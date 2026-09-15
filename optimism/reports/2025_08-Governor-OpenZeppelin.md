### | security

# **Optimism** **Governor Audit**

#### **August 4, 2025**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  5


Security Model and Trust Assumptions _______________________________________________  5

Privileged Roles 5


Low Severity ______________________________________________________________________  7

L-01 Deployment Script Incorrectly Calls updateTimelock Function 7

L-02 Incorrect Documentation 7

L-03 Incomplete Documentation 7

L-04 Possible Duplicate Event Emissions 8

L-05 Timelock Proxy Deployment and Initialization Split into Separate Transactions 8

L-06 OptimismGovernor Version Not Increased 8

L-07 updateTimelock Lacks Zero-Address Validation 9

L-08 proposeWithModule Requires Timelock to Have Proposal Threshold 9


Notes & Additional Information ____________________________________________________ 10

N-01 Discrepancies between Documentation and Implementation 10

N-02 Repeated Calls to Grant Role 10

N-03 Commented-Out Code 11

N-04 Inconsistency in Indexing Event Parameters 11


Conclusion ______________________________________________________________________ 12


Optimism Governor Audit − Table of Contents − 2


## **Summary**

**Type** Governance


**Timeline** From 2025-07-16
To 2025-07-18


**Languages** Solidity



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


0 (0 resolved)


0 (0 resolved)



**Total Issues** 12 (12 resolved)



**Low Severity Issues** 8 (8 resolved)



**Notes & Additional**
**Information**



4 (4 resolved)



Optimism Governor Audit − Summary − 3


## **Scope**

