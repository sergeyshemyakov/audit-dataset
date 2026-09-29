### **Tooling Engagement Report**

**Hardening Blockchain Security with Formal Methods**

#### **FOR**

### ZKsync Airbender

#### Veridise Inc. February 16, 2026


Last updated date: April 22, 2026


`▶` **Prepared For:**


Matter Labs
[https://matter-labs.io/](https://matter-labs.io/)


`▶` **Prepared By:**


Shankara Pailoor
Daniel Dominguez
Ian Neal


`▶` **Contact Us:**


contact@veridise.com


`▶` **Version History:**


April 27, 2026 V1
April 22, 2026 Initial Draft


**© 2026 Veridise Inc. All Rights Reserved.**


## **Contents**

**Contents** **iii**


**1** **Executive Summary** **1**


**2** **Project Dashboard** **5**


**3** **Security Assessment Goals and Scope** **6**
3.1 Security Assessment Goals . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 6
3.2 Security Assessment Methodology & Scope . . . . . . . . . . . . . . . . . . . . 6
3.3 Classification of Vulnerabilities . . . . . . . . . . . . . . . . . . . . . . . . . . . . 8


**4** **Trust Model** **9**
4.1 Operational Assumptions . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 9


**5** **Vulnerability Report** **10**
5.1 Detailed Description of Issues . . . . . . . . . . . . . . . . . . . . . . . . . . . . 11
5.1.1 V-AIRBENDER-VUL-001: Missing ‘enforce_all()‘ in Unrolled ‘jump_branch_slt‘ Leaves Deferred Arithmetic Constraints Unenforced . . . . . 11
5.1.2 V-AIRBENDER-VUL-002: Unrolled Statement Verifier Only TranscriptBinds External Challenges for One Circuit Family . . . . . . . . . . . . . 13
5.1.3 V-AIRBENDER-VUL-003: Verifier Failed To Enforce Continuity of MachineState Permutation Challenges Across Proofs . . . . . . . . . . . . . . . . 16
5.1.4 V-AIRBENDER-VUL-004: Wrong Decoder Variable Breaks Binding of rs2
Bits to the Fetched Instruction . . . . . . . . . . . . . . . . . . . . . . . . 18
5.1.5 V-AIRBENDER-VUL-005: Out of bounds read while fetching instruction 19
5.1.6 V-AIRBENDER-VUL-006: Out of bounds reads and writes on RAM
abstraction . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 24


**6** **Fuzz Testing** **29**
6.1 Methodology . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 29
6.2 Fuzzer Execution Summary . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 30


**7** **Picus** **31**
7.1 Determinism . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 31
7.2 Methodology . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 31
7.3 Results . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 32
7.3.1 Circuits Requiring Customized Verification . . . . . . . . . . . . . . . . 33


**Glossary** **35**


Veridise Tool Engagement Report: ZKsync Airbender © 2026 Veridise Inc.


## **About Veridise**

Veridise is an independent security firm founded by academics and security researchers with
deep expertise in formal methods, programming languages, and applied cryptography. The
firm focuses on high-assurance security for blockchain and cryptographic systems, combining
rigorous theory with practical adversarial analysis.


Veridise provides full-stack blockchain security services spanning smart contracts, zeroknowledge circuits and proving systems, consensus and execution clients, cryptographic
libraries, and supporting infrastructure. The team routinely analyzes systems at the boundary
between protocol design, implementation, and cryptography, where failures are both subtle and
high-impact. To date, Veridise has conducted hundreds of security assessments for protocols
securing billions of dollars in TVL.


**Dynamic Security** Veridise treats security as an ongoing engineering discipline rather than a
one-time validation exercise. Effective security requires iterative review, continuous feedback,
and close collaboration between auditors and system designers. Throughout the engagement,
[Veridise analysts communicated regularly with the Matter Labs team using AuditHub, enabling](https://audithub.dev/)
rapid clarification of design intent, prompt discussion of findings, and efficient validation of
fixes.


In parallel with manual review, Veridise maintains active research programs focused on
automated and formal analysis of blockchain systems. These efforts have produced tools such
as _Vanguard_ for static analysis and _Picus_ for formal verification, which are available through
[AuditHub. AuditHub integrates these techniques directly into CI/CD workflows, supporting](https://audithub.dev/blockchain-security-platform/)
continuous vulnerability detection and regression analysis beyond the scope of a single audit.


[Additional details and case studies are available at https://audithub.dev/case-studies/.](https://audithub.dev/case-studies/)


**Veridise Reports** Veridise reports are published in the public audit archive linked below. Only
[reports obtained from this archive or confirmed directly by a representative of Veridise should](https://veridise.com)
be considered official Veridise reports.


[https://veridise.com/audits-archive/](https://veridise.com/audits-archive/)


Veridise Tool Engagement Report: ZKsync Airbender © 2026 Veridise Inc.


## **Executive Summary**
# **1**

From Feb. 16, 2026 to Apr. 15, 2026, Matter Labs engaged Veridise to conduct a tooling-based
security assessment of their RISC-V zkVM, ZKsync Airbender. Unlike a traditional end-toend code audit, this engagement emphasized formal constraint extraction and verification,
Picus-based determinism analysis, fuzzing-based testing of selected proving and execution
components, and targeted manual review of areas that were not fully covered by automation.


The assessment covered Picus-based determinism checks for selected unified proving and unrolled family circuits, together with fuzzing-based testing of the prover and related components.
Veridise conducted the assessment over 21 person-weeks, with 3 security analysts reviewing
[the project over 7 weeks on commit 5ecb674.](https://github.com/matter-labs/zksync-airbender/commit/5ecb67472a3110878417527398d7e3a43875e57c)


Where tool coverage was incomplete, or where the automated analysis surfaced potentially

security-relevant behavior, Veridise supplemented the tooling effort with focused manual review
of the relevant code paths. Accordingly, this engagement should be understood as a scoped
tooling and testing review with manual follow-up, rather than a comprehensive end-to-end
manual audit of the entire repository.


**Project Summary** ZKsync Airbender is a STARK-based RISC-V proving system that combines
a constrained RV32I+M-style execution model with a family of AIR circuits, a multi-stage
proving pipeline, and a recursive verification stack. The repository contains the core components
needed to compile, simulate, prove, and verify RISC-V execution traces for the ZKsync ecosystem,
including machine-operation circuits, circuit optimization/compiler infrastructure, witness
generation logic, CPU and GPU provers, generated single-circuit verifiers, and higher-level
statement verifiers that compose many chunk proofs into one execution claim.


At a high level, ZKsync Airbender proves execution by modeling a RISC-V machine over the
Mersenne31 field and enforcing instruction semantics with AIR constraints. Rather than keeping
a large monolithic CPU state in every row, the design pushes much of the global consistency
work into shared arguments: RAM/register accesses are enforced through a permutation-style
memory argument, delegation requests are handled through a separate set-equality-style
argument, and control-flow continuity is enforced through machine-state permutation logic.
This lets the system reduce the amount of explicit state carried inside each circuit while still
proving that all pieces describe one coherent execution.


_Circuit_ _Architecture._ In the context of this engagement, Airbender has two primary circuit
architectures, which Matter Labs referred to as unified and unrolled. The unified architecture is
centered on a reduced-machine circuit that is more suitable for recursive verification and higherlayer proof composition. The unrolled architecture specializes execution into opcode-family
circuits in order to improve proving efficiency at the base layer.


Rather than assigning one circuit per opcode, the unrolled architecture groups multiple related
opcodes into a single circuit family. For example, arithmetic-style instructions are grouped into
circuits such as add <sup>_</sup> sub <sup>_</sup> lui <sup>_</sup> auipc <sup>_</sup> mop, control-flow and comparison instructions are grouped
into jump <sup>_</sup> branch <sup>_</sup> slt, shift, binary, and CSR-related behavior is grouped into shift <sup>_</sup> binary <sup>_</sup> csr,
and memory operations are split across dedicated word and subword load/store families. These
grouped opcode-family circuits reduce wasted logic while still allowing the verifier to enforce
one coherent execution through shared memory, delegation, and machine-state arguments.


Veridise Tool Engagement Report: ZKsync Airbender © 2026 Veridise Inc.


_2_ _Executive Summary_


The two architectures are complementary layers of the same proving stack rather than mutually
exclusive alternatives. In the current pipeline, the base layer is proved with the unrolled
opcode-family circuits, the first recursion stage still uses a reduced unrolled configuration, and
a higher recursion stage uses the unified reduced-machine circuit. In other words, the unrolled
architecture is not limited to the base layer; it is also used in an intermediate recursion layer
before proofs are lifted into the unified recursion-friendly form.


_Prover and Verifier Pipeline._ ZKsync Airbender also contains a substantial proving and verification
pipeline around those circuits. A lightweight simulator/tracer executes programs and prepares
witness data, after which the prover runs a five-stage STARK workflow that commits trace
data, constructs lookup and permutation arguments, evaluates quotient polynomials, applies
DEEP/FRI reductions, and produces the final proof. The repository contains both CPU and
GPU proving paths, as well as generated verifier crates that verify individual circuit proofs and a
full-statement verifier that checks setup consistency, transcript consistency, accumulator closure,
final register/PC claims, and recursive chaining metadata across many proof fragments.


_Execution model and trust assumptions._ ZKsync Airbender also makes a deliberate trust-model
simplification: programs are proved against a fixed bytecode image that is preprocessed into ROM
and decoder tables, rather than against adversarial code loaded at runtime into generic executable
RAM. This allows some checks that might appear as explicit local decoder constraints in a more
general CPU arithmetization to instead be enforced through ROM preprocessing, opcode-family
partitioning, restricted machine configurations, and global consistency arguments; unsupported
behaviors are typically made unprovable rather than dynamically trapped. Delegation circuits
serve as protocol-level precompiles for operations such as bigint and hash-related logic, while
the recursive verifier path runs over a narrower machine profile specialized for proof verification
workloads.


In summary, ZKsync Airbender should be understood as a specialized proving architecture
that combines: (1) instruction-family AIR circuits, (2) global RAM/delegation/machine-state
arguments, (3) a chunked STARK/FRI prover, and (4) recursive full-statement verification. The
result is a system that can transform constrained RISC-V execution into efficiently provable
statements that are then recursively composed into higher-level zkSync proofs.


**Code Assessment.** The ZKsync Airbender developers provided the source code of the ZKsync
Airbender repository for review. The codebase appears to be largely original Rust code written
by the ZKsync Airbender developers, together with generated verifier artifacts and standard
third-party dependencies.


The repository contains substantial in-repo documentation, including top-level and crate-level
READMEs, architecture and design notes, repository-layout documentation, tutorials, and
end-to-end usage guidance. To facilitate the Veridise security analysts’ understanding of the
system, the ZKsync Airbender developers shared this documentation and also answered
targeted design and implementation questions during the engagement.


From a reviewability perspective, ZKsync Airbender is a sophisticated and highly optimized
proving system whose correctness depends on interactions across circuit builders, generated
verifier code, full-statement composition logic, recursion layers, and host-side tooling. As a
result, some important security and correctness properties are distributed across multiple layers
of the implementation rather than being obvious from any one local code path in isolation. This
increased the effort required to validate certain invariants and helps explain why relatively small
local mistakes could have broader soundness implications. It also affected the formal verification
workflow: in several places, the Veridise analysts needed to encode explicit environmental


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


_3_ _Executive Summary_


and trust assumptions in the Picus/LLZK model so that the automated analysis reflected
Airbender’s intended execution model rather than the raw constraints in isolation. Without
those assumptions, the extracted constraints could produce false positives that were outside the
system’s intended threat model.


The source code also contained a broad but primarily component-level test suite, including
unit tests across prover, simulator, verifier, and generated-circuit crates, as well as ISA tests
and recursive proving smoke tests. The repository’s CI configuration further indicates that the
developers use supporting engineering checks such as cargo fmt, cargo-deny, generated-artifact
consistency checks, and multiple build and test workflows.


**Summary of Issues Detected.** The security assessment uncovered 6 issues, of which 3 are
assessed to be of critical severity by the Veridise analysts. Specifically, the most severe findings
affected core proving soundness: one unrolled circuit omitted a required enforce <sup>_</sup> all() call,
leaving deferred arithmetic relations unconstrained and enabling forged branch, SLT, linkregister, and next-PC behavior (V-AIRBENDER-VUL-001); two additional verifier-composition
flaws allowed constituent proofs to be checked under inconsistent external Fiat-Shamir and
machine-state permutation challenges, undermining the soundness of the composed execution
claim (V-AIRBENDER-VUL-002, V-AIRBENDER-VUL-003).


The Veridise analysts identified one low-severity issue (V-AIRBENDER-VUL-004), in which
a decoder variable mismatch broke the binding of rs2 bits to the fetched instruction in a
currently unused circuit, as well as two warnings (V-AIRBENDER-VUL-005, V-AIRBENDERVUL-006) involving out-of-bounds instruction-fetch and RAM accesses in the transpiler VM

under conditions that violate Airbender’s trusted-bytecode assumptions. The ZKsync Airbender
developers resolved all critical findings during the engagement and acknowledged the remaining
lower-severity issues, which they did not prioritize for remediation because they either affect
currently unused code paths or fall outside the intended trusted-bytecode execution model.


**Summary of Verification Results.** A central focus of this engagement was the use of Picus to
perform formal determinism checks over extracted Airbender circuits, including per-opcode
specializations, individual operation implementations, parameterized operation families, and
selected delegation circuits. Across the analyzed targets, Picus initially verified 19 components,
falsified 2, and left 5 unresolved. The two falsified targets corresponded to genuine bugs in
the unrolled jump/branch/SLT circuit and the bytecode decoder (V-AIRBENDER-VUL-001, VAIRBENDER-VUL-004), both of which were later fixed and successfully re-verified. This brought

the final number of verified targets to 21, with the remaining unresolved cases concentrated in
larger whole-circuit and delegation-circuit analyses. We describe the results in more detail in
Chapter 7.


**Recommendations.** After this tooling-focused assessment, the Veridise analysts identified
steps that would materially improve assurance around ZKsync Airbender’s circuit and verifier
glue code.


_Consolidate verifier composition logic._ The unrolled and unified verifiers implement nearly identical
logic with minor variations, increasing the risk of inconsistent fixes and missed invariants as
seen in (V-AIRBENDER-VUL-003). Refactor shared functionality into common helpers or data
structures, and enforce critical invariants—such as challenge equality, transcript binding, and
accumulator continuity—through these abstractions rather than duplicated code.


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


_4_ _Executive Summary_


_Modularize large security-critical implementations._ Several parts of the codebase, especially in the
circuit-construction and verifier-composition layers, are implemented as large functions that
combine multiple logical responsibilities in one place. This increases review effort and makes it
harder to isolate which invariants are established locally versus assumed from surrounding
code. The Veridise analysts recommend gradually decomposing these large routines into
smaller modules with clearer interfaces and narrower responsibilities. This would improve
maintainability, make future fixes easier to apply consistently, and reduce the chance that local
changes have unintended effects on adjacent security-critical logic.


_Reduce API footguns in optimized circuit construction._ The missing enforce <sup>_</sup> all() issue suggests
that the current optimized-circuit API makes it too easy to accumulate deferred relations
and forget to materialize them. The developers should consider changing this interface so
that finalization is mandatory, as they once did previously with a drop guard which ensured

enforce <sup>_</sup> all() was called before the guard dropped.


_Continue integrating formal tooling into the development workflow._ This engagement found meaningful issues through Picus-based analysis, fuzzing, and targeted manual follow-up. The analysts
therefore recommend continuing to expand Picus coverage, preserving regression harnesses for
resolved findings, and rerunning these checks after circuit, verifier, or generator changes. For
a system as optimization-heavy as Airbender, automated regression checks provide stronger
long-term assurance than manual review alone.


**Disclaimer.** We hope that this report is informative but provide no warranty of any kind,
explicit or implied. The contents of this report should not be construed as a complete guarantee
that the system is secure in all dimensions. In no event shall Veridise or any of its employees be
liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise,
arising from, out of or in connection with the results reported here.


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


## **Project Dashboard**
# **2**

**Table 2.1:** Application Summary.


**<u><mark>Name</mark></u>** **<u><mark>Version</mark></u>** **<u><mark>Type</mark></u>** **<u><mark>Platform</mark></u>**
<mark>ZKsync Airbender</mark> 5ecb674 <mark>Rust</mark> <mark>RISC-V zkVM</mark>


**Table 2.2:** Engagement Summary.


**<u><mark>Dates</mark></u>** **<u><mark>Method</mark></u>** **<u><mark>Consultants Engaged</mark></u>** **<u><mark>Level of Efort</mark></u>** **f**
<mark>Feb. 16–Apr. 15, 2026</mark> <mark>Manual & Tools</mark> <mark>3</mark> <mark>21 person-weeks</mark>


**Table 2.3:** Vulnerability Summary.


**<u><mark>Name</mark></u>** **<u><mark>Number</mark></u>** **<u><mark>Acknowledged</mark></u>** **<u><mark>Fixed</mark></u>**
<u><mark>Critical-Severity Issues</mark></u> <u><mark>3</mark></u> <u><mark>3</mark></u> <u><mark>3</mark></u>
<u><mark>High-Severity Issues</mark></u> <u><mark>0</mark></u> <u><mark>0</mark></u> <u><mark>0</mark></u>
<u><mark>Medium-Severity Issues</mark></u> <u><mark>0</mark></u> <u><mark>0</mark></u> <u><mark>0</mark></u>
<u><mark>Low-Severity Issues</mark></u> <u><mark>1</mark></u> <u><mark>1</mark></u> <u><mark>0</mark></u>
<u><mark>Warning-Severity Issues</mark></u> <u><mark>2</mark></u> <u><mark>2</mark></u> <u><mark>0</mark></u>
<u><mark>Informational-Severity Issues</mark></u> <u><mark>0</mark></u> <u><mark>0</mark></u> <u><mark>0</mark></u>
<mark>TOTAL</mark> <mark>6</mark> <mark>6</mark> <mark>3</mark>


**Table 2.4:** Category Breakdown.


**<u><mark>Name</mark></u>** **<u><mark>Number</mark></u>**
<mark>Logic Error</mark> <mark>3</mark>
<mark>Memory safety</mark> <mark>2</mark>
<u><mark>Underconstrained Circuit</mark></u> <u><mark>1</mark></u>


**Table 2.5:** Picus Verification Outcome Summary.


**<u><mark>Category</mark></u>** **<u><mark>Count</mark></u>**
<u><mark>Circuits Initially Verif</mark></u> i <u><mark>ed</mark></u> <u><mark>19</mark></u>
<u><mark>Circuits Initially Falsif</mark></u> i <u><mark>ed</mark></u> <u><mark>2</mark></u>
<u><mark>Unknown</mark></u> <u><mark>5</mark></u>
<u><mark>Verif</mark></u> i <u><mark>ed After Fix</mark></u> <u><mark>2</mark></u>
<u><mark>Total Verif</mark></u> i <u><mark>ed</mark></u> <u><mark>21</mark></u>
<mark>TOTAL</mark> <mark>26</mark>


Veridise Tool Engagement Report: ZKsync Airbender © 2026 Veridise Inc.


## **Security Assessment Goals and Scope**
# **3**

#### **3.1 Security Assessment Goals**

The engagement was scoped as a tooling-focused security assessment of ZKsync Airbender’s
source code rather than a comprehensive end-to-end manual audit of the entire repository.
The primary objective was to apply and extend formal verification, static analysis, and fuzzing
workflows to selected Airbender circuits and supporting proving infrastructure, and to use
targeted manual review to validate and interpret the behaviors surfaced by those tools. In
particular, the assessment focused on selected circuit logic, proving and verification components,
and bytecode-execution tooling relevant to the agreed Picus and fuzzing workstreams.


During the assessment, the security analysts aimed to answer questions such as:


`▶` Are selected Airbender circuits deterministic and free of underconstrained behavior under

the system’s intended execution and trust assumptions?

`▶` Can the planned fuzzing campaigns uncover crashes, malformed states, unexpected

transcript behavior, or other security-relevant deviations in selected executor and prover
components?

`▶` Do selected proving and verification components behave consistently with the protocol’s

intended trust assumptions and execution model when analyzed through automated
tooling and targeted manual validation?

`▶` Where automated analysis is inconclusive or requires additional assumptions, what

manual follow-up is necessary to distinguish real security issues from behaviors outside
the intended threat model?

#### **3.2 Security Assessment Methodology & Scope**


To address the questions above, the security assessment combined automated formal methods,
static analysis, dynamic testing, and targeted manual review. In particular, the assessment relied
on the following techniques:


`▶` _Formal verification._ [Security analysts used Picus to analyze determinism and related under-](https://audithub.dev/picus-zk-circuit-formal-verification/)

constraint risks in selected Airbender circuits and extracted LLZK models. Picus was
used both to prove determinism where feasible and to identify cases where additional
modeling assumptions or manual review were required. More details about how Picus
was used are provided in Chapter 7.

`▶` _Fuzzing/property-based testing._ Security analysts developed and ran fuzzing and invariant
based tests for selected bytecode-execution, prover, and verifier-adjacent components to
determine whether they could deviate from expected behavior, crash, or violate important
correctness properties. Additional detail on this testing effort is provided in the dedicated
fuzzing section of this report.

`▶` _Targeted manual review._ Security analysts performed focused manual review of selected

circuits, verifier-composition logic, and related proving components to validate design
assumptions, investigate suspicious behaviors surfaced by tooling, and assess exploitability


Veridise Tool Engagement Report: ZKsync Airbender © 2026 Veridise Inc.


_7_ _Security Assessment Goals and Scope_


of identified issues. This manual work was selective and tool-guided rather than a complete
line-by-line review of the full repository.


_Scope_ . The scope of this security assessment is best understood in terms of the specific tooling
workstreams defined for the engagement, rather than as a uniform review of the entire ZKsync
Airbender repository.


For the formal-methods portion of the engagement, the scope centered on Picus/LLZK-based
determinism analysis of selected Airbender circuit components. This included extractor development, selected unrolled instruction-family circuits, selected legacy instruction implementations,
selected whole-circuit state-transition logic, and selected delegation/precompile components,
with targeted manual follow-up where full automation was incomplete or required additional
assumptions. In particular, the circuits defined in the following files were in scope:


1. cs/src/machine/ops/unrolled/decoder/decoder <sup>_</sup> circuit.rs (untrusted bytecode decoder)
2. cs/src/machine/ops/unrolled/add <sup>_</sup> sub <sup>_</sup> lui <sup>_</sup> auipc <sup>_</sup> mop.rs (apply <sup>_</sup> add <sup>_</sup> sub <sup>_</sup> lui <sup>_</sup> auipc <sup>_</sup> mop
)
3. cs/src/machine/ops/unrolled/jump <sup>_</sup> branch <sup>_</sup> slt.rs (apply <sup>_</sup> jump <sup>_</sup> branch <sup>_</sup> slt)
4. cs/src/machine/ops/unrolled/load <sup>_</sup> store <sup>_</sup> subword <sup>_</sup> only.rs (apply <sup>_</sup> subword <sup>_</sup> only <sup>_</sup> load <sup>_</sup> store
)
5. cs/src/machine/ops/unrolled/load <sup>_</sup> store <sup>_</sup> word <sup>_</sup> only.rs (apply <sup>_</sup> word <sup>_</sup> only <sup>_</sup> load <sup>_</sup> store)
6. cs/src/machine/ops/unrolled/load <sup>_</sup> store.rs (apply <sup>_</sup> load <sup>_</sup> store)
7. cs/src/machine/ops/unrolled/mul <sup>_</sup> div.rs (apply <sup>_</sup> mul <sup>_</sup> div)
8. cs/src/machine/ops/unrolled/shift <sup>_</sup> binary <sup>_</sup> csr.rs (apply <sup>_</sup> shift <sup>_</sup> binop <sup>_</sup> csrrw)
9. cs/src/machine/ops/unrolled/reduced <sup>_</sup> machine <sup>_</sup> ops.rs (apply <sup>_</sup> reduced <sup>_</sup> machine <sup>_</sup> circuit
and reduced-machine sequencing logic)
10. cs/src/machine/ops/add <sup>_</sup> sub.rs (AddOp and SubOp)
11. cs/src/machine/ops/binops.rs (BinaryOp)
12. cs/src/machine/ops/shift.rs (ShiftOp)
13. cs/src/machine/ops/mul <sup>_</sup> div.rs (MulOp and DivRemOp)
14. cs/src/machine/ops/load.rs (LoadOp)
15. cs/src/machine/ops/conditional.rs (ConditionalOp)
16. cs/src/machine/ops/store.rs (StoreOp)
17. cs/src/machine/ops/lui <sup>_</sup> auipc.rs (LuiOp and AuiPc)
18. cs/src/machine/ops/jump.rs (JumpOp)
19. cs/src/machine/ops/mop.rs (MopOp)
20. cs/src/machine/machine <sup>_</sup> configurations/full <sup>_</sup> isa <sup>_</sup> no <sup>_</sup> exceptions/optimized <sup>_</sup> state <sup>_</sup> transition

.rs (optimized <sup>_</sup> base <sup>_</sup> isa <sup>_</sup> state <sup>_</sup> transition)
21. cs/src/delegation/bigint <sup>_</sup> with <sup>_</sup> control/mod.rs
22. cs/src/delegation/blake2 <sup>_</sup> round <sup>_</sup> with <sup>_</sup> extended <sup>_</sup> control/mod.rs
23. cs/src/delegation/blake2 <sup>_</sup> single <sup>_</sup> round/mod.rs
24. cs/src/delegation/keccak <sup>_</sup> special5/mod.rs


For the fuzzing and dynamic-testing workstreams, the scope was narrower and split between
execution-oriented testing and prover-oriented testing. On the execution side, the assessment
covered the bytecode/VM pipeline, including differential fuzzing against a Unicorn-based oracle
and crash-oriented testing of executor and transpiler behavior. On the prover side, the assessment
covered selected unrolled prover stages under prover/src/prover <sup>_</sup> stages/unrolled <sup>_</sup> prover/,
including mod.rs, stage2.rs, stage <sup>_</sup> 2 <sup>_</sup> shared.rs, stage <sup>_</sup> 2 <sup>_</sup> ram <sup>_</sup> shared.rs, stage3.rs, and the
quotient-part logic under prover/src/prover <sup>_</sup> stages/unrolled <sup>_</sup> prover/quotient <sup>_</sup> parts/. These


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


_8_ _Security Assessment Goals and Scope_


campaigns emphasized crash detection, malformed-state discovery, invariant checking, behaviors related to prover correctness, and differential validation of execution behavior against an
external oracle (Unicorn). See Chapter 6 for more details.


Where these tooling efforts surfaced potentially security-relevant behavior, the Veridise analysts

also performed targeted manual review of code which was unable to be verified by Picus, and
core verifier logic to make sure that assumptions made in the Picus verification effort were
actually enforced by the verifier. Components outside these defined workstreams were not
reviewed exhaustively.

#### **3.3 Classification of Vulnerabilities**


When Veridise security analysts discover a possible security vulnerability, they must estimate

its severity by weighing its potential impact against the likelihood that a problem will arise.


The severity of a vulnerability is evaluated according to the Table 3.1.


**Table 3.1:** Severity Breakdown.


<u>Somewhat Bad</u> <u>Bad</u> <u>Very Bad</u> <u>Protocol Breaking</u>
<u>Not Likely</u> <u><mark>Info</mark></u> <u><mark>Warning</mark></u> <u><mark>Low</mark></u> <u><mark>Medium</mark></u>
<u>Likely</u> <u><mark>Warning</mark></u> <u><mark>Low</mark></u> <u><mark>Medium</mark></u> <u><mark>High</mark></u>
<u>Very Likely</u> <u><mark>Low</mark></u> <u><mark>Medium</mark></u> <u><mark>High</mark></u> <u><mark>Critical</mark></u>


The likelihood of a vulnerability is evaluated according to the Table 3.2.


**Table 3.2:** Likelihood Breakdown


<u>Not Likely</u> <u>A small set of users must make a specific mistake</u>
Requires a complex series of steps by almost any user(s)
Likely              - OR <u>Requires a small set of users to perform an action</u>
Very Likely Can be easily performed by almost anyone


The impact of a vulnerability is evaluated according to the Table 3.3:


**Table 3.3:** Impact Breakdown


<u>Somewhat Bad</u> <u>Inconveniences a small number of users and can be fixed by the user</u>
Affects a large number of people and can be fixed by the user
Bad             - OR <u>Afects a very small number of people and requires aid to ff</u> ix
Affects a large number of people and requires aid to fix
Very Bad            - OR Disrupts the intended behavior of the protocol for a small group of
<u>users through no fault of their own</u>
Protocol Breaking Disrupts the intended behavior of the protocol for a large group of
users through no fault of their own


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


## **Trust Model**
# **4**

#### **4.1 Operational Assumptions**

In addition to assuming that out-of-scope components behave correctly, Veridise analysts
assumed the following properties when modeling security for ZKsync Airbender.


`▶` The bytecode/ROM image being proved is fixed in advance and correctly preprocessed

into the ROM and decoder tables expected by the circuits. Airbender does not model
arbitrary runtime-loaded executable code in generic RAM.

`▶` For the Picus/LLZK work stream, the global permutation-style arguments used to connect

rows and circuit families were treated as trusted outer mechanisms. In particular, the
formal verification work assumed the memory-permutation machinery and related outer
proof-system checks correctly enforce cross-row and cross-circuit memory consistency.

`▶` Similarly, the machine-state and other shared cross-proof consistency arguments enforced

by the outer proving system were treated as correct unless they were explicitly brought into
scope by targeted manual review. The formal-methods work therefore focused primarily
on determinism and local under-constraint properties of the selected circuit logic rather
than re-proving the full soundness of the outer composition layer.

`▶` Airbender’s circuit model does not attempt to support every behavior of a fully general

RISC-V machine. Some behaviors are intentionally excluded for efficiency (signed division), and others are assumed not to occur under the expected compiler and execution
environment. In many such cases, the intended behavior is that execution becomes
unprovable rather than being handled through explicit in-circuit trap logic.

`▶` Some inputs to the verification pipeline, including non-deterministic advice values and

setup-related data, are provided externally rather than being fixed directly in the verifier
code. The security model therefore assumes that these inputs are supplied consistently
with the intended proving statement, and that any downstream system relying on final
output commitments to identify the proven program or setup validates those commitments
correctly.


Veridise Tool Engagement Report: ZKsync Airbender © 2026 Veridise Inc.


## **Vulnerability Report**
# **5**

This section presents the vulnerabilities found during the security assessment. For each issue
found, the type of the issue, its severity, location in the code base, and its current status (i.e.,
acknowledged, fixed, etc.) is specified. Table 5.1 summarizes the issues discovered:


**<u>Table 5.1:</u>** <u>Summary of Discovered Vulnerabilities.</u>
**<u><mark>ID</mark></u>** **<u><mark>Description</mark></u>** **<u><mark>Severity</mark></u>** **<u><mark>Status</mark></u>**
<mark>V-AIRBENDER-VUL-001</mark> <mark>Missing ‘enforce_all()‘ in Unrolled . . .</mark> <mark>Critical</mark> <mark>Fixed</mark>
<mark>V-AIRBENDER-VUL-002</mark> <mark>Unrolled Statement Verif</mark> i <mark>er Only . . .</mark> <mark>Critical</mark> <mark>Fixed</mark>
<mark>V-AIRBENDER-VUL-003</mark> <mark>Verif</mark> i <mark>er Failed To Enforce Continuity of . . .</mark> <mark>Critical</mark> <mark>Fixed</mark>
<mark>V-AIRBENDER-VUL-004</mark> <mark>Wrong Decoder Variable Breaks Binding . . .</mark> <mark>Low</mark> <mark>Acknowledged</mark>
<mark>V-AIRBENDER-VUL-005</mark> <mark>Out of bounds read while fetching instruction</mark> <mark>Warning</mark> <mark>Acknowledged</mark>
<mark>V-AIRBENDER-VUL-006</mark> <mark>Out of bounds reads and writes on RAM . . .</mark> <mark>Warning</mark> <mark>Acknowledged</mark>


Veridise Tool Engagement Report: ZKsync Airbender © 2026 Veridise Inc.


_11_ _Vulnerability Report_

#### **5.1 Detailed Description of Issues**


**5.1.1** **V-AIRBENDER-VUL-001: Missing ‘enforce_all()‘ in Unrolled**
**‘jump_branch_slt‘ Leaves Deferred Arithmetic Constraints Unenforced**


**<u><mark>Severity</mark></u>** <u><mark>Critical</mark></u> **<u><mark>Commit</mark></u>** <u><mark>5ecb674</mark></u>
**<u><mark>Type</mark></u>** <u><mark>Underconstrained Circuit</mark></u> **<u><mark>Status</mark></u>** <u><mark>Fixed</mark></u>
**<u><mark>Location(s)</mark></u>** <u><mark>cs/src/machine/ops/unrolled/[...]/jump</mark></u> <sup><mark>_</mark></sup> <u><mark>slt</mark></u> <sup><mark>_</mark></sup> <u><mark>branch.rs:364</mark></u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>[zksync-airbender/pull/212, 77e979ed](https://github.com/matter-labs/zksync-airbender/pull/212)</mark>


**Description** In the affected version of the unrolled jump <sup>_</sup> branch <sup>_</sup> slt family circuit,

apply <sup>_</sup> jump <sup>_</sup> branch <sup>_</sup> slt() built the family logic through an OptimizationContext but did not
call opt <sup>_</sup> ctx.enforce <sup>_</sup> all(cs) before consuming the derived outputs. This is critical because the
family relies on deferred optimized relations for its core semantics:


`▶` branch/SLT comparison results via append <sup>_</sup> sub <sup>_</sup> relation() (line 106),

`▶` JAL/JALR link-register value (pc + 4) via append <sup>_</sup> add <sup>_</sup> relation() (line 140),

`▶` next-PC computation for SLT/SLTI, JAL/JALR, and taken/skipped branches via repeated

append <sup>_</sup> add <sup>_</sup> relation() (line 251).


Crucially, the optimization context does not immediately emit the final arithmetic constraints,
but only materializes them using OptimizationContext::enforce <sup>_</sup> all() (line 1803). If that call is
omitted, the comparison registers, carry/overflow flags, and next-PC scratch registers are no
longer tied to the intended arithmetic over rs1, rs2, imm, and pc.


As a result, a malicious prover can:


`▶` forge branch comparison outcomes and therefore choose taken vs not-taken behavior

inconsistent with the real operands,

`▶` forge SLT/SLTI results by driving the comparison witness into a desired condition-lookup

output,

`▶` forge JAL/JALR link-register writes because the shared pc + 4 scratch register is uncon
strained,

`▶` forge the cycle-end PC:


        - for JAL/JALR and taken branches, to an arbitrary aligned target subject only to the
residual cleanup constraint,

        - for SLT/SLTI and skipped branches, to an arbitrary 32-bit value rather than the
required pc + 4.


**Recommendation** Add opt <sup>_</sup> ctx.enforce <sup>_</sup> all after cs.set <sup>_</sup> values(value <sup>_</sup> fn) in the
function.


**Impact** As described above, a malicious prover can:


`▶` forge branch comparison outcomes and therefore choose taken vs not-taken behavior

inconsistent with the real operands,

`▶` forge SLT/SLTI results by driving the comparison witness into a desired condition-lookup

output,


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


_12_ _Vulnerability Report_


`▶` forge JAL/JALR link-register writes because the shared pc + 4 scratch register is uncon
strained,

`▶` forge the cycle-end PC:


        - for JAL/JALR and taken branches, to an arbitrary aligned target subject only to the
residual cleanup constraint,

        - for SLT/SLTI and skipped branches, to an arbitrary 32-bit value rather than the
required pc + 4.


**Developer Response** The developers have applied the recommended fix.


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


_13_ _Vulnerability Report_


**5.1.2** **V-AIRBENDER-VUL-002: Unrolled Statement Verifier Only Transcript-Binds**
**External Challenges for One Circuit Family**


**<u><mark>Severity</mark></u>** <u><mark>Critical</mark></u> **<u><mark>Commit</mark></u>** <u><mark>5ecb674</mark></u>
**<u><mark>Type</mark></u>** <u><mark>Logic Error</mark></u> **<u><mark>Status</mark></u>** <u><mark>Fixed</mark></u>
**<u><mark>Location(s)</mark></u>** <u><mark>full</mark></u> <sup><mark>_</mark></sup> <u><mark>statement</mark></u> <sup><mark>_</mark></sup> <u><mark>verifier/src/unrolled</mark></u> <sup><mark>_</mark></sup> <u><mark>proof</mark></u> <sup><mark>_</mark></sup> <u><mark>statement.rs</mark></u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>[zksync-airbender/pull/258, 4844b40a](https://github.com/matter-labs/zksync-airbender/pull/258)</mark>


**Background** verify <sup>_</sup> full <sup>_</sup> statement <sup>_</sup> for <sup>_</sup> unrolled <sup>_</sup> circuits() is the top-level verifier for the
unrolled proving system. Its job is not to verify a single proof in isolation, but to verify and
compose:


`▶` multiple unrolled opcode-family proofs,

`▶` init/teardown proofs,

`▶` and optional delegation/precompile proofs,


into one final execution statement.


As it does so, it maintains a Fiat-Shamir transcript by absorbing public execution data and proof
commitments, including:


`▶` final register values and timestamps,

`▶` final PC and timestamp,

`▶` per-family circuit identifiers,

`▶` and each proof’s memory commitment caps.


At the end of this process, the verifier finalizes the transcript and derives the external random
challenges used by the recursive arguments. The core process is illustrated in the following
code snippet taken from the function:


**Why the challenges matter** These externally derived challenges are security-critical. They randomize the main global arguments used to prove soundness across the composed execution:


`▶` memory_challenges randomize the memory multiset/grand-product argument,

`▶` delegation_challenges randomize the delegation request/response argument,

`▶` machine_state_permutation_challenges randomize the PC/timestamp permutation argu
ment that links the machine state across chunks.


These values must be derived from the final transcript so that the prover cannot choose them
after seeing the witness and commitment structure. If some subproofs are verified under
challenges that are not forced to equal the transcript-derived values, then those subproofs are
no longer verified under the intended Fiat-Shamir transform.


**Issue Details** In the implementation, this global transcript-binding invariant was not fully
enforced. The verifier reused two scratch proof-output buffers, proof <sup>_</sup> output <sup>_</sup> 0 and

proof <sup>_</sup> output <sup>_</sup> 1, while iterating across many distinct unrolled circuit families as seen in the
following code snippet:


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


_14_ _Vulnerability Report_


1 **<mark>let</mark>** **<mark>mut</mark>** <mark>proof</mark> <sup><mark>_</mark></sup> <mark>output</mark> <sup><mark>_</mark></sup> <mark>0:</mark> <mark>ProofOutput<...></mark> <mark>=</mark> <mark>MaybeUninit::uninit().assume</mark> <sup><mark>_</mark></sup> <mark>init();</mark>

2 **<mark>let</mark>** **<mark>mut</mark>** <mark>proof</mark> <sup><mark>_</mark></sup> <mark>output</mark> <sup><mark>_</mark></sup> <mark>1:</mark> <mark>ProofOutput<...></mark> <mark>=</mark> <mark>MaybeUninit::uninit().assume</mark> <sup><mark>_</mark></sup> <mark>init();</mark>


3

4 **<mark>for</mark>** <mark>((circuit</mark> <sup><mark>_</mark></sup> <mark>family,</mark> <mark>capacity,</mark> <mark>verifier</mark> <sup><mark>_</mark></sup> <mark>fn),</mark> <mark>setup)</mark> **<mark>in</mark>** <mark>circuits</mark> <sup><mark>_</mark></sup> <mark>families</mark> <sup><mark>_</mark></sup> <mark>verifiers</mark>

5 <mark>.iter()</mark>

6 <mark>.zip(circuits</mark> <sup><mark>_</mark></sup> <mark>families</mark> <sup><mark>_</mark></sup> <mark>setups.iter())</mark>

7 <mark>{</mark>

8 <mark>...</mark>

9 **<mark>for</mark>** <mark>circuit</mark> <sup><mark>_</mark></sup> <mark>sequence</mark> **<mark>in</mark>** <mark>0..num</mark> <sup><mark>_</mark></sup> <mark>circuits</mark> <mark>{</mark>

10 **<mark>let</mark>** <mark>(current,</mark> <mark>previous)</mark> <mark>=</mark> **<mark>if</mark>** <mark>circuit</mark> <sup><mark>_</mark></sup> <mark>sequence</mark> <mark>&</mark> <mark>1</mark> <mark>==</mark> <mark>0</mark> <mark>{</mark>

11 <mark>(&</mark> **<mark>mut</mark>** <mark>proof</mark> <sup><mark>_</mark></sup> <mark>output</mark> <sup><mark>_</mark></sup> <mark>0,</mark> <mark>&proof</mark> <sup><mark>_</mark></sup> <mark>output</mark> <sup><mark>_</mark></sup> <mark>1)</mark>

12 <mark>}</mark> **<mark>else</mark>** <mark>{</mark>

13 <mark>(&</mark> **<mark>mut</mark>** <mark>proof</mark> <sup><mark>_</mark></sup> <mark>output</mark> <sup><mark>_</mark></sup> <mark>1,</mark> <mark>&proof</mark> <sup><mark>_</mark></sup> <mark>output</mark> <sup><mark>_</mark></sup> <mark>0)</mark>

14 <mark>};</mark>


15

16 <mark>(verifier</mark> <sup><mark>_</mark></sup> <mark>fn)(current,</mark> <mark>&</mark> **<mark>mut</mark>** <mark>state</mark> <sup><mark>_</mark></sup> <mark>variables);</mark>

17 <mark>...</mark>

18 <mark>}</mark>

19 <mark>}</mark>


Within each family, the verifier checked challenge continuity only against the immediately
previous proof of the same family:


1 **<mark>if</mark>** <mark>circuit</mark> <sup><mark>_</mark></sup> <mark>sequence</mark> <mark>></mark> <mark>0</mark> <mark>{</mark>

2 **<mark>assert</mark>** <sup>**<mark>_</mark>**</sup> **<mark>eq!</mark>** <mark>(previous.memory</mark> <sup><mark>_</mark></sup> <mark>challenges,</mark> <mark>current.memory</mark> <sup><mark>_</mark></sup> <mark>challenges);</mark>

3 **<mark>assert</mark>** <sup>**<mark>_</mark>**</sup> **<mark>eq!</mark>** <mark>(</mark>

4 <mark>previous.machine</mark> <sup><mark>_</mark></sup> <mark>state</mark> <sup><mark>_</mark></sup> <mark>permutation</mark> <sup><mark>_</mark></sup> <mark>challenges,</mark>

5 <mark>current.machine</mark> <sup><mark>_</mark></sup> <mark>state</mark> <sup><mark>_</mark></sup> <mark>permutation</mark> <sup><mark>_</mark></sup> <mark>challenges</mark>

6 <mark>);</mark>

7 <mark>}</mark>


This enforces same-family consistency, but only locally. It does not ensure that all families use
the same transcript-derived challenge tuple. At the end of verification, the verifier finalized the
transcript, derived expected_challenges, and compared them only against proof <sup>_</sup> output <sup>_</sup> 0:


1 **<mark>let</mark>** <mark>expected</mark> <sup><mark>_</mark></sup> <mark>challenges</mark> <mark>=</mark>

2 <mark>ExternalChallenges::draw</mark> <sup><mark>_</mark></sup> <mark>from</mark> <sup><mark>_</mark></sup> <mark>transcript</mark> <sup><mark>_</mark></sup> <mark>seed</mark> <sup><mark>_</mark></sup> <mark>with</mark> <sup><mark>_</mark></sup> <mark>state</mark> <sup><mark>_</mark></sup> <mark>permutation(</mark>

3 <mark>memory</mark> <sup><mark>_</mark></sup> <mark>seed,</mark>

4 <mark>MEMORY</mark> <sup><mark>_</mark></sup> <mark>DELEGATION</mark> <sup><mark>_</mark></sup> <mark>POW</mark> <sup><mark>_</mark></sup> <mark>BITS,</mark>

5 <mark>pow</mark> <sup><mark>_</mark></sup> <mark>challenge,</mark>

6 <mark>);</mark>


7

8 **<mark>assert</mark>** <sup>**<mark>_</mark>**</sup> **<mark>eq!</mark>** <mark>(</mark>

9 <mark>expected</mark> <sup><mark>_</mark></sup> <mark>challenges.memory</mark> <sup><mark>_</mark></sup> <mark>argument,</mark>

10 <mark>proof</mark> <sup><mark>_</mark></sup> <mark>output</mark> <sup><mark>_</mark></sup> <mark>0.memory</mark> <sup><mark>_</mark></sup> <mark>challenges</mark>

11 <mark>);</mark>

12 **<mark>assert</mark>** <sup>**<mark>_</mark>**</sup> **<mark>eq!</mark>** <mark>(</mark>

13 <mark>expected</mark> <sup><mark>_</mark></sup> <mark>challenges</mark>

14 <mark>.machine</mark> <sup><mark>_</mark></sup> <mark>state</mark> <sup><mark>_</mark></sup> <mark>permutation</mark> <sup><mark>_</mark></sup> <mark>argument</mark>

15 <mark>.unwrap</mark> <sup><mark>_</mark></sup> <mark>unchecked(),</mark>

16 <mark>proof</mark> <sup><mark>_</mark></sup> <mark>output</mark> <sup><mark>_</mark></sup> <mark>0.machine</mark> <sup><mark>_</mark></sup> <mark>state</mark> <sup><mark>_</mark></sup> <mark>permutation</mark> <sup><mark>_</mark></sup> <mark>challenges[0]</mark>

17 <mark>);</mark>


Because proof <sup>_</sup> output <sup>_</sup> 0 was a reused scratch buffer, this final check only bound whatever
family happened to be stored at the end of the loop to the Fiat-Shamir transcript. Other circuit


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


_15_ _Vulnerability Report_


families were only required to remain internally consistent, but were not forced to use the same
transcript-derived external challenges. This is a soundness issue because the composed verifier
is intended to establish that all the constituent proofs together describe one valid execution
under a shared Fiat-Shamir transcript. That claim only holds if every family participating in the
composed proof uses the same transcript derived values.


**Recommendation** The verifier should maintain a canonical challenge tuple for the entire
composed statement and require every main-family proof, init/teardown proof, and delegation
proof to match it. Only after enforcing that global equality should it compare the canonical
tuple against the transcript-derived expected <sup>_</sup> challenges.


**Impact** A malicious prover can cause the verifier to accept malformed multi-family proofs
whose constituent family proofs correspond to inconsistent executions, thereby certifying an
invalid overall RISC-V execution.


**Developer Response** The developers have modified the core loop to check the first challenge
of each family against the transcript-derived expected <sup>_</sup> challenges. This, along with the
continuity checks ensures all the challenges are the same as the transcript-derived one.


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


_16_ _Vulnerability Report_


**5.1.3** **V-AIRBENDER-VUL-003: Verifier Failed To Enforce Continuity of**
**Machine-State Permutation Challenges Across Proofs**


**<u><mark>Severity</mark></u>** <u><mark>Critical</mark></u> **<u><mark>Commit</mark></u>** <u><mark>5ecb674</mark></u>
**<u><mark>Type</mark></u>** <u><mark>Logic Error</mark></u> **<u><mark>Status</mark></u>** <u><mark>Fixed</mark></u>
**Location(s)** full <sup>_</sup> statement <sup>_</sup> verifier/src/

`▶` unified <sup>_</sup> circuit <sup>_</sup> statement.rs:124

`▶` <u>unrolled</u> <sup>_</sup> <u>proof</u> <sup>_</sup> <u>statement.rs:287</u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>[zksync-airbender/pull/258, 4844b40a](https://github.com/matter-labs/zksync-airbender/pull/258)</mark>


**Background** The full-statement verifiers are responsible for composing many lower-level
proofs into one final execution claim.


`▶` verify <sup>_</sup> unified <sup>_</sup> circuit <sup>_</sup> statement() verifies chunks of the unified reduced-machine

circuit.

`▶` verify <sup>_</sup> full <sup>_</sup> statement <sup>_</sup> for <sup>_</sup> unrolled <sup>_</sup> circuits() verifies multiple unrolled

opcode-family proofs, plus init/teardown and optional delegation proofs.


In both paths, the verifier must ensure that all constituent proofs were verified under one
coherent set of external Fiat-Shamir challenges. These challenges parameterize the recursive
global arguments used to prove soundness across proof boundaries.


**Significance of the Machine-State Challenges** One of the key external challenge families is

machine <sup>_</sup> state <sup>_</sup> permutation <sup>_</sup> challenges. These challenges randomize the permutation
argument that ties together machine-state continuity, in particular the PC/timestamp
accumulator used to connect the beginning and end of the execution.


This is visible at the end of the verifier, where the machine-state contribution is folded into the
grand product using the proof output’s machine-state challenges:


1 **<mark>let</mark>** <mark>machine</mark> <sup><mark>_</mark></sup> <mark>state</mark> <sup><mark>_</mark></sup> <mark>contribution</mark> <mark>=</mark>

2 <mark>prover::definitions::produce</mark> <sup><mark>_</mark></sup> <mark>pc</mark> <sup><mark>_</mark></sup> <mark>into</mark> <sup><mark>_</mark></sup> <mark>permutation</mark> <sup><mark>_</mark></sup> <mark>accumulator</mark> <sup><mark>_</mark></sup> <mark>raw(</mark>

3 <mark>INITIAL</mark> <sup><mark>_</mark></sup> <mark>PC,</mark>

4 <mark>split</mark> <sup><mark>_</mark></sup> <mark>timestamp(INITIAL</mark> <sup><mark>_</mark></sup> <mark>TIMESTAMP),</mark>

5 <mark>final</mark> <sup><mark>_</mark></sup> <mark>pc,</mark>

6 <mark>(final</mark> <sup><mark>_</mark></sup> <mark>ts</mark> <sup><mark>_</mark></sup> <mark>low,</mark> <mark>final</mark> <sup><mark>_</mark></sup> <mark>ts</mark> <sup><mark>_</mark></sup> <mark>high),</mark>

7 <mark>&proof</mark> <sup><mark>_</mark></sup> <mark>output</mark> <sup><mark>_</mark></sup> <mark>0.machine</mark> <sup><mark>_</mark></sup> <mark>state</mark> <sup><mark>_</mark></sup> <mark>permutation</mark> <sup><mark>_</mark></sup> <mark>challenges[0].</mark>
<mark>linearization</mark> <sup><mark>_</mark></sup> <mark>challenges,</mark>

8 <mark>&proof</mark> <sup><mark>_</mark></sup> <mark>output</mark> <sup><mark>_</mark></sup> <mark>0.machine</mark> <sup><mark>_</mark></sup> <mark>state</mark> <sup><mark>_</mark></sup> <mark>permutation</mark> <sup><mark>_</mark></sup> <mark>challenges[0].additive</mark> <sup><mark>_</mark></sup> <mark>term,</mark>

9 <mark>);</mark>

10 <mark>grand</mark> <sup><mark>_</mark></sup> <mark>product</mark> <sup><mark>_</mark></sup> <mark>accumulator.mul</mark> <sup><mark>_</mark></sup> <mark>assign(&machine</mark> <sup><mark>_</mark></sup> <mark>state</mark> <sup><mark>_</mark></sup> <mark>contribution);</mark>


If different chunks or families are allowed to use different

machine <sup>_</sup> state <sup>_</sup> permutation <sup>_</sup> challenges, then the verifier is no longer composing one single
permutation argument. It is multiplying together accumulators that were randomized under
different challenge tuples.


**Main Issue** Both verifier paths enforced continuity for some external challenges but omitted
the corresponding equality check for machine <sup>_</sup> state <sup>_</sup> permutation <sup>_</sup> challenges.


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


_17_ _Vulnerability Report_


**Recommendation** We recommend adding the missing check:


1 <mark>//</mark> <mark>missing</mark> <mark>in</mark> <mark>the</mark> <mark>affected</mark> <mark>version</mark>

2 <mark>assert</mark> <sup><mark>_</mark></sup> <mark>eq!(</mark>

3 <mark>previous.machine</mark> <sup><mark>_</mark></sup> <mark>state</mark> <sup><mark>_</mark></sup> <mark>permutation</mark> <sup><mark>_</mark></sup> <mark>challenges,</mark>

4 <mark>current.machine</mark> <sup><mark>_</mark></sup> <mark>state</mark> <sup><mark>_</mark></sup> <mark>permutation</mark> <sup><mark>_</mark></sup> <mark>challenges</mark>

5 <mark>);</mark>


in both verifiers.


**Impact** A malicious prover can construct a composed proof in which different chunks or circuit
families use inconsistent machine-state permutation challenges. This breaks the soundness of
the PC/timestamp continuity argument and causes the verifier to accept malformed composed
proofs that do not correspond to one coherent RISC-V execution.


**Developer Response** The developers have applied the recommended fix.


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


_18_ _Vulnerability Report_


**5.1.4** **V-AIRBENDER-VUL-004: Wrong Decoder Variable Breaks Binding of rs2 Bits**
**to the Fetched Instruction**


**<u><mark>Severity</mark></u>** <u><mark>Low</mark></u> **<u><mark>Commit</mark></u>** <u><mark>5ecb674</mark></u>
**<u><mark>Type</mark></u>** <u><mark>Logic Error</mark></u> **<u><mark>Status</mark></u>** <u><mark>Acknowledged</mark></u>
**<u><mark>Location(s)</mark></u>** <u><mark>cs/src/machine/ops/unrolled/[...]/decoder</mark></u> <sup><mark>_</mark></sup> <u><mark>circuit.rs:98</mark></u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>N/A</mark>


**Description** The decoder circuit translates raw bytecode instructions into the decoded fields
used by the RV32IM execution circuits. Each instruction is a 32-bit word represented as two
field elements, each range-constrained to 16 bits, corresponding to the low and high 16-bit halves
of the instruction. For the high 16-bit half, the decoder is intended to enforce the following
layout:


`▶` rs1 <sup>_</sup> high from bits [19:16],

`▶` rs2 from bits [24:20],

`▶` imm[10:5] from bits [30:25],

`▶` and the sign bit from bit [31]


The decomposition constraint for this high-word layout (shown below) incorrectly used

rs1 <sup>_</sup> from <sup>_</sup> decoder where it should have used rs2 <sup>_</sup> from <sup>_</sup> decoder. As a result, bits [24:20] of the
instruction were constrained against the wrong decoded field. This breaks the binding between
the fetched instruction word and the decoded rs2 value.


1 _<mark>//</mark>_ _<mark>and</mark>_ _<mark>we</mark>_ _<mark>do</mark>_ _<mark>not</mark>_ _<mark>need</mark>_ _<mark>sign</mark>_ _<mark>bit,</mark>_ _<mark>as</mark>_ _<mark>we</mark>_ _<mark>can</mark>_ _<mark>span</mark>_ _<mark>a</mark>_ _<mark>linear</mark>_ _<mark>constraint</mark>_ _<mark>on</mark>_ _<mark>it</mark>_

2 _<mark>//</mark>_ _<mark>insn</mark>_ <sup>_<mark>_</mark>_</sup> _<mark>high</mark>_ _<mark><=></mark>_ _<mark>rs1</mark>_ <sup>_<mark>_</mark>_</sup> _<mark>high:</mark>_ _<mark>[19:16],</mark>_ _<mark>rs2:</mark>_ _<mark>[24:20],</mark>_ _<mark>imm[10-5]:</mark>_ _<mark>[30:25],</mark>_ _<mark>imm12:</mark>_ _<mark>[31]</mark>_

3 **<mark>let</mark>** **<mark>mut</mark>** <mark>sign</mark> <sup><mark>_</mark></sup> <mark>bit</mark> <sup><mark>_</mark></sup> <mark>constraint</mark> <mark>=</mark> <mark>{</mark>

4 <mark>Constraint::from(high</mark> <sup><mark>_</mark></sup> <mark>insn)</mark>

5 <mark>-</mark> <mark>rs1</mark> <sup><mark>_</mark></sup> <mark>high.clone()</mark>

6 <mark>-</mark> <mark>Term::from(rs1</mark> <sup><mark>_</mark></sup> <mark>from</mark> <sup><mark>_</mark></sup> <mark>decoder)</mark> <mark>*</mark> <mark>Term::from(1</mark> <mark><<</mark> <mark>4)</mark>

7 <mark>-</mark> <mark>Term::from(imm10</mark> <sup><mark>_</mark></sup> <mark>5)</mark> <mark>*</mark> <mark>Term::from(1</mark> <mark><<</mark> <mark>9)</mark>

8 <mark>};</mark>


**Recommendation** Use rs2 <sup>_</sup> from <sup>_</sup> decoder instead of rs1 <sup>_</sup> from <sup>_</sup> decoder in

sign <sup>_</sup> bit <sup>_</sup> constraint.


**Impact** This allows the proof system to decouple execution semantics from the actual bytecode.
Downstream unrolled execution circuits consume the decoder outputs to choose source registers
and construct immediates, so an attacker may be able to:


`▶` execute an instruction using a forged rs2 register index,

`▶` and for I/J formats, execute with a forged immediate assembled from unconstrained

rs2-derived bits,
even though the fetched instruction word in ROM encodes different values.


**Developer Response** The developers have acknowledged the behavior but have not prioritized
the fix since the circuit is currently not used.


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


_19_ _Vulnerability Report_


**5.1.5** **V-AIRBENDER-VUL-005: Out of bounds read while fetching instruction**


**<u><mark>Severity</mark></u>** <u><mark>Warning</mark></u> **<u><mark>Commit</mark></u>** <u><mark>5ecb674</mark></u>
**<u><mark>Type</mark></u>** <u><mark>Memory safety</mark></u> **<u><mark>Status</mark></u>** <u><mark>Acknowledged</mark></u>
**<u><mark>Location(s)</mark></u>** <u><mark>riscv</mark></u> <sup><mark>_</mark></sup> <u><mark>transpiler/src/vm/simple</mark></u> <sup><mark>_</mark></sup> <u><mark>tape.rs:20-21</mark></u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>Will not f</mark> i <mark>x</mark>


**Vulnerability Description** The VM stores decoded instructions in a boxed slice and accesses
them using unchecked indexing guarded only by a debug <sup>_</sup> assert!. Because debug_assertions
are disabled by default in release builds, this bounds check is not enforced in production
configurations.


If execution advances past the end of the decoded instruction list, the VM performs an out-ofbounds read on the boxed slice via unchecked access. As a result, memory beyond the end of
the slice is reinterpreted as though it were a decoded RISC-V instruction.


This condition can occur in multiple scenarios:


`▶` During normal execution if the guest program does not conform to the expected ABI and

its final instruction is not an infinite loop. In this case, execution may continue past the
last decoded instruction.

`▶` If the guest program explicitly sets the program counter to an address outside of the

.text section, causing the VM to fetch instructions from a location beyond the decoded
instruction list.


**Developer response** The developers acknowledge the out-of-bound reads but will not fix
because they should not occur under their trusted bytecode assumption.


In most cases this results in a panic because the resulting value does not correspond to a
valid instruction. However, unintended instruction execution is theoretically possible if the
surrounding memory happens to match a valid decoded instruction.


**Impact** The primary impact of this issue is an **out-of-bounds forward memory read** during
instruction fetch. This impact is limited in several ways:


1. **Sequential out-of-bounds access:**
The VM can only read memory located after the instruction slice in memory as execution
advances. It does not enable arbitrary memory reads or backward access.
2. **Read data is not raw machine code:**
The out-of-bounds read does not fetch raw RISC-V instruction bytes. Instead, memory is
interpreted as though it were an element of the Rust Instruction type stored in the boxed
slice. This type is a Rust struct containing decoded instruction fields, and its in-memory
representation differs from the RISC-V machine-code encoding.
3. **Low likelihood of unintended execution:**
Because adjacent memory is interpreted as the Rust Instruction struct rather than raw
instruction bytes, most out-of-bounds reads will not correspond to a valid decoded
instruction and will result in a panic. However, if the surrounding memory happens to
match a valid in-memory representation of the instruction struct, the VM may execute
unintended instructions derived from that memory.


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


_20_ _Vulnerability Report_


In practice, the vulnerability is therefore more likely to result in **unexpected panics or crashes**
than reliable unintended instruction execution.


**Steps to reproduce**


1. [Clone the forked repository that contains the fuzzing harness. The repository is in Github.](https://github.com/Veridise/zksync-airbender-picus-extraction)
The fuzzing harness can be found in the dani/rv32im-fuzz branch.
2. Install dependencies


a) Install afl.rs following the instructions provided in their documentation:

[https://rust-fuzz.github.io/book/afl/setup.html](https://rust-fuzz.github.io/book/afl/setup.html)
b) (Optional) Install a RISC-V C toolchain. On macOS, this can be done by installing

the riscv64-elf-gcc and riscv64-elf-binutils Homebrew packages.


3. Build the harness (note that these commands overwrite the previous build; you must
rebuild when comparing different configurations).


`▶` To build without debug assertions: cargo build -p fuzzing --release

`▶` To build with assertions enabled: cargo afl build -p fuzzing --release


4. Run the test case:

target/release/rv32im-afl --mode unicorn --test-one < <test-case-file>


**Recommendation** Replace the following lines with self.instructions[word] so that the
bounds check is preserved in release builds.


1 **<mark>debug</mark>** <sup>**<mark>_</mark>**</sup> **<mark>assert!</mark>** <mark>(word</mark> <mark><</mark> **<mark>self</mark>** <mark>.instructions.len());</mark>

2 <mark>*</mark> **<mark>self</mark>** <mark>.instructions.get</mark> <sup><mark>_</mark></sup> <mark>unchecked(word)</mark>


**Test cases**


**Single instruction** A test case containing the single instruction xori a0,a6,-220 (0xf2484513)
can trigger this behavior.


With debug assertions enabled:


1 <mark>></mark> <mark>printf</mark> <mark>"\x13\x45\x48\xf2"</mark> <mark>|</mark> <mark>RUST</mark> <sup><mark>_</mark></sup> <mark>LOG=debug</mark> <mark>target/release/rv32im-afl</mark> <mark>--mode</mark> <mark>unicorn</mark>
<mark>--test-one</mark>

2 <mark>[2026-03-12T10:26:38.694Z</mark> <mark>INFO</mark> <mark>]</mark> <mark>Debug</mark> <mark>assertions</mark> <mark>are</mark> <mark>enabled!</mark>

3 <mark>[2026-03-12T10:26:38.694Z</mark> <mark>DEBUG]</mark> <mark>Created</mark> <mark>vm:</mark> <mark>Unicorn</mark> <mark>{</mark> <mark>uc:</mark> <mark>0xa82c00000</mark> <mark>}</mark>

4 <mark>[2026-03-12T10:26:38.694Z</mark> <mark>DEBUG]</mark> <mark>Creating</mark> <mark>memory</mark> <mark>map</mark> <mark>at</mark> <mark>address</mark> <mark>0x0</mark> <mark>with</mark> <mark>4194304</mark>
<mark>bytes</mark>

5 <mark>[2026-03-12T10:26:38.694Z</mark> <mark>DEBUG]</mark> <mark>Creating</mark> <mark>memory</mark> <mark>map</mark> <mark>at</mark> <mark>address</mark> <mark>0x4194304</mark> <mark>with</mark>
<mark>1069547520</mark> <mark>bytes</mark>

6 <mark>[2026-03-12T10:26:38.694Z</mark> <mark>DEBUG]</mark> <mark>Wrote</mark> <mark>program</mark> <mark>to</mark> <mark>entrypoint</mark>

7 <mark>[2026-03-12T10:26:38.694Z</mark> <mark>DEBUG]</mark> <mark>Unicorn</mark> <mark>VM</mark> <mark>configured</mark>

8 <mark>[2026-03-12T10:26:38.695Z</mark> <mark>DEBUG]</mark> <mark>CODE</mark> <mark>HOOK!!</mark> <mark>(0x00000000)</mark> <mark>(4)</mark>

9 <mark>[2026-03-12T10:26:38.695Z</mark> <mark>DEBUG]</mark> <mark>instr</mark> <mark>=</mark> <mark>0xf2484513</mark>

10 <mark>[2026-03-12T10:26:38.695Z</mark> <mark>DEBUG]</mark> <mark>Execution</mark> <mark>completed</mark>

11 <mark>[2026-03-12T10:26:38.695Z</mark> <mark>INFO</mark> <mark>]</mark> <mark>Oracle:</mark> <mark>Some([4294967076,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0])</mark>


12

13 <mark>thread</mark> <mark>’main’</mark> <mark>(411579)</mark> <mark>panicked</mark> <mark>at</mark> <mark>riscv</mark> <sup><mark>_</mark></sup> <mark>transpiler/src/vm/simple</mark> <sup><mark>_</mark></sup> <mark>tape.rs:20:13:</mark>

14 <mark>assertion</mark> <mark>failed:</mark> <mark>word</mark> <mark><</mark> <mark>self.instructions.len()</mark>


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


_21_ _Vulnerability Report_


15 <mark>note:</mark> <mark>run</mark> <mark>with</mark> <mark>‘RUST</mark> <sup><mark>_</mark></sup> <mark>BACKTRACE=1‘</mark> <mark>environment</mark> <mark>variable</mark> <mark>to</mark> <mark>display</mark> <mark>a</mark> <mark>backtrace</mark>

16 <mark>[2026-03-12T10:26:39.822Z</mark> <mark>ERROR]</mark> <mark>Target</mark> <mark>raised</mark> <mark>error:</mark> <mark>assertion</mark> <mark>failed:</mark> <mark>word</mark> <mark><</mark> <mark>self.</mark>
<mark>instructions.len()</mark>

17 <mark>zsh:</mark> <mark>done</mark> <mark>printf</mark> <mark>"\x13\x45\x48\xf2"</mark> <mark>|</mark>

18 <mark>zsh:</mark> <mark>abort</mark> <mark>RUST</mark> <sup><mark>_</mark></sup> <mark>LOG=debug</mark> <mark>target/release/rv32im-afl</mark> <mark>--mode</mark> <mark>unicorn</mark> <mark>--test-one</mark>


Without debug assertions enabled:


1 <mark>></mark> <mark>printf</mark> <mark>"\x13\x45\x48\xf2"</mark> <mark>|</mark> <mark>RUST</mark> <sup><mark>_</mark></sup> <mark>LOG=debug</mark> <mark>target/release/rv32im-afl</mark> <mark>--mode</mark> <mark>unicorn</mark>
<mark>--test-one</mark>

2 <mark>[2026-03-12T10:11:14.479Z</mark> <mark>DEBUG]</mark> <mark>Created</mark> <mark>vm:</mark> <mark>Unicorn</mark> <mark>{</mark> <mark>uc:</mark> <mark>0x7b5004000</mark> <mark>}</mark>

3 <mark>[2026-03-12T10:11:14.479Z</mark> <mark>DEBUG]</mark> <mark>Creating</mark> <mark>memory</mark> <mark>map</mark> <mark>at</mark> <mark>address</mark> <mark>0x0</mark> <mark>with</mark> <mark>4194304</mark>
<mark>bytes</mark>

4 <mark>[2026-03-12T10:11:14.479Z</mark> <mark>DEBUG]</mark> <mark>Creating</mark> <mark>memory</mark> <mark>map</mark> <mark>at</mark> <mark>address</mark> <mark>0x4194304</mark> <mark>with</mark>
<mark>1069547520</mark> <mark>bytes</mark>

5 <mark>[2026-03-12T10:11:14.479Z</mark> <mark>DEBUG]</mark> <mark>Wrote</mark> <mark>program</mark> <mark>to</mark> <mark>entrypoint</mark>

6 <mark>[2026-03-12T10:11:14.479Z</mark> <mark>DEBUG]</mark> <mark>Unicorn</mark> <mark>VM</mark> <mark>configured</mark>

7 <mark>[2026-03-12T10:11:14.480Z</mark> <mark>DEBUG]</mark> <mark>CODE</mark> <mark>HOOK!!</mark> <mark>(0x00000000)</mark> <mark>(4)</mark>

8 <mark>[2026-03-12T10:11:14.480Z</mark> <mark>DEBUG]</mark> <mark>instr</mark> <mark>=</mark> <mark>0xf2484513</mark>

9 <mark>[2026-03-12T10:11:14.480Z</mark> <mark>DEBUG]</mark> <mark>Execution</mark> <mark>completed</mark>

10 <mark>[2026-03-12T10:11:14.480Z</mark> <mark>INFO</mark> <mark>]</mark> <mark>Oracle:</mark> <mark>Some([4294967076,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0])</mark>


11

12 <mark>thread</mark> <mark>’main’</mark> <mark>(380310)</mark> <mark>panicked</mark> <mark>at</mark> <mark>riscv</mark> <sup><mark>_</mark></sup> <mark>transpiler/src/vm/instructions/mod.rs:81:5:</mark>

13 <mark>Illegal</mark> <mark>instruction</mark> <mark>encounteted</mark> <mark>at</mark> <mark>PC</mark> <mark>=</mark> <mark>0x00000004</mark>

14 <mark>note:</mark> <mark>run</mark> <mark>with</mark> <mark>‘RUST</mark> <sup><mark>_</mark></sup> <mark>BACKTRACE=1‘</mark> <mark>environment</mark> <mark>variable</mark> <mark>to</mark> <mark>display</mark> <mark>a</mark> <mark>backtrace</mark>

15 <mark>[2026-03-12T10:11:15.007Z</mark> <mark>INFO</mark> <mark>]</mark> <mark>Target:</mark> <mark>None</mark>

16 <mark>Oracle</mark> <mark>and</mark> <mark>result</mark> <mark>produced</mark> <mark>different</mark> <mark>register</mark> <mark>outputs!</mark>

17 <mark>oracle:</mark> <mark>Some([4294967076,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0])</mark>

18 <mark>target:</mark> <mark>None</mark>

19 <mark>zsh:</mark> <mark>done</mark> <mark>printf</mark> <mark>"\x13\x45\x48\xf2"</mark> <mark>|</mark>

20 <mark>zsh:</mark> <mark>abort</mark> <mark>RUST</mark> <sup><mark>_</mark></sup> <mark>LOG=debug</mark> <mark>target/release/rv32im-afl</mark> <mark>--mode</mark> <mark>unicorn</mark> <mark>--test-one</mark>


**Modified example** One of the examples in the repository can be modified to trigger the same
behavior.


1 <mark>></mark> <mark>ls</mark> <mark>-l</mark> <mark>examples/basic</mark> <sup><mark>_</mark></sup> <mark>fibonacci/app.bin</mark>

2 <mark>-rwxr-xr-x</mark> <mark>1</mark> <mark>foldr</mark> <mark>staff</mark> <mark>388</mark> <mark>Feb</mark> <mark>16</mark> <mark>17:56</mark> <mark>examples/basic</mark> <sup><mark>_</mark></sup> <mark>fibonacci/app.bin</mark>

3 <mark>></mark> <mark>riscv64-elf-objdump</mark> <mark>-D</mark> <mark>-b</mark> <mark>binary</mark> <mark>-m</mark> <mark>riscv:rv32</mark> <mark>examples/basic</mark> <sup><mark>_</mark></sup> <mark>fibonacci/app.bin</mark> <mark>|</mark>
<mark>tail</mark>

4 <mark>15c:</mark> <mark>01cd2883</mark> <mark>lw</mark> <mark>a7,28(s10)</mark>

5 <mark>160:</mark> <mark>020d2903</mark> <mark>lw</mark> <mark>s2,32(s10)</mark>

6 <mark>164:</mark> <mark>024d2983</mark> <mark>lw</mark> <mark>s3,36(s10)</mark>

7 <mark>168:</mark> <mark>028d2a03</mark> <mark>lw</mark> <mark>s4,40(s10)</mark>

8 <mark>16c:</mark> <mark>02cd2a83</mark> <mark>lw</mark> <mark>s5,44(s10)</mark>

9 <mark>170:</mark> <mark>030d2b03</mark> <mark>lw</mark> <mark>s6,48(s10)</mark>

10 <mark>174:</mark> <mark>034d2b83</mark> <mark>lw</mark> <mark>s7,52(s10)</mark>

11 <mark>178:</mark> <mark>038d2c03</mark> <mark>lw</mark> <mark>s8,56(s10)</mark>

12 <mark>17c:</mark> <mark>03cd2c83</mark> <mark>lw</mark> <mark>s9,60(s10)</mark>

13 <mark>180:</mark> <mark>0000006f</mark> <mark>j</mark> <mark>0x180</mark>

14 <mark>></mark> <mark>head</mark> <mark>-c</mark> <mark>384</mark> <mark>examples/basic</mark> <sup><mark>_</mark></sup> <mark>fibonacci/app.bin</mark> <mark>></mark> <mark>badfib.bin</mark>

15 <mark>></mark> <mark>riscv64-elf-objdump</mark> <mark>-D</mark> <mark>-b</mark> <mark>binary</mark> <mark>-m</mark> <mark>riscv:rv32</mark> <mark>badfib.bin</mark> <mark>|</mark> <mark>tail</mark>

16 <mark>158:</mark> <mark>018d2803</mark> <mark>lw</mark> <mark>a6,24(s10)</mark>

17 <mark>15c:</mark> <mark>01cd2883</mark> <mark>lw</mark> <mark>a7,28(s10)</mark>

18 <mark>160:</mark> <mark>020d2903</mark> <mark>lw</mark> <mark>s2,32(s10)</mark>

19 <mark>164:</mark> <mark>024d2983</mark> <mark>lw</mark> <mark>s3,36(s10)</mark>


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


_22_ _Vulnerability Report_


20 <mark>168:</mark> <mark>028d2a03</mark> <mark>lw</mark> <mark>s4,40(s10)</mark>

21 <mark>16c:</mark> <mark>02cd2a83</mark> <mark>lw</mark> <mark>s5,44(s10)</mark>

22 <mark>170:</mark> <mark>030d2b03</mark> <mark>lw</mark> <mark>s6,48(s10)</mark>

23 <mark>174:</mark> <mark>034d2b83</mark> <mark>lw</mark> <mark>s7,52(s10)</mark>

24 <mark>178:</mark> <mark>038d2c03</mark> <mark>lw</mark> <mark>s8,56(s10)</mark>

25 <mark>17c:</mark> <mark>03cd2c83</mark> <mark>lw</mark> <mark>s9,60(s10)</mark>


With debug assertions enabled:


1 <mark>></mark> <mark>target/release/rv32im-afl</mark> <mark>--mode</mark> <mark>unicorn</mark> <mark>--test-one</mark> <mark><</mark> <mark>badfib.bin</mark>

2 <mark>[2026-03-12T10:37:47.826Z</mark> <mark>INFO</mark> <mark>]</mark> <mark>Debug</mark> <mark>assertions</mark> <mark>are</mark> <mark>enabled!</mark>

3 <mark>[2026-03-12T10:37:47.827Z</mark> <mark>INFO</mark> <mark>]</mark> <mark>Oracle:</mark> <mark>Some([144,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0])</mark>


4

5 <mark>thread</mark> <mark>’main’</mark> <mark>(437996)</mark> <mark>panicked</mark> <mark>at</mark> <mark>riscv</mark> <sup><mark>_</mark></sup> <mark>transpiler/src/vm/simple</mark> <sup><mark>_</mark></sup> <mark>tape.rs:20:13:</mark>

6 <mark>assertion</mark> <mark>failed:</mark> <mark>word</mark> <mark><</mark> <mark>self.instructions.len()</mark>

7 <mark>note:</mark> <mark>run</mark> <mark>with</mark> <mark>‘RUST</mark> <sup><mark>_</mark></sup> <mark>BACKTRACE=1‘</mark> <mark>environment</mark> <mark>variable</mark> <mark>to</mark> <mark>display</mark> <mark>a</mark> <mark>backtrace</mark>

8 <mark>[2026-03-12T10:37:48.894Z</mark> <mark>ERROR]</mark> <mark>Target</mark> <mark>raised</mark> <mark>error:</mark> <mark>assertion</mark> <mark>failed:</mark> <mark>word</mark> <mark><</mark> <mark>self.</mark>
<mark>instructions.len()</mark>

9 <mark>zsh:</mark> <mark>abort</mark> <mark>target/release/rv32im-afl</mark> <mark>--mode</mark> <mark>unicorn</mark> <mark>--test-one</mark> <mark><</mark> <mark>badfib.bin</mark>


Without debug assertions enabled:


1 <mark>></mark> <mark>target/release/rv32im-afl</mark> <mark>--mode</mark> <mark>unicorn</mark> <mark>--test-one</mark> <mark><</mark> <mark>badfib.bin</mark>

2 <mark>[2026-03-12T10:39:04.395Z</mark> <mark>INFO</mark> <mark>]</mark> <mark>Oracle:</mark> <mark>Some([144,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0])</mark>


3

4 <mark>thread</mark> <mark>’main’</mark> <mark>(440991)</mark> <mark>panicked</mark> <mark>at</mark> <mark>riscv</mark> <sup><mark>_</mark></sup> <mark>transpiler/src/vm/instructions/mod.rs:81:5:</mark>

5 <mark>Illegal</mark> <mark>instruction</mark> <mark>encounteted</mark> <mark>at</mark> <mark>PC</mark> <mark>=</mark> <mark>0x00000180</mark>

6 <mark>note:</mark> <mark>run</mark> <mark>with</mark> <mark>‘RUST</mark> <sup><mark>_</mark></sup> <mark>BACKTRACE=1‘</mark> <mark>environment</mark> <mark>variable</mark> <mark>to</mark> <mark>display</mark> <mark>a</mark> <mark>backtrace</mark>

7 <mark>[2026-03-12T10:39:04.950Z</mark> <mark>INFO</mark> <mark>]</mark> <mark>Target:</mark> <mark>None</mark>

8 <mark>Oracle</mark> <mark>and</mark> <mark>result</mark> <mark>produced</mark> <mark>different</mark> <mark>register</mark> <mark>outputs!</mark>

9 <mark>oracle:</mark> <mark>Some([144,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0])</mark>

10 <mark>target:</mark> <mark>None</mark>

11 <mark>zsh:</mark> <mark>abort</mark> <mark>target/release/rv32im-afl</mark> <mark>--mode</mark> <mark>unicorn</mark> <mark>--test-one</mark> <mark><</mark> <mark>badfib.bin</mark>


**Unsafe C code** The following C snippet forces execution to jump outside the .text section.
During execution of SimpleTape::read <sup>_</sup> instruction, the VM attempts to read the element at
index 0x1000000 of the SimpleTape::instructions slice, resulting in an out-of-bounds access
relative to the slice’s base address in memory.


1 **<mark>#include</mark>** <mark>"rt.h"</mark>


2

3 **<mark>#define</mark>** <mark>HEAP</mark> <sup><mark>_</mark></sup> <mark>ADDR</mark> <mark>(</mark> **<mark>void</mark>** <mark>*)0x04000000</mark>

4

5 <mark>Result</mark> <mark>main()</mark> <mark>{</mark>

6 **<mark>void</mark>** <mark>(*f)()</mark> <mark>=</mark> <mark>(</mark> **<mark>void</mark>** <mark>(*)())(HEAP</mark> <sup><mark>_</mark></sup> <mark>ADDR);</mark>

7 <mark>(*f)();</mark>

8 **<mark>return</mark>** <mark>success(0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0);</mark>

9 <mark>}</mark>


The C example is available in the forked repository. To test this case, install the RISC-V C
toolchain and run the following commands.


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


_23_ _Vulnerability Report_


1 <mark>></mark> <mark>make</mark> <mark>-C</mark> <mark>c</mark> <sup><mark>_</mark></sup> <mark>examples/</mark> <mark>badread</mark>

2 <mark>riscv64-elf-gcc</mark> <mark>-march=rv32im</mark> <mark>-mabi=ilp32</mark> <mark>-nostdlib</mark> <mark>-O0</mark> <mark>-nolibc</mark> <mark>-fno-builtin</mark> <mark>-</mark>
<mark>ffreestanding</mark> <mark>-T</mark> <mark>memmap.ld</mark> <mark>-o</mark> <mark>badread.elf</mark> <mark>badread.c</mark> <mark>rt.c</mark> <mark>start.s</mark>

3 <mark>riscv64-elf-objcopy</mark> <mark>-O</mark> <mark>binary</mark> <mark>badread.elf</mark> <mark>badread.bin</mark>

4 <mark>riscv64-elf-objcopy</mark> <mark>-O</mark> <mark>binary</mark> <mark>--only-section=.text</mark> <mark>badread.elf</mark> <mark>badread.text</mark>

5 <mark>rm</mark> <mark>badread.elf</mark>

6 <mark>></mark> <mark>target/release/rv32im-afl</mark> <mark>--mode</mark> <mark>unicorn</mark> <mark>--test-one</mark> <mark><</mark> <mark>c</mark> <sup><mark>_</mark></sup> <mark>examples/badread.text</mark>

7 <mark>[2026-03-12T13:14:15.103Z</mark> <mark>INFO</mark> <mark>]</mark> <mark>Oracle:</mark> <mark>None</mark>

8 <mark>zsh:</mark> <mark>segmentation</mark> <mark>fault</mark> <mark>target/release/rv32im-afl</mark> <mark>--mode</mark> <mark>unicorn</mark> <mark>--test-one</mark> <mark><</mark>
<mark>c</mark> <sup><mark>_</mark></sup> <mark>examples/badread.text</mark>


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


_24_ _Vulnerability Report_


**5.1.6** **V-AIRBENDER-VUL-006: Out of bounds reads and writes on RAM abstraction**


**<u><mark>Severity</mark></u>** <u><mark>Warning</mark></u> **<u><mark>Commit</mark></u>** <u><mark>5ecb674</mark></u>
**<u><mark>Type</mark></u>** <u><mark>Memory safety</mark></u> **<u><mark>Status</mark></u>** <u><mark>Acknowledged</mark></u>
**Location(s)** riscv <sup>_</sup> transpiler/[...]/ram <sup>_</sup> with <sup>_</sup> rom <sup>_</sup> region.rs:69-70,
<u>135-139</u>
**<mark>Conf</mark>** **i** **<mark>rmed Fix At</mark>** <mark>Will not f</mark> i <mark>x</mark>


**Vulnerability Description** The VM implements a RAM abstraction that provides access to
guest memory through a contiguous buffer. Access to this buffer relies on unchecked indexing
guarded only by a debug <sup>_</sup> assert!. Because debug <sup>_</sup> assertions are disabled by default in release
builds, these bounds checks are not enforced in production configurations.


If an address outside the allocated RAM region is used, the RAM abstraction may perform
unchecked memory accesses beyond the bounds of the underlying buffer. This can result in
**out-of-bounds reads and writes**, allowing memory located after the RAM buffer to be read
from or overwritten.


**Impact** The primary impact of this issue is the ability to perform **out-of-bounds reads and**
**writes** relative to the RAM buffer used by the VM. This is constrained by several factors:


1. **Forward-only memory access:**
The vulnerability only allows accesses to memory located after the RAM buffer in memory.
It does not permit reading or writing addresses located before the buffer.
2. **Partial control over the accessed data:**
Each RAM cell is represented by a 16-byte structure. However, the attacker can only
reliably control or observe a subset of this memory layout, specifically bytes 9 through 12
of each cell. The remaining bytes depend on the internal structure representation and
cannot be directly manipulated through the guest interface.
3. **Potential stack corruption:**
Because the RAM buffer is allocated on the heap, sufficiently large out-of-bounds accesses
may reach other memory regions used by the host process, including the stack. In principle,
this could allow an attacker to overwrite stack values such as saved frame pointers or
return addresses. Such corruption could lead to control-flow hĳacking.


While this scenario is difficult to exploit reliably due to the limited control over individual bytes
within each memory cell and the dependency on the host process memory layout, the potential
impact is significant if such corruption can be achieved.


**Recommendation** Replace unchecked indexing operations in the RAM abstraction with
bounds-checked indexing to ensure that memory accesses remain within the allocated buffer.


Currently, memory accesses rely on unchecked indexing guarded only by debug <sup>_</sup> assert!.
Because these checks are not enforced in release builds, accesses using out-of-range addresses
may result in out-of-bounds reads or writes.


All accesses to the underlying RAM buffer should instead use bounds-checked indexing (for
example, via safe indexing or get/get <sup>_</sup> mut). This ensures that invalid addresses are detected
and handled appropriately in both debug and release builds, preventing memory accesses
outside the allocated RAM region.


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


_25_ _Vulnerability Report_


**Steps to reproduce**


1. [Clone the forked repository that contains the fuzzing harness. The repository is in Github.](https://github.com/Veridise/zksync-airbender-picus-extraction)
The fuzzing harness can be found in the dani/rv32im-fuzz branch.
2. Install dependencies


a) Install afl.rs following the instructions provided in their documentation:

[https://rust-fuzz.github.io/book/afl/setup.html](https://rust-fuzz.github.io/book/afl/setup.html)
b) Install a RISC-V C toolchain. On macOS, this can be done by installing the

riscv64-elf-gcc and riscv64-elf-binutils Homebrew packages.


3. Build the harness (note that these commands overwrite the previous build; you must
rebuild when comparing different configurations).


`▶` To build without debug assertions: cargo build -p fuzzing --release

`▶` To build with assertions enabled: cargo afl build -p fuzzing --release


4. Run the test case:

target/release/rv32im-afl --mode unicorn --test-one < <test-case-file>


**Test cases** The following test cases are written in C and are intended to exercise the affected
RAM interface through guest programs. Each example includes a short description, the
corresponding C source, and the commands used to reproduce the issue with and without
debug assertions enabled.


**Out of bounds read** The guest program performs a sequence of reads from addresses beyond
the allocated RAM region. Specifically, it reads from offsets 0, 10, 20, ..., 70 starting from
the address immediately following the end of the allocated RAM buffer. This causes the RAM
abstraction to access memory outside the bounds of the underlying buffer.


1 **<mark>#include</mark>** <mark>"rt.h"</mark>


2

3 **<mark>#define</mark>** <mark>RAM</mark> <sup><mark>_</mark></sup> <mark>SIZE</mark> <mark>(1</mark> <mark><<</mark> <mark>30)</mark>

4 **<mark>#define</mark>** <mark>HEAP</mark> <sup><mark>_</mark></sup> <mark>ADDR</mark> <mark>(</mark> **<mark>void</mark>** <mark>*)(RAM</mark> <sup><mark>_</mark></sup> <mark>SIZE)</mark>

5

6 <mark>Result</mark> <mark>main()</mark> <mark>{</mark>

7 **<mark>unsigned</mark>** **<mark>int</mark>** <mark>*values</mark> <mark>=</mark> <mark>(</mark> **<mark>unsigned</mark>** **<mark>int</mark>** <mark>*)HEAP</mark> <sup><mark>_</mark></sup> <mark>ADDR;</mark>

8

9 **<mark>return</mark>** <mark>success(values[0],</mark> <mark>values[10],</mark> <mark>values[20],</mark> <mark>values[30],</mark> <mark>values[40],</mark>

10 <mark>values[50],</mark> <mark>values[60],</mark> <mark>values[70]);</mark>

11 <mark>}</mark>


With debug assertions enabled:


1 <mark>></mark> <mark>make</mark> <mark>-C</mark> <mark>c</mark> <sup><mark>_</mark></sup> <mark>examples/</mark> <mark>badread2</mark>

2 <mark>riscv64-elf-gcc</mark> <mark>-march=rv32im</mark> <sup><mark>_</mark></sup> <mark>zicsr</mark> <mark>-mabi=ilp32</mark> <mark>-nostdlib</mark> <mark>-O0</mark> <mark>-nolibc</mark> <mark>-fno-builtin</mark> <mark>-</mark>
<mark>ffreestanding</mark> <mark>-T</mark> <mark>memmap.ld</mark> <mark>-o</mark> <mark>badread2.elf</mark> <mark>badread2.c</mark> <mark>rt.c</mark> <mark>start.s</mark> <mark>uart.c</mark>

3 <mark>riscv64-elf-objcopy</mark> <mark>-O</mark> <mark>binary</mark> <mark>badread2.elf</mark> <mark>badread2.bin</mark>

4 <mark>riscv64-elf-objcopy</mark> <mark>-O</mark> <mark>binary</mark> <mark>--only-section=.text</mark> <mark>badread2.elf</mark> <mark>badread2.text</mark>

5 <mark>rm</mark> <mark>badread2.elf</mark>

6 <mark>></mark> <mark>target/release/rv32im-afl</mark> <mark>--mode</mark> <mark>unicorn</mark> <mark>--test-one</mark> <mark><</mark> <mark>c</mark> <sup><mark>_</mark></sup> <mark>examples/badread2.text</mark>

7 <mark>[2026-03-13T11:55:56.944Z</mark> <mark>INFO</mark> <mark>]</mark> <mark>Debug</mark> <mark>assertions</mark> <mark>are</mark> <mark>enabled!</mark>

8 <mark>[2026-03-13T11:55:56.945Z</mark> <mark>INFO</mark> <mark>]</mark> <mark>Oracle:</mark> <mark>None</mark>

9 <mark>instructions</mark> <mark>(254)</mark> <mark>is</mark> <mark>at</mark> <mark>0x103ed9f30</mark>

10 <mark>backing</mark> <mark>(268435456)</mark> <mark>is</mark> <mark>at</mark> <mark>0x4d8000000</mark>


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


_26_ _Vulnerability Report_


11

12 <mark>thread</mark> <mark>’main’</mark> <mark>(3492848)</mark> <mark>panicked</mark> <mark>at</mark> <mark>riscv</mark> <sup><mark>_</mark></sup> <mark>transpiler/src/vm/ram</mark> <sup><mark>_</mark></sup> <mark>with</mark> <sup><mark>_</mark></sup> <mark>rom</mark> <sup><mark>_</mark></sup> <mark>region.rs</mark>
<mark>:122:13:</mark>

13 <mark>assertion</mark> <mark>failed:</mark> <mark>word</mark> <sup><mark>_</mark></sup> <mark>idx</mark> <mark><</mark> <mark>self.backing.len()</mark>

14 <mark>note:</mark> <mark>run</mark> <mark>with</mark> <mark>‘RUST</mark> <sup><mark>_</mark></sup> <mark>BACKTRACE=1‘</mark> <mark>environment</mark> <mark>variable</mark> <mark>to</mark> <mark>display</mark> <mark>a</mark> <mark>backtrace</mark>

15 <mark>[2026-03-13T11:55:58.059Z</mark> <mark>ERROR]</mark> <mark>Target</mark> <mark>raised</mark> <mark>error:</mark> <mark>assertion</mark> <mark>failed:</mark> <mark>word</mark> <sup><mark>_</mark></sup> <mark>idx</mark> <mark><</mark>
<mark>self.backing.len()</mark>

16 <mark>zsh:</mark> <mark>abort</mark> <mark>target/release/rv32im-afl</mark> <mark>--mode</mark> <mark>unicorn</mark> <mark>--test-one</mark> <mark><</mark> <mark>c</mark> <sup><mark>_</mark></sup> <mark>examples/</mark>
<mark>badread2.tex</mark>


Without debug assertions enabled:


1 <mark>></mark> <mark>make</mark> <mark>-C</mark> <mark>c</mark> <sup><mark>_</mark></sup> <mark>examples/</mark> <mark>badread2</mark>

2 <mark>riscv64-elf-gcc</mark> <mark>-march=rv32im</mark> <sup><mark>_</mark></sup> <mark>zicsr</mark> <mark>-mabi=ilp32</mark> <mark>-nostdlib</mark> <mark>-O0</mark> <mark>-nolibc</mark> <mark>-fno-builtin</mark> <mark>-</mark>
<mark>ffreestanding</mark> <mark>-T</mark> <mark>memmap.ld</mark> <mark>-o</mark> <mark>badread2.elf</mark> <mark>badread2.c</mark> <mark>rt.c</mark> <mark>start.s</mark> <mark>uart.c</mark>

3 <mark>riscv64-elf-objcopy</mark> <mark>-O</mark> <mark>binary</mark> <mark>badread2.elf</mark> <mark>badread2.bin</mark>

4 <mark>riscv64-elf-objcopy</mark> <mark>-O</mark> <mark>binary</mark> <mark>--only-section=.text</mark> <mark>badread2.elf</mark> <mark>badread2.text</mark>

5 <mark>rm</mark> <mark>badread2.elf</mark>

6 <mark>></mark> <mark>target/release/rv32im-afl</mark> <mark>--mode</mark> <mark>unicorn</mark> <mark>--test-one</mark> <mark><</mark> <mark>c</mark> <sup><mark>_</mark></sup> <mark>examples/badread2.text</mark>

7 <mark>[2026-03-13T11:58:10.797Z</mark> <mark>INFO</mark> <mark>]</mark> <mark>Oracle:</mark> <mark>None</mark>

8 <mark>instructions</mark> <mark>(254)</mark> <mark>is</mark> <mark>at</mark> <mark>0x105509800</mark>

9 <mark>backing</mark> <mark>(268435456)</mark> <mark>is</mark> <mark>at</mark> <mark>0xcb8000000</mark>

10 <mark>[2026-03-13T11:58:11.317Z</mark> <mark>INFO</mark> <mark>]</mark> <mark>Target:</mark> <mark>Some([0,</mark> <mark>1073741824,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0])</mark>

11 <mark>Oracle</mark> <mark>and</mark> <mark>result</mark> <mark>produced</mark> <mark>different</mark> <mark>register</mark> <mark>outputs!</mark>

12 <mark>oracle:</mark> <mark>None</mark>

13 <mark>target:</mark> <mark>Some([0,</mark> <mark>1073741824,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0])</mark>

14 <mark>zsh:</mark> <mark>abort</mark> <mark>target/release/rv32im-afl</mark> <mark>--mode</mark> <mark>unicorn</mark> <mark>--test-one</mark> <mark><</mark> <mark>c</mark> <sup><mark>_</mark></sup> <mark>examples/</mark>
<mark>badread2.tex</mark>


**Out of bounds write** The guest program writes two strings to memory: "Valid write!" is
written to valid addresses near the end of the allocated RAM buffer, while

"Hello from the Guest" is written to addresses beyond the end of the buffer.


In the execution without debug assertions enabled, both strings can be observed in the
resulting hexdump. This demonstrates that the valid writes occur within the buffer while the
second string is written to memory outside the allocated RAM buffer. The RAM buffer spans
the address range 0x4a8000000 to 0x5a7ffffff.


1 **<mark>#include</mark>** <mark>"rt.h"</mark>


2

3 **<mark>#define</mark>** <mark>RAM</mark> <sup><mark>_</mark></sup> <mark>SIZE</mark> <mark>(1</mark> <mark><<</mark> <mark>30)</mark>

4 **<mark>#define</mark>** <mark>HEAP</mark> <sup><mark>_</mark></sup> <mark>ADDR</mark> <mark>(</mark> **<mark>void</mark>** <mark>*)(RAM</mark> <sup><mark>_</mark></sup> <mark>SIZE)</mark>

5

6 <mark>Result</mark> <mark>main()</mark> <mark>{</mark>

7 **<mark>unsigned</mark>** **<mark>int</mark>** <mark>*values</mark> <mark>=</mark> <mark>(</mark> **<mark>unsigned</mark>** **<mark>int</mark>** <mark>*)HEAP</mark> <sup><mark>_</mark></sup> <mark>ADDR;</mark>

8

9 _<mark>//</mark>_ _<mark>Vali</mark>_ _<mark>d</mark>_ _<mark>wr</mark>_ _<mark>ite!</mark>_

10 _<mark>//</mark>_ _<mark>0x696c6156</mark>_ _<mark>0x72772064</mark>_ _<mark>0x21657469</mark>_

11 **<mark>unsigned</mark>** **<mark>int</mark>** <mark>*valid</mark> <mark>=</mark> <mark>values</mark> <mark>-</mark> <mark>5;</mark>

12 <mark>valid[0]</mark> <mark>=</mark> <mark>0x696c6156;</mark>

13 <mark>valid[1]</mark> <mark>=</mark> <mark>0x72772064;</mark>

14 <mark>valid[2]</mark> <mark>=</mark> <mark>0x21657469;</mark>


15

16 _<mark>//</mark>_ _<mark>Hell</mark>_ _<mark>o</mark>_ _<mark>fr</mark>_ _<mark>om</mark>_ _<mark>t</mark>_ _<mark>he</mark>_ _<mark>G</mark>_ _<mark>uest</mark>_

17 _<mark>//</mark>_ _<mark>0x6c6c6548</mark>_ _<mark>0x7266206f</mark>_ _<mark>0x74206d6f</mark>_ _<mark>0x47206568</mark>_ _<mark>0x74736575</mark>_


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


_27_ _Vulnerability Report_


18 <mark>values[1]</mark> <mark>=</mark> <mark>0x6c6c6548;</mark>

19 <mark>values[2]</mark> <mark>=</mark> <mark>0x7266206f;</mark>

20 <mark>values[3]</mark> <mark>=</mark> <mark>0x74206d6f;</mark>

21 <mark>values[4]</mark> <mark>=</mark> <mark>0x47206568;</mark>

22 <mark>values[5]</mark> <mark>=</mark> <mark>0x74736575;</mark>


23

24 **<mark>return</mark>** <mark>success(values[0],</mark> <mark>values[10],</mark> <mark>values[20],</mark> <mark>values[30],</mark> <mark>values[40],</mark>

25 <mark>values[50],</mark> <mark>values[60],</mark> <mark>values[70]);</mark>

26 <mark>}</mark>


With debug assertions enabled:


1 <mark>></mark> <mark>make</mark> <mark>-C</mark> <mark>c</mark> <sup><mark>_</mark></sup> <mark>examples/</mark> <mark>badwrite</mark>

2 <mark>riscv64-elf-gcc</mark> <mark>-march=rv32im</mark> <sup><mark>_</mark></sup> <mark>zicsr</mark> <mark>-mabi=ilp32</mark> <mark>-nostdlib</mark> <mark>-O0</mark> <mark>-nolibc</mark> <mark>-fno-builtin</mark> <mark>-</mark>
<mark>ffreestanding</mark> <mark>-T</mark> <mark>memmap.ld</mark> <mark>-o</mark> <mark>badwrite.elf</mark> <mark>badwrite.c</mark> <mark>rt.c</mark> <mark>start.s</mark> <mark>uart.c</mark>

3 <mark>riscv64-elf-objcopy</mark> <mark>-O</mark> <mark>binary</mark> <mark>badwrite.elf</mark> <mark>badwrite.bin</mark>

4 <mark>riscv64-elf-objcopy</mark> <mark>-O</mark> <mark>binary</mark> <mark>--only-section=.text</mark> <mark>badwrite.elf</mark> <mark>badwrite.text</mark>

5 <mark>rm</mark> <mark>badwrite.elf</mark>

6 <mark>></mark> <mark>target/release/rv32im-afl</mark> <mark>--mode</mark> <mark>unicorn</mark> <mark>--test-one</mark> <mark><</mark> <mark>c</mark> <sup><mark>_</mark></sup> <mark>examples/badwrite.text</mark>

7 <mark>[2026-03-13T11:56:22.614Z</mark> <mark>INFO</mark> <mark>]</mark> <mark>Debug</mark> <mark>assertions</mark> <mark>are</mark> <mark>enabled!</mark>

8 <mark>[2026-03-13T11:56:22.615Z</mark> <mark>INFO</mark> <mark>]</mark> <mark>Oracle:</mark> <mark>None</mark>

9 <mark>instructions</mark> <mark>(296)</mark> <mark>is</mark> <mark>at</mark> <mark>0x983444000</mark>

10 <mark>backing</mark> <mark>(268435456)</mark> <mark>is</mark> <mark>at</mark> <mark>0xc82000000</mark>


11

12 <mark>thread</mark> <mark>’main’</mark> <mark>(3493796)</mark> <mark>panicked</mark> <mark>at</mark> <mark>riscv</mark> <sup><mark>_</mark></sup> <mark>transpiler/src/vm/ram</mark> <sup><mark>_</mark></sup> <mark>with</mark> <sup><mark>_</mark></sup> <mark>rom</mark> <sup><mark>_</mark></sup> <mark>region.rs</mark>
<mark>:190:13:</mark>

13 <mark>assertion</mark> <mark>failed:</mark> <mark>word</mark> <sup><mark>_</mark></sup> <mark>idx</mark> <mark><</mark> <mark>self.backing.len()</mark>

14 <mark>note:</mark> <mark>run</mark> <mark>with</mark> <mark>‘RUST</mark> <sup><mark>_</mark></sup> <mark>BACKTRACE=1‘</mark> <mark>environment</mark> <mark>variable</mark> <mark>to</mark> <mark>display</mark> <mark>a</mark> <mark>backtrace</mark>

15 <mark>[2026-03-13T11:56:23.715Z</mark> <mark>ERROR]</mark> <mark>Target</mark> <mark>raised</mark> <mark>error:</mark> <mark>assertion</mark> <mark>failed:</mark> <mark>word</mark> <sup><mark>_</mark></sup> <mark>idx</mark> <mark><</mark>
<mark>self.backing.len()</mark>

16 <mark>zsh:</mark> <mark>abort</mark> <mark>target/release/rv32im-afl</mark> <mark>--mode</mark> <mark>unicorn</mark> <mark>--test-one</mark> <mark><</mark> <mark>c</mark> <sup><mark>_</mark></sup> <mark>examples/</mark>
<mark>badwrite.tex</mark>


Without debug assertions enabled:


1 <mark>></mark> <mark>make</mark> <mark>-C</mark> <mark>c</mark> <sup><mark>_</mark></sup> <mark>examples/</mark> <mark>badwrite</mark>

2 <mark>riscv64-elf-gcc</mark> <mark>-march=rv32im</mark> <sup><mark>_</mark></sup> <mark>zicsr</mark> <mark>-mabi=ilp32</mark> <mark>-nostdlib</mark> <mark>-O0</mark> <mark>-nolibc</mark> <mark>-fno-builtin</mark> <mark>-</mark>
<mark>ffreestanding</mark> <mark>-T</mark> <mark>memmap.ld</mark> <mark>-o</mark> <mark>badwrite.elf</mark> <mark>badwrite.c</mark> <mark>rt.c</mark> <mark>start.s</mark> <mark>uart.c</mark>

3 <mark>riscv64-elf-objcopy</mark> <mark>-O</mark> <mark>binary</mark> <mark>badwrite.elf</mark> <mark>badwrite.bin</mark>

4 <mark>riscv64-elf-objcopy</mark> <mark>-O</mark> <mark>binary</mark> <mark>--only-section=.text</mark> <mark>badwrite.elf</mark> <mark>badwrite.text</mark>

5 <mark>rm</mark> <mark>badwrite.elf</mark>

6 <mark>></mark> <mark>target/release/rv32im-afl</mark> <mark>--mode</mark> <mark>unicorn</mark> <mark>--test-one</mark> <mark><</mark> <mark>c</mark> <sup><mark>_</mark></sup> <mark>examples/badwrite.text</mark>

7 <mark>[2026-03-13T11:57:54.865Z</mark> <mark>INFO</mark> <mark>]</mark> <mark>Oracle:</mark> <mark>None</mark>

8 <mark>instructions</mark> <mark>(296)</mark> <mark>is</mark> <mark>at</mark> <mark>0x1021be700</mark>

9 <mark>backing</mark> <mark>(268435456)</mark> <mark>is</mark> <mark>at</mark> <mark>0x4a8000000</mark>

10 <mark>0x5a7ffffb0:</mark> <mark>9a*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>56*</mark> <mark>61*</mark> <mark>6c*</mark> <mark>69*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark>
<mark>|........Vali....|</mark>

11 <mark>0x5a7ffffc0:</mark> <mark>ae*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>64*</mark> <mark>20*</mark> <mark>77*</mark> <mark>72*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark>
<mark>|........d</mark> <mark>wr....|</mark>

12 <mark>0x5a7ffffd0:</mark> <mark>c2*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>69*</mark> <mark>74*</mark> <mark>65*</mark> <mark>21*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark>
<mark>|........ite!....|</mark>

13 <mark>0x5a7ffffe0:</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark>
<mark>|................|</mark>

14 <mark>0x5a7fffff0:</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark> <mark>00*</mark>
<mark>|................|</mark>


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


_28_ _Vulnerability Report_


15 <mark>0x5a8000000:</mark> <mark>2d</mark> <mark>01</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark>
<mark>|-...............|</mark>

16 <mark>0x5a8000010:</mark> <mark>d6</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>48</mark> <mark>65</mark> <mark>6c</mark> <mark>6c</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark>
<mark>|........Hell....|</mark>

17 <mark>0x5a8000020:</mark> <mark>ea</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>6f</mark> <mark>20</mark> <mark>66</mark> <mark>72</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark>
<mark>|........o</mark> <mark>fr....|</mark>

18 <mark>0x5a8000030:</mark> <mark>fe</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>6f</mark> <mark>6d</mark> <mark>20</mark> <mark>74</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark>
<mark>|........om</mark> <mark>t....|</mark>

19 <mark>0x5a8000040:</mark> <mark>12</mark> <mark>01</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>68</mark> <mark>65</mark> <mark>20</mark> <mark>47</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark>
<mark>|........he</mark> <mark>G....|</mark>

20 <mark>0x5a8000050:</mark> <mark>26</mark> <mark>01</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>75</mark> <mark>65</mark> <mark>73</mark> <mark>74</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark>
<mark>|&.......uest....|</mark>

21 <mark>0x5a8000060:</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark>
<mark>|................|</mark>

22 <mark>0x5a8000070:</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark>
<mark>|................|</mark>

23 <mark>0x5a8000080:</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark>
<mark>|................|</mark>

24 <mark>0x5a8000090:</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark>
<mark>|................|</mark>

25 <mark>0x5a80000a0:</mark> <mark>39</mark> <mark>01</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>40</mark> <mark>76</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark>
<mark>|9..........@v...|</mark>

26 <mark>0x5a80000b0:</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark>
<mark>|................|</mark>

27 <mark>0x5a80000c0:</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>40</mark> <mark>7e</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>|...@</mark>
<mark>~...........|</mark>

28 <mark>0x5a80000d0:</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>ec</mark> <mark>ff</mark> <mark>ff</mark> <mark>3f</mark> <mark>8a</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark>
<mark>|...........?....|</mark>

29 <mark>0x5a80000e0:</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark> <mark>00</mark>
<mark>|................|</mark>

30 <mark>[2026-03-13T11:57:55.390Z</mark> <mark>INFO</mark> <mark>]</mark> <mark>Target:</mark> <mark>Some([0,</mark> <mark>1073741824,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0])</mark>

31 <mark>Oracle</mark> <mark>and</mark> <mark>result</mark> <mark>produced</mark> <mark>different</mark> <mark>register</mark> <mark>outputs!</mark>

32 <mark>oracle:</mark> <mark>None</mark>

33 <mark>target:</mark> <mark>Some([0,</mark> <mark>1073741824,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0,</mark> <mark>0])</mark>

34 <mark>zsh:</mark> <mark>abort</mark> <mark>target/release/rv32im-afl</mark> <mark>--mode</mark> <mark>unicorn</mark> <mark>--test-one</mark> <mark><</mark> <mark>c</mark> <sup><mark>_</mark></sup> <mark>examples/</mark>
<mark>badwrite.tex</mark>


**Developer response** The developers acknowledge the out-of-bound writes but will not fix
because they should not occur under their trusted bytecode assumption.


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


## **Fuzz Testing**
# **6**

#### **6.1 Methodology**

One of the goals of the security assessment was to fuzz test ZKsync Airbender in order to
evaluate the robustness and correctness of selected execution, proving, and proof-validation
components under malformed, adversarial, or randomized inputs. In particular, the fuzzing
workflows were designed to answer three main questions: whether selected components could
be crashed or driven into abnormal states, whether the transpiler/VM behavior could diverge
from a reference execution oracle, and whether structured mutations of prover inputs could
expose completeness or soundness issues in the proving pipeline.


**Executor fuzzing.** For the bytecode executor/transpiler workflow, the analysts used an AFL.rs
harness to test the Airbender VM on randomized inputs. This campaign was run in two modes.
In the first mode, arbitrary inputs were executed directly in the Airbender VM in order to detect
crashes, panics, malformed execution states, and other robustness issues. In the second mode,
the same inputs were executed both in Airbender and in a Unicorn-based RISC-V reference
emulator, and the harness compared the ABI-visible output registers of the two executions.
This differential setup was intended to detect semantic divergence from the reference model in
addition to crash behavior. This executor based fuzzing found two crashes which resulted in
issues V-AIRBENDER-VUL-005 and V-AIRBENDER-VUL-006.


**Prover fuzzing.** The prover campaign was not based primarily on mutating raw bytecode.
Instead, the Veridise analysts built a structure-aware harness that started from valid seed
programs and then mutated the prover’s internal per-circuit inputs directly. Concretely, the
harness first loaded a corpus of seed programs as .bin/.text pairs, executed each program
once through the Airbender VM, and cached the resulting proof inputs for several unrolled
circuit families. In the implemented scaffold, this included the main arithmetic, control-flow.


Each cached seed was then expanded into multiple fuzzing cases, one per circuit family. The
fuzzer repeatedly selected one such seed case and applied one or more randomized mutations
to the corresponding proof input. These mutations were structure-aware: rather than flipping
arbitrary bytes, they directly modified semantically meaningful parts of the prover input such
as trace rows, row order, row multiplicity, cycle timestamps, read timestamps, the initial PC,
decoder entries, decoder-row ordering, memory discriminators, and preprocessed-table rows
or cells. This made the campaign substantially better targeted to Airbender’s proving logic than
generic byte-level mutation would have been.


After mutation, the harness re-ran the relevant circuit-family prover on the tampered input.
If proof generation failed or panicked, the case was treated as a robustness signal. If proof
generation succeeded, the harness then invoked the corresponding proof-validation routine
on the same mutated input and produced proof. This let the campaign distinguish between
different classes of behavior: cases where malformed structured inputs caused proof generation
to fail, cases where the prover emitted a proof that the validator rejected, and cases where
mutated inputs still led to a proof that validated successfully. The latter category was treated as


Veridise Tool Engagement Report: ZKsync Airbender © 2026 Veridise Inc.


_30_ _Fuzz Testing_


the most security-relevant, since it may indicate that malformed internal prover inputs can still
satisfy the downstream acceptance checks.


To reduce noise, interesting cases were persisted together with the originating seed, targeted
circuit family, and list of applied mutations. The harness also supported offline replay-based
triage: it reloaded both the original cached seed input and the mutated artifact, replayed
each multiple times, and compared compact execution traces across prover stages. This replay
step helped distinguish stable, reproducible divergences from unstable outcomes and false
positives.


**Compliance Testing** Complementary to the fuzzing campaign described above, we conducted
a series of compliance tests based on a publicly available test suite <sup>‗</sup> . These tests are designed to
systematically validate conformance with the RISC-V specification across a range of instruction
semantics and edge cases.


The compliance test suite was executed in three distinct configurations:


`▶` Against the Unicorn-based RISC-V reference emulator;

`▶` Against the Airbender virtual machine (VM) in isolation;

`▶` Against the combined Airbender VM and prover system.


The results indicate that all tests passed successfully in the first two configurations. In the third
configuration (Airbender VM with prover), all tests passed except for a single failure related to
the udiv instruction. Specifically, the failing test exposed an issue in the arithmetic circuit when
handling division by zero.


This issue was already known to the development team and had been disclosed to the Veridise
auditors.

#### **6.2 Fuzzer Execution Summary**


**Table 6.1:** Summary of fuzzing campaign execution statistics


**<u>Fuzzing Campaign</u>** **<u>Run Time</u>** **<u>Approx. Executions</u>** **<u>Issues Found</u>**
Executor fuzzing 4 days ∼1,000,000 2
<u>Prover fuzzing</u> <u>2 days</u> <u>∼10,000</u> <u>0</u>


‗ _https://github.com/riscv/riscv-arch-test_


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


## **Picus**
# **7**

This section describes how the Veridise analysts used Picus to check the determinism of the
ZKsync Airbender circuits.

#### **7.1 Determinism**


Given a circuit 퐶(퐼, 푂) with input signals 퐼 and output signals 푂, a circuit 퐶 is deterministic if
and only if:

∀퐼, 푂, 푂 <sup>′</sup> . 퐶(퐼, 푂) ∧ 퐶(퐼, 푂 <sup>′</sup> ) → 푂 ≡ 푂 <sup>′</sup>


In essence, a deterministic circuit encodes a function (or partial function) from 퐼 to 푂. Determinism is an important property that most ZK Circuits should satisfy since most circuits are
intended to encode some deterministic computation.

#### **7.2 Methodology**


[Picus takes as input programs written in the Picus Constraint Language (PCL). Thus, to use Picus](https://docs.veridise.tools/picus-v2/picus_constraint_language/)
for this engagement, the Veridise analysts needed a translation pipeline from Airbender circuits
into PCL. Conceptually, this pipeline proceeded in two stages: first, the selected Airbender
[circuits were translated into LLZK, an intermediate constraint language used in the formal-](https://github.com/project-llzk/llzk-lib/)
methods workflow; second, an LLZK-to-PCL lowering pass was used to convert the resulting
LLZK programs into PCL for analysis by Picus.


**Unrolled Circuit Harnesses.** For each selected unrolled opcode-family circuit, the Veridise
analysts built a dedicated harness that instantiated the corresponding Airbender circuit in
isolation and extracted the resulting constraint system. Each harness was modeled as one
local state transition. In practice, this meant treating the starting machine state, decoded
instruction information, and values read from registers or memory as inputs, while treating the
ending machine state and any write-side effects as outputs. For decoder-oriented harnesses, the
instruction word and decoded fields were exposed directly so that the decoder logic could be
checked independently of any particular ROM instance.


**Extraction and Interface Modeling.** After instantiating a harness, the analysts translated the
resulting circuit-builder output into LLZK. The builder already separates ordinary polynomial
constraints from lookup queries and records auxiliary metadata such as boolean variables,
which allowed the extractor to preserve that structure in the LLZK model. To formulate a
determinism query, the analysts then determined which AIR columns should be treated as
inputs and which should be treated as outputs. The general rule was to model externally
supplied values and pre-state values as inputs, and newly computed values and post-state
values as outputs (like the rd register and values written to memory).


Because Airbender relies on outer memory and permutation arguments for some global
consistency properties, the analysts also added explicit local assumptions that are implicit in the
full proving system. In particular, the extracted models included one-hot constraints for selector


Veridise Tool Engagement Report: ZKsync Airbender © 2026 Veridise Inc.


_32_ _Picus_


and control flags, as well as range constraints for values that are intended to be bounded but
may enter the local transition as externally supplied inputs. These included halfword-sized
values such as memory limbs, immediate limbs, PC limbs, and timestamp limbs, byte-sized
values introduced by certain lookup relations, and bounded decoded fields such as register
indices and opcode subfields.


**Lookups.** Lookups were extracted as first-class parts of the LLZK model rather than discarded
as opaque implementation details. Since many Airbender transitions depend on lookup outputs
for decoder behavior, memory alignment, masking, sign extraction, and related helper logic,
preserving those relations was necessary for a meaningful determinism query. The auxiliary
metadata recorded by the circuit builder, especially boolean constraints and local range
information, was used to supply the side conditions needed to model these lookup-driven
computations faithfully.


**Opcode Specialization.** Many unrolled circuits implement several related opcodes inside one
shared circuit family. In those families, opcode-specific logic is guarded by selector columns
that are expected to be mutually consistent with the decoder and, in practice, to encode one
valid branch at a time. To avoid asking Picus about invalid mixed-selector states, the Veridise
analysts partially evaluated the circuit constraints under fixed selector assignments and extracted
per-opcode or per-valid-branch variants of the shared circuit. This let the determinism checks
focus on one concrete opcode behavior at a time while still analyzing the real production
constraints.


**Unified** **Circuit** **Harnesses.** The workflow for the unified reduced-machine circuit was
conceptually similar to their unrolled counterparts but required more setup. Unlike the
unrolled families, the unified circuit is built as one large circuit intended to contain many
instruction families at once rather than as a naturally per-opcode artifact. For the purposes of
extraction, the Veridise analysts instantiated harnesses that built the relevant circuit families
with fresh optimization contexts and enforced the accumulated constraints after each family
was constructed. This differs from the production workflow, where the developers instantiate
all families under one shared optimization context and enforce deferred constraints only at the
end. The per-family extraction approach produced cleaner LLZK models for analysis while
preserving the local semantics of the unified circuit logic under study.

#### **7.3 Results**


Table 7.1 summarizes the outcomes of the Picus determinism checks over the main extraction targets. Most of the listed targets were verified deterministic under the modeling assumptions described above. In particular, Picus successfully verified most of the unrolled
instruction-family circuits, all of the listed legacy instruction-operation implementations, and
the bigint <sup>_</sup> with <sup>_</sup> control delegation circuit.


Two targets were falsified. First, Picus found a determinism counterexample for unrolled circuit
which handles the jumping, branching, and comparison logic (issue V-AIRBENDER-VUL001). Second, Picus also falsified determinism for describe <sup>_</sup> decoder <sup>_</sup> cycle <sup>_</sup> from <sup>_</sup> opcode which is
supposed to decode untrusted bytecode, leading to the creation of issue V-AIRBENDER-VUL-004.
We note that after fixing both issues, Picus verified the determinism of these circuits.


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


_33_ _Picus_


Some additional targets remained unresolved. The apply <sup>_</sup> mul <sup>_</sup> div family and the whole-circuit
targets optimized <sup>_</sup> base <sup>_</sup> isa <sup>_</sup> state <sup>_</sup> transition and apply <sup>_</sup> reduced <sup>_</sup> machine <sup>_</sup> circuit were not
fully discharged within the engagement due to their complexity. The remaining unresolved delegation/precompile circuits, namely blake2 <sup>_</sup> round <sup>_</sup> with <sup>_</sup> extended <sup>_</sup> control, blake2 <sup>_</sup> single <sup>_</sup> round
, and keccak <sup>_</sup> special5, were especially challenging because of their size and the density of
interacting constraints. In principle, verification of these larger components could likely be
accelerated by extracting them into smaller logical submodules, but the current extraction
infrastructure does not make it easy to partition constraints along those boundaries.


**<u>Table 7.1:</u>** <u>Picus verification targets.</u>


**Target** **Verification Unit** **Result** **After**
**<u>Fix</u>**

<u><mark>apply</mark></u> <sup><mark>_</mark></sup> <u><mark>add</mark></u> <sup><mark>_</mark></sup> <u><mark>sub</mark></u> <sup><mark>_</mark></sup> <u><mark>lui</mark></u> <sup><mark>_</mark></sup> <u><mark>auipc</mark></u> <sup><mark>_</mark></sup> <u><mark>mop</mark></u> <u><mark>Per-opcode specialization</mark></u> <u><mark>Verif</mark></u> i <u><mark>ed</mark></u> <u><mark>N/A</mark></u>

<u><mark>apply</mark></u> <sup><mark>_</mark></sup> <u><mark>jump</mark></u> <sup><mark>_</mark></sup> <u><mark>branch</mark></u> <sup><mark>_</mark></sup> <u><mark>slt</mark></u> <u><mark>Per-opcode specialization</mark></u> <u><mark>Falsif</mark></u> i <u><mark>ed</mark></u> <u><mark>Verif</mark></u> i <u><mark>ed</mark></u>

<u><mark>apply</mark></u> <sup><mark>_</mark></sup> <u><mark>subword</mark></u> <sup><mark>_</mark></sup> <u><mark>only</mark></u> <sup><mark>_</mark></sup> <u><mark>load</mark></u> <sup><mark>_</mark></sup> <u><mark>store</mark></u> <u><mark>Per-opcode specialization</mark></u> <u><mark>Verif</mark></u> i <u><mark>ed</mark></u> <u><mark>N/A</mark></u>

<u><mark>apply</mark></u> <sup><mark>_</mark></sup> <u><mark>word</mark></u> <sup><mark>_</mark></sup> <u><mark>only</mark></u> <sup><mark>_</mark></sup> <u><mark>load</mark></u> <sup><mark>_</mark></sup> <u><mark>store</mark></u> <u><mark>Per-opcode specialization</mark></u> <u><mark>Verif</mark></u> i <u><mark>ed</mark></u> <u><mark>N/A</mark></u>

<u><mark>apply</mark></u> <sup><mark>_</mark></sup> <u><mark>word</mark></u> <sup><mark>_</mark></sup> <u><mark>only</mark></u> <sup><mark>_</mark></sup> <u><mark>load</mark></u> <sup><mark>_</mark></sup> <u><mark>store</mark></u> <u><mark>Per-opcode specialization</mark></u> <u><mark>Verif</mark></u> i <u><mark>ed</mark></u> <u><mark>N/A</mark></u>

<u><mark>apply</mark></u> <sup><mark>_</mark></sup> <u><mark>load</mark></u> <sup><mark>_</mark></sup> <u><mark>store</mark></u> <u><mark>Per-opcode specialization</mark></u> <u><mark>Verif</mark></u> i <u><mark>ed</mark></u> <u><mark>N/A</mark></u>

<u><mark>apply</mark></u> <sup><mark>_</mark></sup> <u><mark>mul</mark></u> <sup><mark>_</mark></sup> <u><mark>div</mark></u> <u><mark>Per-opcode specialization</mark></u> <u><mark>Verif</mark></u> i <u><mark>ed</mark></u> <u><mark>N/A</mark></u>

<u><mark>describe</mark></u> <sup><mark>_</mark></sup> <u><mark>decoder</mark></u> <sup><mark>_</mark></sup> <u><mark>cycle</mark></u> <sup><mark>_</mark></sup> <u><mark>from</mark></u> <sup><mark>_</mark></sup> <u><mark>opcode</mark></u> <u><mark>Bytecode decoder</mark></u> <u><mark>Falsif</mark></u> i <u><mark>ed</mark></u> <u><mark>Verif</mark></u> i <u><mark>ed</mark></u>

<u><mark>apply</mark></u> <sup><mark>_</mark></sup> <u><mark>shift</mark></u> <sup><mark>_</mark></sup> <u><mark>binop</mark></u> <sup><mark>_</mark></sup> <u><mark>csrrw</mark></u> <u><mark>Per-opcode specialization</mark></u> <u><mark>Verif</mark></u> i <u><mark>ed</mark></u> <u><mark>N/A</mark></u>

<u><mark>AddOp, SubOp</mark></u> <u><mark>Operation implementation</mark></u> <u><mark>Verif</mark></u> i <u><mark>ed</mark></u> <u><mark>N/A</mark></u>

<u><mark>BinaryOp</mark></u> <u><mark>Operation implementation</mark></u> <u><mark>Verif</mark></u> i <u><mark>ed</mark></u> <u><mark>N/A</mark></u>

<u><mark>ShiftOp<SUPPORT</mark></u> <sup><mark>_</mark></sup> <u><mark>SRA,</mark></u> <u><mark>SUPPORT</mark></u> <sup><mark>_</mark></sup> <u><mark>ROT></mark></u> <u><mark>Parameterized operation</mark></u> <u><mark>Verif</mark></u> i <u><mark>ed</mark></u> <u><mark>N/A</mark></u>

<u><mark>MulOp<SUPPORT</mark></u> <sup><mark>_</mark></sup> <u><mark>SIGNED></mark></u> <u><mark>Parameterized operation</mark></u> <u><mark>Verif</mark></u> i <u><mark>ed</mark></u> <u><mark>N/A</mark></u>

<u><mark>DivRemOp<SUPPORT</mark></u> <sup><mark>_</mark></sup> <u><mark>SIGNED></mark></u> <u><mark>Parameterized operation</mark></u> <u><mark>Verif</mark></u> i <u><mark>ed</mark></u> <u><mark>N/A</mark></u>

<u><mark>LoadOp<...></mark></u> <u><mark>Parameterized operation</mark></u> <u><mark>Verif</mark></u> i <u><mark>ed</mark></u> <u><mark>N/A</mark></u>

<u><mark>ConditionalOp<SUPPORT</mark></u> <sup><mark>_</mark></sup> <u><mark>SIGNED></mark></u> <u><mark>Parameterized operation</mark></u> <u><mark>Verif</mark></u> i <u><mark>ed</mark></u> <u><mark>N/A</mark></u>

<u><mark>StoreOp<SUPPORT</mark></u> <sup><mark>_</mark></sup> <u><mark>LESS</mark></u> <sup><mark>_</mark></sup> <u><mark>THAN</mark></u> <sup><mark>_</mark></sup> <u><mark>WORD></mark></u> <u><mark>Parameterized operation</mark></u> <u><mark>Verif</mark></u> i <u><mark>ed</mark></u> <u><mark>N/A</mark></u>

<u><mark>LuiOp, AuiPc</mark></u> <u><mark>Operation implementation</mark></u> <u><mark>Verif</mark></u> i <u><mark>ed</mark></u> <u><mark>N/A</mark></u>

<u><mark>JumpOp</mark></u> <u><mark>Operation implementation</mark></u> <u><mark>Verif</mark></u> i <u><mark>ed</mark></u> <u><mark>N/A</mark></u>

<u><mark>MopOp</mark></u> <u><mark>Operation implementation</mark></u> <u><mark>Verif</mark></u> i <u><mark>ed</mark></u> <u><mark>N/A</mark></u>

<u><mark>optimized</mark></u> <sup><mark>_</mark></sup> <u><mark>base</mark></u> <sup><mark>_</mark></sup> <u><mark>isa</mark></u> <sup><mark>_</mark></sup> <u><mark>state</mark></u> <sup><mark>_</mark></sup> <u><mark>transition</mark></u> <u><mark>Whole circuit</mark></u> <u><mark>Unknown</mark></u> <u><mark>N/A</mark></u>

<u><mark>apply</mark></u> <sup><mark>_</mark></sup> <u><mark>reduced</mark></u> <sup><mark>_</mark></sup> <u><mark>machine</mark></u> <sup><mark>_</mark></sup> <u><mark>circuit</mark></u> <u><mark>Whole circuit</mark></u> <u><mark>Unknown</mark></u> <u><mark>N/A</mark></u>

<u><mark>bigint</mark></u> <sup><mark>_</mark></sup> <u><mark>with</mark></u> <sup><mark>_</mark></sup> <u><mark>control</mark></u> <u><mark>Delegation circuit</mark></u> <u><mark>Verif</mark></u> i <u><mark>ed</mark></u> <u><mark>N/A</mark></u>

<u><mark>blake2</mark></u> <sup><mark>_</mark></sup> <u><mark>round</mark></u> <sup><mark>_</mark></sup> <u><mark>with</mark></u> <sup><mark>_</mark></sup> <u><mark>extended</mark></u> <sup><mark>_</mark></sup> <u><mark>control</mark></u> <u><mark>Delegation circuit</mark></u> <u><mark>Unknown</mark></u> <u><mark>N/A</mark></u>

<u><mark>blake2</mark></u> <sup><mark>_</mark></sup> <u><mark>single</mark></u> <sup><mark>_</mark></sup> <u><mark>round</mark></u> <u><mark>Delegation circuit</mark></u> <u><mark>Unknown</mark></u> <u><mark>N/A</mark></u>

<mark>keccak</mark> <sup><mark>_</mark></sup> <mark>special5</mark> <mark>Delegation circuit</mark> <mark>Unknown</mark> <mark>N/A</mark>


**7.3.1** **Circuits Requiring Customized Verification**


While many circuits were amenable to largely push-button analysis, some required additional

analyst guidance before Picus could successfully discharge the determinism proof. In particular,
the mul <sup>_</sup> div family, including apply <sup>_</sup> mul <sup>_</sup> div and DivRemOp<SUPPORT <sup>_</sup> SIGNED>, was ultimately
verified, but only after applying verification-oriented rewrites and case decomposition. The main
challenge was that the original circuit structure was not immediately solver-friendly. To make
the determinism proof tractable, we rewrote certain constraints, such as IsZero-style conditions,
into more explicit logical assertions. For example, we replaced the constraints with assertions of


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


_34_ _Picus_


the form (assert (<=> (= out 1) ...)), which more directly expose the intended semantics to
the solver. We also split the verification task into semantically distinct cases, including positive
numerators, division-by-zero behavior, and overflow-related corner cases. This case-splitting
was necessary to control path complexity and allow Picus to prove determinism for each case
individually.


© 2026 Veridise Inc. Veridise Tool Engagement Report: ZKsync Airbender


## **Glossary**

**AFL.rs** [A rust interface into AFL-plus-plus (https://github.com/AFLplusplus/AFLplusplus).](https://github.com/AFLplusplus/AFLplusplus)

[See https://github.com/rust-fuzz/afl.rs/ to learn more. 29](https://github.com/rust-fuzz/afl.rs/)


**Fiat-Shamir** A well-known method for converting interactive proofs to non-interactive ones.

[See https://en.wikipedia.org/wiki/Fiat-Shamir](https://en.wikipedia.org/wiki/Fiat-Shamir_heuristic) <sup>_</sup> heuristic to learn more. 3


**LLZK** LLZK is a family of MLIR dialects and compiler optimizations and analysis passes for

[ZK circuits. See https://github.com/project-llzk/llzk-lib/ . 7](https://github.com/project-llzk/llzk-lib/)


**zero-knowledge circuit** A cryptographic construct that allows a prover to demonstrate to a

verifier that a certain statement is true, without revealing any specific information about
[the statement itself. See https://en.wikipedia.org/wiki/Zero-knowledge](https://en.wikipedia.org/wiki/Zero-knowledge_proof) <sup>_</sup> proof for
more. 35
**zkVM** A general-purpose zero-knowledge circuit that implements proving the execution of a

virtual machine. This enables general purpose programs to prove their execution to outside
observers, without the manual constraint writing usually associated with zero-knowledge
circuit development . 1


Veridise Tool Engagement Report: ZKsync Airbender © 2026 Veridise Inc.


