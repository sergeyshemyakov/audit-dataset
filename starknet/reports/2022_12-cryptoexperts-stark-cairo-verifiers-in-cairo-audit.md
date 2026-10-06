# **Smart Contract Audit Report**
## **Conducted by CryptoExperts**

As part of our due process, we retained CryptoExperts to review the design document and

related source code of the STARK/Cairo verifier. We chose to work with CryptoExperts

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


Code review of the Cairo implementation of the STARK/Cairo verifier

### Contents


**1** **Introduction** **4**
1.1 Audited code . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4
1.2 Methodology and summary of findings . . . . . . . . . . . . . . . . . . . . . 5


**2** **Complementary** **documentation** **7**
2.1 Notations . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 7
2.1.1 STARK verifier . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 7
2.1.2 Cairo verifier . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 10
2.2 Architecture of the verifier . . . . . . . . . . . . . . . . . . . . . . . . . . . . 11
2.2.1 Overview of the verification process . . . . . . . . . . . . . . . . . . . 11
2.2.2 Three verification levels . . . . . . . . . . . . . . . . . . . . . . . . . 11
2.2.3 Architecture of the code . . . . . . . . . . . . . . . . . . . . . . . . . 13
2.3 Input format . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 14
2.3.1 Public input . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 15
2.3.2 Proof format . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 16
2.4 Differences with the Solidity implementation . . . . . . . . . . . . . . . . . . 17
2.5 External dependencies . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 18


**3** **Review** **of** **the** **Cairo** **verifier** **21**
3.1 Verifier channel . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 21
3.1.1 File `channel.cairo` . . . . . . . . . . . . . . . . . . . . . . . . . . . 22
3.1.2 File `queries.cairo` . . . . . . . . . . . . . . . . . . . . . . . . . . . 24
3.1.3 File `utils.cairo` . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 25
3.2 Commitments . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 25
3.2.1 File `vector_commitment.cairo` . . . . . . . . . . . . . . . . . . . . . 27
3.2.2 File `table_commitment.cairo` . . . . . . . . . . . . . . . . . . . . . 29
3.2.3 File `traces.cairo` . . . . . . . . . . . . . . . . . . . . . . . . . . . . 29
3.3 FRI protocol . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 30
3.3.1 File `fri/fri_formula.cairo` . . . . . . . . . . . . . . . . . . . . . . 32
3.3.2 File `fri/fri_layer.cairo` . . . . . . . . . . . . . . . . . . . . . . . 33
3.3.3 File `fri/fri.cairo` . . . . . . . . . . . . . . . . . . . . . . . . . . . 34
3.3.4 File `fri/config.cairo` . . . . . . . . . . . . . . . . . . . . . . . . . 35
3.4 Core STARK verifier . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 36
3.4.1 File `domains.cairo` . . . . . . . . . . . . . . . . . . . . . . . . . . . 36
3.4.2 File `air_interface.cairo` . . . . . . . . . . . . . . . . . . . . . . . 37
3.4.3 File `proof_of_work.cairo` . . . . . . . . . . . . . . . . . . . . . . . 38
3.4.4 File `config.cairo` ( `stark_verifier/core` ) . . . . . . . . . . . . . . 39
3.4.5 File `stark.cairo` . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 40
3.5 Public input . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 43
3.5.1 File `public_memory.cairo` . . . . . . . . . . . . . . . . . . . . . . . 44
3.5.2 File `public_input.cairo` . . . . . . . . . . . . . . . . . . . . . . . . 45


Page 2/59


Code review of the Cairo implementation of the STARK/Cairo verifier


3.5.3 File `public_verify.cairo` . . . . . . . . . . . . . . . . . . . . . . . 47
3.6 Layout constraints . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 49
3.6.1 File `diluted.cairo` . . . . . . . . . . . . . . . . . . . . . . . . . . . 49
3.6.2 File `global_values.cairo` . . . . . . . . . . . . . . . . . . . . . . . 49
3.6.3 File `composition.cairo` . . . . . . . . . . . . . . . . . . . . . . . . . 49
3.7 DEEP composition polynomial . . . . . . . . . . . . . . . . . . . . . . . . . 50
3.7.1 File `oods.cairo` . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 50
3.8 Cairo verifier . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 51
3.8.1 File `layout.cairo` . . . . . . . . . . . . . . . . . . . . . . . . . . . . 51
3.8.2 File `verify.cairo` . . . . . . . . . . . . . . . . . . . . . . . . . . . . 52
3.8.3 File `cairo_verifier.cairo` . . . . . . . . . . . . . . . . . . . . . . . 52


**A** **FRI** **folding** **formula** **57**


**B** **Diluted** **component** **product** **58**


Page 3/59


Code review of the Cairo implementation of the STARK/Cairo verifier

### 1 Introduction


StarkWare is a company <u>developing</u> scalability and privacy technologies for blockchain
applications. In particular, StarkWare develops a STARK-powered level-2 scalability
engine which uses cryptographic proofs to attest to the validity of a batch of transactions.
As part of StarkWare’s technology, the Cairo STARK-friendly CPU architecture allows
developers to easily write STARK-provable programs for general computation.

In this context, CryptoExperts has conducted a first audit of StarkWare’s STARK
verifier (implemented as a Solidity smart contract) in late 2021 as well as a second audit
of their Cairo verifier and associated shared proof service (SHARP), which are built on
top of the STARK verifier (together with the Cairo code of the bootloader) in March and
April 2022.

StarkWare was then willing to perform a follow-up audit of the Cairo implementation of their STARK/Cairo verifiers, which is used for recursive STARK proofs. Upon
business agreement with StarkWare, CryptoExperts has conducted this third audit
in October and November 2022. The primary goal of this audit was to ensure that the
Cairo code correctly verifies the computational integrity proof of a Cairo program. The
service consisted of a study of the STARK & Cairo documentation and a review of the
code by two engineers, experts in cryptography. The present report contains the results of
this audit.

We first identify the audited code (Section 1.1) and give a summary of the audit methodology and findings (Section 1.2). We then provide some complementary documentation for
the audited code in Section 2. The results of the audit are presented in Section 3 which is
structured according to the functionalities of the underlying source files: verifier channel
(§ 3.1), commitments (§ 3.2), FRI protocol (§ 3.3), core STARK verifier (§ 3.4), public
input (§ 3.5), layout constraints (§ 3.6), DEEP composition polynomial (§ 3.7), and Cairo
verifier (§ 3.8).

#### 1.1 Audited code


The audited source code corresponds to a STARK/Cairo verifier written in the Cairo
programming language. This code aims to verify a STARK proof of the computational
integrity of a Cairo program. Given a proof, a program bytecode, and a program output,
it verifies that the prover knows a program input for which the considered program produces
the considered output. Such a Cairo implementation of the STARK/Cairo verifier aims to
be used for recursive proofs.

The audited code is composed of 41 Cairo source files in the following repos:


  - `[https://github.com/starkware-libs/cairo-lang/tree/master/src/starkware/](https://github.com/starkware-libs/cairo-lang/tree/master/src/starkware/cairo/stark_verifier)`
```
  cairo/stark_verifier

```

  - `[https://github.com/starkware-libs/cairo-lang/tree/master/src/starkware/](https://github.com/starkware-libs/cairo-lang/tree/master/src/starkware/cairo/cairo_verifier)`
```
  cairo/cairo_verifier

```

Page 4/59


Code review of the Cairo implementation of the STARK/Cairo verifier


excluding files named `autogenerated.cairo` and `periodic_columns.cairo` which are
auto-generated. The version of the code to be reviewed corresponds to the commit `d61255f`,
“Cairo v0.10.0.”, from September 5, 2022. Those 41 source files contain about 4400 lines
of code written in Cairo language.

#### 1.2 Methodology and summary of findings


The main goal of this audit was to validate the soundness of the reviewed Cairo implementation of STARK/Cairo verifier. More precisely, this audit aims


  - to confirm that the implemented verification process is compliant with the specification of the STARK/Cairo verifier,


  - to check the absence of flaws in the implementation which would allow an adversary
to forge a valid proof for an invalid statement (with less effort than the target security
level).


The audit methodology consisted in an in-depth review of the code by two different persons (engineers, junior and senior experts in cryptography), confronting our understanding
of the code and keeping track of our observations.


Our observations are categorized as follows:


  - Observations that may impact the soundness of the verifier, rated as


**–** high risk (flagged ●),


**–** medium risk (flagged ●),


**–** low risk (flagged ●).


  - Observations related to coding practices and implementation choices (flagged ●).


**–** These observations do not translate into a direct risk on the soundness of the

verifier but addressing them would make the code clearer, more efficient, and/or
less prone to errors.


  - Observations related to documentation, comments, variable naming (flagged ■).


**–** These observations do not translate into a direct risk on the soundness of the

verifier but addressing them would facilitate the understanding of the code by
third parties (users, developers, auditors).


Each observation comes with an associated recommendation to fix or improve the underlying issue.


_General_ _remark._ We were provided with a clear set of documentation about the STARK
protocol and Cairo [6, 4, 5, 3, 7] but sometimes missed detailed specifications for the
audited code. To reach a global and confident understanding of the implementation, we
wrote down the missing specifications according to our understanding of the code, which


Page 5/59


Code review of the Cairo implementation of the STARK/Cairo verifier


we include in the present report. Part of it is given in Section 2 while the rest appears in
the preamble of each sub-section of Section 3.


_Summary_ _of_ _findings_ _on_ _the_ _~~Ca~~_ _iro_ _implementation_ _of_ _STARK/Cairo_ _verifier._ Our findings
are summarized in the table below. Our observations are only related to coding practices
and documentation. We did not detect any flaw that could affect the soundness of the
verifier. We therefore conclude that, up to the limitations inherent to human code review,
the code is a sound implementation of the STARK/Cairo verifier.


**<u>Category</u>** **<u>Number</u>** **<u>of</u>** **<u>findings</u>**

      - <u>High</u> <u>risk</u> <u>0</u>

      - <u>Medium</u> <u>risk</u> <u>0</u>

      - <u>Low</u> <u>risk</u> <u>0</u>

      - <u>Coding</u> <u>practices</u> <u>10</u>

       - <u>Documentation</u> <u>10</u>
**<u>Total</u>** **<u>20</u>**


Page 6/59


Code review of the Cairo implementation of the STARK/Cairo verifier

### 2 Complementary documentation


This section provides some <u>complementary</u> documentation which we inferred from the
audited code (and from our previous reports). It includes a reminder of useful notions and
notations (§ 2.1), some details about the verifier architecture (§ 2.2) and the input format
(§ 2.3.1), and a list of the external dependencies which are out of scope of this audit (§ 2.5).

#### 2.1 Notations


We recall hereafter the notions and notations which are relevant to this report. For the
STARK verifier, we use the notations and terminologies introduced in the ethSTARK documentation [6] and additional notations introduced in our previous report on the STARK
verifier [1]. For the CPU verifier, we use the notations and terminologies introduced in the
Cairo article [3] and additional notations introduced in our previous report on the Cairo
verifier [2].


2.1.1 STARK verifier


  - The _IOP_ _Prover_ and the _IOP_ _Verifier_ refer to the two parties of the interactive
protocol ( _i.e._ before the transformation to a non-interactive protocol).


  - The _Execution_ _Trace_ uses _W_ registers and has length _L_, where _L_ is a power of two.
In case _Randomized_ _AIR_ _with_ _Preprocessing_ [3] is used (which is always the case for
Cairo proofs), we denote _W_ <sup>_′_</sup> the number of columns after the sampling of _interaction_
_elements_ .


  - The values in the trace cells are elements of the finite field F _p_ with _p_ a prime. In
practice, the prime _p_ is defined as


_p_ := 2 <sup>251</sup> + 17 _·_ 2 <sup>192</sup> + 1 _._


  - The _Trace_ _Evaluation_ _Domain_ is defined as a multiplicative subgroup _⟨g⟩_ of F <sup>_×_</sup> _p_ <sup>of</sup>
size _L_ .


  - Each trace column is interpreted as the _L_ point-wise evaluations of a polynomial
of degree smaller than _L_ over the trace evaluation domain. These polynomials are
referred to as the _Trace_ _Column_ _polynomials_ and are denoted by _f_ 0 _, . . ., fW_ _−_ 1.


  - An _Algebraic Intermediate Representation (AIR) Polynomial Constraint_ on the trace
(represented as a rational function) is denoted _Cj_ and is of degree _Dj_ . We denote _D_
the smallest power of two which is greater than all the constraint degrees.


  - The _Composition_ _Polynomial_ is denoted by _h_ ( _x_ ) and takes the form



_h_ ( _x_ ) =



_k_



_j_ =1



_Cj_ ( _x_ )( _αjx_ <sup>_D−Dj_</sup> <sup>_−_</sup> <sup>1</sup> + _βj_ ) (1)



Page 7/59


Code review of the Cairo implementation of the STARK/Cairo verifier


where _k_ is the number of constraints. Its degree is _D_ _−_ 1. This polynomial can
be decomposed into _M_ 2 polynomials _h_ 0 _, . . ., hM_ 2 _−_ 1 of degree _L_ (called _Composition_
_Polynomial_ _Trace_ ) such that



_h_ ( _x_ ) =



_M_ 2 _−_ 1

- _x_ <sup>_i_</sup> _hi_ ( _x_ <sup>_M_</sup> <sup>2</sup> ) _._ (2)


_i_ =0




- To check the consistency between the execution trace and the composition polynomial
trace, _h_ is evaluated using the two above expressions in a single random point denoted
_z_ which is called the _OODS_ _point_ .


- To evaluate _h_ in the OODS point _z_ using (1), we need a set of values of the form
_fj_ ( _zg_ <sup>_s_</sup> ) which are involved in the expressions of the _{Cj_ ( _z_ ) _}j_ . This set of values is
called the _mask_ . It is denoted _{yℓ}ℓ_ and its size is denoted _M_ 1.


- To evaluate _h_ in the OODS point _z_ using (2), we need the values _hi_ ( _x_ <sup>_M_</sup> <sup>2</sup> ) for 0 _≤_
_i < M_ 2. Those values are denoted _y_ ˆ _i_ := _hi_ ( _z_ <sup>_M_</sup> <sup>2</sup> ).


- The elements of _{yℓ}ℓ_ _∪{y_ ˆ _i}i_ are called the _OODS_ _Values_ .


- The _DEEP_ _Composition_ _Polynomial_, denoted _p_ 0( _x_ ) is defined as:



_M_ 2 _−_ 1



_i_ =0



_γM_ 1+ _i ·_ <sup>_<u>hi</u>_</sup> <sup><u>(</u></sup> <sup>_<u>x</u>_</sup> <sup><u>)</u></sup> <sup>_<u>−</u>_</sup> <sup>_<u>y</u>_</sup> <sup><u>ˆ</u></sup> <sup>_<u>i</u>_</sup>

_x −_ _z_ <sup>_M_</sup> <sup>2</sup>



_p_ 0( _x_ ) =



_M_ 1 _−_ 1



_ℓ_ =0



_γℓ_ _·_ <sup>_<u>fjℓ</u>_</sup> <sup><u>(</u></sup> <sup>_<u>x</u>_</sup> <sup><u>)</u></sup> <sup>_<u>−</u>_</sup> <sup>_<u>yℓ</u>_</sup> +

_x −_ _zg_ <sup>_sℓ_</sup>



where _{γ_ 0 _, . . ., γM_ 1+ _M_ 2 _−_ 1 _}_ are random coefficients sampled by the IOP verifier, called
_OODS_ _Coefficients_ .


- To achieve a secure protocol, the polynomials _f_ 0 _, . . ., fW_ _−_ 1 and _h_ 0 _, . . ., hM_ 2 _−_ 1 are
evaluated over a domain _L_ 0, larger than and disjoint from the trace evaluation domain, which we call the _evaluation_ _domain_ . We refer to this evaluation as _the_ _trace_
_Low Degree Extension (LDE)_ and the ratio _|L_ 0 _|/L_ (ratio between the size of the evaluation domain and the size of the trace evaluation domain) is further referred to as
the _blowup_ _factor_, denoted _β_ . In practice, _L_ 0 is a non-unit coset of the multiplicative
subgroup _⟨g_ lde _⟩⊆_ F <sup>_×_</sup> _p_ <sup>of</sup> <sup>size</sup> <sup>_βL_</sup> <sup>.</sup> <sup>That</sup> <sup>is</sup> <sup>_L_</sup> <sup>0</sup> <sup>is</sup> <sup>defined</sup> <sup>as</sup>


_L_ 0 := _c_ lde _· ⟨g_ lde _⟩_


for some _c_ lde _̸_ = 1.


- The FRI protocol is composed of different _layers_ . We denote _K_ the number of
FRI layers. Except for the last one, each layer performs several _FRI_ _steps_ . For
the _i_ th layer, the number of steps is denoted _ℓi_, which is stored in a list named
`fri_step_sizes[]` . Namely,


_ℓi_ := `fri_step_sizes[` _i_ `]` _._


Page 8/59


Code review of the Cairo implementation of the STARK/Cairo verifier


(This list is named `fri_step_list` in the Solidity implementation of the verifer [1].)
We further denote by _si_ the total number of steps from layers 1 to _i_, that is



_si_ :=



_i_



_j_ =1



_ℓi_ _._




- At the _i_ th layer, the IOP prover starts with a polynomial _pi−_ 1. She gets a random
challenge _ζi−_ 1 _∈_ F _p_ from the verifier and computes the new polynomial _pi_ as



_i_ <sup>[</sup> <sup>_j_</sup> _−_ <sup>]</sup> 1 <sup>(</sup> <sup>_x_</sup> <sup>)</sup> (3)



_pi_ ( _x_ ) =



2 <sup>_ℓi_</sup> _−_ 1



_j_ =0



_ζi_ <sup>_j_</sup>



_i_ <sup>_j_</sup> _−_ 1 <sup>_· p_</sup> _i_ <sup>[</sup> <sup>_j_</sup> _−_ <sup>]</sup>



where the _{p_ <sup>[</sup> _i_ <sup>_j_</sup> _−_ <sup>]</sup> 1 <sup>_}j_</sup> <sup>are</sup> <sup>the</sup> <sup>polynomials</sup> <sup>defined</sup> <sup>such</sup> <sup>that</sup>



_pi−_ 1( _x_ ) =



2 <sup>_ℓi_</sup> _−_ 1



_j_ =0



_x_ <sup>_j_</sup> _· p_ <sup>[</sup> _i_ <sup>_j_</sup> _−_ <sup>]</sup> 1 <sup>(</sup> <sup>_x_</sup> <sup>2</sup> <sup>_ℓi_</sup> <sup>)</sup> <sup>_._</sup>




- Let _Li_ the evaluation domain of _pi_ . Then, for every _i ≥_ 1, we have



_Li_ :=


which by definition of _L_ 0 implies




- _x_ <sup>2</sup> <sup>_ℓi_</sup> _, x ∈_ _Li−_ 1�



_Li_ = _c_ <sup>2</sup> lde <sup>_si_</sup>




<sup>2</sup> lde <sup>_si_</sup> <sup>_· ⟨g_</sup> lde <sup>2</sup> <sup>_si_</sup>



lde <sup>2</sup> <sup>_si_</sup> <sup>_⟩_</sup> <sup>_._</sup>




- The polynomial _p_ 0 at the input of the FRI protocol is the DEEP composition polynomial and we have, for _i ≥_ 0,

deg _pi_ = <sup>_<u>L</u>_</sup>

2 <sup>_si_</sup>

where _si_ is defined as above.


- All the coefficients of the final polynomial _pK−_ 1 are sent to the IOP Verifier.


- Once the polynomials _{pi}i_ are committed, the FRI protocol evaluates these polynomials on a set of evaluation points, called _queries_ . The set of queries for the
polynomial _pi_ is denoted _Qi_ _⊂_ _Li_, and for every _i ≥_ 1, we have



_Qi_ :=




- _x_ <sup>2</sup> <sup>_ℓi_</sup> _, x ∈Qi−_ 1�



where _Q_ 0 _⊆_ _L_ 0 is the set of random queries sampled by the IOP verifier at the
beginning of the query phase of the FRI protocol.


Page 9/59


Code review of the Cairo implementation of the STARK/Cairo verifier


- Each element _x_ of _Li_ has an index index _i_ ( _x_ ) defined such as




- _e_
_⇐⇒_ index _i_ ( _x_ ) = bit-reverselog2 _|Li|_ ( _e_ )




- _·_ - _g_ lde <sup>2</sup> <sup>_si_</sup>




- _·_ - _g_ lde <sup>2</sup> <sup>_si_</sup>



_x_ =




- _c_ <sup>2</sup> lde <sup>_si_</sup>



where bit-reverselog2 _|Li|_ ( _e_ ) stands for the bit reverse of the exponent _e_ on log2 _|Li|_ =
log2( _β · L_ ) _−_ _si_ bits. We further denote


index _i_ ( _x_ ) := index _i_ ( _x_ ) + _|Li|_ _._


- We introduce the _scaled_ versions of several FRI notions. For all 0 _≤_ _i ≤_ _K −_ 1,




