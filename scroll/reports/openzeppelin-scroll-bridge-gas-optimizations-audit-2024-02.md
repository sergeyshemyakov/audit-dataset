### | security

# **Scroll - Bridge** **Gas** **Optimizations** **Audit**

#### **February 6, 2024**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  6


High Severity ______________________________________________________________________  7

H-01 ETH Deposits Can Get Stuck if They Are Not Successfully Bridged 7


Low Severity ______________________________________________________________________  8

L-01 Implementation Keeps Functionalities for Deprecated Variables 8

L-02 Solidity Version Is Not Fixed and Its Use Is Inconsistent 8


Notes & Additional Information ______________________________________________________  9

N-01 Different Frameworks Are Used Concurrently in the Protocol 9

N-02 Renaming Opportunities 10

N-03 Mismatch Between Interface and Implementation 10

N-04 Inconsistent Use of the __gap Variable 11

N-05 Code Style Inconsistencies 11

N-06 Potential Gas Improvements 12

N-07 Missing or Inconsistent Documentation 13

N-08 Deprecated Variables Are Still Being Assigned Values 13


Conclusion ______________________________________________________________________ 14


Scroll - Bridge Gas Optimizations Audit − Table of Contents − 2


## **Summary**

Type Layer 2


Timeline From 2024-01-08
To 2024-01-19


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



Total Issues 11 (4 resolved, 2 partially resolved)



Low Severity Issues 2 (1 resolved)



Notes & Additional
Information



8 (2 resolved, 2 partially resolved)



Scroll - Bridge Gas Optimizations Audit − Summary − 3


## **Scope**

