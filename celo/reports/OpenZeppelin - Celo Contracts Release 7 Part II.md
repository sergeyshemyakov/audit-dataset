[Research](https://www.openzeppelin.com/research) /
[Security Audits](https://www.openzeppelin.com/research#security-audits)
/

Celo Contracts Audit

[Security Audits](https://www.openzeppelin.com/research#security-audits)

# Celo Contracts Audit

Table of Content

- June 16, 2022

OpenZeppelin Security

OpenZeppelin Security

Security Audits

## 

## Table of Contents

* [Table of Contents](#table-of-contents)
* [Summary](#summary)
* [Scope](#scope)
  + [Overview of changes](#overview-of-changes)
  + [Findings](#findings)
* [Low Severity](#low-severity)
  + [Missing oracle can cause unexpected behavior](#missing-oracle-can-cause-unexpected-behavior)
  + [Incorrect version number](#incorrect-version-number)
* [Notes & Additional Information](#notes-additional-information)
  + [Documentation mismatch](#documentation-mismatch)
  + [Inconsistent code](#inconsistent-code)
  + [Inconsistent test coverage](#inconsistent-test-coverage)
* [Conclusions](#conclusions)

## Summary

Type
:   DeFi

Timeline
:   From 2022-03-22
:   To 2022-03-28

Languages
:   Solidity

Total Issues
:   5 (5 resolved)

## Scope

We reviewed all changes to production Solidity files in the following pull requests:

* [PR #9252](https://github.com/celo-org/celo-monorepo/pull/9252) up to [commit 15f6b6d](https://github.com/celo-org/celo-monorepo/pull/9252/commits/15f6b6d2a983bc0c6f0836e12d1178ae609d679f)
* [PR #9367](https://github.com/celo-org/celo-monorepo/pull/9367) up to [commit 0003e85](https://github.com/celo-org/celo-monorepo/pull/9367/commits/0003e857988c624fb579e555e4a995505bd8ae9d)
* [PR #9369](https://github.com/celo-org/celo-monorepo/pull/9369) up to [commit 2d73adc](https://github.com/celo-org/celo-monorepo/pull/9369/commits/2d73adcc2cb28cb22c2beb0bd1dec1dfebb42cfb)

The following contracts were in scope:

* PR #9252
  + [packages/protocol/contracts/stability/Exchange.sol](https://github.com/celo-org/celo-monorepo/blob/15f6b6d2a983bc0c6f0836e12d1178ae609d679f/packages/protocol/contracts/stability/Exchange.sol)
* PR #9367
  + [packages/protocol/contracts/stability/Reserve.sol](https://github.com/celo-org/celo-monorepo/blob/0003e857988c624fb579e555e4a995505bd8ae9d/packages/protocol/contracts/stability/Reserve.sol)
* PR #9369
  + [packages/protocol/contracts/governance/LockedGold.sol](https://github.com/celo-org/celo-monorepo/blob/2d73adcc2cb28cb22c2beb0bd1dec1dfebb42cfb/packages/protocol/contracts/governance/LockedGold.sol)

### Overview of changes

A summary of the changes in the pull requests:

* PR #9252 – Implements bounds checks on new spread values to ensure they are less than or equal to 1 in [`setSpread`](https://github.com/celo-org/celo-monorepo/pull/9252/files#diff-7ed4b70452014859fd0baa0e2346f7bd804d43f6dc055a71e5bcda62846814d6R297)
* PR #9367 – Removes the requirement for an active oracle when adding new stablecoins with [`addToken`](https://github.com/celo-org/celo-monorepo/pull/9367/files#diff-206f7acad14ba77f0f3c3a30a1f179abd34d543a4ffae6e5b92a47ff458731f0R226)
* PR #9369 – Implements a [`getPendingWithdrawal`](https://github.com/celo-org/celo-monorepo/pull/9369/files#diff-0525e322f4a11b610acde8fb83e0476d58bfce04b4a7f9d16f9493046056a7f1R294) function in order to allow single withdrawal lookups

These changes, along with those from Part 1 of this audit, comprise cLab’s `Release 7` for the [celo-monorepo](https://github.com/celo-org/celo-monorepo).

### Findings

Here we present our findings.

## Low Severity

### Missing oracle can cause unexpected behavior

Prior to pull request [#9367](https://github.com/celo-org/celo-monorepo/pull/9367/files), the `addToken` function in the `Reserve` contract checked that an oracle exists for the token being added, and the oracle returns a non-zero exchange rate. These checks ensured that every token in the `_tokens` array had a corresponding oracle.

With the oracle checks removed from `addToken` by this pull request, it is possible to enter a state where the token has been added but the oracle doesn’t exist yet. However, the `getReserveRatio` function in the `Reserve` contract assumes that every token has a corresponding oracle that returns non-zero exchange rate values. If no oracle exists for a specific token, [the converted price calculation](https://github.com/celo-org/celo-monorepo/blob/eb9ded122872bb3f2682c282a99dc4349b59aa7d/packages/protocol/contracts/stability/Reserve.sol#L542) will result in a divide-by-zero error.

The following contracts also contain code which can incorrectly divide by zero if queried with an oracle that is returning zero:

* [`getGasPriceMinimum`](https://github.com/celo-org/celo-monorepo/blob/eb9ded122872bb3f2682c282a99dc4349b59aa7d/packages/protocol/contracts/common/GasPriceMinimum.sol#L126) of `GasPriceMinimum`
* [`getTargetTotalEpochPaymentsInGold`](https://github.com/celo-org/celo-monorepo/blob/eb9ded122872bb3f2682c282a99dc4349b59aa7d/packages/protocol/contracts/governance/EpochRewards.sol#L409) of `EpochRewards`

Consider implementing additional logic that excludes tokens without oracles from the reserve ratio calculation, as well as including checks to ensure helpful errors are thrown rather than divide-by-zero errors.

***Update:** Partially fixed. The `getReserveRatio` function was fixed in [PR #9527](https://github.com/celo-org/celo-monorepo/pull/9527). Both `getGasPriceMinimum` and `getTargetTotalEpochPaymentsInGold` remain unchanged. Celo’s statement for this issue:*

> *Updating `getGasPriceMinimum` is not critical, as the only reasonable behavior when there is no oracle report is to revert (could be nicer to fail with a relevant require message, but this is an edge case). Updating `getTargetTotalEpochPaymentsInGold` is not necessary as it only ever converts from cUSD (not other cStables), which already has an oracle rate.*

### Incorrect version number

Pull request [#9252](https://github.com/celo-org/celo-monorepo/pull/9252/files#diff-7ed4b70452014859fd0baa0e2346f7bd804d43f6dc055a71e5bcda62846814d6R299-R302) changes the behavior of the `setSpread` function in `Exchange.sol`, but does not update the version reported by the [`getVersionNumber`](https://github.com/celo-org/celo-monorepo/blob/83b5c21c20fb22d17c46f73bc67b3de88f69e171/packages/protocol/contracts/stability/Exchange.sol#L68) function.

Consider incrementing the patch number returned by `getVersionNumber` in order to adhere to the [smart contract release process](https://docs.celo.org/community/release-process/smart-contracts).

***Update:** Fixed in [PR #8334](https://github.com/celo-org/celo-monorepo/pull/8334).*

## Notes & Additional Information

### Documentation mismatch

The online Celo docs state that before fully activating a new stable token, [it is required to have at least one oracle report](https://docs.celo.org/celo-codebase/protocol/stability/adding_stable_assets#oracle-report). The documentation points to [line number 223](https://github.com/celo-org/celo-monorepo/blob/9b43d07b35c9d50389f5f2f53ddfa0c21f16d0f2/packages/protocol/contracts/stability/Reserve.sol#L223) in the `Reserve` contract’s `addToken` function as the enforcer of this requirement. Pull request [#9367](https://github.com/celo-org/celo-monorepo/pull/9367/files) removed that code from the `Reserve` contract, invalidating the online documentation.

Consider updating the online Celo documentation to accurately reflect the new behavior of the `addToken` function.

***Update:** Fixed in [PR #312](https://github.com/celo-org/docs/pull/312) of the [celo-org/docs](https://github.com/celo-org/docs) repository.*

### Inconsistent code

In pull request [#9252](https://github.com/celo-org/celo-monorepo/pull/9252/files), code was added in order to ensure newly set spread values are valid. The change updated the [`setSpread`](https://github.com/celo-org/celo-monorepo/pull/9252/files#diff-7ed4b70452014859fd0baa0e2346f7bd804d43f6dc055a71e5bcda62846814d6R297) function in the [`Exchange`](https://github.com/celo-org/celo-monorepo/blob/83b5c21c20fb22d17c46f73bc67b3de88f69e171/packages/protocol/contracts/stability/Exchange.sol) contract.

Similar to the `Exchange` contract, the [`GrandaMento`](https://github.com/celo-org/celo-monorepo/blob/83b5c21c20fb22d17c46f73bc67b3de88f69e171/packages/protocol/contracts/stability/GrandaMento.sol#L584) contract includes an [implementation of `setSpread`](https://github.com/celo-org/celo-monorepo/blob/83b5c21c20fb22d17c46f73bc67b3de88f69e171/packages/protocol/contracts/stability/GrandaMento.sol#L584) which already has a bounds check, however the two implementations differ in terms of logic and error messages.

In favor of consistent code across the repository, consider updating the code to make both implementations match.

***Update:** Fixed in [PR #9459](https://github.com/celo-org/celo-monorepo/pull/9459).*

### Inconsistent test coverage

Pull request [#9369](https://github.com/celo-org/celo-monorepo/pull/9369/files) introduced a new `getPendingWithdrawal` function to address the possibility that the existing [`getPendingWithdrawals`](https://github.com/celo-org/celo-monorepo/blob/83b5c21c20fb22d17c46f73bc67b3de88f69e171/packages/protocol/contracts/governance/LockedGold.sol#L270) function can run out of gas if the number of pending withdrawals is excessive. In the pull request, a new test case for `getPendingWithdrawal` was added in [`lockedgold.ts`](https://github.com/celo-org/celo-monorepo/pull/9369/files#diff-d739e57b8fd219f2a52b905af80267afe0ad4fab72d573c7b67ce7add15da752L205-R209), but the corresponding test for `getPendingWithdrawals` was removed in the process, even though this function is still in use. Furthermore, there are not matching test cases for both functions.

To improve code coverage, consider restoring the test that was removed and providing equivalent test cases for both functions.

***Update:** Fixed in [PR #9460](https://github.com/celo-org/celo-monorepo/pull/9460).*

## Conclusions

No critical or high severity issues have been found. Recommendations and fixes have been proposed to improve code quality, minimize errors, and address uncommon but possible operating conditions which could result in error.