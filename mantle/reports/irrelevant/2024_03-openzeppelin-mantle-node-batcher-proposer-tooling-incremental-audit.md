### | security

# **Mantle Node,** **Batcher,** **Proposer, and** **Tooling** **Incremental** **Audit**

#### **March 15, 2024**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  7


Summary of Changes ______________________________________________________________  7

Pull Request #72 8

Pull Request #89 8

Pull Request #98 9


Security Model and Trust Assumptions _______________________________________________  9

Privileged Roles 9


Medium Severity _________________________________________________________________ 10

M-01 Data With Id 1 Cannot Be Retrieved From Mantle DA 10


Low Severity ____________________________________________________________________ 10

L-01 RequestL2Range Does Not Return Error if Channel Is Full 10

L-02 Witness Data Reader Skips the Last Line if There Is No New Line 11

L-03 Missing Type Conversion 11

L-04 Tests Panic and Fail 11

L-05 Lack of Input Validation 12

L-06 The Mantle DA Status Is Not Cleared on OP-Batcher Start 12

L-07 Sleep Is Used to Wait for Channel Readiness 12

L-08 Missing Connection Timeout for Contacting Mantle DA 13

L-09 Unencrypted Connection to Mantle DA 13


Notes & Additional Information ____________________________________________________ 14

N-01 Typographical Errors 14

N-02 Code Clarity 14


Conclusion ______________________________________________________________________ 16


Mantle Node, Batcher, Proposer, and Tooling Incremental Audit − Table of

Contents − 2


## **Summary**

**Type** Layer 2


**Timeline** From 2024-02-12
To 2024-02-28


**Languages** Go



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


0 (0 resolved)


1 (1 resolved)



**Total Issues** 12 (3 resolved)



**Low Severity Issues** 9 (0 resolved)



**Notes & Additional**
**Information**



2 (2 resolved)



Mantle Node, Batcher, Proposer, and Tooling Incremental Audit − Summary −

3


## **Scope**

We audited three pull requests with the <mark>`op-node`</mark> <mark>,</mark> <mark>`op-batcher`</mark> <mark>,</mark> <mark>`op-proposer`</mark>, <mark>`op-`</mark>

<mark>`chain-ops`</mark> <mark>,</mark> and <mark>`op-service`</mark> components being in scope:


