# **Ronin Bridge**

## Security Analysis Audit No. 202408211552

### Aug 21 st, 2024

**SECURING BLOCKCHAIN ECOSYSTEM**


**WWW.BEOSIN.COM**


**Ronin Bridge Security Audit**

```

### **Contents**


**1 Overview** **........................................................................................................................................................... 7**


1.1 Project Overview .................................................................................................................................... 7


1.2 Audit Overview .......................................................................................................................................7


1.3 Audit Method ..........................................................................................................................................7


**2 Script Audit......................................................................................................................................... 9**


2.1 20240716-p3 script code logic analysis.......................................................................................9


2.2 Check for uninitialized parameters on the chain........................................................................11


2.3 20240807-ir-recover script code logic analysis........................................................................12


2.4. Test the 20240807-ir-recover script....................................................................................... 13


**3 Contract Audit....................................................................................................................................15**


2.1 Proposal Security...................................................................................................................... 15


[Ronin-01] Propose Function.................................................................................................. 15


[Ronin-02] CastVote Function................................................................................................ 16


[Ronin-03] Execute Function..................................................................................................18


[Ronin-04] DeleteExpired Function........................................................................................ 19


[Ronin-05] RelayProposal Function....................................................................................... 20


2.2 Cross-chain Bridge Security.................................................................................................... 23


[Ronin-06] RequestWithdrawal Function...............................................................................23


[Ronin-07] DepositFor Function............................................................................................ 24


[Ronin-08] SubmitWithdrawal Function.................................................................................26


[Ronin-09] UnlockWithdrawal Function................................................................................. 28


Page 2 of 38


**Ronin Bridge Security Audit**

```


[Ronin-10] RequestDepositFor Function................................................................................29


**4 Appendix............................................................................................................................................31**


4.1 Vulnerability Assessment Metrics and Status in Smart Contracts............................................. 31


4.2 Audit Categories...................................................................................................................... 34


4.3 Disclaimer ............................................................................................................................................36


4.4 About Beosin .......................................................................................................................................37


Page 3 of 38


**Ronin Bridge Security Audit**

```

#### **Summary of Audit Result**


The audit was divided into three parts: the first part focused on the contract audit, the second part on


the audit of the scripts that led to the attack, and the third part on the audit of the scripts intended to


fix the vulnerabilities.


In the contract audit, no major issues were found. During the audit of the


20240716-p3-upgrade-bridge-main-chain.s.sol and 20240716-p2-upgrade-bridge-ronin-chain.s.sol


scripts, the previous attack was analyzed, and potential parameter initialization issues were checked


to ensure that all parameters of the cross-chain bridge were properly initialized. It was confirmed that


only the weight parameters were not initialized.


In the third part, the 20240807-ir-recover script was reviewed, and the entire proposal execution


process was analyzed. Based on the code logic, the process to be feasible. Ultimately, the


20240807-ir-recover script passed the tests.


Page 4 of 38


**Ronin Bridge Security Audit**

```


 **Project Description:**


**1.** **Business overview**


This audit is a contract security audit of Ronin Bridge and a security audit of deployment scripts and


transactions. The audited contracts include: RoninBridgeManager, RoninGatewayV3,


MainchainBridgeManager and MainchainGatewayV3.


The RoninBridgeManager contract is the governance management contract on the Ronin chain,


responsible for creating, voting on, and executing cross-chain bridge proposals. When a proposal is


initiated by a governor, a proposal with an expiration time is created in the current round. Before the


expiration time is reached, governors with voting weight can vote on the proposal in the current round.


If the proposal's weight reaches the preset threshold before expiration, execution is determined based


on the proposal's chain ID. If the chain ID is the Ronin chain itself, the proposal will be executed by the


predefined executor within the proposal, which calls the predefined target contract’s calldata via the


BridgeManager contract. If the chain ID is Ethereum, the proposal will be suspended. Later, the


governor on Ethereum will collect the signatures within the proposal and call functions like


<u><mark>relayProposal</mark></u> in the MainchainBridgeManager contract on Ethereum to generate and create the


Ethereum proposal. Since the weight has already been verified on the Ronin chain, this transaction will


also pass the current proposal, thereby executing the data within the calldata. The


MainchainBridgeManager contract is the governance management contract on Ethereum. Since the


contract does not have a voting function, it can only process proposals that have already been signed


on the Ronin chain and passed the weight check.


The RoninGatewayV3 and MainchainGatewayV3 contracts are cross-chain bridge contracts on the


Ronin chain and Ethereum, respectively, responsible for the generation, receipt, and voting of


cross-chain Receipts. If a user wants to perform a cross-chain operation from the Ronin chain, they


can first use the <u><mark>requestWithdrawalFor</mark></u> function in the RoninGatewayV3 contract to generate a


Receipt of the kind Withdrawal, staking the corresponding tokens to the cross-chain bridge to create


the cross-chain Receipt. The user can then validate the Receipt's weight using the collected operator


signatures. Once the Receipt's weight is sufficient, the cross-chain bridge will send the corresponding


amount of tokens to the user recorded in the Receipt, thereby completing the cross-chain operation. A


similar process applies when a user wants to perform a cross-chain operation from Ethereum; they


can use the <u><mark>requestDepositFor</mark></u> function in the MainchainGatewayV3 contract to generate a Receipt of


the kind Deposit, and then vote on it on the Ronin chain to complete the cross-chain operation. It is


