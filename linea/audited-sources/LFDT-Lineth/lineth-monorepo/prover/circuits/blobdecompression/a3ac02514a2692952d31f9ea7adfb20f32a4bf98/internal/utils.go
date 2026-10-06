package internal

import (
	"errors"
	"math/big"
	"slices"

	fr377 "github.com/consensys/gnark-crypto/ecc/bls12-377/fr"
	"github.com/consensys/gnark-crypto/ecc/bls12-381/fr"
	hint "github.com/consensys/gnark/constraint/solver"
	"github.com/consensys/gnark/frontend"
	"github.com/consensys/gnark/std/lookup/logderivlookup"
)

// Truncate ensures that the slice is 0 starting from the n-th element
func Truncate(api frontend.API, slice []frontend.Variable, n frontend.Variable) []frontend.Variable {
	nYet := frontend.Variable(0)
	res := make([]frontend.Variable, len(slice))
	for i := range slice {
		nYet = api.Add(nYet, api.IsZero(api.Sub(i, n)))
		res[i] = api.MulAcc(api.Mul(1, slice[i]), slice[i], api.Neg(nYet))
	}
	return res
}

func SliceToTable(api frontend.API, slice []frontend.Variable) *logderivlookup.Table {
	table := logderivlookup.New(api)
	for i := range slice {
		table.Insert(slice[i])
	}
	return table
}

// RotateLeft rotates the slice v by n positions to the left, so that res[i] becomes v[(i+n)%len(v)]
func RotateLeft(api frontend.API, v []frontend.Variable, n frontend.Variable) (res []frontend.Variable) {
	res = make([]frontend.Variable, len(v))
	t := SliceToTable(api, v)
	for _, x := range v {
		t.Insert(x)
	}
	for i := range res {
		res[i] = t.Lookup(api.Add(i, n))[0]
	}
	return
}

// Bls12381ScalarToBls12377Scalars interprets its input as a BLS12-381 scalar, with a modular reduction if necessary, returning two BLS12-377 scalars
// r[1] is the lower 252 bits. r[0] is the higher 3 bits.
// useful in circuit "assign" functions
func Bls12381ScalarToBls12377Scalars(v interface{}) (r [2][]byte, err error) {
	var x fr.Element
	_, err = x.SetInterface(v)
	b := x.Bytes()

	r[0] = make([]byte, fr377.Bytes)
	r[0][fr.Bytes-1] = b[0] >> 4

	b[0] &= 0x0f
	r[1] = b[:]
	return
}

func RegisterHints() {
	hint.RegisterHint(toCrumbHint)
}

func toCrumbHint(_ *big.Int, ins, outs []*big.Int) error {
	if len(ins) != 1 {
		return errors.New("expected 1 input")
	}
	if len(outs) >= 32 || !ins[0].IsUint64() {
		return errors.New("large field elements not yet supported")
	}
	in := ins[0].Uint64()
	for i := range outs {
		outs[i].SetUint64(in & 3)
		in >>= 2
	}
	return nil
}

// TODO add to gnark: bits.ToBase
// toCrumbs decomposes scalar v into nbCrumbs 2-bit digits.
// It uses Little Endian order for compatibility with gnark, even though we use Big Endian order in the circuit
func toCrumbs(api frontend.API, v frontend.Variable, nbCrumbs int) []frontend.Variable {
	res, err := api.Compiler().NewHint(toCrumbHint, nbCrumbs, v)
	if err != nil {
		panic(err)
	}
	for _, c := range res {
		api.AssertIsCrumb(c)
	}
	return res
}

// PackedBytesToCrumbs converts a slice of bytes, padded with zeros on the left to make packingSize bits field elements, into a slice of two-bit crumbs
// panics if packingSize is not a multiple of 2
func PackedBytesToCrumbs(api frontend.API, bytes []frontend.Variable, bitsPerElem int) []frontend.Variable {
	crumbsPerElem := bitsPerElem / 2
	if bitsPerElem != 2*crumbsPerElem {
		panic("packing size must be a multiple of 2")
	}
	bytesPerElem := (bitsPerElem + 7) / 8
	firstByteNbCrumbs := crumbsPerElem % 4
	if firstByteNbCrumbs == 0 {
		firstByteNbCrumbs = 4
	}
	nbElems := (len(bytes) + bytesPerElem - 1) / bytesPerElem

	if nbElems*bytesPerElem != len(bytes) { // pad with zeros if necessary
		tmp := bytes
		bytes = make([]frontend.Variable, nbElems*bytesPerElem)
		copy(bytes, tmp)
		for i := len(tmp); i < len(bytes); i++ {
			bytes[i] = 0
		}
	}

	res := make([]frontend.Variable, 0, nbElems*crumbsPerElem)

	for i := 0; i < len(bytes); i += bytesPerElem {
		// first byte
		b := toCrumbs(api, bytes[i], firstByteNbCrumbs)
		slices.Reverse(b)
		res = append(res, b...)
		// remaining bytes
		for j := 1; j < bytesPerElem; j++ {
			b = toCrumbs(api, bytes[i+j], 4)
			slices.Reverse(b)
			res = append(res, b...)
		}
	}

	return res
}

func Pack(api frontend.API, words []frontend.Variable, bitsPerElem, bitsPerWord int) []frontend.Variable {
	if bitsPerWord > bitsPerElem {
		panic("words don't fit in elements")
	}
	wordsPerElem := bitsPerElem / bitsPerWord
	res := make([]frontend.Variable, (len(words)+wordsPerElem-1)/wordsPerElem)
	if len(words) != len(res)*wordsPerElem {
		tmp := words
		words = make([]frontend.Variable, len(res)*wordsPerElem)
		copy(words, tmp)
		for i := len(tmp); i < len(words); i++ {
			words[i] = 0
		}
	}

	// TODO add this to gnark: bits.FromBase
	coeffs := make([]*big.Int, wordsPerElem)
	for i := range coeffs {
		coeffs[len(coeffs)-1-i] = new(big.Int).Lsh(big.NewInt(1), uint(i*bitsPerWord))
	}

	// TODO use compress.ReadNum?
	for i := range res {
		currWords := words[i*wordsPerElem : (i+1)*wordsPerElem]
		res[i] = api.Mul(coeffs[0], currWords[0]) // TODO once the "add 0" optimization is implemented in gnark, remove this line
		for j := 1; j < len(currWords); j++ {
			res[i] = api.MulAcc(res[i], coeffs[j], currWords[j])
		}
	}
	return res
}

// PackFull packs as many words as possible into a single field element
// The words are construed in big-endian, and 0 padding is added as needed on the left for every element and on the right for the last element
func PackFull(api frontend.API, words []frontend.Variable, bitsPerWord int) []frontend.Variable {
	return Pack(api, words, api.Compiler().FieldBitLen()-1, bitsPerWord)
}
