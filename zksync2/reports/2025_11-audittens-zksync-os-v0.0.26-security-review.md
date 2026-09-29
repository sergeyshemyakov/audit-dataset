# **Audittens** **ZKsync OS Security Review**

November 4, 2025


## **Contents**

**1** **About** **Audittens** **3**


**2** **About** **ZKsync** **OS** **3**


**3** **Risk** **classification** **3**


**4** **Executive** **summary** **4**
4.1 Engagement overview . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4
4.2 Scope . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4
4.3 Summary of findings . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4


**5** **Assumptions** **and** **limitations** **5**
5.1 Explicit invariants of the codebase usage . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 5
5.2 Limitations . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 5


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


You can subscribe and learn more about the project at `[https://zksync.io](https://zksync.io)` .

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
implementation. Between June 23, 2025 and November 4, 2025, a team of 3 security researchers reviewed the provided
source code over a total of 11 weeks within this period. After the completion of the fix period by ZKsync’s team, the
full security review was finalized by reviewing the corresponding commits.


**4.2** **Scope**


Security review for the components of the `matter-labs/zksync-os` repository was provided.


The following parts of the codebase were within the scope of the security review:


**<u>Commit</u>** **<u>Scope</u>**
<u>`[50dd547](https://github.com/matter-labs/zksync-os/tree/50dd547f01099d3c4f76b6e34e8ad3657aaa4432)`</u> <u>parts</u> <u>of</u> <u>`basic`</u> ~~<u>`b`</u>~~ <u>`[ootloader](https://github.com/matter-labs/zksync-os/tree/50dd547f01099d3c4f76b6e34e8ad3657aaa4432/basic_bootloader)`</u> <u>,</u> <u>`basic`</u> ~~<u>`[s](https://github.com/matter-labs/zksync-os/tree/50dd547f01099d3c4f76b6e34e8ad3657aaa4432/basic_system)`</u>~~ <u>`ystem`</u> <u>,</u> <u>`[storage](https://github.com/matter-labs/zksync-os/tree/50dd547f01099d3c4f76b6e34e8ad3657aaa4432/storage_models)`</u> ~~<u>`m`</u>~~ <u>`odels`</u> <u>and</u> <u>`zk`</u> ~~<u>`e`</u>~~ <u>`e`</u> <u>crates</u>
<u>`[aad3fab](https://github.com/matter-labs/zksync-os/tree/50dd547f01099d3c4f76b6e34e8ad3657aaa4432)`</u> <u>pull</u> <u>request</u> <u>“multiblock</u> <u>[batch](https://github.com/matter-labs/zksync-os/pull/152)</u> <u>proving”</u>
`[c3698e4](https://github.com/matter-labs/zksync-os/tree/c3698e4fe71406086b2d1e1270a54e7f8cf61a41)` parts of `basic` ~~`b`~~ `[ootloader](https://github.com/matter-labs/zksync-os/tree/c3698e4fe71406086b2d1e1270a54e7f8cf61a41/basic_bootloader)`, `basic` ~~`[s](https://github.com/matter-labs/zksync-os/tree/c3698e4fe71406086b2d1e1270a54e7f8cf61a41/basic_system)`~~ `ystem`, `evm` `[interpreter](https://github.com/matter-labs/zksync-os/tree/c3698e4fe71406086b2d1e1270a54e7f8cf61a41/evm_interpreter)`, `[forward](https://github.com/matter-labs/zksync-os/tree/c3698e4fe71406086b2d1e1270a54e7f8cf61a41/forward_system)` ~~`s`~~ `ystem`,
<u>`proof`</u> ~~<u>`r`</u>~~ <u>`[unning](https://github.com/matter-labs/zksync-os/tree/c3698e4fe71406086b2d1e1270a54e7f8cf61a41/proof_running_system)`</u> ~~<u>`s`</u>~~ <u>`ystem`</u> <u>and</u> <u>`[system](https://github.com/matter-labs/zksync-os/tree/c3698e4fe71406086b2d1e1270a54e7f8cf61a41/system_hooks)`</u> <u>`hooks`</u> <u>crates</u>


**4.3** **Summary** **of** **findings**



**Severity**



**Status**
**Acknowledged** **Fixed** **Total**



**<mark>Critical</mark>** <mark>0</mark> <mark>5</mark> <mark>5</mark>


**<mark>High</mark>** <mark>1</mark> <mark>7</mark> <mark>8</mark>


**<mark>Medium</mark>** <mark>3</mark> <mark>8</mark> <mark>11</mark>


**<mark>Low</mark>** <mark>5</mark> <mark>10</mark> <mark>15</mark>


**<mark>Informational</mark>** <mark>20</mark> <mark>13</mark> <mark>33</mark>


**<mark>Total</mark>** <mark>29</mark> <mark>43</mark> <mark>72</mark>


Table 1. Distribution of found issues.


Audittens 4 ZKsync


## **5 Assumptions and limitations**

**5.1** **Explicit** **invariants** **of** **the** **codebase** **usage**


The security review was conducted assuming that:


1. ZKsync account abstraction, paymaster and EIP-712 transactions will be deprecated.


2. ZKsync OS will not be used as a settlement layer.


**5.2** **Limitations**


The security review was provided as is. Any subsequent changes may introduce new vulnerabilities and require a
separate security review. Fixes for all findings have been reviewed within the limited scope (in the context of only
relevant protocol components).


Audittens 5 ZKsync


