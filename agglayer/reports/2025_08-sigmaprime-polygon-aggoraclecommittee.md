## Polygon

# **AggOracleCommittee Contract**

## **Security Assessment Report**

### _Version: 2.0_

**August, 2025**


### **Contents**

**Introduction** **2**
Disclaimer . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2
Document Structure . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2
Overview . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2


**Security Assessment Summary** **3**
Scope . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 3
Approach . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 3
Coverage Limitations . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 3
Findings Summary . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4


**Detailed Findings** **5**


**Summary of Findings** **6**
Oracles Can Remove Other Oracles’ Votes For A Consolidated GER . . . . . . . . . . . . . . . . 7
Restriction On GER Re-Voting May Prevent Recovery From Incorrect Removals . . . . . . . . . . 9
Missing Validation When Updating Quorum . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 12


**A** **Vulnerability Severity Classification** **13**


1


<u>AggOracleCommittee Contract</u> <u>Introduction</u>

### **Introduction**


Sigma Prime was commercially engaged to perform a time-boxed security review of the Polygon’s

`AggOracleCommittee` components in scope. The review focused solely on the security aspects of the Solidity implementation of the contract, though general recommendations and informational comments are also provided.


**Disclaimer**


Sigma Prime makes all effort but holds no responsibility for the findings of this security review. Sigma Prime
does not provide any guarantees relating to the function of the components in scope. Sigma Prime makes no
judgements on, or provides any security review, regarding the underlying business model or the individuals
involved in the project.


**Document Structure**


The first section provides an overview of the functionality of the Polygon components contained within the
scope of the security review. A summary followed by a detailed review of the discovered vulnerabilities
is then given which assigns each vulnerability a severity rating (see Vulnerability Severity Classification), an
_open/closed/resolved_ status and a recommendation. Additionally, findings which do not have direct security implications (but are potentially of interest) are marked as _informational_ .


The appendix provides additional documentation, including the severity matrix used to classify vulnerabilities
within the Polygon components in scope.


**Overview**


The `AggOracleCommittee` contract is responsible for managing the insertion of Global Exit Roots (GERs) into the

`GlobalExitRootManagerL2SovereignChain` <mark>.</mark>


It operates as an oracle-based system where multiple oracle members vote on proposed GERs, and once a quorum is reached, the GER is consolidated into the `GlobalExitRootManagerL2SovereignChain` . Each oracle will
have a single vote at a given time, meaning that an oracle cannot vote for 2 GERs simultaneously. Once a GER
reaches the required number of votes (quorum), that GER will be consolidated.


Page | 2


<u>AggOracleCommittee Contract</u> <u>Security Assessment Summary</u>

### **Security Assessment Summary**


**Scope**


