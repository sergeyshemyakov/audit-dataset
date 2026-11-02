# **Security Review of**
## Gnosis Safe 1.3.0
#### April 2021


### **Gnosis Safe 1.3.0 / April 2021**

###### **Files in scope**

All solidity files in:


<u>[https://github.com/gnosis/safe-contracts/tree/4bfc0c8519f1893015d7edfd2c2780fca163c364](https://github.com/gnosis/safe-contracts/tree/4bfc0c8519f1893015d7edfd2c2780fca163c364)</u>

###### **Current status**


No serious issues have been discovered.


1 G0 GROUP // Gnosis Safe 1.3.0 / April 2021


##### **Report**

###### **Issues**

No issues have been discovered.

###### **Notes**


1. <mark>GnosisSafe.signMessage</mark> could be optimized by providing a hash instead of data
2. <mark>GnosisSafeProxyFactory.calculateCreateProxyWithNonceAddress</mark> has unused return value
3. In <mark>SecuredTokenTransfer</mark> the boolean return value of the call could be directly written to scratch space
by the call function instead of using returndatacopy to retrieve it
4. Some contracts implement a check that detects whether a code is being delegatecalled, there’s a possible
cheaper alternative to the current implementation based on storing the contract’s address in an immutable in the
contract’s constructor and then comparing it with <mark>address(this)</mark> when the call is being called
5. Uniqueness check on the <mark>_owners</mark> array in <mark>OwnerManager.setupOwners</mark> could be implemented in a
cheaper way if the array of owners was required to be sorted. Checking that <mark>currentOwner < owner</mark> in the
for loop would ensure there are no duplicates.


[Suggestions in notes 3. and 4. have been implemented in:https://github.com/gnosis/safe-](https://github.com/gnosis/safe-contracts/commit/9b305a0f80da7f1107d1181f52c844f089557d05)
<u>[contracts/commit/9b305a0f80da7f1107d1181f52c844f089557d05](https://github.com/gnosis/safe-contracts/commit/9b305a0f80da7f1107d1181f52c844f089557d05)</u>


2 G0 GROUP // Gnosis Safe 1.3.0 / April 2021


