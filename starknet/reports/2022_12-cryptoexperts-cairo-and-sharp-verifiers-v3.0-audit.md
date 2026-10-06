# **Smart Contract Audit Report**
## **Conducted by CryptoExperts**

As part of our due process, we retained CryptoExperts to review the design document and

related source code of the Cairo & SHARP verifiers. We chose to work with CryptoExperts

based on our good experience and interaction with them in the past.


We are happy to share the key findings below, followed by the full report.

## **Vulnerability Severity Classification**


The current version of the report is an update of our original report after counterauditing
modifications from StarkWare.


Each observation is appended with a status:
Resolved (  ), Partially resolved (   ), Unresolved (   ).


Most of our recommendations have been addressed. Unresolved or partially resolved issues are

related to documentation or coding practices which are of minor importance.


#### **Category**

##### **High risk** **Medium risk** **Low risk** **Coding practices** **Documentation**

#### **Total**


#### **Number of findings**

0


1


17


7


**27**


Code Review of the Cairo & SHARP Verifiers

### Contents


**1** **Introduction** **4**
1.1 Overview of the code . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4
1.2 Methodology and summary of findings . . . . . . . . . . . . . . . . . . . . . 5


**2** **Documentation** **for** **the** **Cairo** **verifier** **9**
2.1 The CPU architecture . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 9
2.2 Builtins . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 9
2.3 Execution of a program . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 10
2.4 The main function . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 12
2.5 Public memory . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 14
2.5.1 Pages of the public memory . . . . . . . . . . . . . . . . . . . . . . . 14
2.5.2 Padding of the public memory . . . . . . . . . . . . . . . . . . . . . 14
2.6 Public input and verified statement . . . . . . . . . . . . . . . . . . . . . . . 15
2.7 Verifier dependencies . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 17
2.7.1 Contract `StarkParameters` . . . . . . . . . . . . . . . . . . . . . . . 17
2.7.2 Contract `LayoutSpecific` . . . . . . . . . . . . . . . . . . . . . . . . 18
2.7.3 Contract `CpuConstraintPoly` . . . . . . . . . . . . . . . . . . . . . . 18
2.7.4 Contract `CpuOODS` . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 19


**3** **Review** **of** **the** **Cairo** **verifier** **20**
3.1 Management of the public inputs . . . . . . . . . . . . . . . . . . . . . . . . 20
3.1.1 Contract `PageInfo` . . . . . . . . . . . . . . . . . . . . . . . . . . . . 20
3.1.2 Contract `CpuPublicInputOffsetsBase` . . . . . . . . . . . . . . . . . 20
3.1.3 Contract `CpuPublicInputOffsets` . . . . . . . . . . . . . . . . . . . 20
3.2 Fact registry for memory pages . . . . . . . . . . . . . . . . . . . . . . . . . 21
3.2.1 Contract `MemoryPageFactRegistry` . . . . . . . . . . . . . . . . . . . 21
3.3 The Cairo verifier interface and layouts . . . . . . . . . . . . . . . . . . . . . 23
3.3.1 Contract `CairoVerifierContract` . . . . . . . . . . . . . . . . . . . 23
3.3.2 Contract `LayoutSpecific` . . . . . . . . . . . . . . . . . . . . . . . . 23
3.4 The CPU verifier . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 24
3.4.1 Contract `CpuVerifier` . . . . . . . . . . . . . . . . . . . . . . . . . . 24
3.4.2 Contract `CpuFriLessVerifier` . . . . . . . . . . . . . . . . . . . . . 27
3.5 General observations . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 28


**4** **Documentation** **for** **the** **SHARP** **verifier** **29**
4.1 The bootloader program . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 30
4.1.1 Simple bootloader . . . . . . . . . . . . . . . . . . . . . . . . . . . . 30
4.1.2 General bootloader . . . . . . . . . . . . . . . . . . . . . . . . . . . . 32
4.2 Public memory for SHARP . . . . . . . . . . . . . . . . . . . . . . . . . . . 34
4.2.1 The main page . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 34
4.2.2 The tasks’ pages . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 36


Page 2/52


Code Review of the Cairo & SHARP Verifiers


4.3 The verified statement . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 36
4.4 Fact registration . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 37
4.4.1 Facts from <u>the</u> prover . . . . . . . . . . . . . . . . . . . . . . . . . . 37
4.4.2 Facts from the verifier . . . . . . . . . . . . . . . . . . . . . . . . . . 37
4.4.3 Merkle tree for pages . . . . . . . . . . . . . . . . . . . . . . . . . . . 38


**5** **Review** **of** **the** **SHARP** **verifier** **41**
5.1 SHARP verifier contracts . . . . . . . . . . . . . . . . . . . . . . . . . . . . 41
5.1.1 Contract `GpsOutputParser` . . . . . . . . . . . . . . . . . . . . . . . 41
5.1.2 Contract `GpsStatementVerifier` . . . . . . . . . . . . . . . . . . . . 42
5.1.3 General observations . . . . . . . . . . . . . . . . . . . . . . . . . . . 44
5.2 Bootloader source code . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 45
5.2.1 File `simple_bootloader.cairo` (main function for the simple bootloader) . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 45
5.2.2 File `bootloader.cairo` (main function for the general bootloader) . 45
5.2.3 File `run_simple_bootloader.cairo` (main loop) . . . . . . . . . . . 46
5.2.4 File `execute_task.cairo` (task execution) . . . . . . . . . . . . . . . 48


Page 3/52


Code Review of the Cairo & SHARP Verifiers

### 1 Introduction


StarkWare is a company <u>developing</u> scalability and privacy technologies for blockchain
applications. In particular, StarkWare develops a STARK-powered level-2 scalability
engine which uses cryptographic proofs to attest to the validity of a batch of transactions.
As part of StarkWare’s technology, the Cairo STARK-friendly CPU architecture allows
developers to easily write STARK-provable programs for general computation.

In this context, CryptoExperts has conducted a first audit of StarkWare’s STARK
verifier (implemented as a Solidity smart contract) in late 2021. StarkWare was then
willing to perform a follow-up audit of their Cairo verifier and associated shared proof
service (SHARP), which are built on top of the STARK verifier.

Upon business agreement with StarkWare, CryptoExperts has conducted this
second audit in March and April 2022. The primary goal of this audit was to ensure that
the Solidity code of the Cairo and SHARP verifiers (together with the Cairo code of the
bootloader) correctly verify the computational integrity of Cairo programs. The service
consisted in a study of the Cairo specification and a review of the code by two engineers,
experts in cryptography.

The present report contains the results of this audit. The curent version of the report (v2.0) is an update of the original report with the subsequent audit of the general
bootloader (extending the simple bootloader) which has been conducted in July 2022.

We first give an overview of the code (Section 1.1) and a summary of the audit methodology and findings (Section 1.2). We provide some complementary documentation of the
Cairo verifier implementation in Section 2 then present our review of this implementation
in Section 3. This review includes a summary of the functionality of each smart contract
together with a list of observations and recommendations. We then provide some complementary documentation of the SHARP verifier implementation in Section 4, and its review
in Section 5.

#### 1.1 Overview of the code


The scope of the audit includes the Cairo Verifier and SHARP verifier, a.k.a. GPS (Generic
Proof Service) verifier, which are both built on top of the STARK verifier previously
audited [1].


The first audited code implements the Cairo verifier. It is composed of the 8 source
files at the root of the following GitHub folder:

```
   https://github.com/starkware-libs/starkex-contracts/tree/master/
          evm-verifier/solidity/contracts/cpu

```

The audited version of the code corresponds to the commit `0efa9ce`, “StarkEx v4.0”, from
October 14th, 2021. Those 8 source files contain about 800 lines of code written in Solidity
language (excluding `CairoBootloaderProgram.sol` which is mainly auto-generated).


The second audited code implements the SHARP verifier, a.k.a. GPS (Generic Proof
Service) verifier. The latter verifies the execution of a specific Cairo program, the _boot-_


Page 4/52


Code Review of the Cairo & SHARP Verifiers


_loader_, which is also in the scope of the audit. The audited Solidity code is composed of
the 2 source files at the following GitHub repository:

```
   https://github.com /s tarkware-libs/starkex-contracts/tree/master/
          evm-verifier/solidity/contracts/gps

```

The audited version of the code corresponds to the commit `0efa9ce`, “StarkEx v4.0”, from
October 14th, 2021. Those 2 source files contain about 600 lines of code written in Solidity
language.

The audited Cairo code is composed of the simple bootloader and the (general) bootloader. The simple bootloader is composed of the 3 source files at the following GitHub
repository:

```
 https://github.com/starkware-libs/cairo-lang/tree/master/src/starkware/
          cairo/bootloaders/simple_bootloader

```

The audited version of the code corresponds to the commit `4e23351`, “Cairo v0.8.0”, from
March 13th, 2022. Those 3 source files contain about 500 lines of code written in Cairo
language. The (general) bootloader is composed of the following source file:

```
 https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/
        cairo/bootloaders/bootloader/bootloader.cairo

```

The audited version of the code corresponds to the commit `167b28b`, “ Cairo v0.9.0.”, from
June 5th, 2022. This source file contains about 350 lines of code written in Cairo language.

The different smart contracts are represented in Figures 1 and 2 with their inheritance
relations. The contracts in pink have been audited [1]. The contracts in green are out of
the scope of the present audit. The contracts in yellow are auto-generated and out of the
scope of the audit.

#### 1.2 Methodology and summary of findings


The main goal of this audit was to validate the soundness of the reviewed implementation
of the Cairo and SHARP verifiers. More precisely, this audit aims


  - to confirm that the implemented verification process is compliant to the specification
of the Cairo and SHARP verifiers,


  - to check the absence of flaw in the implementation which would allow an adversary to
forge a valid proof for an invalid statement (with less effort than the target security
level).


The audit methodology consisted in an in-depth review of the code by two different persons (engineers, junior and senior experts in cryptography), confronting our understanding
of the code and keeping track of our observations.


Our observations are categorized as follows:


Page 5/52


Code Review of the Cairo & SHARP Verifiers


Figure 1: The inheritance relations between the smart contracts of the Cairo verifier.


Figure 2: The inheritance relations between the smart contracts of the SHARP verifier.


 - Observations that may impact the soundness of the verifier, rated as


**–** high risk (flagged ●),


Page 6/52


Code Review of the Cairo & SHARP Verifiers


**–** medium risk (flagged ●),


**–** low risk (flagged ●).


  - Observations related t ~~o~~ ~~c~~ oding practices and implementation choices (flagged ●).


**–** These observations do not translate into a direct risk on the soundness of the

verifier but addressing them would make the code clearer, more efficient and/or
less prone to errors.


  - Observations related to documentation, comments, variable naming (flagged ■).


**–** These observations do not translate into a direct risk on the soundness of the

verifier but addressing them would facilitate the understanding of the code by
third parties (users, developers, auditors).


Each observation comes with an associated recommendation to fix or improve the underlying issue.


_General_ _remark._ We were provided with a clear set of documentations about Cairo [2, 5]
but sometimes missed detailed specifications for the reviewed implementation. To reach
a global and confident understanding of the implementation, we wrote down the missing
specifications according to our understanding of the code, which we include in the report
(see Section 2 for the Cairo verifier and Section 4 for the SHARP verifier).


_Summary_ _of_ _findings_ _on_ _the_ _Cairo_ _verifier._ Our findings are summarized in the table
below. Our observations are mainly related to coding practices and documentation. One
observation relates to a test which might be missing but the associated risk is considered
low. We therefore conclude that, up to the limitations inherent to human code review, the
code is a sound implementation of the Cairo verifier.


The current version of the report is an update of our original report after counterauditing modifications from StarkWare. Each observation is appended with a status:
Resolved (✓), Partially resolved ( **_∼_** ), Unresolved (✗). Most of our recommendations have
been addressed. Unresolved or partially resolved issues are related to documentation or
coding practices which are of minor importance. The updated source code corresponds
to the commit `f81ba5f` (“SHARP EVM Verifier v3.0”, from December 8th, 2022) of the
GitHub folder:

```
  https://github.com/starkware-libs/starkex2.0-contracts/tree/master/
```

`[evm-verifier/solidity/contracts/cpu](https://github.com/starkware-libs/starkex2.0-contracts/tree/master/evm-verifier/solidity/contracts/cpu)` .


**<u>Category</u>** **<u>Number</u>** **<u>of</u>** **<u>findings</u>** ✓ **_<u>∼</u>_** ✗

     - <u>High</u> <u>risk</u> <u>0</u> <u>0</u> <u>0</u> <u>0</u>

     - <u>Medium</u> <u>risk</u> <u>0</u> <u>0</u> <u>0</u> <u>0</u>

     - <u>Low</u> <u>risk</u> <u>1</u> <u>1</u> <u>0</u> <u>0</u>

     - <u>Coding</u> <u>practices</u> <u>8</u> <u>6</u> <u>0</u> <u>2</u>

     - <u>Documentation</u> <u>3</u> <u>2</u> <u>1</u> <u>0</u>
**<u>Total</u>** **<u>12</u>** **<u>9</u>** **<u>1</u>** **<u>2</u>**


Page 7/52


Code Review of the Cairo & SHARP Verifiers


_Summary_ _of_ _findings_ _on_ _the_ _SHARP_ _verifier_ _and_ _bootloader._ Our findings are summarized
in the table below. Our observations are only related to coding practices and documentation. We therefore conclude that, up to the limitations inherent to human code review,
the code is a sound implementation of the SHARP verifier and associated bootloader.


The current version of the report is an update of our original report after counterauditing modifications from StarkWare. Each observation is appended with a status:
Resolved (✓), Partially resolved ( **_∼_** ), Unresolved (✗). Most of our recommendations have
been addressed. Unresolved issues are related to documentation or coding practices which
are of minor importance. The updated source code for the SHARP verifier corresponds
to the commit `f81ba5f` (“SHARP EVM Verifier v3.0”, from December 8th, 2022) of the
GitHub folder:

```
  https://github.com/starkware-libs/starkex2.0-contracts/tree/master/
```

`[evm-verifier/solidity/contracts/gps](https://github.com/starkware-libs/starkex2.0-contracts/tree/master/evm-verifier/solidity/contracts/gps)` .


The updated source code for the bootloader corresponds to the commit `de741b9` (“Cairo
v0.10.3.”, from December 2nd, 2022) of the GitHub folder:

```
 https://github.com/starkware-libs/cairo-lang/tree/master/src/starkware/
```

`cairo/bootloaders` .


**<u>Category</u>** **<u>Number</u>** **<u>of</u>** **<u>findings</u>** ✓ **_<u>∼</u>_** ✗

     - <u>High</u> <u>risk</u> <u>0</u> <u>0</u> <u>0</u> <u>0</u>

     - <u>Medium</u> <u>risk</u> <u>0</u> <u>0</u> <u>0</u> <u>0</u>

     - <u>Low</u> <u>risk</u> <u>0</u> <u>0</u> <u>0</u> <u>0</u>

     - <u>Coding</u> <u>practices</u> <u>3</u> <u>2</u> <u>1</u> <u>0</u>

     - <u>Documentation</u> <u>5</u> <u>5</u> <u>0</u> <u>0</u>
**<u>Total</u>** **<u>8</u>** **<u>7</u>** **<u>1</u>** **<u>0</u>**


Page 8/52


Code Review of the Cairo & SHARP Verifiers

### 2 Documentation for the Cairo verifier


In this report, we use the notations and terminology introduced in


  - the article [2] which presents Cairo,


  - the ethSTARK documentation [3],


  - the code review [1] of the STARK verifier.


The present section provides some documentation for the audited Cairo verifier implementation which completes the above references.

#### 2.1 The CPU architecture


The Cairo article [2] describes the Cairo machine which behaves like a central processing
unit (CPU) executing basic instructions. The instruction set has been designed such that
there exists an efficient _algebraic_ _intermediate_ _representation_ (AIR) of the Cairo machine
processing: a loop fetching an instruction, decoding and executing that instruction, and
continuing to the next instruction. The Cairo machine has three registers:


  - the _program_ _counter_, denoted `pc`, which contains the memory address of the next
