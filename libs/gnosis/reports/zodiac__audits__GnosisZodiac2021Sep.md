# **Security Review of**
## Zodiac
#### September 2021


### **Zodiac / September 2021**

###### **Files in scope**

All contract files in
<u>[https://github.com/gnosis/zodiac/tree/67a0956e2bce11b5945cc79f1aff4ee3a0a4ea2a/contracts](https://github.com/gnosis/zodiac/tree/67a0956e2bce11b5945cc79f1aff4ee3a0a4ea2a/contracts)</u>

###### **Current status**


All issues have been fixed by the developer. There are no known issues in
<u>[https://github.com/gnosis/zodiac/tree/c7aea1be89447584d7fb38911c9a8410d8b64acd/contracts](https://github.com/gnosis/zodiac/tree/c7aea1be89447584d7fb38911c9a8410d8b64acd/contracts)</u>


1 G0 GROUP // Zodiac / September 2021


##### **Issues**

###### **1. FactoryFriendly.initialized is redundant**

**type: optimization / severity: minor**


<mark>FactoryFriendly.initialized</mark> is redundant since the functionality is already implemented in the
OZ Initializable contract.


**status - fixed**


Issue has been fixed and is no longer present in


<u>[https://github.com/gnosis/zodiac/tree/c7aea1be89447584d7fb38911c9a8410d8b64acd/contracts](https://github.com/gnosis/zodiac/tree/c7aea1be89447584d7fb38911c9a8410d8b64acd/contracts)</u>

###### **2. Proxy deployment bytcode in** **ModuleProxyFactory.createProxy can be optimized**


**type: optimization / severity: minor**


In the deployment part of the bytecode <mark>DUP2</mark> opcode is used to put a 0 on stack instead of a cheaper
<mark>RETURNDATASIZE</mark> opcode, when <mark>DUP2</mark> is replaced by <mark>RETURNDATASIZE</mark> <mark>,</mark> it also allows the very first
<mark>RETURNDATASIZE</mark> opcode to be removed.


**status - fixed**


Issue has been fixed and is no longer present in


<u>[https://github.com/gnosis/zodiac/tree/c7aea1be89447584d7fb38911c9a8410d8b64acd/contracts](https://github.com/gnosis/zodiac/tree/c7aea1be89447584d7fb38911c9a8410d8b64acd/contracts)</u>


2 G0 GROUP // Zodiac / September 2021


