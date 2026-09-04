### | security

# **Scroll USDC** **Gateway Audit**

#### **September 13, 2023**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  5


Trust Assumptions _________________________________________________________________  5


Privileged Roles ___________________________________________________________________  5


Medium Severity ___________________________________________________________________  8

M-01 L2USDCGateway Is Missing Rate Limiter Functionality 8


Low Severity ______________________________________________________________________  8

L-01 Misleading Comment 8

L-02 Lack of gap Variable 8

L-03 Missing Docstrings 9


Notes & Additional Information ______________________________________________________  9

N-01 Unused Imports 9


Conclusion  ______________________________________________________________________ 11


Scroll USDC Gateway Audit − Table of Contents − 2


## **Summary**

Type zkEVM-based ZK-rollup, Bridge &
Rollup


Timeline From 2023-08-25
To 2023-08-30


Languages Solidity



Critical Severity
Issues


High Severity
Issues


Medium Severity
Issues



0 (0 resolved)


0 (0 resolved)


1 (1 resolved)



Total Issues 5 (4 resolved, 1 partially resolved)



Low Severity Issues 3 (3 resolved)



Notes & Additional
Information


Client Reported
Issues



1 (0 resolved, 1 partially resolved)


0 (0 resolved)



Scroll USDC Gateway Audit − Summary − 3


## **Scope**

