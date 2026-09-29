# zkSync Era Security Audit

: Bug Fixes Review Part 2


January 24, 2024


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

#1 BUGFIX2-001 Deleted the repetition in normalization

#2 BUGFIX2-002 Fix overflow tracking in negated

#3 BUGFIX2-004 Increase memory stipend for EVM calls

#4 BUGFIX2-005 Fix in-circuit gas stipend passing

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

13

17

19

21



© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 2


## Executive Summary

Starting on January 20, 2025, ChainLight of Theori reviewed the recent security bug findings and

fixes in the zkSync Era circuits. The vulnerabilities were identified by Matter Labs and/or external

reporters. The purpose of ChainLight's review was to identify the root cause, to analyze potential

variants, and to review and suggest remediations. This review was a follow-up to a similar review

performed on a different set of bugs in September 2024.


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 3


## Audit Overview

### Scope

Name zkSync Era Security Audit


Git Repository (matter-labs/zksync-protocol): diff

v0.150.20...protocol-v27-rc, commits



Target /

Version



07f7b8d8bddb7b168a8c1745c2b43e2b7b804c3e to

d0b3ad21f4ab7474fdaba9bafb77fb9a69580fc8

Git Repository (matter-labs/zksync-crypto): diff v0.30.13...crypto
v27-rc, commits 59146fc92571415abf2b62001b2bc43b1d04fe60 to

0291932b2c951d721506371519cd5aee4132fa64



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


High 0 N/A


Medium 1 BUGFIX2-005


Low 1 BUGFIX2-002


BUGFIX2-001
Informational 2

BUGFIX2-004


Note 0 N/A


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 7


## Findings

### Summary

# ID Title Severity Status


1 BUGFIX2-001 Deleted the repetition in normalization Informational Reported


2 BUGFIX2-002 Fix overflow tracking in negated Low Patched


3 BUGFIX2-004 Increase memory stipend for EVM calls Informational Patched


4 BUGFIX2-005 Fix in-circuit gas stipend passing Medium Patched


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 8


### #1 BUGFIX2-001 Deleted the repetition in normalization

ID Summary Severity


NonNativeFieldOverU16::normalize no longer repeats
BUGFIX2-001 Informational

the enforced_reduced constraints


Description


NonNativeFieldOverU16 provides an implementation of non-native field arithmetic where

elements are represented with 16-bit limbs. To minimize unnecessary constraints, the module

supports performing some arithmetic operations (e.g. add ) without fully constraining the result to

be in canonical form.


To enforce (i.e. add constraints) that an element is already in canonical form, users of the module

can call enforce_reduced :


pubpub fnfn enforce_reducedenforce_reduced<CSCS: ConstraintSystemConstraintSystem<F>>>>(&mutmut selfself, cs cs: &mutmut CSCS) {

assert_eq!assert_eq!(selfself.formform, RepresentationFormRepresentationForm::::NormalizedNormalized);

ifif selfself.trackertracker.max_moduluses max_moduluses ==== 1 &&&& selfself.form form ==== RepresentationFormRepresentationForm:

:NormalizedNormalized {

returnreturn;

}

// ...// ...

letlet modulus modulus = selfself.

.paramsparams

.modulusmodulus

.mapmap(|elel| cs cs.allocate_constantallocate_constant(F::::from_u64_uncheckedfrom_u64_unchecked(el el asas u64u64)));

letlet els_to_skip els_to_skip = N - selfself.paramsparams.modulus_limbsmodulus_limbs;

letlet _ _ = u16_long_subtraction_noborrow_must_borrowu16_long_subtraction_noborrow_must_borrow(cscs, &selfself.limbslimbs, &momo

dulusdulus, els_to_skip els_to_skip);

selfself.trackertracker.max_moduluses max_moduluses = 1;

}


If the element is not yet in canonical form, users of the module can call normalize to produce a

normalized and reduced representation:


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 9


pubpub fnfn normalizenormalize<CSCS: ConstraintSystemConstraintSystem<F>>>>(&mutmut selfself, cs cs: &mutmut CSCS)

