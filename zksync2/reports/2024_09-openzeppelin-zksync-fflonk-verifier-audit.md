### | security

# **FFLONK Verifier** **Audit**

#### **September 26, 2024**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  4


Scope ____________________________________________________________________________  5

Phase 1 5

Phase 2 5

Phase 3 5


System Overview __________________________________________________________________  7


Security Model and Trust Assumptions _______________________________________________  8


Design Considerations and Trade-Offs ________________________________________________  8


Critical Severity __________________________________________________________________ 10

C-01 Lack of Input Validation Allows Proof Forgery for Arbitrary Public Inputs - Phase 1 10


Medium Severity _________________________________________________________________ 13

M-01 Missing Proof Validation - Phase 1 13


Low Severity ____________________________________________________________________ 14

L-01 Incorrect Bound Check in Lagrange Polynomial Evaluations - Phase 1 14

L-02 Two Representations of the Point-At-Infinity - Phase 1 14

L-03 Missing Docstrings - Phase 1 15

L-04 Brittle Use of Free Memory Pointer - Phase 1 15

L-05 Misleading Documentation - Phase 1 16

L-06 Lack of Validation of Proof Size - Phase 3 17


Notes & Additional Information ____________________________________________________ 17

N-01 Some Memory Variables Could Be Constants – Phase 2 17

N-02 Lack of SPDX License Identifier - Phase 1 18

N-03 Lack of Security Contact - Phase 1 18

N-04 State Variable Visibility Not Explicitly Declared - Phase 1 19

N-05 The Codebase Cannot Be Compiled With the Default Settings - Phase 1 19

N-06 Invalid Reverts - Phase 1 20

N-07 Code Quality and Readability Suggestions - Phase 1 20

N-08 Gas Optimizations - Phase 1 21

N-09 Overwriting of the Free Memory Pointer - Phase 3 22

N-10 Use of Magic Number - Phase 3 22

N-11 Inconsistent Representation of Hex Values - Phase 3 23

N-12 Missing or Misleading Documentation - Phase 3 23


FFLONK Verifier Audit − Table of Contents − 2


N-13 Missing Documentation About Treatment of Point at Infinity - Phase 3 24

N-14 PLONK verify Function Has public Visibility - Phase 3 24


Conclusion ______________________________________________________________________ 26


FFLONK Verifier Audit − Table of Contents − 3


## **Summary**

**Type** ZK Rollup


**Timeline** From 2024-07-22
To 2024-09-13


**Languages** Solidity, Yul



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



1 (1 resolved)


0 (0 resolved)


1 (1 resolved)



**Total Issues** 22 (21 resolved)



**Low Severity Issues** 6 (6 resolved)



**Notes & Additional**
**Information**



14 (13 resolved)



FFLONK Verifier Audit − Summary − 4


## **Scope**

The audit took place in three phases.

### **Phase 1**


