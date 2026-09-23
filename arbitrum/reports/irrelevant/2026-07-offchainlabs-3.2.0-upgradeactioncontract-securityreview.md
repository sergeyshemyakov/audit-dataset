# **Offchain Labs - 3.2.0 Upgrade Action** **Contract**
### Security Assessment (Summary Report)

**July 31, 2026**


_Prepared for:_ ​

**Harry Kalodner, Steven Goldfeder, and Ed Felten​**

Offchain Labs


_Prepared by:_ **Simone Monica and Jaime Iglesias**


​
Trail of Bits​ ​ ​
**PUBLIC​** **​**


## Table of Contents

**Table of Contents​** **1**

**Project Summary​** **2**

**Project Targets​** **3**

**Executive Summary​** **4**

**About Trail of Bits​** **5**

**Notices and Remarks​** **6**


​
Trail of Bits​ 1​ Offchain Labs - 3.2.0 Upgrade Action Contract​
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


​ **Simone Monica**, Consultant​ **Jaime Iglesias**, Consultant
​ simone.monica@trailofbits.com​ jaime.iglesias@trailofbits.com​

#### Project Timeline

The significant events and milestones of the project are listed below.


**<u>Date​</u>** **<u>Event</u>**


**July 14, 2026 ​** Delivery of summary report draft


**July 31, 2026** ​ Delivery of final summary report


​
Trail of Bits​ 2​ Offchain Labs - 3.2.0 Upgrade Action Contract​
**PUBLIC​** **​** Security Assessment


## Project Targets

Arbitrum-Chain-Actions

Repository ​ https://github.com/OffchainLabs/arbitrum-chain-actions


Version ​ fdab5b87ee5e478898478246943a1b1d38da8d52


Type ​ Solidity


Platform ​ Arbitrum


​
Trail of Bits​ 3​ Offchain Labs - 3.2.0 Upgrade Action Contract​
**PUBLIC​** **​** Security Assessment


## Executive Summary

#### Engagement Overview

Offchain Labs engaged Trail of Bits to review the security of the 3.2.0 Upgrade Action
Contract.


A team of two consultants conducted the review from June 2 to June 3, 2026, for a total of
four engineer-days of effort. With full access to source code and documentation, we
performed static and dynamic testing of the target, using automated and manual
processes.

#### Observations and Impact

This action contract bumps an existing rollup from nitro-contracts v3.1.0 to v3.2.0. Only
the rollup proxy implementations are touched.


The main focus of the review was to determine whether this feature was correctly
implemented, identify potential edge cases, and identify any missing functionality.


We specifically checked that the contracts are upgraded correctly and that the addresses
match the expected ones defined in the reference JSON. Note that the action contract has
not yet been deployed.


We identified no findings.


​
Trail of Bits​ 4​ Offchain Labs - 3.2.0 Upgrade Action Contract​
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


[To keep up with our latest news and announcements, please follow @trailofbits on X or](https://x.com/trailofbits)
[LinkedIn and explore our public repositories at https://github.com/trailofbits. To engage us](https://www.linkedin.com/company/trail-of-bits)
[directly, visit our “Contact” page at https://www.trailofbits.com/contact or email us at](https://www.trailofbits.com/contact)
[info@trailofbits.com.](mailto:info@trailofbits.com)


**Trail of Bits, Inc.** ​
228 Park Ave S #80688
New York, NY 10003
https://www.trailofbits.com​
[info@trailofbits.com](mailto:info@trailofbits.com)


​
Trail of Bits​ 5​ Offchain Labs - 3.2.0 Upgrade Action Contract​
**PUBLIC​** **​** Security Assessment


## Notices and Remarks

#### Copyright and Distribution

© 2026 by Trail of Bits, Inc.


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

Trail of Bits performed all activities associated with this project in accordance with a
statement of work and an agreed-upon project plan.


Security assessment projects are time-boxed and often rely on information provided by a
client, its affiliates, or its partners. As a result, the findings documented in this report
should not be considered a comprehensive list of security issues, flaws, or defects in the
target system or codebase.


Trail of Bits uses automated testing techniques to rapidly test software controls and
security properties. These techniques augment our manual security review work, but each
has its limitations. For example, a tool may not generate a random edge case that violates a
property or may not fully complete its analysis during the allotted time. A project's time and
resource constraints also limit their use.


​
Trail of Bits​ 6​ Offchain Labs - 3.2.0 Upgrade Action Contract​
**PUBLIC​** **​** Security Assessment


