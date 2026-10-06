# **Report for Morph** **Emerald upgrade**

## Date: December 23, 2025 Version: 1.0 Contact: contact@blocksec.com


### **Contents**

**Chapter 1 Introduction** **1**

1.1 About the Audit Target . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1

1.2 Disclaimer . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2

1.3 Procedure of Auditing . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 3

1.3.1 Security Issues . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 3

1.3.2 Additional Recommendation . . . . . . . . . . . . . . . . . . . . . . . . . . . . 3

1.4 Security Model . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4


**Chapter 2 Findings** **5**

2.1 Security Issue . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 5

2.1.1 Incorrect access control logic in the modifier `onlyAllowed` . . . . . . . . . . 5

2.1.2 Inconsistent updates of the price ratio and token scale . . . . . . . . . . . . 6

2.1.3 Lack of the value assignment for `FeeLimit` in the `CallArgs` construction . . 9

2.1.4 The misleading return value of the function `getTokenInfo()` . . . . . . . . . 10

2.2 Recommendation . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 11

2.2.1 Revise the unused function `Filter()` . . . . . . . . . . . . . . . . . . . . . . . 11

2.2.2 Remove redundant code . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 12

2.2.3 Add non-zero checks . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 14

2.2.4 Revise the improper error in the function `calculateTokenAmount()` . . . . . 15

2.2.5 Revise typos and improper annotations . . . . . . . . . . . . . . . . . . . . . 15

2.2.6 Unify the existence checks for the balance slot . . . . . . . . . . . . . . . . . 17

2.2.7 Use different custom errors for different revert conditions . . . . . . . . . . 18

2.3 Note . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 18

2.3.1 Ensure the correctness of fee tokens . . . . . . . . . . . . . . . . . . . . . . . 18

2.3.2 Potential centralization risks . . . . . . . . . . . . . . . . . . . . . . . . . . . . 19

2.3.3 Openzeppelin upgrade migration risks . . . . . . . . . . . . . . . . . . . . . . 19

2.3.4 Correct handling of the fee tokens in the contract `L2TxFeeVault` . . . . . . . 19


**Report Manifest**


<u><mark>Item</mark></u> <u><mark>Description</mark></u>
<u>Client</u> <u>Morph</u>
<u>Target</u> <u>Morph Emerald upgrade</u>


**Version History**


<u><mark>Version</mark></u> <u><mark>Date</mark></u> <u><mark>Description</mark></u>
<u>1.0</u> <u>December 23, 2025</u> <u>First release</u>


**Signature**


