### **Auditing Report**

**Hardening Blockchain Security with Formal Methods**

#### **FOR**

### SP1

#### Veridise Inc. July 18, 2024


- **Prepared For:**


Succinct
```
https://www.succinct.xyz/

```

- **Prepared By:**


Shankara Pailoor
Tim Hoffman
Tyler Diamond


- **Contact Us:** `contact@veridise.com`


- **Version History:**


July 18, 2024 V2
July 08, 2024 V1
June 25, 2024 Initial Draft


**© 2024 Veridise Inc. All Rights Reserved.**


## **Contents**

**Contents** **iii**


**1** **Executive Summary** **1**


**2** **Project Dashboard** **5**


**3** **Audit Goals and Scope** **7**
3.1 Audit Goals . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 7
3.2 Audit Methodology & Scope . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 7
3.3 Classification of Vulnerabilities . . . . . . . . . . . . . . . . . . . . . . . . . . . . 8


**4** **Vulnerability Report** **9**
4.1 Detailed Description of Issues . . . . . . . . . . . . . . . . . . . . . . . . . . . . 10
4.1.1 V-SP1-VUL-001: verify_shard takes incorrect indexes . . . . . . . . . . . 10
4.1.2 V-SP1-VUL-002: Sponge state not set to 0 . . . . . . . . . . . . . . . . . . 12
4.1.3 V-SP1-VUL-003: Wrong SRS can be chosen . . . . . . . . . . . . . . . . . 13
4.1.4 V-SP1-VUL-004: Incorrect checks on deferred digest . . . . . . . . . . . . 14
4.1.5 V-SP1-VUL-005: Incorrect zero check of deferred_proof_digest . . . . . . 15
4.1.6 V-SP1-VUL-006: verify_shard does not range check shard indices . . . . 16
4.1.7 V-SP1-VUL-007: Gnark Poseidon Hash not reduced . . . . . . . . . . . . 17
4.1.8 V-SP1-VUL-008: Centralization Risk . . . . . . . . . . . . . . . . . . . . . 18
4.1.9 V-SP1-VUL-009: Unbalanced handling of I/O streams . . . . . . . . . . . 19
4.1.10 V-SP1-VUL-010: MulFConst documented incorrectly . . . . . . . . . . . 20
4.1.11 V-SP1-VUL-011: Two-step ownership is not used . . . . . . . . . . . . . . 21
4.1.12 V-SP1-VUL-012: Comments with typos and outdated information . . . . 22
4.1.13 V-SP1-VUL-013: Excess visibility . . . . . . . . . . . . . . . . . . . . . . . 23
4.1.14 V-SP1-VUL-014: Dead code . . . . . . . . . . . . . . . . . . . . . . . . . . 25
4.1.15 V-SP1-VUL-015: Use of magic constants . . . . . . . . . . . . . . . . . . . 26
4.1.16 V-SP1-VUL-016: Define function could panic instead of returning an error 28
4.1.17 V-SP1-VUL-017: Performance . . . . . . . . . . . . . . . . . . . . . . . . . 29
4.1.18 V-SP1-VUL-018: Duplicate name of variable and package . . . . . . . . . 31
4.1.19 V-SP1-VUL-019: Directory creation called after usage . . . . . . . . . . . 32


Veridise Audit Report: SP1 © 2024 Veridise Inc.


# **Executive Summary 1**

