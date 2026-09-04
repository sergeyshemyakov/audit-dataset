### | security

# **Batch Token** **Bridge Audit**

#### **May 17, 2024**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  5

L1BatchBridgeGateway Contract 5

L2BatchBridgeGateway Contract 5

BatchBridgeCodec Library 6


Security Model and Trust Assumptions _______________________________________________  6

Privileged Roles 6


Medium Severity ___________________________________________________________________  8

M-01 Malicious Actor Can Steal Deposits of Tokens With Sender Hooks or Cause Lock Of Funds 8


Low Severity ______________________________________________________________________  9

L-01 Failed Funds Can Be Locked Inside L2BatchBridgeGateway 9

L-02 Tokens Can Get Stuck While Finalizing Deposit 9

L-03 Multiple Usages of Obsolete safeApprove 10

L-04 Missing Event Emission After Configuration Change 10

L-05 Gas Inefficiencies 11


Notes & Additional Information ____________________________________________________ 11

N-01 Unused Event 11

N-02 Unnecessary Usage of Upgradeable Interfaces 11

N-03 Typos in Comments 12

N-04 Naming Suggestions 12

N-05 Unused Import 12

N-06 Lack of Security Contact 13

N-07 Overly Permissive Function Visibility 13

N-08 Missing Docstrings 14


Conclusion ______________________________________________________________________ 15


Batch Token Bridge Audit − Table of Contents − 2


## **Summary**

**Type** Layer 2


**Timeline** From 2024-04-26
To 2024-05-02


**Languages** Solidity



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


0 (0 resolved)


1 (1 resolved)



**Total Issues** 14 (4 resolved)



**Low Severity Issues** 5 (1 resolved)



**Notes & Additional**
**Information**



8 (2 resolved)



Batch Token Bridge Audit − Summary − 3


## **Scope**

