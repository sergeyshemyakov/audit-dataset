### | security

# **Contracts 5.0** **Release**

#### **October 3, 2023**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  5


Scope ____________________________________________________________________________  6


Overview _______________________________________________________________________ 10


Security Considerations and Threat Model __________________________________________ 13


High Severity ____________________________________________________________________ 15

H-01 Potential Inaccuracies in Voting Unit Accounting When Overriding the ERC20Votes#_getVotingUnits Function's

Formula 15

H-02 Non-Compliance of ERC2771Context With ERC Could Lead to Incorrect Address Extraction 16

H-03 Risk of Failed L2 and Sidechain Deployments with Solidity Version 0.8.20 17


Medium Severity _________________________________________________________________ 18

M-01 Potential Reentrancy in ERC1155._update Function 18

M-02 Unhandled Silent Failures 19

M-03 Lack of Context Usage 20

M-04 Tokens Might Get Stuck in the Contract - Phase 1 20

M-05 ERC2771Forwarder May Call Receiver Without Appending Sender's Address 21

M-06 Immutable Beneficiary Security Risks and Potential Loss of Funds 22

M-07 Unnecessarily Complex and Limited Design of customRevert Callback 23

M-08 State Updated in Modifiers May Be Corrupted 25

M-09 Function withUpdateAt Does Not Behave as Expected 25

M-10 Proposal Execution Could Fail Due to Zero-Delayed AccessManaged Targets 26

M-11 Contradictory _cancel Behavior 27


Low Severity ____________________________________________________________________ 28

L-01 Potentially Incorrect maxFlashLoan Amount When Using ERC20FlashMint And ERC20Capped Together 28

L-02 Context Contract Is Not Used 29

L-03 ERC2771Forwarder Must Not Hold Token Approvals 30

L-04 Error-prone Failure Semantics of verify in ERC2771Forwarder 30

L-05 Inconsistent Solidity Version Used in ERC1967Utils 31

L-06 Lack of Access Control and Flexibility in VestingWallet's Release Methods 31

L-07 Potentially Trapped ETH in ERC2771Forwarder 32

L-08 Reentrancy Risk in ERC1967Utils._setBeacon 33

L-09 Risk of Division by Zero in VestingWallet 33

L-10 Risk of Ownership Loss Due to Single-Step Ownership Transfer in UpgradeableBeacon and ProxyAdmin 34

L-11 ERC-165 Check Is Too Permissive 34

L-12 address(0) Is Allowed as the Initial Owner 35


Contracts 5.0 Release − Table of Contents − 2


L-13 Enumeration Methods Are Unnecessarily Limited 35

L-14 Proposal Front-Running Protection Fails Silently 36

L-15 TimelockController Allows Sending ETH by Default 36

L-16 Unintuitive and Inconsistent Proposal State Timing 37

L-17 Overloaded Error Messages 37


Notes & Additional Information ____________________________________________________ 38

N-01 Allowances And Approval Inconsistencies - Phase 1 38

N-02 Gas Optimization - Phase 1 38

N-03 Contracts Are Not abstract 39

N-04 EIP-3156 Inconsistency 39

N-05 Missing Interface 40

N-06 Missing Or Incorrect Docstrings - Phase 1 40

N-07 Naming Suggestions - Phase 1 42

N-08 Outdated Solidity Version 42

N-09 Uncommented Sensitive Operation 42

N-10 Unused Custom Errors 43

N-11 Unused or Duplicated Imports And Extensions - Phase 1 43

N-12 Outdated Version in Docstrings 44

N-13 Event Definition Improvement Suggestions 44

N-14 Code Style Suggestions - Phase 1 44

N-15 Inadequate Documentation for Reverting Payable Upgrades with Empty Data 45

N-16 Incompatibility of VestingWallet with Rebasing Tokens 46

N-17 Lack of Event Emission - Phase 2 47

N-18 Lack of Inclusion of a "Vesting Cliff" Feature 47

N-19 Missing Or Incorrect Docstrings - Phase 2 48

N-20 Naming Suggestions - Phase 2 50

N-21 Trusted Forwarder Address Lacks External Visibility 50

N-22 Unused Named Return Variables - Phase 2 51

N-23 Code Style Suggestions - Phase 3 51

N-24 Some ERC-721 Features Might Be Atomically Reset 52

N-25 Missing or Incorrect Docstrings - Phase 3 52

N-26 Lack of Event Emission - Phase 3 53

N-27 Repeated Code 54

N-28 Hardcoded Magic Constant 54

N-29 _setTokenURI Does Not Allow Setting URI for Non-Existing Tokens 54

N-30 Default Handling Contract of the DEFAULT_ADMIN_ROLE Is Complex 55

N-31 Unused Named Return Variables - Phase 3 55

N-32 Allowance and Approval Inconsistencies - Phase 3 56

N-33 Confusing Revert Messages Due to Underflow 56

N-34 Missing or Incorrect Docstrings - Phase 4 57

N-35 Refactor AccessManager Data Structures to Reduce Design Complexity 59

N-36 Unused Variables 59

N-37 Inconsistent Use of Named Return Variables - Phase 4 60

N-38 Missing Zero Address Check in AccessManager Constructor 60

N-39 Use of Custom Errors 60

N-40 Code Style Suggestions - Phase 4 61

N-41 TODO Comments 61


Contracts 5.0 Release − Table of Contents − 3


N-42 Gas Optimization - Phase 4 62

N-43 Typographical Errors - Phase 4 62

N-44 Mismatch Between Contract and Interface 63

N-45 Naming Suggestions - Phase 4 63

N-46 Missing or Incorrect Docstrings - Phase 5 64

N-47 Gas Optimizations - Phase 5 66

N-48 Inconsistent Use of Named Return Variables - Phase 5 66

N-49 Unused Import - Phase 5 67

N-50 Inconsistent Solidity Version Used in GovernorStorage 67

N-51 Long Comment Lines 67

N-52 Unused Named Return Variables - Phase 5 67

N-53 Typographical Errors - Phase 5 68

N-54 Naming Suggestions - Phase 5 69

N-55 Extraneous Code 70


Client-Reported _________________________________________________________________ 70

CR-01 Inconsistent Use of Hooks 70

CR-02 Wrong Visibility for a Public Constant 71

CR-03 Inconsistent nonce Enumeration in AccessManager 71

CR-04 AccessManager's onlyAuthorized Functions Cannot Be Executed Through relay() 71


Recommendations _______________________________________________________________ 73

[R01] Features and Design Suggestions 73

[R02] Overridable Functions Risk Classification 73

[R03] Testing and Fuzzing Opportunities - Phase 1 75

[R04] Inextensible Choice of Admin Address 75

[R05] Compatibility with EVM Chains Other Than Ethereum 75

[R06] Tokens Might Get Stuck in the Contract 77

[R07] Testing and Fuzzing Opportunities - Phase 4 78

[R08] Overlapping Operation of Multiple Delay Mechanisms in AccessManager 78


Conclusion  ______________________________________________________________________ 80


Contracts 5.0 Release − Table of Contents − 4


## **Summary**

**Type** Library


**Timeline** From 2023-06-05
To 2023-09-15


**Languages** Solidity



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


3 (1 resolved)


11 (7 resolved, 2 partially resolved)



**Total Issues** 90 (49 resolved, 16 partially resolved)



**Low Severity Issues** 17 (8 resolved, 2 partially resolved)



**Notes & Additional**
**Information**


**Client-Reported**
**Issues**



55 (29 resolved, 12 partially resolved)


4 (4 resolved)



Contracts 5.0 Release − Summary − 5


## **Scope**

**Phase 1**


We audited the OpenZeppelin/openzeppelin-contracts repository at commit <u>[99a4cfc](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8)</u> and the

following files were in scope:

```
contracts
├── ERC20
│  ├── ERC20.sol
│  ├── IERC20.sol
│  ├── extensions
│  │  ├── ERC20Burnable.sol
│  │  ├── ERC20Capped.sol
│  │  ├── ERC20FlashMint.sol
│  │  ├── ERC20Pausable.sol
│  │  ├── ERC20Permit.sol
│  │  ├── ERC20Votes.sol
│  │  ├── ERC20Wrapper.sol
│  │  ├── ERC4626.sol
│  │  ├── IERC20Metadata.sol
│  │  └── IERC20Permit.sol
│  └── utils
│    └── SafeERC20.sol
├── ERC1155
│  ├── ERC1155.sol
│  ├── IERC1155.sol
│  ├── IERC1155Receiver.sol
│  ├── extensions
│  │  ├── ERC1155Burnable.sol
│  │  ├── ERC1155Pausable.sol
│  │  ├── ERC1155Supply.sol
│  │  ├── ERC1155URIStorage.sol
│  │  └── IERC1155MetadataURI.sol
│  └── utils
│    ├── ERC1155Holder.sol
│    └── ERC1155Receiver.sol
└── utils
├── StorageSlot.sol
└── structs
└── Checkpoints.sol

```

The following contracts were audited at the <u>[99a4cfc](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8)</u> commit but only the changes between

versions 5.0 and 4.9 were in scope:

```
contracts
└── utils
└── math

```

Contracts 5.0 Release − Scope − 6


```
├── Safecast.sol
└── Math.sol

```

**Phase 2**


We audited the OpenZeppelin/openzeppelin-contracts repository at commit <u>[8fff875](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/8fff875589443c607ac4ef2d201a6d8bec5a43c8)</u> and the

following files were in scope:

```
contracts
├── interfaces
│  ├── draft-IERC1822.sol
│  └── IERC1967.sol
├── proxy
│  ├── beacon
│  │  ├── BeaconProxy.sol
│  │  ├── IBeacon.sol
│  │  └── UpgradeableBeacon.sol
│  ├── ERC1967
│  │  ├── ERC1967Proxy.sol
│  │  └── ERC1967Utils.sol
│  ├── Proxy.sol
│  ├── transparent
│  │  ├── ProxyAdmin.sol
│  │  └── TransparentUpgradeableProxy.sol
│  └── utils
│    └── UUPSUpgradeable.sol
├── metatx
│  ├── ERC2771Context.sol
│  └── ERC2771Forwarder.sol
├── finance
│  └── VestingWallet.sol
└── utils
├── Address.sol
├── Context.sol
├── cryptography
│  └── EIP712.sol
└── Strings.sol

```

**Phase 3**


We audited the OpenZeppelin/openzeppelin-contracts repository at commit <u>[b027c35](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/b027c3541c03348767b62d45721eaa7d50f02b65)</u> and the

following files were in scope:

```
contracts
├── access
│  ├── AccessControl.sol
│  ├── AccessControlDefaultAdminRules.sol
│  ├── AccessControlEnumerable.sol
│  ├── Ownable.sol
│  └── Ownable2Step.sol
├── proxy

```

Contracts 5.0 Release − Scope − 7


```
│   └── Clones.sol
├── security
│   └── Pausable.sol
├── token
│  ├── common
│  │  └── ERC2981.sol
│  ├── ERC721
│  │  ├── ERC721.sol
│  │  ├── IERC721.sol
│  │  ├── IERC721Receiver.sol
│  │  ├── extensions
│  │  │  ├── ERC721Burnable.sol
│  │  │  ├── ERC721Consecutive.sol
│  │  │  ├── ERC721Enumerable.sol
│  │  │  ├── ERC721Pausable.sol
│  │  │  ├── ERC721Royalty.sol
│  │  │  ├── ERC721URIStorage.sol
│  │  │  ├── ERC721Votes.sol
│  │  │  ├── ERC721Wrapper.sol
│  │  │  ├── IERC721Enumerable.sol
│  │  │  └── IERC721Metadata.sol
│  │  └── utils
│  │    └── ERC721Holder.sol
└─── utils
└── cryptography
└── MessageHashUtils.sol

```

The following contracts were audited at the <u>[b027c35](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8)</u> commit but only the changes between

versions 5.0 and 4.9 were in scope:

```
contracts
└─── utils
├── Arrays.sol
├── Base64.sol
├── Create2.sol
├── cryptography
│  └── ECDSA.sol
├── introspection
│  ├── ERC165.sol
│  ├── ERC165Checker.sol
│  └── IERC165.sol
└── structs
└── BitMaps.sol

```

**Phase 4**


We audited the OpenZeppelin/openzeppelin-contracts repository at commit <u>[b5a3e69](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/b5a3e693e7eeca8d5f608460fd8beeee8e332b03)</u> and the

following files were in scope:

```
contracts
├── access
│  └── manager

```

Contracts 5.0 Release − Scope − 8


```
│    ├── AccessManaged.sol
│    ├── AccessManager.sol
│    ├── IAccessManager.sol
│    ├── IAccessManaged.sol
│    └── IAuthority.sol
└── utils
└── types
└── Time.sol

```

The following contracts were audited at the <u>[b5a3e69](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/b5a3e693e7eeca8d5f608460fd8beeee8e332b03)</u> commit but only the changes between

versions 5.0 and 4.9 were in scope:

```
contracts
└── utils
└── math
│  └── SignedMath.sol
├── structs
│  ├── EnumerableMap.sol
│  └── EnumerableSet.sol
└── Multicall.sol

```

**Phase 5**


We audited the OpenZeppelin/openzeppelin-contracts repository at commit <u>[adbb8c9](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/adbb8c9d27e77452bc2253397908d3d044808e62)</u> and the

following files were in scope:

```
contracts
├── proxy
│   └── utils
│      └── Initializable.sol
├── security
│   └── ReentrancyGuard.sol
├── governance
│  ├── extensions
│  │  ├── GovernorCountingSimple.sol
│  │  ├── GovernorSettings.sol
│  │  ├── GovernorStorage.sol
│  │  ├── GovernorTimelockAccess.sol
│  │  └── GovernorTimelockControl.sol
│  ├── Governor.sol
│  ├── TimelockController.sol
│  └── utils
│    └── Votes.sol
└── utils
├── cryptography
│  └── MerkleProof.sol
└── structs
└── DoubleEndedQueue.sol

```

The following contracts were audited at the <u>[adbb8c9](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/adbb8c9d27e77452bc2253397908d3d044808e62)</u> commit but only the changes between

versions 5.0 and 4.9 were in scope:


Contracts 5.0 Release − Scope − 9


```
contracts
└── governance
└── extensions
├── GovernorVotes.sol
├── GovernorVotesQuorumFraction.sol
├── GoverorPreventLateQuorum.sol
└── GovernorTimelockCompound.sol

## **Overview**

```

The major version 5.0 of this library brings many breaking and important changes. Before

