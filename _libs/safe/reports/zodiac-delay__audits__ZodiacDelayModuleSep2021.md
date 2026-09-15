# **Security Review of**
## Zodiac Delay Module
#### September 2021


### **Zodiac Delay Module / September 2021**

###### **Files in scope**

<u>[https://github.com/gnosis/zodiac-modifier-](https://github.com/gnosis/zodiac-modifier-delay/blob/bde282125ebbe119df4bfd6374e097007a13fb8a/contracts/Delay.sol)</u>
<u>[delay/blob/bde282125ebbe119df4bfd6374e097007a13fb8a/contracts/Delay.sol](https://github.com/gnosis/zodiac-modifier-delay/blob/bde282125ebbe119df4bfd6374e097007a13fb8a/contracts/Delay.sol)</u>

###### **Current status**


All issues have been fixed by the developer. There are no known issues in
<u>[https://github.com/gnosis/zodiac-modifier-](https://github.com/gnosis/zodiac-modifier-delay/blob/808dfda6fd0ea144bbbe83e419e14045a029ca5d/contracts/Delay.sol)</u>
<u>[delay/blob/808dfda6fd0ea144bbbe83e419e14045a029ca5d/contracts/Delay.sol](https://github.com/gnosis/zodiac-modifier-delay/blob/808dfda6fd0ea144bbbe83e419e14045a029ca5d/contracts/Delay.sol)</u>


1 G0 GROUP // Zodiac Delay Module / September 2021


##### **Issues**

###### **1. Reentrancy attack allows one transaction to be** **executed multiple times**

**type: security / severity: critical**


In <mark>executeNextTx</mark> <mark>txNonce</mark> is incremented after <mark>exec</mark> is called, this allows a reentrant subcall of
<mark>exec</mark> to call <mark>executeNextTx</mark> again with the same arguments and execute the same transaction
again.


**status - fixed**


Issue has been fixed and is no longer present in


<u>[https://github.com/gnosis/zodiac-modifier-](https://github.com/gnosis/zodiac-modifier-delay/blob/808dfda6fd0ea144bbbe83e419e14045a029ca5d/contracts/Delay.sol)</u>
<u>[delay/blob/808dfda6fd0ea144bbbe83e419e14045a029ca5d/contracts/Delay.sol](https://github.com/gnosis/zodiac-modifier-delay/blob/808dfda6fd0ea144bbbe83e419e14045a029ca5d/contracts/Delay.sol)</u>

###### **2. In skipExpired, txNonce can be incremented to be higher** **than queueNonce**


**type: security / severity: major**


Since the while loop in <mark>skipExpired</mark> keeps iterating until <mark>txNonce <= queueNonce</mark> and every
iteration will increase <mark>txNonce</mark> by none, the last iteration will result in <mark>txNonce > queueNonce</mark> <mark>,</mark> this
will lead to next qued transaction being skipped.


**status - fixed**


Issue has been fixed and is no longer present in


<u>[https://github.com/gnosis/zodiac-modifier-](https://github.com/gnosis/zodiac-modifier-delay/blob/808dfda6fd0ea144bbbe83e419e14045a029ca5d/contracts/Delay.sol)</u>
<u>[delay/blob/808dfda6fd0ea144bbbe83e419e14045a029ca5d/contracts/Delay.sol](https://github.com/gnosis/zodiac-modifier-delay/blob/808dfda6fd0ea144bbbe83e419e14045a029ca5d/contracts/Delay.sol)</u>

###### **3. Deactivation of transaction expiration is not respected** **in executeNextTx**


**type: incorrect implementation / severity: major**


In <mark>executeNextTx</mark> require on <mark>line 150</mark> doesn’t reflect that <mark>txExpiration == 0</mark> is a special state
that should lead to the skipping of expiration check.


**status - fixed**


Issue has been fixed and is no longer present in


<u>[https://github.com/gnosis/zodiac-modifier-](https://github.com/gnosis/zodiac-modifier-delay/blob/808dfda6fd0ea144bbbe83e419e14045a029ca5d/contracts/Delay.sol)</u>
<u>[delay/blob/808dfda6fd0ea144bbbe83e419e14045a029ca5d/contracts/Delay.sol](https://github.com/gnosis/zodiac-modifier-delay/blob/808dfda6fd0ea144bbbe83e419e14045a029ca5d/contracts/Delay.sol)</u>


2 G0 GROUP // Zodiac Delay Module / September 2021


###### **4. Inconsistently defined expiration periods between** **functions**

**type: inconsistency / severity: minor**


Executable period defined in <mark>executeNextTx</mark> and expired period defined in <mark>skipExpired</mark> are not
continuous.


**status - fixed**


Issue has been fixed and is no longer present in


<u>[https://github.com/gnosis/zodiac-modifier-](https://github.com/gnosis/zodiac-modifier-delay/blob/808dfda6fd0ea144bbbe83e419e14045a029ca5d/contracts/Delay.sol)</u>
<u>[delay/blob/808dfda6fd0ea144bbbe83e419e14045a029ca5d/contracts/Delay.sol](https://github.com/gnosis/zodiac-modifier-delay/blob/808dfda6fd0ea144bbbe83e419e14045a029ca5d/contracts/Delay.sol)</u>


3 G0 GROUP // Zodiac Delay Module / September 2021


##### **Note**

It should be kept in mind that if all DAO calls are routed through the Delay module, including calls to
the Delay module itself, there’s a threat of a broken transaction blocking calls that would normally
be used to skip it. This is especially problematic if transactions have no expiration.


4 G0 GROUP // Zodiac Delay Module / September 2021