important to note that if the cross-chain operation involves a large amount of funds from Ronin to


Page 5 of 38


**Ronin Bridge Security Audit**

```


Ethereum, it may trigger a fund lock, and the corresponding Receipt will need to be unlocked by an


unlock account before the withdrawal can proceed.


Page 6 of 38


**Ronin Bridge Security Audit**

```

#### **1 Overview**

##### **1.1 Project Overview**


**Project Name** Ronin Bridge


**Project Language** solidity


**Platform** Ronin, Ethereum


**Github Link** https://github.com/ronin-chain/bridge-contract/


/src/ronin/gateway/RoninBridgeManager.sol



**Contract Scope**


**Script Scope**



/src/ronin/gateway/RoninGatewayV3.sol

/src/mainchain/MainchainBridgeManager.sol

/src/mainchain/MainchainGatewayV3.sol


/script/20240716-upgrade-v3.2.0-mainnet

/script/20240807-ir-recover



**Audit Commit** 132fcc674f46cd900c2dc6bd677379654bd7f639


Ronin Transaction:



**Audit Transactions**



0xf621da2b000ef3d59d04fe494e6f40b23fe4c2fc29ff32bb9cc9d61eaf28a8a3

Ethereum Transaction:

0xd9e926f03876a286cad87f21015127f7b2b949323d4b4db273c285990a9d336b


##### **1.2 Audit Overview**

Audit work duration: Aug 13, 2024 – Aug 21, 2024


Audit team: Beosin Security Team

##### **1.3 Audit Method**


The audit methods are as follows:


1. Manual Review


Using manual auditing methods, the code is read line by line to identify potential security issues. This


ensures that the contract's execution logic aligns with the client's specifications and intentions,


thereby safeguarding the accuracy of the contract's business logic.


The manual audit is divided into three groups to cover the entire auditing process:


Page 7 of 38


**Ronin Bridge Security Audit**

```


The Basic Testing Group is primarily responsible for interpreting the project's code and conducting


comprehensive functional testing.


The Simulated Attack Group is responsible for analyzing the audited project based on the collected


historical audit vulnerability database and security incident attack models. They identify potential


attack vectors and collaborate with the Basic Testing Group to conduct simulated attack tests.


The Expert Analysis Group is responsible for analyzing the overall project design, interactions with third


parties, and security risks in the on-chain operational environment. They also conduct a review of the


entire audit findings.


2. Static Analysis


Static analysis is a method of examining code during compilation or static analysis to detect issues.


Beosin-VaaS can detect more than 100 common smart contract vulnerabilities through static analysis,


such as reentrancy and block parameter dependency. It allows early and efficient discovery of


problems to improve code quality and security.


Page 8 of 38


**Ronin Bridge Security Audit**

```

#### **2 Script Audit**

##### **2.1 20240716-p3 script code logic analysis**


This script is related to the previous Ronin Bridge attack. The focus is on analyzing its logic to identify


any other potential issues.


Figure 1 Run function screenshot


The <u><mark>run</mark></u> function serves as the entry point for the entire script and primarily handles the migration and


upgrade of the bridge manager on the Ronin mainnet. First, it loads the new bridge manager contract


instance on the Ronin mainnet. Then, it switches to the companion network (Ethereum mainnet) to


load the current main chain bridge manager instance. After performing checks and outputting


information, the function switches back to the Ronin network to set the addresses of the old and new


bridge managers. Next, it calls <u><mark>_prankChangeAdminMainchainBM()</mark></u> to impersonate an admin and


change the permissions of the main chain bridge manager. Finally, it invokes


<u><mark>_upgradeBridgeMainchain()</mark></u> to complete the logic upgrade of the main chain bridge manager.


Page 9 of 38


**Ronin Bridge Security Audit**

```


Figure 2 _upgradeBridgeMainchain function screenshot(1/2)


Figure 3 _upgradeBridgeMainchain function screenshot(2/2)


The <u><mark>_upgradeBridgeMainchain</mark></u> function primarily handles the upgrade of the main chain bridge


manager and creates a proposal containing several critical steps. Specifically, the function first


switches to the companion network and deploys the new contract logic. Next, it sets the mapping rules


for the WBTC token using <u><mark>mapTokensAndThresholds</mark></u> <u>, upgrades and initializes the Mainchain Gateway</u>


V3 logic contract using <u><mark>initializeV4</mark></u>, sets the new bridge manager address, and changes the admin


permissions. All these actions are bundled into a proposal, which includes steps such as


<u><mark>mapTokensAndThresholds</mark></u> and <u><mark>initializeV4</mark></u>, and is eventually executed by calling the <u><mark>relayProposal</mark></u>


function on the old bridge manager contract.


Page 10 of 38


**Ronin Bridge Security Audit**

```

##### **2.2 Check for uninitialized parameters on the chain**


Based on the script(20240716-p3) code analysis, the migration script's execution logic can be


combined with the on-chain code to check whether, aside from the missing weight updates, there are


any other uninitialized parameters in the actual on-chain environment.


Figure 4 mapTokensAndThresholds function screenshot


Figure 5 initializeV4 function screenshot


The first call in the proposal is the <u><mark>mapTokensAndThresholds</mark></u> function, which initializes token


mappings and related threshold parameters. It takes the token addresses on the main chain and Ronin


network, token standards, and an array containing four types of thresholds. This function maps the


