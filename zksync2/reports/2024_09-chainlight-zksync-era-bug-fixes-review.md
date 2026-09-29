# zkSync Era Security Audit

: Bug Fixes Review


September 24, 2024


Revision 1.0


ChainLight@Theori


Theori, Inc. (“We”) is acting solely for the client and is not responsible to any other party.

Deliverables are valid for and should be used solely in connection with the purpose for which they

were prepared as set out in our engagement agreement. You should not refer to or use our name

or advice for any other purpose. The information (where appropriate) has not been verified. No

representation or warranty is given as to accuracy, completeness or correctness of information in

the Deliverables, any document, or any other information made available. Deliverables are for the

internal use of the client and may not be used or relied upon by any person or entity other than the

client. Deliverables are confidential and are not to be provided, without our authorization

(preferably written), to entities or representatives of entities (including employees) that are not the

client, including affiliates or representatives of affiliates of the client.


© 2025 ChainLight, Theori. All rights reserved


## Table of Contents

zkSync Era Security Audit

Table of Contents

Executive Summary

Audit Overview

Scope

Code Revision

Severity Categories

Status Categories

Finding Breakdown by Severity

Findings

Summary

#1 BUGFIX-001 SHA256: add range-checks to make gadget sound

#2 BUGFIX-002 Boojum/U32: range-check output of sub in div_by_const

#3 BUGFIX-003 Boojum/U8: range-check output of sub_no_overflow

#4 BUGFIX-004 Poseidon2 BN254 implementation bug

#5 BUGFIX-007 ZkSync implementation of the permutation argument is weak

#6 BUGFIX-008 Small unsoundness in the recursive verifier

#7 BUGFIX-009 Wrong parameters in gates.

#8 BUGFIX-010 Exception-free formulas for mixing points are broken if the point is infinity

Revision History



1

2

3

4

4

5

5

6

7

8

8

9

12

14

16

18

21

23

26

28



© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 2


## Executive Summary

Starting on September 17, 2024, ChainLight of Theori reviewed the recent security bug findings

and fixes in the zkSync Era circuits. The vulnerabilities were identified by Matter Labs and/or

external reporters. The purpose of ChainLight's review was to identify the root cause, to analyze

potential variants, and to review and suggest remediations.


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 3


## Audit Overview

### Scope

Name zkSync Era Security Audit


Git Repository (matter-labs/zksync-protocol): commit

1bfb6af108c187f8a153afa39bbff0b40bdc4831

Git Repository (matter-labs/zksync-crypto): commit



Target /

Version



542a1a11d57963ace2446c03f2552b74289ec18d

Git Repository (matter-labs/zksync-crypto-fork): commit

73782316774820f6773a1025c23a47ce6c786c50

Git Repository (matter-labs/era-zk_evm): commit

f1db9573a645f48e260649eeaaaf93b5c2ed473a



Application

ZK Circuit
Type


Lang. /

ZK Circuit [Boojum]
Platforms

### Code Revision


N/A


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 4


### Severity Categories

Severity Description


The attack cost is low (not requiring much time or effort to succeed in the



Critical


High


Medium


Low



actual attack), and the vulnerability causes a high-impact issue. (e.g., Effect on

service availability, Attacker taking financial gain)


An attacker can succeed in an attack which clearly causes problems in the

service’s operation. Even when the attack cost is high, the severity of the issue

is considered “high” if the impact of the attack is remarkably high.


An attacker may perform an unintended action in the service, and the action

may impact service operation. However, there are some restrictions for the

actual attack to succeed.


An attacker can perform an unintended action in the service, but the action

does not cause significant impact or the success rate of the attack is

remarkably low.



Informational Any informational findings that do not directly impact the user or the protocol.


Neutral information about the target that is not directly related to the project’s
Note

safety and security.


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 5


### Status Categories

Status Description


Reported ChainLight reported the issue to the client.


WIP The client is working on the patch.


Patched The client fully resolved the issue by patching the root cause.


The client resolved the issue by reducing the risk to an acceptable level by
Mitigated

introducing mitigations.


Acknowledged The client acknowledged the potential risk, but they will resolve it later.


The client acknowledged the potential risk, but they decided to accept the
Won't Fix

risk.


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 6


### Finding Breakdown by Severity

Category Count Findings


Critical 0 N/A


BUGFIX-001



High 4



BUGFIX-002


BUGFIX-003