Cairo instruction to be executed,


  - the _allocation_ _pointer_, denoted `ap`, which (by convention) points to the first memory
cell that has not been used by the program so far, and


  - the _frame_ _pointer_, denoted `fp`, which (by convention) points to the beginning of the
stack frame of the current function (see Section 2.4).


Moreover, the CPU has access to a _nondeterministic_ _continuous_ _read-only_ _memory_ m. To
represent a value of the memory at the address _a_, we use m( _a_ ) or [a]. Since the memory is
read-only, we can write without ambiguity that an address _a_ has a value _v_, _i.e._ m( _a_ ) = _v_,
since the value cannot change.

The address space and value range are both defined as the field F _p_ used for the underlying AIR (see _e.g._ [3, 1]), hence the memory can be seen as a function m : F _p_ _→_ F _p_ .

#### 2.2 Builtins


The Cairo machine further relies on _builtins_ which offer a way to efficiently perform some
specific computation tasks. For example, a call to the Pedersen builtin enables the Cairo
developer to compute the Pedersen hash digest of two field elements without needing
to implement this functionality in Cairo syntax. The idea is similar to the addition of
optimized low-level execution units (a.k.a. co-processors) to a physical CPU.

A builtin aims to perform a specific computation which involves several field elements.
A builtin _instance_ is a set of those field elements and the _size_ of the instance is defined as


Page 9/52


Code Review of the Cairo & SHARP Verifiers


the size of this set. For example, the Pedersen builtin aims to check that _z_ = Hash( _x, y_ )
where _x_, _y_ and _z_ are three field elements. In this case, the size of the builtin instance is
three.

Each builtin is assigned to a memory segment which is split into small chunks. Each
chunk corresponds to a builtin instance, and the values stored on a chunk must satisfy the
relation of the builtin. In the case of the Pedersen builtin, the memory segment has the
form


_<u>a</u>_ _<u>a</u>_ <u>+ 1</u> _<u>a</u>_ <u>+ 2</u> _<u>a</u>_ <u>+ 3</u> _<u>. . .</u>_
m( _·_ ) _<u>x</u>_ <u>1</u> _<u>y</u>_ <u>1</u> _<u>z</u>_ <u>1</u> _<u>x</u>_ <u>2</u> _<u>y</u>_ <u>2</u> _<u>z</u>_ <u>2</u> _<u>x</u>_ <u>3</u> _<u>y</u>_ <u>3</u> _<u>z</u>_ <u>3</u> _<u>. . .</u>_


where _a_ is the first address of the memory segment, and the AIR constraints will impose
that the relation

_zi_ = Hash( _xi, yi_ )


is verified for all _i_ . In practice, to use this builtin in a Cairo program, the developer simply
needs to assert m( _a_ +3 _i_ ) = _xi_ and m( _a_ +3 _i_ +1) = _yi_ for some _i_, and then she can consider
that m( _a_ + 3 _i_ + 2) contains the hash digest _zi_ = Hash( _xi, yi_ ).

In order to use a builtin, a Cairo developer needs to know the address of the first unused
instance. To proceed, she will always store and update the pointer to this address. We
call this pointer the _builtin_ _pointer_ . The number of builtin instances is limited by the size
of the memory segment allocated to the builtin. This number is given by the number _T_ of
state transitions (see next section) and a parameter _r_ called _builtin_ _ratio_ via the formula


_<u>T</u>_
_r_ = `max_nb_instances` <sup>_._</sup>


The audited version of Cairo includes the five following builtins:


  - Output (to output data from the Cairo program),


  - Pedersen (to compute a Pedersen hash of two field values),


  - Range-check (to check a value belong to some predefined range),


  - ECDSA (to verify an ECDSA signature),


  - Bitwise (to compute the bitwise AND, XOR, OR between two field values).

#### 2.3 Execution of a program


A state of the Cairo machine is a triple of register values ( `pc` _,_ `ap` _,_ `fp` ). The execution of
a program can thus be represented as a sequence of states ( `pc` _i,_ `ap` _i,_ `fp` _i_ ) _i_ and a memory
function m : F _p_ _→_ F _p_ (which to each address _a_ accessed by the program associates a value
_v_ such that m( _a_ ) = _v_ ). The transition between two states is defined by the instruction
pointed by the `pc` register:



( `pc` _i,_ `ap` _i,_ `fp` _i_ )



m( `pc` _i_ )
_−−−−→_ ( `pc` _i_ +1 _,_ `ap` _i_ +1 _,_ `fp` _i_ +1) _._


Page 10/52


Code Review of the Cairo & SHARP Verifiers


We denote _T_ the number of steps (or state transitions) in the program execution.

The execution trace which is the input statement of the STARK verifier is a large
two-dimensional array of _W_ <u>columns and</u> _L_ rows. The number of columns _W_ is defined by
the Cairo layout and depends on the used builtins (see hereafter). Each state of the Cairo
machine is represented by a small set of successive rows called _component_ . We denote
`CPU_COMPONENT_HEIGHT` the number of rows in a component. The trace length _L_ ( _i.e._ its
total number of rows) is then given by


_L_ := `CPU_COMPONENT_HEIGHT` _· T._


In a component, we can find the current values of the registers `pc`, `ap` and `fp` . We can also
find all the intermediate variables of the state transition described in Section 4.5 of [2].
Let us remark that the final state ( _i.e._ the state of the Cairo machine after _T_ steps) is not
represented in the execution trace. The AIR constraints check that the last instruction is
well executed (and that the resulting memory mapping is correct) but they do not check
the final values of the three registers ( `pc` _,_ `ap` _,_ `fp` ).

We call _layout_ the organization of all the variables in the execution trace. A layout
depends on which builtins are supported, but it also depends on the configuration of those
builtins (how many times the builtins can be used, _i.e._ the building ratio, the size of its
instances, etc.). Defining a layout consists in choosing a trade-off between universality ( _i.e._
the scope of the Cairo programs which can use this layout) and performances ( _e.g._ minimal
number of trace cells). Indeed, improving the universality of a layout implies increasing
the number of constraints and the number of columns in the execution trace.

The audited source code includes four different layouts. Table 1 summarizes the parameters of those layouts. To illustrate the aforementioned trade-off, let us compare Layout
1 and Layout 2. Both support the same builtins though Layout 2 is cheaper to verify:
it has only 10 columns, compared to 22 columns for Layout 1. On the other hand, the
Cairo programs supported by Layout 1 can make more calls to the builtins compared to
the programs supported by Layout 1 (see the corresponding builtin ratios).

As an illustration, Table 2 describes the structure of a component for Layout 1. All the
notations are introduced in Section 9.10 “List of constraints” of the Cairo article [2]. The
columns which are not described in Table 2 correspond to intermediate variables dedicated
to the builtins.

The 17th column contains all the memory accesses during the program execution,
where an odd row contains the memory address while the next even row contains the
associated value. The 18th column contains the same list of memory accesses but sorted
with increasing memory addresses. These two columns correspond to the lists _L_ 1 and _L_ 2
described in Sections 9.7 and 9.8 of the Cairo article [2]. The AIR constraints impose
that _L_ 2 is a permutation of _L_ 1 (same pairs address-value with same occurrences) which
is a continuous (the addresses are consecutive) and read-only (all the memory accesses to
a given address read the same value). In practice, _L_ 2 is further _padded_ as explained in
Section 2.5.2.

The 21st column contains the cumulative products ( _p_ <sup>m</sup> for memory and _p_ <sup>rc</sup> for rangecheck) which are added to the trace after the interaction step (see Section 9.8 of the Cairo
paper [2]).


Page 11/52


Code Review of the Cairo & SHARP Verifiers


<u>Layout</u> <u>0</u> <u>Layout</u> <u>1</u> <u>Layout</u> <u>2</u> <u>Layout</u> <u>3</u>
<u>`Nb`</u> <u>`of`</u> <u>`interaction`</u> <u>`elements`</u> <u>3</u> <u>3</u> <u>3</u> <u>6</u>
<u>`Mask`</u> <u>`Size`</u> _<u>M</u>_ <u>1</u> <u>201</u> <u>200</u> <u>128</u> <u>291</u>
<u>`Number`</u> <u>`of`</u> <u>`rows`</u> <u>`involved`</u> <u>`in`</u> <u>`mask`</u> <u>81</u> <u>82</u> <u>79</u> <u>164</u>
<u>`Number`</u> _<u>W</u>_ <u>`of`</u> <u>`columns`</u> <u>25</u> <u>22</u> <u>10</u> <u>27</u>
<u>`Nb`</u> <u>`of`</u> <u>`columns`</u> <u>`before`</u> <u>`interaction`</u> <u>23</u> <u>21</u> <u>9</u> <u>24</u>
<u>`Nb`</u> <u>`of`</u> <u>`columns`</u> <u>`after`</u> <u>`interaction`</u> <u>2</u> <u>1</u> <u>1</u> <u>3</u>
<u>`Public`</u> <u>`Memory`</u> <u>`Step`</u> <u>8</u> <u>8</u> <u>8</u> <u>16</u>
<u>`Pedersen`</u> <u>`Builtin`</u> <u>`Ratio`</u> <u>8</u> <u>8</u> <u>32</u> <u>8</u>
<u>`Range-check`</u> <u>`Builtin`</u> <u>`Ratio`</u> <u>8</u> <u>8</u> <u>16</u> <u>8</u>
<u>`ECDSA`</u> <u>`Builtin`</u> <u>`Ratio`</u> <u>512</u> <u>512</u> <u>2048</u> <u>512</u>
<u>`Bitwise`</u> <u>`Builtin`</u> <u>`Ratio`</u> <u>-</u> <u>-</u> <u>-</u> <u>256</u>


Table 1: Parameters of the implemented layouts.

#### 2.4 The main function


The entry point of a Cairo program is always the function `main`, from which Cairo supports
(recursive) function calls. The Cairo paper suggests to implement a function call stack in
the following way:


_The_ _frame_ _pointer_ _register_ _(_ _`fp`_ _)_ _points_ _to_ _the_ _current_ _frame_ _in_ _the_ _“call_ _stack”._
_As_ _you_ _will_ _see,_ _it_ _is_ _convenient_ _not_ _to_ _define_ _`fp`_ _as_ _the_ _beginning_ _of_ _the_ _frame_
_but_ _rather_ _as_ _the_ _beginning_ _of_ _the_ _local_ _variables’_ _section,_ _in_ _a_ _similar_ _way_ _to_
_the_ _behavior_ _of_ _the_ _stack_ _in_ _common_ _architectures._ _Each_ _frame_ _consists_ _of_ _four_
_parts_ _(_ _`fp`_ _refers_ _to_ _the_ _current_ _frame):_


_1._ _The_ _arguments_ _of_ _the_ _function_ _provided_ _by_ _the_ _caller._ _For_ _example,_ _[_ _`fp`_ _-_
_3],_ _[_ _`fp`_ _-_ _4],_ _..._


_2._ _Pointer_ _to_ _the_ _caller_ _function’s_ _frame._ _Located_ _at_ _[_ _`fp`_ _-_ _2]._


_3._ _The_ _address_ _of_ _the_ _instruction_ _to_ _be_ _executed_ _once_ _the_ _function_ _returns_
_(the_ _instruction_ _following_ _the_ _call_ _instruction)._ _Located_ _at_ _[_ _`fp`_ _-_ _1]._


_4._ _Local_ _variables_ _allocated_ _by_ _the_ _function._ _For_ _example,_ _`fp`_ _,_ _`fp`_ _`+`_ _`1`_ _,_ _..._


_In_ _addition,_ _the_ _return_ _values_ _of_ _the_ _function_ _are_ _placed_ _in_ _the_ _memory_ _at_ _`[ap`_

_`-`_ _`1]`_ _,_ _`[ap`_ _`-`_ _`2]`_ _,_ _..._ _,_ _where_ _`ap`_ _is_ _the_ _value_ _of_ _the_ _ap_ _register_ _at_ _the_ _end_ _of_ _the_
_function._


                                - Cairo article [2]


To parse the program input, a Cairo developer shall use _hints_ . Hints are pieces of code
that are inserted between Cairo instructions where additional work is required by the prover
(see Section 2.5 of [2]). The program inputs are available in the hint scope thanks to the


Page 12/52


Code Review of the Cairo & SHARP Verifiers


<u>0</u> _<u>. . .</u>_ <u>17</u> <u>18</u> <u>19</u> _<u>. . .</u>_ <u>21</u>
<u>0</u> _<u>f</u>_ <u>˜0</u> _<u>. . .</u>_ <u>`pc`</u> _<u>a</u>_ <sup>_′_</sup> <sup>m</sup> <u>`off`</u> ˜ <u>`dst`</u> _<u>. . .</u>_ _<u>p</u>_ <sup>m</sup>

<u>1</u> _<u>f</u>_ <u>˜1</u> _<u>. . .</u>_ <u>`inst`</u> _<u>v</u>_ <sup>_′_</sup> <sup>m</sup> <u>`ap`</u> _<u>. . .</u>_ _<u>p</u>_ <sup>rc</sup>

<u>2</u> _<u>f</u>_ <u>˜2</u> _<u>. . .</u>_ <u>0</u> <u>(</u> _<u>p.m.</u>_ <u>)</u> _<u>a</u>_ <sup>_′_</sup> <sup>m</sup> _<u>a</u>_ <sup>_′_</sup> <sup>rc</sup> _<u>. . .</u>_ _<u>p</u>_ <sup>m</sup>

<u>3</u> _<u>f</u>_ <u>˜3</u> _<u>. . .</u>_ <u>0</u> <u>(</u> _<u>p.m.</u>_ <u>)</u> _<u>v</u>_ <sup>_′_</sup> <sup>m</sup> _<u>t</u>_ <u>0</u> _<u>. . .</u>_
<u>4</u> _<u>f</u>_ <u>˜4</u> _<u>. . .</u>_ <u>`op0_addr`</u> _<u>a</u>_ <sup>_′_</sup> <sup>m</sup> <u>`off`</u> ˜ <u>`op1`</u> _<u>. . .</u>_ _<u>p</u>_ <sup>m</sup>

<u>5</u> _<u>f</u>_ <u>˜5</u> _<u>. . .</u>_ <u>`op0`</u> _<u>v</u>_ <sup>_′_</sup> <sup>m</sup> <u>`mul`</u> _<u>. . .</u>_ _<u>p</u>_ <sup>rc</sup>

<u>6</u> _<u>f</u>_ <u>˜6</u> _<u>. . .</u>_ _<u>builtin</u>_ _<u>addr</u>_ _<u>a</u>_ <sup>_′_</sup> <sup>m</sup> _<u>a</u>_ <sup>_′_</sup> <sup>rc</sup> _<u>. . .</u>_ _<u>p</u>_ <sup>m</sup>

<u>7</u> _<u>f</u>_ <u>˜7</u> _<u>. . .</u>_ _<u>builtin</u>_ _<u>value</u>_ _<u>v</u>_ <sup>_′_</sup> <sup>m</sup> _<u>. . .</u>_
<u>8</u> _<u>f</u>_ <u>˜8</u> _<u>. . .</u>_ <u>`dst_addr`</u> _<u>a</u>_ <sup>_′_</sup> <sup>m</sup> <u>`off`</u> ˜ <u>`op0`</u> _<u>. . .</u>_ _<u>p</u>_ <sup>m</sup>

<u>9</u> _<u>f</u>_ <u>˜9</u> _<u>. . .</u>_ <u>`dst`</u> _<u>v</u>_ <sup>_′_</sup> <sup>m</sup> <u>`fp`</u> _<u>. . .</u>_ _<u>p</u>_ <sup>rc</sup>

