# **Smart Contract Audit Report**
## **Conducted by CryptoExperts**

As part of our due process, we retained CryptoExperts to review the design document and

related source code of the EVM STARK Verifier. We chose to work with CryptoExperts based

on warm recommendations and our interaction with them.


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


2


17


7


**27**


Code Review of StarkWare’s EVM STARK Verifier

### Contents


**1** **Introduction** **4**
1.1 Overview of the code . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4
1.2 Methodology and summary of findings . . . . . . . . . . . . . . . . . . . . . 5


**2** **Specifications** **of** **APIs** **and** **data** **formats** **7**
2.1 Notions and notations . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 7
2.2 Merkle commitment scheme . . . . . . . . . . . . . . . . . . . . . . . . . . . 10
2.2.1 Merkle queue . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 10
2.2.2 Trace commitments . . . . . . . . . . . . . . . . . . . . . . . . . . . 11
2.2.3 Layer polynomial commitments . . . . . . . . . . . . . . . . . . . . . 11
2.3 FRI protocol . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 11
2.3.1 Scaling . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 11
2.3.2 FRI context . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 12
2.3.3 FRI queue . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 13
2.4 STARK verifier . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 14
2.4.1 Parameters . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 14
2.4.2 Proof format . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 14
2.4.3 Verifier context . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 15
2.5 External dependencies . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 16
2.5.1 Memory mapping contract . . . . . . . . . . . . . . . . . . . . . . . . 16
2.5.2 OODS contract . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 17
2.5.3 Derived STARK verifier contract . . . . . . . . . . . . . . . . . . . . 17


**3** **Review** **and** **specific** **observations** **19**
3.1 Arithmetic primitives . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 19
3.1.1 Contract `PrimeFieldElement0` . . . . . . . . . . . . . . . . . . . . . 19
3.1.2 Contract `HornerEvaluator` . . . . . . . . . . . . . . . . . . . . . . . 20
3.2 Verifier channel . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 21
3.2.1 Contract `Prng` . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 21
3.2.2 Contract `VerifierChannel` . . . . . . . . . . . . . . . . . . . . . . . 22
3.3 Merkle trees . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 24
3.3.1 Contract `IMerkleVerifier` . . . . . . . . . . . . . . . . . . . . . . . 24
3.3.2 Contract `MerkleVerifier` . . . . . . . . . . . . . . . . . . . . . . . . 25
3.3.3 Contract `MerkleStatementContract` . . . . . . . . . . . . . . . . . . 26
3.3.4 Contract `MerkleStatementVerifier` . . . . . . . . . . . . . . . . . . 27
3.4 FRI protocol . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 27
3.4.1 Contract `FriLayer` . . . . . . . . . . . . . . . . . . . . . . . . . . . . 27
3.4.2 Contract `Fri` . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 31
3.4.3 Contract `FriStatementContract` . . . . . . . . . . . . . . . . . . . . 31
3.4.4 Contract `FriStatementVerifier` . . . . . . . . . . . . . . . . . . . . 32
3.5 STARK verifier . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 34


Page 2/44


Code Review of StarkWare’s EVM STARK Verifier


3.5.1 Contract `StarkVerifier` . . . . . . . . . . . . . . . . . . . . . . . . . 34


**4** **General** **observations** **38**


**A** **Formal** **checking** **of** `doXFriSteps` **44**


Page 3/44


Code Review of StarkWare’s EVM STARK Verifier

### 1 Introduction


StarkWare is a company <u>developing</u> scalability and privacy technologies for blockchain
applications. In particular, StarkWare develops a STARK-powered level-2 scalability
engine which uses cryptographic proofs to attest to the validity of a batch of transactions.
In this context, StarkWare was seeking for a code review of their STARK verifier in order
to verify its correct implementation and its compliance to the protocol specification. The
code of the STARK verifier to be reviewed is written in Solidity language and composed
of 14 smart contract source files.

Upon business agreement, with StarkWare, CryptoExperts conducted the audit
of the code in November and December 2021. The service consisted in a study of the
protocol specification and a review of the code by two engineers, experts in cryptography.
The present report contains the results of this audit.

We first give an overview of the code (Section 1.1) and a summary of the audit methodology and findings (Section 1.2). Then we specify some APIs and data formats which were
necessary for the good understanding of the code (Section 2). Our review of the different
smart contracts is depicted in Section 3, including for each of them a summary of the
functionality and a list of observations and recommendations. General observations and
recommendations (which affect several contracts) are finally provided in Section 4.

#### 1.1 Overview of the code


Figure 1: The inheritance relations between the smart contracts of the STARK verifier.


Page 4/44


Code Review of StarkWare’s EVM STARK Verifier


The audited code implements the STARK verifier of StarkWare’s scalability engine.
It is composed of the 14 source files from the following GitHub repository:

```
     https://github .co m/starkware-libs/starkex-contracts/tree/
 0efa9ce324b04226de5dcd7a0139b109bca8f074/evm-verifier/solidity/contracts

```

The audited version of the code corresponds to the commit “StarkEx v4.0”, from October
14th, 2021.
The different smart contracts are represented in Figure 1 with their inheritance relations. The contract in green is out of the scope of the present audit. The contracts in
yellow are auto-generated and out of the scope of the audit.

#### 1.2 Methodology and summary of findings


The main goal of this audit was to validate the soundness of the reviewed implementation
of the STARK verifier. More precisely, this audit aims


  - to confirm that the implemented verification process is compliant to the specification
of the STARK verifier,


  - to check the absence of flaw in the implementation which would allow an adversary to
forge a valid proof for an invalid statement (with less effort than the target security
level).


The audit methodology consisted in an in-depth review of the code by two different persons (engineers, junior and senior experts in cryptography), confronting our understanding
of the code and keeping track of our observations. We did not rely on automatic tools or
re-implementation (with one exception depicted in Section 3.4.1).


Our observations are categorized as follows:


  - Observations that may impact the soundness of the verifier, rated as


**–** high risk (flagged G),


**–** medium risk (flagged G),


**–** low risk (flagged G).


  - Observations related to coding practices and implementation choices (flagged G).


**–** These observations do not translate into a direct risk on the soundness of the

verifier but addressing them would make the code clearer, more efficient and/or
less prone to errors.


  - Observations related to documentation, comments, variable naming (flagged ■).


**–** These observations do not translate into a direct risk on the soundness of the

verifier but addressing them would facilitate the understanding of the code by
third parties (users, developers, auditors).


Page 5/44


Code Review of StarkWare’s EVM STARK Verifier


Each observation comes with an associated recommendation to fix or improve the underlying issue.


_Summary_ _of_ _findings._ As a ~~gen~~ eral remark, we were provided with a clear set of documentations about the STARK protocol [4, 5, 8, 9] but sometimes missed detailed specifications
for the reviewed implementation. To reach a global and confident understanding of the
implementation, we wrote down the missing specifications according to our understanding
of the code, which we include in the report (see Section 2).

Our findings are summarized in the table below. Besides observations related to coding
practices and documentation, we only made three observations with potential impact on
the verifier soundness, rated low for two of them (contract `VerifierChannel` ) and medium
for one of them (contract `Prng` ). As explained in our recommendations, these issues can
easily be addressed. Besides these points, and up to the limitations inherent to human
code review, we conclude that the code is a sound implementation of the STARK verifier.


The current version of the report is an update of our original report after counterauditing modifications from StarkWare. Each observation is appended with a status:
Resolved ( ), Partially resolved ( **_∼_** ), Unresolved ( ). Most of our recommendations have
been addressed. Unresolved or partially resolved issues are related to documentation or
coding practices which are of minor importance.


**<u>Category</u>** **<u>Number</u>** **<u>of</u>** **<u>findings</u>** **_<u>∼</u>_**

G <u>High</u> <u>risk</u> <u>0</u> <u>-</u> <u>-</u> <u>-</u>
G <u>Medium</u> <u>risk</u> <u>1</u> <u>1</u> <u>-</u> <u>-</u>
G <u>Low</u> <u>risk</u> <u>2</u> <u>2</u> <u>-</u> <u>-</u>
G <u>Coding</u> <u>practices</u> <u>17</u> <u>8</u> <u>4</u> <u>5</u>

     - <u>Documentation</u> <u>7</u> <u>3</u> <u>1</u> <u>3</u>
**<u>Total</u>** **<u>27</u>** <u>14</u> <u>5</u> <u>8</u>


Page 6/44


Code Review of StarkWare’s EVM STARK Verifier

### 2 Specifications of APIs and data formats

#### 2.1 Notions and no tat ions


We recall hereafter the notions and notations relevant to this report. We use the notations and terminology introduced in the ethSTARK documentation [10] (as well as a few
additional notations).


  - The _IOP_ _Prover_ and the _IOP_ _Verifier_ refer to the two parties of the interactive
protocol ( _i.e._ before the transformation to a non-interactive protocol).


  - The _Execution_ _Trace_ uses _W_ registers and has length _N_, where _N_ is a power of two.


  - The values in the trace cells are elements of the finite field F _p_ with _p_ a prime.


  - The _Trace_ _Evaluation_ _Domain_ is defined as a multiplicative subgroup _⟨g⟩_ of F <sup>_×_</sup> _p_ <sup>of</sup>
size _N_ .


  - Each trace column is interpreted as the _N_ point-wise evaluations of a polynomial
of degree smaller than _N_ over the trace evaluation domain. These polynomials are
referred to as the _Trace_ _Column_ _polynomials_ and are denoted by _f_ 0 _, . . ., fW_ _−_ 1.


  - An _Algebraic Intermediate Representation (AIR) Polynomial Constraint_ on the trace
(represented as a rational function) is denoted _Cj_ and is of degree _Dj_ . We denote _D_
the smallest power of two which is greater than all the constraint degrees.


  - The _Composition_ _Polynomial_ is denoted by _h_ ( _x_ ) and takes the form



_h_ ( _x_ ) =



_k_



_j_ =1



_Cj_ ( _x_ )( _αjx_ <sup>_D−Dj_</sup> <sup>_−_</sup> <sup>1</sup> + _βj_ ) (1)



where _k_ is the number of constraints. Its degree is _D−_ 1. This polynomial can decompose into _M_ 2 polynomials _h_ 0 _, . . ., hM_ 2 _−_ 1 of degree _N_ (called _Composition Polynomial_
_Trace_ ) such that



_h_ ( _x_ ) =



_M_ 2 _−_ 1



_i_ =0



_x_ <sup>_i_</sup> _hi_ ( _x_ <sup>_M_</sup> <sup>2</sup> ) _._ (2)




- To check the consistency between the execution trace and the composition polynomial
trace, _h_ is evaluated using the two above expressions in a single random point denoted
_z_ which is called the _OODS_ _point_ .


- To evaluate _h_ in the OODS point _z_ using (1), we need a set of values of the form
_fj_ ( _zg_ <sup>_s_</sup> ) which are involved in the expressions of the _{Cj_ ( _z_ ) _}j_ . This set of values is
called the _mask_ . It is denoted _{yℓ}ℓ_ and its size is denoted _M_ 1.


- To evaluate _h_ in the OODS point _z_ using (2), we need the values _hi_ ( _x_ <sup>_M_</sup> <sup>2</sup> ) for 0 _≤_
_i < M_ 2. Those values are denoted _y_ ˆ _i_ := _hi_ ( _z_ <sup>_M_</sup> <sup>2</sup> ).


Page 7/44


Code Review of StarkWare’s EVM STARK Verifier


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



_γM_ 1+ _i ·_ <sup>_<u>hi</u>_</sup> <sup><u>(</u></sup> <sup>_<u>x</u>_</sup> <sup><u>)</u></sup> <sup>_<u>−</u>_</sup> <sup>_<u>y</u>_</sup> <sup><u>ˆ</u></sup> <sup>_<u>i</u>_</sup>



where _{γ_ 0 _, . . ., γM_ 1+ _M_ 2 _−_ 1 _}_ are random coefficients sampled by the IOP verifier, called
_OODS_ _Coefficients_ .


- To achieve a secure protocol, the polynomials _f_ 0 _, . . ., fW_ _−_ 1 and _h_ 0 _, . . ., hM_ 2 _−_ 1 are
evaluated over a domain _L_ 0, larger than and disjoint from the trace evaluation domain, which we call the _evaluation_ _domain_ . We refer to this evaluation as _the_ _trace_
_Low_ _Degree_ _Extension_ _(LDE)_ and the ratio _|L_ 0 _|/N_ (ratio between the size of the
evaluation domain and the size of the trace evaluation domain) is further referred to
as the _blowup_ _factor_, denoted _β_ . In practice, _L_ 0 is a non-unit coset _c_ lde _· ⟨g_ lde _⟩_ of
the multiplicative subgroup _⟨g_ lde _⟩⊆_ F <sup>_×_</sup> _p_ <sup>of</sup> <sup>size</sup> <sup>_βN_</sup> <sup>.</sup>


- The FRI protocol is composed of different _layers_ . We denote _K_ the number of FRI
layers. Except for the last one, each layer performs a number of _FRI_ _steps_ . For
the _i_ th layer, the number of steps is denoted _ℓi_, which is stored in a list denoted
`fri_step_list[]` . Namely,


_ℓi_ := `fri_step_list[` _i_ `]` _._


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



Page 8/44


Code Review of StarkWare’s EVM STARK Verifier


- The polynomial _p_ 0 at the input of the FRI protocol is the DEEP composition polynomial and we have, for _i ≥_ 0,

deg _pi_ = <sup>_<u>N</u>_</sup>

2 <sup>_si_</sup>

where _si_ is defined as above.


- All the coefficients of the final polynomial _pK−_ 1 are sent to the IOP Verifier.


- Once the polynomials _{pi}i_ committed, the FRI protocol evaluates these polynomials
on a set of evaluation points, called _queries_ . The set of queries for the polynomial _pi_
is denoted _Qi_ _⊂_ _Li_, and for every _i ≥_ 1, we have



_Qi_ :=




- _x_ <sup>2</sup> <sup>_ℓi_</sup> _, x ∈Qi−_ 1�



where _Q_ 0 _⊆_ _L_ 0 is the set of random queries sampled by the IOP verifier at the
beginning of the query phase of the FRI protocol.


- Each element _x_ of _Li_ has an index index _i_ ( _x_ ) defined such as




- _·_ - _g_ lde <sup>2</sup> <sup>_si_</sup>




- _·_ - _g_ lde <sup>2</sup> <sup>_si_</sup>




- _e_
_⇐⇒_ index _i_ ( _x_ ) = bit-reverselog2 _|Li|_ ( _e_ )



_x_ =




- _c_ <sup>2</sup> lde <sup>_si_</sup>



where bit-reverselog2 _|Li|_ ( _e_ ) stands for the bit reverse of the exponent _e_ on log2 _|Li|_ =
log2( _β · N_ ) _−_ _si_ bits. We further denote