BUGFIX-004



Medium 0 N/A


BUGFIX-007
Low 2

BUGFIX-008


BUGFIX-009
Informational 2

BUGFIX-010


Note 0 N/A


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 7


## Findings

### Summary

# ID Title Severity Status


SHA256: add range-checks to make gad
1 BUGFIX-001 High Patched

get sound


Boojum/U32: range-check output of sub
2 BUGFIX-002 High Patched

in div_by_const


Boojum/U8: range-check output of sub_
3 BUGFIX-003 High Patched

no_overflow


4 BUGFIX-004 Poseidon2 BN254 implementation bug High Patched


ZkSync implementation of the permutati
5 BUGFIX-007 Low Patched

on argument is weak


Small unsoundness in the recursive verifi
6 BUGFIX-008 Low Won't Fix

er


7 BUGFIX-009 Wrong parameters in gates. Informational Patched


Exception-free formulas for mixing point
8 BUGFIX-010 Informational Mitigated

s are broken if the point is infinity


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 8


### #1 BUGFIX-001 SHA256: add range-checks to make gadget sound

ID Summary Severity


The aligned_variables from split_and_rotate, used in the

SHA256 gadget, have to be u4s. For most cases, this was



High



BUGFIX-001


Description



done by the call to xor. But for the ones stored in

t1_shifted_10, some variables are not checked, as they

are overwritten.



The split_and_rotate function takes in a variable containing a 32-bit value and outputs 8

variables intended to represent the 4-bit chunks of the 32-bits after a constant rotation is applied.

However, split_and_rotate itself doesn't actually range check the output variables -- it only

checks that they combine to the input value via ReductionGate s. In almost every case,

split_and_rotate doing these 4-bit range checks would be redundant, as the outputs are

typically passed to tri_xor_many which uses a lookup table that also acts as range checks.


This issue stems from one case where some output variables from split_and_rotate were

never range constrained:


letlet (t1_rotated_10t1_rotated_10, _ _, t1_rotated_10_decompose_high t1_rotated_10_decompose_high) = split_and_rotatesplit_and_rotate(cscs

, t1 t1, 1010);


letlet mutmut t1_shifted_10 t1_shifted_10 = t1_rotated_10 t1_rotated_10;

t1_shifted_10t1_shifted_10[7] = zero zero;

t1_shifted_10t1_shifted_10[6] = zero zero;

t1_shifted_10t1_shifted_10[5] = t1_rotated_10_decompose_high t1_rotated_10_decompose_high;

......

letlet s1_chunks s1_chunks = tri_xor_manytri_xor_many(cscs, &t1_rotated_17t1_rotated_17, &t1_rotated_19t1_rotated_19, &t1_shiftt1_shift

ed_10ed_10);


As some of the original variables in t1_rotated_10 are immediately overwritten, they are never

range constrained, which allows the other values in t1_rotated_10 to be invalid.


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 9


After review, we concluded that this was the only case where the split_and_rotate result

wasn't directly passed into tri_xor_many .


Impact


High


These unconstrained variables allow invalid SHA256 hashes to be computed.


Recommendation


In addition to the provided fix, we have some long-term recommendations to reduce the chance of

similar issues:


1. Functions should clearly document their assumptions about range constraints. For example,

split_and_rotate should inform its callers that the output variables must be separately

range constrained.

2. The circuit synthesis could dynamically track range constraints that are (allegedly) applied to

variables. Specifically, each Variable can have a corresponding interval that is tracked.

Circuit gates and lookup tables can adjust the interval of each variables they operate on.

Variable s can also be annotated with their expected/required range constraints, which are

verified at the end of circuit synthesis using their corresponding intervals. This scheme would

accomplish two goals: (a) enable detection of missing range constraints during circuit

synthesis without introducing new constraints, and (b) narrow the scope of code that must be

reviewed for range constraint correctness.


References


N/A


Remediation


Patched


The issue was fixed in commit a548279113178128dde7cf99c5fb20bc16440b0d of matter
labs/zksync-crypto-fork .


The fix uses tri_xor_many to range check the three unchecked values before they are

overwritten:


// These positions need to be range-checked manually to ensure// These positions need to be range-checked manually to ensure

// [split_and_rotate] is sound.// [split_and_rotate] is sound.

