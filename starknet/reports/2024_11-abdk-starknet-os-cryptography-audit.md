#### v. 1.0 StarkWare

## Cryptography Audit
# OS

#### 21st November 2024


##### **Contents**

**1** **Changelog** **4**


**2** **Introduction** **5**


**3** **Project** **scope** **6**


**4** **Methodology** **8**


**5** **Our** **findings** **9**


**6** **Moderate** **Issues** **10**


CVF-1. INFO . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 10


CVF-2. FIXED . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 10


CVF-3. FIXED . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 11


CVF-4. INFO . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 11


CVF-5. INFO . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 11


CVF-6. INFO . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 12


CVF-7. INFO . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 12


CVF-8. INFO . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 13


CVF-9. INFO . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 13


CVF-10. FIXED . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 14


CVF-11. INFO . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 14


CVF-12. INFO . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 15


CVF-13. FIXED . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 15


CVF-14. INFO . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 15


CVF-15. INFO . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 16


CVF-16. INFO . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 16


CVF-17. INFO . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 16


CVF-18. INFO . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 17


CVF-19. FIXED . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 17


**7** **Minor** **Issues** **18**


CVF-20. FIXED . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 18


CVF-21. INFO . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 19


CVF-22. INFO . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 20


CVF-23. FIXED . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 20


CVF-24. INFO . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 20


CVF-25. FIXED . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 20


CVF-26. FIXED . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 21


CVF-27. FIXED . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 21


CVF-28. FIXED . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 21


CVF-29. INFO . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 22


CVF-30. INFO . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 22


CVF-31. INFO . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 23


CVF-32. FIXED . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 23


CVF-33. FIXED . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 24


CVF-34. INFO . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 24


CVF-35. INFO . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 24


##### **1 Changelog**

# Date Author Description


0.1 21.11.24 A. Zveryanskaya Initial Draft


0.2 21.11.24 A. Zveryanskaya Minor revision


1.0 21.11.24 A. Zveryanskaya Release



4


##### **2 Introduction**

**All** **modifications** **to** **this** **document** **are** **prohibited.** **Violators** **will** **be** **prosecuted** **to** **the**


**full** **extent** **of** **the** **U.S.** **law.**


The following document provides the result of the audit performed by ABDK Consulting


(Mikhail Vladimirov and Dmitry Khovratovich) at the customer request. The audit goal is


a general review of the smart contracts structure, critical/major bugs detection and


issuing the general recommendations.


StarkWare Industries is an Israeli software company that specializes in cryptography. It


develops zero-knowledge proof technology that compresses information to address the


scalability problem of the blockchain, and works on the Ethereum platform.


5


##### **3 Project scope**

