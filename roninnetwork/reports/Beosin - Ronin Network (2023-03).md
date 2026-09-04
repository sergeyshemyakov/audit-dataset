# **Ronin Network**

## Public Block Chain Security Audit V1.5
### No. 202303031441 Mar 3 rd, 2023


Ronin Network Security Audit

#### **Contents**

**Overview ............................................................................................................................................................. 1**

Project Overview ..........................................................................................................................................1

Audit Overview ............................................................................................................................................1

**Summary of audit results .................................................................................................................................. 2**

**Findings for Blockchain .................................................................................................................................... 3**

[Ronin Node-1] consortium V2 checks the snapshot improperly.................................................................4

[Ronin Node-2] The _consortiumVerifyHeaders.Run_ method lacks data association validation ..................6

[Ronin Node-3] Changing the Coinbase by the validator node will result in incorrect block generation ....9

**Findings for Consensus Contracts ................................................................................................................. 10**

[DPoS Smart Contracts-1] Wrong use of _candidates as current validator ................................................11

[DPoS Smart Contracts-2] Credit score update exception .........................................................................12

[DPoS Smart Contracts-3] Will cause the validator to exit unexpectedly ..................................................13

[DPoS Smart Contracts-4] The proposal vote will result in defeat ............................................................15

[DPoS Smart Contracts-5] Parameter assignment error .............................................................................16

[DPoS Smart Contracts-6] _SlashDoubleSign_ function call is not implemented .........................................17

[DPoS Smart Contracts-7] Redundant codes ..............................................................................................18

[DPoS Smart Contracts-8] The __updateTrustedOrganization_ function is not designed properly ...............19

**Blockchain Audit Contents ............................................................................................................................. 21**

1 JSON RPC Security Audit .......................................................................................................................21

1.1 JSON RPC Introduction ...............................................................................................................21

1.2 JSON RPC Processing Logic .......................................................................................................22

1.3 RPC Sensitive Interface Permission .............................................................................................23

1.4 CLI Commands Security Audit ....................................................................................................23

1.5 Node Account Unlocking Security Audit .....................................................................................24

2 Node Security ..........................................................................................................................................25

2.1 Number of Node Connections ......................................................................................................25

2.2 Packet Size Limit ..........................................................................................................................25

2.3 Node Network Access Restrictions ..............................................................................................26

3 Account &Asset Security ........................................................................................................................27

3.1 Account Model .............................................................................................................................27

3.2 Account Generation ......................................................................................................................27

3.3 Transaction Signature ...................................................................................................................30

3.4 Asset Security ...............................................................................................................................31

4 Consensus Security ..................................................................................................................................33

4.1 DPoS Consensus Process Analysis ...............................................................................................34


1


Ronin Network Security Audit


4.2 PoA Consensus Process Analysis .................................................................................................34

4.3 Logic Implementation of DPoS ....................................................................................................35

4.4 Logic Implementation of PoA ......................................................................................................36

4.4 Rewards for Building Blocks .......................................................................................................40

4.4 Slashing Logic Implementation ....................................................................................................40

5 Transaction Model Security .....................................................................................................................45

5.1 Transaction Processing Flow ........................................................................................................45

5.2 Transaction replay audit ...............................................................................................................46

5.3 Dusting Attack ..............................................................................................................................47

5.4 Trading Flooding Attacks .............................................................................................................47

5.5 Double-spending Attack ...............................................................................................................47

5.6 Illegal Transactions.......................................................................................................................47

5.7 Fake Deposit Attack .....................................................................................................................48

5.8 Contract trading security ..............................................................................................................49

6 Cross-chain Bridge Security ....................................................................................................................50

6.1 Deposit Feature of Cross-Chain Bridge ........................................................................................50

6.2 Withdrawal Feature of Cross-Chain Bridge .................................................................................50

6.3 Migration Feature of Cross-Chain Bridge ....................................................................................51

**Historical Vulnerability Detection ................................................................................................................. 52**

**Consensus Contracts Audit Categories ......................................................................................................... 53**

**Appendix .......................................................................................................................................................... 55**

1.1 Vulnerability Assessment Metrics and Status in Smart Contracts .......................................................55

1.2 Disclaimer .............................................................................................................................................57

1.3 About Beosin ........................................................................................................................................58


2


Ronin Network Security Audit

##### **Overview**


**Project Overview**


**Project Name** Ronin Network



**Audit Scope**


**Ronin Node**

**Commit Hash**


**Ronin DPoS Contracts**

**Commit Hash**


**Audit Overview**



https://github.com/axieinfinity/ronin (Ronin Node)

https://github.com/axieinfinity/ronin-dpos-contracts (Ronin DPoS Contracts)


66f20552589269278c415ab59fe18a7b874012e6 (Initial)

57a52b0010f86be1b4bd341fbfafd02be3023a96

0c98d1fe8f4f8ffb877bc70df100ce63b4504c46

de588caf79b03c68f062fe1014702f5b6688c076

a285a1a887307d6962b400c1069b50931ccd90c2

8e1799ea45be72be55486d41a3ab1179ebc06c8b

9cba5d7cdc60a6950311abf2791607cbff761e52

9bf4895fbd51a9964a9b09c03b38abf0ace53008 (Final)


1d3f5e3c1de471edd6e8b4ea15167130f40e3d90 (Initial)

66903dbcdfb64964abe16994b4b2e7d5d9057ded (Final)



Audit work duration: February 1, 2023 – March 3, 2023

Update Details: Project commit hash and findings status updated on March 13, 2023

Update Details: Project commit hash and **Historical Vulnerability Detection** chapter updated on March 30,

2023

Update Details: **Historical Vulnerability Detection** and **Summary of audit results** chapters updated on May

10, 2023

Audit methods: Formal Verification, Static Analysis, Typical Case Testing and Manual Review.

Audit team: Beosin Security Team


1


Ronin Network Security Audit

##### **Summary of audit results**

**After auditing, 1 High risk, 4 Medium-risk, 3 Low-risk and 3 Info items were identified in the Ronin**

**Network project.** Specific audit details will be presented in the **Findings for Blockchain and Findings for**

**Consensus Contracts** sections. Users should pay attention to the following aspects when interacting with this

project：


Security vulnerability

5



4


3


2


1


0



4


3 3


1


0


Critical High Medium Low Info


Critical High Medium Low Info



**Notes** ：
 **Risk Description:**

1. Ronin is a fork of Go-Ethereum. Compared with Go-Ethereum, the project party has fixed multiple

vulnerabilities such as CVE-2022-29177 in Ronin Node Ver.2.5.2. And in May 2023, all Ronin validators

have successfully run Ver.2.5.2 Ronin Node in DPoS mainnet. It is recommended that users use Ronin

node Ver.2.5.2 or later.

 **Notes for Project Party:**

