// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC6372} from "@openzeppelin/contracts/interfaces/IERC6372.sol";
import {IVotesPartialDelegation} from "src/IVotesPartialDelegation.sol";

/**
 * @dev Interface that mostly supports the ERC5805 standard, but with a modified IVotes that more appropriately
 * describes partial delegation.
 */
interface IERC5805Modified is IERC6372, IVotesPartialDelegation {}
