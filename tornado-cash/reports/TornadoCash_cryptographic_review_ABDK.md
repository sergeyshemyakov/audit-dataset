# Tornado Privacy Solution Cryptographic Review Version 1.1

Dmitry Khovratovich and Mikhail Vladimirov

ABDK Consulting


November 29, 2019

## **1 Introduction**


We have been approached by Tornado.Cash to review the protocol and the implementation they have
designed. Tornado.Cash implements an Ethereum zero-knowledge mixer: a smart contract that accepts
transactions in Ether (in future also in ERC-20 tokens) so that the amount can be later withdrawn with
no reference to the original transaction.

## **2 Protocol description**


The mixer protocol has the following functionality:


_•_ Insert/deposit money to the mixer. This can be done in a single transaction with a fixed amount
(denoted by _N_ ) of Ether. The _N_ -ETH note is called a _coin_ .


_•_ Remove/withdraw money from the mixer. The _N_ ETH is withdrawn with _f_ Ether sent as a fee to
the mixer owner and ( _N_ _−_ _f_ ) to the designated recipient. The value _f_ is chosen by the sender.


**2.1** **Setup**


Let B = _{_ 0 _,_ 1 _}_ . Let _e_ be the pairing operation used in SNARK proofs, which is defined over groups of
prime order _q_ .

Let _H_ 1 : B <sup>_∗_</sup> _→_ Z _p_ be a Pedersen hash function defined in [Pedb]. Let _H_ 2 : (Z _p,_ Z _p_ ) _→_ Z _p_ be the
MiMC hash function [AGR+16] defined as a MiMC permutation in the Feistel mode in a sponge mode
of operation <sup>1</sup> .

Let _T_ be a Merkle tree of height 16, where each non-leaf node hashes its 2 children with _H_ 2. It is
initialized with all leafs being 0 values. Later the zero values are gradually replaced with other values
from Z _p_ . Let _O_ ( _T, l_ ) be the Merkle opening for leaf with index _l_ (value of sister nodes on the way from
leaf _l_ to the root, denoted by _R_ ) in tree _T_ .

Let us call _k_ _∈_ B <sup>248</sup> a _nullifier_ and _r_ _∈_ B <sup>248</sup> a _randomness_ . Let us denote an Ethereum address of
the coin recipient by _A_ .

Let _S_ [ _R, h, A, f_ ] be the following statement of knowledge with public values _R, h, A, f_ :


_S_ [ _R, h, A, f_ ] = _{_ I KNOW _k, r_ _∈_ B <sup>248</sup> _, l ∈_ B <sup>16</sup> _, O_ _∈_ _Zp_ <sup>16</sup> SUCH THAT _h_ = _H_ 1( _k_ )

AND _O_ is the opening of _H_ 2( _k||r_ ) at position _l_ to _R}_ (1)


where _A_ and _f_ are included into the context of the statement. Here _h_ is called _nullifier_ _hash_ and _||_ is
concatenation of bitstrings.


1 `[https://github.com/iden3/circomlib/blob/master/src/mimcsponge_gencontract.js](https://github.com/iden3/circomlib/blob/master/src/mimcsponge_gencontract.js)`


1


_<u>2.2</u>_ _<u>Deposit</u>_ _<u>3</u>_ _<u>IMPLEMENTATION</u>_


Let _D_ = ( _dp, dv_ ) be the ZK-SNARK [Gro16] proving-verifying key pair for _S_ created using some
trusted setup procedure. Let Prove( _dp, T, k, r, l, A, f_ ) _→_ _P_ be the proof constructor using _dp_ and
Verify( _dv, P, R, h, A, f_ ) be the proof verifier.

Let _C_ be the smart contract that has the following functionality:


_•_ It stores the last _n_ = 100 root values in the history array. For the latest Merkle tree _T_ it also stores
the values of nodes on the path from the last added leaf to the root that are necessary to compute
the next root.


_•_ It accepts payments for _N_ ETH with data _C_ _∈_ Z _p_ . The value _C_ is added to the Merkle tree, the
path from the last added value and the latest root is recalculated. The previous root is added to
the history array.


_•_ It verifies the alleged proof _P_ against the submitted public values ( _R, h, A, f_ ). If verification succeeds, the contract releases ( _N_ _−_ _f_ ) ETH to address _A_ and fee _f_ ETH to the mixer owner.


_•_ It verifies that the coin has not been withdrawn before by checking that the nullifier hash from the
proof has not appeared before and if so, adds it to the list of nullifier hashes.


**2.2** **Deposit**


To deposit a coin, a user proceeds as follows:


