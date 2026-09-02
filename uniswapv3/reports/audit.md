# **Uniswap V3 Core**
## Security Assessment

**March 12, 2021**


Prepared For:
Hayden Adams  | _Uniswap_
<u>[hayden@uniswap.org](mailto:hayden@uniswap.org)</u>


Prepared By:
Alexander Remie  | _Trail of Bits_
<u>[alexander.remie@trailofbits.com](mailto:alexander.remie@trailofbits.com)</u>


Dominik Teiml  | _Trail of Bits_
<u>[dominik.teiml@trailofbits.com](mailto:dominik.teiml@trailofbits.com)</u>


Josselin Feist  | _Trail of Bits_
<u>[josselin.feist@trailofbits.com](mailto:josselin.feist@trailofbits.com)</u>


<u>Executive Summary</u>


<u>Project Dashboard</u>


<u>Code Maturity Evaluation</u>


<u>Engagement Goals</u>


<u>Coverage</u>


<u>Automated Testing and Verifcation i</u>

<u>Automated Testing with Echidna</u>

<u>End-to-End Properties</u>

<u>Arithmetic Properties</u>

<u>Verifcation with Manticorei</u>

<u>Manual Verifcationi</u>

<u>Automated Testing with Slither</u>


<u>Recommendations Summary</u>

<u>Short Term</u>

<u>Long Term</u>


<u>Findings Summary</u>

<u>1. Missing validation of _owner argument could indefnitely lock owner role i</u>

<u>2. Missing validation of _owner argument could lead to incorrect event emission</u>

<u>3. Anyone could steal pool tokens’ earned interest</u>

<u>4. Whitepaper contains incorrect equation</u>

<u>5. Incorrect comparison enables swapping and token draining at no cost</u>

<u>6. Unbound loop enables denial of service</u>

<u>7. Front-running pool’s initialization can lead to draining of liquidity provider’s initial</u>
<u>deposits</u>

<u>8. Swapping on zero liquidity allows for control of the pool’s price</u>

<u>9. Failed transfer may be overlooked due to lack of contract existence check</u>

<u>10. getNextSqrtPriceFromInput|Output can return a value outside of MIN_SQRT_RATIO,</u>
<u>MAX_SQRT_RATIO</u>


<u>A. Vulnerability Classifcations i</u>


<u>B. Code Maturity Classifcationsi</u>


<u>C. Non-security-related Findings</u>


<u>D. Whitepaper Recommendations</u>


<u>E. Token Integration Checklist</u>


© 2021 Trail of Bits Uniswap V3 Core Assessment | 1


<u>General Security Considerations</u>

<u>ERC Conformity</u>

<u>Contract Composition</u>

<u>Owner privileges</u>

<u>Token Scarcity</u>


<u>F. Detecting correct lock usage</u>

<u>Detecting correct lock usage</u>


<u>G. Front-running initialize tests</u>


<u>H. Manual analysis of overfow of amountIn + feeAmountl</u>

<u>Case 1: getAmount0Delta</u>

<u>Case 2: getAmount1Delta</u>


<u>I. Unit test for TOB-UNI-008</u>


© 2021 Trail of Bits Uniswap V3 Core Assessment | 2


### Executive Summary

