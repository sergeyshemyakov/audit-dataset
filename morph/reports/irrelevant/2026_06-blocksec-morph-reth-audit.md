# **Report for Morph Reth**

## Date: June 23, 2026 Version: 1.0 Contact: contact@blocksec.com


### **Contents**

**Chapter 1 Introduction** **1**
1.1 About the Audit Target . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1
1.2 Disclaimer . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2
1.3 Procedure of Auditing . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2
1.3.1 Security Issues . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2
1.3.2 Additional Recommendation . . . . . . . . . . . . . . . . . . . . . . . . . . . . 3
1.4 Security Model . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 3


**Chapter 2 Findings** **5**
2.1 Security Issue . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 6
2.1.1 Potential chain state inconsistency due to incorrect `MorphTx` version detection logic . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 6
2.1.2 Potential chain state inconsistency due to incorrect fee validation logic . . 7
2.1.3 Potential transaction version inconsistency due to incorrect `MorphTx` version selection logic . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 8
2.1.4 Potential transaction type inconsistency due to incorrect `gas_price` handling in `MorphTx` construction . . . . . . . . . . . . . . . . . . . . . . . . . . . . 10
2.1.5 Inconsistent rounding direction for token fee gas estimation . . . . . . . . . 11
2.1.6 Lack of trie backend configuration check in block assembly . . . . . . . . . 12
2.1.7 Improper logic in function `validate_version()` . . . . . . . . . . . . . . . . . 13
2.1.8 Lack of `gas_limit` check in function `maintain_morph_pool()` . . . . . . . . . 14
2.1.9 Non-Atomic canonical head lookup in function `current_head()` . . . . . . . 18
2.1.10Underestimated token fee in `MorphTx` pool validation . . . . . . . . . . . . . . 19
2.1.11Lack of default `chain_id` handling in `MorphTx` RPC construction . . . . . . . 22
2.1.12Lack of RPC input validation in `MorphTx` construction . . . . . . . . . . . . . . 23
2.1.13Inconsistent gas estimation behavior between Rust and Go clients implementation . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 25
2.2 Recommendation . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 27
2.2.1 Update the precompile set comment reference . . . . . . . . . . . . . . . . . 27
2.2.2 Apply `MorphTx` validation in the RPC simulation path . . . . . . . . . . . . . . 28
2.2.3 Handle database read errors in storage `original_value` restoration . . . . . 29
2.3 Note . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 34
2.3.1 Trusted token and oracle assumptions . . . . . . . . . . . . . . . . . . . . . . 34
2.3.2 Trusted upstream `Revm` baseline . . . . . . . . . . . . . . . . . . . . . . . . . . 34


**Report Manifest**


<u><mark>Item</mark></u> <u><mark>Description</mark></u>
<u>Client</u> <u>Morph</u>
<u>Target</u> <u>Morph Reth</u>


**Version History**


<u><mark>Version</mark></u> <u><mark>Date</mark></u> <u><mark>Description</mark></u>
<u>1.0</u> <u>June 23, 2026</u> <u>First release</u>


**Signature**


