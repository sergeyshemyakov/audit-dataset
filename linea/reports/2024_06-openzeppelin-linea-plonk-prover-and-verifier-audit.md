# Linea Plonk Prover (Backend) and Plonk Verifier Audit

Source: [https://www.openzeppelin.com/news/linea-prover-audit](https://www.openzeppelin.com/news/linea-prover-audit)

- June 14, 2024

OpenZeppelin Security

OpenZeppelin Security

Security Audits

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scope](#scope)
- [System Overview](#system-overview)
- [Security Model and Trust Assumptions](#security-model-and-trust-assumptions)
- [High Severity](#high-severity)
  - [The Quotient Polynomial Shards Are Not Individually Blinded](#the-quotient-polynomial-shards-are-not-individually-blinded)
- [Medium Severity](#medium-severity)
  - [Inconsistent BSB22 Polynomial Blinding](#inconsistent-bsb22-polynomial-blinding)
  - [Incorrect UnmarshalSolidity Function](#incorrect-unmarshalsolidity-function)
  - [Inconsistent Plonk Implementation](#inconsistent-plonk-implementation)
  - [Missing Proof Validation](#missing-proof-validation)
- [Low Severity](#low-severity)
  - [Imprecise Domain Size](#imprecise-domain-size)
  - [Off-by-One Indexing Error in Unmarshal Logic](#off-by-one-indexing-error-in-unmarshal-logic)
  - [Implicit Modification of the Blinded Z Polynomial Inside innerComputeLinearizedPoly](#implicit-modification-of-the-blinded-z-polynomial-inside-innercomputelinearizedpoly)
  - [Naming Suggestions](#naming-suggestions)
  - [Missing Error Check](#missing-error-check)
  - [Misleading or Erroneous Documentation](#misleading-or-erroneous-documentation)
  - [Code Simplifications](#code-simplifications)
  - [Verifier Regressions](#verifier-regressions)
- [Notes & Additional Information](#notes-additional-information)
  - [Imprecise Calculation for Number of Gates](#imprecise-calculation-for-number-of-gates)
  - [Presence of Magic Numbers](#presence-of-magic-numbers)
  - [Unused Variable in Solidity Verifier](#unused-variable-in-solidity-verifier)
  - [Use Templating Mechanism for all Buffer Offsets in the Solidity Verifier](#use-templating-mechanism-for-all-buffer-offsets-in-the-solidity-verifier)
  - [Typographical Errors](#typographical-errors)
- [Conclusion](#conclusion)

## Summary

Type
:   Proof System

Timeline
:   From 2024-05-20
:   To 2024-06-14

Languages
:   Go, Solidity

Total Issues
:   18 (9 resolved, 6 partially resolved)

Critical Severity Issues
:   0 (0 resolved)

High Severity Issues
:   1 (1 resolved)

Medium Severity Issues
:   4 (1 resolved, 1 partially resolved)

Low Severity Issues
:   8 (4 resolved, 3 partially resolved)

Notes & Additional Information
:   5 (3 resolved, 2 partially resolved)

## Scope

We audited the [Consensys/gnark](https://github.com/Consensys/gnark) repository at commit [e204083](https://github.com/Consensys/gnark/tree/e2040836eb41a40df04a4a3648764b07a0fa12a2). All the resolutions mentioned in this report are contained at commit [065027a](https://github.com/Consensys/gnark/commit/065027ac0cc36e17a541071dc6c57e87faf0baf7), making it the final version reviewed during this audit.

In scope were the following files:

```
 backend/plonk├── bn254│   ├── marshal.go│   ├── prove.go│   ├── setup.go│   ├── unmarshal.go│   └── verify.go└── plonk.go
```

We also audited the changes made to `backend/plonk/bn254/solidity.go` between commits [3421eaa](https://github.com/Consensys/gnark/tree/3421eaa7d544286abf3de8c46282b8d4da6d5da0) and [e204083](https://github.com/Consensys/gnark/tree/e2040836eb41a40df04a4a3648764b07a0fa12a2).

The in-scope files heavily rely on the proper implementation of functions and structs across a number of out-of-scope files. As such, we also reviewed parts of the out-of-scope files with regards to their interactions to ensure correctness. However, our review of these files should not be considered an audit. For an inexhaustive list of additional files refer to the **Appendix I - Out of Scope Files**.

## System Overview

The Linea system and its modifications to the Plonk algorithm have been described in [a previous audit report](https://blog.openzeppelin.com/linea-verifier-audit-1). While that audit focused on the Solidity verifier, this one reviewed the corresponding Go prover (and the associated Go verifier). The expected use case is to support the Linea rollup, but it is a standalone library that can be used for other Plonk circuits, which may also include the custom gate.

We also reviewed the changes required to upgrade from a [previous version](https://eprint.iacr.org/archive/2019/953/1585767119.pdf) of the Plonk specification to the [current one](https://eprint.iacr.org/2019/953.pdf), as well as some encoding/decoding mechanisms to coordinate between the two codebases.

## Security Model and Trust Assumptions

The provers and verifiers are standalone systems with no inherent trust requirements. Anyone can use them to construct and verify Plonk proofs for any circuit. As noted in our previous report, in practice, they should be configured to match a circuit encoding the Linea state transition function. We did not review the circuit construction and its relationship with Linea's particular use case. Moreover, the codebase assumes the existence of a Structured Reference String, which we assume was specified safely and correctly. Lastly, the Plonk prover codebase relies on an external cryptographic library to obtain random numbers. We assume these are generated and handled securely.

## High Severity

### The Quotient Polynomial Shards Are Not Individually Blinded

After [constructing the shards](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L612-L625) of the quotient polynomial h(X) their KZG commitments are [added to the proof](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L538) without blinding, as required by the [latest Plonk specification](https://eprint.iacr.org/2019/953.pdf). As noted by [Sefranek](https://eprint.iacr.org/2024/848.pdf), this means they do not provide the statistical zero-knowledge property.

Consider blinding the individual shards in the proof.

***Update:** Resolved in [pull request #14](https://github.com/ThomasPiellard/gnark-oz/pull/14).*

*The issue was fixed by applying the blinding of the `h` shards (`h1,h2,h3`) according to the latest version of the PLONK paper (February 23, 2024). In addition, a global `StatisticalZK` option was introduced which, when turned off, switches back to the previous version of the code (i.e., the one that does not blind the shards).*

*This is desirable since the new blinding increases the memory consumption of the prover due to the necessity to reserve three additional arrays of size `n` (where `n` is the size of the circuit) to store the three blinded polynomials. Previously, they were just sliced from the (already allocated) `h` polynomial.*

*Some recommendations to further improve the fix:*

- *Make the `StatisticalZK` switch to control all blindings (i.e., also of the `a,b,c,z` polynomials) and not just of the `t` shards. This will further ease the memory requirements on the prover when blinding is not desirable and will also simplify the implementation and improve consistency.*
- *Make the `h3` polynomial the same size as the `h1,h2` shards by setting its top coefficients to zero. This will remove the conditional logic in the `innerComputeLinearizedPoly` function (which is a bit unnatural, anyway), since all the `hx[i]` values will be valid, and will improve code readability.*

*The Linea team stated:*

> *We made it an option to achieve zero knowledge-ness (see `backend.WithStatisticalZeroKnowledge()`) because it uses more memory. In cases where it is not needed, it is better to avoid it.*

## Medium Severity

### Inconsistent BSB22 Polynomial Blinding

In order to blind the BSB22 preimage polynomials, they are constructed with [random evaluations in two positions](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L298-L303). These positions are carefully chosen so that the evaluations are unused. In particular:

- The first one corresponds to the "hash injection" constraint, where the final challenge is introduced into the circuit as a public input. This guarantees that the corresponding *Q*cpj​​ selector position will be zero and so the random evaluation will be ignored.
- The second one is simply the last constraint in the whole system. Since the circuit builder always constructs the "preimage collection" constraints before the "hash injection" constraints, the last constraint cannot be a "preimage collection" constraint and the corresponding *Q*cpj​​ selector position will also be zero.

However, if the BSB22 gate is the last gate added to the circuit, both of these will correspond to the same position. This means that the corresponding preimage polynomial will only be blinded in one position instead of two.

We believe that one position is sufficient to maintain zero knowledge in this case. Nevertheless, in the interest of predictability and consistency, consider ensuring that all BSB22 preimage polynomials are blinded twice. This could involve choosing a different (unused) evaluation position or ensuring that the last constraint does not match a BSB22 gate.

***Update:** Acknowledged, not resolved. The Linea team stated:*

> *For the moment, the polynomials are blinded in at least one spot no matter what. This should be enough (even if one in every case is enough).*

### Incorrect `UnmarshalSolidity` Function

The [`MarshalSolidity`](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L1339) and [`UnmarshalSolidity`](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/unmarshal.go#L8) functions are intended to encode and decode a Go [`Proof` object](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L91) so that it can be passed to a Solidity verifier contract. However, the `MarshalSolidity` function [skips the opening of the linearized polynomial](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L1386) while the `UnmarshalSolidity` function [does not](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/unmarshal.go#L60). This means that the rest of the function will decode values into the wrong variables and will attempt to read past the end of the input.

Consider removing the linearized polynomial from the `UnmarshalSolidity` function so that it behaves as expected.

***Update:** Resolved in [pull request #10](https://github.com/ThomasPiellard/gnark-oz/pull/10).*

### Inconsistent Plonk Implementation

The code under audit updates the Plonk implementation from a [previous version](https://eprint.iacr.org/archive/2019/953/1585767119.pdf) to the [latest version](https://eprint.iacr.org/2019/953.pdf). Specifically:

- The [quotient polynomial](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L1322-L1329) h(X) is included in the linearized polynomial.
- The corresponding opening ˉhˉ (\bar{h}) is no longer included in the proof.
- The linearized polyenomial opening r(ζ) is [no longer provided](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L1386) to the Solidity verifier.

However, the transition is incomplete:

- The code uses the old definition of *r*(X) which disregards the constant terms. To see this, note the following:

  - The [Plonk constraint term](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L1303-L1317) should include PI(ζ)
  - The α2z(X)L1​(ζ)[term](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L1320) should be α2(z(X)−1)L1​(ζ)
  - The βSσ3​(X)[factor](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L1300) should be ō+βSσ3​+γ
- The Go verifier still [receives](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/verify.go#L196) under the old definition of *r*(X)

In addition, previous inconsistencies have been retained:

- The [bottom two shards](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L612-L620) of the quotient polynomial have degree n+1 (instead of n−1)
- The ordering constraint (α term) [is negated](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L815)
- The L1 term is [actually computed as L](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L494)0
- The final *v* term is computed randomly in the Go verifier, rather than using the expected Fiat-Shamir derivation.

While internally consistent, this means that the code does not conform to either version of the Plonk protocol. It also uses terminology that spans both versions. This makes the codebase harder to understand, modify and maintain.

Consider strictly following the latest Plonk specification.

***Update:** Acknowledged, not resolved. The Linea team stated:*

> *Acknowledged. We will leave it this way for the moment. The most important part is that there is no division anymore in the verifier since the quotient is included in the linearized polynomial. For the signs, it is arbitrary. For the degrees of the shards, it allows using a slightly smaller SRS.*

### Missing Proof Validation

The [`Verify` function](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/verify.go#L46) does not validate the following:

- Whether the polynomial openings are valid field elements
- Whether the public witness values are valid field elements
- Whether the proof commitments are valid elliptic curve points
- Whether the proof commitments are on the correct subgroup

Fortunately, bn curves [do not have small subgroups](https://hackmd.io/@jpw/bn254#Subgroup-check-for-mathbb-G_1) (and therefore are not subject to small subgroup attacks), but this should be validated for the other curves in the library.

In the interest of reducing the attack surface and increasing compliance with the [Plonk specification](https://eprint.iacr.org/2019/953.pdf), consider introducing these checks.

***Update:** Partially resolved in [pull request #11](https://github.com/ThomasPiellard/gnark-oz/pull/11).*

*The fix validates that the commitments from the proof are elements of the correct subgroup. It does not check that the openings and the public values are valid field elements. The rationale is that these checks are done implicitly in Gnark during instantiation.*

*However, the implicit checks can still be bypassed (e.g., if one passes a 256-bit value with all the bits set as in `a := fr.Element{ 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff}`, that is still a valid 256-bit constant, but is not a BN254 field element).*

## Low Severity

### Imprecise Domain Size

The larger domain size [is identified by a simple calculation](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L250), but is then [manually separated into two cases](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L252-L256). Moreover, when `sizeSystem` is 5, direct calculation would result in a larger domain of size 32 rather than the currently computed 64.

Consider passing the desired number of evaluation points, `(domain0.Cardinality + 2) * 3`, in all cases.

***Update:** Acknowledged, not resolved. The Linea team stated:*

> *We prefer leaving it this way. We remember that it led to weird issues back when we implemented it.*

### Off-by-One Indexing Error in Unmarshal Logic

In the `UnmarshalSolidity` function, there should be 6 [rather than 7](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/unmarshal.go#L14) positions reserved for standard batched polynomial openings. Similarly, the [additional BSB22 openings](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/unmarshal.go#L76) should start at index `6`. This is consistent with the [proof construction](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L724-L732).

Consider updating the index, ideally with a named global constant.

***Update:** Resolved in [pull request #10](https://github.com/ThomasPiellard/gnark-oz/pull/10).*

### 

### Implicit Modification of the Blinded `Z` Polynomial Inside `innerComputeLinearizedPoly`

The `innerComputeLinearizedPoly` function [directly modifies the `blindedZCanonical`](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L1320) slice, which corresponds to the instance's [`blindedZ` value](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L185), before [assigning the result](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L673) to the `linearizedPolynomial` variable.

Note that `blindedZ` is not part of the proof (which contains just the opening proof *[Wζω​]* and the opening *Z(ζω)*). Thus, `blindedZ` getting modified inside `innerComputeLinearizedPoly` does not have adverse consequences (e.g., on the verifier side).

Consider cloning `blindedZCanonical` first so that `blindedZ` remains correct, or explicitly documenting that it is modified in place.

***Update:** Resolved in [pull request #12](https://github.com/ThomasPiellard/gnark-oz/pull/12). This issue was fixed by following our second suggestion. That is, by adding an explicit comment that the `blindedZCanonical` value is modified inside the function.*

### Naming Suggestions

There are multiple instances of functions and variables with misleading names:

- [`divideByXMinusOne`](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L1156) could be more appropriately renamed to `divideByXnMinusOne` or `divideByZH`.
- [`verify_opening_linearised_polynomial`](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L1173) does not perform any verification and could more appropriately be renamed to `compute_opening_linearised_polynomial`.
- [`lagrangeOne`](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/verify.go#L107-L110) is computed as ζn−1/(n(ζ−1)), which is the evaluation L0​(ζ) of the 0-th Lagrange basis polynomial. It could more appropriately be renamed to `lagrangeZero`.
- Similarly, [`alphaSquareLagrangeOne`](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/verify.go#L178-L180) could be more appropriately renamed to `alphaSquareLagrangeZero`.

Consider implementing the above renaming suggestions to improve code clarity.

***Update:** Resolved in [pull request #9](https://github.com/ThomasPiellard/gnark-oz/pull/9).*

### 

### Missing Error Check

The error associated with a failed `MOD_EXP` precompile appears to have been [inadvertently removed](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L1328).

Consider restoring the error.

***Update:** Resolved in [pull request #8](https://github.com/ThomasPiellard/gnark-oz/pull/8).*

### Misleading or Erroneous Documentation

We have identified the following instances of misleading documentation:

- The [solveConstraints](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L324) comment says that the function computes the (LRO) polynomials in canonical form whereas they are in Lagrange form.
- [kzg.Commit](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L453) defined in the `gnark-crypto` library at [gnark-crypto/ecc/bn254/kzg/kzg.go:L170](https://github.com/Consensys/gnark-crypto/blob/master/ecc/bn254/kzg/kzg.go#L170), expects a polynomial in coefficient form according to the comment (in `gnark-crypto` [kzg.go:L169](https://github.com/Consensys/gnark-crypto/blob/master/ecc/bn254/kzg/kzg.go#L169)), but in `prove.go`, it can also be in Lagrange form.
- The [domain size validation](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/setup.go#L99) uses `GetNbConstraints` but the actual size [includes the public inputs](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/setup.go#L258).
- The comment [explaining the "gamma" encoding](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L407) is out-of-place now that there is an `FS_GAMMA` constant.
- The [`fold_state` comment](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L897) still includes `H(ζ)` - a remnant from the previous version.
- The [`STATE_FOLDED_DIGESTS_X` comment](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L130) still includes `H`.
- The [comment explaining a preimage size](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L1006) says `0x17` instead of `0x14`.
- The [BSB22 proof layout comment](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L112-L113) is obsolete because the two preceding constants, namely `PROOF_OPENING_QCP_AT_ZETA` and `PROOF_BSB_COMMITMENTS`, already identify these values.
- The [`quotient_polynomial_at_zeta` comment](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/unmarshal.go#L58) is obsolete since it has been removed from the batched proof.
- The `getBlindedCoefficient` function [claims](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L1080) that it modifies the underlying polynomial coefficients. However, the `append` operation will resize the slice and so the original coefficients slice will remain unchanged.
- The [`wire_committed_commitments`](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/unmarshal.go#L74) refers to the [following loop](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/unmarshal.go#L80-L83).

To improve the clarity and readability of the codebase, consider addressing the aforementioned inconsistencies in the documentation.

***Update:** Partially resolved in [pull request #7](https://github.com/ThomasPiellard/gnark-oz/pull/7).*

*The following recommendations were not addressed:*

- *The `kzg.Commit` defined in the gnark-crypto library at `gnark-crypto/ecc/bn254/kzg/kzg.go:L170` expects a polynomial in coefficient form according to the comment (in gnark-crypto `kzg.go:L169`). However, in `prove.go`, it can also be in Lagrange form.*
- *The `wire_committed_commitments` refers to the wrong loop.*
- *The `getBlindedCoefficient` function claims that it modifies the underlying polynomial coefficients. However, the `append` operation will resize the slice and so the original coefficients slice will remain unchanged. Note that the fix amends the comment, saying that only the size is modified, which is also incorrect. Since the `append` operation makes a local copy of `p` (which is then modified), the size of `p` remains the same.*

### Code Simplifications

The following are some suggestions to simplify the code:

- The polynomial `Coefficients` function is used to retrieve evaluations (e.g., [here](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L358)) when the polynomial is in Lagrange form. For clarity, consider creating an `Evaluations` function to be used instead.
- The `NewTrace` function could read the domain's cardinality instead of [recomputing the size](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/setup.go#L159).
- The `MarshalSolidity` function [hardcodes the proof size](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L1341). If there are more than two BSB22 commitment gates, this will need to be resized. Instead, the correct size could be computed dynamically.
- [This](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L1401) `if` statement is redundant.
- The [fold_state function](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L900) keeps recomputing `add(state, STATE_FOLDED_DIGESTS_X)` instead of using `state_folded_digests`. Similarly, `add(state, STATE_FOLDED_CLAIMED_VALUES)` could be saved so that it does not need to be recomputed.
- The commitment constraint index could be included [in the loop specification](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/verify.go#L147) so it does not need to be [recomputed](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/verify.go#L154).
- The `FoldProof` function contains an [`if` statement](https://github.com/Consensys/gnark-crypto/blob/8dbbb92c90f315a9e391925186c7086fcaa60f32/ecc/bn254/kzg/kzg.go#L379) that could be naturally integrated into the [following loop](https://github.com/Consensys/gnark-crypto/blob/8dbbb92c90f315a9e391925186c7086fcaa60f32/ecc/bn254/kzg/kzg.go#L382-L384).
- The `batchOpening` function [waits for the channels `chLRO` and `chLinearizedPolynomial`](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L699-L711). However, the first `select` statement is redundant because `chLinearizedPolynomial` cannot close before `chLRO`.
- [This variable assignment](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L1196) recomputes `expo` unnecessarily.

Consider implementing the aforementioned code simplification suggestions to improve the clarity and maintainability of the codebase.

***Update:** Partially resolved in [pull request #6](https://github.com/ThomasPiellard/gnark-oz/pull/6).*

*The following recommendations were not addressed:*

- *The polynomial `Coefficients` function is used to retrieve evaluations when the polynomial is in Lagrange form. For clarity, consider creating an `Evaluations` function to be used instead.*
- *The `MarshalSolidity` function hardcodes the proof size. If there are more than two BSB22 commitment gates, this will need to be resized. Instead, the correct size could be computed dynamically.*
- *Similarly, `add(state, STATE_FOLDED_CLAIMED_VALUES)` could be saved so that it does not need to be recomputed.*
- *The `FoldProof` function contains an `if` statement that could be naturally integrated into the following loop.*

### Verifier Regressions

Our [previous audit report](https://blog.openzeppelin.com/linea-verifier-audit-1) included recommendations and fixes associated with the Solidity verifier. This corresponds to the output of the [`ExportSolidity` Go function](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/verify.go#L372).

However, when reviewing the template, we identified the following regressions:

- The `sum_pi_commit` function [contains a final unnecessary pointer update](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L644).
- The explanation for the ["beta"](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L471) offset incorrectly references "gamma" and has the wrong offset.
- The polynomial openings are [described](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L87) as "wire values at zeta". It would be more accurate to describe them as "evaluations of wire polynomials at zeta".
- The [b0](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L713) and [b0 ^ b1](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L737) comments incorrectly describe them as occupying 64 bytes.
- The [comment](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L1152) describing the `fold_h` function uses `m` instead of `n` as the group size.
- [This comment](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L763) uses "mPtr[32:]" instead of "mPtr[:32]".
- [This comment](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L761) is unclear and incorrectly suggests that "b2" is 16 bytes.
- The [n](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L570) parameter of the `batch_compute_lagranges_at_z` function is the number of public inputs which [conflicts](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L569) with the domain size.
- The [H commitments](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L80-L85) should include `com` in their name to be consistent with the other constants.
- There are several functions and variables that could remove the "api" decorator which is a reference to how they were constructed rather than what they represent.

Consider restoring the aforementioned corrections.

***Update:** Partially resolved in [pull request #5](https://github.com/ThomasPiellard/gnark-oz/pull/5).*

*The following regressions from the previous audit were not addressed:*

- *The `b0` and `b0 ^ b1` comments incorrectly describe them as occupying 64 bytes.*
- *This comment is unclear and incorrectly suggests that `"b2"` is 16 bytes.*
- *There are several functions and variables that could remove the `"api"` decorator which is a reference to how they were constructed rather than what they represent.*

## Notes & Additional Information

### Imprecise Calculation for Number of Gates

In the `computeNumerator` function, the number of BSB gates [is computed](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L775) using the size of the memory location where the gates are stored. However, the `+1` term in this calculation is incorrect. This does not introduce incorrect functionality because the last bit is discarded during the final division.

Nevertheless, in the interest of clarity and simplicity, consider removing this extra term. Alternatively, consider reading the number of gates directly from the [`commitmentInfo` parameter](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/prove.go#L193).

***Update:** Resolved in [pull request #2](https://github.com/ThomasPiellard/gnark-oz/pull/2).*

### Presence of Magic Numbers

In the Solidity verifier, several [constants for the precompiles](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L160-L163) are introduced. There are multiple instances where the constants should be used (e.g., [1](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L839), [2](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L887), [3](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L1278), [4](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L1297)). In addition, there are several instances (e.g., [1](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L450), [2](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L507), [3](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L705) and 6 more places) where the hard-coded constant `0x2` for the `SHA2` precompile is used. Finally, the [fixed proof size](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L322) should be its own constant or one could use `PROOF_OPENING_QCP_AT_ZETA` instead of hardcoding `0x300`.

To minimize the possibility of issues arising from the use of magic numbers, consider applying the following changes:

- Replace the hard-coded identifiers of the precompiles with their respective constants.
- Introduce a new constant for the `SHA2` precompile and use it instead of the hard-coded identifier `0x2`.
- Introduce a new constant for the fixed proof size or, alternatively, use `PROOF_OPENING_QCP_AT_ZETA` instead of hardcoding `0x300`, as noted above.

***Update:** Partially resolved in [pull request #3](https://github.com/ThomasPiellard/gnark-oz/pull/3).*

*The following recommendation has not been addressed:*

- *Replace the hard-coded identifiers of the precompiles with their respective constants.*

### 

### Unused Variable in Solidity Verifier

The [`state` variable](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L1293) in the `point_acc_mul_calldata` function is unused.

Consider removing the unused variable to improve code clarity.

***Update:** Resolved in [pull request #4](https://github.com/ThomasPiellard/gnark-oz/pull/4).*

### 

### Use Templating Mechanism for all Buffer Offsets in the Solidity Verifier

In the solidity verifier, [template offset variables](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L71) are used to ensure that the constant offsets are specified correctly. Consider using the same mechanism for all buffers with hardcoded constants, such as:

- [when deriving γ](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L411-L426) (note that this would also remove the `544` and `576` "magic" constants),
- [when constructing the pairing check](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L866),
- [when deriving the linearization factor](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L971),
- and at other places.

***Update:** Partially resolved in [pull request #1](https://github.com/ThomasPiellard/gnark-oz/pull/1).*

*The following recommendation has not been addressed:*

- *Consider using the template offset variables mechanism for all buffers with hard-coded constants, such as when deriving the linearization factor and at other places.*

*The Linea team stated:*

> *In `compute_kzg`, we left it as it was since there is a jump on the offset due to the `calldataload`. We prefer to leave the constants hard-coded as they do not depend on the number of custom gates.*

### Typographical Errors

We identified the following typographical errors:

- The word ["converts"](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L1337) has two spaces in the middle.
- The word ["numger"](https://github.com/Consensys/gnark/blob/e2040836eb41a40df04a4a3648764b07a0fa12a2/backend/plonk/bn254/solidity.go#L804) should be "number".

Consider fixing any typographical errors to improve the readability of the codebase.

***Update:** Resolved in [pull request #13](https://github.com/ThomasPiellard/gnark-oz/pull/13).*

## Conclusion

The audit covered the Linea Go implementation of a PLONK ZK prover and associated verifier, as well as the changes to a version of the verifier implemented in Solidity. The codebase is well-written and sufficiently documented.

One high-severity and four medium-severity issues were discovered among other lower-severity issues. The high-severity issue concerned not blinding the three parts of the quotient polynomials computed by the prover which effectively invalidates the statistical ZK property of the system. This, as well as some of the medium-severity issues, resulted from incomplete adherence to the latest version of the PLONK paper. Our overall recommendation is to make the audited implementation fully consistent with the latest version of the paper.

We would like to thank the Linea team - and Thomas Piellard, in particular - for their responsiveness in addressing promptly and in detail all questions that were raised during the course of the audit.

**Appendix I - Out of Scope Files**

Inexhaustive list of out-of-scope files and functions that were reviewed in order to understand the in-scope files:

- `gnark/backend/backend.go:57:backend.ProverConfig`
- `gnark-crypto/ecc/bn254/kzg/kzg.go:L51:VerifyingKey`
- `kzg.Commit` from `gnark-crypto/ecc/bn254/kzg/kzg.go:170`
- `gnark-crypto/ecc/bn254/fr/iop/polynomial.go:49`
- `gnark-crypto/ecc/bn254/fr/iop/polynomial.go:73:Polynomial`
- `gnark-crypto/ecc/bn254/fr/iop/polynomial.go:222`
- `gnark-crypto/ecc/bn254/fr/polynomial/polynomial.go:99:Add`
- `gnark-crypto/ecc/bn254/kzg/kzg.go:58:SRS`
- `gnark-crypto/ecc/bn254/fr/fft/domain.go:79:NewDomain(m)`
- `cs.SparseR1C` defined in `gnark/constraint/r1cs_sparse.go:143`
- `gnark-crypto/ecc/bn254/fr/generator.go:29:Generator`
- `gnark-crypto/fiat-shamir/transcript.go:64:Bind`
- `gnark-crypto/fiat-shamir/transcript.go:89:ComputeChallenge`
- `gnark-crypto/fiat-shamir/transcript.go:49:NewTranscript`
- `gnark-crypto/ecc/bn254/fr/iop/ratios.go:147:BuildRatioCopyConstraint`
- `gnark-crypto/ecc/bn254/fr/iop/ratios.go:331:getSupportIdentityPermutation`
- `gnark-crypto/ecc/bn254/kzg/kzg.go:L301:BatchOpenSinglePoint`
- `gnark-crypto/ecc/bn254/fr/fft/domain.go`
- `gnark-crypto/ecc/bn254/fr/fft/domain.go:210:BuildExpTable`
- `gnark-crypto/ecc/bn254/fr/iop/expressions.go:37:Evaluate`
- `gnark-crypto/ecc/bn254/fr/iop/ratios.go:288:checkSize`
- `gnark-crypto/ecc/bn254/multiexp.go:L31:MultiExp`
- `gnark-crypto/ecc/bn254/kzg/kzg.go:L424-449:BatchVerifyMultiPoints`
- `gnark-crypto/ecc/bn254/kzg/kzg.go:L360:FoldProof`
- `gnark-crypto/ecc/bn254/kzg/kzg.go:L550:deriveGamma`
- `gnark-crypto/ecc/bn254/kzg/marshal.go:L151:ReadFrom`
- `gnark-crypto/ecc/bn254/kzg/marshal.go:L162:UnsafeReadFrom`
- `gnark-crypto/ecc/bn254/marshal.go:L377:NewEncoder`
- `gnark-crypto/ecc/bn254/marshal.go:L68:NewDecoder`
- `gnark-crypto/ecc/bn254/kzg/marshal.go:L27:WriteTo`
- `gnark-crypto/ecc/bn254/kzg/marshal.go:L151:ReadFrom`
- `gnark-crypto/ecc/bn254/kzg/marshal.go:L162:UnsafeReadFrom`
- `gnark-crypto/ecc/bn254/marshal.go:L730:Unmarshal`
- `gnark-crypto/ecc/bn254/fp/element.go::L912:SetBytes`