1. Ronin is a fork of Go-Ethereum. Through this audit, it was found that there are multiple vulnerabilities

that are the same as those in the historical version of Go-Ethereum. Therefore, it is recommended that the

project party should pay attention to the following two security management aspects of the Ronin Node

project:

1) Pay attention to whether the vulnerabilities that have been exposed by Ethereum exist in the Ronin

network, so as to prevent these vulnerabilities from being exploited in the Ronin network.

2) Establish a periodic update mechanism to upgrade the third-party components/libraries that the Ronin

project depends on in a timely, so as to avoid using risky third-party dependent components/libraries that

endanger the safe operation of the Ronin node.


2


Ronin Network Security Audit

##### **Findings for Blockchain**


**Index** **Risk description** **Severity level** **Status**

Ronin Node-1 consortium V2 checks the snapshot improperly **Medium** Fixed



Ronin Node-2


Ronin Node-3


**Status Notes:**



<u>The</u> _<u>consortiumVerifyHeaders.Run</u>_ <u>method lacks data</u>

**Medium** Partially fixed.
association validation

<u>Changing the coinbase by the validator node will result</u>

**Info** Acknowledged
in incorrect block generation



 Ronin Node-2 is partially fixed by Ronin project party. The _Run_ method has fixed the issue that the two
header data are not completely consistent, but it cannot be determined whether the two blocks exist on the

chain. This interface will affect the _slashDoubleSign_ function of the consensus contract, so the project

party will add admin permission to _slashDoubleSign_ function to prevent malicious data input (See **[DPoS**

**Smart Contracts-6]** in **Findings For Consensus Contracts** chapter for permission addition details). In

addition, in order to prevent double-signature attacks, the project party added the judgment of double
signature blocks to the _resultLoop_ method of miner to prevent double-signature attacks.

 Ronin Node-3 is acknowledged by Ronin project party. During the operation of the consortium V1

consensus, it is recommended that the verification nodes do not use the _miner.setEtherbase_ API to change

the coinbase, otherwise they will face the risk of not being able to generate blocks, but **this risk does not**

**exist when using consortium V2** .


3


Ronin Network Security Audit

###### **Finding Details:**

**[Ronin Node-1] consortium V2 checks the snapshot improperly**


**Severity Level** **Medium**

**Lines** consensus/consortium/v2/consortium.go #L310-382

**Description** When the block reaches the height of the consortium V2, due to the error handling
and verification of the snapshot, if the node restarts, it will not be able to continue to
produce blocks.


Figure 1 Source code of _snapshot_ method (Unfixed)


Figure 2 bad block


**Recommendations** It is recommended to modify the snapshot verification logic in consortium v2.

**Status** Fixed. See the PR for the fix details: https://github.com/axieinfinity/ronin/pull/212


4


Ronin Network Security Audit


Figure 3 Source code of _snapshot_ method (Fixed)


5


Ronin Network Security Audit


**[Ronin Node-2] The** **_consortiumVerifyHeaders.Run_** **method lacks data association**

**validation**


**Severity Level** **Medium**

**Lines** core/vm/consortium_precompiled_contracts.go #L421-449

core/vm/consortium_precompiled_contracts.go #L478-493


**Description** The _Run_ method function does not check whether the data of a block passed in
already exists in the chain database, nor does it check whether the data of the two
blocks passed in are the same. Therefore, malicious data can be constructed to bypass
_Run_ method check.


Figure 4 Source code of _Run_ method


Figure 5 Source code of _verify_ method (Unfixed)


**Recommendations** It is recommended to check whether the blocks data are the same and modify the
logic of whether the block exists on the chain.


6


Ronin Network Security Audit


**Status** Partially fixed. The Run method has fixed the issue that the two-header data are not
completely consistent, but it cannot be determined whether the two blocks exist on
the chain. This interface will affect the _slashDoubleSign_ function of the consensus
contract, so the project party will add the Admin permission to _slashDoubleSign_
function to prevent malicious data input (See **[DPoS Smart Contracts-6] in**
**_Findings For Consensus Contracts_** **chapter** for permission addition details). In
addition, in order to prevent double-signature attacks, the project party added the
judgment of double-signature blocks to the _resultLoop_ method of miner to prevent
double-signature attacks.

