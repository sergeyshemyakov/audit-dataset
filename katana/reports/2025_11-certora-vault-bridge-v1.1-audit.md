### **Security Assessment**

# **Polygon Vault Bridge V1.1**
#### `November 2025`

```
Prepared for Polygon

```

​ ​ ​ ​ ​ ​ ​

##### **Table of content**

**Project Summary.............................................................................................................................................................. 3**

Project Scope............................................................................................................................................................................................................3

Project Overview.....................................................................................................................................................................................................3

Protocol Overview......................................................................................................................................................................................... 4

Findings Summary.................................................................................................................................................................................................6

Severity Matrix......................................................................................................................................................................................................... 6

**Detailed Findings...............................................................................................................................................................7**

**Medium Severity Issues........................................................................................................................................... 9**

M-01. Migration may complete for wrong vbToken if mapping changes between asset and message
claims.............................................................................................................................................................................................................................9

M-02. setCustomToken() during in‑progress migrations can strand removal and block completion............. 10
M-03. Migration in-progress accounting couples assets and shares.............................................................11
M-04. Non‑revoked yieldVault approval during pause undermines incident response..................................13
**Low Severity Issues..................................................................................................................................................14**

L-01. Withdraw may deliver fewer assets than requested and event may misreport........................................... 14

L-02. Yield recipient cannot be updated when paused while yield collection remains callable.....................15
L-03. Migration completion on Primary Chain blocked by pause.................................................................. 16
L-04. Agglayer mint-to-zero path for migration finalization blocked by pause...............................................17
L-05. Misleading decimals assertion may mask misconfiguration.................................................................18
**Informational Issues.................................................................................................................................................19**

I-01. Polygon provider leaves setNativeConverter() enabled though unused.............................................................19

I-02. Minimum deposit threshold applied during rebalancing..............................................................................................19

I-03. Missing rotation runbook for LayerZero adapter handover....................................................................................... 20

I-04. Use of ReentrancyGuardTransientUpgradeable breaks cross-chain compatibility.................................20

I-05. Event hygiene for admin/config setters (missing or insufficient emits)..................................................21
I-06. Non-standard ERC-20 Transfer(address(0), address(0), value) emitted.............................................. 22
I-07. Zero-address mint path triggering migration finalization is permitted to NativeConverter.....................22
**Disclaimer......................................................................................................................................................................... 23**

**About Certora..................................................................................................................................................................23**


​ 2


​ ​ ​ ​ ​ ​ ​
## **Project Summary**


**Project Scope**


Latest Commit
Project Name Repository (link) Platform
Hash



Polygon Vault
Bridge V1.1



