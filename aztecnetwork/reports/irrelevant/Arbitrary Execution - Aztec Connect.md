# AZTEC SECURITY ASSESSMENT

## **October 14, 2022** Prepared For: _Joe Andrews, Aztec_ Prepared By: _John Bird, Jasper Clark_ Changelog: _September 16, 2022 Initial report delivered_ _October 14, 2022       Final report delivered_


**<mark>TABLE OF CONTENTS</mark>**


**TABLE OF CONTENTS ........................................................................................................................................ 2**


**EXECUTIVE SUMMARY ..................................................................................................................................... 3**

**FIX REVIEW UPDATE ......................................................................................................................................... 3**


FIX REVIEW PROCESS ....................................................................................................................................................... 3


**AUDIT OBJECTIVES ........................................................................................................................................... 4**


**OBSERVATIONS ................................................................................................................................................ 4**


**SYSTEM OVERVIEW .......................................................................................................................................... 5**

USER CATEGORIES .......................................................................................................................................................... 5

_Users ...................................................................................................................................................................... 5_
_Privileged Roles...................................................................................................................................................... 5_
SYSTEM COMPONENTS .................................................................................................................................................... 5

_RollupProcessorV2 ................................................................................................................................................. 5_
_Rollup Provider ...................................................................................................................................................... 6_
_PermitHelper.......................................................................................................................................................... 6_
_Decoder.................................................................................................................................................................. 6_
_DefiBridgeProxy ..................................................................................................................................................... 6_


**VULNERABILITY STATISTICS .............................................................................................................................. 8**


**FIXES SUMMARY .............................................................................................................................................. 8**


**FINDINGS ......................................................................................................................................................... 9**

LOW SEVERITY................................................................................................................................................................ 9

_[L01] Lack of bounds checking on escape hatch values ........................................................................................ 9_

_[L02] Missing_ _<mark>`extcodesize`</mark>_ _check when using low-level_ _<mark>`call`</mark>_ _........................................................................ 10_

_[L03] Incorrectly set protocol gas limit can render an asset or bridge non-functional ....................................... 10_

_[L04] Truncation of_ _<mark>`block.timestamp`</mark>_ _can leave escape hatch open inside delay window ........................... 11_

_[L05]_ _<mark>`lastRollupTimeStamp`</mark>_ _can be incorrectly set ....................................................................................... 12_
NOTE SEVERITY ............................................................................................................................................................ 13

_[N01] Missing bridge zero-address checks .......................................................................................................... 13_

_[N02] Build issues ................................................................................................................................................ 14_

_[N03] Redundant input validation in_ _<mark>`withdraw`</mark>_ _................................................................................................ 16_

_[N04] Hardcoded gas values ............................................................................................................................... 16_

_[N05] Use of floating compiler version pragma .................................................................................................. 17_

_[N06] Incorrect documentation ........................................................................................................................... 17_

_[N07] Shadowing with function parameter......................................................................................................... 18_

_[N08] Typographical errors ................................................................................................................................. 19_

_[N09] Use of long numerical literals .................................................................................................................... 19_

_[N10] Incomplete initialization ............................................................................................................................ 20_

_[N11] Nonstandard use of unnamed function parameter .................................................................................. 21_


**APPENDIX ...................................................................................................................................................... 22**


APPENDIX A: SEVERITY DEFINITIONS ................................................................................................................................ 22
APPENDIX B: FILES IN SCOPE ........................................................................................................................................... 23

## **2**


**<mark>EXECUTIVE SUMMARY</mark>**


