# **Audittens** **ZKsync OS Security Review** **(v0.1.0...v0.3.0)**

May 6, 2026


## **Contents**

**1** **About** **Audittens** **3**


**2** **About** **ZKsync** **OS** **3**


**3** **Risk** **classification** **3**


**4** **Executive** **summary** **4**
4.1 Engagement overview . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4
4.2 Scope . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4
4.3 Summary of findings . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4


**5** **Limitations** **5**


Audittens 2 ZKsync


## **1 About Audittens**

Audittens is an audit company with expertise across various sectors of Web3 security.


What truly sets us apart is that our team consists entirely of top participants in mathematics and competitive
programming competitions, uniquely equipping us to rapidly analyze codebases, uncover explicit and implicit
invariants, and identify unique attack vectors.


You can subscribe and learn more about us at `[https://x.com/Audittens](https://x.com/Audittens)` .

## **2 About ZKsync OS**


ZKsync OS is a system-level implementation for ZKsync’s state transition function.


Under ZKsync’s new architecture, execution is decoupled from proving. ZKsync OS acts as the operation layer in this
new architecture. It takes block data and an initial state as input and computes the new state after the application of
the block. ZKsync OS is implemented as a Rust program.


You can learn more about the project at `[https://zksync.io](https://zksync.io)` .

## **3 Risk classification**


The severities of the issues are determined based on the following properties:


  - Critical — results in a significant loss of assets within the protocol, a major deviation from the expected behavior
of protocol components, and/or a violation of key security invariants.


  - High  - causes loss of assets within the protocol and/or general violations of protocol security invariants, with
limitations on the variety of potential attacks.


  - Medium  - enables barely profitable attacks on the protocol, violations of security invariants that pose minimal
risk to protocol users, and/or functionality limitations affecting only a relatively small subset of users.


  - Low  - enables griefing attacks on the protocol, unexpected changes in the protocol’s behavior that are
imperceptible, and/or functionality limitations with negligible impact on the security of the protocol.


  - Informational  - issues that have no practical impact on the security of the current version of the protocol but
could potentially lead to more serious consequences in future updates, create the possibility for incorrect use of
the protocol by users, and/or result in a significant decline in code quality, making maintenance more challenging.


While determining the severity of issues, the constraints required for successful attacks and the potential actions to
address their consequences are taken into account in the decision-making process.


Audittens 3 ZKsync


## **4 Executive summary**

**4.1** **Engagement** **overview**


ZKsync Security Council Foundation engaged Audittens to review the security of components of ZKsync OS’s
implementation. Between December 1, 2025 and May 6, 2026, a team of 3 security researchers reviewed the provided
source code over a total of 11 weeks within this period. After the completion of the fix period by ZKsync’s team, the
full security review was finalized by reviewing the corresponding commits.


**4.2** **Scope**


Security review for the components of the `matter-labs/zksync-os` repository was provided.


All changes introduced by the `[be15cc07...12833202](https://github.com/matter-labs/zksync-os/compare/be15cc0778ce2e51f533d47a24143cce441364e7...12833202c2c680646069edde3d4bd04cce60d481)` ( `v0.1.0...v0.3.0` ) diff, except for the changes related to
Ethereum STF, were within the scope of the security review. Specifically, the following directories were excluded
from the scope:


  - `basic` ~~`b`~~ `ootloader/src/bootloader/block` ~~`f`~~ `low/ethereum`,


  - `basic` ~~`b`~~ `ootloader/src/bootloader/transaction` ~~`f`~~ `low/ethereum`,


  - `basic` ~~`s`~~ `ystem/src/system` `implementation/ethereum` ~~`s`~~ `torage` ~~`m`~~ `odel` .


**4.3** **Summary** **of** **findings**



**Severity**



**Status**
**Acknowledged** **Fixed** **Total**



**<mark>Critical</mark>** <mark>0</mark> <mark>1</mark> <mark>1</mark>


**<mark>High</mark>** <mark>0</mark> <mark>4</mark> <mark>4</mark>


**<mark>Medium</mark>** <mark>1</mark> <mark>4</mark> <mark>5</mark>


**<mark>Low</mark>** <mark>4</mark> <mark>13</mark> <mark>17</mark>


**<mark>Informational</mark>** <mark>7</mark> <mark>38</mark> <mark>45</mark>


**<mark>Total</mark>** <mark>12</mark> <mark>60</mark> <mark>72</mark>


Table 1. Distribution of found issues.


Audittens 4 ZKsync


## **5 Limitations**

The security review was provided as is. Any subsequent changes may introduce new vulnerabilities and require a
separate security review. Fixes for all findings have been reviewed within the limited scope (in the context of only
relevant protocol components).


Audittens 5 ZKsync


