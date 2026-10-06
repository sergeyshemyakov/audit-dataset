<!-- page 1 -->
SMART CONTRACT AUDIT
railgun_
April 20th, 2022 | v. 1.0


<!-- page 2 -->
score
98
PASS
Zokyo’s Security Team has concluded
that this smart contract passes
security qualifications to be listed on
digital asset exchanges.
Security Audit Score


<!-- page 3 -->
1
Railgun Smart Contract Audit
This document outlines the overall security of the RAILGUN smart contracts, evaluated by
Zokyo's Blockchain Security team.
Technical​ ​Summary
The scope of this audit was to analyze and document the RAILGUN smart contract 
codebase for quality, security, and correctness.
The testable code is significant for the ensurance of contracts security.
It should be noted that this audit is not an endorsement of the reliability or effectiveness of
the contract, rather limited to an assessment of the logic and implementation. In order to
ensure a security of the contract we at Zokyo recommend that the RAILGUN put in place a 
bug bounty program to encourage further and active analysis of the smart contract.
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
Railgun Smart Contract Audit
3
Auditing Strategy and Techniques Applied
4
Executive Summary
5
Structure​ ​and​ ​Organization​ ​of​ ​Document
6
Complete​ ​Analysis
10
Code​ ​Coverage​ ​and​ ​Test​ ​Results​ ​for​ ​all​ files
Table of Contents


<!-- page 5 -->
The source code of the smart contract was taken from the RAILGUN repository:
https://github.com/railgun-privacy/contract
Audited commit: 62401e1a64b9af968d85b8f5347f1a72cc56862c
Auditing Strategy and Techniques Applied
3
Railgun Smart Contract Audit
Within the scope of this audit Zokyo auditors have reviewed the following contract(s):
Globals.sol
Snark.sol
Commitments.sol
Verifier.sol
Poseidon.sol
RokenBlacklist.sol
RailgunLogic.sol
Throughout the review process, care was taken to ensure that the contract:
Implements and adheres to existing standards appropriately and effectively;
Documentation and code comments match logic and behavior;
Distributes tokens in a manner that matches calculations;
Follows best practices in efficient use of resources, without unnecessary waste;
Uses methods safe from reentrance attacks;
Is not affected by the latest vulnerabilities;
Whether the code meets best practices in code readability, etc.
Zokyo’s Security Team has followed best practices and industry-standard techniques to 
verify the implementation of RAILGUN smart contracts. Ro do so, the code is reviewed line-
by-line by our smart contract developers, documenting any issues as they are discovered. 
Part of this work includes writing a unit test suite. In summary, our strategies consist largely 
of manual collaboration between multiple team members at each stage of the review:
01
Due diligence in assessing the overall
code quality of the codebase.
03
Testing contract logic against common
and uncommon attack vectors.
02
Cross comparison with other, similar
smart contracts by industry leaders.
04
Thorough, manual review of the
codebase, line by line.


<!-- page 6 -->
RAILGUN contributors set of contracts represents functionality for the private balances 
keeping empowered with Merkle trees and snarks verifications.

Audited contracts are well-structured, have very high code quality and are completely
documented. There were no critical issues found. The functionality is sufficiently covered 
with unit-tests, which were also verified by auditors team. Auditors have carefully checked
business logic, access control, verification process, tokens usage and other security factors.
Few issues present in the report are connected to the Solidity best practices and do not
influence contract security.
4
Railgun Smart Contract Audit
Executive Summary


<!-- page 7 -->
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
doesn’t significantly
hinder its behavior.
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
5
Railgun Smart Contract Audit


<!-- page 8 -->
Complete​ ​Analysis
6
Railgun Smart Contract Audit
informational
unresolved
Variables lacks validation.
RailgunLogic.sol: function changeFee().
Percentage fee variables should be verified not to exceed 100%.
Recommendation:
Verify that new fee variables are less than “BASIS_POINTS”.
informational
unresolved
Use enum instead of uint.
Globals.sol: line.
Variables “tokenType” from struct “TokenData”, “withdraw” from struct “BoundParams” are
supposed to be assigned to a restricted range of numbers. To ensure that values of these
variables are not out of bounds, a enum should be used as a set of constants, assigned to
numbers, starting from 0.
Recommendation:
Define enum for each variable instead of using uint8.


