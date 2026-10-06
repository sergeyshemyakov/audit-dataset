### | security

# **Mantle V2** **Solidity** **Contracts Audit**

#### **March 15, 2024**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  4


Scope ____________________________________________________________________________  5


System Overview __________________________________________________________________  7

Bridges 8

Messengers 8

Portal and Message Passer 8


Privileged Roles _________________________________________________________________ 10


Security Model and Trust Assumptions _____________________________________________ 10


Critical Severity __________________________________________________________________ 12

C-01 BVM_ETH and MNT Deposited in Messengers Can Be Stolen 12


Medium Severity _________________________________________________________________ 13

M-01 Cross Domain Messengers Can Fail in Relaying a Message 13

M-02 Gas Estimation Can Fail in finalizeWithdrawalTransaction 14

M-03 Unnecessary Payable Function Definition 15


Low Severity ____________________________________________________________________ 16

L-01 Assets Might Get Stuck in Contracts 16

L-02 Unusual Upgradeability Patterns Are Adopted 17

L-03 Wrong Value Emitted in Event 18

L-04 Incomplete Docstrings 18

L-05 Floating and Multiple Pragma Directives Are Being Used 19

L-06 Unsafe ABI Encoding 20

L-07 Missing Docstrings 20


Notes & Additional Information ____________________________________________________ 21

N-01 Unnecessary Boolean Values 21

N-02 Misleading Docstrings 22

N-03 Duplicated Getter Function 22

N-04 public Functions Can Be Declared as external 23

N-05 Code Style Inconsistency 23

N-06 Typographical Errors 23

N-07 Variables Naming Does Not Follow Solidity Style Guide 24

N-08 Use of Magic Constants 24

N-09 Usage of Single Step Ownership Transfer 24


Mantle V2 Solidity Contracts Audit − Table of Contents − 2


N-10 Lack of Indexed Event Parameters 25

N-11 Lack of Security Contact 25

N-12 Unnecessary Cast 25

N-13 Unused Code 26

N-14 Addresses of Predeploys Are Not Ordered 26

N-15 Address Is Being Removed Twice 26

N-16 Predeployed Contracts Missing Custom Documentation Tag 27

N-17 Unused Import 27

N-18 Duplicate Event Emission 27


Conclusion ______________________________________________________________________ 28


Mantle V2 Solidity Contracts Audit − Table of Contents − 3


## **Summary**

**Type** L2 Rollup


**Timeline** From 2024-01-31
To 2024-03-01


**Languages** Solidity



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



1 (1 resolved)


0 (0 resolved)


3 (3 resolved)



**Total Issues** 29 (12 resolved, 1 partially resolved)



**Low Severity Issues** 7 (1 resolved)



**Notes & Additional**
**Information**



18 (7 resolved, 1 partially resolved)



Mantle V2 Solidity Contracts Audit − Summary − 4


## **Scope**

