### | security

# **ZKsync Custom** **Asset Bridge** **Audit**

#### **August 9, 2024**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  4


Scope ____________________________________________________________________________  5


System Overview __________________________________________________________________  6


Security Model and Trust Assumptions _______________________________________________  7

Privileged Roles 7


Design Considerations _____________________________________________________________  8


Critical Severity ____________________________________________________________________  9

C-01 All Assets Can Be Stolen From the Vault 9


High Severity ______________________________________________________________________  9

H-01 Mismatching Encoding Prevents Bridge Recovery 9

H-02 User Funds Can Be Frozen in the L1NativeTokenVault 10


Medium Severity _________________________________________________________________ 11

M-01 L2 Native Tokens Become Unmintable on Beacon Change 11


Low Severity ____________________________________________________________________ 12

L-01 Lack of Events 12

L-02 Misleading Value Is Forwarded During Deposit 12

L-03 Imprecise Error 12

L-04 Fragile Encodings 13

L-05 Custom Assets May Not Be Withdrawable 14

L-06 ETH’s L2StandardERC20 Representation Does Not Have name or symbol 14

L-07 Inaccurate Legacy Deposits Identification 15


Notes & Additional Information ____________________________________________________ 15

N-01 Unused Code 15

N-02 Incorrect and Missing Documentation 16

N-03 Code Redundancy 18

N-04 Naming Suggestions 18

N-05 Gas Optimizations 19

N-06 Misleading Error 20

N-07 Unreachable Code 20

N-08 Typographical Errors 21

N-09 Misleading Function Name 21


ZKsync Custom Asset Bridge Audit − Table of Contents − 2


N-10 Lack of Security Contact 21

N-11 Incomplete and Mismatching Interfaces 22

N-12 Code Quality and Readability Suggestions 23

N-13 Lack of Input Validation on Emitted Data 24

N-14 Padded Token Address as Asset ID Is Registered Redundantly on Base Token Deposits 24


Conclusion ______________________________________________________________________ 26


ZKsync Custom Asset Bridge Audit − Table of Contents − 3


## **Summary**

**Type** ZK Rollup


**Timeline** From 2024-06-17
To 2024-07-08


**Languages** Solidity



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



1 (1 resolved)


2 (2 resolved)


1 (1 resolved)



**Total Issues** 25 (24 resolved, 1 partially resolved)



**Low Severity Issues** 7 (7 resolved)



**Notes & Additional**
**Information**



14 (13 resolved, 1 partially resolved)



ZKsync Custom Asset Bridge Audit − Summary − 4


## **Scope**

