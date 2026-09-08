# **Security Review Report** **NM-0993 - Safe Allowance Module**

(August 7, 2026)


**<u>NM-0993 - SAFE ALLOWANCE MODULE - SECURITY REVIEW</u>**

## **Contents**


**1** **Executive Summary** **2**


**2** **Audited Files** **3**


**3** **Summary of Issues** **3**


**4** **System Overview** **4**
4.1 Allowance Module . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4


**5** **Risk Rating Methodology** **5**


**6** **Issues** **6**


**7** **Documentation Evaluation** **7**


**8** **Test Suite Evaluation** **8**
8.1 Tests Output . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 8


**9** **About Nethermind** **10**


1


**<u>NM-0993 - SAFE ALLOWANCE MODULE - SECURITY REVIEW</u>**

## **1 Executive Summary**


This document presents the results of the security review conducted by [Nethermind](https://www.nethermind.io/smart-contract-audits) Security for [Safe’s](https://safe.global/) Allowance module. The review
covered the module implementation and its use with the 1.3.0 version of the smart account.


The smart account is the base product, allowing users to create smart contracts that can be used as their accounts. It allows users to
manage owners, signature thresholds, execute transactions from the Safe, and extend its functionalities through the use of modules.


The Allowance module allows Safe owners to approve delegates to spend specific assets owned by the Safe.


**The audit comprises approximately 289** lines of Solidity code. **The audit was performed using** (a) manual analysis of the codebase,
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
**Initial Commit (Allowances Module)** [c95f03900bff99be090dadb9de1c74b162365485](https://github.com/safe-fndn/safe-modules/tree/c95f03900bff99be090dadb9de1c74b162365485)
**Final Commit (Allowances Module)** [c95f03900bff99be090dadb9de1c74b162365485](https://github.com/safe-fndn/safe-modules/tree/c95f03900bff99be090dadb9de1c74b162365485)
**Documentation Assessment** High
**<u>Test Suite Assessment</u>** <u>High</u>


2


**<u>NM-0993 - SAFE ALLOWANCE MODULE - SECURITY REVIEW</u>**

## **2 Audited Files**


**<u>Contract</u>** **<u>LoC</u>** **<u>Comments</u>** **<u>Ratio</u>** **<u>Blank</u>** **<u>Total</u>**
<u>1</u> <u>[modules/allowances/contracts/AllowanceModule.sol](https://github.com/safe-fndn/safe-modules/blob/c95f03900bff99be090dadb9de1c74b162365485/modules/allowances/contracts/AllowanceModule.sol)</u> <u>271</u> <u>194</u> <u>71.6%</u> <u>38</u> <u>503</u>
<u>2</u> <u>[modules/allowances/contracts/Enum.sol](https://github.com/safe-fndn/safe-modules/blob/c95f03900bff99be090dadb9de1c74b162365485/modules/allowances/contracts/Enum.sol)</u> <u>7</u> <u>3</u> <u>42.9%</u> <u>1</u> <u>11</u>
<u>3</u> <u>[modules/allowances/contracts/SignatureDecoder.sol](https://github.com/safe-fndn/safe-modules/blob/c95f03900bff99be090dadb9de1c74b162365485/modules/allowances/contracts/SignatureDecoder.sol)</u> <u>11</u> <u>17</u> <u>154.5%</u> <u>1</u> <u>29</u>
**<u>Total</u>** **<u>289</u>** **<u>214</u>** **<u>74.0%</u>** **<u>40</u>** **<u>543</u>**

## **3 Summary of Issues**


No findings were identified during the review.


3


**<u>NM-0993 - SAFE ALLOWANCE MODULE - SECURITY REVIEW</u>**

## **4 System Overview**


**Safe** is a multisignature smart contract account, it holds ETH, tokens, and arbitrary assets, and executes arbitrary transactions (CALL or
DELEGATECALL) only when authorized. Authorization comes from one of two paths: an n-of-m threshold of owner signatures (execTransaction()),
or a call from a whitelisted _module_ contract, which bypasses signature checks entirely (execTransactionFromModule()). The account is
extensible through modules, a transaction _guard_, and a _fallback handler_ .


Deployment follows a proxy/singleton pattern: a single GnosisSafe implementation is deployed once per chain, and each user account
is a minimal GnosisSafeProxy that stores the singleton address in storage slot 0 and delegatecalls all calls to it. Proxies are deployed
by the GnosisSafeProxyFactory, optionally via CREATE2 for counterfactual addresses, and are initialized exactly once through setup().
GnosisSafeL2 is a subclass that only adds events so transactions can be indexed on chains.


**4.1** **Allowance Module**


The AllowanceModule lets a Safe grant limited, per-delegate, per-token spending allowances so delegates can transfer funds without
collecting owner signatures. The module is a singleton keyed by Safe address; all configuration functions use msg.sender as the Safe
key and therefore require a full owner-approved Safe transaction. Allowances may be one-time budgets or recurring: with a resetTimeMin
interval configured, the spent amount is lazily zeroed each period, aligned to a configurable base time. Each allowance packs into a single
storage slot:


1 **struct** Allowance {

2 **uint96** amount;

3 **uint96** spent;

4 **uint16** resetTimeMin; // Maximum reset time span is 65k minutes

5 **uint32** lastResetMin;

6 **uint16** nonce;

7 }


   - addDelegate() / removeDelegate() - manage a doubly-linked list of delegates keyed by the lower 6 bytes of the delegate address;

removal optionally clears all of the delegate’s allowances.


   - setAllowance() / resetAllowance() / deleteAllowance()    - configure the cap, reset schedule, and spent amount for a (delegate,

token) pair. Deletion preserves the nonce so stale signatures cannot be replayed against a re-created allowance.


   - executeAllowanceTransfer() - validates the delegate and consumes the per-allowance nonce, enforces that the new spent amount

does not exceed the configured cap, and then moves the funds via execTransactionFromModule()


   - getTokenAllowance() - view returning the allowance with the pending time-based reset applied virtually.


4


**<u>NM-0993 - SAFE ALLOWANCE MODULE - SECURITY REVIEW</u>**

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


5


**<u>NM-0993 - SAFE ALLOWANCE MODULE - SECURITY REVIEW</u>**

## **6 Issues**


No findings were identified during the review.



6


**<u>NM-0993 - SAFE ALLOWANCE MODULE - SECURITY REVIEW</u>**

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


7


**<u>NM-0993 - SAFE ALLOWANCE MODULE - SECURITY REVIEW</u>**

## **8 Test Suite Evaluation**


**8.1** **Tests Output**


 - npx hardhat test


AllowanceModule allowanceManagement

Revert when delegate addresses collide
Cannot set allowance **for** address(0)
Delegate address cannot be address(0)
Do not emit event **if** delegate already added
Do not emit event **if** delegate doesn't exist when removing
Add delegates and removes first delegate
Add delegates and removes second delegate
Add and remove delegate and **then** try to execute
Get delegates from non-zero start index
Explicitly save allowances even after removing delegate
Does not remove delegates with key collision
Cannot set allowance without delegate configured
Overwrite previous allowance
Reset allowance
Delete allowance
Use allowance with payment **in** same token
Use allowance with payment **in** different token
Revert when total of payment and transfer amount exceeds allowance


AllowanceModule allowanceRecurring

Execute allowance without refund
Reverts when trying to set up a recurring allowance with reset period of 0


AllowanceModule allowanceSingle

Execute allowance with delegate
Execute allowance with delegate and empty signature
Execute allowance with v=1 **in** signature
Execute allowance using eth_sign
Execute multiple ether allowance with delegate
Reverts when ether transfer fails
Reverts when token transfer fails
Reverts when token transfer fails without reverting
Reverts when using smart contract signature scheme
Reverts on invalid signature
Reverts on invalid signature length
Reverts **if** ecrecover fails


AllowanceModule nonceOverflow

Should revert on nonce overflow


signature

Generates expected transfer hash


·-------------------------------------------------|----------------------------|-------------|------------------------------·
| Solc version: 0.7.6 - Optimizer enabled: false - Runs: 200 - Block limit: 100000000 gas
··················································|····························|·············|·······························
| Methods
·····················|····························|·············|··············|·············|···············|···············
| Contract - Method - Min - Max - Avg - # calls - usd (avg)
·····················|····························|·············|··············|·············|···············|···············
| AllowanceModule - addDelegate - - - - - 91604 - 1 - ·····················|····························|·············|··············|·············|···············|···············
| AllowanceModule - executeAllowanceTransfer - 66121 - 143029 - 90919 - 17 - ·····················|····························|·············|··············|·············|···············|···············
| Safe - execTransaction - 61730 - 135529 - 114416 - 79 - ·····················|····························|·············|··············|·············|···············|···············
| SafeProxyFactory - createProxyWithNonce - - - - - 240915 - 5 - ·····················|····························|·············|··············|·············|···············|···············
| TestToken - mint - - - - - 68899 - 6 - ·····················|····························|·············|··············|·············|···············|···············
| Deployments - - % of limit ··················································|·············|··············|·············|···············|···············
| TestToken - - - - - 941617 - 0.9 % - ··················································|·············|··············|·············|···············|···············
| WeirdToken - - - - - 145789 - 0.1 % - 

8


**<u>NM-0993 - SAFE ALLOWANCE MODULE - SECURITY REVIEW</u>**


·-------------------------------------------------|-------------|--------------|-------------|---------------|--------------·


34 passing (773ms)


9


**<u>NM-0993 - SAFE ALLOWANCE MODULE - SECURITY REVIEW</u>**

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


10


**<u>NM-0993 - SAFE ALLOWANCE MODULE - SECURITY REVIEW</u>**


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


11