tokens to the Ronin network and sets the high-tier thresholds, locked thresholds, unlock fee


percentages, and daily withdrawal limits. The second call is the <u><mark>initializeV4</mark></u> function, used to initialize


the WETH address. Apart from these initialization operations, the proposal does not involve updates to


other contract parameters.


Combining on-chain contract data and code analysis, it is confirmed that the contract currently lacks


updates for <u><mark>_operatorWeight</mark></u> and <u><mark>_totalOperatorWeight</mark></u> . Now there are two ways to solve this problem:


the first is to directly utilize the onBridgeOperatorsAdded function that already exists in the current


contract to update the operator's weights; the second is to upgrade the contract and implement the


initializeV5 function in the upgraded contract to update the weights.


Page 11 of 38


**Ronin Bridge Security Audit**

```


Figure 6 onBridgeOperatorsAdded function screenshot

##### **2.3 20240807-ir-recover script code logic analysis**


This section provides an analysis of the script logic used to fix the vulnerability, and based on this


analysis, confirms the feasibility of the fix.


Figure 7 run function screenshot

The script logic is generally divided into four steps:


1. <u><mark>_preCheck_Withdrawable</mark></u> : Perform a preliminary check by simulating operations to cancel the pause


and ensure that funds can be withdrawn normally.


2. <u><mark>_perform_PrankFix</mark></u> <u>: Execute the fix by creating a proposal and calling the</u> <u><mark>onBridgeOperatorsAdded</mark></u>


function within the proposal to set the weights.


3. <u><mark>_perform_checkAfterPrankFix</mark></u> <u>:</u> Check after the fix to ensure that withdrawal operations can


proceed normally.


4. <u><mark>_performCreateProposalOnRonin</mark></u> : Initiate a proposal on the Ronin chain.


Page 12 of 38


**Ronin Bridge Security Audit**

```

##### **2.4. Test the 20240807-ir-recover script**


This section describes the execution of the fix script and assesses whether it effectively resolves the


vulnerability based on the test results.


Script execution test screenshot:


Screenshot of the run function call in the script:


Successful withdrawals were made using fake credentials, confirming that the vulnerability persisted


after the suspension was lifted.


The <u><mark>onBridgeOperatorsAdded</mark></u> function was successfully called through the proposal, and the weights


were successfully updated.


After verifying the updated weights, another attempt to withdraw token failed, proving the vulnerability


had been fixed.


Page 13 of 38


**Ronin Bridge Security Audit**



```


Page 14 of 38


**Ronin Bridge Security Audit**

```

#### **3 Contract Audit**

##### **2.1 Proposal Security** **[Ronin-01] Propose Function**


**Lines** RoninBridgeManager.sol#L35-57


The <u><mark>_proposeProposalStruct</mark></u> function allows a governor to create a
**Description**

corresponding callback proposal. The proposal includes information such as the


target contract to be called, callback data, and expiration time. Subsequent


voting can be done using functions like <u><mark>castProposalBySignatures</mark></u> . The


<u><mark>propose</mark></u> function can only be called by the Governor, and the expiration of the


old proposal will be checked when creating a proposal. When the old proposal


expires, the current proposal will replace the round of the old proposal, thus


ensuring the safety of the round. Creating a proposal requires classifying the


proposal's chainid, which affects whether the subsequent voting type is a


signed vote or an unsigned vote.

function _proposeProposalStruct(Proposal.ProposalDetail memory

proposal, address creator) internal virtual returns (uint256 round_) {

uint256 chainId = proposal.chainId;

if (chainId == 0) revert ErrInvalidChainId(msg.sig, 0,

block.chainid);

proposal.validate(_proposalExpiryDuration);

bytes32 proposalHash = proposal.hash();

round_ = _createVotingRound(chainId);

_saveVotingRound(vote[chainId][round_], proposalHash,

proposal.expiryTimestamp);

if (round_ != proposal.nonce) revert

ErrInvalidProposalNonce(msg.sig);

emit ProposalCreated(chainId, round_, proposalHash, proposal,

creator);

}


Page 15 of 38


**Ronin Bridge Security Audit**

```

##### **[Ronin-02] CastVote Function**


**Lines** RoninBridgeManager.sol#L67-73


The <u><mark>_castVote</mark></u> function allows voting on the proposal for the current round, but
**Description**

the voting process is divided into two types: signed voting and unsigned voting.


Signed voting is typically used for cross-chain proposals, where the chainid is


not 2020. In this type of voting, a signature is recorded during the voting


process. Once the signature weight of the entire proposal accumulates


sufficiently, the governor will handle the signature list on the corresponding


chain of the proposal in the form of a <u><mark>RelayPropose</mark></u> <u>.</u> Unsigned voting is


generally used for proposals on the current chain. When the weight


accumulates sufficiently, the current chain's calldata will be invoked. After each


governor votes, the contract records the signature hash for the corresponding


proposal to prevent the reuse of signatures for the same proposal, ensuring the


security of the signatures.

function _castVote(

Proposal.ProposalDetail memory proposal,

Ballot.VoteType support,

uint256 minimumForVoteWeight,

uint256 minimumAgainstVoteWeight,

address voter,

Signature memory signature,

uint256 voterWeight

) internal virtual returns (bool done) {

uint256 chainId = proposal.chainId;

uint256 round_ = proposal.nonce;

ProposalVote storage _vote = vote[chainId][round_];

if (_tryDeleteExpiredVotingRound(_vote)) {

return true;

}

if (round[proposal.chainId] != round_) revert

ErrInvalidProposalNonce(msg.sig);

if (_vote.status != VoteStatus.Pending) revert

ErrVoteIsFinalized();

if (_voted(_vote, voter)) revert ErrAlreadyVoted(voter);

_vote.voted[voter] = true;

// Stores the signature if it is not empty

if (signature.r            - 0 || signature.s            - 0 || signature.v            - 0) {


Page 16 of 38


}



**Ronin Bridge Security Audit**

```


