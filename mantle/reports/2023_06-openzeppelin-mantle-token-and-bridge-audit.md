### | security

# **Mantle Token** **and Bridge** **Audit**

#### **June 30, 2023**

This security assessment was prepared by
OpenZeppelin.


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  5


Security Model and Trust Assumptions _______________________________________________  5

Privileged Roles 6


Low Severity ______________________________________________________________________  7

L-01 Misleading Comments 7

L-02 Bridge Can Be Reinitialized 7

L-03 Disable Implementation Contract 7


Notes & Additional Information ______________________________________________________  8

N-01 Typographical Errors 8

N-02 ETH Handling Can Be Simplified 8

N-03 Gas Savings 8

N-04 Imprecise Docstrings 9

N-05 Redundant Cast 9

N-06 Unnecessary Multiple Inheritance 10

N-07 BIT Token Address Is Used Instead of MNT Token Address 10

N-08 Unused Function 10

N-09 Unusable Data Parameter 11

N-10 Unnecessary Specialization 11

N-11 Redundant Validation 11

N-12 Incorrect Encapsulation 11

N-13 Use of Hardcoded Values 12


Conclusions  _____________________________________________________________________ 13


Monitoring Recommendations _____________________________________________________ 14


Mantle Token and Bridge Audit − Table of Contents − 2


## **Summary**

Type Token


Timeline From 2023-06-06
To 2023-06-13


Languages Solidity



Critical Severity
Issues


High Severity
Issues


Medium Severity
Issues



0 (0 resolved)


0 (0 resolved)


0 (0 resolved)



Total Issues 16 (10 resolved)



Low Severity Issues 3 (2 resolved)



Notes & Additional
Information


Client Reported
Issues



13 (8 resolved)


0 (0 resolved)



Mantle Token and Bridge Audit − Summary − 3


## **Scope**