<!-- page 9 -->
7
Railgun Smart Contract Audit
Pass
Access Management Hierarchy
Pass
Pass
Arithmetic Over/Under Flows
Pass
Poseidon.sol
Commitments.sol
Globals.sol
Pass
Pass
Delegatecall
Pass
Pass
Hidden Malicious Code
Pass
Pass
Unchecked CALL 
Return Values
Pass
Pass
External Contract Referencing
Pass
Pass
General Denial Of Service (DOS)
Pass
Pass
Floating Points and Precision
Pass
Pass
Signatures Replay
Pass
Pass
Pool Asset Security (backdoors in 
the underlying ERC-20)
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Re-entrancy
Pass
Pass
Unexpected Ether 
Pass
Pass
Default Public Visibility
Pass
Pass
Entropy Illusion (Lack of Randomness)
Pass
Pass
Short Address/Parameter Attack
Pass
Pass
Race Conditions/Front Running
Pass
Pass
Uninitialized Storage Pointers
Pass
Pass
Tx.Origin Authentication


<!-- page 10 -->
8
Railgun Smart Contract Audit
Pass
Access Management Hierarchy
Pass
Pass
Arithmetic Over/Under Flows
Pass
Verifier.sol
Snark.sol
RailgunLogic.sol
Pass
Pass
Delegatecall
Pass
Pass
Hidden Malicious Code
Pass
Pass
Unchecked CALL 
Return Values
Pass
Pass
External Contract Referencing
Pass
Pass
General Denial Of Service (DOS)
Pass
Pass
Floating Points and Precision
Pass
Pass
Signatures Replay
Pass
Pass
Pool Asset Security (backdoors in 
the underlying ERC-20)
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Pass
Re-entrancy
Pass
Pass
Unexpected Ether 
Pass
Pass
Default Public Visibility
Pass
Pass
Entropy Illusion (Lack of Randomness)
Pass
Pass
Short Address/Parameter Attack
Pass
Pass
Race Conditions/Front Running
Pass
Pass
Uninitialized Storage Pointers
Pass
Pass
Tx.Origin Authentication


<!-- page 11 -->
9
Railgun Smart Contract Audit
Pass
Access Management Hierarchy
Arithmetic Over/Under Flows
Pass
TokenBlacklist.sol
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


<!-- page 12 -->
Code​ ​Coverage​ ​and​ ​Test​ ​Results​ ​for​ ​all​ files
As part of our work assisting RAILGUN contributors in verifying the correctness of their 
contract code, our team has checked the complete set of unit tests prepared by the 
RAILGUN contributors.
It needs to be mentioned, that the original code has a significant original coverage with 
testing scenarios provided by the RAILGUN contributors. All of them were also carefully 
checked by the auditors team to be consistent and meaningful.
Tests written by Zokyo Security
10
Railgun Smart Contract Audit
Logic/Commitments
Logic/RailgunLogic
Logic/Snark
Logic/TokenBlacklist
Logic/Verifier
✓ 
✓ 
✓ 
✓ 
✓ 
Should calculate zero values (49ms)
Should calculate empty root
Should hash left/right pairs
Should incrementally insert elements (2957ms)
Should roll over to new tree
✓ 
✓ 
✓ 
✓ 
✓ 
✓ 
✓ 
Should change treasury
Should change fee (49ms)
Should calculate fee (1137ms)
Should calculate token field
Should hash note preimages (232ms)
Should deposit ERC20 (762ms)
Should transfer ERC20 (30167ms)
✓ 
✓ 
✓ 
Should reject invalid proofs (549ms)
Should accept valid proofs (539ms)
Should reject points outside scalar field
✓ 
✓ 
Should add and remove from blacklist (84ms)
Should emit blacklist events (54ms)
✓ 
✓ 
✓ 
✓ 
✓ 
Should set verifying key (68ms)
Should hash bound parameters (92ms)
Should verify dummy proofs (5251ms)
Should verify proofs
Should throw error if circuit artifacts don t exist


<!-- page 13 -->
11
Railgun Smart Contract Audit
Commitments.sol
Snark.sol
Poseidon.sol
Verifier.sol
logic\
RailgunLogic.sol
Globals.sol
TokenBlacklist.so
FILE
All files
92.31
100
100
95
83.66
71.57
100
100
% STMTS
83.66
87.5
66.67
100
50
46.43
32.14
100
100
% BRANCH
46.43
75
100
0
100
88.46
100
100
100
% FUNCS
88.46
92.31
100
100
95
86.5
76.29
100
100
% LINES
86.5
223,228,231
139
... 386,390,396
Uncovered Lines


<!-- page 14 -->
We are grateful to have been given the opportunity to work with 
RAILGUN contributors.

The statements made in this document should not be interpreted as 
investment or legal advice, nor should its authors be held 
accountable for decisions made based on them.

Zokyo's Security Team recommends that RAILGUN contributors put in 
place a bug bounty program to encourage further analysis of the 
smart contract by third parties.