<u>_vote.sig[voter]</u> <u>=</u> <u>signature;</u>

}

emit ProposalVoted(_vote.hash, voter, support, voterWeight);

uint256 _forVoteWeight;

uint256 _againstVoteWeight;

if (support == Ballot.VoteType.For) {

_vote.forVoteds.push(voter);

_forVoteWeight = _vote.forVoteWeight += voterWeight;

} else if (support == Ballot.VoteType.Against) {

_vote.againstVoteds.push(voter);

_againstVoteWeight = _vote.againstVoteWeight += voterWeight;

} else {

revert ErrUnsupportedVoteType(msg.sig);

}

if (_forVoteWeight >= minimumForVoteWeight) {

done = true;

_vote.status = VoteStatus.Approved;

emit ProposalApproved(_vote.hash);

if (proposal.isAutoExecute()) {

_tryExecute(_vote, proposal);

}

} else if (_againstVoteWeight >= minimumAgainstVoteWeight) {

done = true;

_vote.status = VoteStatus.Rejected;

emit ProposalRejected(_vote.hash);

}


Page 17 of 38


**Ronin Bridge Security Audit**

```

##### **[Ronin-03] Execute Function**


**Lines** RoninBridgeManager.sol#L187-189


The <u><mark>execute</mark></u> function is called by the proposal’s executor to attempt to execute
**Description**

the proposal, invoking the calldata on the target contract with the contract's


authority. When executing a proposal call, the contract checks whether the


hash of the currently passed proposal is consistent with the hash of the ledger


vote, and checks the voting status and whether the caller is the executor of the


proposal. These checks ensure the completeness of the proposal execution.

function _executeWithCaller(Proposal.ProposalDetail memory proposal,

address caller) internal {

bytes32 proposalHash = proposal.hash();

ProposalVote storage _vote =

vote[proposal.chainId][proposal.nonce];

if (_vote.hash != proposalHash) {

revert ErrInvalidProposal(proposalHash, _vote.hash);

}

if (_vote.status != VoteStatus.Approved) revert

ErrProposalNotApproved();

if (caller != proposal.executor) revert ErrInvalidExecutor();

_tryExecute(_vote, proposal);

}


Page 18 of 38


**Ronin Bridge Security Audit**

```

##### **[Ronin-04] DeleteExpired Function**


**Lines** RoninBridgeManager.sol#L208-213


The <u><mark>deleteExpired</mark></u> function allows for manually deleting expired proposals. It is
**Description**

important to note that even if <u><mark>deleteExpired</mark></u> is not called, expired proposals can


still be automatically deleted when creating new proposals. When creating a


proposal, the contract will call the <u><mark>_tryDeleteExpiredVotingRound</mark></u> function to


delete the expired proposal according to the current proposal status. This


ensures the security of the contract round.

function _tryDeleteExpiredVotingRound(ProposalVote storage

proposalVote) internal returns (bool isExpired) {

isExpired = _getChainType() == ChainType.RoninChain &&

proposalVote.status == VoteStatus.Pending &&

proposalVote.expiryTimestamp <= block.timestamp;

if (isExpired) {

emit ProposalExpired(proposalVote.hash);

for (uint256 _i; _i < proposalVote.forVoteds.length;) {

delete proposalVote.voted[proposalVote.forVoteds[_i]];

delete proposalVote.sig[proposalVote.forVoteds[_i]];

unchecked {

++_i;

}}

for (uint256 _i; _i < proposalVote.againstVoteds.length;) {

delete proposalVote.voted[proposalVote.againstVoteds[_i]];

delete proposalVote.sig[proposalVote.againstVoteds[_i]];

unchecked {

++_i;

}

}

delete proposalVote.status;

delete proposalVote.hash;

delete proposalVote.againstVoteWeight;

delete proposalVote.forVoteWeight;

delete proposalVote.forVoteds;

delete proposalVote.againstVoteds;

delete proposalVote.expiryTimestamp;

}

}


Page 19 of 38


**Ronin Bridge Security Audit**