**–** the _scaled_ layer polynomial _p_ <sup>_′_</sup> _i_




<sup>_′_</sup> _i_ <sup>(</sup> <sup>_x_</sup> <sup>)</sup> <sup>is</sup> <sup>defined</sup> <sup>as</sup> <sup>_p′_</sup> _i_




<sup>_′_</sup> _i_ <sup>(</sup> <sup>_x_</sup> <sup>) :=</sup> <sup>_pi_</sup> <sup>(</sup> <sup>_c_</sup> <sup>2</sup> lde <sup>_si_</sup>




<sup>2</sup> lde <sup>_si_</sup> <sup>_· x_</sup> <sup>);</sup>




**–** the scaled layers polynomials _p_ <sup>_′_</sup> _i_




<sup>_′_</sup> _i−_ 1 <sup>and</sup> <sup>_p′_</sup> _i_



the scaled layers polynomials _p_ <sup>_′_</sup> _i−_ 1 <sup>and</sup> <sup>_p′_</sup> _i_ <sup>verify</sup> <sup>a</sup> <sup>similar</sup> <sup>relation</sup> <sup>than</sup> <sup>in</sup> <sup>the</sup>

Equation 4 but for the _scaled_ challenges defined as




- _−_ 1

_· ζi−_ 1 ;



_ζi_ <sup>_′_</sup> _−_ 1 <sup>:=</sup>




- _c_ <sup>2</sup> lde <sup>_si−_</sup> <sup>1</sup>




**–** the _scaled_ evaluation domain _L_ <sup>_′_</sup> _i_



the _scaled_ evaluation domain _L_ <sup>_′_</sup> _i_ <sup>and</sup> <sup>the</sup> <sup>_scaled_</sup> <sup>set</sup> <sup>_Q′_</sup> _i_ <sup>of</sup> <sup>queries</sup> <sup>for</sup> <sup>the</sup> <sup>poly-</sup>

nomial _p_ <sup>_′_</sup> _i_ <sup>are</sup> <sup>defined</sup> <sup>as</sup>




<sup>_′_</sup> _i_ <sup>are</sup> <sup>defined</sup> <sup>as</sup>




<sup>_′_</sup> _i_ <sup>and</sup> <sup>the</sup> <sup>_scaled_</sup> <sup>set</sup> <sup>_Q′_</sup> _i_




- _−_ 1 _· Li_ = _⟨g_ lde2 _si_ <sup>_⟩_</sup> and _Q_ <sup>_′_</sup> _i_ <sup>:=</sup> <sup>_{_</sup>




- _−_ 1 _· Li_ = _⟨g_ lde2 _si_ <sup>_⟩_</sup> and _Q_ <sup>_′_</sup> _i_




- _c_ <sup>2</sup> lde <sup>_si_</sup>




- _c_ <sup>2</sup> lde <sup>_si_</sup>




- _−_ 1 _· v_ ; _v_ _∈Qi}_ _._



_L_ <sup>_′_</sup> _i_ <sup>:=</sup>




- _c_ <sup>2</sup> lde <sup>_si_</sup>




- _c_ <sup>2</sup> lde <sup>_si_</sup>



2.1.2 Cairo verifier


  - The Cairo machine has three registers:


**–** the _program_ _counter_, denoted `pc`, which contains the memory address of the

next Cairo instruction to be executed,


**–** the _allocation_ _pointer_, denoted `ap`, which (by convention) points to the first

memory cell that has not been used by the program so far, and


**–** the _frame_ _pointer_, denoted `fp`, which (by convention) points to the beginning

of the stack frame of the current function.


  - The CPU has access to a _nondeterministic_ _continuous_ _read-only_ _memory_ m.


  - The Cairo machine relies on _builtins_ which offer a way to efficiently perform some
specific computation tasks. A builtin aims to perform a specific computation that
involves several field elements. A builtin _instance_ is a set of those field elements and
the _size_ of the instance is defined as the size of this set. Each builtin is assigned to
a _memory_ _segment_ which is split into small chunks. Each chunk corresponds to a
builtin instance, and the values stored on a chunk must satisfy the relation of the
builtin.


Page 10/59


Code review of the Cairo implementation of the STARK/Cairo verifier


  - The execution of a program can be represented as a sequence of states of the three
registers ( `pc` _i,_ `ap` _i,_ `fp` _i_ ) _i_ and a memory function m : F _p_ _→_ F _p_ . We denote _T_ the
number of steps (or state transitions) in the program execution and


_N_ := _T_ + 1


the number of states. Each state of the Cairo machine is represented in the execution
trace by a small set of successive rows called _component_ . The trace length _L_ ( _i.e._ its
total number of rows) satisfies the relation


_L_ = `CPU_COMPONENT_HEIGHT` _· N_


where `CPU_COMPONENT_HEIGHT` is the number of rows in a component.


  - We call _layout_ the organization of all the variables in the execution trace. A layout
depends on which builtins are supported, but it also depends on the configuration of
those builtins.

#### 2.2 Architecture of the verifier


2.2.1 Overview of the verification process


The STARK proof system is a non-interactive version of an IOP protocol relying on the
FRI protocol. The underlying interactive protocol is depicted in Figure 1.

The STARK proof corresponds to a non-interactive version of this protocol using the
Fiat-Shamir heuristic. In this paradigm, each verifier-to-prover arrow corresponds to some
public-coin challenges obtained through pseudo-random generation from a seed, where the
latter seed is obtained by hashing the previously received elements from the prover. On the
other hand, each prover-to-verifier arrow corresponds to a commitment or a response to a
(pseudo-randomly generated) challenge. Along the verification process, the verifier reads
the prover-to-verifier elements from the proof, updates a hash digest for the Fiat-Shamir
heuristic (the _verifier_ _channel_ ), and pseudo-randomly generates the verifier-to-prover elements from this hash seed. Different verification steps are then applied to the received
elements (read from the proof) and the sent elements (pseudo-randomly generated).


2.2.2 Three verification levels


The audited verifier has been organized with the following three levels.


**Core** **STARK** **verifier.** This bottom level implements the core of the STARK verification process. It does not deal with the format of execution traces, the AIR constraints,
and the public input ( _i.e._ the statement to be verified). For this reason, using STARK
core further requires to:


  - functions to validate the trace format, commit the traces and decommit them,


  - functions to validate and hash the public input,


Page 11/59


Code review of the Cairo implementation of the STARK/Cairo verifier



**Prover** **Verifier**



<u>HashMerkle(Trace0)</u>



<u>Interaction</u> <u>Elements</u>



<u>HashMerkle(Trace1)</u>



<u>{</u> _αj_ <u>}</u> _<u>j</u>_ <u>, {</u> _βj_ <u>}</u> _<u>j</u>_



<u>Hash(C . P .</u> <u>Columns)</u>



<u>OODS</u> <u>Point</u> _<u>z</u>_



<u>OODS</u> <u>Values</u> <u>{</u> _yℓ_ <u>}</u> _ℓ_ <u>∪{̂</u> _yℓ_ <u>}</u> _ℓ_

<u>OODS</u> <u>Coefcientsfi</u> <u>{</u> _γ_ <u>0, …,</u> _γM_ <u>1+</u> _M_ <u>2−1}</u>

<u>HashMerkle(</u> _<u>p</u>_ <u>0)</u>

_<u>ζ</u>_ <u>0</u>

<u>HashMerkle(</u> _<u>p</u>_ <u>1)</u>



_p_ 0 =


2

_p_ 1 =

2

=



2 <sup>_ℓ_</sup> <sup>0</sup> −1

∑
_j_ =0

2 <sup>_ℓ_</sup> <sup>1</sup> −1

∑
_j_ =0



2 <sup>_ℓ_</sup> <sup>0</sup> −1

∑
_j_ =0



2 <sup>_ℓ_</sup> <sup>0</sup> −1



_x_ <sup>_j_</sup> _p_ 1 <sup>[</sup> <sup>_j_</sup> <sup>]</sup> ( _x_ <sup>2</sup> <sup>_ℓ_</sup> <sup>1</sup> )



_x_ <sup>_j_</sup> _p_ 0 <sup>[</sup> <sup>_j_</sup> <sup>]</sup> ( _x_ <sup>2</sup> <sup>_ℓ_</sup> <sup>0</sup> )


_ζ_ 0 <sup>_j_</sup> <sup>_p_</sup> 0 <sup>[</sup> <sup>_j_</sup> <sup>]</sup> ( _x_ )



_<u>ζ</u>_ <u>1</u>

<u>⋮</u>

<u>HashMerkle(</u> _pK_ <u>−2)</u>

_<u>ζK</u>_ <u>−2</u>

_pK_ <u>−1</u>


_PoW Nonce_

<u>⋮</u>



⋮



2 <sup>_ℓK_</sup> <sup>−2</sup> −1

∑
_j_ =0



_K_ <sup>[</sup> <sup>_j_</sup> −2 <sup>]</sup> <sup>(</sup> <sup>_x_</sup> <sup>)</sup>



_pK_ −1 =



_ζ_ <sup>_j_</sup>



_ζK_ <sup>_j_</sup> −2 <sup>_p_</sup> _K_ <sup>[</sup> <sup>_j_</sup> −2 <sup>]</sup>



**Prover** **Verifier**

⋮

<u>풬0</u>

Trace Query Responses

<u>{</u> _f_ <u>0(</u> _v_ <u>), …,</u> _fW_ <u>′−1(</u> _v_ <u>)}</u> _v_ <u>∈풬0</u>


_Authentication paths…_


Trace Query Responses 2

<u>{</u> _fW_ <u>′(</u> _v_ <u>), …,</u> _fW_ <u>−1(</u> _v_ <u>)}</u> _<u>v</u>_ <u>∈풬0</u>

_Authentication paths…_

Composition Query Responses

<u>{</u> _h_ <u>0(</u> _v_ <u>), …,</u> _hM_ <u>2−1(</u> _v_ <u>)}</u> _v_ <u>∈풬0</u>


_Authentication paths…_


<u>Missing</u> <u>Evaluations</u> <u>of</u> _p_ <u>0</u>

_Authentication paths…_

<u>⋮</u>

<u>Missing</u> <u>Evaluations</u> <u>of</u> _pK_ <u>−2</u>

_Authentication paths…_



Figure 1: STARK interactive protcol


  - functions to evaluate the composition polynomial and the DEEP composition polynomial (which depend on the AIR constraints).


From those functions, the STARK core can check that the proof is consistent with the
statement. The source files of the STARK verifier are available in

```
               stark_verifier/core

```

and its entry point is the function

```
        verify_stark_proof(air, proof, security_bits)

```

of the file `stark_verifier/core/stark.cairo` .


**CPU** **verifier** **(layout** **definition).** This middle level specifies the above verifier by
defining the format of the execution trace, the public input, and the layout (the set of
AIR constraints corresponding to a specific Cairo machine). Specifically, it implements
the functions required by the core STARK verifier. The public memory is represented by
a _main_ _page_ and a set of _continuous_ _pages_ . The organization and the content of those


Page 12/59


Code review of the Cairo implementation of the STARK/Cairo verifier


pages is not defined at this level. When calling the CPU verifier, one needs to previously
fill those pages (for example, with the program bytecode). The source files of the CPU
verifier are available in

```
               stark_verifier/air

```

and its entry point is the function

```
           verify_proof(proof, security_bits)

```

of the file `stark_verifier/air/layouts/xxxx/verify.cairo`, where `xxxx` is a CPU layout.


**Cairo** **verifier** **(page** **definition).** This top level defines the content of the pages of
the public memory which shall be used in the CPU verifier. In the context of the Cairo
implementation of the verifier, the full public memory (including the memory mapping
about the output segment) is defined by the main page and there is no continuous page.
The source files of the Cairo verifier are available in


`cairo_verifier` .


and its entry point is the function

```
             verify_cairo_proof(proof)

```

of the file `cairo_verifier/layouts/xxxx/cairo_verifier.cairo`, where `xxxx` is a CPU
layout.


**Remark** **1.** _Continuous_ _pages_ _are_ _used_ _in_ _the_ _context_ _of_ _the_ _SHARP_ _verifier_ _which_ _verifies_
_several_ _Cairo_ _programs,_ _or_ tasks _,_ _loaded_ _and_ _executed_ _through_ _the_ Cairo bootloader _[2]._
_The_ _output_ _of_ _each_ _task_ _is_ _stored_ _in_ _a_ _separate_ _continuous_ _page,_ _which_ _enables_ _independent_
_validation_ _of_ _each_ _task_ _from_ _the_ _global_ _proof._ _The_ _purpose_ _of_ _the_ _Cairo_ _implementation_ _of_
_the_ _verifier_ _is_ _not_ _to_ _verify_ _several_ _tasks_ _at_ _the_ _same_ _time_ _but_ _a_ _single_ _one,_ _which_ _is_ _why_
_the_ _number_ _of_ _continuous_ _pages_ _is_ _set_ _to_ _zero_ _in_ _the_ _current_ _implementation._


2.2.3 Architecture of the code


The source code can be organized under several bundles of source files corresponding to
different functionalities:


  - the files which implement the _verifier_ _channel_ ( _i.e._ the state of the IOP verifier in
the Fiat-Shamir heuristic), dealing with proof reading and challenge sampling,


  - the files which manage Merkle tree _commitments_ (and decommitments),


  - the files which implement the _FRI_ _protocol_,


  - the files which implement the _core_ _STARK_ _verifier_,


Page 13/59


Code review of the Cairo implementation of the STARK/Cairo verifier


  - the files which manage the _public_ _input_,


  - the files dealing with the _AIR_ _constraints_ corresponding to the _CPU_ _layout_,


  - the file which implements the _DEEP_ _composition_ _polynomial_ (or OODS polynomial),


  - the files which implement the _Cairo_ _verifier_ (as a specialization of the core STARK
verifier).


This organization is further illustrated in Figure 2. The STARK verification level is
covered by the _channel_ _verifier_, the _commitments_ (excluding the trace commitments), the
_FRI_ _protocol_, and the _core_ _STARK_ _verifier_ . The CPU verification level is covered by the
_trace_ _commitments_, the _(CPU)_ _public_ _input_, the _layout_ _constraints_, the _DEEP_ _composition_
_polynomial_, and part of the _Cairo_ _verifier_ (the files in `stark_verifier` ). Finally, the rest
of the _Cairo_ _verifier_ (the files in `cairo_verifier` ) corresponds to the Cairo verification
level.


Figure 2: Architecture of the source code


**Call** **graph.** In Figure 3, we represent the call graph of the main routines in the source
code.

#### 2.3 Input format


We detail hereafter the format of


  - the _public_ _input_ which stores the different parameters of the Cairo statement to be
verified,


Page 14/59


Code review of the Cairo implementation of the STARK/Cairo verifier


  - the _proof_ which is the input of the verifier. _NB:_ _In_ _the_ _audited_ _code,_ _the_ _public_ _input_
_is_ _part_ _of_ _the_ _proof._


2.3.1 Public input


The format of the public input is defined by the structure `PublicInput` in the source file
`stark_verifier/air/public_input.cairo` . The fields of this structure are described in
Table 1.



**<u>Field</u>** **<u>Description</u>**
<u>`log_n_steps`</u> <u>Log</u> <u>(in</u> <u>base</u> <u>2)</u> <u>of</u> <u>the</u> <u>number</u> <u>of</u> <u>states</u> _<u>N</u>_
<u>`rc_min`</u> <u>Min</u> <u>range-check</u> <u>value</u>
<u>`rc_max`</u> <u>Max</u> <u>range-check</u> <u>value</u>
<u>`layout`</u> <u>The</u> <u>layout</u> <u>identifier</u>
<u>`n_segments`</u> <u>Number</u> <u>of</u> <u>segments</u>
<u>`segments[0].begin_addr`</u> <u>First</u> <u>address</u> <u>of</u> <u>the</u> <u>segment</u> <u>0</u>
<u>`segments[0].stop_ptr`</u> <u>Final</u> <u>position</u> <u>of</u> <u>the</u> <u>segment-0</u> <u>pointer</u>
<u>`segments[1].begin_addr`</u> <u>First</u> <u>address</u> <u>of</u> <u>the</u> <u>segment</u> <u>1</u>
<u>`segments[1].stop_ptr`</u> <u>Final</u> <u>position</u> <u>of</u> <u>the</u> <u>segment-1</u> <u>pointer</u>
_<u>. . .</u>_ _<u>. . .</u>_
<u>`padding_addr`</u> _<u>a</u>_ <u>pad</u>
<u>`padding_value`</u> <u>m(</u> _<u>a</u>_ <u>pad)</u>
<u>`main_page_len`</u> <u>Size</u> <u>of</u> <u>the</u> <u>main</u> <u>page</u>
<u>`main_page`</u> <u>Main</u> <u>page</u>
<u>`0`</u> <u>m</u> <sup>_<u>∗</u>_</sup> <u>(</u> <u>`pc`</u> _<u>I</u>_ <u>) =</u> <u>`0x40780017fff7fff`</u>
<u>`1`</u> <u>m</u> <sup>_<u>∗</u>_</sup> <u>(</u> <u>`pc`</u> _<u>I</u>_ <u>+ 1) = Number</u> <u>of</u> <u>program</u> <u>builtins</u>
<u>`2`</u> <u>m</u> <sup>_<u>∗</u>_</sup> <u>(</u> <u>`pc`</u> _<u>I</u>_ <u>+ 2) =</u> <u>`0x1104800180018000`</u>
<u>`3`</u> <u>m</u> <sup>_<u>∗</u>_</sup> <u>(</u> <u>`pc`</u> _<u>I</u>_ <u>+ 3) = Absolute</u> <u>position</u> <u>of</u> <u>`main`</u>
<u>`4`</u> <u>m</u> <sup>_<u>∗</u>_</sup> <u>(</u> <u>`pc`</u> _<u>I</u>_ <u>+ 4) =</u> <u>`0x10780017fff7fff`</u>
<u>`5`</u> <u>m</u> <sup>_<u>∗</u>_</sup> <u>(</u> <u>`pc`</u> _<u>I</u>_ <u>+ 5) =</u> <u>`0x0`</u>
<u>`6`</u> _<u>→</u>_ <u>∆</u> _<u>−</u>_ <u>2</u> <u>m</u> <sup>_<u>∗</u>_</sup> <u>(</u> <u>`pc`</u> _<u>I</u>_ <u>+ 6)</u> _<u>. . .</u>_ <u>m</u> <sup>_<u>∗</u>_</sup> <u>(</u> <u>`fp`</u> _<u>I</u>_ _<u>−</u>_ <u>3) = Program</u> <u>Bytecode</u>
<u>∆</u> _<u>−</u>_ <u>1</u> <u>m</u> <sup>_<u>∗</u>_</sup> <u>(</u> <u>`fp`</u> _<u>I</u>_ _<u>−</u>_ <u>2) =</u> <u>`fp`</u> _<u>I</u>_
<u>∆</u> <u>m</u> <sup>_<u>∗</u>_</sup> <u>(</u> <u>`fp`</u> _<u>I</u>_ _<u>−</u>_ <u>1) = 0</u>
<u>∆+ 1</u> _<u>→</u>_ <u>∆+</u> _<u>n</u>_ <u>m</u> <sup>_∗_</sup> <u>(</u> <u>`ap`</u> _<u>I</u>_ <u>)</u> _<u>. . .</u>_ <u>m</u> <sup>_∗_</sup> <u>(</u> <u>`ap`</u> _<u>I</u>_ <u>+</u> _<u>n −</u>_ <u>1) =</u> <u>`ptr`</u> <sup><u>[1]</u></sup> _<u>I</u>_ <sup>_<u>. . .</u>_</sup> <sup><u>`ptr`</u></sup> _<u>I</u>_ <sup><u>[</u></sup> <sup>_<u>n</u>_</sup> <sup><u>]</u></sup>




<sup><u>[1]</u></sup> _<u>I</u>_ <sup>_<u>. . .</u>_</sup> <sup><u>`ptr`</u></sup> _<u>I</u>_ <sup><u>[</u></sup> <sup>_<u>n</u>_</sup> <sup><u>]</u></sup>



_<u>I</u>_
<u>∆+</u> _<u>n</u>_ <u>+ 1</u> _<u>→</u>_ <u>∆+ 2</u> _<u>n</u>_ <u>m</u> <sup>_∗_</sup> <u>(</u> <u>`ap`</u> _<u>F</u>_ _<u>−</u>_ _<u>n</u>_ <u>)</u> _<u>. . .</u>_ <u>m</u> <sup>_∗_</sup> <u>(</u> <u>`ap`</u> _<u>F</u>_ _<u>−</u>_ <u>1) =</u> <u>`ptr`</u> <sup><u>[1]</u></sup> _<u>F</u>_ <sup>_<u>. . .</u>_</sup> <sup><u>`ptr`</u></sup>



_<u>F</u>_
<u>∆+ 2</u> _<u>n</u>_ <u>+ 1</u> _<u>→</u>_ <u>∆+ 2</u> _<u>n</u>_ <u>+</u> _<u>n</u>_ <sup>_′_</sup> <u>m</u> <sup>_∗_</sup> <u>(</u> <u>`ptr`</u> _<u>I</u>_ <sup><u>[output]</u></sup> <u>)</u> _<u>. . .</u>_ <u>m</u> <sup>_∗_</sup> <u>(</u> <u>`ptr`</u> _<u>F</u>_ <sup><u>[output]</u></sup> _<u>−</u>_ <u>1) = Outputs</u>



