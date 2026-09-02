# **Tornado pool audit**

**1 August 2021, Igor Gulamov**
## **Introduction**


Igor Gulamov conducted the audit of tornado.cash smart contracts and circuits.


This review was performed by an independent reviewer under fixed rate.
## **Scope**


zkSNARKs & Solidity contracts from <u>[tornado-pool, including](https://github.com/tornadocash/tornado-pool/tree/a976b9b383d5b7110a1d513a21953d3c317377a2)</u> <u>[PR](https://github.com/tornadocash/tornado-pool/pull/10/files)</u> with OVM support.
## **Issues**


We found no critical or major issues.


We consider commit <u>[b085ab398eaeefff98771f5dad893cb804d98e70](https://github.com/tornadocash/tornado-pool/tree/b085ab398eaeefff98771f5dad893cb804d98e70)</u> as a safe version from the

informational security point of view.


We consider commit <u>[9931fdebefa6de3a0e4f8884406f593b354d3ddf](https://github.com/tornadocash/tornado-pool/tree/9931fdebefa6de3a0e4f8884406f593b354d3ddf)</u> as a safe version from the

informational security point of view for OVM implementation.

### **Critical** **Major** **Warnings**


**1.** **<u>[merkleTree.circom#L17-L25](https://github.com/tornadocash/tornado-pool/blob/a976b9b383d5b7110a1d513a21953d3c317377a2/circuits/merkleTree.circom#L24)</u>**


Unoptimized circuit. We propose rewriting it as the following:





**wont fix**


**2.** **<u>[transaction.circom#L23](https://github.com/tornadocash/tornado-pool/blob/a976b9b383d5b7110a1d513a21953d3c317377a2/circuits/transaction.circom#L23)</u>**


transaction input and output amount. We propose replacing it with one in-SNARK variable and

storing the details inside `extData` structure.


**<u>[Fix](https://github.com/tornadocash/tornado-pool/commit/f99eb4bd1ed70f1bb40d7d16d0ca28db753b92e9)</u>** **<u>[Fix2](https://github.com/tornadocash/tornado-pool/commit/042be187d10d331024ab9fa371b8284c449fa77e)</u>**


**3.** **<u>[transaction.circom#L36](https://github.com/tornadocash/tornado-pool/blob/a976b9b383d5b7110a1d513a21953d3c317377a2/circuits/transaction.circom#L36)</u>**


It's enough to publish the subtree hash only. Leaves could be stored at `extData` .


**wont fix**


**4.** **<u>[TornadoPool.sol#L115](https://github.com/tornadocash/tornado-pool/blob/a976b9b383d5b7110a1d513a21953d3c317377a2/contracts/TornadoPool.sol?#L115)</u>**


The expression could be optimized as





**<u>[Refactored in another fix](https://github.com/tornadocash/tornado-pool/commit/042be187d10d331024ab9fa371b8284c449fa77e)</u>**


**5.** **<u>[TornadoPool.sol#L102-L103](https://github.com/tornadocash/tornado-pool/blob/a976b9b383d5b7110a1d513a21953d3c317377a2/contracts/TornadoPool.sol#L102-L103)</u>**


**<u>[Fix](https://github.com/tornadocash/tornado-pool/commit/476668d250c8c421d6be14663b2f1126a01f1933)</u>**


**6.** **<u>[TornadoPool.sol#L102-L106](https://github.com/tornadocash/tornado-pool/blob/a976b9b383d5b7110a1d513a21953d3c317377a2/contracts/TornadoPool.sol#L102-L106)</u>**


Event data is available from calldata. We propose replacing these events with





**wont fix**


**7.** **<u>[transaction.circom#L122](https://github.com/tornadocash/tornado-pool/blob/b085ab398eaeefff98771f5dad893cb804d98e70/circuits/transaction.circom#L122)</u>**

### **Comments**


**1.** **<u>[treeUpdater.circom#L6](https://github.com/tornadocash/tornado-pool/blob/a976b9b383d5b7110a1d513a21953d3c317377a2/circuits/treeUpdater.circom#L6)</u>**


the readability of the circuit.


**<u>[Fix](https://github.com/tornadocash/tornado-pool/commit/75419e5cff407f3cf12541f1c9eb1caf8842ce10)</u>**


**2.** **<u>[transaction.circom#L23](https://github.com/tornadocash/tornado-pool/blob/042be187d10d331024ab9fa371b8284c449fa77e/circuits/transaction.circom#L23)</u>**


Wrong sign in the description. We propose fixing it





**<u>[Fix](https://github.com/tornadocash/tornado-pool/commit/dd5623629a77e9b0101e8310fc2b10568c129302)</u>**
## **Severity Terms**
### **Comment**


Comment issues are generally subjective in nature, or potentially deal with topics like "best

practices" or "readability". Comment issues in general will not indicate an actual problem or bug

in code.


The maintainers should use their own judgment as to whether addressing these issues improves

the codebase.


### **Warning**

Warning issues are generally objective in nature but do not represent actual bugs or security

problems.


These issues should be addressed unless there is a clear reason not to.

### **Major**


Major issues will be things like bugs or security vulnerabilities. These issues may not be directly

exploitable, or may require a certain condition to arise in order to be exploited.


Left unaddressed these issues are highly likely to cause problems with the operation of the

contract or lead to a situation which allows the system to be exploited in some way.

### **Critical**


Critical issues are directly exploitable bugs or security vulnerabilities.


Left unaddressed these issues are highly likely or guaranteed to cause major problems or

potentially a full failure in the operations of the contract.