```

##### **[Ronin-05] RelayProposal Function**


**Lines** MainchainBridgeManager.sol#L39-46


The <u><mark>relayProposal</mark></u> function can relay proposals that have already been passed
**Description**

on the Ronin chain. When the Ethereum-type proposal on the Ronin chain has


sufficient weight to pass, the governor can collect the corresponding


signatures in the proposal and use the <u><mark>relayProposal</mark></u> function to create and


execute the corresponding proposal. <u><mark>relayProposal</mark></u> will only be executed when


the proposal of the ronin chain is passed, and cannot be executed by voting


alone in Ethereum, this design pattern ensures that voting on proposals is


conducted on the ronin chain, making it easier to carry out and manage


proposals.

function _relayVotesBySignatures(

Proposal.ProposalDetail memory _proposal,

Ballot.VoteType[] calldata _supports,

Signature[] calldata _signatures,

bytes32 proposalHash

) internal {

if (!(_supports.length            - 0 && _supports.length ==

_signatures.length)) revert ErrLengthMismatch(msg.sig);

bytes32 _forDigest =

ECDSA.toTypedDataHash(_proposalDomainSeparator(),

Ballot.hash(proposalHash, Ballot.VoteType.For));

bytes32 _againstDigest =

ECDSA.toTypedDataHash(_proposalDomainSeparator(),

Ballot.hash(proposalHash, Ballot.VoteType.Against));

address[] memory _forVoteSigners = new

address[](_signatures.length);

address[] memory _againstVoteSigners = new

address[](_signatures.length);

{

uint256 _forVoteCount;

uint256 _againstVoteCount;

{

address _signer;

address _lastSigner;

Ballot.VoteType _support;

Signature calldata _sig;


Page 20 of 38


**Ronin Bridge Security Audit**

```


<u>for</u> <u>(uint256</u> <u>_i;</u> <u>_i</u> <u><</u> <u>_signatures.length;)</u> <u>{</u>

_sig = _signatures[_i];

_support = _supports[_i];

if (_support == Ballot.VoteType.For) {

_signer = ECDSA.recover(_forDigest, _sig.v, _sig.r, _sig.s);

_forVoteSigners[_forVoteCount++] = _signer;

} else if (_support == Ballot.VoteType.Against) {

_signer = ECDSA.recover(_againstDigest, _sig.v, _sig.r,

_sig.s);

_againstVoteSigners[_againstVoteCount++] = _signer;

} else {

revert ErrUnsupportedVoteType(msg.sig);

}

if (_lastSigner >= _signer) revert ErrInvalidOrder(msg.sig);

_lastSigner = _signer;

unchecked {

++_i;

}

}

}

assembly {

mstore(_forVoteSigners, _forVoteCount)

mstore(_againstVoteSigners, _againstVoteCount)

}

}

ProposalVote storage _vote =

vote[_proposal.chainId][_proposal.nonce];

uint256 _minimumForVoteWeight = _getMinimumVoteWeight();

uint256 _totalForVoteWeight = _sumWeight(_forVoteSigners);

if (_totalForVoteWeight >= _minimumForVoteWeight) {

if (_totalForVoteWeight == 0) revert

ErrInvalidVoteWeight(msg.sig);

_vote.status = VoteStatus.Approved;

emit ProposalApproved(_vote.hash);

_tryExecute(_vote, _proposal);

return;

}

uint256 _minimumAgainstVoteWeight = _getTotalWeight()   
_minimumForVoteWeight + 1;


Page 21 of 38


**Ronin Bridge Security Audit**

```


<u>uint256</u> <u>_totalAgainstVoteWeight</u> <u>=</u> <u>_sumWeight(_againstVoteSigners);</u>

if (_totalAgainstVoteWeight >= _minimumAgainstVoteWeight) {

if (_totalAgainstVoteWeight == 0) revert

ErrInvalidVoteWeight(msg.sig);

_vote.status = VoteStatus.Rejected;

emit ProposalRejected(_vote.hash);

return;

}

revert ErrRelayFailed(msg.sig);

}


Page 22 of 38


**Ronin Bridge Security Audit**

```

##### **2.2 Cross-chain Bridge Security** **[Ronin-06] RequestWithdrawal Function**


**Lines** RoninGatewayV3.sol#L208-210


The <u><mark>requestWithdrawalFor</mark></u> function can generate a cross-chain Receipt on the
**Description**

Ronin chain. If the user later obtains enough weighted signatures, they can use


the corresponding cross-chain Receipt and signatures on Ethereum to


withdraw funds. It is important to note that when withdrawing corresponding


cross-chain funds from Ethereum, there is a fund threshold. If the withdrawal


amount exceeds this threshold, a specific unlock account will need to call the


<u><mark>unlockWithdrawal</mark></u> function to unlock the corresponding Receipt for


withdrawal.The generation of the receipt includes the kind of Withdrawal type.


This type of receipt can only be redeemed on Ethereum, which ensures the


legitimacy of the receipt.

function _requestWithdrawalFor(Transfer.Request calldata _request,

address _requester, uint256 _chainId) internal {

_request.info.validate();

_checkWithdrawal(_request);

MappedToken memory _token = getMainchainToken(_request.tokenAddr,

_chainId);

if (_request.info.erc != _token.erc) revert

ErrInvalidTokenStandard();

_request.info.handleAssetIn(_requester, _request.tokenAddr);

_storeAsReceipt(_request, _chainId, _requester, _token.tokenAddr);

}


Page 23 of 38


**Ronin Bridge Security Audit**

