### | security

# **Mantle Network** **Pre-Confirmation** **Transactions** **Audit**

#### **April 3, 2025**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  5

Pre-Confirmation Mechanism 5

Block Creation 5

Address Whitelisting for Pre-confirmation Transactions 5


Security Model and Trust Assumption ________________________________________________  6

Privileged Roles 6


Critical Severity ____________________________________________________________________  7

C-01 Deposit Transactions Are Not Applied to the State for Simulation 7


High Severity ______________________________________________________________________  7

H-01 Incorrect Handling of Deposit Transactions 7


Low Severity ______________________________________________________________________  8

L-01 Incorrect Metrics Gathering 8

L-02 Validation of Pre-Confirmation Transaction Does Not Support AllPreconfs Mode 8

L-03 Missing Timeout Settings for L1 RPC and Optimism Node Connections 8

L-04 Missing Cleanup in demoteUnexecutables 9

L-05 Transactions May Be Skipped in commitTimedTransactions 9


Notes & Additional Information ____________________________________________________ 10

N-01 Incorrect Documentation 10

N-02 Unused Code 10

N-03 Confusing Debugging Logs 11

N-04 Unused Aspect of TimedTxSet 11


Client Reported __________________________________________________________________ 11

CR-01 Contract Creation Is Not Supported in AllPreconf Mode 11

CR-02 The depositTxs Slice Is Not Initialized Correctly Within UpdateOptimismSyncStatus 12


Conclusion ______________________________________________________________________ 13


Mantle Network Pre-Confirmation Transactions Audit − Table of Contents − 2


## **Summary**

**Type** Layer 2


**Timeline** From 2025-03-17
To 2025-03-25


**Languages** Go



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



1 (1 resolved)


1 (1 resolved)


0 (0 resolved)



**Total Issues** 13 (12 resolved, 1 partially resolved)



**Low Severity Issues** 5 (5 resolved)



**Notes & Additional**
**Information**


**Client Reported**
**Issues**



4 (3 resolved, 1 partially resolved)


2 (2 resolved)



Mantle Network Pre-Confirmation Transactions Audit − Summary − 3


## **Scope**

