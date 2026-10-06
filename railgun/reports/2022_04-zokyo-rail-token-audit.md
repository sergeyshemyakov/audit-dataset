<!-- page 1 -->
SMART CONTRACT AUDIT
railgun_
April 21th, 2022 | v. 1.0


<!-- page 2 -->
score
100
PASS
Zokyo’s Security Team has concluded 
that this smart contract passes 
security qualifications to be listed on 
digital asset exchanges.
Security Audit Score


<!-- page 3 -->
1
RAIL Token Smart Contract Audit
This document outlines the overall security of the RAIL Token smart contracts, evaluated by 
Zokyo's Blockchain Security team.
Technical​ ​Summary
The scope of this audit was to analyze and document the RAIL Token smart contract 
codebase for quality, security, and correctness.
The testable code is significant for the ensurance of contracts security.
It should be noted that this audit is not an endorsement of the reliability or effectiveness of 
the contract, rather it is limited to an assessment of the logic and implementation. In order 
to ensure that a smart contract is able to withstand the Ethereum network’s fast-paced and 
rapidly changing environment, we at Zokyo recommend that the RAIL Token team put in 
place a bug bounty program to encourage further and active analysis of the smart contract.
Testable Code
100%
75%
50%
25%
0%
your average
INDUSTRY STANDARD
Contract Status
low Risk


<!-- page 4 -->
2
RAIL Token Smart Contract Audit
3
Auditing Strategy and Techniques Applied
5
Executive Summary
6
Structure​ ​and​ ​Organization​ ​of​ ​Document
7
Complete​ ​Analysis
Table of Contents


<!-- page 5 -->
The Smart contract’s source code was taken from Etherscan.
Repository: https://etherscan.io/
address/0xe76c6c83af64e4c60245d8c7de953df673a7a33d#c ode#F1#L1
Auditing Strategy and Techniques Applied
3
RAIL Token Smart Contract Audit
Within the scope of this audit Zokyo auditors have reviewed the following contract(s):
Rail.sol
Behavior of `transfer` method is equivalent to standard ERC20 behaviour in ALL scenarios 
after ANTI_BOT_LOCKTIME has passed
- ANTI_BOT_LOCKTIME has passed and there is no way for the `transfer` method to revert 
back to a non-standard ERC20 transfer behavior
- governanceMint method is only callable by the governance contract and can mint up to a 
max supply of cap
- _mint() can mint up to a max supply of cap and can be called by method governanceMint 
and during deploy of smart contract
Additional requirements to check:
Throughout the review process, care was taken to ensure that the contract:
Implements and adheres to existing standards appropriately and effectively;
Documentation and code comments match logic and behavior;
Distributes tokens in a manner that matches calculations;
Follows best practices in efficient use of resources, without unnecessary waste;
Uses methods safe from reentrance attacks;
Is not affected by the latest vulnerabilities;
Whether the code meets best practices in code readability, etc.


<!-- page 6 -->
4
RAIL Token Smart Contract Audit
Zokyo’s Security Team has followed best practices and industry-standard techniques to 
verify the implementation of RAIL Token smart contracts. To do so, the code is reviewed 
line-by-line by our smart contract developers, documenting any issues as they are 
discovered. Part of this work includes writing a unit test suite. In summary, our strategies 
consist largely of manual collaboration between multiple team members at each stage of 
the review:
01
Due diligence in assessing the overall 
code quality of the codebase.
03
Testing contract logic against common 
and uncommon attack vectors.
02
Cross-comparison with other, similar 
smart contracts by industry leaders.
04
Thorough, manual review of the 
codebase, line-by-line.


<!-- page 7 -->
There were 0 critical issues found during the audit.
5
RAIL Token Smart Contract Audit
Executive Summary


<!-- page 8 -->
The issue has minimal impact on the 
contract’s ability to operate.
Low
The issue has no impact on the 
contract’s ability to operate.
Informational​
The issue affects the ability of the 
contract to compile or operate in a 
significant way.
High
The issue affects the ability of the 
contract to operate in a way that 
doesn’t significantly hinder its 
behavior.
Medium
The issue affects the contract in such 
a way that funds may be lost, 
allocated incorrectly, or otherwise 
result in a significant loss.
Critical
For ease of navigation, sections are arranged from most critical to least critical. Issues are 
tagged “Resolved” or “Unresolved” depending on whether they have been fixed or 
addressed. Furthermore, the severity of each issue is written as assessed by the risk of 
exploitation or other unexpected or otherwise unsafe behavior:
Structure​ ​and​ ​Organization​ ​of​ ​Document
6
RAIL Token Smart Contract Audit


<!-- page 9 -->
Complete​ ​Analysis
7
RAIL Token Smart Contract Audit
informational
unresolved
Solidity version should be updated.
Best practices for Solidity development and auditors standard checklist requires strict and 
explicit usage of the latest stable version of Solidity.
Recommendation:
Consider updating to “pragma solidity 0.8.11;”.


<!-- page 10 -->
8
RAIL Token Smart Contract Audit
Pass
Access Management Hierarchy
Arithmetic Over/Under Flows
Pass
Rail.sol
Pass
Delegatecall
Pass
Hidden Malicious Code
Pass
Unchecked CALL 
Return Values
Pass
External Contract Referencing
Pass
General Denial Of Service (DOS)
Pass
Pass
Floating Points and Precision
Pass
Pass
Signatures Replay
Pass
Pool Asset Security (backdoors in 
the underlying ERC-20)
Pass
Re-entrancy
Pass
Unexpected Ether 
Pass
Default Public Visibility
Pass
Entropy Illusion (Lack of Randomness)
Pass
Short Address/ Parameter Attack
Pass
Race Conditions / Front Running
Uninitialized Storage Pointers
Pass
Tx.Origin Authentication


<!-- page 11 -->
We are grateful to have been given the opportunity to work with RAIL 
Token.

The statements made in this document should not be interpreted as 
investment or legal advice, nor should its authors be held 
accountable for decisions made based on them.

Zokyo's Security Team recommends that RAIL Token put in place a 
bug bounty program to encourage further analysis of the smart 
contract by third parties.