OpenZeppelin audited the following components from the <u>[voteagora/optimism-governor](https://github.com/voteagora/optimism-governor/)</u>

repository at commit <u>[d585692:](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/)</u>









The changes made to <mark>`src/OptimismGovernor.sol`</mark> [in pull request #44](https://github.com/voteagora/optimism-governor/pull/44/files#diff-9a87d7f95c10cdbb83b3666d5c366db79bfd47f49f80fe41107413d08bc21091)

The entire <u><mark>`[script/RedeployTimelock.s.sol](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/script/RedeployTimelock.s.sol)`</mark></u> script

The provided calldata for the proposal on the Sepolia network


Optimism Governor Audit − Scope − 4


## **System Overview**

The <mark>`OptimismGovernor`</mark> contract introduces new logic for an authorized proposer, who is

permitted to create proposals using the <mark>`propose`</mark> and <mark>`proposeWithModule`</mark> functions. In

addition, a dedicated <mark>`setAuthorizedProposer`</mark> function has been added that can only be

called by the manager or the timelock contract to set the authorized proposer's address.


The timelock redeployment script, <mark>`RedeployTimelock.s.sol`</mark> <mark>,</mark> implements the logic for the

deployment of a new timelock contract using the transparent proxy pattern, initializing its state,

and setting up roles and privileged accounts. The final part of the scope covers the calldata

prepared for a proposal to invoke the governor's <mark>`updateTimelock`</mark> function with the address

of the new timelock contract.

## **Security Model and Trust** **Assumptions**


During the audit, the following observations and trust assumptions were made:









The existing logic of the <mark>`OptimismGovernor`</mark> contract works as expected and does

not contain issues, as only the introduced changes were reviewed in this audit.

Using the <mark>`RedeployTimelock.s.sol`</mark> script, the deployer correctly sets the

addresses for <mark>`EXISTING_GOVERNOR`</mark> <mark>,</mark> <mark>`MANAGER_ADDRESS`</mark> <mark>,</mark> <mark>`PROXY_ADMIN`</mark>,

<mark>`L2_SAFE_1`</mark> <mark>,</mark> <mark>`L2_SAFE_2`</mark> <mark>,</mark> and <mark>`L2_SAFE_3`</mark> <mark>.</mark>


### **Privileged Roles**

The changes made to the <mark>`OptimismGovernor`</mark> contract introduce a new privileged role,

<mark>`authorizedProposer`</mark> <mark>,</mark> that is able to propose new proposals and cancel its own proposals.

In addition, the timelock redeployment script <mark>(</mark> <mark>`RedeployTimelock.s.sol`</mark> <mark>)</mark> introduces

<mark>`L2_SAFE_1`</mark> <mark>,</mark> <mark>`L2_SAFE_2`</mark> <mark>,</mark> <mark>`L2_SAFE_3`</mark> addresses that can cancel any proposal.


Optimism Governor Audit − System Overview − 5


**_Update:_** _During the fix review process, the_ _<mark>`timelock`</mark>_ _contract was removed from the_

_authorized proposer set in the_ _<mark>`OptimismGovernor`</mark>_ _contract. Additionally, in the_

_<mark>`RedeployTimelock.s.sol`</mark>_ _script,_ _<mark>`MANAGER_ADDRESS`</mark>_ _was removed from the list of_

_<mark>`CANCELLER_ROLE`</mark>_ _addresses because it is anticipated that one of the SAFE addresses will be_

_assigned to the_ _<mark>`manager`</mark>_ _address._


Optimism Governor Audit − Security Model and Trust Assumptions − 6


## **Low Severity**

### **L-01 Deployment Script Incorrectly Calls** **updateTimelock Function**

The <mark>`RedeployTimelock.s.sol`</mark> script contains a <u>[call](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/script/RedeployTimelock.s.sol#L71)</u> to

<mark>`governor.updateTimelock(newTimelock)`</mark> that will fail during execution due to access
control restrictions. The <u><mark>`[updateTimelock](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/src/OptimismGovernor.sol#L336)`</mark></u> <u>function</u> of the <mark>`OptimismGovernor`</mark> contract has

the <mark>`onlyGovernance`</mark> [modifier, which requires](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.8/contracts/governance/GovernorUpgradeable.sol#L66) <mark>`_msgSender()`</mark> to be the governor contract

itself. However, when the script runs, the <mark>`_msgSender()`</mark> is the deployer's address, not the

governor contract, causing the check to fail.


Consider removing the <mark>`updateTimelock`</mark> call from the deployment script.


**_Update:_** _[Resolved in pull request #47](https://github.com/voteagora/optimism-governor/pull/47)_ _[at commit ce323b5.](https://github.com/voteagora/optimism-governor/pull/47/commits/ce323b50d73cce4fcf5c4c0d73dff073b02cfecc)_

### **L-02 Incorrect Documentation**


The docstrings above the <u><mark>`[propose](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/src/OptimismGovernor.sol#L382)`</mark></u> and <u><mark>`[proposeWithModule](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/src/OptimismGovernor.sol#L439-L440)`</mark></u> functions incorrectly state

that an address with votes above the proposal threshold can propose. They also fail to mention

the timelock contract as one of the proposers. Given that these functions are decorated with

the <mark>`onlyValidProposer`</mark> modifier, only the manager, authorized proposer, or the timelock

contract can call these functions.


Consider correcting the aforementioned instances of incorrect documentation.


**_Update:_** _[Resolved in pull request #48](https://github.com/voteagora/optimism-governor/pull/48)_ _[at commit ef27aaf.](https://github.com/voteagora/optimism-governor/pull/48/commits/ef27aaf4cf52f8666612c5f0e09274425e585dd9)_

### **L-03 Incomplete Documentation**


<u>[This comment](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/src/OptimismGovernor.sol#L393)</u> in the <mark>`propose`</mark> function mentions that only the manager or timelock can

propose. However, it does not mention the <mark>`authorizedProposer`</mark> address that can also

propose.


Consider updating the comment to accurately reflect the complete set of valid proposers.


Optimism Governor Audit − Low Severity − 7


**_Update:_** _[Resolved in pull request #48](https://github.com/voteagora/optimism-governor/pull/48)_ _[at commit ef27aaf.](https://github.com/voteagora/optimism-governor/pull/48/commits/ef27aaf4cf52f8666612c5f0e09274425e585dd9)_

### **L-04 Possible Duplicate Event Emissions**


When a setter function does not check if the value being set is different from the existing one, it

becomes possible to set the same value repeatedly, creating a possibility for event spamming.

Repeated emission of identical events can also confuse off-chain clients.


The <u><mark>`[setAuthorizedProposer](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/src/OptimismGovernor.sol#L325-L328)`</mark></u> function sets the <mark>`authorizedProposer`</mark> variable and

emits an event without checking if the value has changed.


Consider adding a check that reverts the transaction if the value being set is the same as the

existing one.


**_Update:_** _[Resolved in pull request #53](https://github.com/voteagora/optimism-governor/pull/53)_ _[at commit 68d60ba.](https://github.com/voteagora/optimism-governor/pull/53/commits/68d60ba4ed8b94f100a3943de94630d3a886c186)_

### **L-05 Timelock Proxy Deployment and** **Initialization Split into Separate Transactions**


The deployment logic for the <mark>`Timelock`</mark> contract uses the transparent proxy pattern via

<u><mark>`[TransparentUpgradeableProxy](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/script/RedeployTimelock.s.sol#L86)`</mark></u> <mark>,</mark> followed by a separate call to the <u><mark>`[initialize](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/script/RedeployTimelock.s.sol#L88)`</mark></u>

function. This unnecessarily splits the deployment and initialization of the proxy into two

distinct transactions, potentially exposing the contract to front-running attacks.


Consider encoding the initialization call in the <mark>`_data`</mark> parameter of the

<mark>`TransparentUpgradeableProxy`</mark> constructor. This approach ensures that both the proxy

and its implementation are initialized atomically within a single transaction.


**_Update:_** _[Resolved in pull request #54](https://github.com/voteagora/optimism-governor/pull/54)_ _[at commit 600c183.](https://github.com/voteagora/optimism-governor/pull/54/commits/600c183e2bdc2563de2bd00e64b6dabe232d57a5)_

### **L-06 OptimismGovernor Version Not Increased**


The <mark>`OptimismGovernor`</mark> contract was modified to include new logic for the authorized

proposer. However, the <mark>`VERSION`</mark> was not incremented. As a result, the <u><mark>`[reinitialize](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/src/OptimismGovernor.sol#L199-L205)`</mark></u>

function is not callable and will revert due to the <mark>`reinitializer`</mark> modifier. While it is possible

to set the <mark>`authorizedProposer`</mark> using the <u><mark>`[setAuthorizedProposer](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/src/OptimismGovernor.sol#L325-L328)`</mark></u> function, this

approach bypasses the standard practice of handling state changes during upgrades.


Optimism Governor Audit − Low Severity − 8


Consider increasing the <mark>`VERSION`</mark> of the contract and setting the parameters through the

<mark>`reinitialize`</mark> logic.


**_Update:_** _[Resolved in pull request #49](https://github.com/voteagora/optimism-governor/pull/49)_ _[at commit 01d6170. During the upgrade process, it is](https://github.com/voteagora/optimism-governor/pull/49/commits/01d61708e3125dba01860c8b9a02ba396b426d6f)_

_expected that the governor contract is upgraded and reinitialized atomically to prevent any_

_front-running._

### **L-07 updateTimelock Lacks Zero-Address** **Validation**


The <u><mark>`[updateTimelock](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/src/OptimismGovernor.sol#L336)`</mark></u> function of the <mark>`OptimismGovernor`</mark> contract lacks zero-address

validation for the <mark>`newTimelock`</mark> input. If <mark>`address(0)`</mark> is passed as <mark>`newTimelock`</mark>, the

<mark>`OptimismGovernor`</mark> functions will become unusable. This is because the

<mark>`onlyGovernance`</mark> modifier will block further updates, effectively bricking the contract's

governance functionality.


Consider adding a zero-address check before assigning the <mark>`_timelock`</mark> state variable.


**_Update:_** _[Resolved in pull request #56](https://github.com/voteagora/optimism-governor/pull/56)_ _[at commit 7d23fbc.](https://github.com/voteagora/optimism-governor/pull/56/commits/7d23fbc18329ca6096e334f62ca24912775a725a)_

### **L-08 proposeWithModule Requires Timelock to** **Have Proposal Threshold**


The <mark>`proposeWithModule`</mark> function is marked with the <u><mark>`[onlyValidProposer](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/src/OptimismGovernor.sol#L144-L148)`</mark></u> modifier,

which allows the function to be executed by one of the following addresses: <mark>`manager`</mark> <mark>,</mark>

<mark>`authorizedProposer`</mark> <mark>,</mark> or <mark>`timelock`</mark> <mark>.</mark> However, within the function, there is a check that

requires the following: if the function is called by an address that is neither <mark>`manager`</mark> nor

<mark>`authorizedProposer`</mark> <mark>,</mark> a <u>[proposal votes threshold needs to be met.](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/src/OptimismGovernor.sol#L455-L457)</u>


Given that the only other address allowed to call the <mark>`proposeWithModule`</mark> function is

<mark>`timelock`</mark> <mark>,</mark> the aforementioned check implies that <mark>`timelock`</mark> itself must meet a vote

threshold. This design is inconsistent with the <mark>`propose`</mark> function where the check for

privileged proposer addresses to meet the proposal threshold is <u>[intentionally removed. In](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/src/OptimismGovernor.sol#L394-L397)</u>

addition, this discrepancy raises a further discussion on whether the timelock contract should

be allowed to be a proposer on the governor. Timelocks are typically meant to delay, queue,

and execute proposals. Allowing the timelock contract to propose can create circular

governance paths, which can prove to be error-prone.


Optimism Governor Audit − Low Severity − 9


Consider unifying the behavior for the proposal-threshold check across the <mark>`propose`</mark> and

<mark>`proposeWithModule`</mark> functions. Moreover, reconsider the design decision of allowing the

timelock contract to be a proposer.


**_Update:_** _[Resolved in pull request #50](https://github.com/voteagora/optimism-governor/pull/50)_ _[at commit c40620f. The](https://github.com/voteagora/optimism-governor/pull/50/commits/c40620ffa47d0d4097bbc4344b05d669e4bf8d22)_ _<mark>`timelock`</mark>_ _contract is no longer_

_a valid proposer._

## **Notes & Additional** **Information**

### **N-01 Discrepancies between Documentation and** **Implementation**


The <mark>`RedeployTimelock`</mark> deployment script sets up the <mark>`timelock`</mark> controller with

parameters that are meant to reflect those described in the <u>[scoping document. However, some](https://docs.google.com/document/d/1IL2KXyrPQOmoxpAVovSxsncSA7XCHqkgYxi-wIhIwYU/edit?usp=sharing)</u>

discrepancies exist between the script and the documentation:









The document mentions that "Cancellation rights over scheduled timelock calls are held

exclusively by 4 addresses: 3 Optimism Foundation addresses provided in script and

governor". However, in the script, there is an additional address, <mark>`MANAGER_ADDRESS`</mark> <mark>,</mark>

[that is granted](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/script/RedeployTimelock.s.sol#L104) <mark>`CANCELLER_ROLE`</mark> <mark>.</mark>

As per the document, the timelock has a delay of 7 <mark>`days`</mark> <mark>.</mark> However, <mark>`MIN_DELAY`</mark> in the

script is <u>6</u> <u><mark>`[days](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/script/RedeployTimelock.s.sol#L33)`</mark></u> <mark>.</mark>



Consider updating the documentation to reflect the current implementation decisions.


**_Update:_** _[Resolved in pull request #55](https://github.com/voteagora/optimism-governor/pull/55)_ _[at commit 20e632d. The Agora team stated:](https://github.com/voteagora/optimism-governor/pull/55/commits/20e632d365b69548e7a6d32cdb3f9463bb7067c3)_


_This has been updated to reflect the document. One thing to note is that one of the Safe_

_addresses will be the manager. Therefore, we do not need to redundantly grant the role._

### **N-02 Repeated Calls to Grant Role**


In the <mark>`RedeployTimelock`</mark> script, the same roles are being granted to the <mark>`timelock`</mark> and

<mark>`EXISTING_GOVERNOR`</mark> addresses multiple times: first during the <u>[timelock initialization](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/script/RedeployTimelock.s.sol#L64)</u> and

then in the <u><mark>`[_setupRoles](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/script/RedeployTimelock.s.sol#L67)`</mark></u> <u>function.</u>


Optimism Governor Audit − Notes & Additional Information − 10


During the timelock initialization, the <u><mark>`[_setupRole](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.8/contracts/governance/TimelockControllerUpgradeable.sol#L99-L110)`</mark></u> <u>function</u> of the

<mark>`TimelockControllerUpgradeable`</mark> contract is called inside the

<u><mark>`[__TimelockController_init](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/test/mocks/TimelockMock.sol#L14)`</mark></u> <u>call</u> chain, and the <mark>`TIMELOCK_ADMIN_ROLE`</mark> role is

granted to the <mark>`timelock`</mark> and <mark>`deployer`</mark> addresses. In addition, the <mark>`PROPOSER_ROLE`</mark> and

<mark>`CANCELLER_ROLE`</mark> roles are granted to the <mark>`EXISTING_GOVERNOR`</mark> address. After the

deployment of the timelock contract, the script calls an <mark>`internal`</mark> <u><mark>`[_setupRoles](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/script/RedeployTimelock.s.sol#L96)`</mark></u> <u>function</u>

that again grants the <mark>`TIMELOCK_ADMIN_ROLE`</mark> role to the <u><mark>`[timelock](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/script/RedeployTimelock.s.sol#L112)`</mark></u> <u>address, and the</u>

<u><mark>`[PROPOSER_ROLE](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/script/RedeployTimelock.s.sol#L100)`</mark></u> and <u><mark>`[CANCELLER_ROLE](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/script/RedeployTimelock.s.sol#L105)`</mark></u> roles to <mark>`EXISTING_GOVERNOR`</mark> address.


Consider removing the aforementioned duplication of roles in order to improve code clarity and

maintainability.


**_Update:_** _[Resolved in pull request #52](https://github.com/voteagora/optimism-governor/pull/52)_ _[at commit e35f3c7.](https://github.com/voteagora/optimism-governor/pull/52/commits/e35f3c7b5aa6fd26cb0bcf9650df6a097c9cfaf6)_

### **N-03 Commented-Out Code**


The <mark>`propose`</mark> [function contains commented-out code](https://github.com/voteagora/optimism-governor/blob/fdf40c32a3d47bb475963334d1b07916102f52ea/src/OptimismGovernor.sol#L394-L397) which negatively affects the readability

of the codebase.


Consider removing the commented-out code and leaving a code comment explaining the

decision of removing the threshold check.


**_Update:_** _[Resolved in pull request #50](https://github.com/voteagora/optimism-governor/pull/50)_ _[at commit c40620f.](https://github.com/voteagora/optimism-governor/pull/50/commits/c40620ffa47d0d4097bbc4344b05d669e4bf8d22)_

### **N-04 Inconsistency in Indexing Event Parameters**


The <mark>`OptimismGovernor`</mark> contract defines several events that are emitted when privileged

addresses are updated, such as <u><mark>`[ManagerSet](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/src/OptimismGovernor.sol#L67)`</mark></u> <mark>,</mark> <u><mark>`[AuthorizedProposerSet](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/src/OptimismGovernor.sol#L71)`</mark></u> <mark>,</mark> and

<u><mark>`[TimelockChange](https://github.com/voteagora/optimism-governor/blob/d585692582e907a69ecc066cc4196ea16630ab13/src/OptimismGovernor.sol#L69)`</mark></u> <mark>.</mark> Among these events, only the first two use indexed parameters, while the

<mark>`TimelockChange`</mark> event does not.


Consider evaluating whether the parameters in these events are intended to be indexed and

making the use of indexed parameters consistent.


**_Update:_** _[Resolved in pull request #51](https://github.com/voteagora/optimism-governor/pull/51)_ _[at commit 072970a.](https://github.com/voteagora/optimism-governor/pull/51/commits/072970aad9ac0f36247213b7540104caa62f2dd4)_


Optimism Governor Audit − Notes & Additional Information − 11


## **Conclusion**

The review covered updates to the <mark>`OptimismGovernor`</mark> contract, the timelock redeployment

script, and the calldata for updating the governor’s timelock on the Sepolia network. Key

changes included introducing an authorized proposer mechanism, restricting proposer

permissions, securely redeploying the timelock with proper initialization, and preparing the

calldata to update the timelock reference in governance.


During the audit, several minor issues were identified and recommendations were made to

improve code consistency and readability. The Agora team was highly cooperative and

provided clear explanations throughout the audit process.


Optimism Governor Audit − Conclusion − 12


