Audit Report for Aztec - November 2022

## Summary


Audit Report prepared by Solidified covering the Aztec protocol Ethereum Bridge contract for
Liquity Trove Bridge.


The following report covers the **Liquity Trove Bridge** .


This audit is a re-audit of the first Liquity bridge audit. The Aztec team changed the behavior of
the bridge in the repayment case.

## Process and Delivery


Independent Solidified experts performed an unbiased and isolated audit of the code. The
debrief on 21 November 2022.

## Audited Files


The source code has been supplied in the form of one public Github repository.


<u>[https://github.com/aztecProtocol/aztec-connect-bridges/](https://github.com/aztecProtocol/aztec-connect-bridges/)</u>


Commit Hash: <mark>`46af4186f21cd1925d41fd0275883be18755d212`</mark>

```
src
|-- bridges
| -- liquity
    |-- TroveBridge.sol

## Intended Behavior

```

Aztec Connect Bridge for interacting with Liquity's troves.


Audit Report for Aztec - November 2022

## **Code Complexity and Test Coverage**

Smart contract audits are an important step to improve the security of smart contracts
and can find many issues. However, auditing complex codebases has its limits and a
remaining risk is present (see disclaimer).


Users of a smart contract system should exercise caution. In order to help with the
evaluation of the remaining risk, we provide a measure of the following key indicators:
**code complexity**, **code readability**, **level of documentation**, and **test coverage** .


**Note, that high complexity or lower test coverage does equate to a higher risk.**
**Certain bugs are more easily detected in unit testing than in a security audit and**
**vice versa. It is, therefore, more likely that undetected issues remain if the test**
**coverage is low or non-existent.**


Criteria Status Comment


Code complexity Medium 

Code readability and clarity High 

Level of Documentation High 

Test Coverage High 

Audit Report for Aztec - November 2022

## **Issues Found**


Issue # Description Severity Status



1. Deposit ETH Attack can revert every repayment
bridge call with an underflow



Critical Resolved



2. Information Notes Notes Resolved


Audit Report for Aztec - November 2022

# **Critical Issues** **1. Deposit ETH Attack can revert every repayment bridge call** **with an underflow**


In case a Trove <mark>`Redistribution`</mark> happened an attacker could send ETH to the bridge contract
to perform an attack which would cause the bridge transaction to revert with an math-underflow.


This would result in a revert of all repay interactions.
(As a result locked ETH in the Trove would be lost)


Each Trove has a <mark>`debt`</mark> and a <mark>`coll`</mark> value.


In a Trove redistribution event <mark>`debt`</mark> and <mark>`coll`</mark> are both increased. Let say the collateral <mark>`coll`</mark> is
increased by an amount `c'` .


The actual value of `c'` depends on the liquidated Trove size. However the bridge Trove could
just be partially affected and the actual value of `c'` could be a tiny ETH amount worth a few
dollars.


An attacker could just send the following ETH amount to the <mark>`TroveBridge`</mark> contract after the
<mark>`redistribution`</mark> <mark>:</mark>

```
attackAmount = c' + 1

```

All repay transactions would revert. For a smaller attackAmount it would depend on the bridge
<mark>`_totalInputValue`</mark> value if it is enough for an underflow.


The problem lies in the usage of ETH balance in <mark>`_repayWithCollateral`</mark> method:

```
collateralReturned = address(this).balance;

```

This happens after the Uniswap repayment so the actual ETH balance would be:

```
// correct collateralReturned + attack Amount
address(this).balance = collateralReturned + attackAmount

```

Audit Report for Aztec - November 2022


Even if we assume the entire trove collateral has been withdrawn from the Trove, the actual
collateral sold to Uniswap will be just `c'` at maximum. (Actually a bit less because of the 110%
over-collateralization)

```
collToWithdraw = coll + c'

```

Therefore, we can define the actual collateral returned as

```
collateralReturned=collToWithdraw-c'

// actual ETH balance of the contract
// = collateralReturned + attackAmount
// = collToWithdraw-c' + attackAmount
// = collToWithdraw-c' + c' + 1
// = collToWithdraw + 1
collateralReturned = address(this).balance;
...

```

**Subtraction Underflow Revert**

```
// = subtraction underflow
// = collToWithdraw - (collToWithdraw + 1);
uint256 collateralSold = collToWithdraw - collateralReturned;

```

If the entire collateral is not removed from the Trove the underflow would be higher than 1 Wei.


**Recommendation** :
Store the <mark>`address(this).balance`</mark> in a local variable before the Uniswap interaction and
calculate the delta between balance afterwards. This delta amount should be used for
<mark>`collateralReturned`</mark> calculation.


**Resolved** :
In the following commit <mark>`89129e99529b0095310d52396a68edf251043a9b`</mark>


Audit Report for Aztec - November 2022

# **Major Issues**


No issues found

# **Minor Issues**


No issues found

## **2. Informational Notes**


**Variable Naming Improvement suggestions**


In order to increase the code clarity consider renaming <mark>`collateralSold`</mark> to
<mark>`collateralSoldToUniswap`</mark> <mark>,</mark> and <mark>`maxCost`</mark> to <mark>`maxCostInETH`</mark> <mark>.</mark>


**Check for inputAssetB == None**
In the <mark>`convert`</mark> function a check fo <mark>r</mark> <mark>`inputAssetB ==`</mark> <mark>`None`</mark> <mark>c</mark> ould be added to ensure correct
usage.

```
 else if (
       _inputAssetA.erc20Address == address(this) &&
_outputAssetA.assetType == AztecTypes.AztecAssetType.ETH
    )

```

Audit Report for Aztec - November 2022

## **Disclaimer**


Solidified audit is not a security warranty, investment advice, or an endorsement of


Aztec Protocol or its products. This audit does not provide a security or correctness


guarantee of the audited smart contract. Securing smart contracts is a multistep


process, therefore running a bug bounty program as a complement to this audit is


strongly recommended.


The individual audit reports are anonymized and combined during a debrief process, in


order to provide an unbiased delivery and protect the auditors from legal and financial


liability.


_Oak Security GmbH_


