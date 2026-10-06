package keccak

import (
	"errors"
	"github.com/consensys/gnark/frontend"
	"github.com/consensys/gnark/std/lookup/logderivlookup"
	"github.com/consensys/zkevm-monorepo/prover/circuits/blobdecompression/v0/compress"
	"github.com/consensys/zkevm-monorepo/prover/circuits/internal/plonk"
	"github.com/consensys/zkevm-monorepo/prover/protocol/compiler/dummy"
	"github.com/consensys/zkevm-monorepo/prover/protocol/wizard"
	"github.com/consensys/zkevm-monorepo/prover/utils"
	"math/big"
	"slices"
)

type slice struct {
	s      []frontend.Variable
	length frontend.Variable
}

// Hasher is stateless from the user's perspective, but in the background it prepares columns for the Vortex prover
type Hasher struct {
	Api     frontend.API
	NbLanes int
	buffer  []slice
}

// Sum takes in ineLen many 32-byte blocks of slice. bytess[i] for i ≥ inLen are ignored.
// nbIn is not range-checked. Caller must ensure that inLen ≤ len(bytess)
// if nbIn is nil, it is assumed to be len(bytess)
// bytes are not range-checked. Caller must ensure that bytess[i][j] < 256
// the output are 32 bytes
func (h *Hasher) Sum(nbIn frontend.Variable, bytess ...[32]frontend.Variable) [32]frontend.Variable {

	hintIn := make([]frontend.Variable, 1+32*len(bytess))
	radix := big.NewInt(256)
	unpaddedLanes := make([]frontend.Variable, 4*len(bytess))
	for i := range bytess {
		var currLaneBytes [8]frontend.Variable
		for j := 0; j < 4; j++ {
			copy(currLaneBytes[:], bytess[i][8*j:8*j+8])
			slices.Reverse(currLaneBytes[:])
			unpaddedLanes[4*i+j] = compress.ReadNum(h.Api, currLaneBytes[:], radix)
		}
		copy(hintIn[i*32+1:i*32+33], bytess[i][:])
	}

	nbLanes := nbIn
	if nbLanes != nil {
		nbLanes = h.Api.Mul(nbLanes, 4)
	}
	paddedLanes, nbPaddedLanes := pad(h.Api, unpaddedLanes, nbLanes)

	h.buffer = append(h.buffer,
		slice{
			s:      paddedLanes,
			length: nbPaddedLanes,
		})

	if hintIn[0] = nbIn; nbIn == nil {
		hintIn[0] = len(bytess)
	}

	outS, err := h.Api.Compiler().NewHint(keccakHint, 32, hintIn...)

	for i := range outS {
		h.Api.AssertIsLessOrEqual(outS[i], 255)
	}

	if err != nil {
		panic(err)
	}
	var out [32]frontend.Variable
	copy(out[:], outS)
	return out
}

func (h *Hasher) Finalize(c *wizard.WizardVerifierCircuit) error {
	lanes, isLaneActive, isFirstLaneOfNewHash := h.createColumns()
	expectedLanes := c.GetColumn("Lane")
	expectedActive := c.GetColumn("IsLaneActive")
	expectedNewLane := c.GetColumn("IsFirstLaneOfNewHash")
	if len(lanes) != len(expectedLanes) || len(isLaneActive) != len(expectedActive) || len(isFirstLaneOfNewHash) != len(expectedNewLane) {
		return errors.New("column length mismatch")
	}
	for i := range lanes {
		h.Api.AssertIsEqual(expectedLanes[i], lanes[i])
		h.Api.AssertIsEqual(expectedActive[i], isLaneActive[i])
		h.Api.AssertIsEqual(expectedNewLane[i], isFirstLaneOfNewHash[i])
	}
	c.Verify(h.Api)
	return nil
}

