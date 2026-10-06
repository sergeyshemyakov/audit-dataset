## // Security Assessment 02.19.2025 - 02.24.2025

# Taiko


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC

## Prepared by: HALBORN Last Updated 03/24/2025 Date of Engagement: February 19th, 2025 - February 24th, 2025



%



OF ALL REPORTED FINDINGS HAVE BEEN ADDRESSED



1. Introduction
2. Assessment summary
3. Test approach and methodology


4. Static analysis report


4.1 Description
4.2 Output


5. Risk methodology
6. Scope


7. Assessment summary & findings overview
8. Findings & Tech Details


8.1 Inconsistent snapshot for encryption agents
8.2 Unused components


8.3 Public functions not invoked internally
8.4 Lack of account removal mechanism in registry
8.5 Missing input validation


8.6 Missing visibility modifier
8.7 Empty 'revert' statement


8.8 Missing address validation in signer management
8.9 Unhandled return values
8.10 Floating pragma


8.11 Redundant use of `this` keyword


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 2/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


8.12 Missing events


8.13 Typo in error name


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 3/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


`Taiko Labs` engaged `Halborn` to conduct a security assessment on their smart contracts beginning


on February 19th, 2025 and ending on February 25th, 2025. The security assessment was scoped
to the smart contracts provided to Halborn. Commit hashes and further details can be found in the
Scope section of this report.


The `Taiko Labs` codebase in scope consists of a DAO protocol leveraged by Aragon.


`Halborn` was provided 5 days for the engagement and assigned 2 full-time security engineers to


review the security of the smart contracts in scope. The engineers are blockchain and smart


contract security experts with advanced penetration testing and smart contract hacking skills, and
deep knowledge of multiple blockchain protocols.


The purpose of the assessment is to:


Identify potential security issues within the smart contracts.
Ensure that smart contract functionality operates as intended.


In summary, `Halborn` identified some improvements to reduce the likelihood and impact of risks,


which were mostly addressed by the `Taiko Labs` team. The main ones are the following::

```
       Introduce require statements in the constructor or deployOnce to validate all

     parameters.

       Provide an upgrade path for long-lived DAOs.

       Capture the creator’s owner/agent and store the agent used for encryption.

```

https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 4/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


`Halborn` performed a combination of manual review of the code and automated security testing to


balance efficiency, timeliness, practicality, and accuracy in regard to the scope of this assessment.
While manual testing is recommended to uncover flaws in logic, process, and implementation;
automated testing techniques help enhance coverage of smart contracts and can quickly identify
items that do not follow security best practices.


The following phases and associated tools were used throughout the term of the assessment:


Research into architecture, purpose and use of the platform.


Smart contract manual code review and walkthrough to identify any logic issue.
Thorough assessment of safety and usage of critical Solidity variables and functions in scope
that could led to arithmetic related vulnerabilities _._

Local testing with custom scripts ( `Foundry` ).


Fork testing against main networks ( `Foundry` ).


Static analysis of security for scoped contract, and imported functions ( `Slither` ).


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 5/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


`Halborn` used automated testing techniques to enhance the coverage of certain areas of the smart


contracts in scope. Among the tools used was Slither, a Solidity static analysis framework. After

`Halborn` verified the smart contracts in the repository and was able to compile them correctly into


their abis and binary format, Slither was run against the contracts. This tool can statically verify
mathematical relationships between Solidity variables to detect invalid or inconsistent usage of the
contracts' APIs across the entire code-base.


The security team assessed all findings identified by the Slither software, however, findings with


related to external dependencies are not included in the below results for the sake of report
readability.


The findings obtained as a result of the Slither scan were reviewed, and many were not included in
the report because they were determined as false positives.


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 6/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 7/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 8/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


Every vulnerability and issue observed by Halborn is ranked based on **two sets** of **Metrics** and a

**Severity Coefficient** . This system is inspired by the industry standard Common Vulnerability Scoring


System.


The two **Metric sets** are: **Exploitability** and **Impact** . **Exploitability** captures the ease and technical

means by which vulnerabilities can be exploited and **Impact** describes the consequences of a


successful exploit.


The **Severity Coefficients** is designed to further refine the accuracy of the ranking with two factors:

**Reversibility** and **Scope** . These capture the impact of the vulnerability on the environment as well


as the number of users and smart contracts affected.


The final score is a value between 0-10 rounded up to 1 decimal place and 10 corresponding to the
highest security risk. This provides an objective and accurate rating of the severity of security


vulnerabilities in smart contracts.


The system is designed to assist in identifying and prioritizing vulnerabilities based on their level of
risk to address the most critical issues in a timely manner.


:


Captures whether the attack requires compromising a specific account.


:


Captures the cost of exploiting the vulnerability incurred by the attacker relative to sending a single
transaction on the relevant blockchain. Includes but is not limited to financial and computational


cost.


:


Describes the conditions beyond the attacker’s control that must exist in order to exploit the
vulnerability. Includes but is not limited to macro situation, available third-party liquidity and


regulatory challenges.


:


**EXPLOITABILITY METRIC (** _ME_ **)** **METRIC VALUE** **NUMERICAL VALUE**



Arbitrary (AO:A)
Attack Origin (AO)

Specific (AO:S)



1
0.2



https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 9/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


**EXPLOITABILITY METRIC (** _ME_ **)** **METRIC VALUE** **NUMERICAL VALUE**



1
0.67
0.33


1
0.67
0.33



Attack Cost (AC)


Attack Complexity (AX)



Low (AC:L)
Medium (AC:M)

High (AC:H)


Low (AX:L)
Medium (AX:M)

High (AX:H)


### Exploitability E is calculated using the following formula: E = me ∏

:


Measures the impact to the confidentiality of the information resources managed by the contract


due to a successfully exploited vulnerability. Confidentiality refers to limiting access to authorized
users only.


