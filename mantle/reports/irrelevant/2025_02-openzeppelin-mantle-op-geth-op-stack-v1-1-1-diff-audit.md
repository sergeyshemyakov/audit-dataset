### | security

# **Mantle Op-geth** **& Op-stack Diff** **Audit**

#### **February 12, 2025**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  7

Op-stack Updates 7

Op-geth Updates 8

New Precompile for Signatures on sec256r1 8


Security Model and Privileged Roles _________________________________________________  9


Medium Severity _________________________________________________________________ 10

M-01 Inefficient Error Handling and Timeout in loopEigenDa Loop 10


Low Severity ____________________________________________________________________ 11

L-01 Duplication of RLP Encoding 11

L-02 Inadequate Handling of Single Large Data Frames in blobTxCandidates 12

L-03 Redundant Encoding and Decoding of Commitments in disperseEigenDaData 13

L-04 Direct Communication with EigenDA Disperser in RetrieveBlob 13

L-05 Inconsistent Signer Selection in Transaction Signing 14

L-06 Error-Prone Proxy Admin Owner Upgrade Logic 15


Notes & Additional Information ____________________________________________________ 16

N-01 Missing Signature Malleability Check 16

N-02 Missing Documentation 17

N-03 Improved Efficiency of Input Validation 17


Conclusion ______________________________________________________________________ 19


Mantle Op-geth & Op-stack Diff Audit − Table of Contents − 2


## **Summary**

**Type** Layer 2


**Timeline** From 2024-01-06
To 2024-01-27


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



**Total Issues** 10 (5 resolved)



**Low Severity Issues** 6 (3 resolved)



**Notes & Additional**
**Information**



3 (1 resolved)



Mantle Op-geth & Op-stack Diff Audit − Summary − 3


## **Scope**

This audit is divided into three parts:



1.