See the PRs for the fix details:

 [https://github.com/axieinfinity/ronin/pull/220](https://github.com/axieinfinity/ronin/pull/220)

 https://github.com/axieinfinity/ronin/pull/206


Figure 6 Source code of _verify_ method (Partially fixed)


7


Ronin Network Security Audit


Figure 7 Source code of _worker.resultLoop_ method


8


Ronin Network Security Audit


**[Ronin Node-3] Changing the coinbase by the validator node will result in**

**incorrect block generation**


**Severity Level** **Info**

**Lines** core/block_validator.go #L99

**Description** When the validator node calls miner.setEtherbase API to change the coinbase, it will
likely cause the Merkle Patricia Trie to be abnormal, thus packing the wrong block in
consortium V1.


Figure 8 Source code of _validateState_ method


Figure 9 bad block


**Recommendations** It is recommended to disable miner.setEtherbase API in source code.

**Status** Acknowledged. According to the description of the project party, the namespace
"miner" is used for administration configuration, so the project party don't enable
methods in that namespace by default. Moreover, on validator nodes, http RPC is
bound to 127.0.0.1 only. And the vulnerability does not exist when using consortium
V2.


9


Ronin Network Security Audit

##### **Findings for Consensus Contracts**


**Index** **Risk description** **Severity level** **Status**

<u>DPoS Smart Contracts-1</u> <u>Wrong use of _candidates as current validator</u> **<u>High</u>** <u>Fixed</u>

<u>DPoS Smart Contracts-2</u> <u>Credit score update exception</u> **<u>Medium</u>** <u>Fixed</u>

<u>DPoS Smart Contracts-3</u> <u>Will cause the validator to exit unexpectedly</u> **<u>Medium</u>** <u>Fixed</u>

<u>DPoS Smart Contracts-4</u> <u>The proposal vote will result in defeat</u> **<u>Low</u>** <u>Fixed</u>

<u>DPoS Smart Contracts-5</u> <u>Parameter assignment error</u> **<u>Low</u>** <u>Fixed</u>

_SlashDoubleSign_ function call is not
DPoS Smart Contracts-6 **Low** Fixed

<u>implemented</u>

<u>DPoS Smart Contracts-7</u> <u>Redundant codes</u> **<u>Info</u>** <u>Fixed</u>

DPoS Smart Contracts-8 <sup>The_</sup> <sup>_updateTrustedOrganization_</sup> <sup>function is not</sup> **Info** Fixed

designed properly


10


Ronin Network Security Audit

###### **Finding Details:**

**[DPoS Smart Contracts-1] Wrong use of _candidates as current validator**


**Severity Level** **High**


**Type** Business Security


**Lines** ronin/validator/CoinbaseExecution.sol #L445


**Description** The incorrect use of _candidates in the __revampRoles_ function of the
CoinbaseExecution contract to get the value of __maintainedList_ will result in a
possible exception in data processing.


Figure 10 Source code of __revampRoles_ function (Unfixed)


**Recommendations** It is recommended to change _candidates to _currentValidators.


**Status** Fixed. See the PR for the fix details: https://github.com/axieinfinity/ronin-dposcontracts/pull/171


<u>Figure 11 Source code of</u> _<u>_revampRoles</u>_ <u>function (Fixed)</u>


11


Ronin Network Security Audit


**[DPoS Smart Contracts-2] Credit score update exception**


**Severity Level** **Medium**


**Type** Business Security


**Lines** ronin/validator/CoinbaseExecution.sol #L108


**Description** When the _wrapUpEpoch_ function is triggered at the end of the period, it will first
update __currentPeriodStartAtBlock_ to _block.number+1_, which will affect the
_updateCreditScores_ function from getting __periodStartAtBlock_ to get
currentPeriodStartAtBlock is _block.number+1_, which causes the _maintaineds status
of all __validators_ in _checkManyMaintainedInBlockRange_ to return a value of false,
and the __maintaineds_ status of all __validators_ in
_checkManyMaintainedInBlockRange_ to return a value of false when performing the
judgment ( __ isJailedInPeriod || _isMaintainingInPeriod_ ) will increase the value of
__actualGain_ even if the __validators_ are in the maintained state.


Figure 12 Source code of _wrapUpEpoch_ function (Unfixed)


**Recommendations** It is recommended to put the _currentPeriodStartAtBlock update after
updateCreditScores.


**Status** Fixed. See the PR for the fix details: https://github.com/axieinfinity/ronin-dposcontracts/pull/172


<u>Figure 13 Source code of</u> _<u>wrapUpEpoch</u>_ <u>function (Fixed)</u>


12


Ronin Network Security Audit


**[DPoS Smart Contracts-3] Will cause the validator to exit unexpectedly**


**Severity Level** **Medium**


**Type** Business Security


**Lines** ronin/validator/CoinbaseExecution.sol #L403-428


**Description** The __setNewValidatorSet_ function of the CoinbaseExecution contract is not designed
properly and will result in the validator's EnumFlags.ValidatorFlag. As an example,
when the validator of the previous round is [A,B,C,D] and the new round is

[A,C,B,D], when setting validator B, it will clear the _validatorMap of validator C,
which will cause validator C to exit.


Figure 14 Source code of __setNewValidatorSet_ function (Unfixed)


It is recommended to remove the validator information of the previous round and
**Recommendations**
then update the validator information of this round.


Fixed. See the PR for the fix details: https://github.com/axieinfinity/ronin-dpos**Status**
contracts/pull/182


13


Ronin Network Security Audit


<u>Figure 15 Source code of_</u> _<u>setNewValidatorSet</u>_ <u>function (Fixed)</u>


14


Ronin Network Security Audit


**[DPoS Smart Contracts-4] The proposal vote will result in defeat**


**Severity Level** **Low**


**Type** Business Security


**Lines** ronin/extensions/sequential-governance/CoreGovernance.sol #L118


**Description** In the _proposal_ function of the RoninGovernanceAdmin contract, when the
Governor submits a proposal, the nonce is added to 1. But in the
__createVotingRound_ function it can lead to a situation where _round is not equal to
nonce. When the return value of _latestProposalVote is true (the case of an expired
proposal), this time the proposal will overwrite the previous one. Since round is not
equal to nonce, it can lead to a situation where the user fails to vote on the proposal,
and since the proposal is serial (this proposal ends before the proposal can be
initiated), it will result in the inability to perform another proposal vote.


<u>Figure 16 Source code of</u> _<u>_proposeProposal</u>_ <u>function (Unfixed)</u>

**Recommendations** It is recommended that nonce and _round be consistent.


**Status** Fixed. See the PR for the fix details: https://github.com/axieinfinity/ronin-dposcontracts/pull/167.


Figure 17 Source code of __proposeProposal_ function (Fixed)


15


Ronin Network Security Audit


**[DPoS Smart Contracts-5] Parameter assignment error**


**Severity Level** **Low**


**Type** Business Security


**Lines** ronin/slash-indicator/SlashBridgeVoting.sol #131-132


**Description** In the __setBridgeVotingSlashingConfigs_ function in the SlashBridgeVoting contract,
the __slashAmount_ parameter and the __bridgeVotingSlashAmount_ parameter are in the
wrong place, which will cause the __bridgeVotingSlashAmount_ cannot be assigned a
value.


Figure 18 Source code of __setBridgeVotingSlashingConfigs_ function (Unfixed)


**Recommendations** It is recommended to replace the parameter positions in the function.


**Status** Fixed. See the PR for the fix details: https://github.com/axieinfinity/ronin-dposcontracts/pull/179


Figure 19 Source code of _setBridgeVotingSlashingConfigs_ function (Fixed)


16


Ronin Network Security Audit


**[DPoS Smart Contracts-6]** **_SlashDoubleSign_** **function call is not implemented**


**Severity Level** **Low**


**Type** Business Security


**Lines** ronin/slash-indicator/SlashDoubleSign.sol #29


**Description** The _SlashDoubleSign_ function is used to punish Double-sign in the contract, but this
function is not called in consortiumV2. According to the project party: The double
sign function is intended to be called manually by anyone who has the proof of
double sign attack, but as the source code shows, it can only be called through the
coinbase account, which is not the intended design.


Figure 20 Source code of _SlashDoubleSign_ function (Unfixed)


**Recommendations** It is recommended to remove redundant code for related functions.


**Status** Fixed. The _SlashDoubleSign_ function has added admin permission and added penalty
status records.

See the PR for the fix details: https://github.com/axieinfinity/ronin-dposcontracts/pull/180


Figure 21 Source code of _SlashDoubleSign_ function (fixed)


17


Ronin Network Security Audit


**[DPoS Smart Contracts-7] Redundant codes**


**Severity Level** **Info**


**Type** Coding Conventions


**Lines** ronin/BridgeTracking.sol #L205-208


**Description** The __trySyncPeriodStats_ function in the BridgeTracking.sol contract has redundant
code. In the function of the if block __validatorContract_ .
_TryGetPeriodOfEpoch_ ( __temporaryStats. LastEpoch + 1_ ) return _filled variable
value is always true. Since __temporaryStats.lastEpoch < _currentEpoch_ to enter the
if block, when executing _tryGetPeriodOfEpoch(_temporaryStats.lastEpoch+1)_ in the
if block, Since __epoch <= epochOf(block.number)_ is always true, the value returned
is always true.


Figure 22 Source code of __trySyncPeriodStats_ function (Unfixed)


**Recommendations** It is recommended to remove redundant code for related functions.


**Status** Fixed. See the PR for the fix details: https://github.com/axieinfinity/ronin-dposcontracts/pull/170


<u>Figure 23 Source code of</u> _<u>_tryGetPeriodOfEpoch</u>_ <u>function (Fixed)</u>


18


Ronin Network Security Audit


**[DPoS Smart Contracts-8] The** **__updateTrustedOrganization_** **function is not**

**designed properly**


**Severity Level** **Info**


**Type** Business Security


**Lines** src\registries\NodeOperatorRegistry.sol #L172-178


**Description** In the __addTrustedOrganization_ function of the RoninTrustedOrganization contract,
when setting the address, it is required that the consensusAddr, governor and
bridgeVoter addresses cannot be the same, but when calling the
__updateTrustedOrganization_ function to update, it does not check that the
consensusAddr, governor and bridgeVoter addresses cannot be the same. In the
_updateTrustedOrganization_ function, there is no check that the consensusAddr,
governor and bridgeVoter addresses cannot be the same, so you can set all three
addresses to be the same by using the __updateTrustedOrganization_ function.


Figure 24 Source code of _ _updateTrustedOrganization_ function (Unfixed)


**Recommendations** It is recommended to add the same address check.


**Status** Fixed. See the PR for the fix details: https://github.com/axieinfinity/ronin-dposcontracts/pull/174


19


Ronin Network Security Audit


Figure 25 Source code of _ _updateTrustedOrganization_ function (Fixed)


20


Ronin Network Security Audit

##### **Blockchain Audit Contents**

The Ronin is a modular and extensible framework for building Ethereum-compatible blockchain networks and

general scaling solutions.


**JSON RPC**


**Block Chain**


**State**


**Consensus**


**Sync**


**Libp2p**


Figure 26 The Ronin overall framework
**1 JSON RPC Security Audit**


**1.1 JSON RPC Introduction**


RPC provides a way to access the exported objects through the grid or other I/O connections. RPC serializes

the methods and parameters to be called and transmits them to the other side through TCP/UDP protocol, and

the other side deserializes them to find the methods and parameters to be called, and then serializes the return

values to return. After creating the RPC service, the object can be registered to the service to make it

accessible to the outside. The export method according to this specific way is called remote call, which also

supports the publish/subscribe model.

When the Ronin node starts, it will pull up the JSON RPC service, register the corresponding RPC module,

and use RPC or HTTP to call the corresponding interface. The JSON RPC implemented by Ronin node is

basically the same as the RPC module commonly used in Ethereum, except that a consensus-related

consortium module is added, which includes three methods: GetSigners, GetDBValue and GetAncientValue.


21


Ronin Network Security Audit


Figure 27 JSON RPC consortium module

The consensus mechanism used in this audit contains three interfaces: GetSigners, GetDBValue and

GetAncientValue. GetSigners is used to view the validator node address set of a block. GetDBValue is used to

look up an encoded cache trie node in the database or in memory. GetAncientValue is used to retrieve an

ancient binary blob from the append-only immutable files.


**1.2 JSON RPC Processing Logic**


In Ronin node, after receiving an RPC request, the node will call the _serveSingleRequest_ function to check

the request function type, to parse the corresponding RPC request and locate the corresponding module and

function to call.


22


Ronin Network Security Audit


Figure 28 Source code of _serveSingleRequest_ function


**1.3 RPC Sensitive Interface Permission**


The vast majority of the RPC interfaces currently provided by Ronin node are for querying data, and there are

no high authority interfaces.


**1.4 CLI Commands Security Audit**


The Ronin's CLI is mainly for nodes to perform related configurations, and its corresponding parameters are

as follows:


Figure 29 The Ronin node command line parameters


After testing, the relevant commands in the CLI meet the audit requirements and there is no security risk.


23


Ronin Network Security Audit


**1.5 Node Account Unlocking Security Audit**


Ronin uses the DPoS consensus. The DPoS consensus requires that the coinbase account of the node must be

unlocked after it is activated, otherwise it will not be able to generate blocks. There is a potential risk here,

that is, if the node opens the RPC interface to the public network, any user connected to the node can operate

the node's coinbase, which may cause the node to crash when running the consortium V1 consensus. But

according to the project party, this interface is only open to 127.0.0.1.


In theory, unlocked accounts have the above-mentioned risks on open JSON-RPC nodes (users cannot

confirm whether their API is used by hackers to sign raw data, unless the log is turned on). Therefore, it is

recommended to close the sensitive RPC or only open it to the whitelist addresses when the node is online.


24


Ronin Network Security Audit


**2 Node Security**


**2.1 Number of Node Connections**


The Ronin nodes can use the networking module to set parameters at startup, where --maxpeers limit the

number of links to the node, and if the number of links exceeds the specified value, no links will be made.


Figure 30 Node start-up parameters

After testing, the Ronin nodes can limit the number of connections to the current node using the server

parameter (which defaults even if not specified), which can prevent the node from having too many

connections.


Figure 31 Node connection information


**2.2 Packet Size Limit**


As shown in the figure below, the size of the data is checked when a transaction is received, which can avoid

DoS attacks on nodes.


25


Ronin Network Security Audit


Figure 32 Source code for the _validateTX_ function


**2.3 Node Network Access Restrictions**


Network parameters can be set when the node starts the chain, which can protect the node from attacks to

some extent.


Figure 33 The networking module parameters


26


Ronin Network Security Audit


**3 Account &Asset Security**


**3.1 Account Model**


The Ronin node uses a same account model with Ethereum, with the following basic data structure:


Figure 34 Source code of the data structure of Account


 Nonce: The serial number of the transaction sent by the account;


 Balance: The balance of the account's platform coins;


 Root: The root hash []byte of the storage state tree;


 CodeHash: The EVM code bound to the account;


**3.2 Account Generation**


(1) externally owned account


The Ronin use Ethereum way to create external accounts


Through the RPC module personal to create an account interface: NewAccount


Figure 35 Source code of the _NewAccount_ function


27


Ronin Network Security Audit


This interface will call the NewAccount function in accounts/keystore/keystore.go to generate an account and

return the account address.


Figure 36 Source code of the _NewAccount_ function

The NewAccount function in keystore.go will actually call the storeNewKey function in the

accounts/keystore/key.go file to create an account, generate a public and private key, and store the created

account in the cache.


Figure 37 Source code of the _storeNewKey_ function and _newKey_ function

The storeNewKey function calls the newKey function to generate a complete key instance (including the

account public and private key and account address), and calls the StoreKey function to write the generated

account file to the local for persistent storage.


28


Ronin Network Security Audit


Figure 38 Source code of the _GenerateKey_ function

The _newKey_ function will call _GenerateKey_ function to generate the public and private keys.


Figure 39 Source code of the _GnewkeyFromECDSA_ function

Then pass the private key into the _newKeyFromECDSA_ function, and then call the _PubkeyToAddress_ function

in the crypto/crypto.go file to calculate the account address according to the public key, thus generating a

complete key instance.


Figure 40 Source code of the _PubkeyToAddress_ function


(2) contract account


Ronin node supports Ethereum Create and Create2 instructions to create contract accounts.


29


Ronin Network Security Audit


Figure 41 Source code of the _Create_ function and _Create2_ function


**3.3 Transaction Signature**


First call the _SignTx_ function in the accounts/keystore/keystore/wallet.go file to check whether the account is

unlocked.


Figure 42 Source code of the _SignTx_ function

If it is confirmed that the account is valid, call the _SignTx_ function in the accounts/keystore/keystore.go file to

sign.


Figure 43 Source code of the _SignTx_ function

Because the chainID is not empty, in order to prevent repeated attacks across chains, EIP155Signer is selected

as the signer and the _SignTx_ function in core/types/transaction_signing.go is called to complete the transaction

signature.


30


Ronin Network Security Audit


Figure 44 Source code of the _SignTx_ function


Figure 45 Source code of the _NewEIP155Signer_ function


**3.4 Asset Security**


(1) Platform Asset Security


After a comprehensive audit, it can be confirmed that when running the DPoS (consortium V2) consensus,

no new Ronin native tokens will be generated when validator nodes package blocks (call

_FinalizeAndAssemble_ function). This means that all native tokens have been fully pre-mined, and no new

native tokens will be generated afterwards.


31


Ronin Network Security Audit


Figure 46 Source code of the _FinalizeAndAssemble_ function


(2) Contract Asset Security


The Ronin supports EVM in order to be compatible with Ether, and the contracts on it are not upgradable or

modifiable.


32


Ronin Network Security Audit


**4 Consensus Security**


To increase the degree of decentralization of Ronin, Ronin uses Proof of Stake Authority (PoSA) instead of

PoA. Proof of Stake Authority is a combination of delegated Proof of Stake (DPoS) and PoA, specifically

divided into two parts:

1. Token holders use their shares to vote and elect a set of validators (DPoS main logic).

2. Validators take turns to produce blocks in a PoA manner, similar to Ethereum's Clique consensus design.

In DoPS, all token holders can register as validator candidates. They can also act as delegators by staking

tokens to validator candidates. Validator and delegator stakes are updated at the start of each day. Afterwards,

the Ronin network will select a group of 21 validators (including 11 trusted organizations and 10 most staked

token holders). However, during the day, some validators may be (temporarily) removed from the validator set

(for punishment, the part is maintained by the Slash contract, they may be in jail or in maintenance mode).

These changes will be updated every epoch (consisting of 200 blocks ~ 10 minutes).

Furthermore, while increasing the decentralization of the system, the validator selection process through

staking introduces new attack vectors. An attacker who controls more than 51% of the coins can take over the

blockchain.

To prevent such attacks, the Ronin Network relies on a group of 11 trusted organizations selected by the

community and Sky Mavis. Since trusted organizations occupy 11/21 of the validator set, an attacker cannot

control the majority of validators and take over the blockchain.

In PoA, one of the sorted validator sets (updated once per epoch) will be responsible for packaging a certain

block, and the block will not include block rewards (the rewards are allocated by the consensus contract).

In summary, the logical framework of Ronin consensus processing can refer to the following figure:


Figure 47 Consensus Framework


33


Ronin Network Security Audit


**4.1 DPoS Consensus Process Analysis**


The DPoS algorithm is divided into two parts: electing a group of block producers and scheduling production.

The election process makes sure that stakeholders are ultimately in control because stakeholders lose the

most when the network does not operate smoothly. How people are elected has little impact on how

consensus is achieved on a minute by minute basis.


To help explain this algorithm, assume 3 block producers, A, B, and C. Because consensus requires 2/3 + 1

to resolve all cases, this simplified model will assume that producer C is deemed the tie breaker. In the real

world there would be 21 or more block producers. Like proof of work, the general rule is that longest chain

wins. Any time an honest peer sees a valid strictly longer chain it will switch from its current fork to the

longer one.


 **Normal Operation**


Under normal operation block producers take turns producing a block every 3 seconds. Assuming no one

misses their turn then this will produce the longest possible chain. It is invalid for a block producer to

produce a block at any other time slot than the one they are scheduled for.


**4.2 PoA Consensus Process Analysis**


In the PoA consensus preparation phase, the Ronin Consortium V2 consensus engine will obtain the set of

block validators of the current epoch from the consensus contract (DPoS consensus phase) at the beginning of

each epoch, and sort them according to the size of the set addresses. Then convert the sorted validator set into

bytecode and fill it into the extra field of the block header, so that all Ronin nodes can read the validator set

and package the verification block sequence. In each epoch, there are multiple periods of packaging blocks,

and each cycle is trained by a set of validators to produce blocks. When there is a block timeout, repeating the

current block generation and nodes submitting malicious system transactions, the validators will be punished

(see the Slashing Logic Implementation chapter for details).


**Epoch X**


**A** **B** **C** **A** **B** **C** **A** **B** **C**

**<u>Blockchain</u>**

**Period 1** **Period 2** **Period X**


Figure 48 Pack blocks in an epoch


34


Ronin Network Security Audit


**4.3 Logic Implementation of DPoS**


The DPoS consensus contract engine in Ronin is realized through the system contract and the precompiled

contract. The system contract is used to manage validators and candidates; the precompiled contract is used to

sort the candidates of the system contract and select effective validators.

After Ronin runs, if the current block is the last block before the end of this epoch, its block builder will call

the wrapUpEpoch function of the system contract validatorSet to wrap the relevant data of the epoch. This

operation will check the status of all validators in this period, and update the valid validators for the next

epoch (by means of permission replacement). If the current block is still the last block before the end of this

period, the wrap content also includes:

1. Settle the bridge operating reward of each validator.

2. Submit bridge operating reward and mining reward.

3. Update the delegating rewards and send the rewards to the system contract staking.

4. recycle the locked funds from emergency exit requests.

5. Disposal of discarded rewards.

6. Update the credit scores of each validator.

7. Update the validators set.

Among them, when updating the validator list, the system contract validatorSet will send the current candidate

list, its corresponding pledge amount and trusted weight as parameters to the precompile contract Precompile

Pick Validator Set for sorting; in the precompile contract Precompile Pick Validator Set, will first sort these

candidates according to their pledge amount, and then directly add the candidates whose trusted weight is

greater than 0 to the front of the sorted candidate list to determine the valid validator for this period; finally,

return the sorted validators to the system contract The wrapUpEpoch function updates records.


35


Ronin Network Security Audit



**Precompile Pick**

**Validator Set**



**Trusted Organization**



**New Validator** **Pick Validator Set**


**<u>Get Trusted Weight</u>** **<u>Get Staking Amount</u>**



**Ronin Validator Set** **Staking Contract**
**Contract**



**Validator Trusted**



**Validator Staking**



**Weight**



**Weight**



**Wrap up Period**


**Block**
**Producer**


Figure 49 DPoS


**4.4 Logic Implementation of PoA**


The Ronin PoA consensus logic is mainly divided into three parts:

1. Initialize the consensus engine

2. Complete system transactions and assemble blocks.

3. Verify that other nodes produce blocks legally.

During the start-up phase of the Consortium V2 consensus engine, the Ronin node will call the _Prepare_

method to prepare all consensus fields in the block header so that transactions can be run on top. The _Prepare_

method first initializes the consensus contract, and then queries the validator nodes and fills its order into the

block header when it is judged that each Epoch starts.


36


Ronin Network Security Audit


Figure 50 _Prepare_ method

The Ronin node will start the miner network and call the FinalizeAndAssemble method to execute the system

transaction, then determine whether the uncle block exists when the consensus is running to generate blocks.

The processSystemTransactions method is called to process the system transaction, it will check whether the

previous verifier has completed the operation of packing the block. If not, the Slash consensus contract will be

called to punish, and then the SubmitBlockReward function of the consensus contract will be called to submit

the transaction fee as a reward. Finally, at the end of each Epoch, the WrapUpEpoch method of the consensus

contract is called to update the validator set.


37


Ronin Network Security Audit



Figure 51 FinalizeAndAssemble method


38


Ronin Network Security Audit


Figure 52 processSystemTransactions method

In the verification phase, other nodes will call the Finalize method to repeatedly verify whether the system

transaction is legal, and finally insert the block into the database.


Figure 53 _Finalize_ method


39


Ronin Network Security Audit


**4.4 Rewards for Building Blocks**


In Ronin, miner reward is divided into main chain miner reward and side chain miner reward. First, the

algorithm calculates the minerReward of each block through the Period and initSignerBlockReward set in the

config, then calculates the miner reward of the side chain and uses the minerReward to issue it. The remaining

minerReward will then pay the Gas-related Refund. Finally, all the remaining rewards are distributed to the

miners corresponding to the blocks.


Figure 54 Calculate miner rewards


Figure 55 Calculate left miner rewards


**4.4 Slashing Logic Implementation**


In the DPoS system, in order to make validators more actively participate in the system and decentralize to a

certain extent, when validators do not provide good services for the Ronin network or have malicious and

negative behaviors, they will be cut. And in the slash contract, a reduction method for validators and bridge

operators is designed, mainly for punishment in terms of rewards and jail time. The following figure shows

the slash interaction process:


40


**updateCreditScores**


**RoninValidators** **Endperiod**



**Slash Contract**



Ronin Network Security Audit


**slashDoubleSign**


**Jail**


**Bailout**



**SlashBridge Voting** **slashUnavailability**


Figure 56 Slashing Logic

As shown in the figure above, at the end of the period, the RoninValidatorSet.wrapUpEpoch() function will

update the credit score and judge the maintenance status, and also interact with the slash contract. If it is in jail,

it will not be able to become a validator, which will affect the new The setting of the Validator set and the

distribution of rewards.

In terms of bridge operators, when the period ends, the

__updateValidatorRewardBaseOnBridgeOperatingPerformance_ function will update the proportion of votes. If

the bridge operator does not provide enough signatures, then two penalties (slash) will be imposed according

to the number of votes at fault of the bridge operator:

1. If the number of votes obtained by bridge operators is less than the _ratioTier1 (10% on the white paper)

threshold, the bridge rewards for the current period of the operators will be cut.

2. If the number of votes obtained by bridge operators is less than the threshold of _ratioTier2 (20% on the

white paper), then (s)he's bridge rewards and mining rewards will be cut and the jail time will be increased (2

days on the white paper ), while increasing the same amount of time so that the verifier cannot bail himself out