_<u>I</u>_ <sup><u>[output]</u></sup> <u>)</u> _<u>. . .</u>_ <u>m</u> <sup>_∗_</sup> <u>(</u> <u>`ptr`</u> _<u>F</u>_ <sup><u>[output]</u></sup>




<sup><u>[1]</u></sup> _<u>F</u>_ <sup>_<u>. . .</u>_</sup> <sup><u>`ptr`</u></sup> _<u>F</u>_ <sup><u>[</u></sup> <sup>_<u>n</u>_</sup> <sup><u>]</u></sup>



<u>∆+ 2</u> _<u>n</u>_ <u>+ 1</u> _<u>→</u>_ <u>∆+ 2</u> _<u>n</u>_ <u>+</u> _<u>n</u>_ <sup>_′_</sup> <u>m</u> <sup>_∗_</sup> <u>(</u> <u>`ptr`</u> _<u>I</u>_ <sup><u>[output]</u></sup> <u>)</u> _<u>. . .</u>_ <u>m</u> <sup>_∗_</sup> <u>(</u> <u>`ptr`</u> _<u>F</u>_ <sup><u>[output]</u></sup> _<u>−</u>_ <u>1) = Outputs</u>

<u>`n_continuous_pages`</u> <u>Must</u> <u>be</u> _<u>zero</u>_
<u>`continuous_page_headers`</u> _<u>Not</u>_ _<u>used</u>_



Table 1: Format of the public input. For each builtin _i_, `ptr` <sup>[</sup> _I_ <sup>_i_</sup> <sup>]</sup>




<sup>[</sup> _I_ <sup>_i_</sup> <sup>]</sup> <sup>and</sup> <sup>`ptr`</sup> <sup>[</sup> _F_ <sup>_i_</sup> <sup>]</sup>



Table 1: Format of the public input. For each builtin _i_, `ptr` <sup>[</sup> _I_ <sup>_i_</sup> <sup>]</sup> <sup>and</sup> <sup>`ptr`</sup> <sup>[</sup> _F_ <sup>_i_</sup> <sup>]</sup> <sup>are the initial and</sup>

final values of the corresponding builtin pointer. We define ∆:= `fp` _I_ _−_ `pc` _I_ _−_ 1.



Let us remark that the order of the segments in the public input is defined by the names

Page 15/59


Code review of the Cairo implementation of the STARK/Cairo verifier


pace `segments` in the file `stark_verifier/air/layouts/xxx/public_verify.cairo` for
`xxx` being the corresponding CPU layout. Table 1 exhaustively lists the memory mapping
for the main page as it should appear (in the same order) in the public input. Moreover,
the number of continuous pages should be set to 0 (see Remark 1 below).


2.3.2 Proof format


The format of the proof is defined by the structure `StarkProof` in the source file `stark.cairo` :

```
struct StarkProof {
   config: StarkConfig *,
   public_input : PublicInput*,
   unsent_commitment : StarkUnsentCommitment *,
   witness: StarkWitness *,
}

```

It is made of four components:


  - the STARK configuration (member `config` of `StarkProof` ): structure containing
some parameters for the commitments, the FRI protocol, and the proof of work;


  - the public input (member `public_input` of `StarkProof` ): as described above;


  - the commitments sent by the IOP prover (member `unsent_commitment` of `StarkProof` ):
the trace commitments (before and after interaction), the composition polynomial
trace commitment, the OODS values, the FRI commitments (including the coefficients of the last layer polynomial) and the nonce of the proof of work;


  - the witness sent by the IOP prover in the decommitment phase (member `witness` of
`StarkProof` ): the decommitted values and their authentication paths of the Merkle
trees to check decommitment.


Besides configuration data and the public input described above, Table 2 gives an overview
of the different elements of the `unsent_commitment` and `witness` members of the `StarkProof`
structure. These elements can be thought of as the prover-to-verifier transcript of the IOP
protocol.


**Montgomery** **representation.** All the decommitted field elements in the proof are
in _standard_ _form_ while their Merkle commitments are computed from their _Montgomery_
_form_ ( _i.e._ scaled by a factor _R_ := 2 <sup>256</sup> mod _p_ ). <sup>1</sup> Moreover, all the field elements sampled
and hashed by the IOP verifier (in the Fiat-Shamir heuristic) are considered to be in the
Montgomery form and are then converted to the standard form by the verifier. <sup>2</sup> This choice
is presumably made because the prover performs all its computation in the Montgomery
form (for the sake of efficiency).


1See the function `to_montgomery` of the file `table_commitment.cairo` which translates the proof values from standard to Montgomery form before decommitting them ( _i.e._ before verifying their Merkle
authentication paths).

2See `random_felts_to_prover`, `read_felt_from_prover`, `read_felt_vector_from_prover_inner` of
the file `channel.cairo` .


Page 16/59


Code review of the Cairo implementation of the STARK/Cairo verifier


**<u>Field</u>** **<u>Description</u>**

_<u>Elements</u>_ _<u>composing</u>_ _<u>the</u>_ _<u>`unsent_commitment`</u>_ _<u>member</u>_
“Original” Trace Commitment Merkle root where leaves are evaluations in the LDE of the trace column
<u>polynomials</u> <u>before</u> <u>interaction.</u>
“Interaction” Trace Commitment Merkle root where leaves are evaluations in the LDE of other trace
<u>column</u> <u>polynomials</u> <u>after</u> <u>interaction.</u>
OODS Commitment Merkle roots where leaves are evaluations in the LDE of the composition
<u>polynomial</u> <u>columns.</u>
<u>OODS</u> <u>Values</u> <u>The</u> _<u>M</u>_ <u>1 +</u> _<u>M</u>_ <u>2</u> <u>values</u> _<u>{yℓ}ℓ</u>_ _<u>∪{y</u>_ <u>ˆ</u> _<u>i}i</u>_ <u>.</u>
FRI Commitments Merkle roots where leaves are evaluations of the layer polynomials (ex<u>cept</u> <u>the</u> <u>last</u> <u>one).</u>
Last Layer Polynomial All the coefficients of the _scaled_ last layer polynomial _p_ <sup>_<u>′</u>_</sup> _K−_ 1 <sup>,</sup> <sup>starting</sup>

<u>from</u> <u>the</u> <u>coefficient</u> <u>of</u> <u>the</u> <u>constant</u> <u>monomial.</u>
<u>Nonce</u> <u>of</u> <u>Proof</u> <u>of</u> <u>Work</u> <u>The</u> <u>nonce</u> <u>used</u> <u>to</u> <u>prove</u> <u>the</u> <u>work</u> <u>(a.k.a.</u> <u>grinding).</u>

_<u>Elements</u>_ _<u>composing</u>_ _<u>the</u>_ _<u>`witness`</u>_ _<u>member</u>_
<u>“Original”</u> <u>Trace</u> <u>Query</u> <u>Responses</u> <u>The</u> <u>queried</u> <u>rows</u> <u>of</u> <u>the</u> <u>trace</u> <u>columns</u> <u>before</u> <u>interaction.</u>
“Original” Trace Query Witness Authentication paths in the Merkle tree of the Trace Commitment to
<u>decommit</u> <u>the</u> <u>original</u> <u>trace</u> <u>query</u> <u>responses.</u>
<u>“Interaction”</u> <u>Trace</u> <u>Query</u> <u>Responses</u> <u>The</u> <u>queried</u> <u>rows</u> <u>of</u> <u>the</u> <u>trace</u> <u>columns</u> <u>after</u> <u>interaction.</u>
“Interaction” Trace Query Witness Authentication paths in the Merkle tree of the “Interaction” Trace Com<u>mitment</u> <u>to</u> <u>decommit</u> <u>the</u> <u>interaction</u> <u>trace</u> <u>query</u> <u>responses.</u>
<u>Composition</u> <u>Query</u> <u>Responses</u> <u>The</u> <u>queried</u> <u>rows</u> <u>of</u> <u>the</u> <u>composition</u> <u>polynomial</u> <u>columns.</u>
Composition Query Witness Authentication paths in the Merkle tree of the OODS Commitment to
<u>decommit</u> <u>the</u> <u>composition</u> <u>query</u> <u>responses.</u>


_Repeat_ _the_ _two_ _last_ _rows_ _for_ _each_ _FRI_ _layer_ _(but_ _the_ _last_ _one),_ _i.e._ _for_ _layer_ _i ∈{_ 1 _, . . ., K −_ 1 _}._


Required Evaluation Values for the The missing required evaluations of _pi−_ 1 to compute the evaluations of
<u>layer</u> _<u>i</u>_ _<u>pi</u>_ <u>on</u> <u>the</u> <u>queries</u> _<u>Qi</u>_ <u>.</u>

Witness for Opened Evaluations Authentication paths in the Merkle tree with the _i_ th FRI Commitment
<u>as</u> <u>root</u> <u>to</u> <u>validate</u> <u>the</u> <u>Evaluation</u> <u>Values</u> <u>of</u> <u>the</u> <u>current</u> <u>layer.</u>


Table 2: Prover-to-verifier elements of the STARK proof (besides configuration and public
input).


**Hash functions.** The audited Cairo implementation of the STARK/Cairo verifier makes
use of two hash functions: Blake2s and the Pedersen hash function. The former is implemented by an external Cairo library while the latter is a Cairo builtin. The Pedersen hash
function is used to hash the main page of the public input, as well as for the hash of the
program bytecode and the hash of the program output (which are both output by the
Cairo verifier in case of a verification success). All the other hashes are based on Blake2s.
The Merkle commitments use a truncated version of Blake2s, only keeping the 160 most
significant bits of the hash digest, while the other hash calls (verifier channel, public input
hash, proof of work) use the standard version of Blake2s.

#### 2.4 Differences with the Solidity implementation


The audited Cairo implementation of the verifier has a few noticeable differences with the
audited Solidity implementation of the verifier [1, 2]:


1. the form of the field elements in the proof: the Cairo implementation assumes ele

Page 17/59


Code review of the Cairo implementation of the STARK/Cairo verifier


ments in standard form while the Solidity implementation assumes element in Montgomery form,


2. hash functions: the ~~Cai~~ ro implementation uses Blake2s (plus Pedersen) while the
Solidity implementation uses Keccak,


3. continuous pages: the Cairo implementation fixes the number of continuous pages of
the public memory to 0 while the Solidity implementation uses continuous pages for
the SHARP verifier (see Remark 1).


These differences (in particular the second one) make the two versions of the verifier incompatible: a proof is necessarily specific to the verifier implementation.

#### 2.5 External dependencies


The audited source code relies on several external Cairo libraries. The implementation of
those libraries is out of the scope of the audit. We thus assume their correctness when
reviewing the source code of the Cairo verifier. We list below all the used external functions
and libraries:


  - The functions of `common.math` are used in several places in the source code. They
implement arithmetic operations and some assertion utilities.


  - The function `pow` from `common.pow` is used in several places of the source code. It
computes an exponentiation on F _p_ .


  - The hash function Blake2s (routines of `common.cairo_blake2s.blake2s` ) is used in
several places of the source code. It is involved in the verifier channel and the Merkle
decommitments.


  - The function `alloc` from `common.alloc` is used in several places of the source code.
It returns a pointer to a free memory segment and deals with allocating the right
size for the segment.


  - The functions processing 256-bit unsigned integers (represented by a structure `Uint256`
of two field values) are used in several places. These routines are defined in the file
`common.uint256` .


  - The function `usort` from `common.usort` is used in `queries.cairo` . It sorts an array
of field elements and removes duplicates.


  - The function `memcpy` from `common.memcpy` is used in `oods.cairo` . It copies one
memory segment into another.


  - The function `get_label_location` from `common.registers` is used in `verify.cairo`,
in `public_verify.cairo`, in `cairo_verifier.cairo` and in `fri_layer.cairo` . It
returns the memory address corresponding to a label.


Page 18/59


Code review of the Cairo implementation of the STARK/Cairo verifier


- The data structure `HashBuiltin` from `common.hash` is used in `stark.cairo`, in
`public_input.cairo`, in `cairo_verifier.cairo` and in `air_interface.cairo` .


- The data structure `Bi` ~~`twi`~~ `seBuiltin` from `common.cairo_builtins` is used in several
places.


- The function `bitwise_and` from `common.bitwise` is used in `utils.cairo` . It computes the bitwise AND between two field values (251-bit values).


- The interface for the Pedersen hash function from the file `common.hash_state` is
used in `public_input.cairo` and in `cairo_verifier.cairo` .


- The function `get_fp_and_pc` from `common.registers` is used in `composition.cairo` .


- The data structure `StarkCurve` from `common.ec` is used in `composition.cairo` .


Page 19/59


Code review of the Cairo implementation of the STARK/Cairo verifier


Figure 3: Call graph (main routines)


Page 20/59


Code review of the Cairo implementation of the STARK/Cairo verifier

### 3 Review of the Cairo verifier


In what follows, we present <u>our</u> review of the source code. We organize this section by
grouping the files by functionality as discussed in Section 2.2.3. For each functionality, we
first provide some background documentation and then summarize our observations for
each file.

#### 3.1 Verifier channel


As illustrated in Figure 1, the IOP verifier receives parts of the proof from the prover and
sends some public-coin challenges several times. In the current on-interactive setting, these
public-coin challenges are obtained through pseudo-random generation from a seed using
the _verifier_ _channel_ . The latter is represented by a state ( _h, c_ ) where _h_ is a hash digest
and _c_ is a counter. Whenever the verifier receives a value _v_ ( _i.e._ reads a value _v_ from the
proof), the channel ( _h, c_ ) is updated as


         - _h ←_ Hash( _h_ + 1 _, v_ )

_c ←_ 0


Whenever the verifier needs to sample a value _r_, it set _r_ := Hash( _h, c_ ) and then increases
the counter _c_ . Figure 4 represents this process.


Figure 4: Mechanism of the verifier channel


The types of data that the verifier channel can read from the proof and the types of
data that the verifier channel can sample are the following:


**<u>Reading</u>** **<u>Sampling</u>**
unsigned 64-bit integer unsigned 256-bit integer ( `Uint256` )
Field element ( `felt` ) Field elements
Field elements Queries
Vector of field elements
<u>Truncated</u> <u>Hash</u> <u>(160</u> <u>bits)</u>


Note that all the above types are derived from the field element type ( `felt` ) since all the
intermediate values of a Cairo program are encoded as (bunches of) field elements.


Page 21/59


Code review of the Cairo implementation of the STARK/Cairo verifier


The verifier channel is implemented in the file `channel.cairo`, except for the sampling
of the queries which is implemented in `queries.cairo` .


3.1.1 File `channel.cairo`


**Sent** **_vs._** **unsent** **elements.** Each field element read from the proof is under one of
these two forms:


  - _unsent_ whenever the field element has not been read by the verifier channel  - such
an element is cast as a `ChannelUnsentFelt` instance;


  - _sent_ whenever the field element has been read by the verifier channel and can then
be used by the verifier   - such an element is cast as a `ChannelSentFelt` instance.


At the beginning of the verification process, when the proof is parsed, all the values from
the proof are considered as _unsent_ . Namely, they are arranged in structures whose base elements are `ChannelUnsentFelt` instances (the `Unsent` is further used for these structures).
When the verifier reads some of these values, it involves one of the reading functions from
`channel.cairo` . Those functions update the verifier channel and mark the read value as
_sent_ ( _e.g._ it returns an `ChannelSentFelt` instance). This principle does not affect the
functionality of the verifier and is presumably used for the sake of code security (by avoiding the risk of using a value from the proof which does not feed the verifier channel, hence
breaking the Fiat-Shamir heuristic).


**Initialization.** Given an input digest, the function `channel_new` returns a new channel
with this digest and counter set to zero.


**Sampling.** The sampling of an unsigned 256-bit integer by the verifier relies on the function `random_uint256_to_prover` . The latter hashes the channel state _h_ and the counter
_c_ and returns the 256-bit hash digest after updating the counter of the channel. The implementation assumes that the counter stays below 2 <sup>128</sup> (which means that less than 2 <sup>128</sup>

elements have been sampled).

To sample field elements, the function `random_felts_to_prover` calls the above function (at least one call per field element) and performs some rejection sampling. Specifically,
it rejects whenever the sampled 256-bit value is greater than 31 _· p_ and keeps the value
modulo _p_ otherwise (the modulo is direct while going from an `Uint256` to a `felt` ). As
explained in Section 2.3, the resulting field element is considered to be in the _Montgomery_
_form_ . Thus, to return a value in _standard_ _form_, the function further divides the sampled
elements by the Montgomery factor.


**Proof** **reading.** The file provides several functions to read a value through the channel
depending on its type. In contrast with the Solidity implementation of the verifier, the
proof reading functions take as input the read value. These functions take _unsent_ data as
input, update the verifier channel (see Figure 4) and return the same data marked as _sent_
( _i.e._ as `ChannelSentFelt` instances). In those reading functions, when _h_ + 1 is computed,


Page 22/59


Code review of the Cairo implementation of the STARK/Cairo verifier


only the low order part of _h_ is incremented and an assertion is used to avoid missing the
carry ( _i.e._ the implementation requires that _h_ always satisfies _h̸ ≡−_ 1 mod 2 <sup>128</sup> ).

Three different reading functions with the same structure are defined depending on the
type of input element:


  - `read_truncated_hash_from_prover` for a 160-bit (truncated) hash value;


  - `read_felt_from_prover` for a field element;


NB: the field element is read in standard form but put in Montgomery form before

being hashed to update de channel;


  - `read_uint64_from_prover` for 64-bit integer;


NB: the function further checks that the input value is in [0 _,_ 2 <sup>64</sup> ).


Additionally, two functions are defined to read several field elements:


  - `read_felts_from_prover` (with `read_felts_from_prover_inner` ) calls successively
`read_felt_from_prover` for each read elements,


  - `read_felt_vector_from_prover` (with `read_felt_vector_from_prover_inner` ) updates the channel by hashing all the field elements at once.


 - **Observation** **1:** **Inconsistent** **hash** **input** **sizes**


In `read_uint64_from_prover`, the number of hashed bytes ( `0x28` ) matches with the
size of the hashed content ( _i.e._ 32-byte digest plus 8-byte integer). This is not the
case for `read_truncated_hash_from_prover` which uses `64` as input hash size while
the hashed content makes 52 bytes (32-byte digest plus 20-byte truncated digest).


**Recommendation:** We recommend homogenizing the implementation, for instance
by setting the number of hashed bytes as `0x34` in the second case. This modification
also impacts the prover implementation.


 - **Observation** **2:** **Implicit** **assumption**


At line 102, the assertion

```
               assert_nn(high);

```

aims to check that `high` belongs in the range _{_ 0 _, . . .,_ 2 <sup>128</sup> _−_ 1 _}_ . However, it implicitly
assumes that the upper bound of the range-check builtin is 2 <sup>128</sup> (which is not strictly
necessary for other calls to `assert_nn` ). Even if this upper bound is currently defined
to 2 <sup>128</sup> (since the constant `RC_N_PARTS` is defined to `8` ), the soundness of using the
above assertion only holds of it does not change. This looks risky and could provoke
feature soundness breaches.


**Recommendation:** We recommend changing the way this check is performed in


Page 23/59


Code review of the Cairo implementation of the STARK/Cairo verifier


order to rely on a weaker assumption. For example, one could use


`assert_le(high,` 2 <sup>128</sup> _−_ 1 `);`


which will work as long as the upper bound of the range-check is _at_ _least_ 2 <sup>128</sup> . Let
us remark that this check only ensures that `high` _<_ 2 <sup>128</sup>, but the non-negativity is
already ensured by `unsigned_div_rem` .


3.1.2 File `queries.cairo`


Using the same notations as in our audit report on the Solidity implementation of the
STARK verifier [1], a FRI query is sampled under the form of a random index index0( _v_ )
to which corresponds the field element


_v_ := _c_ lde _· g_ LDE <sup>_e_</sup> <sup>_∈_</sup> <sup>_L_</sup> <sup>0</sup>


where the exponent _e_ is defined such that


index0( _v_ ) := bit-reverselog _|L_ 0 _|_ ( _e_ ) _._


All these notions are further recalled in Section 3.3 (FRI protocol) below.


**Query** **sampling.** The function `generate_queries` first calls the auxiliary function
`random_uint256_to_prover` to generate random samples (given a size and an upper bound)
which are then sorted (with the removal of duplicates) through a call to `usort` . The queries
are sampled in quadruplets by `sample_random_queries` . For each quadruplet, 256 bits are
sampled using `random_uint256_to_prover`, which are then split into four 64-bit chunks.
Each query is defined as the remainder of a chunk modulo the upper bound.


 - **Observation** **3:** **Missing** **sanity** **check**


The function `sample_random_queries` would produce biased samples if it was called
with an upper bound argument ( `query_upper_bound` ) which is not a power of two.

**Recommendation:** Although the above case should not occur for the FRI protocol,
we still recommend adding a sanity check to verify that the given upper bound is a
power of two.


**Query** **to** **points.** The function `queries_to_points` take as input a list of _query indexes_
and returns the list of corresponding field elements by computing


_v_ := _c_ lde _· g_ LDE <sup>_e_</sup>


which corresponds to index0( _v_ ). The value _c_ lde is defined as the field generator which is
given by the constant `FIELD_GENERATOR` (defined to `3` in `utils.cairo` ).


Page 24/59


Code review of the Cairo implementation of the STARK/Cairo verifier


3.1.3 File `utils.cairo`


**Field generator.** The file defines the constant `FIELD_GENERATOR` to the value `3`, which is
a generator of the multiplica ~~tiv~~ e group F <sup>_×_</sup> _p_ <sup>.</sup> <sup>This constant is used to derive the generators of</sup>

the trace evaluation domain and the evaluation domain of the trace LDE (see Section 2.1)
and to define the _c_ lde value used in the FRI protocol (see Section 3.3).


**Bit** **reversing.** Let us assume that we want to swap the _n_ -bit chunks in an unsigned
integer _a_ . Namely given



( _a_ 2 _k ·_ (2 <sup>_n_</sup> ) <sup>2</sup> <sup>_k_</sup> + _a_ 2 _k_ +1 _·_ (2 <sup>_n_</sup> ) <sup>2</sup> <sup>_k_</sup> <sup>+1</sup> )



_a_ :=






_k≥_ 0



where 0 _≤_ _ai_ _<_ 2 <sup>_n_</sup> for all _i_, we want to compute






_k≥_ 0



( _a_ 2 _k_ +1 _·_ (2 <sup>_n_</sup> ) <sup>2</sup> <sup>_k_</sup> + _a_ 2 _k ·_ (2 <sup>_n_</sup> ) <sup>2</sup> <sup>_k_</sup> <sup>+1</sup> ) _._



To proceed, let us define `mask` := <sup>�</sup> _k≥_ 0 <sup>(</sup> <sup>`set-bits`</sup> <sup>_·_</sup> <sup>(2</sup> <sup>_n_</sup> <sup>)2</sup> <sup>_k_</sup> <sup>)</sup> <sup>with</sup> <sup>`set-bits`</sup> <sup>:=</sup> <sup>2</sup> <sup>_n −_</sup> <sup>1,</sup> <sup>we</sup>

get that


`masked` := _a_ &bitwise `mask`



=


_a −_ `masked` =






_k≥_ 0




_k≥_ 0



( _a_ 2 _k ·_ (2 <sup>_n_</sup> ) <sup>2</sup> <sup>_k_</sup> )


( _a_ 2 _k_ +1 _·_ (2 <sup>_n_</sup> ) <sup>2</sup> <sup>_k_</sup> <sup>+1</sup> )



When computing 2 <sup>2</sup> <sup>_n_</sup> _·_ `masked` + ( _a −_ `masked` ), we get






_k_ =0



( _a_ 2 _k ·_ (2 <sup>_n_</sup> ) <sup>2</sup> <sup>_k_</sup> <sup>+2</sup> + _a_ 2 _k_ +1 _·_ (2 <sup>_n_</sup> ) <sup>2</sup> <sup>_k_</sup> <sup>+1</sup> )



which corresponds to the desired value scaled by a factor 2 <sup>_n_</sup> .

The function `bit_reverse_u64` uses the above swap process to reverse the bits of a
64-bit value: it swaps the 1-bit chunks, then the 2-bit chunks, then 4-bit chunks, etc. In
the end, the result is divided by 2 <sup>63</sup> to remove the factor introduced by the process.

#### 3.2 Commitments


All the commitments in the STARK protocol are realized thanks to Merkle trees, a.k.a.
hash trees. In such a binary tree every node is labeled with the hash digest of the two child
nodes’ labels. This structure enables to commit several inputs as leaves of the tree into a
single hash commitment (the root of the tree). Then, it is possible to show the consistency
of a revealed subset of inputs with the root without having to communicate all the other
inputs. The principle is to reveal the sibling paths of the revealed inputs in the Merkle
tree.


Page 25/59


Code review of the Cairo implementation of the STARK/Cairo verifier


We start by giving an overview of the format of the different commitments involved
in the STARK protocol. We stress that the source files `vector_commitment.cairo` and
`table_commitment.cairo` (reviewed hereafter) are independent of these particular formats
and could be used for other types of Merkle commitments.


**Trace** **commitments.** In the STARK protocol, Merkle trees are used to commit two
types of traces: the _execution_ _trace_ _f_ 0 _, . . ., fW_ _−_ 1 and the _composition_ _polynomial_ _trace_
_h_ 0 _, . . ., hM_ 2 _−_ 1 which are both defined on the _low_ _degree_ _extension_ _L_ 0 of size _β_ _· L_ (see
Section 2.1).

The leaves of the corresponding Merkle trees have the following formats.


  - For the execution trace:


input _j_ = _f_ 0( _x_ ) _∥_ _f_ 1( _x_ ) _∥_ _. . . ∥_ _fW_ _−_ 1( _x_ ) where _x ∈_ _L_ 0 _,_ index0( _x_ ) = _j_


  - For the composition polynomial trace:


input _j_ = _h_ 0( _x_ ) _∥_ _h_ 1( _x_ ) _∥_ _. . . ∥_ _hM_ 2 _−_ 1( _x_ ) where _x ∈_ _L_ 0 _,_ index0( _x_ ) = _j_


**Remark** **2.** _Whenever_ _the_ _AIR_ _to_ _be_ _verified_ _is_ _a_ _randomized_ _AIR_ _with_ _preprocessing_ _[3]_
_(which_ _is_ _always_ _the_ _case_ _for_ _a_ _Cairo_ _program),_ _the_ _execution_ _trace_ _is_ _committed_ _in_ _two_
_times,_ _using_ _two_ _Merkle_ _trees_ _instead_ _of_ _a_ _single_ _one._ _The_ _first_ _tree_ _contains_ _the_ _trace_
_columns_ _committed_ _before_ _the_ _interaction_ _step,_ _and_ _the_ _second_ _tree_ _contains_ _the_ _remaining_
_trace_ _columns._


**Layer** **polynomial** **commitments.** In the FRI protocol, a polynomial _pi_ is committed
at the layer _i_ + 1 (except for the last layer). We denote _Li_ the evaluation domain for
the commitment of _pi_ . To compute an evaluation of _pi_ +1 for a point of _Li_ +1, one needs
2 <sup>_ℓi_</sup> <sup>+1</sup> evaluations of _pi_ (see Section 3.3 for details). Thus these evaluations are committed
together. The commitment of _pi_ is realized thanks to a Merkle tree with 2 _<u>|</u>_ <sup>_ℓi_</sup> _<u>L</u>_ <sup>+1</sup> _<u>i|</u>_ <sup>leaves,</sup> <sup>and</sup>
the corresponding leaves are defined as follows:


input _j_ = 2 <sup>_si_</sup> _· pi_ ( _x_ 0) _∥_ 2 <sup>_si_</sup> _· pi_ ( _x_ 1) _∥_ _. . . ∥_ 2 <sup>_si_</sup> _· pi_ ( _x_ 2 _ℓi_ +1 _−_ 1)


where

_xk_ _∈_ _Li_ and index _i_ ( _xk_ ) = _j ·_ 2 <sup>_ℓi_</sup> <sup>+1</sup> + _k_ _._


**Merkle** **tree** **structure.** In the STARK verifier, only _complete_ Merkle trees are used,
_i.e._ Merkle trees with 2 <sup>_n_</sup> leaves for some _n ∈_ N. Moreover, only the verification primitive
is implemented: the STARK verifier does not need to commit but only to decommit data.
Each node is an instance of a `VectorQuery` structure, which is composed of two members:


  - `index` (field element): the index of the node. The nodes of depth _i_ have indexes 2 <sup>_i_</sup>,
..., 2 <sup>_i_</sup> <sup>+1</sup> _−_ 1. Thus the root has index “1” and the leave indexes are _{_ 2 <sup>_n_</sup> _, . . . .,_ 2 <sup>_n_</sup> <sup>+1</sup> _−_ 1 _}_ .
Moreover, given an internal node with index _i_, the child nodes have indexes 2 _i_ and
2 _i_ + 1.


Page 26/59


Code review of the Cairo implementation of the STARK/Cairo verifier


  - `value` (unsigned 256-bit integer): the label of the node in the Merkle tree. This is
the hash digest of the child nodes for an internal node. For a leaf node, this is either
the corresponding input value whenever it holds on 256 bits, or the hash digest of
the input value otherwise.


The hash function used for the Merkle tree is a truncated version of Blake2s for which we
keep only the 160 most significant bits of the digest.


3.2.1 File `vector_commitment.cairo`


The file deals with commitments and decommitments of vectors. A vector ( _x_ 1 _, . . ., x_ 2 <sup>_n_</sup> ) of
length 2 <sup>_n_</sup> is committed as a Merkle tree with _x_ 1, . . ., _x_ 2 <sup>_n_</sup> as leaf values. The coordinates
of committed vectors are unsigned 256-bit integers.


**Commitment.** For the IOP verifier, the vector commitment simply consists in receiving a 160-bit Merkle root from the prover. The `vector_commit` function thus only calls
`read_truncated_hash_from_prover` .


**Decommitment.** A vector decommitment consists in checking that some opened vector
coordinates are consistent with a Merkle root using the underlying authentication paths.
For this purpose, the `vector_commitment_decommit` function proceeds as follows:


  - by calling `shift_queries`, it computes the indexes index( _v_ ) of the opened Merkle
leaves. This is done by shifting the indexes index( _v_ ) of the opened vector coordinates:


index( _v_ ) := index( _v_ ) + 2 <sup>`height`</sup>


where `height` is the height of the Merkle tree.


  - by calling `verify_authentications`, it computes the expected Merkle root using
the opened vector coordinates and the authentication paths.


**–** To compute the expected Merkle root, the implementation uses a queue. At the

beginning of the verification, the queue only contains the decommitted leaves
(sorted according to their indexes). Along the verification, the queue is fed with
the encountered nodes on the Merkle paths to the decommitted leaves.


**–** A computation step consists to pop the Merkle node at the queue head, to

compute the index and the label of the parent node (using the following node
in the queue when it corresponds to the sibling node, using a value from the
authentication paths otherwise) and to push the parent node in the queue. In
case any inconsistency is encountered, the verification fails.


**–** At the end, the queue contains a single node which shall be the Merkle root.


  - it checks that the obtained root ( `expected_commitment` ) is well truncated to 160 bits
and further checks that it matches the committed value read from the proof.


Page 27/59


Code review of the Cairo implementation of the STARK/Cairo verifier


- **Observation** **4:** **Inconsistent** **naming**


The decommitment function for vectors is named `vector_commitment_decommit`, while
the decommitment functi ~~on~~ s for tables and traces are named `table_decommit` and
`traces_decommit` .

**Recommendation:** We recommend using consistent naming, for instance, change

```
            vector_commitment_decommit

```

into `vector_decommit` .


- **Observation** **5:** **Useless** **assertion**


The assertion

```
       assert_nn(expected_commitment.low / 2 ** 96);

```

seems to check that `expected_commitment` has only 160 bits (on the leading positions).
However, the value `expected_commitment` is a value returned by `truncated_blake2s`,
and thus always satisfies this assertion. The only exception is when the committed
vector has a single coordinate, which should not occur.


**Recommendation:** If the desired behavior is to avoid the case of a committed
vector with a single coordinate, then we recommend implementing a more explicit
assertion. Otherwise, we recommend removing the assertion.


- **Observation** **6:** **Confusing** **typing**


The structure `VectorQuery` is used for both the input values of a Merkle tree as
well as the internal nodes of a Merkle tree. For an input value, the member `index`
is the index of a field element, index _i_ ( _v_ ), and the member `value` is the hash digest
of polynomial evaluations in _v_ (and in further elements following _v_ for a FRI layer
polynomial commitment). For a Merkle node, the member `index` is the index of the
node in the tree, and the member `value` is the label (hash digest) of the node. The role
of the function `shift_queries` is to translate the former notion to the latter one since
there is a mismatch between the two notions of indexes. Using the same structure for
the two notions is confusing.


**Recommendation:** We recommend defining two different structures, one for Merkle
inputs (before index shifting) and one for Merkle nodes (after index shifting). We
would also recommend avoiding the terminology of “query” but prefer the terminologies
of “input” or “leaf” and “node”.


Page 28/59


Code review of the Cairo implementation of the STARK/Cairo verifier


3.2.2 File `table_commitment.cairo`


The purpose of this file is to extend vector commitments into _table_ _commitments_ . Instead
of (de)commitments of unsig ~~ne~~ d integers (the coordinates of the vector), this file deals with
(de)commitments of rows of field elements. All the values of a row are committed together,
meaning that the prover has to decommit entire rows. The idea is to hash each row into
a digest (except when the rows have a unique element) and to use the vector commitment
to commit the resulting vector of hash digests.


**Commitment.** For the IOP verifier, a table commitment is equivalent to a vector commitment. The function `table_commit` simply receives a 160-bit hash digest from the prover
by calling `vector_commit` .


**Decommitment.** The function `table_decommit` proceeds as follows:


  - it converts each input decommitted value to _Montgomery form_ by calling `to_montgomery`,


  - it computes the hash digest for each opened row by calling `generate_vector_queries`
(except if the rows have a single element),


  - it checks that the decommitment is valid by calling `vector_commitment_decommit` .


 - **Observation** **7:** **Code** **duplication**


In `generate_vector_queries`, the code blocks at lines 135-141 and lines 153-159 are
the same.


**Recommendation:** For the sake of code readability, we recommend using an `else`
statement and having a single `return` statement.


3.2.3 File `traces.cairo`


This file deals with the commitment and decommitment of the execution traces.


**Commitment.** The function `traces_commit` is used to read a trace commitment from
the channel. First, it calls `table_commit` to read from the proof the table commitment
of the “original” trace columns (namely the trace columns before interaction). Then it
calls `random_felts_to_prover` to generate the interaction elements. Afterwards, it calls
`table_commit` once again to read the table commitment of the “interaction” trace columns
(namely the trace columns after interaction). Finally, it returns the resulting table commitments (of the original and interaction columns) packed in a `TracesCommitment` structure
(together with the public input and the sampled interaction elements).


Page 29/59


Code review of the Cairo implementation of the STARK/Cairo verifier


**Decommitment.** The function `traces_decommit` is used to verify a decommitment for
the traces at some given query indices. It simply calls the `table_decommit` function on
the table commitment of the original columns and the table commitment of the interaction
columns (inputting the corresponding decommitments and witnesses).


 - **Observation** **8:** **File** **organization**


The only purpose of the file `stark_verifier/air/config.cairo` is to define the trace
configuration structure and the function to validate a trace configuration.


**Recommendation:** We recommend merging `stark_verifier/air/config.cairo`
into the file `stark_verifier/air/traces.cairo` .

#### 3.3 FRI protocol


We recall hereafter some basics about the FRI protocol and the underlying notions and
data structures. The FRI protocol has two distinct phases: a _commitment_ phase and a
_query_ (or _decommitment_ ) phase. We outline those two phases hereafter:


  - **Commitment** **phase** . For all the layers except the last one,


**–** At the _i_ th layer, the IOP prover starts with a polynomial _pi_ . It first commits this

polynomial in a table commitment (see the previous section). The evaluation
domain for the commitment of _pi_ is

_Li_ := _{x_ <sup>2</sup> <sup>_ℓi_</sup> _, x ∈_ _Li−_ 1 _}_


which by definition of _L_ 0 implies



_Li_ = _c_ <sup>2</sup> lde <sup>_si_</sup>




<sup>2</sup> lde <sup>_si_</sup> <sup>_· ⟨g_</sup> lde <sup>2</sup> <sup>_si_</sup>



lde <sup>2</sup> <sup>_si_</sup> <sup>_⟩_</sup>



_j_ <sup>_i_</sup> =1 <sup>_ℓj_</sup> <sup>.</sup> <sup>For</sup> <sup>each</sup> <sup>value</sup> <sup>_x_</sup> <sup>:=</sup> <sup>_c_</sup> lde <sup>2</sup> <sup>_si_</sup>



lde <sup>2</sup> <sup>_si_</sup> <sup>)</sup> <sup>_e_</sup> <sup>_∈_</sup> <sup>_Li_</sup> <sup>,</sup> <sup>we</sup> <sup>denote</sup>



