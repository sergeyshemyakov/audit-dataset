### | security

# **EIP-4337 –** **Ethereum** **Account** **Abstraction** **Incremental** **Audit**

#### **February 23, 2023**

This security assessment was prepared by
**OpenZeppelin** .


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  4


Scope ____________________________________________________________________________  5


System Overview __________________________________________________________________  7


Client-Reported Findings ___________________________________________________________  8

Detect warm storage accesses 8

Leaked Base Fee 8

Replay on verifying paymaster 8

Self-destruct EIP4337Manager 9

Revert reason bombing 9


High Severity ____________________________________________________________________ 10

H-01 Invalid aggregate signature [samples] 10


Low Severity ____________________________________________________________________ 11

L-01 Accounts cannot replace EntryPoint [samples] 11

L-02 Gnosis safe reverts on signature failure [samples] 11

L-03 Imprecise time range [core] 11

L-04 Incorrect or misleading documentation [core and samples] 12

L-05 Misleading specification [core] 13

L-06 Mismatched event parameter [core] 14

L-07 Missing docstrings [core and samples] 14

L-08 Missing error messages in require statements [core and samples] 15

L-09 Missing recommended function [samples] 15

L-10 Uninitialized implementation contract [samples] 16

L-11 Unrestrained revert reason [core] 16

L-12 Unsafe ABI encoding 17


EIP-4337 – Ethereum Account Abstraction Incremental Audit − Table of

Contents − 2


Notes & Additional Information ____________________________________________________ 17

N-01 Declare uint/int as uint256/int256 [core and samples] 17

N-02 File relocation recommendations [samples] 18

N-03 IAccount inheritance anti-pattern 18

N-04 Implicit size limit [core] 18

N-05 Incomplete event history [samples] 19

N-06 Lack of indexed parameter [core] 19

N-07 Naming suggestions [core and samples] 19

N-08 Inconsistent ordering [core and samples] 21

N-09 Stake size inconsistency [core] 21

N-10 TODO comments [core and samples] 21

N-11 Typographical errors [core and samples] 22

N-12 Unused imports [samples] 24

N-13 Unused interface [core] 25

N-14 References to previously used "wallet" terminology [samples] 25


Conclusions  _____________________________________________________________________ 26


Appendix _______________________________________________________________________ 26

Monitoring Recommendations 26


EIP-4337 – Ethereum Account Abstraction Incremental Audit − Table of

Contents − 3


## **Summary**

**Type** DeFi


**Timeline** From 2023-01-09
To 2023-01-27


**Languages** Solidity



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


1 (1 resolved)


0 (0 resolved)



**Total Issues** 27 (23 resolved, 4 partially resolved)



**Low Severity Issues** 12 (10 resolved, 2 partially resolved)



**Notes & Additional**
**Information**



14 (12 resolved, 2 partially resolved)



EIP-4337 – Ethereum Account Abstraction Incremental Audit − Summary − 4


## **Scope**