<u>10</u> _<u>f</u>_ <u>˜10</u> _<u>. . .</u>_ <u>0</u> <u>(</u> _<u>p.m.</u>_ <u>)</u> _<u>a</u>_ <sup>_′_</sup> <sup>m</sup> _<u>a</u>_ <sup>_′_</sup> <sup>rc</sup> _<u>. . .</u>_ _<u>p</u>_ <sup>m</sup>

<u>11</u> _<u>f</u>_ <u>˜11</u> _<u>. . .</u>_ <u>0</u> <u>(</u> _<u>p.m.</u>_ <u>)</u> _<u>v</u>_ <sup>_′_</sup> <sup>m</sup> _<u>t</u>_ <u>1</u> _<u>. . .</u>_
<u>12</u> _<u>f</u>_ <u>˜12</u> _<u>. . .</u>_ <u>`op1_addr`</u> _<u>a</u>_ <sup>_′_</sup> <sup>m</sup> _<u>. . .</u>_ _<u>p</u>_ <sup>m</sup>

<u>13</u> _<u>f</u>_ <u>˜13</u> _<u>. . .</u>_ <u>`op1`</u> _<u>v</u>_ <sup>_′_</sup> <sup>m</sup> <u>`res`</u> _<u>. . .</u>_ _<u>p</u>_ <sup>rc</sup>

<u>14</u> _<u>f</u>_ <u>˜14</u> _<u>. . .</u>_ _<u>a</u>_ <sup>_′_</sup> <sup>m</sup> _<u>a</u>_ <sup>_′_</sup> <sup>rc</sup> _<u>. . .</u>_ _<u>p</u>_ <sup>m</sup>

<u>15</u> _<u>f</u>_ <u>˜15</u> _<u>. . .</u>_ _<u>v</u>_ <sup>_′_</sup> <sup>m</sup> _<u>. . .</u>_
_L_ 1 _L_ 2


Table 2: Extract of the structure of a component for Layout 1.


Python dictionary `program_input` . The function `main` does not take a user-defined input.
The only arguments of this function are _builtin_ _pointers_, like in the following example:

```
% builtins output pedersen

from starkware.cairo.common. cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2

# Implicit arguments: addresses of the output and pedersen builtins.
func main{output_ptr, pedersen_ptr : HashBuiltin *}():
   ...

   # output_ptr and pedersen_ptr will be implicitly returned.
   return ()
end

```

In the above example, although they are implicit, the function `main` takes two arguments: the output builtin pointer and the Pedersen builtin pointer. In a similar way, the
returned values of `main` do not correspond to the program output but to the updated
builtin pointers, _i.e._ the new position of the first unused instance of each builtin. The
program output is returned through the output builtin.

At the start of the execution, the registers `pc` and `ap` are fixed to some values by
definition of the Cairo machine. In practice, the register `pc` is always initialized with the
address 1. Let us stress that the address 0 is kept for the `null` pointer ( _i.e._ m(0) is not


Page 13/52


Code Review of the Cairo & SHARP Verifiers


defined). Then, the register `fp` is initialized with the same value as `ap` . While compiling a
Cairo program, the compiler add the following instructions at the beginning of the memory
( _i.e._ at address 1 pointed by <u>`pc`</u> at start):

```
          ap += n_args; call main; jmp rel 0.

```

The second instruction calls the function `main`, where the label `main` is replaced by the
absolute position of the function in the bytecode. The last instruction is an infinite loop
which does not change the register state:



( `pc` _F,_ `ap` _F,_ `fp` _F_ )


```
jmp rel 0
```

_−−−−−−→_ ( `pc` _F,_ `ap` _F,_ `fp` _F_ ) _._



Due to those instructions, the final program counter `pc` _F_ is `5` (the three above instructions
are respectively stored on two memory cells at addresses 1, 3, and 5).

#### 2.5 Public memory


The Cairo verifier aims to check that a prover knows an execution trace of a given program
on the Cairo machine. Such an execution trace involves a memory mapping (let us recall
that the memory of the Cairo machine is read-only). Some values of this memory mapping
are publicly known, _i.e._ are part of the statement to be checked. For example, the memory
chunk which contains the program bytecode is usually public. This public part of the
memory is called the _public_ _memory_ which is denoted m <sup>_∗_</sup> in the Cairo documentation.
The public memory can be thought of as a restriction of the memory m to a domain
_A_ <sup>_∗_</sup> _⊂_ F _p_ (the addresses of the public memory cells). The verifier must check that the
execution trace committed by the prover is consistent with m <sup>_∗_</sup> .


2.5.1 Pages of the public memory


The public memory m <sup>_∗_</sup> can be represented as a list _{_ ( _a, v_ ) ; _a ∈_ _A_ <sup>_∗_</sup> _,_ m <sup>_∗_</sup> ( _a_ ) = _v}_ of memory
addresses with their corresponding values. In practice, the memory is divided in several
pages. Each page contains a part m <sup>_∗_</sup> _i_ <sup>of</sup> <sup>the</sup> <sup>public</sup> <sup>memory,</sup> <sup>which</sup> <sup>forms</sup> <sup>a</sup> <sup>partition</sup> <sup>of</sup> <sup>the</sup>

public memory:



m <sup>_∗_</sup> =






_i_



m <sup>_∗_</sup> _i_ <sup>_._</sup>



The pages are part of the statement to check. The first page is a _regular_ one, meaning
that this page corresponds to a list of pairs address-value. The other pages are _continuous_
ones, _i.e._ all the addresses in a same page are adjacent (a continuous page can be encoded
by its starting address and the list of consecutive values).


2.5.2 Padding of the public memory


Some cells of the execution trace are dedicated to the public memory. The number of such
cells is defined as

_<u>L</u>_
_S_ :=
```
                PUBLIC_MEMORY_STEP

```

Page 14/52


Code Review of the Cairo & SHARP Verifiers


where `PUBLIC_MEMORY_STEP` is a parameter of the layout (we introduce the notation _S_ here
for our purpose). This means that the size of the public memory _|A_ <sup>_∗_</sup> _|_ must be lower than
(or equal to) this number. Note that the trace length can be artificially increased to satisfy
this constraint thanks to the final infinite-loop instruction (see Section 2.4).

When _|A_ <sup>_∗_</sup> _|_ is strictly lower than _S_ (which occurs most of the time), the remaining cells
must be filled with 0’s in the (unsorted) virtual column _L_ 1, while they are filled with pairs
( _a_ pad _,_ m <sup>_∗_</sup> ( _a_ pad)) for the (sorted) virtual column _L_ 2, where _a_ pad is a valid address of _A_ <sup>_∗_</sup>

different from 0. This padding is taken into account in the formula for the final ratio _p_ <sup>m</sup>

which enables to check the public memory. Instead of simply having


_<u>z</u>_ <sup>_|A∗|_</sup>

<u>�</u>
_a∈A_ <sup>_∗_</sup> <sup>(</sup> <sup>_z −_</sup> <sup>(</sup> <sup>_a_</sup> <sup>+</sup> <sup>_α ·_</sup> <sup>m</sup> <sup>_∗_</sup> <sup>(</sup> <sup>_a_</sup> <sup>)))</sup> <sup>_,_</sup>


for this ratio (as explained in Section 9.8 of the Cairo paper [2]), we then have:



_<u>z</u>_ <sup>_S_</sup>

( _z −_ ( _a_ pad + _α ·_ m <sup>_∗_</sup> ( _a_ pad))) <sup>_S−|A∗|_</sup> _·_ <sup><u>�</u></sup>



_a∈A_ <sup>_∗_</sup> <sup>(</sup> <sup>_z −_</sup> <sup>(</sup> <sup>_a_</sup> <sup>+</sup> <sup>_α ·_</sup> <sup>m</sup> <sup>_∗_</sup> <sup>(</sup> <sup>_a_</sup> <sup>)))</sup> <sup>_._</sup>


#### 2.6 Public input and verified statement

The parameters of the statement are stored in an array called the _public_ _input_ . The format of this array is defined in the smart contract `CpuPublicInputOffsets` (which further
inherits from `CpuPublicInputOffsetsBase` and `PageInfo` ). The structure of the public
input is summarized in Table 3. We note that, the cumulative products of the public
memory pages are not formally part of the public input but part of the proof.

Based on this public input, the statement to be verified is the following: _There_ _exists_
_a_ _valid_ _execution_ _trace_ _of_ _T_ _steps_ _on_ _the_ _Cairo_ _machine:_


_1._ _with_ _layout_ _corresponding_ _to_ _`LAYOUT_CODE`_ _,_


_2._ _which_ _starts_ _with_ ( _`pc`_ _I_ _,_ _`ap`_ _I_ _,_ _`fp`_ _I_ := _`ap`_ _I_ ) _,_


_3._ _which_ _finishes_ _with_ ( _`pc`_ _F,_ _`ap`_ _F,_ _`fp`_ _F_ := _`fp`_ _I_ ) _,_ <sup>1</sup>



