### **Audit** **Competition**
###### Summary Report November 2024



1


#### **Content Index**


 - Overview


 - Scope of Assets


 - Summary


 - Leaderboard


 - Top 3 Reports



3


4


5


6


8



2


#### **Overview**

Immunefi Audit Competitions are special,
time-limited events that supercharge the
reach and visibility of programs to our
whitehat community.


From November 13 to December 6, 2024, the
Celo Competition offered up to $50,000 USD in
rewards for security researchers.


Immunefi’s Discord server hosted a channel
for enhanced, two-way communication
between whitehats and the Celo team,
improving feedback and response times.
Managed Triaging was also activated for the
duration of this event, streamlining the
resolution process for incoming bug reports.



During this event, 1 low/medium bugs, 3 high,
3 critical, and 1 insight reports were found on
the target contracts. A total of 22 security
researchers participated.


Celo distributed the $50k reward pool to 8 of
the very best submissions for the security
researchers’ valiant efforts, including “Insight”
submissions scored on a rating system that
takes into account levels of:


1) Security best practices
2) Code optimizations and enhancements
3) Architectural decentralization and
composability
4) Documentation improvements



3


#### **Celo Introduction**

Celo is on a mission is to build a regenerative digital economy that creates conditions of prosperity for all.


For more information about Celo, please visit <u><mark>[https://celo.org/](https://celo.org/)</mark></u>


Celo provides rewards in cUSD, denominated in USD.

#### **Scope Of Assets**

The target assets in scope for the Audit Competition included Celo’s smart contracts, specifically
the Staked contracts and the Multisig architecture.


The total nSLOC was 5,253.



4


#### **Summary**



Duration:
**Three weeks**



Comp Date:
**13 Nov - 6 Dec**
**2024**


Security
researchers:

**22**



Rewards Pool:

**$50,000**



nSLOC:

**5,253**



Submitted



Valid
vulnerabilities:

**7**



Insight reports:

**1**



reports:



**57**



5


#### **Total Whitehat** **Participation** Leaderboard


##### **22**

Total Researchers

##### **4**

Paid Researchers



<u>Position</u> <u>Reward</u> <u>Username</u> <u>Valids</u> <u>Insights</u>


<u>1</u> <u>$20,767</u> <u>innertia</u> <u>3</u> <u>0</u>


<u>2</u> <u>$15,387</u> <u>jovi</u> <u>2</u> <u>1</u>


<u>3</u> <u>$10,309</u> <u>shadowHunter</u> <u>1</u> <u>0</u>


<u>4</u> <u>$3,535</u> <u>okmxuse</u> <u>1</u> <u>0</u>



6


## **Top 3 Reports**

**Fraudulent padding of governance voting**
**power**



**Report number:** <u>3</u> <u><mark>[7251](https://reports.immunefi.com/celo/37251-sc-critical-fraudulent-padding-of-governance-voting-power)</mark></u>


**Submitted by:** <u><mark>[@innertia](https://immunefi.com/profile/innertia)</mark></u>


**Target:**
<u>[https://github.com/celo-org/celo-monorepo](https://github.com/celo-org/celo-monorepo/blob/release/core-contracts/12/packages/protocol/contracts/governance/LockedGold.sol)</u>
<u>[/blob/release/core-contracts/12/packages/](https://github.com/celo-org/celo-monorepo/blob/release/core-contracts/12/packages/protocol/contracts/governance/LockedGold.sol)</u>
<u>[protocol/contracts/governance/LockedGold.](https://github.com/celo-org/celo-monorepo/blob/release/core-contracts/12/packages/protocol/contracts/governance/LockedGold.sol)</u>
<u>[sol](https://github.com/celo-org/celo-monorepo/blob/release/core-contracts/12/packages/protocol/contracts/governance/LockedGold.sol)</u>


**Impacts:**

 - Manipulation of governance voting
results deviating from the outcome
and resulting in direct change from
intended effect of original results


**Program Action:** Confirmed as critical
severity.



**Report Excerpt:**


A Slash reduces or increases a user’s
nonvoting balance. However, there is no
processing related to delegate. This can
cause various vulnerabilities including;
Inflating the number of votes and
Withdrawing tokens while maintaining the
number of votes etc.



7


#### **Rollback of the incorrect state** **interferes with the progress of the** **epoch process, prevents the user from** **receiving rewards, blocks the launch** **of the associated contract function etc**



**Report number** : <u>[37010](https://reports.immunefi.com/celo/37010-sc-high-rollback-of-the-incorrect-state-interferes-with-the-progress-of-the-epoch-process-prev)</u>


**Submitted by:** <u><mark>[@innertia](https://immunefi.com/profile/innertia)</mark></u>


**Target:**
<u>[https://github.com/celo-org/celo-monorepo](https://github.com/celo-org/celo-monorepo/blob/release/core-contracts/12/packages/protocol/contracts-0.8/common/EpochManager.sol)</u>
<u>[/blob/release/core-contracts/12/packages/](https://github.com/celo-org/celo-monorepo/blob/release/core-contracts/12/packages/protocol/contracts-0.8/common/EpochManager.sol)</u>
<u>[protocol/contracts-0.8/common/EpochMan](https://github.com/celo-org/celo-monorepo/blob/release/core-contracts/12/packages/protocol/contracts-0.8/common/EpochManager.sol)</u>
<u>[ager.sol](https://github.com/celo-org/celo-monorepo/blob/release/core-contracts/12/packages/protocol/contracts-0.8/common/EpochManager.sol)</u>


**Impacts:**

 - Temporary freezing of funds

 - Smart contract unable to operate due
to lack of token funds

 - Griefing - Issuance of an unauthorized
amount of StableToken (not to the
attacker)

 - Blocking of execution of functions of
other contracts


**Program Action:** Confirmed as high severity.



**Report Excerpt:**


EpochProcess is managed by
EpochProcessStatus, which has three
statuses: NotStarted, Started, and
IndivudualGroupsProcessing. They should
change and cycle in this order, and each
status has a different function that can be
started.


However, after being changed from Started
to IndivudualGroupsProcessing, there is a
function launch route that reverts back to
Started. This causes various problems such
as prevents the user from receiving rewards,
blocks the launch of the associated contract
function, etc.



8


#### **Overflow due to lack of checks leading** **to incorrect price calculations**



**Report number** : <u>[37206](https://reports.immunefi.com/celo/37206-sc-medium-overflow-due-to-lack-of-checks-leading-to-incorrect-price-calculation)</u>


**Submitted by:** <u><mark>[@okmxuse](https://immunefi.com/profile/okmxuse)</mark></u>


**Target:**
<u>[https://github.com/celo-org/optimism](https://github.com/celo-org/optimism/blob/celo10/op-chain-ops/cmd/check-derivation/main.go)</u>
<u>[/blob/celo10/op-chain-ops/cmd/chec](https://github.com/celo-org/optimism/blob/celo10/op-chain-ops/cmd/check-derivation/main.go)</u>
<u>[k-derivation/main.go](https://github.com/celo-org/optimism/blob/celo10/op-chain-ops/cmd/check-derivation/main.go)</u>


**Impacts:**

 - Smart contract unable to operate
due to lack of token funds


**Program Action:** Confirmed as medium
severity.



**Report Excerpt:**


Inside the check-derivation/main.go
function, the
getRandomSignedTransaction function
is invoked (note that this function traces
all the way back to checkConsolidation
which is then called in the main.go
function ).
getRandomSignedTransaction calls
IntrinsicGas at three places. We will
focus on the one that includes the
accessList, which is case

types.AccessListTxType


# **End of Report**



9


