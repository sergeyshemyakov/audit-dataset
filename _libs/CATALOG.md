# Reusable-contract shortlist

The elements below are candidates for matching, **not an assertion that every listed file/version is covered**. [INVENTORY.md](INVENTORY.md) and [inventory.json](inventory.json) contain the local evidence. [REPORTS.md](REPORTS.md) links every collected report; its publisher links and the manifest are the acquisition source of truth.

## OpenZeppelin

Upstream: [openzeppelin-contracts](https://github.com/OpenZeppelin/openzeppelin-contracts) and [openzeppelin-contracts-upgradeable](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable). Local reports: [openzeppelin/reports](openzeppelin/reports).

| Family | Candidate elements |
| --- | --- |
| Proxies and initialization | `Proxy`, `TransparentUpgradeableProxy`, `ERC1967Proxy`, `ERC1967Upgrade`/`ERC1967Utils`, `ProxyAdmin`, `UUPSUpgradeable`, `BeaconProxy`, `UpgradeableBeacon`, `Clones`, `Initializable`; legacy `AdminUpgradeabilityProxy` requires its own old SDK evidence |
| Authorization and emergency controls | `Ownable`, `Ownable2Step`, `AccessControl`, `AccessControlEnumerable`, `AccessManager`, `Pausable`, `ReentrancyGuard`, `ReentrancyGuardTransient` |
| Tokens and vaults | `ERC20`, `ERC20Permit`, `ERC20Votes`, burnable/capped/pausable extensions, `SafeERC20`, `ERC721`, enumerable/URI-storage extensions, `ERC1155`, `ERC4626`, token receiver helpers |
| Governance and vesting | `Governor` and extensions, `Votes`, `Checkpoints`, `TimelockController`, `VestingWallet` |
| Crypto, math and utilities | `ECDSA`, `EIP712`, `SignatureChecker`, `MerkleProof`, `Math`, `SafeMath`, `SafeCast`, `Address`, `StorageSlot`, `Context`, `EnumerableSet`, `EnumerableMap`, `Multicall`, `ERC165`, RLP |
| Interfaces and variants | `IERC20`, `IERC20Metadata`, `IERC721`, `IERC1155`, `IERC165`, `IERC1271`; applicable `*Upgradeable` implementations must be matched separately |

Collected: New Alchemy March 2017 (v1.0.4); LevelK October 2018 (v2.0.0); ERC4626 and Checkpoints October 2022 (v4.8.0); release/component audits for v4.9, v5.0, v5.1, v5.2, v5.3, v5.4, v5.5, RLP, and v5.6; three Certora formal-verification reports from 2021–2022. The [publisher index snapshot](openzeppelin/provenance/contracts-index__audits__README.md) provides version/commit/scope mappings.

Prioritize this vendor: `Ownable` appears in 55 dataset flattened files across nine projects, `Initializable` in 106 across eight, and `SafeERC20` in 53 across nine. These symbols can also denote other vendors or forks. Modern reports are largely diffs; do not extrapolate the 2018 full-scope audit to current versions.

## Gnosis / Safe / Zodiac

Upstreams: [Safe core](https://github.com/safe-global/safe-smart-account), [Safe modules](https://github.com/safe-global/safe-modules), [legacy MultiSigWallet](https://github.com/gnosis/MultiSigWallet), and [Zodiac](https://github.com/gnosis/zodiac). Local reports: [safe/reports](safe/reports).

Candidates: `GnosisSafe`, `GnosisSafeL2`, `Safe`, `SafeL2`, proxy/factory contracts, `OwnerManager`, `ModuleManager`, `GuardManager`, fallback managers/handlers, `MultiSend`, `MultiSendCallOnly`, signature decoding and storage-access utilities. Separate candidates are legacy `MultiSigWallet`/daily-limit variants; Safe allowance, ERC-4337, passkey and recovery modules; and Zodiac `Module`, `Modifier`, `Guard`, `Roles` and `Delay` infrastructure.

Collected Safe core evidence spans the early Alexey review, v1.0-era audit/verification, v1.1.0, v1.1.1, v1.2.0, initial/final v1.3.0 reviews, later Certora/Nethermind v1.3.0 reviews, v1.4.0, v1.4.1 library contracts, and v1.5.0 Ackee/Certora reports. Also collected are the versioned Safe-module reports, three Zodiac infrastructure reports, four dedicated [Roles v2/v2.1](https://github.com/gnosis/zodiac-modifier-roles/tree/main/packages/evm/docs) reports, and the [Delay module's September 2021 report](https://github.com/gnosis/zodiac-modifier-delay/tree/main/audits). The original OpenZeppelin legacy multisig audit is HTML. See the [report index](REPORTS.md) for module versions and individual reports.

`GnosisSafe` appears in seven dataset projects and 176 L2BEAT project directories; `Safe` appears in five and 69 respectively. These counts overlap. Core Safe audits do not cover arbitrary enabled modules, guards or handlers. The publisher's [v1.4.0 notes](safe/provenance/safe-index__docs__audit_1_4_0.md) explicitly describe a post-audit fix; retain that distinction when comparing revisions. “Certora” does not always mean formal verification: the 2026 v1.3.0 report is a manual security assessment.

## Solady

Upstream: [Vectorized/solady](https://github.com/Vectorized/solady). Local reports: [solady/reports](solady/reports).

Candidates: `FixedPointMathLib`, `SafeTransferLib`, `LibClone`, `ERC1967Factory`, `LibString`, `LibBitmap`, `SSTORE2`, `ECDSA`, `EIP712`, `SignatureCheckerLib`, `MerkleProofLib`, `Ownable`, roles helpers, `ReentrancyGuard`, `Initializable`, token/vault implementations and account utilities.

Collected all five published PDFs: Ackee's May 2023 tokens/utils selection, Shung's July 2023 ERC721 review, Cantina's September 2023 review, Xuwinnie's July 2024 cube-root proof, and the January 2025 Coinbase/Spearbit review. The cube-root proof is limited to `cbrt`/`cbrtWad`, not the entire math library. Shung's review identifies v0.0.107 and `ERC721.sol`. Cantina's 2023 main scope lists eight contracts including `LibClone` and `ERC1967Factory`. Read each report for all scoped revisions and fixes.

`LibClone` appears in three dataset projects and 38 L2BEAT project directories, including dispute-game factories. `FixedPointMathLib` occurs across 73 L2BEAT projects, but the count mixes implementations and must be attributed before matching.

## Solmate

Upstream: [transmissions11/solmate](https://github.com/transmissions11/solmate), formerly Rari-Capital/solmate. Local reports: [solmate/reports](solmate/reports).

Candidates: `Owned`, `Auth`, `RolesAuthority`, `MultiRolesAuthority`, `ERC20`/permit, `ERC721`, `ERC1155`, `ERC4626`, `WETH`, `ReentrancyGuard`, `SafeTransferLib`, `FixedPointMathLib`, `SignedWadMath`, `SSTORE2`, `CREATE3`, `LibString`, `MerkleProofLib`.

Collected the canonical v6 Fixed Point Solutions audit. Its scope names a baseline revision and additional revisions for particular files; it is not evidence for all later additions. The source of [Permit2 in this dataset](../uniswapv3/deployed-contracts/Permit2.sol) explicitly credits Solmate's transfer library. Solmate and Solady names overlap; their audits and implementations are not interchangeable.

## Uniswap

Upstreams: [Permit2](https://github.com/Uniswap/permit2), [v2](https://github.com/Uniswap/v2-core), [v3 core](https://github.com/Uniswap/v3-core), [v3 periphery](https://github.com/Uniswap/v3-periphery), [v4 core](https://github.com/Uniswap/v4-core), [Universal Router](https://github.com/Uniswap/universal-router). Local reports: [uniswap/reports](uniswap/reports).

Candidates: `Permit2`, `AllowanceTransfer`, `SignatureTransfer`, their interfaces and signature/nonce helpers; `FullMath`, `TickMath`, `SqrtPriceMath`, `LiquidityMath`, `BitMath`, `UnsafeMath`, `TransferHelper`, periphery math/path/oracle utilities, and v4 currency/hook/position utilities. Core pool/factory and router implementations are common fork targets, but project-specific forks require their own comparison.

Collected Permit2's ABDK and ChainSecurity reports; the original dapp.org Uniswap v2 audit/formal-verification report in HTML; both v3-core reports and the v3-periphery report; all five v4-core audit PDFs; all five Universal Router audit PDFs. Some are explicitly drafts. V3 core/periphery coverage overlaps the existing `uniswapv3` dataset. Reusing `FullMath` does not make the surrounding AMM audited, and importing a Permit2 interface does not audit its caller.

## Compound

Upstream: [compound-finance/compound-protocol](https://github.com/compound-finance/compound-protocol). Local reports: [compound/reports](compound/reports).

Candidates: `GovernorAlpha`, `GovernorBravoDelegate`, `GovernorBravoDelegator`, governance storage/interfaces, COMP-style voting/delegation code, and `Timelock` integration. This dataset's Uniswap governance is a concrete matching target.

Collected Trail of Bits' February 2020 governance PDF and OpenZeppelin's Alpha (February 2020) and Bravo (February 2021) HTML audits. Trail of Bits explicitly scopes `Comp.sol` and `GovernorAlpha.sol`, including their interactions with `Timelock.sol`; that is not a standalone audit of every Timelock implementation. The Bravo audit excludes unlisted files. Token substitutions and voting-parameter changes in forks require review.

## ERC-4337 / eth-infinitism

Upstream: [eth-infinitism/account-abstraction](https://github.com/eth-infinitism/account-abstraction). Local reports: [eth-infinitism/reports](eth-infinitism/reports).

Candidates: `EntryPoint`, `StakeManager`, `NonceManager`, `SenderCreator`, `BaseAccount`, `BasePaymaster`, `SimpleAccount`, `SimpleAccountFactory`, `UserOperation`/packed variants, `IAccount`, `IPaymaster`, `IEntryPoint`.

Collected OpenZeppelin's April 2022 original HTML audit, its February 2023 and February 2024 incremental PDFs, Spearbit's March 2025 review, and Cantina's v0.9 review. L2BEAT's Kinto sources include an `EntryPoint` declaration. Base classes, sample accounts, and sample paymasters may have different inclusion/exclusion rules; the 2022 audit, for example, excludes `SimpleWalletForTokens.sol`. Safe4337Module reports are stored under Gnosis separately.

## PRBMath

Upstream: [PaulRBerg/prb-math](https://github.com/PaulRBerg/prb-math). Local evidence: [prb-math/reports](prb-math/reports).

Candidates: old `PRBMath`, `PRBMathSD59x18`, `PRBMathUD60x18`, newer `SD59x18`/`UD60x18` types and free functions, signed/unsigned `mulDiv`, logarithms, powers and roots. Modern free functions/types are outside the declaration-name inventory's detection method.

Collected both reviews linked by the [publisher's security index](prb-math/provenance/security-index__SECURITY.md): the June 2023 Cantina Sablier audit, which explicitly included PRBMath v3.3.2, and Certora's July 2023 fixed-point bug disclosure. The latter is security research, not a full audit report. The index warns of later code modifications; it identifies a rounding-documentation fix in v4.0.1, whereas the Certora article says “4.1”. Resolve that discrepancy from the actual source history during extraction rather than treating either prose label as an exact revision.

## Chiru Labs / ERC721A

Upstream: [chiru-labs/ERC721A](https://github.com/chiru-labs/ERC721A). Local reports: [chiru-labs/reports](chiru-labs/reports).

Candidates: `ERC721A`, `IERC721A`, `ERC721AQueryable` and related extensions; upgradeable variants require separate matching. Included as a broader ecosystem candidate; no exact `ERC721A` declaration was found in the scanned corpora.

Collected HashEx's dedicated March 2022 ERC721A audit and Paladin's May 2022 LaunchPeg report, which explicitly includes ERC721A as a dependency. The latter contains other application contracts that are outside this standard-library shortlist. Neither audit should be applied to every later ERC721A extension or fork.

## Candidates without assigned library-audit evidence

| Candidate | Why track it | Boundary / next scope check |
| --- | --- | --- |
| Legacy WETH9 | Deployed wrapped Ether and copied wrappers; observed in four L2BEAT project directories | Different from Solmate/Solady `WETH`; do not transfer their audit status |
| Dappsys / Maker utilities | `DSAuth`, `DSMath`, `DSProxy`, `DSToken` and legacy authorization/math patterns | A same-named token can be unrelated; establish upstream code and explicitly scoped audit evidence |
| ABDK math | `ABDKMath64x64`, `ABDKMathQuad` are reusable numerical libraries | ABDK auditing a client does not establish an audit of ABDK's own library; no dedicated report was established here |
| Multicall3 | Reusable batching contract, separate from OZ/Uniswap `Multicall` | The [upstream repository](https://github.com/mds1/multicall) has no audit archive in the checked tree; [Filecoin's integration docs](https://docs.filecoin.io/smart-contracts/advanced/multicall) call it unaudited |
| RLP, bytes and memory views | `RLPReader` appears in 77 L2BEAT projects, `BytesLib` in 13, `TypedMemView` in six | Identify exact origin/fork. OZ's RLP report is not evidence for an unrelated RLPReader; project audits may supply scope |
| Diamond libraries | `LibDiamond` and diamond-cut/loupe code | ERC-2535 is a standard, not one implementation; audited fork and revision must be established |
| External interfaces | Chainlink feeds/VRF, ERC interfaces, protocol adapters | Interface compatibility does not audit deployed implementations or integration behavior |

This is a shortlist for source comparison and further audit attribution, not a recommendation to deploy historical code.