[Succinct engaged Veridise to audit the security of two codebases: sp1-contracts and the recursion](https://github.com/succinctlabs/sp1-contracts)
[circuits in SP1. The review was broken up into three sub-audits which took place over the course](https://github.com/succinctlabs/sp1)
of 7 weeks. The first audit focused on SP1’s recursive verifier and lasted from June 03, 2024 to June
17, 2024. The goal of this audit was to review changes made to the overall logic after a previous
informal audit Veridise performed a few months prior. Veridise conducted the assessment over
4 person-weeks, with 2 engineers reviewing code over 2 weeks on commit `[1049583](https://github.com/succinctlabs/sp1/commit/10495837c72f046aaccc81b81dc3c9055e3bf3a2)`, focusing
on the differences between the original commits reviewed: namely commits `[b6eac88](https://github.com/succinctlabs/sp1/commit/b6eac88baa500ee49b8016bcd8bbd62adb41f002)`, `[ab103ee](https://github.com/succinctlabs/sp1/commit/ab103ee5e70db6eab2d0ac049fb240cb4dccb839)`,
and `[02c6ea6](https://github.com/succinctlabs/sp1/commit/02c6ea68c07ce92ceaa0a426e91e66173eccaf49)` . The auditing strategy involved an extensive manual analysis of the source code
performed by Veridise engineers. Since the changes made to the recursion circuits should have
had corresponding changes made to the non-recursive verifiers and vice-versa, Veridise auditors
checked to see if the two sets of verifiers were consistent. In addition, the auditors compared
each circuit’s logic (which verifies STARK proofs) to an existing implementation of a STARK
[verifier; specifically, the Plonky3 FRI implementation which each circuit was based on.](https://github.com/Plonky3/Plonky3/tree/main/fri)


Next, on July 05, 2024, Veridise reviewed the Solidity smart contracts that can be deployed for
verifying SP1 proofs. This review required 2 engineers to review the code over 1 day on commit
[73c2a8d on the repository sp1-contracts.](ttps://github.com/succinctlabs/sp1-contracts/commit/73c2a8df0c816bf743e9d960e7b14b8e37635578)


Finally, on July 14, 2024, Veridise auditors reviewed additional changes made by Succinct to
the recursion circuits. This review required 2 engineers to review code over 4 days on commit
[6e968e3.](https://github.com/succinctlabs/sp1/commit/6e968e371791d657b1bb3929eab54a4f66365051)


**Project summary. (Recursion)** At a high level, the SP1 recursion circuit takes as input SP1
STARK proofs and generates a groth-16 proof (the recursive proof) attesting to the fact that the
[STARK proofs were verified. Writing such recursion circuits is common practice among zkVMs](https://dev.risczero.com/terminology#recursion-circuit)
to compress/compose multiple proofs so they can be verified efficiently. To write the circuit,
SP1 engineers developed a circuit IR as well as a builder interface to write circuits in the IR. In
addition, they wrote a compiler to compile the circuits into their own circuit assembly language
[which, in turn, can be translated into circuits in other frameworks like Gnark. Veridise engineers](https://github.com/Consensys/gnark)
were asked to re-audit the SP1 recursion circuit, focusing on the changes made to the circuit
since the original audit.


In particular, in commit `1049583`, the major changes made to the codebase were the following:


 - In `circuit/` the main changes were in `circuit/stark.rs` and `circuit/poseidon2.rs` . In

`stark.rs`, new checks were added to ensure the recursive verifier was in line with the
core SP1 verifier. In `poseidon2.rs`, the implementation was refactored to operate over the
BabyBear field whereas the old implementation was over BN254.

 - In `program/`, the recursive verifier in `recursion/program/` was refactored into 4 distinct

verifiers: a `core` verifier which verifies RISC-V execution traces, a `compress` verifier which
verifies recursion proofs, a `deferred` verifier which verifies compressed SP1 proofs,and
a `root` verifier which verifies the entrie tree of proofs. The main focus in this audit was


Veridise Audit Report: SP1 © 2024 Veridise Inc.


_2_ _1_ _Executive Summary_


ensuring that each verifier was enforcing the proper checks on the inputs, the circuit was
properly constrained, and public inputs were correctly committed to.

      - Most of the code in `recursion/gnark-ffi/go/sp1/` was not in scope for the previous audit

and was reviewed in the current one. The code was implementing BabyBear arithmetic in
Gnark over BN254. The main concerns were making sure the computation didn’t have
any overflow issues i.e, the computation exceeds the bounds of the BabyBear modulus
but is within the BN254 field.


Subsequently, in commit 6e968e3, the following major changes were made:


      - Shards no longer need to have a CPU table as the prover now supports off-chip computation

like GPU acceleration or custom precompiled circuits. As a result, the circuit now
distinguishes between executable shards which are generated from CPU execution and
non-executable shards which are not.

      - The prover supports sharded memory to speed up proving time. This requires keeping

track of address initialized and finalized for each shard.


**Project summary. (sp1-contracts)** The `sp1-contracts` repository consists of a set of Solidity
contracts which are used to verify SP1 proofs. The main contract is `SP1VerifierGateway.sol`
which maintains a set of SP1 verifiers. At a high level, SP1 verifiers can be registered through the
gateway and users can supply proofs for a specific SP1 project and the gateway will call the
appropriate verifier to verify the proofs.


**Code assessment. (Recursion)** The SP1 developers provided the SP1 recursion source code
for review. Most of the code appears to be originally designed and written by SP1 developers;
however, significant portions of the recursion circuits are based off Plonky3’s implementation
of FRI. The code base contains some documentation in the form of comments on functions and
data structures. To facilitate the Veridise auditors’ understanding of the code, the SP1 developers
had a kick-off meeting with the Veridise auditors to walk through different sections of the code,
particularly the changes made since the previous audit.


The source code contained a test suite, which the Veridise auditors noted covered many sections
of the intended behavior of the verifier and prover. However, the auditors feel the test suite can
be improved in two ways. First, there should be tests which cover the case where the verifier
handles multiple proof shards. Such tests would have quickly caught V-SP1-VUL-001 as the
verifier’s logic was incorrect whenever multiple shards were verified. Second, the test suite
could contain “negative” tests which try and check that a malicious prover cannot verify an
invalid proof. Tests of this type are very important for ZK applications as they can be used to
catch any major missing constraints.


The code was also well commented for the most part; however, in parts of the `gnark-ffi`
code, implicit assumptions were not well documented such as in V-SP1-VUL-007 where the
output of the Poseidon hash was not reduced to the BabyBear field; this was intentional but
not documented. V-SP1-VUL-009 describes a case where the `MulFConst` instruction appeared
to multiply a field element by an arbitrary constant, but in fact the code assumed that the
constant was constrained to be less than 16. While such assumptions were correct, the lack of
documentation could be a source of future bugs.


© 2024 Veridise Inc. Veridise Audit Report: SP1


_3_



Finally, we observed the code base used a large number of magic constants (see V-SP1-VUL-015)
even in cases where a corresponding global variable for that constant existed. The use of magic
constants can be a source of bugs especially when the underlying value represented by the
constant changes.


**Code assessment. (sp1-contracts)** The sp1-contracts also seemed to be originally designed
and written by the SP1 developers and their implementations are very simple as they essentially
hash the public inputs and then call the verifier contract to verify a zk proof. The code was well
commented and specified the expected behavior along with any implicit assumptions made by
the developers. The contracts also came with a test suite which exercised all external methods
and tested both expected success and failure scenarios.


While the contracts themselves were well written, the code that generated the verifier contracts,

namely `recursion/gnark-ffi/go/sp1/build.go` can be improved. For example, V-SP1-VUL-003
describes an issue where the type of verifier being generated depends on whether the string
"dev" appears in a data directory as opposed to explicitly requiring the user to specify the
working environment. As such, a test verifier with an insecurely generated structured reference
string could be used in a production setting. Moreover, all the code in the file is written within
a single function that is nearly 200 lines long. This should be refactored so that repeated
functionality is captured in individual functions.


**Summary of issues detected.** The audit uncovered 19 issues, 5 of which are assessed to be
of high or critical severity by the Veridise auditors. Specifically, V-SP1-VUL-001 describes an
issue where the `core` verifier incorrectly handled multiple shard proofs. As such, any attempt
to verify multiple shards would fail. V-SP1-VUL-002 describes a case where the initial sponge
state of the challenger was left unconstrained. By allowing the attacker to control the initial
state of the sponge, it becomes much easier for them to manipulate the output of the challenger.
The Veridise auditors also identified 1 medium-severity issue, V-SP1-VUL-006, where the `core`
verifier did not check the shard indices passed in. As such, a malicious prover could potentially
prove more than the maximum number of shards permitted (2 <sup>16</sup> ). The audit also uncovered
2 low-severity issues, 3 warnings, and 8 informational findings. The SP1 developers quickly
acknowledged issues during weekly syncs, and are fixing all of the medium and high issues.


**Recommendations.** While the audited code was well written and had several end-to-end
functional tests, the auditors observed several places where documentation and testing could be
improved as described in the Code assessment. (Recursion) section above. Documentation and
tests must be updated to accurately reflect the code as development continues on this codebase.
Finally, since large parts of the recursion circuit were based on Plonky3’s FRI implementation,
the auditors recommend that the developers watch for any bug reports involving the Plonky3
FRI implementation as such bugs could also appear in the recursion circuit.


**Disclaimer.** We hope that this report is informative but provide no warranty of any kind,
explicit or implied. The contents of this report should not be construed as a complete guarantee
that the system is secure in all dimensions. In no event shall Veridise or any of its employees be
liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise,
arising from, out of or in connection with the results reported here.


Veridise Audit Report: SP1 © 2024 Veridise Inc.


# **Project Dashboard 2**

**Table 2.1:** Application Summary.


**<u><mark>Name</mark></u>** **<u><mark>Version</mark></u>** **<u><mark>Type</mark></u>** **<u><mark>Platform</mark></u>**
<u><mark>SP1</mark></u> `1049583` <u><mark>Rust</mark></u> <u><mark>Desktop</mark></u>
<u><mark>sp1-contracts</mark></u> <u><mark>73c2a8d</mark></u> <u><mark>Solidity</mark></u> <u><mark>EVM</mark></u>
<mark>SP1</mark> <mark>6e968e3</mark> <mark>Rust</mark> <mark>Desktop</mark>


**Table 2.2:** Engagement Summary.


**<u><mark>Dates</mark></u>** **<u><mark>Method</mark></u>** **<u><mark>Consultants Engaged</mark></u>** **<u><mark>Level of Efort</mark></u>** **f**
<u><mark>June 03 - June 17, 2024</mark></u> <u><mark>Manual</mark></u> <u><mark>2</mark></u> <u><mark>4 person-weeks</mark></u>
<u><mark>July 05 - July 06, 2024</mark></u> <u><mark>Manual</mark></u> <u><mark>2</mark></u> <u><mark>2 person-days</mark></u>
<mark>July 14 - July 18, 2024</mark> <mark>Manual</mark> <mark>2</mark> <mark>4 person-days</mark>


**Table 2.3:** Vulnerability Summary.


**<u><mark>Name</mark></u>** **<u><mark>Number</mark></u>** **<u><mark>Acknowledged</mark></u>** **<u><mark>Fixed</mark></u>**
<u><mark>Critical-Severity Issues</mark></u> <u><mark>0</mark></u> <u><mark>0</mark></u> <u><mark>0</mark></u>
<u><mark>High-Severity Issues</mark></u> <u><mark>5</mark></u> <u><mark>5</mark></u> <u><mark>4</mark></u>
<u><mark>Medium-Severity Issues</mark></u> <u><mark>1</mark></u> <u><mark>1</mark></u> <u><mark>1</mark></u>
<u><mark>Low-Severity Issues</mark></u> <u><mark>2</mark></u> <u><mark>2</mark></u> <u><mark>0</mark></u>
<u><mark>Warning-Severity Issues</mark></u> <u><mark>3</mark></u> <u><mark>3</mark></u> <u><mark>1</mark></u>
<u><mark>Informational-Severity Issues</mark></u> <u><mark>8</mark></u> <u><mark>8</mark></u> <u><mark>3</mark></u>
<mark>TOTAL</mark> <mark>19</mark> <mark>19</mark> <mark>9</mark>


**Table 2.4:** Category Breakdown.


**<u><mark>Name</mark></u>** **<u><mark>Number</mark></u>**
<mark>Logic Error</mark> <mark>6</mark>
<mark>Maintainability</mark> <mark>5</mark>
<mark>Data Validation</mark> <mark>3</mark>
<mark>Access Control</mark> <mark>3</mark>
<mark>Documentation</mark> <mark>1</mark>
<u><mark>Gas Optimization</mark></u> <u><mark>1</mark></u>


Veridise Audit Report: SP1 © 2024 Veridise Inc.


# **Audit Goals and Scope 3**

#### **3.1 Audit Goals**

The engagement was initially scoped to provide a security assessment of SP1’s recursion-related
source code, particularly the security of the code changes made after the first audit. Afterwards,
the audit was exapnded to review the corresponding smart contracts. Overall in this audit we
sought to answer the following questions:


 - Do the recursive verifiers correctly commit to the public values used in the proofs?

 - Are the inputs to the proofs properly validated?

 - Do the recursion circuits contain any underconstrained vulnerabilities?

 - Does the `gnark-ffi` code properly perform BabyBear arithmetic within the BN254 prime?

In particular, are bounds being properly checked?

 - Are the recursion circuits’ logic consistent with existing STARK verifiers?

 - Are the cryptographic primitives used in the circuits implemented correctly?

 - Are the SP1 verifiers generated correctly? (sp1-contracts)

 - Are there any centralization risks associated with the contracts (sp1-contracts)

#### **3.2 Audit Methodology & Scope**


**Audit Methodology.** To address the questions above, our audit involved an extensive manual
analysis by Veridise auditors.


_Scope_ . The scope of the re-audit of the `recursion/` folder provided by the SP1 developers was
limited to the `compiler,` `program,` `and` `circuit` sub folders of `recursion/` . The purpose of each
subfolder is as follows:


 - **Compiler** : Details the intermediate language in which the recursive prover is written, and

exposes methods for building out a recursively-verified program.

 - **Program** : Implements a recursion circuit in the circuit DSL which verifies an SP1 STARK

proof.

 - **Circuit** : Implements a recursion circuit that is optimized for eventual compilation into

Gnark.


The audit of the `sp1-contracts/` repository was limited to the `src/contracts/` sub-directory
which contained the verifier interface along with their verifier gateway contract which is used
to manage and discharge proofs to different sp1 verifiers. The code to generate the verifiers
from the circuit was located in the sp1 repository under `recursion/gnark-ffi/assets/build.go`

```
recursion/

```

_Methodology_ . Veridise auditors first reviewed their prior audit of the code base and inspected
the source code diff between the previous version and the one in this audit. During the audit,


Veridise Audit Report: SP1 © 2024 Veridise Inc.


_8_ _3_ _Audit Goals and Scope_


Veridise auditors regularly met with the SP1 developers to ask questions about the code and
would frequently message the developers over Slack.

#### **3.3 Classification of Vulnerabilities**


When Veridise auditors discover a possible security vulnerability, they must estimate its severity

by weighing its potential impact against the likelihood that a problem will arise. Table 3.1 shows
how our auditors weigh this information to estimate the severity of a given issue.


**Table 3.1:** Severity Breakdown.


<u>Somewhat Bad</u> <u>Bad</u> <u>Very Bad</u> <u>Protocol Breaking</u>
<u>Not Likely</u> <u><mark>Info</mark></u> <u><mark>Warning</mark></u> <u><mark>Low</mark></u> <u><mark>Medium</mark></u>
<u>Likely</u> <u><mark>Warning</mark></u> <u><mark>Low</mark></u> <u><mark>Medium</mark></u> <u><mark>High</mark></u>
<u>Very Likely</u> <u><mark>Low</mark></u> <u><mark>Medium</mark></u> <u><mark>High</mark></u> <u><mark>Critical</mark></u>


In this case, we judge the likelihood of a vulnerability as follows in Table 3.2:


**Table 3.2:** Likelihood Breakdown


<u>Not Likely</u> <u>A small set of users must make a specific mistake</u>
Requires a complex series of steps by almost any user(s)
Likely              - OR <u>Requires a small set of users to perform an action</u>
Very Likely Can be easily performed by almost anyone


In addition, we judge the impact of a vulnerability as follows in Table 3.3:


**Table 3.3:** Impact Breakdown


<u>Somewhat Bad</u> <u>Inconveniences a small number of users and can be fixed by the user</u>
Affects a large number of people and can be fixed by the user
Bad             - OR <u>Afects a very small number of people and requires aid to ff</u> ix
Affects a large number of people and requires aid to fix
Very Bad            - OR Disrupts the intended behavior of the protocol for a small group of
<u>users through no fault of their own</u>
Protocol Breaking Disrupts the intended behavior of the protocol for a large group of
users through no fault of their own


© 2024 Veridise Inc. Veridise Audit Report: SP1


# **Vulnerability Report 4**

In this section, we describe the vulnerabilities found during our audit. For each issue found,
we log the type of the issue, its severity, location in the code base, and its current status (i.e.,
acknowledged, fixed, etc.). Table 4.1 summarizes the issues discovered:


**Table 4.1:** Summary of Discovered Vulnerabilities.


**<u><mark>ID</mark></u>** **<u><mark>Description</mark></u>** **<u><mark>Severity</mark></u>** **<u><mark>Status</mark></u>**
<mark>V-SP1-VUL-001</mark> <mark>verify_shard takes incorrect indexes</mark> <mark>High</mark> <mark>Fixed</mark>
<mark>V-SP1-VUL-002</mark> <mark>Sponge state not set to 0</mark> <mark>High</mark> <mark>Fixed</mark>
<mark>V-SP1-VUL-003</mark> <mark>Wrong SRS can be chosen</mark> <mark>High</mark> <mark>Acknowledged</mark>
<mark>V-SP1-VUL-004</mark> <mark>Incorrect checks on deferred digest</mark> <mark>High</mark> <mark>Fixed</mark>
<mark>V-SP1-VUL-005</mark> <mark>Incorrect zero check of deferred_proof_digest</mark> <mark>High</mark> <mark>Fixed</mark>
<mark>V-SP1-VUL-006</mark> <mark>verify_shard does not range check shard indices</mark> <mark>Medium</mark> <mark>Fixed</mark>
<mark>V-SP1-VUL-007</mark> <mark>Gnark Poseidon Hash not reduced</mark> <mark>Low</mark> <mark>Acknowledged</mark>
<mark>V-SP1-VUL-008</mark> <mark>Centralization Risk</mark> <mark>Low</mark> <mark>Open</mark>
<mark>V-SP1-VUL-009</mark> <mark>Unbalanced handling of I/O streams</mark> <mark>Warning</mark> <mark>Fixed</mark>
<mark>V-SP1-VUL-010</mark> <mark>MulFConst documented incorrectly</mark> <mark>Warning</mark> <mark>Acknowledged</mark>
<mark>V-SP1-VUL-011</mark> <mark>Two-step ownership is not used</mark> <mark>Warning</mark> <mark>Acknowledged</mark>
<mark>V-SP1-VUL-012</mark> <mark>Comments with typos and outdated information</mark> <mark>Info</mark> <mark>Fixed</mark>
<mark>V-SP1-VUL-013</mark> <mark>Excess visibility</mark> <mark>Info</mark> <mark>Fixed</mark>
<mark>V-SP1-VUL-014</mark> <mark>Dead code</mark> <mark>Info</mark> <mark>Fixed</mark>
<mark>V-SP1-VUL-015</mark> <mark>Use of magic constants</mark> <mark>Info</mark> <mark>Acknowledged</mark>
<mark>V-SP1-VUL-016</mark> <mark>Def</mark> i <mark>ne() may panic</mark> <mark>Info</mark> <mark>Acknowledged</mark>
<mark>V-SP1-VUL-017</mark> <mark>Performance</mark> <mark>Info</mark> <mark>Acknowledged</mark>
<mark>V-SP1-VUL-018</mark> <mark>Duplicate name of variable and package</mark> <mark>Info</mark> <mark>Acknowledged</mark>
<mark>V-SP1-VUL-019</mark> <mark>Directory creation called after usage</mark> <mark>Info</mark> <mark>Acknowledged</mark>


Veridise Audit Report: SP1 © 2024 Veridise Inc.


_10_ _4_ _Vulnerability Report_

#### **4.1 Detailed Description of Issues**


**4.1.1** **V-SP1-VUL-001: verify_shard takes incorrect indexes**


**<u><mark>Severity</mark></u>** <u><mark>High</mark></u> **<u><mark>Commit</mark></u>** <u><mark>1049583</mark></u>
**<u><mark>Type</mark></u>** <u><mark>Logic Error</mark></u> **<u><mark>Status</mark></u>** <u><mark>Fixed</mark></u>
**<u><mark>File(s)</mark></u>** <u><mark>`program/src/machine/{core`</mark></u> <u><mark>, compress, deferred,</mark></u> <u><mark>`root}.rs`</mark></u>
**<u><mark>Location(s)</mark></u>** <u><mark>multiple</mark></u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>8c0f501</mark>


The SP1 prover breaks up the proof of an execution trace into a collection of shard proofs which
are proofs about one chunk of the execution. The shard proofs are then verified in aggregate
by the verifier whereby each shard is itself verified via a call to `verify` <sup>`_`</sup> `shard` and the linking
between each shard is also verified.


The `verify` <sup>`_`</sup> `shard` implementation takes as input a `shard` <sup>`_`</sup> `idx` variable which indicates which
shard in the collection is being verified. This variable is effectively used as a boolean because it
is expected that certain instructions like `MemoryFinalize` and `MemoryInit` are used in the shard
iff `shard` <sup>`_`</sup> `idx` `=` `1` . This is seen in the below code snippet:


The recursive prover, which implements the verification of the shards as a circuit, incorrectly
assumes that the first shard in the batch has an index of 1. in general, the shards do not have to
start at 1, but can be any value in [0 _,_ 2 <sup>16</sup> ). As such, if the collection of shards passed in does not
start at 1, then the set of constraints will likely become unsatisfiable as the `verify` <sup>`_`</sup> `shard` will
assert that `MemoryFinalize` and `MemoryInit` be used even though they are not.


**Impact** The recursive verifier will not be able to produce a proof that a batch was verified for
any batch of shards that does not start at index 1.


**Recommendation** Replace `shard` <sup>`_`</sup> `idx` in the caller with the shard’s index.


**Developer Response** [The developers fixed the issue by removing the parameter and extracting](https://github.com/succinctlabs/sp1/commit/8c0f5010606f9c2306effe60412d421c23e88afa)
the shard index from the public values for the shard.


© 2024 Veridise Inc. Veridise Audit Report: SP1


_4.1_ _Detailed Description of Issues_ _11_

```
 1 if chip.name() == "MemoryProgram" {
 2 builder.if _ eq(shard _ idx, C::N::one()).then _ or _ else(
 3 |builder| {
 4 builder.assert _ var _ ne(index, C::N::from _ canonical _ usize(EMPTY));
 5 },
 6 |builder| {
 7 builder.assert _ var _ eq(index, C::N::from _ canonical _ usize(EMPTY));
 8 },
 9 );
10 }

11
12 if chip.name() == "MemoryInit" {
13 builder.if _ eq(shard _ idx, C::N::one()).then _ or _ else(
14 |builder| {
15 builder.assert _ var _ ne(index, C::N::from _ canonical _ usize(EMPTY));
16 },
17 |builder| {
18 builder.assert _ var _ eq(index, C::N::from _ canonical _ usize(EMPTY));
19 },
20 );
21 }

22
23 if chip.name() == "MemoryFinalize" {
24 builder.if _ eq(shard _ idx, C::N::one()).then _ or _ else(
25 |builder| {
26 builder.assert _ var _ ne(index, C::N::from _ canonical _ usize(EMPTY));
27 },
28 |builder| {
29 builder.assert _ var _ eq(index, C::N::from _ canonical _ usize(EMPTY));
30 },
31 );
32 }

```

**Snippet 4.1:** Snippet from `verify` <sup>`_`</sup> `shard`


Veridise Audit Report: SP1 © 2024 Veridise Inc.


_12_ _4_ _Vulnerability Report_


**4.1.2** **V-SP1-VUL-002: Sponge state not set to 0**


**<u><mark>Severity</mark></u>** <u><mark>High</mark></u> **<u><mark>Commit</mark></u>** <u><mark>1049583</mark></u>
**<u><mark>Type</mark></u>** <u><mark>Logic Error</mark></u> **<u><mark>Status</mark></u>** <u><mark>Fixed</mark></u>
**<u><mark>File(s)</mark></u>** <u><mark>`program/src/challenger.rs`</mark></u>
**<u><mark>Location(s)</mark></u>** <u><mark>new()</mark></u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>N/A</mark>


The `DuplexChallengerVariable` ’s constructor, shown below, is expected to produce a challenger
in a default state where the `sponge` <sup>`_`</sup> `state` is an array of zeros and `nb` <sup>`_`</sup> `inputs` and `nb` <sup>`_`</sup> `outputs` are
zero.

```
       1 pub fn new(builder: & mut Builder <C>) -> Self {
       2 DuplexChallengerVariable::<C> {
       3 sponge _ state: builder.dyn _ array(PERMUTATION _ WIDTH),
       4 nb _ inputs: builder.eval(C::N::zero()),
       5 input _ buffer: builder.dyn _ array(PERMUTATION _ WIDTH),
       6 nb _ outputs: builder.eval(C::N::zero()),
       7 output _ buffer: builder.dyn _ array(PERMUTATION _ WIDTH),
       8 }
       9 }

```

**Snippet 4.2:** Snippet from `new`


While the `nb` <sup>`_`</sup> `inputs` and `nb` <sup>`_`</sup> `outputs` are correctly set to zero, `sponge` <sup>`_`</sup> `state` is assigned an array

of felts whose values can be chosen arbitrarily by the prover. Allowing an attacker to have
complete control over the value set in the `sponge` <sup>`_`</sup> `state` gives them much more flexibility to
manipulate the outputs during `duplexing` .


**Recommendation** Add constraints that assert that each element of `sponge` <sup>`_`</sup> `state` is 0 .


**Developer Response** Developers have fixed the issue in the following PR `[https://github.](https://github.com/succinctlabs/sp1/pull/951)`

`[com/succinctlabs/sp1/pull/951](https://github.com/succinctlabs/sp1/pull/951)` .


© 2024 Veridise Inc. Veridise Audit Report: SP1


_4.1_ _Detailed Description of Issues_ _13_


**4.1.3** **V-SP1-VUL-003: Wrong SRS can be chosen**


**<u><mark>Severity</mark></u>** <u><mark>High</mark></u> **<u><mark>Commit</mark></u>** <u><mark>9494407</mark></u>
**<u><mark>Type</mark></u>** <u><mark>Data Validation</mark></u> **<u><mark>Status</mark></u>** <u><mark>Acknowledged</mark></u>
**<u><mark>File(s)</mark></u>** <u><mark>`gnark-ffi/go/sp1/build.go`</mark></u>
**<u><mark>Location(s)</mark></u>** <u><mark>Build()</mark></u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>N/A</mark>


The `Build()` function will construct the SRS depending upon whether the `dataDir` variable
contains the `dev` string. If `dataDir` _does_ contain the string, then an unsafe SRS is chosen that does
not provide security to the proving system

```
1 if !strings.Contains(dataDir, "dev") {
2 ...
3 } else {
4 srs, srsLagrange, err = unsafekzg.NewSRS(scs)
5 ...

```

**Snippet 4.3:** Snippet from `build.go`


This means that if _any_ directory along the filepath contains the string `dev` the unsafe SRS will be
used as opposed to using the real one.


**Impact** The incorrect (unsafe) SRS can be chosen for proof deployment, and this will lead to
breaking the soundness of verifiers that are deployed with this script.


**Recommendation** Pass a function parameter to `Build()`, or an environmental variable, to
determine if the test SRS should be used.


**Developer Response** The developers have acknowledged the issue but do not plan on fixing
it.


Veridise Audit Report: SP1 © 2024 Veridise Inc.


_14_ _4_ _Vulnerability Report_


**4.1.4** **V-SP1-VUL-004: Incorrect checks on deferred digest**


**<u><mark>Severity</mark></u>** <u><mark>High</mark></u> **<u><mark>Commit</mark></u>** <u><mark>6e968e3</mark></u>
**<u><mark>Type</mark></u>** <u><mark>Logic Error</mark></u> **<u><mark>Status</mark></u>** <u><mark>Fixed</mark></u>
**<u><mark>File(s)</mark></u>** <u><mark>`program/src/machine/{compress.rs`</mark></u> <u><mark>,</mark></u> <u><mark>`core.rs}`</mark></u>
**<u><mark>Location(s)</mark></u>** <u><mark>verify</mark></u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>N/A</mark>


The recursive verifiers need to check that if there is a deferred digest (i.e not zero), then it
remains the same across shards and is zero otherwise. However, the current implementation in
the `compress` and `core` verifiers only check that the first word of the digest remains the same as
seen below:

```
       1 // If ‘deferred _ proofs _ digest‘ is not zero, then ‘public _ values.
          deferred _ proofs _ digest
       2 // should be the current value.
       3 let is _ zero: Var< _ > = builder.eval(C::N::zero());
       4 #[allow(clippy::needless _ range _ loop)]
       5 for i in 0..deferred _ proofs _ digest.len() {
       6 let d = felt2var(builder, deferred _ proofs _ digest[i]);
       7 builder.if _ ne(d, C::N::zero()).then(|builder| {
       8 builder.assign(is _ zero, C::N::zero());
       9 });
       10 }
       11 builder.if _ eq(is _ zero, C::N::zero()).then(|builder| {
       12 builder.assert _ felt _ eq(
       13 deferred _ proofs _ digest[0],
       14 current _ public _ values.deferred _ proofs _ digest[0],
       15 );
       16 });

```

**Snippet 4.4:** Snippet from `verify` in `compress`


**Impact** By not checking the other elements, the other elements of the digest can be varied
while still satisfying the constraints. The concern is that an attacker could set the other digest
values in a way that would allow the final digest to be equal to the end_reconstruct_digest
during the completion check.


**Recommendation** Check that all the elements are the same.


**Developer Response** The developers have been acknowledged the issue.


© 2024 Veridise Inc. Veridise Audit Report: SP1


_4.1_ _Detailed Description of Issues_ _15_


**4.1.5** **V-SP1-VUL-005: Incorrect zero check of deferred_proof_digest**


**<u><mark>Severity</mark></u>** <u><mark>High</mark></u> **<u><mark>Commit</mark></u>** <u><mark>6e968e3</mark></u>
**<u><mark>Type</mark></u>** <u><mark>Logic Error</mark></u> **<u><mark>Status</mark></u>** <u><mark>Fixed</mark></u>
**<u><mark>File(s)</mark></u>** <u><mark>`program/src/machine/compress.rs`</mark></u>
**<u><mark>Location(s)</mark></u>** <u><mark>verify</mark></u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>f11e51a</mark>


The `compress` verifier performs a check (lines 473-479 ) to see if the previous `deferred` <sup>`_`</sup> `proofs` <sup>`_`</sup> `digest`

variable is zero as shown below. If it isn’t, then it asserts that the `deferred` <sup>`_`</sup> `proofs` <sup>`_`</sup> `digest` for
the current shard must equal the previous one.

```
 1 // If ‘deferred _ proofs _ digest‘ is not zero, then ‘public _ values.
    deferred _ proofs _ digest
 2 // should be the current value.
 3 let is _ zero: Var< _ > = builder.eval(C::N::zero());
 4 #[allow(clippy::needless _ range _ loop)]
 5 for i in 0..deferred _ proofs _ digest.len() {
 6 let d = felt2var(builder, deferred _ proofs _ digest[i]);
 7 builder.if _ ne(d, C::N::zero()).then(|builder| {
 8 builder.assign(is _ zero, C::N::zero());
 9 });
10 }
11 builder.if _ eq(is _ zero, C::N::zero()).then(|builder| {
12 builder.assert _ felt _ eq(
13 deferred _ proofs _ digest[0],
14 current _ public _ values.deferred _ proofs _ digest[0],
15 );
16 });

```

**Snippet 4.5:** Snippet from `verify`


However, the zero check is not correct as it initializes the `is` <sup>`_`</sup> `zero` variable to be 0 instead of 1.
Thus, the check always sets `is` <sup>`_`</sup> `zero` to be 0 even if the digest is actually zero.


**Impact** This forces all `deferred` <sup>`_`</sup> `proofs` <sup>`_`</sup> `digest` to be the same even if they aren’t.


**Recommendation** `is` <sup>`_`</sup> `zero` should be initialized to 1 not 0.


**Developer Response** The developers have been notified of the issue but have yet to respond
with acknowledgement or fixes.


Veridise Audit Report: SP1 © 2024 Veridise Inc.


_16_ _4_ _Vulnerability Report_


**4.1.6** **V-SP1-VUL-006: verify_shard does not range check shard indices**


**<u><mark>Severity</mark></u>** <u><mark>Medium</mark></u> **<u><mark>Commit</mark></u>** <u><mark>1049583</mark></u>
**<u><mark>Type</mark></u>** <u><mark>Data Validation</mark></u> **<u><mark>Status</mark></u>** <u><mark>Fixed</mark></u>
**<u><mark>File(s)</mark></u>** <u><mark>`program/src/machine/core.rs`</mark></u>
**<u><mark>Location(s)</mark></u>** <u><mark>verify()</mark></u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>N/A</mark>


The SP1 Verifier is designed to only verify at most 2 <sup>16</sup> shards; as such, each shard index should lie
in the half-open interval [0 _,_ 2 <sup>16</sup> ). However, the `verify()` procedure in `core.rs` does not perform
this range check on the shard indices.


**Impact** The recursive verifier allows proofs to be verified that are larger than the max number
of shards.


**Recommendation** Add a range check on each shard index to ensure it is within [0 _,_ 2 <sup>16</sup> ).


**Developer Response** Developers have acknowledged the issue.


© 2024 Veridise Inc. Veridise Audit Report: SP1


_4.1_ _Detailed Description of Issues_ _17_


**4.1.7** **V-SP1-VUL-007: Gnark Poseidon Hash not reduced**


**<u><mark>Severity</mark></u>** <u><mark>Low</mark></u> **<u><mark>Commit</mark></u>** <u><mark>1049583</mark></u>
**<u><mark>Type</mark></u>** <u><mark>Data Validation</mark></u> **<u><mark>Status</mark></u>** <u><mark>Acknowledged</mark></u>
**<u><mark>File(s)</mark></u>** <u><mark>`gnark-ffi/sp1/poseidon2`</mark></u> <sup><mark>`_`</mark></sup> <u><mark>`babybear.go`</mark></u>
**<u><mark>Location(s)</mark></u>** <u><mark>PermuteMut()</mark></u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>N/A</mark>


The SP1 developers wrote an implementation of the Poseidon hash function which in turn uses
field primitives such as `addF` and `mulF` implemented in `babybear.go` which (respectively) add
and multiply field elements. To optimize performance, the developers have implemented each
arithmetic operation to allow the resulting value to exceed the field modulus and only reduce
the value at a certain threshold. As such, the developers should make sure to note whether a
function’s result is intended to be non-reduced so that users of the function are aware and can
reduce the resulting value when necessary.


In particular, the hash implementation doesn’t reduce the resulting sponge state and there is no
documentation indicating that this was the intention. As such, a user of the Poseidon hash may
forget to reduce the resulting state.


**Impact** See above.


**Recommendation** Add documentation indicating that the resulting state is not reduced.


**Developer Response** Developers stated that not reducing the state was intentional but will
add documentation.


Veridise Audit Report: SP1 © 2024 Veridise Inc.


_18_ _4_ _Vulnerability Report_


**4.1.8** **V-SP1-VUL-008: Centralization Risk**


**<u><mark>Severity</mark></u>** <u><mark>Low</mark></u> **<u><mark>Commit</mark></u>** <u><mark>73c2a8d</mark></u>
**<u><mark>Type</mark></u>** <u><mark>Access Control</mark></u> **<u><mark>Status</mark></u>** <u><mark>Open</mark></u>
**<u><mark>File(s)</mark></u>** <u><mark>`SP1VerifierGateway.sol`</mark></u>
**<u><mark>Location(s)</mark></u>** <u><mark>See issue description</mark></u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>N/A</mark>


Similar to many projects, Succinct’s `SP1VerifierGateway` declare an administrator role that is
given special permissions. In particular, these administrators are given the following abilities:


      - The owner can add malicious verifiers to routes

      - The owner can freeze routes, preventing verification of proofs


**Impact** If a private key were stolen, a hacker would have access to sensitive functionality
that could compromise the project. For example, a malicious route could enable dependent
applications to verify invalid proofs that provide the hacker with unintended behavior.


**Recommendation** As these are all particularly sensitive operations, we would encourage the
developers to utilize a decentralized governance or multi-sig contract as opposed to a single
account, which introduces a single point of failure.


**Developer Response** The developers have been notified of the issue but have yet to respond
with acknowledgement or fixes.


© 2024 Veridise Inc. Veridise Audit Report: SP1


_4.1_ _Detailed Description of Issues_ _19_


**4.1.9** **V-SP1-VUL-009: Unbalanced handling of I/O streams**


**<u><mark>Severity</mark></u>** <u><mark>Warning</mark></u> **<u><mark>Commit</mark></u>** <u><mark>1049583</mark></u>
**<u><mark>Type</mark></u>** <u><mark>Logic Error</mark></u> **<u><mark>Status</mark></u>** <u><mark>Fixed</mark></u>
**<u><mark>File(s)</mark></u>** <u><mark>multiple</mark></u>
**<u><mark>Location(s)</mark></u>** <u><mark>multiple</mark></u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>N/A</mark>


At several locations, files are opened without being closed or closed more than once.


1. In `gnark-ffi/go/sp1/build.go`


a) `solidityVerifierFile` is not closed
b) `srsFile.Close()` is executed twice, once via the `defer` statement and once directly.

This occurs for two distinct variables with this same name, created at lines 67 and 85.
c) The file `srsLagrangeFileName` is opened at line 97 but is already available via the

variable `srsLagrangeFile` defined at line 55. The version opened at line 97 is also
closed twice.


2. In `gnark-ffi/go/sp1/prove.go`


a) `scsFile` is not closed
b) `pkFile` is not closed

c) `vkFile` is not closed


**Impact** Writing to a file stream without subsequently closing it can lose data that has been
buffered but not yet written when the program terminates.


**Recommendation** Ensure that each stream is closed exactly one time.


**Developer Response** Developers have applied the recommendation.


Veridise Audit Report: SP1 © 2024 Veridise Inc.


_20_ _4_ _Vulnerability Report_


**4.1.10** **V-SP1-VUL-010: MulFConst documented incorrectly**


**<u><mark>Severity</mark></u>** <u><mark>Warning</mark></u> **<u><mark>Commit</mark></u>** <u><mark>1049583</mark></u>
**<u><mark>Type</mark></u>** <u><mark>Documentation</mark></u> **<u><mark>Status</mark></u>** <u><mark>Acknowledged</mark></u>
**<u><mark>File(s)</mark></u>** <u><mark>`gnark-ffi/go/sp1/babybear/babybear.go`</mark></u>
**<u><mark>Location(s)</mark></u>** <u><mark>MulFConst()</mark></u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>N/A</mark>


The `babybear.go` file exposes a function called `MulFConst`, shown below, that multiplies a variable
with an integer. However, this function implicitly assumes that `0` `<=` `b` `<` `16` as the resulting
felt is assigned `NbBits` equal to `a.NbBits` `+` `4` . The developers informed the auditors that this
assumption was, in fact, intended and callers should only pass in values for `b` which fit in the
assumed range. Furthermore, the callers of this function seem to satisfy this assumption as all
uses of this function pass in values within this range.


Nevertheless, not making this assumption explicit in comments and not checking whether `b`
actually fits in this range can lead to issues down the road if new functionality is added which
forgets this assumption.

```
       1 func (c *Chip) MulFConst(a Variable, b int ) Variable {
       2 return c.ReduceFast(Variable{
       3 Value: c.api.Mul(a.Value, b),
       4 NbBits: a.NbBits + 4,
       5 })
       6 }

```

**Snippet 4.6:** Definition of `MulFConst()`


**Impact** Callers can mistakenly call this function and pass in a value for `b` which is larger than

`16` .


**Recommendation** Recommend changing the name of the function to `MulFSmallConst` and
adding an explicit check that `b` `<` `16` .


**Developer Response** Developers have acknowledged the issue.


© 2024 Veridise Inc. Veridise Audit Report: SP1


_4.1_ _Detailed Description of Issues_ _21_


**4.1.11** **V-SP1-VUL-011: Two-step ownership is not used**


**<u><mark>Severity</mark></u>** <u><mark>Warning</mark></u> **<u><mark>Commit</mark></u>** <u><mark>73c2a8d</mark></u>
**<u><mark>Type</mark></u>** <u><mark>Access Control</mark></u> **<u><mark>Status</mark></u>** <u><mark>Acknowledged</mark></u>
**<u><mark>File(s)</mark></u>** <u><mark>`SP1VerifierGateway.sol`</mark></u>
**<u><mark>Location(s)</mark></u>** <u><mark>See issue details</mark></u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>N/A</mark>


The `SP1VerifierGateway` contract inherits from OpenZeppelin’s `Ownable` contract. This contract
does require the receiving owner to acknowledge transfer of ownership.


**Impact** Specifying the wrong address for an ownership transfer will lead to loss of administrative functionality.


**Recommendation** Utilize ownership that requires the receiving owner to acknowledge the
transfer of ownership, such as OpenZeppelin’s `Ownable2Step` as seen here: `[https://github.com/](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable2Step.sol)`

`[OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable2Step.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable2Step.sol)` .


**Developer Response** The developers have been notified of the issue but have yet to respond
with acknowledgement or fixes.


Veridise Audit Report: SP1 © 2024 Veridise Inc.


_22_ _4_ _Vulnerability Report_


**4.1.12** **V-SP1-VUL-012: Comments with typos and outdated information**


**<u><mark>Severity</mark></u>** <u><mark>Info</mark></u> **<u><mark>Commit</mark></u>**
**<u><mark>Type</mark></u>** <u><mark>Maintainability</mark></u> **<u><mark>Status</mark></u>** <u><mark>Fixed</mark></u>
**<u><mark>File(s)</mark></u>** <u><mark>multiple</mark></u>
**<u><mark>Location(s)</mark></u>** <u><mark>multiple</mark></u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>N/A</mark>


The code documentation has typos or appears to be outdated in several locations.


1. In `program/src/machine/core.rs`


a) The documentation comment for `verify()` has several typos:


i. reprersents →represents
ii. shardf →shard
iii. reconstructiing →reconstructing

iv. chanllenger →challenger

v. Therefoee →Therefore
vi. assertds →asserts
vii. deffered →deferred


b) The `verify()` function contains a check if `shard` `==` `1` but the comment above says "If