1. Generate two random numbers _k, r_ _∈_ B <sup>248</sup> and computes _C_ = _H_ 1( _k||r_ )


2. Send Ethereum transaction with _N_ ETH to contract _C_ with data _C_ interpreted as an unsigned
256-bit integer. If the tree is not full, the contract accepts the transaction and adds _C_ to the tree
as a new non-zero leaf.


**2.3** **Withdrawal**


To withdraw a coin ( _k, r_ ) with position _l_ in the tree a user proceeds as follows:


1. Select a recipient address _A_ and fee value _f_ _< N_ ;


2. Select a root _R_ among the stored ones in the contract and compute opening _O_ ( _l_ ) that ends with _R_ .


3. Compute nullifier hash _h_ = _H_ 1( _k_ ).


4. Compute proof _P_ by calling Prove on _dp_ .


5. Send an Ethereum transaction to contract _C_ supplying _R, h, A, f, P_ in transaction data.


The contract verifies the proof and uniqueness of the nullifier hash. In the successful case it sends ( _N −_ _f_ )
to _A_ and _f_ to the mixer owner and adds _h_ to the list of nullifier hashes.

## **3 Implementation**


The cryptographic functions for off-chain use are implemented in the circomlib library <sup>2</sup> . The Solidity
implementation of Merkle tree, deposit, and withdraw logic is by the authors <sup>3</sup> . The Solidity implementation of MiMC is by iden3 <sup>4</sup> . The SNARK keypair and the Solidity verifier code are generated by the
authors using SnarkJS. The other protocol logic (e.g., Ethereum transaction composition, SNARK proof
construction calls) is by the authors <sup>5</sup> .


2 `[https://github.com/iden3/circomlib/tree/master/circuits](https://github.com/iden3/circomlib/tree/master/circuits)`
3 `[https://github.com/peppersec/tornado-mixer/tree/master/contracts](https://github.com/peppersec/tornado-mixer/tree/master/contracts)`
4 `[https://github.com/iden3/circomlib/blob/master/src/mimcsponge_gencontract.js](https://github.com/iden3/circomlib/blob/master/src/mimcsponge_gencontract.js)`
5 `[https://github.com/peppersec/tornado-mixer/blob/master/cli.js](https://github.com/peppersec/tornado-mixer/blob/master/cli.js)`


2


_<u>5</u>_ _<u>ANALYSIS</u>_

## **4 Security claims**


Tornado claims the following security properties of Mixer:


_•_ Only coins deposited into the contract can be withdrawn;


_•_ No coin can be withdrawn twice;


_•_ Any coin can be withdrawn once if its parameters ( _k, r_ ) are known unless a coin with the same _k_
has been already deposited and withdrawn.


_•_ If _k_ or _r_ is unknown, a coin can not be withdrawn. If _k_ is unknown to the attacker, he can not
prevent the one who knows ( _k, r_ ) from withdrawing the coin (this includes all cases of front-running
a transaction).


_•_ The proof is binding: one can not use the same proof with a different nullifier hash, another recipient
address, or a new fee amount.


_•_ The cryptographic primitives used by Mixer have at least 126-bit security ( except for the BN254
curve where the discrete logarithm problem has something like 100-bit security), and the security
does not degrade because of their composition.


_•_ For each withdrawal every deposit since the last moment when the contract has zero Ether till the
formation of the root in the proof can be a potential coin, though some coins are more likely to be
withdrawn depending on the user behaviour.

## **5 Analysis**


**5.1** **Hash** **function** **issues**


Here we investigate the issues related to the use of hash functions in the protocol. There are two functions
in use: Pedersen hash and MiMC.



**Pedersen** **hash** **issues** The Pedersen hash function is derived from vector Pedersen commitment
_Cr_ ( _x_ 1 _, x_ 2 _, . . ., xm_ ) = _g_ 1 <sup>_x_</sup> <sup>1</sup> <sup>_g_</sup> 2 <sup>_x_</sup> <sup>2</sup> <sup>_· · · g_</sup> _m_ <sup>_xm_</sup> <sup>_g_</sup> _m_ <sup>_r_</sup> +1 <sup>where</sup> <sup>_gi_</sup> <sup>are</sup> <sup>generators</sup> <sup>of</sup> <sup>some</sup> <sup>group</sup> <sup>G.</sup> <sup>It</sup> <sup>is</sup> <sup>known</sup> <sup>that</sup>

