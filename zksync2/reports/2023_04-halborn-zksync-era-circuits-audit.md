# **MatterLabs -** **zkSync Era**

## Zero Knowledge Security Audit

Prepared by: **Halborn**

Date of Engagement: **January** **9th,** **2023** **-** **March** **8th,** **2023**


Visit: **[Halborn.com](https://halborn.com)**


DOCUMENT REVISION HISTORY 4


CONTACTS 5


1 EXECUTIVE OVERVIEW 6


1.1 INTRODUCTION 7


1.2 AUDIT SUMMARY 7


1.3 TEST APPROACH & METHODOLOGY 8


RISK METHODOLOGY 8


1.4 SCOPE 10


2 ASSESSMENT SUMMARY & FINDINGS OVERVIEW 12


3 FINDINGS & TECH DETAILS 13


3.1 (HAL-01) CIRCUIT NOT PROPERLY WORKING WHEN USING SHARD ID - 0 
CRITICAL 15


Description 15


Code Location 15


Proof of Concept 17


Risk Level 17


Recommendation 18


Remediation Plan 18


3.2 (HAL-02) HEAD STATE NOT ENFORCED TO BE ZERO - LOW 19


Description 19


Code Location 19


Risk Level 20


Recommendation 20


Remediation Plan 21


3.3 (HAL-03) UNUSED CIRCUIT FUNCTIONALITY - INFORMATIONAL 22



1


Description 22


Code Location 22


Risk Level 26


Recommendation 26


Remediation Plan 27


3.4 (HAL-04) QUEUE NOT ENFORCED TO BE EMPTY RIGHT AFTER POPPING ALL

ELEMENTS   - INFORMATIONAL 28


Description 28


Code Location 28


Risk Level 29


Recommendation 29


Remediation Plan 30


3.5 (HAL-05) UNNEEDED INITIALIZATION OF UINT256 VARIABLES - INFOR
MATIONAL 31


Description 31


Code Location 31


Risk Level 32


Recommendation 32


Remediation Plan 33


4 AUTOMATED TESTING 34


4.1 STATIC ANALYSIS REPORT 35


Description 35


cargo geiger results 35


4.2 AUTOMATED SECURITY SCAN 40


Description 40


cargo audit results 40



2


3


### DOCUMENT REVISION HISTORY

VERSION MODIFICATION DATE AUTHOR


0.1 Document Creation 03/05/2023 Omar Alshaeb


0.2 Document Updates 03/08/2023 Omar Alshaeb


0.3 Draft Review 03/08/2023 Gokberk Gulgun


0.4 Draft Review 03/09/2023 Gabi Urrutia


0.5 Document Updates 04/03/2023 Omar Alshaeb


0.6 Document Draft Review 04/03/2023 Gokberk Gulgun


0.7 Document Draft Review 04/03/2023 Gabi Urrutia


1.0 Remediation Plan 04/04/2023 Omar Alshaeb


1.1 Remediation Plan Review 04/04/2023 Gokberk Gulgun


1.2 Remediation Plan Review 04/04/2023 Gabi Urrutia



4


### CONTACTS

CONTACT COMPANY EMAIL


Rob Behnke Halborn [Rob.Behnke@halborn.com](mailto:Rob.Behnke@halborn.com)


Steven Walbroehl Halborn [Steven.Walbroehl@halborn.com](mailto:Steven.Walbroehl@halborn.com)


Gabi Urrutia Halborn [Gabi.Urrutia@halborn.com](mailto:Gabi.Urrutia@halborn.com)


Gokberk Gulgun Halborn [Gokberk.Gulgun@halborn.com](mailto:Gokberk.Gulgun@halborn.com)


Omar Alshaeb Halborn [Omar.Alshaeb@halborn.com](mailto:Omar.Alshaeb@halborn.com)



5


# EXECUTIVE OVERVIEW



6


### 1.1 INTRODUCTION

MatterLabs zkSync Era is a Layer 2 blockchain protocol that eliminates

Ethereum’s inherent congestion with zero knowledge proofs. Matter Labs’

creation is on a mission to accelerate the mass adoption of crypto

for personal sovereignty. It is designed to unlock the full potential of

trustless blockchain technology while scaling the core values of Ethereum.


MatterLabs engaged Halborn to conduct a security audit on their zero

knowledge circuits and the verifier, beginning on January 9th, 2023 and

ending on March 8th, 2023. The security assessment was scoped to the

circuits provided to the Halborn team.

### 1.2 AUDIT SUMMARY


The team at Halborn was provided two months for the engagement and assigned

a full-time security engineer to audit the security of the zero knowledge

circuits and the verifier. The security engineer is a blockchain, smart
contract and ZK security expert with advanced penetration testing, smart
contract hacking, and deep knowledge of multiple blockchain protocols.


The purpose of this audit to achieve the following:

#### • Ensure that the circuits operate as intended. • Identify potential security issues within the circuits. • Ensure that the verifier operate as intended. • Identify potential security issues within the verifier contracts.


In summary, Halborn identified some security risks that were mostly

addressed by the MatterLabs team.



7


### 1.3 TEST APPROACH & METHODOLOGY

Halborn performed a combination of manual and automated security testing

to balance efficiency, timeliness, practicality, and accuracy in regard

to the scope of this audit. While manual testing is recommended to uncover

flaws in logic, process, and implementation; automated testing techniques

help enhance coverage of the bridge code and can quickly identify items

that do not follow security best practices. The following phases and

associated tools were used throughout the term of the audit:

#### • Research into architecture and purpose. • Smart contract manual code review and walkthrough. • Circuit manual code review and walkthrough. • Graphing out functionality and circuit logic/connectivity/functions.


(cargo-deps)
#### • Manual code review of common Rust security vulnerabilities. • Manual code review of specific zero knowledge security vulnerabil
ities.
#### • Scanning of circuits files for unsafe Rust code usage. (cargo-geiger

)
#### • Static Analysis of security for scoped circuits, and imported func
tions. (cargo-audit)


