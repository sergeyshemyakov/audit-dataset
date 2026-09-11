# **Security Review Report** **NM-0993 - Safe Social Recovery Module**

(August 7, 2026)


**<u>NM-0993 - SAFE SOCIAL RECOVERY MODULE - SECURITY REVIEW</u>**

## **Contents**


**1** **Executive Summary** **2**


**2** **Audited Files** **3**


**3** **Summary of Issues** **4**


**4** **System Overview** **5**
4.1 Social Recovery Module . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 5


**5** **Risk Rating Methodology** **6**


**6** **Issues** **7**


**7** **Documentation Evaluation** **8**


**8** **Test Suite Evaluation** **9**
8.1 Tests Output . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 9


**9** **About Nethermind** **11**


1


**<u>NM-0993 - SAFE SOCIAL RECOVERY MODULE - SECURITY REVIEW</u>**

## **1 Executive Summary**


This document presents the results of the security review conducted by [Nethermind](https://www.nethermind.io/smart-contract-audits) Security for [Safe’s](https://safe.global/) Social Recovery module. The
review covered the module implementation and its use with the 1.3.0 version of the smart account.


The smart account is the base product, allowing users to create smart contracts that can be used as their accounts. It allows users to
manage owners, signature thresholds, execute transactions from the Safe, and extend its functionalities through the use of modules.


The Social Recovery module adds the possibility of creating a set of guardians defined for the Safe account, which can rewrite the set of
owners for that Safe.


**The audit comprises approximately 344** lines of Solidity code. **The audit was performed using** (a) manual analysis of the codebase,
and (b) automated analysis tools.


**Along this document, we report** no points of attention.


**This document is organized as follows.** Section 2 presents the files in the scope. Section 3 presents the summary of issues. Section 4
presents the System Overview. Section 5 discusses the risk rating methodology. Section 6 details the issues. Section 7 discusses the
documentation provided by the client for this audit. Section 8 presents the test suite evaluation and automated tools used. Section 9
concludes the document.



Severity


(a)



None
100.0%



Status


(b)



None
100.0%



**Fig. 1:** **Distribution of issues:** **Critical** (0), **High** (0), **Medium** (0), **Low** (0), **Undetermined** (0), **Informational** (0), **Best Practices** (0).

**Distribution of status:** **Fixed** (0), **Acknowledged** (0), **Mitigated** (0), **Unresolved** (0)


**Summary of the Audit**


**Audit Type** Security Review
**Initial Report** Aug 7, 2026
**Final Report** Aug 17, 2026
**Initial Commit (Social Recovery Module)** [8076191f93e88eefaae3508efa8b12a091158c68](https://github.com/safe-fndn/safe-modules/tree/8076191f93e88eefaae3508efa8b12a091158c68)
**Final Commit (Social Recovery Module)** [8076191f93e88eefaae3508efa8b12a091158c68](https://github.com/safe-fndn/safe-modules/tree/8076191f93e88eefaae3508efa8b12a091158c68)
**Documentation Assessment** High
**<u>Test Suite Assessment</u>** <u>High</u>


2


**<u>NM-0993 - SAFE SOCIAL RECOVERY MODULE - SECURITY REVIEW</u>**

## **2 Audited Files**


**<u>Contract</u>** **<u>LoC</u>** **<u>Comments</u>** **<u>Ratio</u>** **<u>Blank</u>** **<u>Total</u>**
<u>1</u> <u>[contracts/modules/social_recovery/SocialRecoveryModule.sol](https://github.com/5afe/CandideWalletContracts/blob/113d3c059e039e332637e8f686d9cbd505f1e738/contracts/modules/social_recovery/SocialRecoveryModule.sol)</u> <u>247</u> <u>88</u> <u>35.6%</u> <u>34</u> <u>369</u>
<u>2</u> <u>[contracts/modules/social_recovery/storage/IGuardianStorage.sol](https://github.com/5afe/CandideWalletContracts/blob/113d3c059e039e332637e8f686d9cbd505f1e738/contracts/modules/social_recovery/storage/IGuardianStorage.sol)</u> <u>10</u> <u>35</u> <u>350.0%</u> <u>7</u> <u>52</u>
<u>3</u> <u>[contracts/modules/social_recovery/storage/GuardianStorage.sol](https://github.com/5afe/CandideWalletContracts/blob/113d3c059e039e332637e8f686d9cbd505f1e738/contracts/modules/social_recovery/storage/GuardianStorage.sol)</u> <u>87</u> <u>49</u> <u>56.3%</u> <u>16</u> <u>152</u>
**<u>Total</u>** **<u>344</u>** **<u>172</u>** **<u>50.0%</u>** **<u>57</u>** **<u>573</u>**


3


**<u>NM-0993 - SAFE SOCIAL RECOVERY MODULE - SECURITY REVIEW</u>**

## **3 Summary of Issues**


No findings were identified during the review.



4


**<u>NM-0993 - SAFE SOCIAL RECOVERY MODULE - SECURITY REVIEW</u>**

## **4 System Overview**


**Safe** is a multisignature smart contract account, it holds ETH, tokens, and arbitrary assets, and executes arbitrary transactions (CALL or
DELEGATECALL) only when authorized. Authorization comes from one of two paths: an n-of-m threshold of owner signatures (execTransaction()),
or a call from a whitelisted _module_ contract, which bypasses signature checks entirely (execTransactionFromModule()). The account is
extensible through modules, a transaction _guard_, and a _fallback handler_ .


Deployment follows a proxy/singleton pattern: a single GnosisSafe implementation is deployed once per chain, and each user account
is a minimal GnosisSafeProxy that stores the singleton address in storage slot 0 and delegatecalls all calls to it. Proxies are deployed
by the GnosisSafeProxyFactory, optionally via CREATE2 for counterfactual addresses, and are initialized exactly once through setup().
GnosisSafeL2 is a subclass that only adds events so transactions can be indexed on chains.


**4.1** **Social Recovery Module**


The SocialRecoveryModule lets a Safe designate _guardians_ who can collectively replace the owner set and signing threshold if the owners
lose access to their keys. Guardians are stored per wallet in a linked list with an independent guardian threshold. Recovery is a two-phase,
time-delayed process governed by a module-wide immutable recoveryPeriod:


1 **struct** GuardianStorageEntry {

2 **mapping** ( **address** => **address** ) guardians; // sentinel linked list

3 **uint256** count;

4 **uint256** threshold;

5 }


6

7 **struct** RecoveryRequest {

8 **uint256** guardiansApprovalCount;

9 **uint256** newThreshold;

10 **uint64** executeAfter;

11 **address** [] newOwners;

12 }


13

14 **mapping** ( **address** => RecoveryRequest) **internal** recoveryRequests;

15 **mapping** ( **bytes32** => **mapping** ( **address** => **bool** )) **internal** confirmedHashes;

16 **mapping** ( **address** => **uint256** ) **internal** walletsNonces;


    - addGuardianWithThreshold() / revokeGuardianWithThreshold() / changeThreshold() - guardian management, callable only by the

Safe itself; guardians cannot be current owners.


    - confirmRecovery() / multiConfirmRecovery() - guardians approve an EIP-712

ExecuteRecovery(address wallet,address[] newOwners,uint256 newThreshold,uint256 nonce) hash, individually on-chain or as
a batch of ECDSA/EIP-1271 signatures in ascending signer order.


    - executeRecovery() - permissionless; once approvals reach the guardian threshold, records the RecoveryRequest with executeAfter

= block.timestamp + recoveryPeriod and bumps the wallet nonce. A pending request can only be displaced by one carrying strictly
more approvals.


    - finalizeRecovery() - permissionless after the delay; rewrites the owner set via execTransactionFromModule() calls into the Safe’s

OwnerManager.


    - cancelRecovery() / invalidateNonce()    - the owners’ defense during the delay window: the Safe can abort a pending request or

invalidate all outstanding guardian confirmations.


5


**<u>NM-0993 - SAFE SOCIAL RECOVERY MODULE - SECURITY REVIEW</u>**

## **5 Risk Rating Methodology**


The risk rating methodology used by [Nethermind](https://www.nethermind.io/smart-contract-audits) Security follows the principles established by the OWASP [Foundation.](https://owasp.org) The severity of
each finding is determined by two factors: **Likelihood** and **Impact** .


**Likelihood** measures how likely the finding is to be uncovered and exploited by an attacker. This factor will be one of the following values:


a) **High** : The issue is trivial to exploit and has no specific conditions that need to be met;


b) **Medium** : The issue is moderately complex and may have some conditions that need to be met;


c) **Low** : The issue is very complex and requires very specific conditions to be met.


When defining the likelihood of a finding, other factors are also considered. These can include but are not limited to motive, opportunity,
exploit accessibility, ease of discovery, and ease of exploit.


**Impact** is a measure of the damage that may be caused if an attacker exploits the finding. This factor will be one of the following values:


a) **High** : The issue can cause significant damage, such as loss of funds or the protocol entering an unrecoverable state;


b) **Medium** : The issue can cause moderate damage, such as impacts that only affect a small group of users or only a particular part

of the protocol;


c) **Low** : The issue can cause little to no damage, such as bugs that are easily recoverable or cause unexpected interactions that

cause minor inconveniences.


When defining the impact of a finding, other factors are also considered. These can include but are not limited to Data/state integrity, loss
of availability, financial loss, and reputation damage. After defining the likelihood and impact of an issue, the severity can be determined
according to the table below.


**<u>Severity Risk</u>**



**Impact**



**<u>High</u>** <u>Medium</u> <u>High</u> <u>Critical</u>
**<u>Medium</u>** <u>Low</u> <u>Medium</u> <u>High</u>
**<u>Low</u>** <u>Info/Best Practices</u> <u>Low</u> <u>Medium</u>
**<u>Undetermined</u>** <u>Undetermined</u> <u>Undetermined</u> <u>Undetermined</u>
**<u>Low</u>** **<u>Medium</u>** **<u>High</u>**
**<u>Likelihood</u>**



[To address issues that do not fit a High/Medium/Low severity, Nethermind Security also uses three more finding severities:](https://www.nethermind.io/smart-contract-audits) **Informational**,
**Best Practices**, and **Undetermined** .


a) **Informational** findings do not pose any risk to the application, but they carry some information that the audit team intends to pass

to the client formally;


b) **Best Practice** findings are used when some piece of code does not conform with smart contract development best practices;


