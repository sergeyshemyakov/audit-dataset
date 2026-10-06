### ​
##### **Security Assessment**
#### Final Report


## **Kat token**
```
March 2025

Prepared for Polygon Labs

```

​ ​ ​ ​ ​ ​ ​


**Table of Contents**


**Project Summary.................................................................................................................................................3**

Project Scope..................................................................................................................................................3
Project Overview............................................................................................................................................. 3

Protocol Overview..................................................................................................................................... 3
Findings Summary.......................................................................................................................................... 4
Severity Matrix.................................................................................................................................................4
**Detailed Findings................................................................................................................................................ 5**

Low Severity Issues........................................................................................................................................ 7
L-01 Renounced roles in KatToken can be re-acquired.................................................................................. 7
L-02 MerkleMinter’s root and katToken can be changed after claims have happened................................... 9
Informational Issues...................................................................................................................................... 11
I-01. Off-by-one error in MAX_INFLATION check......................................................................................... 11
I-02. Deployment logic could be simplified....................................................................................................12
I-03. KatToken.renounceInflationBeneficiary() allows distributing minting capacity to address(0)................13
I-04. MerkleMinter.rootSetter is allowed to renounce before calling MerkleMinter.init.................................. 14
I-05. 18-digits constants are saved with 17 digits of precision...................................................................... 15
Gas Optimization...........................................................................................................................................16
G-01. Unchecked subtraction in KatToken.distributeMintCapacity................................................................16
G-02. KatToken.distributeInflation could return early.................................................................................... 17
G-03. KatToken._calcInflation could return early...........................................................................................18
G-04. MerkleMinter.claimKatToken spends unnecessary gas in double hashing......................................... 19
**Formal Verification............................................................................................................................................20**

Verification Notations.....................................................................................................................................20
General Assumptions and Simplifications.....................................................................................................20
Formal Verification Properties....................................................................................................................... 21
KatToken....................................................................................................................................................... 21
P-01. Integrity of important methods............................................................................................................. 21
P-02. Risk assessment..................................................................................................................................21
P-03. Allowed transitions of storage variables.............................................................................................. 22
**Appendix 1: Late-stage revision at 494205c...................................................................................................25**

L-03 Unbounded inflation allows admins to DoS minting..............................................................................25
I-06. Error-prone setLockExemption implementation....................................................................................26
I-07. Inconsistent behavior when renouncing roles with pending transfers...................................................26
I-08. isUnlocked() function fails to unlock at exact unlockTime.....................................................................27
**Disclaimer.......................................................................................................................................................... 28**
**About Certora.................................................................................................................................................... 28**


​ 2


​ ​ ​ ​ ​ ​ ​
### **Project Summary**


**Project Scope**


Project Name Repository (link) Commit Hash Platform


