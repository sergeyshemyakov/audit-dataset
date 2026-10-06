<!-- page 1 -->
SMART CONTRACT AUDIT
railgun_
Nov 3th, 2021 | v. 1.0


<!-- page 2 -->
score
99
PASS
Zokyo’s Security Team has concluded 
that this smart contract passes 
security qualifications to be listed on 
digital asset exchanges
Security Audit Score


<!-- page 3 -->
1
RAILGUN Contract Audit
This document outlines the overall security of the RAILGUN smart contracts, evaluated by 
Zokyo's Blockchain Security team.
Technical​ ​Summary
The scope of this audit was to analyze and document the RAILGUN smart contract 
codebase for quality, security, and correctness.
The testable code is 99.26%, which is above the industry standard of 95%.
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
Summary
6
Structure​ ​and​ ​Organization​ ​of​ ​Document
7
Complete​ ​Analysis
9
Code​ ​Coverage​ ​and​ ​Test​ ​Results​ ​for​ ​all​ files
9
Tests written by RAILGUN contributors
13
Tests written by Zokyo Secured team
Table of Contents


<!-- page 5 -->
Auditing Strategy and Techniques Applied
3
RAILGUN Contract Audit
The Smart contract's source code was taken from the RAILGUN repository.
Repository: https://github.com/Railgun-Privacy/contract/commit/ 
d2c63577ddd8310c87dced0d549cf9505b372111
Contracts under the scope:
Delegator;
Voting;
Poseidon;
ProxyAdmin;
Deployer;
Commitments;
RailgunLogic;
Distributor;
TokenWhitelist;
VestLock;
Staking;
Globals;
Proxy;
Snark;
Multisend;
Verifier;
Treasury.


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
and uncommon attack vectors
02
Cross-comparison with other, similar 
smart contracts by industry leaders.
04
Thorough, manual review of the 
codebase, line-by-line.


<!-- page 7 -->
The Zokyo team has conducted a security audit of the given codebase. The contracts 
provided for an audit are well written and structured. All the findings spotted within the 
auditing process are presented in this document.
There were no critical issues found during the auditing process. Just a couple of 
informational issues and one issue with a low severity level were found. All the issues are left 
unresolved as the contracts are already deployed on the mainnet. However, it is worth 
mentioning that all of the mentioned issues have no major security or operational risk.
Based on the audit result we can give a score of 99 to the provided codebase.
5
RAILGUN Contract Audit
Summary


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
Token receiver address defined as payable
low
UNresolved
In the treasury contract function 
 you declared the address of the tokens 
receiver as payable. Addresses declared payable can receive ether.
transferERC20()
Recommendation:
Remove payable for a token receiver.
Misleading comment at Treasury.sol
informational
UNresolved
In the treasury contract function 
 is used for transferring tokens.
transferERC20()
Recommendation:
Change comment in the notice from 
 to 
.
“Transfers ETH to specified address”
“Transfers 
ERC20 token to specified address”
Misleading comment at VestLock.sol
informational
UNresolved
In the VestLock contract function 
 is used for transferring tokens.
transferERC20()
Recommendation:
Change comment in the notice from 
 to 
.
“Transfers ETH to specified address”
“Transfers 
ERC20 token to specified address”


<!-- page 10 -->
8
RAILGUN Contract Audit
Typo at TokenWhitelist.sol
informational
UNresolved
In the TokenWhitelist event, 
 is misspelled.
TokeDelisting
Recommendation:
Change event to 
 at line 22 and line 78.
TokenDelisting