:


Measures the impact to integrity of a successfully exploited vulnerability. Integrity refers to the


trustworthiness and veracity of data stored and/or processed on-chain. Integrity impact directly
affecting Deposit or Yield records is excluded.


:


Measures the impact to the availability of the impacted component resulting from a successfully
exploited vulnerability. This metric refers to smart contract features and functionality, not state.


Availability impact directly affecting Deposit or Yield is excluded.


:


Measures the impact to the deposits made to the contract by either users or owners.


:


Measures the impact to the yield generated by the contract for either users or owners.


:


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 10/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


**IMPACT METRIC (** _MI_ **)** **METRIC VALUE** **NUMERICAL VALUE**



0
0.25
0.5
0.75
1


0
0.25
0.5
0.75
1


0
0.25
0.5
0.75
1


0
0.25
0.5
0.75
1


0
0.25
0.5
0.75
1



Confidentiality (C)


Integrity (I)


Availability (A)


Deposit (D)


Yield (Y)



None (I:N)

Low (I:L)
Medium (I:M)

High (I:H)
Critical (I:C)


None (I:N)

Low (I:L)
Medium (I:M)

High (I:H)
Critical (I:C)


None (A:N)

Low (A:L)
Medium (A:M)

High (A:H)
Critical (A:C)


None (D:N)

Low (D:L)
Medium (D:M)

High (D:H)
Critical (D:C)


None (Y:N)

Low (Y:L)
Medium (Y:M)

High (Y:H)
Critical (Y:C)


### Impact I is calculated using the following formula:


### I = max ( mI ) +

:


### ∑ mI − max ( mI ) 4



Describes the share of the exploited vulnerability effects that can be reversed. For upgradeable
contracts, assume the contract private key is available.


:


Captures whether a vulnerability in one vulnerable contract impacts resources in other contracts.


:


**SEVERITY COEFFICIENT (** _C_ **)** **COEFFICIENT VALUE** **NUMERICAL VALUE**



1
0.5
0.25



Reversibility ( _r_ )



None (R:N)
Partial (R:P)

Full (R:F)



https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 11/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


**SEVERITY COEFFICIENT (** _C_ **)** **COEFFICIENT VALUE** **NUMERICAL VALUE**



Changed (S:C)
Scope ( _s_ )
Unchanged (S:U)



1.25
1


### Severity Coefficient C is obtained by the following product: C = rs The Vulnerability Severity Score S is obtained by: S = min (10, EIC ∗10)

The score is rounded up to 1 decimal places.


**SEVERITY** **SCORE VALUE RANGE**


Critical 9 - 10


High 7 - 8.9


Medium 4.5 - 6.9


Low 2 - 4.4


Informational 0 - 1.9


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 12/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


FILES AND REPOSITORY


(a) Repository:


(b) Assessed Commit ID: eed36d3


(c) Items in scope:


src/adapted-dependencies/ITaikoL1.sol


src/conditions/StandardProposalCondition.sol


src/factory/TaikoDaoFactory.sol


src/helpers/proxy.sol


src/setup/EmergencyMultisigPluginSetup.sol
src/setup/MultisigPluginSetup.sol


src/setup/OptimisticTokenVotingPluginSetup.sol


src/DelegationWall.sol


src/EmergencyMultisig.sol


src/EncryptionRegistry.sol
src/Multisig.sol


src/OptimisticTokenVotingPlugin.sol


src/SignerList.sol


Out-of-Scope: Third party dependencies and economic attacks.


REMEDIATION COMMIT ID:


