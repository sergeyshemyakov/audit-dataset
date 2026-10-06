### | security

# **Mantle OP-Geth** **Audit**

#### **March 15, 2024**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  6

Gas on L2 6

Security Model and Privileged Roles 7


Critical Severity ____________________________________________________________________  8

C-01 Attacker Can Get Infinite BVM_ETH Tokens to Drain the Protocol 8

C-02 Wrong Cost Accounting 9

C-03 Potential Insufficient Balance for Sponsorship 9


Low Severity ____________________________________________________________________ 10

L-01 Incorrect Error Message 10

L-02 Use of Non-Granular Value for tokenRatio 10

L-03 The Light txpool Implementation Does Not Account for L1 Costs 11

L-04 Fragilely Shared Pointer 11

L-05 Misleading Documentation 12


Notes & Additional Information ____________________________________________________ 12

N-01 Code Redundancy 12

N-02 Incorrect Module Name 13

N-03 Struct Field and Tag Mismatch 13

N-04 Block Number Expiry Potentially Confusing 14

N-05 Unused Variables 14

N-06 Inexplicit Struct Declaration 14

N-07 Unclear Calldata Byte Counting 15

N-08 Todo Comments in the Code 15

N-09 Unnecessary Double Check of SponsorPercent 16

N-10 Inconsistent Naming of File 16


Conclusion ______________________________________________________________________ 17


Mantle OP-Geth Audit − Table of Contents − 2


## **Summary**

**Type** Layer 2


**Timeline** From 2024-02-09
To 2024-02-29


**Languages** Go



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



3 (3 resolved)


0 (0 resolved)


0 (0 resolved)



**Total Issues** 18 (7 resolved, 1 partially resolved)



**Low Severity Issues** 5 (2 resolved, 1 partially resolved)



**Notes & Additional**
**Information**



10 (2 resolved)



Mantle OP-Geth Audit − Summary − 3


## **Scope**