wherewhere

[(); N + 1]:,

{

ifif selfself.trackertracker.max_moduluses max_moduluses ==== 1 &&&& selfself.form form ==== RepresentationFormRepresentationForm:

:NormalizedNormalized {

returnreturn;

}

// well, we just mul by 1// well, we just mul by 1

letlet mutmut one one: NonNativeFieldOverU16NonNativeFieldOverU16<F, T, N> =

SelfSelf::::allocated_constantallocated_constant(cscs, T::::oneone(), &selfself.paramsparams);

letlet mutmut normalized normalized = selfself.mulmul(cscs, &mutmut one one);

// ...// ...

letlet modulus modulus = selfself

.paramsparams

.modulusmodulus

.mapmap(|elel| cs cs.allocate_constantallocate_constant(F::::from_u64_uncheckedfrom_u64_unchecked(el el asas u64u64)));

// for rare case when our modulus is exactly 16 * K bits, but we use l// for rare case when our modulus is exactly 16 * K bits, but we use l

arger representationarger representation

letlet els_to_skip els_to_skip = N - selfself.paramsparams.modulus_limbsmodulus_limbs;

letlet _ _ =

u16_long_subtraction_noborrow_must_borrowu16_long_subtraction_noborrow_must_borrow(cscs, &normalizednormalized.limbslimbs, &

modulusmodulus, els_to_skip els_to_skip);

assert!assert!(normalizednormalized.form form ==== RepresentationFormRepresentationForm::::NormalizedNormalized);

normalizednormalized.trackertracker.max_moduluses max_moduluses = 1;


// update self to normalized one// update self to normalized one

*selfself = normalized normalized;

}


Notice that the full enforced_reduce logic is duplicated in normalize . The bulk of the logic to

actually produce a normalized representation is in mul, which normalize leverages by

multiplying the element by one. However, the mul function always calls enforce_reduced on

the result before returning:


pubpub fnfn mulmul<CSCS: ConstraintSystemConstraintSystem<F>>>>(&mutmut selfself, cs cs: &mutmut CSCS, other other: &mutmut SeSe

lflf) ->-> SelfSelf

wherewhere


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 10


{


}




[(); N + 1]:,


// ...// ...

letlet mutmut new new = SelfSelf {

limbslimbs: r r,

non_zero_limbsnon_zero_limbs: selfself.paramsparams.modulus_limbsmodulus_limbs,

trackertracker: OverflowTrackerOverflowTracker {

max_modulusesmax_moduluses: selfself.paramsparams.max_mods_in_allocationmax_mods_in_allocation,

},

formform: RepresentationFormRepresentationForm::::NormalizedNormalized,

paramsparams: selfself.paramsparams.cloneclone(),

_marker_marker: stdstd::::markermarker::::PhantomDataPhantomData,

};


// enforce that r is canonical// enforce that r is canonical

newnew.enforce_reducedenforce_reduced(cscs);


newnew



As a result, the additional reduction checking constraints added by normalize are unnecessary

and redundant.


Impact


Informational


This change does not fix a security issue. It simply removes some redundant constraints.


Recommendation


The change removes the additional constraints and simply returns the result after multiplying by

one. This relies on the implementation of mul always returning fully reduced values. We suggest a

more resilient change, which is to substitute the additional constraints with a call to

new.enforce_reduced(cs) . This call will be a no-op on reduced values, but will be robust

against future edits to mul .


References


N/A


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 11


Remediation


Reported


A patch removing the additional constraints from normalize was applied in commit

b03cc4fc67a84efe46104f9c885b8ad3cc3134cd of matter-labs/zksync-crypto.


Our recommended fix has been reported to Matter Labs.


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 12


### #2 BUGFIX2-002 Fix overflow tracking in negated

ID Summary Severity


NonNativeFieldOverU16::negated incorrectly
BUGFIX2-002 Low

implements overflow tracking


Description


NonNativeFieldOverU16 performs static range tracking for each element, which is used both

