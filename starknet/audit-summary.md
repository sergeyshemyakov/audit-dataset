# Audit source summary: starknet

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC). Paths are EVM contracts unless marked zk, cairo or other.

## PeckShield StarkEx v1.0 Smart Contract Audit

- Report: [2020_02-peckshield-starkex-v1.0-audit.md](<reports/2020_02-peckshield-starkex-v1.0-audit.md>)
- Auditor: PeckShield
- Date: 2020-02-26
- Description: PeckShield audit of the StarkEx v1.0 Solidity contracts, covering both the scalable-dex exchange contracts (StarkExchange, components, interactions, committee, proxy upgrade) and the evm-verifier STARK verifier (Merkle/FRI statement contracts, Dex statement verifier) at starkex-contracts d6bde00 and the private starkware-industries/starkex 7a8d0da. One Medium (integer overflow in MerkleVerifier), three Low and eight Informational findings were reported, all resolved or confirmed.

### Repository: <a href="https://github.com/starkware-libs/starkex-contracts"><code>starkware-libs/starkex-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/starkware-libs/starkex-contracts/commit/d6bde00ba6f5fa38c05e2e2222ddc6a2eaf2c562"><code>d6bde00ba6f5fa38c05e2e2222ddc6a2eaf2c562</code></a> | February 11, 2020 | <code>evm-verifier/solidity/contracts</code> (recursive directory)<br><code>scalable-dex/contracts/src</code> (recursive directory) |

### Repository: <a href="https://github.com/starkware-industries/starkex"><code>starkware-industries/starkex</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

## PeckShield StarkEx V2 Smart Contract Audit

- Report: [2020_10-peckshield-starkex-v2.0-audit.md](<reports/2020_10-peckshield-starkex-v2.0-audit.md>)
- Auditor: PeckShield
- Date: 2020-10-26
- Description: PeckShield audit of the StarkEx V2 Solidity contracts (scalable-dex exchange with ERC-721 and fast withdrawals, and the evm-verifier including the Cairo CPU verifier and gps/GpsStatementVerifier) at starkex-contracts 8d596dd, with fixes in e4c1faa and the V2.0 release commit 2799231. One Medium (depositCancel denial of service), one Low and eight Informational findings were reported.

### Repository: <a href="https://github.com/starkware-libs/starkex-contracts"><code>starkware-libs/starkex-contracts</code></a>