[The review was conducted on the files hosted on the Agglayer repository.](https://github.com/agglayer)


[The scope of this time-boxed review was strictly limited to the following files at commit dc5bb8c:](https://github.com/agglayer/agglayer-contracts/blob/dc5bb8cc083f1e47b78ba3da836cd06384c0bc64/contracts/v2/sovereignChains/AggOracleCommittee.sol)


 - `contracts/v2/sovereignChains/AggOracleCommittee.sol`


 - `deployment/v2/utils/updateVanillaGenesis.ts`


 - `tools/createSovereignGenesis/create-sovereign-genesis.ts`


 - `tools/deployAggOracleCommittee/deployAggOracleCommittee.ts`


_Note: third party libraries and dependencies were excluded from the scope of this assessment._


**Approach**


The security assessment covered components written in Solidity.


The manual review focused on identifying issues associated with the business logic implementation of the contracts. This includes their internal interactions, intended functionality and correct implementation with respect
to the underlying functionality of the Ethereum Virtual Machine (for example, verifying correct storage/memory
layout).


Additionally, the manual review process focused on identifying vulnerabilities related to known Solidity antipatterns and attack vectors, such as re-entrancy, front-running, integer overflow/underflow and correct visibility
specifiers.


For a more detailed, but non-exhaustive list of examined vectors, see [1, 2].


To support the Solidity components of the review, the testing team may use the following automated testing
tools:


 - Aderyn: `[https://github.com/Cyfrin/aderyn](https://github.com/Cyfrin/aderyn)`


 - Slither: `[https://github.com/trailofbits/slither](https://github.com/trailofbits/slither)`


 - Mythril: `[https://github.com/ConsenSys/mythril](https://github.com/ConsenSys/mythril)`


Output for these automated tools is available upon request.


**Coverage Limitations**


Due to the time-boxed nature of this review, all documented vulnerabilities reflect best effort within the allotted,
limited engagement time. As such, Sigma Prime recommends to further investigate areas of the code, and any
related functionality, where majority of critical and high risk vulnerabilities were identified.


Page | 3


<u>AggOracleCommittee Contract</u> <u>Findings Summary</u>


**Findings Summary**


The testing team identified a total of 3 issues during this assessment. Categorised by their severity:


 - Medium: 2 issues.


 - Low: 1 issue.


Page | 4


<u>AggOracleCommittee Contract</u> <u>Detailed Findings</u>

### **Detailed Findings**


This section provides a detailed description of the vulnerabilities identified within the Polygon components in
scope. Each vulnerability has a severity classification which is determined from the likelihood and impact of each
issue by the matrix given in the Appendix: Vulnerability Severity Classification.


A number of additional properties of the components, including optimisations, are also described in this section
and are labelled as “informational”.


Each vulnerability is also assigned a **status** :


 - **_Open:_** the issue has not been addressed by the project team.


 - **_Resolved:_** the issue was acknowledged by the project team and updates to the affected components(s) have
been made to mitigate the related risk.


 - **_Closed:_** the issue was acknowledged by the project team but no further actions have been taken.


Page | 5


# **Summary of Findings**

### **ID Description Severity Status**

PAOC-01 Oracles Can Remove Other Oracles’ Votes For A Consolidated GER **Medium** **Closed**


Restriction On GER Re-Voting May Prevent Recovery From Incorrect
PAOC-02 **Medium** **Closed**
Removals


PAOC-03 Missing Validation When Updating Quorum **Low** **Closed**


6


<u>AggOracleCommittee Contract</u> <u>Detailed Findings</u>


**PAOC-01** Oracles Can Remove Other Oracles’ Votes For A Consolidated GER


Asset `AggOracleCommittee.sol`


Status **Closed:** See Resolution


Rating Severity: Medium Impact: High Likelihood: Low


**Description**


Oracle votes can unintentionally overwrite other oracles’ votes, undermining consensus integrity.


If an oracle re-votes for a previously consolidated Global Exit Root <mark>(</mark> <mark>`GER`</mark> <mark>)</mark>, for example, when a valid <mark>`GER`</mark> is mistakenly
removed from the `GlobalExitRootManagerL2SovereignChain` <mark>,</mark> the current vote tracking mechanism may cause other
oracles’ votes to be removed inadvertently or maliciously.


Consider the following scenario:


1. There are three oracle members: `[A,B,C]` <mark>,</mark> with a quorum of 2.


2. Oracle A votes for <mark>`GER1`</mark> <mark>,</mark> setting:


   - `addressToLastProposedGER[A]` `=` `GER1`


3. Oracle B also votes for <mark>`GER1`</mark> <mark>.</mark> This reaches the quorum, so:


   - <mark>`GER1`</mark> is consolidated


   - `addressToLastProposedGER[B]` `=` `INITIAL_PROPOSED_GER`

```
    if ( currentVotedReport . votes >= quorum ) {
       _consolidateGlobalExitRoot ( proposedGlobalExitRoot );
    } else {
       // Store submitted report with a new added vote

       proposedGERToReport [ proposedGlobalExitRoot ] = currentVotedReport ;

        // Store voted report hash

        addressToLastProposedGER [msg.sender] = proposedGlobalExitRoot ;
    }

```

4. The consolidated root is inserted into the `GlobalExitRootManagerL2SovereignChain` <mark>:</mark>

```
    if ( globalExitRootMap [ _newRoot ] == 0) {
       globalExitRootMap [ _newRoot ] = block.timestamp;
       //....

    }

```

5. Later, suppose <mark>`GER1`</mark> is removed (either intentionally or by mistake) via a call to

`GlobalExitRootManagerL2SovereignChain.removeGlobalExitRoots()` by `onlyGlobalExitRootRemover` :

```
    delete globalExitRootMap [ gerToRemove ];

```

6. Realising the mistake, Oracle B votes again for <mark>`GER1`</mark> . Because B’s previous vote was reset to
`INITIAL_PROPOSED_GER`, it is allowed to vote for <mark>`GER1`</mark> again. Now:


   - `addressToLastProposedGER[B]` `=` `GER1`


Page | 7


<u>AggOracleCommittee Contract</u> <u>Detailed Findings</u>


   - `proposedGERToReport[GER1].votes` `=` `1`


7. Oracle A now votes for a different root, <mark>`GER2`</mark> <mark>.</mark> Since A previously voted for <mark>`GER1`</mark>, the following logic reduces
<mark>`GER1`</mark> <mark>’</mark> s vote count:

```
    // If it's not the initial report hash, check last report voted

    if ( lastProposedGER != INITIAL_PROPOSED_GER ) {
       Report storage lastVotedReport = proposedGERToReport [

         lastProposedGER
       ];

       // Subtract a vote on the last voted report
       // That report could have 0 votes because:
       // - The report was already consolidated
       // - Were subtracted all the votes from that report

       if ( lastVotedReport . votes > 0) {
         unchecked {
            lastVotedReport . votes --;
         }
       }
    }

```

In scenario above, Oracle A’s new vote unintentionally removes Oracle B’s vote for <mark>`GER1`</mark> <mark>,</mark> despite B having voted
independently. This undermines vote integrity, allowing one oracle’s actions to affect another’s vote history and count,
potentially leading to incorrect consensus outcomes.


**Recommendations**


Update the vote tracking logic to prevent oracles from affecting the votes cast by the others.


**Resolution**


The finding has been closed with the following comment provided by the development team:


_"The_ _remove_ _global_ _exit_ _root_ _functionality_ _is_ _thought_ _as_ _a_ _recovery/excepctional_ _mechanism._ _So_ _won’t_ _be_ _an_
_automatic process. Also the oracles will be coded to always vote for the last GER available in L1 which is the one_
_that contains more information, and the other ones are redundant._


_In_ _the_ _scenario_ _where_ _we_ _want_ _to_ _delete_ _a_ _GER,_ _we_ _probably_ _stop_ _the_ _bridge,_ _remove_ _a_ _GER_ _and_ _consider_
_damages before restarting it._ _In all of this process a new GER will be available on L1 (either for a user deposit, or_
_because any chain has verified a proof) and the oracles will vote for that GER._


_So,_ _operationally_ _this_ _won’t_ _cause_ _any_ _additional_ _problem,_ _this_ _scenario_ _we_ _hope_ _that_ _is_ _extremely_ _weird,_
_and adding all the complexity to take in account removed GERs I think it’s an overkill for this particular case._


_An_ _important_ _part_ _of_ _this_ _is_ _that,_ _the_ _new_ _GER_ _always_ _contains_ _all_ _the_ _information_ _of_ _the_ _previous_ _ones,_
_meaning that, there’s not much relevance if one GER was skipped to be inserted and the new ones are the ones_
_that should be inserted since contain the new bridge information."_


Page | 8


<u>AggOracleCommittee Contract</u> <u>Detailed Findings</u>


**PAOC-02** Restriction On GER Re-Voting May Prevent Recovery From Incorrect Removals


Asset `AggOracleCommittee.sol`


Status **Closed:** See Resolution


Rating Severity: Medium Impact: High Likelihood: Low


**Description**


In the current implementation, once an oracle votes for a given Global Exit Root (GER) and it gets consolidated, the
same oracle is not allowed to vote for that GER again:

```
// Check if the proposed GER is not the same as the last voted report

require(
   lastProposedGER != proposedGlobalExitRoot,
   AlreadyVotedForThisGER ()
);

```

This introduces an edge case where an oracle may be forced to vote for an invalid GER, or not vote at all.


Consider the following scenario:


1. Suppose there are three oracle members: `[A,` `B,` `C]` <mark>,</mark> with a quorum set to 2.


2. Oracle A votes for <mark>`GER1`</mark> <mark>.</mark> As a result:


   - `addressToLastProposedGER[A]` `=` `GER1`


   - `proposedGERToReport[GER1].votes` `=` `1`


3. Oracle B then votes for <mark>`GER1`</mark> <mark>.</mark> Since the quorum is reached, <mark>`GER1`</mark> is consolidated. Now:


   - `addressToLastProposedGER[B]` `=` `INITIAL_PROPOSED_GER`


   - `proposedGERToReport[GER1].votes` `=` `0`


4. On the `GlobalExitRootManagerL2SovereignChain` <mark>,</mark> the following entry is made:


   - `globalExitRootMap[GER1]` `=` `block.timestamp`

```
    if ( globalExitRootMap [ _newRoot ] == 0) {
       globalExitRootMap [ _newRoot ] = block.timestamp;
       //...

    }

```

5. Later, <mark>`GER1`</mark> is removed, either mistakenly or maliciously, via `onlyGlobalExitRootRemover` <mark>,</mark> making:


   - `GlobalExitRootManagerL2SovereignChain.globalExitRootMap[GER1]` `=` `0`

```
    // Remove the GER from the map

    delete globalExitRootMap [ gerToRemove ];

```

6. Oracle C then votes for a new root, <mark>`GER2`</mark> :


Page | 9


<u>AggOracleCommittee Contract</u> <u>Detailed Findings</u>


   - `addressToLastProposedGER[C]` `=` `GER2`


   - `proposedGERToReport[GER2].votes` `=` `1`


7. Oracle B realizes that <mark>`GER1`</mark> was the correct root and attempts to vote for it again. Since its last vote was set to
`INITIAL_PROPOSED_GER`, it is allowed to vote for <mark>`GER1`</mark> <mark>,</mark> updating:


   - `addressToLastProposedGER[B]` `=` `GER1`


   - `proposedGERToReport[GER1].votes` `=` `1`


8. Oracle A also realizes <mark>`GER1`</mark> was the correct root and tries to vote for it again. However, because its

`addressToLastProposedGER[A]` is already <mark>`GER1`</mark> <mark>,</mark> the system reverts:

```
require(
   lastProposedGER != proposedGlobalExitRoot,
   AlreadyVotedForThisGER ()
);

```

Now, Oracle A is stuck with two bad options:


 - **Option 1** : Vote for <mark>`GER2`</mark> (to reset its last voted GER) and then re-vote for <mark>`GER1`</mark> . This introduces two issues:


**–** Since Oracle C already voted for <mark>`GER2`</mark> <mark>,</mark> voting for it again meets the quorum and consolidates an invalid

root.


**–** Voting for another GER resets the vote count for <mark>`GER1`</mark> <mark>,</mark> undoing Oracle B’s vote.


 - **Option 2** : Vote for an arbitrary new root like `GER3` just to reset state.


**–** This too reduces <mark>`GER1`</mark> <mark>’</mark> s vote count to zero by removing Oracle B’s vote, defeating the purpose of recovery.


**Recommendations**


Enhance the oracle voting logic by adding a mechanism that queries the state of `globalExitRootMap` from

`GlobalExitRootManagerL2SovereignChain` <mark>.</mark>


This would allow an oracle to re-vote for a GER if it has been previously removed, thus supporting recovery from
mistaken or malicious GER removals without corrupting the consensus process.


**Resolution**


The finding has been closed with the following comment provided by the development team:


_"The_ _remove_ _global_ _exit_ _root_ _functionality_ _is_ _thought_ _as_ _a_ _recovery/excepctional_ _mechanism._ _So_ _won’t_ _be_ _an_
_automatic process. Also the oracles will be coded to always vote for the last GER available in L1 which is the one_
_that contains more information, and the other ones are redundant._


_In_ _the_ _scenario_ _where_ _we_ _want_ _to_ _delete_ _a_ _GER,_ _we_ _probably_ _stop_ _the_ _bridge,_ _remove_ _a_ _GER_ _and_ _consider_
_damages before restarting it._ _In all of this process a new GER will be available on L1 (either for a user deposit, or_
_because any chain has verified a proof) and the oracles will vote for that GER._


Page | 10


<u>AggOracleCommittee Contract</u> <u>Detailed Findings</u>


_So,_ _operationally_ _this_ _won’t_ _cause_ _any_ _additional_ _problem,_ _this_ _scenario_ _we_ _hope_ _that_ _is_ _extremely_ _weird,_
_and adding all the complexity to take in account removed GERs I think it’s an overkill for this particular case._


_An_ _important_ _part_ _of_ _this_ _is_ _that,_ _the_ _new_ _GER_ _always_ _contains_ _all_ _the_ _information_ _of_ _the_ _previous_ _ones,_
_meaning that, there’s not much relevance if one GER was skipped to be inserted and the new ones are the ones_
_that should be inserted since contain the new bridge information."_


Page | 11


<u>AggOracleCommittee Contract</u> <u>Detailed Findings</u>


**PAOC-03** Missing Validation When Updating Quorum


Asset `AggOracleCommittee.sol`


Status **Closed:** See Resolution


Rating Severity: Low Impact: Low Likelihood: Low


**Description**


During contract initialisation, a check ensures the quorum does not exceed the number of oracle members:

```
require(
   _quorum <= _aggOracleMembers . length,
   QuorumCannotBeGreaterThanAggOracleMembers ()
);

```

However, this constraint is missing in the `updateQuorum` function, allowing the owner to set a quorum higher than the
current number of oracle members:

```
function updateQuorum (uint64 newQuorum ) external onlyOwner {
   require( newQuorum != 0, QuorumCannotBeZero ());

   quorum = newQuorum ;
   emit UpdateQuorum ( newQuorum );
}

```

This could lead to a scenario where achieving quorum is impossible, effectively blocking any action that depends on it.


**Recommendations**


Add a validation in the `updateQuorum` function to ensure the new quorum does not exceed the current number of
oracle members.


**Resolution**


The finding has been closed with the following comment provided by the development team:


_"Yes_ _we_ _don’t_ _check_ _that_ _since_ _we_ _want_ _to_ _give_ _the_ _maximum_ _flexibility_ _to_ _the_ _owner._ _And_ _putting_ _this_ _check_
_could make some operations more difficult._


_(Consider_ _the_ _scenario)_ _I_ _have_ _a_ _quorum_ _3/5_ _and_ _I_ _want_ _not_ _a_ _5/7._ _If_ _I_ _first_ _add_ _the_ _oracle_ _participants_
_and then update the quorum, the contract will be unsecure until the quorum will be updated, since for a moment_
_I will have a 3/7, and there are new, potentially malicious, oracle participants."_


Page | 12


<u>AggOracleCommittee Contract</u> <u>Vulnerability Severity Classification</u>

### **Appendix A Vulnerability Severity Classification**


This security review classifies vulnerabilities based on their potential impact and likelihood of occurance. The total
severity of a vulnerability is derived from these two metrics based on the following matrix.


High Medium High Critical


Medium Low Medium High


Low Low Low Medium


Low Medium High


**Likelihood**


Table 1: Severity Matrix - How the severity of a vulnerability is given based on the _impact_ and the _likelihood_ of a
vulnerability.

### **References**


[1] Sigma Prime. Solidity Security. Blog, 2018, Available: `[https://blog.sigmaprime.io/solidity-security.html](https://blog.sigmaprime.io/solidity-security.html)` . [Ac
cessed 2018].


[2] NCC Group. DASP - Top 10. Website, 2018, Available: `[http://www.dasp.co/](http://www.dasp.co/)` . [Accessed 2018].


Page | 13


