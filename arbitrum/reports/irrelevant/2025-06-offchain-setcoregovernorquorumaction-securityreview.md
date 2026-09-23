# **Offchain Labs** **SetCoreGovernorQuorumAction**

### Security Assessment (Summary Report)

**June 16, 2025**


_Prepared for:_ ​

**Harry Kalodner, Steven Goldfeder, and Ed Felten​**

Offchain Labs


_Prepared by:_ **Jaime Iglesias, Simone Monica, and Nicolas Donboly**


​
Trail of Bits​ ​ ​
**PUBLIC​** **​**


## Table of Contents

**Table of Contents​** **1**

**Project Summary​** **2**

**Project Targets​** **3**

**Executive Summary​** **4**

**A. Code Quality Findings​** **5**

**About Trail of Bits​** **6**

**Notices and Remarks​** **7**


​
Trail of Bits​ 1​ Offchain Labs SetCoreGovernorQuorumAction​
**PUBLIC​** **​** Security Assessment


## Project Summary

#### Contact Information

The following project manager was associated with this project:


**Mary O’Brien**, Project Manager
[mary.obrien@trailofbits.com](mailto:mary.obrien@trailofbits.com)


The following engineering director was associated with this project:


**Benjamin Samuels**, Engineering Director, Blockchain
benjamin.samuels@trailofbits.com


The following consultants were associated with this project:


​ **Jaime Iglesias**, Consultant​ ​ ​ **Simone Monica**, Consultant
​ jaime.iglesias@trailofbits.com​ ​ [simone.monica@trailofbits.com](mailto:simone.monica@trailofbits.com)

​ **Nicolas Donboly**, Consultant
nicolas.donboly@trailofbits.com

#### Project Timeline

The significant events and milestones of the project are listed below.


**<u>Date​</u>** **<u>Event</u>**


**June 9, 2025​** Pre-project kickoff call


**June 9, 2025​** Delivery of report draft


**June 16, 2025** ​ Delivery of final summary report


​
Trail of Bits​ 2​ Offchain Labs SetCoreGovernorQuorumAction​
**PUBLIC​** **​** Security Assessment


## Project Targets

The engagement involved reviewing and testing the following target.


ArbitrumFoundation