// createColumns prepares the columns for the Vortex prover
func (h *Hasher) createColumns() (lanes, isLaneActive, isFirstLaneOfNewHash []frontend.Variable) {
	lanes = make([]frontend.Variable, h.NbLanes)
	isLaneActive = make([]frontend.Variable, h.NbLanes)
	isFirstLaneOfNewHash = make([]frontend.Variable, h.NbLanes)

	maxMaxLanesPerHash := 0
	lengths := logderivlookup.New(h.Api)
	nbLanes := frontend.Variable(0)
	for i := range h.buffer {
		nbLanes = h.Api.Add(nbLanes, h.buffer[i].length)
		lengths.Insert(h.buffer[i].length)
		if len(h.buffer[i].s) > maxMaxLanesPerHash {
			maxMaxLanesPerHash = len(h.buffer[i].s) // this value will be used to create a "two-dimensional" table
		}
	}
	lengths.Insert(-1) // a phantom extra hash that never runs out
	h.Api.AssertIsLessOrEqual(nbLanes, h.NbLanes)

	lanesT := logderivlookup.New(h.Api)
	for i := range h.buffer {
		for j := range h.buffer[i].s {
			lanesT.Insert(h.buffer[i].s[j])
		}
		for j := len(h.buffer[i].s); j < maxMaxLanesPerHash; j++ {
			lanesT.Insert(0)
		}
	}
	for j := 0; j < len(lanes); j++ {
		lanesT.Insert(0) // lots of lanes for the phantom hash
	}

	var (
		currHashI, currHashLaneI                   frontend.Variable = 0, 0
		isCurrLaneActive, isCurrFirstLineOfNewHash frontend.Variable = 1, 1
	)

	for i := range lanes {
		// isCurrLaneActive = isCurrLaneActive ? (currHashI != len(h.buffer)) : 0
		isCurrLaneActive = plonk.EvaluateExpression(h.Api, isCurrLaneActive, h.Api.IsZero(h.Api.Sub(currHashI, len(h.buffer))), 1, 0, -1, 0)
		isLaneActive[i] = isCurrLaneActive

		isFirstLaneOfNewHash[i] = h.Api.Mul(isCurrFirstLineOfNewHash, isCurrLaneActive) // TODO is it okay to have firstLine = 1, active = 0? If not, can remove the mul

		lanes[i] = lanesT.Lookup(h.Api.Add(currHashLaneI, h.Api.Mul(maxMaxLanesPerHash, currHashI)))[0]

		// prepare the next iteration
		currHashLaneI = h.Api.Add(currHashLaneI, 1)
		isCurrFirstLineOfNewHash = h.Api.IsZero(h.Api.Sub(currHashLaneI, lengths.Lookup(currHashI)[0]))
		currHashI = h.Api.Add(currHashI, isCurrFirstLineOfNewHash)
		// currHashLaneI = isCurrFirstLineOfNewHash ? 0 : currHashLaneI = (1-isCurrFirst...) * currHashLaneI
		currHashLaneI = plonk.EvaluateExpression(h.Api, currHashLaneI, isCurrFirstLineOfNewHash, 1, 0, -1, 0)
	}

	h.buffer = h.buffer[:0] // unlikely for this object to be reused, but make it reusable anyway
	return
}

// ins[0] is the number of bytes to come, divided by 32
// input are bytes
// output are 2-byte lanes
func keccakHint(_ *big.Int, ins, outs []*big.Int) error {

	inLen := ins[0].Uint64() * 32
	if !ins[0].IsUint64() || inLen > uint64(len(ins))-1 {
		return errors.New("input length too large")
	}
	ins = ins[1 : inLen+1]
	inBytes := make([]byte, len(ins))

	for i := range ins {
		if b := ins[i].Uint64(); !ins[i].IsUint64() || b > 255 {
			return errors.New("not a byte")
		} else {
			inBytes[i] = byte(b)
		}
	}
	outBytes := utils.KeccakHash(inBytes)
	if len(outBytes) != 32 {
		return errors.New("output is not 32 bytes")
	}

	outElemSize := 32 / len(outs)
	if outElemSize*len(outs) != 32 {
		return errors.New("output size does not divide 32")
	}

	for i := range outs {
		outs[i].SetBytes(outBytes[i*outElemSize : (i+1)*outElemSize])
	}

	return nil
}

const (
	lanesPerBlock        = 17
	dstLane       uint64 = 0x1
	lastLane      uint64 = 0x8000000000000000
)

