# Security Review

## Cantina Managed COINBASE: CONTRACTS DYNAMIC UP- GRADES

#### Cantina Managed review by: Sujith S, Lead Security Researcher Cryptara, Security Researcher

### September 19, 2026


#### **Contents**

**1** **Introduction** **2**
1.1 About Cantina . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2
1.2 Disclaimer . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2
1.3 Risk assessment . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2
1.3.1 Severity Classification . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2


**2** **Security Review Summary** **3**
2.1 Scope . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 3


**3** **Findings** **4**
3.1 Medium Risk . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4
3.1.1 Truncated initial schedules make the node and verifier commit to different histories 4
3.2 Low Risk . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 5
3.2.1 Clearing an upgrade under a scheduled successor permanently holes the id . . . . 5
3.2.2 Asymmetric timestamp checks prevent simultaneous upgrades from being delayed
together . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 6
3.2.3 Imported schedules leave the node-required minimum protocol version unset . . . 7
3.2.4 Initialization can make a near-term activation immutable before nodes observe it . 8
3.2.5 A permitted emergency schedule change can reach nodes after the old upgrade
has activated . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 9
3.3 Informational . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 10
3.3.1 NatSpec claims L1-origin pinning and journal domain fields <mark>AggregateVerifier</mark>
does not implement . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 10
3.3.2 <mark>AggregateVerifier</mark> comment still describes freeze-at-activation semantics . . . 10

3.3.3 Initialization proof L1 origin is unbound from the factory <mark>l1Head</mark> . . . . . . . . . . 11


Cantina Managed 1 September 19, 2026


#### **1 Introduction**

**1.1** **About Cantina**


