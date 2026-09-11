# Open Zeppelin v2.0� Security Audit�

**Level K**

146 Magazine Street,

Apt. 2

Cambridge, MA 02139

www.levelk.io


**Prepared by**

Chris Whinfrey

Paul Cowgill

Shane Fontaine


audits@levelk.io



**Version**

1.1


**Date**

October 21st, 2018


### Introduction

[The Zeppelin team asked us to review and audit all of the smart contracts](https://openzeppelin.org/)

contained in their widely used OpenZeppelin library in order to prepare it

for the OpenZeppelin v2.0 release.


The audited code is located in the [OpenZeppelin/openzeppelin-solidity](https://github.com/OpenZeppelin/openzeppelin-solidity)

repository. The version used for this report is commit

**dac5bccf803696d9d98d269b8c27c7aac5fa1c5c** .


The Zeppelin team did a great job of being consistent with their style, even

though there are over 150 contributors to the repository. This consistency

of the contracts combined with the well-written code allowed us to focus

on the critical pieces of the codebase during the audit. We commend the

team for their ability to write modular code while keeping it both simple and

usable. We are very pleased with the team’s communication with us

throughout the entire process, as it allowed for a more continuous audit

flow and quick clarification whenever it was needed.


We found one critical issue in BreakInvariantBounty.sol that

was susceptible to frontrunning by a malicious party that may lead to a

loss of funds. After independently coming up with the issue, we worked

with the team and an existing PR to take the best course of action

given the situation. The Zeppelin team removed the contract until a

better solution has been found. Our goal with this audit was

twofold: remove any vulnerabilities that may be found in the existing

framework and help future developers easily deploy these contracts as

they are intended to be used. Our suggestions that follow range from

gas optimizations and comment clarifications to recommended fixes of

potentially exploitable code.


**_Update:_** _The Zeppelin team has followed most of our_

_recommendations and updated their contracts appropriately._


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    2


## Issues Overview Open Zeppelin v2.0

##### **Number of Issues per severity level**

#### Open 3 0 0 0 Closed 16 4 2 1

##### **Issues by severity level**

#### **Directory Issue Title Status Severity**



drafts Avoid frontrunning by a malicious actor or
the contract owner


crowdsale Stop crowdsale manipulation via
reentrancy by adding the nonReentrant
modifier to the buyTokens() function


token Allow for safe changes to allowances
through the SafeERC20 interface


crowdsale Require closingTime to be strictly greater
than openingTime



Resolved


Resolved


Resolved


Resolved



crowdsale Return the true value of remainingTokens()
Resolved


crowdsale Prevent reentrancy in finalize()
Resolved


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    3


token Make _clearApproval() private
Resolved


access Role contracts emit events when a role has
Resolved
already been assigned or unassigned


crowdsale Use the internal keyword to force correct
Resolved
contract usage


crowdsale Mark validation functions as view to ensure
Resolved
they don’t change state


crowdsale Require initialRate is strictly greater than
Resolved
finalRate


crowdsale Consider overriding the rate() function to
Resolved
avoid any confusion


drafts Checks-Effects-Interactions
Resolved



drafts Consider being more explicit upon contract
creation to force correct usage of the
contract


drafts Consider being explicit about the number
of tokens that are meant to exist within the
contract



Resolved


Resolved



introspection _supportedInterfaces should be private
Resolved


math Additional test cases are needed for
Resolved
SafeMath to have full coverage


ownership Allow subclasses to renounce ownership
Open


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    4


ownership Secondary’s constructor should be internal
Resolved
because it is meant to be extended


payment Explicitly prevent adding payees late
Resolved



payment PullPayment‘s constructor should be
internal because it is meant to be
extended.



Resolved



token Cast 0 to an address type on lines 169 and
Open
182


token Expose an internal _transfer() function
Resolved


token Unused function _burn()
Resolved


token ERC20Capped should override _mint()
Resolved
instead of mint()


utils Consider changing the name of
Open
isContract()


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    5


## Issues Open Zeppelin v2.0

### **access/**

##### **1. Role contracts emit events when a role has already** **been assigned or unassigned**

[Roles.sol#L16-L27​](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/access/Roles.sol#L16-L27) ​- In Roles.sol, preventing add() from adding

already assigned roles and preventing remove() from removing


unassigned roles will keep the role contracts from emitting false


events such as CapperAdded when the role was already


assigned to the added address.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1421) _[#1421](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1421)_

### Notes:


**●** [CapperRole.sol#L15​ - Emit a](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/v2.0.0-rc.2/contracts/access/roles/CapperRole.sol#L15) ​ <mark>CapperAdded</mark> ​ event in the

<mark>CapperRole</mark> ​ constructor so that the contract’s set of

cappers can be determined from the contract’s events. This

recommendation applies to ​ <mark>MinterRole</mark> ​, ​ <mark>PauserRole</mark> ​,

and ​ <mark>SignerRole</mark> ​ as well.


_Update: resolved in_ ​ _[#1329](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1329)_


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    6


crowdsale/
### **Crowdsale.sol**

##### **1. Stop crowdsale manipulation via reentrancy by** **adding the nonReentrant modifier to the buyTokens()** **function**


The Crowdsale contract is at risk for reentrancy if a call to an


unknown address is made during the execution of the

<mark>buyTokens()</mark> ​ function. One way this could happen is if the

ERC20 token executes code at the receiver’s address when it is


transferred. An example of this class of token is described by the

[ERC677​ standard, an extension of ERC20. Reentrancy would](https://github.com/ethereum/EIPs/issues/677)

allow a malicious actor to bypass protections such as

<mark>IndividuallyCappedCrowdsale</mark> ​’s purchase cap. Consider

adding the ​ <mark>nonReentrant</mark> ​ modifier to the ​ <mark>buyTokens()</mark>

function to ensure this attack is not possible.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1438) _[#1438](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1438)_

##### **2. Use the internal keyword to force correct contract** **usage**


Because all of the crowdsale contracts are meant to be


extended, consider making every crowdsale contract’s

constructor ​ <mark>internal</mark> ​ <mark>.</mark>


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1439) _[#1439](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1439)_


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    7


##### **3. Mark validation functions as view to ensure they** **don’t change state**

Consider using the view keyword on both

<mark>_preValidatePurchase</mark> ​ and ​ <mark>_postValidatePurchase</mark> ​ <mark>.</mark>

All state changes should be made in

<mark>_updatePurchasingState</mark> ​, so enforcing view for the

validation functions ensures that state changes are implemented


where they should be.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1439) _[#1439](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1439)_

### Notes:


**●** _Comment:_ [​​Crowdsale.sol#L78​ - Crowdsale’s fallback](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/crowdsale/Crowdsale.sol#L78)

function can be used to purchase tokens but requires more

than 2300 gas. Any tokens purchased via ​ <mark>transfer()</mark>

from another contract will fail due to the imposed gas limit.


One case where this might be implemented is a contract that


pools funds to make a group purchase with a single


transaction. A comment advising users to use the

<mark>buyTokens()</mark> ​ function when purchasing from another

contract will help avoid unexpected transaction failures.


_Update: resolved in_ ​ _[#1446](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1446)_


            - _Typo:_ [​​Crowdsale.sol#L104​ - the mount -> the amount](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/crowdsale/Crowdsale.sol#L104)


_Update: resolved in_ ​ _[#1446](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1446)_


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    8


            - _Grammar:_ <mark>​</mark> The NatSpec comment for ​ <mark>buyTokens</mark> ​ says

<mark>@param beneficiary Address performing the</mark>

<mark>token purchase</mark> ​, but the beneficiary doesn’t necessarily

perform the buyTokens transaction. The ​ <mark>msg.sender</mark>

“performs” it. Consider rewording the comment to say that


the beneficiary is the address that will be receiving the


purchased ERC20 tokens.


_Update: resolved in_ ​ _[#1446](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1446)_


            - _Grammar:_ <mark>​</mark> ​ <mark>Not necessarily emits/sends</mark> ​ -> ​ <mark>Does</mark>

<mark>not necessarily emit/send</mark>


_Update: resolved in_ ​ _[#1446](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1446)_


crowdsale/validation/
### **TimedCrowdsale.sol**

##### **1. Require closingTime to be strictly greater than** **openingTime**


[TimedCrowdsale.sol#L33​ -](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/crowdsale/validation/TimedCrowdsale.sol#L33) ​ <mark>closingTime</mark> ​ should be strictly

greater than ​ <mark>openingTime</mark> ​. If opening time and closing time are

equal, ​ <mark>IncreasingPriceCrowdsale</mark> ​’s ​ <mark>[getCurrentRate()](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/crowdsale/price/IncreasingPriceCrowdsale.sol#L53-L55)</mark>

will always revert ​due to division by 0​.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1440) _[#1440](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1440)_


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    9


crowdsale/price/
### **IncreasingPriceCrowdsale.sol**

##### **1. Require initialRate is strictly greater than finalRate**


[IncreasingPriceCrowdsale.sol#L26​ - ​Make ​](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/crowdsale/price/IncreasingPriceCrowdsale.sol#L26) <mark>initialRate</mark> ​ strictly

greater than ​ <mark>finalRate</mark> ​ (that is, the price should increase by

some amount or ​ <mark>TimedCrowdsale</mark> ​ could be used instead).


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1441) _[#1441](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1441)_

##### **2. Consider overriding the rate() function to avoid any** **confusion**


[IncreasingPriceCrowdsale.sol#L50​ - ​The](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/crowdsale/price/IncreasingPriceCrowdsale.sol#L50) ​ <mark>rate()</mark> ​ function will

return the static rate that is passed into ​ <mark>Crowdsale</mark> ​ <mark>’</mark> s constructor

and is never used. This will differ from what is returned from

<mark>getCurrentRate()</mark> ​. Consider overriding ​ <mark>rate()</mark> ​ to revert in

<mark>IncreasingPriceCrowdsale</mark> ​.


_Update: resolved in_ ​ _[#1441](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1441)_

### Notes:


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    10


            - [IncreasingPriceCrowdsale.sol#L50​ - We believe](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/crowdsale/price/IncreasingPriceCrowdsale.sol#L50)

<mark>getCurrentRate()</mark> ​ should return ​0​ when called outside of

the crowdsale time period. The current implementation will


throw in some cases or return a nonzero rate in others.

Ideally the function should return early like this:​ ​ <mark>if</mark>

<mark>(!isOpen()) { return 0 }</mark>


_Update: resolved in_ ​ _[#1442](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1442)_


crowdsale/emission/
### **AllowanceCrowdsale.sol**

##### **1. Return the true value of remainingTokens()**


[AllowanceCrowdsale.sol#L40​ -](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/crowdsale/emission/AllowanceCrowdsale.sol#L40) ​ <mark>remainingTokens()</mark> ​ may return

more tokens than the ​ <mark>_tokenWallet</mark> ​ address contains. It should

return the minimum (using ​ <mark>Math.min</mark> ​) of the ​ <mark>_tokenWallet</mark> ​’s

<mark>balance</mark> ​ and the ​ <mark>allowance</mark> ​.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1449) _[#1449](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1449)_


crowdsale/distribution/
### **RefundableCrowdsale.sol**


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    11


### Notes:


            - _Note:_ <mark>​</mark> [​RefundableCrowdsale.sol#L44​ - For ​](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/crowdsale/distribution/RefundableCrowdsale.sol#L44) <mark>claimRefund</mark> ​ <mark>,</mark>

<mark>beneficiary</mark> ​ is a loaded word that implies the intended

beneficiary from the escrow’s perspective. This is because

<mark>Escrow</mark> ​ has a ​ <mark>beneficiaryWithdraw</mark> ​ function and it isn’t

the same ​ <mark>beneficiary</mark> ​ that is meant here. Consider

calling the parameter ​ <mark>refundee</mark> ​ in the ​ <mark>claimRefund</mark>

function of this contract.


crowdsale/distribution/
### **PostDeliveryCrowdsale.sol** Notes:


            - _Note:_ <mark>​</mark> [​PostDeliveryCrowdsale.sol#L4​ - Consider removing](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/crowdsale/distribution/PostDeliveryCrowdsale.sol#L4)

the ​ <mark>IERC20</mark> ​ import, as it is never used.


_Update: resolved in_ ​ _[#1437](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1437)_


crowdsale/distribution/
### **FinalizableCrowdsale.sol**


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    12


##### **1. Prevent reentrancy in finalize()**

[FinalizableCrowdsale.sol#L37​ - We recommend setting](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/crowdsale/distribution/FinalizableCrowdsale.sol#L37)

<mark>_finalized</mark> ​ to true before calling ​ <mark>_finalization()</mark> ​ <mark>.</mark> If

<mark>_finalization()</mark> ​ is overridden to make a call to an unknown

address, a malicious actor could reenter ​ <mark>finalize()</mark> ​ <mark>.</mark> One case

where this may happen is if the caller of ​ <mark>finalize()</mark> ​ is rewarded

with a small ETH payment.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1447) _[#1447](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1447)_

### Notes:


            - _Note:_ [​​FinalizableCrowdsale.sol#L15​ - We recommend](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/crowdsale/distribution/FinalizableCrowdsale.sol#L15)

removing the right-hand operand of ​ <mark>_finalized</mark> ​ in order to

save gas on deployment.


_Update: resolved in_ ​ _[#1403](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1403)_


drafts/
### **BreakInvariantBounty.sol**

##### **1. Avoid frontrunning by a malicious actor or the** **contract owner**


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    13


[BreakInvariantBounty.sol#L49​ - Claims can be frontrun by both a](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/drafts/BreakInvariantBounty.sol#L49)

malicious third-party and the contract owner. A malicious


third-party can frontrun the claim by repeating the researcher’s


transactions that deploy the target, break the invariant, and make


the claim with higher gas prices. The contract owner can frontrun

a claim with a call to ​ <mark>destroy()</mark> ​, revoking the bounty before the

researcher can be rewarded while the researcher already revealed


the broken invariant.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1424) _[#1424](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1424)_ ​ _. This contract will be removed while_

_new approaches are considered._

##### **2. Checks-Effects-Interactions**


[BreakInvariantBounty.sol#L55​: ​](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/drafts/BreakInvariantBounty.sol#L55) <mark>_claimed</mark> ​ should be moved

above ​ <mark>_asyncTransfer(researcher,</mark>

<mark>address(this).balance);</mark> ​ in order to comply with the

“check-effects-interaction” rule.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1424) _[#1424](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1424)_ ​ _. This contract will be removed while_

_new approaches are considered._


drafts/
### **SignatureBouncer.sol** Notes:


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    14


            - _Comment:_ [​​SignatureBouncer.sol​ - Add a comment warning](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/drafts/SignatureBouncer.sol)

that users are responsible for preventing replay attacks when


inheriting from this contract.


_Update: resolved in_ ​ _[#1434](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1434)_


drafts/
### **TokenVesting.sol**

##### **1. Consider being more explicit upon contract** **creation to force correct usage of the contract**


[TokenVesting.sol#L45​ - Consider adding](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/drafts/TokenVesting.sol#L45)

<mark>require(start.add(duration) > now);</mark> ​ and

<mark>require(duration > 0);</mark> ​ to the constructor. As it stands, if

either were to return false, the contract would allow the beneficiary


to claim all tokens immediately, which is likely not desired (this can


be achieved with a simple transaction). Adding this check adds an


additional sanity check to confirm that the contract executes as


expected.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1431) _[#1431](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1431)_

##### **2. Consider being explicit about the number of tokens** **that are meant to exist within the contract**


[TokenVesting.sol#L162​ -](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/v2.0.0-rc.2/contracts/drafts/TokenVesting.sol#L162) ​ <mark>vestedAmount()</mark> ​ returns a different

amount if tokens are added to the contract. The beneficiary could


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    15


withdraw their currently vested tokens and send them back to the


contract in order to increase the amount returned by

<mark>vestedAmount()</mark> ​. Changing the function to

<mark>vestedPercentage()</mark> ​ and using that to calculate

<mark>releasableAmount()</mark> ​ will prevent unexpected manipulation of

the amount returned by ​ <mark>vestedAmount()</mark> ​ <mark>.</mark>


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1427) _[#1427](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1427)_

### Notes:


            - _Note:_ [​TokenVesting.sol#L20-L21​ - Since the contract can](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/drafts/TokenVesting.sol#L20-L21)

accept and pay out multiple types of tokens, we recommend

adding a variable ​ <mark>tokenAddress</mark> ​ to both the ​ <mark>Released()</mark>

and ​ <mark>Revoked()</mark> ​ events.


_Update: resolved in_ ​ _[#1431](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1431)_


            - _Note:_ <mark>​</mark> [TokenVesting.sol#L163​: We recommend adding an](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/drafts/TokenVesting.sol#L163)

<mark>address</mark> ​ typecast to ​ <mark>this</mark> ​.

### **examples/** Notes:


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    16


            - _Note:_ [​Both ​SampleCrowdsaleToken​ and ​SimpleToken](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/examples/SampleCrowdsale.sol#L14)

declare state variables for ​ <mark>name</mark> ​ <mark>,</mark> ​ <mark>symbol</mark> ​, and ​ <mark>decimals</mark> ​ <mark>.</mark>

We recommend inheriting from ​ <mark>ERC20Detailed</mark> ​ instead to

demonstrate its usage.


_Update: resolved in_ ​ _[#1448](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1448)_


            - _Comment:_ [​SampleCrowdsale.sol#L28​ -](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/examples/SampleCrowdsale.sol#L28) ​ <mark>MintedCrowdsale</mark>

is not listed as an extension in the comment.


_Update: resolved in_ ​ _[#1448](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1448)_

### **introspection/**

##### **1. _supportedInterfaces should be private**


[ERC165.sol#L22​ - ​](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/introspection/ERC165.sol#L22) <mark>_supportedInterfaces</mark> ​ can be ​ <mark>private</mark>

for increased encapsulation.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1379) _[#1379](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1379)_

### Notes:


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    17


            - _Typo:_ <mark>​</mark> [​ERC165.sol#L46​ - ​](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/introspection/ERC165.sol#L46) <mark>_registerInterface</mark> ​ comment

says ​ <mark>@dev private method</mark> ​ but it’s ​ <mark>internal</mark> ​ <mark>.</mark> The

comment should be changed to say ​ <mark>internal</mark> ​.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1422) _[#1422](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1422)_


            - _Style:_ <mark>​</mark> [​ERC165Checker.sol#L44-L81​ -](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/introspection/ERC165Checker.sol#L44-L81)

<mark>supportsInterfaces()</mark> ​ as a name is very similar to

<mark>supportsInterface()</mark> ​ which may be error prone.

Consider renaming the function to something slightly more


verbose but easily distinguishable, like

<mark>supportsManyInterfaces</mark> ​.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1435) _[#1435](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1435)_


            - _Style:_ <mark>​</mark> [​ERC165Checker.sol#L94-L147​ - Adding underscores](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/introspection/ERC165Checker.sol#L94-L147)

to ​ <mark>ERC165Checker</mark> ​‘s private functions and changing

<mark>supportsERC165Interface()</mark> ​ to

<mark>_supportsInterface()</mark> ​ will help differentiate the

functions and their usages.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1435) _[#1435](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1435)_


lifecycle/
### **Pausable.sol** Notes:


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    18


            - _Note:_ [​​Pausable.sol#L11-L12​ - In](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/lifecycle/Pausable.sol#L11-L12) ​ <mark>Paused</mark> ​ and ​ <mark>Unpaused</mark>

events, consider including the pauser’s address in the event


since there can be multiple pausers.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1410) _[#1410](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1410)_


            - _Note:_ <mark>​</mark> ​Subclasses of Pausable currently have no access to

the ​ <mark>_paused</mark> ​ state variable. Adding internal functions for

<mark>_pause</mark> ​ and ​ <mark>_unpause</mark> ​ would allow for subclasses that

provide additional functionality. (e.g. a contract that allows


for unpausing by any address after a time period has


expired)


math/
### **Math.sol** Notes:


            - _Comment:_ ​ Consider adding NatSpec comments to each

function in ​ <mark>Math.sol</mark> ​ for consistency and clarity.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1423) _[#1423](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1423)_


math/


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    19


### **SafeMath.sol**

##### **1. Additional test cases are needed for SafeMath to** **have full coverage**

The following test cases are needed for SafeMath to have full


coverage:


            - <mark>div</mark> ​ with numbers that aren’t divisible evenly


            - <mark>div</mark> ​ with the first argument being 0


            - <mark>mul</mark> ​ with the second argument being 0


_Update: Tracked in issue_ ​ _[#1386](https://github.com/OpenZeppelin/openzeppelin-solidity/issues/1386)_


ownership/
### **Ownable.sol**

##### **1. Allow subclasses to renounce ownership**


Subclasses of ​ <mark>Ownable</mark> ​ are able to transfer ownership but are not

able to set ​ <mark>_owner</mark> ​ to a 0 address like ​ <mark>renounceOwnership</mark>

does. Consider exposing an internal function to allow ​ <mark>Ownable</mark>

subclasses to remove the owner.


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    20


### Notes:


            - _API:_ <mark>​</mark> The ERC20 and ERC721 standards require a

<mark>Transfer</mark> ​ event be emitted when tokens are created or

destroyed. Consider following this pattern with ​ <mark>Ownable</mark> ​ and

emitting an ​ <mark>OwnershipTransferred</mark> ​ event from the 0

address when ​ <mark>_owner</mark> ​ is set in the constructor and to the 0

address in ​ <mark>renounceOwnership</mark> ​ <mark>.</mark> This allows off-chain

applications to recreate the ownership state from the events.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1397) _[#1397](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1397)_


ownership/
### **Secondary.sol**

##### **1. Secondary’s constructor should be internal** **because it is meant to be extended**


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1433) _[#1433](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1433)_

### Notes:


            - _Comments:_ <mark>​</mark> Consider adding NatSpec comments to the

<mark>primary()</mark> ​ and ​ <mark>transferPrimary()</mark> ​ functions.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1425) _[#1425](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1425)_


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    21


            - _API:_ ​​ <mark>transferPrimary()</mark> ​ in ​ <mark>Secondary.sol</mark> ​ should

emit an event.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1425) _[#1425](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1425)_


payment/
### **RefundEscrow.sol** Notes:


            - _Note:_ <mark>​</mark> [​RefundEscrow.sol#L13​ - ​](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/payment/RefundEscrow.sol#L13) <mark>RefundEscrow</mark> ​ is already

<mark>Secondary</mark> ​ via ​ <mark>ConditionalEscrow</mark> ​ <mark>.</mark> Remove the

redundant inheritance of ​ <mark>Secondary</mark> ​.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1381) _[#1381](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1381)_


            - _Style:_ <mark>​</mark> We recommend replacing all ​ <mark>_state</mark> ​ checks such as

<mark>require(_state == State.Active);</mark> ​ with a modifier.

(e.g. ​ <mark>isState(State.Active)</mark> ​)


            - _Style:_ [​​RefundEscrow.sol#L16​ -](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/v2.0.0-rc.2/contracts/payment/RefundEscrow.sol#L16) ​ <mark>Closed</mark> ​ is the name of both

a state and an event. Consider renaming the event to

<mark>RefundClosed</mark> ​ to avoid confusion later on in the code.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1418) _[#1418](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1418)_


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    22


payment/
### **Escrow.sol** Notes:


            - _Word choice:_ ​ **​** [Escrow.sol#L9​ - Use more common English](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/payment/Escrow.sol#L9)

word choice: “destinated to” -> “sent to”


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1430) _[#1430](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1430)_


payment/
### **SplitPayment.sol**

##### **1. Explicitly prevent adding payees late**


[SplitPayment.sol#L101​ - Adding payees after payments have](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/payment/SplitPayment.sol#L101)

been released is not supported by the current code. Consider

making this function private or requiring that ​ <mark>_totalReleased</mark> ​ is

0. If the second option is chosen, adding payees after funds have


been received but not released will dilute existing payees which


may or may not be the desired behavior.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1417) _[#1417](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1417)_


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    23


### Notes:


            - _Naming:_ ​ We recommend being more clear about the desired

functionality of ​ <mark>SplitPayment.sol</mark> ​ <mark>.</mark> An unknowing user

may not realize that funds can be added throughout the


lifetime of the contract. Consider changing the name of the

contract to ​ <mark>SplitPayments.sol</mark> ​ <mark>.</mark>


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1418) _[#1417](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1417)_


            - _Note:_ <mark>​</mark> Adding ​ <mark>PayeeAdded</mark> ​ <mark>,</mark> ​ <mark>PaymentReceived</mark> ​ <mark>,</mark> and

<mark>PaymentReleased</mark> ​ events will log interactions with this

contract.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1418) _[#1417](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1417)_


payment/
### **PullPayment.sol**

##### **1. PullPayment‘s constructor should be internal** **because it is meant to be extended.**


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1433) _[#1433](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1433)_


token/ERC20/
### **ERC20.sol**


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    24


##### **1. Cast 0 to an address type on lines ​169​ and ​182** **2. Expose an internal _transfer() function**

Exposing an internal ​ <mark>_transfer()</mark> ​ function may be useful when

subclassing ERC20 for use cases such as security tokens where a


central operator may need to reverse a transfer or recover frozen


shares. Additionally, an internal function such as

<mark>_clearAllowance()</mark> ​ may be useful when a transaction

requires a certain amount of token be approved for transfer but, in


some cases, transfers none or a fraction of the approved amount.


_Update: An internal _transfer() function was added in_ ​ _[#1370](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1370)_


token/ERC20/
### **ERC20Burnable.sol**

##### **1. Unused function _burn()**


[ERC20Burnable.sol#L33​ - The ​](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/v2.0.0-rc.2/contracts/token/ERC20/ERC20Burnable.sol#L33) <mark>_burn()</mark> ​ function is not changed

by the override in ​ <mark>ERC20Burnable</mark> ​ and is no longer emitting an

event. Consider removing this function override.


_Update: resolved in_ ​ _[#1373](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1373)_


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    25


token/ERC20/
### **ERC20Capped.sol**

##### **1. ERC20Capped should override _mint() instead of** **mint()**


Now that the base ERC20 contract implements ​ <mark>_mint()</mark> ​ <mark>,</mark>

<mark>ERC20Capped</mark> ​ can inherit directly from the base ERC20 contract

and override ​ <mark>_mint()</mark> ​ instead of ​ <mark>mint()</mark> ​. This will ensure the

cap is not exceeded even when tokens are minted through

functions other than ​ <mark>mint()</mark> ​ <mark>.</mark>


_Update: resolved in_ ​ _[#1443](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1443)_


token/ERC20/
### **SafeERC20.sol**

##### **1. Allow for safe changes to allowances through the** **SafeERC20 interface**


<mark>SafeERC20</mark> ​’s ​ <mark>safeApprove</mark> ​ [is still susceptible to this ​attack​ and](https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/edit)

may be misleading. Reverting when the allowance is not being set


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    26


to or from 0 will help protect users from this vulnerability.

Additionally, adding ​ <mark>safeIncreaseAllowance</mark> ​ and

<mark>safeDecreaseAllowance</mark> ​ functions will allow users to still

safely adjust allowances when they are not setting the allowance


to or from 0.


_Update: resolved in_ ​ _[#1407](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1407)_

### Notes:


            - _Note:_ [​​SafeERC20.sol#L3​ - Importing ​](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/token/ERC20/SafeERC20.sol#L3) <mark>ERC20.sol</mark> ​ is

unnecessary.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1418) _[#1437](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1437)_


token/ERC721/
### **ERC721.sol**

##### **1. Make _clearApproval() private**


Subclasses that call ​ <mark>_clearApproval()</mark> ​ without emitting an

<mark>Approval</mark> ​ event will not be ERC721 compliant. Consider making

this function ​ <mark>private</mark> ​ or emitting an ​ <mark>Approval</mark> ​ event in

<mark>_clearApproval()</mark> ​.


_Update: resolved in_ ​ _[#1450](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1450)_


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    27


### Notes:


            - _Note:_ ​​ <mark>_checkAndCallSafeTransfer</mark> ​ does not call any

transfer-related functions as its name implies (although it is


used by one). Consider renaming the function to

<mark>_checkOnERC721Received</mark> ​.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1418) _[#1445](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1445)_


token/ERC721/
### **ERC721Burnable.sol** Notes:


            - _Note:_ [​​ERC721Burnable.sol#L7​ -](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/token/ERC721/ERC721Burnable.sol#L7) ​ <mark>burn()</mark> ​ is missing a

NatSpec comment.


token/ERC721/
### **ERC721Enumerable.sol**


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    28


### Notes:


            - _Note:_ ​ Consider adding a natspec comment for the contract

itself.


token/ERC721/
### **ERC721Metadata.sol** Notes:


            - _Note:_ ​​ <mark>tokenURI</mark> ​ should be ​ <mark>external</mark> ​ rather than ​ <mark>public</mark> ​ <mark>.</mark>


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1418) _[#1444](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1444)_


            - _Note:_ ​​ <mark>_name</mark> ​ and ​ <mark>_symbol</mark> ​ should be ​ <mark>private</mark> ​.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1418) _[#1426](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1426)_


token/ERC721/
### **ERC721Mintable.sol** Notes:


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    29


            - _Note:_ [​​ERC721Mintable.sol#L47​ -](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/token/ERC721/ERC721Mintable.sol#L47) ​ <mark>mintWithTokenURI()</mark> ​ is

missing a NatSpec comment.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1418) _[#1365](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1365)_

### **utils/**

##### **1. Consider changing the name of isContract()**


[Address.sol#L16​ - Because this function returns false when called](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/utils/Address.sol#L16)

from a contract’s constructor, consider calling this function

<mark>isInitializedContract()</mark> ​ for clarity.

### **General** Notes:


            - _Note:_ ​ There are a number of times throughout the code base

where a variable is assigned a default value. We recommend


removing the right-hand operand for each of these instances


that will reduce the gas cost.


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    30


              - [drafts/ERC1046/TokenMetadata.sol#L18​:](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/drafts/ERC1046/TokenMetadata.sol#L18)
<mark>_tokenURI</mark> ​ (8,170 gas)

              - [payment/SplitPayment.sol#L14-15​:](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/payment/SplitPayment.sol#L14-L15) ​ <mark>_totalShares</mark>
and ​ <mark>_totalReleased</mark> ​ (10,560 gas)

              - [token/ERC20/ERC20Mintable.sol#L14​:](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/dac5bccf803696d9d98d269b8c27c7aac5fa1c5c/contracts/token/ERC20/ERC20Mintable.sol#L14)
<mark>_mintingFinished</mark> ​ (6,911 gas)

_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1418) _[#1432](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1432)_ ​ _and_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1418) _[#1451](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1451)_


            - _Note:_ ​We recommend mirroring the testing directory with the

contracts directory. This is already followed for the most part,


but there are some notable exceptions after the


reorganization of the contracts directory. The following are


some adjustments that should be made to achieve this:


              - Move ​ <mark>TokenVesting.test.js</mark> ​ into
<mark>test/drafts/</mark>


              - Move ​ <mark>Math.test.js</mark> ​ into ​ <mark>test/math/</mark>

              - Tests are in the wrong folder for ​ <mark>ECDSA</mark> ​ <mark>.</mark> They’re still
in the ​ <mark>library/</mark> ​ folder.

_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1418) _[#1428](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1428)_


            - _Style:_ ​ It would be good to consistently use decimal or hex

numbers in assembly. Switching for different contracts using

assembly will confuse users. See ​ <mark>ECDSA.sol</mark> ​ vs.

<mark>ERC165Checker.sol</mark> ​.


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1418) _[#1429](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1429)_


            - _Note:_ ​The escrow contracts can be separated out into their

own folder to help them stand out as first-class contracts in


the library. Also, consider adding the following comments to


the escrow contracts to clarify their usage. See this Gist for


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    31


specific recomendations:


[https://gist.github.com/cwhinfrey/8d995081483906796d634d](https://gist.github.com/cwhinfrey/8d995081483906796d634d0373a16c15)

[0373a16c15​.](https://gist.github.com/cwhinfrey/8d995081483906796d634d0373a16c15)


_Update: resolved in_ [​​](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1418) _[#1430](https://github.com/OpenZeppelin/openzeppelin-solidity/pull/1430)_

### **No Issues**

##### **The following contracts were reviewed but no issues** **were found:**


            - crowdsale/validation/IndividuallyCappedCrowdsale.sol


            - crowdsale/validation/CappedCrowdsale.sol


            - crowdsale/emission/MintedCrowdsale.sol


            - cryptography/


            - drafts/ERC20Migrator.sol


            - drafts/ERC1046/TokenMetadata.sol


            - token/ERC20Detailed.sol


            - token/ERC20/ERC20Mintable.sol


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    32


            - token/ERC20/ERC20Pausable.sol


            - token/ERC20/IERC20.sol


            - token/ERC20/TokenTimelock.sol


            - token/ERC721/ERC721Full.sol


            - token/ERC721/ERC721Holder.sol


            - token/ERC721/ERC721Pausable.sol


            - token/ERC721/IERC721.sol


            - token/ERC721/IERC721Enumerable.sol


            - token/ERC721/IERC721Full.sol


            - token/ERC721/IERC721Metadata.sol


            - token/ERC721/IERC721Receiver.sol


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    33


### Conclusion

One issue of critical severity was found and relayed to the Zeppelin team

immediately. A solution was discussed and implemented as quickly as

possible. Only two high severity issues were found and explained, along

with recommendations on how to fix them. Most of the issues above are

there in order to mitigate the likelihood of an attack by a malicious actor

so that developers can focus on writing application-specific code and not

have to worry about the implementation of these contracts.


It has been a wonderful experience working with the Zeppelin team and

we look forward to seeing the many scenarios in which these contracts

are used!


_Note that the above audit reflects the Level K analysis of the OpenZeppelin contracts based_

_on currently known security patterns in Solidity and the EVM. We have not reviewed any_

_other Zeppelin or OpenZeppelin products. The above is not investment advice and we do_

_not endorse any token sale related to or created by this code. We do not guarantee that this_

_code is unexploitable and assume no liability for any funds lost in these contracts._


Open Zeppelin v2.0 Audit Level K, Inc. October 21st, 2018    34