index _i_ ( _x_ ) := index _i_ ( _x_ ) + _|Li|_ _._


- We introduce the _scaled_ versions of several FRI notions. For all 0 _≤_ _i ≤_ _K −_ 1,




**–** the _scaled_ layer polynomial _p_ <sup>_′_</sup> _i_




<sup>_′_</sup> _i_ <sup>(</sup> <sup>_x_</sup> <sup>)</sup> <sup>is</sup> <sup>defined</sup> <sup>as</sup> <sup>_p′_</sup> _i_




<sup>_′_</sup> _i_ <sup>(</sup> <sup>_x_</sup> <sup>) :=</sup> <sup>_pi_</sup> <sup>(</sup> <sup>_c_</sup> <sup>2</sup> lde <sup>_si_</sup>




<sup>2</sup> lde <sup>_si_</sup> <sup>_· x_</sup> <sup>);</sup>




**–** the scaled layers polynomials _p_ <sup>_′_</sup> _i_




<sup>_′_</sup> _i−_ 1 <sup>and</sup> <sup>_p′_</sup> _i_



the scaled layers polynomials _p_ <sup>_′_</sup> _i−_ 1 <sup>and</sup> <sup>_p′_</sup> _i_ <sup>verify</sup> <sup>a</sup> <sup>similar</sup> <sup>relation</sup> <sup>than</sup> <sup>in</sup> <sup>the</sup>

Equation 3 but for the _scaled_ challenges defined as




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



_Remark._ In the above notations, the following are not from [10] but introduced for the
purpose of the present report: _si_, _ℓi_, _K_, index _i_ ( _x_ ), _c_ lde, _g_ lde _, Qi_ and all the scaled notions.


Page 9/44


Code Review of StarkWare’s EVM STARK Verifier

#### 2.2 Merkle commitment scheme


All the commitments in the protocol are realized thanks to Merkle trees. This structure
enables to commit several i ~~np~~ uts as leaves of the tree to get a single commitment value
(the root of the tree). Then, it is possible to show the consistence of a small subset of
the revealed inputs with the committed root without having to communicate all the other
inputs. The principle is to reveal the sibling paths of the revealed inputs in the Merkle
tree.

In the STARK verifier, only _complete_ Merkle trees are used, _i.e._ Merkle trees with
2 <sup>_n_</sup> leaves for some _n_ _∈_ N. Moreover, only the verification primitive is implemented: the
STARK verifier does not need to commit but only to decommit data.


2.2.1 Merkle queue


The implementation uses a structure called a _Merkle queue_ . It is a _circular_ queue containing
some nodes of the tree (leaves and internal nodes). At the beginning of the verification the
queue only contains the decommitted leaves. Along the verification, the queue is fed with
the encountered nodes on the Merkle paths to the decommitted leaves (either computed
from previous queue elements or fetched from the proof).


Each node is represented by a pair composed of


  - The index of the node, which is stored on 32 bytes. The nodes of depth _i_ have
indexes 2 <sup>_i_</sup>, ..., 2 <sup>_i_</sup> <sup>+1</sup> _−_ 1. Thus the root has index “1” and the leave indexes are
_{_ 2 <sup>_n_</sup> _, . . . .,_ 2 <sup>_n_</sup> <sup>+1</sup> _−_ 1 _}_ .


  - The label of the node in the Merkle tree ( _i.e._ the hash of the child nodes for a internal
node or a hash digest of one committed value), which is stored on 32 bytes.


By definition of a Merkle tree, the label corresponding to index _i_ is defined as


label _i_ := Hash(label2 _i_ _∥_ label2 _i_ +1) _,_


for internal nodes and



label2 <sup>_n_</sup> + _i_ :=



�Hash(input _i_ ) if input _i_ is bigger than 256 bits
input _i_ otherwise



for leaves, where input0, . . ., input2 _n−_ 1 are the 2 <sup>_n_</sup> inputs of the tree. The used hash function
Hash( _·_ ) is Keccack-256 truncated to the 160 most significant bits.


The nodes in the Merkle queue must respect the following order:


  - All the present nodes of the same depth must be contiguous in the queue and must
have their indices in the increasing order;


  - A node of depth _i_ must be before a node of depth _j_ if _i > j_ .


Page 10/44


Code Review of StarkWare’s EVM STARK Verifier



2.2.2 Trace commitments


In the STARK protocol, two Merkle trees are used to commit traces: the _Execution_ _Trace_
_f_ 0 _, . . ., fW_ _−_ 1 and the _Comp_ _~~osit~~_ _ion_ _Polynomial_ _Trace_ _h_ 0 _, . . ., hM_ 2 _−_ 1 which are both defined
on the _Low_ _Degree_ _Extension_ _L_ 0 of size _β · N_ .

The leaves of the corresponding Merkle are defined as follow:


  - For the Execution Trace:


input _i_ = _f_ 0( _x_ ) _||_ _f_ 1( _x_ ) _|| . . . ||_ _fW_ _−_ 1( _x_ ) where _x ∈_ _L_ 0 _,_ index0( _x_ ) = _i_


  - For the Composition Trace:


input _i_ = _h_ 0( _x_ ) _||_ _h_ 1( _x_ ) _|| . . . ||_ _hM_ 2 _−_ 1( _x_ ) where _x ∈_ _L_ 0 _,_ index0( _x_ ) = _i_


_Remark._ If the _Randomized_ _AIR_ _with_ _Preprocessing_ [7] is used, the execution trace is
committed in two times, using two Merkle trees (instead of a single one). The first tree
contains the trace columns committed before the additional round, and the second tree
contains the remaining trace columns.


2.2.3 Layer polynomial commitments


In the FRI protocol, a polynomial _pi_ is committed at the layer _i_ + 1 (except for the last
layer). The evaluation domain for the commitment of _pi_ is _Li_ . To compute an evaluation
of _pi_ +1 for a point of _Li_ +1 using the Equation (3), one needs 2 <sup>_ℓi_</sup> <sup>+1</sup> evaluations of _pi_ . Thus
these evaluations are committed together. The commitment of _pi_ is realized thanks to a
Merkle tree with 2 _<u>|</u>_ <sup>_ℓi_</sup> _<u>L</u>_ <sup>+1</sup> _<u>i|</u>_ <sup>leaves,</sup> <sup>and</sup> <sup>the</sup> <sup>corresponding</sup> <sup>leaves</sup> <sup>are</sup> <sup>defined</sup> <sup>as</sup> <sup>follows:</sup>


input _j_ = _pi_ ( _x_ 0) _||_ _pi_ ( _x_ 1) _|| . . . ||_ _pi_ ( _x_ 2 _ℓi_ +1 _−_ 1)


where

_xk_ _∈_ _Li_ and index _i_ ( _xk_ ) = _j ·_ 2 <sup>_ℓi_</sup> <sup>+1</sup> + _k_ _._

#### 2.3 FRI protocol


The implementation of the FRI verification process is based on a trick that we call _scaling_
(explained in Section 2.3.1) and it makes use of two data structures: the _FRI_ _context_
(specified in Section 2.3.2) and the _FRI_ _queue_ (specified in Section 2.3.3).


2.3.1 Scaling


Instead of performing the standard FRI protocol on the DEEP composition polynomial
_p_ 0, the implementation runs the protocol on the _scaled_ _DEEP_ _composition_ _polynomial_ _p_ <sup>_′_</sup> 0

(see Section 2.1 for the definition of scaled notions). This choice enables to avoid all the
offsets - _c_ <sup>2</sup> lde <sup>_si_</sup> 
_i_ <sup>of</sup> <sup>the</sup> <sup>evaluation</sup> <sup>domains</sup> <sup>_{Li}i_</sup> <sup>.</sup> <sup>Instead,</sup> <sup>the</sup> <sup>protocol</sup> <sup>is</sup> <sup>performed</sup> <sup>on</sup> <sup>the</sup>




- _c_ <sup>2</sup> lde <sup>_si_</sup>







offsets - _c_ <sup>2</sup> lde <sup>_si_</sup> 
_i_ <sup>of</sup> <sup>the</sup> <sup>evaluation</sup> <sup>domains</sup> <sup>_{Li}i_</sup> <sup>.</sup> <sup>Instead,</sup> <sup>the</sup> <sup>protocol</sup> <sup>is</sup> <sup>performed</sup> <sup>on</sup> <sup>the</sup>
scaled evaluation domains _{L_ <sup>_′_</sup> _i_ <sup>_}_</sup> <sup>which</sup> <sup>are</sup> <sup>subgroups</sup> <sup>of</sup> <sup>F</sup> <sup>_×_</sup> _p_ <sup>easier</sup> <sup>to</sup> <sup>handle.</sup>



lde




<sup>_′_</sup> _i_ <sup>_}_</sup> <sup>which</sup> <sup>are</sup> <sup>subgroups</sup> <sup>of</sup> <sup>F</sup> <sup>_×_</sup> _p_




<sup>_×_</sup> _p_ <sup>easier</sup> <sup>to</sup> <sup>handle.</sup>



Page 11/44


Code Review of StarkWare’s EVM STARK Verifier



This change of representation does not impact the commitments defined in Section 2.2.3,
since _p_ <sup>_′_</sup> _i_ <sup>(</sup> <sup>_x′_</sup> <sup>) =</sup> <sup>_pi_</sup> <sup>(</sup> <sup>_x_</sup> <sup>)</sup> <sup>whenever</sup> <sup>_x_</sup> <sup>=</sup> <sup>_x′ · c_</sup> <sup>2</sup> lde <sup>_si_</sup> <sup>(with</sup> <sup>_x ∈_</sup> <sup>_Li_</sup> <sup>and</sup> <sup>_x′_</sup> <sup>_∈_</sup> <sup>_L_</sup> _i_ <sup>_′_</sup> <sup>).</sup> <sup>It</sup> <sup>only</sup> <sup>implies</sup> <sup>that</sup>




<sup>_′_</sup> _i_ <sup>(</sup> <sup>_x′_</sup> <sup>) =</sup> <sup>_pi_</sup> <sup>(</sup> <sup>_x_</sup> <sup>)</sup> <sup>whenever</sup> <sup>_x_</sup> <sup>=</sup> <sup>_x′ · c_</sup> <sup>2</sup> lde <sup>_si_</sup>