c) **Undetermined** findings are used when we cannot predict the impact or likelihood of the issue.


6


**<u>NM-0993 - SAFE SOCIAL RECOVERY MODULE - SECURITY REVIEW</u>**

## **6 Issues**


No findings were identified during the review.



7


**<u>NM-0993 - SAFE SOCIAL RECOVERY MODULE - SECURITY REVIEW</u>**

## **7 Documentation Evaluation**


Software documentation refers to the written or visual information that describes the functionality, architecture, design, and implementation
of software. It provides a comprehensive overview of the software system and helps users, developers, and stakeholders understand how
the software works, how to use it, and how to maintain it. Software documentation can take different forms, such as user manuals, system
manuals, technical specifications, requirements documents, design documents, and code comments. Software documentation is critical
in software development, enabling effective communication between developers, testers, users, and other stakeholders. It helps to ensure
that everyone involved in the development process has a shared understanding of the software system and its functionality. Moreover,
software documentation can improve software maintenance by providing a clear and complete understanding of the software system,
making it easier for developers to maintain, modify, and update the software over time. Smart contracts can use various types of software
documentation. Some of the most common types include:


  - Technical whitepaper: A technical whitepaper is a comprehensive document describing the smart contract’s design and technical

details. It includes information about the purpose of the contract, its architecture, its components, and how they interact with each
other;


  - User manual: A user manual is a document that provides information about how to use the smart contract. It includes step-by-step