Pedersen commitment is computationally binding and perfectly hiding, which makes it a good candidate
for hashing (these properties have some similarity to collision and preimage resistance, respectively). It
can be demonstrated that a collision for _Cr_ ( _x_ 1 _, x_ 2 _, . . ., xm_ ) implies a discrete logarithm relation among
generators, which reduces the collision resistance to the discrete logarithm complexity in the group. However, there is some subtlety in adopting Pedersen commitment to hashing arbitrary long bitstrings. Note
that it is collision resistant only when all _xi_ and _r_ have fixed length and do not exceed the group order.

A concrete instantiation by Iden3 and borrowed by Tornado does the following. A bitstring _M_ is
divided into segments _Mi_ of 200 bits max. We need elliptic-curve points _Pi_ as many as segments. Each
segment is partitioned into 4-bit chunks _mi,j_ interpreted as an integer in the set [ _−_ 8; 8] _\_ 0. Then one
computes [Pedb]:






 _._ (2)



_H_ 1( _M_ ) =






_i_



_Pi_





 <sup>�</sup> 2 <sup>5</sup> <sup>_j_</sup> _mi,j_

0 _≤j<_ 50



where summation is the addition on the curve and multiplication is scalar. The actual implementation
for the BN254 curve [Peda] deviates from [Pedb] as it uses only 10 points, so at most 2000 bits can be
hashed.

Note the following properties of the resulting hash function:


1. It adds redundancy to the scalar: only 200 bits are used, whereas the BN254 group has order above
2 <sup>253</sup>, so 53 bits are unused.


3


_<u>5.2</u>_ _<u>User</u>_ _<u>mistakes</u>_ _<u>5</u>_ _<u>ANALYSIS</u>_


2. It is homomorphic: if we denote by **P** the vector of generators used in _H_ 1, then


_H_ 1 <sup>**P**</sup> <sup>(</sup> <sup>_M_</sup> <sup>1) +</sup> <sup>_H_</sup> 1 <sup>**Q**</sup> <sup>(</sup> <sup>_M_</sup> <sup>2) =</sup> <sup>_H_</sup> 1 <sup>**P**</sup> <sup>_||_</sup> <sup>**Q**</sup> ( _M_ 1 _||M_ 2) _._ (3)


This property is useful in commitments in many protocols, but for a hash function it is quite
unexpected, and such a hash function should be used with great care. For example, if one computes
a message authentication code (MAC) with this function as _H_ 1( _K||M_ ) where _K_ is secret then,
obviously, a MAC for _M_ 1 _||M_ 2 can be easily obtained from MAC for _M_ 1. Such a property, called
length extension, has been used in many attacks <sup>6</sup> . It is also insecure to make several hash functions
out of one by using domain separation prefix as _Hq_ ( _x_ ) = _H_ 1( _q||x_ ) as it becomes just a public
addend in the formula.


3. During witdrawal the nullifier hash _H_ 1( _k_ ) is revealed. Looking at each previous deposit with
commitment _C_, the attacker guesses that it is _H_ 1( _k||r_ ), and then he can obtain candidate _H_ 1 <sup>_′_</sup> <sup>(</sup> <sup>_r_</sup> <sup>)</sup>

using Equation (3).


_H_ 1( _k||r_ ) = _f_ 1( _k_ ) _P_ 1 + ( _f_ 2( _k_ ) + _f_ 3( _r_ )) _P_ 2 + _f_ 4( _r_ ) _P_ 3; (4)

_H_ 1( _k_ ) = _f_ 1( _k_ ) _P_ 1 + _f_ 2( _k_ ) _P_ 2; (5)

_H_ 1 <sup>_′_</sup> <sup>(</sup> <sup>_r_</sup> <sup>) =</sup> <sup>_f_</sup> <sup>3(</sup> <sup>_r_</sup> <sup>)</sup> <sup>_P_</sup> <sup>2</sup> <sup>+</sup> <sup>_f_</sup> <sup>4(</sup> <sup>_r_</sup> <sup>)</sup> <sup>_P_</sup> <sup>3</sup> <sup>_._</sup> (6)


for some arithmetic functions _f_ 1 _, f_ 2 _, f_ 3 _, f_ 4. If _r_ has low entropy, the attacker can check his guess
and thus break the anonymity of the scheme.


4. It requires an elliptic curve arithmetic to be implemented. The current implementation of Pedersen
hash used by Tornado relies on a very new elliptic curve BabyJubJub.


We found **no** **way** **to** **exploit** **these** **properties** in the concrete protocol by Tornado: the authors
use the Pedersen hash in a proper way. For all future protocol that might rely on this one, the following
steps must be taken:


_•_ Always call Pedersen hash with same message length.


