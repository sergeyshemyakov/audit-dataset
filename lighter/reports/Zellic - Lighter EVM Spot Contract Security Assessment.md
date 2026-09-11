**Prepared for**
**Manu**
Lighter


**January 21, 2026**

# Lighter (EVM) Smart Contract Security Assessment



**Prepared by**
**Filipe Alves**
**Quentin Lemauf**
Zellic


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026

## Contents About Zellic 4


**1.** **Overview** **4**


1.1. Executive Summary 5


1.2. Goals of the Assessment 5


1.3. Non-goals and Limitations 5


1.4. Results 6


**2.** **Introduction** **6**


2.1. About Lighter (EVM) 7


2.2. Methodology 7


2.3. Scope 9


2.4. File Checksums 9


2.5. Project Overview 10


2.6. Project Timeline 11


**3.** **Detailed Findings** **11**


3.1. L1 createOrder rejects spot-market indexes 12


3.2. Insufficient test coverage 14


3.3. Default asset configs rely on manual migration during upgrades 16


3.4. Priority requests not revalidated against current L1 state during execution 19


**4.** **Discussion** **20**


4.1. Notes on issues already handled 21


Zellic © 2026 _←_ **Back to Contents** Page 2 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**5.** **Threat Model** **23**


5.1. Module: AdditionalZkLighter.sol 24


5.2. Module: ZkLighter.sol 62


**6.** **Assessment Results** **106**


6.1. Disclaimer 107


Zellic © 2026 _←_ **Back to Contents** Page 3 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026

## About Zellic Zellic is a vulnerability research firm with deep expertise in blockchain security. We specialize in

EVM, Move (Aptos and Sui), and Solana as well as Cairo, NEAR, and Cosmos. We review L1s and
L2s, cross-chain protocols, wallets and applied cryptography, zero-knowledge circuits, web applications, and more.