instructions on how to perform various tasks and explains the different features and functionalities of the contract;


  - Code documentation: Code documentation is a document that provides details about the code of the smart contract. It includes

information about the functions, variables, and classes used in the code, as well as explanations of how they work;


  - API documentation: API documentation is a document that provides information about the API (Application Programming Interface)

of the smart contract. It includes details about the methods, parameters, and responses that can be used to interact with the
contract;


  - Testing documentation: Testing documentation is a document that provides information about how the smart contract was tested.

It includes details about the test cases that were used, the results of the tests, and any issues that were identified during testing;


  - Audit documentation: Audit documentation includes reports, notes, and other materials related to the security audit of the smart

contract. This type of documentation is critical in ensuring that the smart contract is secure and free from vulnerabilities.


These types of documentation are essential for smart contract development and maintenance. They help ensure that the contract is
properly designed, implemented, and tested, and they provide a reference for developers who need to modify or maintain the contract in
the future.


Remarks about Safe’s documentation


The Safe team provided an overview of the main system components during the kick-off call with a detailed explanation of the
intended functionalities. Additionally, the team addressed all questions and concerns raised by the Nethermind Security team,
providing valuable insights and an in-depth understanding of the project’s technical aspects. The Safe team also provided previous
audit reports to consult konwn design choices and later improvements to the protocol.


