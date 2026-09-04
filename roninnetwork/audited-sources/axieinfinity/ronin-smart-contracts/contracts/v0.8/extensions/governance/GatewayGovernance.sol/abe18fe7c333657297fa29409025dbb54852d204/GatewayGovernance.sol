// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

abstract contract GatewayGovernance {
  enum VoteStatus {
    Pending,
    Approved,
    Executed
  }

  struct ReceiptVote {
    VoteStatus status;
    bytes32 finalHash;
    /// @dev Mapping from voter => receipt hash
    mapping(address => bytes32) receiptHash;
    /// @dev Mapping from receipt hash => vote weight
    mapping(bytes32 => uint256) weight;
  }

  /**
   * @dev Casts vote for the receipt with the receipt hash `_hash`.
   *
   * Requirements:
   * - The vote is not finalized.
   * - The voter has not voted for the round.
   *
   */
  function _castVote(
    ReceiptVote storage _proposal,
    address _voter,
    uint256 _voterWeight,
    uint256 _minimumVoteWeight,
    bytes32 _hash
  ) internal virtual returns (VoteStatus _status, uint256 _weight) {
    require(_proposal.status == VoteStatus.Pending, "GatewayGovernance: the vote is finalized");

    if (_voted(_proposal, _voter)) {
      revert(
        string(abi.encodePacked("GatewayGovernance: ", Strings.toHexString(uint160(_voter), 20), " already voted"))
      );
    }

    // Record for voter
    _proposal.receiptHash[_voter] = _hash;
    // Increase vote weight
    _weight = _proposal.weight[_hash] += _voterWeight;

    if (_weight >= _minimumVoteWeight) {
      _status = VoteStatus.Approved;
      _proposal.status = _status;
      _proposal.finalHash = _hash;
    }
  }

  /**
   * @dev Returns whether the voter casted for the proposal.
   */
  function _voted(ReceiptVote storage _proposal, address _voter) internal view virtual returns (bool) {
    return _proposal.receiptHash[_voter] != bytes32(0);
  }
}