[https://github.com/aragon/taiko-contracts/pull/50/commits/f80fb99dea86277dfadcdc](https://github.com/aragon/taiko-contracts/pull/50/commits/f80fb99dea86277dfadcdcacdf869689f804c53b)


[acdf869689f804c53b](https://github.com/aragon/taiko-contracts/pull/50/commits/f80fb99dea86277dfadcdcacdf869689f804c53b)


[https://github.com/aragon/taiko-contracts/pull/50/commits/939b67a60ddfd65198ba8](https://github.com/aragon/taiko-contracts/pull/50/commits/939b67a60ddfd65198ba86e126d08da3e45ef2e4)


[6e126d08da3e45ef2e4](https://github.com/aragon/taiko-contracts/pull/50/commits/939b67a60ddfd65198ba86e126d08da3e45ef2e4)
[https://github.com/aragon/taiko-contracts/pull/50/commits/2628cad4b3af2bddefb69b](https://github.com/aragon/taiko-contracts/pull/50/commits/2628cad4b3af2bddefb69b5f2d02b04ad29f5eb4)


[5f2d02b04ad29f5eb4](https://github.com/aragon/taiko-contracts/pull/50/commits/2628cad4b3af2bddefb69b5f2d02b04ad29f5eb4)


[https://github.com/aragon/taiko-contracts/pull/50/commits/a8fa1e56c8a0ff1aaf5ff44](https://github.com/aragon/taiko-contracts/pull/50/commits/a8fa1e56c8a0ff1aaf5ff449cc67c1b2f7eea591)


[9cc67c1b2f7eea591](https://github.com/aragon/taiko-contracts/pull/50/commits/a8fa1e56c8a0ff1aaf5ff449cc67c1b2f7eea591)


[https://github.com/aragon/taiko-contracts/pull/50/commits/62b17859716d3482800a](https://github.com/aragon/taiko-contracts/pull/50/commits/62b17859716d3482800ae08f6e721fdd5d55c95f)
[e08f6e721fdd5d55c95f](https://github.com/aragon/taiko-contracts/pull/50/commits/62b17859716d3482800ae08f6e721fdd5d55c95f)


[https://github.com/aragon/taiko-contracts/pull/50/commits/eb18176260c3e200ae79f](https://github.com/aragon/taiko-contracts/pull/50/commits/eb18176260c3e200ae79f74ddb233b81790dd601)


[74ddb233b81790dd601](https://github.com/aragon/taiko-contracts/pull/50/commits/eb18176260c3e200ae79f74ddb233b81790dd601)


Out-of-Scope: New features/implementations after the remediation commit IDs.


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 13/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


**SECURITY ANALYSIS** **RISK LEVEL** **REMEDIATION DATE**



INCONSISTENT SNAPSHOT FOR ENCRYPTION



INCONSISTENT SNAPSHOT FOR ENCRYPTION RISK ACCEPTED 
LOW
AGENTS 03/13/2025



03/13/2025



UNUSED COMPONENTS INFORMATIONAL SOLVED - 03/13/2025


PUBLIC FUNCTIONS NOT INVOKED INTERNALLY INFORMATIONAL SOLVED - 03/25/2025


LACK OF ACCOUNT REMOVAL MECHANISM IN

INFORMATIONAL SOLVED - 03/17/2025
REGISTRY


PARTIALLY SOLVED MISSING INPUT VALIDATION INFORMATIONAL

03/14/2025


MISSING VISIBILITY MODIFIER INFORMATIONAL SOLVED - 03/14/2025


EMPTY 'REVERT' STATEMENT INFORMATIONAL SOLVED - 03/14/2025


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 14/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


**SECURITY ANALYSIS** **RISK LEVEL** **REMEDIATION DATE**



MISSING ADDRESS VALIDATION IN SIGNER



MISSING ADDRESS VALIDATION IN SIGNER ACKNOWLEDGED 
INFORMATIONAL
MANAGEMENT 03/20/2025



03/20/2025



ACKNOWLEDGED UNHANDLED RETURN VALUES INFORMATIONAL

03/20/2025



ACKNOWLEDGED FLOATING PRAGMA INFORMATIONAL

03/20/2025



REDUNDANT USE OF `THIS` KEYWORD INFORMATIONAL SOLVED - 03/14/2025


ACKNOWLEDGED MISSING EVENTS INFORMATIONAL

03/20/2025


TYPO IN ERROR NAME INFORMATIONAL SOLVED - 03/14/2025


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 15/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


// LOW


Description


The system does not snapshot which encryption agent was tied to a signer at proposal creation,

which can lead to a **voting integrity issue** if agents are changed during an active proposal. The


`SignerList.resolveEncryptionAccountAtBlock()` function uses the current `EncryptionRegistry`


mapping to resolve an approver’s owner/agent relationship, but only the signer’s listed status is
checked at the historical block.


This means if an owner replaces their agent after the proposal was created, the **new** agent (who

was not part of the original encrypted payload distribution) **is now allowed to approve the pending**

**proposal** . Conversely, the original agent (who had the encrypted details) **would no longer be**

**recognized after removal** (since `appointerOf(oldAgent)` becomes **0 (zero)** and thus cannot approve.


This dynamic can be problematic, as a newly appointed agent might cast a vote without actually


knowing the proposal’s content (if the encryption key changed or wasn’t shared). It also lets a
signer potentially **rotate agents to influence a vote**     - for example, if an owner’s original agent was


uncooperative, the owner could appoint a new agent who will blindly approve, and the contract


would count it. While this doesn’t allow unauthorized entities to vote (the new agent is still


appointed by a listed signer), it breaks the expectation that only those privy to the original proposal


can vote on it. It slightly undermines the integrity of the emergency voting process by not locking in


the “voting identity” (owner or their delegate) at proposal creation.


**Code Location** : `SignerList.sol`    - `resolveEncryptionAccountAtBlock()` uses the current


`encryptionRegistry.appointerOf(_address)` without a historical reference. There is no storage of

the agent at snapshot time in the `Proposal` struct. The **EmergencyMultisig** `_canApprove()` then


bases approval on this potentially updated information.

```
         function resolveEncryptionAccountAtBlockresolveEncryptionAccountAtBlock((addressaddress _address _address, uint256uint256 _blockNumber _blockNumber)
            publicpublic
            viewview
            returns ((addressaddress _owner _owner, addressaddress _agent _agent)
         {
            if ((isListedAtBlockisListedAtBlock((_address_address,, _blockNumber _blockNumber))) {
              // The owner + the agent// The owner + the agent
              return ((_address_address,, settings settings..encryptionRegistryencryptionRegistry..getAppointedAgentgetAppointedAgent((_address_address))));
            }

            addressaddress _appointer _appointer == settings settings..encryptionRegistryencryptionRegistry..appointerOfappointerOf((_address_address));
            if ((thisthis..isListedAtBlockisListedAtBlock((_appointer_appointer,, _blockNumber _blockNumber))) {
              // The appointed agent votes// The appointed agent votes
              return ((_appointer_appointer,, _address _address));
            }

            // Not found, returning empty addresses// Not found, returning empty addresses
         }

```

https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 16/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


BVSS


<u>[AO:S/AC:L/AX:L/R:N/S:U/C:H/A:M/I:H/D:N/Y:N (2.1)](https://www.halborn.com/portal/bvss?q=AO:S/AC:L/AX:L/R:N/S:U/C:H/A:M/I:H/D:N/Y:N)</u>


Recommendation

**I** n the `createProposal()` functions of the **EmergencyMultisig** and **Multisig** contracts, capture the


creator’s owner/agent and store the agent used for encryption (since all approvers would likely use

the same mapping at creation time). Then, in `_canApprove()`, require that if an agent was set at


creation for that owner, only that specific agent can approve.


Alternatively, treat an agent change as invalid for existing proposals: if `appointerOf(msg.sender)` at


the snapshot block doesn’t match the current appointer (meaning the agent changed), then reject

the approval **or** require the original agent to vote. This ensures the individuals who actually have


the decrypted proposal (the original agent or the owner with original key) are the ones voting.


Implementing a full snapshot of agent mappings might be complex; at minimum, document this


behavior so the council knows not to change agents during active proposals. As a procedural
mitigation, the Security Council should refrain from rotating encryption agents until all active


emergency proposals are resolved.


Remediation Comment

**RISK ACCEPTED:** The **Taiko Labs team** has accepted the risk related to this finding.


References


<u>[aragon/taiko-contracts/src/SignerList.sol#L134-L151](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/SignerList.sol#L134-L151)</u>


<u>[aragon/taiko-contracts/src/EmergencyMultisig.sol#L366](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/EmergencyMultisig.sol#L366)</u>


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 17/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


// INFORMATIONAL


Description


Throughout the files in scope, there are several instances where components are declared but


never used. Instances of this issue include:


In the `StandardProposalCondition` contract, the `dao` variable is declared but not used throughout


the contract.

In the `Multisig` contract the `InvalidAddressListSource` error is declared but never used.


In the `OptimisticTokenVotingPlugin` contract the `ProposalCreationForbidden` error is declared


but never used.


Additionally, it was identified that several imported contracts or interfaces are not used within the


proposed scope.

```
    - src/SignerList.sol

         importimport {{IERC165IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol""@openzeppelin/contracts/utils/introspection/IERC165.sol";

    - src/factory/TaikoDaoFactory.sol

         importimport {{AddresslistAddresslist} from "@aragon/osx/plugins/utils/Addresslist.sol""@aragon/osx/plugins/utils/Addresslist.sol";

         importimport {{ERC1967ProxyERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol""@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

    - src/setup/EmergencyMultisigPluginSetup.sol

         importimport {{DAODAO} from "@aragon/osx/core/dao/DAO.sol""@aragon/osx/core/dao/DAO.sol";

    - src/setup/MultisigPluginSetup.sol

         importimport {{DAODAO} from "@aragon/osx/core/dao/DAO.sol""@aragon/osx/core/dao/DAO.sol";

    - src/setup/OptimisticTokenVotingPluginSetup.sol

         importimport {{ITaikoL1ITaikoL1} from "../adapted-dependencies/ITaikoL1.sol""../adapted-dependencies/ITaikoL1.sol";

```

BVSS


<u>[AO:A/AC:L/AX:M/R:N/S:U/C:N/A:N/I:L/D:N/Y:N (1.7)](https://www.halborn.com/portal/bvss?q=AO:A/AC:L/AX:M/R:N/S:U/C:N/A:N/I:L/D:N/Y:N)</u>


Recommendation


Remove the unused `dao` variable from the `StandardProposalCondition` contract. Alternatively, if


the variable is intended to be used, implement the necessary logic.


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 18/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


Remove unused custom errors and ensure that any relevant error checks consistently reference
active custom errors. This maintains a clean codebase, reduces confusion, and makes the


contract’s logic clearer for future readers and maintainers.


Remove unused imports in order to increase code maintainability and avoid unnecessary bloat.


Remediation Comment

**SOLVED:** The **Taiko Labs team** solved this finding in commit `f80fb99` by following the mentioned


recommendation.


Remediation Hash


<u>[https://github.com/aragon/taiko-contracts/pull/50/commits/f80fb99dea86277dfadcdcacdf86968](https://github.com/aragon/taiko-contracts/pull/50/commits/f80fb99dea86277dfadcdcacdf869689f804c53b)</u>


<u>[9f804c53b](https://github.com/aragon/taiko-contracts/pull/50/commits/f80fb99dea86277dfadcdcacdf869689f804c53b)</u>


References


<u>[aragon/taiko-contracts/src/conditions/StandardProposalCondition.sol#L14](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/conditions/StandardProposalCondition.sol#L14)</u>


<u>[aragon/taiko-contracts/src/SignerList.sol#L6](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/SignerList.sol#L6)</u>


<u>[aragon/taiko-contracts/src/factory/TaikoDaoFactory.sol#L14-L15](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/factory/TaikoDaoFactory.sol#L14-L15)</u>
<u>[aragon/taiko-contracts/src/factory/TaikoDaoFactory.sol#L20](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/factory/TaikoDaoFactory.sol#L20)</u>


<u>[aragon/taiko-contracts/src/interfaces/IEmergencyMultisig.sol#L5](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/interfaces/IEmergencyMultisig.sol#L5)</u>


<u>[aragon/taiko-contracts/src/interfaces/IMultisig.sol#L5](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/interfaces/IMultisig.sol#L5)</u>


<u>[aragon/taiko-contracts/src/interfaces/IOptimisticTokenVoting.sol#L6](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/interfaces/IOptimisticTokenVoting.sol#L6)</u>


<u>[aragon/taiko-contracts/src/setup/EmergencyMultisigPluginSetup.sol#L6](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/setup/EmergencyMultisigPluginSetup.sol#L6)</u>
<u>[aragon/taiko-contracts/src/setup/MultisigPluginSetup.sol#L6](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/setup/MultisigPluginSetup.sol#L6)</u>


<u>[aragon/taiko-contracts/src/setup/OptimisticTokenVotingPluginSetup.sol#L21](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/setup/OptimisticTokenVotingPluginSetup.sol#L21)</u>


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 19/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


// INFORMATIONAL


Description


The smart contracts in-scope include several functions that are declared as `public` but are not


invoked internally within the smart contracts. These functions are intended to be called only from
external sources.

```
    - src/DelegationWall.sol

            function registerregister((bytes memorymemory _contentUrl _contentUrl) public {

            function getCandidateAddressesgetCandidateAddresses(() public view returns ((addressaddress[[] memorymemory) {

            function candidateCountcandidateCount(() public view returns ((uint256uint256) {

    - src/EmergencyMultisig.sol

            function supportsInterfacesupportsInterface((bytes4bytes4 _interfaceId _interfaceId) public {

            function getProposalgetProposal((uint256uint256 _proposalId _proposalId) public {

            function hasApprovedhasApproved((uint256uint256 _proposalId _proposalId, addressaddress _account _account) public view returns ((boolbool) {

            function executeexecute((uint256uint256 _proposalId _proposalId, bytes memorymemory _metadataUri _metadataUri,, IDAO IDAO..ActionAction[[] calldatacalldata _actions _actions) public {

    - src/EncryptionRegistry.sol

            function appointAgentappointAgent((addressaddress _newAgent _newAgent) public {

            function setOwnPublicKeysetOwnPublicKey((bytes32bytes32 _publicKey _publicKey) public {

            function setPublicKeysetPublicKey((addressaddress _accountOwner _accountOwner, bytes32bytes32 _publicKey _publicKey) public {

            function getRegisteredAccountsgetRegisteredAccounts(() public view returns ((addressaddress[[] memorymemory) {

            function getAppointedAgentgetAppointedAgent((addressaddress _account _account) public view returns ((addressaddress) {

    - src/Multisig.sol

            function getProposalgetProposal((uint256uint256 _proposalId _proposalId) public {

            function hasApprovedhasApproved((uint256uint256 _proposalId _proposalId, addressaddress _account _account) public view returns ((boolbool) {

            function executeexecute((uint256uint256 _proposalId _proposalId) public {

    - src/OptimisticTokenVotingPlugin.sol

            function hasVetoedhasVetoed((uint256uint256 _proposalId _proposalId, addressaddress _voter _voter) public view returns ((boolbool) {

            function getProposalgetProposal((uint256uint256 _proposalId _proposalId) public {

            function vetoveto((uint256uint256 _proposalId _proposalId) publicpublic virtual virtual {

            function executeexecute((uint256uint256 _proposalId _proposalId) publicpublic virtual virtual {

            function updateOptimisticGovernanceSettingsupdateOptimisticGovernanceSettings((OptimisticGovernanceSettings OptimisticGovernanceSettings calldatacalldata _governanceSettings _governanceSettings) public {

            function parseProposalIdparseProposalId((uint256uint256 _proposalId _proposalId) public {

```

https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 20/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC

```
    - src/SignerList.sol

            function isListedOrAppointedByListedisListedOrAppointedByListed((addressaddress _address _address) public view returns ((boolbool listedOrAppointedByListed listedOrAppointedByListed) {

            function getListedEncryptionOwnerAtBlockgetListedEncryptionOwnerAtBlock((addressaddress _address _address, uint256uint256 _blockNumber _blockNumber) public {

            function resolveEncryptionAccountAtBlockresolveEncryptionAccountAtBlock((addressaddress _address _address, uint256uint256 _blockNumber _blockNumber) public {

            function supportsInterfacesupportsInterface((bytes4bytes4 _interfaceId _interfaceId) public viewview virtual override virtual override returns ((boolbool) {

    - src/factory/TaikoDaoFactory.sol

            function deployOncedeployOnce(() public {

            function getSettingsgetSettings(() public view returns ((DeploymentSettings DeploymentSettings memorymemory) {

            function getDeploymentgetDeployment(() public view returns ((Deployment Deployment memorymemory) {

```

BVSS


<u>[AO:A/AC:M/AX:M/R:N/S:U/C:N/A:N/I:L/D:N/Y:N (1.1)](https://www.halborn.com/portal/bvss?q=AO:A/AC:M/AX:M/R:N/S:U/C:N/A:N/I:L/D:N/Y:N)</u>


Recommendation


To improve code clarity and optimize gas usage, it is recommended to change the visibility of these

functions from `public` to `external` .


The `external` keyword is specifically designed for functions that are meant to be called from


outside the contract, and it can result in more efficient code execution.


By making this change, you can enhance the readability and performance of the smart contracts.


Remediation Comment

**SOLVED:** The **Taiko Labs team** solved this finding in commit `939b67a` by following the mentioned


recommendation.


Remediation Hash


<u>[https://github.com/aragon/taiko-contracts/pull/50/commits/939b67a60ddfd65198ba86e126d08d](https://github.com/aragon/taiko-contracts/pull/50/commits/939b67a60ddfd65198ba86e126d08da3e45ef2e4)</u>


<u>[a3e45ef2e4](https://github.com/aragon/taiko-contracts/pull/50/commits/939b67a60ddfd65198ba86e126d08da3e45ef2e4)</u>


References


<u>[aragon/taiko-contracts/src/DelegationWall.sol#L8](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/DelegationWall.sol#L8)</u>


<u>[aragon/taiko-contracts/src/EmergencyMultisig.sol#L19](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/EmergencyMultisig.sol#L19)</u>


<u>[aragon/taiko-contracts/src/EncryptionRegistry.sol#L14](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/EncryptionRegistry.sol#L14)</u>
<u>[aragon/taiko-contracts/src/OptimisticTokenVotingPlugin.sol#L24](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/OptimisticTokenVotingPlugin.sol#L24)</u>


<u>[aragon/taiko-contracts/src/SignerList.sol#L23](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/SignerList.sol#L23)</u>


<u>[aragon/taiko-contracts/src/conditions/StandardProposalCondition.sol#L13](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/conditions/StandardProposalCondition.sol#L13)</u>


<u>[aragon/taiko-contracts/src/factory/TaikoDaoFactory.sol#L26](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/factory/TaikoDaoFactory.sol#L26)</u>


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 21/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


// INFORMATIONAL


Description


The `EncryptionRegistry` contract maintains an `accountList` array that stores all registered


accounts, but lacks functionality to remove accounts that are no longer active or have been

removed as appointed agents. Accounts are added to this `accountList` when they first appoint an


agent or set a public key, but there is no corresponding mechanism to remove them when they


become inactive or delisted.


As the `accountList` grows indefinitely, operations that iterate through this list (like checking for


existing accounts in `appointAgent()` and `_setPublicKey()` ) will consume increasingly more gas. This


creates a potential DoS vector where the list becomes so large that operations become


prohibitively expensive or hit block gas limits.


BVSS


<u>[AO:S/AC:L/AX:L/R:N/S:U/C:N/A:N/I:M/D:N/Y:N (1.0)](https://www.halborn.com/portal/bvss?q=AO:S/AC:L/AX:L/R:N/S:U/C:N/A:N/I:M/D:N/Y:N)</u>


Recommendation


Implement a removal mechanism that allows accounts to be removed from the `accountList` when


they are removed as appointed agents. This could be achieved through a cleanup during agent
appointment or key setting operations.


Remediation Comment

**SOLVED:** The **Taiko Labs** **team** solved this finding in commit `2628cad` by following the mentioned


recommendation.


Remediation Hash


<u>[https://github.com/aragon/taiko-contracts/pull/50/commits/2628cad4b3af2bddefb69b5f2d02b04](https://github.com/aragon/taiko-contracts/pull/50/commits/2628cad4b3af2bddefb69b5f2d02b04ad29f5eb4)</u>


<u>[ad29f5eb4](https://github.com/aragon/taiko-contracts/pull/50/commits/2628cad4b3af2bddefb69b5f2d02b04ad29f5eb4)</u>


References


<u>[aragon/taiko-contracts/src/EncryptionRegistry.sol#L71](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/EncryptionRegistry.sol#L71)</u>
<u>[aragon/taiko-contracts/src/EncryptionRegistry.sol#L156](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/EncryptionRegistry.sol#L156)</u>


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 22/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


// INFORMATIONAL


Description


Throughout the contracts in scope, there are several instances where input validation is missing.


Instances if this issue include:


The `_governanceERC20Base` and `_governanceWrappedERC20Base` parameters are not checked


against the zero address in the `OptimisticTokenVotingPluginSetup` contract constructor.


The `_minDuration` parameter is not validated to fall within a reasonable range in the


`StandardProposalCondition` contract constructor. A long duration could potentially lock the contract


for an excessive period.

The `_dao` parameter in the `initialize()` function of the `SignerList` contract is not validated


against the zero address.

The `_setPublicKey()` function in the `EncryptionRegistry` contract does not validate the


`_publicKey` parameter against a valid length.

In the **OptimisticTokenVotingPlugin** contract, the `votingToken` and `taikoBridge` state variables


are updated without checking whether the assigned address is the zero address ( `address(0)` ).


BVSS


<u>[AO:A/AC:H/AX:L/R:N/S:U/C:N/A:N/I:L/D:N/Y:N (0.8)](https://www.halborn.com/portal/bvss?q=AO:A/AC:H/AX:L/R:N/S:U/C:N/A:N/I:L/D:N/Y:N)</u>


Recommendation


Implement input validation to ensure that the input parameters are valid and within the expected


ranges.


Remediation Comment

**PARTIALLY SOLVED:** The **Taiko Labs team** partially solved this finding in commit `a8fa1e5` by verifying


the `_governanceERC20Base` and `_governanceWrappedERC20Base` parameters against the zero address.


Remediation Hash


<u>[https://github.com/aragon/taiko-contracts/pull/50/commits/a8fa1e56c8a0ff1aaf5ff449cc67c1b2](https://github.com/aragon/taiko-contracts/pull/50/commits/a8fa1e56c8a0ff1aaf5ff449cc67c1b2f7eea591)</u>


<u>[f7eea591](https://github.com/aragon/taiko-contracts/pull/50/commits/a8fa1e56c8a0ff1aaf5ff449cc67c1b2f7eea591)</u>


References


<u>[aragon/taiko-contracts/src/setup/OptimisticTokenVotingPluginSetup.sol#L78](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/setup/OptimisticTokenVotingPluginSetup.sol#L78)</u>
<u>[aragon/taiko-contracts/src/conditions/StandardProposalCondition.sol#L30](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/conditions/StandardProposalCondition.sol#L30)</u>


<u>[aragon/taiko-contracts/src/SignerList.sol#L55](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/SignerList.sol#L55)</u>
<u>[aragon/taiko-contracts/src/EncryptionRegistry.sol#L143](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/EncryptionRegistry.sol#L143)</u>
<u>[aragon/taiko-contracts/src/OptimisticTokenVotingPlugin.sol#L177-L179](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/OptimisticTokenVotingPlugin.sol#L177-L179)</u>


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 23/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


// INFORMATIONAL


Description


In the `StandardProposalCondition` contract, the `dao` and `minDuration` variables are missing the


visibility modifier.


By default, variables are set to `internal` visibility. However, It is considered best practice to


explicitly specify visibility to enhance clarity and prevent ambiguity. Clearly labeling the visibility of
all variables and functions will help in maintaining clear and understandable code.


BVSS


<u>[AO:A/AC:L/AX:H/R:N/S:U/C:N/A:N/I:L/D:N/Y:N (0.8)](https://www.halborn.com/portal/bvss?q=AO:A/AC:L/AX:H/R:N/S:U/C:N/A:N/I:L/D:N/Y:N)</u>


Recommendation


Explicitly define the visibility of all variables in the contracts to enhance readability and reduce the


potential for errors.


Remediation Comment

**SOLVED:** The **Taiko Labs team** solved this finding in commit `62b1785` by following the mentioned


recommendation.


Remediation Hash


<u>[https://github.com/aragon/taiko-contracts/pull/50/commits/62b17859716d3482800ae08f6e721f](https://github.com/aragon/taiko-contracts/pull/50/commits/62b17859716d3482800ae08f6e721fdd5d55c95f)</u>
<u>[dd5d55c95f](https://github.com/aragon/taiko-contracts/pull/50/commits/62b17859716d3482800ae08f6e721fdd5d55c95f)</u>


References


<u>[aragon/taiko-contracts/src/conditions/StandardProposalCondition.sol#L14-L15](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/conditions/StandardProposalCondition.sol#L14-L15)</u>


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 24/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


// INFORMATIONAL


Description

In the **OptimisticTokenVotingPlugin** contract, there is an empty `revert` statement, as follows:

```
       ifif ((_taikoL1 _taikoL1 == addressaddress((00))) revertrevert(());

```

In case the condition is met, the function call to the `initialize()` function will revert without a


descriptive error message.


BVSS


<u>[AO:A/AC:L/AX:H/R:N/S:U/C:N/A:N/I:L/D:N/Y:N (0.8)](https://www.halborn.com/portal/bvss?q=AO:A/AC:L/AX:H/R:N/S:U/C:N/A:N/I:L/D:N/Y:N)</u>


Recommendation


Consider creating a custom error for this specific condition, or reverting with a string (reason) for
clarity.


Remediation Comment

**SOLVED:** The **Taiko Labs team** solved this finding in commit `a8fa1e5` by following the mentioned


recommendation.


Remediation Hash


<u>[https://github.com/aragon/taiko-contracts/pull/50/commits/a8fa1e56c8a0ff1aaf5ff449cc67c1b2](https://github.com/aragon/taiko-contracts/pull/50/commits/a8fa1e56c8a0ff1aaf5ff449cc67c1b2f7eea591)</u>


<u>[f7eea591](https://github.com/aragon/taiko-contracts/pull/50/commits/a8fa1e56c8a0ff1aaf5ff449cc67c1b2f7eea591)</u>


References


<u>[aragon/taiko-contracts/src/OptimisticTokenVotingPlugin.sol#L175](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/OptimisticTokenVotingPlugin.sol#L175)</u>


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 25/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


// INFORMATIONAL


Description


The `SignerList` contract lacks validation against zero addresses when adding new signers through


the `initialize()` and `addSigners()` functions. These functions rely on the internal `_addAddresses()`


function inherited from the `Addresslist` contract, which does not perform zero address validation.


The addition of zero addresses could affect quorum calculations, by artificially inflating the number
of available signers.


BVSS


<u>[AO:S/AC:L/AX:L/R:N/S:U/C:N/A:L/I:L/D:N/Y:N (0.6)](https://www.halborn.com/portal/bvss?q=AO:S/AC:L/AX:L/R:N/S:U/C:N/A:L/I:L/D:N/Y:N)</u>


Recommendation


Implement zero address validation to prevent adding invalid addresses as signers.


Remediation Comment

**ACKNOWLEDGED:** The **Taiko Labs team** made a business decision to acknowledge this finding and


not alter the contracts.


References


<u>[aragon/taiko-contracts/src/SignerList.sol#L55](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/SignerList.sol#L55)</u>


<u>[aragon/taiko-contracts/src/SignerList.sol#L68](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/SignerList.sol#L68)</u>


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 26/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


// INFORMATIONAL


Description


Several function calls throughout the contracts in scope ignore the return values of the functions
they call. Ignoring return values can lead to unexpected behavior and may result in unanticipated
outcomes.


Instances of unhandled return values include:


In src/EmergencyMultisig.sol:

```
       proposal_proposal_..destinationPlugindestinationPlugin..createProposalcreateProposal(

```

In src/Multisig.sol

```
       proposal_proposal_..destinationPlugindestinationPlugin..createProposalcreateProposal(

```

BVSS


<u>[AO:S/AC:L/AX:L/R:N/S:U/C:N/A:N/I:L/D:N/Y:N (0.5)](https://www.halborn.com/portal/bvss?q=AO:S/AC:L/AX:L/R:N/S:U/C:N/A:N/I:L/D:N/Y:N)</u>


Recommendation


Ensure that the return values of external calls are handled appropriately throughout the contracts.


Remediation Comment

**ACKNOWLEDGED:** The **Taiko Labs team** made a business decision to acknowledge this finding and


not alter the contracts.


References


<u>[aragon/taiko-contracts/src/EmergencyMultisig.sol#L343](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/EmergencyMultisig.sol#L343)</u>


<u>[aragon/taiko-contracts/src/Multisig.sol#L328](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/Multisig.sol#L328)</u>


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 27/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


// INFORMATIONAL


Description


Smart contracts should be deployed with the same compiler version and flags that they have been


tested with thoroughly. Locking the pragma helps to ensure that contracts do not accidentally get
deployed using, for example, an outdated compiler version that might introduce bugs that affect the
contract system negatively.


During the analysis of the proposed scope, it was identified that all smart contracts are using a


floating pragma, as follows:

```
         pragmapragma solidity ^^0.8.170.8.17;

```

BVSS


<u>[AO:A/AC:H/AX:H/R:N/S:U/C:N/A:N/I:L/D:N/Y:N (0.3)](https://www.halborn.com/portal/bvss?q=AO:A/AC:H/AX:H/R:N/S:U/C:N/A:N/I:L/D:N/Y:N)</u>


Recommendation


Lock the pragma version and also consider known bugs


[(https://github.com/ethereum/solidity/releases) for the compiler version that is chosen.](https://github.com/ethereum/solidity/releases)


Remediation Comment

**ACKNOWLEDGED:** The **Taiko Labs team** made a business decision to acknowledge this finding and


not alter the contracts.


References


<u>[aragon/taiko-contracts/src/conditions/StandardProposalCondition.sol#L3](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/conditions/StandardProposalCondition.sol#L3)</u>
<u>[aragon/taiko-contracts/src/factory/TaikoDaoFactory.sol#L2](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/factory/TaikoDaoFactory.sol#L2)</u>
<u>[aragon/taiko-contracts/src/helpers/proxy.sol#L2](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/helpers/proxy.sol#L2)</u>


<u>[aragon/taiko-contracts/src/setup/OptimisticTokenVotingPluginSetup.sol#L3](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/setup/OptimisticTokenVotingPluginSetup.sol#L3)</u>
<u>[aragon/taiko-contracts/src/DelegationWall.sol#L3](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/DelegationWall.sol#L3)</u>


<u>[aragon/taiko-contracts/src/EmergencyMultisig.sol#L3](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/EmergencyMultisig.sol#L3)</u>
<u>[aragon/taiko-contracts/src/EncryptionRegistry.sol#L3](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/EncryptionRegistry.sol#L3)</u>
<u>[aragon/taiko-contracts/src/Multisig.sol#L3](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/Multisig.sol#L3)</u>


<u>[aragon/taiko-contracts/src/OptimisticTokenVotingPlugin.sol#L3](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/OptimisticTokenVotingPlugin.sol#L3)</u>
<u>[aragon/taiko-contracts/src/SignerList.sol#L3](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/SignerList.sol#L3)</u>


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 28/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


` `


// INFORMATIONAL


Description


In the `resolveEncryptionAccountAtBlock()` function of the `SignersList` contract, the `this` keyword


is used redundantly when calling the `isListedAtBlock()` function.

```
       ifif ((thisthis..isListedAtBlockisListedAtBlock((_appointer_appointer,, _blockNumber _blockNumber))) {
         // The appointed agent votes// The appointed agent votes
         return ((_appointer_appointer,, _address _address));
       } }

```

While using the `this` keyword is not incorrect, it is redundant and may create gas overhead in this


context.


BVSS


<u>[AO:S/AC:H/AX:L/R:N/S:U/C:N/A:L/I:N/D:N/Y:N (0.2)](https://www.halborn.com/portal/bvss?q=AO:S/AC:H/AX:L/R:N/S:U/C:N/A:L/I:N/D:N/Y:N)</u>


Recommendation


Call the `isListedAtBlock()` function directly without using the `this` keyword.


Remediation Comment

**SOLVED:** The **Taiko Labs team** solved this finding in commit `eb18176` by following the mentioned


recommendation.


Remediation Hash


<u>[https://github.com/aragon/taiko-contracts/pull/50/commits/eb18176260c3e200ae79f74ddb233b](https://github.com/aragon/taiko-contracts/pull/50/commits/eb18176260c3e200ae79f74ddb233b81790dd601)</u>
<u>[81790dd601](https://github.com/aragon/taiko-contracts/pull/50/commits/eb18176260c3e200ae79f74ddb233b81790dd601)</u>


References


<u>[aragon/taiko-contracts/src/SignerList.sol#L145](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/SignerList.sol#L145)</u>


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 29/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


// INFORMATIONAL


Description


In the `deployOnce()` function of the `TaikoFactory` contract, state is modified. However, these


changes are not reflected in any event emission. Additionally, in the `execute()` function of the


`OptimisticTokenVotingPlugin` no events are emitted as well.


BVSS


<u>[AO:S/AC:L/AX:H/R:N/S:U/C:N/A:N/I:L/D:N/Y:N (0.2)](https://www.halborn.com/portal/bvss?q=AO:S/AC:L/AX:H/R:N/S:U/C:N/A:N/I:L/D:N/Y:N)</u>


Recommendation


Emit events for all state changes that occur as a result of administrative functions to facilitate off

chain monitoring of the system.


Remediation Comment

**ACKNOWLEDGED:** The **Taiko Labs team** made a business decision to acknowledge this finding and


not alter the contracts.


References


<u>[aragon/taiko-contracts/src/factory/TaikoDaoFactory.sol#L107](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/factory/TaikoDaoFactory.sol#L107)</u>


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 30/31


3/25/25, 10:09 AM Preview Taiko DAO Contracts | SSC


// INFORMATIONAL


Description


In the `SignerList` contract there is a typo in an error name, where the word `Registry` is misspelled


as `Regitry` _._

```
       error error InvalidEncryptionRegitryInvalidEncryptionRegitry((addressaddress givenAddress givenAddress));

```

While this typo does not affect the functionality of the code, it can make the codebase harder to
read and understand.


BVSS


<u>[AO:S/AC:H/AX:H/R:N/S:U/C:N/A:N/I:L/D:N/Y:N (0.1)](https://www.halborn.com/portal/bvss?q=AO:S/AC:H/AX:H/R:N/S:U/C:N/A:N/I:L/D:N/Y:N)</u>


Recommendation


Correct the typo in the error name to improve the readability of the codebase.


Remediation Comment

**SOLVED:** The **Taiko Labs team** solved this finding in commit `eb18176` by following the mentioned


recommendation.


Remediation Hash


<u>[https://github.com/aragon/taiko-contracts/pull/50/commits/eb18176260c3e200ae79f74ddb233b](https://github.com/aragon/taiko-contracts/pull/50/commits/eb18176260c3e200ae79f74ddb233b81790dd601)</u>


<u>[81790dd601](https://github.com/aragon/taiko-contracts/pull/50/commits/eb18176260c3e200ae79f74ddb233b81790dd601)</u>


References


<u>[aragon/taiko-contracts/src/SignerList.sol#L30](https://github.com/aragon/taiko-contracts/blob/eed36d3102957236c53164d06ff67000a5ee2e67/src/SignerList.sol#L30)</u>


Halborn strongly recommends conducting a follow-up assessment of the project either within six months or
immediately following any material changes to the codebase, whichever comes first. This approach is crucial for
maintaining the project’s integrity and addressing potential vulnerabilities introduced by code modifications.


https://www.halborn.com/portal/reports/preview?auditId=615b52c8-515a-4584-b6d8-208a1e44391c 31/31