// pad takes a slice of 8-byte lanes and pads then into 17-lane blocks as per the Keccak standard
// if length is not provided, it is assumed to be len(inputLanes)
// the slice is not range checked. It is furthermore not checked if length ⩽ len(inputBytes)
func pad(api frontend.API, inputLanes []frontend.Variable, length frontend.Variable) (lanes []frontend.Variable, nbLanes frontend.Variable) {
	if length == nil {
		nbBlocks := 1 + len(inputLanes)/lanesPerBlock
		lanes = make([]frontend.Variable, nbBlocks*lanesPerBlock) // static length
		nbLanes = len(lanes)
		copy(lanes, inputLanes)
		if len(inputLanes)+1 == len(lanes) {
			lanes[len(inputLanes)] = dstLane | lastLane
		} else {
			lanes[len(inputLanes)] = dstLane
			lanes[len(lanes)-1] = lastLane
		}
		for i := len(inputLanes) + 1; i < len(lanes)-1; i++ {
			lanes[i] = 0
		}
		return
	}

	// dynamic padding

	nbBlocks, _, err := divByLanesPerBlock(api, length)
	if err != nil {
		panic(err)
	}
	nbBlocks = api.Add(1, nbBlocks)
	nbLanes = api.Mul(nbBlocks, lanesPerBlock)
	lanes = make([]frontend.Variable, lanesPerBlock*(1+len(inputLanes)/lanesPerBlock))
	if n := copy(lanes, inputLanes); n != len(lanes) {
		for i := n; i < len(lanes); i++ {
			lanes[i] = 0
		}
	}

	//inInputRange := frontend.Variable(1)
	for i := range lanes {

		iEqualsLen := api.IsZero(api.Sub(length, i))

		/*inInputRange = api.Sub(inInputRange, iEqualsLen)

		lanes[i] = api.Mul(inInputRange, lanes[i]) // technically unnecessary if we say input must be zero-padded */

		lanes[i] = api.Add(lanes[i], api.Mul(dstLane, iEqualsLen)) // first padding byte contribution

		if i%lanesPerBlock == lanesPerBlock-1 { // if it's the last byte of ANY block
			isLastBlock := api.IsZero(api.Sub(i+1, api.Mul(nbBlocks, lanesPerBlock))) // TODO check the slice to IsZero involves one constraint only
			lanes[i] = api.Add(lanes[i], api.Mul(isLastBlock, lastLane))
		}
	}

	return

}

func divByLanesPerBlock(api frontend.API, x frontend.Variable) (q, r frontend.Variable, err error) {
	hintOuts, err := api.Compiler().NewHint(divByLanesPerBlockHint, 2, x)
	if err == nil {
		q, r = hintOuts[0], hintOuts[1]
		api.AssertIsLessOrEqual(r, lanesPerBlock-1)
		api.AssertIsLessOrEqual(q, x)
	}
	return
}

// output are of the form q₀, r₀, q₁, r₁, ...
func divByLanesPerBlockHint(_ *big.Int, ins, outs []*big.Int) error {
	if len(outs) != len(ins)*2 {
		return errors.New("incongruent in/out lengths")
	}
	for i := range ins {
		if !ins[i].IsUint64() {
			return errors.New("non-uint64 not implemented")
		}
		in := ins[i].Uint64()
		q, r := in/lanesPerBlock, in%lanesPerBlock
		outs[2*i].SetUint64(q)
		outs[2*i+1].SetUint64(r)
	}
	return nil
}

type HashWizardVerifierSubCircuit struct {
	m        module
	compiled *wizard.CompiledIOP
}

func AssignKeccakWizardVerifier(ins [][]byte) {

}

func NewWizardVerifierSubCircuit(maxNbKeccakF int) *HashWizardVerifierSubCircuit {
	var c HashWizardVerifierSubCircuit
	c.compiled = wizard.Compile(func(b *wizard.Builder) {
		c.m.DefineCustomizedKeccak(b.CompiledIOP, maxNbKeccakF)
	}, dummy.Compile)
	return &c
}

func (c *HashWizardVerifierSubCircuit) prove(ins [][]byte) wizard.Proof {
	c.m.SliceProviders = ins
	return wizard.Prove(c.compiled, func(r *wizard.ProverRuntime) {
		c.m.AssignCustomizedKeccak(r)
	})
}

func (c *HashWizardVerifierSubCircuit) Compile() (*wizard.WizardVerifierCircuit, error) {
	return wizard.AllocateWizardCircuit(c.compiled)
}

func (c *HashWizardVerifierSubCircuit) Assign(ins [][]byte) *wizard.WizardVerifierCircuit {
	return wizard.GetWizardVerifierCircuitAssignment(c.compiled, c.prove(ins))
}
