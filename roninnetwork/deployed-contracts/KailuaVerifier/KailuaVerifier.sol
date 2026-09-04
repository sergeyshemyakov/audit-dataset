// SPDX-License-Identifier: Unknown
pragma solidity 0.8.24;

// lib/optimism/packages/contracts-bedrock/interfaces/universal/ISemver.sol

/// @title ISemver
/// @notice ISemver is a simple contract for ensuring that contracts are
///         versioned using semantic versioning.
interface ISemver {
    /// @notice Getter for the semantic version of the contract. This is not
    ///         meant to be used onchain but instead meant to be used by offchain
    ///         tooling.
    /// @return Semver contract version as a string.
    function version() external view returns (string memory);
}

// lib/risc0-ethereum/contracts/src/IRiscZeroVerifier.sol
// Copyright 2025 RISC Zero, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/// @notice A receipt attesting to a claim using the RISC Zero proof system.
/// @dev A receipt contains two parts: a seal and a claim.
///
/// The seal is a zero-knowledge proof attesting to knowledge of a witness for the claim. The claim
/// is a set of public outputs, and for zkVM execution is the hash of a `ReceiptClaim` struct.
///
/// IMPORTANT: The `claimDigest` field must be a hash computed by the caller for verification to
/// have meaningful guarantees. Treat this similar to verifying an ECDSA signature, in that hashing
/// is a key operation in verification. The most common way to calculate this hash is to use the
/// `ReceiptClaimLib.ok(imageId, journalDigest).digest()` for successful executions.
struct Receipt {
    bytes seal;
    bytes32 claimDigest;
}

/// @notice Verifier interface for RISC Zero receipts of execution.
interface IRiscZeroVerifier {
    /// @notice Verify that the given seal is a valid RISC Zero proof of execution with the
    ///     given image ID and journal digest. Reverts on failure.
    /// @dev This method additionally ensures that the input hash is all-zeros (i.e. no
    /// committed input), the exit code is (Halted, 0), and there are no assumptions (i.e. the
    /// receipt is unconditional).
    /// @param seal The encoded cryptographic proof (i.e. SNARK).
    /// @param imageId The identifier for the guest program.
    /// @param journalDigest The SHA-256 digest of the journal bytes.
    function verify(bytes calldata seal, bytes32 imageId, bytes32 journalDigest) external view;

    /// @notice Verify that the given receipt is a valid RISC Zero receipt, ensuring the `seal` is
    /// valid a cryptographic proof of the execution with the given `claim`. Reverts on failure.
    /// @param receipt The receipt to be verified.
    function verifyIntegrity(Receipt calldata receipt) external view;
}

/// @title LibDuration
/// @notice This library contains helper functions for working with the `Duration` type.
library LibDuration {
    /// @notice Get the value of a `Duration` type in the form of the underlying uint64.
    /// @param _duration The `Duration` type to get the value of.
    /// @return duration_ The value of the `Duration` type as a uint64 type.
    function raw(Duration _duration) internal pure returns (uint64 duration_) {
        assembly {
            duration_ := _duration
        }
    }
}

using LibDuration for Duration global;

/// @notice A dedicated duration type.
/// @dev Unit: seconds
type Duration is uint64;

// src/KailuaLib.sol
// Copyright 2024, 2025 RISC Zero, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/// @notice Denotes the proven status of the game
/// @custom:value NONE indicates that no proof has been submitted yet.
enum ProofStatus {
    NONE,
    FAULT,
    VALIDITY
}

interface IKailuaTreasury {
    /// @notice Emitted when the participation bond is updated
    /// @param amount The new required bond amount
    event BondUpdated(uint256 amount);

    /// @notice Returns the game index at which proposer was proven faulty
    function eliminationRound(address proposer) external view returns (uint256);

    /// @notice Returns the proposer of a game
    function proposerOf(address game) external view returns (address);