with _si_ := <sup>�</sup> _j_ <sup>_i_</sup>



lde <sup>2</sup> <sup>_si_</sup> <sup>_·_</sup> <sup>(</sup> <sup>_g_</sup> lde <sup>2</sup> <sup>_si_</sup>



index _i_ ( _x_ ) := bit-reverselog _|Li|_ ( _e_ ) _._

The commitment of _pi_ is realized thanks to a Merkle tree with 2 _<u>|</u>_ <sup>_ℓi_</sup> _<u>L</u>_ <sup>+1</sup> _<u>i|</u>_ <sup>leaves,</sup> <sup>and</sup>
the corresponding leaves are defined as follows:

input _j_ = 2 <sup>_si_</sup> _· pi_ ( _xj,_ 0) _||_ 2 <sup>_si_</sup> _· pi_ ( _xj,_ 1) _|| . . . ||_ 2 <sup>_si_</sup> _· pi_ ( _xj,_ 2 _ℓi_ +1 _−_ 1)


where

_xj,k_ _∈_ _Li_ and index _i_ ( _xj,k_ ) = _j ·_ 2 <sup>_ℓi_</sup> <sup>+1</sup> + _k_ _._


**Remark** **3.** _One_ _can_ _observe_ _that_ _the_ _leaves’_ _polynomial_ _evaluations_ _are_ _scaled_
_by_ _a_ _factor_ 2 <sup>_si_</sup> _._ _This_ _factor_ _is_ _not_ _in_ _the_ _original_ _definition_ _of_ _the_ _FRI_ _protocol_
_but_ _is_ _introduced_ _for_ _the_ _sake_ _of_ _efficiency_ _of_ _the_ _verifier_ _implementation._ _In-_
_deed,_ _the_ _verifier_ _evaluates_ _so-called_ _folding_ _formulae_ _to_ _map_ _queries_ _from_ _one_
_layer_ _to_ _queries_ _of_ _the_ _next_ _layer._ _This_ _evaluation_ _introduces_ _the_ 2 <sup>_si_</sup> _factor._ _To_
_avoid_ _correcting_ _it_ _at_ _the_ _verifier_ _level,_ _this_ _factor_ _is_ _then_ _further_ _applied_ _to_ _the_
_committed_ _values._


Page 30/59


Code review of the Cairo implementation of the STARK/Cairo verifier


**–** Once the layer polynomial _pi_ committed, the IOP prover gets a random chal
lenge _ζi_ from the verifier and computes the new polynomial _pi_ +1 as




<sup>[</sup> _i_ <sup>_j_</sup> <sup>](</sup> <sup>_x_</sup> <sup>)</sup> (4)



_pi_ +1( _x_ ) :=



2 <sup>_ℓi_</sup> <sup>+1</sup> _−_ 1



_j_ =0



_ζi_ <sup>_j_</sup>



_i_ <sup>_j_</sup> <sup>_· p_</sup> <sup>[</sup> _i_ <sup>_j_</sup> <sup>]</sup>



where the _{p_ <sup>[</sup> _i_ <sup>_j_</sup> <sup>]</sup> <sup>_}j_</sup> <sup>are</sup> <sup>the</sup> <sup>polynomials</sup> <sup>defined</sup> <sup>such</sup> <sup>that</sup>



_pi_ ( _x_ ) =



2 <sup>_ℓi_</sup> <sup>+1</sup> _−_ 1



_j_ =0



_x_ <sup>_j_</sup> _· p_ <sup>[</sup> _i_ <sup>_j_</sup> <sup>](</sup> <sup>_x_</sup> <sup>2</sup> <sup>_ℓi_</sup> <sup>+1</sup> <sup>)</sup> <sup>_._</sup>



To compute an evaluation of _pi_ +1 for a point of _Li_ +1, one needs 2 <sup>_ℓi_</sup> <sup>+1</sup> evaluations
of _pi_, it is why these evaluations are committed together.


At the last layer, the IOP prover simply sends 2 <sup>_sK−_</sup> <sup>1</sup> _· pK−_ 1 to the verifier.


- **Query/decommitment** **phase** . Once all the layer polynomials _{pi}i_ have been
committed, the FRI protocol evaluates these polynomials on a set of evaluation
points, called _queries_ . The set of queries for the polynomial _pi_ is denoted _Qi_ _⊂_ _Li_,
and for every _i ≥_ 1, we have







_Qi_ :=




- _x_ <sup>2</sup> <sup>_ℓi_</sup> _, x ∈Qi−_ 1



where _Q_ 0 _⊆_ _L_ 0 is the set of random queries sampled by the IOP verifier at the
beginning of the query phase.


At the _i_ th layer, the Cairo implementation of the verifier




**–** takes a set _Qi_ of queries where each query _v_ = _c_ <sup>2</sup> lde <sup>_si_</sup>




<sup>2</sup> lde <sup>_si_</sup> <sup>_· g_</sup> _i_ <sup>_e_</sup>



takes a set _Qi_ of queries where each query _v_ = _c_ <sup>2</sup> lde <sup>_si_</sup> <sup>_· g_</sup> _i_ <sup>_e_</sup> <sup>_∈Qi_</sup> <sup>with</sup> <sup>scaled</sup> <sup>value</sup>

_v_ <sup>_′_</sup> = _gi_ <sup>_e_</sup> <sup>is</sup> <sup>represented</sup> <sup>as</sup> <sup>a</sup> <sup>triplet</sup>



_i_ <sup>_e_</sup> <sup>is</sup> <sup>represented</sup> <sup>as</sup> <sup>a</sup> <sup>triplet</sup>



(index _i_ ( _v_ ) _, pi_ ( _v_ ) _,_ 1 _/v_ <sup>_′_</sup> )


stored via the structure `FriLayerQuery`, where


index _i_ ( _v_ ) = bit-reverselog _|Li|_ ( _e_ ) _._


**–** builds the set _Qi_ +1 of queries represented with the same format (but for _i_ + 1),

**–** checks that all the evaluations of _pi_ used to build _Qi_ +1 are consistent with the

commitment.


**Scaled values.** As explained in our previous audit report [1], the verifier implementation
is based on _scaled_ versions of several FRI notions (yet another scaling different from the
2 <sup>_si_</sup> factor addressed above). For all 0 _≤_ _i ≤_ _K −_ 1,




<sup>_′_</sup> _i_ <sup>(</sup> <sup>_x_</sup> <sup>) :=</sup> <sup>_pi_</sup> <sup>(</sup> <sup>_c_</sup> <sup>2</sup> lde <sup>_si_</sup>




- the _scaled_ layer polynomial _p_ <sup>_′_</sup> _i_ <sup>(</sup> <sup>_x_</sup> <sup>)</sup> <sup>is</sup> <sup>defined</sup> <sup>as</sup> <sup>_p′_</sup> _i_




<sup>2</sup> lde <sup>_si_</sup> <sup>_· x_</sup> <sup>);</sup>



Page 31/59


Code review of the Cairo implementation of the STARK/Cairo verifier


- the scaled layers polynomials _p_ <sup>_′_</sup> _i−_ 1 <sup>and</sup> <sup>_p′_</sup> _i_ <sup>verify</sup> <sup>a</sup> <sup>similar</sup> <sup>relation</sup> <sup>as</sup> <sup>Equation</sup> <sup>(4)</sup>

but for the _scaled_ challenges defined as



_ζi_ <sup>_′_</sup> _−_ 1 <sup>:=</sup>




- _c_ lde <sup>2</sup> <sup>_si−_</sup> <sup>1</sup>




- _c_ lde <sup>2</sup> <sup>_si−_</sup> <sup>1</sup>




- _−_ 1

_· ζi−_ 1 ;




- the _scaled_ evaluation domain _L_ <sup>_′_</sup> _i_ <sup>and</sup> <sup>the</sup> <sup>_scaled_</sup> <sup>set</sup> <sup>_Q′_</sup> _i_



the _scaled_ evaluation domain _L_ <sup>_′_</sup> _i_ <sup>and</sup> <sup>the</sup> <sup>_scaled_</sup> <sup>set</sup> <sup>_Q′_</sup> _i_ <sup>of</sup> <sup>queries</sup> <sup>for</sup> <sup>the</sup> <sup>polynomial</sup>

_p_ <sup>_′_</sup> _i_ <sup>are</sup> <sup>defined</sup> <sup>as</sup>




<sup>_′_</sup> _i_ <sup>are</sup> <sup>defined</sup> <sup>as</sup>




- _−_ 1 _· v_ ; _v_ _∈Qi}_ _._