<u>[EIP-4337](https://eips.ethereum.org/EIPS/eip-4337)</u> is a specification to add account abstraction functionality to the Ethereum mainnet

without modifying the consensus rules. The <u>[Ethereum Foundation](https://ethereum.org/)</u> asked us to review the latest

version revision of their specification and reference implementation.


We audited the <u>[eth-infinitism/account-abstraction](https://github.com/eth-infinitism/account-abstraction)</u> repository at the

<u>[6dea6d8752f64914dd95d932f673ba0f9ff8e144](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144)</u> commit.


In scope were the following contracts:

```
contracts
├── bls
│  ├── BLSAccount.sol
│  ├── BLSAccountFactory.sol
│  ├── BLSSignatureAggregator.sol
│  └── IBLSAccount.sol
├── core
│  ├── BaseAccount.sol
│  ├── BasePaymaster.sol
│  ├── EntryPoint.sol
│  ├── SenderCreator.sol
│  └── StakeManager.sol
├── gnosis
│  ├── EIP4337Fallback.sol
│  ├── EIP4337Manager.sol
│  └── GnosisAccountFactory.sol
├── interfaces
│  ├── IAccount.sol
│  ├── IAggregatedAccount.sol
│  ├── IAggregator.sol
│  ├── ICreate2Deployer.sol
│  ├── IEntryPoint.sol
│  ├── IPaymaster.sol
│  ├── IStakeManager.sol
│  └── UserOperation.sol
├── samples
│  ├── DepositPaymaster.sol
│  ├── IOracle.sol
│  ├── SimpleAccount.sol
│  ├── SimpleAccountFactory.sol
│  ├── TestAggregatedAccount.sol
│  ├── TestAggregatedAccountFactory.sol
│  ├── TestSignatureAggregator.sol
│  ├── TokenPaymaster.sol
│  └── VerifyingPaymaster.sol

```

EIP-4337 – Ethereum Account Abstraction Incremental Audit − Scope − 5


```
└── utils
└── Exec.sol

```

Originally `BLSHelper.sol` was in scope, but we agreed to deprioritize a complete review

during the audit.


**_Update:_** _As part of the fix review process, we reviewed the pull requests that affect in-scope_

_contracts up to commit_ _<u>`[f3b5f79](https://github.com/eth-infinitism/account-abstraction/commit/f3b5f795515ad8a7a7bf447575d6554854b820da)`</u>_ _._


EIP-4337 – Ethereum Account Abstraction Incremental Audit − Scope − 6


## **System Overview**

The system architecture is described in <u>[our original audit report, and now contains a series of](https://blog.openzeppelin.com/eth-foundation-account-abstraction-audit/)</u>

important changes.


For instance, users and paymasters can now both change the EVM state when validating an

operation. This is more general and mitigates the need for a paymaster to have after-revert

functionality, which may be removed in a future version. To support this change, additional

storage restrictions (described in the EIP) have been added to ensure all validations in a batch

access non-overlapping sets of storage slots. In addition, user operations can delegate their

validation to an "Aggregator" smart contract, which allows all operations that share an

aggregator to be validated together. Aggregators are subject to the same staking and throttling

rules as paymasters.


To forestall possible confusion, it is worth noting that in this context, "aggregation" refers to

any mechanism that can authenticate independent user operations efficiently. The sample

`BLSSignatureAggregator` contract efficiently validates several BLS signatures over

different user operations, but does not use the standard <u>[BLS Signature Aggregation](https://mirror.xyz/0x6afeB3d9E380787e7D0a17Fc3CA764Bb885014FA/D3g-4UPRLkAnug-p6AZYfjgXWo-psaTulyu3SaL35vg)</u> technique,

which produces a combined signature over a single message. Regardless, the system

supports accounts with arbitrary validation logic, so anyone could deploy an account that

accepts aggregate BLS signatures over a single message (to produce a multi-signature wallet,

for example).


There are also a few incremental changes:


   - New accounts are now initialized with user-chosen factory contracts to provide more

flexibility during deployment.

   - The term "wallet" has been replaced with "account".

   - Users can set time restrictions that define when an operation is valid.

   - Senders can now have multiple operations in a batch if they are also staked.


EIP-4337 – Ethereum Account Abstraction Incremental Audit − System

Overview − 7


## **Client-Reported Findings**

### **Detect warm storage accesses**

**Client reported:** _The Ethereum Foundation identified this issue during the audit._


During simulation, the `EntryPoint` contract <u>[invokes a view function](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L359)</u> on the sender contract,

before proceeding with the <u>[regular validation. Since the first access of any storage slot is](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L371)</u> <u>[more](https://eips.ethereum.org/EIPS/eip-2929)</u>

<u>[expensive than subsequent accesses, the view function could perform the initial "cold](https://eips.ethereum.org/EIPS/eip-2929)</u>

accesses" to allow the regular validation function to use "warm accesses". If the different gas

costs determined whether the validation function ran out of gas, the validation would succeed

during simulation but fail on-chain. In this scenario, the bundler would have to pay for the failed

transaction.


**_Update:_** _Resolved in_ _<u>[pull request #216](https://github.com/eth-infinitism/account-abstraction/pull/216)</u>_ _and merged at commit_ _<u>`[1f505c5](https://github.com/eth-infinitism/account-abstraction/commit/1f505c5889b04a115b1bf09386c0b84cecdad5c4)`</u>_ _. The aggregator logic_

_has been redesigned, which makes this issue obsolete._

### **Leaked Base Fee**


**Client reported:** _The Ethereum Foundation identified this issue before the audit._


The EIP <u>[forbids accounts](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/eip/EIPS/eip-4337.md?plain=1&#L375-L376)</u> from using the `BASEFEE` opcode during validation, to prevent them

from detecting when they are being simulated offline. However, the `EntryPoint` contract

<u>[passes the required pre-fund to the account, which](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L371)</u> <u>[depends on the base fee, thereby leaking](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L581)</u>

this value.


**_Update:_** _Resolved in_ _<u>[pull request #171](https://github.com/eth-infinitism/account-abstraction/pull/171)</u>_ _and merged at commit_ _<u>`[b34b7a0](https://github.com/eth-infinitism/account-abstraction/commit/b34b7a0b61623e59f64a06828637fbb52e9862ef)`</u>_ _. The prefund amount_

_now uses the maximum possible gas price._

### **Replay on verifying paymaster**


**Client reported:** _The Ethereum Foundation shared this issue with us during the audit after it_

_was reported by_ _<u>[leekt.](https://github.com/leekt)</u>_


The `VerifyingPaymaster` contract requires the trusted signer to sign <u>[a hash of a user](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/VerifyingPaymaster.sol#L36)</u>

<u>[operation. However, the signature is under-specified. In particular:](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/VerifyingPaymaster.sol#L36)</u>


   - It is not locked to a particular chain or paymaster.


EIP-4337 – Ethereum Account Abstraction Incremental Audit − Client
Reported Findings − 8


   - It does not take advantage of the new <u>[time restriction option.](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IPaymaster.sol#L23)</u>

   - It relies on the account's nonce for replay protection. If the account could process the

same operation multiple times, the signature would remain valid every time.


**_Update:_** _Resolved in_ _<u>[pull request #184](https://github.com/eth-infinitism/account-abstraction/pull/184)</u>_ _and merged at commit_ _<u>`[48854ef](https://github.com/eth-infinitism/account-abstraction/commit/48854ef5ada1c966475b2074703ad983329faacf)`</u>_ _._

### **Self-destruct EIP4337Manager**


**Client reported:** _The Ethereum Foundation shared this issue with us during the audit after it_

_was reported by_ _<u>[leekt.](https://github.com/leekt)</u>_


The `EIP4337Manager` contract is intended to augment `GnosisSafe` contracts, by

providing a <u>[user op validation function. Safe contracts (technically their proxies) are intended to](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/gnosis/EIP4337Manager.sol#L36)</u>

use `delegatecall` to access this function.


However, anyone can configure the manager contract <u>[with new modules. Since the manager](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/gnosis/EIP4337Manager.sol#L66)</u>

contract <u>inherits</u> <u>`[GnosisSafe](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/gnosis/EIP4337Manager.sol#L23)`</u> <u>functionality, the new modules can</u> <u>[trigger arbitrary function](https://github.com/safe-global/safe-contracts/blob/v1.3.0/contracts/base/ModuleManager.sol#L61)</u>

<u>[calls](https://github.com/safe-global/safe-contracts/blob/v1.3.0/contracts/base/ModuleManager.sol#L61)</u> and potentially self-destruct the contract. This would effectively disable the manager

module for all safes that used it.


**_Update:_** _Resolved in_ _<u>[pull request #208](https://github.com/eth-infinitism/account-abstraction/pull/208)</u>_ _and merged at commit_ _<u>`[d92fec8](https://github.com/eth-infinitism/account-abstraction/commit/d92fec8983a47b6c2535e04fd66f684b1220f8a0)`</u>_ _._

### **Revert reason bombing**


**Client reported:** _The Ethereum Foundation identified this issue during the audit._


The `EntryPoint` contract has four locations where an external function call can revert with

an arbitrarily large message that the `EntryPoint` must copy to its own memory. Each

instance has a different practical consequence:


   - The <u>[first instance](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L223)</u> occurs after a user operation completes, which effectively allows the

operation to consume much more than the allocated `callGasLimit` . If this occurs on
chain, the user (or the paymaster) will still be charged for the extra gas consumed. If

instead the entire bundle reverted, the `FailedOp` error would not be returned, so the

bundler would not easily recognize the problematic operation.

   - The <u>[second instance](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L374)</u> occurs when a user's validation fails. This operation will be

discarded anyway without being added to a bundle, so it can be ignored.

   - The <u>[third](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L416)</u> and <u>[fourth](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L548)</u> instances occur when the paymaster validates or concludes a user

operation. Either could occur for the first time once the operation is in a bundle, and

could also cause the entire bundle to be reverted without returning a `FailedOp` error.


EIP-4337 – Ethereum Account Abstraction Incremental Audit − Client
Reported Findings − 9


**_Update:_** _Partially resolved in_ _<u>[pull request #178](https://github.com/eth-infinitism/account-abstraction/pull/178)</u>_ _and merged at commit_ _<u>`[9c00e78](https://github.com/eth-infinitism/account-abstraction/commit/9c00e784fa45fef5d771c9ec3f971edca0c82aa4)`</u>_ _. Only the user_

_operation revert reason was limited._

## **High Severity**

### **H-01 Invalid aggregate signature [samples]**


The `BLSSignatureAggregator` exposes a mechanism to let the bundler <u>[validate individual](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSSignatureAggregator.sol#L123)</u>

<u>[signatures](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSSignatureAggregator.sol#L123)</u> before constructing the bundle. Successful operations are grouped so the bundler

can <u>[combine their signatures](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSSignatureAggregator.sol#L143)</u> off-chain and the `EntryPoint` can <u>[validate them together](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L142)</u> on
chain. However, it is possible for an account to construct an operation that will pass the

individual-signature check and still fail the combined-signature check.


In particular, if the public key it exposes <u>[during the individual validation](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSSignatureAggregator.sol#L126)</u> is different from the one

used <u>[during the combined validation, the two validations will be inconsistent even though the](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSSignatureAggregator.sol#L60)</u>

signature is the same. This could occur if the <u>[last 4 words of the](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSSignatureAggregator.sol#L23)</u> <u>`[initCode](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSSignatureAggregator.sol#L23)`</u> do not match the

public key (because the `initCode` has additional data, or if they do not use the <u>[expected](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSAccountFactory.sol#L29)</u>

<u>[creation function). It could also occur if the](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSAccountFactory.sol#L29)</u> <u>[user's validation function](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L135)</u> (which is not invoked

during the individual signature validation) changes the public key that is returned by

`getBlsPublicKey` .


If a bundler constructs a bundle with these operations, it will be unable to validate the

combined signature and will attribute the fault to the aggregator, which will cause the

aggregator to be throttled and user operations with the same aggregator will not be processed.


Consider synchronizing the two validation functions so they both use the same public key.


**_Update:_** _Resolved in_ _<u>[pull request #195](https://github.com/eth-infinitism/account-abstraction/pull/195)</u>_ _as well as commit_ _<u>`[268f103](https://github.com/eth-infinitism/account-abstraction/pull/216/commits/268f103597c0406ba2595cf18d3d5a5473b9c7b9)`</u>_ _of_ _<u>[pull request #216,](https://github.com/eth-infinitism/account-abstraction/pull/216)</u>_

_which were merged at commits_ _<u>`[1cc1c97](https://github.com/eth-infinitism/account-abstraction/commit/1cc1c97a00131a7922d1ccebd823e81e823b5d9f)`</u>_ _and_ _<u>`[1f505c5](https://github.com/eth-infinitism/account-abstraction/commit/1f505c5889b04a115b1bf09386c0b84cecdad5c4)`</u>_ _respectively._


EIP-4337 – Ethereum Account Abstraction Incremental Audit − High Severity

                                                - 10


## **Low Severity**

### **L-01 Accounts cannot replace EntryPoint** **[samples]**

The <u>[comments](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/SimpleAccount.sol#L76-L78)</u> describing the `initialize` function of the `SimpleAccount` contract claim

there should be a mechanism to replace the `EntryPoint` contract. This does not match the

behavior of the function it describes, and in fact, there is no mechanism to replace the

`EntryPoint` contract without upgrading the whole account.


Consider updating the comment to match the behavior, and introducing a mechanism to

replace the `EntryPoint` contract if that functionality is desired.


**_Update:_** _Resolved in_ _<u>[pull request #192](https://github.com/eth-infinitism/account-abstraction/pull/192)</u>_ _and merged at commit_ _<u>`[82685b2](https://github.com/eth-infinitism/account-abstraction/commit/82685b233feaad7b63f2744137855e939f1146b6)`</u>_ _. A @dev comment_

_was added to the docstring of the_ _`initialize`_ _function to clarify that the_ _`_entryPoint`_

_storage variable is not a parameter of the initializer because an upgrade is required to change_

_the EntryPoint address._

### **L-02 Gnosis safe reverts on signature failure** **[samples]**


The <u>[documentation](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L32-L33)</u> for the `SIG_VALIDATION_FAILED` constant states that

`validateUserOp` must return this value instead of reverting if signature validation fails. The

`SimpleAccount` contract <u>[correctly follows](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/SimpleAccount.sol#L110-L111)</u> the specification, however in the

`EIP4337Manager` contract, the `validateUserOp` function <u>[reverts](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/gnosis/EIP4337Manager.sol#L45)</u> if the signature validation

fails. This means the <u>`[simulateValidation](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L273)`</u> <u>function</u> will revert without providing a

`ValidationResult` object.


Consider changing the logic so that `validateUserOp` returns `SIG_VALIDATION_FAILED`

in all cases where an invalid signature is encountered.


**_Update:_** _Resolved in_ _<u>[pull request #181](https://github.com/eth-infinitism/account-abstraction/pull/181)</u>_ _and merged at commit_ _<u>`[1dfb173](https://github.com/eth-infinitism/account-abstraction/commit/1dfb17366fb85598aadc8f4a5cb111d4ae159f26)`</u>_ _._

### **L-03 Imprecise time range [core]**


The `EntryPoint` contract <u>[decrements the operation expiry timestamp](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L460)</u> in order to convert `0`

(which should be interpreted as "no expiry") to the maximum `uint64` value. However, every


EIP-4337 – Ethereum Account Abstraction Incremental Audit − Low Severity

                                                - 11


other possible expiry value is now off by one. In the interest of predictability, consider only

modifying the `0` timestamp.


**_Update:_** _Resolved in_ _<u>[pull request #193](https://github.com/eth-infinitism/account-abstraction/pull/193)</u>_ _and merged at commit_ _<u>`[973c0ac](https://github.com/eth-infinitism/account-abstraction/commit/973c0ac1e54b2f5209e1c3ba2df8585ae27a7fa5)`</u>_ _._

### **L-04 Incorrect or misleading documentation** **[core and samples]**


Several docstrings and inline comments throughout the code base were found to be incorrect

or misleading. In particular:


   - In `BaseAccount.sol` :


    - <u>[Line 72: The docstring defines](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/BaseAccount.sol#L72)</u> `sigTimeRange` as "signature and time-range for

this operation", but it contains the signature validity, not the signature itself.




- In `BLSSignatureAggregator.sol` :




- <u>[Line 117: The docstring references a call to](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSSignatureAggregator.sol#L117)</u> `simulateUserOperation` . The



function name should be `simulateValidation` .


- In `EIP4337Manager.sol` :




- <u>[Line 21: The docstring states the contract inherits](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/gnosis/EIP4337Manager.sol#L21)</u> `GnosisSafeStorage`, but it



actually inherits `GnosisSafe` .


- In `EntryPoint.sol` :




- <u>[Line 180: The comment does not include](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L180)</u> <u>`[paymasterAndData](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/UserOperation.sol#L30)`</u> as one of the



dynamic byte arrays being excluded from `MemoryUserOp` .

  - <u>[Line 393: The docstring states that](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L393)</u> `_validatePaymasterPrepayment`

validates that the paymaster is staked, but the function does not perform this

check.


- In `IPaymaster.sol` :




- <u>[Lines 25-26: The docstring states that the](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IPaymaster.sol#L25-L26)</u> `validUntil` and `validAfter`

timestamps are 4 bytes in length, but these are 8-byte (uint64) values.


EIP-4337 – Ethereum Account Abstraction Incremental Audit − Low Severity

                                          - 12


- In `IStakeManager.sol` :


  - <u>[Line 7, lines 43-44: Docstrings in this contract refer to staking only for paymasters,](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IStakeManager.sol#L7)</u>

implying this is the only entity that should stake. Signature aggregators and

factories are also required to stake following the same rules as paymasters.

  - <u>[Line 45: The docstring makes a reference to the "global unstakeDelaySec", which](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IStakeManager.sol#L45)</u>

no longer exists.

  - <u>[Line 47: The](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IStakeManager.sol#L47)</u> `DepositInfo` docstring explains that the variable sizes were

chosen so that `deposit` and `staked` fit into a single `uint256` word, but the

3rd parameter `stake` will also fit.




- In `SimpleAccount.sol` :




- <u>[Line 52: The comment makes a reference to the](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/SimpleAccount.sol#L52)</u> `execFromEntryPoint` function,



which no longer exists.

  - <u>[Line 57: The docstring for](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/SimpleAccount.sol#L57)</u> `execute` says "called directly from owner, not by

entryPoint", but the <u>`[_requireFromEntryPointOrOwner](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/SimpleAccount.sol#L60)`</u> function allows

`execute` to be called by the EntryPoint. The comment isn't clear on whether it is

a suggestion, or a restriction to be enforced.

  - <u>[Lines 75-79: The docstring does not match the](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/SimpleAccount.sol#L75-L79)</u> `initialize` function.

  - <u>[Lines 89-96: The docstring does not match the](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/SimpleAccount.sol#L89-L96)</u>

`_requireFromEntryPointOrOwner` function.


- In `IEntryPoint.sol` :




- <u>[Line 26: The](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IEntryPoint.sol#L26)</u> `@success` parameter is listed in the wrong order.




- In `UserOperation.sol` :




- <u>[Line 25: The](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/UserOperation.sol#L25)</u> `callGasLimit` parameter has no `@param` statement.



**_Update:_** _Resolved in_ _<u>[pull request #194](https://github.com/eth-infinitism/account-abstraction/pull/194)</u>_ _and_ _<u>[pull request #216, which were merged at commits](https://github.com/eth-infinitism/account-abstraction/pull/216)</u>_

_<u>`[faf305e](https://github.com/eth-infinitism/account-abstraction/commit/faf305e3022ac7daa7cafb141ffe1dc1f936ee6c)`</u>_ _and_ _<u>`[1f505c5](https://github.com/eth-infinitism/account-abstraction/commit/1f505c5889b04a115b1bf09386c0b84cecdad5c4)`</u>_ _respectively._

### **L-05 Misleading specification [core]**


The EIP <u>[states](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/eip/EIPS/eip-4337.md?plain=1#L365)</u> that when a `FailedOp` is detected, all other operations from the same

paymaster should be removed from the current batch. However, this should only apply to

`FailedOp` errors that explicitly mention the paymaster, which imply the paymaster was at

fault. Operations that fail for unrelated reasons should not penalize their paymaster.


EIP-4337 – Ethereum Account Abstraction Incremental Audit − Low Severity

                                                - 13


The EIP also <u>[states](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/eip/EIPS/eip-4337.md?plain=1#L322)</u> that `userOp` validation cannot call the `handleOps` method. This

restriction should also apply to `handleAggregatedOps` .


Consider clarifying these points in the EIP.


**_Update:_** _Partially resolved in_ _<u>[pull request #196](https://github.com/eth-infinitism/account-abstraction/pull/196)</u>_ _and merged at_ _<u>`[5929ff8](https://github.com/eth-infinitism/account-abstraction/commit/5929ff80077e0e8dbf91c9ee234b73caa8d94bbc)`</u>_ _. The updated EIP_

_mistakenly refers to the EntryPoint's_ _`depositTo`_ _function as_ _`depositFor`_ _._

### **L-06 Mismatched event parameter [core]**


The `StakeLocked` event specifies a <u>`[withdrawTime](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IStakeManager.sol#L26)`</u> <u>parameter, but the argument passed in</u>

is the <u>[new unstake delay. Consider renaming the event parameter to match its actual usage.](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/StakeManager.sol#L73)</u>


**_Update:_** _Resolved in_ _<u>[pull request #197](https://github.com/eth-infinitism/account-abstraction/pull/197)</u>_ _and merged at commit_ _<u>`[545a15c](https://github.com/eth-infinitism/account-abstraction/commit/545a15cfdc793be375c2747ea90900612c00e077)`</u>_ _._

### **L-07 Missing docstrings [core and samples]**


Throughout the <u>[codebase](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/)</u> there are several parts that do not have docstrings. For instance:


   - <u>[Line 24](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSAccount.sol#L23-L24)</u> in <u>`[BLSAccount.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSAccount.sol)`</u>

   - <u>[Line 39](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSAccount.sol#L38-L39)</u> in <u>`[BLSAccount.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSAccount.sol)`</u>

   - <u>[Line 44](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSAccount.sol#L43-L44)</u> in <u>`[BLSAccount.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSAccount.sol)`</u>

   - <u>[Line 48](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSAccount.sol#L47-L48)</u> in <u>`[BLSAccount.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSAccount.sol)`</u>

   - <u>[Line 20](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSSignatureAggregator.sol#L19-L20)</u> in <u>`[BLSSignatureAggregator.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSSignatureAggregator.sol)`</u>

   - <u>[Line 48](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSSignatureAggregator.sol#L46-L48)</u> in <u>`[BLSSignatureAggregator.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSSignatureAggregator.sol)`</u>

   - <u>[Line 106](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSSignatureAggregator.sol#L105-L106)</u> in <u>`[BLSSignatureAggregator.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSSignatureAggregator.sol)`</u>

   - <u>[Line 10](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/IBLSAccount.sol#L10)</u> in <u>`[IBLSAccount.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/IBLSAccount.sol)`</u>

   - <u>[Line 24](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/BasePaymaster.sol#L23-L24)</u> in <u>`[BasePaymaster.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/BasePaymaster.sol)`</u>

   - <u>[Line 29](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/BasePaymaster.sol#L27-L29)</u> in <u>`[BasePaymaster.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/BasePaymaster.sol)`</u>

   - <u>[Line 31](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/BasePaymaster.sol#L30-L31)</u> in <u>`[BasePaymaster.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/BasePaymaster.sol)`</u>

   - <u>[Line 167](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L166-L167)</u> in <u>`[EntryPoint.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol)`</u>

   - <u>[Line 18](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/StakeManager.sol#L17-L18)</u> in <u>`[StakeManager.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/StakeManager.sol)`</u>

   - <u>[Line 11](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/gnosis/EIP4337Fallback.sol#L10-L11)</u> in <u>`[EIP4337Fallback.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/gnosis/EIP4337Fallback.sol)`</u>

   - <u>[Line 23](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/gnosis/GnosisAccountFactory.sol#L22-L23)</u> in <u>`[GnosisAccountFactory.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/gnosis/GnosisAccountFactory.sol)`</u>

   - <u>[Line 67](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IStakeManager.sol#L66-L67)</u> in <u>`[IStakeManager.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IStakeManager.sol)`</u>

   - <u>[Line 34](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/UserOperation.sol#L33-L34)</u> in <u>`[UserOperation.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/UserOperation.sol)`</u>

   - <u>[Line 73](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/DepositPaymaster.sol#L72-L73)</u> in <u>`[DepositPaymaster.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/DepositPaymaster.sol)`</u>

   - <u>[Line 27](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/SimpleAccount.sol#L26-L27)</u> in <u>`[SimpleAccount.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/SimpleAccount.sol)`</u>

   - <u>[Line 31](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/SimpleAccount.sol#L30-L31)</u> in <u>`[SimpleAccount.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/SimpleAccount.sol)`</u>


EIP-4337 – Ethereum Account Abstraction Incremental Audit − Low Severity

                                                - 14


   - <u>[Line 23](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TestAggregatedAccount.sol#L22-L23)</u> in <u>`[TestAggregatedAccount.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TestAggregatedAccount.sol)`</u>

   - <u>[Line 34](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TestAggregatedAccount.sol#L33-L34)</u> in <u>`[TestAggregatedAccount.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TestAggregatedAccount.sol)`</u>

   - <u>[Line 16](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TestSignatureAggregator.sol#L15-L16)</u> in <u>`[TestSignatureAggregator.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TestSignatureAggregator.sol)`</u>

   - <u>[Line 28](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TestSignatureAggregator.sol#L26-L28)</u> in <u>`[TestSignatureAggregator.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TestSignatureAggregator.sol)`</u>

   - <u>[Line 43](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TestSignatureAggregator.sol#L42-L43)</u> in <u>`[TestSignatureAggregator.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TestSignatureAggregator.sol)`</u>

   - <u>[Line 40](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TokenPaymaster.sol#L37-L40)</u> in <u>`[TokenPaymaster.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TokenPaymaster.sol)`</u>

   - <u>[Line 6](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/utils/Exec.sol#L3-L6)</u> in <u>`[Exec.sol](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/utils/Exec.sol)`</u>


Consider thoroughly documenting all functions and their parameters, especially public APIs.

When writing docstrings, consider following the <u>[Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/develop/natspec-format.html)</u>

(NatSpec).


**_Update:_** _Partially resolved in_ _<u>[pull request #212](https://github.com/eth-infinitism/account-abstraction/pull/212)</u>_ _and merged at commit_ _<u>`[eeb93b2](https://github.com/eth-infinitism/account-abstraction/commit/eeb93b25804a748519245df34c4162fddf9a8fd1)`</u>_ _. The_

_recommended changes to_ _`GnosisAccountFactory.sol`_ _were not implemented._

### **L-08 Missing error messages in require** **statements [core and samples]**


Within the <u>[codebase](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/)</u> there are some `require` statements that lack error messages:


   - The `require` statement on <u>[line 105](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/BasePaymaster.sol#L105)</u> of <u>`[BasePaymaster.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/BasePaymaster.sol)`</u>

   - The `require` statement on <u>[line 49](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/DepositPaymaster.sol#L49)</u> of <u>`[DepositPaymaster.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/DepositPaymaster.sol)`</u>

   - The `require` statement on <u>[line 137](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/SimpleAccount.sol#L137)</u> of <u>`[SimpleAccount.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/SimpleAccount.sol)`</u>


Consider including specific, informative error messages in `require` statements to improve

overall code clarity and facilitate troubleshooting whenever a requirement is not satisfied.


**_Update:_** _Resolved in_ _<u>[pull request #198](https://github.com/eth-infinitism/account-abstraction/pull/198)</u>_ _and merged at commit_ _<u>`[182b7d3](https://github.com/eth-infinitism/account-abstraction/commit/182b7d3387a12d2d96974dbb883ed4c15f573122)`</u>_ _. Error messages were_

_added to the deficient_ _`require`_ _statements in_ _`BasePaymaster.sol`_ _and_

_`DepositPaymaster.sol`_ _, and the_ _`require`_ _statement in_ _`SimpleAccount.sol`_ _was_

_eliminated as part of a code change._

### **L-09 Missing recommended function [samples]**


The EIP <u>[states](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/eip/EIPS/eip-4337.md?plain=1#L149-L150)</u> that an aggregated account should support the `getAggregationInfo`

function, and that this function should return the account's public key, and possibly other data.

However, the <u>`[BLSAccount](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSAccount.sol)`</u> contract does not contain a `getAggregationInfo` function.

Consider renaming <u>the</u> <u>`[getBlsPublicKey](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSAccount.sol#L48)`</u> <u>function</u> to `getAggregationInfo` .


EIP-4337 – Ethereum Account Abstraction Incremental Audit − Low Severity

                                                - 15


**_Update:_** _Resolved in_ _<u>[pull request #199](https://github.com/eth-infinitism/account-abstraction/pull/199)</u>_ _and merged at commit_ _<u>`[12d2ac0](https://github.com/eth-infinitism/account-abstraction/commit/12d2ac0326ce87d7b58a9c57e0e73d1717023ef9)`</u>_ _. The EIP now uses_

_the_ _`getBlsPublicKey`_ _function as an example._

### **L-10 Uninitialized implementation contract** **[samples]**


The `SimpleAccountFactory` <u>[creates a new implementation contract](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/SimpleAccountFactory.sol#L19)</u> but does not <u>[initialize](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/SimpleAccount.sol#L80)</u>

<u>[it. This means that anyone can initialize the implementation contract to become its owner.](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/SimpleAccount.sol#L80)</u>


The consequences depend on the version of OpenZeppelin contracts in use. The project

<u>[requires release 4.2](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/package.json#L57)</u> and later, but <u>[release 4.8](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/yarn.lock#L804)</u> is locked. The `onlyProxy` modifier was

introduced in release 4.3.2 to protect the upgrade mechanism. Without this modifier, the owner

is <u>[authorized](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/SimpleAccount.sol#L151)</u> to call the upgrade functions on the implementation contract directly, <u>[which lets](https://forum.openzeppelin.com/t/uupsupgradeable-vulnerability-post-mortem/15680)</u>

<u>them</u> <u>`[selfdestruct](https://forum.openzeppelin.com/t/uupsupgradeable-vulnerability-post-mortem/15680)`</u> <u>it.</u>


With the locked version, the implementation owner can <u>[execute arbitrary calls](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/SimpleAccount.sol#L56-L73)</u> from the

implementation contract, but should not be able to interfere with the operation of the proxies.


Nevertheless, to reduce the attack surface, consider restricting the versions of OpenZeppelin

contracts that are supported and <u>[disabling the initializer](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.0/contracts/proxy/utils/Initializable.sol#L144)</u> in the constructor of the

`SimpleAccount` contract, to prevent anyone from claiming ownership.


**_Update:_** _Resolved in_ _<u>[pull request #201](https://github.com/eth-infinitism/account-abstraction/pull/201)</u>_ _and merged at commit_ _<u>`[4004ebf](https://github.com/eth-infinitism/account-abstraction/commit/4004ebf1fa615c94801605f042a20d7cf1146fee)`</u>_ _._

### **L-11 Unrestrained revert reason [core]**


The `EntryPoint` contract can emit a <u>`[FailedOp](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IEntryPoint.sol#L63)`</u> <u>error</u> where the `reason` parameter

provides additional context for troubleshooting purposes. However, there are two locations

<u>[(line 375](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L375)</u> and <u>[line 417) where an untrusted contract can provide the reason, potentially](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L417)</u>

including misleading error codes. For example, the sender `validateUserOp` function might

revert with `"AA90 invalid beneficiary"`, which might cause confusion during

simulation.


Consider prefixing the externally provided revert reasons with a uniquely identifying error code.


**_Update:_** _Resolved in_ _<u>[pull request #200](https://github.com/eth-infinitism/account-abstraction/pull/200)</u>_ _and merged at commit_ _<u>`[3d8f450](https://github.com/eth-infinitism/account-abstraction/commit/3d8f4508b23d712859d08aa848d6fc729c2761ad)`</u>_ _._


EIP-4337 – Ethereum Account Abstraction Incremental Audit − Low Severity

                                                - 16


### **L-12 Unsafe ABI encoding**

It is not an uncommon practice to use `abi.encodeWithSignature` or

`abi.encodeWithSelector` to generate calldata for a low-level call. However, the first

option is not safe from typographical errors, and the second option is not type-safe. The result

is that both of these methods are error-prone and should be considered unsafe.


Within <u>`[EIP4337Manager.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/gnosis/EIP4337Manager.sol)`</u>, there are some occurrences of unsafe ABI encodings being

used:


  - On <u>[line 119](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/gnosis/EIP4337Manager.sol#L119)</u>

  - On <u>[line 144](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/gnosis/EIP4337Manager.sol#L144)</u>


Consider replacing all occurrences of unsafe ABI encodings with `abi.encodeCall`, which

checks whether the supplied values actually match the types expected by the called function,

and also avoids typographical errors.


Note that a <u>[bug](https://blog.soliditylang.org/2022/03/16/encodecall-bug/)</u> related to the use of string literals as inputs to `abi.encodeCall` was fixed in

version 0.8.13, so developers should exercise caution when using this function with earlier

versions of Solidity.


**_Update:_** _Resolved in_ _<u>[pull request #220](https://github.com/eth-infinitism/account-abstraction/pull/220)</u>_ _and merged at commit_ _<u>`[c0a69bf](https://github.com/eth-infinitism/account-abstraction/commit/c0a69bf34077e461f12e4d7e2146b52e7b59553b)`</u>_ _. The first example is_

_an invalid recommendation because it is encoding an error._

## **Notes & Additional** **Information**

### **N-01 Declare uint/int as uint256/int256** **[core and samples]**


Throughout the <u>[codebase, there are multiple instances of](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/)</u> `int` and `uint` being used, as

opposed to `int256` and `uint256` . In favor of explicitness, consider replacing all instances

of `int` with `int256`, and `uint` with `uint256` .


**_Update:_** _Partially resolved in_ _<u>[pull request #215](https://github.com/eth-infinitism/account-abstraction/pull/215)</u>_ _and merged at commit_ _<u>`[998fa7d](https://github.com/eth-infinitism/account-abstraction/commit/998fa7dfe3a251e07bc9caded926d841fb3a3e57)`</u>_ _. Most_

_instances have been addressed but there are some_ _`uint`_ _types remaining._


EIP-4337 – Ethereum Account Abstraction Incremental Audit − Notes &

Additional Information − 17


### **N-02 File relocation recommendations [samples]**

To provide additional clarity regarding whether a given contract file contains core, sample, or

test code, consider the following recommendations to move project files:


   - Within the <u>`[samples](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples)`</u> directory, `TestAggregatedAccount.sol`,

`TestAggregatedAccountFactory.sol`, and `TestSignatureAggregator.sol`

contain test contracts similar to those found in the <u>`[contracts/test](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/test)`</u> directory.

Consider relocating these files to the `contracts/test` directory.


   - The <u>`[bls](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls)`</u> and <u>`[gnosis](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/gnosis)`</u> directories contain sample account implementations, but do not

reside in the <u>`[samples](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples)`</u> directory. Consider moving these items to the `samples`

directory.


**_Update:_** _Resolved in_ _<u>[pull request #217](https://github.com/eth-infinitism/account-abstraction/pull/217)</u>_ _and merged at commit_ _<u>`[f82cbbb](https://github.com/eth-infinitism/account-abstraction/commit/f82cbbb364fdc599ab37bd0a541e8c03a94941f0)`</u>_ _._

### **N-03 IAccount inheritance anti-pattern**


The `IAggregatorAccount` interface extends the base `IAccount` interface by adding the

ability <u>[to expose a signature aggregator](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IAggregatedAccount.sol#L18)</u> associated with the account. To add support for

handling aggregated user operations, the `validateUserOp` function in `IAccount` now

includes an `aggregator` address parameter. Accounts not associated with an aggregator

<u>[must provide a null address for this parameter. This represents an anti-pattern where a base](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IAccount.sol#L19)</u>

class is aware of features only relevant to a derived class.


To address this case and future enhancements of the protocol, consider replacing the

`aggregator` parameter in `validateUserOp` with a more generic `extensions` parameter

that can be used to specify the aggregator as well as any future account-specific extensions.


**_Update:_** _Resolved in_ _<u>[pull request #216](https://github.com/eth-infinitism/account-abstraction/pull/216)</u>_ _and merged at commit_ _<u>`[1f505c5](https://github.com/eth-infinitism/account-abstraction/commit/1f505c5889b04a115b1bf09386c0b84cecdad5c4)`</u>_ _._

### **N-04 Implicit size limit [core]**


The `packSigTimeRange` function of the `BaseAccount` contract <u>[implicitly assumes](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/BaseAccount.sol#L30)</u> the

timestamps fit within 8 bytes. Consider enforcing this assumption by using `uint64`

parameters.


**_Update:_** _Resolved in_ _<u>[pull request #203](https://github.com/eth-infinitism/account-abstraction/pull/203)</u>_ _and merged at commit_ _<u>`[fa46d5b](https://github.com/eth-infinitism/account-abstraction/commit/fa46d5be28b4d436a28688ac3e85d1a0f4970fb0)`</u>_ _._


EIP-4337 – Ethereum Account Abstraction Incremental Audit − Notes &

Additional Information − 18


### **N-05 Incomplete event history [samples]**

The `BLSAccount` contract <u>[emits an event](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSAccount.sol#L40)</u> when the public key is changed, but not when it is

<u>[initialized. To complete the event history, consider emitting the event on initialization as well.](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSAccount.sol#L26)</u>


**_Update:_** _Resolved in_ _<u>[pull request #204](https://github.com/eth-infinitism/account-abstraction/pull/204)</u>_ _and merged at commit_ _<u>`[2600d7e](https://github.com/eth-infinitism/account-abstraction/commit/2600d7ef05145f6974112e155bf2fd68adc74bc8)`</u>_ _._

### **N-06 Lack of indexed parameter [core]**


The `aggregator` parameter in the <u>`[SignatureAggregatorChanged](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IEntryPoint.sol#L51)`</u> event is not indexed.

Consider <u>[indexing the event parameter](https://solidity.readthedocs.io/en/latest/contracts.html#events)</u> to avoid hindering the task of off-chain services

searching and filtering for specific events.


**_Update:_** _Resolved in_ _<u>[pull request #202](https://github.com/eth-infinitism/account-abstraction/pull/202)</u>_ _and merged at commit_ _<u>`[1633c06](https://github.com/eth-infinitism/account-abstraction/commit/1633c063c3dd72b073fe9c116f7f6410f2438951)`</u>_ _._

### **N-07 Naming suggestions [core and samples]**


To favor explicitness and readability, there are several locations in the contracts that may

benefit from better naming. Our suggestions are:


   - In `BaseAccount.sol` :


    - The <u>`[packSigTimeRange](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/BaseAccount.sol#L29)`</u> function is internal but is not prefixed with "_".

Consider renaming to `_packSigTimeRange` .




- In `BasePaymaster.sol` :




- The <u>`[packSigTimeRange](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/BasePaymaster.sol#L115)`</u> function is internal but is not prefixed with "_".



Consider renaming to `_packSigTimeRange` .


- In `BLSSignatureAggregator.sol` :




- Consider renaming <u>[all instances](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSSignatureAggregator.sol#L92-L112)</u> of `hashPublicKey` to `publicKeyHash` for



consistency.


- In `EIP4337Manager.sol` :




- Consider renaming the local variable <u>`[_msgSender](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/gnosis/EIP4337Manager.sol#L38)`</u> to `msgSender` for

consistency.


EIP-4337 – Ethereum Account Abstraction Incremental Audit − Notes &

Additional Information − 19


- In `IAggregator.sol` :


  - Consider renaming the return value of the <u>`[aggregateSignatures](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IAggregator.sol#L35)`</u> function from

`aggregatesSignature` to `aggregatedSignature` .




- In `IEntryPoint.sol` :




- The <u>`[ExecutionResult](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IEntryPoint.sol#L188)`</u> error uses `validBefore` instead of `validUntil` . For



consistency, consider changing the parameter name to `validUntil` .

  - The `ReturnInfo` struct's <u>[documentation](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IEntryPoint.sol#L143)</u> for the `validAfter` parameter

indicates it is inclusive. Consider renaming it to `validFrom` throughout the entire

codebase.

  - In the `AggregatorStakeInfo` struct, consider renaming <u>`[actualAggregator](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IEntryPoint.sol#L161)`</u>

to `aggregator` (also in the comment <u>[here).](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IEntryPoint.sol#L83)</u>


- In `SenderCreator.sol` :




- In the `createSender` function, consider renaming the <u>`[initAddress](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/SenderCreator.sol#L16)`</u> variable to



`factory` to be consistent with the <u>[EntryPoint contract.](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L282)</u>


- In `SimpleAccount.sol` :




- In the `addDeposit` function, consider renaming the <u>`[req](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/SimpleAccount.sol#L136)`</u> variable to `success` .




- In `StakeManager.sol` :




- <u>`[internalIncrementDeposit](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/StakeManager.sol#L38)`</u> is an internal function that uses "internal" as its



prefix instead of "_". Consider changing to `_incrementDeposit` .

    - The <u>`[getStakeInfo](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/StakeManager.sol#L23)`</u> function is internal but not prefixed with "_". Consider

renaming the function to `_getStakeInfo` .

    - Consider renaming the `addr` parameter of `getStakeInfo` to `account` .

    - Consider removing the leading underscore from <u>[all instances](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/StakeManager.sol#L57-L73)</u> of

`_unstakeDelaySec` in `StakeManager` now that there is no longer a storage

variable named `unstakeDelaySec` .


**_Update:_** _Resolved in_ _<u>[pull request #221](https://github.com/eth-infinitism/account-abstraction/pull/221)</u>_ _and merged at commit_ _<u>`[7bd9909](https://github.com/eth-infinitism/account-abstraction/commit/7bd9909f47f0de0fb10a4bfe382d6352069b6ca0)`</u>_ _._


EIP-4337 – Ethereum Account Abstraction Incremental Audit − Notes &

Additional Information − 20


### **N-08 Inconsistent ordering [core and samples]**

The Solidity Style Guide specifies a <u>[recommended order](https://docs.soliditylang.org/en/v0.8.12/style-guide.html#order-of-layout)</u> for the layout of elements within a

contract file in order to facilitate finding declarations grouped together in predictable locations.

Within the <u>[codebase, this recommendation is not followed in several places:](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts)</u>


   - In <u>`[BLSAccount.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSAccount.sol)`</u> : The <u>`[PublicKeyChanged](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSAccount.sol#L37)`</u> event is defined between two

functions.

   - In <u>`[BLSSignatureAggregator.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSSignatureAggregator.sol)`</u> : Constant value <u>`[N](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSSignatureAggregator.sol#L134)`</u> is defined between two

functions.

   - In <u>`[IEntryPoint.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IEntryPoint.sol)`</u> : Starting at <u>[line 70, error and struct definitions are intermingled](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IEntryPoint.sol#L70)</u>

with function definitions.

   - In <u>`[IPaymaster.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IPaymaster.sol)`</u> : The <u>`[PostOpMode](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IPaymaster.sol#L45)`</u> enum is defined after all functions.

   - In <u>`[SimpleAccount.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/SimpleAccount.sol#L35)`</u> : The <u>`[_entryPoint](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/SimpleAccount.sol#L35)`</u> variable,

<u>`[SimpleAccountInitialized](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/SimpleAccount.sol#L37)`</u> event, and <u>`[onlyOwner](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/SimpleAccount.sol#L46)`</u> modifier are defined after

several function definitions.


To improve the project's overall legibility, consider standardizing ordering throughout the

codebase, as recommended by the Solidity Style Guide.


**_Update:_** _Partially resolved in_ _<u>[pull request #211](https://github.com/eth-infinitism/account-abstraction/pull/211)</u>_ _and merged at commit_ _<u>`[ca1b649](https://github.com/eth-infinitism/account-abstraction/commit/ca1b6495f2bc9d8c22c499a42543ff2242e76ecd)`</u>_ _. In_

_`IEntryPoint.sol`_ _, the error definitions were relocated but several struct definitions remain_

_defined in between functions._

### **N-09 Stake size inconsistency [core]**


The `StakeManager` allows <u>[deposits up to the maximum](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/StakeManager.sol#L41)</u> <u>`[uint112](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/StakeManager.sol#L41)`</u> value, but the stake must

be <u>[strictly less than the maximum](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/StakeManager.sol#L65)</u> <u>`[unit112](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/StakeManager.sol#L65)`</u> value. Consider using the same maximum in both

cases for consistency.


**_Update:_** _Resolved in_ _<u>[pull request #209](https://github.com/eth-infinitism/account-abstraction/pull/209)</u>_ _at commit_ _<u>`[419b7b0](https://github.com/eth-infinitism/account-abstraction/commit/419b7b04f9c8ff0beb2c336fc5854b0ac1d3fc69)`</u>_ _._

### **N-10 TODO comments [core and samples]**


The following instances of `TODO` comments were found in the <u>[codebase:](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/)</u>


   - <u>[Line 305](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L305)</u> in <u>[EntryPoint.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol)</u>

   - <u>[Line 52](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/gnosis/EIP4337Manager.sol#L52)</u> in <u>[EIP4337Manager.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/gnosis/EIP4337Manager.sol)</u>

   - <u>[Line 57](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TokenPaymaster.sol#L57)</u> in <u>[TokenPaymaster.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TokenPaymaster.sol)</u>


EIP-4337 – Ethereum Account Abstraction Incremental Audit − Notes &

Additional Information − 21


`TODO` comments are more likely to be overlooked and remain unresolved if they are not being

tracked formally as issues. Over time, important information regarding the original motivation,

plan, and supporting details may be lost. Consider removing all instances of `TODO` comments

and tracking them in the issues backlog instead. Alternatively, consider linking each inline

`TODO` to the corresponding issues backlog entry.


**_Update:_** _Resolved in_ _<u>[pull request #218](https://github.com/eth-infinitism/account-abstraction/pull/218)</u>_ _and merged at commit_ _<u>`[80d5c89](https://github.com/eth-infinitism/account-abstraction/commit/80d5c89b6177164d761149eefa76f9b13f8110b4)`</u>_ _. The first example is_

_obsolete. The other two are not TODOs and were changed to "Note"._

### **N-11 Typographical errors [core and samples]**


Consider addressing the following typographical errors:


   - In `BaseAccount.sol` :


    - <u>[Line 70: "chain-id" should be "chain id".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/BaseAccount.sol#L70)</u>

    - <u>[Line 76: "The an account" should be "If an account".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/BaseAccount.sol#L76)</u>




- In `BLSAccount.sol` :




- <u>[Line 9: "public-key" should be "public key" in this context.](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSAccount.sol#L9)</u>




- <u>[Line 12: "a BLS public" should be "a BLS public key".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSAccount.sol#L12)</u>




- <u>[Line 19: "Mutable values slots" should be "Mutable value slots".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSAccount.sol#L19)</u>




- In `BLSAccountFactory.sol` :




- <u>[Line 11: "Based n" should be "Based on".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSAccountFactory.sol#L11)</u>




- <u>[Line 27: "public-key" should be "public key" in this context.](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSAccountFactory.sol#L27)</u>




- In `BLSHelper.sol` :




- <u>[Line 32: "(x2 y2, z2)" should be "(x2, y2, z2)".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSHelper.sol#L32)</u>




- <u>[Line 137: "Doubles a points" should be "Doubles a point".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSHelper.sol#L137)</u>




- In `BLSSignatureAggregator.sol` :




- <u>[Line 34: "to short" should be "too short".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSSignatureAggregator.sol#L34)</u>




- <u>[Line 89: "public-key" should be "public key" in this context; remove 1 space](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSSignatureAggregator.sol#L89)</u>

between "value" and "using".

- <u>[Line 155: remove 1 space between "stake" and "or".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSSignatureAggregator.sol#L155)</u>


EIP-4337 – Ethereum Account Abstraction Incremental Audit − Notes &

Additional Information − 22


- In `DepositPaymaster.sol` :


  - <u>[Line 14: "deposit" should be "deposits".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/DepositPaymaster.sol#L14)</u>




- In `EIP4337Manager.sol` :




- <u>[Line 106: "prevent mistaken replaceEIP4337Manager to disable" should be](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/gnosis/EIP4337Manager.sol#L106)</u>



"prevents mistaken replaceEIP4337Manager from disabling".


- In `EntryPoint.sol` :




- <u>[Line 50: "into into" should be "index into".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L50)</u>




- <u>[Line 69: "deliberately caused" should be "not deliberately caused".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L69)</u>




- <u>[Line 80: "UserOperation" should be "UserOperations" or "user operations".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L80)</u>




- <u>[Line 180: "except that" should be "except for".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L180)</u>




- <u>[Line 180: Missing closing parenthesis.](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L180)</u>




- <u>[Line 522: "if it is was" should be "if it was".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L522)</u>




- <u>[Line 552: "A50" should be "AA50".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L552)</u>




- <u>[Line 560: "A51" should be "AA51".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/core/EntryPoint.sol#L552)</u>




- In `IAccount.sol` :




- <u>[Line 29: "The an account" should be "If an account".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IAccount.sol#L29)</u>




- In `IAggregatedAccount.sol` :




- <u>[Line 9: "account, that support" should be "account that supports".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IAggregatedAccount.sol#L9)</u>




- <u>[Line 11: "valiate" should be "validate".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IAggregatedAccount.sol#L11)</u>




- In `IAggregator.sol` :




- <u>[Line 20: "return" should be "returns".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IAggregator.sol#L20)</u>




- <u>[Line 20: Sentence ends with a colon.](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IAggregator.sol#L20)</u>




- <u>[Line 23: Missing closing parenthesis.](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IAggregator.sol#L23)</u>




- In `IEntryPoint.sol` :




- <u>[Line 118: "factor" should be "factory".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IEntryPoint.sol#L118)</u>




- <u>[Line 129: "factor" should be "factory".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IEntryPoint.sol#L129)</u>




- In `IPaymaster.sol` :




- <u>[Line 13: "agree" should be "agrees".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IPaymaster.sol#L13)</u>




- <u>[Line 24: "validation,)" should be "validation)".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IPaymaster.sol#L24)</u>


EIP-4337 – Ethereum Account Abstraction Incremental Audit − Notes &

Additional Information − 23


  - <u>[Line 48: "Now its" should be "Now it's".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IPaymaster.sol#L48)</u>


- In `IStakeManager.sol` :




- <u>[Line 22: Docstring copy-paste error from line 29.](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IStakeManager.sol#L22)</u>




- <u>[Line 51: "allow" should be "allows".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IStakeManager.sol#L51)</u>




- In `SimpleAccount.sol` :




- <u>[Line 65: "transaction" should be "transactions".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/SimpleAccount.sol#L65)</u>




- In `TestAggregatedAccount.sol` :




- <u>[Line 18: "Mutable values slots" should be "Mutable value slots".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TestAggregatedAccount.sol#L18)</u>




- In `TestAggregatedAccountFactory.sol` :




- <u>[Line 10: "Based n" should be "Based on".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TestAggregatedAccountFactory.sol#L10)</u>




- In `TokenPaymaster.sol` :




- <u>[Line 11: "define itself" should be "defines itself".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TokenPaymaster.sol#L11)</u>




- <u>[Line 14: Missing closing double quote on "getTokenValueOfEth".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TokenPaymaster.sol#L14)</u>




- <u>[Line 66: The sentence is incomplete.](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TokenPaymaster.sol#L66)</u>




- In `UserOperation.sol` :




- <u>[Line 16: "field hold" should be "field holds".](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/UserOperation.sol#L16)</u>




- <u>[Line 16: "paymaster-specific-data" should be "paymaster-specific data"; also](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/UserOperation.sol#L16)</u>



remove quotes around this phrase.


**_Update:_** _Resolved in_ _<u>[pull request #219](https://github.com/eth-infinitism/account-abstraction/pull/219)</u>_ _and merged at commit_ _<u>`[b4ce311](https://github.com/eth-infinitism/account-abstraction/commit/b4ce311e12c823242c611c228d4e2264f0979100)`</u>_ _._

### **N-12 Unused imports [samples]**


Throughout the <u>[codebase](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/)</u> imports on the following lines are unused and could be removed:


   - Import <u>`[console](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSSignatureAggregator.sol#L10)`</u> of <u>`[BLSSignatureAggregator.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSSignatureAggregator.sol)`</u>

   - Import <u>`[EIP4337Manager](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/gnosis/EIP4337Fallback.sol#L9)`</u> of <u>`[EIP4337Fallback.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/gnosis/EIP4337Fallback.sol)`</u>

   - Import <u>`[Exec](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/gnosis/GnosisAccountFactory.sol#L7)`</u> of <u>`[GnosisAccountFactory.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/gnosis/GnosisAccountFactory.sol)`</u>

   - Import <u>`[IAggregator](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IAggregatedAccount.sol#L6)`</u> of <u>`[IAggregatedAccount.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IAggregatedAccount.sol)`</u>

   - Import <u>`[UserOperation](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IAggregatedAccount.sol#L4)`</u> of <u>`[IAggregatedAccount.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces/IAggregatedAccount.sol)`</u>

   - Import <u>`[Ownable](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/DepositPaymaster.sol#L9)`</u> of <u>`[DepositPaymaster.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/DepositPaymaster.sol)`</u>


EIP-4337 – Ethereum Account Abstraction Incremental Audit − Notes &

Additional Information − 24


   - Import <u>`[BaseAccount](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TestAggregatedAccount.sol#L5)`</u> of <u>`[TestAggregatedAccount.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TestAggregatedAccount.sol)`</u>

   - Import <u>`[SimpleAccount](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TestSignatureAggregator.sol#L8)`</u> of <u>`[TestSignatureAggregator.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TestSignatureAggregator.sol)`</u>

   - Import <u>`[console](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TestSignatureAggregator.sol#L7)`</u> in <u>`[TestSignatureAggregator.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TestSignatureAggregator.sol)`</u>

   - Import <u>`[SimpleAccount](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TokenPaymaster.sol#L7)`</u> of <u>`[TokenPaymaster.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TokenPaymaster.sol)`</u>


Consider removing unused imports to avoid confusion that could reduce the overall clarity and

readability of the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #206](https://github.com/eth-infinitism/account-abstraction/pull/206)</u>_ _and merged at commit_ _<u>`[e019bbd](https://github.com/eth-infinitism/account-abstraction/commit/e019bbd673dc6ec09332ad5510b4061f5ee187bf)`</u>_ _._

### **N-13 Unused interface [core]**


The `ICreate2Deployer.sol` import was removed from `EntryPoint.sol` in <u>[pull request](https://github.com/eth-infinitism/account-abstraction/pull/144/files)</u>

<u>[#144, but the file still exists in the](https://github.com/eth-infinitism/account-abstraction/pull/144/files)</u> <u>`[interfaces](https://github.com/eth-infinitism/account-abstraction/tree/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/interfaces)`</u> directory. None of the contracts import this

file.


Consider deleting the unused interface file.


**_Update:_** _Resolved in_ _<u>[pull request #205](https://github.com/eth-infinitism/account-abstraction/pull/205)</u>_ _and merged at commit_ _<u>`[679ac11](https://github.com/eth-infinitism/account-abstraction/commit/679ac1187766ab0053fc7636b6e3acbf8f691d1c)`</u>_ _._

### **N-14 References to previously used "wallet"** **terminology [samples]**


Throughout the codebase, an effort has been made to change the term "wallet" to "account",

e.g. `SimpleWallet` was renamed `SimpleAccount` . However, some "wallet" references

remain in various comments:


   - <u>[Line 13](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSAccountFactory.sol#L13)</u> of <u>[BLSAccountFactory.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSAccountFactory.sol)</u>

   - <u>[Line 9](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/gnosis/GnosisAccountFactory.sol#L9)</u> of <u>[GnosisAccountFactory.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/gnosis/GnosisAccountFactory.sol)</u>

   - <u>[Line 12](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TestAggregatedAccountFactory.sol#L12)</u> of <u>[TestAggregatedAccountFactory.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/TestAggregatedAccountFactory.sol)</u>

   - <u>[Line 14](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/VerifyingPaymaster.sol#L14)</u> of <u>[VerifyingPaymaster.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/VerifyingPaymaster.sol)</u>

   - <u>[Line 16](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/VerifyingPaymaster.sol#L16)</u> of <u>[VerifyingPaymaster.sol](https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/samples/VerifyingPaymaster.sol)</u>


To avoid confusion, consider replacing these instances of "wallet" with "account".


**_Update:_** _Resolved in_ _<u>[pull request #210](https://github.com/eth-infinitism/account-abstraction/pull/210)</u>_ _and merged at commit_ _<u>`[d6a2db7](https://github.com/eth-infinitism/account-abstraction/commit/d6a2db7b267608782c33446bd7e76c06ece49a5e)`</u>_ _._


EIP-4337 – Ethereum Account Abstraction Incremental Audit − Notes &

Additional Information − 25


## **Conclusions**

One high severity issue was found. Several changes were proposed to improve the code's

overall quality and reduce the attack surface.

## **Appendix**

### **Monitoring Recommendations**


While audits help in identifying potential security risks, the Ethereum Foundation is encouraged

to also incorporate automated monitoring of on-chain contract activity, and activity within the

new mempool, into their operations. Ongoing monitoring of deployed contracts helps in

identifying potential threats and issues affecting the production environment. In this case, it

may also provide useful information about how the system is being used or misused. Consider

monitoring the following items:


   - User operations that have unusually high or low gas parameters may indicate a general

misunderstanding of the system, or could identify unexpected economic opportunities in

some kinds of transactions.

   - Operations or paymasters that consistently fail validation in the mempool could indicate

a misunderstanding of the system, or an attempted denial-of-service attack.

   - Transactions that use non-standard accounts, factories, and aggregators could reveal

interesting use cases, or unnecessary restrictions in the current design.

   - Any bundle that reverts on-chain may indicate a problem with the clients, or an edge

case in the specified restrictions.

   - Operations where any of the participants have unusually low stake may provide useful

insight into the risks that bundlers are willing to accept.


EIP-4337 – Ethereum Account Abstraction Incremental Audit − Conclusions

                                                - 26


