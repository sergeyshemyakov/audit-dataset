**Prepared for**
**Haichen Shen**
Scroll Foundation


**January 23, 2024**

# Lido Gateway Smart Contract Security Assessment



**Prepared by**
**Aaron Esau**
**Vlad Toie**
Zellic


**Lido Gateway** Smart Contract Security Assessment January 23, 2024

## Contents About Zellic 4


**1.** **Executive Summary** **4**


1.1. Goals of the Assessment 5


1.2. Non-goals and Limitations 5


1.3. Results 5


**2.** **Introduction** **6**


2.1. About Lido Gateway 7


2.2. Methodology 7


2.3. Scope 9


2.4. Project Overview 9


2.5. Project Timeline 10


**3.** **Detailed Findings** **10**


3.1. L2 token is not necessarily pegged to L1 token 11


**4.** **Discussion** **11**


4.1. Contract BridgeExecutorBase has ability to call onlyThis functions 12


**5.** **Threat Model** **12**


5.1. Module: L1LidoGateway.sol 13


5.2. Module: L2LidoGateway.sol 15


5.3. Module: L2WstETHToken.sol 17


Zellic © 2024 _←_ **Back to Contents** Page 2 of 25


**Lido Gateway** Smart Contract Security Assessment January 23, 2024


5.4. Module: LidoGatewayManager.sol 19


5.5. Module: ScrollBridgeExecutor.sol 23


**6.** **Assessment Results** **24**


6.1. Disclaimer 25


Zellic © 2024 _←_ **Back to Contents** Page 3 of 25


**Lido Gateway** Smart Contract Security Assessment January 23, 2024

## About Zellic Zellic is a vulnerability research firm with deep expertise in blockchain security. We specialize

in EVM, Move (Aptos and Sui), and Solana, as well as Cairo, NEAR, and Cosmos. We review L1s
and L2s, cross-chain protocols, wallets and applied cryptography, zero-knowledge circuits, web
applications, and more.


