## **Optimism Superchain**

### **Security Review**

#### Cantina Managed review by: Haxatron, Lead Security Researcher MiloTruck, Lead Security Researcher November 28, 2025


##### **Contents**

**1** **Introduction** **2**
1.1 About Cantina . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2
1.2 Disclaimer . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2
1.3 Risk assessment . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2
1.3.1 Severity Classification . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2


**2** **Security Review Summary** **3**
2.1 Scope . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 3


**3** **Findings** **4**
3.1 Informational . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4
3.1.1 FeeVaultUpgrader.SETTERS_GAS_LIMIT can be moved to RevShareCommon . . . 4
3.1.2 Notes On Gas Costs . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4


1


##### **1 Introduction**

**1.1** **About Cantina**


Cantina is a security services marketplace that connects top security researchers and solutions with clients.
[Learn more at cantina.xyz](https://cantina.xyz)


**1.2** **Disclaimer**


Cantina Managed provides a detailed evaluation of the security posture of the code at a particular moment
based on the information available at the time of the review. While Cantina Managed endeavors to identify
and disclose all potential security issues, it cannot guarantee that every vulnerability will be detected or
that the code will be entirely secure against all possible attacks. The assessment is conducted based on
the specific commit and version of the code provided. Any subsequent modifications to the code may
introduce new vulnerabilities that were absent during the initial review. Therefore, any changes made
to the code require a new security review to ensure that the code remains secure. Please be advised
that the Cantina Managed security review is not a replacement for continuous security measures such as
penetration testing, vulnerability scanning, and regular code reviews.


**1.3** **Risk assessment**


**<u>Severity level</u>** **<u>Impact:</u>** **<u>High</u>** **<u>Impact:</u>** **<u>Medium</u>** **<u>Impact:</u>** **<u>Low</u>**
**<u>Likelihood:</u>** **<u>high</u>** <u>Critical</u> <u>High</u> <u>Medium</u>
**<u>Likelihood:</u>** **<u>medium</u>** <u>High</u> <u>Medium</u> <u>Low</u>
**<u>Likelihood:</u>** **<u>low</u>** <u>Medium</u> <u>Low</u> <u>Low</u>


**1.3.1** **Severity Classification**


The severity of security issues found during the security review is categorized based on the above table.
Critical findings have a high likelihood of being exploited and must be addressed immediately. High
findings are almost certain to occur, easy to perform, or not easy but highly incentivized thus must be
fixed as soon as possible.


Medium findings are conditionally possible or incentivized but are still relatively likely to occur and should
be addressed. Low findings are a rare combination of circumstances to exploit, or offer little to no incentive
to exploit but are recommended to be addressed.


Lastly, some findings might represent objective improvements that should be addressed but do not impact
the project’s overall security (Gas and Informational findings).


2


##### **2 Security Review Summary**

Optimism is a fast, stable, and scalable L2 blockchain built by Ethereum developers, for Ethereum developers. Built as a minimal extension to existing Ethereum software, Optimism's EVM-equivalent architecture
scales your Ethereum apps without surprises. If it works on Ethereum, it works on Optimism at a fraction
of the cost.


From Nov 20th to Nov 23rd the Cantina team conducted a review of [superchain-ops](https://github.com/ethereum-optimism/superchain-ops) on commit hash
[5a01b8c1.](https://github.com/ethereum-optimism/superchain-ops/tree/5a01b8c1e4cd3e7d5acab48175612f86eb451c26/) The team identified a total of **2** issues:


**Issues Found**


**<u>Severity</u>** **<u>Count</u>** **<u>Fixed</u>** **<u>Acknowledged</u>**
<u>Critical Risk</u> <u>0</u> <u>0</u> <u>0</u>
<u>High Risk</u> <u>0</u> <u>0</u> <u>0</u>
<u>Medium Risk</u> <u>0</u> <u>0</u> <u>0</u>
<u>Low Risk</u> <u>0</u> <u>0</u> <u>0</u>
<u>Gas Optimizations</u> <u>0</u> <u>0</u> <u>0</u>
<u>Informational</u> <u>2</u> <u>2</u> <u>0</u>
**<u>Total</u>** **<u>2</u>** **<u>2</u>** **<u>0</u>**


[The Cantina Managed team reviewed OP Labs’s superchain-ops holistically on commit hash 692cab0d (PR](https://github.com/ethereum-optimism/superchain-ops)
[1308) and concluded that all findings were addressed and no new vulnerabilities were identified.](https://github.com/ethereum-optimism/superchain-ops/pull/1308/commits/692cab0d8a827ffd167da6535a1dd1108ec42659)


**2.1** **Scope**


[The security review had the following components in scope for superchain-ops on commit hash 5a01b8c1:](https://github.com/ethereum-optimism/superchain-ops)


src
├──libraries
│ ├──FeeSplitterSetup.sol
│ ├──FeeVaultUpgrader.sol
│ └──RevShareCommon.sol
└──RevShareContractsUpgrader.sol


3


##### **3 Findings**

**3.1** **Informational**


**3.1.1** **FeeVaultUpgrader.SETTERS_GAS_LIMIT** **can be moved to** **RevShareCommon**


**Severity:** Informational


**Context:** [RevShareContractsUpgrader.sol#L103](https://cantina.xyz/code/ac2ffc69-4ffa-4c78-9a92-9a15d55e54fb/src/RevShareContractsUpgrader.sol#L103)


**Description/Recommendation:** Consider moving the FeeVaultUpgrader.SETTERS_GAS_LIMIT
constant to the RevShareCommon library instead, as it is also used for other setters such as

FeeSplitter.setSharesCalculator and not just exclusively for the fee vaults.


**OP Labs:** [Fixed in PR 1308.](https://github.com/ethereum-optimism/superchain-ops/pull/1308)


**Cantina Managed:** Fix verified.


**3.1.2** **Notes On Gas Costs**


**Severity:** Informational


**Context:** _(No context files were provided by the reviewer)_


**Description:** We performed a deployment that uses upgradeAndSetupRevShare to upgrade a local
chain that was originally not using the FeeSplitter contracts to then use it. All deposit transactions
were executed successfully. The following table are the gas costs that were observed as compared to the
gas limit and are meant to be provided as a reference:


<mark>Operation</mark> <mark>Actual Gas Used</mark> <mark>Gas Limit Conf</mark> i <mark>gured</mark>


<mark>1.</mark> <mark>Deploy</mark> <mark>L1Withdrawer</mark> <mark>558_032</mark> <mark>700_000</mark>
<mark>2.</mark> <mark>Deploy</mark> <mark>SuperchainRevSharesCalculator</mark> <mark>579_688</mark> <mark>700_000</mark>
<mark>3.</mark> <mark>Deploy</mark> <mark>FeeSplitter</mark> <mark>implementation</mark> <mark>1_127_359</mark> <mark>1_400_000</mark>
<mark>4.</mark> <mark>Upgrade and initialize</mark> <mark>FeeSplitter</mark> <mark>proxy</mark> <mark>112_009</mark> <mark>150_000</mark>
<mark>5.</mark> <mark>Deploy</mark> <mark>OperatorFeeVault</mark> <mark>implementation</mark> <mark>881_227</mark> <mark>1_200_000</mark>
<mark>6.</mark> <mark>Upgrade and initialize</mark> <mark>OperatorFeeVault</mark> <mark>proxy</mark> <mark>97_373</mark> <mark>150_000</mark>
<mark>7.</mark> <mark>Deploy</mark> <mark>SequencerFeeVault</mark> <mark>implementation</mark> <mark>883_547</mark> <mark>1_200_000</mark>
<mark>8.</mark> <mark>Upgrade and initialize</mark> <mark>SequencerFeeVault</mark> <mark>proxy</mark> <mark>94_851</mark> <mark>150_000</mark>
<mark>9.</mark> <mark>Deploy</mark> <mark>L1FeeVault</mark> <mark>implementation</mark> <mark>881_227</mark> <mark>1_200_000</mark>
<mark>10.</mark> <mark>Upgrade and initialize</mark> <mark>BaseFeeVault</mark> <mark>proxy</mark> <mark>97_373</mark> <mark>150_000</mark>
<mark>11.</mark> <mark>Upgrade and initialize</mark> <mark>L1FeeVault</mark> <mark>proxy</mark> <mark>97_373</mark> <mark>150_000</mark>


For the setupRevShare path, we used eth_call tracing to track the gas costs. We observed that the
gas consumed is around ~43173 which is less than SETTERS_GAS_LIMIT of 50_000 if the storage slot is
initially non-zero, but around ~60275 if the storage slot is zero which exceeds the SETTERS_GAS_LIMIT .
However, on a reasonable configuration none of the storage slots for the fee vaults or the fee splitter are
initially zero (not even FeeSplitter.setSharesCalculator as the initialized bit located in the same
slot as the sharesCalculator variable will be set).


**Recommendation:** All other gas costs are fine, but for the SETTERS_GAS_LIMIT, we recommend increasing it to 70_000 just in case any of the storage slots are initially zero.


**OP Labs:** [Fixed in PR 1308.](https://github.com/ethereum-optimism/superchain-ops/pull/1308)


**Cantina Managed:** Fix verified.


4