Prior to Zellic, we founded the <u>[#1 CTF (competitive hacking) team ↗](https://perfect.blue)</u> worldwide in 2020, 2021, and
2023. Our engineers bring a rich set of skills and backgrounds, including cryptography, web security, mobile security, low-level exploitation, and finance. Our background in traditional information security and competitive hacking has enabled us to consistently discover hidden vulnerabilities
and develop novel security research, earning us the reputation as the go-to security firm for teams
whose rate of innovation outpaces the existing security landscape.


For more on Zellic’s ongoing security research initiatives, check out our website <u>[zellic.io ↗](https://zellic.io)</u> and follow
<u>[@zellic_io ↗](https://twitter.com/zellic_io)</u> on Twitter. If you are interested in partnering with Zellic, contact us at <u>[hello@zellic.io ↗.](mailto:hello@zellic.io)</u>


Zellic © 2026 _←_ **Back to Contents** Page 4 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026

## 1. Overview 1.1. Executive Summary


Zellic conducted a security assessment for Lighter from December 25th, 2025 to January 7th,
2026. During this engagement, our team analyzed the Lighter (EVM) codebase to identify security
vulnerabilities, design flaws, and other issues that could impact its security posture.


1.2. Goals of the Assessment


In a security assessment, goals are framed in terms of questions that we wish to answer. These
questions are agreed upon through close communication between Zellic and the client. In this
assessment, we sought to answer the following questions:


_•_ Are spot-market index ranges correctly validated across all priority-request flows and
state transitions?

_•_ Can spot-market functionality introduce vulnerabilities or bypass existing security
controls in the priority-request queue?

_•_ Can emergency exit mechanisms (desert mode) be exploited or misused to lock funds
permanently?

_•_ Are authorization boundaries between on-chain and off-chain validation clearly defined
and secure?

_•_ Do asset-configuration migrations during upgrades properly initialize all default assets
without creating locked states?

_•_ Does the upgrade mechanism properly validate parameters and maintain access-control
integrity?

_•_ Arestatemigrationsduringupgradeshandledsafelywithoutintroducinginconsistencies
or fund loss?

_•_ Are initialization and upgrade functions protected against reinitialization or replay
attacks?


1.3. Non-goals and Limitations


We did not assess the following areas that were outside the scope of this engagement:


_•_ Front-end components

_•_ Infrastructure relating to the project

_•_ Key custody

_•_ Off-chain system components (sequencer, prover, indexer, zero-knowledge circuits)


We assume these off-chain components are functioning as intended and focus exclusively on the
on-chain smart contract security.


Zellic © 2026 _←_ **Back to Contents** Page 5 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


Due to the time-boxed nature of security assessments in general, there are limitations in the
coverage an assessment can provide.


1.4. Results


During our assessment on the scoped Lighter (EVM) contracts, we discovered four findings. No
critical issues were found. Two findings were of medium impact, one was of low impact, and the
remaining finding was informational in nature.


Additionally, Zellic recorded its notes and observations from the assessment for the benefit of
Lighter in the Discussion section (4. ↗).


**Breakdown of Finding Impacts**


**Impact Level** **Count**


           - Critical 0


           - High 0


           - Medium 2


           - Low 1


           - Informational 1


Zellic © 2026 _←_ **Back to Contents** Page 6 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026

## 2. Introduction 2.1. About Lighter (EVM)


Lighter contributed the following description of Lighter (EVM):


Lighter is a decentralized trading platform built for unmatched security and scale. It’s the first
exchange to offer verifiable order matching and liquidations while delivering best-in-class performance on par with traditional exchanges.


2.2. Methodology


During a security assessment, Zellic works through standard phases of security auditing, including
bothautomatedtestingandmanualreview. Theseprocessescanvarysignificantlyperengagement,
but the majority of the time is spent on a thorough manual review of the entire scope.


Alongside a variety of tools and analyzers used on an as-needed basis, Zellic focuses primarily on
the following classes of security and reliability issues:


**Basic coding mistakes.** Many critical vulnerabilities in the past have been caused by simple,
surface-level mistakes that could have easily been caught ahead of time by code review.
Depending on the engagement, we may also employ sophisticated analyzers such as model
checkers, theorem provers, fuzzers, and so on as necessary. We also perform a cursory
review of the code to familiarize ourselves with the contracts.


**Business** **logic** **errors.** Business logic is the heart of any smart contract application.
We examine the specifications and designs for inconsistencies, flaws, and weaknesses
that create opportunities for abuse. For example, these include problems like unrealistic
tokenomicsordangerousarbitrageopportunities. Tothebestofourabilities, timepermitting,
we also review the contract logic to ensure that the code implements the expected
functionality as specified in the platform's design documents.


**Integration risks.** Several well-known exploits have not been the result of any bug within
the contract itself; rather, they are an unintended consequence of the contract's interaction
with the broader DeFi ecosystem. Time permitting, we review external interactions and
summarize the associated risks: for example, flash loan attacks, oracle price manipulation,
MEV/sandwich attacks, and so on.


**Code** **maturity.** We look for potential improvements in the codebase in general. We look
for violations of industry best practices and guidelines and code quality standards. We
also provide suggestions for possible optimizations, such as gas optimization, upgradability
weaknesses, centralization risks, and so on.


For each finding, Zellic assigns it an impact rating based on its severity and likelihood. There is no
hard-and-fast formula for calculating a finding’s impact. Instead, we assign it on a case-by-case
basis based on our judgment and experience. Both the severity and likelihood of an issue affect


Zellic © 2026 _←_ **Back to Contents** Page 7 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


its impact. For instance, a highly severe issue's impact may be attenuated by a low likelihood.
We assign the following impact ratings (ordered by importance): Critical, High, Medium, Low, and
Informational.


Zellic organizes its reports such that the most important findings come first in the document, rather
than being strictly ordered on impact alone. Thus, we may sometimes emphasize an "Informational"
finding higher than a "Low" finding. The key distinction is that although certain findings may have the
same impact rating, their _importance_ may differ. This varies based on various soft factors, like our
clients’ threat models, their business needs, and so on. We aim to provide useful and actionable
advice to our partners considering their long-term goals, rather than a simple list of security issues
at present.


Finally, Zellic provides a list of miscellaneous observations that do not have security impact or are
not directly related to the scoped contracts itself. These observations — found in the Discussion
(4. ↗) section of the document — may include suggestions for improving the codebase, or general
recommendations, but do not necessarily convey that we suggest a code change.


Zellic © 2026 _←_ **Back to Contents** Page 8 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


2.3. Scope


The engagement involved a review of the following targets:


**Lighter (EVM) Contracts**


**Type** Solidity


**Platform** EVM-compatible


**Target** Only changes between 5cbd2d23..e6890b14


**Repository** <u>[https://github.com/elliottech/lighter-contracts.git ↗](https://github.com/elliottech/lighter-contracts.git)</u>


**Version** e6890b14a340321be161fb99d980c71c348541dc


**Programs** ZkLighter.sol
AdditionalZkLighter.sol

lib/Bytes.sol
lib/TxTypes.sol
ExtendableStorage.sol
Config.sol
Storage.sol


2.4. File Checksums


ThisassessmentcoveredLighter(EVM)atcommithash e6890b14a340321be161fb99d980c71c348541dc.
The SHA-256 checksums of the audited source files are listed below. File paths are relative to the
contracts/ directory.


Zellic © 2026 _←_ **Back to Contents** Page 9 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**File** **SHA-256**


AdditionalZkLighter.sol ab3a4944ac609dd300c9f205bdc2d909974c227da1b57f9333ea1aca7524f936


Config.sol d58837a79c3a51189707a24636408532881918ab5be3b82296384d7b60266a39


ExtendableStorage.sol 462ad9a220c39a456e31ac7d5fa5bf7590e68195a6eadd4fd5eca061f94b91f8


lib/Bytes.sol 8312145c6db2cc32c89e7b19685c91fb5d22c05a89fe05b3f32cf63a8b681788


lib/TxTypes.sol 836b2d80238de6d7415efa2c8d3fff6c9a782d47ee0716d490627c5680d9429b


Storage.sol a4c6946df6be78289ade3f2fefc4dd034f5e26edad0a9f6a25337b32185a9845


ZkLighter.sol afb22aba6f17d81b0c5707cf5a308ea3072edf5d4c136642605f86d0083dc9a8


The following script was used to compute these checksums, should the reader wish to reproduce
them (run from the root of the repository at the audited commit):


#!/usr/bin/env zsh
files=(

contracts/AdditionalZkLighter.sol
contracts/Config.sol
contracts/ExtendableStorage.sol
contracts/lib/Bytes.sol

contracts/lib/TxTypes.sol
contracts/Storage.sol
contracts/ZkLighter.sol
)
shasum -a 256 $files | awk '{printf "%-48s                  - %s\n", $2, $1}'


2.5. Project Overview


Zellic was contracted to perform a security assessment for a total of 2.2 person-weeks. The assessment was conducted by two consultants over the course of nine calendar days.


Zellic © 2026 _←_ **Back to Contents** Page 10 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Contact Information**



The following project manager was associated
with the engagement:


**Jacob Goreski**
Engagement Manager
<u>[jacob@zellic.io ↗](mailto:jacob@zellic.io)</u>


2.6. Project Timeline



The following consultants were engaged to
conduct the assessment:


**Filipe Alves**
Engineer
<u>[filipe@zellic.io ↗](mailto:filipe@zellic.io)</u>


**Quentin Lemauf**
Engineer
<u>[quentin@zellic.io ↗](mailto:quentin@zellic.io)</u>



The key dates of the engagement are detailed below.


**December 25, 2025** Start of primary review period


**January 7, 2026** End of primary review period


Zellic © 2026 _←_ **Back to Contents** Page 11 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026

## 3. Detailed Findings 3.1. L1 createOrder rejects spot-market indexes


**Target** AdditionalZkLighter


**Category** Coding Mistakes **Severity** Medium


**Likelihood** Medium **Impact** Medium


**Description**


The protocol uses different market index ranges for different market types:


_•_ Perps markets use indexes <= MAX_PERPS_MARKET_INDEX (currently 254).

_•_ Spot markets use indexes in the MIN_SPOT_MARKET_INDEX..MAX_SPOT_MARKET_INDEX
range (currently 2048..4094).


However, AdditionalZkLighter::createOrder validates _marketIndex only against
MAX_PERPS_MARKET_INDEX and reverts for any value greater than 254. As a result, every attempt to
submit an L1 order for a spot market (which must use an index >= 2048) will revert and never be
added to the priority queue.


function createOrder(

uint48 _accountIndex,
uint16 _marketIndex,
uint48 _baseAmount,
uint32 _price,

uint8 _isAsk,
uint8 _orderType
) external nonReentrant onlyActive {


// ...


if (_marketIndex                   - MAX_PERPS_MARKET_INDEX) {

revert AdditionalZkLighter_InvalidMarketIndex();
}


// ...
}


**Impact**


Spot markets cannot accept L1 submitted orders via createOrder, effectively disabling the
spot-order flow through the on-chain priority-request queue (“escape hatch”) that the


Zellic © 2026 _←_ **Back to Contents** Page 12 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


documentation describes as existing “to guarantee liveness and censorship resistance” by
allowing users to submit critical operations on chain (with the Sequencer required to process them
within a predefined time frame). See the documentation <u>[here ↗.](https://docs.lighter.xyz/about-lighter/technical-architecture-lighter-core#escape-hatch)</u>


**Recommendations**


Update createOrder market index validation to accept both perps and spot-market index ranges:


_•_ _marketIndex <= MAX_PERPS_MARKET_INDEX or

_•_ MIN_SPOT_MARKET_INDEX <= _marketIndex <= MAX_SPOT_MARKET_INDEX


**Remediation**


This issue has been acknowledged by Lighter.


Zellic © 2026 _←_ **Back to Contents** Page 13 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


3.2. Insufficient test coverage


**Target** Project-wide


**Category** Protocol Risks **Severity** Medium


**Likelihood** N/A **Impact** Medium


**Description**


The test suite for the Lighter EVM contracts has notable gaps in coverage for critical functionality.
While basic deposit, withdrawal, and batch-processing flows have some coverage, several
important areas lack comprehensive testing.


The EIP-4844 blob-processing functions (_pointEvaluationPrecompile and _processBlobs)
have limited direct test coverage: the happy path is exercised via commitBatch, but
blob-verification edge cases and error conditions are untested. Similarly, revertBatches has no
meaningful test coverage.


Desert-mode functionality, which handles emergency withdrawals, lacks comprehensive testing.
Functions such as performDesert and createExitCommitment have no tests, and
cancelOutstandingDepositsForDesertMode has only partial coverage with several important
branches untested. The updateStateRoot function also has no direct tests, and upgrade-related
state-root override logic (via stateRootUpdates during commitBatch) remains unverified.


Several delegation wrapper functions have limited or no direct testing: registerAsset and
updateAsset are never called in tests (all validation logic remains untested); depositBatch has no
direct coverage for batch-specific validations (array-length matching, empty arrays,
MAX_BATCH_DEPOSIT_LENGTH); createOrder never tests market orders or NIL_ORDER_BASE_AMOUNT;
and burnShares is missing tests for the _accountIndex == _publicPoolIndex equality check and
unregistered caller revert. Proxy and upgrade mechanisms also have minimal coverage.


The deposit flow handles fee-on-transfer tokens by calculating balanceAfter                    - balanceBefore
and crediting excess to the treasury, but this logic is never tested.


Additionally, the test suite lacks end-to-end (E2E) tests entirely. Given that critical paths in this
protocol involve off-chain components (sequencer, ZK circuit, L2 state management), E2E tests are
essential to verify the full flow from L1 priority-request creation through off-chain processing to
final L1 execution — specifically the priority-request lifecycle, the batch-processing flow
(commitBatch → verifyBatch → executeBatches), and the desert-mode activation and exit flow.
Without E2E tests, interactions between L1 contracts and off-chain components remain unverified.
See section <u>5. ↗for further details.</u>


Zellic © 2026 _←_ **Back to Contents** Page 14 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Impact**


Insufficient test coverage increases the likelihood of bugs and vulnerabilities going unnoticed until
after deployment. The untested areas include critical emergency functionality (desert mode),
newer EVM features (EIP-4844 blobs), and state-management operations that are difficult to verify
through manual review alone.


**Recommendations**


We recommend building a comprehensive E2E test suite that covers the full life cycle of priority
requests from L1 creation through off-chain processing to final execution, including the
batch-processing flow and desert-mode activation. This would help verify the interactions
between on-chain contracts and off-chain components that are critical to the protocol's security.


Additionally, unit test coverage should be expanded to include EIP-4844 blob-processing functions
with edge cases and malformed blob data, batch reversion scenarios, desert-mode activation and
fund-recovery flows, state-root upgrade flows with mock ZK proofs, all delegation wrapper
functions (particularly registerAsset, updateAsset, depositBatch batch-specific logic,
createOrder market orders, and burnShares edge cases), fee-on-transfer token handling, and
negative tests for revert conditions in critical paths.


**Remediation**


This issue has been acknowledged by Lighter.


Zellic © 2026 _←_ **Back to Contents** Page 15 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


3.3. Default asset configs rely on manual migration during upgrades


**Target** ZkLighter


**Category** Business Logic **Severity** Low


**Likelihood** Low **Impact** Low


**Description**


The function _registerDefaultAssetConfigs() is only called in ZkLighter.initialize() and
not in ZkLighter.upgrade(). This helper registers the default assets and their parameters,
including native ETH (NATIVE_ASSET_INDEX = 1) and USDC (USDC_ASSET_INDEX = 3).


When a proxy upgrade occurs via Proxy.upgradeTarget(), it calls ZkLighter.upgrade() rather
than initialize(). If a live deployment is upgraded to the multiasset version without a separate
migration step, the default asset configs would remain uninitialized. This is particularly fragile
because ETH cannot be configured later using ZkLighter.registerAssetConfig(), as it explicitly
rejects NATIVE_ASSET_INDEX:


// [...]
if (assetIndex == NATIVE_ASSET_INDEX || assetConfigs[assetIndex].tokenAddress

!= address(0)) {

revert ZkLighter_InvalidAssetIndex();
}
// [...]


Additionally, the _deposit() function in AdditionalZkLighter does not validate that the native ETH
asset configuration is properly initialized before performing arithmetic operations with tickSize.
For non-native assets, uninitialized configs are caught by checking tokenAddress == address(0).
However, native ETH legitimately uses tokenAddress = address(0), so this validation is skipped.
The function then uses tickSize directly in modulo and division operations. If tickSize == 0,
both operations would cause a division-by-zero panic.


**Impact**


If native ETH's asset configuration is not properly set, all native ETH deposits would panic with
division by zero (not a clean revert), users would receive unhelpful error messages, and ETH
deposit functionality would be completely broken. Unlike USDC, which fails safely with
InvalidAssetIndex, native ETH has no fallback validation.


Zellic © 2026 _←_ **Back to Contents** Page 16 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Recommendations**


We recommend keeping _registerDefaultAssetConfigs() permanently in the upgrade()
function. This would ensure that future upgrades automatically initialize default asset configs
without requiring manual intervention.


Lighter team has acknowledged this issue and provided the following response:


We already performed the upgrade by calling _registerDefaultAssetConfigs() in the upgrade function and then removed it from the function.


This addressed the immediate risk for the current upgrade. However, this differs from our
recommendation in that the function call was temporary—it was removed after the upgrade
completed.


For defense in depth, also consider adding explicit validation for native ETH configuration in

AdditionalZkLighter::_deposit():


function _deposit(address[] memory _to, uint16 _assetIndex,

TxTypes.RouteType _routeType, uint256[] memory _amount) internal {
AssetConfig memory assetConfig = assetConfigs[_assetIndex];

if (_assetIndex != NATIVE_ASSET_INDEX) {

if (assetConfig.tokenAddress == address(0)) {


revert AdditionalZkLighter_InvalidAssetIndex();


}

if (_assetIndex == NATIVE_ASSET_INDEX) {

if (assetConfig.tickSize == 0) {


revert AdditionalZkLighter_InvalidAssetIndex();


}

} else {

if (assetConfig.tokenAddress == address(0)) {


revert AdditionalZkLighter_InvalidAssetIndex();


}

if (msg.value != 0) {

revert AdditionalZkLighter_InvalidDepositAmount();
}
}


Additionally, the test suite has the specific test for the ZkLighter upgrade skipped
(it.skip('upgrade zkLighter', ...) in test/upgradeable/Proxy.test.ts), and no migration test
exists that simulates upgrading from the old version to the new multiasset version. We recommend
implementing proper test coverage for upgrade scenarios to ensure default asset configs are
correctly initialized during future upgrades.


Zellic © 2026 _←_ **Back to Contents** Page 17 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Remediation**


This issue has been acknowledged by Lighter.


Zellic © 2026 _←_ **Back to Contents** Page 18 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


3.4. Priority requests not revalidated against current L1 state during execution


**Target** ZkLighter, AdditionalZkLighter


**Category** Business Logic **Severity** Informational


**Likelihood** Low **Impact** Informational


**Description**


Priority requests are validated only at creation time on L1. Once a priority request is created and
added to the queue, governance changes to asset configuration (such as depositCapTicks or
minDepositTicks) do not affect its processing. The on-chain batch life-cycle functions
(commitBatch, verifyBatch, executeBatches) do not revalidate the current L1 configuration state
before executing priority operations.


For example, if a user creates a deposit request when depositCapTicks allows for large deposits,
and governance then reduces depositCapTicks, the deposit would still complete successfully
even though it exceeds the new cap. These snapshot semantics are likely intentional, as users
should be able to rely on their valid requests being processed.


It is worth noting that withdrawalsEnabled cannot be disabled once enabled (the code enforces a
one-way transition from 0 to 1), so the scenario of pausing withdrawals does not apply to in-flight
requests.


**Impact**


This behavior is likely intentional, as users should be able to rely on their valid requests being
processed regardless of later governance changes. However, governance should be aware that
configuration changes only affect new priority requests, not in-flight ones. Users monitoring
governance actions could also front-run configuration changes by creating requests before new
restrictions take effect, though this does not result in fund loss.


**Recommendations**


We recommend documenting the snapshot validation behavior so that governance understands
configuration changes only affect new priority requests. Additionally, it should be clarified whether
the sequencer and ZK circuit also use snapshot semantics when processing priority requests, to
ensure consistent behavior across L1 and off-chain components.


Zellic © 2026 _←_ **Back to Contents** Page 19 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Remediation**


This issue has been acknowledged by Lighter.


Zellic © 2026 _←_ **Back to Contents** Page 20 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026

## 4. Discussion The purpose of this section is to document miscellaneous observations that we made during the

assessment. These discussion notes are not necessarily security related and do not convey that
we are suggesting a code change.


4.1. Notes on issues already handled


The following are several notes on issues that are already handled by the off-chain process or prior
upgrade.


**Parameter-locked upgrade() via a hardcoded commitment hash**


As shown below, ZkLighter.upgrade() gates upgrades by requiring
keccak256(upgradeParameters) to match a hardcoded commitment:


bytes32 upgradeParametersHash = keccak256(upgradeParameters);
// Commits to 0 address for _additionalZkLighter, _desertVerifier and

_stateRootUpgradeVerifier
bytes32 initializationParametersCommitment

= 0x46700b4d40ac5c35af2c22dda2787a91eb567b06c924a8fb8ae9a05b20c08c21;

if (upgradeParametersHash != initializationParametersCommitment) {

revert ZkLighter_InvalidUpgradeParameters();
}


At the time of writing, the commitment corresponds to the “all-zero addresses” parameter set (i.e.,
abi.encode(address(0), address(0), address(0))). This effectively disables address updates
via the current upgrade() entry point (calls either revert or performs no state changes).


This is worth noting because it can look like a broken or inverted check when reviewing the code in
isolation.


The Lighter team notes the following:


This is an intentional “commitment-based” upgrade flow. The team plans to handle upgrades
by deploying a specific upgrade implementation where the hard-coded commitment is updated to the hash of the intended new addresses.


**Reliance of AdditionalZkLighter.changePubKey on circuit-level authorization**


As shown below, AdditionalZkLighter.changePubKey only enforces that msg.sender is a
registered master account:


Zellic © 2026 _←_ **Back to Contents** Page 21 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


uint48 _masterAccountIndex = getAccountIndexFromAddress(msg.sender);
if (_masterAccountIndex == NIL_ACCOUNT_INDEX) {

revert AdditionalZkLighter_AccountIsNotRegistered();
}


However, there is no on-chain access-control check that ties the requested _accountIndex to
msg.sender. As written, any registered master account can enqueue a ChangePubKey priority
request for an arbitrary _accountIndex.


The Lighter team notes the following:


Authorization is checked in the circuits; account indices and master account indices are not
tied together in the contracts.


**Requirement of ZkLighter.performDesert to provide the full per-asset balance**
**(no partial desert exit)**


As shown below, ZkLighter.performDesert requires callers to provide _totalBaseAmount, which
is incorporated into the public commitment verified by desertVerifier:


bytes32 commitment = createExitCommitment(

uint256(stateRoot),
_accountIndex,
_l1Address,

_assetIndex,
_totalBaseAmount
);


Given that _totalBaseAmount is user-supplied and there is no on-chain check that it matches the
account’s full balance, an incorrect value could permanently lock the remaining funds for that
asset/account.


The Lighter team notes the following:


Users must withdraw their entire balance for that asset for that account index; partial desert
exits are not supported.


Zellic © 2026 _←_ **Back to Contents** Page 22 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**If** **an** **ERC-20** **overtransfers,** **AdditionalZkLighter._deposit** **can** **leave** **unac-**
**counted dust**


When depositing ERC-20s via AdditionalZkLighter._deposit, the implementation compares
balanceAfter vs balanceBefore + totalAmount to detect nonstandard tokens. In particular, if the
token transfers _more_ than totalAmount, the excess is credited to the treasury:


} else if (balanceAfter                  - balanceBefore + totalAmount) {

uint256 excessAmount = balanceAfter                   - (balanceBefore + totalAmount);

uint64 baseExcessAmount = SafeCast.toUint64(excessAmount

/ assetConfig.tickSize);
increaseBalanceToWithdraw(TREASURY_ACCOUNT_INDEX, _assetIndex,

baseExcessAmount);
}


However, because the credited amount is rounded down by assetConfig.tickSize, any
remainder (excessAmount % assetConfig.tickSize) is left in the contract and is not represented
in the tick-based accounting. This means that up to assetConfig.tickSize                    - 1 (in token units)
can be left as dust per interaction if this branch is ever triggered, and it can accumulate over time.


The Lighter team notes the following:


Intended and acknowledged – expected not to trigger for supported assets.


Zellic © 2026 _←_ **Back to Contents** Page 23 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026

## 5. Threat Model This provides a full threat model description for various functions. As time permitted, we analyzed

each function in the contracts and created a written threat model for some critical functions. A
threat model documents a given function’s externally controllable inputs and how an attacker
could leverage each input to cause harm.


Not all functions in the audit scope may have been modeled. The absence of a threat model in this
section does not necessarily suggest that a function is safe.


5.1. Module: AdditionalZkLighter.sol


**Function:** **updateStateRoot(StoredBatchInfo** **calldata** **_lastStoredBatch,**
**bytes32** **_stateRoot,** **bytes32** **_validiumRoot,** **bytes** **calldata** **proof)**


This function allows active validators to upgrade the state root after all batches have been
executed. It verifies a zero-knowledge proof before updating critical state variables.


**Inputs**


_•_ _lastStoredBatch


_•_ **Control** : Validator control.

_•_ **Constraints** : Must match the stored batch hash at

storedBatchHashes[committedBatchesCount].

_•_ **Impact** : Used to verify the current state before upgrade.

_•_ _stateRoot


_•_ **Control** : Validator control.

_•_ **Constraints** : Must be verified by the state-root upgrade verifier proof.

_•_ **Impact** : The new state root that will replace the current one.

_•_ _validiumRoot


_•_ **Control** : Validator control.

_•_ **Constraints** : Must be verified by the state-root upgrade verifier proof.

_•_ **Impact** : The new validium root that will replace the current one.

_•_ proof


_•_ **Control** : Validator control.

_•_ **Constraints** : Must be a valid ZK proof that verifies the state transition from
old to new roots.

_•_ **Impact** : The cryptographic proof ensuring the state transition is valid.


**Branches and code coverage**


**Intended branches**


Zellic © 2026 _←_ **Back to Contents** Page 24 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ State root and validium root should be updated successfully when a valid proof is
provided.


Test coverage (not explicitly tested — edge-case feature)

_•_ The state-root upgrade verifier should be set to address(0) after successful verification.


Test coverage (not explicitly tested)


**Negative behavior**


_•_ Revert when the caller is not an active validator.


Negative test: not explicitly tested

_•_ Revert when stored batch information does not match.


Negative test: not explicitly tested

_•_ Revert when there are pending verified requests to execute.


Negative test: not explicitly tested

_•_ Revert when the state-root upgrade verifier is not set.


Negative test: not explicitly tested

_•_ Revert when ZK proof verification fails.


Negative test: not explicitly tested


**Function call analysis**


_•_ governance.isActiveValidator(msg.sender)


_•_ **What is controllable?** msg.sender by the caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — reverts if sender is not an active validator.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts the entire transaction, preventing unauthorized state-root updates.

_•_ hashStoredBatchInfo(_lastStoredBatch)


_•_ **What is controllable?** The entire _lastStoredBatch struct by validator.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
The return value is compared against stored hash. Mismatch causes a revert.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Pure function, no unusual control flow.

_•_ stateRootUpgradeVerifier.Verify(proof, inputs)


_•_ **What is controllable?** proof is fully controlled by the validator, and inputs is
derived from state roots.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns boolean. If false, the transaction reverts. A validator cannot force a


Zellic © 2026 _←_ **Back to Contents** Page 25 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


true result without valid proof.

_•_ **What happens if it reverts, reenters or does other unusual control flow?** If it
reverts, the entire transaction fails. It is an external call to the verifier contract
but protected by nonReentrant.


**Function:** **deposit(address** **_to,** **uint16** **_assetIndex,** **TxTypes.RouteType**
**_routeType,** **uint256** **_amount)**


This function allows users to deposit ETH or ERC-20 assets to ZkLighter. It validates deposit
amounts, handles both native and ERC-20 tokens, and registers the deposit in the priority queue.


**Inputs**


_•_ _to


_•_ **Control** : User control.

_•_ **Constraints** : Cannot be address(0) — validated in _deposit.

_•_ **Impact** : Recipient address for deposit on L2.

_•_ _assetIndex


_•_ **Control** : User control.

_•_ **Constraints** : Must be valid (NATIVE_ASSET_INDEX or configured ERC-20). See
validateAssetIndex.

_•_ **Impact** : Determines which asset to deposit.

_•_ _routeType


_•_ **Control** : User control.

_•_ **Constraints** : Type-safe enum (RouteType).

_•_ **Impact** : Routes deposit to perps or spot.

_•_ _amount


_•_ **Control** : User control.

_•_ **Constraints** : Must be >= minDeposit, aligned with tickSize, and not exceed
depositCap.

_•_ **Impact** : Amount to deposit.


**Branches and code coverage**


**Intended branches**


_•_ Native asset (ETH) deposits should succeed when msg.value matches _amount.


Test coverage: ZkLighter.t.sol::L-156
(test_deposit_eth_fail_and_success)


Zellic © 2026 _←_ **Back to Contents** Page 26 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ ERC-20 deposits should work with exact amounts.


Test coverage: ZkLighter.t.sol::L-101
(test_deposit_usdc_fail_and_success)

_•_ Account should be auto-registered if depositing to unregistered address.


Test coverage: ZkLighter.test.ts::L-701 (via _deposit)

_•_ Deposit should be added to priority queue.


Test coverage: ZkLighter.test.ts::L-711 (NewPriorityRequest event, via
_deposit)


**Negative behavior**


_•_ Revert when non-native asset has no configured tokenAddress.


Negative test: ZkLighter.t.sol::L-110

_•_ Revert when depositing ERC-20 with nonzero msg.value.


Negative test: ZkLighter.t.sol::L-126

_•_ Revert when amount is < minDeposit or not aligned with tickSize.


Negative test: ZkLighter.t.sol::L-122

_•_ Revert when recipient is address(0).


Negative test: ZkLighter.test.ts::L-686

_•_ Revert when ETH msg.value != _amount.


Negative test: ZkLighter.t.sol::L-172

_•_ Revert when ERC-20 transfer results in less balance than expected.


Negative test: not explicitly tested (fee-on-transfer tokens)

_•_ Revert when balanceAfter exceeds depositCap.


Negative test: ZkLighter.test.ts::L-692


**Function call analysis**


This function wraps _deposit with a single recipient. All deposit logic (validation, transfers, priority
queue) is handled in _deposit. See _deposit for detailed function call analysis.


**Function:** **depositBatch(uint64[]** **calldata** **_amount,** **address[]** **calldata**
**_to,** **uint48[]** **calldata** **_accountIndex)**


This function allows batch deposits of USDC to ZkLighter for multiple users in a single transaction.
It is hardcoded to use USDC_ASSET_INDEX and RouteType.Perps.


Zellic © 2026 _←_ **Back to Contents** Page 27 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Inputs**


_•_ _amount


_•_ **Control** : User control.

_•_ **Constraints** : Array length must match _to and _accountIndex, be > 0 and <=
MAX_BATCH_DEPOSIT_LENGTH. Each amount validated in _deposit.

_•_ **Impact** : USDC amounts to deposit for each recipient.

_•_ _to


_•_ **Control** : User control.

_•_ **Constraints** : Array length must match _amount and _accountIndex. Each
address cannot be address(0) — validated in _deposit.

_•_ **Impact** : Recipient addresses for deposits.

_•_ _accountIndex


_•_ **Control** : User control.

_•_ **Constraints** : Array length must match _amount and _to. Currently unused
but validated for length.

_•_ **Impact** : Reserved for future use.


**Branches and code coverage**


**Intended branches**


_•_ USDC batch deposits should succeed with valid arrays.


Test coverage: not tested (core logic tested via _deposit, but batch iteration
with multiple recipients not tested)

_•_ Account should be auto-registered if depositing to unregistered address.


Test coverage: not tested (single registration tested via _deposit, but
multiple registrations in batch not tested)

_•_ Deposit should be added to priority queue for each recipient.


Test coverage: not tested (single priority request tested via _deposit, but
multiple in batch not tested)


**Negative behavior**


_•_ Revert when array lengths do not match.


Negative test: not tested (batch-specific)

_•_ Revert when arrays are empty.


Negative test: not tested (batch-specific)

_•_ Revert when array length exceeds MAX_BATCH_DEPOSIT_LENGTH.


Zellic © 2026 _←_ **Back to Contents** Page 28 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


Negative test: not tested (batch-specific)

_•_ Revert when amount is < minDeposit or not aligned with tickSize.


Negative test: indirectly via _deposit — ZkLighter.t.sol::L-122

_•_ Revert when recipient is address(0).


Negative test: indirectly via _deposit — ZkLighter.test.ts::L-686

_•_ Revert when ERC-20 transfer fails.


Negative test: indirectly via _deposit — ZkLighter.t.sol::L-115


**Function call analysis**


This function wraps _deposit with multiple recipients, hardcoded to USDC and perps. All deposit
logic (validation, transfers, priority queue) is handled in _deposit. See _deposit for detailed
function call analysis.


**Function:** **changePubKey(uint48** **_accountIndex,** **uint8** **_apiKeyIndex,** **bytes**
**calldata** **_pubKey)**


Allows registered users to change the ZkLighter public key for an account API key slot. Validates
public key format and Goldilocks field constraints. Protected by nonReentrant and onlyActive
modifiers.


**Inputs**


_•_ _accountIndex


_•_ **Control** : User control (caller must be registered master account).

_•_ **Constraints** : Must be <= MAX_ACCOUNT_INDEX.

_•_ **Impact** : Account index whose public key will be changed.

_•_ _apiKeyIndex


_•_ **Control** : User control.

_•_ **Constraints** : Must be <= MAX_API_KEY_INDEX.

_•_ **Impact** : API key slot to update (multiple keys per account).

_•_ _pubKey


_•_ **Control** : User control.

_•_ **Constraints** : Must be exactly PUB_KEY_BYTES_SIZE (40 bytes), cannot be all
zeros, each 8-byte element must be < GOLDILOCKS_MODULUS.

_•_ **Impact** : New public key for signing ZkLighter operations.


Zellic © 2026 _←_ **Back to Contents** Page 29 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Branches and code coverage**


**Intended branches**


_•_ Public key change should succeed with valid parameters.


Test coverage: ZkLighter.test.ts::L-837

_•_ Priority request should be added to queue.


Test coverage: ZkLighter.test.ts::L-173 (helper verifies
NewPriorityRequest event)

_•_ Caller must be registered master account.


Test coverage: ZkLighter.test.ts::L-836 (implicit — deposit registers
account first)


**Negative behavior**


_•_ Revert when account index is invalid (> MAX_ACCOUNT_INDEX).


Negative test: ZkLighter.test.ts::L-808

_•_ Revert when API key index is invalid (> MAX_API_KEY_INDEX).


Negative test: ZkLighter.test.ts::L-811

_•_ Revert when public key length is incorrect.


Negative test: ZkLighter.test.ts::L-814

_•_ Revert when public key is all zeros.


Negative test: ZkLighter.test.ts::L-817

_•_ Revert when any public key element is >= GOLDILOCKS_MODULUS.


Negative test: ZkLighter.test.ts::L-823

_•_ Revert when caller is not registered.


Negative test: ZkLighter.test.ts::L-831


**Function call analysis**


_•_ getAccountIndexFromAddress(msg.sender)


_•_ **What is controllable?** msg.sender is the caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns master-account index from stored mapping. If NIL_ACCOUNT_INDEX,
reverts. Cannot be manipulated — mapping is set during registration.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
View function, no unusual control flow.

_•_ TxTypes.writeChangePubKeyPubDataForPriorityQueue(_tx)


Zellic © 2026 _←_ **Back to Contents** Page 30 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ **What is controllable?** All _tx struct parameters by caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns encoded bytes for priority queue. Malformed encoding could cause
L2 processing issues.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Library function, no revert conditions.

_•_ addPriorityRequest


_•_ **What is controllable?** pubData derived from user inputs.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — adds to priority queue. Queue corruption could prevent L2
from processing key change.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Internal function, no revert conditions.


**Function:** **registerAsset(uint8** **_l1Decimals,** **uint8** **_decimals,** **bytes32**
**_symbol,** **TxTypes.RegisterAsset** **calldata** **_params)**


Governor-only function to register new assets in ZkLighter. Validates asset parameters and adds a
priority request for L2 registration. Protected by nonReentrant and onlyActive modifiers.


**Inputs**


_•_ _l1Decimals


_•_ **Control** : Governor control.

_•_ **Constraints** : Metadata only — not validated, passed to event/L2.

_•_ **Impact** : L1 decimal count for reference.

_•_ _decimals


_•_ **Control** : Governor control.

_•_ **Constraints** : Metadata only — not validated, passed to event/L2.

_•_ **Impact** : Lighter system decimal count.

_•_ _symbol


_•_ **Control** : Governor control.

_•_ **Constraints** : Metadata only — not validated, passed to event/L2.

_•_ **Impact** : Asset symbol for identification.

_•_ _params (TxTypes.RegisterAsset)


_•_ **Control** : Governor control.

_•_ **Constraints** : Asset must have tokenAddress configured (except
NATIVE_ASSET_INDEX). Extension multiplier must match existing config. L2
amounts must be > 0 and <= MAX_DEPOSIT_CAP_TICKS. Margin mode:


Zellic © 2026 _←_ **Back to Contents** Page 31 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


Enabled for USDC only, Disabled for others.

_•_ **Impact** : Contains assetIndex, extensionMultiplier,

minL2TransferAmount, minL2WithdrawalAmount, marginMode.


**Branches and code coverage**


**Intended branches**


_•_ Asset should be registered successfully with valid parameters.


Test coverage: not tested

_•_ Extension multiplier must match preconfigured value in assetConfigs.


Test coverage: not tested

_•_ USDC must have margin mode Enabled; other assets must have Disabled.


Test coverage: not tested

_•_ Priority request should be added to queue.


Test coverage: not tested


**Negative behavior**


_•_ Revert when caller is not governor.


Negative test: not tested (governor check tested elsewhere)

_•_ Revert when asset index is invalid for non-native assets.


Negative test: not tested

_•_ Revert when extension multiplier does not match config.


Negative test: not tested

_•_ Revert when minL2TransferAmount is 0 or > MAX_DEPOSIT_CAP_TICKS.


Negative test: not tested

_•_ Revert when minL2WithdrawalAmount is 0 or > MAX_DEPOSIT_CAP_TICKS.


Negative test: not tested

_•_ Revert when margin mode is invalid value.


Negative test: not tested

_•_ Revert when margin mode is Enabled for non-USDC asset.


Negative test: not tested

_•_ Revert when margin mode is Disabled for USDC.


Negative test: not tested


Zellic © 2026 _←_ **Back to Contents** Page 32 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Function call analysis**


_•_ governance.requireGovernor(msg.sender)


_•_ **What is controllable?** msg.sender is the caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — reverts if not governor. If bypassed, unauthorized caller
could register malicious assets.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts entire transaction.

_•_ TxTypes.writeRegisterAssetPubDataForPriorityQueue(_params)


_•_ **What is controllable?** All parameters by governor.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns encoded bytes for priority queue. Malformed encoding could cause
L2 processing issues.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Library function, no revert conditions.

_•_ TxTypes.writeRegisterAssetPubDataForPriorityQueueWithMetadata(...)


_•_ **What is controllable?** All parameters by governor.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns encoded bytes with metadata for event emission. Incorrect
encoding could mislead off-chain indexers.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Library function, no revert conditions.

_•_ addPriorityRequest


_•_ **What is controllable?** All data derived from governor inputs.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — adds to priority queue. Queue corruption could prevent L2
from processing asset registration.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Internal function, no revert conditions.


**Function: updateAsset(TxTypes.UpdateAsset** **calldata** **_params)**


Governor-only function to update parameters of existing assets. Validates asset exists and checks
constraints similar to registerAsset. Protected by nonReentrant and onlyActive modifiers.


**Inputs**


_•_ _params (TxTypes.UpdateAsset)


_•_ **Control** : Governor control.


Zellic © 2026 _←_ **Back to Contents** Page 33 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ **Constraints** : Asset index must be valid (see validateAssetIndex). L2
amounts must be > 0 and <= MAX_DEPOSIT_CAP_TICKS. Margin mode:
Enabled for USDC only, Disabled for others.

_•_ **Impact** : Contains assetIndex, minL2TransferAmount,
minL2WithdrawalAmount, marginMode.


**Branches and code coverage**


**Intended branches**


_•_ Asset parameters should be updated successfully with valid parameters.


Test coverage: not tested

_•_ Asset index must be validated before updating.


Test coverage: not tested (validated via validateAssetIndex)

_•_ USDC must have margin mode Enabled; other assets must have Disabled.


Test coverage: not tested

_•_ Priority request should be added to queue.


Test coverage: not tested


**Negative behavior**


_•_ Revert when caller is not governor.


Negative test: not tested (governor check tested elsewhere)

_•_ Revert when asset index is invalid.


Negative test: not tested

_•_ Revert when minL2TransferAmount is 0 or > MAX_DEPOSIT_CAP_TICKS.


Negative test: not tested

_•_ Revert when minL2WithdrawalAmount is 0 or > MAX_DEPOSIT_CAP_TICKS.


Negative test: not tested

_•_ Revert when margin mode is invalid value.


Negative test: not tested

_•_ Revert when margin mode is Enabled for non-USDC asset.


Negative test: not tested

_•_ Revert when margin mode is Disabled for USDC.


Negative test: not tested


Zellic © 2026 _←_ **Back to Contents** Page 34 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Function call analysis**


_•_ governance.requireGovernor(msg.sender)


_•_ **What is controllable?** msg.sender is the caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — reverts if not governor. If bypassed, unauthorized caller
could modify asset parameters.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts entire transaction.

_•_ validateAssetIndex


_•_ **What is controllable?** Asset index by governor.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — reverts if invalid. If bypassed, could update non-existent
assets.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts if asset not configured.

_•_ TxTypes.writeUpdateAssetPubDataForPriorityQueue(_params)


_•_ **What is controllable?** All parameters by governor.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns encoded bytes for priority queue. Malformed encoding could cause
L2 processing issues.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Library function, no revert conditions.

_•_ addPriorityRequest


_•_ **What is controllable?** All data derived from governor inputs.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — adds to priority queue. Queue corruption could prevent L2
from processing asset update.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Internal function, no revert conditions.


**Function:** **createMarket(uint8** **_size_decimals,** **uint8** **_price_decimals,**
**bytes32** **_symbol,** **TxTypes.CreateMarket** **calldata** **_params)**


This function is only available to the governor and allows creation of new markets (perps or spot). It
performs extensive validation of market parameters including fees, margin fractions, interest rates,
and order limits.


**Inputs**


_•_ _size_decimals


Zellic © 2026 _←_ **Back to Contents** Page 35 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ **Control** : Governor control.

_•_ **Constraints** : Metadata only, no direct validation.

_•_ **Impact** : Number of decimals for order size display.

_•_ _price_decimals


_•_ **Control** : Governor control.

_•_ **Constraints** : Metadata only, no direct validation.

_•_ **Impact** : Number of decimals for price display.

_•_ _symbol


_•_ **Control** : Governor control.

_•_ **Constraints** : In bytes32 format, metadata only.

_•_ **Impact** : Market symbol for identification.

_•_ _params


_•_ **Control** : Governor control.

_•_ **Constraints** : Complex validation via ![validateCreateMarketParams].

_•_ **Impact** : Defines the market's operational configuration including fees,
margin requirements, interest rates, order limits, and other type-specific
parameters that will be enforced on-chain.


**Branches and code coverage**


**Intended branches**


_•_ Perps market should be created with valid parameters.


Test coverage: test ZkLighter.test.ts::L-943

_•_ Spot market should be created with valid parameters and different base/quote assets.


Test coverage: test ZkLighter.test.ts::L-1120


**Negative behavior**


_•_ Revert when the caller is not the governor.


Negative test (not explicitly tested)


**Function call analysis**


_•_ governance.requireGovernor(msg.sender)


_•_ **What is controllable?** msg.sender by the caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — reverts if not governor.


Zellic © 2026 _←_ **Back to Contents** Page 36 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Prevents unauthorized market creation.

_•_ validateCreateMarketParams(_params)


_•_ **What is controllable?** All parameters by the governor.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Internal view function with comprehensive validation. Reverts on any invalid
parameter. See ![validateCreateMarketParams] for detailed analysis.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
View function, no reentrancy.


**Function: updateMarket(TxTypes.UpdateMarket** **calldata** **_params)**


This function is only available to the governor and allows updating parameters of existing markets.
It validates market status and parameters similar to createMarket.


**Inputs**


_•_ _params


_•_ **Control** : Governor control.

_•_ **Constraints** : Complex validation via validateUpdateMarketParams.

_•_ **Impact** : Contains marketIndex, marketType, and marketData with updated
parameters.


**Branches and code coverage**


**Intended branches**


_•_ Perps market parameters should be updated successfully.


Test coverage: test ZkLighter.test.ts::L-1270

_•_ Spot market parameters should be updated successfully.


Test coverage: test ZkLighter.test.ts::L-1407

_•_ A priority request should be added to the queue.


Test coverage: Verified in tests ZkLighter.test.ts::L-1270 and
ZkLighter.test.ts::L-1407


**Negative behavior**


_•_ Revert when the caller is not the governor.


Negative test (not explicitly tested)


Zellic © 2026 _←_ **Back to Contents** Page 37 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Function call analysis**


_•_ governance.requireGovernor(msg.sender)


_•_ **What is controllable?** msg.sender is determined by the caller, but the
function reverts if not governor.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — reverts if not governor.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Prevents unauthorized updates.

_•_ validateUpdateMarketParams(_params)


_•_ **What is controllable?** All parameters by the governor.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Internal pure function validates all parameters. Reverts on invalid data. See
![validateUpdateMarketParams] for detailed analysis.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Pure function, no reentrancy.

_•_ TxTypes.writeUpdateMarketPubDataForPriorityQueue(_params)


_•_ **What is controllable?** All parameters by the governor.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Encodes market update data into bytes for the priority queue. Pure function,
deterministic encoding.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Pure function, no reentrancy.

_•_ addPriorityRequest(TxTypes.PriorityPubDataTypeL1UpdateMarket, pubdata,
pubdata)


_•_ **What is controllable?** All encoded data by the governor.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Adds the market update to the priority request queue for L1 processing. See
![addPriorityRequest] for detailed analysis.

_•_ **What happens if it reverts, reenters or does other unusual control flow?** No
revert conditions.


**Function: cancelAllOrders(uint48** **_accountIndex)**


Allows registered users to cancel all orders for a specific account. Adds a priority request to L2 to
cancel all pending orders. Protected by nonReentrant and onlyActive modifiers.


**Inputs**


_•_ _accountIndex


Zellic © 2026 _←_ **Back to Contents** Page 38 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ **Control** : User control (caller must be registered master account).

_•_ **Constraints** : Must be <= MAX_ACCOUNT_INDEX.

_•_ **Impact** : Account whose orders will be canceled.


**Branches and code coverage**


**Intended branches**


_•_ Cancel request should succeed with valid parameters.


Test coverage: ZkLighter.test.ts::L-858

_•_ Priority request should be added to queue.


Test coverage: ZkLighter.test.ts::L-141 (helper verifies
NewPriorityRequest event)

_•_ Caller must be registered master account.


Test coverage: ZkLighter.test.ts::L-857 (implicit — deposit registers
account first)


**Negative behavior**


_•_ Revert when account index is invalid (> MAX_ACCOUNT_INDEX).


Negative test: ZkLighter.test.ts::L-850

_•_ Revert when caller is not registered.


Negative test: ZkLighter.test.ts::L-843


**Function call analysis**


_•_ getAccountIndexFromAddress(msg.sender)


_•_ **What is controllable?** msg.sender is the caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns master-account index from stored mapping. If NIL_ACCOUNT_INDEX,
reverts. Cannot be manipulated — mapping is set during registration.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
View function, no unusual control flow.

_•_ TxTypes.writeCancelAllOrdersPubDataForPriorityQueue(_tx)


_•_ **What is controllable?** accountIndex and masterAccountIndex by caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns encoded bytes for priority queue. Malformed encoding could cause
L2 processing issues.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Library function, no revert conditions.


Zellic © 2026 _←_ **Back to Contents** Page 39 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ addPriorityRequest


_•_ **What is controllable?** pubData derived from user inputs.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — adds to priority queue. Queue corruption could prevent L2
from processing cancellation.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Internal function, no revert conditions.


**Function:** **withdraw(uint48** **_accountIndex,** **uint16** **_assetIndex,** **Tx-**
**Types.RouteType** **_routeType,** **uint64** **_baseAmount)**


Allows registered users to withdraw ETH or ERC-20 assets from ZkLighter. Validates withdrawal
parameters and adds a priority request for L2 processing. Protected by nonReentrant and
onlyActive modifiers.


**Inputs**


_•_ _accountIndex


_•_ **Control** : User control (caller must be registered master account).

_•_ **Constraints** : None on-chain — should be validated by ZK circuit/sequencer
to ensure caller owns the account.

_•_ **Impact** : Account to withdraw from.

_•_ _assetIndex


_•_ **Control** : User control.

_•_ **Constraints** : Must be valid asset index (see validateAssetIndex).
Withdrawals must be enabled for asset.

_•_ **Impact** : Asset to withdraw.

_•_ _routeType


_•_ **Control** : User control.

_•_ **Constraints** : Must be Perps or Spot.

_•_ **Impact** : Route to withdraw from.

_•_ _baseAmount


_•_ **Control** : User control.

_•_ **Constraints** : Must be > 0 and <= depositCapTicks.

_•_ **Impact** : Amount to withdraw in ticks.


**Branches and code coverage**


**Intended branches**


Zellic © 2026 _←_ **Back to Contents** Page 40 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ ETH withdrawals should work correctly.


Test coverage: ZkLighter.test.ts::L-790

_•_ ERC-20 withdrawals should work correctly.


Test coverage: ZkLighter.test.ts::L-762

_•_ Priority request should be added to queue.


Test coverage: ZkLighter.test.ts::L-94 (helper verifies
NewPriorityRequest event)

_•_ Caller must be registered master account.


Test coverage: ZkLighter.test.ts::L-761 (implicit — deposit registers
account first)


**Negative behavior**


_•_ Revert when asset index is invalid.


Negative test: ZkLighter.test.ts::L-798

_•_ Revert when withdrawals are not enabled for asset.


Negative test: ZkLighter.t.sol::L-261 (LIT withdrawals disabled initially)

_•_ Revert when amount is 0 or > depositCapTicks.


Negative test: ZkLighter.test.ts::L-743 (amount = 0),
ZkLighter.test.ts::L-749 (amount too large)

_•_ Revert when route type is not Perps or Spot.


Negative test: ZkLighter.test.ts::L-752

_•_ Revert when caller is not registered.


Negative test: ZkLighter.test.ts::L-754


**Function call analysis**


_•_ getAccountIndexFromAddress(msg.sender)


_•_ **What is controllable?** msg.sender is the caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns master-account index from stored mapping. If NIL_ACCOUNT_INDEX,
reverts. Cannot be manipulated — mapping is set during registration.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
View function, no unusual control flow.

_•_ TxTypes.writeWithdrawPubDataForPriorityQueue(_tx)


_•_ **What is controllable?** All _tx struct parameters by caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns encoded bytes for priority queue. Malformed encoding could cause


Zellic © 2026 _←_ **Back to Contents** Page 41 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


L2 withdrawal processing issues.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Library function, no revert conditions.

_•_ addPriorityRequest


_•_ **What is controllable?** pubData derived from user inputs.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — adds to priority queue. Queue corruption could prevent L2
from processing withdrawal.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Internal function, no revert conditions.


**Function: createOrder(uint48** **_accountIndex,** **uint16** **_marketIndex,** **uint48**
**_baseAmount,** **uint32** **_price,** **uint8** **_isAsk,** **uint8** **_orderType)**


Allows registered users to create orders (limit or market) on ZkLighter perps markets. Validates all
order parameters before adding to priority queue. Protected by nonReentrant and onlyActive
modifiers.


**Inputs**


_•_ _accountIndex


_•_ **Control** : User control (caller must be registered master account).

_•_ **Constraints** : Must be <= MAX_ACCOUNT_INDEX.

_•_ **Impact** : Account placing the order.

_•_ _marketIndex


_•_ **Control** : User control.

_•_ **Constraints** : Must be <= MAX_PERPS_MARKET_INDEX.

_•_ **Impact** : Perps market to trade on.

_•_ _baseAmount


_•_ **Control** : User control.

_•_ **Constraints** : Must be NIL_ORDER_BASE_AMOUNT or in range

[MIN_ORDER_BASE_AMOUNT, MAX_ORDER_BASE_AMOUNT].

_•_ **Impact** : Order size in base units.

_•_ _price


_•_ **Control** : User control.

_•_ **Constraints** : Must be in range [MIN_ORDER_PRICE, MAX_ORDER_PRICE].

_•_ **Impact** : Order price.

_•_ _isAsk


Zellic © 2026 _←_ **Back to Contents** Page 42 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ **Control** : User control.

_•_ **Constraints** : Must be 0 or 1.

_•_ **Impact** : Order side (0 = bid, 1 = ask).

_•_ _orderType


_•_ **Control** : User control.

_•_ **Constraints** : Must be LimitOrder (1) or MarketOrder (2).

_•_ **Impact** : Type of order to create.


**Branches and code coverage**


**Intended branches**


_•_ Order should be created successfully with valid parameters.


Test coverage: ZkLighter.test.ts::L-899

_•_ Market orders should be created successfully.


Test coverage: not tested (only limit orders tested)

_•_ NIL_ORDER_BASE_AMOUNT should be accepted as special value.


Test coverage: not tested

_•_ Priority request should be added to queue.


Test coverage: ZkLighter.test.ts::L-207 (helper verifies
NewPriorityRequest event)

_•_ Caller must be registered master account.


Test coverage: ZkLighter.test.ts::L-898 (implicit — deposit registers
account first)


**Negative behavior**


_•_ Revert when account index is invalid (> MAX_ACCOUNT_INDEX).


Negative test: ZkLighter.test.ts::L-867

_•_ Revert when market index is invalid (> MAX_PERPS_MARKET_INDEX).


Negative test: ZkLighter.test.ts::L-891

_•_ Revert when base amount is invalid (not NIL and outside valid range).


Negative test: not tested

_•_ Revert when price is outside valid range.


Negative test: ZkLighter.test.ts::L-879 (price = 0 rejected)

_•_ Revert when isAsk is not 0 or 1.


Negative test: ZkLighter.test.ts::L-873


Zellic © 2026 _←_ **Back to Contents** Page 43 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ Revert when order type is not LimitOrder or MarketOrder.


Negative test: ZkLighter.test.ts::L-885

_•_ Revert when caller is not registered.


Negative test: not tested


**Function call analysis**


_•_ getAccountIndexFromAddress(msg.sender)


_•_ **What is controllable?** msg.sender is the caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns master-account index from stored mapping. If NIL_ACCOUNT_INDEX,
reverts. Cannot be manipulated — mapping is set during registration.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
View function, no unusual control flow.

_•_ TxTypes.writeCreateOrderPubDataForPriorityQueue(_tx)


_•_ **What is controllable?** All _tx struct parameters by caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns encoded bytes for priority queue. Malformed encoding could cause
L2 order processing issues.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Library function, no revert conditions.

_•_ addPriorityRequest


_•_ **What is controllable?** pubData derived from user inputs.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — adds to priority queue. Queue corruption could prevent L2
from processing order.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Internal function, no revert conditions.


**Function:** **burnShares(uint48** **_accountIndex,** **uint48** **_publicPoolIndex,**
**uint64** **_shareAmount)**


Allows registered users to burn shares of a public pool. Validates pool and share parameters
before adding to priority queue. Protected by nonReentrant and onlyActive modifiers.


**Inputs**


_•_ _accountIndex


_•_ **Control** : User control (caller must be registered master account).


Zellic © 2026 _←_ **Back to Contents** Page 44 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ **Constraints** : Must be <= MAX_ACCOUNT_INDEX. Cannot equal
_publicPoolIndex.

_•_ **Impact** : Account burning shares.

_•_ _publicPoolIndex


_•_ **Control** : User control.

_•_ **Constraints** : Must be in range (MAX_MASTER_ACCOUNT_INDEX,
MAX_ACCOUNT_INDEX]. Cannot equal _accountIndex.

_•_ **Impact** : Public pool to burn shares from.

_•_ _shareAmount


_•_ **Control** : User control.

_•_ **Constraints** : Must be in range [MIN_POOL_SHARES_TO_MINT_OR_BURN,
MAX_POOL_SHARES_TO_MINT_OR_BURN].

_•_ **Impact** : Amount of shares to burn.


**Branches and code coverage**


**Intended branches**


_•_ Shares should be burned successfully with valid parameters.


Test coverage: ZkLighter.test.ts::L-939

_•_ Priority request should be added to queue.


Test coverage: ZkLighter.test.ts::L-236 (helper verifies
NewPriorityRequest event)

_•_ Caller must be registered master account.


Test coverage: ZkLighter.test.ts::L-937 (implicit — deposit registers
account first)


**Negative behavior**


_•_ Revert when account index is invalid (> MAX_ACCOUNT_INDEX).


Negative test: ZkLighter.test.ts::L-910

_•_ Revert when account index equals pool index.


Negative test: not tested

_•_ Revert when pool index is <= MAX_MASTER_ACCOUNT_INDEX.


Negative test: ZkLighter.test.ts::L-916

_•_ Revert when pool index is > MAX_ACCOUNT_INDEX.


Negative test: ZkLighter.test.ts::L-921

_•_ Revert when share amount is < MIN_POOL_SHARES_TO_MINT_OR_BURN.


Zellic © 2026 _←_ **Back to Contents** Page 45 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


Negative test: ZkLighter.test.ts::L-926

_•_ Revert when share amount is > MAX_POOL_SHARES_TO_MINT_OR_BURN.


Negative test: ZkLighter.test.ts::L-932

_•_ Revert when caller is not registered.


Negative test: not tested


**Function call analysis**


_•_ getAccountIndexFromAddress(msg.sender)


_•_ **What is controllable?** msg.sender is the caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns master-account index from stored mapping. If NIL_ACCOUNT_INDEX,
reverts. Cannot be manipulated — mapping is set during registration.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
View function, no unusual control flow.

_•_ TxTypes.writeBurnSharesPubDataForPriorityQueue(_tx)


_•_ **What is controllable?** All _tx struct parameters by caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns encoded bytes for priority queue. Malformed encoding could cause
L2 share burning issues.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Library function, no revert conditions.

_•_ addPriorityRequest


_•_ **What is controllable?** pubData derived from user inputs.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — adds to priority queue. Queue corruption could prevent L2
from processing share burn.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Internal function, no revert conditions.


**Function:** **_deposit(address[]** **memory** **_to,** **uint16** **_assetIndex,** **Tx-**
**Types.RouteType** **_routeType,** **uint256[]** **memory** **_amount)**


This is an internal function that implements the core deposit logic for both single and batch
deposits. It handles ETH and ERC-20 transfers, validates amounts against tick sizes and caps, and
handles fee-on-transfer tokens.


Zellic © 2026 _←_ **Back to Contents** Page 46 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Inputs**


_•_ _to


_•_ **Control** : User control (via deposit() and depositBatch()).

_•_ **Constraints** : Each address must not be address(0). Array length must
match _amount.

_•_ **Impact** : Recipient addresses for deposits.

_•_ _assetIndex


_•_ **Control** : User control (via deposit() and depositBatch()).

_•_ **Constraints** : Must be valid (NATIVE_ASSET_INDEX or configured ERC-20). See
validateAssetIndex.

_•_ **Impact** : Determines asset type and configuration.

_•_ _routeType


_•_ **Control** : User control (via deposit() and depositBatch()).

_•_ **Constraints** : Type-safe enum (RouteType).

_•_ **Impact** : Routes deposit to perps or spot.

_•_ _amount


_•_ **Control** : User control (via deposit() and depositBatch()).

_•_ **Constraints** : Each amount must be >= minDeposit, aligned with tickSize,
and sum must not exceed depositCap.

_•_ **Impact** : Amounts to deposit for each recipient.


**Branches and code coverage**


**Intended branches**


_•_ Native asset (ETH) deposits should succeed when msg.value matches totalAmount.


Test coverage: ZkLighter.t.sol::L-156
(test_deposit_eth_fail_and_success)

_•_ ERC-20 deposits should work with exact amounts.


Test coverage: ZkLighter.t.sol::L-101
(test_deposit_usdc_fail_and_success)

_•_ Account should be auto-registered if depositing to unregistered address.


Test coverage: ZkLighter.test.ts::L-701 (via registerDeposit)

_•_ Deposit should be added to priority queue.


Test coverage: ZkLighter.test.ts::L-711 (NewPriorityRequest event, via

registerDeposit)


**Negative behavior**


Zellic © 2026 _←_ **Back to Contents** Page 47 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ Revert when non-native asset has no configured tokenAddress.


Negative test: ZkLighter.t.sol::L-110

_•_ Revert when depositing ERC-20 with nonzero msg.value.


Negative test: ZkLighter.t.sol::L-126

_•_ Revert when amount is < minDeposit or not aligned with tickSize.


Negative test: ZkLighter.t.sol::L-122

_•_ Revert when recipient is address(0).


Negative test: ZkLighter.test.ts::L-686

_•_ Revert when ETH msg.value != totalAmount.


Negative test: ZkLighter.t.sol::L-172

_•_ Revert when ERC-20 transfer results in less balance than expected.


Negative test: not explicitly tested (fee-on-transfer tokens)

_•_ Revert when balanceAfter exceeds depositCap.


Negative test: ZkLighter.test.ts::L-692


**Function call analysis**


_•_ IERC20(assetConfig.tokenAddress).balanceOf(address(this))


_•_ **What is controllable?** Nothing — reads contract's balance.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Used to calculate the actual received amount.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
External view call. If a token has a malicious balanceOf, it could cause issues
but is protected by asset whitelisting.

_•_ SafeERC20.safeTransferFrom(_token, msg.sender, address(this),
totalAmount)


_•_ **What is controllable?** Caller controls msg.sender and amount (validated).

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — reverts on failure. Handles nonstandard ERC-20s.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts entire transaction. Reentrancy protected at external function level.

_•_ increaseBalanceToWithdraw(TREASURY_ACCOUNT_INDEX, _assetIndex,
baseExcessAmount)


_•_ **What is controllable?** baseExcessAmount is calculated from the actual
received amount (excess from fee-on-transfer tokens).

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — updates pendingBalances mapping. If excess calculation


Zellic © 2026 _←_ **Back to Contents** Page 48 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


is wrong, treasury gets incorrect credit.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Internal function, no reentrancy risk. Could overflow if balance exceeds
uint128, but unlikely with validated inputs.

_•_ registerDeposit(_to[i], _assetIndex, _routeType, baseAmount)


_•_ **What is controllable?** All parameters derived from validated inputs.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — adds deposit to priority queue for L2 processing. Data
encoding is deterministic from validated inputs, so malformed data is unlikely.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Could revert if lastAccountIndex exceeds MAX_ACCOUNT_INDEX (2^48 - 2),
but practically impossible to reach.


**Function:** **validateCommonPerpMarketParams(TxTypes.CommonPerpsData** **mem-**
**ory** **perpParams)**


This is an internal pure function that validates common parameters for perps markets including
fees, margin fractions, interest rates, funding clamps, and order limits.


**Inputs**


_•_ perpParams


_•_ **Control** : Called by validateCreateMarketParams and
validateUpdateMarketParams with governor-provided data.

_•_ **Constraints** : Complex hierarchy of constraints. Fees are <= FEE_TICK,
margin fractions are in proper order (closeOut < maintenance <
minInitial < defaultInitial <= MARGIN_TICK), the interest rate is <=
FUNDING_RATE_TICK, funding clamps are <= FUNDING_RATE_TICK, minimum
amounts are in valid ranges, the order quote limit is >= minQuoteAmount, and
the open interest limit is >= orderQuoteLimit.

_•_ **Impact** : Defines core economic parameters for perps market.


**Branches and code coverage**


**Intended branches**


_•_ Fees (maker, taker, liquidation) should be validated as <= FEE_TICK.


Test coverage: ZkLighter.test.ts::L-943 (create) and
ZkLighter.test.ts::L-1270 (update)

_•_ Margin fraction hierarchy should be enforced.


Test coverage: ZkLighter.test.ts::L-943 (create) and


Zellic © 2026 _←_ **Back to Contents** Page 49 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


ZkLighter.test.ts::L-1270 (update)

_•_ Interest rate should be <= FUNDING_RATE_TICK.


Test coverage: ZkLighter.test.ts::L-943 (create) and
ZkLighter.test.ts::L-1270 (update)

_•_ Funding clamps should be <= FUNDING_RATE_TICK.


Test coverage: not explicitly tested

_•_ Minimum base/quote amounts should be > 0 and within limits.


Test coverage: ZkLighter.test.ts::L-943 (create) and
ZkLighter.test.ts::L-1270 (update)

_•_ Order quote limit and open interest limit should be within valid ranges.


Test coverage: ZkLighter.test.ts::L-943 (create) and
ZkLighter.test.ts::L-1270 (update)


**Negative behavior**


_•_ Revert when makerFee                           - FEE_TICK.


Negative test: ZkLighter.test.ts::L-1008

_•_ Revert when takerFee                           - FEE_TICK.


Negative test: ZkLighter.test.ts::L-1016

_•_ Revert when liquidationFee                           - FEE_TICK.


Negative test: ZkLighter.test.ts::L-1025

_•_ Revert when closeOutMarginFraction is 0.


Negative test: ZkLighter.test.ts::L-1037

_•_ Revert when closeOut >= maintenance.


Negative test: ZkLighter.test.ts::L-1044

_•_ Revert when maintenance >= minInitial.


Negative test: ZkLighter.test.ts::L-1051

_•_ Revert when minInitial >= defaultInitial.


Negative test: ZkLighter.test.ts::L-1059

_•_ Revert when defaultInitial                           - MARGIN_TICK.


Negative test: ZkLighter.test.ts::L-1068

_•_ Revert when interestRate                           - FUNDING_RATE_TICK.


Negative test: ZkLighter.test.ts::L-1079

_•_ Revert when funding clamps are invalid.


Negative test: not explicitly tested

_•_ Revert when minBaseAmount is 0 or > MAX_ORDER_BASE_AMOUNT.


Zellic © 2026 _←_ **Back to Contents** Page 50 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


Negative test: ZkLighter.test.ts::L-1102

_•_ Revert when minQuoteAmount is 0 or > MAX_ORDER_QUOTE_AMOUNT.


Negative test: ZkLighter.test.ts::L-1109

_•_ Revert when order quote limit is invalid.


Negative test: not explicitly tested

_•_ Revert when open interest limit is invalid.


Negative test: not explicitly tested


**Function call analysis**


No external or internal function calls (pure validation logic).


**Function:** **validateCommonSpotMarketParams(TxTypes.CommonSpotData** **memory**
**spotParams)**


This is an internal pure function that validates common parameters for spot markets, including fees
and order limits.


**Inputs**


_•_ spotParams


_•_ **Control** : Called by validateCreateMarketParams and
validateUpdateMarketParams with governor-provided data.

_•_ **Constraints** : Fees are <= FEE_TICK, minimum amounts are in valid ranges,
and order quote limit is >= minQuoteAmount and <=
MAX_ORDER_QUOTE_AMOUNT.

_•_ **Impact** : Defines fee structure and order limits for the spot market.


**Branches and code coverage**


**Intended branches**


_•_ Fees (maker, taker) should be validated as <= FEE_TICK.


Test coverage: ZkLighter.test.ts::L-1120 (create) and
ZkLighter.test.ts::L-1407 (update)

_•_ Minimum base/quote amounts should be > 0 and within limits.


Test coverage: ZkLighter.test.ts::L-1120 (create) and
ZkLighter.test.ts::L-1407 (update)

_•_ Order quote limit should be within valid range.


Zellic © 2026 _←_ **Back to Contents** Page 51 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


Test coverage: ZkLighter.test.ts::L-1120 (create) and
ZkLighter.test.ts::L-1407 (update)


**Negative behavior**


_•_ Revert when makerFee                           - FEE_TICK.


Negative test: ZkLighter.test.ts::L-1230

_•_ Revert when takerFee                           - FEE_TICK.


Negative test: ZkLighter.test.ts::L-1237

_•_ Revert when minBaseAmount is 0 or > MAX_ORDER_BASE_AMOUNT.


Negative test: ZkLighter.test.ts::L-1253

_•_ Revert when minQuoteAmount is 0 or > MAX_ORDER_QUOTE_AMOUNT.


Negative test: ZkLighter.test.ts::L-1259

_•_ Revert when orderQuoteLimit                           - MAX_ORDER_QUOTE_AMOUNT.


Negative test: not explicitly tested

_•_ Revert when minQuoteAmount                           - orderQuoteLimit.


Negative test: Implicit via minimum-amounts validation


**Function call analysis**


No external or internal function calls (pure validation logic).


**Function:** **validateCreateMarketParams(TxTypes.CreateMarket** **calldata**
**_params)**


This is an internal view function that performs comprehensive validation of market creation
parameters.


**Inputs**


_•_ _params (TxTypes.CreateMarket)


_•_ **Control** : Called by createMarket() with governor-provided data.

_•_ **Type** : TxTypes.CreateMarket struct containing:


_•_ marketIndex (uint16): Market identifier, must be within valid range
for market type

_•_ marketType (MarketType enum): Either Perps or Spot

_•_ marketData (bytes): Packed data that gets decoded based on
marketType


Zellic © 2026 _←_ **Back to Contents** Page 52 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


                                                                            - For perps: Decoded into CreateMarketPerpsData
containing quoteMultiplier (uint32) and common
(CommonPerpsData with fees, margins, rates, limits)

                                                                            - For spot: Decoded into CreateMarketSpotData
containing baseAssetIndex (uint16), quoteAssetIndex
(uint16), sizeExtensionMultiplier (uint56),
quoteExtensionMultiplier (uint56), and common
(CommonSpotData with fees, minimum amounts, order
limits)

_•_ **Constraints** : Validation depends on market type. For perps: market index
must be <= MAX_PERPS_MARKET_INDEX, quote multiplier must be > 0 and <=

MAX_QUOTE_MULTIPLIER, and common perps params (fees, margins, rates,
limits) must be validated. For spot: market index must be in

[MIN_SPOT_MARKET_INDEX, MAX_SPOT_MARKET_INDEX], base and quote assets
must be different and both must exist (validated via validateAssetIndex),
extension multipliers must be > 0, <= MAX_ASSET_EXTENSION_MULTIPLIER,
and divisible by FEE_TICK, and common spot params (fees, minimum
amounts, order limits) must be validated.

_•_ **Impact** : Determines if market creation should proceed.


**Branches and code coverage**


**Intended branches**


_•_ Perps market parameters should be fully validated including index, quote multiplier, and
common params.


Test coverage: test ZkLighter.test.ts::L-943

_•_ Spot market parameters should be fully validated including index range, asset indexes,
extension multipliers, and common params.


Test coverage: test ZkLighter.test.ts::L-1120

_•_ Base and quote assets must be different for spot markets.


Test coverage: Verified in test ZkLighter.test.ts::L-1120 (creates market
with different assets)

_•_ Both assets must exist (validated via validateAssetIndex).


Test coverage: ZkLighter.test.ts::L-1148

_•_ Extension multipliers must be greater than zero, <=

MAX_ASSET_EXTENSION_MULTIPLIER, and divisible by FEE_TICK.


Test coverage: ZkLighter.test.ts::L-1187 and
ZkLighter.test.ts::L-1207


**Negative behavior**


_•_ Revert when the perps market index is > MAX_PERPS_MARKET_INDEX.


Zellic © 2026 _←_ **Back to Contents** Page 53 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


Negative test: ZkLighter.test.ts::L-966

_•_ Revert when the perps quote multiplier is 0 or > MAX_QUOTE_MULTIPLIER.


Negative test: ZkLighter.test.ts::L-986

_•_ Revert when the spot market index is < MIN_SPOT_MARKET_INDEX.


Negative test: ZkLighter.test.ts::L-1167

_•_ Revert when the spot market index is > MAX_SPOT_MARKET_INDEX.


Negative test: ZkLighter.test.ts::L-1177

_•_ Revert when the spot base and quote assets are the same.


Negative test: ZkLighter.test.ts::L-1137

_•_ Revert when the base or quote asset index is invalid.


Negative test: ZkLighter.test.ts::L-1148

_•_ Revert when the size extension multiplier is 0, > MAX_ASSET_EXTENSION_MULTIPLIER, or
not divisible by FEE_TICK.


Negative test: ZkLighter.test.ts::L-1207

_•_ Revert when the quote extension multiplier is 0, > MAX_ASSET_EXTENSION_MULTIPLIER,
or not divisible by FEE_TICK.


Negative test: ZkLighter.test.ts::L-1191

_•_ Revert when the market type is invalid.


Negative test (not explicitly tested)

_•_ Revert for any common param validation failures (delegated to validation functions).


Negative test: Extensively tested (fees, margins, rates, etc.)


**Function call analysis**


_•_ TxTypes.readCreateMarketPerpsData(_params.marketData)


_•_ **What is controllable?** marketData bytes by the governor.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Decodes packed bytes into CreateMarketPerpsData struct containing
quoteMultiplier and common (CommonPerpsData). The decoded values are
then used for validation checks. If bytes length is incorrect, function reverts
with "Invalid packed create market perps data length". Successfully decoded
but invalid values are caught by subsequent validation. Pure library function,
deterministic decoding.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts if _data.length != PACKED_CREATE_MARKET_PERPS_BYTES.

_•_ TxTypes.readCreateMarketSpotData(_params.marketData)


_•_ **What is controllable?** marketData bytes by the governor.


Zellic © 2026 _←_ **Back to Contents** Page 54 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Decodes packed bytes into CreateMarketSpotData struct containing
baseAssetIndex, quoteAssetIndex, sizeExtensionMultiplier,
quoteExtensionMultiplier, and common (CommonSpotData). The decoded
values are then used for validation checks. If bytes length is incorrect,
function reverts with "Invalid packed create market spot data length".
Successfully decoded but invalid values are caught by subsequent validation.
Pure library function, deterministic decoding.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts if _data.length != PACKED_CREATE_MARKET_SPOT_BYTES.

_•_ validateCommonPerpMarketParams(perpParams.common)


_•_ **What is controllable?** perpParams by the governor.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — reverts on invalid params. See
validateCommonPerpMarketParams for detailed analysis.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts with specific error codes causing the calling function to revert and
preventing market creation.

_•_ validateAssetIndex(spotParams.baseAssetIndex) and
validateAssetIndex(spotParams.quoteAssetIndex)


_•_ **What is controllable?** Asset indexes by the governor.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — reverts if asset is invalid. Called separately for base and
quote assets. See validateAssetIndex for detailed analysis.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
View function, no reentrancy.

_•_ validateCommonSpotMarketParams(spotParams.common)


_•_ **What is controllable?** spotParams by the governor.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value, reverts on invalid params. See
validateCommonSpotMarketParams for detailed analysis.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts with specific error codes, causing the calling function to revert and
preventing market creation.


**Function:** **validateUpdateMarketParams(TxTypes.UpdateMarket** **calldata**
**_params)**


This is an internal pure function that validates market-update parameters. It is similar to
validateCreateMarketParams but also checks that the market status is ACTIVE or NONE.


Zellic © 2026 _←_ **Back to Contents** Page 55 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Inputs**


_•_ _params


_•_ **Control** : Called by updateMarket() with governor-provided data.

_•_ **Constraints** : Market index must be valid for type. Status must be ACTIVE or
NONE. All other params validated are the same as createMarket.

_•_ **Impact** : Determines if market update should proceed.


**Branches and code coverage**


**Intended branches**


_•_ Perps-market updates should validate index, status, and common params.


Test coverage: ZkLighter.test.ts::L-1270 (perps update tests)

_•_ Spot-market updates should validate index range, status, and common params.


Test coverage: ZkLighter.test.ts::L-1407 (spot update tests)


**Negative behavior**


_•_ Revert when perps-market index is invalid.


Negative test: ZkLighter.test.ts::L-1291

_•_ Revert when perps status is not ACTIVE or NONE.


Negative test: ZkLighter.test.ts::L-1307

_•_ Revert when spot-market index is out of range.


Negative test: ZkLighter.test.ts::L-1419

_•_ Revert when spot status is not ACTIVE or NONE.


Negative test: ZkLighter.test.ts::L-1435

_•_ Revert when market type is invalid.


Negative test: not explicitly tested

_•_ Revert for invalid fees.


Negative test: ZkLighter.test.ts::L-1315

_•_ Revert for invalid margin requirements.


Negative test: ZkLighter.test.ts::L-1337

_•_ Revert for invalid interest rate.


Negative test: ZkLighter.test.ts::L-1372

_•_ Revert for invalid min amounts.


Negative test: ZkLighter.test.ts::L-1385


Zellic © 2026 _←_ **Back to Contents** Page 56 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Function call analysis**


Decodes market data via TxTypes.readUpdateMarketPerpsData or
TxTypes.readUpdateMarketSpotData, then delegates to validateCommonPerpMarketParams or
validateCommonSpotMarketParams. All pure functions.


**Function:** **registerDeposit(address** **_toAddress,** **uint16** **_assetIndex,** **Tx-**
**Types.RouteType** **_routeType,** **uint64** **_baseAmount)**


This is an internal function that handles account registration (if needed) and adds a deposit to
priority queue. It is critical for managing account indexes and the L1 →L2 deposit flow.


**Inputs**


_•_ _toAddress


_•_ **Control** : User control (provided via _deposit).

_•_ **Constraints** : If the address maps to a system account (index <=
MAX_SYSTEM_ACCOUNT_INDEX), it is reset to address(0) within this function. If
the address is not registered (NIL_ACCOUNT_INDEX), a new account is
auto-registered up to the MAX_MASTER_ACCOUNT_INDEX limit.

_•_ **Impact** : Recipient address for deposit — may trigger account registration or
address reset for system accounts.

_•_ _assetIndex


_•_ **Control** : User control (provided via _deposit).

_•_ **Constraints** : Already validated in _deposit to ensure the asset exists (either
NATIVE_ASSET_INDEX or a registered token asset). See _deposit for detailed
validation.

_•_ **Impact** : Asset being deposited.

_•_ _routeType


_•_ **Control** : User control (provided via _deposit).

_•_ **Constraints** : Type-safe enum (TxTypes.RouteType) with values Perps (0) or
Spot (1). No explicit runtime validation in _deposit, but enum type prevents
invalid values at compile time.

_•_ **Impact** : Routing of deposit on L2 (perps or spot market).

_•_ _baseAmount


_•_ **Control** : Derived from user-provided amounts (calculated by _deposit).

_•_ **Constraints** : Converted from token amount to base units. Original amount is
validated for minimum deposit, divisibility by tick size, and deposit cap limits
in _deposit.

_•_ **Impact** : Amount deposited in base units (uint64).


Zellic © 2026 _←_ **Back to Contents** Page 57 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Branches and code coverage**


**Intended branches**


_•_ Existing accounts should use their existing account index.


Test coverage: test ZkLighter.test.ts::L-252

_•_ System accounts (index <= MAX_SYSTEM_ACCOUNT_INDEX) should have the address set
to address(0).


Test coverage: test ZkLighter.test.ts::L-710 (treasury) and
ZkLighter.test.ts::L-715 (insurance fund)

_•_ New accounts (NIL_ACCOUNT_INDEX) should autoregister with incremented
lastAccountIndex.


Test coverage: test ZkLighter.test.ts::L-252 (first-time deposit)

_•_ A priority request should be added with correct deposit data.


Test coverage: Verified in test ZkLighter.test.ts::L-252 via
NewPriorityRequest event


**Negative behavior**


_•_ None (validation in _deposit).


**Function call analysis**


_•_ getAccountIndexFromAddress(_toAddress)


_•_ **What is controllable?** _toAddress by the user.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns the stored mapping value from addressToAccountIndex. Returns
NIL_ACCOUNT_INDEX if address is not registered. The return value directly
controls critical logic: if <= MAX_SYSTEM_ACCOUNT_INDEX, address is reset to
address(0); if NIL_ACCOUNT_INDEX, triggers auto-registration; otherwise
uses existing index. If the mapping contains unexpected values (e.g.,
corrupted state), it could cause incorrect account handling, wrong address
assignments, or unintended account registration. Additionally, if a user
provides an address that maps to a system account index, the deposit
address will be reset to address(0), which may not be the intended behavior.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
View function, no unusual control flow.

_•_ TxTypes.writeDepositPubDataForPriorityQueue(_tx)


_•_ **What is controllable?** All transaction parameters are derived from validated
inputs and internal state.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Encodes deposit data into packed bytes for the priority queue. The encoded


Zellic © 2026 _←_ **Back to Contents** Page 58 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


bytes are then passed to addPriorityRequest for L2 processing. Pure library
function, deterministic encoding.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Pure function, no revert conditions.

_•_ addPriorityRequest(TxTypes.PriorityPubDataTypeL1Deposit, pubData,

pubData)


_•_ **What is controllable?** pubData derived from validated inputs.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Adds the deposit to the priority request queue for L2 processing. See
addPriorityRequest for detailed analysis.

_•_ **What happens if it reverts, reenters or does other unusual control flow?** No
revert conditions.


**Function:** **addPriorityRequest(uint8** **_pubdataType,** **bytes** **memory** **_priori-**
**tyRequest,** **bytes** **memory** **_pubDataWithMetadata)**


This is a critical internal function that adds requests to the priority queue for L2 processing. It
creates a cryptographic hash chain (prefixHash) to ensure request ordering and integrity. It sets
expiration timestamps for requests.


**Inputs**


_•_ _pubdataType


_•_ **Control** : Called by various functions with fixed type constants.

_•_ **Constraints** : Should be one of the predefined PriorityPubDataType
constants.

_•_ **Impact** : Identifies the type of priority operation (deposit, market creation,
order creation, etc.).

_•_ _priorityRequest


_•_ **Control** : Encoded data from calling functions.

_•_ **Constraints** : Padded to MAX_PRIORITY_REQUEST_PUBDATA_SIZE bytes. Used
for hash-chain creation.

_•_ **Impact** : The actual request data hashed and stored.

_•_ _pubDataWithMetadata


_•_ **Control** : Encoded data from calling functions — may include additional
metadata.

_•_ **Constraints** : Only used for event emission, not stored.

_•_ **Impact** : Request data emitted in event for off-chain processing.


Zellic © 2026 _←_ **Back to Contents** Page 59 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Branches and code coverage**


**Intended branches**


_•_ Priority request should be added with correct hash chain and expiration.


Test coverage: Implicit via all priority-request operations (e.g.,
ZkLighter.test.ts::L-95)

_•_ PrefixHash should be Keccak-256 of (previous prefixHash || padded pubdata).


Test coverage: ZkLighter.t.sol::L-502 (hash validation in desert mode
test)

_•_ NewPriorityRequest event should be emitted.


Test coverage: ZkLighter.test.ts::L-95, L-119, L-140, etc.

_•_ openPriorityRequestCount should be incremented.


Test coverage: ZkLighter.test.ts::L-1479 and L-1513


**Negative behavior**


_•_ None (internal function with validated inputs from calling functions).


**Function call analysis**


Minimal external calls — only SafeCast.toUint64 for safe timestamp conversion. Rest is direct
storage updates, hash computation, and event emission.


**Function:** **increaseBalanceToWithdraw(uint48** **_masterAccountIndex,** **uint16**
**_assetIndex,** **uint128** **_baseAmount)**


This is an internal function that increases the withdrawable balance for an account. It is called by
_deposit when handling excess tokens from ERC-20 transfers (excess goes to treasury).


**Inputs**


_•_ _masterAccountIndex


_•_ **Control** : Called by _deposit with TREASURY_ACCOUNT_INDEX for excess
amounts.

_•_ **Constraints** : Should be a valid master-account index.

_•_ **Impact** : The account whose withdrawable balance increases.

_•_ _assetIndex


_•_ **Control** : From _deposit — already validated.

_•_ **Constraints** : Should be a valid asset index.


Zellic © 2026 _←_ **Back to Contents** Page 60 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ **Impact** : The asset whose balance increases.

_•_ _baseAmount


_•_ **Control** : Calculated by _deposit from excess token amount.

_•_ **Constraints** : Must fit in uint128. Added to existing balance.

_•_ **Impact** : Amount to add to withdrawable balance.


**Branches and code coverage**


**Intended branches**


_•_ Balance should be increased by the specified amount.


Test coverage: Identical implementation in ZkLighter.sol tested via
executeBatches (ZkLighter.t.sol::L-627, assertion at L-636)


**Negative behavior**


_•_ None (internal function with validated inputs from _deposit).


**Function call analysis**


No external or internal function calls (direct storage update).


**Function: validateAssetIndex(uint16** **_assetIndex)**


This is a simple internal view function that validates that an asset index exists in the system
configuration. It is used to ensure operations only reference configured assets.


**Inputs**


_•_ _assetIndex


_•_ **Control** : From calling functions (typically governor or validated user input).

_•_ **Constraints** : Must be NATIVE_ASSET_INDEX or have a configured
tokenAddress.

_•_ **Impact** : Asset being validated for existence.


**Branches and code coverage**


**Intended branches**


_•_ NATIVE_ASSET_INDEX should always be considered valid.


Test coverage: Implicit via depositNative calls (e.g.,


Zellic © 2026 _←_ **Back to Contents** Page 61 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


ZkLighter.test.ts::L-723)

_•_ Non-native assets should be validated by checking tokenAddress != address(0).


Test coverage: Implicit via depositUSDC calls (e.g.,
ZkLighter.test.ts::L-698)


**Negative behavior**


_•_ Revert when non-native asset has tokenAddress == address(0).


Negative test: ZkLighter.test.ts::L-798 (invalid asset in withdraw) and
ZkLighter.test.ts::L-1151 (invalid base asset in spot market) and
ZkLighter.test.ts::L-1160 (invalid quote asset in spot market)


**Function call analysis**


No external or internal function calls (simple storage read and comparison).


5.2. Module: ZkLighter.sol


**Function: initialize(bytes** **calldata** **initializationParameters)**


This is a contract initialization function that sets up governance, verifiers, and genesis state roots
and registers default asset configurations (ETH and USDC). It can only be called once on a proxy,
not on the implementation.


**Inputs**


_•_ initializationParameters


_•_ **Control** : Deployer control during deployment.

_•_ **Constraints** : Must decode to (governanceAddress, verifierAddress,
additionalZkLighter, desertVerifier, genesisStateRoot,
genesisValidiumRoot). All addresses must have code deployed.

_•_ **Impact** : Initializes critical contract dependencies and genesis state.


**Branches and code coverage**


**Intended branches**


_•_ Should decode all six parameters correctly from initializationParameters.


Test coverage: Proxy deployment in Proxy.test.ts (beforeEach lines 57-70)
successfully initializes

_•_ Should set verifier, governance, additionalZkLighter, and desertVerifier correctly.


Zellic © 2026 _←_ **Back to Contents** Page 62 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


Test coverage: Implicit — all tests depend on these being set correctly

_•_ Should create and store genesis batch (batch 0) with provided state roots.


Test coverage: Tests use genesis batch (storedBatchInfo with batchNumber
1)

_•_ Should call _registerDefaultAssetConfigs to set up ETH and USDC.


Test coverage: test_check_default_asset_configs() lines 284–314 verify
ETH and USDC configs


**Negative behavior**


_•_ Revert when called on implementation instead of proxy
(ZkLighter_CannotBeInitialisedByImpl).


Negative test (proxy pattern not explicitly tested)

_•_ Revert when any address does not have code
(ZkLighter_InvalidInitializeParameters).


Negative test (not explicitly tested)

_•_ Revert when called more than once (initializer modifier).


Negative test (not explicitly tested)


**Function call analysis**


_•_ _registerDefaultAssetConfigs()


_•_ **What is controllable?** Nothing, hardcoded ETH and USDC configs.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value. Sets up default assets.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Could revert if the USDC address from governance is invalid.


**Function: upgrade(bytes** **calldata** **upgradeParameters)**


This is a contract upgrade function that allows updating additionalZkLighter, desertVerifier,
and stateRootUpgradeVerifier addresses. It uses a commitment hash to ensure upgrade
parameters are known beforehand.


**Inputs**


_•_ upgradeParameters


_•_ **Control** : Caller control (but protected by commitment check).


Zellic © 2026 _←_ **Back to Contents** Page 63 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ **Constraints** : Must hash to hardcoded
initializationParametersCommitment (0x46700b4d...). Must decode to
(additionalZkLighter, desertVerifier, stateRootUpgradeVerifier).
Nonzero addresses must have code.

_•_ **Impact** : Updates critical contract dependencies.


**Branches and code coverage**


**Intended branches**


_•_ Should only be callable via Proxy.upgradeTarget().


Test coverage: Proxy.test.ts::L-165, Proxy.test.ts::L-195

_•_ Should validate upgrade parameters hash matches commitment and update contract
addresses.


Test coverage: not tested (upgrade flow via proxy)


**Negative behavior**


_•_ Revert when called on implementation.


Negative test: Proxy.test.ts::L-195

_•_ Revert when parameters hash mismatches or address has no code.


Negative test: not tested


**Function call analysis**


_•_ keccak256(upgradeParameters)


_•_ **What is controllable?** upgradeParameters by the caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Compared against the hardcoded commitment. Prevents arbitrary upgrades.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Deterministic hash, no revert.

_•_ abi.decode(upgradeParameters, (address, address, address))


_•_ **What is controllable?** upgradeParameters (but must match commitment).

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Used to update contract references. Protected by commitment and code
checks.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts if decode fails. Protected by nonReentrant.

_•_ _hasCode(_additionalZkLighter) (and others)


_•_ **What is controllable?** Addresses from parameters.


Zellic © 2026 _←_ **Back to Contents** Page 64 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Must return true or revert.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Pure check, no unusual flow.


**Function: _registerDefaultAssetConfigs()**


This is an internal function called during initialization to register default asset configurations for
ETH (native asset) and USDC. It sets up hardcoded parameters for these two core assets.


**Branches and code coverage**


**Intended branches**


_•_ ETH config should be registered at NATIVE_ASSET_INDEX with correct parameters.


Test coverage: ZkLighter.t.sol::L-295 to L-303

_•_ USDC config should be registered at USDC_ASSET_INDEX with address from
governance.usdc().


Test coverage: ZkLighter.t.sol::L-285 to L-293


**Negative behavior**


_•_ Could revert if the governance.usdc() call fails.


Negative test (not tested — would require faulty governance contract)


**Function call analysis**


_•_ governance.usdc()


_•_ **What is controllable?** Nothing, reads USDC address from the governance
contract.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Used to set the USDC token address. Must be set correctly in the governance
contract.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
External view call — could revert if not set. Called during initialization.


Zellic © 2026 _←_ **Back to Contents** Page 65 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Function:** **registerAssetConfig(uint16** **assetIndex,** **address** **tokenAddress,**
**uint8** **withdrawalsEnabled,** **uint56** **extensionMultiplier,** **uint128** **tick-**
**Size,** **uint64** **depositCapTicks,** **uint64** **minDepositTicks)**


This is a governor-only function that registers new asset configurations on L1. This is separate from
the L2 asset registration and sets up the L1-side asset parameters.


**Inputs**


_•_ assetIndex


_•_ **Control** : Governor control.

_•_ **Constraints** : Must be in [MIN_ASSET_INDEX, MAX_ASSET_INDEX]. Cannot be
NATIVE_ASSET_INDEX. Must not be already registered.

_•_ **Impact** : Index for the new asset.

_•_ tokenAddress


_•_ **Control** : Governor control.

_•_ **Constraints** : Cannot be address(0). Must not be already mapped. Must
have code deployed.

_•_ **Impact** : ERC-20 token contract address.

_•_ withdrawalsEnabled


_•_ **Control** : Governor control.

_•_ **Constraints** : Must be 0 or 1.

_•_ **Impact** : Whether withdrawals are enabled for this asset.

_•_ extensionMultiplier


_•_ **Control** : Governor control.

_•_ **Constraints** : Must be greater than zero and <=
MAX_ASSET_EXTENSION_MULTIPLIER. Extended cap (multiplier *

depositCapTicks) must be <= MAX_EXTENDED_DEPOSIT_CAP_TICKS.

_•_ **Impact** : Multiplier for extended deposit capacity.

_•_ tickSize


_•_ **Control** : Governor control.

_•_ **Constraints** : Must be greater than zero and <= MAX_TICK_SIZE.

_•_ **Impact** : Smallest unit for this asset.

_•_ depositCapTicks


_•_ **Control** : Governor control.

_•_ **Constraints** : Must be greater than zero and <= MAX_DEPOSIT_CAP_TICKS.

_•_ **Impact** : Maximum deposits allowed in ticks.

_•_ minDepositTicks


Zellic © 2026 _←_ **Back to Contents** Page 66 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ **Control** : Governor control.

_•_ **Constraints** : Must be greater than zero and <= depositCapTicks.

_•_ **Impact** : Minimum deposit required in ticks.


**Branches and code coverage**


**Intended branches**


_•_ Should register new ERC-20 asset config with all parameters.


Test coverage: ZkLighter.t.sol::L-97 (LIT in setUp()),
ZkLighter.t.sol::L-305


**Negative behavior**


_•_ Revert when caller is not governor or parameters are invalid.


Negative test: not tested


**Function call analysis**


_•_ governance.requireGovernor(msg.sender)


_•_ **What is controllable?** msg.sender by the caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — reverts if not governor.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Prevents unauthorized registration.

_•_ _hasCode(tokenAddress)


_•_ **What is controllable?** tokenAddress by the governor.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Must return true or revert.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Pure check, no unusual flow.


**Function:** **updateAssetConfig(uint16** **assetIndex,** **uint8** **withdrawalsEn-**
**abled,** **uint64** **depositCapTicks,** **uint64** **minDepositTicks)**


This is a governor-only function to update existing asset-configuration parameters. It cannot
disable withdrawals once enabled (one-way transition). Cannot change token address, extension
multiplier, or tick size.


Zellic © 2026 _←_ **Back to Contents** Page 67 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Inputs**


_•_ assetIndex


_•_ **Control** : Governor control.

_•_ **Constraints** : Must be valid (NATIVE_ASSET_INDEX or configured asset).

_•_ **Impact** : Asset to update.

_•_ withdrawalsEnabled


_•_ **Control** : Governor control.

_•_ **Constraints** : Must be 0 or 1. Cannot go from 1 to 0 (withdrawals can only be
enabled, not disabled).

_•_ **Impact** : Withdrawal status for asset.

_•_ depositCapTicks


_•_ **Control** : Governor control.

_•_ **Constraints** : Must be greater than zero and <= MAX_DEPOSIT_CAP_TICKS.
Extended cap must be <= MAX_EXTENDED_DEPOSIT_CAP_TICKS.

_•_ **Impact** : Maximum deposits allowed in ticks.

_•_ minDepositTicks


_•_ **Control** : Governor control.

_•_ **Constraints** : Must be greater than zero and <= depositCapTicks.

_•_ **Impact** : Minimum deposit required in ticks.


**Branches and code coverage**


**Intended branches**


_•_ Should allow governor to update config and enable withdrawals (0 →1).


Test coverage: ZkLighter.t.sol::L-260 to L-273


**Negative behavior**


_•_ Revert when caller is not governor, asset invalid, or trying to disable withdrawals.


Negative test: not tested


**Function call analysis**


_•_ governance.requireGovernor(msg.sender)


_•_ **What is controllable?** msg.sender by the caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — reverts if not governor.


Zellic © 2026 _←_ **Back to Contents** Page 68 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Prevents unauthorized updates.


**Function:** **registerAsset(uint8** **_l1Decimals,** **uint8** **_decimals,** **bytes32**
**_symbol,** **TxTypes.RegisterAsset** **calldata** **_params)**


External wrapper that delegates to AdditionalZkLighter.registerAsset. All logic and
validations are in the delegated contract.


**Inputs**


All inputs passed through to AdditionalZkLighter.registerAsset — see that threat model for
details.


**Branches and code coverage**


**Intended branches**


_•_ Should delegate to AdditionalZkLighter.


Test coverage: see AdditionalZkLighter.registerAsset


**Negative behavior**


_•_ All validation in delegated contract.


Negative test: see AdditionalZkLighter.registerAsset


**Function call analysis**


_•_ delegateAdditional


_•_ **What is controllable?** All calldata passed through.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
delegatecall preserves msg.sender context. Reverts propagate correctly.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts bubble up. Reentrancy protection in delegated function.


**Function: updateAsset(TxTypes.UpdateAsset** **calldata** **_params)**


External wrapper that delegates to AdditionalZkLighter.updateAsset. All logic and validations
are in the delegated contract.


Zellic © 2026 _←_ **Back to Contents** Page 69 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Inputs**


All inputs passed through to AdditionalZkLighter.updateAsset — see that threat model for
details.


**Branches and code coverage**


**Intended branches**


_•_ Should delegate to AdditionalZkLighter.


Test coverage: see AdditionalZkLighter.updateAsset


**Negative behavior**


_•_ All validation in delegated contract.


Negative test: see AdditionalZkLighter.updateAsset


**Function call analysis**


_•_ delegateAdditional


_•_ **What is controllable?** All calldata passed through.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
delegatecall preserves msg.sender context. Reverts propagate correctly.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts bubble up. Reentrancy protection in delegated function.


**Function:** **deposit(address** **_to,** **uint16** **_assetIndex,** **TxTypes.RouteType**
**_routeType,** **uint256** **_amount)**


External payable wrapper that delegates to AdditionalZkLighter.deposit. Supports both ETH
and ERC-20 deposits. All logic and validations are in the delegated contract.


**Inputs**


All inputs passed through to AdditionalZkLighter.deposit — see that threat model for details.
msg.value also preserved for ETH deposits.


**Branches and code coverage**


**Intended branches**


_•_ Should delegate to AdditionalZkLighter.


Zellic © 2026 _←_ **Back to Contents** Page 70 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


Test coverage: see AdditionalZkLighter.deposit


**Negative behavior**


_•_ All validation in delegated contract.


Negative test: see AdditionalZkLighter.deposit


**Function call analysis**


_•_ delegateAdditional


_•_ **What is controllable?** All calldata and msg.value passed through.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
delegatecall preserves msg.sender and msg.value context. Reverts
propagate correctly.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts bubble up. Reentrancy protection in delegated function.


**Function:** **depositBatch(uint64[]** **calldata** **_amount,** **address[]** **calldata**
**_to,** **uint48[]** **calldata** **_accountIndex)**


External wrapper that delegates to AdditionalZkLighter.depositBatch. Supports batch USDC
deposits. All logic and validations are in the delegated contract.


**Inputs**


All inputs passed through to AdditionalZkLighter.depositBatch — see that threat model for
details.


**Branches and code coverage**


**Intended branches**


_•_ Should delegate to AdditionalZkLighter.


Test coverage: see AdditionalZkLighter.depositBatch


**Negative behavior**


_•_ All validation in delegated contract.


Negative test: see AdditionalZkLighter.depositBatch


Zellic © 2026 _←_ **Back to Contents** Page 71 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Function call analysis**


_•_ delegateAdditional


_•_ **What is controllable?** All calldata passed through.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
delegatecall preserves msg.sender context. Reverts propagate correctly.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts bubble up. Reentrancy protection in delegated function.


**Function:** **changePubKey(uint48** **_accountIndex,** **uint8** **_apiKeyIndex,** **bytes**
**calldata** **_pubKey)**


External wrapper that delegates to AdditionalZkLighter.changePubKey. All logic and validations
(including Goldilocks field checks) are in the delegated contract.


**Inputs**


All inputs passed through to AdditionalZkLighter.changePubKey — see that threat model for
details.


**Branches and code coverage**


**Intended branches**


_•_ Should delegate to AdditionalZkLighter.


Test coverage: see AdditionalZkLighter.changePubKey


**Negative behavior**


_•_ All validation in delegated contract.


Negative test: see AdditionalZkLighter.changePubKey


**Function call analysis**


_•_ delegateAdditional


_•_ **What is controllable?** All calldata passed through.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
delegatecall preserves msg.sender context. Reverts propagate correctly.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts bubble up. Reentrancy protection in delegated function.


Zellic © 2026 _←_ **Back to Contents** Page 72 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Function:** **createMarket(uint8** **_size_decimals,** **uint8** **_price_decimals,**
**bytes32** **_symbol,** **TxTypes.CreateMarket** **calldata** **_params)**


External wrapper that delegates to AdditionalZkLighter.createMarket. Governor-only. All logic
and validations are in the delegated contract.


**Inputs**


All inputs passed through to AdditionalZkLighter.createMarket — see that threat model for
details.


**Branches and code coverage**


**Intended branches**


_•_ Should delegate to AdditionalZkLighter.


Test coverage: see AdditionalZkLighter.createMarket


**Negative behavior**


_•_ All validation in delegated contract.


Negative test: see AdditionalZkLighter.createMarket


**Function call analysis**


_•_ delegateAdditional


_•_ **What is controllable?** All calldata passed through.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**

delegatecall preserves msg.sender context. Reverts propagate correctly.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts bubble up. Reentrancy protection in delegated function.


**Function: updateMarket(TxTypes.UpdateMarket** **calldata** **_params)**


External wrapper that delegates to AdditionalZkLighter.updateMarket. Governor-only. All logic
and validations are in the delegated contract.


**Inputs**


All inputs passed through to AdditionalZkLighter.updateMarket — see that threat model for
details.


Zellic © 2026 _←_ **Back to Contents** Page 73 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Branches and code coverage**


**Intended branches**


_•_ Should delegate to AdditionalZkLighter.


Test coverage: see AdditionalZkLighter.updateMarket


**Negative behavior**


_•_ All validation in delegated contract.


Negative test: see AdditionalZkLighter.updateMarket


**Function call analysis**


_•_ delegateAdditional


_•_ **What is controllable?** All calldata passed through.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
delegatecall preserves msg.sender context. Reverts propagate correctly.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts bubble up. Reentrancy protection in delegated function.


**Function: cancelAllOrders(uint48** **_accountIndex)**


External wrapper that delegates to AdditionalZkLighter.cancelAllOrders. All logic and
validations are in the delegated contract.


**Inputs**


All inputs passed through to AdditionalZkLighter.cancelAllOrders — see that threat model for
details.


**Branches and code coverage**


**Intended branches**


_•_ Should delegate to AdditionalZkLighter.


Test coverage: see AdditionalZkLighter.cancelAllOrders


**Negative behavior**


_•_ All validation in delegated contract.


Negative test: see AdditionalZkLighter.cancelAllOrders


Zellic © 2026 _←_ **Back to Contents** Page 74 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Function call analysis**


_•_ delegateAdditional


_•_ **What is controllable?** All calldata passed through.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
delegatecall preserves msg.sender context. Reverts propagate correctly.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts bubble up. Reentrancy protection in delegated function.


**Function:** **withdraw(uint48** **_accountIndex,** **uint16** **_assetIndex,** **Tx-**
**Types.RouteType** **_routeType,** **uint64** **_baseAmount)**


External wrapper that delegates to AdditionalZkLighter.withdraw. Creates a priority request for
L2 withdrawal. All logic and validations are in the delegated contract.


**Inputs**


All inputs passed through to AdditionalZkLighter.withdraw — see that threat model for details.


**Branches and code coverage**


**Intended branches**


_•_ Should delegate to AdditionalZkLighter.


Test coverage: see AdditionalZkLighter.withdraw


**Negative behavior**


_•_ All validation in delegated contract.


Negative test: see AdditionalZkLighter.withdraw


**Function call analysis**


_•_ delegateAdditional


_•_ **What is controllable?** All calldata passed through.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
delegatecall preserves msg.sender context. Reverts propagate correctly.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts bubble up. Reentrancy protection in delegated function.


Zellic © 2026 _←_ **Back to Contents** Page 75 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Function: createOrder(uint48** **_accountIndex,** **uint16** **_marketIndex,** **uint48**
**_baseAmount,** **uint32** **_price,** **uint8** **_isAsk,** **uint8** **_orderType)**


External wrapper that delegates to AdditionalZkLighter.createOrder. Creates limit or market
orders. All logic and validations are in the delegated contract.


**Inputs**


All inputs passed through to AdditionalZkLighter.createOrder — see that threat model for
details.


**Branches and code coverage**


**Intended branches**


_•_ Should delegate to AdditionalZkLighter.


Test coverage: see AdditionalZkLighter.createOrder


**Negative behavior**


_•_ All validation in delegated contract.


Negative test: see AdditionalZkLighter.createOrder


**Function call analysis**


_•_ delegateAdditional


_•_ **What is controllable?** All calldata passed through.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**

delegatecall preserves msg.sender context. Reverts propagate correctly.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts bubble up. Reentrancy protection in delegated function.


**Function:** **burnShares(uint48** **_accountIndex,** **uint48** **_publicPoolIndex,**
**uint64** **_shareAmount)**


External wrapper that delegates to AdditionalZkLighter.burnShares. Burns shares in a public
pool. All logic and validations are in the delegated contract.


Zellic © 2026 _←_ **Back to Contents** Page 76 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Inputs**


All inputs passed through to AdditionalZkLighter.burnShares — see that threat model for
details.


**Branches and code coverage**


**Intended branches**


_•_ Should delegate to AdditionalZkLighter.


Test coverage: see AdditionalZkLighter.burnShares


**Negative behavior**


_•_ All validation in delegated contract.


Negative test: see AdditionalZkLighter.burnShares


**Function call analysis**


_•_ delegateAdditional


_•_ **What is controllable?** All calldata passed through.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
delegatecall preserves msg.sender context. Reverts propagate correctly.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts bubble up. Reentrancy protection in delegated function.


**Function:** **updateStateRoot(StoredBatchInfo** **calldata** **_lastStoredBatch,**
**bytes32** **_stateRoot,** **bytes32** **_validiumRoot,** **bytes** **calldata** **proof)**


External wrapper that delegates to AdditionalZkLighter.updateStateRoot. Updates state root
with ZK proof verification. All logic and validations are in the delegated contract.


**Inputs**


All inputs passed through to AdditionalZkLighter.updateStateRoot — see that threat model for
details.


**Branches and code coverage**


**Intended branches**


_•_ Should delegate to AdditionalZkLighter.


Zellic © 2026 _←_ **Back to Contents** Page 77 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


Test coverage: see AdditionalZkLighter.updateStateRoot


**Negative behavior**


_•_ All validation in delegated contract.


Negative test: see AdditionalZkLighter.updateStateRoot


**Function call analysis**


_•_ delegateAdditional


_•_ **What is controllable?** All calldata passed through.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
delegatecall preserves msg.sender context. Reverts propagate correctly.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts bubble up. Reentrancy protection in delegated function.


**Function:** **createExitCommitment(uint256** **stateRoot,** **uint48** **_accountIn-**
**dex,** **uint48** **_masterAccountIndex,** **uint16** **_assetIndex,** **uint128** **_total-**
**BaseAmount)**


This is an internal pure function that creates a Keccak-256 commitment hash for desert-mode
exits. It is used by performDesert to verify that a user's exit parameters match the ZK-proven state.


**Inputs**


_•_ stateRoot


_•_ **Control** : From calling function (performDesert).

_•_ **Constraints** : Should be the last verified state root.

_•_ **Impact** : State root included in commitment.

_•_ _accountIndex


_•_ **Control** : From calling function (caller-provided).

_•_ **Constraints** : L2 account index.

_•_ **Impact** : Account index included in commitment.

_•_ _masterAccountIndex


_•_ **Control** : From calling function (caller-provided).

_•_ **Constraints** : L1 master-account index.

_•_ **Impact** : Master-account index included in commitment.

_•_ _assetIndex


_•_ **Control** : From calling function (caller-provided).


Zellic © 2026 _←_ **Back to Contents** Page 78 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ **Constraints** : Asset index for withdrawal.

_•_ **Impact** : Asset included in commitment.

_•_ _totalBaseAmount


_•_ **Control** : From calling function (caller-provided, ZK proven).

_•_ **Constraints** : Must match proven balance.

_•_ **Impact** : Amount included in commitment.


**Branches and code coverage**


**Intended branches**


_•_ Should create deterministic Keccak-256 hash of packed parameters for ZK proof
verification.


Test coverage: not tested


**Negative behavior**


_•_ Pure function, no revert conditions.


**Function call analysis**


Pure function using keccak256(abi.encodePacked(...)). No external calls.


**Function:** **performDesert(uint48** **_accountIndex,** **uint48** **_masterAccountIn-**
**dex,** **uint16** **_assetIndex,** **uint128** **_totalBaseAmount,** **bytes** **calldata**
**proof)**


This function allows users to exit ZkLighter in desert mode by providing a ZK proof of their account
balance. Desert mode is activated when priority requests expire without processing.


**Inputs**


_•_ _accountIndex


_•_ **Control** : User control.

_•_ **Constraints** : Must not have already performed desert for this asset. The
proof must verify this account index.

_•_ **Impact** : Account exiting in desert mode.

_•_ _masterAccountIndex


_•_ **Control** : User control.

_•_ **Constraints** : Must match the master account that owns _accountIndex


Zellic © 2026 _←_ **Back to Contents** Page 79 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


(verified by proof).

_•_ **Impact** : Master account to receive withdrawn balance.

_•_ _assetIndex


_•_ **Control** : User control.

_•_ **Constraints** : Must be valid asset. Account must not have already exited for
this asset.

_•_ **Impact** : Asset being withdrawn.

_•_ _totalBaseAmount


_•_ **Control** : User control (but must be proven).

_•_ **Constraints** : Must be provable via ZK proof against current stateRoot.

_•_ **Impact** : Amount to withdraw in base units.

_•_ proof


_•_ **Control** : User control.

_•_ **Constraints** : Must be a valid ZK proof verifying account balance for this asset.

_•_ **Impact** : Cryptographic proof of balance.


**Branches and code coverage**


**Intended branches**


_•_ Desert mode must be active and account must not have already exited for this asset.


Test coverage: ZkLighter.t.sol::L-317, L-413 to L-421

_•_ ZK proof should be verified and balance credited to master account.


Test coverage: ZkLighter.t.sol::L-333 to L-342


**Negative behavior**


_•_ Revert when desert mode inactive, already performed, or proof fails.


Negative test: ZkLighter.t.sol::L-344 to L-353, L-406 to L-421


**Function call analysis**


_•_ createExitCommitment(uint256(stateRoot), _accountIndex,
_masterAccountIndex, _assetIndex, _totalBaseAmount)


_•_ **What is controllable?** All parameters except stateRoot (which is a contract
state).

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns the deterministic hash used for proof verification. Cannot be
manipulated without valid proof.


Zellic © 2026 _←_ **Back to Contents** Page 80 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Pure function, no revert.

_•_ desertVerifier.Verify(proof, inputs)


_•_ **What is controllable?** proof by user, and inputs is derived from parameters.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns boolean. If false, it causes a revert. The user cannot forge a valid
proof without actual balance.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
External call but protected by nonReentrant. Could revert if proof is invalid.

_•_ increaseBalanceToWithdraw(_masterAccountIndex, _assetIndex,

_totalBaseAmount)


_•_ **What is controllable?** All parameters (but validated by proof).

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value. Updates withdrawal balance.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Internal function — could overflow if the amount is too large.


**Function:** **cancelOutstandingDepositsForDesertMode(uint64** **_n,** **bytes[]**
**memory** **_priorityPubData)**


This function allows cancellation of outstanding priority requests during desert mode. It verifies
the hash chain and credits deposit balances back to users for deposit operations.


**Inputs**


_•_ _n


_•_ **Control** : Caller control.

_•_ **Constraints** : Must be greater than zero, <= openPriorityRequestCount, and
equal to _priorityPubData.length.

_•_ **Impact** : Number of requests to cancel.

_•_ _priorityPubData


_•_ **Control** : Caller control (but must match the stored hash chain).

_•_ **Constraints** : Each element must be greater than zero and <=
MAX_PRIORITY_REQUEST_PUBDATA_SIZE. Must match stored priority-request
hashes. Deposit operations must be the correct size.

_•_ **Impact** : Array of priority-request data to verify and cancel.


**Branches and code coverage**


**Intended branches**


Zellic © 2026 _←_ **Back to Contents** Page 81 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ Desert mode must be active with outstanding requests to cancel.


Test coverage: ZkLighter.t.sol::L-461, L-464

_•_ Hash chain should be verified and deposit balances credited via
increaseBalanceToWithdraw.


Test coverage: ZkLighter.t.sol::L-498 to L-517

_•_ Nondeposit operations should be skipped.


Test coverage: not tested


**Negative behavior**


_•_ Revert when desert inactive, no outstanding deposits, or hash mismatch.


Negative test: ZkLighter.t.sol::L-461 to L-509 (partial coverage)

_•_ Revert when _n != _priorityPubData.length.


Negative test: not tested


**Function call analysis**


_•_ TxTypes.readDepositForDesertMode(depositPubdata)


_•_ **What is controllable?** depositPubdata (but must match the hash chain).

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns (accountIndex, assetIndex, baseAmount). Used to credit balance.
Cannot be manipulated due to hash verification.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Library function, could revert if malformed.

_•_ increaseBalanceToWithdraw(accountIndex, assetIndex, baseAmount)


_•_ **What is controllable?** Parameters from verified deposit data.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value. Updates balance.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Could overflow if the amount is too large.


**Function:** **commitBatch(CommitBatchInfo** **calldata** **newBatchData,** **Stored-**
**BatchInfo** **calldata** **lastStoredBatch)**


This is a validator-only function that commits a new batch of L2 blocks. It validates batch
parameters, processes blob commitments (EIP-4844), updates state roots, and manages priority
requests and on-chain operation queues.


Zellic © 2026 _←_ **Back to Contents** Page 82 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Inputs**


_•_ newBatchData


_•_ **Control** : Validator control.

_•_ **Constraints** : pubdataCommitments must be nonempty with Blob mode,
endBlockNumber must increase, and batchSize must match block count.
Timestamps must be nondecreasing, priorityRequestCount must not
exceed available requests, and prefixPriorityRequestHash must match if
requests exist.

_•_ **Impact** : New batch data to commit including block range, timestamps, state
roots, priority requests, and blob commitments.

_•_ lastStoredBatch


_•_ **Control** : Validator control (but must match stored hash).

_•_ **Constraints** : Must hash to storedBatchHashes[committedBatchesCount].

_•_ **Impact** : Previous batch information for validation continuity.


**Branches and code coverage**


**Intended branches**


_•_ Should validate batch parameters (block numbers, timestamps, batch size) and process
blob commitments.


Test coverage: ZkLighter.t.sol::L-214 to L-224

_•_ Should verify lastStoredBatch hash and priority-request hash chain.


Test coverage: ZkLighter.t.sol::L-316, L-406

_•_ Should update counters and on-chain execution queue.


Test coverage: ZkLighter.t.sol::L-329 to L-333

_•_ State-root override via stateRootUpdates mapping.


Test coverage: not tested


**Negative behavior**


_•_ Revert when caller is not validator or batch parameters invalid.


Negative test: ZkLighter.t.sol::L-336 to L-416

_•_ Revert from _processBlobs if blob validation fails.


Negative test (not explicitly tested)


**Function call analysis**


_•_ governance.isActiveValidator(msg.sender)


Zellic © 2026 _←_ **Back to Contents** Page 83 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ **What is controllable?** msg.sender by the caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — reverts if not validator.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Prevents unauthorized commits.

_•_ hashStoredBatchInfo(lastStoredBatch)


_•_ **What is controllable?** lastStoredBatch by the validator.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Must match stored hash. Deterministic hash.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Pure function, no revert.

_•_ _processBlobs(newBatchData.pubdataCommitments[1:])


_•_ **What is controllable?** Blob commitments by the validator.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns aggregated blob commitment. Validates blob proofs via precompile.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Could revert if blob validation fails. View function, no reentrancy.


**Function:** **verifyBatch(StoredBatchInfo** **memory** **batch,** **bytes** **calldata**
**proof)**


This is a validator-only function that verifies a committed batch using a ZK proof. It updates
verification counters, state roots, and lazily updates execution state.


**Inputs**


_•_ batch


_•_ **Control** : Validator control (but must match committed batch).

_•_ **Constraints** : batchNumber must be verifiedBatchesCount + 1. Must hash
to stored batch hash.

_•_ **Impact** : Batch to verify.

_•_ proof


_•_ **Control** : Validator control.

_•_ **Constraints** : Must be valid ZK proof for batch commitment.

_•_ **Impact** : Zero-knowledge proof of batch validity.


**Branches and code coverage**


**Intended branches**


Zellic © 2026 _←_ **Back to Contents** Page 84 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ Should verify batches in order with valid ZK proof.


Test coverage: ZkLighter.t.sol::L-442 to L-444

_•_ Should update verification counters and lazily execute if no pending on-chain batches.


Test coverage: ZkLighter.t.sol::L-439, L-445, L-557 to L-614


**Negative behavior**


_•_ Revert when caller is not validator, batch not committed, or proof fails.


Negative test: ZkLighter.t.sol::L-448, L-561, L-566


**Function call analysis**


_•_ governance.isActiveValidator(msg.sender)


_•_ **What is controllable?** msg.sender by the caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — reverts if not the validator.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Prevents unauthorized verification.

_•_ hashStoredBatchInfo(batch)


_•_ **What is controllable?** batch by the validator.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Must match stored hash. Deterministic.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Pure function, no revert.

_•_ verifier.Verify(proof, inputs)


_•_ **What is controllable?** proof by the validator and inputs from the batch
commitment.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns boolean. If false, reverts. Validator cannot forge a valid proof.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
External call but protected by nonReentrant.


**Function:** **_executeOneBatch(StoredBatchInfo** **memory** **batch,** **bytes** **memory**
**_onChainOperationsPubData)**


This is an internal function that processes on-chain operations (withdrawals) for a single batch. It
decodes operation types, increases withdrawal balances, and validates operation's hash.


Zellic © 2026 _←_ **Back to Contents** Page 85 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Inputs**


_•_ batch


_•_ **Control** : Called by executeBatches with a validated batch.

_•_ **Constraints** : Must match the stored batch hash.

_•_ **Impact** : Batch containing the operations hash to verify.

_•_ _onChainOperationsPubData


_•_ **Control** : Called by executeBatches with caller-provided data.

_•_ **Constraints** : Must decode correctly and hash to

batch.onChainOperationsHash.

_•_ **Impact** : Encoded on-chain operations to process.


**Branches and code coverage**


**Intended branches**


_•_ Should verify batch hash and process operations sequentially.


Test coverage: ZkLighter.t.sol::L-574, L-777 to L-842

_•_ Should decode and credit withdrawal balances via increaseBalanceToWithdraw.


Test coverage: ZkLighter.t.sol::L-628

_•_ USDCWithdraw operations.


Test coverage: not tested


**Negative behavior**


_•_ Revert when batch hash mismatches, invalid operation type, or operations hash
mismatches.


Negative test: ZkLighter.t.sol::L-917, L-963, L-1024, L-1087


**Function call analysis**


_•_ hashStoredBatchInfo(batch)


_•_ **What is controllable?** batch from caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Must match stored hash. Deterministic.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Pure function, no revert.

_•_ TxTypes.readWithdrawOnChainLog(...) /
TxTypes.readUSDCWithdrawOnChainLog(...)


_•_ **What is controllable?** Pubdata from caller, offset.


Zellic © 2026 _←_ **Back to Contents** Page 86 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns decoded withdrawal data. Must match hash to be valid.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Could revert if malformed. Library functions.

_•_ increaseBalanceToWithdraw(_tx.masterAccountIndex, _tx.assetIndex,

_tx.baseAmount)


_•_ **What is controllable?** All parameters from decoded data (validated by hash).

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value. Updates balances.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Could overflow if the amount is too large.


**Function: executeBatches(StoredBatchInfo[]** **memory** **batches,** **bytes[]** **mem-**
**ory** **onChainOperationsPubData)**


This function executes verified batches that contain on-chain operations (withdrawals). It
processes withdrawal operations, updates state roots, and manages execution queues. It can only
execute batches in the on-chain execution queue.


**Inputs**


_•_ batches


_•_ **Control** : Caller control (but must be verified and in queue).

_•_ **Constraints** : Length must match onChainOperationsPubData. Length must
be <= pendingOnChainBatchesCount. Each batch must be verified and
match queue order.

_•_ **Impact** : Array of batches to execute.

_•_ onChainOperationsPubData


_•_ **Control** : Caller control (but must match batch operation's hash).

_•_ **Constraints** : Each element's operations must hash to the corresponding
batch's onChainOperationsHash.

_•_ **Impact** : On-chain operation data for each batch.


**Branches and code coverage**


**Intended branches**


_•_ Anyone can call (not restricted to validators). Array lengths must match.


Test coverage: ZkLighter.t.sol::L-723, L-773, L-853

_•_ Should process verified batches in queue order and update counters/state roots.


Zellic © 2026 _←_ **Back to Contents** Page 87 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


Test coverage: ZkLighter.t.sol::L-612 to L-645

_•_ Should support multiple operations per batch via _executeOneBatch.


Test coverage: ZkLighter.t.sol::L-777, L-842


**Negative behavior**


_•_ Revert when array mismatch, batch not verified, or not in queue.


Negative test: ZkLighter.t.sol::L-853, L-861, L-871, L-1151

_•_ Revert from _executeOneBatch on validation errors.


Negative test: ZkLighter.t.sol::L-917, L-963, L-1024, L-1087


**Function call analysis**


_•_ _executeOneBatch(batches[i], onChainOperationsPubData[i])


_•_ **What is controllable?** Both parameters by the caller (but validated).

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value. Processes withdrawals and validates hash.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Internal function — can revert if there is a hash mismatch or there are invalid
operations.


**Function:** **revertBatches(StoredBatchInfo[]** **memory** **_batchesToRevert,**
**StoredBatchInfo** **memory** **_remainingBatch)**


This is a validator-only function that reverts committed batches (rollback). It cannot revert
executed batches. It updates all batch counters and verified state.


**Inputs**


_•_ _batchesToRevert


_•_ **Control** : Validator control (but must match committed batches).

_•_ **Constraints** : Each batch must match stored hash and be at
committedBatchesCount. It cannot revert the genesis batch
(endBlockNumber != 0). Must be pending (not executed). If it has on-chain
ops, must be at the end of the pending queue.

_•_ **Impact** : Array of batches to revert from most recent backwards.

_•_ _remainingBatch


_•_ **Control** : Validator control (but must match stored batch).

_•_ **Constraints** : Must hash to storedBatchHashes[committedBatchesCount]
after reversions. Must be the last remaining batch.


Zellic © 2026 _←_ **Back to Contents** Page 88 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ **Impact** : The batch that remains after reversions (for validation).


**Branches and code coverage**


**Intended branches**


_•_ Caller must be an active validator. Should allow no-op rollback.


Test coverage: Proxy.test.ts::L-148 (no-op case only)

_•_ Should revert committed batches and update counters.


Test coverage: not tested (actual batch reversion)


**Negative behavior**


_•_ Revert when not validator, genesis batch, executed batch, or hash mismatch.


Negative test: not tested


**Function call analysis**


_•_ governance.isActiveValidator(msg.sender)


_•_ **What is controllable?** msg.sender by the caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — reverts if not a validator.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Prevents unauthorized reversions.

_•_ hashStoredBatchInfo(storedBatchInfo) / hashStoredBatchInfo(_remainingBatch)


_•_ **What is controllable?** Batch data by the validator.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Must match stored hash. Deterministic.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Pure functions, no revert.


**Function:** **transferERC20(IERC20** **_token,** **address** **_to,** **uint256** **_amount,**
**uint256** **_maxAmount)**


This is a self-callable function that transfers ERC-20 tokens and returns the actual transferred
amount. It handles fee-on-transfer tokens by checking the balance difference. It is used by
withdrawPendingBalance for isolated state changes.


Zellic © 2026 _←_ **Back to Contents** Page 89 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Inputs**


_•_ _token


_•_ **Control** : Caller control (but must be self-call).

_•_ **Constraints** : Must be called from address(this).

_•_ **Impact** : ERC-20 token to transfer.

_•_ _to


_•_ **Control** : Caller control (but must be self-call).

_•_ **Constraints** : Recipient address.

_•_ **Impact** : Transfer recipient.

_•_ _amount


_•_ **Control** : Caller control (but must be self-call).

_•_ **Constraints** : Amount to transfer.

_•_ **Impact** : Requested transfer amount.

_•_ _maxAmount


_•_ **Control** : Caller control (but must be self-call).

_•_ **Constraints** : Maximum allowed balance decrease.

_•_ **Impact** : Upper bound for balance decrease (protects against fee-on-transfer
issues).


**Branches and code coverage**


**Intended branches**


_•_ Should only be callable as self-call and return actual balance difference.


Test coverage: implicitly via withdrawPendingBalance tests


**Negative behavior**


_•_ Revert when msg.sender != address(this) (ZkLighter_OnlyZkLighter).


Negative test (self-call pattern not explicitly tested externally)

_•_ Revert when balance diff > maxAmount
(ZkLighter_RollUpBalanceBiggerThanMaxAmount).


Negative test (would require malicious token)

_•_ Revert when safeTransfer fails (from SafeERC20).


Negative test (not simulated in tests)


Zellic © 2026 _←_ **Back to Contents** Page 90 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Function call analysis**


_•_ _token.balanceOf(address(this))


_•_ **What is controllable?** Token address (validated by the caller).

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Used to calculate the actual transferred amount. For fee-on-transfer tokens,
may differ from requested.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
External view call. Token could be malicious but validated by system.

_•_ SafeERC20.safeTransfer(_token, _to, _amount)


_•_ **What is controllable?** All parameters from self-call.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — reverts on failure.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
External call. Reentrancy protected by the self-call pattern and nonReentrant
in the caller.


**Function: transferETH(address** **_to,** **uint256** **_amount)**


This is a self-callable function that transfers ETH to a recipient. It is used by

withdrawPendingBalance for isolated state changes that can be reverted if needed.


**Inputs**


_•_ _to


_•_ **Control** : Caller control (but must be self-call).

_•_ **Constraints** : Must be called from address(this).

_•_ **Impact** : ETH recipient.

_•_ _amount


_•_ **Control** : Caller control (but must be self-call).

_•_ **Constraints** : Amount of ETH to transfer.

_•_ **Impact** : ETH amount to send.


**Branches and code coverage**


**Intended branches**


_•_ Should only be callable as self-call and transfer ETH to recipient.


Test coverage: ZkLighter.t.sol::L-706 (via withdrawPendingBalance)


Zellic © 2026 _←_ **Back to Contents** Page 91 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Negative behavior**


_•_ Revert when not self-call or ETH transfer fails.


Negative test: not tested


**Function call analysis**


_•_ _to.call{value: _amount}("")


_•_ **What is controllable?** Recipient and amount from self-call.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns bool success. Must be true or revert.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Low-level call. Reentrancy protected by the self-call pattern and
nonReentrant in the caller. Recipient could be a contract with fallback.


**Function:** **increaseBalanceToWithdraw(uint48** **_masterAccountIndex,** **uint16**
**_assetIndex,** **uint128** **_baseAmount)**


This is an internal function that increases the withdrawable balance for an account/asset pair. It is
used when L2 withdrawals are executed, deposits are canceled in desert mode, or desert-mode
exits are performed.


**Inputs**


_•_ _masterAccountIndex


_•_ **Control** : Called by various functions (performDesert,
cancelOutstandingDepositsForDesertMode, _executeOneBatch).

_•_ **Constraints** : Should be a valid master-account index.

_•_ **Impact** : The master account whose withdrawable balance increases.

_•_ _assetIndex


_•_ **Control** : From calling function — should be validated.

_•_ **Constraints** : Should be a valid asset index.

_•_ **Impact** : The asset whose balance increases.

_•_ _baseAmount


_•_ **Control** : From calling function (validated or proven).

_•_ **Constraints** : Must fit in uint128. Added to existing balance (overflow risk).

_•_ **Impact** : Amount to add to withdrawable balance in base units.


Zellic © 2026 _←_ **Back to Contents** Page 92 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Branches and code coverage**


**Intended branches**


_•_ Should increase pending balance for the account/asset pair.


Test coverage: ZkLighter.t.sol::L-458, L-517, L-628, L-636


**Negative behavior**


_•_ Overflow when adding balances (uint128 limit).


Negative test (would require depositing to be greater than the uint128
maximum, implicit Solidity 0.8.x protection)


**Function call analysis**


No external or internal function calls (direct storage update).


**Function: getPendingBalance(address** **_owner,** **uint16** **_assetIndex)**


This is an external view function that returns the pending withdrawable balance for an owner
address and a specific asset. It maps the address to the master-account index and looks up the
balance.


**Inputs**


_•_ _owner


_•_ **Control** : Caller control.

_•_ **Constraints** : Any address.

_•_ **Impact** : Address to check the balance for.

_•_ _assetIndex


_•_ **Control** : Caller control.

_•_ **Constraints** : Any uint16 (no validation).

_•_ **Impact** : Asset to check the balance for.


**Branches and code coverage**


**Intended branches**


_•_ Should return pending balance for owner/asset pair (0 for unregistered).


Test coverage: ZkLighter.t.sol::L-628, L-636, L-703, L-711


Zellic © 2026 _←_ **Back to Contents** Page 93 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Negative behavior**


_•_ View function, no revert conditions.


**Function call analysis**


_•_ getAccountIndexFromAddress(_owner)


_•_ **What is controllable?** _owner by the caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns stored mapping. If not registered, returns NIL_ACCOUNT_INDEX,
which will have 0 balance.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
View function, no unusual flow.


**Function: getPendingBalanceLegacy(address** **_owner)**


This is a public view function that returns the pending USDC balance from the deprecated/legacy
balance storage. It is used for backwards compatibility with older deposits before multiasset
support.


**Inputs**


_•_ _owner


_•_ **Control** : Caller control.

_•_ **Constraints** : Any address.

_•_ **Impact** : Address to check the legacy balance for.


**Branches and code coverage**


**Intended branches**


_•_ Should return legacy USDC balance from deprecated storage.


Test coverage: not tested


**Negative behavior**


_•_ View function, no revert conditions.


**Function call analysis**


_•_ getAccountIndexFromAddress(_owner)


Zellic © 2026 _←_ **Back to Contents** Page 94 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ **What is controllable?** _owner by the caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns stored mapping. If not registered, returns NIL_ACCOUNT_INDEX,
which will have 0 balance.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
View function, no unusual flow.


**Function:** **withdrawPendingBalance(address** **_owner,** **uint16** **_assetIndex,**
**uint128** **_baseAmount)**


This function allows users to withdraw their pending L1 balances accumulated from L2
withdrawals or desert-mode exits. It handles both ETH and ERC-20 tokens, with support for
fee-on-transfer tokens.


**Inputs**


_•_ _owner


_•_ **Control** : Caller control.

_•_ **Constraints** : Must have a registered master account. Must have sufficient
pending balance.

_•_ **Impact** : Owner whose balance to withdraw.

_•_ _assetIndex


_•_ **Control** : Caller control.

_•_ **Constraints** : Must be valid asset (NATIVE_ASSET_INDEX or configured).

_•_ **Impact** : Asset to withdraw.

_•_ _baseAmount


_•_ **Control** : Caller control.

_•_ **Constraints** : Must be greater than zero and less than or equal to the pending
balance.

_•_ **Impact** : Amount to withdraw in base units.


**Branches and code coverage**


**Intended branches**


_•_ Should withdraw pending balance for registered owner (ETH or ERC-20).


Test coverage: ZkLighter.t.sol::L-631, L-638, L-706, L-713


**Negative behavior**


_•_ Revert when amount exceeds balance, is zero, asset invalid, or transfer fails.


Zellic © 2026 _←_ **Back to Contents** Page 95 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


Negative test: not tested


**Function call analysis**


_•_ getAccountIndexFromAddress(_owner)


_•_ **What is controllable?** _owner by the caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns master account from mapping. Cannot be manipulated.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
View function, no unusual flow.

_•_ this.transferETH(_owner, amount)


_•_ **What is controllable?** _owner and amount (validated).

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns transferred amount. Should equal requested for ETH.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
External self-call to isolate state changes. Can revert if transfer fails.
Protected by nonReentrant.

_•_ this.transferERC20(IERC20(assetConfig.tokenAddress), _owner, amount,
balance)


_•_ **What is controllable?** Recipient and amounts (validated).

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns the actual transferred amount. May differ from that requested for
fee-on-transfer tokens. Cannot exceed balance.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
External self-call. Can revert if transfer fails. Protected by nonReentrant.

_•_ SafeCast.toUint128(transferredBaseAmount)


_•_ **What is controllable?** Calculated transferred amount.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Must fit in uint128. Could overflow for very large amounts.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts on overflow.


**Function:** **withdrawPendingBalanceLegacy(address** **_owner,** **uint128**
**_baseAmount)**


This is an external function to withdraw the pending USDC balance from the deprecated/legacy
balance storage. It allows users to withdraw balances accumulated before multiasset support was
added.


Zellic © 2026 _←_ **Back to Contents** Page 96 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Inputs**


_•_ _owner


_•_ **Control** : Caller control.

_•_ **Constraints** : Must have a registered master account. Must have sufficient
legacy pending balance.

_•_ **Impact** : Owner whose legacy balance to withdraw.

_•_ _baseAmount


_•_ **Control** : Caller control.

_•_ **Constraints** : Must be greater than zero and less than or equal to the legacy
pending balance.

_•_ **Impact** : Amount to withdraw in base units (USDC has 1:1 base unit).


**Branches and code coverage**


**Intended branches**


_•_ Should withdraw legacy USDC balance from deprecated storage.


Test coverage: not tested


**Negative behavior**


_•_ Revert when amount exceeds balance, is zero, or transfer fails.


Negative test: not tested


**Function call analysis**


_•_ getAccountIndexFromAddress(_owner)


_•_ **What is controllable?** _owner by the caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns master account from mapping. Cannot be manipulated.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
View function, no unusual flow.

_•_ governance.usdc()


_•_ **What is controllable?** Nothing — reads USDC address from governance.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns USDC token contract address. Set during initialization.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
View function — could revert if governance is not set.

_•_ this.transferERC20(governance.usdc(), _owner, uint256(_baseAmount),
uint256(baseBalance))


Zellic © 2026 _←_ **Back to Contents** Page 97 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ **What is controllable?** Recipient and amounts (validated).

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns actual transferred amount. Should equal requested for standard
USDC.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
External self-call. Can revert if transfer fails. Protected by nonReentrant.


**Function: activateDesertMode()**


This is a public function that anyone can call to activate desert mode if priority requests have
expired. Once activated, users can exit using performDesert and cancel outstanding deposits.


**Branches and code coverage**


**Intended branches**


_•_ Trigger should be true if openPriorityRequestCount                           - 0 _and_ the current time is
greater than or equal to the expiration timestamp _and_ expiration != 0.


Test coverage: test/ZkLighter.test.ts::L-1475 (sets up priority requests
and advances time to activate)

_•_ If the trigger is true and not already in desert mode, activate it.


Test coverage: test/ZkLighter.test.ts::L-1488 (calls
activateDesertMode()), test/ZkLighter.test.ts::L-1491 (desertMode
becomes true)

_•_ If already in desert mode, do not emit the event again.


Test coverage (idempotency not explicitly tested)

_•_ The DesertMode event should be emitted on activation.


Test coverage: test/ZkLighter.test.ts::L-1488

_•_ The function should return true if triggered and false otherwise.


Test coverage (return value not asserted)


**Negative behavior**


_•_ No revert conditions (permissionless function by design).


**Function call analysis**


No external or internal function calls (direct storage reads).


Zellic © 2026 _←_ **Back to Contents** Page 98 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Function: setTreasury(address** **_newTreasury)**


This is a governor-only function to update the treasury address that collects fees. The treasury
address must not be in use as a user account.


**Inputs**


_•_ _newTreasury


_•_ **Control** : Governor control.

_•_ **Constraints** : Cannot be address(0). Cannot be registered as a user account
(must return NIL_ACCOUNT_INDEX).

_•_ **Impact** : New treasury address.


**Branches and code coverage**


**Intended branches**


_•_ The new treasury must not be address(0).


Test coverage: test/ZkLighter.system.t.sol::L-45

_•_ The new treasury must not be registered as a user account.


Test coverage: test/ZkLighter.system.t.sol::L-51

_•_ The treasury should be updated.


Test coverage: test/ZkLighter.system.t.sol::L-30

_•_ The TreasuryUpdate event should be emitted.


Test coverage: test/ZkLighter.system.t.sol::L-31


**Negative behavior**


_•_ Revert when the caller is not the governor.


Negative test: test/ZkLighter.system.t.sol::L-39

_•_ Revert when the treasury is address(0) (ZkLighter_TreasuryCannotBeZero).


Negative test: test/ZkLighter.system.t.sol::L-45

_•_ Revert when the treasury is a registered account (ZkLighter_TreasuryCannotBeInUse).


Negative test: test/ZkLighter.system.t.sol::L-51


**Function call analysis**


_•_ governance.requireGovernor(msg.sender)


_•_ **What is controllable?** msg.sender by the caller.


Zellic © 2026 _←_ **Back to Contents** Page 99 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — reverts if not the governor.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Prevents unauthorized updates.

_•_ getAccountIndexFromAddress(_newTreasury)


_•_ **What is controllable?** _newTreasury by the governor.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Must return NIL_ACCOUNT_INDEX. Cannot be manipulated.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
View function, no unusual flow.


**Function: setInsuranceFundOperator(address** **_newInsuranceFundOperator)**


This is a governor-only function that updates the insurance-fund-operator address. The
insurance-fund-operator address must not be in use as a user account.


**Inputs**


_•_ _newInsuranceFundOperator


_•_ **Control** : Governor control.

_•_ **Constraints** : Cannot be address(0). Cannot be registered as a user account
(must return NIL_ACCOUNT_INDEX).

_•_ **Impact** : New insurance-fund-operator address.


**Branches and code coverage**


**Intended branches**


_•_ The new operator must not be address(0).


Test coverage: test/ZkLighter.system.t.sol::L-83

_•_ The new operator must not be registered as a user account.


Test coverage: test/ZkLighter.system.t.sol::L-89

_•_ The insurance fund operator should be updated.


Test coverage: test/ZkLighter.system.t.sol::L-68

_•_ The InsuranceFundOperatorUpdate event should be emitted.


Test coverage: test/ZkLighter.system.t.sol::L-69


**Negative behavior**


_•_ Revert when the caller is not the governor.


Zellic © 2026 _←_ **Back to Contents** Page 100 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


Negative test: test/ZkLighter.system.t.sol::L-77

_•_ Revert when the operator is address(0)
(ZkLighter_InsuranceFundOperatorCannotBeZero).


Negative test: test/ZkLighter.system.t.sol::L-83

_•_ Revert when the operator is a registered account
(ZkLighter_InsuranceFundOperatorCannotBeInUse).


Negative test: test/ZkLighter.system.t.sol::L-89


**Function call analysis**


_•_ governance.requireGovernor(msg.sender)


_•_ **What is controllable?** msg.sender by the caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — reverts if not the governor.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Prevents unauthorized updates.

_•_ getAccountIndexFromAddress(_newInsuranceFundOperator)


_•_ **What is controllable?** _newInsuranceFundOperator by the governor.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Must return NIL_ACCOUNT_INDEX. Cannot be manipulated.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
View function, no unusual flow.


**Function: delegateAdditional()**


Internal function that delegates calls to AdditionalZkLighter using low-level delegatecall. Used
by multiple external functions to split contract logic due to size limits. Uses msg.data directly.


**Inputs**


None (uses msg.data directly from original call).


**Branches and code coverage**


**Intended branches**


_•_ Should delegatecall to AdditionalZkLighter with full calldata.


Test coverage: all delegated functions work correctly

_•_ Should copy return data back to caller.


Zellic © 2026 _←_ **Back to Contents** Page 101 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


Test coverage: return values propagate correctly

_•_ If delegatecall fails, should revert with return data.


Test coverage: error messages propagate correctly


**Negative behavior**


_•_ Revert when called on implementation contract (not via proxy).


Negative test: not tested

_•_ Revert with delegatecall revert data if target reverts.


Negative test: all negative tests on delegated functions verify error
propagation


**Function call analysis**


_•_ Assembly delegatecall


_•_ **What is controllable?** Calldata from original caller.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Return data passed through unchanged. Preserves msg.sender and
msg.value context.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts propagate correctly. Reentrancy protection must be in external caller
or AdditionalZkLighter functions (all use nonReentrant).


**Function:** **_pointEvaluationPrecompile(bytes32** **blobVersionedHash,** **bytes**
**calldata** **evaluationPointCommitmentProof)**


This is an internal view function that calls the EIP-4844 point evaluation precompile to verify blob
KZG proofs. It validates that the precompile succeeded and returned the expected BLS_MODULUS
value.


**Inputs**


_•_ blobVersionedHash


_•_ **Control** : From blobhash opcode (transaction-provided).

_•_ **Constraints** : Must be a valid versioned hash from transaction blobs.

_•_ **Impact** : Identifies which blob to verify.

_•_ evaluationPointCommitmentProof


_•_ **Control** : From pubDataCommitments (validator-provided).

_•_ **Constraints** : Must be a valid KZG proof (160 bytes — evaluationPoint 64
bytes plus commitment 48 bytes plus proof 48 bytes).


Zellic © 2026 _←_ **Back to Contents** Page 102 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ **Impact** : KZG proof data to verify.


**Branches and code coverage**


**Intended branches**


_•_ Precompile input should be encoded correctly (hash plus proof).


Test coverage: exercised via blob processing in
test/ZkLighter.t.sol::L-215 (blobhashes set) and
test/ZkLighter.t.sol::L-222 (commitBatch happy path)

_•_ Static call to POINT_EVALUATION_PRECOMPILE_ADDRESS should succeed.


Test coverage: exercised via blob processing in
test/ZkLighter.t.sol::L-215 (blobhashes set) and
test/ZkLighter.t.sol::L-222 (commitBatch happy path)

_•_ Response should decode to two uint256 values.


Test coverage: exercised via blob processing in
test/ZkLighter.t.sol::L-215 (blobhashes set) and

test/ZkLighter.t.sol::L-222 (commitBatch happy path)

_•_ Second uint256 (result) must equal BLS_MODULUS.


Test coverage: exercised via blob processing in
test/ZkLighter.t.sol::L-215 (blobhashes set) and
test/ZkLighter.t.sol::L-222 (commitBatch happy path)


**Negative behavior**


_•_ Revert when precompile call fails (ZkLighter_InvalidPointEvaluationParams).


Negative test (not explicitly tested)

_•_ Revert when result != BLS_MODULUS (ZkLighter_InvalidPointEvaluationParams).


Negative test (not explicitly tested)


**Function call analysis**


_•_ POINT_EVALUATION_PRECOMPILE_ADDRESS.staticcall(precompileInput)


_•_ **What is controllable?** Precompile input (hash plus proof data).

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
Returns (bool success, bytes data). Must succeed, and data must decode
correctly with result == BLS_MODULUS.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Static call, no state changes possible. No reentrancy risk.


Zellic © 2026 _←_ **Back to Contents** Page 103 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


**Function: _processBlobs(bytes** **calldata** **pubDataCommitments)**


This is an internal view function that processes and validates EIP-4844 blob commitments. It
verifies each blob using the point evaluation precompile and computes an aggregated
commitment hash.


**Inputs**


_•_ pubDataCommitments


_•_ **Control** : Called by commitBatch with validator-provided data.

_•_ **Constraints** : Length must be a multiple of
BLOB_DATA_COMMITMENT_BYTE_SIZE (160 bytes). Blob count must be <=
MAX_BLOB_COUNT. Each blob must have a valid versioned hash. Must pass
point-evaluation-precompile verification.

_•_ **Impact** : Array of blob commitment data (evaluationPointX,
evaluationPointY, commitment, proof) per blob.


**Branches and code coverage**


**Intended branches**


_•_ The pubDataCommitments length must be a multiple of 160 bytes.


Test coverage: exercised via test/ZkLighter.t.sol::L-222 (commit batch
with blob mode + commitments)

_•_ The blob count must be calculated correctly and <= MAX_BLOB_COUNT.


Test coverage: exercised with a single blob via
test/ZkLighter.t.sol::L-215 and test/ZkLighter.t.sol::L-222

_•_ For each blob, extract evaluationPointX and evaluationPointY.


Test coverage: exercised (not explicitly asserted) via
test/ZkLighter.t.sol::L-222

_•_ For each blob, get the versioned hash from the blobhash(i) opcode.


Test coverage: exercised via test/ZkLighter.t.sol::L-215 and

test/ZkLighter.t.sol::L-222

_•_ The blob versioned hash must be nonzero.


Test coverage: exercised implicitly (call succeeds with configured blobhash)
via test/ZkLighter.t.sol::L-215 and test/ZkLighter.t.sol::L-222

_•_ The point evaluation precompile should be called and succeed for each blob.


Test coverage: exercised via test/ZkLighter.t.sol::L-222 (commit batch
succeeds, so precompile verification does not revert)

_•_ The current blob commitment should be a hash of (evaluationPointX,


Zellic © 2026 _←_ **Back to Contents** Page 104 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


evaluationPointY, blobVersionedHash).


Test coverage: exercised (not explicitly asserted) via
test/ZkLighter.t.sol::L-222

_•_ The first blob sets aggregatedBlobCommitment and subsequent blobs hash with
previous.


Test coverage: exercised for the first-blob case via

test/ZkLighter.t.sol::L-222

_•_ After processing all blobs, the next blobhash must be zero (no extra blobs).


Test coverage: exercised implicitly (call succeeds with exactly one
configured blobhash) via test/ZkLighter.t.sol::L-215 and
test/ZkLighter.t.sol::L-222

_•_ Return aggregated blob commitment.


Test coverage: exercised (return value is used by commitBatch, but not
asserted directly) via test/ZkLighter.t.sol::L-222


**Negative behavior**


_•_ Revert when the pubDataCommitments length is not a multiple of 160
(ZkLighter_InvalidBlobCommitmentParams).


Negative test: not explicitly tested (would require commitBatch with
newBatchData.pubdataCommitments[1:] not a multiple of 160 bytes)

_•_ Revert when blob count is > MAX_BLOB_COUNT (ZkLighter_InvalidBlobCount).


Negative test: not explicitly tested (would require pubdataCommitments
containing MAX_BLOB_COUNT + 1 blob entries)

_•_ Revert when blobVersionedHash is bytes32(0)
(ZkLighter_InvalidBlobCommitmentParams).


Negative test: not explicitly tested (would require vm.blobhashes with an
empty list, or otherwise forcing blobhash(0) == 0)

_•_ Revert from _pointEvaluationPrecompile if verification fails.


Negative test: not explicitly tested (no test forces the point-evaluation
precompile to return a non-BLS_MODULUS value)

_•_ Revert when extra blobs are attached (emptyBlobVersionedHash != 0)
(ZkLighter_InvalidBlobCommitmentParams).


Negative test: not explicitly tested (would require setting vm.blobhashes with
more blobs than the provided commitments cover)


**Function call analysis**


_•_ _pointEvaluationPrecompile(blobVersionedHash, _blobDataCommitment)


Zellic © 2026 _←_ **Back to Contents** Page 105 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026


_•_ **What is controllable?** Blob commitment data by validator and the versioned
hash from the transaction.

_•_ **If the return value is controllable, how is it used and how can it go wrong?**
No return value — reverts if invalid. Uses EIP-4844 precompile to verify KZG
proofs.

_•_ **What happens if it reverts, reenters or does other unusual control flow?**
Reverts if precompile fails or the result is invalid. Static call, no reentrancy.


Zellic © 2026 _←_ **Back to Contents** Page 106 of 107


**Lighter (EVM)** Smart Contract Security Assessment January 21, 2026

## 6. Assessment Results During our assessment on the scoped Lighter (EVM) contracts, we discovered four findings. No

critical issues were found. Two findings were of medium impact, one was of low impact, and the
remaining finding was informational in nature.


The Lighter EVM codebase demonstrates solid architectural design with appropriate security
mechanisms. The code quality is generally high with clear structure.


To note, our audit was conducted under the assumption that off-chain components (L2 operator,
sequencer, and ZK proof generation) perform their own validation and operate correctly. The
security of the overall system is heavily dependent on these off-chain components, which handle
critical validation logic for batch data integrity, L2 state transitions, and priority-request processing.


Additionally, the test suite has notable gaps in coverage for EIP-4844 blob processing, batch
reversion logic, proxy upgrade mechanisms, and various edge cases. We recommend expanding
test coverage in these areas before mainnet deployment to strengthen confidence in the system's
security posture.


6.1. Disclaimer


This assessment does not provide any warranties about finding all possible issues within its scope;
in other words, the evaluation results do not guarantee the absence of any subsequent issues. Zellic, of course, also cannot make guarantees about any code added to the project after the version
reviewed during our assessment. Furthermore, because a single assessment can never be considered comprehensive, we always recommend multiple independent assessments paired with a bug
bounty program.


For each finding, Zellic provides a recommended solution. All code samples in these recommendations are intended to convey how an issue may be resolved (i.e., the idea), but they may not be
tested or functional code. These recommendations are not exhaustive, and we encourage our partners to consider them as a starting point for further discussion. We are happy to provide additional
guidance and advice as needed.


Finally, the contents of this assessment report are for informational purposes only; do not construe
any information in this report as legal, tax, investment, or financial advice. Nothing contained in this
report constitutes a solicitation or endorsement of a project by Zellic.


Zellic © 2026 _←_ **Back to Contents** Page 107 of 107