the shard is zero" so that should be updated to match the implementation.

```
       1 // If the shard is zero, verify the global initial conditions hold on challenger and
          pc.
       2 let shard = felt2var(builder, public _ values.shard);
       3 builder.if _ eq(shard, C::N::one()).then(|builder| {

```

**Snippet 4.7:** Excerpt from `verify()`


c) On line 404 of `verify()` within `[compress.rs](http://compress.rs)` the following the comment `//` `Assert`

`that` `the` `leaf` `challenger` `is` `always` `the` `same.` doesn’t have corresponding code
underneath which implements it. Instead, the relevant code is on line 422 and so the
comment or code should be moved so they remain consistent.


**Impact** Unclear and/or outdated documentation makes the project harder to maintain.


**Recommendation** Apply the changes mentioned above.


**Developer Response** Developers have applied the recommendation.


© 2024 Veridise Inc. Veridise Audit Report: SP1


_4.1_ _Detailed Description of Issues_ _23_


**4.1.13** **V-SP1-VUL-013: Excess visibility**


**<u><mark>Severity</mark></u>** <u><mark>Info</mark></u> **<u><mark>Commit</mark></u>** <u><mark>1049583</mark></u>
**<u><mark>Type</mark></u>** <u><mark>Access Control</mark></u> **<u><mark>Status</mark></u>** <u><mark>Fixed</mark></u>
**<u><mark>File(s)</mark></u>** <u><mark>multiple</mark></u>
**<u><mark>Location(s)</mark></u>** <u><mark>multiple</mark></u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>N/A</mark>