by deducting the credit score through the BailOut function, so as to encourage the verifier to get enough votes

and actively participate.


Figure 57 _ _updateValidatorRewardBaseOnBridgeOperatingPerformance_ function


41


Ronin Network Security Audit


Since the PoA consensus is used for block generation, it is quite a serious error when a validator signs more

than one block with the same height. After verifying the double-signed malicious behavior, in the

slashDoubleSign function, the malicious violating verifier will be directly punished with an amount of

_slashDoubleSignAmount of funds, and the jail time of _doubleSigningJailUntilBlock will be increased. The

current punishment is considered to be released on bail of.


Figure 58 slashDoubleSign function (unfixed)

In terms of block generation, the performance of Ronin nodes depends on everyone in the validator set

producing blocks in time when it is their turn. If validators miss the opportunity to create blocks, it will

damage the performance of the system. Therefore, Ronin introduces an unavailable slashing logic to penalize

validators who miss too many blocks.

In the function slashUnavailability, the number of blocks _count missed by the verifier will be recorded.

When _count reaches _unavailabilityTier1Threshol(50 on the white paper) and triggers the threshold, the

rewards of the current period will be penalized. If it reaches _count_unavailabilityTier2Threshold(150 on the

white paper paper) and the threshold is triggered, the rewards of the current cycle will be confiscated, the