<u>[Pull request #72](https://github.com/mantlenetworkio/mantle-v2/pull/72)</u> from the base commit at <u>[68f2533](https://github.com/mantlenetworkio/mantle-v2/tree/68f2533714457bfd7031578a8be2633552a9743c)</u> and the head commit at <u>[bb0ff70. In scope](https://github.com/mantlenetworkio/mantle-v2/tree/bb0ff7002520ee936101c4c263ac02a66e7e3c96)</u>

were the following files:

```
mantle-v2
├── op-batcher
│  ├── batcher
│  │  ├── batch_submitter.go
│  │  ├── channel_manager.go
│  │  ├── config.go
│  │  ├── driver_da.go
│  │  └── driver.go
│  ├── common
│  │  ├── types.go
│  │  └── utils.go
│  ├── flags
│  │  └── flags.go
│  └── metrics
│    ├── metrics.go
│    └── noop.go
├── op-chain-ops
│  ├── cmd
│  │  ├── check-migration
│  │  │  └── main.go
│  │  ├── op-migrate
│  │  │  └── main.go
│  │  ├── rollover
│  │  │  └── main.go
│  │  └── withdrawals
│  │    └── main.go
│  ├── crossdomain
│  │  ├── encoding.go
│  │  ├── hashing.go
│  │  ├── legacy_abi.go
│  │  ├── legacy_withdrawal.go
│  │  ├── message.go
│  │  ├── migrate.go
│  │  ├── params.go
│  │  ├── withdrawal.go
│  │  ├── withdrawals.go
│  │  └── witness.go
│  ├── eof
│  │  └── eof_crawler.go
│  ├── ether

```

Mantle Node, Batcher, Proposer, and Tooling Incremental Audit − Scope − 4


```
│  │  ├── addresses.go
│  │  ├── cli.go
│  │  ├── migrate.go
│  │  └── storage.go
│  ├── genesis
│  │  ├── check.go
│  │  ├── config.go
│  │  ├── db_migration.go
│  │  ├── genesis.go
│  │  ├── layer_one.go
│  │  ├── layer_two.go
│  │  └── setters.go
│  ├── immutables
│  │  └── immutables.go
│  └── util
│    └── util.go
├── op-node
│  ├── chaincfg
│  │  └── chains.go
│  ├── cmd
│  │  └── genesis
│  │    └── cmd.go
│  ├── eth
│  │  ├── sync_status.go
│  │  └── types.go
│  ├── flags
│  │  └── flags.go
│  ├── metrics
│  │  └── metrics.go
│  ├── node
│  │  ├── config.go
│  │  └── node.go
│  ├── rollup
│  │  ├── da
│  │  │  └── datastore.go
│  │  ├── derive
│  │  │  ├── attributes.go
│  │  │  ├── calldata_source.go
│  │  │  ├── channel_bank.go
│  │  │  ├── channel_in_reader.go
│  │  │  ├── deposit_log.go
│  │  │  ├── engine_consolidate.go
│  │  │  ├── engine_queue.go
│  │  │  ├── error.go
│  │  │  ├── frame.go
│  │  │  ├── l1_block_info.go
│  │  │  ├── l1_retrieval.go
│  │  │  ├── l2block_util.go
│  │  │  ├── payload_util.go
│  │  │  ├── pipeline.go
│  │  │  └── system_config.go
│  │  ├── driver
│  │  │  ├── driver.go
│  │  │  └── state.go
│  │  ├── sync
│  │  │  ├── config.go

```

Mantle Node, Batcher, Proposer, and Tooling Incremental Audit − Scope − 5


```
│  │  │  └── start.go
│  │  └── types.go
│  ├── service.go
│  ├── service_mantle.go
│  ├── sources
│  │  └── sync_client.go
│  └── withdrawals
│    └── utils.go
└── op-service
├── crypto
│  └── signature.go
└── txmgr
└── cli.go

```

<u>[Pull request #89](https://github.com/mantlenetworkio/mantle-v2/pull/89)</u> from the base commit at <u>[5e3886c](https://github.com/mantlenetworkio/mantle-v2/tree/5e3886ce7d384a2fb79bc76eedcc3c120f2aa6da)</u> and the head commit at <u>[76959dd. In scope](https://github.com/mantlenetworkio/mantle-v2/tree/76959dd6b20e978ef0bdd12c5f200e5480037dad)</u>

were the following files:

```
mantle-v2
└── op-node
└── rollup
└── derive
├── deposit_log.go
└── l1_block_info.go

```

<u>[Pull request #98](https://github.com/mantlenetworkio/mantle-v2/pull/98)</u> from the base commit at <u>[0f0861b](https://github.com/mantlenetworkio/mantle-v2/tree/0f0861b998c3d262aba4bb8c006fe981cdc6a26a)</u> and the head commit at <u>[365f02a. In scope](https://github.com/mantlenetworkio/mantle-v2/tree/365f02ae77246e61524182a156861048d1b0bcb6)</u>

were the following files:

```
mantle-v2
└── op-chain-ops
├── genesis
│  └── config.go
└── immutables
└── immutables.go

```

Mantle Node, Batcher, Proposer, and Tooling Incremental Audit − Scope − 6


## **System Overview**

Mantle V2 is a layer 2 (L2) scaling solution for Ethereum that uses fraud proofs instead of

validity proofs for its security. The protocol aims to provide low transaction fees and high

throughput while maintaining full EVM compatibility. Mantle V2 is built on top of Ethereum

using the OP Stack and therefore shares many similarities with Optimism. The <mark>`op-node`</mark> <mark>,</mark> <mark>`op-`</mark>

<mark>`batcher`</mark> <mark>,</mark> and <mark>`op-proposer`</mark> components collectively comprise the consensus layer that

keeps the chain running and glues all the other layer 1 and layer 2 components together

(though there is no consensus as per the Ethereum understanding). Adding <mark>`op-geth`</mark> to this

set, which is the execution layer, makes up the Mantle network.


The <mark>`op-node`</mark> component is responsible for deriving the layer 2 blockchain which means that

it listens for specific layer 1 events and layer 2 transactions, and keeps the chain running by

continuously grouping this data into batches and passing them to the execution client in order

to produce layer 2 blocks. The <mark>`op-batcher`</mark> component, in turn, listens to <mark>`op-node`</mark> for fresh

batches, groups the batches into channels, compresses them, splits them into frames, and

posts frames to the data availability layer.


The <mark>`op-proposer`</mark> component listens to <mark>`op-node`</mark> for the so-called layer 2 output roots

which are Merkle roots. These are then posted to the layer 1 so that the smart contracts on

layer 1 can receive messages from layer 2. This includes ERC-20 token bridging as well as

general message passing. The <mark>`op-chain-ops`</mark> component is a tool that facilitates the

administration of the chain. The <mark>`op-service`</mark> component contains common utilities used by

other parts of the codebase.

## **Summary of Changes**


Presented below is a summary of changes to the in-scope components grouped by pull

request and component.


Mantle Node, Batcher, Proposer, and Tooling Incremental Audit − System

Overview − 7


### **Pull Request #72**

**op-node**


   - MantleDA is now used as a data availability provider. Prior to that, Ethereum calldata was

used.

   - The base fee parameter was introduced. It is set in the <mark>`SystemConfig`</mark> contract on

Ethereum and then passed to the execution layer as part of the first transaction of each

L2 block along with other <mark>`SystemConfig`</mark> parameters.

   - The <mark>`requestsChannelBufferSize`</mark> constant was increased from 128 to 1024 and

the logic around handling the corresponding channel was changed.

   - The <mark>`unsafeL2PayloadsChannelBufferSize`</mark> constant was increased from 10 to

4096 and the logic around handling the corresponding channel was changed.

  - Several improvements were merged from the upstream repository.


**op-batcher**


   - MantleDA is now used as a data availability provider. Prior to that, Ethereum calldata was

used.


**op-proposer**


  - No changes


**op-chain-ops**


   - Support for the <mark>`GasPriceOracle`</mark> contract was added.

  - Support for MNT as a native token was added.


**op-service**


   - The updates to the <mark>`op-service`</mark> component encompass support for the Key

Management Service (KMS) from the Google Cloud Platform (GCP) in Ethereum

operations. In case the Cloud HSM is expected to be used, new configuration

parameters have been introduced to streamline the process.

### **Pull Request #89**


**op-node**


   - The new version of the deposited transaction event was added. In particular, the marshal

and unmarshal functionality was added.


Mantle Node, Batcher, Proposer, and Tooling Incremental Audit − Summary

of Changes − 8


**op-batcher, op-proposer, op-chain-ops, and op-service**


  - No changes.

### **Pull Request #98**


**op-chain-ops**


   - The <mark>`L1_MNT_ADDRESS`</mark> constant was added.


**op-node, op-batcher, op-proposer, and op-service**


  - No changes.

## **Security Model and Trust** **Assumptions**


MantleDA was treated as a black-box during this engagement as we were not provided with

access to the documentation, tests, or the development instance of the system. Similarly, it

was also assumed that the in-scope code uses MantleDA correctly.


Having said that, MantleDA is an emerging technology and thus has a higher chance of having

bugs. The current way to recover from a MantleDA outage or malfunctioning is to stop the

sequencer, switch data availability to Ethereum calldata in the configuration file, and start the

sequencer again. This means there is no automatic fallback mechanism and, in case such an

outage happens, the Mantle blockchain loses liveness until the sequencer is restarted with the

new config.

### **Privileged Roles**


The <mark>`op-batcher`</mark> component uses a private key to interact with the MantleDA contract which

defines which MantleDA blobs should be used to derive the layer 2 chain.


Mantle Node, Batcher, Proposer, and Tooling Incremental Audit − Security

Model and Trust Assumptions − 9


## **Medium Severity**

### **M-01 Data With Id 1 Cannot Be Retrieved From** **Mantle DA**

The <u><mark>`[RetrievalFramesFromDa](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-node/rollup/da/datastore.go#L119-L171)`</mark></u> function of <u>[OP-Node](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-node/rollup/da/datastore.go)</u> implements the logic for retrieving

frames from Mantle DA. It requires a <mark>`dataStoreId`</mark> value, which undergoes a check to verify

if <u>[it is equal to or smaller than 0. As the](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-node/rollup/da/datastore.go#L127-L130)</u> <mark>`calldata_source`</mark> calls

<mark>`RetrievalFramesFromDa`</mark> with the <u><mark>`[dataStoreId](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-node/rollup/derive/calldata_source.go#L222)`</mark></u> <u>decreased by 1, attempting to retrieve</u>

data from Mantle DA with a <mark>`dataStoreId`</mark> equal to 1 becomes impossible.


Consider removing <u>[the check](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-node/rollup/da/datastore.go#L127-L130)</u> from the <mark>`RetrievalFramesFromDa`</mark> function to permit the

processing of a <mark>`dataStoreId`</mark> with a value of 0. In addition, since the <mark>`dataStoreId`</mark> is of

type <mark>`uint32`</mark> and so cannot be smaller than 0, the check becomes unnecessary.


**_Update:_** _Resolved in_ _<u>[pull request #117.](https://github.com/mantlenetworkio/mantle-v2/pull/117)</u>_

## **Low Severity**

### **L-01 RequestL2Range Does Not Return Error if** **Channel Is Full**


The <mark>`RequestL2Range`</mark> function queues a range of L2 blocks and <u>[returns early if the channel](https://github.com/mantlenetworkio/mantle-v2/blob/bb0ff7002520ee936101c4c263ac02a66e7e3c96/op-node/sources/sync_client.go#L123-L125)</u>

<u>[is full. However, it does not return an error in this case which means that the partial data will be](https://github.com/mantlenetworkio/mantle-v2/blob/bb0ff7002520ee936101c4c263ac02a66e7e3c96/op-node/sources/sync_client.go#L123-L125)</u>

processed.


Consider returning an error in case the channel is full in order to make callers aware.


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_Not a valid issue._


Mantle Node, Batcher, Proposer, and Tooling Incremental Audit − Medium

Severity − 10


### **L-02 Witness Data Reader Skips the Last Line if** **There Is No New Line**

The <u><mark>`[ReadWitnessData](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-chain-ops/crossdomain/witness.go#L81-L142)`</mark></u> function of OP-Chain-Ops utilizes <mark>`bufio`</mark> <mark>'</mark> s <u><mark>`[NewReader](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-chain-ops/crossdomain/witness.go#L88)`</mark></u> to iterate

through the file and retrieve all entries. To read each line, the function employs <u><mark>`[ReadString](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-chain-ops/crossdomain/witness.go#L92)`</mark></u> <mark>,</mark>

which reads until a new line is encountered. However, this approach poses an issue – if the last

line of the file lacks a new line character (as is the case for text file <mark>`witness.txt`</mark> <mark>)</mark>, the reader

will trigger an <mark>`EOF`</mark> error, <u>[causing an early break from the loop](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-chain-ops/crossdomain/witness.go#L94-L96)</u> failing to read the last line.


Consider redesigning the function logic in such a way the last line will be read correctly even if

it does not end with a new line.


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_Acknowledged, only used for upgrading, will not fix it._

### **L-03 Missing Type Conversion**


The <u><mark>`[NewWithdrawal](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-chain-ops/crossdomain/withdrawal.go#L38-L53)`</mark></u> function of OP-Chains-Ops returns a <mark>`Withdrawal`</mark> struct with filled

values. The <u><mark>`[Data](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-chain-ops/crossdomain/withdrawal.go#L34)`</mark></u> field, which is of type <mark>`hexutil.Bytes`</mark> <mark>,</mark> is assigned <u><mark>`[data](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-chain-ops/crossdomain/withdrawal.go#L51)`</mark></u> of type

<mark>`[]byte`</mark> <mark>.</mark> However, the assigned value should first be converted to the correct type using the

<mark>`hexutil.Bytes`</mark> function.


Consider converting the <mark>`data`</mark> parameter to the <mark>`hexutil.Bytes`</mark> type.


**_Update:_** _Not resolved. The Mantle team stated:_


_Not a valid issue._

### **L-04 Tests Panic and Fail**


The proposed changes are not thoroughly covered by the test suite. In addition, there are

multiple tests that fail, making it difficult to confirm the correctness of the implementation. The

following components require additional testing:


  - op-node

   - op-batcher

  - op-chain-ops


Mantle Node, Batcher, Proposer, and Tooling Incremental Audit − Low

Severity − 11


Consider reviewing the test suite for the above mentioned components to improve code

quality.


**_Update:_** _Not resolved._

### **L-05 Lack of Input Validation**


The <mark>`BaseFee`</mark> parameter of type <mark>`big.Int`</mark> <u>[is checked for not being](https://github.com/mantlenetworkio/mantle-v2/blob/bb0ff7002520ee936101c4c263ac02a66e7e3c96/op-node/rollup/types.go#L236-L238)</u> <u><mark>`[nil](https://github.com/mantlenetworkio/mantle-v2/blob/bb0ff7002520ee936101c4c263ac02a66e7e3c96/op-node/rollup/types.go#L236-L238)`</mark></u> . However, a

<mark>`big.Int`</mark> can be a negative number which does not make sense for <mark>`BaseFee`</mark> given that it

should always be positive.


Consider checking the <mark>`BaseFee`</mark> parameter both for not being <mark>`nil`</mark> and being a positive

number just like other <mark>`big.Int`</mark> parameters (e.g., <u>[chain ids are validated to be greater than 0](https://github.com/mantlenetworkio/mantle-v2/blob/bb0ff7002520ee936101c4c263ac02a66e7e3c96/op-node/rollup/types.go#L254-L259)</u>

<u>[and not equal to 0).](https://github.com/mantlenetworkio/mantle-v2/blob/bb0ff7002520ee936101c4c263ac02a66e7e3c96/op-node/rollup/types.go#L254-L259)</u>


**_Update:_** _Acknowledged, will resolve._

### **L-06 The Mantle DA Status Is Not Cleared on OP-** **Batcher Start**


Upon starting the OP-Batcher, <u>[the state is cleaned](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-batcher/batcher/driver.go#L179)</u> but the Mantle DA status is not.


Consider calling the <u><mark>`[clearMantleDAStatus](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-batcher/batcher/channel_manager.go#L142-L148)`</mark></u> function to clear the Mantle DA status.


**_Update:_** _Acknowledged, not resolved._

### **L-07 Sleep Is Used to Wait for Channel Readiness**


The <u>[sleep is used to wait](https://github.com/mantlenetworkio/mantle-v2/blob/bb0ff7002520ee936101c4c263ac02a66e7e3c96/op-node/rollup/driver/state.go#L201-L205)</u> <u><mark>`[0.1 ms](https://github.com/mantlenetworkio/mantle-v2/blob/bb0ff7002520ee936101c4c263ac02a66e7e3c96/op-node/rollup/driver/state.go#L201-L205)`</mark></u> for <mark>`sequencerCh`</mark> and <mark>`stepReqCh`</mark> to be ready. While this

might mitigate the issue in the testing environment, it might behave differently in the production

environment where load might be different and thus the sleep time might not provide the

desired effect.


Consider refactoring the code to avoid using sleep and instead using more reliable

mechanisms to sync the channels.


**_Update:_** _Not resolved. The Mantle team stated:_


_Not a valid issue._


Mantle Node, Batcher, Proposer, and Tooling Incremental Audit − Low

Severity − 12


### **L-08 Missing Connection Timeout for Contacting** **Mantle DA**

The implemented connection to Mantle DA is missing a defined timeout option. This might lead

to issues when servers accept connections but fail to respond to calls. There are the following

occurrences of connections to Mantle DA:


   - Connection to Mantle DA in <u><mark>`[getFramesByDataStoreId](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-node/rollup/da/datastore.go#L78)`</mark></u> of OP-Node

   - Connection to Mantle DA Indexer in <u><mark>`[getFramesFromIndexerByDataStoreId](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-node/rollup/da/datastore.go#L99)`</mark></u> of OP
Node

   - Connection to Mantle DA Disperser in <u><mark>`[callEncode](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-batcher/batcher/driver_da.go#L294)`</mark></u> of OP-Batcher


Consider adding a timeout mechanism to the above listed connections.


**_Update:_** _Acknowledged, will resolve._

### **L-09 Unencrypted Connection to Mantle DA**


The implemented connection to Mantle DA is unencrypted. In a production environment, it is

generally recommended to encrypt the connection. There are the following occurrences of

unencrypted connections to Mantle DA:


   - Connection to Mantle DA in <u><mark>`[getFramesByDataStoreId](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-node/rollup/da/datastore.go#L78)`</mark></u> of OP-Node

   - Connection to Mantle DA Indexer in <u><mark>`[getFramesFromIndexerByDataStoreId](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-node/rollup/da/datastore.go#L99)`</mark></u> of OP
Node

   - Connection to Mantle DA Disperser in <u><mark>`[callEncode](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-batcher/batcher/driver_da.go#L294)`</mark></u> of OP-Batcher


Consider using encrypted connection instead.


**_Update:_** _Acknowledged, will resolve._


Mantle Node, Batcher, Proposer, and Tooling Incremental Audit − Low

Severity − 13


## **Notes & Additional** **Information**

### **N-01 Typographical Errors**

Throughout the codebase, several typographical errors were found:


  - The constant name <u><mark>`[TxConfirmDataSubmiited](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-batcher/metrics/metrics.go#L275)`</mark></u> should be

<mark>`TxConfirmDataSubmitted`</mark> <mark>.</mark>

  - The comment <u><mark>`[openend](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-batcher/metrics/metrics.go#L77)`</mark></u> should be <mark>`opened`</mark> <mark>.</mark>

   - This <u><mark>`[comment](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-chain-ops/genesis/setters.go#L116)`</mark></u> should be <mark>`L1_MANTLE_TOKEN`</mark> not <mark>`L1_MANTLE_TOEKN`</mark> <mark>.</mark>


Consider addressing the above typographical errors.


**_Update:_** _Resolved in_ _<u>[pull request #124.](https://github.com/mantlenetworkio/mantle-v2/pull/124)</u>_

### **N-02 Code Clarity**


Throughout the codebase, several instances of redundant and unclear code were identified:


   - The <mark>`NewMantleDataStore`</mark> function defined in <mark>`datastore.go`</mark> <u>[always returns](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-node/rollup/da/datastore.go#L50)</u>

<u><mark>`[error](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-node/rollup/da/datastore.go#L50)`</mark></u> <u>as</u> <u><mark>`[nil](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-node/rollup/da/datastore.go#L50)`</mark></u> <mark>.</mark> Thus, it is not necessary to return it and <u>[check it later.](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-node/node/node.go#L204-L207)</u>

   - The <mark>`NewMantleDataStoreConfig`</mark> function <u>[returns a config and an error. However,](https://github.com/mantlenetworkio/mantle-v2/blob/bb0ff7002520ee936101c4c263ac02a66e7e3c96/op-node/service.go#L211)</u>

the error is always <mark>`nil`</mark> which makes returning an error unnecessary.

   - The <u><mark>`[MockDataStoreConfig](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-node/chaincfg/chains.go#L75-L80)`</mark></u> variable is not used anywhere and should be removed.

   - The <u><mark>`[marshalDepositVersion1](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-node/rollup/derive/deposit_log.go#L306-L357)`</mark></u> function is not used anywhere and can be removed.

   - The <u>[data from reply is retrieved twice](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-node/rollup/da/datastore.go#L94-L95)</u> in the <mark>`getFramesByDataStoreId`</mark> function.

Consider calling <mark>`GetData`</mark> once and then use it in <mark>`log.Debug`</mark> and the return

statement.

   - The <u>[data from reply is retrieved twice](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-node/rollup/da/datastore.go#L115-L116)</u> in the <mark>`getFramesFromIndexerByDataStoreId`</mark>

function. Consider calling <mark>`GetData`</mark> once and then use it in <mark>`log.Debug`</mark> and the return

statement.

   - The <u>two</u> <u><mark>`[if](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-node/rollup/derive/engine_consolidate.go#L44-L49)`</mark></u> <u>[statements](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/op-node/rollup/derive/engine_consolidate.go#L44-L49)</u> check for the <mark>`BaseFee`</mark> not being equal to `0` . Consider moving

the second <mark>`if`</mark> statement inside the first <mark>`if`</mark> statement block and removing the

unnecessary check.


Mantle Node, Batcher, Proposer, and Tooling Incremental Audit − Notes &

Additional Information − 14


   - The <u><mark>`[ds.cfg.MantleDaSwitch](https://github.com/mantlenetworkio/mantle-v2/blob/bb0ff7002520ee936101c4c263ac02a66e7e3c96/op-node/rollup/derive/calldata_source.go#L130-L146)`</mark></u> <u><mark>`[if](https://github.com/mantlenetworkio/mantle-v2/blob/bb0ff7002520ee936101c4c263ac02a66e7e3c96/op-node/rollup/derive/calldata_source.go#L130-L146)`</mark></u> <u>statement</u> could be easier to read if it used an <mark>`if`</mark>

statement with only true and false branches where the true branch contained code for

handling MantleDA and the <mark>`else`</mark> branch contained code for Ethereum <mark>`calldata`</mark> <mark>.</mark>

   - One of the significant updates to the codebase was addition of the MNT value which

changed the protocol to handle <mark>`MNTValue`</mark> and <mark>`ETHValue`</mark> <mark>.</mark> The correct encoding

starts with the <mark>`MNTValue`</mark> parameter followed by <mark>`ETHValue`</mark> parameter. However, in

multiple places, the structures are initilaized in the reverse order. While this does not

cause an issue since the parameter names are used, it does hinder readability. Consider

changing the order of the <mark>`MNTValue`</mark> and <mark>`ETHValue`</mark> parameters in the <u><mark>`[Decode](https://github.com/mantlenetworkio/mantle-v2/blob/bb0ff7002520ee936101c4c263ac02a66e7e3c96/op-chain-ops/crossdomain/withdrawal.go#L121-L122)`</mark></u> and

<u><mark>`[WithdrawalTransaction](https://github.com/mantlenetworkio/mantle-v2/blob/bb0ff7002520ee936101c4c263ac02a66e7e3c96/op-chain-ops/crossdomain/withdrawal.go#L162-L163)`</mark></u> functions.


**_Update:_** _Resolved in_ _<u>[pull request #125.](https://github.com/mantlenetworkio/mantle-v2/pull/125)</u>_


Mantle Node, Batcher, Proposer, and Tooling Incremental Audit − Notes &

Additional Information − 15


## **Conclusion**

The audit uncovered one issue of medium severity, in addition to several other issues of a

lower severity. Various recommendations have been provided to enhance the quality and

documentation of the codebase. We also strongly recommend that Mantle implements more

extensive QA procedures and tests before going live to prevent potentially undiscovered

vulnerabilities from being exploited. This is especially crucial in areas of the code where testing

was limited, such as the integration with Mantle DA. The Mantle team was very supportive

throughout the audit period and answered questions in a timely manner.


Mantle Node, Batcher, Proposer, and Tooling Incremental Audit − Conclusion

                                                - 16