```

##### **[Ronin-07] DepositFor Function**


**Lines** RoninGatewayV3.sol#L146-148


The <u><mark>depositFor</mark></u> function allows the Operator to vote on the generated Receipt
**Description**

on Ethereum. Once the Receipt accumulates sufficient weight, the contract will


send the corresponding cross-chain funds to the user recorded in the Receipt.


When withdrawing funds, the chainid and kind types are checked to avoid


multiple chains being reused. This cross-chain withdrawal requires enough


operators to call and vote, which ensures the overall security of the receipt.

function _depositFor(Transfer.Receipt memory receipt, address

operator, uint256 minVoteWeight) internal {

uint256 id = receipt.id;

receipt.info.validate();

if (receipt.kind != Transfer.Kind.Deposit) revert

ErrInvalidReceiptKind();

if (receipt.ronin.chainId != block.chainid) revert

ErrInvalidChainId(msg.sig, receipt.ronin.chainId, block.chainid);

MappedToken memory token =

getMainchainToken(receipt.ronin.tokenAddr,

receipt.mainchain.chainId);

if (!(token.erc == receipt.info.erc && token.tokenAddr ==

receipt.mainchain.tokenAddr)) {

revert ErrInvalidReceipt();

}

IsolatedGovernance.Vote storage _proposal =

depositVote[receipt.mainchain.chainId][id];

bytes32 _receiptHash = receipt.hash();

VoteStatus status = _castIsolatedVote(_proposal, operator,

minVoteWeight, _receiptHash);

emit DepositVoted(operator, id, receipt.mainchain.chainId,

_receiptHash);

IBridgeTracking bridgeTrackingContract =

IBridgeTracking(getContract(ContractType.BRIDGE_TRACKING));

if (status == VoteStatus.Approved) {

_proposal.status = VoteStatus.Executed;

receipt.info.handleAssetOut(payable(receipt.ronin.addr),

receipt.ronin.tokenAddr, IWETH(address(0)));

bridgeTrackingContract.handleVoteApproved(IBridgeTracking.VoteK


Page 24 of 38


**Ronin Bridge Security Audit**

```


<u>ind.Deposit,</u> <u>receipt.id);</u>

emit Deposited(_receiptHash, receipt);

}

bridgeTrackingContract.recordVote(IBridgeTracking.VoteKind.Depos

it, receipt.id, operator);

}


Page 25 of 38


**Ronin Bridge Security Audit**

```

##### **[Ronin-08] SubmitWithdrawal Function**


**Lines** MainchainGatewayV3.sol#L173-175

If a user has obtained enough weighted signatures, they can call the
**Description**

<u><mark>submitWithdrawal</mark></u> function and pass in the signature list to use the operator's


signatures to verify the weight of the Receipt, thereby claiming the cross-chain


funds. It is important to note that when withdrawing corresponding cross-chain


funds from Ethereum, there is a fund threshold. If the withdrawal amount


exceeds this threshold, a specific unlock account will need to call the


<u><mark>unlockWithdrawal</mark></u> function to unlock the corresponding Receipt for withdrawal.


function _submitWithdrawal(Transfer.Receipt calldata receipt,

Signature[] memory signatures) internal virtual returns (bool locked)

{

uint256 id = receipt.id;

uint256 quantity = receipt.info.quantity;

address tokenAddr = receipt.mainchain.tokenAddr;

receipt.info.validate();

if (receipt.kind != Transfer.Kind.Withdrawal) revert

ErrInvalidReceiptKind();

if (receipt.mainchain.chainId != block.chainid) {

revert ErrInvalidChainId(msg.sig, receipt.mainchain.chainId,

block.chainid);

}

MappedToken memory token =

getRoninToken(receipt.mainchain.tokenAddr);

if (!(token.erc == receipt.info.erc && token.tokenAddr ==

receipt.ronin.tokenAddr && receipt.ronin.chainId == roninChainId)) {

revert ErrInvalidReceipt();

}

if (withdrawalHash[id] != 0) revert

ErrQueryForProcessedWithdrawal();

if (!(receipt.info.erc == TokenStandard.ERC721

|| !_reachedWithdrawalLimit(tokenAddr, quantity))) {

revert ErrReachedDailyWithdrawalLimit();

}

bytes32 receiptHash = receipt.hash();

bytes32 receiptDigest = Transfer.receiptDigest(_domainSeparator,

receiptHash);


Page 26 of 38


**Ronin Bridge Security Audit**

```


<u>uint256</u> <u>minimumWeight;</u>

(minimumWeight, locked) = _computeMinVoteWeight(receipt.info.erc,

tokenAddr, quantity);

{

bool passed;

address signer;

address lastSigner;

Signature memory sig;

uint256 accumWeight;

for (uint256 i; i < signatures.length; i++) {

sig = signatures[i];

signer = ECDSA.recover({ hash: receiptDigest, v: sig.v, r: sig.r,

s: sig.s });

if (lastSigner >= signer) revert ErrInvalidOrder(msg.sig);

lastSigner = signer;

uint256 w = _getWeight(signer);

if (w == 0) revert ErrInvalidSigner(signer, w, sig);

accumWeight += w;

if (accumWeight >= minimumWeight) {

passed = true;

break;

}

}

if (!passed) revert ErrQueryForInsufficientVoteWeight();

withdrawalHash[id] = receiptHash;

}

if (locked) {

withdrawalLocked[id] = true;

emit WithdrawalLocked(receiptHash, receipt);

return locked;

}

_recordWithdrawal(tokenAddr, quantity);

receipt.info.handleAssetOut(payable(receipt.mainchain.addr),

tokenAddr, wrappedNativeToken);

emit Withdrew(receiptHash, receipt);

}


Page 27 of 38


**Ronin Bridge Security Audit**