Digitally signed by: BlockSec (https://blocksec.com)

SHA1 digest of public key: BAB106D3708BC6DE0963CE05E9478C24B326AE1C

Date: 2026-06-24 08:49:08+0000


**About** **BlockSec** [BlockSec](https://www.blocksec.com) focuses on the security of the blockchain ecosystem and collaborates with leading DeFi projects to secure their products. BlockSec is founded by topnotch security researchers and experienced experts from both academia and industry. They
have published multiple blockchain security papers in prestigious conferences, reported several zero-day attacks of DeFi applications, and successfully protected digital assets that are
worth more than 14 million dollars by blocking multiple attacks. [They can be reached at Email,](mailto:contact@blocksec.com)
[Twitter and Medium.](https://twitter.com/BlockSecTeam)


### **Chapter 1 Introduction**

##### **1.1 About the Audit Target**

<u><mark>Information</mark></u> <u><mark>Description</mark></u>
<u>Type</u> <u>Smart Contract</u>
<u>Language</u> <u>Rust</u>
<u>Approach</u> <u>Semi-automatic and manual verification</u>


The audit target (hereinafter referred to as the Target) of this audit is the code repository <sup>1</sup> of
Morph Reth of Morph.

Morph Reth is a Rust-based Morph L2 execution client built on top of Reth and Revm. It
implements Morph-specific execution semantics, including Morph transaction types, ERC20
gas token payment, L1 data fee accounting, FeeVault routing, L1 message execution, custom
precompile sets, and Engine API block assembly/import flows. The project aims to remain compatible with Morph’s Go implementation while leveraging the Reth stack for modular execution,
payload building, transaction pool management, and RPC handling.

Note this audit only focuses on the smart contracts in the following directories/files:

crates/revm/src/precompiles.rs
crates/revm/src/evm.rs
crates/revm/src/handler.rs
crates/primitives/src/transaction/morph_transaction.rs
crates/primitives/src/transaction/envelope.rs
crates/txpool/src/morph_tx_validation.rs
crates/txpool/src/maintain.rs
crates/rpc/src/eth/call.rs
crates/rpc/src/eth/transaction.rs
crates/engine-api/src/builder.rs
Other files are not within the scope of the audit. Additionally, all dependencies of the Target are considered reliable in terms of both functionality and security, and are therefore not
included in the audit scope.

The auditing process is iterative. Specifically, we would audit the commits that fix the discovered issues. If there are new issues, we will continue this process. The commit SHA values
during the audit are shown in the following table. Our audit report is responsible for the code in
the initial version ( `Version` `1` ), as well as new code (in the following versions) to fix issues in the
audit report. Code prior to and including the baseline version ( `Version` `0` ), where applicable, is
outside the scope of this audit and assumes to be reliable and secure.


<u><mark>Project</mark></u> <u><mark>Version</mark></u> <u><mark>Commit Hash</mark></u>
```
                  Version 1 ac2e035123f237e88a39b60cb9669168bd2bfdf8
```

Morph Reth
```
                  Version 2 f60c2b2bbde1aaee7ab02244c96a70a55e7aaf76

```

1 `[https://github.com/morph-l2/morph-reth](https://github.com/morph-l2/morph-reth)`


##### **1.2 Disclaimer**

This audit report does not constitute investment advice or a personal recommendation.
It does not consider, and should not be interpreted as considering or having any bearing on,
the potential economics of a token, token sale or any other product, service or other asset.
Any entity should not rely on this report in any way, including for the purpose of making any
decisions to buy or sell any token, product, service or other asset.

This audit report is not an endorsement of any particular project or team, and the report does not guarantee the security of any particular project. This audit does not give any
warranties on discovering all security issues of the Target, i.e., the evaluation result does not
guarantee the nonexistence of any further findings of security issues. As one audit cannot be
considered comprehensive, we always recommend proceeding with independent audits and a
public bug bounty program to ensure the security of the Target.

The scope of this audit is limited to the code mentioned in Section 1.1. Unless explicitly
specified, the security of the language itself (e.g., the solidity language), the underlying compiling toolchain and the computing infrastructure are out of the scope.

##### **1.3 Procedure of Auditing**


We perform the audit according to the following procedure.

 - **Vulnerability** **Detection** We first scan the Target with automatic code analyzers, and
then manually verify (reject or confirm) the issues reported by them.

 - **Semantic** **Analysis** We study the business logic of the Target and conduct further investigation on the possible vulnerabilities using an automatic fuzzing tool (developed by
our research team). We also manually analyze possible attack scenarios with independent
auditors to cross-check the result.

 - **Recommendation** We provide some useful advice to developers from the perspective
of good programming practice, including gas optimization, code style, and etc.
We show the main concrete checkpoints in the following.


**1.3.1** **Security Issues**


_∗_ Access control
_∗_ Permission management
_∗_ Whitelist and blacklist mechanisms
_∗_ Initialization consistency
_∗_ Improper use of the proxy system
_∗_ Reentrancy
_∗_ Denial of Service DoS
_∗_ Untrusted external call and control flow
_∗_ Exception handling
_∗_ Data handling and flow
_∗_ Events operation


2


_∗_ Error-prone randomness
_∗_ Oracle security
_∗_ Business logic correctness
_∗_ Semantic and functional consistency
_∗_ Emergency mechanism
_∗_ Economic and incentive impact


**1.3.2** **Additional Recommendation**


_∗_ Gas optimization
_∗_ Code quality and style

**Note** _The previous checkpoints are the main ones._ _We may use more checkpoints during the_
_auditing process according to the functionality of the project._

##### **1.4 Security Model**


To evaluate the risk, we follow the standards or suggestions that are widely adopted by both
industry and academy, including OWASP Risk Rating Methodology <sup>2</sup> and Common Weakness
Enumeration <sup>3</sup> . The overall _severity_ of the risk is determined by _likelihood_ and _impact_ . Specifically, likelihood is used to estimate how likely a particular vulnerability can be uncovered and
exploited by an attacker, while impact is used to measure the consequences of a successful
exploit.

In this report, both likelihood and impact are categorized into two ratings, i.e., _high_ and _low_
respectively, and their combinations are shown in Table 1.1.


**Table 1.1:** Vulnerability Severity Classification


_High_ High Medium


_Low_ Medium Low


_High_ _Low_

**Likelihood**


Accordingly, the severity measured in this report are classified into three categories: **High**,
**Medium**, **Low** . For the sake of completeness, **Undetermined** is also used to cover circumstances when the risk cannot be well determined.

Furthermore, the status of a discovered item will fall into one of the following five categories:


[2https://owasp.org/www-community/OWASP_Risk_Rating_Methodology](https://owasp.org/www-community/OWASP_Risk_Rating_Methodology)

[3https://cwe.mitre.org/](https://cwe.mitre.org/)


3


- **Undetermined** No response yet.

- **Acknowledged** The item has been received by the client, but not confirmed yet.

- **Confirmed** The item has been recognized by the client, but not fixed yet.

- **Partially Fixed** The item has been confirmed and partially fixed by the client.

- **Fixed** The item has been confirmed and fixed by the client.


4


### **Chapter 2 Findings**

In total, we found **thirteen** potential security issues. Besides, we have **three** recommendations and **two** notes.

 - High Risk: 4

 - Low Risk: 9

 - Recommendation: 3

 - Note: 2


<u><mark>ID</mark></u> <u><mark>Severity</mark></u> <u><mark>Description</mark></u> <u><mark>Category</mark></u> <u><mark>Status</mark></u>

Potential chain state inconsistency due to
1 High Security Issue Fixed
<u>incorrect</u> <u>`MorphTx`</u> <u>version detection logic</u>

Potential chain state inconsistency due to
2 High Security Issue Fixed
<u>incorrect fee validation logic</u>



3 High


4 High



Potential transaction version inconsistency due to incorrect `MorphTx` version
<u>selection logic</u>

Potential transaction type inconsistency
due to incorrect `gas_price` handling in
<u>`MorphTx`</u> <u>construction</u>



Security Issue Fixed


Security Issue Fixed



Inconsistent rounding direction for token
5 Low Security Issue Confirmed
<u>fee gas estimation</u>

Lack of trie backend configuration check
6 Low Security Issue Confirmed
<u>in block assembly</u>

Improper logic in function
7 Low Security Issue Fixed
```
       validate_version()
```

Lack of `gas_limit` check in function
8 Low Security Issue Fixed
```
       maintain_morph_pool()
```

Non-Atomic canonical head lookup in
9 Low Security Issue Fixed
<u>function</u> <u>`current_head()`</u>

Underestimated token fee in `MorphTx` pool
10 Low Security Issue Fixed
<u>validation</u>

Lack of default `chain_id` handling in
11 Low Security Issue Fixed
<u>`MorphTx`</u> <u>RPC construction</u>

Lack of RPC input validation in `MorphTx`
12 Low Security Issue Fixed
<u>construction</u>

Inconsistent gas estimation behavior be13 Low Security Issue Confirmed
<u>tween Rust and Go clients implementation</u>

Update the precompile set comment ref14 - Recommendation Fixed
<u>erence</u>

Apply `MorphTx` validation in the RPC sim15 - Recommendation Confirmed
<u>ulation path</u>


Handle database read errors in storage
16  - Recommendation Confirmed
<u>`original_value`</u> <u>restoration</u>

<u>17</u> <u>-</u> <u>Trusted token and oracle assumptions</u> <u>Note</u> <u>-</u>

<u>18</u> <u>-</u> <u>Trusted upstream</u> <u>`Revm`</u> <u>baseline</u> <u>Note</u> <u>-</u>


The details are provided in the following sections.

##### **2.1 Security Issue**


**2.1.1** **Potential chain state inconsistency due to incorrect** **`MorphTx`** **version**
**detection logic**


**Severity** High

**Status** Fixed in `Version` `2`

**Introduced by** `Version` `1`

**Description** In file `morph_transaction.rs`, the function `decode_fields()` determines the `MorphTx`
version by inspecting the first byte of the payload. Payloads whose first byte is an RLP list prefix
( `0xC0` or greater) are routed to the `V0` decoder, while payloads starting with version byte `0x01`
are routed to the `V1` decoder.

However, the Rust client implementation does not treat a leading zero byte ( `0x00` ) as a `V0`
payload indicator. On the contrary, in the Go client implementation, both a leading zero byte
and an RLP list prefix are routed to the `V0` decoder.

As a result, a `MorphTx` `V0` payload with a leading `0x00` may be accepted by the Go client
implementation but rejected by the Rust client implementation as an unsupported version. If
such a transaction is included in a block, Rust and Go nodes may disagree on block validity,
leading to a potential chain state inconsistency.


340 <mark>`///`</mark> <mark>`Decodes`</mark> <mark>`the`</mark> <mark>`inner`</mark> <mark>`fields`</mark> <mark>`from`</mark> <mark>`RLP`</mark> <mark>`bytes`</mark> <mark>`(after`</mark> <mark>`txType`</mark> <mark>`byte`</mark> <mark>`is`</mark> <mark>`consumed).`</mark>

341 <mark>`///`</mark>

342 <mark>`///`</mark> <mark>`Version`</mark> <mark>`detection`</mark> <mark>`based`</mark> <mark>`on`</mark> <mark>`first`</mark> <mark>`byte:`</mark>

343 <mark>`///`</mark> <mark>`-`</mark> <mark>`V0`</mark> <mark>`format:`</mark> <mark>`first`</mark> <mark>`byte`</mark> <mark>`is`</mark> <mark>`0`</mark> <mark>`or`</mark> <mark>`RLP`</mark> <mark>`list`</mark> <mark>`prefix`</mark> <mark>`(>=`</mark> <mark>`0xC0)`</mark> <mark>`→direct`</mark> <mark>`RLP`</mark> <mark>`decode`</mark>

344 <mark>`///`</mark> <mark>`-`</mark> <mark>`V1+`</mark> <mark>`format:`</mark> <mark>`first`</mark> <mark>`byte`</mark> <mark>`is`</mark> <mark>`version`</mark> <mark>`(0x01,`</mark> <mark>`0x02,`</mark> <mark>`...)`</mark> <mark>`→skip`</mark> <mark>`version`</mark> <mark>`byte,`</mark> <mark>`then`</mark> <mark>`RLP`</mark> <mark>`decode`</mark>

345 <mark>`///`</mark>

346 <mark>`///`</mark> <mark>`V0`</mark> <mark>`RLP:`</mark> <mark>`ChainID,`</mark> <mark>`Nonce,`</mark> <mark>`GasTipCap,`</mark> <mark>`GasFeeCap,`</mark> <mark>`Gas,`</mark> <mark>`To,`</mark> <mark>`Value,`</mark> <mark>`Data,`</mark> <mark>`AccessList,`</mark> <mark>`FeeTokenID,`</mark>
```
       FeeLimit
```

347 <mark>`///`</mark> <mark>`V1`</mark> <mark>`RLP:`</mark> <mark>`ChainID,`</mark> <mark>`Nonce,`</mark> <mark>`GasTipCap,`</mark> <mark>`GasFeeCap,`</mark> <mark>`Gas,`</mark> <mark>`To,`</mark> <mark>`Value,`</mark> <mark>`Data,`</mark> <mark>`AccessList,`</mark> <mark>`FeeTokenID,`</mark>
```
       FeeLimit, Reference, Memo
```

348 **<mark>`pub`</mark>** **<mark>`fn`</mark>** <mark>`decode_fields(buf:`</mark> <mark>`&`</mark> **<mark>`mut`</mark>** <mark>`&[`</mark> **<mark>`u8`</mark>** <mark>`])`</mark> <mark>`->`</mark> <mark>`alloy_rlp::`</mark> **<mark>`Result`</mark>** <mark>`<`</mark> **<mark>`Self`</mark>** <mark>`>`</mark> <mark>`{`</mark>

349 **<mark>`if`</mark>** <mark>`buf.is_empty()`</mark> <mark>`{`</mark>

350 **<mark>`return`</mark>** **<mark>`Err`</mark>** <mark>`(alloy_rlp::`</mark> **<mark>`Error`</mark>** <mark>`::InputTooShort);`</mark>

351 <mark>`}`</mark>

352

353 **<mark>`let`</mark>** <mark>`first_byte`</mark> <mark>`=`</mark> <mark>`buf[0];`</mark>

354

355 <mark>`//`</mark> <mark>`Check`</mark> <mark>`first`</mark> <mark>`byte`</mark> <mark>`to`</mark> <mark>`determine`</mark> <mark>`version:`</mark>


6


356 <mark>`//`</mark> <mark>`-`</mark> <mark>`V0`</mark> <mark>`format`</mark> <mark>`(legacy`</mark> <mark>`AltFeeTx):`</mark> <mark>`first`</mark> <mark>`byte`</mark> <mark>`is`</mark> <mark>`RLP`</mark> <mark>`list`</mark> <mark>`prefix`</mark> <mark>`(0xC0-0xFF),`</mark> <mark>`no`</mark> <mark>`version`</mark>
```
        prefix
```

357 <mark>`//`</mark> <mark>`-`</mark> <mark>`V1+`</mark> <mark>`format:`</mark> <mark>`first`</mark> <mark>`byte`</mark> <mark>`is`</mark> <mark>`version`</mark> <mark>`(0x01,`</mark> <mark>`0x02,`</mark> <mark>`...)`</mark> <mark>`followed`</mark> <mark>`by`</mark> <mark>`RLP`</mark>

358 **<mark>`if`</mark>** <mark>`first_byte`</mark> <mark>`>=`</mark> <mark>`0xC0`</mark> <mark>`{`</mark>

359 <mark>`//`</mark> <mark>`V0`</mark> <mark>`format:`</mark> <mark>`direct`</mark> <mark>`RLP`</mark> <mark>`decode`</mark> <mark>`(legacy`</mark> <mark>`compatible)`</mark>

360 **<mark>`Self`</mark>** <mark>`::decode_fields_v0(buf)`</mark>

361 <mark>`}`</mark> **<mark>`else`</mark>** **<mark>`if`</mark>** <mark>`first_byte`</mark> <mark>`==`</mark> <mark>`MORPH_TX_VERSION_1`</mark> <mark>`{`</mark>

362 <mark>`//`</mark> <mark>`V1`</mark> <mark>`format:`</mark> <mark>`first`</mark> <mark>`byte`</mark> <mark>`is`</mark> <mark>`version,`</mark> <mark>`rest`</mark> <mark>`is`</mark> <mark>`RLP`</mark>

363 <mark>`//`</mark> <mark>`Skip`</mark> <mark>`the`</mark> <mark>`version`</mark> <mark>`byte`</mark>

364 <mark>`*buf`</mark> <mark>`=`</mark> <mark>`&buf[1..];`</mark>

365 **<mark>`Self`</mark>** <mark>`::decode_fields_v1(buf)`</mark>

366 <mark>`}`</mark> **<mark>`else`</mark>** <mark>`{`</mark>

367 **<mark>`Err`</mark>** <mark>`(alloy_rlp::`</mark> **<mark>`Error`</mark>** <mark>`::Custom("unsupported`</mark> <mark>`morph`</mark> <mark>`tx`</mark> <mark>`version"))`</mark>

368 <mark>`}`</mark>

369 <mark>`}`</mark>


**Listing 2.1:** morph-reth/crates/primitives/src/transaction/morph_transaction.rs


**Impact** `MorphTx` `V0` payloads with a leading zero byte may be accepted by the Go client implementation but rejected by the Rust client implementation. If such transactions are propagated
or included in a block, Rust nodes may reject transactions or blocks that Go nodes consider
valid.

**Suggestion** Add the zero-byte case to the `V0` routing branch in function `decode_fields()` to
match the documented behavior.


**2.1.2** **Potential chain state inconsistency due to incorrect fee validation logic**


**Severity** High

**Status** Fixed in `Version` `2`

**Introduced by** `Version` `1`

**Description** In file `handler.rs`, the function `validate_env()` performs `EIP-1559` fee parameter validation for `MorphTx` transactions only when the transaction pays fees in the native token.
This validation path is not applied to token-fee `MorphTx` transactions. In the Go client implementation, `EIP-1559` fee parameter validation, including the requirement that `max_fee_per_gas`
`>=` `base_fee`, is applied to all non-L1-message transactions regardless of the fee payment
method.

As a result, a token-fee `MorphTx` with `max_fee_per_gas` below the current `base_fee` can pass
validation in Rust client implementation but be rejected by the Go client implementation. If such
a transaction is included in a block, Rust and Go nodes may disagree on block validity.


219 **<mark>`fn`</mark>** <mark>`validate_env(&`</mark> **<mark>`self`</mark>** <mark>`,`</mark> <mark>`evm:`</mark> <mark>`&`</mark> **<mark>`mut`</mark>** **<mark>`Self`</mark>** <mark>`::Evm)`</mark> <mark>`->`</mark> **<mark>`Result`</mark>** <mark>`<(),`</mark> **<mark>`Self`</mark>** <mark>`::`</mark> **<mark>`Error`</mark>** <mark>`>`</mark> <mark>`{`</mark>

220 <mark>`//`</mark> <mark>`For`</mark> <mark>`L1`</mark> <mark>`message`</mark> <mark>`transactions`</mark>

221 **<mark>`if`</mark>** <mark>`evm.ctx_ref().tx().is_l1_msg()`</mark> <mark>`{`</mark>

222 <mark>`//`</mark> <mark>`L1`</mark> <mark>`messages`</mark> <mark>`have`</mark> <mark>`zero`</mark> <mark>`gas`</mark> <mark>`price,`</mark> <mark>`so`</mark> <mark>`skip`</mark> <mark>`gas`</mark> <mark>`price`</mark> <mark>`validation`</mark>

223 **<mark>`return`</mark>** **<mark>`Ok`</mark>** <mark>`(());`</mark>

224 <mark>`}`</mark>

225

226 <mark>`//`</mark> <mark>`Standard`</mark> <mark>`validation.`</mark>

227 <mark>`//`</mark> <mark>`Note:`</mark> <mark>`revm`</mark> <mark>`maps`</mark> <mark>`MorphTx`</mark> <mark>`(type`</mark> <mark>`0x7F)`</mark> <mark>`to`</mark> <mark>``TransactionType::Custom`,`</mark>


7


228 <mark>`//`</mark> <mark>`which`</mark> <mark>`skips`</mark> <mark>`gas-price`</mark> <mark>`checks`</mark> <mark>`entirely.`</mark>

229 <mark>`validation::validate_env::<_,`</mark> **<mark>`Self`</mark>** <mark>`::`</mark> **<mark>`Error`</mark>** <mark>`>(evm.ctx())?;`</mark>

230

231 <mark>`//`</mark> <mark>`MorphTx`</mark> <mark>`V1`</mark> <mark>`ETH-fee:`</mark> <mark>`enforce`</mark> <mark>`the`</mark> <mark>`EIP-1559`</mark> <mark>`priority-fee`</mark> <mark>`rule.`</mark>

232 <mark>`//`</mark> <mark>`Token-fee`</mark> <mark>`MorphTx`</mark> <mark>`skips`</mark> <mark>`it`</mark> <mark>`(fees`</mark> <mark>`paid`</mark> <mark>`in`</mark> <mark>`ERC20);`</mark> <mark>`simulation`</mark>

233 <mark>`//`</mark> <mark>`paths`</mark> <mark>`also`</mark> <mark>`skip`</mark> <mark>`it.`</mark>

234 **<mark>`if`</mark>** <mark>`evm.ctx_ref().tx().is_morph_tx()`</mark>

235 <mark>`&&`</mark> <mark>`!evm.ctx_ref().tx().uses_token_fee()`</mark>

236 <mark>`&&`</mark> <mark>`!evm.ctx_ref().cfg().is_fee_charge_disabled()`</mark>

237 <mark>`{`</mark>

238 **<mark>`let`</mark>** <mark>`base_fee`</mark> <mark>`=`</mark> **<mark>`Some`</mark>** <mark>`(evm.ctx_ref().block().basefee()`</mark> **<mark>`as`</mark>** **<mark>`u128`</mark>** <mark>`);`</mark>

239 <mark>`validation::validate_priority_fee_tx(`</mark>

240 <mark>`evm.ctx_ref().tx().max_fee_per_gas(),`</mark>

241 <mark>`evm.ctx_ref()`</mark>

242 <mark>`.tx()`</mark>

243 <mark>`.max_priority_fee_per_gas()`</mark>

244 <mark>`.unwrap_or_default(),`</mark>

245 <mark>`base_fee,`</mark>

246 <mark>`evm.ctx_ref().cfg().is_priority_fee_check_disabled(),`</mark>

247 <mark>`)?;`</mark>

248 <mark>`}`</mark>

249

250 **<mark>`Ok`</mark>** <mark>`(())`</mark>

251 <mark>`}`</mark>


**Listing 2.2:** morph-reth/crates/revm/src/handler.rs


**Impact** The divergent validation can lead to state inconsistency between Rust and Go nodes,
as one accepts a block containing such a transaction while the other rejects it.

**Suggestion** Apply the `EIP-1559` fee parameter check to all `MorphTx` transactions regardless of
the fee payment token.


**2.1.3** **Potential transaction version inconsistency due to incorrect** **`MorphTx`** **version**
**selection logic**


**Severity** High

**Status** Fixed in `Version` `2`

**Introduced by** `Version` `1`

**Description** In file `transaction.rs`, the function `try_build_morph_tx_from_request()` assigns
version `V1` to all `MorphTx` transactions constructed from RPC requests. In the Go client implementation, the `MorphTx` version is selected based on the request fields. If `V1` specific fields, such
as a non-zero `reference` or a non-empty `memo`, are present, the transaction is constructed as
`V1` . Otherwise, a `MorphTx` with only `fee_token_id` set is constructed as `V0` .

As a result, the same RPC request with `fee_token_id` set but without reference or memo
may produce a `V1` transaction in Rust client implementation and a `V0` transaction in Go client
implementation, which is incorrect.


230 **<mark>`fn`</mark>** <mark>`try_build_morph_tx_from_request(`</mark>

231 <mark>`req:`</mark> <mark>`&alloy_rpc_types_eth::TransactionRequest,`</mark>


8


232 <mark>`fee_token_id:`</mark> <mark>`U64,`</mark>

233 <mark>`fee_limit:`</mark> <mark>`U256,`</mark>

234 <mark>`reference:`</mark> **<mark>`Option`</mark>** <mark>`<alloy_primitives::B256>,`</mark>

235 <mark>`memo:`</mark> **<mark>`Option`</mark>** <mark>`<alloy_primitives::`</mark> **<mark>`Bytes`</mark>** <mark>`>,`</mark>

236 <mark>`)`</mark> <mark>`->`</mark> **<mark>`Result`</mark>** <mark>`<`</mark> **<mark>`Option`</mark>** <mark>`<TxMorph>,`</mark> <mark>`&'`</mark> **<mark>`static`</mark>** **<mark>`str`</mark>** <mark>`>`</mark> <mark>`{`</mark>

237 **<mark>`let`</mark>** <mark>`fee_token_id_u16`</mark> <mark>`=`</mark> **<mark>`u16`</mark>** <mark>`::try_from(fee_token_id.to::<`</mark> **<mark>`u64`</mark>** <mark>`>()).map_err(|_|`</mark> <mark>`"invalid`</mark> <mark>`token")`</mark>
```
       ?;
```

238

239 <mark>`//`</mark> <mark>`Check`</mark> <mark>`if`</mark> <mark>`this`</mark> <mark>`should`</mark> <mark>`be`</mark> <mark>`a`</mark> <mark>`MorphTx`</mark>

240 **<mark>`let`</mark>** <mark>`has_fee_token`</mark> <mark>`=`</mark> <mark>`fee_token_id_u16`</mark> <mark>`>`</mark> <mark>`0;`</mark>

241 **<mark>`let`</mark>** <mark>`has_reference`</mark> <mark>`=`</mark> <mark>`reference.is_some();`</mark>

242 **<mark>`let`</mark>** <mark>`has_memo`</mark> <mark>`=`</mark> <mark>`memo.as_ref().is_some_and(|m|`</mark> <mark>`!m.is_empty());`</mark>

243

244 **<mark>`if`</mark>** <mark>`!has_fee_token`</mark> <mark>`&&`</mark> <mark>`!has_reference`</mark> <mark>`&&`</mark> <mark>`!has_memo`</mark> <mark>`{`</mark>

245 <mark>`//`</mark> <mark>`No`</mark> <mark>`Morph-specific`</mark> <mark>`fields`</mark> <mark>`→standard`</mark> <mark>`Ethereum`</mark> <mark>`tx`</mark>

246 **<mark>`return`</mark>** **<mark>`Ok`</mark>** <mark>`(`</mark> **<mark>`None`</mark>** <mark>`);`</mark>

247 <mark>`}`</mark>

248

249 <mark>`//`</mark> <mark>`All`</mark> <mark>`MorphTx`</mark> <mark>`are`</mark> <mark>`constructed`</mark> <mark>`as`</mark> <mark>`Version`</mark> <mark>`1`</mark>

250 **<mark>`let`</mark>** <mark>`version`</mark> <mark>`=`</mark> <mark>`morph_primitives::transaction::morph_transaction::MORPH_TX_VERSION_1;`</mark>

251

252 <mark>`//`</mark> <mark>`Now`</mark> <mark>`build`</mark> <mark>`the`</mark> <mark>`MorphTx`</mark>

253 **<mark>`let`</mark>** <mark>`chain_id`</mark> <mark>`=`</mark> <mark>`req`</mark>

254 <mark>`.chain_id`</mark>

255 <mark>`.ok_or("missing`</mark> <mark>`chain_id`</mark> <mark>`for`</mark> <mark>`morph`</mark> <mark>`transaction")?;`</mark>

256 **<mark>`let`</mark>** <mark>`gas_limit`</mark> <mark>`=`</mark> <mark>`req.gas.unwrap_or_default();`</mark>

257 **<mark>`let`</mark>** <mark>`nonce`</mark> <mark>`=`</mark> <mark>`req.nonce.unwrap_or_default();`</mark>

258 **<mark>`let`</mark>** <mark>`max_fee_per_gas`</mark> <mark>`=`</mark> <mark>`req.max_fee_per_gas.or(req.gas_price).unwrap_or_default();`</mark>

259 **<mark>`let`</mark>** <mark>`max_priority_fee_per_gas`</mark> <mark>`=`</mark> <mark>`req.max_priority_fee_per_gas.unwrap_or_default();`</mark>

260 **<mark>`let`</mark>** <mark>`access_list:`</mark> <mark>`AccessList`</mark> <mark>`=`</mark> <mark>`req.access_list.clone().unwrap_or_default();`</mark>

261 **<mark>`let`</mark>** **<mark>`input`</mark>** <mark>`=`</mark> <mark>`req.`</mark> **<mark>`input`</mark>** <mark>`.clone().into_input().unwrap_or_default();`</mark>

262 **<mark>`let`</mark>** <mark>`to`</mark> <mark>`=`</mark> <mark>`req.to.unwrap_or(TxKind::Create);`</mark>

263

264 **<mark>`let`</mark>** <mark>`morph_tx`</mark> <mark>`=`</mark> <mark>`TxMorph`</mark> <mark>`{`</mark>

265 <mark>`chain_id,`</mark>

266 <mark>`nonce,`</mark>

267 <mark>`gas_limit,`</mark>

268 <mark>`max_fee_per_gas,`</mark>

269 <mark>`max_priority_fee_per_gas,`</mark>

270 <mark>`to,`</mark>

271 <mark>`value:`</mark> <mark>`req.value.unwrap_or_default(),`</mark>

272 <mark>`access_list,`</mark>

273 **<mark>`input`</mark>** <mark>`,`</mark>

274 <mark>`fee_token_id:`</mark> <mark>`fee_token_id_u16,`</mark>

275 <mark>`fee_limit,`</mark>

276 <mark>`version,`</mark>

277 <mark>`reference,`</mark>

278 <mark>`memo,`</mark>

279 <mark>`};`</mark>

280

281 <mark>`//`</mark> <mark>`Validate`</mark> <mark>`all`</mark> <mark>`MorphTx`</mark> <mark>`constraints:`</mark> <mark>`version-specific`</mark> <mark>`rules,`</mark> <mark>`gas`</mark> <mark>`fee`</mark> <mark>`ordering,`</mark>

282 <mark>`//`</mark> <mark>`and`</mark> <mark>`memo`</mark> <mark>`length.`</mark> <mark>`This`</mark> <mark>`catches`</mark> <mark>`invalid`</mark> <mark>`combinations`</mark> <mark>`early`</mark> <mark>`at`</mark> <mark>`the`</mark> <mark>`RPC`</mark> <mark>`layer.`</mark>

283 <mark>`morph_tx.validate()?;`</mark>


9


284

285 **<mark>`Ok`</mark>** <mark>`(`</mark> **<mark>`Some`</mark>** <mark>`(morph_tx))`</mark>

286 <mark>`}`</mark>


**Listing 2.3:** morph-reth/crates/rpc/src/eth/transaction.rs


**Impact** The same RPC request can produce different `MorphTx` versions across clients, leading
to inconsistent transaction encoding and signature computation.

**Suggestion** Align Rust `MorphTx` version selection with the Go client implementation.


**2.1.4** **Potential transaction type inconsistency due to incorrect** **`gas_price`**
**handling in** **`MorphTx`** **construction**


**Severity** High

**Status** Fixed in `Version` `2`

**Introduced by** `Version` `1`

**Description** In file `transaction.rs`, function `try_build_morph_tx_from_request()` treats
`gas_price` as a fallback for `max_fee_per_gas` when constructing a `MorphTx` . If a request contains both `gas_price` and `MorphTx` specific fields, the Rust client implementation still constructs
a `MorphTx` . In the Go client implementation, the presence of `gas_price` forces the transaction
type to `LegacyTxType`, unconditionally overriding any `MorphTx` specific field detection. A request with both `gas_price` and `Morph` specific fields therefore produces a `MorphTx` in Rust client
implementation but a legacy transaction in Go client implementation, which is incorrect.


230 **<mark>`fn`</mark>** <mark>`try_build_morph_tx_from_request(`</mark>

231 <mark>`req:`</mark> <mark>`&alloy_rpc_types_eth::TransactionRequest,`</mark>

232 <mark>`fee_token_id:`</mark> <mark>`U64,`</mark>

233 <mark>`fee_limit:`</mark> <mark>`U256,`</mark>

234 <mark>`reference:`</mark> **<mark>`Option`</mark>** <mark>`<alloy_primitives::B256>,`</mark>

235 <mark>`memo:`</mark> **<mark>`Option`</mark>** <mark>`<alloy_primitives::`</mark> **<mark>`Bytes`</mark>** <mark>`>,`</mark>

236 <mark>`)`</mark> <mark>`->`</mark> **<mark>`Result`</mark>** <mark>`<`</mark> **<mark>`Option`</mark>** <mark>`<TxMorph>,`</mark> <mark>`&'`</mark> **<mark>`static`</mark>** **<mark>`str`</mark>** <mark>`>`</mark> <mark>`{`</mark>

237 **<mark>`let`</mark>** <mark>`fee_token_id_u16`</mark> <mark>`=`</mark> **<mark>`u16`</mark>** <mark>`::try_from(fee_token_id.to::<`</mark> **<mark>`u64`</mark>** <mark>`>()).map_err(|_|`</mark> <mark>`"invalid`</mark> <mark>`token")`</mark>
```
        ?;
```

238

239 <mark>`//`</mark> <mark>`Check`</mark> <mark>`if`</mark> <mark>`this`</mark> <mark>`should`</mark> <mark>`be`</mark> <mark>`a`</mark> <mark>`MorphTx`</mark>

240 **<mark>`let`</mark>** <mark>`has_fee_token`</mark> <mark>`=`</mark> <mark>`fee_token_id_u16`</mark> <mark>`>`</mark> <mark>`0;`</mark>

241 **<mark>`let`</mark>** <mark>`has_reference`</mark> <mark>`=`</mark> <mark>`reference.is_some();`</mark>

242 **<mark>`let`</mark>** <mark>`has_memo`</mark> <mark>`=`</mark> <mark>`memo.as_ref().is_some_and(|m|`</mark> <mark>`!m.is_empty());`</mark>

243

244 **<mark>`if`</mark>** <mark>`!has_fee_token`</mark> <mark>`&&`</mark> <mark>`!has_reference`</mark> <mark>`&&`</mark> <mark>`!has_memo`</mark> <mark>`{`</mark>

245 <mark>`//`</mark> <mark>`No`</mark> <mark>`Morph-specific`</mark> <mark>`fields`</mark> <mark>`→standard`</mark> <mark>`Ethereum`</mark> <mark>`tx`</mark>

246 **<mark>`return`</mark>** **<mark>`Ok`</mark>** <mark>`(`</mark> **<mark>`None`</mark>** <mark>`);`</mark>

247 <mark>`}`</mark>

248

249 <mark>`//`</mark> <mark>`All`</mark> <mark>`MorphTx`</mark> <mark>`are`</mark> <mark>`constructed`</mark> <mark>`as`</mark> <mark>`Version`</mark> <mark>`1`</mark>

250 **<mark>`let`</mark>** <mark>`version`</mark> <mark>`=`</mark> <mark>`morph_primitives::transaction::morph_transaction::MORPH_TX_VERSION_1;`</mark>

251

252 <mark>`//`</mark> <mark>`Now`</mark> <mark>`build`</mark> <mark>`the`</mark> <mark>`MorphTx`</mark>

253 **<mark>`let`</mark>** <mark>`chain_id`</mark> <mark>`=`</mark> <mark>`req`</mark>


10


254 <mark>`.chain_id`</mark>

255 <mark>`.ok_or("missing`</mark> <mark>`chain_id`</mark> <mark>`for`</mark> <mark>`morph`</mark> <mark>`transaction")?;`</mark>

256 **<mark>`let`</mark>** <mark>`gas_limit`</mark> <mark>`=`</mark> <mark>`req.gas.unwrap_or_default();`</mark>

257 **<mark>`let`</mark>** <mark>`nonce`</mark> <mark>`=`</mark> <mark>`req.nonce.unwrap_or_default();`</mark>

258 **<mark>`let`</mark>** <mark>`max_fee_per_gas`</mark> <mark>`=`</mark> <mark>`req.max_fee_per_gas.or(req.gas_price).unwrap_or_default();`</mark>

259 **<mark>`let`</mark>** <mark>`max_priority_fee_per_gas`</mark> <mark>`=`</mark> <mark>`req.max_priority_fee_per_gas.unwrap_or_default();`</mark>

260 **<mark>`let`</mark>** <mark>`access_list:`</mark> <mark>`AccessList`</mark> <mark>`=`</mark> <mark>`req.access_list.clone().unwrap_or_default();`</mark>

261 **<mark>`let`</mark>** **<mark>`input`</mark>** <mark>`=`</mark> <mark>`req.`</mark> **<mark>`input`</mark>** <mark>`.clone().into_input().unwrap_or_default();`</mark>

262 **<mark>`let`</mark>** <mark>`to`</mark> <mark>`=`</mark> <mark>`req.to.unwrap_or(TxKind::Create);`</mark>

263

264 **<mark>`let`</mark>** <mark>`morph_tx`</mark> <mark>`=`</mark> <mark>`TxMorph`</mark> <mark>`{`</mark>

265 <mark>`chain_id,`</mark>

266 <mark>`nonce,`</mark>

267 <mark>`gas_limit,`</mark>

268 <mark>`max_fee_per_gas,`</mark>

269 <mark>`max_priority_fee_per_gas,`</mark>

270 <mark>`to,`</mark>

271 <mark>`value:`</mark> <mark>`req.value.unwrap_or_default(),`</mark>

272 <mark>`access_list,`</mark>

273 **<mark>`input`</mark>** <mark>`,`</mark>

274 <mark>`fee_token_id:`</mark> <mark>`fee_token_id_u16,`</mark>

275 <mark>`fee_limit,`</mark>

276 <mark>`version,`</mark>

277 <mark>`reference,`</mark>

278 <mark>`memo,`</mark>

279 <mark>`};`</mark>

280

281 <mark>`//`</mark> <mark>`Validate`</mark> <mark>`all`</mark> <mark>`MorphTx`</mark> <mark>`constraints:`</mark> <mark>`version-specific`</mark> <mark>`rules,`</mark> <mark>`gas`</mark> <mark>`fee`</mark> <mark>`ordering,`</mark>

282 <mark>`//`</mark> <mark>`and`</mark> <mark>`memo`</mark> <mark>`length.`</mark> <mark>`This`</mark> <mark>`catches`</mark> <mark>`invalid`</mark> <mark>`combinations`</mark> <mark>`early`</mark> <mark>`at`</mark> <mark>`the`</mark> <mark>`RPC`</mark> <mark>`layer.`</mark>

283 <mark>`morph_tx.validate()?;`</mark>

284

285 **<mark>`Ok`</mark>** <mark>`(`</mark> **<mark>`Some`</mark>** <mark>`(morph_tx))`</mark>

286 <mark>`}`</mark>


**Listing 2.4:** morph-reth/crates/rpc/src/eth/transaction.rs


**Impact** The same RPC request can result in different transaction types between clients, affecting fee payment semantics and transaction processing behavior.

**Suggestion** Align the Rust and Go transaction type selection logic.


**2.1.5** **Inconsistent rounding direction for token fee gas estimation**


**Severity** Low

**Status** Confirmed

**Introduced by** `Version` `1`

**Description** In file `call.rs`, function `token_amount_to_eth()` converts the user’s `ERC20` token balance into an equivalent native token amount for gas allowance calculation in functions `eth_estimateGas()` and `eth_call()` . This conversion uses floor division. In the Go client
implementation, the function `AltToEth()` performs ceiling division by adding one whenever a
non-zero remainder exists. For the same token balance and exchange rate, the Rust client


11


implementation therefore computes a lower ETH-equivalent gas allowance than Go client implementation.


311 **<mark>`fn`</mark>** <mark>`token_amount_to_eth(token_amount:`</mark> <mark>`U256,`</mark> <mark>`info:`</mark> <mark>`&TokenFeeInfo)`</mark> <mark>`->`</mark> **<mark>`Option`</mark>** <mark>`<U256>`</mark> <mark>`{`</mark>

312 **<mark>`if`</mark>** <mark>`info.price_ratio.is_zero()`</mark> <mark>`||`</mark> <mark>`info.scale.is_zero()`</mark> <mark>`{`</mark>

313 **<mark>`return`</mark>** **<mark>`None`</mark>** <mark>`;`</mark>

314 <mark>`}`</mark>

315 **<mark>`Some`</mark>** <mark>`(token_amount.saturating_mul(info.price_ratio)`</mark> <mark>`/`</mark> <mark>`info.scale)`</mark>

316 <mark>`}`</mark>


**Listing 2.5:** morph-reth/crates/rpc/src/eth/call.rs


**Impact** When the token fee conversion produces a remainder, Rust client implementation may
calculate a lower gas allowance than the Go client implementation. As a result, a transaction
may fail gas estimation in Rust client implementation while succeeding in Go client implementation.

**Suggestion** Align token fee rounding direction with the Go client implementation by using
ceiling division.

**Feedback from the project** The project clarifies that Rust client’s floor rounding is intentional
and represents the safe, internally consistent behavior. The ceil rounding used by Go client in
the token to ETH conversion path is therefore treated as an implementation difference rather
than a defect in Rust client.


**2.1.6** **Lack of trie backend configuration check in block assembly**


**Severity** Low

**Status** Confirmed

**Introduced by** `Version` `1`

**Description** In the Go client implementation, the function `AssembleL2Block()` checks whether
the `Jade` fork status is consistent with the configured trie backend `UseZktrie` . If the configuration indicates an incompatible fork/backend combination, block assembly is rejected. This
prevents a node from producing blocks under an invalid `zktrie` to `MPT` migration configuration.

The function `assemble_l2_block()` in Rust client implementation does not perform an equivalent configuration consistency check. As a result, Rust client implementation may proceed
with block assembly without explicitly validating the fork/backend compatibility enforced by
the Go client implementation.


169 <mark>`async`</mark> **<mark>`fn`</mark>** <mark>`assemble_l2_block(`</mark>

170 <mark>`&`</mark> **<mark>`self`</mark>** <mark>`,`</mark>

171 <mark>`params:`</mark> <mark>`AssembleL2BlockParams,`</mark>

172 <mark>`)`</mark> <mark>`->`</mark> <mark>`EngineApiResult<ExecutableL2Data>`</mark> <mark>`{`</mark>

173 **<mark>`let`</mark>** <mark>`started`</mark> <mark>`=`</mark> **<mark>`Instant`</mark>** <mark>`::now();`</mark>

174 **<mark>`let`</mark>** <mark>`result`</mark> <mark>`=`</mark> **<mark>`self`</mark>** <mark>`.build_l2_payload(params,`</mark> **<mark>`None`</mark>** <mark>`,`</mark> **<mark>`None`</mark>** <mark>`).await;`</mark>

175 **<mark>`self`</mark>** <mark>`.metrics`</mark>

176 <mark>`.assemble_l2_block_duration_seconds`</mark>

177 <mark>`.record(started.elapsed());`</mark>

178

179 **<mark>`let`</mark>** <mark>`built_payload`</mark> <mark>`=`</mark> <mark>`result.inspect_err(|_|`</mark> <mark>`{`</mark>


12


180 **<mark>`self`</mark>** <mark>`.metrics.assemble_l2_block_failures_total.increment(1);`</mark>

181 <mark>`})?;`</mark>

182 **<mark>`let`</mark>** <mark>`executable_data`</mark> <mark>`=`</mark> <mark>`built_payload.executable_data;`</mark>

183

184 <mark>`tracing::debug!(`</mark>

185 <mark>`target:`</mark> <mark>`"morph::engine",`</mark>

186 <mark>`block_hash`</mark> <mark>`=`</mark> <mark>`%executable_data.hash,`</mark>

187 <mark>`gas_used`</mark> <mark>`=`</mark> <mark>`executable_data.gas_used,`</mark>

188 <mark>`tx_count`</mark> <mark>`=`</mark> <mark>`executable_data.transactions.len(),`</mark>

189 <mark>`"L2`</mark> <mark>`block`</mark> <mark>`assembled`</mark> <mark>`successfully"`</mark>

190 <mark>`);`</mark>

191

192 **<mark>`Ok`</mark>** <mark>`(executable_data)`</mark>

193 <mark>`}`</mark>


**Listing 2.6:** morph-reth/crates/engine-api/src/builder.rs


**Impact** In the Go client implementation, a node with an incompatible `Jade` fork and trie backend configuration is rejected during block assembly. Rust client implementation does not perform an equivalent safeguard, which may allow block assembly to proceed without the same
fork/backend compatibility check.

**Suggestion** Evaluate whether an equivalent fork-aware configuration check is warranted in
the block assembly path.

**Feedback** **from** **the** **project** The project clarifies that the Rust client does not expose a trie
backend switch equivalent to the Go client’s `UseZktrie` option. In the Rust client, `pre-Jade` and
`post-Jade` state root enforcement is handled centrally by the function `state_root_enforced_at()` .
Therefore, the corresponding Go client check is tied to its own trie backend configuration model
and does not directly apply to the Rust client.


**2.1.7** **Improper logic in function** **`validate_version()`**


**Severity** Low

**Status** Fixed in `Version` `2`

**Introduced by** `Version` `1`

**Description** In file `morph_transaction.rs`, the function `validate_version()` rejects any `MorphTx`
`V0` transaction where the `reference` field is `Some`, regardless of the underlying value. In the
Go client implementation, function `ValidateMorphTxVersion()` allows a `MorphTx` `V0` to carry a
`reference` field as long as the `reference` value is all zeros. A `V0` transaction containing a zerovalued `reference` is therefore accepted by the Go client implementation, but rejected by the
Rust client implementation.


204 **<mark>`pub`</mark>** **<mark>`fn`</mark>** <mark>`validate_version(&`</mark> **<mark>`self`</mark>** <mark>`)`</mark> <mark>`->`</mark> **<mark>`Result`</mark>** <mark>`<(),`</mark> <mark>`&'`</mark> **<mark>`static`</mark>** **<mark>`str`</mark>** <mark>`>`</mark> <mark>`{`</mark>

205 **<mark>`match`</mark>** **<mark>`self`</mark>** <mark>`.version`</mark> <mark>`{`</mark>

206 <mark>`MORPH_TX_VERSION_0`</mark> <mark>`=>`</mark> <mark>`{`</mark>

207 <mark>`//`</mark> <mark>`Version`</mark> <mark>`0`</mark> <mark>`requires`</mark> <mark>`FeeTokenID`</mark> <mark>`>`</mark> <mark>`0`</mark> <mark>`(legacy`</mark> <mark>`format`</mark> <mark>`used`</mark> <mark>`for`</mark> <mark>`alt-fee`</mark> <mark>`transactions)`</mark>

208 **<mark>`if`</mark>** **<mark>`self`</mark>** <mark>`.fee_token_id`</mark> <mark>`==`</mark> <mark>`0`</mark> <mark>`{`</mark>

209 **<mark>`return`</mark>** **<mark>`Err`</mark>** <mark>`("version`</mark> <mark>`0`</mark> <mark>`MorphTx`</mark> <mark>`requires`</mark> <mark>`FeeTokenID`</mark> <mark>`>`</mark> <mark>`0");`</mark>

210 <mark>`}`</mark>


13


211 <mark>`//`</mark> <mark>`Version`</mark> <mark>`0`</mark> <mark>`does`</mark> <mark>`not`</mark> <mark>`support`</mark> <mark>`Reference`</mark> <mark>`field`</mark>

212 **<mark>`if`</mark>** **<mark>`self`</mark>** <mark>`.reference.is_some()`</mark> <mark>`{`</mark>

213 **<mark>`return`</mark>** **<mark>`Err`</mark>** <mark>`("version`</mark> <mark>`0`</mark> <mark>`MorphTx`</mark> <mark>`does`</mark> <mark>`not`</mark> <mark>`support`</mark> <mark>`Reference`</mark> <mark>`field");`</mark>

214 <mark>`}`</mark>

215 <mark>`//`</mark> <mark>`Version`</mark> <mark>`0`</mark> <mark>`does`</mark> <mark>`not`</mark> <mark>`support`</mark> <mark>`Memo`</mark> <mark>`field`</mark>

216 **<mark>`if`</mark>** **<mark>`self`</mark>** <mark>`.memo.as_ref().is_some_and(|m|`</mark> <mark>`!m.is_empty())`</mark> <mark>`{`</mark>

217 **<mark>`return`</mark>** **<mark>`Err`</mark>** <mark>`("version`</mark> <mark>`0`</mark> <mark>`MorphTx`</mark> <mark>`does`</mark> <mark>`not`</mark> <mark>`support`</mark> <mark>`Memo`</mark> <mark>`field");`</mark>

218 <mark>`}`</mark>

219 <mark>`}`</mark>

220 <mark>`MORPH_TX_VERSION_1`</mark> <mark>`=>`</mark> <mark>`{`</mark>

221 <mark>`//`</mark> <mark>`Version`</mark> <mark>`1:`</mark> <mark>`FeeTokenID,`</mark> <mark>`Reference,`</mark> <mark>`Memo`</mark> <mark>`are`</mark> <mark>`all`</mark> <mark>`optional`</mark>

222 <mark>`//`</mark> <mark>`If`</mark> <mark>`FeeTokenID`</mark> <mark>`is`</mark> <mark>`0,`</mark> <mark>`FeeLimit`</mark> <mark>`must`</mark> <mark>`not`</mark> <mark>`be`</mark> <mark>`set`</mark>

223 **<mark>`if`</mark>** **<mark>`self`</mark>** <mark>`.fee_token_id`</mark> <mark>`==`</mark> <mark>`0`</mark> <mark>`&&`</mark> **<mark>`self`</mark>** <mark>`.fee_limit`</mark> <mark>`>`</mark> <mark>`U256::ZERO`</mark> <mark>`{`</mark>

224 **<mark>`return`</mark>** **<mark>`Err`</mark>** <mark>`("version`</mark> <mark>`1`</mark> <mark>`MorphTx`</mark> <mark>`cannot`</mark> <mark>`have`</mark> <mark>`FeeLimit`</mark> <mark>`when`</mark> <mark>`FeeTokenID`</mark> <mark>`is`</mark> <mark>`0");`</mark>

225 <mark>`}`</mark>

226 <mark>`}`</mark>

227 <mark>`_`</mark> <mark>`=>`</mark> <mark>`{`</mark>

228 **<mark>`return`</mark>** **<mark>`Err`</mark>** <mark>`("unsupported`</mark> <mark>`MorphTx`</mark> <mark>`version");`</mark>

229 <mark>`}`</mark>

230 <mark>`}`</mark>

231 **<mark>`Ok`</mark>** <mark>`(())`</mark>

232 <mark>`}`</mark>


**Listing 2.7:** morph-reth/crates/primitives/src/transaction/morph_transaction.rs


**Impact** Valid `MorphTx V0` transactions accepted by Go nodes may be rejected by Rust nodes,
causing inconsistent transaction admission.

**Suggestion** Update the validation logic to match the Go client implementation by allowing a
zero-valued `reference` for `MorphTx` `V0` .


**2.1.8** **Lack of** **`gas_limit`** **check in function** **`maintain_morph_pool()`**


**Severity** Low

**Status** Fixed in `Version` `2`

**Introduced by** `Version` `1`

**Description** In file `maintain.rs`, the function `maintain_morph_pool()` revalidates pending `MorphTx`
transactions on each canonical state change, checking token balances, fee parameters, and
cumulative sender affordability. However, it does not verify whether a transaction’s `gas_limit`
exceeds the current block gas limit. If the block gas limit decreases after a transaction was initially admitted to the pool, that transaction may remain in the pool despite being unexecutable.


114 **<mark>`pub`</mark>** <mark>`async`</mark> **<mark>`fn`</mark>** <mark>`maintain_morph_pool<Pool,`</mark> <mark>`Client>(pool:`</mark> <mark>`Pool,`</mark> <mark>`client:`</mark> <mark>`Client)`</mark>

115 **<mark>`where`</mark>**

116 <mark>`Pool:`</mark> <mark>`TransactionPool<Transaction`</mark> <mark>`=`</mark> <mark>`MorphPooledTransaction>`</mark> <mark>`+`</mark> **<mark>`Clone`</mark>** <mark>`,`</mark>

117 <mark>`Client:`</mark> <mark>`ChainSpecProvider<ChainSpec:`</mark> <mark>`MorphHardforks>`</mark>

118 <mark>`+`</mark> <mark>`StateProviderFactory`</mark>

119 <mark>`+`</mark> <mark>`CanonStateSubscriptions`</mark>

120 <mark>`+`</mark> **<mark>`Clone`</mark>**

121 <mark>`+`</mark> <mark>`'`</mark> **<mark>`static`</mark>** <mark>`,`</mark>

122 <mark>`{`</mark>


14


123 **<mark>`let`</mark>** **<mark>`mut`</mark>** <mark>`chain_events`</mark> <mark>`=`</mark> <mark>`client.canonical_state_stream();`</mark>

124

125 <mark>`tracing::info!(target:`</mark> <mark>`"morph::txpool::maintain",`</mark> <mark>`"Starting`</mark> <mark>`MorphTx`</mark> <mark>`maintenance`</mark> <mark>`task");`</mark>

126

127 **<mark>`loop`</mark>** <mark>`{`</mark>

128 <mark>`//`</mark> <mark>`Wait`</mark> <mark>`for`</mark> <mark>`the`</mark> <mark>`next`</mark> <mark>`canonical`</mark> <mark>`state`</mark> <mark>`change`</mark>

129 **<mark>`let`</mark>** **<mark>`Some`</mark>** <mark>`(`</mark> **<mark>`event`</mark>** <mark>`)`</mark> <mark>`=`</mark> <mark>`chain_events.next().await`</mark> **<mark>`else`</mark>** <mark>`{`</mark>

130 <mark>`tracing::debug!(target:`</mark> <mark>`"morph::txpool::maintain",`</mark> <mark>`"Chain`</mark> <mark>`event`</mark> <mark>`stream`</mark> <mark>`ended");`</mark>

131 **<mark>`break`</mark>** <mark>`;`</mark>

132 <mark>`};`</mark>

133

134 **<mark>`let`</mark>** <mark>`new_tip`</mark> <mark>`=`</mark> **<mark>`event`</mark>** <mark>`.tip();`</mark>

135 **<mark>`let`</mark>** <mark>`block_number`</mark> <mark>`=`</mark> <mark>`new_tip.number();`</mark>

136 **<mark>`let`</mark>** <mark>`block_timestamp`</mark> <mark>`=`</mark> <mark>`new_tip.`</mark> **<mark>`timestamp`</mark>** <mark>`();`</mark>

137

138 <mark>`tracing::trace!(`</mark>

139 <mark>`target:`</mark> <mark>`"morph::txpool::maintain",`</mark>

140 <mark>`block_number,`</mark>

141 <mark>`"Processing`</mark> <mark>`new`</mark> <mark>`block`</mark> <mark>`for`</mark> <mark>`MorphTx`</mark> <mark>`validation"`</mark>

142 <mark>`);`</mark>

143

144 <mark>`//`</mark> <mark>`Get`</mark> <mark>`the`</mark> <mark>`hardfork`</mark> <mark>`at`</mark> <mark>`this`</mark> <mark>`block`</mark>

145 **<mark>`let`</mark>** <mark>`hardfork`</mark> <mark>`=`</mark> <mark>`client`</mark>

146 <mark>`.chain_spec()`</mark>

147 <mark>`.morph_hardfork_at(block_number,`</mark> <mark>`block_timestamp);`</mark>

148

149 <mark>`//`</mark> <mark>`Collect`</mark> <mark>`all`</mark> <mark>`MorphTx`</mark> <mark>`transactions`</mark> <mark>`from`</mark> <mark>`the`</mark> <mark>`pool`</mark>

150 **<mark>`let`</mark>** <mark>`all_txs`</mark> <mark>`=`</mark> <mark>`pool.all_transactions();`</mark>

151 **<mark>`let`</mark>** <mark>`morph_txs:`</mark> **<mark>`Vec`</mark>** <mark>`<_>`</mark> <mark>`=`</mark> <mark>`all_txs`</mark>

152 <mark>`.pending`</mark>

153 <mark>`.iter()`</mark>

154 <mark>`.chain(all_txs.queued.iter())`</mark>

155 <mark>`.filter(|tx|`</mark> <mark>`tx.transaction.ty()`</mark> <mark>`==`</mark> <mark>`morph_primitives::MORPH_TX_TYPE_ID)`</mark>

156 <mark>`.collect();`</mark>

157

158 **<mark>`if`</mark>** <mark>`morph_txs.is_empty()`</mark> <mark>`{`</mark>

159 **<mark>`continue`</mark>** <mark>`;`</mark>

160 <mark>`}`</mark>

161

162 <mark>`//`</mark> <mark>`Get`</mark> <mark>`state`</mark> <mark>`provider`</mark> <mark>`for`</mark> <mark>`the`</mark> <mark>`new`</mark> <mark>`tip`</mark>

163 **<mark>`let`</mark>** <mark>`state_provider`</mark> <mark>`=`</mark> **<mark>`match`</mark>** <mark>`client.state_by_block_hash(new_tip.hash())`</mark> <mark>`{`</mark>

164 **<mark>`Ok`</mark>** <mark>`(provider)`</mark> <mark>`=>`</mark> <mark>`provider,`</mark>

165 **<mark>`Err`</mark>** <mark>`(err)`</mark> <mark>`=>`</mark> <mark>`{`</mark>

166 <mark>`tracing::warn!(`</mark>

167 <mark>`target:`</mark> <mark>`"morph::txpool::maintain",`</mark>

168 <mark>`%err,`</mark>

169 <mark>`"Failed`</mark> <mark>`to`</mark> <mark>`get`</mark> <mark>`state`</mark> <mark>`provider`</mark> <mark>`for`</mark> <mark>`MorphTx`</mark> <mark>`revalidation"`</mark>

170 <mark>`);`</mark>

171 **<mark>`continue`</mark>** <mark>`;`</mark>

172 <mark>`}`</mark>

173 <mark>`};`</mark>

174

175 **<mark>`let`</mark>** **<mark>`mut`</mark>** <mark>`db`</mark> <mark>`=`</mark> <mark>`StateProviderDatabase::new(state_provider);`</mark>


15


176

177 <mark>`//`</mark> <mark>`Fetch`</mark> <mark>`L1`</mark> <mark>`block`</mark> <mark>`info`</mark> <mark>`for`</mark> <mark>`fee`</mark> <mark>`calculation`</mark>

178 **<mark>`let`</mark>** <mark>`l1_block_info`</mark> <mark>`=`</mark> **<mark>`match`</mark>** <mark>`L1BlockInfo::try_fetch(&`</mark> **<mark>`mut`</mark>** <mark>`db,`</mark> <mark>`hardfork)`</mark> <mark>`{`</mark>

179 **<mark>`Ok`</mark>** <mark>`(info)`</mark> <mark>`=>`</mark> <mark>`info,`</mark>

180 **<mark>`Err`</mark>** <mark>`(err)`</mark> <mark>`=>`</mark> <mark>`{`</mark>

181 <mark>`tracing::warn!(`</mark>

182 <mark>`target:`</mark> <mark>`"morph::txpool::maintain",`</mark>

183 <mark>`?err,`</mark>

184 <mark>`"Failed`</mark> <mark>`to`</mark> <mark>`fetch`</mark> <mark>`L1`</mark> <mark>`block`</mark> <mark>`info`</mark> <mark>`for`</mark> <mark>`MorphTx`</mark> <mark>`revalidation"`</mark>

185 <mark>`);`</mark>

186 **<mark>`continue`</mark>** <mark>`;`</mark>

187 <mark>`}`</mark>

188 <mark>`};`</mark>

189

190 <mark>`tracing::trace!(`</mark>

191 <mark>`target:`</mark> <mark>`"morph::txpool::maintain",`</mark>

192 <mark>`count`</mark> <mark>`=`</mark> <mark>`morph_txs.len(),`</mark>

193 <mark>`"Revalidating`</mark> <mark>`MorphTx`</mark> <mark>`transactions"`</mark>

194 <mark>`);`</mark>

195

196 <mark>`//`</mark> <mark>`Group`</mark> <mark>`by`</mark> <mark>`sender`</mark> <mark>`and`</mark> <mark>`process`</mark> <mark>`in`</mark> <mark>`nonce`</mark> <mark>`order`</mark> <mark>`so`</mark> <mark>`affordability`</mark> <mark>`is`</mark> <mark>`validated`</mark> <mark>`cumulatively`</mark>
```
         .
```

197 **<mark>`let`</mark>** **<mark>`mut`</mark>** <mark>`txs_by_sender:`</mark> **<mark>`HashMap`</mark>** <mark>`<Address,`</mark> **<mark>`Vec`</mark>** <mark>`<_>>`</mark> <mark>`=`</mark> **<mark>`HashMap`</mark>** <mark>`::new();`</mark>

198 **<mark>`for`</mark>** <mark>`pooled_tx`</mark> **<mark>`in`</mark>** <mark>`morph_txs`</mark> <mark>`{`</mark>

199 **<mark>`let`</mark>** <mark>`sender`</mark> <mark>`=`</mark> <mark>`pooled_tx.transaction.sender();`</mark>

200 <mark>`txs_by_sender.entry(sender).or_default().push(pooled_tx);`</mark>

201 <mark>`}`</mark>

202

203 <mark>`//`</mark> <mark>`Revalidate`</mark> <mark>`each`</mark> <mark>`sender's`</mark> <mark>`MorphTx`</mark> <mark>`set`</mark> <mark>`and`</mark> <mark>`collect`</mark> <mark>`invalid`</mark> <mark>`ones`</mark>

204 **<mark>`let`</mark>** **<mark>`mut`</mark>** <mark>`to_remove:`</mark> **<mark>`Vec`</mark>** <mark>`<TxHash>`</mark> <mark>`=`</mark> **<mark>`Vec`</mark>** <mark>`::new();`</mark>

205

206 **<mark>`for`</mark>** <mark>`(sender,`</mark> **<mark>`mut`</mark>** <mark>`sender_txs)`</mark> **<mark>`in`</mark>** <mark>`txs_by_sender`</mark> <mark>`{`</mark>

207 <mark>`sender_txs.sort_by_key(|pooled_tx|`</mark> <mark>`pooled_tx.transaction.nonce());`</mark>

208

209 <mark>`//`</mark> <mark>`Initialize`</mark> <mark>`sender`</mark> <mark>`ETH`</mark> <mark>`budget`</mark> <mark>`once.`</mark>

210 **<mark>`let`</mark>** <mark>`eth_balance`</mark> <mark>`=`</mark> **<mark>`match`</mark>** <mark>`db.basic(sender)`</mark> <mark>`{`</mark>

211 **<mark>`Ok`</mark>** <mark>`(`</mark> **<mark>`Some`</mark>** <mark>`(account))`</mark> <mark>`=>`</mark> <mark>`account.balance,`</mark>

212 **<mark>`Ok`</mark>** <mark>`(`</mark> **<mark>`None`</mark>** <mark>`)`</mark> <mark>`=>`</mark> <mark>`U256::ZERO,`</mark>

213 **<mark>`Err`</mark>** <mark>`(err)`</mark> <mark>`=>`</mark> <mark>`{`</mark>

214 <mark>`tracing::warn!(`</mark>

215 <mark>`target:`</mark> <mark>`"morph::txpool::maintain",`</mark>

216 <mark>`?sender,`</mark>

217 <mark>`?err,`</mark>

218 <mark>`"Failed`</mark> <mark>`to`</mark> <mark>`get`</mark> <mark>`account`</mark> <mark>`balance"`</mark>

219 <mark>`);`</mark>

220 **<mark>`continue`</mark>** <mark>`;`</mark>

221 <mark>`}`</mark>

222 <mark>`};`</mark>

223

224 **<mark>`let`</mark>** **<mark>`mut`</mark>** <mark>`budget`</mark> <mark>`=`</mark> <mark>`SenderBudget`</mark> <mark>`{`</mark>

225 <mark>`eth_balance,`</mark>

226 <mark>`token_balances:`</mark> **<mark>`HashMap`</mark>** <mark>`::new(),`</mark>

227 <mark>`};`</mark>


16


228

229 **<mark>`for`</mark>** <mark>`pooled_tx`</mark> **<mark>`in`</mark>** <mark>`sender_txs`</mark> <mark>`{`</mark>

230 **<mark>`let`</mark>** <mark>`tx`</mark> <mark>`=`</mark> <mark>`&pooled_tx.transaction;`</mark>

231 <mark>`//`</mark> <mark>`Access`</mark> <mark>`the`</mark> <mark>`consensus`</mark> <mark>`tx`</mark> <mark>`by`</mark> <mark>`reference`</mark> <mark>`(via`</mark> <mark>`Deref`</mark> <mark>`chain)`</mark> <mark>`instead`</mark> <mark>`of`</mark>

232 <mark>`//`</mark> <mark>`cloning.`</mark> <mark>`Use`</mark> <mark>`the`</mark> <mark>`pool`</mark> <mark>`tx's`</mark> <mark>`cached`</mark> <mark>`EIP-2718`</mark> <mark>`encoding`</mark> <mark>`for`</mark> <mark>`L1`</mark> <mark>`fee.`</mark>

233 **<mark>`let`</mark>** <mark>`consensus_tx`</mark> <mark>`=`</mark> <mark>`tx.transaction();`</mark>

234

235 **<mark>`let`</mark>** <mark>`l1_data_fee`</mark> <mark>`=`</mark> <mark>`l1_block_info.calculate_tx_l1_cost(tx.encoded_2718(),`</mark> <mark>`hardfork)`</mark>
```
             ;
```

236

237 <mark>`//`</mark> <mark>`Use`</mark> <mark>`shared`</mark> <mark>`validation`</mark> <mark>`logic`</mark> <mark>`first`</mark> <mark>`with`</mark> <mark>`current`</mark> <mark>`sender`</mark> <mark>`ETH`</mark> <mark>`budget.`</mark>

238 **<mark>`let`</mark>** **<mark>`input`</mark>** <mark>`=`</mark> **<mark>`crate`</mark>** <mark>`::MorphTxValidationInput`</mark> <mark>`{`</mark>

239 <mark>`consensus_tx,`</mark>

240 <mark>`sender,`</mark>

241 <mark>`eth_balance:`</mark> <mark>`budget.eth_balance,`</mark>

242 <mark>`l1_data_fee,`</mark>

243 <mark>`base_fee_per_gas:`</mark> <mark>`new_tip.base_fee_per_gas(),`</mark>

244 <mark>`hardfork,`</mark>

245 <mark>`};`</mark>

246

247 **<mark>`let`</mark>** <mark>`validation`</mark> <mark>`=`</mark> **<mark>`match`</mark>** **<mark>`crate`</mark>** <mark>`::validate_morph_tx(&`</mark> **<mark>`mut`</mark>** <mark>`db,`</mark> <mark>`&`</mark> **<mark>`input`</mark>** <mark>`)`</mark> <mark>`{`</mark>

248 **<mark>`Ok`</mark>** <mark>`(v)`</mark> <mark>`=>`</mark> <mark>`v,`</mark>

249 **<mark>`Err`</mark>** <mark>`(err)`</mark> <mark>`=>`</mark> <mark>`{`</mark>

250 <mark>`tracing::debug!(`</mark>

251 <mark>`target:`</mark> <mark>`"morph::txpool::maintain",`</mark>

252 <mark>`tx_hash`</mark> <mark>`=`</mark> <mark>`?tx.hash(),`</mark>

253 <mark>`?sender,`</mark>

254 <mark>`?err,`</mark>

255 <mark>`"Removing`</mark> <mark>`MorphTx:`</mark> <mark>`validation`</mark> <mark>`failed"`</mark>

256 <mark>`);`</mark>

257 <mark>`to_remove.push(*tx.hash());`</mark>

258 **<mark>`break`</mark>** <mark>`;`</mark>

259 <mark>`}`</mark>

260 <mark>`};`</mark>

261

262 **<mark>`let`</mark>** <mark>`fields`</mark> <mark>`=`</mark> <mark>`consensus_tx.morph_fields();`</mark>

263 **<mark>`let`</mark>** <mark>`state_token_balance`</mark> <mark>`=`</mark> <mark>`validation.token_info.as_ref().map(|info|`</mark> <mark>`info.balance)`</mark>
```
             ;
```

264 **<mark>`let`</mark>** <mark>`token_id`</mark> <mark>`=`</mark> <mark>`fields.as_ref().map(|f|`</mark> <mark>`f.fee_token_id);`</mark>

265 **<mark>`let`</mark>** <mark>`fee_limit`</mark> <mark>`=`</mark> <mark>`fields.as_ref().map(|f|`</mark> <mark>`f.fee_limit);`</mark>

266

267 **<mark>`let`</mark>** <mark>`affordable`</mark> <mark>`=`</mark> **<mark>`if`</mark>** <mark>`validation.uses_token_fee`</mark> <mark>`{`</mark>

268 <mark>`consume_token_budget(`</mark>

269 <mark>`&`</mark> **<mark>`mut`</mark>** <mark>`budget,`</mark>

270 <mark>`consensus_tx.value(),`</mark>

271 <mark>`token_id,`</mark>

272 <mark>`fee_limit,`</mark>

273 <mark>`validation.required_token_amount,`</mark>

274 <mark>`state_token_balance,`</mark>

275 <mark>`)`</mark>

276 <mark>`}`</mark> **<mark>`else`</mark>** <mark>`{`</mark>

277 <mark>`consume_eth_budget(`</mark>

278 <mark>`&`</mark> **<mark>`mut`</mark>** <mark>`budget,`</mark>


17


279 <mark>`consensus_tx.value(),`</mark>

280 <mark>`consensus_tx.gas_limit(),`</mark>

281 <mark>`consensus_tx.max_fee_per_gas(),`</mark>

282 <mark>`l1_data_fee,`</mark>

283 <mark>`)`</mark>

284 <mark>`};`</mark>

285 **<mark>`if`</mark>** <mark>`!affordable`</mark> <mark>`{`</mark>

286 <mark>`tracing::debug!(`</mark>

287 <mark>`target:`</mark> <mark>`"morph::txpool::maintain",`</mark>

288 <mark>`tx_hash`</mark> <mark>`=`</mark> <mark>`?tx.hash(),`</mark>

289 <mark>`?sender,`</mark>

290 <mark>`uses_token_fee`</mark> <mark>`=`</mark> <mark>`validation.uses_token_fee,`</mark>

291 <mark>`token_id`</mark> <mark>`=`</mark> <mark>`?token_id,`</mark>

292 <mark>`required_token_amount`</mark> <mark>`=`</mark> <mark>`?validation.required_token_amount,`</mark>

293 <mark>`"Removing`</mark> <mark>`MorphTx:`</mark> <mark>`insufficient`</mark> <mark>`cumulative`</mark> <mark>`sender`</mark> <mark>`budget"`</mark>

294 <mark>`);`</mark>

295 <mark>`to_remove.push(*tx.hash());`</mark>

296 **<mark>`break`</mark>** <mark>`;`</mark>

297 <mark>`}`</mark>

298 <mark>`}`</mark>

299 <mark>`}`</mark>

300

301 <mark>`//`</mark> <mark>`Remove`</mark> <mark>`invalid`</mark> <mark>`transactions`</mark> <mark>`and`</mark> <mark>`all`</mark> <mark>`higher-nonce`</mark> <mark>`descendants`</mark> <mark>`from`</mark> <mark>`the`</mark> <mark>`same`</mark> <mark>`sender.`</mark>

302 <mark>`//`</mark> <mark>`Using`</mark> <mark>`remove_transactions_and_descendants`</mark> <mark>`ensures`</mark> <mark>`that`</mark> <mark>`nonce-dependent`</mark> <mark>`txs`</mark> <mark>`are`</mark>
```
          cleaned
```

303 <mark>`//`</mark> <mark>`up`</mark> <mark>`immediately`</mark> <mark>`rather`</mark> <mark>`than`</mark> <mark>`becoming`</mark> <mark>`orphans`</mark> <mark>`that`</mark> <mark>`are`</mark> <mark>`re-validated`</mark> <mark>`every`</mark> <mark>`block.`</mark>

304 **<mark>`if`</mark>** <mark>`!to_remove.is_empty()`</mark> <mark>`{`</mark>

305 **<mark>`let`</mark>** <mark>`count`</mark> <mark>`=`</mark> <mark>`to_remove.len();`</mark>

306 <mark>`pool.remove_transactions_and_descendants(to_remove);`</mark>

307 <mark>`tracing::info!(`</mark>

308 <mark>`target:`</mark> <mark>`"morph::txpool::maintain",`</mark>

309 <mark>`count,`</mark>

310 <mark>`block_number,`</mark>

311 <mark>`"Removed`</mark> <mark>`invalid`</mark> <mark>`MorphTx`</mark> <mark>`transactions"`</mark>

312 <mark>`);`</mark>

313 <mark>`}`</mark>

314 <mark>`}`</mark>

315 <mark>`}`</mark>


**Listing 2.8:** morph-reth/crates/txpool/src/maintain.rs


**Impact** Unexecutable transactions with `gas_limit` above the current block gas limit may persist in the mempool, consuming pool resources.

**Suggestion** Add a `gas_limit` check against the current block gas limit during `MorphTx` pool
maintenance.


**2.1.9** **Non-Atomic canonical head lookup in function** **`current_head()`**


**Severity** Low

**Status** Fixed in `Version` `2`

**Introduced by** `Version` `1`


18


**Description** In file `builder.rs`, the function `current_head()` retrieves the canonical head in
two sequential calls: function `chain_info()` returns the best block number and hash, then function `sealed_header_by_hash()` loads the corresponding header. If the canonical head advances
between these two calls, the hash returned by function `chain_info()` may point to a header
that is no longer accessible through the subsequent lookup, causing the function to fail with
a ” `canonical` `head` `not` `found` ” error. In the Go client implemention, the equivalent operation
reads the canonical head as a single object in one call.


884 **<mark>`fn`</mark>** <mark>`current_head(&`</mark> **<mark>`self`</mark>** <mark>`)`</mark> <mark>`->`</mark> <mark>`EngineApiResult<CanonicalHead>`</mark>

885 **<mark>`where`</mark>**

886 <mark>`Provider:`</mark> <mark>`HeaderProvider`</mark> <mark>`+`</mark> <mark>`BlockNumReader,`</mark>

887 <mark>`{`</mark>

888 **<mark>`let`</mark>** <mark>`info`</mark> <mark>`=`</mark> **<mark>`self`</mark>**

889 <mark>`.provider`</mark>

890 <mark>`.chain_info()`</mark>

891 <mark>`.map_err(|e|`</mark> <mark>`MorphEngineApiError::Database(e.to_string()))?;`</mark>

892 **<mark>`let`</mark>** <mark>`header`</mark> <mark>`=`</mark> **<mark>`self`</mark>**

893 <mark>`.provider`</mark>

894 <mark>`.sealed_header_by_hash(info.best_hash)`</mark>

895 <mark>`.map_err(|e|`</mark> <mark>`MorphEngineApiError::Database(e.to_string()))?`</mark>

896 <mark>`.ok_or_else(||`</mark> <mark>`{`</mark>

897 <mark>`MorphEngineApiError::`</mark> **<mark>`Internal`</mark>** <mark>`(`</mark> **<mark>`format!`</mark>** <mark>`(`</mark>

898 <mark>`"canonical`</mark> <mark>`head`</mark> <mark>`header`</mark> <mark>`{}`</mark> <mark>`({})`</mark> <mark>`not`</mark> <mark>`found",`</mark>

899 <mark>`info.best_number,`</mark> <mark>`info.best_hash`</mark>

900 <mark>`))`</mark>

901 <mark>`})?;`</mark>

902

903 **<mark>`Ok`</mark>** <mark>`(CanonicalHead`</mark> <mark>`{`</mark>

904 <mark>`number:`</mark> <mark>`info.best_number,`</mark>

905 <mark>`hash:`</mark> <mark>`info.best_hash,`</mark>

906 **<mark>`timestamp`</mark>** <mark>`:`</mark> <mark>`header.`</mark> **<mark>`timestamp`</mark>** <mark>`(),`</mark>

907 <mark>`})`</mark>

908 <mark>`}`</mark>


**Listing 2.9:** morph-reth/crates/engine-api/src/builder.rs


**Impact** Concurrent head updates may cause transient failures in block assembly, validation,
or import operations.

**Suggestion** Use an atomic or single-snapshot canonical head retrieval so the block hash and
header are read from the same consistent state.


**2.1.10** **Underestimated token fee in** **`MorphTx`** **pool validation**


**Severity** Low

**Status** Fixed in `Version` `2`

**Introduced by** `Version` `1`

**Description** In file `morph_tx_validation.rs`, function `validate_morph_tx()` calculates the required ERC20 token fee using `effective_gas_price`, which is derived from the current


19


`base_fee_per_gas` and is always less than or equal to `max_fee_per_gas` . In the Go client implementation, the equivalent pool validation uses `GasPrice` (equal to `GasFeeCap`, i.e., `max_fee_per_gas` )
for this calculation. If `base_fee_per_gas` increases between validation and execution, Rust client
implementation may underestimate the required token amount during validation compared with
the actual execution cost.


55 **<mark>`pub`</mark>** **<mark>`fn`</mark>** <mark>`validate_morph_tx<DB:`</mark> <mark>`Database>(`</mark>

56 <mark>`db:`</mark> <mark>`&`</mark> **<mark>`mut`</mark>** <mark>`DB,`</mark>

57 **<mark>`input`</mark>** <mark>`:`</mark> <mark>`&MorphTxValidationInput<'_>,`</mark>

58 <mark>`)`</mark> <mark>`->`</mark> **<mark>`Result`</mark>** <mark>`<MorphTxValidationResult,`</mark> <mark>`MorphTxError>`</mark> <mark>`{`</mark>

59 <mark>`//`</mark> <mark>`Keep`</mark> <mark>`MorphTx`</mark> <mark>`structural`</mark> <mark>`validation`</mark> <mark>`in`</mark> <mark>`the`</mark> <mark>`shared`</mark> <mark>`path`</mark> <mark>`so`</mark> <mark>`both`</mark> <mark>`initial`</mark>

60 <mark>`//`</mark> <mark>`admission`</mark> <mark>`and`</mark> <mark>`background`</mark> <mark>`revalidation`</mark> <mark>`enforce`</mark> <mark>`the`</mark> <mark>`same`</mark> <mark>`invariants.`</mark>

61 **<mark>`let`</mark>** <mark>`morph_tx`</mark> <mark>`=`</mark> **<mark>`match`</mark>** **<mark>`input`</mark>** <mark>`.consensus_tx`</mark> <mark>`{`</mark>

62 <mark>`MorphTxEnvelope::Morph(signed)`</mark> <mark>`=>`</mark> <mark>`signed.tx(),`</mark>

63 <mark>`_`</mark> <mark>`=>`</mark> **<mark>`return`</mark>** **<mark>`Err`</mark>** <mark>`(MorphTxError::InvalidTokenId),`</mark>

64 <mark>`};`</mark>

65

66 **<mark>`if`</mark>** <mark>`!input.hardfork.is_jade()`</mark> <mark>`&&`</mark> <mark>`morph_tx.version`</mark> <mark>`==`</mark> <mark>`MORPH_TX_VERSION_1`</mark> <mark>`{`</mark>

67 **<mark>`return`</mark>** **<mark>`Err`</mark>** <mark>`(MorphTxError::InvalidFormat`</mark> <mark>`{`</mark>

68 <mark>`reason:`</mark> <mark>`"MorphTx`</mark> <mark>`version`</mark> <mark>`1`</mark> <mark>`is`</mark> <mark>`not`</mark> <mark>`yet`</mark> <mark>`active`</mark> <mark>`(jade`</mark> <mark>`fork`</mark> <mark>`not`</mark> <mark>`reached)".to_string(),`</mark>

69 <mark>`});`</mark>

70 <mark>`}`</mark>

71

72 **<mark>`if`</mark>** **<mark>`let`</mark>** **<mark>`Err`</mark>** <mark>`(reason)`</mark> <mark>`=`</mark> <mark>`morph_tx.validate()`</mark> <mark>`{`</mark>

73 **<mark>`return`</mark>** **<mark>`Err`</mark>** <mark>`(MorphTxError::InvalidFormat`</mark> <mark>`{`</mark>

74 <mark>`reason:`</mark> <mark>`reason.to_string(),`</mark>

75 <mark>`});`</mark>

76 <mark>`}`</mark>

77

78 **<mark>`let`</mark>** <mark>`tx_value`</mark> <mark>`=`</mark> <mark>`morph_tx.value;`</mark>

79 **<mark>`if`</mark>** <mark>`tx_value`</mark> <mark>`>`</mark> **<mark>`input`</mark>** <mark>`.eth_balance`</mark> <mark>`{`</mark>

80 **<mark>`return`</mark>** **<mark>`Err`</mark>** <mark>`(MorphTxError::InsufficientEthForValue`</mark> <mark>`{`</mark>

81 <mark>`balance:`</mark> **<mark>`input`</mark>** <mark>`.eth_balance,`</mark>

82 <mark>`value:`</mark> <mark>`tx_value,`</mark>

83 <mark>`});`</mark>

84 <mark>`}`</mark>

85

86 **<mark>`let`</mark>** <mark>`fee_token_id`</mark> <mark>`=`</mark> <mark>`morph_tx.fee_token_id;`</mark>

87 **<mark>`let`</mark>** <mark>`fee_limit`</mark> <mark>`=`</mark> <mark>`morph_tx.fee_limit;`</mark>

88

89 <mark>`//`</mark> <mark>`Shared`</mark> <mark>`fee`</mark> <mark>`components`</mark> <mark>`used`</mark> <mark>`by`</mark> <mark>`both`</mark> <mark>`ETH-fee`</mark> <mark>`and`</mark> <mark>`token-fee`</mark> <mark>`branches.`</mark>

90 **<mark>`let`</mark>** <mark>`gas_limit`</mark> <mark>`=`</mark> <mark>`U256::from(morph_tx.gas_limit);`</mark>

91 **<mark>`let`</mark>** <mark>`max_fee_per_gas`</mark> <mark>`=`</mark> <mark>`U256::from(morph_tx.max_fee_per_gas);`</mark>

92 **<mark>`let`</mark>** <mark>`effective_gas_price`</mark> <mark>`=`</mark> <mark>`U256::from(morph_tx.effective_gas_price(`</mark> **<mark>`input`</mark>** <mark>`.base_fee_per_gas));`</mark>

93 **<mark>`let`</mark>** <mark>`gas_fee`</mark> <mark>`=`</mark> <mark>`gas_limit.saturating_mul(max_fee_per_gas);`</mark>

94 **<mark>`let`</mark>** <mark>`total_eth_fee`</mark> <mark>`=`</mark> <mark>`gas_fee.saturating_add(`</mark> **<mark>`input`</mark>** <mark>`.l1_data_fee);`</mark>

95 **<mark>`let`</mark>** <mark>`total_eth_cost`</mark> <mark>`=`</mark> <mark>`total_eth_fee.saturating_add(tx_value);`</mark>

96

97 <mark>`//`</mark> <mark>`fee_token_id`</mark> <mark>`==`</mark> <mark>`0`</mark> <mark>`means`</mark> <mark>`MorphTx`</mark> <mark>`uses`</mark> <mark>`ETH-fee`</mark> <mark>`path`</mark> <mark>`(reference/memo-only`</mark> <mark>`MorphTx).`</mark>

98 **<mark>`if`</mark>** <mark>`fee_token_id`</mark> <mark>`==`</mark> <mark>`0`</mark> <mark>`{`</mark>

99 **<mark>`if`</mark>** <mark>`total_eth_cost`</mark> <mark>`>`</mark> **<mark>`input`</mark>** <mark>`.eth_balance`</mark> <mark>`{`</mark>

100 **<mark>`return`</mark>** **<mark>`Err`</mark>** <mark>`(MorphTxError::InsufficientEthForValue`</mark> <mark>`{`</mark>


20


101 <mark>`balance:`</mark> **<mark>`input`</mark>** <mark>`.eth_balance,`</mark>

102 <mark>`value:`</mark> <mark>`total_eth_cost,`</mark>

103 <mark>`});`</mark>

104 <mark>`}`</mark>

105 **<mark>`return`</mark>** **<mark>`Ok`</mark>** <mark>`(MorphTxValidationResult`</mark> <mark>`{`</mark>

106 <mark>`uses_token_fee:`</mark> **<mark>`false`</mark>** <mark>`,`</mark>

107 <mark>`token_info:`</mark> **<mark>`None`</mark>** <mark>`,`</mark>

108 <mark>`required_token_amount:`</mark> <mark>`U256::ZERO,`</mark>

109 <mark>`amount_to_pay:`</mark> <mark>`U256::ZERO,`</mark>

110 <mark>`});`</mark>

111 <mark>`}`</mark>

112

113 **<mark>`let`</mark>** <mark>`token_info`</mark> <mark>`=`</mark> <mark>`TokenFeeInfo::load_for_caller(db,`</mark> <mark>`fee_token_id,`</mark> **<mark>`input`</mark>** <mark>`.sender,`</mark> **<mark>`input`</mark>** <mark>`.`</mark>
```
       hardfork)
```

114 <mark>`.map_err(|err|`</mark> <mark>`MorphTxError::TokenInfoFetchFailed`</mark> <mark>`{`</mark>

115 <mark>`token_id:`</mark> <mark>`fee_token_id,`</mark>

116 <mark>`message:`</mark> **<mark>`format!`</mark>** <mark>`("{err:?}"),`</mark>

117 <mark>`})?`</mark>

118 <mark>`.ok_or(MorphTxError::TokenNotFound`</mark> <mark>`{`</mark>

119 <mark>`token_id:`</mark> <mark>`fee_token_id,`</mark>

120 <mark>`})?;`</mark>

121

122 <mark>`//`</mark> <mark>`Check`</mark> <mark>`token`</mark> <mark>`is`</mark> <mark>`active`</mark>

123 **<mark>`if`</mark>** <mark>`!token_info.is_active`</mark> <mark>`{`</mark>

124 **<mark>`return`</mark>** **<mark>`Err`</mark>** <mark>`(MorphTxError::TokenNotActive`</mark> <mark>`{`</mark>

125 <mark>`token_id:`</mark> <mark>`fee_token_id,`</mark>

126 <mark>`});`</mark>

127 <mark>`}`</mark>

128

129 <mark>`//`</mark> <mark>`Check`</mark> <mark>`price`</mark> <mark>`ratio`</mark> <mark>`is`</mark> <mark>`valid`</mark>

130 **<mark>`if`</mark>** <mark>`token_info.price_ratio.is_zero()`</mark> <mark>`{`</mark>

131 **<mark>`return`</mark>** **<mark>`Err`</mark>** <mark>`(MorphTxError::InvalidPriceRatio`</mark> <mark>`{`</mark>

132 <mark>`token_id:`</mark> <mark>`fee_token_id,`</mark>

133 <mark>`});`</mark>

134 <mark>`}`</mark>

135

136 **<mark>`let`</mark>** <mark>`token_gas_fee`</mark> <mark>`=`</mark> <mark>`gas_limit.saturating_mul(effective_gas_price);`</mark>

137 **<mark>`let`</mark>** <mark>`total_token_fee`</mark> <mark>`=`</mark> <mark>`token_gas_fee.saturating_add(`</mark> **<mark>`input`</mark>** <mark>`.l1_data_fee);`</mark>

138 **<mark>`let`</mark>** <mark>`required_token_amount`</mark> <mark>`=`</mark> <mark>`token_info.eth_to_token_amount(total_token_fee);`</mark>

139

140 <mark>`//`</mark> <mark>`Match`</mark> <mark>`REVM`</mark> <mark>`semantics:`</mark>

141 <mark>`//`</mark> <mark>`-`</mark> <mark>`fee_limit`</mark> <mark>`==`</mark> <mark>`0`</mark> <mark>`=>`</mark> <mark>`use`</mark> <mark>`token`</mark> <mark>`balance`</mark> <mark>`as`</mark> <mark>`effective`</mark> <mark>`limit`</mark>

142 <mark>`//`</mark> <mark>`-`</mark> <mark>`fee_limit`</mark> <mark>`>`</mark> <mark>`balance`</mark> <mark>`=>`</mark> <mark>`cap`</mark> <mark>`by`</mark> <mark>`token`</mark> <mark>`balance`</mark>

143 **<mark>`let`</mark>** <mark>`effective_limit`</mark> <mark>`=`</mark> **<mark>`if`</mark>** <mark>`fee_limit.is_zero()`</mark> <mark>`||`</mark> <mark>`fee_limit`</mark> <mark>`>`</mark> <mark>`token_info.balance`</mark> <mark>`{`</mark>

144 <mark>`token_info.balance`</mark>

145 <mark>`}`</mark> **<mark>`else`</mark>** <mark>`{`</mark>

146 <mark>`fee_limit`</mark>

147 <mark>`};`</mark>

148

149 <mark>`//`</mark> <mark>`Check`</mark> <mark>`token`</mark> <mark>`balance`</mark> <mark>`against`</mark> <mark>`effective`</mark> <mark>`limit.`</mark>

150 **<mark>`if`</mark>** <mark>`effective_limit`</mark> <mark>`<`</mark> <mark>`required_token_amount`</mark> <mark>`{`</mark>

151 **<mark>`return`</mark>** **<mark>`Err`</mark>** <mark>`(MorphTxError::InsufficientTokenBalance`</mark> <mark>`{`</mark>

152 <mark>`token_id:`</mark> <mark>`fee_token_id,`</mark>


21


153 <mark>`token_address:`</mark> <mark>`token_info.token_address,`</mark>

154 <mark>`balance:`</mark> <mark>`effective_limit,`</mark>

155 <mark>`required:`</mark> <mark>`required_token_amount,`</mark>

156 <mark>`});`</mark>

157 <mark>`}`</mark>

158

159 **<mark>`Ok`</mark>** <mark>`(MorphTxValidationResult`</mark> <mark>`{`</mark>

160 <mark>`uses_token_fee:`</mark> **<mark>`true`</mark>** <mark>`,`</mark>

161 <mark>`token_info:`</mark> **<mark>`Some`</mark>** <mark>`(token_info),`</mark>

162 <mark>`required_token_amount,`</mark>

163 <mark>`amount_to_pay:`</mark> <mark>`required_token_amount,`</mark>

164 <mark>`})`</mark>

165 <mark>`}`</mark>


**Listing 2.10:** morph-reth/crates/txpool/src/morph_tx_validation.rs


**Impact** A transaction may pass pool validation with an underestimated fee requirement but
fail during execution when the `base_fee` increases.

**Suggestion** Use `max_fee_per_gas` instead of `effective_gas_price` for the upfront token fee
calculation.


**2.1.11** **Lack of default** **`chain_id`** **handling in** **`MorphTx`** **RPC construction**


**Severity** Low

**Status** Fixed in `Version` `2`

**Introduced by** `Version` `1`

**Description** In file `transaction.rs`, function `try_build_morph_tx_from_request()` requires
`chain_id` to be explicitly provided in the `RPC` request. If `chain_id` is absent, the function returns
an error immediately. In the Go client implementation, RPC behavior defaults to the node’s configured `chain_id` when it omits this field. The `MorphTx` construction path in Rust client implementation does not implement this fallback, causing valid requests without an explicit `chain_id`
to be rejected.


230 **<mark>`fn`</mark>** <mark>`try_build_morph_tx_from_request(`</mark>

231 <mark>`req:`</mark> <mark>`&alloy_rpc_types_eth::TransactionRequest,`</mark>

232 <mark>`fee_token_id:`</mark> <mark>`U64,`</mark>

233 <mark>`fee_limit:`</mark> <mark>`U256,`</mark>

234 <mark>`reference:`</mark> **<mark>`Option`</mark>** <mark>`<alloy_primitives::B256>,`</mark>

235 <mark>`memo:`</mark> **<mark>`Option`</mark>** <mark>`<alloy_primitives::`</mark> **<mark>`Bytes`</mark>** <mark>`>,`</mark>

236 <mark>`)`</mark> <mark>`->`</mark> **<mark>`Result`</mark>** <mark>`<`</mark> **<mark>`Option`</mark>** <mark>`<TxMorph>,`</mark> <mark>`&'`</mark> **<mark>`static`</mark>** **<mark>`str`</mark>** <mark>`>`</mark> <mark>`{`</mark>

237 **<mark>`let`</mark>** <mark>`fee_token_id_u16`</mark> <mark>`=`</mark> **<mark>`u16`</mark>** <mark>`::try_from(fee_token_id.to::<`</mark> **<mark>`u64`</mark>** <mark>`>()).map_err(|_|`</mark> <mark>`"invalid`</mark> <mark>`token")`</mark>
```
        ?;
```

238

239 <mark>`//`</mark> <mark>`Check`</mark> <mark>`if`</mark> <mark>`this`</mark> <mark>`should`</mark> <mark>`be`</mark> <mark>`a`</mark> <mark>`MorphTx`</mark>

240 **<mark>`let`</mark>** <mark>`has_fee_token`</mark> <mark>`=`</mark> <mark>`fee_token_id_u16`</mark> <mark>`>`</mark> <mark>`0;`</mark>

241 **<mark>`let`</mark>** <mark>`has_reference`</mark> <mark>`=`</mark> <mark>`reference.is_some();`</mark>

242 **<mark>`let`</mark>** <mark>`has_memo`</mark> <mark>`=`</mark> <mark>`memo.as_ref().is_some_and(|m|`</mark> <mark>`!m.is_empty());`</mark>

243

244 **<mark>`if`</mark>** <mark>`!has_fee_token`</mark> <mark>`&&`</mark> <mark>`!has_reference`</mark> <mark>`&&`</mark> <mark>`!has_memo`</mark> <mark>`{`</mark>

245 <mark>`//`</mark> <mark>`No`</mark> <mark>`Morph-specific`</mark> <mark>`fields`</mark> <mark>`→standard`</mark> <mark>`Ethereum`</mark> <mark>`tx`</mark>


22


246 **<mark>`return`</mark>** **<mark>`Ok`</mark>** <mark>`(`</mark> **<mark>`None`</mark>** <mark>`);`</mark>

247 <mark>`}`</mark>

248

249 <mark>`//`</mark> <mark>`All`</mark> <mark>`MorphTx`</mark> <mark>`are`</mark> <mark>`constructed`</mark> <mark>`as`</mark> <mark>`Version`</mark> <mark>`1`</mark>

250 **<mark>`let`</mark>** <mark>`version`</mark> <mark>`=`</mark> <mark>`morph_primitives::transaction::morph_transaction::MORPH_TX_VERSION_1;`</mark>

251

252 <mark>`//`</mark> <mark>`Now`</mark> <mark>`build`</mark> <mark>`the`</mark> <mark>`MorphTx`</mark>

253 **<mark>`let`</mark>** <mark>`chain_id`</mark> <mark>`=`</mark> <mark>`req`</mark>

254 <mark>`.chain_id`</mark>

255 <mark>`.ok_or("missing`</mark> <mark>`chain_id`</mark> <mark>`for`</mark> <mark>`morph`</mark> <mark>`transaction")?;`</mark>

256 **<mark>`let`</mark>** <mark>`gas_limit`</mark> <mark>`=`</mark> <mark>`req.gas.unwrap_or_default();`</mark>

257 **<mark>`let`</mark>** <mark>`nonce`</mark> <mark>`=`</mark> <mark>`req.nonce.unwrap_or_default();`</mark>

258 **<mark>`let`</mark>** <mark>`max_fee_per_gas`</mark> <mark>`=`</mark> <mark>`req.max_fee_per_gas.or(req.gas_price).unwrap_or_default();`</mark>

259 **<mark>`let`</mark>** <mark>`max_priority_fee_per_gas`</mark> <mark>`=`</mark> <mark>`req.max_priority_fee_per_gas.unwrap_or_default();`</mark>

260 **<mark>`let`</mark>** <mark>`access_list:`</mark> <mark>`AccessList`</mark> <mark>`=`</mark> <mark>`req.access_list.clone().unwrap_or_default();`</mark>

261 **<mark>`let`</mark>** **<mark>`input`</mark>** <mark>`=`</mark> <mark>`req.`</mark> **<mark>`input`</mark>** <mark>`.clone().into_input().unwrap_or_default();`</mark>

262 **<mark>`let`</mark>** <mark>`to`</mark> <mark>`=`</mark> <mark>`req.to.unwrap_or(TxKind::Create);`</mark>

263

264 **<mark>`let`</mark>** <mark>`morph_tx`</mark> <mark>`=`</mark> <mark>`TxMorph`</mark> <mark>`{`</mark>

265 <mark>`chain_id,`</mark>

266 <mark>`nonce,`</mark>

267 <mark>`gas_limit,`</mark>

268 <mark>`max_fee_per_gas,`</mark>

269 <mark>`max_priority_fee_per_gas,`</mark>

270 <mark>`to,`</mark>

271 <mark>`value:`</mark> <mark>`req.value.unwrap_or_default(),`</mark>

272 <mark>`access_list,`</mark>

273 **<mark>`input`</mark>** <mark>`,`</mark>

274 <mark>`fee_token_id:`</mark> <mark>`fee_token_id_u16,`</mark>

275 <mark>`fee_limit,`</mark>

276 <mark>`version,`</mark>

277 <mark>`reference,`</mark>

278 <mark>`memo,`</mark>

279 <mark>`};`</mark>

280

281 <mark>`//`</mark> <mark>`Validate`</mark> <mark>`all`</mark> <mark>`MorphTx`</mark> <mark>`constraints:`</mark> <mark>`version-specific`</mark> <mark>`rules,`</mark> <mark>`gas`</mark> <mark>`fee`</mark> <mark>`ordering,`</mark>

282 <mark>`//`</mark> <mark>`and`</mark> <mark>`memo`</mark> <mark>`length.`</mark> <mark>`This`</mark> <mark>`catches`</mark> <mark>`invalid`</mark> <mark>`combinations`</mark> <mark>`early`</mark> <mark>`at`</mark> <mark>`the`</mark> <mark>`RPC`</mark> <mark>`layer.`</mark>

283 <mark>`morph_tx.validate()?;`</mark>

284

285 **<mark>`Ok`</mark>** <mark>`(`</mark> **<mark>`Some`</mark>** <mark>`(morph_tx))`</mark>

286 <mark>`}`</mark>


**Listing 2.11:** morph-reth/crates/rpc/src/eth/transaction.rs


**Impact** The valid local `MorphTx` requests can be rejected when `chain_id` is not explicitly specified.

**Suggestion** Fall back to the node’s configured `chain_id` when `chain_id` is not specified in the
RPC request.


**2.1.12** **Lack of RPC input validation in** **`MorphTx`** **construction**


**Severity** Low


23


**Status** Fixed in `Version` `2`

**Introduced by** `Version` `1`

**Description** In file `transaction.rs`, function `try_build_morph_tx_from_request()` does not
perform two RPC `input` validations. First, when both the `data` and `input` fields are present
with different values, the function silently selects `input` over `data` without reporting the conflict. In contrast, the Go client implementation rejects requests containing conflicting values for
these fields. Second, when the `to` field is absent and the `input` is empty, the function constructs a contract creation transaction with no `initcode` . The Go client implementation rejects
such requests instead of constructing the transaction. These validation differences may result
in transaction construction behavior that differs from the Go client implementation.


230 **<mark>`fn`</mark>** <mark>`try_build_morph_tx_from_request(`</mark>

231 <mark>`req:`</mark> <mark>`&alloy_rpc_types_eth::TransactionRequest,`</mark>

232 <mark>`fee_token_id:`</mark> <mark>`U64,`</mark>

233 <mark>`fee_limit:`</mark> <mark>`U256,`</mark>

234 <mark>`reference:`</mark> **<mark>`Option`</mark>** <mark>`<alloy_primitives::B256>,`</mark>

235 <mark>`memo:`</mark> **<mark>`Option`</mark>** <mark>`<alloy_primitives::`</mark> **<mark>`Bytes`</mark>** <mark>`>,`</mark>

236 <mark>`)`</mark> <mark>`->`</mark> **<mark>`Result`</mark>** <mark>`<`</mark> **<mark>`Option`</mark>** <mark>`<TxMorph>,`</mark> <mark>`&'`</mark> **<mark>`static`</mark>** **<mark>`str`</mark>** <mark>`>`</mark> <mark>`{`</mark>

237 **<mark>`let`</mark>** <mark>`fee_token_id_u16`</mark> <mark>`=`</mark> **<mark>`u16`</mark>** <mark>`::try_from(fee_token_id.to::<`</mark> **<mark>`u64`</mark>** <mark>`>()).map_err(|_|`</mark> <mark>`"invalid`</mark> <mark>`token")`</mark>
```
        ?;
```

238

239 <mark>`//`</mark> <mark>`Check`</mark> <mark>`if`</mark> <mark>`this`</mark> <mark>`should`</mark> <mark>`be`</mark> <mark>`a`</mark> <mark>`MorphTx`</mark>

240 **<mark>`let`</mark>** <mark>`has_fee_token`</mark> <mark>`=`</mark> <mark>`fee_token_id_u16`</mark> <mark>`>`</mark> <mark>`0;`</mark>

241 **<mark>`let`</mark>** <mark>`has_reference`</mark> <mark>`=`</mark> <mark>`reference.is_some();`</mark>

242 **<mark>`let`</mark>** <mark>`has_memo`</mark> <mark>`=`</mark> <mark>`memo.as_ref().is_some_and(|m|`</mark> <mark>`!m.is_empty());`</mark>

243

244 **<mark>`if`</mark>** <mark>`!has_fee_token`</mark> <mark>`&&`</mark> <mark>`!has_reference`</mark> <mark>`&&`</mark> <mark>`!has_memo`</mark> <mark>`{`</mark>

245 <mark>`//`</mark> <mark>`No`</mark> <mark>`Morph-specific`</mark> <mark>`fields`</mark> <mark>`→standard`</mark> <mark>`Ethereum`</mark> <mark>`tx`</mark>

246 **<mark>`return`</mark>** **<mark>`Ok`</mark>** <mark>`(`</mark> **<mark>`None`</mark>** <mark>`);`</mark>

247 <mark>`}`</mark>

248

249 <mark>`//`</mark> <mark>`All`</mark> <mark>`MorphTx`</mark> <mark>`are`</mark> <mark>`constructed`</mark> <mark>`as`</mark> <mark>`Version`</mark> <mark>`1`</mark>

250 **<mark>`let`</mark>** <mark>`version`</mark> <mark>`=`</mark> <mark>`morph_primitives::transaction::morph_transaction::MORPH_TX_VERSION_1;`</mark>

251

252 <mark>`//`</mark> <mark>`Now`</mark> <mark>`build`</mark> <mark>`the`</mark> <mark>`MorphTx`</mark>

253 **<mark>`let`</mark>** <mark>`chain_id`</mark> <mark>`=`</mark> <mark>`req`</mark>

254 <mark>`.chain_id`</mark>

255 <mark>`.ok_or("missing`</mark> <mark>`chain_id`</mark> <mark>`for`</mark> <mark>`morph`</mark> <mark>`transaction")?;`</mark>

256 **<mark>`let`</mark>** <mark>`gas_limit`</mark> <mark>`=`</mark> <mark>`req.gas.unwrap_or_default();`</mark>

257 **<mark>`let`</mark>** <mark>`nonce`</mark> <mark>`=`</mark> <mark>`req.nonce.unwrap_or_default();`</mark>

258 **<mark>`let`</mark>** <mark>`max_fee_per_gas`</mark> <mark>`=`</mark> <mark>`req.max_fee_per_gas.or(req.gas_price).unwrap_or_default();`</mark>

259 **<mark>`let`</mark>** <mark>`max_priority_fee_per_gas`</mark> <mark>`=`</mark> <mark>`req.max_priority_fee_per_gas.unwrap_or_default();`</mark>

260 **<mark>`let`</mark>** <mark>`access_list:`</mark> <mark>`AccessList`</mark> <mark>`=`</mark> <mark>`req.access_list.clone().unwrap_or_default();`</mark>

261 **<mark>`let`</mark>** **<mark>`input`</mark>** <mark>`=`</mark> <mark>`req.`</mark> **<mark>`input`</mark>** <mark>`.clone().into_input().unwrap_or_default();`</mark>

262 **<mark>`let`</mark>** <mark>`to`</mark> <mark>`=`</mark> <mark>`req.to.unwrap_or(TxKind::Create);`</mark>

263

264 **<mark>`let`</mark>** <mark>`morph_tx`</mark> <mark>`=`</mark> <mark>`TxMorph`</mark> <mark>`{`</mark>

265 <mark>`chain_id,`</mark>

266 <mark>`nonce,`</mark>

267 <mark>`gas_limit,`</mark>

268 <mark>`max_fee_per_gas,`</mark>


24


269 <mark>`max_priority_fee_per_gas,`</mark>

270 <mark>`to,`</mark>

271 <mark>`value:`</mark> <mark>`req.value.unwrap_or_default(),`</mark>

272 <mark>`access_list,`</mark>

273 **<mark>`input`</mark>** <mark>`,`</mark>

274 <mark>`fee_token_id:`</mark> <mark>`fee_token_id_u16,`</mark>

275 <mark>`fee_limit,`</mark>

276 <mark>`version,`</mark>

277 <mark>`reference,`</mark>

278 <mark>`memo,`</mark>

279 <mark>`};`</mark>

280

281 <mark>`//`</mark> <mark>`Validate`</mark> <mark>`all`</mark> <mark>`MorphTx`</mark> <mark>`constraints:`</mark> <mark>`version-specific`</mark> <mark>`rules,`</mark> <mark>`gas`</mark> <mark>`fee`</mark> <mark>`ordering,`</mark>

282 <mark>`//`</mark> <mark>`and`</mark> <mark>`memo`</mark> <mark>`length.`</mark> <mark>`This`</mark> <mark>`catches`</mark> <mark>`invalid`</mark> <mark>`combinations`</mark> <mark>`early`</mark> <mark>`at`</mark> <mark>`the`</mark> <mark>`RPC`</mark> <mark>`layer.`</mark>

283 <mark>`morph_tx.validate()?;`</mark>

284

285 **<mark>`Ok`</mark>** <mark>`(`</mark> **<mark>`Some`</mark>** <mark>`(morph_tx))`</mark>

286 <mark>`}`</mark>


**Listing 2.12:** morph-reth/crates/rpc/src/eth/transaction.rs


**Impact** Malformed RPC requests with conflicting calldata fields or empty contract creation
may be accepted by Rust client implementation but rejected by the Go client implementation,
potentially causing inconsistent transaction construction behavior.

**Suggestion** Reject requests where `data` and `input` fields are both present with conflicting
values, and reject contract creation requests with empty calldata.


**2.1.13** **Inconsistent gas estimation behavior between Rust and Go clients**
**implementation**


**Severity** Low

**Status** Confirmed

**Introduced by** `Version` `1`

**Description** In file `transaction.rs`, function `try_build_morph_tx_from_request()` determines
whether a request should enter the token-fee path by checking whether `fee_token_id` is greater
than 0. As a result, when a request specifies a `fee_token_id` value of zero, the Rust client
implementation treats the request as a native-fee transaction and does not construct a tokenfee transaction.

In contrast, the Go client implementation interprets the presence of `fee_token_id` as an
indication that token-fee payment is intended. Consequently, requests with a `fee_token_id`
value of zero are rejected during gas estimation.

As a result, gas estimation requests specifying a `fee_token_id` value of zero are handled
differently by the Rust and Go client implementations.


230 **<mark>`fn`</mark>** <mark>`try_build_morph_tx_from_request(`</mark>

231 <mark>`req:`</mark> <mark>`&alloy_rpc_types_eth::TransactionRequest,`</mark>

232 <mark>`fee_token_id:`</mark> <mark>`U64,`</mark>

233 <mark>`fee_limit:`</mark> <mark>`U256,`</mark>


25


234 <mark>`reference:`</mark> **<mark>`Option`</mark>** <mark>`<alloy_primitives::B256>,`</mark>

235 <mark>`memo:`</mark> **<mark>`Option`</mark>** <mark>`<alloy_primitives::`</mark> **<mark>`Bytes`</mark>** <mark>`>,`</mark>

236 <mark>`)`</mark> <mark>`->`</mark> **<mark>`Result`</mark>** <mark>`<`</mark> **<mark>`Option`</mark>** <mark>`<TxMorph>,`</mark> <mark>`&'`</mark> **<mark>`static`</mark>** **<mark>`str`</mark>** <mark>`>`</mark> <mark>`{`</mark>

237 **<mark>`let`</mark>** <mark>`fee_token_id_u16`</mark> <mark>`=`</mark> **<mark>`u16`</mark>** <mark>`::try_from(fee_token_id.to::<`</mark> **<mark>`u64`</mark>** <mark>`>()).map_err(|_|`</mark> <mark>`"invalid`</mark> <mark>`token")`</mark>
```
       ?;
```

238

239 <mark>`//`</mark> <mark>`Check`</mark> <mark>`if`</mark> <mark>`this`</mark> <mark>`should`</mark> <mark>`be`</mark> <mark>`a`</mark> <mark>`MorphTx`</mark>

240 **<mark>`let`</mark>** <mark>`has_fee_token`</mark> <mark>`=`</mark> <mark>`fee_token_id_u16`</mark> <mark>`>`</mark> <mark>`0;`</mark>

241 **<mark>`let`</mark>** <mark>`has_reference`</mark> <mark>`=`</mark> <mark>`reference.is_some();`</mark>

242 **<mark>`let`</mark>** <mark>`has_memo`</mark> <mark>`=`</mark> <mark>`memo.as_ref().is_some_and(|m|`</mark> <mark>`!m.is_empty());`</mark>

243

244 **<mark>`if`</mark>** <mark>`!has_fee_token`</mark> <mark>`&&`</mark> <mark>`!has_reference`</mark> <mark>`&&`</mark> <mark>`!has_memo`</mark> <mark>`{`</mark>

245 <mark>`//`</mark> <mark>`No`</mark> <mark>`Morph-specific`</mark> <mark>`fields`</mark> <mark>`→standard`</mark> <mark>`Ethereum`</mark> <mark>`tx`</mark>

246 **<mark>`return`</mark>** **<mark>`Ok`</mark>** <mark>`(`</mark> **<mark>`None`</mark>** <mark>`);`</mark>

247 <mark>`}`</mark>

248

249 <mark>`//`</mark> <mark>`All`</mark> <mark>`MorphTx`</mark> <mark>`are`</mark> <mark>`constructed`</mark> <mark>`as`</mark> <mark>`Version`</mark> <mark>`1`</mark>

250 **<mark>`let`</mark>** <mark>`version`</mark> <mark>`=`</mark> <mark>`morph_primitives::transaction::morph_transaction::MORPH_TX_VERSION_1;`</mark>

251

252 <mark>`//`</mark> <mark>`Now`</mark> <mark>`build`</mark> <mark>`the`</mark> <mark>`MorphTx`</mark>

253 **<mark>`let`</mark>** <mark>`chain_id`</mark> <mark>`=`</mark> <mark>`req`</mark>

254 <mark>`.chain_id`</mark>

255 <mark>`.ok_or("missing`</mark> <mark>`chain_id`</mark> <mark>`for`</mark> <mark>`morph`</mark> <mark>`transaction")?;`</mark>

256 **<mark>`let`</mark>** <mark>`gas_limit`</mark> <mark>`=`</mark> <mark>`req.gas.unwrap_or_default();`</mark>

257 **<mark>`let`</mark>** <mark>`nonce`</mark> <mark>`=`</mark> <mark>`req.nonce.unwrap_or_default();`</mark>

258 **<mark>`let`</mark>** <mark>`max_fee_per_gas`</mark> <mark>`=`</mark> <mark>`req.max_fee_per_gas.or(req.gas_price).unwrap_or_default();`</mark>

259 **<mark>`let`</mark>** <mark>`max_priority_fee_per_gas`</mark> <mark>`=`</mark> <mark>`req.max_priority_fee_per_gas.unwrap_or_default();`</mark>

260 **<mark>`let`</mark>** <mark>`access_list:`</mark> <mark>`AccessList`</mark> <mark>`=`</mark> <mark>`req.access_list.clone().unwrap_or_default();`</mark>

261 **<mark>`let`</mark>** **<mark>`input`</mark>** <mark>`=`</mark> <mark>`req.`</mark> **<mark>`input`</mark>** <mark>`.clone().into_input().unwrap_or_default();`</mark>

262 **<mark>`let`</mark>** <mark>`to`</mark> <mark>`=`</mark> <mark>`req.to.unwrap_or(TxKind::Create);`</mark>

263

264 **<mark>`let`</mark>** <mark>`morph_tx`</mark> <mark>`=`</mark> <mark>`TxMorph`</mark> <mark>`{`</mark>

265 <mark>`chain_id,`</mark>

266 <mark>`nonce,`</mark>

267 <mark>`gas_limit,`</mark>

268 <mark>`max_fee_per_gas,`</mark>

269 <mark>`max_priority_fee_per_gas,`</mark>

270 <mark>`to,`</mark>

271 <mark>`value:`</mark> <mark>`req.value.unwrap_or_default(),`</mark>

272 <mark>`access_list,`</mark>

273 **<mark>`input`</mark>** <mark>`,`</mark>

274 <mark>`fee_token_id:`</mark> <mark>`fee_token_id_u16,`</mark>

275 <mark>`fee_limit,`</mark>

276 <mark>`version,`</mark>

277 <mark>`reference,`</mark>

278 <mark>`memo,`</mark>

279 <mark>`};`</mark>

280

281 <mark>`//`</mark> <mark>`Validate`</mark> <mark>`all`</mark> <mark>`MorphTx`</mark> <mark>`constraints:`</mark> <mark>`version-specific`</mark> <mark>`rules,`</mark> <mark>`gas`</mark> <mark>`fee`</mark> <mark>`ordering,`</mark>

282 <mark>`//`</mark> <mark>`and`</mark> <mark>`memo`</mark> <mark>`length.`</mark> <mark>`This`</mark> <mark>`catches`</mark> <mark>`invalid`</mark> <mark>`combinations`</mark> <mark>`early`</mark> <mark>`at`</mark> <mark>`the`</mark> <mark>`RPC`</mark> <mark>`layer.`</mark>

283 <mark>`morph_tx.validate()?;`</mark>

284

285 **<mark>`Ok`</mark>** <mark>`(`</mark> **<mark>`Some`</mark>** <mark>`(morph_tx))`</mark>


26


286 <mark>`}`</mark>


**Listing 2.13:** morph-reth/crates/rpc/src/eth/transaction.rs


**Impact** Identical gas estimation requests may be accepted by the Rust client implementation
but rejected by the Go client implementation when the value of `fee_token_id` is zero, resulting
in inconsistent behavior across client implementations.

**Suggestion** Ensure consistent handling of requests specifying a `fee_token_id` value of zero
across Rust and Go client implementations.

**Feedback** **from** **the** **project** The project clarifies that the issue will be addressed in the Go
client, as the current behavior of the Rust client is considered the intended implementation.

##### **2.2 Recommendation**


**2.2.1** **Update the precompile set comment reference**


**Status** Fixed in `Version` `2`

**Introduced by** `Version` `1`

**Description** In file `precompiles.rs`, the comment for the function `bernoulli()` links to
`PrecompiledContractsMorph203` in the Go client implementation, while the function itself implements the `Bernoulli` precompile set. The correct reference should be `PrecompiledContractsBernoulli` .

These two precompile sets are distinct and have different configurations for `ripemd160`
`(0x03)` and `blake2f` `(0x09)` . The incorrect reference may mislead future reviewers when comparing the in Rust and Go client implementation precompile definitions.


248 <mark>`///`</mark> <mark>`Returns`</mark> <mark>`precompiles`</mark> <mark>`for`</mark> <mark>`Bernoulli`</mark> <mark>`hardfork.`</mark>

249 <mark>`///`</mark>

250 <mark>`///`</mark> <mark>`Based`</mark> <mark>`on`</mark> <mark>`Berlin`</mark> <mark>`with`</mark> <mark>`ripemd160`</mark> <mark>`(0x03)`</mark> <mark>`and`</mark> <mark>`blake2f`</mark> <mark>`(0x09)`</mark> <mark>`replaced`</mark> <mark>`by`</mark> <mark>`disabled`</mark> <mark>`stubs.`</mark>

251 <mark>`///`</mark> <mark>`All`</mark> <mark>`9`</mark> <mark>`Berlin`</mark> <mark>`addresses`</mark> <mark>`are`</mark> <mark>`present`</mark> <mark>`(so`</mark> <mark>`they`</mark> <mark>`get`</mark> <mark>`warmed`</mark> <mark>`via`</mark> <mark>`EIP-2929),`</mark> <mark>`but`</mark> <mark>`0x03/0x09`</mark>

252 <mark>`///`</mark> <mark>`consume`</mark> <mark>`all`</mark> <mark>`forwarded`</mark> <mark>`gas`</mark> <mark>`and`</mark> <mark>`return`</mark> <mark>`failure`</mark> <mark>`when`</mark> <mark>`called.`</mark>

253 <mark>`///`</mark>

254 <mark>`///`</mark> <mark>`Matches:`</mark> <mark>`<https://github.com/morph-l2/go-ethereum/blob/main/core/vm/contracts.go#L136-L148>`</mark>

255 **<mark>`pub`</mark>** **<mark>`fn`</mark>** <mark>`bernoulli()`</mark> <mark>`->`</mark> <mark>`&'`</mark> **<mark>`static`</mark>** <mark>`Precompiles`</mark> <mark>`{`</mark>

256 **<mark>`static`</mark>** <mark>`INSTANCE:`</mark> <mark>`OnceLock<Precompiles>`</mark> <mark>`=`</mark> <mark>`OnceLock::new();`</mark>

257 <mark>`INSTANCE.get_or_init(||`</mark> <mark>`{`</mark>

258 <mark>`//`</mark> <mark>`Start`</mark> <mark>`from`</mark> <mark>`Berlin`</mark> <mark>`(9`</mark> <mark>`precompiles`</mark> <mark>`including`</mark> <mark>`0x03`</mark> <mark>`and`</mark> <mark>`0x09).`</mark>

259 **<mark>`let`</mark>** **<mark>`mut`</mark>** <mark>`precompiles`</mark> <mark>`=`</mark> <mark>`Precompiles::berlin().clone();`</mark>

260

261 <mark>`//`</mark> <mark>`Replace`</mark> <mark>`ripemd160`</mark> <mark>`(0x03)`</mark> <mark>`and`</mark> <mark>`blake2f`</mark> <mark>`(0x09)`</mark> <mark>`with`</mark> <mark>`disabled`</mark> <mark>`stubs.`</mark>

262 <mark>`//`</mark> <mark>`This`</mark> <mark>`keeps`</mark> <mark>`them`</mark> <mark>`in`</mark> <mark>`warm_addresses()`</mark> <mark>`so`</mark> <mark>`EIP-2929`</mark> <mark>`warms`</mark> <mark>`them`</mark> <mark>`(100`</mark> <mark>`gas`</mark> <mark>`instead`</mark> <mark>`of`</mark>

263 <mark>`//`</mark> <mark>`2600`</mark> <mark>`cold),`</mark> <mark>`matching`</mark> <mark>`go-ethereum's`</mark> <mark>`PrecompiledContractsBernoulli`</mark> <mark>`behavior.`</mark>

264 <mark>`precompiles.extend([`</mark>

265 <mark>`Precompile::new(`</mark>

266 <mark>`PrecompileId::Ripemd160,`</mark>

267 <mark>`addresses::RIPEMD160,`</mark>

268 <mark>`ripemd160_disabled,`</mark>

269 <mark>`),`</mark>

270 <mark>`Precompile::new(PrecompileId::Blake2F,`</mark> <mark>`addresses::BLAKE2F,`</mark> <mark>`blake2f_disabled),`</mark>


27


271 <mark>`]);`</mark>

272

273 <mark>`//`</mark> <mark>`Replace`</mark> <mark>`modexp`</mark> <mark>`(0x05)`</mark> <mark>`with`</mark> <mark>`32-byte`</mark> <mark>`input`</mark> <mark>`limit`</mark> <mark>`wrapper.`</mark>

274 <mark>`//`</mark> <mark>`go-ethereum's`</mark> <mark>`Bernoulli`</mark> <mark>`modexp`</mark> <mark>`has`</mark> <mark>`eip2565=true`</mark> <mark>`but`</mark> <mark>`neither`</mark> <mark>`eip7823`</mark> <mark>`nor`</mark> <mark>`eip7883,`</mark>

275 <mark>`//`</mark> <mark>`which`</mark> <mark>`enforces`</mark> <mark>`base/exp/mod`</mark> <mark>`<=`</mark> <mark>`32`</mark> <mark>`bytes.`</mark> <mark>`Berlin`</mark> <mark>`modexp`</mark> <mark>`in`</mark> <mark>`revm`</mark> <mark>`has`</mark> <mark>`no`</mark> <mark>`such`</mark> <mark>`limit.`</mark>

276 <mark>`precompiles.extend([Precompile::new(`</mark>

277 <mark>`PrecompileId::ModExp,`</mark>

278 <mark>`addresses::MODEXP,`</mark>

279 <mark>`modexp_with_32byte_limit,`</mark>

280 <mark>`)]);`</mark>

281

282 <mark>`precompiles`</mark>

283 <mark>`})`</mark>

284 <mark>`}`</mark>


**Listing 2.14:** morph-reth/crates/revm/src/precompiles.rs


**Suggestion** Update the comment to reference the correct precompile set in the Go client implementation, and ensure that the linked line numbers point to the corresponding implementation.


**2.2.2** **Apply** **`MorphTx`** **validation in the RPC simulation path**


**Status** Confirmed

**Introduced by** `Version` `1`

**Description** In file `transaction.rs`, the function `try_into_tx_env()` converts an RPC request
into a `MorphTxEnv` for functions `eth_call()` and `eth_estimateGas()` . Unlike the real transaction
construction path (in function `try_build_morph_tx_from_request()` ), it does not invoke function `TxMorph::validate()` or perform an equivalent structural check. Although this path only
serves simulation and does not submit transactions on-chain, function `eth_call()` and function `eth_estimateGas()` should enforce the same `MorphTx` structural rules to prevent simulations
of transactions that would be rejected during actual construction or submission.


162 **<mark>`fn`</mark>** <mark>`try_into_tx_env(`</mark>

163 **<mark>`self`</mark>** <mark>`,`</mark>

164 <mark>`evm_env:`</mark> <mark>`&EvmEnv<Spec,`</mark> <mark>`MorphBlockEnv>,`</mark>

165 <mark>`)`</mark> <mark>`->`</mark> **<mark>`Result`</mark>** <mark>`<MorphTxEnv,`</mark> **<mark>`Self`</mark>** <mark>`::`</mark> **<mark>`Err`</mark>** <mark>`>`</mark> <mark>`{`</mark>

166 **<mark>`let`</mark>** <mark>`fee_token_id`</mark> <mark>`=`</mark> **<mark>`self`</mark>** <mark>`.fee_token_id;`</mark>

167 **<mark>`let`</mark>** <mark>`fee_limit`</mark> <mark>`=`</mark> **<mark>`self`</mark>** <mark>`.fee_limit;`</mark>

168 **<mark>`let`</mark>** <mark>`reference`</mark> <mark>`=`</mark> **<mark>`self`</mark>** <mark>`.reference;`</mark>

169 **<mark>`let`</mark>** <mark>`memo`</mark> <mark>`=`</mark> **<mark>`self`</mark>** <mark>`.memo;`</mark>

170 **<mark>`let`</mark>** <mark>`inner`</mark> <mark>`=`</mark> **<mark>`self`</mark>** <mark>`.inner;`</mark>

171

172 **<mark>`let`</mark>** <mark>`inner_tx_env`</mark> <mark>`=`</mark> <mark>`inner.try_into_tx_env(evm_env).map_err(EthApiError::from)?;`</mark>

173

174 **<mark>`let`</mark>** **<mark>`mut`</mark>** <mark>`tx_env`</mark> <mark>`=`</mark> <mark>`MorphTxEnv::new(inner_tx_env);`</mark>

175 <mark>`tx_env.fee_token_id`</mark> <mark>`=`</mark> **<mark>`match`</mark>** <mark>`fee_token_id`</mark> <mark>`{`</mark>

176 **<mark>`Some`</mark>** <mark>`(`</mark> **<mark>`id`</mark>** <mark>`)`</mark> <mark>`=>`</mark> **<mark>`Some`</mark>** <mark>`(`</mark>

177 **<mark>`u16`</mark>** <mark>`::try_from(`</mark> **<mark>`id`</mark>** <mark>`.to::<`</mark> **<mark>`u64`</mark>** <mark>`>())`</mark>

178 <mark>`.map_err(|_|`</mark> <mark>`EthApiError::InvalidParams("invalid`</mark> <mark>`token".to_string()))?,`</mark>


28


179 <mark>`),`</mark>

180 **<mark>`None`</mark>** <mark>`=>`</mark> **<mark>`None`</mark>** <mark>`,`</mark>

181 <mark>`};`</mark>

182 <mark>`tx_env.fee_limit`</mark> <mark>`=`</mark> <mark>`fee_limit;`</mark>

183 <mark>`tx_env.reference`</mark> <mark>`=`</mark> <mark>`reference;`</mark>

184 <mark>`tx_env.memo`</mark> <mark>`=`</mark> <mark>`memo.clone();`</mark>

185

186 <mark>`//`</mark> <mark>`Determine`</mark> <mark>`if`</mark> <mark>`this`</mark> <mark>`is`</mark> <mark>`a`</mark> <mark>`MorphTx`</mark> <mark>`based`</mark> <mark>`on`</mark> <mark>`Morph-specific`</mark> <mark>`fields`</mark>

187 **<mark>`let`</mark>** <mark>`is_morph_tx`</mark> <mark>`=`</mark> <mark>`fee_token_id.is_some_and(|`</mark> **<mark>`id`</mark>** <mark>`|`</mark> **<mark>`id`</mark>** <mark>`.to::<`</mark> **<mark>`u64`</mark>** <mark>`>()`</mark> <mark>`>`</mark> <mark>`0)`</mark>

188 <mark>`||`</mark> <mark>`reference.is_some()`</mark>

189 <mark>`||`</mark> <mark>`memo.as_ref().is_some_and(|m|`</mark> <mark>`!m.is_empty());`</mark>

190

191 **<mark>`if`</mark>** <mark>`is_morph_tx`</mark> <mark>`{`</mark>

192 <mark>`tx_env.inner.tx_type`</mark> <mark>`=`</mark> <mark>`morph_primitives::MORPH_TX_TYPE_ID;`</mark>

193 <mark>`tx_env.version`</mark> <mark>`=`</mark>

194 **<mark>`Some`</mark>** <mark>`(morph_primitives::transaction::morph_transaction::MORPH_TX_VERSION_1);`</mark>

195 <mark>`}`</mark>

196

197 <mark>`//`</mark> <mark>`Required`</mark> <mark>`by`</mark> <mark>``MorphEthApi::caller_gas_allowance``</mark> <mark>`(eth/call.rs)`</mark> <mark>`to`</mark>

198 <mark>`//`</mark> <mark>`recover`</mark> <mark>`the`</mark> <mark>`L1`</mark> <mark>`data`</mark> <mark>`fee`</mark> <mark>`when`</mark> <mark>`capping`</mark> <mark>``eth_estimateGas``</mark> <mark>`allowance.`</mark>

199 <mark>`tx_env.rlp_bytes`</mark> <mark>`=`</mark> **<mark>`Some`</mark>** <mark>`(tx_env.encode_for_l1_fee(evm_env.cfg_env.chain_id));`</mark>

200

201 **<mark>`Ok`</mark>** <mark>`(tx_env)`</mark>

202 <mark>`}`</mark>


**Listing 2.15:** morph-reth/crates/rpc/src/eth/transaction.rs


**Suggestion** Reuse the `MorphTx` structural validation in function `try_into_tx_env()` to match
the real transaction construction path.

**Feedback** **from** **the** **project** The project clarifies that this code path is used exclusively by
the `eth_call()` and `eth_estimateGas()` RPC methods. RPC request conversion already handles `MorphTx` field parsing, transaction version determination, and L1 fee encoding. As a result,
invoking function `TxMorph::validate()` in this path would duplicate validation logic with limited
practical benefit.


**2.2.3** **Handle database read errors in storage** **`original_value`** **restoration**


**Status** Confirmed

**Introduced by** `Version` `1`

**Description** In file `evm.rs`, functions `sload_morph()` and `sstore_morph()` restore the `original_value`
of storage slots that were modified during token fee deduction. The restoration reads the committed value from the database and only applies the correction when the read succeeds. If the
database read fails, the error is silently ignored and execution continues with a potentially incorrect `original_value` . Since the correctness of `EIP-2200` gas accounting and refund calculation
depends on `original_value`, a failed restoration could cause gas charges to diverge from the
expected behavior.


96 **<mark>`fn`</mark>** <mark>`sload_morph<DB:`</mark> <mark>`Database>(context:`</mark> <mark>`InstructionContext<'_,`</mark> <mark>`MorphContext<DB>,`</mark> <mark>`EthInterpreter>)`</mark>
```
       {

```

29


97 **<mark>`let`</mark>** **<mark>`Some`</mark>** <mark>`(([],`</mark> <mark>`index))`</mark> <mark>`=`</mark> <mark>`StackTr::popn_top::<0>(&`</mark> **<mark>`mut`</mark>** <mark>`context.interpreter.`</mark> **<mark>`stack`</mark>** <mark>`)`</mark> **<mark>`else`</mark>** <mark>`{`</mark>

98 <mark>`context.interpreter.halt_underflow();`</mark>

99 **<mark>`return`</mark>** <mark>`;`</mark>

100 <mark>`};`</mark>

101

102 **<mark>`let`</mark>** <mark>`target`</mark> <mark>`=`</mark> <mark>`context.interpreter.`</mark> **<mark>`input`</mark>** <mark>`.target_address;`</mark>

103 **<mark>`let`</mark>** **<mark>`key`</mark>** <mark>`=`</mark> <mark>`*index;`</mark>

104

105 **<mark>`let`</mark>** <mark>`additional_cold_cost`</mark> <mark>`=`</mark> <mark>`context.host.gas_params().cold_storage_additional_cost();`</mark>

106 **<mark>`let`</mark>** <mark>`skip_cold`</mark> <mark>`=`</mark> <mark>`context.interpreter.gas.remaining()`</mark> <mark>`<`</mark> <mark>`additional_cold_cost;`</mark>

107 **<mark>`let`</mark>** <mark>`res`</mark> <mark>`=`</mark> <mark>`context.host.sload_skip_cold_load(target,`</mark> **<mark>`key`</mark>** <mark>`,`</mark> <mark>`skip_cold);`</mark>

108

109 **<mark>`match`</mark>** <mark>`res`</mark> <mark>`{`</mark>

110 **<mark>`Ok`</mark>** <mark>`(storage)`</mark> <mark>`=>`</mark> <mark>`{`</mark>

111 **<mark>`if`</mark>** <mark>`storage.is_cold`</mark> <mark>`{`</mark>

112 <mark>`//`</mark> <mark>`Read`</mark> <mark>`the`</mark> <mark>`true`</mark> <mark>`committed`</mark> <mark>`value`</mark> <mark>`from`</mark> <mark>`DB`</mark> <mark>`(hits`</mark> <mark>`State<DB>`</mark> <mark>`cache,`</mark> <mark>`O(1)).`</mark>

113 <mark>`//`</mark> <mark>`This`</mark> <mark>`matches`</mark> <mark>`go-eth's`</mark> <mark>`GetCommittedState()`</mark> <mark>`returning`</mark> <mark>`the`</mark> <mark>`un-modified`</mark> <mark>`DB`</mark> <mark>`value.`</mark>

114 **<mark>`let`</mark>** <mark>`db_original`</mark> <mark>`=`</mark> <mark>`context.host.journaled_state.database.storage(target,`</mark> **<mark>`key`</mark>** <mark>`);`</mark>

115 **<mark>`if`</mark>** **<mark>`let`</mark>** **<mark>`Ok`</mark>** <mark>`(db_original)`</mark> <mark>`=`</mark> <mark>`db_original`</mark>

116 <mark>`&&`</mark> **<mark>`let`</mark>** **<mark>`Some`</mark>** <mark>`(acc)`</mark> <mark>`=`</mark> <mark>`context.host.journaled_state.inner.state.get_mut(&target)`</mark>

117 <mark>`&&`</mark> **<mark>`let`</mark>** **<mark>`Some`</mark>** <mark>`(slot)`</mark> <mark>`=`</mark> <mark>`acc.storage.get_mut(&`</mark> **<mark>`key`</mark>** <mark>`)`</mark>

118 <mark>`&&`</mark> <mark>`slot.original_value`</mark> <mark>`!=`</mark> <mark>`db_original`</mark>

119 <mark>`{`</mark>

120 <mark>`slot.original_value`</mark> <mark>`=`</mark> <mark>`db_original;`</mark>

121 <mark>`}`</mark>

122

123 **<mark>`if`</mark>** <mark>`!context`</mark>

124 <mark>`.interpreter`</mark>

125 <mark>`.gas`</mark>

126 <mark>`.record_regular_cost(additional_cold_cost)`</mark>

127 <mark>`{`</mark>

128 <mark>`context.interpreter.halt_oog();`</mark>

129 **<mark>`return`</mark>** <mark>`;`</mark>

130 <mark>`}`</mark>

131 <mark>`}`</mark>

132

133 <mark>`*index`</mark> <mark>`=`</mark> <mark>`storage.data;`</mark>

134 <mark>`}`</mark>

135 **<mark>`Err`</mark>** <mark>`(LoadError::ColdLoadSkipped)`</mark> <mark>`=>`</mark> <mark>`context.interpreter.halt_oog(),`</mark>

136 **<mark>`Err`</mark>** <mark>`(LoadError::DBError)`</mark> <mark>`=>`</mark> <mark>`context.interpreter.halt_fatal(),`</mark>

137 <mark>`}`</mark>

138 <mark>`}`</mark>


**Listing 2.16:** morph-reth/crates/revm/src/evm.rs


96 **<mark>`fn`</mark>** <mark>`sload_morph<DB:`</mark> <mark>`Database>(context:`</mark> <mark>`InstructionContext<'_,`</mark> <mark>`MorphContext<DB>,`</mark> <mark>`EthInterpreter>)`</mark>
```
      {
```

97 **<mark>`let`</mark>** **<mark>`Some`</mark>** <mark>`(([],`</mark> <mark>`index))`</mark> <mark>`=`</mark> <mark>`StackTr::popn_top::<0>(&`</mark> **<mark>`mut`</mark>** <mark>`context.interpreter.`</mark> **<mark>`stack`</mark>** <mark>`)`</mark> **<mark>`else`</mark>** <mark>`{`</mark>

98 <mark>`context.interpreter.halt_underflow();`</mark>

99 **<mark>`return`</mark>** <mark>`;`</mark>

100 <mark>`};`</mark>

101

102 **<mark>`let`</mark>** <mark>`target`</mark> <mark>`=`</mark> <mark>`context.interpreter.`</mark> **<mark>`input`</mark>** <mark>`.target_address;`</mark>


30


103 **<mark>`let`</mark>** **<mark>`key`</mark>** <mark>`=`</mark> <mark>`*index;`</mark>

104

105 **<mark>`let`</mark>** <mark>`additional_cold_cost`</mark> <mark>`=`</mark> <mark>`context.host.gas_params().cold_storage_additional_cost();`</mark>

106 **<mark>`let`</mark>** <mark>`skip_cold`</mark> <mark>`=`</mark> <mark>`context.interpreter.gas.remaining()`</mark> <mark>`<`</mark> <mark>`additional_cold_cost;`</mark>

107 **<mark>`let`</mark>** <mark>`res`</mark> <mark>`=`</mark> <mark>`context.host.sload_skip_cold_load(target,`</mark> **<mark>`key`</mark>** <mark>`,`</mark> <mark>`skip_cold);`</mark>

108

109 **<mark>`match`</mark>** <mark>`res`</mark> <mark>`{`</mark>

110 **<mark>`Ok`</mark>** <mark>`(storage)`</mark> <mark>`=>`</mark> <mark>`{`</mark>

111 **<mark>`if`</mark>** <mark>`storage.is_cold`</mark> <mark>`{`</mark>

112 <mark>`//`</mark> <mark>`Read`</mark> <mark>`the`</mark> <mark>`true`</mark> <mark>`committed`</mark> <mark>`value`</mark> <mark>`from`</mark> <mark>`DB`</mark> <mark>`(hits`</mark> <mark>`State<DB>`</mark> <mark>`cache,`</mark> <mark>`O(1)).`</mark>

113 <mark>`//`</mark> <mark>`This`</mark> <mark>`matches`</mark> <mark>`go-eth's`</mark> <mark>`GetCommittedState()`</mark> <mark>`returning`</mark> <mark>`the`</mark> <mark>`un-modified`</mark> <mark>`DB`</mark> <mark>`value.`</mark>

114 **<mark>`let`</mark>** <mark>`db_original`</mark> <mark>`=`</mark> <mark>`context.host.journaled_state.database.storage(target,`</mark> **<mark>`key`</mark>** <mark>`);`</mark>

115 **<mark>`if`</mark>** **<mark>`let`</mark>** **<mark>`Ok`</mark>** <mark>`(db_original)`</mark> <mark>`=`</mark> <mark>`db_original`</mark>

116 <mark>`&&`</mark> **<mark>`let`</mark>** **<mark>`Some`</mark>** <mark>`(acc)`</mark> <mark>`=`</mark> <mark>`context.host.journaled_state.inner.state.get_mut(&target)`</mark>

117 <mark>`&&`</mark> **<mark>`let`</mark>** **<mark>`Some`</mark>** <mark>`(slot)`</mark> <mark>`=`</mark> <mark>`acc.storage.get_mut(&`</mark> **<mark>`key`</mark>** <mark>`)`</mark>

118 <mark>`&&`</mark> <mark>`slot.original_value`</mark> <mark>`!=`</mark> <mark>`db_original`</mark>

119 <mark>`{`</mark>

120 <mark>`slot.original_value`</mark> <mark>`=`</mark> <mark>`db_original;`</mark>

121 <mark>`}`</mark>

122

123 **<mark>`if`</mark>** <mark>`!context`</mark>

124 <mark>`.interpreter`</mark>

125 <mark>`.gas`</mark>

126 <mark>`.record_regular_cost(additional_cold_cost)`</mark>

127 <mark>`{`</mark>

128 <mark>`context.interpreter.halt_oog();`</mark>

129 **<mark>`return`</mark>** <mark>`;`</mark>

130 <mark>`}`</mark>

131 <mark>`}`</mark>

132

133 <mark>`*index`</mark> <mark>`=`</mark> <mark>`storage.data;`</mark>

134 <mark>`}`</mark>

135 **<mark>`Err`</mark>** <mark>`(LoadError::ColdLoadSkipped)`</mark> <mark>`=>`</mark> <mark>`context.interpreter.halt_oog(),`</mark>

136 **<mark>`Err`</mark>** <mark>`(LoadError::DBError)`</mark> <mark>`=>`</mark> <mark>`context.interpreter.halt_fatal(),`</mark>

137 <mark>`}`</mark>

138 <mark>`}`</mark>

139

140 <mark>`///`</mark> <mark>`Morph`</mark> <mark>`custom`</mark> <mark>`SSTORE`</mark> <mark>`opcode.`</mark>

141 <mark>`///`</mark>

142 <mark>`///`</mark> <mark>`Twin`</mark> <mark>`of`</mark> <mark>`[`sload_morph`]:`</mark> <mark>`revm's`</mark> <mark>`standard`</mark> <mark>`SSTORE`</mark> <mark>`warms`</mark> <mark>`a`</mark> <mark>`cold`</mark> <mark>`slot`</mark> <mark>`through`</mark>

143 <mark>`///`</mark> <mark>`the`</mark> <mark>`same`</mark> <mark>``mark_warm_with_transaction_id()``</mark> <mark>`path`</mark> <mark>`as`</mark> <mark>`SLOAD,`</mark> <mark>`so`</mark> <mark>`forced-cold`</mark>

144 <mark>`///`</mark> <mark>`token-fee`</mark> <mark>`slots`</mark> <mark>`need`</mark> <mark>`the`</mark> <mark>`same`</mark> <mark>``original_value``</mark> <mark>`restoration`</mark> <mark>`before`</mark>

145 <mark>`///`</mark> <mark>``sstore_dynamic_gas()``</mark> <mark>`reads`</mark> <mark>`it`</mark> <mark>`for`</mark> <mark>`EIP-2200`</mark> <mark>`accounting.`</mark>

146 <mark>`///`</mark>

147 <mark>`///`</mark> <mark>`Without`</mark> <mark>`this,`</mark> <mark>`a`</mark> <mark>`main`</mark> <mark>`tx`</mark> <mark>`that`</mark> <mark>`writes`</mark> <mark>`a`</mark> <mark>`fee-deducted`</mark> <mark>`slot`</mark> <mark>`WITHOUT`</mark> <mark>`first`</mark>

148 <mark>`///`</mark> <mark>`SLOADing`</mark> <mark>`it`</mark> <mark>`sees`</mark> <mark>`a`</mark> <mark>`"clean"`</mark> <mark>`slot`</mark> <mark>`(2900`</mark> <mark>`gas`</mark> <mark>`SSTORE_RESET,`</mark> <mark>`no`</mark> <mark>`refund)`</mark>

149 <mark>`///`</mark> <mark>`instead`</mark> <mark>`of`</mark> <mark>`a`</mark> <mark>`"dirty"`</mark> <mark>`slot`</mark> <mark>`(100`</mark> <mark>`gas`</mark> <mark>`SLOAD_GAS`</mark> <mark>`plus`</mark> <mark>`refund),`</mark> <mark>`causing`</mark> <mark>`the`</mark>

150 <mark>`///`</mark> <mark>`same`</mark> <mark>`2800-gas-per-write`</mark> <mark>`divergence`</mark> <mark>`vs`</mark> <mark>`go-eth`</mark> <mark>`that`</mark> <mark>``sload_morph``</mark> <mark>`fixes.`</mark>

151 <mark>`///`</mark>

152 <mark>`///`</mark> <mark>`Uses`</mark> <mark>`DB-direct`</mark> <mark>`lookup`</mark> <mark>`(no`</mark> <mark>`per-tx`</mark> <mark>`runtime`</mark> <mark>`map`</mark> <mark>`needed).`</mark>

153 **<mark>`fn`</mark>** <mark>`sstore_morph<DB:`</mark> <mark>`Database>(context:`</mark> <mark>`InstructionContext<'_,`</mark> <mark>`MorphContext<DB>,`</mark> <mark>`EthInterpreter`</mark>
```
      >) {
```

154 **<mark>`if`</mark>** <mark>`context.interpreter.runtime_flag.is_static()`</mark> <mark>`{`</mark>


31


155 <mark>`context`</mark>

156 <mark>`.interpreter`</mark>

157 <mark>`.halt(InstructionResult::StateChangeDuringStaticCall);`</mark>

158 **<mark>`return`</mark>** <mark>`;`</mark>

159 <mark>`}`</mark>

160

161 **<mark>`let`</mark>** **<mark>`Some`</mark>** <mark>`([index,`</mark> <mark>`value])`</mark> <mark>`=`</mark> <mark>`StackTr::popn::<2>(&`</mark> **<mark>`mut`</mark>** <mark>`context.interpreter.`</mark> **<mark>`stack`</mark>** <mark>`)`</mark> **<mark>`else`</mark>** <mark>`{`</mark>

162 <mark>`context.interpreter.halt_underflow();`</mark>

163 **<mark>`return`</mark>** <mark>`;`</mark>

164 <mark>`};`</mark>

165

166 **<mark>`let`</mark>** <mark>`target`</mark> <mark>`=`</mark> <mark>`context.interpreter.`</mark> **<mark>`input`</mark>** <mark>`.target_address;`</mark>

167 **<mark>`let`</mark>** <mark>`spec_id`</mark> <mark>`=`</mark> <mark>`context.interpreter.runtime_flag.spec_id();`</mark>

168

169 **<mark>`if`</mark>** <mark>`spec_id.is_enabled_in(ISTANBUL)`</mark>

170 <mark>`&&`</mark> <mark>`context.interpreter.gas.remaining()`</mark> <mark>`<=`</mark> <mark>`context.host.gas_params().call_stipend()`</mark>

171 <mark>`{`</mark>

172 <mark>`context`</mark>

173 <mark>`.interpreter`</mark>

174 <mark>`.halt(InstructionResult::ReentrancySentryOOG);`</mark>

175 **<mark>`return`</mark>** <mark>`;`</mark>

176 <mark>`}`</mark>

177

178 **<mark>`if`</mark>** <mark>`!context`</mark>

179 <mark>`.interpreter`</mark>

180 <mark>`.gas`</mark>

181 <mark>`.record_regular_cost(context.host.gas_params().sstore_static_gas())`</mark>

182 <mark>`{`</mark>

183 <mark>`context.interpreter.halt_oog();`</mark>

184 **<mark>`return`</mark>** <mark>`;`</mark>

185 <mark>`}`</mark>

186

187 **<mark>`let`</mark>** **<mark>`mut`</mark>** <mark>`state_load`</mark> <mark>`=`</mark> **<mark>`if`</mark>** <mark>`spec_id.is_enabled_in(BERLIN)`</mark> <mark>`{`</mark>

188 **<mark>`let`</mark>** <mark>`additional_cold_cost`</mark> <mark>`=`</mark> <mark>`context.host.gas_params().cold_storage_additional_cost();`</mark>

189 **<mark>`let`</mark>** <mark>`skip_cold`</mark> <mark>`=`</mark> <mark>`context.interpreter.gas.remaining()`</mark> <mark>`<`</mark> <mark>`additional_cold_cost;`</mark>

190 **<mark>`match`</mark>** <mark>`context`</mark>

191 <mark>`.host`</mark>

192 <mark>`.sstore_skip_cold_load(target,`</mark> <mark>`index,`</mark> <mark>`value,`</mark> <mark>`skip_cold)`</mark>

193 <mark>`{`</mark>

194 **<mark>`Ok`</mark>** <mark>`(`</mark> **<mark>`load`</mark>** <mark>`)`</mark> <mark>`=>`</mark> **<mark>`load`</mark>** <mark>`,`</mark>

195 **<mark>`Err`</mark>** <mark>`(LoadError::ColdLoadSkipped)`</mark> <mark>`=>`</mark> <mark>`{`</mark>

196 <mark>`context.interpreter.halt_oog();`</mark>

197 **<mark>`return`</mark>** <mark>`;`</mark>

198 <mark>`}`</mark>

199 **<mark>`Err`</mark>** <mark>`(LoadError::DBError)`</mark> <mark>`=>`</mark> <mark>`{`</mark>

200 <mark>`context.interpreter.halt_fatal();`</mark>

201 **<mark>`return`</mark>** <mark>`;`</mark>

202 <mark>`}`</mark>

203 <mark>`}`</mark>

204 <mark>`}`</mark> **<mark>`else`</mark>** <mark>`{`</mark>

205 **<mark>`let`</mark>** **<mark>`Some`</mark>** <mark>`(`</mark> **<mark>`load`</mark>** <mark>`)`</mark> <mark>`=`</mark> <mark>`context.host.sstore(target,`</mark> <mark>`index,`</mark> <mark>`value)`</mark> **<mark>`else`</mark>** <mark>`{`</mark>

206 <mark>`context.interpreter.halt_fatal();`</mark>

207 **<mark>`return`</mark>** <mark>`;`</mark>


32


208 <mark>`};`</mark>

209 **<mark>`load`</mark>**

210 <mark>`};`</mark>

211

212 <mark>`//`</mark> <mark>`Morph`</mark> <mark>`fix:`</mark> <mark>`on`</mark> <mark>`cold`</mark> <mark>`access,`</mark> <mark>`restore`</mark> <mark>`original_value`</mark> <mark>`from`</mark> <mark>`the`</mark> <mark>`DB-committed`</mark> <mark>`value.`</mark>

213 <mark>`//`</mark> <mark>`Mirrors`</mark> <mark>`sload_morph.`</mark> <mark>`Only`</mark> <mark>`fires`</mark> <mark>`on`</mark> <mark>`cold`</mark> <mark>`path;`</mark> <mark>`zero`</mark> <mark>`overhead`</mark> <mark>`on`</mark> <mark>`warm`</mark> <mark>`SSTOREs.`</mark>

214 **<mark>`if`</mark>** <mark>`state_load.is_cold`</mark> <mark>`{`</mark>

215 **<mark>`let`</mark>** <mark>`db_original`</mark> <mark>`=`</mark> <mark>`context.host.journaled_state.database.storage(target,`</mark> <mark>`index);`</mark>

216 **<mark>`if`</mark>** **<mark>`let`</mark>** **<mark>`Ok`</mark>** <mark>`(db_original)`</mark> <mark>`=`</mark> <mark>`db_original`</mark>

217 <mark>`&&`</mark> <mark>`state_load.data.original_value`</mark> <mark>`!=`</mark> <mark>`db_original`</mark>

218 <mark>`{`</mark>

219 <mark>`state_load.data.original_value`</mark> <mark>`=`</mark> <mark>`db_original;`</mark>

220 **<mark>`if`</mark>** **<mark>`let`</mark>** **<mark>`Some`</mark>** <mark>`(acc)`</mark> <mark>`=`</mark> <mark>`context.host.journaled_state.inner.state.get_mut(&target)`</mark>

221 <mark>`&&`</mark> **<mark>`let`</mark>** **<mark>`Some`</mark>** <mark>`(slot)`</mark> <mark>`=`</mark> <mark>`acc.storage.get_mut(&index)`</mark>

222 <mark>`{`</mark>

223 <mark>`slot.original_value`</mark> <mark>`=`</mark> <mark>`db_original;`</mark>

224 <mark>`}`</mark>

225 <mark>`}`</mark>

226 <mark>`}`</mark>

227

228 **<mark>`let`</mark>** <mark>`is_istanbul`</mark> <mark>`=`</mark> <mark>`spec_id.is_enabled_in(ISTANBUL);`</mark>

229 **<mark>`let`</mark>** <mark>`dynamic_gas`</mark> <mark>`=`</mark> <mark>`context.host.gas_params().sstore_dynamic_gas(`</mark>

230 <mark>`is_istanbul,`</mark>

231 <mark>`&state_load.data,`</mark>

232 <mark>`state_load.is_cold,`</mark>

233 <mark>`);`</mark>

234 **<mark>`if`</mark>** <mark>`!context.interpreter.gas.record_regular_cost(dynamic_gas)`</mark> <mark>`{`</mark>

235 <mark>`context.interpreter.halt_oog();`</mark>

236 **<mark>`return`</mark>** <mark>`;`</mark>

237 <mark>`}`</mark>

238

239 <mark>`context.interpreter.gas.record_refund(`</mark>

240 <mark>`context`</mark>

241 <mark>`.host`</mark>

242 <mark>`.gas_params()`</mark>

243 <mark>`.sstore_refund(is_istanbul,`</mark> <mark>`&state_load.data),`</mark>

244 <mark>`);`</mark>

245 <mark>`}`</mark>


**Listing 2.17:** morph-reth/crates/revm/src/evm.rs


**Suggestion** Propagate the database read error and halt execution when the committed value
cannot be retrieved.

**Feedback from the project** The project clarifies that the committed storage read is intended
only as a best-effort correction of `original_value` following token-fee related storage updates.
Failures in the primary `sload` and `sstore` database operations already halt execution, whereas
failures in this auxiliary correction path are intentionally treated as non-fatal. Treating such
failures as fatal would introduce additional complexity without a corresponding benefit.


33


##### **2.3 Note**

**2.3.1** **Trusted token and oracle assumptions**


**Introduced by** `Version` `1`

**Description** Protocol supported gas tokens are assumed to be whitelisted, trusted, and standardscompliant ERC20 tokens. Under this assumption, the function `balanceOf()` function returns a
valid 32-byte balance, the `transfer()` function follows normal ERC20 semantics, and token
behavior does not depend on unexpected caller-specific logic. The chain oracle is also assumed to provide correct and timely pricing data for token fee conversion.

Under these assumptions, the observed implementation differences in balance queries are
unlikely to affect supported gas tokens. Specifically, in function `query_balance_via_system_call()`,
the Rust client implementation falls back to function `system_call_one()` when the cached balance slot is unavailable, while the Go client implementation uses function `StaticCall()` with
the user address as the caller. In addition, the Rust client implementation treats short or failed
`balanceOf()` results as zero, whereas the Go client implementation returns an error when the
returned data is shorter than expected.

A similar caller difference also exists in function `evm_call_balance_of()` . The Rust client
implementation constructs the correct calldata, but executes the internal call with `Address::ZERO`
as the caller instead of the queried account.

For standard whitelisted gas tokens, these differences should not affect the returned balance.


**2.3.2** **Trusted upstream** **`Revm`** **baseline**


**Introduced by** `Version` `1`

**Description** The audit focused on the `Morph` specific changes and the files explicitly included
in the audit scope, rather than the entire codebase. As an assumption, the upstream Rust execution client logic based on `paradigmxyz/reth` `v2.2.0` <sup>1</sup> was treated as a trusted baseline dependency. This baseline covers the `Reth` execution stack, together with the `Revm` derived EVM
logic used by `Reth` . These upstream components were assumed to correctly implement the
expected Ethereum execution semantics.


1 `[https://github.com/paradigmxyz/reth/tree/88505c7fcbfdebfd3b56d88c86b62e950043c6c4](https://github.com/paradigmxyz/reth/tree/88505c7fcbfdebfd3b56d88c86b62e950043c6c4)`


34