Repository ​ [https://github.com/ArbitrumFoundation/governance](https://github.com/ArbitrumFoundation/governance)


Version ​ [d2163adcb6b5415d76bc4d09ec21791749b00c8e](https://github.com/ArbitrumFoundation/governance/commit/d2163adcb6b5415d76bc4d09ec21791749b00c8e)


​ [4bf1db4702469d3cd17dcefaf0ffbaa92f880763](https://github.com/ArbitrumFoundation/governance/commit/4bf1db4702469d3cd17dcefaf0ffbaa92f880763)


Type ​ Solidity


Platform ​ Arbitrum


​
Trail of Bits​ 3​ Offchain Labs SetCoreGovernorQuorumAction​
**PUBLIC​** **​** Security Assessment


## Executive Summary

#### Engagement Overview

Offchain Labs engaged Trail of Bits to review the security of the
SetCoreGovernorQuorumAction and SetConstitutionHashAction governance
[proposals, specifically PR #341 and PR #346, respectively.](https://github.com/ArbitrumFoundation/governance/pull/341)


A team of three consultants conducted the review from June 9 to June 10, 2025, for a total
of six engineer-days of effort. With full access to source code and documentation, we
[performed a manual review of PR #341 and PR #346.](https://github.com/ArbitrumFoundation/governance/pull/341)

#### Observations and Impact

[PR #341 introduces a new governance action contract (SetCoreGovernorQuorumAction)](https://github.com/ArbitrumFoundation/governance/pull/341)
that implements a proposal to reduce the Arbitrum DAO’s voting quorum threshold from
5% to 4.5% of all votable tokens. This reduction aims to make governance more accessible
and to prevent proposal failures due to insufficient participation, though it also reduces the
[economic cost of potential governance attacks. This change is motivated by challenges in](https://forum.arbitrum.foundation/t/constitutional-aip-constitutional-quorum-threshold-reduction/29145)
[reaching quorum for important governance decisions due to low voter participation. The](https://forum.arbitrum.foundation/t/constitutional-aip-constitutional-quorum-threshold-reduction/29145)
[contract, deployed at address 0xd5FDDac0BC78C5D7fD1FC0F66B05d697029D9946, will](https://arbiscan.io/address/0xd5FDDac0BC78C5D7fD1FC0F66B05d697029D9946)
be executed through Arbitrum’s standard governance process.


[PR #346 introduces an action contract that changes the on-chain DAO constitution hash to](https://github.com/ArbitrumFoundation/governance/pull/346)
reflect the new quorum parameter.


[The review focused on ensuring that the governance proposal follows Arbitrum](https://github.com/ArbitrumFoundation/governance/blob/main/docs/overview.md#invariants)
[governance’s invariants, that the governance action contract follows Arbitrum’s standards](https://github.com/ArbitrumFoundation/governance/blob/main/docs/overview.md#invariants)
[and guidelines, and that the action implements the intended behavior. We carefully](https://github.com/ArbitrumFoundation/governance/blob/main/src/gov-action-contracts/README.md#governance-action-contract-standards-and-guidelines)
[reviewed the payload generation and the specific actions encoded in the calldata. Finally,](https://github.com/ArbitrumFoundation/governance/pull/341#issue-3014663069)
[we reviewed PR #346.](https://github.com/ArbitrumFoundation/governance/pull/346)


[The review did not reveal any security-relevant issues with the changes made in PR #341 or](https://github.com/ArbitrumFoundation/governance/pull/341)
[PR #346.](https://github.com/ArbitrumFoundation/governance/pull/346)

#### Recommendations

We recommend implementing the recommendation provided in the Code Quality Findings
appendix.


​
Trail of Bits​ 4​ Offchain Labs SetCoreGovernorQuorumAction​
**PUBLIC​** **​** Security Assessment


## A. Code Quality Findings

The following finding is not associated with any specific vulnerabilities. However, fixing it
will enhance code readability and may prevent the introduction of vulnerabilities in the
future.


●​ [According to the “Governance Action Contract Standards and Guidelines,” the](https://github.com/ArbitrumFoundation/governance/blob/main/src/gov-action-contracts/README.md#governance-action-contract-standards-and-guidelines)
[perform function should verify that the current quorum numerator is as expected](https://github.com/ArbitrumFoundation/governance/blob/d2163adcb6b5415d76bc4d09ec21791749b00c8e/src/gov-action-contracts/governance/SetCoreGovernorQuorumAction.sol#L18-L27)
(500) before calling coreGov.relay to update it. It must also ensure that the
update has been applied correctly (450) after the call to relay; if not, the function
should revert. We recommend adding at least an after check in the perform
function of the SetCoreGovernorQuorumAction contract.


​
Trail of Bits​ 5​ Offchain Labs SetCoreGovernorQuorumAction​
**PUBLIC​** **​** Security Assessment


## About Trail of Bits

Founded in 2012 and headquartered in New York, Trail of Bits provides technical security
assessment and advisory services to some of the world’s most targeted organizations. We
combine high-­end security research with a real­-world attacker mentality to reduce risk and
fortify code. With 100+ employees around the globe, we’ve helped secure critical software
elements that support billions of end users, including Kubernetes and the Linux kernel.


[We maintain an exhaustive list of publications at https://github.com/trailofbits/publications,](https://github.com/trailofbits/publications)
with links to papers, presentations, public audit reports, and podcast appearances.


In recent years, Trail of Bits consultants have showcased cutting-edge research through
presentations at CanSecWest, HCSS, Devcon, Empire Hacking, GrrCon, LangSec, NorthSec,
the O’Reilly Security Conference, PyCon, REcon, Security BSides, and SummerCon.


We specialize in software testing and code review assessments, supporting client
organizations in the technology, defense, blockchain, and finance industries, as well as
government entities. Notable clients include HashiCorp, Google, Microsoft, Western Digital,
Uniswap, Solana, Ethereum Foundation, Linux Foundation, and Zoom.


[To keep up to date with our latest news and announcements, please follow @trailofbits on](https://x.com/trailofbits)
[X or LinkedIn, and explore our public repositories at https://github.com/trailofbits. To](https://x.com/trailofbits)
[engage us directly, visit our “Contact” page at https://www.trailofbits.com/contact or email](https://www.trailofbits.com/contact)
[us at info@trailofbits.com.](mailto:info@trailofbits.com)


**Trail of Bits, Inc.** ​
228 Park Ave S #80688
New York, NY 10003
https://www.trailofbits.com​
[info@trailofbits.com](mailto:info@trailofbits.com)


​
Trail of Bits​ 6​ Offchain Labs SetCoreGovernorQuorumAction​
**PUBLIC​** **​** Security Assessment


## Notices and Remarks

#### Copyright and Distribution

© 2025 by Trail of Bits, Inc.


All rights reserved. Trail of Bits hereby asserts its right to be identified as the creator of this
report in the United Kingdom.


Trail of Bits considers this report public information; it is licensed to Offchain Labs under
the terms of the project statement of work and has been made public at Offchain Labs’
request. Material within this report may not be reproduced or distributed in part or in
whole without Trail of Bits’ express written permission.


[The sole canonical source for Trail of Bits publications is the Trail of Bits Publications page.](https://github.com/trailofbits/publications)
Reports accessed through sources other than that page may have been modified and
should not be considered authentic.

#### Test Coverage Disclaimer

All activities undertaken by Trail of Bits in association with this project were performed in
accordance with a statement of work and agreed upon project plan.


Security assessment projects are time-boxed and often reliant on information that may be
provided by a client, its affiliates, or its partners. As a result, the findings documented in
this report should not be considered a comprehensive list of security issues, flaws, or
defects in the target system or codebase.


Trail of Bits uses automated testing techniques to rapidly test the controls and security
properties of software. These techniques augment our manual security review work, but
each has its limitations: for example, a tool may not generate a random edge case that
violates a property or may not fully complete its analysis during the allotted time. Their use
is also limited by the time and resource constraints of a project.


​
Trail of Bits​ 7​ Offchain Labs SetCoreGovernorQuorumAction​
**PUBLIC​** **​** Security Assessment