8


**<u>NM-0993 - SAFE SOCIAL RECOVERY MODULE - SECURITY REVIEW</u>**

## **8 Test Suite Evaluation**


**8.1** **Tests Output**


 - npx hardhat test


GuardianStorage

Adding Guardians

should not allow adding guardian **if** SocialRecoveryModule is not an enabled module
should not allow adding zero address as guardian
should not allow adding sentinel address as guardian
should not allow adding itself (wallet) as guardian
should not allow adding the wallet owners as guardians
should not allow adding guardian with 0 threshold
should not allow adding x guardians with threshold >x
should not allow adding duplicate guardians
should allow adding guardians with new threshold
should allow adding guardians with same threshold
Revoking Guardians

should not allow revoking guardian **if** SocialRecoveryModule is not an enabled module
can not revoke non guardians
can not revoke address 0
can not revoke sentinel address
can not revoke with an invalid threshold
can not revoke with a 0 threshold
revocation reverts **if** wrong previous guardian
should allow revoking guardians with same threshold
should allow revoking guardians with new threshold
Changing Threshold

should not allow changing threshold **if** SocialRecoveryModule is not an enabled module
reverts **if** threshold is higher than guardians count
reverts **if** threshold is equal to 0
allows changing threshold to 0 even with no guardians
allows changing threshold


SocialRecoveryModule

Multi Confirm Recovery

reverts **if** account has no guardians
reverts **if** new owners array is empty
reverts **if** threshold is 0
reverts **if** threshold is higher than new owners length
reverts **if** signatures field is empty
reverts **if** invalid guardian
reverts **if** invalid nonce
reverts **if** invalid signers ordering
reverts **if** duplicate guardian signature
reverts **if** empty signature is not a guardian
reverts **if** empty signature is not transaction sender
reverts **if** approvals is less than threshold and execute is true
allows multiple guardians confirms of a recovery
allows multiple guardians confirms with sender null signature of a recovery
allows multiple guardians confirms of a recovery and auto-executing
Confirm Recovery

reverts **if** sender is not a guardian
reverts **if** new owners array is empty
reverts **if** new threshold is 0
reverts **if** new threshold is     - new owners length
reverts **if** approvals are less than threshold
allows guardian recovery confirmation
allows guardian recovery confirmation and executing
encodeRecoveryData matches off-chain EIP-712 encoding
Execute Recovery

reverts **if** account has no guardians
reverts **if** recovery doesn't have enough approvals
can not replace existing recovery if new one doesn't have more approvals
allows execution of a recovery
allows replacing an existing recovery
Cancel Recovery

reverts **if** there's no ongoing recovery
allows cancelling an ongoing recovery
Finalize Recovery

reverts if there's no ongoing recovery



9


**<u>NM-0993 - SAFE SOCIAL RECOVERY MODULE - SECURITY REVIEW</u>**


reverts **if** recovery period has not passed yet
reverts **if** plugin was not enabled
reverts **if** new owner was later added as a guardian
reverts **if** account removeOwner does not succeed
reverts **if** account swapOwner does not succeed
reverts **if** account addOwnerWithThreshold does not succeed
reverts **if** account changeThreshold does not succeed
allows finalizing a recovery
allows finalizing a recovery with single owner
allows finalizing a recovery **if** one of the new owners is an old one
Invalidate Nonce

allows invalidating a nonce of a recovery


66 passing (395ms)



10


**<u>NM-0993 - SAFE SOCIAL RECOVERY MODULE - SECURITY REVIEW</u>**

## **9 About Nethermind**