The visibility modifiers should be more strict in the following locations:


1. `gnark-ffi/go/sp1/babybear/babybear.go`


a) Global value `MODULUS` should be private
b) Function `NegF()` should be private

c) Function `InvF()` should be private
d) Function `ReduceFast()` should be private

e) Function `ReduceWithMaxBits()` should be private

f) Function `ReduceHint()` should be private
g) Function `InvFHint()` should be private
h) Function `invEHint()` should be private


2. `gnark-ffi/go/sp1/poseidon2/constants.go`


a) Global value `RC3` should be private
b) Global value `RC16` should be private


3. `gnark-ffi/go/sp1/poseidon2/poseidon2` <sup>`_`</sup> `babybear.go`


a) Global value `BABYBEAR` <sup>`_`</sup> `NUM` <sup>`_`</sup> `EXTERNAL` <sup>`_`</sup> `ROUNDS` should be private
b) Global value `BABYBEAR` <sup>`_`</sup> `NUM` <sup>`_`</sup> `INTERNAL` <sup>`_`</sup> `ROUNDS` should be private


4. `gnark-ffi/go/sp1/poseidon2/poseidon2.go`


a) Global value `WIDTH` should be private
b) Global value `NUM` <sup>`_`</sup> `EXTERNAL` <sup>`_`</sup> `ROUNDS` should be private

