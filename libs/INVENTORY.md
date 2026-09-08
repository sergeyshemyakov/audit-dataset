# Observed reusable-contract candidates

Scanned on 2026-09-08. See [inventory.json](inventory.json) for the regex, complete counts, project names, source examples with line numbers, and corpus fingerprints.

Counts are flattened files containing a declaration with the exact symbol name, once per file. They include forks and names shared by several vendors; they are **not audited coverage** or counts of unique implementations. Only current L2BEAT `.flat` directories were scanned. Historical `.flat@...` snapshots, imported-only symbols, free functions, and renamed code are not counted.

| Corpus | Solidity files | Project directories |
| --- | ---: | ---: |
| audit-dataset | 455 | 11 |
| l2beat | 8777 | 259 |

| Symbol | Dataset files | Dataset projects | L2BEAT files | L2BEAT projects |
| --- | ---: | ---: | ---: | ---: |
| `Address` | 123 | 10 | 2824 | 225 |
| `Proxy` | 104 | 8 | 1933 | 227 |
| `Initializable` | 106 | 8 | 1758 | 197 |
| `StorageSlot` | 52 | 7 | 1484 | 154 |
| `Ownable` | 55 | 9 | 1143 | 224 |
| `Context` | 80 | 10 | 1059 | 220 |
| `ERC1967Proxy` | 39 | 4 | 1013 | 134 |
| `SafeERC20` | 53 | 9 | 993 | 189 |
| `ERC1967Upgrade` | 37 | 3 | 986 | 115 |
| `IERC165` | 68 | 8 | 824 | 108 |
| `Math` | 66 | 7 | 746 | 145 |
| `TransparentUpgradeableProxy` | 44 | 3 | 733 | 102 |
| `ModuleManager` | 38 | 8 | 703 | 206 |
| `OwnerManager` | 38 | 8 | 703 | 206 |
| `GuardManager` | 36 | 7 | 686 | 203 |
| `EnumerableSet` | 17 | 7 | 596 | 56 |
| `OwnableUpgradeable` | 35 | 4 | 534 | 137 |
| `GnosisSafe` | 25 | 7 | 512 | 176 |
| `GnosisSafeProxy` | 21 | 6 | 479 | 166 |
| `SafeMath` | 42 | 8 | 476 | 113 |
| `SafeCast` | 25 | 5 | 465 | 69 |
| `ReentrancyGuard` | 22 | 3 | 460 | 109 |
| `IERC20` | 64 | 9 | 368 | 64 |
| `Ownable2Step` | 12 | 3 | 362 | 32 |
| `ERC1967Utils` | 5 | 3 | 360 | 52 |
| `AccessControl` | 16 | 3 | 341 | 52 |
| `ProxyAdmin` | 13 | 4 | 316 | 163 |
| `UUPSUpgradeable` | 3 | 2 | 293 | 75 |
| `ERC165` | 17 | 4 | 269 | 75 |
| `PausableUpgradeable` | 4 | 1 | 265 | 78 |
| `FixedPointMathLib` | 27 | 3 | 261 | 73 |
| `ECDSA` | 23 | 7 | 249 | 98 |
| `MerkleProofLib` | 0 | 0 | 191 | 46 |
| `Safe` | 13 | 5 | 191 | 69 |
| `AccessControlUpgradeable` | 3 | 2 | 189 | 78 |
| `RLPReader` | 9 | 4 | 184 | 77 |
| `SafeProxy` | 11 | 5 | 178 | 68 |
| `Guard` | 30 | 6 | 172 | 67 |
| `IERC20Metadata` | 6 | 5 | 152 | 39 |
| `SafeTransferLib` | 6 | 2 | 152 | 8 |
| `ReentrancyGuardUpgradeable` | 23 | 2 | 141 | 31 |
| `Pausable` | 15 | 4 | 104 | 37 |
| `ERC20Upgradeable` | 4 | 2 | 97 | 24 |
| `GnosisSafeL2` | 1 | 1 | 84 | 42 |
| `TransferHelper` | 6 | 1 | 82 | 6 |
| `EIP712` | 16 | 7 | 77 | 41 |
| `ERC20` | 14 | 6 | 73 | 37 |
| `EnumerableMap` | 1 | 1 | 62 | 9 |
| `Checkpoints` | 8 | 2 | 61 | 8 |
| `Roles` | 0 | 0 | 54 | 7 |
| `TimelockController` | 9 | 2 | 47 | 18 |
| `BytesLib` | 3 | 1 | 44 | 13 |
| `TypedMemView` | 0 | 0 | 42 | 6 |
| `LibString` | 6 | 3 | 41 | 26 |
| `LibClone` | 3 | 3 | 39 | 38 |
| `AccessControlEnumerable` | 6 | 2 | 34 | 5 |
| `IERC721` | 9 | 5 | 32 | 20 |
| `SafeL2` | 1 | 1 | 32 | 18 |
| `MerkleProof` | 1 | 1 | 30 | 15 |
| `SignatureChecker` | 2 | 2 | 29 | 14 |
| `Clones` | 4 | 2 | 28 | 10 |
| `IERC1271` | 3 | 2 | 20 | 9 |
| `ERC20Permit` | 9 | 4 | 19 | 11 |
| `UpgradeableBeacon` | 0 | 0 | 17 | 13 |
| `Governor` | 0 | 0 | 14 | 5 |
| `LibDiamond` | 0 | 0 | 13 | 1 |
| `BeaconProxy` | 0 | 0 | 12 | 7 |
| `ERC721` | 1 | 1 | 11 | 7 |
| `TickMath` | 10 | 2 | 11 | 3 |
| `AdminUpgradeabilityProxy` | 1 | 1 | 10 | 4 |
| `IERC1155` | 2 | 2 | 10 | 7 |
| `Timelock` | 1 | 1 | 10 | 7 |
| `FullMath` | 8 | 2 | 9 | 3 |
| `Module` | 1 | 1 | 8 | 6 |
| `Owned` | 3 | 1 | 8 | 4 |
| `MultiSigWallet` | 0 | 0 | 7 | 5 |
| `ERC721Upgradeable` | 0 | 0 | 6 | 4 |
| `Multicall` | 3 | 1 | 6 | 3 |
| `WETH9` | 1 | 1 | 6 | 4 |
| `IPermit2` | 1 | 1 | 5 | 3 |
| `BitMath` | 4 | 1 | 4 | 1 |
| `IAllowanceTransfer` | 2 | 1 | 4 | 2 |
| `ISignatureTransfer` | 2 | 1 | 4 | 2 |
| `ReentrancyGuardTransient` | 0 | 0 | 4 | 3 |
| `AccessManager` | 2 | 1 | 3 | 2 |
| `AllowanceTransfer` | 1 | 1 | 3 | 2 |
| `ERC20Votes` | 0 | 0 | 3 | 2 |
| `LiquidityMath` | 3 | 1 | 3 | 1 |
| `Permit2` | 1 | 1 | 3 | 2 |
| `SignatureTransfer` | 1 | 1 | 3 | 2 |
| `SqrtPriceMath` | 3 | 1 | 3 | 1 |
| `UnsafeMath` | 3 | 1 | 3 | 1 |
| `AllowanceModule` | 0 | 0 | 2 | 2 |
| `WETH` | 0 | 0 | 2 | 1 |
| `Auth` | 0 | 0 | 1 | 1 |
| `BaseAccount` | 0 | 0 | 1 | 1 |
| `BasePaymaster` | 0 | 0 | 1 | 1 |
| `Comp` | 0 | 0 | 1 | 1 |
| `DSToken` | 0 | 0 | 1 | 1 |
| `Delay` | 0 | 0 | 1 | 1 |
| `ERC1155` | 1 | 1 | 1 | 1 |
| `ERC1967Factory` | 0 | 0 | 1 | 1 |
| `ERC4626` | 0 | 0 | 1 | 1 |
| `EntryPoint` | 0 | 0 | 1 | 1 |
| `GovernorBravoDelegate` | 1 | 1 | 1 | 1 |
| `GovernorBravoDelegator` | 1 | 1 | 1 | 1 |
| `IAccount` | 0 | 0 | 1 | 1 |
| `IEntryPoint` | 0 | 0 | 1 | 1 |
| `IPaymaster` | 0 | 0 | 1 | 1 |
| `Modifier` | 0 | 0 | 1 | 1 |
| `MultiSendCallOnly` | 0 | 0 | 1 | 1 |
| `MultiSigWalletWithDailyLimit` | 0 | 0 | 1 | 1 |
| `RolesAuthority` | 0 | 0 | 1 | 1 |
| `Votes` | 0 | 0 | 1 | 1 |

Zero-hit candidates are retained in the JSON to distinguish an unobserved name from an unsearched one. In particular, PRBMath and ERC721A were included for broader reuse beyond these two corpora.