During the week of January 4, 2021 and from February 15 to March 12, 2021, Uniswap
engaged Trail of Bits to review the security of Uniswap V3. Trail of Bits conducted this
assessment over 10 person-weeks, with 3 engineers working from `99223f3` from the
<u>[uniswap-v3-core repository.](https://github.com/Uniswap/uniswap-v3-core)</u>


In the first week (in January), we focused on gaining a high-level understanding of the
project. We started by reviewing the three main contracts against the most common
Solidity flaws and found the first two issues. Because the second week of our engagement
was several weeks later, we first reviewed the diff of the code since the first week. We then
studied the updated whitepaper and reviewed the factory contract and the mint/burn and
flash functionalities.


In the third week, Trail of Bits focused on the math libraries and the swap function. In the
fourth, we continued our manual review of the arithmetic libraries, the flash loan feature,
and pool initialization and focused on using Echidna to test properties. In the final week, we
added more Echidna properties to the core pool contracts and the libraries and improved
the existing properties, including by adding dynamic position creation. This enabled us to
discover issues such as <u>TOB-UNI-010 .</u>


We found 10 issues, including 2 of high severity. The most critical is TOB-UNI-005, which
allows anyone to drain a pool’s funds in both tokens due to an incorrect balance
comparison.


[Uniswap developed a significant set of properties and leveraged Echidna](https://github.com/crytic/echidna) to ensure the
correctness of the arithmetic, including rounding. The system includes one of the broader
sets of properties in the industry and demonstrates Uniswap’s commitment to ensuring the
security of its protocol.


Overall, the codebase follows best practices. The code is well structured, and Uniswap
avoided the most common Solidity pitfalls. However, due to the novelty of the project, it
suffers from significant complexity. The state of the whitepaper, a work in progress, made
the code review more difficult and increased the likelihood of issues. Additionally, drastic
gas optimizations such as a lack of SafeMath and the assembly usage increase the
probability of undiscovered bugs. While there is significant testing on the individual
components, the system will benefit from more thorough end-to-end tests on the overall
swapping, minting, and burning process.


Trail of Bits recommends that Uniswap complete the following:

  - Address all issues reported.

  - Expand the code documentation of the arithmetic functions with precise
assumptions about the ranges of all inputs and outputs.


© 2021 Trail of Bits Uniswap V3 Core Assessment | 3


 - Add unit tests and Echidna tests for libraries and core contracts, particularly the
`LiquidityMath`, `Tick`, and `Position` libraries and the pool and factory contracts.

 - Improve the unit test and Echidna test coverage for the end-to-end system
properties.

 - Consolidate and finish the whitepaper.

 - Conduct a security review of the periphery contracts, focusing on ensuring that their
interactions with the core match the core’s assumptions.


© 2021 Trail of Bits Uniswap V3 Core Assessment | 4


### Project Dashboard

|Application Summary|Col2|
|---|---|
|Name<br>|Uniswap V3 Core<br>|
|Version<br>|`99223f3` <br>|
|Type<br>|Solidity<br>|
|<br><br>Platforms<br>|Ethereum|


|Engagement Summary|Col2|
|---|---|
|Dates<br>|Week of January 4, 2021 and February 15 –<br>March 12, 2021<br>|
|Method<br>|Whitebox<br>|
|Consultants Engaged<br>|3<br>|
|<br><br>Level of Eﬀort<br>|10 person-weeks<br>|



**<u>Vulnerability Summary</u>**

|Total High-Severity Issues|2|◼◼|
|---|---|---|
|Total Medium-Severity Issues<br>|4<br>|◼◼◼◼ <br>|
|Total Low-Severity Issues<br>|1<br>|◼ <br>|
|Total Informational-Severity Issues<br>|3<br>|◼◼◼ <br>|
|<br><br>Total|10<br>|<br>|



**<u>Category Breakdown</u>**

|Data Validation|6|◼◼◼◼◼◼|
|---|---|---|
|Undeﬁned Behavior<br>|2<br>|◼◼ <br>|
|Timing<br>|1<br>|◼ <br>|
|Auditing and Logging<br>|1<br>|◼ <br>|
|Total|10<br>|<br>|



© 2021 Trail of Bits Uniswap V3 Core Assessment | 5


### Code Maturity Evaluation







|Category Name|Description|
|---|---|
|Access Controls <br>|**Satisfactory**. The number of public-facing functions is limited, and<br>the access controls are satisfactory. However, one issue related to<br>access controls ( TOB-UNI-001 ) was found, and the system would<br>beneﬁt from clear documentation on the owner’s privileges. <br>|
|Arithmetic <br>|**Moderate**. Overall, Uniswap has devoted signiﬁcant eﬀort to<br>making arithmetic operations (including custom ones) safe.<br>However, we identiﬁed several such issues ( TOB-UNI-005 and<br>TOB-UNI-010 ), and Uniswap identiﬁed additional issues during the<br>review. The arithmetic would also beneﬁt from more robust edge<br>cases and more thorough testing on the end-to-end operations. <br>|
|Assembly Use <br>|**Satisfactory**. Assembly is used extensively in two complex, critical<br>functions,`mulDiv` and`getTickAtSqrtRatio`. Writing these functions<br>in Solidity would decrease risks to the system. <br>|
|Centralization <br>|**Satisfactory.**The system is parameterized by the factory owner.<br>The owner can add new available (`fee`,`tickSpacing`) pairs in the<br>factory, depending on data validation. In the pool, the owner can<br>collect protocol fees and include them among a set of available<br>options. In general, the owner does not have unreasonable power.<br>However, the system would beneﬁt from more restrictions on the<br>system parameters’ values (see TOB-UNI-006 ). <br>|
|Upgradeability <br>|**Not applicable.** The system cannot be upgraded.<br>|
|Function<br>Composition <br>|Satisfactory. Overall, the code is well structured. Most logic is<br>located in one of the numerous libraries, and logic is extracted into<br>pure functions whenever possible. The splitting of the code into<br>logical libraries is a good practice and makes unit testing and fuzzing<br>the system much easier. However, the system would beneﬁt from<br>schema describing the diﬀerent components and their interactions<br>and behaviors.<br>|
|Front-Running<br>|**Satisfactory**. We did not ﬁnd many issues regarding front-running.<br>In the mint and burn functionality, we did not see a way for a<br>front-runner to proﬁt. A front-runner may generate proﬁts from the<br>swap functionality, as in V1 and V2, but the loss incurred by the user<br>is mitigated by the limit price. Finally, the initialization of pools can<br>be front-run ( TOB-UNI-007 ). Due to its nature, the system allows for<br>arbitrage opportunities; documentation regarding those<br>opportunities would be beneﬁcial to users.<br>|


© 2021 Trail of Bits Uniswap V3 Core Assessment | 6


|Monitoring|Satisfactory. In general, functions emit events where appropriate.<br>However, in at least one case, validation is not performed, which can<br>cause such an emission to be misleading (T OB-UNI-002) .|
|---|---|
|Speciﬁcation <br>|**Moderate.**At  the  beginning  of  the  assessment,  the  whitepaper<br>provided  by  Uniswap  was  not  up  to  date  with  the  codebase.  Many<br>sections  were  missing,  and  it  underwent  signiﬁcant  changes  during<br>the  review. Appendix  D  contains  our  initial  recommendations.  While<br>the  speciﬁcation  has  improved,  it  is  still  a  work  in  progress,  making<br>the  code  review  more  diﬃcult.<br>|
|<br><br>Testing  &<br>Veriﬁcation <br>|**Moderate.** The  project  has  extensive  but  incomplete  unit  tests  and<br>Echidna  tests.  Uniswap  devoted  signiﬁcant  eﬀort  to  testing  the<br>individual  components,  but  the  tests  lack  end-to-end  coverage.<br>More  thorough  end-to-end  coverage  would  have  discovered  issue<br>TOB-UNI-005,  which  allows  anyone  to  drain  a  pool. <br>|



© 2021 Trail of Bits Uniswap V3 Core Assessment | 7


### Engagement Goals

The engagement was scoped to provide a security assessment of the Uniswap V3 smart
contracts.


Specifically, we sought to answer the following questions:

  - Are all arithmetic libraries correct?

  - Are the arithmetic libraries used correctly, and do they correctly apply rounding?

  - Do the main interactions with the contracts lead to expected behavior?

  - Are there appropriate access controls for privileged actions?

  - Is it possible to manipulate the price and gain an unfair advantage when executing
swaps?

  - Are the pool operations susceptible to front-running issues?

  - Is it possible to perform swaps without paying the required amount?

  - Is it possible to drain funds from a pool?

### Coverage

**Arithmetic primitives (BitMath, FullMath, UnsafeMath, SafeCast, and**
**LowGasSafeMath).** These libraries form the mathematical building blocks of the system.
For most functions, we extensively reviewed the implementations to ensure that they
would return the correct results and revert otherwise. For example, `safeAdd` should return
the sum if the mathematical sum is at most 2^256 - 1 and should revert if it is not. Safe
casts should return a new type if the old value fits and should otherwise revert. For all
functions, we completed a comprehensive review of the Echidna tests, checking that their
properties sufficiently modeled the desired behavior. We also reviewed the unit tests for all
functions and again confirmed that the returned values were sufficiently constrained.


**TransferHelper.** TransferHelper contains just one function, safeTransfer. We manually
checked how the lack of a contract existence check would affect the operations of the pool
contract that used safeTransfer. We also checked that the possible transfer return values
were all correctly handled.


**LiquidityMath.** LiquidityMath contains just one function, addDelta. We checked for both
underflow and overflow cases and verified that the correct result was returned in the
success case.


**TickMath.** TickMath defines four constants and two functions used to convert prices to
ticks. Both functions have very complex implementations; one makes extensive use of
assembly for gas optimization. We manually checked that the conversion of the input
argument was correct. We also ran extensive tests, using the existing Echidna tests, to
discern whether we could trigger an out-of-bounds return value.


© 2021 Trail of Bits Uniswap V3 Core Assessment | 8


**TickBitmap.** TickBitmap defines three functions to obtain the position of a tick, flip a tick,
and retrieve the next initialized tick. We manually reviewed the conversion of ticks to the
wordPos and bitPos. We also reviewed the use of bitwise XOR to update the bitmap. For
the last function, we ran extensive tests, using the existing Echidna tests, to check whether
we could trigger an assertion.


**Tick.** This defines the tick struct, one pure function to calculate maximum liquidity per tick,
and four methods that operate on a tick struct. We studied the method by which
tickSpacing is enforced on the MIN_TICK and MAX_TICK and the corresponding code that
determines the number of ticks. We also examined the function to cross a tick to see if it
correctly updated all tick struct variables.


**Position.** This defines the position struct, a getter function that operates on the position
mapping, and an update function employed when a user wants to add or remove liquidity.
We examined the process of creating a position key to see if it was possible to create
overlapping position keys. We performed a manual review and wrote several unit tests to
determine if the update function correctly calculated and updated the fee-related position
struct variables, including in cases in which liquidityDelta was below zero, equal to zero,
and above zero.


**SqrtPriceMath.** This library contains formulas that operate between the prices, liquidities,
and token amounts. These functions are used

  - to identify the amount of tokens a user must transfer/receive in order to
add/remove liquidity from a position,

  - to identify what sizes of orders can be fulfilled based on the limit price and the price
of the next initialized tick within one word, and

  - to identify the next price if an order has been partially filled.
We were able to manually check the implementations of the `getAmount(0|1)Delta` and the
`getNextSqrtPriceFrom(Input|Output)` functions but not the
`getNextSqrtPriceFromAmount(0RoundUp|1RoundingDown)` functions. We checked for
correct signs, over- and underflow, and the correct handling of rounding.


**SwapMath.** This library contains just one function, `computeSwapStep`, which computes the
size of an order to fulfill, based on the current step parameters. Since this function fulfills
all four cases of (exactIn, zeroForOne) possibilities, we checked whether the
implementation was correct for all situations. We also checked that the correct type of
rounding (i.e., up or down) was used in all situations.


**Oracle.** This library contains a struct and provides functions to store (historical) liquidity
and the tick values of the pool’s tokens. We briefly reviewed the implementation, checking
that updating the cardinality preserved the monotonicity of the observations.


© 2021 Trail of Bits Uniswap V3 Core Assessment | 9


**SecondsOutside.** This library is used to track the amount of time that a position has been
active. It is gas-optimized by packing eight 32-bit timestamps inside one uint256. We
reviewed the use of bitwise operations to determine the bit-shift and wordPos of a tick. We
also confirmed that bitwise operations in the cross and clear functions were correct.


**NoDelegateCall.** This contract prevents the execution of delegate calls into Uniswap
contracts and is applied to most of the functions in the factory and pool contracts. We
manually checked that the implementation prevented delegate calls and did not lead to
any unexpected results.


**UniswapV3Factory.** This contract contains methods that allow anyone to create a new
pool, as well as owner-only methods that enable the creation of a new ( `fee`, `tickSpacing` )
pair and owner changes. We checked that a new fee and tickSpacing could not overwrite
existing entries. We also checked that the creation of a new pool correctly shuffled the
tokens when necessary and that no pool could overwrite an existing pool. In addition, we
inspected the chosen range of permitted tickSpacing values and its effect on the pool
contract. Lastly, we checked how control of the ownership role could be lost during
deployment or reassignment of the owner role.


**UniswapV3PoolDeployer.** This contract contains just one function to deploy a new pool
contract using CREATE2. We checked that the chosen arguments for the CREATE2 address
did not lead to any problems. We also checked that the use of CREATE2 would not cause
any issues (e.g., that it would not cause a pool to self-destruct).


**UniswapV3Pool.** This is the core contract of the Uniswap V3 project. Its main functions are
mint, burn, swap, and flash. Its numerous other functions include functions that update
protocol fee percentages, withdraw protocol fees, and withdraw a position’s collected fees,
as well as an initialize function to set an initial price upon deployment and various view
functions. For this contract, we performed an extensive manual review, wrote unit tests,
and wrote end-to-end Echidna tests.


We checked if the price could be manipulated through swap, mint, burn, or initialize and if
an attacker could manipulate the price to swap tokens at an unfair price. We also examined
how swaps of various amounts could be used to move the current price and if the price
movement could be exploited by an attacker to swap tokens at an unfair price. Additionally,
we reviewed the process of front-running an initialize call and how **such a call** could be
used by an attacker to execute (and profit off of) a swap at an unfair price. We assessed the
flash loan function to see if an attacker could use it without repaying the loan (+fee), as well
as the loop inside the swap function to see whether it could cause a denial of service due to
a large amount of very small ticks. We also inspected the swap, burn, and mint callback
functions, with an eye toward confirming that the surrounding checks were correctly
implemented to prevent minting/swapping at no cost. We examined various non-standard


© 2021 Trail of Bits Uniswap V3 Core Assessment | 10


ERC20 tokens and how they could lead to unexpected results when used in a pool,
confirmed that all functions inside the pool contract were implemented correctly, and
checked the validation of all function parameters. Lastly, we implemented more than 25
<u>Echidna end-to-end properties</u> to test various invariants for mint, burn, and swap.


Due to time constraints, Trail of Bits could not explore the following areas:

  - The Oracle functions, with the exception of those that deal with increasing the
cardinality

  - The last three lines of the `computeSwapStep` function, which deal with determining
the `feeAmount`

  - `TickBitmap.nextInitializedTickWithinOneWord`

  - `SecondsOutside.secondsInside`

  - Assembly inside `TickMath.getTickAtSqrtRatio`


© 2021 Trail of Bits Uniswap V3 Core Assessment | 11


### Automated Testing and Verification

Trail of Bits used automated testing techniques to enhance the coverage of certain areas of
the contracts, including the following:


  - <u>[Slither, a Solidity static analysis framework.](https://github.com/trailofbits/slither)</u>

  - <u>[Echidna, a smart contract fuzzer that can rapidly test security properties via](https://github.com/trailofbits/echidna)</u>
malicious, coverage-guided test case generation.

Automated testing techniques augment our manual security review but do not replace it.
Each method has limitations: Slither may identify security properties that fail to hold when
Solidity is compiled to EVM bytecode, and Echidna may not randomly generate an edge
case that violates a property.

#### Automated Testing with Echidna

We wrote more than 25 end-to-end properties. Because Uniswap had already implemented
many per-component Echidna tests, we decided to set up an end-to-end Echidna test suite.
We wrote Echidna tests for the swap, mint, and burn functions and achieved sufficient
Echidna test coverage throughout those functions. We implemented the following Echidna
properties:

###### End-to-End Properties







|ID|Property|Result|
|---|---|---|
|1<br>|Calling`mint` never leads to a decrease in`liquidity`. <br>|PASSED<br>|
|2<br>|Calling`mint` always leads to an increase in<br>`ticks(tickLower).liquidityGross`. <br>|PASSED<br>|
|3<br>|Calling`mint` always leads to an increase in<br>`ticks(tickUpper).liquidityGross`. <br>|PASSED<br>|
|4<br>|Calling`mint` always leads to an increase in<br>`ticks(tickLower).liquidityNet`. <br>|PASSED<br>|
|5<br>|Calling`mint` always leads to a decrease in<br>`ticks(tickUpper).liquidityNet`. <br>|PASSED<br>|
|6<br>|Calling`mint` always reverts if neither`tickLower` nor`tickUpper` is a<br>multiple of the conﬁgured`tickSpacing`. <br>|PASSED<br>|
|7<br>|Calling`burn` never leads to an increase in`liquidity`. <br>|PASSED<br>|


© 2021 Trail of Bits Uniswap V3 Core Assessment | 12


|8|Calling does not lead to an increase in<br>burn<br>.<br>ticks(tickLower).liquidityGross|PASSED|
|---|---|---|
|9<br>|Calling`burn` does  not  lead  to  an  increase  in<br>`ticks(tickUpper).liquidityGross`.  <br>|PASSED<br>|
|10<br>|Calling`burn` does  not  lead  to  an  increase  in<br>`ticks(tickLower).liquidityNet`.  <br>|PASSED<br>|
|11<br>|Calling`burn` does  not  lead  to  a  decrease  in<br>`ticks(tickUpper).liquidityNet`.  <br>|PASSED<br>|
|12<br>|Calling`burn` always  reverts  if  neither`tickLower` nor`tickUpper` is  a<br>multiple  of  the  conﬁgured`tickSpacing`.  <br>|PASSED<br>|
|13<br>|Calling`swap` with`zeroForOne` does  not  lead  to  a  decrease  in<br>`feeGrowthGobal0X128`.  <br>|PASSED<br>|
|14<br>|Calling`swap` with`zeroForOne` does  not  lead  to  a  change  in<br>`feeGrowthGobal1X128`.  <br>|PASSED<br>|
|15<br>|Calling`swap` with`!zeroForOne` does  not  lead  to  a  decrease  in<br>`feeGrowthGobal1X128`.  <br>|PASSED<br>|
|16<br>|Calling`swap` with`!zeroForOne` does  not  lead  to  a  change  in<br>`feeGrowthGobal0X128`.  <br>|PASSED<br>|
|17<br>|If  calling`swap` does  not  change  the`sqrtPriceX96`,`liquidity`will<br>not  change. <br>|PASSED<br>|
|18<br>|If  calling`swap` with`zeroForOne` does  not  lead  to  the  payment  of<br>token0,  it  will  not  lead  to  the  receipt  of`token1`.  <br>|PASSED<br>|
|19<br>|If  calling`swap` with`!zeroForOne` does  not  lead  to  the  payment  of<br>`token1`,  it  will  not  lead  to  the  receipt  of`token0`.<br>|PASSED<br>|
|20<br>|`liquidityNet` over  all  ticks  should  sum  to  zero.<br>|PASSED<br>|
|21<br>|`liquidity` is  equal  to  the  summation  of`liquidityNet` for  all  ticks<br>below  and  including  the  current`tick.`|PASSED<br>|
|22<br>|For  the  ticks  immediately  below  (`t_b`)  and  above  (`t_a`)  the  current<br>tick,`ticks[t_b].feeGrowthOutside0X128  +`<br>`ticks[t_a].feeGrowthOutside0X128  <=  feeGrowthGlobal0X128`.<br>|<br>PASSED<br>|
|23<br>|For  the  ticks  immediately  below  (`t_b`)  and  above  (`t_a`)  the  current<br>tick,`ticks[t_b].feeGrowthOutside1X128  +`<br>`ticks[t_a].feeGrowthOutside1X128  <=  feeGrowthGlobal1X128`.<br>|<br>PASSED<br>|



© 2021 Trail of Bits Uniswap V3 Core Assessment | 13


|24|and are<br>feeGrowthGlobal0X128 feeGrowthGlobal1X128<br>non-strictly increasing in calls to swap.|PASSED|
|---|---|---|
|25<br>|After a`mint`, calling the inverse`burn` always succeeds.<br>|PASSED<br>|
|26<br>|Calling`burn` on an existing position with amount zero never fails.<br>|PASSED<br>|
|27<br>|Burning x amount of a position always decreases<br>`position.liquidity` by x amount.<br>|PASSED<br>|
|28<br>|Burning less than the total position amount never fails.<br>|PASSED<br>|
|29<br>|Calling`burn` with amount zero does not change the`liquidity` of<br>the pool.<br>|PASSED<br>|

###### Arithmetic Properties







|ID|Property|Result|
|---|---|---|
|30<br>|`getNextSqrtPriceFromInput/getNextSqrtPriceFromOutput` <br>always returns a price between MIN_SQRT_RATIO and<br>MAX_SQRT_RATIO (inclusive). <br>|**FAILED**<br> <br>**( TOB-UNI-01**<br>**0 ) **<br>|

#### Verification with Manticore





Verification was performed with the experimental branch <u>`[dev-evm-experiments](https://github.com/trailofbits/manticore/tree/dev-evm-experiments)`</u> <u>, which</u>
contains new optimizations and is a work in progress. Trail of Bits will ensure that the
following properties hold once the branch has stabilized and been included in a Manticore
release:






|ID|Property|Result|
|---|---|---|
|1<br>|`BitMath.mostSignificantBit` returns  a  value  in`x  >=  2**msb  &&`<br>`(msb  ==  255  ||  x  <  2**(msb+1))`.  <br>|VERIFIED<br>|
|2<br>|`BitMath.leastSignificantBit` returns  a  value  in`((x  &  2**  lsb)`<br>`!=  0)  &&  ((x  &  (2**(lsb  -1)))  ==  0)`.  <br>|VERIFIED<br>|
|3<br>|If`LiquidityMath.addDelta` returns,  the  value  will  be  equal  to`x  +`<br>`uint128(y)`.  <br>|<br>VERIFIED<br>|



© 2021 Trail of Bits Uniswap V3 Core Assessment | 14


#### Manual Verification

|ID|Property|Result|
|---|---|---|
|1<br>|`amountIn + feeAmount` cannot overﬂow <br>|VERIFIED<br>( **Appendix H**)|


#### Automated Testing with Slither

We implemented the following Slither property:






|Property|Result|
|---|---|
|<br><br>Every  publicly  accessible  function  uses  the`lock` modiﬁer,  is<br>whitelisted,  or  is  a`view` function.<br>|PASSED<br> <br>( **APPENDIX  F**) <br>|



© 2021 Trail of Bits Uniswap V3 Core Assessment | 15


### Recommendations Summary

This section aggregates all the recommendations made during the engagement. Short-term
recommendations address the immediate causes of issues. Long-term recommendations
pertain to the development process and long-term design goals.

#### Short Term

<mark>❑</mark> **Designate msg.sender as the initial owner of a pool contract, and implement a**
**two-step ownership-transfer process.** This will ensure that the owner role is not assigned
to an address not controlled by any user. TOB-UNI-001

<mark>❑</mark> **Add a check ensuring that the** **`_owner`** **argument does not equal the existing** **`owner.`**
This check will prevent the emission of an event indicating that the owner role was changed
when it was actually reassigned to the current owner. <u>TOB-UNI-002</u>


<mark>❑</mark> **Add documentation explaining to users that the use of interest-earning tokens can**
**reduce the standard payments for minting and flash loans.** That way, they will not be
surprised if they use an interest-earning token through Uniswap. <u>TOB-UNI-003</u>


<mark>❑</mark> **Correct the sentence in the whitepaper regarding the effect of price movements**
**on the number of tokens that are touched.** This will prevent the whitepaper’s readers
from becoming confused. <u>TOB-UNI-004</u>


<mark>❑</mark> **Replace the** **`>=`** **with** **`<=`** **inside the** **`require`** **in the** **`swap`** **function and add at least one**
**unit test checking that the** **`IIA`** **error is thrown when too few tokens are transferred**
**from the initiator’s contract to the pool.** The current logic allows an attacker to drain the
pool. <u>TOB-UNI-005</u>


<mark>❑</mark> **Determine a reasonable minimum tick spacing requirement, or consider setting a**
**minimum for liquidity per position.** This will lower the likelihood of a DoS in the while
loop. <u>TOB-UNI-006</u>


<mark>❑</mark> **Consider moving price initialization operations to the constructor, adding access**
**controls to the initialize function, or enhancing the documentation to warn users**
**against price manipulation through the initialize function.** This will lower the risk of
users unknowingly falling victim to price manipulation during initialization of the pool.
<u>TOB-UNI-007</u>


<mark>❑</mark> **There does not appear to be a straightforward way to prevent** <u>TOB-UNI-008</u> **<u>. We</u>**
**recommend investigating the limits associated with pools without liquidity in some**


© 2021 Trail of Bits Uniswap V3 Core Assessment | 16


**ticks and ensuring that users are aware of the risks so that they can make informed**
**decisions.** <u>TOB-UNI-008</u>


<mark>❑</mark> **Check the contract’s existence prior to the low-level call in**
**`TransferHelper.safeTransfer`** **.** This will ensure that a swap reverts if the token to be
bought no longer exists, preventing the pool from accepting the token to be sold without
returning any tokens in exchange. <u>TOB-UNI-009</u>


<mark>❑</mark> **Check in** **`getNextSqrtPriceFromInput`** **/** **`getNextSqrtPriceFromOutput`** **that the**
**returned value is within** **`MIN_SQRT_RATIO`** **,** **`MAX_SQRT_RATIO`** **.** Including the check where
the calculation is performed will reduce the likelihood that a refactor will remove the check
and cause problems in calling functions. <u>TOB-UNI-010</u>


© 2021 Trail of Bits Uniswap V3 Core Assessment | 17


#### Long Term

<mark>❑</mark> **Use Slither, which will catch the missing** **`address(0)`** **check.** Using Slither will also
prevent important privileged roles from being assigned to address zero, which causes a
permanent loss of access to the role. TOB-UNI-001


<mark>❑</mark> **Carefully inspect the code to ensure that configuration functions do not allow a**
**value to be updated as the existing value.** This will prevent the emission of an event
falsely indicating a change. <u>TOB-UNI-002</u>


<mark>❑</mark> **Using the relevant recommendations in the token integration checklist ( Appendix**
**<u>E), generate a document detailing the shortcomings of tokens with certain features</u>**
**and the impacts of their use in the Uniswap V3 protocol.** That way, users will not be
alarmed if the use of a token with non-standard features leads to unexpected results.
<u>TOB-UNI-003</u>


<mark>❑</mark> **Finalize the whitepaper, ensuring that it is clear.** Enable as many users as possible to
read and understand the whitepaper and the inner workings of Uniswap. TOB-UNI-004


<mark>❑</mark> **Consider adding more properties and using** **<u>[Echidna](https://github.com/crytic/echidna)</u>** **or** **<u>[Manticore to verify that](https://github.com/trailofbits/manticore)</u>**
**initiators are correctly transferring tokens to the pool.** The current tests did not catch a
critical bug in the swap callback. <u>TOB-UNI-005</u>


<mark>❑</mark> **Consider adding at least one unit test for each error that can be thrown by the**
**contracts.** With a unit test, each error in the contract/libraries would be thrown when it
should be, at least in simple cases. TOB-UNI-005


<mark>❑</mark> **Make sure that all parameters that the owner can enable (such as fee level and**
**tick spacing) have bounds that lead to expected behavior, and clearly document**
**those bounds, such as in a markdown file or in the whitepaper.** Documentation would
allow users to inspect the enabled fee levels and tick spacings, which could affect whether
they decide to use a specific pool or to create one with the desired fee and tick spacing.
<u>TOB-UNI-006</u>


<mark>❑</mark> **Avoid initialization outside of the constructor. If that is not possible, ensure that**
**the underlying risks of initialization are documented and properly tested.**
Initialization done outside of the constructor is error-prone and a bad practice and can lead
to contract compromise. TOB-UNI-007


<mark>❑</mark> **Ensure that pools can never end up in an unexpected state.** This will ensure that the
system’s behavior is predictable at all states. <u>TOB-UNI-008</u>


© 2021 Trail of Bits Uniswap V3 Core Assessment | 18


<mark>❑</mark> **[Avoid low-level calls. If such a call is not avoidable, carefully review the Solidity](http://solidity.readthedocs.io/en/develop/control-structures.html#error-handling-assert-require-revert-and-exceptions)**
**<u>[documentation, particularly the “Warnings” section.](http://solidity.readthedocs.io/en/develop/control-structures.html#error-handling-assert-require-revert-and-exceptions)</u>** This will protect against
unforeseen (missing) features of the Solidity language. TOB-UNI-009


<mark>❑</mark> **Document every bound for all arithmetic functions and test every bound with**
**Echidna and Manticore.** Documentation will ensure that each function’s bounds are
immediately clear, and testing will ensure that functions do not return out-of-bound values.
<u>TOB-UNI-010</u>


© 2021 Trail of Bits Uniswap V3 Core Assessment | 19


### Findings Summary


























|#|Title|Type|Severity|
|---|---|---|---|
|1<br>|Missing  validation  of`_owner` argument <br>could  indeﬁnitely  lock  owner  role  <br>|Data  Validation<br>|<br>Medium<br>|
|2<br>|Missing  validation  of`_owner` argument <br>could  lead  to  incorrect  event  emission <br>|Auditing  and<br>Logging<br>|Informational<br>|
|3<br>|Anyone  could  steal  pool  tokens’  earned  <br>interest  <br>|Timing<br>|Low<br>|
|4<br>|Whitepaper  contains  incorrect  equation  <br>|Undeﬁned<br>Behavior<br>|Informational<br>|
|5<br>|Incorrect  comparison  enables  swapping <br>and  token  draining  at  no  cost  <br>|Undeﬁned<br>Behavior<br>|High<br>|
|6<br>|Unbound  loop  enables  denial  of  service  <br>|Data  Validation<br>|<br>Medium<br>|
|7<br>|Front-running  pool’s  initialization  can  lead  <br>to  draining  of  liquidity  provider’s  initial  <br>deposits <br>|Data  Validation<br>|<br>Medium<br>|
|8<br>|Swapping  on  zero  liquidity  allows  for <br>control  of  the  pool’s  price <br>|Data  Validation<br>|<br>Medium<br>|
|9<br>|Failed  transfer  may  be  overlooked  due  to <br>lack  of  contract  existence  check  <br>|Data  Validation<br>|<br>High<br>|
|<br><br>10|`getNextSqrtPriceFromInput|Output` can  <br>return  a  value  outside  of  <br>`MIN_SQRT_RATIO`,`MAX_SQRT_RATIO  `|Data  Validation<br>|<br>Informational<br>|



© 2021 Trail of Bits Uniswap V3 Core Assessment | 20


#### 1. Missing validation of  _owner  argument could indefinitely lock owner role

Severity: Medium Difficulty: High
Type: Data Validation Finding ID: TOB-UNI-001
Target: `UniswapV3Factory.sol`


**Description**
A lack of input validation of the `_owner` argument in both the `constructor` and `setOwner`
functions could permanently lock the owner role, requiring a costly redeploy.


The `constructor` calls `_enableFeeAmount` to add three available initial fees and tick
spacings. This means that, as far as a regular user is concerned, the contract will work,
allowing the creation of pairs and all functionality needed to start trading. In other words,
the incorrect owner role may not be noticed before the contract is put into use.


The following functions are callable only by the owner:

  - `UniswapV3Factory.enableFeeAmount`

    - Called to add more fees with specific tick spacing.

  - `UniswapV3Pair.setFeeTo`

    - Called to update the fees’ destination address.

  - `UniswapV3Pair.recover`

    - Called to withdraw accidentally sent tokens from the pair.

  - `UniswapV3Factory.setOwner`

    - Called to change the owner.

To resolve an incorrect owner issue, Uniswap would need to redeploy the factory contract
and re-add pairs and liquidity. Users might not be happy to learn of these actions, which


© 2021 Trail of Bits Uniswap V3 Core Assessment | 21


could lead to reputational damage. Certain users could also decide to continue using the
original factory and pair contracts, in which owner functions cannot be called. This could
lead to the concurrent use of two versions of Uniswap, one with the original factory
contract and no valid owner and another in which the owner was set correctly.


Trail of Bits identified four distinct cases in which an incorrect owner is set:

  - Passing `address(0)` to the `constructor`

  - Passing `address(0)` to the `setOwner` function

  - Passing an incorrect address to the `constructor`

  - Passing an incorrect address to the `setOwner` function.


**Exploit Scenario**
Alice deploys the `UniswapV3Factory` contract but mistakenly passes `address(0)` as the
`_owner` .


**Recommendation**
Several improvements could prevent the four abovementioned cases:

  - Designate `msg.sender` as the initial owner, and transfer ownership to the chosen
owner after deployment.

  - Implement a two-step ownership-change process through which the new owner
needs to accept ownership.

  - If it needs to be possible to set the owner to `address(0)`, implement a
`renounceOwnership` function.

Long term, use Slither, which will catch the missing `address(0)` check, and consider using
two-step processes to change important privileged roles.


© 2021 Trail of Bits Uniswap V3 Core Assessment | 22


#### 2. Missing validation of  _owner  argument could lead to incorrect event emission

Severity: Informational Difficulty: High
Type: Auditing and Logging Finding ID: TOB-UNI-002
Target: `UniswapV3Factory.sol`


**Description**
Because the `setOwner` lacks input validation, the owner can be updated to the existing
owner. Although such an update wouldn’t change the contract state, it would emit an event
falsely indicating the owner had been changed.


**Exploit Scenario**
Alice has set up monitoring of the `OwnerChanged` event to track transfers of the owner role.
Bob, the current owner, calls `setOwner` to update the owner to his address (not actually
making a change). Alice is notified that the owner was changed but upon closer inspection
discovers it was not.


**Recommendation**
Short term, add a check ensuring that the `_owner` argument does not equal the existing
`owner` .


Long term, carefully inspect the code to ensure that configuration functions do not allow a
value to be updated as the existing value. Such updates are not inherently problematic but
could cause confusion among users monitoring the events.


© 2021 Trail of Bits Uniswap V3 Core Assessment | 23


#### 3. Anyone could steal pool tokens’ earned interest

Severity: Low Difficulty: Medium
Type: Timing Finding ID: TOB-UNI-003
Target: `UniswapV3Pool.sol`


**Description**
Unexpected ERC20 token interest behavior might allow token interest to count toward the
amount of tokens required for the `UniswapV3Pool.mint` and `flash` functions, enabling the
user to avoid paying in full.


The mint function allows an account to increase its liquidity in a position. To verify that the
pool has received at least the minimum amount of tokens necessary, the following code is
used:


Assume that both `amount0` and `amount1` are positive. First, the current balances of the
tokens are fetched. This step is followed by a call to the `uniswapV3MintCallback` function
of the caller, which should transfer the required amount of each token to the pool contract.
Finally, the code verifies that each token’s balance has increased by at least the required
amount.


A token could allow token holders to earn interest simply because they are token holders.
It is possible that to retrieve this interest, any token holder could call a function to calculate
the interest earned and increase the token holder’s balance.


An attacker could call the function to pay out interest to the pool contract from within the
`uniswapV3MintCallback` function. This would increase the pool’s token balance, decreasing
the number of tokens that the user needs to transfer to the pool contract in order to pass
the balance check (i.e., the check confirming that the balance has sufficiently increased). In
effect, the user’s token payment obligation is reduced because the interest accounts for
part of the required balance increase.


To date, we have not identified a token contract that contains such a functionality;
however, it is possible that one could exist or be created.


Similarly, the `flash` function allows any user to secure a flash loan from the pool.


© 2021 Trail of Bits Uniswap V3 Core Assessment | 24


**Exploit Scenario**
Bob deploys a pool with token1 and token2. Token1 allows all of its holders to earn passive
interest. Anyone can call `get_interest(address)` to make a specific token holder’s interest
be claimed and added to the token holder’s balance. Over time, the pool can claim 1,000
tokens. Eve calls `mint` on the pool, such that the pool requires Eve to send 1,000 tokens.
Eve calls `get_interest(address)` instead of sending the tokens, adding liquidity to the
pool without paying.


**Recommendation**
Short term, add documentation explaining to users that the use of interest-earning tokens
can reduce the standard payments for minting and flash loans.


Long term, using the token integration checklist (Appendix E ), generate a document
detailing the shortcomings of tokens with certain features and the impacts of their use in
the Uniswap V3 protocol. That way, users will not be alarmed if the use of a token with
non-standard features leads to unexpected results.


© 2021 Trail of Bits Uniswap V3 Core Assessment | 25


#### 4. Whitepaper contains incorrect equation

Severity: Informational Difficulty: High
Type: Undefined Behavior Finding ID: TOB-UNI-004
Target: Whitepaper

**Description**
The whitepaper contains the following statement:


This formula does not make sense, even for a trivial case. When the price is constant (i.e., _N_
_= 1_ ), the function indicates that 1/1 (i.e., 100%) of the pool’s liquidity is touched.


The correct formula is `1- 1 /` √ `N` .


**Exploit Scenario**
Alice is a Uniswap user or a developer of integrated products. She reads the whitepaper
and misunderstands the system, causing her users to lose money.


**Recommendation**
Short term, correct the following sentence:


Long term, finalize the whitepaper, ensuring that it is clear.


© 2021 Trail of Bits Uniswap V3 Core Assessment | 26


#### 5. Incorrect comparison enables swapping and token draining at no cost

Severity: High Difficulty: Low
Type: Data Validation Finding ID: TOB-UNI-005
Target: UniswapV3Pool.sol


**Description**
An incorrect comparison in the `swap` function allows the swap to succeed even if no tokens
are paid. This issue could be used to drain any pool of all of its tokens at no cost.


The `swap` function calculates how many tokens the initiator ( `msg.sender` ) needs to pay
( `amountIn` ) to receive the requested amount of tokens ( `amountOut` ). It then calls the
`uniswapV3SwapCallback` function on the initiator’s account, passing in the amount of
tokens to be paid. The callback function should then transfer at least the requested
amount of tokens to the pool contract. Afterward, a `require` inside the `swap` function
verifies that the correct amount of tokens ( `amountIn` ) has been transferred to the pool.


However, the check inside the `require` is incorrect. Instead of checking that _at least_ the
requested amount of tokens has been transferred to the pool, it checks that _no more than_
the requested amount has been transferred. In other words, if the callback does not
transfer any tokens to the pool, the check, and the swap, will succeed without the initiator
having paid any tokens.


**Exploit Scenario**
Bob deploys a pool for USDT/DAI. The pool holds 1,000,000 DAI. Eve calls a swap for
1,000,000 DAI but transfers 0 USDT, stealing all of the DAI from the pool.

**Recommendation**
Short term, replace the `>=` with `<=` inside the `require` in the `swap` function. Add at least one
unit test checking that the `IIA` error is thrown when too few tokens are transferred from
the initiator’s contract to the pool.


Long term, consider adding at least one unit test for each error that can be thrown by the
contracts. With a unit test, an error would be thrown when it should be, at least in a simple


© 2021 Trail of Bits Uniswap V3 Core Assessment | 27


[case. Also consider adding more properties and using Echidna](https://github.com/crytic/echidna) or <u>[Manticore](https://github.com/trailofbits/manticore)</u> to verify that
initiators are correctly transferring tokens to the pool.


© 2021 Trail of Bits Uniswap V3 Core Assessment | 28


#### 6. Unbound loop enables denial of service

Severity: Medium Difficulty: High
Type: Data Validation Finding ID: TOB-UNI-006
Target: _`UniswapV3Pool.sol`_

**Description**
The `swap` function relies on an unbounded loop. An attacker could disrupt swap operations
by forcing the loop to go through too many operations, potentially trapping the swap due
to a lack of gas.


`UniswapV3Pool.swap` iterates over the tick:


On every loop iteration, there is a swap on the current tick’s price, increasing it to the next
price limit. The next price limit depends on the next tick:

```
 (step.tickNext, step.initialized) = tickBitmap.nextInitializedTickWithinOneWord(
     state.tick,
     tickSpacing,
     zeroForOne
 );

 // ensure that we do not overshoot the min/max tick, as the tick bitmap is not aware of
 these bounds
 if (step.tickNext < TickMath.MIN_TICK) {
     step.tickNext = TickMath.MIN_TICK;
 } else if (step.tickNext > TickMath.MAX_TICK) {
     step.tickNext = TickMath.MAX_TICK;
 }

 // get the price for the next tick

```

© 2021 Trail of Bits Uniswap V3 Core Assessment | 29


```
 step.sqrtPriceNextX96 = TickMath.getSqrtRatioAtTick(step.tickNext);
```

_<u>Figure 6.2:</u>_ _`UniswapV3Pool.sol#L549-L563`_

The next tick is the next initialized tick (or an uninitialized tick if no initialized tick is found).


A conservative gas cost analysis of the loop iteration returns the following estimates:

1. ~50,000 gas per iteration if there is no previous fee on the tick (7 SLOAD, 1 SSTORE
from non-zero to non-zero, 2 SSTORE from zero to non-zero).
2. ~20,000 gas per iteration if there are previous fees on the tick (7 SLOAD, 3 SSTORE
from non-zero to non-zero).

The current block gas limit is 12,500,000. As a result, the swap operation will not be doable
if it requires more than 2,500 (scenario 1) or 6,250 (scenario 2) iterations.


An attacker could create thousands of positions with 1 wei to make the system very costly
and potentially prevent swap operations.


An attacker would have to pay gas to create the position. However, an Ethereum miner
could create a position for free, and if the system were deployed on a layer 2 solution (e.g.,
optimism), the attacker’s gas payment would be significantly lower.


**Exploit Scenario**
Eve is a malicious miner involved with a Uniswap competitor. Eve creates thousands of
positions in every Uniswap V3 pool to prevent users from using the system.


**Recommendation**
Short term, to mitigate the issue, determine a reasonable minimum tick spacing
requirement, or consider setting a minimum for liquidity per position.


Long term, make sure that all parameters that the owner can enable (such as fee level and
tick spacing) have bounds that lead to expected behavior, and clearly document those
bounds, such as in a markdown file or in the whitepaper.


© 2021 Trail of Bits Uniswap V3 Core Assessment | 30


#### 7. Front-running pool’s initialization can lead to draining of liquidity provider’s initial deposits

Severity: Medium Difficulty: High
Type: Data Validation Finding ID: TOB-UNI-007
Target: _`UniswapV3Pool.sol`_

**Description**
A front-run on `UniswapV3Pool.initialize` allows an attacker to set an unfair price and to
drain assets from the first deposits.


`UniswapV3Pool.initialize` initiates the pool’s price:


There are no access controls on the function, so anyone could call it on a deployed pool.


Initializing a pool with an incorrect price allows an attacker to generate profits from the
initial liquidity provider’s deposits.


**Exploit Scenario**

  - Bob deploys a pool for assets A and B through a deployment script. The current
market price is 1 A == 1 B.

  - Eve front-runs Bob’s transaction to the `initialize` function and sets a price such
that 1 A ~= 10 B.


© 2021 Trail of Bits Uniswap V3 Core Assessment | 31


  - Bob calls mint and deposits assets A and B worth $100,000, sending ~10 times more
of asset B than asset A.

  - Eve swaps A tokens for B tokens at an unfair price, profiting off of Bob’s
deployment.

Two tests that demonstrate such an attack are included in <u>Appendix G .</u>


**Recommendation**
Short term, consider

  - moving the price operations from `initialize` to the constructor,

  - adding access controls to `initialize`, or

  - ensuring that the documentation clearly warns users about incorrect initialization.

Long term, avoid initialization outside of the constructor. If that is not possible, ensure that
the underlying risks of initialization are documented and properly tested.


© 2021 Trail of Bits Uniswap V3 Core Assessment | 32


#### 8. Swapping on zero liquidity allows for control of the pool’s price

Severity: Medium Difficulty: Medium
Type: Data Validation Finding ID: TOB-UNI-008
Target: `UniswapV3Pool.sol, libraries/SwapMath.sol`


**Description**
Swapping on a tick with zero liquidity enables a user to adjust the price of 1 wei of tokens in
any direction. As a result, an attacker could set an arbitrary price at the pool’s initialization
or if the liquidity providers withdraw all of the liquidity for a short time.


Swapping 1 wei in `exactIn` with a liquidity of zero and a fee enabled will cause
`amountRemainingLessFee` and `amountIn` to be zero:

```
 uint256 amountRemainingLessFee = FullMath.mulDiv( uint256 (amountRemaining), 1e6 - feePips,
 1e6);
 amountIn = zeroForOne
  ? SqrtPriceMath.getAmount0Delta(sqrtRatioTargetX96, sqrtRatioCurrentX96, liquidity, true )
  : SqrtPriceMath.getAmount1Delta(sqrtRatioCurrentX96, sqrtRatioTargetX96, liquidity, true );
```

_<u>Figure 8.1:</u>_ _`libraries/SwapMath.sol#L41-L44`_

As `amountRemainingLessFee == amountIn`, the next square root ratio will be the square
root target ratio:

```
 if (amountRemainingLessFee >= amountIn) sqrtRatioNextX96 = sqrtRatioTargetX96;
```

_<u>Figure 8.2:</u>_ _`libraries/SwapMath.sol#L45`_

The next square root ratio assignment results in updates to the pool’s price and tick:

```
 // shift tick if we reached the next price
 if (state.sqrtPriceX96 == step.sqrtPriceNextX96) {
   // if the tick is initialized, run the tick transition
   if (step.initialized) {
     int128 liquidityNet =
       ticks.cross(
         step.tickNext,
         (zeroForOne ? state.feeGrowthGlobalX128 : feeGrowthGlobal0X128),
         (zeroForOne ? feeGrowthGlobal1X128 : state.feeGrowthGlobalX128)
       );
     // if we're moving leftward, we interpret liquidityNet as the opposite sign
     // safe because liquidityNet cannot be type(int128).min
     if (zeroForOne) liquidityNet = -liquidityNet;

     secondsOutside.cross(step.tickNext, tickSpacing, cache.blockTimestamp);

```

© 2021 Trail of Bits Uniswap V3 Core Assessment | 33


```
     state.liquidity = LiquidityMath.addDelta(state.liquidity, liquidityNet);
   }
```

_<u>Figure 8.3:</u>_ _`UniswapV3Pool.sol#L595-L612`_

On a tick without liquidity, anyone could move the price and the tick in any direction. A user
could abuse this option to move the initial pool’s price (e.g., between its initialization and
minting) or to move the pool’s price if all the liquidity is temporarily withdrawn.


**Exploit Scenario**

  - Bob initializes the pool’s price to have a ratio such that 1 token0 == 10 token1.

  - Eve changes the pool’s price such that 1 token0 == 1 token1.

  - Bob adds liquidity to the pool.

  - Eve executes a swap and profits off of the unfair price.

<u>Appendix I</u> contains a unit test for this issue.


**Recommendation**
Short term, there does not appear to be a straightforward way to prevent the issue. We
recommend investigating the limits associated with pools without liquidity in some ticks
and ensuring that users are aware of the risks.


Long term, ensure that pools can never end up in an unexpected state.


© 2021 Trail of Bits Uniswap V3 Core Assessment | 34


#### 9. Failed transfer may be overlooked due to lack of contract existence check

Severity: High Difficulty: High
Type: Data Validation Finding ID: TOB-UNI-009
Target: `libraries/TransferHelper.sol`

**Description**
Because the pool fails to check that a contract exists, the pool may assume that failed
transactions involving destructed tokens are successful.


`TransferHelper.safeTransfer` performs a transfer with a low-level call without
confirming the contract’s existence:

```
 ) internal {
   ( bool success, bytes memory data) =
      token.call(abi.encodeWithSelector(IERC20Minimal.transfer.selector, to, value));
   require (success && (data.length == 0 || abi.decode(data, ( bool ))), 'TF' );
```

_<u>Figure 9.1:</u>_ _`libraries/TransferHelper.sol#L18-L21`_

The <u>[Solidity documentation includes the following warning:](http://solidity.readthedocs.io/en/develop/control-structures.html#error-handling-assert-require-revert-and-exceptions)</u>


_The low-level call, delegatecall, and callcode will return success if the calling account is_
_non-existent, as part of the design of EVM. Existence must be checked prior to calling if desired._

_<u>Figure 9.2: The Solidity documentation details the necessity of executing existence checks prior to</u>_

_performing a delegatecall._

As a result, if the tokens have not yet been deployed or have been destroyed,
`safeTransfer` will return success even though no transfer was executed.


If the token has not yet been deployed, no liquidity can be added. However, if the token
has been destroyed, the pool will act as if the assets were sent even though they were not.


**Exploit Scenario**
The pool contains tokens A and B. Token A has a bug, and the contract is destroyed. Bob is
not aware of the issue and swaps 1,000 B tokens for A tokens. Bob successfully transfers
1,000 B tokens to the pool but does not receive any A tokens in return. As a result, Bob
loses 1,000 B tokens.

**Recommendation**
Short term, check the contract’s existence prior to the low-level call in
`TransferHelper.safeTransfer` . This will ensure that a swap reverts if the token to be


© 2021 Trail of Bits Uniswap V3 Core Assessment | 35


bought no longer exists, preventing the pool from accepting the token to be sold without
returning any tokens in exchange.


Long term, avoid low-level calls. If such a call is not avoidable, carefully review the <u>[Solidity](http://solidity.readthedocs.io/en/develop/control-structures.html#error-handling-assert-require-revert-and-exceptions)</u>
<u>[documentation, particularly the “Warnings” section.](http://solidity.readthedocs.io/en/develop/control-structures.html#error-handling-assert-require-revert-and-exceptions)</u>


© 2021 Trail of Bits Uniswap V3 Core Assessment | 36


#### 10.  getNextSqrtPriceFromInput|Output  can return a value outside of  MIN_SQRT_RATIO,  MAX_SQRT_RATIO

Severity: Informational Difficulty: High
Type: Data Validation Finding ID: TOB-UNI-010
Target: `libraries/SqrtPriceMath.sol, libraries/TickMath.sol`


**Description**
`getNextSqrtPriceFromInput|Output` takes a square price and returns the next square
ratio price. A square ratio price should be between [ `MIN_SQRT_RATIO`, `MAX_SQRT_RATIO]` ;
however, `getNextSqrtPriceFromInput|Output` does not confirm that is the case.


The square ratio price’s limit is defined with `MIN_SQRT_RATIO/MAX_SQRT_RATIO:`

```
 /// @dev The minimum value that can be returned from #getSqrtRatioAtTick. Equivalent to
 getSqrtRatioAtTick(MIN_TICK)
 uint160 internal constant MIN_SQRT_RATIO = 4295128739 ;
 /// @dev The maximum value that can be returned from #getSqrtRatioAtTick. Equivalent to
 getSqrtRatioAtTick(MAX_TICK)
 uint160 internal constant MAX_SQRT_RATIO =
 1461446703485210103287273052203988822378723970342 ;
```

_<u>Figure 10.1:</u>_ _`libraries/TickMath.sol#L13-L16`_

`getNextSqrtPriceFromInput` / `getNextSqrtPriceFromOutput` returns a next square price
ratio based on the current one:

```
   /// @notice Gets the next sqrt price given an input amount of token0 or token1
   /// @dev Throws if price or liquidity are 0, or if the next price is out of bounds
   /// @param sqrtPX96 The starting price, i.e., before accounting for the input amount
   /// @param liquidity The amount of usable liquidity
   /// @param amountIn How much of token0, or token1, is being swapped in
   /// @param zeroForOne Whether the amount in is token0 or token1
   /// @return sqrtQX96 The price after adding the input amount to token0 or token1
   function getNextSqrtPriceFromInput (
     uint160 sqrtPX96,
     uint128 liquidity,
     uint256 amountIn,
     bool zeroForOne
   ) internal pure returns ( uint160 sqrtQX96 ) {
     require (sqrtPX96 > 0 );
     require (liquidity > 0 );

     // round to make sure that we don't pass the target price
     return
       zeroForOne

```

© 2021 Trail of Bits Uniswap V3 Core Assessment | 37


```
         ? getNextSqrtPriceFromAmount0RoundingUp(sqrtPX96, liquidity, amountIn, true )
         : getNextSqrtPriceFromAmount1RoundingDown(sqrtPX96, liquidity, amountIn,
 true );
   }

   /// @notice Gets the next sqrt price given an output amount of token0 or token1
   /// @dev Throws if price or liquidity are 0 or the next price is out of bounds
   /// @param sqrtPX96 The starting price before accounting for the output amount
   /// @param liquidity The amount of usable liquidity
   /// @param amountOut How much of token0, or token1, is being swapped out
   /// @param zeroForOne Whether the amount out is token0 or token1
   /// @return sqrtQX96 The price after removing the output amount of token0 or token1
   function getNextSqrtPriceFromOutput (
     uint160 sqrtPX96,
     uint128 liquidity,
     uint256 amountOut,
     bool zeroForOne
   ) internal pure returns ( uint160 sqrtQX96 ) {
     require (sqrtPX96 > 0 );
     require (liquidity > 0 );

     // round to make sure that we pass the target price
     return
       zeroForOne
         ? getNextSqrtPriceFromAmount1RoundingDown(sqrtPX96, liquidity, amountOut,
 false )
         : getNextSqrtPriceFromAmount0RoundingUp(sqrtPX96, liquidity, amountOut,
 false );
   }
```

_<u>Figure 10.1:</u>_ _`libraries/SqrtPriceMath.sol#L102-L146`_

Both functions allow the next square ratio to be outside of its expected bounds.


Currently, the issue is not exploitable, as the bound is checked in `getTickAtSqrtRatio:`

```
  function getTickAtSqrtRatio ( uint160 sqrtPriceX96 ) internal pure returns ( int24 tick ) {
     // second inequality must be < because the price can never reach the price at the
 max tick
     require (sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO, 'R' );
```

_<u>Figure 10.2:</u>_ _`libraries/TickMath.sol#L60-L62`_


**Exploit Scenario**
The code is refactored, and the check in `getTickAtSqrtRatio` is removed.
`getNextSqrtPriceFromInput` is called with the following and returns 1:

  - sqrtPriceX96 =  192527866349542497182378200028923523296830566619


© 2021 Trail of Bits Uniswap V3 Core Assessment | 38


  - liquidity = 3121856577256316178563069792952001938

  - Amount =
87976224064120683466372192477762052080551804637393713865979671817311
849605529

  - Round up = true.
As a result, the next square ratio price is outside of the expected bounds.


**Recommendation**
Short term, check in `getNextSqrtPriceFromInput` / `getNextSqrtPriceFromOutput` that the
returned value is within `MIN_SQRT_RATIO`, `MAX_SQRT_RATIO.`

Long term, document every bound for all arithmetic functions and test every bound with
Echidna and Manticore.


© 2021 Trail of Bits Uniswap V3 Core Assessment | 39


### A. Vulnerability Classifcations i

|Vulnerability Classes|Col2|
|---|---|
|**Class**<br>|**Description**<br>|
|Access Controls<br>|Related to authorization of users and assessment of rights.<br>|
|Auditing and Logging<br>|Related to auditing of actions or logging of problems.<br>|
|Authentication<br>|Related to the identiﬁcation of users.<br>|
|Conﬁguration<br>|Related to security conﬁgurations of servers, devices, or<br>software.<br>|
|Cryptography<br>|Related to protecting the privacy or integrity of data.<br>|
|Data Exposure<br>|Related to unintended exposure of sensitive information.<br>|
|Data Validation<br>|Related to improper reliance on the structure or values of data.<br>|
|Denial of Service<br>|Related to causing a system failure.<br>|
|Error Reporting<br>|Related to the reporting of error conditions in a secure fashion.<br>|
|Patching<br>|Related to keeping software up to date.<br>|
|Session Management<br>|Related to the identiﬁcation of authenticated users.<br>|
|Timing<br>|Related to race conditions, locking, or the order of operations.<br>|
|<br><br>Undeﬁned Behavior<br>|Related to undeﬁned behavior triggered by the program.<br>|


|Severity Categories|Col2|
|---|---|
|**Severity**<br>|**Description**<br>|
|Informational<br>|The issue does not pose an immediate risk but is relevant to security<br>best practices or Defense in Depth.<br>|
|Undetermined<br>|The extent of the risk was not determined during this engagement.|
|Low<br>|The risk is relatively small or is not a risk the customer has indicated is<br>important.<br>|
|Medium<br>|Individual users’ information is at risk; exploitation could pose|



© 2021 Trail of Bits Uniswap V3 Core Assessment | 40


|Col1|reputational, legal, or moderate financial risks to the client.|
|---|---|
|<br><br>High<br>|The issue could aﬀect numerous users and have serious reputational,<br>legal, or ﬁnancial implications for the client.<br>|


|Difficulty Levels|Col2|
|---|---|
|**Diﬃculty**<br>|**Description**<br>|
|Undetermined<br>|The diﬃculty of exploitation was not determined during this<br>engagement.<br>|
|Low<br>|Commonly exploited public tools exist, or such tools can be scripted.<br>|
|Medium<br>|An attacker must write an exploit or will need in-depth knowledge of<br>a complex system.<br>|
|<br><br><br>High<br>|An attacker must have privileged insider access to the system, may<br>need to know extremely complex technical details, or must discover<br>other weaknesses to exploit this issue.<br> <br> <br>|


© 2021 Trail of Bits Uniswap V3 Core Assessment | 41


### B. Code Maturity Classifications












|Code Maturity Classes|Col2|
|---|---|
|**Category  Name**<br>|**Description**<br>|
|Access  Controls <br>|Related  to  the  authentication  and  authorization  of  components. <br>|
|Arithmetic <br>|Related  to  the  proper  use  of  mathematical  operations  and<br>semantics. <br>|
|Assembly  Use <br>|Related  to  the  use  of  inline  assembly. <br>|
|Centralization <br>|Related  to  the  existence  of  a  single  point  of  failure.|
|Upgradeability <br>|Related  to  contract  upgradeability. <br>|
|Function<br>Composition <br>|Related  to  separation  of  the  logic  into  functions  with  clear  purposes. <br>|
|Front-Running<br>|Related  to  resilience  against  front-running.<br>|
|Key  Management <br>|Related  to  the  existence  of  proper  procedures  for  key  generation,<br>distribution,  and  access. <br>|
|Monitoring <br>|Related  to  the  use  of  events  and  monitoring  procedures. <br>|
|Speciﬁcation <br>|Related  to  the  expected  codebase  documentation. <br>|
|<br><br>Testing  &<br>Veriﬁcation <br>|Related  to  the  use  of  testing  techniques  (unit  tests,  fuzzing,  symbolic<br>execution,  etc.). <br>|



|Rating Criteria|Col2|
|---|---|
|**Rating**<br>|**Description**<br>|
|Strong<br>|The component was reviewed, and no concerns were found.<br>|
|Satisfactory<br>|The component had only minor issues.<br>|
|Moderate<br>|The component had some issues.<br>|
|Weak<br>|The component led to multiple issues; more issues might be present.<br>|
|Missing<br>|The component was missing.<br>|


© 2021 Trail of Bits Uniswap V3 Core Assessment | 42


|Not Applicable|The component is not applicable.|
|---|---|
|Not  Considered<br>|The  component  was  not  reviewed.<br>|
|<br><br>Further<br>Investigation<br>Required<br>|The  component  requires  further  investigation.<br>|



© 2021 Trail of Bits Uniswap V3 Core Assessment | 43


### C. Non-security-related Findings

The following recommendations are not associated with specific vulnerabilities. However,
they enhance code readability and may prevent the introduction of vulnerabilities in the
future.


© 2021 Trail of Bits Uniswap V3 Core Assessment | 44


  - **Rename the** `getNextPrice` **functions.** The functions
```
   getNextPrice(FromAmount0RoundingUp|Amount1RoundingDown|Input|Output)
```

return not the price but the root of the price. They should be renamed to
`getNextSqrtPriceX` ; this will facilitate code comprehension.

**●** **Fix** `isMulSafe` **.** Currently, `isMulSafe` throws, consuming all gas, when the first
parameter is 0, even though premultiplication by 0 is safe for all unsigned integers,
`y` .

```
BitMath.sol
```

  - **Rename the BitMath functions.** The `BitMath.(most|least)SignificantBit`
functions don’t return the most/least significant bit of an integer. Consider renaming
them to better reflect their actual behavior and facilitate code comprehension.

**●** **Update the** **`mostSignificantBit`** **’s comment to contain the correct property.**
<u>The comment states that the function returns the following:</u>

```
     x >= 2**mostSignificantBit(x) and x < 2**(mostSignificantBit(x)+1)
```

<u>In actuality, it returns the following:</u>

```
     x >= 2**mostSignificantBit(x) && (mostSignificantBit(x) == 255 || x <
     2**(mostSignificantBit(x)+1))

```

© 2021 Trail of Bits Uniswap V3 Core Assessment | 45


### D. Whitepaper Recommendations

This section lists recommendations for improving the whitepaper (specifically the version
provided to Trail of Bits during our initial one-week review in January).


  - **Add definitions for each symbol.** Most of the symbols are explained inline.
However, some lack a definition. For example, what does b 0 stand for— “balance”?
Also consider adding a symbol table at the beginning of each section instead of
inlining the definitions.

  - **Use the same naming system in the whitepaper and the codebase.** The
whitepaper includes several references to functions that do not exist in the
codebase (e.g., `getValueForPrice)` .

**●** **Add concrete examples of formulas.** Most formulas lack concrete examples,
which would help clarify the formulas. For example, consider adding a concrete
example of the geometric mean calculation, possibly by comparing it to a concrete
example of the arithmetic mean calculation used in previous versions of Uniswap.

**●** **Replace the TODOs.** There are numerous TODOs throughout the whitepaper.
These include small assumptions that still need to be addressed (e.g., in _section 1.5,_
_“do we also assume transfer and transferFrom cause an increase or decrease by the right_
_amount”)_, formulas that need to be replaced (e.g., the last line of section 1.5,
“Invariants”), and entire sections that need to be added in (e.g., section 1.3,
“Crossing a tick”). The inclusion of such a high number of TODOs makes it difficult to
fully grasp the system.

  - **Add explanations of all concepts to increase the whitepaper’s readability.** For
example, what exactly does “virtual liquidity” mean?

  - **Add more diagrams.** As noted in some of the TODOs, numerous diagrams need to
be added. They will help readers visualize the algorithms used.

  - **Clearly state which sections are correct and which do not reflect the current**
**state of the code.** While the whitepaper is undergoing revisions, clearly identifying
outdated/work-in-progress sections would be highly beneficial to readers.

**●** **Add cross-tick and within-tick subsections for each level of state.** Section 1.2,
“Global state,” includes a subsection, 1.2.1, “Swapping within a tick.” Also, there is a
TODO for subsection 1.3.1, “Crossing a tick,” in section 1.3, “Per-tick state.” In
addition to these two levels of state, the whitepaper includes section 1.4,
“Per-position state.” Consider adding a subsection for both cross-tick and within-tick
swaps in each of these state-level sections, which would help readers fully
understand the ticks and how they affect each of the state levels.

**●** **Add examples of crossing a tick.** One of the trickiest parts of the system is what
happens when a tick is crossed. Consider adding extensive examples of crossing a
tick.

  - **Make the per-level sections subsections of a “state” section.** There are three
state levels, each with its own section (1.2, 1.3, and 1.4). Placing all of these under a
single section, 1.2, “State,” would improve the whitepaper’s structure.

**●** **Use a numbered list for setPosition steps.** Subsection 1.4.1, “setPosition,”
describes the execution steps for adding or removing liquidity in paragraph form.


© 2021 Trail of Bits Uniswap V3 Core Assessment | 46


Consider using a numbered list to call the readers’ attention to these sequential
steps.


© 2021 Trail of Bits Uniswap V3 Core Assessment | 47


### E. Token Integration Checklist

The following checklist provides recommendations for interactions with arbitrary tokens.
Every unchecked item should be justified, and its associated risks, understood. An
[up-to-date version of the checklist can be found in crytic/building-secure-contracts .](https://github.com/crytic/building-secure-contracts/blob/master/development-guidelines/token_integration.md)


[For convenience, all Slither utilities can be run directly on a token address, such as the](https://github.com/crytic/slither)
following:

```
slither-check-erc 0xdac17f958d2ee523a2206206994597c13d831ec7 TetherToken

```

To follow this checklist, use the below output from Slither for the token:

#### General Security Considerations

❏ **The contract has a security review.** Avoid interacting with contracts that lack a
security review. Check the length of the assessment (i.e., the level of effort), the
reputation of the security firm, and the number and severity of the findings.
❏ **You have contacted the developers.** You may need to alert their team to an
[incident. Look for appropriate contacts on blockchain-security-contacts .](https://github.com/crytic/blockchain-security-contacts)
❏ **They have a security mailing list for critical announcements.** Their team should
advise users (like you!) when critical issues are found or when upgrades occur.

#### ERC Conformity

Slither includes a utility, <u>`[slither-check-erc](https://github.com/crytic/slither/wiki/ERC-Conformance)`</u>, that reviews the conformance of a token to
many related ERC standards. Use slither-check-erc to review the following:


❏ **`Transfer`** **and** **`transferFrom`** **return a boolean.** Several tokens do not return a
boolean on these functions. As a result, their calls in the contract might fail.
❏ **`The name`** **,** **`decimals`** **, and** **`symbol`** **functions are present if used.** These functions
are optional in the ERC20 standard and may not be present.
❏ **`Decimals`** **returns a** **`uint8`** **.** Several tokens incorrectly return a `uint256` . In such


© 2021 Trail of Bits Uniswap V3 Core Assessment | 48


cases, ensure that the value returned is below 255.
❏ **[The token mitigates the known ERC20 race condition.](https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729)** The ERC20 standard has a
known ERC20 race condition that must be mitigated to prevent attackers from
stealing tokens.
❏ **The token is not an ERC777 token and has no external function call in** **`transfer`**
**and** **`transferFrom`** **.** External calls in the transfer functions can lead to reentrancies.

Slither includes a utility, <u>`[slither-prop](https://github.com/crytic/slither/wiki/Property-generation)`</u> <u>, that generates unit tests and security properties</u>
that can discover many common ERC flaws. Use slither-prop to review the following:


❏ **The contract passes all unit tests and security properties from** **`slither-prop`** **.**
[Run the generated unit tests and then check the properties with Echidna](https://github.com/crytic/echidna) and
<u>[Manticore.](https://manticore.readthedocs.io/en/latest/verifier.html)</u>

Finally, there are certain characteristics that are difficult to identify automatically. Conduct
a manual review of the following conditions:


❏ **`Transfer`** **and** **`transferFrom`** **should not take a fee.** Deflationary tokens can lead to
unexpected behavior.
❏ **Potential interest earned from the token is taken into account.** Some tokens
distribute interest to token holders. This interest may be trapped in the contract if
not taken into account.

#### Contract Composition

❏ **The contract avoids unnecessary complexity.** The token should be a simple
contract; a token with complex code requires a higher standard of review. Use
Slither’s <u>`[human-summary](https://github.com/crytic/slither/wiki/Printer-documentation#human-summary)`</u> printer to identify complex code.
❏ **The contract uses** **`SafeMath`** **.** Contracts that do not use `SafeMath` require a higher
standard of review. Inspect the contract by hand for `SafeMath` usage.
❏ **The contract has only a few non–token-related functions.** Non–token-related
functions increase the likelihood of an issue in the contract. Use Slither’s

#### Owner privileges

<mark>❏</mark> **The token is not upgradeable.** Upgradeable contracts may change their rules over
time. Use Slither’s <u>`[human-summary](https://github.com/crytic/slither/wiki/Printer-documentation#human-summary)`</u> printer to determine if the contract is
upgradeable.


© 2021 Trail of Bits Uniswap V3 Core Assessment | 49


❏ **The owner has limited minting capabilities.** Malicious or compromised owners
can abuse minting capabilities. Use Slither’s <u>`[human-summary](https://github.com/crytic/slither/wiki/Printer-documentation#human-summary)`</u> printer to review
minting capabilities, and consider manually reviewing the code.
❏ **The token is not pausable.** Malicious or compromised owners can trap contracts
relying on pausable tokens. Identify pausable code by hand.
❏ **The owner cannot blacklist the contract.** Malicious or compromised owners can
trap contracts relying on tokens with a blacklist. Identify blacklisting features by
hand.
❏ **The team behind the token is known and can be held responsible for abuse.**
Contracts with anonymous development teams or teams that reside in legal shelters
require a higher standard of review.

#### Token Scarcity

Reviews of token scarcity issues must be executed manually. Check for the following
conditions:


❏ **The supply is owned by more than a few users.** If a few users own most of the
tokens, they can influence operations based on the tokens’ repartition.
❏ **The total supply is sufficient.** Tokens with a low total supply can be easily
manipulated.
❏ **The tokens are located in more than a few exchanges.** If all the tokens are in one
exchange, a compromise of the exchange could compromise the contract relying on
the token.
❏ **Users understand the risks associated with a large amount of funds or flash**
**loans.** Contracts relying on the token balance must account for attackers with a
large amount of funds or attacks executed through flash loans.


© 2021 Trail of Bits Uniswap V3 Core Assessment | 50


### F. Detecting correct  lock  usage

The following contains a Slither script developed during the assessment. We recommend
that Uniswap review and integrate the script into its CI.

#### Detecting correct  lock  usage

`UniswapV3Pool.lock` has two purposes:

  - Preventing the functions from being called before `initialize`

  - Preventing reentrancy.

It is crucial for the functions in `UniswapV3Pool` to have this modifier. The following script
follows a whitelist approach, where every reachable function must

  - be protected with the `lock` modifier,

  - be whitelisted (including `initialize` and `swap` ), or

  - be a view function.

No issue was found with the script.


© 2021 Trail of Bits Uniswap V3 Core Assessment | 51


© 2021 Trail of Bits Uniswap V3 Core Assessment | 52


### G. Front-running initialize tests

Below are two tests that show the results of setting a correct vs. incorrect initial price in the
`initialize` function. These tests demonstrate that an attacker could abuse TOB-UNI-007
<u>to swap tokens at an unfair price.</u>


© 2021 Trail of Bits Uniswap V3 Core Assessment | 53


© 2021 Trail of Bits Uniswap V3 Core Assessment | 54


© 2021 Trail of Bits Uniswap V3 Core Assessment | 55


© 2021 Trail of Bits Uniswap V3 Core Assessment | 56


### H. Manual analysis of over�low of amountIn + feeAmount

The following describes our manual analysis of a potential overflow in
`UniswapV3Pool.swap` . The overflow is currently not reachable in the system’s parameter
limits. However, we recommend that Uniswap ensure that the overflow remains
unreachable if the parameters are changed.


<u>`SwapMath.computeSwapStep`</u> <u>returns the step’s</u> <u>`amountIn`</u> <u>and</u> <u>`feeAmount`</u> <u>(both a uint256):</u>

```
 (state.sqrtPriceX96, step.amountIn, step.amountOut, step.feeAmount) =
 SwapMath.computeSwapStep(
   state.sqrtPriceX96,
   (zeroForOne ? step.sqrtPriceNextX96 < sqrtPriceLimitX96 : step.sqrtPriceNextX96 >
 sqrtPriceLimitX96)
      ? sqrtPriceLimitX96
      : step.sqrtPriceNextX96,
   state.liquidity,
   state.amountSpecifiedRemaining,
   fee
 );
```

_<u>Figure I.1:</u>_ _`UniswapV3Pool.sol#L566-L574`_

The variables are added together, `amountIn + feeAmount`, without arithmetic overflow
protection:

```
 state.amountSpecifiedRemaining -= (step.amountIn + step.feeAmount).toInt256();
 [..]
 state.amountCalculated = state.amountCalculated.add((step.amountIn +
 step.feeAmount).toInt256());
```

_<u>Figure I.2:</u>_ _`UniswapV3Pool.sol#L577-L581`_

We’ll show that neither of the above calculations can overflow.


Both variables are computed in `SwapMath.computeSwapStep` . Let’s start with `feeAmount`,
computed here:

```
     if (exactIn && sqrtRatioNextX96 != sqrtRatioTargetX96) {
       // we didn't reach the target, so take the remainder of the maximum input as fee
       feeAmount = uint256 (amountRemaining) - amountIn;
     } else {
       feeAmount = FullMath.mulDivRoundingUp(amountIn, feePips, 1e6 - feePips);
     }
```

_<u>Figure I.3:</u>_ _`SwapMath.sol#L91-L96`_


© 2021 Trail of Bits Uniswap V3 Core Assessment | 57


Because the first case cannot overflow, `feeAmount = amountRemaining - amountIn` (and
no underflow happens), `feeAmount + amountIn = amountRemaining`, which by definition
fits into a uint256.


Let’s consider the second case of the “if” statement. The maximum value of `feePips` is
999,999:

```
                   require (fee < 1000000 );
```

_Figure I.4:_ _`UniswapV3Factory.sol#L63`_

As such, the maximum value of `feeAmount` is `amountIn * 999,999` .


Now `amountIn` is one of the following (with the X96 suffix removed for readability):
```
  1. SqrtPriceMath.getAmount0Delta(sqrtRatioA, sqrtRatioB, liquidity, true),
   or
  2. SqrtPriceMath.getAmount1Delta(sqrtRatioA, sqrtRatioB, liquidity, true).

```

Note that `liquidity` is a uint128; let’s assume its maximum value is 2^128 - 1. Let’s
consider these cases separately, as Case 1: getAmount0Delta and Case 2:
getAmount1Delta.

###### Case 1: getAmount0Delta

```
     return
       roundUp
         ? UnsafeMath.divRoundingUp(
            FullMath.mulDivRoundingUp(numerator1, numerator2, sqrtRatioBX96),
            sqrtRatioAX96
         )

```

_<u>Figure I.5: SqrtPriceMath</u>_ _`.sol#L164-L169`_


`getAmount0Delta` returns (rounding up in the division):


Call this expression `E` . We assume that

  - `sqrtRatioA` and `sqrtRatioB >= 1` (otherwise, the operation would revert).


© 2021 Trail of Bits Uniswap V3 Core Assessment | 58


So

  - `sqrtRatioB <= sqrtRatioB + 1 <= sqrtRatioA * (sqrtRatioB + 1)`

  - `sqrtRatioB - sqrtRatioA <= sqrtRatioA * sqrtRatioB`,

  - `(sqrtRatioB - sqrtRatioA) / (sqrtRatioB * sqrtRatioA) <= 1`,

which gives us


_E_ ≤ _liquidity_        - 2 <sup>96</sup> <sup>≤</sup> (2128 ­ 1)        - 2 <sup>96</sup> <sup><</sup> 2 <sup>128</sup>        - 2 <sup>96</sup> <sup>=</sup> 2 <sup>224</sup>,

resulting in


_amountIn_ + _feeAmount_ ≤ _E_ + 999, 999 _E_ = 1, 000, 000 _E_ < 1, 000, 000 - 2 <sup>224</sup> <sup><</sup> 2 <sup>20</sup> - 2 <sup>224</sup> <sup>=</sup> 2 <sup>244</sup> .

And so

_amountIn_ + _feeAmount_ < 2 <sup>244</sup> .

It follows that no overflow can happen in this case. Let’s move on to the second and final
case.

###### Case 2: getAmount1Delta

```
     return
       roundUp
         ? FullMath.mulDivRoundingUp(liquidity, sqrtRatioBX96 - sqrtRatioAX96,
 FixedPoint96.Q96)
```

_<u>Figure I.6: SqrtPriceMath</u>_ _`.sol#L188-L190`_

`getAmount1Delta` returns the following (rounding up in the division):









resulting in

_F_ < 2 <sup>192</sup> .


© 2021 Trail of Bits Uniswap V3 Core Assessment | 59


© 2021 Trail of Bits Uniswap V3 Core Assessment | 60


### I. Unit test for TOB-UNI-008

The following contains a unit test for TOB-UNI-008, meant to be run in
`UniswapV3Pool.spec.ts` .


© 2021 Trail of Bits Uniswap V3 Core Assessment | 61


© 2021 Trail of Bits Uniswap V3 Core Assessment | 62