_Commit dates unavailable: 2 revision(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/starkware-libs/starkex-contracts/commit/27992317365bc58c6efcd0efe274fd58a7d08e9a"><code>27992317365bc58c6efcd0efe274fd58a7d08e9a</code></a> | October 18, 2020 | <code>evm-verifier/solidity/contracts</code> (recursive directory)<br><code>scalable-dex/contracts/src</code> (recursive directory) |
| <a href="https://github.com/starkware-libs/starkex-contracts/commit/8d596dd"><code>8d596dd</code></a> | — | <code>evm-verifier/solidity/contracts</code> (recursive directory)<br><code>scalable-dex/contracts/src</code> (recursive directory) |
| <a href="https://github.com/starkware-libs/starkex-contracts/commit/e4c1faa"><code>e4c1faa</code></a> | — | <code>evm-verifier/solidity/contracts</code> (recursive directory) |

## ChainSecurity Code Assessment of the Starknet Teleport Smart Contracts

- Report: [2022_06-chainsecurity-makerdao-starknet-teleport-audit.md](<reports/2022_06-chainsecurity-makerdao-starknet-teleport-audit.md>)
- Auditor: ChainSecurity
- Date: 2022-06-21
- Description: ChainSecurity assessment for MakerDAO of the Starknet Teleport extension of the DAI bridge (L1DAITeleportGateway.sol and l2_dai_teleport_gateway.cairo) over three versions in starknet-dai-bridge, with all other files, the DAI bridge and dss-teleport excluded. Two Medium and two Low findings were reported, all corrected.

### Repository: <a href="https://github.com/sky-ecosystem/starknet-dai-bridge"><code>sky-ecosystem/starknet-dai-bridge</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/sky-ecosystem/starknet-dai-bridge/commit/b6233cfdbd3068fa58c1951d38901f883e39a8be"><code>b6233cfdbd3068fa58c1951d38901f883e39a8be</code></a> | June 9, 2022 | <code>contracts/l1/L1DAITeleportGateway.sol</code><br><code>contracts/l2/l2_dai_teleport_gateway.cairo</code> (cairo) |
| <a href="https://github.com/sky-ecosystem/starknet-dai-bridge/commit/3d3385cd16f516a8e70709fbc7910ba517d0b0a7"><code>3d3385cd16f516a8e70709fbc7910ba517d0b0a7</code></a> | June 13, 2022 | <code>contracts/l1/L1DAITeleportGateway.sol</code><br><code>contracts/l2/l2_dai_teleport_gateway.cairo</code> (cairo) |
| <a href="https://github.com/sky-ecosystem/starknet-dai-bridge/commit/33b2989e55ec68c59b3c4e8f3df2638ea07c1fa4"><code>33b2989e55ec68c59b3c4e8f3df2638ea07c1fa4</code></a> | June 20, 2022 | <code>contracts/l1/L1DAITeleportGateway.sol</code><br><code>contracts/l2/l2_dai_teleport_gateway.cairo</code> (cairo) |

## CryptoExperts Code Review of StarkWare&#x27;s EVM STARK Verifier (v4.0)

- Report: [2022_07-cryptoexperts-evm-stark-verifier-v4.0-audit.md](<reports/2022_07-cryptoexperts-evm-stark-verifier-v4.0-audit.md>)
- Auditor: CryptoExperts
- Date: 2022-07-07
- Description: CryptoExperts cryptographic code review of the Solidity STARK verifier contracts (PRNG, verifier channel, Merkle and FRI verification, StarkVerifier) in starkex-contracts evm-verifier at the StarkEx v4.0 commit, checking spec compliance and soundness. The report was updated after StarkWare&#x27;s fixes; the highest-rated observation is Medium risk (PRNG seed refreshing).

### Repository: <a href="https://github.com/starkware-libs/starkex-contracts"><code>starkware-libs/starkex-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/starkware-libs/starkex-contracts/blob/0efa9ce324b04226de5dcd7a0139b109bca8f074/evm-verifier/solidity/contracts/PrimeFieldElement0.sol"><code>0efa9ce324b04226de5dcd7a0139b109bca8f074</code></a> | October 14, 2021 | <code>evm-verifier/solidity/contracts/PrimeFieldElement0.sol</code><br><code>evm-verifier/solidity/contracts/HornerEvaluator.sol</code><br><code>evm-verifier/solidity/contracts/Prng.sol</code><br><code>evm-verifier/solidity/contracts/VerifierChannel.sol</code><br><code>evm-verifier/solidity/contracts/IMerkleVerifier.sol</code><br><code>evm-verifier/solidity/contracts/MerkleVerifier.sol</code><br><code>evm-verifier/solidity/contracts/MerkleStatementContract.sol</code><br><code>evm-verifier/solidity/contracts/MerkleStatementVerifier.sol</code><br><code>evm-verifier/solidity/contracts/FriLayer.sol</code><br><code>evm-verifier/solidity/contracts/Fri.sol.ref</code><br><code>evm-verifier/solidity/contracts/FriStatementContract.sol</code><br><code>evm-verifier/solidity/contracts/FriStatementVerifier.sol.ref</code><br><code>evm-verifier/solidity/contracts/MemoryAccessUtils.sol.ref</code><br><code>evm-verifier/solidity/contracts/StarkVerifier.sol.ref</code><br><code>evm-verifier/solidity/contracts/interfaces/IStarkVerifier.sol</code><br><code>evm-verifier/solidity/contracts/components/FactRegistry.sol</code> (explicitly not audited) |

## ChainSecurity Code Assessment of the StarkNet-DAI-Bridge Smart Contracts

- Report: [2022_10-chainsecurity-makerdao-starknet-dai-bridge-audit.md](<reports/2022_10-chainsecurity-makerdao-starknet-dai-bridge-audit.md>)
- Auditor: ChainSecurity
- Date: 2022-10-18
- Description: ChainSecurity assessment for MakerDAO of the StarkNet DAI bridge (L1DAIBridge, L1Escrow, L1EscrowMom, L1GovernanceRelay, L2 dai, l2_dai_bridge, l2_governance_relay) over six versions from November 2021 to the October 2022 fee-model update, with mocks.sol, account.cairo and registry.cairo excluded. A Critical escrow-draining issue in L1DAIBridge and a High token-stealing issue in L2 DAI were found in Version 1 and corrected, along with five Medium and five Low findings.

### Repository: <a href="https://github.com/sky-ecosystem/starknet-dai-bridge"><code>sky-ecosystem/starknet-dai-bridge</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/sky-ecosystem/starknet-dai-bridge/commit/ba740acd782c18650ad0c70d623ba3b03087d49e"><code>ba740acd782c18650ad0c70d623ba3b03087d49e</code></a> | November 21, 2021 | <code>contracts/l1/L1DAIBridge.sol</code><br><code>contracts/l1/L1Escrow.sol</code><br><code>contracts/l1/L1GovernanceRelay.sol</code><br><code>contracts/l2/dai.cairo</code> (cairo)<br><code>contracts/l2/l2_dai_bridge.cairo</code> (cairo)<br><code>contracts/l2/l2_governance_relay.cairo</code> (cairo)<br><code>contracts/l1/mocks.sol</code> (explicitly not audited)<br><code>contracts/l2/account.cairo</code> (cairo) (explicitly not audited)<br><code>contracts/l2/registry.cairo</code> (cairo) (explicitly not audited) |
| <a href="https://github.com/sky-ecosystem/starknet-dai-bridge/commit/14c52313b10e8006e66835690ed5eb6546be2b5a"><code>14c52313b10e8006e66835690ed5eb6546be2b5a</code></a> | December 1, 2021 | <code>contracts/l1/L1DAIBridge.sol</code><br><code>contracts/l1/L1Escrow.sol</code><br><code>contracts/l1/L1GovernanceRelay.sol</code><br><code>contracts/l2/dai.cairo</code> (cairo)<br><code>contracts/l2/l2_dai_bridge.cairo</code> (cairo)<br><code>contracts/l2/l2_governance_relay.cairo</code> (cairo) |
| <a href="https://github.com/sky-ecosystem/starknet-dai-bridge/commit/bdea59fd2d273bf7a91f3dc5f745ba2a66560805"><code>bdea59fd2d273bf7a91f3dc5f745ba2a66560805</code></a> | December 5, 2021 | <code>contracts/l1/L1DAIBridge.sol</code><br><code>contracts/l1/L1Escrow.sol</code><br><code>contracts/l1/L1GovernanceRelay.sol</code><br><code>contracts/l2/dai.cairo</code> (cairo)<br><code>contracts/l2/l2_dai_bridge.cairo</code> (cairo)<br><code>contracts/l2/l2_governance_relay.cairo</code> (cairo) |
| <a href="https://github.com/sky-ecosystem/starknet-dai-bridge/commit/b367d6adf659bcaa550b794b9f8de3ea8cd14f4c"><code>b367d6adf659bcaa550b794b9f8de3ea8cd14f4c</code></a> | March 16, 2022 | <code>contracts/l1/L1DAIBridge.sol</code><br><code>contracts/l1/L1Escrow.sol</code><br><code>contracts/l1/L1EscrowMom.sol</code><br><code>contracts/l1/L1GovernanceRelay.sol</code><br><code>contracts/l2/dai.cairo</code> (cairo)<br><code>contracts/l2/l2_dai_bridge.cairo</code> (cairo)<br><code>contracts/l2/l2_governance_relay.cairo</code> (cairo) |
| <a href="https://github.com/sky-ecosystem/starknet-dai-bridge/commit/9939066ed9e146a1bcf1ef859e07673bec836568"><code>9939066ed9e146a1bcf1ef859e07673bec836568</code></a> | March 21, 2022 | <code>contracts/l1/L1DAIBridge.sol</code><br><code>contracts/l1/L1Escrow.sol</code><br><code>contracts/l1/L1EscrowMom.sol</code><br><code>contracts/l1/L1GovernanceRelay.sol</code><br><code>contracts/l2/dai.cairo</code> (cairo)<br><code>contracts/l2/l2_dai_bridge.cairo</code> (cairo)<br><code>contracts/l2/l2_governance_relay.cairo</code> (cairo) |
| <a href="https://github.com/sky-ecosystem/starknet-dai-bridge/commit/51b832099acb5fa02da5a5c683f729922e88d497"><code>51b832099acb5fa02da5a5c683f729922e88d497</code></a> | October 10, 2022 | <code>contracts/l1/L1DAIBridge.sol</code><br><code>contracts/l1/L1Escrow.sol</code><br><code>contracts/l1/L1EscrowMom.sol</code><br><code>contracts/l1/L1GovernanceRelay.sol</code><br><code>contracts/l2/dai.cairo</code> (cairo)<br><code>contracts/l2/l2_dai_bridge.cairo</code> (cairo)<br><code>contracts/l2/l2_governance_relay.cairo</code> (cairo) |

## CryptoExperts Code Review of the Cairo Implementation of the STARK/Cairo Verifier

- Report: [2022_12-cryptoexperts-stark-cairo-verifiers-in-cairo-audit.md](<reports/2022_12-cryptoexperts-stark-cairo-verifiers-in-cairo-audit.md>)
- Auditor: CryptoExperts
- Date: 2022-11-19
- Description: CryptoExperts cryptographic code review of the STARK/Cairo verifier written in Cairo (cairo-lang stark_verifier and cairo_verifier, used for recursive proofs) at the Cairo v0.10.0 commit, excluding auto-generated files. Only coding-practice and documentation observations were reported, all left unresolved.

### Repository: <a href="https://github.com/starkware-libs/cairo-lang"><code>starkware-libs/cairo-lang</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/starkware-libs/cairo-lang/blob/d61255f32a7011e9014e1204471103c719cfd5cb/src/starkware/cairo/cairo_verifier/layouts/recursive/cairo_verifier.cairo"><code>d61255f32a7011e9014e1204471103c719cfd5cb</code></a> | September 5, 2022 | <code>src/starkware/cairo/cairo_verifier/layouts/recursive/cairo_verifier.cairo</code> (cairo)<br><code>src/starkware/cairo/cairo_verifier/objects.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/config.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/diluted.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/layout.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/layouts/bitwise/composition.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/layouts/bitwise/global_values.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/layouts/bitwise/public_verify.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/layouts/bitwise/verify.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/layouts/dex/composition.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/layouts/dex/global_values.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/layouts/dex/public_verify.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/layouts/dex/verify.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/layouts/perpetual_with_bitwise/composition.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/layouts/perpetual_with_bitwise/global_values.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/layouts/perpetual_with_bitwise/public_verify.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/layouts/perpetual_with_bitwise/verify.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/layouts/recursive/composition.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/layouts/recursive/global_values.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/layouts/recursive/public_verify.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/layouts/recursive/verify.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/oods.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/params.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/public_input.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/public_memory.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/traces.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/core/air_interface.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/core/channel.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/core/channel_test.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/core/config.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/core/domains.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/core/fri/config.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/core/fri/fri.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/core/fri/fri_formula.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/core/fri/fri_layer.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/core/proof_of_work.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/core/queries.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/core/stark.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/core/table_commitment.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/core/utils.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/core/vector_commitment.cairo</code> (cairo)<br><code>src/starkware/cairo/stark_verifier/air/layouts/bitwise/autogenerated.cairo</code> (cairo) (explicitly not audited)<br><code>src/starkware/cairo/stark_verifier/air/layouts/bitwise/periodic_columns.cairo</code> (cairo) (explicitly not audited)<br><code>src/starkware/cairo/stark_verifier/air/layouts/dex/autogenerated.cairo</code> (cairo) (explicitly not audited)<br><code>src/starkware/cairo/stark_verifier/air/layouts/dex/periodic_columns.cairo</code> (cairo) (explicitly not audited)<br><code>src/starkware/cairo/stark_verifier/air/layouts/perpetual_with_bitwise/autogenerated.cairo</code> (cairo) (explicitly not audited)<br><code>src/starkware/cairo/stark_verifier/air/layouts/perpetual_with_bitwise/periodic_columns.cairo</code> (cairo) (explicitly not audited)<br><code>src/starkware/cairo/stark_verifier/air/layouts/recursive/autogenerated.cairo</code> (cairo) (explicitly not audited)<br><code>src/starkware/cairo/stark_verifier/air/layouts/recursive/periodic_columns.cairo</code> (cairo) (explicitly not audited) |

## CryptoExperts Code Review of the Cairo &amp; SHARP Verifiers (v3.0)

- Report: [2022_12-cryptoexperts-cairo-and-sharp-verifiers-v3.0-audit.md](<reports/2022_12-cryptoexperts-cairo-and-sharp-verifiers-v3.0-audit.md>)
- Auditor: CryptoExperts
- Date: 2022-12-17
- Description: CryptoExperts cryptographic code review of the Solidity Cairo verifier (cpu) and SHARP/GPS statement verifier (gps) in starkex-contracts evm-verifier at StarkEx v4.0 plus the Cairo simple and general bootloaders in cairo-lang (v0.8.0, v0.9.0). Fixes were counter-audited at SHARP EVM Verifier v3.0 (f81ba5f) and Cairo v0.10.3 (de741b9); the highest-rated observation is Low risk.

### Repository: <a href="https://github.com/starkware-libs/starkex-contracts"><code>starkware-libs/starkex-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/starkware-libs/starkex-contracts/blob/0efa9ce324b04226de5dcd7a0139b109bca8f074/evm-verifier/solidity/contracts/cpu/PageInfo.sol"><code>0efa9ce324b04226de5dcd7a0139b109bca8f074</code></a> | October 14, 2021 | <code>evm-verifier/solidity/contracts/cpu/PageInfo.sol</code><br><code>evm-verifier/solidity/contracts/cpu/CpuPublicInputOffsetsBase.sol</code><br><code>evm-verifier/solidity/contracts/cpu/CpuPublicInputOffsets.sol</code><br><code>evm-verifier/solidity/contracts/cpu/MemoryPageFactRegistry.sol</code><br><code>evm-verifier/solidity/contracts/cpu/CairoVerifierContract.sol</code><br><code>evm-verifier/solidity/contracts/cpu/CpuFrilessVerifier.sol</code><br><code>evm-verifier/solidity/contracts/cpu/CpuVerifier.sol.ref</code><br><code>evm-verifier/solidity/contracts/cpu/CairoBootloaderProgram.sol</code> (explicitly not audited)<br><code>evm-verifier/solidity/contracts/gps/GpsOutputParser.sol</code><br><code>evm-verifier/solidity/contracts/gps/GpsStatementVerifier.sol</code><br><code>evm-verifier/solidity/contracts/components/FactRegistry.sol</code> (explicitly not audited)<br><code>evm-verifier/solidity/contracts/interfaces/Identity.sol</code> (explicitly not audited) |
| <a href="https://github.com/starkware-libs/starkex-contracts/blob/f81ba5fdbd68516db50ea9679de9d0ac2f8049d8/evm-verifier/solidity/contracts/cpu/PageInfo.sol"><code>f81ba5fdbd68516db50ea9679de9d0ac2f8049d8</code></a> | December 8, 2022 | <code>evm-verifier/solidity/contracts/cpu/PageInfo.sol</code><br><code>evm-verifier/solidity/contracts/cpu/CpuPublicInputOffsetsBase.sol</code><br><code>evm-verifier/solidity/contracts/cpu/CpuPublicInputOffsets.sol</code><br><code>evm-verifier/solidity/contracts/cpu/MemoryPageFactRegistry.sol</code><br><code>evm-verifier/solidity/contracts/cpu/CairoVerifierContract.sol</code><br><code>evm-verifier/solidity/contracts/cpu/CpuFrilessVerifier.sol</code><br><code>evm-verifier/solidity/contracts/cpu/CpuVerifier.sol</code><br><code>evm-verifier/solidity/contracts/cpu/PublicMemoryOffsets.sol</code><br><code>evm-verifier/solidity/contracts/gps/GpsOutputParser.sol</code><br><code>evm-verifier/solidity/contracts/gps/GpsStatementVerifier.sol</code> |

### Repository: <a href="https://github.com/starkware-libs/starkex2.0-contracts"><code>starkware-libs/starkex2.0-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

### Repository: <a href="https://github.com/starkware-libs/cairo-lang"><code>starkware-libs/cairo-lang</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/starkware-libs/cairo-lang/blob/4e233516f52477ad158bc81a86ec2760471c1b65/src/starkware/cairo/bootloaders/simple_bootloader/simple_bootloader.cairo"><code>4e233516f52477ad158bc81a86ec2760471c1b65</code></a> | March 13, 2022 | <code>src/starkware/cairo/bootloaders/simple_bootloader/simple_bootloader.cairo</code> (cairo)<br><code>src/starkware/cairo/bootloaders/simple_bootloader/run_simple_bootloader.cairo</code> (cairo)<br><code>src/starkware/cairo/bootloaders/simple_bootloader/execute_task.cairo</code> (cairo) |
| <a href="https://github.com/starkware-libs/cairo-lang/blob/167b28bcd940fd25ea3816204fa882a0b0a49603/src/starkware/cairo/bootloaders/bootloader/bootloader.cairo"><code>167b28bcd940fd25ea3816204fa882a0b0a49603</code></a> | June 5, 2022 | <code>src/starkware/cairo/bootloaders/bootloader/bootloader.cairo</code> (cairo) |
| <a href="https://github.com/starkware-libs/cairo-lang/blob/de741b92657f245a50caab99cfaef093152fd8be/src/starkware/cairo/bootloaders/simple_bootloader/simple_bootloader.cairo"><code>de741b92657f245a50caab99cfaef093152fd8be</code></a> | December 4, 2022 | <code>src/starkware/cairo/bootloaders/simple_bootloader/simple_bootloader.cairo</code> (cairo)<br><code>src/starkware/cairo/bootloaders/simple_bootloader/run_simple_bootloader.cairo</code> (cairo)<br><code>src/starkware/cairo/bootloaders/simple_bootloader/execute_task.cairo</code> (cairo)<br><code>src/starkware/cairo/bootloaders/bootloader/bootloader.cairo</code> (cairo) |

## NM-0194 Starknet Token Distributor Security Review

- Report: [2024_02-nethermind-starknet-token-distributor-security-review.md](<reports/2024_02-nethermind-starknet-token-distributor-security-review.md>)
- Auditor: Nethermind
- Date: 2024-02-22
- Description: Nethermind security review (NM-0194) for the Starknet Foundation of the Cairo Merkle-tree Distributor contract in the defispring repository, which lets users claim STRK against owner-published Merkle roots. Six Info and Best Practices findings were reported, with fixes reviewed up to commit be3ca1f.

### Repository: <a href="https://github.com/starknetfndn/defispring"><code>starknetfndn/defispring</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/starknetfndn/defispring/commit/5ca2536c6cfccb7527dd633796d46a0d2f74febd"><code>5ca2536c6cfccb7527dd633796d46a0d2f74febd</code></a> | February 14, 2024 | <code>contract/src/contract.cairo</code> (cairo)<br><code>contract/src/lib.cairo</code> (cairo) |
| <a href="https://github.com/starknetfndn/defispring/commit/a20d0be7dc4ab5441770c3cd9a190a9444f1bb3f"><code>a20d0be7dc4ab5441770c3cd9a190a9444f1bb3f</code></a> | February 20, 2024 | <code>contract/src/contract.cairo</code> (cairo) |
| <a href="https://github.com/starknetfndn/defispring/commit/c91d05feb3b5b7ca06bce3593144021bac2ebad9"><code>c91d05feb3b5b7ca06bce3593144021bac2ebad9</code></a> | February 20, 2024 | <code>contract/src/contract.cairo</code> (cairo) |
| <a href="https://github.com/starknetfndn/defispring/commit/5f06c147b42daf3685d3cb9a5f58c67edc757998"><code>5f06c147b42daf3685d3cb9a5f58c67edc757998</code></a> | February 20, 2024 | <code>contract/src/contract.cairo</code> (cairo) |
| <a href="https://github.com/starknetfndn/defispring/commit/be3ca1f2b55e1de94399c29da854adb30184bebc"><code>be3ca1f2b55e1de94399c29da854adb30184bebc</code></a> | February 21, 2024 | <code>contract/src/contract.cairo</code> (cairo) |

## Audit of Herodotus&#x27; Integrity - A Cairo Verifier compatible with Starknet written in Cairo 1

- Report: [2024_09-zksecurity-herodotus-integrity-cairo-verifier-audit.md](<reports/2024_09-zksecurity-herodotus-integrity-cairo-verifier-audit.md>)
- Auditor: zkSecurity
- Date: 2024-09-23
- Description: Four-week zkSecurity audit for Herodotus of Integrity, a Cairo 1 STARK/FRI verifier for Cairo programs deployed on Starknet, checking soundness and divergences from StarkWare&#x27;s Cairo 0 verifier (cairo-lang v0.13.2, used only as reference) including split contracts, split proofs, Cairo 1 programs and Stone v6 proofs. One High (lack of specification), three Medium and one Low findings were reported without a fix review.

### Repository: <a href="https://github.com/HerodotusDev/integrity"><code>HerodotusDev/integrity</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/HerodotusDev/integrity/commit/aa28d4dd0eafe7b0a4109c8a5c81c2dd27d3d6cc"><code>aa28d4dd0eafe7b0a4109c8a5c81c2dd27d3d6cc</code></a> | September 24, 2024 | <code>src</code> (recursive directory) (cairo) |

## StarkWare Cryptography Audit OS

- Report: [2024_11-abdk-starknet-os-cryptography-audit.md](<reports/2024_11-abdk-starknet-os-cryptography-audit.md>)
- Auditor: ABDK Consulting
- Date: 2024-11-21
- Description: ABDK review for StarkWare of the update to the Cairo library and the Starknet OS between cairo-lang v0.10.1 and v0.12.1, covering keccak, Poseidon, secp, Patricia and hash-state library code plus OS contract-class hashing, transaction and syscall execution, state and output. No Critical or Major issues were found; 19 Moderate and 16 Minor recommendations were reported.

### Repository: <a href="https://github.com/starkware-libs/cairo-lang"><code>starkware-libs/cairo-lang</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/starkware-libs/cairo-lang/compare/v0.10.1...v0.12.1"><code>0ba3ff59c1c86f2a30adc8fd144eaacb22c48ce9…0614f265421735bbb567d9b5897791a51b3705de</code></a> (commit range) | October 17, 2022 – August 7, 2023 | <code>src/starkware/cairo/common/builtin_keccak/keccak.cairo</code> (cairo)<br><code>src/starkware/cairo/common/builtin_poseidon/poseidon.cairo</code> (cairo)<br><code>src/starkware/cairo/common/cairo_keccak/keccak.cairo</code> (cairo)<br><code>src/starkware/cairo/common/cairo_secp/constants.cairo</code> (cairo)<br><code>src/starkware/cairo/common/cairo_secp/ec.cairo</code> (cairo)<br><code>src/starkware/cairo/common/cairo_secp/signature.cairo</code> (cairo)<br><code>src/starkware/cairo/common/cairo_secp/field.cairo</code> (cairo)<br><code>src/starkware/cairo/common/cairo_secp/bigint.cairo</code> (cairo)<br><code>src/starkware/cairo/common/keccak_utils/keccak_utils.cairo</code> (cairo)<br><code>src/starkware/cairo/common/cairo_builtins.cairo</code> (cairo)<br><code>src/starkware/cairo/common/hash_chain.cairo</code> (cairo)<br><code>src/starkware/cairo/common/hash_state_poseidon.cairo</code> (cairo)<br><code>src/starkware/cairo/common/hash_state.cairo</code> (cairo)<br><code>src/starkware/cairo/common/patricia_utils.cairo</code> (cairo)<br><code>src/starkware/cairo/common/patricia_with_poseidon.cairo</code> (cairo)<br><code>src/starkware/cairo/common/patricia.cairo</code> (cairo)<br><code>src/starkware/cairo/common/poseidon_state.cairo</code> (cairo)<br><code>src/starkware/cairo/common/sponge_as_hash.cairo</code> (cairo)<br><code>src/starkware/cairo/common/uint256.cairo</code> (cairo)<br><code>src/starkware/starknet/core/os/contract_class/compiled_class.cairo</code> (cairo)<br><code>src/starkware/starknet/core/os/contract_class/contract_class.cairo</code> (cairo)<br><code>src/starkware/starknet/core/os/execution/deprecated_execute_syscalls.cairo</code> (cairo)<br><code>src/starkware/starknet/core/os/execution/execute_entry_point.cairo</code> (cairo)<br><code>src/starkware/starknet/core/os/execution/execute_syscalls.cairo</code> (cairo)<br><code>src/starkware/starknet/core/os/execution/execute_transactions.cairo</code> (cairo)<br><code>src/starkware/starknet/core/os/block_context.cairo</code> (cairo)<br><code>src/starkware/starknet/core/os/builtins.cairo</code> (cairo)<br><code>src/starkware/starknet/core/os/constants.cairo</code> (cairo)<br><code>src/starkware/starknet/core/os/contracts.cairo</code> (cairo)<br><code>src/starkware/starknet/core/os/os.cairo</code> (cairo)<br><code>src/starkware/starknet/core/os/output.cairo</code> (cairo)<br><code>src/starkware/starknet/core/os/state.cairo</code> (cairo)<br><code>src/starkware/starknet/core/os/transactions.cairo</code> (cairo) |

## Starknet Staking Cairo Application Security Audit

- Report: [2024_11-zellic-starknet-staking-v1-audit.md](<reports/2024_11-zellic-starknet-staking-v1-audit.md>)
- Auditor: Zellic
- Date: 2024-11-22
- Description: Zellic assessment for StarkWare of the Starknet Staking v1 contracts (staking, pool, reward supplier, minting curve, shared roles/replaceability components and the L1 MintManager/RewardSupplier Solidity contracts) in two review periods, at 1fb6d43 (September 2024) and e4f75ea (November 2024). It reported one Critical, three High, four Medium, four Low and three Informational findings (by impact rating), most fixed in listed commits.

### Repository: <a href="https://github.com/starkware-libs/starknet-staking"><code>starkware-libs/starknet-staking</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/starkware-libs/starknet-staking/commit/1fb6d430593ac64fbdc886cb165dc2e73353a289"><code>1fb6d430593ac64fbdc886cb165dc2e73353a289</code></a> | September 4, 2024 | <code>workspace/apps/staking/contracts/src</code> (recursive directory) (cairo)<br><code>workspace/packages/contracts/src</code> (recursive directory) (cairo)<br><code>workspace/apps/staking/solidity/MintManager.sol</code> |
| <a href="https://github.com/starkware-libs/starknet-staking/commit/695e2cad098fc072b6e13fed6cb6ae749c95c846"><code>695e2cad098fc072b6e13fed6cb6ae749c95c846</code></a> | September 9, 2024 | <code>workspace/apps/staking/contracts/src</code> (recursive directory) (cairo) |
| <a href="https://github.com/starkware-libs/starknet-staking/commit/fb6c3a88252b67d3733bb9f71c06091ae0256156"><code>fb6c3a88252b67d3733bb9f71c06091ae0256156</code></a> | September 25, 2024 | <code>workspace/apps/staking/contracts/src</code> (recursive directory) (cairo) |
| <a href="https://github.com/starkware-libs/starknet-staking/commit/e8e2ab58720baa646642764cb101e0e8e16623fc"><code>e8e2ab58720baa646642764cb101e0e8e16623fc</code></a> | October 8, 2024 | <code>workspace/apps/staking/solidity/stake/MintManager.sol</code> |
| <a href="https://github.com/starkware-libs/starknet-staking/commit/2c81b5f09200fb47df792a230be5563717710b12"><code>2c81b5f09200fb47df792a230be5563717710b12</code></a> | October 27, 2024 | <code>workspace/apps/staking/contracts/src</code> (recursive directory) (cairo) |
| <a href="https://github.com/starkware-libs/starknet-staking/commit/005d8b686b402ae9a2ae03f7a969eabad4a339cf"><code>005d8b686b402ae9a2ae03f7a969eabad4a339cf</code></a> | November 6, 2024 | <code>workspace/apps/staking/contracts/src</code> (recursive directory) (cairo)<br><code>workspace/packages/contracts/src</code> (recursive directory) (cairo) |
| <a href="https://github.com/starkware-libs/starknet-staking/commit/e4f75ea411d1a46abdb5127d0abcc5b3891e9300"><code>e4f75ea411d1a46abdb5127d0abcc5b3891e9300</code></a> | November 10, 2024 | <code>workspace/apps/staking/contracts/src</code> (recursive directory) (cairo)<br><code>workspace/packages/contracts/src/components/roles</code> (recursive directory) (cairo)<br><code>workspace/packages/contracts/src/components/replaceability</code> (recursive directory) (cairo)<br><code>workspace/packages/contracts/src/types/time.cairo</code> (cairo)<br><code>workspace/apps/staking/L1/starkware/solidity/stake</code> (recursive directory) |
| <a href="https://github.com/starkware-libs/starknet-staking/commit/c70d5a908827ad155221aa6e880cc87fd3267f86"><code>c70d5a908827ad155221aa6e880cc87fd3267f86</code></a> | November 12, 2024 | <code>workspace/apps/staking/contracts/src</code> (recursive directory) (cairo) |
| <a href="https://github.com/starkware-libs/starknet-staking/commit/7a3e786de7a1063c106dfeced24cab8e14f1ae3f"><code>7a3e786de7a1063c106dfeced24cab8e14f1ae3f</code></a> | November 13, 2024 | <code>workspace/apps/staking/contracts/src</code> (recursive directory) (cairo) |
| <a href="https://github.com/starkware-libs/starknet-staking/commit/eeba818e6445ad10c4c132b6f7d72566d68a7da8"><code>eeba818e6445ad10c4c132b6f7d72566d68a7da8</code></a> | November 13, 2024 | <code>workspace/apps/staking/contracts/src</code> (recursive directory) (cairo)<br><code>workspace/packages/contracts/src/types/time.cairo</code> (cairo) |

## Starkware Utils Security Review

- Report: [2025_05-cairosecurityclan-starkware-starknet-utils-v1-audit.md](<reports/2025_05-cairosecurityclan-starkware-starknet-utils-v1-audit.md>)
- Auditor: Cairo Security Clan
- Date: 2025-05-05
- Description: Cairo Security Clan security review of the starkware-starknet-utils shared Cairo library (deposit, nonce, pausable and request-approvals components, math, trace, iterable map, message hash and time types) at 43451ba, with fixes at 142ba4f. Two Informational and one Best Practices finding were reported, all in the Deposit component.

### Repository: <a href="https://github.com/starkware-libs/starkware-starknet-utils"><code>starkware-libs/starkware-starknet-utils</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/starkware-libs/starkware-starknet-utils/commit/43451ba97e2bbcffa34c1cf984b75cf1c92f6fa1"><code>43451ba97e2bbcffa34c1cf984b75cf1c92f6fa1</code></a> | March 27, 2025 | <code>packages/utils/src/components.cairo</code> (cairo)<br><code>packages/utils/src/constants.cairo</code> (cairo)<br><code>packages/utils/src/erc20_mocks.cairo</code> (cairo)<br><code>packages/utils/src/errors.cairo</code> (cairo)<br><code>packages/utils/src/interfaces.cairo</code> (cairo)<br><code>packages/utils/src/iterable_map.cairo</code> (cairo)<br><code>packages/utils/src/lib.cairo</code> (cairo)<br><code>packages/utils/src/math.cairo</code> (cairo)<br><code>packages/utils/src/message_hash.cairo</code> (cairo)<br><code>packages/utils/src/tests.cairo</code> (cairo)<br><code>packages/utils/src/trace.cairo</code> (cairo)<br><code>packages/utils/src/types.cairo</code> (cairo)<br><code>packages/utils/src/utils.cairo</code> (cairo)<br><code>packages/utils/src/components/deposit/deposit.cairo</code> (cairo)<br><code>packages/utils/src/components/deposit/errors.cairo</code> (cairo)<br><code>packages/utils/src/components/deposit/events.cairo</code> (cairo)<br><code>packages/utils/src/components/deposit/interface.cairo</code> (cairo)<br><code>packages/utils/src/components/nonce/interface.cairo</code> (cairo)<br><code>packages/utils/src/components/nonce/mock_contract.cairo</code> (cairo)<br><code>packages/utils/src/components/nonce/nonce.cairo</code> (cairo)<br><code>packages/utils/src/components/nonce/test.cairo</code> (cairo)<br><code>packages/utils/src/components/pausable/interface.cairo</code> (cairo)<br><code>packages/utils/src/components/pausable/pausable.cairo</code> (cairo)<br><code>packages/utils/src/components/request_approvals/errors.cairo</code> (cairo)<br><code>packages/utils/src/components/request_approvals/interface.cairo</code> (cairo)<br><code>packages/utils/src/components/request_approvals/request_approvals.cairo</code> (cairo)<br><code>packages/utils/src/components/deposit.cairo</code> (cairo)<br><code>packages/utils/src/components/nonce.cairo</code> (cairo)<br><code>packages/utils/src/components/pausable.cairo</code> (cairo)<br><code>packages/utils/src/components/request_approvals.cairo</code> (cairo)<br><code>packages/utils/src/interfaces/identity.cairo</code> (cairo)<br><code>packages/utils/src/interfaces/mintable_token.cairo</code> (cairo)<br><code>packages/utils/src/math/abs.cairo</code> (cairo)<br><code>packages/utils/src/math/fraction.cairo</code> (cairo)<br><code>packages/utils/src/math/utils.cairo</code> (cairo)<br><code>packages/utils/src/trace/errors.cairo</code> (cairo)<br><code>packages/utils/src/trace/mock.cairo</code> (cairo)<br><code>packages/utils/src/trace/test.cairo</code> (cairo)<br><code>packages/utils/src/trace/trace.cairo</code> (cairo)<br><code>packages/utils/src/types/time.cairo</code> (cairo)<br><code>packages/utils/src/types/time/errors.cairo</code> (cairo)<br><code>packages/utils/src/types/time/time.cairo</code> (cairo) |
| <a href="https://github.com/starkware-libs/starkware-starknet-utils/commit/142ba4fd8525368690969f623c682e33230ce866"><code>142ba4fd8525368690969f623c682e33230ce866</code></a> | April 28, 2025 | <code>packages/utils/src/components/deposit/deposit.cairo</code> (cairo)<br><code>packages/utils/src/components/deposit/errors.cairo</code> (cairo)<br><code>packages/utils/src/components/deposit/events.cairo</code> (cairo) |

## Starknet Part 2 Audit Report

- Report: [2025_06-codehawks-starknet-staking-part-2-audit.md](<reports/2025_06-codehawks-starknet-staking-part-2-audit.md>)
- Auditor: CodeHawks
- Date: 2025-06-14
- Description: CodeHawks competitive audit (Apr 3 - Apr 24, 2025) of Starknet Staking v2 (SNIP-28: block attestation, commission commitments, epochs) Cairo contracts in the staking app of the contest repository. It found one High, one Medium and seven Low issues.

### Repository: <a href="https://github.com/CodeHawks-Contests/2025-04-starknet-part-2"><code>CodeHawks-Contests/2025-04-starknet-part-2</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/CodeHawks-Contests/2025-04-starknet-part-2/commit/656f00bd62a19540a803ec9512456349eba61dcd"><code>656f00bd62a19540a803ec9512456349eba61dcd</code></a> | April 4, 2025 | <code>workspace/apps/staking/contracts/src/attestation/attestation.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/attestation/errors.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/attestation/interface.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/constants.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/errors.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/pool/eic.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/pool/errors.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/pool/interface.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/pool/objects.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/pool/pool.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/pool/pool_member_balance_trace/trace.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/reward_supplier/errors.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/reward_supplier/interface.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/reward_supplier/reward_supplier.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/staking/eic.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/staking/errors.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/staking/interface.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/staking/objects.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/staking/staker_balance_trace/trace.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/staking/staking.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/types.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/utils.cairo</code> (cairo) |

## Audit of the Stwo-Cairo Verifier

- Report: [2025_08-zksecurity-stwo-cairo-verifier-audit.md](<reports/2025_08-zksecurity-stwo-cairo-verifier-audit.md>)
- Auditor: zkSecurity
- Date: 2025-08-06
- Description: zkSecurity three-week audit (from Jul 14, 2025) of stwo_cairo_verifier, the Cairo implementation of the Stwo Circle-STARK verifier for the Cairo AIR used for recursive proving. It found two High findings (Fiat-Shamir omission of public memory IDs and LogUp sums of unused components) plus Medium, Low and informational issues.

### Repository: <a href="https://github.com/starkware-libs/stwo-cairo"><code>starkware-libs/stwo-cairo</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/starkware-libs/stwo-cairo/commit/aef7d0951471c6f0474d7c1f936241095875d3d5"><code>aef7d0951471c6f0474d7c1f936241095875d3d5</code></a> | July 15, 2025 | <code>stwo_cairo_verifier</code> (recursive directory) (cairo) |

## USDC Token Migration Audit

- Report: [2025_11-openzeppelin-usdc-token-migration-audit.md](<reports/2025_11-openzeppelin-usdc-token-migration-audit.md>)
- Auditor: OpenZeppelin
- Date: 2025-11-28
- Description: OpenZeppelin audit (Nov 11-12, 2025) of the Starknet token migration contract that swaps StarkGate-bridged USDC.e for native CCTP USDC and batches legacy tokens back to L1 through StarkGate. It found only five notes, four of which were resolved in follow-up pull requests.

### Repository: <a href="https://github.com/starkware-libs/usdc-migration"><code>starkware-libs/usdc-migration</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/starkware-libs/usdc-migration/commit/de1489d6a76966e25a99d46993f183c440080319"><code>de1489d6a76966e25a99d46993f183c440080319</code></a> | November 13, 2025 | <code>packages/token_migration/src/errors.cairo</code> (cairo)<br><code>packages/token_migration/src/events.cairo</code> (cairo)<br><code>packages/token_migration/src/interface.cairo</code> (cairo)<br><code>packages/token_migration/src/lib.cairo</code> (cairo)<br><code>packages/token_migration/src/starkgate_interface.cairo</code> (cairo)<br><code>packages/token_migration/src/token_migration.cairo</code> (cairo)<br><code>packages/token_migration/src/utils.cairo</code> (cairo) |
| <a href="https://github.com/starkware-libs/usdc-migration/commit/13bdbf0c2ad87efecda6b931b7642d82a99b0fe3"><code>13bdbf0c2ad87efecda6b931b7642d82a99b0fe3</code></a> | November 17, 2025 | <code>packages/token_migration/src/interface.cairo</code> (cairo)<br><code>packages/token_migration/src/token_migration.cairo</code> (cairo) |
| <a href="https://github.com/starkware-libs/usdc-migration/commit/c73cf0eca16528e365b99a06659deda2810b9667"><code>c73cf0eca16528e365b99a06659deda2810b9667</code></a> | November 17, 2025 | <code>packages/token_migration/src/lib.cairo</code> (cairo) |
| <a href="https://github.com/starkware-libs/usdc-migration/commit/36a5d2a4c4bb21cbb0bdc679922037c0ba90f3e5"><code>36a5d2a4c4bb21cbb0bdc679922037c0ba90f3e5</code></a> | November 17, 2025 | <code>packages/token_migration/src/token_migration.cairo</code> (cairo) |
| <a href="https://github.com/starkware-libs/usdc-migration/commit/c9970e7a6e09d2beb7ffc2f4df4c508179ae48f2"><code>c9970e7a6e09d2beb7ffc2f4df4c508179ae48f2</code></a> | November 18, 2025 | <code>packages/token_migration/src/events.cairo</code> (cairo)<br><code>packages/token_migration/src/token_migration.cairo</code> (cairo) |

## Starkware (ERC20) Smart Contract Security Assessment

- Report: [2026_02-zellic-starkware-erc20-security-assessment.md](<reports/2026_02-zellic-starkware-erc20-security-assessment.md>)
- Auditor: Zellic
- Date: 2026-02-11
- Description: Zellic two-day assessment (Feb 5-6, 2026) of StarkGate token contracts ERC20Lockable, ERC20Mintable and eip712_utils in starkgate-contracts, including SNIP-2 compliance. It found a single informational issue.

### Repository: <a href="https://github.com/starknet-io/starkgate-contracts"><code>starknet-io/starkgate-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/starknet-io/starkgate-contracts/commit/c763c1f74692fbdd5015e023e765c403bfc01b95"><code>c763c1f74692fbdd5015e023e765c403bfc01b95</code></a> | February 4, 2026 | <code>packages/strk/src/erc20_lockable.cairo</code> (cairo)<br><code>packages/strk/src/eip712_utils.cairo</code> (cairo)<br><code>packages/sg_token/src/erc20_mintable.cairo</code> (cairo) |

## Code Assessment of the strkBTC Bridge Smart Contracts

- Report: [2026_04-chainsecurity-strkbtc-bridge-audit.md](<reports/2026_04-chainsecurity-strkbtc-bridge-audit.md>)
- Auditor: ChainSecurity
- Date: 2026-04-29
- Description: ChainSecurity code assessment of the strkBTC Bitcoin-to-Starknet quorum-signer bridge Cairo contracts (Bridge, Registry and strkBTC Token) across three versions, with the Bitcoin side and off-chain signers out of scope. It found one Low issue (corrected) and several informational findings.

### Repository: <a href="https://github.com/starkware-libs/strkBTC"><code>starkware-libs/strkBTC</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/starkware-libs/strkBTC/commit/134b36ea35bce5d72f365ef03d228d868632cf33"><code>134b36ea35bce5d72f365ef03d228d868632cf33</code></a> | March 29, 2026 | <code>contracts/bridge/src/bridge.cairo</code> (cairo)<br><code>contracts/bridge/src/errors.cairo</code> (cairo)<br><code>contracts/bridge/src/events.cairo</code> (cairo)<br><code>contracts/bridge/src/interface.cairo</code> (cairo)<br><code>contracts/bridge/src/lib.cairo</code> (cairo)<br><code>contracts/bridge/src/utils.cairo</code> (cairo)<br><code>contracts/registry/src/errors.cairo</code> (cairo)<br><code>contracts/registry/src/events.cairo</code> (cairo)<br><code>contracts/registry/src/interface.cairo</code> (cairo)<br><code>contracts/registry/src/lib.cairo</code> (cairo)<br><code>contracts/registry/src/registry.cairo</code> (cairo)<br><code>contracts/registry/src/utils.cairo</code> (cairo)<br><code>contracts/token/src/lib.cairo</code> (cairo)<br><code>contracts/token/src/token.cairo</code> (cairo) |
| <a href="https://github.com/starkware-libs/strkBTC/commit/8829f3d2c93e91a51282bd297c0ae3d31b51e353"><code>8829f3d2c93e91a51282bd297c0ae3d31b51e353</code></a> | April 6, 2026 | <code>contracts/bridge/src/bridge.cairo</code> (cairo)<br><code>contracts/bridge/src/errors.cairo</code> (cairo)<br><code>contracts/bridge/src/events.cairo</code> (cairo)<br><code>contracts/bridge/src/interface.cairo</code> (cairo)<br><code>contracts/registry/src/errors.cairo</code> (cairo)<br><code>contracts/registry/src/registry.cairo</code> (cairo) |
| <a href="https://github.com/starkware-libs/strkBTC/commit/482f932ca49fdbd3624d8d36834018c8aae802cb"><code>482f932ca49fdbd3624d8d36834018c8aae802cb</code></a> | April 9, 2026 | <code>contracts/bridge/src/bridge.cairo</code> (cairo)<br><code>contracts/bridge/src/errors.cairo</code> (cairo)<br><code>contracts/registry/src/registry.cairo</code> (cairo) |

## Starknet Security Review

- Report: [2025_08-pashov-starknet-btc-staking-security-review.md](<reports/2025_08-pashov-starknet-btc-staking-security-review.md>)
- Auditor: Pashov Audit Group
- Description: Pashov Audit Group review (Jul 31 - Aug 15, 2025) of the Starknet Staking v3 (BTC staking) Cairo contracts (Staking, Pool, RewardSupplier, MintingCurve) and shared starkware-starknet-utils components, with a fixes review. It found one Medium and eight Low issues.

### Repository: <a href="https://github.com/starkware-libs/starknet-staking"><code>starkware-libs/starknet-staking</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/starkware-libs/starknet-staking/commit/5c11a5689f2d2e08ffecebf30d3e49569accbfca"><code>5c11a5689f2d2e08ffecebf30d3e49569accbfca</code></a> | August 20, 2025 | <code>workspace/apps/staking/contracts/src/constants.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/errors.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/utils.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/minting_curve/errors.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/minting_curve/interface.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/minting_curve/minting_curve.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/pool/errors.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/pool/interface.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/pool/interface_v0.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/pool/objects.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/pool/pool.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/pool/pool_member_balance_trace/trace.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/reward_supplier/errors.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/reward_supplier/interface.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/reward_supplier/reward_supplier.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/staking/eic_v1_v2.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/staking/errors.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/staking/interface.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/staking/interface_v0.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/staking/objects.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/staking/staker_balance_trace/trace.cairo</code> (cairo)<br><code>workspace/apps/staking/contracts/src/staking/staking.cairo</code> (cairo) |

### Repository: <a href="https://github.com/starkware-libs/starkware-starknet-utils"><code>starkware-libs/starkware-starknet-utils</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/starkware-libs/starkware-starknet-utils/commit/142ba4fd8525368690969f623c682e33230ce866"><code>142ba4fd8525368690969f623c682e33230ce866</code></a> | April 28, 2025 | <code>packages/utils/src/components/replaceability/errors.cairo</code> (cairo)<br><code>packages/utils/src/components/replaceability/interface.cairo</code> (cairo)<br><code>packages/utils/src/components/replaceability/replaceability.cairo</code> (cairo)<br><code>packages/utils/src/components/roles/errors.cairo</code> (cairo)<br><code>packages/utils/src/components/roles/interface.cairo</code> (cairo)<br><code>packages/utils/src/components/roles/roles.cairo</code> (cairo)<br><code>packages/utils/src/interfaces/identity.cairo</code> (cairo)<br><code>packages/utils/src/iterable_map.cairo</code> (cairo)<br><code>packages/utils/src/trace/errors.cairo</code> (cairo)<br><code>packages/utils/src/trace/trace.cairo</code> (cairo)<br><code>packages/utils/src/types/time/errors.cairo</code> (cairo)<br><code>packages/utils/src/types/time/time.cairo</code> (cairo) |

## Irrelevant reports

### Nethermind StarkGate Security Review (Draft)

- Report: [irrelevant/2022_04-nethermind-starkgate-security-review-draft.md](<reports/irrelevant/2022_04-nethermind-starkgate-security-review-draft.md>)
- Auditor: Nethermind
- Date: 2022-04-05
- Description: Draft Nethermind review (NM-0050) of the StarkGate Alpha L1 Solidity bridges and L2 Cairo token bridge, ERC20 and governance contracts at commit 4031360 of the private starkware-libs/starkgate-contracts-internal repository; three Medium and two Low findings. Irrelevant because the entire scope lives in the private repository and none of the cited commits are served by any public repository.

### Nethermind NM-0064 StarkGate (Layer 1 and Layer 2) Security Review (Draft)

- Report: [irrelevant/2022_11-nethermind-starkgate-l1-l2-security-review-draft.md](<reports/irrelevant/2022_11-nethermind-starkgate-l1-l2-security-review-draft.md>)
- Auditor: Nethermind
- Date: 2022-11-10
- Description: Draft Nethermind review (NM-0064) of the StarkGate L1 Solidity bridges, proxy and governance contracts and the L2 Cairo token bridge, ERC20 and upgradability proxy at commit fd5ad0bd of the private starkware-libs/starkgate-contracts-internal repository; one High (fees not returned after message cancellation), one Medium and five Low findings, all unresolved at the time of the draft. Irrelevant because the entire scope lives in the private repository and the cited commit is not served by any public repository.

### Audit of Micro-Starknet

- Report: [irrelevant/2023_09-kudelski-micro-starknet-audit.md](<reports/irrelevant/2023_09-kudelski-micro-starknet-audit.md>)
- Auditor: Kudelski Security
- Date: 2023-09-04
- Description: Kudelski Security code audit, for StarkWare, of the Micro-Starknet TypeScript library (Stark curve keys and signatures, Pedersen and Poseidon hashing) at commit 07b25e9, with focus on hashing, randomness and constant-time behaviour. The library is an offchain JavaScript cryptographic dependency (used by starknet.js), not onchain protocol logic.