<!-- page 11 -->
Code​ ​Coverage​ ​and​ ​Test​ ​Results​ ​for​ ​all​ files
The resulting code coverage (i.e., the ratio of tests-to-code) is as follows:
Tests are written by the RAILGUN contributors
Code Coverage
9
RAILGUN Contract Audit
All files
93.72
70.10
82.83
94.13
Delegator.sol
Globals.sol
Staking.sol
RailgunLogic.sol
Distributor.sol
proxy\
Treasury.sol
ProxyAdmin.sol
logic\
TokenWhitelist.sol
VestLock.sol
contracts\
Commitments.sol
Deployer.sol
Poseidon.sol
token\
Verifier.sol
treasury
Voting.sol
Snark.sol
Multisend.sol
Proxy.sol
55.56
97.93
91.30
88.94
100.00
94.06
93.85
100.00
100.00
100.00
100.00
99.34
80.00
94.74
100.00
100.00
91.67
100.00
100.00
96.97
83.33
84.00
42.86
82.14
77.97
100.00
83.33
100.00
100.00
57.89
50.00
50.00
64.29
64.29
100.00
100.00
100.00
100.00
100.00
100.00
100.00
62.50
57.14
62.50
100.00
72.73
70.00
83.33
100.00
100.00
100.00
100.00
100.00
80.00
100.00
100.00
77.78
75.00
75.00
85.71
83.33
82.76
0.00
89.66
77.50
100.00
60.00
98.63
100.00
93.94
100.00
100.00
99.33
80.00
95.00
100.00
100.00
92.31
100.00
100.00
82.35
82.76
89.29
92.42
100.00
100.00
93.48
100.00
...117, 120, 123
352
230, 235, 238
...127, 351, 353
...185, 195, 285
29
98
FILE
% STMTS
% BRANCH
% FUNCS
% LINES
Uncovered Lines


<!-- page 12 -->
10
RAILGUN Contract Audit
Test Results
Logic/Whitelist
Logic/Commitments
Proxy/Proxy
Proxy/Proxy
Logic/RailgunLogic
✓ 
✓ 
✓ 
Should initialize whitelist with passed values 
Should add an address to whitelist 
Should remove address from whitelist
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
Should verify proofs 
Should deposit token correctly 
Should collect treasury fees correctly
Should deposit with 2 outputs correctly 
Should deposit with 3 outputs correctly 
Should deposit and withdraw
Should deposit, do an internal transaction, and withdraw 
Should transact with large circuit 
Should deposit and generate commitments correctly
Should be able to spend from generated commitment
✓Should update the tree correctly
✓Should generate commitment correctly
(132ms)
✓Should initialize the tree correctly (57ms)
✓Should deploy as paused (126ms)
✓Should upgrade and unpause (135ms)
✓Should unpause and pause again (208ms)
✓Should upgrade and unpause (210ms)
✓Should upgrade unpause and upgrade again (325ms)
✓Shouldn't allow unpausing unless the implementation is set
✓Should unpause and pause again (229ms)
✓Should upgrade unpause and upgrade again (319ms)
(2060ms)
(20691ms)
(20771ms)
(47217ms)
(24052ms)
(24024ms)
(46906ms)
(69847ms)
(130299ms)
(1051ms)
(24743ms)
(835ms)
(129ms)
(117ms)


<!-- page 13 -->
11
RAILGUN Contract Audit
(8m)
Treasury/Treasury
Governance/Delegator
Governance/Staking
Governance/Voting
42 passing
Token/Vesting
Token/Multisend
Governance/Deployer
✓Should transfer ETH (63ms)
✓Should set permissions (57ms)
✓Should count intervals properly (38ms)
✓Should go through vote lifecycle correctly (754ms)
✓Should set up vesting (475ms)
✓Should multisend (1599ms)
✓Should deploy contracts at expected address (104ms)
✓Should transfer ERC20 (130ms)
✓Should be able to call a function with permission (80ms)
✓Should return correct snapshot regardless of hint (14317ms)
✓Should not be able to sponsor after the sponsor window (54ms)
✓Should be able to call the function with wildcard function permission (94ms)
✓Should delegate and snapshot correctly (379ms)
✓Should execute proposals correctly (193ms)
✓Should be able to call the function with wildcard contract permission (64ms)
✓Should go through stake lifecycle correctly (330ms)
✓Should not execute failed proposal (177ms)
✓Should intercept calls to self correctly (70ms)