_•_ If messages of different lengths must be used, generate a completely new set of generators for each
length.


**MiMC** **issues** There is an attack on the blockcipher version of MiMC [Bon19], which does not apply
to the MiMC hash function (and we do not see any way to do that).


**Multiple** **hash** **functions** Tornado uses two hash functions in the design, and both are used in zeroknowledge proofs. This is redundant and increases the attack surface: an attack on either design can
break the entire protocol. We thus recommend using only one hash function - MiMC or more efficient
variants (see Section 5.4).


**Elliptic** **curve** **issues** The BN254 curve used for zkSNARKs has security level of only 100 bits according to recent cryptanalytic results [BD17]. An attacker with this capacity (though clearly inexistent
nowadays) can forge SNARK proofs and withdraw arbitrary amount of coins from Mixer. We recommend using a curve with higher estimated security (such as BLS12-381) but unfortunately the pairing
operation for such curves has not been added to Ethereum and thus would cost a great amount of gas if
implemented directly.


**5.2** **User** **mistakes**


In this section we investigate mistakes that are likely to occur in an implementation or done by users.
We check if the protocol is robust to some of them.


6For example, an attack on Flickr `[http://netifera.com/research/flickr_api_signature_forgery.pdf](http://netifera.com/research/flickr_api_signature_forgery.pdf)` .


4


_<u>5.3</u>_ _<u>Claim</u>_ _<u>verification</u>_ _<u>5</u>_ _<u>ANALYSIS</u>_


_•_ Consider the nullifier value _k_ . If _k_ has low entropy, an attacker can guess it, then submit his own
commitment with the same _k_ but different _r_, and withdraw it. As a result, a nullifier hash _H_ 1( _k_ )
will be added to the list and the user will be unable to withdraw his coin. The same situation
occurs if _k_ is stolen.


If user for any reason repeats _k_ (due to buggy software or accidental transaction doubling) or
another user takes the same _k_, then only one coin with given _k_ can be withdrawn (the first one
tried to be withdrawn), and the others are effectively lost. We recommend to take the position in
the tree as input when computing _h_, so same commitments in different leafs can still be withdrawn.


_•_ Consider now the randomness value _r_ . If _r_ is stolen or has low entropy, the anonymity is broken
as explained earlier in the text: an attacker can compute _H_ 1 <sup>_′_</sup> <sup>(</sup> <sup>_r_</sup> <sup>)</sup> <sup>and</sup> <sup>for</sup> <sup>every</sup> <sup>submitted</sup> <sup>nullifier</sup>

he computes the original commitment _H_ 1( _k, r_ ). In the low entropy case the attacker can verify his
guess against the history of commitments.


If _r_ repeats, nothing bad happens, as it is used only for a proof and no function of it is published
during the withdrawal. As long as _k_ and _r_ together have sufficient entropy, an attacker can not link
two commitments together.


We checked the Tornado random number generator (RNG) in the supplied client code and **found** **that**
**it** **yields** **enough** **entropy** for security. All third-party implementations must ensure a good RNG is
used for secret generation.


**5.3** **Claim** **verification**


In this section we check the original security claims by the designers.


1. Consider a successful withdrawal with nullifier hash _h_ . A SNARK proof is sound and complete,
so Prover knows _k, r, l, O_ such that _h_ = _H_ 1( _k_ ) and _O_ ( _l_ ) opens _H_ 1( _k, r_ ) to root _R_ . Assuming that
MiMC is collision resistant, _H_ 1( _k, r_ ) must be a leaf in the tree, so for each withdrawal there must
be a deposit in the tree it refers to. **True** .


2. Suppose some deposit _C_ has been withdrawn twice. According to the SNARK proof, there must
be a valid ( _k, r_ ) pair in each case. As _H_ 1 is collision resistant, the pairs are the same, but then
nullifier hashes _H_ 1( _k_ ) must also collide, which is forbidden by the protocol. **True** .


3. If all _k_ are different, a coin can always be withdrawn if its nullifier is unique. For the nullifier to
repeat, a collision must be found in the nullifier hash function. This contradicts the assumption of
MiMC being collision resistant. **True** .


4. If _k_ or _r_ are unknown, a coin can not be withdrawn as this would contradict the SNARK proof of
knowledge of _k_ and _r_ . We have not found a way to front run the transaction when _k_ is unknown.
**True** .


5. A SNARK proof can not be used for another _h_ as the circuit involves the calculation of _h_ . The
recipient address and fee can not be changed either, as long as they are in the SNARK proof context
(this must be checked in the implementation too). **True** .