We audited the <u>[scroll-tech/scroll](https://github.com/scroll-tech/scroll)</u> repository at commit <u>[84f73c7.](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498)</u>


In scope were the following files:

```
contracts/src/batch-bridge
├── BatchBridgeCodec.sol
├── L1BatchBridgeGateway.sol
└── L2BatchBridgeGateway.sol

```

Batch Token Bridge Audit − Scope − 4


## **System Overview**

We have previously covered Scroll's bridge architecture in the following reports: <u>[1, 2, 3, 4, 5.](https://blog.openzeppelin.com/scroll-phase-1-audit)</u>

Below, we shall provide a concise explanation of the bridge's core architecture in addition to

an extensive description of the recently implemented batch bridge functionality.


Scroll's native bridge is capable of bridging messages, ETH, and different tokens like ERC-20,

ERC-721, and ERC-1155 tokens. The bridge operates bidirectionally between L1 and L2. The

newly implemented batch bridge gateway is limited to unidirectionally batch bridging ETH and

ERC-20 tokens from L1 to L2. A deposit made on L1 can only be distributed to the same

depositor address on L2. In addition, there is no option for sending data alongside the deposit.

### **L1BatchBridgeGateway Contract**


The <mark>`L1BatchBridgeGateway`</mark> contract is the entry point of the batch bridging functionality.

For users to deposit ETH and ERC-20 tokens, the respective assets must be configured. To

avoid congestion or protracted delays, a batch of deposits will be finalized (ready to be

bridged) once either <mark>`maxTxsPerBatch`</mark> or <mark>`maxDelayPerBatch`</mark> is reached.


Finalizing a batch implies a separate transaction which sends two L1->L2 messages: the first

bridges the batch assets to L2 while the second calls <mark>`finalizeBatchDeposit`</mark> to relay a

hash that represents the depositors and their corresponding amounts. In contrast to other

bridge gateways on L1, <mark>`L1BatchBridgeGateway`</mark> does not implement the

<mark>`onDropMessage`</mark> callback.

### **L2BatchBridgeGateway Contract**


The <mark>`L2BatchBridgeGateway`</mark> contract is responsible for distributing the bridged assets. It

first receives the assets from the <mark>`L2ScrollMessenger`</mark> and then finalizes the batch by

storing the batch's hash. Once a batch is finalized on L2, the funds can be distributed to the

corresponding receivers. If any of the transfers fail, they will be accounted for and can be

withdrawn and manually refunded.


Batch Token Bridge Audit − System Overview − 5


### **BatchBridgeCodec Library**

The <mark>`BatchBridgeCodec`</mark> library is used to encode and decode the nodes for each batch

bridging. The initial node holds information about the token and the batch index. Each

following node holds the depositor's address and their deposited amount.

## **Security Model and Trust** **Assumptions**


Both <mark>`L1BatchBridgeGateway`</mark> and <mark>`L2BatchBridgeGateway`</mark> contracts are upgradeable.

Upon deployment, it is assumed that both contracts will be initialized and configured

accordingly.


When bridging a batch to L2, the system sends two consecutive messages to the

<mark>`L1ScrollMessenger`</mark> <mark>.</mark> These messages are expected to arrive in order and always cost

roughly the same amount of gas. Hence, it is assumed that the messenger will never drop any

of them. This not only makes the process atomic but also allows for not implementing the

<mark>`onDropMessage`</mark> callback.


Both <mark>`SAFE_BATCH_BRIDGE_GAS_LIMIT`</mark> and <mark>`SAFE_ETH_TRANSFER_GAS_LIMIT`</mark>

constants are pre-defined values that are used to avoid out-of-gas errors in their respective

function calls. It is assumed that the primary users of the batch bridge will be EOAs and

multisig wallets. Should the <mark>`SAFE_ETH_TRANSFER_GAS_LIMIT`</mark> not be enough while

distributing ETH to a certain recipient, the ETH will be retrieved using

<mark>`withdrawFailedAmount`</mark> and manually transferred to their address.

### **Privileged Roles**

```
DEFAULT_ADMIN_ROLE

```

This role will be assigned to <mark>`ScrollOwner`</mark> <mark>.</mark> On L1, this role is responsible for adding and

updating the batch bridge configuration for a given token address. When setting the batch

configuration, the caller should ensure that <mark>`safeBridgeGasLimit`</mark> is enough for batch

bridging the respective token. Moreover, the caller should set <mark>`maxTxsPerBatch`</mark> to a

reasonable value to avoid out-of-gas errors when distributing on L2. Last but not least, the


Batch Token Bridge Audit − Security Model and Trust Assumptions − 6


value of <mark>`maxDelayPerBatch`</mark> should also be set to a reasonable value to avoid long waiting

times for the users when bridging. On L2, this role is responsible for withdrawing failed

amounts while distributing and manually redistributing the assets to the corresponding

depositors.

```
KEEPER_ROLE

```

This role is responsible for executing batch deposits on L1 and distributing deposited assets to

corresponding receivers on L2. In order to do so, the <mark>`KEEPER_ROLE`</mark> will have to be

incentivized to spend gas, or be managed by the Scroll team.


Batch Token Bridge Audit − Security Model and Trust Assumptions − 7


## **Medium Severity**

### **M-01 Malicious Actor Can Steal Deposits of** **Tokens With Sender Hooks or Cause Lock Of** **Funds**

The <u><mark>`[depositERC20](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L221-L230)`</mark></u> <u>function</u> can be used to deposit ERC-20 tokens. It first <u>[transfers the](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L226)</u>

<u><mark>`[_msgSender()](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L226)`</mark></u> <u><mark>'</mark></u> <u>s tokens</u> to the contract and then <u>calls the</u> <u><mark>`[_deposit](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L229)`</mark></u> <u>function. If the token</u>

implements sender hooks, a malicious attacker can leverage this to trick the smart contract

into believing that they have deposited more funds than they actually had. Following are the

steps to achieve this:


1. A malicious contract calls the <mark>`depositERC20`</mark> function for a token with sender hooks

and deposits an amount of 50 tokens.

2. During <u>[the token transfer, the caller reenters the](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L226)</u> <mark>`depositERC20`</mark> function and deposits

50 tokens again.

3. The reentrancy check will not trigger as none of the calls has yet reached the <u><mark>`[_deposit](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L344)`</mark></u>

<u>[function.](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L344)</u>

4. The second execution increases the user's balance by 50 and toggles the reentrancy

guard on and then off.

5. The first execution increases the user's balance by 100, resulting in a total deposited

balance of 150 whereas only 100 tokens made it to the contract.


There are two effects of this: if the smart contract contains enough tokens for sending the

inflated amount of funds to L2, the batch deposit can be finalized on L2 and 150 tokens will be

distributed to the malicious attacker. Alternatively, if the smart contract does not contain

enough tokens, the <mark>`executeBatchDeposit`</mark> call would fail, without possibility of withdrawal

and hence locking the funds.


Consider moving the reentrancy guard to both the <mark>`depositERC20`</mark> and <mark>`depositETH`</mark>

functions in order to prevent any reentrancy into these functions.


**_Update:_** _Resolved in_ _<u>[pull request #1334](https://github.com/scroll-tech/scroll/pull/1334)</u>_ _at commit_ _<u>[3d08e40.](https://github.com/scroll-tech/scroll/pull/1334/commits/3d08e40f1e101558d4cd29cf6e07b00c4ba126f0)</u>_


Batch Token Bridge Audit − Medium Severity − 8


## **Low Severity**

### **L-01 Failed Funds Can Be Locked Inside** **`L2BatchBridgeGateway`**

After a batch deposit <u>[has been fnalized on L2i](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L2BatchBridgeGateway.sol#L144)</u> <u>, the</u> <mark>`KEEPER_ROLE`</mark> can <u>[distribute the funds. If](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L2BatchBridgeGateway.sol#L188)</u>

distributing to a party fails, the failed amounts <u>[are accounted for](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L2BatchBridgeGateway.sol#L210)</u> in order to rescue them later

through the <u><mark>`[withdrawFailedAmount](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L2BatchBridgeGateway.sol#L176)`</mark></u> <u>function. Note that the</u> <u><mark>`[_transferToken](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L2BatchBridgeGateway.sol#L228C5-L245C6)`</mark></u> <u>function</u>

does not revert on failure but returns a <mark>`success`</mark> value which <u>[is not checked. As such, if the](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L2BatchBridgeGateway.sol#L181)</u>

ETH or token transfer to the receiver fails, the <u><mark>`[failedAmount[token]](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L2BatchBridgeGateway.sol#L179)`</mark></u> is still set to 0, locking

the funds.


Consider checking the success value of <mark>`_transferTokens`</mark> and reverting if the transfer fails.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_Acknowledged. Not a priority._

### **L-02 Tokens Can Get Stuck While Finalizing** **Deposit**


In the <mark>`L1BatchBridgeGateway`</mark> contract, <u><mark>`[IL1ERC20Gateway.getL2ERC20Address](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L297)`</mark></u>

retrieves the corresponding <mark>`l2Token`</mark> address of the <mark>`l1Token`</mark> <mark>.</mark> In the

<mark>`L2BatchBridgeGateway`</mark> contract, a <u><mark>`[tokenMapping](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L2BatchBridgeGateway.sol#L85)`</mark></u> is used to set and get the

corresponding <mark>`l1Token`</mark> in order to minimize gas cost, as opposed to using the

<u><mark>`[IL2ERC20Gateway.getL1ERC20Address](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/L2/gateways/IL2ERC20Gateway.sol#L48)`</mark></u> function. The token mapping is used by the

<mark>`distribute`</mark> function, which needs to know the corresponding L1 address of the token to

distribute.


In the <mark>`L2BatchBridgeGateway`</mark> contract, the <u><mark>`[finalizeBatchDeposit](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L2BatchBridgeGateway.sol#L144-L167)`</mark></u> <u>function</u> relies on

the messenger to accurately <u>map the</u> <u><mark>`[l2Token](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L2BatchBridgeGateway.sol#L154-L158)`</mark></u> <u>[address to the associated](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L2BatchBridgeGateway.sol#L154-L158)</u> <u><mark>`[l1Token](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L2BatchBridgeGateway.sol#L154-L158)`</mark></u> when a

batch deposit of a token is executed and finalized for the first time. The function will revert in a

subsequent call if the <mark>`l1Token`</mark> differs from the <mark>`storedL1Token`</mark> <mark>.</mark>


In the <mark>`L2CustomERC20Gateway`</mark> contract, the token mapping from L2 to L1 is <u>[updatable. In a](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/L2/gateways/L2CustomERC20Gateway.sol#L114-L121)</u>

scenario where the tokens being bridged are handled by the <mark>`L2CustomERC20Gateway`</mark> <mark>,</mark> a

change of address of the token on L1 cannot be replicated in the <mark>`L2BatchBridgeGateway`</mark> <mark>.</mark>

When batch bridging the new <mark>`l1Token`</mark> with the changed address to L2, the


Batch Token Bridge Audit − Low Severity − 9


<mark>`finalizeBatchDeposit`</mark> function will retrieve the old <mark>`l1Token`</mark> address from its mapping.

Ultimately, the function will revert since the updated address of the <mark>`l1Token`</mark> will not match

the address that is recorded in the mapping.


Consider removing the duplicated token mapping and supplying the <mark>`l1Token`</mark> as a parameter

to the <mark>`distribute`</mark> function. Alternatively, consider either leveraging the

<mark>`IL2ERC20Gateway.getL1ERC20Address`</mark> function or providing a function that enables the

<mark>`L2BatchBridgeGateway`</mark> contract's token mapping to be updated.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_Acknowledged. Not a priority at the moment._

### **L-03 Multiple Usages of Obsolete safeApprove**


In the <u><mark>`[executeBatchDeposit](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L298-L299)`</mark></u> function of <mark>`L1BatchBridgeGateway`</mark> <mark>,</mark> the function

<mark>`safeApprove`</mark> is used to approve an amount of 0 and once again to approve the desired

value. While this ensures compatibility with tokens that require the approval to be set to zero

before setting it to a non-zero value(such as USDT), it hinders readability and is not the best

practice. Furthermore, <mark>`safeApprove`</mark> will not be supported in future OpenZeppelin contracts.


Consider implementing best practices by using the <mark>`SafeERC20`</mark> contract's <mark>`forceApprove`</mark>

function.


**_Update:_** _Acknowledged, will resolve. The Scroll team stated:_


_Acknowledged. Not a priority. We will document for better readability and update to_

_<mark>`forceApprover`</mark>_ _later._

### **L-04 Missing Event Emission After Configuration** **Change**


The <u><mark>`[setBatchConfig](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L242-L251)`</mark></u> <u>function</u> is used to add or update the batch bridge config for a given

token. However, this function does not emit any event.


Consider emitting an event to be able to efficiently track configuration changes off-chain.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_Acknowledged. Not a priority due to gas._


Batch Token Bridge Audit − Low Severity − 10


### **L-05 Gas Inefficiencies**

Across the codebase, there are some instances in which the code can be refactored to be

more gas efficient:


   - The <u><mark>`[newConfig](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L242)`</mark></u> <u>parameter</u> of the <mark>`setBatchConfig`</mark> function can be made read-only.

Consider changing its location from <mark>`memory`</mark> to <mark>`calldata`</mark> to save gas.

   - In order to improve code intentionality and reduce the gas cost in case of a revert,

consider switching the order of the following <u>[instructions](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L353-L356)</u> to prioritize the <u><mark>`[if](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L354-L356)`</mark></u> <u>[statement.](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L354-L356)</u>

   - The <u><mark>`[feeVault](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L163)`</mark></u> state variable of the <mark>`L1BatchBridgeGateway`</mark> contract is not

changeable, consider declaring it as <mark>`immutable`</mark> <mark>.</mark>


**_Update:_** _Resolved in_ _<u>[pull request #1334](https://github.com/scroll-tech/scroll/pull/1334)</u>_ _at commit_ _<u>[b7cc5c2.](https://github.com/scroll-tech/scroll/pull/1334/commits/b7cc5c293b7984fbeb8aa7a9f105bcfe27bc77f2)</u>_

## **Notes & Additional** **Information**

### **N-01 Unused Event**


In the <mark>`L2BatchBridgeGateway`</mark> contract, the <u><mark>`[UpdateTokenMapping](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L2BatchBridgeGateway.sol#L21)`</mark></u> <u>event</u> is unused.


To improve the overall clarity, intentionality, and readability of the codebase, consider removing

it.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_Acknowledged. Not a priority._

### **N-02 Unnecessary Usage of Upgradeable** **Interfaces**


Using upgradeable interfaces does not provide significant benefits and can introduce

unnecessary complexity to the codebase. Throughout the codebase, there are a few instances

where upgradeable interfaces are being used:







<u><mark>`[SafeERC20Upgradeable](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L7)`</mark></u> and <u><mark>`[IERC20Upgradeable](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L8)`</mark></u> in the

<mark>`L1BatchBridgeGateway`</mark> contract


Batch Token Bridge Audit − Notes & Additional Information − 11


<u><mark>`[IERC20Upgradeable](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L2BatchBridgeGateway.sol#L6)`</mark></u> in the <mark>`L2BatchBridgeGateway`</mark> contract



Moreover, upgradeable interfaces are no longer part of the <u>[newer releases](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/releases/tag/v5.0.0)</u> of the OpenZeppelin

Contracts Upgradable library.


Consider switching to non-upgradeable interfaces and libraries for better code compatibility.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_Acknowledged. Not a priority._

### **N-03 Typos in Comments**


In lines <u>[86, 169, and](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L86)</u> <u>[187](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L187)</u> of <mark>`L1BatchBridgeGateway.sol`</mark> <mark>,</mark> consider replacing

<mark>`L2BatchDepositGateway`</mark> by <mark>`L2BatchBridgeGateway`</mark> and <mark>`L1BatchDepositGateway`</mark>

by <mark>`L1BatchBridgeGateway`</mark> <mark>.</mark>


**_Update:_** _Resolved in_ _<u>[pull request #1334](https://github.com/scroll-tech/scroll/pull/1334)</u>_ _at commit_ _<u>[7a21e29.](https://github.com/scroll-tech/scroll/pull/1334/commits/7a21e297cbef2ade6fe0fbc5611b1483e23afcce)</u>_

### **N-04 Naming Suggestions**


In the <u><mark>`[L1BatchBridgeGateway](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol)`</mark></u> <u>contract, consider replacing the</u> <u><mark>`[tokens](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L160)`</mark></u> <u>[variable name](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L160)</u>

with <mark>`tokenStates`</mark> to favor explicitness and readability. In addition, consider renaming the

<u><mark>`[pending](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L141)`</mark></u> <u>[struct member](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L141)</u> to <mark>`pendingAmount`</mark> <mark>.</mark>


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_Acknowledged. Not a priority._

### **N-05 Unused Import**


The <u><mark>`[AddressUpgradeable](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L9)`</mark></u> <u>import</u> inside the <mark>`L1BatchBridgeGateway`</mark> is unused.

Consider removing it.


**_Update:_** _Resolved in_ _<u>[pull request #1334](https://github.com/scroll-tech/scroll/pull/1334)</u>_ _at commit_ _<u>[900ed4f.](https://github.com/scroll-tech/scroll/pull/1334/commits/900ed4f63c8712342e7c61922377fd4a5bb25b00)</u>_


Batch Token Bridge Audit − Notes & Additional Information − 12


### **N-06 Lack of Security Contact**

Providing a specific security contact (such as an email or ENS name) within a smart contract

significantly simplifies the process for individuals to communicate if they identify a vulnerability

in the code. This practice is quite beneficial as it permits the code owners to dictate the

communication channel for vulnerability disclosure, eliminating the risk of miscommunication

or failure to report due to a lack of knowledge on how to do so. In addition, if the contract

incorporates third-party libraries and a bug surfaces in those, it becomes easier for their

maintainers to contact the appropriate person about the problem and provide mitigation

instructions.


Throughout the codebase, there are contracts that do not have a security contact:


   - The <u><mark>`[BatchBridgeCodec](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/BatchBridgeCodec.sol)`</mark></u> <u>library</u>

   - The <u><mark>`[L1BatchBridgeGateway](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol)`</mark></u> <u>contract</u>

   - The <u><mark>`[L2BatchBridgeGateway](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L2BatchBridgeGateway.sol)`</mark></u> <u>contract</u>


Consider adding a NatSpec comment containing a security contact above each contract

definition. Using the <mark>`@custom:security-contact`</mark> convention is recommended as it has

been adopted by the <u>[OpenZeppelin Wizard](https://wizard.openzeppelin.com/)</u> and the <u>[ethereum-lists.](https://github.com/ethereum-lists/contracts#tracking-new-deployments)</u>


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_Acknowledged. Not a priority._

### **N-07 Overly Permissive Function Visibility**


The <u><mark>`[_deposit](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L344-L381)`</mark></u> and <u><mark>`[_tryFinalizeCurrentBatch](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/L1BatchBridgeGateway.sol#L388-L407)`</mark></u> functions in the

<mark>`L1BatchBridgeGateway`</mark> contract have unnecessarily permissive visibility.


To better convey their intended use, consider changing their visibility from <mark>`internal`</mark> to

<mark>`private`</mark> <mark>.</mark>


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_Acknowledged. Not a priority._


Batch Token Bridge Audit − Notes & Additional Information − 13


### **N-08 Missing Docstrings**

Consider adding docstrings to the <u><mark>`[BatchBridgeCodec](https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/BatchBridgeCodec.sol#L5-L35)`</mark></u> <u>library. When writing docstrings,</u>

consider following the <u>[Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html)</u> (NatSpec).


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_Acknowledged. Not a priority._


Batch Token Bridge Audit − Notes & Additional Information − 14


## **Conclusion**

The newly implemented batch bridge gateway offers users an interface to batch bridge ETH or

whitelisted ERC-20 tokens.


The codebase is well-written, straightforward to follow, and well-documented. Only one

medium-severity issue and some low-severity issues were discovered, while recommendations

have been made to improve the overall quality of the codebase.


The Scroll team was very responsive throughout the engagement and answered all our

questions. The test suite was easy to set up and had great branch coverage.


Batch Token Bridge Audit − Conclusion − 15


