### | security

# **OpenZeppelin** **Checkpoints** **Library Audit**

#### **November 15th, 2022**

This security assessment was prepared by
OpenZeppelin.


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope  ____________________________________________________________________________  4


Introduction  _______________________________________________________________________  5


Findings __________________________________________________________________________  5


Low Severity ______________________________________________________________________  6

L-01 Gas inefficiency 6

L-02 Unused private function 6


Notes & Additional Information ______________________________________________________  7

N-01 Inconsistent formatting 7

N-02 Incorrect require statement 7

N-03 Missing docstrings 7

N-04 Mixed nomenclature 8


Conclusions  _______________________________________________________________________  9


OpenZeppelin Checkpoints Library Audit − Table of Contents − 2


## **Summary**

Type Library


Timeline From 2022-10-17

To 2022-10-28


Languages Solidity



Critical Severity
Issues


High Severity
Issues


Medium Severity
Issues



0 (0 resolved)


0 (0 resolved)


0 (0 resolved)



Total Issues 6 (3 resolved)



Low Severity Issues 2 (1 resolved)



Notes & Additional
Information



4 (2 resolved)



OpenZeppelin Checkpoints Library Audit − Summary − 3


## **Scope**

We audited the `OpenZeppelin/openzeppelin-contracts` repository at the

`14f98dbb581a5365ce3f0c50bd850e499c554f72` commit.


In scope were the following contracts:

```
contracts
└── utils
├── math
│  ├── SafeCast.sol
│  └── Math.sol
└── Checkpoints.sol

```

OpenZeppelin Checkpoints Library Audit − Scope − 4


## **Introduction**

The scope for this audit is the `Checkpoints` library. The `Checkpoints` library is designed

to allow developers to chronologically track specific events happening within their application.

This is achieved through the use of a `History` or `Trace` struct which themselves are

composed of checkpoints. A checkpoint is a struct containing the `block.number` for when

the checkpoint is created, along with a specified `value` .


The library has several functions repeated that are meant to deal with different versions of the

struct used. The struct versions differ in their data type sizes, allowing developers to choose

the one that best fits their custom codebase.


[The commit used for the audit is 14f98db](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/14f98dbb581a5365ce3f0c50bd850e499c554f72) and the code has been audited during the course of

five (5) days by two (2) auditors.

## **Findings**


Here we present our findings.


OpenZeppelin Checkpoints Library Audit − Introduction − 5


## **Low Severity**

### **L-01 Gas inefficiency**

