# **Offchain Labs - Sequencer Feed** **Ticketing**
### Security Assessment (Summary Report)

**July 31, 2026**


_Prepared for:_ ​

**Harry Kalodner, Steven Goldfeder, and Ed Felten​**

Offchain Labs


_Prepared by:_ **Simone Monica, Nicolas Donboly, and Jaime Iglesias**


​
Trail of Bits​ ​ ​
**PUBLIC​** **​**


## Table of Contents

**Table of Contents​** **1**

**Project Summary​** **2**

**Project Targets​** **3**

**Executive Summary​** **4**

**A. Code Quality Findings​** **5**

**About Trail of Bits​** **7**

**Notices and Remarks​** **8**


​
Trail of Bits​ 1​ Offchain Labs - Sequencer Feed Ticketing​
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


​ **Nicolas Donboly**, Consultant​ **Simone Monica**, Consultant
​ nicolas.donboly@trailofbits.com​ simone.monica@trailofbits.com

​ **Jaime Iglesias**, Consultant
jaime.iglesias@trailofbits.com​

#### Project Timeline

The significant events and milestones of the project are listed below.


**<u>Date​</u>** **<u>Event</u>**


**July 14, 2026 ​** Delivery of summary report draft


**July 31, 2026** ​ Delivery of final summary report


​
Trail of Bits​ 2​ Offchain Labs - Sequencer Feed Ticketing​
**PUBLIC​** **​** Security Assessment


## Project Targets

Feed-Tickets-Contracts

Repository ​ https://github.com/OffchainLabs/feed-ticket-contracts


Version ​ 9d04eb0be29733b9f302a56976a0f3148f10866e


Type ​ Solidity


Platform ​ Arbitrum


​
Trail of Bits​ 3​ Offchain Labs - Sequencer Feed Ticketing​
**PUBLIC​** **​** Security Assessment


## Executive Summary

#### Engagement Overview

Offchain Labs engaged Trail of Bits to review the security of their sequencer feed ticketing
contracts.


A team of three consultants conducted the review from June 29 to July 1, 2026, for a total of
nine engineer-days of effort. With full access to source code and documentation, we
performed static and dynamic testing of the target, using automated and manual
processes.

#### Observations and Impact

This new feature allows users to access a premium sequencer feed by purchasing tickets.
The contracts in scope manage all the accounting and purchasing for these tickets.


The main focus of the review was to determine whether this feature was correctly
implemented and to identify potential edge cases, missing functionality, and opportunities
for improvement. Additionally, we looked for logical issues and Solidity-specific issues.


All findings are enhancements to code quality and relate to undocumented edge cases and
UX improvements.

#### Recommendations

**●​** **Consider addressing the Code Quality findings presented in appendix A.**


​
Trail of Bits​ 4​ Offchain Labs - Sequencer Feed Ticketing​
**PUBLIC​** **​** Security Assessment


## A. Code Quality Findings

The following findings are not associated with any specific vulnerabilities. However, fixing
them will enhance code readability and may prevent the introduction of vulnerabilities in
the future.


●​ **Grandfather guarantee can be broken by lowering _maxTicketsPerRound**
**during the grandfather window.** If an admin reduces the _maxTicketsPerRound,
there could be a situation where some users will not be able to renew their
grandfathered tickets because the round does not have enough tickets to cover
them.


function purchaseTickets(
uint256 expectedRound,
uint256 expectedPrice,
<mark>uint256</mark> <mark>numTicketsDesired,</mark>
bytes32 apiKeyHash
) external {
<mark>_lazyUpdateRoundState();</mark>

if (numTicketsDesired == 0) revert ZeroTicketsRequested();
if (expectedRound != _roundNumber) revert RoundNumberMismatch(expectedRound,
_roundNumber);
if (expectedPrice != _currentPrice) revert IncorrectTicketPrice(expectedPrice,
_currentPrice);
<mark>if</mark> <mark>(_ticketsSoldThisRound</mark> <mark>>=</mark> <mark>_maxTicketsPerRound)</mark> <mark>{</mark>
<mark>revert</mark> <mark>MaxTicketsSold();</mark>
}

uint16 _numTicketsDesired = numTicketsDesired.toUint16();
<mark>uint16</mark> <mark>_numTickets</mark> <mark>=</mark> <mark>uint256(_ticketsSoldThisRound)</mark> <mark>+</mark>
<mark>uint256(_numTicketsDesired)</mark> <mark>></mark> <mark>_maxTicketsPerRound</mark>
<mark>?</mark> <mark>_maxTicketsPerRound</mark> <mark>-</mark> <mark>_ticketsSoldThisRound</mark>
<mark>:</mark> <mark>_numTicketsDesired;</mark>
[...]


_Figure A.1: part of the purchaseTickets function in Tickets.sol_


●​ **Partial fills in purchaseTickets are silent.** If there are not enough tickets to
cover numTicketsDesired, the function will purchase as many as are available.


However, users have no control over this partial fill; instead, we suggest adding
another parameter to the function _minTicketsDesired that prevents partial fills
unless they cover a minimum number of tickets the user desires.


function purchaseTickets(
uint256 expectedRound,


​
Trail of Bits​ 5​ Offchain Labs - Sequencer Feed Ticketing​
**PUBLIC​** **​** Security Assessment


uint256 expectedPrice,
<mark>uint256</mark> <mark>numTicketsDesired,</mark>
bytes32 apiKeyHash
) external {
_lazyUpdateRoundState();

[...]

<mark>uint16</mark> <mark>_numTicketsDesired</mark> <mark>=</mark> <mark>numTicketsDesired.toUint16();</mark>
<mark>uint16</mark> <mark>_numTickets</mark> <mark>=</mark> <mark>uint256(_ticketsSoldThisRound)</mark> <mark>+</mark>
<mark>uint256(_numTicketsDesired)</mark> <mark>></mark> <mark>_maxTicketsPerRound</mark>
<mark>?</mark> <mark>_maxTicketsPerRound</mark> <mark>-</mark> <mark>_ticketsSoldThisRound</mark>
<mark>:</mark> <mark>_numTicketsDesired;</mark>
<mark>uint256</mark> <mark>cost</mark> <mark>=</mark> <mark>expectedPrice</mark> <mark>*</mark> <mark>uint256(_numTickets);</mark>

UserData memory userDataMem = _userData[msg.sender];
if (userDataMem.tokenBalance < cost) {
revert InsufficientTokenBalance(userDataMem.tokenBalance, cost);
}

[...]


_Figure A.2: _numTickets clamping in the purchaseTickets function in Tickets.sol_


​
Trail of Bits​ 6​ Offchain Labs - Sequencer Feed Ticketing​
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
Trail of Bits​ 7​ Offchain Labs - Sequencer Feed Ticketing​
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
Trail of Bits​ 8​ Offchain Labs - Sequencer Feed Ticketing​
**PUBLIC​** **​** Security Assessment