We audited the <u>[mantle-token-contracts](https://github.com/mantlenetworkio/mantle-token-contracts)</u> repository at the

`b2016dfb932d85b8b33a9294e8280aa04ca46975` commit and the <u>[mantle](https://github.com/mantlenetworkio/mantle)</u> repository at

the `d627d242fe19f50f344f1ff4b27532d1757303a6` commit.


In scope were the following contracts:

```
contracts
├── L1
│  └── L1MantleToken.sol
└── Migration
└── MantleTokenMigrator.sol

packages
└── contracts
└── contracts
├── L1
│  └── messaging
│    └── L1StandardBridge.sol
└── L2
└── messaging
└── L2StandardBridge.sol

```

When reviewing the bridge contracts, we assumed the cross-domain messengers work as

documented.


Mantle Token and Bridge Audit − Scope − 4


## **System Overview**

The Mantle token (MNT) is the gas token of the Mantle network. On the Ethereum network, it is

an upgradeable ERC-20 token with mint, burn, permit, and vote extensions. In the default

configuration, it allows minting to occur at most once a year and has a configurable mint cap

that limits how many tokens can be minted at once, though both parameters can be changed

by the owner.


The migrator contract facilitates migration from BIT to MNT by holding MNT tokens and

exchanging them for BIT at a specified ratio. It also has the functionality to recover mistakenly

sent tokens as well as send BIT and MNT tokens from the contract to a treasury address.


The bridge is a fork of the Optimism bridge contracts, extended to handle the Mantle token. It

allows anyone to lock ETH or arbitrary ERC-20 tokens on the Ethereum mainnet in exchange

for corresponding ERC-20 tokens on the Mantle network, which can later be destroyed to

recover the original tokens. It is worth noting that the bridge itself does not guarantee any

properties of the layer 2 tokens, or any correspondence with their layer 1 (L1) counterparts. For

instance, any non-standard features of the original token such as rebasing, blacklists or pause

functionality will not be replicated on the layer 2 (L2) contract unless it is specifically designed

that way.

## **Security Model and Trust** **Assumptions**


The Mantle token is upgradeable, meaning that the mint cooldown and other constants can be

changed as well as the behavior of the token.


The bridge attempts to identify valid token exchanges, but with the exception of ETH and MNT,

it trusts the L2 tokens to be able to identify the corresponding L1 token address. Therefore, the

onus is on users to validate that they only interact with trustworthy tokens.


Mantle Token and Bridge Audit − System Overview − 5


### **Privileged Roles**

The owner of the Mantle token can upgrade the contract, mint new tokens, change the mint

cap, and transfer the ownership.


The owner of the migrator contract can pause and unpause the contract, change the treasury

address, transfer BIT and MNT tokens to the treasury address, and transfer all the other

ERC-20 tokens to an arbitrary address.


The Mantle team has claimed that both contracts will be owned by the governance.


Mantle Token and Bridge Audit − Security Model and Trust Assumptions − 6


## **Low Severity**

### **L-01 Misleading Comments**

The following misleading comments were identified:


   - The <u>[comment](https://github.com/mantlenetworkio/mantle-token-contracts/blob/b2016dfb932d85b8b33a9294e8280aa04ca46975/contracts/L1/L1MantleToken.sol#L117)</u> describing the `setMintCapNumerator` references a

`MintCapNumeratorSet` event, but it should be `MintCapNumeratorChanged` .

   - The <u>[comment](https://github.com/mantlenetworkio/mantle-token-contracts/blob/b2016dfb932d85b8b33a9294e8280aa04ca46975/contracts/L1/L1MantleToken.sol#L100)</u> describing the `mint` function says the mint time interval "is initially set to

1 year", which suggests it could be updated. It is actually a <u>[constant](https://github.com/mantlenetworkio/mantle-token-contracts/blob/b2016dfb932d85b8b33a9294e8280aa04ca46975/contracts/L1/L1MantleToken.sol#LL28C30-L28C30)</u> and can only be

changed if the whole contract is upgraded.


Consider updating the comments accordingly.


**_Update:_** _Resolved in_ _<u>[pull request #50](https://github.com/mantlenetworkio/mantle-token-contracts/pull/50)</u>_ _at commit_ _<u>[2a04393.](https://github.com/mantlenetworkio/mantle-token-contracts/pull/50/commits/2a043939a748f91c0d29213b7f0a73a7a6a2c724)</u>_

### **L-02 Bridge Can Be Reinitialized**


The `L1StandardBridge` contains a <u>[guard condition](https://github.com/mantlenetworkio/mantle/blob/d627d242fe19f50f344f1ff4b27532d1757303a6/packages/contracts/contracts/L1/messaging/L1StandardBridge.sol#L54)</u> to prevent it from being reinitialized.

However, it assumes the `messenger` will be non-zero after initialization, which is not

guaranteed by the `initialize` function. This means it is possible to initialize the other

variables and later overwrite them. In practice, the contract will be non-functional until the

messenger is set.


Nevertheless, in the interest of predictability, consider ensuring the messenger is non-zero

during initialization.


**_Update:_** _Resolved in_ _<u>[pull request #1027](https://github.com/mantlenetworkio/mantle/pull/1027)</u>_ _at commit_ _<u>[e641f0e.](https://github.com/mantlenetworkio/mantle/pull/1027/commits/e641f0eac6ba8bf25fa7800ee4aecdf084cb41d2)</u>_

### **L-03 Disable Implementation Contract**


The `L1StandardBridge` implementation contract <u>[sets the messenger to the zero address,](https://github.com/mantlenetworkio/mantle/blob/d627d242fe19f50f344f1ff4b27532d1757303a6/packages/contracts/contracts/L1/messaging/L1StandardBridge.sol#L41)</u>

but this doesn't prevent it from being <u>[initialized.](https://github.com/mantlenetworkio/mantle/blob/d627d242fe19f50f344f1ff4b27532d1757303a6/packages/contracts/contracts/L1/messaging/L1StandardBridge.sol#L53)</u>


Mantle Token and Bridge Audit − Low Severity − 7


In the interest of limiting the attack surface, consider ensuring the implementation contract

cannot be initialized. This could be achieved by setting the messenger to an unused non-zero

address.


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_We decided to use our proxy contract to do the initialization right after deploying the_

_bridge contract. It is not necessary to care about the implementation contract after the_

_proxy contract is initialized._

## **Notes & Additional** **Information**

### **N-01 Typographical Errors**


In <u>`[MantleTokenMigrator.sol](https://github.com/mantlenetworkio/mantle-token-contracts/blob/b2016dfb932d85b8b33a9294e8280aa04ca46975/contracts/Migration/MantleTokenMigrator.sol#L199)`</u> the `received` word is misspelled as `recieved` in several

places. Consider resolving this typographical error.


**_Update:_** _Resolved in_ _<u>[pull request #53](https://github.com/mantlenetworkio/mantle-token-contracts/pull/53)</u>_ _at commit_ _<u>[6b78f54. There have been unrelated changes](https://github.com/mantlenetworkio/mantle-token-contracts/pull/50/commits/6b78f54e665fc8a51f44ef6ec8b2e0ee4a448225)</u>_

_that removed several instances._

### **N-02 ETH Handling Can Be Simplified**


The `MantleTokenMigrator` contract doesn't expect to receive ETH and explicitly <u>[reverts](https://github.com/mantlenetworkio/mantle-token-contracts/blob/b2016dfb932d85b8b33a9294e8280aa04ca46975/contracts/Migration/MantleTokenMigrator.sol#L164-L173)</u> on

the `receive` and `fallback` functions. As noted in <u>[the Solidity documentation, without the](https://docs.soliditylang.org/en/v0.8.13/contracts.html#receive-ether-function)</u>

`receive`, `fallback`, and `payable` functions a Solidity contract reverts on receiving ETH

by default. Consider removing the `receive` and `fallback` functions to simplify the

codebase.


**_Update:_** _Resolved in_ _<u>[pull request #45](https://github.com/mantlenetworkio/mantle-token-contracts/pull/45)</u>_ _at commit_ _<u>[c662f74.](https://github.com/mantlenetworkio/mantle-token-contracts/pull/45/commits/c662f74ad89e60bfb4c6e1996173ea2fe0a80d07)</u>_

### **N-03 Gas Savings**


The <u>`[setMintCapNumerator](https://github.com/mantlenetworkio/mantle-token-contracts/blob/b2016dfb932d85b8b33a9294e8280aa04ca46975/contracts/L1/L1MantleToken.sol#L116-L130)`</u> and <u>`[setTreasury](https://github.com/mantlenetworkio/mantle-token-contracts/blob/b2016dfb932d85b8b33a9294e8280aa04ca46975/contracts/Migration/MantleTokenMigrator.sol#L269-L278)`</u> functions can consume less gas by

emitting an event first and then changing the storage variable.


Mantle Token and Bridge Audit − Notes & Additional Information − 8


For example, the following code snippet

```
uint256 previousMintCapNumerator = mintCapNumerator;
mintCapNumerator = _mintCapNumerator;
emit MintCapNumeratorChanged(msg.sender, previousMintCapNumerator, mintCapNumerator);

```

may be rewritten as:

```
emit MintCapNumeratorChanged(msg.sender, mintCapNumerator, _mintCapNumerator);
mintCapNumerator = _mintCapNumerator;

```

Consider rewriting the <u>`[setMintCapNumerator](https://github.com/mantlenetworkio/mantle-token-contracts/blob/b2016dfb932d85b8b33a9294e8280aa04ca46975/contracts/L1/L1MantleToken.sol#L116-L130)`</u> and <u>`[setTreasury](https://github.com/mantlenetworkio/mantle-token-contracts/blob/b2016dfb932d85b8b33a9294e8280aa04ca46975/contracts/Migration/MantleTokenMigrator.sol#L269-L278)`</u> functions to save gas.


**_Update:_** _Resolved in_ _<u>[pull request #48](https://github.com/mantlenetworkio/mantle-token-contracts/pull/48)</u>_ _at commit_ _<u>[4159ef3.](https://github.com/mantlenetworkio/mantle-token-contracts/pull/48/commits/4159ef39895a4b532071c36bf29ac25d153fd9a4)</u>_

### **N-04 Imprecise Docstrings**


Some imprecise docstrings have been identified:


   - The <u>[comment](https://github.com/mantlenetworkio/mantle-token-contracts/blob/b2016dfb932d85b8b33a9294e8280aa04ca46975/contracts/L1/L1MantleToken.sol#L120)</u> describing the parameter for the `setMintCapNumerator` function does

not follow the <u>[Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/develop/natspec-format.html)</u> (NatSpec) format.

   - For consistency with the `migrateAllBIT` <u>[description, the](https://github.com/mantlenetworkio/mantle-token-contracts/blob/b2016dfb932d85b8b33a9294e8280aa04ca46975/contracts/Migration/MantleTokenMigrator.sol#L181)</u> `migrateBIT` description

should note that the `_amount` must be non-zero.


Consider updating the docstrings accordingly.


**_Update:_** _Resolved in_ _<u>[pull request #54](https://github.com/mantlenetworkio/mantle-token-contracts/pull/54)</u>_ _at commits_ _<u>[97d88d6](https://github.com/mantlenetworkio/mantle-token-contracts/pull/54/commits/97d88d6c243dec5380ad6db839313830278d1852)</u>_ _and_ _<u>[0e76225, and](https://github.com/mantlenetworkio/mantle-token-contracts/pull/54/commits/0e762251252cb456642d7ac048c29ca49fbc0064)</u>_ _<u>[pull request #55](https://github.com/mantlenetworkio/mantle-token-contracts/pull/55)</u>_

_at commit_ _<u>[d515706.](https://github.com/mantlenetworkio/mantle-token-contracts/pull/55/commits/d515706607a15226f2405605271cdc3972621010)</u>_

### **N-05 Redundant Cast**


The `sweepTokens` function of the `MantleTokenMigrator` contract <u>[redundantly casts](https://github.com/mantlenetworkio/mantle-token-contracts/blob/b2016dfb932d85b8b33a9294e8280aa04ca46975/contracts/Migration/MantleTokenMigrator.sol#L312)</u> both

known token addresses to the `address` type. Consider removing the unnecessary cast

operations.


**_Update:_** _Resolved in_ _<u>[pull request #44](https://github.com/mantlenetworkio/mantle-token-contracts/pull/44)</u>_ _at commit_ _<u>[bb921bf.](https://github.com/mantlenetworkio/mantle-token-contracts/pull/44/commits/bb921bf9c1655a341ac5be655460ff490bc75389)</u>_


Mantle Token and Bridge Audit − Notes & Additional Information − 9


### **N-06 Unnecessary Multiple Inheritance**

The `L1MantleToken` contract inherits from <u>[several contracts](https://github.com/mantlenetworkio/mantle-token-contracts/blob/b2016dfb932d85b8b33a9294e8280aa04ca46975/contracts/L1/L1MantleToken.sol#L15-L20)</u> with redundant dependencies.

This means that some of the contracts are inherited both directly and indirectly. For example,

inheriting `ERC20VotesUpgradeable` makes inheriting `ERC20PermitUpgradeable` and

`ERC20Upgradeable` redundant.


This is still a reasonable pattern because it improves explicitness and makes <u>[the sequence of](https://github.com/mantlenetworkio/mantle-token-contracts/blob/b2016dfb932d85b8b33a9294e8280aa04ca46975/contracts/L1/L1MantleToken.sol#L83-L87)</u>

<u>[initializations](https://github.com/mantlenetworkio/mantle-token-contracts/blob/b2016dfb932d85b8b33a9294e8280aa04ca46975/contracts/L1/L1MantleToken.sol#L83-L87)</u> more intuitive. However, it also forces the `L1MantleToken` to introduce

<u>[boilerplate functions](https://github.com/mantlenetworkio/mantle-token-contracts/blob/b2016dfb932d85b8b33a9294e8280aa04ca46975/contracts/L1/L1MantleToken.sol#L132-L150)</u> that are unrelated to the token's new logic. Our opinion is that removing

redundancy from the inheritance chain would make the contract simpler and easier to reason

about. Consider limiting the inheritance chain to the necessary contracts (i.e.,

`ERC20BurnableUpgradeable`, `OwnableUpgradeable` and `ERC20VotesUpgradeable` ).


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_We prefer not to make modifications to improve explicitness and make the initialization_

_sequence more intuitive._

### **N-07 BIT Token Address Is Used Instead of MNT** **Token Address**


The bridge contracts have specific logic to handle MNT tokens but the `L1StandardBridge`

contract <u>[currently associates the BIT token](https://github.com/mantlenetworkio/mantle/blob/d627d242fe19f50f344f1ff4b27532d1757303a6/packages/contracts/contracts/L1/messaging/L1StandardBridge.sol#L200)</u> with the L2 Mantle token. Consider reusing the

<u>[existing variable](https://github.com/mantlenetworkio/mantle/blob/d627d242fe19f50f344f1ff4b27532d1757303a6/packages/contracts/contracts/L1/messaging/L1StandardBridge.sol#L31)</u> to identify the MNT token address.


Note that the L2 token also <u>[still references the BIT token](https://github.com/mantlenetworkio/mantle/blob/d627d242fe19f50f344f1ff4b27532d1757303a6/packages/contracts/contracts/L2/predeploys/BVM_MANTLE.sol#L21)</u> and should be updated accordingly.


**_Update:_** _Resolved in_ _<u>[pull request #1075](https://github.com/mantlenetworkio/mantle/pull/1075)</u>_ _at commit_ _<u>[d140d18. The correct address is now](https://github.com/mantlenetworkio/mantle/pull/1075/commits/d140d183fdd4aeda7539c60323b09458c303a935)</u>_

_hardcoded instead of reusing the variable._

### **N-08 Unused Function**


The `L1StandardBridge` has a <u>[function](https://github.com/mantlenetworkio/mantle/blob/d627d242fe19f50f344f1ff4b27532d1757303a6/packages/contracts/contracts/L1/messaging/L1StandardBridge.sol#L297)</u> to donate ETH to the contract. However, this

function is a holdover from the Optimism code base and is not required for a fresh deployment.

Consider removing it.


**_Update:_** _Resolved in_ _<u>[pull request #1029](https://github.com/mantlenetworkio/mantle/pull/1029)</u>_ _at commit_ _<u>[a47a661.](https://github.com/mantlenetworkio/mantle/pull/1029/commits/a47a66135685f5e487b286b641fb7f681c8d4095)</u>_


Mantle Token and Bridge Audit − Notes & Additional Information − 10


### **N-09 Unusable Data Parameter**

All deposits and withdrawals <u>[pass an arbitrary data parameter](https://github.com/mantlenetworkio/mantle/blob/d627d242fe19f50f344f1ff4b27532d1757303a6/packages/contracts/contracts/L1/messaging/L1StandardBridge.sol#L126)</u> over the bridge. This parameter

is emitted in the events on <u>[both](https://github.com/mantlenetworkio/mantle/blob/d627d242fe19f50f344f1ff4b27532d1757303a6/packages/contracts/contracts/L1/messaging/L1StandardBridge.sol#L134)</u> <u>[sides, but is otherwise unused. The documentation](https://github.com/mantlenetworkio/mantle/blob/d627d242fe19f50f344f1ff4b27532d1757303a6/packages/contracts/contracts/L2/messaging/L2StandardBridge.sol#L169)</u> <u>[claims](https://github.com/mantlenetworkio/mantle/blob/d627d242fe19f50f344f1ff4b27532d1757303a6/packages/contracts/contracts/L1/messaging/L1StandardBridge.sol#L108-L110)</u> it is

a convenience for external contracts, but it is not passed to the destination and other contracts

cannot read the events. Consider clarifying how the parameter could be used, or remove it

from the transfer.


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_We see this as a data interface reserved for subsequent cross-chain interoperability._

### **N-10 Unnecessary Specialization**


The bridge contracts contain custom logic to support <u>[depositing Mantle tokens. However, only](https://github.com/mantlenetworkio/mantle/blob/d627d242fe19f50f344f1ff4b27532d1757303a6/packages/contracts/contracts/L1/messaging/L1StandardBridge.sol#L195-L196)</u>

the <u>[token mapping validation](https://github.com/mantlenetworkio/mantle/blob/d627d242fe19f50f344f1ff4b27532d1757303a6/packages/contracts/contracts/L1/messaging/L1StandardBridge.sol#L197)</u> differs from the generic ERC-20 case, so the

`finalizeDeposit` calldata specification can be unified between both branches. Similarly, as

long as the `BVM_MANTLE` token is configured correctly Mantle tokens can be withdrawn using

the <u>[generic ERC-20 logic. This would remove unnecessary withdrawal logic and make the](https://github.com/mantlenetworkio/mantle/blob/d627d242fe19f50f344f1ff4b27532d1757303a6/packages/contracts/contracts/L2/messaging/L2StandardBridge.sol#L122)</u>

<u>`[finalizeMantleWithdrawal](https://github.com/mantlenetworkio/mantle/blob/d627d242fe19f50f344f1ff4b27532d1757303a6/packages/contracts/contracts/L1/messaging/L1StandardBridge.sol#L257)`</u> <u>function</u> obsolete. Consider simplifying the code accordingly.


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_We divided this method mainly to facilitate the addition of necessary restrictions for the_

_L2 native token, and also to facilitate subsequent targeted maintenance._

### **N-11 Redundant Validation**


The `finalizeMantleWithdrawal` function <u>[validates](https://github.com/mantlenetworkio/mantle/blob/d627d242fe19f50f344f1ff4b27532d1757303a6/packages/contracts/contracts/L1/messaging/L1StandardBridge.sol#L262)</u> that it is called from the L2 bridge, but

this check is repeated on the <u>`[finalizeERC20Withdrawal](https://github.com/mantlenetworkio/mantle/blob/d627d242fe19f50f344f1ff4b27532d1757303a6/packages/contracts/contracts/L1/messaging/L1StandardBridge.sol#L276)`</u> <u>function. Consider removing the</u>

redundant validation.


**_Update:_** _Resolved in_ _<u>[pull request #1031](https://github.com/mantlenetworkio/mantle/pull/1031)</u>_ _at commit_ _<u>[5fbb898.](https://github.com/mantlenetworkio/mantle/pull/1031/commits/5fbb898249452adfd0557762a77e7318e9d83fb4)</u>_

### **N-12 Incorrect Encapsulation**


The `_initiateWithdrawal` function <u>[claims](https://github.com/mantlenetworkio/mantle/blob/d627d242fe19f50f344f1ff4b27532d1757303a6/packages/contracts/contracts/L2/messaging/L2StandardBridge.sol#L80)</u> to retrieve tokens from the `_from` address but

it actually <u>[takes them from the caller. Similarly, the event](https://github.com/mantlenetworkio/mantle/blob/d627d242fe19f50f344f1ff4b27532d1757303a6/packages/contracts/contracts/L2/messaging/L2StandardBridge.sol#L99)</u> <u>[references the caller](https://github.com/mantlenetworkio/mantle/blob/d627d242fe19f50f344f1ff4b27532d1757303a6/packages/contracts/contracts/L2/messaging/L2StandardBridge.sol#L139)</u> instead of the

`_from` address. This behavior is equivalent in the current code base because <u>[both calling](https://github.com/mantlenetworkio/mantle/blob/d627d242fe19f50f344f1ff4b27532d1757303a6/packages/contracts/contracts/L2/messaging/L2StandardBridge.sol#L54-L75)</u>


Mantle Token and Bridge Audit − Notes & Additional Information − 11


<u>[functions](https://github.com/mantlenetworkio/mantle/blob/d627d242fe19f50f344f1ff4b27532d1757303a6/packages/contracts/contracts/L2/messaging/L2StandardBridge.sol#L54-L75)</u> pass the message sender as the `_from` address. Nevertheless, in the interest of

predictability and encapsulation, consider using the `_from` address inside the function.


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_In future bedrock upgrades, the above call logic has not changed, and no fixes are_

_necessary._

### **N-13 Use of Hardcoded Values**


The `L1StandardBridge` contract has <u>[the address of the MNT token hardcoded. Consider](https://github.com/mantlenetworkio/mantle/blob/d627d242fe19f50f344f1ff4b27532d1757303a6/packages/contracts/contracts/L1/messaging/L1StandardBridge.sol#L200)</u>

creating a constant variable and using it instead of the hardcoded address for clarity and

readability.


Similarly, the `L2StandardBridge` contract <u>hardcodes the</u> <u>`[IL2StandardERC20](https://github.com/mantlenetworkio/mantle/blob/d627d242fe19f50f344f1ff4b27532d1757303a6/packages/contracts/contracts/L2/messaging/L2StandardBridge.sol#L161)`</u> <u>identifier.</u>

Consider using the more expressive `type(IL2StandardERC20).interfaceId` statement

instead.


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_We think it is fine to hardcode it. Moreover, where the address comes from and its_

_purpose are clearly explained in the comments._


Mantle Token and Bridge Audit − Notes & Additional Information − 12


## **Conclusions**

Several minor vulnerabilities and notes have been found throughout the codebase, and fixes

have been suggested. We found the codebase to be well documented and appreciate the

reuse of existing libraries and systems.


Below we provide our recommendations for monitoring important activities in order to detect

and prevent potential bugs.


Mantle Token and Bridge Audit − Conclusions − 13


## **Monitoring** **Recommendations**

While audits help in identifying code-level issues in the current implementation and potentially

the code deployed in production, the Mantle team is encouraged to consider incorporating

monitoring activities in the production environment. Ongoing monitoring of deployed contracts

helps identify potential threats and issues affecting production environments. With the goal of

providing a complete security assessment, the monitoring recommendations section raises

several actions addressing trust assumptions and out-of-scope components that can benefit

from on-chain monitoring.


**Governance**


There are multiple privileged actions with serious security implications:


   - The `L1MantleToken` contract owner can :

    - Change the mint cap, within some bounds.

    - Mint tokens within the mint cap.

    - Upgrade the contract arbitrarily, potentially removing the mint cap restrictions.




- The `MantleTokenMigrator` contract owner can:




- Halt or unhalt the contract.




- Change the treasury address that can receive the BIT and MNT tokens.




- Send the BIT or MNT tokens to the treasury address.




- Retrieve any other tokens sent to the contract.




- The `L1StandardBridge` contract owner can upgrade the contract, which gives the



owner access to all funds secured by the bridge.


Consider monitoring these administrator functions to ensure all changes are expected.


**Financial activity**


Consider monitoring the exchanges that occur on the `MantleTokenMigrator` contract to

ensure they are within reasonable bounds. Unusually large, small or frequent transactions may

indicate an unexpected edge case.


Mantle Token and Bridge Audit − Monitoring Recommendations − 14


Consider monitoring the token transfers over the bridge to identify:


   - Transfers that take unusually long to complete

   - Transactions that revert

   - Any deposits that invoke the refund mechanism

   - Any unusually large, small or frequent transactions

  - Transfers with mismatched L1 and L2 tokens


These may indicate a user interface bug, an ongoing attack or other unexpected edge cases.


Mantle Token and Bridge Audit − Monitoring Recommendations − 15