<u>[https://github.com/agglayer/vault](https://github.com/agglayer/vault-bridge/tree/feat/layerzero)</u>
<u>[-bridge/tree/feat/layerzero](https://github.com/agglayer/vault-bridge/tree/feat/layerzero)</u>

<u>[https://github.com/agglayer/vault](https://github.com/agglayer/vault-bridge/tree/tmp-lz-conflicts)</u>
<u>[-bridge/tree/tmp-lz-confictsl](https://github.com/agglayer/vault-bridge/tree/tmp-lz-conflicts)</u>



<u>[7289ca3 (original](https://github.com/agglayer/vault-bridge/commit/7289ca32a9dfddbd7a6d2b6e5af4dd3384c665d5)</u>
commit) ​
<u>[950e64d (final](https://github.com/agglayer/vault-bridge/commit/950e64d4ead51a8ef911829ab8775a18533a8cca)</u>
commit)



Solidity



**​**
**Project Overview**


This document describes the manual code review findings of **Polygon Vault Bridge V1.1** . The
review involved a re-audit of the full scope with a focus on the LayerZero integration. The
following contract list is included in our scope:

```
​
src/etc/ERC20PermitUser.sol
src/etc/IAgglayerBridge.sol
src/etc/IBridgeMessageReceiver.sol
src/etc/IFiatTokenV2_2.sol
src/etc/IWETH9.sol
src/etc/IVaultBridgeTokenInitializer.sol
src/etc/InitializationCounterUpgradeable.sol
src/etc/Versioned.sol
src/primary-chain/MigrationManager.sol
src/primary-chain/VaultBridgeToken.sol
src/primary-chain/VaultBridgeTokenInitializer.sol
src/primary-chain/VaultBridgeTokenPart2.sol
src/primary-chain/ethereum/GenericVaultBridgeToken.sol
src/primary-chain/ethereum/vbETH/VbETH.sol
src/primary-chain/layerzero/NonDefaultOftAdapter.sol

```

​ 3


​ ​ ​ ​ ​ ​ ​

```
src/secondary-chain/CustomToken.sol
src/secondary-chain/CustomTokenWethExtension.sol
src/secondary-chain/NativeConverter.sol
src/secondary-chain/agglayer/CustomTokenAgglayer.sol
src/secondary-chain/agglayer/GenericCustomTokenAgglayer.sol
src/secondary-chain/agglayer/GenericNativeConverterAgglayer.sol
src/secondary-chain/agglayer/NativeConverterAgglayer.sol
src/secondary-chain/agglayer/vbETH/WethAgglayer.sol
src/secondary-chain/agglayer/vbETH/WethNativeConverterAgglayer.sol
src/secondary-chain/agglayer/vbUSDC/bridged-usdc-standard/VbUsdcNativeConv
erterAgglayerBridgedUsdcStandard.sol
src/secondary-chain/layerzero/CustomTokenLayerZero.sol
src/secondary-chain/layerzero/GenericCustomTokenLayerZero.sol
src/secondary-chain/layerzero/NonDefaultMintBurnOftAdapter.sol
src/secondary-chain/layerzero/vbETH/WethLayerZero.sol
src/secondary-chain/polygon/CustomTokenPolygon.sol
src/secondary-chain/polygon/GenericCustomTokenPolygon.sol
src/secondary-chain/wormhole/CustomTokenWormhole.sol
src/secondary-chain/wormhole/GenericCustomTokenWormhole.sol
src/secondary-chain/wormhole/vbETH/WethWormhole.sol

```

The work was undertaken from **November 03, 2025,** to **November 17, 2025** . During this time,
Certora’s security researchers performed a manual audit of all the Solidity contracts and
discovered several bugs in the codebase, which are summarized in the subsequent section.


**Protocol Overview**


Vault Bridge enables chains and apps to earn native yield on bridged TVL by staking underlying
assets on the Primary Chain while keeping liquid representations on Secondary Chains.


The protocol is comprised of:


●​ One Primary Chain
○​ Vault Bridge Token (vbToken): ERC      - 20/4626 vault that locks underlyings, optionally
bridges minted vbToken, and manages yield.


​ 4


​ ​ ​ ​ ​ ​ ​


○​ Migration Manager: singleton that receives cross      - chain messages and finalizes
migrations from Native Converters via a strict origin allowlist. ​

●​ Many Secondary Chains
○​ Custom Token: chain      - local representation minted/burned by the bridge or its
adapter.
○​ Native Converter (optional): converts between Custom Token and its underlying on
the Secondary Chain, tracks backing, and can migrate backing to Primary.


Select assets are deposited into the Vault Bridge Token on the Primary Chain, which mints
vbToken and can bridge it to Secondary Chains through supported providers (e.g.,
Agglayer/Polygon zkEVM, LayerZero, Wormhole) via adapters. Underlyings are put to work in a
configured ERC - 4626 yield vault on Primary, while vbTokens/Custom Tokens circulate in DeFi on
Secondary. Produced yield can be collected on Primary and routed to a designated recipient.


A Native Converter on a Secondary Chain enables local acquisition/redemption of Custom Token
without first bridging from Primary. As backing accumulates, the converter allows its migration to
Vault Bridge Token on Primary via Migration Manager.


​ 5


​ ​ ​ ​ ​ ​ ​


**Findings Summary**


The table below summarizes the findings of the review, including type and severity details.


**Severity** **Discovered** **Confirmed** **Fixed**


Critical  -  -  

High  -  -  

Medium 4 4 2


Low 5 5 3


Informational 7 7 5


**Total** **16** **16** **10**


**Severity Matrix**


High Medium High Critical



**Impact**



Medium Low Medium High


Low Low Low Medium


Low Medium High


**Likelihood**



​ 6


​ ​ ​ ​ ​ ​ ​
## **Detailed Findings**


**ID** **Title** **Severity** **Status**



<u>M-01</u>
Migration may complete for wrong vbToken if
mapping changes between asset and message
claims


<u>M-02</u>
setCustomToken() during in     - progress
migrations can strand removal and block
completion


<u>M-03</u>
Migration in-progress accounting couples
assets and shares


<u>M-04</u>
Non    - revoked yieldVault approval during
pause undermines incident response


<u>L-01</u>
Withdraw may deliver fewer assets than
requested and event may misreport


<u>L-02</u>
Yield recipient cannot be updated when paused
while yield collection remains callable


<u>L-03</u>
Migration completion on Primary Chain blocked
by pause


<u>L-04</u>
Agglayer mint-to-zero path for migration
finalization blocked by pause



Medium Acknowledged


Medium Fixed


Medium Acknowledged


Medium Fixed


Low Acknowledged


Low Fixed


Low Acknowledged


Low Fixed


​ 7


​ ​ ​ ​ ​ ​ ​


<u>L-05</u>
Misleading decimals assertion may mask
misconfiguration


<u>I-01</u> Polygon provider leaves

setNativeConverter() enabled though

unused


<u>I-02</u> Minimum deposit threshold applied during
rebalancing


<u>I-03</u> Missing rotation runbook for LayerZero adapter
handover


<u>I-04</u> Use of

ReentrancyGuardTransientUpgradeable

breaks cross-chain compatibility


<u>I-05</u> Event hygiene for admin/config setters (missing
or insufficient emits)


<u>I-06</u> Non-standard ERC-20

Transfer(address(0), address(0),

value) emitted


<u>I-07</u> Zero-address mint path triggering migration

finalization is permitted to NativeConverter



Low Fixed


Informational Fixed


Informational Fixed


Informational Acknowledged


Informational Fixed


Informational Acknowledged


Informational Fixed


Informational Fixed


​ 8


​ ​ ​ ​ ​ ​ ​

###### **Medium Severity Issues**


**M-01. Migration may complete for wrong vbToken if mapping changes between asset**
**and message claims**


Severity: **Medium** Impact: **High** Likelihood: **Low**



[Files: MigrationManager.sol](https://github.com/agglayer/vault-bridge/blob/7289ca32a9dfddbd7a6d2b6e5af4dd3384c665d5/src/primary-chain/MigrationManager.sol#L197-L261)
<u>[VaultBridgeToken.sol](https://github.com/agglayer/vault-bridge/blob/7289ca32a9dfddbd7a6d2b6e5af4dd3384c665d5/src/primary-chain/VaultBridgeTokenPart2.sol#L123-L183)</u>



Status: Acknowledged



**Description:** On Primary Chain, MigrationManager.onMessageReceived() selects the

vbToken using the current (originNetwork, originAddress) `→` TokenPair mapping and

calls completeMigration(). If a call to configureNativeConverters() happens between

an asset and message claim, completion will use the new vbToken. In that scenario, if the new

vbToken uses the same underlying, completeMigration() succeeds and vbToken is

minted/bridged for the wrong token, misattributing assets. If the underlying differs, it reverts,
leaving assets in MigrationManager. This involves distinct roles (Primary DEFAULT_ADMIN_ROLE
vs MIGRATOR_ROLE) and can arise solely from insufficient cross-role coordination.


**Recommendations:** Encode the expected vbToken address into the migration message and

require equality in onMessageReceived() before calling completeMigration(). Alternatively,

document and enforce an operational runbook, such as:


●​ Revoke MIGRATOR_ROLE on the affected NativeConverter contracts.

●​ Finish any pending migrations for the pair.

●​ Pause MigrationManager.

●​ Update the mapping, then unpause MigrationManager and restore MIGRATOR_ROLE.


**Customer’s response:** A complete revamp of Native Converter / backing migration mechanisms
is planned for V2. The current mechanism will be replaced with a different one. In the meantime,
we will keep this in mind.


**Fix Review:** Acknowledged.


​ 9


​ ​ ​ ​ ​ ​ ​


**M-02.** **setCustomToken() during in** - **progress migrations can strand removal and**
**block completion**


Severity: **Medium** Impact: **High** Likelihood: **Low**



[Files: NativeConverter.sol](https://github.com/agglayer/vault-bridge/blob/7289ca3/src/secondary-chain/NativeConverter.sol#L565-L604)
<u>[CustomTokenAgglayer.sol](https://github.com/agglayer/vault-bridge/blob/7289ca3/src/secondary-chain/agglayer/CustomTokenAgglayer.sol#L31-L41)</u>



Status: Fixed



**Description:** NativeConverter.setCustomToken() checks backingOnSecondaryChain ==

0 (and gas backing) but not in - flight migrations. If customToken is swapped while

_migrationsInProgressCount > 0 or before pending zero - address mints arrive, the

subsequent zero - address mint on the old token calls removeMigrationInProgress() via the

old token, but the converter now enforces onlyCustomToken for the new token and reverts

Unauthorized. This strands _migrationsInProgress* and blocks clean completion. This

involves distinct roles (Secondary DEFAULT_ADMIN_ROLE vs MIGRATOR_ROLE) and can arise
solely from insufficient coordination.


**Recommendations:** Prevent setCustomToken() when migrations are in - flight by requiring

_migrationsInProgressCount == 0. Alternatively, document and enforce an operational

runbook, such as:

●​ Freeze new starts: revoke MIGRATOR_ROLE.

●​ Require no in-flight: _migrationsInProgressCount == 0 and

_totalMigratedBackingInProgress == 0.

●​ Ensure no pending zero-address mints for that token/network on the bridge.

●​ Then call setCustomToken and re-grant roles.


**Customer’s response:** [Addressed in c452808.](https://github.com/agglayer/vault-bridge/commit/c4528080c8ae0857625ae4c7872cf1dfd55db245)


**Fix Review:** Confirmed.


​ 10


​ ​ ​ ​ ​ ​ ​


**M-03. Migration in-progress accounting couples assets and shares**


Severity: **Medium** Impact: **High** Likelihood: **Low**



[Files: NativeConverter.sol](https://github.com/agglayer/vault-bridge/blob/7289ca3/src/secondary-chain/NativeConverter.sol#L544-L561) ​
<u>[CustomTokenAgglayer.sol](https://github.com/agglayer/vault-bridge/blob/7289ca3/src/secondary-chain/agglayer/CustomTokenAgglayer.sol#L31-L47)</u>



Status: Acknowledged



**Description:** The migration “in - progress” tracking in NativeConverter increments using

migrated backing (assets) while the removal path decrements using minted custom token

(shares). This implicitly assumes a permanent 1:1 exchange rate between assets and shares. If

the ratio or decimals ever diverge, the map key will not match and totals may underflow or
desync, blocking migration completion or corrupting accounting.


JavaScript

function _addMigrationInProgress(uint256 migratedBacking) internal {

NativeConverterStorage storage $ = _getNativeConverterStorage();


$._migrationsInProgress[migratedBacking]++;

$._migrationsInProgressCount++;

$._totalMigratedBackingInProgress += migratedBacking;


emit MigrationInProgressAdded(migratedBacking);

}


function _removeMigrationInProgress(uint256 mintedCustomToken) private {

NativeConverterStorage storage $ = _getNativeConverterStorage();


$._migrationsInProgress[mintedCustomToken]--;

$._migrationsInProgressCount--;

$._totalMigratedBackingInProgress -= mintedCustomToken;


emit MigrationInProgressRemoved(mintedCustomToken);

}


​ 11


​ ​ ​ ​ ​ ​ ​


// in CustomTokenAgglayer.mint(...)

if (account == address(0)) {

NativeConverter(nativeConverter()).removeMigrationInProgress(value);

emit Transfer(address(0), address(0), value);

return;

}


**Recommendations:** Convert shares to assets before subtracting, and always index and update
the in - progress map and totals in assets so add/remove use the same unit. Include a lightweight
check that shares and assets remain 1:1 and if the invariant ever changes, migrate to recording
both units.


**Customer’s response:** The units are different because backing is migrated (assets) and
vbTokens are received back (shares). Therefore, the exchange between NC and VB is an 1:1 assets
for shares exchange.


**Fix Review:** Acknowledged.


​ 12


​ ​ ​ ​ ​ ​ ​


**M-04. Non** - **revoked** **yieldVault approval during pause undermines incident**
**response**


Severity: **Medium** Impact: **High** Likelihood: **Low**



[Files: VaultBridgeTokenInitializer.sol](https://github.com/agglayer/vault-bridge/blob/7289ca3/src/primary-chain/VaultBridgeTokenInitializer.sol#L105-L108) <u>​</u>
<u>[VaultBridgeTokenPart2.sol](https://github.com/agglayer/vault-bridge/blob/7289ca3/src/primary-chain/VaultBridgeTokenPart2.sol#L244-L366)</u>



Status: Fixed



**Description:** vbToken grants the yieldVault an unlimited allowance of the underlying at

initialization and does not revoke it on pause(). If the yieldVault is compromised, an admin

response that pauses and then calls drainYieldVault() (both of which can be immediately

executed, as opposed to setYieldVault() which requires configuration) will concentrate

assets on vbToken. This creates a window where the compromised yieldVault can

immediately transferFrom the drained underlying before the admin manages to call

setYieldVault(), where approval is revoked.


**Recommendation:** Call forceApprove(yieldVault, 0) on pause() and re-grant the

allowance on unpause().


**Customer’s** **response:** Auxiliary functions revokeYieldVaultApproval() and

restoreYieldVaultApproval() have been implemented in <u>[e0fa943, which permit revoking](https://github.com/agglayer/vault-bridge/commit/e0fa943a70762bb3f38db6ba57c445ae6121a4e0)</u>

the approval without delay.


**Fix Review:** Confirmed.


​ 13


​ ​ ​ ​ ​ ​ ​

###### **Low Severity Issues**


**L-01. Withdraw may deliver fewer assets than requested and event may misreport**


Severity: **Low** Impact: **Medium** Likelihood: **Low**


[Files: VaultBridgeToken.sol](https://github.com/agglayer/vault-bridge/blob/7289ca32a9dfddbd7a6d2b6e5af4dd3384c665d5/src/primary-chain/VaultBridgeToken.sol#L720-L736) Status: Acknowledged


**Description:** In VaultBridgeToken, the withdraw path assumes the yield vault transfers

exactly the requested amount of assets. The contract (a) forwards whatever the vault actually

returned to the user (via receivedAssets plus any reserve) without enforcing equality to the

requested assets, and (b) emits the ERC  - 4626 Withdraw event with the requested assets

value rather than the measured delivery. The solvency check in _withdrawFromYieldVault

constrains exchange  - rate/solvency using requested assets and burned shares, not the actual

delivered amount; therefore, it does not prevent under  - delivery. Under a trusted ERC  - 4626, this is
not expected to occur. However, if a non  - compliant vault underdelivers, the user can receive
fewer assets than requested while the event reports the full requested amount.


**Recommendations:** Consider asserting that delivered assets (amountToWithdraw +

receivedAssets) equal requested assets, and emit the actual delivered assets.


**Customer’s response:** only vaults that are ERC-4626 compliant and always send exactly

assets will be used as yieldVault.


**Fix Review:** Acknowledged.


​ 14


​ ​ ​ ​ ​ ​ ​


**L-02. Yield recipient cannot be updated when paused while yield collection remains**
**callable**


Severity: **Low** Impact: **Low** Likelihood: **Low**


[Files: VaultBridgeTokenPart2.sol](https://github.com/agglayer/vault-bridge/blob/7289ca3/src/primary-chain/VaultBridgeTokenPart2.sol#L203-L209) Status: Fixed


**Description:** The collectYield function in VaultBridgeTokenPart2 is intentionally callable

during pause, allowing the system to continue transferring yield. However, the admin-only

setYieldRecipient is whenNotPaused, preventing operators from switching the recipient

during an incident without opening an unpause window. This can complicate incident response
and routing updates when pausing is required for safety.


**Recommendations:** Allow changing the yield recipient during pause.

**Customer’s response:** [Addressed in a603746](https://github.com/agglayer/vault-bridge/commit/a603746b0f042b678618c8776060b5cfec9e8cc6) [and fcca991.](https://github.com/agglayer/vault-bridge/commit/fcca99123c9136222b4f9545b13df9045627c673)


**Fix Review:** Confirmed.


​ 15


​ ​ ​ ​ ​ ​ ​


**L-03. Migration completion on Primary Chain blocked by pause**


Severity: **Low** Impact: **Low** Likelihood: **Low**



[Files: MigrationManager.sol](https://github.com/agglayer/vault-bridge/blob/7289ca3/src/primary-chain/MigrationManager.sol#L263-L336)
<u>[VaultBridgeTokenPart2.sol](https://github.com/agglayer/vault-bridge/blob/7289ca3/src/primary-chain/VaultBridgeTokenPart2.sol#L124-L183)</u>



Status: Acknowledged



**Description:** On Primary Chain, completion of migrations is blocked while the system is paused

because both the Agglayer Bridge callback MigrationManager.onMessageReceived() and

the completion routine VaultBridgeTokenPart2.completeMigration() are guarded by

whenNotPaused. In contrast, on Secondary Chains

NativeConverter.migrateBackingToPrimaryChain() is callable while paused, so

migrations can be initiated but not finalized during a pause. This creates an emergency-time

liveness gap: underlying assets can accumulate at MigrationManager and cross-chain

reconciliation cannot be executed until unpaused. This also prevents safely calling

configureNativeConverters() as per M-01.


**Recommendations:** Permit migration completion while paused by removing whenNotPaused

from MigrationManager.onMessageReceived() and

VaultBridgeTokenPart2.completeMigration() so user flows remain paused while

recovery stays live.


**Customer’s response:** This is by design. Completing a migration is equivalent to depositing
assets, which is disallowed when the protocol is paused.


**Fix Review:** Acknowledged.


​ 16


​ ​ ​ ​ ​ ​ ​


**L-04. Agglayer mint-to-zero path for migration finalization blocked by pause**


Severity: **Low** Impact: **Low** Likelihood: **Low**



[Files: CustomTokenAgglayer.sol](https://github.com/agglayer/vault-bridge/blob/7289ca3/src/secondary-chain/agglayer/CustomTokenAgglayer.sol#L31-L46) <u>​</u>
<u>[NativeConverter.sol](https://github.com/agglayer/vault-bridge/blob/7289ca3/src/secondary-chain/NativeConverter.sol#L538-L563)</u>



Status: Fixed



**Description:** On Agglayer, CustomTokenAgglayer.mint() is whenNotPaused. The

migration-completion path relies on the “mint-to-zero” special case to invoke

NativeConverter.removeMigrationInProgress(). When the token is paused, the

mint-to-zero branch cannot execute, leaving _migrationsInProgress counters uncleared.

This creates stale “migration in progress” state and operational ambiguity during incident
response.


**Recommendations:** Allow mint-to-zero to bypass pause by handling the account ==

address(0) branch before the whenNotPaused check. This lets

removeMigrationInProgress(value) run even when paused, while all other mint/burn paths

remain pause-gated.

**Customer’s response:** [Addressed in 7602e91.](https://github.com/agglayer/vault-bridge/commit/7602e918a809dc72ea272dfda3fa36a5b73667c7)


**Fix Review:** Confirmed.


​ 17


​ ​ ​ ​ ​ ​ ​


**L-05. Misleading decimals assertion may mask misconfiguration**


Severity: **Low** Impact: **Low** Likelihood: **Low**



[Files: GenericCustomTokenAgglayer.sol](https://github.com/agglayer/vault-bridge/blob/7289ca3/src/secondary-chain/agglayer/GenericCustomTokenAgglayer.sol#L33-L42)
<u>[WethAgglayer.sol](https://github.com/agglayer/vault-bridge/blob/7289ca3/src/secondary-chain/agglayer/vbETH/WethAgglayer.sol#L36-L45)</u>



Status: Fixed



**Description:** Both reinitialize2() implementations assert that

originalUnderlyingTokenDecimals_ equals ERC20Upgradeable.decimals(). However,

ERC20Upgradeable.decimals() is a base implementation that always returns 18 and does not

reflect the actual token metadata or preserved bridged token state. This assertion can provide
false assurance, wrongly constraining non - 18 - decimals tokens or silently passing when metadata
is not truly validated at runtime.


JavaScript

function reinitialize2(...) ... {

...

string memory name_ = ERC20Upgradeable.name();

string memory symbol_ = ERC20Upgradeable.symbol();

assert(ERC20Upgradeable.decimals() == originalUnderlyingTokenDecimals_);

__CustomToken_init1(owner_, name_, symbol_, originalUnderlyingTokenDecimals_, bridge_,

nativeConverter_);

}


**Recommendations:** Compare against IERC20Metadata(address(this)).decimals()

rather than the base implementation.

**Customer’s response:** Addressed in <u>[f5a6177](https://github.com/agglayer/vault-bridge/commit/f5a6177512f0330daedf241b4d36531f3a15ac53)</u> and <u>[44c2cf1. The old storage lives in a different](https://github.com/agglayer/vault-bridge/commit/44c2cf1b3224b72e0548856a4e0af407d6b3f61c)</u>
slot.


**Fix Review:** Confirmed.


​ 18


​ ​ ​ ​ ​ ​ ​

###### **Informational Issues**


**I-01. Polygon provider leaves setNativeConverter() enabled though unused**


**Description:** In the Polygon PoS child token variant, minting is restricted to the

ChildChainManager and burning is self-initiated. The base token still exposes a one-time

setNativeConverter(), which is not used by this provider model.


**Recommendations:** For parity and clarity, override setNativeConverter() in

CustomTokenPolygon to revert, as is done in other providers.


**Customer’s response:** [Addressed in 00b3208.](https://github.com/agglayer/vault-bridge/commit/00b320883d49a8a95922d4c0ce6efdca6385f71d#diff-80a251e49bfb02fd2381f1e0641dcd72080d998172c1718b54182828bbf66fd6R43-R46)


**Fix Review:** Confirmed. **​**


**I-02. Minimum deposit threshold applied during rebalancing**


**Description:** The documentation for minimumYieldVaultDeposit in VaultBridgeToken states

“The limit does not apply when rebalancing the reserve.” However, the rebalancing-down path

calls _depositIntoYieldVault(excess, false), which enforces the

minimumYieldVaultDeposit threshold. As a result, when the reserve is slightly above target

and excess < minimumYieldVaultDeposit, the deposit is skipped and the small surplus

remains in reservedAssets. This is operationally benign, but it contradicts the stated behavior

and can leave small amounts idle instead of being deployed.


**Recommendations:** Align behavior and documentation: either (a) explicitly bypass the threshold

during _rebalanceReserve() when depositing excess, or (b) update the docs to state that

the threshold applies during rebalancing as well.


**Customer’s response:** [Addressed in 1ec5b2e.](https://github.com/agglayer/vault-bridge/commit/1ec5b2ee8a03a4e29b3e7d9eb6f8373606b2ef96)


**Fix Review:** Confirmed.


​ 19


​ ​ ​ ​ ​ ​ ​


**I-03. Missing rotation runbook for LayerZero adapter handover**


**Description:** The LayerZero README references wiring changes via the LayerZero CLI, and the
USDC README outlines a high-level handover (“double totalSupply and bridge half”), but there is

no explicit, end - to - end runbook for safely rotating the NonDefaultMintBurnOftAdapter token.

The docs omit how to briefly stop inbound credits, sweep to zero with the token unpaused, and
then switch adapters without races.


**Recommendations:** Add e.g. the following explicit instructions to the README:


1. ​ Temporarily disable inbound LayerZero routing/messages to the Secondary Chain for the
relevant lane.
2. ​ Keep the token unpaused; ensure mint rights on the legacy token and, if approvalRequired
= true, adapter allowance.

3. ​ Read the adapter’s local chain balance once (secondaryChainBalance), mint exactly

that amount, and bridge it out via the adapter to zero the balance (optionally submit via a
private mempool).

4. ​ Call setTokenAndApprovalRequired() with a fresh zero   - supply token, then re   - enable

inbound routing.


**Customer’s response:** Will be improved before the release.


**Fix Review:** Acknowledged. ​


**I-04. Use of ReentrancyGuardTransientUpgradeable breaks cross-chain**

**compatibility**


**Description:** The NonDefaultMintBurnOftAdapter contract imports and uses

ReentrancyGuardTransientUpgradeable. This specific implementation of a reentrancy

guard relies on the TSTORE and TLOAD opcodes (transient storage), which were introduced in the

Dencun hard fork (EIP-1153).


The protocol is intended for deployment on multiple L2s and EVM-compatible chains. However,
not all chains have implemented the Dencun upgrade or support these opcodes.


That’s why the other contracts which will be deployed on multiple L2s, such as CustomToken,

use the regular ReentrancyGuardUpgradeable.

​ 20


​ ​ ​ ​ ​ ​ ​


**Recommendations:** Modify the NonDefaultMintBurnOftAdapter contract to import and use

ReentrancyGuardUpgradeable instead of ReentrancyGuardTransientUpgradeable. This

will align it with the other contracts in the protocol and guarantee its functionality on all
EVM-compatible chains.


**Customer’s response:** [Addressed in ac19efd.](https://github.com/agglayer/vault-bridge/commit/ac19efd7937beff75ddd1b8b7821f76f310c0b88)


**Fix Review:** Confirmed. ​


**I-05. Event hygiene for admin/config setters (missing or insufficient emits)**


**Description:** Several role-gated configuration setters do not emit events, or emit events without
old/new values and/or proper indexing, which hinders monitoring and auditability.


●​ Instances of missing events:

○​ NativeConverter: setCustomToken

○​ NonDefaultMintBurnOftAdapter: setTokenAndApprovalRequired

○​ VaultBridgeTokenPart2: setMinimumYieldVaultDeposit

○​ MigrationManager: reinitialize1 (sets agglayerBridge/_agglayerId), reinitialize2 (sets
_wrappedGasToken)

○​ CustomToken: setBridge, setNativeConverter ​ (previously acknowledged)

●​ Instances of insufficient payload/indexing:

○​ VaultBridgeTokenPart2: setYieldVault (new only; address not indexed),
setYieldRecipient (new only), setMinimumReservePercentage (new only),
setYieldVaultMaximumSlippagePercentage (new only)

○​ NativeConverter: setNonMigratableBackingPercentage (new only)

○​ WethNativeConverterAgglayer: setNonMigratableGasBackingPercentage (new only)

○​ CustomTokenWethExtension: setWethFunctionalityEnabled (new only)


**Recommendations:** Emit new events where missing and extend existing events to include old
and new values, and index address fields where applicable. Keep naming consistent with “...Set”

e.g. YieldVaultSet(address indexed oldYieldVault, address indexed

newYieldVault).


**Customer’s response:** Will be considered.


**Fix Review:** Acknowledged.

​ 21


​ ​ ​ ​ ​ ​ ​


**I-06. Non-standard ERC-20 Transfer(address(0), address(0), value) emitted**


**Description:** When completing migration, the L1 VaultBridgeTokenPart2 bridges vbToken to

address(0) on the origin network; on L2, CustomTokenAgglayer.mint() handles account

== address(0) by emitting a raw ERC-20 event Transfer(address(0), address(0),

value) without any actual mint/burn or balance change. This is non-standard for ERC-20

(zero-from denotes mint; zero-to denotes burn; both zero is not a valid balance-changing
Transfer) and can mislead or break off-chain indexers and accounting systems that assume
standard semantics.


**Recommendations:** Use a dedicated domain event and stop emitting ERC - 20 Transfer in the

zero - recipient path. If a supply-affecting representation is desired, use a canonical mint-to-self

followed by immediate burn to produce standard Transfer events.


**Customer’s response:** [Addressed in 61163d5.](https://github.com/agglayer/vault-bridge/commit/61163d5215ef23d1e1987dd46e5e510f1e322386)


**Fix Review:** Confirmed. ​


**I-07. Zero-address mint path triggering migration finalization is permitted to**
**NativeConverter**


**Description:** In CustomTokenAgglayer.mint, the zero-address branch used to finalize

migrations is authorized for both bridge() and nativeConverter(). While current

NativeConverter flows validate a non-zero receiver before minting, the permission boundary is

broader than necessary: nativeConverter() is allowed to invoke the zero-address path that is

semantically intended for bridge-driven completion.


**Recommendations:** Check for (account == address(0) && msg.sender == bridge()).


**Customer’s response:** [Addressed in a19647a.](https://github.com/agglayer/vault-bridge/commit/a19647a77747ec6cb1a5e3c701f2fc917f523f2f)


**Fix Review:** Confirmed.


​ 22


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


​ 23