We audited the <u>[changes](https://github.com/mantlenetworkio/op-geth/compare/d28ec490317e7e0363edf5ce912fdfb2e73f0a23..6a7275cad013b9a6a97d7c0b12a94e30ff1be167)</u> [made in the mantlenetworkio/op-geth](https://github.com/mantlenetworkio/op-geth) repository between commits

<u>[d28ec49](https://github.com/mantlenetworkio/op-geth/commit/d28ec490317e7e0363edf5ce912fdfb2e73f0a23)</u> [and 6a7275c. In addition, the following individual commits were reviewed:](https://github.com/mantlenetworkio/op-geth/commit/6a7275cad013b9a6a97d7c0b12a94e30ff1be167)














Commit <u><mark>`[a6e2562](https://github.com/mantlenetworkio/op-geth/pull/103/commits/a6e2562e2f418e966cde2cd061033bf2a0c5d8ac)`</mark></u> addressing an issue related to incorrectly handling deposit

transactions.

Commit <u><mark>`[525bca0](https://github.com/mantlenetworkio/op-geth/pull/103/commits/525bca0d295afcdba21583d6f2a278786634300d)`</mark></u> addressing an issue in <mark>`IsPreconfTxFrom`</mark> to support

<mark>`AllPreconfs`</mark> mode.

Commit <u><mark>`[3cfc154](https://github.com/mantlenetworkio/op-geth/pull/103/commits/3cfc154ddf06bf71e9cd69e9fd7ad7db54667c2b)`</mark></u> related to supporting contract creation in <mark>`AllPreconf`</mark> mode.

Commit <u><mark>`[45c338f](https://github.com/mantlenetworkio/op-geth/pull/103/commits/45c338ffc512aedaa2be41ff361eec474b2ca91d)`</mark></u> addressing the correct initialization of <mark>`depositTxs`</mark> within

<mark>`UpdateOptimismSyncStatus`</mark> <mark>.</mark>

Commit <u><mark>`[d22e02a](https://github.com/mantlenetworkio/op-geth/pull/103/commits/d22e02ab603cf1d28329736b57c3531d0048c13c)`</mark></u> addressing an issue in correctly handling metrics for new pre
confirmed transactions.



In scope were the following files:

```
core
└── txpool
├── journal.go
└── txpool.go
eth
├── backend.go
└── filters
├── api.go
└── filter_system.go
internal
└── ethapi
└── api.go
miner
├── preconf_checker.go
└── worker.go
preconf
├── deposit_log.go
├── deposit_source.go
├── id.go
├── metrics.go
├── miner_config.go
├── sync_status.go
├── timed_tx_set.go
└── tx_pool_config.go

```


Mantle Network Pre-Confirmation Transactions Audit − Scope − 4


## **System Overview**

The pre-confirmation transaction feature in the Mantle Network introduces a process whereby

designated accounts can submit transactions that are validated and simulated before being

included in a block. This mechanism reduces latency, allowing systems that cannot rely on a

long block time (2 seconds) and require near-instant responses to determine transaction

validity.

### **Pre-Confirmation Mechanism**


The pre-confirmation transaction can be submitted through the API logic, which starts by

subscribing to the pre-confirmation transaction response feed and adding the transaction to

the pool of pending transactions. The transaction is then forwarded to a worker responsible for

executing pre-confirmation, verifying its validity, and ensuring successful execution.


Once the execution results are obtained, they are returned and passed to the event feed, which

subscribed parties can consume, allowing external users to monitor the status of pre
confirmation transactions. This mechanism operates almost instantaneously, providing an

immediate response without waiting for the transaction to be included in a block.

### **Block Creation**


The block creation process follows a logical sequence, starting with retrieving pending

transactions through a custom function that separates pre-confirmation transactions from

regular ones. Transactions are ordered based on priority: L1-to-L2 deposit transactions first,

followed by pre-confirmation transactions, and finally, regular transactions. This ensures that

critical operations, such as cross-chain deposits, are processed with the highest priority.

### **Address Whitelisting for Pre-confirmation** **Transactions**


Pre-confirmation transactions are currently restricted to a predefined whitelist of sender

addresses (Fiat24 Bank withdrawal accounts) and recipient addresses (Fiat24 withdrawal

contracts). This restriction ensures controlled usage of the pre-confirmation feature, thereby


Mantle Network Pre-Confirmation Transactions Audit − System Overview − 5


preventing unauthorized access. However, this behavior might change in the future, as the

update introduces a flag that allows all transactions to be treated as pre-confirmation

transactions.

## **Security Model and Trust** **Assumption**


Since there are no specific plans to disable address whitelisting for pre-confirmation

transactions, it was assumed for the scope of the audit that pre-confirmation transactions can

only be created by authorized addresses.


In addition, it was assumed that both the L1 RPC and the Optimism Node operate correctly

and in accordance with their respective specifications. Any failure, misconfiguration, or

malicious behavior of these components was considered out of scope for the system security

model.

### **Privileged Roles**


The implemented changes add a privileged role that can submit pre-confirmation transactions.

The lists of authorized addresses for transaction origins <mark>(</mark> <mark>`from`</mark> <mark>)</mark> and recipients <mark>(</mark> <mark>`to`</mark> <mark>)</mark> are

provided as configuration parameters and separated by commas.


Mantle Network Pre-Confirmation Transactions Audit − Security Model and

Trust Assumption − 6


## **Critical Severity**

### **C-01 Deposit Transactions Are Not Applied to the** **State for Simulation**

The <u><mark>`[preconfChecker](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/miner/preconf_checker.go#L37)`</mark></u> struct maintains a copy of the chain environment and a slice of

synced deposit transactions that must be considered when simulating pre-confirmed

transactions for the next block.


However, while <u>[deposit transactions are appended](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/miner/preconf_checker.go#L271)</u> to the transactions slice in the environment,

their state diff is never applied. As a result, when <u>[pre-confrmed transactions are simulatedi](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/miner/preconf_checker.go#L246)</u> <u>,</u>

they do not account for the deposit transactions that would be executed first. This can lead to

a situation where a pre-confirmed transaction is simulated successfully and emitted as an

event to the user, but during block sealing, a deposit transaction executed beforehand

interferes with it, potentially changing its outcome from success to failure.


To ensure simulation accuracy, consider applying the state diff of deposit transactions before

simulating pre-confirmed transactions. This will align the simulation environment with the

actual state during block sealing and prevent inconsistencies.


**_Update:_** _[Resolved in commit a6e2562.](https://github.com/mantlenetworkio/op-geth/commit/a6e2562e2f418e966cde2cd061033bf2a0c5d8ac)_

## **High Severity**

### **H-01 Incorrect Handling of Deposit Transactions**


Deposit transactions are not handled correctly within the pre-confirmation transactions

implementation. This causes <mark>`preconfTxs`</mark> to not be properly removed, resulting in the

<u><mark>`[extractPreconfTxsFromPending](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/core/txpool/txpool.go#L630-L683)`</mark></u> function returning incorrect data.


Consider redesigning the logic so that <mark>`extractPreconfTxsFromPending`</mark> correctly extracts

pre-confirmed transactions from the pending list.


**_Update:_** _[Resolved in commit a6e2562.](https://github.com/mantlenetworkio/op-geth/commit/a6e2562e2f418e966cde2cd061033bf2a0c5d8ac)_


Mantle Network Pre-Confirmation Transactions Audit − Critical Severity − 7


## **Low Severity**

### **L-01 Incorrect Metrics Gathering**

The <u><mark>`[Add](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/preconf/timed_tx_set.go#L35-L63)`</mark></u> <u>[function](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/preconf/timed_tx_set.go#L35-L63)</u> in <mark>`timed_tx_set.go`</mark> replaces an existing transaction by <u>[removing it from](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/preconf/timed_tx_set.go#L46-L54)</u>

<u>[the queue](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/preconf/timed_tx_set.go#L46-L54)</u> [and re-adding it to the end. However, it](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/preconf/timed_tx_set.go#L57-L58) <u>[increments metrics and logs](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/preconf/timed_tx_set.go#L60-L62)</u> each time

without distinguishing replacements from new additions, suggesting that a new pre-confirmed

transaction was added, even for updates. This could inflate pre-confirmation counts and

mislead monitoring.


Consider incrementing metrics only for new transactions to accurately reflect additions.


**_Update:_** _[Resolved in commit d22e02a.](https://github.com/mantlenetworkio/op-geth/commit/d22e02ab603cf1d28329736b57c3531d0048c13c)_

### **L-02 Validation of Pre-Confirmation Transaction** **Does Not Support AllPreconfs Mode**


The <u><mark>`[IsPreconfTxFrom](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/preconf/tx_pool_config.go#L29-L36)`</mark></u> function validates whether the <mark>`from`</mark> address belongs to the list of

authorized addresses. However, it does not take into account the <mark>`AllPreconfs`</mark> mode, which

enables all transactions to be pre-confirmation transactions. In addition, the logic in

<u><mark>`[IsPreconfTx](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/preconf/tx_pool_config.go#L44-L46)`</mark></u> checks if the <mark>`AllPreconfs`</mark> mode is enabled, but it does so only after

verifying the <mark>`from`</mark> and <mark>`to`</mark> addresses.


Consider returning <mark>`true`</mark> for both the <mark>`IsPreconfTxFrom`</mark> and <mark>`IsPreconfTx`</mark> functions

when the <mark>`AllPreconfs`</mark> mode is enabled.


**_Update:_** _[Resolved in commit 525bca0.](https://github.com/mantlenetworkio/op-geth/pull/103/commits/525bca0d295afcdba21583d6f2a278786634300d)_

### **L-03 Missing Timeout Settings for L1 RPC and** **Optimism Node Connections**


[The connections to the L1 RPC](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/miner/preconf_checker.go#L103) [and Optimism Node](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/miner/preconf_checker.go#L78) do not have defined timeout options. This

could lead to issues if the server accepts the connection but fails to respond to the request.


Consider adding a timeout to external connections.


**_Update:_** _[Resolved in commit 2e2875c.](https://github.com/mantlenetworkio/op-geth/pull/103/commits/2e2875c09f781f9d1006235da8ca467f202cdaf0)_


Mantle Network Pre-Confirmation Transactions Audit − Low Severity − 8


### **L-04 Missing Cleanup in demoteUnexecutables**

The <u><mark>`[demoteUnexecutables](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/core/txpool/txpool.go#L1968)`</mark></u> <u>function</u> is invoked during a chain reorganization (reorg)—when

a blockchain node switches to a new, longer chain, potentially invalidating transactions from

the old chain—to clean up the mempool by removing or re-queuing transactions from the

pending pool that are no longer valid due to insufficient gas, low account balance, or outdated

nonces reflecting the updated state. While it <u>[removes](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/core/txpool/txpool.go#L1996)</u> unpayable (low balance or out-of-gas)

transactions from the <mark>`all`</mark> lookup set, it does not remove them from the <mark>`preconfTxs`</mark> set,

leaving pre-confirmed transactions that are no longer executable in the pool. This could lead to

unnecessary re-evaluation of these transactions in future cycles, even though they are unlikely

to succeed, whereas they could instead be directly removed for consistency and efficiency.


Consider removing these costly (low balance or out-of-gas) transactions from the

<mark>`preconfTxs`</mark> set to ensure that only executable, pre-confirmed transactions remain.


**_Update:_** _[Resolved in commit 547cdf8.](https://github.com/mantlenetworkio/op-geth/pull/103/commits/547cdf8c72bffbc2a19da5547d5cf1388355169e)_

### **L-05 Transactions May Be Skipped in** **`commitTimedTransactions`**


The <u><mark>`[commitTimedTransaction](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/miner/worker.go#L1033-L1117)`</mark></u> <u>function</u> function is called during block construction to

process a list of pre-confirmed transactions <mark>(</mark> <mark>`txs`</mark> <mark>)</mark> . However, it breaks if <u><mark>`[tx](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/miner/worker.go#L1042-L1044)`</mark></u> <u>[is equal to](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/miner/worker.go#L1042-L1044)</u> <u><mark>`[nil](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/miner/worker.go#L1042-L1044)`</mark></u>,

based on a comment suggesting that <mark>`nil`</mark> only appears at the end. While the current logic

implies that <mark>`txs`</mark> should not contain nil entries, an unexpected <mark>`nil`</mark> in the middle of the list

could cause the function to break early, skipping subsequent valid transactions. This could

result in valid transactions being excluded from the block when they should be processed.


Consider removing the <mark>`nil`</mark> check or using <mark>`continue`</mark> instead of <mark>`break`</mark> to ensure that all

valid transactions are processed.


**_Update:_** _[Resolved in commit 2e2875c.](https://github.com/mantlenetworkio/op-geth/pull/103/commits/2e2875c09f781f9d1006235da8ca467f202cdaf0)_


Mantle Network Pre-Confirmation Transactions Audit − Low Severity − 9


## **Notes & Additional** **Information**

### **N-01 Incorrect Documentation**

Throughout the codebase, multiple instances of incorrect documentation were identified:













The comment for the <u><mark>`[SubscribePreconfTxs](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/eth/filters/filter_system.go#L437)`</mark></u> function is copied from

<mark>`SubscribePendingTxs`</mark> <mark>.</mark>

The comment for the <u><mark>`[SendRawTransactionWithPreconf](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/internal/ethapi/api.go#L2171)`</mark></u> function is copied from

<mark>`SendRawTransaction`</mark> <mark>.</mark>

The comment in the <u><mark>`[rotate](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/core/txpool/journal.go#L148)`</mark></u> <u>function</u> about adding regular transactions to the journal is

inaccurate.

Several comments describing the default configuration are incorrect:




     - The <mark>`MantleToleranceDuration`</mark> is <u>[6 seconds, not 5.](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/miner/preconf_checker.go#L210)</u>

     - The <mark>`EthToleranceDuration`</mark> is <u>[72 seconds, not 30.](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/miner/preconf_checker.go#L216)</u>

     - The <mark>`EthToleranceBlock`</mark> is <u>[6 blocks, not 5.](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/miner/preconf_checker.go#L228)</u>


Consider reviewing the codebase to correct these inaccuracies to improve its overall

readability and correctness.


**_Update:_** _[Resolved in commits 1d76268, 2a2f613](https://github.com/mantlenetworkio/op-geth/pull/103/commits/1d76268e059ee27a41eb36bfe17c4a83d21b706d)_ _[and a6e2562.](https://github.com/mantlenetworkio/op-geth/pull/103/commits/a6e2562e2f418e966cde2cd061033bf2a0c5d8ac)_

### **N-02 Unused Code**


Throughout the codebase, multiple instances of unused code were identified:











In <mark>`txpool.go`</mark> <mark>,</mark> the <mark>`handlePreconfTxs`</mark> [function aggregates](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/core/txpool/txpool.go#L1289) all non-timeout pre
confirmation transactions and returns them, but its return value is never used.

In <mark>`deposit_log.go`</mark> <mark>,</mark> the <u><mark>`[MarshalDepositLogEventV0](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/preconf/deposit_log.go#L215)`</mark></u> and

<u><mark>`[marshalDepositVersion0](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/preconf/deposit_log.go#L263)`</mark></u> functions are unused.

None of the functions in <u><mark>`[id.go](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/preconf/id.go)`</mark></u> are used.



Consider removing these unused functions to improve the clarity and maintainability of the

codebase.


Mantle Network Pre-Confirmation Transactions Audit − Notes & Additional

Information − 10


**_Update:_** _Partially resolved in commit_ _<u>[2e2875c. The files](https://github.com/mantlenetworkio/op-geth/pull/103/commits/2e2875c09f781f9d1006235da8ca467f202cdaf0)</u>_ _<mark>`deposit_log.go`</mark>_ _and_ _<mark>`id.go`</mark>_

_remained unchanged as they are a direct copy from the op-node component._

### **N-03 Confusing Debugging Logs**


[In case adding a pre-confrmed transaction to the journal failsi](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/core/txpool/txpool.go#L1301-L1304) <u>, the logged warnings are</u>

confusing. The logs will first indicate that the transaction failed, followed by information

suggesting that the transaction was journaled.


Consider adding an <mark>`else`</mark> statement to indicate that the transaction was journaled if no error

occurred.


**_Update:_** _[Resolved in commit 2e2875c.](https://github.com/mantlenetworkio/op-geth/pull/103/commits/2e2875c09f781f9d1006235da8ca467f202cdaf0#diff-8b4e997b7db214641f4e025b3434f20d9106e68f833909d679248e70665251be)_

### **N-04 Unused Aspect of TimedTxSet**


<u><mark>`[TimedTxSet](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/preconf/timed_tx_set.go#L13)`</mark></u> manages the order of incoming pre-confirmed transactions in a FIFO manner.

However, two aspects of this struct may cause confusion:









Its name suggests that transactions are timed for execution at a specific point in the

future.

The <u><mark>`[addedTime](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/preconf/timed_tx_set.go#L22)`</mark></u> field, which tracks when a transaction was added to the set, is unused.



Consider renaming the set to something that better reflects its FIFO nature and removing the

unused <mark>`addedTime`</mark> field.


**_Update:_** _[Resolved in commit 1d76268.](https://github.com/mantlenetworkio/op-geth/pull/103/commits/1d76268e059ee27a41eb36bfe17c4a83d21b706d)_

## **Client Reported**

### **CR-01 Contract Creation Is Not Supported in** **AllPreconf Mode**


The <u><mark>`[handlePreconfTxs](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/core/txpool/txpool.go#L1231-L1319)`</mark></u> function is responsible for handling pre-confirmed transactions. The

issue is that it includes <u>logic to ensure that the</u> <u><mark>`[To](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/core/txpool/txpool.go#L1248-L1251)`</mark></u> <u>[address is not a zero address. This is](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/core/txpool/txpool.go#L1248-L1251)</u>

problematic because contract creation transactions use the zero address for the <mark>`To`</mark> parameter


Mantle Network Pre-Confirmation Transactions Audit − Client Reported − 11


and, while contract creation is not intended for pre-confirmed transactions, enabling the

<mark>`AllPreconf`</mark> mode might prevent contract creation.


Consider removing the check that the <mark>`To`</mark> address cannot be a zero address.


**_Update:_** _[Resolved in commit 3cfc154.](https://github.com/mantlenetworkio/op-geth/commit/3cfc154ddf06bf71e9cd69e9fd7ad7db54667c2b)_

### **CR-02 The depositTxs Slice Is Not Initialized** **Correctly Within UpdateOptimismSyncStatus**


The <mark>`depositTxs`</mark> slice within <u><mark>`[UpdateOptimismSyncStatus](https://github.com/mantlenetworkio/op-geth/blob/6a7275cad013b9a6a97d7c0b12a94e30ff1be167/miner/preconf_checker.go#L131-L182)`</mark></u> is not initialized properly. This

lack of proper initialization could lead to incorrect handling of deposit transactions, potentially

causing errors in transaction processing or inconsistencies in the system's state.


It is recommended to redesign the logic to ensure that the <mark>`depositTxs`</mark> slice is initialized

correctly.


**_Update:_** _[Resolved in commit 45c338f.](https://github.com/mantlenetworkio/op-geth/commit/45c338ffc512aedaa2be41ff361eec474b2ca91d)_


Mantle Network Pre-Confirmation Transactions Audit − Client Reported − 12


## **Conclusion**

While the pre-confirmed transaction feature enhances efficiency and reduces transaction

latency, it also introduces new security challenges. The current implementation mitigates key

risks through structured prioritization, event-driven state management, and stringent validation

mechanisms. However, expanding beyond whitelisted addresses will require additional

protections to prevent abuse and ensure equitable access to transaction prioritization.


The audited codebase was a work in progress, undergoing multiple code and design changes

during the audit, including fixes for issues identified by both the development and auditing

teams. It is highly recommended that the codebase undergoes an extensive testing phase and

another round of auditing to ensure the system is secure and safe for deployment.


Communication with the Mantle team was seamless, and they were transparent in explaining

the inner workings of the system. Furthermore, they promptly implemented the suggested

solutions to address the vulnerabilities identified early in the audit.


Mantle Network Pre-Confirmation Transactions Audit − Conclusion − 13


