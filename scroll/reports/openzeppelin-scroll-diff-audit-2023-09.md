### | security

# **Scroll Diff Audit** **Report**

#### **September 21, 2023**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  5


Low Severity ______________________________________________________________________  6

L-01 Insufficient Tests When Using BitMaps 6

L-02 Implicit Limitation of Withdrawal 6


Notes & Additional Information ______________________________________________________  7

N-01 Misleading Documentation 7


Conclusion  ________________________________________________________________________  8


Scroll Diff Audit Report − Table of Contents − 2


## **Summary**

Type Layer 2


Timeline From 2023-09-13
To 2023-09-15


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



Total Issues 3 (3 resolved)



Low Severity Issues 2 (2 resolved)



Notes & Additional
Information



1 (1 resolved)



Scroll Diff Audit Report − Summary − 3


## **Scope**

We performed a diff audit of the `scroll-tech/scroll` repository for <u>[pull request 887](https://github.com/scroll-tech/scroll/pull/887)</u> at

commit <u>`[02bce20](https://github.com/scroll-tech/scroll/pull/887/commits/02bce207cd5bb511106943e13d4d64b47d4dea13)`</u>, <u>[pull request 912](https://github.com/scroll-tech/scroll/pull/912)</u> at commit <u>`[10743c2](https://github.com/scroll-tech/scroll/pull/912/commits/10743c26b888d62ba3b2faa9eaa8522488235bb4)`</u>, <u>[pull request 893](https://github.com/scroll-tech/scroll/pull/893)</u> at commit

<u>`[f8b9da0](https://github.com/scroll-tech/scroll/pull/893/commits/f8b9da0fbabd9915b869f274aabc4d5dc0c28fa6)`</u>, and <u>[pull request 943](https://github.com/scroll-tech/scroll/pull/943)</u> at commit <u>`[3d9bfb5](https://github.com/scroll-tech/scroll/pull/943/commits/3d9bfb5c2bd4b1ea2340a7a2469d7b8ca336bd8d)`</u> .


In scope were the following contracts:

```
contracts
└── src
├── L1/rollup
│  ├── IL1MessageQueue.sol
│  ├── L1MessageQueue.sol
│  └── ScrollChain.sol
├── L2/predeploys
│  └── L2TxFeeVaults.sol
└── libraries
└── FeeVault.sol

```

Scroll Diff Audit Report − Scope − 4


## **System Overview**

Scroll is an EVM-equivalent ZK-rollup designed to be a scaling solution for Ethereum. It

achieves this by interpreting EVM bytecode directly at the bytecode level, following a similar

path to projects like Polygon's zkEVM and Consensys' Linea.


This audit reviewed the addition of four different pull requests to the Scroll ZK-rollup protocol.


This report presents our findings and recommendations for the new additions to the Scroll ZK
rollup protocol. We urge the Scroll team to consider these findings in their ongoing efforts to

provide a secure and efficient Layer 2 solution for Ethereum.


Scroll Diff Audit Report − System Overview − 5


## **Low Severity**

### **L-01 Insufficient Tests When Using BitMaps**

<u>[Pull request 893](https://github.com/scroll-tech/scroll/pull/893/commits/ebe2b1519654767a762f0e3ade8a8663e57fc25f#diff-229854e4c18fbdae29d0e9ce11b88b080363f508f3fe6381dab5f3ab19dc3d78)</u> changes the way of popping and tracking skipped messages, using BitMaps

and buckets instead. This represents a sensitive change compared to the previous version.

However, only <u>[a single test case](https://github.com/scroll-tech/scroll/pull/893/commits/ebe2b1519654767a762f0e3ade8a8663e57fc25f#diff-229854e4c18fbdae29d0e9ce11b88b080363f508f3fe6381dab5f3ab19dc3d78R306)</u> with a fixed random BitMap, count, and starting index was

introduced.


In order to verify that the expected behavior of filling the buckets and skipping messages is the

expected one from the rest of the code, consider adding more test cases, especially testing

edge cases for filling buckets.


**_Update:_** _Resolved in_ _<u>[pull request 956 at commit](https://github.com/scroll-tech/scroll/pull/956/commits/6749eb7325caf53149a15889d3512401970c4f67)</u>_ _<u>`[6749eb7](https://github.com/scroll-tech/scroll/pull/956/commits/6749eb7325caf53149a15889d3512401970c4f67)`</u>_ _._

### **L-02 Implicit Limitation of Withdrawal**


On <u>[pull request 912, the](https://github.com/scroll-tech/scroll/pull/912/commits/03f3a0e7a068e0327ff6533bd07c654d0acd6714)</u> `FeeVault` contract introduced the possibility to <u>[pass a parameter](https://github.com/scroll-tech/scroll/pull/912/commits/03f3a0e7a068e0327ff6533bd07c654d0acd6714#diff-59b7fd0ed38ccb8a8dc9d3f3a2929a4532f2868a89b7839e3d09a4e267c9c5b3R107)</u> of

the value to withdraw. However, this value is implicitly limited to the contract's current balance

by the <u>`[sendMessage](https://github.com/scroll-tech/scroll/pull/912/commits/03f3a0e7a068e0327ff6533bd07c654d0acd6714#diff-59b7fd0ed38ccb8a8dc9d3f3a2929a4532f2868a89b7839e3d09a4e267c9c5b3R120)`</u> <u>function call.</u>


In order to fail early and return a clear error message (which would help when debugging a

reverted transaction), consider adding a requirement that asserts that the value passed is equal

to or less than the contract's balance.


**_Update:_** _Resolved in_ _<u>[pull request 954 at commit](https://github.com/scroll-tech/scroll/pull/954/commits/08b8bc93228e64453916b9bbc46e85c21de0a477)</u>_ _<u>`[08b8bc9](https://github.com/scroll-tech/scroll/pull/954/commits/08b8bc93228e64453916b9bbc46e85c21de0a477)`</u>_ _._


Scroll Diff Audit Report − Low Severity − 6


## **Notes & Additional** **Information**

### **N-01 Misleading Documentation**

Throughout the codebase, there are some instances of incorrect or misleading documentation.

In particular:


   - <u>[Pull request 943](https://github.com/scroll-tech/scroll/pull/943/commits/3d9bfb5c2bd4b1ea2340a7a2469d7b8ca336bd8d)</u> refactored the functionality of the `FeeVault` contract under the

`L2TxFeeVault` contract. However, the NatSpec was copied from the `FeeVault`

contract, stating: "The L2TxFeeVault contract contains the basic logic for the various

different vault contracts used to hold fee revenue generated by the L2 system". Unless

the `L2TxFeeVault` contract is going to be used as a base contract for other future

contracts, consider adjusting the documentation to reflect the current behavior.

   - The <u>[comment in line 67](https://github.com/scroll-tech/scroll/blob/f8b9da0fbabd9915b869f274aabc4d5dc0c28fa6/contracts/src/L1/rollup/L1MessageQueue.sol#L67)</u> of `L1MessageQueue.sol` should say "for dropped messages"

instead of "skipped messages".


Consider resolving these instances of incorrect documentation to improve the clarity and

readability of the codebase.


**_Update:_** _Resolved in_ _<u>[pull request 955 at commit](https://github.com/scroll-tech/scroll/pull/955/commits/e1a3f95325d672558a5b50fc49dcf34c3593b4ec)</u>_ _<u>`[e1a3f95](https://github.com/scroll-tech/scroll/pull/955/commits/e1a3f95325d672558a5b50fc49dcf34c3593b4ec)`</u>_ _._


Scroll Diff Audit Report − Notes & Additional Information − 7


## **Conclusion**

Throughout this 3-day audit, we reviewed the mentioned pull requests and identified two low
severity issues, as well as one note to improve the documentation of the codebase.


Scroll Diff Audit Report − Conclusion − 8


