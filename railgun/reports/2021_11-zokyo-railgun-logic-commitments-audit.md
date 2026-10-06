<!-- page 1 -->
SMART CONTRACT AUDIT
railgun_
Nov 23rd, 2021 | v. 1.0


<!-- page 2 -->
score
100
PASS
Zokyo Security Team has
concluded that this smart contract 
passes security qualifications and 
bear no security or operational risk
Security Audit Score


<!-- page 3 -->
1
RAILGUN Contract Audit
This document outlines the overall security of the RAILGUN smart contracts, evaluated by
Zokyo's Blockchain Security team.
Technical​ ​Summary
The scope of this audit was to analyze and document the RAILGUN smart contract 
codebase for quality, security, and correctness.
The testable code is 98.2%, which is above the industry standard of 95%.
It should be noted that this audit is not an endorsement of the reliability or effectiveness of
the contract, rather limited to an assessment of the logic and implementation. In order to
ensure a secure contract that's able to withstand the Ethereum network's fast-paced and
rapidly changing environment, we at Zokyo recommend that the RAILGUN contributors put 
in place a bug bounty program to encourage further and active analysis of the smart 
contract.
Testable Code
100%
75%
50%
25%
0%
your average
INDUSTRY STANDARD
There were no critical issues found during the audit.
Contract Status
low Risk


<!-- page 4 -->
2
RAILGUN Contract Audit
3
Auditing Strategy and Techniques Applied
5
Executive Summary
6
Structure​ ​and​ ​Organization​ ​of​ ​Document
7
Complete​ ​Analysis
9
Code​ ​Coverage​ ​and​ ​Test​ ​Results​ ​for​ ​all​ files
9
Tests written by RAILGUN contributors
10
Tests written by Zokyo Secured team
Table of Contents


<!-- page 5 -->
Auditing Strategy and Techniques Applied
3
RAILGUN Contract Audit
The Smart contract's source code was taken from the RAILGUN repository:
Repository: https://github.com/Railgun-Privacy/contract/
commit/0418a0f1bf0e58e5b3bab8870112b7648ff20aca
Last commit: 97af307fa1d737d4526323acc3d0ef372c703417
Contracts under the scope:
Commitments;
Globals;
RailgunLogic.
For the logic system:
Â Users can spend all their funds and only their funds, there is no hidden mint or burn in 
the contract.
Â Assuming high volume + a relayer system to pay gas, a user's actions can't be linked to 
them (exception: deposits and withdraws can be linked to the depositing and 
withdrawing addresses respectively).
For governance:
Â Only a DAO vote has the ability to make the governance contract call any function on any 
contract.
Â A DAO vote can delegate the ability to call certain other contracts or functions to another 
address (EOA or Contract).
Â AA DAO vote can remove the ability to call certain other contracts or functions from 
another address (EOA or Contract).
Â Only the governance process can change the deployed code (Proxy pattern).
Additional requirements to check:


<!-- page 6 -->
4
RAILGUN Contract Audit
Throughout the review process, care was taken to ensure that the token contract:
Implements and adheres to existing Token standards appropriately and effectively;
Documentation and code comments match logic and behavior;
Distributes tokens in a manner that matches calculations;
Follows best practices in efficient use of gas, without unnecessary waste;
Uses methods safe from reentrance attacks;
Is not affected by the latest vulnerabilities;
Whether the code meets best practices in code readability, etc.
Zokyo's Security Team has followed best practices and industry-standard techniques to 
verify the implementation of RAILGUN smart contracts. To do so, the code is reviewed line-
by-line by our smart contract developers, documenting any issues as they are discovered. 
Part of this work includes writing a unit test suite using the Truffle testing framework. In 
summary, our strategies consist largely of manual collaboration between multiple team 
members at each stage of the review:
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
The Zokyo team has conducted a security audit of the given codebase. The contracts 
provided for an audit are well written and structured. All the findings within the auditing 
process are presented in this document.

During the auditing process, our auditor's team found 2 issues which were successfully
resolved by the RAILGUN contributors.

Taking into consideration the audit results, we can state that the audited smart contracts are
safe to deploy and bear no security or operational risk for neither contract owner, nor end
user. Hence, the score of the audit is set to 100 to the provided codebase.
5
RAILGUN Contract Audit
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
The issue affects the ability of the 
contract to compile or operate in a 
significant way.
Critical
For ease of navigation, sections are arranged from most critical to least critical. Issues are
tagged “Resolved” or “Unresolved” depending on whether they have been fixed or 
addressed. Furthermore, the severity of each issue is written as assessed by the risk of 
exploitation or other unexpected or otherwise unsafe behavior:
Structure​ ​and​ ​Organization​ ​of​ ​Document
6
RAILGUN Contract Audit


