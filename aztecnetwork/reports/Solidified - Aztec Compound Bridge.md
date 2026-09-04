Audit Report for Aztec - June 17, 2022

## Summary


Audit Report prepared by Solidified covering the Aztec protocol Ethereum Bridge contract for
Compound Bridge.


The following report covers the **Compound Bridge** .

## Process and Delivery


Three (3) independent Solidified experts performed an unbiased and isolated audit of the code.
The debrief on 17 June 2022.

## Audited Files


The source code has been supplied in the form of one public Github repository.


<u>[https://github.com/aztecProtocol/aztec-connect-bridges/](https://github.com/aztecProtocol/aztec-connect-bridges/)</u>


Commit Hash: <mark>`ad5d8d5fa83ae0e1c519e1bdb79adb4caa5aa8c1`</mark>

```
src
|-- bridges
| -- compound
    |-- CompoundBridge.sol
    |-- interfaces

## Intended Behavior

```

Smart contract responsible for depositing, managing and redeeming Defi interactions with the
Compound protocol.


Audit Report for Aztec - June 17, 2022

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


Code complexity Low 

Code readability and clarity High 

Level of Documentation Medium 

Test Coverage High 

Audit Report for Aztec - June 17, 2022

## **Issues Found**


Issue # Description Severity Status



1 The safeIncreaseAllowance() might revert if the
current allowance is not 0


2 Only allow valid cToken contracts from
Compound



Minor Pending



Note/Pre
caution






Audit Report for Aztec - June 17, 2022

# **Critical Issues**


No issues found

# **Major Issues**


No issues found

# **Minor Issues**

## **1. The safeIncreaseAllowance() might revert if the current** **allowance is not 0**


For example Tether’s <mark>`ERC-20`</mark> implementation does not allow modifying the existing allowance if
the existing allowance is not equal to `0` . If allowance is not `0`, it first needs to be set to `0` and
then it can be set to another value.
The <mark>`SafeERC20.safeIncreaseAllowance()`</mark> does not handle such a case, although the
comments in code seem to assume otherwise.


See discussion at
<mark>`[https://github.com/OpenZeppelin/openzeppelin-contracts/pull/3046](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/3046)`</mark> <mark>f</mark> or more
details.


Currently, the RollupProcessor/cToken always takes the entire amount, however the <mark>`approve`</mark>
would revert if that changes.


**Recommendation**
In order for the bridge to be compatible with underlying tokens which do not fully comply with the
<mark>`ERC-20`</mark> specification, consider setting allowance to `0` before setting it to another value (it could
be implemented for all <mark>`ERC-20`</mark> tokens or for a manageable specific list of tokens).


Audit Report for Aztec - June 17, 2022

## **Informational Notes/Precaution** **2. Only allow valid cToken contracts from Compound**


Currently, the bridge doesn’t verify if a passed cToken address is actually a valid cToken
contract from Compound.


A potential malicious contract could steal funds, etc.


The <mark>`Comptroller`</mark> could be called to verify if the cToken is a valid market.

```
Comptroller.markets(address cToken) public returns(bool)

## **Disclaimer**

```

Solidified audit is not a security warranty, investment advice, or an endorsement of


Aztec Protocol or its products. This audit does not provide a security or correctness


guarantee of the audited smart contract. Securing smart contracts is a multistep


process, therefore running a bug bounty program as a complement to this audit is


strongly recommended.


The individual audit reports are anonymized and combined during a debrief process, in


order to provide an unbiased delivery and protect the auditors from legal and financial


liability.


_Oak Security GmbH_