amount of _slashAmountForUnavailabilityTier2Threshold (10,000 RON on the white paper) will be deducted,

and the jail time of _jailDurationForUnavailabilityTier2Threshold (2 days on the white paper) will be

increased. If a verifier triggers Tier1 in the current cycle and uses credit score to bail himself out, triggers

Tier1 again, then the verifier will be penalized at Tier2 level and cannot use credit score to bail.


42


Ronin Network Security Audit


Then the trusted organization has not voted for the bridge operator for more than _bridgeVotingThreshold(3

days on the white paper) time threshold, then the slashBridgeVoting function will be called to confiscate the

corresponding node number is _bridgeVotingSlashAmount(10,000 RON on the white paper) funds.


When updating a candidate node, if the candidate has not become a validator node, then he will reset the credit

score in the execResetCreditScores function after the update.


In the bailOut function, each validator can hold a maximum credit score of maxCreditScore. The credit score

spent on bail is multiplied by the remaining jailed time with bailOutCostMultiplier as the basic unit. The less

the remaining jailed time, the less credits will be spent.


43


Ronin Network Security Audit


Figure 59 bailOut function

The gainCreditScores function is used to update the score, when the validator is in jail or is executing the

maintenance plan, the score will not be awarded.


44


Ronin Network Security Audit