We audited the <u>[mantlenetworkio/op-geth](https://github.com/mantlenetworkio/op-geth)</u> repository at head commit <u>[4d05b2c. All files were](https://github.com/mantlenetworkio/op-geth/tree/4d05b2cd9a2b8096680eb9b2e87e473a44a43922)</u>

diff-audited against the base commit <u>[0a77db9. Any code outside of this diff was](https://github.com/mantlenetworkio/op-geth/tree/0a77db9c21b01ae40bfee790274744e939517564)</u> _not_ audited.

As such, we do not guarantee the correctness of the unchanged code.


In scope were the following files:

```
op-geth
├── accounts/abi/bind/backends/simulated.go
├── beacon/engine
│  ├── gen_blockparams.go
│  └── types.go
├── cmd
│  ├── evm/internal/t8ntool/execution.go
│  └── utils/flags.go
├── consensus/misc/eip1559.go
├── core
│  ├── genesis.go
│  ├── mantle_upgrade.go
│  ├── state_prefetcher.go
│  ├── state_processor.go
│  ├── state_transition.go
│  ├── txpool/txpool.go
│  ├── types
│  │  ├── deposit_tx.go
│  │  ├── gen_receipt_json.go
│  │  ├── meta_transaction.go
│  │  ├── rollup_l1_cost.go
│  │  ├── transaction.go
│  │  └── transaction_marshalling.go
│  └── vm
│    ├── interpreter.go
│    ├── jump_table.go
│    └── runtime.go
├── eth
│  ├── api_backend.go
│  ├── backend.go
│  ├── catalyst/api.go
│  ├── ethconfig/config.go
│  ├── state_accessor.go
│  └── tracers
│    ├── api.go
│    └── internal/tracetest/calltrace_test.go
├── graphql
│  └── graphql.go
├── internal
│  └── ethapi

```

Mantle OP-Geth Audit − Scope − 4


```
│    ├── api.go
│    └── transaction_args.go
├── les/state_accessor.go
├── light/txpool.go
├── miner
│  ├── miner.go
│  ├── payload_building.go
│  └── worker.go
├── params
│  ├── config.go
│  └── protocol_params.go
└── rpc/http.go

```


Mantle OP-Geth Audit − Scope − 5


## **System Overview**

Mantle V2 is a layer 2 (L2) scaling solution for Ethereum that uses fraud proofs instead of

validity proofs for its security. The protocol aims to provide low transaction fees and high

throughput while maintaining full EVM compatibility. Mantle V2 is built on top of Ethereum

using the OP Stack and therefore shares many similarities with Optimism. This audit

particularly focuses on its L2 execution client which has been forked from Optimism's op-geth

repository. While changes have been made in order to customize the client as per Mantle's

needs, its name still remains op-geth. Therefore, in this report, the term "op-geth" will refer to

Mantle's version of op-geth, rather than Optimism's.


Mantle V1 has been running on Optimism's OVM so far. Hence, adopting the OP Stack

Bedrock version was a big transition. Other changes include EIP-1559 support, removal of

redundant components, stable block time, and block state tagging. This sets the starting point

(base commit) of the audit. While the above changes reflect Mantle's compatibility with OP

Stack Bedrock, other changes have been introduced that set Mantle apart. These distinctions

include using Mantle DA as a data availability layer, using MNT as the native L2 token instead

of ETH, native meta transactions, and the fee optimization strategy. This report specifically

focuses on the last three distinctions which are changes introduced in the head commit.

### **Gas on L2**


Due to MNT being the native token on L2, the way in which gas works can result in a slightly

different behavior than on L1. For all L2s, there are two costs that the user must pay for: the L2

execution cost and the L1 data availability cost. Therefore, the gas fee charged to the user

must cover both of these. However, the latter cost is in terms of ETH, and because MNT is the

native token on L2, users must pay their gas fees in MNT. Mantle's solution to this is to use a

<mark>`tokenRatio`</mark> in order to scale units of ETH gas to units of MNT gas. This <mark>`tokenRatio`</mark> is

defined as the price of ETH divided by the price of MNT. Thus, depending on the price of these

two assets, the amount of L2 gas the user must pay for their transaction to succeed will vary.


This contrasts with the behavior on L1, where the same transaction executed on the same

state should cost the same amount of gas. Therefore, it is possible that a user executes a

transaction with a certain gas limit on L2 and, depending on the <mark>`tokenRatio`</mark> <mark>,</mark> that

transaction may succeed or may revert due to running out of gas. To try and prevent this from


Mantle OP-Geth Audit − System Overview − 6


happening, Mantle provides a way for users to perform gas estimation and returns a 20%

buffer in its calculation to allow more room for fluctuation. Nevertheless, if ever there is a

drastic price change in one of the two assets, this scenario could occur.

### **Security Model and Privileged Roles**


The op-geth execution client relies on the appropriate configurations to be set correctly. Some

of these parameters are hardcoded into the client code itself, whereas others need to be

passed in and read. The party which feeds in these parameters is a trusted entity. In addition,

the correct configuration also includes good access control for the L1 contracts upon which

the system rests. The client also relies on information from the op-node. For example, deposit

transactions (which come from L1) are first processed by the op-node before being sent over

to op-geth. The assumption is that the op-node is processing these deposit transactions

correctly. At the moment, Mantle is a centralized system and therefore inherits all the potential

risks from being one. Furthermore, op-geth relies on some specific smart contracts on L2 for

important information such as the <mark>`tokenRatio`</mark> <mark>,</mark> the L1 <mark>`basefee`</mark> <mark>,</mark> other parameters for fee

calculation, and even the ERC-20 contract which is L2 ETH itself. Op-geth depends on the fact

that the smart contracts are working as intended.


In terms of bridging, Mantle then relies on the correctness of the implementation of its L1 and

L2 bridging contracts. What the op-geth expects needs to be aligned with the behavior of the

smart contracts. For example, if a user bridges through the L1 messenger smart contract into

an L2 account and the L2 transaction reverts, there is a chance for the funds to be stuck.

However, at the moment, this is unlikely to happen as the values are hardcoded correctly on L1

such that this would not be allowed to occur. This interplay between the L1 smart contracts

and op-geth is crucially important in order for the system to function properly. The security of

any L2 is dependent on the security of the underlying L1 blockchain. Since Mantle is an

optimistic rollup, the security of the system depends on the ability to send and execute fraud

proofs in a manner that disincentivizes malicious behavior. While Mantle seeks to be as EVM

compatible as possible, there are some differences with Ethereum which can be viewed in <u>[their](https://docs-v2.mantle.xyz/devs/dev-hubs/diffs)</u>

<u>[documentation.](https://docs-v2.mantle.xyz/devs/dev-hubs/diffs)</u>


Mantle OP-Geth Audit − System Overview − 7


## **Critical Severity**

### **C-01 Attacker Can Get Infinite BVM_ETH Tokens** **to Drain the Protocol**

The process of depositing MNT and ETH from L1 to L2 starts in the <u><mark>`[depositTransaction](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L451)`</mark></u>

<u>[function](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L451)</u> of the <mark>`OptimismPortal`</mark> contract. While this contract is used by the

<mark>`L1CrossDomainMessenger`</mark> contract, it can also be called by users directly. It allows anyone

to specify the values to mint and/or transfer MNT and/or ETH on L2. The values of minted MNT

and minted ETH are determined by <u>[pulling the MNT token](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L482-L484)</u> from the user and <u><mark>`[msg.value](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L498)`</mark></u> <mark>.</mark>

However, the transaction values of MNT and ETH are just forwarded from the user input to the

<mark>`TransactionDeposited`</mark> event. The node listens to this event, <u>[parses it, and includes it in a](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-node/rollup/derive/deposit_log.go#L100)</u>

block to execute it in the client.


When the client processes the deposit transaction, it is checked that the L2 user has <u>[enough](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/state_transition.go#L548-L550)</u>

<u>[balance available](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/state_transition.go#L548-L550)</u> for the given MNT transfer value. If not, the execution reverts. However, this

check is never performed for the ETH transaction value. In fact, the <u>[ETH balance transfer](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/state_transition.go#L716)</u> is

performed by reading the <mark>`from`</mark> and <mark>`to`</mark> balance from their contract storage slot, <u>[applying the](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/state_transition.go#L739-L740)</u>

<u>[difference](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/state_transition.go#L739-L740)</u> in value, and setting the new state for these slots. **This happens without any over-/**

**underflow check.** Furthermore, the <mark>`common.BigToHash`</mark> function that is used to set the

state, changes a **negative** <mark>`big.Int`</mark> value to a **positive** hexadecimal representation.


This means that an attacker with zero ETH balance on L2 can initiate a deposit transaction to

transfer 100 ETH to their second controlled address. Then, in the <mark>`transferBVMETH`</mark> function,

their <mark>`from`</mark> balance is calculated as -100 ETH but written to state as +100 ETH, while their

second account also gets another +100 ETH, totaling a gain of 200 ETH on L2 without any L1

investment (besides gas). This ETH value could simply be withdrawn to L1 to drain all of the

locked ETH.


Consider applying stronger balance and overflow checks when directly manipulating the state

of an asset.


**_Update:_** _Resolved in_ _<u>[pull request #42](https://github.com/mantlenetworkio/op-geth/pull/42)</u>_ _at commit_ _<u>[0cf00ba.](https://github.com/mantlenetworkio/op-geth/pull/42/commits/0cf00ba8bc26c27f433c1fa61bdf7d2750933544)</u>_


Mantle OP-Geth Audit − Critical Severity − 8


### **C-02 Wrong Cost Accounting**

The <mark>`Cost`</mark> function of the <mark>`transaction.go`</mark> file supposedly determines the L2 transaction

cost that a user is charged. This is calculated as <mark>`GasPrice * GasLimit`</mark> for the maximum

gas cost, adding the transaction <mark>`Value`</mark> <mark>,</mark> and optionally adding the blob transaction costs as

<mark>`BlobGas * BlobGasFeeCap`</mark> (which is not yet supported). When the function was patched

to add the optional blob costs, the team introduced a copy-paste mistake by removing the

<mark>`Value`</mark> cost addition. As such, while the return value was interpreted to include the <mark>`Value`</mark> <mark>,</mark> it

[actually did not. This has a bad impact on the transaction validation of the transaction pools [1,](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/txpool/txpool.go#L690)

<u>[2] where it is checked whether the user's balance covers the transaction costs.](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/light/txpool.go#L404)</u>


However, as the cost does not include the transaction value, a transaction the user could not

afford by value would still be added to the pool as valid. Then, when the transaction is

processed during <mark>`state_transition.go`</mark> to buy gas, the <u>[balance check is performed](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/state_transition.go#L308)</u>

again, this time with the <mark>`Value`</mark> <mark>,</mark> which causes the transaction to revert without charging the

user. This leads to a DoS attack vector, where an attacker can spam the network with lucrative

transactions that would be prioritized by the node, but never get executed at no cost while also

preventing other transactions from being added to the transaction pool, effectively causing the

blockchain to stop working.


Consider adding the transaction <mark>`Value`</mark> to the transaction cost. Also, consider whether the

code redundancy of cost calculation can be better managed with one or two methods.


**_Update:_** _Resolved in_ _<u>[pull request #41](https://github.com/mantlenetworkio/op-geth/pull/41)</u>_ _at commit_ _<u>[44c9a41.](https://github.com/mantlenetworkio/op-geth/pull/41/commits/44c9a4154ba92dd32def5957f6b51d420aa382ad)</u>_

### **C-03 Potential Insufficient Balance for** **Sponsorship**


The purpose of the <u><mark>`[validateMetaTxList](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/txpool/txpool.go#L1480)`</mark></u> <u>[function of](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/txpool/txpool.go#L1480)</u> <u><mark>`[core/txpool/txpool.go](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/txpool/txpool.go#L1480)`</mark></u> is to

check if the sponsor has enough balance to cover the gas fees of the transactions that it is

sponsoring. This is used by the <u><mark>`[validateTx](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/txpool/txpool.go#L729)`</mark></u> <u>function, the</u> <u><mark>`[promoteExecutables](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/txpool/txpool.go#L1532)`</mark></u> <u>function,</u>

and the <u><mark>`[demoteUnexecutables](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/txpool/txpool.go#L1745)`</mark></u> <u>function, in order to determine which transactions are valid.</u>


The <mark>`validateMetaTxList`</mark> function iterates over all the transactions in a list, and checks if

the sponsor has <u>[enough to fund each transaction individually. However, there can be scenarios](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/txpool/txpool.go#L1503)</u>

in which a sponsor has enough balance to fund each transaction individually, but not all of the

transactions combined. The node then views all of these transactions as valid and keeps them

in its <mark>`txpool`</mark> <mark>.</mark> It is not until the node builds a block and begins to process these transactions

that it realizes that some of these transactions may fail. As such, a malicious attacker could


Mantle OP-Geth Audit − Critical Severity − 9


perform a DoS attack on a node by submitting many sponsored transactions to sponsor as

much as its balance, and while the node views all of the transactions as valid and thus stores

them in its <mark>`txpool`</mark> <mark>,</mark> only one of them can actually be valid. This could stall the node from

processing other users' transactions, effectively causing the L2 to stop functioning.


Consider updating the <mark>`validateMetaTxList`</mark> function to check if the balance of the sponsor

can pay for the <mark>`sponsorCostSum`</mark> <mark>,</mark> which is the total of the sponsored amounts.


**_Update:_** _Resolved in_ _<u>[pull request #43](https://github.com/mantlenetworkio/op-geth/pull/43)</u>_ _at commit_ _<u>[2619376.](https://github.com/mantlenetworkio/op-geth/pull/43/commits/261937606f7d5d13afdac18675769257e4493c5e)</u>_

## **Low Severity**

### **L-01 Incorrect Error Message**


In the <u><mark>`[validateTx](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/light/txpool.go#L350)`</mark></u> <u>[function of](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/light/txpool.go#L350)</u> <u><mark>`[light/txpool.go](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/light/txpool.go#L350)`</mark></u> <mark>,</mark> if the sponsor does not contain

sufficient funds in order to <u>pay for the</u> <u><mark>`[sponsorAmount](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/light/txpool.go#L394-L396)`</mark></u> <mark>,</mark> the error returned is

<mark>`core.ErrInsufficientFunds`</mark> <mark>.</mark> However, for clarity and <u>[consistency with](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/txpool/txpool.go#L709-L711)</u> <u><mark>`[txpool/](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/txpool/txpool.go#L709-L711)`</mark></u>

<u><mark>`[txpool.go](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/txpool/txpool.go#L709-L711)`</mark></u> <mark>,</mark> consider returning the <u><mark>`[types.ErrSponsorBalanceNotEnough](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/types/meta_transaction.go#L26)`</mark></u> error instead.


**_Update:_** _Resolved in_ _<u>[pull request #50](https://github.com/mantlenetworkio/op-geth/pull/50)</u>_ _at commit_ _<u>[65ab3a1.](https://github.com/mantlenetworkio/op-geth/pull/50/commits/65ab3a1f3f309cd297b4cb23283e688d5cf5048f)</u>_

### **L-02 Use of Non-Granular Value for tokenRatio**


The value of <mark>`tokenRatio`</mark> is <u>stored in the</u> <u><mark>`[GasPriceOracle.sol](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/GasPriceOracle.sol#L29)`</mark></u> <u>contract</u> on L2 as a

<mark>`uint256`</mark> <mark>.</mark> This <mark>`tokenRatio`</mark> is intended to take on the quotient value of ETH price divided

by MNT price, and it is used to calculate the gas on L2. Currently, when this value is updated,

all decimals are truncated. Given the current market price of ETH and MNT, the truncation

would only result in a slight error in the gas calculation. However, if the value of MNT grows

relative to the price of ETH, the error will continue to grow.


Therefore, consider scaling up the <mark>`tokenRatio`</mark> value and, upon using this value in op-geth,

scale it back down to its proper scale at that point in order to improve precision.


**_Update:_** _Acknowledged, will resolve._


Mantle OP-Geth Audit − Low Severity − 10


### **L-03 The Light txpool Implementation Does Not** **Account for L1 Costs**

The light client implementation of <mark>`txpool`</mark> <u>[validates](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/light/txpool.go#L350)</u> added transactions just as the core

implementation does. This includes checking whether the user and the meta transaction

sponsor have enough balance to cover the costs.


[However, the user balance is only checked against the L2 cost [1, 2] without the L1 fee, even](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/light/txpool.go#L390-L392)

though it is necessary to account for the rollup transaction cost to L1. This implies that the

underestimated cost could lead to the transaction reverting due to insufficient funds once it is

sent to a full node.


Despite the light node not being in use yet, consider correcting the validation to account for the

L1 costs in order to be prepared for when the network goes decentralized with light nodes.


**_Update:_** _Acknowledged, will resolve. The Mantle team stated:_


_The light node is not yet in use, we will fix it later._

### **L-04 Fragilely Shared Pointer**


In the <mark>`buyGas`</mark> function of the <mark>`state_transition.go`</mark> file, the value of <mark>`mgval`</mark> is intended

to be copied into <mark>`balanceCheck`</mark> <mark>.</mark> However, instead of the value, a pointer to the value is

copied. Hence, <u>[with this assignment, the variables share the same memory. Luckily, the](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/state_transition.go#L304)</u>

<mark>`balanceCheck`</mark> variable then gets another pointer assigned due to

<mark>`new(big.Int).SetUint64()`</mark> <mark>.</mark>


However, if in future revisions this code were to be changed to

<mark>`balanceCheck.SetUint64()`</mark> <mark>,</mark> no new memory would be allocated for this value, implying

an overwrite of <mark>`mgval`</mark> with it. In this code context, this means that the transaction <u>[value is](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/state_transition.go#L308)</u>

<u>[additionally considered](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/state_transition.go#L308)</u> as gas cost, leading to a <u>[double spending of the value](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/state_transition.go#L346)</u> or additional

spending <u>[for the transaction sponsor.](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/state_transition.go#L340)</u>


Consider avoiding a shared pointer altogether by always allocating a new value through

<mark>`new(big.Int).SetUint64()`</mark> <mark>.</mark> While this is not an issue in the given function, it is better to

minimize the risk before it escalates in the future if not treated carefully.


**_Update:_** _Resolved in_ _<u>[pull request #52](https://github.com/mantlenetworkio/op-geth/pull/52)</u>_ _at commit_ _<u>[75b60cb.](https://github.com/mantlenetworkio/op-geth/pull/52/commits/75b60cb8f353730f5d68390618cde0ceafcce24d)</u>_


Mantle OP-Geth Audit − Low Severity − 11


### **L-05 Misleading Documentation**

Throughout the codebase, there are instances of misleading documentation:


   - In <u>[line 80](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/types/transaction.go#L80)</u> of <mark>`transaction.go`</mark> <mark>,</mark> the comment currently says "This is implemented by

DynamicFeeTx, LegacyTx and AccessListTx", but should be updated to include the

<mark>`BlobTx`</mark> and <mark>`DepositTx`</mark> types.

   - In <u>[line 377](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/types/transaction.go#L377)</u> of <mark>`transaction.go`</mark> <mark>,</mark> the comment currently says "gas * gasPrice + value",

but should say "(gas * gasPrice) + (blobGas * blobGasPrice) + value" instead.

   - In <u>[line 655](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/state_transition.go#L655)</u> of <mark>`state_transition.go`</mark> <mark>,</mark> the comment currently says "Return ETH for

remaining gas", but should say "MNT" instead.


Furthermore, there is misleading documentation in the developer documentation as well:


   - The <u>"</u> _<u>[BASEFEE Adjustment Mechanism](https://docs-v2.mantle.xyz/devs/concepts/tx-fee/eip-1559#application-of-eip-1559-in-mantle-v2)</u>_ <u>[" section "Application of EIP-1559 in Mantle v2"](https://docs-v2.mantle.xyz/devs/concepts/tx-fee/eip-1559#application-of-eip-1559-in-mantle-v2)</u>

is outdated. With the <u>Mantle</u> <u><mark>`[BaseFee](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/params/config.go#L680)`</mark></u> <u>upgrade, the</u> <u><mark>`[BaseFee](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/consensus/misc/eip1559.go#L57-L59)`</mark></u> <u>is set</u> by a config

contract (or remains as the last <mark>`BaseFee`</mark> <mark>)</mark> .


Consider fixing the reported documentation instances to improve the overall readability of the

codebase.


**_Update:_** _Partially resolved in_ _<u>[pull request #41](https://github.com/mantlenetworkio/op-geth/pull/41)</u>_ _at commit_ _<u>[44c9a41](https://github.com/mantlenetworkio/op-geth/pull/41/commits/44c9a4154ba92dd32def5957f6b51d420aa382ad)</u>_ _and_ _<u>[pull request #52](https://github.com/mantlenetworkio/op-geth/pull/52)</u>_ _at_

_commit_ _<u>[2527a58. While the comments on line 377 in](https://github.com/mantlenetworkio/op-geth/pull/52/commits/2527a58e28c0fcb2674820375e71cc1b33dfed27)</u>_ _<mark>`transaction.go`</mark>_ _and line 655 in_

_<mark>`state_transition.go`</mark>_ _have been resolved, the comment on line 80 in_ _<mark>`transaction.go`</mark>_

_as well as the developer documentation remain unchanged._

## **Notes & Additional** **Information**

### **N-01 Code Redundancy**


Code redundancy can lead to code bloat and an increased error surface when updating the

code in the future. Throughout the codebase, there are several instances of code redundancy:


   - The <u><mark>`[newPUSH0InstructionSet](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/vm/jump_table.go#L83)`</mark></u> <u>function</u> contains the same code as the

<u><mark>`[newShanghaiInstructionSet](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/vm/jump_table.go#L90)`</mark></u> <u>function.</u>


Mantle OP-Geth Audit − Notes & Additional Information − 12


   - This <u>section of code in the</u> <u><mark>`[DoEstimateGas](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/internal/ethapi/api.go#L1225-L1254)`</mark></u> <u>function</u> which is to estimate the gas cap

for a meta transaction is redundant given the <u><mark>`[calculateGasWithAllowance](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/internal/ethapi/api.go#L1324)`</mark></u>

<u>[function.](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/internal/ethapi/api.go#L1324)</u>

   - In <u>line 87 of</u> <u><mark>`[meta_transaction.go](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/types/meta_transaction.go#L87)`</mark></u> <mark>,</mark> the <mark>`len(MetaTxPrefix)`</mark> is the same as the

existing constant <u><mark>`[MetaTxPrefixLength](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/types/meta_transaction.go#L14)`</mark></u> <mark>.</mark>

   - In <u>lines 73 to 76 of</u> <u><mark>`[rollup_l1_cost.go](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/types/rollup_l1_cost.go#L73-L76)`</mark></u> <mark>,</mark> the contract state is fetched directly instead

of using the <u><mark>`[DeriveL1GasInfo](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/types/rollup_l1_cost.go#L98-L104)`</mark></u> <u>function.</u>

   - In <mark>`worker.go`</mark> <mark>,</mark> the way the <mark>`header.BaseFee`</mark> can be <u>[overwritten twice](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/miner/worker.go#L1070-L1075)</u> is redundant.


Consider removing any instances of code redundancy or explicitly documenting why they are

necessary.


**_Update:_** _Acknowledged, will resolve._

### **N-02 Incorrect Module Name**


The Mantle codebase is currently using <mark>`github.com/ethereum/go-ethereum`</mark> as its

module name, as seen in the <u><mark>`[go.mod](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/go.mod#L1)`</mark></u> <u>flei</u> <u>. The usage of this name, which is from a GitHub</u>

repo that it does not own, prevents others from importing Mantle's code and makes it more

challenging for testing.


Consider using Mantle's own path for its module name.


**_Update:_** _Acknowledged, will resolve. The Mantle team stated:_


_No issue. In mantle-v2, we will replace_ _<mark>`github.com/ethereum/go-ethereum`</mark>_

_<mark>`v1.11.6`</mark>_ _=>_ _<mark>`github.com/mantlenetworkio/op-geth...`</mark>_ _and so on._

### **N-03 Struct Field and Tag Mismatch**


In the <mark>`txJSON`</mark> struct, the <mark>`Data`</mark> field is <u>[tagged](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/types/transaction_marshalling.go#L44)</u> and <u>[referred to](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/types/transaction_marshalling.go#L354)</u> as "input". In the <u><mark>`[go-](https://github.com/ethereum/go-ethereum/blob/release/1.13/core/types/transaction_marshalling.go#L43)`</mark></u>

<u><mark>`[ethereum](https://github.com/ethereum/go-ethereum/blob/release/1.13/core/types/transaction_marshalling.go#L43)`</mark></u> reference implementation, this field is called <mark>`Input`</mark> as well.


To prevent confusion about the parameters and to close the gap between this and the <mark>`go-`</mark>

<mark>`ethereum`</mark> repository, consider renaming the <mark>`Data`</mark> field to <mark>`Input`</mark> <mark>.</mark>


**_Update:_** _Acknowledged, will resolve. The Mantle team stated:_


_Will not fix now, we will upgrade to the latest_ _<mark>`go-ethereum`</mark>_ _later._


Mantle OP-Geth Audit − Notes & Additional Information − 13


### **N-04 Block Number Expiry Potentially Confusing**

The validity of a meta transaction can be limited by the <u>[block number. When this](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/types/meta_transaction.go#L30)</u> <u>[block number](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/txpool/txpool.go#L701-L703)</u>

<u>[is exceeded, the transaction will not be accepted as valid. However, from a user experience](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/txpool/txpool.go#L701-L703)</u>

perspective, it is less intuitive for a sponsor to set a block number as opposed to a timestamp.


To enhance the user experience, consider changing the unit from block number to block

timestamp.


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_The blockheight and blocktime of the mantle-v2 blocks correspond one-to-one, and this_

_is only for user experience. If we modify it, it will introduce significant modifications. Will_

_not fix._

### **N-05 Unused Variables**


As the codebase grows and matures, unused variables can cause code bloat, naming

collisions, and confusion when reading the code. Throughout the codebase, there are

instances of unused variables:


   - The <u><mark>`[OptimismL1FeeRecipient](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/params/protocol_params.go#L29)`</mark></u> <u>variable</u> is not used since the L1 fee is already

included in the fee <u>[that goes towards](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/state_transition.go#L628-L629)</u> the <mark>`OptimismBaseFeeRecipient`</mark> <mark>.</mark>

   - The <u><mark>`[OverrideMantleBaseFee](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/eth/ethconfig/config.go#L209-L210)`</mark></u> <u>variable</u> is unused and from the comment it should be

removed after the fork.

   - The <u><mark>`[OverrideShanghai](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/eth/ethconfig/config.go#L212-L213)`</mark></u> <u>variable</u> is unused and from the comment it should be

removed after the fork.


Consider removing these unused variables to improve code clarity.


**_Update:_** _Acknowledged, will resolve._

### **N-06 Inexplicit Struct Declaration**


It is considered best practice to create a struct using the keys explicitly when instantiating it.

This helps improve the readability and maintainability of the codebase. Struct usage with

inexplicit declarations reduces code readability and is more error-prone. One instance of an

inexplicit struct declaration is <u><mark>`[EthAPIBackend](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/eth/backend.go#L263)`</mark></u> in <mark>`backend.go`</mark> <mark>.</mark>


Consider using the key-value syntax for explicitness.


Mantle OP-Geth Audit − Notes & Additional Information − 14


**_Update:_** _Resolved in_ _<u>[pull request #55](https://github.com/mantlenetworkio/op-geth/pull/55)</u>_ _at commit_ _<u>[79bab65.](https://github.com/mantlenetworkio/op-geth/pull/55/commits/79bab65fffdb84ce2698491f0ea3bfab18e335fa)</u>_

### **N-07 Unclear Calldata Byte Counting**


In Ethereum, zero and non-zero bytes in the <mark>`calldata`</mark> are taxed differently. Hence, when a

transaction buys gas in the <u>[gas estimation (without balance check) run mode, it counts the](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/state_transition.go#L296)</u>

zero and non-zero bytes of the RLP-encoded transaction to approximate the <u>[L1 fee cost. For](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/types/rollup_l1_cost.go#L67)</u>

these specific run modes, a <u>[heuristic value of 80](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/state_transition.go#L225)</u> is added to the number of <mark>`Ones`</mark> (non-zero

bytes). This is to cover transaction fields that are unknown at the time of estimation but will

carry non-zero bytes data during execution. Furthermore, these byte counts are used in the

<u><mark>`[DataGas](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/types/rollup_l1_cost.go#L30)`</mark></u> <u>function</u> to apply the different gas cost per each zero and non-zero byte. However,

before the Regolith update, a magic value of 68 is added to the <mark>`Ones`</mark> <mark>.</mark>


Consider using a <mark>`const`</mark> value at the top of the file along with some context information

instead of magic numbers. This will ensure the maintenance of the value as the protocol

progresses. Moreover, consider renaming the <mark>`Ones`</mark> field of the <u><mark>`[RollupGasData](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/types/rollup_l1_cost.go#L27)`</mark></u> <u>struct</u> to

<mark>`NonZero`</mark> in order to better reflect its meaning.


**_Update:_** _Acknowledged, will resolve._

### **N-08 Todo Comments in the Code**


During development, having well-described TODO comments will make the process of tracking

and solving them easier. Without such information, these comments might age and important

information for the security of the system might be forgotten by the time it is released to

production. These comments should be tracked in the project's issue backlog and resolved

before the system deployment.


Consider removing all instances of TODO comments and instead tracking them in the issues

backlog. Alternatively, consider linking each inline TODO comment to the corresponding issues

backlog entry.


**_Update:_** _Acknowledged, will resolve._


Mantle OP-Geth Audit − Notes & Additional Information − 15


### **N-09 Unnecessary Double Check of** **`SponsorPercent`**

Meta transactions are transactions where the another party other than the <mark>`tx.origin`</mark> can

agree to sponsor the gas fees or a percentage of them on behalf of the user. The percent that a

sponsor can sponsor up to should have an upper bound of 100%. In

<mark>`meta_transaction.go`</mark> <mark>,</mark> this upper bound is checked in <u>[lines 100 to 102](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/types/meta_transaction.go#L100-L102)</u> in the

<mark>`DecodeMetaTxParams`</mark> function.


In the <mark>`DecodeAndVerifyMetaTxParams`</mark> function, <u>this</u> <u><mark>`[DecodeMetaTxParams](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/types/meta_transaction.go#L119)`</mark></u> <u>function</u> is

called and then subsequently <u>[the upper bound of 100% is checked once again. Consider](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/types/meta_transaction.go#L131-L133)</u>

removing this second check as it has already been performed.


**_Update:_** _Resolved in_ _<u>[pull request #57](https://github.com/mantlenetworkio/op-geth/pull/57)</u>_ _at commit_ _<u>[ff8f850.](https://github.com/mantlenetworkio/op-geth/pull/57/commits/ff8f8500921694359c37e12b75d07011d1387cc7)</u>_

### **N-10 Inconsistent Naming of File**


The <u><mark>`[deposit_tx.go](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/types/deposit_tx.go)`</mark></u> <u>file</u> implements the <mark>`DepositTx`</mark> type. Implementations of other types

of transactions are located in the <u><mark>`[tx_access_list.go](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/types/tx_access_list.go)`</mark></u> <mark>,</mark> <u><mark>`[tx_blob.go](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/types/tx_blob.go)`</mark></u> <mark>,</mark>

<u><mark>`[tx_dynamic_fee.go](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/types/tx_dynamic_fee.go)`</mark></u> <mark>,</mark> and <u><mark>`[tx_legacy.go](https://github.com/mantlenetworkio/op-geth/blob/4d05b2cd9a2b8096680eb9b2e87e473a44a43922/core/types/tx_legacy.go)`</mark></u> files.


Consider renaming the <mark>`deposit_tx.go`</mark> file to <mark>`tx_deposit.go`</mark> for consistency.


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_No issues. This file is related to the_ _<mark>`depositTx`</mark>_ _data struct._


Mantle OP-Geth Audit − Notes & Additional Information − 16


## **Conclusion**

Mantle's op-geth upgrade to version 2 has introduced new capabilities to the rollup. These

include native meta-transactions, MNT as a native token, and gas fee optimizations. The audit

uncovered three issues of critical severity, in addition to several other issues of a lower-severity.

We strongly recommend that Mantle implements more extensive QA and testing before going

live to prevent potentially undiscovered vulnerabilities from being exploited. This is especially

crucial in areas relating to the DOS-ing of the node and deposit transactions. We really

appreciated working with the Mantle team as they were very supportive throughout the audit

period and answered questions in a timely manner.


Mantle OP-Geth Audit − Conclusion − 17


