# `Trust` `Security`

### Smart Contract Audit Optimism Bedrock upgrade
#### 11/01/2024


Trust Security Optimism Bedrock upgrade

### Executive summary

###### **FINDINGS**


**1, High**



**3,**
**Medium**



<u>Category</u> <u>Rollups</u>
<u>Audited file count</u> <u>8</u>
Auditor Trust
<u>Gjaldon</u>
<u>Time period</u> <u>11/12-25/12</u>



**8, Low**



Findings


<u>Severity</u> <u>Total</u> <u>Fixed</u> <u>Acknowledged</u>
<u><mark>High</mark></u> <u>1</u> <u>1</u> <u>-</u>
<u><mark>Medium</mark></u> <u>3</u> <u>-</u> <u>3</u>
<u><mark>Low</mark></u> <u>8</u> <u>1</u> <u>7</u>


Centralization score


Centralized Decentralized


Signature
## Digitally signed by Trust Date: 2024.01.11 15:34:54 +02'00'


Trust Security Optimism Bedrock upgrade

EXECUTIVE SUMMARY 1


DOCUMENT PROPERTIES 3


**Versioning** **3**


**Contact** **3**


INTRODUCTION 4


**Scope** **4**


**Repository details** **4**


**About Trust Security** **4**


**About the Auditors** **5**


**Disclaimer** **5**


**Methodology** **5**


QUALITATIVE ANALYSIS 6


FINDINGS 7


**High severity findings** **7**
TRST-H-1 Anyone can execute a withdrawal twice by abusing the upgrade procedure 7


**Medium severity findings** **8**
TRST-M-1 Anyone can make a victim’s withdrawal TX revert, delaying withdrawals and making
them more expensive 8
TRST-M-2 Insufficient calldata gas stipend could make initial delivery fail 9
TRST-M-3 Messages of over 50k bytes can be permanently lost due to unaccounted gas costs 10


**Low severity findings** **13**
TRST-L-1 User is forced to overpay for deposit gas due to calldata gas calculation 13
TRST-L-2 The metering logic in OptimismPortal will be incorrect immediately after the upgrade 14
TRST-L-3 A storage slot is accidentally skipped 15
TRST-L-4 Upgrades are resetting the state of unused storage slots 16
TRST-L-5 The gas buffer set is insufficient, leading to risks of unexpected reverts 17
TRST-L-6 OptimismPortal consumes all forwarded gas even if the TX is undeliverable 18
TRST-L-7 Users can underpay gas for contract creations, which would make them fail 20
TRST-L-8 Different ERC20Factory addresses between chains makes it impossible to deploy ERC20s
with the same address on all the chains 21


**Additional recommendations** **21**
Including constructor arguments in the salt is redundant 21


**Centralization risks** **22**
TRST-CR-1 The SuperchainConfig guardian can pause all Superchains 22


Trust Security Optimism Bedrock upgrade

### Document properties


Versioning


<u>Version</u> <u>Date</u> <u>Description</u>
<u>0.1</u> <u>25/12/23</u> <u>Client report</u>
<u>0.2</u> <u>11/01/23</u> <u>Mitigation review</u>


Contact


**Trust**


trust@trust-security.xyz


Trust Security Optimism Bedrock upgrade

### Introduction


Trust Security has conducted an audit at the customer's request. The audit is focused on
uncovering security issues and additional bugs contained in the code defined in scope. Some
additional recommendations have also been given when appropriate.


Scope