c) Global value `NUM` <sup>`_`</sup> `INTERNAL` <sup>`_`</sup> `ROUNDS` should be private
d) Global value `DEGREE` should be private

e) Function `AddRc()` should be private

f) Function `SboxP()` should be private
g) Function `Sbox()` should be private


5. `gnark-ffi/go/sp1/poseidon2/utils.go`


a) Function `DiffusionPermuteMut()` should be private
b) Function `MatrixPermuteMut()` should be private


6. `gnark-ffi/go/sp1/sp1.go`


a) Global value `SRS` <sup>`_`</sup> `FILE` should be private
b) Global value `SRS` <sup>`_`</sup> `LAGRANGE` <sup>`_`</sup> `FILE` should be private

c) Global value `CONSTRAINTS` <sup>`_`</sup> `JSON` <sup>`_`</sup> `FILE` should be private
d) Global value `VERIFIER` <sup>`_`</sup> `CONTRACT` <sup>`_`</sup> `PATH` should be private

e) Global value `CIRCUIT` <sup>`_`</sup> `PATH` should be private

f) Global value `VK` <sup>`_`</sup> `PATH` should be private
g) Global value `PK` <sup>`_`</sup> `PATH` should be private


Veridise Audit Report: SP1 © 2024 Veridise Inc.