    /// @notice Eliminates a child's proposer and allocates their bond to the prover
    function eliminate(address child, address prover) external;

    /// @notice Returns true iff a proposal is currently being submitted
    function isProposing() external view returns (bool);

    /// @notice Returns the last resolved proposal contract address
    function lastResolved() external view returns (address);

    /// @notice Updates the last resolved contract address to that of the caller
    function updateLastResolved() external;

    /// @notice Returns the collateral required to submit proposals
    function participationBond() external view returns (uint256);

    /// @notice Returns the prover's number of shares in elimination rewards
    function ELIMINATION_SPLIT_PROVER_NUM() external view returns (uint256);

    /// @notice Returns the total number of shares for elimination rewards
    function ELIMINATION_SPLIT_DENOM() external view returns (uint256);
}

/// @title LibTimestamp
/// @notice This library contains helper functions for working with the `Timestamp` type.
library LibTimestamp {
    /// @notice Get the value of a `Timestamp` type in the form of the underlying uint64.
    /// @param _timestamp The `Timestamp` type to get the value of.
    /// @return timestamp_ The value of the `Timestamp` type as a uint64 type.
    function raw(Timestamp _timestamp) internal pure returns (uint64 timestamp_) {
        assembly {
            timestamp_ := _timestamp
        }
    }
}

using LibTimestamp for Timestamp global;

/// @notice A dedicated timestamp type.
type Timestamp is uint64;

interface IKailuaTournament {
    /// @notice Emitted when a proof is submitted.
    /// @param signature The proposal signature
    /// @param status The proven status
    event Proven(bytes32 indexed signature, ProofStatus indexed status);

    /// @notice Returns the KailuaTreasury of this tournament
    function KAILUA_TREASURY() external view returns (IKailuaTreasury);
    /// @notice The timestamp of when the first proof for a proposal signature was made
    function provenAt(bytes32) external view returns (Timestamp);
    /// @notice Returns the hash of the output claim and all blob hashes associated with this proposal
    function signature() external view returns (bytes32);
    /// @notice Returns whether a child can be considered valid
    function isViableSignature(bytes32 childSignature) external view returns (bool);
    /// @notice Returns the signature of the child proven valid
    function validChildSignature() external view returns (bytes32);
}

// src/KailuaVerifier.sol
// Copyright 2025 RISC Zero, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/// @notice Thrown when a target is invalid
error BadTarget();

// 0x5e22e582
/// @notice Thrown when resolving a faulty proposal
error ProvenFaulty();

/// @notice Thrown when a supplied bond is not equal to the required bond amount to cover the cost of the interaction.
error IncorrectBondAmount();

/// @notice Thrown when the game is attempted to be resolved too early.
error ClockNotExpired();

// 0xa506d334
/// @notice Thrown when a resolution is attempted for an unproven claim
error NotProven();

/// @notice Thrown when a credit claim is attempted for a value of 0.
error NoCreditToClaim();

// 0x8b1dfa22
/// @notice Thrown when eliminating an already removed child
error AlreadyEliminated();

/// @notice Thrown when the transfer of credit to a recipient account reverts.
error BondTransferFailed();

library KailuaPayLib {
    /// @notice Transfers ETH from the contract's balance to the recipient
    function pay(uint256 amount, address recipient) internal {
        (bool success,) = recipient.call{value: amount}(hex"");
        if (!success) revert BondTransferFailed();
    }
}

