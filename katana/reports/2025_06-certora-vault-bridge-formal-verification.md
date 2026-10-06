## ​
#### **Security Assessment**
### Final Report

# **​** **Vault Bridge**
##### `June 2025`

```
Prepared for Polygon Labs

```

​ ​ ​ ​ ​ ​ ​

###### **Table of content**


**Project Summary.................................................................................................................................................3**

Project Scope..................................................................................................................................................3
Project Overview............................................................................................................................................. 3

Protocol Overview..................................................................................................................................... 4
**Detailed Findings................................................................................................................................................ 5**

Informational Severity Issues.......................................................................................................................... 5
I-01. Incorrect rounding in the calculation of minimumReserve...................................................................... 6
I-02. Incorrect rounding in the calculation of nonMigratableBacking...............................................................7
**Formal Verification..............................................................................................................................................8**

Verification Methodology................................................................................................................................. 8
Verification Notations.......................................................................................................................................9
General Assumptions and Simplifications.......................................................................................................9
Formal Verification Properties Overview....................................................................................................... 10
Detailed Properties........................................................................................................................................ 11
GenericVaultBridgeToken.............................................................................................................................. 11
P-01. Solvency.............................................................................................................................................. 12
P-02. Valid states.......................................................................................................................................... 12
P-03. Integrity of important methods............................................................................................................. 13
P-04. Risk assessment..................................................................................................................................15
GenericNativeConverter and MigrationManager...........................................................................................17
P-05. Risk assessment..................................................................................................................................17
**Disclaimer.......................................................................................................................................................... 18**
**About Certora.................................................................................................................................................... 18**


​ 2


​ ​ ​ ​ ​ ​ ​
## **Project Summary**


**Project Scope**


Project Plat- ​
Repository (link) Latest Commit Hash
Name form



Vault bridge