<!-- page 14 -->
Code​ ​Coverage​ ​and​ ​Test​ ​Results​ ​for​ ​all​ files
As part of our work assisting RAILGUN in verifying the correctness of their contract code, 
our team was responsible for writing integration tests using the Truffle testing framework.
Tests were based on the functionality of the code, as well as a review of the RAILGUN contract 
requirements for details about issuance amounts and how the system handles these.
The resulting code coverage (i.e., the ratio of tests-to-code) is as follows:
Tests written by Zokyo Security team
Code Coverage
12
RAILGUN Contract Audit
Delegator.sol
Globals.sol
Staking.sol
RailgunLogic.sol
Distributor.sol
proxy\
ProxyAdmin.sol
logic\
TokenWhitelist.sol
contracts\
Commitments.sol
Deployer.sol
Poseidon.sol
token\
Verifier.sol
Voting.sol
Snark.sol
Multisend.sol
Proxy.sol
100.00
98.97
95.65
100.00
100.00
100.00
100.00
100.00
100.00
100.00
100.00
100.00
100.00
100.00
100.00
100.00
96.97
96.97
96.00
100.00
92.86
96.61
100.00
100.00
100.00
100.00
84.21
50.00
100.00
100.00
100.00
100.00
100.00
100.00
100.00
75.00
77.14
75.00
100.00
100.00
100.00
100.00
100.00
100.00
100.00
100.00
100.00
100.00
100.00
100.00
92.86
91.67
88.89
0.00
93.10
100.00
100.00
100.00
100.00
100.00
100.00
100.00
100.00
100.00
100.00
100.00
100.00
100.00
94.12
93.10
100.00
100.00
100.00
100.00
100.00
100.00
101, 108
FILE
% STMTS
% BRANCH
% FUNCS
% LINES
Uncovered Lines


<!-- page 15 -->
13
RAILGUN Contract Audit
All files
99.26
90.20
94.95
99.63
Treasury.sol
VestLock.sol
treasury
100.00
100.00
100.00
100.00
100.00
100.00
88.89
75.00
75.00
100.00
100.00
100.00
Test Results
Delegator contract
Deployer contract
Staking contract
✓ 
✓ 
✓ 
✓ 
 
✓ 
✓ 
✓ 
✓ 
 
✓ 
Should initialize owner correct
Should set permission correct 
Should revoke permission correct 
Should call the function with permission
Should revert call function if not has permission 
Should set permission by call contract function correct 
Should transfer ownership by call contract function correct
Should renounce ownership by call contract function correct
Should intercept calls to self correctly
✓Should initialize owner correct
✓Should return initial total voting power in system correct
✓Shouldn't stake zero amount
✓Shouldn't unlock twice
✓Should deploy correctly
✓Should stake correct
✓Should unlock correct
(70ms)
(135ms)
(78ms)
(127ms)
(89ms)
(50ms)
(59ms)
(92ms)
(186ms)
(286ms)


<!-- page 16 -->
14
RAILGUN Contract Audit
Voting contract
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
  ✓ 
  ✓ 
  ✓ 
  ✓ 
  ✓ 
  ✓ 
Should claim correct
 Shouldn't claim twice
Should delegate correct
Shouldn't delegate after unlock
Shouldn't delegate to zero address
Should undelegated correct
Should return stakesLength correct

Should fail intervalAtTime when the requested time is below the deploy time value
Should return latestGlobalsSnapshotInterval correct
Should return latestAccountSnapshotInterval correct 
Should return accountSnapshotLength correct
Should return globalsSnapshotLength correct 
Should return accountSnapshot correct 
Should return globalsSnapshot correct 
Should return globalsSnapshotAt correct
Should return accountSnapshotAt correct
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
✓ 
✓ 
✓
✓
✓
✓
✓
✓
✓
Should initial proposalsLength be correct 
Should getActions correct
Should getSponsored correct 
Should createProposal correct 
 Should revert createProposal with no actions
Should sponsorProposal correct 
Should revert sponsorProposal when the proposal went to vote 
Should revert sponsorProposal when sponsor window passed 
Should revert sponsorProposal when not enough voting power 
Should unsponsorProposal correct 
Should revert unsponsorProposal when the proposal went to vote
Should revert unsponsorProposal when sponsor window passed
 Should revert unsponsorProposal when request more than sponsored 
 Should callVote correct 
 Should revert callVote when the proposal went to vote 
 Should revert callVote when sponsor window passed 
 Should revert callVote when not met sponsorship threshold 
 Should vote for correct 
 Should vote against correct
(172ms)
(178ms)
(259ms)
(158ms)
(112ms)
(237ms)
(371ms)
(4022ms)
(4312ms)
(60ms)
(136ms)
(85ms)
(123ms)
(157ms)
(46ms)
(112ms)
(134ms)
(201ms)
(90ms)
(93ms)
(161ms)
(217ms)
(45ms)
(90ms)
(233ms)
(206ms)
snapshot


