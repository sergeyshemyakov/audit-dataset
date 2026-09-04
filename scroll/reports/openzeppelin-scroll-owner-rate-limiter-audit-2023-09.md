### | security

# **ScrollOwner** **and Rate** **Limiter Audit**

#### **September 26, 2023**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  5


Trust Assumptions _________________________________________________________________  5


Privileged Roles ___________________________________________________________________  6


High Severity ______________________________________________________________________  9

H-01 Abuse of Rate Limiter Mechanism to Perform DOS Attack 9


Low Severity ____________________________________________________________________ 10

L-01 Missing Docstrings 10

L-02 Utilizing Deprecated Function From Library 10


Notes & Additional Information ____________________________________________________ 11

N-01 Variable Cast is Unnecessary 11

N-02 Incorrect Function Visibility 11

N-03 Inconsistent Usage of msg.sender 11

N-04 Implicit Type Casting 12

N-05 Lack of Logs on Sensitive Actions 12

N-06 Unpinned Compiler Version 13

N-07 Naming Issue 13


Recommendations _______________________________________________________________ 14

Monitoring Recommendations 14


Conclusion  ______________________________________________________________________ 15


ScrollOwner and Rate Limiter Audit − Table of Contents − 2


## **Summary**

Type zkEVM-based ZK-rollup, Bridge &
Rollup


Timeline From 2023-08-16
To 2023-08-23


Languages Solidity



Critical Severity
Issues


High Severity
Issues


Medium Severity
Issues



0 (0 resolved)


1 (1 resolved)


0 (0 resolved)



Total Issues 10 (8 resolved, 1 partially resolved)



Low Severity Issues 2 (1 resolved)



Notes & Additional
Information



7 (6 resolved, 1 partially resolved)



ScrollOwner and Rate Limiter Audit − Summary − 3


## **Scope**