[The getAtProbablyRecentBlock](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/14f98dbb581a5365ce3f0c50bd850e499c554f72/contracts/utils/Checkpoints.sol#L48) function is intended to provide an optimized search for recent

checkpoints where recent is defined as the checkpoint being among the last `sqrt(n)`

checkpoints.


However, in an internal test conducted by our team, the optimization was tested to create

slightly more expensive lookups for smaller arrays such as those of size `5`, `8`, `16`, and `25` .

[Because of this, consider increasing the minimum length check](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/14f98dbb581a5365ce3f0c50bd850e499c554f72/contracts/utils/Checkpoints.sol#L57) to a larger size to ensure

optimization is actually achieved.


Update: _Acknowledged, resolved. After discussions with OpenZeppelin's Libraries & Tooling_

_team, both of our teams came up with specific tests giving contrastring results. Given the_

_subjectivity of those and the little improvement in gas consumption that might derive from it, we_

_leave the issue as it is for the reader to have knowledge of it._

### **L-02 Unused private function**


<u>This specific</u> <u>`[_lowerBinaryLookup](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/14f98dbb581a5365ce3f0c50bd850e499c554f72/contracts/utils/Checkpoints.sol#L191)`</u> function is marked as private but is not used by any

other function.


Given the different repetitions of the same functions, in order to improve readability, clarity and

code size, consider removing the unused function.


Update: _Acknowledged, not resolved. The OpenZeppelin stated:_


_This will be tackled in a later PR._


OpenZeppelin Checkpoints Library Audit − Low Severity − 6


## **Notes & Additional** **Information**

### **N-01 Inconsistent formatting**

The <u>`[_unsafeAccess](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/14f98dbb581a5365ce3f0c50bd850e499c554f72/contracts/utils/Checkpoints.sol#L369)`</u> functions are formatted in a different way across definitions. Consider

reviewing the entire codebase and unifying the way code lines are formatted.


This will improve readability and overall quality of the codebase.


Update: _Acknowledged, not resolved. The OpenZeppelin team stated:_


This is due to the use of automatic formatting and some of the definitions going over

the line length limit. We believe there is an upcoming version of prettier-solidity that may

result in a more consistent output.

### **N-02 Incorrect require statement**


Within all <u>`[_insert](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/14f98dbb581a5365ce3f0c50bd850e499c554f72/contracts/utils/Checkpoints.sol#L296)`</u> [functions, there is](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/14f98dbb581a5365ce3f0c50bd850e499c554f72/contracts/utils/Checkpoints.sol#L307) a comment stating that all keys must be increasing.

However, the require statement only requires that a key be _non-decreasing_ .


In order to improve correctness and clarity, consider aligning the comment and the require

statement. Also, consider reflecting this _non-decreasing_ requirement in the require statement

error message.


Update: _[Resolved in commit 0943b4d.](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/0943b4dd5498ea3d3f7b7598bc59a3dde6be2cbd)_

### **N-03 Missing docstrings**


In the codebase there are some places that might benefit from improved docstrings. Some

examples are:







The private <u>`[_unsafeAccess](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/14f98dbb581a5365ce3f0c50bd850e499c554f72/contracts/utils/Checkpoints.sol#L208)`</u> functions are using inline assembly and have no

docstrings at all. While it is not common practice to include docstrings in private

functions, functions using inline assembly warrant additional documentation.


OpenZeppelin Checkpoints Library Audit − Notes & Additional Information −

7


The <u>`[getAtBlock](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/14f98dbb581a5365ce3f0c50bd850e499c554f72/contracts/utils/Checkpoints.sol#L33)`</u> <u>function</u> is designed to disallow querying a checkpoint pushed within

the same block as `block.number` . While there might be several reasons for that, it's

not clear why the library limits this.



Consider improving the docstrings in the examples mentioned to improve readability and

understandability as well as to improve the developer experience when making use of this

library.


Updated: _[Resolved in commits 6b5de2c](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/6b5de2c6f0010eccf0a3e3467c91a7024219fcce)_ _[and 1ee1154.](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/1ee1154a1afac3151fe7d35fba30d26f74cd3eb1)_

### **N-04 Mixed nomenclature**


The structs <u>`[Checkpoint160](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/14f98dbb581a5365ce3f0c50bd850e499c554f72/contracts/utils/Checkpoints.sol#L384)`</u> and <u>`[Checkpoint224](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/14f98dbb581a5365ce3f0c50bd850e499c554f72/contracts/utils/Checkpoints.sol#L220)`</u> both have their initial named value as

`_key` . The near identical <u>`[Checkpoint](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/14f98dbb581a5365ce3f0c50bd850e499c554f72/contracts/utils/Checkpoints.sol#L24)`</u> struct has its initial named value as `_blockNumber` .

Functions that interact with these initial values all have named parameters using the `key`

nomenclature.


We understand that part of the reason of the current codebase state is because of backward

compatibility with previous versions. However, consider using `blockNumber` for parameter

names for functions that interact with `Checkpoint` like the <u>`[_insert](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/14f98dbb581a5365ce3f0c50bd850e499c554f72/contracts/utils/Checkpoints.sol#L135)`</u> function. Moreover,

consider whether it is also worth changing the <u>`[_lowerBinaryLookup](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/14f98dbb581a5365ce3f0c50bd850e499c554f72/contracts/utils/Checkpoints.sol#L191)`</u> and

<u>`[_upperBinaryLookup](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/14f98dbb581a5365ce3f0c50bd850e499c554f72/contracts/utils/Checkpoints.sol#L168)`</u> functions to have `blockNumber` instead of `key` as input

parameter.


Update: _Acknowledged, not resolved. The OpenZeppelin team stated:_


_It will be addressed in a future PR along with the unused private function issue._


OpenZeppelin Checkpoints Library Audit − Notes & Additional Information −

8


## **Conclusions**

No high or critical severity issues have been identified. Minor recommendations have been

made to improve documentation and readability within the codebase.


OpenZeppelin Checkpoints Library Audit − Conclusions − 9