<u>[https://github.co](https://github.com/agglayer/vault-bridge)</u>
<u>[m/agglayer/vault-](https://github.com/agglayer/vault-bridge)</u>
<u>[bridge](https://github.com/agglayer/vault-bridge)</u>



Initial commit: <u>[3a7d025](https://github.com/agglayer/vault-bridge/commit/3a7d02576d5ecd1c9f4d22143983839f69d5f135)</u>
Fix review commit: <u>[e4243e0](https://github.com/agglayer/vault-bridge/pull/27/commits/e4243e06d63f71f4a42e2c5fc8d10c42e93a5e73)</u>



EVM



**​**
**Project Overview**


This document describes the security assessment of **Vault bridge** using formal verification. The
work was undertaken from **May 13 2025** to **June 23 2025.**


The following contract list is included in our scope:

```
src\CustomToken.sol
src\VaultBridgeTokenInitializer.sol
src\VaultBridgeToken.sol
src\MigrationManager.sol
src\NativeConverter.sol
src\custom-tokens\GenericCustomToken.sol
src\custom-tokens\GenericNativeConverter.sol
src\custom-tokens\vbUSDC\VbUSDC.sol.generic
src\custom-tokens\vbUSDC\vbUSDCNativeConverter.sol.generic
src\custom-tokens\vbUSDS\VbUSDS.sol.generic
src\custom-tokens\vbUSDS\VbUSDSNativeConverter.sol.generic
src\custom-tokens\vbUSDT\VbUSDT.sol.generic
src\custom-tokens\vbUSDT\VbUSDTNativeConverter.sol.generic
src\custom-tokens\vbWBTC\VbWBTC.sol.generic
src\custom-tokens\vbWBTC\VbWBTCNativeConverter.sol.generic
src\custom-tokens\WETH\WETH.sol

```

​ 3


​ ​ ​ ​ ​ ​ ​

```
src\custom-tokens\WETH\WETHNativeConverter.sol
src\etc\ERC20PermitUser.sol ​
src\etc\IBridgeMessageReceiver.sol
src\etc\ILxLyBridge.sol
src\etc\IVaultBridgeTokenInitializer.sol
src\etc\IVersioned.sol
src\etc\IWETH9.sol
src\vault-bridge-tokens\GenericVaultBridgeToken.sol
src\vault-bridge-tokens\vbETH\VbETH.sol
src\vault-bridge-tokens\vbUSDC\VbUSDC.sol.generic
src\vault-bridge-tokens\vbUSDS\VbUSDS.sol.generic
src\vault-bridge-tokens\vbUSDT\VbUSDT.sol.generic
src\vault-bridge-tokens\vbWBTC\VbWBTC.sol.generic

```

The Certora Prover demonstrated that the implementation of the **Solidity** contracts above is
correct with respect to the formal rules written by the Certora team. During the verification
process, the Certora team identified formal specifications and proofs, as listed on the following
pages.


**Protocol Overview**


The Vault Bridge protocol is a yield-generating cross-chain bridge solution built on top of the
LxLy Bridge system (Polygon zkEVM). Its core component, the Vault Bridge Token, combines
ERC-4626 vault functionality with bridge mechanics to enable yield generation during asset
bridging. ​
The protocol operates across two layers: Layer X (main network) hosts the Vault Bridge Token
(ERC-20/4626) and a singleton Migration Manager for backing asset coordination, while Layer Y
networks contain Custom Tokens (enhanced wrapped tokens) and Native Converters
(pseudo-ERC-4626 vaults). ​
[The tokens on Layer X will be held in a MetaMorpho 1.1](https://github.com/morpho-org/metamorpho-v1.1) ERC-4626 vault. ​
The system supports bridging of major assets (WBTC, WETH, USDT, USDC, USDS) while producing
yield, effectively solving the opportunity cost problem of traditional bridge locking periods
through its vault-bridge hybrid architecture.


​ 4


​ ​ ​ ​ ​ ​ ​
## **Detailed Findings**


**ID** **Title** **Severity** **Status**



<u>I-01</u> Incorrect rounding in the calculation of

minimumReserve


<u>I-02</u> Incorrect rounding in the calculation of

nonMigratableBacking



Informational Fixed


Informational Fixed



​ 5


​ ​ ​ ​ ​ ​ ​


**Informational Severity Issues**


**I-01. Incorrect rounding in the calculation of minimumReserve**


**Description:** In the _rebalanceReserve() function in VaultBridgeToken.sol we have the
following line:


None

uint256 minimumReserve = convertToAssets(Math.mulDiv(originalTotalSupply,

$.minimumReservePercentage, 1e18));


By default the mulDiv rounds down so the minimumReserve could end up being off by one.
Consequently, the actual percentage of reserved assets can drop below the

minimumReservePercentage, as demonstrated by the violated rule in P-03.


**Example:** **​**
**​** totalSupply() = 10​

​ minimumReservePercentage = 39 % = 39e16​

​ minimumReserve = convertToAssets(Math.mulDiv(10, 39e16, 1e18) = 3​

​ Actual reserved percentage = 3 / 10 = 30 % < 39 %


The same formula is used also in the function _calculateAmountToReserve().


**Recommendation:** Specify the rounding direction manually.


**Customer’s response:** Fixed


​ 6


​ ​ ​ ​ ​ ​ ​


**I-02. Incorrect rounding in the calculation of nonMigratableBacking**


**Description:** In the migratableBacking() function in NativeConverter.sol the

nonMigratableBacking is computed as follows:


None

uint256 nonMigratableBacking =

_convertToAssets(Math.mulDiv(customToken().totalSupply(),

$.nonMigratableBackingPercentage, 1e18));


By default the mulDiv rounds down so the result could end up being off by one. Consequently,
the actual percentage of backing can drop below the nonMigratableBackingPercentage. This is
shown in the violated rule in <u>P-05.</u>


**Recommendation:** Specify the rounding direction manually.


**Customer’s response:** Fixed


​ 7


​ ​ ​ ​ ​ ​ ​
## **Formal Verification**


**Verification Methodology**


We performed verification of the **Polygon** protocol using the Certora verification tool which is
based on Satisfiability Modulo Theories (SMT). In short, the Certora verification tool works by
[compiling formal specifications written in the Certora Verifcation Language (CVLi](https://docs.certora.com/en/latest/docs/cvl/index.html) <u>) and</u> **Polygon** ’s
implementation source code written in Solidity. ​
More information about Certora’s tooling can be found in the <u>[Certora Technology Whitepaper.](https://docs.certora.com/en/latest/docs/whitepaper/index.html)</u>

If a property is verified with this methodology it means the specification in CVL holds for all
possible inputs. However specifications must introduce assumptions to rule out situations which
are impossible in realistic scenarios (e.g. to specify the valid range for an input parameter).
Additionally, SMT-based verification is notoriously computationally difficult. As a result, we
introduce overapproximations (replacing real computations with broader ranges of values) and
underapproximations (replacing real computations with fewer values) to make verification
feasible.


**Rules:** A rule is a verification task possibly containing assumptions, calls to the relevant
functionality that is symbolically executed and assertions that are verified on any resulting states
from the computation.


**Inductive Invariants:** Inductive invariants are proved by induction on the structure of a smart
contract. We use constructors as a base case, and consider all other (relevant) externally callable
functions that can change the storage as step cases. ​
Specifically, to prove the base case, we show that a property holds in any resulting state after a
symbolic call to the respective constructor. For proving step cases, we generally assume a state
where the invariant holds (induction hypothesis), symbolically execute the functionality under
investigation, and prove that after this computation any resulting state satisfies the invariant.


​ 8


​ ​ ​ ​ ​ ​ ​


**Verification Notations**



Formally Verified


Formally Verified After Fix



The rule is verified for every state of the
contract(s), under the assumptions of the
scope/requirements in the rule.


The rule was violated due to an issue in the
code and was successfully verified after
fixing the issue



A counter-example exists that violates one
Violated
of the assertions of the rule.


**General Assumptions and Simplifications**


●​ We use mock contracts for asset() / underlyingToken, lxlyBridge and

yieldVault. These exhibit the typical behavior of the respective contracts. By
doing this we implicitly assume that underlyingToken !=

GenericVaultBridgeToken.


●​ We assume that underlyingToken, lxlyBridge and yieldVault work correctly and
do not have any security vulnerabilities that an attacker could exploit, that is, we
assume that yieldVault is immune to inflation attacks.


●​ We use our own implementation of Math.mulDiv which is equivalent to the original
and better suited to our prover.


●​ Loops are inherently difficult for formal verification. We handle loops by unrolling
them a specific amount of times. We use a **loop_iter of 2**, unrolling each loop
exactly twice. This only affects the loop in

MigrationManager.configureNativeConverters.


●​ Harnessing: We work with contracts inherited from the original contracts to add
additional methods, flags, getters, etc. for verification purposes without modifying
the original code. Any verification result on the harness applies to the original
contract.


​ 9


​ ​ ​ ​ ​ ​ ​


●​ The verified Solidity contracts are compiled with solcX (with via-ir).


**Formal Verification Properties Overview**


**ID** **Contract** **Title** **Impact** **Status**



<u>P-01</u> GenericVault
BridgeToken


<u>P-02</u> GenericVault
BridgeToken


<u>P-03</u> GenericVault
BridgeToken


<u>P-04</u> GenericVault
BridgeToken


<u>P-05</u> GenericNativ
eConverter ​
MigrationMan
ager



Solvency Verifies that the vault token maintains
solvency against its total obligations
under worst-case yield slippage.



Valid States
Invariants


Integrity
Rules


Risk
assessment


Risk
assessment



Prevents invalid configurations by
enforcing bounds on reserves, supply,
and allowances.


Verifies correctness and monotonicity
of core financial operations to ensure
reliable and predictable behavior.


Guarantees that only known and
permitted methods can mutate critical
state variables preventing
unauthorized behavior.


Verifies that the system remains
solvent and migration-safe, with
sufficient and non-depletable asset
backing.



Verified


Verified


Verified
after fix


Verified


Verified
after fix


​ 10


​ ​ ​ ​ ​ ​ ​


**Detailed Properties**


**GenericVaultBridgeToken**


<u>Module Properties</u>


To check correctness of the GenericVaultBridgeToken, we prove **four sets of properties** :


P1​ **Solvency.** Let’s use this notation:​

A = convertToAssets(totalSupply() + yield()) - reservedAssets()​
B = return value of yieldVault.withdraw(assets)​
C = assets​
D = yieldVault.balanceOf(GenericVaultBridgeToken)​
E = (10^18 + yieldVaultMaximumSlippagePercentage)​

​
The solvency property states that for all assets​
​ A * B / C <= D * E / 10^18​
This can be rewritten to​
​ A * B * 10^18 <= D * E * C​
We’re assuming that the yieldVault always holds more assets than its total shares which
means that B <= C, so​

​ A * B * 10^18 <= A * C * 10^18 (<= D * E * C)​
Hence we can cancel the term C and simplify the formula to​

​ A * 10^18 <= D * E​
We formally prove this as rule vaultBridgeTokenSolvency.​
​
We also proved a simplified version which states​
​ totalAssets() >= convertToAssets(totalSupply())​
This is verified as rule vaultBridgeTokenSolvency_simple.
P2​ **Valid states of the contract:** a set of invariants that hold in every valid state. E.g. ​

​ minimumReservePercentage <= 10^18.​
We proved these and then we assume them in our other rules.
P3​ **Integrity of important methods**
P4​ **Risk assessment properties**


​ 11


​ ​ ​ ​ ​ ​ ​


**P-01.** **Solvency**


Status: Verified


Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/6893/81dc4788a4134e5db46cbf3a31687b9b/)</u>



**<mark>vaultBridgeTokenSolvency_simple​</mark>**
**<mark>vaultBridgeTokenSolvency</mark>**


**P-02.** **Valid states**


Status: Verified



Verified The contract stays solvent.



Rule Name Status Description Link to rule
report



**<mark>minimumReservePercentageL</mark>**
**<mark>imit</mark>**


**<mark>netCollectedYieldAccounted</mark>**
**<mark>netCollectedYieldLimited</mark>**



Verified _`minimumReservePercentage`_ cannot exceed
```
         10^18.

```

Verified _`netCollectedYield`_ is never greater than the

balance of the _`yieldRecipient`_ .



**<mark>reserveBacked</mark>** Verified The contract holds enough underlying tokens to

cover _`reservedAssets + migrationFeesFund.`_



<u>[Report](https://prover.certora.com/output/6893/f0aeacf781154af9bb08c1c95da4f2dc/)</u>


<u>[Report](https://prover.certora.com/output/6893/1d0356a2ee254d34ae262146532ed51d/)</u>


<u>[Report](https://prover.certora.com/output/6893/d6f552b06b9c419fba88a52c96a888cc/)</u>



**<mark>assetsMoreThanSupply</mark>**
**<mark>noSupplyIfNoAssets</mark>**


**<mark>zeroAllowanceOnAssets</mark>**
**<mark>zeroAllowanceOnShares</mark>**



Verified _`totalSupply`_ cannot exceed _`totalAssets.`_ <u>[Report](https://prover.certora.com/output/6893/a60fa94f85204b11800f12c503af6e1a/)</u>



Verified The contract doesn’t give allowance to any

address except the _`yieldVault.`_



<u>[Report](https://prover.certora.com/output/6893/db2e911b8898463db27d9cd5f4d92d3f/)</u>


​ 12


​ ​ ​ ​ ​ ​ ​


**P-03.** **Integrity of important methods**


Status: Verified after fix


Rule Name Status Description Link to rule
report



After calling _`rebalanceReserve`_, the

_`reservedAssets`_ >=

_`minimumReservedAssets`_ . The method

doesn’t affect _`totalAssets`_ .



<u>[Original report](https://prover.certora.com/output/1000000000/c45e6b9e67cf414e9d6854396ae26ef0/?anonymousKey=52a8295bfb9f1d4ba6d1230a7ce1330de57143b3)</u> _<u>​</u>_

<u>[Report after fix](https://prover.certora.com/output/6893/926bbe8911cd4df3861cc0479dba78df/)</u>


<u>[Report](https://prover.certora.com/output/6893/926bbe8911cd4df3861cc0479dba78df/)</u>


<u>[Report](https://prover.certora.com/output/6893/926bbe8911cd4df3861cc0479dba78df/)</u>



**<mark>integrityOfRebalance</mark>**


**<mark>integrityOfRebalance_margin1</mark>**



Verified
after fix ​
​
Reported
issue <u>I-01</u>



Verified After calling _`rebalanceReserve`_, the

_`reservedAssets`_ +1 >=

_`minimumReservedAssets`_ . The method

doesn’t affect _`totalAssets`_ .



**<mark>integrityOf_depositIntoYieldVault</mark>** Verified _`nonDeposited =`_
```
                                  depositIntoYieldVault(assets)
```

then _`nonDeposited`_ _`<= assets.`_



**<mark>integrityOf_simulateWithdraw_force</mark>** Verified _`_simulateWithdraw(x, true) == x.`_ <u>[Report](https://prover.certora.com/output/6893/926bbe8911cd4df3861cc0479dba78df/)</u>



<u>[Report](https://prover.certora.com/output/6893/926bbe8911cd4df3861cc0479dba78df/)</u>


<u>[Report](https://prover.certora.com/output/6893/7ef323f5cc08481e966730b3a77944ef/)</u>


<u>[Report](https://prover.certora.com/output/6893/7ef323f5cc08481e966730b3a77944ef/)</u>



**<mark>previewDepositCorrectness_strict</mark>**
**<mark>previewMintCorrectness_strict​</mark>**
**<mark>previewRedeemCorrectness_strict</mark>**
**<mark>previewWithdrawCorrectness_strict</mark>**


**<mark>conversionOfZero</mark>**


**<mark>convertToAssetsWeakAdditivity</mark>**
**<mark>convertToSharesWeakAdditivity</mark>**



Verified Preview methods provide exact

information.


Verified convertTo(0) == 0. (Both

_`convertToAssets`_ and

_`converToShares`_ .)


Verified convertTo(A) + convertTo(B) <=

convertTo(A+B) (Both

_`convertToAssets`_ and

_`converToShares`_ .)



​ 13


​ ​ ​ ​ ​ ​ ​



<u>[Report](https://prover.certora.com/output/6893/7ef323f5cc08481e966730b3a77944ef/)</u>


<u>[Report](https://prover.certora.com/output/6893/7ef323f5cc08481e966730b3a77944ef/)</u>


<u>[Report](https://prover.certora.com/output/6893/7ef323f5cc08481e966730b3a77944ef/)</u>


<u>[Report](https://prover.certora.com/output/6893/7ef323f5cc08481e966730b3a77944ef/)</u>



**<mark>conversionWeakMonotonicity</mark>**



Verified A < B then convertTo(A) <=

convertTo(B) (Both _`convertToAssets`_

and _`convertToShares`_ .)



**<mark>conversionWeakIntegrity</mark>** Verified _`convertToShares(convertToAssets(`_
```
                                  X)) <= X

```

**<mark>depositMonotonicity</mark>** Verified A < B, then _`deposit(A)`_ gives less or

equal shares than _`deposit(B)`_


**<mark>zeroDepositZeroShares</mark>** Verified _`deposit(x) == 0`_ if and only if _`x ==`_
```
                                  0.

```


​ 14


​ ​ ​ ​ ​ ​ ​


**P-04.** **Risk assessment**


Status: Verified


Rule Name Status Description Link to rule
report



<u>[Report](https://prover.certora.com/output/6893/2a590a1bd5a240628ac99333108c00bc/)</u>


<u>[Report](https://prover.certora.com/output/6893/2a590a1bd5a240628ac99333108c00bc/)</u>


<u>[Report](https://prover.certora.com/output/6893/2a590a1bd5a240628ac99333108c00bc/)</u>


<u>[Report](https://prover.certora.com/output/6893/2a590a1bd5a240628ac99333108c00bc/)</u>


<u>[Report](https://prover.certora.com/output/6893/7ef323f5cc08481e966730b3a77944ef/)</u>



**<mark>onlyAllowedMethodsMayChangeMigrati</mark>**
**<mark>onFeesFund</mark>**


**<mark>onlyAllowedMethodsMayChangeTotalAs</mark>**
**<mark>sets</mark>**


**<mark>onlyAllowedMethodsMayChangeTotalSu</mark>**
**<mark>pply</mark>**


**<mark>onlyAllowedMethodsMayChangeStaked</mark>**
**<mark>Assets</mark>**



Verified Only specified methods may change

_`migrationFeesFund`_ .


Verified Only specified methods may change

_`totalAssets`_ .


Verified Only specified methods may change

_`totalSupply`_ .


Verified Only specified methods may change

_`stakedAssets`_ .



**<mark>noDynamicCalls</mark>** Verified There are no dynamic calls to

untrusted contracts.



**<mark>underlyingCannotChange</mark>** Verified address of _`asset()`_ never changes. <u>[Report](https://prover.certora.com/output/6893/7ef323f5cc08481e966730b3a77944ef/)</u>



**<mark>dustFavorsTheHouse</mark>** Verified _`redeem(deposit(x))`_ doesn't

decrease the balance of the

contract.


**<mark>redeemingAllValidity</mark>** Verified After redeeming the entire balance,

the user's balance is zero.



<u>[Report](https://prover.certora.com/output/6893/7ef323f5cc08481e966730b3a77944ef/)</u>


<u>[Report](https://prover.certora.com/output/6893/7ef323f5cc08481e966730b3a77944ef/)</u>


​ 15


​ ​ ​ ​ ​ ​ ​



**<mark>onlyContributionMethodsReduceAssets​</mark>**
**<mark>contributingProducesShares</mark>**



Verified Only specified methods may

decrease the user's balance. _​_

When a user contributes assets,

they are given shares.



**<mark>reclaimingProducesAssets</mark>** Verified When calling _`withdraw`_ or _`redeem`_

with _`receiver`_ and _`owner`_, _`owner’s`_

shares go down if and only if

_`receiver’s`_ assets go up.



<u>[Report](https://prover.certora.com/output/6893/7ef323f5cc08481e966730b3a77944ef/)</u>


<u>[Report](https://prover.certora.com/output/6893/7ef323f5cc08481e966730b3a77944ef/)</u>


​ 16


​ ​ ​ ​ ​ ​ ​


**GenericNativeConverter and MigrationManager**


<u>Module Properties</u>


We verified that the GenericNativeConverter is always solvent and two more important properties
about _`backingOnLayerY`_ and _`nonMigratableBacking.`_


**P-05.** **Risk assessment**


Status: Verified after fix


Rule Name Status Description Link to rule
report



<u>[Report](https://prover.certora.com/output/6893/fcc54d1a22894d1b8f67fe5341634a1e/)</u>


<u>[Report](https://prover.certora.com/output/6893/fcc54d1a22894d1b8f67fe5341634a1e/)</u>


<u>[Report](https://prover.certora.com/output/6893/fcc54d1a22894d1b8f67fe5341634a1e/)</u>


<u>[Original report](https://prover.certora.com/output/1000000000/a9928c36af4d417cb356f44c10846d85/?anonymousKey=d33d510dcdfd55d20424ac572973ba40d406afba)</u> _<u>​</u>_

<u>[Report after fix](https://prover.certora.com/output/6893/fcc54d1a22894d1b8f67fe5341634a1e/)</u>


<u>[Report](https://prover.certora.com/output/6893/fcc54d1a22894d1b8f67fe5341634a1e/)</u>


<u>[Report](https://prover.certora.com/output/6893/131bd67fccc242b895d4ecfce1a0e438/)</u>


​ 17



**<mark>converterSolvency</mark>**



Verified The balance of the converter is at least

_`backingOnLayerY`_ .



**<mark>backingMoreThanSupply</mark>** Verified _`backingOnLayerY`_ is at least

_`customToken.TotalSupply`_ (minus

bridged assets).



**<mark>nonMigratableBackingPercentage</mark>**
**<mark>LT_E18</mark>**


**<mark>nonMigratableBackingAlwaysPres</mark>**
**<mark>ent</mark>**


**<mark>nonMigratableBackingAlwaysPres</mark>**
**<mark>ent_margin1</mark>**


**<mark>onMsgReceived_doesntAlwaysRe</mark>**
**<mark>vert</mark>**



Verified _`nonMigratableBackingPercentage`_

cannot exceed _`10^18`_ .



Verified _`backingOnLayerY`_ + 1 can’t go below

_`nonMigratableBacking`_ .


Verified _`MigrationManager.onMsgReceived`_
```
         doesn't always revert

```


Verified after
fix ​
Reported
issue I-02



_`backingOnLayerY`_ can’t go below

_`nonMigratableBacking`_ .


​ ​ ​ ​ ​ ​ ​

## **Disclaimer**


Even though we hope this information is helpful, we provide no warranty of any kind, explicit or
implied. The contents of this report should not be construed as a complete guarantee that the
contract is secure in all dimensions. In no event shall Certora or any of its employees be liable for
any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising
from, out of, or in connection with the results reported here.

## **About Certora**


Certora is a Web3 security company that provides industry-leading formal verification tools and
smart contract audits. Certora’s flagship security product, Certora Prover, is a unique SaaS
product that automatically locates even the most rare & hard-to-find bugs on your smart
contracts or mathematically proves their absence. The Certora Prover plugs into your standard
deployment pipeline. It is helpful for smart contract developers and security researchers during
auditing and bug bounties.

Certora also provides services such as auditing, formal verification projects, and incident
response.


​ 18