We audited the <u>[Scroll Owner pull request](https://github.com/scroll-tech/scroll/pull/586)</u> and the <u>[Rate Limiter pull request](https://github.com/scroll-tech/scroll/pull/712)</u> from the <u>[scroll-tech/](https://github.com/scroll-tech/)</u>

<u>[scroll](https://github.com/scroll-tech/)</u> repository at commit <u>[ae2e010.](https://github.com/scroll-tech/scroll/tree/ae2e010324506d52f30d1aa98b98cc3e44f8c501)</u>

```
contracts
└── src
├── misc
│  └── ScrollOwner.sol
└── rate-limiter
├── ETHRateLimiter.sol
├── IETHRateLimiter.sol
├── ITokenRateLimiter.sol
└── TokenRateLimiter.sol

```

For the Rate Limiter pull request, we also performed a diff audit of the

`scroll-tech/scroll` repository at the <u>[ae2e010](https://github.com/scroll-tech/scroll/tree/ae2e010324506d52f30d1aa98b98cc3e44f8c501)</u> commit against the <u>[767a2cb](https://github.com/scroll-tech/scroll/tree/767a2cbfdf6a566ea6991505a13e06a7ef09bfdd)</u> commit.

```
contracts
└── src
├── L1
│  ├── gateways
│  │  ├── L1ERC20Gateway.sol
│  │  └── L1ETHGateway.sol
│  └── L1ScrollMessenger.sol
├── L2
│  ├── gateways
│  │  ├── L2CustomERC20Gateway.sol
│  │  ├── L2StandardERC20Gateway.sol
│  │  ├── L2WETHGateway.sol
│  │  └── L2ETHGateway.sol
│  └── L2ScrollMessenger.sol
├── gas-swap
│  └── GasSwap.sol
└── libraries
├── gateway
│  └── ScrollGatewayBase.sol
└── ScrollMessengerBase.sol

```

ScrollOwner and Rate Limiter Audit − Scope − 4


## **System Overview**

Scroll is an EVM-equivalent ZK-rollup designed to be a scaling solution for Ethereum. It

achieves this by interpreting EVM bytecode directly at the bytecode level, following a similar

path to projects like Polygon's zkEVM and Consensys' Linea.


Scroll's architecture and code structure draw inspiration from other Layer 2 solutions like

Arbitrum and Optimism, particularly in the design of their gateways, predeploys, and

messaging contracts. Notably, a lot of code structures from Arbitrum's gateways and the

`AddressAliasHelper.sol` contract are reused with minor modifications.


This audit reviewed two new additions to the protocol. `ScrollOwner` implements a role
based model for access control. This will allow administrators' addresses to execute sensitive

configurations on the core contracts of the protocol. Additionally, rate-limiting contracts have

been implemented to enforce deposit and withdrawal limits for assets over specific time

intervals for enhanced security.


This report presents our findings and recommendations for the additions to the Scroll ZK-rollup

protocol. In the following sections, we will discuss these aspects in detail. We urge the Scroll

team to consider these findings in their ongoing efforts to provide a secure and efficient Layer

2 solution for Ethereum.

## **Trust Assumptions**


During the course of the audit, several assumptions about the Scroll protocol were considered

to be inherently trusted. These assumptions and the context surrounding them include:


  - EVM node and relayer implementation: It is assumed that the EVM node

implementation will work as described in the <u>[Scroll documentation, particularly the](https://guide.scroll.io/developers/ethereum-and-alpha-testnet-differences)</u>

opcodes and their expected behavior. The relayer implementation is trusted to act in the

best interest of the users.

   - Censoring: The protocol is centralized as is, as the sequencer and prover have the ability

to censor L2 messages and transactions. L1 to L2 messages are appended into a

message queue that is checked against when finalizing, but the sequencer can currently


ScrollOwner and Rate Limiter Audit − System Overview − 5


choose to skip any message from this queue during finalization. This allows the chain to

finalize even if a message is not provable. Therefore, it is worth noting that L1 to L2

messages from the `L1ScrollMessenger` or `EnforcedTxGateway` can be ignored

and skipped. There are plans to remove this message-skipping mechanism after the

mainnet launch, once the prover is more capable.

  - No escape hatch: The Scroll protocol does not feature an escape hatch mechanism.

This, combined with the potential for transaction censorship by the relayer, introduces a

trust assumption in the protocol. In the event of the network going offline, users would

not be able to recover their funds.

   - Whitelist ownership: The whitelist contract has an owner who can update the whitelist

status of different addresses. This implies trust in the owner of the whitelist to manage

this list correctly and in the best interest of the system and its users.

## **Privileged Roles**


Certain privileged roles within the Scroll protocol were identified during the audit. These roles

possess special permissions that could potentially impact the system's operation:


   - Access Control: The access control manager is a contract in which there is an address

with default admin privileges that can perform the critical administrative action of giving

and revoking roles for different addresses. This mechanism is used in the following

contracts:




- `ScrollOwner` : The default admin role can grant roles for addresses to execute

functions through the contract. Every role will be associated with a designated set

of functions tied to specific addresses permissible to execute within that role.

Moreover, existing roles will come with execution delays ranging from 0 days for

instant execution to 1 day, 7 days, and 14 days. This provides a dynamic control

mechanism over the timing of function execution based on their respective impact

levels.




- `TokenRateLimiter` : The default admin role can update the total token amount



limit. The admin can also grant a token spender role for the Scroll gateways and

messengers to ensure a rate limit when depositing or withdrawing funds.

- Proxy Admins: Most of the contracts are upgradeable. Hence, most of the logic can be

changed by the proxy admin. The following contracts are upgradeable:

  - The gateway contracts




- `L1MessageQueue`



ScrollOwner and Rate Limiter Audit − Privileged Roles − 6


- `L1ScrollMessenger`

- `L2GasPriceOracle`

- `ScrollChain`

- `L2ScrollMessenger`




- Implementation Owners: Most contracts are also ownable. The following actions

describe what the owner can do in each contract.




- `L1ScrollMessenger` : Pause the relay of L2 to L1 messages and L1 to L2

message requests.




- `EnforcedTxGateway` : Pause L1 to L2 transaction requests and change the fee

vault.




- `L1{CustomERC20|ERC721|ERC1155}Gateway` : Change the token mapping

containing which L1 token is bridged to which L2 token.




- `L1GatewayRouter` : Set the respective gateway for ETH, custom ERC-20s and

default ERC-20s.




- `L1MessageQueue` : Update the maximum allowed gas limit for L2 transactions,

the gas price oracle to calculate the L2 fee, and the `EnforcedTxGateway`

address that may append unaliased messages into the queue.




- `L2GasPriceOracle` : Set the whitelist contract address that defines who may

change gas-related settings.




- `ScrollChain` : Revert previously committed batches that have not yet been

finalized, set addresses as sequencers, change the verifier, and update the

maximum amount of L2 transactions that are allowed in a chunk (bundle of

blocks).




- `FeeVault` : Change the messenger address that is used to withdraw the funds

from L2 to L1, the recipient address of the collected fees, and update the minimum

amount of funds to withdraw.




- `ScrollMessengerBase` : Change the fee vault address which collects fees for

message relaying.




- `ScrollStandardERC20Factory` : Use the factory to deploy another instance of

a standard ERC-20 token on L2.




- `L2ScrollMessenger` : Pause the relay of L1 to L2 messages and L2 to L1

message requests.




- `L2{CustomERC20|ERC721|ERC1155}Gateway` : Change the token mapping

containing which L2 token is bridged to which L1 token.




- `L2GatewayRouter` : Set the respective gateway for ETH, custom ERC-20s and

default ERC-20s.




- `L2MessageQueue` : Update the address of the messenger.


ScrollOwner and Rate Limiter Audit − Privileged Roles − 7


- `L2TxFeeVault` : Change the messenger address that is used to withdraw the

funds from L1 to L2, the recipient address of the collected fees, and update the

minimum amount of funds to withdraw.




- `L1BlockContainer` : Initialize the starting block hash, block height, block

timestamp, block base fee, and state root.




- `L1GasPriceOracle` : Update the gas price and whitelist.

- `Fallback` : Withdraw ERC-20 tokens and ETH as well as execute arbitrary

messages.




- `Whitelist` : Accounts can be whitelisted to change the L2 base fee on L1 as well

as the intrinsic gas parameters.




- `GasSwap` : Withdraw stuck ERC-20 tokens and ETH, update the fees, and set the

approved targets to call.




- `MultipleVersionRollupVerifier` : Set the new verifier and their starting

batch index.




- `ETHRateLimiter` : Update the total ETH amount limit.




- Sequencer: The sequencer role can interact with the `ScrollChain` contract to commit



to new batches that bundle multiple L2 blocks in chunks that can then be finalized along

with a proof.

   - Prover: The prover role can interact with the `ScrollChain` contract to prove batches

that have already been committed by the sequencer, thus finalizing them.


Each of these roles presents a unique set of permissions within the Scroll protocol. The

potential implications of these permissions warrant further consideration and mitigation to

ensure the system’s security and robustness.


ScrollOwner and Rate Limiter Audit − Privileged Roles − 8


## **High Severity**

### **H-01 Abuse of Rate Limiter Mechanism to** **Perform DOS Attack**

The Rate Limiting mechanism is an excellent safety mechanism to add to a bridge. However, in

its current implementation, it can be abused by a malicious attacker to perform a denial-of
service on the system.


The rate limiter contracts <u>`[ETHRateLimiter](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/ETHRateLimiter.sol)`</u> and <u>`[TokenRateLimiter](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/TokenRateLimiter.sol)`</u> keep track of the

amount of `ETH` or tokens that have been deposited in a certain time period. Every time a user

makes an asset deposit or withdrawal, the total amount of their transaction is added to the

total amount of the current time period. If the total amount of the current time period exceeds

the maximum amount allowed, the transaction is reverted.


A malicious user can make a large deposit, withdraw, and repeat the process multiple times

until the rate limiter reaches its total amount limit. This will prevent other users from making

deposits or withdrawals from the protocol. The only cost for the malicious user would be the

gas fees incurred. Once the amount limit is reached, it can only be updated by admins with the

`updateTotalLimit` functions. Based on the responses to our inquiries with the Scroll team,

it was communicated that the rate limiter `updateTotalLimit` functions will have a full-day

delay before being executable. This would allow a malicious user to perform a DOS attack for

24 hours before the rate limiter can be updated and even then, the malicious user could keep

repeating the DOS attack.


Consider adding an emergency 0-day execution of the rate limiter's `updateTotalLimit`

function. This would allow the Scroll team to update the rate limiter in case there is a DOS

attempt. We also recommend using short time periods for the rate limiter and adding the

capability to turn on withdrawal fees that can be enabled during an attack to discourage

malicious deposit-withdrawal cycling.


**_Update:_** _Resolved, the Scroll team removed the delay for updating the limit total amount in_ _<u>[pull](https://github.com/scroll-tech/scroll/pull/838)</u>_

_<u>[request #838](https://github.com/scroll-tech/scroll/pull/838)</u>_ _at commit_ _<u>[fd5dcda.](https://github.com/scroll-tech/scroll/commit/0fe10691947a48b1cf94fb83ff1e7cae87b57f48)</u>_


ScrollOwner and Rate Limiter Audit − High Severity − 9


## **Low Severity**

### **L-01 Missing Docstrings**

Throughout the <u>[codebase, there are several parts that do not have docstrings. For instance:](https://github.com/scroll-tech/scroll/tree/ae2e010324506d52f30d1aa98b98cc3e44f8c501/)</u>


   - <u>[Line 10](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/misc/ScrollOwner.sol#L7-L10)</u> in <u>`[ScrollOwner.sol](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/misc/ScrollOwner.sol)`</u>

   - <u>[Line 13](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/ETHRateLimiter.sol#L9-L13)</u> in <u>`[ETHRateLimiter.sol](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/ETHRateLimiter.sol)`</u>

   - <u>[Line 5](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/IETHRateLimiter.sol#L4-L5)</u> in <u>`[IETHRateLimiter.sol](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/IETHRateLimiter.sol)`</u>

   - <u>[Line 5](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/ITokenRateLimiter.sol#L4-L5)</u> in <u>`[ITokenRateLimiter.sol](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/ITokenRateLimiter.sol)`</u>

   - <u>[Line 13](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/TokenRateLimiter.sol#L9-L13)</u> in <u>`[TokenRateLimiter.sol](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/TokenRateLimiter.sol)`</u>

   - <u>[Line 96](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/TokenRateLimiter.sol#L96)</u> in <u>`[TokenRateLimiter.sol](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/TokenRateLimiter.sol)`</u>

   - <u>[Line 13](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/ITokenRateLimiter.sol#L13)</u> in <u>`[ITokenRateLimiter.sol](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/ITokenRateLimiter.sol)`</u>


Consider thoroughly documenting all functions (and their parameters) that are part of any

contract's public API. Functions implementing sensitive functionality, even if not public, should

be clearly documented as well. When writing docstrings, consider following the <u>[Ethereum](https://solidity.readthedocs.io/en/develop/natspec-format.html)</u>

<u>[Natural Specification Format](https://solidity.readthedocs.io/en/develop/natspec-format.html)</u> (NatSpec).


**_Update:_** _Acknowledged, will resolve. The Scroll team stated:_


_It will be fixed later on when we have more time._

### **L-02 Utilizing Deprecated Function From Library**


The <u>`[TokenRateLimiter](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/TokenRateLimiter.sol)`</u> <u>contract</u> is setting up its default admin role in the constructor using

the <u>`[_setupRole](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/TokenRateLimiter.sol#L57)`</u> <u>function. However, this function</u> <u>[has been deprecated.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/access/AccessControl.sol#L204)</u>


To avoid potential future incompatibilities with OpenZeppelin's contracts library, consider using

the <u>`[_grantRole](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/access/AccessControl.sol#L228)`</u> method instead.


**_Update:_** _Resolved in_ _<u>[pull request #902](https://github.com/scroll-tech/scroll/pull/902)</u>_ _at commit_ _<u>[daae8c4.](https://github.com/scroll-tech/scroll/pull/902/commits/daae8c438d4e246c304da9251e286668d6189bc6)</u>_


ScrollOwner and Rate Limiter Audit − Low Severity − 10


## **Notes & Additional** **Information**

### **N-01 Variable Cast is Unnecessary**

Within the <u>`[ScrollOwner](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/misc/ScrollOwner.sol)`</u> <u>contract, the</u> `_target` variable in the <u>`[_execute](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/misc/ScrollOwner.sol#L119)`</u> <u>function</u> was

unnecessarily cast.


To improve the overall clarity, intent, and readability of the codebase, consider removing this

unnecessary cast.


**_Update:_** _Resolved in_ _<u>[pull request #903](https://github.com/scroll-tech/scroll/pull/903)</u>_ _at commit_ _<u>[9a69617.](https://github.com/scroll-tech/scroll/pull/903/commits/9a69617b8a22039bfed50b5eccd6ac726ad0c574)</u>_

### **N-02 Incorrect Function Visibility**


In the <u>`[ScrollOwner](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/misc/ScrollOwner.sol)`</u> <u>contract, the</u> <u>`[execute](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/misc/ScrollOwner.sol#L67)`</u> <u>function</u> is marked as `public`, while the

<u>`[_execute](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/misc/ScrollOwner.sol#L113)`</u> <u>function</u> has `internal` visibility.


The `execute` function should be marked as `external` because it is not called internally by

any of the functions in the `ScrollOwner` contract.


The `_execute` function should be marked as `private` because it is implemented in the top
level `ScrollOwner` contract and is not intended to be called by the derived contracts.


To improve the overall clarity, intent, and readability of the codebase, consider fixing the

visibility for these functions.


**_Update:_** _Resolved in_ _<u>[pull request #904](https://github.com/scroll-tech/scroll/pull/904)</u>_ _at commit_ _<u>[72d484c.](https://github.com/scroll-tech/scroll/pull/904/commits/7d2484c112ea7957e1ec33004008e0e92b34f2af)</u>_

### **N-03 Inconsistent Usage of msg.sender**


The <u>`[ScrollOwner](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/misc/ScrollOwner.sol)`</u> <u>contract</u> inherits from OpenZeppelin's <u>`[AccessControl](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/access/AccessControl.sol)`</u> <u>contract</u> through

its inheritance chain. This contract uses the `_msgSender` function.


Likewise, the <u>`[ETHRateLimiter](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/ETHRateLimiter.sol)`</u> <u>contract</u> inherits from OpenZeppelin's <u>`[Ownable](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/access/Ownable.sol)`</u> <u>contract.</u>

This contract also uses the `_msgSender` function.


ScrollOwner and Rate Limiter Audit − Notes & Additional Information − 11


The <u>`[_msgSender](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/utils/Context.sol#L17)`</u> <u>function</u> from OpenZeppelin's <u>`[Context](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/utils/Context.sol)`</u> <u>contract</u> is used to allow the

usage of metadata execution.


However, the `ScrollOwner` and `ETHRateLimiter` contracts directly use `msg.sender` <u>[[1],](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/misc/ScrollOwner.sol#L39)</u>

<u>[[2]](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/ETHRateLimiter.sol#L74)</u> instead of the `_msgSender` function. Even though there is no security risk per se, having

some methods use `msg.sender` while others use the `_msgSender` function can be

confusing.


Consider standardizing the usage of the `_msgSender` function throughout the codebase to

increase clarity and consistency.


**_Update:_** _Resolved in_ _<u>[pull request #906](https://github.com/scroll-tech/scroll/pull/906)</u>_ _at commit_ _<u>[d0780e9.](https://github.com/scroll-tech/scroll/pull/906/commits/d0780e956a6a35d99463bd9003647f3bc0e19fc4)</u>_

### **N-04 Implicit Type Casting**


In the <u>`[ETHRateLimiter](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/ETHRateLimiter.sol)`</u> <u>contract, the variables</u> `_currentPeriod.lastUpdateTs` and

`_currentPeriodStart` are being <u>[compared. However,](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/ETHRateLimiter.sol#L85)</u>

<u>`[_currentPeriod.lastUpdateTs](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/ETHRateLimiter.sol#L20)`</u> 's type is `uint48` and <u>`[_currentPeriodStart](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/ETHRateLimiter.sol#L79)`</u> 's type

is `uint256` .


Consider explicitly type-casting variables of different types when they are compared or used in

the same calculation. This ensures consistency in computations and reduces the risk of errors

resulting from data loss.


**_Update:_** _Resolved in_ _<u>[pull request #907](https://github.com/scroll-tech/scroll/pull/907)</u>_ _at commit_ _<u>[d0780e9.](https://github.com/scroll-tech/scroll/pull/906/commits/d0780e956a6a35d99463bd9003647f3bc0e19fc4)</u>_

### **N-05 Lack of Logs on Sensitive Actions**


In the <u>`[ScrollOwner](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/misc/ScrollOwner.sol)`</u> <u>contract, the</u> <u>`[updateAccess](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/misc/ScrollOwner.sol#L88)`</u> <u>function</u> can modify a role's access to

calling specific function selectors on a target contract. Although this function will not interfere

with users' actions, it is recommended to emit events to allow users to track changes to their

permissions and monitor for any anomalies.


In the <u>`[constructor](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/ETHRateLimiter.sol#L49)`</u> of the `ETHRateLimiter` contract, the storage variable

<u>`[currentPeriod.limit](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/ETHRateLimiter.sol#L65)`</u> is set without emitting the respective <u>`[UpdateTotalLimit](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/ETHRateLimiter.sol#L114C14-L114C30)`</u> <u>event.</u>


Consider emitting events when changing state variables. Moreover, consider replacing the

manual variable declarations in constructors with the corresponding function to update those

variables.


ScrollOwner and Rate Limiter Audit − Notes & Additional Information − 12


**_Update:_** _Resolved in_ _<u>[pull request #908](https://github.com/scroll-tech/scroll/pull/908)</u>_ _at commit_ _<u>[0bb41be.](https://github.com/scroll-tech/scroll/pull/908/commits/0bb41be065704c7a39f09ecf604458d0fca96cac)</u>_

### **N-06 Unpinned Compiler Version**


<u>`[ScrollOwner.sol](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/misc/ScrollOwner.sol#L3)`</u>, <u>`[IETHRateLimiter.sol](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/IETHRateLimiter.sol#L3)`</u> and <u>`[ITokenRateLimiter.sol](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/ITokenRateLimiter.sol#L3)`</u> use an

unpinned Solidity version.


Consider pinning the version of the Solidity compiler to match the pinned version in the other

contracts. This should help prevent the introduction of unexpected bugs due to incompatible

future releases.


**_Update:_** _Partially resolved in_ _<u>[pull request #909](https://github.com/scroll-tech/scroll/pull/909)</u>_ _at commit_ _<u>[0c5fbb7.](https://github.com/scroll-tech/scroll/pull/909/commits/0c5fbb7babc30a41aa5ed2fc3c700e0221cd66a4)</u>_ _`IETHRateLimiter.sol`_

_and_ _`ITokenRateLimiter.sol`_ _still use an unpinned Solidity version._

### **N-07 Naming Issue**


In the <u>`[ETHRateLimiter](https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/rate-limiter/ETHRateLimiter.sol)`</u> <u>contract, consider replacing instances of the term "token" with</u>

"ETH" to favor explicitness and readability.


**_Update:_** _Resolved in_ _<u>[pull request #910](https://github.com/scroll-tech/scroll/pull/910)</u>_ _at commit_ _<u>[86556dd.](https://github.com/scroll-tech/scroll/pull/910/commits/86556dd25f826ec1609089f979f7c75d192f6641)</u>_


ScrollOwner and Rate Limiter Audit − Notes & Additional Information − 13


## **Recommendations**

### **Monitoring Recommendations**

While audits help in identifying code-level issues in the current implementation and potentially

the code deployed in production, the Scroll team is encouraged to consider incorporating

monitoring activities in the production environment. Ongoing monitoring of deployed contracts

helps identify potential threats and issues affecting production environments. With the goal of

providing a complete security assessment, the monitoring recommendations section raises

several actions addressing trust assumptions and out-of-scope components that can benefit

from on-chain monitoring.


**Scroll Owner**


Monitoring any role changes from the Scroll Owner will help detect any unauthorized changes.

This can help detect malicious activity or a compromised account.


**Rate Limiter**


Monitoring the current rate limits against the total rate limit should be done to ensure that

protocol withdrawals are not being paused because of rate limit breaches. It can also help

detect DOS attacks against the rate limiter or suspicious activity. It is also recommended to

monitor any updates to the rate limiter limit.


ScrollOwner and Rate Limiter Audit − Recommendations − 14


## **Conclusion**

Over the course of this 8-day audit, we reviewed the Scroll Owner and the Rate Limiter

codebases. We identified a single high-severity issue, as well as a few low-severity issues and

additional notes. Overall, we commend the quality and thoughtful design of both codebases.

The auditing process was seamless, and we appreciate the Scroll team's prompt responses to

our inquiries throughout the process.


The implementation of the Scroll Owner for governance and the integration of the Rate Limiter

for the bridge serve as significant enhancements to the protocol.


ScrollOwner and Rate Limiter Audit − Conclusion − 15