RISK METHODOLOGY:


Vulnerabilities or issues observed by Halborn are ranked based on the risk

assessment methodology by measuring the **LIKELIHOOD** of a security incident

and the **IMPACT** should an incident occur. This framework works for commu
nicating the characteristics and impacts of technology vulnerabilities.

The quantitative model ensures repeatable and accurate measurement while

enabling users to see the underlying vulnerability characteristics that

were used to generate the Risk scores. For every vulnerability, a risk

level will be calculated on a scale of 5 to 1 with 5 being the highest

likelihood or impact.


**RISK** **SCALE** **-** **LIKELIHOOD**



8


5 - Almost certain an incident will occur.

4 - High probability of an incident occurring.

3 - Potential of a security incident in the long term.

2 - Low probability of an incident occurring.

1 - Very unlikely issue will cause an incident.


**RISK** **SCALE** **-** **IMPACT**


5 - May cause devastating and unrecoverable impact or loss.

4 - May cause a significant level of impact or loss.

3 - May cause a partial impact or loss to many.

2 - May cause temporary impact or loss.

1 - May cause minimal or un-noticeable impact.


The risk level is then calculated using a sum of these two values, creating

a value of 10 to 1 with 10 being the highest level of security risk.


CRITICAL HIGH MEDIUM LOW INFORMATIONAL


**10** - CRITICAL

**9** **-** **8** - HIGH

**7** **-** **6** - MEDIUM

**5** **-** **4** - LOW

**3** **-** **1** - VERY LOW AND INFORMATIONAL



9


### 1.4 SCOPE

**1.** **IN-SCOPE:**


