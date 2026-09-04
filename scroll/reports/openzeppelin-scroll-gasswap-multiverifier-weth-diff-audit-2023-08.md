### | security

# **Scroll** **GasSwap,** **Multiple** **Verifier,** **Wrapped Ether** **and Diff Audit**

#### **August 31, 2023**

This security assessment was prepared by
OpenZeppelin.


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  4


Scope ____________________________________________________________________________  5


System Overview __________________________________________________________________  7

Architecture 7

Rollup and Bridging 8

State of Refunds 8


Trust Assumptions _________________________________________________________________  9


Privileged Roles _________________________________________________________________ 10


High Severity ____________________________________________________________________ 12

H-01 Lack of Refunds 12

H-02 Potentially Stuck USDC From Pausing 13


Medium Severity _________________________________________________________________ 14

M-01 Lack of Expiration for Retrying Transactions 14

M-02 Potentially Stuck ETH in L1ScrollMessenger 14

M-03 Potentially Stuck ETH from Incorrect Data Parameter 15

M-04 Use of Non-Production-Ready Trusted Forwarder 15

M-05 replayMessage and dropMessage Can Be Front-Run 16


Low Severity ____________________________________________________________________ 17

L-01 Error-Prone Call Encoding 17

L-02 Anyone Can Steal ERC-20 Tokens From GasSwap 17

L-03 Inconsistency of Allowing a Trusted Forwarder 18

L-04 Inconsistency of Reentrancy Guard 18

L-05 Potentially Stuck ETH in GasSwap 18

L-06 Possible Misleading revert Message When Swapping Non-ERC20Permit Tokens 19

L-07 Potentially Misleading Verifier Event 19

L-08 Redundancy of Replaying Messages in L2ScrollMessenger 20

L-09 Misleading and Incorrect Comments 20

L-10 maxReplayTimes is Not Initialized in L1ScrollMessenger 21


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Table of

Contents − 2


Notes & Additional Information ____________________________________________________ 21

N-01 Tokens With Permit Functionality Can Be Front-Run 21

N-02 Extraneous Use of safeApprove 22

N-03 Variables Missing immutable Keyword 22

N-04 Inconsistency Between maxReplayTimes and ReplayState.times 23

N-05 Lack of Indexed Event Parameters 23

N-06 Inconsistent Coding Style 24

N-07 Incorrect Function Visibility 24

N-08 Inconsistent Order of Event Emissions 24

N-09 Missing and Inconsistent Event Emissions 25

N-10 Code Duplication 26

N-11 Follow the Checks-Effects-Interactions Pattern 27

N-12 Unused Function Parameter 27

N-13 Unnecessary Usage of Upgradeable Interfaces 27

N-14 Duplicate Imports 28

N-15 Unused Imports 28


Recommendations _______________________________________________________________ 30

ERC-20 Factory Design 30

ERC-165 Support 30

Testing Coverage 30

Custom Gateway Contracts 31

Monitoring Recommendations 32


Conclusion  ______________________________________________________________________ 34


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Table of

Contents − 3


## **Summary**

Type zkEVM-based zkRollup, Bridge &
Rollup


Timeline From 2023-07-24
To 2023-08-11


Languages Solidity



Critical Severity
Issues


High Severity
Issues


Medium Severity
Issues



0 (0 resolved)


2 (0 resolved)


5 (0 resolved, 2 partially resolved)



Total Issues 32 (13 resolved, 4 partially resolved)



Low Severity Issues 10 (8 resolved)



Notes & Additional
Information


Client Reported
Issues



15 (5 resolved, 2 partially resolved)


0 (0 resolved)



Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Summary −

4


## **Scope**

