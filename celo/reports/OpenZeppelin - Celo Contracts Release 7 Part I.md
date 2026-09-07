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

## Table of Contents

* [Table of Contents](#table-of-contents)
* [Summary](#summary)
* [Scope](#scope)
  + [Overview of changes](#overview-of-changes)
  + [Findings](#findings)
* [Medium Severity](#medium-severity)
  + [Invalid Beneficiary](#invalid-beneficiary)
* [Low Severity](#low-severity)
  + [Version not incremented](#version-not-incremented)
* [Notes & Additional Information](#notes-additional-information)
  + [Comments should be linted](#comments-should-be-linted)
  + [Inadequate NatSpec](#inadequate-natspec)
  + [Recalculated constant](#recalculated-constant)
  + [Typographical errors](#typographical-errors)
  + [Improper use of solhint-disable](#improper-use-of-solhint-disable)
* [Conclusions](#conclusions)

## Summary

Type
:   DeFi

Timeline
:   From 2022-01-17
:   To 2022-01-24

Languages
:   Solidity

Total Issues
:   7 (7 resolved)

## Scope

We reviewed all changes to production Solidity files in the following pull requests:

* [PR 9041](https://github.com/celo-org/celo-monorepo/pull/9041) up to [commit e763f08](https://github.com/celo-org/celo-monorepo/pull/9041/commits/e763f08f100524f905b1389f0288894fef69737c)
* [PR 8993](https://github.com/celo-org/celo-monorepo/pull/8993) up to [commit 0fea046](https://github.com/celo-org/celo-monorepo/pull/8993/commits/0fea04630b9c7d4920b0fbe0ffe53e3438a0e9db)
* [PR 8334](https://github.com/celo-org/celo-monorepo/pull/8334) up to [commit cae8504](https://github.com/celo-org/celo-monorepo/pull/8334/commits/cae8504b7e4bb8c8444d0bdff06fbd0c69845936)

### Overview of changes

These pull requests:

* Define a new collection of contracts to represent the Brazilian REAL as a stable token
* Introduce a mechanism for validators to delegate a fraction of their payments to a beneficiary address
* Allow the `Exchange` contracts to be deployed without the corresponding stable token address, which can be provided by the contract owner once it is known

### Findings

Here we present our findings.

## Medium Severity

### Invalid Beneficiary

The [`setPaymentDelegation` function](https://github.com/celo-org/celo-monorepo/blob/0fea04630b9c7d4920b0fbe0ffe53e3438a0e9db/packages/protocol/contracts/common/Accounts.sol#L327) of the `Accounts` contract allows a validator to set the zero address as their beneficiary with a non-zero payment fraction. In this scenario, the reward distribution mechanism will [attempt to mint](https://github.com/celo-org/celo-monorepo/blob/0fea04630b9c7d4920b0fbe0ffe53e3438a0e9db/packages/protocol/contracts/governance/Validators.sol#L528) tokens to the zero address, which [will revert](https://github.com/celo-org/celo-monorepo/blob/0fea04630b9c7d4920b0fbe0ffe53e3438a0e9db/packages/protocol/contracts/stability/StableToken.sol#L248). Consequently, neither the validator nor their group will receive the epoch payment.

Consider preventing validators from setting a zero beneficiary with a non-zero payment fraction. Additionally, in the interest of clearly signaling user intentions, consider introducing a `deletePaymentDelegation` function so the `setPaymentDelegation` function can disallow any zero beneficiary.

***Update:** Fixed in [pull request #9283](https://github.com/celo-org/celo-monorepo/pull/9283).*

## Low Severity

### Version not incremented

[PR #8993](https://github.com/celo-org/celo-monorepo/pull/8993) adds new rewards delegation functionality to the `Accounts` and `Validators` contracts, but does not increment the version functions. Consider incrementing the MINOR version of both contracts in line with [the contract versioning system](https://docs.celo.org/community/release-process/smart-contracts#versioning).

***Update:** Fixed in [pull request #9256](https://github.com/celo-org/celo-monorepo/pull/9256). The PR also increments the MAJOR version of the `ExchangeBRL` contract.*

## Notes & Additional Information

### Comments should be linted

In [PR #9041](https://github.com/celo-org/celo-monorepo/pull/9041), both the [`ExchangeBRL`](https://github.com/celo-org/celo-monorepo/pull/9041/files#diff-6459b0f5b9cbcb06cc36f6574d074c5b933c94d14b2ee0755456445c285cb630R1-R20) and [`StableTokenBRL`](https://github.com/celo-org/celo-monorepo/pull/9041/files#diff-aebae7900647149d03417ce8978c58ed49fcc551534e8532eba6b41c897eb71cR1-R20) contracts have inconsistent indentation.

Consider linting the comments in order to increase readability of the codebase.

***Update:** Fixed in [pull request #9285](https://github.com/celo-org/celo-monorepo/pull/9285).*

### Inadequate NatSpec

We identified the following instances of incorrect or incomplete [NatSpec comments](https://docs.soliditylang.org/en/develop/natspec-format.html):

* in the `getPaymentDelegation` function of the `Accounts` contract:
  + [the `@param account`](https://github.com/celo-org/celo-monorepo/pull/8993/files#diff-e361a6167db81d829a10f419e96159995c5ea2cbfd0b1edfd1f1af96cf26f5e6R335-R338) statement is missing
  + [the `@return`](https://github.com/celo-org/celo-monorepo/pull/8993/files#diff-e361a6167db81d829a10f419e96159995c5ea2cbfd0b1edfd1f1af96cf26f5e6R337) statement describes both values returned as a single value instead of two separate values
  + [the `@return`](https://github.com/celo-org/celo-monorepo/pull/8993/files#diff-e361a6167db81d829a10f419e96159995c5ea2cbfd0b1edfd1f1af96cf26f5e6R337) statement should note that the `fraction` parameter is a `FixidityLib` value, or has 24 decimals of precision
* in the `initialize` function of the `Exchange` contract:
  + [the `@param stableTokenIdentifier`](https://github.com/celo-org/celo-monorepo/pull/8334/files#diff-7ed4b70452014859fd0baa0e2346f7bd804d43f6dc055a71e5bcda62846814d6R88) statement is in the wrong order.
* throughout the codebase, the `getVersionNumber` functions share a common issue:
  + the `@return` statement describes all four values returned as a single value instead of four separate values
  + during this review we identified this issue in the [`ExchangeBRL`](https://github.com/celo-org/celo-monorepo/pull/9041/files#diff-6459b0f5b9cbcb06cc36f6574d074c5b933c94d14b2ee0755456445c285cb630R15), [`StableTokenBRL`](https://github.com/celo-org/celo-monorepo/pull/9041/files#diff-aebae7900647149d03417ce8978c58ed49fcc551534e8532eba6b41c897eb71cR15), [`Validators`](https://github.com/celo-org/celo-monorepo/pull/8993/files#R163), [`Exchange`](https://github.com/celo-org/celo-monorepo/pull/8334/files#diff-7ed4b70452014859fd0baa0e2346f7bd804d43f6dc055a71e5bcda62846814d6R66), and [`ExchangeEUR`](https://github.com/celo-org/celo-monorepo/pull/8334/files#diff-19ef7492dd749499e7a5964d6383654446cb156c6b582f4a8a8eaac8f7f8b1daR15) contracts
  + this issue is replicated across the codebase and is found in code outside the scope of this review

In order to keep the codebase well documented, consider updating the NatSpec comments.

***Update:** Partially fixed in [pull request #9270](https://github.com/celo-org/celo-monorepo/pull/9270). The remaining fixes are being tracked in [issue #9242](https://github.com/celo-org/celo-monorepo/issues/9242) and [issue #9268](https://github.com/celo-org/celo-monorepo/issues/9268).*

*The Celo team states:*

> The issue with `@return` statements exists throughout the contracts code base, including many contracts that were outside the scope of this audit. For consistency, and to get them all in one go, we’ll keep singular `@return`s for now, but have created [#9268](https://github.com/celo-org/celo-monorepo/issues/9268) to fix this throughout our smart contracts in the immediate future.

### Recalculated constant

The `grandamento` test file [imports the `SECONDS_IN_A_WEEK` variable](https://github.com/celo-org/celo-monorepo/pull/8475/files#diff-85ae308199426855086067003294dd7f1cf35d2572d8251e09a60ab097535d7bR31), but recalculates its value [multiple](https://github.com/celo-org/celo-monorepo/pull/8475/files#diff-85ae308199426855086067003294dd7f1cf35d2572d8251e09a60ab097535d7bR1170) [times](https://github.com/celo-org/celo-monorepo/pull/8475/files#diff-85ae308199426855086067003294dd7f1cf35d2572d8251e09a60ab097535d7bR1187). For improved code clarity, consider using the constant.

***Update:** Fixed in [pull request #9269](https://github.com/celo-org/celo-monorepo/pull/9269).*

### Typographical errors

The codebase contains the following typographical errors:

* [`FixidyLib`](https://github.com/celo-org/celo-monorepo/pull/8993/files#diff-e361a6167db81d829a10f419e96159995c5ea2cbfd0b1edfd1f1af96cf26f5e6R324) should be `FixidityLib`
* [`vaidator`](https://github.com/celo-org/celo-monorepo/pull/8993/files#diff-e361a6167db81d829a10f419e96159995c5ea2cbfd0b1edfd1f1af96cf26f5e6R321) should be `validator`

Consider correcting these errors to improve code readability.

***Update:** Fixed in [pull request #9250](https://github.com/celo-org/celo-monorepo/pull/9250).*

### Improper use of solhint-disable

`solhint-disable` will disable a feature of solhint until it is re-enabled with `solhint-enable` or until the end of the file. Using `solhint-disable` with an unmatched `solhint-enable` creates code that is prone to errors when updating it in the future.

In [PR #9041](https://github.com/celo-org/celo-monorepo/pull/9041), both the [`ExchangeBRLProxy`](https://github.com/celo-org/celo-monorepo/pull/9041/files#diff-9a9969a9a31282fe8e0baab7b665ad8dedff9968ea949b8ba94703bb1ef4b371R5) and [`StableTokenBRLProxy`](https://github.com/celo-org/celo-monorepo/pull/9041/files#diff-1eb158ee2e8f0bfddb056ef8f222d1e13d43ad90b8190af056ba79adafab3479R5) contracts use `solhint-disable` without a following `solhint-enable`. Consider matching each instance of `solhint-disable` with `solhint-enable` or instead use `solhint-disable-next-line` to ensure clean, developer friendly code.

***Update:** Issue is scheduled for a future fix, it is tracked by [issue #9245](https://github.com/celo-org/celo-monorepo/issues/9245).*

*The Celo team states:*

> Agreed that `solhint-disable-next-line` would be better. That said, the current risk of these unmatched `solhint-disabled`s causing problems is minimal – these contracts exist solely to create new named proxies, and are meant to have exactly the code of the original Proxy contract, so they inherit from it and add nothing new, and we don’t expect ever modifying them to add anything new.

## Conclusions

No critical or high severity issues were found. Some changes were proposed to follow best practices and reduce potential attack surface.