_4._ _for_ _some_ _memory_ m _which_ _is_ _continuous_ _read-only_ _and_ _consistent_ _with_ _a_ _public_ _mem-_
_ory_ m <sup>_∗_</sup> := <sup>�</sup> _i_ <sup>m</sup> _i_ <sup>_∗_</sup> <sup>_matching_</sup> <sup>_the_</sup> <sup>_pages’_</sup> <sup>_information_</sup> <sup>_from_</sup> <sup>_the_</sup> <sup>_public_</sup> <sup>_input_</sup> <sup>_array_</sup> <sup>_(in_</sup>



_i_ <sup>m</sup> _i_ <sup>_∗_</sup>



_ory_ m <sup>_∗_</sup> := <sup>�</sup> _i_ <sup>m</sup> _i_ <sup>_∗_</sup> <sup>_matching_</sup> <sup>_the_</sup> <sup>_pages’_</sup> <sup>_information_</sup> <sup>_from_</sup> <sup>_the_</sup> <sup>_public_</sup> <sup>_input_</sup> <sup>_array_</sup> <sup>_(in_</sup>

_particular_ _the_ _pages’_ _sizes_ _and_ _hash_ _values),_



_5._ _where_ _range-check_ _values_ _are_ _between_ _`RC_MIN`_ _and_ _`RC_MAX`_ _,_


_6._ _where_ _the_ _unused_ _cells_ _for_ _public_ _memory_ _are_ _filled_ _with_ m( _apad_ ) = _apad_ _in_ _the_ _L_ 2
_column_ _of_ _the_ _execution_ _trace,_


1Let us stress that ( `pc` _F,_ `ap` _F,_ `fp` _F_ ) should correspond the last _executed_ state, and not the state after
the _T_ steps (as explained in Section 2.3.


Page 15/52


Code Review of the Cairo & SHARP Verifiers


**<u>Field</u>** **<u>Description</u>**

<u>`LOG_N_STEPS`</u> <u>Log</u> <u>(in</u> <u>base</u> <u>2)</u> <u>of</u> <u>the</u> <u>number</u> <u>of</u> <u>states</u> _<u>T</u>_
<u>`RC_MIN`</u> <u>Min</u> <u>range-check</u> <u>value</u>
<u>`RC_MAX`</u> <u>Max</u> <u>range-check</u> <u>value</u>
<u>`LAYOUT_CODE`</u> <u>The</u> <u>layout</u> <u>identifier</u>
<u>`PROGRAM_BEGIN_ADDR`</u> <u>pc</u> _<u>I</u>_
<u>`PROGRAM_STOP_PTR`</u> <u>pc</u> _<u>F</u>_
<u>`EXECUTION_BEGIN_ADDR`</u> <u>ap</u> _<u>I</u>_
<u>`EXECUTION_STOP_PTR`</u> <u>ap</u> _<u>F</u>_
<u>`<BUILTIN>_BEGIN_ADDR`</u> <u>Builtin</u> <u>pointer</u> <u>(argument</u> <u>of</u> <u>`main`</u> <u>)</u>
<u>`<BUILTIN>_STOP_PTR`</u> <u>Updated</u> <u>builtin</u> <u>pointer</u> <u>(returned</u> <u>by</u> <u>`main`</u> <u>)</u>
<u>`PUBLIC_MEMORY_PADDING_ADDR`</u> _<u>a</u>_ <u>pad</u>
<u>`PUBLIC_MEMORY_PADDING_VALUE`</u> <u>m(</u> _<u>a</u>_ <u>pad)</u>
<u>`N_PUBLIC_MEMORY_PAGES`</u> <u>Number</u> <u>of</u> <u>public</u> <u>memory</u> <u>pages</u>


_For_ _each_ _page_ _i:_



<u>First</u> <u>address</u> <u>in</u> <u>the</u> <u>page</u> <u>First</u> <u>address</u> <u>of</u> <u>m</u> <sup>_<u>∗</u>_</sup> _<u>i</u>_



<u>First</u> <u>address</u> <u>in</u> <u>the</u> <u>page</u> <u>First</u> <u>address</u> <u>of</u> <u>m</u> <sup>_<u>∗</u>_</sup> _<u>i</u>_ <sup><u>(except</u></sup> <sup><u>for</u></sup> <sup>_<u>i</u>_</sup> <sup><u>= 0)</u></sup>

<u>Page</u> <u>size</u> <u>Size</u> <u>of</u> <u>m</u> <sup>_<u>∗</u>_</sup> _<u>i</u>_



_<u>i</u>_
<u>Page</u> <u>hash</u> <u>Hash</u> <u>of</u> <u>m</u> <sup>_<u>∗</u>_</sup> _<u>i</u>_



_<u>i</u>_



_For_ _each_ _page_ _i:_




<sup>_∗_</sup> _<u>i</u>_ <sup>(</sup> <sup>_z −_</sup> <sup>(</sup> <sup>_a_</sup> <sup>+</sup> <sup>_α ·_</sup> <sup>m</sup> _<u>i</u>_ <sup>_<u>∗</u>_</sup>



Cumulative product <u>�</u> _<u>a∈A</u>_ <sup>_∗_</sup>

_<u>i</u>_



_<u>i</u>_ <sup>_<u>∗</u>_</sup> <sup>(</sup> <sup>_a_</sup> <sup>)))</sup>



Table 3: Structure of the public input.


_7._ _where_ _the_ _builtin_ _segments_ _start_ _at_ _the_ _addresses_ _`<BUILTIN>_BEGIN_ADDR`_ _._ <sup>2</sup>


We note that although `pc` _I_ and `pc` _F_ are part of the public input, the current implementation of the Cairo verifier assumes (and only supports) `pc` _I_ := 1 and `pc` _F_ := 5 (as
explained in Section 2.4).


In practice, additional constraints must be enforced by the caller of the Cairo verifier
in order to ensure the global computational integrity of the Cairo program. Namely, the
above list should be completed with:


_8._ _where_ _the_ _corresponding_ _bytecode_ _includes_ _a_ _function_ _`main`_ _,_


_9._ _where_ _the_ _arguments_ _of_ _`main`_ _match_ _the_ _set_ _of_ _`<BUILTIN>_BEGIN_ADDR`_ _,_


2This item fixes all the addresses of the builtin segments since those segments are continuous and their
size is determined by the max number of instances (defined by the builtin ratio). We stress that the validity
of the execution trace requires the validity of all the instances on the builtin segment.


Page 16/52


Code Review of the Cairo & SHARP Verifiers


_10._ _where_ _the_ _returned_ _values_ _by_ _`main`_ _match_ _the_ _set_ _of_ _`<BUILTIN>_STOP_PTR`_ _(and_ _in_
_particular_ _`main`_ _properly_ _returns),_


_11._ _where_ m( _`fp`_ _I_ _−_ 2) = _`f`_ _~~`p`~~_ _I_ _and_ m( _`fp`_ _I_ _−_ 1) = 0 _._ <sup>3</sup>


These items should be verified by the caller of the `CpuVerifier` contract (that is the
SHARP verifier in the context of the present audit - see Section 4), hence they should be
reformulated as constraints on the public memory m <sup>_∗_</sup> .

#### 2.7 Verifier dependencies


The CPU verifier contract is derived from several smart contracts. The parent contract
`LayoutSpecific` and its own parent contract `StarkParameters` do not have a unique
implementation and both depend on the selected layout. The verifier also calls external
smart contracts, namely the `CpuOODS` and `CpuConstraintPoly` contracts. In practice, those
four contracts are autogenerated according to the selected layout. In this section, we give
an overview of those contracts.


2.7.1 Contract `StarkParameters`


To be functional, the CPU verifier requires some constants related to the format of the execution trace and the AIR constraints which are defined in the smart contract `StarkParameters`
(an autogenerated parent contract of `LayoutSpecific` ). We summarize those constants
hereafter (the notations are from the ethSTARK documentation [3] and our previous audit [1]):


  - `N_COEFFICIENTS` : Number of coefficients _{αj}j ∪{βj}j_ to build the composition polynomial from the AIR polynomial constraints.


  - `N_INTERACTION_ELEMENTS` : Number of F _p_ elements that the IOP verifier must sample
for the interaction step.


  - `MASK_SIZE` : Mask size _M_ 1, _i.e._ size of _{yℓ}ℓ_ .


  - `N_ROWS_IN_MASK` : Number of rows involved in the mask _{yℓ}ℓ_ .


  - `N_COLUMNS_IN_MASK` : Number of columns involved in the mask _{yℓ}ℓ_, which must be
equal to the number of columns in the execution trace.


  - `N_COLUMNS_IN_TRACE0` : Number of committed trace columns in the first round.


  - `N_COLUMNS_IN_TRACE1` : Number of committed trace columns in the second round
(after sampling the interaction elements).


3This item is required to guarantee the “safe call” feature (that is, all “call” instructions will return,
even if the called function is malicious). This feature guarantees the impossibility of creating a cycle in
the call stack.


Page 17/52


Code Review of the Cairo & SHARP Verifiers


  - `CONSTRAINTS_DEGREE_BOUND` : Number _M_ 2 of composition polynomial trace columns.
All the constraints must have a degree of at most _M_ 2.


  - `N_OODS_VALUES` : Num ~~ber~~ _M_ 1 + _M_ 2 of OODS values _{yℓ}ℓ_ _∪{y_ ˆ _i}i_ .


  - `N_OODS_COEFFICIENTS` : Number _M_ 1 + _M_ 2 of OODS coefficients _{γi}i_ .


  - `PUBLIC_MEMORY_STEP` : Frequency of an address-value pair in the public memory in
the execution trace. This constant defines


_<u>L</u>_
`PUBLIC_MEMORY_SIZE` =
```
                     PUBLIC_MEMORY_STEP

```

where _L_ is the trace length and `PUBLIC_MEMORY_SIZE` is the size that is allocated to
the public memory.


  - `LAYOUT_CODE` : Unique layout identifier. Used to verify if the program to check has
been compiled with the verifier’s layout.


  - `LOG_CPU_COMPONENT_HEIGHT` : The logarithm of the component height (see Section 2.3),
satisfying

_L_ = _T_ _·_ 2 <sup>`LOG_CPU_COMPONENT_HEIGHT`</sup> _._


Constants about the builtins’ configuration are further defined, such as `<BUILTIN>_RATIO`
which corresponds to the builtin ratio (see Section 2.2), and `<BUILTIN>_REPETITIONS` for
periodic columns.


2.7.2 Contract `LayoutSpecific`


The contract `LayoutSpecific` gathers all the layout-specific functions and in particular
functions dealing with builtins. `LayoutSpecific` must implement the function `getLayoutInfo`
requested by the interface `CairoVerifierContract` . To be compatible with the audited
smart contract `CpuVerifier` (which inherits from `LayoutSpecific` ), it must further implement the following functions:


  - `initPeriodicColumns` which initializes the contracts relative to periodic columns,


  - `layoutSpecificInit` which initializes the builtin-relative fields of the verifier state
and which performs some sanity checks on the builtin pointers,


  - `prepareForOodsCheck` which prepares the builtin-relative values for the OODS contract.


2.7.3 Contract `CpuConstraintPoly`



Using the notations of [3] and [1], an AIR polynomial constraint (represented as a rational
function) is denoted _Cj_ and its degree _Dj_ . Let us recall that the composition polynomial
_h_ is then in the form



_Cj_ ( _x_ )



_h_ ( _x_ ) =



_k_





- _αjx_ <sup>_D−Dj_</sup> <sup>_−_</sup> <sup>1</sup> + _βj_







_j_ =1



Page 18/52


Code Review of the Cairo & SHARP Verifiers


where _k_ is the number of constrains, _D_ is the smallest power of two which is greater than
all the constraint degrees, and _{αj}j_ _∪{βj}j_ are verifier challenges (sampled using the
Fiat-Shamir heuristic while <u>building</u> the non-interactive proof).

Given the OODS point _z_, the coefficients _{αj}j_ _∪{βj}j_ and some constraint-relative
information (like the offsets of some boundary constraints and the interaction elements),
the contract `CpuConstraintPoly` must return the evaluation of the composition polynomial
at the OODS point, _i.e._ it must return _h_ ( _z_ ) evaluated through the above equation.

In practice, this contract is autogenerated with the corresponding composition polynomial which is hardcoded. It uses a strategy of batching for the inverses (the denominators
of rational functions _Cj_ ).


2.7.4 Contract `CpuOODS`


This contract corresponds to the OODS contract described in Section 2.5.2 of the previous audit report [1]. This contract is called by the STARK verifier while verifying the
proof (specifically it is called by the auxiliary function `computeFirstFriLayer` of the
`verifyProof` function). It must return the evaluations for the FRI queries of the DEEP
composition polynomial and the inverses of all the evaluation points. We refer to the
previous report for detailed specifications [1].


Page 19/52


Code Review of the Cairo & SHARP Verifiers

### 3 Review of the Cairo verifier

#### 3.1 Management of th e public inputs


3.1.1 Contract `PageInfo`


The contract `PageInfo` defines some constants (size and offsets) relative to the page information included in the public input of the program (for each page of the public memory

- see Section 2.5.1). Specifically, it defines the size of a page information (3 memory cells,
or 3 _∗_ 32 bytes) as well as the offsets of each field in the page information, namely the first
address of the page, the page size, and the page hash digest (as described in Section 2.6).


3.1.2 Contract `CpuPublicInputOffsetsBase`


The contract `CpuPublicInputOffsetsBase`, which inherits from `PageInfo`, defines some
offsets for the fields of the public input (which are listed in Section 2.6). Specifically, it includes all the fields which are not relative to the builtins ( _e.g._ `LOG_N_STEPS`, `LAYOUT_CODE`,
...) which are placed at the beginning of the public input, as well as the fields relative to the
builtins which are common to each layout (namely the output, Pedersen and range check
builtins). The contract `CpuPublicInputOffsetsBase` further defines a constant for the
number of field elements per public memory entry (which equals to 2) as well as the initial
and final values of the program counter `pc` _I_ and `pc` _F_ (which equal 1 and 5 as explained in
Section 2.4).


 - **Observation** **1:** **Ambiguous** **constant** **name**


The constant `N_WORDS_PER_PUBLIC_MEMORY_ENTRY` corresponds to the number of 256bit words which represent a memory mapping for an address in the case of a regular
page (which is 2). Up to our understanding, this constant name is not explicit and it
does not correspond to a parameter that could take different values.


**Recommendation:** We recommend to simply remove this constant (and replace it
by 2), or to rename it with a more explicit name (referring to regular pages) and to
move it in the contract `PageInfo` since it is relative to pages of the public memory.


**Status:** **Resolved** **(** ✓ **)**
This constant has been renamed as `MEMORY_PAIR_SIZE` and it has been moved in the
contract `PageInfo` . Moreover, a comment has been added to explain its purpose.


3.1.3 Contract `CpuPublicInputOffsets`


The contract `CpuPublicInputOffsets`, which inherits from `CpuPublicInputOffsetsBase`,
defines the remaining offsets for the fields of the public input, specifically for the fields
specific to the current layout.


Page 20/52


Code Review of the Cairo & SHARP Verifiers


It further defines getter functions for the offsets related to the page information fields
with respect to the page index as well as a function returning the size of the public input
with respect to the number <u>of</u> public memory pages.


 - **Observation** **2:** **Redundant** **code**


The offset getter functions are related to the page management and are the same for
each layout.


**Recommendation:** We recommend to move those getter functions in the contract `PageInfo` since they relate to page management (or at least in the contract
`CpuPublicInputOffsetsBase` since they are common to each layout). Those functions
depend on the constant `OFFSET_PUBLIC_MEMORY` which could be obtained through a
virtual function.


**Status:** **Resolved** **(** ✓ **)**
The offset getter functions are now in a dedicated contract `PublicMemoryOffsets`
(which inherits from `PageInfo` ). They all rely on the virtual auxiliary function
`getPublicMemoryOffset` for which an implementation is provided in the contract
`CpuVerifier` .

#### 3.2 Fact registry for memory pages


3.2.1 Contract `MemoryPageFactRegistry`


Before running the Cairo verifier, all the pages m <sup>_∗_</sup> _i_ <sup>of the public memory must be registered</sup>

using the smart contract `MemoryPageFactRegistry` . This contract implements two registration functions depending on whether the memory page is regular or continuous. The
function

```
  registerRegularMemoryPage( uint256[] calldata memoryPairs, uint256 z,
```

`uint256` `alpha,` `uint256` `prime` `)`,


is used for a regular page, while the function

```
 registerContinuousMemoryPage( uint256 startAddr, uint256[] memory values,
```

`uint256` `z,` `uint256` `alpha,` `uint256` `prime` `)` .


is used for a continuous page.

Those functions first compute the cumulative product



`prod` =






_a∈A_ <sup>_∗_</sup> _i_



( _z −_ ( _a_ + _α ·_ m <sup>_∗_</sup> ( _a_ ))) _∈_ F _p_



where _A_ <sup>_∗_</sup> _i_




<sup>_∗_</sup> _i_ <sup>is</sup> <sup>the</sup> <sup>domain</sup> <sup>of</sup> <sup>m</sup> <sup>_∗_</sup> _i_




<sup>_∗_</sup> _i_ <sup>and</sup> <sup>the</sup> <sup>hash</sup> <sup>digest</sup> <sup>_h_</sup> <sup>m</sup> <sup>_∗_</sup> _i_




<sup>_∗_</sup> _i_ <sup>of</sup> <sup>the</sup> <sup>memory</sup> <sup>page</sup> <sup>computed</sup> <sup>as</sup>



_h_ m <sup>_∗_</sup> _i_ <sup>:=</sup>




- Hash( _a_ 1 _, v_ 1 _, . . ., an, vn_ ) if m <sup>_∗_</sup> _i_ <sup>is</sup> <sup>a</sup> <sup>regular</sup> <sup>page,</sup>

(1)
Hash( _v_ 1 _, . . ., vn_ ) otherwise,


Page 21/52


Code Review of the Cairo & SHARP Verifiers



with _n_ := _|A_ <sup>_∗_</sup> _i_




<sup>_∗_</sup> _i_ <sup>_|_</sup> <sup>and</sup> <sup>m</sup> <sup>_∗_</sup> _i_



with _n_ := _|A_ <sup>_∗_</sup> _i_ <sup>_|_</sup> <sup>and</sup> <sup>m</sup> <sup>_∗_</sup> _i_ <sup>(</sup> <sup>_aj_</sup> <sup>) =</sup> <sup>_vj_</sup> <sup>for</sup> <sup>_j_</sup> <sup>_∈_</sup> <sup>[1</sup> <sup>_, n_</sup> <sup>].</sup> <sup>Then,</sup> <sup>those</sup> <sup>functions</sup> <sup>register</sup> <sup>the</sup> <sup>following</sup>

fact:



_“There_ _exists_ _a_ _memory_ _mapping_ m _i_ _with_ _n_ _addresses_ _for_ _which_ _the_
_memory hash is h_ m <sup>_∗_</sup> _i_ <sup>_and the cumulative product w.r.t._</sup> <sup>_z_</sup> <sup>_and α is_</sup> <sup>_`prod`_</sup> <sup>_.”_</sup>



This fact is stored as the hash digest


`ValidFact` := Hash( `pageType` _, p, n, z, α,_ `prod` _, h_ m <sup>_∗_</sup> _i_ <sup>_,_</sup> <sup>`address`</sup> <sup>)</sup>


where


  - `pageType` is `0` for a regular page and `1` for a continuous page,


  - `address` is the first address if the page is continuous, and `0` otherwise.


The two functions further perform some sanity checks on their inputs before running
the main computation. The function `registerContinuousMemoryPage` batches the terms
of the cumulative product eight by eight for more efficiency.

The constants for the two page types (regular and continuous) are defined in the parent
virtual contract `MemoryPageFactRegistryConstants` .


The reason why the definition of the memory hash does not have the same scope
depending to the page type (it binds the addresses for regular pages, not for the continuous
pages) comes from how the pages are used by the SHARP verifier (see Section 4.2).


 - **Observation** **3:** **Code** **structure**


On one hand, the function `registerRegularMemoryPage` only performs the sanity
checks on its input and then call an auxiliary function `computeFactHash` to perform the
main computation, before finally registering the fact. On the other hand, the function
`registerContinuousMemoryPage` does not call an auxiliary function and performs all
the computation itself.


**Recommendation:** We recommend to have the same structure for the two functions
(either both call auxiliary functions, or no one does).


**Status:** **Unresolved** **(** ✗ **)**
The two functions still have different structures.


 - **Observation** **4:** **Different** **check** **behavior**

The check performed at lines 44 and 140, that the page size is under 2 <sup>20</sup>, does not
behave the same way for a regular page and for a continuous page. In the former
case, the actual check is that the page size is under 2 <sup>19</sup> since the buffer `memoryPairs`
contains addresses and values (and is hence twice longer than the page).


**Recommendation:** Fix the above difference if not desired and document these
checks.


Page 22/52


Code Review of the Cairo & SHARP Verifiers


**Status:** **Resolved** **(** ✓ **)**
Following some clarification from StarkWare, these checks aim to limit the input
size and not the page size, thus our observation does not apply.

#### 3.3 The Cairo verifier interface and layouts


3.3.1 Contract `CairoVerifierContract`


The smart contract `CairoVerifierContract` acts an interface. Its declares the external
functions the Cairo verifier must implement:


  - `verifyProofExternal(proofParams,` `proof,` `publicInput)` is the function which
verifies the given proof with respect to the statement corresponding to the given
public input.


  - `getLayoutInfo()` is a function which returns some information related to the verifier
layout (the offset of the public memory pages’ information in the public input, the
builtins selected by the layout).


The function `getLayoutInfo` returns the layout builtins as a bit-map: each builtin
is associated to a bit position, and a set bit means that the corresponding builtin is selected. The contract `CairoVerifierContract` defines some constants which specify the
bit position for each builtin.


 - **Observation** **5:** **Implicit** **interface**


As described above, `CairoVerifierContract` acts an interface even if it is not declared
with the keyword `interface` .


**Recommendation:** We recommend to explicitly define this contract as an interface
using the keyword `interface` . <sup>_a_</sup>


**Status:** **Resolved** **(** ✓ **)**
The use of internal constants prevents defining `CairoVerifierContract` as an interface.


_a_ See `[https://docs.soliditylang.org/en/v0.8.13/contracts.html#interfaces](https://docs.soliditylang.org/en/v0.8.13/contracts.html#interfaces)` .


3.3.2 Contract `LayoutSpecific`


The contract `LayoutSpecific` is an (abstract) autogenerated contract which implements
some functions specific to the current layout (and to the builtins of the current layout
in particular). Those functions are required by the `CpuVerifier` contract, which inherits
from `LayoutSpecific` . The implemented functions are the following:


  - `initPeriodicColumns` which initializes the contracts relative to periodic columns,


Page 23/52


Code Review of the Cairo & SHARP Verifiers


  - `getLayoutInfo` which is declared in the interface `CairoVerifierContract` (see Section 3.3.1),


  - `safeDiv` which imple ~~me~~ nts a “safe” integer division ( _i.e._ which verifies that the
denominator is different from 0 and divides the numerator),


  - `layoutSpecificInit` which initializes the builtin-relative fields of the verifier state
and which performs some sanity checks on the builtin pointers. This function further
calls to the subfunction `validateBuiltinPointers` which validates the consistency
of builtin pointers,


  - `prepareForOodsCheck` which prepares the builtin-relative values for the contract
`CpuConstraintPoly` (see Section 2.7.3).


 - **Observation** **6:** **Unused** **constant**


The constant `MAX_FRI_STEP` defined in the parent contract `StarkParameters` is never
used. In particular, no check is performed to verify that this constant is compatible
with the implementation of the STARK verifier.


**Recommendation:** We recommend to remove this constant, or to make proper use
(or check) of it in the STARK verifier implementation.


**Status:** **Resolved** **(** ✓ **)**
The constant `MAX_FRI_STEP` has been removed.


 - **Observation** **7:** **Missing** **test?**


Shouldn’t the function `validateBuiltinPointers` further test that `stopAddress` (or
`maxStopPtr` ) is lower than 2 <sup>64</sup> ?


**Status:** **Resolved** **(** ✓ **)**
The feedback received from StarkWare is the following: since the memory is continuous, checking `initialAddress` bounds `maxStopPtr` . We thought that the idea of the
test was to check that memory addresses did not exceed 2 <sup>64</sup> . This check corresponds
to a sanity check from a past version of the code for which the Cairo memory was not
enforced to start at the address `1` .

#### 3.4 The CPU verifier


3.4.1 Contract `CpuVerifier`


The contract `CpuVerifier` is an implementation of the interface `CairoVerifierContract` .
It is also derived from the previously audited STARK verifier (contract `StarkVerifier` ).


Page 24/52


Code Review of the Cairo & SHARP Verifiers


As described in Section 2.5.3 of our previous audit report [1], a contract derived from
`StarkVerifier` must implement several functions. Most of them are simple getters, and
`CpuVerifier` implements them by returning the values of the corresponding constants from
`StarkParameters` (see Section 2.7.1). Besides those, the contract must implement three
functions: `airSpecificInit`, `getPublicInputHash` and `oodsConsistencyCheck` .

The function `getPublicInputHash` returns the hash of the public input ( _a.k.a._ the
statement to verify). Its implementation simply hashes the public input array (defined in
Table 3, Section 2.6) without the cumulative products which are not formally part of the
public input.

The function `airSpecificInit` creates the verifier context and initializes the context
fields which are specific to the proved statement while performing some sanity checks on
the public input. The latter are described in Table 4. The function also checks:


`pc` _I_ = `INITIAL_PC` and `pc` _F_ = `FINAL_PC` _,_


where `pc` _I_ and `pc` _F_ are read from the public input array and where `INITIAL_PC` and
`FINAL_PC` are constants defined in the contract `CpuPublicInputOffsetsBase`, specifically
`INITIAL_PC` := 1 and `FINAL_PC` := 5 in the current implementation (see Section 2.4).
Finally, a call to the function `layoutSpecificInit` (see Section 3.3.2) performs some
sanity checks on the initial and final builtins pointers <sup>4</sup>, and fills the layout-related fields of
the verifier context. If all the checks pass, the function returns the verifier context.


**<u>Parameter</u>** **<u>Check</u>**
<u>The</u> <u>number</u> _<u>T</u>_ <u>of</u> <u>steps</u> <u>log2</u> _<u>T</u>_ _<u><</u>_ <u>50</u>
<u>Range-check</u> <u>interval</u> <u>0</u> _<u>≤</u>_ <u>`RC_MIN`</u> _<u>≤</u>_ <u>`RC_MAX`</u> _<u><</u>_ <u>2</u> <sup><u>16</u></sup>



<u>Layout</u> <u>Code</u> <u>Must</u> <u>match</u> <u>with</u> <u>the</u> <u>verifier</u> <u>layout</u>
<u>Number</u> <u>of</u> <u>pages</u> <u>At</u> <u>least</u> <u>1,</u> <u>strictly</u> <u>lower</u> <u>than</u> <u>100 000</u>
<u>Page</u> <u>size</u> _<u>|A</u>_ <sup>_<u>∗</u>_</sup> _<u>i</u>_ <sup>_<u>|</u>_</sup> _<u>|A</u>_ <sup>_<u>∗</u>_</sup> _<u>i</u>_ <sup>_<u>| <</u>_</sup> <sup><u>230</u></sup>




<sup>_<u>∗</u>_</sup> _<u>i</u>_ <sup>_<u>|</u>_</sup> _<u>|A</u>_ <sup>_<u>∗</u>_</sup> _<u>i</u>_




<sup>_<u>∗</u>_</sup> _<u>i</u>_ <sup>_<u>| <</u>_</sup> <sup><u>230</u></sup>



Table 4: Sanity checks on the public input.


Finally, the function `oodsConsistencyCheck` verifies the consistency of OODS values.
The implemented function proceeds as follows:


  - it checks that the public memory pages have been registered as valid facts (see Section 3.2) using the auxiliary function `verifyMemoryPageFacts` . The latter computes
the fact hash corresponding to each public memory page as described in Section 3.2.1
and asks the fact registry whether the computed fact hash has well been registered.


  - it computes the quantity


_<u>z</u>_ <sup>_S_</sup>



( _z −_ ( _a_ pad + _α ·_ m <sup>_∗_</sup> ( _a_ pad))) <sup>_S−|A∗|_</sup> _·_ <sup><u>�</u></sup>



_a∈A_ <sup>_∗_</sup> <sup>(</sup> <sup>_z −_</sup> <sup>(</sup> <sup>_a_</sup> <sup>+</sup> <sup>_α ·_</sup> <sup>m</sup> <sup>_∗_</sup> <sup>(</sup> <sup>_a_</sup> <sup>)))</sup>



4Precisely, it checks that for each builtin, the begin and end addresses of the segment verify
`<BUILTIN>_BEGIN_ADDR` _≤_ `<BUILTIN>_STOP_PTR` _≤_ `<BUILTIN>_BEGIN_ADDR` + segment size (where the segment size is the product between the maximum number of instances and the instance size, see Section 2.2).


Page 25/52


Code Review of the Cairo & SHARP Verifiers


with `computePublicMemoryQuotient` which shall be used to check the consistency
of the public memory in the execution trace (see Section 2.5). The computation of

 - _a∈A_ <sup>_∗_</sup> <sup>(</sup> <sup>_z −_</sup> <sup>(</sup> <sup>_a_</sup> <sup>+</sup> <sup>_α ·_</sup> <sup>m</sup> <sup>_∗_</sup> <sup><u>(</u></sup> <sup>_<u>a</u>_</sup> <sup>)))</sup> <sup>is</sup> <sup>delegated</sup> <sup>to</sup> <sup>the</sup> <sup>function</sup> <sup>`computePublicMemoryProd`</sup>
which simply multiplies the cumulative products of the different memory pages from
the public input array.


 - it prepares the input data for the `CpuConstraintPoly` contract (see Section 2.7.3),
specifically the interactive elements for public memory ( _z_ and _α_ ), the interactive element for range-check ( _z_ ), the computed quotient (above item), and further builtinrelative values prepared by calling the function `prepareForOodsCheck` (see Section 3.3.2).


 - it calls the contract `CpuConstraintPoly` (through a static call) which evaluates _h_ ( _z_ )
where _h_ is the composition polynomial and _z_ is the OODS point. This value is
computed from the mask _{yℓ}ℓ_ using all the hardcoded AIR constraints.


 - it computes _h_ ( _z_ ) using the evaluations _y_ ˆ _i_ := _hi_ ( _z_ <sup>_M_</sup> <sup>2</sup> ) of the composition polynomial
trace through the equation _h_ ( _z_ ) = _y_ ˆ0 + ˆ _y_ 1 _· z_ (since _M_ 2 = 2 here).


 - it raises an error if the results of the two previous evaluations do not match.


- **Observation** **8:** **Erroneous** **comment**


The comment at lines 11–13 mentions “for which if a program starts at `pc` =0, it runs
successfully and ends with `pc` =2” whereas the initial and final `pc` values are 1 and 5.


**Recommendation:** Fix the comment.


**Status:** **Resolved** **(** ✓ **)**
The comment now mentions the constants `INITIAL_PC` and `FINAL_PC` instead of the
hardcoded values `0` and `2` .


- **Observation** **9:** **Hardcoded** **restriction**

The composition polynomial _h_ ( _z_ ) is defined as _h_ ( _z_ ) = <sup>�</sup> _i_ <sup>_M_</sup> =0 <sup>2</sup> <sup>_ziy_</sup> <sup>ˆ</sup> <sup>_i_</sup> <sup>with</sup> <sup>_z_</sup> <sup>the</sup> <sup>OODS</sup>

point and _y_ ˆ _i_ = _hi_ ( _z_ <sup>_M_</sup> <sup>2</sup> ), where _M_ 2 is the number of polynomial trace columns a.k.a.
the degree bound on the constraints. The implementation of `oodsConsistencyCheck`
assumes _M_ 2 = 2 since the value _h_ ( _z_ ) is directly computed as _y_ ˆ0 + _z ·_ _y_ ˆ1, although a
constant `CONSTRAINTS_DEGREE_BOUND` is inherited from the `StarkParameters` contract
for the parameter _M_ 2.

**Recommendation:** Since this restriction is an implementation choice, we recommend to check that `CONSTRAINTS_DEGREE_BOUND` is equal to 2 at the beginning of the
function `oodsConsistencyCheck` .


**Status:** **Unresolved** **(** ✗ **)**
The feedback received from StarkWare is that static assertions do not exist in


Page 26/52


Code Review of the Cairo & SHARP Verifiers


Solidity. Even though, we would still recommend using a dynamic assertion to avoid
any possibility of inconsistent use of this code with another definition of the constant
`CONSTRAINTS_DEGREE_BOUND` .


 - **Observation** **10:** **Indirect** **offsets**

At lines 363-364, the source code gets evaluations of the composition polynomials _h_ 0
and _h_ 1 from the verifier context `ctx` at the offsets


`MM_OODS_VALUES` `+` `MASK_SIZE` and `MM_OODS_VALUES` `+` `MASK_SIZE` `+` `1` .


Similarly, at line 230, it gets the padding value for public memory with


`OFFSET_PUBLIC_MEMORY_PADDING_ADDR` `+` `1` .


**Recommendation:** Since there exist explicit constants for those offsets, we recommend to use them, _i.e._ to access to


   - evaluations of _h_ 0 and _h_ 1 with `MM_COMPOSITION_OODS_VALUES` .


   - padding value with `OFFSET_PUBLIC_MEMORY_PADDING_VALUE` .


**Status:** **Resolved** **(** ✓ **)**
The source code has been updated and the defined constants are now properly used.


3.4.2 Contract `CpuFriLessVerifier`


The contract `CpuFriLessVerifier` is derived from the `CpuVerifier` contract and proposes
an alternative implementation of the interface `CairoVerifierContract` . It is similar to
the CPU verifier (see previous section) with


  - the function `verifyMerkle` (originally from the `MerkleVerifier` contract, inherited
through `StarkVerifier` ) overridden by the function of the same name from an instance of the `MerkleStatementVerifier` contract,


  - the function `fryVerifyLayers` (originally from the `Fri` contract, inherited through
`StarkVerifier` ) overridden by the function of the same name from an instance of
the `FriStatementVerifier` contract.


The addresses of the two contract instances are passed as additional arguments of the
`CpuFriLessVerifier` constructor. Both the `MerkleStatementVerifier` contract and the
`FriStatementVerifier` contract have been reviewed in our previous audit [1]. Using
the `CpuFriLessVerifier` contract requires that the Merkle tree openings and the FRI
transitions involved in the proof to be verified have been previously registered as valid facts
using `MerkleStatementContract` and `FriStatementContract` (also previously reviewed
in [1]).


Page 27/52


Code Review of the Cairo & SHARP Verifiers

#### 3.5 General observations


 - **Observation** **11:** **Auxiliary** **functions**


The following functions are auxiliary (i.e. used to avoid redundancy in the corresponding contract and/or to improve the code readability):


   - `MemoryPageFactRegistry.computeFactHash`,


   - `CpuVerifier.computePublicMemoryQuotient`,


   - `CpuVerifier.computePublicMemoryProd`,


   - `CpuVerifier.verifyMemoryPageFacts` .


**Recommendation:** Since these functions do not aim to be used in other contracts,
we suggest to define them as private functions.


**Status:** **Resolved** **(** ✓ **)**
These functions are now defined as private.


 - **Observation** **12:** **Magic** **numbers**


Several constant values are hardcoded without being explained or specified:


   - `MemoryPageFactRegistry.sol`, lines 44 and 140: `2**20` .


   - `MemoryPageFactRegistry.sol`, line 144: `2**64` .


   - `CpuVerifier.sol.ref`, line 114: `2**16` .


   - `CpuVerifier.sol.ref`, line 115: `2**15` .


   - `CpuVerifier.sol.ref`, line 210: `0x1000000` .


   - `CpuVerifier.sol.ref` : all the limits involved in the sanity checks of the public
inputs (see Table 4).


**Recommendation:** We recommend to avoid such magic numbers by defining constants and by documenting their values.


**Status:** **Partially** **resolved** **(** **_∼_** **)**
Some comments have been added to document these values (for all of them except
`2**16` and `2**15` in `CpuVerifier` ). The comments explain that these values are somewhat arbitrary. They remain as magic numbers.


Page 28/52


Code Review of the Cairo & SHARP Verifiers

### 4 Documentation for the SHARP verifier


The present section provides <u>some</u> documentation for the audited SHARP verifier implementation which completes the available documentation [2, 3, 5].


_SHARP_ _(formerly_ _known_ _as_ _GPS)_ _is_ _a_ _service_ _that_ _generates_ _proofs_ _attesting_
_to_ _the_ _validity_ _of_ _the_ _executions_ _of_ _Cairo_ _programs._ _Then,_ _it_ _sends_ _those_ _proofs_
_to_ _an_ _Ethereum_ _testnet_ _(Goerli)_ _where_ _they_ _are_ _verified_ _by_ _a_ _smart_ _contract._


                            - Cairo Documentation [5]


As described above, the _shared_ _prover_ (SHARP) is a service which enables everyone
to prove the computational integrity of Cairo programs. It works as follows: assume a
user wants to send a proof of computational integrity for a specific Cairo program on the
Ethereum blockchain, then (see Figure 3):


  - The user generates a _symbolic_ execution trace of its computation and sends it to
the shared prover. A symbolic execution trace (called _Position_ _Independent_ _Execu-_
_tion_ (PIE) trace in the Cairo runner) is an execution trace where the addresses of
the different memory segments are symbolic allowing the prover to deal with memory allocation. By definition, such a trace contains the bytecode of the underlying
program.


  - The prover gets this execution trace and wait for more requests (from other users).
A request for proving the computational integrity of a program is called a _task_ .


  - When the prover has received enough requests (or after a time delay), it generates
a proof that all the collected execution traces are valid. This proof consists in a
computational integrity proof for a program called the _bootloader_ (see next section)
which executes sequentially all the collected programs. To build the execution trace
of the bootloader, the prover can insert the symbolic execution traces of the tasks in
the bootloader’s trace and deal with memory allocation of the segments.


  - The prover sends this proof to an online verifier (a smart contract), called the _SHARP_
_verifier_ (formerly GPS verifier).


  - This verifier checks whether the proof is valid, and if it is the case, register for each
task the _fact_ that the computational integrity has been verified.


  - At the end, online applications can check the validity of any of those facts by calling
the _fact_ _registry_ _contract_ .


Page 29/52


Code Review of the Cairo & SHARP Verifiers


Figure 3: The SHARP environment [4].

#### 4.1 The bootloader program


The bootloader is a special Cairo program which loads and executes a batch of programs (or
_tasks_ ) sequentially. This approach results in a single proof for the computational integrity
of all the programs. Since proof-verification scales logarithmically with the trace length,
batching many computational integrity proofs in a single (larger) one enables to amortize
the verification cost per task, which tends to zero while more tasks are added to the batch.
The implemented bootloader uses the paradigm “bootloading from hash” (Section 2.2.1
of [2]), which enables a verifier to check the computational integrity of a Cairo program
without knowing its full bytecode, but just its hash digest.


4.1.1 Simple bootloader


The program data specific to a given task is represented in Table 5. The _program_ _header_
is composed of the different fields before the program bytecode. Note that this data is not
part of the public input. It is written in memory at the beginning of the task execution
using a hint.

The output of the bootloader is written in a memory segment (the output builtin
segment) represented on Figure 4. At the end of the execution this memory segment
contains the number of tasks (first memory cell) followed by the concatenation of the
output segments of all the tasks. The output segment dedicated to a given task includes a
prefix, composed of the segment size and the program hash, followed by the output of the
program.

To execute a given task, the bootloader proceeds as follows:


Page 30/52


Code Review of the Cairo & SHARP Verifiers


**<u>Field</u>** **<u>name</u>** **<u>Nb.</u>** **<u>slots</u>** **<u>Description</u>**
<u>Data</u> <u>length</u> <u>1</u> <u>Length</u> _<u>ℓ</u>_ <u>of</u> <u>the</u> <u>header</u> <u>plus</u> <u>the</u> <u>bytecode</u>

Version of the bootloader compliant with
Bootloader version 1

<u>the</u> <u>program</u>

Absolute position of the function `main` in
Program main 1

<u>the</u> <u>program</u> <u>bytecode</u>
<u>Number</u> <u>of</u> <u>builtins</u> <u>1</u> <u>Number</u> _<u>n</u>_ <u>of</u> <u>builtins</u> <u>used</u> <u>by</u> <u>the</u> <u>program</u>
<u>List</u> <u>of</u> <u>builtins</u> _<u>n</u>_ <u>List</u> <u>of</u> <u>the</u> <u>builtins</u> <u>used</u> <u>by</u> <u>the</u> <u>program</u>
<u>Program</u> <u>bytecode</u> _<u>ℓ</u>_ _<u>−</u>_ _<u>n −</u>_ <u>4</u> <u>Bytecode</u> <u>of</u> <u>the</u> <u>program</u>


Table 5: Program data specific to a task.


_Segment Size_


Nb Tasks Dedicated to Task 1 Dedicated to Task 2 …


Segment Size Program Hash Output of Task 2…


Figure 4: Bootloader output.


1. It loads the task in memory, _i.e._ writes the program’s data (Table 5) in memory,
which is done in a _nondeterministic_ _way_ from the first unused address.


2. it computes the hash of the program data (header and bytecode) as:


_h_ = Hash( _v_ 1 _,_ Hash( _v_ 2 _, . . ._ Hash( _vℓ−_ 1 _, vℓ_ ) _. . ._ )) (2)


where ( _v_ 1 _, v_ 2 _, . . ., vℓ_ ) is the memory segment described by Table 5 (with in particular
_v_ 1 = _ℓ_ ) and where Hash is the Pedersen hash function.


3. it adds the program hash to the bootloader output using the output builtin (see
Figure 4). The purpose of outputing this hash is to bind the proof to the loaded
program (since the program itself is not part of the public input).


4. it computes the entry point of the program ( _i.e._ address of its `main` function in the
bootloader memory) and computes the builtin pointers for the program execution (as
described in Section 2.4, the `main` function of a program takes the builtin pointers
as implicit arguments),


5. it executes the program by jumping to its entry point.


6. Throughout its execution, the program outputs some data (using the output builtin)
in a dedicated chunk (see Figure 4).


7. At the end of the task execution, the function `main` returns the updated builtin
pointers which are then checked by the bootloader.


Page 31/52


Code Review of the Cairo & SHARP Verifiers


8. Finally, the bootloader writes the output segment size in the appropriate memory
cell at the beginning of the segment (see Figure 4). This size must be equal to the
output size of the program plus two for the segment prefix (segment size and program
hash).


4.1.2 General bootloader


Instead of verifying a computational integrity (CI) statement for the simple bootloader on
tasks _T_ 1, . . . _Tn_, an alternative approach is to consider a single task, called a _composite_
_task_, which runs the verification of a proof _π_ for the former CI statement. If, in addition
to running the verification, such a task outputs the hash of the verified program ( _i.e._ the
simple bootloader) and the hash of its output (which includes the respective outputs of all
the _Ti_ ’s) then proving the CI statement for this composite task is equivalent to proving
the former CI statement of the simple bootloader (which implies the CI of all the tasks).

The general bootloader extends the simple bootloader to support such composite tasks.
Each composite task corresponds to the execution of a _Cairo_ _verifier_ _program_ which


1. takes a STARK proof as input,


2. verifies the correctness of the proof,


3. outputs the following:


(a) the hash of the program that is verified in the STARK proof (in practice the

simple bootloader),


(b) the hash of the output of this program (in practice a hash of the outputs of the

tasks executed by the simple bootloader).


The principle of composite tasks can be applied in a recursive way: one or several of
the _Ti_ ’s in a composite task might be composite tasks themselves ( _i.e._ tasks which execute
the above Cairo verifier program on a CI proof corresponding to further subtasks). Thus,
we have two types of tasks:


  - _plain_ tasks for arbitrary programs (such as the tasks in the input of the simple
bootloader), and


  - _composite_ tasks which correspond to the execution of the above Cairo verifier program, and hence verifying the CI statements of several subtasks (which can be plain
or composite themselves).


Thus, the full set of verified tasks can be represented as a tree where the internal nodes
correspond to composite tasks while the leaves correspond to plain tasks (see Figure 5 for
an illustration).

The general bootloader first calls the simple bootloader which executes the direct subtasks ( _i.e._ the tasks of depth 1 in the tree, just below the root). Direct subtasks might
include composite tasks whose outputs then _pack_ the outputs of the underlying leaves. The
general bootloader then parses the packed outputs from which it derives its own output.


Page 32/52


Code Review of the Cairo & SHARP Verifiers


Figure 5: Tree representation of recursive tasks.


The output format of the general bootloader is given by the Figure 6. It is similar to the
output of the simple bootloader (see Figure 4) with an additional configuration header.
The configuration header is composed of:


  - the hash of the simple bootloader bytecode which is used to execute the tasks (used
to verify the first output of the Cairo verifier program used in composite tasks),


  - the list of hashes of the supported Cairo verifier bytecodes (used to verify the compliance of the bytecode hash included in the output header of each composite task).


The order of the plain tasks in the output corresponds to the order of the leaves in the
task tree using a depth-first search.


_Segment Size_


Bootloader Config. Nb Tasks Dedicated to Plain Task 1 Dedicated to Plain Task 2 …


Segment Size Program Hash Output of Plain Task 2…


Figure 6: General bootloader output.


In order to unpack the tasks’ outputs and reorganize them according to the format
defined in Figure 6, a recursive parsing function is called on the outputs of the (plain
and composite) tasks of depth 1 in the tree. For a composite task, the outputs of the
corresponding subtasks are non-deterministically guessed and checked to match the second
output of the Cairo verifier program. The parsing function makes recursive calls to unpack
all the tasks’ outputs with a depth-first search approach.


Page 33/52


Code Review of the Cairo & SHARP Verifiers


To be compatible with the audited general bootloader, the Cairo verifier program must
comply with the following API:


  - the input of the progra ~~m~~ is a STARK proof for the execution of the simple bootloader
program (whose bytecode is part of the public input and whose output follows the
format of Figure 4),


  - the output of the program is the pair


(Hash _c_ ( `bytecode` sbl) _,_ Hash _c_ ( `output` sbl))


where `bytecode` sbl and `output` sbl respectively denote the bytecode and output of the
simple bootloader in the STARK proof and where Hash _c_ is the function defined as:


Hash _c_ ( _v_ 1 _, . . ., vℓ_ ) := Hash(Hash( _. . ._ Hash(Hash(0 _, v_ 1) _, v_ 2) _. . ., vℓ_ ) _, ℓ_ )


with Hash being the Pedersen hash function.

#### 4.2 Public memory for SHARP


As explained in Section 2.5, the public memory is composed of several pages. In the context
of SHARP, the public memory of the proven Cairo program (the bootloader) is partitioned
as follows:


  - The first page, a.k.a. the _main_ _page_, is composed of the (public) memory used by
the bootloader itself (its bytecode, its inputs, its returned values, ...) including the
output segment prefix of each task (segment size and program hash).


  - Then the next pages (which are continuous ones) contain the outputs of the tasks,
where each task can give rise to several pages.


4.2.1 The main page


The main page is a _regular_ page, _i.e._ it is represented as a list of address-value pairs (see
Section 2.5.1). The hash digest of this page depends on the ordering of those pairs. In
what follows, we describe the content of the main page, namely the list of address-value
pairs composing the page, in the same order as for the hashing operation (see Equation (1),
Section 3.2.1).

The first cells are dedicated to the bytecode of the bootloader:


m <sup>_∗_</sup> (pc _I_ ) _. . ._ m <sup>_∗_</sup> (pc _I_ + `PROGRAM_SIZE` _−_ 1) = Bootloader bytecode


where `PROGRAM_SIZE` corresponds to the size of the bootloader bytecode. Then, two cells
are relative to the frame of the bootloader main function:


          - m _∗_ (fp _I_ _−_ 2) = fp _I_
m <sup>_∗_</sup> (fp _I_ _−_ 1) = 0


Page 34/52


Code Review of the Cairo & SHARP Verifiers


where fp _I_ := ap _I_ . The next cells hold the arguments of the bootloader’s main function:


m <sup>_∗_</sup> (fp _I_ ) _. . ._ m <sup>_∗_</sup> (fp _I_ + `N_MAIN_ARGS` _−_ 1) = Arguments of `main`


where `N_MAIN_ARGS` is the number of arguments. Let us recall that those arguments correspond to the builtin pointers used by the bootloader (see Section 2.4). Then, come the
cells for the returned values of the main function:


m <sup>_∗_</sup> (ap _F_ _−_ `N_MAIN_RETURN_VALUES` ) _. . ._ m <sup>_∗_</sup> (ap _F_ _−_ 1) = Returned values of `main`


where `N_MAIN_RETURN_VALUES` is the number of returned values. In practice, those values
are the builtin pointers after the bootloader execution. Finally, the last cells of the main
page contain information relative to the tasks. If we denote `outputAddress` the first address
of the memory segment of the output builtin, we have


m <sup>_∗_</sup> ( `outputAddress` ) = Number of tasks


and for each task _Ti_, we have


      - m _∗_ ( `outputAddress` _Ti_ ) = Size of _Ti_ ’s output
m <sup>_∗_</sup> ( `outputAddress` _Ti_ + 1) = Program hash for _Ti_


where `outputAddress` _Ti_ points to the first cell dedicated to the task _Ti_ in the output
memory segment. According to the structure described in Figure 4, we have


`outputAddress` _Ti_ +1 = `outputAddress` _Ti_ + m <sup>_∗_</sup> ( `outputAddress` _Ti_ ) _._


The main page is reconstructed by the SHARP verifier in order to check the consistency of its hash and cumulative product, and register the corresponding memory fact
(by calling the function `registerRegularMemoryPage`, see Section 3.2.1). This is done by
the function `registerPublicMemoryMainPage` of the `GpsStatementVerifier` contract (see
Section 5.1.2) using:


  - the bootloader bytecode (and its size `PROGRAM_SIZE` ) which is provided by an external
instance of the `CairoBootloaderProgram` smart contract,


  - the value pc _I_ := `INITIAL_PC` which is hardcoded in `CpuPublicInputOffsetsBase`
(parent contract of the verifier, see Section 3.1.2),


  - the value `N_MAIN_ARGS` = `N_MAIN_RETURN_VALUES` = `N_BUILTINS` which is hardcoded
in the `GpsStatementVerifier` contract,


  - the following values from the public input (see Table 3, Section 2.6):


**–** the initial frame pointer fp _I_ := ap _I_,

**–** the final allocation pointer ap _F_,

**–** the arguments of `main` (fields `<BUILTIN>_BEGIN_ADDR` in Table 3),


Page 35/52


Code Review of the Cairo & SHARP Verifiers


**–** the returned values of `main` (fields `<BUILTIN>_STOP_ADDR` in Table 3),


**–** the output address `outputAddress` (field `<BUILTIN>_BEGIN_ADDR` for the output

builtin in Table 3),


  - the following values from the input tasks’ metadata (see Section 4.4.3 below):


**–** the number of tasks,


**–** the sizes of the tasks’ outputs,


**–** the program hashes of the tasks.


While constructing the cells for the arguments and returned values of the `main` function
for a given builtin, the verifier checks whether the builtin is supported by the current layout
(through the `getLayoutInfo` function, see Section 3.3.2). If the builtin is not supported,
then the corresponding memory cells are set to 0. For instance, if the first builtin is not
supported, we have m <sup>_∗_</sup> (fp _I_ ) = 0 and m <sup>_∗_</sup> (ap _F_ _−_ `N_MAIN_RETURN_VALUES` ) = 0.


4.2.2 The tasks’ pages


The remaining memory pages which need to be checked compose the outputs of the different
tasks. For a given task _Ti_, it would be possible to create a unique page which contains its
full output since it consists in a continuous memory segment (see Figure 4). However, the
shared prover and its verifier offers more flexibility. The output of a task can be split into
several chunks and then, each chunk corresponds to a page of the public memory. This
split has no impact on the prover and the verifier, but it enables a user to check only a
subpart of the output of a program execution without necessarily knowing the full output
(see the next section for more details).

Due to implementation choices, the pages are sorted by increasing address ranges.
Moreover, the union of all the pages must include all the memory segments dedicated to
the different tasks (as depicted in Figure 4) without redundancy.


Let us remark that, because a client who uses the shared prover does not know in
advance where the task output will be stored in the bootloader memory, the hash of a task
page must not be bound to the address range of the page but only to its content. This
explains why two different definitions of the page hash are used (see Section 3.2.1).

#### 4.3 The verified statement


The public input is the same as in the case of the Cairo verifier (see Table 3 of Section 2.6). The statement verified by the SHARP verifier is the following: _There_ _exists_ _a_
_valid_ _execution_ _trace_ _of_ _T_ _steps_ _on_ _the_ _Cairo_ _machine:_


_1-7._ _which_ _satisfies_ _the_ _constraints_ _of_ _the_ _Cairo_ _verifier,_ _numbered_ _from_ _1_ _to_ _7_ _in_ _Sec-_
_tion_ _2.6,_


Page 36/52


Code Review of the Cairo & SHARP Verifiers


_8-11._ _where the bytecode includes a function_ _`main`_ _protected by the “safe call”_ _feature and for_
_which_ _the_ _arguments_ _and_ _returned_ _values_ _match_ _the_ _sets_ _of_ _`<BUILTIN>_BEGIN_ADDR`_
_and_ _`<BUILTIN>_STOP_PTR`_ _(constraints_ _numbered_ _from_ _8_ _to_ _11_ _in_ _Section_ _2.6),_


_12._ _using_ _the_ _bootloader_ _bytecode,_ _meaning_


m <sup>_∗_</sup> ( _pcI_ ) _. . ._ m <sup>_∗_</sup> ( _pcI_ + _`PROGRAM_SIZE`_ _−_ 1) = _Bootloader_ _bytecode,_


_13._ _where_ _the_ _page_ m <sup>_∗_</sup> 0 <sup>_of_</sup> <sup>_the_</sup> <sup>_public_</sup> <sup>_memory_</sup> <sup>_corresponds_</sup> <sup>_to_</sup> <sup>_the_</sup> <sup>_main_</sup> <sup>_page_</sup> <sup>_described_</sup> <sup>_in_</sup>
_Section_ _4.2.1,_


_14._ _where_ _the_ _pages_ _{_ m <sup>_∗_</sup> _i_ <sup>_}i≥_</sup> <sup>1</sup> <sup>_of_</sup> <sup>_the_</sup> <sup>_public_</sup> <sup>_memory_</sup> <sup>_correspond_</sup> <sup>_to_</sup> <sup>_the_</sup> <sup>_tasks’_</sup> <sup>_pages,_</sup> <sup>_de-_</sup>
_scribed_ _in_ _Section_ _4.2.2._

#### 4.4 Fact registration


4.4.1 Facts from the prover


Before calling the SHARP verifier, the shared prover must first register all the public
memory pages relative to the tasks’ outputs ( _i.e._ all the pages except the main one). This
shall done by calling `registerContinuousMemoryPage` from a `MemoryPageFactRegistry`
contract (see Section 3.2.1) for each page.

Then depending on the version of the Cairo verifier, the shared prover might need to
register additional information before running the verifier. Indeed, Cairo verifier comes in
two flavors:


  - the contract `CpuVerifier` (see Section 3.4.1) for which no additional information is
needed,


  - the contract `CpuFriLessVerifier` (see Section 3.4.2) for which the shared prover
needs to register the Merkle openings and the FRI transitions involved in the proof.
Those fact registrations shall be done using the contracts `MerkleStatementContract`
and `FriStatementContract` (see our previous audit report [1]).


4.4.2 Facts from the verifier


While checking a proof from the shared prover, and if the proof is valid, the SHARP verifier
shall register the following fact for each task _Ti_ :


Hash( `program_hash` _Ti,_ `merkle_root_pages` _Ti_ )


where


  - `program_hash` _Ti_ is the hash of the program corresponding to task _Ti_ _i.e._ the hash of
the program header and bytecode for this task (see Equation (2), Section 4.1).


  - `merkle_root_pages` _Ti_ is the root of a (non-binary) Merkle tree where leafs are the
page hashes (as defined in Equation (1), Section 3.2.1).


Page 37/52


Code Review of the Cairo & SHARP Verifiers


This fact encodes the following statement:


“There exists an execution trace of the program represented by `program_hash` _Ti_

which outputs ~~the~~ values represented by `merkle_root_pages` _Ti_ .”


The values `merkle_root_pages` _Ti_ is computed as the root of a Merkle tree with a
flexible structure (called _fact_ _topology_ of _Ti_ ), which we explain hereafter.


4.4.3 Merkle tree for pages


In the Merkle tree to compute `merkle_root_pages` _Ti_, each node consists of a pair ( _h, e_ ),
where _h_ is the hash of the child nodes (or the hash of a memory page for a leaf node)
and _e_ is the offset between the beginning of the task memory segment and the end of the
(contiguous) pages represented by the node. <sup>5</sup> A parent node ( _h_ <sup>_∗_</sup> _, e_ <sup>_∗_</sup> ) can have have several
children ( _h_ 1 _, e_ 1) _, . . .,_ ( _hn, en_ ), with _e_ 1 _< e_ 2 _< · · · < en_ and is then defined as


_h_ <sup>_∗_</sup> = Hash(( _h_ 1 _, e_ 1) _, . . .,_ ( _hn, en_ )) and _e_ <sup>_∗_</sup> = _en_ _._ (3)


The Merkle tree structure is represented by a list of pairs which describes how to build
the tree root from the leaves using a stack. This process works as follows:


1. At the beginning, we have a empty stack and the list _{_ ( _hi, ei_ ) _}_ of all pages’ hashes
and offsets.


2. For each pair ( _n_ 1 _, n_ 2) of non-negative integers in the Merkle tree structure,


    - push _n_ 1 pairs ( _hi, ei_ ) from the input list in the stack,

    - pop _n_ 2 elements from the stack, compute the corresponding parent node as in
Equation (3), and push the result in the stack.


3. At the end, all the pairs ( _hi, ei_ ) must have been used and the stack must contain a
single pair whose hash is the Merkle root.


To illustrate this process, Figure 7 shows the successive states of the stack when running
the above algorithm on the list of pages’ hash digests [ _h_ 1 _, h_ 2 _, h_ 3] and with the Merkle tree
represented as `[(2,2),(1,2)]` . In this figure, we have _h_ 1 _,_ 2 := Hash(( _h_ 1 _, e_ 1) _,_ ( _h_ 2 _, e_ 2)) and
_h_ (1 _,_ 2) _,_ 3 := Hash(( _h_ 1 _,_ 2 _, e_ 2) _,_ ( _h_ 3 _, e_ 3)). The resulting Merkle tree is further represented in
Figure 8.

The structures of the Merkle trees used to compute the facts for the different tasks are
provided as input of the SHARP verifier in the so-called _tasks’_ _metadata_ . The latter is an
array of format depicted in Table 6.


5In other terms, the address range represented by the node ( _i.e._ by all the memory pages corresponding
to the leaves of this node) is _{a_ + _x, . . ., a_ + _e −_ 1 _}_ where _a_ is the first address of the memory segment
dedicated to the current task and _x_ is a non-negative integer smaller than _e_ .


Page 38/52


Code Review of the Cairo & SHARP Verifiers



_<u>h</u>_ <u>1</u> _<u>,</u>_ <u>2</u> _<u>e</u>_ <u>2</u>

**_<u>Hash</u>_** **_<u>End</u>_**



_<u>h</u>_ <u>(1</u> _<u>,</u>_ <u>2)</u> _<u>,</u>_ <u>3</u> _<u>e</u>_ <u>3</u>

**_<u>Hash</u>_** **_<u>End</u>_**



= _⇒_



= _⇒_



= _⇒_ _h_ 3 _e_ 3
_<u>h</u>_ <u>1</u> _<u>,</u>_ <u>2</u> _<u>e</u>_ <u>2</u>

**_<u>Hash</u>_** **_<u>End</u>_**



**_<u>Hash</u>_** **_<u>End</u>_**



= _⇒_ _h_ 2 _e_ 2
_<u>h</u>_ <u>1</u> _<u>e</u>_ <u>1</u>

**_<u>Hash</u>_** **_<u>End</u>_**



Figure 7: Stack transitions to build the Merkle root from the list `[(2,2),(1,2)]` .


Figure 8: Example of a fact topology for a task.


Page 39/52


Code Review of the Cairo & SHARP Verifiers


Number of tasks ( _n_ )


Size of _T_ <u>1’s</u> output (sum of pages’ sizes)

Program hash for _T_ <u>1</u> ( `program_hash` _<u>T</u>_ <u>1)</u>

Number of pairs in the Merkle tree of _T_ <u>1</u>


Merkle tree structure (list of pairs) for _T_ 1


Size of _T_ <u>2’s</u> output (sum of pages’ sizes)

Program hash for _T_ <u>2</u> ( `program_hash` _<u>T</u>_ <u>2)</u>

Number of pairs in the Merkle tree of _T_ <u>2</u>


Merkle tree structure (list of pairs) for _T_ 2


<u>...</u>

Size of _Tn_ ’s output (sum of pages’ sizes)

Program hash for _Tn_ ( `program_hash` _<u>Tn</u>_ )

Number of pairs in the Merkle tree of _Tn_


Merkle tree structure (list of pairs) for _Tn_


Table 6: Tasks’ metadata


Page 40/52


Code Review of the Cairo & SHARP Verifiers

### 5 Review of the SHARP verifier

#### 5.1 SHARP verifier co ntracts


5.1.1 Contract `GpsOutputParser`


The contract `GpsOutputParser` implements the function `registerGpsFacts` which aims
to register for each task the fact that the computational integrity has been checked. To
proceed, for each task _Ti_, this function

  - computes the hash digest `merkle_root_pages` _Ti_ which is the root of a non-binary
Merkle tree taking the memory pages’ hashes as input (see Section 4.4),


  - computes the fact hash of the task defined as


`fact_hash` _Ti_ := Hash( `program_hash` _Ti,_ `merkle_root_pages` _Ti_ )


where the program hash digest is available from the tasks’ metadata (see Table 6),


  - registers `fact_hash` _Ti_ using the `registerFact` function from `FactRegistry` .

At the same time, the function checks that the memory pages of each task well form a
partition of the output memory segment dedicated to this task. Namely it checks that


  - the first page starts with the first address of the memory segment,


  - the first address of each page is contiguous to the last address of the previous page,


  - the total size of the memory pages equals the size of the memory segment.


The function also emits an event to log the Merkle root together with the memory pages’ hashes of the task (input of the Merkle tree). The logged data is a buffer
`pageHashesLogData` defined as


  - `pageHashesLogData` [0] = `merkle_root_pages` _Ti_


  - `pageHashesLogData` [1] = `0x40`


  - `pageHashesLogData` [2] = _ℓ_ (number of memory pages for task _Ti_ )


  - `pageHashesLogData` [3] = hash of page 1 of _Ti_
...


  - `pageHashesLogData` [ _ℓ_ + 2] = hash of page _ℓ_ of _Ti_


 - **Observation** **13:** **Unclear** **implementation** **choice**


When building a Merkle node by hashing its child nodes, the resulting hash digest is
incremented by one. According to the comment at line 263, adding one to the node
hash enables to “distinguish it from the hash of a Merkle leaf”. Since the used hash
function is `keccak256` in the both cases, it is not clear why and how this increment


Page 41/52


Code Review of the Cairo & SHARP Verifiers


helps to distinguish.


**Recommendation:** Update the comment to provide a more detailed explanation.


**Status:** **Resolved** **(** ✓ **)**
A more detailed comment has been added at lines 51-52 explaning the purpose of this
increment which is to enforce some domain separation, _i.e._ to have distincts hash
functions for the leaves and for the nodes.


 - **Observation** **14:** **Mismatch** **between** **comment** **and** **code**


According to the comment line 29, the event `LogMemoryPagesHashes` “logs the fact
hash together with the relevant continuous memory pages’ hashes”. However, when
emitted (lines 182–196) it logs the Merkle root (variable `factWithoutProgramHash` )
together pages’ hashes (as described above) but not the fact hash (variable `fact` ).


**Recommendation:** Correct the comment or the code.


**Status:** **Resolved** **(** ✓ **)**
The comment for the event `LogMemoryPagesHashes` has been fixed. Moreover, the
variable `factWithoutProgramHash` has been renamed as `programOutputFact` .


5.1.2 Contract `GpsStatementVerifier`


The contract `GpsStatementVerifier` implements the function `verifyProofAndRegister`
which verifies a SHARP proof and registers the associated facts.

This contract uses three state variables:


  - `bootloaderProgramContractAddress` which points to a smart contract storing the
bytecode of the bootloader,


  - `memoryPageFactRegistry` which points to an instance of `MemoryPageFactRegistry`
(see Section 3.2),


  - `cairoVerifierContractAddresses` an array of pointers to different instances of the
contract `CairoVerifierContract` (see Section 3.3.1).


The function `verifyProofAndRegister` takes as input the proof parameters, the SHARP
proof, the tasks’ metadata (see Section 4.4.3), the public input (extended with the two interaction elements _z_ and _α_ required to check the memory – see Section 2.6), a Cairo verifier
identifier. The latter identifier is used to select the desired Cairo verifier instance from the
array `cairoVerifierContractAddresses` .

The function `verifyProofAndRegister` proceeds as follows:


Page 42/52


Code Review of the Cairo & SHARP Verifiers


1. First, it builds and registers the main page of the statement (as detailed in Section 4.2.1) using the auxiliary function `registerPublicMemoryMainPage` . Note that
the other pages corresponding to the tasks’ outputs should have been previously
registered by the shared prover.


2. It verifies that the reconstructed and registered main page matches the page size, hash
and cumulative product from the public input (to avoid calling the Cairo verifier in
case of mismatch).


3. It calls the selected Cairo verifier instance (function `verifyProofExternal`, see Section 3.3.1) to verify the proof.


4. If the proof verification succeeds, it finally registers the fact that the computational
integrity has been verified for each task, using the `registerGpsFacts` function from
`GpsOutputParser` (see Section 5.1.1).


- **Observation** **15:** **Constant** **definition**


The contract `GpsStatementVerifier` defines a constant for the number of builtins:

```
        uint256 internal constant N_BUILTINS = 5;

```

However some other contracts exist for the purpose of defining such constants, and in
particular the interface `CairoVerifierContract` (which defines the constants related
to the builtins’ selection bitmap).


**Recommendation:** Move this constant definition to `CairoVerifierContract` .


**Status:** **Resolved** **(** ✓ **)**
The constant `N_BUILTINS` aims to refer to the number of builtins managed by the
corresponding bytecode (here, by the bootloader). This number can be larger than
the number of layout builtins. We still recommend to rename this constant to avoid
any confusion (for example, `N_PROGRAM_BUILTINS` or `N_BOOTLOADER_BUILTINS` ).


- **Observation** **16:** **Confusing** **comment**


The comment in line 86 “Each page has a page info and a hash” to explain that the
length of `publicMemoryPages` is expected to be `nPages` `*` `(PAGE_INFO_SIZE` `+` `1)` is
not accurate. The explanation for this expected value is


  - each page has page info and a _cumulative_ _product_ (hash is part of the page info),


  - the page info of the first page is of size `PAGE_INFO_SIZE` `-` `1` (it does not include
the page address),


  - the `publicMemoryPages` array includes the number of pages as first element.


Page 43/52


Code Review of the Cairo & SHARP Verifiers


**Recommendation:** Update the comment to reflect the above explanation.


**Status:** **Resolved** **(** ✓ **)**
The comment has been updated (lines 102-105) as recommended.


5.1.3 General observations


Hereafter are some observations which are general to the two contracts of the SHARP
verifier.


 - **Observation** **17:** **Auxiliary** **functions**


The following functions are auxiliary (i.e. used to avoid redundancy in the corresponding contract and/or to improve the code readability):


   - `GpsOutputParser.pushPageToStack`,


   - `GpsOutputParser.constructNode`,


   - `GpsStatementVerifier.registerPublicMemoryMainPage` .


**Recommendation:** Since these functions do not aim to be used in other contracts,
we suggest to define them as private functions.


**Status:** **Resolved** **(** ✓ **)**
These functions are now defined as private.


 - **Observation** **18:** **Magic** **numbers**


Many constant values are hardcoded:


   - `GpsOutputParser.sol`, line 123: `2**20`, the maximum number of pages by _push_
operation.


   - `GpsOutputParser.sol`, line 224: `2**30`, the maximum size for a page of the
public memory.


   - `GpsStatementVerifier.sol`, line 153: `2**30`, the maximum number of tasks.


   - `GpsStatementVerifier.sol`, line 255: `2**30`, the maximum number of output
slots used by a task.


   - `GpsStatementVerifier.sol` : line 259: `2**20`, the maximum size of the structure
which describe the fact topology of a task.


Page 44/52


Code Review of the Cairo & SHARP Verifiers


**Recommendation:** We recommend to avoid such magic numbers by defining constants and by documenting their values. Since the maximum size for a page is also
used in the Cairo verifier, we recommend to define the corresponding constant in the
contract `PageInfo` .


**Status:** **Partially** **resolved** **(** **_∼_** **)**
Some comments have been added to explain that these values are somewhat arbitrary.
They still remain as magic numbers. Moreover, even though these values are arbitrary, we recommend to explain why the corresponding sanity checks are needed. For
example, what is the interest of limiting the number of tasks?

#### 5.2 Bootloader source code


5.2.1 File `simple_bootloader.cairo` (main function for the simple bootloader)


The entry point of the simple bootloader (see Section 4.1.1) is the function `main` from
the file `simple_bootloader.cairo` . Using hints, this function parses the input files and
produces some output files while executed by the Cairo runner, but from the Cairo machine
point of view, it simply calls the subfunction `run_simple_bootloader` .


5.2.2 File `bootloader.cairo` (main function for the general bootloader)


The entry point of the general bootloader is the function `main` from the file `bootloader.cairo` .
This function starts by calling the function `run_simple_bootloader` to execute the simple bootloader on the direct subtasks (see Section 4.1.2). However, instead of passing the
real output builtin pointer as an (implicit) argument to this call, it passes a pointer to
another memory area. After the execution of `run_simple_bootloader`, this memory area
contains the output of the simple bootloader. For the rest of its computation, the general
bootloader parses and reorganizes this output as explained in Section 4.1.2.

The function first writes the bootloader configuration at the beginning of its own output
segment (see Figure 6) using the subfunction `serialize_bootloader_config` . The latter
simply writes:


  - the hash digest of the simple bootloader bytecode verified by the Cairo verifier program in composite tasks, and


  - the hash digest of the list of the possible bytecodes for the Cairo verifier program.


Then, the function lets an empty cell in the output memory segment which will be assigned
to the total number of plain tasks (this number is not known yet and will be progressively
computed during the depth-first search of the task tree).

By calling the subfunction `parse_tasks`, the bootloader initializes the depth-first search
of the task tree. It browses recursively each branch of the tree. When it finds a plain
task (a leave of the task tree), it calls the function `unpack_plain_packed_task` which


Page 45/52


Code Review of the Cairo & SHARP Verifiers


simply copies the chunk dedicated to this task from the simple bootloader output (see
Figure 4) to the general bootloader output (see Figure 6) and which increments the counter
of the number of plain tasks. When it encounters a composite task, it calls the function
`unpack_composite_packed_task` . The latter proceeds as follows:


1. It non-deterministically guesses the output of the simple bootloader, _i.e._ the preimage of the hash digest output by the Cairo verifier program.


2. It verifies that the guessing is right by hashing the output and checking the hash
digest.


3. It verifies that the hash digest of the Cairo verifier program is in the list of the
supported program hash digests from the general bootloader configuration.


4. It verifies that the hash digest of the simple bootloader output by the Cairo verifier
program matches the one of the general bootloader configuration.


5. It calls `parse_tasks` on the guessed output to recursively browse the subtasks of the
current composite task.


5.2.3 File `run_simple_bootloader.cairo` (main loop)


The function `run_simple_bootloader` initializes some variables and implements the main
loop which executes the different tasks. Specifically, this function


  - writes the number of tasks to the output segment,


  - initializes the lists `builtin_encodings` and `builtin_instances_sizes` that shall be
given as input of the core function,


  - initializes a range-check pointer `self_range_check_ptr` which will be dedicated to
the verification of the builtin pointers returned by the task programs. This pointer
gives access to a memory segment of length `n_tasks` _×_ `n_supported_builtins` where
`n_tasks` is the number of tasks and `n_supported_builtins` is the number of builtins
the bootloader supports (currently five).


  - initializes a list of builtin pointers which will be used by the task programs. In this
list, the range-check pointer points to the end of the previous range-check segment
(the segment pointed by `self_range_check_ptr` ),


  - calls the auxiliary function `execute_tasks` which calls the function `execute_task`
(from `execute_task.cairo` ) on each task,


  - checks that the memory segment initially pointed by `self_range_check_ptr` has
been completely consumed ( _i.e._ after execution of the tasks `self_range_check_ptr`
matches the initial range-check builtin pointer given to task programs),


Page 46/52


Code Review of the Cairo & SHARP Verifiers


 - checks that the range-check builtin pointer has been effectively advanced beyond the
new value of `self_range_check_ptr` (this is done by checking that the difference
between the two pointers is non-negative).


- **Observation** **19:** **Check** **of** **the** **RC** **builtin** **pointer**


Before returning, the function `run_simple_bootloader` checks that the range-check
builtin pointer has been effectively advanced by calling `verify_non_negative` . However the aim of this check is not clear since the function `execute_task` (from the file
`execute_task.cairo` ) already checks that the builtin pointers used by the task programs have correctly advanced (see next section). Moreover, it is not clear why this
builtin pointer has a special treatment compared to the other builtin pointers used by
task programs.


**Recommendation:** Document the purpose of this check.


**Status:** **Resolved** **(** ✓ **)**
A comment was added at lines 94–102 of `run_simple_bootloader` . This refers to
the “Cairo calling convention”, a convention for Cairo developers stating that only
the builtin instances between the initial and the final values of a builtin pointer are
assumed to be verified by the proof system. Without the check of the range-check
builtin pointer, the function `run_simple_bootloader` could return the same rangecheck builtin pointer that it received as input. Indeed, even if `execute_tasks` is
called with this pointer trustfully advanced at the end of the self range-check segment, the latter function calls untrusted code (the tasks’ bytecode), so that the rangecheck pointer returned by `execute_tasks` (and then by `run_simple_bootloader` )
might have stepped back. In theory, this malicious behavior would be prevented by
`validate_builtins`, but the verification performed by this function is only valid if
the instances of the self range-check segment are verified, which might not be the
case –according to the aforementioned calling convention– if the range-check builtin
pointer returned by `run_simple_bootloader` have stepped back (before the end of the
self range-check segment).

It seems to us that this check is not necessary strictly speaking while considering
how the builtin instances are currently verified in SHARP. In practice, the AIR constraints verify all the instances in the builtin segment (not only the instances between
the initial and final values of the builtin pointer). The above malicious strategy would
require that the self range-check segment (which is at the beginning of the range-check
segment) exceed the range-check segment, which seems unlikely (except if the rangecheck builtin ratio is particularly large or if the trace is particularly small) and which
would be detectable from the statement (because the statement contains the Cairo
layout identifier and the number of tasks as part of the output).

Nonetheless, having this check of the RC builtin pointer enforces the respect of
the “Cairo calling convention” and results in a bootloader bytecode which is secure


Page 47/52


Code Review of the Cairo & SHARP Verifiers


regardless of how the builtin instances are verified. This is safer and we are now
convinced of the usefulness of this check.


5.2.4 File `execute_task.cairo` (task execution)


The core of the bootloader program resides in the `execute_task` function from the file
`execute_task.cairo`, which executes a single task as described in Section 4.1. The task
to be executed is passed via the hint variable `task` . The `execute_task` function further
takes as input:


  - The list `builtin_encodings` of builtins that the bootloader supports. Each builtin is
represented by a field element, called _encoding_ of the builtin. This list _must_ be sorted
in the same order as the builtins’ pointers (implicit arguments of Cairo programs).


  - The list `builtin_instance_sizes` which associates, for each builtin, the size of the
builtin instance.


  - As implicit argument, a list `builtin_ptrs` which for each builtin gives a pointer to
the first unused instance.


  - As implicit argument, a pointer `self_range_check_ptr` which is another pointer
for the range-check builtin. The function hence gets two different pointers for the
range-check builtins. Those two pointers point to two distinct areas of the rangecheck builtin memory segment. The program needs two pointers to this segment
because, for each task, after running the task program, the bootloader shall check
that the updated builtin pointers are valid (and in particular the range-check builtin
pointer), and for this purpose the bootloader needs to use another part of the rangecheck builtin segment, namely the part pointed by `self_range_check_ptr` . The
correct usage of the latter part of the range-check builtin segment is checked by
the `run_simple_bootloader` function, once all the tasks have been executed (see
Section 5.2.3).


In practice, the two non-implicit arguments are constants and, in the audited version
of the bootloader program, are equal to:

```
         builtin_encodings builtin_instance_sizes
           'output' 1
           'pedersen' 3
          'range_check' 1
           'ecdsa' 2
           'bitwise' 5

```

Let us recall that `'xxxxx'` is a short string literal which is encoded as a single field element.


First of all, the function `execute_task` gets the address `program_data_header` of the
task headers and bytecode. This address is given via a hint, and the memory area pointed


Page 48/52


Code Review of the Cairo & SHARP Verifiers


by the address is also filled with a hint. The function then checks that the loaded program
is compatible with the current bootloader version thanks to the corresponding header. Let
us note that at this point nothing ensures that the right bytecode was loaded.

To convince the verifier that the loaded program is the right one, the function then
computes the hash digest of the corresponding memory segment as described in Equation 2
(see Section 4.1) and writes the result in the output segment (using the output builtin).
This hash computation is done by the auxiliary function `hash_chain` which makes use of
the Pedersen builtin (through the pointer `builtin_ptrs.pedersen` ). Using a hint, the
function further recomputes the expected hash digest from the program of the `task` hint
variable and verifies that it matches the digest written in output.

The function then computes the entry point of the program as

```
      program_entry_point = program_address + program_main

```

where `program_address` is the program’s address stored after the header in the bootloader
memory and `program_main` is the absolute position (available from the program header)
of the function `main` of the loaded program (see Table 5, Section 4.1). After computing
the entry point, the function prepares the builtin pointers which will be given as input to
the task program:


  - it increases the output builtin pointer by 2, because the bootloader uses the two first
slots for the output prefix which is composed the segment size and program hash (see
Figure 4),


  - it sets the Pedersen builtin pointer to the value returned by the `hash_chain` function
(which used some Pedersen slots to compute the program hash),


  - the other builtin pointers are left unchanged.


Those updated pointers are stored in the list `pre_execution_builtin_ptrs` . This list
contains the pointers for all the five builtins. However the task program might not use all
of them, but only a subset of them ( _i.e._ the `main` function of the program might take less
than 5 builtin pointers as implicit arguments). That is why the bootloader needs to select
the appropriate builtin pointers according to the list `builtin_list` from the program
header. The selection is done by calling the auxiliary function `select_input_builtins`
which returns the pointers of the selected builtins (at [ `ap` -1], [ `ap` -2], ...). This process is
illustrated in Figure 9 for an example program which only uses the output and range-check
builtins, where the `select_input_builtins` function shall store `ptr` output in [ `ap` -2] and
`ptr` rc in [ `ap` -1].

At this point, the function calls the program with an absolute call to the entry point:


`call` `abs` `program_entry_point` .


From the Cairo runner point of view, this call can be done in two different ways (depending
on the task data processed by the surrounding hints):


Page 49/52


<u>`'output'`</u> <u><mark>`ptr`</mark></u> <u>output</u>
<u>`'pedersen'`</u> <u>`ptr`</u> <u>hash</u>
<u>`'range_check'`</u> <u><mark>`ptr`</mark></u> <u>rc</u>
<u>`'ecdsa'`</u> <u>`ptr`</u> <u>ecdsa</u>
<u>`'bitwise'`</u> <u>`ptr`</u> <u>bitwise</u>



Code Review of the Cairo & SHARP Verifiers


<u>`'output'`</u> <u><mark>`ptr`</mark></u> <u>output</u>
= _⇒_
<u>`'range_check'`</u> <u><mark>`ptr`</mark></u> <u>rc</u>



Figure 9: Selection of builtin pointers.


  - either the Cairo runner has already the symbolic execution trace (a.k.a. the PIE
trace) that the bytecode execution produces and then simply append this trace to
the bootloader trace (also dealing with memory segment allocation) rather than reexecuting the task bytecode,


  - or the Cairo runner does not have such symbolic execution trace and then has to run
the bytecode itself.


When the task program returns, the updated builtin pointers are available in memory
at [ `ap` -1], [ `ap` -2], . . . The idea is now to compute the list `return_builtin_ptrs` of all the
five builtin pointers by updating the pointers of the selected builtins with the returned
builtin pointers from the task execution. This is illustrated on Figure 10 using the same
example as above. In practice, the list `return_builtin_ptrs` is computed thanks to a
hint, and a call to the auxiliary function `inner_select_builtins` checks that this list is
really a extension of the pointers returned by the task program. This call makes use of the
list of selected builtins `builtin_list` from the program header and returns a pointer to
the end of this list. The function then checks that this pointer has well been incremented
of `n_builtins`, the number of builtins from the program header.



<u>`'output'`</u> <u><mark>`ptr`</mark></u> <sup>~~up~~</sup>



<u>`'output'`</u> <u><mark>`ptr`</mark></u> <sup>~~up~~</sup>



= _⇒_



<u>output</u>
<u>`'range_check'`</u> <u><mark>`ptr`</mark></u> <sup><u>up</u></sup> <u>rc</u>



<u>output</u>
<u>`'pedersen'`</u> <u>`ptr`</u> <u>hash</u>
<u>`'range_check'`</u> <u><mark>`ptr`</mark></u> <sup><u>up</u></sup> <u>rc</u>



<u>rc</u>
<u>`'ecdsa'`</u> <u>`ptr`</u> <u>ecdsa</u>
<u>`'bitwise'`</u> <u>`ptr`</u> <u>bitwise</u>



<u>rc</u>



Figure 10: Returned builtin pointers.


Next, the function `validate_builtins` compares the updated list of builtin pointers
(namely `return_builtin_ptrs` ) to its original value before running the program (namely
`pre_execution_builtins_ptrs` ). For each builtin, the function `validate_builtins` checks
that the corresponding pointer has increased by a multiple of the builtin instance size and
that the number of used builtin instances is between 0 and 2 <sup>128</sup>, the range-check bound. <sup>6</sup>

Note that this process does not strictly ensure that the builtin pointers which are not used


6The upper bound depends on the configuration of the range-check builtin via the parameter
`RC_N_PARTS` . This check fixes an implicit maximum for the number of used instances. For example, it
means that the number of outputs of the task program is limited. But in practice, the maximum if very
high constraint is very wide, so the limitation is not an issue.


Page 50/52


Code Review of the Cairo & SHARP Verifiers


by the task program are the same between both lists. A malicious prover could indeed
advance the builtin pointers which are not used by the task program. However, while
doing so would waste some <u>builtin</u> memory space, it would not allow to prove a false CI
statement since the Cairo verifier checks that the builtin pointers returned by the main
function are valid ( _i.e._ are before the end of the respective builtin memory segments).

Finally, the function `execute_task` puts in the output segment the number of output
slots consumed by the task program (see Figure 4), use some hint to store the fact topology
of the executed task and set the implicit return value of `builtin_ptrs` to the address of
the new list `&return_builtins_ptrs` .


 - **Observation** **20:** **Absolute** **positions** **in** **the** **bytecode**


According to the user documentation [5], the instruction `call` with an absolute position
is not supported by Cairo although it is defined in the Cairo article [2] (and used by
the bootloader). Presumably, this restriction aims to ensure that the bytecode is
position-independent and can hence correctly be used by the bootloader (which deals
with memory allocation for tasks). On the other hand, the jump at absolute position
( `jmp` `abs` instruction) seems to be supported. Why this difference of treatment?


**Recommendation:** Document the support (or non-support) of absolute positions
in the bytecode.


**Status:** **Resolved** **(** ✓ **)**
The user documentation [5] has been updated and now states that the instruction
`call` with an absolute position is supported:


The full syntax of `call` is similar to `jmp` : you can call a label (a function is
also considered a label), and make a relative or absolute call ( `call` `rel/abs`
`...` ).


                              - “Functions” page.


Page 51/52


Code Review of the Cairo & SHARP Verifiers

### References


[1] CryptoExperts (Thibauld <u>Feneuil</u> and Matthieu Rivain). Code Review of StarkWare’s

EVM STARK Verifier, December 2021.


[2] Lior Goldberg, Shahar Papini, and Michael Riabzev. Cairo - a turing-complete stark
friendly cpu architecture. Cryptology ePrint Archive, Report 2021/1063, 2021. `[https:](https://ia.cr/2021/1063)`
`[//ia.cr/2021/1063](https://ia.cr/2021/1063)` .


[3] StarkWare. ethstark documentation. Cryptology ePrint Archive, Report 2021/582,
2021. `[https://ia.cr/2021/582](https://ia.cr/2021/582)` .


[4] StarkWare. Cairo for Blockchain Developers, 2022. `[https://www.cairo-lang.org/](https://www.cairo-lang.org/cairo-for-blockchain-developers/)`

`[cairo-for-blockchain-developers/](https://www.cairo-lang.org/cairo-for-blockchain-developers/)` .


[5] StarkWare. StarkNet and Cairo Documentation, 2022. `[https://www.cairo-lang.](https://www.cairo-lang.org/docs/)`
`[org/docs/](https://www.cairo-lang.org/docs/)` .


Page 52/52