<sup>2</sup> lde <sup>_si_</sup> <sup>(with</sup> <sup>_x ∈_</sup> <sup>_Li_</sup> <sup>and</sup> <sup>_x′_</sup> <sup>_∈_</sup> <sup>_L_</sup> _i_ <sup>_′_</sup>



since _p_ <sup>_′_</sup> _i_ <sup>(</sup> <sup>_x′_</sup> <sup>) =</sup> <sup>_pi_</sup> <sup>(</sup> <sup>_x_</sup> <sup>)</sup> <sup>whenever</sup> <sup>_x_</sup> <sup>=</sup> <sup>_x′ · c_</sup> <sup>2</sup> lde <sup>_si_</sup> <sup>(with</sup> <sup>_x ∈_</sup> <sup>_Li_</sup> <sup>and</sup> <sup>_x′_</sup> <sup>_∈_</sup> <sup>_L_</sup> _i_ <sup>_′_</sup> <sup>).</sup> <sup>It</sup> <sup>only</sup> <sup>implies</sup> <sup>that</sup>

the IOP verifier samples scaled challenges _{ζi_ <sup>_′}i_</sup> <sup>instead</sup> <sup>of</sup> <sup>_{ζi}i_</sup> <sup>(but</sup> <sup>the</sup> <sup>two</sup> <sup>distributions</sup>



the IOP verifier samples scaled challenges _{ζi_ <sup>_′}i_</sup> <sup>instead</sup> <sup>of</sup> <sup>_{ζi}i_</sup> <sup>(but</sup> <sup>the</sup> <sup>two</sup> <sup>distributions</sup>

are actually equivalent) and that the IOP prover sends the scaled version of the last layer
polynomial _p_ <sup>_′_</sup> _K−_ 1 <sup>(instead</sup> <sup>of</sup> <sup>_pK−_</sup> <sup>1).</sup>




<sup>_′_</sup> _K−_ 1 <sup>(instead</sup> <sup>of</sup> <sup>_pK−_</sup> <sup>1).</sup>



2.3.2 FRI context


The FRI context is a data structure which contains three different lists. The two last lists
contain elements which are computed once for all at the beginning of the verification. The
first list is the only one to be updated along the proof verification. The three lists are
described hereafter:


  - The _FRI_ _evaluations_ . This list contains the 2 <sup>_ℓi_</sup> <sup>+1</sup> evaluations


_{pi_ ( _v ξ_ <sup>_j_</sup> ) _,_ 0 _≤_ _j_ _<_ 2 <sup>_ℓi_</sup> <sup>+1</sup> _}_ _,_


which will be used to compute _pi_ +1( _v_ <sup>2</sup> <sup>_ℓi_</sup> <sup>+1</sup> ), where _ξ_ denotes a generator of the multiplicative subgroup of F <sup>_×_</sup> _p_ <sup>of</sup> <sup>order</sup> <sup>2</sup> <sup>_ℓi_</sup> <sup>+1.</sup>

  - The _FRI_ _group_ . This is the subgroup of F <sup>_×_</sup> _p_ <sup>with</sup> <sup>2</sup> <sup>`MAX_FRI_STEP`</sup> <sup>elements,</sup> <sup>sorted</sup> <sup>in</sup>
a specific order. Let _ξ_ be a generator of this group. <sup>1</sup> Then the _i_ th element of the
group, denoted `friGroup[` _i_ `]`, is defined as


`friGroup[` _i_ `]` := _ξ_ <sup>_e_</sup> _⇐⇒_ _i_ = bit-reverse `MAX_FRI_STEP` ( _e_ ) _._


Figure 2: The FRI group when `MAX_FRI_STEP` = 4.


Figure 2 represents this group for `MAX_FRI_STEP` = 4 (the current choice in the
audited code). This order implies the two following properties:


1In the code, this generator is implemented via the constant `FriLayer.FRI_GROUP_GEN` .


Page 12/44


Code Review of StarkWare’s EVM STARK Verifier


**–** We have `friGroup[` 2 _i_ + 1 `]` = _−_ `friGroup[` 2 _i_ `]` .




**–** Let order( _·_ ) denote the multiplicative order of an element of F <sup>_×_</sup> _p_



Let order( _·_ ) denote the multiplicative order of an element of F <sup>_×_</sup> _p_ <sup>.</sup> <sup>If</sup> <sup>two</sup> <sup>group</sup>

elements _x, y_ verify order( _x_ ) _<_ order( _y_ ), then _x_ is stored before _y_ . It results that
the 2 <sup>_ℓ_</sup> first elements form the multiplicative subgroup of F <sup>_×_</sup> _p_ <sup>with</sup> <sup>2</sup> <sup>_ℓ_</sup> <sup>elements,</sup>



the 2 <sup>_ℓ_</sup> first elements form the multiplicative subgroup of F <sup>_×_</sup> _p_ <sup>with</sup> <sup>2</sup> <sup>_ℓ_</sup> <sup>elements,</sup>

for any 0 _≤_ _ℓ_ _≤_ `MAX_FRI_STEP` .




  - The _FRI_ _half_ _group_ _of_ _inverses_ . This list contains half of the inverse elements from
the previous list:

<u>1</u>
`friHalfInvGroup[` _i_ `]` := `friGroup[` 2 _i_ `]` <sup>_,_</sup>


for every _i <_ 2 <sup>`MAX_FRI_STEP`</sup> <sup>_−_</sup> <sup>1</sup> .


2.3.3 FRI queue


The FRI queue is a structure which contains the FRI queries, _i.e._ evaluations of layer
polynomials which must be verified by Merkle decommitment. The FRI queue is updated
along the FRI verification process. At the beginning the queue only contains evaluations
of the DEEP composition polynomial _p_ 0. Then while processing the _i_ th layer, for _i_ from
1 to _K_ _−_ 1, the layer-( _i −_ 1) queries are replaced by layer- _i_ queries. Finally the last layer
checks the consistency of the evaluations of _pK−_ 1 present in the queue at the end.

A layer- _i_ FRI query corresponding to an evaluation point _v_ = _c_ <sup>2</sup> lde <sup>_si_</sup> <sup>_·_</sup> <sup>_g_</sup> _i_ <sup>_e_</sup> <sup>_∈_</sup> <sup>_Li_</sup> <sup>, with scaled</sup>

value _v_ <sup>_′_</sup> = _gi_ <sup>_e_</sup> <sup>_∈_</sup> <sup>_L_</sup> _i_ <sup>_′_</sup> <sup>,</sup> <sup>is</sup> <sup>represented</sup> <sup>as</sup> <sup>a</sup> <sup>triplet</sup>



A layer- _i_ FRI query corresponding to an evaluation point _v_ = _c_ <sup>2</sup> lde <sup>_si_</sup>



_i_ <sup>_e_</sup> <sup>_∈_</sup> <sup>_L_</sup> _i_ <sup>_′_</sup>




<sup>2</sup> lde <sup>_si_</sup> <sup>_·_</sup> <sup>_g_</sup> _i_ <sup>_e_</sup>



_i_ <sup>_′_</sup> <sup>,</sup> <sup>is</sup> <sup>represented</sup> <sup>as</sup> <sup>a</sup> <sup>triplet</sup>



�index _i_ ( _v_ ) _, pi_ ( _v_ ) _,_ 1 _/v_ <sup>_′_</sup> )


where (as introduced in Section 2.1)


index _i_ ( _v_ ) = index _i_ ( _v_ ) + _|Li|_ = bit-reverselog _|Li|_ ( _e_ ) + _|Li|_ _._


Each element of the FRI query triplet is stored on 32 bytes.


_Remark._ There are several reasons to keep index _i_ ( _v_ ) instead of index _i_ ( _v_ ). First, it directly
gives the indexes of the corresponding Merkle leaves (let recall the leaves indexes have an
offset of 2 <sup>_n_</sup> when the Merkle tree has 2 <sup>_n_</sup> leaves) up to a shift operation. It also enables to
easily <u>identify</u> the set _Li_ to which an evaluation point belongs to (thanks to the leading
bit of index _i_ ( _v_ )).


The elements in the FRI queue must respect the following order:


  - All the present elements of the same layer must be contiguous in the queue and must
have their indices in increasing order.


  - An element belonging to the _i_ th layer must be before an element belonging to the
_j_ th layer if _i < j_ .


Page 13/44


Code Review of StarkWare’s EVM STARK Verifier

#### 2.4 STARK verifier


We specify hereafter the format and constraints underlying the implementation of the
STARK verifier (besides the ~~F~~ RI context, FRI queue, and Merkle queue, already specified
above). The STARK verifier is configured by a set of parameters which must verify some
constraints (see Section 2.4.1). It takes as input a proof and relies on a context, for which
formats are respectively specified in Section 2.4.2 and Section 2.4.3 hereafter.


2.4.1 Parameters


Besides the statement which must be proved ( _i.e._ the “public input”) and the proof itself,
the STARK verifier received a list of parameters which must verify some constraints.


**<u>Parameter</u>** **<u>Constraints</u>**

<u>The</u> <u>number</u> <u>of</u> <u>queries</u> <u>-</u>
<u>The</u> <u>logarithm</u> <u>of</u> <u>the</u> <u>blowup</u> <u>factor</u> _<u>β</u>_ <u>1</u> _<u>≤</u>_ <u>log2(</u> _<u>β</u>_ <u>)</u> _<u>≤</u>_ <u>16</u>
The number of security bits for the proof of work `minProofOfWorkBits` _≤_ _. . . ≤_ 50

_<u>. . . <</u>_ <u>`numSecurityBits`</u>
<u>The</u> <u>bound</u> <u>on</u> <u>the</u> <u>log-degree</u> <u>of</u> _<u>pK−</u>_ <u>1</u> <u>log2(deg</u> _<u>pK−</u>_ <u>1)</u> _<u>≤</u>_ <u>10</u>
<u>The</u> <u>number</u> <u>of</u> <u>FRI</u> <u>layers</u> <u>1</u> _<u>< K</u>_ _<u>≤</u>_ <u>10</u>
The number of steps for each layer `fri_step_list[` 0 `]` = 0
<u>0</u> _<u><</u>_ <u>`fri_step_list[`</u> _<u>i</u>_ <u>`]`</u> _<u>≤</u>_ <u>4</u> <u>for</u> <u>`i`</u> _<u>≥</u>_ <u>1</u>


2.4.2 Proof format


As input of the STARK verifier, the user must give the proof which will convince the
verifier about the correctness of the statement. The proof is a sequence of bytes. The type
of the proof in `StarkVerifier.verifyProof` is


`uint256[]` `memory` `proof`,


but it is manipulated as an array of bytes in the code. Specifically, the proof is the sequence
of fields which are listed in the table below. All those fields are composed of one or several
256-bit (32-byte) elements, except one: the nonce of the proof of work, which is a single
64-bit (8-byte) value. As a result, the fields succeeding the nonce are not aligned on 32
bytes. The STARK verifier parses the proof assuming it contains the elements described
in the following table.


Page 14/44


Code Review of StarkWare’s EVM STARK Verifier


**<u>Field</u>** **<u>Description</u>**

Trace Commitment Merkle root where leaves are evaluations of some trace column polyno<u>mials</u> <u>in</u> <u>the</u> <u>LDE</u> <u>(see</u> <u>Section</u> <u>2.2.2).</u>
Trace Commitment “Interactive” _Only_ _if_ _the_ _proof_ _deals_ _with_ _Randomized_ _Air_ _with_ _Preprocessing._ Merkle
root where leaves are evaluations of other trace column polynomials in
<u>the</u> <u>LDE.</u>
OODS Commitment Merkle roots where leaves are evaluations of the composition polynomial
<u>columns</u> <u>in</u> <u>the</u> <u>LDE.</u>
<u>OODS</u> <u>Values</u> <u>The</u> _<u>M</u>_ <u>1 +</u> _<u>M</u>_ <u>2</u> <u>values</u> _<u>{yℓ}ℓ</u>_ _<u>∪{y</u>_ <u>ˆ</u> _<u>i}i</u>_ <u>.</u>
FRI Commitments Merkle roots where leaves are evaluations of the layer polynomials (ex<u>cept</u> <u>the</u> <u>last</u> <u>one).</u>
Last Layer Polynomial All the coefficients of the _scaled_ last layer polynomial _p_ <sup>_<u>′</u>_</sup> _K−_ 1 <sup>, starting from</sup>

<u>the</u> <u>coefcientfi</u> <u>of</u> <u>the</u> <u>constant</u> <u>monomial.</u>
<u>Nonce</u> <u>of</u> <u>Proof</u> <u>of</u> <u>Work</u> <u>The</u> <u>nonce</u> <u>used</u> <u>to</u> <u>prove</u> <u>the</u> <u>work</u> <u>(a.k.a.</u> <u>grinding).</u> _<u>Only</u>_ _<u>64</u>_ _<u>bits.</u>_
<u>Trace</u> <u>Query</u> <u>Responses</u> <u>The</u> <u>queried</u> <u>rows</u> <u>of</u> <u>the</u> <u>trace.</u>

    - Authentication paths in the Merkle tree of the Trace Commitment to
<u>decommit</u> <u>the</u> <u>trace</u> <u>query</u> <u>responses.</u>
Trace Query Responses 2 _Only_ _if_ _the_ _proof_ _deals_ _with_ _Randomized_ _Air_ _with_ _Preprocessing._ The
<u>queried</u> <u>rows</u> <u>of</u> <u>the</u> <u>trace.</u>

    - Authentication paths in the Merkle tree of the Trace Commitment (In<u>teractive)</u> <u>to</u> <u>decommit</u> <u>the</u> <u>trace</u> <u>query</u> <u>responses.</u>
<u>Composition</u> <u>Query</u> <u>Responses</u> <u>The</u> <u>queried</u> <u>rows</u> <u>of</u> <u>the</u> <u>composition</u> <u>polynomial</u> <u>columns.</u>

    - Authentication paths in the Merkle tree of the OODS Commitment to
<u>decommit</u> <u>the</u> <u>composition</u> <u>query</u> <u>responses.</u>


_Repeat_ _the_ _two_ _last_ _rows_ _for_ _each_ _FRI_ _layer_ _(but_ _the_ _last_ _one),_ _i.e._ _for_ _layer_ _i ∈{_ 1 _, . . ., K −_ 1 _}._


Required Evaluation Values for the The missing required evaluations of _pi−_ 1 to compute the evaluations of
<u>layer</u> _<u>i</u>_ _<u>pi</u>_ <u>on</u> <u>the</u> <u>queries</u> _<u>Qi</u>_ <u>.</u>

    - Authentication paths in the Merkle tree with the _i_ th FRI Commitment
<u>as</u> <u>root</u> <u>to</u> <u>valid</u> <u>the</u> <u>Evaluation</u> <u>Values</u> <u>of</u> <u>the</u> <u>current</u> <u>layer</u> <u>(</u> _<u>i.e.</u>_ <u>layer</u> _<u>i</u>_ <u>).</u>


All the elements of F _p_ (and their commitments) in the proof are in the _Montgomery_
_form_, _i.e._ are multiplied by a coefficient _R_ which verifies


_R ≡_ 2 <sup>256</sup> mod _p_ _._


2.4.3 Verifier context


The state of the verifier, called _verifier_ _context_, is stored in a contiguous chunk of memory.
This state is an array of elements of 256 bits, and contains the fields described in the below
table. Each field is stored in a contiguous part of the state, the corresponding offsets are
given by the constants. The column “Fixed” in the table indicates if the corresponding
field contains a value which is set only once during the proof checking.


Page 15/44


Code Review of StarkWare’s EVM STARK Verifier


**<u>Constants</u>** **<u>Fixed</u>** **<u>Description</u>**
<u>`MM_BLOW_UP_FACTOR`</u> <u>The</u> <u>blowup</u> <u>factor</u> _<u>β</u>_
`MM_LOG_EVAL_DOMAIN_SIZE` The logarithm of the size of the Low Degree Extension:
<u>log2(</u> _<u>β · N</u>_ <u>)</u>
<u>`MM_EVAL_DOMAIN_SIZE`</u> <u>The</u> <u>size</u> <u>of</u> <u>the</u> <u>Low</u> <u>Degree</u> <u>Extension:</u> _<u>β · N</u>_
<u>`MM_EVAL_DOMAIN_GENERATOR`</u> <u>The</u> <u>generator</u> _<u>g</u>_ lde <u>of</u> <u>the</u> <u>Low</u> <u>Degree</u> <u>Extension.</u>
`MM_PROOF_OF_WORK_BITS` The required number of leading zeros in the proof of
<u>work.</u>
`MM_TRACE_COMMITMENT` The Merkle root for commitments of the execution
<u>trace.</u>
`MM_OODS_COMMITMENT` The Merkle root for commitments of the composition
<u>polynomial</u> <u>trace.</u>
`MM_N_UNIQUE_QUERIES` The number of queries for the first layer ( _i.e._ size of
<u>the</u> <u>set</u> _<u>Q</u>_ <u>0).</u>
`MM_CHANNEL` Pointer to the verifier channel (further pointing to the
<u>proof</u> <u>and</u> <u>the</u> <u>PRNG).</u>
`MM_MERKLE_QUEUE` The Merkle queue, which contains the values to be
<u>checked</u> <u>in</u> <u>the</u> <u>next</u> <u>decommiment</u> <u>verification.</u>
`MM_FRI_QUEUE` The FRI queue, which contains the evaluation values
<u>of</u> <u>the</u> <u>next</u> <u>layer</u> <u>polynomial.</u>
`MM_FRI_QUERIES_DELIMITER` End of the FRI queue. Used to detect the end of the
<u>FRI</u> <u>queue.</u>
<u>`MM_FRI_CTX`</u> <u>/</u> <u>The</u> <u>FRI</u> <u>context</u> <u>(see</u> <u>Section</u> <u>2.3.2).</u>
<u>`MM_FRI_STEPS_PTR`</u> <u>Pointer</u> <u>to</u> <u>the</u> <u>list</u> <u>`fri_step_list[]`</u> <u>.</u>
`MM_FRI_EVAL_POINTS` _Scaled_ coefficients _ζ_ 0 <sup>_<u>′</u>_</sup> <sup>_, . . ., ζ_</sup> _K_ <sup>_<u>′</u>_</sup> _−_ 2 <sup>used to half the current</sup>

_scaled_ layer polynomial to build the polynomial of the
<u>next</u> <u>layer.</u>
`MM_FRI_COMMITMENTS` The Merkle roots for commitments of the layer poly<u>nomials.</u>
`MM_FRI_LAST_LAYER_DEG_BOUND` The number of monomials for the scaled last layer
polynomial _p_ <sup>_′_</sup> _K−_ 1 <sup>(</sup> <sup>_i.e._</sup> <sup>the</sup> <sup>degree</sup> <sup>of</sup> <sup>this</sup> <sup>polynomial,</sup>

<u>added</u> <u>to</u> <u>1).</u>
`MM_FRI_LAST_LAYER_PTR` A pointer to the coefficients for the scaled last layer
<u>polynomial</u> _<u>p</u>_ <sup>_′_</sup> _<u>K−</u>_ <u>1</u> <sup><u>.</u></sup>

<u>`MM_TRACE_LENGTH`</u> <u>The</u> <u>trace</u> <u>length</u> _<u>N</u>_ <u>.</u>
<u>`MM_TRACE_GENERATOR`</u> <u>The</u> <u>generator</u> _<u>g</u>_ <u>of</u> <u>the</u> <u>trace</u> <u>evaluation</u> <u>domain.</u>
<u>`MM_OODS_POINT`</u> <u>The</u> <u>OODS</u> <u>point</u> _<u>z</u>_ <u>.</u>
`MM_OODS_EVAL_POINTS` The OODS Evaluation Points, _i.e._ the queries for the
<u>first</u> <u>layer</u> <u>polynomial.</u>
<u>`MM_TRACE_QUERY_RESPONSES`</u> <u>The</u> <u>trace</u> <u>values</u> <u>for</u> <u>the</u> <u>queried</u> <u>rows.</u>
`MM_COMPOSITION_QUERY_RESPONSES` The values of the composition polynomial traces for
<u>the</u> <u>queried</u> <u>rows.</u>
<u>`MM_CONTEXT_SIZE`</u> <u>The</u> <u>size</u> <u>of</u> <u>the</u> <u>verifier</u> <u>context.</u>


#### 2.5 External dependencies

2.5.1 Memory mapping contract


The memory mapping contract `MemoryMap` contains only declarations of constants which
are related to the context of the STARK verifier. This context is stored in a contiguous


Page 16/44


Code Review of StarkWare’s EVM STARK Verifier


chunk of memory, and the constants are the offsets of the different fields. Users are free to
organized the context as they want, but the offsets listed in Section 2.4.3 must be defined
by the memory mapping contract.


2.5.2 OODS contract


Let us recall that the DEEP composition polynomial is in the form



_M_ 2 _−_ 1



_i_ =0



_γM_ 1+ _i ·_ <sup>_<u>hi</u>_</sup> <sup><u>(</u></sup> <sup>_<u>x</u>_</sup> <sup><u>)</u></sup> <sup>_<u>−</u>_</sup> <sup>_<u>y</u>_</sup> <sup><u>ˆ</u></sup> <sup>_<u>i</u>_</sup> _._

_x −_ _z_ <sup>_M_</sup> <sup>2</sup>



_p_ 0( _x_ ) =



_M_ 1 _−_ 1



_ℓ_ =0



_γℓ_ _·_ <sup>_<u>fjℓ</u>_</sup> <sup><u>(</u></sup> <sup>_<u>x</u>_</sup> <sup><u>)</u></sup> <sup>_<u>−</u>_</sup> <sup>_<u>yℓ</u>_</sup> +

_x −_ _zg_ <sup>_sℓ_</sup>



Given the OODS point _z_ (sampled by the verifier), the corresponding OODS values _yℓ_
and _y_ ˆ _i_ (given by the prover), the OODS coefficients _γi_ (sampled by the verifier) and the
evaluation of _fi_ and _hi_ for the queries, the OODS contract must return the evaluations
for the queries of the DEEP composition polynomial and the inverses of all the evaluation
points.

In practice, the OODS contract is autogenerated with hardcoded DEEP composition
polynomial. This contract computes evaluations of _p_ 0 efficiently with a strategy of batching
for the inverses (the denominators of rational functions and the inverses of the evaluation
points).

No implementation of the OODS contract has been reviewed in the present audit.
However, we stress that the OODS contract must comply to some API to be compatible
with the audited STARK verifier. In particular, the OODS contract must implement a
function which takes the verifier context as input and which returns the initial FRI queue
(in which the _p_ 0 evaluations corresponding to the initial FRI queries have been filled under
the format specified in Section 2.3.3). Moreover, with the current implementation of the
STARK verifier, the evaluations of _fi_ and _hi_ in input of the OODS contract must be in
_Montgomery_ _form_ while the point _z_, the values _{yℓ}ℓ_ _∩{y_ ˆ _i}i_ and the coefficients _γi_ must
be in _standard_ _form_ . Then the OODS contract must return evaluation values of the DEEP
Composition Polynomial in the _standard_ _form_ .


2.5.3 Derived STARK verifier contract


The STARK verifier is an abstract contract. This means that to run an instance of the
STARK verifier, one must implements a derived contract and the latter must implements
the following functions:


  - `getNColumnsInTrace` : Returns the number _W_ of trace columns.


  - `getNColumnsInComposition` : Returns the number _M_ 2 of composition polynomial
trace columns.


  - `getNCoefficients` : Returns the number of coefficients _{αj}j_ _∪{βj}j_ to build the
composition polynomial from the AIR polynomial constraints.


  - `getNOodsValues` : Returns the number _M_ 1 + _M_ 2 of OODS values _{yℓ}ℓ_ _∪{y_ ˆ _i}i_ .


Page 17/44


Code Review of StarkWare’s EVM STARK Verifier


  - `getNOodsCoefficients` : Returns the number _M_ 1 + _M_ 2 of OODS coefficients _{γi}i_ .


  - `getMmCoefficients` : Returns the memory offset where the coefficients _{αj}j ∪{βj}j_
must be stored.


  - `getMmOodsValues` : Returns the memory offset where the OODS values must be
stored.


  - `getMmOodsCoefficients` : Returns the memory offset where the OODS coefficients
must be stored.


In case _Randomized_ _AIR_ _with_ _Preprocessing_ [7] is used, the following functions must
be overridden since the execution trace is computed in two rounds (instead of one):


  - `getNInteractionElements` : Returns the number of F _p_ elements that the IOP verifier
must sample between both rounds to commit the execution trace.


  - `getMmInteractionElements` : Returns the memory offset where the above elements
must be stored.


  - `getNColumnsInTrace0` : Returns the number of committed trace columns in the first
round.


  - `getNColumnsInTrace1` : Returns the number of committed trace columns in the second round (after sampling the interaction elements).


One must further implements these functions:


  - `airSpecificInit` : Creates the verifier context, of size `MM_CONTEXT_SIZE`, and initializes all the context fields which are specific to the proved statement. Must return
the logarithm (in base two) of the trace length _N_ .


  - `getPublicInputHash` : Returns the hash of the public input ( _i.e._ the statement which
must be proved). It is used to initialized the PRNG of the IOP verifier.


  - `oodsConsistencyCheck` : Checks that the OODS values are consistent, _i.e._ that the
mask _{yℓ}ℓ_ for the OODS point given by the prover is consistent with the evaluations
of the composition polynomial trace _h_ 0 _, . . ., hM_ 2 _−_ 1, and raises an error otherwise. To
proceed, the function uses the coefficients _{αj}j ∪{βj}j_ and the interaction elements
(if any).


Page 18/44


Code Review of StarkWare’s EVM STARK Verifier

### 3 Review and specific observations

#### 3.1 Arithmetic prim iti ves


3.1.1 Contract `PrimeFieldElement0`


The contract `PrimeFieldElement0` defines arithmetic functions on the field F _p_, namely
the addition ( `fadd` ), subtraction ( `fsub` ), multiplication ( `fmul` ), exponentiation ( `pow` ) and
inversion ( `inverse` ). The field prime characteristic _p_, declared as the constant `K_MODULUS`,
is defined as

_p_ = 2 <sup>251</sup> + 17 _·_ 2 <sup>192</sup> + 1 _._

As required, _p_ is a prime and the order _p −_ 1 of the multiplicative group F <sup>_×_</sup> _p_ <sup>is</sup> <sup>a</sup> <sup>multiple</sup>

of a large power of two:


_p −_ 1 = 2 <sup>192</sup> _·_ 5 _·_ 7 _·_ 98714381 _·_ 166848103


(allowing large trace length _N_ ). The implementation of the STARK verifier sometimes
requires a generator of the multiplicative group F <sup>_×_</sup> _p_ <sup>.</sup> <sup>This generator,</sup> <sup>which is declared here</sup>

as the constant `GENERATOR_VAL`, is defined as _g_ = 3.

The contract `PrimeFieldElement0` further implements functions for the conversion
to/from Montgomery form: `toMontgomeryInt`, `fromMontgomery`, `fromMontgomeryBytes` .
The Montgomery factor _R_ and its inverse _R_ <sup>_−_</sup> <sup>1</sup> mod _p_ (used by those conversion functions)
are also declared as the constants `K_MONTGOMERY_R` and `K_MONTGOMERY_R_INV` . As required,
the following relations are verified:


          - _R ≡_ 2256 mod _p_
_R · R_ <sup>_−_</sup> <sup>1</sup> _≡_ 1 mod _p_ _._


_General_ _observations:_ Observations 21 (G), 22 (G) and 23 (G) are applicable to this
contract.


G **Observation** **1:** **Montgomery** **arithmetic**


The choice of using Montgomery arithmetic is not documented. Our understanding is
that Montgomery arithmetic is used in the proof computation, presumably for performances. It results that some values from the proof are in Montgomery form and must
be converted to standard form in the verification process. It is not clear why those
conversions are not done in the proof computation; this would lighten the verification
process executed on the EVM. Also the special sparse form of the prime _p_ might allow
efficient modular arithmetic without relying on the Montgomery form.


**Recommendation:** We recommend to document the choice of Montgomery. We
further suggest that


   - converting values to the standard form might be done on the proof side to lighten
the EVM computation;


Page 19/44


Code Review of StarkWare’s EVM STARK Verifier


   - using the special form of _p_ might allow efficient arithmetic without relying on
the Montgomery form.


**Status:** **Unresolved** **(** **)**
This recommendation has not been implemented since it would require changing the
implementation of the prover.


3.1.2 Contract `HornerEvaluator`


The contract `HornerEvaluator` implements the evaluation of a polynomial



_p_ ( _x_ ) :=



`nCoefs` _−_ 1

 

_i_ =0



`coefsStart[` _i_ `]` _· x_ <sup>_i_</sup>



for a given point _x_ := `point` via the function of prototype

```
 function hornerEval( uint256 coefsStart, uint256 point, uint256 nCoefs )
```

`internal` `pure` `returns` `(uint256)` .


This function is used to compute the evaluations of the polynomial _pK−_ 1 in the last FRI
layer for the queries _QK−_ 1.


G **Observation** **2:** **Check** **of** **unclear** **purpose**


The purpose of the check “ `nCoefs` `<` `4096` ” is not clear here. It does not seem to be
a constraint from the implementation of the function `hornerEval` .

**Recommendation:** If this check is due to a constraint on the proof design, we
would recommend to move it in the function

```
           StarkVerifier.initVerifierParams

```

which is dedicated to this kind of checks. But since this function already includes a
stronger constraint, which is


`require(logFriLastLayerDegBound` `<=` `10,` `"...")`,


it seems this check could simply be removed.


**Status:** **Partially** **resolved** **(** **_∼_** **)**
A comment has been added but the purpose of the test remains unclear to us.


_General_ _observations:_ Observations 24 (■) and 25 (G) are applicable to this contract.


Page 20/44


Code Review of StarkWare’s EVM STARK Verifier

#### 3.2 Verifier channel


3.2.1 Contract `Prng`


This contract implements the pseudo-random number generator (PRNG) of the IOP verifier, which aims to be secure when the underlying hash function is modeled as a _random_
_oracle_ . The PRNG state is composed of a seed (called `digest` in the implementation since
this seed is always a hash function output) and a counter. When the verifier needs randomness, she calls the function `getRandomBytes`, which computes the hash digest of the
pair (seed, counter), increments the counter and returns the computed hash (32 bytes) as
randomness. The function `initPrng` initializes the PRNG state with an input seed (and
set the counter to 0), and the function `mixSeedWithBytes` re-seeds the PRNG (by mixing
the previous seed with some input data). Finally, the functions `getPrngDigest`, `loadPrng`
and `storePrng` are getters and setter for the PRNG state.


 - **Observation** **3:** **Naming**


The variable names `prngPtr` and `statePtr` are both used to refer to the same concept.

**Recommendation:** We recommend to use a single name. `statePtr` (or `prngStatePtr` )
is probably clearer.


**Status:** **Resolved** **(** **)**
All these variables are now named as `prngPtr` .


G **Observation** **4:** **Seed** **refreshing**


The way the PRNG state is mixed with fresh bytes in the `mixSeedWithByte` function
might be weak. When the seed (a.k.a. _digest_ ) is refreshed using fresh bytes taking a
value _x_, the new seed value is derived as


newSeed := Hash(seed _∥_ _x_ ) _._


On the other hand, the function which generates random bytes from the seed (before
refreshing) and a counter value _ctr_ is defined as


randomBytes := Hash(seed _∥_ _ctr_ ) _,_


where the hash function is similar in both cases.

We observe that if the value _x_ of the fresh bytes collides with a value _ctr_ previously
taken by the counter, then newSeed will equal a previously generated randomBytes
output of the PRNG. If such collision happens, it might break the security proof of
the STARK protocol.

In practice, the function `mixSeedWithByte` is inlined by the function `readBytes`
(from the `VerifierChannel` contract) which might refresh the seed with two types of
fresh bytes read from the proof:


Page 21/44


Code Review of StarkWare’s EVM STARK Verifier


   - Merkle roots of {trace, OODS, FRI} commitments (function `readHash` ),


   - OODS values (function `readFieldElement` ).


An adversary could deliberately set one of these value to a previous counter value.
While it would be hard to generate a valid Merkle root taking the value of a previous
counter (and an invalid Merkle root would be detected by the Merkle verifier), the
impact of such cheating is less clear for the OODS values.

More generally, this PRNG design does not comply to the security proof of the
IOP paper [6] in which two different random oracles _ρ_ 1 and _ρ_ 2 are used for randomness
generation and reseeding.


**Recommendation:** We recommend to use two different hash functions for randomness generation and reseeding. For example:


   - newSeed := Hash(0 _∥_ seed _∥_ _x_ ) for reseeding,


   - randomBytes := Hash(1 _∥_ seed _∥_ _ctr_ ) for randomness generation.


**Status:** **Resolved** **(** **)**
The reseeding strategy now consists in computing the new seed as


newSeed := Hash((seed + 1) _∥_ _x_ ) _,_


while the randomness generation has not changed.


_General_ _observations:_ Observations 22 (G) and 23 (G) are applicable to this contract.


3.2.2 Contract `VerifierChannel`


The _Verifier_ _Channel_ is a structure which contains


  - the pointer to a position in the proof (which must have the format defined in Section 2.4.2);


  - the PRNG which provides the randomness for the IOP verifier.


The function `initChannel` initializes the channel, and the function `getPrngPtr` returns
the pointer to the PRNG state. Two functions are then dedicated to the sampling of
random elements:


  - `sendFieldElements` samples `nElements` elements of F _p_ using the PRNG of the channel and stores them in the memory at address `targetPtr` . A conversion from Montgomery form to standard form is applied to each sampled value.


  - `sendRandomQueries` samples `count` random elements in _{_ 0 _, . . .,_ `mask` _}_, sorts them
and removes redundancy. The resulting list is stored in the memory at address
`queriesOutPtr` .


Page 22/44


Code Review of StarkWare’s EVM STARK Verifier


The contract further implements three functions to read elements from the proof:


  - `readBytes` reads a 256-bit value from the proof and increases the proof pointer. If
the input `mix` is set at ~~tr~~ ue, the PRNG is reseeded using the read value.


  - `readHash` is similar to `readBytes` (it actually calls `readBytes` with the same input).


  - `readFieldElement` proceeds as `readBytes`, but further applies a conversion from
Montgomery form to standard form to the output.


Finally, the contract implements a check function for the grinding process. This function, named `verifyProofOfWork`, reads a 64-bit nonce from the proof and check that the
prover computed a correct proof of work on the current seed of the PRNG. Specifically,
this function checks the nonce satisfies that


Hash(Hash( `0x0123456789abcded` _||_ `prngSeed` _||_ `workBits` ) _||_ `nonce` )


has the `workBits` most significant bits to zero. In practice, this verification is run once
before sampling the queries.


G **Observation** **5:** **Sampling** **rejection**


To sample an element _x_ in _{_ 0 _, . . ., p −_ 1 _}_ from a random 256-bit value _y_, the function
`sendFieldElements` considers the 252 least significant bits _y_ ˆ of _y_ . Then, if _y_ ˆ _< p_, the
function defines _x_ as _y_ ˆ, otherwise it samples a new random 256-bit value _y_ and repeats.
In average, the function will sample two 256-bit values to get a random element of F _p_
(this is because of the sparseness of the most significant bits of _p_ ).


**Recommendation:** We suggest to proceed as follows to obtain a lower rejection
rate. From a uniform random 256-bit value _y_ : if _y_ _<_ 31 _· p_, define _x_ as


_x_ := _y_ mod _p_ _,_


otherwise sample a new random 256-bit value _y_ and repeat. This methodology reduces
the average number of 256-bit samplings to 1 _._ 03 (instead of 2 _._ 00), which reduces almost
by half the number of calls to `keccak256` .


**Status:** **Resolved** **(** **)**
The sampling rejection strategy has been revised as suggested.


G **Observation** **6:** **Bias** **in** **the** **output** **distribution** **of** `sendRandomQueries`

In the function `sendRandomQueries`, the variable `curr` is not explicitly initialized.
Therefore, according to the Solidity documentation, <sup>_a_</sup> `curr` is implicitly initialized to
zero. For the first sampled query, the program does not enter in the loop `while` `(ptr`

`>` `queriesOutPtr)` . Then, for the evaluation of the condition `queryIdx` `!=` `curr`,
the variable `curr` is still zero. As a result, if the first sampled query index is zero,
then it is rejected. This implies a small bias in the output distribution: sampling 0


Page 23/44


Code Review of StarkWare’s EVM STARK Verifier


for the first sampled query should occur with probability 1 _/_ ( _β · N_ ) (since in practice
`mask` = _β ·_ _N −_ 1), but it occurs with probability 0 instead (and hence the other values
are sampled with probability 1 _/_ ( _β · N_ _−_ 1)).


**Recommendation:** We recommend to explicitly initialize the variable `curr` with a
value outside the interval _{_ 0 _, . . .,_ `mask` _}_ .


**Status:** **Resolved** **(** **)**
The variable `curr` is now initialized with `uint256(-1)` which is outside the interval
_{_ 0 _, . . .,_ `mask` _}_ thanks to the inequality `mask` _<_ 2 <sup>64</sup> .


_a_ `[https://docs.soliditylang.org/en/v0.8.10/control-structures.html#default-value](https://docs.soliditylang.org/en/v0.8.10/control-structures.html#default-value)`


G **Observation** **7:** **Undefined** **behavior**

If the input `mask` is equal or greater than 2 <sup>64</sup>, the function `sendRandomQueries` has an
undefined behavior. In practice, it implies that the evaluation domain _L_ 0 must have
less than 2 <sup>64</sup> elements, _i.e._ the relation _β · N_ _≤_ 2 <sup>64</sup> must be verified.


**Recommendation:** We recommend


   - either to add an explicit requirement at the beginning of the function

```
            require((mask » 64) == 0, "...");

```

and to further add a check on _β · N_ in the function `initVerifierParams`,


   - or to change the implementation of `sendRandomQueries` to remove this limitation.


**Status:** **Resolved** **(** **)**
There is now an explicit requirement (at the beginning of the function) that prevents
the undefined behavior. No checks have been added in the function `initVerifierParams` .


_General_ _observations:_ Observations 21 (G), 22 (G) and 26 (G) are applicable to this
contract.

#### 3.3 Merkle trees


3.3.1 Contract `IMerkleVerifier`


The contract `IMerkleVerifier` acts as an interface (although it does not use the keyword
`interface` ). It defines the following upper bound

```
   uint256 internal constant MAX_N_MERKLE_VERIFIER_QUERIES = 128;

```

Page 24/44


Code Review of StarkWare’s EVM STARK Verifier


for the number of decommitted values in a call to the Merkle verifier. It also declares the
following virtual function for the verification of decommitted values:

```
     function veri fy Merkle(

         uint256 channelPtr,

         uint256 queuePtr,

         bytes32 root,

         uint256 n

         ) internal view virtual returns (bytes32 hash);

```

`channelPtr` is a pointer to the authentication paths in the Merkle tree (via the proof).
`queuePtr` is a Merkle queue (see Section 2.2.1) containing the `n` leaves to be verified. The
Merkle root is given by `root` . If the decommitment is invalid, the function shall raise an
error, otherwise it shall return the Merkle root.


3.3.2 Contract `MerkleVerifier`


The contract `MerkleVerifier` is a derived contract of the `IMerkleVerifier` abstract contract. Its implementation of the function `verifyMerkle` (defined in Section 2.2.1) follows
this iterative algorithm:


1. While the queue head is not the Merkle root ( _i.e._ while the index of the node at the
queue head is not 1),


1.1. Pop a node at the head of the queue.
1.2. If the next node in the queue is the sibling node, then pop it, otherwise get the
sibling node from the verifier channel ( _i.e._ from the proof). Note: Since the
queue is sorted by increasing node index (see Section 2.2.1), if the sibling node
is in the queue, it must be the next node.
1.3. From the two sibling nodes, compute the label of the parent node and push it
(together with corresponding index) in the queue.


2. Compare the computed root with the input root, and raise an error in case of mismatch.


As explained in the comment of `verifyMerkle`, the content of the input Merkle queue
is destroyed during the process.


G **Observation** **8:** `slotSize`

The variable `slotSize` is used to store the constant `0x40` in the function `verifyMerkle` .
Then the function sometimes uses this variable and sometimes hardcodes the constant
`0x40` when the slot size is required.

**Recommendation:** Declare a constant for the slot size instead of a local variable
and use this constant instead of hardcoding `0x40` .


Page 25/44


Code Review of StarkWare’s EVM STARK Verifier


**Status:** **Resolved** **(** **)**
Different constants ( `MERKLE_SLOT_SIZE_IN_BYTES`, `COMMITMENT_SIZE_IN_BYTES`, ...)
are now used to represent this value.


G **Observation** **9:** **Hardcoded** **security** **parameter**


The hash function used for the Merkle commitments is implicitly defined as Keccak256 truncated to 160 bits (the most significant bits of the output), which implicitly
sets the collision security of Merkle trees to 80 bits. The truncation mask is hardcoded
in the function `getHashMask` and does not appear as the other constants of the verifier.
It is not clear why a function declaration is needed here instead of a simple constant.


**Recommendation:** Treat the truncation mask as the other verifier constants.


**Status:** **Resolved** **(** **)**
The function `getHashMask` has been replaced by the constant `COMMITMENT_MASK` .


3.3.3 Contract `MerkleStatementContract`


The contract `MerkleVerifier` implements the function `verifyMerkle` as an internal function which assumes that its inputs are in the right format. In contrast, the contract
`MerkleStatementVerifier` provides a public instance of `verifyMerkle` . The latter first
applies a batch of format checks:


  - the height of the tree (input `height` ) must be lower than 200;


  - the length of the Merkle queue (as an array of 256-bit values) must be even and at
most twice `MAX_N_MERKLE_VERIFIER_QUERIES` (constant defined in `IMerkleVerifier` );


  - the node in the queue must be of indices in _{_ 2 <sup>_h_</sup> _, . . .,_ 2 <sup>_h_</sup> <sup>+1</sup> _−_ 1 _}_ where _h_ is here the
height of the Merkle tree (input `height` ), _i.e._ the nodes in the input queue must be
leaves of the tree;


  - the node indices in the queue must be increasing.


After completing those checks (and in case of success) the function then calls the
`verifyMerkle` function from `MerkleVerifier` to check the decommitment validity. If the
Merkle queue has a valid format and if the decommitment is also valid, then the function
`registerFact` from the base contract `FactRegistry` is called to keep track of the fact that
the input Merkle queue is a valid decommitment for the input root. `registerFact` stores
the valid fact as a hash digest, which is built as


ValidFact := Hash(MerkleQueue _||_ MerkleRoot) _._


Page 26/44


Code Review of StarkWare’s EVM STARK Verifier


G **Observation** **10:** **Magic** **number**


The maximum height of the Merkle tree is hardcoded as the magic number 200.


**Recommendation:** W ~~e~~ ~~r~~ ecommend to avoid such a magic number by defining a
constant and to document the choice of 200.


**Status:** **Partially** **resolved** **(** **_∼_** **)**
This remains as a magic number. A comment has been added which explains that this
upper bound is somewhat arbitrary.


3.3.4 Contract `MerkleStatementVerifier`


The contract `MerkleVerifier` is a derived contract of the `IMerkleVerifier` abstract
contract. It has a state variable which is the address of an instance of the contract
`MerkleStatementContract` (initialized by the constructor). Its implementation of the
function `verifyMerkle` (defined in Section 2.2.1) computes the hash of the corresponding
“Merkle statement” from the input Merkle queue and the input Merkle root:


Hash(MerkleQueue _||_ MerkleRoot) _,_


and checks whether this hash is registered as valid fact in the `MerkleStatementContract`
instance pointed by the stored address. If the statement is not registered, then an error is
raised. Otherwise the function outputs the Merkle root.

#### 3.4 FRI protocol


3.4.1 Contract `FriLayer`


The contract `FriLayer` implements the processing of one FRI layer, which aims at moving
from the layer polynomial _pi_ to the layer polynomial _pi_ +1 (as defined in Section 2.1).
Specifically, from the set of queries _Qi_ and corresponding evaluations of _pi_, it


  - computes the leaves to be decommitted from the Merkle tree of _pi_ ;


  - computes the next set _Qi_ +1 of queries:




;



_Qi_ +1 :=




- _v_ <sup>2</sup> <sup>_ℓi_</sup> <sup>+1</sup> _, v_ _∈Qi_




- computes the evaluations of _pi_ +1 on _Qi_ +1.



For _vi_ +1 _∈Qi_ +1, the evaluation _pi_ +1( _vi_ +1) can be computed from the evaluations of _pi_
on the coset _vi · ⟨ξ⟩⊆_ _Li_, where _vi_ _∈Qi_ s.t. _vi_ +1 = _vi_ <sup>2</sup> <sup>_ℓi_</sup> <sup>+1</sup> and where _ξ_ is a generator of



on the coset _vi · ⟨ξ⟩⊆_ _Li_, where _vi_ _∈Qi_ s.t. _vi_ +1 = _vi_ <sup>2</sup> <sup>_ℓi_</sup> <sup>+1</sup> and where _ξ_ is a generator of

the subgroup of F <sup>_×_</sup> _p_ <sup>of</sup> <sup>size</sup> <sup>2</sup> <sup>_ℓi_</sup> <sup>+1.</sup> <sup>Some</sup> <sup>of</sup> <sup>these</sup> <sup>evaluations</sup> <sup>are</sup> <sup>obtained</sup> <sup>from</sup> <sup>the</sup> <sup>previous</sup>



the subgroup of F <sup>_×_</sup> _p_ <sup>of</sup> <sup>size</sup> <sup>2</sup> <sup>_ℓi_</sup> <sup>+1.</sup> <sup>Some</sup> <sup>of</sup> <sup>these</sup> <sup>evaluations</sup> <sup>are</sup> <sup>obtained</sup> <sup>from</sup> <sup>the</sup> <sup>previous</sup>

layer (namely the evaluations in the points _vi · ⟨ξ⟩∩Qi_ ) while the others are taken from
the proof.



Page 27/44


Code Review of StarkWare’s EVM STARK Verifier


The main function of this contract is `computeNextLayer` . To be functional, it requires
that the second and third fields of verifier context (see Section 2.3.2) have been previously initialized by the function `initFriGroups` . When `computeNextLayer` is called, the
queries of _Qi_ and the evaluations of _pi_ on these queries are stored in the FRI queue (see
Section 2.3.3) pointed by the input `friQueuePtr` . Since these evaluations are not sufficient to compute the evaluations of _pi_ +1 on _Qi_ +1, the remaining evaluations are read
from the proof through the verifier channel pointed by the input `channelPtr` . The function `computeNextLayer` makes repeated calls to the functions `gatherCosetInputs` and
`doFriSteps` which are described hereafter.

The function `gatherCosetInputs` gathers all the evaluations of _pi_ on _vi_ _· ⟨ξ⟩_ for the
query _vi_ at the head of the FRI queue. Let us recall that the corresponding element in the
FRI queue is the triplet
�index _i_ ( _vi_ ) _, pi_ ( _vi_ ) _,_ <sup><u>1</u></sup>                






_vi_ <sup>_′_</sup>



_i_



where _vi_ <sup>_′_</sup> <sup>=</sup> <sup>(</sup> <sup>_c_</sup> lde <sup>2</sup> <sup>_si_</sup> <sup>)</sup> <sup>_−_</sup> <sup>1</sup> <sup>_· vi_</sup> <sup>is</sup> <sup>the</sup> <sup>scaled</sup> <sup>value</sup> <sup>of</sup> <sup>_vi_</sup> <sup>(see</sup> <sup>Section</sup> <sup>2.1).</sup> <sup>Let</sup> <sup>us</sup> <sup>denote</sup> <sup>_c_</sup> <sup>the</sup>

element of _vi · ⟨ξ⟩_ with the lowest index. The index of _c_ is called the _coset_ _index_ (variable
`cosetIdx` in the code). The coset index is computed by setting the _ℓi_ +1 right-most bits
of the index of _vi_ to 0. Then all the indexes of the elements of _vi_ _·_ _⟨ξ⟩_ are listed as
`cosetIdx`, `cosetIdx` +1, . . ., `cosetIdx` +2 <sup>_ℓi_</sup> <sup>+1</sup> _−_ 1. For each index, the function checks
whether the corresponding element is in the FRI queue (thanks to the structure of the
queue the indexes are in increasing order). In case of match, the element is popped from
the FRI queue and the corresponding evaluation (second item of the triplet) is added to
the set of gathered evaluations. In case of mismatch, the evaluation corresponding to the
current index is read from the proof. All the gathered evaluations are stored in the FRI
context (see Section 2.3.2). The function `gatherCosetInputs` further returns



_i_ <sup>_′_</sup> <sup>=</sup> <sup>(</sup> <sup>_c_</sup> lde <sup>2</sup> <sup>_si_</sup>



where _vi_ <sup>_′_</sup>



<u>1</u>
`cosetIdx` = index _i_ ( _c_ ) and
_c_ <sup>_′_</sup> <sup>=</sup> _v_ <sup><u>1</u></sup> _i_ <sup>_′_</sup>



_vi_ <sup>_′_</sup>




_· ξ_ <sup>_j_</sup>



_i_



where _c_ <sup>_′_</sup> = ( _c_ <sup>2</sup> lde <sup>_si_</sup> <sup>)</sup> <sup>_−_</sup> <sup>1</sup> <sup>_· c_</sup> <sup>is</sup> <sup>the</sup> <sup>scaled</sup> <sup>value</sup> <sup>of</sup> <sup>_c_</sup> <sup>and</sup> <sup>where</sup> <sup>_j_</sup> <sup>= bit-reverse</sup> log _|Li|_ <sup>(index</sup> <sup>_i_</sup> <sup>(</sup> <sup>_vi_</sup> <sup>)</sup> <sup>_−_</sup>

`cosetIdx` ). Those returned values will be used to compute the FRI queue triplet corresponding to the query _vi_ +1.



Once `gatherCosetInputs` done, the function `doFriSteps` is called to compute _pi_ +1( _vi_ +1)
from the gathered evaluations and the returned value 1 _/c_ <sup>_′_</sup> (input `cosetOffset_` in the
code). In practice, the implementation evaluates the scaled layer polynomial _p_ <sup>_′_</sup> _i_ +1 <sup>on</sup>




<sup>_′_</sup>

_i_ +1 <sup>using</sup> <sup>the</sup> <sup>scaled</sup> <sup>inverse</sup> <sup>1</sup> <sup>_/c′_</sup> <sup>which</sup> <sup>satisfies</sup> <sup>(1</sup> <sup>_/c′_</sup> <sup>)2</sup> <sup>_ℓi_</sup> <sup>+1</sup> <sup>=</sup> <sup>1</sup> <sup>_/v_</sup> _i_ <sup>_′_</sup>




<sup>_′_</sup> _i_ +1 <sup>on</sup>



_v_ <sup>_′_</sup>

_i_



_v_ <sup>_′_</sup>

_i_ +1 <sup>using</sup> <sup>the</sup> <sup>scaled</sup> <sup>inverse</sup> <sup>1</sup> <sup>_/c′_</sup> <sup>which</sup> <sup>satisfies</sup> <sup>(1</sup> <sup>_/c′_</sup> <sup>)2</sup> <sup>_ℓi_</sup> <sup>+1</sup> <sup>=</sup> <sup>1</sup> <sup>_/v_</sup> _i_ <sup>_′_</sup> +1 <sup>(see</sup> <sup>Section</sup> <sup>2.3.1</sup>

for explanations about the scaling). This computation is done by calling the function
`doXFriSteps` with `X` _∈{_ `2` _,_ `3` _,_ `4` _}_ depending on the number of FRI steps in the current layer
_ℓi_ +1 = `fri_step_list[` _i_ + 1 `]` . The function `doFriSteps` then computes the leave of the
Merkle tree corresponding to the gathered evaluations of _pi_ (see Section 2.2.3), namely



_p_ <sup>_′_</sup> _i_




<sup>_′_</sup> _i_ <sup>(</sup> <sup>_c_</sup> <sup>)</sup> <sup>_∥_</sup> <sup>_p′_</sup> _i_




<sup>_′_</sup> _i_ <sup>(</sup> <sup>_c · ξj_</sup> <sup>1)</sup> <sup>_∥_</sup> <sup>_p′_</sup> _i_




<sup>_′_</sup> _i_ <sup>(</sup> <sup>_c · ξj_</sup> <sup>2)</sup> <sup>_∥_</sup> <sup>_. . ._</sup>



where the exponent _j_ 1, _j_ 2, . . ., are in increasing bit-reverse order (according to the definition to the FRI group in Section 2.3.2). This leave is stored in the Merkle queue (to be


Page 28/44


Code Review of StarkWare’s EVM STARK Verifier


verified as a valid decommitment later). Finally the function `doFriSteps` add the triplet




- <u>1</u>
index _i_ +1( _vi_ +1) _, pi_ <u>+1(</u> _vi_ +1) _,_
_vi_ <sup>_′_</sup> +1




with index _i_ +1( _vi_ +1) := <sup><u>index</u></sup> <sup>_<u>i</u>_</sup> <sup><u>+1(</u></sup> <sup>_<u>c</u>_</sup> <sup><u>)</u></sup>

2 <sup>_ℓi_</sup> <sup>+1</sup>



to the FRI queue as an element to be processed by the next FRI layer.

The function `computeNextLayer` repeats the calls to `gatherCosetInputs` and `doFriSteps`
for each query _vi_ _∈Qi_ . When all the queries from _Qi_ have been popped from the FRI queue,
the latter has been filled with all the queries from _Qi_ +1. The function `computeNextLayer`
then stops and returns the size of the new queue ( _i.e._ the number of queries in _Qi_ +1).


_Methodology._ As exposed in the introduction of this report, our audit consists in a careful
review of the source code. However, the implementation of `do2FriSteps`, `do3FriSteps`
and `do4FriSteps` is too complex to validate their correctness through a simple code review.
Therefore, we wrote a SageMath script that parses the implementation of these functions,
evaluates them in a symbolic way, and checks the obtained outputs. The followed approach
is detailed in Appendix A. All the tests of the script have passed, we therefore validate the
correctness of these functions.


 - **Observation** **11:** **Comments** **and** **variable** **naming**


The comments and naming of variables are confusing in this contract. For instance:


   - Our understanding is that the label `friEvalPoint` is used for the (scaled) sampled value _ζi_ <sup>_′_</sup> <sup>which</sup> <sup>is</sup> <sup>confusing</sup> <sup>since</sup> <sup>this</sup> <sup>is</sup> <sup>not</sup> <sup>an</sup> <sup>evaluation</sup> <sup>point.</sup>

   - The labels `cosetOffset_` and `xInv` are both used for the values 1 _/c_ <sup>_′_</sup> (which does
not exist in the protocol description, _e.g._ [10]). The terminology `X` is further used
with `friEvalPointDivByX` .


   - There is an ambiguity on the definition of the “coset offset”. We can assume it
corresponds to the value `c` in the following comment (lines 7–19):

```
        The main component of FRI is the FRI step which
        takes the i-th layer evaluations on a coset c*<g>
        and produces a single evaluation in layer i+1.

```

This definition matches what we denote _c_ in the above description.


The notation `c` is reused in the comment of `gatherCosetInputs` (lines 669-675):

```
     // Get the algebraic coset offset:

     // I.e. given c*gˆ(-k) compute c, where

     // g is the generator of the coset group.

     // k is bitReverse(offsetWithinCoset, log2(cosetSize)).

```

However, this `c` is in reality the _inverse_ of the `c` from the first comment.


Page 29/44


Code Review of StarkWare’s EVM STARK Verifier


**Recommendation:** We recommend to document the multiple-step FRI protocol
and the scaling trick with a proper definition of the different variables occurring in the
computation. The comments in the code and a consistent naming convention could
then be based on such a <u>description.</u>


**Status:** **Unresolved** **(** **)**
The labels `friEvalPoint`, `cosetOffset_` and `xInv` are still used. Moreover, the two
above comments stay unchanged.


- **Observation** **12:** **Incorrect** **function** **description**


The description of the function `doFriSteps` (lines 795–805) states:

```
      The input is read either from the queue or from
      the proof depending on data availability. Since
      the function reads from the queue it returns an
      updated head pointer.

```

This comment is not relevant for `doFriSteps` (it might be for `gatherCosetInputs` ).
Moreover, earlier in the same description, the third output is described as

```
      3. The root of a Merkle tree for the input layer.

```

but this should be a Merkle leave (from the layer polynomial Merkle tree).


**Recommendation:** We recommend to correct the description of this function.


**Status:** **Unresolved** **(** **)**
The description of the function `doFriSteps` has not changed.


G **Observation** **13:** **Unused** **function**


As also reported in Observation 22, the function

```
       nextLayerElementFromTwoPreviousLayerElements

```

is never called. Our guess is that this function is meant to ease the understanding of
the functions `do2FriSteps`, `do3FriSteps` and `do4FriSteps` . However, the inputs of
this function are not the same as the inputs of the latter functions.


**Recommendation:** We recommend to avoid unused functions. If the above function
is useful, we would suggest to clarify its purpose and to homogenize its name and
arguments with the other functions.


Page 30/44


Code Review of StarkWare’s EVM STARK Verifier


**Status:** **Resolved** **(** **)**
The function `nextLayerElementFromTwoPreviousLayerElements` has been removed.


_General_ _observations:_ Observations 21 (G), 22 (G), 23 (G), 24 (■) and 27 (■) are applicable to this contract.


3.4.2 Contract `Fri`



The contract `Fri` processes and verifies all the FRI layers of the protocol. The main function `friVerifyLayers` is called when the FRI queue has been initialized with the set _Q_ 0
of queries for _p_ 0. The FRI queue is accessed through the field `MM_FRI_QUEUE` of the verifier
context (input `ctx` of the function). First, the function calls to `FriLayer.initFriGroups`
to populate the constant data in the FRI context (see Section 2.3.2). Then, it processes each
FRI layer (but the last one) thanks to `FriLayer.computeNextLayer` and decommits the
evaluations of the current layer polynomial thanks to `MerkleVerifier.verifyMerkle` . At
the end, the FRI queue holds the evaluations of _pK−_ 1 on _QK−_ 1. The function `verifyLastLayer`
is then called to recompute these evaluations using the coefficients of the scaled layer polynomial _p_ <sup>_′_</sup> _K−_ 1 <sup>(available in the field</sup> <sup>`MM_FRI_LAST_LAYER_PTR`</sup> <sup>of the verifier context) as well</sup>



nomial _p_ <sup>_′_</sup> _K−_ 1 <sup>(available in the field</sup> <sup>`MM_FRI_LAST_LAYER_PTR`</sup> <sup>of the verifier context) as well</sup>

as the queries _v_ <sup>_′_</sup> _∈Q_ <sup>_′_</sup> _K−_ 1 <sup>recovered</sup> <sup>by</sup> <sup>inverting</sup> <sup>the</sup> <sup>1</sup> <sup>_/v′_</sup> <sup>items</sup> <sup>of</sup> <sup>the</sup> <sup>elements</sup> <sup>of</sup> <sup>the</sup> <sup>FRI</sup>



as the queries _v_ <sup>_′_</sup> _∈Q_ <sup>_′_</sup> _K−_ 1 <sup>recovered</sup> <sup>by</sup> <sup>inverting</sup> <sup>the</sup> <sup>1</sup> <sup>_/v′_</sup> <sup>items</sup> <sup>of</sup> <sup>the</sup> <sup>elements</sup> <sup>of</sup> <sup>the</sup> <sup>FRI</sup>

queue.

As explained in the comments of the contract, all the evaluations of the polynomials
_p_ 0, . . ., _pK−_ 1 are in the Montgomery form when calling `FriLayer.computeNextLayer` and
`Fri.verifyLastLayer` . However, the computation is performed as if those evaluations
were in the standard form. Both computation are indeed equivalent thanks to the following
properties:


  - two added values are always in the same form (both in the standard form, or both
in the Montgomery form);


  - when a value _x_ _·_ _R_ in Montgomery form is multiplied by a value _y_, the latter is always
in the standard form. Then, the result is in the Montgomery form


( _x · R_ ) _· y_ = ( _x · y_ ) _· R_ _._


_General_ _observations:_ Observations 23 (G), 24 (G) and 27 (■) are applicable to this
contract.


3.4.3 Contract `FriStatementContract`


This contract implements a public function `verifyFRI` which, given


  - a FRI queue containing evaluations of _pi_ on a query set _Qi_ for a layer _i_ + 1;


  - the scaled sampled value _ζi_ <sup>_′_</sup> <sup>(input</sup> <sup>`evaluationPoint`</sup> <sup>);</sup>


  - the number _ℓi_ +1 of steps from _pi_ to _pi_ +1 (input `friStepSize` );


Page 31/44


Code Review of StarkWare’s EVM STARK Verifier


  - the Merkle root for the commitment of _pi_ on _Li_ ;


  - a proof sequence,


process the layer ( _i_ +1) and checks that the revealed evaluations of _pi_ (from the FRI queue
and from the proof) are consistent with the Merkle root. If the computation of the layer
succeeds and if the decommitment of the evaluations of _pi_ is valid, then the `FactRegistry`
contract is called to save the fact that, given the initial and the final states of the FRI
queue, there exists a valid computation which links the both states and which is consistent
with the given Merkle root.

The function proceeds as follows:


  - it checks that the FRI queue has the right format (checks the length, checks that
indices are increasing and in the right range, checks that the elements of F _p_ are
encoded with a value of _{_ 0 _, . . ., p −_ 1 _}_ );


  - it checks that _ζi_ <sup>_′_</sup> <sup>is</sup> <sup>an</sup> <sup>element</sup> <sup>of</sup> <sup>_{_</sup> <sup>0</sup> <sup>_, . . ., p −_</sup> <sup>1</sup> <sup>_}_</sup> <sup>;</sup>


  - it allocates the memory for the verifier channel, the Merkle queue and the FRI
context;


  - it initializes the FRI context by calling `FriLayer.initFriGroups` ;


  - it computes the next layer by calling `FriLayer.computeNextLayer` ;


  - it checks the decommitment of the revealed evaluations of _pi_ by calling `verifyMerkle` ;


  - in case of successful verification, it computes the hash



Hash




- _ζi_ <sup>_′_</sup> <sup>_∥_</sup> <sup>_ℓi_</sup> <sup>+1</sup> <sup>_∥_</sup> <sup>Hash(FriQueue</sup> _i_ <sup>)</sup> <sup>_∥_</sup> <sup>Hash(FriQueue</sup> _i_ +1 <sup>)</sup> <sup>_∥_</sup> <sup>MerkleRoot</sup>







and stores it as a valid fact in the `FactRegistry` contract. Here FriQueue _i_ denotes
the content of the queue before layer processing and FriQueue _i_ +1 is the content of
the queue after layer processing.


_General_ _observations:_ Observation 24 (■) is applicable to this contract.


3.4.4 Contract `FriStatementVerifier`


The contract `FriStatementVerifier` verifies all the FRI layers, one by one, using the
contract `FriStatementContract` which stores as valid facts the processed and verified
transitions between two consecutive states of the FRI queue. It has a state variable which
is the address of an instance of the contract `FriStatementContract` (initialized by the
constructor).

The function `friVerifyLayers` starts from a FRI queue which contains the initial
queries _Q_ 0 and the corresponding evaluations of the DEEP composition polynomial _p_ 0
(computed by the OODS contract). It proceeds as follows:


Page 32/44


Code Review of StarkWare’s EVM STARK Verifier


 - It converts the _p_ 0 evaluations (computed by the OODS contract) to the Montgomery
form;


 - It computes the hash ~~di~~ gest _h_ 0 := Hash(FriQueue0), where FriQueue0 denotes the
initial content of the FRI queue;


 - For each FRI layer (but the last one), _i.e._ for _i_ in _{_ 1 _, . . ., K −_ 2 _}_,


**–** It reads the hash digest _hi_ := Hash(FriQueue _i_ ) from the verifier channel;

**–** It computes the hash


Hash( _ζi_ <sup>_′_</sup> _−_ 1 <sup>_∥_</sup> <sup>_ℓi_</sup> <sup>_∥_</sup> <sup>_hi−_</sup> <sup>1</sup> <sup>_∥_</sup> <sup>_hi_</sup> <sup>_∥_</sup> <sup>MerkleRoot</sup> <sup>_i−_</sup> <sup>1)</sup>


where MerkleRoot _i−_ 1 is the commitment of the _pi−_ 1 evaluations (obtained from
the verifier context);


**–** It checks if this hash is registered in the `FriStatementContract` instance as a

valid fact (an error is raised otherwise).


 - Using the function `computerLastLayerHash`, it computes the final state of the FRI
queue, denoted FriQueue _K−_ 1. This is done by first computing the query set _QK−_ 1
from the query set _Q_ 0 by

_QK−_ 1 = _{v_ <sup>2</sup> <sup>_sK−_</sup> <sup>1</sup> _,_ _v_ _∈Q_ 0 _}_ _,_


then evaluating _pK−_ 1 for each queries in _QK−_ 1 by calling `hornerEval` . From this
final states, it computes the hash _hK−_ 1 := Hash(FriQueue _K−_ 1).


 - Finally, it computes the hash


Hash( _ζK_ <sup>_′_</sup> _−_ 2 <sup>_||ℓK−_</sup> <sup>1</sup> <sup>_||hK−_</sup> <sup>2</sup> <sup>_||hK−_</sup> <sup>1</sup> <sup>_||_</sup> <sup>MerkleRoot</sup> <sup>_K−_</sup> <sup>2)</sup> <sup>_,_</sup>


and checks if this hash is registered in the `FriStatementContract` instance as a valid
fact (an error is raised otherwise).


- **Observation** **14:** **Naming**


The label `numLayers` is used for the total number of FRI steps, _i.e._ the sum of the
steps of all the layers, which we denote _sK−_ 1 in this report (and which is strictly
greater than the number of FRI layers). This is confusing.


**Recommendation:** We recommend to change this name, _e.g._ for `totalNumSteps` .


**Status:** **Resolved** **(** **)**
The label has been renamed into `sumOfStepSizes` .


Page 33/44


Code Review of StarkWare’s EVM STARK Verifier


G **Observation** **15:** **Costly** **exponentiations**



The piece of code from line 52 to line 56 makes two calls to `fpow` in order to compute
_v_ <sup>2</sup> <sup>_sK −_</sup> <sup>1</sup> from 1 _/v_ (raising t ~~o t~~ he 2 <sup>_sK−_</sup> <sup>1</sup> first and then to the group order minus 1). These
costly exponentiations could be avoided.

**Recommendation:** An other way would be to use the index of _v_ <sup>2</sup> <sup>_sK−_</sup> <sup>1</sup> (which can be
easily derived from the index of _v_ ) and to raise a generator of _L_ <sup>_′_</sup> _K−_ 1 <sup>(see</sup> <sup>Section</sup> <sup>2.1)</sup>



easily derived from the index of _v_ ) and to raise a generator of _L_ <sup>_′_</sup> _K−_ 1 <sup>(see</sup> <sup>Section</sup> <sup>2.1)</sup>

to the exponent corresponding to the index. This would require to pre-compute a
generator of _L_ <sup>_′_</sup> _K−_ 1 <sup>once,</sup> <sup>and</sup> <sup>then</sup> <sup>would</sup> <sup>result</sup> <sup>in</sup> <sup>a</sup> <sup>much</sup> <sup>smaller</sup> <sup>exponentiation</sup>



generator of _L_ <sup>_′_</sup> _K−_ 1 <sup>once,</sup> <sup>and</sup> <sup>then</sup> <sup>would</sup> <sup>result</sup> <sup>in</sup> <sup>a</sup> <sup>much</sup> <sup>smaller</sup> <sup>exponentiation</sup>

inside the loop.



**Status:** **Resolved** **(** **)**
The recommendation is not applicable since it would require reversing the bits of the
index of _v_ <sup>2</sup> <sup>_sK−_</sup> <sup>1</sup> .


_General_ _observations:_ Observations 23 (G) and 24 (■) are applicable to this contract.

#### 3.5 STARK verifier


3.5.1 Contract `StarkVerifier`


The contract `StarkVerifier` is the main contract of the STARK verifier which is derived
from the other contracts and performs the global STARK verification of an input proof
of computational integrity. The entry point of this contract is the function `verifyProof`
which takes three inputs:


  - the proof parameters `proofParams` (see Section 2.4.1);


  - the proof `proof` (formatted as described Section in 2.4.2);


  - the statement `publicInput` which must be verified thanks to the proof.


The proof verification proceeds as follows:


  - It calls the function `initVerifierParams` . This function checks if the proof parameters are valid (the parameter checkings are described in Section 2.4.2), and initializes
all the fields of the verifier context related to the statement and the proof parameters.
It also checks that the trace length _N_ is consistent with `fri_step_list[` _._ `]` and with
the degree of the last layer polynomial _pK−_ 1 and that the soundness error


`nQueries` _·_ log2 _β_ + `proofOfWorkBits`


achieves the target security level `numSecurityBits` .


  - It initializes the verifier channel with the proof.


Page 34/44


Code Review of StarkWare’s EVM STARK Verifier


 - It reads the trace commitments from the proof (and samples the corresponding challenges).


 - It samples the OODS ~~p~~ oint _z_, reads the OODS values _{yℓ}ℓ_ _∪{y_ ˆ _i}i_ and calls the
function `oodsConsistencyCheck` . As described in Section 2.5.3, this function (implemented by the user) must check that the mask _{yℓ}ℓ_ for the point _z_ is consistent
with all the _y_ ˆ _i_ := _hi_ ( _z_ <sup>_M_</sup> <sup>2</sup> ).


 - After sampling the OODS coefficients _{γ_ 0 _, . . ., γM_ 1+ _M_ 2 _−_ 1 _}_ which defines the first
layer polynomial _p_ 0 ( _i.e._ the DEEP composition polynomial), it reads from proof
the commitments for all the layer polynomials _p_ 0 _, . . ., pK−_ 2 except the last one.


 - It calls the function `readLastFriLayer` . This function reads the coefficients of the
polynomial _pK−_ 1, checks if they are in _{_ 0 _, . . ., p −_ 1 _}_ and stores a pointer to them in
the verifier context (field `MM_FRI_LAST_LAYER_PTR` ).


 - It checks if the proof of work is consistent with the current PRNG state (by calling
`VerifierChannel.verifyProofOfWork` ).


 - It generates all the (initial) queries _Q_ 0 for the FRI protocol. And then, it calls the
function `computeFirstFriLayer`, which


**–** correctly formats the queries in _Q_ 0 in the FRI queue thanks to


`adjustQueryIndicesAndPrepareEvalPoints` ;


**–** reads _f_ 0( _v_ ) _, . . ., fW_ ( _v_ ) and _h_ 0( _v_ ) _, . . ., hM_ 2 _−_ 1( _v_ ) for every _v_ _∈Q_ 0 from the proof

and checks these values are consistent with the trace commitments (see Section 2.2.2) thanks to `readQueryResponsesAndDecommit` .


**–** calls the OODS contract (see section 2.5.2) to compute _p_ 0( _v_ ) from the _{fi_ ( _v_ ) _}_

and _{hi_ ( _v_ ) _}_ for every _v_ _∈Q_ 0 (these values are stored in the FRI queue).


 - Finally, it launches the processing and verification of the FRI layers thanks to the
function `Fri.friVerifyLayers` .


G **Observation** **16:** **Magic** **numbers**


Many constant values are hardcoded in the checks of `initVerifierParams` (while
some checks make use of properly defined constants).


**Recommendation:** We recommend to avoid such magic numbers by defining constants.


**Status:** **Partially** **resolved** **(** **_∼_** **)**
Those remain as a magic numbers. Some comments have been added which explain
that some bounds are somewhat arbitrary.


Page 35/44


Code Review of StarkWare’s EVM STARK Verifier


G **Observation** **17:** **Check** **for** **the** **number** **of** **FRI** **steps**


The auxiliary function `validateFriParams` checks that the number of steps of a layer
is in the interval _{_ 1 _, . . .,_ 4 _~~}~~_ ~~.~~ The interval maximum `4` is hardcoded instead using the
constant `FRI_MAX_FRI_STEP` . The interval minimum is `1`, but this case is not supported
by the function `FriLayer.doFriSteps` .

**Recommendation:** We recommend to define a constant for the minimum number
of FRI steps, which is 2, and to use this constant as well as the defined constant
`FRI_MAX_FRI_STEP` in the check.


**Status:** **Resolved** **(** **)**
The interval minimum is now `2` (hardcoded value) and the interval maximum is now
set using the constant `FRI_MAX_STEP_SIZE` .


- **Observation** **18:** **Naming**


The proof parameter defined in the constant

```
       PROOF_PARAMS_FRI_LAST_LAYER_DEG_BOUND_OFFSET

```

is not the upper bound of the degree of _pK_ but of its logarithm.

**Recommendation:** We recommend to rename this constant

```
      PROOF_PARAMS_FRI_LAST_LAYER_LOG_DEG_BOUND_OFFSET

```

or some other name which makes appear the `LOG` keyword.


**Status:** **Resolved** **(** **)**
The constant has been renamed as suggested.


G **Observation** **19:** **Costly** **exponentiation**


In the function `adjustQueryIndicesAndPrepareEvalPoints`, the following expression
is used to compute a right shift:

```
      res := div(res, exp(2, sub(127, numberOfBits)))

```

Thus it costs 25 units of gas [11] for a simple shift operation.

**Recommendation:** If the targeted EVM version is at least Constantinople <sup>_a_</sup>, we
suggest to use the opcode `shr` which only costs 3 units of gas.


**Status:** **Resolved** **(** **)**
The expression has been replaced by


Page 36/44


Code Review of StarkWare’s EVM STARK Verifier


`res` `:=` `shr(sub(127,` `numberOfBits),` `res)` .


_a_ `[https://docs.soliditylang.org/en/v0.8.10/using-the-compiler.html#target-options](https://docs.soliditylang.org/en/v0.8.10/using-the-compiler.html#target-options)`


G **Observation** **20:** **Montgomery** **vs.** **standard** **form** **for** **OODS** **contract**


As explained in Section 2.5.2, the OODS contract takes some inputs in standard form
( _z_, _{yℓ}ℓ_ _∩{y_ ˆ _i}i_ and _{γi}i_ ) and some inputs in Montgomery form (the _fi_ and _hi_
evaluations). Then it converts the Montgomery-form inputs to standard form and
produces outputs in standard form.


**Recommendation:** We recommend to homogenize the form of the inputs and
outputs of the OODS contract, namely to convert the _fi_ and _hi_ evaluations before
calling the OODS contract.


**Status:** **Unresolved** **(** **)**
No modification has been made.


_General_ _observations:_ Observations 21 (G), 22 (G), 24 (■), 26 (G) and 27 (■) are applicable to this contract.


Page 37/44


Code Review of StarkWare’s EVM STARK Verifier

### 4 General observations


G **Observation** **21:** **Harcoded** **constants**


In the source code, many constant values are hardcoded even though the corresponding constants are declared. This mainly occurs in inline assembly. For example, the
constant `PrimeFieldElement0.K_MODULUS` defines the prime _p_, but this constant is not
used by the functions `fmul`, `fadd`, `fromMontgomery`, which directly hardcode the corresponding value `0x800000000000011000[...]0001` . The list of the constants which
are hardcoded in some parts of the implementation are:


   - `PrimeFieldElement0.K_MODULUS`,


   - `PrimeFieldElement0.K_MODULUS_MASK`,


   - `PrimeFieldElement0.K_MONTGOMERY_R`,


   - `PrimeFieldElement0.K_MONTGOMERY_R_INV`,


   - `FriLayer.FRI_MAX_FRI_STEP` .


**Recommendation:** Solidity supports constants in inline assembly


   - since version 0.5.11 (2019-08-12): “Inline Assembly: Support direct constants of
value type in inline assembly.” [3], see also [1].


   - since version 0.5.14 (2019-12-09): “Inline Assembly: Support constants that reference other constants.” [3], see also [2].


Since the pragma for Solidity version is configured as

```
             pragma solidity ˆ0.6.11;

```

we recommend to avoid the hardcoding of constant values (in inline assembly) but to
rely on declared constants.


**Status:** **Resolved** **(** **)**
All these hardcoded values have been replaced by the corresponding constants.


G **Observation** **22:** **Unused** **functions** **and** **constants**


The following functions and constants are never used:


   - `PrimeFieldElement0.GEN1024_VAL`


   - `PrimeFieldElement0.fromMontgomeryBytes`


Page 38/44


Code Review of StarkWare’s EVM STARK Verifier


  - `PrimeFieldElement0.toMontgomeryInt`


  - `Prng.mixSeedWithBytes`


  - `Prng.getPrngDigest`


  - `VerifierChannel.CHANNEL_STATE_SIZE`


  - `StarkVerifier.hashRow`


  - `FriLayer.nextLayerElementFromTwoPreviousLayerElements`


**Recommendation:** If the above constants and functions aim to be called in external
contracts, we recommend to add a comment to clarify it. Otherwise, we recommend
to remove them.


**Status:** **Partially** **resolved** **(** **_∼_** **)**
All these functions and constants have been removed, except `fromMontgomeryBytes`
and `toMontgomeryInt` .


G **Observation** **23:** **Auxiliary** **functions** **defined** **as** **internal**


The following functions are auxiliary ( _i.e._ used to avoid redundancy in the corresponding contract and/or to improve the code readability):


  - `PrimeFieldElement0.expmod`,


  - `Prng.getRandomBytesInner`,


  - `FriLayer.doXFriSteps` with `X` _∈{_ `2` _,_ `3` _,_ `4` _}_,


  - `FriLayer.gatherCosetInputs`,


  - `FriLayer.doFriSteps`,


  - `Fri.verifyLastLayer` .


  - `FriStatementVerifier.computerLastLayerHash` .


**Recommendation:** Since these functions do not aim to be used in other contracts,
we suggest to define them as private functions.


**Status:** **Unresolved** **(** **)**
All these functions are still defined as internal.


Page 39/44


Code Review of StarkWare’s EVM STARK Verifier


- **Observation** **24:** **Pointer** **variables**


Pointer variables are often indicated by the suffix `Ptr` but not always. For instance,
the following variables are ~~p~~ ointers:


  - `coefsStart` in `HornerEvaluator`, `Fri` and `FriStatementVerifier`


  - `friCtx` in `FriLayer`, `Fri` and `FriStatementContract`


  - `friQueue` in many places


  - `friQueueTail` in `FriLayer`


  - `friQueueHead` in `FriLayer`


  - `friQueueEnd` in `StarkVerifier` and `FriLayer`


  - `dataToHash` in `FriStatementContract`


**Recommendation:** Use suffix `Ptr` for all pointer variables.


**Status:** **Unresolved** **(** **)**
All these pointer names have remained unchanged.


G **Observation** **25:** **Homogenize** **the** **call** **to** **constants** **of** **base** **contracts**


To refer to a specific constant in the source code, it is sometimes written

```
            BaseContract.ConstantName

```

( _e.g._ line 21 of `HornerEvaluator.sol` ) and at other locations, it is just written

```
               ConstantName

```

( _e.g._ line 157 of `StarkVerifier.sol.ref` ).

**Recommendation:** We recommend to always use the same notation (without the
contract name if there is no ambiguity).


**Status:** **Unresolved** **(** **)**
The recommendation has not been fixed for the sake of readability.


G **Observation** **26:** **Redundant** **code**


In multiple places in the code, some functions are re-implemented.


  - In the contract `VerifierChannel`,


Page 40/44


Code Review of StarkWare’s EVM STARK Verifier


**–** `sendFieldElements` reimplements `getRandomBytes` .


**–** `readBytes` reimplements `mixSeedWithBytes` .


  - In the contract `StarkVerifier`, the function
`adjustQueryIndicesAndPrepareEvalPoints` reimplements


**–** `bitReverse` (from `FriLayer` ), and


**–** `expmod` (from `PrimeFieldElement0` ).


**Recommendation:** We recommend as much as possible to call the implemented
functions. It makes the code easier to maintain and less prone to bugs.


**Status:** **Unresolved** **(** **)**
The recommendation has not been applied since it is impossible to call global functions
in assembly. However, the use of assembly does not seem always justified. For example,
it is not clear why the implementation of `VerifierChannel.sendFieldElements` is
entirely written in assembly. For this function, the assembly language seems useful
only when storing the sampled value at `targetPtr` .


- **Observation** **27:** **Ambiguity** **in** **the** **meaning** **of** **“step”** **in** **the** **code**


The notion of “step” is used in different variable names for two different notions:


  - A step of the FRI protocol (which divides the polynomial degree by 2) where
steps are grouped by 2, 3, or 4 in one layer. This is _e.g._ the terminology
suggested by the functions `doXFriSteps` and more generally in the `FriLayer`
contract. This is also the terminology we use in this report, as introduced in
Section 2.1 and according to the ethSTARK documentation [10].


  - In the functions


**–** `FriStatementVerifier.friVerifyLayers` (variable `nFriStepsLessOne` )


**–** `StarkVerifier.initVerifierParams` (variable `nFriSteps` )


the usage of “step” refers to the notion of layer.


**Recommendation:** We recommend to clearly define the notion of “step” and to fix
the variable names accordingly.


**Status:** **Partially** **resolved** **(** **_∼_** **)**
Some variables have been renamed ( `friStep` into `friStepSizes`, `nFriStepsLessOne`
into `nFriInnerLayers`, ...). The notion of “step” then seems to refer to the transition
between two layers. There is only one step between two layers, but this step can have


Page 41/44


Code Review of StarkWare’s EVM STARK Verifier


several sizes (2, 3 or 4). However, some names remain inconsistent with this choice
( `doXFriSteps` for `X` _∈{_ 2 _,_ 3 _,_ 4 _}_, `doFriSteps` ).


Page 42/44


Code Review of StarkWare’s EVM STARK Verifier

### References


[1] Constant variables in inline assemby. Solidity Issues on GitHub, 2018. `[https://](https://github.com/ethereum/solidity/issues/3776)`
`[github.com/ethereum/solidity/issues/3776](https://github.com/ethereum/solidity/issues/3776)` .


[2] Support referencing another constants in inline assembly. Solidity Pull Requests on

GitHub, 2019. `[https://github.com/ethereum/solidity/pull/7874](https://github.com/ethereum/solidity/pull/7874)` .


[3] Solidity changelog. Solidity Repository on GitHub, 2021. `[https://github.com/](https://github.com/ethereum/solidity/blob/develop/Changelog.md)`
`[ethereum/solidity/blob/develop/Changelog.md](https://github.com/ethereum/solidity/blob/develop/Changelog.md)` .


[4] Eli Ben-Sasson, Iddo Bentov, Yinon Horesh, and Michael Riabzev. Fast reed-solomon

interactive oracle proofs of proximity. In Ioannis Chatzigiannakis, Christos Kaklamanis, Dániel Marx, and Donald Sannella, editors, _45th International Colloquium on Au-_
_tomata,_ _Languages,_ _and_ _Programming,_ _ICALP_ _2018,_ _July_ _9-13,_ _2018,_ _Prague,_ _Czech_
_Republic_, volume 107 of _LIPIcs_, pages 14:1–14:17. Schloss Dagstuhl - Leibniz-Zentrum
für Informatik, 2018.


[5] Eli Ben-Sasson, Iddo Bentov, Yinon Horesh, and Michael Riabzev. Scalable, trans
parent, and post-quantum secure computational integrity. Cryptology ePrint Archive,
Report 2018/046, 2018. `[https://ia.cr/2018/046](https://ia.cr/2018/046)` .


[6] Eli Ben-Sasson, Alessandro Chiesa, and Nicholas Spooner. Interactive oracle proofs.

Cryptology ePrint Archive, Report 2016/116, 2016. `[https://ia.cr/2016/116](https://ia.cr/2016/116)` .


[7] Lior Goldberg, Shahar Papini, and Michael Riabzev. Cairo – a turing-complete stark
friendly cpu architecture. Cryptology ePrint Archive, Report 2021/1063, 2021. `[https:](https://ia.cr/2021/1063)`
`[//ia.cr/2021/1063](https://ia.cr/2021/1063)` .


[8] Kineret Segal and Gideon Kaempfer. Starkdex deep dive: the
stark core engine. Medium, 2019. `[https://medium.com/starkware/](https://medium.com/starkware/starkdex-deep-dive-the-stark-core-engine-497942d0f0ab)`
`[starkdex-deep-dive-the-stark-core-engine-497942d0f0ab](https://medium.com/starkware/starkdex-deep-dive-the-stark-core-engine-497942d0f0ab)` .


[9] StarkWare. Stark math. Medium, 2019. `[https://medium.com/starkware/tagged/](https://medium.com/starkware/tagged/stark-math)`

`[stark-math](https://medium.com/starkware/tagged/stark-math)` .


[10] StarkWare. ethstark documentation. Cryptology ePrint Archive, Report 2021/582,

2021. `[https://ia.cr/2021/582](https://ia.cr/2021/582)` .


[11] Gavin Wood. Ethereum: A secure decentralised generalised transaction ledger (rev.

2021-12-02), 2021. `[https://ethereum.github.io/yellowpaper/paper.pdf](https://ethereum.github.io/yellowpaper/paper.pdf)` .


Page 43/44


Code Review of StarkWare’s EVM STARK Verifier

### A Formal checking of doXFriSteps


As explained in Section 3.4.1, the functions `doXFriSteps` with `X` _∈{_ 2 _,_ 3 _,_ 4 _}_ compute an
evaluation _pi_ +1( _vi_ +1) from the 2 <sup>_ℓi_</sup> <sup>+1</sup> evaluations _pi_ ( _c · ξ_ <sup>_j_</sup> <sup>0</sup> ), _pi_ ( _c · ξ_ <sup>_j_</sup> <sup>1</sup> ), ... where


  - _j_ 0, _j_ 1, ... are in increasing bit-reverse order, _i.e._


_jr_ = bit-reverselog _|Li|_ ( _r_ ) _._


  - _ξ_ is a generator of the subgroup of F <sup>_×_</sup> _p_ <sup>of</sup> <sup>size</sup> <sup>2</sup> <sup>_ℓi_</sup> <sup>+1.</sup>


As written in Equation 3, the polynomial _pi_ +1 is built as




<sup>[</sup> _i_ <sup>_j_</sup> <sup>](</sup> <sup>_x_</sup> <sup>)</sup>



_pi_ +1( _x_ ) =



2 <sup>_ℓi_</sup> <sup>+1</sup> _−_ 1



_j_ =0



_ζi_ <sup>_j_</sup>



_i_ <sup>_j_</sup> <sup>_· p_</sup> <sup>[</sup> _i_ <sup>_j_</sup> <sup>]</sup>



where the _{p_ <sup>[</sup> _i_ <sup>_j_</sup> <sup>]</sup> <sup>_}j_</sup> <sup>are</sup> <sup>the</sup> <sup>polynomials</sup> <sup>defined</sup> <sup>such</sup> <sup>that</sup>



_pi_ ( _x_ ) =


We have the following relation



2 <sup>_ℓi_</sup> <sup>+1</sup> _−_ 1



_j_ =0



_x_ <sup>_j_</sup> _· p_ <sup>[</sup> _i_ <sup>_j_</sup> <sup>](</sup> <sup>_x_</sup> <sup>2</sup> <sup>_ℓi_</sup> <sup>+1</sup> <sup>)</sup> <sup>_._</sup>



_p_ <sup>[0]</sup>

_i_






































_p_ <sup>[0]</sup>

_i_ <sup>(</sup> <sup>_vi_</sup> <sup>+1)</sup>
_p_ <sup>[1]</sup>

_i_ <sup>(</sup> <sup>_vi_</sup> <sup>+1)</sup>
_p_ <sup>[2]</sup>

_i_ <sup>(</sup> <sup>_vi_</sup> <sup>+1)</sup>




<sup>[2]</sup>

_i_ <sup>(</sup> <sup>_vi_</sup> <sup>+1)</sup>




















1 _c · ξ_ <sup>_j_</sup> <sup>0</sup> ( _c · ξ_ <sup>_j_</sup> <sup>0</sup> ) <sup>2</sup> _. . ._
1 _c · ξ_ <sup>_j_</sup> <sup>1</sup> ( _c · ξ_ <sup>_j_</sup> <sup>1</sup> ) <sup>2</sup> _. . ._
1 _c · ξ_ <sup>_j_</sup> <sup>2</sup> ( _c · ξ_ <sup>_j_</sup> <sup>2</sup> ) <sup>2</sup> _. . ._
_. . ._



1 1 _. . ._
( _c · ξ_ <sup>_j_</sup> <sup>0</sup> ) <sup>_−_</sup> <sup>1</sup> ( _c · ξ_ <sup>_j_</sup> <sup>1</sup> ) <sup>_−_</sup> <sup>1</sup> _. . ._
( _c · ξ_ <sup>_j_</sup> <sup>0</sup> ) <sup>_−_</sup> <sup>2</sup> ( _c · ξ_ <sup>_j_</sup> <sup>1</sup> ) <sup>_−_</sup> <sup>2</sup> _. . ._
_. . ._





















_pi_ ( _c · ξ_ <sup>_j_</sup> <sup>0</sup> )
_pi_ ( _c · ξ_ <sup>_j_</sup> <sup>1</sup> )
_pi_ ( _c · ξ_ <sup>_j_</sup> <sup>2</sup> )

_. . ._








 <sup>=</sup>













since _c_ <sup>2</sup> <sup>_ℓi_</sup> <sup>+1</sup> = _vi_ +1. Thus,













_p_ <sup>[0]</sup>

_i_




<sup>[2]</sup>

_i_ <sup>(</sup> <sup>_vi_</sup> <sup>+1)</sup>



_p_ <sup>[0]</sup>

_i_ <sup>(</sup> <sup>_vi_</sup> <sup>+1)</sup>
_p_ <sup>[1]</sup>

_i_ <sup>(</sup> <sup>_vi_</sup> <sup>+1)</sup>
_p_ <sup>[2]</sup>

_i_ <sup>(</sup> <sup>_vi_</sup> <sup>+1)</sup>



_. . ._


_pi_ ( _c · ξ_ <sup>_j_</sup> <sup>0</sup> )
_pi_ ( _c · ξ_ <sup>_j_</sup> <sup>1</sup> )
_pi_ ( _c · ξ_ <sup>_j_</sup> <sup>2</sup> )

_. . ._

















 <sup>_._</sup>






 <u>1</u>

 2 <sup>_ℓi_</sup> <sup>+1</sup>
 <sup>=</sup>



_. . ._


So we have


2 <sup>_ℓi_</sup> <sup>+1</sup> _· pi_ +1( _vi_ +1) =












1 1 _. . ._
( _ξ_ <sup>_j_</sup> <sup>0</sup> ) <sup>_−_</sup> <sup>1</sup> ( _ξ_ <sup>_j_</sup> <sup>1</sup> ) <sup>_−_</sup> <sup>1</sup> _. . ._
( _ξ_ <sup>_j_</sup> <sup>0</sup> ) <sup>_−_</sup> <sup>2</sup> ( _ξ_ <sup>_j_</sup> <sup>1</sup> ) <sup>_−_</sup> <sup>2</sup> _. . ._
_. . ._



_pi_ ( _c · ξ_ <sup>_j_</sup> <sup>0</sup> )
_pi_ ( _c · ξ_ <sup>_j_</sup> <sup>1</sup> )
_pi_ ( _c · ξ_ <sup>_j_</sup> <sup>2</sup> )

_. . ._








 <sup>_._</sup>



1
_ζi/c_
( _ζi/c_ ) <sup>2</sup>

_. . ._



 _T_ <sup></sup>


 
 
 



The formal checking we applied to verify the correctness of the functions `do2FriSteps`,
`do3FriSteps` and `do3FriSteps` compares the outputs of these functions with the above
formula.


Page 44/44