Prior to Zellic, we founded the <u>[#1 CTF (competitive hacking) team ↗worldwide in 2020, 2021, and](https://perfect.blue)</u>
2023. Our engineers bring a rich set of skills and backgrounds, including cryptography, web security, mobile security, low-level exploitation, and finance. Our background in traditional information security and competitive hacking has enabled us to consistently discover hidden vulnerabilities and develop novel security research, earning us the reputation as the go-to security firm
for teams whose rate of innovation outpaces the existing security landscape.


For more on Zellic’s ongoing security research initiatives, check out our website <u>[zellic.io ↗and](https://zellic.io)</u>
follow <u>[@zellic_io](https://twitter.com/zellic_io)</u> ↗on Twitter. If you are interested in partnering with Zellic, contact us at
<u>[hello@zellic.io ↗.](mailto:hello@zellic.io)</u>


Zellic © 2024 _←_ **Back to Contents** Page 4 of 25


**Lido Gateway** Smart Contract Security Assessment January 23, 2024

## 1. Executive Summary Zellic conducted a security assessment for Scroll Foundation from January 16th to January 19th,

2024. During this engagement, Zellic reviewed Lido Gateway’s code for security vulnerabilities,
design issues, and general weaknesses in security posture.


1.1. Goals of the Assessment


In a security assessment, goals are framed in terms of questions that we wish to answer. These
questions are agreed upon through close communication between Zellic and the client. In this
assessment, we sought to answer the following questions:


_•_ Is it possible for funds to be permanently locked in the bridge?

_•_ Can attackers drain wstETH locked in the L1 bridge contract?

_•_ Can attackers improperly mint extra wstETH on L2?

_•_ Does the L2 token’s supply always match the amount of locked wstETH on L1?


1.2. Non-goals and Limitations


We did not assess the following areas that were outside the scope of this engagement:


_•_ Front-end components

_•_ Infrastructure relating to the project

_•_ Key custody

_•_ Core Scroll bridge contracts, validators, and so on

_•_ Deployment configuration of in-scope contracts


Due to the time-boxed nature of security assessments in general, there are limitations in the
coverage an assessment can provide.


1.3. Results


DuringourassessmentonthescopedLidoGatewaycontracts, wediscoveredonefinding, which
was informational in nature.


Additionally, Zellic recorded its notes and observations from the assessment for Scroll
Foundation’s benefit in the Discussion section (4. ↗).


Zellic © 2024 _←_ **Back to Contents** Page 5 of 25


**Lido Gateway** Smart Contract Security Assessment January 23, 2024


**Breakdown of Finding Impacts**


**Impact Level** **Count**


           - Critical 0


           - High 0


           - Medium 0


           - Low 0


           - Informational 1


Zellic © 2024 _←_ **Back to Contents** Page 6 of 25


**Lido Gateway** Smart Contract Security Assessment January 23, 2024

## 2. Introduction 2.1. About Lido Gateway


Scroll is a zkEVM-based ZK rollup on Ethereum that enables native compatibility for existing
Ethereum applications and tools. Lido Gateway is used to bridge wstETH between Mainnet and
Scroll and relay governance proposals.


2.2. Methodology


During a security assessment, Zellic works through standard phases of security auditing,
including both automated testing and manual review. These processes can vary significantly
per engagement, but the majority of the time is spent on a thorough manual review of the entire
scope.


Alongside a variety of tools and analyzers used on an as-needed basis, Zellic focuses primarily
on the following classes of security and reliability issues:


**Basic** **coding** **mistakes.** Many critical vulnerabilities in the past have been caused by
simple, surface-level mistakes that could have easily been caught ahead of time by code
review. Depending on the engagement, we may also employ sophisticated analyzers
such as model checkers, theorem provers, fuzzers, and so on as necessary. We also
perform a cursory review of the code to familiarize ourselves with the contracts.


**Business** **logic** **errors.** Business logic is the heart of any smart contract application.
We examine the specifications and designs for inconsistencies, flaws, and weaknesses
that create opportunities for abuse. For example, these include problems like unrealistic
tokenomics or dangerous arbitrage opportunities. To the best of our abilities, time
permitting, we also review the contract logic to ensure that the code implements the
expected functionality as specified in the platform’s design documents.


**Integration** **risks.** Several well-known exploits have not been the result of any bug
within the contract itself; rather, they are an unintended consequence of the contract’s
interaction with the broader DeFi ecosystem. Time permitting, we review external
interactions and summarize the associated risks: for example, flash loan attacks, oracle
price manipulation, MEV/sandwich attacks, and so on.


**Code** **maturity.** We look for potential improvements in the codebase in general. We
look for violations of industry best practices and guidelines and code quality standards.
We also provide suggestions for possible optimizations, such as gas optimization,
upgradability weaknesses, centralization risks, and so on.


For each finding, Zellic assigns it an impact rating based on its severity and likelihood. There is no
hard-and-fast formula for calculating a finding’s impact. Instead, we assign it on a case-by-case
basis based on our judgment and experience. Both the severity and likelihood of an issue affect
its impact. For instance, a highly severe issue’s impact may be attenuated by a low likelihood.
We assign the following impact ratings (ordered by importance): Critical, High, Medium, Low,
and Informational.


Zellic © 2024 _←_ **Back to Contents** Page 7 of 25


**Lido Gateway** Smart Contract Security Assessment January 23, 2024


Zellic organizes its reports such that the most important findings come first in the document,
rather than being strictly ordered on impact alone. Thus, we may sometimes emphasize an
“Informational” finding higher than a “Low” finding. The key distinction is that although certain
findings may have the same impact rating, their _importance_ may differ. This varies based on
various soft factors, like our clients’ threat models, their business needs, and so on. We aim to
provide useful and actionable advice to our partners considering their long-term goals, rather
than a simple list of security issues at present.


Finally, Zellicprovidesalistofmiscellaneousobservationsthatdonothavesecurityimpactorare
not directly related to the scoped contracts itself. These observations — found in the Discussion
(4. ↗) section of the document — may include suggestions for improving the codebase, or general
recommendations, but do not necessarily convey that we suggest a code change.


Zellic © 2024 _←_ **Back to Contents** Page 8 of 25


**Lido Gateway** Smart Contract Security Assessment January 23, 2024


2.3. Scope


The engagement involved a review of the following targets:


**Lido Gateway Contracts**


**Repositories** <u>[https://github.com/scroll-tech/scroll](https://github.com/scroll-tech/scroll)</u> ↗
<u>[https://github.com/scroll-tech/governance-crosschain-bridges ↗](https://github.com/scroll-tech/governance-crosschain-bridges)</u>


**Versions** Bridge: 69224ebb935d499c055c7859c1c8ade57244249c
Governance: d023beed13f9b7f77c062b8fee43476788e48343


**Programs**                  - L1LidoGateway

                                         - L2LidoGateway

                                         - L2WstETHToken

                                         - LidoBridgeableTokens

                                         - LidoGatewayManager

                                         - ScrollBridgeExecutor


**Type** Solidity


**Platform** EVM-compatible


2.4. Project Overview


Zellic was contracted to perform a security assessment with two consultants for a total of eight
person-days. The assessment was conducted over the course of four calendar days.


Zellic © 2024 _←_ **Back to Contents** Page 9 of 25


**Lido Gateway** Smart Contract Security Assessment January 23, 2024


**Contact Information**



The following project manager was associated with the engagement:


**Chad McDonald**
Engagement Manager
<u>[chad@zellic.io ↗](mailto:chad@zellic.io)</u>


2.5. Project Timeline



The following consultants were engaged to
conduct the assessment:


**Aaron Esau**
Engineer
<u>[aaron@zellic.io ↗](mailto:aaron@zellic.io)</u>


**Vlad Toie**
Engineer
<u>[vlad@zellic.io ↗](mailto:vlad@zellic.io)</u>



The key dates of the engagement are detailed below.


**January 16, 2024** Start of primary review period


**January 19, 2024** End of primary review period


Zellic © 2024 _←_ **Back to Contents** Page 10 of 25


**Lido Gateway** Smart Contract Security Assessment January 23, 2024

## 3. Detailed Findings 3.1. L2 token is not necessarily pegged to L1 token


Target L2LidoGateway


**Category** Business Logic **Severity** Informational


**Likelihood** N/A **Impact** Informational


**Description**


Note that it is logically possible for the L2 token’s supply to be greater than the L1LidoGateway
balance of the L1 token; this is because the L2LidoGateway accepts the token address as a constructor parameter. L2 is ERC-20–implementation agnostic in that it only requires the ability to
call mint and burn on the token address.


**Impact**


The invariant that L1 locked supply is equal to the L2 supply can possibly be broken if the deployer (e.g., if the code is reused) is not aware of the requirement for L2LidoGateway to be the
only minter of the L2 token.


**Recommendations**


Ensure the only address able to mint L2 tokens is the L2LidoGateway. Alternatively, consider
deployingtheL2tokenfromtheL2LidoGatewaycontractanddeployingtheL2contractstoScroll
first before the L1 contracts (so that the L2 token’s address can be configured on L1).


**Remediation**


ScrollFoundationnotedthattheyintendtoensuretheonlyminterofL2tokensisL2LidoGateway:


We already make sure that L2LidoGateway is the only minter for L2 token. The address of
current L2 token is <u>[0xf610a9dfb7c89644979b4a0f27063e9e7d7cda32 ↗, you can see that](https://scrollscan.com/address/0xf610a9dfb7c89644979b4a0f27063e9e7d7cda32#code)</u>
only the gateway can mint token.


Zellic © 2024 _←_ **Back to Contents** Page 11 of 25


**Lido Gateway** Smart Contract Security Assessment January 23, 2024

## 4. Discussion The purpose of this section is to document miscellaneous observations that we made during the

assessment. These discussion notes are not necessarily security related and do not convey that
we are suggesting a code change.


4.1. Contract BridgeExecutorBase has ability to call onlyThis functions


Note that onlyThis functions in BridgeExecutorBase may be called via executeTransaction.
This may or may not be intended.


Zellic © 2024 _←_ **Back to Contents** Page 12 of 25


**Lido Gateway** Smart Contract Security Assessment January 23, 2024

## 5. Threat Model This provides a full threat model description for various functions. As time permitted, we ana
lyzed each function in the contracts and created a written threat model for some critical functions. A threat model documents a given function’s externally controllable inputs and how an
attacker could leverage each input to cause harm.


Not all functions in the audit scope may have been modeled. The absence of a threat model in
this section does not necessarily suggest that a function is safe.


5.1. Module: L1LidoGateway.sol


**Function:** **_beforeFinalizeWithdrawERC20(address** **_l1Token,** **address**
**_l2Token,** **address** **None,** **address** **None,** **uint256** **None,** **byte[]** **None)**


The hook that is called before finalizeWithdrawERC20 is executed.


**Inputs**


_•_ _l1Token

_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : Has to be a supported L1 token.

_•_ **Impact** : The L1 token to be withdrawn.

_•_ _l2Token

_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : Has to be a supported L2 token.

_•_ **Impact** : The L2 token that has been bridged.


**Branches and code coverage (including function calls)**


**Intended branches**


_•_ Ensure that l1Token is supported.
Test coverage

_•_ Ensure that l2Token is supported.
Test coverage

_•_ Ensure that withdrawalsEnabled is true.
Test coverage


**Negative behavior**


_•_ Should not allow msg.value                             - 0.
Test coverage


Zellic © 2024 _←_ **Back to Contents** Page 13 of 25


**Lido Gateway** Smart Contract Security Assessment January 23, 2024


**Function:** **_deposit(address** **_token,** **address** **_to,** **uint256** **_amount,**
**byte[]** **_data,** **uint256** **_gasLimit)**


Facilitates the deposit of tokens from L1 to L2.


**Inputs**




_•_ _token


_•_ _to


_•_ _amount


_•_ _data




_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : Ensured that it is the l1Token address.

_•_ **Impact** : The token to be deposited.


_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : None.

_•_ **Impact** : The destination address for the deposit.


_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : Ensured that it is a nonzero amount.

_•_ **Impact** : The amount of tokens to be deposited.


_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : None.

_•_ **Impact** : The data to be passed to the recipient.




_•_ _gasLimit

_•_ **Control** : Fully controlled by the caller.




_•_ **Constraints** : None.

_•_ **Impact** : The gas limit for the deposit.


**Branches and code coverage (including function calls)**


**Intended branches**


_•_ Increase the balance of _token by _amount for address(this).
Test coverage

_•_ Decrease the balance of _token by _amount for msg.sender.
Test coverage

_•_ Generate the message to be sent cross-chain.
Test coverage

_•_ Forward the cross-chain finalizeDepositERC20 message to L2LidoGateway.
Test coverage

_•_ Ensure that depositsEnabled is true.
Test coverage

_•_ Ensure that token is supported.


Zellic © 2024 _←_ **Back to Contents** Page 14 of 25


**Lido Gateway** Smart Contract Security Assessment January 23, 2024


Test coverage


**Negative behavior**


_•_ Should not allow sending tokens if there is not enough balance. Handled in _transferERC20In.

Test coverage


5.2. Module: L2LidoGateway.sol


**Function:** **finalizeDepositERC20(address** **_l1Token,** **address** **_l2Token,**
**address** **_from,** **address** **_to,** **uint256** **_amount,** **byte[]** **_data)**


Finalizes the deposit of ERC-20 tokens from L1 to L2.


**Inputs**


_•_ _l1Token

_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : Ensured that it is supported.

_•_ **Impact** : The l1Token that has been deposited.

_•_ _l2Token

_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : Ensured that it is supported.

_•_ **Impact** : The l2Token to be minted.




_•_ _from


_•_ _to


_•_ _amount


_•_ _data




_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : None.

_•_ **Impact** : The depositor of the tokens.


_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : None.

_•_ **Impact** : The recipient of the tokens.


_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : None.

_•_ **Impact** : The amount of tokens to be minted.


_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : None.

_•_ **Impact** : Data to be passed to the callback.



Zellic © 2024 _←_ **Back to Contents** Page 15 of 25


**Lido Gateway** Smart Contract Security Assessment January 23, 2024


**Branches and code coverage (including function calls)**


**Intended branches**


_•_ Perform the callback on to with data.
Test coverage

_•_ Mint the correct amount of tokens to to.
Test coverage

_•_ Ensure that l1Token is supported.
Test coverage

_•_ Ensure that l2Token is supported.
Test coverage

_•_ Ensure that depositsEnabled is true.
Test coverage


**Negative behavior**


_•_ Should not be callable by anyone other than the counterpart.
Test coverage

_•_ msg.value should not be positive.
Test coverage


**Function:** **_withdraw(address** **_l2Token,** **address** **_to,** **uint256** **_amount,**
**byte[]** **_data,** **uint256** **_gasLimit)**


Facilitates the withdrawing of tokens from L2 to L1.


**Inputs**


_•_ _l2Token

_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : Ensure it is a supported L2 token.

_•_ **Impact** : The L2 token to be withdrawn.




_•_ _to


_•_ _amount


_•_ _data




_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : None.

_•_ **Impact** : The address to which the tokens will be sent.


_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : Ensured from possesses at least _amount tokens.

_•_ **Impact** : The amount of tokens to be withdrawn.


_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : None.



Zellic © 2024 _←_ **Back to Contents** Page 16 of 25


**Lido Gateway** Smart Contract Security Assessment January 23, 2024


_•_ **Impact** : The data to be forwarded cross-chain.

_•_ _gasLimit

_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : None.

_•_ **Impact** : The gas limit for the cross-chain transaction.


**Branches and code coverage (including function calls)**


**Intended branches**


_•_ Ensure that l2Token is supported.
Test coverage

_•_ Ensure that withdrawals are enabled.
Test coverage

_•_ Burn the amount of tokens from from.
Test coverage

_•_ Generate the message to be sent to L1.
Test coverage

_•_ Forward the message to L1.
Test coverage


**Negative behavior**


_•_ Should not allow sending tokens if there is not enough balance. Handled in burn.
Test coverage


5.3. Module: L2WstETHToken.sol


**Function:** **permit(address** **owner,** **address** **spender,** **uint256** **value,**
**uint256** **deadline,** **uint8** **v,** **bytes32** **r,** **bytes32** **s)**


Permits spender to spend value tokens on behalf of owner with a valid signature.


**Inputs**




_•_ owner


_•_ spender




_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : Ensured that the owner is the recovered address from the
computed signature (in isValidSignatureNow).

_•_ **Impact** : The owner of the tokens to be approved.


_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : Ensured that spender is included in the computed signature



Zellic © 2024 _←_ **Back to Contents** Page 17 of 25


**Lido Gateway** Smart Contract Security Assessment January 23, 2024


(in isValidSignatureNow).

_•_ **Impact** : The spender of the tokens to be approved.




_•_ value




_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : Ensured that value is the approved amount of tokens (in isValidSignatureNow).

_•_ **Impact** : The amount of tokens to be approved.




_•_ deadline

_•_ **Control** : Fully controlled by the caller.




_•_ v


_•_ r


_•_ s




_•_ **Constraints** : Ensured that the deadline is respected.

_•_ **Impact** : The deadline of the signature.


_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : Ensured that v is valid in the computed signature (in isValidSignatureNow).

_•_ **Impact** : Component of the ECDSA signature.


_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : Ensured that r is valid in the computed signature (in isValidSignatureNow).

_•_ **Impact** : Component of the ECDSA signature.


_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : Ensured that s is valid in the computed signature (in isValidSignatureNow).

_•_ **Impact** : Component of the ECDSA signature.



**Branches and code coverage (including function calls)**


**Intended branches**


_•_ Ensure that the signature is valid.
Test coverage

_•_ Use a nonce for replay protection.
Test coverage

_•_ Approve the desired amount of tokens.
Test coverage


**Negative behavior**


_•_ Should not allow using signatures that have been revoked (due to ERC-1271). That is
enforced in isValidSignatureNow.

Test coverage

_•_ Should not allow the usage of expired signatures.


Zellic © 2024 _←_ **Back to Contents** Page 18 of 25


**Lido Gateway** Smart Contract Security Assessment January 23, 2024


Test coverage


5.4. Module: LidoGatewayManager.sol


**Function: disableDeposits()**


Function that disables the deposits.


**Branches and code coverage (including function calls)**


**Intended branches**


_•_ Set the isDepositsEnabled to false.
Test coverage


**Negative behavior**


_•_ Should not allow to disable deposits if they are already disabled. Performed in whenDepositsEnabled modifier.

Test coverage

_•_ Should not allow anyone other than the depositsDisabler to disable deposits.
Test coverage


**Function: disableWithdrawals()**


Function that disables the withdrawals.


**Branches and code coverage (including function calls)**


**Intended branches**


_•_ Set the isWithdrawalsEnabled to false.
Test coverage


**Negative behavior**


_•_ Should not allow to disable withdrawals if they are already disabled. Performed in
whenWithdrawalsEnabled modifier.

Test coverage

_•_ Shouldnotallowanyoneotherthanthe withdrawalsDisabler todisablewithdrawals.
Test coverage


Zellic © 2024 _←_ **Back to Contents** Page 19 of 25


**Lido Gateway** Smart Contract Security Assessment January 23, 2024


**Function: enableDeposits()**


Function that enables the deposits.


**Branches and code coverage (including function calls)**


**Intended branches**


_•_ Set the isDepositsEnabled to true.
Test coverage


**Negative behavior**


_•_ Should not allow to enable deposits if they are already enabled.
Test coverage

_•_ Should not allow anyone other than the depositsEnabler to enable deposits.
Test coverage


**Function: enableWithdrawals()**


Function that enables the withdrawals.


**Branches and code coverage (including function calls)**


**Intended branches**


_•_ Set the isWithdrawalsEnabled to true.
Test coverage


**Negative behavior**


_•_ Should not allow to enable withdrawals if they are already enabled.
Test coverage

_•_ Should not allow anyone other than the withdrawalsEnabler to enable withdrawals.
Test coverage


**Function: updateDepositsDisabler(address** **_newDisabler)**


Allows owner to update the address of the deposits disabler.


**Inputs**


_•_ _newDisabler

_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : None.


Zellic © 2024 _←_ **Back to Contents** Page 20 of 25


**Lido Gateway** Smart Contract Security Assessment January 23, 2024


_•_ **Impact** : The address of the new deposits disabler.


**Branches and code coverage (including function calls)**


**Intended branches**


_•_ Set the depositsDisabler to _newDisabler. Currently not tested.
Test coverage


**Negative behavior**


_•_ Should not allow anyone other than the owner to update the address of the deposits
disabler. Not tested.

Test coverage

_•_ Shouldnotallowsettingthesameaddressasthecurrentdepositsdisabler. Nottested
and not enforced.

Test coverage

_•_ Should not allow changing the address of the deposits disabler should the deposits
be enabled at the moment. Not tested and not enforced.

Test coverage


**Function: updateDepositsEnabler(address** **_newEnabler)**


Allows owner to update the address of the deposits enabler.


**Inputs**


_•_ _newEnabler

_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : None.

_•_ **Impact** : The address of the new deposits enabler.


**Branches and code coverage (including function calls)**


**Intended branches**


_•_ Set the depositsEnabler to _newEnabler. Currently not tested.
Test coverage


**Negative behavior**


_•_ Should not allow anyone other than the owner to update the address of the deposits
enabler. Not tested.

Test coverage

_•_ Should not allow setting the same address as the current deposits enabler. Not tested


Zellic © 2024 _←_ **Back to Contents** Page 21 of 25


**Lido Gateway** Smart Contract Security Assessment January 23, 2024


and not enforced.

Test coverage

_•_ Should not allow changing the address of the deposits enabler should the deposits be
enabled at the moment. Not tested and not enforced.

Test coverage


**Function: updateWithdrawalsDisabler(address** **_newDisabler)**


Allows owner to update the address of the withdrawals disabler.


**Inputs**


_•_ _newDisabler

_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : None.

_•_ **Impact** : The address of the new withdrawals disabler.


**Branches and code coverage (including function calls)**


**Intended branches**


_•_ Set the withdrawalsDisabler to _newDisabler. Currently not tested.
Test coverage


**Negative behavior**


_•_ Should not allow anyone other than the owner to update the address of the withdrawals disabler. Not tested.

Test coverage

_•_ Should not allow setting the same address as the current withdrawals disabler. Not
tested and not enforced.

Test coverage

_•_ Should not allow changing the address of the withdrawals disabler should the withdrawals be disabled at the moment. Not tested and not enforced.

Test coverage


**Function: updateWithdrawalsEnabler(address** **_newEnabler)**


Allows owner to update the address of the withdrawals enabler.


**Inputs**


_•_ _newEnabler


Zellic © 2024 _←_ **Back to Contents** Page 22 of 25


**Lido Gateway** Smart Contract Security Assessment January 23, 2024


_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : None.

_•_ **Impact** : The address of the new withdrawals enabler.


**Branches and code coverage (including function calls)**


**Intended branches**


_•_ Set the withdrawalsEnabler to _newEnabler. Currently not tested.
Test coverage


**Negative behavior**


_•_ Should not allow anyone other than the owner to update the address of the withdrawals enabler. Not tested.

Test coverage

_•_ Should not allow setting the same address as the current withdrawals enabler. Not
tested and not enforced.

Test coverage

_•_ Should not allow changing the address of the withdrawals enabler should the withdrawals be enabled at the moment. Not tested and not enforced.

Test coverage


5.5. Module: ScrollBridgeExecutor.sol


**Function:** **constructor(address** **l2ScrollMessenger,** **address** **ethereum-**
**GovernanceExecutor,** **uint256** **delay,** **uint256** **gracePeriod,** **uint256** **min-**
**imumDelay,** **uint256** **maximumDelay,** **address** **guardian)**


Deploys a new L2BridgeExecutor contract with l2ScrollMessenger.


**Inputs**


_•_ l2ScrollMessenger

_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : None.

_•_ **Impact** : The l2ScrollMessenger contract address.

_•_ ethereumGovernanceExecutor

_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : None.

_•_ **Impact** : The ethereumGovernanceExecutor contract address.




_•_ delay




_•_ **Control** : Fully controlled by the caller.



Zellic © 2024 _←_ **Back to Contents** Page 23 of 25


**Lido Gateway** Smart Contract Security Assessment January 23, 2024


_•_ **Constraints** : Checked to be greater than minimumDelay and less than maximumDelay.

_•_ **Impact** : The delay before which an actions set can be executed.

_•_ gracePeriod

_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : Checked to be greater than MINIMUM_GRACE_PERIOD.

_•_ **Impact** : The time period after a delay during which an actions set can be
executed.

_•_ minimumDelay

_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : Checked to be less than maximumDelay.

_•_ **Impact** : The minimum bound a delay can be set to.

_•_ maximumDelay

_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : Checked to be greater than minimumDelay.

_•_ **Impact** : The maximum bound a delay can be set to.

_•_ guardian

_•_ **Control** : Fully controlled by the caller.

_•_ **Constraints** : None.

_•_ **Impact** : The guardian address.


**Branches and code coverage (including function calls)**


**Intended branches**


_•_ Set all the parameters, including the L2_SCROLL_MESSENGER address.
Test coverage


Zellic © 2024 _←_ **Back to Contents** Page 24 of 25


**Lido Gateway** Smart Contract Security Assessment January 23, 2024

## 6. Assessment Results At the time of our assessment, the reviewed code was partly deployed to the Ethereum Mainnet

and Scroll.


DuringourassessmentonthescopedLidoGatewaycontracts, wediscoveredonefinding, which
was informational in nature. Scroll Foundation acknowledged the finding and implemented a fix.


6.1. Disclaimer


This assessment does not provide any warranties about finding all possible issues within its
scope; in other words, the evaluation results do not guarantee the absence of any subsequent
issues. Zellic, of course, also cannot make guarantees about any code added to the project after the version reviewed during our assessment. Furthermore, because a single assessment
can never be considered comprehensive, we always recommend multiple independent assessments paired with a bug bounty program.


For each finding, Zellic provides a recommended solution. All code samples in these recommendations are intended to convey how an issue may be resolved (i.e., the idea), but they may not be
tested or functional code. These recommendations are not exhaustive, and we encourage our
partners to consider them as a starting point for further discussion. We are happy to provide
additional guidance and advice as needed.


Finally, the contents of this assessment report are for informational purposes only; do not construe any information in this report as legal, tax, investment, or financial advice. Nothing contained in this report constitutes a solicitation or endorsement of a project by Zellic.


Zellic © 2024 _←_ **Back to Contents** Page 25 of 25