We audited <u>[pull request #1011](https://github.com/scroll-tech/scroll/pull/1011)</u> from the <u>[scroll-tech/scroll](https://github.com/scroll-tech/scroll/)</u> repository at commit <u>[45e1305.](https://github.com/scroll-tech/scroll/commit/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949)</u>


In scope were the following files:

```
contracts/src
├── L1
│  ├── gateways
│  │  ├── L1CustomERC20Gateway.sol
│  │  ├── L1ERC1155Gateway.sol
│  │  ├── L1ERC721Gateway.sol
│  │  ├── L1ETHGateway.sol
│  │  ├── L1GatewayRouter.sol
│  │  ├── L1StandardERC20Gateway.sol
│  │  ├── L1WETHGateway.sol
│  │  └── usdc
│  │    └── L1USDCGateway.sol
│  ├── L1ScrollMessenger.sol
│  └── rollup
│    ├── IL1MessageQueue.sol
│    ├── IL1MessageQueueWithGasPriceOracle.sol
│    ├── IL2GasPriceOracle.sol
│    ├── IScrollChain.sol
│    ├── L1MessageQueue.sol
│    ├── L1MessageQueueWithGasPriceOracle.sol
│    ├── L2GasPriceOracle.sol
│    └── ScrollChain.sol
├── L2
│  ├── gateways
│  │  ├── L2CustomERC20Gateway.sol
│  │  ├── L2ERC1155Gateway.sol
│  │  ├── L2ERC721Gateway.sol
│  │  ├── L2ETHGateway.sol
│  │  ├── L2GatewayRouter.sol
│  │  ├── L2StandardERC20Gateway.sol
│  │  ├── L2WETHGateway.sol
│  │  └── usdc
│  │    └── L2USDCGateway.sol
│  └── L2ScrollMessenger.sol
├── libraries
│  ├── gateway
│  │  ├── IScrollGateway.sol
│  │  └── ScrollGatewayBase.sol
│  ├── IScrollMessenger.sol
│  └── ScrollMessengerBase.sol
└── misc
└──EmptyContract.sol

```

Scroll - Bridge Gas Optimizations Audit − Scope − 4


Dependencies, tests, scripts, and changes outside the pull request were left out of the scope.


Scroll - Bridge Gas Optimizations Audit − Scope − 5


## **System Overview**

Scroll is an EVM-equivalent ZK-rollup designed to be a scaling solution for Ethereum. It

achieves this by interpreting EVM bytecode directly at the bytecode level, following a path

similar to that taken by projects like Polygon's zkEVM and Consensys' Linea.


This audit reviewed the changes made to multiple Scroll contracts as part of <u>[pull request](https://github.com/scroll-tech/scroll/pull/1011)</u>

<u>[#1011. These changes had the single purpose of reducing the gas cost of the operation. The](https://github.com/scroll-tech/scroll/pull/1011)</u>

most notable changes consist of:


   - Adapting parameters stored in variables as immutable values and assigning those values

during the deployment

   - Moving validations from the initialization stage to the implementation deployment stage

   - Creation of a new contract that inherits from the <mark>`MessageQueue`</mark> contract and adds

functionalities from the <mark>`L2GasPriceOracle`</mark> contract to reduce the dependency on

external calls

   - Simplified message gas limit calculation by setting a single multiplying factor

   - Initial deprecation of the ETH gateways in favor of connecting the routers to the

messengers directly

   - Moving forward with the usage of custom errors instead of <mark>`require`</mark> statements


This report presents our findings and recommendations regarding the additions made to the

Scroll ZK-rollup protocol. We urge the Scroll team to consider these findings in their ongoing

efforts to provide a secure and efficient Layer 2 solution for Ethereum.


Scroll - Bridge Gas Optimizations Audit − System Overview − 6


## **High Severity**

### **H-01 ETH Deposits Can Get Stuck if They Are Not** **Successfully Bridged**

<u>[Pull request #1011](https://github.com/scroll-tech/scroll/pull/1011)</u> introduced the change of <u>[redirecting the calls](https://github.com/scroll-tech/scroll/pull/1011/files#diff-ef2695307fe7f3dfd610ae22338941d20233e19db326322cfca61ad4ceeda1c7)</u> to deposit ETH from the

<mark>`L1GatewayRouter`</mark> contract to the <mark>`L1ScrollMessenger`</mark> contract without going through

the <mark>`L1ETHGateway`</mark> contract. This was done with the intention of reducing the gas cost

associated with such an action.


However, this causes a problem. Namely, in situations in which a message could not be

correctly sent through the bridge, the <u>[dropping and asset-return mechanism](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/L1ScrollMessenger.sol#L262-L311)</u> implemented in

the <mark>`L1ScrollMessenger`</mark> contract will get stuck and the assets will not be able to be paid

back. This is due to the lack of the <u><mark>`[onDropMessage](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/L1ScrollMessenger.sol#L308)`</mark></u> <u>hook</u> implementation in the

<u><mark>`[L1GatewayRouter](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1GatewayRouter.sol)`</mark></u> <u>contract, which serves as a handler to repay the respective origin of the</u>

message.


For instance, if a user wants to simply deposit ETH, in both versions they should call the

<u><mark>`[depositETH](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1GatewayRouter.sol#L206)`</mark></u> <u>function</u> from the <mark>`L1GatewayRouter`</mark> contract. The difference lies in <u>[who calls](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/L1ScrollMessenger.sol#L340)</u>

and passes the message to the <mark>`L1ScrollMessenger`</mark> contract. In the former

implementation, the <u>[message would come from](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1ETHGateway.sol#L148)</u> the <mark>`L1ETHGateway`</mark> contract, whereas in the

current implementation, the <mark>`L1GatewayRouter`</mark> will be the <u>[caller. This is relevant as the](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1GatewayRouter.sol#L226)</u>

<mark>`_msgSender`</mark> call will then be part of the <u><mark>`[_xDomainCalldata](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/L1ScrollMessenger.sol#L340)`</mark></u> data that will be used to keep

track of the message (with its hash) but will also be used in case the message needs <u>[to be](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/L1ScrollMessenger.sol#L308)</u>

<u>[dropped.](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/L1ScrollMessenger.sol#L308)</u>


In such a dropping scenario, as the address that sent the message to the

<mark>`L1ScrollMessenger`</mark> contract is the one that will be called to execute the <mark>`onDropMessage`</mark>

hook, if such hook is not implemented, the dropping mechanism will fail and the original user

will not get their ETH back. This is the same as how it used to happen when routing the call

through the <mark>`L1ETHGateway`</mark> contract. As this does not depend on the data added to the

<mark>`depositETH`</mark> call, those funds will get stuck in case they are not bridged successfully.


To showcase this, one can get inspired by the following <u>[gist; however, caution should be made](https://gist.github.com/andresbach/5dcd4fff562dc6c72ac713e46136bd27)</u>

when fixing this issue, since the gist's proposed scenario in which the issue resolves is merely

an example and it is not meant to represent a fully valid resolution.


Scroll - Bridge Gas Optimizations Audit − High Severity − 7


Consider implementing the <mark>`onDropMessage`</mark> hook in the <mark>`L1GatewayRouter`</mark> contract to

handle the back payment when dropping messages.


**_Update:_** _Resolved in_ _<u>[pull request #1093](https://github.com/scroll-tech/scroll/pull/1093)</u>_ _at commit_ _<u><mark>`[888c3d2](https://github.com/scroll-tech/scroll/pull/1093/commits/888c3d26b34f217877628b1208ea3473d9836600)`</mark></u>_ _<mark>.</mark>_ _The respective contracts have_

_been rolled back to a previous state in which the bypass previously done over the respective_

_ETH gateways is no longer there, and in which the gateway routers have to go through the ETH_

_gateways when depositing/withdrawing ETH._

## **Low Severity**

### **L-01 Implementation Keeps Functionalities for** **Deprecated Variables**


At line <u>[82](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1GatewayRouter.sol#L82)</u> of <mark>`L1GatewayRouter.sol`</mark>, it is explained that the <mark>`ethGateway`</mark> parameter is no

longer in use. However, the logic that makes use of/changes this variable, such as the <u>[check](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1GatewayRouter.sol#L96)</u> in

the initialize function and the <u><mark>`[setETHGateway](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1GatewayRouter.sol#L244)`</mark></u> function, is maintained.


If a variable is no longer in use, consider removing the logic that uses it.


**_Update:_** _Resolved in_ _<u>[pull request #1094](https://github.com/scroll-tech/scroll/pull/1094)</u>_ _at commit_ _<u><mark>`[223538d](https://github.com/scroll-tech/scroll/pull/1094/commits/223538de478e26415fe57682254cdfb9469a5d79)`</mark></u>_ _<mark>.</mark>_

### **L-02 Solidity Version Is Not Fixed and Its Use Is** **Inconsistent**


In the codebase, there are <u>[some](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/libraries/gateway/ScrollGatewayBase.sol#L3)</u> contracts whose pragma statement does not use a fixed

version, whereas <u>[others](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L2/gateways/L2ERC1155Gateway.sol#L3)</u> are correctly using a fixed one.


Consider reviewing all the contracts and always using the same fixed Solidity pragma version

in all of them. This will help improve consistency and avoid compiling contracts with

unexpected compiler versions.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_We prefer to leave base contracts and interfaces using_ _<mark>`^0.8.0`</mark>_ _such that the third_

_party can inherit it more easily._


Scroll - Bridge Gas Optimizations Audit − Low Severity − 8


## **Notes & Additional** **Information**

### **N-01 Different Frameworks Are Used** **Concurrently in the Protocol**

When it comes to checking the correct execution of unit tests, coverage, and scripts, the

project offers integrations with both Hardhat and Foundry. However, we identified some issues

that are worth analyzing:


   - The coverage does not work if run through Hardhat. This is because the instrumentation

step fails with the following error:

```
Error in plugin solidity-coverage: Error: Could not instrument: L2/
predeploys/L1BlockContainer.sol. (Please verify solc can compile this
file without errors.) extraneous input ',' expecting {'from', '{',
'}', '(', 'error', 'for', 'function', 'address', 'calldata', 'if',
'assembly', 'return', 'revert', 'byte', 'let', '=:', 'switch',
'callback', DecimalNumber, HexNumber, HexLiteralFragment, 'break',
'continue', 'leave', 'payable', 'constructor', 'receive', Identifier,
StringLiteralFragment} (251:23)

```

   - Even though the coverage with Foundry executes well, it shows an empty coverage for

all the contracts inside the <mark>`src/libraries/verifier`</mark> sub-directory.


   - There is no script defined in the <mark>`package.json`</mark> to run the Foundry coverage. Consider

adding one as done for the tests and for Hardhat's coverage.


Scripts exist for both Foundry and Hardhat, but it seems that those used in the latter are

outdated and deprecated. This is error-prone and a concern since production environment

variables can be used in the wrong scripts and thereby run unneeded/erroneous transactions.

As such, consider whether is worth maintaining both frameworks, unifying the testing and

coverage. In addition, consider having a unique way of running production scripts to avoid

unexpected executions.


**_Update:_** _Acknowledged, will resolve. In_ _<u>[pull request #1095](https://github.com/scroll-tech/scroll/pull/1095)</u>_ _at commit_ _<u><mark>`[26fa7a1](https://github.com/scroll-tech/scroll/commit/26fa7a1ca2f050990cc1de968d39ff31b420829e)`</mark></u>_ _a specific_

_script has been defined to run coverage with Foundry. Verifiers contracts are being skipped by_

_the coverage in the_ _<mark>`.solcover.js`</mark>_ _file. The Scroll team stated:_


Scroll - Bridge Gas Optimizations Audit − Notes & Additional Information − 9


_We also noted this issue. That's why we added it to_ _<mark>`skipFiles`</mark>_ _in_ _<mark>`.solcover.js`</mark>_ _._

### **N-02 Renaming Opportunities**


The <u>[INTRINSIC_GAS_NONZERO_BYTE factor](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/rollup/L1MessageQueueWithGasPriceOracle.sol#L21)</u> that multiplies the length of the message-to-be
sent in order to calculate the amount of gas needed for the L2 execution, has a name that

originates from a previous version that differentiated between zero and non-zero bytes.

However, now, there is no such distinction and its name suggests that the whole message

does not have a zero byte.


Consider changing its name to something more appropriate that does not refer to old code's

behavior.


**_Update:_** _Resolved in_ _<u>[pull request #1096](https://github.com/scroll-tech/scroll/pull/1096)</u>_ _at commit_ _<u><mark>`[71d8c78](https://github.com/scroll-tech/scroll/commit/71d8c78384dc769b19cd9631c212ae18d63c94a6)`</mark></u>_ _<mark>.</mark>_

### **N-03 Mismatch Between Interface and** **Implementation**


Throughout the codebase, there are some instances in which the interface differs from the

actual implementation:


  - The parameter <mark>`_calldata`</mark> from the

<mark>`L1MessageQueue.calculateIntrinsicGasFee`</mark> function is defined as <u><mark>`[memory](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/rollup/IL1MessageQueue.sol#L74)`</mark></u> in

the interface but as <u><mark>`[calldata](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/rollup/L1MessageQueue.sol#L151)`</mark></u> in the implementation.

   - The <u><mark>`[L2GasPriceOracle.intrinsicParams](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/rollup/L2GasPriceOracle.sol#L57)`</mark></u> getter from the implementation is not

reflected in the <u>[interface.](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/rollup/IL2GasPriceOracle.sol)</u>

   - The <u><mark>`[IL1MessageQueueWithGasPriceOracle](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/rollup/IL1MessageQueueWithGasPriceOracle.sol)`</mark></u> interface does not reflect the

existence of the <u><mark>`[l2BaseFee](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/rollup/L1MessageQueueWithGasPriceOracle.sol#L28)`</mark></u> and <u><mark>`[whitelistChecker](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/rollup/L1MessageQueueWithGasPriceOracle.sol#L31)`</mark></u> getters from the

implementation.

   - The <u><mark>`[gasOracle](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/rollup/L1MessageQueue.sol#L50)`</mark></u> public variable of the <mark>`L1MessageQueue`</mark> contract is not defined in the

corresponding <u>[interface. The same happens for all the immutable and public variables](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/rollup/IL1MessageQueue.sol)</u>

except for <u><mark>`[pendingQueueIndex](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/rollup/L1MessageQueue.sol#L56)`</mark></u> which has a specific <u>[getter](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/rollup/IL1MessageQueue.sol#L58)</u> defined in the interface.

  - The parameter <mark>`_calldata`</mark> from the <mark>`IL1GatewayRouter.setERC20Gateway`</mark>

function is defined as <mark>`memory`</mark> in the interface but as <mark>`calldata`</mark> in the implementation.


Consider reviewing the entire codebase and making all the interfaces consistent with their

implementations.


Scroll - Bridge Gas Optimizations Audit − Notes & Additional Information −

10


**_Update:_** _Partially resolved in_ _<u>[pull request #1097](https://github.com/scroll-tech/scroll/pull/1097)</u>_ _at commit_ _<u><mark>`[747f354](https://github.com/scroll-tech/scroll/commit/747f35433cc5a92fb81999d395f3d14dec071854)`</mark></u>_ _. Only the_ _<mark>`memory`</mark>_ _input_

_in the_ _<mark>`IL1MessageQueue`</mark>_ _interface and the inconsistency between the_

_<mark>`IL1MessageQueueWithGasPriceOracle`</mark>_ _interface and its implementation has been_

_resolved. However, in the latter ones, the variables have been marked as_ _<mark>`override`</mark>_ _. The Scroll_

_team stated:_


_Two are fixed. The others are intended to not be public in the interface or will be fixed at_

_a later time._

### **N-04 Inconsistent Use of the __gap Variable**


Throughout the codebase, there are contracts that <u>[make use](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/rollup/L1MessageQueue.sol#L68)</u> of the <mark>`__gap`</mark> variable whereas

<u>[others](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1ERC1155Gateway.sol)</u> do not. As the majority of the contracts are upgradeable, consider consistently defining

a <mark>`__gap`</mark> variable for each one of such upgradeable contracts, with the corresponding size

being according to the defined storage slots. Furthermore, consider adding comments

mentioning the slots that were already used to keep track of the deprecated slots when

upgrading the contracts.


Moreover, the <mark>`L2ScrollMessenger`</mark> contract uses a variable called <u><mark>`[__used](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L2/L2ScrollMessenger.sol#L45)`</mark></u> to reflect the

slots that were used prior to changing them into immutable parameters or into parameters are

no longer in use. However, the rest of the codebase has adopted the approach of replacing

those slots with <u>[deprecated private variables.](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/L1ScrollMessenger.sol#L65-L68)</u>


In order to be consistent and prevent possible mistakes when upgrading future versions of the

contract, consider keeping the same style of deprecating previously used slots while also

addressing the lack of the <mark>`__gap`</mark> variable in most of the contracts.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_We are comfortable with the current implementation, no change is needed._

### **N-05 Code Style Inconsistencies**


Throughout the codebase, there are places at which the code style adopted is not consistent

across all the contracts:


   - In some instances, the <u><mark>`[onlyInitializing](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/libraries/ScrollMessengerBase.sol#L79)`</mark></u> modifier is used, but in others it is <u>[not.](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/libraries/gateway/ScrollGatewayBase.sol#L101)</u>

   - A few events are <u>[defnedi](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/IL1ERC20Gateway.sol#L17)</u> in the interface, whereas in <u>[other cases](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1ERC1155Gateway.sol#L31)</u> they are defined in the

implementation contract.


Scroll - Bridge Gas Optimizations Audit − Notes & Additional Information −

11


   - The <u><mark>`[L2GasPriceOracle.IntrinsicParams](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/rollup/L2GasPriceOracle.sol#L45)`</mark></u> struct should be defined in the interface

instead of in the implementation to be consistent with the rest of the codebase.

   - The <u><mark>`[ErrorZeroAddress](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1GatewayRouter.sol#L27)`</mark></u> error defined in <mark>`L1GatewayRouter`</mark> should be defined in the

<u><mark>`[IL1GatewayRouter](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/IL1GatewayRouter.sol)`</mark></u> <u>interface</u> as well to be consistent with the other implementations

like the <u><mark>`[IScrollChain](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/rollup/IScrollChain.sol#L32)`</mark></u> interface. The same applies to the <u><mark>`[L2GatewayRouter](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L2/gateways/L2GatewayRouter.sol)`</mark></u>

contract.


Consider fixing such inconsistencies to improve the overall readability and clarity of the

codebase.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_We are comfortable with the current implementation, no change is needed._

### **N-06 Potential Gas Improvements**


Throughout the codebase, there are some instances in which the code can be refactored to be

more gas-efficient:


   - Many getters are duplicated due to there being <u><mark>`[public](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1CustomERC20Gateway.sol#L38)`</mark></u> <u>[variable declarations](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1CustomERC20Gateway.sol#L38)</u> along with

<u>[specific getter definitions](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1CustomERC20Gateway.sol#L78)</u> as well. Consider using only one of the two and checking the

code for other such instances.

  - Some functions <u>[might be defined](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/L1ScrollMessenger.sol#L121)</u> as <mark>`external`</mark> instead of <mark>`public`</mark> <mark>.</mark> Consider reviewing

the entire codebase for other similar occurrences like the one in the <u><mark>`[L2ETHGateway](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L2/gateways/L2ETHGateway.sol#L65)`</mark></u>

contract.

   - The use of <mark>`require`</mark> statements instead of custom errors <u>[has been proven](https://medium.com/coinmonks/how-custom-errors-in-solidity-save-gas-3c499aa22745)</u> to consume

more gas. Even though there are attempts at porting the existing <mark>`require`</mark> statements

to custom errors, several cases still remain that have not been so ported. Consider

porting these across the entire codebase.


Consider whether it is worth refactoring the code to accommodate such changes so that less

gas is consumed.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_We are comfortable with the current implementation, no change is needed._


Scroll - Bridge Gas Optimizations Audit − Notes & Additional Information −

12


### **N-07 Missing or Inconsistent Documentation**

Throughout the codebase, there are inconsistencies in the documentation. Particularly when

checking the NatSpec docstrings from the other analogous set of contracts:


   - At lines <u>[47](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1ERC721Gateway.sol#L47)</u> and <u>[57](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1ERC721Gateway.sol#L57)</u> of the <mark>`L1ERC721Gateway`</mark> contract, "in L1" is missing at the end.

The same happens at lines <u>[47](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1ERC1155Gateway.sol#L47)</u> and <u>[54](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1ERC1155Gateway.sol#L54)</u> of the <mark>`L1ERC1155Gateway`</mark> contract, at lines <u>[47,](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1CustomERC20Gateway.sol#L47)</u>

<u>[48, 63](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1CustomERC20Gateway.sol#L48)</u> and <u>[64](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1CustomERC20Gateway.sol#L64)</u> of the <mark>`L1CustomERC20Gateway`</mark> contract, and at lines <u>[57, 58, 81](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/usdc/L1USDCGateway.sol#L57)</u> and <u>[82](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/usdc/L1USDCGateway.sol#L82)</u>

of the <mark>`L1USDCGateway`</mark> contract.

   - The <u><mark>`[L1WETHGateway](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1WETHGateway.sol)`</mark></u> contract misses the same statement present in the

<u><mark>`[L2WETHGateway](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L2/gateways/L2WETHGateway.sol#L65)`</mark></u> contract about parameters not being used.

   - The <mark>`L2ETHGateway`</mark> contract is missing documentation in the <u><mark>`[_withdraw](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L2/gateways/L2ETHGateway.sol#L101)`</mark></u> function

analogous to the one in <u><mark>`[L1ETHGateway._deposit](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1ETHGateway.sol#L126)`</mark></u> but with the respective

parameters.

   - The <mark>`L2GatewayRouter`</mark> is missing the "@dev This variable is no longer used" comment

in the <u><mark>`[ethGateway](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L2/gateways/L2GatewayRouter.sol#L37)`</mark></u> variable definition.

   - In the <mark>`IL2GasPriceOracle`</mark> interface, the <u>[two added getter functions](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/rollup/IL2GasPriceOracle.sol#L7-L9)</u> do not have any

documentation besides a single "@notice" comment.


Consider fixing the reported examples to improve the overall readability of the codebase.


**_Update:_** _Partially resolved in_ _<u>[pull request #1098](https://github.com/scroll-tech/scroll/pull/1098)</u>_ _at commit_ _<u><mark>`[a8addd8](https://github.com/scroll-tech/scroll/commit/a8addd896717b663bc8053744f794f721ed87cdd)`</mark></u>_ _. The comment on the_

_<mark>`L2GatewayRouter`</mark>_ _contract has not been added to the variable definition._

### **N-08 Deprecated Variables Are Still Being** **Assigned Values**


In the <mark>`L1StandardERC20Gateway`</mark> contract, the <u><mark>`[__l2TokenImplementation](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1StandardERC20Gateway.sol#L95-L96)`</mark></u> <u>and the</u>

<u><mark>`[__l2TokenFactory](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1StandardERC20Gateway.sol#L95-L96)`</mark></u> variables have been deprecated as <u>[suggested](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1StandardERC20Gateway.sol#L36)</u> by the docstrings.

However, they are still being assigned values. This not only consumes more gas but is also

inconsistent with other places across the codebase, such as the <u><mark>`[ScrollGatewayBase](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/libraries/gateway/ScrollGatewayBase.sol#L84-L86)`</mark></u>

contract where variables are being directly omitted. The same happens in the

<u><mark>`[L2StandardERC20Gateway](https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L2/gateways/L2StandardERC20Gateway.sol#L80)`</mark></u> contract with the <mark>`__tokenFactory`</mark> variable.


Consider removing such assignments to save gas. In addition, consider improving the

consistency of the codebase by not assigning values to deprecated variables.


**_Update:_** _Resolved in_ _<u>[pull request #1099](https://github.com/scroll-tech/scroll/pull/1099)</u>_ _at commit_ _<u><mark>`[fbb7862](https://github.com/scroll-tech/scroll/commit/fbb786210ea23bb1a11ceefcefa26c15c14992fa)`</mark></u>_ _<mark>.</mark>_


Scroll - Bridge Gas Optimizations Audit − Notes & Additional Information −

13


## **Conclusion**

Systematic changes have been made across the codebase to reduce the gas consumption of

the protocol. The audit yielded one high-severity issue while recommendations to improve the

overall quality and health of the codebase have also been made.


The codebase is well-written and has proper documentation. However, it could benefit from a

more descriptive reasoning about some of the decisions taken to reduce the gas costs.

Furthermore, there are opportunities to improve the deployment and initialization scripts, and

to increase the test coverage.


The Scroll team was very responsive throughout the audit period and provided us with

information regarding the various aspects of the changes introduced.


Scroll - Bridge Gas Optimizations Audit − Conclusion − 14