We audited the <u>[mantlenetworkio/mantle-v2](https://github.com/mantlenetworkio/mantle-v2)</u> repository at commit <u>[e29d360.](https://github.com/mantlenetworkio/mantle-v2/commit/e29d360904db5e5ec81888885f7b7250f8255895)</u>


In scope were the following files:

```
packages/contracts-bedrock/contracts
├── L1
│  ├── L1CrossDomainMessenger.sol
│  ├── L1ERC721Bridge.sol
│  ├── L1StandardBridge.sol
│  ├── L2OutputOracle.sol
│  ├── OptimismPortal.sol
│  ├── ResourceMetering.sol
│  └── SystemConfig.sol
└── L2
│  ├── BaseFeeVault.sol
│  ├── BVM_ETH.sol
│  ├── CrossDomainOwnable.sol
│  ├── CrossDomainOwnable2.sol
│  ├── CrossDomainOwnable3.sol
│  ├── GasPriceOracle.sol
│  ├── L1Block.sol
│  ├── L1FeeVault.sol
│  ├── L2CrossDomainMessenger.sol
│  ├── L2ERC721Bridge.sol
│  ├── L2StandardBridge.sol
│  ├── L2ToL1MessagePasser.sol
│  └── SequencerFeeVault.sol

```

In addition, we also performed a limited review of the contracts listed below as they are

dependencies of above in-scope contracts. As a result, some low- and note-level issues were

raised. However, a full audit of these files was not performed.

```
├── universal
│  ├── ERC721Bridge.sol
│  ├── StandardBridge.sol
│  ├── CrossDomainMessenger.sol
│  ├── OptimismMintableERC20.sol
│  ├── Semver.sol
│  └── FeeVault.sol

```

Finally, the following files were audited exclusively in terms of differences with the base commit

<u>[bb0ff70:](https://github.com/mantlenetworkio/mantle-v2/commit/bb0ff7002520ee936101c4c263ac02a66e7e3c96)</u>


Mantle V2 Solidity Contracts Audit − Scope − 5


```
├── deployment
│  ├── PortalSender.sol
│  ├── SystemDictator.sol
├── legacy
│  └── LegacyERC20MNT.sol
├── libraries
│  ├── Burn.sol
│  ├── Encoding.sol
│  ├── Hashing.sol
│  ├── Predeploys.sol
│  ├── Types.sol

```


Mantle V2 Solidity Contracts Audit − Scope − 6


## **System Overview**

Mantle V2 is a layer 2 (L2) scaling solution for Ethereum that uses fraud proofs instead of

validity proofs for its security. The protocol aims to provide low transaction fees and high

throughput while maintaining full EVM compatibility. Mantle V2 is built on top of Ethereum

using the OP Stack and therefore shares many similarities with Optimism. As far as the

differences are concerned, the most important one is the native currency used in L2 being

changed from ETH to the Mantle Token (MNT). MNT is an ERC-20 token on the Ethereum

mainnet becaue of which the code has to be adapted. Prior to going into the details of all the

specific changes, it is worth summarizing what the Mantle v2 stack is and how it works. The

system is based on two main directories of contracts, namely the <mark>`L1`</mark> and <mark>`L2`</mark> directories.


As the name suggests, the <mark>`L1`</mark> directory will contain contracts that manage the following:


  - ERC-20, ERC-721, MNT, and ETH deposit into the L1 contracts.

   - Event <u>[emission](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L507)</u> for L2 bridging finalization.

   - Additional features to <u>[prove](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L253)</u> and <u>[finalize](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L336)</u> a withdrawal transaction (the inverse action of

depositing into L2).

   - Auxiliary contracts like the <mark>`ResourceMetering`</mark> <u>[contract](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/ResourceMetering.sol)</u> to handle gas unit

measurements according to EIP-1559, the <mark>`L2OutputOracle`</mark> <u>[contract](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L2OutputOracle.sol)</u> that hosts

finalized state roots of L2 blocks, and the <mark>`SystemConfig`</mark> <u>[contract](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/SystemConfig.sol)</u> which serves merely

to retrieve system configurations of different parameters.


On the other hand, the <mark>`L2`</mark> directory will contain contracts that manage the following:


   - Initialization of ERC-20, ERC-721, MNT, and ETH withdrawals.

  - Finalization of ERC-20, ERC-721, MNT, and ETH deposits.

   - Fee vaults where <u>[base fees, sequencer fees, and the](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/BaseFeeVault.sol)</u> <u>[l1 portion of the transaction fees](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L1FeeVault.sol)</u>

are accumulated.

   - Auxiliary contracts like the <u><mark>`[GasPriceOracle](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/GasPriceOracle.sol)`</mark></u> <mark>,</mark> where the relation of price between MNT

and ETH is managed <u>by a</u> <u><mark>`[tokenRatio](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/GasPriceOracle.sol#L29)`</mark></u> <u>parameter</u> and L1 block information can be

retrieved thanks to the information stored in the <mark>`L1Block`</mark> <u>[contract, and the](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L1Block.sol)</u> <u>[ownable](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/CrossDomainOwnable.sol)</u>

<u>[contracts](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/CrossDomainOwnable.sol)</u> that are meant to manage cross-domain ownership interactions.


The three main parts of both <mark>`L1`</mark> and <mark>`L2`</mark> are the following:


Mantle V2 Solidity Contracts Audit − System Overview − 7


### **Bridges**

On L1, ERC-20 assets, MNT tokens, and ETH are managed through the <mark>`L1StandardBridge`</mark>

<u>[contract, while ERC-721 assets are managed through the](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1StandardBridge.sol)</u> <mark>`L1ERC721Bridge`</mark> <u>[contract. On L2,](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1ERC721Bridge.sol)</u>

equivalent contracts are found, namely the <u><mark>`[L2StandardBridge](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2StandardBridge.sol)`</mark></u> and <u><mark>`[L2ERC721Bridge](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2ERC721Bridge.sol)`</mark></u>

contracts.


Both bridges have functions in common to initialize asset transfers to the opposite domain like

the <u><mark>`[bridgeMNT](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1StandardBridge.sol#L562)`</mark></u> <mark>,</mark> <u><mark>`[bridgeERC20](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1StandardBridge.sol#L599)`</mark></u> <mark>,</mark> <u><mark>`[bridgeETH](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1StandardBridge.sol#L526)`</mark></u> or <u><mark>`[bridgeERC721](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/ERC721Bridge.sol#L127)`</mark></u> functions, and to finalize

bridging from the opposite domain like the <u><mark>`[finalizeBridgeERC20](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1StandardBridge.sol#L693)`</mark></u> <mark>,</mark> <u><mark>`[finalizeBridgeMNT](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1StandardBridge.sol#L662)`</mark></u> <mark>,</mark>

<u><mark>`[finalizeBridgeETH](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1StandardBridge.sol#L662)`</mark></u> or <u><mark>`[finalizeBridgeERC721](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2ERC721Bridge.sol#L46)`</mark></u> <mark>.</mark> ERC-20 and ERC-721 assets are

locked within the bridge contracts, whereas MNT and ETH are transferred to the

<mark>`L1CrossDomainMessenger`</mark> / <mark>`L2CrossDomainMessenger`</mark> contracts when bridging to the

other domain, or are transferred from them when finalizing a bridge to the current domain.

### **Messengers**


The <u><mark>`[L1CrossDomainMessenger](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1CrossDomainMessenger.sol)`</mark></u> and <u><mark>`[L2CrossDomainMessenger](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2CrossDomainMessenger.sol)`</mark></u> contracts are merely

intermediaries between bridges and the <mark>`OptimismPortal`</mark> / <mark>`L2toL1MessagePasser`</mark> <mark>.</mark>

Messengers do not distinguish between assets and the only thing they do is pass arbitrary

<u>[encoded messages](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1StandardBridge.sol#L875)</u> together with <u>[MNT](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1CrossDomainMessenger.sol#L75)</u> or ETH. When bridging over to the other domain, the

<mark>`sendMessage`</mark> <u>[functions](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1CrossDomainMessenger.sol#L68-L143)</u> are triggered, whereas when finalizing a bridge from another domain,

the <mark>`relayMessage`</mark> <u>[functions](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1CrossDomainMessenger.sol#L158)</u> are called. The target of any <mark>`sendMessage`</mark> call is the

<u><mark>`[OptimismPortal](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1CrossDomainMessenger.sol#L62)`</mark></u> / <u><mark>`[L2toL1MessagePasser](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2CrossDomainMessenger.sol#L65)`</mark></u> <mark>,</mark> whereas the target of a <mark>`relayMessage`</mark>

execution is usually a bridge contract.

### **Portal and Message Passer**


The <mark>`OptimismPortal`</mark> (portal) contract is the final point in the L1 execution when depositing

assets from L1 to L2, whereas the <mark>`L2toL1MessagePasser`</mark> contract is the final point for

withdrawing from L2 to L1. These contracts emit <u>[events](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2ToL1MessagePasser.sol#L137)</u> whose parameters are the encoded

messages of the assets being transferred. One notable difference between the two is that

<mark>`OptimismPortal`</mark> hosts the <u>[mechanism](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L253-L435)</u> to prove and finalize any withdrawal transaction from

L2-to-L1, while the <mark>`L2toL1MessagePasser`</mark> merely passes messages from L2-to-L1. The

verification of withdrawal transactions is where L2 state roots are <u>[used](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L269)</u> to <u>[ensure](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L309)</u> that the

withdrawal transaction has been effectively triggered on L2 first. The <mark>`OptimismPortal`</mark> and

the <mark>`L2toL1MessagePasser`</mark> contracts are the ones effectively holding MNT and ETH on both

domains.


Mantle V2 Solidity Contracts Audit − System Overview − 8


The reason behind this is that one can skip the entire flow of passing from bridges to

messengers and target them directly, thereby saving gas. However, it is a less user-friendly flow

to follow and is also error-prone. Moreover, users can also only skip the bridges and send

arbitrary data through the messengers. Messengers will pass the execution to the portal or to

the message passer on L2. The main difference introduced by Mantle v2 is changing the native

currency on L2 from ETH to MNT. This means that ETH is converted into an ERC-20 asset on

L2, specifically into an <u>[instance](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/BVM_ETH.sol)</u> of an <mark>`OptimismMintableERC20`</mark> token. This comes with

some nuances:


   - A deposit transaction transfers ERC-20 MNT into the L1 system, whereas on the L2, it is

the native currency. MNT, as the native currency, is minted at the protocol level before

the L2 finalization executes, as would be the case for ETH in the original Optimism code.

   - ETH is transferred into the L1 system which is accounted for by an ERC-20 WETH token

mint into the L2 system. WETH is first minted and then transferred to the initiator of L2

deposit finalization. The minting process is performed at the protocol level.


When bridging from L2 to L1:


   - The native MNT is collected into the L2 system and <u>[burned at a later stage](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2ToL1MessagePasser.sol#L98)</u> through a

contract that self-destructs at construction time, effectively removing the native currency

from circulation. The corresponding amount of the ERC-20 Mantle token is then released

on the L1 system.

   - The WETH is first <u>[burned](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2ToL1MessagePasser.sol#L120)</u> on L2 and then released on L1 as native currency. In contrast

to the minting process, the burning process happens at the contract level.


Since the MNT-to-ETH exchange rate fluctuates, in order to correctly account for transaction

fees, a <mark>`tokenRatio`</mark> value has been introduced in the <mark>`GasPriceOracle`</mark> contract. The

<mark>`tokenRatio`</mark> represents the value of MNT compared to ETH which enables fee values to be

correctly calculated. This token ratio is managed at the client level and is meant to be adjusted

by a trusted operator every time the price relation changes.


Mantle v2 introduces many other features which are implemented at the protocol level and are

deemed out of scope of the current smart contract list. We recommend taking a look at the

<u>[following](https://docs-v2.mantle.xyz/intro/whats-new-in-mantle-v2)</u> official page for a more in-depth analysis of the new features.


Mantle V2 Solidity Contracts Audit − System Overview − 9


## **Privileged Roles**

There are several privileged actors within the system:


   - In the <mark>`L2OutputOracle`</mark> <mark>,</mark> only the <mark>`CHALLENGER`</mark> address can <u>[revert state roots](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L2OutputOracle.sol#L141)</u> which

have been already pushed, whereas only the <mark>`PROPOSER`</mark> address can <u>[add new roots.](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L2OutputOracle.sol#L179)</u>

   - In the <mark>`OptimismPortal`</mark> <mark>,</mark> the <mark>`GUARDIAN`</mark> address can <u><mark>`[pause/unpause](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L185-L198)`</mark></u> withdrawal

verification and finalization.

   - The <mark>`owner`</mark> of the <mark>`SystemConfig`</mark> contract can change the <u>[unsafe block signer, the](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/SystemConfig.sol#L190)</u>

entire <u>[configuration, and the](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/SystemConfig.sol#L278)</u> <u><mark>`[batcherHash](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/SystemConfig.sol#L202-L246)`</mark></u> <u><mark>,</mark></u> <u><mark>`[overhead](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/SystemConfig.sol#L202-L246)`</mark></u> <u><mark>[,](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/SystemConfig.sol#L202-L246)</mark></u> <u><mark>`[scalar](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/SystemConfig.sol#L202-L246)`</mark></u> <u>,</u> <u><mark>`[gasLimit](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/SystemConfig.sol#L202-L246)`</mark></u> <u><mark>,</mark></u> <u>and</u>

<u><mark>`[baseFee](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/SystemConfig.sol#L202-L246)`</mark></u> <u>[parameters.](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/SystemConfig.sol#L202-L246)</u>

   - The <mark>`owner`</mark> of the <mark>`GasPriceOracle`</mark> contract can <u>[change the operator address, while](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/GasPriceOracle.sol#L62)</u>

the <mark>`operator`</mark> can <u>[change the token ratio. There are no sanity checks present that can](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/GasPriceOracle.sol#L84)</u>

ensure that the token ratio set by the operator is correct.

   - The <mark>`DEPOSITOR_ACCOUNT`</mark> address can <u>[set L1 block values](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L1Block.sol#L79)</u> in the <mark>`L1Block`</mark> contract.


At any moment, it is assumed that all these special actors have been properly configured and

that none of their private keys are compromised.

## **Security Model and Trust** **Assumptions**


Cross-chain messaging and the asset bridging built on top of are integral parts of every L2

solution. However, the correctness of these cross-chain communications depends on the

underlying node and client operations. As such, we assume that the emitted data for cross
chain communication is correctly relayed from one layer to the other. Given the increased

complexity in differentiating between MNT and ETH (both on L1 and L2), significant amount of

logic is handled at the protocol level. This makes both system contracts and clients have a

bigger dependent relation compared to the original Optimism code. More precisely, there is the

assumption that a deposit transaction will be executed exactly as requested. For a counter
example of how funds can get stuck due to some incorrect node relaying or client executions,

please see the Appendix.


Mantle V2 Solidity Contracts Audit − Privileged Roles − 10


Furthermore, the token ratio that establishes a price relation for MNT-to-ETH is assumed to be

manipulation-resistant as claimed in the <u>[official documentation.](https://docs-v2.mantle.xyz/devs/concepts/tx-fee/overviews#control-of-tokenratio)</u>


Mantle V2 Solidity Contracts Audit − Security Model and Trust Assumptions

                                                - 11


## **Critical Severity**

### **C-01 BVM_ETH and MNT Deposited in Messengers** **Can Be Stolen**

In the <u><mark>`[L2CrossDomainMessenger](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2CrossDomainMessenger.sol)`</mark></u> contract, the <u><mark>`[relayMessage](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2CrossDomainMessenger.sol#L161)`</mark></u> <u>function</u> will perform an

arbitrary external call to <mark>`_target`</mark> <mark>.</mark> At the same time, the same function is expected to fail in

the external call and has logic to handle such a case. If an external call fails, the

<mark>`failedMessages[versionedHash]`</mark> mapping <u>[will be set to](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2CrossDomainMessenger.sol#L267C13-L267C42)</u> <u><mark>`[true](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2CrossDomainMessenger.sol#L267C13-L267C42)`</mark></u> and, at that point,

anyone can <u>[retry](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2CrossDomainMessenger.sol#L203)</u> the execution of the transaction.


When transferring ETH from L1 to L2, if the user went through the <mark>`L1StandardBridge`</mark> logic,

the <mark>`BVM_ETH`</mark> will be minted and transferred to the <mark>`L2CrossDomainMessenger`</mark> on L2 and

the <mark>`relayMessage`</mark> execution is then triggered to move those <mark>`BVM_ETH`</mark> to their final

destination. Similarly, if the user went through the <mark>`L2StandardBridge`</mark> <u>[contract](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2StandardBridge.sol)</u> when

transferring MNT from L2 to L1, the <mark>`OptimismPortal`</mark> contract <u>[will](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L418)</u> transfer MNT to the

<mark>`L1CrossDomainMessenger`</mark> and execute the <mark>`relayMessage`</mark> function to finalize the MNT

withdrawals.


In both cases, the messengers are expected to potentially fail. If that happens, ETH will be

sitting in th <mark>e</mark> <mark>`L2CrossDomainMessenger`</mark> contract and MNT will be sitting in the

<mark>`L1CrossDomainMessenger`</mark> contract, waiting for anyone to retry the failed execution. This is

where a malicious actor can steal all of the ETH or MNT. The attacker can initiate a

<u><mark>`[depositTransaction](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L451)`</mark></u> through the <mark>`L1CrossDomainMessenger`</mark> contract which will be

passed to <u><mark>`relayMessage`</mark></u> with the <mark>`_target`</mark> as the <mark>`BVM_ETH`</mark> contract and the <mark>`_data`</mark>

corresponding to an <mark>`approve`</mark> call from the <u><mark>`L2CrossDomainMessenger`</mark></u> to an EOA owned

by the attacker.


The approval allows the attacker to steal any <mark>`BVM_ETH`</mark> sitting in the

<u><mark>`[L2CrossDomainMessenger](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2CrossDomainMessenger.sol)`</mark></u> coming from a failed <mark>`relayMessage`</mark> execution and waiting to

be retried. The same attack applies to L1 where anyone can become an allowed spender of

MNT stored in <u><mark>`[L1CrossDomainMessenger](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1CrossDomainMessenger.sol)`</mark></u> and steal those too.


Consider declaring the <mark>`BVM_ETH`</mark> address an unsafe target in the <mark>`_isUnsafeTarget`</mark>

<u>[function](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2CrossDomainMessenger.sol#L291)</u> of <mark>`L2CrossDomainMessenger`</mark> and doing the same for the MNT address in the

<mark>`L1CrossDomainMessenger`</mark> <u>[contract. Alternatively consider prohibiting setting the](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1CrossDomainMessenger.sol#L287)</u>


Mantle V2 Solidity Contracts Audit − Critical Severity − 12


<mark>`BVM_ETH`</mark> / <mark>`MNT`</mark> address as target when sending cross-chain messages that will trigger one of

the messenger. Moreover, consider whether such change can restrict potential use cases that

are allowed by the system.


**_Update:_** _Resolved in_ _<u>[pull request #123](https://github.com/mantlenetworkio/mantle-v2/pull/123)</u>_ _at commit_ _<u>[e251c1b. No new unit tests have been](https://github.com/mantlenetworkio/mantle-v2/tree/8571274c3b7e251c1b4108932eaa3a36885f230d)</u>_

_added._

## **Medium Severity**

### **M-01 Cross Domain Messengers Can Fail in** **Relaying a Message**


The <u><mark>`[L1CrossDomainMessenger](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1CrossDomainMessenger.sol)`</mark></u> <u>contract</u> extends <u><mark>`[CrossDomainMessenger](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/CrossDomainMessenger.sol)`</mark></u> and overrides

the <u><mark>`[relayMessage](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1CrossDomainMessenger.sol#L166)`</mark></u> <u>function. One of the characteristics of the original</u> <mark>`relayMessage`</mark>

function is that the estimation of whether there is enough gas or not to proceed with the

[external call has](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/CrossDomainMessenger.sol#L435-L455) a few operations performed in between. The <mark>`hasMinGas`</mark> function,

responsible for the proper gas check, has clear <u>[docstrings](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/libraries/SafeCall.sol#L67)</u> that warn against the overhead gas

provided. It <u>[states](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/libraries/SafeCall.sol#L77)</u> that 40000 units of gas are added as extra gas cost to account for a worst
case scenario of the <mark>`CALL`</mark> opcode called in the subsequent external call. The worst-case

scenario includes:


   - Access to cold storage that accounts for <u>[2600](https://github.com/ethereum/execution-specs/blob/cd9b7d6a9af2f5e07cad02a4971744dd6a553b10/src/ethereum/shanghai/vm/gas.py#L62)</u> units of gas.

   - Call to a non-existent target that accounts for <u>[25000](https://github.com/ethereum/execution-specs/blob/cd9b7d6a9af2f5e07cad02a4971744dd6a553b10/src/ethereum/shanghai/vm/gas.py#L46)</u> units of gas.

   - A positive <mark>`msg.value`</mark> in the call that will increase the cost by <u>[9000](https://github.com/ethereum/execution-specs/blob/cd9b7d6a9af2f5e07cad02a4971744dd6a553b10/src/ethereum/shanghai/vm/gas.py#L47)</u> units of gas.


Also, note that the <u>[second](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/CrossDomainMessenger.sol#L436)</u> argument of the <mark>`hasMinGas`</mark> function is the sum of the following

two variables:




- <u><mark>`[RELAY_RESERVED_GAS](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/CrossDomainMessenger.sol#L157)`</mark></u> which is set to 40000 units of gas. This is an estimation of how

much gas is needed to continue with the <mark>`relayMessage`</mark> execution after the external

call. This is unchanged from Optimism code.




- <u><mark>`[RELAY_GAS_CHECK_BUFFER](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/CrossDomainMessenger.sol#L163)`</mark></u> which is set to 5000 units of gas and represents an



amount that should be used in between the <mark>`hasMinGas`</mark> function and the external call.

This is also unchanged from Optimism code.


The <mark>`hasMinGas`</mark> function contains the following formula:

```
[ gasLeft - (40000 + _reservedGas) ] * 63/64 >= _minGas

```

Mantle V2 Solidity Contracts Audit − Medium Severity − 13


Here, <mark>`_reservedGas`</mark> is 45000 units of gas of which only 5000 are estimated to be a buffer

before the external call. Taking into account all of this, between the gas estimation and the

external call, there is a total buffer of 5000 plus the remainder of the 40000, removing the worst

case scenario of 36600 units of gas, for a total of 8400 units of gas (and <u>[not](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/libraries/SafeCall.sol#L85)</u> 5700 as

mentioned in the docs). After the external call, another 40000 units of gas are reserve to finish

with the normal execution.


The <mark>`L1CrossDomainMessenger`</mark> override adds some extra instructions in the code: <u>[an](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1CrossDomainMessenger.sol#L250)</u>

<mark>`approve`</mark> call to the MNT token contract in case the message being relayed contains a

movement of MNT tokens, and a <u>[second](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1CrossDomainMessenger.sol#L256)</u> <mark>`approve`</mark> to set the allowance back to 0 which is

repeated after the external call. Whether the second approval is needed or not depends on

whether there might be circumstances in which given approvals are not consumed by the

target of the external call.


An approval of an ERC-20 token can span from a few thousand up to 30000 or 40000 units of

gas, exceeding the buffer of few thousands units provided by far. <u>[Some](https://optimistic.etherscan.io/tx/0xebc91e5f1d421eb2165a8d58a5275dd0eebee7008dbf8c2f19d7078b70e7f078)</u> instances of an

<mark>`OptmismMintableERC20`</mark> token might consume even more than 40000 units of gas for every

<mark>`approve`</mark> call. <mark>`approve`</mark> call gas consumption definitely depends on whether values are

being set from zero to positive values or the other way around, or from non-zero to non-zero

values. Notice that a similar argument can be made for the <mark>`relayMessage`</mark> <u>[function](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2CrossDomainMessenger.sol#L161)</u> of the

<mark>`L2CrossDomainMessenger`</mark> <mark>.</mark>


In light of the above, consider revisiting the values for <mark>`RELAY_GAS_CHECK_BUFFER`</mark> and

<mark>`RELAY_RESERVED_GAS`</mark> <mark>,</mark> and deciding whether the second approval is needed to avoid

having unexpected gas failures due to extra instructions included from the original Optimism

code that came with no changes to those default estimation values. Moreover, given the added

logic from Optimism code, gas buffers should be adapted to ensure that enough overhead is

added so that the transactions do not fail. It is worth noting that calls to <mark>`relayMessage`</mark> that

can be engineered to fail can prevent the finalization of deposits and withdrawals, opening the

doors for DoS attacks.


**_Update:_** _Resolved in_ _<u>[pull request #114](https://github.com/mantlenetworkio/mantle-v2/pull/114/files)</u>_ _at commit_ _<u>[67f0904](https://github.com/mantlenetworkio/mantle-v2/tree/67f0904af76580e05b630714411b0e6dadfd5e83)</u>_ _and at commit_ _<u>[92ebaf9.](https://github.com/mantlenetworkio/mantle-v2/commit/92ebaf96622e8126ce5322bdf3ea730640c7a548)</u>_

### **M-02 Gas Estimation Can Fail in** **`finalizeWithdrawalTransaction`**


The <mark>`finalizeWithdrawalTransaction`</mark> <u>[function](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L336)</u> of the <mark>`OptimismPortal`</mark> contract has

been slightly changed from the original Optimism's code to accommodate the changes

required to bridge MNT, separately from the bridging of other assets. Like many other functions


Mantle V2 Solidity Contracts Audit − Medium Severity − 14


within the contract, the function is supposed to <u>[revert](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L432)</u> whenever an external call fails and the

<mark>`tx.origin`</mark> is the <mark>`ESTIMATION_ADDRESS`</mark> <mark>.</mark> Conversely, if the external call did not fail, the

call should not revert even if the <mark>`tx.origin`</mark> is the <mark>`ESTIMATION_ADDRESS`</mark> <mark>.</mark>


As a result of the changes introduced, the original Optimism behavior is not maintained

anymore. Now, even if the external call does not fail and the <mark>`tx.origin`</mark> is the

<mark>`ESTIMATION_ADDRESS`</mark> <mark>,</mark> the <mark>`finalizeWithdrawalTransaction`</mark> execution can still fail if

the only asset being bridged is ETH. This is because the boolean flagging of whether the MNT

transfer was successful or not defaults to <mark>`false`</mark> <mark>,</mark> making the call revert. However, this should

not happen if no MNT are being transferred. The correct fix would be to set the

<mark>`l1mntSuccess`</mark> <u>[boolean](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L416)</u> by default to <mark>`true`</mark> so that the same Optimism behavior is

maintained, but this can also render the boolean useless as mentioned in <u>issue N01.</u>


Consider making the gas estimation behavior consistent with what has been inherited from

Optimism and left unchanged in other parts of the codebase. When doing so, consider the

mentioned issue about useless boolean variables being used.


**_Update:_** _Resolved in_ _<u>[pull request #105](https://github.com/mantlenetworkio/mantle-v2/pull/105)</u>_ _at commit_ _<u>[6022c06.](https://github.com/mantlenetworkio/mantle-v2/tree/6022c060b1baaa1f1c2e60df1136083917d92bb3)</u>_

### **M-03 Unnecessary Payable Function Definition**


The <mark>`proposeL2Output`</mark> <u>[function](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L2OutputOracle.sol#L179)</u> of the <mark>`L2OutputOracle`</mark> contract is defined as <mark>`payable`</mark>

but it does not handle any <mark>`msg.value`</mark> <mark>.</mark> While the function is restricted to be called exclusively

by the <mark>`PROPOSER`</mark> <mark>,</mark> if any <mark>`msg.value`</mark> is passed, funds can get stuck in the contract as there

is no way to pull them out.


Consider whether the <mark>`proposeL2Output`</mark> has to be <mark>`payable`</mark> and document the reason.

Alternatively, consider removing the <mark>`payable`</mark> attribute.


**_Update:_** _Resolved in_ _<u>[pull request #138](https://github.com/mantlenetworkio/mantle-v2/pull/138)</u>_ _at commit_ _<u>[af0d029.](https://github.com/mantlenetworkio/mantle-v2/tree/af0d029ae5222e39b3aae4f9d07569708c2cbdf9)</u>_


Mantle V2 Solidity Contracts Audit − Medium Severity − 15


## **Low Severity**

### **L-01 Assets Might Get Stuck in Contracts**

Across the codebase, there are several circumstances in which assets can get locked in the

contracts due to external call failures. Two examples are:


   - When bridging ETH from L2 to L1, the <mark>`finalizeWithdrawalTransaction`</mark> <u>[function](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L336)</u>

of the <mark>`OptimismPortal`</mark> is called. This will attempt to <u>[call](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L421)</u> the <mark>`L1StandardBridge`</mark> at

the <mark>`finalizeBridgeETH`</mark> <u>[function](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1StandardBridge.sol#L662)</u> [which performs an external call](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1StandardBridge.sol#L675) to the recipient of

the ETH. However, if such a call fails, the <mark>`success`</mark> [returned boolean](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L421) will be false and

the <mark>`finalizeWithdrawalTransaction`</mark> will revert <u>[exclusively](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L432)</u> if the <mark>`tx.origin`</mark> is

the <mark>`ESTIMATION_ADDRESS`</mark> <mark>,</mark> but it will not revert if the caller is a normal user trying to

finalize the bridge back to L1. Moreover, the <mark>`finalizedWithdrawals`</mark> mapping will be

<u>[set](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L404)</u> to <mark>`true`</mark> for this specific withdrawal, preventing any future attempt to replay the

transaction and make it work. The result is that ETH will be stuck in the

<mark>`OptimismPortal`</mark> <mark>.</mark>


  - When bridging an ERC-721 token from L2 to L1, the same

<mark>`finalizeWithdrawalTransaction`</mark> will be called, but this time the

<mark>`L1ERC721Bridge`</mark> will be called at the <mark>`finalizeERC721Bridge`</mark> <u>[function. This](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1ERC721Bridge.sol#L46)</u>

function will effectively <u>[perform](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1ERC721Bridge.sol#L68)</u> a <mark>`safeTransferFrom`</mark> from the <mark>`L1ERC721Bridge`</mark> to

the recipient of the ERC-721 token. The usage of the <mark>`safeTransferFrom`</mark> <u>[implies](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC721/ERC721.sol#L192C17-L192C39)</u> also

triggering a <mark>`_checkOnERC721Received`</mark> <u>[hook](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC721/ERC721.sol#L399)</u> which will revert if the recipient is a

contract that does not implement the correct interface to receive the token. If the call

reverts, the same situation as before will happen since the

<mark>`finalizeWithdrawalTransaciton`</mark> will not revert and the withdrawal will be marked

as finalized. The result here is that the ERC-721 token will be stuck in the bridge.


Consider either documenting such behaviours in the docstrings of the contracts or putting

remediations in place.


Note that case in which ETH gets stuck in the <mark>`OptimismPortal`</mark> is inherited from the

Optimism contracts and Optimism have already taken a position in which they delegate the

responsibility of this to the user who should understand the risk. Quoting one of their <u>[issues:](https://github.com/sherlock-audit/2023-01-optimism-judging/issues/109)</u>


One of the quirks of the OptimismPortal is that there is no replaying of transactions. If a

transaction fails, it will simply fail, and all ETH associated with it will remain in the


Mantle V2 Solidity Contracts Audit − Low Severity − 16


OptimismPortal contract. Users have been warned of this and understand the risks, so

Optimism takes no responsibility for user error.


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_Won't fix; we have already implemented transaction replay at the_

_CrossDomainMessenger contract level._

### **L-02 Unusual Upgradeability Patterns Are** **Adopted**


In the codebase, <u>[some](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1CrossDomainMessenger.sol)</u> contracts are meant to be upgradeable and so may have a <mark>`__gap`</mark>

<u>[variable](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/CrossDomainMessenger.sol#L212)</u> defined. Upgradeable contracts are meant to be called via proxies, for which reason

they usually have an <mark>`initialize`</mark> <u>[function](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1CrossDomainMessenger.sol#L49)</u> that is called through the proxy. This function sets

the initial variable values of the proxy storage slots. In order to prevent someone from

initializing the implementation contract directly, in some circumstances, the <mark>`initialize`</mark>

function is called <u>[within](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1CrossDomainMessenger.sol#L43)</u> the constructor. However, this consumes unnecessary gas and is sub
optimal. All initializable contracts extend the OpenZeppelin <mark>`Initializable`</mark> <u>[contract](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/CrossDomainMessenger.sol#L4)</u> which

[defines an internal function](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/proxy/utils/Initializable.sol#L145) called <mark>`_disableInitializers`</mark> that performs the same task of

disabling implementation initializations, but without wasting gas by setting the variables to

unnecessary values.


Consider calling the <mark>`_disableInitializers`</mark> function instead of calling the <mark>`initialize`</mark>

function within the constructor.


Moreover, some contracts seem to have misplaced and incorrectly-used <mark>`__gap`</mark> variables as

is the case for the <u>[ERC721Bridge](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/ERC721Bridge.sol)</u> and <u>[L1ERC721Bridge](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1ERC721Bridge.sol)</u> contracts. The former has two

immutable variables that do not take any slot and the <mark>`__gap`</mark> variable is <u>[set](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/ERC721Bridge.sol#L25)</u> to have a size of

49 slots despite the canonical value being 50, while the latter has one slot occupied by the

deposits <u>[mapping. This may be misleading as it might explain the 49 slot size instead of the 50](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1ERC721Bridge.sol#L20)</u>

slot size for the <mark>`__gap`</mark> variable. However, the way in which storage layout works in the

<mark>`contract L1ERC721Bridge is ERC721Bridge, Semver`</mark> definition is to have the

<mark>`ERC721Bridge`</mark> slots defined first, then the <mark>`Semver`</mark> ones, and finally the <mark>`L1ERC721Bridge`</mark>

as the last one.


Consider reviewing the codebase and always using upgradeability standard patterns in which

the <mark>`__gap`</mark> variable's size reflects the amount of storage slots occupied by the current

contextual contract.


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


Mantle V2 Solidity Contracts Audit − Low Severity − 17


_Not fixing. It will not affect the main logic._

### **L-03 Wrong Value Emitted in Event**


The <mark>`TokenRatioUpdated`</mark> <u>[event](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/GasPriceOracle.sol#L87)</u> is emitted in the <mark>`GasPriceOracle`</mark> contract everytime the

<mark>`tokenRatio`</mark> variable is updated to a new value. Its parameters are the previous and the new

value being set. However, the event <u>[incorrectly](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/GasPriceOracle.sol#L84-L88)</u> emits the new token ratio twice instead of

emitting the previous token ratio followed by the new token ratio.


Consider assigning the <mark>`previousTokenRatio`</mark> variable to the current token ratio instead of

the used input parameter.


**_Update:_** _Resolved in_ _<u>[pull request #138](https://github.com/mantlenetworkio/mantle-v2/pull/138)</u>_ _at commit_ _<u>[572600a.](https://github.com/mantlenetworkio/mantle-v2/tree/572600a4f163e10ae6049a9826855dd86f4e93e7)</u>_

### **L-04 Incomplete Docstrings**


Throughout the <u>[codebase, there are several parts that have a incomplete docstring:](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/)</u>


   - In the <u>[relayMessage](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/CrossDomainMessenger.sol#L362-L474)</u> function of the <u><mark>`[CrossDomainMessenger](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/CrossDomainMessenger.sol)`</mark></u> contract, the

<mark>`_mntValue`</mark> parameter is not documented.

   - The <u>[OwnershipTransferred](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/CrossDomainOwnable3.sol#L26-L30)</u> event of the <u><mark>`[CrossDomainOwnable3](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/CrossDomainOwnable3.sol)`</mark></u> contract does not

document what the <mark>`previousOwner`</mark> <mark>,</mark> <mark>`newOwner`</mark> <mark>,</mark> and <mark>`isLocal`</mark> parameters are.

   - The <u>[TokenRatioUpdated,](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/GasPriceOracle.sol#L41)</u> <u><mark>`[OwnershipTransferred](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/GasPriceOracle.sol#L42)`</mark></u> <mark>,</mark> and <u><mark>`[OperatorUpdated](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/GasPriceOracle.sol#L43)`</mark></u> events

in the <u><mark>`[GasPriceOracle](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/GasPriceOracle.sol)`</mark></u> contract do not document what their parameters are.

   - In the <u>[transferOwnership](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/GasPriceOracle.sol#L72-L77)</u> function of the <u><mark>`[GasPriceOracle](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/GasPriceOracle.sol)`</mark></u> contract, the <mark>`_owner`</mark>

parameter is not documented.

   - In the <u>[depositMNT](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1StandardBridge.sol#L198-L204)</u> function of the <u><mark>`[L1StandardBridge](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1StandardBridge.sol)`</mark></u> contract, the <mark>`_amount`</mark>

parameter is not documented.

   - In the <u>[depositMNTTo](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1StandardBridge.sol#L220-L227)</u> function of the <u><mark>`[L1StandardBridge](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1StandardBridge.sol)`</mark></u> contract, the <mark>`_amount`</mark>

parameter is not documented.

   - In the <u>[bridgeETH](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2StandardBridge.sol#L475-L477)</u> function of the <u><mark>`[L2StandardBridge](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2StandardBridge.sol)`</mark></u> contract, the <mark>`_value`</mark> parameter

is not documented.

   - In the <u>[l1Token](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/OptimismMintableERC20.sol#L122-L124)</u> function of th <mark>e</mark> <u><mark>`[OptimismMintableERC20](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/OptimismMintableERC20.sol)`</mark></u> contract, not all return values

are documented. The same happens in the <u>[l2Bridge, remoteToken, and the](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/OptimismMintableERC20.sol#L130-L132)</u> <u>[bridge](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/OptimismMintableERC20.sol#L146-L148)</u>

functions of the same contract.

   - In the <u>[WithdrawalProven](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L115-L119)</u> event of the <u><mark>`[OptimismPortal](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol)`</mark></u> contract, the <mark>`from`</mark> and <mark>`to`</mark>

parameters are not documented.


Mantle V2 Solidity Contracts Audit − Low Severity − 18


   - In the <u>[initialize](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L176-L180)</u> function of the <u><mark>`[OptimismPortal](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol)`</mark></u> contract, the <mark>`_paused`</mark> parameter is

not documented.

   - In the <u>[minimumGasLimit](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L207-L209)</u> function of the <u><mark>`[OptimismPortal](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol)`</mark></u> contract, the <mark>`_byteCount`</mark>

and the return value are not documented.

   - In the <u>[initialize](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/SystemConfig.sol#L133-L153)</u> function of the <u><mark>`[SystemConfig](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/SystemConfig.sol)`</mark></u> contract, the <mark>`_baseFee`</mark> parameter is

not documented.


Consider thoroughly documenting all functions/events (and their parameters or return values)

that are part of any contract's public API. When writing docstrings, consider following the

<u>[Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html)</u> (NatSpec).


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_Will fix later. it's not a logic issue._

### **L-05 Floating and Multiple Pragma Directives Are** **Being Used**


Pragma directives should be fixed to clearly identify the Solidity version with which the

contracts will be compiled. Throughout the <u>[codebase, there are multiple floating pragma](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/)</u>

directives. The majority of contracts have a fixed version of <mark>`0.8.15`</mark> but there are some

contracts that differ:


   - The <u><mark>`[BVM_ETH.sol](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/BVM_ETH.sol)`</mark></u> file has the <u><mark>`[solidity ^0.8.9](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/BVM_ETH.sol#L2)`</mark></u> floating pragma directive.

   - The <u><mark>`[CrossDomainOwnable.sol](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/CrossDomainOwnable.sol)`</mark></u> file has the <u><mark>`[solidity ^0.8.0](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/CrossDomainOwnable.sol#L2)`</mark></u> floating pragma

directive.

   - The <u><mark>`[CrossDomainOwnable2.sol](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/CrossDomainOwnable2.sol)`</mark></u> file has the <u><mark>`[solidity ^0.8.0](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/CrossDomainOwnable2.sol#L2)`</mark></u> floating pragma

directive.

   - The <u><mark>`[CrossDomainOwnable3.sol](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/CrossDomainOwnable3.sol)`</mark></u> file has the <u><mark>`[solidity ^0.8.0](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/CrossDomainOwnable3.sol#L2)`</mark></u> floating pragma

directive.

   - The <u><mark>`[Semver.sol](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/Semver.sol)`</mark></u> file has the <u><mark>`[solidity ^0.8.0](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/Semver.sol#L2)`</mark></u> floating pragma directive.


Moreover, there are cases in which one contract has a pragma directive which differs from that

of its imports:


   - The <u><mark>`[CrossDomainOwnable2.sol](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/CrossDomainOwnable2.sol)`</mark></u> file has the <u><mark>`[pragma solidity ^0.8.0;](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/CrossDomainOwnable2.sol#L2)`</mark></u> pragma

directive and imports <u><mark>`[L2CrossDomainMessenger.sol](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2CrossDomainMessenger.sol)`</mark></u> which has a different pragma

directive.


Mantle V2 Solidity Contracts Audit − Low Severity − 19


   - The <u><mark>`[CrossDomainOwnable3.sol](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/CrossDomainOwnable3.sol)`</mark></u> file has the <u><mark>`[pragma solidity ^0.8.0;](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/CrossDomainOwnable3.sol#L2)`</mark></u> pragma

directive and imports <u><mark>`[L2CrossDomainMessenger.sol](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2CrossDomainMessenger.sol)`</mark></u> which has a different pragma

directive.


Consider using a fixed pragma version which is consistent across all contracts.


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_No need to fix._

### **L-06 Unsafe ABI Encoding**


It is not an uncommon practice to use <mark>`abi.encodeWithSignature`</mark> or

<mark>`abi.encodeWithSelector`</mark> to generate calldata for a low-level call. However, the first

option is not typo-safe and the second option is not type-safe. The results in both of these

methods being error-prone and thus to be considered unsafe. Within <mark>`Encoding.sol`</mark> <mark>,</mark> there

are several occurrences of unsafe ABI encodings:


   - In <u>[line 92.](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/libraries/Encoding.sol#L92)</u>

   - In <u>[line 124.](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/libraries/Encoding.sol#L124)</u>


Consider replacing all the occurrences of unsafe ABI encodings with <mark>`abi.encodeCall`</mark> <mark>,</mark>

which checks whether the supplied values actually match the types expected by the called

function and also avoids errors caused by typos.


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_There is no need to fix this._

### **L-07 Missing Docstrings**


Throughout the <u>[codebase, there are several parts that do not have docstrings. For instance:](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/)</u>


   - The <u><mark>`[mint](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/BVM_ETH.sol#L24-L30)`</mark></u> function of the <u><mark>`[BVM_ETH](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/BVM_ETH.sol)`</mark></u> contract is not documented.

   - The <u>[variables, events, and](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/GasPriceOracle.sol#L29-L31)</u> <u>[modifersi](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/GasPriceOracle.sol#L48-L55)</u> of the <u><mark>`[GasPriceOracle](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/GasPriceOracle.sol)`</mark></u> contract are not

documented.

   - The <u>[L1_MNT_ADDRESS](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1CrossDomainMessenger.sol#L31)</u> variable of the <u><mark>`[L1CrossDomainMessenger](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1CrossDomainMessenger.sol)`</mark></u> contract is

missing documentation. The same variable <u>[lacks](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1StandardBridge.sol#L29)</u> docstrings in the <mark>`L1StandardBridge`</mark>

and <u>[in the](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2StandardBridge.sol#L28)</u> <mark>`L2StandardBridge`</mark> contracts.

   - The <u><mark>`[bridgeMNTTo](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2StandardBridge.sol#L525-L531)`</mark></u> function of the <u><mark>`[L2StandardBridge](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2StandardBridge.sol)`</mark></u> contract is not documented.


Mantle V2 Solidity Contracts Audit − Low Severity − 20


   - In the <mark>`depositTransaction`</mark> <u>[function](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L451)</u> of the <mark>`OptimismPortal`</mark> contract it is possible

to bridge simultaneously ETH and MNT at the same time. If this is the case the user

should not use the normal flow of bridging through <mark>`L2CrossDomainMessenger`</mark> and

<mark>`L2StandardBridge`</mark> since this supports bridging only one asset at time. Consider

warning the user about it.


Consider thoroughly documenting all functions (and their parameters) that are part of any

contract's public API. Functions implementing sensitive functionality, even if not <mark>`public`</mark>,

should be clearly documented as well. When writing docstrings, consider following the

<u>[Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html)</u> (NatSpec).


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_No need to fix._

## **Notes & Additional** **Information**

### **N-01 Unnecessary Boolean Values**


Throughout the codebase, there are instances of boolean values being defined but not being

logically useful:


   - The <mark>`success`</mark> <u>[value](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1StandardBridge.sol#L866)</u> of the <mark>`approve`</mark> call within the <mark>`_initiateBridgeMNT`</mark> function

of the <mark>`L1StandardBridge`</mark> contract. The Mantle token's <mark>`approve`</mark> <u>[function](https://etherscan.io/address/0xcd368c1d80120b0dd92447c87eb570154f8e685c#code#F7#L141)</u> either

reverts or returns true, there is no case in which its result value is false.

   - The <mark>`l1mntSuccess`</mark> <u>[variable](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L418)</u> of the <mark>`finalizeWithdrawalTransaction`</mark> function of

the <mark>`OptimismPortal`</mark> contract is either true or the <mark>`transfer`</mark> call reverted. <u>[It](https://etherscan.io/address/0xcd368c1d80120b0dd92447c87eb570154f8e685c#code#F7#L118)</u> will

never be false.

   - The <mark>`ethSuccess`</mark> <u>[variable](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2CrossDomainMessenger.sol#L254)</u> of the <mark>`relayMessage`</mark> function of the

<mark>`L2CrossDomainMessenger`</mark> contract is either true or the <mark>`approve`</mark> function reverted.

It will never be false whenever its value is evaluated.


Consider refactoring the code to avoid using unnecessary boolean values. When doing so,

care should be taken in maintaining the same flow of execution, especially at places where the

current unnecessary booleans are being evaluated.


Mantle V2 Solidity Contracts Audit − Notes & Additional Information − 21


**_Update:_** _Resolved in_ _<u>[pull request #128](https://github.com/mantlenetworkio/mantle-v2/pull/128)</u>_ _at commit_ _<u>[d8efd33.](https://github.com/mantlenetworkio/mantle-v2/tree/d8efd33f8c6f063a23875910e722385ed877f16b)</u>_

### **N-02 Misleading Docstrings**


Several instances of incorrect or misleading docstrings have been identified throughout the

codebase:


<mark>`BVM_ETH.sol`</mark> <mark>:</mark>


   - Line <u>[12: the comment above the](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/BVM_ETH.sol#L12)</u> <mark>`BVM_ETH`</mark> definition is outdated and can be misleading


<mark>`LegacyERC20MNT.sol`</mark> <mark>:</mark>


   - Lines <u>[39, 47, 55, 63: "ETH" should be "MNT"](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/legacy/LegacyERC20MNT.sol#L39)</u>


<mark>`Burn.sol`</mark> <mark>:</mark>


   - Lines <u>[34, 35: "ETH" should be "MNT"](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/libraries/Burn.sol#L34-L35)</u>

   - The docstrings in lines <u>[19, 21](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/libraries/Burn.sol#L19-L21)</u> mention that the <mark>`gas`</mark> function "burns" a specific amount

of gas. However, the amount of gas is not burnt but consumed


<mark>`Types`</mark> <mark>:</mark>


   - Both <u><mark>`[mntTxValue](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/libraries/Types.sol#L48)`</mark></u> and <u><mark>`[ethTxValue](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/libraries/Types.sol#L50)`</mark></u> share identical documentation, yet they serve

different purposes in <mark>`UserDepositTransaction`</mark> <mark>.</mark>

   - In <mark>`WithdrawalTransaction`</mark> <mark>'</mark> s struct documentation, the docstring for the non
existent field <u><mark>`[value](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/libraries/Types.sol#L76)`</mark></u> can be removed. Additionally, both <u><mark>`[mntValue](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/libraries/Types.sol#L84)`</mark></u> and <u><mark>`[ethValue](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/libraries/Types.sol#L85)`</mark></u>

fields are not documented.


Consider updating the misleading instances of docstrings for improved clarity and readability.


**_Update:_** _Partially resolved in_ _<u>[pull request #129](https://github.com/mantlenetworkio/mantle-v2/pull/129)</u>_ _at commit_ _<u>[fd4fc03. The outdated comment in](https://github.com/mantlenetworkio/mantle-v2/tree/fd4fc03d0986022b3ed0d0bcdf950478dd166da1)</u>_

_<mark>`BVM_ETH.sol`</mark>_ _is still present._

### **N-03 Duplicated Getter Function**


The <mark>`RECIPIENT`</mark> variable of the <mark>`SequencerFeeVault`</mark> contract is <u>[declared](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/FeeVault.sol#L30)</u> as <mark>`public`</mark> .

However, it also has a <u>[specifci](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/SequencerFeeVault.sol#L28)</u> getter defined.


Consider removing the duplicate getter and leaving only one instance to retrieve the value of

the <mark>`RECIPIENT`</mark> variable from.


Mantle V2 Solidity Contracts Audit − Notes & Additional Information − 22


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_No need to fix._

### **N-04 public Functions Can Be Declared as** **`external`**


Throughout the codebase, there are <u>[multiple](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/GasPriceOracle.sol#L62-L84)</u> <u>[instances](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/deployment/PortalSender.sol#L29)</u> of contracts that define <mark>`public`</mark>

functions. However, these functions can be defined as <mark>`external`</mark> instead.


To save gas and improve code clarity, consider reviewing the codebase and marking all

functions that are not called within the code itself as <mark>`external`</mark> <mark>.</mark>


**_Update:_** _Resolved in_ _<u>[pull request #130](https://github.com/mantlenetworkio/mantle-v2/pull/130)</u>_ _at commit_ _<u>[c6f2d81.](https://github.com/mantlenetworkio/mantle-v2/tree/c6f2d81c0c55c783a1472316f891fedf2bb23c60)</u>_

### **N-05 Code Style Inconsistency**


The <mark>`ERC721Bridge`</mark> contract has a specific <mark>`require`</mark> <u>[statement](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/ERC721Bridge.sol#L140)</u> to make sure that the caller

is an EOA and not a contract. However, other contracts have a specific <u>[modifier](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/StandardBridge.sol#L176)</u> called

<mark>`onlyEOA`</mark> for the same purpose.


Consider using the <mark>`onlyEOA`</mark> modifier consistently across the codebase to improve code

readability and quality.


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_No need to fix._

### **N-06 Typographical Errors**


In the codebase, there are a few instances of docstrings containing typos:


   - In <u>[line 32](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L32)</u> of the <mark>`OptimismPortal`</mark> contract, "whcih" should be "which".

   - In <u>[line 72](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L72)</u> of the <mark>`OptimismPortal`</mark> contract, the first docstring line is missing "If the

value" and thus does not logically connect with the second docstring line.


Consider reviewing the entire codebase and addressing typographical errors in order to

improve code quality and readability.


**_Update:_** _Resolved in_ _<u>[pull request #131](https://github.com/mantlenetworkio/mantle-v2/pull/131)</u>_ _at commit_ _<u>[53fe7ce.](https://github.com/mantlenetworkio/mantle-v2/tree/53fe7ce8b20e55f66f45e99cfb377cd042f98895)</u>_


Mantle V2 Solidity Contracts Audit − Notes & Additional Information − 23


### **N-07 Variables Naming Does Not Follow Solidity** **Style Guide**

As per the <u>[Solidity Style Guide suggestions, private or internal variable identifiers should be](https://docs.soliditylang.org/en/latest/style-guide.html#underscore-prefix-for-non-external-functions-and-variables)</u>

prefixed with `_` . Throughout the codebase, there are multiple <u>[instances](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2ToL1MessagePasser.sol#L46)</u> of variable naming that

do not follow these guidelines.


Consider reviewing the codebase and fixing any instances of irregular variable naming, and

adopting all the Solidity style guidelines in order to improve the overall code quality and

readability.


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_No need to fix._

### **N-08 Use of Magic Constants**


In <mark>`L1CrossDomainMessenger`</mark> <mark>,</mark> magic constants are being <u>[used. In the linked instance, the](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1CrossDomainMessenger.sol#L169)</u>

check can be changed from <mark>`< 2`</mark> to <mark>`<= MESSAGE_VERSION`</mark> <mark>.</mark>


Consider always defining constants with explicit names for better readability and

understandability of the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #132](https://github.com/mantlenetworkio/mantle-v2/pull/132)</u>_ _at commit_ _<u>[75e7984. However, the same happens on](https://github.com/mantlenetworkio/mantle-v2/tree/75e7984f6e0ab99473ae7ae117cc1397a6c159b9)</u>_

_<mark>`L2CrossDomainMessenger`</mark>_ _but it hasn't been fixed there._

### **N-09 Usage of Single Step Ownership Transfer**


In the <u>[CrossDomainOwnable](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/CrossDomainOwnable.sol)</u> and <u>[GasPriceOracle](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/GasPriceOracle.sol)</u> contracts, ownership is transferred in a

single step. This might be pose a risk since setting an incorrect address would mean that the

ownership of the contracts is permanently lost, with no method of recovery.


Consider using a two-step ownership transfer process such as OpenZeppelin's <u>[Ownable2Step.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable2Step.sol)</u>


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_No need to fix._


Mantle V2 Solidity Contracts Audit − Notes & Additional Information − 24


### **N-10 Lack of Indexed Event Parameters**

Throughout the <u>[codebase, several events do not have their parameters indexed:](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/)</u>


   - The <u><mark>`[Withdrawal](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/FeeVault.sol#L20)`</mark></u> event of the <u><mark>`[FeeVault](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/FeeVault.sol)`</mark></u> contract

   - The <u><mark>`[Paused](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L134)`</mark></u> and <u><mark>`[Unpaused](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L141)`</mark></u> events of the <u><mark>`[OptimismPortal](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol)`</mark></u> contract


Consider <u>[indexing event parameters](https://solidity.readthedocs.io/en/latest/contracts.html#events)</u> to improve the ability of off-chain services to search and

filter for specific events.


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_No need to fix._

### **N-11 Lack of Security Contact**


Providing a specific security contact (such as an email or ENS name) within a smart contract

significantly simplifies the process for individuals to communicate if they identify a vulnerability

in the code. This practice is beneficial as it permits the code owners to dictate the

communication channel for vulnerability disclosure, eliminating the risk of miscommunication

or failure to report due to a lack of knowledge on how to do so. In addition, if the contract

incorporates third-party libraries and a bug surfaces in these, it becomes easier for the

maintainers of those libraries to make contact with the appropriate person about the problem

and provide mitigation instructions.


Throughout the <u>[codebase, there are many instances of contracts not having a security contact.](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/)</u>


Consider adding a NatSpec comment containing a security contact above the contract

definitions. Using the <mark>`@custom:security-contact`</mark> convention is recommended as it has

been adopted by the <u>[OpenZeppelin Wizard](https://wizard.openzeppelin.com/)</u> and the <u>[ethereum-lists.](https://github.com/ethereum-lists/contracts#tracking-new-deployments)</u>


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_There is no need to fix this._

### **N-12 Unnecessary Cast**


Within the <mark>`LegacyERC20MNT`</mark> contract, the <u><mark>`[address(_who)](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/legacy/LegacyERC20MNT.sol#L34)`</mark></u> cast is unnecessary.


To improve the overall clarity, intent, and readability of the codebase, consider removing

unnecessary casts.


Mantle V2 Solidity Contracts Audit − Notes & Additional Information − 25


**_Update:_** _Resolved in_ _<u>[pull request #133](https://github.com/mantlenetworkio/mantle-v2/pull/133)</u>_ _at commit_ _<u>[9032ff2.](https://github.com/mantlenetworkio/mantle-v2/tree/9032ff2d1b114b92605bfd9e8e43af328ab4b66f)</u>_

### **N-13 Unused Code**


The <u><mark>`[hashDepositTransaction](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/libraries/Hashing.sol#L21)`</mark></u> function of the <mark>`Hashing`</mark> library contract is never used

within the codebase. In addition, the following code eventually remains unused as well, since it

currently only assists the <mark>`hashDepositTransaction`</mark> function:


   - function <u><mark>`[encodeDepositTransaction](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/libraries/Encoding.sol#L22-L40)`</mark></u> of the <mark>`Encoding`</mark> library

   - function <u><mark>`[hashDepositSource](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/libraries/Hashing.sol#L39-L46)`</mark></u> of the <mark>`Hashing`</mark> library

   - struct <u><mark>`[UserDepositTransaction](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/libraries/Types.sol#L56-L68)`</mark></u> of the <mark>`Types`</mark> library


To improve the overall clarity, intentionality, and readability of the codebase, consider removing

any unused code.


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_There is no need to fix this._

### **N-14 Addresses of Predeploys Are Not Ordered**


The constant values of addresses in the <u><mark>`[Predeploys](https://github.com/mantlenetworkio/mantle-v2/tree/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/libraries/Predeploys.sol)`</mark></u> library are not ordered incrementally

which is prone to errors when new addresses need to be added.


Consider ordering all addresses incrementally.


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_There is no need to fix this._

### **N-15 Address Is Being Removed Twice**


In the <mark>`SystemDictator`</mark> contract, the <u><mark>`[step3](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/deployment/SystemDictator.sol#L290)`</mark></u> <u>function</u> is being called to remove deprecated

addresses from the <mark>`AddressManager`</mark> contract. However, the

<mark>`BVM_CanonicalTransactionChain`</mark> address is being removed twice, first on <u>[line 293](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/deployment/SystemDictator.sol#L293)</u> and

then on <u>[line 300.](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/deployment/SystemDictator.sol#L300)</u>


Consider only removing the deprecated address of <mark>`BVM_CanonicalTransactionChain`</mark>

once.


Mantle V2 Solidity Contracts Audit − Notes & Additional Information − 26


**_Update:_** _Resolved in_ _<u>[pull request #135](https://github.com/mantlenetworkio/mantle-v2/pull/135)</u>_ _at commit_ _<u>[4ed9335.](https://github.com/mantlenetworkio/mantle-v2/tree/4ed93352bdaf3cd51544e3f0f2c43290d8fd7c0a)</u>_

### **N-16 Predeployed Contracts Missing Custom** **Documentation Tag**


Throughout the <u>[codebase, predeployed contracts listed in the](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts)</u> <u><mark>`[Predeploys](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/libraries/Predeploys.sol#L8)`</mark></u> <u>library</u> include the

custom tag <mark>`@custom:predeploy`</mark> in each contract's NatSpec documentation. However, the

following contracts were found missing the custom <mark>`@custom:predeploy`</mark> tag: 
<u><mark>`[ProxyAdmin](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/ProxyAdmin.sol#L29-L35)`</mark></u> - <u><mark>`[OptimismMintableERC721Factory](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/universal/OptimismMintableERC721Factory.sol#L7-L11)`</mark></u> - <u><mark>`[L2ERC721Bridge](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2ERC721Bridge.sol#L10-L21)`</mark></u> - <u><mark>`[BVM_ETH](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/BVM_ETH.sol#L10-L15)`</mark></u>


To improve code clarity, consider adding the <mark>`@custom:predeploy`</mark> tag with the appropriate

address to each contract's NatSpec documentation.


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_There is no need to fix this._

### **N-17 Unused Import**


The <u><mark>`[L1StandardBridge.sol](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1StandardBridge.sol)`</mark></u> contract imports <u><mark>`[L1CrossDomainMessenger](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/L1StandardBridge.sol#L12)`</mark></u> but does not

use it.


Consider removing any unused imports to improve the overall clarity and readability of the

codebase.


**_Update:_** _Resolved in_ _<u>[pull request #136](https://github.com/mantlenetworkio/mantle-v2/pull/136)</u>_ _at commit_ _<u>[2002a90.](https://github.com/mantlenetworkio/mantle-v2/tree/2002a90d86d7ec299223709d4db5dcbb28a8be2f)</u>_

### **N-18 Duplicate Event Emission**


The <mark>`OwnershipTransferred`</mark> <u>[event](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/CrossDomainOwnable3.sol#L44)</u> of the <mark>`CrossDomainOwnable3`</mark> contract is already

emitted inside the <u>[internal](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.7/contracts/access/Ownable.sol#L81)</u> <mark>`_transferOwnership`</mark> function.


Consider removing the duplicate event.


**_Update:_** _Acknowledged, not resolved. The Mantle team stated:_


_No need to fix._


Mantle V2 Solidity Contracts Audit − Notes & Additional Information − 27


## **Conclusion**

The audit yielded one critical and some medium-severity issues. While the code inherited from

Optimism was well documented, the new code needs some documentation fixes as suggested

in the reported issues. Given the issues raised, the test suite could be improved around the

changes introduced to the Mantle codebase. As such, we strongly recommend that the Mantle

team implements more extensive QA and testing before going live to prevent potentially

undiscovered vulnerabilities from being exploited. When doing so, it should be ensured that a

high branch coverage is achieved and that comprehensive end-to-end tests are performed.

The Mantle team was very responsive in resolving doubts and answering questions during the

course of the audit. The official documentation was also quite helpful in getting the right

context to understand the changes introduced.


**_Update:_** _The team resolved the higher severity issues and some of the issues lower in severity._

_Many issues have been not addressed but acknowledged. Moreover, even if the changes_

_introduced have been properly reviewed in addressing the issues found, there is no addition of_

_proper unit tests around those. We recommend the Mantle team to improve the overall test_

_suite in light of the new changes introduced._


**Appendix - Locked Funds Due to Failed Deposit Transaction Exploration**


The code has been adapted to support changing ETH from the native token to an ERC-20

token on L2, as well as to change MNT from an ERC-20 token to the native token. When

bridging from L1 to L2, the last L1 execution step is the <mark>`depositTransaction`</mark> <u>[function](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L451)</u> of

the <mark>`OptimismPortal`</mark> <mark>.</mark> This function emits an <u>[event](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L507)</u> that is then listened to at the protocol

level and processed. Then, the first L2 execution step is the <mark>`relayMessage`</mark> <u>[function](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2CrossDomainMessenger.sol#L161)</u> of the

<mark>`L2CrossDomainMessenger`</mark> <mark>.</mark> The L2 execution should carry over the parameters emitted in

the L1 event into the L2 execution.


The details of the execution are as follows:


1) The native L1 ETH <mark>`ethValue`</mark> <u>[amount](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L498)</u> is locked into the <mark>`OptimismPortal`</mark> contract once

the <mark>`depositTransaction`</mark> execution finishes. 2) At the protocol level, the <mark>`ethValue`</mark>

amount emitted in the event is minted in the form of ERC-20 WETH to the <mark>`from`</mark> parameter

emitted in the <mark>`TransactionDeposited`</mark> event. 3) A snapshot is taken. 4) The <u>[amount](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L499)</u>

<mark>`ethTxValue`</mark> is then transferred to the <mark>`to`</mark> of the emitted L1 event. 5) The L2

<mark>`relayMessage`</mark> function is now executed.


Mantle V2 Solidity Contracts Audit − Conclusion − 28


The reason for this flow resides in two main considerations:


   - The normal user execution flow to bridge ETH from L1 to L2 would require the user to

first trigger the <mark>`_initiateBridgeETH`</mark> function on the <mark>`L1StandardBridge`</mark> <mark>.</mark> This

would call the <mark>`sendMessage`</mark> function of the <mark>`L1CrossDomainMessenger`</mark> contract

which will then call the <mark>`depositTransaction`</mark> function of the <mark>`OptimismPortal`</mark> <mark>.</mark>

When doing so, the <mark>`from`</mark> parameter emitted in the event is the <u>[aliased](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L1/OptimismPortal.sol#L489)</u> address of the

<mark>`L1CrossDomainMessenger`</mark> while the <mark>`to`</mark> is the <mark>`L2CrossDomainMessenger`</mark> <mark>.</mark>

   - One can skip this entire flow and directly call the <mark>`OptimismPortal`</mark> passing the correct

parameters to execute the same exact operation. However, this can be done by directly

triggering the <mark>`depositTransaction`</mark> from an externally owned account or through a

user-controlled intermediary contract. If the case is the latter, the <mark>`from`</mark> parameter this

time would be the aliased address of the user-controlled contract.


Now suppose that we are in this latest scenario and step `5` fails to execute. At the protocol

level, the snapshot taken in step `3` is restored. In this hypothetical scenario, the <mark>`from`</mark> would

have some WETH minted, but those would not have been transferred to

<mark>`L2CrossDomainMessenger`</mark> <mark>.</mark> Now, thanks to this pattern, the user can trigger a transaction

once again through its controlled contract using this time <mark>`ethValue == msg.value == 0`</mark>

and <mark>`ethTxValue`</mark> the same value as before. This time, WETH will not be minted, but the same

amount as before would be transferred from where they are stuck (the aliased address of the

user-controlled address, which has no private key to unstuck the funds) to the original recipient

<mark>`L2CrossDomainMessenger`</mark> <mark>,</mark> effectively un-stucking the funds.


All of this seems to solve an important issue. However, it also introduces an edge case: if the

<mark>`depositTransaction`</mark> is executed from the <mark>`L1CrossDomainMessenger`</mark> and the

<mark>`relayMessage`</mark> execution fails, the funds would then get stuck at the aliased address of

<mark>`L1CrossDomainMessener`</mark> since there is no way for it to call the <mark>`depositTransaction`</mark>

again with different values for <mark>`ethValue`</mark> and <mark>`ethTxValue`</mark> <mark>.</mark> However, such a scenario is

extremely unlikely and can happen only in a few edge-case situations. The <mark>`relayMessage`</mark>

function can revert if:


1) There is not enough gas to finish execution correctly at any step (even before the <u>[external](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2CrossDomainMessenger.sol#L257)</u>

call or before the minimum <u>[gas check). 2)](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2CrossDomainMessenger.sol#L257)</u> <u>[Version](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2CrossDomainMessenger.sol#L172)</u> of the message used is >= 2. 3) <u>[When](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2CrossDomainMessenger.sol#L201)</u>

<mark>`msg.value != _mntValue`</mark> <mark>.</mark> 4) If <u>[gasleft() - RELAY_RESERVED_GAS](https://github.com/mantlenetworkio/mantle-v2/blob/e29d360904db5e5ec81888885f7b7250f8255895/packages/contracts-bedrock/contracts/L2/L2CrossDomainMessenger.sol#L257)</u> underflows.


Even if none of the above situations should occur, the possibility of introducing bugs with

future developments might break this assumption. The aim of this write-up is just to showcase

the impact of the correctness assumption of node and client being broken. As such, we

strongly recommend thoroughly testing the cross-chain features end-to-end. On the other


Mantle V2 Solidity Contracts Audit − Conclusion − 29


hand, if any of the above should happen, funds would get stuck and the only way to recover

funds is to either upgrade the contracts or fix the issue at the protocol level. Two possible

solutions might be:


   - Introduce a special restricted-access function in the <mark>`L1CrossDomainMessenger`</mark>

contract to call the <mark>`depositTransaction`</mark> with custom parameters. This way, a call

can be replicated with <mark>`msg.value == 0`</mark> and <mark>`ethTxValue != 0`</mark> and unstuck funds.

   - Introduce a mechanism at the protocol level that calls <mark>`depositTransaction`</mark> with
```
   msg.sender == L1CrossDomainMessenger & tx.origin !=
```

<mark>`L1CrossDomainMessenger`</mark> with custom parameters as above. This would achieve the

same result.


If no remediation is ultimately applied, consider documenting such a scenario, describing the

potential risks involved.


Mantle V2 Solidity Contracts Audit − Conclusion − 30


