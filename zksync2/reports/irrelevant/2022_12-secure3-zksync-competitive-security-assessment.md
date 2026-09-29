# zkSync Competitive Security Assessment

**Auditor:** Secure3  
**Date:** December 5, 2022  
**Methodology:** Audit contest, business-logic and code review, privileged-role review, static analysis  
**Platform / language:** Solidity  
**Audit commit:** `8bc57b7273a61b04d9ca96b5d3443f5a8f0a150e`  
**Original report:** [Secure3 PDF](https://secure3-public-docs.s3.us-west-2.amazonaws.com/pdf/453/b17dffeb.pdf)

> Recovery note: Secure3's original 18-page PDF currently returns HTTP 404 and no Internet Archive snapshot was available. This Markdown copy was recovered from the complete, page-indexed text retained by the web search index. It is included so the public audit is not lost from the dataset.

## Summary

The assessment reviewed zkSync's Layer 1 smart contracts. Secure3 used static analysis and manual review, supplemented by an audit contest whose participants included security researchers covered by NDAs.

The assessment reported no critical findings, three medium-severity findings, one low-severity finding, and four informational findings. At publication, four findings were fixed, three acknowledged, and two declined (the report's totals count status/category combinations rather than eight unique rows).

## Scope

All files were reviewed at commit `8bc57b7273a61b04d9ca96b5d3443f5a8f0a150e`:

- `contracts/zksync/facets/Executor.sol`
- `contracts/zksync/libraries/PairingsBn254.sol`
- `contracts/bridge/L1ERC20Bridge.sol`
- `contracts/zksync/libraries/Diamond.sol`
- `contracts/zksync/facets/Mailbox.sol`
- `contracts/bridge/L1EthBridge.sol`
- `contracts/zksync/facets/Getters.sol`
- `contracts/common/AllowList.sol`
- `contracts/zksync/facets/DiamondCut.sol`
- `contracts/zksync/facets/Governance.sol`
- `contracts/zksync/interfaces/IMailbox.sol`
- `contracts/common/L2ContractHelper.sol`
- `contracts/zksync/interfaces/IExecutor.sol`
- `contracts/zksync/Storage.sol`
- `contracts/zksync/DiamondInit.sol`
- `contracts/zksync/libraries/PriorityQueue.sol`
- `contracts/dev-contracts/Multicall.sol`
- `contracts/common/interfaces/IAllowList.sol`
- `contracts/zksync/libraries/TranscriptLib.sol`
- `contracts/zksync/interfaces/IGetters.sol`
- `contracts/common/ReentrancyGuard.sol`
- `contracts/zksync/Config.sol`
- `contracts/bridge/interfaces/IL1Bridge.sol`
- `contracts/zksync/DiamondProxy.sol`
- `contracts/common/libraries/UnsafeBytes.sol`
- `contracts/zksync/libraries/Merkle.sol`
- `contracts/zksync/DiamondUpgradeInit.sol`
- `contracts/zksync/interfaces/IDiamondCut.sol`
- `contracts/zksync/interfaces/IGovernance.sol`
- `contracts/dev-contracts/RevertTransferERC20.sol`
- `contracts/dev-contracts/TestnetERC20Token.sol`
- `contracts/bridge/interfaces/IL2Bridge.sol`
- `contracts/common/interfaces/IERC20.sol`
- `contracts/zksync/facets/Base.sol`
- `contracts/common/libraries/UncheckedMath.sol`
- `contracts/dev-contracts/RevertReceiveAccount.sol`
- `contracts/common/AllowListed.sol`
- `contracts/zksync/interfaces/IZkSync.sol`
- `contracts/dev-contracts/RevertFallback.sol`
- `contracts/common/Dependencies.sol`

## Findings overview

| ID | Finding | Severity | Status | Contributor |
|---|---|---:|---|---|
| ZKS-1 | Contract with payable function but lack of withdraw function | Medium | Declined | BradMoonUESTC |
| ZKS-2 | Potential security issue if revealing secret X | Informational | Acknowledged | lfzkoala |
| ZKS-3 | Should check whether the transfer is successful | Medium | Fixed | lfzkoala, iczc |
| ZKS-4 | Useless mappings should be deleted | Informational | Fixed | zircon |
| ZKS-5 | `Executor._blockMetaParameters()` unused input `_block` | Informational | Fixed | lfzkoala |
| ZKS-6 | `IL2Bridge` functions `l1TokenAddress` and `l1Bridge` never defined | Informational | Acknowledged | lfzkoala |
| ZKS-7 | `msg.value` should be restricted when depositing ERC20 | Low | Declined | zircon |
| ZKS-8 | `claimFailedDeposit` logic may lead to double-spend risk | Medium | Acknowledged | iczc |

## ZKS-1: Contract with payable function but lack of withdraw function

**Location:** `contracts/zksync/DiamondUpgradeInit.sol#L10`  
**Severity:** Medium  
**Status:** Declined

`DiamondUpgradeInit` has the payable function `forceDeployL2Contract`, but no withdrawal function or equivalent logic. The reporter warned that ETH might become locked and recommended an emergency-withdraw function.

**Client response:** The function is used only through a delegate call during diamond initialization. Matter Labs therefore did not consider withdrawal from the facet/target/implementation contract necessary.

## ZKS-2: Potential security issue if revealing secret X

**Location:** `contracts/zksync/facets/Executor.sol#L334-L343`  
**Severity:** Informational  
**Status:** Acknowledged

The finding warned that disclosure of the PLONK trapdoor `X` could allow an adversary to forge a recursive proof. It recommended ensuring that the trapdoor was generated randomly and stored securely.

**Client response:** Acknowledged. The implementation reused the trusted setup from zkSync v1.

## ZKS-3: Should check whether the transfer is successful

**Locations:** `contracts/bridge/L1ERC20Bridge.sol#L125`, `contracts/bridge/L1ERC20Bridge.sol#L248`  
**Severity:** Medium  
**Status:** Fixed

The ERC-20 `transfer` and `transferFrom` calls did not use a return value or a `SafeERC20` wrapper, so unsuccessful token transfers might not be detected. The auditors recommended using `SafeERC20` and checking transfer success.

**Client response:** Fixed.

## ZKS-4: Useless mappings should be deleted

**Locations:** `contracts/bridge/L1EthBridge.sol#L142`, `contracts/bridge/L1ERC20Bridge.sol#L182`  
**Severity:** Informational  
**Status:** Fixed

The contracts cleared deposit mappings by assigning zero. The auditor recommended using Solidity's `delete` operator to release the storage slots and obtain the applicable gas refund.

**Client response:** Gas optimization fixed.

## ZKS-5: `Executor._blockMetaParameters()` unused input `_block`

**Location:** `contracts/zksync/facets/Executor.sol#L398`  
**Severity:** Informational  
**Status:** Fixed

The `_blockMetaParameters` function did not use its `_block` calldata argument. The auditor recommended either removing the parameter or using it if required by the intended logic.

**Client response:** Fixed.

## ZKS-6: `IL2Bridge` functions never defined

**Locations:** `contracts/bridge/interfaces/IL2Bridge.sol#L21`, `contracts/bridge/interfaces/IL2Bridge.sol#L25`  
**Severity:** Informational  
**Status:** Acknowledged

The interface declared `l1TokenAddress` and `l1Bridge`, but the scoped implementation did not define either function. The auditor recommended confirming that the interface methods were needed and adding the corresponding implementations if so.

**Client response:** The implementations were part of the protocol's L2 code, which was outside this audit's scope.

## ZKS-7: `msg.value` should be restricted when depositing ERC20

**Location:** `contracts/bridge/L1ERC20Bridge.sol#L97-L117`  
**Severity:** Low  
**Status:** Declined

Users depositing ERC-20 tokens could attach excess ETH and might appear unable to retrieve it. The auditor recommended limiting the maximum and minimum ETH value that could accompany a deposit.

**Client response:** This behavior was by design. ETH was used to pay fees and forwarded to the mailbox, which retained it as the fee for the ERC-20 deposit.

## ZKS-8: `claimFailedDeposit` logic may lead to double-spend risk

**Locations:** `contracts/bridge/L1EthBridge.sol#L115`, `contracts/bridge/L1ERC20Bridge.sol#L159`  
**Severity:** Medium  
**Status:** Acknowledged

The L1 bridge allowed a user to claim assets for an L2 deposit shown as failed. The reporter warned that, without checking the corresponding L2 state, a deposit might conceivably be finalized on L2 and still reclaimed on L1. The recommendation was to check the L2 asset status before processing a failed-deposit claim.

**Client response:** Matter Labs stated that the L2 implementation, which was outside this audit's scope, covered this case.