```

##### **[Ronin-09] UnlockWithdrawal Function**


**Lines** MainchainGatewayV3.sol#L180-205

If the amount of cross-chain funds to be claimed by the user is large enough,
**Description**

the Receipt will be locked. At this time, the unlock account will need to call the


<u><mark>unlockWithdrawal</mark></u> function to unlock the Receipt so that the user can claim the


corresponding cross-chain funds. When performing the unlocking operation, a


portion of the funds will be used as commission for the unlock account, which


ensures the enthusiasm for the unlock account.

function unlockWithdrawal(Transfer.Receipt calldata receipt) external

onlyRole(WITHDRAWAL_UNLOCKER_ROLE) {

bytes32 _receiptHash = receipt.hash();

if (withdrawalHash[receipt.id] != receipt.hash()) {

revert ErrInvalidReceipt();

}

if (!withdrawalLocked[receipt.id]) {

revert ErrQueryForApprovedWithdrawal();

}

delete withdrawalLocked[receipt.id];

emit WithdrawalUnlocked(_receiptHash, receipt);

address token = receipt.mainchain.tokenAddr;

if (receipt.info.erc == TokenStandard.ERC20) {

TokenInfo memory feeInfo = receipt.info;

feeInfo.quantity = _computeFeePercentage(receipt.info.quantity,

unlockFeePercentages[token]);

TokenInfo memory withdrawInfo = receipt.info;

withdrawInfo.quantity = receipt.info.quantity - feeInfo.quantity;

feeInfo.handleAssetOut(payable(msg.sender), token,

wrappedNativeToken);

withdrawInfo.handleAssetOut(payable(receipt.mainchain.addr),

token, wrappedNativeToken);

} else {

receipt.info.handleAssetOut(payable(receipt.mainchain.addr),

token, wrappedNativeToken);

}

emit Withdrew(_receiptHash, receipt);

}


Page 28 of 38


**Ronin Bridge Security Audit**

```

##### **[Ronin-10] RequestDepositFor Function**


**Lines** MainchainGatewayV3.sol#L156-158


The <u><mark>requestDepositFor</mark></u> function can generate a cross-chain Receipt on
**Description**

Ethereum. Subsequently, the operator on the Ronin chain can vote on the


Receipt. Once the accumulated weight of the votes is sufficient, the contract


will send the corresponding cross-chain funds to the user recorded in the


Receipt. This withdrawal method is convenient for users to make manual


proposals, but it requires sufficient security protection for the operator's


signature.

function _requestDepositFor(Transfer.Request memory _request, address

_requester) internal virtual {

MappedToken memory _token;

address _roninWeth = address(wrappedNativeToken);

_request.info.validate();

if (_request.tokenAddr == address(0)) {

if (_request.info.quantity != msg.value) revert

ErrInvalidRequest();

_token = getRoninToken(_roninWeth);

if (_token.erc != _request.info.erc) revert

ErrInvalidTokenStandard();

_request.tokenAddr = _roninWeth;

} else {

if (msg.value != 0) revert ErrInvalidRequest();

_token = getRoninToken(_request.tokenAddr);

if (_token.erc != _request.info.erc) revert

ErrInvalidTokenStandard();

_request.info.handleAssetIn(_requester, _request.tokenAddr);

if (_roninWeth == _request.tokenAddr) {

wrappedNativeToken.approve(address(wethUnwrapper),

_request.info.quantity);

wethUnwrapper.unwrap(_request.info.quantity);

}

}

uint256 _depositId = depositCount++;

Transfer.Receipt memory _receipt =

_request.into_deposit_receipt(_requester, _depositId,

_token.tokenAddr, roninChainId);


Page 29 of 38


**Ronin Bridge Security Audit**



}



```


<u>emit</u> <u>DepositRequested(_receipt.hash(),</u> <u>_receipt);</u>


Page 30 of 38


**Ronin Bridge Security Audit**

```

#### **4 Appendix**

##### **4.1 Vulnerability Assessment Metrics and Status in Smart Contracts**

###### **4.1.1 Metrics**


In order to objectively assess the severity level of vulnerabilities in blockchain systems, this report


provides detailed assessment metrics for security vulnerabilities in smart contracts with reference to


CVSS 3.1 (Common Vulnerability Scoring System Ver 3.1).


According to the severity level of vulnerability, the vulnerabilities are classified into four levels:


"critical", "high", "medium" and "low". It mainly relies on the degree of impact and likelihood of


exploitation of the vulnerability, supplemented by other comprehensive factors to determine of the


severity level.



**Impact**



**Severe** **High** **Medium** **Low**



**Likelihood**



**Probable** **Critical** **High** **Medium** **Low**


**Possible** **High** **Medium** **Medium** **Low**


**Unlikely** **Medium** **Medium** **Low** **Info**


**Rare** **Low** **Low** **Info** **Info**


Page 31 of 38


**Ronin Bridge Security Audit**