for runtime asserts and constraint optimizations. For instance, adding two elements should only

require a gate count proportional to their number of nonzero limbs, so statically tracking the

maximum value of each element allows omitting those unnecessary gates.


The static range tracking is implemented using OverflowTracker, which tracks the maximum

value of element in terms of multiples of the modulus:


pubpub structstruct OverflowTrackerOverflowTracker {

pubpub max_moduluses max_moduluses: u32u32,

}


NonNativeFieldOverU16::negated returns the additive inverse of a field element.


pubpub fnfn negatednegated<CSCS: ConstraintSystemConstraintSystem<F>>>>(&mutmut selfself, cs cs: &mutmut CSCS) ->-> SelfSelf

wherewhere

[(); N + 1]:,

{

letlet new new = ifif selfself.form form ==== RepresentationFormRepresentationForm::::NormalizedNormalized {

// ...// ...

// lazy path is not possible in this case// lazy path is not possible in this case

letlet modulus_shifted modulus_shifted = selfself

.paramsparams

.modulus_u1024modulus_u1024

.wrapping_mulwrapping_mul(&U1024U1024::::from_wordfrom_word(selfself.trackertracker.max_moduluses max_moduluses asas

u64u64));

letlet used_words used_words = selfself

.trackertracker


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 13


.used_words_if_normalizedused_words_if_normalized(selfself.paramsparams.modulus_u1024modulus_u1024.as_refas_ref());

debug_assert!debug_assert!(used_words used_words <=<= N);


letlet modulus_words modulus_words = u1024_to_u16_wordsu1024_to_u16_words::::<N>(&modulus_shiftedmodulus_shifted);

letlet modulus_words modulus_words =

modulus_wordsmodulus_words.mapmap(|elel| cs cs.allocate_constantallocate_constant(F::::from_u64_unchecfrom_u64_unchec

kedked(el el asas u64u64)));

letlet limbs limbs =

u16_long_subtraction_noborrowu16_long_subtraction_noborrow(cscs, &modulus_wordsmodulus_words, &selfself.limbslimbs,

N - used_words used_words);


letlet new new = SelfSelf {

limbslimbs,

non_zero_limbsnon_zero_limbs: used_words used_words,

trackertracker: OverflowTrackerOverflowTracker { max_moduluses max_moduluses: 2 }, // NOTE: if sel// NOTE: if sel

f == 0, then limbs will be == modulus, so use 2f == 0, then limbs will be == modulus, so use 2

formform: RepresentationFormRepresentationForm::::NormalizedNormalized,

paramsparams: selfself.paramsparams.cloneclone(),

_marker_marker: stdstd::::markermarker::::PhantomDataPhantomData,

};


newnew

} elseelse {

// ...// ...

};

// ...// ...


newnew

}


The above code returns an OverflowTracker with max_moduluses hardcoded to 2, which is

only correct if the input was fully reduced. In reality, negated computes the result as


selfself.trackertracker.max_moduluses max_moduluses * selfself.paramsparams.modulus modulus - selfself


which may be as large as self.tracker.max_moduluses * self.params.modulus if the

input was the zero element.


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 14


Impact


Low


Since the overflow tracking is used for gate optimizations and overflow avoidance, this issue may

have security impact in particular circumstances.


Recommendation


The following patch was provided for us to review:


@@ -764,7 +764,7 @@ where@@ -764,7 +764,7 @@ where