[Nethermind](https://nethermind.io/) is a Blockchain Research and Software Engineering company. Our work touches every part of the web3 ecosystem - from
layer 1 and layer 2 engineering, cryptography research, and security to application-layer protocol development. We offer strategic support
to our institutional and enterprise partners across the blockchain, digital assets, and DeFi sectors, guiding them through all stages of the
research and development process, from initial concepts to successful implementation.


We offer security audits of projects built on EVM-compatible chains and Starknet. We are active builders of the Starknet ecosystem,
delivering a node implementation, a block explorer, a Solidity-to-Cairo transpiler, and formal verification tooling. Nethermind also provides
strategic support to our institutional and enterprise partners in blockchain, digital assets, and decentralized finance (DeFi). In the next
paragraphs, we introduce the company in more detail.


**Blockchain** **Security:** At Nethermind, we believe security is vital to the health and longevity of the entire Web3 ecosystem. We provide security services related to Smart Contract Audits, Formal Verification, and Real-Time Monitoring. Our Security Team comprises
blockchain security experts in each field, often collaborating to produce comprehensive and robust security solutions. The team has a
strong academic background, can apply state-of-the-art techniques, and is experienced in analyzing cutting-edge Solidity and Cairo smart
contracts, such as ArgentX and StarkGate (the bridge connecting Ethereum and StarkNet). Most team members hold a Ph.D. degree and
actively participate in the research community, accounting for 240+ articles published and 1,450+ citations in Google Scholar. The security
team adopts customer-oriented and interactive processes where clients are involved in all stages of the work.


**Blockchain** **Core** **Development:** Our core engineering team, consisting of over 20 developers, maintains, improves, and upgrades our
flagship product - the Nethermind Ethereum Execution Client. The client has been successfully operating for several years, supporting both
the Ethereum Mainnet and its testnets, and now accounts for nearly a quarter of all synced Mainnet nodes. Our unwavering commitment
to Ethereum’s growth and stability extends to sidechains and layer 2 solutions. Notably, we were the sole execution layer client to facilitate
Gnosis Chain’s Merge, transitioning from Aura to Proof of Stake (PoS), and we are actively developing a full-node client to bolster Starknet’s
decentralization efforts. Our core team equips partners with tools for seamless node set-up, using generated docker-compose scripts
tailored to their chosen execution client and preferred configurations for various network types.


**DevOps** **and** **Infrastructure** **Management:** Our infrastructure team ensures our partners’ systems operate securely, reliably, and efficiently. We provide infrastructure design, deployment, monitoring, maintenance, and troubleshooting support, allowing you to focus on
your core business operations. Boasting extensive expertise in Blockchain as a Service, private blockchain implementations, and node
management, our infrastructure and DevOps engineers are proficient with major cloud solution providers and can host applications inhouse or on clients’ premises. Our global in-house SRE teams offer 24/7 monitoring and alerts for both infrastructure and application
levels. We manage over 5,000 public and private validators and maintain nodes on major public blockchains such as Polygon, Gnosis,
Solana, Cosmos, Near, Avalanche, Polkadot, Aptos, and StarkWare L2. Sedge is an open-source tool developed by our infrastructure
experts, designed to simplify the complex process of setting up a proof-of-stake (PoS) network or chain validator. Sedge generates dockercompose scripts for the entire validator set-up based on the chosen client, making the process easier and quicker while following best
practices to avoid downtime and being slashed.


**Cryptography** **Research:** At Nethermind, our cryptography Research team conducts cutting-edge internal research and collaborates
closely with external partners on cryptographic protocols, consensus design, succinct arguments and folding schemes, elliptic curve-based
STARK protocols, post-quantum security and zero-knowledge proofs (ZKPs). Our research has led to influential contributions, including
Zinc (Crypto ’25), Mova, FLI (Asiacrypt ’24), and foundational results in Fiat-Shamir security and STARK proof batching. Complementing
this theoretical work, our engineering expertise is demonstrated through implementations such as the Latticefold aggregation scheme, the
Labrador proof system, zkvm-benchmarks, and Plonk Verifier in Cairo. This combined strength in theory and engineering enables us to
deliver cutting-edge cryptographic solutions to partners and clients.


**Smart** **Contract** **Development** **&** **DeFi** **Research:** Our smart contract development and DeFi research team comprises 40+ world-class
engineers who collaborate closely with partners to identify needs and work on value-adding projects. The team specializes in Solidity
and Cairo development, architecture design, and DeFi solutions, including DEXs, AMMs, structured products, derivatives, and money
market protocols, as well as ERC20, 721, and 1155 token design. Our research and data analytics focuses on three key areas: technical
due diligence, market research, and DeFi research. Utilizing a data-driven approach, we offer in-depth insights and outlooks on various
industry themes.


**Our** **suite** **of** **L2** **tooling:** Warp is Starknet’s approach to EVM compatibility. It allows developers to take their Solidity smart contracts
and transpile them to Cairo, Starknet’s smart contract language. In the short time since its inception, the project has accomplished many
achievements, including successfully transpiling Uniswap v3 onto Starknet using Warp.


  - **Voyager** is a user-friendly Starknet block explorer that offers comprehensive insights into the Starknet network. With its intuitive

interface and powerful features, Voyager allows users to easily search for and examine transactions, addresses, and contract
details. As an essential tool for navigating the Starknet ecosystem, Voyager is the go-to solution for users seeking in-depth
information and analysis;


  - **Horus** is an open-source formal verification tool for StarkNet smart contracts. It simplifies the process of formally verifying Starknet

smart contracts, allowing developers to express various assertions about the behavior of their code using a simple assertion
language;


  - **Juno** is a full-node client implementation for Starknet, drawing on the expertise gained from developing the Nethermind Client.

Written in Golang and open-sourced from the outset, Juno verifies the validity of the data received from Starknet by comparing it to
proofs retrieved from Ethereum, thus maintaining the integrity and security of the entire ecosystem.


11


**<u>NM-0993 - SAFE SOCIAL RECOVERY MODULE - SECURITY REVIEW</u>**


**General Advisory to Clients**


As auditors, we recommend that any changes or updates made to the audited codebase undergo a re-audit or security review to address
potential vulnerabilities or risks introduced by the modifications. By conducting a re-audit or security review of the modified codebase,
you can significantly enhance the overall security of your system and reduce the likelihood of exploitation. However, we do not possess
the authority or right to impose obligations or restrictions on our clients regarding codebase updates, modifications, or subsequent audits.
Accordingly, the decision to seek a re-audit or security review lies solely with you.


**Disclaimer**


[This report is based on the scope of materials and documentation provided by you to Nethermind in order that Nethermind could conduct](https://nethermind.io)
the security review outlined in **1.** **Executive** **Summary** and **2.** **Audited** **Files** . The results set out in this report may not be complete nor
inclusive of all vulnerabilities. [Nethermind has provided the review and this report on an as-is, where-is, and as-available basis.](https://nethermind.io) You agree
that your access and/or use, including but not limited to any associated services, products, protocols, platforms, content, and materials,
will be at your sole risk. Blockchain technology remains under development and is subject to unknown risks and flaws. The review does
not extend to the compiler layer, or any other areas beyond the programming language, or other programming aspects that could present
security risks. This report does not indicate the endorsement of any particular project or team, nor guarantee its security. No third party
should rely on this report in any way, including for the purpose of making any decisions to buy or sell a product, service or any other asset.
[To the fullest extent permitted by law, Nethermind disclaims any liability in connection with this report, its content, and any related services](https://nethermind.io)
and products and your use thereof, including, without limitation, the implied warranties of merchantability, fitness for a particular purpose,
and non-infringement. [Nethermind](https://nethermind.io) does not warrant, endorse, guarantee, or assume responsibility for any product or service advertised
or offered by a third party through the product, any open source or third-party software, code, libraries, materials, or information linked to,
called by, referenced by or accessible through the report, its content, and the related services and products, any hyperlinked websites,
any websites or mobile applications appearing on any advertising, [and Nethermind will not be a party to or in any way be responsible for](https://nethermind.io)
monitoring any transaction between you and any third-party providers of products or services. As with the purchase or use of a product
or service through any medium or in any environment, you should use your best judgment and exercise caution where appropriate.
FOR AVOIDANCE OF DOUBT, THE REPORT, ITS CONTENT, ACCESS, AND/OR USAGE THEREOF, INCLUDING ANY ASSOCIATED
SERVICES OR MATERIALS, SHALL NOT BE CONSIDERED OR RELIED UPON AS ANY FORM OF FINANCIAL, INVESTMENT, TAX,
LEGAL, REGULATORY, OR OTHER ADVICE.


12


