# Linea Canonical Token Bridge

Source: [https://diligence.security/audits/2023/06/linea-canonical-token-bridge/](https://diligence.security/audits/2023/06/linea-canonical-token-bridge/)

|  |  |
| --- | --- |
| Date | June 2023 |
| Auditors | Rai Yang, Tejaswa Rastogi |
| Download | JSON  CSV |

## 1 Executive Summary

This report presents the results of our engagement with **Linea** to review **Canonical Token bridge**.

The review was conducted over two weeks, from **June 26th** to **July 4th**, by
**Rai Yang** and **Tejaswa Rastogi**. A total of 2x7 person-days were spent.

## 2 Scope

Our review focused on the commit hash `db5553a5f3166fd17a72806d79f28906e4e375ba`. The list of files in scope can be found in the [Appendix](#appendix---files-in-scope).

### 2.1 Objectives

Together with the **Linea** team, we identified the following priorities for our review:

1. Correctness of the implementation, consistent with the intended functionality and without unintended edge cases.
2. Identify known vulnerabilities particular to smart contract systems, as outlined in our [Smart Contract Best Practices](https://consensys.github.io/smart-contract-best-practices/), and the [Smart Contract Weakness Classification Registry](https://swcregistry.io/).
3. Exploiting the bridge to
   - mint tokens without depositing
   - withdraw without burning on the other chain
   - steal user funds on Bridged ERC20
   - bridge to an unintended address
   - or any other
4. Exploiting a bug making it impossible for users to withdraw their token or use the contracts
5. Bypassing protection set by Linea (reserved tokens, pause status)
6. The user’s funds are stuck in the contract due to bridging issues

## 3 Security Specification

This section describes, **from a security perspective**, the expected behavior of the system under audit. It is not a substitute for documentation. The purpose of this section is to identify specific security properties that were validated by the audit team.

### 3.1 Actors

The relevant actors are listed below with their respective abilities:

- User: The User uses the token bridge to transfer ERC20 tokens between L1 and L2
- Bridge: The bridge also acts an administrator that deploys new Bridge Tokens and mints new tokens on them.
- Security Council: A Linea/ConsenSys-controlled multi-sig wallet that deploys contracts and performs upgrades or contract functions such as setting custom bridge token contracts
- Postman: Linea’s off-chain message delivery service or third-party service delivering the messages to claim the delivery fee. Each postman is not dependent on the other to function. There is the possibility of third-party postmen being unavailable.

### 3.2 Trust Model

In any system, it’s important to identify what trust is expected/required between various actors. For this audit, we established the following trust model:

- The single coordinator relays L1 messages to L2 correctly and timely and does not censor L1 messages
- The single sequencer sequences the L2 transaction correctly, does not censor L2 messages and submits the blocks and proof to L1 timely
- Postman delivers the messages to the destination layer correctly and rationally based on the fee and gas cost of delivering the message
- Security Council performs the service management properly and upgrades the contracts correctly and securely

## 4 Findings

Each issue has an assigned severity:

- Critical issues are directly exploitable security vulnerabilities that need to be fixed.
- Major issues are security vulnerabilities that may not be directly exploitable or may require certain conditions in order to be exploited. All major issues should be addressed.
- Medium issues are objective in nature but are not security vulnerabilities. These should be addressed unless there is a clear reason not to.
- Minor issues are subjective in nature. They are typically suggestions around best practices or readability. Code maintainers should use their own judgment as to whether to address such issues.
- Issues without a severity are general recommendations or optional improvements. They are not related to security or correctness and may be addressed at the discretion of the maintainer.

[### 4.1 Bridge Token Would Be Locked and Cannot Bridge to Native Token Critical ✓ Fixed](#bridge-token-would-be-locked-and-cannot-bridge-to-native-token)

#### Resolution

The recommendations are implemented by the Linea team in the pull request [66](https://github.com/Consensys/linea-token-bridge/pull/66) with the final commit hash as `8f8ee32cf3ad24ec669b62910d3d6eb1da9cc78e`

#### Description

If the bridge token B of a native token A is already deployed and `confirmDeployment` is called on the other layer and `setDeployed` sets A’s `nativeToBridgedToken` value to `DEPLOYED_STATUS`. The bridge token B cannot bridge to native token A in `completeBridging` function, because A’s `nativeToBridgedToken` value is not `NATIVE_STATUS`, as a result the native token won’t be transferred to the receiver. User’s bridge token will be locked in the original layer

#### Examples

**contracts/TokenBridge.sol:L217-L229**

```
if (nativeMappingValue == NATIVE_STATUS) {
  // Token is native on the local chain
  IERC20(_nativeToken).safeTransfer(_recipient, _amount);
} else {
  bridgedToken = nativeMappingValue;
  if (nativeMappingValue == EMPTY) {
    // New token
    bridgedToken = deployBridgedToken(_nativeToken, _tokenMetadata);
    bridgedToNativeToken[bridgedToken] = _nativeToken;
    nativeToBridgedToken[_nativeToken] = bridgedToken;
  }
  BridgedToken(bridgedToken).mint(_recipient, _amount);
}
```

**contracts/TokenBridge.sol:L272-L279**

```
function setDeployed(address[] memory _nativeTokens) external onlyMessagingService fromRemoteTokenBridge {
  address nativeToken;
  for (uint256 i; i < _nativeTokens.length; i++) {
    nativeToken = _nativeTokens[i];
    nativeToBridgedToken[_nativeTokens[i]] = DEPLOYED_STATUS;
    emit TokenDeployed(_nativeTokens[i]);
  }
}
```

#### Recommendation

Add an condition `nativeMappingValue` = `DEPLOYED_STATUS` for native token transfer in `confirmDeployment`

```
if (nativeMappingValue == NATIVE_STATUS || nativeMappingValue == DEPLOYED_STATUS) {
   IERC20(_nativeToken).safeTransfer(_recipient, _amount);
```

[### 4.2 User Cannot Withdraw Funds if Bridging Failed or Delayed Major  Won't Fix](#user-cannot-withdraw-funds-if-bridging-failed-or-delayed)

#### Description

If the bridging failed due to the single coordinator is down, censoring the message, or bridge token contract is set to a bad or wrong contract address by `setCustomContract`, user’s funds will stuck in the `TokenBridge` contract until coordinator is online or stop censoring, there is no way to withdraw the deposited funds

#### Examples

**contracts/TokenBridge.sol:L341-L348**

```
function setCustomContract(
  address _nativeToken,
  address _targetContract
) external onlyOwner isNewToken(_nativeToken) {
  nativeToBridgedToken[_nativeToken] = _targetContract;
  bridgedToNativeToken[_targetContract] = _nativeToken;
  emit CustomContractSet(_nativeToken, _targetContract);
}
```

#### Recommendation

Add withdraw functionality to let user withdraw the funds under above circumstances or at least add withdraw functionality for Admin (admin can send the funds to the user manually), ultimately decentralize coordinator and sequencer to reduce bridging failure risk.

[### 4.3 Bridges Don’t Support Multiple Native Tokens, Which May Lead to Incorrect Bridging Major ✓ Fixed](#bridges-dont-support-multiple-native-tokens-which-may-lead-to-incorrect-bridging)

#### Resolution

The recommendations are implemented by the Linea team in the pull request [65](https://github.com/Consensys/linea-token-bridge/pull/65) with the final commit hash as `27c2e53c8da206d1d2e06abbdadee1e728219763`.
The Bridges now support only one native token and revert, if attempted to bridge a native token with the same address on the other layer. The team mentions the reason for choosing this design is to support their specific use case, and for the cases where the users want to have same native tokens on both the layers, third-party liquidity bridges would be a better option.

**Note**:- Although, the introduced check adds a scenario, where if the **owner** adds a bridge for a native token on the source layer via `setCustomContract` , the protocol will disallow any bridging from it. However, after having a discussion, the team concluded that the function `setCustomContract`  is intended to be called on the destination layer and the team will take the necessary precautions while dealing with it.

**Update**: A related [issue 4.7](#incorrect-bridging-due-to-address-collision--inconsistent-state-of-native-tokens) with a similar root cause has also been identified and addressed with a fix that also correct this issue.

#### Description

Currently, the system design does not support the scenarios where native tokens with the same addresses (which is possible with the same deployer and nonce) on different layers can be bridged.

For instance,
Let’s consider, there is a native token `A` on `L1` which has already been bridged on `L2`. If anyone tries to bridge native token `B` on `L2` with the same address as token `A` , instead of creating a new bridge on `L1` and minting new tokens, the token bridge will transfer native token `A` on `L1` to the `_recipient` which is incorrect.

The reason is the mappings don’t differentiate between the native tokens on two different Layers.

```
  mapping(address => address) public nativeToBridgedToken;
  mapping(address => address) public bridgedToNativeToken;
```

#### Examples

**contracts/TokenBridge.sol:L208-L220**

```
function completeBridging(
  address _nativeToken,
  uint256 _amount,
  address _recipient,
  bytes calldata _tokenMetadata
) external onlyMessagingService fromRemoteTokenBridge {
  address nativeMappingValue = nativeToBridgedToken[_nativeToken];
  address bridgedToken;

  if (nativeMappingValue == NATIVE_STATUS) {
    // Token is native on the local chain
    IERC20(_nativeToken).safeTransfer(_recipient, _amount);
  } else {
```

#### Recommendation

Redesign the approach to handle the same native tokens on different layers. One possible approach could be to define the set of mappings for each layer.

[### 4.4 No Check for Initializing Parameters of TokenBridge Major ✓ Fixed](#no-check-for-initializing-parameters-of-tokenbridge)

#### Resolution

The recommendations are implemented by the Linea team in the pull request [68](https://github.com/Consensys/linea-token-bridge/pull/68) with the final commit hash as `7a3764b461b70f3b06aa77b859349be7a918ac1d`

#### Description

In `TokenBridge` contract’s `initialize` function, there is no check for initializing parameters including `_securityCouncil`, `_messageService`, `_tokenBeacon` and `_reservedTokens`. If any of these address is set to 0 or other invalid value, TokenBridge would not work, user may lose funds.

#### Examples

**contracts/TokenBridge.sol:L97-L111**

```
function initialize(
  address _securityCouncil,
  address _messageService,
  address _tokenBeacon,
  address[] calldata _reservedTokens
) external initializer {
  __Pausable_init();
  __Ownable_init();
  setMessageService(_messageService);
  tokenBeacon = _tokenBeacon;
  for (uint256 i = 0; i < _reservedTokens.length; i++) {
    setReserved(_reservedTokens[i]);
  }
  _transferOwnership(_securityCouncil);
}
```

#### Recommendation

Add non-zero address check for `_securityCouncil`, `_messageService`, `_tokenBeacon` and `_reservedTokens`

[### 4.5 Owner Can Update Arbitrary Status for New Native Token Without Confirmation Major ✓ Fixed](#owner-can-update-arbitrary-status-for-new-native-token-without-confirmation)

#### Resolution

The recommendations are implemented by the Linea team in the pull request [67](https://github.com/Consensys/linea-token-bridge/pull/67) with the final commit hash as `e096523ec3fc34996a30fd517d6e97cfef3bcf8d`.
The function now reverts, if the `_targetContract`  supplied is any of the reserved status codes.

#### Description

The function `setCustomContract` allows the owner to update arbitrary status for new native tokens without confirmation, bypassing the bridge protocol.

- It can set `DEPLOYED_STATUS` for a new native token, even if there exists no bridged token for it.
- It can set `NATIVE_STATUS` for a new native token even if it’s not.
- It can set `RESERVED_STATUS` disallowing any new native token to be bridged.

#### Examples

**contracts/TokenBridge.sol:L341-L348**

```
function setCustomContract(
  address _nativeToken,
  address _targetContract
) external onlyOwner isNewToken(_nativeToken) {
  nativeToBridgedToken[_nativeToken] = _targetContract;
  bridgedToNativeToken[_targetContract] = _nativeToken;
  emit CustomContractSet(_nativeToken, _targetContract);
}
```

#### Recommendation

The function should not allow `_targetContract` to be any state code

[### 4.6 Owner May Exploit Bridged Tokens Major ✓ Fixed](#owner-may-exploit-bridged-tokens)

#### Resolution

The recommendations are implemented by the Linea team in the pull request [67](https://github.com/Consensys/linea-token-bridge/pull/67) with the final commit hash as `e096523ec3fc34996a30fd517d6e97cfef3bcf8d`.
The function now reverts, if the `_targetContract`  supplied has already been defined as a bridge to a native token.

#### Description

The function `setCustomContract` allows the owner, to define a custom ERC20 contract for the native token. However, it doesn’t check whether the target contract has already been defined as a bridge to a native token or not. As a result, the owner
may take advantage of the design flaw and bridge another new native token that has not been bridged yet, to an already existing target(already a bridge for another native token).
Now, if a user tries to bridge this native token, the token bridge on the source chain will take the user’s tokens, and instead of deploying a new bridge on the destination chain, tokens will be minted to the `_recipient` on an existing bridge defined by the owner, or it can be any random EOA address to create a DoS.

The owner can also try to front-run calls to `completeBridging` for new Native Tokens on the destination chain, by setting a different bridge via `setCustomContract`. Although, the team states that the role will be controlled by a multi-sig which makes frontrunning less likely to happen.

#### Examples

**contracts/TokenBridge.sol:L341-L348**

```
function setCustomContract(
  address _nativeToken,
  address _targetContract
) external onlyOwner isNewToken(_nativeToken) {
  nativeToBridgedToken[_nativeToken] = _targetContract;
  bridgedToNativeToken[_targetContract] = _nativeToken;
  emit CustomContractSet(_nativeToken, _targetContract);
}
```

**contracts/TokenBridge.sol:L220-L229**

```
} else {
  bridgedToken = nativeMappingValue;
  if (nativeMappingValue == EMPTY) {
    // New token
    bridgedToken = deployBridgedToken(_nativeToken, _tokenMetadata);
    bridgedToNativeToken[bridgedToken] = _nativeToken;
    nativeToBridgedToken[_nativeToken] = bridgedToken;
  }
  BridgedToken(bridgedToken).mint(_recipient, _amount);
}
```

#### Recommendation

Make sure, a native token should bridge to a single target contract. A possible approach could be to check whether the `bridgedToNativeToken` for a target is `EMPTY` or not. If it’s not EMPTY, it means it’s already a bridge for a native token and the function should revert. The same can be achieved by adding the modifier `isNewToken(_targetContract)`.

**Note**:- However, it doesn’t resolve the issue of frontrunning, even if the likelihood is less.

[### 4.7 Incorrect Bridging Due to Address Collision & Inconsistent State of Native Tokens Medium ✓ Fixed](#incorrect-bridging-due-to-address-collision--inconsistent-state-of-native-tokens)

#### Resolution

The Linea team has proposed another [PR](https://github.com/Consensys/linea-contracts-fix/pull/3) to fix the issues associated with token address collision during bridging. Namely, the chain ID associated with the token’s native chain is now introduced as a key to the token address mapping, and the chain ID is added to the salt when deploying bridged token contracts, ensuring uniqueness. Consequently, this PR addresses the raised concerns though introduction of a more complex state to the bridge contract may raise the difficulty of upgrading the contract, thus redeployments are recommended in future for any changes.

#### Description

**In the second round of the audit**, we discovered an edge case that may exist because of an address collision of native tokens. In the first round, we found [issue 4.3](#bridges-dont-support-multiple-native-tokens-which-may-lead-to-incorrect-bridging) explaining how the bridges only support a single native token on both layers and may cause incorrect bridging. In response to that, the Linea team implemented a change that reverts whenever there is an attempt to bridge a native token with the same address on the other layer.

However, the issue still exists because of the inconsistent state of native tokens while bridging. The reason is, there could be an attempt to bridge a token with the same address on both layers at the same time, which could be done deliberately by an attacker by monitoring the bridging call at source layer and frontrunning them on the destination layer. As a consequence, both the tokens will get the `NATIVE_STATUS` on both layers, as the bridges can’t check the state of a token on the other layer while bridging. Now, the bridging that was initiated for a native token on the source layer will be completed with the native token on the destination layer, as the bridging was initiated at the same time.

```
    if (nativeMappingValue == NATIVE_STATUS || nativeMappingValue == DEPLOYED_STATUS) {
      // Token is native on the local chain
      IERC20Upgradeable(_nativeToken).safeTransfer(_recipient, _amount);
```

For the issue, the Linea team came back with the solution in the PR [1041](https://github.com/Consensys/zkevm-monorepo/pull/1041) with the final commit `a875e67e0681ce387825127a08f1f924991a274c`. The solution implemented adds a flag `_isNativeLayer` while sending the message to Message Service on source layer

```
    messageService.sendMessage{ value: msg.value }(
      remoteSender,
      msg.value, // fees
      abi.encodeCall(ITokenBridge.completeBridging, (nativeToken, _amount, _recipient, _isNativeLayer, tokenMetadata))
    );
```

and is used to verify the state of native token on destination layer while calling `completeBridging`.

```
...
    if (_isNativeLayer == false && (nativeMappingValue == NATIVE_STATUS || nativeMappingValue == DEPLOYED_STATUS)) {
      // Token is native on the local chain
      IERC20Upgradeable(_nativeToken).safeTransfer(_recipient, _amount);
    }
    else{
    ...
          if (
        nativeMappingValue == EMPTY ||
        (_isNativeLayer && (nativeMappingValue == NATIVE_STATUS || nativeMappingValue == DEPLOYED_STATUS))
      ) {
              // New token
        bridgedToken = deployBridgedToken(_nativeToken, _tokenMetadata);
        bridgedToNativeToken[bridgedToken] = _nativeToken;
        nativeToBridgedToken[_nativeToken] = bridgedToken;
      }
      BridgedToken(bridgedToken).mint(_recipient, _amount);
      ...
    }
   
```

The logic adds two conditional checks:
1- If `_isNativeLayer`  is false, it means the token is not native on the source layer, and if for the same address the status is either Native or Deployed, then the native token of the destination layer should be bridged.
2- If the flag is true, it means the token is native on the source layer, and if there exists a collision of the Native or Deployed status, then a new bridge token should be created.

**Minting Bad Tokens**
We reviewed the PR and new integrations and found that it is still problematic. The reason is the bridging of a token with the same address, will create a `bridgedToken` on each layer. Now the `nativeToBridgedToken` status is no more Native or Deployed, but a bridge address.
Let’s call the native token `A` and bridgedToken be `B` and `C` on each layer respectively. Now if the bridgeToken `B` is tried to be bridged back to native token `A`, it’ll be not possible, as while doing `completeBridging` both of the conditional checks will be unsatisfied. However, in any case, the bridge on the destination layer will still mint the `bridgedTokens`

```
      BridgedToken(bridgedToken).mint(_recipient, _amount);
```

As an example, the `B` tokens can be bridged to mint `C` bridgedTokens and vice-versa as and when needed. So, now it is mandatory to call `confirmDeployment` in order to allow condition 1 to be satisfied for this bridging and avoid this kind of bad minting.

[### 4.8 Updating Message Service Does Not Emit Event Medium ✓ Fixed](#updating-message-service-does-not-emit-event)

#### Resolution

The recommendations are implemented by the Linea team in the pull request [69](https://github.com/Consensys/linea-token-bridge/pull/69) with the final commit hash as `1fdd5cfc51c421ad9aaf8b2fd2b3e2ed86ffa898`

#### Description

The function `setMessageService` allows the owner to update the message service address. However, it does not emit any event reflecting the change. As a result, in case the owner gets compromised, it can silently add a malicious message service, exploiting users’ funds. Since, there was no event emitted, off-chain monitoring tools wouldn’t be able to trigger alarms and users would continue using rogue message service until and unless tracked manually.

#### Examples

**contracts/TokenBridge.sol:L237-L240**

```
function setMessageService(address _messageService) public onlyOwner {
  messageService = IMessageService(_messageService);
}
```

#### Recommendation

Consider emitting an event reflecting the update from the old message service to the new one.

[### 4.9 Lock Solidity Version in `pragma` Minor](#lock-solidity-version-in-pragma)

#### Description

Contracts should be deployed with the same compiler version they have been tested with. Locking the pragma helps ensure that contracts do not accidentally get deployed using, for example, the latest compiler which may have higher risks of undiscovered bugs. Contracts may also be deployed by others and the pragma indicates the compiler version intended by the original authors.

See [Locking Pragmas](https://consensys.github.io/smart-contract-best-practices/development-recommendations/solidity-specific/locking-pragmas/) in [Ethereum Smart Contract Best Practices](https://consensys.github.io/smart-contract-best-practices/).

#### Examples

**contracts/interfaces/IMessageService.sol:L2**

```
pragma solidity ^0.8.19;
```

**contracts/BridgedToken.sol:L2**

```
pragma solidity ^0.8.19;
```

**contracts/TokenBridge.sol:L2**

```
pragma solidity ^0.8.19;
```

**contracts/interfaces/ITokenBridge.sol:L2**

```
pragma solidity ^0.8.19;
```

#### Recommendation

Lock the Solidity version to the latest version before deploying the contracts to production.

```
pragma solidity 0.8.19;
```

[### 4.10 Upgradeability Concerns Minor ✓ Fixed](#upgradeability-concerns)

#### Resolution

The recommendations are implemented by the Linea team in the pull request [70](https://github.com/Consensys/linea-token-bridge/pull/70) with the final commit hash as `a014c29ddc12d5eb13a86827ac25a90e5239277b`

#### Description

**1- Using Standard Interfaces and Libraries instead of Upgradeable ones.**

**contracts/TokenBridge.sol:L5-L10**

```
import { IERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
```

We recommend using upgradeable interfaces and libraries to avoid any unexpected issues while contract upgrades, also increasing code readability.

**2- Using Deprecated Files**
The contract imports file `draft-IERC20Permit` from the npm module `openzeppelin/contracts`.

**contracts/TokenBridge.sol:L5**

```
import { IERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";
```

However, the file has been deprecated now, as the EIP2612 has been finalized. We recommend using the correct file which is `extensions/IERC20Permit.sol` or the corresponding upgradeable one.

[### 4.11 TokenBridge Does Not Follow a 2-Step Approach for Ownership Transfers Minor ✓ Fixed](#tokenbridge-does-not-follow-a-2-step-approach-for-ownership-transfers)

#### Resolution

The recommendations are implemented by the Linea team in the pull request [71](https://github.com/Consensys/linea-token-bridge/pull/71) with the final commit hash as `8ebfd011675ea318b7067af52637192aa1126acd`

#### Description

`TokenBridge` defines a privileged role **Owner**, however, it uses a single-step approach, which immediately transfers the ownership to the new address. If accidentally passed an incorrect address, the current owner will immediately lose control over the system as there is no fail-safe mechanism.

A safer approach would be to first propose the ownership to the new owner, and let the new owner accept the proposal to be the new owner. It will add a fail-safe mechanism for the current owner as in case it proposes ownership to an incorrect address, it will not immediately lose control, and may still propose again to a correct address.

#### Examples

**contracts/TokenBridge.sol:L22**

```
contract TokenBridge is ITokenBridge, PausableUpgradeable, OwnableUpgradeable {
```

#### Recommendation

Consider moving to a 2-step approach for the ownership transfers as recommended above.
**Note**:- Openzeppelin provides another helper utility as [Ownable2StepUpgradeable](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/access/Ownable2StepUpgradeable.sol) which follows the recommended approach

[### 4.12 Code Corrections ✓ Fixed](#code-corrections)

#### Resolution

The recommendations are implemented by the Linea team in the pull request [72](https://github.com/Consensys/linea-token-bridge/pull/72) with the final commit hash as `0f9c5bb5e9ec261bff8e688ddd224896d298963c`

#### Description

**1- Importing `ITokenBridge` twice**
The contract defines the import of interface `ITokenBridge` twice, out of which one can be removed.

**contracts/TokenBridge.sol:L4**

```
import { ITokenBridge } from "./interfaces/ITokenBridge.sol";
```

**contracts/TokenBridge.sol:L14**

```
import { ITokenBridge } from "./interfaces/ITokenBridge.sol";
```

**2- Using bytes32 for a bytes4 selector**
The contract stores a 4-byte selector of `_PERMIT_SELECTOR` in a bytes32 type.

**contracts/TokenBridge.sol:L24-L25**

```
bytes32 private constant _PERMIT_SELECTOR =
  bytes4(keccak256(bytes("permit(address,address,uint256,uint256,uint8,bytes32,bytes32)")));
```

The selector is then compared with the first 4 bytes of `_permitData` to make sure, the calldata is indeed a calldata of `permit` function.

**contracts/TokenBridge.sol:L435-L436**

```
if (bytes4(_permitData[:4]) != _PERMIT_SELECTOR)
  revert InvalidPermitData(bytes4(_permitData[:4]), _PERMIT_SELECTOR);
```

The check will work as intended, however, if it fails, the error will revert with info containing 32 bytes of _PERMIT_SELECTOR as `0xd505accf00000000000000000000000000000000000000000000000000000000`, which may create unnecessary confusion for end users.
As a recommendation, consider using a bytes4 type for `_PERMIT_SELECTOR` and also for the custom error `InvalidPermitData`.

**contracts/interfaces/ITokenBridge.sol:L20**

```
error InvalidPermitData(bytes4 permitData, bytes32 permitSelector);
```

## 5 Findings from Other Sources

This section includes Issues that are reported externally by the Whitehats apart from this audit, either via bug bounty platforms or with other means of responsible disclosure. The details are included as is as shared by the Whitehats.

**ERC-777 tokens can re-enter TokenBridge’s deposit function and bridge an unlimited amount of tokens**

The TokenBridge contract implements a L1 <-> L2 token bridge that is open to be used with any token. Tokens supporting the ERC-777 standard provide before and after token transfer hooks. The before transfer hook is invoked on the sender, while the after transfer hook is invoked on the recipient.
An attacker can abuse this behaviour by re-entering the deposit function over and over, artificially inflating the amount of bridged tokens. Thi is due to the TokenBridge caching the token balance before transfer:

```
// TokenBridge @ function bridgeToken
uint256 balanceBefore = IERC20Upgradeable(_token).balanceOf(
    address(this)
);

IERC20Upgradeable(_token).safeTransferFrom(
    msg.sender,
    address(this),
    _amount
);

_amount =
    IERC20Upgradeable(_token).balanceOf(address(this)) -
    balanceBefore;
```

By re-entering the function multiple times with a minimal amount, for example 1 wei, and sending a larger amount during the final re-entrancy, all invokations of the function will calculate _amount as the final larger amount. This results in the actually deposited amount being multiplied by the number of re-entrancies.
This mints more tokens to the attacker than should be, that could then be bridged-back to withdraw the excess funds of other previous legitimate depositors, or kept on the remote chain and sold there.

**Recommendation**:
Mark the deposit function as nonReentrant, for example by using OZ’s ReentrancyGuard.

**Our Review**:
Following the recommendation, the team added the Reentrancy Guard, which the auditing team has reviewed. But adding the Reentrancy Guard in the inheritance hierarchy may mess up the storage layout while making the upgrade, as Openzeppelin’s ReentrancyGuardUpgradeable pushes more buffer space and may collide with the existing storage slot, so we recommend either going for a fresh deployment or making necessary changes in the files to make sure there is no collision and a consistent storage layout.

**Update from Linea Team**:
The recommendation was taken into consideration and a fresh version was deployed on the Mainnet, which is also the first version deployed on the Mainnet covering the fixes.

## Appendix 1 - Files in Scope

This audit covered the following files:

| File | SHA-1 hash |
| --- | --- |
|  |  |
| contracts/interfaces/IMessageService.sol | `5dca9238ae13515eebd6a8c24274529f0dce8aab` |
| contracts/interfaces/ITokenBridge.sol | `1ea6ed6495137080d2f903a254f8745a61734425` |
| contracts/BridgedToken.sol | `247732ab4e95d7628189095f4e8b996c690ceae8` |
| contracts/TokenBridge.sol | `2c9c1743bfd76798ca7600b447ca741051528aad` |

## Appendix 2 - Disclosure

ConsenSys Diligence (“CD”) typically receives compensation from one or more clients (the “Clients”) for performing the analysis contained in these reports (the “Reports”). The Reports may be distributed through other means, including via ConsenSys publications and other distributions.

The Reports are not an endorsement or indictment of any particular project or team, and the Reports do not guarantee the security of any particular project. This Report does not consider, and should not be interpreted as considering or having any bearing on, the potential economics of a token, token sale or any other product, service or other asset. Cryptographic tokens are emergent technologies and carry with them high levels of technical risk and uncertainty. No Report provides any warranty or representation to any Third-Party in any respect, including regarding the bugfree nature of code, the business model or proprietors of any such business model, and the legal compliance of any such business. No third party should rely on the Reports in any way, including for the purpose of making any decisions to buy or sell any token, product, service or other asset. Specifically, for the avoidance of doubt, this Report does not constitute investment advice, is not intended to be relied upon as investment advice, is not an endorsement of this project or team, and it is not a guarantee as to the absolute security of the project. CD owes no duty to any Third-Party by virtue of publishing these Reports.

PURPOSE OF REPORTS The Reports and the analysis described therein are created solely for Clients and published with their consent. The scope of our review is limited to a review of code and only the code we note as being within the scope of our review within this report. Any Solidity code itself presents unique and unquantifiable risks as the Solidity language itself remains under development and is subject to unknown risks and flaws. The review does not extend to the compiler layer, or any other areas beyond specified code that could present security risks. Cryptographic tokens are emergent technologies and carry with them high levels of technical risk and uncertainty. In some instances, we may perform penetration testing or infrastructure assessments depending on the scope of the particular engagement.

CD makes the Reports available to parties other than the Clients (i.e., “third parties”) – on its website. CD hopes that by making these analyses publicly available, it can help the blockchain ecosystem develop technical best practices in this rapidly evolving area of innovation.

LINKS TO OTHER WEB SITES FROM THIS WEB SITE You may, through hypertext or other computer links, gain access to web sites operated by persons other than ConsenSys and CD. Such hyperlinks are provided for your reference and convenience only, and are the exclusive responsibility of such web sites’ owners. You agree that ConsenSys and CD are not responsible for the content or operation of such Web sites, and that ConsenSys and CD shall have no liability to you or any other person or entity for the use of third party Web sites. Except as described below, a hyperlink from this web Site to another web site does not imply or mean that ConsenSys and CD endorses the content on that Web site or the operator or operations of that site. You are solely responsible for determining the extent to which you may use any content at any other web sites to which you link from the Reports. ConsenSys and CD assumes no responsibility for the use of third party software on the Web Site and shall have no liability whatsoever to any person or entity for the accuracy or completeness of any outcome generated by such software.

TIMELINESS OF CONTENT The content contained in the Reports is current as of the date appearing on the Report and is subject to change without notice. Unless indicated otherwise, by ConsenSys and CD.