The security assessment was scoped to the following zero [knowledge](https://github.com/matter-labs/sync_vm/tree/v1.2.1) cir
[cuits:](https://github.com/matter-labs/sync_vm/tree/v1.2.1)

#### • /src/vm/* • /src/glue/sort_decommitments_requests/* • /src/glue/code_unpacker_sha256/* • /src/glue/demux_log_queue/* • /src/precompiles/keccak256.rs • /src/precompiles/sha256.rs • /src/glue/ecrecover_circuit/* • /src/glue/ram_permutation/* • /src/glue/storage_validity_by_grand_product/* • /src/glue/storage_application/* • /src/glue/pub_data_hasher/* • /src/glue/log_sorter/* • /src/glue/merkleize_l1_messages/* • /src/scheduler/* • /src/circuit_structures/* • /src/data_structures/* • /src/inputs/* • /src/recursion/* • /src/traits/* • /src/secp256k1/* • /src/utils.rs


**Commit** **ID** **:** [014e674916058e31725d6e92439fa5ff14e6677e](https://github.com/matter-labs/sync_vm/commit/014e674916058e31725d6e92439fa5ff14e6677e)



10


And the [verifier:](https://github.com/matter-labs/era-contracts/tree/main/ethereum/contracts/zksync)

#### • /zksync/Verifier.sol • /zksync/Plonk4VerifierWithAccessToDNext.sol • /zksync/libraries/PairingsBn254.sol • /zksync/libraries/TranscriptLib.sol


**Commit** **ID** **:** [fc7e86a3df404acb88d86502c944c0630a7ed288](https://github.com/matter-labs/era-contracts/commit/fc7e86a3df404acb88d86502c944c0630a7ed288)


**2.** **REMEDIATION** **PR/COMMITS:**

#### • Fix Commit ID (HAL-01): 5109e0768c7de799f87ec67bf40b6a544cca4e4e • Fix Commit ID (HAL-02): b0a79356613655bddccaab3b89dbf1142b5483fb • Fix Commit ID (HAL-03): 06c2e76546369fb112d8ac14fb5388154857435b



11


### 2. ASSESSMENT SUMMARY & FINDINGS OVERVIEW

CRITICAL HIGH MEDIUM LOW INFORMATIONAL

##### 1 0 0 1 3

#### LIKELIHOOD


(HAL-01)


(HAL-02)


(HAL-03)
(HAL-04)
(HAL-05)



12


SECURITY ANALYSIS RISK LEVEL REMEDIATION DATE


HAL01  - CIRCUIT NOT PROPERLY
Critical SOLVED                     - 03/27/2023
WORKING WHEN USING SHARD ID - 0


HAL02 - HEAD STATE NOT ENFORCED TO

Low SOLVED                      - 03/27/2023
BE ZERO


HAL03    - UNUSED CIRCUIT

Informational SOLVED                    - 03/27/2023
FUNCTIONALITY


HAL04 - QUEUE NOT ENFORCED TO BE



EMPTY RIGHT AFTER POPPING ALL

<u>ELEMENTS</u>



Informational ACKNOWLEDGED



HAL05 - UNNEEDED INITIALIZATION OF

Informational ACKNOWLEDGED
UINT256 VARIABLES



13


# FINDINGS & TECH DETAILS



14


### 3.1 (HAL-01) CIRCUIT NOT PROPERLY WORKING WHEN USING SHARD ID > 0 - CRITICAL

Description:


The STORAGE QUERIES FILTER circuit (storage_validity_by_grand_product)

does not produce the intended output when shard ID is greater than 0.

When the keys of each element of the initial queue are being packed

throughout the sorting of the queues, the second linear combination is

wrongly created, overlapping the bits of the address variable, due to

using the incorrect coefficient.


The problem with this bug, is that as the pack_key function is returning

an incorrect packed key to the sorting functionality, the final sorted

queue of the circuit is not being properly generated, leading to even

more issues afterward. This can be seen as a completeness bug.


Code Location:


**Listing** **1:** **storage_validity_by_grand_product/mod.rs** **(Line** **425)**


419 const PACKED_WIDTHS : [ usize ; 2] = [192, 232];

420 // now resolve a logic

421 for ( item, is_trivial ) in it {

422 // check if keys are equal and check a value

423 let TimestampedStorageLogRecord { record, timestamp } = item ;

424

425 <mark>let</mark> <mark>packed_key</mark> <mark>=</mark> <mark>pack_key</mark> <mark>(</mark>

426 cs,

427 ( record . shard_id . clone (), record . address . clone (), record .

ë key ),

428 )?;

429

430 // ensure sorting

431 let ( keys_are_equal, previous_key_is_greater ) =

432 prepacked_long_comparison ( cs, & previous_packed_key, &

ë packed_key, & PACKED_WIDTHS )?;



15


433

434 can_not_be_false_if_flagged ( cs, & previous_key_is_greater . not ()

ë, & is_trivial . not ())?;

435

436 // if keys are the same then timestamps are sorted

437 let (_, previous_timestamp_is_less ) = previous_timestamp . sub (

ë cs, & timestamp )?;

438 // enforce if keys are the same and not trivial

439 let must_enforce = smart_and (cs, &[ keys_are_equal, is_trivial .

ë not ()])?;

440 can_not_be_false_if_flagged ( cs, & previous_timestamp_is_less, &

ë must_enforce )?;

441

442 // we follow the procedure:

443 // if keys are different then we finish with a previous one

ë and update parameters

444 // else we just update parameters


**Listing** **2:** **storage_validity_by_grand_product/mod.rs** **(Line** **669)**


650 pub fn pack_key <E : Engine, CS : ConstraintSystem <E >>(

651 cs : & mut CS,

652 key_tuple : ( Byte <E >, UInt160 <E >, UInt256 <E >),

653 ) -> Result <[ Num <E >; 2], SynthesisError > {

654 let shifts = compute_shifts ::< E :: Fr >();

655

656 // LE packing

657

658 let ( shard_id, address, key ) = key_tuple ;

659 let mut lc_0 = LinearCombination :: zero ();

660 lc_0 . add_assign_number_with_coeff (& key . inner [0]. inner, shifts

ë [0]);

661 lc_0 . add_assign_number_with_coeff (& key . inner [1]. inner, shifts

ë [64]);

662 lc_0 . add_assign_number_with_coeff (& key . inner [2]. inner, shifts

ë [128]);

663 // 192 in total

664 let value_0 = lc_0 . into_num ( cs )?;

665

666 let mut lc_1 = LinearCombination :: zero ();

667 lc_1 . add_assign_number_with_coeff (& key . inner [3]. inner, shifts

ë [0]);

668 lc_1 . add_assign_number_with_coeff (& address . inner, shifts [64]);

669 <mark>lc_1</mark> <mark>.</mark> <mark>add_assign_number_with_coeff (& shard_id</mark> <mark>.</mark> <mark>inner,</mark> <mark>shifts</mark>



16


ë <mark>[160]);</mark>

670 let value_1 = lc_1 . into_num ( cs )?;

671 // 64 + 160 + 8 = 232 in total

672

673 Ok ([ value_0, value_1 ])

674 }


Proof of Concept:


1. The STORAGE QUERIES FILTER circuit receives as input witness the

storage access requests queue.

2. This circuit aims to order the resulting queue of all the elements

in the initial queue by a generated key.

3. The circuit calls the pack_key function to generate the key for the

current element of the queue.

4. A shard_id different from 0 is being used.

5. Within the generated key, the bits of the address parameter gets

overlapped with the bits of the shard_id.

6. An incorrect key is returned to the main function of the circuit,

thus breaking the overall functionality of the circuit.

7. The resulting queue is not ordered as expected, leading to even more

issues afterward.


Risk Level:


**Likelihood** **-** **5**

**Impact** **-** **5**



17


Recommendation:


The last coefficient on line 669 needs to be shifts[224] instead of

shifts[160].


**Listing** **3:** **storage_validity_by_grand_product/mod.rs** **(Line** **669)**


666 let mut lc_1 = LinearCombination :: zero ();

667 lc_1 . add_assign_number_with_coeff (& key . inner [3]. inner, shifts [0]);

668 lc_1 . add_assign_number_with_coeff (& address . inner, shifts [64]);

669 <mark>lc_1</mark> <mark>.</mark> <mark>add_assign_number_with_coeff (& shard_id</mark> <mark>.</mark> <mark>inner,</mark> <mark>shifts [224]);</mark>

670 let value_1 = lc_1 . into_num ( cs )?;


Moreover, would be useful to check after each linear combination if the

shift value is within the capacity by using:


**Listing** **4:** **storage_validity_by_grand_product/mod.rs**


0 assert! ( shift <= E :: Fr :: CAPACITY as usize );


Remediation Plan:


**SOLVED** : The MatterLabs team solved the issue by fixing the offset and

adding assertion.


Commit ID : [5109e0768c7de799f87ec67bf40b6a544cca4e4e](https://github.com/matter-labs/sync_vm/commit/5109e0768c7de799f87ec67bf40b6a544cca4e4e)



18


### 3.2 (HAL-02) HEAD STATE NOT ENFORCED TO BE ZERO - LOW

Description:


The MESSAGES EVENTS FILTER circuit (log_sorter) is not enforcing the head

state of the initial queue received as input to be zero. Even though the

LOG DEMULTIPLEXER circuit gives as output all queues that were initially

empty, already enforcing the head state to be zero, it is essential to

ensure it is atomically checked in each circuit, regardless of where the

input is coming from.


Code Location:


**Listing** **5:** **log_sorter/mod.rs**


49 let structured_input_witness = project_ref! ( witness,

ë closed_form_input ). cloned ();

50 let initial_queue_witness = project_ref! ( witness,

ë initial_queue_witness ). cloned ();

51 let intermediate_sorted_queue_state =

52 project_ref! ( witness, intermediate_sorted_queue_state ). cloned

ë ();

53 let sorted_queue_witness = project_ref! ( witness,

ë sorted_queue_witness ). cloned ();

54

55 let mut structured_input = EventsDeduplicatorInputOutput ::

ë alloc_ignoring_outputs (

56 cs,

57 structured_input_witness . clone (),

58 )?;

59

60 Boolean :: enforce_equal ( cs, & structured_input . start_flag, & Boolean

ë :: constant ( true ))?;

61

62 let mut initial_queue = StorageLogQueue :: from_raw_parts (

63 cs,

64 structured_input

65 . observable_input

66 . initial_log_queue_state



19


67 . head_state,

68 structured_input

69 . observable_input

70 . initial_log_queue_state

71 . tail_state,

72 structured_input

73 . observable_input

74 . initial_log_queue_state

75 . num_items,

76 )?;

77

78 // dbg!(initial_queue.clone ().into_state ().create_witness ());

79

80 if let Some ( wit ) = initial_queue_witness {

81 initial_queue . witness = wit ;

82 }


Risk Level:


**Likelihood** **-** **1**

**Impact** **-** **3**


Recommendation:


Adding the enforcement for the initial queue head state to be zero right

after getting it from the input witness.


**Listing** **6:** **log_sorter/mod.rs** **(Line** **79)**


77

78 // it must be trivial

79 <mark>initial_queue</mark> <mark>.</mark> <mark>head_state</mark> <mark>.</mark> <mark>enforce_equal</mark> <mark>(</mark> <mark>cs</mark> <mark>,</mark> <mark>&</mark> <mark>Num</mark> <mark>::</mark> <mark>zero</mark> <mark>())?;</mark>

80

81 // dbg!(initial_queue.clone ().into_state ().create_witness ());

82

83 if let Some ( wit ) = initial_queue_witness {

84 initial_queue . witness = wit ;

85 }



20


Remediation Plan:


**SOLVED** : The MatterLabs team solved the issue by enforcing the initial

queue head state to zero.


Commit ID : [b0a79356613655bddccaab3b89dbf1142b5483fb](https://github.com/matter-labs/sync_vm/commit/b0a79356613655bddccaab3b89dbf1142b5483fb)



21


### 3.3 (HAL-03) UNUSED CIRCUIT FUNCTIONALITY - INFORMATIONAL

Description:


Within the LOG DEMULTIPLEXER circuit (demux_log_queue) the

demultiplex_storage_logs_inner function is declared but never

used. The demultiplex_storage_logs_inner_optimized function is used

instead.


Code Location:


**Listing** **7:** **demux_log_queue/mod.rs**


144 pub fn demultiplex_storage_logs_inner <

145 E: Engine,

146 CS : ConstraintSystem <E >,

147 R: CircuitArithmeticRoundFunction <E, 2, 3, StateElement = Num <

ë E >>,

148 >(

149 cs : & mut CS,

150 mut storage_log_queue : StorageLogQueue <E >,

151 round_function : &R,

152 limit : usize,

153 ) -> Result <[ StorageLogQueue <E >; NUM_SEPARATE_QUEUES ],

ë SynthesisError > {

154 assert! ( limit <= u32 :: MAX as usize );

155

156 let mut optimizer = SpongeOptimizer :: new ( round_function . clone

ë (), 3);

157

158 let mut rollup_storage_queue = StorageLogQueue :: empty ();

159 // let mut porter_storage_queue = StorageLogQueue :: empty ();

160 let mut events_queue = StorageLogQueue :: empty ();

161 let mut l1_messages_queue = StorageLogQueue :: empty ();

162 let mut keccak_calls_queue = StorageLogQueue :: empty ();

163 let mut sha256_calls_queue = StorageLogQueue :: empty ();

164 let mut ecdsa_calls_queue = StorageLogQueue :: empty ();

165

166 const SYSTEM_CONTRACTS_OFFSET_ADDRESS : u16 = 1 << 15;



22


167

168 const KECCAK256_ROUND_FUNCTION_PRECOMPILE_ADDRESS : u16 =

ë SYSTEM_CONTRACTS_OFFSET_ADDRESS + 0 x10 ;

169 const SHA256_ROUND_FUNCTION_PRECOMPILE_ADDRESS : u16 = 0 x02 ; //

ë as in Ethereum

170 const ECRECOVER_INNER_FUNCTION_PRECOMPILE_ADDRESS : u16 = 0 x01 ;

ë // as in Ethereum

171

172 let keccak_precompile_address = UInt160 :: from_uint ( u160 ::

ë from_u64 (

173 KECCAK256_ROUND_FUNCTION_PRECOMPILE_ADDRESS as u64,

174 ));

175 let sha256_precompile_address = UInt160 :: from_uint ( u160 ::

ë from_u64 (

176 SHA256_ROUND_FUNCTION_PRECOMPILE_ADDRESS as u64,

177 ));

178 let ecrecover_precompile_address = UInt160 :: from_uint ( u160 ::

ë from_u64 (

179 ECRECOVER_INNER_FUNCTION_PRECOMPILE_ADDRESS as u64,

180 ));

181

182 for _ in 0.. limit {

183 let execute = storage_log_queue . is_empty ( cs )?. not ();

184

185 // let n = cs.get_current_step_number ();

186 let popped = storage_log_queue . pop_first ( cs, & execute,

ë round_function )?;

187 // dbg!(cs.get_current_step_number () - n); // 291

188

189 let is_storage_aux_byte =

190 Num :: equals (cs, & aux_byte_for_storage (). inner, & popped

ë . aux_byte . inner )?;

191 let is_event_aux_byte =

192 Num :: equals (cs, & aux_byte_for_event (). inner, & popped .

ë aux_byte . inner )?;

193 let is_l1_message_aux_byte =

194 Num :: equals (cs, & aux_byte_for_l1_message (). inner, &

ë popped . aux_byte . inner )?;

195 let is_precompile_aux_byte = Num :: equals (

196 cs,

197 & aux_byte_for_precompile_call (). inner,

198 & popped . aux_byte . inner,

199 )?;

200



23


201 let is_keccak_address = UInt160 :: equals ( cs, &

ë keccak_precompile_address, & popped . address )?;

202 let is_sha256_address = UInt160 :: equals ( cs, &

ë sha256_precompile_address, & popped . address )?;

203 let is_ecrecover_address =

204 UInt160 :: equals ( cs, & ecrecover_precompile_address, &

ë popped . address )?;

205

206 let is_rollup_shard = popped . shard_id . inner . is_zero ( cs )?;

207

208 let execute_rollup_storage =

209 smart_and ( cs, &[ is_storage_aux_byte, is_rollup_shard,

ë execute ])?;

210 let execute_porter_storage =

211 smart_and ( cs, &[ is_storage_aux_byte, is_rollup_shard .

ë not (), execute ])?;

212 Boolean :: enforce_equal ( cs, & execute_porter_storage, &

ë Boolean :: constant ( false ))?;

213 let execute_event = smart_and (cs, &[ is_event_aux_byte,

ë execute ])?;

214 let execute_l1_message = smart_and ( cs, &[

ë is_l1_message_aux_byte, execute ])?;

215 let execute_keccak_call =

216 smart_and ( cs, &[ is_precompile_aux_byte,

ë is_keccak_address, execute ])?;

217 let execute_sha256_call =

218 smart_and ( cs, &[ is_precompile_aux_byte,

ë is_sha256_address, execute ])?;

219 let execute_ecrecover_call =

220 smart_and ( cs, &[ is_precompile_aux_byte,

ë is_ecrecover_address, execute ])?;

221

222 // let n = cs.get_current_step_number ();

223 rollup_storage_queue . push_with_optimizer (

224 cs,

225 LogType :: RollupStorage as u64,

226 & popped,

227 & execute_rollup_storage,

228 & mut optimizer,

229 )?;

230 // porter_storage_queue.push_with_optimizer(cs, LogType ::

ë PorterStorage as u64, &popped, &execute_porter_storage, &mut

ë optimizer)?;

231 events_queue . push_with_optimizer (



24


232 cs,

233 LogType :: Events as u64,

234 & popped,

235 & execute_event,

236 & mut optimizer,

237 )?;

238 l1_messages_queue . push_with_optimizer (

239 cs,

240 LogType :: L1Messages as u64,

241 & popped,

242 & execute_l1_message,

243 & mut optimizer,

244 )?;

245 keccak_calls_queue . push_with_optimizer (

246 cs,

247 LogType :: KeccakCalls as u64,

248 & popped,

249 & execute_keccak_call,

250 & mut optimizer,

251 )?;

252 sha256_calls_queue . push_with_optimizer (

253 cs,

254 LogType :: Sha256Calls as u64,

255 & popped,

256 & execute_sha256_call,

257 & mut optimizer,

258 )?;

259 ecdsa_calls_queue . push_with_optimizer (

260 cs,

261 LogType :: ECRecoverCalls as u64,

262 & popped,

263 & execute_ecrecover_call,

264 & mut optimizer,

265 )?;

266 // dbg!(cs.get_current_step_number () - n); // 96

267

268 // let n = cs.get_current_step_number ();

269 optimizer . enforce ( cs )?;

270 // dbg!(cs.get_current_step_number () - n); // 338

271

272 let expected_bitmask_bits = [

273 is_storage_aux_byte,

274 is_event_aux_byte,

275 is_l1_message_aux_byte,



25


276 is_precompile_aux_byte,

277 ];

278

279 let ( is_bitmask, all_flags_are_false ) =

280 check_if_bitmask_and_if_empty ( cs, &

ë expected_bitmask_bits )?;

281 can_not_be_false_if_flagged (cs, & is_bitmask, & Boolean ::

ë Constant ( true ))?;

282 can_not_be_false_if_flagged (cs, & all_flags_are_false . not ()

ë, & execute )?;

283 }

284

285 storage_log_queue . enforce_to_be_empty ( cs )?;

286

287 let all_queues = [

288 rollup_storage_queue,

289 events_queue,

290 l1_messages_queue,

291 keccak_calls_queue,

292 sha256_calls_queue,

293 ecdsa_calls_queue,

294 ];

295

296 Ok ( all_queues )

297 }


Risk Level:


**Likelihood** **-** **1**

**Impact** **-** **1**


Recommendation:


Any unused code is recommended to be removed for better readability of

the overall code and optimization.



26


Remediation Plan:


**SOLVED** : The MatterLabs team solved the issue by removing the unused

function.


Commit ID : [06c2e76546369fb112d8ac14fb5388154857435b](https://github.com/matter-labs/sync_vm/commit/06c2e76546369fb112d8ac14fb5388154857435b)



27


### 3.4 (HAL-04) QUEUE NOT ENFORCED TO BE EMPTY RIGHT AFTER POPPING ALL ELEMENTS - INFORMATIONAL

Description:


The MERKLEIZER circuit (merkleize_l1_messages) does not enforce the ini
tial queue to be empty right after popping all elements. Even though it

does it at the end of the circuit, as this circuit is resource-consuming

while computing the linear hash and the Merkle tree hash, it would be

useful to enforce it before all the hashing functionality for better

readability of the overall code and optimization.


Code Location:


**Listing** **8:** **merkleize_l1_messages/merkleize.rs** **(Line** **244)**


204 for chunk in linear_hash_input [4..]. chunks_exact_mut (

ë MESSAGE_SERIALIZATION_BYTES ) {

205 let can_pop = initial_queue . is_empty ( cs )?. not ();

206 let item = initial_queue . pop_first ( cs, & can_pop,

ë round_function )?;

207 let serialized = item . serialize ( cs )?;

208 assert_eq! ( chunk . len (), serialized . len ());

209 for ( dst, src ) in chunk . iter_mut (). zip ( serialized . iter ()) {

210 - dst = Byte :: conditionally_select ( cs, & can_pop, src, dst )

ë ?;

211 }

212 }

213

214 let linear_hash = if output_linear_hash {

215 println! (

216 "Computing linear hash over {} bytes",

217 linear_hash_input . len ()

218 );

219 let pubdata_hash = tree_hasher . hash ( cs, & linear_hash_input )?;

220 let pubdata_hash_as_bytes32 = Bytes32 :: from_bytes_array (&

ë pubdata_hash );

221



28


222 pubdata_hash_as_bytes32

223 } else {

224 Bytes32 :: empty ()

225 };

226

227 // a little bit tricky: unsafe cast, but we checked the length,

ë and ABI wise it 's guaranteed

228 // later on we can use split_array_ref

229

230 let leafs_only_bytes = & linear_hash_input [4..];

231 assert! ( leafs_only_bytes . len () % MESSAGE_SERIALIZATION_BYTES == 0)

ë ;

232

233 let mut leafs = vec! [];

234 for chunk in leafs_only_bytes . chunks_exact (

ë MESSAGE_SERIALIZATION_BYTES ) {

235 let leaf_encoding : [ _ ; MESSAGE_SERIALIZATION_BYTES ] = chunk .

ë to_vec (). try_into (). unwrap ();

236 leafs . push ( leaf_encoding );

237 }

238

239 println! ( "Computing tree over {} leafs", leafs . len ());

240

241 let calculated_merkle_root =

242 circuit_compute_merkle_root_from_leafs_generic ::<_, _, H,

ë ARITY >( cs, & leafs, tree_hasher )?;

243

244 <mark>initial_queue</mark> <mark>.</mark> <mark>enforce_to_be_empty</mark> <mark>(</mark> <mark>cs</mark> <mark>)?;</mark>


Risk Level:


**Likelihood** **-** **1**

**Impact** **-** **1**


Recommendation:


Enforce the initial queue to be empty right after popping all elements

for better readability of the overall code and optimization.



29


Remediation Plan:


**ACKNOWLEDGED:** The MatterLabs team acknowledged this issue. It will be

addressed while moving to the new proof system.



30


### 3.5 (HAL-05) UNNEEDED INITIALIZATION OF UINT256 VARIABLES - INFORMATIONAL

Description:


As i is an uint256, it is already initialized to 0. uint256 i = 0

reassigns the 0 to i which wastes gas.


Code Location:


Verifier.sol

- Line 134: for (uint256 i = 0; i < public_inputs.length; i = i.

uncheckedInc()){

- Line 139: for (uint256 i = 0; i < STATE_WIDTH; i = i.uncheckedInc()){

- Line 164: for (uint256 i = 0; i < proof.quotient_poly_parts_commitments

.length; i = i.uncheckedInc()){

- Line 172: for (uint256 i = 0; i < proof.state_polys_openings_at_z.

length; i = i.uncheckedInc()){

- Line 178: for (uint256 i = 0; i < proof.state_polys_openings_at_z_omega

.length; i = i.uncheckedInc()){

- Line 183: for (uint256 i = 0; i < proof.gate_selectors_openings_at_z.

length; i = i.uncheckedInc()){

- Line 188: for (uint256 i = 0; i < proof.copy_permutation_polys_openings_at_z

.length; i = i.uncheckedInc()){


Plonk4VerifierWithAccessToDNext.sol

- Line 144: for (uint256 i = 0; i < vk.num_inputs; i = i.uncheckedInc()

){

- Line 148: for (uint256 i = 0; i < STATE_WIDTH; i = i.uncheckedInc()){

- Line 164: for (uint256 i = 0; i < proof.quotient_poly_parts_commitments

.length; i = i.uncheckedInc()){

- Line 171: for (uint256 i = 0; i < proof.state_polys_openings_at_z.

length; i = i.uncheckedInc()){

- Line 175: for (uint256 i = 0; i < proof.state_polys_openings_at_z_omega


31


.length; i = i.uncheckedInc()){

- Line 178: for (uint256 i = 0; i < proof.gate_selectors_openings_at_z.

length; i = i.uncheckedInc()){

- Line 181: for (uint256 i = 0; i < proof.copy_permutation_polys_openings_at_z

.length; i = i.uncheckedInc()){

- Line 301: for (uint256 i = 0; i < lagrange_poly_numbers.length; i = i

.uncheckedInc()){

- Line 307: for (uint256 i = 0; i < vk.num_inputs; i = i.uncheckedInc()

){

- Line 324: for (uint256 i = 0; i < proof.copy_permutation_polys_openings_at_z

.length; i = i.uncheckedInc()){

- Line 448: for (uint256 i = 0; i < proof.state_polys_openings_at_z.

length; ){

- Line 472: for (uint256 i = 0; i < STATE_WIDTH - 1; i = i.uncheckedInc

()){

- Line 558: for (uint256 i = 0; i < STATE_WIDTH - 1; i = i.uncheckedInc

()){

- Line 613: for (uint256 i = 0; i < STATE_WIDTH; i = i.uncheckedInc()){

- Line 622: for (uint256 i = 0; i < STATE_WIDTH - 1; i = i.uncheckedInc

()){


PairingsBn254.sol

- Line 240: for (uint256 i = 0; i < elements; ){


Risk Level:


**Likelihood** **-** **1**

**Impact** **-** **1**


Recommendation:


It is recommended not to initialize uint256 variables to 0 to reduce the

gas costs. For example, use instead:

for (uint256 i; i < length; ++i){


32


Remediation Plan:


**ACKNOWLEDGED:** The MatterLabs team acknowledged this issue.



33


# AUTOMATED TESTING



34


### 4.1 STATIC ANALYSIS REPORT

Description:


Halborn used automated testing techniques to enhance the coverage of

certain areas of the scoped circuits. Among the tools used was cargo

geiger, a tool that lists statistics related to the usage of unsafe Rust

code in a Rust crate and all its dependencies. After Halborn verified all

the circuits in the repository and was able to compile them correctly,

cargo geiger was run on the all-scoped circuits.


cargo geiger results:



35


36


37


38


#### • As a result of the tests carried out with the cargo geiger tool, the

results were obtained and reviewed by Halborn. Based on the results

reviewed, all warnings were determined to not pose a security issue.



39


### 4.2 AUTOMATED SECURITY SCAN

Description:


Halborn used automated security scanners to assist with detection of

well-known security issues, and to identify low-hanging fruits on the

targets for this engagement. Among the tools used was cargo audit, a

command-line utility which inspects Cargo.lock files and compares them

against the RustSec Advisory Database, a community database of security

vulnerabilities maintained by the Rust Secure Code Working Group. Cargo

audit performed a scan on all the circuits.


cargo audit results:

#### • No major issues found by cargo audit.



40


**THANK** **YOU** **FOR** **CHOOSING**