**5 Transaction Model Security**


**5.1 Transaction Processing Flow**


Ronin's transaction processing is divided into two main parts: adding the transaction to the pool and executing

the transaction. Adding a transaction to the pool means that each node adds the submitted transaction to the

pool. As shown in the figure below, Ronin will perform the following checks on the transaction.

 Data size must be < 128KB

 Transaction amount must be non-negative (>=0)

 Ensure the transaction doesn't exceed the current block limit gas

 The signature data must be valid and the sender address can be resolved

 Gas price required to be transaction is not greater than the Gas price of the pool

 The nonce value of the transaction must be higher than the nonce value of the account on the current

chain (lower than that means the transaction has been packaged)

 Current account balance must be greater than "Transaction Amount"

 Trading GAS requirements cannot be less than the specified quantity


45


Ronin Network Security Audit


Figure 60 Partial source code of transaction check


**5.2 Transaction replay audit**


Replay attack refers to when the blockchain is hard-forked, the blockchain has a permanent difference and

produces two historical transactions, on the exact corresponding chains, with differences such as address,

private key, and balance, in which the same transaction can take effect at the same time on the two chains.


After testing, the trades on the Ronin chain (including EVM transactions) cannot be replayed, and during the

transaction when adding to transaction pool, validity is verified, while illegal transactions are rejected because

