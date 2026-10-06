# Linea Verifier Audit

Source: [https://www.openzeppelin.com/news/linea-verifier-audit-1](https://www.openzeppelin.com/news/linea-verifier-audit-1)

- November 3, 2023

OpenZeppelin Security

OpenZeppelin Security

Security Audits

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scope](#scope)
- [System Overview](#system-overview)
  - [Transpilation](#transpilation)
  - [PLONK Modification](#plonk-modification)
- [Security Model and Trust Assumptions](#security-model-and-trust-assumptions)
- [Critical Severity](#critical-severity)
  - [Incorrect Randomness Computation Allows Proof Forgery](#incorrect-randomness-computation-allows-proof-forgery)
- [Medium Severity](#medium-severity)
  - [Missing Commitment in Challenge Computation](#missing-commitment-in-challenge-computation)
  - [Deviations From So-Far-Digest Model](#deviations-from-so-far-digest-model)
  - [Missing Validations](#missing-validations)
- [Low Severity](#low-severity)
  - [Incomplete Specialization of Custom Gate Support](#incomplete-specialization-of-custom-gate-support)
  - [Inconsistent Error Handling](#inconsistent-error-handling)
  - [Inconsistent Memory Management](#inconsistent-memory-management)
  - [Misleading Documentation](#misleading-documentation)
  - [Missing Docstrings](#missing-docstrings)
  - [Implementation Deviates From Paper](#implementation-deviates-from-paper)
- [Notes & Additional Information](#notes-additional-information)
  - [Complicated Bit Manipulations](#complicated-bit-manipulations)
  - [Constants Not Using UPPER_CASE Format](#constants-not-using-upper_case-format)
  - [Magic Numbers](#magic-numbers)
  - [Naming Suggestions](#naming-suggestions)
  - [Outdated Specification](#outdated-specification)
  - [Potentially Unnecessary Computation](#potentially-unnecessary-computation)
  - [Reuse Cached Value](#reuse-cached-value)
  - [Typographical Errors](#typographical-errors)
- [Recommendations](#Recommendations)
- [Conclusion](#conclusion)

## Summary

Type
:   ZK Rollup

Timeline
:   From 2023-08-03
:   To 2023-08-18

Languages
:   Solidity

Total Issues
:   18 (11 resolved, 5 partially resolved)

Critical Severity Issues
:   1 (1 resolved)

High Severity Issues
:   0 (0 resolved)

Medium Severity Issues
:   3 (1 resolved, 2 partially resolved)

Low Severity Issues
:   6 (4 resolved, 1 partially resolved)

Notes & Additional Information
:   8 (5 resolved, 2 partially resolved)

## Scope

We audited the [Consensys/linea-contracts-fix](https://github.com/Consensys/linea-contracts-fix/tree/04d6677474421239c1f215c5a676223d09266ba4/) repository at the [04d6677](https://github.com/Consensys/linea-contracts-fix/tree/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers) commit.

```
 contracts
└── verifiers
    ├── PlonkVerifierFull.sol
    └── PlonkVerifierFullLarge.sol
```

## System Overview

The [Linea](https://docs.linea.build/overview) blockchain (L2) is a ZK-rollup on top of the Ethereum mainnet (L1). The L1 periodically receives the latest L2 state, along with a succinct proof that the state transition is the result of the execution of a known list of transactions. This is achieved using a variant of the [PLONK](https://eprint.iacr.org/2019/953.pdf) algorithm, and the code under review implements the verifier deployed to L1.

### Transpilation

The Solidity code is automatically generated from [gnark](https://github.com/ConsenSys/gnark/blob/develop/backend/plonk/bn254/verify.go#L43), a zk-SNARK Go library used to create circuits. This means that our recommended changes should actually be implemented in the source file or the transpiler. Nevertheless, for simplicity, this report describes the suggested effect on the outputted code.

One related architectural consideration is that the code makes extensive use of assembly for both low-level memory manipulation and high-level logic. Since the use of assembly discards many safety features provided by Solidity, it should usually be limited to small well-defined code blocks. This would make the code more robust, readable and extensible. However, this may not be practical without significantly modifying the transpiler. Instead, we recommend significantly increasing the test suite to ensure consistency with the specification and validate all expected behaviors.

### PLONK Modification

The verifier code includes a [custom gate](https://github.com/Consensys/plonk-solidity-audit#custom-gate), which is not part of the original PLONK specification. This is an optimization that allows the verifier to independently construct a hash using a subset of the circuit wires, and validate that these match a public input provided by the prover. Thus the circuit itself does not need to include a hash function, which is a costly operation. The Linea team has indicated that the underlying circuit implements the [Vortex protocol](https://eprint.iacr.org/2022/1633.pdf) and this hash is used as part of the Fiat-Shamir step.

## Security Model and Trust Assumptions

The verifier contracts are standalone systems with no inherent trust requirements. Anyone can use them to confirm that the supplied proof is valid for the configured circuit conditions. In practice, the particular verifiers under review should be configured to match a circuit encoding the Linea state transition function. They can then be used by the Linea L1 contracts to validate whether a proposed state root should be accepted.

However, the configuration is out of scope for the purposes of this audit. Each verifier contract contains a subset of the Structured Reference String, as well as cryptographic parameters and a verifying key that encodes the circuit. These are assumed to be specified safely and correctly. The circuit itself is also out of the scope of this audit and is assumed to function as specified.

## Critical Severity

### Incorrect Randomness Computation Allows Proof Forgery

The `PlonkVerifier` contract is called by the rollup to verify the validity proofs associated with blocks of transactions. The [`Verify`](https://github.com/Consensys/linea-contracts-fix/blob/dd24dc8acd7f9b58a56caaef68b8b5f4e247c59b/contracts/verifiers/PlonkVerifierFull.sol#L174) function can be called with the proof and the public inputs, and outputs a boolean indicating that the proof is valid for the received public inputs. To do so, the verifier notably [samples a random value](https://github.com/Consensys/linea-contracts-fix/blob/dd24dc8acd7f9b58a56caaef68b8b5f4e247c59b/contracts/verifiers/PlonkVerifierFull.sol#L714) `u` and does a batch evaluation to verify that all the openings match their respective commitments.

However, `u` is not sampled randomly (or in practice as the hash of the full transcript), resulting in the possibility of forged proofs passing the verification. More specifically, `u` does not depend on `[Wζ]1` and `[Wζω]1`, meaning that it is possible for a malicious prover to change `[Wζ]1` and `[Wζω]1` after seeing the value of `u`. Here is an example of an attack based on this observation:

1. The malicious prover `P` extracts `A = [Wζ]1 + u*[Wζω]1` and `B = z*[Wζ]1 + uζω*[Wζω]1 + [F]1 - [E]1` obtained when any valid proof is submitted. `A` and `B` are by construction points on the elliptic curve for which `e(-A, [x]2) * e(B, [1]2) == 1`.
2. `P` sets the public input (or any proof commitment) to an arbitrary value. Any value beside `t(ζ)`, `[Wζ]1` and `[Wζω]1` can be changed.
3. `P` computes `T = [ r(ζ) + PI(ζ) − ((a(ζ) + βsσ1(ζ) + γ)(b(ζ) + βsσ2(ζ) + γ)(c(ζ) + γ)zω(ζ))α − L1(ζ)α^2 ] / ZH(ζ)` following step 8 of the [PLONK verifier algorithm](https://eprint.iacr.org/archive/2019/953/1623868682.pdf). The prover sets `t(ζ) = T` in the forged proof. This step is required to pass this [check](https://github.com/Consensys/linea-contracts-fix/blob/dd24dc8acd7f9b58a56caaef68b8b5f4e247c59b/contracts/verifiers/PlonkVerifierFull.sol#L1087) in the code.
4. `P` computes `u`, `ζ` and `ω` as done by the code.
5. `P` solves the equations `X + u*Y = A` and `ζ*X + ζωu*Y = C + B` obtained by denoting `X = [Wζ]1` and `Y = [Wζω]1` taken from step 12 of the verifier algorithm. This system has for solutions `[Wζ]1 = X = (-u)*Y + A` and `[Wζω]1 = Y = 1/(ζu(ω - 1)) * (C + B -ζA)`.
6. `P` submits the proof to the verifier, replacing `t(ζ)` by `T`, and `[Wζ]1`, `[Wζω]1` by the values computed in step 5.
7. The verifier computes `e(-A, [x]2) * e(B, [1]2) == 1` and accepts the proof.

The core of the attack is the ability of the prover to change `[Wζ]1` and `[Wζω]1` after `u` has been sampled. This attack allows the prover to arbitrarily change the public inputs or any polynomial commitments and still submit a valid proof. In the case of Linea, this could be used by the prover to [modify the state root](https://github.com/Consensys/linea-contracts-fix/blob/dd24dc8acd7f9b58a56caaef68b8b5f4e247c59b/contracts/ZkEvmV2.sol#L239) and steal all the assets on the rollup.

Consider computing `u` as the hash of the transcript following the PLONK paper.

***Update:** Resolved in [pull request #30](https://github.com/Consensys/linea-contracts-fix/pull/30).*

## Medium Severity

### Missing Commitment in Challenge Computation

When following the non-interactive version of [PLONK](https://eprint.iacr.org/2019/953.pdf) using Fiat-Shamir, the challenges are assumed to be derived from the transcript, defined as "the concatenation of the common preprocessed input, and public input, and the proof elements written by the prover up to a certain point in time". In the code, the following parameters are used to [compute](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L345) the `γ` and `β` challenges:

- The public inputs
- The commitments to the wire polynomials (`[a]1`, `[b]1`, `[c]1`, `[Pi]1`)
- The commitments to the selector polynomials (`[Sσ1]1`, `[Sσ2]1`, `[Sσ3]1`, `[Ql]1`, `[Qr]1`, `[Qm]1`, `[Qo]1`, `[Qk]1`)

However, the commitments to the selector polynomials corresponding to the custom gate `[Qci]1` are missing when deriving these challenges. While they are eventually [included](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L884C9-L885C85) in the derivation of the `v` challenge, other challenges (namely `γ`, `β`, `α`, `ζ` and `u`) do not depend on them.

Since they [are hardcoded](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L62-L65) anyway, they cannot be used as a free parameter in [frozen-heart](https://blog.trailofbits.com/2022/04/13/part-1-coordinated-disclosure-of-vulnerabilities-affecting-girault-bulletproofs-and-plonk/)-style attacks. Nevertheless, this means the system is out of compliance with the security analysis, which undermines the security guarantees.

Consider including all relevant parameters when deriving these challenges. In particular, consider adding the `[Qci]1` commitments, the group parameters (generators, at least `[1]1`, `[x]1` and `[1]2`, modulus and domain size), as well as the number of public inputs and the circuit size. Similarly, the Fiat-Shamir done inside of the circuit should also include all relevant parameters.

***Update:** Resolved in [pull request #25](https://github.com/Consensys/linea-contracts-fix/pull/25). The Linea team stated:*

> *The modifications are that now gamma depends on the Qcp (instead of the commitments to the wires associated with it). Beta is unchanged, and alpha depends on the commitments to the wires associated with the custom gate (it is at this point that the verifier should have sent alpha if the protocol were interactive).*

### Deviations From So-Far-Digest Model

We are aware of only two provably secure transformations of a constant round argument of knowledge from its interactive to its non-interactive version. Those transformations are, in the terms used in [this article](https://eprint.iacr.org/2022/1072.pdf), the so-far-transcript (i.e., the Fiat-Shamir transformation in its classical form) and the so-far-digest transformations.

The PLONK specification chooses pseudorandom challenges using the so-far-transcript method, where each challenge is generated from the content of the entire transcript so far. The Linea verifier uses the newly introduced so-far-digest method, where each challenge is generated only from the previous challenge and subsequent messages. However, there are several deviations:

- [`compute_gamma_kzg`](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L867), corresponding to `v` in the PLONK specification, should strictly follow the so-far-digest transformation. In particular, it should depend on `ζ` and all the PLONK prover messages that are output in round 4 (i.e., the respective opening evaluations). Currently, it has several redundant dependencies but does not depend on `z(ζω)`.
- The [`random` variable used in the KZG opening](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L714), corresponding to `u` in the PLONK specification, should also be computed as any challenge defined by the so-far-digest model. In particular, it should depend on challenge `v` (not `α`) and on the two KZG commitments that are output by the PLONK prover in round 5. Moreover, the use of `keccak256` for computing this challenge should be substituted by the same hash-to-field function as in the rest of the so-far-digest model.

Note that the definition of a challenge in the so-far-transcript and so-far-digest models is that of randomness computed by a non-interactive prover/verifier in lieu of the public coin randomness computed by an interactive verifier, so `u` in the PLONK specification is also a challenge.

- `ζ` [depends](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L183) on the non-reduced version of `α`, but in accordance with the so-far-digest transformation we recommend making the dependency directly on `α`. The same holds for almost all other challenges.

In summary, in order to fall under the security guarantees of one of the two existing interactive to non-interactive secure transformations for argument systems, once started, it is strongly recommended to strictly follow the so-far-digest transformation without interleaving it with any other possible transformation. Avoiding compliance may lead to transformations without currently explored security proofs and may put the codebase at risk of attacks on the system's soundness.

Finally, note that we are in contact with the authors of [this paper](https://eprint.iacr.org/2022/1072.pdf) with comments and feedback regarding the security proof of the so-far-digest transformation.

***Update:** Partially resolved in [pull request #30](https://github.com/Consensys/linea-contracts-fix/pull/30), except for `ζ` which still depends on the non-reduced version of `α`. The issue regarding the computation of `random` in the second point was spun off as a separate issue during the fix review as the vulnerability was found to be more serious than initially thought.*

### Missing Validations

The `Verify` function [performs sanity checks](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L174-L176) on the inputs, but there are still some validations missing. In particular, it does not confirm the number of public inputs, or whether the commitments correspond to valid elliptic curve points.

In the interest of reducing the attack surface, consider including these validations. Note that checking that the commitments are valid elliptic curve points is a requirement of the PLONK specification in order to inherit the security proof.

***Update:** Partially resolved in [pull request #26](https://github.com/Consensys/linea-contracts-fix/pull/26). A check to explicitly restrict the number of public inputs was added. Regarding the elliptic curve checks, the Linea team stated:*

> *It is implicitly tested when the EC precompiles are called - if a point is not on the curve, the precompile will revert. This avoids doing checks each time we verify a proof (there are a lot of points to verify), and the proofs that are received are likely to be correctly formatted so we believe the trade-off is better as it is now.*

## Low Severity

### Incomplete Specialization of Custom Gate Support

The codebase is designed to support an [arbitrary number of selector gates](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L115-L116) that are nevertheless [fixed at compile time](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L69).

However, the [`sum_pi_commit` function](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L542) is specialized for the current configuration of one selector gate, which is inconsistent with the rest of the codebase. Moreover, the specialization is incomplete. In particular:

- It [only hashes the first commitment](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L552) and ignores any subsequent commitments.
- It unnecessarily [adds the result to an unspecified value](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L554).
- It unnecessarily [increases a pointer](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L555) that is never reused.
- It is still named `sum` even though it does not return a summation.

Similarly, the `compute_gamma_kzg` function [assumes there is only one](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L884-L885) custom gate, but then [allows for multiple](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L898-L906) corresponding openings.

Consider generalizing the functions to support multiple selector gates. Alternatively, consider explicitly enforcing the single gate requirement and simplifying the functions accordingly.

***Update:** Resolved in [pull request #27](https://github.com/Consensys/linea-contracts-fix/pull/27).*

### Inconsistent Error Handling

The [`pow`](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L1216), [`compute_gamma_kzg`](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L919) and [batch_verify_multi_points](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L737) functions all use the `eq` instruction to check the error flag. To be consistent with the rest of the codebase, consider using the `iszero` instruction instead.

In addition, the [final KZG check](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L788) combines protocol logic and error handling. In particular, it validates the previously saved (quotient polynomial evaluation) status, the success of the precompile call, and the result of the pairing. To be consistent with the rest of the codebase, consider checking the precompile success flag independently and immediately after the call is made.

***Update:** Partially resolved in [pull request #17](https://github.com/Consensys/linea-contracts-fix/pull/17). The `check_pairing_kzg` function still checks the precompile call success flag in the returned boolean instead of raising an error.*

### Inconsistent Memory Management

The codebase adopts a convention where [the memory at the free memory pointer](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L170) is reserved for a [shared state](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L121-L152), and the [subsequent block of memory](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L171) is considered free. When a function wants to reserve additional memory, it explicitly passes a new free memory pointer (e.g., [here](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L720)) to the called function.

However, this violates Solidity's memory model, where reserved memory is "allocated" by updating the free memory pointer. Moreover, the `fold_state` function [directly uses](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L806) a buffer that was constructed in the `compute_gamma_kzg` function, even though it appears to be in "free" memory under both conventions.

To improve readability and limit potential inconsistencies, consider allocating memory whenever it is reserved. Additionally, consider explicitly documenting that the code is not [memory-safe](https://docs.soliditylang.org/en/v0.8.19/assembly.html#memory-safety).

***Update:** Resolved in [pull request #20](https://github.com/Consensys/linea-contracts-fix/pull/20).*

### Misleading Documentation

There are several instances where the codebase's documentation could be improved:

- [This comment](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L1070) references the Lagrange polynomial at index 1 instead of index 0.
- The explanation for the ["beta"](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L406) and ["alpha"](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L423) string offsets incorrectly references "gamma". Note that the "beta" comment also has the wrong offset.
- The polynomial openings are [described](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L89) as "wire values at zeta". It would be more accurate to describe them as "evaluations of wire polynomials at zeta".
- The [b0](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L615) and [b0 ^ b1](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L638) comments incorrectly describe them as occupying 64 bytes.
- The [comment](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L1054) describing the `fold_h` function uses `m` instead of `n` as the group size.
- The `verify_quotient_poly_eval_at_zeta` function contains a [commented-out instruction](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L1086) that does not match the rest of the code.
- [This comment](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L665) uses "mPtr[32:]" instead of "mPtr[:32]".
- [This comment](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L663) is unclear and incorrectly suggests that "b2" is 16 bytes.
- Some comments could use additional context. For example, [this comment](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L1067C3-L1071C20) could indicate which step in the paper it corresponds to (step 8) and what it is computing (the `t(z)` expression).

Consider updating these comments to improve the clarity of the codebase.

***Update:** Resolved in [pull request #16](https://github.com/Consensys/linea-contracts-fix/pull/16).*

### Missing Docstrings

The [code under review](https://github.com/Consensys/linea-contracts-fix/tree/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers) contains several functions with minimal or missing docstrings, which limits readability. This is compounded by the fact that many functions intermingle protocol logic with low-level memory manipulation in assembly.

Consider thoroughly documenting all functions (and their parameters). When writing docstrings, consider following the [Ethereum Natural Specification Format](https://docs.soliditylang.org/en/develop/natspec-format.html) (NatSpec).

***Update:** Resolved in [pull request #18](https://github.com/Consensys/linea-contracts-fix/pull/18).*

### Implementation Deviates From Paper

Some operations are done differently in the code compared to what is described in the [paper](https://eprint.iacr.org/archive/2019/953/1585767119.pdf):

- The permutation polynomial is [defined using the Lagrange polynomial at index 0](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L1045), which means the interpolation starts at the previous position when compared to the specification.
- Some signs have been inverted, for example when [evaluating the quotient polynomial](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L1105C35-L1105C66).
- Some computations are done differently, such as when [computing the partial opening commitment](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L1008) `[D]1`, where the multiplication by `v` and the addition of `u[z]1` are done later.
- The components of the quotient polynomial [are scaled by `ζ^{n+2}`](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L1056) instead of `ζ^{n}`.

Consider closely following the paper's implementation to reduce the likelihood of mistakes and improve the clarity of the codebase. When this is not feasible, consider clearly documenting the differences between the paper and the codebase.

***Update:** Acknowledged, not resolved. The first point was found to stem from the code implementing an older version of PLONK than the audit team was looking at, which in itself is not a security concern. The Linea team expressed that the other points were not resolved as, while the code differs from the specifications, it is consistent.*

## Notes & Additional Information

### Complicated Bit Manipulations

The [penultimate step](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L667-L677) of the `hash_fr` function is to retrieve the most significant 16 bytes of the 32-byte word `b2`. This is achieved by zeroing out the previous 16 bytes one at a time, and then reading 32 bytes across the natural word boundary. Instead, the same effect can be achieved directly through right-shifting `b2` by 128-bit positions. Consider implementing this simplification.

***Update:** Resolved in [pull request #29](https://github.com/Consensys/linea-contracts-fix/pull/29).*

### Constants Not Using UPPER_CASE Format

Throughout the codebase, [constants](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L22C3-L166C34) are not using the `UPPER_CASE` format. Consider following this convention as recommended by the [Solidity Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html#constants).

***Update:** Resolved in [pull request #24](https://github.com/Consensys/linea-contracts-fix/pull/24).*

### Magic Numbers

The `batch_verify_multi_points` function [hardcodes the group 1 generator](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L730-L734) with no explanation. To improve readability, consider introducing named constants to describe this value.

Similarly, consider replacing the [hardcoded proof size offset](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L272) with the [positional constant](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L114) that it represents.

Lastly, the [size of the `ecPairing` buffer](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L785) is assumed to be `0x180`, which is not apparent through contextual analysis, because the buffer is constructed in the calling function. Consider passing the length to the `check_pairing_kzg` function.

***Update:** Partially resolved in [pull request #23](https://github.com/Consensys/linea-contracts-fix/pull/23). Constants for the group 1 generator were introduced, but the proof size offset and the size of the elliptic curve pairing buffer are still hardcoded.*

### Naming Suggestions

The following variables and constants could benefit from more descriptive names:

- The [`n` parameter](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L481) of the `batch_compute_lagranges_at_z` function is the number of public inputs, which [conflicts](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L477C15-L477C15) with the domain size.
- The [`h` commitments](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L82-L87) should include `com` or `commitment` in their name to be consistent with the other constants.
- There are several variables that could remove the "api" decorator, which is a reference to how they were constructed rather than what they represent.

Consider renaming these values accordingly.

***Update:** Resolved in [pull request #22](https://github.com/Consensys/linea-contracts-fix/pull/22).*

### Outdated Specification

The verifier implements an [outdated version](https://eprint.iacr.org/archive/2019/953/1585767119.pdf) of the PLONK specification. If possible, consider implementing the [latest version](https://eprint.iacr.org/2019/953.pdf), which requires a smaller proof.

***Update:** Acknowledged, not resolved. The Linea team stated:*

> *There is a release of Linea coming soon, we will potentially update our PLONK prover and verifier afterwards.*

### Potentially Unnecessary Computation

There are multiple places where the verifier continues processing once the outcome is known:

- Several functions [are called](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L198-L202) after the `verify_quotient_poly_eval_at_zeta` function [saves its result](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L1119), regardless of the outcome, even though [a failure will always eventually revert](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L787).
- The [`check_inputs_size`](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L263) and [`check_proof_openings_size`](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L278) functions construct a combined error flag for each input, even though any failure ultimately results in a revert.

In the interest of code simplicity and limiting unnecessary computation, consider reverting as soon as a failure is detected.

***Update:** Partially resolved in [pull request #28](https://github.com/Consensys/linea-contracts-fix/pull/28). An early revert was added when validating the inputs and opening. The Linea team stated:*

> *For `verify_quotient_poly_eval_at_zeta`, we left the old version so that the verifier executes fully and returns either true or false according to the success.*

### Reuse Cached Value

Several functions in the [`fold_state`](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L796) function recompute the pointer to free memory, such as [here](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L822C88-L822C105). Consider reusing the [`mPtrOffset` variable](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L804).

***Update:** Resolved in [pull request #20](https://github.com/Consensys/linea-contracts-fix/pull/20).*

### Typographical Errors

The following typographical errors were identified in the codebase:

- ["comming"](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L451) should be "coming".
- ["32byes"](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L663C68-L663C74) should be "32 bytes".
- ["in"](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L663C82-L663C84) should be "is".
- ["too"](https://github.com/Consensys/linea-contracts-fix/blob/04d6677474421239c1f215c5a676223d09266ba4/contracts/verifiers/PlonkVerifierFull.sol#L778C60-L778C63) should be "to".

Consider resolving these typographical errors, as well as running an automated spelling/grammar checker on the codebase and correcting any identified errors.

***Update:** Resolved in [pull request #21](https://github.com/Consensys/linea-contracts-fix/pull/21).*

## Recommendations

Supplementary Materials

We recommend reading the following supplementary materials related to some theoretical  
security considerations in PLONK.

SRS and Transcript in Practice

As part of the Fiat-Shamir (FS) transformation from the interactive to the non-interactive version  
of a protocol, the full transcript should include all public parameters. In a S(N)ARK, the set of  
public parameters includes the structured reference string (i.e., the SRS).

In the following, we explain why it is necessary and sufficient to include just a small part of the  
SRS in the full transcript for the FS transformation.

Let O(n) be the size of the SNARK witness.

On the one hand, it is not feasible to include the full SRS as part of the full transcript to be later  
hashed as this would constitute a computational cost of up to O(n) for both the non-interactive  
prover as well as the non-interactive verifier. Indeed, O(n) largely outweighs the upper bound of  
O(log n) as the desired computational cost for a non-interactive SNARK verifier.  
On the other hand, one certainly needs to add at least some SRS points as part of the full  
transcript. We recommend adding [1]1, [x]1 and [1]2. Given these three elements, there exists a  
deterministic procedure that verifies the well-formedness of any other SRS element due to the  
bilinearity of the pairing. Moreover, this verification is valid only if the SRS elements match [1]1, [x]1  
and [1]2. For short, the SRS elements are uniquely determined by fixing only 3 elements: [1]1, [x]1 and [1]2. The mathematical motivation is included below.  
  
Step 1: Given [1]1, [x]1, [1]2, one can check that a value y is indeed equal to [x]2 by checking the pairing equality e([x]1, [1]2) = e([1]1, y). This equality holds if and only if y = [x]2.  
  
Step 2 and onwards: given [1]2, [x]2 and a previously verified [xi-1]1, we want to check that a value y is indeed equal to [xi]1 for i>1. This can be done by checking the pairing equality e(y, [1]2) = e([xi-1]1, [x]2) which (due to the non-degeneracy of the pairing) holds if and only if y =[xi]1.

**Observation 1:** In order to prove that e([x]1, [1]2) = e([1]1, y) holds if and only if y = [x]2, the harder part is the direction e([x]1, [1]2) = e([1]1, y) (*) implies y = [x]2. Assuming (*), we also know that e([x]1, [1]2) =e([1]1, [x]2) (**) holds. Dividing the two equations (*) and (**), we obtain: e([1]1, y- [x]2) = 1. In turn, by the definition of a pairing (the non-degeneracy condition, see [Pairing-Based Cryptography](https://en.wikipedia.org/wiki/Pairing-based_cryptography)), this holds if and only if y= [x]2.  
  
Observation 2: Analogously to Observation 1, one can use the non-degeneracy of the pairing  
to motivate the reasoning in Step 2 and onwards.

**Observation 3:** Analogously to **Step 2 and onwards**, we have Step 2' and onwards: given [1]1, [x]1 and a previously verified [xi-1]2, we now want to check that a value y is indeed equal to [xi]2 for i>1. This can be done by checking the pairing equality e([1]1, y) = e([x]1,[xi-1]2) which, with analogous reasoning as described in previous observations, holds if and only if y = [xi]2.  
  
In conclusion, using only [1]1, [x]1 and [1]2, one can check if any other element of a PLONK SRS is well-formatted. Hence, we have explained why including only [1]1, [x]1 and [1]2 in the full transcript is both necessary and sufficient.

**Batching KZG Proofs for Two Evaluation Points**

These sections address the missing security proof on page 13 of the PLONK paper, and how to  
implement the required randomness in practice.

**Section 1: Security Proof**

***Lemma 1:*** Let a, a', b, b' ∈ F be some given, fixed scalars, where F⊂ O(2λ) is a finite field and  
λ is the security parameter. Let r' ∈ F be a scalar chosen uniformly at random in F and, thus,  
independently chosen from a, a', b, b'.

Then, it holds that a = a' and b= b' if and only if, up to a negligible probability in λ, a+ r'·b = a'+  
r'·b'.

*Proof:*

• "=>": The implication from left to right holds trivially and with a probability of 1.

•"<=": For the implication from right to left, assume a+ r'·b = a'+ r'·b' holds. Then,  
equivalently, (a - a')+ r'·(b' - b) = 0. For a, a', b, b' ∈ F fixed and r' chosen uniformly at  
random in F, by applying the [Schwartz-Zippel Lemma](https://en.wikipedia.org/wiki/Schwartz%E2%80%93Zippel_lemma), this implies, with overwhelming  
probability in λ that a = a' and b = b'. This concludes the proof.

***Instantiation 1:*** Next, we apply Lemma 1 for the special case of the scheme describing  
batching KZG proofs for two evaluation points (page 13 in [PLONK](https://eprint.iacr.org/2019/953.pdf)). In order to do that, we  
instantiate:

- a = e(F + zW, [1]1), where F = ∑i=1t1 γi-1·cmi - [ ∑i=1t1 γi-1·si]1 and using the [PLONK paper](https://eprint.iacr.org/2019/953.pdf) (pages 11-13) notation for γ, cmi, si, t1.
- b = e(W, [x]2).
- a' = e(F' + z'W', [1]1), where F' = ∑i=1t2 γ'i-1· cmi' - [ ∑i=1t2 γ'i-1· s'i]1.
- b' = e(W', [x]2).

Hence, we can conclude that given the security proof for the KZG scheme for one evaluation  
point (i.e., the KZG scheme described in Section 3.1, pages 11-12 of [PLONK](https://eprint.iacr.org/2019/953.pdf)), and using  
Instantiation 1, the security of the KZG scheme described on page 13 of PLONK holds.  
  
Note that in order to conclude the above security proof, we made explicit use of the [Schwartz-](https://en.wikipedia.org/wiki/Schwartz%E2%80%93Zippel_lemma)  
[Zippel Lemma](https://en.wikipedia.org/wiki/Schwartz%E2%80%93Zippel_lemma) used in the proof of Lemma 1. If not all pre-conditions are met, such as if either the degree of the polynomial considered is not negligible over the size of the field F, or if any of  
the coefficients of the polynomial for which we apply the [Schwartz-Zippel Lemma](https://en.wikipedia.org/wiki/Schwartz%E2%80%93Zippel_lemma) are chosen  
after r' is chosen, then the security proof may no longer hold.

Section 2: Concrete Implementation Details

To protect itself from a malicious KZG prover, a KZG verifier has two options.

- In an ideal world, the verifier would choose r' uniformly at random from F. However, that  
  is not efficient to implement in practice.
- In practice and in support of an efficient implementation, the KZG verifier simply needs  
  to compute the value r' as the hash of the entire transcript and all the public values used  
  in the KZG scheme up to that point. This is equivalent to the Fiat-Shamir transformation  
  for a multi-round protocol, with the last round in this case being the computation by the  
  verifier of some publicly used randomness and the final KZG paring check. From a  
  theoretical perspective, this is secure in the random oracle model.

Note that when extrapolated to PLONK, for example, everything we have seen above points to  
the fact that a PLONK verifier, in step 12 of the protocol, should compute the challenge u as the hash of the entire transcript of the interaction so far. Only then does one fall under the coverage of a known security proof.  
  
**Open Questions and Remarks Regarding the Security Proof of the So-Far Digest**  
**Model**  
  
Non-interactivity is a desirable and sometimes necessary property of blockchain protocols. In a  
non-interactive protocol, each party completes its part only via local computation and the  
outcome of that computation is eventually made public. Thus, there is only one round of  
communication from each party towards all the others. Certain secure and interactive  
cryptographic protocols (e.g., public-coin protocols with a constant number of communication  
rounds) can be converted into non-interactive protocols while preserving their security  
properties via the Fiat-Shamir transformation. Essentially, the public coin (i.e., challenges) in the  
non-interactive version can be computed by any party as the hash of the entire transcript of the  
communication up to that point. The transcript includes all the public inputs and public  
parameters necessary during the interaction, as mentioned before.

We noticed that the Linea verifiers' implementations do not use the standard Fiat-Shamir  
transformation. We have traced the actual transformation used to [this recent article](https://eprint.iacr.org/archive/2022/1072/1669800347.pdf), where it is  
detailed in the 9-th section of the appendix i.e., Appendix I. The article introduces a more  
efficient alternative for computing the Fiat-Shamir challenges. The authors call it the so-far  
digest model. We have revised the proposed security proof (i.e., proof of Theorem 4, Appendix  
I) in detail for this model and have some comments, suggestions and questions about it. We  
have previously attempted to ask the authors directly and have not received an answer, but we  
believe it would be valuable to have them addressed.

1. With respect to attacker B, how is the starting value h0 defined and how are the values h1, h2, ..., defined?
2. Do you implicitly assume/restrict the attacker B to only submit values in the set {(m1  
   , h0),(m2, h1), (m3, h2), ...} as RO-queries to their respective oracles? If yes, does your security proof work without this assumption?
3. If we think about the classical Fiat-Shamir transformation and how the first challenge is  
   obtained, namely as the hash of all the public inputs (without including any message  
   from the prover or any challenge so far as there is none yet), how is this modelled for B?  
   Can the security proof of *Theorem 4* work in all its generality without taking this point into  
   account?
4. Regarding the sentence "**Bad Event**. is when B sends a RO-query on (m, h) to HFS, for  
   m that has not been the response for any round [...]", do you actually mean "any round  
   so far", since you also write "later during the i-th round it sends mi= m as its message"?
5. Is it implicitly true that every h used by B (including but not limited to h0, h1, h2, ...) is the  
   output of a RO-query, and hence is uniformly distributed? Is this why h=hi for some round i holds with negligible probability for the right definition of RO using the security parameter?
6. Is it possible that you are missing some steps or some description, either in the definition  
   of B or in the use of B by A? Otherwise, why would it be conflicting with the simulation  
   that the pair (m,h) is sent twice to the RO-query?
7. The output of B doesn't seem to be explicitly defined. Is it an alleged proof? When does  
   B win (is it when the output proof is an accepted proof)? Does the same hold for A?

## Conclusion

Three medium-severity issues were discovered among various lower-severity issues. While reviewing the fixes for these, one of the issues previously identified as a medium was found to be exploitable in practice by allowing proof forgery and was updated to a critical severity. Since the verifier is a complex but critical part of the rollup architecture, it was also recommended to add more extensive documentation to the codebase, notably with regard to the differences between the implementation and the original PLONK specification. We wish to extend our gratitude to the Linea team for their quick and helpful answers to our questions.