[The scope is all changes made in the contracts below, since the Sherlock contest commit.](https://github.com/ethereum-optimism/optimism/commit/9b9f78c6613c6ee53b93ca43c71bb74479f4b975)


  - SuperchainConfig.sol

  - L1CrossDomainMessenger.sol

  - L1ERC721Bridge.sol

  - L1StandardBridge.sol

  - OptimismPortal.sol

  - CrossDomainMessenger.sol

  - ERC721Bridge.sol

  - StandardBridge.sol


Specifically, the following mechanisms have been given special attention:


   - Mitigation of contest’s reported gas issues and additional gas-related flaws

   - Examination of storage slots and the impact of upgrades on their safety

   - Changes in reentrancy protection of cross-chain messaging

   - Integration of the new SuperchainConfig contract, including the pausing functionality.

   - Upgrade procedure of Bedrock contracts and potential side-effects


Repository details


  - **Repository URL:** <u>[https://github.com/ethereum-optimism/optimism](https://github.com/ethereum-optimism/optimism)</u>

  - **Commit hash:** d1651bb22645ebd41ac4bb2ab4786f9a56fc1003

  - **Mitigation review commit hash:** 81b56fee40f96c798174115c375f41c3d2ff9d40


About Trust Security


Trust Security has been established by top-end blockchain security researcher Trust, in order
to provide high quality auditing services. Trust is a leading auditor at competitive auditing
service Code4rena, reported several critical issues to Immunefi bug bounty platform and is
serving as a Code4rena judge.


Trust Security Optimism Bedrock upgrade


About the Auditors


Trust has established a dominating presence in the smart contract security ecosystem since
2022. He is a resident on the Immunefi, Sherlock and C4 leaderboards and is now focused in
auditing and managing audit teams under Trust Security. When taking time off auditing & bug
hunting, he enjoys assessing bounty contests in C4 as a Supreme Court judge.


Gjaldon transitioned to Web3 after 10+ years working as a Web2 engineer. His first foray into
Web3 was achieving first place in a smart contracts hackathon and then later securing a
project grant to write a contract for Compound III. He shifted to Web3 security and in 3
months achieved top 2-5 in two contests with unique High and Medium findings and joined
exclusive top-tier auditing firms.


Disclaimer


Smart contracts are an experimental technology with many known and unknown risks. Trust
Security assumes no responsibility for any misbehavior, bugs or exploits affecting the audited
code or any part of the deployment phase.


Furthermore, it is known to all parties that changes to the audited code, including fixes of
issues highlighted in this report, may introduce new issues and require further auditing.


Methodology


In general, the primary methodology used is manual auditing. The entire in-scope code has
been deeply looked at and considered from different adversarial perspectives. Any additional
dependencies on external code have also been reviewed.


Trust Security Optimism Bedrock upgrade

### Qualitative analysis


##### **Metric Rating Comments**

Code complexity **Good** The code is modularized



**Good**



The code is modularized
well to reduce complexity.



Documentation **Excellent** Project is mostly very well

documented.
Best practices **Excellent** Project consistently



Documentation



**Excellent**

**Excellent**



Best practices **Excellent** Project consistently

adheres standards. to industry
Centralization risks **Moderate** A compromised multisig



**Moderate** A compromised multisig
account can cause
<u>irrecoverable damage.</u>


Trust Security Optimism Bedrock upgrade

### Findings


High severity findings


TRST-H-1 Anyone can execute a withdrawal twice by abusing the upgrade procedure

  - **Category:** Reentrancy attacks, frontrunning attacks, initialization flaws

  - **Source:** <u>[CrossDomainMessenger.sol](https://github.com/ethereum-optimism/optimism/)</u>

  - **Status:** Fixed


**Description**


In Optimism architecture, every withdrawal can be performed once. The recommended way
is to use the CrossDomainMessenger which protects against any delivery issues by storing
failed messages, so they may be replayed. In _CrossDomainMessenger::relayMessage()_, the
<u>[following code](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol#L267-L270)</u> serves as a reentrancy guard:


It checks that **xDomainMsgSender** is not the default L2 sender. If it is not, then it will proceed
to fail the message. Note that because **successfulMessages[versionedHash]** is checked before
the external call and set to **true** after it, the code pattern is otherwise susceptible to
reentrancy attacks.


The _CrossDomainMessenger_ also has some <u>[initialization code](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol#L356-L358)</u> that is run every time it is
upgraded. This initializer resets the **xDomainMsgSender** and is what opens the exploit
enabling an attacker to steal funds via reentrancy.


<mark>To perform the exploit, the following steps must be taken by the attacker:</mark>


<mark>1.</mark> <mark>Wait for a signed upgrade transaction from Optimism. This was intended to be</mark>
<mark>delivered by the public mempool.</mark>
<mark>2.</mark> <mark>Once the signed upgrade transaction is available, front-run by running</mark> _<mark>it inside a</mark>_
_<mark>withdrawal transaction</mark>_ <mark>.</mark>
<mark>3.</mark> <mark>The attacker's withdrawal payload will call their own contract which would run the</mark>
<mark>upgrade transaction and then re-enter</mark> _<mark>relayMessage()</mark>_ <mark>with their own same</mark>
<mark>withdrawal message.</mark>
<mark>4.</mark> <mark>The reentrancy will succeed since</mark> _<mark>xDomainMsgSender</mark>_ <mark>has been reset by the upgrade.</mark>


<mark>The attacker must also satisfy the following with their withdrawal message:</mark>


<mark>1.</mark> <mark>It must be a failed withdrawal so they can re-enter relayMessage(). A fresh withdrawal</mark>
<mark>cannot reenter as it checks</mark> **<mark>failedMessages[versionedHash]</mark>** <mark>is</mark> **<mark>true</mark>** <mark>.</mark>
<mark>2.</mark> <mark>It must have a value set. The amount for value is the amount that they will able to</mark>
<mark>drain from the contract.</mark>


Trust Security Optimism Bedrock upgrade

<mark>The funds at risk for this exploit is the ETH balance of the L1CrossDomainMessenger contract.</mark>
It will have ETH from all the failed messages with attached msg.value that are pending replay.


**Recommended mitigation**


<mark>The following mitigations will address the issue:</mark>


<mark>-</mark> <mark>When setting the state of</mark> **<mark>xDomainMsgSender</mark>** <mark>in</mark> _<mark>__CrossDomainMessenger_init()</mark>_ <mark>,</mark>
<mark>verify it is previously</mark> **<mark>zero</mark>** <mark>(meaning it is freshly deployed, not upgraded).</mark>

<mark>-</mark> <mark>Add another check that</mark> **<mark>successfulMessages</mark>** <mark>for the message is still false after the</mark>
<mark>external call.</mark> **<mark>successfulMessages</mark>** <mark>only becomes true at this point if the external call</mark>
<mark>has successfully re-entered</mark> _<mark>relayMessage()</mark>_ <mark>.</mark>

<mark>-</mark> <mark>Set</mark> **<mark>successfulMessages[versionedHash] = true</mark>** <mark>before the external call similar to the</mark>
<mark>replay protection that exists in</mark> _<mark>[OptimismPortal](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/L1/OptimismPortal.sol#L328)</mark>_ <mark>.</mark>


**Team response**


<u>[Fixed.](https://github.com/ethereum-optimism/optimism/pull/8864)</u>


**Mitigation Review**


The fix implements two of the recommended methods of mitigating the issue, which is
sufficient to address the reentrancy issue. The changes are the following:


   - On initialize, **<u>[xDomainMsgSender](https://github.com/ethereum-optimism/optimism/pull/8864/files#diff-a860b6e33b2c00fee38e1a78bb8c449475078a08c2326abdf9a3bc9fba84e37eR360-R366)</u>** is no longer reset to zero when it has already been
previously set.

   - An <u>[assertion is added to ensure that](https://github.com/ethereum-optimism/optimism/pull/8864/files#diff-a860b6e33b2c00fee38e1a78bb8c449475078a08c2326abdf9a3bc9fba84e37eR291-R293)</u> **successfulMessages** is still false after the external
call.


[The fix also includes an added protective measure](https://github.com/ethereum-optimism/optimism/pull/8864/files#diff-f5f7dc90c748b7d98110fa1cc80f3bedd5aa9f299b691c51b9bb473a20b526caR112-R114) against reentrancy for _OptimismPortal_ .


Medium severity findings


TRST-M-1 Anyone can make a victim’s withdrawal TX revert, delaying withdrawals and
making them more expensive

  - **Category:** Griefing attacks, reentrancy attacks

  - **Source:** <u>[CrossDomainMessenger.sol](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol#L211)</u>

  - **Status:** Acknowledged


**Description**


<mark>An attacker can grief other users by forcing their withdrawals to fail for their initial</mark>
<mark>submissions. This leads to the victims having to manually replay their own withdrawals and</mark>
cover the gas costs for these transactions on top of the reverting transaction.


<mark>Below are the steps to execute the griefing:</mark>


<mark>1.</mark> <mark>Attacker sends a withdrawal message that is run in the</mark> _<mark>L1CrossDomainMessenger</mark>_ <mark>.</mark>
<mark>2.</mark> <mark>The withdrawal message calls the attacker's contract which then calls</mark>
_<mark>OptimismPortal::finalizeWithdrawalTransaction()</mark>_ <mark>to finalize the withdrawal of the</mark>
<mark>target user.</mark>


Trust Security Optimism Bedrock upgrade

<mark>3.</mark> <mark>When the target user's withdrawal is relayed, it reenters</mark> _<u><mark>[relayMessage](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol#L211)</mark></u>_ <mark>[which fails the](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol#L269-L272)</mark>
<u><mark>[message](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol#L269-L272)</mark></u> <mark>due to the reentrancy guard.</mark>
<mark>4.</mark> <mark>Since</mark> <mark>the</mark> <mark>call</mark> <mark>to</mark> _<mark>L1CrossDomainMessenger::relayMessage</mark>_ <mark>did</mark> <mark>not</mark> <mark>revert,</mark>
<mark>[the withdrawal is considered finalized in the](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/L1/OptimismPortal.sol#L340-L347)</mark> _<mark>OptimismPortal</mark>_ <mark>.</mark>


**Recommended mitigation**


<mark>Consider refactoring to revert in a reentrant flow, while adding safeguards in place not to brick</mark>
<mark>transactions. Note that due to the fragile nature of the code, there may be dangerous side</mark>
<mark>effects.</mark>


**Team response**


Acknowledged. This will be tracked and addressed in future upgrades.


TRST-M-2 Insufficient calldata gas stipend could make initial delivery fail

  - **Category:** Gas-related issues

  - **Source:** <u>[CrossDomainMessenger.sol](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol#L211)</u>

  - **Status:** Acknowledged


**Description**


<mark>When sending deposit transactions, a user pays for L2 gas costs in L1. The total gas user pays</mark>
for is computed via _<u>[baseGas()](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol#L335-L352)</u>_ <u>:</u>


<mark>Note that in the above calculation, the calldata overhead accounts for only one external call.</mark>
<mark>However, when the deposit transaction is executed in L2, this transaction involves at least 2</mark>


Trust Security Optimism Bedrock upgrade

<mark>external calls. The first external call is the call to</mark> _<u><mark>[relayMessage()](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol#L211-L306)</mark></u>_ <mark>and the second external call</mark>
[is the call to the target address.](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol#L286-L288)


<mark>As far as Optimism is concerned,</mark> **<mark>minGasLimit</mark>** <mark>should be the amount available when running</mark>
<mark>the first instruction in the user's contract, ignoring calldata costs. This means that</mark> _<mark>baseGas()</mark>_
is incorrect and its calldata overhead is insufficient.


<mark>Note that since one copy of calldata costs is accounted for, it is extremely unlikely for the</mark>
_<mark>relayMessage()</mark>_ <mark>call to revert before storing the delivery status. It will presumably fail the</mark>
_<mark>SafeCall.hasMinGas()</mark>_ <mark>check and store the failure immediately. Therefore, impact is limited to</mark>
delay and extra gas spending of the withdrawal process.


**Recommended mitigation**


The correct calculation for calldata overhead costs is:


<mark>This takes into consideration the calldata spending of</mark> _<mark>relayMessage</mark>_ <mark>( The arbitrary payload as</mark>
well as fixed parameters) as well as the target contract calldata (only payload).


**<mark>Team response</mark>**


Acknowledged. This will be tracked and addressed in future upgrades.


TRST-M-3 Messages of over 50k bytes can be permanently lost due to unaccounted gas
costs

  - **Category:** Gas-related issues

  - **Source:** <u>[CrossDomainMessenger.sol](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol#L211)</u>

  - **Status:** Acknowledged


**Description**


<mark>The</mark> _<u><mark>[baseGas()](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol#L335-L352)</mark></u>_ <mark>calculation is intended to account for all the overhead costs for executing a</mark>
deposit or withdrawal transaction.


Trust Security Optimism Bedrock upgrade


<mark>The</mark> _<mark>RELAY_CONSTANT_OVERHEAD</mark>_ <mark>(200K gas units) should cover all the costs in</mark>
_<u><mark>[relayMessage()](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol#L211-L306)</mark></u>_ <mark>up to the</mark> _<u><mark>[hasMinGas()](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol#L268)</mark></u>_ <mark>check. It is critical that</mark> _<mark>relayMessage()</mark>_ <mark>has enough gas</mark>
<mark>to at least store the transaction hash in the</mark> **<mark>failedMessages</mark>** <mark>mapping and return. Otherwise,</mark>
in the case of withdrawals, the transaction could be permanently lost.


<mark>There are dynamic gas costs related to hashing that have not been sufficiently accounted for</mark>
<mark>in</mark> _<mark>baseGas()</mark>_ <mark>. Listed below are the non-negligible operations in terms of gas, in</mark>
_relayMessage()_ :


<u><mark>require(paused()</mark></u> <mark>==</mark> <mark>false, "CrossDomainMessenger: paused");</mark>

<mark>-</mark> <mark>2 cold SLOADs and 1 cold address CALL - ~7000 gas</mark>

<mark>-</mark> <mark>1 or 2 hashing rounds – gas cost is dependent on the length of the message being</mark>
<mark>hashed</mark>


<u><mark>assert(!failedMessages[versionedHash])</mark></u>

<mark>-</mark> <mark>Cold SLOAD - ~2100 gas</mark>


<u><mark>require(successfulMessages[versionedHash]</mark></u> <mark>==</mark> <mark>false, "CrossDomainMessenger: message has already</mark>
<u><mark>been relayed");</mark></u>

<mark>-</mark> <mark>Cold SLOAD - ~2100 gas</mark>


<mark>failedMessages[versionedHash]</mark> <mark>=</mark> <mark>true;</mark>

<mark>-</mark> <mark>Warm zero to non-zero SSTORE - ~20,000 gas</mark>


<mark>emit</mark> <mark>FailedRelayedMessage(versionedHash);</mark>

<mark>-</mark> <mark>LOG1 - ~750 gas</mark>


Total gas costs - ~32,000 + hash costs


The available gas from _baseGas()_ is:


Trust Security Optimism Bedrock upgrade

**200k + 40k + 40k + 5k + minGasLimit * 64/63 = ~285k + minGasLimit**


<mark>Note that the calldata overhead component of</mark> _<mark>baseGas()</mark>_ <mark>is spent on the calldata cost of the</mark>
<mark>call from</mark> _<mark>OptimismPortal</mark>_ <mark>to</mark> _<mark>CrossDomainMessenger</mark>_ <mark>, so it is not included in the calculation</mark>
above.


<mark>To simplify the computations, a</mark> **<mark>minGasLimit</mark>** <mark>of 0 will be assumed, since a user could specify</mark>
<mark>it as such and expect the TX to always be replayable through the CrossDomainMessenger</mark>
<mark>security guarantees. Given the above costs and gas provided by the user, the gas cost of the</mark>
<mark>hashing operations must equal or exceed ~253,000 gas for</mark> _<mark>relayMessage()</mark>_ <mark>to always revert</mark>
due to an OOG error.


To simulate the hashing functions, the following code can be used:



<mark>functiontest_demo() public</mark> <mark>{</mark>



<mark>uint256[]</mark> <u><mark>memory input</mark></u> <u><mark>=</mark></u> <mark>new</mark> <mark>uint256[](1563);</mark>



for (uint256 i; i <u><</u> <u>input.length; i</u> ++ ) {
<mark>input[i]</mark> <mark>=</mark> <mark>type(uint256).max;</mark>



}
<mark>bytes</mark> <u><mark>memory</mark></u> <mark>data</mark> <mark>=</mark> <mark>abi.encodePacked(input);</mark>



console.log("Data length: ", data.length);
<mark>(bool success,)</mark> <mark>=</mark> <mark>address(</mark> <u><mark>this</mark></u> <u><mark>).call(abi.encodeWithSelector(</mark></u> <u><mark>this</mark></u> <mark>.encodeCrossDomainMessageV1.selector, data));</mark>



}



functionencodeCrossDomainMessageV1(bytes <u>memory</u> _data) public {



<mark>uint size;</mark>



uint offset;
<u><mark>assembly</mark></u> <mark>{ offset</mark> <mark>:=</mark> <mark>_data }</mark>



<u>size</u> <u>=</u> <u>offset</u> + _data.length;
<mark>console.log("Starting memory size: ", size);</mark>



uint256 startingGas = <u>gasleft</u> ();
<mark>console.log("Starting gas: ", startingGas);</mark>



bytes <u>memory</u> b = abi.encodeWithSignature("aaaa",_data);
<u><mark>assembly</mark></u> <u><mark>{ offset</mark></u> <mark>:=</mark> <mark>b }</mark>



<u>size</u> <u>=</u> <u>offset</u> + b.length;
<mark>bytes32 kec</mark> <mark>=</mark> <mark>keccak256</mark> <mark>(b);</mark>



bytes <u>memory</u> c = abi.encodeWithSignature("aaaa",_data);
<u><mark>assembly</mark></u> <u><mark>{ offset</mark></u> <mark>:=</mark> <mark>c }</mark>



<u>size</u> <u>=</u> <u>offset</u> + c.length;
<mark>kec</mark> <mark>=</mark> <mark>keccak256</mark> <mark>(c);</mark>



console.log("Total gas used: ", startingGas - <u>gasleft</u> <u>());</u>
<mark>console.log("Completed memory size: ", size);</mark>



}



<mark>In the above simulation (a legacy transaction), the input provided has a size of 50,016 bytes</mark>
<mark>(1563 32-byte elements in the array). The operations related to the hashing function end up</mark>
<mark>consuming a total of 278,012 gas units. Given input data of 50,000 bytes, that is enough for</mark>
_<mark>relayMessage()</mark>_ <mark>to permanently fail for a withdrawal with 0</mark> **<mark>minGasLimit</mark>** <mark>. Tweaking the input</mark>
<mark>to a size of 120,000 bytes, which is the maximum data size allowed in</mark>


Trust Security Optimism Bedrock upgrade

_<mark>OptimismPortal::depositTransaction</mark>_ <mark>, the operations would consume gas totaling 791,575</mark>
units.


<mark>There are two operations responsible for the dynamic gas costs of the hashing functions.</mark>
Below is a simplified version of the hashing function:


_<mark>Keccak256</mark>_ <mark>is largely the SHA3 opcode which has a gas cost that grows linearly based on the</mark>
size of the message being hashed. This is the actual hashing operation.


<mark>However, responsible for the larger chunk of gas usage is</mark> _<mark>abi.encodeWithSignature()</mark>_ <mark>since its</mark>
<mark>output is</mark> _<mark>bytes</mark>_ <mark>data that is always stored in memory. The way Solidity works when working</mark>
<mark>with dynamic data is that it always stores (MSTORE) new data in an unused offset to avoid</mark>
<mark>data corruption. This leads to memory expansion which is a very costly operation that grows</mark>
quadratically based on the size of expanded memory.


<mark>With the hashing function, memory is expanded by the size of the</mark> _<mark>_message</mark>_ <mark>parameter in</mark>
_<mark>relayMessage()</mark>_ <mark>. When the withdrawal is a legacy withdrawal, the memory expansion is twice</mark>
<mark>the size of the</mark> _<mark>_message</mark>_ <mark>since two hashing functions are executed. Note that a 100k v1</mark>
<mark>payload would not cost the same as a 50k v0 payload, as although the loop length and memory</mark>
<mark>expansion size are the same, the memory size starting point is higher for a v1 payload, making</mark>
the quadratic cost higher.


**Recommended mitigation**


<mark>Limit the</mark> _<u><mark>[sendMessage()](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol#L180-L200)</mark></u>_ <mark>payload size using an upper bound calculated from simulation of</mark> **<mark>v1</mark>**
<mark>and</mark> **<mark>v0</mark>** <mark>transactions, making sure to leave margin for inaccuracies.</mark>


**Team response**


Acknowledged. This will be tracked and addressed in future upgrades.


Low severity findings


TRST-L-1 User is forced to overpay for deposit gas due to calldata gas calculation

  - **Category:** Gas-related issues

  - **Source:** <u>[OptimismPortal.sol](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/L1/OptimismPortal.sol#L164-L166)</u>

  - **Status:** Acknowledged


**Description**


Trust Security Optimism Bedrock upgrade

Gas consumption for non-zero bytes in data passed in transactions is 16 while it is 4 for zero
bytes. However, <u>[OptimismPortal::minimumGasLimit](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/L1/OptimismPortal.sol#L164-L166)</u> does not apply this distinction.


This leads to users overpaying for gas.


**Recommended mitigation**


<mark>The following computation can instead be used for minimum gas limit:</mark>


<mark>Note that the above calculation is also used by Scroll. However, it would be fair to consider</mark>
<mark>the heavier gas costs of this loop and opt out of its use.</mark>


**Team response**


Acknowledged. This will be tracked and addressed in future upgrades.


TRST-L-2 The metering logic in OptimismPortal will be incorrect immediately after the
upgrade

  - **Category:** Initialization flaws

  - **Source:** <u>[OptimismPortal.sol](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/L1/OptimismPortal.sol#L118-L122)</u>

  - **Status:** Fixed


**Description**


During upgrades, _<u>[OptimismPortal::initialize](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/L1/OptimismPortal.sol#L118-L122)</u>_ is called:


Trust Security Optimism Bedrock upgrade


The initializer in _ResourceMetering_ does the following:


<mark>Note that the</mark> **<mark>prevBoughtGas</mark>** <mark>is set to 0. It is used for recording all the gas that has been</mark>
<mark>previously bought within the current block and is used to ensure that the</mark> _<u><mark>[maxResourceLimit](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/L1/ResourceMetering.sol#L123-L127)</mark></u>_
<u><mark>[is not exceeded.](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/L1/ResourceMetering.sol#L123-L127)</mark></u>


<mark>In effect, upgrades reset</mark> **<mark>prevBoughtGas</mark>** <mark>and allow users to go beyond the</mark> **<mark>maxResourceLimit</mark>** <mark>.</mark>


**Recommended mitigation**


<mark>Remove the resetting of the gas market in</mark> _<mark>ResourceMetering</mark>_ <mark>'s initializer.</mark>


**Team response**


<u>[Fixed.](https://github.com/ethereum-optimism/optimism/pull/8639)</u>


**Mitigation Review**


The **ResourceParams** in _ResourceMetering’s_ [initializer is no longer reset when it has already](https://github.com/ethereum-optimism/optimism/pull/8639/files#diff-674d74f8728f924a833316b38f3c277b467c7cfbbd0536da18b9344a05c1b22aR158-R160)
been previously set.


TRST-L-3 A storage slot is accidentally skipped

  - **Category:** Storage collision issues

  - **Source:** <u>[CrossDomainMessenger.sol](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol)</u>

  - **Status:** Acknowledged


**Description**


A previous version of _CrossDomainMessenger_ had a **reentrancyLocks** state variable. This older
version had the following gap size:


Trust Security Optimism Bedrock upgrade


The current version of _CrossDomainMessenger_ no longer has the **reentrancyLocks** state
variable. However, its gap size has increased to 44.


<mark>The latest</mark> _<mark>CrossDomainMessenger</mark>_ <mark>is now using 1 more storage slot than it should.</mark>


**Recommended mitigation**


<mark>The latest</mark> _<mark>CrossDomainMessenger</mark>_ <mark>should have a gap size of 43 so that its total storage slots</mark>
<mark>would be a multiple of 50. With a gap size of 43, its total storage slots would be 250, which is</mark>
<mark>a multiple of 50.</mark>


**Team response**


Acknowledged. This will be tracked and addressed in future upgrades.


TRST-L-4 Upgrades are resetting the state of unused storage slots

  - **Category:** Storage collision issues

  - **Source:** <u>[l1.go](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/op-chain-ops/upgrades/l1.go)</u>

  - **Status:** Acknowledged


**Description**


L1 upgrades are a 2-step process which involves replacing the implementation contract with
the _<u>[StorageSetter](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/universal/StorageSetter.sol)</u>_ and directly manipulating data in storage slots as the first step. This is
necessary to reset the __initialized_ slot to be able to re-initialize the Proxy contracts.


There is an issue in the upgrade logic for some of the L1 contracts since they are resetting
state for storage slots that are unused. The table below details the issues:


Trust Security Optimism Bedrock upgrade


Relevant references:


[- OptimismMintableERC20Factory](https://github.com/ethereum-optimism/optimism/blob/develop/op-chain-ops/upgrades/l1.go#L364-L370)


[- OptimismPortal](https://github.com/ethereum-optimism/optimism/blob/develop/op-chain-ops/upgrades/l1.go#L425-L434)


[- SystemConfig](https://github.com/ethereum-optimism/optimism/blob/develop/op-chain-ops/upgrades/l1.go#L496-L536)


[- L2OutputOracle](https://github.com/ethereum-optimism/optimism/blob/develop/op-chain-ops/upgrades/l1.go#L276-L285)


[- L1StandardBridge](https://github.com/ethereum-optimism/optimism/blob/develop/op-chain-ops/upgrades/l1.go#L211-L214)


[- L1CrossDomainMessenger](https://github.com/ethereum-optimism/optimism/blob/develop/op-chain-ops/upgrades/l1.go#L83-L87)


**Recommended mitigation**


<mark>Remove all the state manipulation code that are no longer necessary and are being applied to</mark>
<mark>state variables that no longer exist. Leaving these may lead to issues in the future related to</mark>
<mark>corrupt data.</mark>


**Team response**


Acknowledged. This will be tracked and addressed in future upgrades.


TRST-L-5 The gas buffer set is insufficient, leading to risks of unexpected reverts

  - **Category:** Gas-related flaws

  - **Source:** <u>[OptimismPortal.sol](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/L1/OptimismPortal.sol#L118-L122)</u>

  - **Status:** Acknowledged


**Description**


The _CrossDomainMessenger_ introduced a _RELAY_GAS_CHECK_BUFFER_ which has a value of
5000. This buffer represents the gas that needs to be reserved for the execution between the
_<u>[hasMinGas()](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol#L268)</u>_ [check and the external call](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol#L287) in _relayMessage()_ .


Trust Security Optimism Bedrock upgrade


<mark>The assumption is that this 5000 buffer is enough to cover the gas required in the following</mark>
<mark>code between</mark> _<mark>hasMinGas()</mark>_ <mark>and</mark> _<mark>SafeCall.call()</mark>_ <mark>:</mark>


<mark>A breakdown of the gas costs for the execution between the gas check and the external call</mark>
<mark>follows:</mark>


   - <mark>Cold</mark> <mark>SLOAD</mark> <mark>of</mark> **<mark>xDomainMsgSender</mark>** <mark>in</mark> **<mark>xDomainMsgSender</mark>** **<mark>!=</mark>**
**<mark>Constants.DEFAULT_L2_SENDER</mark>** <mark>- 2100 gas</mark>

   - <mark>Non-zero to non-zero SSTORE of</mark> **<mark>xDomainMsgSender</mark>** <mark>in</mark> **<mark>xDomainMsgSender =</mark>**
**<mark>_sender</mark>** <mark>- 2900 gas</mark>

   - <mark>Other opcodes for comparisons, additions, multiplications and jumps - ~200-300 gas</mark>


<mark>The gas check buffer is insufficient by a few hundred gas units.</mark>


**Recommended mitigation**


<mark>Increase the gas check buffer by 1000 gas to 6000 gas for additional safety.</mark>


**Team response**


Acknowledged. This will be tracked and addressed in future upgrades.


TRST-L-6 OptimismPortal consumes all forwarded gas even if the TX is undeliverable

  - **Category:** Gas-related flaws


Trust Security Optimism Bedrock upgrade

  - **Source:** <u>[OptimismPortal.sol](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/L1/OptimismPortal.sol#L366-L407)</u>

  - **Status:** Acknowledged


**Description**


If a user does not forward enough gas to cover the gas cost of their deposit when calling
_<u>[depositTransaction()](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/L1/OptimismPortal.sol#L366-L407)</u>_, then all the forwarded gas will be burned and the transaction will be
reverted. A check can be implemented to prevent this unnecessary gas loss at the expense of
the user.


Suppose a user calls _OptimismPortal::depositTransaction()_ and the following parameters
apply:


L2 base fee – 10 gwei


L1 base fee – 50 gwei


gasLimit – 1M


gas forwarded by the caller – 150,000


The total gas that should be burned on L1 is: <mark>1e6 * 10e9 / 50e9 = 200,000</mark>


With the above parameters, the 150,000 gas forward by the caller is not enough to cover the
gas cost of 200,000. However, the <u>[metering function](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/L1/ResourceMetering.sol#L137-L145)</u> will still proceed with burning all the
150,000 gas of the caller and revert with an OOG (out-of-gas) error.


The issue lies in _<u>[Burn.gas()](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/libraries/Burn.sol#L15-L21)</u>_ :


For simplicity, assume the **___** **amount** is the total gas cost of 200,000 and _gasleft()_ is zero to get
the maximum amount of the lefthand-side of the condition. Since the condition <mark>150,000 <</mark>
<mark>200,000</mark> will always be true, all the 150,000 gas will be burned and it will attempt to burn more
but will revert due to no more gas left.


In fact, any deposit transaction that has insufficient gas forwarded with it will lose all that gas.


**Recommended mitigation**


<mark>A check can be added to</mark> _<mark>Burn.gas()</mark>_ <mark>to prevent unnecessary burning when the forwarded gas</mark>
<mark>is insufficient.</mark>


Trust Security Optimism Bedrock upgrade


**Team response**


Acknowledged. This will be tracked and addressed in future upgrades.


TRST-L-7 Users can underpay gas for contract creations, which would make them fail

  - **Category:** Gas-related flaws

  - **Source:** <u>[OptimismPortal.sol](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/L1/OptimismPortal.sol#L385)</u>

  - **Status:** Acknowledged


**Description**


<mark>[For deposit transactions, a minimum gas limit](https://github.com/ethereum-optimism/optimism/blob/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003/packages/contracts-bedrock/src/L1/OptimismPortal.sol#L385)</mark> <mark>is enforced to ensure that gas consumption on</mark>
<mark>L2 has been paid for by users. However, this minimum gas limit only accounts for the data</mark>
length and intrinsic TX cost (21000 gas units):


<mark>This minimum gas limit does not account for the case of contract creations where it has a</mark>
<mark>minimum fixed cost of 32000 gas on top of the inherent 21k cost. This leads to users possibly</mark>
attempting to deploy contracts with a gas amount that is guaranteed to be insufficient.


**<mark>Recommended mitigation</mark>**


The minimum gas limit should account for the fixed costs and dynamic costs of contract
creation when the deposit transaction is a contract creation.


**Team response**


Acknowledged. This will be tracked and addressed in future upgrades.


Trust Security Optimism Bedrock upgrade

TRST-L-8 Different ERC20Factory addresses between chains makes it impossible to
deploy ERC20s with the same address on all the chains

  - **Category:** Deployments

  - **Source:** <u>[OptimismMintableERC20Factory.sol](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/src/universal/OptimismMintableERC20Factory.sol#L100)</u>

  - **Status:** Acknowledged


**Description**


_<mark>OptimismMintableERC20Factory</mark>_ <mark>deploys</mark> _<mark>OptimisMintableERC20</mark>_ <mark>with the use of</mark> <u><mark>[CREATE2.](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/src/universal/OptimismMintableERC20Factory.sol#L100-L102)</mark></u>
<mark>The intention for this is to enable deploying a token contract with the same address on all the</mark>
<mark>OP Stack chains. For the contract to have the same address on all the chains, the following</mark>
<mark>details must be consistent on every deployment on each chain:</mark>


<mark>1.</mark> <mark>Sender address – This would be the address of the</mark> _<mark>OptimismMintableERC20Factory</mark>_ <mark>.</mark>
<mark>2.</mark> <mark>Bytecode of the</mark> _<mark>OptimismMintableERC20</mark>_ <mark>contract</mark>
<mark>3.</mark> <mark>Constructor arguments passed to the</mark> _<mark>OptimismMintableERC20</mark>_ <mark>contract which are</mark>
**_<mark>BRIDGE</mark>_** <mark>,</mark> **<mark>_remoteToken</mark>** <mark>,</mark> **<mark>_name</mark>** <mark>,</mark> **<mark>_symbol</mark>** <mark>, and</mark> **<mark>_decimals</mark>** <mark>.</mark>


<mark>Currently, the address for the</mark> _<mark>OptimismMintableERC20Factory</mark>_ <mark>contract is different between</mark>
<mark>Optimism and Base. This would make it impossible to have the same address for any ERC20</mark>
contracts deployed with the Factory in those chains.


<mark>Also worth noting is that the counterpart for Optimism’s USDC, would be USDbC on Base.</mark>
<mark>USDbC has a different name and symbol for its token. This difference in the constructor</mark>
<mark>arguments would lead to different token addresses. The current implementation of the</mark>
<mark>Factory does not allow for differences in the name, symbol, and decimals of the token if they</mark>
are to have the same address on different chains.


**<mark>Recommended mitigation</mark>**


The _OptimismMintableERC20Factory_ must be deployed to the same address on all the chains
to enable token deployers to deploy the same address for their token. If there is value to
enabling using different names, symbols, and decimals for the tokens while deploying to the
same address, these details must instead be stored in state variables and not passed as
constructor arguments. If not passed as constructor arguments, these details can instead be
set in and fetched from a different contract.


**Team response**


Acknowledged.


Additional recommendations


Including constructor arguments in the salt is redundant


The _OptimismMintableERC20Factory_ deploys _OptimismMintableERC20_ contracts via CREATE2
for deterministic addresses to enable a token to have the same address across all OP Stack
chains. The **<u>[salt](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/src/universal/OptimismMintableERC20Factory.sol#L100)</u>** input to CREATE2 includes the construct arguments such as **_remoteToken**,
**_name**, **_symbol**, and **_decimals** . This is redundant since the constructor arguments already


Trust Security Optimism Bedrock upgrade

affect CREATE2 address derivation. In this case, **salt** could be a zero value or a value set by the
user instead.


Centralization risks


Only risks introduced by the upgrade in scope will be detailed below.


TRST-CR-1 The SuperchainConfig guardian can pause all Superchains


The upgrade delegates responsibility for pausing withdrawals to the SuperchainConfig
contract. This means all chains share the pause button, and therefore to handle an issue in
one particular chain would require pausing all Superchains. It is acknowledged that the chosen
model presents an advantage, whereby all chains which presumably share the same source
code, can be paused in tandem, should a code-level emergency arise.