A diff audit of the <u>[mantlenetworkio/mantle-v2](https://github.com/mantlenetworkio/mantle-v2)</u> repo, comparing commit <u>[c77cb6e](https://github.com/mantlenetworkio/mantle-v2/tree/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9)</u> with

[commit fd99099, and the following files being in scope:](https://github.com/mantlenetworkio/mantle-v2/tree/fd990997c6cfa51b1506cb925cac3dd8267a37f0)


```
mantle-v2
├── op-batcher
│  ├── batcher
│  │  ├── channel_builder.go
│  │  ├── channel_manager.go
│  │  ├── config.go
│  │  ├── driver.go
│  │  └── driver_da.go
│  ├── cmd
│  │  └── main.go
│  ├── flags
│  │  └── flags.go
│  └── metrics
│    ├── metrics.go
│    └── noop.go
├── op-e2e
│  └── actions
│    └── l2_verifier.go
├── op-node
│  ├── flags
│  │  └── flags.go
│  ├── metrics
│  │  └── metrics.go
│  ├── node
│  │  ├── client.go
│  │  ├── config.go
│  │  └── node.go
│  ├── rollup
│  │  ├── da
│  │  │  ├── datastore.go
│  │  │  └── interfaceRetrieverServer/server.pb.go
│  │  ├── derive
│  │  │  ├── calldata_source.go
│  │  │  ├── l1_retrieval.go
│  │  │  └── pipeline.go
│  │  ├── driver
│  │  │  └── driver.go
│  │  └── types.go
│  └── service.go
├── op-program/client/driver/driver.go
└── op-service
├── client

```

Mantle Op-geth & Op-stack Diff Audit − Scope − 4


```
│  └── http.go
├── eigenda
│  ├── cli.go
│  ├── codec.go
│  ├── config.go
│  ├── da.go
│  ├── da_proxy.go
│  ├── derivation.go
│  └── metrics.go
├── eth
│  ├── blob.go
│  ├── blobs_api.go
│  ├── ether.go
│  ├── id.go
│  └── types.go
├── proto
│  ├── gen/op_service/v1/calldata.pb.go
│  └── src/op_service/v1/calldata.proto
├── retry
│  ├── operation.go
│  └── strategies.go
├── sources/l1_beacon_client.go
├── txmgr
│  ├── cli.go
│  └── txmgr.go
└── upgrade
└── mantle_upgrade.go

```


1.



A diff audit of the <u>[mantlenetworkio/op-geth](https://github.com/mantlenetworkio/op-geth)</u> repo, comparing commit <u>[4a20fa6](https://github.com/mantlenetworkio/op-geth/tree/4a20fa61a79e4c4cd61138e467332368d7fc8a8d)</u> with

[commit 87c2ac2, and the following files being in scope:](https://github.com/mantlenetworkio/op-geth/tree/87c2ac29425685d97fdb5a8934741a10f2588f99)


```
op-geth
├── consensus/misc/eip1559.go
├── core
│  ├── genesis.go
│  ├── mantle_upgrade.go
│  ├── state_transition.go
│  ├── txpool/txpool.go
│  ├── types
│  │  ├── deposit_tx.go
│  │  ├── meta_transaction.go
│  │  ├── transaction.go
│  │  ├── transaction_signing.go
│  │  ├── tx_access_list.go
│  │  ├── tx_dynamic_fee.go
│  │  └── tx_legacy.go
├── internal
│  └── ethapi
│    ├── api.go
│    └── transaction_args.go

```


Mantle Op-geth & Op-stack Diff Audit − Scope − 5


```
├── light/txpool.go
└── params/confighttp.go

```


1.


 


An audit of two pull requests in the <u>[mantlenetworkio/op-geth](https://github.com/mantlenetworkio/op-geth)</u> repo:


<u>[Pull request #93](https://github.com/mantlenetworkio/op-geth/pull/93/commits)</u> and the following files being in scope:


```
op-geth
├── core
│  ├── genesis.go
│  ├── mantle_upgrade.go
│  ├── txpool/txpool.go
│  └── vm
│    ├── contracts.go
│    └── evm.go
├── crypto
│  └── secp256r1
│    ├── publickey.go
│    └── verifier.go
└── params
├── config.go
└──protocol_params.go

```






<u>[Pull request #95](https://github.com/mantlenetworkio/op-geth/pull/95/files)</u> and the following files being in scope:


```
op-geth
├── core
│  ├── mantle_upgrade.go
│  ├── state_transition.go
│  ├── txpool/txpool.go
|  └── types/meta_transaction.go
└── light/txpool.go

```


Mantle Op-geth & Op-stack Diff Audit − Scope − 6


## **System Overview**

Mantle V2 is a layer 2 (L2) scaling solution for Ethereum that uses fraud proofs instead of

validity proofs for its security. The protocol aims to provide low transaction fees and high

throughput while maintaining full EVM compatibility. Mantle V2 is built on top of Ethereum

using the OP Stack and therefore shares many similarities with Optimism. Further details about

Mantle can be found in our previous audit reports <u>[here, here, here, and here. In this diff audit,](https://blog.openzeppelin.com/mantle-token-and-bridge-audit)</u>

the reviewed changes can be categorized into three groups:

### **Op-stack Updates**


The updates to the op-stack focus on enhancing scalability and reliability by addressing data

availability (DA) using EigenDA. These can be categorized into three main upgrades:











**Batcher** : The batcher aggregates transactions and disperses them to EigenDA for

storage, posting commitments to L1. If EigenDA is unavailable, Ethereum blobs are used

as a fallback.

**Rollup** : The rollup uses data from EigenDA (or Ethereum blobs) and the commitment

(dispersed by the batcher) on Ethereum to reconstruct the L2 blockchain.

**EigenDA Service** : A new client, <mark>`NewEigenDAClient`</mark> <mark>,</mark> facilitates communication with

the EigenDA proxy, enabling the retrieval of blobs and their associated commitments,

and verifying them when necessary.



Other notable updates include:











A Mantle update configuration that specifies when each chain should upgrade to

EigenDA based on block height.

Retry handling for operations to ensure failed operations are retried with an appropriate

backoff strategy.

Enhanced tracking of the DA layer with metrics to monitor transaction submissions,

handle retries, and manage fallback options in case of issues.


Mantle Op-geth & Op-stack Diff Audit − System Overview − 7


### **Op-geth Updates**

Several changes have been made to the op-geth implementation. These can be categorized

into three main categories: updates related to Blob transactions, updates related to meta

transactions, and bug fixes.













**Blob Transactions** : A new file, <mark>`eip4844.go`</mark> <mark>,</mark> has been added. Its functions handle

[header verification for blob transactions as defined by EIP-4844](https://eips.ethereum.org/EIPS/eip-4844) and compute the base

fee for such transactions. In addition, support for signing such transactions has been

introduced by implementing the Cancun signer. Blob transactions are designed to be

included in L1 blocks and are not relevant to the L2 execution layer. As a result, the

functions in this file are not utilized elsewhere in the op-geth code.


**Meta Transactions** : Meta transactions have been disabled, as the Mantle team plans to

implement EIP-7702 as a replacement in a future upgrade.


**Gas Bug Fix** : A bug related to the computation of the gas for transactions with a sender

having pending transactions has been fixed.


**Proxy Admin Owner Update** : The proxy admin owner for the proxy contract of Mantle's

system contracts had been previously set incorrectly. Now, this issue has been

addressed by implementing an update of the owner address at the node level.


### **New Precompile for Signatures on sec256r1**

Mantle has implemented a new precompile <mark>(</mark> <mark>`p256Verify`</mark> <mark>)</mark> for verifying ECDSA signatures on

the <mark>`sec256r1`</mark> [curve, following RIP-7212. The](https://github.com/ethereum/RIPs/blob/master/RIPS/rip-7212.md) <mark>`sec256r1`</mark> curve is widely adopted and

supported by many modern devices, making the addition of this precompile highly convenient.


<mark>`p256Verify`</mark> is similar to <mark>`ecrecover`</mark> and the main differences lie in the choice of the elliptic

curve and the expected arguments. <mark>`ecrecover`</mark> verifies signatures on the <mark>`sec256k1`</mark> curve.

Furthermore, while <mark>`ecrecover`</mark> takes as arguments the message hash along with the three

fields of the signature: `v`, `r`, and `s`, and the public key of the signer can be recovered from

them, <mark>`p256verify`</mark> expects the hash of the message, the signatur <mark>e</mark> <mark>`(r,s)`</mark> <mark>,</mark> but also the

public key of the signer <mark>`(x,y)`</mark> to be provided explicitly.


When invalid arguments are provided, such as if the `r` or `s` are out of range or if the public

key does not represent a valid point of the curve, the precompile does not revert but instead

returns <mark>`false`</mark> <mark>.</mark> Moreover, as stated in RIP-7212, the precompile permits malleable signatures,

and it is left to the wrapper libraries to add a malleability check, if needed. The gas cost for


Mantle Op-geth & Op-stack Diff Audit − System Overview − 8


calling this new precompile has been set to 3450, slightly higher than that of <mark>`ecrecover`</mark> <mark>.</mark> To

implement input validation and signature verification, the precompile relies on standard Go

libraries, as <mark>`crypto/ecdsa`</mark> and <mark>`crypto/elliptic`</mark> <mark>.</mark> These libraries are widely used and

were considered safe for the purposes of this audit.

## **Security Model and** **Privileged Roles**


This audit focused on reviewing changes across various components of the Mantle chain.

Since this was a diff audit, we only assessed the modified code and, thus, cannot guarantee

the correctness of the unchanged parts.


In the <mark>`op-stack`</mark> <mark>,</mark> [we assume that the EigenDA proxy server, hosted by Mantle, is functioning](https://github.com/Layr-Labs/eigenda-proxy)

as expected, verifying both the DA certificate and KZG commitments. We also assume that the

parameters and servers are correctly configured to ensure seamless communication between

the EigenDA service and EigenDA, that the EigenDA dispersal process is actively monitored,

and that in the event of failure, the system automatically adjusts the <mark>`SkipEigenDARpc`</mark> toggle

for a quicker fallback to Ethereum blobs.


In the <mark>`op-geth`</mark> part, we identified several hardcoded values, primarily related to timestamps

for scheduled upgrades and rules changes. During the audit, many of these values had not

been set yet and were marked as TODO. We assume these values will be properly configured

before deployment. In addition, a new proxy admin owner will be assigned to the proxy

contract that governs most of Mantle's system contracts. This address will have the authority

to update system contracts at will, particularly those controlling the bridging mechanism with

L1. The designated admin address is expected to be controlled by a multisig and is assumed

to be trusted to ensure the proper functioning of the system.


Mantle Op-geth & Op-stack Diff Audit − Security Model and Privileged Roles

                                                  - 9


## **Medium Severity**

### **M-01 Inefficient Error Handling and Timeout in** **loopEigenDa Loop**

The <u><mark>`[loopEigenDa](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-batcher/batcher/driver_da.go#L208-L310)`</mark></u> <u>function</u> of the <mark>`BatchSubmitter`</mark> attempts to call

<u><mark>`[disperseEigenDaData](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-batcher/batcher/driver_da.go#L237)`</mark></u> within a retry loop that continues for either a fixed number of retries

( <u><mark>`[EigenRPCRetryNum](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-batcher/batcher/driver_da.go#L235)`</mark></u> <mark>)</mark> or until a timeout ( <u><mark>`[DisperseBlobTimeout](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-batcher/batcher/driver_da.go#L234)`</mark></u> <mark>)</mark> is reached. However, the

implementation neglects to properly handle errors returned by <mark>`disperseEigenDaData`</mark> <mark>.</mark>

Instead of classifying or acting on the errors, the loop merely logs them and retries, effectively

waiting for the entire <mark>`DisperseBlobTimeout`</mark> duration, even in cases where the operation

cannot succeed due to permanent or critical errors.


This oversight can lead to inefficient resource utilization and unnecessary delays. In scenarios

where a critical error occurs (e.g., invalid input data or persistent configuration issues), the loop

will still continue retrying until the timeout expires. This results in wasted computation time,

potential bottlenecks in the rollup process, and delayed submission of transaction data.

Furthermore, this behavior can obscure the root cause of errors in the logs as the same error is

repeatedly logged without actionable resolution.


To address this issue, consider enhancing the error-handling logic to distinguish between

transient errors (e.g., network issues) and permanent ones (e.g., invalid data). For transient

errors, the loop can continue with retries, potentially implementing exponential back-off to

reduce retry frequency over time. For permanent errors, the loop should exit immediately to

avoid unnecessary delays. Moreover, the timeout check should be performed at the beginning

of each retry iteration to ensure that retries do not continue beyond the configured timeout.


**_Update:_** _[Resolved in pull request #192. The Mantle team implemented a more fine-grained](https://github.com/mantlenetworkio/mantle-v2/pull/192)_

_distinction between transient and permanent errors. Transient errors will be retried, while_

_permanent errors such as EigenDA invocation errors will exit immediately, requiring manual_

_investigation._


Mantle Op-geth & Op-stack Diff Audit − Medium Severity − 10


## **Low Severity**

### **L-01 Duplication of RLP Encoding**

In the <u><mark>`[loopEigenDa](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-batcher/batcher/driver_da.go#L208-L251)`</mark></u> <u>function, the</u> <u><mark>`[txAggregatorForEigenDa](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-batcher/batcher/driver_da.go#L218-L218)`</mark></u> <u>function</u> [performs the RLP](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-batcher/batcher/driver_da.go#L503)

<u>[encoding of transaction data](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-batcher/batcher/driver_da.go#L503)</u> to validate its size against <mark>`RollupMaxSize`</mark> <mark>.</mark> However, the

method only returns the raw, non-encoded transaction data ( <u><mark>`[txsData](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-batcher/batcher/driver_da.go#L524-L525)`</mark></u> <mark>)</mark> . Subsequently, in

<mark>`loopEigenDa`</mark> <mark>,</mark> the same data is passed to <u><mark>`[disperseEigenDaData](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-batcher/batcher/driver_da.go#L237)`</mark></u> <mark>,</mark> where it is <u>[RLP-](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-batcher/batcher/driver_da.go#L387)</u>

<u>[encoded again. This duplication of the RLP encoding process is unnecessary and inefficient,](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-batcher/batcher/driver_da.go#L387)</u>

as the encoded data from <mark>`txAggregatorForEigenDa`</mark> could have been reused directly.


This redundancy introduces computational overhead, especially when handling large datasets,

as RLP encoding can be resource-intensive. Repeating the encoding process effectively

doubles the time and CPU cycles required for this operation, which could lead to performance

degradation. In addition, the current implementation introduces unnecessary complexity and

inconsistency, as the RLP-encoded data is discarded instead of being reused, making the data

flow harder to follow and maintain.


To resolve this issue, consider updating the <mark>`txAggregatorForEigenDa`</mark> function to return

both the RLP-encoded data ( <mark>`transactionByte`</mark> <mark>)</mark> and the raw transaction data ( <mark>`txsData`</mark> <mark>)</mark> .

The <mark>`loopEigenDa`</mark> function can then directly use the encoded data in

<mark>`disperseEigenDaData`</mark> <mark>,</mark> eliminating the need for a second encoding pass. This change

reduces computational overhead, simplifies the logic, and ensures consistent handling of the

encoded data. By avoiding redundant operations, the overall performance and maintainability

of the code are significantly improved.


**_Update:_** _Resolved, not an issue. The Mantle team stated:_


_We tested the performance of_ _<mark>`rlp.EncodeToBytes`</mark>_ _for data of 4MiB (4 times the size_

_of a typical Mantle blob) in the following code. The test results showed an average time_

_consumption of 0.43ms per EncodeToBytes operation._

```
bash pkg: github.com/ethereum-optimism/optimism/op-batcher/batcher
BenchmarkRLPEncoding
BenchmarkRLPEncoding-8
2767    438315 ns/op   5434873 B/op     2 allocs/op

```

_Compared to the approximately 1-minute duration for a single loopEigenDa operation,_

_the impact on performance is negligible. Therefore, we believe this will not cause any_

_performance issues._


Mantle Op-geth & Op-stack Diff Audit − Low Severity − 11


```
go func BenchmarkRLPEncoding(b *testing.B) { // Generate 40 random
128KB chunks data := make([][]byte, 40) for i := range data { data[i]
= make([]byte, 128*1024) _, err := rand.Read(data[i]) if err != nil {
b.Fatalf("Failed to generate random data: %v", err) } } b.ResetTimer()
for i := 0; i < b.N; i++ { _, err := rlp.EncodeToBytes(data) if err !=
```

<mark>`nil { b.Fatalf("RLP encoding failed: %v", err) } } }`</mark> <mark>_</mark>

### **L-02 Inadequate Handling of Single Large Data** **Frames in blobTxCandidates**


In the <u><mark>`[blobTxCandidates](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-batcher/batcher/driver_da.go#L327-L384)`</mark></u> <u>function, the code assumes that data exceeding the size limit</u>

( <mark>`se.MaxBlobDataSize * MaxblobNum`</mark> <mark>)</mark> results from the aggregation of multiple frames.

However, it does not account for the possibility that a single frame ( <mark>`frameData`</mark> <mark>)</mark> could

[individually exceed the maximum size. When this occurs, the function appends](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-batcher/batcher/driver_da.go#L334) the oversized

frame to <mark>`dataInTx`</mark> and proceeds without any special handling, which may lead to

unintended behavior during blob creation.


If a single frame exceeds the maximum blob size, the function does not split it into smaller

chunks or handle the error explicitly. This can result in the generation of transaction candidates

with empty blobs or transaction candidates with an amount of blobs that exceeds the

configured amount of maximum blobs <mark>(</mark> <u><mark>`[MaxblobNum](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-batcher/batcher/driver_da.go#L39)`</mark></u> <mark>)</mark>, which is currently set to 4.


Consider introducing explicit handling for single frames that exceed the maximum size. Before

appending a frame to <mark>`dataInTx`</mark> <mark>,</mark> check whether the frame itself exceeds the size limit. If it

does, log an error and return an appropriate error message. Alternatively, consider

implementing logic to split oversized frames into smaller chunks before proceeding. Another

solution could be to ensure that a single frame will always fit in a single blob transaction by

enforcing that the configured <u><mark>`[MaxFrameSize](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-batcher/batcher/driver.go#L108)`</mark></u> is smaller than the maximum size

( <mark>`se.MaxBlobDataSize * MaxblobNum`</mark> <mark>)</mark> . Adding this check will ensure robust handling of

all edge cases.


**_Update:_** _[Resolved in pull request #194. The Mantle team stated:](https://github.com/mantlenetworkio/mantle-v2/pull/194)_


_A check has been introduced to ensure a single frame is not larger than_

_<mark>`MaxBlobDataSize * MaxblobNum`</mark>_ <mark>.</mark>


Mantle Op-geth & Op-stack Diff Audit − Low Severity − 12


### **L-03 Redundant Encoding and Decoding of** **Commitments in disperseEigenDaData**

In the <mark>`disperseEigenDaData`</mark> [function, the commitment retrieved from](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-batcher/batcher/driver_da.go#L393)

<u><mark>`[EigenDA.DisperseBlob](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-batcher/batcher/driver_da.go#L393)`</mark></u> is first <u>decoded in</u> <u><mark>`[DisperseBlob](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-service/eigenda/da_proxy.go#L161)`</mark></u> using <mark>`DecodeCommitment`</mark>

and then is returned to <mark>`disperseEigenDaData`</mark> <mark>,</mark> where it is subsequently <u>[re-encoded using](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-batcher/batcher/driver_da.go#L399)</u>

<u><mark>`[EncodeCommitment](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-batcher/batcher/driver_da.go#L399)`</mark></u> <mark>.</mark> This results in unnecessary computational overhead, as the

commitment undergoes an extra encoding-decoding cycle that does not add value to the

process. This redundancy increases computational costs and adds inefficiency to the blob

dispersal process. The extra encoding and decoding operations introduce unnecessary

processing time, which could impact the overall performance of batch submission.


To optimize the process, consider having <mark>`DisperseBlob`</mark> return both the encoded and

decoded versions of the commitment, eliminating the need for <mark>`disperseEigenDaData`</mark> to

re-encode it while still being able to extract information from the decoded commitment and

<u>[adding the encoded version to the calldata frame.](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-batcher/batcher/driver_da.go#L414)</u>


**_Update:_** _Resolved, not an issue. The Mantle team stated:_


_In our tests, the average time elapsed for each decode is 0.0013ms, and for each_

_encode is 0.0004ms. Moreover,_ _<mark>`DecodeCommitment`</mark>_ _and_ _<mark>`EncodeCommitment`</mark>_ _are_

_not high-frequency operations, so their impact on performance is very minimal. We_

_believe it's not a issue._

### **L-04 Direct Communication with EigenDA** **Disperser in RetrieveBlob**


The rollup service <u>leverages</u> <u><mark>`[RetrieveBlob](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-node/rollup/derive/calldata_source.go#L534)`</mark></u> to retrieve blobs from EigenDA in order to

reconstruct the L2 state. This <u><mark>`[RetrieveBlob](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-node/rollup/da/datastore.go#L228-L233)`</mark></u> <u>function</u> calls the <u><mark>`[RetrieveBlob](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-service/eigenda/da_proxy.go#L61-L89)`</mark></u> function of

the EigenDA client when the length of the commitment is 0. This function directly

communicates with the EigenDA disperser over gRPC to retrieve the blob based on the

<mark>`BatchHeaderHash`</mark> and <mark>`BlobIndex`</mark> instead of using the EigenDA proxy used by the

<u><mark>`[RetrieveBlobWithCommitment](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-service/eigenda/da_proxy.go#L92-L128)`</mark></u> <u>function.</u>


[Using the EigenDA proxy](https://github.com/Layr-Labs/eigenda-proxy) instead of the EigenDA disperser directly to retrieve blobs comes

with several benefits such as KZG verification ensuring data correctness and DA certificate

verification ensuring data represented by bad DA certificates does not become part of the

canonical chain. By using the disperser directly, these verification checks are not performed,


Mantle Op-geth & Op-stack Diff Audit − Low Severity − 13


which could lead to an inability to reconstruct the proper L2 state when using EigenDA to

retrieve blobs. Do note that this only happens when the <u>[commitment length is equal to zero.](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-node/rollup/da/datastore.go#L229)</u>


While this generally should not happen as the batcher will not post empty commitments to L1,

consider adding a check to ensure that the <mark>`RetrieveBlob`</mark> function in the rollup service is

<u>[not invoked](https://github.com/mantlenetworkio/mantle-v2/blob/c77cb6e9f44a60f6d25de54bd3d52731de8bdda9/op-node/rollup/derive/calldata_source.go#L534)</u> with a commitment length of 0.


**_Update:_** _Acknowledged, will resolve. The Mantle team stated:_


_The Direct Communication with EigenDA Disperser in RetrieveBlob is retained_

_compatibility code for a historical EigenDA integration version on the sepolia testnet. It_

_will not be executed on the mainnet. We will remove these codes in the next protocol_

_upgrade._

### **L-05 Inconsistent Signer Selection in Transaction** **Signing**


In <mark>`transaction_signing.go`</mark> <mark>,</mark> there are three functions responsible for returning the

appropriate Signer type for the chain <mark>:</mark> <u><mark>`[LatestSignerForChainID](https://github.com/mantlenetworkio/op-geth/blob/4a20fa61a79e4c4cd61138e467332368d7fc8a8d/core/types/transaction_signing.go#L86-L91)`</mark></u> <mark>,</mark> <u><mark>`[LatestSigner](https://github.com/mantlenetworkio/op-geth/blob/4a20fa61a79e4c4cd61138e467332368d7fc8a8d/core/types/transaction_signing.go#L64-L77)`</mark></u> <mark>,</mark> and

<u><mark>`[MakeSigner](https://github.com/mantlenetworkio/op-geth/blob/4a20fa61a79e4c4cd61138e467332368d7fc8a8d/core/types/transaction_signing.go#L40-L55)`</mark></u> <mark>.</mark> While these functions differ in their inputs, they are expected to return the same

Signer types.









<mark>`LatestSignerForChainID`</mark> <mark>:</mark> Only accepts the chain ID as an argument.

<mark>`LatestSigner`</mark> <mark>:</mark> Accepts the chain configuration.

<mark>`MakeSigner`</mark> <mark>:</mark> Accepts both the chain configuration and the block number.



However, there is an inconsistency. The <mark>`LatestSignerForChainID`</mark> function returns

<u><mark>`[cancunSigner](https://github.com/mantlenetworkio/op-geth/blob/4a20fa61a79e4c4cd61138e467332368d7fc8a8d/core/types/transaction_signing.go#L173)`</mark></u> <mark>,</mark> reflecting that the Cancun upgrade is expected to be the most recent op
geth update adopted by Mantle. In contrast, the other two functions, even if the chain has been

upgraded to Cancun, return <u><mark>`[londonSigner](https://github.com/mantlenetworkio/op-geth/blob/4a20fa61a79e4c4cd61138e467332368d7fc8a8d/core/types/transaction_signing.go#L242)`</mark></u> instead of <mark>`cancunSigner`</mark> <mark>.</mark>


The only difference between <u><mark>`[londonSigner](https://github.com/ethereum-optimism/op-geth/blob/831e3fd7447f32be6a6d8e06b674479c400e7416/core/types/transaction_signing.go#L248-L252)`</mark></u> and <u><mark>`[cancunSigner](https://github.com/ethereum-optimism/op-geth/blob/831e3fd7447f32be6a6d8e06b674479c400e7416/core/types/transaction_signing.go#L179-L184)`</mark></u> is that the latter supports

Blob transactions. However, Blob transactions are meant to be posted on L1 and are not

intended for inclusion in L2 blocks. In fact, such transactions are discarded from the L2

<u><mark>`[txpool](https://github.com/mantlenetworkio/op-geth/blob/4a20fa61a79e4c4cd61138e467332368d7fc8a8d/core/txpool/txpool.go#L637-L640)`</mark></u> <mark>.</mark> Despite this, since <mark>`LatestSignerForChainID`</mark> returns <mark>`cancunSigner`</mark>, it allows

users to create Blob transactions for the L2 by calling

<u><mark>`[NewKeyedTransactionWithChainID](https://github.com/mantlenetworkio/op-geth/blob/4a20fa61a79e4c4cd61138e467332368d7fc8a8d/accounts/abi/bind/auth.go#L144-L164)`</mark></u> and providing a Blob transaction, even though that

transaction will be rejected.


Mantle Op-geth & Op-stack Diff Audit − Low Severity − 14


To ensure uniform behavior of the three functions and to prevent attempts to submit Blob

transactions to the L2 chain, consider modifying <mark>`LatestSignerForChainID`</mark> to return

<mark>`londonSigner`</mark> <mark>.</mark> This change would align the behavior of all three functions and maintain the

intended handling of transactions on L2.


**_Update:_** _Acknowledged, will resolve. The Mantle team stated:_


_Acknowledged. It will be fixed in the next version._

### **L-06 Error-Prone Proxy Admin Owner Upgrade** **Logic**


Most Mantle system contracts are implemented behind a proxy contract. This proxy contract is

controlled by a <mark>`ProxyAdmin`</mark> contract. However, as part of the previous upgrade, an invalid

address has been inadvertently set as the owner of the <mark>`ProxyAdmin`</mark> contract. In this

upgrade, the issue is remedied by setting the correct address as the proxy admin owner.


The owner upgrade is handled in the <u><mark>`[TransitionDb](https://github.com/mantlenetworkio/op-geth/blob/4a20fa61a79e4c4cd61138e467332368d7fc8a8d/core/state_transition.go#L486-L488)`</mark></u> function, which updates the actual state

of the <mark>`Proxy`</mark> contract. More specifically, if the block's timestamp matches the predefined

<u><mark>`[ProxyAdminUpgradeTime](https://github.com/mantlenetworkio/op-geth/blob/5c50f43bd7d5d8b57129de183863aa8a2ecfd091/params/config.go#L713)`</mark></u> <u>[(this value](https://github.com/mantlenetworkio/op-geth/blob/4a20fa61a79e4c4cd61138e467332368d7fc8a8d/core/mantle_upgrade.go#L16)</u> was not yet set in the version of the code provided for

this audit), the proxy owner is updated to the correct address.


This approach is error-prone as it relies on the following assumptions:









If the majority of nodes update before the target <mark>`ProxyAdminUpgradeTime`</mark> <mark>,</mark> the other

minority of nodes has to update and resync the chain in order to have the correct view of

the state. Similarly, If a minority of nodes updates before the target

<mark>`ProxyAdminUpgradeTime`</mark> <mark>,</mark> the owner state update will not happen and a new

<mark>`ProxyAdminUpgradeTime`</mark> has to be scheduled.

The predefined <mark>`ProxyAdminUpgradeTime`</mark> must exactly match a future block's

timestamp for the owner upgrade to be executed successfully. If the block times are not

fixed, this is an impossible task.



[While in Mantle a fixed block time of 2 seconds](https://docs.mantle.xyz/network/introduction/whats-new-in-mantle-v2-tectonic#stable-block-time) is configured, which allows for more accurate

predictions of future block times, this reliance on precise timing remains risky.


Consider replacing the current timestamp-matching logic with a more flexible and robust

approach. For example, the owner upgrade could be executed if the block timestamp is

greater than or equal to <mark>`ProxyAdminUpgradeTime`</mark> and the upgrade has not been already

executed.


Mantle Op-geth & Op-stack Diff Audit − Low Severity − 15


**_Update:_** _Acknowledged, not resolved. The Mantle team has decided to keep the simple_

_<mark>`ProxyAdmin`</mark>_ _owner upgrade logic. The team will announce the upgrade well in advance,_

_giving nodes sufficient time to upgrade before the_ _<mark>`ProxyAdminUpgradeTime`</mark>_ _<mark>.</mark>_ _The team told_

_us that they expect only a small number of nodes to fail to to upgrade on time, and these can_

_resync to align with the correct system view._

## **Notes & Additional** **Information**

### **N-01 Missing Signature Malleability Check**


ECDSA signatures are known to be malleable due to the fact that both <mark>`(r,s)`</mark> and <mark>`(r,-s)`</mark>

are valid signatures for the same message `m` . To remove this undesirable property,

implementations typically enforce <mark>`s <= N/2`</mark> <mark>,</mark> where `N` is the order of the elliptic curve group

( <mark>`N := curve.Params().N`</mark> <mark>)</mark> . This naturally rejects the second valid signature <mark>`(r,-s)`</mark> for

which <mark>`-s=N-s > N/2`</mark> (since <mark>`s <= N/2`</mark> <mark>)</mark> .


<u>[The implementation of p256Verify](https://github.com/mantlenetworkio/op-geth/pull/93/files#diff-8403dffcbec1accad5356c19a66853e9c4cf77a1a11a2d9eeb73ed0c2022257fR1074-R1104)</u> does not apply the mentioned malleability check on the

value of `s` [. This is intentional and is motivated by the RIP-7212 standard, which states the](https://github.com/ethereum/RIPs/blob/master/RIPS/rip-7212.md#rationale)

following:


"[...] the NIST FIPS 186-5 specification does not include a malleability check. We've

matched that here [in RIP-7212] in order to maximize compatibility with the large

existing NIST P-256 ecosystem. Wrapper libraries SHOULD add a malleability check by

default, with functions wrapping the raw precompile call (exact NIST FIPS 186-5 spec,

without malleability check) clearly identified. For example, <mark>`P256.verifySignature`</mark>

and <mark>`P256.verifySignatureWithoutMalleabilityCheck`</mark> <mark>.</mark> Adding the

malleability check is straightforward and costs minimal gas."


Consider explicitly documenting that the implementation of <mark>`p256Verify`</mark> intentionally does

not have a malleability check and referring to the relevant part of the RIP-7212 standard for the

motivation.


**_Update:_** _[Resolved. The Mantle team has explicit documentation](https://docs.mantle.xyz/network/for-node-operators/network-updates/changelogs/mantle-v2-v1.1.0)_ _stating that the new_

_<mark>`p256Verify`</mark>_ _precompile does not perform any malleability checks._


Mantle Op-geth & Op-stack Diff Audit − Notes & Additional Information − 16


### **N-02 Missing Documentation**

Throughout the parts of the codebase relevant to <u>[PR #93, multiple instances of missing](https://github.com/mantlenetworkio/op-geth/pull/93)</u>

comments and opportunities for improving documentation were identified:











There is a <u>[missing comment](https://github.com/mantlenetworkio/op-geth/pull/93/files#diff-8403dffcbec1accad5356c19a66853e9c4cf77a1a11a2d9eeb73ed0c2022257fR108)</u> in <mark>`contracts.go`</mark> describing the

<mark>`PrecompiledContractsMantleEverest`</mark> map similar to the other maps (e.g., <u>[the](https://github.com/mantlenetworkio/op-geth/pull/93/files#diff-8403dffcbec1accad5356c19a66853e9c4cf77a1a11a2d9eeb73ed0c2022257fR80-R81)</u>

<u>[comment to the Berlin release).](https://github.com/mantlenetworkio/op-geth/pull/93/files#diff-8403dffcbec1accad5356c19a66853e9c4cf77a1a11a2d9eeb73ed0c2022257fR80-R81)</u>


The <mark>`newPublicKey`</mark> [function returns nil](https://github.com/mantlenetworkio/op-geth/pull/93/files#diff-d5d31c386ff355862fb3336375d40f924b43cb835dcb76cd48fec402c055fb81R13) in two cases: first, when at least one of the

coordinates is invalid (i.e., `x` or `y` or both are <mark>`nil`</mark> <mark>)</mark>, and second, when the point is not

on the curve.


The <u><mark>`[Verify](https://github.com/mantlenetworkio/op-geth/pull/93/files#diff-42aa89445835b22ad5e89bbea13ecfe2fa10b69084397e2dca6a826194f542e0R10-R22)`</mark></u> <u>function</u> does not explicitly check that the <mark>`r,s`</mark> inputs are in the correct

range <mark>`1<= r,s < N`</mark> <mark>,</mark> where `N` is the curve order. Instead, it <u>[delegates the actual](https://github.com/mantlenetworkio/op-geth/pull/93/files#diff-42aa89445835b22ad5e89bbea13ecfe2fa10b69084397e2dca6a826194f542e0R21)</u>

<u>[verification](https://github.com/mantlenetworkio/op-geth/pull/93/files#diff-42aa89445835b22ad5e89bbea13ecfe2fa10b69084397e2dca6a826194f542e0R21)</u> to the Go standard library's <mark>`ecdsa.Verify`</mark> <mark>,</mark> which performs the check

implicitly.



Consider thoroughly documenting all functions (and their parameters) that are part of any

contract's public API. In addition, for enhanced readability and maintainability consider

providing clear documentation within the codebase for cases where the behavior is not explicit

or self-explanatory.


**_Update:_** _Acknowledged, will resolve. The Mantle team stated:_


_Acknowledged. It will be fixed in the next version._

### **N-03 Improved Efficiency of Input Validation**


The <mark>`newPublicKey`</mark> function correctly <u>[validates the](https://github.com/mantlenetworkio/op-geth/pull/93/files#diff-d5d31c386ff355862fb3336375d40f924b43cb835dcb76cd48fec402c055fb81R12)</u> <u><mark>`[x,y](https://github.com/mantlenetworkio/op-geth/pull/93/files#diff-d5d31c386ff355862fb3336375d40f924b43cb835dcb76cd48fec402c055fb81R12)`</mark></u> <u>input, ensuring that:</u>



1.

2.



<mark>`x,y`</mark> is not an invalid input <mark>`nil,nil`</mark> <mark>.</mark>

The point <mark>`x,y`</mark> lies on the P256 curve by calling <mark>`IsOnCurve(x, y)`</mark> <mark>.</mark>



The function does not explicitly check that <mark>`x,y`</mark> is not the point-at-infinity, which is commonly

represented as <mark>`0,0`</mark> (in affine coordinates) (e.g., as noted in <u>[RIP-7212). However, the point](https://github.com/ethereum/RIPs/blob/master/RIPS/rip-7212.md)</u>

<mark>`0,0`</mark> does not lie on the P256 curve, so the call to <mark>`IsOnCurve`</mark> will reject it. Therefore, this

check is implicit. While the employed checks are appropriate, the function <mark>`IsOnCurve`</mark> <mark>,</mark> which

performs elliptic curve arithmetic, is computationally expensive.


Mantle Op-geth & Op-stack Diff Audit − Notes & Additional Information − 17


To improve efficiency, consider implementing a (more) efficient preliminary range check on

<mark>`x,y`</mark> before making the expensive call to <mark>`IsOnCurve`</mark> <mark>.</mark> This check is similar to what is done in

<u>[ecrecover](https://github.com/ethereum/go-ethereum/blob/8dfad579e961f4fdd718fdcf435ad68f4d6d67df/core/vm/contracts.go#L255)</u> and validates that <mark>`x,y`</mark> have the expected byte length and that their values are in

the expected range determined by the curve order <mark>`N := curve.Params().N`</mark> <mark>.</mark>


Note that the mentioned preliminary range check on <mark>`x,y`</mark> is also performed by <mark>`IsOnCurve`</mark>

and so will be done twice for valid points. As such, the decision to implement it or not depends

on how frequently <mark>`IsOnCurve`</mark> is expected to be called. Alternatively, one may modify the

<mark>`IsOnCurve`</mark> implementation in the Go standard library to remove the extra range check.


Consider implementing a preliminary range check on <mark>`x,y`</mark> keeping in mind the mentioned

efficiency trade-offs. In addition, consider explicitly rejecting the case <mark>`x,y=0,0`</mark> or at least

documenting that the check is implicit.


**_Update:_** _Acknowledged, will resolve. The Mantle team stated:_


_Acknowledged. It will be fixed in the next version._


Mantle Op-geth & Op-stack Diff Audit − Notes & Additional Information − 18


## **Conclusion**

In this update, Mantle introduced several new features and improvements over the previous

version. Notably, EigenDA has been implemented as the primary data availability layer, while

Ethereum blobs are being used as the fallback. Additionally, a new precompile for verifying

signatures on <mark>`sec256r1`</mark> have been introduced and meta transactions are being disabled.

This update also includes some minor improvements and bug fixes which increases the overall

robustness of the chain.


The audit identified one medium-severity and a few low- and note-severity issues. Although

some of the changes were adopted from Optimism, these changes have been audited

independently. The Mantle team was highly responsive and provided detailed answers to our

questions.


Mantle Op-geth & Op-stack Diff Audit − Conclusion − 19