We were asked to review the update to the Cairo [library.](https://github.com/starkware-libs/cairo-lang/compare/v0.10.1...v0.12.1)


Files:


**cairo/builtin_keccak/**


keccak.cairo


**cairo/builtin_poseidon/**


poseidon.cairo


**cairo/cairo_keccak/**


keccak.cairo


**cairo/cairo_secp/**


constants.cairo ec.cairo signature.cairo


field.cairo bigint.cairo


**cairo/keccak_utils/**


keccak_utils.cairo


**cairo/**


hash_state

cairo_builtins.cairo hash_chain.cairo

_poseidon.cairo


patricia_with

hash_state.cairo patricia_utils.cairo

_poseidon.cairo


patricia.cairo poseidon_state.cairo sponge_as_hash.cairo


uint256.cairo


**starknet/contract_class/**


compiled_class.cairo contract_class.cairo


**starknet/execution/**



deprecated


_execute_syscalls.cairo


execute


_transactions.cairo



execute


_entry_point.cairo



execute_syscalls.cairo



6


**starknet/**



block_context.cairo builtins.cairo constants.cairo


contracts.cairo os.cairo output.cairo


state.cairo transactions.cairo



7


##### **4 Methodology**

The methodology is not a strict formal procedure, but rather a selection of methods and


tactics combined differently and tuned for each particular project, depending on the


project structure and technologies used, as well as on client expectations from the audit.


  - **General** **Code** **Assessment** . The code is reviewed for clarity, consistency, style,


and for whether it follows best code practices applicable to the particular


programming language used. We check indentation, naming convention,


commented code blocks, code duplication, confusing names, confusing,


irrelevant, or missing comments etc. At this phase we also understand overall


code structure.


  - **Entity** **Usage** **Analysis** . Usages of various entities defined in the code are


analysed. This includes both: internal usages from other parts of the code as well


as potential external usages. We check that entities are defined in proper places


as well as their visibility scopes and access levels are relevant. At this phase, we


understand overall system architecture and how different parts of the code are


related to each other.


  - **Access** **Control** **Analysis** . For those entities, that could be accessed externally,


access control measures are analysed. We check that access control is relevant


and done properly. At this phase, we understand user roles and permissions, as


well as what assets the system ought to protect.


  - **Code** **Logic** **Analysis** . The code logic of particular functions is analysed for


correctness and efficiency. We check if code actually does what it is supposed to


do, if that algorithms are optimal and correct, and if proper data types are used.


We also make sure that external libraries used in the code are up to date and


relevant to the tasks they solve in the code. At this phase we also understand data


structures used and the purposes they are used for.


We classify issues by the following severity levels:


  - **Critical** **issue** directly affects the smart contract functionality and may cause a


significant loss.


  - **Major** **issue** is either a solid performance problem or a sign of misuse: a slight


code modification or environment change may lead to loss of funds or data.


Sometimes it is an abuse of unclear code behaviour which should be double


checked.


  - **Moderate** **issue** is not an immediate problem, but rather suboptimal performance


in edge cases, an obviously bad code practice, or a situation where the code is


correct only in certain business flows.


  - **Minor** **issues** contain code style, best practices and other recommendations.


8


##### **5 Our findings**

We provided the Client with a few recommendations.


### **0**

#### **0**

**14** **5**


**8** **8**


9


##### **6 Moderate Issues**

**CVF-1.** **INFO**


    - **Category** Unclear behavior    - **Source** execute_syscalls.cairo


**Description** It seems that reasons spanning several felts are supported in the “Failur

eReason” structure, but this code only allows reasons one felt long.


**Recommendation** Consider either fully supporting reasons of multiple felts or removing


support for them from the structure.


**Client** **Comment** _At_ _the_ _moment_ _failed_ _executions_ _don’t_ _reach_ _the_ _OS,_ _and_ _are_ _charged_ _in_ _a_


_trusted_ _manner_ _(only_ _check_ _is_ _that_ _max_fee_ _>=_ _actual_fee)._ _Thus,_ _we_ _never_ _really_ _handle_


_failed_ _executions_ _in_ _the_ _OS_ _curretly,_ _so_ _this_ _is_ _only_ _partially_ _implemented_ _to_ _support_ _a_ _1_ _felt_


_failure_ _reason._ _Before_ _we_ _fully_ _enable_ _it,_ _and_ _pass_ _through_ _the_ _OS_ _for_ _failed_ _executions,_


_we_ _will_ _handle_ _failure_ _reasons_ _properly._


1080 <mark>+//</mark> <mark>Write</mark> <mark>the</mark> <mark>failure</mark> <mark>reason.</mark>

1081 <mark>+tempvar</mark> <mark>start</mark> <mark>=</mark> <mark>failure_reason.start;</mark>

1082 <mark>+</mark> **<mark>assert</mark>** <mark>start[0]</mark> <mark>=</mark> <mark>failure_felt;</mark>

1083 <mark>+</mark> **<mark>assert</mark>** <mark>failure_reason.end</mark> <mark>=</mark> <mark>start</mark> <mark>+</mark> <mark>1;</mark>


**CVF-2.** **FIXED**


    - **Category** Unclear behavior    - **Source** execute_transactions.cairo


**Description** This limits the maximum fee by 2^128.


**Recommendation** Consider either removing this limitation or clearly stating it.


**Client** **Comment** _We_ _will_ _add_ _a_ _comment_ _that_ _the_ _fee_ _is_ _limited_ _by_ _2**128._


249 <mark>+amount=</mark> **<mark>Uint256</mark>** <mark>(low=nondet</mark> <mark>%{</mark> <mark>execution_helper.tx_execution_info.</mark>

_<mark>�→</mark>_ <mark>actual_fee</mark> <mark>%},</mark> <mark>high=0),</mark>


10


**CVF-3.** **FIXED**


    - **Category** Unclear behavior    - **Source** compiled_class.cairo


**Description** It is unclear how exactly builtins are encoded and how they are ordered.


**Recommendation** Consider clarifying.


**Client** **Comment** _We_ _will_ _add_ _a_ _comment_ _that_ _describes_ _the_ _expected_ _order_ _of_ _builtins_


_(the_ _Cairo_ _0_ _compiler_ _didn’t_ _compile_ _when_ _the_ _order_ _was_ _wrong)._ _This_ _is_ _relied_ _upon_ _in_


_select_builtins.cairo,_ _and_ _checked_ _(for_ _Cairo_ _>=_ _1)_ _in_ _the_ _Sierra_ _to_ _CASM_ _compiler._


22 <mark>+//</mark> <mark>'builtin_list'</mark> <mark>is</mark> <mark>a</mark> <mark>continuous</mark> <mark>memory</mark> <mark>segment</mark> <mark>containing</mark> <mark>the</mark>

_<mark>�→</mark>_ <mark>ASCII</mark> <mark>encoding</mark> <mark>of</mark> <mark>the</mark> <mark>(ordered)</mark>


**CVF-4.** **INFO**


    - **Category** Suboptimal    - **Source** compiled_class.cairo


**Recommendation** As the compiled class version is a constant, and it is the first value


hashed, then the hash state after it could be precomputed.


**Client** **Comment** _Here_ _Poseidon_ _is_ _used,_ _so_ _the_ _element_ _is_ _added_ _to_ _a_ _list,_ _and_ _eventually_


_we’ll_ _do_ _length/2_ _hades_ _permutations._ _It’s_ _not_ _clear_ _what_ _to_ _precompute_ _in_ _this_ _case_


_(unlike_ _the_ _older_ _Pedersen_ _case)._ _A_ _single_ _hash_ _in_ _the_ _entire_ _OS_ _execution_ _is_ _not_ _very_


_concerning._


86 <mark>+hash_update_single(item=compiled_class.compiled_class_version);</mark>


**CVF-5.** **INFO**


    - **Category** Suboptimal    - **Source** contract_class.cairo


**Recommendation** As the contract class version is a constant, and it is the first value


hashed, then the hash state after it could be precomputed.


**Client** **Comment** _Same_ _as_ _above._


50 <mark>+hash_update_single(item=contract_class.contract_class_version);</mark>


11


**CVF-6.** **INFO**


    - **Category** Documentation    - **Source** state.cairo


**Description** The description of the arguments taken and the actual argument doesn’t


seems to match each other.


**Recommendation** Consider describing individual arguments in more details.


**Client** **Comment** _class_changes_ _is_ _a_ _mapping_ _class_hash_ _→compiled_class_hash_ _for_ _de-_


_clares_ _within_ _that_ _block,_ _hashed_class_changes_ _is_ _a_ _mapping_ _that_ _is_ _filled_ _throughout_ _the_


_function_ _from_ _class_hash_ _to_ _the_ _actual_ _leaf_ _content_ _in_ _the_ _classes_ _tree._ _I_ _think_ _it_ _matches_


_the_ _current_ _description,_ _we’ll_ _try_ _to_ _make_ _the_ _comment_ _clearer._


257 <mark>+//</mark> <mark>Takes</mark> <mark>a</mark> <mark>dict</mark> <mark>mapping</mark> <mark>class</mark> <mark>hash</mark> <mark>to</mark> <mark>compiled</mark> <mark>class</mark> <mark>hash</mark> <mark>and</mark>

_<mark>�→</mark>_ <mark>produces</mark>


261 <mark>+</mark> <mark>n_class_updates:</mark> <mark>felt,</mark> <mark>class_changes:</mark> <mark>DictAccess*,</mark>
_<mark>�→</mark>_ <mark>hashed_class_changes:</mark> <mark>DictAccess*</mark>


**CVF-7.** **INFO**


    - **Category** Documentation    - **Source** keccak.cairo


**Description** The semantics of ‘n_bytes‘ parameter is unclear and may lead to errors.


**Recommendation** Consider specifying,


129 <mark>+inputs:</mark> <mark>felt*,</mark> <mark>n_bytes:</mark> <mark>felt</mark>


140 <mark>+inputs:</mark> <mark>felt*,</mark> <mark>n_bytes:</mark> <mark>felt</mark>


149 <mark>+inputs:</mark> <mark>felt*,</mark> <mark>n_bytes:</mark> <mark>felt</mark>


12


**CVF-8.** **INFO**


    - **Category** Suboptimal    - **Source** keccak.cairo


**Description** This function makes 44 128-bit range checks, which is a huge number for


processing 1088 bits of data.


**Recommendation** It would be much more efficient to make inputs[] array of 128-bit num

bers, range-check them with 10 checks, and then split into two parts each, spending at


most 20 more checks. Even better way is to check smaller chunks with dedicated check


functions.


**Client** **Comment** _These_ _rangechecks_ _are_ _negligible_ _compared_ _to_ _the_ _keccak_ _builtin._ _We_


_may_ _optimize_ _in_ _the_ _future._


161 <mark>+func</mark> <mark>_prepare_full_block{range_check_ptr,</mark> <mark>bitwise_ptr:</mark>

_<mark>�→</mark>_ <mark>BitwiseBuiltin*,</mark> <mark>keccak_ptr:</mark> <mark>KeccakBuiltin*}(</mark>


**CVF-9.** **INFO**


    - **Category** Suboptimal    - **Source** hash_state_poseidon.cairo


**Recommendation** It would probably be more efficient to directly feed inputs into sponge,


rather than accumulating them in memory first.


**Client** **Comment** _We_ _considered_ _it_ _in_ _the_ _past_ _but_ _reached_ _the_ _opposite_ _conclusion._ _Feed-_


_ing_ _it_ _directly_ _to_ _the_ _sponge_ _would_ _force_ _us_ _to_ _pass_ _the_ _builtin_ptr_ _and_ _keep_ _track_ _of_ _the_


_parity_ _of_ _the_ _#_ _of_ _arguments,_ _which_ _turns_ _out_ _to_ _be_ _more_ _expensive._


52 <mark>+let</mark> <mark>(hash)</mark> <mark>=</mark> <mark>poseidon_hash_many(n=hash_state.end</mark> <mark>-</mark> <mark>hash_state.start</mark>

_<mark>�→</mark>_ <mark>,</mark> <mark>elements=hash_state.start);</mark>


13


**CVF-10.** **FIXED**


    - **Category** Procedural    - **Source** sponge_as_hash.cairo


**Description** The naming is inconsistent in many aspects: 1. Inputs use different letters


(“x” and “y”), while outputs use indexes: (“result”, “result1”). 2. Only one of two outputs


has index. 3. Naming for capacity input and output differs from naming for other fields.


**Recommendation** A consistent naming would be, for example: x_in, y_in, c_in, x_out,


y_out, c_out


**Client** **Comment** _Will_ _consider_ _renaming_ _the_ _stuct_ _members_ _(elsewhere_ _they_ _are_ _called_


_s0,s1,s2)._


8 <mark>+x:</mark> <mark>felt,</mark>

9 <mark>+y:</mark> <mark>felt,</mark>

10 <mark>+c_in:</mark> <mark>felt,</mark>

11 <mark>+result:</mark> <mark>felt,</mark>

12 <mark>+result1:</mark> <mark>felt,</mark>

13 <mark>+c_out:</mark> <mark>felt,</mark>


**CVF-11.** **INFO**


    - **Category** Unclear behavior    - **Source** execute_syscalls.cairo


**Description** There is no range check for the “request..y_parity”.


**Recommendation** Consider implementing an appropriate check.


**Client** **Comment** _It_ _is_ _checked_ _inside_ _try_get_point_from_x_ _(assert_nn)._ _With_ _regards_ _to_


_completeness,_ _in_ _Sierra_ _this_ _syscall_ _expects_ _bool_ _which_ _is_ _guranteed_ _to_ _be_ _0_ _or_ _1._


981 <mark>+let</mark> <mark>(is_on_curve)</mark> <mark>=</mark> <mark>try_get_point_from_x(x=x,</mark> <mark>v=request.y_parity,</mark>

_<mark>�→</mark>_ <mark>result=response.ec_point);</mark>


14


**CVF-12.** **INFO**


    - **Category** Unclear behavior    - **Source** execute_syscalls.cairo


**Description** There are no range checks for these values.


**Recommendation** Consider implementing appropriate checks.


**Client** **Comment** _Guranteed_ _by_ _Sierra,_ _the_ _inputs_ _to_ _these_ _syscalls_ _is_ _u256,_ _which_ _is_ _two_


_u128_ _that_ _are_ _guranteed_ _to_ _be_ _of_ _the_ _apprpriate_ _size_ _(execute_syscalls.cairo_ _only_ _deals_


_with_ _Cairo_ _>=_ _1_ _syscalls)._


1002 <mark>+let</mark> <mark>(x)</mark> <mark>=</mark> <mark>bigint_to_uint256(ec_point.x);</mark>

1003 <mark>+let</mark> <mark>(y)</mark> <mark>=</mark> <mark>bigint_to_uint256(ec_point.y);</mark>


**CVF-13.** **FIXED**


    - **Category** Unclear behavior    - **Source** execute_transactions.cairo


**Description** This logic allows one to avoid paying fee just by setting max_fee to zero.


**Client** **Comment** _This_ _is_ _used_ _in_ _testing,_ _will_ _be_ _removed_ _in_ _the_ _future._


237 <mark>+</mark> **<mark>if</mark>** <mark>(max_fee</mark> <mark>==</mark> <mark>0)</mark> <mark>{</mark>

238 <mark>+</mark> **<mark>return</mark>** <mark>();</mark>

239 <mark>+}</mark>


**CVF-14.** **INFO**


    - **Category** Unclear behavior    - **Source** compiled_class.cairo


**Description** This function doesn’t verify that “builtin_list” is properly ordered and contains


only valid builtins.


**Client** **Comment** _True._ _compiled_class.cairo_ _deals_ _with_ _the_ _image_ _of_ _the_ _Sierra⟶CASM_


_compiler,_ _which_ _checks_ _the_ _values_ _and_ _order_ _of_ _the_ _builtins._ _ATM_ _compilation_ _is_ _han-_


_dled_ _by_ _the_ _sequencer_ _(user_ _signs_ _the_ _compiled_ _artifcat),_ _in_ _the_ _future_ _we_ _may_ _have_ _”full_


_Sierra”,_ _which_ _means_ _verifying_ _this_ _compilation_ _in_ _the_ _OS._


63 <mark>+func</mark> <mark>validate_entry_points_inner{range_check_ptr}(</mark>


15


**CVF-15.** **INFO**


    - **Category** Documentation    - **Source** compiled_class.cairo


**Description** The hashing is done using some tree-like structure in order to get different


hashes for different classes. It is not clear though how different classes can be.


**Recommendation** Consider writing explicitly which kind of classes is supported.


**Client** **Comment** _This_ _code_ _computes_ _the_ _hash_ _of_ _a_ _single_ _compiled_ _class,_ _there_ _are_ _no_


_different_ _types_ _(unless_ _you_ _consider_ _deprecated_compiled_class,_ _which_ _represents_ _cairo_


_0)._ _Will_ _add_ _to_ _the_ _starknet_ _docs_ _how_ _are_ _compiled_ _classes_ _hashed,_ _does_ _it_ _answer_ _the_


_question?_


84 <mark>+let</mark> <mark>hash_state:</mark> <mark>HashState</mark> <mark>=</mark> <mark>hash_init();</mark>


**CVF-16.** **INFO**


    - **Category** Procedural    - **Source** builtins.cairo


**Description** The function doesn’t actually implement this logic.


97 <mark>+//</mark> <mark>For</mark> <mark>the</mark> <mark>non-selected</mark> <mark>builtins</mark> <mark>(that</mark> <mark>is,</mark> <mark>selectable</mark> <mark>builtins</mark> <mark>that</mark>

_<mark>�→</mark>_ <mark>do</mark> <mark>not</mark> <mark>appear</mark> <mark>in</mark>

98 <mark>+//</mark> <mark>`selected_encodings`),</mark> <mark>this</mark> <mark>function</mark> <mark>validates</mark> <mark>that</mark> <mark>the</mark>

_<mark>�→</mark>_ <mark>difference</mark> <mark>is</mark> <mark>nonnegative</mark>

99 <mark>+//</mark> <mark>(that</mark> <mark>is,</mark> <mark>they</mark> <mark>weren't</mark> <mark>moved</mark> <mark>backward)</mark> <mark>and</mark> <mark>divisible</mark> <mark>by</mark> <mark>the</mark>

_<mark>�→</mark>_ <mark>builtin</mark> <mark>size.</mark>


**CVF-17.** **INFO**


    - **Category** Suboptimal    - **Source** signature.cairo


**Description** Here ’verify_zero()‘ is called several times internally.


**Recommendation** Consider calling it directly instead.


147 <mark>+let</mark> <mark>(reduced_diff)</mark> <mark>=</mark> <mark>reduce(diff);</mark>


149 <mark>+</mark> **<mark>return</mark>** <mark>is_zero(reduced_diff);</mark>


16


**CVF-18.** **INFO**


    - **Category** Flaw    - **Source** keccak.cairo


**Description** This condition is not checked with explicit constraints, and is only implicitly


checked.


**Recommendation** Consider checking explcitly.


**Client** **Comment** _The_ _only_ _way_ _to_ _exploit_ _this_ _is_ _instead_ _of_ _doing_ _n_bytes/rate_ _number_ _of_


_iterations,_ _we_ _can_ _do_ _(n_bytes+prime)/rate,_ _which_ _is_ _impossible_ _in_ _practice._


358 <mark>+</mark> **<mark>if</mark>** <mark>(nondet</mark> <mark>%{</mark> <mark>ids.n_bytes</mark> <mark>>=</mark> <mark>ids.KECCAK_FULL_RATE_IN_BYTES</mark> <mark>%}</mark> <mark>!=</mark> <mark>0)</mark>

_<mark>�→</mark>_ <mark>{</mark>


**CVF-19.** **FIXED**


    - **Category** Procedural    - **Source** sponge_as_hash.cairo


**Description** The capacity initialization constants are scattered across files and may col

lide.


**Recommendation** Consider defining them in a single file.


**Client** **Comment** _Will_ _consider_ _initializing_ _to_ _”2”_ _in_ _one_ _place._


3 <mark>+//</mark> <mark>c_in</mark> <mark>-</mark> <mark>the</mark> <mark>capacity</mark> <mark>part</mark> <mark>of</mark> <mark>the</mark> <mark>input</mark> <mark>(must</mark> <mark>be</mark> <mark>initialized</mark> <mark>to</mark> <mark>a</mark>

_<mark>�→</mark>_ <mark>constant,</mark> <mark>we</mark> <mark>use</mark> <mark>2).</mark>


17


##### **7 Minor Issues**

**CVF-20.** **FIXED**


    - **Category** Documentation    - **Source** compiled_class.cairo


**Recommendation** Consider explaining why there are 5 nonzero entries.


**Client** **Comment** _Will_ _add_ _a_ _comment_ _that_ _explains_ _it_ _(currently_ _the_ _Cairo_ _>=_ _1_ _gas_ _mech-_


_anism_ _is_ _not_ _in_ _use)._


172 <mark>+</mark> **<mark>assert</mark>** <mark>builtin_costs[0]</mark> <mark>=</mark> <mark>0;</mark>

173 <mark>+</mark> **<mark>assert</mark>** <mark>builtin_costs[1]</mark> <mark>=</mark> <mark>0;</mark>

174 <mark>+</mark> **<mark>assert</mark>** <mark>builtin_costs[2]</mark> <mark>=</mark> <mark>0;</mark>

175 <mark>+</mark> **<mark>assert</mark>** <mark>builtin_costs[3]</mark> <mark>=</mark> <mark>0;</mark>

176 <mark>+</mark> **<mark>assert</mark>** <mark>builtin_costs[4]</mark> <mark>=</mark> <mark>0;</mark>


18


**CVF-21.** **INFO**


    - **Category** Bad datatype    - **Source** constants.cairo


**Recommendation** The numeric quotients used in these expressions should be named


constants.


**Client** **Comment** _numerics_ _only_ _multiply_ _#_ _of_ _steps_ _or_ _#_ _of_ _range_ _checks,_ _with_ _dedicated_


_constants_ _the_ _code_ _will_ _look_ _worse_ _(we’ll_ _need_ _consts_ _per_ _each_ _syscall)._


74 <mark>+const</mark> <mark>ENTRY_POINT_GAS_COST</mark> <mark>=</mark> <mark>ENTRY_POINT_INITIAL_BUDGET</mark> <mark>+</mark> <mark>500</mark> <mark>*</mark>

_<mark>�→</mark>_ <mark>STEP_GAS_COST;</mark>


76 <mark>+const</mark> <mark>FEE_TRANSFER_GAS_COST</mark> <mark>=</mark> <mark>ENTRY_POINT_GAS_COST</mark> <mark>+</mark> <mark>100</mark> <mark>*</mark>

_<mark>�→</mark>_ <mark>STEP_GAS_COST;</mark>


79 <mark>+const</mark> <mark>TRANSACTION_GAS_COST</mark> <mark>=</mark> <mark>(2</mark> <mark>*</mark> <mark>ENTRY_POINT_GAS_COST)</mark> <mark>+</mark>

_<mark>�→</mark>_ <mark>FEE_TRANSFER_GAS_COST</mark> <mark>+</mark> <mark>(</mark>


83 <mark>+const</mark> <mark>CALL_CONTRACT_GAS_COST</mark> <mark>=</mark> <mark>SYSCALL_BASE_GAS_COST</mark> <mark>+</mark> <mark>10</mark> <mark>*</mark>

_<mark>�→</mark>_ <mark>STEP_GAS_COST</mark> <mark>+</mark> <mark>ENTRY_POINT_GAS_COST;</mark>

84 <mark>+const</mark> <mark>DEPLOY_GAS_COST</mark> <mark>=</mark> <mark>SYSCALL_BASE_GAS_COST</mark> <mark>+</mark> <mark>200</mark> <mark>*</mark> <mark>STEP_GAS_COST</mark>

_<mark>�→</mark>_ <mark>+</mark> <mark>ENTRY_POINT_GAS_COST;</mark>

85 <mark>+const</mark> <mark>GET_BLOCK_HASH_GAS_COST</mark> <mark>=</mark> <mark>SYSCALL_BASE_GAS_COST</mark> <mark>+</mark> <mark>50</mark> <mark>*</mark>

_<mark>�→</mark>_ <mark>STEP_GAS_COST;</mark>

86 <mark>+const</mark> <mark>GET_EXECUTION_INFO_GAS_COST</mark> <mark>=</mark> <mark>SYSCALL_BASE_GAS_COST</mark> <mark>+</mark> <mark>10</mark> <mark>*</mark>

_<mark>�→</mark>_ <mark>STEP_GAS_COST;</mark>


88 <mark>+const</mark> <mark>REPLACE_CLASS_GAS_COST</mark> <mark>=</mark> <mark>SYSCALL_BASE_GAS_COST</mark> <mark>+</mark> <mark>50</mark> <mark>*</mark>

_<mark>�→</mark>_ <mark>STEP_GAS_COST;</mark>

89 <mark>+const</mark> <mark>STORAGE_READ_GAS_COST</mark> <mark>=</mark> <mark>SYSCALL_BASE_GAS_COST</mark> <mark>+</mark> <mark>50</mark> <mark>*</mark>

_<mark>�→</mark>_ <mark>STEP_GAS_COST;</mark>

90 <mark>+const</mark> <mark>STORAGE_WRITE_GAS_COST</mark> <mark>=</mark> <mark>SYSCALL_BASE_GAS_COST</mark> <mark>+</mark> <mark>50</mark> <mark>*</mark>

_<mark>�→</mark>_ <mark>STEP_GAS_COST;</mark>

91 <mark>+const</mark> <mark>EMIT_EVENT_GAS_COST</mark> <mark>=</mark> <mark>SYSCALL_BASE_GAS_COST</mark> <mark>+</mark> <mark>10</mark> <mark>*</mark>

_<mark>�→</mark>_ <mark>STEP_GAS_COST;</mark>

92 <mark>+const</mark> <mark>SEND_MESSAGE_TO_L1_GAS_COST</mark> <mark>=</mark> <mark>SYSCALL_BASE_GAS_COST</mark> <mark>+</mark> <mark>50</mark> <mark>*</mark>

_<mark>�→</mark>_ <mark>STEP_GAS_COST;</mark>


94 <mark>+const</mark> <mark>SECP256K1_ADD_GAS_COST</mark> <mark>=</mark> <mark>SYSCALL_BASE_GAS_COST</mark> <mark>+</mark> <mark>254</mark> <mark>*</mark>

_<mark>�→</mark>_ <mark>STEP_GAS_COST</mark> <mark>+</mark> <mark>29</mark> <mark>*</mark>


96 <mark>+const</mark> <mark>SECP256K1_GET_POINT_FROM_X_GAS_COST</mark> <mark>=</mark> <mark>SYSCALL_BASE_GAS_COST</mark> <mark>+</mark>

_<mark>�→</mark>_ <mark>260</mark> <mark>*</mark> <mark>STEP_GAS_COST</mark> <mark>+</mark> <mark>30</mark> <mark>*</mark>


98 <mark>+const</mark> <mark>SECP256K1_GET_XY_GAS_COST</mark> <mark>=</mark> <mark>SYSCALL_BASE_GAS_COST</mark> <mark>+</mark> <mark>24</mark> <mark>*</mark>

_<mark>�→</mark>_ <mark>STEP_GAS_COST</mark> <mark>+</mark> <mark>9</mark> <mark>*</mark>


100 <mark>+const</mark> <mark>SECP256K1_MUL_GAS_COST</mark> <mark>=</mark> <mark>SYSCALL_BASE_GAS_COST</mark> <mark>+</mark> <mark>121810</mark> <mark>*</mark>

_<mark>�→</mark>_ <mark>STEP_GAS_COST</mark> <mark>+</mark> <mark>10739</mark> <mark>*</mark>


102 <mark>+const</mark> <mark>SECP256K1_NEW_GAS_COST</mark> <mark>=</mark> <mark>SYSCALL_BASE_GAS_COST</mark> <mark>+</mark> <mark>340</mark> <mark>*</mark>

_<mark>�→</mark>_ <mark>STEP_GAS_COST</mark> <mark>+</mark> <mark>36</mark> <mark>*</mark>


19


**CVF-22.** **INFO**


    - **Category** Bad datatype    - **Source** output.cairo


**Recommendation** This value should be a named constant.


**Client** **Comment** _This_ _is_ _defined_ _only_ _in_ _the_ _hint,_ _we_ _can_ _an_ _import_ _of_ _the_ _constant_ _but_ _it_


_will_ _be_ _pretty_ _much_ _the_ _same._


91 <mark>+max_page_size</mark> <mark>=</mark> <mark>3800</mark>


**CVF-23.** **FIXED**


    - **Category** Documentation    - **Source** os.cairo


**Recommendation** Consider writing explicitly which bound is asserted this way and why


too big positive numbers are not a problem.


**Client** **Comment** _We’ll_ _add_ _a_ _comment_ _that_ _we’re_ _only_ _storing_ _block_ _hashes_ _>=10_ _blocks_


_in_ _the_ _past._


172 <mark>+let</mark> <mark>is_old_block_number_non_negative</mark> <mark>=</mark> <mark>is_nn(old_block_number);</mark>


**CVF-24.** **INFO**


    - **Category** Unclear behavior    - **Source** signature.cairo


**Description** It is possible to pass the sign not in the parity bit but as a quadratic


residue/non-residue in the starknet field. Then to assert the choice for y it is enough


to verify that y/v is a square in the starknet field, with just a few multiplications.


243 <mark>+assert_nn((y.d0</mark> <mark>+</mark> <mark>v)</mark> <mark>/</mark> <mark>2);</mark>


**CVF-25.** **FIXED**


    - **Category** Suboptimal    - **Source** keccak.cairo


**Recommendation** These functions are very similar and could be merged into one function


with an additional argument “bigend”.


**Client** **Comment** _Will_ _unify._


27 <mark>+func</mark> <mark>keccak_uint256s{range_check_ptr,</mark> <mark>bitwise_ptr:</mark> <mark>BitwiseBuiltin*,</mark>

_<mark>�→</mark>_ <mark>keccak_ptr:</mark> <mark>KeccakBuiltin*}(</mark>


42 <mark>+func</mark> <mark>keccak_uint256s_bigend{</mark>


20


**CVF-26.** **FIXED**


    - **Category** Documentation    - **Source** keccak.cairo


**Recommendation** Consider explaining how field elements are converted to bitstrings.


**Client** **Comment** _Will_ _document._


55 <mark>+//</mark> <mark>Computes</mark> <mark>the</mark> <mark>keccak</mark> <mark>hash</mark> <mark>of</mark> <mark>multiple</mark> <mark>field</mark> <mark>elements.</mark>

56 <mark>+func</mark> <mark>keccak_felts{range_check_ptr,</mark> <mark>bitwise_ptr:</mark> <mark>BitwiseBuiltin*,</mark>

_<mark>�→</mark>_ <mark>keccak_ptr:</mark> <mark>KeccakBuiltin*}(</mark>


69 <mark>+//</mark> <mark>Computes</mark> <mark>the</mark> <mark>keccak</mark> <mark>hash</mark> <mark>of</mark> <mark>multiple</mark> <mark>field</mark> <mark>elements</mark> <mark>(big-endian)</mark>

_<mark>�→</mark>_ <mark>.</mark>

70 <mark>+//</mark> <mark>Note</mark> <mark>that</mark> <mark>both</mark> <mark>the</mark> <mark>output</mark> <mark>and</mark> <mark>the</mark> <mark>input</mark> <mark>are</mark> <mark>in</mark> <mark>big</mark> <mark>endian</mark>

_<mark>�→</mark>_ <mark>representation.</mark>

71 <mark>+func</mark> <mark>keccak_felts_bigend{range_check_ptr,</mark> <mark>bitwise_ptr:</mark>

_<mark>�→</mark>_ <mark>BitwiseBuiltin*,</mark> <mark>keccak_ptr:</mark> <mark>KeccakBuiltin*}(</mark>


**CVF-27.** **FIXED**


    - **Category** Suboptimal    - **Source** keccak.cairo


**Recommendation** These functions are very similar and could be merged into one function


with an additional argument “bigend”.


**Client** **Comment** _Will_ _unify._


56 <mark>+func</mark> <mark>keccak_felts{range_check_ptr,</mark> <mark>bitwise_ptr:</mark> <mark>BitwiseBuiltin*,</mark>

_<mark>�→</mark>_ <mark>keccak_ptr:</mark> <mark>KeccakBuiltin*}(</mark>


71 <mark>+func</mark> <mark>keccak_felts_bigend{range_check_ptr,</mark> <mark>bitwise_ptr:</mark>

_<mark>�→</mark>_ <mark>BitwiseBuiltin*,</mark> <mark>keccak_ptr:</mark> <mark>KeccakBuiltin*}(</mark>


**CVF-28.** **FIXED**


    - **Category** Documentation    - **Source** keccak.cairo


**Recommendation** Consider describing the formula calculated by this function.


**Client** **Comment** _Will_ _document._


84 <mark>+//</mark> <mark>Converts</mark> <mark>a</mark> <mark>final</mark> <mark>state</mark> <mark>of</mark> <mark>the</mark> <mark>Keccak</mark> <mark>builtin</mark> <mark>to</mark> <mark>the</mark> <mark>hash</mark> <mark>output</mark>

_<mark>�→</mark>_ <mark>as</mark> <mark>`Uint256`.</mark>


21


**CVF-29.** **INFO**


    - **Category** Suboptimal    - **Source** keccak.cairo


**Recommendation** These checks could be simplified as: 256**9   - 1   - output0_high


256**7   - 1   - output1_low 256**2   - 1   - output1_high


**Client** **Comment** _Negligible_ _(and_ _the_ _power_ _operations_ _are_ _computed_ _in_ _compile_ _time)._


99 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>2]</mark> <mark>=</mark> <mark>output0_high</mark> <mark>-</mark> <mark>256</mark> <mark>**</mark> <mark>9</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>


110 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>6]</mark> <mark>=</mark> <mark>output1_low</mark> <mark>-</mark> <mark>256</mark> <mark>**</mark> <mark>7</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>

111 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>7]</mark> <mark>=</mark> <mark>output1_high</mark> <mark>-</mark> <mark>256</mark> <mark>**</mark> <mark>2</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>


**CVF-30.** **INFO**


    - **Category** Suboptimal    - **Source** keccak.cairo


**Recommendation** This could be simplified as: 256**n   - 1   - inputs[i]


**Client** **Comment** _Same_ _as_ _above._


166 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>1]</mark> <mark>=</mark> <mark>inputs[0]</mark> <mark>-</mark> <mark>256</mark> <mark>**</mark> <mark>8</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>


168 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>3]</mark> <mark>=</mark> <mark>inputs[1]</mark> <mark>-</mark> <mark>256</mark> <mark>**</mark> <mark>8</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>


170 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>5]</mark> <mark>=</mark> <mark>inputs[2]</mark> <mark>-</mark> <mark>256</mark> <mark>**</mark> <mark>8</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>


176 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>8]</mark> <mark>=</mark> <mark>low3</mark> <mark>-</mark> <mark>256</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>

177 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>9]</mark> <mark>=</mark> <mark>high3</mark> <mark>-</mark> <mark>256</mark> <mark>**</mark> <mark>7</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>


189 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>11]</mark> <mark>=</mark> <mark>inputs[4]</mark> <mark>-</mark> <mark>256</mark> <mark>**</mark> <mark>8</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>


191 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>13]</mark> <mark>=</mark> <mark>inputs[5]</mark> <mark>-</mark> <mark>256</mark> <mark>**</mark> <mark>8</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>


197 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>16]</mark> <mark>=</mark> <mark>low6</mark> <mark>-</mark> <mark>256</mark> <mark>**</mark> <mark>2</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>

198 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>17]</mark> <mark>=</mark> <mark>high6</mark> <mark>-</mark> <mark>256</mark> <mark>**</mark> <mark>6</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>


210 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>19]</mark> <mark>=</mark> <mark>inputs[7]</mark> <mark>-</mark> <mark>256</mark> <mark>**</mark> <mark>8</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>


212 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>21]</mark> <mark>=</mark> <mark>inputs[8]</mark> <mark>-</mark> <mark>256</mark> <mark>**</mark> <mark>8</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>


218 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>24]</mark> <mark>=</mark> <mark>low9</mark> <mark>-</mark> <mark>256</mark> <mark>**</mark> <mark>3</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>

219 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>25]</mark> <mark>=</mark> <mark>high9</mark> <mark>-</mark> <mark>256</mark> <mark>**</mark> <mark>5</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>


231 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>27]</mark> <mark>=</mark> <mark>inputs[10]</mark> <mark>-</mark> <mark>256</mark> <mark>**</mark> <mark>8</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>


233 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>29]</mark> <mark>=</mark> <mark>inputs[11]</mark> <mark>-</mark> <mark>256</mark> <mark>**</mark> <mark>8</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>


22


239 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>32]</mark> <mark>=</mark> <mark>low12</mark> <mark>-</mark> <mark>256</mark> <mark>**</mark> <mark>4</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>

240 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>33]</mark> <mark>=</mark> <mark>high12</mark> <mark>-</mark> <mark>256</mark> <mark>**</mark> <mark>4</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>


252 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>35]</mark> <mark>=</mark> <mark>inputs[13]</mark> <mark>-</mark> <mark>256</mark> <mark>**</mark> <mark>8</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>


254 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>37]</mark> <mark>=</mark> <mark>inputs[14]</mark> <mark>-</mark> <mark>256</mark> <mark>**</mark> <mark>8</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>


260 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>40]</mark> <mark>=</mark> <mark>low15</mark> <mark>-</mark> <mark>256</mark> <mark>**</mark> <mark>5</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>

261 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>41]</mark> <mark>=</mark> <mark>high15</mark> <mark>-</mark> <mark>256</mark> <mark>**</mark> <mark>3</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>


273 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>43]</mark> <mark>=</mark> <mark>inputs[16]</mark> <mark>-</mark> <mark>256</mark> <mark>**</mark> <mark>8</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>


**CVF-31.** **INFO**


    - **Category** Suboptimal    - **Source** keccak.cairo


**Recommendation** This could be simplified as: MAX_VALUE   - 1   - x


**Client** **Comment** _Same_ _as_ _above._


307 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>2]</mark> <mark>=</mark> <mark>n_bytes_left</mark> <mark>-</mark> <mark>BYTES_IN_WORD</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark>

_<mark>�→</mark>_ <mark>128;</mark>

308 <mark>+</mark> **<mark>assert</mark>** <mark>[range_check_ptr</mark> <mark>+</mark> <mark>3]</mark> <mark>=</mark> <mark>n_words_to_copy</mark> <mark>-</mark>

_<mark>�→</mark>_ <mark>KECCAK_FULL_RATE_IN_WORDS</mark> <mark>+</mark> <mark>2</mark> <mark>**</mark> <mark>128;</mark>


**CVF-32.** **FIXED**


    - **Category** Readability    - **Source** keccak.cairo


**Recommendation** Consider providing the keccak padding scheme in comments.


**Client** **Comment** _Will_ _document._


322 <mark>+let</mark> <mark>first_one</mark> <mark>=</mark> <mark>_pow256(n_bytes_left);</mark>

323 <mark>+//</mark> <mark>The</mark> <mark>beginning</mark> <mark>of</mark> <mark>the</mark> <mark>padding</mark> <mark>with</mark> <mark>the</mark> <mark>last</mark> <mark>bytes</mark> <mark>of</mark> <mark>the</mark> <mark>input</mark>

_<mark>�→</mark>_ <mark>and</mark> <mark>the</mark> <mark>first</mark> <mark>1.</mark>

324 <mark>+let</mark> <mark>input_word_with_initial_padding</mark> <mark>=</mark> <mark>input_word</mark> <mark>+</mark> <mark>first_one;</mark>

325 <mark>+</mark>

326 <mark>+</mark> **<mark>if</mark>** <mark>(padding_len</mark> <mark>==</mark> <mark>1)</mark> <mark>{</mark>

327 <mark>+</mark> **<mark>assert</mark>** <mark>dst[0]</mark> <mark>=</mark> <mark>2</mark> <mark>**</mark> <mark>63</mark> <mark>+</mark> <mark>input_word_with_initial_padding;</mark>

328 <mark>+}</mark> **<mark>else</mark>** <mark>{</mark>

329 <mark>+</mark> <mark>//</mark> <mark>Padding</mark> <mark>of</mark> <mark>more</mark> <mark>than</mark> <mark>1</mark> <mark>word.</mark>

330 <mark>+</mark> **<mark>assert</mark>** <mark>dst[0]</mark> <mark>=</mark> <mark>input_word_with_initial_padding;</mark>

331 <mark>+</mark> <mark>memset(dst=dst</mark> <mark>+</mark> <mark>1,</mark> **<mark>value</mark>** <mark>=0,</mark> <mark>n=padding_len</mark> <mark>-</mark> <mark>2);</mark>

332 <mark>+</mark> **<mark>assert</mark>** <mark>dst[padding_len</mark> <mark>-</mark> <mark>1]</mark> <mark>=</mark> <mark>2</mark> <mark>**</mark> <mark>63;</mark>

333 <mark>+}</mark>


23


**CVF-33.** **FIXED**


    - **Category** Procedural    - **Source** hash_state_poseidon.cairo


**Description** This import is not used.


**Recommendation** Consider removing it.


**Client** **Comment** _Will_ _remove._


4 <mark>+poseidon_hash_single,</mark>


**CVF-34.** **INFO**


    - **Category** Procedural    - **Source**


patricia_with_poseidon.cairo


**Description** We didn’t review this function.


5 <mark>+patricia_update_using_update_constants</mark> <mark>as</mark>

_<mark>�→</mark>_ <mark>patricia_update_using_update_constants_with_sponge,</mark>


**CVF-35.** **INFO**


    - **Category** Unclear behavior    - **Source** patricia.cairo


**Description** These comments look like instructions for some kind of macroprocessor, but


its unclear what code they are expanded to. Without this knowledge, it is impossible to


tell whether the code is correct or not.


**Client** **Comment** _These_ _are_ _used_ _only_ _here_ _to_ _avoid_ _duplicating_ _patricia.cairo_ _for_ _both_


_pedersen/poseidon,_ _we’ll_ _either_ _document_ _and_ _add_ _the_ _generating_ _code_ _to_ _the_ _scope_


_(see_ _patricia_gen_test.py)_ _or_ _remove_ _this_ _mechanism_ _alltogether_ _and_ _duplicate._


20 <mark>+//</mark> <mark>ADDITIONAL_IMPORTS_MACRO()</mark>


46 <mark>+</mark> <mark>//</mark> <mark>PREPARE_ADDITIONAL_HASH_INPUTS_MACRO(hash_ptr)</mark>


250 <mark>+</mark> <mark>//</mark> <mark>PREPARE_ADDITIONAL_HASH_INPUTS_MACRO(hash_ptr)</mark>


325 <mark>+</mark> <mark>//</mark> <mark>PREPARE_ADDITIONAL_HASH_INPUTS_MACRO(current_hash)</mark>


24


dmitry@abdkconsulting.com


<u>[twitter.com/ABDKconsulting](https://twitter.com/ABDKconsulting)</u>



<u>[abdk.consulting](https://abdk.consulting/)</u>


<u>[linkedin.com/company/abdk-consulting](https://linkedin.com/company/abdk-consulting)</u>


