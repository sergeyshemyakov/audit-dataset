<!-- page 1 -->
SMART CONTRACT AUDIT
railgun
September 14th, 2022 | v. 1.0


<!-- page 2 -->
score
99
PASS
Zokyo’s Security Team has concluded 
that this smart contract passes 
security qualifications to be listed on 
digital asset exchanges.
Security Audit Score


<!-- page 3 -->
1
RAILGUN Smart Contract Audit
This document outlines the overall security of the RAILGUN smart contracts, evaluated by 
Zokyo's Blockchain Security team.
Technical​ ​Summary
The scope of this audit was to analyze and document the RAILGUN smart contract 
codebase for quality, security, and correctness.
There was 0 critical issue found during the audit.  (See Complete Analysis)
Contract Status
low Risk
The testable code is 100%, which is above the industry standard of 95%. (See Complete 
Analysis)
It should be noted that this audit is not an endorsement of the reliability or effectiveness of 
the contract, rather limited to an assessment of the logic and implementation. In order to 
ensure a secure contract that’s able to withstand the Ethereum network’s fast-paced and 
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


<!-- page 4 -->
2
RAILGUN Smart Contract Audit
3
Auditing Strategy and Techniques Applied
4
Executive Summary
5
Structure​ ​and​ ​Organization​ ​of​ ​Document
6
Complete​ ​Analysis
11
Code​ ​Coverage​ ​and​ ​Test​ ​Results​ ​for​ ​all​ files written by the RAILGUN contributors
12
Code​ ​Coverage​ ​and​ ​Test​ ​Results​ ​for​ ​all​ files written by Zokyo Secured team
Table of Contents


<!-- page 5 -->
Zokyo’s Security Team has followed best practices and industry-standard techniques to 
verify the implementation of RAILGUN smart contract. To do so, the code is reviewed line-
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
Thorough manual review of the 
codebase, line by line.
Throughout the review process, Zokyo Security ensures that the contract:
Implements and adheres to existing Token standards appropriately and effectively;
Documentation and code comments match logic and behavior;
Distributes tokens in a manner that matches calculations;
Follows best practices inefficient use of gas, without unnecessary waste;
Uses methods safe from reentrance attacks;
Is not affected by the latest vulnerabilities;
Whether the code meets best practices in code readability, etc.
Contract under the scope:
Voting.sol
The Smart contract’s source code was taken from the RAILGUN repository:
Repository:  https://github.com/Railgun-Privacy/contract
Last commit: d73c1da62c624fe083417342ce3e64748572bde9
Auditing Strategy and Techniques Applied
3
RAILGUN Smart Contract Audit


<!-- page 6 -->
Zokyo auditing team has run a deep investigation of RAILGUN’s smart contract. The contract 
is in good condition, well written and structured.
During the auditing process, there were some issues with low severity and informational 
issues found. After the technical review of fixes from RAILGUN contributors, we can state 
issues are resolved and acknowledged in the doc accordingly.
Based on the conducted audit, we give a score of 99 to the aforementioned contract.
Executive Summary
4
RAILGUN Smart Contract Audit


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
addressed. Acknowledged means that the issue was sent to the client team and the client 
team are aware of it, but they have chosen to not solved it. Furthermore, the severity of each 
issue is written as assessed by the risk of exploitation or other unexpected or otherwise 
unsafe behavior:
Structure​ ​and​ ​Organization​ ​of​ ​Document
5
RAILGUN Smart Contract Audit


<!-- page 8 -->
Complete​ ​Analysis
6
RAILGUN Smart Contract Audit
low
resolved
The solidity pragma version is not locked for both Voting.sol and Delegator.sol which is 
imported in the Voting.sol contract, in the hardhat config file right now the version selected 
is 0.8.12, but by having a pragma version that is not locked this can be prone to errors, an 
example of such an error is that in the moment the contracts get compiled with a version 
lower then 0.8.7, there will be a compilation error because of conversion from bytes to 
bytes4 at line 102 in Delegator.sol
Recommendation:
Lock the pragma version to 0.8.12
low
Acknowledged
In contract Voting.sol,  there are two for loops functions, one at line 207 and one at line 408, 
it is recommended that inside the loop functions to implement a break condition that will 
check the gasLeft() and will break the function iteration if the gas is lesser then 20 000 units 
to not run into the out of gas error, in the case of an “out of gas error”, the gas it is not 
returned but in a case of reverting from an require or revert function or from  execution 
breaking the gas it is returned.
Recommendation:
Implement a check inside the loops that will check for the gas left and will intrerupt the 
execution of the function using the break keyword to not be able to run in the “out of gas 
error” 


<!-- page 9 -->
7
RAILGUN Smart Contract Audit
informational
Acknowledged
In contract Voting.sol, at line 102, variable STAKING_CONTRACT is of type Staking, and the 
variable it is used inside the contract to do external calls to a certain address at lines 204, 
250, 320, 352. To better optimize the gas usage, it is recommended that 
STAKING_CONTACT to be of type address, and do an in-place initialization using an 
interface where you want to do an external call, this will greatly reduce the gas costs, 
because you will only read from the storage the address instead of an object of type Staking 
which is greatly more expensive.
Recommendation:
Change the type of STAKING_CONTRACT to address  and do an in-place initialization using 
the interface where you are doing external calls at lines 204, 250, 320 and 352.
informational
Acknowledged
In contract Voting.sol, at line 103, variable DELEGATOR_CONTRACT is of type Delegator, and 
the variable it is used inside the contract to do external calls to a certain address at line 407 
inside a for loop. To better optimize the gas usage, it is recommended that 
DELEGATOR_CONTRACT to be of type address, and do an in-place initialization using an 
interface where you want to do an external call, this will greatly reduce the gas costs, 
because you will only read from the storage the address instead of an object of type Staking 
which is greatly more expensive.
Recommendation:
Change the type of DELEGATOR_CONTRACT to address  and do an in-place initialization 
using the interface at line 407