_24_ _4_ _Vulnerability Report_


7. `program/src/machine/utils.rs`


a) Function `calculate` <sup>`_`</sup> `public` <sup>`_`</sup> `values` <sup>`_`</sup> `digest()` should be private


**Impact** Excess visibility can create security risks such as modifying the internal state of a
structure in an inconsistent manner.


**Recommendation** Always apply the principle of least privilege when setting visibility modifiers. The violations mentioned above consider only uses within the `sp1` repository. Before
making the visibility adjustments, the developers must also consider external uses that were
not disclosed to the auditors.


**Developer Response** Developers have applied the recommendation.


© 2024 Veridise Inc. Veridise Audit Report: SP1


_4.1_ _Detailed Description of Issues_ _25_


**4.1.14** **V-SP1-VUL-014: Dead code**


**<u><mark>Severity</mark></u>** <u><mark>Info</mark></u> **<u><mark>Commit</mark></u>** <u><mark>1049583</mark></u>
**<u><mark>Type</mark></u>** <u><mark>Maintainability</mark></u> **<u><mark>Status</mark></u>** <u><mark>Fixed</mark></u>
**<u><mark>File(s)</mark></u>** <u><mark>multiple</mark></u>
**<u><mark>Location(s)</mark></u>** <u><mark>multiple</mark></u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>N/A</mark>


