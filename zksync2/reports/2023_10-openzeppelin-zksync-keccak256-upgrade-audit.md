# zkSync Keccak256 Upgrade Audit

Source: [https://www.openzeppelin.com/news/zksync-keccak256-upgrade-audit](https://www.openzeppelin.com/news/zksync-keccak256-upgrade-audit)

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scope](#scope)
- [System Overview](#system-overview)
- [Trust Assumptions](#trust-assumptions)
- [Low Severity](#low-severity)
  - [Precompile Keccak256 Contract Is Missing Constructor Code](#precompile-keccak256-contract-is-missing-constructor-code)
  - [Missing Tests](#missing-tests)
- [Notes & Additional Information](#notes-additional-information)
  - [Missing Comments](#missing-comments)
  - [Magic Numbers Documentation](#magic-numbers-documentation)
  - [Function Order of Contract Addresses](#function-order-of-contract-addresses)
  - [Gas Is Not Charged for Hashing Empty Data](#gas-is-not-charged-for-hashing-empty-data)
- [Conclusion](#conclusion)

## Summary

Type
:   Layer 2

Timeline
:   From 2023-10-23
:   To 2023-10-27

Languages
:   Solidity, Yul

Total Issues
:   6 (6 resolved)

Critical Severity Issues
:   0 (0 resolved)

High Severity Issues
:   0 (0 resolved)

Medium Severity Issues
:   0 (0 resolved)

Low Severity Issues
:   2 (2 resolved)

Notes & Additional Information
:   4 (4 resolved)

## Scope

We audited [pull request #41](https://github.com/matter-labs/era-system-contracts/pull/41) of the `matter-labs/era-system-contracts` repository at commit [217e115](https://github.com/matter-labs/era-system-contracts/tree/217e115a91348c6a4dafde19a9777613e782e747).

In scope were the following contracts:

```
 ├── bootloader
│   └── bootloader.yul
└── contracts
    ├── ContractDeployer.sol
    └── precompiles
        └── Keccak256.yul
```

## System Overview

The system upgrade introduces a new, more efficient way for the `keccak256` function to work. In the previous system version, the `keccak256` precompile process involved copying data into memory and padding it for processing, leading to additional processing steps and user charges for memory growth.

In the revised version, the `keccak256` precompile process remains similar, but with the key change of removing the data copying and padding. The padding will now be handled within the ZK circuits. The new algorithm involves receiving data to hash and packing the parameters into the correct precompile ABI format.

The update also includes the implementation of the `keccak256` upgrade process. When transitioning to a VM version that supports the new `keccak256` precompile, the old `keccak256` precompile will cease to function. Therefore, the initial `keccak256` upgrade cannot involve any `keccak256` invocations.

## Trust Assumptions

- The successful execution of `keccak256` relies on the out-of-scope `keccak256` ZK circuit. Thus, it is assumed that the circuit is implemented correctly and behaves according to its specification.
- This upgrade does not introduce new roles to the system.

## Low Severity

### Precompile `Keccak256` Contract Is Missing Constructor Code

The [`Keccak256`](https://github.com/matter-labs/era-system-contracts/blob/217e115a91348c6a4dafde19a9777613e782e747/contracts/precompiles/Keccak256.yul) contract defined in the [`Keccak256.yul`](https://github.com/matter-labs/era-system-contracts/blob/217e115a91348c6a4dafde19a9777613e782e747/contracts/precompiles/Keccak256.yul) file is missing the constructor definition, whereas all other precompile contracts have it.

Consider adding constructor code to the `Keccak256` contract to improve its readability and clarity.

***Update:** Resolved in [pull request #57](https://github.com/matter-labs/era-system-contracts/pull/57) at commit [bd52d32](https://github.com/matter-labs/era-system-contracts/pull/57/commits/bd52d324843646678ea349365613dcc219826555).*

### Missing Tests

The upgrade to the new version of `keccak256` lacks several tests that could significantly enhance the quality of the codebase. Consider adding the following tests to ensure the correctness of the upgrade process:

- A test for the upgrade process using the new version of `keccak256`. The current upgrade process does not test transitioning from one `keccak256` version to another. Instead, it [acquires the current `keccak256` version](https://github.com/matter-labs/era-system-contracts/blob/217e115a91348c6a4dafde19a9777613e782e747/test/Keccak256.spec.ts#L23), changes it to a reverting contract, and then changes it back to the current version.
- A `keccak256` unit test to verify the correctness of generated hashes. Consider implementing fuzz testing for this purpose.

***Update:** Resolved in [pull request #58](https://github.com/matter-labs/era-system-contracts/pull/58) at commit [a4dc0d9](https://github.com/matter-labs/era-system-contracts/pull/58/commits/a4dc0d95225764056e0cbb2f3edaf636c98fbad2).*

## Notes & Additional Information

### Missing Comments

The comment on lines [233 and 234](https://github.com/matter-labs/era-system-contracts/blob/217e115a91348c6a4dafde19a9777613e782e747/contracts/ContractDeployer.sol#L233-L234) suggests that the `forceDeployKeccak256` function is temporarily needed to upgrade the `Keccak256` precompiled contract, and is to be removed in the future.

In the future, if `forceDeployKeccak256` is removed, its interdependent counterpart `upgradeKeccakIfNeeded` function should also be removed. However, the [documentation](https://github.com/matter-labs/era-system-contracts/blob/217e115a91348c6a4dafde19a9777613e782e747/bootloader/bootloader.yul#L641-L643) for the `upgradeKeccakIfNeeded` function does not mention that this is temporarily needed and should be removed when the upgrade process is no longer needed.

Consider adding a comment to the `upgradeKeccakIfNeeded` function, pointing out that it should be removed once the upgrade process is complete. Furthermore, ensure that the documentation for both mentioned functions includes a note specifying that their interdependent counterpart function should also be removed.

***Update:** Resolved in [pull request #60](https://github.com/matter-labs/era-system-contracts/pull/60) at commit [40d31d5](https://github.com/matter-labs/era-system-contracts/pull/60/commits/40d31d52481577526a75ddcda54149c0f1cb13a9).*

### Magic Numbers Documentation

The [`Keccak256.yul`](https://github.com/matter-labs/era-system-contracts/blob/217e115a91348c6a4dafde19a9777613e782e747/contracts/precompiles/Keccak256.yul) contract defines two magic hardcoded numbers, but there is a lack of proper documentation regarding how they were derived.

The [`BLOCK_SIZE` function returns a value of 136](https://github.com/matter-labs/era-system-contracts/blob/217e115a91348c6a4dafde19a9777613e782e747/contracts/precompiles/Keccak256.yul#L15-L17), which is expected to be the size of the processing `keccak256` block in bytes. `Keccak256` is defined with rate (equivalent to "block size") `$r = 1088$ bits $= 136$` bytes and capacity `$c = 512$ bits $= 64$ bytes`. The sum of the two gives the full size of the state of the Keccak permutation `$r + c = 1600$ bits $= 200$ bytes`. Clearly, the hard-coded constant `$136$` corresponds to the size of the rate in bytes, but a detailed explanation of how it was derived is missing.

The [`KECCAK_ROUND_GAS_COST` function returns a value of 40](https://github.com/matter-labs/era-system-contracts/blob/217e115a91348c6a4dafde19a9777613e782e747/contracts/precompiles/Keccak256.yul#L20-L22), which is expected to be the gas cost of processing one `keccak256` round. Yet there is no explanation of how this value is computed.

Consider including explanations in the comments as to how the values `$136$` and `$40$` were derived.

***Update:** Resolved in [pull request #61](https://github.com/matter-labs/era-system-contracts/pull/61) at commit [a90e2c0](https://github.com/matter-labs/era-system-contracts/pull/61/commits/a90e2c0e8b4a588fab6b3904b2c23a496c86415a).*

### Function Order of Contract Addresses

The [ordering of functions that return contract addresses](https://github.com/matter-labs/era-system-contracts/blob/217e115a91348c6a4dafde19a9777613e782e747/bootloader/bootloader.yul#L443-L497) in [`bootloader.yul`](https://github.com/matter-labs/era-system-contracts/blob/217e115a91348c6a4dafde19a9777613e782e747/bootloader/bootloader.yul) is not currently done based on the address value. This lack of proper ordering may lead to errors and issues when new contract addresses need to be added.

Consider reordering these functions according to the address they return for better organization and reliability.

***Update:** Resolved in [pull request #62](https://github.com/matter-labs/era-system-contracts/pull/62) at commit [d6c93ed](https://github.com/matter-labs/era-system-contracts/commit/d6c93edd1291af6efd1099c250f2e660a84e040d).*

### Gas Is Not Charged for Hashing Empty Data

The proposed implementation of the `keccak256` precompile calculates the amount of gas to be charged for hashing. [This calculation](https://github.com/matter-labs/era-system-contracts/blob/217e115a91348c6a4dafde19a9777613e782e747/contracts/precompiles/Keccak256.yul#L89) is based on the number of `keccak256` rounds required to process the given data, multiplied by the hardcoded cost of gas for a single round. The number of rounds is determined by [performing a ceiling division on the data length with `BLOCK_SIZE` as the denominator](https://github.com/matter-labs/era-system-contracts/blob/217e115a91348c6a4dafde19a9777613e782e747/contracts/precompiles/Keccak256.yul#L88).

This approach results in an issue: if empty data is hashed, the calculation yields a `numRounds` value of 0. While this is technically accurate because no rounds of hashing are executed, there is still some processing involved in returning the `keccak256` hash for empty input data.

Consider charging gas for cases where empty data is being hashed.

***Update:** Resolved in [pull request #63](https://github.com/matter-labs/era-system-contracts/pull/63) at commit [4f1b6c6](https://github.com/matter-labs/era-system-contracts/pull/63/commits/4f1b6c6b27edfb850d14b3a9cba703d583dbec78).*

## Conclusion

The audit did not reveal any significant issues with the `keccak256` upgrade. Various recommendations have been provided to enhance the quality and documentation of the codebase. The Matter Labs team was responsive and facilitated the setup of a functional test environment for running the test code.