<!-- page 17 -->
15
RAILGUN Contract Audit
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
✓
✓
✓
 Should revert vote if the voting window was not opened
 Should revert vote if call vote was not called for the proposal
 Should revert vote against if yay window was closed 
 Should revert vote for if nay window was closed 
 Should revert vote if there is not enough voting power 
 Should executeProposal correct 
 Should revert execute proposal if call vote was not called for the proposal 
 Should revert executeProposal if a quorum hasn't been reached 
 Should revert executeProposal if the proposal hasn't been passed 
 Should revert executeProposal if execution window hasn't been started 
 Should revert executeProposal if execution window has been closed 
 Should revert executeProposal if a proposal has already been executed 
 Should revert executeProposal if proposal action is reverted
Should initialize railgun logic correct 
Should change treasury correct 
Should revert change treasury by not owner 
Should change fee correct 
Should revert change fee by not owner 
Should verify proofs 
Should deposit whitelisted token correct 
Should deposit and withdraw whitelisted token correct 
Should revert deposit when adaptID address is incorrect token correct 
Should revert deposit when the merkle root is incorrect 
Should revert deposit not whitelisted token 
Should collect treasury fees correctly 
Should generateDeposit and withdraw token from the generated commitments 
Should revert generateDeposit if fee not paid 
Should revert generateDeposit if deposited amount is zero 
Should revert generateDeposit if deposit not whitelisted token
(161ms)
(69ms)
(151ms)
(217ms)
(125ms)
(21943ms)
(21641ms)
(49991ms)
(22057ms)
(21974ms)
(22395ms)
(49711ms)
(25316ms)
(81ms)
(54ms)
(91ms)
(212ms)
(181ms)
(166ms)
(291ms)
(145ms)
(219ms)
(220ms)
(222ms)
(267ms)
(297ms)
(287ms)
Commitments contract
Commitments contract
✓should initialize merkle tree correct
✓should revert adding a new commitment if the leaf is invalid
✓should create a new tree correct
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
✓
✓
✓
✓
✓
✓
✓should update the tree correctly
✓should add new generated commitment correctly


<!-- page 18 -->
16
RAILGUN Contract Audit
TokenWhitelist contract
TokenWhitelist contract
TokenWhitelist contract
ProxyAdmin contract
Distributor contract
Multisend contract
✓should initialize correctly
✓should revert add whitelisted token if caller, not the owner
✓should revert remove whitelisted token if caller, not owner
✓should add whitelisted token correct (159ms)
✓should verifyProof correct (22972ms)
✓should verifyProof with 10 nullifiers correct (41842ms)
✓should revert verifyProof with incorrect nullifier
✓Should upgrade and emit event correct (186ms)
✓Should not set new implementation as non-contract address (45ms)
✓Should pause and emit event correct (221ms)
✓Should unpause and emit event correct (234ms)
✓Should revert unpause before implementation is set
✓Should transfer ownership correct
✓Should revert transfer ownership by not the owner (237ms)
✓Should upgrade correct (81ms)
✓Should pause and emit event correct (157ms)
✓Should unpause and emit event correct (187ms)
✓Should transfer ownership correct
✓Should initialize vesting implementation correct
✓Should create vest lock correct (79ms)
✓Should not create vest lock by not the owner (62ms)
✓Should multisend correct to one address (76ms)
✓Should multisend correct to multiple addresses (106ms)
✓should remove whitelisted token correct (179ms)


<!-- page 19 -->
16
RAILGUN Contract Audit
VestLock contract
Treasury contract
✓Should initialize owner correct
✓Should initialize release time correct
✓Should delegate correct (204ms)
✓Should stake correct (134ms)
✓Should unlock correct (115ms)
✓Should claim correct (248ms)
✓Should receive ETH correct (45ms)
✓Should transferETH correct (78ms)
✓Shouldn't transferETH while not achieved release time
✓Should transferERC20 correct (45ms)
✓Shouldn't transferERC20 while not achieved release time
✓Should initialize owner correct
✓Should transfer ETH (58ms)
✓Should revert transfer ETH if caller, not owner
✓Should transfer ERC20 (173ms)
✓Should revert transfer ERC20 if caller, not owner (137ms)
(7m)
125 passing


<!-- page 20 -->
We are grateful to have been given the opportunity to work with the 
RAILGUN contributors.

The statements made in this document should not be interpreted as 
investment or legal advice, nor should its authors be held 
accountable for decisions made based on them.

Zokyo's Security Team recommends that the RAILGUN contributors 
put in place a bug bounty program to encourage further analysis of the 
smart contract by third parties.
