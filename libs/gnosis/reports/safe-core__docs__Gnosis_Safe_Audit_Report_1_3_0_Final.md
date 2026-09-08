# **Security Review of**
## Gnosis Safe 1.3.0
#### May 2021


### **Gnosis Safe 1.3.0 / May 2021**

###### **Files in scope**

All solidity files in:


<u>[https://github.com/gnosis/safe-contracts/tree/ad6c7355d5bdf4f7fa348fbfcb9f07431769a3c9](https://github.com/gnosis/safe-contracts/tree/ad6c7355d5bdf4f7fa348fbfcb9f07431769a3c9)</u>

###### **Current status**


No serious issues have been discovered.


1 G0 GROUP // Gnosis Safe 1.3.0 / May 2021


##### **Report**

###### **Issues**

No issues have been discovered.

###### **Notes**


1. In <mark>ReentrencyTransactionGuard.sol</mark> it might be useful to track the active status for each caller
separately so that the same guard contract can be used for multiple wallets in the same transaction.


2 G0 GROUP // Gnosis Safe 1.3.0 / May 2021


