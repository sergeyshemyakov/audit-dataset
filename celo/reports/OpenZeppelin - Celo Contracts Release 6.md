[Research](https://www.openzeppelin.com/research) /
[Security Audits](https://www.openzeppelin.com/research#security-audits)
/

Celo Contracts Audit – Release 6

[Security Audits](https://www.openzeppelin.com/research#security-audits)

# Celo Contracts Audit – Release 6

Table of Content

- February 23, 2022

OpenZeppelin Security

OpenZeppelin Security

Security Audits

In another round of auditing, the cLabs team asked OpenZeppelin to review and audit recent changes to the core contracts of the Celo protocol.

### Scope

This audit was a diff audit, meaning that the scope of the audit was the difference across files in certain pull requests. The pull requests audited in this phase were [8300](https://github.com/celo-org/celo-monorepo/pull/8300), [8349](https://github.com/celo-org/celo-monorepo/pull/8349), [8360](https://github.com/celo-org/celo-monorepo/pull/8360), [8475](https://github.com/celo-org/celo-monorepo/pull/8475), [8750](https://github.com/celo-org/celo-monorepo/pull/8750), [8751](https://github.com/celo-org/celo-monorepo/pull/8751), [8831](https://github.com/celo-org/celo-monorepo/pull/8831), and [8854](https://github.com/celo-org/celo-monorepo/pull/8854). Note that the audit covered production Solidity files as well as upgrade deployment scripts. A more detailed scope is below.

Within the various pull requests, the following files were considered in-scope for this audit:

Within `PR #8300`

* `packages/protocol/contracts/stability/GrandaMento.sol`

Within `PR #8349`

* `packages/protocol/contracts/common/Accounts.sol`
* `packages/protocol/contracts/common/MetaTransactionWallet.sol`
* `packages/protocol/contracts/common/Signatures.sol`
* `packages/protocol/contracts/common/linkedlists/AddressLinkedList.sol`
* `packages/protocol/contracts/common/linkedlists/AddressSortedLinkedList.sol`
* `packages/protocol/contracts/common/linkedlists/AddressSortedLinkedListWithMedian.sol`
* `packages/protocol/contracts/common/linkedlists/IntegerSortedLinkedList.sol`
* `packages/protocol/contracts/governance/Election.sol`
* `packages/protocol/contracts/governance/Governance.sol`
* `packages/protocol/contracts/governance/Proposals.sol`
* `packages/protocol/contracts/identity/Attestations.sol`
* `packages/protocol/contracts/identity/Escrow.sol`
* `packages/protocol/contracts/stability/SortedOracles.sol`
* `packages/protocol/scripts/bash/release-on-devchain.sh`
* `packages/protocol/scripts/truffle/make-release.ts`

Within `PR #8360`

* `packages/protocol/contracts/common/Accounts.sol`

Within `PR #8475`

* `packages/protocol/contracts/governance/Validators.sol`
* `packages/protocol/contracts/stability/GrandaMento.sol`

Within `PR #8750`

* `packages/protocol/contracts/governance/ReleaseGold.sol`

Within `PR #8751`

* `packages/protocol/contracts/governance/ReleaseGold.sol`

Within `PR #8831`

* `packages/protocol/contracts/stability/ExchangeBRL.sol`
* `packages/protocol/contracts/stability/StableTokenBRL.sol`
* `packages/protocol/contracts/stability/proxies/ExchangeBRLProxy.sol`
* `packages/protocol/contracts/stability/proxies/StableTokenBRLProxy.sol`

Within `PR #8854`

* `packages/protocol/contracts/governance/LockedGold.sol`

If a file is not listed above, it should be considered out of scope for this audit. However, some notes were made on auxiliary files.

### Overview of the changes

The pull requests are planned to be included in Release 6 of Celo’s Core Contracts. A brief description is given of each pull request:

* [PR #8300](https://github.com/celo-org/celo-monorepo/pull/8300) changes the directory of the GrandaMento file for CI purposes.
* [PR #8349](https://github.com/celo-org/celo-monorepo/pull/8349) removes the `getVersionNumber` function from all libraries.
* [PR #8360](https://github.com/celo-org/celo-monorepo/pull/8360) introduces the `offchainStorageRoots` mapping on the Accounts contract that can be used to register new storage roots.
* [PR #8475](https://github.com/celo-org/celo-monorepo/pull/8475) implements per-proposal `vetoPeriodSeconds` and limits it to a hardcoded value.
* [PR #8750](https://github.com/celo-org/celo-monorepo/pull/8750) adds a `genericTransfer` function for rescuing ERC-20 tokens from ReleaseGold contracts.
* [PR #8751](https://github.com/celo-org/celo-monorepo/pull/8751) removes the requirement for funding when initializing ReleaseGold and adds an `isFunded` view function.
* [PR #8831](https://github.com/celo-org/celo-monorepo/pull/8831) adds and updates various files for the `StableTokenBRL` release. Note that PR #8831 was not merged at the time of this audit and we reviewed up to [commit 63f75e3](https://github.com/celo-org/celo-monorepo/pull/8831/commits/63f75e33df2fe8f1a9005fce53de302d126fe2c3). The cLabs team confirmed that some parts of the implementation were still in development.
* [PR #8854](https://github.com/celo-org/celo-monorepo/pull/8854) adds a requirement that the reporter of a locked gold `slash` must also be a registered account.

### Vulnerabilities

Below, we list all the vulnerabilities found in this audit.

## Critical severity

None.

## High severity

None.

## Medium severity

None.

## Low severity

### [L01] Missing error message in require statement

[PR #8360](https://github.com/celo-org/celo-monorepo/pull/8360) contains a require statement [in `removeStorageRoot`](https://github.com/celo-org/celo-monorepo/blob/c1f72b8918d8d6f1da2d988afd410bbd0ebad96a/packages/protocol/contracts/common/Accounts.sol#L266) that does not include an error message. Consider including specific and informative error messages in all require statements.

**Update:** *Fixed in PR9010 at commit [`093ac05c3b66b8381ae85bfd4eef6b9eacb1c536`](https://github.com/celo-org/celo-monorepo/pull/9010/commits/093ac05c3b66b8381ae85bfd4eef6b9eacb1c536).*

### [L02] `genericTransfer` can fail without error

In [PR #8750](https://github.com/celo-org/celo-monorepo/pull/8750), the [`genericTransfer` function](https://github.com/celo-org/celo-monorepo/blob/e04bd2af60ed20fad991115d22214b95597ea6be/packages/protocol/contracts/governance/ReleaseGold.sol#L186) of the `ReleaseGold` contract calls the ERC20 member `transfer` function on the `erc20` token, but does not check the returned `bool` of the `transfer`.

This means that with certain ERC20 tokens, the `transfer` could fail and the user would receive no error messages with information on the failing conditions.

Consider updating the token `transfer` to instead use OpenZeppelin’s [`SafeERC20` `safeTransfer` function](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8d7a871609117b2d95074f5f5e92e4c0506584b7/contracts/token/ERC20/utils/SafeERC20.sol#L20), which will provide proper logging in the event of a transfer failure.

**Update:** *Fixed in PR9025 at commit [`6e5a9b26b3d4b34f7370f465ea8ee4fc28183cc3`](https://github.com/celo-org/celo-monorepo/pull/9025/commits/6e5a9b26b3d4b34f7370f465ea8ee4fc28183cc3).*

### [L03] Validators does not increment PATCH version

In [PR #8349](https://github.com/celo-org/celo-monorepo/pull/8349/files#diff-e1c177d3b579272bfa171be200069cbb9961d2072fd5b16d843f5427bd155274), the `getVersionNumber` function is removed [from `AddressLinkedList.sol`](https://github.com/celo-org/celo-monorepo/pull/8349/files#diff-e1c177d3b579272bfa171be200069cbb9961d2072fd5b16d843f5427bd155274).

`Validators.sol` does [not increment the PATCH version](https://github.com/celo-org/celo-monorepo/blob/5ce409a35f5abdf90ed3985dca09eba8df6f565e/packages/protocol/contracts/governance/Validators.sol#L165-L167) even though it is [using `AddressLinkedList.sol`](https://github.com/celo-org/celo-monorepo/blob/5ce409a35f5abdf90ed3985dca09eba8df6f565e/packages/protocol/contracts/governance/Validators.sol#L13). Consider incrementing the PATCH version of the Validators contract to reflect the change.

**Update:** *Fixed in PR8475 as of commit [`4bd0dea1a9a24282c107527175442de879230ced`](https://github.com/celo-org/celo-monorepo/pull/8475/commits/4bd0dea1a9a24282c107527175442de879230ced).*

### [L04] Contract registry has no entry for `BRL`

In [PR #8831](https://github.com/celo-org/celo-monorepo/pull/8831), the [`UsingRegistryV2` contract](https://github.com/celo-org/celo-monorepo/blob/63f75e33df2fe8f1a9005fce53de302d126fe2c3/packages/protocol/contracts/common/UsingRegistryV2.sol) provides various getters returning addresses for contracts comprising the Celo protocol. For each featured protocol contract, a constant pointer is defined and used to inform the corresponding getter. While this mechanism isn’t too complex, duplicating this process in code for a particular contract can lead to errors.

The problem is that the EUR token [has corresponding getters](https://github.com/celo-org/celo-monorepo/blob/63f75e33df2fe8f1a9005fce53de302d126fe2c3/packages/protocol/contracts/common/UsingRegistryV2.sol#L86) for its registry and exchange, while the BRL token does not. So retrieval of corresponding BRL contract address would require code that may be error prone and not follow the standard defined by the `UsingRegistryV2` contract.

Consider defining within the `UsingRegistryV2` contract getters corresponding to the BRL token.

**Update:** *Fixed as of commit [`0afc15a6dac109ada329e12c0d40fec7dcb9f40c`](https://github.com/luisgj/celo-monorepo/commit/0afc15a6dac109ada329e12c0d40fec7dcb9f40c). cLab’s statement for this issue:*

> *“we were indeed missing the getters, but the contract UsingRegistryV2 is not actually used anywhere and the contract to update should have been UsingRegistry.”*

## Notes & Additional Information

### [N01] `addStorageRoot` can add duplicate `url`‘s

In [PR #8360](https://github.com/celo-org/celo-monorepo/pull/8360), the [`addStorageRoot` function](http://github.com/celo-org/celo-monorepo/blob/c1f72b8918d8d6f1da2d988afd410bbd0ebad96a/packages/protocol/contracts/common/Accounts.sol#L250) of the `Accounts` contract adds `url`‘s to an `offchainStorageRoots` array for the `msg.sender`‘s `account`.

This function does not check whether the `url` already exists in the array so there can be duplicate entries added.

This does not pose a security risk. However, it can result in unnecessary gas expenditure. Furthermore the resulting redundant data returned by the [`getOffchainStorageRoots` function](http://github.com/celo-org/celo-monorepo/blob/c1f72b8918d8d6f1da2d988afd410bbd0ebad96a/packages/protocol/contracts/common/Accounts.sol#L279) can confuse offchain clients and add computational complexity to the processing of this data.

Consider using OpenZeppelin’s [`EnumerableMap`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.3.3/contracts/utils/structs/EnumerableMap.sol) as a more practical solution than an array.

**Update:** *Acknowledged, and will not fix. cLab’s statement for this issue:*

> *These duplicates can be checked for on the client side easily, both as a check before adding a duplicate or as a filter on the returned storage roots. To avoid complicating and inflating the cost of the storage root logic, we will not make a change to address this at this time.*

### [N02] `ExchangeBRL.sol` lacks Solidity version pragma

In [PR #8831](https://github.com/celo-org/celo-monorepo/pull/8831), the [`ExchangeBRL.sol`](https://github.com/celo-org/celo-monorepo/pull/8831/files#diff-6459b0f5b9cbcb06cc36f6574d074c5b933c94d14b2ee0755456445c285cb630) file does not define a Solidity version pragma.

In this case, it does not pose a security threat since the `ExchangeBRL` contract has trivial logic and its base contract does have its Solidity version pragma set. But it is considered good practice to always define the Solidity version pragma, since it can be a security concern when the contract contains non-trivial operations which can have different effects across Solidity versions.

Consider defining Solidity version pragmas for all Solidity source files in this project.

**Update:** *Fixed as of commit [`8e0caecc0554d5a3f6fb25b6d024f29ff7562029`](https://github.com/luisgj/celo-monorepo/commit/8e0caecc0554d5a3f6fb25b6d024f29ff7562029).*

### [N03] Not using `SafeMath`

[PR #8360](https://github.com/celo-org/celo-monorepo/pull/8360) contains a `getOffchainStorageRoots` function which concatenates the url bytes of an account using the help of a [local `totalLength` variable](https://github.com/celo-org/celo-monorepo/blob/c1f72b8918d8d6f1da2d988afd410bbd0ebad96a/packages/protocol/contracts/common/Accounts.sol#L286). The `totalLength` is the aggregated length of all the `offchainStorageRoots` elements for a specified account.

Consider using [OpenZeppelin’s `SafeMath`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.3.3/contracts/utils/math/SafeMath.sol) to perform [the addition to `totalLength`](https://github.com/celo-org/celo-monorepo/blob/c1f72b8918d8d6f1da2d988afd410bbd0ebad96a/packages/protocol/contracts/common/Accounts.sol#L288) to prevent overflow and maintain consistency with the method in [`batchGetMetadataURL`](https://github.com/celo-org/celo-monorepo/blob/c1f72b8918d8d6f1da2d988afd410bbd0ebad96a/packages/protocol/contracts/common/Accounts.sol#L911).

**Update:** *Fixed in PR9026 as of commit [`6af9bf0371550f723731080929f9d8946d78d524`](https://github.com/celo-org/celo-monorepo/pull/9026/commits/6af9bf0371550f723731080929f9d8946d78d524).*

### [N04] Incorrect token initialization data

In [PR #8831](https://github.com/celo-org/celo-monorepo/pull/8831), the `migrationsConfig.js` file is updated to include initialization data for the deployment of the `StableTokenBRL`.

This initialization data is [incorrectly set](https://github.com/celo-org/celo-monorepo/pull/8831/files#) to be a copy of the `StableTokenEUR` initialization data. Specifically the `tokenName` and `tokenSymbol` are set incorrectly to `Celo Euro` and `cEUR`.

This incorrect token initialization will not affect the inner logic and accounting of the token itself. However, this mislabelling can cause errors in indexing this token in exchanges, and will likely confuse users which can greatly affect its utility and adoption.

Consider updating the `migrationsConfig.js` to have appropriate `tokenName` and `tokenSymbol` set specific to the `StableTokenBRL`.

**Update:** *Fixed as of commit [`92441e39e3b5cbb29bb8af6ed914b90a874d9afe`](https://github.com/luisgj/celo-monorepo/commit/92441e39e3b5cbb29bb8af6ed914b90a874d9afe). cLabs comments on the issue:*

> *As a clarification, wanted to point out that file is only used for testing proposals and not for mainnet (not even testnets).*

### Conclusions

No critical or high severity issues were found. Some changes were proposed to follow best practices and reduce potential attack surface.