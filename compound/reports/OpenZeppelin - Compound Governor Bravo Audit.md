Feb 12, 2021February 12, 2021

* OpenZeppelin Security

The Compound team engaged us to audit a new governance mechanism called [Governor Bravo](https://github.com/compound-finance/compound-protocol/tree/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance). The audited commit is `f86c247f6f81e14f8e0fd78402653a0b8371266a` in the [proposed pull request](https://github.com/compound-finance/compound-protocol/pull/91), and the following files were included in scope:

* [`GovernorBravoDelegate.sol`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol)
* [`GovernorBravoDelegator.sol`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegator.sol)
* [`GovernorBravoInterfaces.sol`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoInterfaces.sol)

Any files that are not listed as “in scope” have not been audited in this engagement.

### High-level overview of the system

`GovernorBravoDelegate` is the logic contract of the new governance. It inherits many of the mechanism from the previous [`GovernorAlpha`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorAlpha.sol) contract with some differences:

* [`proposalThresold`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L245), [`votingDelay`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L219) and [`votingPeriod`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L231) are now non-fixed parameters that can be set.
* Voters can now vote to [`abstain`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L66) and add a [`reason`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L165) along with the vote.
* Governance contract is now upgradeable.

For a complete list of changes here there’s a [summary](https://www.comp.xyz/t/governor-bravo-development/942).

The `GovernorBravoDelegator` contract is the proxy that enables upgradeability of the `GovernorBravoDelegate` contract. This contract is administrated by the `Timelock` contract, which will execute proposals both in the proxy contract (to change [the implementation address](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegator.sol#L36)) and the implementation contract (to set governance parameters or to change `admin`).

Finally, the `GovernorBravoInterfaces.sol` file contains several auxiliary contracts to define storage layouts and events to be emitted.

To update the current governance system to `Governor Bravo` the following steps will be executed:

* The `GovernorBravoDelegate` contract is deployed, and its address is passed as a constructor parameter to deploy the `GovernorBravoDelegator` contract, which will set the `admin` to the `Timelock` contract and will `initialize` the implementation contract.
* A governance proposal is submitted to the current governance contract `GovernorAlpha` to change the `admin` of the `Timelock` to the `GovernorBravoDelegator` contract and to call the Governor Bravo [`_initiate`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L255) function.

Overall we are happy with the changes introduced. The code is clear and easy to read, no major issues have been found and we are pleased that incremental changes are being made to the sensitive governance structure. These contracts were audited by two auditors during the course of 5 days. Here we present our findings, in order of importance.

***Update**: The Compound team has reviewed the issues and published fixes for them. The fixes can be found as pull requests in the following, separate github repository: <https://github.com/Arr00-Blurr/compound-protocol>.*

## Critical severity

None.

## High severity

None.

## Medium severity

### [M01] Lack of input validation

The [`constructor`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegator.sol#L7) in `GovernanceBravoDelegator` lacks input validation on all passed-in parameters, allowing things like [`admin` to be set to `address(0)`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegator.sol#L28), the addresses of `comp` or `timelock` to be [incorrectly set](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L28-L29), or [`proposalThreshold` to be set arbitrarily](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L32) despite [the `MIN_PROPOSAL_THRESHOLD`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L243). Additionally, functions such as [`_setImplementation`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegator.sol#L36), [`_setVotingDelay`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L216) and [`_setVotingPeriod`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L228) contain no input checks and allow sensitive values to be set to any arbitrary value.

Consider bounding inputs to reasonable ranges and excluding certain values, such as `address(0)` or `uint256(0)` from being successfully passed in. This will reduce the surface for error when using these functions.

***Update**: Partially fixed in [pull request #5](https://github.com/Arr00-Blurr/compound-protocol/pull/5). There are still no input checks on the [`_setImplementation`](https://github.com/Arr00-Blurr/compound-protocol/blob/b49b3192fe6a92eb1e9e0619481c03aa1c2c13aa/contracts/Governance/GovernorBravoDelegator.sol#L36) function.*

### [M02] Proposals cannot contain duplicate transactions

When [queueing a proposal](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L82-L84) in the `Timelock` contract, a [check is done](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L90) for each proposed action which verifies that this action is not being done already in this proposal or with the same `eta`.

Although this design appears to be intentional, consider documenting this behavior explicitly. It must be made apparent to future development efforts that any functions which are intended to be called by governance can only be called once with the same parameters per proposal. Developers should understand to design functions such that multiple identical calls are unneeded.

## Low severity

### [L01] Unexecuted proposals from Governor Alpha will be frozen

When upgrading the governance system from Governor Alpha to Governor Bravo, any proposals that are currently unexecuted will not be executable. Whenever the Governor Bravo is transitioned to, the `proposalCount` variable [is set to the `proposalCount` value of Governor Alpha](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L258) at that moment. At this point, executing any proposal will require [it to be in the `Queued` state](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L95). During the execution, when [checking](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L128) the state of the proposal, Governor Alpha proposal IDs will be all less than or equal to [`initialProposalId`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L129), and in those cases, the execution will fail.

Consider informing users of this functionality before upgrading. If a proposal is created in Governor Alpha which cannot be executed, it can always be re-proposed in Governor Bravo. Alternatively, consider implementing some method to execute previously queued proposals in the `Timelock` contract.

### [L02] `initialize` can be called multiple times

The `initialize` function is intended to be [delegate-called during the `GovernorBravoDelegator`‘s construction](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegator.sol#L19). However, since [it is public](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L26) and contains no checks to stop future calls, it can be called again.

It is unclear whether this is intended or not. On the one hand, `initialize` is currently the only method available which can [change the `comp` or `timelock` addresses](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L28-L29). On the other hand, there exist [functions for changing](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L216-L248) the other [three values set in `initialize`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L30-L32), suggesting that it is not intended for `comp` or `timelock` to change after initialization.

Consider implementing some check so that `initialize` can be called only once, like the [`initializer` modifier of the OpenZeppelin `Initializable` contract](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/a4fc50c501ad078d8705715c4a10ea98c52180fb/contracts/proxy/Initializable.sol#L34). Alternatively, consider documenting why `initialize` is left open for future calls. If it is desired to be able to change `comp` or `timelock` while the contract is being used, consider implementing separate functions for setting just those variables, in order to better separate changes to sensitive values within the Governor Bravo system.

***Update**: Fixed in [pull request #4](https://github.com/Arr00-Blurr/compound-protocol/pull/4).*

### [L03] Missing docstrings

Many important functions in the Governor Bravo code base lack documentation. This hinders reviewers’ understanding of the code’s intention, which is fundamental to correctly assess not only security, but also correctness. Additionally, docstrings improve readability and ease maintenance. They should explicitly explain the purpose or intention of the functions, the scenarios under which they can fail, the roles allowed to call them, the values returned and the events emitted. Functions such as [`propose`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L35), [`queue`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L78), and [`execute`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L94) lack explanatory docstrings.

Consider thoroughly documenting all functions (and their parameters) that are part of the contracts’ public API. Functions implementing sensitive functionality, even if not public, should be clearly documented as well. When writing docstrings, consider following the [Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/develop/natspec-format.html) (NatSpec).

***Update**: Fixed in [pull request #10](https://github.com/Arr00-Blurr/compound-protocol/pull/10).*

### [L04] Superfluous condition in `require` statement

Within the [`_acceptAdmin`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L286) function of the `GovernorBravoDelegate` contract, there is a [`require`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L288) statement which checks that `msg.sender != address(0)`. It is a common assumption, within Ethereum, that the private key for `address(0)` will never be known, and therefore it will be impossible for `msg.sender == address(0)`. Although it may seem that this conditional will prevent `pendingAdmin == address(0)`, the first condition in the require (`msg.sender == pendingAdmin`) also takes care of this if we assume that `msg.sender` will never be `address(0)`.

Consider removing the second condition from the mentioned `require`. This will make the code more easily understandable and reduce gas consumption.

### [L05] Unused return value

The [`delegateTo` function](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegator.sol#L52) is `internal` and is only [called once](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegator.sol#L19) within the codebase. When the function is called, the return value is ignored.

To simplify the codebase, consider removing the returned value from `delegateTo`. Alternatively, consider utilizing the returned value when `delegateTo` is called.

***Update**: Fixed in [pull request #6](https://github.com/Arr00-Blurr/compound-protocol/pull/6/files).*

## Notes & Additional Information

### [N01] Inconsistent style

Within the Governor Bravo contracts, there are a few instances of inconsistency in coding style. We have identified the following:

* Some `external` or `public` functions begin with underscores, such as [`_initiate`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L255), while others do not, such as [`castVote`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L155). Additionally, some `internal` functions begin with underscores, such as [`_queueOrRevert`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L89), while some do not, such as [`getChainId`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L315). Often, leading underscores are used for `internal` functions only, to increase the code’s readability. Consider changing function names so that there is a consistent naming style within the Governor Bravo contracts.
* To improve readability, [lines 105 and 106](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L105-L106) of the `GovernorBravoDelegate` contract should be converted into the equivalent used in line [95](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L95) or [79](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L79).
* The constant [`name`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L9) and the constant [`MIN_PROPOSAL_THRESHOLD`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L12) are declared differently than the `pure` functions [`quorumVotes`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L15) and [`proposalMaxOperations`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L18), but they all behave as constants within the code. Consider documenting the discrepancy in declaration style, or changing the declarations of all four to be consistent.

***Update**: Fixed in [pull request #7](https://github.com/Arr00-Blurr/compound-protocol/pull/7/files).*

### [N02] Misleading revert messages

The error message returned on [line 90 of `GovernorBravoDelegate`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L90) implies that queueing has failed because there is already a proposal with the chosen `eta`. However, it is possible to queue multiple proposals with the same `eta`. This `require` will fail only when the exact same action has already been queued.

Additionally, the error message returned on [line 288 of `GovernorBravoDelegate`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L288) implies only the `admin` is allowed to call the `acceptAdmin` function. In actuality, the `pendingAdmin` role is the only one allowed to call this function. Since [`pendingAdmin` and `admin`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoInterfaces.sol#L47-L50) are two distinct roles, this error message should be changed to match this distinction.

Error messages are intended to notify users about failing conditions, and should provide enough information so that the appropriate corrections needed to interact with the system can be applied. Uninformative error messages greatly damage the overall user experience, thus lowering the system’s quality. Therefore, consider not only fixing the specific issues mentioned, but also reviewing the entire codebase to make sure every error message is informative and user-friendly enough. Furthermore, for consistency, consider reusing error messages when extremely similar conditions are checked.

***Update**: Partially fixed in [pull request 8](https://github.com/Arr00-Blurr/compound-protocol/pull/8/files). The error message on [line 90 of `GovernorBravoDelegate`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L90) has not been changed. Consider updating this message for greater clarity.*

### [N03] Overflow protection unneeded

Solidity version 0.8 and above has [built-in overflow protection](https://docs.soliditylang.org/en/v0.8.0/080-breaking-changes.html#solidity-v0-8-0-breaking-changes) for math. The `internal` functions [`add256`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L304) and [`sub256`](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol#L310) provide overflow checking functionality. Using solidity 0.8, these are unneeded.

Consider upgrading to Solidity 0.8 and removing instances of `add256` and `sub256`. Utilizing built-in checks reduces code size and therefore the surface for error.

### [N04] Declare `uint` as `uint256`

In the audited contracts, there is a general use of unsigned integer variables declared as `uint`.

To favor explicitness, consider replacing all instances of `uint` to `uint256`.

### [N05] Upgradeable proxy design can be improved

The new governance implementation has been designed to have the [`GovernorBravoDelegator`](https://github.com/compound-finance/compound-protocol/tree/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegator.sol) acting as a proxy for the [`GovernorBravoDelegate`](https://github.com/compound-finance/compound-protocol/tree/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol) contract.

In this sense, the `GovernorBravoDelegate` contract is just the logic implementation layer, and the proxy is in charge of forwarding any call through a `delegatecall` instruction, and of mantaining the storage of the proxied contract.

Separating storage and logic into two separate contracts is a common pattern to follow when upgradeability of the logic layer is needed, but there are some downsides that must be addressed when implementing it.

[Storage collision](https://docs.openzeppelin.com/upgrades-plugins/1.x/proxies#storage-collisions-between-implementation-versions) or [function clashing](https://docs.openzeppelin.com/upgrades-plugins/1.x/proxies#transparent-proxies-and-function-clashes) are two of them.

In the audited contracts, we did not identify any possible storage collisions, but there’s a lack of control against function clashing. Moreover, the [`GovernorBravoDelegateStorageV1` in the `GovernorBravoInterfaces.sol` file](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoInterfaces.sol#L56) defines variables of [different types in mixed order](https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoInterfaces.sol#L71-L85) and this is prone to errors when contract upgrades change the storage layout of the contracts.

Consider using the [OpenZeppelin *unstructured storage* proxy pattern](https://docs.openzeppelin.com/upgrades-plugins/1.x/proxies) to improve design robustness and have proper control over possible function clashes and storage collisions. Alternatively, consider documenting how storage collisions and function clashes will be handled in future upgrades, and consider rearranging the declaration order of `GovernorBravoDelegateStorageV1` so that it follows some predictable pattern.

***Update:** Fixed in [pull request #9](https://github.com/Arr00-Blurr/compound-protocol/pull/9/files). Storage variables within `GovernorBravoInterfaces` are now declared in a predictable order.*

## Conclusion

No critical or high severity issues were found. Recommendations were made to improve code quality and usability, as well as improve the basic structure of the new governance system. We found that typical issues with proxy implementations, such as storage layout management issues, were not present here, although we still reccomend usage of OpenZeppelin’s proxy implementations rather than “rolling your own”. Overall, we found the codebase to be well-written and were happy with the fact that only incremental changes were made from Governor Alpha.