We audited the USDC Gateway changes from the <u>[scroll-tech/scroll](https://github.com/scroll-tech/)</u> repository at commit

<u>[f6894bb.](https://github.com/scroll-tech/scroll/commit/f6894bb82f78228b349267ed814375cae2fc1483)</u>

```
contracts
└── src
├── L1
│  ├── gateways
│  │  ├── L1ERC20Gateway.sol
│  │  └── usdc
│  │    └── L1USDCGateway.sol
├── L2
│  ├── gateways
│  │  └── usdc
│  │    └── L2USDCGateway.sol
├── interfaces
│  ├── L2USDCGateway.sol
│  ├── ITokenMessenger.sol
│  ├── IMessangerTransmitter.sol
│  ├── IUSDCBurnableSourceBrdge.sol
│  ├── IUSDCDestinationBridge.sol
└─── libraries
└── gateway
└── CCTPGatewayBase.sol

```

Scroll USDC Gateway Audit − Scope − 4


## **System Overview**

Scroll is an EVM-equivalent ZK-rollup designed to be a scaling solution for Ethereum. It

achieves this by interpreting EVM bytecode directly at the bytecode level, following a similar

path to projects like Polygon's zkEVM and Consensys' Linea.


This audit reviewed the extension of the special USDC Gateway from the scroll protocol.


This report presents our findings and recommendations for the new additions to the Scroll ZK
rollup protocol. We urge the Scroll team to consider these findings in their ongoing efforts to

provide a secure and efficient Layer 2 solution for Ethereum.

## **Trust Assumptions**


It is assumed that the `USDC` contract to be deployed in the Scroll Layer 2 Network will be

identical to the one deployed in the Ethereum Mainnet.

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


Scroll USDC Gateway Audit − System Overview − 5


mechanism over the timing of function execution based on their respective impact

levels.

- `TokenRateLimiter` : The default admin role can update the total token amount



limit. The admin can also grant a token spender role for the Scroll gateways and

messengers to ensure a rate limit when depositing or withdrawing funds.


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


- USDC: The following roles are present in the `USDC` contract:




- `owner` : This role can transfer ownership of the contract and grant or remove the

`masterMinter`, `pauser` and `blacklister` roles.


- `masterMinter` : This role can create new minters and assign allowances to

existing minters.




- `pauser` : This role has the ability to pause and unpause the contract.


- `blacklister` : This role can add or remove addresses from a blacklist, which if

added would prevent that address from transferring or receiving `USDC` .


Scroll USDC Gateway Audit − Privileged Roles − 6


`minter` : This role allows the minting of tokens up to each minter's allowance.



Each of these roles presents a unique set of permissions within the Scroll protocol. The

potential implications of these permissions warrant further consideration and mitigation to

ensure the system’s security and robustness.


Scroll USDC Gateway Audit − Privileged Roles − 7


## **Medium Severity**

### **M-01 L2USDCGateway Is Missing Rate Limiter** **Functionality**

The <u>`[L1USDCGateway](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L1/gateways/usdc/L1USDCGateway.sol)`</u> <u>contract</u> inherits from <u>`[L1ERC20Gateway](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L1/gateways/L1ERC20Gateway.sol)`</u> . When a user initiates a

deposit, the `_transferERC20In` function is called, which in turn invokes the rate limiter

function <u>`[_addUsedAmount](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L1/gateways/L1ERC20Gateway.sol#L163)`</u> . However, the <u>`[L2USDCGateway](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L2/gateways/usdc/L2USDCGateway.sol)`</u> <u>contract</u> inherits from

<u>`[L2ERC20Gateway](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L2/gateways/L2ERC20Gateway.sol)`</u> which does not call the rate limiter `_addUsedAmount` function. This

means that USDC withdrawals will not be subject to rate limiting.


Consider ensuring that `_addUsedAmount` is called when users make a withdrawal in USDC.


**_Update:_** _Resolved in_ _<u>[pull request #927](https://github.com/scroll-tech/scroll/pull/927)</u>_ _at commit_ _<u>[be6d404.](https://github.com/scroll-tech/scroll/pull/927/commits/be6d4041e62817b72fffa555d83c9c0d271b291a)</u>_

## **Low Severity**

### **L-01 Misleading Comment**


The <u>[comment in line 172](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L2/gateways/usdc/L2USDCGateway.sol#L172)</u> of the `L2USDCGateway` contract should say `L2ScrollMessenger`

instead of `L1ScrollMessenger` .


Consider resolving this instance of incorrect documentation to improve the clarity and

readability of the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #928](https://github.com/scroll-tech/scroll/pull/928)</u>_ _at commit_ _<u>[733d2a6.](https://github.com/scroll-tech/scroll/pull/928/commits/733d2a62d44a0037b2972d6825e6802fc6ac76f5)</u>_

### **L-02 Lack of gap Variable**


The <u>`[CCTPGatewayBase](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/libraries/gateway/CCTPGatewayBase.sol#L9)`</u> <u>contract</u> does not contain a gap variable although it is upgradeable.


Consider adding a gap variable following <u>[OpenZeppelin's upgradeable contracts guide](https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps)</u> to

avoid future storage collisions.


Scroll USDC Gateway Audit − Medium Severity − 8


**_Update:_** _Resolved in_ _<u>[pull request #929](https://github.com/scroll-tech/scroll/pull/929)</u>_ _at commit_ _<u>[5e61a05.](https://github.com/scroll-tech/scroll/pull/929/commits/5e61a05f5f543598f3b99ce484bba243ae664e2e)</u>_

### **L-03 Missing Docstrings**


Throughout the <u>[codebase](https://github.com/scroll-tech/scroll/tree/f6894bb82f78228b349267ed814375cae2fc1483/contracts/)</u> there are several parts that do not have docstrings. For instance:


   - <u>[Line 17](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L1/gateways/L1ERC20Gateway.sol#L16-L17)</u> in <u>`[L1ERC20Gateway.sol](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L1/gateways/L1ERC20Gateway.sol)`</u>

   - <u>[Line 64](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L2/gateways/usdc/L2USDCGateway.sol#L59-L64)</u> in <u>`[L2USDCGateway.sol](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L2/gateways/usdc/L2USDCGateway.sol)`</u>

   - <u>[Line 5](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/interfaces/IMessageTransmitter.sol#L4-L5)</u> in <u>`[IMessageTransmitter.sol](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/interfaces/IMessageTransmitter.sol)`</u>

   - <u>[Line 6](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/interfaces/IMessageTransmitter.sol#L6)</u> in <u>`[IMessageTransmitter.sol](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/interfaces/IMessageTransmitter.sol)`</u>

   - <u>[Line 5](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/interfaces/ITokenMessenger.sol#L4-L5)</u> in <u>`[ITokenMessenger.sol](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/interfaces/ITokenMessenger.sol)`</u>

   - <u>[Line 6](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/interfaces/IUSDCBurnableSourceBridge.sol#L4-L6)</u> in <u>`[IUSDCBurnableSourceBridge.sol](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/interfaces/IUSDCBurnableSourceBridge.sol)`</u>

   - <u>[Line 6](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/interfaces/IUSDCDestinationBridge.sol#L4-L6)</u> in <u>`[IUSDCDestinationBridge.sol](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/interfaces/IUSDCDestinationBridge.sol)`</u>

   - <u>[Line 9](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/libraries/gateway/CCTPGatewayBase.sol#L8-L9)</u> in <u>`[CCTPGatewayBase.sol](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/libraries/gateway/CCTPGatewayBase.sol)`</u>


Consider thoroughly documenting all functions (and their parameters) that are part of any

contract's public API. Functions implementing sensitive functionality, even if not public, should

be clearly documented. When writing docstrings, consider following the <u>[Ethereum Natural](https://solidity.readthedocs.io/en/develop/natspec-format.html)</u>

<u>[Specification Format](https://solidity.readthedocs.io/en/develop/natspec-format.html)</u> (NatSpec).


**_Update:_** _Resolved in_ _<u>[pull request #940](https://github.com/scroll-tech/scroll/pull/940)</u>_ _at commit_ _<u>[30fa5e6.](https://github.com/scroll-tech/scroll/pull/940/commits/30fa5e65ef577acbde630baa982e1752b2095a60)</u>_

## **Notes & Additional** **Information**

### **N-01 Unused Imports**


Throughout the <u>[codebase](https://github.com/scroll-tech/scroll/tree/f6894bb82f78228b349267ed814375cae2fc1483/contracts/)</u> there are imports that are unused and could be removed. For

instance:


   - Import <u>`[IScrollMessenger](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L1/gateways/L1ERC20Gateway.sol#L12)`</u> of <u>`[L1ERC20Gateway.sol](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L1/gateways/L1ERC20Gateway.sol)`</u>

   - Import <u>`[ScrollConstants](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L1/gateways/L1ERC20Gateway.sol#L13)`</u> of <u>`[L1ERC20Gateway.sol](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L1/gateways/L1ERC20Gateway.sol)`</u>

   - Import <u>`[OwnableUpgradeable](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L1/gateways/usdc/L1USDCGateway.sol#L5)`</u> of <u>`[L1USDCGateway.sol](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L1/gateways/usdc/L1USDCGateway.sol)`</u>

   - Import <u>`[IERC20Upgradeable](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L1/gateways/usdc/L1USDCGateway.sol#L6)`</u> of <u>`[L1USDCGateway.sol](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L1/gateways/usdc/L1USDCGateway.sol)`</u>

   - Import <u>`[IL1ERC20Gateway](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L1/gateways/usdc/L1USDCGateway.sol#L12)`</u> of <u>`[L1USDCGateway.sol](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L1/gateways/usdc/L1USDCGateway.sol)`</u>

   - Import <u>`[IL2ERC20Gateway](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L2/gateways/usdc/L2USDCGateway.sol#L13)`</u> of <u>`[L2USDCGateway.sol](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L2/gateways/usdc/L2USDCGateway.sol)`</u>


Scroll USDC Gateway Audit − Notes & Additional Information − 9


   - Import <u>`[IScrollGateway](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L2/gateways/usdc/L2USDCGateway.sol#L15)`</u> of <u>`[L2USDCGateway.sol](https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L2/gateways/usdc/L2USDCGateway.sol)`</u>


Consider removing unused imports to improve the overall clarity and readability of the

codebase.


**_Update:_** _Partially resolved in_ _<u>[pull request #930](https://github.com/scroll-tech/scroll/pull/930)</u>_ _at commit_ _<u>[23bf84a.](https://github.com/scroll-tech/scroll/pull/930/commits/23bf84a634065df5c4db7f90e2d8b4a07160a604)</u>_ _`L1USDCGateway.sol`_ _still_

_imports_ _`IL1ERC20Gateway`_ _and_ _`L2USDCGateway.sol`_ _still imports_ _`IL2ERC20Gateway`_ _._


Scroll USDC Gateway Audit − Notes & Additional Information − 10


## **Conclusion**

Throughout this 4-day audit, we reviewed both L1 and L2 USDC gateways. We identified a

single medium-severity issue, as well as a few low-severity issues and additional notes.

Overall, we commend the quality and thoughtful integration of the USDC gateway. The auditing

process was seamless, and we appreciate the Scroll team's prompt responses to our inquiries

throughout the process.


Scroll USDC Gateway Audit − Conclusion − 11