<!-- page 9 -->
Complete​ ​Analysis
7
RAILGUN Contract Audit
Unsafe transfer usage
low
resolved
In contract RailgunLogic.sol in functions 
and 
 is used 
function for transferring fee to the treasury contract. Since transfers have fixed 2,300 gas for
executing it is unsafe to use it with new versions of solidity.
transact() 
generateDeposit()
transfer()
Recommendation:
Consider to use 
 instead of 
.
call()
transfer()
Re-audit:
Fixed. Replaced 
 with 
.
transfer()
call()
Misleading NatSpec comment
informational
resolved
In Commitments.sol contracts for function 
 provided misleading comments in
lines 138-142. In section 
 and 
 descriptions in not valid for the functionality.
insertLeaves()
@notice
@dev
Recommendation:
Consider fixing the comment.


<!-- page 10 -->
8
RAILGUN Contract Audit
Pass
Access Management Hierarchy
Pass
Pass
Arithmetic Over/Under Flows
Pass
Globals
RailgunLogic
Commitments
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
Code​ ​Coverage​ ​and​ ​Test​ ​Results​ ​for​ ​all​ files
The resulting code coverage (i.e., the ratio of tests-to-code) is as follows:
Tests are written by the RAILGUN contributors
Code Coverage
Test Results
9
RAILGUN Contract Audit
Commitments.sol
RailgunLogic.sol
logic\
Globals.sol
FILE
All files
94.59
97.30
96.40
100
% STMTS
96.40
100
56.23
61.11
100
% BRANCH
61.11
75
100
88.89
100
% FUNCS
88.89
92.11
100
97.30
100
% LINES
97.30
245, 250, 253
Uncovered Lines
Logic/Commitments
Logic/RailgunLogic
13 passing (9m)
✓ 
✓ 
Should initialize the tree correctly
Should update the tree correctly (60203ms)
✓ 
✓ 
✓ 
✓ 
✓ 
✓ 
✓ 
✓ 
✓ 
✓ 
Should verify proofs (19092ms)
Should deposit token correctly (19962ms)
Should collect treasury fees correctly (44755ms)
Should deposit with 2 outputs correctly (22064ms)
Should deposit with 3 outputs correctly (22560ms)
Should deposit, do an internal transaction, and withdraw (66361ms)
Should transact with large circuit (125395ms)
Should deposit and generate commitments correctly (935ms)
Should be able to spend from generated commitment (23790ms)
Should do batch transactions(67603ms)


<!-- page 12 -->
The resulting code coverage (i.e., the ratio of tests-to-code) is as follows:
Tests written by Zokyo Security team
Code Coverage
Test Results
10
RAILGUN Contract Audit
Commitments.sol
RailgunLogic.sol
logic\
Globals.sol
FILE
All files
100
97.63
98.20
100
% STMTS
98.20
100
77.08
79.63
100
% BRANCH
79.63
100
100
100
100
% FUNCS
100
100
100
100
100
% LINES
100
Uncovered Lines
Contract: Commitments
Contract: RailgunLogic
✓ 
✓ 
✓ 
should initialize merkle tree correct (48ms)
should update the tree correctly (1156ms)
should create a new tree correct (93ms)
✓ 
✓ 
✓ 
✓ 
✓ 
✓ 
✓ 
✓ 
✓ 
✓ 
Should initialize railgun logic correct (144ms)
Should change treasury correct (211ms)
Should revert change treasury by not owner(92ms)
Should change fee correct (117ms)
Should revert change fee by not owner
Should verify proofs (19469ms)
Should deposit whitelisted token correct (20339ms)
Should deposit and withdraw whitelisted token correct (47679ms)
Should revert deposit when adaptID address is incorrect (21244ms)
Should revert deposit when the merkle root is incorrect(21037ms)
As part of our work assisting RAILGUN in verifying the correctness of their contract code, 
our team was responsible for writing integration tests using the Truffle testing framework.
Tests were based on the functionality of the code, as well as a review of the RAILGUN 
contract requirements for details about issuance amounts and how the system handles 
these.


<!-- page 13 -->
11
RAILGUN Contract Audit
19 passing (4m)
✓ 
✓ 
✓ 
✓ 
✓ 
✓ 
Should revert deposit not whitelisted token (21518ms)
Should collect treasury fees correctly (46725ms)
Should generateDeposit and withdraw token from the generated commitments(24076ms)
Should revert generateDeposit if fee not paid (77ms)
Should revert generateDeposit if deposited amount is zero
Should revert generateDeposit if deposit not whitelisted token (89ms)


<!-- page 14 -->
We are grateful to have been given the opportunity to work with the 
RAILGUN contributors.

The statements made in this document should not be interpreted as 
investment or legal advice, nor should its authors be held 
accountable for decisions made based on them.

Zokyo's Security Team recommends that the RAILGUN contributors 
put in place a bug bounty program to encourage further analysis of the 
smart contract by third parties.