letlet _ _ = tri_xor_manytri_xor_many(


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 10


cscs,

&[t1_rotated_10t1_rotated_10[7]],

&[t1_rotated_10t1_rotated_10[6]],

&[t1_rotated_10t1_rotated_10[5]],

);


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 11


### #2 BUGFIX-002 Boojum/U32: range-check output of sub in div_by_const

ID Summary Severity


Missing range constraint on remainder check in div_by
BUGFIX-002 High

constant .


Description


The UIntXAddGate is described as follows:


// a + b + carry_in = c + 2^N * carry_out,


// `carry_out` is boolean constrainted


// but `c` is NOT. We will use reduction gate to perform decomposition of


`c`, and separate range checks


It's worth noting that the gate itself also does not range constrain a or b .


UIntXAddGate::perform_subtraction_with_expected_borrow_out(a, b, borrow_in,

zerovar, borrow_out) creates the following gate:


SelfSelf {

a: output_variable output_variable,

b,

carry_incarry_in: borrow_in borrow_in,

c: a a,

carry_outcarry_out: borrow_out borrow_out

}


and thus does not itself range constrain the output_variable .


In Uint32::div_by_constant, the remainder after division should be constrained to be lower

than the divisor. To implement that, the code uses

perform_subtraction_with_expected_borrow_out to check that the output carry flag is true

when computing remainder - constant :


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 12


letlet _ _ = UIntXAddGateUIntXAddGate::::<3232>::::perform_subtraction_with_expected_borrow_outperform_subtraction_with_expected_borrow_out(

cscs,

remainderremainder.variablevariable,

allocated_constantallocated_constant.variablevariable,

no_borrowno_borrow,

no_borrowno_borrow,

boolean_trueboolean_true.variablevariable,

);


However, since the output_variable is not range constrained and is ignored in

UInt32::div_by_constant, this fails to constrain the size of the remainder. Specifically, a

malicious prover can assign (remainder - constant + 2**32) mod p to the

output_variable to satisfy the gate even if remainder < constant .


Impact


High


The issue allows invalid division results to be proven, which impacts many parts of the circuit code.

A notable example is determining which memory cell is accessed during a memory read or write:


letlet (cell_idxcell_idx, unalignment unalignment) = offset offset.div_by_constantdiv_by_constant(cscs, 3232);


Recommendation


N/A


References


N/A


Remediation


Patched


The issue was fixed in commit b2afca2d77045f692bf6abe5e1d4baaf871009af of matter
labs/zksync-crypto-fork .


The provided fix uses UInt32::from_variable_checked to range constrain the subtraction

result.


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 13


### #3 BUGFIX-003 Boojum/U8: range-check output of sub_no_overflow

ID Summary Severity


BUGFIX-003 Brief explanation High


Description


This issue is similar to BUGFIX-002. In U8::sub_no_overflow, a subtraction result from

UIntXAddGate is used without a range check:


letlet no_borrow no_borrow = cs cs.allocate_constantallocate_constant(F::::ZEROZERO);

letlet result_var result_var = UIntXAddGateUIntXAddGate::::<8>::::perform_subtraction_no_borrowperform_subtraction_no_borrow(

cscs,

selfself.variablevariable,

otherother.variablevariable,

no_borrowno_borrow,

no_borrowno_borrow,

);


letlet result result = SelfSelf {

variablevariable: result_var result_var,

_marker_marker: stdstd::::markermarker::::PhantomDataPhantomData,

};


Impact


High


U8::sub_no_overflow is used in the keccak256 round function, so this issue can allow invalid

keccak hashes to be computed.


Recommendation


N/A


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 14


References


N/A


Remediation


Patched


The issue was fixed 73782316774820f6773a1025c23a47ce6c786c50 of matter
labs/zksync-crypto-fork . The fix adds a range check to the subtraction result:


letlet result result = SelfSelf::::from_variable_checkedfrom_variable_checked(cscs, result_var result_var);


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 15


### #4 BUGFIX-004 Poseidon2 BN254 implementation bug

ID Summary Severity


Poseidon2Params::defaults zeros out the wrong round
BUGFIX-004 High

constants.


Description


The partial rounds of Poseidon2 should applied in between the first half and second half of the full