- _−_ 1 _· Li_ = _⟨g_ lde2 _si_ <sup>_⟩_</sup> and _Q_ <sup>_′_</sup> _i_ <sup>:=</sup> <sup>_{_</sup>




- _−_ 1 _· Li_ = _⟨g_ lde2 _si_ <sup>_⟩_</sup> and _Q_ <sup>_′_</sup> _i_




- _c_ <sup>2</sup> lde <sup>_si_</sup>




- _c_ <sup>2</sup> lde <sup>_si_</sup>



_L_ <sup>_′_</sup> _i_ <sup>:=</sup>




- _c_ <sup>2</sup> lde <sup>_si_</sup>



Instead of performing the standard FRI protocol on the DEEP composition polynomial _p_ 0,
the implementation runs the protocol on the _scaled DEEP composition polynomial_ _p_ <sup>_′_</sup> 0 <sup>.</sup> <sup>This</sup>



the implementation runs the protocol on the _scaled DEEP composition polynomial_ _p_ <sup>_′_</sup> 0 <sup>.</sup> <sup>This</sup>

choice enables to avoid all the offsets - _c_ <sup>2</sup> lde <sup>_si_</sup> 
_i_ <sup>of</sup> <sup>the</sup> <sup>evaluation</sup> <sup>domains</sup> <sup>_{Li}i_</sup> <sup>.</sup> <sup>Instead,</sup>




- _c_ <sup>2</sup> lde <sup>_si_</sup>







choice enables to avoid all the offsets - _c_ <sup>2</sup> lde <sup>_si_</sup> 
_i_ <sup>of</sup> <sup>the</sup> <sup>evaluation</sup> <sup>domains</sup> <sup>_{Li}i_</sup> <sup>.</sup> <sup>Instead,</sup>
the protocol is performed on the scaled evaluation domains _{L_ <sup>_′_</sup> _i_ <sup>_}_</sup> <sup>which</sup> <sup>are</sup> <sup>subgroups</sup> <sup>of</sup>



lde



the protocol is performed on the scaled evaluation domains _{L_ <sup>_′_</sup> _i_ <sup>_}_</sup> <sup>which</sup> <sup>are</sup> <sup>subgroups</sup> <sup>of</sup>

F <sup>_×_</sup> _p_ <sup>easier</sup> <sup>to</sup> <sup>deal</sup> <sup>with.</sup>

This change of representation does not impact the commitments, since _p_ <sup>_′_</sup> _i_ <sup>(</sup> <sup>_x′_</sup> <sup>)</sup> <sup>=</sup> <sup>_pi_</sup> <sup>(</sup> <sup>_x_</sup> <sup>)</sup>

whenever _x_ = _x_ <sup>_′_</sup> _· c_ <sup>2</sup> lde <sup>_si_</sup> <sup>(with</sup> <sup>_x_</sup> <sup>_∈_</sup> <sup>_Li_</sup> <sup>and</sup> <sup>_x′_</sup> <sup>_∈_</sup> <sup>_L_</sup> _i_ <sup>_′_</sup> <sup>).</sup> <sup>It</sup> <sup>only</sup> <sup>implies</sup> <sup>that</sup> <sup>the</sup> <sup>IOP</sup> <sup>verifier</sup>




<sup>_×_</sup> _p_ <sup>easier</sup> <sup>to</sup> <sup>deal</sup> <sup>with.</sup>



This change of representation does not impact the commitments, since _p_ <sup>_′_</sup> _i_




<sup>2</sup> lde <sup>_si_</sup> <sup>(with</sup> <sup>_x_</sup> <sup>_∈_</sup> <sup>_Li_</sup> <sup>and</sup> <sup>_x′_</sup> <sup>_∈_</sup> <sup>_L_</sup> _i_ <sup>_′_</sup>



whenever _x_ = _x_ <sup>_′_</sup> _· c_ <sup>2</sup> lde <sup>_si_</sup> <sup>(with</sup> <sup>_x_</sup> <sup>_∈_</sup> <sup>_Li_</sup> <sup>and</sup> <sup>_x′_</sup> <sup>_∈_</sup> <sup>_L_</sup> _i_ <sup>_′_</sup> <sup>).</sup> <sup>It</sup> <sup>only</sup> <sup>implies</sup> <sup>that</sup> <sup>the</sup> <sup>IOP</sup> <sup>verifier</sup>

samples scaled challenges _{ζi_ <sup>_′}i_</sup> <sup>instead</sup> <sup>of</sup> <sup>_{ζi}i_</sup> <sup>(but</sup> <sup>the</sup> <sup>two</sup> <sup>distributions</sup> <sup>are</sup> <sup>equivalent)</sup>



samples scaled challenges _{ζi_ <sup>_′}i_</sup> <sup>instead</sup> <sup>of</sup> <sup>_{ζi}i_</sup> <sup>(but</sup> <sup>the</sup> <sup>two</sup> <sup>distributions</sup> <sup>are</sup> <sup>equivalent)</sup>

and that the IOP prover sends the scaled version of the last layer polynomial _p_ <sup>_′_</sup> _K−_ 1 <sup>(instead</sup>



and that the IOP prover sends the scaled version of the last layer polynomial _p_ <sup>_′_</sup> _K−_ 1 <sup>(instead</sup>

of _pK−_ 1).



**The** **FRI** **group.** The FRI group is the subgroup of F <sup>_×_</sup> _p_ <sup>with</sup> <sup>24</sup> <sup>elements,</sup> <sup>sorted</sup> <sup>in</sup> <sup>a</sup>

specific order. Let _ξ_ be a generator of this group. Then the _i_ th element of the group,
denoted `friGroup[` _i_ `]`, is defined as


`friGroup[` _i_ `]` := _ξ_ <sup>_e_</sup> _⇐⇒_ _i_ = bit-reverse4( _e_ ) _._


We refer the reader to our previous audit report [1] for more details about the FRI group.


3.3.1 File `fri/fri_formula.cairo`


In what follows, we denote rev( _·_ ) for bit-reverse _|Li|_ ( _·_ ) to ease the notations.

This file implements the computation of 2 <sup>_si_</sup> <sup>+1</sup> _· pi_ +1( _v_ ) for some _v_ _∈Qi_ +1 using evaluations of 2 <sup>_si_</sup> _· pi_ where _pi_ and _pi_ +1 satisfy Equation (4). Let us denote


Combine _j_ ( _{e_ 0 _, . . ., e_ 2 _j_ _−_ 1 _}, ζ, v_ )


the function which returns 2 <sup>_si_</sup> <sup>+1</sup> _· pi_ +1( _v_ <sup>2</sup> <sup>_ℓi_</sup> <sup>+1</sup> ) whenever _ζ_ = _ζi−_ 1 and _e_ 0 _, . . ., e_ 2 _j_ _−_ 1 are the
evaluations


2 <sup>_si_</sup> _· pi_ ( _v · ξ_ <sup>rev(0)</sup> ) _,_ 2 <sup>_si_</sup> _· pi_ ( _v · ξ_ <sup>rev(1)</sup> ) _,_ _. . .,_ 2 <sup>_si_</sup> _· pi_ ( _v · ξ_ <sup>rev(2</sup> <sup>_j_</sup> <sup>_−_</sup> <sup>1)</sup> )


for _ξ_ a generator of the subgroup of F _p_ of size 2 <sup>_ℓi_</sup> <sup>+1</sup> . By [1, Appendix A], we know that



2 <sup>_ℓi_</sup> <sup>+1</sup> _−_ 1



_k_ =0



( _ξ_ <sup>_−_</sup> <sup>rev(</sup> <sup>_k_</sup> <sup>)</sup> ) <sup>_q_</sup> _· pi_ ( _v · ξ_ <sup>rev(</sup> <sup>_k_</sup> <sup>)</sup> ) _,_



_pi_ +1( _v_ <sup>2</sup> <sup>_ℓi_</sup> <sup>+1</sup> ) = <u>1</u>
2 <sup>_ℓi_</sup> <sup>+1</sup> <sup>_·_</sup>



2 <sup>_ℓi_</sup> <sup>+1</sup> _−_ 1



_q_ =0




- _<u>ζi</u>_
_v_




- _q_

_·_



Page 32/59


Code review of the Cairo implementation of the STARK/Cairo verifier



thus we get


Combine _j_ ( _{e_ 0 _, ._ _~~. .,~~_ _e_ 2 _j_ _−_ 1 _}, ζ, v_ ) :=


When _j_ = 1, we get



2 <sup>_j_</sup> _−_ 1



_q_ =0




- _<u>ζ</u>_

_v_




- _q_ 2 <sup>_j_</sup> _−_ 1

_·_   

_k_ =0



( _ξ_ <sup>_−_</sup> <sup>rev(</sup> <sup>_k_</sup> <sup>)</sup> ) <sup>_q_</sup> _· ek_ _._



Combine1( _{e_ 0 _, e_ 1 _}, ζ, v_ ) := ( _e_ 0 + _e_ 1) + _ζ · v_ <sup>_−_</sup> <sup>1</sup> _·_ ( _e_ 0 _−_ _e_ 1)


since _ξ_ <sup>_−_</sup> <sup>rev(0)</sup> = 1 and _ξ_ <sup>_−_</sup> <sup>rev(1)</sup> = _−_ 1. Moreover, Combine satisfies the recursive relation


Combine _j_ ( _{e_ 0 _, . . ., e_ 2 _j_ _−_ 1 _}, ζ, v_ ) = Combine1( _{e_ <sup>_′_</sup> 0 <sup>_, e_</sup> 1 <sup>_′_</sup> <sup>_}, ζ_</sup> <sup>2</sup> <sup>_j−_</sup> <sup>1</sup> <sup>_, v_</sup> <sup>2</sup> <sup>_j−_</sup> <sup>1)</sup>


where


_e_ <sup>_′_</sup> 0 <sup>:= Combine</sup> <sup>_j−_</sup> <sup>1(</sup> <sup>_{e_</sup> <sup>0</sup> <sup>_, . . ., e_</sup> 2 <sup>_j−_</sup> <sup>1</sup> _−_ 1 <sup>_}, ζ, v_</sup> <sup>)</sup>

_e_ <sup>_′_</sup> 1 <sup>:= Combine</sup> <sup>_j−_</sup> <sup>1(</sup> <sup>_{e_</sup> 2 <sup>_j−_</sup> <sup>1</sup> <sup>_, . . ., e_</sup> 2 <sup>_j_</sup> _−_ 1 <sup>_}, ζ, v · ξ_</sup> <sup>)</sup>


We provide a proof that this recursive relation is correct in Appendix A.


The function `fri_formula2` correctly implements Combine1. Moreover, the functions
`fri_formula4`, `fri_formula8` and `fri_formula16` correctly implement Combine2, Combine3
and Combine4 using the recursive relation. Finally, the constants `OMEGA_16`, `OMEGA_8`,
`OMEGA_4` and `OMEGA_2` are well defined (respectively defined as a generator of the subgroup
of F <sup>_×_</sup> _p_ <sup>of</sup> <sup>size</sup> <sup>16,</sup> <sup>of</sup> <sup>size</sup> <sup>8,</sup> <sup>of</sup> <sup>size</sup> <sup>4</sup> <sup>and</sup> <sup>of</sup> <sup>size</sup> <sup>2).</sup>


3.3.2 File `fri/fri_layer.cairo`


**FRI group.** The function `get_fri_group` returns an address of a memory segment where
the FRI group is stored.


**Computing** **next** **layer.** The function `compute_next_layer` takes as input


  - a list `queries` of queries _Qi_ (represented as a list of `FriLayerQuery` ), and


  - a list `sibling_witness` of evaluations of the polynomial _pi_ .


The function computes the queries of the next layer as follows:


  - it guesses the coset index `cosetIdx` (with a hint), which corresponds to the common
prefix of the indexes of _v · ⟨ξ⟩_, where _ξ_ is the generator of the subgroup of F <sup>_×_</sup> _p_ <sup>of</sup> <sup>size</sup>

2 <sup>_ℓi_</sup> . Let us denote _c_ the element of _v · ⟨ξ⟩_ with the lowest index.


  - by calling `compute_coset_elements`, it gathers all the evaluations




<sup>_′_</sup> _i_ <sup>(</sup> <sup>_c · ξj_</sup> <sup>1)</sup> <sup>_,_</sup> <sup>2</sup> <sup>_si_</sup> <sup>_· p_</sup> _i_ <sup>_′_</sup>



2 <sup>_si_</sup> _· p_ <sup>_′_</sup> _i_ <sup>(</sup> <sup>_c_</sup> <sup>)</sup> <sup>_,_</sup> <sup>2</sup> <sup>_si_</sup> <sup>_· p′_</sup> _i_



_i_ <sup>_′_</sup> <sup>(</sup> <sup>_c · ξj_</sup> <sup>2)</sup> <sup>_, . . ._</sup>



where the exponents _j_ 1 _, j_ 2 _, . . .,_ matches the set _{_ 0 _, . . .,_ 2 <sup>_ℓi_</sup> _−_ 1 _}_ in increasing bitreverse order. Specifically:


Page 33/59


Code review of the Cairo implementation of the STARK/Cairo verifier


**–** if the query list is not empty and the following query has index `cosetIdx` _·_

2 <sup>_ℓi_</sup> + _j_, it gets the evaluation of _pi_ from the query list (and computes <sup><u>1</u></sup> _c_ <sup>as</sup>
_v ·_ `friGroup[` _j_ `]` <sup>_−_</sup> <sup>1</sup> <u>);</u>


**–** otherwise, it takes the evaluation from `sibling_witness` (this value will be

checked later with the Merkle tree).


The evaluations of _p_ <sup>_′_</sup> _i_ <sup>are</sup> <sup>stored</sup> <sup>in</sup> <sup>`verify_y_values`</sup> <sup>and</sup> <sup>the</sup> <sup>coset</sup> <sup>index</sup> <sup>is</sup> <sup>stored</sup>

in `verify_indices` .


- it checks that at least one query has been read from the query list. This notably
implies that the index of _v_ is in the range _{_ `cosetIdx` _·_ 2 <sup>_ℓi_</sup> _, . . .,_ ( `cosetIdx` +1) _·_ 2 <sup>_ℓi_</sup> _−_ 1 _}_
hence the guess on the coset index was necessarily correct.


- it computes 2 <sup>_si_</sup> <sup>+1</sup> _·pi_ +1( _v_ <sup>2</sup> <sup>_ℓi_</sup> ) using the folding formulae from `fri/fri_formula.cairo` .




- it adds the triplet

        - <u>1</u>
`costIdx` _,_ 2 <sup>_si_</sup> <sup>+1</sup> _· pi_ +1( _v_ <sup>2</sup> <sup>_ℓi_</sup> ) _,_
( _v_ <sup>_′_</sup> ) <sup>2</sup> <sup>_ℓi_</sup>







to the FRI queries as an element to be processed by the next FRI layer.


At the end, the function `compute_next_layer` outputs


  - `next_queries` : the list of the queries to be processed by the next FRI layer,


  - `verify_indices` : the list of indexes of layer polynomial evaluations to be decommitted,


  - `verify_y_values` : the list of layer polynomial evaluations to be decommitted.


 - **Observation** **9:** **Confusing** **naming**


The variable `sibling_witness` contains the additional evaluations of the layer polynomials required to perform the decommit phase of the FRI protocol. However, the
term “sibling witness” usually refers to the authentication paths of Merkle trees.


**Recommendation:** We recommend renaming the variable and avoiding the “sibling”
terminology. For example, it could be renamed as `coset_witness` .


3.3.3 File `fri/fri.cairo`


**FRI** **commitment.** The function `fri_commit` corresponds to the commitment phase
of the FRI protocol. It calls the recursive function `fri_commit_rounds` : for each layer _i_
except the last one, this function reads the commitment of the layer polynomial _pi_ from the
proof and samples the challenge _ζi_ . Then the function `fri_commit` reads the coefficients of
the polynomial _p_ <sup>_′_</sup> _K−_ 1 <sup>from the proof.</sup> <sup>It returns all the commitment digests,</sup> <sup>the challenges</sup>



the polynomial _p_ <sup>_′_</sup> _K−_ 1 <sup>from the proof.</sup> <sup>It returns all the commitment digests,</sup> <sup>the challenges</sup>

_{ζi}i_ and the polynomial _p_ <sup>_′_</sup> _K−_ 1 <sup>packed</sup> <sup>in</sup> <sup>a</sup> <sup>`FriCommitment`</sup> <sup>structure.</sup>




<sup>_′_</sup> _K−_ 1 <sup>packed</sup> <sup>in</sup> <sup>a</sup> <sup>`FriCommitment`</sup> <sup>structure.</sup>



Page 34/59


Code review of the Cairo implementation of the STARK/Cairo verifier


 - **Observation** **10:** **Confusing** **naming**

The values in `eval_points` corresponds the challenges _{ζi}i_ which are not evaluation
points.


**Recommendation:** We recommend changing the name of this variable.


**FRI** **decommitment.** The function `fri_decommit` proceeds as follow:


  - the function `gather_first_layer_queries` formats the initial FRI queries _Q_ 0 using
the evaluations of the DEEP composition polynomial _p_ 0. For each _v_ _∈Q_ 0 with
scaled value _v_ <sup>_′_</sup> := _c_ lde _<u>v</u>_ <sup>,</sup> <sup>it</sup> <sup>builds</sup> <sup>the</sup> <sup>triplet</sup>



�index0( _v_ ) _,_ _p_ 0( _v_ ) _,_ <sup><u>1</u></sup>

_v_ <sup>_′_</sup>


represented by the `FriLayerQuery` structure.








  - then, the function `fri_decommit_layers` runs the decommitment of the FRI layers:
for each layer _i_,


**–** it computes the evaluations of _pi_ +1 on the queries _Qi_ +1 := _Q_ <sup>2</sup> _i_ <sup>_ℓi_</sup> using evaluations

of _pi_, thanks to the function `compute_next_layer` of `fri_layer.cairo` .

**–** it checks that the evaluations of _pi_ used by the `compute_next_layer` func
tion (which are returned in `verify_y_values` with corresponding coset indices
in `verify_indices` ) are consistent with the commitment of _pi_, thanks to the
function `table_decommit` .


  - finally, the function `verify_last_layer` evaluates the last layer polynomial _pK−_ 1 on
all the queries _QK−_ 1 and checks that the evaluations are consistent with the output
of the FRI protocol.


 - **Observation** **11:** **Unused** **variable**


The member `n_leaves` of the structure `FriLayerWitness` is never used.

**Recommendation:** We recommend verifying that the number of read values in
`sibling_witness` is exactly `n_leaves` .


3.3.4 File `fri/config.cairo`


**FRI** **configuration.** The function `fri_config_validate` performs a batch of checks on
the FRI configuration. It performs some sanity checks:


0 _≤_ deg _pK−_ 1 _≤_ 15 _,_

2 _≤_ _K_ _≤_ 15 _._


Page 35/59


Code review of the Cairo implementation of the STARK/Cairo verifier


It also checks that _ℓ_ 0 = 0, and by calling the function `fri_layers_config_validate`, it
checks that

1 _≤_ _ℓi_ _≤_ 4 _,_


for all 1 _≤_ _i < K_ . At the same time, it computes



_sK−_ 1 :=



_K−_ 1



_i_ =1



_ℓi_



and it returns the expected degree of the polynomial _p_ 0 ( _i.e._ the first layer polynomial)


log2 deg _p_ 0 := log2 _pK−_ 1 + _sK−_ 1


after checking that log2 deg _p_ 0 + log2 _β_ = log2 _|L_ 0 _|_ .


 - **Observation** **12:** **Confusing** **naming**


The variable `log_n_cosets` corresponds to the logarithm of the blowup factor _β_ .

**Recommendation:** We recommend using the notion of _blowup_ _factor_ instead of
speaking about the number of cosets.

#### 3.4 Core STARK verifier


The source files reviewed in this section correspond to the first verification level described in
Section 2.2.2. They implement the core of the STARK verification process without dealing
with the format of execution traces, the AIR constraints, and the public input. The STARK
core depends on several external functions. Those functions must be made accessible to
the STARK core through an `AirInstance` structure (from `air_interface.cairo` ). The
entry point of the STARK verifier is the function

```
        verify_stark_proof(air, proof, security_bits)

```

of the file `stark_verifier/core/stark.cairo` .


3.4.1 File `domains.cairo`


This file defines the structure `StarkDomains` . The latter gathers all the information about
the trace domain (each trace column is interpreted as the evaluations of a polynomial over
this domain) and the evaluation domain _L_ 0. The members of this structure are


  - `eval_domain_size` which corresponds to _|L_ 0 _|_ := _β · L_,


  - `log_eval_domain_size` which corresponds to log2 _|L_ 0 _|_,




- `eval_generator` which corresponds to _g_



_|pL−_ 01 _|_,



Page 36/59


Code review of the Cairo implementation of the STARK/Cairo verifier


  - `trace_domain_size` which corresponds to _L_ := `CPU_COMPONENT_HEIGHT` _· N_,


  - `log_trace_domain_size` which corresponds to log2 _L_,

  - `trace_generator` which corresponds to _g_ _<u>p−L</u>_ <u>1</u>,


where _g_ is a generator of F <sup>_×_</sup> _p_ <sup>.</sup>


This structure is initialized by the function `stark_domains_create` (from the file
`stark_verifier/core/config.cairo` ) which is called by `verify_stark_proof` . This initialization ensures that the values in the structure are self-consistent, while a subsequent
call to `public_input_validate` (from `public_verify.cairo` ) makes sure that the structure is consistent with the public input.


3.4.2 File `air_interface.cairo`


This file defines the structure `AirInstance` which gathers all the functions necessary to
the STARK core for running the proof verification process. Those functions are


  - `public_input_hash` : which takes as input a pointer to the public input and must
return the hash digest of the public input.


  - `public_input_validate` : which performs a batch of checks to validate the configuration of the public input. At the same time, it must check that the given STARK
domains are consistent with the public input.


  - `traces_config_validate` : which performs a batch of checks to validate the format
of the traces.


  - `traces_commit` : which updates the verifier channel by reading trace commitments
from the proof.


  - `traces_decommit` : which checks that the revealed values of the execution trace are
consistent with the commitment.


  - `traces_eval_composition_polynomial` : which evaluates the composition polynomial _h_ in the OODS point _z_ using the mask _{yℓ}ℓ_ .


  - `eval_oods_boundary_poly_at_points` : which evaluates the DEEP composition polynomial _p_ 0 for the queries in _Q_ 0.


Moreover, the `AirInstance` structure includes some constants related to the AIR constraints:


  - `n_constraints` is the number of constraints, which we denote _k_,


  - `constraint_degree` is the constraint degree, which we denote _M_ 2,


  - `mask_size` is the size of the mask, which we denote _M_ 1.


Page 37/59


Code review of the Cairo implementation of the STARK/Cairo verifier


The `air_interface.cairo` file further provides wrapper functions for the routines
from `AirInstance` . For example, the function `public_input_hash` takes an `AirInstance`
structure as input and performs an absolute jump to the same function from the structure
(thus forwarding its input arguments).

The `air_interface.cairo` file also defines void structures `PublicInput` and `Traces*`
since the core STARK verifier manipulates some instances of these structures (without
accessing their members). It further defines the structure `OodsEvaluationInfo` used by
the function `eval_oods_boundary_poly_at_points` .


Let us remark that the definition of the traces is not part of the core STARK verifier. In
practice, there are two possible trace formats depending on whether the STARK proof relies
on classical AIR constraints, or on Randomized AIR with Preprocessing [3]. A different
choice is made in the Solidity implementation of the verifier for which the two formats are
supported in the core STARK verifier (which takes a parameter flag to select the format).
Another option would be to only support the second format which is necessary for Cairo
programs (because of the way the memory is handled). The current choice offers more
flexibility for possible future evolutions of the format of traces.


3.4.3 File `proof_of_work.cairo`


A proof of work is used to impose a computational effort on the IOP prover after the
STARK commitment phase and before receiving the FRI queries. The proof of work
consists in solving a partial hash preimage puzzle which depends on the channel state.
The IOP verifier just receives a nonce ( _i.e._ the solution of the puzzle) and checks its
validity.


**Proof** **of** **work.** The proof-of-work puzzle consists in finding a 64-bit nonce such that
the hash digest resulting of the hash of the nonce which, when hashed together with the
channel state, results in a digest with `n_bits` most significant bits to zero. Figure 5 gives
a graphical description of the puzzle.


Figure 5: Proof of work


Page 38/59


Code review of the Cairo implementation of the STARK/Cairo verifier


The function `proof_of_work_commit` gets the nonce from the proof transcript and
checks it with `verify_proof_of_work` . Given the nonce and the channel state, the latter
function verifies that the nonce constitutes a valid proof of work by computing the hash
digest as depicted in Figure 5 and by checking that its `n_bits` leading bits are unset. Let
us remark that the channel state on which the proof of work depends is the state _before_
_reading_ _the_ _nonce_ .


 - **Observation** **13:** **Terminology**


The name `proof_of_work_commit` does not seem fully appropriate. Indeed this function does not properly “commit” a proof of work but it verifies by calling the function
`verify_proof_of_work` .

**Recommendation:** Avoid the “commit” terminology for this function.


**Proof-of-work** **configuration.** The function `proof_of_work_config_validate` performs the following sanity check on the proof-of-work configuration:


1 _≤_ _κpow_ _≤_ 50


where _κpow_ is the computational cost (in bits) of the proof of work.


3.4.4 File `config.cairo` ( `stark_verifier/core` )


In what follows, we denote _κpow_ the computational cost (in bits) of the proof of work and
_κ_ the security (in bits) of the STARK proof.


**STARK** **configuration.** The function `stark_config_validate` performs several sanity
checks on the proof configuration:


1 _≤_ log2 _N_ _≤_ 64

0 _≤_ _κ_

1 _≤_ log2 _β_ _≤_ 16

_κpow_ _≤_ _κ_

1 _≤_ # _Q_ 0 _≤_ 48 _._


It also checks that the configuration achieves the desired security level, that is:


# _Q_ 0 _·_ log2 _β_ + _κpow_ _≥_ _κ._


It then calls the validation functions of different proof components:


  - `proof_of_work_config_validate` validates the configuration of the proof of work
by checking

1 _≤_ _κpow_ _≤_ 50 _._


Page 39/59


Code review of the Cairo implementation of the STARK/Cairo verifier


  - `traces_config_validate` validates the configuration of the traces by checking


1 _≤_ _W_ <sup>_′_</sup> _≤_ 128 _,_

1 _≤_ _W_ _−_ _W_ <sup>_′_</sup> _≤_ 128 _._


  - `fri_config_validate` validates the configuration of the FRI protocol by checking


0 _≤_ deg _pK−_ 1 _≤_ 15 _,_

2 _≤_ _K_ _≤_ 15 _,_


_ℓ_ 0 = 0 _,_

_∀_ 1 _≤_ _i < K,_ 1 _≤_ _ℓi_ _≤_ 4 _._


**Initializing** **domains.** The function `stark_domains_create` initializes a `StarkDomains`
object from the STARK configuration:


  - it computes the size of the trace domain and computes a generator of the trace
domain,


  - it computes the size of the evaluation domain _|L_ 0 _|_ = _βL_ and computes the generator
_g_ lde, such that _L_ 0 = _c_ lde _· ⟨g_ lde _⟩_ .


The two generators are computed by raising the “field generator” _g_ to the appropriate
power.


 - **Observation** **14:** **Confusing** **expression**



At line 85, the generator for the evaluation domain _g_ lde := _g_



_|pL−_ 01 _|_ is computed as



`pow(FIELD_GENERATOR,` `(-1)` `/` `eval_domain_size)`,


which might be confused with _g_ _|−L_ 01 _|_ . Same remark for the generator of the trace domain

at line 87.


**Recommendation:** We recommend defining a constant `PRIME` for _p_ and to use it
in those formulae, or at least to add some comments next to those lines to explain the
computation.


3.4.5 File `stark.cairo`


**Structure** **definition.** The file `stark.cairo` defines several data structures. The structure `StarkProof` gathers the different elements of the proofs (as detailed in Section 2.3.1):


  - the proof configuration ( `StarkConfig` ),


  - the public input ( `PublicInput` ),


Page 40/59


Code review of the Cairo implementation of the STARK/Cairo verifier


  - the commitments of the proof transcript ( `StarkUnsentCommitment` ), and


  - the witnesses revealed in the STARK decommitment phase ( `StarkWitness` ).


The structure `StarkCommitment` represents all the data from the STARK commitment
phase which will be used in the STARK decommitment phase. Finally, additional structures (whose names start by `InteractionValuesAfter` ) are defined to wrap some challenges sampled by the verifier.


**STARK** **commitment.** The function `stark_commit` processes the successive steps of
the STARK commitment phase as described in Figure 1 (Section 2.2):


  - it reads the trace commitment from the proof using `traces_commit`,


  - it samples the constraint coefficients _{αj}j, {βj}j_ using `random_felts_to_prover`,


  - it reads the commitment of the composition polynomial _h_ using `table_commit`,


  - it samples the OODS point _z_ using `random_felts_to_prover`,


  - it reads the OODS values _{yℓ}ℓ_ _∪{y_ ˆ _ℓ}ℓ_ using `read_felts_from_prover`,


  - by calling `verify_oods`,


**–** it evaluates the composition polynomial _h_ on the OODS point _z_ with the mask

_{yℓ}ℓ_ using `traces_eval_composition_polynomial`,

**–** it evaluates again the composition polynomial _h_ on the OODS point _z_ as


_h_ ( _z_ ) = _y_ ˆ0 + _z ·_ ˆ _y_ 1 _,_


**–** it checks that the two above computations give the same result.


  - it samples the OODS coefficients _{γi}i_ using `random_felts_to_prover`,


  - it runs the FRI commitment phase by calling `fri_commit`,


  - it verifies that the prover correctly performed the proof of work,


  - it finally returns all the commitments (trace, composition, FRI), the OODS point,
the OODS coefficients, and the OODS values packed in a structure `StarkCommitment`
(let us remark that the constraint coefficients are not useful anymore).


**STARK** **decommitment.** The function `stark_decommit` processes the successive steps
of the STARK decommitment phase as described in Figure 1 (Section 2.2):


  - it checks that `witness.traces_decommitment` are valid opened values


_{f_ 0( _v_ ) _, . . ., fW_ _−_ 1( _v_ ) _}v∈Q_ 0


using `traces_decommit`,


Page 41/59


Code review of the Cairo implementation of the STARK/Cairo verifier


  - it checks that `witness.composition_decommitment` are valid opened values


_{h_ 0( _v_ ) _, . . ., hM_ 2 _−_ 1( _v_ ) _}v∈Q_ 0


using `table_decommit` <u>,</u>


  - it computes the field elements in _Q_ 0 from their indexes using `queries_to_points`,


  - it evaluates the DEEP composition polynomial _p_ 0 on the queries:


_{p_ 0( _v_ ) _, v_ _∈Q_ 0 _}_


using `eval_oods_boundary_poly_at_points`,


  - and finally, it runs the FRI decommitment phase by calling `fri_decommit` .


**STARK** **verifier.** The function `verify_stark_proof` is the entry point of the core
STARK verifier. It takes as input an `AirInstance` instance, a `StarkProof` instance, and
the security level (in bits). It proceeds as follows:


  - it validates the proof configuration by calling `stark_config_validate` and computes
the STARK domains by calling `stark_domains_create`,


  - it validates the public input (and checks its consistency with the STARK domains)
by calling `public_input_validate`,


  - it allocates a memory segment dedicated for Blake2s instances: this memory segment
will be given as an implicit parameter to functions (in the same way as a builtin
memory segment),


  - it hashes the public input using `public_input_hash`,


  - it initializes the verifier channel with the hash digest of the public input by calling
`channel_new`,


  - it runs the STARK commitment phase by calling `stark_commit`,


  - it samples the queries _Q_ 0 by calling `generate_queries`,


  - it runs the STARK decommitment phase by calling `stark_decommit`,


  - it finally checks that all the instances in the Blake2s memory segment are valid.


 - **Observation** **15:** **Confusing** **naming**


The naming used in the implementation is inconsistent with the notions from the
STARK/Cairo documentation.


   - The constraint coefficients _{αj}j_ and _{βj}j_ are named (or referred to as):


**–** `interaction` `values` `after` `traces` in `stark.cairo`


**–** `traces` `coefficients` in `stark.cairo`


Page 42/59


Code review of the Cairo implementation of the STARK/Cairo verifier


**–** `constraint_coefficients` in `composition.cairo`


   - The OODS coefficients _γ_ 0 _, . . ., γM_ 1+ _M_ 2 _−_ 1 are named (or referred to as):


**–** `interaction` `values` `after` `OODS` in `stark.cairo`


**–** `oods_coefficients` in `stark.cairo`


**–** `constraint_coefficients` in `oods.cairo` and in `OodsEvaluationInfo`


This confusing naming harms the code readability and increases the risk of implementation errors.


**Recommendation:** We recommend making the naming consistent, typically by
using the terminology defined in Section 2.1 (which was gathered from different StarkWare resources [5, 6, 3]).


 - **Observation** **16:** **Useless** **wrapping**


The structures


`InteractionValuesAfterTraces`, `InteractionValuesAfterComposition`

and `InteractionValuesAfterOods`


are wrappers for the constraint coefficients, the OODS point and the OODS coefficients respectively. However, the purpose of those wrappers is not clear, and using
them decreases the readability of the source code (by increasing the naming confusion
reported above).


**Recommendation:** We recommend removing these structures from the source code,
or at least, to document their purpose and revising their naming.

#### 3.5 Public input


The statement to be verified by the CPU verifier (the second verification level, see Section 2.2.2) is represented by a structure named _the_ _public_ _input_ . This structure is summarized in Table 3. Let us stress that the public input of the Cairo verifier described in
Table 1 (Section 2.3) is a specific case of Table 3.

The CPU verifier aims to check that the proof has been built from a valid execution
trace of a given Cairo program. Such an execution trace involves a memory mapping. Some
values of this memory mapping are publicly known, _i.e._ are part of the statement to be
verified. This public part of the memory is called the _public_ _memory_ which is denoted m <sup>_∗_</sup>

in the Cairo documentation. The verifier must check that the execution trace committed
by the prover is consistent with m <sup>_∗_</sup> .

In the present implementation of the CPU verifier, the public memory is divided into
several pages. Each page contains a part m <sup>_∗_</sup> _i_ <sup>of the public memory.</sup> <sup>All together,</sup> <sup>the pages</sup>


Page 43/59


Code review of the Cairo implementation of the STARK/Cairo verifier


**<u>Field</u>** **<u>Description</u>**
<u>`log_n_steps`</u> <u>Log</u> <u>(in</u> <u>base</u> <u>2)</u> <u>of</u> <u>the</u> <u>number</u> _<u>N</u>_ <u>of</u> <u>states</u>
<u>`rc_min`</u> <u>Min</u> <u>range-check</u> <u>value</u>
<u>`rc_max`</u> <u>Max</u> <u>range-check</u> <u>value</u>
<u>`layout`</u> <u>The</u> <u>layout</u> <u>identifier</u>
<u>`n_segments`</u> <u>Number</u> <u>of</u> <u>segments</u>
<u>`segments[0].begin_addr`</u> <u>First</u> <u>address</u> <u>of</u> <u>the</u> <u>segment</u> <u>0</u>
<u>`segments[0].stop_ptr`</u> <u>Final</u> <u>position</u> <u>of</u> <u>the</u> <u>segment-0</u> <u>pointer</u>
<u>`segments[1].begin_addr`</u> <u>First</u> <u>address</u> <u>of</u> <u>the</u> <u>segment</u> <u>1</u>
<u>`segments[1].stop_ptr`</u> <u>Final</u> <u>position</u> <u>of</u> <u>the</u> <u>segment-1</u> <u>pointer</u>
_<u>. . .</u>_ _<u>. . .</u>_
<u>`padding_addr`</u> <u>The</u> <u>padding</u> <u>address</u> _<u>a</u>_ <u>pad</u>
<u>`padding_value`</u> <u>The</u> <u>padding</u> <u>value</u> <u>m(</u> _<u>a</u>_ <u>pad)</u>
<u>`main_page_len`</u> <u>Size</u> <u>of</u> <u>the</u> <u>main</u> <u>page</u>
<u>`main_page[0]`</u> <u>A</u> <u>memory</u> <u>mapping</u> <u>(an</u> <u>address</u> <u>with</u> <u>its</u> <u>value)</u>
<u>`main_page[1]`</u> <u>Another</u> <u>memory</u> <u>mapping</u>
_<u>. . .</u>_ _<u>. . .</u>_
<u>`n_continuous_pages`</u> <u>Number</u> <u>of</u> <u>continuous</u> <u>pages</u>


_For_ _each_ _continuous_ _page_ _i:_



<u>`start_address`</u> <u>The</u> <u>first</u> <u>address</u> <u>of</u> <u>m</u> <sup>_<u>∗</u>_</sup> _<u>i</u>_

<u>`size`</u> <u>Size</u> <u>of</u> <u>m</u> <sup>_<u>∗</u>_</sup> _<u>i</u>_



<u>`size`</u> _<u>i</u>_

<u>`hash`</u> <u>Hash</u> <u>of</u> <u>m</u> <sup>_<u>∗</u>_</sup> _<u>i</u>_



<u>`hash`</u> _<u>i</u>_

`prod` <u>�</u> _<u>a∈A</u>_ <sup>_∗_</sup>

_<u>i</u>_ <sup>(</sup> <sup>_z −_</sup>



_<u>i</u>_ <sup>_<u>∗</u>_</sup> <sup>(</sup> <sup>_a_</sup> <sup>)))</sup>




<sup>_∗_</sup> _<u>i</u>_ <sup>(</sup> <sup>_z −_</sup> <sup>(</sup> <sup>_a_</sup> <sup>+</sup> <sup>_α ·_</sup> <sup>m</sup> _<u>i</u>_ <sup>_<u>∗</u>_</sup> <sup>(</sup>



Table 3: Structure of the public input.


form a partition of the public memory:



m <sup>_∗_</sup> =






_i_



m <sup>_∗_</sup> _i_ <sup>_._</sup>



The first page (named the _main_ _page_ ) is a _regular_ one, meaning that this page corresponds
to a list of pairs address-value (represented by the structure `AddrValue` ). The other pages
are _continuous_ ones, _i.e._ all the addresses in the same page are adjacent. A continuous
page is encoded by its starting address and a list of consecutive values.


3.5.1 File `public_memory.cairo`


The function `get_page_product` computes the cumulative product for a regular page.
Given the (partial) public memory m <sup>_∗_</sup> 0 <sup>:</sup> <sup>_A∗_</sup> <sup>_→_</sup> <sup>F</sup> <sup>_p_</sup> <sup>and</sup> <sup>interaction</sup> <sup>elements</sup> <sup>(</sup> <sup>_z, α_</sup> <sup>),</sup> <sup>it</sup>


Page 44/59


Code review of the Cairo implementation of the STARK/Cairo verifier



outputs

      

_a∈A_ <sup>_∗_</sup>



( _z −_ ( _a_ + _α ·_ m <sup>_∗_</sup> 0 <sup>(</sup> <sup>_a_</sup> <sup>)))</sup> <sup>_._</sup>



In practice, the above function is used to compute the cumulative product of the main
page.

A header of a continuous page m <sup>_∗_</sup> _i_ <sup>(represented by the structure</sup> <sup>`ContinuousPageHeader`</sup> <sup>)</sup>

contains the first address _a_ 0 of the page, its size _n_ := _|A_ <sup>_∗_</sup> _i_ <sup>_|_</sup> <sup>,</sup> <sup>its</sup> <sup>hash</sup> <sup>digest</sup>



A header of a continuous page m <sup>_∗_</sup> _i_




<sup>_∗_</sup> _i_ <sup>_|_</sup> <sup>,</sup> <sup>its</sup> <sup>hash</sup> <sup>digest</sup>



_h_ m <sup>_∗_</sup> _i_ <sup>:= Hash (m</sup> <sup>_∗_</sup> <sup>(</sup> <sup>_a_</sup> <sup>0)</sup> <sup>_, . . .,_</sup> <sup>m</sup> <sup>_∗_</sup> <sup>(</sup> <sup>_a_</sup> <sup>0 +</sup> <sup>_n −_</sup> <sup>1))</sup>



and its cumulative product


`prod` _i_ =






_a∈A_ <sup>_∗_</sup> _i_



( _z −_ ( _a_ + _α ·_ m <sup>_∗_</sup> ( _a_ ))) _∈_ F _p,_



where _A_ <sup>_∗_</sup> _i_




<sup>_∗_</sup> _i_ <sup>:=</sup> <sup>_{a_</sup> <sup>0</sup> <sup>_, a_</sup> <sup>0</sup> <sup>+ 1</sup> <sup>_, . . ., a_</sup> <sup>0</sup> <sup>+</sup> <sup>_n −_</sup> <sup>1</sup> <sup>_}_</sup> <sup>is</sup> <sup>the</sup> <sup>domain</sup> <sup>of</sup> <sup>m</sup> <sup>_∗_</sup> _i_



where _A_ <sup>_∗_</sup> _i_ <sup>:=</sup> <sup>_{a_</sup> <sup>0</sup> <sup>_, a_</sup> <sup>0</sup> <sup>+ 1</sup> <sup>_, . . ., a_</sup> <sup>0</sup> <sup>+</sup> <sup>_n −_</sup> <sup>1</sup> <sup>_}_</sup> <sup>is</sup> <sup>the</sup> <sup>domain</sup> <sup>of</sup> <sup>m</sup> <sup>_∗_</sup> _i_ <sup>.</sup> <sup>Using</sup> <sup>such</sup> <sup>headers,</sup> <sup>the</sup>

function `get_continuous_pages_product` computes the global cumulative product for all
the continuous pages:

       


prod _i_



_i_

where prod1 _,_ prod2 _, . . ._ are the individual cumulative products of the continuous pages.

Let us stress that the CPU verifier does not check that the cumulative products of the
continuous pages are consistent with their hash digests. It should be verified by the code
which calls this implementation of the CPU verifier. In the audited source code, this call
is performed by `verify_cairo_proof` of the file


`cairo_verifier/layouts/xxxx/cairo_verifier.cairo` .


This version of the Cairo verifier considers a public memory that is only made of the main
page (see explanation in Section 2.2.2). Therefore, the audited verifier does not care about
the consistency between the cumulative products and the hash digest of the continuous
pages.


3.5.2 File `public_input.cairo`


This file implements the functions related to the public input. It defines the structure
`PublicInput` as depicted in Table 3. It further provides two functions.


**Hashing the public input.** The function `public_input_hash` computes the hash digest
of the public input to be used as the initial state for the verifier channel. To proceed, it
first computes the _Pedersen_ hash digest of the main page as


`main_page_hash` := Hash( _a_ 0 _,_ m <sup>_∗_</sup> 0 <sup>(</sup> <sup>_a_</sup> <sup>0)</sup> <sup>_, a_</sup> <sup>1</sup> <sup>_,_</sup> <sup>m</sup> <sup>_∗_</sup> 0 <sup>(</sup> <sup>_a_</sup> <sup>1)</sup> <sup>_, . . ._</sup> <sup>)</sup>


where _{a_ 0 _, a_ 1 _, . . .}_ = _A_ <sup>_∗_</sup> 0 <sup>is the domain of m</sup> 0 <sup>_∗_</sup> <sup>, and then it computes the</sup> <sup>_Blake2s_</sup> <sup>hash digest</sup>

of the public input. The data is hashed in the order depicted Table 4. A recursive function
`add_continuous_page_headers` is used to loop over the continuous pages.


Page 45/59


Code review of the Cairo implementation of the STARK/Cairo verifier

```
                 log_n_steps

                  rc_min

                  rc_max

                  layout

              segments[0].begin_addr

              segments[0].stop_ptr

              segments[1].begin_addr

              segments[1].stop_ptr
```

<u>.</u>

```
                padding_addr

                padding_value
```

<u>`n_continuous_pages`</u> <u>+ 1</u>

```
                main_page_len

                main_page_hash

              pages[0].start_address

                pages[0].size

                pages[0].hash

              pages[1].start_address

                pages[1].size

                pages[1].hash
```

<u>.</u>


Table 4: Hashing order for the public input


Let us remark that the number of segments is fixed for a specific layout, which is why
this number is not hashed. Moreover, the cumulative products of the public memory pages
do not belong to the statement to prove since they depend on interaction elements which
are sampled during the proof generation, which is why they are not hashed either.


**Cumulative** **product** **ratio.** Some cells of the execution trace are dedicated to the
public memory. The number of such cells is defined as


_<u>L</u>_
_S_ :=
```
                PUBLIC_MEMORY_STEP
```

where `PUBLIC_MEMORY_STEP` is a parameter of the CPU layout. Given _S_ and two interaction
elements ( _z, α_ ), the function `get_public_memory_product_ratio` computes the quotient


_<u>z</u>_ <sup>_S_</sup>



( _z −_ ( _a_ pad + _α ·_ m <sup>_∗_</sup> ( _a_ pad))) <sup>_S−|A∗|_</sup> _·_ <sup><u>�</u></sup>



_a∈A_ <sup>_∗_</sup> <sup>(</sup> <sup>_z −_</sup> <sup>(</sup> <sup>_a_</sup> <sup>+</sup> <sup>_α ·_</sup> <sup>m</sup> <sup>_∗_</sup> <sup>(</sup> <sup>_a_</sup> <sup>)))</sup>



which will be used for the boundary constraint checking that the public memory is valid
(see [3, 2] for details). The product






_a∈A_ <sup>_∗_</sup>



( _z −_ ( _a_ + _α ·_ m <sup>_∗_</sup> ( _a_ )))


Page 46/59


Code review of the Cairo implementation of the STARK/Cairo verifier


is computed by `get_public_memory_product` and is obtained by simply multiplying the
cumulative product of the main page (returned by `get_page_product` ) with the cumulative
product of the other pages (returned by `get_continuous_pages_product` ).


3.5.3 File `public_verify.cairo`


**Segment** **list.** This file defines the list of the segments which are in the public input
for the considered layout. This list is implemented via the namespace `segments` . In
practice, the segments `PROGRAM` and `EXECUTION` will be always present since they correspond
to the program segment (holding the bytecode of the proven Cairo program) and the
execution segment (holding the intermediate variables of the execution). These segments
are respectively defined over the domains [ `pc` _I_ _,_ `pc` _F_ ] and [ `ap` _I_ _,_ `ap` _F_ ] with `pc` _I_, `pc` _F_ the initial
and final states of the program counter, and `ap` _I_, `ap` _F_ the initial and final states of the
allocation pointer. The other segments correspond to builtin segments.


**Builtin** **list.** The function `get_layout_builtins` outputs the list of the builtins present
in the considered layout. Each builtin is represented by a short string literal with the
builtin name. This list should be consistent with the namespace `segment` and is further
terminated by a zero cell.


 - **Observation** **17:** **Magic** **number**


In the function `get_layout_builtins`, the number of builtins is hardcoded.

**Recommendation:** We recommend to defining the number of builtins as


`segments.N_SEGMENTS` `-` `2` .


with a comment explaining that the value `2` corresponds to the program and execution
segments.


**Public** **input** **validation.** The function `public_input_validate` aims to validate the
public input. It takes as input a `PublicInput` instance and a `StarkDomains` instance and
performs the following sanity checks:


  - it checks that the number _N_ of Cairo states is upper bounded as:


log2 _N_ _≤_ `MAX_LOG_N_STEPS` _,_


where `MAX_LOG_N_STEPS` is equal to 50 in the audited files;


  - it checks that the range-check configuration is valid:


0 _≤_ `rc_min` _≤_ `rc_max` _≤_ `MAX_RANGE_CHECK` := 2 <sup>16</sup> _−_ 1


  - it checks that the layout identifier in the public input corresponds to the identifier of
the considered layout;


Page 47/59


Code review of the Cairo implementation of the STARK/Cairo verifier


- it checks that
_N_ _×_ `CPU_COMPONENT_HEIGHT` = _L_


where for this check _N_ ~~is~~ obtained from the `PublicInput` instance while _L_ is obtained
from the `StarkDomains` instance. This single check ensures that the STARK domains
are consistent with the public input since we already know that the STARK domains
are self-consistent thanks to the function `stark_domains_create` .


- for each builtin, it checks that the number of used instances is less than the maximum
number of instances:



<u>`ptr`</u> _<u>F</u>_ _<u>−</u>_ <u>`ptr`</u> _<u>I</u>_
0 _≤_
```
  INSTANCE_SIZE
```

  - <u>��</u> <u>�</u>
Nb used instances



_<u>N</u>_
_≤_ _,_
```
 BUILTIN_RATIO
```

<u>�</u> <u>��</u> <u>�</u>
Max nb instances



where `ptr` _I_ and `ptr` _F_ are the initial and final states of the builtin pointer. While the
builtin ratio is a layout parameter, the instance size is a constant depending on the
builtin. Table 5 lists all the builtins used in the audited files and their corresponding
instance sizes. Let us remark that the above verification assumes that the size of
the builtin segment is a multiple of the instance size, which shall always be the case
for a correctly implemented Cairo program (note that this correct behavior can be
verified from the statement definition). If this is not the case, the above test shall
fail anyway (since the left-hand ratio shall then be large on F _p_ ).


**<u>Existing</u>** **<u>builtin</u>** **<u>Instance</u>** **<u>Size</u>**
<u>Output</u> <u>1</u>
<u>Pedersen</u> <u>3</u>
<u>Range-Check</u> <u>1</u>
<u>ECDSA</u> <u>2</u>
<u>Bitwise</u> <u>5</u>
<u>Keccak</u> <u>16</u>
<u>Pedersen</u> <u>3</u>
<u>EC</u> <u>Op</u> <u>7</u>


Table 5: Instance sizes for the builtins


- **Observation** **18:** **Magic** **numbers**


The instance sizes of the builtins are hardcoded.


**Recommendation:** We recommend to defining constants for these sizes.


Page 48/59


Code review of the Cairo implementation of the STARK/Cairo verifier

#### 3.6 Layout constraints


A CPU layout involves a set of AIR constraints. In the STARK proof system, those
constraints come into play ~~whe~~ n computing the composition polynomial



_h_ ( _x_ ) :=



_k_



_j_ =1



_Cj_ ( _x_ )( _αjx_ <sup>_D−Dj_</sup> <sup>_−_</sup> <sup>1</sup> + _βj_ ) _,_



where _{Cj}j_ are the AIR constraints on the trace (of degrees _{Dj}j_ ) and _D_ the smallest
power of two which is greater than all the constraint degrees.

In the verification process, the constraints _{Cj}j_ are only involved when the verifier
evaluates _h_ on the OODS point _z_ after receiving the mask _{yℓ}ℓ_ .


3.6.1 File `diluted.cairo`


This file provides the function `get_diluted_prod` which computes the diluted component
product used for the layout constraints of the bitwise builtin. Given ( _n,_ `spacing` _, z, α_ ), this
function computes the term _r_ 2 <sup>_n_</sup> of the sequence



where




    _r_ 1 = 1
_∀j, rj_ +1 = _rj_ _·_ (1 + _z · uj_ ) + _α · u_ <sup>2</sup> _j_


_∀j_ := 2 <sup>_i_</sup> _·_ (2 _k_ + 1) _,_ _uj_ = _u_ 2 _i_ = _u_ 2 _i−_ 1 + 2 <sup>_i·_</sup> <sup>`spacing`</sup> _−_ 2 <sup>(</sup> <sup>_i−_</sup> <sup>1)</sup> <sup>_·_</sup> <sup>`spacing`</sup> <sup>+1</sup>



As detailed in Appendix B, the function `get_diluted_prod` correctly implements the above
formula (which was inferred from the comment in the code). Note that the soundness of
the AIR constraints is out of scope of the present audit so we did not further check the
soundness of the above formula.


3.6.2 File `global_values.cairo`


This file defines the structure `GlobalValues` which accumulates all the required information
to evaluate the composition polynomial for the considered layout with the autogenerated
function `eval_composition_polynomial` . It also defines a wrapper `InteractionElements`
for the interaction elements.


3.6.3 File `composition.cairo`


To evaluate the composition polynomial _h_ in the OODS point _z_ using Equation (1), one
needs the _mask_ _{yℓ}ℓ_ which is a set of values of the form _fj_ ( _zg_ <sup>_s_</sup> ) which are involved in the
expressions of the _{Cj_ ( _z_ ) _}j_ .

From the OODS point _z_, the mask values _{yℓ}ℓ_ and some constraints-related coefficients, the function `traces_eval_composition_polynomial` computes _h_ ( _z_ ). To proceed,
it needs to collect and format some information about the constraints:


Page 49/59


Code review of the Cairo implementation of the STARK/Cairo verifier


- thanks to the function `get_public_memory_product_ratio`, it computes the ratio


_<u>z</u>_ <sup>_S_</sup>



( _z −_ ( _a_ pad <u>+</u> _<u>α ·</u>_ m <sup>_∗_</sup> ( _a_ pad))) <sup>_S−|A∗|_</sup> _·_ <sup><u>�</u></sup> _a∈A_ <sup>_∗_</sup> <sup>(</sup> <sup>_z −_</sup> <sup>(</sup> <sup>_a_</sup> <sup>+</sup> <sup>_α ·_</sup> <sup>m</sup> <sup>_∗_</sup> <sup>(</sup> <sup>_a_</sup> <sup>)))</sup>



used for the boundary constraint checking that the public memory is valid.


  - thanks to the function `get_diluted_prod`, it computes the diluted component product used for the constraints of the bitwise builtin (if the bitwise builtin is used in the
considered layout).


  - thanks to the autogenerated functions in `periodic_columns.cairo`, it evaluates periodic columns for the constraints of the builtins which are in the selected layout.


  - it compiles all the necessary values to compute constraints in a structure named
`GlobalValues` defined in `globalvalues.cairo` .


It then calls the autogenerated function `eval_composition_polynomial` (from the file
`autogenerated.cairo` ) with the above structure together with the mask values, the constraint coefficients, and the point _z_, and gets the desired value _h_ ( _z_ ).

#### 3.7 DEEP composition polynomial


Let us recall that the DEEP composition polynomial is the polynomial _p_ 0 defined as



_M_ 2 _−_ 1



_i_ =0



_γM_ 1+ _i ·_ <sup>_<u>hi</u>_</sup> <sup><u>(</u></sup> <sup>_<u>x</u>_</sup> <sup><u>)</u></sup> <sup>_<u>−</u>_</sup> <sup>_<u>y</u>_</sup> <sup><u>ˆ</u></sup> <sup>_<u>i</u>_</sup> _._

_x −_ _z_ <sup>_M_</sup> <sup>2</sup>



_p_ 0( _x_ ) :=



_M_ 1 _−_ 1



_ℓ_ =0



_γℓ_ _·_ <sup>_<u>fjℓ</u>_</sup> <sup><u>(</u></sup> <sup>_<u>x</u>_</sup> <sup><u>)</u></sup> <sup>_<u>−</u>_</sup> <sup>_<u>yℓ</u>_</sup> +

_x −_ _zg_ <sup>_sℓ_</sup>



_γM_ 1+ _i ·_ <sup>_<u>hi</u>_</sup> <sup><u>(</u></sup> <sup>_<u>x</u>_</sup> <sup><u>)</u></sup> <sup>_<u>−</u>_</sup> <sup>_<u>y</u>_</sup> <sup><u>ˆ</u></sup> <sup>_<u>i</u>_</sup>



This polynomial is further called the _OODS_ _polynomial_ . Once the FRI layer polynomials _{pi}i_ have been committed, the IOP verifier sends a list _Q_ 0 of queries and the IOP
prover must evaluate the DEEP composition polynomial (or OODS) polynomial _p_ 0 on
those queries.


3.7.1 File `oods.cairo`


**Evaluating** **the** **DEEP** **composition** **polynomial.** The function

```
           eval_oods_boundary_poly_at_points

```

aims to evaluate the DEEP composition polynomial _p_ 0. This function takes as inputs


  - `points` : the list of evaluation points in _Q_ 0,


  - `decommitment` : the evaluations of _fi_ in these points:


_{_ ( _f_ 1( _v_ ) _, . . ., fW_ _−_ 1( _v_ )) _,_ _v_ _∈Q_ 0 _},_


Page 50/59


Code review of the Cairo implementation of the STARK/Cairo verifier


  - `composition_decommitment` : the evaluations of _hi_ in these points:


_{_ ( _h_ 1( _v_ ) _, . . ., hM_ 2 _−_ 1( _v_ )) _,_ _v_ _∈Q_ 0 _},_


  - `eval_infos` : a structure with members


**–** `eval_infos.oods_point` : the OODS point _z_,

**–** `eval_infos.oods_values` : the OODS values _{yℓ}ℓ_ _∪{y_ ˆ _ℓ}ℓ_,

**–** `eval_infos.constraint_coefficients` : the OODS coefficients _{γi}i_ .


The function then returns the evaluations of _p_ 0 for the input queries:


_{p_ 0( _v_ ) _, v_ _∈Q_ 0 _} ._


In practice, using `eval_oods_boundary_poly_at_points_inner`, the function loops on
the queries and calls the autogenerated evaluation function `eval_oods_polynomial` (from
the file `autogenerated.cairo` ) for each query. More precisely, given a query _v_ _∈Q_ 0,
the OODS point _z_, the OODS values _{yℓ}ℓ_ _∪{y_ ˆ _ℓ}ℓ_, the OODS coefficients _{γi}i_ and the
evaluations ( _f_ 0( _v_ ) _, . . ., fW_ _−_ 1( _v_ )) and ( _h_ 0( _v_ ) _, . . ., hM_ 2 _−_ 1( _v_ )), the autogenerated function
`eval_oods_polynomial` returns _p_ 0( _v_ ).


 - **Observation** **19:** **Inconsistent** **choice** **of** **function** **parameters**


In `eval_oods_boundary_poly_at_points_inner`, the number `n_original_columns`
of trace columns before sampling interaction elements is a function parameter, while
the number `n_interaction_columns` is not.

**Recommendation:** We recommend homogenizing the implementation by removing
`n_original_columns` from the function parameters.

#### 3.8 Cairo verifier


3.8.1 File `layout.cairo`


The core STARK verifier (Section 3.4) takes as input some layout-dependent functions
which are called during the verification process. However, these functions sometimes need
layout-dependent data besides the inputs provided by the core STARK verifier. This
additional data is stored in a structure `Layout` defined in the file `layout.cairo` .

The virtual functions of `AirInstance` take as first argument a pointer to an `AirInstance`
object. To grant them access to the additional data, the idea is to store a `Layout` object
right after the `AirInstance` object in the memory. Namely, if `air` denotes the pointer to
the `AirInstance` object, the `Layout` object shall be stored at address


`air` + `AirInstance.SIZE` _._


The file defines the structure `AirWithLayout` as a wrapper containing an `AirInstance`
object followed by a `Layout` object.

The members of the `Layout` structure are the following:


Page 51/59


Code review of the Cairo implementation of the STARK/Cairo verifier


  - `eval_oods_polynomial` : the autogenerated function to evaluate the DEEP composition polynomial,


  - `n_original_columns` : ~~th~~ e number of columns in the execution trace before sampling
interaction elements,


  - `n_interaction_columns` : the number of columns in the execution trace added after
sampling interaction elements,


  - `n_interaction_elements` : the number of interaction elements.


In the same way as for `AirInstance`, the file implements a function `eval_oods_polynomial`
which performs an absolute jump to the function with the same name in the input `Layout`
structure.


3.8.2 File `verify.cairo`


This file implements the _CPU_ _verifier_, _i.e._ the second verification level abstracted in
Section 2.2.2. The entry point of this level is the function `verify_proof` . It takes as input a
proof (stored in a `StarkProof` object) and calls the function `build_air` . The latter gathers
the layout-dependent information required by the core STARK verifier (trace format, AIR
constraints, etc.) in a `AirInstance` structure as well as the additional data required by the
`AirInstance` functions in a structure `Layout`, both wrapped in a `AirWithLayout` object.
Then, the function `verify_proof` simply runs the STARK verification process by calling
`verify_stark_proof` .


3.8.3 File `cairo_verifier.cairo`


This file implements the Cairo verifier, _i.e._ the third verification level abstracted in Section 2.2.2. This level defines the pages of the public memory on top of the CPU verifier.


**Program** **builtin** **list.** The function `get_program_builtins` outputs the list of the
builtins used in the considered Cairo program. Each builtin is represented by a short string
literal with the builtin name, as for the function `get_layout_builtins` of `public_verify.cairo` .
This list is always terminated by a zero cell. The list of layout builtins must be a subset
of the program builtins, ordered in the same way.


**Public** **input.** As explained in Section 2 (and Remark 1), the audited verifier implementation fixes the number of continuous pages of the public memory m <sup>_∗_</sup> to 0. This means
that m <sup>_∗_</sup> is entirely defined with the main page. For this reason, the output builtin segment
is included to the main page, as opposed to the audited Solidity implementation of the
verifier for which it was part of the continuous pages [1].

The function `_verify_public_input` performs some sanity checks and verifies that the
public input satisfies the format described in Table 1. Specifically, this function:


  - checks that the given public input is made of a single page (the main page),


Page 52/59


Code review of the Cairo implementation of the STARK/Cairo verifier


  - checks that the main page starts with the program bytecode, with first instructions:

```
            ap += n_args; call main; jmp rel 0.

```

where `n_args` is the number of program builtins,


  - checks that the cells following the program bytecode are set to


**–** m <sup>_∗_</sup> ( `fp` _I_ _−_ 2) = `fp` _I_

**–** m <sup>_∗_</sup> ( `fp` _I_ ) = 0


  - checks that


**–** m <sup>_∗_</sup> ( `fp` _I_ ) _. . ._ m <sup>_∗_</sup> ( `fp` _I_ + `n_args` _−_ 1) matches the initial state of the program builtin

pointers,

**–** m <sup>_∗_</sup> ( `ap` _F −_ `n_args` ) _. . ._ m <sup>_∗_</sup> ( `ap` _F −_ 1) matches the final state of the builtin pointers.


This is done by calling the auxiliary function `verify_stack` . If a program builtin is
not included in the list of layout builtins, then the start and end pointers for this
builtin are set to zero.


  - checks that the initial/final program counter and allocation pointer satisfy:


**–** `pc` _I_ = `INITIAL_PC` `:=` `1`,

**–** 0 _≤_ `ap` _I_ _<_ `MAX_ADDRESS` + 1,

**–** 0 _≤_ `ap` _F_ _<_ `MAX_ADDRESS` + 1.


We note that the implementation of `_verify_public_input` implicitly assumes that


`segments.PROGRAM` = 0 and `segments.EXECUTION` = 1


since it assumes that the builtin segment starts from the index 2 (see lines 112 and 118 of
the source code). Table 6 represents the format of the memory which is ensured by these
different checks.

In addition to checking the memory, the function `_verify_public_input` further computes


  - the Pedersen hash digest of the program bytecode (with the booting instructions
calling the `main` function),


  - the Pedersen hash digest of the values in the memory segment of the output builtin.


Those two digests are returned by the function (if all the sanity checks pass).


 - **Observation** **20:** **Unexpected** **behaviour**


If the function `verify_stack` encounters a layout builtin that is not in the list of the
program builtins, all the following memory values will be set to zero without raising
an error.


**Recommendation:** We recommend raising an error when there exists a layout


Page 53/59


Code review of the Cairo implementation of the STARK/Cairo verifier


builtin that is not in the list of the program builtins.


**Main** **entry** **point.** This file further contains the `main` function of the Cairo verifier.
The function:


  - loads the proof (with the public input) in a `StarkProof` object thanks to a hint
parsing the program input,


  - calls the function `verify_cairo_proof` which:


**–** runs the CPU verifier using `verify_proof` with a security level of


`SECURITY_BITS` := 80 bits,


**–** verifies that the public input is valid and complies with Cairo’s public memory

format using `_verify_public_input` .


  - outputs ( _i.e._ writes in the output memory segment):


**–** the hash digest of the bytecode of the proven Cairo program,


**–** the hash digest of the output memory segment of the proven Cairo program


both packed in a `CairoVerifierOutput` object.


Page 54/59


Code review of the Cairo implementation of the STARK/Cairo verifier


`pc` _I_ := 1 <u>`0x40780017fff7fff`</u>
Number program builtins

```
                0x1104800180018000
```

( _no_ _check_ )

```
                0x10780017fff7fff

                    0x0

```

_rest_ _of_ _the_


_bytecode_


`fp` _I_ _−_ 2 <u>`fp`</u> _<u>I</u>_

```
                    0x0
```

`ap` _I_ = `fp` _I_ Start pointer for builtin 1
Start pointer for builtin 2

~~.~~ ..
`fp` _I_ + ( _n −_ 1) Start pointer for builtin _n_


( _no_ _check_ )


`ap` _F_ _−_ _n_ End pointer for builtin 1
End pointer for builtin 2

~~.~~ ..
`ap` _F_ _−_ 1 End pointer for builtin _n_


Table 6: Format of the memory as ensured by the function `_verify_public_input`, with
_n_ = `n_args` the number of program builtins.


Page 55/59


Code review of the Cairo implementation of the STARK/Cairo verifier

### References


[1] CryptoExperts (Thibauld <u>Feneuil</u> and Matthieu Rivain). Code Review of StarkWare’s

EVM STARK Verifier, December 2021.


[2] CryptoExperts (Thibauld Feneuil and Matthieu Rivain). Code Review of the Cairo &

SHARP Verifiers, July 2022.


[3] Lior Goldberg, Shahar Papini, and Michael Riabzev. Cairo - a turing-complete stark
friendly cpu architecture. Cryptology ePrint Archive, Report 2021/1063, 2021. `[https:](https://ia.cr/2021/1063)`
`[//ia.cr/2021/1063](https://ia.cr/2021/1063)` .


[4] Kineret Segal and Gideon Kaempfer. Starkdex deep dive: the
stark core engine. Medium, 2019. `[https://medium.com/starkware/](https://medium.com/starkware/starkdex-deep-dive-the-stark-core-engine-497942d0f0ab)`
`[starkdex-deep-dive-the-stark-core-engine-497942d0f0ab](https://medium.com/starkware/starkdex-deep-dive-the-stark-core-engine-497942d0f0ab)` .


[5] StarkWare. Stark math. Medium, 2019. `[https://medium.com/starkware/tagged/](https://medium.com/starkware/tagged/stark-math)`

`[stark-math](https://medium.com/starkware/tagged/stark-math)` .


[6] StarkWare. ethstark documentation. Cryptology ePrint Archive, Report 2021/582,
2021. `[https://ia.cr/2021/582](https://ia.cr/2021/582)` .


[7] StarkWare. StarkNet and Cairo Documentation, 2022. `[https://www.cairo-lang.](https://www.cairo-lang.org/docs/)`
`[org/docs/](https://www.cairo-lang.org/docs/)` .


Page 56/59


Code review of the Cairo implementation of the STARK/Cairo verifier

### A FRI folding formula


As explained in Section 3.3.1, the term



2 <sup>_j_</sup> _−_ 1

Combine _j_ ( _{e_ 0 _, . . ., e_ 2 _j_ _−_ 1 _}, ζ, v_ ) :=      
_q_ =0


follows a recursive relation



2 <sup>_j_</sup> _−_ 1



_k_ =0



( _ξ_ <sup>_−_</sup> <sup>rev(</sup> <sup>_k_</sup> <sup>)</sup> ) <sup>_q_</sup> _· ek_




- _<u>ζ</u>_

_v_




- _q_

_·_



Combine _j_ ( _{e_ 0 _, . . ., e_ 2 _j_ _−_ 1 _}, ζ, v_ ) = Combine1( _{e_ <sup>_′_</sup> 0 <sup>_, e_</sup> 1 <sup>_′_</sup> <sup>_}, ζ_</sup> <sup>2</sup> <sup>_j−_</sup> <sup>1</sup> <sup>_, v_</sup> <sup>2</sup> <sup>_j−_</sup> <sup>1)</sup>



where



_e_ <sup>_′_</sup> 0 <sup>:= Combine</sup> <sup>_j−_</sup> <sup>1(</sup> <sup>_{e_</sup> <sup>0</sup> <sup>_, . . ., e_</sup> 2 <sup>_j−_</sup> <sup>1</sup> _−_ 1 <sup>_}, ζ, v_</sup> <sup>)</sup>



_e_ <sup>_′_</sup> 1 <sup>:= Combine</sup> <sup>_j−_</sup> <sup>1(</sup> <sup>_{e_</sup> 2 <sup>_j−_</sup> <sup>1</sup> <sup>_, . . ., e_</sup> 2 <sup>_j_</sup> _−_ 1 <sup>_}, ζ, v · ξ_</sup> <sup>)</sup> <sup>_._</sup>



Here is below the proof of correctness of this recursive relation.


**Initial** **case.** When _j_ = 1, we directly get that


Combine1( _{e_ 0 _, e_ 1 _}, ζ, v_ ) := ( _e_ 0 + _e_ 1) + _ζ · v_ <sup>_−_</sup> <sup>1</sup> _·_ ( _e_ 0 _−_ _e_ 1) _._


**Induction.** Let us take _j_ _>_ 1. By induction assumption, we have



2 <sup>_j−_</sup> <sup>1</sup> _−_ 1

- ( _ξ_ <sup>_−_</sup> <sup>rev(</sup> <sup>_k_</sup> <sup>)</sup> ) <sup>_q_</sup> _· ek_


_k_ =0




- _q_

_·_



_e_ <sup>_′_</sup> 0 <sup>=</sup>




- _<u>ζ</u>_

_v_



( _ξ_ <sup>_−_</sup> <sup>rev(</sup> <sup>_k_</sup> <sup>)</sup> ) <sup>_q_</sup> _· e_ 2 _j−_ 1+ _k_




- _q_

_·_



2 <sup>_j−_</sup> <sup>1</sup> _−_ 1

 

_k_ =0



_e_ <sup>_′_</sup> 1 <sup>=</sup>


=



2 <sup>_j−_</sup> <sup>1</sup> _−_ 1



_q_ =0


2 <sup>_j−_</sup> <sup>1</sup> _−_ 1



_q_ =0


2 <sup>_j−_</sup> <sup>1</sup> _−_ 1



_q_ =0




- _<u>ζ</u>_
_v · ξ_




- _<u>ζ</u>_

_v_



2 <sup>_j_</sup> _−_ 1

- ( _ξ_ <sup>_−_</sup> <sup>rev(</sup> <sup>_k_</sup> <sup>)</sup> ) <sup>_q_</sup> _· ek_

_k_ =2 <sup>_j−_</sup> <sup>1</sup>




- _q_

_·_



since _ξ_ <sup>rev(</sup> <sup>_k_</sup> <sup>)</sup> _· ξ_ = _ξ_ <sup>rev(</sup> <sup>_k_</sup> <sup>+2</sup> <sup>_j−_</sup> <sup>1)</sup> . We then get



2 <sup>_j_</sup> _−_ 1



_k_ =0



( _ξ_ <sup>_−_</sup> <sup>rev(</sup> <sup>_k_</sup> <sup>)</sup> ) <sup>_q_</sup> _· ek_



_e_ <sup>_′_</sup> 0 <sup>+</sup> <sup>_e′_</sup> 1 <sup>=</sup>



2 <sup>_j−_</sup> <sup>1</sup> _−_ 1

- - _<u>ζ</u>_

_v_

_q_ =0




- _q_

_·_



2 <sup>_j_</sup> _−_ 1

- ( _ξ_ <sup>_−_</sup> <sup>rev(</sup> <sup>_k_</sup> <sup>)</sup> ) <sup>2</sup> <sup>_j−_</sup> <sup>1+</sup> <sup>_q_</sup> _· ek_


_k_ =0



_e_ <sup>_′_</sup> 0 <sup>_−_</sup> <sup>_e′_</sup> 1 <sup>=</sup>



2 <sup>_j−_</sup> <sup>1</sup> _−_ 1



_q_ =0




- _<u>ζ</u>_ - _q_

_·_

_v_



Page 57/59


Code review of the Cairo implementation of the STARK/Cairo verifier



since ( _ξ_ <sup>_−_</sup> <sup>rev(</sup> <sup>_k_</sup> <sup>)</sup> ) <sup>2</sup> <sup>_j−_</sup> <sup>1+</sup> <sup>_q_</sup> = ( _ξ_ <sup>_−_</sup> <sup>rev(</sup> <sup>_k_</sup> <sup>)</sup> ) <sup>2</sup> <sup>_j−_</sup> <sup>1</sup> _·_ ( _ξ_ <sup>_−_</sup> <sup>rev(</sup> <sup>_k_</sup> <sup>)</sup> ) <sup>_q_</sup> =


we can deduce that



�( _ξ_ <sup>_−_</sup> <sup>rev(</sup> <sup>_k_</sup> <sup>)</sup> ) <sup>_q_</sup> if _k_ _<_ 2 <sup>_j−_</sup> <sup>1</sup>

_−_ ( _ξ_ <sup>_−_</sup> <sup>rev(</sup> <sup>_k_</sup> <sup>)</sup> ) <sup>_q_</sup> if _k_ _≥_ 2 <sup>_j−_</sup> <sup>1 .</sup> <sup>Finally,</sup>




              - _<u>ζ</u>_

Combine2( _{e_ <sup>_′_</sup> 0 <sup>_, e_</sup> 1 <sup>_′_</sup> <sup>_}, ζ_</sup> <sup>2</sup> <sup>_j−_</sup> <sup>1</sup> <sup>_, v_</sup> <sup>2</sup> <sup>_j−_</sup> <sup>1) = (</sup> <sup>_e′_</sup> 0 <sup>+</sup> <sup>_e_</sup> 1 <sup>_′_</sup> <sup>) +</sup>

_v_



�2 _j−_ 1

_·_ ( _e_ <sup>_′_</sup> 0 <sup>_−_</sup> <sup>_e_</sup> <sup>1)</sup>



2 <sup>_j_</sup> _−_ 1



_k_ =0



=



2 <sup>_j_</sup> _−_ 1



_q_ =0




- _<u>ζ</u>_ - _q_

_·_

_v_



( _ξ_ <sup>_−_</sup> <sup>rev(</sup> <sup>_k_</sup> <sup>)</sup> ) <sup>_q_</sup> _· ek_



= Combine _j_ ( _{e_ 0 _, . . ., e_ 2 _j_ _−_ 1 _}, ζ, v_ ) _._

### B Diluted component product


The file `diluted.cairo` provides a function `get_diluted_prod` which computes the diluted
component product used for the layout constraints of the bitwise builtin. More precisely,
given ( _n,_ `spacing` _, z, α_ ), it computes the term _r_ 2 <sup>_n_</sup> of the sequence


       _r_ 1 = 1
_∀j, rj_ +1 = _rj_ _·_ (1 + _z · uj_ ) + _α · u_ <sup>2</sup> _j_


where _u_ 1 = 1 and

_∀j_ := 2 <sup>_i_</sup> _·_ (2 _k_ + 1) _,_ _uj_ = _u_ 2 _i_ = _u_ 2 _i−_ 1 + 2 <sup>_i·_</sup> <sup>`spacing`</sup> _−_ 2 <sup>(</sup> <sup>_i−_</sup> <sup>1)</sup> <sup>_·_</sup> <sup>`spacing`</sup> <sup>+1</sup>

= _u_ 2 _i−_ 1 + 2 <sup>(</sup> <sup>_i−_</sup> <sup>1)</sup> <sup>_·_</sup> <sup>`spacing`</sup> _·_ (2 <sup>`spacing`</sup> _−_ 2) _._


We have for all _j_,



2 <sup>_j_</sup> _−_ 1

- (1 + _z · uℓ_ ))


_ℓ_ = _k_ +1



2 <sup>_j_</sup> _−_ 1



_k_ =1



( _u_ <sup>2</sup> _k_ <sup>_·_</sup>



_r_ 2 _j_ =



2 <sup>_j_</sup> _−_ 1



_k_ =1



(1 + _z · uk_ ) + _α ·_



_._




<u>�</u> <u>��</u> <u>�</u>
_pj_ := _..._




<u>�</u> <u>��</u> <u>�</u>
_qj_ := _..._



For _k_ _∈{_ 2 <sup>_j_</sup> + 1 _, . . .,_ 2 <sup>_j_</sup> <sup>+1</sup> _−_ 1 _}_, we have _uk_ = _uk−_ 2 _j_ (since _ui_ only depends on the number
of trailing zeros in the binary representation of _i_ ), and so we have



2 <sup>_j_</sup> <sup>+1</sup> _−_ 1

 - (1 + _z · uk_ ) = _pj._


_k_ =2 <sup>_j_</sup> +1


Page 58/59


Code review of the Cairo implementation of the STARK/Cairo verifier



Thus, we get


_pj_ +1 = _pj_ _·_ (1 _−_ _z · u_ 2 _j_ ) _· pj_



2 <sup>_j_</sup> <sup>+1</sup> _−_ 1

 

_ℓ_ = _k_ +1



2 <sup>_j_</sup> <sup>+1</sup> _−_ 1

 

_ℓ_ = _k_ +1








 _u_ <sup>2</sup> _k_ <sup>_·_</sup>






(1 + _z · uℓ_ )





 _u_ <sup>2</sup> _k_ <sup>_·_</sup>








<sup>2</sup> 2 <sup>_j_</sup> <sup>_· pj_</sup> <sup>+</sup>



_qj_ +1 =



2 <sup>_j_</sup> _−_ 1



_k_ =1



(1 + _z · uℓ_ )



 + _u_ <sup>2</sup> 2



2 <sup>_j_</sup> <sup>+1</sup> _−_ 1



_k_ =2 <sup>_j_</sup> +1


2 <sup>_j_</sup> _−_ 1

 

_ℓ_ = _k_ +1





 _u_ <sup>2</sup> _k_ <sup>_·_</sup>



= _qj_ _·_ (1 + _z · u_ 2 _j_ ) _· pj_ + _u_ <sup>2</sup> 2 <sup>_j_</sup> <sup>_· pj_</sup> <sup>+</sup>



2 <sup>_j_</sup> _−_ 1



_k_ =1



(1 + _z · uℓ_ )



(1 + _z · uℓ_ )



= _qj_ _·_ (1 + _z · u_ 2 _j_ ) _· pj_ + _u_ <sup>2</sup> 2 <sup>_j_</sup> <sup>_· pj_</sup> <sup>+</sup> <sup>_qj_</sup>



with ( _p_ 0 _, q_ 0) = (1 _,_ 0) and ( _p_ 1 _, q_ 1) = (1 + _z,_ 1).


Let us denote _n_ the value of `n_bits` when calling `get_diluted_prod` . Then the auxiliary
function `get_diluted_prod_inner` takes as input


  - a counter _c_,


  - the term `diff_x` _n−c_ of the sequence `diff_x` _i_ := 2 <sup>(</sup> <sup>_i−_</sup> <sup>1)</sup> <sup>_·_</sup> <sup>`spacing`</sup> _·_ (2 <sup>`spacing`</sup> _−_ 2),


  - the term `x` _n−c_ := _u_ 2 _n−c−_ 1,


  - the term _pn−c_,


  - the term _qn−c_,


computes


`x` _n−c_ +1 = `x` _n−c_ + `diff_x` _n−c_
`diff_x` _n−c_ +1 = `diff_x` _n−c ·_ `diff_multiplier`

_pn−c_ +1 = _pn−c ·_ ( _pn−c_ + _z ·_ `x` _n−c_ +1 _· pn−c_ )

_qn−c_ +1 = _qn−c ·_ ( _pn−c_ + _z ·_ `x` _n−c_ +1 _· pn−c_ ) + `x` _n−c_ +1 _·_ ( `x` _n−c_ +1 _· pn−c_ ) + _qn−c_


and outputs

( _pn, qn_ )


after doing a recursive call. Finally, the function `get_diluted_prod` outputs


_pn_ + _α · qn_


which corresponds to the desired value.


Page 59/59


