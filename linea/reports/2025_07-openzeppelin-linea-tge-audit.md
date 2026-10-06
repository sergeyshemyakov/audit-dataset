# Linea TGE Audit

Source: [https://www.openzeppelin.com/news/linea-tge-audit](https://www.openzeppelin.com/news/linea-tge-audit)

- September 3, 2025

OpenZeppelin Security

OpenZeppelin Security

Security Audits

## Summary

**Type:** Layer 2 & Rollups **Timeline:** July 22, 2025 → July 24, 2025 **Languages:** Solidity **Findings**Total issues: 10 (5 resolved, 1 partially resolved) Critical: 0 (0 resolved) · High: 0 (0 resolved) · Medium: 0 (0 resolved) · Low: 3 (1 resolved, 1 partially resolved) **Notes & Additional Information**6 notes raised (3 resolved)

## Scope

OpenZeppelin audited the [Consensys/linea-tokens](https://github.com/Consensys/linea-tokens/) repository at commit [44640f0](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/). In addition, [pull rquest #10](https://github.com/Consensys/linea-tokens/pull/10/) was audited up to commit [86605a9](https://github.com/Consensys/linea-tokens/pull/10/commits/86605a938a033e93f3a63a7a263628c583840e4d) while [pull request #11](https://github.com/Consensys/linea-tokens/pull/11/) was audited up to commit [b9aad54](https://github.com/Consensys/linea-tokens/pull/11/commits/b9aad5421a6fe8bd52602209bd38472911e19d77).

***Update**: We have completed the review of all submissions and finalized the audit report. The final commit reviewed is [91036da](https://github.com/Consensys/linea-tokens/commit/91036daf2331610841796772f8fbb2fcc4a9233f). We note that the additional changes to in-scope files since [44640f0](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/) are related to fixes from audit engagements conducted concurrently with ours.*

*In addition, we have verified the deployed bytecode matches the code at [commit 91036da](https://github.com/Consensys/linea-tokens/commit/91036daf2331610841796772f8fbb2fcc4a9233f).*

*Lastly, we have verified that the TGE contract code and exported artifacts have been migrated from the private repository into the open-source [linea-monorepo](https://github.com/Consensys/linea-monorepo) at release tag [contract-audit-2025-07-30](https://github.com/Consensys/linea-monorepo/releases/tag/contract-audit-2025-07-30). The in-scope files and artifacts under [contracts-tge/src](https://github.com/Consensys/linea-monorepo/tree/main/contracts-tge/src) and [contracts-tge/exported-artifacts](https://github.com/Consensys/linea-monorepo/tree/main/contracts-tge/exported-artifacts) match exactly with those from the audited commit in the private repository.*

In scope were the following files:

```
 src
├── L1
│   ├── LineaToken.sol
│   └── interfaces
│       └── ILineaToken.sol
├── L2
│   ├── L2LineaToken.sol
│   └── interfaces
│       └── IL2LineaToken.sol
├── airdrops
│   └── TokenAirdrop.sol
└── interfaces
    ├── IGenericErrors.sol
    └── IMessageService.sol
```

## System Overview

This system includes two ERC-20 token contracts deployed on Ethereum L1 and Linea L2, along with an airdrop contract deployed on L2. Together, these contracts enable cross-chain token minting, supply synchronization, and structured airdrop distribution based on predefined external signals.

- The **L1 token contract**, `LineaToken`, is an upgradeable ERC-20 contract with burnable, permit-based approvals and role-based access control. It supports controlled minting via the `MINTER_ROLE` and uses Linea's message service to propagate total supply updates to the L2 counterpart.
- The **L2 token contract**, `L2LineaToken`, is the bridged version of the L1 token. It includes `ERC20VotesUpgradeable`, allowing voting power delegation and integration with applications that rely on token-weighted governance or identity-based utility.
- The **`TokenAirdrop` contract** is deployed on L2 and allows eligible users to claim an allocation of L2 tokens. Rather than relying on an allowlist or merkle root, it calculates allocations dynamically based on a user’s balance across up to three external contracts. These external contracts do not represent transferable tokens and may serve purely as reference points for determining eligibility or proportional distribution. The design assumes that the balances of these contracts are immutable per user, which ensures airdrop fairness and resistance to Sybil or replay attacks.

This structure enables a secure, modular, and upgradeable distribution system that connects L1-L2 token flows with transparent and programmable airdrop logic.

## Security Model and Trust Assumptions

During the audit, the following trust assumptions were made:

- The contracts referenced as `PRIMARY_FACTOR_ADDRESS`, `PRIMARY_CONDITIONAL_MULTIPLIER_ADDRESS`, and `SECONDARY_FACTOR_ADDRESS` in the airdrop must meet specific requirements to ensure allocation integrity:

  - All three contracts must provide the interface for the ERC-20 standard's `balanceOf` functionality.
  - These tokens must be soulbound (non-transferable) to prevent users from abusing the system by moving balances between wallets.
  - The `PRIMARY_FACTOR_ADDRESS` and `SECONDARY_FACTOR_ADDRESS` must have the same number of decimals as the airdrop token.
  - The `PRIMARY_CONDITIONAL_MULTIPLIER_ADDRESS` must have 9 decimals, as it is used as a multiplier and divided by a fixed denominator of 1e9.
  - The balance multiplication between `PRIMARY_FACTOR_ADDRESS` and `PRIMARY_CONDITIONAL_MULTIPLIER_ADDRESS` must not overflow a `uint256` value. This is especially critical due to the multiplication done in [this line](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/src/airdrops/TokenAirdrop.sol#L112).
  - The contract owner must avoid setting up addresses that are not controlled by real users. Since any address can be claimed on behalf of, adding an unowned address would result in an irrecoverable loss of tokens if someone were to claim it.
- Transactions interacting with the system should consume less than 250,000 gas to remain compatible with Linea’s message service infrastructure and benefit from fee-free postman execution for L1 → L2 messages.
- The deployment and configuration process must follow a specific sequence to ensure correctness:

  1. Both the L1 and L2 token contracts should be deployed first on Ethereum mainnet and Linea, respectively.
  2. On Linea, the bridge contract owner must call `setCustomContract` to register the L1 token contract as the designated target for the corresponding L2 token.
  3. The `confirmDeployment` function should be called on the Linea token bridge to notify the mainnet bridge that deployment on L2 is complete. This updates the `nativeToBridgedToken` mapping to reflect the `DEPLOYED_STATUS`.
  4. Once the bridging setup is finalized, the airdrop contract can be deployed on Linea and token funds can be transferred to it.

This deployment order guarantees safe airdrop initialization, consistent bridging logic, and secure synchronization between L1 and L2 states.

### Privileged Roles

The following privileged roles were identified in the system:

- `LineaToken` (L1) defines two roles:
  - `DEFAULT_ADMIN_ROLE`, used to manage roles and administrative settings.
  - `MINTER_ROLE`, used to mint new tokens.
- `L2LineaToken` only accepts messages from the official token bridge and messaging service of Linea.
- `TokenAirdrop` is governed by a single owner that is assigned at deployment. This owner has the authority to withdraw unclaimed tokens after the claim window closes and can trigger the contract’s `withdraw` function after the claiming period has ended.
- Cross-chain trust boundaries are enforced via `MessageServiceBase` modifiers (`onlyMessagingService`, `onlyAuthorizedRemoteSender`), ensuring that only authenticated L1/L2 message services and senders can invoke cross-chain sync logic.

## Low Severity

### Incomplete Docstrings

Throughout the codebase, the following instance of incomplete docstrings was identified:

- In `IL2LineaToken.sol`, within the [`L1LineaTokenTotalSupplySynced`](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/./src/L2/interfaces/IL2LineaToken.sol#L12) event, the `l1BlockTimestamp` and `l1TotalSupply` parameters are not documented.

Consider thoroughly documenting the event (and its parameters) that are part of a contract's public API. When writing docstrings, consider following the [Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html) (NatSpec).

***Update:** Resolved in [pull request #16](https://github.com/Consensys/linea-tokens/pull/16).*

### `Primary_Factor_Address` & `Primary_Conditional_Multiplier_Address` Checks optimization

The `TokenAirdrop` contract contains [these two `require` statements](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/src/airdrops/TokenAirdrop.sol#L92-L94). The intent is to ensure that either both `_primaryFactorAddress` and `_primaryConditionalMultiplierAddress` have been set (non-zero) or both are unset (zero). This guards against only one of them being initialized while the other is not. However, these two conditions are logically redundant and can be simplified. Moreover, in subsequent logic in the [`calculateAllocation`](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/src/airdrops/TokenAirdrop.sol#L111-L113) function, the check can also be simplified based on the guarantee enforced by the constructor.

Consider replacing both of the `require` statements in the constructor of the `TokenAirdrop` with a single equivalent condition which ensures that both addresses are either set or unset. In addition, simplify the conditional in `calculateAllocation` to check just one of the two addresses.

***Update:** Partially resolved in [pull request #10](https://github.com/Consensys/linea-tokens/pull/10). While the check in `calculateAllocation` has been simplified, the `require` statements in the constructor can be simplified further.*

### Floating Pragma

Pragma directives should be fixed to clearly identify the Solidity version with which the contracts will be compiled.

Throughout the codebase, multiple instances of floating pragma directives were identified:

- `ILineaToken.sol` has the [`solidity ^0.8.30`](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/./src/L1/interfaces/ILineaToken.sol#L2) floating pragma directive.
- `IL2LineaToken.sol` has the [`solidity ^0.8.30`](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/./src/L2/interfaces/IL2LineaToken.sol#L2) floating pragma directive.
- `IGenericErrors.sol` has the [`solidity ^0.8.30`](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/./src/interfaces/IGenericErrors.sol#L2) floating pragma directive.
- `IMessageService.sol` has the [`solidity ^0.8.30`](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/./src/interfaces/IMessageService.sol#L2) floating pragma directive.

Consider using fixed pragma directives.

***Update:** Acknowledged, not resolved. The team stated:*

> *Acknowledged: These have been left intentionally open for others to use for future/higher versions of their contracts. The top level deployables will dictate the compiler version which has been set without the floating pragma. No changes expected.*

## Notes & Additional Information

### Ambiguous Call to Parent Contract

In the `L2LineaToken` contract, the [`super.nonces`](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/./src/L2/L2LineaToken.sol#L121) call is ambiguous.

Consider avoiding ambiguous calls to parent contracts and explicitly specifying which parent contract's function is being called.

***Update:** Acknowledged, not resolved. The team stated:*

> *Acknowledged: When removing the `super.` and using `permit` explicitly, the Voting nonces is bypassed. It is safer to leave it in.*

### Functions Updating State Without Event Emissions

Throughout the codebase, multiple instances of functions updating the state without an event emission were identified:

- The [`initialize` function](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/./src/L1/LineaToken.sol#L41-L60) in `LineaToken.sol`
- The [`initialize` function](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/./src/L2/L2LineaToken.sol#L45-L68) in `L2LineaToken.sol`
- The [`constructor` function](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/./src/airdrops/TokenAirdrop.sol#L79-L101) in `TokenAirdrop.sol`

Consider emitting events whenever there are state changes to improve the clarity of the codebase and make it less error-prone.

***Update:** Resolved in [pull request #16](https://github.com/Consensys/linea-tokens/pull/16) and [pull request #10](https://github.com/Consensys/linea-tokens/pull/10).*

### Lack of Indexed Event Parameters

Throughout the codebase, multiple instances of events not having indexed parameters were identified:

- The [`L2TokenAddressSet` event](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/./src/L1/interfaces/ILineaToken.sol#L12) of `ILineaToken.sol`
- The [`L1TotalSupplySyncStarted` event](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/./src/L1/interfaces/ILineaToken.sol#L19) of `ILineaToken.sol`
- The [`L1LineaTokenTotalSupplySynced` event](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/./src/L2/interfaces/IL2LineaToken.sol#L12) of `IL2LineaToken.sol`
- The [`TokenBalanceWithdrawn` event](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/./src/airdrops/TokenAirdrop.sol#L24) of `TokenAirdrop.sol`

To improve the ability of off-chain services to search and filter for specific events, consider [indexing event parameters](https://solidity.readthedocs.io/en/latest/contracts.html#events).

***Update:** Acknowledged, not resolved. The team stated:*

> Acknowledged. The event values themselves are variable (e.g., `TokenBalanceWithdrawn` could be anything), there wouldn't be event querying by that value. If they were, adding the indexing would be prudent. No changes will be made for these.

### Post-EIP-6780 `selfdestruct` Does Not Delete Code

The intended behavior is that calling the `withdraw()` function in [`TokenAirdrop.sol`](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/src/airdrops/TokenAirdrop.sol#L152) should remove the contract entirely, transferring any remaining ETH to the caller and preventing further interaction with the contract address. However, due to the behavior change introduced in EIP-6780, the use of `selfdestruct(payable(msg.sender))` no longer removes the contract’s bytecode—it only transfers ETH.

Consider replacing `selfdestruct` with a direct ETH transfer for improved code clarity and better alignment with post-EIP-6780 behavior.

***Update:** Resolved in [pull request #12](https://github.com/Consensys/linea-tokens/pull/12). The team stated:*

> Acknowledged: Originally we expected the call to be on our network while the London EVM version applied. This has been removed.

### Indecisive Licenses

Throughout the codebase, multiple instances of files having indecisive SPDX licenses were identified:

- The `// SPDX-License-Identifier: Apache-2.0 OR MIT` SPDX license in [`LineaToken.sol`](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/./src/L1/LineaToken.sol)
- The `// SPDX-License-Identifier: Apache-2.0 OR MIT` SPDX license in [`ILineaToken.sol`](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/./src/L1/interfaces/ILineaToken.sol)
- The `// SPDX-License-Identifier: Apache-2.0 OR MIT` SPDX license in [`L2LineaToken.sol`](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/./src/L2/L2LineaToken.sol)
- The `// SPDX-License-Identifier: Apache-2.0 OR MIT` SPDX license in [`IL2LineaToken.sol`](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/./src/L2/interfaces/IL2LineaToken.sol)
- The `// SPDX-License-Identifier: Apache-2.0 OR MIT` SPDX license in [`TokenAirdrop.sol`](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/./src/airdrops/TokenAirdrop.sol)
- The `// SPDX-License-Identifier: Apache-2.0 OR MIT` SPDX license in [`IGenericErrors.sol`](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/./src/interfaces/IGenericErrors.sol)
- The `// SPDX-License-Identifier: Apache-2.0 OR MIT` SPDX license in [`IMessageService.sol`](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/./src/interfaces/IMessageService.sol)

Consider specifying only one license to prevent possible licensing ambiguity.

***Update:** Acknowledged, not resolved. The team stated:*

> Acknowledged: This has been done on purpose to give consumers of our code flexibility when incorporating into their codebase. The intent is that whichever one their codebase uses applies.

### Unnecessary Data Field in Event Emission

In `LineaToken.sol`, the [`emit L1TotalSupplySyncStarted(block.timestamp, totalSupply);`](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/./src/L1/LineaToken.sol#L84) event emission includes unnecessary data fields such as `block.number` or `block.timestamp`.

To improve code clarity and maintainability, consider removing unnecessary data fields like `block.number` or `block.timestamp` from event emissions since they are already included in the block information.

***Update:** Resolved in [pull request #15](https://github.com/Consensys/linea-tokens/pull/15). The team stated:*

> Acknowledged: It was originally in for clarity, however, removing it is better practice and has been done.

## Client Reported

### `L2LineaToken` does not require `ERC20BurnableUpgradeable` inheritance

The `L2LineaToken` contract includes a custom implementation of the [`burn` function](https://github.com/Consensys/linea-tokens/blob/44640f0965a5c7465b99769a5d241a9a1cb3a2ef/src/L2/L2LineaToken.sol#L89-L94) with additional authorization logic specific to the Linea token bridge. As a result, inheriting from `ERC20BurnableUpgradeable` was unnecessary and introduced extra functionality that the token does not utilize.

This issue was also identified by the Linea team during a parallel audit, and the inheritance from `ERC20BurnableUpgradeable` was removed in [commit b9aad54](https://github.com/Consensys/linea-tokens/pull/11/commits/b9aad5421a6fe8bd52602209bd38472911e19d77).

***Update:** Resolved in [commit b9aad54](https://github.com/Consensys/linea-tokens/pull/11/commits/b9aad5421a6fe8bd52602209bd38472911e19d77).*

## Conclusion

The audited system supports the Linea Token Generation Event (TGE), enabling cross-chain token minting, supply synchronization, and airdrop distribution. It includes a bridged ERC-20 token pair and an airdrop contract that calculates allocations based on balances in external reference contracts.

No high- or critical-severity issues were identified. Only minor observations were reported, primarily related to the handling of specific edge cases and documentation. The correctness of the bridging flow and the assumptions around allocation inputs are central to the system’s integrity and should be carefully monitored during deployment.

The Linea team is appreciated for being responsive and collaborative throughout the audit process.

Ready to secure your code?

[Request an Audit →](https://www.openzeppelin.com/request?utm_campaign=Audit%20Reports%202024&utm_source=mybloglog&utm_medium=social&utm_term=CTARequestAudit&utm_content=AuditBlogPost)