rounds, as described in Section 6 of [https://eprint.iacr.org/2023/323.pdf.](https://eprint.iacr.org/2023/323.pdf) The default round

constants are generated via a deterministic hashing procedure, and the code was previously

modifying the round constants at the beginning (rather than in between the sets of full rounds):


letlet mutmut round_constants round_constants = params params.round_constantsround_constants().to_ownedto_owned();

forfor i i inin 0....paramsparams.partial_rounds partial_rounds {

forfor j j inin 1....WIDTHWIDTH {

round_constantsround_constants[i][j] = E::::FrFr::::zerozero();

}

}


Impact


High


Using the wrong parameters can greatly reduce the security of the Poseidon hash family.


Recommendation


N/A


References


[https://eprint.iacr.org/2023/323.pdf](https://eprint.iacr.org/2023/323.pdf)


Remediation


Patched


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 16


The issue was fixed in commit 542a1a11d57963ace2446c03f2552b74289ec18d of matter
labs/zksync-crypto . The fix changes the offset of the round constants being overwritten:


letlet mutmut round_constants round_constants = params params.round_constantsround_constants().to_ownedto_owned();

forfor i i inin (full_rounds full_rounds / 2)....(full_rounds full_rounds / 2) + partial_rounds partial_rounds {

forfor j j inin 1....WIDTHWIDTH {

round_constantsround_constants[i][j] = E::::FrFr::::zerozero();

}

}


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 17


### #5 BUGFIX-007 ZkSync implementation of the permutation argument is weak

ID Summary Severity


If proving a batch with very large queues, the security of the
BUGFIX-007 Low

permutation argument can reach as low as 70 bits.


Description


The soundness of the zkSync Era circuits relies on various queues (e.g. storage writes and RAM

access) being properly constrained. This is accomplished by sorting the queue (out of circuit)

according to a simple ordering and verifying consistency by iterating the sorted queue.

Constraining the order of the sorted queue is easy to do in-circuit, but verifying it contains the

same elements as the original queue is done with a permutationargument.


The permutation argument constructs two polynomials whose roots are the encodings of the

elements of their respective queue, such that the queues are equal if and only if the polynomials

are equal. Let qo ​(x) ∈ Fp ​[x] be the polynomial for the original queue and qs ​(x) ∈ Fp ​[x] be the

polynomial for the sorted queue.



Deterministically checking if qo ​(x) = qs ​(x) is expensive, but it can be approximated by random



Deterministically checking if qo ​(x) = qs ​(x) is expensive, but it can be approximated by random

evaluations. Let p(x) = qs ​(x) − qo ​(x), so we want to check if p(x) = 0. The Schwartz-Zippel

Lemma tells us that if p = 0, deg(p) ≤ d, and r is a uniformly random value in Fp,​ then Pr[p(r) =

0] ≤ <u>dp</u> ​.



evaluations. Let p(x) = qs ​(x) − qo ​(x), so we want to check if p(x) = 0. The Schwartz-Zippel



Lemma tells us that if p = 0, deg(p) ≤ d, and r is a uniformly random value in Fp,​ then



.



This means we can approximate checking if qo ​(x) = qs ​(x) by evaluating p(x) on a random point

and confirming it is zero. If this random evaluation is performed k times, the probability of a false



​
( pd



​
pd )



k



positive is at most ​ .

( pd )



As usual in ZK proofs, the random point selection is replaced with the Fiat-Shamir heuristic,

wherein the points are selected by hashing the input values.



p = 264 - 232 + 1 and repeats the random evaluation k = 2

als are degree at most 2 <sup>32</sup> (the maximum length of a Boojum



zkSync Era's proof system uses p = 264 - 232 + 1 and repeats the random evaluation



times. Since the queue polynomials are degree at most 2 <sup>32</sup> (the maximum length of a Boojum



© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 18


2

queue), the false-positive probability is roughly ​ = 2 <sup>−64</sup> . This means an attacker brute

( 2264 <sup>32</sup> )

forcing an invalid sorted storage queue takes an expected 2 <sup>64</sup> attempts.


This is notably lower than other parts of the system, but is still sufficiently high that an attack is

unlikely, especially given the high fixed cost of each attempt. Nonetheless, the permutation

argument is a weak link that is easy to strengthen.


Impact


Low


Describe the impact of the bug


Recommendation


There are two primary ways to increase the security of the permutation check.


1. Increase the number of evaluations

2. Perform the evaluation(s) over a field extension


Option 2 has better probability scaling properties. Specifically, the false-positive probability when

using a degree-k extension is p <sup><u>dk</u></sup> ​, which is a factor of d <sup>k−1</sup> better than doing k base field

evaluations.



However, option 1 is a significantly simpler change to the codebase. An single evaluation (k = 3)



ange to the codebase. An single evaluation (k = 3

2 <sup>32</sup> without introducing additional complexity.



will increase the security budget by at least 2 <sup>32</sup> without introducing additional complexity.



If option 2 is chosen, we recommend having the field extension evaluation closely audited to

ensure the additional complexity does not introduce new vulnerabilities.


A third, supplemental improvement would be to constrain the queue length to be at most 2 <sup>24</sup>,

which should be sufficiently large for any batch being proven in practice, but further increase the

security budget by 8 bits per evaluation.


References


[https://en.wikipedia.org/wiki/Schwartz%E2%80%93Zippel_lemma](https://en.wikipedia.org/wiki/Schwartz%E2%80%93Zippel_lemma)


Remediation


Patched


Commit ec69d6f0e13f0cdf67471fb12ec0e098aea973e4 of matter-labs/zksync
protocol-25-09-2024 increases the number of evaluations to 3, upgrading the worst-case


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 19


security level to 96 bits.


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 20


### #6 BUGFIX-008 Small unsoundness in the recursive verifier

ID Summary Severity


The transcript challenge bits can be slightly influenced by a
BUGFIX-008 Low

malicious prover.


Description


The recursive verifier uses the Fiat-Shamir heuristic to generate challenges for the proof

verification routine. Some of these challenges come in the form of indexes in binary trees, so the

challenges are generated in a bit-decomposed form which is interpreted as the path through the

tree. To generate these path challenges, BoolsBuffer::get_bits is used:


pubpub fnfn get_bitsget_bits<CSCS: ConstraintSystemConstraintSystem<F>, T: CircuitTranscriptCircuitTranscript<F>>>>(

......

) ->-> VecVec<BooleanBoolean<F>>>> {

......

// get 1 field element form transcript// get 1 field element form transcript

letlet field_el field_el = transcript transcript.get_challengeget_challenge(cscs);

letlet el_bits el_bits = field_el field_el.spread_into_bitsspread_into_bits::::<CSCS, 6464>(cscs);

letlet mutmut lsb_iterator lsb_iterator = el_bits el_bits.iteriter();

......

}



Here, transcript.get_challenge returns an element in the Goldilocks field (



p = 264 - 232 +



), and spread_into_bits<CS, 64> returns a 64-bit decomposition of the field element.



1), and spread_into_bits<CS, 64> returns a 64-bit decomposition of the field

However, there are 264 - p = 232 - 1 many elements that have twovalid 64-bit dec

the field, namely for all 0 ≤ i < 2 <sup>32−1</sup>, the integer bit decompositions for i and p + i



However, there are 264 - p = 232 - 1 many elements that have twovalid 64-bit decompositions in



the field, namely for all 0 ≤ i < 2 <sup>32−1</sup>, the integer bit decompositions for i and p + i both satisfy



the constraints for spread_into_bits<CS, 64> .


This means that if the transcript challenge returns a value in this range, an attacker gets 1 bit of

control over the challenge bits, i.e. they can choose which of the two valid decompositions to

assign to the witness.


Impact


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 21


Low



For a given transcript, the probability that the transcript challenge is vulnerable is roughly 2 <sup>−32</sup> and

they are only given 1 bit of control over the path challenge. While even this level of control should

be eliminated, it is extremely unlikely to be exploitable in practice.


Recommendation


It is difficult to fix this issue without introducing a nontrivial number of additional constraints. One

possibility is to reject the invalid bit decompositions as follows:


1. Split the field element into 32-bit limbs (with range checking)

2. Constrain that if the high limb is 0xffffffff, then the low limb must be 0

3. Decompose each 32-bit limb and concatenate the results.



Additionally, spread_into_bits<CS, N> could be updated to require N < log2 ​(p) during



N < log



2 ​(p)



circuit synthesis to help catch similar issues in the future.


References


N/A


Remediation


Won't Fix


As this issue is difficult to exploit, it was decided to not fix it immediately.


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 22


### #7 BUGFIX-009 Wrong parameters in gates.

ID Summary Severity


Some gates have their max_constraint_degree
BUGFIX-009 Informational

configured incorrectly.


Description


In Boojum, each gate type has an associated GateConstraintEvaluator which provides some

metadata about the gates and implements the gate evaluation at proving time. The

GateConstraintEvaluator::gate_purpose function returns the metadata information while

the GateConstraintEvaluator::evaluate_once function implements the actual evaluation.

For example, the BooleanConstaintEvaluator has the following simple definitions:


implimpl<F: PrimeFieldPrimeField> GateConstraintEvaluatorGateConstraintEvaluator<F> forfor BooleanConstraitEvaluatBooleanConstraitEvaluat

oror {

......

fnfn gate_purposegate_purpose() ->-> GatePurposeGatePurpose {

GatePurposeGatePurpose::::EvaluatableEvaluatable {

max_constraint_degreemax_constraint_degree: 2,

num_quotient_termsnum_quotient_terms: 1,

}

}

......

fnfn evaluate_onceevaluate_once<

P: fieldfield::::traitstraits::::field_likefield_like::::PrimeFieldLikePrimeFieldLike<BaseBase = F>,

S: TraceSourceTraceSource<F, P>,

D: EvaluationDestinationEvaluationDestination<F, P>,

>(

&selfself,

trace_sourcetrace_source: &S,

destinationdestination: &mutmut D,

_shared_constants_shared_constants: &SelfSelf::::RowSharedConstantsRowSharedConstants<P>,

_global_constants_global_constants: &SelfSelf::::GlobalConstantsGlobalConstants<P>,

ctxctx: &mutmut P::::ContextContext,

) {


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 23


letlet one one = P::::oneone(ctxctx);

letlet a a = trace_source trace_source.get_variable_valueget_variable_value(0);

letlet mutmut tmp tmp = one one;

tmptmp.sub_assignsub_assign(&a, ctx ctx);


letlet mutmut contribution contribution = a a;

contributioncontribution.mul_assignmul_assign(&tmptmp, ctx ctx);


destinationdestination.push_evaluation_resultpush_evaluation_result(contributioncontribution, ctx ctx);

}

}


This gate implements the common boolean constraint a * (1-a) == 0, which has degree 2, as

reflected by the max_constraint_degree in the GatePurpose .


Several gates were found to return the incorrect value for max_constraint_degree :


U32SubConstraintEvaluator returns 1, but it should be 2 as it contains a boolean

constraint for a carry bit within it.

U32AddConstraintEvaluator returns 1, but it should be 2 as it contains a boolean

constraint for a carry bit within it.

U32TriAddCarryAsChunkConstraintEvaluator returns 2, but it should be 1 as all terms

are products of a global constant and variable.


Impact


Informational


This gate degree information is used during setup to assign selectors, as explained in the

documentation in CSReferenceAssembly::compute_selector_and_constants_placement :


// every gate has a specific degree that it evaluates too,// every gate has a specific degree that it evaluates too,

// and potentially non-trivial selector's path that// and potentially non-trivial selector's path that

// looks like unbalanced tree// looks like unbalanced tree


//       X//       X

//    sel0  (1-sel0)//    sel0  (1-sel0)

//  sel1 (1-sel1) sel1  (1-sel1)//  sel1 (1-sel1) sel1  (1-sel1)

//  G0   G1    G2  sel2  (1-sel2)//  G0   G1    G2  sel2  (1-sel2)

//              G3    G4//              G3    G4


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 24


// and our task is to find placements of gates and selectors// and our task is to find placements of gates and selectors

// such that it leads to the minimal value of// such that it leads to the minimal value of

// degree(gate) * len(selectors path) from the root// degree(gate) * len(selectors path) from the root


The degree in GatePurpose is used to search for the assignment of selectors which minimizes

the total degree of the resulting constraint, including selectors. The maximum degree of the

resulting constraint is then used to determine the quotient_degree value used in the

polynomial IOP.


Hence, max_constraint_degree values which are too large could result in non-optimal selector

assignment. Worse yet, values which are too small could result in miscalculation of the total degree

of the constraint (including selectors) and hence also the quotient_degree, which could have

implications for the security of the proof system. However, whether this occurs is dependent on

the selector assignment and may require significantly low values as the quotient_degree is

rounded up to the nearest power of two. Note that the selector assignment is dependent on the

set of gate types used, and so will vary circuit-to-circuit.


Recommendation


Correct the max_constraint_degree value for all gates identified in the description above.


References


N/A


Remediation


Patched


This issue was fixed in commit 3f77d715b27bebe28fa8f53861324f1d4284c19b of matter
labs/ zksync-crypto-fork .


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 25


### #8 BUGFIX-010 Exception-free formulas for mixing points are broken if the point is infinity

ID Summary Severity


‎SWProjectivePoint::add_mixed‎expects the argument



Informational



BUGFIX-010


Description



point is a valid affine point (i.e. not the point at infinity), but is

occasionally used with invalid affine points.



Various circuits (for instance, the ecrecover circuit) in zkSync Era must constrain the result of

elliptic curve arithmetic over non-native fields. A common operation needed is adding two elliptic

curve points, and the preferred algorithm for a ZK-circuit implementation is an exception-free

mixed point addition formula, as it uses fewer constraints than other methods. Here, "mixed point"

means that one of the points is represented in projective coordinates while the other is

represented in affine coordinates. Recall that affine coordinates are unable to represent the

additive identity in an elliptic curve group, i.e. the point at infinity.


As a result, using mixed point addition requires knowing that one of the points cannot be the

identity element. However, since ZK-circuits are uniform computation models, the circuit cannot

"choose" not to use mixed point addition if it encounters a point at infinity. Instead, it must pass a

dummyinput into the mixed point addition and ignore the result via a conditional select.


An example of this approach is in ecrecover 's fixed-based point multiplication. This performs a

base-256 optimized multiplication of the generator with a scalar. Each iteration uses a lookup


table to lookup an affine point, where the point at infinity is represented by the dummy value (x, y)

where x = y = 0, and the point is added to an accumulator. Below is the accumulation code:


letlet new_acc new_acc = acc acc.add_mixedadd_mixed(cscs, &mutmut (x, y y));

letlet should_not_update should_not_update = byte byte.is_zerois_zero(cscs);

acc acc = SelectableSelectable::::conditionally_selectconditionally_select(cscs, should_not_update should_not_update, &accacc, &new_anew_a

cccc);


As you can see, the result of the add_mixed is ignored if the lookup byte is zero, directly

corresponding to when the (x, y) are not a valid affine point.


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 26


All other uses of add_mixed either operate similarly, or are guaranteed the affine point is valid by

some other means.


Impact


Informational


This issue was assessed to have no security impact on the current circuits. However, some

mitigations can ensure issues don't arise in future versions of the circuits.


Recommendation


This common pattern of an add_mixed followed by a conditionally_select could become

the default interface for point addition. Specifically, the add_mixed function could be rewritten as

follows:


pubpub fnfn add_mixedadd_mixed<CSCS: ConstraintSystemConstraintSystem<F>>>>(

&mutmut selfself,

cscs: &mutmut CSCS,

other_xyother_xy: &mutmut (NNNN, NNNN),

is_infinityis_infinity: BooleanBoolean<F>

) ->-> SelfSelf {

letlet res res = selfself.add_sub_mixed_impladd_sub_mixed_impl(cscs, other_xy other_xy, falsefalse);

SelectableSelectable::::conditionally_selectconditionally_select(cscs, is_infinity is_infinity, selfself, &resres)

}


Note that the conditionally_select could in principle be optimized to not create any

constraints if the is_infinity flag is a constant value, allowing this interface to have zero

overhead for cases where other_xy is guaranteed to be valid.


References


Algorithm 8 from [https://eprint.iacr.org/2015/1060.pdf](https://eprint.iacr.org/2015/1060.pdf)


Remediation


Mitigated


There was no current security impact of this code pattern. Commit

3f77d715b27bebe28fa8f53861324f1d4284c19b of matter-labs/zksync-crypto-fork

adds documentation to help avoid potentially dangerous use of add_mixed .


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 27


### Revision History

Version Date Description


1.0 Sep 24, 2024 Initial version


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 28


Theori, Inc. (“We”) is acting solely for the client and is not responsible to any other party.

Deliverables are valid for and should be used solely in connection with the purpose for which they

were prepared as set out in our engagement agreement. You should not refer to or use our name

or advice for any other purpose. The information (where appropriate) has not been verified. No

representation or warranty is given as to accuracy, completeness or correctness of information in

the Deliverables, any document, or any other information made available. Deliverables are for the

internal use of the client and may not be used or relied upon by any person or entity other than the

client. Deliverables are confidential and are not to be provided, without our authorization

(preferably written), to entities or representatives of entities (including employees) that are not the

client, including affiliates or representatives of affiliates of the client.


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 29