the transaction data format does not match; Chains with substrate frameworks can also fail transactions

because of differences in chain ids. Therefore, it is recommended that the project developer pay close attention

to chain id to avoid duplicate ids for the same type of chain.


46


Ronin Network Security Audit


**5.3 Dusting Attack**


The dusting attack is when an attacker sends a very small amount of tokens, called "dust", to a user's wallet.

By tracking the dusted wallet funds and all transactions, the attacker can then connect to these addresses and

determine the company or person to whom these wallet addresses belong, destroying the anonymity of the

block chain; or misuse the block chain resources, causing the block chain memory pool strain. If the dust

money is not moved, the attacker cannot establish a connection to it and cannot complete the de
anonymization of the wallet or address owners.

The Ronin chain is based on the account model, so dust attacks are not considered.


**5.4 Trading Flooding Attacks**


In Ronin, transactions are subject to a fee. The base fee for creating a contract is 53,000, and the base fee for a

normal transaction is 21,000.


Figure 61 `T` ransactions minimum gas consumption

However, it is worth mentioning that gasprice is set by the super node and if it is 0, it will lead to trading

flooding attacks.


Figure 62 Screenshot of the node start command


**5.5 Double-spending Attack**


For Ronin's transactions, each transaction of the account contains a unique and mintable nonce, and Ronin

uses the consensus model of PoSA, it is also difficult to complete a double-spending through a 51% attack.


**5.6 Illegal Transactions**


The user will sign the entire transaction data when initiating a transaction, and any changes to the data in the

transaction will cause the Ronin node to fail the signature check.


47


Ronin Network Security Audit


Figure 63 Transaction signature check(1/2)


Figure 64 Transaction signature check(2/2)

If the Ronin node is malicious, the signature checks fails here, but the verification node also checks the

transaction signature again, and the forged transaction will fail to be verified.


**5.7 Fake Deposit Attack**


Fake recharge attack is the transaction execution failure, but the corresponding receipt status shows success.

In Ronin, there are only two types of transaction status, Failed(0x0) and Success(0x1). For transactions that


48


Ronin Network Security Audit


pass the check, both gas exceeds the block limit and transaction execution fails will return failed, and there is

no chain-level fake deposit attack.


Figure 65 Transaction receipt information(1/2)


Figure 66 Transaction receipt information(2/2)


**5.8 Contract trading security**


Ronin is compatible with EVM transactions. Our team tested various types of EVM contract transactions on

the Ronin chain and found that Ethereum contract transactions have no security issues and can run on the

Ronin chain.


49


Ronin Network Security Audit


**6 Cross-chain Bridge Security**


The Ronin cross-chain bridge contract allows users to transfer assets between Ronin Network and other EVM

blockchains. When a deposit event occurs on the main chain, the Bridge component in each validator node

will receive it and forward it to Ronin by sending the corresponding transaction. For withdrawals and

governance events, it will start on Ronin and then relay on other chains. After auditing, no security issues

were found in the cross-chain bridge contract.


**6.1 Deposit Feature of Cross-Chain Bridge**


Users can top up ETH, ERC20 and ERC721 (NFT) by sending transactions to MainchainGatewayV2 on the

main chain and waiting for Ronin to verify the deposit. The verifier will listen to the DepositRequested event

on the main chain, and then vote and recharge on Ronin. Before the deposit happens, the gateway should

establish a mapping between Ethereum and the token contract on Ronin. For deposits, there is no limit to the

amount deposited.


The specific process of deposit is as follows:

(1) The user deposits funds to MainchainGatewayV2 on Mainchain and triggers the DepositRequested event.

(2) The bridge relay listens to the DepositRequested event and forwards the deposit request in the

DepositRequested event to the RoninGatewayV2 contract on the Ronin chain.

(3) Bridge validators on the Ronin chain vote on deposit requests.

(4) When the vote is passed, transfer the voucher token corresponding to the deposit funds to the user's

address on the Ronin chain.


**6.2 Withdrawal Feature of Cross-Chain Bridge**


Users can send transactions to the RoninGatewayV2 contract on the Ronin chain and wait for validators on the

Ronin chain to vote and sign. After the signature is passed, the user can withdraw money on the main chain

with the corresponding signature. It should be noted that, unlike deposits, there are restrictions on the

withdrawal amount when making withdrawals in Ronin. The specific restrictions are as follows:


Figure 67 Withdrawal Limit


50


Ronin Network Security Audit


The specific process of withdrawal is as follows:

(1) The user deposits funds to the RoninGatewayV2 on Ronin and triggers the WithdrawalRequested event.

(2) The bridge worker monitors the WithdrawalRequested event and signs the withdrawn

WithdrawalRequested event.

(3) The user collects the corresponding signatures of the WithdrawalRequested event, and takes these

signatures and corresponding withdrawal information to Mainchain for withdrawal.

(4) When withdrawing money, the signature will be verified, and the withdrawal amount will also be judged;

if the signature is correct and the withdrawal amount meets the conditions, the corresponding deposit funds

will be transferred to the user's address on the Mainchain chain and the withdrawal will be triggered Withdraw

event.

(5) After the verifiers on the Ronin chain listen to the Withdraw event, they will vote on the Withdraw event.

If the vote is passed, it means that the withdrawal event has been successfully confirmed on the Ronin chain.

so far, the entire withdrawal process is over.


**6.3 Migration Feature of Cross-Chain Bridge**


When the funds in MainchainGatewayV2 on the Mainchain chain need to be migrated, the migrator will call

the migration function on the Ronin chain to migrate funds.


51


Ronin Network Security Audit

##### **Historical Vulnerability Detection**

Ronin is a fork of Go-Ethereum Ver.1.10.13 from over 2 years ago. Through this audit, it was found that there

were vulnerabilities that are the same as those in the historical version of Go-Ethereum. While development of