diving into each phase's changeset description, the general applicable changes include:


   - A switch <u>[from](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/utils/Address.sol#L65)</u> `require` statements <u>[to](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/utils/Address.sol#L13)</u> custom errors instead. Custom errors have been

introduced with the latest Solidity versions and are a natural evolution of error handling

within Solidity. `require` statements had to be managed with custom strings to

describe the error, introducing difficulties and error-prone techniques; custom errors on

the contrary are more explicit and easy to handle, making the code more readable and

robust. The team is also behind the draft of <u>[EIP-6093](https://eips.ethereum.org/EIPS/eip-6093)</u> in an effort to standardize custom

errors being used for common token implementations. Finally, custom errors appear to

be more convenient in terms of gas costs as one can read from a <u>[benchmark test](https://ethereum-magicians.org/t/eip-6093-custom-errors-for-commonly-used-tokens/12043/3)</u> that

the team performed.

   - <u>[Updated](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/proxy/utils/UUPSUpgradeable.sol#L4)</u> the Solidity version to 0.8.20. This sparked a discussion about the compatibility

with chains that lack adoption of the `PUSH0` opcode. You can read more about the

needs and consequences <u>[here.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4489)</u>

   - Some contracts were removed, like <u>`[Counters](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/utils/Counters.sol)`</u>, and some others have been added

such as <u>`[Nonces](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/utils/Nonces.sol)`</u> .

   - The code style went under a refactor that greatly improved consistency across all files.

Some examples are contracts that had to be marked as abstract when they were not,

contracts that were a good fit to be defined as library instead and modifiers that now are

consistently using internal functions instead of having the logic directly within their

definition.


There is a more detailed and technical changelog <u>[here. Below is a brief breakdown of the focus](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v5.0/CHANGELOG.md)</u>

and the corresponding set of changes for each individual phase.


In Phase 1, we focused mainly on token standards <u>[ERC-20](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/ERC20.sol)</u> and <u>[ERC-1155. The main changes](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/ERC1155.sol)</u>

are in the inner mechanics. The <u>`[_update](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/ERC20.sol#L241)`</u> internal function is now in charge of summarizing

the contracts' token accounting logic when it comes to transfers, minting/burning and


Contracts 5.0 Release − Overview − 10


allowances checks. The `_update` function replaced many internal functions that were

<u>[previously used](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC20/ERC20.sol#L222-L293)</u> to handle the same logic. With this change, the team believes in better

maintenance of the code while having a more modular and compact code. Moreover, the

<u>[legacy transfer hooks](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC20/ERC20.sol#L348-L364)</u> are now removed and replaced by <u>[overrides of the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20Capped.sol#L45)</u> <u>`[_update](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20Capped.sol#L45)`</u> function,

making custom integrations easier to perform.


In Phase 2, we switched the focus to proxies and their related contracts. One change is that

<u>`[ERC1967Upgrade](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/proxy/ERC1967/ERC1967Upgrade.sol)`</u> is no longer an abstract contract, and is now a library, renamed to

<u>`[ERC1967Utils](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/ERC1967/ERC1967Utils.sol)`</u> . Apart from this, there is an important change in design in which the

`TransparentUpgradeableProxy` now <u>[deploys its own](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/transparent/TransparentUpgradeableProxy.sol#L75)</u> `ProxyAdmin`, assigning it to an

<u>`[immutable](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/transparent/TransparentUpgradeableProxy.sol#L63)`</u> <u>`[_admin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/transparent/TransparentUpgradeableProxy.sol#L63)`</u> variable so that there will be a new proxy admin for every transparent

proxy with no possibility to change it. The same thing occurs with beacons, which are

<u>[immutable](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/beacon/BeaconProxy.sol#L25)</u> and cannot be changed once set.


Phase 3 was about auditing ERC-721 and some basic access contracts in preparation for a big

change in Phase 4. The ERC-721 part was similar to Phase 1, where the most important

changes are the use of the <u>`[_update](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/ERC721.sol#L247)`</u> function and the removal of before and after hooks.

Notice that even if before and after transfer hooks were removed, the <u>[check on ERC-721](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/ERC721.sol#L448)</u>

<u>[received](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/ERC721.sol#L448)</u> is still supported, given the fact that it serves an explicit and separate security

concern. In this phase, we also inspected the `Ownable` contract, where a notable change is

that the contract does not <u>default to</u> <u>`[_msgSender](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/access/Ownable.sol#L28)`</u> <u>[as the initial owner anymore, and an](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/access/Ownable.sol#L28)</u>

<u>`[initialOwner](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/access/Ownable.sol#L38)`</u> <u>parameter</u> must be specified upon construction.


In Phase 4, we moved to one of the main features of this new major version: the

<u>`[AccessManager](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol)`</u> contract. The `AccessManager` can be seen as a more sophisticated

access management solution combining and extending the concepts of `AccessControl` and

`TimelockController` . Some of its features are:


   - Access management rules are defined per function selector for each managed contract.

The rules are defined and handled altogether in the `AccessManager` contract for any

set of contracts.

   - Each restricted function <u>[is linked](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L456)</u> to a group allowed to access it. A group essentially

defines a role. Members <u>[are granted access](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L271)</u> to a group by the group's admin. The group

linked to a function can be changed by an authorized entity.

   - Each member is configured with two kinds of delays:

    - A <u>[grant delay, which is the time period that needs to pass from the time point](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L353)</u>

when the member is granted access until the time point that the member becomes

active. All members of a group share the same grant delay.

    - An <u>[execution delay, which is a timelock-like delay defining the time period that](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L354)</u>

needs to pass from when the member schedules the call to a restricted function


Contracts 5.0 Release − Overview − 11


until the time point from which on the member is allowed to actually call that

function.

- <u>[Delay mechanisms](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L486)</u> are defined for the administration tasks within the `AccessManager`



contract. All sensitive operations (e.g., setting the grant delay for a group, changing a

group's admin, changing the group linked to a restricted function) are subject to a delay

mechanism.

   - The <u>[relay](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L620)</u> functionality allows deployed `Ownable` contracts to migrate to an

`AccessManager` instance by transferring the ownership to `AccessManager` and

relaying the restricted functions calls through it (and similarly for deployed

`AccessControl` contracts).


While it can be difficult to approach because of the increased complexity, the

`AccessManager` provides a more flexible management system residing in a unique central

contract, while featuring relays and administrations in an entire system. Additionally, during this

phase, the <u>`[Time](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/utils/types/Time.sol)`</u> <u>[contract](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/utils/types/Time.sol)</u> has been audited. This new contract defines a `Delay` type to

represent duration (delay) that can be configured to change value at a given time point

automatically.


Finally, in Phase 5, we focused on the <u>[governance module. The governance module has been](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance)</u>

modified to integrate a new <u>`[GovernorTimelockAccess](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorTimelockAccess.sol)`</u> extension contract, to enable

compatibility with `AccessManaged` contracts. The added value here is that proposal targets

that are subject to `AccessManager` delays do not require separate proposals for scheduling

and executing the target. In addition, the `GovernorStorage` extension contract has been

introduced, which enables storing the proposals' details in storage as well as proposal

enumerability.


**_Update:_** _During the fix review of the different phases, the contracts team changed the code to_

_adopt some more explicit naming conventions. In particular,_ _`AccessManager`_ _'s_ _`groups`_ _are_

_now called_ _`roles`_ _while the_ _`relay`_ _function is now renamed in_ _`execute`_ _. We keep the old_

_naming within this report to avoid confusing the reader and to keep consistency with the issues_

_descriptions. In addition, as part of the_ _<u>[pull request #4644](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4644)</u>_ _the code has been slightly refactored_

_to be more strict in regards to valid actions scheduling._


Contracts 5.0 Release − Overview − 12


## **Security Considerations** **and Threat Model**

As security researchers, our focus has primarily been on auditing protocols within the

blockchain ecosystem, ensuring their robustness and resilience against potential

vulnerabilities. However, in recent times, this scope has expanded to include the examination

of libraries - foundational code that serves as a basis for developers to extend and build upon.

With this new area of investigation, we have come to realize that the traditional severity

definitions, which were initially designed for protocols, may not fully cover the vulnerabilities

that libraries can introduce.


In libraries, vulnerabilities can take on different forms. First, there are explicit flaws where

specific parts of the library, such as contracts or functions, do not perform as intended. These

issues can directly impact the security of the library and, by extension, the protocols built upon

it.


However, challenges arise with implicit vulnerabilities. While the individual components of the

library may work properly in isolation, combining multiple contracts or engaging in certain

actions, such as overriding virtual functions, can unexpectedly introduce security risks. This

suggests that the vulnerability lies not with the developer's implementation but rather with the

design of the library itself. You can read about those at the end of this report.


During this audit, our approach has been to try to simulate use cases and classic user patterns

and mistakes when it comes to developing smart contracts. While we approached the

codebase from many different angles, we did not lose the focus on assessing the correctness

of the code itself. Finally, the OpenZeppelin Contracts library has been a pillar for many

projects in the past and many more yet to come, and for this, we also tried to bring

recommendations and areas of research and study for the team to bring its adoption and

security even further.


About severity classifications, we used this as a reference guide:


    - _critical_ : The issue significantly jeopardizes the security of the protocol built upon the

library, leading to a high risk of compromising sensitive information, causing substantial

financial losses, or severely damaging the protocol's reputation.


Contracts 5.0 Release − Security Considerations and Threat Model − 13


    - _high_ : The issue poses a substantial risk to the security of the protocol built upon the

library, potentially compromising sensitive information, causing temporary disruptions, or

resulting in moderate financial losses.

    - _medium_ : The issue presents a moderate risk to the security of the protocol built upon the

library, potentially affecting a subset of users, having a moderate financial impact, or

having a workaround.

    - _low_ : The issue represents a relatively minor risk to the security of the protocol built upon

the library, typically with limited or infrequent exploitation potential. It may involve non
security related concerns worth noting to enhance the codebase's quality.

    - _note & additional info_ : This category encompasses non-security relevant issues that are

worth noting to improve the codebase's overall quality, irrespective of their direct impact

on the security of the protocol.


Finally, the methodology we adopted also included pre-audit threat modelling sessions

between the security services team and the contracts team to investigate particular angles of

attack on the contracts and create priorities about what to focus on when auditing specific

contracts. These have been fruitful conversations where the auditors had the opportunity to

learn the motivations behind particular code designs and patterns. The contracts team was

provided with increased visibility over the typical attack vectors and scenarios that are

prepared when assessing the security of the contracts.


Contracts 5.0 Release − Security Considerations and Threat Model − 14


## **High Severity**

### **H-01 Potential Inaccuracies in Voting Unit** **Accounting When Overriding the** **ERC20Votes#_getVotingUnits Function's** **Formula**

The <u>`[_getVotingUnits](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20Votes.sol#L58)`</u> <u>function</u> in the `ERC20Votes` contract determines the voting power

of an account, typically based on its token balance. This function is designed to be overridden,

allowing developers to modify the voting power system, such as implementing quadratic

voting.


However, if this function is overridden and the formula is altered, there is a potential issue with

the accounting of voting units during token transfers, particularly when the token holder

delegates their votes to themselves or another address.


The problem arises because the <u>`[_update](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20Votes.sol#L43)`</u> function in the `ERC20Votes` contract invokes the

<u>`[_transferVotingUnits](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20Votes.sol#L52)`</u> function from the `Votes` contract, passing the transferred token

amount as a parameter instead of the corresponding voting units that these tokens represent

for either the `from` address or its delegate.


Let's consider a quadratic voting system as an example. Suppose Alice holds 100 tokens and

delegates her voting power to Bob. In this scenario, Bob would possess 10,000 voting power

units (100^2 = 10,000).


Now, let's assume Alice transfers her 100 tokens to Charlie, who delegates tokens to himself.

During the transfer:


   - The voting power transferred from Alice to Charlie would be 100 instead of 10,000. This

discrepancy occurs because <u>[line 112](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20Votes.sol#L52)</u> uses the raw transferred token amount instead of

the underlying voting units. As a result, Bob would have 9,900 voting power units, while

Charlie would have 100 voting power units, leading to an inaccurate distribution.

   - The <u>`[_totalCheckpoints](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/governance/utils/Votes.sol#L182-L187)`</u> variable, which tracks the total voting power units over time,

would also yield incorrect calculations as it utilizes the raw token amount instead of the

underlying voting units.


Contracts 5.0 Release − High Severity − 15


Furthermore, if Charlie re-delegates his tokens to Bob, Bob's new voting power would consist

of the remaining 9,900 voting units plus an additional 10,000 voting units, resulting in a total of

19,900 voting power units. This behavior arises because the <u>`[_delegate](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/governance/utils/Votes.sol#L174)`</u> <u>function</u> in the

`Votes` contract correctly utilizes the `_getVotingUnits` function to calculate the voting

power units to be transferred.


Exploiting this vulnerability, an attacker could artificially inflate their voting power and

potentially seize control of the governance by creating and voting for proposals.


When calling the <u>`[_transferVotingUnits](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20Votes.sol#L52)`</u> <u>function</u> in the `_update` function of the

`ERC20Votes` contract, consider sending as the third parameter

`_getVotingUnits(account)` instead of `amount`, and also changing the `from` and `to` as

parameters, send `delegates(from)` and `delegates(to)` respectively.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


_The suggestion in this issue doesn't work, because the parameter to_

_`_transferVotingUnits`_ _in_ _`_update`_ _needs to be the amount being transferred, not_

_the total voting units of one of the accounts. We considered an alternative fix adding a_

_`_toVotingUnits(uint256)`_ _function to convert from token amounts to voting units_

_that could be overridden if necessary. However, we found that overriding this function is_

_also error-prone, especially if implementing something complex like quadratic voting,_

_but even in simpler functions due to the potential for rounding errors. In the end, we_

_have decided to just add a comment warning about the potential error._

### **H-02 Non-Compliance of ERC2771Context With** **ERC Could Lead to Incorrect Address Extraction**


The implementation of the <u>`[_msgSender](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/metatx/ERC2771Context.sol#L24-L34)`</u> function in `ERC2771Context` does not adhere to

the specifications laid out by the <u>[EIP. Specifically, it fails to retain the original](https://eips.ethereum.org/EIPS/eip-2771#extracting-the-transaction-signer-address)</u> `msg.sender`

when `msg.data` is shorter than 20 bytes.


In cases where `msg.data` is less than 20 bytes, the extracted address becomes

`address(0)` . This is due to the EVM reading out-of-bounds calldata as <u>[zeros. Consequently,](https://www.evm.codes/#35)</u>

`address(0)` will be returned as the `msg.sender` .


Coincidentally, due to a separate vulnerability, if the <u>`[refundReceiver](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/metatx/ERC2771Forwarder.sol#L179)`</u> <u>in the forwarder's</u>

<u>`[executeBatch](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/metatx/ERC2771Forwarder.sol#L179)`</u> method is set to be the receiver contract, it will result in a call that is also not

compliant with the EIP, since it does not append the sender's address to the end of the

calldata.


Contracts 5.0 Release − High Severity − 16


In combination with the non-compliant address extraction, if both contracts are used together,

and the receiver contract implements a fallback or a receive method that makes use of the

`_msgSender()` method, the contract will interpret the sender as `address(0)` . This can

result in unexpected consequences, as this address is often used as a default or burn address,

and is presumed to be an impossible sender. For example, tokens explicitly or implicitly owned

by `address(0)` or contracts with revoked ownership may be exploited. The high likelihood of

this occurring, despite the multiple prerequisites, is demonstrated by the fact that both of the

needed vulnerabilities co-exist in this codebase.


Consider adhering to the original specifications and returning the original `msg.sender` when

`msg.data` is less than 20 bytes.


**_Update:_** _Resolved in_ _<u>[pull request #4481](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4481)</u>_ _at commit_ _<u>[7ec712b, pull request #4484](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/7ec712baa50525353360a43700f953912bebef9c)</u>_ _at commit_

_<u>[e4435ee. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/e4435eed757d4309436b1e06608e97b6d6e2fdb5)</u>_


_Addressed in two steps:_


       - _Default_ `_msgSender()` _to the original_ `msg.sender` _if the calldata length is less_

_than_ 20 _bytes_ .


       - _Default_ `_msgData()` _to the original_ _`msg.data`_ _if the calldata length is less than_

_20 bytes_ . _This was done so that both_ _`_msgData()`_ _and_ _`_msgSender()`_ _are_

_consistently used together and not partially overriding the data but not the sender_

_in some cases._

### **H-03 Risk of Failed L2 and Sidechain** **Deployments with Solidity Version 0.8.20**


The codebase has been <u>[updated](https://github.com/OpenZeppelin/openzeppelin-contracts/compare/v4.9.3...audit/2023-08-01)</u> to Solidity pragma `^0.8.20` . With this version, <u>[Shanghai](https://github.com/ethereum/solidity/releases/tag/v0.8.20)</u>

<u>[becomes the default EVM version](https://github.com/ethereum/solidity/releases/tag/v0.8.20)</u> employed by the Solidity compiler and <u>[hardhat. This may](https://hardhat.org/hardhat-runner/docs/guides/compile-contracts#configuring-the-compiler)</u>

pose an issue for projects deploying to L2s and non-Ethereum-mainnet chains, most of which

don't support Shanghai EVM. Specifically, the compiler will generate bytecode that includes

<u>`[push0](https://eips.ethereum.org/EIPS/eip-3855)`</u>, which will cause deployment failures on these chains.


Since projects will have to configure their project to use a non-default `evmVersion`

proactively, a significant number of projects may overlook this new requirement when using the

new library version. Crucially, this problem is likely to go unnoticed until the deployment stage.

During deployment, most transactions are likely to fail due to the invalid opcode. Besides failed

deployments, there's a risk of projects transferring funds or ownership to an address presumed

to be deployed, but which contains empty code due to the failed deployment. This is because


Contracts 5.0 Release − High Severity − 17


the failed deployment transaction will still carry a non-empty `contractAddress` field, and

that address will still accept function calls and native token transfers.


While the impact of a failed deployment would be limited in most cases, it will be a disruptive

event for a project, requiring investigation and causing deployment delays. Additionally, the

impact on the contracts library's reputation could be significant if multiple projects encounter

this issue. Given its high likelihood and medium impact, this problem's severity appears high.


Consider maintaining the use of `^0.8.19` until the community is well aware of the risks and

tooling has improved to mitigate these risks for most projects.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


_We are using ^0.8.20 because we need compiler features that were launched in 0.8.20._

_We recommended that Hardhat default its_ _`evmVersion`_ _to Paris and they have_

_[implemented it, to be included with the next release. Foundry already has the same](https://github.com/NomicFoundation/hardhat/pull/4336)_

_default. With this change we feel comfortable releasing with pragma ^0.8.20._

## **Medium Severity**

### **M-01 Potential Reentrancy in ERC1155._update** **Function**


When the <u>`[_update](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/ERC1155.sol#L157)`</u> function of the `ERC1155` contract is triggered either by a transfer or a

mint/burn, the last action performed in the execution is <u>[acceptances checks, where the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/ERC1155.sol#L189-L201)</u>

execution calls the `to` recipient doing an external call in the case it's not an EOA and it's

effectively a contract.


This means that the recipient contract must implement <u>`[IERC1155Receiver](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/IERC1155Receiver.sol)`</u> and answer to

the external call properly to let execution flow without errors. If the recipient happens to be a

contract that either fails in returning the right data or just fails in returning any data, then the

`_update` execution will revert.


This is dictated by the <u>[EIP defnitioni](https://eips.ethereum.org/EIPS/eip-1155#erc-1155-token-receiver)</u> <u>. However, when dealing with a smart contract library that</u>

makes extensibility the most important feature, one should take care of this external call and

avoid falling into the error of failing at the checks-effects-interactions pattern.


Concretely if a contract extends from `ERC1155` and overrides the `_update` function in a way

that it performs state updates after the `super._update` call, the external call might be used


Contracts 5.0 Release − Medium Severity − 18


maliciously to reenter the contract before those state updates are performed, violating the

mentioned security pattern.


Consider informing the users in the docstrings of the limitation. One mitigation might be

isolating the acceptances checks and so the external call, separately from the `_update`

functions so that implementers that override `_update` have the flexibility to perform those

external calls at the very end of their execution.


**_Update:_** _Resolved in_ _<u>[pull request #4398. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4398)</u>_


_We have split_ _`_update`_ _into two parts:_


_1)_ _`_update`_ _contains balance update logic._


_2)_ _`_updateWithAcceptanceCheck`_ _invokes_ _`_update`_ _and invokes the_ _`receive`_

_hook. Overrides to_ _`_update`_ _are no longer vulnerable to reentrancy._

### **M-02 Unhandled Silent Failures**


There are some cases in the code base where failures are not handled early nor routed to some

explicit error message. This means that execution can unexpectedly stop, finally reverting.


   - In the <u>`[ERC1155Supply._update](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/extensions/ERC1155Supply.sol#L47)`</u> function, the check that `ids` and `amounts` have

the same length is performed in the <u>`[super._update](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/ERC1155.sol#L164)`</u> <u>[call](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/extensions/ERC1155Supply.sol#L80)</u> but not before arrays are

being <u>[iterated](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/extensions/ERC1155Supply.sol#L56)</u> once. If there is a length mismatch there is a high chance that the `for`

loop will end up accessing bad data locations and the transaction will revert.

   - Again in the <u>`[ERC1155Supply._update](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/extensions/ERC1155Supply.sol#L47)`</u> function, the user input parameter <u>`[amounts](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/extensions/ERC1155Supply.sol#L51)`</u>

is <u>[deducted](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/extensions/ERC1155Supply.sol#L69)</u> from `_totalSupply[id]` without any previous balance check, meaning

that the subtraction can actually overflow, reverting the transaction. The same happens

in the <u>`[increaseAllowance](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/ERC20.sol#L184)`</u> function of `ERC20` and in the

<u>`[safeIncreaseAllowance](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/utils/SafeERC20.sol#L59)`</u> of `SafeERC20` .


Following the "fail early and loudly" principle, consider including specific and informative error
handling structures to avoid unexpected failures.


**_Update:_** _Resolved in_ _<u>[pull request #4398.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4398)</u>_


Contracts 5.0 Release − Medium Severity − 19


### **M-03 Lack of Context Usage**

Line <u>[115](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20FlashMint.sol#L115)</u> of `ERC20FlashMint` uses `msg.sender` instead of the `_msgSender` function to

get the message's sender, even though the docstrings of the `_msgSender` function say:


Provides information about the current execution context, including the sender of the

transaction and its data. While these are generally available via msg.sender and

msg.data, they should not be accessed in such a direct manner, since when dealing

with meta-transactions the account sending and paying for execution may not be the

actual sender (as far as an application is concerned).


This effectively prevents the use of such a contract with meta transactions (additionally not

adhering to the EIP) since `msg.sender` is taken as `initiator` while it might just be the

trusted forwarder of a meta transaction.


In the worst-case scenario, the `receiver` (or Borrower) implementation is the <u>[one](https://eips.ethereum.org/EIPS/eip-3156#implementation)</u> suggested

by the flash loan EIP, and in the case of a meta transaction, the transaction will revert because

the `msg.sender` will not be the `receiver` itself.


Consider fixing it using the `_msgSender` function. Alternatively, consider adding a comment

explaining why `msg.sender` is used instead of `_msgSender`, to avoid contradicting the

implementation of this function with the documentation provided in the `Context` contract.


**_Update:_** _Resolved in_ _<u>[pull request #4398.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4398)</u>_

### **M-04 Tokens Might Get Stuck in the Contract -** **Phase 1**


There are some places in the codebase where without any user custom implementation, the

library leaves open the doors for `ERC20` tokens to get stuck inside the token contract itself.


The <u>`[ERC20Wrapper](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20Wrapper.sol)`</u> contract has a <u>`[depositFor](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20Wrapper.sol#L54)`</u> function that checks whether the `sender`

is `address(this)` or not but never checks whether the `account` parameter, to which

`ERC20Wrapper` tokens are minted, is the same `address(this)` or not. If it happens to be

`account == address(this)` then tokens are effectively stuck in the contract, as long as

the user doesn't create a custom implementation with a function that is capable of transferring

them out of the contract. Similarly, the <u>`[withdrawTo](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20Wrapper.sol#L67)`</u> function never checks the same when

doing the `safeTransfer` instruction. Since there's no assumption on what `underlying`

looks like, if the underlying token accepts self-transfers, an `ERC20Wrapper` `amount` of

tokens will be burned, while the same amount of underlying is not transferred anywhere else. In


Contracts 5.0 Release − Medium Severity − 20


this case, the situation can be recovered by the use of <u>`[_recover](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20Wrapper.sol#L77)`</u> which will mint again the

spread and bring back a 1:1 ratio between the two tokens.


Further, the `_recover` function itself allows the caller to send any stuck underlying tokens in

the contract to an account sent by parameter. This amount is calculated by checking the

difference between the contract's underlying amount and the wrapped token's total supply.

However, if there are underlying tokens that are stuck, if someone calls the `_recover`

function and provides the contract itself as a parameter (i.e., the `ERC20Wrapped` contract),

then the total supply of the underlying token will have again a 1:1 ratio with the

`ERC20Wrapped` contract, and those funds also will get stuck.


The same exact issue happens with `ERC20FlashMint`, where the <u>[receiver of flash loan fees](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20FlashMint.sol#L118)</u>

is not checked to not be `address(this)`, eventually letting tokens be stuck within the

contract again.


Since the library doesn't provide built-in functions to sweep tokens stuck in the contract,

consider either creating a feature which is easy to plug in but that is optional or completely

avoiding such edge cases by implementing proper checks. Leaving the door open for tokens

to be stuck in the contract with no way to sweep them out is a common error, as we can see

from <u>[USDT, DAI](https://etherscan.io/address/0xdac17f958d2ee523a2206206994597c13d831ec7)</u> or many other token contracts which hold millions of dollars that are stuck

there forever.


**_Update:_** _Partially resolved in_ _<u>[pull request #4398. The](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4398)</u>_ _`flashFeeReceiver`_ _is still not checked_

_to not be_ _`address(this)`_ _. The OpenZeppelin Contracts team stated:_


_If the developer overrides_ _`flashFeeReceiver`_ _to return_ _`address(this)`_ _, we_

_assume they are doing that intentionally and do not want to disallow it._

### **M-05 ERC2771Forwarder May Call Receiver** **Without Appending Sender's Address**


If the <u>`[refundReceiver](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/metatx/ERC2771Forwarder.sol#L179)`</u> <u>[in the forwarder's](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/metatx/ERC2771Forwarder.sol#L179)</u> <u>`[executeBatch](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/metatx/ERC2771Forwarder.sol#L179)`</u> method is set to be the receiver

contract, it will result in a call that is not compliant with the <u>[EIP](https://eips.ethereum.org/EIPS/eip-2771)</u> since it does not append the

sender's address to the end of the calldata.


While the EIP specification prevents incorrect address extraction in this case, as the calldata

would be shorter than 20 bytes, this protection may not be implemented by all receivers. As a

result, if the forwarder is trusted by a receiver that does not apply the length rule, the receiver

may extract an incorrect sender address (e.g., `address(0)` ). This can result in unexpected

consequences, as this address is often used as a default or burn address, and is presumed to


Contracts 5.0 Release − Medium Severity − 21


be an impossible sender. For example, tokens explicitly or implicitly owned by `address(0)`,

or contracts with revoked ownership, may be exploited. The likelihood of this occurring,

despite the multiple prerequisites, is demonstrated by the existence of this receiver

vulnerability (described separately) in this codebase.


Consider making the call compliant with the EIP by appending the contract's own address to

the calldata as the ERC-2771 `msg.sender` . Alternatively, consider avoiding the need to make

an arbitrary destination call by utilizing WETH to make a token transfer to the refund recipient.


**_Update:_** _Acknowledged, not resolved but documented in_ _<u>[pull request #4502](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502)</u>_ _at commit_

_<u>[a06b352. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502/commits/a06b35260556899c6e5e01fe0e827b96449ef75e)</u>_


_We documented the expected behavior of a refund receiver when it trusts the forwarder._

_Our_ _`ERC2771Context`_ _implementation also properly handles this issue after solving_

_H-02._

### **M-06 Immutable Beneficiary Security Risks and** **Potential Loss of Funds**


The `VestingWallet` contract's beneficiary <u>[is immutable. However, during an extended](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/finance/VestingWallet.sol#L45)</u>

vesting period, the beneficiary might need to migrate to a different account, either due to a

suspected security breach of their private key or to bolster account security by shifting to a

hardware wallet, a multisig, or an account-abstracted wallet.


The likelihood of such scenarios increases with longer vesting schedules. Over time, the

beneficiary's security needs and the available wallet options are likely to evolve. Additionally,

the unvested tokens' value could potentially grow substantially, necessitating a more robust

security solution than initially available or justified.


In addition to the above, the contract does not provide a way for the beneficiary account to

prove its ability to control the contract before funds are transferred into it. As a result, if the

beneficiary's address is set inaccurately - be it to a contract address on another chain, an

address that requires aliasing on L2, or simply an erroneous EOA - funds forwarded to the

contract could be permanently lost. Although this could be attributed to a benefactor's error,

the probability of such a mistake is substantial, given the benefactor and beneficiary are

separate entities, and the benefactor is like to be managing multiple beneficiaries through

various communication channels.


Consider modifying the contract to inherit from `Ownable2Step`, assigning initial ownership **to**

**the benefactor** rather than the beneficiary - for instance, to `msg.sender` - and nominating


Contracts 5.0 Release − Medium Severity − 22


the beneficiary as the **pending owner** . At the same time, restrict access to `release` methods

to `onlyOwner`, which prevents a malicious `release` from frontrunning an ownership

transfer. Crucially, this also allows the benefactor to recover any funds sent to the contract if

the beneficiary fails to invoke `acceptOwnership` eventually.


It's worth noting that while explicit ownership and transferability facilitate over-the-counter

(OTC) trading of unvested tokens, this is also possible with the current immutable beneficiary

design, given it could be an ownable contract or even <u>[a counterfactual contract](https://docs.openzeppelin.com/cli/2.8/deploying-with-create2#interacting_with_the_counterfactual_contract)</u> if an EOA

check is included.


**_Update:_** _Partially resolved in_ _<u>[pull request #4508. The contract is now](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4508)</u>_ _`Ownable`_ _, with the_

_beneficiary as the owner. This allows to update the beneficiary, but still bears the risk of an_

_incorrect ownership transfer by either the benefactor when creating the contract, or by the_

_beneficiary when transferring ownership. Additionally, the release method remains publicly_

_callable. The OpenZeppelin Contracts team stated:_


_The risks involved with not allowing the_ _`beneficiary`_ _migration are acknowledged._

_However, we decided to use_ _`Ownable`_ _instead of_ _`Ownable2Step`_ _to keep the users'_

_right to choose which implementation to inherit from. We will work on a lightweight_

_version for_ _`Ownable`_ _with optional 2 steps._

### **M-07 Unnecessarily Complex and Limited Design** **of customRevert Callback**


Several methods in the `Address` [library (1, 2, 3, 4, 5, 6, 7) expect an argument of the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/utils/Address.sol#L80-L84)

`function() internal view customRevert` form. Users are thereby expected to define

a distinct reverting view method, and then pass it as a function callback, similar to the

procedure for <u>`[defaultRevert](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/utils/Address.sol#L219-L221)`</u> .


This design has three disadvantages:


1. The <u>["second" revert](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/utils/Address.sol#L234)</u> must be used to ensure that `customRevert` reverts, but it is not

sufficient. For example, a `RETURN` opcode in an assembly block can bypass the rest of

the Solidity code, including this second revert. Although an edge case, this will cause a

failed call to not revert, violating a core intent of the library's methods.

2. The design does not support the customizability of the custom errors, as it does not

allow passing parameters into the callback.

3. This interface is not a common pattern in Solidity, making it error-prone for users.


Contracts 5.0 Release − Medium Severity − 23


Instead, consider using `bytes memory revertData` as the input parameter for the

methods. This approach offers several benefits:


   - It guarantees a revert.

   - It maintains the option for a simple error.

   - It allows users to pass a parameterized error.

   - It enables users to conform to the string-based `revert` / `require` interface if that is

their preference.

   - It presents a simpler, less error-prone interface for users and eliminates the need to

define a special callback.

   - It reduces the bytecode size of the Address library by removing `defaultRevert` and

simplifying `_revert` 's implementation.


Example code:

```
error SomeError();
error RichError(uint value);

function userMethod() internal {
  bytes memory errData;

  // will look like `revert SomeError()`
  errData = abi.encodeWithSelector(SomeError.selector);

  // will look like `revert RichError(42)`
  errData = abi.encodeWithSelector(RichError.selector, (42));

  // will look like `revert("some error string")`
  errData = abi.encodeWithSignature("Error(string)", ("some error string"));

  Address.libraryMethod(errData);
}

...

function libraryMethod(bytes memory errData) internal pure {
  assembly {
     revert(add(32, errData), mload(errData))
  }
}

```

**_Update:_** _Resolved in_ _<u>[pull request #4502](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502)</u>_ _at commit_ _<u>[316c30c. The OpenZeppelin Contracts team](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502/commits/316c30ce3c889eca5eae059df6dcd37dbcc11620)</u>_

_stated:_


_We agree with the 3 disadvantages pointed out for the_ _`customRevert`_ _function pointer_

_alternative. However, the issue with the recommendation is that using memory in the_

_arguments leaves such memory allocated, which may cause unexpected issues in_

_contracts using this utility. We decided to remove the error customization alternatives_


Contracts 5.0 Release − Medium Severity − 24


_and we will reconsider adding them back if there is a language update that allows a less_

_restrictive customization mechanism._

### **M-08 State Updated in Modifiers May Be** **Corrupted**


The <u>`[ReentrancyGuard.nonReentrant](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/security/ReentrancyGuard.sol#L55)`</u>, <u>`[Initializable.initializer](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/utils/Initializable.sol#L93)`</u> and

<u>`[Initializable.reinitializer](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/utils/Initializable.sol#L127)`</u> modifiers can be abruptly interrupted if a `RETURN`

opcode in an assembly block is part of the wrapped method execution in `_;` .


In the case of `nonReentrant`, anything guarded by it will be permanently locked because

`_status` will remain `_ENTERED` .


In the case `Initializable`, subsequent calls to `reinitializer` will be locked, and also

`onlyInitializing` protection will be broken.


While a DoS due to broken `nonReentrant` and `reinitializer` may be noticed during

development, and possibly fixed by an upgrade, the impact of losing `onlyInitializing`

protection can be a total loss of funds and ownership of a contract. This is because a

dysfunctional `onlyInitializing` can easily be missed during development and allow the

contracts relying on it to become exploitable.


Consider using the `block.number` or part of its hash (either of which can be cast to be

smaller than a full slot) as flags instead of `bool` values. This way, the stored values can be

invalidated after loading if the current `block.number` does not match the loaded value. As a

result, any state corruption will have an effect on a single block only, rather than in perpetuity.

Additionally, consider adding a warning in the documentation against the usage of the

`RETURN` opcode in assembly blocks in code that is expected to be used with these modifiers.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


_Assembly returns are not part of our threat model. We think it would be unreasonable to_

_consider them because anything can break in that way._

### **M-09 Function withUpdateAt Does Not Behave** **as Expected**


The <u>`[Time.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/utils/types/Time.sol)`</u> <u>contract</u> provides a `Delay` type which holds a delay value that can be

configured to be updated automatically at a future timepoint. The delay value may be


Contracts 5.0 Release − Medium Severity − 25


expressed in terms of block timestamp or block number values. The contract also provides a

number of helper functions for manipulating the `Delay` type. The contract is supposed to treat

block timestamp and block-number-based delays <u>[equivalently, and every helper function is](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/utils/types/Time.sol#L64-L65)</u>

implemented in two separate variations in order to handle both delay units.


However, the functions `withUpdate` and `withUpdateAt` are not equivalent. More

specifically, <u>`[withUpdate](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/utils/types/Time.sol#L122-L123)`</u> <u>[guarantees that](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/utils/types/Time.sol#L122-L123)</u> in the case of decreasing the current delay value, it

cannot be updated instantly but rather its effect timepoint adheres to a `minSetback` period.

This is <u>[the expected behavior](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/utils/types/Time.sol#L49-L50)</u> according to the `Delay` docstring. On the contrary,

<u>`[withUpdateAt](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/utils/types/Time.sol#L112)`</u> <u>[immediately applies](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/utils/types/Time.sol#L112)</u> the provided effect timepoint for the new delay value.


Consider reimplementing the `withUpdateAt` function so that it behaves similarly to

`withUpdate` in order to avoid mistaken expectations that could lead to misuse of the library.


**_Update:_** _Resolved in_ _<u>[pull request #4555](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4555)</u>_ _and_ _<u>[pull request #4606. Note that the block-number-](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4606)</u>_

_based delays have been currently completely removed. The OpenZeppelin Contracts team_

_stated:_


_We removed_ _`withUpdateAt`_ _and kept only_ _`withUpdate`_ _. We also identified a_

_potential for misunderstanding about the meaning of a delay value when_ _`effect=0`_ _,_

_and to make this more straightforward we changed the "current value" and "pending_

_value" parameters into "value before" and "value after", where before/after are relative to_

_the effect timepoint. Note that_ _`effect=0`_ _does not have a special meaning as it used_

_to._

### **M-10 Proposal Execution Could Fail Due to Zero-** **Delayed AccessManaged Targets**


The `GovernorTimelockAccess` contract handles proposals that may contain calls to

restricted functions managed by an `AccessManager` instance ( <u>`[_manager](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorTimelockAccess.sol#L46)`</u> ). Upon a proposal

submission, the `_manager` 's <u>`[canCallWithDelay](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/access/manager/AuthorityUtils.sol#L13)`</u> <u>function</u> is called for each target which

returns a tuple `(bool allowed, uint32 delay)` denoting the respective access

restrictions, if any.


The `GovernorTimelockAccess` contract <u>[ignores the boolean return variable](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorTimelockAccess.sol#L253)</u> and only

considers the `delay` value to determine whether the target is managed by `_manager` . In

case of a non-zero delay, the target will be scheduled during the queuing step and later on

executed via the `_manager` 's <u>`[relay](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/access/manager/AccessManager.sol#L654)`</u> <u>[function. Otherwise, the target function will be called](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/access/manager/AccessManager.sol#L654)</u>

directly by the governor, as it is considered to be a target that is not managed by `_manager` .


Contracts 5.0 Release − Medium Severity − 26


Note that executing through the `_manager` 's `relay` function is necessary in cases where the

target is an <u>`[Ownable](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/access/manager/AccessManager.sol#L41-L45)`</u> <u>[contract that has transferred ownership to](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/access/manager/AccessManager.sol#L41-L45)</u> <u>`[_manager](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/access/manager/AccessManager.sol#L41-L45)`</u> (similarly for an

`AccessControl` contract). For code simplicity, the current implementation executes all

targets that are found to be managed by `_manager` through `relay` .


However, there is one case where `delay` is zero although the target is managed by the

`_manager` . This is when the `canCallWithDelay` function returns `(true, 0)`, which

means that the target is managed by `_manager` but the caller is authorized to call the target

without a delay.


Consider respecting this case in the implementation to prevent this scenario from failing

proposal executions.


**_Update:_** _Resolved in_ _<u>[pull request #4591. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4591)</u>_


_The contract now correctly considers the boolean return value. Additionally, there is a_

_mechanism to ignore it for a given target function to protect against potential DoS by_

_`AccessManager`_ _admins._

### **M-11 Contradictory _cancel Behavior**


In the `GovernorTimelockAccess` contract, the <u>`[_cancel](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorTimelockAccess.sol#L211)`</u> <u>function</u> handles

`AccessManager` -related logic to cancel previously scheduled operations. This internal

function is getting called from the <u>external</u> <u>`[cancel](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/Governor.sol#L470)`</u> <u>function</u> that allows users to cancel their

proposal while it is in a pending stage.


However, the internal function is attempting to cancel scheduled operations from the

`AccessManager`, which due to the pending state requirement cannot exist in the first place.

In the code, this is indicated through the <u>`[eta](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorTimelockAccess.sol#L219-L224)`</u> <u>[value](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorTimelockAccess.sol#L219-L224)</u> which would not be set until the proposal

has been queued after a successful voting.


In addition, note that `_cancel` handles the canceling of succeeded proposals and it would be

expected that only governance would have permission for such a sensitive action. Consider

documenting the risks in case this functionality is enabled when the `cancel` restrictions of the

`Governor` contract are overridden.


Furthermore, even if the logic would be overridden to allow to `_cancel` a queued proposal,

then the `_cancel` function can leave governance in a corrupted state. This can happen in the

event that an admin of the `AccessManager` cancels an operation directly. Then, if a user

wanted to cancel the whole proposal, the call <u>[to cancel for one of the operations](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorTimelockAccess.sol#L229-L232)</u> would fail and


Contracts 5.0 Release − Medium Severity − 27


revert the transaction. Hence, this semi-cancelled proposal could <u>[not be set to a canceled](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/Governor.sol#L495)</u>

<u>[state](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/Governor.sol#L495)</u> and the other scheduled operations in the `AccessManager` would eventually expire.


Consider clarifying what the intention of the internal `_cancel` function is and how it fits into

the overall functionality. Additionally, implement the `cancel` calls to the `AccessManager`

with the necessary exception handling for operations which have already been cancelled by

another party.


**_Update:_** _Resolved in_ _<u>[pull request #4591. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4591)</u>_


_The report is correct in that we are considering "if the logic would be overridden to allow_

_to_ _`_cancel`_ _a queued proposal", so even though in_ _`GovernorTimelockAccess`_ _, as_

_is, there is a part of the code that is not reachable, we want_ _`_cancel`_ _to be correct in_

_case it is exposed under different conditions. We have fixed the situation described in_

_the report about the corrupted governance state._

## **Low Severity**

### **L-01 Potentially Incorrect maxFlashLoan Amount** **When Using ERC20FlashMint And ERC20Capped** **Together**


The <u>`[maxFlashLoan](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20FlashMint.sol#L42)`</u> <u>function</u> in the `ERC20FlashLoan` contract determines the maximum

amount of tokens that can be flash-borrowed in a transaction. It is calculated as the difference

between the maximum value of a `uint256` variable and the `totalSupply` of the token.


In addition, the `ERC20Capped` contract allows developers to set an upper limit, or cap, on the

total number of tokens for an `ERC20` contract. During the minting process, the `totalSupply`

of the token <u>[cannot exceed the specified](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20Capped.sol#L51)</u> <u>`[cap](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20Capped.sol#L51)`</u>, which is defined at the time of contract

creation.


However, when using both the `ERC20FlashMint` contract and the `ERC20Capped` contract

together, the `maxFlashLoan` function does not take the `cap` into account. As a result:


   - Users who call the `maxFlashLoan` function may receive an incorrect maximum

amount. If they rely on the value returned by `maxFlashLoan` and request an amount

higher than the difference between the total supply and the `cap`, the transaction will fail

and revert.


Contracts 5.0 Release − Low Severity − 28


   - When calling the `flashLoan` function, <u>[lines 109-112](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20FlashMint.sol#L109-L112)</u> allow the code to proceed even if

the provided amount exceeds the cap.


Although this behavior does not pose a security risk because the <u>`[_mint](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20FlashMint.sol#L114)`</u> <u>[function](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20FlashMint.sol#L114)</u> called by

`flashMint` triggers the `_update` function in the `ERC20Capped` contract, which checks

that the new total supply does not exceed the `cap`, it can be confusing because the

`maxFlashLoan` function does not accurately represent the true maximum amount of tokens

that can be flash-borrowed.


Consider adding an internal virtual function within `maxFlashLoan` instead of relying solely on

`type(uint256).max` . By doing so, if the `ERC20Capped` contract is also used, users can

override the function to return `super.cap()` instead, ensuring that the maximum amount

reflects the capped value.


**_Update:_** _Partially resolved in_ _<u>[pull request #4398. The suggestion to add an internal function has](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4398)</u>_

_been discarded. However, the team acknowledged the potential issue and decided to improve_

_the docstrings. The OpenZeppelin Contracts team stated:_


_Added documentation to explain the potential issue and how to prevent it. We didn't_

_add an internal function because it would be no different than the existing_

_`maxFlashLoan`_ _function._

### **L-02 Context Contract Is Not Used**


The `TransparentUpgradeableProxy` <u>[uses](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/transparent/TransparentUpgradeableProxy.sol#L84)</u> plain `msg.sender` instead of the `Context`

contract. This makes it impossible to be used with meta transactions and is inconsistent with

the rest of the contracts in the codebase.


Consider using the `Context` contract instead.


**_Update:_** _Resolved in_ _<u>[pull request #4502](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502)</u>_ _at commit_ _<u>[351565f. The OpenZeppelin Contracts team](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502/commits/351565f273c75be2601a4ccd27b5b6f69b1594b0)</u>_

_stated:_


_The ProxyAdmin contract will never send a meta-transaction in any way. We prefer to_

_stick to_ _`msg.sender`_ _but we're documenting and making explicit the fact that we don’t_

_use_ _`_msgSender()`_ _._


Contracts 5.0 Release − Low Severity − 29


### **L-03 ERC2771Forwarder Must Not Hold Token** **Approvals**

If `ERC2771Forwarder` is granted a token approval by the user, their tokens can be exploited.

This is because an attacker can call the `execute` method to exploit the approval by

forwarding a `transferFrom` request to the token contract. While the attacker address will be

appended to the request, it will be ignored by the token contract, which will result in a

malicious token transfer from the approving user's wallet.


Although it is unlikely that this contract will be granted any token approvals for its current

functionality, given that the library contracts are typically extended with additional functionality

the documentation should be clear about this risk.


Consider clarifying in the documentation that no token approvals or permits should be granted

to this contract or any contract that extends it.


**_Update:_** _Resolved in_ _<u>[pull request #4502](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502)</u>_ _at commit_ _<u>[1bd3544, at commit](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502/commits/1bd35440a9eae540fa6db1fad0a87058c55db0bc)</u>_ _<u>[11213f5, at commit](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502/commits/11213f59912149f2df68632a0b115d67092288c3)</u>_

_<u>[889c112, at](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502/commits/889c11271f704e25b6d5685e9b0b8c36e4695fd3)</u>_ _<u>[pull request #4519](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4519)</u>_ _at commit_ _<u>[b83d8fc. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4519/commits/b83d8fc90ecfb10049602a2badff2005567b7e03)</u>_


_The forwarder was restricted to only call contracts trusting it to mitigate further misuse_

_of the forwarder._

### **L-04 Error-prone Failure Semantics of verify in** **`ERC2771Forwarder`**


The `verify` view in <u>`[ERC2771Forwarder](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/metatx/ERC2771Forwarder.sol#L99)`</u> exhibits ambiguous behavior in certain failure

scenarios. It returns `false` if a request is expired or if the signer doesn't match. However, it

might also revert due to the use of <u>`[ECDSA.recover](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/utils/cryptography/ECDSA.sol#L88)`</u>, which reverts on signature recovery

errors.


This ambiguity in failure semantics can be error-prone and complicate integrations. For

instance, an on-chain contract or off-chain script invoking `verify` should anticipate both a

`false` return value and a potential revert. If only one of these outcomes is expected, this

could lead to unforeseen consequences. An on-chain contract might revert unexpectedly if

only `false` is expected. Conversely, if only a revert is anticipated, requests may be incorrectly

deemed verified.


Consider using <u>`[ECDSA.tryRecover](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/utils/cryptography/ECDSA.sol#L53)`</u> in the `verify` view, and return `false` in all invalid

scenarios.


Contracts 5.0 Release − Low Severity − 30


**_Update:_** _Resolved in_ _<u>[pull request #4502](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502)</u>_ _at commit_ _<u>[53b4feb. The OpenZeppelin Contracts team](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502/commits/53b4febe4267abcf11dfcbfa69c942cd477c79d4)</u>_

_stated:_


_We implemented the recommended solution of using_ _`ECDSA.tryRecover`_ _._

### **L-05 Inconsistent Solidity Version Used in** **`ERC1967Utils`**


Most of the contracts utilize Solidity version `0.8.19`, however, the <u>`[ERC1967Utils](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/ERC1967/ERC1967Utils.sol#L4)`</u> contract

uses `0.8.20` . This discrepancy could be <u>[problematic](https://github.com/ethereum/solidity/releases/tag/v0.8.20)</u> for certain chains, especially if they do

not support the `push0` opcode. This inconsistency might pass unnoticed in a project's

configuration and lead to the use of an incompatible compiler version and deployment of

incompatible bytecode.


Consider aligning the Solidity version in `ERC1967Utils` with the rest of the contracts to avoid

potential compatibility issues.


**_Update:_** _Resolved in_ _<u>[pull request #4489](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4489)</u>_ _at commit_ _<u>[00cbf5a. The solidity version of all files will](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/00cbf5a236564c3b7aacdad1f378cae22d890ca6)</u>_

_be updated to_ _`0.8.20`_ _following_ _<u>[Hardhat's intention](https://github.com/NomicFoundation/hardhat/issues/4232)</u>_ _of supporting safe default_ _`evmVersion`_ _._

_This should prevent any issues for projects on L2s and side-chains that do not support_ _`push0`_

_opcode. Foundry's default is already safe in that regard, which means that most projects using_

_up to date tooling should be safe from the issue by the time the library update is released. The_

_OpenZeppelin Contracts team stated:_


_The library pragma version was bumped to 0.8.20, aligned with the version used in_

_`ERC1967Utils`_ _which is required for proper library events accessing._

### **L-06 Lack of Access Control and Flexibility in** **VestingWallet 's Release Methods**


The release methods in the `VestingWallet` contract, <u>`[release()](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/finance/VestingWallet.sol#L117-L134)`</u> <u>and</u>

<u>`[release(address)](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/finance/VestingWallet.sol#L117-L134)`</u>, lack access control, allowing anyone to invoke them. This presents a

potential for malicious actions, including:


   - Enabling attack vectors if the beneficiary has significant token approvals for certain

contracts. If these contracts are compromised, an attacker could trigger

`release(address)` and exploit any vested but unreleased tokens. In such cases, the

users might consider the approvals normally safe, for instance, if they typically hold

these token balances only for a short period.


Contracts 5.0 Release − Low Severity − 31


   - Inducing unwanted taxable events. The beneficiary may wish to time the release to their

advantage in terms of taxation. A maliciously-timed release could impact the beneficiary

by triggering unwanted tax liabilities.


Moreover, the transfer destination is not flexible, which might be problematic if the

beneficiary's income and tax structure changes over time. This could restrict the beneficiary's

ability to direct tokens to different addresses, for example, when an individual has incorporated

or wants to release tokens into an entity-controlled address.


Consider restricting the release methods to be callable only by the beneficiary. Along with this

access control, consider allowing the beneficiary to specify the transfer destination or

nominate another beneficiary instead.


**_Update:_** _Acknowledged, not resolved in_ _<u>[pull request #4508. The OpenZeppelin Contracts team](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4508)</u>_

_stated:_


_We see use cases where release() being restricted to the beneficiary is the opposite of_

_what's needed. As an example, custody solutions give constrained access to the private_

_key, and they may be able to transfer tokens but not able to call a release() function. It is_

_easy to add this restriction through inheritance, especially now that the contract uses_

_Ownable, so we are leaving it as is._

### **L-07 Potentially Trapped ETH in** **`ERC2771Forwarder`**


The `ERC2771Forwarder` contract is carefully designed to prevent the accidental trapping of

ETH by matching incoming and outgoing ETH values and by not including a `receive`

function. However, a scenario exists where the contract can still receive ETH. If the

<u>`[refundReceiver](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/metatx/ERC2771Forwarder.sol#L152)`</u> is set to the contract's own address in the `executeBatch` method, it can

<u>[send ETH to itself.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/metatx/ERC2771Forwarder.sol#L179)</u>


Although setting the contract's own address as a `refundReceiver` can be considered a

user error, this is also the case for other currently prevented potential mistakes that could result

in sending ETH to the contract unintentionally.


Consider adding a check to prevent the `refundReceiver` from being set to the contract's

own address, in line with the existing efforts to avoid such accidental scenarios.


**_Update:_** _Resolved. The OpenZeppelin Contracts team stated:_


Contracts 5.0 Release − Low Severity − 32


_The ERC2771Forwarder doesn't contain a_ _`receive()`_ _function so any value sent will_

_make the refund revert. Any user using this contract can enable balance management at_

_will._

### **L-08 Reentrancy Risk in** **`ERC1967Utils._setBeacon`**


Within `ERC1967Utils._setBeacon`, when the <u>`[implementation()](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/ERC1967/ERC1967Utils.sol#L154)`</u> <u>external call is made,</u>

the <u>assignment</u> <u>`[StorageSlot.getAddressSlot(BEACON_SLOT).value = newBeacon;](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/ERC1967/ERC1967Utils.sol#L159)`</u>

has not yet been executed. Thus, if the `getBeacon` getter or the EIP1967 storage slot is read

during this external call, it will return an inconsistent value.


Consider updating the beacon address in the storage slot prior to making any external calls.

This could prevent potential inconsistencies due to reentrancy.


**_Update:_** _Resolved in_ _<u>[pull request #4502](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502)</u>_ _at commit_ _<u>[a94adcd. The OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502/commits/a94adcd82c8c58e02af6778e08d22a6221a89546)</u>_

_team stated:_


_Fixed as suggested._

### **L-09 Risk of Division by Zero in VestingWallet**


In the `VestingWallet` contract, if the duration is set to zero by the deployer, the contract

behaves similarly to an asset timelock for the beneficiary. However, in this case, there's a risk

of division by zero in the `_vestingSchedule` function. If the duration is set to zero,

`start()` and `end()` will be identical. Thus, calling `_vestingSchedule` with a

`timestamp` equal to `start()` and `end()` will result in a division by zero error in the vesting

formula, causing the transaction to revert for that particular block.


Consider using `>=` in the <u>`[else if](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/finance/VestingWallet.sol#L157)`</u> <u>[branch condition](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/finance/VestingWallet.sol#L157)</u> to prevent the division by zero in this

scenario.


**_Update:_** _Resolved in_ _<u>[pull request #4502](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502)</u>_ _at commit_ _<u>[9afa6c9. The OpenZeppelin Contracts team](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502/commits/9afa6c9e50d6d63f6fa4e97262d9c38a7ce692b5)</u>_

_stated:_


_Fixed as suggested._


Contracts 5.0 Release − Low Severity − 33


### **L-10 Risk of Ownership Loss Due to Single-Step** **Ownership Transfer in UpgradeableBeacon and** **`ProxyAdmin`**

The `UpgradeableBeacon` and `ProxyAdmin` contracts utilize the `Ownable` <u>[(1, 2) contract](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/beacon/UpgradeableBeacon.sol#L15)</u>

for access control. This single-step ownership transfer method can be error-prone, potentially

leading to loss of ownership.


Consider adopting the `Ownable2Step` contract instead.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


_We agree with the risk of ownership loss and we'll consider further options for providing_

_a more robust workaround. For now, both_ _`ProxyAdmin`_ _and_ _`UpgradeableBeacon`_

_are kept using_ _`Ownable`_ _in order to prioritize flexibility for the library users. The current_

_setup is already extensible, whereas_ _`Ownable2Step`_ _can't be opt-out._

### **L-11 ERC-165 Check Is Too Permissive**


<u>[ERC-165](https://eips.ethereum.org/EIPS/eip-165)</u> specifies that a compliant contract must return a bool, implementing the interface

`supportsInterface(bytes4) returns(bool)` . However, the <u>[check in](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/utils/introspection/ERC165Checker.sol#L122)</u>

<u>`[ERC165Checker](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/utils/introspection/ERC165Checker.sol#L122)`</u> will return `true` for a broader set of return values, such as a `uint` that is

greater than 0, or a bytes array of any nonzero size. In general, any return data of a length

greater than one word, in which the first word is not 0, will cause the check to return `true` . In

contrast, Solidity's `abi.decode` will revert for such values, for example

`abi.decode(abi.encode(uint(2)), (bool))` will revert.


Consider restricting the check to require `returnValue == 1` to mimic Solidity's decoding

behavior of a single `bool(true)` return value. Additionally, consider restricting the check of

`returndatasize` to exactly 32 bytes, despite the fact that this will be stricter than Solidity's

`abi.decode` behavior, to more strictly enforce the expected interface.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


_When ERC-165 was defined Solidity hadn't yet switched to ABI coder v2 by default._

_Prior to v2, compliant contracts could behave in a way that would not work for the_

_suggested implementation, because any nonzero value was interpreted as true when_

_decoded as a boolean. Because of this we are keeping the current behavior._


Contracts 5.0 Release − Low Severity − 34


### **L-12 address(0) Is Allowed as the Initial Owner**

When transferring ownership in the `Ownable` contract, the address of the `newOwner` is

<u>[checked against](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/access/Ownable.sol#L82-L83)</u> <u>`[address(0)](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/access/Ownable.sol#L82-L83)`</u> in order to avoid completely renouncing the ownership by

mistake. Instead, the special function <u>`[renounceOwnership](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/access/Ownable.sol#L73)`</u> should be called for this

purpose.


However, upon constructing an `Ownable` instance, the initial owner address <u>[is not checked](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/access/Ownable.sol#L39)</u>

<u>against</u> <u>`[address(0)](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/access/Ownable.sol#L39)`</u> .


Consider adding a zero address check for the initial owner address upon construction, to avoid

wrongly deployed instances but also to remain consistent with the rest of the contract's code.


**_Update:_** _Resolved in_ _<u>[pull request #4531.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4531)</u>_

### **L-13 Enumeration Methods Are Unnecessarily** **Limited**


The enumeration methods of `EnumerableSet` <u>[(1, 2, 3) and](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/utils/structs/EnumerableSet.sol#L219-L229)</u> `EnumerableMap` <u>[(1, 2, 3, 4, 5)](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/utils/structs/EnumerableMap.sol#L158)</u>

only support returning the full array. The documentation states that this action can only be

useful in the context of off-chain views, since it may be either too expensive to run or may even

not be possible to run at all if the array is long enough to exhaust a single block's gas limit.


This is problematic because if the goal of these data structures is to provide an _enumerable_ set

and map, the goal is not accomplished as currently implemented, and this implied core

functionality is not fully usable. That said, allowing paginated or sliced enumeration should be a

simple and limited update to the logic of <u>`[EnumerableSet](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/utils/structs/EnumerableSet.sol#L153)`</u> <u>'s</u> <u>`[_values()](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/utils/structs/EnumerableSet.sol#L153)`</u> . In addition to the

logic, the interfaces would need to be updated to allow passing additional arguments into the

`values()` and `keys()` methods to specify either the pagination or the slicing parameters: 
For pagination, a page size and page index would need to be passed, where array length and

index 0 would replicate the current behavior. - For slicing, the start index and end index (or

number of elements) would need to be passed, where start index 0 and array length would

replicate the current behavior.


Consider implementing slicing or pagination in the keys' and values' enumeration methods to

allow them to be used more flexibly.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


Contracts 5.0 Release − Low Severity − 35


_We consider the methods_ _`at`_ _and_ _`length`_ _to be a form of enumerability, and this is the_

_form that is recommended to be exposed publicly._

### **L-14 Proposal Front-Running Protection Fails** **Silently**


In the `Governor` contract, the <u>`[_isValidDescriptionProposer](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/Governor.sol#L760)`</u> <u>function</u> checks whether

the description includes a `#proposal=0x` string followed by an address. As a front-running

protection measure, this is to make the proposal optionally proposer dependent for the

respective proposal id.


The validation function checks the proposer address string towards the end of the description

and silently ignores the validation when an unexpected format is given. This means that a

proposal with a simple mistake, such as a trailing whitespace, can still be front-run.


Consider making the validation more tolerant for user mistakes by parsing the whole

description for the proposal query parameter and reverting if the address is badly formatted or

doesn't match the proposer.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


_Not addressing. We don't consider silent failure is a significant risk here, and the logic_

_required to parse and detect malformed string suffixes would be too complex and_

_expensive to be justified. The worst that can happen is that the proposal becomes_

_frontrunnable, and if it is indeed frontrun the proposer can resubmit it._

### **L-15 TimelockController Allows Sending ETH by** **Default**


The `TimelockController` contract has an empty <u>`[receive](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/TimelockController.sol#L155)`</u> <u>function</u> to enable other

accounts to send ETH to it. This might be necessary to further execute scheduled calls that

require ETH. However, this also enables users to accidentally lose their ETH by sending it to

the contract.


Consider either removing the `receive` function so that it needs to be implemented in an

extended contract if it plans on handling ETH, or protecting the function through the existing

proposer, executor, and canceller roles.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


Contracts 5.0 Release − Low Severity − 36


_Not addressing. The TimelockController is designed to be a kind of wallet. It has the_

_ability to extract ETH through the timelock process so there is no risk of loss. We want_

_the contract to be usable out of the box without extending to add basic features._

### **L-16 Unintuitive and Inconsistent Proposal State** **Timing**


In the `Governor` contract, a proposal has a life-cycle of multiple states. E.g., the state can be

pending or active depending on the vote start and end time.


These states are implemented such that on the vote start time point, the proposal is <u>[still](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/Governor.sol#L159-L160)</u>

<u>[pending. This behavior can be unintuitive and potentially cause confusion for applications.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/Governor.sol#L159-L160)</u>

Consider adjusting the bound to be inclusive towards the beginning of the voting period.


In addition, on the deadline time point the proposal is <u>[still active](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/Governor.sol#L165-L166)</u> while in the

`TimelockController` contract the delay deadline <u>[time point is excluded](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/TimelockController.sol#L213)</u> from the delayed

period. Consider adjusting the code so that a common convention is followed regarding time

periods bounds throughout the codebase.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


_Not addressing. 1. Vote start cannot start earlier because it is the vote snapshot block._

_The block needs to end before ERC20Votes can answer getPastVotes queries. 2. We_

_prefer to keep Governor behaving as it is now for compatibility with existing Governors_

_and GovernorBravos._

### **L-17 Overloaded Error Messages**


Throughout the codebase the following instances of overloaded error messages were noted:


   - In `Initializable.sol`, the error `AlreadyInitialized()` on <u>[line 146](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/proxy/utils/Initializable.sol#L146)</u> and <u>[line 186](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/proxy/utils/Initializable.sol#L186)</u>

are not accurate as the contracts are in the process of initializing, thus not already

initialized. Consider using a custom error reflecting the state that it is

`StillInitializing()` .

   - In `MerkleProof.sol`, the error `MerkleProofInvalidMultiproof()` is used in

two different scenarios. The first appearance is when the lengths of leaves, proofs and

flags violate the <u>[invariant](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/utils/cryptography/MerkleProof.sol#L121)</u> and the second appearance is when <u>[there are unused](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/utils/cryptography/MerkleProof.sol#L146)</u> elements

left in the proof array. Consider using different and informative error messages for these

two distinct cases.


Contracts 5.0 Release − Low Severity − 37


**_Update:_** _Partially resolved in_ _<u>[pull request #4592. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4592)</u>_


_1. Addressed by renaming the error to InvalidInitialization. 2. Did not address. We_

_consider that "invalid multi proof" is accurate. The second instance of the error is also_

_part of the invariant, but one that we can check most efficiently after iterating over the_

_proof._

## **Notes & Additional** **Information**

### **N-01 Allowances And Approval Inconsistencies -** **Phase 1**


The `ERC20` contract <u>[allows for self approvals, while](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/ERC20.sol#L320)</u> `ERC1155` <u>[doesn't allow for that.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/ERC1155.sol#L354)</u>

Moreover, the `ERC1155` contract can approve an allowance <u>[to the zero address, while this is](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/ERC1155.sol#L356)</u>

<u>[not possible in the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/ERC20.sol#L318)</u> <u>`[ERC20](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/ERC20.sol#L318)`</u> <u>contract.</u>


Whether this inconsistent behaviour is given by following EIP guidelines or not, consider stating

that in the docstrings. If there are no EIP-imposed restrictions, consider making the library

consistent in how it handles approvals and allowances across all the contracts.


**_Update:_** _Resolved in_ _<u>[pull request #4398. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4398)</u>_


_None of these requirements are a part of the ERCs. We have allowed self-approvals and_

_disallowed_ _`address(0)`_ _approvals in ERC1155 to align with ERC20._

### **N-02 Gas Optimization - Phase 1**


There are some areas of the codebase where either its style can be improved or changes can

be made to save gas:


   - The <u>`[_msgSender](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/ERC1155.sol#L141-L143)`</u> function is called three times when transferring in the `ERC1155`

contract. It might be worth caching its value.

   - In line <u>[67](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/extensions/ERC1155Supply.sol#L67)</u> of the `ERC1155Supply`, the `ids[i]` value is cached in a local variable, while

in line <u>[58](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/extensions/ERC1155Supply.sol#L58)</u> `ids[i]` is not. Consider making the style consistent.


Contracts 5.0 Release − Notes & Additional Information − 38


**_Update:_** _Resolved in_ _<u>[pull request #4398.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4398/files)</u>_

### **N-03 Contracts Are Not abstract**


With the goal of extensibility and customization, all contracts within the library, apart from

some special examples, should be marked as `abstract`, so that users consciously inherit

from them even if they don't include any custom implementation. However, there are still some

contracts that are not marked as `abstract`, but should be. Some examples include the

<u>`[ERC20](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/ERC20.sol)`</u> and <u>`[ERC1155Holder](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/utils/ERC1155Holder.sol)`</u> contracts.


Consider reviewing the entire codebase and marking all necessary definitions as `abstract` .


**_Update:_** _Resolved in_ _<u>[pull request #4010.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4010)</u>_

### **N-04 EIP-3156 Inconsistency**


The <u>`[ERC20FlashMint](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20FlashMint.sol)`</u> <u>contract</u> is an implementation of the ERC-3156 extension. Following

the <u>[description](https://eips.ethereum.org/EIPS/eip-3156#automatic-approvals)</u> of the EIP, the way in which the design was originally thought was by having an

external ERC-20 token that should have been transferred to the user and then pulled back from

the `receiver` plus an amount of fees.


The pull mechanism of payment is generally preferred over a push payment pattern and this is

the only reason why it has been adopted by the EIP. A subtle difference comes with the flash

mint variant of the EIP, represented by the in `ERC20FlashMint` contract. The difference is in

that the contract itself is the ERC-20 token used, and no external tokens or contracts are used.

While adopting such EIP, the intention to follow it strictly but with such subtle differences

created an inconsistency.


Given the fact that there's no need to pull tokens from the receiver since the contract itself is

the token contract, instead of a pull payment pattern, <u>[internal functions are used directly. This](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20FlashMint.sol#L121-L124)</u>

means that the <u>[need to approve an allowance](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20FlashMint.sol#L90)</u> beforehand and <u>[then spend](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20FlashMint.sol#L119)</u> such allowance is a

useless design that only wastes gas. The only reason that justifies such a sub-optimal pattern

is given by the fact that making a useless approval and subsequent spend allowance would

allow covering either for a flash loan or a flash mint, without worrying about which one is the

specific implementation of the interacting contract.


Consider either removing the need to approve and then spend the allowance or documenting

why it has been maintained despite not being necessary. On a side note, consider creating a

`FlashLoan` contract that adheres completely to the flash loan use case (not flash mint),


Contracts 5.0 Release − Notes & Additional Information − 39


having an external token contract and a pull payment mechanism to retrieve flash-loaned

funds. This new contract together with the already existing `ERC20FlashMint` should be

complementary to each other, covering all use cases.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


_We see good reasons to preserve the current behavior:_


_1) The reference implementation for FlashMint in ERC-3156 implements the same_

_behavior._


_2) Contracts that use the_ _`flashLoan`_ _function may use both_ _`FlashMint`_ _and_

_`FlashLoan`_ _contracts._


_These contracts will want to treat both uniformly, for simplicity and also because the EIP_

_doesn't give means to distinguish between them._ _`FlashLoan`_ _contracts need the_

_allowance, and they will approve when interacting with_ _`FlashMint`_ _too. If they do that,_

_it seems better to take from the allowance rather than leave the allowance unused_

_because it could open up attack vectors._

### **N-05 Missing Interface**


The <u>`[IERC20Permit](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/IERC20Permit.sol)`</u> <u>interface</u> defines the `nonces` getter definition, while in reality, it should

extend from a non-existing `INonces` interface.


Consider creating an `INonces` interface, and making `Nonces` and `IERC20Permit` extend

from it.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


_We have decided to keep the current structure to avoid introducing a new interface, and_

_because it mirrors the interface defined in EIP-2612._

### **N-06 Missing Or Incorrect Docstrings - Phase 1**


Throughout the codebase, there are instances where docstrings are missing, incorrect or can

benefit from a rephrase:


   - Docstrings in <u>[line 71](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/ERC1155.sol#L71)</u> of the `ERC1155` contract say that it is a requirement for the

address to not be the zero address, but this is not enforced.


Contracts 5.0 Release − Notes & Additional Information − 40


- The <u>`[uri](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/ERC1155.sol#L62)`</u> function of the `ERC1155` contract ignores the unnamed parameter, which

might be specified in the docstrings too.

- The <u>`[_asSingletonArrays](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/ERC1155.sol#L408)`</u> function has an uncommented assembly block, consider

clarifying each line of assembly instructions. Moreover, the function itself has no

docstrings at all.

- The <u>`[_safeBatchTransferFrom](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/ERC1155.sol#L227-L236)`</u> <u>function docstrings</u> lack the requirement for `ids` and

`amounts` lengths to be equal.

- The <u>`[_mintBatch](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/ERC1155.sol#L295-L305)`</u> <u>[function docstrings](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/ERC1155.sol#L295-L305)</u> don't specify that `to` can't be the zero address.

- The <u>`[_burnBatch](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/ERC1155.sol#L331-L339)`</u> <u>[function docstrings](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/ERC1155.sol#L331-L339)</u> don't inherit the same requirements of the

equivalent `_burn` function.

- The <u>[acceptances checks](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/ERC1155.sol#L360-L406)</u> miss any sort of docstrings, that might need to be inherited

from `IERC1155Receiver` .

- The <u>[docstrings](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/extensions/ERC1155Pausable.sol#L20)</u> of the `ERC1155Pausable` mention that if some don't extend from it, the

contract will be unpausable. It should also be stated that the contract will not be

pausable at all.

- Line <u>[80](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/IERC1155.sol#L80)</u> of the `IERC1155` has double quotes around "account".

- The <u>`[ERC1155InsufficientBalance](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/interfaces/draft-IERC6093.sol#L122)`</u> error definition lacks `@param` docstrings for the

`tokenId` parameter.

- Line <u>[80](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/utils/Address.sol#L80)</u> of the `Address` library says that `customRevert` must be a reverting function,

but this is not true, and it's not enforced.

- The <u>`[decreaseAllowance](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/ERC20.sol#L202)`</u> function should specify that it doesn't protect from having

the spender front-running any attempt to decrease the allowance.

<u>`[increaseAllowance](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/ERC20.sol#L182)`</u> and <u>`[decreaseAllowance](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/ERC20.sol#L202)`</u> are described to be a safe way to

avoid double-spending when using `approve` . However it does not inform that the

spender can still spend the entire allowance by front-running any attempt of allowance

reduction. Consider adding some clarification in the docstrings of the

`decreaseAllowance` function.

- Docstrings in <u>[line 14](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/utils/structs/Checkpoints.sol#L14)</u> of `Checkpoints` say "Checkpoints.History" when it should be

"Checkpoints.Trace224".




- <u>`[key](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/utils/structs/Checkpoints.sol#L30)`</u> values of `Checkpoints` library should be never accepted as direct user input. If



this happens anyone can disable the library by setting a `key == type(uint32).max`

then any `_insert` call <u>[will revert. This should be clearly stated in the docstrings, since](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/utils/structs/Checkpoints.sol#L134)</u>

it is important to know when it comes to using and integrating with it.

   - The <u>`[nonces](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/utils/Nonces.sol#L18)`</u> <u>function</u> of the `Nonces` contract should be described as the "next unused

nonce" and not as the current nonce.


Consider reviewing the entire codebase for more occurrences and fixing the suggested ones.


**_Update:_** _Resolved in_ _<u>[pull request #4398.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4398)</u>_


Contracts 5.0 Release − Notes & Additional Information − 41


### **N-07 Naming Suggestions - Phase 1**

To favor explicitness and readability, several parts of the contracts may benefit from better

naming. Consider making the following changes:


   - The <u>`[ERC1155InsufficientApprovalForAll](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/interfaces/draft-IERC6093.sol#L141)`</u> name suggests that the allowance is

not "sufficient" in quantity but the approval function doesn't take quantities into account.

Consider renaming to something like `ERC1155LackOfApprovalForAll` .

   - The <u>`[onERC1155Received](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/IERC1155Receiver.sol#L27)`</u> and <u>`[onERC1155BatchReceived](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/IERC1155Receiver.sol#L51)`</u> functions have a

parameter named `value(s)` in the interface definition, but what is passed in when

called is `amount(s)` in the <u>[actual](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/ERC1155.sol#L392)</u> `ERC1155` <u>[implementation. Consider making them](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/ERC1155.sol#L369)</u>

consistent and changing `value(s)` to `amount(s)` .


**_Update:_** _Resolved in_ _<u>[pull request #4381](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4381)</u>_ _and_ _<u>[pull request #4398. The OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4398)</u>_

_team stated:_


_Renamed the error. For "amount" vs "value", we used the opportunity to align across all_

_the ERC-20 and ERC-1155 contracts to use "value" everywhere._

### **N-08 Outdated Solidity Version**


The majority of contracts use a pragma Solidity version `^0.8.19` while the `0.8.20` version

is already out. Consider whether it is worth updating the version across the codebase.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


_We are using 0.8.19 because there are no new language features in 0.8.20. We will_

_consider using 0.8.21 once it comes out._

### **N-09 Uncommented Sensitive Operation**


The `ERC20` and `ERC1155Supply` `_update` function relies on built-in overflow checks in

Solidity to <u>[increment supply](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/ERC20.sol#L243)</u> when minting new tokens. This will in general protect from

overflowing.


However, it's not written anywhere in the docstrings that this is an extremely important

assumption that should never change. If this was done inside an unchecked box instead, the

effects might spread in many extension contracts. The main reason is that all other calculations

rely on that operation to not overflow, to save gas and use `unchecked` boxes anywhere else

instead.


Contracts 5.0 Release − Notes & Additional Information − 42


Since such an operation has no comments at all and it is of utter importance, consider whether

this should be specified in the docstrings since an eventual overflow might have a catastrophic

impact even in the most basic contracts like `ERC20Capped` .


**_Update:_** _Resolved in_ _<u>[pull request #4398.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4398)</u>_

### **N-10 Unused Custom Errors**


The <u>`[ERC1155InvalidOwner](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/ERC1155.sol#L33)`</u> <u>custom error</u> of the `ERC1155` contract is not used. Moreover, it

is misplaced, since all custom errors are defined within the `contracts/interfaces/`

`draft-IERC6093.sol` <u>[file. The same happens with the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/interfaces/draft-IERC6093.sol#L115)</u> <u>`[ERC1155InvalidApprover](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/interfaces/draft-IERC6093.sol#L147)`</u>

custom error, which is not used anywhere in the codebase.


Consider removing unused custom errors and to consolidate all custom error definitions within

the same file.


**_Update:_** _Partially resolved in_ _<u>[pull request #4261. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4261)</u>_


_`ERC1155InvalidOwner`_ _was removed._ _`ERC1155InvalidApprover`_ _is not used,_

_but it is defined in the EIP so we are keeping it._

### **N-11 Unused or Duplicated Imports And** **Extensions - Phase 1**


In the codebase, there are cases in which contracts might have a shorter inheritance chain or

where imports are either unused or duplicated.


   - In <u>`[Checkpoints.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/utils/structs/Checkpoints.sol)`</u> the import <u>`[SafeCast](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/utils/structs/Checkpoints.sol#L8)`</u> is unused and could be removed.

   - The <u>`[ERC1155](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/ERC1155.sol#L20)`</u> contract extends from `IERC1155` and `IERC1155MetadataURI` but the

latter already extends from the former. Similarly, some imports are already present in

parent contracts.


Consider removing unused or duplicated imports and/or extensions to improve the overall

clarity and readability of the codebase.


**_Update:_** _Partially resolved in_ _<u>[pull request #4398. Regarding the second point, the](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4398)</u>_

_OpenZeppelin Contracts team stated:_


Contracts 5.0 Release − Notes & Additional Information − 43


_We decided to keep the interface. The main reason is that seeing it there allows us to be_

_confident that the contract is actually correctly implementing the ERC-1155 interface,_

_without knowing that_ _`IERC1155MetadataURI`_ _extends_ _`IERC1155`_ _._

### **N-12 Outdated Version in Docstrings**


Many contracts don't have the docstrings updated with the latest version. An example is the

<u>`[ERC1155](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/ERC1155.sol#L2)`</u> contract that mentions `v4.9` in the docstrings titles.


Consider updating all of the codebase's docstrings to reflect the latest version of the contracts

that have been modified in the latest release.


**_Update:_** _Acknowledged, will resolve. The OpenZeppelin Contracts team stated:_


_These are automatically updated with releases._

### **N-13 Event Definition Improvement Suggestions**


The <u>`[AdminChanged](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/ERC1967/ERC1967Utils.sol#L25)`</u> event of `ERC1967Utils` does not index its parameters, while the

<u>`[Upgraded](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/ERC1967/ERC1967Utils.sol#L20)`</u> and <u>`[BeaconUpgraded](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/ERC1967/ERC1967Utils.sol#L30)`</u> events do not emit the old implementation's values.


Consider indexing event parameters and emitting old values whenever a change occurs in the

state.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


_ERC-1967 defines the event like that and is final. The suggested change can't be made._

### **N-14 Code Style Suggestions - Phase 1**


Throughout the codebase, many functions use the nested conditionals coding style, which

affects readability. For instance:


   - In `TransparentUpgradeableProxy`, the <u>`[_fallback](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/transparent/TransparentUpgradeableProxy.sol#L84-L92)`</u> <u>function</u>

   - In `Address`, the <u>`[verifyCallResultFromTarget](https://github.com/ernestognw/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/utils/Address.sol#L174-L185)`</u> <u>function</u>


   - In `ERC2771Forwarder`, the <u>`[_execute](https://github.com/ernestognw/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/metatx/ERC2771Forwarder.sol#L239-L261)`</u> <u>function</u>


Consider refactoring the aforementioned functions following the <u>[guard clauses](https://maximegel.medium.com/what-are-guard-clauses-and-how-to-use-them-350c8f1b6fd2#:~:text=A%20guard%20clause%20is%20a,deeper%20and%20less%20meaningful%20error.)</u>

<u>[technique. An example is shown below for the aforementioned](https://maximegel.medium.com/what-are-guard-clauses-and-how-to-use-them-350c8f1b6fd2#:~:text=A%20guard%20clause%20is%20a,deeper%20and%20less%20meaningful%20error.)</u> `_execute` method.


Contracts 5.0 Release − Notes & Additional Information − 44


```
function _execute(
  ForwardRequestData calldata request,
  bool skipInvalid // note: flipped relative to `requireValidRequest`
) internal virtual returns (bool success) {
  // note: could also be refactored into `_handleInvalidRequest(ForwardRequestData
calldata request, bool skipInvalid)`
  if (!signerMatch || !alive) {
     if (skipInvalid) {
       return;
     }

     if (!alive) {
       revert ERC2771ForwarderExpiredRequest(request.deadline);
     }

     if (!signerMatch) { // redundant if, but more readable (optimized away by
compiler?)
       revert ERC2771ForwarderInvalidSigner(signer, request.from);
     }
  }

  // Nonce should be used before the call to prevent reusing by reentrancy
  uint256 currentNonce = _useNonce(signer);

  (success, ) = request.to.call{gas: request.gas, value: request.value}(
     abi.encodePacked(request.data, request.from)
  );

  _checkForwardedGas(gasleft(), request);

  emit ExecutedForwardRequest(signer, currentNonce, success);
}

```

**_Update:_** _Partially resolved in_ _<u>[pull request #4502](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502)</u>_ _at commit_ _<u>[7263524, at commit](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502/commits/72635240430ea1a1a17b90bc68de882963b97008)</u>_ _<u>[3d8baba. The](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502/commits/3d8babad048f820b1f8cb314ffde842a9603d494)</u>_

_OpenZeppelin Contracts team stated:_


_We agree the guard clauses technique is valuable so we prioritized errors in both_

_`Address`_ _and_ _`TransparentUpgradeableProxy`_ _. However, we also consider using_

_braces is less error-prone and may prevent unintentional issues so we kept such syntax._

_Note that the recommendation for_ _`ERC2771Context`_ _does not replicate the same_

_behavior._

### **N-15 Inadequate Documentation for Reverting** **Payable Upgrades with Empty Data**


Several upgrade methods within the contracts are payable, including the <u>`[ProxyAdmin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/transparent/ProxyAdmin.sol#L38-L42)`</u> and its

target in <u>`[TransparentUpgradeableProxy](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/transparent/TransparentUpgradeableProxy.sol#L83-L85)`</u>, the <u>`[UUPSUpgradeable](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/utils/UUPSUpgradeable.sol#L95)`</u>, and the

<u>`[ERC1967Proxy](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/ERC1967/ERC1967Proxy.sol#L22)`</u> <u>constructor.</u>


Contracts 5.0 Release − Notes & Additional Information − 45


However, these methods will revert in the <u>`[ERC1967Utils.upgradeToAndCall](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/ERC1967/ERC1967Utils.sol#L89)`</u> if the `data`

parameter is empty, yet `msg.value` is not zero. This occurs because even if the

implementation can receive ETH, this cannot be guaranteed, since it will not be called due to

the empty `data` input.


Consider adding inline documentation that explains why this combination of inputs is

unsupported. Additionally, provide guidance on the best approach a project can use to support

these inputs if they are required for any reason.


**_Update:_** _Resolved in_ _<u>[pull request #4382](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4382)</u>_ _at commit_ _<u>[121be5d. The OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/121be5dd09caa2f7ce731f0806b0e14761023bd6)</u>_

_team stated:_


_Documentation was added in the NatSpec of the_

_`ERC1967Utils.upgradeToAndCall`_ _and_

_`ERC1967Utils.upgradeBeaconToAndCall`_ _functions._

### **N-16 Incompatibility of VestingWallet with** **Rebasing Tokens**


The `VestingWallet` contract may not function as expected with rebasing tokens. In such

tokens, the token's balance and total supply can change without any interaction with the

`VestingWallet` contract, due to the rebasing mechanism.


Since the `_released` and `_erc20released` variables remain static between their updates

<u>[(1, 2), an external change in the contract's token balance due to a rebase, can result in the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/finance/VestingWallet.sol#L119)</u>

vesting schedule speeding up or slowing down, contrary to the defined `durationSeconds` .


Consider documenting this incompatibility to ensure users are aware that this contract may not

function correctly with ERC-20 tokens that exhibit atypical balance behaviors, such as rebasing

tokens.


**_Update:_** _Resolved in_ _<u>[pull request #4502](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502)</u>_ _at commit_ _<u>[6689060. The OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502/commits/6689060500fd53c4577ff441693962725b39fe36)</u>_

_team stated:_


_We added documentation for rebasing tokens._


Contracts 5.0 Release − Notes & Additional Information − 46


### **N-17 Lack of Event Emission - Phase 2**

Throughout the codebase there are some state changes and calls that are not accompanied by

event emission:


   - The `ProxyAdmin` contract <u>[does not emit an event](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/transparent/ProxyAdmin.sol#L38-L44)</u> during the `upgradeAndCall`

function execution. Although the proxy contract <u>will emit an</u> <u>`[Upgraded](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/ERC1967/ERC1967Utils.sol#L84)`</u> <u>event, it will do</u>

so in its own context. Emitting a separate upgrade event in the context of the admin

contract would simplify off-chain upgrade tracking, especially in systems where a single

admin controls multiple proxies.

   - The <u>`[UpgradeableBeacon](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/beacon/UpgradeableBeacon.sol#L31)`</u> <u>'s constructor</u> updates the implementation without emitting

an event. This happens because the <u>`[Upgraded](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/beacon/UpgradeableBeacon.sol#L54)`</u> <u>event</u> is not emitted during the

execution of the internal `_setImplementation` function. Consider relocating the

event emission to the `_setImplementation` function to ensure it is triggered in both

cases.


Consider ensuring events are emitted in these cases.


**_Update:_** _Partially resolved in_ _<u>[pull request #4502](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502)</u>_ _at commit_ _<u>[687b805. The OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502/commits/687b80515b16138d11e79eb2d9503fb1ae8defec)</u>_

_Contracts team stated:_


_Fixed by emitting the_ _`Upgraded`_ _event in UpgradeableBeacon's constructor. However,_

_an extra event wasn't added to ProxyAdmin in order to keep it as simple as possible,_

_which is its intended design._

### **N-18 Lack of Inclusion of a "Vesting Cliff"** **Feature**


A "vesting cliff" is a prevalent feature in vesting schedules. It defines a date before which no

tokens can be released, despite the linear progression of the vesting schedule prior to that

date. Even though projects can extend the contract to include this functionality, given its

prevalence in vesting schedules, it would be beneficial to incorporate it into the default

contract. This addition would help reduce potential implementation errors and enhance the

utility of the default contract.


Consider adding a `cliffTimestamp` input to the constructor. This timestamp could be used

in a `cliff()` view, whose value should not exceed the `end()` time. In the

`_vestingSchedule` method, if the `timestamp` is earlier than the `cliff()`, the

`totalAllocation` should be set to 0.


Contracts 5.0 Release − Notes & Additional Information − 47


**_Update:_** _Acknowledged, will resolve. The OpenZeppelin Contracts team stated:_


_This variant will be considered for future development. We consider it an easy_

_implementation to be built on top of the VestingWallet._

### **N-19 Missing Or Incorrect Docstrings - Phase 2**


Throughout the codebase, there are instances where docstrings are missing, incorrect or can

benefit from a rephrase:


   - In the <u>[ERC1967Utils library, the comments for the internal constants](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/ERC1967/ERC1967Utils.sol)</u>

<u>[IMPLEMENTATION_SLOT, ADMIN_SLOT, and](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/ERC1967/ERC1967Utils.sol#L33-L35)</u> <u>[BEACON_SLOT](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/ERC1967/ERC1967Utils.sol#L133-L134)</u> mention that they are

"validated in the constructor". However, no constructor occurrence could be found

where the aforementioned internal constants are validated.


   - In the <u>[IBeacon interface, the following](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/beacon/IBeacon.sol)</u> <u>[comment](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/beacon/IBeacon.sol#L13C8-L13C64)</u> assumes that the `BeaconProxy` will

check that the implementation's address is a contract. However, this is not checked in

`BeaconProxy` but rather in <u>[UpgradeableBeacon while setting the implementation.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/beacon/UpgradeableBeacon.sol#L64)</u>


   - The definition's syntax of the <u>[BEACON_SLOT](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/ERC1967/ERC1967Utils.sol#L134)</u> differs from the definitions' syntaxes of

<u>[IMPLEMENTATION_SLOT](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/ERC1967/ERC1967Utils.sol#L34-L35)</u> and <u>[ADMIN_SLOT.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/ERC1967/ERC1967Utils.sol#L95-L95)</u>


   - Throughout the scope (and codebase), events that refer to standard EIP events are

mentioned as "Emits an {IERCxxx-Eventname} event" in the comments. In some other

places, standard EIP events are mentioned as "Emits an {Eventname}" instead. For

example, in the comments for <u>[upgradeToAndCall](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/utils/UUPSUpgradeable.sol#L91)</u> and <u>[upgradeToAndCallUUPS, the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/utils/UUPSUpgradeable.sol#L115)</u>

declaration of the `Upgraded` event is not consistent.


   - The <u>`[UUPSUpgradeable](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/utils/UUPSUpgradeable.sol)`</u> compatibility check should specify in the docstrings that it is

merely a sanity check and that more robust rollback tests are possible but not

implemented because of increased complexity, code size and gas consumption.


   - The <u>`[VestingWallet](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/finance/VestingWallet.sol)`</u> docstrings should specify that the beneficiary is able to modulate

the behavior of the linear vesting into a curve by re-depositing into the vesting contract

the amount released for both ETH and tokens. Moreover, it should prove the calculations

starting from an invariant. An example:

```
/**
* Suggested documentation for `releasable()`
*
* The contract's invariant is `total-withdrawal / total-deposit <= vesting-ratio`
where:

```

Contracts 5.0 Release − Notes & Additional Information − 48


```
*  - `vesting-ratio` is 0 before vesting period start, and during the vesting period
*  is linear in the vesting duration (to a maximum of 100%). For example 50%
*  ratio after 50% of duration.
*  - `total-deposits` is the sum of the contract's balance (regardless of who
supplied it and when),
*  and the already `released` funds (because the release method is the only way
*  that funds can leave this contract).
*  - `total-withdrawal` is the sum of already released funds (stored in `released`),
*  plus the currently `releasable`. Again, because the release method is the only
way
*  that funds can leave this contract.
*
* From the above we can translate the invariant to:
*  `(released + releasable) / (released + contract-balance) <= vesting-ratio`.
* Extracting maximum `releasable` (assuming equality):
*  `releasable = (contract-balance + released) * vesting-ratio - released`
*
* We can call the first term on the right side `vested-amount` and calculate it
separately
* in `vestedAmount()` to make it available in a separate view.
* /

```

   - The <u>`[equal](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/utils/Strings.sol#L90)`</u> function of `Strings` should specify that the function is not able to

distinguish same-length input hash collisions.


   - Functions that do `delegateCall` s in the <u>`[Address](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/utils/Address.sol)`</u> library should have a warning

stating that the call potentially modifies the state of the caller contract.


   - The <u>`[_checkNonPayable](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/ERC1967/ERC1967Utils.sol#L182)`</u> misses useful docstrings.







`being impossible` in <u>`[ProxyAdmin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/transparent/ProxyAdmin.sol#L19C66-L19C82)`</u> <u>'s</u> and <u>`[UUPSUpgradeable](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/utils/UUPSUpgradeable.sol#L28C66-L28C82)`</u> <u>'s</u> docstrings should



be `making it impossible` .


Consider reviewing the entire codebase for more occurrences and fixing the suggested ones.


**_Update:_** _Partially resolved in_ _<u>[pull request #4502](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502)</u>_ _at commit_ _<u>[60329ea. The OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502/commits/60329ea7fe656a330db783cc7ba046acaaa0e045)</u>_

_Contracts team stated:_


_Some of the suggestions were implemented except for those that required more_

_discussion._


Contracts 5.0 Release − Notes & Additional Information − 49


### **N-20 Naming Suggestions - Phase 2**

Throughout the codebase, there are naming choices that impact readability or are inconsistent.

Some suggested improvements include:




- <u>`[implementation](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/ERC1967/ERC1967Utils.sol#L82)`</u> is the generally adopted name for the logic contract behind a proxy.

However, in the <u>`[ERC1967Proxy](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/ERC1967/ERC1967Proxy.sol#L22)`</u> and <u>`[TransparentUpgradeableProxy](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/transparent/TransparentUpgradeableProxy.sol#L74)`</u> constructors

it is called `_logic` instead. Consider always using `implementation` .

- The <u>constant</u> <u>`[_SYMBOLS](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/audit/2023-07-10/contracts/utils/Strings.sol#L13C60-L13C60)`</u> can refer to any symbol. Consider renaming it to

`_HEX_DIGITS` to be more precise.

- The <u>`[UpgradeableBeacon](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/beacon/UpgradeableBeacon.sol)`</u> contract is not per se upgradeable, and instead administers

upgradeability for `BeaconProxy` contracts. Consider mimicking the <u>`[ProxyAdmin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/transparent/ProxyAdmin.sol)`</u>

contract which administers upgradeability for `TransparentUpgradeableProxy` and

use `BeaconProxyAdmin` instead. Alternatively, use `ImplementationBeacon` to

describe the functionality directly.




- <u>`[alive](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/metatx/ERC2771Forwarder.sol)`</u> is an atypical name and is confusing. Some possible alternatives include

`expired` (flipped value), `nonExpired`, or `beforeDeadline` .

- <u>`[requireValidRequest](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/metatx/ERC2771Forwarder.sol#L239C13-L239C32)`</u> is confusing since it can imply that invalid calls are processed



despite being invalid. Consider flipping the value and using `skipInvalidRequests` .

   - Consider incorporating a clearer distinction between the variables and methods in

`VestingWallet` that are duplicated between ETH and ERC-20 cases by suffixing them

with `ETH`, and `ERC20` or `Token` .


**_Update:_** _Partially resolved in_ _<u>[pull request #4502](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502)</u>_ _at commit_ _<u>[dee9963. The OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502/commits/dee9963a03f587e9080a872063ba02039f97b99c)</u>_

_Contracts team stated:_


_Some of the suggestions were implemented except for those that require more_

_discussion._

### **N-21 Trusted Forwarder Address Lacks External** **Visibility**


`ERC2771Context` <u>[stores the trusted forwarder address as an immutable variable](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/metatx/ERC2771Context.sol#L17)</u> and does

not emit an event. As a consequence, querying for the address would be difficult off-chain and

impossible on-chain.


Consider emitting an event when setting the forwarder address, and providing an external view

to access it.


Contracts 5.0 Release − Notes & Additional Information − 50


**_Update:_** _Resolved in_ _<u>[pull request #4502](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502)</u>_ _at commit_ _<u>[1164c51. The OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502/commits/1164c5157d477d35ebfb6231819d9624bf401436)</u>_

_team stated:_


_Addressed by adding a virtual getter, making it opt-in to extend any trusted forwarder_

_custom behavior._

### **N-22 Unused Named Return Variables - Phase 2**


The <u>`[impl](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/ERC1967/ERC1967Proxy.sol#L33)`</u> named return variable of the `ERC1967Proxy` is unused. Similarly, in

`ERC2771Context` the <u>`[sender](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/metatx/ERC2771Context.sol#L24)`</u> <u>variable</u> of the `_msgSender` function is unused in the `else`

branch.


In both cases, consider either removing the named parameter or making use of it.


**_Update:_** _Resolved in_ _<u>[pull request #4502](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502)</u>_ _at commit_ _<u>[58546a1. The OpenZeppelin Contracts team](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502/commits/58546a17c4e78aedf55aa3ae49e81d421bdca4a6)</u>_

_stated:_


_The_ _`_impl`_ _return value name was removed. The_ _`sender`_ _case was kept because it's_

_used and we consider it has better readability._

### **N-23 Code Style Suggestions - Phase 3**


The check in <u>`[Initializable.initializer](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/proxy/utils/Initializable.sol#L93)`</u> is very complex and difficult to read, which

makes it unnecessarily hard to maintain and audit. The code can be improved by documenting

the logic of the check and splitting the conditional logic into multiple temporary variables that

are appropriately named. For example, consider refactoring in the style of the code below:

```
// first call is allowed
bool firstCall = (isTopLevelCall && _initialized == 0);
// calls at construction time are allowed to allow multiple constructors to run their
inits.
// the version check ensures the version number cannot be reduced
// in the case version > 1 was already set by `reinitializer` or `_disableInitializers`
bool callDuringConstruction = (address(this).code.length == 0 && _initialized == 1);
if (!firstCall && !callDuringConstruction) {
  revert AlreadyInitialized();
}

```

**_Update:_** _Resolved in_ _<u>[pull request #4576. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4576)</u>_


_Refactored using intermediate variables and added explanatory comment._


Contracts 5.0 Release − Notes & Additional Information − 51


### **N-24 Some ERC-721 Features Might Be Atomically** **Reset**

The `ERC-721` token has many extensions and among them, there are the <u>[royalties](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/extensions/ERC721Royalty.sol)</u> and the

<u>[URI storage](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/extensions/ERC721URIStorage.sol)</u> ones. If a particular `tokenId` is first burned and then re-minted, that specific

token will have all of these features reset, <u>[the custom URI](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/extensions/ERC721URIStorage.sol#L75)</u> and <u>[royalties information](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/extensions/ERC721Royalty.sol#L35)</u> but also the

specific <u>[approvals.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/ERC721.sol#L257)</u>


Consider whether this should be documented so that users know the potential mechanisms

involved.


Notice that <u>`[ERC721Wrapper](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/extensions/ERC721Wrapper.sol)`</u> offers a `withdrawTo` and `depositFor` flow that can be

called within the same transaction and will effectively burn and re-mint the same wrapped

`tokenId` achieving the mentioned reset.


Consider documenting that the wrapper can be used in an atomic way, especially since the

receiver of any wrapped token can be a contract on itself and re-enter the wrapper contract on

the `onERC721Received` hook.


**_Update:_** _Resolved in_ _<u>[pull request #4561. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4561)</u>_


_We don't think atomic reset is necessarily a problem, but agree that allowing the user to_

_reset values is potentially a problem, so we're removing it._

### **N-25 Missing or Incorrect Docstrings - Phase 3**


Throughout the codebase, there are instances where docstrings are missing, incorrect or can

benefit from a rephrase:


   - The `burn` function <u>[docstrings](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/extensions/ERC721Burnable.sol#L21)</u> of the `ERC721Burnable` contract should clarify why the

internal `_burn` function is not used and make clear when it should be used.

   - The <u>`[transferFrom](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/ERC721.sol#L149)`</u> function of the `ERC721` contract that refers to the <u>[_isAuthorized](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/ERC721.sol#L197)</u>

<u>[function](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/ERC721.sol#L197)</u> as "_isApprove". Similarly for <u>[the comment](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/extensions/ERC721Burnable.sol#L22)</u> for the `_update` function of the

`ERC721Burnable` contract.








<u>`[hash](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/utils/cryptography/MessageHashUtils.sol#L23C19-L23C23)`</u> should be `messageHash` in `MessageHashUtils` contract.

<u>`[ECDSA.tryRecover](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/utils/cryptography/ECDSA.sol#L36-L37)`</u> return values description is out of date.




- In the `ERC721Consecutive` contract <u>[some advisory docstrings](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/extensions/ERC721Consecutive.sol#L22-L28)</u> refer to the

`_beforeTokenTransfer` and `_afterTokenTransfer` hooks which have been

abandoned in the latest version.


Contracts 5.0 Release − Notes & Additional Information − 52


   - The <u>`[WARNING](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/ERC721.sol#L207-L208)`</u> <u>docstring</u> for the `_checkAuthorized` function in the `ERC721` contract

unclearly suggests that the `_isAuthorized` function checks whether the `owner`

address is the actual token owner, <u>[while this is not true.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/ERC721.sol#L195)</u>

   - The <u>[onlyRole](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/access/AccessControl.sol#L63-L65)</u> and <u>[_checkRole](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/access/AccessControl.sol#L99-L101)</u> docstrings in `AccessControl` describe the regular

expression format of the previous revert reason string, which has been replaced with a

custom error.

   - The documentation of `Initializable` 's <u>`[initializer](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/5ae630684a0f57de400ef69499addab4c32ac8fb/contracts/proxy/utils/Initializable.sol#L83-L87)`</u> is misleading since it

mentions that the function protected by it can only be invoked once, or if nested within

the constructor. However, the methods protected by it can be invoked any number of

times during construction, and do not have to be nested. An example contract below is

supported:

```
 contract MultipleInits is Initializable {
  constructor() initializer {
     initialize();
     initialize();
  }
  function initialize() public initializer {}

```

It appears that this is a known edge case since the <u>[contract documentation](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/5ae630684a0f57de400ef69499addab4c32ac8fb/contracts/proxy/utils/Initializable.sol#L36-L37)</u> warns about

multiple calls to `initializer` -protected methods. Consider clarifying the method

documentation to prevent confusion regarding the allowed use cases and the lack of

protection from multiple initializations.


Consider reviewing the entire codebase for more occurrences and fixing the suggested ones.


**_Update:_** _Partially resolved in_ _<u>[pull request #4581. The](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4581)</u>_ _`burn`_ _function of the_ _`ERC721Burnable`_

_extension contract makes no comments about why the internal_ _`_burn`_ _function is not used._

### **N-26 Lack of Event Emission - Phase 3**


In the <u>`[ERC2981](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/common/ERC2981.sol)`</u> contract, used within <u>`[ERC721Royalty](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/extensions/ERC721Royalty.sol#L35)`</u>, there are no events emitted every

time a <u>[custom](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/common/ERC2981.sol#L135)</u> or <u>[default](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/common/ERC2981.sol#L107)</u> royalty's information is being reset.


Consider emitting events every time a sensitive storage action is performed.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


_We are following ERC-2981, which does not specify any events. We don't want to add_

_proprietary events that are not a part of the standard._


Contracts 5.0 Release − Notes & Additional Information − 53


### **N-27 Repeated Code**

In the `ERC721` contract there are two places in which code can be optimized and reused with

little refactoring.


   - The <u>`[ownerOf](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/ERC721.sol#L71)`</u> function could make use of <u>`[_requireMinted](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/ERC721.sol#L433)`</u> logic to use the same

logic.

   - The `auth` parameter is checked to not be the zero address two times, one <u>[inside the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/ERC721.sol#L251)</u>

<u>`[_update](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/ERC721.sol#L251)`</u> function and one inside the <u>`[_isAuthorized](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/ERC721.sol#L199)`</u> <u>function, called within</u>

`_update` execution exclusively. If the `_isAuthorized` function is meant to be

triggered exclusively within the `_update` one, consider removing the second check.


Consider consolidating the logic in less code and reusing the same pattern as much as

possible.


**_Update:_** _Partially resolved in_ _<u>[pull request #4566. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4566)</u>_


_Partially fixed only for the ERC721 item, with a rename of_ _`_requireMinted`_ _to_

_`_requireOwned`_ _. For_ _`_update`_ _we have decided not to accept the suggestion. We_

_want_ _`_isAuthorized`_ _to be correct when called directly, and not just through_

_`_update`_ _. For correct semantics we need to check that_ _`spender`_ _is not zero,_

_otherwise the function returns true when the token has no approved address._

### **N-28 Hardcoded Magic Constant**


In the `ERC721URIStorage` contract, there is the `0x49064906` hardcoded value.


Consider adding a comment specifying where the hardcoded magic constant comes from and

defining it in a constant variable instead.


**_Update:_** _Resolved in_ _<u>[pull request #4560.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4560)</u>_

### **N-29 _setTokenURI Does Not Allow Setting URI** **for Non-Existing Tokens**


The <u>`[_setTokenURI](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/extensions/ERC721URIStorage.sol#L57)`</u> function of the `ERC721URIStorage` contract doesn't allow setting the

URI for non-existent `tokenId` .


This prohibits using this contract with a common use case in which `tokenId` metadata are

set even before minting the corresponding token.


Contracts 5.0 Release − Notes & Additional Information − 54


Consider lifting this restriction to not limit the library's flexibility.


**_Update:_** _Resolved in_ _<u>[pull request #4559.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4559)</u>_

### **N-30 Default Handling Contract of the** **DEFAULT_ADMIN_ROLE Is Complex**


The <u>`[AccessControl](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/access/AccessControl.sol)`</u> <u>contract</u> is the basic building block for constructing role-based access

control mechanisms. Each role may have its own administrator entity. However, the

administrator account of the `DEFAULT_ADMIN_ROLE` serves as the default administrator for

all roles for which a specific administrator is not defined. Thus the `DEFAULT_ADMIN_ROLE`

comes with the great power that handles other roles, essentially granting or revoking access

from members.


The `AccessControl` contract makes no assumptions and provides no special rules for the

owner of the `DEFAULT_ADMIN_ROLE` . In essence, users are encouraged to use the

<u>`[AccessControlDefaultAdminRules](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/access/extensions/AccessControlDefaultAdminRules.sol)`</u> <u>contract</u> as an extension to the basic

`AccessControl`, which defines <u>[timelock-like procedures](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/access/extensions/AccessControlDefaultAdminRules.sol#L23-L25)</u> for the sensitive operations of the

default admin. However, the advanced security of the `AccessControlDefaultAdminRules`

contract comes with a certain level of complexity and could be erroneously used or modified

by non-sophisticated development teams.


To assist developers with the somewhat complex management of the

`DEFAULT_ADMIN_ROLE`, consider providing more extensive documentation for the

`AccessControlDefaltAdminRules` contract, explaining the purpose and mechanics of the

two delay mechanisms, along with example use cases. Also consider expanding the existing

docstring of the `AccessControl` contract to provide more specifics about the advanced

security guarantees provided by `AccessControlDefaultAdminRules`, such as the delay

mechanisms, to help development teams choose which contract is most suitable for their

projects.


**_Update:_** _Acknowledged, will resolve. The OpenZeppelin Contracts team stated:_


_We will address this with documentation in the near future._

### **N-31 Unused Named Return Variables - Phase 3**


The named return variable `digest` is unused in `MessageHashUtils` 's

<u>`[toEthSignedMessageHash(bytes memory message)](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/utils/cryptography/MessageHashUtils.sol#L48)`</u> and


Contracts 5.0 Release − Notes & Additional Information − 55


<u>`[toDataWithIntendedValidatorHash](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/utils/cryptography/MessageHashUtils.sol#L61C14-L66)`</u> functions. Similarly, in the

`AccessControlDefaultAdminRules` contract, the return variables `newAdmin`,

`schedule` of the <u>`[pendingDefaultAdmin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/access/extensions/AccessControlDefaultAdminRules.sol#L177-L178)`</u> <u>function</u> and return variables `newDelay`,

`schedule` of the <u>`[pendingDefaultAdminDelay](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/access/extensions/AccessControlDefaultAdminRules.sol#L192-L194)`</u> <u>function</u> are unused.


For consistency with the rest of the codebase, consider assigning values to these return

variables instead of explicitly returning. Alternatively, consider removing the named variables

from the signatures of the methods in these cases.


**_Update:_** _Partially resolved in_ _<u>[pull request #4573. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4573)</u>_


_Removed some, but in the case of multiple return values we kept the names even if_

_unused, because we think they help to understand what each return value is._

### **N-32 Allowance and Approval Inconsistencies -** **Phase 3**


The `ERC721` contract allows any user to <u>`[approve](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/ERC721.sol#L115)`</u> the `address(0)` as spender. This is

inconsistent with what is done in <u>`[ERC20](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC20/ERC20.sol#L342)`</u> . Disallowing such approvals would also be in

agreement with the relevant restriction for `setApprovalForAll` which is followed both in

ERC-1155 and ERC-721.


Consider being consistent with all kinds of tokens in how approvals are managed.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


_In ERC721,_ _`approve`_ _of_ _`address(0)`_ _is used to remove the currently approved_

_address._

### **N-33 Confusing Revert Messages Due to** **Underflow**


If both `leaves` and `proof` are empty arrays in `processMultiProof` or

`processMultiProofCalldata` [, the respective length checks (1, 2) will revert due to](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/utils/cryptography/MerkleProof.sol#L121)

underflow.


Consider checking for this condition, and emitting the same

`MerkleProofInvalidMultiproof` in this case.


**_Update:_** _Resolved in_ _<u>[pull request #4564.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4564)</u>_


Contracts 5.0 Release − Notes & Additional Information − 56


### **N-34 Missing or Incorrect Docstrings - Phase 4**

Throughout the codebase, there are instances where docstrings are missing, incorrect or can

benefit from a rephrase:


In `AccessManaged.sol` :


   - The `_checkCanCall` function contains a confusingly named variable <u>`[allowed](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManaged.sol#L105)`</u>, which

is not purely a yes/no indicator of whether the caller is allowed to call the target function.

A call may still be able to execute even if `!allowed` is true. Consider adding a

comment that clarifies this behavior.


In `AccessManager.sol` :


  - The comments for the `Access` data structure <u>refer to an</u> <u>`[onlyGroup](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L65)`</u> <u>modifier</u> which is

not present in the codebase.

   - The <u>`[_canCallExtended](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L799)`</u> <u>function</u> returns a `(bool, uint32)` tuple but has no

documentation that explains how to interpret these values, and determining their

meaning is not trivial.

   - The <u>`[_getAdminRestrictions](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L759)`</u> <u>function</u> returns a `(bool, uint64, uint32)` tuple

but has no documentation that explains how to interpret these values, and determining

their meaning is not trivial.

   - There is <u>[a stale docstring](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L30-L32)</u> which refers to three possible modes `(open, custom,`

`closed)` while no such categorization is implemented.

   - The <u>docstring of the</u> <u>`[cancel](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L687)`</u> <u>function</u> should mention that in addition to the proposer

and guardian, a global administrator <u>[is also allowed to call it.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L699)</u>

   - The `renounceGroup`, `revokeGroup`, and `_revokeGroup` docstrings all say "Emits

a {GroupRevoked} event" instead of "May emit". If the targeted account is not a member

of the group, the shared function `_revokeGroup` will return before emitting the

`GroupRevoked` event.

   - The <u>docstring of</u> <u>`[setClassFunctionGroup](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L454)`</u> says it emits a

"FunctionAllowedGroupUpdated" event. This should be changed to

"ClassFunctionGroupUpdated".

   - The <u>docstring of</u> <u>`[_setClassFunctionGroup](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L467)`</u> says this function is the internal version

of "setFunctionAllowedGroup". This should be changed to "setClassFunctionGroup".

   - The <u>docstring of</u> <u>`[_setClassFunctioNGroup](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L469)`</u> says it emits a

"FunctionAllowedGroupUpdated" event. THis should be changed to

"ClassFunctionGroupUpdated".


Contracts 5.0 Release − Notes & Additional Information − 57


   - The <u>docstring of</u> <u>`[setClassAdminDelay](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L484)`</u> says it emits a

"FunctionAllowedGroupUpdated" event. This should be changed to

"ClassAdminDelayUpdated".

   - The `_checkAuthorized` function contains a confusingly named variable <u>`[allowed](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L745)`</u>,

which is not purely a yes/no indicator of whether or not the call is authorized. A call may

still be allowed to execute even if `!allowed` is true. Consider adding a comment that

clarifies this behavior.

   - The <u>`[AccessMode](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L54-L57)`</u> and <u>`[Class](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L81-L84)`</u> structs are undocumented.


In `EnumerableMap.sol` :


  - An isolated comment <u>[refers to a non-existent data structure](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/utils/structs/EnumerableMap.sol#L55)</u> <u>`[Uint256ToAddressMap](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/utils/structs/EnumerableMap.sol#L55)`</u>,

which has been renamed to `UintToAddressMap` .


In `IAccessManaged.sol` :


   - No documentation is present in this file for `IAccessManaged` interface and its

functions, events, and errors.


In `IAccessManager.sol` :


   - Except for <u>[three events, no other documentation is present in this file for the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/IAccessManager.sol#L9-L22)</u>

`IAccessManager` interface and its functions, events, and errors.


In `Time.sol` :


   - The <u>[docstring for the type](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/utils/types/Time.sol#L55)</u> <u>`[Delay](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/utils/types/Time.sol#L55)`</u> describes it as 128 bits long, but <u>its size is</u> <u>`[uint112](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/utils/types/Time.sol#L67)`</u> .

   - The <u>[docstring for the type](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/utils/types/Time.sol#L55)</u> <u>`[Delay](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/utils/types/Time.sol#L55)`</u> provides a <u>[visual representation of the packed values](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/utils/types/Time.sol#L58-L61)</u>

inside the `Delay` type but puts them in the wrong order: the `current value` and

`pending value` labels should be swapped so that `current value` occupies the

least significant `CCCCCCCC` bits in the diagram.


Consider reviewing the entire codebase for more occurrences of missing and incorrect

documentation, and fixing the suggested ones.


**_Update:_** _Partially resolved in_ _<u>[pull request #4586, pull request #4581. No extra documentation](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4586)</u>_

_has been added to the_ _`IAccessManaged`_ _and_ _`IAccessManager`_ _interfaces._


Contracts 5.0 Release − Notes & Additional Information − 58


### **N-35 Refactor AccessManager Data Structures** **to Reduce Design Complexity**

The `AccessManager` contract organizes the access rights per each managed contract's

function selector. For this purpose, <u>[the following mappings and structs are used:](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L89-L91)</u>




- `_contractMode` mapping: Given a target contract address, returns an `AccessMode`

struct. `AccessMode` contains a `classId` and a boolean value denoting whether the

contract is "closed" or not.




- `_classes` mapping: Given a class's id, returns a `Class` struct. `Class` contains a

mapping with the allowed group ( `groupId` ) per function selector and an `adminDelay`

value, which is a delay applied on some class-level administrative operations.




- `_groups` mapping: Given a member group's id, returns a `Group` struct. `Group`



contains a mapping with the access details per member along with some other data.


Essentially, there are two intermediary structs ( `AccessMode` and `Class` ) involved with linking

a target contract to its member groups per function selector. While this distinction could help

batch some update operations for similar target contracts which share the same class of

access rules, it is unnecessary for the most common use cases. At the same time, this

distinction increases the conceptual complexity of the already complex `AccessManager`

contract.


Consider consolidating the `AccessMode` and `Class` structs into a single data structure that

eliminates the intermediate `Class` concept, in order to simplify the design and reduce the

conceptual complexity in regards to the configuration of the access management rules.


**_Update:_** _Resolved in_ _<u>[pull request #4562. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4562)</u>_


_Removed classes to simplify. Additionally renamed_ _`AccessMode`_ _to_ _`TargetConfig`_ _,_

_and functions like_ _`getContractClass`_ _to_ _`getTargetClass`_ _to avoid the generic_

_"contract" concept._

### **N-36 Unused Variables**


In the `AccessManager` contract, the <u>`[_adminDelays](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L93)`</u> variable is declared but never used.


Consider removing the unused variable for clarity and readability.


**_Update:_** _Resolved in_ _<u>[pull request #4565.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4565)</u>_


Contracts 5.0 Release − Notes & Additional Information − 59


### **N-37 Inconsistent Use of Named Return Variables** **- Phase 4**

Almost all functions in `IAccessManager` that return a value do not use named return

variables, but the <u>`[canCall](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/IAccessManager.sol#L53)`</u> and <u>`[getContractClass](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/IAccessManager.sol#L57)`</u> functions do use named values. The

<u>`[canCall](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/IAuthority.sol#L12)`</u> function in the `IAuthority` interface also returns a named value.


While inconsistent with the rest of the `AccessManager` codebase, these named return values

still provide valuable information to the reader. Consider removing the named values but

adding documentation that provides the same information in the functions' docstrings.


**_Update:_** _Acknowledged, will resolve. The OpenZeppelin Contracts team stated:_


_Guidelines and consistency for named return variables will be reviewed for a future_

_release._

### **N-38 Missing Zero Address Check in** **AccessManager Constructor**


The `AccessManager` constructor's job is to <u>[grant](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L109)</u> an `initialAdmin` address access to the

`ADMIN_GROUP` . However there is no check that ensures `initialAdmin` is not

`address(0)`, in which case the contract would be deployed without an admin role.

Attempting to correct this after the fact by calling the public `grantGroup` function would fail

because the function is protected by the `onlyAuthorized` modifier.


Consider checking that the initial administrator address is not `address(0)` upon the

contract's construction, in order to avoid the accidental deployment of contracts that cannot

be used.


**_Update:_** _Resolved in_ _<u>[pull request #4570.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4570)</u>_

### **N-39 Use of Custom Errors**


The `AccessManager` contract uses custom errors in nearly all cases. In contrast, the

`consumeScheduledOp` function <u>uses a</u> <u>`[require](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L660)`</u> <u>[statement with no error string](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L660)</u> for

reverting.


To improve the consistency of the codebase, consider reverting with a custom error instead of

using `require` .


Contracts 5.0 Release − Notes & Additional Information − 60


**_Update:_** _Resolved in_ _<u>[pull request #4575. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4575)</u>_


_Added a custom error. Additionally, we changed the return value to be a bytes4 selector_

_in this same PR, out of caution due to potential selector clashes._

### **N-40 Code Style Suggestions - Phase 4**


In the `AccessManager` contract, the <u>`[grantGroup](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L271)`</u> <u>function</u> has dual-purpose functionality: it

handles granting access to a new member of a group, and also updating an existing member's

`delay` value. In both cases, a `GroupGranted` event is emitted, even if the member has

already been granted access to the group.


To favor explicitness and simplify the code, consider adding a separate function to handle the

case of updating a member's `delay` value. In addition, consider emitting a separate event for

such updates.


**_Update:_** _Resolved in_ _<u>[pull request #4569. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4569)</u>_


_Here we prioritize fewer number of external functions and events because we think the_

_information can be accurately represented in events. A series of_ _`GroupGranted`_

_events should be interpreted as observing that the account has the group with a specific_

_execution delay, starting at the_ _`since`_ _parameter. If there are multiple_ _`GroupGranted`_

_events without any revokes, they represent updates to the execution delay. We added a_

_boolean to make it very explicit in each event whether the account is a new member in_

_the group, or just its execution delay was modified._

### **N-41 TODO Comments**


The <u>`[minSetback function](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L155)`</u> in the `AccessManager` contract has a TODO comment that

states the setback value should be changed from 0 days to 1 day. Additionally, <u>[lines 122-123](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L122-L123)</u> in

the `canCall` docstring appear to be a TODO comment without a TODO tag.


Consider tracking these changes in the project's issue backlog.


**_Update:_** _Resolved in_ _<u>[pull request #4557. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4557)</u>_


_Fixed by setting the value to 5 days, except for_ _`grantGroup`_ _which we decided to_

_keep as 0 days for reasons explained in a comment._


Contracts 5.0 Release − Notes & Additional Information − 61


### **N-42 Gas Optimization - Phase 4**

In `AccessManager` 's `setClassFunctionGroup` function, the length of the `selectors`

array being iterated could be saved in a local variable that replaces <u>`[selectors.length](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L461)`</u> in

the `for` loop.


Consider making the above change to reduce gas consumption.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


_Since this array is in calldata we don't expect to see significant improvement so we are_

_not prioritizing it at the moment._

### **N-43 Typographical Errors - Phase 4**


Consider addressing the following typographical errors:


In `AccessManager.sol` :


   - <u>[Line 48: Remove the extra space between "danger" and "associated".](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L48)</u>

   - <u>[Line 59: "This structures fit" should be "This structure fits".](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L59)</u>

   - <u>[Line 62: "are not available" should be "is not available" (or "group permission" should be](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L62)</u>

"group permissions").

   - <u>[Line 73: "grand" should be "grant".](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L73)</u>

   - <u>[Line 95: "transcient" should be "transient".](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L95)</u>

   - <u>[Line 126" "contract" should be "contracts".](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L126)</u>

   - <u>[Line 127: "call" should be "calls".](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L127)</u>

   - <u>[Line 208: "operation" should be "operations".](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L208)</u>

   - <u>[Line 208: "require" should be "requires".](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L208)</u>

   - <u>[Line 585: "restriction to that apply" should be "restrictions that apply".](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L585)</u>


In `Time.sol` :


   - <u>[Line 47: "so guarantees" should be "some guarantees".](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/utils/types/Time.sol#L47)</u>

   - <u>[Line 49: "is the delay" should be "if the delay".](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/utils/types/Time.sol#L49)</u>

   - <u>[Line 116: "after at a timepoint" should be "after a timepoint".](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/utils/types/Time.sol#L116)</u>


**_Update:_** _Resolved in_ _<u>[pull request #4571.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4571)</u>_


Contracts 5.0 Release − Notes & Additional Information − 62


### **N-44 Mismatch Between Contract and Interface**

The <u>`[getSchedule](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L570)`</u> function in `AccessManager` is defined as a `view` function in the

implementation, but in the `IAccessManager` interface, <u>the</u> <u>`[view](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/IAccessManager.sol#L95)`</u> <u>[keyword is missing.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/IAccessManager.sol#L95)</u>


To avoid confusion, consider adding the `view` keyword to the `getSchedule` function's

definition in `IAccessManager` .


**_Update:_** _Resolved in_ _<u>[pull request #4558. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4558)</u>_


_Fixed by adding_ _`view`_ _modifier to_ _`getSchedule`_ _and two other functions that had the_

_same issue. We consider this more serious than a Note, because callers using the_

_interface would generate code that uses_ _`CALL`_ _instead of_ _`STATICCALL`_ _._

### **N-45 Naming Suggestions - Phase 4**


To favor explicitness and readability, several parts of the contracts may benefit from better

naming. Consider making the following changes:


   - The `EnumerableSet` contract uses the word "index(es)" to name both <u>[indexes](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/utils/structs/EnumerableSet.sol#L93-L94)</u> and

<u>[indexes incremented by one, which hinders the understanding of the code. Consider](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/utils/structs/EnumerableSet.sol#L84-L85)</u>

renaming indexes incremented by one to "position".

   - The `EnumerableSet` contract refers to its elements as "value(s)". The word "value",

however, is generic and creates unnecessary confusion especially when

`EnumerableMap` comes into play (where the word "value" refers to the value in a key
value pair). Consider using more specific words for set elements, such as "element" or

"member".

   - The `AccessManager` contract uses the word `delay` to name both <u>[the execution delay](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L66)</u>

<u>[of a group's member](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L66)</u> as well as <u>[the grant delay of a group. Renaming these two variables](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L78)</u>

to indicate their specific purpose would improve the contract's readability.

   - In the `AccessManaged` contract, the function `_checkCanCall` makes an external call

to the `AuthorityUtils` contract and <u>[names the boolean return variable "allowed".](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManaged.sol#L105)</u>

However, even if `allowed` is `false`, this does not necessarily mean that the caller is

unauthorized, but rather that the operation falls under a delay. In this case, if the

operation has been scheduled and the delay duration has been completed then the

execution proceeds normally, <u>[following an unintuitive flow. Consider renaming the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManaged.sol#L111-L115)</u>

variable "allowed" to a word that accurately denotes its content, such as

"immediatelyAllowed".


Contracts 5.0 Release − Notes & Additional Information − 63


**_Update:_** _Partially resolved in_ _<u>[pull request #4577, pull request #4562. The OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4577)</u>_

_Contracts team stated:_


_In_ _`AccessManager.canCall`_ _renamed the_ _`allowed`_ _return variable to_ _`immediate`_ _._

_In_ _`EnumerableSet`_ _used position and index as suggested, but kept "values" after_

_seeing it is also used for sets in standard libraries in other ecosystems (C++, JavaScript)._

### **N-46 Missing or Incorrect Docstrings - Phase 5**


Throughout the codebase, there are instances where docstrings are missing, incorrect, or can

benefit from a rephrase:


In `Governor.sol` :


   - The <u>docstring for the</u> <u>`[_governanceCall](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/Governor.sol#L51-L54)`</u> <u>variable</u> refers to `_beforeExecute` and

`_afterExecute` functions which do not exist in the codebase anymore.

   - The docstring for the `_queueOperations` function <u>refers to the</u> <u>`[_queue](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/Governor.sol#L378)`</u> <u>function</u>

which does not exist in the codebase.

   - <u>["Any asset sent to the {Governor} will be inaccessible"](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorTimelockControl.sol#L17-L18)</u> could mention that assets can be

recovered through the relay function of the `Governor` contract.

  - The comment <u>["ProposalCore is just one slot. We can load it from storage to stack with a](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/Governor.sol#L138)</u>

<u>[single sload"](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/Governor.sol#L138)</u> is wrong, as the struct actually takes two slots.


In `TimelockController.sol` :


   - The <u>docstring for the</u> <u>`[isOperation](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/TimelockController.sol#L168)`</u> <u>function</u> refers to a "Pending" state, which does

not exist. It should refer to the `Waiting` state instead.


In `GovernorTimelockControl.sol` :


   - There is a <u>`[WARNING](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorTimelockControl.sol#L20-L23)`</u> <u>docstring</u> pointing out some risks relevant to the sensitive access

roles of the `TimelockController` contract. However, the list of risks is neither

accurate nor complete. More specifically, the `relay` function of the `Governor`

contract is in fact secure against malicious role holders. Furthermore, apart from the risk

of malicious cancelers causing a DoS, it is also possible that malicious proposers and

executors create and execute arbitrary proposals bypassing the voting procedure.

Consider listing this risk as well. Consider also documenting that the

`GovernorTimelockControl` module can be used in two different secure ways:




- `TimelockController` is set as the owner of the target contracts. Then, in order

to mitigate the risks mentioned above, a secure setup of `TimelockController`

is needed where the governor contract is the only admin and proposer.


Contracts 5.0 Release − Notes & Additional Information − 64


`GovernorTimelockControl` is set as the owner of the target contracts. Then



the proposals should be structured in a way that all its actions are forwarded by

the `relay` function.


In `GovernorTimelockAccess.sol` :


   - Consider documenting the fact that scheduling the same call is prevented by the

`AccessManager`, while as a workaround it is recommended to append extra calldata,

which will function as a salt.

   - Consider correcting the docstring of the <u>`[_detectExecutionRequirements](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorTimelockAccess.sol#L252)`</u> <u>function,</u>

which appears to be outdated.


In `GovernorVotesQuorumFraction.sol` :


   - <u>["If history is empty, fallback to old storage"](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorVotesQuorumFraction.sol#L48)</u> is outdated because the fallback mechanism

has been removed.


In `GovernorSettings.sol` :


  - The comment <u>["voting period must be at least one block long"](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorSettings.sol#L96)</u> in the

`GovernorSettings` contract is not accurate, since the period can also be in seconds.


In `DoubleEndedQueue.sol` :


   - The <u>docstring for the</u> <u>`[Bytes32Deque](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/utils/structs/DoubleEndedQueue.sol#L34-L44)`</u> <u>struct</u> refers to the use of signed integers for

indices, but the queue <u>[now uses unsigned values.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/utils/structs/DoubleEndedQueue.sol#L48)</u>

   - The <u>docstring for the</u> <u>`[Byres32Deque](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/utils/structs/DoubleEndedQueue.sol#L42-L43)`</u> <u>struct</u> states that indices lie in the range

`[begin, end)`, but due to intentional overflow/underflow that allows indices to wrap

around, `_begin` can be larger than `_end` (Example: push 1 element to the front of an

empty queue).

   - For consistency, the <u>[docstring](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/utils/structs/DoubleEndedQueue.sol#L51-L53)</u> for the `pushBack` function should contain the following

note: "Reverts with `QueueFull` if the queue is full".

   - For consistency, the <u>[docstring](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/utils/structs/DoubleEndedQueue.sol#L79-L81)</u> for the `pushFront` function should contain the following

note: "Reverts with `QueueFull` if the queue is full".


In `MerkleProof.sol` :


   - The `_hashPair` and `_efficientHash` functions are undocumented.

   - The `_efficientHash` function contains <u>[undocumented assembly code.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/utils/cryptography/MerkleProof.sol#L220-L224)</u>


Contracts 5.0 Release − Notes & Additional Information − 65


In `Initializable.sol` :


   - The `reinitializer` modifier's docstring <u>[states: The comment "WARNING: setting the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/proxy/utils/Initializable.sol#L137)</u>

version to 255 will prevent any future reinitialization" is incorrect. The version value used

to disable reinitialization has been changed from `255` to `2^64 - 1` .


Consider reviewing the entire codebase for more occurrences of missing and incorrect

documentation, and fixing the suggested ones.


**_Update:_** _Resolved in_ _<u>[pull request #4601.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4601)</u>_

### **N-47 Gas Optimizations - Phase 5**


In the `MerkleProof` contract, the <u>`[processProof](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/utils/cryptography/MerkleProof.sol#L49)`</u> and <u>`[processProofCalldata](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/utils/cryptography/MerkleProof.sol#L49)`</u>

functions both access `proof.length` inside their respective `for` loops.


Consider saving this length value in a local variable prior to entering each loop.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


_Since the arrays are in memory or calldata, reading the length is not so expensive and_

_this is not an optimization we're prioritizing._

### **N-48 Inconsistent Use of Named Return** **Variables - Phase 5**


With the exception of `processMultiProof`, `processMultiProofCalldata`, and

`_efficientHash`, the other functions in the <u>`[MerkleProof](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/utils/cryptography/MerkleProof.sol)`</u> <u>contract</u> do not use named

return variables.


While this approach to naming is inconsistent, these named return values still provide valuable

information to the reader. Consider removing the named values but adding documentation that

provides the same information in the docstrings of these functions.


**_Update:_** _Acknowledged, will resolve. The OpenZeppelin Contracts team stated:_


_Guidelines and consistency for named return variables will be reviewed for a future_

_release._


Contracts 5.0 Release − Notes & Additional Information − 66


### **N-49 Unused Import - Phase 5**

Within the `GovernorTimelockCompound` contract, the <u>`[IERC165](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorTimelockCompound.sol#L8)`</u> <u>import</u> is not used.


Consider removing unused imports to improve the overall clarity and readability of the

codebase.


**_Update:_** _Resolved in_ _<u>[pull request #4590.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4590)</u>_

### **N-50 Inconsistent Solidity Version Used in** **`GovernorStorage`**


One of the 5.0 release changes is bumping the Solidity version to `^0.8.20` . This change has

been applied to all files except for <u>`[GovernorStorage](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorStorage.sol#L3)`</u>, which has version `^0.8.19` but

extends a `^0.8.20` -versioned <u>`[Governor](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/Governor.sol#L4)`</u> <u>contract</u> anyways.


Consider adapting the Solidity version to be consistent with the rest of the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #4589.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4589)</u>_

### **N-51 Long Comment Lines**


The style guide of the codebase appears to foresee a maximum line-width of 120 characters.

However, this is not to fully adhered to. For instance, see the comment on the

<u>`[GovernorStorage](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorStorage.sol#L7-L14)`</u> <u>contract.</u>


Consider adhering to the ruler of 120 characters for the code to be more readable in split
screen or diff-views.


**_Update:_** _Resolved in_ _<u>[pull request #4600.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4600)</u>_

### **N-52 Unused Named Return Variables - Phase 5**


In the contract `GovernornCountingSimple` <u>[the named return variables](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorCountingSimple.sol#L50)</u> `againstVotes`,

`forVotes` and `abstainVotes` are unused in the `proposalVotes` function.


For consistency with the rest of the codebase, consider assigning values to these return

variables instead of explicitly returning. Alternatively, consider removing the named variables

from the signatures of the methods in these cases.


Contracts 5.0 Release − Notes & Additional Information − 67


**_Update:_** _Acknowledged, will resolve. The OpenZeppelin Contracts team stated:_


_Guidelines and consistency for named return variables will be reviewed for a future_

_release._

### **N-53 Typographical Errors - Phase 5**


Consider addressing the following typographical errors:


   - Throughout the codebase, there is an inconsistency between using the word "Canceled"

and "Cancelled". Consider adhering to American or British English.


In `Governor.sol` :


   - <u>[Line 19: "though" should be "through"](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/Governor.sol#L19)</u>


In `TimelockController.sol` :


   - <u>[Line 167: "correspond" should be "corresponds"](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/TimelockController.sol#L167)</u>


In `GovernorTimelockControl.sol` :


   - <u>[Line 114: "as already been queued" should be "has already been queued"](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorTimelockControl.sol#L114)</u>

   - <u>[Line 38: "where the nonce is that which we get back from the manager" should be](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorTimelockAccess.sol#L37-L38)</u>

"where the nonce is received from the manager"

   - <u>[Line 21: "powers that they must be trusted" should be "powers that must be trusted"](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorTimelockControl.sol#L21)</u>

   - <u>[Line 114: "if it as already been queued" should be "if it has already been queued"](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorTimelockControl.sol#L114-L115)</u>


In `Nonces.sol` :


   - <u>[Line 16: "an the" should be "the" .](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/utils/Nonces.sol#L16)</u>


In `MerkleProof.sol` :


   - <u>[Line 16, Line 17, Line 69, Line 72, Line 86, Line 103, Line 115, Line 161: "merkle" should](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/utils/cryptography/MerkleProof.sol#L16)</u>

be "Merkle"


**_Update:_** _Resolved in_ _<u>[pull request #4595.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4595)</u>_


Contracts 5.0 Release − Notes & Additional Information − 68


### **N-54 Naming Suggestions - Phase 5**

To favor explicitness and readability, several parts of the contracts may benefit from better

naming. Consider making the following changes:


   - In `Votes.sol`, the <u>`[delegates](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/utils/Votes.sol#L126)`</u> <u>function</u> only returns a single delegate address, and is

similarly named to the `delegate` function. Consider renaming `delegates` to

`getDelegate` .

   - In `Votes.sol`, an address that delegates its voting units is often referred to as an

<u>[account](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/utils/Votes.sol#L37)</u> and an address receiving delegated votes is often referred to as a <u>[delegatee.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/utils/Votes.sol#L39)</u>

This naming consistency is also observed in the local variables for instance in the

<u>[delegate](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/utils/Votes.sol#L133)</u> function. However there are some instances where a delegatee is referred to as

an account, for instance in <u>[getVotes, getPastVotes](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/utils/Votes.sol#L76)</u> functions. Consider adopting this

naming convention consistently throughout the contract for clarity and readability.

   - Throughout the codebase state variables have a leading underscore, while function

parameters have no underscores. Consider sticking to this format for the <u>`[name_](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/Governor.sol#L75)`</u>

<u>[parameter](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/Governor.sol#L75)</u> of the `Governor` constructor.

   - The <u>`[ProposalCore](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/Governor.sol#L37)`</u> <u>struct</u> contains three variables that handle timepoints, namely

`voteStart`, `voteDuration` and `eta` . While the time unit of the first two is expected

to be decided by the <u>`[clock()](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorVotes.sol#L25)`</u> <u>[implementation, the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorVotes.sol#L25)</u> `eta` value follows the block

timestamp as happens in the <u>`[GovernorTimelockControl](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorTimelockControl.sol#L93)`</u> and

<u>`[GovernorTimelockAccess](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorTimelockAccess.sol#L164)`</u> extensions. As the timepoints are generally expected to

follow the same units within a module it is possible that the users misinterpret the value

of the timepoints. Consider renaming `eta` to `etaSeconds` or something similar to

underline the possible inconsistency and avoid false expectations.

   - The `TimelockController` implements the roles proposer, executor, and canceller.

The <u>[proposer role](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/TimelockController.sol#L25)</u> can be confusing in the context of governance contracts, which

involves making actual proposals. However, in the context of the

`TimelockController`, the proposer role is able to schedule calls, which could be a

successful proposal. Hence, calling the role scheduler would be more fitting.

   - Throughout the <u>`[TimelockController](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/TimelockController.sol)`</u> <u>contract, a single call's calldata is called</u>

`data`, while a batch-call's calldata is called `payloads` . Consider adhering to

`payload(s)` to clarify that it is referring to same information.

   - In the <u>`[ProposalCreated](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/IGovernor.sol#L117-L118)`</u> <u>event</u> the parameters `voteStart` and `voteEnd` indicate

the starting and ending timepoints of the voting period. However, the <u>[getter functions](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/Governor.sol#L186-L194)</u> for

these values are named after `proposalSnapshot` and `proposalDeadline`

respectively. Consider adopting a consistent naming to avoid confusion.


**_Update:_** _Partially resolved in_ _<u>[pull request #4599. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4599)</u>_


Contracts 5.0 Release − Notes & Additional Information − 69


_Renamed_ _`ProposalCore.eta`_ _to_ _`etaSeconds`_ _. Many of the other recommendations_

_would imply breaking changes with GovernorBravo or with OpenZeppelin Contracts 4.x_

_that we do not want to make. The other recommendations will be considered in the_

_future._

### **N-55 Extraneous Code**


The following cases of extraneous code have been identified:


   - In the `Governor` contract, the validity of performing a specific action is usually checked

through the `_validateStateBitmap` function. However, this functionality is

duplicated within the <u>`[_castVote](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/Governor.sol#L631)`</u> <u>function, instead of utilizing the</u>

`_validateStateBitmap` function.

   - In the `Nonces` contract, the <u>`[_useCheckedNonce](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/utils/Nonces.sol#L39)`</u> <u>function</u> returns (assuming no revert)

the `current` nonce, which will always be equal to the input `nonce` . This eliminates the

need for the caller to ever check the return value. Consider removing the return value.


Consider addressing the above cases as suggested.


**_Update:_** _Resolved in_ _<u>[pull request #4588.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4588)</u>_

## **Client-Reported**

### **CR-01 Inconsistent Use of Hooks**


The `ERC20` and `ERC1155` contracts have been refactored to delete the

`_beforeTokenTransfer` and `_afterTokenTransfer` hooks in favour of a more robust

`_update` function. However, the <u>`[_beforeFallback](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/Proxy.sol#L77)`</u> hook of the `Proxy` contract hasn't

been removed.


To favor consistency, consider removing the `_beforeFallback` hook.


**_Update:_** _Resolved in_ _<u>[pull request #4502](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502)</u>_ _at commit_ _<u>[5a0e133. The OpenZeppelin Contracts team](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4502/commits/5a0e133df93f19e33d840891cc49d88f5327590a)</u>_

_stated:_


_The_ _`_beforeFallback`_ _hook is removed as suggested._


Contracts 5.0 Release − Client-Reported − 70


### **CR-02 Wrong Visibility for a Public Constant**

The `UPGRADE_INTERFACE_VERSION` <u>[variable](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/transparent/ProxyAdmin.sol#L23)</u> has `internal` visibility. However, the

<u>[docstrings](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/utils/UUPSUpgradeable.sol#L24)</u> clearly explain that this constant should be queried from the outside of the

contract's context and so it should be public instead.


Consider changing the variable visibility to `public` .


**_Update:_** _Resolved in_ _<u>[pull request #4382](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4382)</u>_ _at commit_ _<u>[121be5d.](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/121be5dd09caa2f7ce731f0806b0e14761023bd6)</u>_

### **CR-03 Inconsistent nonce Enumeration in** **`AccessManager`**


In the `AccessManager` contract, scheduled operations are assigned <u>a</u> <u>`[nonce](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/access/manager/AccessManager.sol#L95)`</u> <u>value</u> which is

<u>[sequentially incremented upon scheduling an](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/access/manager/AccessManager.sol#L633)</u> <u>`[operationId](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/access/manager/AccessManager.sol#L633)`</u> . This design allows

distinguishing active and potentially cancelled operations that share the same `operationId`

and is particularly useful <u>in the</u> <u>`[GovernorTimelockAccess](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/governance/extensions/GovernorTimelockAccess.sol#L197-L198)`</u> contract.


When successfully executing a scheduled operation, the whole `Schedule` struct of the

corresponding `operationId` <u>[is being deleted, essentially resetting the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/access/manager/AccessManager.sol#L718)</u> `nonce` . Note that

when canceling an operation the `nonce` entry of `Schedule` is not deleted. As a

consequence, the invariant where <u>the</u> <u>`[nonce](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/access/manager/AccessManager.sol#L583-L584)`</u> <u>[is an incremental value](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/adbb8c9d27e77452bc2253397908d3d044808e62/contracts/access/manager/AccessManager.sol#L583-L584)</u> for each `operationId`

breaks.


This error could interfere with the proposals execution and cancellation in the

`GovernorTimelockAccess` contract.


To fix this issue, consider retaining the `nonce` value when an operation is successfully

executed through `AccessManager` .


**_Update:_** _Resolved in_ _<u>[pull request #4603.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4603)</u>_

### **CR-04 AccessManager 's onlyAuthorized** **Functions Cannot Be Executed Through relay()**


The <u>`[AccessManager](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol)`</u> contract provides two ways to execute a delay-restricted function after

its scheduling period is completed:


1. directly call the restricted function


Contracts 5.0 Release − Client-Reported − 71


2. call the `relay` function so that the restricted function is called by the `AccessManager`

contract itself


However, in the case of the `AccessManager` 's <u>`[onlyAuthorized](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L102)`</u> functions the execution

through `relay` always fails. This is because the `onlyAuthorized` modifier <u>[only checks the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L745)</u>

<u>[permissions of](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L745)</u> <u>`[msg.sender](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b5a3e693e7eeca8d5f608460fd8beeee8e332b03/contracts/access/manager/AccessManager.sol#L745)`</u> and nowhere considers the case where `address(this)` is the

caller.


This issue is not severe within the context of `AccessManager` alone since there is always the

option of a direct call to the `onlyAuthorized` function. However, this bug could result in

failing governance proposals execution, because the `GovernorTimelockAccess` extension

contract relies on `relay` for calling any function related to `AccessManager` .


Consider updating the `onlyAuthorized` modifier so that it also considers execution calls

through the `relay` function.


**_Update:_** _Resolved in_ _<u>[pull request #4612.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4612)</u>_


Contracts 5.0 Release − Client-Reported − 72


## **Recommendations**

### **[R01] Features and Design Suggestions**

There are some features that are either missing or are partially implemented. We encourage the

team to go over this list and evaluate, in each individual case, whether it is worth adding to the

library:


   - The <u>`[Nonces](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/utils/Nonces.sol)`</u> <u>contract</u> misses a function that increments the nonce and returns the

incremented one. Alternatively, the current function can be modified to return both the

old and new nonce values. This should improve extensibility and give the implementers

more choices on how they want to check nonce value correctness.

   - The <u>`[MinimalForwarder](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/metatx/MinimalForwarder.sol)`</u> <u>contract</u> is not using `Nonces` . Consider using the already

existing `Nonces` code in `MinimalForwarder` .

   - Across the library, non-explicit imports are used. To improve readability and make the

code easier to follow, especially when more definitions are inside the same file, consider

using explicit imports instead.

   - Across the library, mappings do not have named parameters for the keys and values.

Consider adopting the newly available syntax to make the code easier to understand and

follow.

   - As it is right now, <u>`[ERC1155Supply](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/extensions/ERC1155Supply.sol)`</u> limits the `totalSupply` of all `tokenId` s

cumulated all together with the <u>`[_totalSupplyAll](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC1155/extensions/ERC1155Supply.sol#L61)`</u> <u>variable. Consider whether is worth</u>

exploring the possibility of having an `ERC1155SupplyAll` that reflects the current

behavior and an `ERC1155Supply` that only caps individual `tokenId` amounts without

cumulating them.

### **[R02] Overridable Functions Risk Classification**


The codebase is a general-purpose library and for this, it has to be extensible and flexible

enough to allow users to perform custom implementation on a variety of different use cases.

For this reason, the vast majority of functions defined in all contracts are `virtual` so that

those can be overridden.


However, in some special cases, overriding a function might be dangerous and undermine the

inner mechanics of some established flows. The connection between overridable functions and


Contracts 5.0 Release − Recommendations − 73


other parts of the codebase that make use of them assuming a specific behavior is not always

easy to spot, and in general it doesn't mean that a user is not allowed to do a custom override,

but that instead, it might unexpectedly introduce errors.


As such, we encourage the team to establish security levels for all overridable functions and to

clearly classify those in the docstrings so that users are aware of the confidence that should be

used when creating custom overridden implementations. We identified three main categories

where all overridable functions can be grouped:


   - Unrestricted overrideability: functions that can be overridden and are either unused by

other parts of the codebase or if used, it's unlikely for a custom implementation, to break

other mechanics that make use of them.

   - Restricted overrideability: functions that can be overridden but special care should be

taken if used in combination with other contracts or if some anti-patterns are already

known so that users must avoid them.

   - Discouraged overrideability: functions that can be overridden but that are likely to

produce some issues when being re-implemented. Special care should be used by users

when dealing with this category.


Some examples of restricted and discouraged levels functions are:


   - The <u>`[nonces](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/utils/Nonces.sol#L18)`</u> getter of the `Nonces` library. We didn't identify any reason why someone

would like to re-implement such a function. However, we noticed that if the getter returns

something different from the actual nonce, the majority of contracts that make use of it

will likely break or need a refactor to adopt such change.

   - The <u>`[cap](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20Capped.sol#L38)`</u> function of the `ERC20Capped`, if re-implemented, will likely impact the

`_update` function that makes use of it.

   - The <u>`[_transferTokenUnits](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/governance/utils/Votes.sol#L181)`</u> function of `Votes` internally calls

`_moveDelegateVotes` with `amount` assuming a 1:1 relation between token units and

voting units, while the `_delegate` one calls the same but with <u>`[_getVotingUnits](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/extensions/ERC20Votes.sol#L58)`</u> .

The `_getVotingUnits` is overridable and by default it just returns the

`balanceOf(account)`, but if this were to be overridden to implement a quadratic or

any constant product formula, the `_transferVotingUnits` will still mistakenly

transfer `amount` because of the assumption. The `_getVotingUnits` should be of

unrestricted category, but the actual codebase makes it possible to introduce severe

issues if it was to be re-implemented.

   - Sensitive <u>`[balanceOf](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/ERC20.sol#L106)`</u> and <u>`[totalSupply](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/token/ERC20/ERC20.sol#L99)`</u> functions of `ERC20` can create issues on

other contracts that make use of them and assume their default behavior.


Contracts 5.0 Release − Recommendations − 74


When thinking about how to display categories to users, consider adopting docstrings of the

following format

```
/// @Custom:overrideability { unrestricted | restricted | discouraged }

### **[R03] Testing and Fuzzing Opportunities - Phase 1**

```

There are some functions in the library that might benefit from fuzzing. The following is a non
exhaustive list:


  - The newly added <u>`[_isValidDescriptionForProposer](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/governance/Governor.sol#L704)`</u> function.

   - The entire <u>`[Checkpoints](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/utils/structs/Checkpoints.sol)`</u> and <u>`[DoubleEndedQueue](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/utils/structs/DoubleEndedQueue.sol)`</u> libraries.

   - The majority of the functions in the <u>`[StorageSlot](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/utils/StorageSlot.sol)`</u> and <u>`[Strings](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99a4cfca17279b77ae945b30cf9f7e87b21bf6f8/contracts/utils/Strings.sol)`</u> libraries.


In other parts of the codebase, it would be beneficial to add specific test cases. Some

examples are:


   - Include a test to prove the correctness of <u>[this](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f8e3c375d19bd12f54222109dd0801c0e0b60dd2/contracts/governance/TimelockController.sol#L298)</u> statement in the `TimelockController`

contract.

   - Similarly, consider conducting a test to prove that the chosen design in

`ERC4626._deposit` is aligned with the <u>[statement](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f8e3c375d19bd12f54222109dd0801c0e0b60dd2/contracts/token/ERC20/extensions/ERC4626.sol#L218-L219)</u> in the docstrings.

### **[R04] Inextensible Choice of Admin Address**


The latest design of the `TransparentUpgradeableProxy` <u>[uses an immutable](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/transparent/TransparentUpgradeableProxy.sol#L84)</u> <u>`[_admin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/transparent/TransparentUpgradeableProxy.sol#L84)`</u>

variable to avoid storage loads during the execution of the `_fallback` function, effectively

skipping the usage of the `ERC1967` admin slot. This implies that there's no way to change the

`_admin` that is allowed to upgrade the proxy.


Consider wrapping the `_admin` variable into a virtual function that can be overridden to use

the `ERC1967` admin slot instead so that user can choose their own tradeoffs when it comes to

using a transparent proxy.

### **[R05] Compatibility with EVM Chains Other Than** **Ethereum**


While performing the audit we noticed that some of the patterns followed by the code base

might not be compatible with chains in which Solidity code can be deployed.


Contracts 5.0 Release − Recommendations − 75


Based on the official <u>[documentation](https://era.zksync.io/docs/reference/architecture/differences-with-ethereum.html)</u> of zkSync Era:




- `CREATE` and `CREATE2` on zkSync Era need to have the compiler to resolve the

bytecode beforehand. Unfortunately, <u>`[Create2.deploy](https://github.com/ernestognw/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/utils/Create2.sol#L45)`</u> takes it as input parameter and

will not work if it's going to be implemented as an external user input. Similarly the

<u>`[Clones](https://github.com/ernestognw/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/Clones.sol)`</u> <u>contract</u> might be incompatible due to the same.

- There might be issues with `mload` and `mstore` . On zkSync Era, memory growth is in

bytes, while on EVM is in words. The result of an `mstore(100,0)` will give an `msize`

of `160` on EVM, of `132` on zkEVM. So any contract that doesn't deal with the `32`

`bytes = 1 word` growth will likely behave differently on EVM vs zkEVM. An example

can be the <u>`[toETHSignedMessageHash](https://github.com/ernestognw/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/utils/cryptography/MessageHashUtils.sol#L29)`</u> <u>of</u> <u>`[MessageHashUtils](https://github.com/ernestognw/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/utils/cryptography/MessageHashUtils.sol#L29)`</u> or the <u>`[toString](https://github.com/ernestognw/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/utils/ShortStrings.sol#L63)`</u> <u>of</u>

<u>the</u> <u>`[ShortStrings](https://github.com/ernestognw/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/utils/ShortStrings.sol#L63)`</u> contract.




- `CALLDATACOPY` and `CALLDATALOAD` will panic at `2^32-33` offset values.

<u>`[_msgSender](https://github.com/ernestognw/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/metatx/ERC2771Context.sol#L24)`</u> <u>[from](https://github.com/ernestognw/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/metatx/ERC2771Context.sol#L24)</u> <u>`[ERC2771Context](https://github.com/ernestognw/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/metatx/ERC2771Context.sol#L24)`</u> might fail. The same is true for the <u>`[_delegate](https://github.com/ernestognw/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/proxy/Proxy.sol#L22)`</u>



function of `Proxy` .


Moreover, based on this <u>[other documentation page, another difference with zkSync Era is that](https://era.zksync.io/docs/reference/concepts/blocks.html#block-number-and-timestamp-considerations)</u>

`block.number` and `block.timestamp` within zkSync VM execution refers to the latest L1

batch that has been sent to Ethereum mainnet and not to the current L2 block number and

timestamp. L1 batches might take some time to be finalized on L1 so the main effect is that

`block.number` and timestamp would somehow be stuck to the same value until the next

batch is finalized, definitely making time less continuous. Other rollups may have similar

[behaviors (Arbitrum). In terms of how this might affect the library let's imagine that an L1 batch](https://developer.arbitrum.io/time#ethereum-block-numbers-within-arbitrum)

has been pushed and another one will be added in a few minutes. In between the two batches:




- `Votes` will potentially break its mechanism. The <u>`[getPastVotes](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8fff875589443c607ac4ef2d201a6d8bec5a43c8/contracts/governance/utils/Votes.sol#L88)`</u> function takes

`timepoint` as reference. `timepoint` can be anything in the past but in this context it

can't be something which is in the past and also after the latest L1 batch `timepoint`,

otherwise the function will revert as if it was an attempt to read in the future.




- `TimelockController` operations might not move because the recorded timestamp

refers to the previous L1 batch even if in the L2 VM context the timestamp is correct

enough to move the proposals to another state.




- `VestingWallet` changes in vested amount are reflected on an L1-batches-basis



instead of the L2 VM time base.


Notice that this is not a comprehensive list and more issues might emerge from such subtle

differences.


Contracts 5.0 Release − Recommendations − 76


Based on the official <u>[documentation](https://community.optimism.io/docs/developers/build/differences/#)</u> of Optimism:







`tx.origin` might be aliased (and so `msg.sender` ) if it's an L1 -> L2 message. This



might affect `Context`, `ERC2771Context` and `TransparentUpgradeableProxy` .

This same issue applies to Arbitrum, and it's defined as <u>[address aliasing. The same](https://developer.arbitrum.io/arbitrum-ethereum-differences#l1-to-l2-messages)</u>

happens on zkSync Era.


Based on the official <u>[documentation](https://zkevm.polygon.technology/docs/protocol/evm-diff/)</u> Polygon zkEVM:







`block.number` returns the number of processable transactions, not an actual block



number as in L2s. Any contract making use of it will have a wrong assumption of what

the returned value is.


Notice that this is not a complete list of all the possible chains with their differences and is a

mere list of examples that we were able to lift up by a rapid analysis. There might be other

chains with completely different behaviours that we are not aware of.


It is important for the contracts team to establish a framework in which the library code can be

tested on different VMs with their differences. Unfortunately, many alternative chains have

different results if the information is queried through RPC calls or within VM execution directly

(i.e., `block.number` or `chain.id` ). For this, the suggestion is to test the contracts directly

within VM executions using local setup nodes for each of the chains. There are no known tools

that facilitate such operation, so we suggest further research on the topic.

### **[R06] Tokens Might Get Stuck in the Contract**


The <u>`[transferFrom](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/ERC721.sol#L145)`</u> and the <u>`[_transfer](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/ERC721.sol#L350)`</u> <u>functions of the</u> `ERC721` contract allows the

recipient to be `address(this)` since they don't perform the <u>`[onERC721Received](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/ERC721.sol#L450)`</u> <u>hook</u>

<u>[check. While the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/ERC721.sol#L450)</u> `ERC721Wrapper` provides a <u>`[_recover](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/token/ERC721/extensions/ERC721Wrapper.sol#L87)`</u> <u>method</u> for such scenario, the

`ERC721` would end up with tokens effectively stuck in the contract.


Consider whether is worth adding an internal `_recover` function or prohibiting

`address(this)` as a recipient.


In general, the issue has been officially raised in Phase 1 too but we decided to add

recommendations instead because we think it's a general issue that should be solved by

taking a common decision and we defer to the team on how to proceed from here.


Contracts 5.0 Release − Recommendations − 77


### **[R07] Testing and Fuzzing Opportunities - Phase** **4**

There are some functions in the library that might benefit from fuzzing. The following is a non
exhaustive list:


   - The entire <u>`[SignedMath](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b027c3541c03348767b62d45721eaa7d50f02b65/contracts/utils/math/SignedMath.sol)`</u> <u>library.</u>

### **[R08] Overlapping Operation of Multiple Delay** **Mechanisms in AccessManager**


There are currently three different delay mechanisms in the `AccessManager` contract:


   - Execution delays: access to restricted functions is allowed to members of an authorized

group with respect to each member's `executionDelay` . This means that in order to

execute a restricted function for which they are authorized, a member should first

schedule the operation and then trigger its execution after `executionDelay` period of

time has passed. This delay is set per member.

   - Group granting delays: the delay between the time point when an account is granted

membership and the time point that the member becomes active, in essence allowed to

perform or schedule a restricted operation. This delay is set per group.

   - Class admin delays: these delays are also considered for some sensitive operations at

the `AccessManager` contract that fall under no delay restriction other than the caller's

own `executionDelay` .


The operation field of these three mechanisms could overlap in some cases so that it is hard to

extract strong constraints about the delay restrictions applied to a set of sensitive operations,

e.g. calling a restricted function on the target contract, granting membership to authorized

groups, or configuring the `AccessManager` contract.


For example, an authorized member can access some restricted function `functionA` with

`executionDelayA`, but could possibly access `functionA` faster if they are also admins of

`functionA` 's groups and can grant membership to a new account with zero

`executionDelay` for this new member. The admin will be able to access `functionA` faster

if their `executionDelay` for granting membership and the `grantDelay` for this group are

overall lower than `executionDelayA` .


Contracts 5.0 Release − Recommendations − 78


The administrators of the `AccessManager` contract should take these edge cases into

consideration when configuring the delay values. However, it's admittedly not trivial to

configure all its parameters in a secure and effective manner.


The design could be made clearer and simpler if grant delays are omitted in favor of minimum

execution delays per group that apply to all groups' members. However, there are some cases

where zero execution delay is useful. For example, administrative entities that take decisions

by running a voting procedure, like DAOs, would be expected to perform a single step in order

to execute restricted functionality. Thus, this design simplification should be accompanied by a

solution for cases like a DAO administrator. For example, scheduled operations that have

passed the delay period could be open for anyone to execute or the `schedule` function could

accept an additional `address` parameter for the scheduler to provide a trusted account to

`relay` the scheduled operation on their behalf.


Consider reviewing the above design suggestions and try to simplify the delay mechanisms so

that it becomes more comprehensive, needing less administrative effort to manage effectively

and securely and allowing special entities (like DAOs) to interact efficiently.


Contracts 5.0 Release − Recommendations − 79


## **Conclusion**

Version 5 is a new milestone not only for the development team but also for OpenZeppelin as a

whole. The level of appreciation that previous versions of the library have shown is outstanding

and the number of protocols and projects that rely on it is always increasing. Because of this,

there has been an enormous effort from many team members to make this possible and deliver

impactful changes that we hope can allow for more robust and new projects to be built.


As the security services team we are happy to be part of it and we particularly value the

research, the study and the continuous back and forth with changes and new feature that the

development team have been through, but also the engagement in the endless discussions

and brainstorming sessions with us.


Waiting to see what the world will build with it, we wish all the best to this new release!


_From OpenZeppelin's Security Services team with_


Contracts 5.0 Release − Conclusion − 80