Cantina is a security platform that pairs a world-class network of security researchers with agentic AI
to help teams building onchain find and fix real risk. Through managed reviews, competitions, and
bounties, Cantina secures protocols before vulnerabilities can be exploited.
[Learn more at cantina.security](https://cantina.security)


**1.2** **Disclaimer**


Cantina Managed provides a detailed evaluation of the security posture of the code at a particular
moment based on the information available at the time of the review. While Cantina Managed endeavors
to identify and disclose all potential security issues, it cannot guarantee that every vulnerability will
be detected or that the code will be entirely secure against all possible attacks. The assessment
is conducted based on the specific commit and version of the code provided. Any subsequent
modifications to the code may introduce new vulnerabilities that were absent during the initial review.
Therefore, any changes made to the code require a new security review to ensure that the code
remains secure. Please be advised that the Cantina Managed security review is not a replacement for
continuous security measures such as penetration testing, vulnerability scanning, and regular code
reviews.


**1.3** **Risk assessment**


**<u>Severity level</u>** **<u>Impact:</u>** **<u>High</u>** **<u>Impact:</u>** **<u>Medium</u>** **<u>Impact:</u>** **<u>Low</u>**

**<u>Likelihood:</u>** **<u>high</u>** <u>Critical</u> <u>High</u> <u>Medium</u>

**<u>Likelihood:</u>** **<u>medium</u>** <u>High</u> <u>Medium</u> <u>Low</u>

**<u>Likelihood:</u>** **<u>low</u>** <u>Medium</u> <u>Low</u> <u>Low</u>


**1.3.1** **Severity Classification**


The severity of security issues found during the security review is categorized based on the above
table. Critical findings have a high likelihood of being exploited and must be addressed immediately.
High findings are almost certain to occur, easy to perform, or not easy but highly incentivized thus
must be fixed as soon as possible.


Medium findings are conditionally possible or incentivized but are still relatively likely to occur and
should be addressed. Low findings are a rare combination of circumstances to exploit, or offer little to
no incentive to exploit but are recommended to be addressed.


Lastly, some findings might represent objective improvements that should be addressed but do not
impact the project’s overall security (Gas and Informational findings).


Cantina Managed 2 September 19, 2026


#### **2 Security Review Summary**

Base is a secure, low-cost, builder-friendly Ethereum L2 built to bring the next billion users onchain.


From Aug 19th to Aug 21st the Cantina team conducted a review of [contracts](https://github.com/base/contracts) on commit hash
[4f7acda5. The team identified a total of](https://github.com/base/contracts/tree/4f7acda51dba4165361b292ae08c119f5bfa1f0d/) **9** issues:


**Issues Found**


**<u>Severity</u>** **<u>Count</u>** **<u>Fixed</u>** **<u>Acknowledged</u>**

<u>Critical Risk</u> <u>0</u> <u>0</u> <u>0</u>

<u>High Risk</u> <u>0</u> <u>0</u> <u>0</u>

<u>Medium Risk</u> <u>1</u> <u>0</u> <u>1</u>

<u>Low Risk</u> <u>5</u> <u>5</u> <u>0</u>

<u>Gas Optimizations</u> <u>0</u> <u>0</u> <u>0</u>

<u>Informational</u> <u>3</u> <u>3</u> <u>0</u>

**<u>Total</u>** **<u>9</u>** **<u>8</u>** **<u>1</u>**


**2.1** **Scope**


[The security review had the following components in scope for contracts on commit hash 4f7acda5:](https://github.com/base/contracts)


src/L1
├── ProtocolVersions.sol
└── proofs

└── AggregateVerifier.sol


Cantina Managed 3 September 19, 2026


#### **3 Findings**

**3.1** **Medium Risk**


**3.1.1** **Truncated initial schedules make the node and verifier commit to different histories**


**Severity:** Medium Risk.


**Context:** [ProtocolVersions.sol#L149.](https://cantina.xyz/code/83d4667b-fefe-4491-a430-5436afb37f64/src/L1/ProtocolVersions.sol#L149)


**Description:** The initial schedule is a positional cross-system commitment, but neither <mark>Deploy</mark>


<mark>Config</mark> nor <mark>ProtocolVersions.initialize()</mark> checks that the array contains an entry for every
contract-backed upgrade known to the node. A proper prefix is therefore accepted as a complete
schedule and permanently registers only that prefix onchain.


The two sides interpret the missing suffix differently. <mark>ProtocolVersions.activatedScheduleId()</mark>

can only hash entries present in <mark>_timestamps</mark>, whereas the node zips the supplied prefix onto its

existing <mark>RollupConfig</mark> . Omitted upgrades receive no explicit <mark>Never</mark> override, so their static activa
tion timestamps remain effective. <mark>ScheduleId::pin()</mark> subsequently walks all thirteen <mark>BaseUpgrade:</mark>


<mark>:CONTRACT_VARIANTS</mark> and includes any active static suffix. Once an omitted fork is active, the verifier

pins one schedule ID while honest TEE and ZK provers derive another. Because <mark>scheduleId</mark> is part
of both proof journals, every honest proof is rejected and aggregate games cannot make progress.
Setting a valid <mark>minimumProtocolVersion</mark> fixes the separate startup gate but does not repair this
commitment mismatch.


**Proof of Concept:** The first four entries below are a correctly ordered Base mainnet prefix, but the
later known entries through Beryl are omitted. Add this test to <mark>ProtocolVersions_ActivatedSchedule</mark>


<mark>Id_Test</mark> in <mark>test/L1/ProtocolVersions.t.sol</mark> :


**function** test_truncatedInitialSchedule_divergesFromNodeHistory() **external** {

**uint64** [] **memory** prefix = **new** **uint64** [](4);
prefix[0] = 1_686_789_347; // Regolith, normalized to the L2 genesis timestamp.
prefix[1] = 1_704_992_401; // Canyon.
prefix[2] = 1_708_560_000; // Delta.
prefix[3] = 1_710_374_401; // Ecotone.


IProtocolVersions truncated = _importSchedule(prefix);


**bytes32** contractScheduleId =

_�→_ truncated.activatedScheduleId(BASE_MAINNET_BERYL_TIMESTAMP);
**bytes32** nodeScheduleId =

0xadd4aa9bd3532969035a9543c16b8c7d71298e15836f0ac731fdd3eea552c6e2;


// The contract stops after Ecotone (id 3).
assertEq(

contractScheduleId,
0xd694b06480e4f65f86d9d2a7be6a0d34149ef0bd0eae338f3a26d769911bc0a8
);


// The node retains its static Fjord..Beryl suffix and hashes through id 11.
assertNotEq(contractScheduleId, nodeScheduleId);
}


The <mark>nodeScheduleId</mark> value is the existing cross-implementation Base mainnet golden produced

by <mark>ScheduleId::pin()</mark> at Beryl. <mark>AggregateVerifier.initializeWithInitData()</mark> stores <mark>contract</mark>


<mark>ScheduleId</mark>, while the proof boot path journals <mark>nodeScheduleId</mark> ; the final journal hashes therefore
differ even when every other proof input is identical.


**Recommendation:** For migrations, generate the imported array from the node's complete effective
contract-backed schedule and require explicit zero entries for known but unscheduled upgrades.
Reject nonempty proper prefixes, verify the resulting onchain schedule ID against a node-generated


Cantina Managed 4 September 19, 2026


value before enabling the game type, and make nodes reject incomplete authoritative arrays instead
of silently falling back to static suffix values.


**Coinbase:** The deployment of <mark>ProtocolVersions</mark> will happen in our contract-deployments repo and
will have its own security review. I don't think we need a base/contracts change for this.


**Cantina Managed:** Acknowledged.


**3.2** **Low Risk**


**3.2.1** **Clearing an upgrade under a scheduled successor permanently holes the id**


**Severity:** Low Risk.


**Context:** [ProtocolVersions.sol#L227-L242, ProtocolVersions.sol#L372-L376.](https://cantina.xyz/code/83d4667b-fefe-4491-a430-5436afb37f64/src/L1/ProtocolVersions.sol#L227-L242)


**Description:** The function <mark>setTimestamp()</mark> forbids filling a zero-valued hole once a later upgrade is
already scheduled, but clearing an earlier upgrade to zero is unrestricted:


**function** setTimestamp( **uint256** id, **uint64** timestamp) **external** {

// ...
**if** (timestamp != 0) {

**if** (current == 0) _assertNoScheduledSuccessor(id);
_assertTimestampAfterPrevious(id, timestamp);
_assertTimestampBeforeNext(id, timestamp);
}
_writeTimestamp(id, timestamp);
}


<mark>_assertNoScheduledSuccessor</mark> therefore runs only on the <mark>0</mark> <mark>→</mark> <mark>nonzero</mark> path. Passing


<mark>timestamp</mark> <mark>==</mark> <mark>0</mark> always proceeds to <mark>_writeTimestamp</mark>, which refreshes the hash chain from that
id onward.


After clearing upgrade A while successor B remains scheduled:


1. <mark>scheduleId</mark> / <mark>activatedScheduleId</mark> for affected cutoffs change and embed <mark>(id_A,</mark> <mark>0)</mark> in
the prefix.


2. Re-scheduling A reverts <mark>ProtocolVersions_StaticScheduleHole</mark> until every higher scheduled
successor is cleared first.


This contradicts the NatSpec on <mark>activatedScheduleId</mark>, which states that zero-valued holes below a
scheduled successor cannot be scheduled later in order to prevent inactive prefix holes from moving
activated schedule commitments. The fill-side guard enforces half of that claim; the clear-side path
falsifies it.


Under <mark>FREEZE_WINDOW</mark> and <mark>AggregateVerifier</mark> ’s <mark>L2TimestampInFuture</mark> check, an upgrade that
could appear in a creatable proof-game pin is already frozen, so this does not create divergent pins
across creatable <mark>AggregateVerifier</mark> games. The residual issue is an owner-gated operational footgun with a permanent recovery cost until successors are cleared, plus the documentation mismatch.


**Proof of Concept:**


**function** test_clearUnderSuccessor_changesActivatedPrefixAndFreezesHole() **public** {

**uint64** l1Now = 3_000_000;
vm.warp(l1Now);


**uint64** t0 = l1Now + protocolVersions.MIN_NOTICE() + 100;
**uint64** t1 = l1Now + protocolVersions.MIN_NOTICE() + 200;


vm.startPrank(owner);
protocolVersions.registerUpgrade(t0, 0);
protocolVersions.registerUpgrade(t1, 0);
vm.stopPrank();


Cantina Managed 5 September 19, 2026


**bytes32** beforeClear = protocolVersions.activatedScheduleId(t1);
**bytes32** link0 = keccak256(abi.encode( **bytes32** (0), **uint256** (0), t0));
**bytes32** link1 = keccak256(abi.encode(link0, **uint256** (1), t1));
assertEq(beforeClear, link1);


vm.prank(owner);
protocolVersions.setTimestamp(0, 0);


**bytes32** hole0 = keccak256(abi.encode( **bytes32** (0), **uint256** (0), **uint64** (0)));
**bytes32** link1Hole = keccak256(abi.encode(hole0, **uint256** (1), t1));
assertEq(protocolVersions.activatedScheduleId(t1), link1Hole);
assertNotEq(beforeClear, link1Hole);


**uint64** refill = l1Now + protocolVersions.MIN_NOTICE() + 150;
vm.expectRevert(

abi.encodeWithSelector(ProtocolVersions.ProtocolVersions_StaticScheduleHole _⌋_



_�→_



.selector, 0,
1)



_�→_ 1)
);
vm.prank(owner);
protocolVersions.setTimestamp(0, refill);
}



The test passes.


**Recommendation:** On clear-to-zero, enforce the same successor check used when filling a hole:


**if** (timestamp == 0) {

_assertNoScheduledSuccessor(id);
} **else** {

**if** (current == 0) _assertNoScheduledSuccessor(id);
_assertTimestampAfterPrevious(id, timestamp);
_assertTimestampBeforeNext(id, timestamp);
}


Alternatively, expose an explicit multi-id cancel path that documents recovery, and update the

<mark>activatedScheduleId</mark> NatSpec so it no longer claims clear-under-successor is impossible.


**Coinbase:** [Fixed in PR 415.](https://github.com/base/contracts/pull/415)


**Cantina Managed:** [PR 415 resolves the owner-gated footgun and the NatSpec overclaim in](https://github.com/base/contracts/pull/415) <mark>activated</mark>


<mark>ScheduleId</mark> . Cross-game divergence through this path is not possible: clearing is only permitted

while <mark>L1</mark> <mark><</mark> <mark>activation</mark> <mark>-</mark> <mark>FREEZE_WINDOW</mark>, but an <mark>AggregateVerifier</mark> game against that activation

requires <mark>L1</mark> <mark>>=</mark> <mark>activation</mark>, so the two windows never overlap; additionally, <mark>GameAlreadyExists</mark>
prevents a replacement proposal from being re-created after a clear.


**3.2.2** **Asymmetric timestamp checks prevent simultaneous upgrades from being delayed together**


**Severity:** Low Risk.


**Context:** [ProtocolVersions.sol#L239.](https://cantina.xyz/code/83d4667b-fefe-4491-a430-5436afb37f64/src/L1/ProtocolVersions.sol#L239)


**Description:** The function <mark>registerUpgrade()</mark> allows consecutive upgrades to share an activa
tion timestamp, but <mark>_assertTimestampBeforeNext()</mark> rejects setting an earlier upgrade to the same
timestamp as its successor.


Consequently, the incident responder cannot delay simultaneous upgrades while preserving their
atomic activation, requiring owner intervention or split timestamps.


**Recommendation:** Allow equality in the forward-ordering check and add tests covering equal timestamps in both <mark>setTimestamp()</mark> and <mark>delayTimestamp()</mark> .


Cantina Managed 6 September 19, 2026


**Coinbase:** [Fixed in PR 419.](https://github.com/base/contracts/pull/419)


**Cantina Managed:** Fix verified.


**3.2.3** **Imported schedules leave the node-required minimum protocol version unset**


**Severity:** Low Risk.


**Context:** [ProtocolVersions.sol#L134.](https://cantina.xyz/code/83d4667b-fefe-4491-a430-5436afb37f64/src/L1/ProtocolVersions.sol#L134)


**Description:** <mark>ProtocolVersions.initialize()</mark> imports <mark>_initialSchedule</mark> but never initializes


<mark>minimumProtocolVersion</mark> . The standard deployment path calls only this initializer, so deploying
an existing chain with any historical activation leaves a positive schedule paired with the default
minimum version of zero.


That state is valid to the contract but invalid to the Base node. <mark>AlloyUpgradeSignalReader::map_</mark>


<mark>schedule()</mark> attaches the global minimum version to every imported timestamp, and <mark>UpgradeSignal</mark>


<mark>Config::validate_signal_has_protocol_version()</mark> rejects every positive timestamp whose version

is zero. Startup uses <mark>read_validated_schedule()</mark> before applying either the execution or consensus
schedule, so production nodes configured to consume the newly deployed registry fail to start. The
runtime refresh path rejects the schedule for the same reason. Recovery requires a separate owner
transaction to set the version, leaving an avoidable outage window during migration.


**Proof of Concept:** Add the following test to <mark>ProtocolVersions_Initialize_Test</mark> in <mark>test/L1/Prot</mark>


<mark>ocolVersions.t.sol</mark> :


**function** test_initialize_importLeavesMinimumProtocolVersionUnset() **external** {

**uint64** [] **memory** schedule = **new** **uint64** [](1);
schedule[0] = 1;


IProtocolVersions imported = _deployUninitializedProxy();
vm.prank(EIP1967Helper.getAdmin( **address** (imported)));
imported.initialize(_incidentResponder, schedule);


assertGt(imported.getSchedule()[0], 0);
assertEq(imported.minimumProtocolVersion(), 0);
}


The test passes. The resulting values are then mapped by the node into an <mark>UpgradeSignal</mark> with


<mark>activation_timestamp</mark> <mark>=</mark> <mark>1</mark> and <mark>protocol_version</mark> <mark>=</mark> <mark>0</mark>, which deterministically hits the following
startup validation:


**if** signal.activation_timestamp  - 0 && signal.protocol_version == U256::ZERO {

**return** Err(UpgradeSignalError::missing_protocol_version(

signal.upgrade_id.contract_id().to_string(),
));
}


<mark>SystemDeploy._initializeOPChain()</mark> does not make a subsequent <mark>setMinimumProtocolVersion()</mark>
call, so this is also the final state produced by the standard deployment flow.


**Recommendation:** Add an initial minimum protocol version to the initializer and deployment configuration, and set it atomically with the imported schedule. Initialization should revert when any imported
timestamp is nonzero and the supplied minimum version is zero; the deployment script should also
assert the post-deployment schedule and minimum version before completing.


**Coinbase:** [Fixed in PR-420 and PR-435.](https://github.com/base/contracts/pull/420)


**Cantina Managed:** Verified fix. PR-420 did not fully mitigate the finding, as zero minimum protocol
versions remained possible through alternative code paths. Following our request, PR-435 added the
necessary safeguards and fully resolves the issue.


Cantina Managed 7 September 19, 2026


**3.2.4** **Initialization can make a near-term activation immutable before nodes observe it**


**Severity:** Low Risk.


**Context:** [ProtocolVersions.sol#L124-L128.](https://cantina.xyz/code/83d4667b-fefe-4491-a430-5436afb37f64/src/L1/ProtocolVersions.sol#L124-L128)


**Description:** <mark>initialize()</mark> intentionally bypasses <mark>MIN_NOTICE</mark> so historical activations can be
imported, but it applies the exemption to every timestamp, including future ones. A deployment
can therefore import an activation at or inside <mark>block.timestamp</mark> <mark>+</mark> <mark>FREEZE_WINDOW</mark> . The timestamp is
accepted and immediately becomes impossible for either the owner or incident responder to clear or
delay because all later mutations call <mark>_assertNotFrozen()</mark> .


Nodes read the registry at the finalized L1 head by default. A near-term activation can consequently
take effect before the initialization transaction is finalized and observed by the fleet, leaving running
nodes on the old rules while newly started nodes apply the imported schedule. Besides a consensus
split or outage at the activation boundary, retroactive application can miss fork-specific one-time
transition transactions. The emergency role cannot recover the network because the timestamp was
frozen at the moment it was created.


**Proof of Concept:** Add the following test to <mark>ProtocolVersions_Initialize_Test</mark> in <mark>test/L1/Prot</mark>


<mark>ocolVersions.t.sol</mark> :


**function** test_initialize_acceptsAlreadyFrozenFutureActivation() **external** {

vm.warp(1_800_000_000);


**uint64** activation = **uint64** ( **block.timestamp** ) + protocolVersions.FREEZE_WINDOW();
**uint64** [] **memory** schedule = **new** **uint64** [](1);
schedule[0] = activation;


IProtocolVersions imported = _deployUninitializedProxy();
vm.prank(EIP1967Helper.getAdmin( **address** (imported)));
imported.initialize(_incidentResponder, schedule);


assertEq(imported.getSchedule()[0], activation);


vm.expectRevert(

abi.encodeWithSelector(

IProtocolVersions.ProtocolVersions_ActivationFrozen.selector,
**uint256** (0),
activation
)
);
vm.prank(_incidentResponder);
imported.delayTimestamp(0, activation + imported.MIN_NOTICE());


vm.expectRevert(

abi.encodeWithSelector(

IProtocolVersions.ProtocolVersions_ActivationFrozen.selector,
**uint256** (0),
activation
)
);
vm.prank(_owner);
imported.setTimestamp(0, 0);
}


The initializer accepts the future activation, and both recovery paths revert in the same block.


**Recommendation:** Keep the initializer exemption only for historical timestamps. Any nonzero imported timestamp greater than <mark>block.timestamp</mark> should satisfy the same <mark>MIN_NOTICE</mark> requirement

as <mark>registerUpgrade()</mark> and <mark>setTimestamp()</mark> ; alternatively, require future upgrades to be registered
only after initialization.


Cantina Managed 8 September 19, 2026


**Coinbase:** [Fixed in PR 421.](https://github.com/base/contracts/pull/421)


**Cantina Managed:** Fix verified.


**3.2.5** **A permitted emergency schedule change can reach nodes after the old upgrade has activated**


**Severity:** Low Risk.


**Context:** [ProtocolVersions.sol#L368.](https://cantina.xyz/code/83d4667b-fefe-4491-a430-5436afb37f64/src/L1/ProtocolVersions.sol#L368)


**Description:** <mark>ProtocolVersions</mark> allows an upgrade scheduled for A to be cleared or delayed at


<mark>A</mark> <mark>-</mark> <mark>1801</mark> . A <mark>RuntimeAdmin</mark> node using the default <mark>Finalized</mark> block tag may take a nominal 27
minutes 48 seconds to observe the change: 12 minutes 48 seconds for finality plus up to 15 minutes
for its next poll.


Under that nominal timing, the mutation is observed at approximately <mark>A</mark> <mark>-</mark> <mark>133</mark>, so the boundary
alone does not prove late application. The issue occurs if permitted timestamp drift has already taken
the L2 head past A, or if finality or delivery exceeds the nominal estimate. Upgrade signalling defaults

to <mark>MetricsOnly</mark>, so only nodes explicitly configured to apply runtime updates are affected.


Once observed, the node applies the amended schedule without comparing it to its current L2 head.
This does not immediately rewrite stored blocks, but later execution, replay, derivation, reorg handling,
synchronization, or proving may interpret affected blocks under different fork rules and reject them or
halt.


**Proof of Concept:** The existing test confirms that the last second before the freeze window remains
mutable:


**uint64** activation = _scheduleCanyon(100);


vm.warp(activation  - protocolVersions.FREEZE_WINDOW()  - 1);
vm.prank(_owner);
protocolVersions.setTimestamp(CANYON, 0);


assertEq(protocolVersions.getSchedule()[CANYON], 0);


Run it with:


forge test --match-test test_setTimestamp_justBeforeFreezeWindow_succeeds


At <mark>A</mark> <mark>-</mark> <mark>1801</mark>, the nominal finalized observation time is <mark>A</mark> <mark>-</mark> <mark>133</mark> . The unsafe case is therefore condi
tional on the L2 head already being at or beyond A, or on observation taking longer than the nominal

estimate. <mark>UpgradeSignalRefresher::apply()</mark> and <mark>apply_schedule_to_sink()</mark> receive no current
L2-head timestamp and cannot reject such a late change.


**Recommendation:** At startup and during runtime refresh, reject or safely halt on any schedule change
that would alter fork rules at or before the current L2 head. Also use a schedule-freshness gate or
a reorg-aware safe/latest read near activation; increasing the Solidity freeze window alone cannot
account for unbounded L1 finality delays.


**Coinbase:** [Fixed in PR-424.](https://github.com/base/contracts/pull/424) Furthermore, the sequencers can be updated to use safe head polling as a
runtime config.


**Cantina** **Managed:** Verified fix. PR-424 extends the freeze window to one hour, while sequencers
will use safe-head polling through runtime configuration. Together, these measures address the
late-application risk, no additional code changes are required.


Cantina Managed 9 September 19, 2026


**3.3** **Informational**


**3.3.1** **NatSpec claims L1-origin pinning and journal domain fields** **<mark>AggregateVerifier</mark>** **does not im-**
**plement**


**Severity:** Informational.


**Context:** [AggregateVerifier.sol#L962-L975, ProtocolVersions.sol#L33-L36.](https://cantina.xyz/code/83d4667b-fefe-4491-a430-5436afb37f64/src/L1/proofs/AggregateVerifier.sol#L962-L975)


**Description:** <mark>ProtocolVersions</mark> documents that proof journals bind to the schedule in effect at
the game’s L1 origin and that cross-chain domain separation comes from committing the L2 chain id
and registry address alongside <mark>scheduleId</mark> :


/// Proof journals bind to `scheduleId`, pinning every proof in a
/// dispute game to the schedule in effect at the game's L1 origin block;

_�→_ cross-chain domain
/// separation is provided by the journal itself, which commits the L2 chain id and

_�→_ registry
/// address alongside `scheduleId`.


<mark>AggregateVerifier.initializeWithInitData</mark> instead pins via a linear L2 claim timestamp derived

from genesis and block time, independent of the verified L1 origin and of the factory <mark>l1Head</mark> . The

TEE/ZK journals pack <mark>CONFIG_HASH</mark>, the image or range hash, and <mark>scheduleId</mark> only:


**bytes32** journal = keccak256(

abi.encodePacked(

proposer,
l1OriginHash,
startingRoot,
startingL2SequenceNumber,
endingRoot,
endingL2SequenceNumber,
intermediateRoots,
CONFIG_HASH,
TEE_IMAGE_HASH, // or ZK_RANGE_HASH
scheduleId
)
);


The <mark>L2_CHAIN_ID</mark> and <mark>PROTOCOL_VERSIONS</mark> immutables are set in the constructor but never appear
in the journal encoding. Offchain, Rust, or TEE builders that follow the NatSpec may bind the wrong
schedule view or omit domain fields that the onchain verifier never checks. Domain separation then
depends entirely on <mark>CONFIG_HASH</mark> composition being unique per deployment.


**Recommendation:** Align the <mark>ProtocolVersions</mark> NatSpec with <mark>AggregateVerifier</mark> ’s pin source

and journal layout. Either include <mark>L2_CHAIN_ID</mark> and <mark>address(PROTOCOL_VERSIONS)</mark> in the journal, or

document that those values are committed inside <mark>CONFIG_HASH</mark> and enforce that invariant in deploy
config.


**Coinbase:** [Fixed in PR 416.](https://github.com/base/contracts/pull/416)


**Cantina Managed:** Fix verified.


**3.3.2** **<mark>AggregateVerifier</mark>** **comment still describes freeze-at-activation semantics**


**Severity:** Informational.


**Context:** [AggregateVerifier.sol#L430-L433.](https://cantina.xyz/code/83d4667b-fefe-4491-a430-5436afb37f64/src/L1/proofs/AggregateVerifier.sol#L430-L433)


**Description:** <mark>initializeWithInitData</mark> comments that <mark>ProtocolVersions</mark> only freezes an activa
tion once L1 time reaches it, and that requiring <mark>claimTimestamp</mark> <mark><=</mark> <mark>block.timestamp</mark> keeps the pin
canonical:


Cantina Managed 10 September 19, 2026


// `ProtocolVersions` only freezes an activation once L1 time reaches it, so a claim

_�→_ whose L2
// timestamp is still in L1's future would pin a schedule the owner can afterwards

_�→_ clear or
// delay. Requiring the claim to have already passed on L1 keeps the pin canonical

_�→_ for life.
**if** (claimTimestamp  - **block.timestamp** ) revert L2TimestampInFuture(claimTimestamp,

_�→_ **block.timestamp** );


After <mark>#409</mark>, preexisting activations freeze at <mark>activation</mark> <mark>-</mark> <mark>FREEZE_WINDOW</mark> via <mark>ProtocolVersions_</mark>


<mark>ActivationFrozen</mark> . The runtime gate is correct; the comment is stale and can mislead reviewers
tracing pin/mutation invariants.


**Recommendation:** Update the comment to state that mutations freeze <mark>FREEZE_WINDOW</mark> before activation, and that the claim-timestamp check additionally ensures the game’s L2 time is not still in L1’s
future.


**Coinbase:** [Fixed in PR 417.](https://github.com/base/contracts/pull/417)


**Cantina Managed:** Fix verified.


**3.3.3** **Initialization proof L1 origin is unbound from the factory** **<mark>l1Head</mark>**


**Severity:** Informational.


**Context:** [AggregateVerifier.sol#L450-L456, AggregateVerifier.sol#L490-L498.](https://cantina.xyz/code/83d4667b-fefe-4491-a430-5436afb37f64/src/L1/proofs/AggregateVerifier.sol#L450-L456)


**Description:** During <mark>initializeWithInitData</mark>, the contract verifies a proof-supplied L1 origin

( <mark>proof[1:65]</mark> ) via <mark>_verifyL1Origin</mark>, then journals that origin into the init attestation. The CWIA

payload still carries a separate factory <mark>l1Head</mark>, which later <mark>verifyProposalProof</mark> calls journal instead:


**bytes32** l1OriginHash = **bytes32** (proof[1:33]);
**uint256** l1OriginNumber = **uint256** ( **bytes32** (proof[33:65]));
_verifyL1Origin(l1OriginHash, l1OriginNumber);


_verifyProof(

proof[65:],
proofType,
gameCreator(),
l1OriginHash,
/* ... */
);


Nothing requires the init origin to equal <mark>l1Head()</mark>, or to lie within a bounded age of it. A single game
can therefore attest one L1 provenance at creation and another in subsequent proofs. This may be
intentional, but prover stacks can easily assume a single L1 head binding and produce journals that
fail one of the two paths.


**Recommendation:** Document the split explicitly for prover implementers. If a single provenance is
required, enforce <mark>l1OriginHash</mark> <mark>==</mark> <mark>l1Head()</mark> (or a bounded relationship) at initialization.


**Coinbase:** [Fixed in PR 418.](https://github.com/base/contracts/pull/418)


**Cantina Managed:** Fix verified.


Cantina Managed 11 September 19, 2026