We diff-audited <u>[pull request #484](https://github.com/matter-labs/era-contracts/pull/484)</u> of the <u>[matter-labs/era-contracts](https://github.com/matter-labs/era-contracts)</u> repository at commit

<u>[d397b7f. New contracts were fully audited. Other files that were fully audited despite only](https://github.com/matter-labs/era-contracts/tree/d397b7f0b4d608d20d403554a30e3659a326309b)</u>

being partially changed are explicitly tagged as "full" in the scope definition given below.


The following files were in scope:

```
├── l1-contracts
│  └── contracts
│    ├── bridge
│    │  ├── L1NativeTokenVault.sol
│    │  ├── L1SharedBridge.sol (full)
│    │  └── interfaces
│    │    ├── IL1AssetHandler.sol
│    │    ├── IL1NativeTokenVault.sol
│    │    ├── IL1SharedBridge.sol
│    │    ├── IL2Bridge.sol
│    │    └── IL2BridgeLegacy.sol
│    ├── bridgehub
│    │  ├── Bridgehub.sol (full)
│    │  └── IBridgehub.sol
│    ├── common
│    │  ├── Config.sol
│    │  └── libraries
│    │    └── UnsafeBytes.sol
│    └── state-transition
│      ├── chain-deps
│      │  └── facets
│      │    ├── Getters.sol
│      │    └── Mailbox.sol
│      └── chain-interfaces
│        ├── IGetters.sol
│        └── IMailbox.sol
└── l2-contracts
└── contracts
├── L2ContractErrors.sol
├── L2ContractHelper.sol
└── bridge
├── L2NativeTokenVault.sol
├── L2SharedBridge.sol (full)
└── interfaces
├── IL2AssetHandler.sol
├── IL2NativeTokenVault.sol
├── IL2SharedBridge.sol (full)
└── ILegacyL2SharedBridge.sol

```

ZKsync Custom Asset Bridge Audit − Scope − 5


## **System Overview**

The upgrade under review is driven by the goal of supporting bridging custom assets. This has

necessitated a redesign of the existing bridge architecture to relieve token developers from the

burden of creating their own bridges and repeatedly implementing the same bridge logic. Thus,

the new concept of asset handlers, the new <mark>`L{1,2}NativeTokenVault`</mark> contracts, and

changes to the <mark>`L{1,2}SharedBridge`</mark> have been introduced. Until now, the <mark>`L{1,2}`</mark>

<mark>`SharedBridge`</mark> only supported ETH and ERC-20 tokens by deploying a standard ERC-20

implementation on L2. With this upgrade, assets are managed by handlers and identified by

their ID, which is a hash of the origin chain ID, the initial asset handler registrant, and any

<mark>`bytes32`</mark> asset data value (e.g., the padded token address). The shared bridge maintains a

mapping of asset handlers for each asset ID bridged by users.


An asset handler is a smart contract on both layers that handles the burning, minting, locking,

and releasing of bridged tokens. It must implement the <mark>`bridgeMint`</mark> and <mark>`bridgeBurn`</mark>

functions on both layers, as well as the <mark>`bridgeRecoverFailedTransfer`</mark> function on L1.

The shared bridge functionality of bridging standard ERC-20 tokens and ETH has been

outsourced to the <mark>`L{1,2}NativeTokenVault`</mark> asset handler which will also hold all of the

current shared bridge funds. For custom token needs, developers can deploy the token

contract on L2 along with the asset handler on each layer, which can permissionlessly be

registered in the shared bridge. Users can then refer to the associated asset ID when

depositing/withdrawing this token, with the shared bridge partially delegating the flow to the

asset handler.


The change from token address to asset ID required small adjustments to the <mark>`Bridgehub`</mark> and

<mark>`Mailbox`</mark> facets to track each chain's base asset ID and to comply with the latest shared

bridge interface. In addition, the legacy <mark>`L1ERC20Bridge`</mark> now forwards the tokens to the

<mark>`L1NativeTokenVault`</mark> <mark>.</mark> Other than that, the main control flow and integrations remain

unchanged while backwards compatibility, notably in the shared bridge, is maintained.


ZKsync Custom Asset Bridge Audit − System Overview − 6


## **Security Model and Trust** **Assumptions**

Several trust assumptions were made during our audit of the protocol:


   - All of the addresses with the roles mentioned in the _Privileged Roles_ section below can

impact users in different ways and some, if compromised, could freeze or steal users'

funds. These actors are assumed to behave honestly and in the best interests of the

protocol users.

   - Deposits and withdrawals from batches before the last bridge upgrade are considered to

have been finalized prior to the upgrade and handled separately.

   - The <u>[bridge address](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridgehub/Bridgehub.sol#L330)</u> called as part of the <mark>`requestL2TransactionTwoBridges`</mark>

function is expected to fully implement the <u><mark>`[IL1SharedBridge](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/interfaces/IL1SharedBridge.sol)`</mark></u> <u>interface. For instance,</u>

this interface should allow users to reclaim their assets in case of a failed deposit.

   - The upgrade is assumed to be well-coordinated, such that the contracts are upgraded

and funds are transferred all at the same time. Due to interface changes, parts of the

code will break if not upgraded simultaneously.

   - ZKchains are assumed to have valid state transitions. For example, it is assumed that

they can not force an invalid state transition in order to steal assets from the bridge.

   - The <mark>`L2NativeTokenVault`</mark> contract is expected to be deployed at the current

<mark>`L2SharedBridge`</mark> implementation, while the <mark>`L2SharedBridge`</mark> becomes a system

contract. However, a compatible storage layout has not yet been finalized. As this is a

<u>[known issue, we assume that the storage layout will still be adapted to not cause](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/contracts-review-prep.md#known-issues)</u>

conflicts.


The above trust assumptions are considered inherent to the current design of the codebase.

### **Privileged Roles**


There are multiple privileged roles in the system:


    - **Admin** : Bridge contracts are deployed behind transparent proxies. The admin of these

proxies on L1 and L2 can arbitrarily upgrade the contract implementations.

    - **Owner** : The <mark>`Bridgehub`</mark> <mark>,</mark> <mark>`L1SharedBridge`</mark> <mark>,</mark> <mark>`L1NativeTokenVault`</mark> <mark>,</mark> and

<mark>`L2NativeTokenVault`</mark> contracts have an owner. This owner can call privileged

functions and pause some functionalities in the L1 contracts.


ZKsync Custom Asset Bridge Audit − Security Model and Trust Assumptions

                                                  - 7


    - **Asset Handler Registrant** : The initial registrant associated with an asset ID can edit the

address of the asset handler on L1 and L2 at any time. Users should be aware of the risk

of using custom asset IDs when bridging their assets.

## **Design Considerations**


The following design considerations are motivated by the issues found during the audit and the

perceived code clarity:


   - The bridge contracts make use of multiple encodings to pass data and information from

one layer to the other. Data encoding and decoding are always made in-place wherever

they are needed, but mismatches between the two can result in issues. For concrete

examples, please refer to <u>H-01</u> and <u>L-04. The approach taken appears to be prone to</u>

errors, difficult to maintain, and introduces code redundancy. Instead, a library containing

the common encodings could be implemented and reused throughout the codebase.

   - Backwards compatibility is a guarantee for developers, ensuring that their bridge

integrations do not break with the upgrade. However, it also increases the surface for

potential security issues. For instance, <u>H-02</u> originates from the need to maintain

backwards compatibility. Backwards compatibility makes the code more complex due to

multiple control flow paths in parallel that want to achieve the same behavior, but are

difficult to maintain, require extra code, and can introduce mismatching outcomes that

lead to issues. When backwards compatibility is no longer necessary in the future,

consider revisiting the bridge contracts and updating them to only support the latest

version.


ZKsync Custom Asset Bridge Audit − Design Considerations − 8


## **Critical Severity**

### **C-01 All Assets Can Be Stolen From the Vault**

Users can bridge ERC-20 tokens and ETH from L1 to L2 (and back) by using the native token

[vaults as asset handlers (L1, L2). A standard L2 token is](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L24) <u>[deployed](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2NativeTokenVault.sol#L108)</u> as a beacon proxy by the

<mark>`L2NativeTokenVault`</mark> for each new token bridged from L1. Such tokens are <u>[minted](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2NativeTokenVault.sol#L115)</u> when

assets are bridged from L1 using the <mark>`L1NativeTokenVault`</mark> as the asset handler.


However, the <u><mark>`[bridgeMint](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2NativeTokenVault.sol#L95)`</mark></u> function is not protected by the <u><mark>`[onlyBridge](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2NativeTokenVault.sol#L35)`</mark></u> <u>modifier</u> and can

be called by anyone on L2. This means that anyone can mint any amount of any token that is

managed by the native token vault on L2, which could then be bridged back to drain all the

assets in the <mark>`L1NativeTokenVault`</mark> <mark>,</mark> including those currently in the shared bridge.


Consider adding an <mark>`onlyBridge`</mark> modifier to the <mark>`bridgeMint`</mark> function.


**_Update:_** _Resolved in_ _<u>[pull request #618](https://github.com/matter-labs/era-contracts/pull/618)</u>_ _at commit_ _<u>[c564076.](https://github.com/matter-labs/era-contracts/commit/c564076a5d3896145233e36fb278a20758a70e72)</u>_

## **High Severity**

### **H-01 Mismatching Encoding Prevents Bridge** **Recovery**


Funds can be recovered through the <mark>`L1SharedBridge`</mark> in case of a failed non-legacy

deposit. A <u>[successful recovery requires](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L527)</u> that the hash of the sender, the token address, and the

amount matches the stored deposit information which is stored through the

<u><mark>`[bridgehubConfirmL2Transaction](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L454)`</mark></u> <u>function</u> that is called by the <mark>`Bridgehub`</mark> <mark>.</mark> This

function stores the <u><mark>`[txDataHash](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L460)`</mark></u> returned by the <u><mark>`[L1SharedBridge](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L389-L391)`</mark></u> <mark>.</mark>


However, this <mark>`txDataHash`</mark> returned by the bridge is encoded and hashed differently

compared to during the recovery. This is because the recovery encodes <mark>`address l1Token`</mark>

and <mark>`uint256 amount`</mark> <mark>,</mark> while the deposit function encodes a <mark>`bytes32 _assetId`</mark> and

<mark>`bytes _transferData`</mark> for non-legacy deposits. Due to this mismatch, a recovery is

impossible and user funds would be locked in the bridge.


ZKsync Custom Asset Bridge Audit − Critical Severity − 9


Consider implementing an <mark>`internal`</mark> function to construct a consistent transaction data hash

for both functions.


**_Update:_** _Resolved in_ _<u>[pull request #619](https://github.com/matter-labs/era-contracts/pull/619)</u>_ _at commit_ _<u>[16241e4. A function was implemented to](https://github.com/matter-labs/era-contracts/pull/619/commits/16241e4616075d53de9a958c3a4eb107bfe28e3c)</u>_

_handle the hash generation. During the recovery a try/catch mechanism determines whether the_

_transaction data is hashed over the legacy or new encoding and properly checks it against the_

_stored hash._

### **H-02 User Funds Can Be Frozen in the** **`L1NativeTokenVault`**


Users can bridge ERC-20 tokens from L1 to L2 in three different ways:


1. By calling <u><mark>`[requestL2TransactionDirect](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridgehub/Bridgehub.sol#L256C14-L256C40)`</mark></u> or

<u><mark>`[requestL2TransactionTwoBridges](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridgehub/Bridgehub.sol#L302C14-L302C44)`</mark></u> on the <mark>`Bridgehub`</mark> contract.

2. By calling <u><mark>`[requestL2Transaction](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L199C14-L199C34)`</mark></u> on the <mark>`MailboxFacet`</mark> contract (through the

diamond proxy).

3. By calling <u><mark>`[deposit](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1ERC20Bridge.sol#L149C14-L149C21)`</mark></u> on the <mark>`L1ERC20Bridge`</mark> contract.


In practice, in most cases, the asset bridged will be safeguarded by the

<mark>`L1NativeTokenVault`</mark> (as the canonical asset handler). When the <mark>`L1NativeTokenVault`</mark>

handles an asset, <u><mark>`[bridgeBurn](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L119)`</mark></u> or <u><mark>`[bridgeMint](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L193C14-L193C24)`</mark></u> is called. These two functions add or

subtract the amount of tokens sent from the <u><mark>`[chainBalance](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L204)`</mark></u> mapping, respectively. This

mapping is used as a security measure to segregate the funds sent by chain ID, ensuring that

no more than the deposited amount of assets can be withdrawn from a certain chain.


However, the <mark>`deposit`</mark> function (see 3. above) does not increase the <mark>`chainBalance`</mark>

mapping as it <u>[sends the funds directly](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1ERC20Bridge.sol#L178-L180)</u> to the <mark>`L1NativeTokenVault`</mark> <mark>.</mark> Still, withdrawals

decrease the <mark>`chainBalance`</mark> <mark>,</mark> possibly reverting if it becomes negative. This asymmetry

creates an imbalance, leading to a state where all funds cannot be bridged back as soon as

<mark>`deposit`</mark> is called.


This could be used by a malicious user to actively freeze funds by calling <mark>`deposit`</mark> to bridge
##### x amount of an ERC-20 token, and then immediately bridging back to L1. The net effect of this scheme would be to reduce chainBalance by . By choosing as the current x x

<mark>`chainBalance`</mark> <mark>,</mark> the malicious user could cause all the future calls made to <mark>`bridgeMint`</mark> for

a certain asset to revert, thereby causing users' funds to effectively be stuck in the

<mark>`L1NativeTokenVault`</mark> <mark>.</mark>


ZKsync Custom Asset Bridge Audit − High Severity − 10


Consider calling <mark>`bridgeBurn`</mark> on the <mark>`L1NativeTokenVault`</mark> when depositing through the

<mark>`L1ERC20Bridge`</mark> <mark>.</mark> Note that this would require handling the allowance given by the user to

the <mark>`L1NativeTokenVault`</mark> <mark>,</mark> similar to <u>what is done for the</u> <u><mark>`[L1SharedBridge](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L334-L341)`</mark></u> <mark>.</mark>


**_Update:_** _Resolved in_ _<u>[pull request #620](https://github.com/matter-labs/era-contracts/pull/620)</u>_ _at commit_ _<u>[992c85a. The ERC-20 tokens are deposited](https://github.com/matter-labs/era-contracts/pull/620/commits/992c85a7b5acb4f09fd8286c3c10c6ec9aa1dfb5)</u>_

_from the legacy bridge to the shared bridge, which gives an allowance to the native token vault._

## **Medium Severity**

### **M-01 L2 Native Tokens Become Unmintable on** **Beacon Change**


Any ERC-20 token can be bridged to L2 through the native token vault. On the first mint of a

newly bridged token, a <u>[standard contract will be deployed](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2NativeTokenVault.sol#L101-L112)</u> using the beacon proxy pattern. The

beacon proxy (L2 token) is deployed at a deterministic address using the <mark>`create2`</mark> function of

the deployer system contract. As the L2 token address is deterministic given the L1 token

address, the <u><mark>`[bridgeMint](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2NativeTokenVault.sol#L115)`</mark></u> <u>[function is called](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2NativeTokenVault.sol#L115)</u> on that expected L2 token address.


The problem is that the L2 token address is <u>[deterministic under three variables: The L1 token](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2NativeTokenVault.sol#L182-L187)</u>

address, the beacon proxy bytecode hash, and the beacon address as a constructor

argument. The latter two can be configured by the owner calling the <u><mark>`[setL2TokenBeacon](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2NativeTokenVault.sol#L89)`</mark></u>

<u>[function. Thus, if these beacon variables change, the L1 token address leads to a different](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2NativeTokenVault.sol#L89)</u>

expected address without any deployed code, making the <u><mark>`[bridgeMint](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2NativeTokenVault.sol#L115)`</mark></u> <u>call</u> revert. This

means that no more of this L2 token can be minted unless the beacon change is reverted.


Instead of calling the expected token address, consider calling the <u>[token address that is stored](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2NativeTokenVault.sol#L96)</u>

<u>[during deployment](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2NativeTokenVault.sol#L96)</u> to guarantee that the same asset ID leads to the same token contract.

Furthermore, consider moving the address computation logic from the <u><mark>`[l2TokenAddress](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2NativeTokenVault.sol#L182-L187)`</mark></u>

function to an <mark>`internal`</mark> <mark>`_calculateCreate2TokenAddress`</mark> function. This function

could be called within the <u><mark>`[if](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2NativeTokenVault.sol#L100-L113)`</mark></u> <u><mark>-</mark></u> <u>[block](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2NativeTokenVault.sol#L100-L113)</u> of the <mark>`bridgeMint`</mark> function instead of <u>[outside.](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2NativeTokenVault.sol#L99)</u>

Moreover, in the <mark>`l2TokenAddress`</mark> function, the asset ID could be computed to return the

address stored in the <mark>`tokenAddress`</mark> mapping if it is non-zero. Otherwise, the address

returned by <mark>`_calculateCreate2TokenAddress`</mark> could be returned.


Alternatively, consider if the beacon proxy bytecode hash and beacon address **ever** have to be

changed. If this is not the case, the <mark>`setL2TokenBeacon`</mark> function can be removed, with the

above implications clearly documented in the code.


ZKsync Custom Asset Bridge Audit − Medium Severity − 11


**_Update:_** _Resolved in_ _<u>[pull request #621](https://github.com/matter-labs/era-contracts/pull/621)</u>_ _at commit_ _<u>[82ffa3a. The Matter Labs team applied the](https://github.com/matter-labs/era-contracts/pull/621/commits/82ffa3a3da9617a1ea239e6e542d69a08e96a17a)</u>_

_first suggestion, making use of the stored token address._

## **Low Severity**

### **L-01 Lack of Events**


The <mark>`Bridgehub`</mark> contract has <u>[various owner-permitted functions](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridgehub/Bridgehub.sol#L101-L130)</u> to edit the set of active

<mark>`StateTransitionManagers`</mark> <mark>,</mark> add a base token, and update the shared bridge in use,

without emitting any events.


For improved transparency, consider emitting events when interacting with any of these

functions.


**_Update:_** _Resolved in_ _<u>[pull request #622](https://github.com/matter-labs/era-contracts/pull/622)</u>_ _at commit_ _<u>[ed9cc80.](https://github.com/matter-labs/era-contracts/pull/622/commits/ed9cc8066636c54c5940f5b8132c8c9cb8d8f202)</u>_

### **L-02 Misleading Value Is Forwarded During** **Deposit**


The <mark>`L1SharedBridge`</mark> contract receives the <mark>`_l2Value`</mark> parameter in the

<mark>`bridgehubDeposit`</mark> function and <u>[forwards this as](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L422)</u> <u><mark>`[_mintValue](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L422)`</mark></u> when calling the

<mark>`bridgeBurn`</mark> function of the asset handler. However, <mark>`mintValue`</mark> and <mark>`l2Value`</mark> are

conceptually different. The <mark>`mintValue`</mark> is what is minted on L2 as a native asset and what

<u>[covers the transaction fee. On the other hand, the](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L270)</u> <mark>`l2Value`</mark> is the <mark>`msg.value`</mark> of the L2

transaction.


Consider clarifying the intention of the forwarded value.


**_Update:_** _Resolved in_ _<u>[pull request #624](https://github.com/matter-labs/era-contracts/pull/624)</u>_ _at commit_ _<u>[46b84aa.](https://github.com/matter-labs/era-contracts/pull/624/commits/46b84aa4c0577d565b9f1b07cec48be6111acc1d)</u>_

### **L-03 Imprecise Error**


Users can deposit any <u><mark>`[assetId](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L373)`</mark></u> through the <u><mark>`[Bridgehub](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridgehub/Bridgehub.sol#L330-L336)`</mark></u> expecting that an asset handler is

registered in the shared bridge that will handle the deposit. However, if no such asset handler

is registered in the <mark>`assetHandlerAddress`</mark> mapping, the <u><mark>`[bridgeBurn](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L420)`</mark></u> <u>call to</u>

<u><mark>`[address(0)](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L420)`</mark></u> will revert with a generic error.


ZKsync Custom Asset Bridge Audit − Low Severity − 12


Consider checking beforehand that the asset ID has a defined handler and giving a specific

revert reason if that is not the case.


**_Update:_** _Resolved in_ _<u>[pull request #625](https://github.com/matter-labs/era-contracts/pull/625)</u>_ _at commit_ _<u>[2d57678.](https://github.com/matter-labs/era-contracts/commit/2d57678f1f7b857066dfa174420ebae22f261bc3)</u>_

### **L-04 Fragile Encodings**


The bridge contracts make use of many encodings for the handling of assets. As seen in

_<u>Mismatching Encoding Prevents Bridge Recovery</u>_ <u>, this led to a severe issue of locked funds. In</u>

addition, there are two more encodings which appear fragile, although a concrete issue could

not be identified:


   - The asset ID is a hash of the encoded chain ID, the initial asset handler registrant, and a

<mark>`bytes32`</mark> asset data value. However, sometimes, this asset data is encoded as an

<mark>`address`</mark> <u>[[1, 2] and sometimes as a](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L250)</u> <mark>`bytes32`</mark> [value [3, 4, 5]. Due to the words being](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L217)

padded when using <mark>`abi.encode`</mark> <mark>,</mark> both variations lead to the same ID. Still, consider

handling the ID generation with one function for standardization and ease of

maintenance.

   - When bridging tokens from L1 to L2 through the native token vault, <mark>`bridgeBurn`</mark> on L1

will provide the <mark>`bridgeMintData`</mark> passed to <mark>`bridgeMint`</mark> on L2. However, there is a

dangerous mismatch between the <u>[encoding](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L153)</u> and <u>[decoding](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2NativeTokenVault.sol#L97-L98)</u> of that mint information, as

the <mark>`amount`</mark> matches the <mark>`l1Sender`</mark> information and vice-versa. Luckily, this is not a

problem because <mark>`bridgeMintData`</mark> is correctly decoded and encoded **for a second**

**time** . The <mark>`L1SharedBridge`</mark> decodes the <mark>`bridgeMintData`</mark> to <u>[encode the call](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L475-L483)</u> to the

legacy <mark>`finalizeDeposit`</mark> function. That function in the <mark>`L2SharedBridge`</mark> then

correctly <u>[encodes the data](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2SharedBridge.sol#L173)</u> that is passed to the <mark>`L2NativeTokenVault`</mark> <mark>.</mark> Overall, the

flow of data is not intuitive to follow and the double encoding is prone to errors. Consider

simplifying the functions involved and using the same encoding of data in the native

token vaults.


Consider creating a common library that will handle the encodings and decodings of bridge
related data in one place. Furthermore, consider simplifying the data flow to make code review

and maintenance easier.


**_Update:_** _Resolved in_ _<u>[pull request #627](https://github.com/matter-labs/era-contracts/pull/627)</u>_ _at commit_ _<u>[b70d2a7.](https://github.com/matter-labs/era-contracts/pull/627/commits/b70d2a78105716ac549103fac29be29b5a1b07ee)</u>_


ZKsync Custom Asset Bridge Audit − Low Severity − 13


### **L-05 Custom Assets May Not Be Withdrawable**

When assets are withdrawn through the <mark>`L2SharedBridge`</mark> <mark>,</mark> the asset handler for this asset

ID <u>[returns the bridge mint data](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2SharedBridge.sol#L125)</u> that will be <u>passed into the</u> <u><mark>`[bridgeMint](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L636)`</mark></u> <u>function</u> of the L1

asset handler. In the case of a native token vault, for example, the bridge mint data encodes

the amount and address of the L1 receiver. In an intermediate step, the shared bridge packs

the <mark>`finalizeWithdrawal`</mark> selector, asset ID, and bridge mint data into an L1 withdraw

message that is parsed in the <mark>`_parseL2WithdrawalMessage`</mark> function.


In this function, the L1 withdraw message is checked to be <u>[at least 56 bytes long. With the](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L684)</u>

selector being 4 bytes and the asset ID 32 bytes, this means that the bridge mint data has to

have 20 or more bytes. For the vast majority of custom asset handlers, this is expected to work

out because the L1 receiver address will likely be encoded in it. However, there might be edge

cases where less than 20 bytes are needed and, thus, the withdrawal will fail.


Consider checking the (minimum) expected length of the bridge mint data for each of the

<u>[message formats.](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L691-L715)</u>


**_Update:_** _Resolved in_ _<u>[pull request #628](https://github.com/matter-labs/era-contracts/pull/628)</u>_ _at commit_ _<u>[de49b6e.](https://github.com/matter-labs/era-contracts/pull/628/commits/de49b6ea22a1f629e81536f1b26ee83989342d25)</u>_

### **L-06 ETH’s L2StandardERC20 Representation** **Does Not Have name or symbol**


When bridging on L1 using the <mark>`L1NativeTokenVault`</mark> as asset handler, <u>[token metadata](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L153C75-L153C99)</u>

<mark>(</mark> <mark>`name`</mark> <mark>,</mark> <mark>`symbol`</mark> <mark>,</mark> <mark>`decimals`</mark> <mark>)</mark> is passed alongside the bridging information. This metadata is

decoded on L2 when <u>deploying a new</u> <u><mark>`[L2StandardERC20](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2StandardERC20.sol#L60-L101)`</mark></u> <mark>.</mark>


However, ETH metadata contains the name and symbol as <u><mark>`[bytes("Ether")](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L180-L181)`</mark></u> <u>and</u>

<u><mark>`[bytes("ETH")](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L180-L181)`</mark></u> respectively. These bytes arrays are not valid abi encoding and thus cannot

be decoded in the <u><mark>`[decodeString](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2StandardERC20.sol#L187-L189)`</mark></u> function of the <mark>`L2StandardERC20`</mark> contract. This means

the <mark>`L2StandardERC20`</mark> token representation of ETH on L2 would not have a <mark>`name`</mark> or

<mark>`symbol`</mark> metadata, which is unintended.


Consider abi-encoding the names instead of <u>[casting them to](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L180-L181)</u> <u><mark>`[bytes](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L180-L181)`</mark></u> when sending the

metadata for the ETH token.


**_Update:_** _Resolved in_ _<u>[pull request #629](https://github.com/matter-labs/era-contracts/pull/629)</u>_ _at commit_ _<u>[c68390a.](https://github.com/matter-labs/era-contracts/commit/c68390a887691d9948de6077742f3903baaebaaf)</u>_


ZKsync Custom Asset Bridge Audit − Low Severity − 14


### **L-07 Inaccurate Legacy Deposits Identification**

When a failed transfer is recovered, a <u>[check is performed](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L521)</u> to ensure that the transaction is not

an Era legacy deposit. This is done by checking <u>[the following condition:](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L573-L575)</u>

```
_l2BatchNumber < eraLegacyBridgeLastDepositBatch ||
(_l2BatchNumber == eraLegacyBridgeLastDepositBatch &&
_l2TxNumberInBatch < eraLegacyBridgeLastDepositTxNumber)

```

However, <mark>`eraLegacyBridgeLastDepositTxNumber`</mark> is <u>[defined](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L65)</u> as "The tx number in the

<mark>`_eraLegacyBridgeLastDepositBatch`</mark> of the last deposit tx initiated by the legacy

bridge". Thus, the very last transaction numbered

<mark>`eraLegacyBridgeLastDepositTxNumber`</mark> in batch number

<mark>`_eraLegacyBridgeLastDepositBatch`</mark> would be incorrectly identified as not being an Era

legacy deposit.


Consider changing the <u>`[<](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L574C37-L574C38)`</u> <u>[operator](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L574C37-L574C38)</u> to <mark>`<=`</mark> <mark>.</mark>


**_Update:_** _Resolved in_ _<u>[pull request #630](https://github.com/matter-labs/era-contracts/pull/630)</u>_ _at commit_ _<u>[c0749f4.](https://github.com/matter-labs/era-contracts/commit/c0749f408ddb5443a3ae5a1c4f447c104d00ff2e)</u>_

## **Notes & Additional** **Information**

### **N-01 Unused Code**


Throughout the codebase, several instances of unused or obsolete code were identified:


   - The following code is unused:

     - The <u><mark>`[onlySelf](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L51)`</mark></u> <u>modiferi</u> of <mark>`L1NativeTokenVault`</mark>

     - The <u><mark>`[IL2SharedBridgeLegacy](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/interfaces/IL2SharedBridgeLegacy.sol)`</mark></u> interface




- The following events are unused:




- <u><mark>`[AssetHandlerRegistered](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/interfaces/IL1SharedBridge.sol#L65)`</mark></u> of <mark>`IL1SharedBridge`</mark>

- <u><mark>`[AssetHandlerRegisteredInitial](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/interfaces/IL2SharedBridge.sol#L16)`</mark></u> of <mark>`IL2SharedBridge`</mark>




- The following imports are unused:




- The <u><mark>`[IL1ERC20Bridge](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2SharedBridge.sol#L8)`</mark></u> import in <mark>`L2SharedBridge.sol`</mark>




- The <u><mark>`[ILegacyL2SharedBridge](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2SharedBridge.sol#L11)`</mark></u> import in <mark>`L2SharedBridge.sol`</mark> (imported

twice)


ZKsync Custom Asset Bridge Audit − Notes & Additional Information − 15


- The following variables are unused:










<u><mark>`[ERA_CHAIN_ID](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L34)`</mark></u> of <mark>`L1NativeTokenVault`</mark>

<u><mark>`[hyperbridgingEnabled](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L89)`</mark></u> of <mark>`L1SharedBridge`</mark>

<u><mark>`[l1TokenAddress](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2SharedBridge.sol#L38)`</mark></u> of <mark>`L2SharedBridge`</mark>

<u><mark>`[l1Bridge](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2SharedBridge.sol#L42)`</mark></u> of <mark>`L2SharedBridge`</mark> . It is obsolete to maintain and use in the

<u><mark>`[onlyL1Bridge](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2SharedBridge.sol#L57)`</mark></u> <u>modiferi</u> because all calls to the <mark>`L2SharedBridge`</mark> are done



through the <mark>`L1SharedBridge`</mark> <u>[[1, 2, 3]. This deprecation will also make](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1ERC20Bridge.sol#L161)</u>

<u><mark>`[ERA_CHAIN_ID](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2SharedBridge.sol#L45)`</mark></u> of <mark>`L2SharedBridge`</mark> obsolete.


Consider removing any unused code. For state variables, consider marking them as

deprecated. Note that removing a state variable would shift the storage layout leading to

unexpected behavior with upgradeable contracts.


**_Update:_** _Resolved in_ _<u>[pull request #617](https://github.com/matter-labs/era-contracts/pull/617)</u>_ _at commit_ _<u>[1b0ce84. The Matter Labs team stated:](https://github.com/matter-labs/era-contracts/pull/617/commits/1b0ce84576f662fd39caf62e856a41168bb0dd9d)</u>_


_<mark>`_hyperbridgingEnabled`</mark>_ _<mark>,</mark>_ _<mark>`l1TokenAddress`</mark>_ _<mark>,</mark>_ _and_ _<mark>`l1Bridge`</mark>_ _are variables that_

_we have to keep for backwards compatibility, so marking it as Depracated would mean_

_we need to introduce a function for it._

### **N-02 Incorrect and Missing Documentation**


Throughout the codebase, several instances of incorrect documentation were identified:


   - The <mark>`onlyBridge`</mark> modifier of the <mark>`L1NativeTokenVault`</mark> contract permits the

<mark>`L1_SHARED_BRIDGE`</mark> to be the message sender instead of <u>[the documented bridgehub.](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L44)</u>

   - The <mark>`onlySelf`</mark> modifier is documented to be callable by the <u>["shared bridge itself"](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L50)</u>

whereas the contract is the <mark>`L1NativeTokenVault`</mark> <mark>.</mark>

   - The <u><mark>`[requestL2TransactionDirect](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridgehub/Bridgehub.sol#L254)`</mark></u> and <u><mark>`[requestL2TransactionTwoBridges](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridgehub/Bridgehub.sol#L295-L296)`</mark></u>

functions are documented with "the msg.sender has approved mintValue allowance for

the sharedBridge", whereas the allowance could also be given to the

<mark>`L1NativeTokenVault`</mark> <mark>.</mark>

   - The <mark>`createNewChain`</mark> function reverts with <u>["Bridgehub: weth bridge not set"](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridgehub/Bridgehub.sol#L151)</u> when the

<mark>`sharedBridge`</mark> address is not set which <u>[does not allow](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L109)</u> for WETH to be deposited.

   - The <mark>`_assetData`</mark> parameter of the <mark>`bridgeRecoverFailedTransfer`</mark> function is

documented as <u>["The amount of the deposit that failed", whereas](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L490)</u> <mark>`_assetData`</mark> is

<u>[expected to encode](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L525)</u> <mark>`uint256 amount`</mark> and <mark>`address prevMsgSender`</mark> <mark>.</mark>

  - The documentation of the <mark>`depositHappened`</mark> mapping says <u>["Tracks deposit](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L78)</u>

<u>[transactions from L2", whereas it should be "from L1" or "to L2". Furthermore, it](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L78)</u>


ZKsync Custom Asset Bridge Audit − Notes & Additional Information − 16


documents the <mark>`depositDataHash`</mark> in the <u>[legacy format](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L77)</u> with the token address and

amount instead of asset ID and transfer data.

  - The documentation of the <mark>`assetHandlerAddress`</mark> says <u>["A mapping l2 token address](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2SharedBridge.sol#L53)</u>

<u>[=> l1 token address", whereas it maps an asset ID to an L2 asset handler address.](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2SharedBridge.sol#L53)</u>

   - The <mark>`_getL1WithdrawMessage`</mark> function comment uses the

<u>"</u> <u><mark>`[IL1ERC20Bridge.finalizeWithdrawal](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2SharedBridge.sol#L144)`</mark></u> <u>function selector", whereas the function is</u>

using the <u><mark>`[IL1SharedBridge.finalizeWithdrawal](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2SharedBridge.sol#L147)`</mark></u> function selector.

   - The code documentation goes by the old branding of "zkSync" instead of "ZKsync".

   - The <u><mark>`[param mintValue](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/interfaces/IL1AssetHandler.sol#L35)`</mark></u> documentation is missing `@` and `_` .

   - The <u><mark>`[_mintValue](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L243)`</mark></u> variable is commented as being withdrawn by the "base token

bridge", whereas the shared bridge is in charge of depositing base tokens.

   - The <u>[documentation](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L202)</u> around the <mark>`setNativeTokenVault`</mark> was copied from the

<mark>`setL1Erc20Bridge`</mark> function and does not correspond to what the function is actually

doing.

   - The <u>[documentation](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L676-L681)</u> in the <mark>`_parseL2WithdrawalMessage`</mark> mentions that "there are

two versions of the message". However, the <mark>`if/else`</mark> flow control statement below has

three branches.

   - In the <u>[first branch](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L691-L697)</u> of the <mark>`_parseL2WithdrawalMessage`</mark> function, the message could

be sent by calling <mark>`withdrawWithMessage`</mark> on the <mark>`L2BaseToken`</mark> <mark>.</mark> Consider

documenting this extra possibility and the fact that in such a case, the <u>[extra arguments](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/system-contracts/contracts/L2BaseToken.sol#L93C81-L93C108)</u>

would be ignored.

   - The <u>[documentation](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/interfaces/IL1SharedBridge.sol#L133-L136)</u> around the <mark>`bridgehubDeposit`</mark> function in the

<mark>`IL1SharedBridge`</mark> interface only documents the legacy format for the <mark>`_data`</mark>

argument. The data could be encoded <u>[differently.](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L373)</u>

   - The <u>[NatSpec](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridgehub/Bridgehub.sol#L28)</u> above the <mark>`sharedBridge`</mark> state variable references it as being the "weth

bridge".

   - A <u>[comment](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridgehub/Bridgehub.sol#L157)</u> in the <mark>`createNewChain`</mark> function starts with "///" which is intended for

<u>[documentation. Consider replacing it with a normal comment.](https://docs.soliditylang.org/en/v0.8.24/natspec-format.html#documentation-example)</u>

  - The NatSpec above <mark>`setPendingAdmin`</mark> in the <mark>`IBridgeHub`</mark> interface says that "only

the current admin can propose a new pending one". However, the <u>[owner can also](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridgehub/Bridgehub.sol#L71C65-L71C81)</u>

<u>[propose a new admin.](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridgehub/Bridgehub.sol#L71C65-L71C81)</u>

   - The <u>[NatSpec](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2SharedBridge.sol#L119-L122)</u> above the <mark>`withdraw`</mark> function in the <mark>`L2SharedBridge`</mark> contract

documents the <mark>`_assetId`</mark> as "The L2 token address which is withdrawn".


In addition, the following instances of missing documentation were identified:


   - The <u><mark>`[getAssetId](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L249)`</mark></u> function is not documented.

   - The <u><mark>`[setAssetHandlerAddressInitial](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L215)`</mark></u> function documentation could be more

complete to guide custom asset handler developers.


ZKsync Custom Asset Bridge Audit − Notes & Additional Information − 17


   - The <u><mark>`[setAssetHandlerAddressOnCounterPart](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L223)`</mark></u> function is not documented.

   - The <u>[legacy functions](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2SharedBridge.sol#L161-L191)</u> in <mark>`L2SharedBridge`</mark> are not documented.

   - The <u><mark>`[setL2TokenBeacon](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2NativeTokenVault.sol#L89)`</mark></u> <mark>,</mark> <u><mark>`[bridgeMint](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2NativeTokenVault.sol#L95)`</mark></u> <mark>,</mark> and <u><mark>`[bridgeBurn](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2NativeTokenVault.sol#L122)`</mark></u> functions are not

documented.


To improve code clarity and readability, consider addressing the aforementioned instances of

incorrect and missing documentation.


**_Update:_** _Resolved in_ _<u>[pull request #623](https://github.com/matter-labs/era-contracts/pull/623)</u>_ _at commit_ _<u>[d85474c.](https://github.com/matter-labs/era-contracts/pull/623/commits/d85474c41bbb4cc8890185cf22f4c2a143f50d3f)</u>_

### **N-03 Code Redundancy**


Throughout the codebase, a few instances of redundant code were found:


   - The <u><mark>`[claimFailedDepositLegacyErc20Bridge](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L903)`</mark></u> <u>function</u> is redundant to the

<u><mark>`[claimFailedDeposit](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L749)`</mark></u> <u>function</u> except for the <mark>`_chainId`</mark> parameter. Consider calling

the <mark>`claimFailedDeposit`</mark> function from the legacy bridge while specifying the

<mark>`ERA_CHAIN_ID`</mark> as <mark>`_chainId`</mark> <mark>.</mark>

   - The <u><mark>`[bridgeRecoverFailedTransfer](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L222)`</mark></u> and <u><mark>`[bridgeMint](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L193)`</mark></u> function are identical

except for the address returned and <mark>`BridgeMint`</mark> event being emitted in the

<mark>`bridgeMint`</mark> function. Consider reusing the same logic to ease maintenance.

   - The <u><mark>`[getERC20Getters](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L722)`</mark></u> <u>function</u> in the <mark>`L1SharedBridge`</mark> is equally implemented in

the <u><mark>`[L1NativeTokenVault](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L178)`</mark></u> <mark>.</mark> Consider reusing the logic from a common library

implementation.


Consider applying the above suggestions to reduce the footprint of the codebase and make its

maintenance less error-prone.


**_Update:_** _Resolved in_ _<u>[pull request #634](https://github.com/matter-labs/era-contracts/pull/634)</u>_ _at commit_ _<u>[f43178f. The second bullet point is no longer](https://github.com/matter-labs/era-contracts/pull/634/commits/f43178f5154cbe61201628ed1fd52e5e596c3436)</u>_

_applicable with the H-01 fix._

### **N-04 Naming Suggestions**


Throughout the codebase, a few instances of contract members that could be better named

were found:


   - The <u><mark>`[transferBalancesFromSharedBridge](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L99)`</mark></u> and <u><mark>`[transferBalanceToNTV](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L190)`</mark></u>

functions do not transfer any tokens but instead update a mapping used for internal

accounting. Consider renaming them to <mark>`updateChainBalancesFromSharedBridge`</mark>

and <mark>`nullifyChainBalanceByNTV`</mark> or something similar.


ZKsync Custom Asset Bridge Audit − Notes & Additional Information − 18


   - The name of the <u><mark>`[_assetAddressOnCounterPart](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L230)`</mark></u> parameter of the

<mark>`setAssetHandlerAddressOnCounterPart`</mark> function suggests that it refers to the

token address, whereas the parameter is actually used to set the <u>[asset handler address](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2SharedBridge.sol#L152)</u>

on the L2 side. Consider renaming it to <mark>`_assetHandlerAddressOnCounterPart`</mark> <mark>.</mark>

   - The <u><mark>`[BridgehubDepositFinalized](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/interfaces/IL1SharedBridge.sol#L38)`</mark></u> event is emitted when the <u><mark>`[Bridgehub](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridgehub/Bridgehub.sol#L360)`</mark></u> <u>flow</u> is

completed on the L1 side, without guaranteeing its success on L2. However, "Finalized"

is usually used to refer to the successful completion of bridge operations on the

counterpart (e.g., the <u><mark>`[FinalizeDepositSharedBridge](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2SharedBridge.sol#L116)`</mark></u> or

<u><mark>`[WithdrawalFinalizedSharedBridge](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L639)`</mark></u> event). To prevent confusion, consider

renaming the event to <mark>`CompletedL1BridgehubDeposit`</mark> or something similar.


For improved code clarity, consider applying the above renaming suggestions.


**_Update:_** _Partially resolved in_ _<u>[pull request #635](https://github.com/matter-labs/era-contracts/pull/635)</u>_ _at commit_ _<u>[8a65222. The Matter Labs team](https://github.com/matter-labs/era-contracts/pull/635/commits/8a6522242a128ab02cb4e09edfb0965c82ddf64d)</u>_

_stated:_


_<mark>`BridgehubDepositFinalized`</mark>_ _renaming makes sense, but that event is already in_

_production so someone might rely on it, so I don't think we should change that. Fixed_

_the others._

### **N-05 Gas Optimizations**


Throughout the codebase, several opportunities for gas optimizations were identified:


   - In the <mark>`Bridgehub`</mark> <mark>,</mark> the <u><mark>`[secondBridgeAddress](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridgehub/Bridgehub.sol#L343)`</mark></u> <u>check</u> could be placed before the

<u><mark>`[bridgehubDeposit](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridgehub/Bridgehub.sol#L330-L331)`</mark></u> <u>call</u> to fail early and save some gas.

   - The usage of the <u><mark>`[MessageParams](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L603)`</mark></u> <u>struct</u> solely for the internal call between

<mark>`_finalizeWithdrawal`</mark> and <mark>`_checkWithdrawal`</mark> requires memory space to be

allocated, without making the code cleaner. Consider propagating the <u>[message data](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L604-L606)</u>

directly through function parameters.

  - The same <u><mark>`[baseTokenAssetId](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridgehub/Bridgehub.sol#L321)`</mark></u> storage variable is read twice in the

<mark>`requestL2TransactionTwoBridges`</mark> function.

   - The <u><mark>`[ntvAddress](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L176)`</mark></u> stack variable can be reused instead of re-reading

<mark>`nativeTokenVault`</mark> from storage.

   - The <u><mark>`[_l2ToL1message](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L674)`</mark></u> parameter can be handled in <mark>`calldata`</mark> <mark>.</mark>

   - The <mark>`ReentrancyGuard`</mark> could use transient storage introduced in <u>[EIP-1153. An](https://eips.ethereum.org/EIPS/eip-1153)</u>

inspiration can be found in <u>[OpenZeppelin's contracts library.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b6e07917eb3725e7a1304b01d8d9211b2b48526f/contracts/utils/ReentrancyGuardTransient.sol)</u>


Consider applying the above suggestions to make the code more gas efficient.


ZKsync Custom Asset Bridge Audit − Notes & Additional Information − 19


**_Update:_** _Resolved in_ _<u>[pull request #636](https://github.com/matter-labs/era-contracts/pull/636)</u>_ _at commit_ _<u>[8ec22b4. The Matter Labs team stated:](https://github.com/matter-labs/era-contracts/pull/636/commits/8ec22b436fd20198b3d9057c7b99f688f9ef59c8)</u>_


_<mark>`MessageParams`</mark>_ _were needed because of stackTooDeep issues._ _<mark>`_l2ToL1message`</mark>_

_needs to be in memory as it is handled by_ _<mark>`readRemainingBytes`</mark>_ _<mark>.</mark>_ _TransientStorage_

_for_ _<mark>`ReentrancyGuard`</mark>_ _is true, however optimising that is out of scope for now, we did_

_not write that contract for this upgrade._

### **N-06 Misleading Error**


The <u><mark>`[AssetIdMismatch](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/L2ContractErrors.sol#L12)`</mark></u> <u>error</u> reverts with two <mark>`bytes32`</mark> values, which are the expected and

supplied asset IDs. However, in the <mark>`bridgeMint`</mark> function where the <u>[error is used, the](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2NativeTokenVault.sol#L106)</u>

parameters are given in reverse order, with the expected asset ID coming second.


Consider swapping the variable order in the emitted event to prevent confusion when

interpreting the output.


**_Update:_** _Resolved in_ _<u>[pull request #637](https://github.com/matter-labs/era-contracts/pull/637)</u>_ _at commit_ _<u>[e482840.](https://github.com/matter-labs/era-contracts/pull/637/commits/e4828404439005ee4e34fd431466f7a4ce20101a)</u>_

### **N-07 Unreachable Code**


Before the changes being audited were made, the bridge contracts referred to assets by their

token address. This was changed by referring to the asset ID. To maintain backwards

compatibility when <u>[depositing a base token, the](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L260)</u> <u><mark>`[_getAssetProperties](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L285)`</mark></u> <u>function</u> takes the

input in either format (padded token address or asset ID) and returns the asset handler and ID.


However, the <u><mark>`[bridgehubDepositBaseToken](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L260)`</mark></u> <u>function</u> is always called with a valid asset ID

<u>[[1, 2, 3], while also conforming to the right interface. Thus, since the asset ID cannot be a](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridgehub/Bridgehub.sol#L270)</u>

padded token address, the deposit call would always revert on the <u>[address check](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L293)</u> if a base

token is not yet registered. In other words, the <u><mark>`[registerToken](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L295)`</mark></u> <u>call</u> cannot be reached.


Consider simplifying the <mark>`bridgehubDepositBaseToken`</mark> function by checking that the asset

ID has a registered handler and reverting otherwise. It is a good practice to keep the code self
contained (e.g., to expect that a token was previously registered instead of invoking the

registration within the same call).


**_Update:_** _Resolved in_ _<u>[pull request #638](https://github.com/matter-labs/era-contracts/pull/638)</u>_ _at commit_ _<u>[23fcec7. The code was simplified by](https://github.com/matter-labs/era-contracts/pull/638/commits/23fcec7f3339d61dca7e5ac926283e2fe796b066)</u>_

_removing the_ _<mark>`_getAssetProperties`</mark>_ _function._


ZKsync Custom Asset Bridge Audit − Notes & Additional Information − 20


### **N-08 Typographical Errors**

There is a typographical error in the <mark>`IL1NativeTokenVault`</mark> interface, where <u>["Used to get](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/interfaces/IL1NativeTokenVault.sol#L24)</u>

<u>[the the ERC20 data for a token"](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/interfaces/IL1NativeTokenVault.sol#L24)</u> has one extra "the".


To improve code readability, consider correcting any typographical errors.


**_Update:_** _Resolved in_ _<u>[pull request #631](https://github.com/matter-labs/era-contracts/pull/631)</u>_ _at commit_ _<u>[8e114ec.](https://github.com/matter-labs/era-contracts/commit/8e114eceae301bcbcd8e2504968234733674b4ab)</u>_

### **N-09 Misleading Function Name**


The <u><mark>`[l2TokenAddress](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2SharedBridge.sol#L194)`</mark></u> <u>function</u> of the <mark>`L2SharedBridge`</mark> contract returns the calculated L2

counterpart address of an L1 token address, assuming it was deployed through the

<mark>`L2NativeTokenVault`</mark> <mark>.</mark> However, as the shared bridge can use custom asset handlers, or an

L1 token may not have an L2 counterpart, this function's name can be misleading.


Consider checking that the L1 token is indeed part of the L2 native token vault, and clarifying

the behavior of the function in the documentation.


**_Update:_** _Resolved in_ _<u>[pull request #642](https://github.com/matter-labs/era-contracts/pull/642)</u>_ _at commit_ _<u>[0d0e218. Documentation was added to raise](https://github.com/matter-labs/era-contracts/commit/0d0e218d59dcaad77b5828d84175d83a163ad7ae)</u>_

_awareness about the potentially misleading return value._

### **N-10 Lack of Security Contact**


Providing a specific security contact (such as an email or ENS name) within a smart contract

significantly simplifies the process for individuals to communicate if they identify a vulnerability

in the code. This practice is beneficial as it permits the code owners to dictate the

communication channel for vulnerability disclosure, eliminating the risk of miscommunication

or failure to report due to a lack of knowledge on how to do so. In addition, if the contract

incorporates third-party libraries and a bug surfaces in those, it becomes easier for their

maintainers to contact the appropriate person about the problem and provide mitigation

instructions.


Throughout the codebase, there are several instances of contracts not having a security

contract:


   - The <u><mark>`[IBridgehub](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridgehub/IBridgehub.sol)`</mark></u> <u>interface</u>

   - The <u><mark>`[IL1ERC20Bridge](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/interfaces/IL1ERC20Bridge.sol)`</mark></u> <u>interface</u>

   - The <u><mark>`[IL2AssetHandler](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/interfaces/IL2AssetHandler.sol)`</mark></u> <u>interface</u>

   - The <u><mark>`[IL2Bridge](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/interfaces/IL2Bridge.sol)`</mark></u> <u>interface</u>


ZKsync Custom Asset Bridge Audit − Notes & Additional Information − 21


   - The <u><mark>`[IL2BridgeLegacy](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/interfaces/IL2BridgeLegacy.sol)`</mark></u> <u>interface</u>

   - The <u><mark>`[IL2NativeTokenVault](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/interfaces/IL2NativeTokenVault.sol)`</mark></u> <u>interface</u>

   - The <u><mark>`[IL2SharedBridge](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/interfaces/IL2SharedBridge.sol)`</mark></u> <u>interface</u>

   - The <u><mark>`[IL2SharedBridgeLegacy](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/interfaces/IL2SharedBridgeLegacy.sol)`</mark></u> <u>interface</u>

   - The <u><mark>`[ILegacyL2SharedBridge](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/interfaces/ILegacyL2SharedBridge.sol)`</mark></u> <u>interface</u>


Consider adding a NatSpec comment containing a security contact above each contract

definition. Using the <mark>`@custom:security-contact`</mark> convention is recommended as it has

been adopted by the <u>[OpenZeppelin Wizard](https://wizard.openzeppelin.com/)</u> and the <u>[ethereum-lists.](https://github.com/ethereum-lists/contracts#tracking-new-deployments)</u>


**_Update:_** _Resolved in_ _<u>[pull request #641](https://github.com/matter-labs/era-contracts/pull/641)</u>_ _at commit_ _<u>[040026b.](https://github.com/matter-labs/era-contracts/commit/040026b48ae03563b61c0d1dd1b79b22a5838018)</u>_

### **N-11 Incomplete and Mismatching Interfaces**


Throughout the codebase, several instances of interface mismatches were identified:


   - The <u><mark>`[_msgSender](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/interfaces/IL1SharedBridge.sol#L74)`</mark></u> parameter is implemented as <u><mark>`[_prevMsgSender](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L805)`</mark></u> <mark>.</mark>

   - The <u><mark>`[_tokenData](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/interfaces/IL1SharedBridge.sol#L169)`</mark></u> parameter is implemented as <u><mark>`[_assetData](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L501)`</mark></u> <mark>.</mark>

   - The <u><mark>`[_baseToken](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridgehub/IBridgehub.sol#L61)`</mark></u> parameter is implemented as <u><mark>`[_token](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridgehub/Bridgehub.sol#L34)`</mark></u> <mark>.</mark>

   - The <u><mark>`[l1TokenAddress](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/interfaces/IL1NativeTokenVault.sol#L22)`</mark></u> parameter is implemented as <u><mark>`[_l1TokenAddress](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L249)`</mark></u> <mark>.</mark>

   - The <u><mark>`[l1Token](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/interfaces/IL1SharedBridge.sol#L112)`</mark></u> return parameter is implemented as <u><mark>`[l1Asset](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L878)`</mark></u> <mark>.</mark>

   - The <mark>`txHash`</mark> [named return parameters [1, 2] are implemented as](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/interfaces/IL1ERC20Bridge.sol#L34-L42) <mark>`l2TxHash`</mark> <u>[[3, 4, 5].](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1ERC20Bridge.sol#L113)</u>

   - The <u><mark>`[_l2Token](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/interfaces/IL2SharedBridge.sol#L35)`</mark></u> parameter is implemented as <u><mark>`[l2TokenAddress](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2SharedBridge.sol#L38)`</mark></u> <mark>.</mark>

   - The <mark>`finalizeDeposit`</mark> function <mark>`_data`</mark> [parameter [1, 2] is implemented as](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/interfaces/IL2Bridge.sol#L7)

<mark>`_transferData`</mark> <u>[[3, 4] and the](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2SharedBridge.sol#L107)</u> <mark>`withdraw`</mark> function <u><mark>`[_data](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/interfaces/IL2SharedBridge.sol#L27)`</mark></u> parameter is implemented

as <u><mark>`[_assetData](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2SharedBridge.sol#L123)`</mark></u> <mark>.</mark>

   - Leading underscores on mapping variables are inconsistent. The <u><mark>`[Bridgehub](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridgehub/Bridgehub.sol#L31-L49)`</mark></u> and

interface getters have leading underscores, while most contracts do not. This makes

[such contracts inconsistent with other contracts as well as their own interfaces (1.1, 1.2),](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L74-L104)

<u>[(2), (3.1, 3.2), (4.1, 4.2).](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L36-L42)</u>

   - The legacy <u><mark>`[withdraw](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/interfaces/IL2Bridge.sol#L9)`</mark></u> <mark>,</mark> <u><mark>`[l2TokenAddress](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/interfaces/IL2Bridge.sol#L13)`</mark></u> <mark>,</mark> and <u><mark>`[l1TokenAddress](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/interfaces/IL2Bridge.sol#L11)`</mark></u> functions should

be defined in the <u><mark>`[IL2BridgeLegacy](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/interfaces/IL2BridgeLegacy.sol)`</mark></u> interface. However, instead of the new

<u><mark>`[withdraw](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2SharedBridge.sol#L123)`</mark></u> function, the legacy <u><mark>`[withdraw](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/interfaces/IL2Bridge.sol#L9)`</mark></u> function has been defined in the

<mark>`IL2Bridge`</mark> interface.

   - The legacy <u><mark>`[getL1TokenAddress](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2SharedBridge.sol#L189)`</mark></u> function is not defined in

<u><mark>`[ILegacyL2SharedBridge](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/interfaces/ILegacyL2SharedBridge.sol#L6)`</mark></u> <mark>.</mark>

   - The <u><mark>`[baseTokenAssetId](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/state-transition/chain-deps/ZkSyncHyperchainStorage.sol#L155)`</mark></u> Diamond Proxy storage variable has no <u><mark>`[Getters](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/state-transition/chain-deps/facets/Getters.sol)`</mark></u> <u>facet</u>

function.


ZKsync Custom Asset Bridge Audit − Notes & Additional Information − 22


   - The <u><mark>`[chainBalance](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L39)`</mark></u> public variable is missing a function in the

<u><mark>`[IL1NativeTokenVault](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/interfaces/IL1NativeTokenVault.sol#L11)`</mark></u> interface.

   - The <u><mark>`[depositAmount](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/interfaces/IL1ERC20Bridge.sol#L74-L78)`</mark></u> function should be defined as a <mark>`view`</mark> function.


Consider correcting the above interface mismatches to improve the code clarity.


**_Update:_** _Resolved in_ _<u>[pull request #633](https://github.com/matter-labs/era-contracts/pull/633)</u>_ _at commit_ _<u>[f80c0fb.](https://github.com/matter-labs/era-contracts/commit/f80c0fb992f5780ad1aa8bb929808e45624682c4)</u>_

### **N-12 Code Quality and Readability Suggestions**


The following opportunities to improve the codebase were identified:


   - The <mark>`bridgehubDepositBaseToken`</mark> is marked as <u><mark>`[virtual](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L265C24-L265C31)`</mark></u> <mark>.</mark> If there is no intention of

overriding it, consider removing the <mark>`virtual`</mark> attribute.

   - The <mark>`_assetId`</mark> argument of the <u><mark>`[bridgehubDepositBaseToken](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L262)`</mark></u> function could, in

theory, be an address padded to 32 bytes and handled by <mark>`_getAssetProperties`</mark>

which returns the computed <mark>`assetId`</mark> <mark>.</mark> However, the original padded <mark>`_assetId`</mark>

argument is <u>[emitted. Consider replacing the argument to emit](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L278C75-L278C83)</u> <mark>`assetId`</mark> <mark>.</mark> In addition, if

supporting <u><mark>`[bytes32](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L262)`</mark></u> <u>arguments</u> with padded addresses is desired and to avoid such

issues, consider renaming the argument to clarify this possibility (e.g., to

<mark>`_assetIdOrLegacyAddr`</mark> <mark>)</mark> .

   - A <u><mark>`[try/catch](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L366-L374)`</mark></u> around <mark>`this.handleLegacyData`</mark> is used to check if the data could

be decoded in the legacy format. However, calls to <mark>`this.handleLegacyData`</mark> can

revert for reasons other than unsuccessful decoding (e.g., if the token address is <u>[WETH,](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L109-L110)</u>

<u>[or does not have code). If support for a legacy data format is desired, consider replacing](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1NativeTokenVault.sol#L109-L110)</u>

the <mark>`handleLegacyData`</mark> function with a <mark>`decodeLegacyData`</mark> <mark>`external`</mark> function

that only handles the decoding of the parameters. The rest of the function handling the

data could be done in an <mark>`internal`</mark> function called in the <u>[success branch of the](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L369-L372)</u> <u><mark>`[try/](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L369-L372)`</mark></u>

<u><mark>`[catch](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L369-L372)`</mark></u> to bubble up errors.

   - The <mark>`finalizeDeposit`</mark> has a <u>commented-out</u> <u><mark>`[onlyBridge](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/L2SharedBridge.sol#L168)`</mark></u> <u>modifier</u> which could be

removed.

   - The order of functions within the contracts does not adhere to the <u>[Solidity Style Guide.](https://docs.soliditylang.org/en/latest/style-guide.html#order-of-functions)</u>

   - The <u><mark>`[amount](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L685-L686)`</mark></u> <u>and</u> <u><mark>`[l1Receiver](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L685-L686)`</mark></u> stack variables could be only declared in the scope

they are used in, while the commented-out variables <u><mark>`[l1ReceiverBytes](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L687-L688)`</mark></u> <u>and</u>

<u><mark>`[parsedL1Receiver](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L687-L688)`</mark></u> can be removed.

   - There is an unspecified <u><mark>`[//todo](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L713)`</mark></u> in the <mark>`_parseL2WithdrawalMessage`</mark> function.

   - The <u><mark>`[FinalizeDepositSharedBridge](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/interfaces/IL2SharedBridge.sol#L7-L14)`</mark></u> <u>and</u>

<u><mark>`[WithdrawalInitiatedSharedBridge](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/interfaces/IL2SharedBridge.sol#L7-L14)`</mark></u> events emit the hash of asset data as one of

their parameters. This does not appear to be very useful as the pre-image is rather


ZKsync Custom Asset Bridge Audit − Notes & Additional Information − 23


interesting as information compared to its hash. Consider emitting the pre-image <mark>`bytes`</mark>

data.

   - The parameters of the <u><mark>`[L2TokenBeaconUpdated](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l2-contracts/contracts/bridge/interfaces/IL2NativeTokenVault.sol#L24)`</mark></u> event could be indexed as they are

used for address derivation in new token deployments.


Consider applying the aforementioned suggestions to improve the clarity of the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #640](https://github.com/matter-labs/era-contracts/pull/640)</u>_ _at commit_ _<u>[8cec7bb. The second bullet point was](https://github.com/matter-labs/era-contracts/pull/640/commits/8cec7bbe006042071fa45468dbe6fcd50c10e638)</u>_

_addressed with N-07. Regarding the_ _<mark>`_handleLegacyData`</mark>_ _function, an encoding version_

_byte is now prefixing the_ _<mark>`_data`</mark>_ _parameter as differentiation for non-legacy deposits. The_

_<mark>`_handleLegacyData`</mark>_ _function now has_ _<mark>`internal`</mark>_ _visibility and is regularly invoked._

### **N-13 Lack of Input Validation on Emitted Data**


The <u><mark>`[_depositSender](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L499)`</mark></u> <u>argument</u> of the <mark>`bridgeRecoverFailedTransfer`</mark> function is user
controlled and not validated by the function. The function decodes and validates

<u><mark>`[prevMsgSender](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L525)`</mark></u> which plays a similar role but does not validate <mark>`_depositSender`</mark> <mark>.</mark> This

could cause the wrong information to be emitted in the

<u><mark>`[ClaimedFailedDepositSharedBridge](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L533C57-L533C71)`</mark></u> event.


Consider removing <mark>`_depositSender`</mark> from the interface and replacing it with

<mark>`prevMsgSender`</mark> in the event parameters.


**_Update:_** _Resolved in_ _<u>[pull request #619](https://github.com/matter-labs/era-contracts/pull/619)</u>_ _at commit_ _<u>[16241e4. The](https://github.com/matter-labs/era-contracts/pull/619/commits/16241e4616075d53de9a958c3a4eb107bfe28e3c)</u>_ _<mark>`_depositSender`</mark>_ _argument_

_is now used to check the transaction data hash and is forwarded to the_

_<mark>`bridgeRecoverFailedTransfer`</mark>_ _function of the asset handler to receive the funds._

### **N-14 Padded Token Address as Asset ID Is** **Registered Redundantly on Base Token Deposits**


The <u><mark>`[_getAssetProperties](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L285)`</mark></u> function can be provided an <mark>`address`</mark> padded to 32 bytes as

its <mark>`_assetId`</mark> argument for backwards compatibility. In this case, <mark>`assetId`</mark> is computed as
```
keccak256(abi.encode(block.chainid,
```

<mark>`NATIVE_TOKEN_VAULT_VIRTUAL_ADDRESS, _assetId))`</mark> <mark>.</mark>


However, when querying the asset handler address for such assets, the <u>[padded address is](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L290C46-L290C54)</u>

<u>[used in place of the](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L290C46-L290C54)</u> <u><mark>`[assetId](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L290C46-L290C54)`</mark></u> <mark>.</mark> This means that the asset handler would always be 0 and the

token would be <u>[re-registered](https://github.com/matter-labs/era-contracts/blob/d397b7f0b4d608d20d403554a30e3659a326309b/l1-contracts/contracts/bridge/L1SharedBridge.sol#L292-L296)</u> on each bridging transaction.


ZKsync Custom Asset Bridge Audit − Notes & Additional Information − 24


Consider replacing <mark>`_assetId`</mark> by <mark>`assetId`</mark> when fetching the asset handler address. This

will help avoid re-registering the asset and save gas.


**_Update:_** _Resolved in_ _<u>[pull request #639](https://github.com/matter-labs/era-contracts/pull/639)</u>_ _at commit_ _<u>[d41438d. The code was simplified by](https://github.com/matter-labs/era-contracts/pull/639/commits/d41438d73d7f4c754f60b51a7585565f2a53dbdd)</u>_

_removing the_ _<mark>`_getAssetProperties`</mark>_ _function._


ZKsync Custom Asset Bridge Audit − Notes & Additional Information − 25


## **Conclusion**

The audited code updates the ZKsync bridge contracts by adding support for custom asset

handlers. Such handlers can be used to support more token types with the addition of custom

logic on mints and burns. A canonical asset handler supporting ETH and simple ERC-20

tokens, called the native token vault, was also added.


We commend the Matter Labs team on their effort to ensure backwards compatibility with

previous interfaces and integrations, but note that it adds significant complexity to the

codebase. The high-level design of the code seems well thought out, though we found issues

which could have been caught by additional tests. We also made multiple recommendations to

enhance the quality of the codebase.


We thank the Matter Labs team for their responsiveness and for providing us with

documentation explaining the changes introduced by the update.


ZKsync Custom Asset Bridge Audit − Conclusion − 26