let new = Self {      let new = Self {

limbs,        limbs,

non_zero_limbs: used_words,        non_zero_limbs: used_words,

  -    tracker: OverflowTracker { max_moduluses: 2 }, // NOTE: if    tracker: OverflowTracker { max_moduluses: 2 }, // NOTE: if

self == 0, then limbs will be == modulus, so use 2self == 0, then limbs will be == modulus, so use 2

+       tracker: self.tracker,       tracker: self.tracker,

form: RepresentationForm::Normalized,        form: RepresentationForm::Normalized,

params: self.params.clone(),        params: self.params.clone(),

_marker: std::marker::PhantomData,        _marker: std::marker::PhantomData,


However, we suggest using the following patch instead:


@@ -764,7 +764,7 @@ where@@ -764,7 +764,7 @@ where

let new = Self {      let new = Self {

limbs,        limbs,

non_zero_limbs: used_words,        non_zero_limbs: used_words,

  -    tracker: OverflowTracker { max_moduluses: 2 }, // NOTE: if    tracker: OverflowTracker { max_moduluses: 2 }, // NOTE: if

self == 0, then limbs will be == modulus, so use 2self == 0, then limbs will be == modulus, so use 2

+       tracker: OverflowTracker { max_moduluses: self.tracker.max_       tracker: OverflowTracker { max_moduluses: self.tracker.max_

moduluses + 1 },moduluses + 1 },

form: RepresentationForm::Normalized,        form: RepresentationForm::Normalized,

params: self.params.clone(),        params: self.params.clone(),

_marker: std::marker::PhantomData,        _marker: std::marker::PhantomData,


The reason is that other code assumes that a normalized value with max_moduluses = 1 means

the value is reduced. For instance, enforce_reduced will not produce any constraints if these

conditions are met:


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 15


pubpub fnfn enforce_reducedenforce_reduced<CSCS: ConstraintSystemConstraintSystem<F>>>>(&mutmut selfself, cs cs: &mutmut CSCS) {

assert_eq!assert_eq!(selfself.formform, RepresentationFormRepresentationForm::::NormalizedNormalized);

ifif selfself.trackertracker.max_moduluses max_moduluses ==== 1 &&&& selfself.form form ==== RepresentationFormRepresentationForm:

:NormalizedNormalized {

returnreturn;

}

// ...// ...

}


However, calling negate on the zero element will return the modulus, which is not reduced and

thus should not have max_moduluses == 1 .


References


N/A


Remediation


Patched


The change which returns self.tracker was applied in commit

59146fc92571415abf2b62001b2bc43b1d04fe60 of matter-labs/zksync-crypto.


Our recommended fix was applied in commit f5c3c8bce24b6cab6508f50497c75e63b910e5db

of matter-labs/zksync-crypto.


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 16


### #3 BUGFIX2-004 Increase memory stipend for EVM calls

ID Summary Severity


BUGFIX2-004 Grants the EVM simulator a memory stipend when called Informational


Description


The EraVM has two types of stipends: gas stipends and memory stipends. BUGFIX2-003 removed

the gas stipend for the EVM simulator, while this change adds a memory stipend to EVM simulator

calls.


Memory stipends are an amount of memory for which the callee can use before being charged

memory growth costs. Before this change, all calls received a small memory stipend, while calls to

system contracts received an extra memory stipend:


// 4 KB for new frames is "free"// 4 KB for new frames is "free"

pubpub constconst NEW_FRAME_MEMORY_STIPENDNEW_FRAME_MEMORY_STIPEND: u32u32 = 1u321u32 <<<< 1212;

// 2 MB for kernel frames, where we can be sure about the behavior.// 2 MB for kernel frames, where we can be sure about the behavior.

// Note, that this number should high enough to allow any bytecode for // Note, that this number should high enough to allow any bytecode for ``dede

commitcommit`` opcode. opcode.

pubpub constconst NEW_KERNEL_FRAME_MEMORY_STIPENDNEW_KERNEL_FRAME_MEMORY_STIPEND: u32u32 = 1u321u32 <<<< 2121;


This change adds a new constant


// 56 KB for new EVM frames is "free"// 56 KB for new EVM frames is "free"

pubpub constconst NEW_EVM_FRAME_MEMORY_STIPENDNEW_EVM_FRAME_MEMORY_STIPEND: u32u32 = 5656 * 1u321u32 <<<< 1010;


which is used as the memory stipend when calling the EVM simulator.


The logic for selecting the memory stipend in the out-of-circuit zk_evm is now as follows:


letlet memory_stipend memory_stipend = ifif address_is_kerneladdress_is_kernel(&address_for_nextaddress_for_next) {

zkevm_opcode_defszkevm_opcode_defs::::system_paramssystem_params::::NEW_KERNEL_FRAME_MEMORY_STIPENDNEW_KERNEL_FRAME_MEMORY_STIPEND

} elseelse {

ifif call_to_evm_simulator call_to_evm_simulator {


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 17


zkevm_opcode_defszkevm_opcode_defs::::system_paramssystem_params::::NEW_EVM_FRAME_MEMORY_STIPENDNEW_EVM_FRAME_MEMORY_STIPEND

} elseelse {

zkevm_opcode_defszkevm_opcode_defs::::system_paramssystem_params::::NEW_FRAME_MEMORY_STIPENDNEW_FRAME_MEMORY_STIPEND

}

};


Equivalent logic is implemented in the circuits to select the appropriate memory stipend.


Impact


Informational


This bug adds additional memory stipend for EVM simulator calls, but the amount is still relatively

small and thus does not introduce significant risk of abuse.


Recommendation


None


References


N/A


Remediation


Patched


This change was applied in commit 965841d3912d14a13600b2f399a661e0c1826b67 of matter
labs/zksync-protocol.


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 18


### #4 BUGFIX2-005 Fix in-circuit gas stipend passing

ID Summary Severity


Gas stipends were not being assigned to the new callee
BUGFIX2-005 Medium

frame in the circuits


Description


The EraVM supports configuring gas stipends which provide free gas to a callee that can not be

returned to the caller if unused. These are primarily used to offset overhead introduced by EraVM

system contracts or the EVM simulator. The stipend logic happens in two parts:


1. During the call, the stipend amount is computed and added to the gas amount to be passed to

the callee

2. During the return, the stipend is subtracted from the remaining gas before being returned to

the caller, masking it to zero if the result was negative.


After BUGFIX2-003, the EVM simulator stipend is removed, so the circuits once again always

determine gas stipends by performing a lookup on the callee address:


letlet [callee_stipendcallee_stipend, extra_ergs_from_caller_to_callee extra_ergs_from_caller_to_callee] =

cscs.perform_lookupperform_lookup::::<1, 2>(table_idtable_id, &[address_low_maskedaddress_low_masked.get_variableget_variable()]);

// ...// ...

letlet callee_stipend callee_stipend = unsafeunsafe { UInt32UInt32::::from_variable_uncheckedfrom_variable_unchecked(callee_stipecallee_stipe

ndnd) };

// ...// ...

letlet passed_ergs_if_pass passed_ergs_if_pass = passed_ergs_if_pass passed_ergs_if_pass.add_no_overflowadd_no_overflow(cscs, callee_s callee_s

tipendtipend);


Although the stipend was correctly increasing the gas passed to the callee, the stipend was never

assigned to the callee's stack frame object. As a result, the leftover stipend would incorrectly be

returned to the caller. An attacker could abuse this to generate infinite gas by repeatedly

extracting the leftover stipend.


The issue was fixed by simply assigning the stipend into the new stack frame during a far call:


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 19


// stipend// stipend

new_callstack_entrynew_callstack_entry.stipend stipend = callee_stipend callee_stipend;


Impact


Medium


The impact of this bug is limited because the out-of-circuit implementation correctly tracked the

stipend. As a result, the witness data for an exploit transaction would have to be specially crafted

and proved by a malicious prover.


The impact also depends on the size of the stipends. If the full stipends are guaranteed to be

consumed by the callee, it would be impossible to extract gas through this bug. Before BUGFIX2
003, the large EVM simulator stipend could likely be partially extracted, which increases the

severity of this bug.


Recommendation


The provided fix fully addresses this bug. We have no additional recommendations.


References


N/A


Remediation


Patched


The issue was fixed in commit 965841d3912d14a13600b2f399a661e0c1826b67 of matter
labs/zksync-protocol.


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 20


### Revision History

Version Date Description


.0 January 24, 2024 Initial version


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 21


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


© 2025 ChainLight, Theori. All rights reserved zkSync Era Security Audit | 22