In the first phase, we audited the <u>[matter-labs/fflonk-verifier](https://github.com/matter-labs/fflonk-verifier/)</u> repository at commit <u>[3881e18.](https://github.com/matter-labs/fflonk-verifier/tree/3881e1839a3ecab8ba2159cb5113ffcc1b523e69)</u>


In scope was the following file:

```
fflonk-verifier
└── solidity/fflonk-foundry/src/FflonkYul.sol

### **Phase 2**

```

In the second phase, we audited the <u>[matter-labs/fflonk-verifier](https://github.com/matter-labs/fflonk-verifier/)</u> repository at commit <u>[3c09dfd.](https://github.com/matter-labs/fflonk-verifier/tree/3c09dfd93ff1f5fb8dc25cb0872755782561af59)</u>

This audit was focused on an update of the verifier and had the same scope as phase 1:

```
fflonk-verifier
└── solidity/fflonk-foundry/src/FflonkYul.sol

### **Phase 3**

```

In the third phase, we audited the <u>[matter-labs/fflonk-verifier](https://github.com/matter-labs/fflonk-verifier/)</u> repository at commit <u>[c9e99a8,](https://github.com/matter-labs/fflonk-verifier/tree/c9e99a8760774fcc45df110fddd954246feac00c)</u>

which was an update of the FFLONK verifier with the same scope as phases 1 and 2:

```
fflonk-verifier
└── solidity/fflonk-foundry/src/FflonkYul.sol

```

In addition, we audited the <u>[matter-labs/era-contracts](https://github.com/matter-labs/era-contracts/)</u> repository at commit <u>[49868af, with the](https://github.com/matter-labs/era-contracts/tree/49868afc8590c3d09daf4d5fc73dcc31587f487d)</u>

goal of ensuring that the validator calls to prove batches were compatible with the verifier. The

scope was comprised of portions of the following files:

```
era-contracts/l1-contracts/contracts/state-transition
├── chain-deps
│  └── facets
│    └── Executor.sol

```

FFLONK Verifier Audit − Scope − 5


```
├── chain-interfaces
│  ├── IExecutor.sol
│  └── IVerifier.sol
└── Verifier.sol

```

Specifically, for <mark>`Executor.sol`</mark> <mark>,</mark> the proving flow consisting of the

<mark>`proveBatchesSharedBridge`</mark> function and its subsequent function calls were audited. This

audit was performed with the goal of ensuring completeness and soundness, assuming all

prior steps were functioning as intended. As such, all prior operations such as committing

batches, as well as latter operations such as executing batches, were deemed out of scope.

These changes will be audited as part of a separate audit. As mentioned below, the circuit itself

was also deemed out of scope.


The <mark>`IExecutor.sol`</mark> and <mark>`IVerifier.sol`</mark> interfaces were checked to ensure compatibility

with both the current <mark>`Verifier.sol`</mark> and the new <mark>`FFlonkYul.sol`</mark> file. The current verifier,

located in <mark>`Verifier.sol`</mark> <mark>,</mark> was assumed to be functioning correctly outside of this interface

change.


All resolutions in this report related to <mark>`FflonkYul.sol`</mark> are contained at commit <u>[8aaf8b7](https://github.com/matter-labs/fflonk-verifier/tree/8aaf8b789ef49b900b4fb1079042c6e016e43bcd)</u> in

the <u>[fflonk-verifier](https://github.com/matter-labs/fflonk-verifier/)</u> repository. This commit marks the final state of the audited contract.


FFLONK Verifier Audit − Scope − 6


## **System Overview**

The upgrade under review aims to reduce the gas required for on-chain verification. When L2

blocks are produced, the sequencer submits them to the L1 <mark>`Executor`</mark> contract and a prover

generates a proof of the associated state transitions. This proof generation is done with layers

of recursion, finally resulting in the final proof that is submitted on-chain. Upon submission of

this proof, the <mark>`Executor`</mark> contract calls the ZKP verifier contract to verify its validity. It is here

that the verifier determines whether or not the L2 state transitions are valid, which would lead

to the finalization of the L2 blocks on L1.


The current on-chain verifier uses a custom PLONK protocol and the upgrade seeks to replace

this with the FFLONK protocol instead. The trade-off that FFLONK makes is to increase the

number of prover operations in favor of reducing the number of scalar multiplications for the

verifier. As the proving takes place off-chain but the verification takes place on-chain, it is

important to reduce the verifier's work in terms of gas. As of this writing, each scalar

multiplication requires calling the <mark>`ecMul`</mark> precompile, which consumes at least 6000 gas. With

the FFLONK protocol, the number of scalar multiplications done by the verifier is reduced from

16 to 5.


During phase 1, the codebase used powers of a 4-th root of unity for the openings of the

combined polynomials of both the first and the second rounds. The update audited in phase 2

used 3-rd roots of unity for the second round instead. This update further decreases gas costs
##### by reducing the number of openings of C 2 by 2, as well as the number of inverses sent for the

corresponding Lagrange interpolations. During phase 3, the Lagrange inverses were batched

using the Montgomery batched inversion technique, thereby reducing the number of elements

sent by the prover in calldata to 1. Combined with other optimizations, this resulted in further

reducing gas costs.


FFLONK Verifier Audit − System Overview − 7


## **Security Model and Trust** **Assumptions**

As stated earlier, the verifier is called by the <mark>`Executor`</mark> contract to perform validation of the

ZK-SNARK. During phases 1 and 2 of this audit, the <mark>`Executor`</mark> code calling the FFLONK

verifier had not been written. Therefore, those portions of the audit were performed with the

assumption that the new <mark>`Executor`</mark> contract would have validations similar to the one that

was in place. During phase 3 of the audit, the <mark>`Executor`</mark> contract was updated to integrate

with the new verifier. As previously mentioned, the proof verification part of <mark>`Executor`</mark> <mark>,</mark> in

conjunction with the verifier, was then checked for soundness and completeness, assuming all

prior steps had been performed as intended. While the current ZKsync system only allows

privileged addresses to call the external function in <mark>`Executor`</mark> to prove state transitions, the

eventual goal is to decentralize the prover.

##### In addition, the combined preprocessed polynomial C 0 was taken as-is for the purpose of our

audit. As such, the fact that the circuit represented by this commitment is well-implemented is

considered a trust assumption. For the sake of transparency, we recommend that the Matter

Labs team provides code and tools to help anyone who is interested check that the desired
##### circuit is correctly represented by the commitment C 0. In the same vein, it is assumed that the

trusted setup to produce the SRS was done properly and the toxic waste was discarded. We

recommend adding verbiage that makes it clear how this process was performed, along with

checks for the well-formedness of the SRS.

## **Design Considerations and** **Trade-Offs**


As outlined above, there is a trade-off between the prover and verifier work when switching

from PLONK to FFLONK. There is also a trade-off between proof size and verifier work. For

example, if a prover calculates and sends more elements to the verifier, the verifier may only

need to check the validity of these elements instead of computing them for itself. Since the

proof is passed as calldata in the call to the verifier, additional proof elements result in

increased gas costs. However, there is a reduction in the work the verifier has to do to compute


FFLONK Verifier Audit − Security Model and Trust Assumptions − 8


these elements. A concrete example can be found in this codebase, where the Lagrange

inverses are computed and sent to the verifier, which only validates them. This approach offers

significant gas savings compared to having the verifier compute the inverses.


To further improve gas savings, the suggestion was made during phases 1 and 2 to use the

Montgomery batched inversion technique to combine all the inverses into one. In reducing the

number of elements sent in the calldata, the gas cost is reduced further. This was later

implemented and audited in phase 3. A suggestion to switch to 3-rd roots of unity to reduce

gas costs was also implemented and audited in phase 2.


After auditing the codebase over all three phases, the following is an additional suggested

design change that could further reduce the gas costs of the verifier:


   - Besides the inverses of the field elements involved in the computation of Lagrange

polynomial evaluations, there are additional elements whose inverses are still computed
##### by calling the modexp precompile with the R −2 power. Each such call costs ~1400

gas. Consider computing them as part of the Montgomery batched inversion.


FFLONK Verifier Audit − Design Considerations and Trade-Offs − 9


## **Critical Severity**

### **C-01 Lack of Input Validation Allows Proof** **Forgery for Arbitrary Public Inputs - Phase 1**

During the validation of a proof, a transcript is built by appending elements sent by the prover.

This transcript contains the public inputs, the commitments, and the evaluations. When adding

some of these elements to the transcript, for example, the evaluations, the number of

evaluations to be added is <u>[read from a fxed offset of the calldatai](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L184)</u> <u>. Challenges are then</u>

computed by <u>[hashing this transcript.](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L746-L757)</u>


However, the length of the <mark>`evaluations`</mark> array, as read from calldata, is not validated to be

equal to 18. This makes it possible to send an <mark>`evaluations`</mark> array of size 0, followed by an

<mark>`inputs`</mark> array of size 19. The first 17 elements of the <mark>`inputs`</mark> would be the remaining

evaluations, followed by a `1` <u>[(validated](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L213-L215)</u> to be the length of the public input), followed by the

public input itself. The illustration of the layout of the expected calldata versus the forged

calldata is shown below:


In addition, given that the inputs are calldata arrays and are only used in assembly, there is no

implicit abi decoding of these arrays. Thus, they are not validated to be correctly abi encoded.

A second possible attack vector could be the caller sending a sequence of bytes in calldata

with the wrong length for the <mark>`evaluations`</mark> array (an invalid abi encoded array) to control the

number of evaluations added to the transcript. <u>[For example, the length could be set to 0 in the](https://gist.github.com/0xmp/ab40d0924df74de8b7edd407aa3e6fdc)</u>

calldata so that no evaluations are added to the transcript at all.


Since the number of elements added to the transcript depends on the value of the length of

<mark>`evaluations`</mark> <mark>,</mark> in both of the aforementioned scenarios, an attacker would be able to change

the evaluations without affecting the challenges since they are not added to the transcript. It is,


FFLONK Verifier Audit − Critical Severity − 10


in fact, possible to change these evaluations in both of these cases to forge proofs and

successfully pass the pairing check for any public input of the attacker's choosing. This is

done by solving the pairing equation using the evaluations as degrees of freedom. Here is an

example of how such an attack could be carried out:


1. The malicious prover picks a public input. For example, in the case of a ZK rollup, the

public input could correspond to an invalid state transition to drain funds from users.



2. The malicious prover first simulates a SHPLONK PCS opening, following the protocol
##### outlined in Lemma 4.2 of the FFLONK paper, where the polynomials opened are C 0( X ), C 1( X ) = X and C 2( X ) = X . Note that C 0( X ) here is the polynomial committed to in the verification key. The C 1( X ) and C 2( X ) polynomials can be set to arbitrary polynomials for the sake of this PCS, and are set to X for simplicity. The SHPLONK



The malicious prover first simulates a SHPLONK PCS opening, following the protocol


##### outlined in Lemma 4.2 of the FFLONK paper, where the polynomials opened are C 0( X ),


##### and C 2( X ) = X . Note that C 0( X ) here is the polynomial committed to


##### in the verification key. The C 1( X ) and C 2( X ) polynomials can be set to arbitrary


##### polynomials for the sake of this PCS, and are set to X for simplicity. The SHPLONK



protocol is followed honestly.


##### 1. The protocol is adapted so that the challenges, noted and in SHPLONK, are γ z computed exactly the same way as and in the FFLONK verifier. For the sake of α y consistency, we will keep the notation of and for these challenges as we use α y z


##### The protocol is adapted so that the challenges, noted and in SHPLONK, are γ z


##### computed exactly the same way as and in the FFLONK verifier. For the sake of α y


##### consistency, we will keep the notation of and for these challenges as we use α y



for the permutation polynomial.


##### 2. The commitments [ C 0]1, [ C 1 ] 1, [ C 2 ] 1, [ W ] 1, and [ W ′ ]1, as well as the Lagrange interpolation evaluations R 0 := r 0( y ), R 1 := r 1( y ) and R 2 := r 2( y ) computed. The value of the challenges and are also saved to be used later. α y


##### The commitments [ C 0]1, [ C 1 ] 1, [ C 2 ] 1, [ W ] 1, and [ W ′ ]1, as well as the Lagrange


##### interpolation evaluations R 0 := r 0( y ), R 1 := r 1( y ) and R 2 := r 2( y ) are


##### computed. The value of the challenges and are also saved to be used later. α y


##### 3. At the end of the protocol, these values pass the pairing check e ([ C 0]1 +

_<u>Z</u>_ <u>(</u> _<u>y</u>_ <u>)</u> _<u>Z</u>_ <u>(</u> _<u>y</u>_ <u>)</u> _<u>Z</u>_ <u>(</u> _<u>y</u>_ <u>)</u> _<u>Z</u>_ <u>(</u> _<u>y</u>_ <u>)</u>
_<u>T</u>_ <u>∖</u> _<u>S</u>_ <u>1</u> 2 _<u>T</u>_ <u>∖</u> _<u>S</u>_ <u>2</u> _<u>T</u>_ <u>∖</u> _<u>S</u>_ <u>1</u> 2 _<u>T</u>_ <u>∖</u> _<u>S</u>_ <u>2</u>
##### α Z ( y ) [ C 1]1 + α Z ( y ) [ C 2]1 − ( R 0 + α Z ( y ) R 1 + α Z ( y ) R

_T_ ∖ _S_ 0 _T_ ∖ _S_ 0 _T_ ∖ _S_ 0 _T_ ∖ _S_ 0



At the end of the protocol, these values pass the pairing check



_<u>Z</u>_ <u>(</u> _<u>y</u>_ <u>)</u> _<u>Z</u>_ <u>(</u> _<u>y</u>_ <u>)</u> _<u>Z</u>_ <u>(</u> _<u>y</u>_ <u>)</u> _<u>Z</u>_ <u>(</u> _<u>y</u>_ <u>)</u>
_<u>T</u>_ <u>∖</u> _<u>S</u>_ <u>1</u> 2 _<u>T</u>_ <u>∖</u> _<u>S</u>_ <u>2</u> _<u>T</u>_ <u>∖</u> _<u>S</u>_ <u>1</u> 2 _<u>T</u>_ <u>∖</u> _<u>S</u>_ <u>2</u>
##### α Z ( y ) [ C 1]1 + α Z ( y ) [ C 2]1 − ( R 0 + α Z ( y ) R 1 + α Z ( y ) R 2

_T_ ∖ _S_ 0 _T_ ∖ _S_ 0 _T_ ∖ _S_ 0 _T_ ∖ _S_ 0
##### [1]1 − ZZT ( y () y ) [ W ]1 + y [ W ′]1, [1]2) ⋅ e (−[ W ′]1, [ x ]2) = 1.

_T_ ∖ _S_ 0



_<u>Z</u>_ <u>(</u> _<u>y</u>_ <u>)</u> _<u>Z</u>_ <u>(</u> _<u>y</u>_ <u>)</u>
_<u>T</u>_ <u>∖</u> _<u>S</u>_ <u>1</u> 2 _<u>T</u>_ <u>∖</u> _<u>S</u>_ <u>2</u>
##### Z ( y ) [ C 1]1 + α Z ( y ) [ C 2]1 −

_T_ ∖ _S_ 0 _T_ ∖ _S_ 0



_<u>Z</u>_ <u>(</u> _<u>y</u>_ <u>)</u> _<u>Z</u>_ <u>(</u> _<u>y</u>_ <u>)</u>
##### ZT ∖ S 2 ( y ) [ C 2]1 − ( R 0 + α ZT ∖ S 1 ( y ) R 1 +

_T_ ∖ _S_ 0 _T_ ∖ _S_ 0



_<u>Z</u>_ <u>(</u> _<u>y</u>_ <u>)</u> _<u>Z</u>_ <u>(</u> _<u>y</u>_ <u>)</u>
_<u>T</u>_ <u>∖</u> _<u>S</u>_ <u>1</u> 2 _<u>T</u>_ <u>∖</u> _<u>S</u>_ <u>2</u>
##### Z ( y ) R 1 + α Z ( y ) R 2) ⋅

_T_ ∖ _S_ 0 _T_ ∖ _S_ 0


##### ZT ( y () y ) [ W ]1 + y [ W ′]1, [1]2) ⋅ e (−[ W ′]1, [ x ]2) = 1.



3. The malicious prover reuses the same commitments in the FFLONK proof. Denoting

<u><mark>`[REvals](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L66)`</mark></u> as the array computed in the code that contains <u><mark>`[r_0(y)](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L428-L490)`</mark></u> <mark>,</mark> <u><mark>`[r_1(y)](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L495-L527)`</mark></u> and

<u><mark>`[r_2(y)](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L532-L581)`</mark></u> <mark>,</mark> the malicious prover wants to change the evaluations sent in the proof to solve



_<u>Z</u>_ <u>(</u> _<u>y</u>_ <u>)</u>
##### REvals [0] + α ∗ T ∖ S 1 ∗

_Z_ <u>(</u> _y_ <u>)</u>
_T_ ∖ _S_ 0



_<u>Z</u>_ <u>(</u> _<u>y</u>_ <u>)</u>
##### ZT ∖ S 2 ( y ) ∗ R 2



_<u>Z</u>_ <u>(</u> _<u>y</u>_ <u>)</u>
_<u>T</u>_ <u>∖</u> _<u>S</u>_ <u>2</u>



the equation:



_<u>Z</u>_ <u>(</u> _<u>y</u>_ <u>)</u> _<u>Z</u>_ <u>(</u> _<u>y</u>_ <u>)</u>
##### T ∖ S 1 ∗ REvals [1] + α 2 ∗ T ∖ S 2 ∗

_Z_ <u>(</u> _y_ <u>)</u> _Z_ <u>(</u> _y_ <u>)</u>
_T_ ∖ _S_ 0 _T_ ∖ _S_ 0



_<u>Z</u>_ <u>(</u> _<u>y</u>_ <u>)</u> _<u>Z</u>_ <u>(</u> _<u>y</u>_ <u>)</u>
##### ZT ∖ S 1 ( y ) ∗ R 1 + α 2 ∗ ZT ∖ S 2 ( y ) ∗

_T_ ∖ _S_ 0 _T_ ∖ _S_ 0



_<u>Z</u>_ <u>(</u> _<u>y</u>_ <u>)</u>
##### REvals [2] = R 0 + α ∗ ZT ∖ S 1 ( y ) ∗

_T_ ∖ _S_ 0


##### 4. We denote T as the right-hand side of this equation, which the malicious prover can

calculate using the values obtained in the previous steps. We also have that the verifier

computes and/or checks the following constraints, which must be satisfied.

##### 1. T 0( ζ ) ⋅ ZH ( ζ ) = qa ( ζ ) a ( ζ ) + qb ( ζ ) b ( ζ ) + qc ( ζ ) c ( ζ ) + qm ( ζ ) a ( ζ ) b ( ζ ) + qconst ( ζ ) + PI ( ζ ) 2. T 1( ζ ) ⋅ ZH ( ζ ) = z ( ζ )( a ( ζ ) + βζ + γ )( b ( ζ ) + k 1 βζ + γ )( c ( ζ ) + k 2 βζ + γ ) − z ( ζω )( a ( ζ ) + βSσ 1( ζ ) + γ )( b ( ζ ) + βSσ 2( ζ ) + γ )( c ( ζ ) + βSσ 3( ζ ) + γ )


FFLONK Verifier Audit − Critical Severity − 11


##### 3. T 2( ζ ) ⋅ ZH ( ζ ) = L 0( ζ )( z ( ζ ) − 1) 5. Solving the equation can, for example, be done by sending the following evaluations : 1. Set z ( ζ ) = 1, which implies T 2( ζ ) = 0, by constraint iii above.


##### 2. Set z ( ζω ) = 1, Sσ 1( ζ ) = ζ, Sσ 2( ζ ) = k 1 ζ, Sσ 3( ζ ) = k 2 ζ T 1( ζ ) = 0, by constraint ii above.


##### Set z ( ζω ) = 1, Sσ 1( ζ ) = ζ, Sσ 2( ζ ) = k 1 ζ, Sσ 3( ζ ) = k 2 ζ . This implies



, by constraint ii above.


##### 3. Set qconst ( ζ ) = − PI ⋅ L 0( ζ ), a ( ζ ) = b ( ζ ) = c ( ζ ) = 0. This implies T 0( ζ ) = 0.


##### Set qconst ( ζ ) = − PI ⋅ L 0( ζ ), a ( ζ ) = b ( ζ ) = c ( ζ ) = 0. This implies



.



4. Thus, we have


##### 1. ∀ x ∈ S 1 = { h 1, h 1 ω 4, h 1 ω 42, h 1 ω 43}, C 1( x ) = 0. Therefore, REvals [1] = 0


##### 1. ∀ x ∈ S 1 = { h 1, h 1 ω 4, h 1 ω 42, h 1 ω 43}, C 1( x ) = 0 REvals [1] = 0 2. ∀ x ∈ S 2 = { h 2, h 2 ω 4, h 2 ω 42, h 2 ω 43}, C 2( x ) = 1 REvals [2] = ∑3 i =0 L ( iS 2)( y ) + ∑7 j =4 L ( jS 2)( y )



. Therefore,


##### 3 i =0 L ( iS 2)( y ) + ∑7 j =4 L ( jS 2)( y )


##### 7 j =4 L ( jS 2)( y ), noted A


#####, noted A, constant


##### 5. Set T 1( ζω ) = T 2( ζω ) = 0. This implies ∀ x ∈ S 3 = { h 3, h 3 ω 4, h 3 ω 42, h 3 ω 43}, C 2 shifted ( x ) = 1


##### Set T 1( ζω ) = T 2( ζω ) = 0. This implies


##### 6. Given the values of Sσ 1( ζ ), Sσ 2( ζ ), Sσ 3( ζ ) from above, we have that ∀ x ∈ S 0 = { h 0, h 0 ω 8, h 0 ω 82, h 0 ω 83, h 0 ω 84, h 0 ω 85, h 0 ω 86, h 0 ω 87}: C 0( x ) = qa ( ζ ) + xqb ( ζ ) + x 2 qc ( ζ ) + x 3 qm ( ζ ) + x 4 qconst ( ζ ) + x 5 ζ + x 6 k 1 ζ + x 7 k 2 ζ . In our case, qa ( ζ ) = 19 as it is the first value read from the evaluations array.


##### Given the values of Sσ 1( ζ ), Sσ 2( ζ ), Sσ 3( ζ ) from above, we have that



:



. In our


##### case, qa ( ζ ) = 19 as it is the first value read from the evaluations array.


##### 7. Let us set qc ( ζ ) = qm ( ζ ) = 0


##### Let us set qc ( ζ ) = qm ( ζ ) = 0. Then


##### [0] = (∑7 i =0 L ( iS 0)( y ) ⋅ ( h 0 w 8 i )) ⋅ qb ( ζ ) + C = B ⋅ qb ( ζ ) + C

7 ( _S_ 0) 4 4 _i_ 5 5 _i_
##### C := ∑ i =0 Li ( y ) ⋅ (19 + h 0 w 8 (− PI ⋅ L 0( ζ )) + h 0 w 8 ζ +


##### 1. REvals [0] = (∑7 i =0 L ( iS 0)( y ) ⋅



where



7 ( _S_ 0) 4 4 _i_ 5 5 _i_
##### i =0 Li ( y ) ⋅ (19 + h 0 w 8 (− PI ⋅ L 0( ζ )) + h 0 w 8 ζ +


##### h 60 w 86 ik 1 ζ + h 70 w 87 ik 2 ζ ) and where B := ∑7 i =0( h 0 w 8 i ) LSi 0( y )



and where


##### 7 i =0( h 0 w 8 i



_S_ 0
_i_



_<u>Z</u>_ <u>(</u> _<u>y</u>_ <u>)</u>
##### T ∖ S 2 ⋅ A = T

_Z_ <u>(</u> _y_ <u>)</u>



_<u>Z</u>_ <u>(</u> _<u>y</u>_ <u>)</u>
##### 8. The malicious prover then solves B ⋅ qb ( ζ ) + C + α 2 ZT ∖ S 2 ( y ) ⋅

_T_ ∖ _S_ 0


##### The malicious prover then solves B ⋅ qb ( ζ ) + C + α 2 ZT ∖ S 2 ( y ) ⋅ A = T . It is



_ZT_ <u>∖</u> _<u>S</u>_ <u>2</u> ( _y_ )


##### qb ( ζ ) = ZT ∖ BS



solved by setting



_Z_ ( _y_ )

_T_ - _α_ 2 _ZTT_ <u>∖∖</u> _<u>SS</u>_ <u>20</u> ( _y_ ) _A_ - _C_


##### 6. The malicious prover sends the commitments [ C 0]1, [ C 1 ] 1, [ C 2 ] 1, [ W ] 1, [ W ′] 1


##### The malicious prover sends the commitments [ C 0]1, [ C 1 ] 1, [ C 2 ] 1, [ W ] 1, [ W ′] 1 and all



the evaluations described above as part of the proof.

7. Because changing the evaluations did not change the challenges, the FFLONK pairing

check is exactly the same as the one done in SHPLONK in step 2. Thus, the pairing

check passes for this malicious public input, chosen by the prover.


If a ZK rollup relied on this verifier for its state transition and did not perform the checks

previously mentioned, it would be possible to forge proofs and drain the rollup. Importantly, we

note that as this audit was focused only on the verifier itself, we did not have access to the

code that calls the verifier. It is, therefore, possible that checks identified as missing in this

issue were in fact assumed to be made by the caller. However, upon reviewing the current

contract calling the <mark>`verify`</mark> function, these checks are not performed by the caller.


FFLONK Verifier Audit − Critical Severity − 12


Consider adding checks which ensure that the input arrays are correctly abi encoded and that

their lengths match what is expected. We recommend using fixed-sized arrays as inputs. This

would natively protect against size mismatches while also saving gas by not sending the

offsets and lengths associated with dynamic types in calldata (~1200 gas). If such checks are

expected to be made in the caller of the <mark>`verify`</mark> function, consider documenting this

assumption in the verifier. As a general strategy against this kind of attack, we recommend

ensuring that the transcript always contains everything, especially when the prover could be

adversarial.


**_Update:_** _Resolved in_ _<u>[pull request #3](https://github.com/matter-labs/fflonk-verifier/pull/3)</u>_ _at commit_ _<u>[9a89ab8. The team stated:](https://github.com/matter-labs/fflonk-verifier/pull/3/commits/9a89ab86acbde4f4602519b844fbf2ca157b6682)</u>_


_The implementation now works with fixed-size arrays._

## **Medium Severity**

### **M-01 Missing Proof Validation - Phase 1**


The <u><mark>`[Verify](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L100)`</mark></u> <u>function</u> does not validate the following:


   - Whether the polynomial openings are valid field elements

   - Whether the public witness values are valid field elements

   - Whether the proof commitments are valid elliptic curve points

  - Whether the proof commitments are on the correct subgroup


The codebase assumes the use of the BN254 curve which <u>[does not have non-trivial proper](https://hackmd.io/@jpw/bn254#Subgroup-check-for-mathbb-G_1)</u>

<u>[subgroups. Therefore, if only BN254 support is intended, checking whether the proof](https://hackmd.io/@jpw/bn254#Subgroup-check-for-mathbb-G_1)</u>

commitments are valid elliptic curve points will suffice, and it is not necessary to also check

that they are on the correct subgroup. The check in bullet point 4 above can thus be skipped if

is it the only supported curve. In addition to the check for bullet point 3, we also recommend

the first two validations listed above, in order to future-proof the verifier.


Please note that dependence on precompiles to perform these checks would not always be

effective. For example, the code for <u><mark>`[point_add](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L777-L812)`</mark></u> circumvents this call to the precompile at

times when <mark>`matched`</mark> is set to 1.


While the Fflonk paper does not explicitly mention these checks as it simply describes its novel

contribution on top of Plonk, these checks are mentioned explicitly in the <u>[Plonk paper. In the](https://eprint.iacr.org/2019/953.pdf)</u>


FFLONK Verifier Audit − Medium Severity − 13


interest of reducing the attack surface and increasing compliance with the Plonk specification,

consider introducing these checks.


**_Update:_** _Resolved in_ _<u>[pull request #3](https://github.com/matter-labs/fflonk-verifier/pull/3)</u>_ _at commit_ _<u>[d7b8335. The team stated:](https://github.com/matter-labs/fflonk-verifier/pull/3/commits/d7b8335245b30a5694ba815da4c287494cc24073)</u>_


_The validations are now added._

## **Low Severity**

### **L-01 Incorrect Bound Check in Lagrange** **Polynomial Evaluations - Phase 1**


The <mark>`precompute_lagrange_basis_evaluations_from_inverses_for_union_set`</mark>


##### function computes the Lagrange polynomial evaluations L ( iS 2)( y ), where S 2 = { h 2, h 2 ω 4, h 2 ω 42, h 2 ω 43} ∪ { h 3, h 3 ω 4, h 3 ω 42, h 3 ω 43}. This function does a


##### function computes the Lagrange polynomial evaluations L ( iS 2)( y ), where



. This function does a <u>[bound check](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L299-L301)</u> to



validate that it does not read past the end of the <mark>`lagrange_basis_inverses`</mark> array.


However, this check is inaccurate as it does not account for the union set. In practice, it checks

that <mark>`start + num_polys = 16 <= lagrange_basis_inverses.length`</mark> <mark>,</mark> but the

function reads up to index <u><mark>`[start + 2 * num_polys - 1 = 19](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L369C91-L369C120)`</mark></u> <mark>.</mark>


Consider modifying the bound check to validate that <mark>`start + 2 * num_polys <=`</mark>

<mark>`lagrange_basis_inverses.length`</mark> <mark>.</mark>


**_Update:_** _Resolved in_ _<u>[pull request #3](https://github.com/matter-labs/fflonk-verifier/pull/3)</u>_ _at commit_ _<u>[9ddb5d3. The team stated:](https://github.com/matter-labs/fflonk-verifier/pull/3/commits/9ddb5d32468272870986b6e0fba5dc757edd3445)</u>_


_The bound check has now been fixed_

### **L-02 Two Representations of the Point-At-Infinity** **- Phase 1**


In the <mark>`point_mul`</mark> function, there is an <mark>`if`</mark> block that <u>[sets the point (0, 1) to the value (0, 0).](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L761-L763)</u>

Therefore, there are two representations of the point-at-infinity when calling this function, (0, 1)

and (0, 0). While not necessarily a practical issue currently, this inconsistency in representation

increases the attack surface for a malicious prover who now has two options to represent this

point. Furthermore, this inconsistency could lead to more serious vulnerabilities down the road

when the code is refactored or if additional calling functions are created.


FFLONK Verifier Audit − Low Severity − 14


Consider removing this <mark>`if`</mark> block and making (0, 0) the only valid representation of the point
at-infinity.


**_Update:_** _Resolved in_ _<u>[pull request #3](https://github.com/matter-labs/fflonk-verifier/pull/3)</u>_ _at commit_ _<u>[4f2e2f1. The team stated:](https://github.com/matter-labs/fflonk-verifier/pull/3/commits/4f2e2f15cd151f979187f92ecfbeed835c712b36)</u>_


_The_ _<mark>`point_mul`</mark>_ _has now been corrected to have only one representation of point-at-_

_infinity (0,0)._

### **L-03 Missing Docstrings - Phase 1**


In the <mark>`FflonkYul`</mark> contract, multiple instances of missing docstrings were identified:


   - The <u><mark>`[verify](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L100-L871)`</mark></u> <u>function</u> should document the structure of the inputs and any assumptions

related to the checks made by the caller.

   - The core functions <u><mark>`[check_main_gate_identity](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L208)`</mark></u> <mark>,</mark>

<u><mark>`[precompute_lagrange_basis_evaluations_from_inverses](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L258)`</mark></u> <mark>,</mark>

<u><mark>`[precompute_lagrange_basis_evaluations_from_inverses_for_union_set](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L298)`</mark></u> <mark>,</mark>

<u><mark>`[compute_opening_points](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L385)`</mark></u> <mark>,</mark> and <u><mark>`[evaluate_r_polys_at_point_unrolled](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L421)`</mark></u>

should be documented.

   - The helper functions <u><mark>`[update_transcript](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L727)`</mark></u> <mark>,</mark> <u><mark>`[get_challenge](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L746)`</mark></u> <mark>,</mark> <u><mark>`[point_mul](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L760)`</mark></u>,

<u><mark>`[point_add](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L777)`</mark></u> <mark>,</mark> <u><mark>`[pairing_check](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L814)`</mark></u> <mark>,</mark> and <u><mark>`[revertWithMessage](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L842)`</mark></u> functions should be

documented.


Consider thoroughly documenting all functions (and their parameters) that are part of any

contract's public API. Functions implementing sensitive functionality, even if not public, should

be clearly documented as well. When writing docstrings, consider following the <u>[Ethereum](https://solidity.readthedocs.io/en/latest/natspec-format.html)</u>

<u>[Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html)</u> (NatSpec).


**_Update:_** _Resolved in_ _<u>[pull request #3](https://github.com/matter-labs/fflonk-verifier/pull/3)</u>_ _at commit_ _<u>[8ced28d. The team stated:](https://github.com/matter-labs/fflonk-verifier/pull/3/commits/8ced28df3ad918fb0e82f89b023dd322a8f12618)</u>_


_The functions have now been documented with the necessary details._

### **L-04 Brittle Use of Free Memory Pointer - Phase 1**


The <u><mark>`[point_mul](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L760-L775)`</mark></u> <mark>,</mark> <u><mark>`[point_add](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L777-L794)`</mark></u> <mark>,</mark> and <u><mark>`[pairing_check](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L814-L840)`</mark></u> functions do not return their result.

Instead, they leave it at the location of the free memory pointer, relying on the calling function

to obtain the resulting value from that memory location. This lack of an explicit return results in

brittle code that can be broken in a future refactoring of the calling function. Furthermore, for

<mark>`point_mul`</mark> and <mark>`point_add`</mark> <mark>,</mark> the resulting elliptic curve point is represented by two words of


FFLONK Verifier Audit − Low Severity − 15


memory, thereby making this connection even more tenuous. If the calling function overwrites

these memory locations with other values, errors could be introduced into the codebase.


To make the code more robust, consider explicitly returning the output of the aforementioned

functions using return variables in assembly.


**_Update:_** _Resolved in_ _<u>[pull request #3](https://github.com/matter-labs/fflonk-verifier/pull/3)</u>_ _at commit_ _<u>[c21ab95](https://github.com/matter-labs/fflonk-verifier/pull/3/commits/c21ab9590ee8132b2ff40ad274842e65d3dee86d)</u>_ _and at commit_ _<u>[3c09dfd. The team](https://github.com/matter-labs/fflonk-verifier/pull/3/commits/3c09dfd93ff1f5fb8dc25cb0872755782561af59)</u>_

_stated:_


_The concerned functions now return values instead of storing them at the free memory_

_pointer._

### **L-05 Misleading Documentation - Phase 1**


Throughout the <mark>`FflonkYul.sol`</mark> file, multiple instances of misleading comments were

identified:


   - When updating the transcript, the <u>[comment in line 175](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L175)</u> says, "commit third round

commitment: copy-perm and lookup". However, the current codebase does not use

lookup tables.

   - The <u>[comment in line 190](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L190)</u> of the code was commented out and could be removed.

   - The <u>[denominator in the comment in line 302](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L302C29-L302C55)</u> should be in parenthesis to clarify the

precedence of the operations.

   - The point at which the vanishing polynomial is evaluated in <mark>`W'`</mark> is indicated as <u>`[x](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L631C23-L631C24)`</u>

whereas it should be `y` . Similarly, there are <u>[other instances](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L694)</u> of the incorrect use of `x`

instead of `y` .

   - The <u>[comment in line 660](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L660)</u> should say <mark>`(alpha^2*Z_{T\S2}(y)/Z_{T\S0}(y)) * C2`</mark>

and a comment should be inserted before line 664 <mark>`C0 + (alpha^2*Z_{T\S2}(y)/`</mark>

<mark>`Z_{T\S0}(y)) * C2`</mark> <mark>.</mark> Similarly, the <u>[comment in line 667](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L667)</u> should say

<mark>`(alpha^2*Z_{T\S2}(y)/Z_{T\S0}(y)) * r2`</mark> <mark>.</mark>

   - The <u>[comment on line 674](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L674)</u> should say <mark>`(alpha*Z_{T\S1}(y)/Z_{T\S0}(y)) * C1`</mark>

and a comment should be inserted before line 678 <mark>`C0 + (alpha*Z_{T\S1}(y)/`</mark>

<mark>`Z_{T\S0}(y)) * C1 + (alpha^2*Z_{T\S2}(y)/Z_{T\S0}(y)) * C2`</mark> <mark>.</mark> Similarly,

the <u>[comment on line 682](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L682)</u> should say <mark>`(alpha*Z_{T\S1}(y)/Z_{T\S0}(y)) * r1 +`</mark>

<mark>`(alpha^2*Z_{T\S2}(y)/Z_{T\S0}(y)) * r2`</mark> <mark>.</mark>

   - The <u>[comment on line 685](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L685)</u> should say <mark>`r0 + (alpha*Z_{T\S1}(y)/Z_{T\S0}(y)) *`</mark>

<mark>`r1 + (alpha^2*Z_{T\S2}(y)/Z_{T\S0}(y)) * r2`</mark> <mark>.</mark>


FFLONK Verifier Audit − Low Severity − 16


Consider revising the aforementioned comments to improve consistency and more accurately

reflect the implemented logic. This will make it easier for auditors and other parties examining

the code to understand what each section of the code is designed to do.


**_Update:_** _Resolved in_ _<u>[pull request #3](https://github.com/matter-labs/fflonk-verifier/pull/3)</u>_ _at commit_ _<u>[343d11c](https://github.com/matter-labs/fflonk-verifier/pull/3/commits/343d11c5c05e46fe3419ef6ba6b73ba30af1f426)</u>_ _and at commit_ _<u>[3c09dfd. The team](https://github.com/matter-labs/fflonk-verifier/pull/3/commits/3c09dfd93ff1f5fb8dc25cb0872755782561af59)</u>_

_stated:_


_The comments are now fixed._

### **L-06 Lack of Validation of Proof Size - Phase 3**


The <u><mark>`[verify](https://github.com/matter-labs/fflonk-verifier/blob/c9e99a8760774fcc45df110fddd954246feac00c/solidity/fflonk-foundry/src/FflonkYul.sol#L156)`</mark></u> function of the <mark>`FflonkYul`</mark> contract expects a <mark>`_proof`</mark> argument with 24

elements. However, the length of <mark>`_proof`</mark> is currently not validated. If the proof is too short,

missing evaluations will be filled with 0s instead of reverting. If the proof is too long, additional

elements will be ignored. While we did not find any concrete security risk associated with this

behavior, passing a short proof currently reverts later on in the execution with an unclear

<u>["Precompute Eval. Error [PALBE]" error, whereas passing a long proof does not necessarily](https://github.com/matter-labs/fflonk-verifier/blob/c9e99a8760774fcc45df110fddd954246feac00c/solidity/fflonk-foundry/src/FflonkYul.sol#L550-L552)</u>

revert. A mismatch in proof size could potentially happen during the migration from the PLONK

to the FFLONK verifier.


Consider adding validation for the length of the proof in order to reduce the attack surface and

facilitate debugging in case of proof length mismatch.


**_Update:_** _Resolved in_ _<u>[pull request #5](https://github.com/matter-labs/fflonk-verifier/pull/5)</u>_ _at commit_ _<u>[85ce7df. The Matter Labs team stated:](https://github.com/matter-labs/fflonk-verifier/pull/5/commits/85ce7df6f2be6901ef7d022c80db96c694d997c3)</u>_


_The length check for the proof has now been integrated._

## **Notes & Additional** **Information**

### **N-01 Some Memory Variables Could Be** **Constants – Phase 2**


The variables defined in the <u>[verifcation keyi](https://github.com/matter-labs/fflonk-verifier/blob/3c09dfd93ff1f5fb8dc25cb0872755782561af59/solidity/fflonk-foundry/src/FflonkYul.sol#L137-L155)</u> <u>, as well as some transcript elements such as</u> <u>[the](https://github.com/matter-labs/fflonk-verifier/blob/3c09dfd93ff1f5fb8dc25cb0872755782561af59/solidity/fflonk-foundry/src/FflonkYul.sol#L200-L205)</u>

<u>[domain size, the number one, and omega, could be defined as constants instead of being](https://github.com/matter-labs/fflonk-verifier/blob/3c09dfd93ff1f5fb8dc25cb0872755782561af59/solidity/fflonk-foundry/src/FflonkYul.sol#L200-L205)</u>


FFLONK Verifier Audit − Notes & Additional Information − 17


stored in memory. This would clarify the fact that they are indeed constants, as well as save a

bit of gas during execution.


Consider defining the variables mentioned above as constants.


**_Update:_** _Resolved in_ _<u>[pull request #5](https://github.com/matter-labs/fflonk-verifier/pull/5)</u>_ _at commit_ _<u>[620ac25. The Matter Labs team stated:](https://github.com/matter-labs/fflonk-verifier/pull/5/commits/620ac25e47d230aa7550004ad7de80cbe215c054)</u>_


_The variables are now made constants, and the necessary changes are reflected in the_

_code._

### **N-02 Lack of SPDX License Identifier - Phase 1**


The <u><mark>`[FflonkYul.sol](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol)`</mark></u> file lacks an SPDX license identifier.


To avoid legal issues regarding copyright and to follow the best practices, consider adding

SPDX license identifiers to files as suggested by the <u>[Solidity documentation.](https://docs.soliditylang.org/en/latest/layout-of-source-files.html#spdx-license-identifier)</u>


**_Update:_** _Resolved in_ _<u>[pull request #3](https://github.com/matter-labs/fflonk-verifier/pull/3)</u>_ _at commit_ _<u>[2726bc8. The team stated:](https://github.com/matter-labs/fflonk-verifier/pull/3/commits/2726bc812356565a079e2f82b8c52aa457298a45)</u>_


_The license has now been added._

### **N-03 Lack of Security Contact - Phase 1**


Providing a specific security contact (such as an email or ENS name) within a smart contract

significantly simplifies the process for individuals to communicate if they identify a vulnerability

in the code. This practice is beneficial as it permits the code owners to dictate the

communication channel for vulnerability disclosure, eliminating the risk of miscommunication

or failure to report due to a lack of knowledge on how to do so.


The <u><mark>`[FflonkYul](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol)`</mark></u> <u>contract</u> does not have a security contact.


Consider adding a NatSpec comment containing a security contact to the contract definition.

Using the <mark>`@custom:security-contact`</mark> convention is recommended as it has been

adopted by the <u>[OpenZeppelin Wizard](https://wizard.openzeppelin.com/)</u> and the <u>[ethereum-lists.](https://github.com/ethereum-lists/contracts#tracking-new-deployments)</u>


**_Update:_** _Resolved in_ _<u>[pull request #3](https://github.com/matter-labs/fflonk-verifier/pull/3)</u>_ _at commit_ _<u>[2726bc8. The team stated:](https://github.com/matter-labs/fflonk-verifier/pull/3/commits/2726bc812356565a079e2f82b8c52aa457298a45)</u>_


_The Security Contact has now been added with the recommended NatSpec convention._


FFLONK Verifier Audit − Notes & Additional Information − 18


### **N-04 State Variable Visibility Not Explicitly** **Declared - Phase 1**

Within <u><mark>`[FflonkYul.sol](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol)`</mark></u> <mark>,</mark> there are state variables that lack an explicitly declared visibility:


   - The <u><mark>`[DST_0](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L6)`</mark></u> <u>[state variable](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L6)</u>

   - The <u><mark>`[DST_1](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L7)`</mark></u> <u>[state variable](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L7)</u>

   - The <u><mark>`[DST_CHALLENGE](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L8)`</mark></u> <u>state variable</u>

   - The <u><mark>`[FR_MASK](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L9)`</mark></u> <u>[state variable](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L9)</u>

   - The <u><mark>`[Q_MOD](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L10)`</mark></u> <u>[state variable](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L10)</u>

   - The <u><mark>`[R_MOD](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L11)`</mark></u> <u>[state variable](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L11)</u>

   - The <u><mark>`[NUM_ALL_POLYS](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L12)`</mark></u> <u>state variable</u>


For improved code clarity, consider always explicitly declaring the visibility of variables, even

when the default visibility matches the intended visibility. Note that if these variables are

declared to be <mark>`internal`</mark> <mark>,</mark> they would not increase the gas costs of the verifier. However, if

these variables are declared to be <mark>`public`</mark> <mark>,</mark> they would increase both the deployment and

runtime gas costs.


**_Update:_** _Resolved in_ _<u>[pull request #3](https://github.com/matter-labs/fflonk-verifier/pull/3)</u>_ _at commit_ _<u>[2726bc8. The team stated:](https://github.com/matter-labs/fflonk-verifier/pull/3/commits/2726bc812356565a079e2f82b8c52aa457298a45)</u>_


_The concerned variables now explicitly define the visibility._

### **N-05 The Codebase Cannot Be Compiled With** **the Default Settings - Phase 1**


The <mark>`FflonkYul`</mark> contract has a <u>[pragma](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L1)</u> to be compiled with Solidity version <mark>`0.8.24`</mark> <mark>.</mark>

However, the Foundry config of the project sets the solc version to <u><mark>`[0.8.25](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/foundry.toml#L14)`</mark></u> which is

inconsistent and prevents the contract from being compiled. In addition, the

<mark>`FflonkYul.t.sol`</mark> test imports <mark>`FflonkYul`</mark> from <u><mark>`["../src/fflonk/FflonkYul.sol"](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/test/FflonkYul.t.sol#L3)`</mark></u>

which does not exist. The correct path should be <mark>`"../src/FflonkYul.sol"`</mark> <mark>.</mark>


Consider addressing the above issues to prevent the code from not compiling.


**_Update:_** _Resolved in_ _<u>[pull request #3](https://github.com/matter-labs/fflonk-verifier/pull/3)</u>_ _at commit_ _<u>[2726bc8. The team stated:](https://github.com/matter-labs/fflonk-verifier/pull/3/commits/2726bc812356565a079e2f82b8c52aa457298a45)</u>_


_The imports and solidity versions have now been fixed as per the project configurations._


FFLONK Verifier Audit − Notes & Additional Information − 19


### **N-06 Invalid Reverts - Phase 1**

The code defines a <u><mark>`[revertWithMessage](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L842-L854)`</mark></u> function. This function can be called with a length

and a string as arguments to revert with an <mark>`Error(string)`</mark> error. However, some parts of

the code use the assembly <u><mark>`[revert](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L154)`</mark></u> despite being passed the same arguments (a length and a

string message) as if the <mark>`revertWithMessage`</mark> function had been called instead. Yet, the Yul

<mark>`revert`</mark> function expects a memory pointer and a length as parameters. This mismatch would

cause the reverts to fail as the string is mistakenly interpreted as the length.


In addition, some of the lengths given for the error messages are inaccurate:


   - The length of <u>[this error](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L716)</u> is 21, not 22.

   - Similarly, the length of <u>[this error](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L836)</u> is 20, not 21.


Consider addressing the aforementioned issues to improve the ability of callers to successfully

debug potential reverts.


**_Update:_** _Resolved in_ _<u>[pull request #3](https://github.com/matter-labs/fflonk-verifier/pull/3)</u>_ _at commit_ _<u>[2346c17. The team stated:](https://github.com/matter-labs/fflonk-verifier/pull/3/commits/2346c17a8c46278496a323b632d77852c5722a52)</u>_


_The revert function has been corrected with the right lengths for the error strings._

### **N-07 Code Quality and Readability Suggestions -** **Phase 1**


Throughout the <mark>`FflonkYul.sol`</mark> file, multiple code quality and readability issues were

identified:


   - The <u>inputs to the</u> <u><mark>`[verify](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L101-L104)`</mark></u> <u>function</u> are defined as <mark>`uint`</mark> <mark>.</mark> Consider explicitly defining

them as <mark>`uint256`</mark> <mark>.</mark>




[• There are multiple instances of numbers being hardcoded in the code. For example,](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L380)
##### corresponding to ω 8, ω 4, as well as powers of roots of unity (e.g., ω 8 2



[There are multiple instances of numbers being hardcoded in the code. For example,](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L380)



<u>[2](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L443)</u>


##### corresponding to ω 8, ω 4, as well as powers of roots of unity (e.g., ω 8 2). Consider either

defining these numbers as constants or adding comments if defining new constants is

not desired.




- The <u><mark>`[verify](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L100-L105)`</mark></u> function could be defined as <mark>`view`</mark> to improve code clarity.

- The ">" operator should be replaced with ">=" in error messages associated with checks

which ensure that field values are <mark>`< R_MOD`</mark> <u>[[1]](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L154)</u> <u>[[2]. This will help make the error](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L159)</u>

messages more accurate.

- Similarly, the number of inputs is checked to be equal to 1. Otherwise, the code reverts

with "Inputs should be atmost 1" <u>[[1]](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L110)</u> <u>[[2]. Consider changing the error message to be](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L214)</u>

more explicit (e.g., "Inputs length should be 1").


FFLONK Verifier Audit − Notes & Additional Information − 20


   - The naming convention of variables in the <mark>`update_transcript`</mark> function is

inconsistent, mixing both camel and snake case. Consider rewriting the <u><mark>`[newState0](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L737C17-L737C26)`</mark></u>

and <u><mark>`[newState1](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L742)`</mark></u> variables in snake case for consistency.

   - The <u><mark>`[NUM_ALL_POLYS](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L12)`</mark></u> constant is unused and could be removed.


Consider making the changes outlined above to improve code quality and readability for

auditors, code maintainers, and developers.


**_Update:_** _Resolved in_ _<u>[pull request #3](https://github.com/matter-labs/fflonk-verifier/pull/3)</u>_ _at commit_ _<u>[22be764. The team stated:](https://github.com/matter-labs/fflonk-verifier/pull/3/commits/22be7640d6c76c489ec325c38198b319d63181d5)</u>_


_The suggestions have been acknowledged and implemented_

### **N-08 Gas Optimizations - Phase 1**


Throughout the audited code, multiple opportunities for gas optimizations were identified:

##### • The proof currently contains three extra openings: T 0( z ), T 1( z ), and T 2( z ). These

openings are currently validated by checking that they match what is recomputed by the

verifier <u>[[1]](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L222-L224)</u> <u>[[2]](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L245-L247)</u> <u>[[3]. As these values are recomputed anyway, there always exists a unique](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L253-L255)</u>

value that the prover can send for these and sending them in calldata costs an extra

~1500 gas. As such, they could be removed from the proof to save gas. Note that the

<u>[FFLONK specifications](https://eprint.iacr.org/2021/1167.pdf)</u> do not send these openings, as only 15 field elements are sent.




- <mark>`OPS_Y_POWS`</mark> stores <u>[17 values, ranging from](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L56)</u> <mark>`y^0`</mark> to <mark>`y^16`</mark> <mark>.</mark> These values are



computed and saved in memory inside the <u><mark>`[initialize_opening_state](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L408-L412)`</mark></u> <u>function.</u>

However, not all of these values are used. While some powers less than 8 remain unused

throughout the protocol, notably, all powers of `y` exceeding 8 are not used at all.

   - Each addition to the transcript <u>[computes](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L727-L744)</u> two rolling hashes and stores them in memory.

Unless there is a strong cryptographic argument to do so, consider maintaining a single

rolling hash instead of two in order to save gas.

   - Length of loops loaded from calldata or computed with <mark>`add`</mark> or <mark>`sub`</mark> could be loaded

once and stored on the stack. For example, these lengths <u>[[1]](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L141C33-L141C86)</u> <u>[[2]](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L307C34-L307C50)</u> <u>[[3]](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L329C34-L329C50)</u> could be stored on

the stack to save gas.

   - The <u><mark>`[compute_opening_points](https://github.com/matter-labs/fflonk-verifier/blob/3881e1839a3ecab8ba2159cb5113ffcc1b523e69/solidity/fflonk-foundry/src/FflonkYul.sol#L385-L403)`</mark></u> function could be optimized to remove the loops by

storing <mark>`mload(PVS_R)`</mark> on the stack and computing the other elements with it.


Consider addressing the above instances to save gas.


**_Update:_** _Resolved in_ _<u>[pull request #3](https://github.com/matter-labs/fflonk-verifier/pull/3)</u>_ _at commit_ _<u>[cbf09ba](https://github.com/matter-labs/fflonk-verifier/pull/3/commits/cbf09ba7a46acb4039a672d057e09cad84f6561d)</u>_ _and at commit_ _<u>[3c09dfd. The team](https://github.com/matter-labs/fflonk-verifier/pull/3/commits/3c09dfd93ff1f5fb8dc25cb0872755782561af59)</u>_

_stated:_


_The optimizations have now been addressed._


FFLONK Verifier Audit − Notes & Additional Information − 21


### **N-09 Overwriting of the Free Memory Pointer -** **Phase 3**

The <u><mark>`[point_mul](https://github.com/matter-labs/fflonk-verifier/blob/c9e99a8760774fcc45df110fddd954246feac00c/solidity/fflonk-foundry/src/FflonkYul.sol#L917)`</mark></u> <mark>,</mark> <u><mark>`[point_add](https://github.com/matter-labs/fflonk-verifier/blob/c9e99a8760774fcc45df110fddd954246feac00c/solidity/fflonk-foundry/src/FflonkYul.sol#L931)`</mark></u> <mark>,</mark> <u><mark>`[point_sub](https://github.com/matter-labs/fflonk-verifier/blob/c9e99a8760774fcc45df110fddd954246feac00c/solidity/fflonk-foundry/src/FflonkYul.sol#L947)`</mark></u> <mark>,</mark> <u><mark>`[pairing_check](https://github.com/matter-labs/fflonk-verifier/blob/c9e99a8760774fcc45df110fddd954246feac00c/solidity/fflonk-foundry/src/FflonkYul.sol#L966)`</mark></u> <mark>,</mark> and <u><mark>`[modexp](https://github.com/matter-labs/fflonk-verifier/blob/c9e99a8760774fcc45df110fddd954246feac00c/solidity/fflonk-foundry/src/FflonkYul.sol#L1006)`</mark></u> functions

overwrite the free memory pointer location at <mark>`0x40`</mark> <mark>.</mark> In addition, all of these functions except

for <mark>`point_mul`</mark> also overwrite the zero slot at <mark>`0x60`</mark> <mark>.</mark> According to the <u>[Solidity](https://docs.soliditylang.org/en/latest/internals/layout_in_memory.html)</u>

<u>[documentation, the free memory pointer points to](https://docs.soliditylang.org/en/latest/internals/layout_in_memory.html)</u> <mark>`0x80`</mark> initially to avoid overwriting these

designated slots.


The free memory pointer currently remains unused in the codebase as elements are written to

memory using the <u>[locations defned by the constantsi](https://github.com/matter-labs/fflonk-verifier/blob/c9e99a8760774fcc45df110fddd954246feac00c/solidity/fflonk-foundry/src/FflonkYul.sol#L24-L98)</u> at the beginning of <mark>`FflonkYul`</mark> <mark>.</mark>

However, leaving such memory slots dirty introduces a risk in case of code reformatting or if

these generic functions using elliptic curve points and field elements were to be copied to

other files.


Consider storing values starting at memory location <mark>`0x80`</mark> for the aforementioned functions,

while keeping in mind not to overwrite the <u>[first constant-defined memory location. Currently,](https://github.com/matter-labs/fflonk-verifier/blob/c9e99a8760774fcc45df110fddd954246feac00c/solidity/fflonk-foundry/src/FflonkYul.sol#L24)</u>

starting at memory location <mark>`0x80`</mark> should not cause any overwriting, but this should be a

consideration for any future refactoring of the code. Alternatively, consider documenting these

functions more thoroughly, warning developers that these functions do indeed overwrite the

free memory pointer and possibly the zero slot as well.


**_Update:_** _Resolved in_ _<u>[pull request #5](https://github.com/matter-labs/fflonk-verifier/pull/5)</u>_ _at commit_ _<u>[8aaf8b7. The Matter Labs team stated:](https://github.com/matter-labs/fflonk-verifier/tree/8aaf8b789ef49b900b4fb1079042c6e016e43bcd)</u>_


_The concerned functions now store values starting from 0x80, and a comment has been_

_added._

### **N-10 Use of Magic Number - Phase 3**


The domain size, <mark>`8388608`</mark> <mark>,</mark> is hardcoded as a magic number in <u>[line 253, line 300, and](https://github.com/matter-labs/fflonk-verifier/blob/c9e99a8760774fcc45df110fddd954246feac00c/solidity/fflonk-foundry/src/FflonkYul.sol#L253)</u> <u>[line](https://github.com/matter-labs/fflonk-verifier/blob/c9e99a8760774fcc45df110fddd954246feac00c/solidity/fflonk-foundry/src/FflonkYul.sol#L302)</u>

<u>[302.](https://github.com/matter-labs/fflonk-verifier/blob/c9e99a8760774fcc45df110fddd954246feac00c/solidity/fflonk-foundry/src/FflonkYul.sol#L302)</u>


In order to future-proof this codebase and prevent a scenario during refactoring where only

some of these values are updated but not others, consider defining a constant called

<mark>`DOMAIN_SIZE`</mark> and using this constant throughout the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #5](https://github.com/matter-labs/fflonk-verifier/pull/5)</u>_ _at commit_ _<u>[19ca355. The Matter Labs team stated:](https://github.com/matter-labs/fflonk-verifier/pull/5/commits/19ca3553369027c71eb512686e9bd2903830a10c)</u>_


_The DOMAIN_SIZE is now a constant._


FFLONK Verifier Audit − Notes & Additional Information − 22


### **N-11 Inconsistent Representation of Hex Values -** **Phase 3**

Throughout the <mark>`FflonkYul.sol`</mark> file, the hex values are sometimes represented with 2 digits

and at other times with 3 digits, even when one of the digits is superfluous. One example of

this is in <u>[line 189, where both](https://github.com/matter-labs/fflonk-verifier/blob/c9e99a8760774fcc45df110fddd954246feac00c/solidity/fflonk-foundry/src/FflonkYul.sol#L189)</u> <mark>`0x24`</mark> and <mark>`0x024`</mark> are used.


Consider standardizing the representation of hex values to improve the consistency of the

codebase.


**_Update:_** _Resolved in_ _<u>[pull request #5](https://github.com/matter-labs/fflonk-verifier/pull/5)</u>_ _at commit_ _<u>[19ca355. The Matter Labs team stated:](https://github.com/matter-labs/fflonk-verifier/pull/5/commits/19ca3553369027c71eb512686e9bd2903830a10c)</u>_


_The hex representations are now made consistent._

### **N-12 Missing or Misleading Documentation -** **Phase 3**


Throughout <mark>`FflonkYul.sol`</mark> <mark>,</mark> multiple instances of missing or misleading comments were

identified:


   - The <u>[comment in line 905, which states "Generates a new challenge with (uint32(2) ||](https://github.com/matter-labs/fflonk-verifier/blob/c9e99a8760774fcc45df110fddd954246feac00c/solidity/fflonk-foundry/src/FflonkYul.sol#L902)</u>

state_0 || state_1 || challenge_counter)" could be updated to "Generates a new challenge

with (uint32(2) || state_0 || state_1 || uint32(challenge_counter))" to reflect the type of the

challenge counter.

   - The name of the <u>constant</u> <u><mark>`[MEM_PROOF_LAGRANGE_BASIS_INVERSES](https://github.com/matter-labs/fflonk-verifier/blob/c9e99a8760774fcc45df110fddd954246feac00c/solidity/fflonk-foundry/src/FflonkYul.sol#L98)`</mark></u> could be

updated to <mark>`MEM_PROOF_LAGRANGE_BASIS_NUMERATORS`</mark> or

<mark>`MEM_PROOF_LAGRANGE_BASIS`</mark> as these memory locations are first used to store the

numerators and later on to store the Lagrange basis, but are not used to store the

inverses.

   - The <u>[first comment](https://github.com/matter-labs/fflonk-verifier/blob/c9e99a8760774fcc45df110fddd954246feac00c/solidity/fflonk-foundry/src/FflonkYul.sol#L391C20-L391C21)</u> in the loop of the

<mark>`precompute_partial_lagrange_basis_evaluations`</mark> function should say

"h*w_i" instead of "h".

   - In the <u><mark>`[update_transcript](https://github.com/matter-labs/fflonk-verifier/blob/c9e99a8760774fcc45df110fddd954246feac00c/solidity/fflonk-foundry/src/FflonkYul.sol#L891-L899)`</mark></u> function, the memory slots <mark>`0x200`</mark> to <mark>`0x203`</mark> are

assumed to <u>[be clean](https://github.com/matter-labs/fflonk-verifier/blob/c9e99a8760774fcc45df110fddd954246feac00c/solidity/fflonk-foundry/src/FflonkYul.sol#L892)</u> and are not explicitly cleaned. While we did not find any security

risk associated with the current usage of this function, consider documenting this

assumption explicitly to reduce the risk of error in case of code reformatting.


FFLONK Verifier Audit − Notes & Additional Information − 23


Consider revising the aforementioned comments to improve consistency and more accurately

reflect the implemented logic, making it easier for auditors and other parties examining the

code to understand what each section of code is designed to do.


**_Update:_** _Resolved in_ _<u>[pull request #5](https://github.com/matter-labs/fflonk-verifier/pull/5)</u>_ _at commit_ _<u>[19ca355. All the points were addressed, and](https://github.com/matter-labs/fflonk-verifier/pull/5/commits/19ca3553369027c71eb512686e9bd2903830a10c)</u>_

_<mark>`MEM_PROOF_LAGRANGE_BASIS_INVERSES`</mark>_ _was renamed to_

_<mark>`MEM_PROOF_LAGRANGE_BASIS_EVALS`</mark>_ _<mark>.</mark>_ _The Matter Labs team stated:_


_The suggestions are now integrated._

### **N-13 Missing Documentation About Treatment of** **Point at Infinity - Phase 3**


The point at infinity was decided not to be accepted as a valid input for the <u>[commitment](https://github.com/matter-labs/fflonk-verifier/blob/c9e99a8760774fcc45df110fddd954246feac00c/solidity/fflonk-foundry/src/FflonkYul.sol#L191-L228)</u> or for

the second operand of the <u>[point_sub](https://github.com/matter-labs/fflonk-verifier/blob/c9e99a8760774fcc45df110fddd954246feac00c/solidity/fflonk-foundry/src/FflonkYul.sol#L948)</u> function due to security concerns by the Matter Labs

team. While this could, in theory, pose completeness issues, we determined, in agreement with

the team, that the security risks outweigh the completeness concerns in this case. However,

this decision has not been documented in the code.


Consider adding documentation around the checks which ensure that the points are on the

curve and the <u><mark>`[point_sub](https://github.com/matter-labs/fflonk-verifier/blob/c9e99a8760774fcc45df110fddd954246feac00c/solidity/fflonk-foundry/src/FflonkYul.sol#L948)`</mark></u> function. This will help document the decision made and avoid any

confusion.


**_Update:_** _Resolved in_ _<u>[pull request #5](https://github.com/matter-labs/fflonk-verifier/pull/5)</u>_ _at commit_ _<u>[19ca355. The Matter Labs team stated:](https://github.com/matter-labs/fflonk-verifier/pull/5/commits/19ca3553369027c71eb512686e9bd2903830a10c)</u>_


_The checks and the function now highlight our decision based on the security concern._

### **N-14 PLONK verify Function Has public** **Visibility - Phase 3**


The current PLONK verifier defines the <mark>`verify`</mark> function with a <u>[public](https://github.com/matter-labs/era-contracts/blob/49868afc8590c3d09daf4d5fc73dcc31587f487d/l2-contracts/contracts/verifier/Verifier.sol#L347)</u> visibility. However, this

function <u>[writes](https://github.com/matter-labs/era-contracts/blob/49868afc8590c3d09daf4d5fc73dcc31587f487d/l2-contracts/contracts/verifier/Verifier.sol#L395)</u> to the free memory pointer slot in memory. Thus, internal calls to the <mark>`verify`</mark>

function would result in an invalid memory layout for the caller.


Consider defining the <mark>`verify`</mark> function as <mark>`external`</mark> for improved clarity, as this function

should not be called internally by other contracts.


**_Update:_** _Acknowledged, will resolve. This will be resolved after migration. The Matter Labs_

_team stated:_


FFLONK Verifier Audit − Notes & Additional Information − 24


_Acknowledged. The visibility is set to_ _<mark>`external`</mark>_ _for the Fflonk verifier per the Verifier_

_interface. Thus, the verifier will have the correct visibility during the migration process._


FFLONK Verifier Audit − Notes & Additional Information − 25


## **Conclusion**

The audited code replaces the current custom PLONK verifier with FFLONK. This new verifier

aims to reduce the on-chain gas costs of verifying L2 blocks.


We commend the Matter Labs team on their effort to reduce gas costs but note the complexity

of the code, as it implements a complicated protocol in assembly. One critical issue was found

that could have resulted in funds from rollups using this verifier being drained, assuming the

future <mark>`Executor`</mark> contract would function in the same way as the current one. This issue

stemmed from assumptions related to the structure of the inputs which were not validated. We

also made multiple recommendations to enhance the quality of the codebase and to further

reduce gas costs, many of which were addressed in later phases. In general, we recommend

that for complex cryptographic changes such as these, a detailed spec be produced

beforehand in order to reduce the possibility of error.


We thank the Matter Labs team for their responsiveness and for meeting with us regularly to

explain the changes introduced by the update.


FFLONK Verifier Audit − Conclusion − 26