The following definitions are not used after being defined:


1. `gnark-ffi/go/sp1/babybear/babybear.go`


a) `var` `W`


2. `gnark-ffi/go/sp1/poseidon2/poseidon2.go`


a) `Poseidon2Chip.one`


3. `gnark-ffi/go/sp1/poseidon2/poseidon2` <sup>`_`</sup> `babybear.go`


a) `const` `BABYBEAR` <sup>`_`</sup> `DEGREE`


4. `gnark-ffi/go/sp1/sp1.go`


a) `var` `WITNESS` <sup>`_`</sup> `JSON` <sup>`_`</sup> `FILE` (the developers may have intended to use this in `build.go` )


**Impact** Definitions that are not used make the code messy and harder to maintain.


**Recommendation** Remove the unused definitions.


**Developer Response** Developers have applied the recommendation.


Veridise Audit Report: SP1 © 2024 Veridise Inc.


_26_ _4_ _Vulnerability Report_


**4.1.15** **V-SP1-VUL-015: Use of magic constants**


**<u><mark>Severity</mark></u>** <u><mark>Info</mark></u> **<u><mark>Commit</mark></u>** <u><mark>1049583</mark></u>
**<u><mark>Type</mark></u>** <u><mark>Maintainability</mark></u> **<u><mark>Status</mark></u>** <u><mark>Acknowledged</mark></u>
**<u><mark>File(s)</mark></u>** <u><mark>multiple</mark></u>
**<u><mark>Location(s)</mark></u>** <u><mark>multiple</mark></u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>N/A</mark>


The following locations use constant values whose meaning is not made clear:


1. `gnark-ffi/go/sp1/babybear/babybear.go`


a) In `ReduceFast()`, the value `120`
b) In `MulE()`, the value `11`


2. `gnark-ffi/go/sp1/sp1.go`


a) The `"Permute"` case uses the constant `3` but should use `poseidon2.WIDTH` instead.

Additionally, the implementation here should use two loops like the `"PermuteBabyBear`

`"` case does to be future-proof against changes to `poseidon2.WIDTH` .
b) The `"PermuteBabyBear"` case uses the value `16` in three locations but should use

`poseidon2.BABYBEAR` <sup>`_`</sup> `WIDTH` instead.


3. `program/src/machine/deferred.rs`


a) In the snippet below, the value `16` should be `2` `*` `DIGEST` <sup>`_`</sup> `SIZE`

```
       1 builder.set(& mut poseidon _ inputs, j * WORD _ SIZE + k + 16, element);

```

**Snippet 4.8:** Snippet from `verify()`


4. `program/src/hints.rs`


a) The last two parameters of `DuplexChallenger` should be `PERMUTATION` <sup>`_`</sup> `WIDTH,` `HASH` <sup>`_`</sup> `RATE`

instead of `16,` `8` . This occurs on the line `impl` `Hintable<C>` `for` `DuplexChallenger<`

`InnerVal,` `InnerPerm,` `16,` `8>` and three occurrences of the expression `DuplexChallenger`

`::<InnerVal,` `InnerPerm,` `16,` `8>::read(builder)` .


5. `program/src/stark.rs`


a) In `verify` <sup>`_`</sup> `shard()`, the loop over the machine chips uses the string literals `"CPU"`,

`"MemoryProgram"`, `"MemoryInit"`, and `"MemoryFinalize"` for the cases. These same
string literals are used in the Chip definitions and elsewhere in the code. New
constants should be declared for these string literals and all uses replaced with the
constants.


6. `program/src/machine/core.rs`


a) Every shard index should be between [0 _,_ 2 <sup>16</sup> ) and this is enforced via the range check

The range check on each shard is as follows: `builder.range` <sup>`_`</sup> `check` <sup>`_`</sup> `f(public` <sup>`_`</sup> `values.`

`shard,` `16);` which is correct but the constant `16` should be replaced with a constant
like `LOG` <sup>`_`</sup> `MAX` <sup>`_`</sup> `SHARD` <sup>`_`</sup> `IDX` .


**Impact** The meaning of an unnamed constant value is unclear.


© 2024 Veridise Inc. Veridise Audit Report: SP1


_4.1_ _Detailed Description of Issues_ _27_


**Recommendation** Add a comment documenting the meaning of the constant value or extract
the value into a constant declaration with a descriptive name.


**Developer Response** Developers have acknowledged the issues and plan to fix in the future.


Veridise Audit Report: SP1 © 2024 Veridise Inc.


_28_ _4_ _Vulnerability Report_


**4.1.16** **V-SP1-VUL-016: Define function could panic instead of returning an error**


**<u><mark>Severity</mark></u>** <u><mark>Info</mark></u> **<u><mark>Commit</mark></u>** <u><mark>1049583</mark></u>
**<u><mark>Type</mark></u>** <u><mark>Logic Error</mark></u> **<u><mark>Status</mark></u>** <u><mark>Acknowledged</mark></u>
**<u><mark>File(s)</mark></u>** <u><mark>`gnark-ffi/go/sp1/sp1.go`</mark></u>
**<u><mark>Location(s)</mark></u>** <u><mark>Def</mark></u> i <u><mark>ne()</mark></u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>N/A</mark>


The `"Num2BitsV"` and `"Num2BitsF"` cases of the `Define()` function convert an input value to a bit
array and then assign the elements of that bit array to positions in the `vars` map as defined by
the values of `cs.Args[0][i]` .

```
       1 case "Num2BitsV":
       2 numBits, err := strconv.Atoi(cs.Args[2][0])
       3 if err != nil {
       4 return fmt.Errorf("error converting number of bits to int: %v", err)
       5 }
       6 bits := api.ToBinary(vars[cs.Args[1][0]], numBits)
       7 for i := 0; i < len (cs.Args[0]); i++ {
       8 vars[cs.Args[0][i]] = bits[i]
       9 }
       10 case "Num2BitsF":
       11 bits := fieldAPI.ToBinary(felts[cs.Args[1][0]])
       12 for i := 0; i < len (cs.Args[0]); i++ {
       13 vars[cs.Args[0][i]] = bits[i]
       14 }

```

**Snippet 4.9:** Snippet from `Define()`


Both loops that perform the copies have iteration count equal to `len(cs.Args[0])` but do
not check if the `bits` array contains that many elements. If `len(cs.Args[0])` `>` `len(bits)`, the
program will panic with "runtime error: index out of range" rather than returning an `error`
from the `Define()` function. In the `"Num2BitsV"` case, `len(bits)==numBits` . In the `"Num2BitsF"`
case, `len(bits)==32` .


**Impact** The program will terminate abruptly rather than returning an `error` which can be
handled.


**Recommendation** Add checks for these conditions that return an `error` .


**Developer Response** The developers have been notified of the issue but have yet to respond
with acknowledgement or fixes.