This report contains the results of Arbitrary Execution’s security assessment of the Aztec Connect smart
[contracts. The Aztec protocol uses PLONK](https://eprint.iacr.org/2019/953.pdf) technology to provide privacy for users and enable fast and
inexpensive transactions on Ethereum. Aztec Connect enables Aztec users to interact with external DeFi
protocols from within Aztec’s layer 2 via smart contracts called bridges.


Two Arbitrary Execution (AE) engineers conducted this review over a 4-week period, from August 15,
2022 to September 12, 2022. The audited commit was
<mark>`9558b62604c72e5d1ea70f330df057eaeae10bd1`</mark> in the <mark>`lh/compliance`</mark> branch of the
<mark>`AztecProtocol/aztec2-internal/`</mark> repository. The complete list of files in scope is located in
Appendix B. These repositories were private at the time of the engagement, so hyperlinks may not work
for readers without access.


The team performed a detailed, manual review of the codebase with a focus on Aztec’s
<mark>`RollupProcessorV2`</mark>, <mark>`Decoder`</mark> <mark>,</mark> and <mark>`DefiBridgeProxy`</mark> contracts. In addition to manual review, the
[team used Slither for automated static analysis.](https://github.com/crytic/slither)


The assessment resulted in findings ranging in severity from low to note (informational). One low
severity finding involves the absence of safety checks around the protocol’s escape hatch parameters, a
mechanism that allows ordinary users to send proofs directly to the rollup contract. Two other low
findings focus on a time delay added to the escape hatch. The remaining low severity findings involve
adding assets and bridges that do not function properly, and safety checks in the <mark>`TokenTransfers`</mark>
contract. The note severity findings contain observations regarding code hygiene, documentation, and
other best practices.


**<mark>FIX REVIEW UPDATE</mark>**


<mark>FIX REVIEW PROCESS</mark>


After receiving fixes for the findings shared with Aztec, the AE team performed a review of each fix. Each
pull request was scrutinized to ensure that the core issue was addressed, and that no regressions were
introduced with the fix. A summary of each fix review can be found in the _Update_ section for a finding.
For findings that the Aztec team chose not to address, the team’s rationale is included in the update.


The Aztec team has fixed or acknowledged all major issues identified in the engagement. The full
breakdown of fixes can be found in the Fixes Summary section. While the team acknowledged L04, they
[fixed an overflow in the same calculation in pull request #1479.](https://github.com/AztecProtocol/aztec2-internal/pull/1479)

## **3**


**<mark>AUDIT OBJECTIVES</mark>**


AE had the following high-level goals for the engagement:


 - Ensure Aztec’s contracts are implemented consistently with their documentation

 - Identify smart contract vulnerabilities

 - Evaluate adherence to development best practices


The Aztec team also identified specific questions to guide the engagement:


 - Can an attacker manipulate the encoded proof data such that the proof still passes, but actions
other than expected are performed? (e.g., insert extra withdraw or skip a user deposit)

 - Can an attacker remove funds from the rollup, without a valid withdraw proof or valid deposit
into a bridge? (Assuming the attacker doesn’t hold <mark>`OWNER_ROLE`</mark> or control the <mark>`PROXY_ADMIN`</mark> )

 - Can an attacker brick the contract or freeze funds indefinitely? (Assuming the attacker doesn’t
hold <mark>`OWNER_ROLE`</mark> or control the <mark>`PROXY_ADMIN`</mark> )

 - Can an attacker escalate privileges?


**<mark>OBSERVATIONS</mark>**


The contracts in this repository make extensive use of inline assembly. Assembly is used in part to save
[on gas and reduce deployed bytecode size, but also to decode Aztec’s custom proof data encoding](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/Decoder.sol#L9-L11)
<u>[scheme. Writing code in yul](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/Decoder.sol#L9-L11)</u> is more error prone than writing Solidity. Higher level languages place more
burden on the compiler to choose code that will be executed, whereas assembly places that
responsibility on the developer. It is the developer’s responsibility to check every instruction written for
[issues like off-by one errors, mistyped bitmasks or literals, and incorrect argument ordering](https://ethereum.stackexchange.com/questions/127538/right-shift-not-working-in-inline-assembly) because
code with these problems will often compile but not behave as intended.


[Assembly code can also be more sensitive to Solidity compiler bugs, as some bugs are only reachable](https://blog.soliditylang.org/2021/09/29/signed-immutables-bug/)
<u>[from inline assembly. Bugs are continuously being fixed in the Solidity compiler, and sometimes new](https://blog.soliditylang.org/2021/09/29/signed-immutables-bug/)</u>
<u>[bugs are introduced in the process. These bugfixes are](https://blog.soliditylang.org/2022/09/08/storage-write-removal-before-conditional-termination/)</u> **not** backported to older compiler versions. All
projects, and projects that use assembly in particular, must take care in understanding what bugs are
present in their current compiler version.


On top of the security implications of writing assembly code, there are tradeoffs to consider between
readability/maintainability and performance. When using assembly, developers get additional control
over code execution but the code can become more difficult to understand and maintain. It is critical to
keep code comments up-to-date and accurate to aid developers and auditors. When in doubt, err on the
side of being explicit over implicit.


The <mark>`RollupProcessorV2`</mark> [contract is approaching the bytecode size limit introduced in the Spurious](https://eips.ethereum.org/EIPS/eip-170)
<u>[Dragon](https://eips.ethereum.org/EIPS/eip-170)</u> hard-fork. Hardhat’s contract sizer reports a size of 24.438 KB, which leaves 138 bytes before
<mark>`RollupProcessorV2`</mark> will exceed the size limit for mainnet deployment. It is feasible that a new
feature could push the contract size over the limit of 24.576 KB. The team will have to be mindful of this
constraint as they continue development.

## **4**


**<mark>SYSTEM OVERVIEW</mark>**


<mark>USER CATEGORIES</mark>


USERS


Users can deposit funds into Aztec’s Ethereum smart contracts and claim funds on Aztec’s L2 to privately
transact with one another and interact with external protocols through Aztec bridges. Users do not hold
any special roles in the context of the smart contracts.


PRIVILEGED ROLES


There are 4 roles defined in Aztec’s access control scheme in addition to <mark>`AccessControl`</mark> <mark>’</mark> s
<mark>`[DEFAULT_ADMIN_ROLE](https://docs.openzeppelin.com/contracts/4.x/access-control#granting-and-revoking)`</mark> .

```
OWNER_ROLE

```

The <mark>`OWNER_ROLE`</mark> has access to functions that modify the configuration of the <mark>`RollupProcessorV2`</mark>
contract. This role can perform actions including:


 - Adding and removing rollup providers

 - Changing the addresses of the <mark>`DefiBridgeProxy`</mark> and PLONK verifier

 - Changing the escape hatch delay

 - Allowing third parties to add assets and bridges

```
EMERGENCY_ROLE

```

Holders of the <mark>`EMERGENCY_ROLE`</mark> can pause the <mark>`RollupProcessorV2`</mark> contract.

```
RESUME_ROLE

```

Holders of the <mark>`RESUME_ROLE`</mark> can unpause the <mark>`RollupProcessorV2`</mark> contract.

```
LISTER_ROLE

```

Holders of the <mark>`LISTER_ROLE`</mark> can add new supported assets and bridges to the <mark>`RollupProcessorV2`</mark>
contract. They can also set the asset cap for a particular asset.


<mark>SYSTEM COMPONENTS</mark>


ROLLUPPROCESSORV2


The <mark>`RollupProcessorV2`</mark> is an updated version of <mark>`RollupProcessor.sol`</mark> <mark>.</mark> It is responsible for
processing Aztec zk-rollup proofs, relaying the proofs to a verifier contract, and performing relevant
ether and ERC-20 token transfers to users and DeFi bridges.


A <mark>`RollupState`</mark> structure is defined to track state information pertinent to the current rollup.

## **5**


REAL AND VIRTUAL ASSETS


The rollup processor supports two types of assets:


 - Real assets are either ether or ERC-20 tokens. Real assets on Aztec’s L2 have a corresponding
asset on L1.

 - Virtual assets exist purely inside the Aztec network and do not have a corresponding asset on L1.
These are used by bridges to track data such as loans or votes in a DAO.


Assets in the rollup processor are tracked by an <mark>`assetId`</mark> <mark>.</mark> Real and virtual assets can be distinguished
by their <mark>`assetId`</mark> format.


ASSET CAP


Asset caps are restrictions placed on supported Aztec assets. Caps limit the daily amount of deposits for
a particular asset. There is a <mark>`capped`</mark> flag inside the <mark>`rollupState`</mark> structure to enable and disable the
enforcement of asset caps. This flag can be toggled by the <mark>`OWNER_ROLE`</mark> through calling the <mark>`setCapped`</mark>
function.


ESCAPE HATCH


The escape hatch is a window of time (measured in blocks) in which anyone can submit rollup proofs to
the rollup processor. It exists for the scenario where Aztec disappears or rollup providers are
unavailable.


ROLLUPPROCESSORLIBRARY


The <mark>`RollupProcessorLibrary`</mark> is a helper contract that contains signature validation methods for the
rollup processor.


ROLLUP PROVIDER


A rollup provider is a third party that constructs rollup proofs. Aztec currently acts as a rollup provider.
Rollup providers are tracked in the rollup processor with the <mark>`rollupProviders`</mark> mapping. Rollup
providers call <mark>`processRollup`</mark> to decode and verify rollup proofs.


PERMITHELPER


The <mark>`PermitHelper`</mark> [is a helper contract for performing ERC-20 permit](https://eips.ethereum.org/EIPS/eip-2612) actions.


DECODER


The <mark>`Decoder`</mark> contract is responsible for decoding and extracting proof data. It receives encoded proof
data in <mark>`calldata`</mark> when the rollup processor calls the <mark>`decodeProof`</mark> function. The decoder decodes the
encoded calldata, and returns the full proof data back to the rollup processor.


DEFIBRIDGEPROXY

## **6**


The <mark>`DefiBridgeProxy`</mark> calls bridge contracts to convert Aztec inputs into outputs based on an external
protocol interaction.


BRIDGE


A bridge in the context of Aztec is an L1 smart contract that translates an external contract’s interface
into the Aztec Connect interface. For example, a Uniswap bridge contract would allow users to spend
Aztec L2 funds to perform swaps on mainnet. Bridges are called through the <mark>`DefiBridgeProxy`</mark> <mark>.</mark>

## **7**


**<mark>VULNERABILITY STATISTICS</mark>**


**<u>Severity</u>** **<u>Count</u>**


<u>Critical</u> <u>0</u>


<u>High</u> <u>0</u>


<u>Medium</u> <u>0</u>


<u>Low</u> <u>5</u>


<u>Note</u> <u>11</u>


**<mark>FIXES SUMMARY</mark>**


**<u>Finding</u>** **<u>Severity</u>** **<u>Status</u>**


<u>L01</u> <u>Low</u> <u>[Fixed in pull request #1476](https://github.com/AztecProtocol/aztec2-internal/pull/1476)</u>


<u>L02</u> <u>Low</u> <u>[Fixed in pull request #1515](https://github.com/AztecProtocol/aztec2-internal/pull/1515)</u>


<u>L03</u> <u>Low</u> <u>[Fixed in pull request #1478](https://github.com/AztecProtocol/aztec2-internal/pull/1478)</u>


<u>L04</u> <u>Low</u> <u>Acknowledged</u>


<u>L05</u> <u>Low</u> <u>[Fixed in pull requests #1480 and #1517](https://github.com/AztecProtocol/aztec2-internal/pull/1480)</u>


<u>N01</u> <u>Note</u> <u>[Fixed in pull request #1487](https://github.com/AztecProtocol/aztec2-internal/pull/1487)</u>


<u>N02</u> <u>Note</u> <u>Acknowledged</u>


<u>N03</u> <u>Note</u> <u>[Fixed in pull request #1505](https://github.com/AztecProtocol/aztec2-internal/pull/1505)</u>


<u>N04</u> <u>Note</u> <u>[Fixed in pull request #1501](https://github.com/AztecProtocol/aztec2-internal/pull/1501)</u>


<u>N05</u> <u>Note</u> <u>Acknowledged</u>


<u>N06</u> <u>Note</u> <u>[Fixed in pull request #1502](https://github.com/AztecProtocol/aztec2-internal/pull/1502)</u>


<u>N07</u> <u>Note</u> <u>[Fixed in pull request #1513](https://github.com/AztecProtocol/aztec2-internal/pull/1513)</u>


<u>N08</u> <u>Note</u> <u>[Fixed in pull request #1503](https://github.com/AztecProtocol/aztec2-internal/pull/1503)</u>


<u>N09</u> <u>Note</u> <u>[Fixed in pull request #1506](https://github.com/AztecProtocol/aztec2-internal/pull/1506)</u>


<u>N10</u> <u>Note</u> <u>Acknowledged</u>


<u>N11</u> <u>Note</u> <u>[Fixed in pull request #1504](https://github.com/AztecProtocol/aztec2-internal/pull/1504)</u>


## **8**


**<mark>FINDINGS</mark>**


<mark>LOW SEVERITY</mark>


[L01] LACK OF BOUNDS CHECKING ON ESCAPE HATCH VALUES


The upper and lower bounds for the escape hatch window are set in the <mark>`RollupProcessorV2`</mark>
<u>[constructor](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/processors/RollupProcessorV2.sol#L442)</u> without bounds checking:

```
constructor(uint256 _escapeBlockLowerBound, uint256 _escapeBlockUpperBound) {
_disableInitializers();
rollupState.paused = true;

escapeBlockLowerBound = _escapeBlockLowerBound;
escapeBlockUpperBound = _escapeBlockUpperBound;
}

```

If these values are inverted during deployment, the escape hatch will never open when the
<mark>`RollupProcessor`</mark> calls <mark>`getEscapeHatchStatus`</mark> <mark>.</mark> Because <mark>`escapeBlockLowerBound`</mark> and
<mark>`escapeBlockUpperBound`</mark> are declared <mark>`immutable`</mark>, a new <mark>`RollupProcessorV2`</mark> contract will have
to be deployed to update the values.


RECOMMENDATION


Consider adding a check that ensures <mark>`escapeBlockUpperBound`</mark> is greater than
<mark>`escapeBlockLowerBound`</mark> .


UPDATE


Fixed in pull request #1476 (commit hash <mark>`fba1e694bc1ed2ee0679072d9b08c6debc2b248b`</mark> <mark>)</mark>, as
recommended.

## **9**


[L02] MISSING <mark>`EXTCODESIZE`</mark> CHECK WHEN USING LOW-LEVEL <mark>`CALL`</mark>


The <mark>`[safeTransferTo](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/libraries/TokenTransfers.sol#L20)`</mark> and <mark>`[safeTransferFrom](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/libraries/TokenTransfers.sol#L65)`</mark> functions in <mark>`TokenTransfers.sol`</mark> use the low-level
<mark>`call`</mark> instruction when transferring tokens. The <mark>`call`</mark> instruction will return <mark>`true`</mark> when there is no code
[present at an address, which is known behavior. However, neither function checks to ensure code is](https://docs.soliditylang.org/en/v0.8.10/control-structures.html?highlight=.call#error-handling-assert-require-revert-and-exceptions)
present at the target address. While it is unlikely that an address with no code would be added to the
<mark>`supportedAssets`</mark> whitelist, in the event that this did occur the <mark>`safeTransferTo`</mark> and
<mark>`safeTransferFrom`</mark> functions would erroneously succeed.


RECOMMENDATION


Consider adding a check using the <mark>`extcodesize`</mark> instruction to ensure there is code present at a target
address before using <mark>`call`</mark> <mark>.</mark>


UPDATE


Fixed in pull request #1515 (commit hash <mark>`75d31df88d3e796760e8ae6e581d9259b16a4c2b`</mark> <mark>)</mark>, as
recommended.


[L03] INCORRECTLY SET PROTOCOL GAS LIMIT CAN RENDER AN ASSET OR BRIDGE NONFUNCTIONAL


In <mark>`RollupProcessorV2.sol`</mark> <mark>,</mark> the <mark>`setSupportedBridge`</mark> and <mark>`setSupportedAsset`</mark> functions call
<mark>`[sanitiseBridgeGasLimit](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/processors/RollupProcessorV2.sol#L1507)`</mark> and <mark>`[sanitiseAssetGasLimit](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/processors/RollupProcessorV2.sol#L1522)`</mark> respectively to adjust contract gas limits
within the bounds set by the protocol.


If a new asset or bridge specifies a gas limit that is above <mark>`MAX_BRIDGE_GAS_LIMIT`</mark> or
<mark>`MAX_ERC20_GAS_LIMIT`</mark>, the sanitise function will cap the limit to the corresponding max. If
<mark>`MAX_*_GAS_LIMIT`</mark> is lower than what the bridge or asset needs to function, the newly added contract
will be unusable. Failing fast, rather than capping the limit is more clear to users and prevents the
possibility of adding non-functional assets and bridges.


RECOMMENDATION


Consider reverting if a user specifies a gas limit that is greater than <mark>`MAX_BRIDGE_GAS_LIMIT`</mark> or
<mark>`MAX_ERC20_GAS_LIMIT`</mark> .


UPDATE


Fixed in pull request #1478 (commit hash <mark>`8bfc8d1f034438b6aa9777dc7ad9b44824887148`</mark> <mark>)</mark>, as
recommended.

## **10**


[L04] TRUNCATION OF <mark>`BLOCK.TIMESTAMP`</mark> CAN LEAVE ESCAPE HATCH OPEN INSIDE DELAY
WINDOW


Timestamps for the latest rollup and asset cap updates are tracked in the <mark>`RollupProcessorV2`</mark>
contract with <mark>`lastRollupTimeStamp`</mark> and <mark>`lastUpdatedTimestamp`</mark> <mark>.</mark> Both of these variables are
<mark>`uint32`</mark> types.


Because <mark>`block.timestamp`</mark> <u>[is of type](https://docs.soliditylang.org/en/v0.8.10/units-and-global-variables.html#block-and-transaction-properties)</u> <u><mark>`uint`</mark></u> and <mark>`delayBeforeEscapeHatch`</mark> is of type <mark>`uint32`</mark>, the
[following condition will never be true once](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/processors/RollupProcessorV2.sol#L1464) <mark>`block.timestamp`</mark> exceeds 2**32:

```
if (block.timestamp < lastRollupTimeStamp + delayBeforeEscapeHatch) {
isOpen = false;
}

```

This will prevent the getEscapeHatchStatus function from closing the hatch until
<mark>`delayBeforeEscapeHatch`</mark> has elapsed.


RECOMMENDATION


Consider storing <mark>`lastRollupTimeStamp`</mark> in a <mark>`uint256`</mark> type.


UPDATE


Acknowledged. Aztec’s statement for this issue:


_The time frame that the contract needs to stay active for this to become an issue, is longer_
_than what we expect the specific instance of the project to survive._

## **11**


[L05] <mark>`LASTROLLUPTIMESTAMP`</mark> CAN BE INCORRECTLY SET


The <mark>`lastRollupTimeStamp`</mark> variable in the <mark>`[RollupProcessorV2](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/processors/RollupProcessorV2.sol#L337-L338)`</mark> contract is used to calculate the
escape hatch delay and is updated when a new rollup is processed. It is also updated whenever
<mark>`setCapped`</mark> is called. Repeated calls to <mark>`setCapped(true)`</mark> would increase the
<mark>`lastRollupTimeStamp`</mark> at a quicker rate than expected and reset the delay window in
<mark>`getEscapeHatchStatus`</mark> :

```
function setCapped(bool _isCapped) external onlyRole(OWNER_ROLE)
noReenter {
rollupState.capped = _isCapped;
if (_isCapped) {
lastRollupTimeStamp = uint32(block.timestamp);
}
emit CappedUpdated(_isCapped);
}

```

This could only be performed by holders of the <mark>`OWNER_ROLE`</mark> <mark>,</mark> so the likelihood of this being abused is
low.


RECOMMENDATION


Consider returning early from the <mark>`setCapped`</mark> function if <mark>`rollupState.capped`</mark> is equal to
<mark>`_isCapped`</mark> <mark>.</mark>


UPDATE


[Fixed in pull requests #1480](https://github.com/AztecProtocol/aztec2-internal/pull/1480) (commit hash <mark>`c93bf80a89d9b116224ed69f9a49cf0714231201`</mark> <mark>)</mark> and
<u>[#1517](https://github.com/AztecProtocol/aztec2-internal/pull/1517)</u> (commit hash <mark>`895ba7a0218041a3661466136b7ef1725b53c4ef`</mark> <mark>)</mark>, as recommended.

## **12**


<mark>NOTE SEVERITY</mark>


[N01] MISSING BRIDGE ZERO-ADDRESS CHECKS


In <mark>`RollupProcessorV2.sol`</mark> <mark>,</mark> the <mark>`[setDefiBridgeProxy](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/processors/RollupProcessorV2.sol#L586)`</mark> function does not check that the
<mark>`_defiBridgeProxy`</mark> address is nonzero.


If the <mark>`_defiBridgeProxy`</mark> address is set to zero, calls to the proxy will fail until an additional call to
<mark>`setDefiBridgeProxy`</mark> is made to set the correct address.


RECOMMENDATION


Consider checking that the <mark>`_defiBridgeProxy`</mark> address supplied to <mark>`setDefiBridgeProxy`</mark> is
nonzero.


UPDATE


Fixed in pull request #1487 (commit hash <mark>`a11d333fc4234ec787d658b778148e4d72047de6`</mark> <mark>)</mark>, as
recommended. A zero-address check was also added to the <mark>`setVerifier`</mark> function.


## **13**


[N02] BUILD ISSUES


Build errors were encountered when following the steps outlined in <mark>`[getting_started.md](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/markdown/getting_started.md#building)`</mark>


The following errors were encountered when building on MacOS Monterey 12.5.1:

```
/aztec2internal/barretenberg/src/aztec/ecc/curves/bn254/../../groups/./element_impl.
hpp:249:40: [ 27%] Building CXX object _deps/leveldbbuild/CMakeFiles/leveldb.dir/util/options.cc.o
fatal error: use of bitwise '|' with boolean operands [-Wbitwise-instead-oflogical]
const bool edge_case_trigger = x.is_msb_set() | other.x.is_msb_set();

gyp ERR! stack Error: Command failed: /opt/homebrew/bin/python3 -c import
sys; print "%s.%s.%s" % sys.version_info[:3];
gyp ERR! stack  File "<string>", line 1
gyp ERR! stack   import sys; print "%s.%s.%s" % sys.version_info[:3];
gyp ERR! stack         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
gyp ERR! stack SyntaxError: Missing parentheses in call to 'print'. Did you
mean print(...)?

```

The following errors were encountered when building on Ubuntu 20.04:

```
In file included from /aztec2internal/barretenberg/src/aztec/stdlib/hash/pedersen/../../primitives/compose
rs/composers.hpp:4:
/aztec2internal/barretenberg/src/aztec/plonk/composer/plookup_composer.hpp:126:14:
fatal error: no template named 'optional' in namespace 'std'
std::optional<uint32_t> key_b_index = std::nullopt);
~~~~~^

```

The following additional steps were taken to successfully build on MacOS Monterey 12.5.1:


 - Run <mark>`brew install llvm libomp clang-format`</mark> as per the instructions in Barretenberg’s
```
   bootstrap script
```

 - Squelch warnings that caused <mark>`fatal error: use of bitwise '|' with boolean`</mark>
<mark>`operands [-Wbitwise-instead-of-logical]`</mark> in <mark>`barretenberg`</mark>

 - Alias <mark>`nproc`</mark> to <mark>`sysctl -n hw.physicalcpu`</mark>

 - Install Python 2.7 as it is required by <mark>`sqlite3`</mark>


Ensuring builds work on fresh systems will decrease developer and auditor spin-up time.


RECOMMENDATION


Consider re-testing builds on the supported platforms, and updating documentation accordingly.

## **14**


UPDATE


Acknowledged. Aztec’s statement on the issue:


_We are actively working on translating our tests to use Foundry and repackaging the_
_blockchain sub-dir, such that it can be run as a standalone for developers and auditors to_
_reduce spin-up time._


## **15**


[N03] REDUNDANT INPUT VALIDATION IN <mark>`WITHDRAW`</mark>


The <mark>`withdraw`</mark> function in the <mark>`[RollupProcessorV2](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/processors/RollupProcessorV2.sol#L1331-L1353)`</mark> contract contains redundant input validation.
Both the <mark>`validateAssetIdIsNotVirtual`</mark> modifier and the <mark>`getSupportedAsset`</mark> function call
ensure that the <mark>`_assetId`</mark> input is non-virtual.


RECOMMENDATION


Consider removing the extraneous validation check.


UPDATE


Fixed in pull request #1505 (commit hash <mark>`b7805e2ebf81e1fe9752e0ff28f09543f8fcb04f`</mark> <mark>)</mark>, as
recommended.


[N04] HARDCODED GAS VALUES


The <mark>`RollupProcessorV2`</mark> contract uses assembly <mark>`call`</mark> opcodes to perform transfers in the following
locations:


 - <mark>`RollupProcessorV2.sol`</mark> <mark>,</mark> <u>[line 1304](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/processors/RollupProcessorV2.sol#L1304)</u>

 - <mark>`RollupProcessorV2.sol`</mark> <mark>,</mark> <u>[line 1341](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/processors/RollupProcessorV2.sol#L1341)</u>


The rationale for ignoring <mark>`call`</mark> return values is explained in comments, but the rationale for using hardcoded gas values (50000 and 30000) is not.


RECOMMENDATION


Consider adding comments to justify the use of fixed gas parameters over the <mark>`gas()`</mark> opcode.


UPDATE


Fixed in pull request #1501 (commit hash <mark>`516d12fc369dce7e99ac5c32e286ec3cf5f7eaa6`</mark> <mark>)</mark>, as
recommended.

## **16**


[N05] USE OF FLOATING COMPILER VERSION PRAGMA


All contracts in this audit float their Solidity compiler versions (e.g. <mark>`pragma solidity >=0.8.4`</mark> ).


Locking the compiler version prevents accidentally deploying the contracts with a different version than
what was used for testing. The current pragma prevents contracts from being deployed with an
outdated compiler version, but still allows contracts to be deployed with newer compiler versions that
may have higher risks of undiscovered bugs.


It is best practice to deploy contracts with the same compiler version that is used during testing and
development (in this case <mark>`0.8.10`</mark> <mark>)</mark> .


RECOMMENDATION


Consider locking the compiler pragma to the specific version of the Solidity compiler used during testing
and development.


UPDATE


Acknowledged. Aztec’s statement on the issue:


_The pragma is locked through the configuration of deployment. We let the pragma float in the_
_code to allow easy patching if an issue should be found in the used version (0.8.10)._


[N06] INCORRECT DOCUMENTATION


Throughout the codebase, there are comments that do not match the referenced code.


The following comments mention a “92-byte length parameter in the <mark>`signature`</mark> byte array” when the
code uses a 96-byte length:


 - <mark>`RollupProcessorV2.sol`</mark> <u>[line 1224](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/processors/RollupProcessorV2.sol#L1224)</u>

 - <mark>`RollupProcessorV2.sol`</mark> <u>[line 1234](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/processors/RollupProcessorV2.sol#L1234)</u>

 - <mark>`RollupProcessorLibrary.sol`</mark> <u>[line 104](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/libraries/RollupProcessorLibrary.sol#L104)</u>


The following comments also do not match the implementation:


 - <mark>`DefiBridgeProxy.sol`</mark> <mark>,</mark> <u>[Line 70:](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/DefiBridgeProxy.sol#L70)</u> <mark>`receiveEthPayment`</mark> should be <mark>`receiveEthFromBridge`</mark>


Inaccurate comments impact code readability, and can cause developers to make errors in the future.


RECOMMENDATION


Consider updating code comments to match the implementation.


UPDATE


Fixed in pull request #1502 (commit hash <mark>`659f896717e4ff8332ee6308d33de89a520dec60`</mark> <mark>)</mark>, as
recommended.

## **17**


[N07] SHADOWING WITH FUNCTION PARAMETER


In <mark>`PermitHelper.sol`</mark>, the <mark>`[depositPendingFundsPermit](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/periphery/PermitHelper.sol#L49)`</mark> and
<mark>`[depositPendingFundsPermitNonStandard](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/periphery/PermitHelper.sol#L76)`</mark> functions shadow the <mark>`owner`</mark> getter function defined in
OpenZeppelin’s <mark>`[Ownable.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.6.0/contracts/access/Ownable.sol)`</mark> <mark>:</mark>

```
function depositPendingFundsPermit(
uint256 assetId,
uint256 amount,
address owner, <--- also defined in Ownable.sol
uint256 deadline,
uint8 v,
bytes32 r,
bytes32 s
)

```

The parameter is used in the following locations:


 - <mark>`PermitHelper.sol`</mark> [, line 62](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/periphery/PermitHelper.sol#L62)

 - <mark>`PermitHelper.sol`</mark> [, line 90](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/periphery/PermitHelper.sol#L90)


There is no security impact in this particular case, as the functions in <mark>`PermitHelper.sol`</mark> behave
correctly. Regardless, name collisions and variable shadowing can lead to confusion when reading or
writing code.


RECOMMENDATION


Consider renaming the <mark>`owner`</mark> parameter in <mark>`PermitHelper.sol`</mark> or prefixing the name with an
underscore to avoid shadowing.


UPDATE


Fixed in pull request #1513 (commit hash <mark>`a8dffd1d7ecf84c7df2bdfd6d98b374e21b91272`</mark> <mark>)</mark>, as
recommended. Function parameters in <mark>`PermitHelper.sol`</mark> are now prefixed with underscores.

## **18**


[N08] TYPOGRAPHICAL ERRORS


The following lines contain typographical errors:


 - <mark>`RollupProcessorV2.sol`</mark> <mark>,</mark> <u>[line 1113:](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/processors/RollupProcessorV2.sol#L1113)</u> <mark>`If does not return`</mark> should be <mark>`It does not`</mark>
```
   return
```

 - <mark>`RollupProcessorV2.sol`</mark> <mark>,</mark> <u>[line 1239:](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/processors/RollupProcessorV2.sol#L1239)</u> <mark>`sheild`</mark> should be <mark>`shield`</mark> .

 - <mark>`RollupProcessorLibrary.sol`</mark> <mark>,</mark> <u>[line 110:](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/libraries/RollupProcessorLibrary.sol#L110)</u> <mark>`sheild`</mark> should be <mark>`shield`</mark> <mark>.</mark>


RECOMMENDATION


Consider making the suggested changes to fix the typographical errors.


UPDATE


[Fixed in pull request #1503](https://github.com/AztecProtocol/aztec2-internal/pull/1503) (commit hash <mark>`e3c062fc5e46cbdb2d52b4515a6377863c0d60bc`</mark> <mark>)</mark>, as
recommended.


[N09] USE OF LONG NUMERICAL LITERALS


Long numerical literals are used in the <mark>`RollupProcessorV2`</mark> and <mark>`Decoder`</mark> contracts.


<u>[Underscores](https://docs.soliditylang.org/en/v0.8.10/types.html#rational-and-integer-literals)</u> can separate digits of numeric literals to aid in readability. The following bitmasks defined
in <mark>`RollupProcessorV2.sol`</mark> <mark>`Decoder.sol`</mark> will be easier to read and verify with underscores
separating words (e.g. <mark>`0xffff_ffff`</mark> instead of <mark>`0xffffffff`</mark> <mark>)</mark> :


 - <mark>`RollupProcessorV2.sol`</mark> <mark>,</mark> <u>[lines 256-259](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/processors/RollupProcessorV2.sol#L256-L259)</u>

 - <mark>`RollupProcessorV2.sol`</mark> <mark>,</mark> <u>[line 266](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/processors/RollupProcessorV2.sol#L266)</u>

 - <mark>`Decoder.sol`</mark> [, line 114](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/Decoder.sol#L114)


These changes will increase code readability for developers and auditors.


RECOMMENDATION


Consider adding underscores to separate digits for long numerical literals.


UPDATE


Fixed in pull request #1506 (commit hash <mark>`6ab1ff65be153b970589ac88cc08311de0a244ab`</mark> <mark>)</mark>, as
recommended.

## **19**


[N10] INCOMPLETE INITIALIZATION


The <mark>`RollupProcessorV2`</mark> contract adds two new access roles ( <mark>`LISTER_ROLE`</mark> and <mark>`RESUME_ROLE`</mark> <mark>)</mark> but
does not call <mark>`_grantRole`</mark> in its <mark>`initialize`</mark> function. This behavior is different than the original
<mark>`[RollupProcessor](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/RollupProcessor.sol#L424-L426)`</mark> contract. The <mark>`LISTER_ROLE`</mark> and <mark>`RESUME_ROLE`</mark> must be configured after
deployment.


If the <mark>`RollupProcessorV2`</mark> is paused before the <mark>`RESUME_ROLE`</mark> is configured the normal unpause
workflow will not work as intended, requiring the <mark>`OWNER_ROLE`</mark> to unpause the contract.


RECOMMENDATION


Add the configuration of the <mark>`LISTER_ROLE`</mark> and the <mark>`RESUME_ROLE`</mark> to the <mark>`initialize`</mark> function in
<mark>`RollupProcessorV2.sol`</mark> .


UPDATE


Acknowledged. Aztec’s statement for the issue:


_We acknowledge this, but are not configuring the roles in the initializer as the addresses of the_
_holders are not “stable” and we are very close to code size limits for the current optimizer_
_config._

## **20**


[N11] NONSTANDARD USE OF UNNAMED FUNCTION PARAMETER


The <mark>`processRollup`</mark> function in the <mark>`[RollupProcessorV2](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/processors/RollupProcessorV2.sol#L661-L664)`</mark> contract contains an unnamed parameter
that is used in the <mark>`decodeProof`</mark> function by accessing calldata:

```
function processRollup(
bytes calldata, /* encodedProofData */
bytes calldata _signatures
) external override(IRollupProcessor) whenNotPaused allowAsyncReenter {

```

[This technique works and the reasoning is documented in the decoder, but according to the Solidity](https://github.com/AztecProtocol/aztec2-internal/blob/9558b62604c72e5d1ea70f330df057eaeae10bd1/blockchain/contracts/Decoder.sol#L57)
<u>[documentation](https://docs.soliditylang.org/en/v0.8.10/control-structures.html#omitted-function-parameter-names)</u> it is not a normal use case:


The names of unused parameters (especially return parameters) can be omitted. Those
parameters will still be present on the stack, but they are inaccessible.


An additional <mark>`@dev`</mark> comment in the <mark>`processRollup`</mark> docstring will make it clear to readers why
<mark>`encodedProofData`</mark> is ignored, and how it will be used later.


RECOMMENDATION


Consider documenting why the <mark>`encodedProofData`</mark> parameter is unnamed, and how it is being
accessed in <mark>`decodeProof`</mark> .


UPDATE


Fixed in pull request #1504 (commit hash <mark>`5165e20a685e6a8ad3f37d20beff64bf201d7db2`</mark> <mark>)</mark>, as
recommended.

## **21**


**<mark>APPENDIX</mark>**


<mark>APPENDIX A: SEVERITY DEFINITIONS</mark>


**<u>Severity</u>** **<u>Definition</u>**


Critical This issue is straightforward to exploit and is likely to lead to catastrophic impact for client’s
<u>reputation and can lead to financial loss for client or users.</u>


High This issue is difficult to exploit and is likely to lead to catastrophic impact for client’s
<u>reputation and can lead to financial loss for client or users.</u>


Medium This issue is important to fix and puts a subset of users’ data at risk and is possible to lead to

<u>moderate financial impact.</u>


Low This issue is not exploitable in a recurring basis and cannot have a significant impact on
<u>execution.</u>


<u>Note</u> <u>This issue does not pose an immediate risk but is relevant to security best practices.</u>

## **22**


<mark>APPENDIX B: FILES IN SCOPE</mark>
```
Decoder.sol
DefiBridgeProxy.sol
libraries/RollupProcessorLibrary.sol
libraries/TokenTransfers.sol
periphery/PermitHelper.sol
processors/RollupProcessorV2.sol

```

## **23**