Ronin has diverged from Ethereum, it is still highly recommended that the project party continue to place

enough security resources to continuously check and fix the existence of vulnerabilities and issues that have

been exposed by Ethereum to prevent damage to Ronin nodes.


52


Ronin Network Security Audit

##### **Consensus Contracts Audit Categories**


**No.** **Categories** **Subitems**


Compiler Version Security


Deprecated Items



1 Coding Conventions


2 General Vulnerability


3 Business Security



Redundant Code


require/assert Usage


Gas Consumption


Integer Overflow/Underflow


Reentrancy


Pseudo-random Number Generator (PRNG)


Transaction-Ordering Dependence


DoS (Denial of Service)


Function Call Permissions


call/delegatecall Security


Returned Value Security


tx.origin Usage


Replay Attack


Overriding Variables


Third-party Protocol Interface Consistency


Business Logics


Business Implementations


Manipulable Token Price


Centralized Asset Control


Asset Tradability


Arbitrage Attack



Beosin classified the security issues of smart contracts into three categories: Coding Conventions, General

Vulnerability, Business Security. Their specific definitions are as follows:


 **Coding Conventions**


53


Ronin Network Security Audit


Audit whether smart contracts follow recommended language security coding practices. For example,

smart contracts developed in Solidity language should fix the compiler version and do not use

deprecated keywords.

 **General Vulnerability**

General Vulnerability include some common vulnerabilities that may appear in smart contract

projects. These vulnerabilities are mainly related to the characteristics of the smart contract itself,

such as integer overflow/underflow and denial of service attacks.

 **Business Security**

Business security is mainly related to some issues related to the business realized by each project,

and has a relatively strong pertinence. For example, whether the lock-up plan in the code match the

white paper, or the flash loan attack caused by the incorrect setting of the price acquisition oracle.

*Note that the project may suffer stake losses due to the integrated third-party protocol. This is not something Beosin can control.

Business security requires the participation of the project party. The project party and users need to stay vigilant at all times.


54


Ronin Network Security Audit

##### **Appendix**


**1.1 Vulnerability Assessment Metrics and Status in Smart Contracts**


**1.1.1 Metrics**


In order to objectively assess the severity level of vulnerabilities in blockchain systems, this report

provides detailed assessment metrics for security vulnerabilities in smart contracts with reference to

CVSS 3.1 (Common Vulnerability Scoring System Ver 3.1).


According to the severity level of vulnerability, the vulnerabilities are classified into four levels:

"critical", "high", "medium" and "low". It mainly relies on the degree of impact and likelihood of

exploitation of the vulnerability, supplemented by other comprehensive factors to determine of the

severity level.



**Impact**

**<u><mark>Likelihood</mark></u>**



**Severe** **High** **Medium** **Low**



**<u><mark>Probable</mark></u>** **<u>Critical</u>** **<u>High</u>** **<u>Medium</u>** **<u>Low</u>**

**<u><mark>Possible</mark></u>** **<u>High</u>** **<u>High</u>** **<u>Medium</u>** **<u>Low</u>**

**<u><mark>Unlikely</mark></u>** **<u>Medium</u>** **<u>Medium</u>** **<u>Low</u>** **<u>Info</u>**

**<u><mark>Rare</mark></u>** **<u>Low</u>** **<u>Low</u>** **<u>Info</u>** **<u>Info</u>**


**1.1.2 Degree of impact**


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


55


Ronin Network Security Audit


Medium impact generally refers to the vulnerability can have a relatively minor impact on the

confidentiality, integrity, availability of the smart contract or its economic model, which can cause a

small amount of economic loss to the contract business system, individual business unavailability

and other impact.


 **Low**


Low impact generally refers to the vulnerability can have a minor impact on the smart contract,

which can pose certain security threat to the contract business system and needs to be improved.

**3.1.4 Likelihood of Exploitation**


 **Probable**


Probable likelihood generally means that the cost required to exploit the vulnerability is low, with no

special exploitation threshold, and the vulnerability can be triggered consistently.


 **Possible**


Possible likelihood generally means that exploiting such vulnerability requires a certain cost, or there

are certain conditions for exploitation, and the vulnerability is not easily and consistently triggered.


 **Unlikely**


Unlikely likelihood generally means that the vulnerability requires a high cost, or the exploitation

conditions are very demanding and the vulnerability is highly difficult to trigger.


 **Rare**


Rare likelihood generally means that the vulnerability requires an extremely high cost or the

conditions for exploitation are extremely difficult to achieve.

**1.1.5 Fix Results Status**


**Status** **Description**


**Fixed** The project party fully fixes a vulnerability.


**Partially Fixed** The project party did not fully fix the issue, but only mitigated the issue.


**Acknowledged** The project party confirms and chooses to ignore the issue.


56


Ronin Network Security Audit


**1.2 Disclaimer**


The Audit Report issued by Beosin is related to the services agreed in the relevant service agreement. The

Project Party or the Served Party (hereinafter referred to as the "Served Party") can only be used within the

conditions and scope agreed in the service agreement. Other third parties shall not transmit, disclose, quote,

rely on or tamper with the Audit Report issued for any purpose.

The Audit Report issued by Beosin is made solely for the code, and any description, expression or wording

contained therein shall not be interpreted as affirmation or confirmation of the project, nor shall any warranty

or guarantee be given as to the absolute flawlessness of the code analyzed, the code team, the business model

or legal compliance.

The Audit Report issued by Beosin is only based on the code provided by the Served Party and the technology

currently available to Beosin. However, due to the technical limitations of any organization, and in the event

that the code provided by the Served Party is missing information, tampered with, deleted, hidden or

subsequently altered, the audit report may still fail to fully enumerate all the risks.

The Audit Report issued by Beosin in no way provides investment advice on any project, nor should it be

utilized as investment suggestions of any type. This report represents an extensive evaluation process designed

to help our customers improve code quality while mitigating the high risks in blockchain.


57


Ronin Network Security Audit


**1.3 About Beosin**


Beosin is the first institution in the world specializing in the construction of blockchain security ecosystem.

The core team members are all professors, postdocs, PhDs, and Internet elites from world-renowned academic

institutions. Beosin has more than 20 years of research in formal verification technology, trusted computing,

mobile security and kernel security, with overseas experience in studying and collaborating in project research

at well-known universities. Through the security audit and defense deployment of more than 2,000 smart

contracts, over 50 public blockchains and wallets, and nearly 100 exchanges worldwide, Beosin has

accumulated rich experience in security attack and defense of the blockchain field, and has developed several

security products specifically for blockchain.


58


###### **Official Website**

https://www.beosin.com


###### **Telegram**

https://t.me/+dD8Bnqd133RmNWNl


###### **Twitter**

https://twitter.com/Beosin_com


###### **Email**

Contact@beosin.com