Digitally signed by: BlockSec (https://blocksec.com)

SHA1 digest of public key: BAB106D3708BC6DE0963CE05E9478C24B326AE1C

Date: 2025-12-24 09:16:52+0000


**About** **BlockSec** [BlockSec](https://www.blocksec.com) focuses on the security of the blockchain ecosystem and col
laborates with leading DeFi projects to secure their products. BlockSec is founded by top
notch security researchers and experienced experts from both academia and industry. They

have published multiple blockchain security papers in prestigious conferences, reported sev
eral zero-day attacks of DeFi applications, and successfully protected digital assets that are

worth more than 14 million dollars by blocking multiple attacks. [They can be reached at Email,](mailto:contact@blocksec.com)

[Twitter and Medium.](https://twitter.com/BlockSecTeam)


### **Chapter 1 Introduction**

##### **1.1 About the Audit Target**

<u><mark>Information</mark></u> <u><mark>Description</mark></u>
<u>Type</u> <u>Smart Contract, Chain</u>
<u>Language</u> <u>Solidity, Golang</u>
<u>Approach</u> <u>Semi-automatic and manual verification</u>


The audit target (hereinafter referred to as the Target) of this audit is the code repository <sup>12</sup> of Morph Emerald upgrade of Morph.


The Morph Emerald upgrade of Morph introduces alternative fee transactions (i.e., `AltFeeTx` ),

enabling native multi-token gas payments on the Morph L2 chain. This upgrade allows users

to pay gas fees using registered ERC-20 tokens. Specifically, this feature is enabled through

the introduction of the `L2TokenRegistry` contract and corresponding modifications to the Geth

codebase. The `L2TokenRegistry` contract allows managers to register fee tokens and update

their associated parameters (e.g., token scale and exchange rate). On the Geth side, the project

defines the `AltFeeTx` transaction type with two key parameters (i.e., `FeeTokenID` and `FeeLimit` )

and implements the corresponding handling logic, including transaction creation, fee calcu
lation, and fee transfer. Notably, the token information used during transaction processing is

fetched directly from the `L2TokenRegistry` contract. In addition, the Emerald upgrade synchro
nizes recent Ethereum mainnet updates by introducing new precompiles and opcodes (e.g.,

`CLZ` ).


Note this audit only focuses on the code in the following directories/files. Code prior to

and including the baseline version 0, where applicable, is outside the scope of this audit and

assumes to be reliable and secure.


morph/contracts/contracts/l2/system/L2TokenRegistry.sol

go-ethereum/accounts/abi/bind/base.go

go-ethereum/accounts/external/backend.go

go-ethereum/core/types/receipt.go

go-ethereum/core/state_processor.go

go-ethereum/core/tx_list.go

go-ethereum/core/tx_pool.go

go-ethereum/core/types/alt_fee_tx.go

go-ethereum/core/types/token_fee.go

go-ethereum/core/types/transaction.go

go-ethereum/internal/ethapi/api.go

go-ethereum/internal/ethapi/transaction_args.go

go-ethereum/light/txpool.go

go-ethereum/core/state_transition.go


1 `[https://github.com/morph-l2/morph](https://github.com/morph-l2/morph)`


2 `[https://github.com/morph-l2/go-ethereum](https://github.com/morph-l2/go-ethereum)`


go-ethereum/core/token_gas.go

go-ethereum/rollup/fees/token_info.go

go-ethereum/rollup/fees/rate.go

go-ethereum/rollup/fees/rollup_fee.go

go-ethereum/rollup/fees/token_transfer.go

go-ethereum/signer/core/apitypes/types.go

go-ethereum/core/vm/contracts.go

go-ethereum/crypto/secp256r1/verifier.go

go-ethereum/core/vm/eips.go

go-ethereum/core/vm/jump_table.go

go-ethereum/core/vm/opcodes.go

Other files are not within the scope of the audit. Additionally, all dependencies of the

Target are considered reliable in terms of both functionality and security, and are therefore not

included in the audit scope.


The auditing process is iterative. Specifically, we would audit the commits that fix the

discovered issues. If there are new issues, we will continue this process. The commit SHA

values during the audit are shown in the following table. Our audit report is responsible for the

code in the initial version ( `Version` `1` ), as well as new code (in the following versions) to fix

issues in the audit report. Code prior to and including the baseline version ( `Version` `0` ), where

applicable, is outside the scope of this audit and assumes to be reliable and secure.


<u><mark>Project</mark></u> <u><mark>Version</mark></u> <u><mark>Commit Hash</mark></u>



morph


go-ethereum

##### **1.2 Disclaimer**


```
Version 0 3cb4687bca674b093a715fc7d328327c35b6e99c

Version 1 26233deddf5c77e811a73cfcfb797a2579ed9112

Version 2 e64256ee2109d4fcd3f4c6d90aec8abc46a751e7

Version 0 62fcaab9b7a732eea298f45d97234d718b522b13

Version 1 42d39732bb88bef91c1743efcf10db40ae6b990a

Version 2 64e9dcd01e673d9a25efc91090b81f46150cab3c

```


This audit report does not constitute investment advice or a personal recommendation.

It does not consider, and should not be interpreted as considering or having any bearing on,

the potential economics of a token, token sale or any other product, service or other asset.

Any entity should not rely on this report in any way, including for the purpose of making any

decisions to buy or sell any token, product, service or other asset.


This audit report is not an endorsement of any particular project or team, and the re
port does not guarantee the security of any particular project. This audit does not give any

warranties on discovering all security issues of the Target, i.e., the evaluation result does not

guarantee the nonexistence of any further findings of security issues. As one audit cannot be

considered comprehensive, we always recommend proceeding with independent audits and a

public bug bounty program to ensure the security of the Target.


The scope of this audit is limited to the code mentioned in Section 1.1. Unless explic
itly specified, the security of the language itself (e.g., the solidity language), the underlying


2


compiling toolchain and the computing infrastructure are out of the scope.

##### **1.3 Procedure of Auditing**


We perform the audit according to the following procedure.

   - **Vulnerability** **Detection** We first scan the Target with automatic code analyzers, and

then manually verify (reject or confirm) the issues reported by them.

   - **Semantic Analysis** We study the business logic of the Target and conduct further in
vestigation on the possible vulnerabilities using an automatic fuzzing tool (developed by

our research team). We also manually analyze possible attack scenarios with indepen
dent auditors to cross-check the result.

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

_∗_ Denial of Service (DoS)

_∗_ Untrusted external call and control flow

_∗_ Exception handling

_∗_ Data handling and flow

_∗_ Events operation

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


3


##### **1.4 Security Model**

To evaluate the risk, we follow the standards or suggestions that are widely adopted by
both industry and academy, including OWASP Risk Rating Methodology <sup>3</sup> and Common Weakness Enumeration <sup>4</sup> . The overall _severity_ of the risk is determined by _likelihood_ and _impact_ .

Specifically, likelihood is used to estimate how likely a particular vulnerability can be uncov
ered and exploited by an attacker, while impact is used to measure the consequences of a

successful exploit.


In this report, both likelihood and impact are categorized into two ratings, i.e., _high_ and _low_

respectively, and their combinations are shown in Table 1.1.


**Table 1.1:** Vulnerability Severity Classification


_High_ High Medium


_Low_ Medium Low


_High_ _Low_


**Likelihood**


Accordingly, the severity measured in this report are classified into three categories: **High**,

**Medium**, **Low** . For the sake of completeness, **Undetermined** is also used to cover circum
stances when the risk cannot be well determined.


Furthermore, the status of a discovered item will fall into one of the following five cate
gories:


  - **Undetermined** No response yet.

  - **Acknowledged** The item has been received by the client, but not confirmed yet.

  - **Confirmed** The item has been recognized by the client, but not fixed yet.

  - **Partially Fixed** The item has been confirmed and partially fixed by the client.

  - **Fixed** The item has been confirmed and fixed by the client.


[3https://owasp.org/www-community/OWASP_Risk_Rating_Methodology](https://owasp.org/www-community/OWASP_Risk_Rating_Methodology)


[4https://cwe.mitre.org/](https://cwe.mitre.org/)


4


### **Chapter 2 Findings**

In total, we found **four** potential security issues. Besides, we have **seven** recommendations

and **four** notes.


 - High Risk: 1

 - Medium Risk: 1

 - Low Risk: 2

 - Recommendation: 7

 - Note: 4


<mark>ID</mark> <mark>Severity</mark> <mark>Description</mark> <mark>Category</mark> <mark>Status</mark>


Incorrect access control logic in the mod1 High Security Issue Fixed
ifier <u>`onlyAllowed`</u>


Inconsistent updates of the price ratio and
2 Medium Security Issue Fixed
token scale


Lack of the value assignment for `FeeLimit`
3 Low Security Issue Fixed
in the <u>`CallArgs`</u> construction


The misleading return value of the func4 Low Security Issue Fixed
tion <u>`getTokenInfo()`</u>


5  - Revise the unused function <u>`Filter()`</u> Recommendation Confirmed


6  - Remove redundant code Recommendation Fixed


7  - Add non-zero checks Recommendation Fixed


Revise the improper error in the function
8  - Recommendation Fixed
```
         calculateTokenAmount()

```

9  - Revise typos and improper annotations Recommendation Fixed


Unify the existence checks for the bal10  - Recommendation Fixed
ance slot


Use different custom errors for different
11  - Recommendation Fixed
revert conditions


12  - Ensure the correctness of fee tokens Note  

13  - Potential centralization risks Note  

14  - Openzeppelin upgrade migration risks Note  

Correct handling of the fee tokens in the
15  - Note  contract <u>`L2TxFeeVault`</u>


The details are provided in the following sections.

##### **2.1 Security Issue**


**2.1.1** **Incorrect access control logic in the modifier** **`onlyAllowed`**


**Severity** High


**Status** Fixed in `Version` `2`


**Introduced by** `Version` `1`


**Description** In the contract `L2TokenRegistry`, the functions `updatePriceRatio()`, `batchUpdatePrices()`,

and `updateTokenScale()` are protected by the modifier `onlyAllowed` . However, the design of

the modifier `onlyAllowed` is incorrect, causing these functions to become publicly accessible.

Specifically, when the variable `allowListEnabled` is set to `false`, the check (i.e., `allowListEnabled`

`&&` `!allowList[msg.sender]` `&&` `msg.sender` `!=` `owner()` ) in the modifier `onlyAllowed` becomes

ineffective. As a result, anyone can update the price ratio and token scale. Since the morph

chain node directly uses the token information registered in the contract `L2TokenRegistry` to

calculate the amount of required fee tokens, allowing arbitrary updates to these values may

lead to denial-of-service (DoS) issues or fund loss.


47 **<mark>`modifier`</mark>** <mark>`onlyAllowed()`</mark> <mark>`{`</mark>


48 **<mark>`if`</mark>** <mark>`(allowListEnabled`</mark> <mark>`&&`</mark> <mark>`!allowList[`</mark> **<mark>`msg`</mark>** <mark>`.`</mark> **<mark>`sender`</mark>** <mark>`]`</mark> <mark>`&&`</mark> **<mark>`msg`</mark>** <mark>`.`</mark> **<mark>`sender`</mark>** <mark>`!=`</mark> <mark>`owner())`</mark> <mark>`{`</mark>


49 **<mark>`revert`</mark>** <mark>`CallerNotAllowed();`</mark>


50 <mark>`}`</mark>


51 <mark>`_;`</mark>


52 <mark>`}`</mark>


**Listing 2.1:** morph/contracts/contracts/l2/system/L2TokenRegistry.sol


362 **<mark>`function`</mark>** <mark>`updatePriceRatio(`</mark> **<mark>`uint16`</mark>** <mark>`_tokenID,`</mark> **<mark>`uint256`</mark>** <mark>`_newPrice)`</mark> **<mark>`external`</mark>** <mark>`onlyAllowed`</mark> <mark>`{`</mark>


**Listing 2.2:** morph/contracts/contracts/l2/system/L2TokenRegistry.sol


378 **<mark>`function`</mark>** <mark>`batchUpdatePrices(`</mark> **<mark>`uint16`</mark>** <mark>`[]`</mark> **<mark>`memory`</mark>** <mark>`_tokenIDs,`</mark> **<mark>`uint256`</mark>** <mark>`[]`</mark> **<mark>`memory`</mark>** <mark>`_prices)`</mark> **<mark>`external`</mark>**

```
      onlyAllowed {

```

**Listing 2.3:** morph/contracts/contracts/l2/system/L2TokenRegistry.sol


476 **<mark>`function`</mark>** <mark>`updateTokenScale(`</mark> **<mark>`uint16`</mark>** <mark>`_tokenID,`</mark> **<mark>`uint256`</mark>** <mark>`_newScale)`</mark> **<mark>`external`</mark>** <mark>`onlyAllowed`</mark> <mark>`{`</mark>


**Listing 2.4:** morph/contracts/contracts/l2/system/L2TokenRegistry.sol


**Impact** The incorrect logic in the modifier allows arbitrary updates for the price ratio and

token scale, leading to potential DoS issues or fund loss.


**Suggestion** Revise the modifier `onlyAllowed` accordingly.


**2.1.2** **Inconsistent updates of the price ratio and token scale**


**Severity** Medium


**Status** Fixed in `Version` `2`


**Introduced by** `Version` `1`


**Description** In the morph chain, the calculation of the fee token amount depends on the price

ratio (i.e., `rate` ) and token scale (i.e., `scale` ) configured in the contract `L2TokenRegistry` . More
over, the annotation (at line 425) of the contract `L2TokenRegistry` indicates that the price ratio

is determined based on the token scale. However, in the contract `L2TokenRegistry`, the price

ratio and token scale are updated via different functions (i.e., the functions `updatePriceRatio()`,

`batchUpdatePrices()`, `updateTokenInfo()` or `updateTokenScale()` ). These inconsistent updates


6


may lead to incorrect calculation of the fee token amount in the morph chain. As a result, the

incorrect amount calculation may lead to potential DoS issues or loss of fees. Additionally, the

inconsistent update for the variable `tokenAddress` (via the function `updateTokenInfo()` ) could

lead to the same impact as well.


426 **<mark>`if`</mark>** <mark>`st.msg.FeeTokenID()`</mark> <mark>`!=`</mark> <mark>`0`</mark> <mark>`{`</mark>


427 <mark>`active,`</mark> <mark>`err`</mark> <mark>`:=`</mark> <mark>`fees.IsTokenActive(st.state,`</mark> <mark>`st.msg.FeeTokenID())`</mark>


428 **<mark>`if`</mark>** <mark>`err`</mark> <mark>`!=`</mark> **<mark>`nil`</mark>** <mark>`{`</mark>


429 **<mark>`return`</mark>** <mark>`fmt.Errorf("get`</mark> <mark>`token`</mark> <mark>`status`</mark> <mark>`failed`</mark> <mark>`%v",`</mark> <mark>`err)`</mark>


430 <mark>`}`</mark>


431 **<mark>`if`</mark>** <mark>`!active`</mark> <mark>`{`</mark>


432 **<mark>`return`</mark>** <mark>`fmt.Errorf("token`</mark> <mark>`%v`</mark> <mark>`not`</mark> <mark>`active",`</mark> <mark>`st.msg.FeeTokenID())`</mark>


433 <mark>`}`</mark>


434 <mark>`feeRate,`</mark> <mark>`tokenScale,`</mark> <mark>`err`</mark> <mark>`:=`</mark> <mark>`fees.TokenRate(st.state,`</mark> <mark>`st.msg.FeeTokenID())`</mark>


435 **<mark>`if`</mark>** <mark>`err`</mark> <mark>`!=`</mark> **<mark>`nil`</mark>** <mark>`{`</mark>


436 **<mark>`return`</mark>** <mark>`fmt.Errorf("get`</mark> <mark>`token`</mark> <mark>`rate`</mark> <mark>`failed`</mark> <mark>`%v",`</mark> <mark>`err)`</mark>


437 <mark>`}`</mark>


438 **<mark>`if`</mark>** <mark>`feeRate`</mark> <mark>`==`</mark> **<mark>`nil`</mark>** <mark>`||`</mark> <mark>`tokenScale`</mark> <mark>`==`</mark> **<mark>`nil`</mark>** <mark>`||`</mark> <mark>`feeRate.Sign()`</mark> <mark>`<=`</mark> <mark>`0`</mark> <mark>`||`</mark> <mark>`tokenScale.Sign()`</mark> <mark>`<=`</mark> <mark>`0`</mark> <mark>`{`</mark>


439 **<mark>`return`</mark>** <mark>`fmt.Errorf("token`</mark> <mark>`rate`</mark> <mark>`or`</mark> <mark>`scale`</mark> <mark>`is`</mark> <mark>`nil")`</mark>


440 <mark>`}`</mark>


441 <mark>`st.feeRate`</mark> <mark>`=`</mark> <mark>`feeRate`</mark>


442 <mark>`st.tokenScale`</mark> <mark>`=`</mark> <mark>`tokenScale`</mark>


443 **<mark>`return`</mark>** <mark>`st.buyAltTokenGas()`</mark>


**Listing 2.5:** go-ethereum/core/state_transition.go


13 **<mark>`func`</mark>** <mark>`TokenRate(state`</mark> <mark>`StateDB,`</mark> <mark>`tokenID`</mark> **<mark>`uint16`</mark>** <mark>`)`</mark> <mark>`(*big.Int,`</mark> <mark>`*big.Int,`</mark> **<mark>`error`</mark>** <mark>`)`</mark> <mark>`{`</mark>


14 **<mark>`if`</mark>** <mark>`tokenID`</mark> <mark>`==`</mark> <mark>`0`</mark> <mark>`{`</mark>


15 **<mark>`return`</mark>** **<mark>`nil`</mark>** <mark>`,`</mark> **<mark>`nil`</mark>** <mark>`,`</mark> <mark>`errors.New("token`</mark> <mark>`id`</mark> <mark>`0`</mark> <mark>`not`</mark> <mark>`support")`</mark>


16 <mark>`}`</mark>


17 <mark>`info,`</mark> <mark>`rate,`</mark> <mark>`err`</mark> <mark>`:=`</mark> <mark>`GetTokenInfoFromStorage(state,`</mark> <mark>`TokenRegistryAddress,`</mark> <mark>`tokenID)`</mark>


18 **<mark>`if`</mark>** <mark>`err`</mark> <mark>`!=`</mark> **<mark>`nil`</mark>** <mark>`{`</mark>


19 <mark>`log.Error("Failed`</mark> <mark>`to`</mark> <mark>`get`</mark> <mark>`token`</mark> <mark>`info`</mark> <mark>`from`</mark> <mark>`storage",`</mark> <mark>`"tokenID",`</mark> <mark>`tokenID,`</mark> <mark>`"error",`</mark> <mark>`err)`</mark>


20 **<mark>`return`</mark>** **<mark>`nil`</mark>** <mark>`,`</mark> **<mark>`nil`</mark>** <mark>`,`</mark> <mark>`err`</mark>


21 <mark>`}`</mark>


22


23 <mark>`//`</mark> <mark>`If`</mark> <mark>`token`</mark> <mark>`address`</mark> <mark>`is`</mark> <mark>`zero,`</mark> <mark>`this`</mark> <mark>`is`</mark> <mark>`not`</mark> <mark>`a`</mark> <mark>`valid`</mark> <mark>`token`</mark>


24 **<mark>`if`</mark>** <mark>`info.TokenAddress`</mark> <mark>`==`</mark> <mark>`(common.Address{})`</mark> <mark>`{`</mark>


25 <mark>`log.Error("Invalid`</mark> <mark>`token`</mark> <mark>`address",`</mark> <mark>`"tokenID",`</mark> <mark>`tokenID)`</mark>


26 **<mark>`return`</mark>** **<mark>`nil`</mark>** <mark>`,`</mark> **<mark>`nil`</mark>** <mark>`,`</mark> <mark>`err`</mark>


27 <mark>`}`</mark>


28


29 <mark>`//`</mark> <mark>`If`</mark> <mark>`price`</mark> <mark>`is`</mark> <mark>`nil`</mark> <mark>`or`</mark> <mark>`zero,`</mark> <mark>`this`</mark> <mark>`token`</mark> <mark>`doesn’t`</mark> <mark>`have`</mark> <mark>`a`</mark> <mark>`valid`</mark> <mark>`price`</mark>


30 **<mark>`if`</mark>** <mark>`rate`</mark> <mark>`==`</mark> **<mark>`nil`</mark>** <mark>`||`</mark> <mark>`rate.Sign()`</mark> <mark>`==`</mark> <mark>`0`</mark> <mark>`{`</mark>


31 <mark>`log.Error("Invalid`</mark> <mark>`token`</mark> <mark>`price",`</mark> <mark>`"tokenID",`</mark> <mark>`tokenID,`</mark> <mark>`"tokenAddr",`</mark> <mark>`info.TokenAddress.Hex())`</mark>


32 **<mark>`return`</mark>** **<mark>`nil`</mark>** <mark>`,`</mark> **<mark>`nil`</mark>** <mark>`,`</mark> <mark>`err`</mark>


33 <mark>`}`</mark>


34


35 <mark>`//`</mark> <mark>`Get`</mark> <mark>`scale`</mark> <mark>`from`</mark> <mark>`token`</mark> <mark>`info`</mark>


36 <mark>`scale,`</mark> <mark>`err`</mark> <mark>`:=`</mark> <mark>`GetTokenScaleByIDWithState(state,`</mark> <mark>`tokenID)`</mark>


**Listing 2.6:** go-ethereum/rollup/fees/rate.go


7


255 **<mark>`function`</mark>** <mark>`updateTokenInfo(`</mark>


256 **<mark>`uint16`</mark>** <mark>`_tokenID,`</mark>


257 **<mark>`address`</mark>** <mark>`_tokenAddress,`</mark>


258 **<mark>`bytes32`</mark>** <mark>`_balanceSlot,`</mark>


259 **<mark>`bool`</mark>** <mark>`_needBalanceSlot,`</mark>


260 **<mark>`bool`</mark>** <mark>`_isActive,`</mark>


261 **<mark>`uint256`</mark>** <mark>`_scale`</mark>


262 <mark>`)`</mark> **<mark>`external`</mark>** <mark>`onlyOwner`</mark> <mark>`nonReentrant`</mark> <mark>`{`</mark>


263 <mark>`//`</mark> <mark>`Check`</mark> <mark>`if`</mark> <mark>`token`</mark> <mark>`exists`</mark>


264 **<mark>`if`</mark>** <mark>`(tokenRegistry[_tokenID].tokenAddress`</mark> <mark>`==`</mark> **<mark>`address`</mark>** <mark>`(0))`</mark> **<mark>`revert`</mark>** <mark>`TokenNotFound();`</mark>


265


266 <mark>`//`</mark> <mark>`Check`</mark> <mark>`new`</mark> <mark>`information`</mark>


267 **<mark>`if`</mark>** <mark>`(_tokenAddress`</mark> <mark>`==`</mark> **<mark>`address`</mark>** <mark>`(0))`</mark> **<mark>`revert`</mark>** <mark>`InvalidTokenAddress();`</mark>


268


269 <mark>`//`</mark> <mark>`Prevent`</mark> <mark>`address`</mark> <mark>`being`</mark> <mark>`shared`</mark> <mark>`across`</mark> <mark>`different`</mark> <mark>`tokenIDs`</mark>


270 **<mark>`uint16`</mark>** <mark>`existing`</mark> <mark>`=`</mark> <mark>`tokenRegistration[_tokenAddress];`</mark>


271 **<mark>`if`</mark>** <mark>`(existing`</mark> <mark>`!=`</mark> <mark>`0`</mark> <mark>`&&`</mark> <mark>`existing`</mark> <mark>`!=`</mark> <mark>`_tokenID)`</mark> **<mark>`revert`</mark>** <mark>`TokenAlreadyRegistered();`</mark>


272


273 <mark>`//`</mark> <mark>`Get`</mark> <mark>`decimals`</mark> <mark>`from`</mark> <mark>`contract`</mark>


274 **<mark>`uint8`</mark>** <mark>`decimals`</mark> <mark>`=`</mark> <mark>`18;`</mark> <mark>`//`</mark> <mark>`Default`</mark> <mark>`value`</mark>


275 **<mark>`try`</mark>** <mark>`IERC20Infos(_tokenAddress).decimals()`</mark> **<mark>`returns`</mark>** <mark>`(`</mark> **<mark>`uint8`</mark>** <mark>`v)`</mark> <mark>`{`</mark>


276 <mark>`decimals`</mark> <mark>`=`</mark> <mark>`v;`</mark>


277 <mark>`}`</mark> **<mark>`catch`</mark>** <mark>`{`</mark>


278 <mark>`//`</mark> <mark>`If`</mark> <mark>`call`</mark> <mark>`fails,`</mark> <mark>`use`</mark> <mark>`default`</mark> <mark>`value`</mark> <mark>`18`</mark>


279 <mark>`}`</mark>


280 <mark>`//`</mark> <mark>`Update`</mark> <mark>`registration`</mark> <mark>`information`</mark>


281 <mark>`//`</mark> <mark>`Note:`</mark> <mark>`balanceSlot`</mark> <mark>`is`</mark> <mark>`stored`</mark> <mark>`as`</mark> <mark>`actualSlot`</mark> <mark>`+`</mark> <mark>`1`</mark> <mark>`if`</mark> <mark>`needBalanceSlot`</mark> <mark>`is`</mark> <mark>`true,`</mark> <mark>`otherwise`</mark> <mark>`0`</mark>


282 **<mark>`address`</mark>** <mark>`oldAddress`</mark> <mark>`=`</mark> <mark>`tokenRegistry[_tokenID].tokenAddress;`</mark>


283 <mark>`tokenRegistry[_tokenID]`</mark> <mark>`=`</mark> <mark>`TokenInfo({`</mark>


284 <mark>`tokenAddress:`</mark> <mark>`_tokenAddress,`</mark>


285 <mark>`balanceSlot:`</mark> <mark>`_toStoredBalanceSlot(_balanceSlot,`</mark> <mark>`_needBalanceSlot),`</mark>


286 <mark>`isActive:`</mark> <mark>`_isActive,`</mark>


287 <mark>`decimals:`</mark> <mark>`decimals,`</mark>


288 <mark>`scale:`</mark> <mark>`_scale`</mark>


289 <mark>`});`</mark>


**Listing 2.7:** morph/contracts/contracts/l2/system/L2TokenRegistry.sol


362 **<mark>`function`</mark>** <mark>`updatePriceRatio(`</mark> **<mark>`uint16`</mark>** <mark>`_tokenID,`</mark> **<mark>`uint256`</mark>** <mark>`_newPrice)`</mark> **<mark>`external`</mark>** <mark>`onlyAllowed`</mark> <mark>`{`</mark>


363 <mark>`//`</mark> <mark>`Check`</mark> <mark>`if`</mark> <mark>`token`</mark> <mark>`exists`</mark>


364 **<mark>`if`</mark>** <mark>`(tokenRegistry[_tokenID].tokenAddress`</mark> <mark>`==`</mark> **<mark>`address`</mark>** <mark>`(0))`</mark> **<mark>`revert`</mark>** <mark>`TokenNotFound();`</mark>


365


366 **<mark>`if`</mark>** <mark>`(_newPrice`</mark> <mark>`==`</mark> <mark>`0)`</mark> **<mark>`revert`</mark>** <mark>`InvalidPrice();`</mark>


367


368 <mark>`priceRatio[_tokenID]`</mark> <mark>`=`</mark> <mark>`_newPrice;`</mark>


369


370 **<mark>`emit`</mark>** <mark>`PriceRatioUpdated(_tokenID,`</mark> <mark>`_newPrice);`</mark>


371 <mark>`}`</mark>


**Listing 2.8:** morph/contracts/contracts/l2/system/L2TokenRegistry.sol


378 **<mark>`function`</mark>** <mark>`batchUpdatePrices(`</mark> **<mark>`uint16`</mark>** <mark>`[]`</mark> **<mark>`memory`</mark>** <mark>`_tokenIDs,`</mark> **<mark>`uint256`</mark>** <mark>`[]`</mark> **<mark>`memory`</mark>** <mark>`_prices)`</mark> **<mark>`external`</mark>**

```
      onlyAllowed {

```

8


379 **<mark>`if`</mark>** <mark>`(_tokenIDs.`</mark> **<mark>`length`</mark>** <mark>`!=`</mark> <mark>`_prices.`</mark> **<mark>`length`</mark>** <mark>`)`</mark> **<mark>`revert`</mark>** <mark>`InvalidArrayLength();`</mark>


380


381 **<mark>`for`</mark>** <mark>`(`</mark> **<mark>`uint256`</mark>** <mark>`i`</mark> <mark>`=`</mark> <mark>`0;`</mark> <mark>`i`</mark> <mark>`<`</mark> <mark>`_tokenIDs.`</mark> **<mark>`length`</mark>** <mark>`;`</mark> <mark>`i++)`</mark> <mark>`{`</mark>


382 **<mark>`if`</mark>** <mark>`(tokenRegistry[_tokenIDs[i]].tokenAddress`</mark> <mark>`==`</mark> **<mark>`address`</mark>** <mark>`(0))`</mark> **<mark>`continue`</mark>** <mark>`;`</mark>


383 **<mark>`if`</mark>** <mark>`(_prices[i]`</mark> <mark>`==`</mark> <mark>`0)`</mark> **<mark>`continue`</mark>** <mark>`;`</mark>


384


385 <mark>`priceRatio[_tokenIDs[i]]`</mark> <mark>`=`</mark> <mark>`_prices[i];`</mark>


386 **<mark>`emit`</mark>** <mark>`PriceRatioUpdated(_tokenIDs[i],`</mark> <mark>`_prices[i]);`</mark>


387 <mark>`}`</mark>


388 <mark>`}`</mark>


**Listing 2.9:** morph/contracts/contracts/l2/system/L2TokenRegistry.sol


**Impact** The inconsistent update for the token information may lead to potential DoS issues or

loss of fees.


**Suggestion** Revise the code accordingly.


**2.1.3** **Lack of the value assignment for** **`FeeLimit`** **in the** **`CallArgs`** **construction**


**Severity** Low


**Status** Fixed in `Version` `2`


**Introduced by** `Version` `1`


**Description** In the file `transaction_args.go`, the function `setDefaults()` fills in default values

for unspecified fields of users’ transactions. As part of this process, the function `setDefaults()`

invokes the function `DoEstimateGas()` to estimate the potential gas usage (i.e., `args.Gas` ). How
ever, the user-specified fee limit (i.e., `args.FeeLimit` ) is not propagated into the struct `callArgs`,

which is passed to the function `DoEstimateGas()` for the estimation. The gas estimation logic

is performed based on the user’s balance of the alternative fee token, which may exceed the

user-specified fee limit (i.e., `args.FeeLimit` ). As a result, the gas estimation may fail to reject

invalid transactions, as the user-specified fee limit is not taken into account.


161 <mark>`//`</mark> <mark>`Estimate`</mark> <mark>`the`</mark> <mark>`gas`</mark> <mark>`usage`</mark> <mark>`if`</mark> <mark>`necessary.`</mark>


162 **<mark>`if`</mark>** <mark>`args.Gas`</mark> <mark>`==`</mark> **<mark>`nil`</mark>** <mark>`{`</mark>


163 <mark>`//`</mark> <mark>`These`</mark> <mark>`fields`</mark> <mark>`are`</mark> <mark>`immutable`</mark> <mark>`during`</mark> <mark>`the`</mark> <mark>`estimation,`</mark> <mark>`safe`</mark> <mark>`to`</mark>


164 <mark>`//`</mark> <mark>`pass`</mark> <mark>`the`</mark> <mark>`pointer`</mark> <mark>`directly.`</mark>


165 <mark>`data`</mark> <mark>`:=`</mark> <mark>`args.data()`</mark>


166 <mark>`callArgs`</mark> <mark>`:=`</mark> <mark>`TransactionArgs{`</mark>


167 <mark>`From:`</mark> <mark>`args.From,`</mark>


168 <mark>`To:`</mark> <mark>`args.To,`</mark>


169 <mark>`GasPrice:`</mark> <mark>`args.GasPrice,`</mark>


170 <mark>`MaxFeePerGas:`</mark> <mark>`args.MaxFeePerGas,`</mark>


171 <mark>`MaxPriorityFeePerGas:`</mark> <mark>`args.MaxPriorityFeePerGas,`</mark>


172 <mark>`FeeTokenID:`</mark> <mark>`args.FeeTokenID,`</mark>


173 <mark>`Value:`</mark> <mark>`args.Value,`</mark>


174 <mark>`Data:`</mark> <mark>`(*hexutil.Bytes)(&data),`</mark>


175 <mark>`AccessList:`</mark> <mark>`args.AccessList,`</mark>


176 <mark>`}`</mark>


177 <mark>`pendingBlockNr`</mark> <mark>`:=`</mark> <mark>`rpc.BlockNumberOrHashWithNumber(rpc.PendingBlockNumber)`</mark>


178 <mark>`estimated,`</mark> <mark>`err`</mark> <mark>`:=`</mark> <mark>`DoEstimateGas(ctx,`</mark> <mark>`b,`</mark> <mark>`callArgs,`</mark> <mark>`pendingBlockNr,`</mark> <mark>`b.RPCGasCap())`</mark>


179 **<mark>`if`</mark>** <mark>`err`</mark> <mark>`!=`</mark> **<mark>`nil`</mark>** <mark>`{`</mark>


9


180 **<mark>`return`</mark>** <mark>`err`</mark>


181 <mark>`}`</mark>


182 <mark>`args.Gas`</mark> <mark>`=`</mark> <mark>`&estimated`</mark>


183 <mark>`log.Trace("Estimate`</mark> <mark>`gas`</mark> <mark>`usage`</mark> <mark>`automatically",`</mark> <mark>`"gas",`</mark> <mark>`args.Gas)`</mark>


184 <mark>`}`</mark>


**Listing 2.10:** go-ethereum/internal/ethapi/transaction_args.go


1204 <mark>`limit`</mark> <mark>`:=`</mark> <mark>`altBalance`</mark>


1205 **<mark>`if`</mark>** <mark>`args.FeeLimit`</mark> <mark>`!=`</mark> **<mark>`nil`</mark>** <mark>`&&`</mark> <mark>`args.FeeLimit.ToInt().Sign()`</mark> <mark>`>`</mark> <mark>`0`</mark> <mark>`{`</mark>


1206 <mark>`limit`</mark> <mark>`=`</mark> <mark>`math.BigMin(altBalance,`</mark> <mark>`args.FeeLimit.ToInt())`</mark>


1207 <mark>`}`</mark>


**Listing 2.11:** go-ethereum/internal/ethapi/api.go


**Impact** The gas estimation may fail to reject invalid transactions, as the user-specified fee

limit is not taken into account.


**Suggestion** Pass the user-specified fee limit into the gas estimation process.


**2.1.4** **The misleading return value of the function** **`getTokenInfo()`**


**Severity** Low


**Status** Fixed in `Version` `2`


**Introduced by** `Version` `1`


**Description** In the contract `L2TokenRegistry`, managers can register fee tokens with an ex
isting balance slot by providing the token’s valid balance slot (i.e., `_balanceSlot` ) along with the

boolean flag `_needBalanceSlot` . When `_needBalanceSlot` is set to `true`, the provided balance

slot is further processed (i.e., incremented by one via the function `_toStoredBalanceSlot()` )

to distinguish it from a non-exiting balance slot (i.e., `bytes(0)` ). For example, if the valid

balance slot is `bytes(0)`, it is converted and stored as `bytes(1)` . However, in the function

`getTokenInfo()`, the stored balance slot of a registered token is converted to its actual value

and returned to users. As a result, when the stored balance slot is `bytes(1)`, users cannot dis
tinguish it from the absence of a balance slot, making the existence of the balance slot unclear.


234 <mark>`tokenRegistry[_tokenID]`</mark> <mark>`=`</mark> <mark>`TokenInfo({`</mark>


235 <mark>`tokenAddress:`</mark> <mark>`_tokenAddress,`</mark>


236 <mark>`balanceSlot:`</mark> <mark>`_toStoredBalanceSlot(_balanceSlot,`</mark> <mark>`_needBalanceSlot),`</mark>


237 <mark>`isActive:`</mark> **<mark>`false`</mark>** <mark>`,`</mark>


238 <mark>`decimals:`</mark> <mark>`decimals,`</mark>


239 <mark>`scale:`</mark> <mark>`_scale`</mark>


240 <mark>`});`</mark>


**Listing 2.12:** morph/contracts/contracts/l2/system/L2TokenRegistry.sol


175 **<mark>`function`</mark>** <mark>`_toStoredBalanceSlot(`</mark> **<mark>`bytes32`</mark>** <mark>`_actualSlot,`</mark> **<mark>`bool`</mark>** <mark>`_needBalanceSlot)`</mark> **<mark>`internal`</mark>** **<mark>`pure`</mark>**

```
      returns ( bytes32 ) {

```

176 **<mark>`if`</mark>** <mark>`(!_needBalanceSlot)`</mark> <mark>`{`</mark>


177 **<mark>`return`</mark>** **<mark>`bytes32`</mark>** <mark>`(0);`</mark> <mark>`//`</mark> <mark>`Don’t`</mark> <mark>`store`</mark> <mark>`balanceSlot`</mark>


178 <mark>`}`</mark>


179 **<mark>`if`</mark>** <mark>`(_actualSlot`</mark> <mark>`==`</mark> **<mark>`bytes32`</mark>** <mark>`(type(`</mark> **<mark>`uint256`</mark>** <mark>`).max))`</mark> **<mark>`revert`</mark>** <mark>`InvalidBalanceSlot();`</mark>


10


180 **<mark>`bytes32`</mark>** <mark>`storedSlot;`</mark>


181 **<mark>`assembly`</mark>** <mark>`{`</mark>


182 <mark>`storedSlot`</mark> <mark>`:=`</mark> <mark>`add(_actualSlot,`</mark> <mark>`1)`</mark>


183 <mark>`}`</mark>


184 **<mark>`return`</mark>** <mark>`storedSlot;`</mark>


185 <mark>`}`</mark>


**Listing 2.13:** morph/contracts/contracts/l2/system/L2TokenRegistry.sol


445 **<mark>`function`</mark>** <mark>`getTokenInfo(`</mark> **<mark>`uint16`</mark>** <mark>`_tokenID)`</mark> **<mark>`external`</mark>** **<mark>`view`</mark>** **<mark>`returns`</mark>** <mark>`(TokenInfo`</mark> **<mark>`memory`</mark>** <mark>`)`</mark> <mark>`{`</mark>


446 **<mark>`if`</mark>** <mark>`(tokenRegistry[_tokenID].tokenAddress`</mark> <mark>`==`</mark> **<mark>`address`</mark>** <mark>`(0))`</mark> **<mark>`revert`</mark>** <mark>`TokenNotFound();`</mark>


447


448 <mark>`TokenInfo`</mark> **<mark>`memory`</mark>** <mark>`info`</mark> <mark>`=`</mark> <mark>`tokenRegistry[_tokenID];`</mark>


449 <mark>`//`</mark> <mark>`Convert`</mark> <mark>`stored`</mark> <mark>`balanceSlot`</mark> <mark>`to`</mark> <mark>`actual`</mark> <mark>`value`</mark>


450 <mark>`info.balanceSlot`</mark> <mark>`=`</mark> <mark>`_toActualBalanceSlot(info.balanceSlot);`</mark>


451


452 **<mark>`return`</mark>** <mark>`info;`</mark>


453 <mark>`}`</mark>


**Listing 2.14:** morph/contracts/contracts/l2/system/L2TokenRegistry.sol


192 **<mark>`function`</mark>** <mark>`_toActualBalanceSlot(`</mark> **<mark>`bytes32`</mark>** <mark>`_storedSlot)`</mark> **<mark>`internal`</mark>** **<mark>`pure`</mark>** **<mark>`returns`</mark>** <mark>`(`</mark> **<mark>`bytes32`</mark>** <mark>`)`</mark> <mark>`{`</mark>


193 **<mark>`if`</mark>** <mark>`(_storedSlot`</mark> <mark>`==`</mark> **<mark>`bytes32`</mark>** <mark>`(0))`</mark> <mark>`{`</mark>


194 **<mark>`return`</mark>** **<mark>`bytes32`</mark>** <mark>`(0);`</mark> <mark>`//`</mark> <mark>`No`</mark> <mark>`balanceSlot`</mark> <mark>`stored`</mark>


195 <mark>`}`</mark>


196 **<mark>`bytes32`</mark>** <mark>`actualSlot;`</mark>


197 **<mark>`assembly`</mark>** <mark>`{`</mark>


198 <mark>`actualSlot`</mark> <mark>`:=`</mark> <mark>`sub(_storedSlot,`</mark> <mark>`1)`</mark>


199 <mark>`}`</mark>


200 **<mark>`return`</mark>** <mark>`actualSlot;`</mark>


201 <mark>`}`</mark>


**Listing 2.15:** morph/contracts/contracts/l2/system/L2TokenRegistry.sol


**Impact** Users cannot distinguish the existence of the balance slot via the function `getTokenInfo()` .


**Suggestion** Revise the code accordingly.

##### **2.2 Recommendation**


**2.2.1** **Revise the unused function** **`Filter()`**


**Status** Confirmed


**Introduced by** `Version` `1`


**Description** In the file `tx_list.go`, the function `Filter()` is intended to remove all transactions

from the transaction list (i.e., `l` ) based on the provided thresholds (i.e., the inputs `costLimit`,

`gasLimit`, and `altCostLimit` ). Specifically, at line 388, the function `Filter()` directly returns

`nil,` `nil`, indicating that no transactions should be removed if both thresholds `costLimit` and

`gasLimit` are satisfied.


However, the check at line 388 is insufficient because it does not validate the thresh
old `altCostLimit` before returning `nil,` `nil` . As a result, transactions exceeding the threshold


11


`altCostLimit` will not be removed, potentially allowing invalid transactions to remain in the

transaction list.


Additionally, the current codebase does not appear to use the function `Filter()` . It is

recommended to revise the unused function `Filter()` .


**Suggestion** Revise the unused function `Filter()` accordingly.


**2.2.2** **Remove redundant code**


**Status** Fixed in `Version` `2`


**Introduced by** `Version` `1`


**Description** There are several redundant codes in the project. It is recommended to remove

them for better code readability. Specifically, the following code should be removed or revised.


1. Redundant value assignments.


35 **<mark>`bool`</mark>** **<mark>`public`</mark>** <mark>`allowListEnabled`</mark> <mark>`=`</mark> **<mark>`true`</mark>** <mark>`;`</mark>


**Listing 2.16:** morph/contracts/contracts/l2/system/L2TokenRegistry.sol


2. Redundant error definitions.


68 <mark>`error`</mark> <mark>`InvalidPercent();`</mark>


**Listing 2.17:** morph/contracts/contracts/l2/system/IL2TokenRegistry.sol


72 <mark>`error`</mark> <mark>`AlreadyInitialized();`</mark>


**Listing 2.18:** morph/contracts/contracts/l2/system/IL2TokenRegistry.sol


3. Redundant query logic for the variable `scale` .

In the function `TokenRate()` of the file `rate.go`, the invocation of the `GetTokenInfoFromStorage()`

function is redundant because the token scale (i.e., `scale` ) can be obtained directly from the

variable `info` .


13 **<mark>`func`</mark>** <mark>`TokenRate(state`</mark> <mark>`StateDB,`</mark> <mark>`tokenID`</mark> **<mark>`uint16`</mark>** <mark>`)`</mark> <mark>`(*big.Int,`</mark> <mark>`*big.Int,`</mark> **<mark>`error`</mark>** <mark>`)`</mark> <mark>`{`</mark>


14 **<mark>`if`</mark>** <mark>`tokenID`</mark> <mark>`==`</mark> <mark>`0`</mark> <mark>`{`</mark>


15 **<mark>`return`</mark>** **<mark>`nil`</mark>** <mark>`,`</mark> **<mark>`nil`</mark>** <mark>`,`</mark> <mark>`errors.New("token`</mark> <mark>`id`</mark> <mark>`0`</mark> <mark>`not`</mark> <mark>`support")`</mark>


16 <mark>`}`</mark>


17 <mark>`info,`</mark> <mark>`rate,`</mark> <mark>`err`</mark> <mark>`:=`</mark> <mark>`GetTokenInfoFromStorage(state,`</mark> <mark>`TokenRegistryAddress,`</mark> <mark>`tokenID)`</mark>


18 **<mark>`if`</mark>** <mark>`err`</mark> <mark>`!=`</mark> **<mark>`nil`</mark>** <mark>`{`</mark>


19 <mark>`log.Error("Failed`</mark> <mark>`to`</mark> <mark>`get`</mark> <mark>`token`</mark> <mark>`info`</mark> <mark>`from`</mark> <mark>`storage",`</mark> <mark>`"tokenID",`</mark> <mark>`tokenID,`</mark> <mark>`"error",`</mark> <mark>`err)`</mark>


20 **<mark>`return`</mark>** **<mark>`nil`</mark>** <mark>`,`</mark> **<mark>`nil`</mark>** <mark>`,`</mark> <mark>`err`</mark>


21 <mark>`}`</mark>


22


23 <mark>`//`</mark> <mark>`If`</mark> <mark>`token`</mark> <mark>`address`</mark> <mark>`is`</mark> <mark>`zero,`</mark> <mark>`this`</mark> <mark>`is`</mark> <mark>`not`</mark> <mark>`a`</mark> <mark>`valid`</mark> <mark>`token`</mark>


24 **<mark>`if`</mark>** <mark>`info.TokenAddress`</mark> <mark>`==`</mark> <mark>`(common.Address{})`</mark> <mark>`{`</mark>


25 <mark>`log.Error("Invalid`</mark> <mark>`token`</mark> <mark>`address",`</mark> <mark>`"tokenID",`</mark> <mark>`tokenID)`</mark>


26 **<mark>`return`</mark>** **<mark>`nil`</mark>** <mark>`,`</mark> **<mark>`nil`</mark>** <mark>`,`</mark> <mark>`err`</mark>


27 <mark>`}`</mark>


28


29 <mark>`//`</mark> <mark>`If`</mark> <mark>`price`</mark> <mark>`is`</mark> <mark>`nil`</mark> <mark>`or`</mark> <mark>`zero,`</mark> <mark>`this`</mark> <mark>`token`</mark> <mark>`doesn’t`</mark> <mark>`have`</mark> <mark>`a`</mark> <mark>`valid`</mark> <mark>`price`</mark>


30 **<mark>`if`</mark>** <mark>`rate`</mark> <mark>`==`</mark> **<mark>`nil`</mark>** <mark>`||`</mark> <mark>`rate.Sign()`</mark> <mark>`==`</mark> <mark>`0`</mark> <mark>`{`</mark>


31 <mark>`log.Error("Invalid`</mark> <mark>`token`</mark> <mark>`price",`</mark> <mark>`"tokenID",`</mark> <mark>`tokenID,`</mark> <mark>`"tokenAddr",`</mark> <mark>`info.TokenAddress.Hex())`</mark>


12


32 **<mark>`return`</mark>** **<mark>`nil`</mark>** <mark>`,`</mark> **<mark>`nil`</mark>** <mark>`,`</mark> <mark>`err`</mark>


33 <mark>`}`</mark>


34


35 <mark>`//`</mark> <mark>`Get`</mark> <mark>`scale`</mark> <mark>`from`</mark> <mark>`token`</mark> <mark>`info`</mark>


36 <mark>`scale,`</mark> <mark>`err`</mark> <mark>`:=`</mark> <mark>`GetTokenScaleByIDWithState(state,`</mark> <mark>`tokenID)`</mark>


37 **<mark>`if`</mark>** <mark>`err`</mark> <mark>`!=`</mark> **<mark>`nil`</mark>** <mark>`{`</mark>


38 <mark>`log.Error("Failed`</mark> <mark>`to`</mark> <mark>`get`</mark> <mark>`token`</mark> <mark>`scale",`</mark> <mark>`"tokenID",`</mark> <mark>`tokenID,`</mark> <mark>`"error",`</mark> <mark>`err)`</mark>


39 **<mark>`return`</mark>** **<mark>`nil`</mark>** <mark>`,`</mark> **<mark>`nil`</mark>** <mark>`,`</mark> <mark>`err`</mark>


40 <mark>`}`</mark>


41 **<mark>`if`</mark>** <mark>`scale`</mark> <mark>`==`</mark> **<mark>`nil`</mark>** <mark>`||`</mark> <mark>`scale.Sign()`</mark> <mark>`==`</mark> <mark>`0`</mark> <mark>`{`</mark>


42 <mark>`log.Error("Invalid`</mark> <mark>`token`</mark> <mark>`scale",`</mark> <mark>`"tokenID",`</mark> <mark>`tokenID,`</mark> <mark>`"tokenAddr",`</mark> <mark>`info.TokenAddress.Hex())`</mark>


43 <mark>`}`</mark>


**Listing 2.19:** go-ethereum/rollup/fees/rate.go


4. Redundant `nil` checks for the variable `costcap` .

In the file `token_fee.go`, the function `Eth()` will not return `nil` . Therefore, the check `l.costcap.Eth()`

`==` `nil` in the file `tx_list.go` is redundant.


359 **<mark>`if`</mark>** <mark>`ethCost`</mark> <mark>`!=`</mark> **<mark>`nil`</mark>** <mark>`&&`</mark> <mark>`ethCost.Sign()`</mark> <mark>`>`</mark> <mark>`0`</mark> <mark>`{`</mark>


360 **<mark>`if`</mark>** <mark>`l.costcap.Eth()`</mark> <mark>`==`</mark> **<mark>`nil`</mark>** <mark>`||`</mark> <mark>`l.costcap.Eth().Cmp(ethCost)`</mark> <mark>`<`</mark> <mark>`0`</mark> <mark>`{`</mark>


361 <mark>`l.costcap.SetEthAmount(ethCost)`</mark>


362 <mark>`}`</mark>


363 <mark>`}`</mark>


**Listing 2.20:** go-ethereum/core/tx_list.go


19 **<mark>`func`</mark>** <mark>`(dca`</mark> <mark>`*SuperAccount)`</mark> <mark>`Eth()`</mark> <mark>`*big.Int`</mark> <mark>`{`</mark>


20 **<mark>`if`</mark>** <mark>`dca.ethAmount`</mark> <mark>`==`</mark> **<mark>`nil`</mark>** <mark>`{`</mark>


21 **<mark>`return`</mark>** **<mark>`new`</mark>** <mark>`(big.Int)`</mark>


22 <mark>`}`</mark>


23 **<mark>`return`</mark>** <mark>`dca.ethAmount`</mark>


24 <mark>`}`</mark>


**Listing 2.21:** go-ethereum/core/types/token_fee.go


5. Redundant inputs in the function `GetTokenInfoFromStorage()` .

In the file `token_info.go`, the function `GetTokenInfoFromStorage()` has an input `contractAddr`,

but this parameter is always assigned the global variable `TokenRegistryAddress` in all invoca
tions. Therefore, the input `contractAddr` of the function `GetTokenInfoFromStorage()` is redun
dant.


171 **<mark>`func`</mark>** <mark>`GetTokenInfoFromStorage(state`</mark> <mark>`StateDB,`</mark> <mark>`contractAddr`</mark> <mark>`common.Address,`</mark> <mark>`tokenID`</mark> **<mark>`uint16`</mark>** <mark>`)`</mark> <mark>`(*`</mark>

```
    TokenInfo, *big.Int, error ) {

```

172 <mark>`//`</mark> <mark>`Get`</mark> <mark>`token`</mark> <mark>`info`</mark> <mark>`from`</mark> <mark>`TokenInfo`</mark> <mark>`struct`</mark>


173 <mark>`info,`</mark> <mark>`err`</mark> <mark>`:=`</mark> <mark>`GetTokenInfo(state,`</mark> <mark>`tokenID)`</mark>


174 **<mark>`if`</mark>** <mark>`err`</mark> <mark>`!=`</mark> **<mark>`nil`</mark>** <mark>`{`</mark>


175 **<mark>`return`</mark>** **<mark>`nil`</mark>** <mark>`,`</mark> **<mark>`nil`</mark>** <mark>`,`</mark> <mark>`fmt.Errorf("failed`</mark> <mark>`to`</mark> <mark>`get`</mark> <mark>`token`</mark> <mark>`info:`</mark> <mark>`%v",`</mark> <mark>`err)`</mark>


176 <mark>`}`</mark>


177


178 <mark>`//`</mark> <mark>`Get`</mark> <mark>`token`</mark> <mark>`price`</mark> <mark>`from`</mark> <mark>`priceRatio`</mark> <mark>`mapping`</mark>


179 <mark>`price,`</mark> <mark>`err`</mark> <mark>`:=`</mark> <mark>`GetTokenPriceByIDWithState(state,`</mark> <mark>`contractAddr,`</mark> <mark>`tokenID)`</mark>


180 **<mark>`if`</mark>** <mark>`err`</mark> <mark>`!=`</mark> **<mark>`nil`</mark>** <mark>`{`</mark>


181 **<mark>`return`</mark>** **<mark>`nil`</mark>** <mark>`,`</mark> **<mark>`nil`</mark>** <mark>`,`</mark> <mark>`fmt.Errorf("failed`</mark> <mark>`to`</mark> <mark>`get`</mark> <mark>`token`</mark> <mark>`price:`</mark> <mark>`%v",`</mark> <mark>`err)`</mark>


13


182 <mark>`}`</mark>


183


184 **<mark>`return`</mark>** <mark>`info,`</mark> <mark>`price,`</mark> **<mark>`nil`</mark>**


185 <mark>`}`</mark>


**Listing 2.22:** go-ethereum/rollup/fees/token_info.go


**Suggestion** Remove or revise the redundant code.


**2.2.3** **Add non-zero checks**


**Status** Fixed in `Version` `2`


**Introduced by** `Version` `1`


**Description** In the contract `L2TokenRegistry`, it is recommended to add non-zero checks for

the input `_scale` in the function `updateTokenInfo()` to prevent potential mis-operations.


255 **<mark>`function`</mark>** <mark>`updateTokenInfo(`</mark>


256 **<mark>`uint16`</mark>** <mark>`_tokenID,`</mark>


257 **<mark>`address`</mark>** <mark>`_tokenAddress,`</mark>


258 **<mark>`bytes32`</mark>** <mark>`_balanceSlot,`</mark>


259 **<mark>`bool`</mark>** <mark>`_needBalanceSlot,`</mark>


260 **<mark>`bool`</mark>** <mark>`_isActive,`</mark>


261 **<mark>`uint256`</mark>** <mark>`_scale`</mark>


262 <mark>`)`</mark> **<mark>`external`</mark>** <mark>`onlyOwner`</mark> <mark>`nonReentrant`</mark> <mark>`{`</mark>


263 <mark>`//`</mark> <mark>`Check`</mark> <mark>`if`</mark> <mark>`token`</mark> <mark>`exists`</mark>


264 **<mark>`if`</mark>** <mark>`(tokenRegistry[_tokenID].tokenAddress`</mark> <mark>`==`</mark> **<mark>`address`</mark>** <mark>`(0))`</mark> **<mark>`revert`</mark>** <mark>`TokenNotFound();`</mark>


265


266 <mark>`//`</mark> <mark>`Check`</mark> <mark>`new`</mark> <mark>`information`</mark>


267 **<mark>`if`</mark>** <mark>`(_tokenAddress`</mark> <mark>`==`</mark> **<mark>`address`</mark>** <mark>`(0))`</mark> **<mark>`revert`</mark>** <mark>`InvalidTokenAddress();`</mark>


268


269 <mark>`//`</mark> <mark>`Prevent`</mark> <mark>`address`</mark> <mark>`being`</mark> <mark>`shared`</mark> <mark>`across`</mark> <mark>`different`</mark> <mark>`tokenIDs`</mark>


270 **<mark>`uint16`</mark>** <mark>`existing`</mark> <mark>`=`</mark> <mark>`tokenRegistration[_tokenAddress];`</mark>


271 **<mark>`if`</mark>** <mark>`(existing`</mark> <mark>`!=`</mark> <mark>`0`</mark> <mark>`&&`</mark> <mark>`existing`</mark> <mark>`!=`</mark> <mark>`_tokenID)`</mark> **<mark>`revert`</mark>** <mark>`TokenAlreadyRegistered();`</mark>


272


273 <mark>`//`</mark> <mark>`Get`</mark> <mark>`decimals`</mark> <mark>`from`</mark> <mark>`contract`</mark>


274 **<mark>`uint8`</mark>** <mark>`decimals`</mark> <mark>`=`</mark> <mark>`18;`</mark> <mark>`//`</mark> <mark>`Default`</mark> <mark>`value`</mark>


275 **<mark>`try`</mark>** <mark>`IERC20Infos(_tokenAddress).decimals()`</mark> **<mark>`returns`</mark>** <mark>`(`</mark> **<mark>`uint8`</mark>** <mark>`v)`</mark> <mark>`{`</mark>


276 <mark>`decimals`</mark> <mark>`=`</mark> <mark>`v;`</mark>


277 <mark>`}`</mark> **<mark>`catch`</mark>** <mark>`{`</mark>


278 <mark>`//`</mark> <mark>`If`</mark> <mark>`call`</mark> <mark>`fails,`</mark> <mark>`use`</mark> <mark>`default`</mark> <mark>`value`</mark> <mark>`18`</mark>


279 <mark>`}`</mark>


280 <mark>`//`</mark> <mark>`Update`</mark> <mark>`registration`</mark> <mark>`information`</mark>


281 <mark>`//`</mark> <mark>`Note:`</mark> <mark>`balanceSlot`</mark> <mark>`is`</mark> <mark>`stored`</mark> <mark>`as`</mark> <mark>`actualSlot`</mark> <mark>`+`</mark> <mark>`1`</mark> <mark>`if`</mark> <mark>`needBalanceSlot`</mark> <mark>`is`</mark> <mark>`true,`</mark> <mark>`otherwise`</mark> <mark>`0`</mark>


282 **<mark>`address`</mark>** <mark>`oldAddress`</mark> <mark>`=`</mark> <mark>`tokenRegistry[_tokenID].tokenAddress;`</mark>


283 <mark>`tokenRegistry[_tokenID]`</mark> <mark>`=`</mark> <mark>`TokenInfo({`</mark>


284 <mark>`tokenAddress:`</mark> <mark>`_tokenAddress,`</mark>


285 <mark>`balanceSlot:`</mark> <mark>`_toStoredBalanceSlot(_balanceSlot,`</mark> <mark>`_needBalanceSlot),`</mark>


286 <mark>`isActive:`</mark> <mark>`_isActive,`</mark>


287 <mark>`decimals:`</mark> <mark>`decimals,`</mark>


288 <mark>`scale:`</mark> <mark>`_scale`</mark>


289 <mark>`});`</mark>


**Listing 2.23:** morph/contracts/contracts/l2/system/L2TokenRegistry.sol


14


**Suggestion** Add non-zero checks for the input `_scale` in the function `updateTokenInfo()` .


**2.2.4** **Revise the improper error in the function** **`calculateTokenAmount()`**


**Status** Fixed in `Version` `2`


**Introduced by** `Version` `1`


**Description** In the contract `L2TokenRegistry`, the function `calculateTokenAmount()` reverts

with the error `InvalidPrice()` when the variable `tokenAmount` is zero (i.e., at line 435). This

error is misleading since the zero token amount can be produced due to the zero `info.scale`

or `_ethAmount` . It is recommended to replace the error `InvalidPrice()` with a proper error.


417 **<mark>`function`</mark>** <mark>`calculateTokenAmount(`</mark> **<mark>`uint16`</mark>** <mark>`_tokenID,`</mark> **<mark>`uint256`</mark>** <mark>`_ethAmount)`</mark> **<mark>`external`</mark>** **<mark>`view`</mark>** **<mark>`returns`</mark>** <mark>`(`</mark>

```
      uint256 tokenAmount) {

```

418 <mark>`//`</mark> <mark>`Validate:`</mark> <mark>`token`</mark> <mark>`must`</mark> <mark>`be`</mark> <mark>`registered`</mark>


419 **<mark>`if`</mark>** <mark>`(tokenRegistry[_tokenID].tokenAddress`</mark> <mark>`==`</mark> **<mark>`address`</mark>** <mark>`(0))`</mark> **<mark>`revert`</mark>** <mark>`TokenNotFound();`</mark>


420


421 <mark>`//`</mark> <mark>`Get`</mark> <mark>`token`</mark> <mark>`information`</mark>


422 <mark>`TokenInfo`</mark> **<mark>`memory`</mark>** <mark>`info`</mark> <mark>`=`</mark> <mark>`tokenRegistry[_tokenID];`</mark>


423


424 <mark>`//`</mark> <mark>`Get`</mark> <mark>`priceRatio`</mark> <mark>`which`</mark> <mark>`follows:`</mark>


425 <mark>`//`</mark> <mark>`ratio`</mark> <mark>`=`</mark> <mark>`tokenScale`</mark> <mark>`*`</mark> <mark>`(tokenPrice`</mark> <mark>`/`</mark> <mark>`ethPrice)`</mark> <mark>`*`</mark> <mark>`10^(ethDecimals`</mark> <mark>`-`</mark> <mark>`tokenDecimals)`</mark>


426 **<mark>`uint256`</mark>** <mark>`ratio`</mark> <mark>`=`</mark> <mark>`priceRatio[_tokenID];`</mark>


427 **<mark>`if`</mark>** <mark>`(ratio`</mark> <mark>`==`</mark> <mark>`0)`</mark> **<mark>`revert`</mark>** <mark>`InvalidPrice();`</mark>


428


429 <mark>`//`</mark> <mark>`Calculate`</mark> <mark>`token`</mark> <mark>`amount`</mark> <mark>`with`</mark> <mark>`ceiling`</mark> <mark>`division:`</mark>


430 <mark>`//`</mark> <mark>`tokenAmount`</mark> <mark>`=`</mark> <mark>`ceil((ethAmount`</mark> <mark>`*`</mark> <mark>`tokenScale)`</mark> <mark>`/`</mark> <mark>`ratio)`</mark>


431 <mark>`//`</mark> <mark>`Using`</mark> <mark>`formula:`</mark> <mark>`ceil(a/b)`</mark> <mark>`=`</mark> <mark>`(a`</mark> <mark>`+`</mark> <mark>`b`</mark> <mark>`-`</mark> <mark>`1)`</mark> <mark>`/`</mark> <mark>`b`</mark>


432 **<mark>`uint256`</mark>** <mark>`numerator`</mark> <mark>`=`</mark> <mark>`_ethAmount`</mark> <mark>`*`</mark> **<mark>`uint256`</mark>** <mark>`(info.scale);`</mark>


433 <mark>`tokenAmount`</mark> <mark>`=`</mark> <mark>`(numerator`</mark> <mark>`+`</mark> <mark>`ratio`</mark> <mark>`-`</mark> <mark>`1)`</mark> <mark>`/`</mark> <mark>`ratio;`</mark>


434


435 **<mark>`if`</mark>** <mark>`(tokenAmount`</mark> <mark>`==`</mark> <mark>`0)`</mark> **<mark>`revert`</mark>** <mark>`InvalidPrice();`</mark>


**Listing 2.24:** morph/contracts/contracts/l2/system/L2TokenRegistry.sol


**Suggestion** Replace the error `InvalidPrice()` with a proper error in the `calculateTokenAmount()`

function.


**2.2.5** **Revise typos and improper annotations**


**Status** Fixed in `Version` `2`


**Introduced by** `Version` `1`


**Description** There are several typos and improper annotations in the codebase. It is recom
mended to revise them for better readability.


1. In the file `rate.go`, it is recommended to revise the name of the variable `tokenSacle` in

the functions `EthToAlt()` and `AltToETH()` .


48 **<mark>`func`</mark>** <mark>`EthToAlt(state`</mark> <mark>`StateDB,`</mark> <mark>`tokenID`</mark> **<mark>`uint16`</mark>** <mark>`,`</mark> <mark>`amount`</mark> <mark>`*big.Int)`</mark> <mark>`(*big.Int,`</mark> **<mark>`error`</mark>** <mark>`)`</mark> <mark>`{`</mark>


49 <mark>`rate,`</mark> <mark>`tokenSacle,`</mark> <mark>`err`</mark> <mark>`:=`</mark> <mark>`TokenRate(state,`</mark> <mark>`tokenID)`</mark>


50 **<mark>`if`</mark>** <mark>`err`</mark> <mark>`!=`</mark> **<mark>`nil`</mark>** <mark>`{`</mark>


51 **<mark>`return`</mark>** **<mark>`nil`</mark>** <mark>`,`</mark> <mark>`err`</mark>


15


52 <mark>`}`</mark>


53 **<mark>`return`</mark>** <mark>`types.EthToAlt(amount,`</mark> <mark>`rate,`</mark> <mark>`tokenSacle),`</mark> **<mark>`nil`</mark>**


54 <mark>`}`</mark>


55


56 **<mark>`func`</mark>** <mark>`AltToETH(state`</mark> <mark>`StateDB,`</mark> <mark>`tokenID`</mark> **<mark>`uint16`</mark>** <mark>`,`</mark> <mark>`amount`</mark> <mark>`*big.Int)`</mark> <mark>`(*big.Int,`</mark> **<mark>`error`</mark>** <mark>`)`</mark> <mark>`{`</mark>


57 <mark>`rate,`</mark> <mark>`tokenSacle,`</mark> <mark>`err`</mark> <mark>`:=`</mark> <mark>`TokenRate(state,`</mark> <mark>`tokenID)`</mark>


58 **<mark>`if`</mark>** <mark>`err`</mark> <mark>`!=`</mark> **<mark>`nil`</mark>** <mark>`{`</mark>


59 **<mark>`return`</mark>** **<mark>`nil`</mark>** <mark>`,`</mark> <mark>`err`</mark>


60 <mark>`}`</mark>


61 **<mark>`return`</mark>** <mark>`types.AltToEth(amount,`</mark> <mark>`rate,`</mark> <mark>`tokenSacle),`</mark> **<mark>`nil`</mark>**


62 <mark>`}`</mark>


**Listing 2.25:** go-ethereum/rollup/fees/rate.go


2. In the file `token_transfer.go`, the annotation at line 62 incorrectly explains the purpose

of the following code.


62 <mark>`//`</mark> <mark>`Calculate`</mark> <mark>`the`</mark> <mark>`storage`</mark> <mark>`slot`</mark> <mark>`for`</mark> <mark>`the`</mark> <mark>`user’s`</mark> <mark>`balance`</mark>


63 <mark>`state.SetState(tokenAddress,`</mark> <mark>`storageSlot,`</mark> <mark>`amountHash)`</mark>


**Listing 2.26:** go-ethereum/rollup/fees/token_transfer.go


3. In the file `receipt.go`, the annotation at line 127 incorrectly indicates the introduction

date of the feature.


126 <mark>`//`</mark> <mark>`v7StoredReceiptRLP`</mark> <mark>`is`</mark> <mark>`the`</mark> <mark>`storage`</mark> <mark>`encoding`</mark> <mark>`of`</mark> <mark>`a`</mark> <mark>`receipt`</mark> <mark>`used`</mark> <mark>`in`</mark> <mark>`database`</mark> <mark>`version`</mark> <mark>`7.`</mark>


127 <mark>`//`</mark> <mark>`This`</mark> <mark>`version`</mark> <mark>`was`</mark> <mark>`introduced`</mark> <mark>`when`</mark> <mark>`AltFee`</mark> <mark>`feature`</mark> <mark>`was`</mark> <mark>`added`</mark> <mark>`(2024-11).`</mark>


**Listing 2.27:** go-ethereum/core/types/receipt.go


4. In the contract `L2TokenRegistry`, the annotation for the function `calculateTokenAmount()`

is inconsistent with the implemented logic. Specifically, the formula described in the annotation

(i.e., at lines 406-409) is incorrect. It is recommended to revise the formula annotation to

accurately reflect the implementation.


402 <mark>`/**`</mark>


403 <mark>`*`</mark> <mark>`@notice`</mark> <mark>`Calculate`</mark> <mark>`the`</mark> <mark>`corresponding`</mark> <mark>`token`</mark> <mark>`amount`</mark> <mark>`for`</mark> <mark>`a`</mark> <mark>`given`</mark> <mark>`ETH`</mark> <mark>`amount`</mark>


404 <mark>`*`</mark> <mark>`@dev`</mark> <mark>`Calculation`</mark> <mark>`formula:`</mark>


405 <mark>`*`</mark> <mark>`-`</mark> <mark>`ratio`</mark> <mark>`=`</mark> <mark>`tokenScale`</mark> <mark>`*`</mark> <mark>`(tokenPrice`</mark> <mark>`/`</mark> <mark>`ethPrice)`</mark> <mark>`*`</mark> <mark>`10^(ethDecimals`</mark> <mark>`-`</mark> <mark>`tokenDecimals)`</mark>


406 <mark>`*`</mark> <mark>`-`</mark> <mark>`tokenAmount`</mark> <mark>`=`</mark> <mark>`(ethAmount`</mark> <mark>`*`</mark> <mark>`10^tokenDecimals)`</mark> <mark>`/`</mark> <mark>`ratio`</mark>


407 <mark>`*`</mark> <mark>`-`</mark> <mark>`Substituting`</mark> <mark>`ratio:`</mark> <mark>`tokenAmount`</mark> <mark>`=`</mark> <mark>`(ethAmount`</mark> <mark>`*`</mark> <mark>`10^tokenDecimals)`</mark> <mark>`/`</mark> <mark>`(tokenScale`</mark> <mark>`*`</mark> <mark>`(`</mark>

```
       tokenPrice / ethPrice) * 10^(18 - tokenDecimals))

```

408 <mark>`*`</mark> <mark>`-`</mark> <mark>`Simplified:`</mark> <mark>`tokenAmount`</mark> <mark>`=`</mark> <mark>`(ethAmount`</mark> <mark>`*`</mark> <mark>`10^tokenDecimals`</mark> <mark>`*`</mark> <mark>`10^tokenDecimals)`</mark> <mark>`/`</mark> <mark>`(`</mark>

```
       tokenScale * tokenPrice * 10^18 / ethPrice)

```

409 <mark>`*`</mark> <mark>`-`</mark> <mark>`Final:`</mark> <mark>`tokenAmount`</mark> <mark>`=`</mark> <mark>`(ethAmount`</mark> <mark>`*`</mark> <mark>`ethPrice`</mark> <mark>`*`</mark> <mark>`10^tokenDecimals)`</mark> <mark>`/`</mark> <mark>`(tokenScale`</mark> <mark>`*`</mark>

```
       tokenPrice * 10^18)

```

410 <mark>`*`</mark> <mark>`-`</mark> <mark>`Note:`</mark> <mark>`Uses`</mark> <mark>`ceiling`</mark> <mark>`division`</mark> <mark>`to`</mark> <mark>`ensure`</mark> <mark>`users`</mark> <mark>`receive`</mark> <mark>`fair`</mark> <mark>`token`</mark> <mark>`amounts`</mark>


411 <mark>`*`</mark> <mark>`@param`</mark> <mark>`_tokenID`</mark> <mark>`Token`</mark> <mark>`ID`</mark> <mark>`of`</mark> <mark>`the`</mark> <mark>`ERC20`</mark> <mark>`token`</mark>


412 <mark>`*`</mark> <mark>`@param`</mark> <mark>`_ethAmount`</mark> <mark>`ETH`</mark> <mark>`amount`</mark> <mark>`(unit:`</mark> <mark>`wei)`</mark>


413 <mark>`*`</mark> <mark>`@return`</mark> <mark>`tokenAmount`</mark> <mark>`Corresponding`</mark> <mark>`token`</mark> <mark>`amount`</mark> <mark>`(unit:`</mark> <mark>`token’s`</mark> <mark>`smallest`</mark> <mark>`unit)`</mark>


414 <mark>`*`</mark> <mark>`-`</mark> <mark>`ratio`</mark> <mark>`follows:`</mark> <mark>`ratio`</mark> <mark>`=`</mark> <mark>`tokenScale`</mark> <mark>`*`</mark> <mark>`(tokenPrice`</mark> <mark>`/`</mark> <mark>`ethPrice)`</mark> <mark>`*`</mark> <mark>`10^(ethDecimals`</mark> <mark>`-`</mark>

```
       tokenDecimals)

```

415 <mark>`*`</mark> <mark>`-`</mark> <mark>`Will`</mark> <mark>`revert`</mark> <mark>`if`</mark> <mark>`token`</mark> <mark>`is`</mark> <mark>`not`</mark> <mark>`registered`</mark> <mark>`or`</mark> <mark>`priceRatio`</mark> <mark>`is`</mark> <mark>`not`</mark> <mark>`set`</mark>


416 <mark>`*/`</mark>


16


417 **<mark>`function`</mark>** <mark>`calculateTokenAmount(`</mark> **<mark>`uint16`</mark>** <mark>`_tokenID,`</mark> **<mark>`uint256`</mark>** <mark>`_ethAmount)`</mark> **<mark>`external`</mark>** **<mark>`view`</mark>** **<mark>`returns`</mark>** <mark>`(`</mark>

```
      uint256 tokenAmount) {

```

418 <mark>`//`</mark> <mark>`Validate:`</mark> <mark>`token`</mark> <mark>`must`</mark> <mark>`be`</mark> <mark>`registered`</mark>


419 **<mark>`if`</mark>** <mark>`(tokenRegistry[_tokenID].tokenAddress`</mark> <mark>`==`</mark> **<mark>`address`</mark>** <mark>`(0))`</mark> **<mark>`revert`</mark>** <mark>`TokenNotFound();`</mark>


420


421 <mark>`//`</mark> <mark>`Get`</mark> <mark>`token`</mark> <mark>`information`</mark>


422 <mark>`TokenInfo`</mark> **<mark>`memory`</mark>** <mark>`info`</mark> <mark>`=`</mark> <mark>`tokenRegistry[_tokenID];`</mark>


423


424 <mark>`//`</mark> <mark>`Get`</mark> <mark>`priceRatio`</mark> <mark>`which`</mark> <mark>`follows:`</mark>


425 <mark>`//`</mark> <mark>`ratio`</mark> <mark>`=`</mark> <mark>`tokenScale`</mark> <mark>`*`</mark> <mark>`(tokenPrice`</mark> <mark>`/`</mark> <mark>`ethPrice)`</mark> <mark>`*`</mark> <mark>`10^(ethDecimals`</mark> <mark>`-`</mark> <mark>`tokenDecimals)`</mark>


426 **<mark>`uint256`</mark>** <mark>`ratio`</mark> <mark>`=`</mark> <mark>`priceRatio[_tokenID];`</mark>


427 **<mark>`if`</mark>** <mark>`(ratio`</mark> <mark>`==`</mark> <mark>`0)`</mark> **<mark>`revert`</mark>** <mark>`InvalidPrice();`</mark>


428


429 <mark>`//`</mark> <mark>`Calculate`</mark> <mark>`token`</mark> <mark>`amount`</mark> <mark>`with`</mark> <mark>`ceiling`</mark> <mark>`division:`</mark>


430 <mark>`//`</mark> <mark>`tokenAmount`</mark> <mark>`=`</mark> <mark>`ceil((ethAmount`</mark> <mark>`*`</mark> <mark>`tokenScale)`</mark> <mark>`/`</mark> <mark>`ratio)`</mark>


431 <mark>`//`</mark> <mark>`Using`</mark> <mark>`formula:`</mark> <mark>`ceil(a/b)`</mark> <mark>`=`</mark> <mark>`(a`</mark> <mark>`+`</mark> <mark>`b`</mark> <mark>`-`</mark> <mark>`1)`</mark> <mark>`/`</mark> <mark>`b`</mark>


432 **<mark>`uint256`</mark>** <mark>`numerator`</mark> <mark>`=`</mark> <mark>`_ethAmount`</mark> <mark>`*`</mark> **<mark>`uint256`</mark>** <mark>`(info.scale);`</mark>


433 <mark>`tokenAmount`</mark> <mark>`=`</mark> <mark>`(numerator`</mark> <mark>`+`</mark> <mark>`ratio`</mark> <mark>`-`</mark> <mark>`1)`</mark> <mark>`/`</mark> <mark>`ratio;`</mark>


434


435 **<mark>`if`</mark>** <mark>`(tokenAmount`</mark> <mark>`==`</mark> <mark>`0)`</mark> **<mark>`revert`</mark>** <mark>`InvalidPrice();`</mark>


436


437 **<mark>`return`</mark>** <mark>`tokenAmount;`</mark>


438 <mark>`}`</mark>


**Listing 2.28:** morph/contracts/contracts/l2/system/L2TokenRegistry.sol


**Suggestion** Revise the above typos and annotation inconsistencies accordingly.


**2.2.6** **Unify the existence checks for the balance slot**


**Status** Fixed in `Version` `2`


**Introduced by** `Version` `1`


**Description** In the file `token_gas.go`, the `GetAltTokenBalanceHybrid()` and `GetAltTokenBalance()`

functions perform an existence check for the balance slot in different ways. It is recommended

to use the defined function `HasSlot()` in both functions for better readability.


25 **<mark>`func`</mark>** <mark>`(st`</mark> <mark>`*StateTransition)`</mark> <mark>`GetAltTokenBalanceHybrid(tokenID`</mark> **<mark>`uint16`</mark>** <mark>`,`</mark> <mark>`user`</mark> <mark>`common.Address)`</mark> <mark>`(*fees.`</mark>

```
    TokenInfo, *big.Int, error ) {

```

26 <mark>`info,`</mark> <mark>`err`</mark> <mark>`:=`</mark> <mark>`fees.GetTokenInfo(st.state,`</mark> <mark>`tokenID)`</mark>


27 **<mark>`if`</mark>** <mark>`err`</mark> <mark>`!=`</mark> **<mark>`nil`</mark>** <mark>`{`</mark>


28 **<mark>`return`</mark>** **<mark>`nil`</mark>** <mark>`,`</mark> **<mark>`nil`</mark>** <mark>`,`</mark> <mark>`err`</mark>


29 <mark>`}`</mark>


30 <mark>`balance`</mark> <mark>`:=`</mark> **<mark>`new`</mark>** <mark>`(big.Int)`</mark>


31 **<mark>`if`</mark>** <mark>`!info.HasSlot`</mark> <mark>`{`</mark>


**Listing 2.29:** go-ethereum/core/token_gas.go


60 **<mark>`func`</mark>** <mark>`GetAltTokenBalance(evm`</mark> <mark>`*vm.EVM,`</mark> <mark>`tokenID`</mark> **<mark>`uint16`</mark>** <mark>`,`</mark> <mark>`user`</mark> <mark>`common.Address)`</mark> <mark>`(*big.Int,`</mark> **<mark>`error`</mark>** <mark>`)`</mark> <mark>`{`</mark>


61 <mark>`info,`</mark> <mark>`err`</mark> <mark>`:=`</mark> <mark>`fees.GetTokenInfo(evm.StateDB,`</mark> <mark>`tokenID)`</mark>


62 **<mark>`if`</mark>** <mark>`err`</mark> <mark>`!=`</mark> **<mark>`nil`</mark>** <mark>`{`</mark>


63 **<mark>`return`</mark>** **<mark>`nil`</mark>** <mark>`,`</mark> <mark>`fmt.Errorf("failed`</mark> <mark>`to`</mark> <mark>`get`</mark> <mark>`token`</mark> <mark>`address`</mark> <mark>`for`</mark> <mark>`token`</mark> <mark>`ID`</mark> <mark>`%d:`</mark> <mark>`%v",`</mark> <mark>`tokenID,`</mark> <mark>`err)`</mark>


64 <mark>`}`</mark>


17


65 <mark>`balance`</mark> <mark>`:=`</mark> **<mark>`new`</mark>** <mark>`(big.Int)`</mark>


66 **<mark>`if`</mark>** <mark>`!bytes.Equal(info.BalanceSlot.Bytes(),`</mark> <mark>`common.Hash{}.Bytes())`</mark> <mark>`{`</mark>


**Listing 2.30:** go-ethereum/core/token_gas.go


**Suggestion** Unify the existence checks for the balance slot.


**2.2.7** **Use different custom errors for different revert conditions**


**Status** Fixed in `Version` `2`


**Introduced by** `Version` `1`


**Description** In the contract `L2TokenRegistry`, the checks performed at lines 218 and 219 are

semantically different but revert with the same error. It is recommended to implement separate

custom errors for better readability and easier off-chain tracking.


206 **<mark>`function`</mark>** <mark>`_registerSingleToken(`</mark>


207 **<mark>`uint16`</mark>** <mark>`_tokenID,`</mark>


208 **<mark>`address`</mark>** <mark>`_tokenAddress,`</mark>


209 **<mark>`bytes32`</mark>** <mark>`_balanceSlot,`</mark>


210 **<mark>`bool`</mark>** <mark>`_needBalanceSlot,`</mark>


211 **<mark>`uint256`</mark>** <mark>`_scale`</mark>


212 <mark>`)`</mark> **<mark>`internal`</mark>** <mark>`{`</mark>


213 <mark>`//`</mark> <mark>`Check`</mark> <mark>`token`</mark> <mark>`address`</mark>


214 **<mark>`if`</mark>** <mark>`(_tokenAddress`</mark> <mark>`==`</mark> **<mark>`address`</mark>** <mark>`(0))`</mark> **<mark>`revert`</mark>** <mark>`InvalidTokenAddress();`</mark>


215


216 <mark>`//`</mark> <mark>`Forbid`</mark> <mark>`zero`</mark> <mark>`ID`</mark> <mark>`and`</mark> <mark>`enforce`</mark> <mark>`uniqueness`</mark> <mark>`for`</mark> <mark>`both`</mark> <mark>`ID`</mark> <mark>`and`</mark> <mark>`address`</mark>


217 **<mark>`if`</mark>** <mark>`(_tokenID`</mark> <mark>`==`</mark> <mark>`0)`</mark> **<mark>`revert`</mark>** <mark>`InvalidTokenID();`</mark>


218 **<mark>`if`</mark>** <mark>`(tokenRegistry[_tokenID].tokenAddress`</mark> <mark>`!=`</mark> **<mark>`address`</mark>** <mark>`(0))`</mark> **<mark>`revert`</mark>** <mark>`TokenAlreadyRegistered();`</mark>


219 **<mark>`if`</mark>** <mark>`(tokenRegistration[_tokenAddress]`</mark> <mark>`!=`</mark> <mark>`0)`</mark> **<mark>`revert`</mark>** <mark>`TokenAlreadyRegistered();`</mark>


**Listing 2.31:** morph/contracts/contracts/l2/system/L2TokenRegistry.sol


**Suggestion** Define and use distinct custom errors for these two revert conditions in the func
tion `_registerSingleToken()` .

##### **2.3 Note**


**2.3.1** **Ensure the correctness of fee tokens**


**Introduced by** `Version` `1`


**Description** The contract `L2TokenRegistry` allows the role `owner` to register fee tokens and

update their corresponding information (e.g., price ratio, scale, address, and decimal). The

registered tokens’ information stored in the contract `L2TokenRegistry` is directly fetched by the

Morph chain to support the alternative fee token feature. Therefore, the project must ensure

fee tokens are carefully selected (e.g., fee-on-transfer tokens should not be registered as the

fee token) and the corresponding information is correctly configured to avoid potential DoS

issues or loss of fees.


18


**2.3.2** **Potential centralization risks**


**Introduced by** `Version` `1`


**Description** In the contract `L2TokenRegistry`, several privileged roles (e.g., the role `owner` )

can conduct sensitive operations, which introduces potential centralization risks. For example,

the role `owner` can register fee tokens via the function `registerToken()` . If the private keys of

the privileged accounts are lost or maliciously exploited, it could pose a significant risk to the

protocol.


114 **<mark>`function`</mark>** <mark>`registerTokens(`</mark>


115 **<mark>`uint16`</mark>** <mark>`[]`</mark> **<mark>`memory`</mark>** <mark>`_tokenIDs,`</mark>


116 **<mark>`address`</mark>** <mark>`[]`</mark> **<mark>`memory`</mark>** <mark>`_tokenAddresses,`</mark>


117 **<mark>`bytes32`</mark>** <mark>`[]`</mark> **<mark>`memory`</mark>** <mark>`_balanceSlots,`</mark>


118 **<mark>`bool`</mark>** <mark>`[]`</mark> **<mark>`memory`</mark>** <mark>`_needBalanceSlots,`</mark>


119 **<mark>`uint256`</mark>** <mark>`[]`</mark> **<mark>`memory`</mark>** <mark>`_scales`</mark>


120 <mark>`)`</mark> **<mark>`external`</mark>** <mark>`onlyOwner`</mark> <mark>`nonReentrant`</mark> <mark>`{`</mark>


**Listing 2.32:** morph/contracts/contracts/l2/system/L2TokenRegistry.sol


**2.3.3** **Openzeppelin upgrade migration risks**


**Introduced by** `Version` `1`


**Description** The contract `L2TokenRegistry` currently uses OpenZeppelin’s contracts `Initializable`

and `ReentrancyGuardUpgradeable` (v4.9.3) to implement upgradeable contracts. It is important

to note that the contracts `Initializable` and `ReentrancyGuardUpgradeable` with versions v5.0.0

and later introduce ERC-7201 namespaced storage to mitigate storage collision risks. This

change relocates initialization and reentrancy-guard state variables from direct storage slots

(e.g., `_initialized` and `status` ) to namespaced storage structures (e.g., `$._initialized` and

`$._status` ). When upgrading to the newer versions of `Initializable` and `ReentrancyGuardUpgradeable`,

the project must ensure that the initialization and reentrancy-guard states are migrated cor
rectly. Otherwise, an improper migration may introduce severe security vulnerabilities (e.g.,

contract being reinitialized or the reentrancy guard being circumvented).


**2.3.4** **Correct handling of the fee tokens in the contract** **`L2TxFeeVault`**


**Introduced by** `Version` `1`


**Description** To support the alternative fee token feature, the project must ensure that the

contract `L2TxFeeVault`, which is responsible to receive and hold the fee tokens, contains the

logic to correctly handle the fee tokens.


19