contract KailuaVerifier is ISemver {
    /// @notice Semantic version.
    /// @custom:semver 1.2.0
    string public constant version = "1.2.0";

    /// @notice The RISC Zero verifier contract
    IRiscZeroVerifier public immutable RISC_ZERO_VERIFIER;

    /// @notice The RISC Zero image id of the fault proof program
    bytes32 public immutable FPVM_IMAGE_ID;

    /// @notice The hash of the game configuration
    bytes32 public immutable ROLLUP_CONFIG_HASH;

    /// @notice The duration after which a permit expires
    Duration public immutable PERMIT_DURATION;

    /// @notice The duration after which a permit is active
    Duration public immutable PERMIT_DELAY;

    constructor(
        IRiscZeroVerifier _verifierContract,
        bytes32 _imageId,
        bytes32 _configHash,
        Duration _permitDuration,
        Duration _permitDelay
    ) {
        RISC_ZERO_VERIFIER = _verifierContract;
        FPVM_IMAGE_ID = _imageId;
        ROLLUP_CONFIG_HASH = _configHash;
        PERMIT_DURATION = _permitDuration;
        PERMIT_DELAY = _permitDelay;
        assert(_permitDelay.raw() < _permitDuration.raw());
    }

    /// @notice Maps parent-child to their fault proving permits
    mapping(bytes32 => FaultProofPermit[]) public faultProofPermits;

    /// @notice Describes a permit for fault proving
    /// @custom:field recipient             Address of the permit recipient
    /// @custom:field aggregateCollateral   Total collateral locked as of permit
    /// @custom:field timestamp             Timestamp of permit issuance
    /// @custom:field released              Flag for whether the collateral locked for this permit
    struct FaultProofPermit {
        uint256 aggregateCollateral;
        address recipient;
        uint64 timestamp;
        bool released;
    }

    /// @notice Returns the key for indexing fault proving permits
    function faultProofPermitKey(IKailuaTournament proposalParent, bytes32 proposalSignature)
        public
        pure
        returns (bytes32)
    {
        return sha256(abi.encodePacked(address(proposalParent), proposalSignature));
    }

    /// @notice Returns the earliest timestamp at which a fault proof permit can be released
    function faultProofPermitProvenAt(IKailuaTournament proposalParent, bytes32 proposalSignature)
        public
        view
        returns (uint64)
    {
        // INVARIANT: A validity proof for the same signature does not satisfy a fault proof permit.
        bytes32 validChildSignature = proposalParent.validChildSignature();
        if (proposalSignature == validChildSignature) {
            return 0;
        }
        // Fetch both fault and validity proof timestamps
        uint64 faultProofTimestamp = proposalParent.provenAt(proposalSignature).raw();
        uint64 validityProofTimestamp = proposalParent.provenAt(validChildSignature).raw();
        // Return the smaller timestamp if both proofs are present
        if (faultProofTimestamp > 0 && validityProofTimestamp > 0) {
            return faultProofTimestamp < validityProofTimestamp ? faultProofTimestamp : validityProofTimestamp;
        }
        // Return the larger timestamp otherwise
        return faultProofTimestamp > validityProofTimestamp ? faultProofTimestamp : validityProofTimestamp;
    }

    /// @notice Returns the exclusive beneficiary of a fault proof reward
    function faultProofPermitBeneficiary(IKailuaTournament proposalParent, bytes32 proposalSignature)
        public
        view
        returns (address)
    {
        // If the signature is still viable, there is no sole fault proof beneficiary
        if (proposalParent.isViableSignature(proposalSignature)) {
            return address(0x0);
        }
        // If there wasn't exactly one permit, then proving was not exclusive to one party
        FaultProofPermit[] storage proposalPermits =
            faultProofPermits[faultProofPermitKey(proposalParent, proposalSignature)];
        if (proposalPermits.length != 1) {
            return address(0x0);
        }
        // If the permit was not yet active at proof submission, ignore the permit
        uint64 provingTime = faultProofPermitProvenAt(proposalParent, proposalSignature);
        if (provingTime < proposalPermits[0].timestamp + PERMIT_DELAY.raw()) {
            return address(0x0);
        }
        // If there was no proof or the permit was expired as of proof submission, disqualify the beneficiary
        if (provingTime == 0 || proposalPermits[0].timestamp + PERMIT_DURATION.raw() < provingTime) {
            return address(0x0);
        }
        // Return the successful sole beneficiary of the locked fault proof reward
        return proposalPermits[0].recipient;
    }

    /// @notice Given a reference timestamp, returns the number of expired permits, the number of delayed permits,
    /// the total expired permit collateral, and the number of active permits
    function countExpiredPermits(
        bytes32 proposalKey,
        uint64 numExpiredPermits,
        uint64 numDelayedPermits,
        uint64 timestamp
    ) public view returns (uint64, uint64, uint256, uint64) {
        FaultProofPermit[] storage proposalPermits = faultProofPermits[proposalKey];
        uint256 expiredCollateral = 0;
        uint64 totalPermits = uint64(proposalPermits.length);
        if (totalPermits == 0) {
            // If there are no permits, no permit is expired or active, and there is no collateral
            return (0, 0, 0, 0);
        }
        // Increment numExpiredPermits if possible
        for (; numExpiredPermits < totalPermits; numExpiredPermits++) {
            if (proposalPermits[numExpiredPermits].timestamp + PERMIT_DURATION.raw() >= timestamp) {
                break;
            }
        }
        // Validate expiry
        if (numExpiredPermits > 0) {
            // If numExpiredPermits is invalid, revert
            if (proposalPermits[numExpiredPermits - 1].timestamp + PERMIT_DURATION.raw() >= timestamp) {
                revert BadTarget();
            }
            // Set expired collateral
            expiredCollateral = proposalPermits[numExpiredPermits - 1].aggregateCollateral;
        }
        // Increment numDelayedPermits if possible
        for (; numDelayedPermits < totalPermits; numDelayedPermits++) {
            // If this permit is active, stop incrementing
            if (proposalPermits[totalPermits - numDelayedPermits - 1].timestamp + PERMIT_DELAY.raw() <= timestamp) {
                break;
            }
        }
        // Decrement numDelayedPermits if possible
        numDelayedPermits = numDelayedPermits > totalPermits ? totalPermits : numDelayedPermits;
        for (; numDelayedPermits > 0 && numDelayedPermits <= totalPermits; numDelayedPermits--) {
            // If this permit is delayed, stop decrementing
            if (proposalPermits[totalPermits - numDelayedPermits].timestamp + PERMIT_DELAY.raw() > timestamp) {
                break;
            }
        }
        return
            (
                numExpiredPermits,
                numDelayedPermits,
                expiredCollateral,
                totalPermits - numExpiredPermits - numDelayedPermits
            );
    }

    /// @notice Returns the collateral required to acquire a fault proof permit
    function faultProofPermitBond(IKailuaTreasury treasury) public view returns (uint256 bond) {
        bond = (treasury.participationBond() * 2 * treasury.ELIMINATION_SPLIT_PROVER_NUM())
            / treasury.ELIMINATION_SPLIT_DENOM();
    }

    /// @notice Locks the right to submit a fault proof for a given proposal signature
    /// @dev Do not call this function to acquire locks for faults that will not lead to elimination.
    function acquireFaultProofPermit(
        IKailuaTournament proposalParent,
        bytes32 proposalSignature,
        uint64 numExpiredPermits,
        uint64 numDelayedPermits,
        address payoutRecipient
    ) external payable returns (uint256 totalPermitsIssued_) {
        // INVARIANT: The child signature is still viable so no proof is submitted for/against it
        if (!proposalParent.isViableSignature(proposalSignature)) {
            revert ProvenFaulty();
        }
        // INVARIANT: The collateral submitted for the permit covers two times the proving reward
        IKailuaTreasury treasury = proposalParent.KAILUA_TREASURY();
        if (msg.value < faultProofPermitBond(treasury)) {
            revert IncorrectBondAmount();
        }
        // INVARIANT: There are exactly numExpiredPermits expired permits as of block.timestamp
        bytes32 proposalKey = faultProofPermitKey(proposalParent, proposalSignature);
        (numExpiredPermits,,,) =
            countExpiredPermits(proposalKey, numExpiredPermits, numDelayedPermits, uint64(block.timestamp));
        // INVARIANT: There is at least one permit available
        FaultProofPermit[] storage proposalPermits = faultProofPermits[proposalKey];
        totalPermitsIssued_ = proposalPermits.length;
        if (totalPermitsIssued_ > 2 * numExpiredPermits) {
            revert ClockNotExpired();
        }
        // Calculate the aggregate collateral value
        uint256 aggregateCollateral = msg.value;
        if (totalPermitsIssued_ > 0) {
            aggregateCollateral += proposalPermits[totalPermitsIssued_ - 1].aggregateCollateral;
        }
        // Assign a new permit
        proposalPermits.push(FaultProofPermit(aggregateCollateral, payoutRecipient, uint64(block.timestamp), false));
    }

    /// @notice Claims the total payout for a permit
    function releaseFaultProofPermit(
        IKailuaTournament proposalParent,
        bytes32 proposalSignature,
        uint64 numExpiredPermits,
        uint64 numDelayedPermits,
        uint64 permitIndex
    ) external {
        // INVARIANT: The child signature is proven faulty
        if (proposalParent.isViableSignature(proposalSignature)) {
            revert NotProven();
        }
        // INVARIANT: There are exactly numExpiredPermits expired permits as of proof submission
        uint64 proofTimestamp = faultProofPermitProvenAt(proposalParent, proposalSignature);
        bytes32 permitKey = faultProofPermitKey(proposalParent, proposalSignature);
        (,, uint256 expiredCollateral, uint64 numActivePermits) =
            countExpiredPermits(permitKey, numExpiredPermits, numDelayedPermits, proofTimestamp);
        // INVARIANT: The permit is not already released
        FaultProofPermit storage permit = faultProofPermits[permitKey][permitIndex];
        if (permit.released) {
            revert NoCreditToClaim();
        }
        // INVARIANT: The permit is not expired as of proof submission
        if (permit.timestamp + PERMIT_DURATION.raw() < proofTimestamp) {
            revert AlreadyEliminated();
        }
        // If the permit was active at proof submission, then we pay out a share of the locked collateral.
        uint256 payout =
            permit.timestamp + PERMIT_DELAY.raw() < proofTimestamp ? expiredCollateral / numActivePermits : 0;
        // Add in recipient's own deposited collateral
        if (permitIndex > 0) {
            payout += permit.aggregateCollateral - faultProofPermits[permitKey][permitIndex - 1].aggregateCollateral;
        } else {
            payout += permit.aggregateCollateral;
        }
        // Pay out recipient
        permit.released = true;
        KailuaPayLib.pay(payout, payable(permit.recipient));
    }

    /// @notice Verifies a ZK proof
    function verify(
        address payoutRecipient,
        bytes32 preconditionHash,
        bytes32 l1Head,
        bytes32 agreedL2OutputRoot,
        bytes32 claimedL2OutputRoot,
        uint64 claimedL2BlockNumber,
        bytes calldata encodedSeal
    ) external view {
        // Construct the expected journal
        bytes memory journal = abi.encodePacked(
            // The address of the recipient of the payout for this proof
            payoutRecipient,
            // The blob equivalence precondition hash
            preconditionHash,
            // The L1 head hash containing the safe L2 chain data that may reproduce the L2 head hash.
            l1Head,
            // The accepted output
            agreedL2OutputRoot,
            // The proposed output
            claimedL2OutputRoot,
            // The claim block number
            claimedL2BlockNumber,
            // The rollup configuration hash
            ROLLUP_CONFIG_HASH,
            // The FPVM Image ID
            FPVM_IMAGE_ID
        );

        // Revert on proof verification failure
        RISC_ZERO_VERIFIER.verify(encodedSeal, FPVM_IMAGE_ID, sha256(journal));
    }
}