We audited the `scroll-tech/scroll` repository at the <u>[2eb458c](https://github.com/scroll-tech/scroll/tree/2eb458cf4224d82fc56254e91e297a9ed261cefb)</u> commit.

```
contracts
└── src
├── L1
│  ├── gateways
│  │  ├── usdc
│  │  │  └── L1USDCGateway.sol
│  ├── rollup
│  │  └── MultipleVersionRollupVerifier.sol
├── L2
│  ├── gateways
│  │  ├── usdc
│  │  │  └── L2USDCGateway.sol
│  ├── predeploys
│  │  └── WrappedEther.sol
├── gas-swap
│  └── GasSwap.sol
├── interfaces
│  └── IFiatToken.sol
├── libraries
│  ├── callbacks
│  │  └── IMessageDropCallback.sol
│  ├── token
│  │  ├── IScrollERC1155Extension.sol
│  │  ├── IScrollERC20Extension.sol
│  │  └── IScrollERC721Extension.sol
│  ├── verifier
│  │  └── IZkEvmVerifier.sol
│  └── ScrollMessengerBase.sol
├── misc
│  └── Fallback.sol
└── External.sol

```

We also performed a diff audit of the `scroll-tech/scroll` repository at the <u>[2eb458c](https://github.com/scroll-tech/scroll/tree/2eb458cf4224d82fc56254e91e297a9ed261cefb)</u>

commit against <u>[3bc8a3f](https://github.com/scroll-tech/scroll/tree/3bc8a3f5c6ac816ddffadca41024331dcf4d3064)</u> commit.

```
contracts
└── src
├── L1
│  ├── gateways
│  │  ├── EnforcedTxGateway.sol
│  │  ├── IL1ERC1155Gateway.sol
│  │  ├── IL1ERC20Gateway.sol
│  │  ├── IL1ERC721Gateway.sol
│  │  ├── IL1ETHGateway.sol

```

Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Scope − 5


```
│  │  ├── IL1GatewayRouter.sol
│  │  ├── L1CustomERC20Gateway.sol
│  │  ├── L1ERC1155Gateway.sol
│  │  ├── L1ERC20Gateway.sol
│  │  ├── L1ERC721Gateway.sol
│  │  ├── L1ETHGateway.sol
│  │  ├── L1GatewayRouter.sol
│  │  ├── L1StandardERC20Gateway.sol
│  │  └── L1WETHGateway.sol
│  ├── rollup
│  │  ├── IL1MessageQueue.sol
│  │  ├── L1MessageQueue.sol
│  │  └── ScrollChain.sol
│  ├── IL1ScrollMessenger.sol
│  └── L1ScrollMessenger.sol
├── L2
│  ├── gateways
│  │  ├── L2ERC1155Gateway.sol
│  │  ├── L2ERC721Gateway.sol
│  │  └── L2ETHGateway.sol
│  ├── predeploys
│  │  └── L1GasPriceOracle.sol
│  ├── IL2ScrollMessenger.sol
│  └── L2ScrollMessenger.sol
├── gas-swap
│  └── GasSwap.sol
└── libraries
├── constants
│  └── ScrollConstants.sol
├── gateway
│  └── ScrollGatewayBase.sol
├── token
│  ├── IScrollERC1155.sol
│  ├── IScrollERC20.sol
│  └── IScrollERC721.sol
├── verifier
│  └── IRollupVerifier.sol
└── ScrollMessengerBase.sol

```

Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Scope − 6


## **System Overview**

Scroll is an EVM-equivalent zk-Rollup designed to be a scaling solution for Ethereum. It

achieves this by interpreting EVM bytecode directly at the bytecode level, following a similar

path to projects like Polygon zkEVM and ConsenSys' Linea.


Scroll's architecture and code structure draw inspiration from other Layer 2 solutions like

Arbitrum and Optimism, particularly in the design of their gateways, predeploys, and

messaging contracts. Notably, a lot of code structures from Arbitrum's gateways and the

`AddressAliasHelper.sol` contract are reused with minor modifications.


There were several major changes since the last audit. The first major change was to add a

refund for skipped messages only and to remove the message retry logic from the L2 side.

There was also an addition of the `MultipleVersionRollupVerifier` contract which

allows for different verifiers to be used for different batches. A `GasSwap` contract was also

added to help users swap tokens for L2 ETH. Aside from these major changes, this audit

focused on diff audits across almost all contracts across this protocol. In this audit, we aimed

to verify the correctness and security of the contracts, focusing on block finalization, message

passing, and the process of depositing and withdrawing into/from the rollup.


This report presents our findings and recommendations for the Scroll zk-Rollup protocol. In the

following sections, we will discuss these aspects in detail. We urge the Scroll team to consider

these findings in their ongoing efforts to provide a secure and efficient Layer 2 solution for

Ethereum.

### **Architecture**


The system's architecture is split into three main components:


   - Scroll Node: This constructs Layer 2 (L2) blocks from user transactions, commits these

transactions to the Ethereum base layer and handles message passing between L1 and

L2.

   - Roller Network: This component is responsible for generating the zkEVM validity proofs,

which are used to prove that transactions are executed correctly.

   - Rollup and Bridge contracts: These contracts provide data availability for Scroll

transactions, verify zkEVM validity proofs, and allow users to move assets between


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − System

Overview − 7


Ethereum and Scroll. Users can pass arbitrary messages between L1 and L2 and can

bridge assets in either direction thanks to the Gateway contracts.

### **Rollup and Bridging**


The Scroll system connects to Ethereum primarily through its Rollup and Messenger contracts.

The Rollup contract is responsible for receiving L2 state roots and blocks from the Sequencer,

and finalizing blocks on Scroll once their validity is established.


The Messenger contracts enable users to pass arbitrary messages between L1 and L2, as well

as bridge assets in both directions. The gateway contracts make use of the messages to

operate on the appropriate layer.


The standard ERC-20 token bridge automatically deploys tokens on L2, using a standardized

token implementation. There is also a custom token bridge which enables users to deploy their

L1 token on L2 for more sophisticated cases. In such scenarios, the Scroll team would need to

manually set the mapping for these tokens. This could potentially lead to double-minting on L2

(two tokens being created, one through each method). To prevent such a scenario, it is

recommended to use the GatewayRouter, which will route the token to the correct gateway.

These custom gateways are also required for ERC-721 and ERC-1155 tokens, which currently

do not have a standard gateway provided. However, the GatewayRouter does not currently

support ERC-721 or ERC-1155 custom gateways.

### **State of Refunds**


When communicating/bridging from L1 to L2, values are handled in two ways on the L1 side:


1. If a token is bridged, the token will be held by the gateway contract. If ETH is transferred,

the value is kept in the L1 messenger contract. In the case of WETH, the assets will be

first unwrapped to ETH and forwarded to be held by the L1 messenger contract.

2. The user has to specify a gas limit that will be used for the L2 transaction. The relayer

accounts for this gas limit through a fee that is deducted on the L1 call.


In the audited version of the protocol, there is a refund mechanism for (1) only if the L1

initialized message is not provable and hence not executed and skipped from the L1 message

queue. If an L1 message is not executed, reverted, or otherwise in a situation where it has

succeeded on L1 but failed on L2 and yet is proven back onto L1, there are no refunds

available. This means assets can potentially get stuck in the Gateway or L1 messenger

contracts. Regarding (2), any gas limit in excess of the required amount is paid as an extra fee


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − System

Overview − 8


into the fee vault. It is therefore crucial for users to make their best estimations through the

l2geth API. For technical details please see _<u>Lack of Refunds</u>_ <u>.</u>

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

choose to skip any message from this queue during finalization. This allows the chain to

finalize even if a message is not provable. Therefore, it is worth noting that L1 to L2

messages from the `L1ScrollMessenger` or `EnforcedTxGateway` can be ignored

and skipped. There are plans to remove this message-skipping mechanism post-mainnet

launch once the prover is more capable.

  - No escape hatch: The Scroll protocol does not feature an escape hatch mechanism.

This, combined with the potential for transaction censorship by the relayer, introduces a

trust assumption in the protocol. In the event of the network going offline, users would

not be able to recover their funds.

   - Whitelist ownership: The whitelist contract has an owner who can update the whitelist

status of different addresses. This implies trust in the owner of the whitelist to manage

this list correctly and in the best interest of the system and its users.


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Trust

Assumptions − 9


## **Privileged Roles**

Certain privileged roles within the Scroll protocol were identified during the audit. These roles

possess special permissions that could potentially impact the system's operation:


   - Proxy Admins: Most of the contracts are upgradeable. Hence, most of the logic can be

changed by the proxy admin. The following contracts are upgradeable:

    - The gateway contracts




- `L1MessageQueue`

- `L1ScrollMessenger`

- `L2GasPriceOracle`

- `ScrollChain`

- `L2ScrollMessenger`




- Implementation Owners: Most contracts are also ownable. The following actions

describe what the owner can do in each contract.




- `L1ScrollMessenger` : Pause relaying of L2 to L1 messages and L1 to L2

message requests.




- `EnforcedTxGateway` : Pause L1 to L2 transaction requests and change the fee

vault.




- `L1{CustomERC20|ERC721|ERC1155}Gateway` : Change the token mapping of

which L1 token is bridged to which L2 token.




- `L1GatewayRouter` : Set the respective gateway for ETH, custom ERC-20s and

default ERC-20s.




- `L1MessageQueue` : Update the maximum allowed gas limit for L2 transactions,

the gas price oracle to calculate the L2 fee and the `EnforcedTxGateway`

address that may append unaliased messages into the queue.




- `L2GasPriceOracle` : Set the whitelist contract address that defines who may

change gas-related settings.




- `ScrollChain` : Revert previously committed batches that haven't been finalized



yet, set addresses as sequencers, change the verifier, and update the maximum

amount of L2 transactions that are allowed in a chunk (bundle of blocks).

- `FeeVault` : Change the messenger address that is used to withdraw the funds

from L2 to L1, the recipient address of the collected fees, and update the minimum

amount of funds to withdraw.




- `ScrollMessengerBase` : Change the fee vault address which collects fees for

message relaying.


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Privileged

Roles − 10


- `ScrollStandardERC20Factory` : Use the factory to deploy another instance of

a standard ERC-20 token on L2.




- `L2ScrollMessenger` : Pause relaying of L1 to L2 messages and L2 to L1

message requests.




- `L2{CustomERC20|ERC721|ERC1155}Gateway` : Change the token mapping of

which L2 token is bridged to which L1 token.




- `L2GatewayRouter` : Set the respective gateway for ETH, custom ERC-20s and

default ERC-20s.




- `L2MessageQueue` : Update the address of the messenger.

- `L2TxFeeVault` : Change the messenger address that is used to withdraw the

funds from L1 to L2, the recipient address of the collected fees, and update the

minimum amount of funds to withdraw.




- `L1BlockContainer` : Initialize the starting block hash, block height, block

timestamp, block base fee, and state root.




- `L1GasPriceOracle` : Update the gas price and whitelist.

- `Fallback` : Withdraw ERC20 tokens and ETH as well as execute arbitrary

messages.




- `Whitelist` : Accounts can be whitelisted to change the L2 base fee on L1 as well

as the intrinsic gas parameters.




- `GasSwap` : Withdraw stuck ERC20 tokens and ETH, update the fees, and set the

approved targets to call




- `MultipleVersionRollupVerifier` : Set the new verifier and their starting



batch index

   - Sequencer: The sequencer role can interact with the `ScrollChain` contract to commit

to new batches that bundle multiple L2 blocks in chunks that can then be finalized along

with a proof.

   - Prover: The prover role can interact with the `ScrollChain` contract to prove batches

that have already been committed by the sequencer, thus finalizing them.


Each of these roles presents a unique set of permissions within the Scroll protocol. The

potential implications of these permissions warrant further consideration and mitigation to

ensure the system’s security and robustness.


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Privileged

Roles − 11


## **High Severity**

### **H-01 Lack of Refunds**

The protocol allows users to bridge their ERC-20, ERC-721, ERC-1155, USDC, WETH, and

ETH assets to the L2 rollup and back. If the target address is a contract, a callback is executed

during the bridging transaction. For example, when calling the `deposit{ERC20|ETH}`

`AndCall` function on the gateway contracts (for <u>[ETH, ERC-20s, USDC, and WETH), the](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ETHGateway.sol#L62)</u>

<u>`[onScrollGatewayCallback](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/libraries/gateway/ScrollGatewayBase.sol#L111)`</u> call is made to the target contract as the last step of the

bridging process. The same happens on the `withdraw{ERC20|ETH}AndCall` function.

Such callbacks are also standardly triggered on the `safeTransferFrom` function for

<u>[ERC-721](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC721Gateway.sol#L117)</u> and <u>[ERC-1155](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC1155Gateway.sol#L123)</u> tokens, which respectively call <u>`[onERC721Received](https://eips.ethereum.org/EIPS/eip-721#specification)`</u> and

<u>`[onERC1155Received](https://eips.ethereum.org/EIPS/eip-1155#specification)`</u> on the target contract.


However, because bridging transactions are not atomic, it is possible for the first half of the

transaction to be successful while the second half fails. This can happen when withdrawing/

depositing if the external call for the callback on the target contract reverts, for instance, when

a user is trying to bridge ETH through the `L{1|2}ETHGateway` but the target contract reverts

when calling `onScrollGatewayCallback` . Under such circumstances, users' funds are

stuck in the gateways or messenger, as there is no mechanism for them to recover their assets.

As mentioned above, the same could happen for the other assets.


It is worth noting that a reverting L2 transaction does not prevent the block from being finalized

on L1. Moreover, if the L2 transaction from an L1 deposit is not provable it has to be <u>[skipped](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/ScrollChain.sol#L167)</u>

<u>[from the L1 message queue for finalization. However, the prior asset deposit into the L1](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/ScrollChain.sol#L167)</u>

gateway or messenger would currently not be refunded to the user.


Further, when messaging from L1 to L2 (including bridging assets), users have to provide a <u>[gas](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol#L326)</u>

<u>[limit](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol#L326)</u> that will be used for the L2 transaction. The relayer accounts for this by deducting a <u>[fee](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/L2GasPriceOracle.sol#L101)</u>

<u>[based on the gas limit](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/L2GasPriceOracle.sol#L101)</u> from the `msg.value` when queuing the transaction on L1. Users

expecting this functionality to behave <u>[similarly to Ethereum](https://ethereum.org/en/developers/docs/gas/#what-is-gas-limit)</u> could set a high gas limit to ensure

the success of their transaction while being refunded for unused gas. However, any excessive

gas results in a fee overpayment that goes towards Scroll's fee vault, and is not refunded on

L2.


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − High

Severity − 12


To avoid funds being lost when bridging, consider adding a way for users to be refunded when

the bridging transaction cannot be completed (for example when the transaction reverts or is

skipped), and when the gas limit exceeds the gas effectively consumed.


**_Update_** _: Acknowledged, not resolved. The Scroll team stated:_


_This is not a priority at the time. It will be addressed later on._

### **H-02 Potentially Stuck USDC From Pausing**


Currently the <u>`[L2USDCGateway](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/gateways/usdc/L2USDCGateway.sol#L106-L116)`</u> has pausing functionality that its L1 counterpart does not

have. This is a feature that will be used by the protocol to do supply locking in the future.


An issue arises when the `L2USDCGateway` is paused while the `L1USDCGateway` remains

unpaused and usable. Users may still use the gateway to submit messages from L1 to L2, and

while the transaction could succeed on L1, it will fail during finalization on L2 via the <u>[paused](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/gateways/usdc/L2USDCGateway.sol#L93)</u>

<u>[deposit check](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/gateways/usdc/L2USDCGateway.sol#L93)</u> in the <u>`[finalizeDepositERC20](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/gateways/usdc/L2USDCGateway.sol#L82-L100)`</u> <u>function. Therefore, the users who deposited</u>

L1 USDC will have their tokens locked in the gateway and unable to replay their transaction.

Assuming that the transaction was not skipped, <u>[dropMessage](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol#L241)</u> cannot be called to obtain a

refund.


As USDC is one of the most widely used tokens, this issue could cause a high volume of users

to have locked funds. Consider adding the same pausing functionality to the

`L1USDCGateway` and updating the pausing state on both sides at the same time.

Furthermore, consider implementing a refund mechanism to unlock user funds when their

message from L1 to L2 fails.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_We will ensure that in L1_ _`pauseDeposit`_ _will be called first and in the meantime, in L2,_

_`pauseWithdraw`_ _will be called. After this, the pending L1=>L2 or L2=>L1 messages_

_are relayed. The pausing withdraw in L1 and pausing deposit in L2 will enable (actually_

_not needed but just in case). We will help relay pending L2=>L1 message if users forget_

_to withdraw the USDC. We will also help replay L1=>L2 messages if they fail in L2 due_

_to running out of gas. Skipped messages are not possible in the USDC gateway, since_

_we disabled deposit/withdraw with data._


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − High

Severity − 13


## **Medium Severity**

### **M-01 Lack of Expiration for Retrying** **Transactions**

The `L1ScrollMessenger` contract provides a <u>[mechanism to retry failed transactions](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol#L175)</u> from L1

to L2 at any time. Therefore, if a user creates an L1 to L2 transaction and it fails, it can be

retried indefinitely at a later time. A scenario could occur where a user erroneously sends an L1

to L2 transaction, which fails at the L2 level. The user may be inclined to send another

transaction, which would succeed at the L2 level. However, a malicious recipient could later

retry the user's first transaction against their will, which could succeed.


More generally, if a transaction is sent from L1 to L2 and fails, it can be retried indefinitely at a

later time. Consider adding an expiration time to replay failed transactions, limiting the

timeframe during which a failed transaction can be retried.


**_Update:_** _Partially resolved in_ _<u>[pull request #840](https://github.com/scroll-tech/scroll/pull/840)</u>_ _at commit_ _<u>[0d7d73f. The](https://github.com/scroll-tech/scroll/pull/840/commits/0d7d73ff1a6e463d58efe2073d1dbd590f5da0f1)</u>_ _`L1ScrollMessenger`_

_and_ _`L2ScrollMessenger`_ _contracts were updated to store the timestamp of when the_

_message was sent. However, checking for expiration was not implemented. The Scroll team_

_stated:_


_Only the timestamp is added for each message, the expiration check will be added_

_together with the refund feature._

### **M-02 Potentially Stuck ETH in** **`L1ScrollMessenger`**


The <u>function</u> <u>`[dropMessage](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol#L241)`</u> in `L1ScrollMessenger` allows the dropping of a message sent

from L1 to L2 that has been skipped in the proof. In order for a sender to obtain their refund

when their message is skipped, the `dropMessage` function is called and the <u>`[_value](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol#L289)`</u> of the

message is returned to the sender using the `onDropMessage` function call. However, if the

sender's address does not include the `onDropMessage` or a `payable fallback`, this

callback function will fail. While the gateways provided by the protocol do have the

`onDropMessage` implemented, it is possible that the user had sent a message by calling

`L1ScrollMessenger` directly using an EOA or a smart wallet. In the future, it is also possible

that a sender would use their own gateway that does not implement the `onDropMessage`

function.


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Medium

Severity − 14


Consider allowing the `_value` to be returned to the sender even if the sender does not

implement the `onDropMessage` function.


**_Update:_** _Acknowledged, will resolve. The Scroll team stated that they will resolve the issue:_


_This will be resolved if we implement the refund feature._

### **M-03 Potentially Stuck ETH from Incorrect Data** **Parameter**


The protocol allows users to bridge their assets to the L2 rollup and back through the

`L1ScrollMessenger` and the `L2ScrollMessenger` . When bridging from L1 to L2, the

<u>`[_executeMessage](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/L2ScrollMessenger.sol#L182)`</u> will be called. On <u>[line 198](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/L2ScrollMessenger.sol#L198)</u> of this function, the `_to` address is called and

the `_message` is passed to this function. If a user accidentally sets a value in the `_message`

field, but either the `_to` address is an EOA, the message is in an incorrect format, or the

address is a contract that does not support the data in this field, the user's assets will be stuck

on L1, as the L1 transaction has succeeded but the L2 transaction will fail.


The replaying of this message will not help, as the `_message` field cannot be changed for a

replay, and assuming that the transaction was not skipped, <u>`[dropMessage](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol#L241)`</u> cannot be called to

get a refund.


To avoid funds being lost when bridging, consider adding a way for users to be refunded when

the bridging transaction cannot be completed (for example when the transaction reverts or is

skipped), and when the gas limit exceeds the gas effectively consumed.


**_Update:_** _Acknowledged, will resolve. The Scroll team stated that they will resolve the issue:_


_This will be resolved if we implement the refund feature._

### **M-04 Use of Non-Production-Ready Trusted** **Forwarder**


The `GasSwap` contract inherits from `ERC2771Context` thereby allowing meta-transactions

to work with its functions. It relies on a trusted forwarder <u>[that is set in the constructor. The](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/gas-swap/GasSwap.sol#L79)</u>

trusted forwarder that it depends on is the `MinimalForwarder`, which is <u>[located in the](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/External.sol#L7)</u>

<u>`[External](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/External.sol#L7)`</u> <u>contract. However, the</u> `MinimalForwarder` is not ready for production use and

is <u>[mainly meant for testing.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/metatx/MinimalForwarder.sol#L9-L16)</u>


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Medium

Severity − 15


By using the `MinimalForwarder`, ETH could <u>[potentially be lost. In addition, the](https://github.com/OpenZeppelin/openzeppelin-contracts/issues/3664)</u>

`MinimalForwader` 's signed requests do not expire and lack batching, which is useful when

dealing with a large volume of requests to be forwarded.


Consider using OpenZeppelin's `ERC2771Forwarder` instead. While this contract is not

available until v5.0 is released, the source code can be obtained from the <u>`[master](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/metatx/ERC2771Forwarder.sol)`</u> <u>branch</u> and

inserted into the codebase.


**_Update:_** _Partially resolved in_ _<u>[pull request #843](https://github.com/scroll-tech/scroll/pull/843)</u>_ _at commit_ _<u>[709101a. The Scroll team replaced](https://github.com/scroll-tech/scroll/pull/843/commits/709101a5b253b08480ad22f16f07fd90b396e3ab)</u>_

_the_ _`MinimalForwarder`_ _with the_ _`ERC2771Forwarder`_ _contract but did not remove the_

_<u>`[MinimalForwarder](https://github.com/scroll-tech/scroll/blob/709101a5b253b08480ad22f16f07fd90b396e3ab/contracts/src/External.sol#L7)`</u>_ _import from the_ _<u>`[External.sol](https://github.com/scroll-tech/scroll/blob/709101a5b253b08480ad22f16f07fd90b396e3ab/contracts/src/External.sol)`</u>_ _<u>flei</u>_

### **M-05 replayMessage and dropMessage Can Be** **Front-Run**


The <u>`[L1ScrollMessenger](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L130)`</u> contract is used to send messages from L1 to L2. Failed

messages can be replayed using the <u>`[replayMessage](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L128C14-L128C32)`</u> <u>function. In addition, skipped</u>

messages can be dropped using the <u>`[dropMessage](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/L1MessageQueue.sol)`</u> <u>function. A scenario could occur where a</u>

user sends an L1-to-L2 transaction that gets skipped. The user can now choose to either

replay or drop the message.


However, an adversary could void the user's intention by front-running the user's intended

action if they have an incentive to do so. If a user wants to replay their message, the adversary

could front-run the user and call `dropMessage` . Similarly, if a user wants to drop their

message, the adversary could front-run the user and call `replayMessage` .


Consider only allowing the sender of the original message to replay or drop their message to

prevent front-running attacks.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_Firstly, we do not think the fact that the transaction can be front-run is a big problem._

_Secondly, it is not easy to figure out which user is the original sender of the message._

_Thirdly, in some situations, we want to replay or drop message for some users, so we do_

_not plan on fixing the issue._


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Medium

Severity − 16


## **Low Severity**

### **L-01 Error-Prone Call Encoding**

On <u>[line 126 of](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/libraries/ScrollMessengerBase.sol#L126)</u> <u>`[ScrollMessengerBase.sol](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/libraries/ScrollMessengerBase.sol)`</u> a call is encoded with

`abi.encodeWithSignature`, which is prone to typographical errors. Instead, consider

using the <u>`[abi.encodeCall](https://docs.soliditylang.org/en/v0.8.20/cheatsheet.html#abi-encoding-and-decoding-functions)`</u> <u>function</u> that protects against mistakes. When making this

change, ensure that at least Solidity version 0.8.13 or above is used, due to a <u>[bug encoding](https://blog.soliditylang.org/2022/03/16/encodecall-bug/)</u>

<u>[literals.](https://blog.soliditylang.org/2022/03/16/encodecall-bug/)</u>


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_This is the only_ _`encodeWithSignature`_ _left in the contracts. The reason why we do_

_not fix it is because the_ _`relayMessage`_ _is only used in_ _`L2ScrollMessenger`_ _. If we_

_use_ _`abi.encodeCall`_ _, some L2 only interface will be introduced to the base contract,_

_which is not good in our opinion._

### **L-02 Anyone Can Steal ERC-20 Tokens From** **`GasSwap`**


The `GasSwap` contract implements the <u>`[withdraw](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L130)`</u> <u>function to allow the owner to</u> `withdraw`

ETH or ERC-20 tokens that are stuck within the contract. This contract also contains a <u>`[swap](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L128C14-L128C32)`</u>

<u>[function, which allows users to swap any ERC-20 token for a specified amount of ETH. This](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L128C14-L128C32)</u>

function performs the swap followed by <u>[a refund of the unswapped tokens](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/L1MessageQueue.sol)</u> to the user.


However, the amount refunded to the user is the total balance of the `GasSwap` contract of that

ERC-20 token, which includes the amount of that ERC-20 token that has been stuck in the

contract. Therefore, if there is any ERC-20 token that is stuck in `GasSwap`, any user can

execute a swap of 0 tokens of that particular ERC-20 token and obtain these stuck tokens for

themselves as the refund.


When swapping, consider taking into account the user's balance of the swapped token before

and after the swap, before refunding the user.


**_Update:_** _Resolved in_ _<u>[pull request #844](https://github.com/scroll-tech/scroll/pull/844)</u>_ _at commit_ _<u>[7a26dbc.](https://github.com/scroll-tech/scroll/pull/844/commits/7a26dbce9c0cd6b170702cd9a36ebf0d2453efc3)</u>_


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Low

Severity − 17


### **L-03 Inconsistency of Allowing a Trusted** **Forwarder**

In `GasSwap`, some parts of the code rely on `_msgSender` and others on `msg.sender` . This

inconsistency can lead to confusion as to when meta-transactions are allowed. For example,

`GasSwap` inherits from `OwnableBase` which has an `onlyOwner` check that uses

<u>`[msg.sender](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/libraries/common/OwnableBase.sol#L28)`</u> . Therefore, all functions with `onlyOwner` modifier will fail when submitted

through a trusted forwarder.


This inconsistency is confusing and error-prone. Consider using `_msgSender()` everywhere

in `GasSwap` and `OwnableBase`, which will automatically default to `msg.sender` if it is not

sent from the `trustedForwarder` address.


**_Update:_** _Resolved in_ _<u>[pull request #846](https://github.com/scroll-tech/scroll/pull/846)</u>_ _at commit_ _<u>[60de22b.](https://github.com/scroll-tech/scroll/pull/846/commits/60de22bfea6cde7c7790b3a8914230d1ea0a70af)</u>_

### **L-04 Inconsistency of Reentrancy Guard**


The <u>`[ScrollMessengerBase](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/libraries/ScrollMessengerBase.sol#L54-L66)`</u> and <u>`[ScrollGatewayBase](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/libraries/gateway/ScrollGatewayBase.sol#L42-L54)`</u> contracts implement a

`nonReentrant` modifier. Instead, consider utilizing the <u>[ReentrancyGuardUpgradeable](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.9/contracts/security/ReentrancyGuardUpgradeable.sol)</u>

<u>[contract](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.9/contracts/security/ReentrancyGuardUpgradeable.sol)</u> of the OpenZeppelin library which is a dependency in use. The reimplementation of

such safety mechanisms is generally discouraged. In addition, this is inconsistent with other

contracts such as <u>`[EnforcedTxGateway](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/EnforcedTxGateway.sol#L15)`</u>, which does, in fact, use OpenZeppelin's reentrancy

guard. In both cases, make sure to initialize the contracts properly if they are used for

upgradeable contracts.


**_Update:_** _Resolved in_ _<u>[pull request #698](https://github.com/scroll-tech/scroll/pull/698)</u>_ _at commit_ _<u>[a798e4d.](https://github.com/scroll-tech/scroll/pull/698/commits/a798e4d52524ddc388e48f9b24d437ee0b3ad85d)</u>_

### **L-05 Potentially Stuck ETH in GasSwap**


In the <u>`[GasSwap](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L130)`</u> <u>contract, the</u> <u>`[swap](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L128C14-L128C32)`</u> <u>[function](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L128C14-L128C32)</u> allows a user to swap ERC-20 tokens for ETH.

The swap is <u>[executed by calling an approved target, which in return transfers ETH to the](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/L1MessageQueue.sol)</u>

`GasSwap` contract through the <u>`[receive](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/L1MessageQueue.sol#L382)`</u> <u>function. The user is then</u> <u>[reimbursed](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/L1MessageQueue.sol#L102)</u> the output

amount of ETH after deducting the fee.


However, any user can accidentally transfer ETH to the `GasSwap` contract without calling the

`swap` function. Any ETH transferred outside of a swap will be locked in the contract and is

only redeemable through the owner.


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Low

Severity − 18


Consider only allowing ETH transfers to the `GasSwap` contract from approved targets to

minimize the probability of having ETH accidentally locked in this contract. Alternatively,

consider only allowing ETH transfers to the contract during a swap.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_Our owner can rescue the stuck ETH as long as the user provides the transfer_

_transaction._

### **L-06 Possible Misleading revert Message When** **Swapping Non- ERC20Permit Tokens**


The `GasSwap` contract allows users to sign an off-chain transaction and pass it to a forwarder

to swap any `ERC20Permit` token on their behalf. However, since the <u>`[_permit.token](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L130)`</u> can

be arbitrarily chosen by the user, there is no guarantee that the address of the token is an

`ERC20Permit` token. If the token has a `fallback` function that fails silently, the call to the

`permit` function will not revert. In this case, the transaction will fail when trying to call

<u>`[safeTransferFrom](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L128C14-L128C32)`</u>, emitting an insufficient allowance message.


Consider using the `safePermit` function from the imported `SafeERC20` library to fail with a

more reasonable message.


**_Update:_** _Resolved in_ _<u>[pull request #847](https://github.com/scroll-tech/scroll/pull/847)</u>_ _at commit_ _<u>[8daae8f.](https://github.com/scroll-tech/scroll/pull/847/commits/8daae8f401d7806ec5910b8e6d9915bc60cc586f)</u>_

### **L-07 Potentially Misleading Verifier Event**


The `MultipleVersionRollupVerifier` contract maps the batch index to the address of

the verifier that was used. The owner of this contract can call the <u>`[updateVerifier](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/MultipleVersionRollupVerifier.sol#L103)`</u> function

in order to update the verifier. For this update to succeed, it <u>[requires that the provided](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/MultipleVersionRollupVerifier.sol#L105)</u>

<u>`[startBatchIndex](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/MultipleVersionRollupVerifier.sol#L105)`</u> <u>[is greater than or equal to the previous verifier's](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/MultipleVersionRollupVerifier.sol#L105)</u> <u>`[startBatchIndex](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/MultipleVersionRollupVerifier.sol#L105)`</u> .


However, it does not check if that batch number has already been verified by the current

verifier, which could be confusing. For example, if the current verifier's start index is 100, and it

has verified batches up to batch 105, the new verifier could be set with a start index of 102.

The <u>[event emitted](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/MultipleVersionRollupVerifier.sol#L116)</u> would contain the index of 102, which would be confusing because it would

appear to a user monitoring the events as though the new verifier was used to verify the

batches 102-105 when in reality it was not. This could even be used maliciously by the owner

to hide information relating to a faulty verifier.


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Low

Severity − 19


Consider enforcing that the start index must be greater than the

<u>`[lastFinalizedBatchIndex](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/ScrollChain.sol#L70)`</u> .


**_Update:_** _Resolved in_ _<u>[pull request #849](https://github.com/scroll-tech/scroll/pull/849)</u>_ _at commit_ _<u>[6527331.](https://github.com/scroll-tech/scroll/pull/849/commits/6527331f9ec01e536da328a91880dd16ce6b67e4)</u>_

### **L-08 Redundancy of Replaying Messages in** **`L2ScrollMessenger`**


The logic to retry messages sent from L1 to L2 lives solely in the <u>`[replayMessage](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol#L175)`</u> <u>function</u> in

`L1ScrollMessenger` . In addition, the <u>[maximum number of times that a message can be](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol#L63)</u>

<u>[replayed](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol#L63)</u> as well as the <u>`[replayStates](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol#L66)`</u> are also located in `L1ScrollMessenger` .


However, the `L2ScrollMessenger` also contains a <u>`[maxFailedExecutionTimes](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/L2ScrollMessenger.sol#L59)`</u> state

variable and a <u>`[l1MessageFailedTimes](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/L2ScrollMessenger.sol#L56)`</u> mapping, which are tracking the same values as on

the L1 side. When executing a message in `L2ScrollMessenger`, it uses these variables to

determine whether or not a <u>[transaction will succeed. However, given that the maximum](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/L2ScrollMessenger.sol#L207-L209)</u>

number of failed execution times <u>[can be updated](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/L2ScrollMessenger.sol#L139-L145)</u> to be a different value than that on the L1

side, this could cause confusion for a user who replays a transaction from L1. This duplication

of function can also result in future issues when refactoring code, which could lead to future

vulnerabilities.


Consider removing all code related to replaying messages in `L2ScrollMessenger` to reduce

code duplication as well as the potential surface of future errors.


**_Update:_** _Resolved in_ _<u>[pull request #850](https://github.com/scroll-tech/scroll/pull/850)</u>_ _at commit_ _<u>[51a74dd.](https://github.com/scroll-tech/scroll/pull/850/commits/51a74dd0fafcde21d7f4631d29ab625d802dc9d1)</u>_

### **L-09 Misleading and Incorrect Comments**


Throughout the code, we found several comments that were either misleading or incorrect.

Some examples are:


   - This <u>[comment](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L128C14-L128C32)</u> in `ScrollMessengerBase` suggests moving the declaration of

`_lock_status` to `ScrollMessengerBase` in the next big refactor, which has already

been done.

  - The comments on lines <u>[36](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/L1MessageQueue.sol#L102)</u> and <u>[172](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1CustomERC20Gateway.sol)</u> in `L1ERC721Gateway` should say `_l2Token`

instead of `_l1Token` .

   - The <u>[comment on line 134](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1CustomERC20Gateway.sol#L122)</u> in `L2USDCGateway.sol` should say `L2GatewayRouter`

instead of `L1GatewayRouter` .


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Low

Severity − 20


Consider resolving these instances of incorrect documentation to improve the clarity and

readability of the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #851](https://github.com/scroll-tech/scroll/pull/851)</u>_ _at commit_ _<u>[b933adb.](https://github.com/scroll-tech/scroll/pull/851/commits/b933adb279290665c362f3d264dec52733d34348)</u>_

### **L-10 maxReplayTimes is Not Initialized in** **`L1ScrollMessenger`**


Currently `maxReplayTimes` is not being set in the <u>`[initialize](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol#L94-L105)`</u> function of

`L1ScrollMessenger` . In addition, the <u>[deployment script](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/scripts/initialize_l1_messenger.ts)</u> for `L1ScrollMessenger` does

not call <u>`[updateMaxReplayTimes](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol#L312-L316)`</u> to set `maxReplayTimes` to an appropriate value. An

uninitialized value of `maxReplyTimes` would have the value of 0, which would prevent any

user from calling <u>`[replayMessage](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol#L175-L238)`</u> due to the <u>[max reply check](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol#L224)</u> reverting. Therefore, this will

happen until `updateMaxReplayTimes` is called to set `maxReplayTimes` .


Consider setting `maxReplayTimes` to an appropriate value during the initialization of the

`L1ScrollMessenger` contract.


**_Update:_** _Resolved in_ _<u>[pull request #852](https://github.com/scroll-tech/scroll/pull/852)</u>_ _at commit_ _<u>[020d272.](https://github.com/scroll-tech/scroll/pull/852/commits/020d272bf3326e2a96c91af3f31b4200cc21c70a)</u>_

## **Notes & Additional** **Information**

### **N-01 Tokens With Permit Functionality Can Be** **Front-Run**


Tokens that are created on L2 through the standard flow of bridging from

`L1StandardERC20Gateway` will be of type `ScrollStandardERC20`, which <u>[has](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/libraries/token/ScrollStandardERC20.sol#L17)</u> `permit`

functionality. In addition, the <u>`[WrappedEther](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/predeploys/WrappedEther.sol#L12)`</u> <u>contract</u> will also have `permit` functionality. If a

user wants to call the `permit` function for these tokens from L1 to L2 through the

`EnforcedTxGateway`, a malicious user could read it and execute the `permit` in L2 before it

arrives.


The result would be that when this L1 to L2 message is executed on L2, it would fail since it

would attempt to execute the same `permit` function with the same nonce. This griefing


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Notes &

Additional Information − 21


attack could confuse the user, who may believe that the `permit` did not succeed on L2, and

cause them to re-send the message, costing the user more gas.


Consider discouraging calling the `permit` function from L1 to L2 or documenting the

possibility of front-running griefing attacks more thoroughly. Alternatively, consider removing

the `permit` functionality from frequently used tokens in L2.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_It seems not a big problem, we think it is not necessary to fix._

### **N-02 Extraneous Use of safeApprove**


In the <u>`[swap](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/gas-swap/GasSwap.sol#L111-L112)`</u> function of `GasSwap`, the function `safeApprove` is used to approve an amount

of 0 and once again to approve the desired value. While this will mitigate the attack against

double increments, it is gas-inefficient and not the best practice. Furthermore, `safeApprove`

will not be supported in future OpenZeppelin contracts.


Consider avoiding this anti-pattern with the use of `safeIncreaseAllowance` and

`safeDecreaseAllowance` instead.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_We want make sure only at most_ _`amount`_ _is used by the target contract, so_

_safeApprove is our best choice._

### **N-03 Variables Missing immutable Keyword**


Throughout the codebase, there are variables that remain unchanged after initialization and can

be optimized by declaring them as immutable variables and setting them in the constructor.

This could increase code clarity as well as reduce gas costs. For instance:


   - The variables <u>`[rollup](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol#L57)`</u> and <u>`[messageQueue](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol#L60)`</u> in `L1ScrollMessenger`

   - The variable <u>`[counterpart](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/libraries/ScrollMessengerBase.sol#L38)`</u> in `ScrollMessengerBase`

   - The variables <u>`[messenger](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/L1MessageQueue.sol#L44)`</u> and <u>`[scrollChain](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/L1MessageQueue.sol#L47)`</u> in `L1MessageQueue`

   - The variable <u>`[messageQueue](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/ScrollChain.sol#L58)`</u> in `ScrollChain`


Consider declaring these variables as `immutable` if they are not meant to be updateable

later.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Notes &

Additional Information − 22


_Some of the addresses are not known until deploy, so current way works well for us._

### **N-04 Inconsistency Between maxReplayTimes** **and ReplayState.times**


The state variable <u>`[maxReplayTimes](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol#L63)`</u> is of type `uint256`, while the struct field

<u>`[ReplayState.times](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol#L38)`</u> is of type `uint128` (for the purpose of packing the struct into one

storage slot).


If `maxReplayTimes` is set to be greater than `type(uint128).max`, a user would be

allowed to replay their message more than `type(uint128).max` times. Due to the use of

<u>`[unchecked block](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol#L225-L227)`</u>, the value of `_replayState.times` could overflow, causing

unexpected behavior.


Consider changing `maxReplayTimes` from `uint256` to `uint128` to prevent this potential

overflow.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_The overflow is not likely to happen. If someone replays the message 1 time per second,_

_it well need 10790283070806014188970529154990 years._

### **N-05 Lack of Indexed Event Parameters**


Throughout the <u>[codebase, several events do not have their parameters indexed. For instance:](https://github.com/scroll-tech/scroll/tree/2eb458cf4224d82fc56254e91e297a9ed261cefb/)</u>


   - The <u>`[UpdateMaxReplayTimes](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/IL1ScrollMessenger.sol#L14)`</u> event

   - The <u>`[DequeueTransaction](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/IL1MessageQueue.sol#L30)`</u> event

   - The <u>`[DropTransaction](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/IL1MessageQueue.sol#L34)`</u> event

   - The <u>`[UpdateVerifier](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/MultipleVersionRollupVerifier.sol#L18)`</u> event

   - The <u>`[UpdateMaxNumL2TxInChunk](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/ScrollChain.sol#L41)`</u> event

   - The <u>`[UpdateMaxFailedExecutionTimes](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/L2ScrollMessenger.sol#L36)`</u> event

   - The `UpdateTokenMapping` events <u>[1](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L130)</u> <u>[2](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/gateways/L2ERC721Gateway.sol#L30)</u>

   - The <u>`[UpdateWhitelist](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/predeploys/L1GasPriceOracle.sol#L19)`</u> event

   - The <u>`[UpdateFeeRatio](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/gas-swap/GasSwap.sol#L25)`</u> event

   - The <u>`[UpdateApprovedTarget](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/gas-swap/GasSwap.sol#L30)`</u> event


Consider <u>[indexing event parameters](https://solidity.readthedocs.io/en/latest/contracts.html#events)</u> to improve the ability of off-chain services to search and

filter for specific events.


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Notes &

Additional Information − 23


**_Update:_** _Partially resolved in_ _<u>[pull request #673](https://github.com/scroll-tech/scroll/pull/673)</u>_ _at commit_ _<u>[b7a02fb. The client added in indexed](https://github.com/scroll-tech/scroll/pull/673/commits/b7a02fbe54cf14fb0149df520343bf0195e00c99)</u>_

_parameters for a few events, but kept the following events unindexed:_


    - _The_ _<u>`[UpdateMaxReplayTimes](https://github.com/scroll-tech/scroll/blob/b7a02fbe54cf14fb0149df520343bf0195e00c99/contracts/src/L1/IL1ScrollMessenger.sol#L15)`</u>_ _event_

    - _The_ _<u>`[DequeueTransaction](https://github.com/scroll-tech/scroll/blob/b7a02fbe54cf14fb0149df520343bf0195e00c99/contracts/src/L1/rollup/IL1MessageQueue.sol#L30)`</u>_ _event_

    - _The_ _<u>`[DropTransaction](https://github.com/scroll-tech/scroll/blob/b7a02fbe54cf14fb0149df520343bf0195e00c99/contracts/src/L1/rollup/IL1MessageQueue.sol#L34)`</u>_ _event_

    - _The_ _<u>`[UpdateVerifier](https://github.com/scroll-tech/scroll/blob/b7a02fbe54cf14fb0149df520343bf0195e00c99/contracts/src/L1/rollup/MultipleVersionRollupVerifier.sol#L18)`</u>_ _event_

    - _The_ _<u>`[UpdateMaxNumL2TxInChunk](https://github.com/scroll-tech/scroll/blob/b7a02fbe54cf14fb0149df520343bf0195e00c99/contracts/src/L1/rollup/ScrollChain.sol#L41)`</u>_ _event_

    - _The_ _<u>`[UpdateMaxFailedExecutionTimes](https://github.com/scroll-tech/scroll/blob/b7a02fbe54cf14fb0149df520343bf0195e00c99/contracts/src/L2/IL2ScrollMessenger.sol#L15)`</u>_ _event_

    - _The_ _<u>`[UpdateWhitelist](https://github.com/scroll-tech/scroll/blob/b7a02fbe54cf14fb0149df520343bf0195e00c99/contracts/src/L2/predeploys/L1GasPriceOracle.sol#L19)`</u>_ _event_

    - _The_ _<u>`[UpdateFeeRatio](https://github.com/scroll-tech/scroll/blob/b7a02fbe54cf14fb0149df520343bf0195e00c99/contracts/src/gas-swap/GasSwap.sol#L25)`</u>_ _event_

    - _The_ _<u>`[UpdateApprovedTarget](https://github.com/scroll-tech/scroll/blob/b7a02fbe54cf14fb0149df520343bf0195e00c99/contracts/src/gas-swap/GasSwap.sol#L30)`</u>_ _event_

### **N-06 Inconsistent Coding Style**


Throughout the codebase, a couple of `solhint-disable no-empty-blocks` instances

were found that are unnecessary. The `no-empty-blocks` rule should only be used to

suppress `solhint` warnings if a code block has zero statements inside. However, multiple

instances were found where the rule was implemented, but no empty blocks were found in the

code. For instance: - <u>[Line 19](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L130)</u> in `L1ERC20Gateway` - <u>[Line 7](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L128C14-L128C32)</u> in `L2ERC20Gateway`


Consider removing the `solhint-disable no-empty-blocks` statements listed above to

improve the clarity of the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #874](https://github.com/scroll-tech/scroll/pull/874)</u>_ _at commit_ _<u>[ba98a1a.](https://github.com/scroll-tech/scroll/pull/874/commits/ba98a1add3baa1c8e43238cd0c91edee7e0fa2e1)</u>_

### **N-07 Incorrect Function Visibility**


The <u>`[depositETH](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L130)`</u> function is not called internally by any of the functions in the

`L1ETHGateway` contract. Consider setting the visibility to `external` instead of `public` .


**_Update:_** _Resolved in_ _<u>[pull request #875](https://github.com/scroll-tech/scroll/pull/875)</u>_ _at commit_ _<u>[f5e5de1.](https://github.com/scroll-tech/scroll/pull/875/commits/f5e5de194a1311398b1121f1d7d40cedf43a45c5)</u>_

### **N-08 Inconsistent Order of Event Emissions**


Throughout the codebase, events are emitted after the corresponding storage has changed.

However, in <u>`[revertBatch](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L130)`</u> in `ScrollChain`, the <u>`[RevertBatch](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L128C14-L128C32)`</u> <u>event</u> is being emitted

before <u>[resetting the batch value.](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/L1MessageQueue.sol)</u>


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Notes &

Additional Information − 24


To improve the readability and consistency of the codebase, consider always following the

same order of operations when emitting an event in response to a change in the state of the

contract.


**_Update:_** _Resolved in_ _<u>[pull request #876](https://github.com/scroll-tech/scroll/pull/876)</u>_ _at commit_ _<u>[4b8d9ce.](https://github.com/scroll-tech/scroll/pull/876/commits/4b8d9cef5140d3db4a7947ffa817b64f3a5719e9)</u>_

### **N-09 Missing and Inconsistent Event Emissions**


Throughout the codebase, several constructors and initializers do not emit events after

initializing sensitive variables in the system, although when those variables are updated using

setter functions, an event is emitted. For instance:


   - In the `constructor` of `FeeVault`, both the storage variables <u>`[minWithdrawAmount](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L130)`</u>

and <u>`[recipient](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L128C14-L128C32)`</u> are changed without emitting the events

`UpdateMinWithdrawAmount` and `UpdateRecipient` respectively.

   - When initializing `ScrollMessengerBase`, the storage variable <u>`[feeVault](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/L1MessageQueue.sol)`</u> is changed

without emitting the respective `UpdateFeeVault` event.

   - In the `constructor` of `GasSwap`, setting the storage variable <u>`[owner](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/L1MessageQueue.sol#L382)`</u> does not emit

the `OwnershipTransferred` event.

   - In the `constructor` of `MultipleVersionRollupVerifier`, the storage variable

<u>`[latestVerifier](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1CustomERC20Gateway.sol)`</u> is changed without emitting the respective `UpdateVerifier`

event.

   - When initializing `EnforcedTxGateway`, the storage variable <u>`[feeVault](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1CustomERC20Gateway.sol#L102)`</u> is changed

without emitting the respective `UpdateFeeVault` event.


In addition, in `L1ScrollMessenger`, the functions <u>`[dropMessage](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/L1MessageQueue.sol#L102)`</u> and <u>`[replayMessage](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1CustomERC20Gateway.sol#L122)`</u> do

not emit an event when a message is dropped or replayed. Also, the functions

<u>`[pauseDeposit](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol)`</u> and <u>`[pauseWithdraw](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L151)`</u> in `L2USDCGateway` do not emit an event when

deposits or withdrawals are paused.


Consider emitting events when changing state variables. Moreover, consider replacing the

manual variable declarations in constructors and initializers with the corresponding setter

function to update those variables.


**_Update:_** _Acknowledged, will resolve. The Scroll team stated that they will resolve the issue:_


_It will be fixed later on when we have more time._


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Notes &

Additional Information − 25


### **N-10 Code Duplication**

There are instances of duplicated code within the codebase. Duplicating code can lead to

issues later in the development lifecycle and leaves the project more prone to the introduction

of errors. Such errors can inadvertently be introduced when functionality changes are not

replicated across all instances of code that should be identical. For instance:


   - In the <u>`[L1MessageQueue](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/L1MessageQueue.sol)`</u> <u>contract</u> the <u>[value while declaring](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/L1MessageQueue.sol#L382)</u> <u>`[_queueIndex](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/L1MessageQueue.sol#L382)`</u> can be

replaced by calling <u>`[nextCrossDomainMessageIndex](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/rollup/L1MessageQueue.sol#L102)`</u> . Consider marking

`nextCrossDomainMessageIndex` as `public` .

   - In the <u>`[L1CustomERC20Gateway](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1CustomERC20Gateway.sol)`</u> <u>contract</u> multiple instances, for example on lines <u>[102](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1CustomERC20Gateway.sol#L102)</u>

and <u>[122, obtain the value of the L2 token address by accessing the mapping directly.](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1CustomERC20Gateway.sol#L122)</u>

Consider using the designated `getL2ERC20Address` function.

   - In the <u>`[L1ERC20Gateway](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol)`</u> <u>contract, if</u> <u>`[msg.sender != router](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L151)`</u>, the amount requested

is calculated in the <u>`[else](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L155-L162)`</u> <u>[-block. However, the calculation can be replaced by calling the](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L155-L162)</u>

designated <u>`[requestERC20](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1GatewayRouter.sol#L110)`</u> <u>function.</u>

   - In the <u>`[L1ERC721Gateway](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC721Gateway.sol)`</u> <u>contract, lines</u> <u>[196 to 197](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC721Gateway.sol#L196-L197)</u> and <u>[227 to 228](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC721Gateway.sol#L227-L228)</u> obtain the

corresponding L2 address of the token being deposited and check if the address exists.

Consider replacing these lines with a corresponding internal function.

   - All instances of the <u>`[OwnableBase](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/libraries/common/OwnableBase.sol)`</u> <u>contract</u> can be replaced by OpenZeppelin's

`Ownable` contract.

   - During the initialization of the <u>`[L1GatewayRouter](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1GatewayRouter.sol)`</u> <u>contract, the declaration of the</u>

variables <u>`[defaultERC20Gateway](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1GatewayRouter.sol#L70-L71)`</u> and <u>`[ethGateway](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1GatewayRouter.sol#L76-L77)`</u> can be replaced by the

<u>`[setDefaultERC20Gateway](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1GatewayRouter.sol#L235)`</u> and <u>`[setETHGateway](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1GatewayRouter.sol#L228)`</u> functions respectively.

   - During the initialization of the <u>`[L2GatewayRouter](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/gateways/L2GatewayRouter.sol)`</u> <u>contract, the declaration of the</u>

variables <u>`[defaultERC20Gateway](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/gateways/L2GatewayRouter.sol#L47-L48)`</u> and <u>`[ethGateway](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/gateways/L2GatewayRouter.sol#L53-L54)`</u> can be replaced by the

<u>`[setDefaultERC20Gateway](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/gateways/L2GatewayRouter.sol#L195)`</u> and <u>`[setETHGateway](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/gateways/L2GatewayRouter.sol#L186)`</u> functions respectively.


Consider removing the listed code duplications to improve the readability and consistency of

the codebase.


**_Update:_** _Acknowledged, will resolve. The Scroll team stated that they will resolve the issue:_


_It will be fixed later on when we have more time._


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Notes &

Additional Information − 26


### **N-11 Follow the Checks-Effects-Interactions** **Pattern**

In the <u>`[relayMessageWithProof](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol#L133)`</u> function in `L1ScrollMessenger`, there is an <u>[external call](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol#L162)</u>

which is made before a <u>[state update, thereby breaking the Checks-Effects-Interactions pattern.](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol#L167)</u>

While currently there may not be a reentrancy risk, it is still considered best practice to follow

this pattern to mitigate future issues that may occur when refactoring code.


Consider rewriting this function to follow the Checks-Effects-Interactions pattern.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_It is hard to do so, that's why we add a reentrancy guard here._

### **N-12 Unused Function Parameter**


The <u>`[_receiver](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L130)`</u> <u>parameter</u> is never used in any implementations of the

<u>`[_beforeDropMessage](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L128C14-L128C32)`</u> <u>function.</u>


Consider removing the unused function parameter to avoid confusion.


**_Update:_** _Resolved. This is not an issue. The Scroll team stated:_


_Yeah, it is not used in our gateways. But we keep it, just in case if thirdparty gateways_

_need it._

### **N-13 Unnecessary Usage of Upgradeable** **Interfaces**


Upgradeable patterns are useful for contract upgradeability. While useful in the context of the

implementation contract, it is unnecessary to use the following upgradeable interfaces and

libraries to call into an external contract. Using upgradeable interfaces and libraries can

introduce unnecessary complexity to your codebase and reduce code readability. For example:

- <u>`[SafeERC20Upgradeable](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1GatewayRouter.sol#L21C11-L21C31)`</u> and <u>`[IERC20Upgradeable](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1GatewayRouter.sol#L21C36-L21C53)`</u> in `L1GatewayRouter` . 
<u>`[SafeERC20Upgradeable](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1CustomERC20Gateway.sol#L22C11-L22C31)`</u> and <u>`[IERC20Upgradeable](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1CustomERC20Gateway.sol#L22C36-L22C53)`</u> in `L1CustomERC20Gateway` . 
<u>`[SafeERC20Upgradeable](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/gateways/usdc/L2USDCGateway.sol#L21C11-L21C31)`</u> and <u>`[IERC20Upgradeable](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/gateways/usdc/L2USDCGateway.sol#L21C36-L21C53)`</u> in `L2USDCGateway` .


Consider using upgradeable patterns only for the code contract logic and implementing non
upgradeable interfaces and libraries for better code compatibility and consistency.


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Notes &

Additional Information − 27


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_All the contracts mentioned are upgradeable, I think it is ok to use the upgradeable_

_version of IERC20 and SafeERC20._

### **N-14 Duplicate Imports**


There are duplicate imports throughout the <u>[codebase. For instance:](https://github.com/scroll-tech/scroll/tree/2eb458cf4224d82fc56254e91e297a9ed261cefb/)</u>


   - The duplicate import <u>`[ScrollGatewayBase](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L11)`</u> in <u>`[L1ERC20Gateway.sol](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol)`</u>

   - The duplicate import <u>`[IERC20](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/gas-swap/GasSwap.sol#L7)`</u> in <u>`[GasSwap.sol](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/gas-swap/GasSwap.sol)`</u>


Consider removing duplicate imports to improve the readability of the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #877](https://github.com/scroll-tech/scroll/pull/877)</u>_ _at commit_ _<u>[b73f7a9.](https://github.com/scroll-tech/scroll/pull/877/commits/b73f7a9fa231f2350dcce9d07aa9030100103d06)</u>_

### **N-15 Unused Imports**


Throughout the <u>[codebase](https://github.com/scroll-tech/scroll/tree/2eb458cf4224d82fc56254e91e297a9ed261cefb/)</u> there are imports that are unused and could be removed. For

instance:


   - Import <u>`[AddressAliasHelper](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol#L13)`</u> of <u>`[L1ScrollMessenger.sol](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/L1ScrollMessenger.sol)`</u>

   - Import <u>`[IScrollMessenger](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L14)`</u> of <u>`[L1ERC20Gateway.sol](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol)`</u>

   - Import <u>`[ScrollConstants](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L15)`</u> of <u>`[L1ERC20Gateway.sol](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol)`</u>

   - Import <u>`[IScrollGateway](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1GatewayRouter.sol#L9)`</u> of <u>`[L1GatewayRouter.sol](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1GatewayRouter.sol)`</u>

   - Import <u>`[IL1ScrollMessenger](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1GatewayRouter.sol#L10)`</u> of <u>`[L1GatewayRouter.sol](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1GatewayRouter.sol)`</u>

   - Import <u>`[IL1BlockContainer](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/L2ScrollMessenger.sol#L9)`</u> of <u>`[L2ScrollMessenger.sol](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/L2ScrollMessenger.sol)`</u>

   - Import <u>`[IL1GasPriceOracle](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/L2ScrollMessenger.sol#L10)`</u> of <u>`[L2ScrollMessenger.sol](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/L2ScrollMessenger.sol)`</u>

   - Import <u>`[PatriciaMerkleTrieVerifier](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/L2ScrollMessenger.sol#L12)`</u> of <u>`[L2ScrollMessenger.sol](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/L2ScrollMessenger.sol)`</u>

   - Import <u>`[IERC1155Upgradeable](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/gateways/L2ERC1155Gateway.sol#L6)`</u> of <u>`[L2ERC1155Gateway.sol](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/gateways/L2ERC1155Gateway.sol)`</u>

   - Import <u>`[IScrollGateway](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/gateways/L2ERC1155Gateway.sol#L12)`</u> of <u>`[L2ERC1155Gateway.sol](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/gateways/L2ERC1155Gateway.sol)`</u>

   - Import <u>`[IERC721Upgradeable](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/gateways/L2ERC721Gateway.sol#L6)`</u> of <u>`[L2ERC721Gateway.sol](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/gateways/L2ERC721Gateway.sol)`</u>

   - Import <u>`[IScrollGateway](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/gateways/L2ERC721Gateway.sol#L12)`</u> of <u>`[L2ERC721Gateway.sol](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/gateways/L2ERC721Gateway.sol)`</u>

   - Import <u>`[IScrollGateway](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/gateways/usdc/L2USDCGateway.sol#L14)`</u> of <u>`[L2USDCGateway.sol](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/gateways/usdc/L2USDCGateway.sol)`</u>

   - Import <u>`[IL1BlockContainer](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/predeploys/L1GasPriceOracle.sol#L8)`</u> of <u>`[L1GasPriceOracle.sol](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/predeploys/L1GasPriceOracle.sol)`</u>


Consider removing unused imports to improve the overall clarity and readability of the

codebase.


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Notes &

Additional Information − 28


**_Update:_** _Partially resolved in_ _<u>[pull request #698](https://github.com/scroll-tech/scroll/pull/698)</u>_ _at commit_ _<u>[3e21edb. The client removed most](https://github.com/scroll-tech/scroll/pull/698/commits/3e21edb752a57dad0c50feb1dfb8b86eda6465c8)</u>_

_unused imports, but kept the following:_


    - _Import_ _<u>`[IScrollMessenger](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L14)`</u>_ _of_ _<u>`[L1ERC20Gateway.sol](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol)`</u>_

    - _Import_ _<u>`[ScrollConstants](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol#L15)`</u>_ _of_ _<u>`[L1ERC20Gateway.sol](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/L1ERC20Gateway.sol)`</u>_

    - _Import_ _<u>`[PatriciaMerkleTrieVerifier](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/L2ScrollMessenger.sol#L12)`</u>_ _of_ _<u>`[L2ScrollMessenger.sol](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/L2ScrollMessenger.sol)`</u>_

    - _Import_ _<u>`[IScrollGateway](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/gateways/usdc/L2USDCGateway.sol#L14)`</u>_ _of_ _<u>`[L2USDCGateway.sol](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L2/gateways/usdc/L2USDCGateway.sol)`</u>_


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Notes &

Additional Information − 29


## **Recommendations**

### **ERC-20 Factory Design**

Tokens can be bridged in a custom and standard way. For the latter, the

<u>`[ScrollStandardERC20](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/libraries/token/ScrollStandardERC20.sol)`</u> is the default implementation that will represent the L1 token on L2.

This is realized with the <u>`[Clones](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/proxy/Clones.sol)`</u> <u>library</u> and the <u>[EIP-1167](https://eips.ethereum.org/EIPS/eip-1167)</u> standard. It works by deploying a

minimal proxy that delegates its calls into the token implementation and is initialized as the

token instance.


These standard tokens are not upgradeable, which comes with a trade-off. On the one hand, it

is more secure since the logic cannot be changed. On the other hand, it is less future-proof

meaning that standards like ERC-677 - which is not a finalized EIP - might at some point be

overruled by a new standard that finds mass adoption.


An alternative factory design that is future-proof would be the <u>[Beacon proxy pattern. In a](https://docs.openzeppelin.com/contracts/4.x/api/proxy#beacon)</u>

similar approach the `BeaconProxy` will be the token instance, but then fetches the

implementation contract to delegate to from a single `UpgradeableBeacon` contract. This

allows upgrading all tokens in one transaction.


Regarding the security implications of upgradeable contracts, it is crucial to have the

`UpgradeableBeacon` secured through a timelock, multisig, and cold wallets.

### **ERC-165 Support**


While most of the codebase is comprised of custom contracts which do not implement a

specific standard, the <u>`[ScrollStandardERC20](https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/libraries/token/ScrollStandardERC20.sol)`</u> <u>contract</u> is implementing the ERC-20 and

ERC-677 standards. As such, it makes sense to also add ERC-165 support to enable other

parties to identify its interface and the standard it implements.

### **Testing Coverage**


Due to the complex nature of the system, we believe this audit would have benefitted from

more complete testing coverage.


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit −

Recommendations − 30


While insufficient testing is not necessarily a vulnerability, it implies a high probability of

additional hidden vulnerabilities and bugs. Given the complexity of this codebase and the

numerous interrelated risk factors, this probability is further increased. Testing provides a full

implicit specification along with the expected behaviors of the codebase, which is especially

important when adding novel functionalities. A lack thereof increases the chances that

correctness issues will be missed. It also results in more effort to establish basic correctness

and reduces the effort spent exploring edge cases, thereby increasing the chances of missing

complex issues.


Moreover, the lack of repeated automated testing of the full specification increases the

chances of introducing breaking changes and new vulnerabilities. This applies to both

previously audited code and future changes to current code. This is particularly true in this

project due to the pace, extent, and complexity of ongoing and planned changes across all

parts of the stack (L1, L2, relayer, and zkEVM). Underspecified interfaces and assumptions

increase the risk of subtle integration issues, which testing could reduce by enforcing an

exhaustive specification.


We recommend implementing a comprehensive multi-level test suite consisting of contract
level tests with >90% coverage, per-layer deployment and integration tests that test the

deployment scripts as well as the system as a whole, per-layer fork tests for planned upgrades

and cross-chain full integration tests of the entire system. Crucially, the test suite should be

documented in a way so that a reviewer can set up and run all these test layers independently

of the development team. Some existing examples of such setups can be suggested for use as

reference in a follow-up conversation. Implementing such a test suite should be a very high

priority to ensure the system's robustness and reduce the risk of vulnerabilities and bugs.

### **Custom Gateway Contracts**


Developers who need to use custom gateway contracts should ensure that their contracts are

designed to allow for the burning of tokens and the creation of the same tokens with the same

ID. This is particularly relevant for non-fungible tokens (NFTs) and other unique asset types that

rely on the token ID for maintaining uniqueness.


The burning of tokens on one layer (L1 or L2) and the subsequent creation of the same tokens

on the other layer is a crucial feature for token bridging in layer 2 solutions like Scroll. However,

most NFT contracts are designed to create new tokens with a sequential counter, which makes

them incompatible with this requirement.


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit −

Recommendations − 31


Ensure providing adequate documentation, and if possible code examples, so that developers

in the Scroll ecosystem can properly implement these requirements.

### **Monitoring Recommendations**


While audits help in identifying code-level issues in the current implementation and potentially

the code deployed in production, the Scroll team is encouraged to consider incorporating

monitoring activities in the production environment. Ongoing monitoring of deployed contracts

helps identify potential threats and issues affecting production environments. With the goal of

providing a complete security assessment, the monitoring recommendations section raises

several actions addressing trust assumptions and out-of-scope components that can benefit

from on-chain monitoring.


Governance


Critical: There are several important contracts that use the Proxy Pattern and can be arbitrarily

upgraded by the proxy owner. Consider monitoring for upgrade events on at least the following

contracts:








```
ScrollChain
L1ScrollMessenger
L2ScrollMessenger

```



  - Gateway contracts


Access Control


Critical: `Ownable` allows implementing access control to prevent unauthorized parties from

making unintended changes, but it is important to monitor for events where the owner

changes. Consider monitoring for the `OwnershipTransferred` event on all ownable

contracts such as `ScrollChain`, `MultipleVersionRollupVerifier`, `GasSwap`,

`L1BlockContainer`, `L1GasPriceOracle`, `L1MessageQueue`, `L2MessageQueue`,

`L2TxFeeVault`, and `Whitelist` .


Technical


High: The rollup contract contains sensitive functions that should only be called by the owner.

Consider monitoring if any of the following events are emitted.








```
UpdateSequencer
UpdateProver
UpdateVerifier

```


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit −

Recommendations − 32


Medium: The `L1ScrollMessenger`, `L2ScrollMessenger`, and `L2USDCGateway`

contracts include a mechanism for pausing in case of an incident. Consider monitoring for

`Paused` since an unexpected pause may cause a disruption in the system.


Financial


Medium: Consider monitoring the size, cadence and token type of bridge transfers during

normal operations to establish a baseline of healthy properties. Any large deviation, such as an

unexpectedly large withdrawal, may indicate unusual behavior of the contracts or an ongoing

attack.


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit −

Recommendations − 33


## **Conclusion**

This three-week audit had a somewhat challenging start due to scope changes, but it

ultimately progressed smoothly and benefitted greatly from valuable insights provided by the

Scroll team, who were responsive and thorough with their answers to our questions. The

codebase of the Scroll protocol is well-documented and organized, making it easier to

understand its functionality and potential vulnerabilities. The architecture of the contracts is

sound and inspired by other protocols.


However, the fact that the protocol had not yet implemented a refund mechanism casts some

doubts on the protocol's readiness for it's production use. The lack of refund mechanisms,

except for skipped messages, is an important feature for safeguarding user assets when

bridging them, which points towards the need for further development before the protocol can

be considered ready for live deployment. In addition, we recommend a more exhaustive and

rigorous test suite after this feature has been implemented. Particularly, we feel that the

protocol would benefit from more extensive integration testing. Having said that, we see great

efforts by the Scroll team to realize this and launch the system responsibly.


Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit − Conclusion

                                                - 34