© 2024 Veridise Inc. Veridise Audit Report: SP1


_4.1_ _Detailed Description of Issues_ _29_


**4.1.17** **V-SP1-VUL-017: Performance**


**<u><mark>Severity</mark></u>** <u><mark>Info</mark></u> **<u><mark>Commit</mark></u>** <u><mark>1049583</mark></u>
**<u><mark>Type</mark></u>** <u><mark>Gas Optimization</mark></u> **<u><mark>Status</mark></u>** <u><mark>Acknowledged</mark></u>
**<u><mark>File(s)</mark></u>** <u><mark>multiple</mark></u>
**<u><mark>Location(s)</mark></u>** <u><mark>multiple</mark></u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>N/A</mark>


Performance could be improved in the following locations:


1. `gnark-ffi/go/sp1/babybear/babybear.go`


a) In the snippet below from `ReduceWithMaxBits()`, the final line performs an array

access when the value is already stored in the local variable `remainder` . Avoid the
array access by using `remainder` in the final line shown in the snippet.

```
1 remainder := result[1]
2 p.rangeChecker.Check(remainder, 31)
3 p.api.AssertIsEqual(x, p.api. Add (p.api. Mul (quotient, MODULUS), result[1]))

```

**Snippet 4.10:** Snippet from `ReduceWithMaxBits()`


2. `gnark-ffi/go/sp1/poseidon2/utils.go`


a) In the snippet below from `MatrixPermuteMut()`, two calls to `Add()` are used to compute

the sum of three values. However, `Add()` is variadic so all three values could be
passed into a single call to avoid unnecessary intermediate structures.


3. `program/src/machine/core.rs`


a) The `verify()` function keeps a reference to the exit code from the first batch and then

generates assertions that every other batch has that same exit code. However, for
each batch it also adds an assertion that the exit code from the first batch is zero.

```
1 // Assert that exit code is the same for all proofs.
2 builder.assert _ felt _ eq(exit _ code, public _ values.exit _ code);

3
4 // Assert that the exit code is zero (success) for all proofs.
5 builder.assert _ felt _ eq(exit _ code, C::F::zero());

```

**Snippet 4.11:** Snippet from `verify()`


One assert for each batch could be avoided by directly asserting that every batch exit
code equals zero.


4. `program/src/utils.rs`


a) In `get` <sup>`_`</sup> `preprocessed` <sup>`_`</sup> `data()`, the `clone()` of the chip name is not necessary.


5. `program/src/fri/mod.rs`


a) In the snippet below, the second call to `clone()` is not necessary.


6. `program/src/stark.rs`


Veridise Audit Report: SP1 © 2024 Veridise Inc.


_30_ _4_ _Vulnerability Report_

```
       1 builder.poseidon2 _ compress _ x(
       2 & mut root.clone(),
       3 &root.clone(),
       4 &next _ height _ openings _ digest,
       5 );

```

**Snippet 4.12:** Snippet from `verify` <sup>`_`</sup> `batch()`


a) In `verify` <sup>`_`</sup> `shard()`, the loop over the machine chips contains multiple `if` statements

to check the value of the chip name. The conditions checked are mutually exclusive
of one another so they should use else branches to avoid checking the remaining
conditions once a match is found. In fact, all of the `"Memory*"` conditions have identical
bodies so the snippet below could be used.

```
       1 if chip.name() == "CPU" {
       2 builder.assert _ var _ ne(index, C::N::from _ canonical _ usize(EMPTY));
       3 } else if chip.name() == "MemoryProgram"
       4 || chip.name() == "MemoryInit"
       5 || chip.name() == "MemoryFinalize"
       6 {
       7 builder.if _ eq(shard _ idx, C::N::one()).then _ or _ else(
       8 |builder| {
       9 builder.assert _ var _ ne(index, C::N::from _ canonical _ usize(EMPTY));
       10 },
       11 |builder| {
       12 builder.assert _ var _ eq(index, C::N::from _ canonical _ usize(EMPTY));
       13 },
       14 );
       15 }

```

**Snippet 4.13:** Suggested code for the chip name conditions


7. `circuit/src/fri.rs`


a) The clone is not necessary in the following lines, in the second a reference is needed

when the clone is removed:

i. `for` `(batch` <sup>`_`</sup> `opening,` `round)` `in` `izip!(query` <sup>`_`</sup> `opening.clone(),` `&rounds)`
ii. `for` `(mat` <sup>`_`</sup> `opening,` `mat)` `in` `izip!(batch` <sup>`_`</sup> `opening.opened` <sup>`_`</sup> `values.clone(),` `mats`

```
                )
```

iii. `for` `(p` <sup>`_`</sup> `at` <sup>`_`</sup> `x,` `&p` <sup>`_`</sup> `at` <sup>`_`</sup> `z)` `in` `izip!(mat` <sup>`_`</sup> `opening.clone(),` `ps` <sup>`_`</sup> `at` <sup>`_`</sup> `z)`

iv. `let` `index` <sup>`_`</sup> `sibling:` `Var<` <sup>`_`</sup> `>` `=` `builder.eval(one` `-` `index` <sup>`_`</sup> `bits.clone()[offset`

```
                ])

```

**Developer Response** The developers have been notified of the issue but have yet to respond
with acknowledgement or fixes.


© 2024 Veridise Inc. Veridise Audit Report: SP1


_4.1_ _Detailed Description of Issues_ _31_


**4.1.18** **V-SP1-VUL-018: Duplicate name of variable and package**


**<u><mark>Severity</mark></u>** <u><mark>Info</mark></u> **<u><mark>Commit</mark></u>** <u><mark>9494407</mark></u>
**<u><mark>Type</mark></u>** <u><mark>Maintainability</mark></u> **<u><mark>Status</mark></u>** <u><mark>Acknowledged</mark></u>
**<u><mark>File(s)</mark></u>** <u><mark>`gnark-ffi/go/sp1/build.go`</mark></u>
**<u><mark>Location(s)</mark></u>** <u><mark>Build()</mark></u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>N/A</mark>


The `build.go` file imports `github.com/consensys/gnark/frontend/cs/scs`, which brings the module in scope and can therefore be referenced as `scs` . However, a variable is declared with the
same name:

```
1 scs, err := frontend.Compile(ecc.BN254.ScalarField(), scs.NewBuilder, &circuit)

```

**Snippet 4.14:** Snippet from `build.go`


**Impact** Although the correct code execution is performed, this introduces unnecessary
confusion and can harm maintainability for the future.


**Recommendation** Use a different name for the locally defined `scs` variable.


**Developer Response** The developers have been notified of the issue but have yet to respond
with acknowledgement or fixes.


Veridise Audit Report: SP1 © 2024 Veridise Inc.


_32_ _4_ _Vulnerability Report_


**4.1.19** **V-SP1-VUL-019: Directory creation called after usage**


**<u><mark>Severity</mark></u>** <u><mark>Info</mark></u> **<u><mark>Commit</mark></u>** <u><mark>9494407</mark></u>
**<u><mark>Type</mark></u>** <u><mark>Maintainability</mark></u> **<u><mark>Status</mark></u>** <u><mark>Acknowledged</mark></u>
**<u><mark>File(s)</mark></u>** <u><mark>`gnark-ffi/go/sp1/build.go`</mark></u>
**<u><mark>Location(s)</mark></u>** <u><mark>Build()</mark></u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>N/A</mark>


The `Build()` function requires reading or writing to various files and subdirectories in the

`dataDir` variable. One example is the `srsLagrangeFileName` :

```
       1 srsLagrangeFileName := dataDir + "/" + srsLagrangeFile
       2 srsLagrangeFile, err := os.Create(srsLagrangeFileName)
       3 if err != nil {
       4 log.Fatal("error creating srs file: ", err)
       5 panic (err)
       6 }

```

**Snippet 4.15:** Snippet from `build.go`


Later in the `build.go` file, the call to actually make this directory is defined:

```
       1 os.MkdirAll(dataDir, 0755)

```

**Snippet 4.16:** Snippet later in `build.go`


**Impact** Delaying the creation of the directory may cause the `build.go` script to panic prematurely.


**Recommendation** Move the directory creation call before any of the file reading and writing
is performed.


**Developer Response** The developers have been notified of the issue but have yet to respond
with acknowledgement or fixes.


© 2024 Veridise Inc. Veridise Audit Report: SP1


_4.1_ _Detailed Description of Issues_ _33_


Veridise Audit Report: SP1 © 2024 Veridise Inc.