```

###### **4.1.2 Degree of impact**


 **Severe**


Severe impact generally refers to the vulnerability can have a serious impact on the confidentiality,


integrity, availability of smart contracts or their economic model, which can cause substantial


economic losses to the contract business system, large-scale data disruption, loss of authority


management, failure of key functions, loss of credibility, or indirectly affect the operation of other


smart contracts associated with it and cause substantial losses, as well as other severe and mostly


irreversible harm.


 **High**


High impact generally refers to the vulnerability can have a relatively serious impact on the


confidentiality, integrity, availability of the smart contract or its economic model, which can cause a


greater economic loss, local functional unavailability, loss of credibility and other impact to the


contract business system.


 **Medium**


Medium impact generally refers to the vulnerability can have a relatively minor impact on the


confidentiality, integrity, availability of the smart contract or its economic model, which can cause a


small amount of economic loss to the contract business system, individual business unavailability and


other impact.


 **Low**


Low impact generally refers to the vulnerability can have a minor impact on the smart contract, which


can pose certain security threat to the contract business system and needs to be improved.

###### **4.1.3 Likelihood of Exploitation**


 **Probable**


Probable likelihood generally means that the cost required to exploit the vulnerability is low, with no


special exploitation threshold, and the vulnerability can be triggered consistently.


 **Possible**


Possible likelihood generally means that exploiting such vulnerability requires a certain cost, or there


are certain conditions for exploitation, and the vulnerability is not easily and consistently triggered.


Page 32 of 38


**Ronin Bridge Security Audit**

```


 **Unlikely**


Unlikely likelihood generally means that the vulnerability requires a high cost, or the exploitation


conditions are very demanding and the vulnerability is highly difficult to trigger.


 **Rare**


Rare likelihood generally means that the vulnerability requires an extremely high cost or the conditions


for exploitation are extremely difficult to achieve.

###### **4.1.4 Fix Results Status**


**Status** **Description**


**Fixed** The project party fully fixes a vulnerability.


The project party did not fully fix the issue, but only mitigated the
**Partially Fixed**
issue.


**Acknowledged** The project party confirms and chooses to ignore the issue.


Page 33 of 38


**Ronin Bridge Security Audit**



```

##### **4.2 Audit Categories**


**No.** **Categories** **Subitems**


SPL Token Standards


Visibility Specifiers


Lamport Check



**1** Coding Conventions


**2** General Vulnerability


**3** Business Security



Account Check


Signer Check


Program Id Check


Deprecated Items


Redundant Code


Integer Overflow/Underflow


Reentrancy


Pseudo-random Number Generator (PRNG)


Transaction-Ordering Dependence


DoS (Denial of Service)


Function Call Permissions


Returned Value Security


Replay Attack


Overriding Variables


Third-party Protocol Interface Consistency


Business Logics


Business Implementations


Manipulable Token Price


Centralized Asset Control


Asset Tradability


Arbitrage Attack



Beosin classified the security issues of smart contracts into three categories: Coding Conventions,


General Vulnerability, Business Security. Their specific definitions are as follows:


 **Coding Conventions**


Page 34 of 38


**Ronin Bridge Security Audit**

```


Audit whether smart contracts follow recommended language security coding practices. For example,


smart contracts developed in Solidity language should fix the compiler version and do not use


deprecated keywords.

 **General Vulnerability**

General Vulnerability include some common vulnerabilities that may appear in smart contract projects.


These vulnerabilities are mainly related to the characteristics of the smart contract itself, such as


integer overflow/underflow and denial of service attacks.

 **Business Security**

Business security is mainly related to some issues related to the business realized by each project, and


has a relatively strong pertinence. For example, whether the lock-up plan in the code match the white


paper, or the flash loan attack caused by the incorrect setting of the price acquisition oracle.


*Note that the project may suffer stake losses due to the integrated third-party protocol. This is not something


Beosin can control. Business security requires the participation of the project party. The project party and users


need to stay vigilant at all times.


Page 35 of 38


**Ronin Bridge Security Audit**

```

##### **4.3 Disclaimer**


The Audit Report issued by Beosin is related to the services agreed in the relevant service agreement.


The Project Party or the Served Party (hereinafter referred to as the "Served Party") can only be used


within the conditions and scope agreed in the service agreement. Other third parties shall not transmit,


disclose, quote, rely on or tamper with the Audit Report issued for any purpose.


The Audit Report issued by Beosin is made solely for the code, and any description, expression or


wording contained therein shall not be interpreted as affirmation or confirmation of the project, nor


shall any warranty or guarantee be given as to the absolute flawlessness of the code analyzed, the code


team, the business model or legal compliance.


The Audit Report issued by Beosin is only based on the code provided by the Served Party and the


technology currently available to Beosin. However, due to the technical limitations of any organization,


and in the event that the code provided by the Served Party is missing information, tampered with,


deleted, hidden or subsequently altered, the audit report may still fail to fully enumerate all the risks.


The Audit Report issued by Beosin in no way provides investment advice on any project, nor should it be


utilized as investment suggestions of any type. This report represents an extensive evaluation process


designed to help our customers improve code quality while mitigating the high risks in blockchain.


Page 36 of 38


**Ronin Bridge Security Audit**

```

##### **4.4 About Beosin**


Beosin is the first institution in the world specializing in the construction of blockchain


security ecosystem. The core team members are all professors, postdocs, PhDs, and Internet


elites from world-renowned academic institutions. Beosin has more than 20 years of research


in formal verification technology, trusted computing, mobile security and kernel security, with


overseas experience in studying and collaborating in project research at well-known


universities. Through the security audit and defense deployment of more than 2,000 smart


contracts, over 50 public blockchains and wallets, and nearly 100 exchanges worldwide,


Beosin has accumulated rich experience in security attack and defense of the blockchain field,


and has developed several security products specifically for blockchain.


Page 37 of 38


##### **Official Website** https://www.beosin.com **Telegram** https://t.me/beosin **Twitter** https://twitter.com/Beosin_com **Email** service@beosin.com