<u>[https://github.com/0xPolygon/](https://github.com/0xPolygon/kat-token/tree/main)</u>
Kat Token <u>[21644ff](https://github.com/0xPolygon/kat-token/tree/21644ffdb2f00d3b8ba5f2fc84e9e3d0888faeed)</u> EVM
<u>[kat-token/tree/main](https://github.com/0xPolygon/kat-token/tree/main)</u>


**Project Overview**


This document describes the specification and verification of **Kat Token** using the Certora Prover
and manual code review findings. The work was undertaken from **11.3.2025** to **18.3.2025** .


The following contract list is included in our scope:

```
kat-token/src/KatToken.sol
kat-token/src/MerkleMinter.sol
kat-token/src/Powutil.sol

```

The Certora Prover demonstrated that the implementation of the **Solidity** contracts above is
correct with respect to the formal rules written by the Certora team. In addition, the team
performed a manual audit of all the Solidity contracts **.** During the verification process and the
manual audit, the Certora team discovered bugs in the Solidity contracts code, as listed on the
following page.


All issues identified in the audit were resolved as of commit <u>[eea36ab.](https://github.com/0xPolygon/kat-token/tree/eea36ab61f4ba1022dd2d3b53f5c43eb925b238e)</u>


**Protocol Overview**


The protocol implements Kat Token, an ERC20 which is the native token of the Katana network
chain. An initial amount of tokens could be minted and distributed by the Merkle Minter, a smart
contract that mints tokens for valid leaves in a Merkle Tree. After 4 years, a limited amount of
token inflation starts, allowing the fee beneficiary to mint new Kat Tokens.


​ 3


​ ​ ​ ​ ​ ​ ​


**Findings Summary**


The table below summarizes the findings of the review, including type and severity details.


**Severity** **Discovered** **Confirmed** **Fixed**


Critical  -  -  

High  -  -  

Medium  -  -  

Low 3 3 3


Informational 8 7 6


Gas Optimization 4 4 1


**Total** **15** **14** **10**


**Severity Matrix**


High Medium High Critical



**Impact**



Medium Low Medium High


Low Low Low Medium


Low Medium High


**Likelihood**



​ 4


​ ​ ​ ​ ​ ​ ​
### **Detailed Findings**


**ID** **Title** **Severity** **Status**



<u>L-01</u>
Renounced roles in KatToken can
be re-acquired


<u>L-02</u>
MerkleMinter’s root and katToken
can be changed after claims have
happened


<u>I-01</u> Off-by-one error in
MAX_INFLATION check


<u>I-02</u> Deployment logic could be
simplified


<u>I-03</u> KatToken.renounceInflationBenefici
ary() allows distributing minting
capacity to address(0)


<u>I-04</u> MerkleMinter.rootSetter is allowed
to renounce before calling
MerkleMinter.init



Low Fixed


Low Fixed


Info Fixed


Info Fixed


Info Fixed


Info Fixed



<u>I-05</u> 18-digits constants are saved with Info Fixed
17 digits of precision



<u>G-01</u> Unchecked subtraction in
KatToken.distributeMintCapacity



Gas Acknowledged



​ 5


​ ​ ​ ​ ​ ​ ​



<u>G-02</u> KatToken.distributeInflation could
return early


<u>G-03</u> KatToken._calcInflation could
return early


<u>G-04</u> MerkleMinter.claimKatToken
spends unnecessary gas in double
hashing



Gas Fixed


Gas Acknowledged


Gas Acknowledged



​ 6


​ ​ ​ ​ ​ ​ ​


**Low Severity Issues**


**L-01 Renounced roles in KatToken can be re-acquired**


Severity: **Low** Impact: **Medium** Likelihood: **Low**



Files:
<u>[KatToken.sol](https://github.com/0xPolygon/kat-token/blob/main/src/KatToken.sol)</u>



Status: Fixed in <u>[11d9bb7](https://github.com/0xPolygon/kat-token/pull/3/commits/11d9bb72c53eaa38f1030f2a7d72f28ff3099a2f)</u> Violated Property: P-03



**Description:** The code in scope allows for a few privileged addresses responsible for the initial
operation and setup of the contracts. These roles can then be renounced to make the contracts
eventually become fully decentralized. This full decentralization can however be reverted
because renouncing a role can be undone through a pending role assignment:


JavaScript
```
  File: KatToken.sol
  82:   function acceptInflationAdmin() external {
  83:     require(msg.sender == pendingInflationAdmin, "Not new role owner.");
  84:     inflationAdmin = pendingInflationAdmin;
  85:     pendingInflationAdmin = address(0);
  86:     emit InflationAdminChanged(inflationAdmin, false);
  87:   }
  --  93:   function renounceInflationAdmin() external {
  94:     require(msg.sender == inflationAdmin, "Not role owner.");
  95:     inflationAdmin = address(0);
  96:     emit InflationAdminChanged(address(0), false);
  97:   }

```

**Recommendations:** Clear also pending addresses when a `katToken` role ( `inflationAdmin`,

`inflationBeneficiary` ) is renounced. This would be in analogy with OpenZeppelin’s

`Ownable2Step` behavior when `renounceOwnership()` is called.


​ 7


​ ​ ​ ​ ​ ​ ​


**Customer’s response:** Fixed in <u>[11d9bb7.](https://github.com/0xPolygon/kat-token/pull/3/commits/11d9bb72c53eaa38f1030f2a7d72f28ff3099a2f)</u>


**Fix Review:** Issue Fixed.



​ 8


​ ​ ​ ​ ​ ​ ​


**L-02 MerkleMinter’s root and katToken can be changed after claims have happened**


Severity: **Low** Impact: **Medium** Likelihood: **Low**



Files:
<u>[MerkleMinter.sol](https://github.com/0xPolygon/kat-token/blob/main/src/MerkleMinter.sol)</u>



Status: Fixed in <u>[c19f230](https://github.com/0xPolygon/kat-token/pull/3/commits/c19f2303f49fbe1d902728f19e37464e91285ea1)</u> Violated Property: P-02



**Description:** The `MerkleMinter` contract allows the `rootSetter` address to call its `init` function
multiple times, effectively allowing changing the airdrop information and its ERC-20 `katToken`
until `rootSetter` renounces its role.


It is however possible that `rootSetter` updates the Merkle tree `root` and/or the ERC-20

`katToken` **_after_** some users have successfully claimed their share of tokens.


**Exploit Scenario:** When this happens, the airdrop can end up in an inconsistent state because:


  - ​ Parts of the airdrop can happen and distribute different ERC-20s in case `katToken`

changed

  - ​ Depending on how the Merkle tree is computed off-chain, it is possible that equal airdrop

bits ( `receiver`, `amount` pairs) are assigned a different `index`, thus allowing a single

`receiver` to claim the same amount twice, while another `receiver` can’t ever claim their
share


In the case of a malicious `rootSetter`, this can also be abused to selectively deny users with
legitimate leaves from minting KatTokens even when there’s an appearance that everything was
configured properly. ​
In more detail, the `rootSetter` can initially set the expected root with an incorrect token as the

`katToken` . They will then call `claimKatToken()` at some users' behalf, setting their leaves as
claimed, then calling `init()` once again with the correct root and the correct `katToken` followed
by a call to `renounceRootSetter()`, providing the appearance that all users with a valid leaf
would be able to claim their Kat Tokens.


**Recommendations:** Forbid calling `init()` as soon as `claimKatToken()` becomes callable.


​ 9


​ ​ ​ ​ ​ ​ ​


**Customer’s response:** Fixed in <u>[c19f230.](https://github.com/0xPolygon/kat-token/pull/3/commits/c19f2303f49fbe1d902728f19e37464e91285ea1)</u>


**Fix Review:** Issue Fixed. Note that the added check is not completely inverted to the one in

`claimKatToken()` because it does not use `>=` .


JavaScript
```
  File: MerkleMinter.sol
  42:    require(((block.timestamp < unlockTime) && locked), "Minter not locked.");
  --  82:    require(((block.timestamp > unlockTime) || !locked), "Minter locked.");

```

​ 10


​ ​ ​ ​ ​ ​ ​


**Informational Issues**


**I-01. Off-by-one error in MAX_INFLATION check**


**Description:** The `katToken` ’s `changeInflation()` function accepts values up to `MAX_INFLATION` :


JavaScript
```
    File: KatToken.sol
    156:   function changeInflation(uint256 value) external {
    157:     require(msg.sender == inflationAdmin, "Not role owner.");
    158:     require(value < MAX_INFLATION, "Inflation too large.");

```

This check, which leaves `MAX_INFLATION` off the range of accepted values, may provide a bad
user experience: calling `changeInflation(MAX_INFLATION)` would fail, despite `MAX_INFLATION`
would more intuitively be seen as the maximum attainable and not the minimum unattainable
value.

**Recommendation:** Consider updating the check to be “ `require(value <= MAX_INFLATION,`
```
 …)”.

```

**Customer’s response:** Fixed in <u>[600a24f.](https://github.com/0xPolygon/kat-token/pull/3/commits/600a24f6f24f69efd94354c23dd480f64a3fdde0)</u>

**Fix Review:** Issue Fixed.


​ 11


​ ​ ​ ​ ​ ​ ​


**I-02. Deployment logic could be simplified**


**Description:** The deployment logic in `Deploy.s.sol` contains some steps to pre-compute
contract addresses to solve circular dependencies:


JavaScript
```
  File: Deploy.s.sol
  27:   function deploy(
  --  33:   ) public returns (KatToken katToken, MerkleMinter merkleMinter) {
  34:     address _merkleMinter = vm.computeCreate2Address(
  35:       salt,
  36:       keccak256(bytes.concat(type(MerkleMinter).creationCode,
  abi.encode(_unlockDelay, _unlocker, _rootSetter)))
  37:     );
  --  43:     katToken = new KatToken{salt: salt}("KatToken", "KAT", _inflation_admin,
  _inflation_ben, _merkleMinter);
  --  47:     merkleMinter = new MerkleMinter{salt: salt}(_unlockDelay, _unlocker,
  _rootSetter);
  48:
  49:     assert(address(merkleMinter) == _merkleMinter);
  50:   }

```

This complexity is however unnecessary because the dependency is one-way before

`MerkleMinter.init()` is called - `katToken` needs `MerkleMinter` ’s address, but `MerkleMinter`
doesn’t need `KatToken` ’s address at construction.

**Recommendation:** Consider simplifying the deployment by:

1. ​ Normally deploying `MerkleMinter` first.
2. ​ Deploying `katToken`, with a reference to `MerkleMinter` .
3. ​ (optionally) calling `MerkleMinter.init()` with `katToken` ’s address.

**Customer’s response:** Fixed in <u>[8631f84.](https://github.com/0xPolygon/kat-token/pull/3/commits/8631f8477f753ffe96f437c1a6767cc560e93bae)</u>

**Fix Review:** Issue Fixed.


​ 12


​ ​ ​ ​ ​ ​ ​


**I-03. KatToken.renounceInflationBeneficiary() allows distributing minting capacity to**
**address(0)**


**Description:** Whenever `KatToken.renounceInflationBeneficiary()` is called, it is possible that

`inflationFactor` is non-zero. When this happens, new inflation will be minted to the zero
address, and this is likely an undesirable situation.

**Recommendation:** Consider enforcing `inflationFactor` to be zero when

`inflationBeneficiary` is `address(0)` .

**Customer’s response:** Fixed in <u>[7838454.](https://github.com/0xPolygon/kat-token/pull/3/commits/7838454e9fde07c664b0cafbab707a1eda57cba7)</u>

**Fix Review:** Issue Fixed.


​ 13


​ ​ ​ ​ ​ ​ ​


**I-04. MerkleMinter.rootSetter is allowed to renounce before calling MerkleMinter.init**


**Description:** The function `MerkleMinter.renounceRootSetter()` allows the `rootSetter` to give
up its role after it has properly configured the contract via the `init()` function call. There is
however no check that the `init()` call actually happened beforehand.

**Recommendation:** Consider adding a `require(root != bytes32(0))` check in

`renounceRootSetter` .

**Customer’s response:** Fixed in <u>[b5bdc1b.](https://github.com/0xPolygon/kat-token/pull/3/commits/b5bdc1b94886a3cfaf8b130f0d7064e5487d438f)</u>

**Fix Review:** Issue Fixed.


​ 14


​ ​ ​ ​ ​ ​ ​


**I-05. 18-digits constants are saved with 17 digits of precision**


**Description:** The `inflationFactor` constants are saved with 17 digits of precision, effectively
using 0 as the least significant digit which could have been used to represent a meaningful digit. ​
Ultimately, this affects the precision of the output of the `exp2()` function:


JavaScript
```
  exp2(42644337408493690) = 1030000000000000003
  exp2(42644337408493685) = 1029999999999999999
  --  exp2(28569152196770890) = 1019999999999999997
  exp2(28569152196770894) = 1020000000000000000

```

**Recommendation:** Correct the constants to account for the full possible precision.


JavaScript
```
  File: KatToken.sol
  29:   uint256 public constant MAX_INFLATION = 0.042644337408493685e18; // log2(1.03).
  Currently 0.04264433740849369e18
  --  63:   inflationFactor = 0.028569152196770894e18; // log2(1.02). Currently
  0.02856915219677089e18

```

**Customer’s response:** Fixed in <u>[aa2932f.](https://github.com/0xPolygon/kat-token/commit/321a62443daba78d64e877d448350df9737aef2f)</u>

**Fix Review:** Issue Fixed.


​ 15


​ ​ ​ ​ ​ ​ ​


**Gas Optimization**


**G-01. Unchecked subtraction in KatToken.distributeMintCapacity**


**Description:** The `distributeMintCapacity` function implements a check at `L201` for `amount` to
not exceed the sender’s capacity. This makes the `L202` implicit underflow check unnecessary.


JavaScript
```
    File: KatToken.sol
    199:   function distributeMintCapacity(address to, uint256 amount) external {
    200:     require(to != address(0), "Sending to 0 address");
    201:     require(mintCapacity[msg.sender] >= amount, "Not enough mint capacity.");
    202:     mintCapacity[msg.sender] -= amount;
    203:     mintCapacity[to] += amount;
    204:     emit MintCapacityDistributed(msg.sender, to, amount);
    205:   }

```

**Recommendation:** Consider adding an `unchecked` block around `L202` .

**Customer’s response:** Acknowledged. Won’t be fixed because the change reduces readability
for a seldom called function.


​ 16


​ ​ ​ ​ ​ ​ ​


**G-02. KatToken.distributeInflation could return early**


**Description:** The `distributeInflation` function implements a check at `L188` for incrementing
or not `lastMintCapacityIncrease` :


JavaScript
```
  File: KatToken.sol
  182:   function distributeInflation() public {
  183:     uint256 inflation = _calcInflation();
  184:     distributedSupplyCap += inflation;
  185:     // give increase to INFLATION_BENEFICIARY
  186:     mintCapacity[inflationBeneficiary] += inflation;
  187:     // increase distributedSupplyCap
  188:     if (block.timestamp > lastMintCapacityIncrease) {
  189:       lastMintCapacityIncrease = block.timestamp;
  190:     }
  191:     emit InflationDistributed(inflationBeneficiary, inflation);
  192:   }

```

However, under the same condition of `block.timestamp > lastMintCapacityIncrease`, it is
guaranteed that inflation is zero.
**Recommendation:** Consider moving the `block.timestamp > lastMintCapacityIncrease`
check for an early return at the top of the function.

**Customer’s response:** Fixed in <u>[321a624.](https://github.com/0xPolygon/kat-token/commit/321a62443daba78d64e877d448350df9737aef2f)</u>

**Fix Review:** Issue Fixed. Note that the new check is inverted but does use `>=` .


JavaScript
```
  File: KatToken.sol
  188:    if (lastMintCapacityIncrease > block.timestamp) {
  189:       return;
  190:    }

```

​ 17


​ ​ ​ ​ ​ ​ ​


**G-03. KatToken._calcInflation could return early**


**Description:** The `_calcInflation` function implements a check at `L170` for early returning in a
case where inflation is known to be zero:


JavaScript
```
  File: KatToken.sol
  169:   function _calcInflation() internal view returns (uint256) {
  170:     if (lastMintCapacityIncrease > block.timestamp) {
  171:       return 0;
  172:     }
  173:     uint256 timeElapsed = block.timestamp - lastMintCapacityIncrease;
  174:     uint256 supplyFactor = PowUtil.exp2((inflationFactor * timeElapsed) / 365 days);
  // when timeElapsed is 1, we have ~310e6
  175:     uint256 newCap = (supplyFactor * distributedSupplyCap) / 1e18;
  176:     return newCap - distributedSupplyCap;
  177:   }
  178:

```

This check could be extended to also cover the case where `lastMintCapacityIncrease ==`

`block.timestamp`, which is another condition when inflation is trivially zero.

**Recommendation:** Consider changing the `L170` check as follows:


JavaScript
```
  if (block.timestamp > lastMintCapacityIncrease) {
   // calculate & return
  }
  return 0;

```

**Customer’s response:** Acknowledged. Won’t be fixed because the change reduces readability
only to save a bit of gas for a case that wouldn’t really ever happen (calling cap() in the same
block after distributeInflation).


​ 18


​ ​ ​ ​ ​ ​ ​


**G-04. MerkleMinter.claimKatToken spends unnecessary gas in double hashing**


**Description:** The Merkle tree leaves in `MerkleMinter` are hashed as follows:


JavaScript
```
  File: MerkleMinter.sol
  83:     bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(index, receiver,
  amount))));

```

This double hashing is unnecessary because the ( `index`, `receiver`, `amount` ) leaf key encodes to
96 bytes which is a safe length for second preimage attacks.

**Recommendation:** Consider using a single `keccak256` round like done by <u>[Uniswap’s](https://github.com/Uniswap/merkle-distributor/blob/25a79e8ec8c22076a735b1a675b961c8184e7931/contracts/MerkleDistributor.sol#L47)</u>
<u>[MerkleDistributor to reduce the gas footprint of the claiming function.](https://github.com/Uniswap/merkle-distributor/blob/25a79e8ec8c22076a735b1a675b961c8184e7931/contracts/MerkleDistributor.sol#L47)</u>

**Customer’s response:** Acknowledged. Won’t be fixed because of development time constraints.


​ 19


​ ​ ​ ​ ​ ​ ​
### **Formal Verification**

The formal verification has been successfully completed during the late-stage review, with all
proofs conducted on the latest version of the code at commit <u>[494205c. The following results](https://github.com/0xPolygon/kat-token/tree/494205cc0e5d302b4c6d96c16e63fa99912631d6)</u>
reflect the current state of the implementation and are aligned with the most recent codebase.
For reference, the findings from the manual audit are provided in Appendix 1, ensuring full
traceability between manual and formal review.


**Verification Notations**



Formally Verified


Formally Verified After Fix



The rule is verified for every state of the
contract(s), under the assumptions of the
scope/requirements in the rule.


The rule was violated due to an issue in the
code and was successfully verified after
fixing the issue



A counter-example exists that violates one
Violated
of the assertions of the rule.


The rule is no longer applicable to the fixed
No longer applicable
code.


**General Assumptions and Simplifications**


●​ Harnessing: We sometimes work with contracts inherited from the original contracts. In
these “harnessed” contracts we add additional methods, flags etc. for verification
purposes without modifying the original code such that any verification result of the
harness applies to the original contracts.
●​ The verified Solidity contracts are compiled with solcX (with via-ir).
●​ We’re using an approximate version of the `exp2()` function in order to speed up the
verification process. The approximation behaves as an uninterpreted function where the
following axioms hold:

a. ​ `forall uint256 x < 100: exp2(x *1e18) == 2^x *1e18`
b. ​ `x < y => exp2(x) <= exp2(y)`


​ 20


​ ​ ​ ​ ​ ​ ​


**Formal Verification Properties**


**KatToken**


<u>Module Properties</u>


**P-01.** **Integrity of important methods**


Status: Verified


Rule Name Status Description Link to rule report



<u>[Report after fix](https://prover.certora.com/output/1000000000/bce173cd763f4e0e87b16a2cc2475015/?anonymousKey=9af1be8bff26d108a9f290646339230922471a37)</u>



**<mark>integrityOfChangeRoleHolder</mark>**
**<mark>integrityOfAcceptRole</mark>**
**<mark>integrityOfRenounceInflationBeneficiary</mark>**
**<mark>integrityOfRenounceInflationAdmin</mark>**
**<mark>integrityOfDistributeMintCapacity</mark>**
**<mark>integrityOfRenounceLockExemptionAd</mark>**
**<mark>min</mark>**
**<mark>integrityOfUnlockAndRenounceUnlocker</mark>**


**P-02.** **Risk assessment**


Status: Verified after fix



Verified The methods update the

storage as expected and can

only be called by the

corresponding privileged

addresses.



Rule Name Status Description Link to rule report



<u>[Report after fix](https://prover.certora.com/output/1000000000/bce173cd763f4e0e87b16a2cc2475015/?anonymousKey=9af1be8bff26d108a9f290646339230922471a37)</u>


<u>[Report after fix](https://prover.certora.com/output/1000000000/bce173cd763f4e0e87b16a2cc2475015/?anonymousKey=9af1be8bff26d108a9f290646339230922471a37)</u>


​ 21



**<mark>onlyAllowedAddressesCanMo</mark>**
**<mark>veFunds</mark>**



Verified Balance of any address can only

change either via mint, or after

the token is unlocked, or when

msg.sender is exempt.



**<mark>onceActivatedItStaysActive</mark>** Verified Once active, the protocol will

not go to an inactive state.


​ ​ ​ ​ ​ ​ ​



<u>[Original report](https://prover.certora.com/output/6893/354742828e96480c9b0165d2dbfca4e0/?anonymousKey=d13b214b1e45292fc92bc503e3323678c265df62)</u> _<u>​</u>_


<u>[Original report](https://prover.certora.com/output/6893/354742828e96480c9b0165d2dbfca4e0/?anonymousKey=d13b214b1e45292fc92bc503e3323678c265df62)</u>


<u>[Original report](https://prover.certora.com/output/6893/354742828e96480c9b0165d2dbfca4e0/?anonymousKey=d13b214b1e45292fc92bc503e3323678c265df62)</u>


<u>[Original report](https://prover.certora.com/output/6893/354742828e96480c9b0165d2dbfca4e0/?anonymousKey=d13b214b1e45292fc92bc503e3323678c265df62)</u>



**<mark>rootCanAlwaysBeSet</mark>** No longer applicable
Reported issue: I-04


**<mark>cannotInitAfterUnlocked</mark>** No longer applicable
Reported issue: L-02



It should not be be possible to

permanently renounce the

rootSetter role without actually

setting the root first


init cannot be called after the

minter has already become

active



**<mark>canOnlyClaimWhenNotLocked</mark>** No longer applicable All calls to claimKatToken must

revert before unlockTime


**<mark>cannotClaimTheIndexTwice</mark>** No longer applicable indexIsClaimed(index) == true

then claimKatToken(..,index)

will revert.


**P-03.** **Allowed transitions of storage variables**


Status: Verified after fix



Rule Name Status Description Link to rule report



**<mark>lockedValueChange</mark>** Verified Locked can only change

from true -> false



<u>[Report after fix](https://prover.certora.com/output/1000000000/bce173cd763f4e0e87b16a2cc2475015/?anonymousKey=9af1be8bff26d108a9f290646339230922471a37)</u>


<u>[Report after fix](https://prover.certora.com/output/1000000000/bce173cd763f4e0e87b16a2cc2475015/?anonymousKey=9af1be8bff26d108a9f290646339230922471a37)</u>


<u>[Report after fix](https://prover.certora.com/output/1000000000/bce173cd763f4e0e87b16a2cc2475015/?anonymousKey=9af1be8bff26d108a9f290646339230922471a37)</u>


​ 22



**<mark>lastMintCapacityIncreaseNeverDe</mark>**
**<mark>creases</mark>**


**<mark>distributedSupplyCapNeverDecre</mark>**
**<mark>ases</mark>**



Verified lastMintCapacityIncrease

can never decrease


Verified distributedSupplyCap can

never decrease


​ ​ ​ ​ ​ ​ ​



**<mark>mintCapacityPlusMintedEqualsDi</mark>**
**<mark>stributedSupplyCap</mark>**



Verified distributedSupplyCap ==

total mint capacity +

mintedTokens



**<mark>mintCapacityOfZeroIsZero</mark>** Verified after fix
Reported issue: <u>I-03</u>


**<mark>changeInflation_revertConditions</mark>** Verified after fix ​
Reported issue: <u>I-01</u>


**<mark>inflationAdminValueChange</mark>** Verified after fix ​
Reported issue: <u>L-01</u>


**<mark>inflationBeneficiaryValueChange</mark>** Verified after fix
Reported issue: <u>L-01</u>


**<mark>noBeneficiaryThenNoInflation</mark>** Verified after fix ​
Reported issue: <u>I-03</u>



mintCapacity of address(0)

is always 0


changeIinflation doesn’t

revert unexpectedly.


inflationAdmin can never

change from 0 to non-zero


inflationBeneficiary can

never change from 0 to

non-zero


If inflationBeneficiary is

zero then inflationFactor is

zero



**<mark>zeroRoleThenZeroPendingRole</mark>**
**<mark>(covers</mark>**
**<mark>zeroAdminThenZeroPendingAdmi</mark>**
**<mark>n and</mark>**
**<mark>zeroBeneficiaryThenZeroPending</mark>**
**<mark>Beneficiary)</mark>**


**<mark>zeroAdminThenZeroPendingAdmi</mark>**
**<mark>n</mark>**


**<mark>zeroBeneficiaryThenZeroPending</mark>**
**<mark>Beneficiary</mark>**



Verified If roleHolder(role) is zero

then

pendingInRoleHolder(role)

is also zero. This implies the

following two properties.



<u>[Report after fix](https://prover.certora.com/output/1000000000/44f2cd36f6544cf9a390be3e7cb4a42f/?anonymousKey=f4a79cd646f8906a2a36c561ede8b7c1b64c82e6)</u>


<u>[Report](https://prover.certora.com/output/6893/2711811320bd430a987ca0d94f637b35/?anonymousKey=13789723b8084bdcbf94a7da9b8390cf6bec4df4)</u> _<u>​</u>_

<u>[Report after fix](https://prover.certora.com/output/1000000000/a4c2b0237985448e9fb21441dd626e29/?anonymousKey=ce078c5be32e8d017d17f8f312ef153297001e58)</u>


<u>[Report](https://prover.certora.com/output/6893/2711811320bd430a987ca0d94f637b35/?anonymousKey=13789723b8084bdcbf94a7da9b8390cf6bec4df4)</u> _<u>​</u>_

<u>[Report after fix](https://prover.certora.com/output/1000000000/b0d13caf05df43be93198556056601e1/?anonymousKey=64b06b6fa2a38d00d296cc42de6ffad37d946057)</u>


<u>[Report](https://prover.certora.com/output/6893/2711811320bd430a987ca0d94f637b35/?anonymousKey=13789723b8084bdcbf94a7da9b8390cf6bec4df4)</u> _<u>​</u>_

<u>[Report after fix](https://prover.certora.com/output/1000000000/a4c2b0237985448e9fb21441dd626e29/?anonymousKey=ce078c5be32e8d017d17f8f312ef153297001e58)</u>


<u>[Report](https://prover.certora.com/output/6893/2711811320bd430a987ca0d94f637b35/?anonymousKey=13789723b8084bdcbf94a7da9b8390cf6bec4df4)</u> _<u>​</u>_

<u>[Report after fix](https://prover.certora.com/output/1000000000/a4c2b0237985448e9fb21441dd626e29/?anonymousKey=ce078c5be32e8d017d17f8f312ef153297001e58)</u>


<u>[Report](https://prover.certora.com/output/6893/ff027fb471af4cf1bbb673f3384d1a43/?anonymousKey=20d3a37b0261ddf9e2c185b1d89a2cb01c9871ba)</u> _<u>​</u>_

<u>[Report after fix](https://prover.certora.com/output/1000000000/bce173cd763f4e0e87b16a2cc2475015/?anonymousKey=9af1be8bff26d108a9f290646339230922471a37)</u>


<u>[Report after fix](https://prover.certora.com/output/1000000000/bce173cd763f4e0e87b16a2cc2475015/?anonymousKey=9af1be8bff26d108a9f290646339230922471a37)</u>


<u>[Original report](https://prover.certora.com/output/6893/935de9ac69a2432588c714ed03d9f886/?anonymousKey=1a34df932b7825056be96648e9c80e9869b0d480)</u>


<u>[Original report](https://prover.certora.com/output/6893/935de9ac69a2432588c714ed03d9f886/?anonymousKey=1a34df932b7825056be96648e9c80e9869b0d480)</u>


​ 23



No longer applicable ​
Reported issue: <u>L-01</u>


No longer applicable ​
Reported issue: <u>L-01</u>



If inflationAdmin is zero

then

pendingInflationAdmin is

zero.


If inflationBeneficiary is

zero then

pendingInflationBeneficiary

is zero.


​ ​ ​ ​ ​ ​ ​



<u>[Original report](https://prover.certora.com/output/6893/354742828e96480c9b0165d2dbfca4e0/?anonymousKey=d13b214b1e45292fc92bc503e3323678c265df62)</u>


<u>[Original report](https://prover.certora.com/output/6893/e6ed2e876a4e40cb8e010d8035c50fd0/?anonymousKey=58598fd14f4c352a3987dac43f1cf2f09f4f2ec3)</u>


<u>[Original report](https://prover.certora.com/output/6893/354742828e96480c9b0165d2dbfca4e0/?anonymousKey=d13b214b1e45292fc92bc503e3323678c265df62)</u>


​ 24



**<mark>katTokenCannotBeChangedOutsi</mark>**
**<mark>deInit</mark>**
**<mark>rootCannotBeChangedOutsideInit</mark>**



No longer applicable KatToken and root can only

be changed by the init

function.



**<mark>indexIsClaimedValueChange</mark>** No longer applicable indexIsClaimed(index) can

only change false -> true


**<mark>rootSetterValueChange</mark>** No longer applicable rootSetter can only change

from x -> address(0)


​ ​ ​ ​ ​ ​ ​
###### **Appendix 1: Late-stage revision at 494205c**


As part of the mitigation review for the main scope, Certora reviewed fixes to the contracts in
[scope, specifically the PR #5, which at the time of this late-stage review had its head at commit](https://github.com/0xPolygon/kat-token/pull/5)
<u>[494205c.](https://github.com/0xPolygon/kat-token/tree/494205cc0e5d302b4c6d96c16e63fa99912631d6)</u>
At this stage, the key changes were the fixes to the findings reported, the removal of the

`MerkleMinter` contract, and a rework of the permissioned roles in `KatToken` .
After reviewing these changes, Certora identified and reported the following additional findings:


**L-03 Unbounded inflation allows admins to DoS minting**


Severity: **Low** Impact: **Medium** Likelihood: **Low**



Files:
<u>[KatToken.sol](https://github.com/0xPolygon/kat-token/blob/494205cc0e5d302b4c6d96c16e63fa99912631d6/src/KatToken.sol)</u>



Status: Fixed in <u>[9b348dd](https://github.com/0xPolygon/kat-token/commit/9b348dd7dd7099727257e06447c622a2f8334d7d)</u>



**Description:** The `KatToken` contract allows the `INFLATION_ADMIN` address to call its

`changeInflation` [function to adapt the inflation rate. While in the original scope, there was an](https://github.com/0xPolygon/kat-token/blob/41e3bcc72c8a8ecb67c55e19b2951e3caa3da92c/src/KatToken.sol#L29)
<u>[upper limit to the inflation rate that could be configured.](https://github.com/0xPolygon/kat-token/blob/41e3bcc72c8a8ecb67c55e19b2951e3caa3da92c/src/KatToken.sol#L29)</u>


Since this limit was removed, administrators can now set any arbitrarily high value.


**Exploit Scenario:** The address holding the `INFLATION_ADMIN` role can set an extremely high
value for inflation, then trigger a distribution that would bring `distributedSupplyCap` close to

`uint256.max` . Once the contract is at this stage, no more inflation can be distributed.


More generally, token holders could be reassured by the existence of a limit to how much their
tokens can be diluted over time.


**Recommendations:** Consider reintroducing an upper limit - if flexibility drove the change, a limit
that is higher than it used to be can be envisaged.


**Customer’s response:** Fixed in <u>[9b348dd.](https://github.com/0xPolygon/kat-token/commit/9b348dd7dd7099727257e06447c622a2f8334d7d)</u>

**Fix Review:** Issue fixed.


​ 25


​ ​ ​ ​ ​ ​ ​


**I-06. Error-prone setLockExemption implementation**


**Description:** The `KatToken.setLockExemption()` function allows the `LOCK_EXEMPTION_ADMIN` to
toggle an override to the contract locking mechanism for a given address. Because this function
does not take the desired status as input, but instead reverses the current stored setting, it is
unnecessarily error-prone.

**Recommendation:** Consider adding a boolean parameter that allows the caller to define the
desired exemption setting for the given address explicitly.

**Customer’s response:** Fixed in <u>[e54329b.](https://github.com/0xPolygon/kat-token/commit/e54329b0deb1d66815be8150e80e0351e4488651)</u>

**Fix Review:** Issue fixed.


**I-07. Inconsistent behavior when renouncing roles with pending transfers**


**Description:** There is an inconsistency in how different roles are renounced within the `KatToken`
contract. Specifically:


●​ The `renounceInflationAdmin()` and `renounceInflationBeneficiary()` functions **revert**
if there is a pending role transfer (i.e., `pendingRoleHolder[role] != address(0)` ). ​

●​ In contrast, the `unlockAndRenounceUnlocker()` and `renounceLockExemptionAdmin()`
functions **clear** the `pendingRoleHolder[role]` field and proceed with the renouncement.


**Recommendation:** Standardize the behavior across all role renouncement functions

**Customer’s response:** Acknowledged. The different roles have different expected usage
patterns, and the reported behaviour is an intentional decision.


​ 26


​ ​ ​ ​ ​ ​ ​


**I-08.** **`isUnlocked()`** **function fails to unlock at exact** **`unlockTime`**


**Description:** The `isUnlocked()` function currently uses a strict greater-than check against
```
unlockTime:

```

JavaScript
```
    function isUnlocked() public view returns (bool) {
       return (block.timestamp > unlockTime) || !locked;
  }

```

This means that at the exact moment when `block.timestamp == unlockTime`, the contract is
still considered locked, which contradicts the intuitive meaning implied by the function name

`isUnlocked()` . Users would reasonably expect the contract to be unlocked once the specified

`unlockTime` is reached.


**Recommendation:** Update the condition to be inclusive of `unlockTime`

**Customer’s response:** Acknowledged. The current implementation provides a long-term gas
optimization that is preferable.


​ 27


​ ​ ​ ​ ​ ​ ​

### **Disclaimer**


Even though we hope this information is helpful, we provide no warranty of any kind, explicit or
implied. The contents of this report should not be construed as a complete guarantee that the
contract is secure in all dimensions. In no event shall Certora or any of its employees be liable for
any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising
from, out of, or in connection with the results reported here.

### **About Certora**


Certora is a Web3 security company that provides industry-leading formal verification tools and
smart contract audits. Certora’s flagship security product, Certora Prover, is a unique SaaS
product that automatically locates even the most rare & hard-to-find bugs on your smart
contracts or mathematically proves their absence. The Certora Prover plugs into your standard
deployment pipeline. It is helpful for smart contract developers and security researchers during
auditing and bug bounties.

Certora also provides services such as auditing, formal verification projects, and incident
response.


​ 28