<!-- page 10 -->
8
RAILGUN Smart Contract Audit
informational
resolved
In contract Voting.sol, at line 60, the struct ProposalStruct it is defined, to be in accordance 
with best practices and to optimize the gas usage it would be recommended to implement 
variable packing inside structures definitions. 
Recommendation:
Refactor the structure so it will be in accordance with the variable packing patter.
informational
Acknowledged
In contract Voting.sol, at line 207, there is a for loop that could be better optimized by 
changing the i++ inside the for loop to an unchecked arithmetic because the i variable is of 
type uint256, and you will run out of gas before being able to iterate enough for an overflow
Recommendation:
Change the structure of the i++ instruction to an unchecked one to better optimize the gas. 


<!-- page 11 -->
9
RAILGUN Smart Contract Audit
informational
Acknowledged
In contract Voting.sol, at line 408, there is a for loop that could be better optimized by 
changing the i++ inside the for loop to an unchecked arithemthic because the i variable is of 
type uint256 and you will run out of gas before being able to iterate enough for an overflow.
Recommendation:
Change the structure of the i++ instruction to an unchecked one to better optimize the gas. 
(Note: this img also represents multiple changes from recommendations about this lines of 
code that are place in the document above for better gas optimization)
informational
resolved
In contract Voting.sol, at line 405, there is a for loop that could be better optimized by 
changing the the variable actions from storage to an in memory variable, because the gets 
used in the for loop and at every use the value will be read again from the storage, which 
can become expensive after a lot of operations. 
Recommendation:
Change the variable actions form in storage to an in memory variable. (The modification can 
be observed in the image from above)


<!-- page 12 -->
10
RAILGUN Smart Contract Audit
Access Management Hierarchy
Arithmetic Over/Under Flows
Voting.sol
Delegatecall
Hidden Malicious Code
Unchecked CALL 
Return Values
External Contract Referencing
General Denial Of Service (DOS)
Floating Points and Precision
Signatures Replay
Pool Asset Security (backdoors in 
the underlying ERC-20)
Pass
Re-entrancy
Unexpected Ether 
Default Public Visibility
Entropy Illusion (Lack of Randomness)
Short Address/Parameter Attack
Race Conditions/Front Running
Uninitialized Storage Pointers
Tx.Origin Authentication
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


<!-- page 13 -->
Tests are written by the RAILGUN contributors
Code Coverage
Code​ ​Coverage​ ​and​ ​Test​ ​Results​ ​for​ ​all​ files
11
RAILGUN Smart Contract Audit
The resulting code coverage (i.e., the ratio of tests-to-code) is as follows:
Governance/Voting
✓Should go through vote lifecycle correctly (1090ms)
✓Should not be able to sponsor after the sponsor window (85ms)
✓Should not not execute failed proposal (265ms)
✓Should execute proposals correctly (240ms)
✓Should only be able to sponsor once per week (189ms)
✓Should only allow voting key to call (134ms)
6 passing (7s)
voting.sol
governance/
92.31
83.87
69.23
93.15
... 155,167,415
92.31
83.87
69.23
93.15
FILE
% STMTS
% BRANCH
% FUNCS
% LINES
% UNCOVERED
          LINES     
All files
92.31
93.15
83.87 
69.23
voting.sol
governance/
92.31
83.87
69.23
93.15
... 155,167,415
92.31
83.87
69.23
93.15
FILE
% STMTS
% BRANCH
% FUNCS
% LINES
% UNCOVERED
          LINES     
All files
92.31
93.15
83.87 
69.23


<!-- page 14 -->
As part of our work assisting RAILGUN DAO Project contributors in verifying the correctness 
of their contract code, our team was responsible for writing integration tests using the 
Truffle testing framework. 
Tests were based on the functionality of the code, as well as a review of the RAILGUN 
contract requirements for details about issuance amounts and how the system handles these. 
Tests are written by Zokyo Secured team
Code​ ​Coverage​ ​and​ ​Test​ ​Results​ ​for​ ​all​ files
12
RAILGUN Smart Contract Audit
  Voting
✓Should be deployed correctly (134ms)
✓Should be able to create a proposal (482ms)
✓Should be able to get number of proposals (180ms)
✓Should be able to get actions in a proposal (182ms)
✓Should allow voting key to be set (518ms)
✓Should allow sponsorship of proposals (744ms)
✓Should be able to get sponsored amount given by account (179ms)
✓Should allow proposals to be unsponsored (498ms)
✓Should allow votes to be called (429ms)
✓Should allow nay votes on proposal (639ms)
✓Should allow yes votes on proposals (359ms)
✓Should be able to get number of votes cast by voter (388ms)
✓Should allow proposals to be executed (828ms)
✓Should not  allow proposals to be executed with wrong variables (882ms)
14 passing (13s)
Code Coverage
The resulting code coverage (i.e., the ratio of tests-to-code) is as follows: 
Voting.sol
governance/
100
100
100
100
100
100
100
100
FILE
% STMTS
% BRANCH
% FUNCS
% LINES
% UNCOVERED
          LINES     
All files
100
100
100 
100


<!-- page 15 -->
We are grateful to have been given the opportunity to work with the 
RAILGUN DAO Project contributors.

The statements made in this document should not be interpreted as 
an investment or legal advice, nor should its authors be held 
accountable for the decisions made based on them.

Zokyo's Security Team recommends that the RAILGUN DAO Project  
contributors put in place a bug bounty program to encourage further 
analysis of the smart contract by third parties.