6. We have found that all primitives have at least 126-bit security, except for the BN254 curve. It
does not make sense though to increase the security above the BN254 level, since finding discrete
logarithms on it would imply signature forgery in the entire Ethereum, which would be a bigger
problem than the Mixer insecurity. **True** .


7. It is obvious that if the contract has zero balance, then every earlier deposit has been withdrawn.
We have, however, found one more such case.


Suppose a tree with root _R_ has _n_ leafs, and there has been _n_ withdrawals with proofs for _R_ or an
earlier root. Then all _n_ deposits to _R_ must have been t. **Mostly** **true** .


5


_<u>5.4</u>_ _<u>Optimality</u>_ _<u>REFERENCES</u>_


**5.4** **Optimality**


We have found several ways to optimize the protocol:


_•_ The value _r_ can be optimized away, since there are two secret variables for each deposit which are
not opened. As long as _k_ has sufficient entropy and different functions are used to compute the
commitment and the nullifier hash, one variable is sufficient. An alternative construction would be


Commitment _C_ = _H_ ( _k,_ 0);


Nullifier hash _h_ = _H_ ( _k,_ 1 _, l_ ) _,_


where _H_ is non-homomorphic hash function and _l_ is the tree position. With a 15-byte _k_, everything
can be packed into two field elements. This construction is also robust to nullifier reuse: in this
case, deposits will be identical but both can still be withdrawn.


_•_ The same hash function can be used for tree hashing, nullifier hashing, and commitment construction.


_•_ The used hash functions are expensive, particularly Pedersen hash, which has a large codebase and
largest number of SNARK constraints. If the gas costs become too high, an alternative might be
to use a more recent (but not that thoroughly tested) Poseidon [GKK+19] with its 2:1 variant and
the S-box _x_ <sup>5</sup> adapted for the BN254 curve. It has 80 S-boxes per call (and 240 constraints) where
it processes two field elements. Thus for the SNARK proof we need 18 calls to Poseidon, thus 4320
constraints in total, a 5x reduction over the current case.

## **References**


[AGR+16] Martin R. Albrecht, Lorenzo Grassi, Christian Rechberger, et al. “MiMC: Efficient Encryption and Cryptographic Hashing with Minimal Multiplicative Complexity”. In: _ASIACRYPT_
_(1)_ . Vol. 10031. Lecture Notes in Computer Science. 2016, pp. 191–219 (cit. on p. 1).


[BD17] Razvan Barbulescu and Sylvain Duquesne. “Updating key size estimations for pairings”. In:
_IACR_ _Cryptology_ _ePrint_ _Archive_ 2017 (2017), p. 334 (cit. on p. 4).


[Bon19] Xavier Bonnetain. _Collisions_ _on_ _Feistel-MiMC_ _and_ _univariate_ _GMiMC_ . Cryptology ePrint
Archive, Report 2019/951. `[https://eprint.iacr.org/2019/951](https://eprint.iacr.org/2019/951)` . 2019 (cit. on p. 4).


[GKK+19] Lorenzo Grassi, Daniel Kales, Dmitry Khovratovich, et al. “Starkad and Poseidon: New
Hash Functions for Zero Knowledge Proof Systems”. In: _IACR_ _Cryptology_ _ePrint_ _Archive_
2019 (2019) (cit. on p. 6).


[Gro16] Jens Groth. “On the Size of Pairing-Based Non-interactive Arguments”. In: _EUROCRYPT_
_2016_ . Vol. 9666. LNCS. Springer, 2016, pp. 305–326 (cit. on p. 2).


[Peda] _Circomlib:_ _Pedersen_ _Hash_ . `[https : / / github . com / iden3 / circomlib / blob / master /](https://github.com/iden3/circomlib/blob/master/circuits/pedersen.circom)`
`[circuits/pedersen.circom](https://github.com/iden3/circomlib/blob/master/circuits/pedersen.circom)` . 2019 (cit. on p. 3).


[Pedb] _Iden3:_ _Pedersen_ _Hash_ . `[https://iden3-docs.readthedocs.io/en/latest/iden3_repos/](https://iden3-docs.readthedocs.io/en/latest/iden3_repos/research/publications/zkproof-standards-workshop-2/pedersen-hash/pedersen.html)`
```
      research/publications/zkproof-standards-workshop-2/pedersen-hash/pedersen.
```

`[html](https://iden3-docs.readthedocs.io/en/latest/iden3_repos/research/publications/zkproof-standards-workshop-2/pedersen-hash/pedersen.html)` . 2019 (cit. on pp. 1, 3).


6


