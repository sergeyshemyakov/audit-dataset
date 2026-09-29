# ZKsync Era CodeHawks Competitive Audit Report

Source: [CodeHawks results](https://codehawks.cyfrin.io/c/2024-10-zksync/results)

Competition: Era (ZKsync)  
Repository: [https://github.com/Cyfrin/2024-10-zksync](https://github.com/Cyfrin/2024-10-zksync)  
Period: 2024-10-28 to 2024-12-02

The finalized report contains 1 high-risk, 10 medium-risk, and 18 low-risk canonical findings.

## High Risk Findings

### Priority operation reexecution for ERA chain in GW and L1 when migrating from GW to L1

Submission ID: `cm46w3n2y0005befqo9exkivx`  
Severity: High

## Summary

If the ERA chain decides to migrate the settlement layer from GW to L1 the same priority operations will be executed in the GW and L1 which is not the intended behavior

## Vulnerability Details

The ERA chain is planned for migration to the Gateway (GW), but it presents a unique scenario due to the priority queue. To integrate the ERA chain into the ZK Chains ecosystem, the GatewayUpgrade will be applied. The following code snippet outlines this upgrade:

```Solidity
    function upgrade(ProposedUpgrade calldata _proposedUpgrade) public override returns (bytes32) {
        ...
        s.priorityTree.setup(s.priorityQueue.getTotalPriorityTxs());
        ...
    }
```

This upgrade performs several configurations, including initializing the priority tree. As of this report, the ERA diamond chain has the following data:

```Solidity
totalPriorityTxs (tail) = 3264282
firstUnprocessedPriorityTx (head) = 3264203
```

But let's suppose that before migration all priority operations have been executed and both tail and head are the same.
Thus, the setup of the priority tree will set the \_startIndex to 3264282 in the diamond proxy on Layer 1 (L1). Upon migration to the GW, this \_startIndex will be transferred from the priority tree as follows:

```Solidity
    function initFromCommitment(Tree storage _tree, PriorityTreeCommitment memory _commitment) internal {
        uint256 height = _commitment.sides.length; // Height, including the root node.
        if (height == 0) {
            revert InvalidCommitment();
        }
        _tree.startIndex = _commitment.startIndex;
        _tree.unprocessedIndex = _commitment.unprocessedIndex;
        _tree.tree._nextLeafIndex = _commitment.nextLeafIndex;
        _tree.tree._sides = _commitment.sides;
        bytes32 zero = ZERO_LEAF_HASH;
        _tree.tree._zeros = new bytes32[](height);
        for (uint256 i; i < height; ++i) {
            _tree.tree._zeros[i] = zero;
            zero = Merkle.efficientHash(zero, zero);
        }
        _tree.historicalRoots[_tree.tree.root()] = true;
    }
```

However, the data from the priority queue in the L1 diamond will not be transferred, and every time a priority operation is initiated on the GW, the following process will occur:

```Solidity
    function _writePriorityOpHash(bytes32 _canonicalTxHash, uint64 _expirationTimestamp) internal {
        if (s.priorityTree.startIndex > s.priorityQueue.getFirstUnprocessedPriorityTx()) {
            s.priorityQueue.pushBack(
                PriorityOperation({
                    canonicalTxHash: _canonicalTxHash,
                    expirationTimestamp: _expirationTimestamp,
                    layer2Tip: uint192(0) // TODO: Restore after fee modeling will be stable. (SMA-1230)
                })
            );
        }
        s.priorityTree.push(_canonicalTxHash);
    }
```

Since the startIndex is 3264282 and the firstUnprocessedPriorityTx is 0 (due to non-initialization on the GW), a large number of priority transactions will be added to both the priority queue and tree. Specifically, 3264282 operations will be required to populate the priority tree. When executing these priority operations, the following will take place:

```Solidity
    function executeBatchesSharedBridge(
        uint256, // _chainId
        uint256 _processFrom,
        uint256 _processTo,
        bytes calldata _executeData
    ) external nonReentrant onlyValidator chainOnCurrentBridgehub {
        ...
        for (uint256 i = 0; i < nBatches; i = i.uncheckedInc()) {
            if (s.priorityTree.startIndex <= s.priorityQueue.getFirstUnprocessedPriorityTx()) {
                _executeOneBatch(batchesData[i], priorityOpsData[i], i);
            } else {
                if (priorityOpsData[i].leftPath.length != 0) {
                    revert PriorityOpsDataLeftPathLengthIsNotZero();
                }
                if (priorityOpsData[i].rightPath.length != 0) {
                    revert PriorityOpsDataRightPathLengthIsNotZero();
                }
                if (priorityOpsData[i].itemHashes.length != 0) {
                    revert PriorityOpsDataItemHashesLengthIsNotZero();
                }
                _executeOneBatch(batchesData[i], i);
            }
            emit BlockExecution(batchesData[i].batchNumber, batchesData[i].batchHash, batchesData[i].commitment);
        }
        ...
    }
```

As mentioned earlier, the startIndex will be 3264282, and the firstUnprocessedPriorityTx will be 0. Consequently, the batch execution will process the priority queue for the next 3264282 priority transactions. Since all these priority operations will not make the priority tree `unprocessedIndex` increment, if the ERA chain is migrated back to L1 this index will remain to 0 even though some priority operations have been executed. So the L1 will enforce that the priority operations that have been already executed on the GW to be executed again on L1 because they have been registered on the priority tree and the `unprocessedIndex` is 0. Notice that this happens because in the GW the `s.priorityQueue.getFirstUnprocessedPriorityTx` was 0 but 3264282 in L1.

## Impact

High, priority operations will be enforced to be reexecuted leading to serious problems like double spendings

## Tools Used

Manual review

## Recommendations

When the ERA chain is settled on the GW it will push the priority operations in both data structures, so I would increment the `unprocessedIndex` from the priority tree regardless from which data structure is executing the operations. Because since operations will be duplicated in both data structures, once the priority tree will have finished to process all his operations, the `unprocessedIndex` will already point to the correct priority operation to process. This way since the `unprocessedIndex` will be up to date, when migrating back to L1 it will be correct and L1 will process priority operations properly.

## Medium Risk Findings

### Double spending of funds when bridging “bridgedToken” 

Submission ID: `cm41772ix000784pa41oo07w0`  
Severity: Medium

## Summary

When a user bridges a `BridgedToken`, the user will spend twice their funds.

## Vulnerability Details

When a user bridges the `BridgedToken` to L2, they need to deposit their funds into the `L1ERC20Bridge` contract. So, when the user calls `L1ERC20Bridge::deposit`, it triggers the `_approveFundsToAssetRouter` function, which executes the fund transfer from the user to the `L1ERC20Bridge` contract. Here's how the code works:

```solidity

function deposit(
        address _l2Receiver,
        address _l1Token,
        uint256 _amount,
        uint256 _l2TxGasLimit,
        uint256 _l2TxGasPerPubdataByte,
        address _refundRecipient
    ) public payable nonReentrant returns (bytes32 l2TxHash) {
        if (_amount == 0) {
            // empty deposit amount
            revert EmptyDeposit();
        }
        if (_l1Token == ETH_TOKEN_ADDRESS) {
            revert ETHDepositNotSupported();
        }
=>        uint256 amount = _approveFundsToAssetRouter(msg.sender, IERC20(_l1Token), _amount);


 function _approveFundsToAssetRouter(address _from, IERC20 _token, uint256 _amount) internal returns (uint256) {
        uint256 balanceBefore = _token.balanceOf(address(this));
=>        _token.safeTransferFrom(_from, address(this), _amount);
        bool success = _token.approve(address(L1_ASSET_ROUTER), _amount);
        if (!success) {
            revert ApprovalFailed();
        }
        uint256 balanceAfter = _token.balanceOf(address(this));

        return balanceAfter - balanceBefore;
    }

```

After that, the `L1ERC20Bridge::deposit` triggers the `L1AssetRouter::depositLegacyErc20Bridge` function, passing `_originalCaller` as `msg.sender`, which is the address of the user interacting with the `L1ERC20Bridge::deposit` function. This `_originalCaller` parameter is forwarded to `L1AssetRouter::depositLegacyErc20Bridge`:
Look at this code [depositLegacyErc20Bridge](https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/era-contracts/l1-contracts/contracts/bridge/asset-router/L1AssetRouter.sol#L517-L547)

```Solidity
#L1ERC20Bridge.sol

function deposit(
/////////////////////////////
=>    l2TxHash = L1_ASSET_ROUTER.depositLegacyErc20Bridge{value: msg.value}({
=>         _originalCaller: msg.sender,
            _l2Receiver: _l2Receiver,
            _l1Token: _l1Token,
            _amount: _amount,
            _l2TxGasLimit: _l2TxGasLimit,
            _l2TxGasPerPubdataByte: _l2TxGasPerPubdataByte,
            _refundRecipient: _refundRecipient
        });

# L1AssetRouter.sol

 function depositLegacyErc20Bridge(
=>      address _originalCaller,
        address _l2Receiver,
        address _l1Token,
        uint256 _amount,
        uint256 _l2TxGasLimit,
        uint256 _l2TxGasPerPubdataByte,
        address _refundRecipient
    ) 

=> bridgeMintCalldata = _burn({
                _chainId: ERA_CHAIN_ID,
                _nextMsgValue: 0,
                _assetId: _assetId,
=>             _originalCaller: _originalCaller,
                _transferData: abi.encode(_amount, _l2Receiver),
                _passValue: false
            });

```

In `AssetRouterBase.sol`, the `_burn` function calls `IAssetHandler(l1AssetHandler).bridgeBurn`:

```Solidity
# AssetRouterBase.sol

function _burn(
        uint256 _chainId,
        uint256 _nextMsgValue,
        bytes32 _assetId,
        address _originalCaller,
        bytes memory _transferData,
        bool _passValue
    ) internal returns (bytes memory bridgeMintCalldata) {
        address l1AssetHandler = assetHandlerAddress[_assetId];
        if (l1AssetHandler == address(0)) {
            revert AssetHandlerDoesNotExist(_assetId);
        }

        uint256 msgValue = _passValue ? msg.value : 0;
=>        bridgeMintCalldata = IAssetHandler(l1AssetHandler).bridgeBurn{value: msgValue}({
            _chainId: _chainId,
            _msgValue: _nextMsgValue,
            _assetId: _assetId,
=>          _originalCaller: _originalCaller,
            _data: _transferData
        });
    }
```

The `BridgedToken` is initialized with the `assetHandlerAddress[_assetId] `as `_nativeTokenVault`:

```Solidity

 function _finalizeDeposit(
        uint256 _chainId,
        bytes32 _assetId,
        bytes calldata _transferData,
        address _nativeTokenVault
    ) internal {
        address assetHandler = assetHandlerAddress[_assetId];

        if (assetHandler != address(0)) {
            IAssetHandler(assetHandler).bridgeMint(_chainId, _assetId, _transferData);
        } else {
=>          assetHandlerAddress[_assetId] = _nativeTokenVault;
            IAssetHandler(_nativeTokenVault).bridgeMint(_chainId, _assetId, _transferData);
        }
    }
```

Since the `BridgedToken`'s `assetHandlerAddress` is `_nativeTokenVault`, the `_burn` function will trigger `NativeTokenVault::bridgeBurn` which calls the `_bridgeBurnBridgedToken` function:

```solidity

# NativeTokenVault.sol

 function bridgeBurn(
        uint256 _chainId,
        uint256,
        bytes32 _assetId,
        address _originalCaller,
        bytes calldata _data
    ) external payable override onlyAssetRouter whenNotPaused returns (bytes memory _bridgeMintData) {
        if (originChainId[_assetId] != block.chainid) {
=>      _bridgeMintData = _bridgeBurnBridgedToken(_chainId, _assetId, _originalCaller, _data);
        } else {
        //////////////////////////////////////
    }

    function _bridgeBurnBridgedToken(
        uint256 _chainId,
        bytes32 _assetId,
        address _originalCaller,
        bytes calldata _data
    ) internal returns (bytes memory _bridgeMintData) {
        (uint256 _amount, address _receiver) = abi.decode(_data, (uint256, address));
        if (_amount == 0) {
            // "Amount cannot be zero");
            revert AmountMustBeGreaterThanZero();
        }

        address bridgedToken = tokenAddress[_assetId];
=>      IBridgedStandardToken(bridgedToken).bridgeBurn(_originalCaller, _amount);
        _handleChainBalanceIncrease(_chainId, _assetId, _amount, false);

```

Since the `_originalCaller` is the user's address, when `NativeTokenVault::bridgeBurn` triggers `_bridgeBurnBridgedToken`, it burns the `BridgedToken` from the user by calling `(bridgedToken).bridgeBurn`.

As a result, whenever the user bridges the `BridgedToken`, the contract deducts double the amount of the user's `BridgedToken`.

1. `L1ERC20Bridge` takes the user's `BridgedToken` by calling `transferFrom` to transfer the user's `BridgedToken` into the `L1ERC20Bridge` contract.
2. `NativeTokenVault` burns the `BridgedToken` from the user.

## Impact

1. If the user still has remaining `BridgedToken`, they will lose their funds because bridging the `BridgedToken` causes the contract to take double the amount.
2. If the user has no remaining `BridgedToken`, the transaction will fail.

## Tools Used

Manual

## Recommendations

If user bridge `BridgedToken` from `L1ERC20Bridge` contract. Then when executing `_bridgeBurnBridgedToken`, ensure that the `_originalCaller` is the address of `L1ERC20Bridge`, since the user has already transferred their funds to the `L1ERC20Bridge`.

```Solidity

function depositLegacyErc20Bridge(
        address _originalCaller,
        address _l2Receiver,
        address _l1Token,
        uint256 _amount,
        uint256 _l2TxGasLimit,
        uint256 _l2TxGasPerPubdataByte,
        address _refundRecipient
    ) external payable override onlyLegacyBridge nonReentrant whenNotPaused returns (bytes32 txHash) {
        if (_l1Token == L1_WETH_TOKEN) {
            revert TokenNotSupported(L1_WETH_TOKEN);
        }

        bytes32 _assetId;
        bytes memory bridgeMintCalldata;

        {
            // Inner call to encode data to decrease local var numbers
            _assetId = _ensureTokenRegisteredWithNTV(_l1Token);
            IERC20(_l1Token).forceApprove(address(nativeTokenVault), _amount);

+        if (originChainId[_assetId] != block.chainid) {
+            _originalCaller = address(legacyBridge);
+        }

          bridgeMintCalldata = _burn({
                _chainId: ERA_CHAIN_ID,
                _nextMsgValue: 0,
                _assetId: _assetId,
                _originalCaller: _originalCaller,
                _transferData: abi.encode(_amount, _l2Receiver),
                _passValue: false
            });
        }
```

### USDT and similar tokens does not return bool due to incompatible with ERC20 Standard

Submission ID: `cm454a7zv0003vjzgr6msrj3o`  
Severity: Medium

# Summary

Approve is incompatible with non-standard erc20 tokens

# Vulnerability Details

USDT and similar tokens do not correctly implement the EIP20 standard, and their approve function returns void instead of a success `bool`.

Calling these functions with the EIP20 function signatures will always revert. Tokens like USDT on Ethereum, will be unusable in the `L1ERC20Bridge` contract as it will revert the transaction because of the missing return value.

Some tokens also require that the allowance be set to 0 before issuing a new approve call. Calling the approve function when the allowance is not zero reverts the transaction with these types of tokens.

# Impact

Checking bool return of ERC20 approve breaks protocol for mainnet USDT and similar tokens does not return [true]() even when calls are successful.

# POC

The below test clearly highlight the issue of revert, if we try approve method for USDT on mainnet.

 A random address is selected having USDT tokens then `approve` call is made for the `test_Contract`.

```Solidity
// forge t --mt test\_ApproveERC -vvv

    function test\_ApproveERC() external {

        IERC20 USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7); // usdt address on Mainnet

        address random\_User = 0x46340b20830761efd32832A74d7169B29FEB9758; // random User having USDT

 

        uint256 user\_Balance = IERC20(USDT).balanceOf(random\_User); // user Balance

        console.log("user\_Balance:", user\_Balance / 1e6); // division by 1e6 as USDT have 6 decimals

 

        uint256 amount\_Approve = 1000 \* 1e6; // approving 1000 USDT sans decimals

 

        vm.prank(random\_User); // mock call made by user

        IERC20(USDT).approve(address(test\_Contract), amount\_Approve); // approving amount

    }
```

 

In the test we made a fork call which simulates transaction carried in real world to the mainnet.

The result clearly shows call revert when `approve`method is called for `USDT` Token.

 

```Solidity
\$ forge t -f \$fork\_rpc\_url --etherscan-api-key \$key\_Api --mt test\_ApproveERC

\[⠒] Compiling...

\[⠔] Compiling 1 files with Solc 0.8.27

\[⠑] Solc 0.8.27 finished in 2.45s

Compiler run successful!

 

Ran 1 test for test/Contract\_Test.t.sol:CounterTest

\[FAIL: EvmError: Revert] test\_ApproveERC() (gas: 41748)

Suite result: FAILED. 0 passed; 1 failed; 0 skipped; finished in 8.95s (3.07s CPU time)

 

Ran 1 test suite in 10.49s (8.95s CPU time): 0 tests passed, 1 failed, 0 skipped (1 total tests)

 

Failing tests:

Encountered 1 failing test in test/Contract\_Test.t.sol:CounterTest

\[FAIL: EvmError: Revert] test\_ApproveERC() (gas: 41748)

 

Encountered a total of 1 failing tests, 0 tests succeeded

```

## Mitigation

Then we tried the same test with OZ’s SafeErc20 `forceApprove` method using fork call method.

```Solidity
     // forge t --mt test\_forceApprove -vvv

    function test\_forceApprove() external {

        IERC20 USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7); // usdt address on Mainnet

        address random\_User = 0x46340b20830761efd32832A74d7169B29FEB9758; // random User having USDT

 

        uint256 user\_Balance = IERC20(USDT).balanceOf(random\_User); // user Balance

        console.log("user\_Balance:", user\_Balance / 1e6); // division by 1e6 as USDT have 6 decimals

 

        uint256 amount\_Approve = 1000 \* 1e6; // approving 1000 USDT

 

        vm.startPrank(random\_User); // mock call made by user

        SafeERC20.forceApprove(USDT, address(test\_Contract), amount\_Approve); // approving amount

        uint256 approved\_Balance = IERC20(USDT).allowance(random\_User, address(test\_Contract)); // caching approved amount

 

        console.log("test\_Contract Approved Balance: %e", approved\_Balance);

    }

```

The result shows test passes and the `test_Contract` balance changes when we call the `allowance` method.

```Solidity
\$ forge t -f \$fork\_rpc\_url --etherscan-api-key \$key\_Api -vvv --mt test\_forceApprove

\[⠒] Compiling...

\[⠒] Compiling 1 files with Solc 0.8.27

\[⠘] Solc 0.8.27 finished in 2.45s

Compiler run successful!

 

Ran 1 test for test/Contract\_Test.t.sol:CounterTest

\[PASS] test\_forceApprove() (gas: 45103)

Logs:

  user\_Balance: 35414102

  test\_Contract Approved Balance: 1e9

 

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 6.47s (2.79s CPU time)

 

Ran 1 test suite in 7.94s (6.47s CPU time): 1 tests passed, 0 failed, 0 skipped (1 total tests)

```

## Code Reference

https://github.com/Cyfrin/2024-10-zksync/blob/b0c5565b6078a93cc3358a5d5012258caa701385/era-contracts/l1-contracts/contracts/bridge/L1ERC20Bridge.sol#L230



## Recommendation

It is recommended to use OpenZeppelin’s SafeERC20 `forceApprove` method to handle non-standard-compliant tokens.

### Merkle Proof Verification Path Inconsistency Enables Cross-Chain Message Verification Bypass

Submission ID: `cm44dm8b00005dhpdtzx11thz`  
Severity: Medium

## Summary

A critical inconsistency exists in Matter Labs' Merkle Tree implementation where competing validation logics for single-node trees create a race condition in the security model. While `calculateRootPaths` correctly validates single-node scenarios, both `calculateRoot` and `calculateRootMemory` implement a conflicting validation pattern that breaks the fundamental security assumptions of cross-chain message verification.

This vulnerability manifests in L1->L2 message processing where single-node Merkle trees (which are valid and common in certain bridge scenarios) would be rejected by `calculateRoot` but accepted by `calculateRootPaths`. The inconsistency creates an attack vector where a malicious actor could force message processing down specific codepaths by manipulating the tree structure, potentially leading to cross-chain message verification failures or bypasses.

Most critically, single-node Merkle trees are commonly used in bridge implementations for individual message verification, batch processing of single messages, and recovery scenarios. The presence of dual validation paths breaks the security invariant that a valid Merkle proof should be consistently verifiable across the entire system.

## Proof of Concept

The vulnerability stems from competing validations in two locations:

`calculateRootPaths` accepts valid single-node cases:

<https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/era-contracts/l1-contracts/contracts/common/libraries/Merkle.sol#L71>

```solidity
// Location: contracts/common/libraries/Merkle.sol#L82
if (pathLength == 0 && (_startIndex != 0 || levelLen != 1)) {
    revert MerklePathEmpty();
}
```

While `_validatePathLengthForSingleProof` used by `calculateRoot` rejects ALL single-node cases:

<https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/era-contracts/l1-contracts/contracts/common/libraries/Merkle.sol#L125>

```solidity
// Location: contracts/common/libraries/Merkle.sol#L132
function _validatePathLengthForSingleProof(uint256 _index, uint256 _pathLength) private pure {
    if (_pathLength == 0) {
        revert MerklePathEmpty(); // Always reverts
    }
    // ... additional validation
}
```

Here's a proof-of-concept that demonstrates how this affects bridge message verification:

```solidity
contract MerkleBridgeExploit {
    bytes32 private constant EMPTY_STRING_KECCAK = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    
    function exploitInconsistentValidation() external {
        // Simulate a single cross-chain message
        bytes32 messageHash = keccak256(abi.encodePacked("cross_chain_message"));
        
        // Set up minimal valid proof components
        bytes32[] memory emptyPath = new bytes32[]();
        uint256 index = 0;
        
        // Try direct calculation (fails)
        try Merkle.calculateRoot(emptyPath, index, messageHash) returns (bytes32 root1) {
            revert("Should have failed - validation inconsistency");
        } catch Error(string memory) {
            // Expected failure path
        }

        // Set up for batch path calculation
        bytes32[] memory messages = new bytes32[]();
        messages[0] = messageHash;
        
        // Calculate via batch path (succeeds)
        bytes32 root2 = Merkle.calculateRootPaths(
            emptyPath,
            emptyPath,
            index,
            messages
        );
        
        // Proof that the same message/proof combination produces different results
        console.log("Message verification status mismatch detected");
    }
}
```

To exploit this in a bridge context:

1. Attacker constructs a cross-chain message that must be verified via Merkle proof
2. Forces message batching into a single-node tree
3. Message verification fails or succeeds based on which validation path is taken
4. This breaks the fundamental assumption that valid messages should always verify consistently

The real-world impact is particularly severe for L1->L2 bridges where inconsistent message verification could lead to:

* Stuck cross-chain messages
* Potential double spending if redundant verification paths exist
* Denial of service for legitimate single-message proofs
* Increased gas costs from forced message batching to avoid the inconsistency

## Recommended mitigation steps

The fix requires unifying the validation logic to maintain consistent security invariants across all verification paths. Implement a new unified validation function:

```solidity
function validateMerkleProof(uint256 _index, uint256 _pathLength, uint256 _totalLeaves) private pure {
    // Special case: Valid single-node tree
    if (_pathLength == 0) {
        if (_index == 0 && _totalLeaves == 1) {
            return;
        }
        revert MerklePathEmpty();
    }

    // Standard multi-node validation
    if (_pathLength >= 256) {
        revert MerklePathOutOfBounds();
    }
    
    // Safe index validation incorporating total leaves
    uint256 maxIndex;
    unchecked {
        // Safe even in unchecked because _pathLength < 256
        maxIndex = (1 << _pathLength) - 1;
    }
    
    if (_index > maxIndex || _index >= _totalLeaves) {
        revert MerkleIndexOutOfBounds();
    }
}
```

Then modify both proof verification paths to use this unified validation:

```solidity
function calculateRoot(bytes32[] calldata _path, uint256 _index, bytes32 _itemHash) 
    internal pure returns (bytes32) 
{
    validateMerkleProof(_index, _path.length, 1);
    
    if (_path.length == 0) {
        return _itemHash;  // Single-node case
    }
    
    // Existing merkle path calculation...
}

function calculateRootPaths(
    bytes32[] memory _startPath,
    bytes32[] memory _endPath,
    uint256 _startIndex,
    bytes32[] memory _itemHashes
) internal pure returns (bytes32) {
    validateMerkleProof(_startIndex, _startPath.length, _itemHashes.length);
    
    // Existing batch verification logic...
}
```

### Unlimited Token Address Overwrites by Admin

Submission ID: `cm34zm9j70005f20jbaco7bjh`  
Severity: Medium

## Summary

<https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/era-contracts/l1-contracts/contracts/bridge/L2WrappedBaseTokenStore.sol#L68>



<https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/era-contracts/l1-contracts/contracts/bridge/L2WrappedBaseTokenStore.sol#L80>

In the `L2WrappedBaseTokenStore` contract, the `admin` can overwrite the `l2WBaseTokenAddress` mapping for any `chainId` an unlimited number of times. This lack of restrictions on address overwrites allows the `admin` to change L2 token addresses at will, potentially causing security and operational issues if abused.

## Vulnerability Details

The `initializeChain` and `reinitializeChain` functions allow the `admin` to set a new L2 wrapped token address in the `l2WBaseTokenAddress` mapping without restriction.

**Cause**: Lack of safeguards, such as overwrite limitations or multi-signature requirements, permits repeated and arbitrary changes.

**Exploitation**: An admin could change token addresses to malicious contracts or redirect funds to unauthorized addresses. Since no restrictions or tracking mechanisms are in place, these changes would be difficult to detect without constant monitoring.

## Impact

The unlimited overwrite ability creates several risks:

**Potential for Malicious Token Address Overwrites**: A malicious or compromised admin could redirect token addresses to arbitrary or malicious addresses, causing users to unknowingly interact with untrusted contracts.

**Loss of Trust and Reliability**: If addresses can be changed arbitrarily, users and applications may lose confidence in the accuracy and reliability of the stored token addresses.

**Increased Attack Surface**: The unrestricted overwrite ability creates an entry point for potential exploits or accidental errors by an admin, leading to unintended consequences.

## Tools Used

Exploit sample

Here’s a simplified example illustrating the unlimited overwrites in the contract:

```Solidity
contract L2WrappedBaseTokenStore is Ownable2Step {
    mapping(uint256 chainId => address l2WBaseTokenAddress) public l2WBaseTokenAddress;
    address public admin;

    function initializeChain(uint256 _chainId, address _l2WBaseToken) external onlyOwnerOrAdmin {
        l2WBaseTokenAddress[_chainId] = _l2WBaseToken; // Admin can overwrite without restriction
    }

    function reinitializeChain(uint256 _chainId, address _l2WBaseToken) external onlyOwner {
        l2WBaseTokenAddress[_chainId] = _l2WBaseToken;
    }
}

```

In this scenario, the `admin` can call `initializeChain` repeatedly, changing `l2WBaseTokenAddress` for any `chainId` without restriction. This can lead to unauthorized or malicious changes to token addresses.

## Recommendations

**Introduce Overwrite Limitations for Admin**

**Description**: Limit the number of times the `admin` can modify the `l2WBaseTokenAddress` mapping for each `chainId`.

**Implementation**: Use a mapping to track the number of times each `chainId` address has been set, and enforce a maximum limit (e.g., one modification by `admin`). Only allow further modifications by the owner.

**Benefit**: Reduces the risk of arbitrary overwrites, ensuring changes are intentional and limited.

```Solidity
mapping(uint256 => uint256) public overwriteCount;

function initializeChain(uint256 _chainId, address _l2WBaseToken) external onlyOwnerOrAdmin {
    require(overwriteCount[_chainId] < 1, "Admin overwrite limit reached");
    l2WBaseTokenAddress[_chainId] = _l2WBaseToken;
    overwriteCount[_chainId]++;
}

```

### Users can create proposals with very long descriptions that are uncancellable by the guardians

Submission ID: `cm3a8a9sy0005uvhkhs7j79jj`  
Severity: Medium

## Summary
Users can create proposals where any attempt that tries to cancel them reaches the gas / transaction limit on the L1, therefore completely circumventing the `GovernorGuardianVeto` module / safeguard.

## Vulnerability Details
The guardians have to use the function `cancelL2GovernorProposal` within the L1 contract `Guardians` (https://github.com/Cyfrin/2024-10-zksync/blob/b0c5565b6078a93cc3358a5d5012258caa701385/zk-governance/l1-contracts/src/Guardians.sol#L93) to cancel a proposal. This requests an L2 transaction, which ultimately calls `cancel` on `GovernorGuardianVeto` (https://github.com/Cyfrin/2024-10-zksync/blob/b0c5565b6078a93cc3358a5d5012258caa701385/zk-governance/l2-contracts/src/extensions/GovernorGuardianVeto.sol#L32).
It is important to note that the guardians have to pass in the whole description string to the function `cancelL2GovernorProposal`. The hashing only happens within the function and the hash is then submitted to the L2. It is also important to note that every blockchain has (implicit) limits for the length of calldata. There is an upper limit for the size of transactions (128kB for geth: https://github.com/ethereum/go-ethereum/blob/74ef47462f2a9daea04e81687c4d0b4598826ca2/core/txpool/legacypool/legacypool.go#L56) and a block gas limit (30 million for Ethereum). Because processing the calldata costs gas (especially hashing it), one of these automatically restricts the largest possible string that can be passed in such that the transaction is still included. Note that these limits are typically higher on an L2, the block gas limit is for instance 2**32 on ZkSync Era. But even if there were exactly the same, the following attack would still work, which is discussed below.

A malicious user can exploit the previously mentioned facts and submit proposals that are uncancellable. To do so, they submit a proposal with an extremely long `description`. The function `propose` (https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/zk-governance/l2-contracts/lib/openzeppelin-contracts/contracts/governance/Governor.sol#L273) does not restrict this length in any way. The length of the `description` is chosen such that the transaction is directly at its limit (either the transaction size limit or the block gas limit, whatever is smaller). Then, when the governors try to cancel the proposal, they need to submit the exact same string to get the same resulting proposal ID. However, this transaction would be above the limit and could not be executed. As previously argued, the limits (especially block gas limit) will be much lower on Ethereum. But even if they are the same, the transaction could not be executed: This happens because both the gas usage and the additional calldata size is larger for  `cancelL2GovernorProposal` than for `propose`. `cancelL2GovernorProposal` performs more work (signature verification, requesting an L2 verification, etc...). Most importantly, it hashes the description twice (once in [`hashL2Proposal`](https://github.com/Cyfrin/2024-10-zksync/blob/b0c5565b6078a93cc3358a5d5012258caa701385/zk-governance/l1-contracts/src/Guardians.sol#L178) and once in [the function itself](https://github.com/Cyfrin/2024-10-zksync/blob/b0c5565b6078a93cc3358a5d5012258caa701385/zk-governance/l1-contracts/src/Guardians.sol#L116) vs. only once for `propose`. The hashing gas cost is linear in the size of the data, so very expensive for such huge strings.
But also the additional calldata is longer. `propose` only has the arrays `targets`, `values`, and `calldatas`. `cancelL2GovernorProposal` includes these as well, but additionally `_txRequest`, `_signers`, and `_signatures`.

## Impact
The purpose of `GovernorGuardianVeto` is for the guardians to be able to veto any proposals, for instance when they are malicious. As shown previously, this mechanism can be circumvented and it is possible to create proposals that cannot be cancelled by the guardians. The L2 governors `ZkGovOpsGovernor` and `ZkTokenGovernor` use this module, which both can be used to create proposals that steal funds (e.g. by minting with a `ZkTokenGovernor` proposal) or break the system (with malicious governance proposals). This therefore seems to match funds being "nearly at risk".

## Recommendations
Change `cancelL2GovernorProposal` such that it accepts the description hash instead of the description string.

### User can send toke with fees

Submission ID: `cm42jq9pj0007iphddpyqb575`  
Severity: Medium

## Summary

A vulnerability exists in the token bridging mechanism that allows transfer of non-standard tokens with fee-on-transfer functionality from Layer 1 (L1) to Layer 2 (L2), despite documentation stating such tokens are not supported. This issue can occur when transferring base tokens or using the \`Bridgehub\` for ERC20 token transfers.



## Vulnerability Details



The `L1AssetRouter` transfers tokens to `L1NativeTokenVault` without verifying the exact balance after the transfer. Specifically:

* The router returns `depositChecked = true` without confirming the transferred amount&#x20;
* The subsequent `NativeTokenVault._bridgeBurnNativeToken` method does not validate that the full intended amount has been deposited This means tokens with transfer fees can be bridged without proper accounting, potentially leading to discrepancies in token balances.

This means tokens with transfer fees can be bridged without proper accounting, potentially leading to discrepancies in token balances.



\
<https://github.com/Cyfrin/2024-10-zksync/blob/b0c5565b6078a93cc3358a5d5012258caa701385/era-contracts/l1-contracts/contracts/bridge/ntv/L1NativeTokenVault.sol#L171>



<https://github.com/Cyfrin/2024-10-zksync/blob/b0c5565b6078a93cc3358a5d5012258caa701385/era-contracts/l1-contracts/contracts/bridge/ntv/NativeTokenVault.sol#L279>

## Impact

* Bridge tokens with fee-on-transfer mechanisms, which is not supported by the protocol
* Cause accounting discrepancies in the bridge
* Manipulate the actual amount of tokens transferred across layers

## Tools Used

Manual review.

Unit test.

## Recommendations

In `L1NativeTokenVault._bridgeBurnNativeToken`  do the following changes

```Solidity
    function _bridgeBurnNativeToken(
        uint256 _chainId,
        bytes32 _assetId,
        address _originalCaller,
    // solhint-disable-next-line no-unused-vars
        bool _depositChecked,
        bytes calldata _data
    ) internal override returns (bytes memory _bridgeMintData) {
        console.log("L1NativeTokenVault:_bridgeBurnNativeToken");
        if (!_depositChecked) {
            IERC20 token = IERC20(tokenAddress[_assetId]);
            uint balanceBefore = token.balanceOf(address(this));
            uint256 _depositAmount;
            (_depositAmount,) = abi.decode(_data, (uint256, address));
            bool depositDone = IL1AssetRouter(address(ASSET_ROUTER)).transferFundsToNTV(
                _assetId,
                _depositAmount,
                _originalCaller
            );
            if (depositDone) {
                uint256 balanceAfter = token.balanceOf(address(this));
                if (balanceAfter - balanceBefore != _depositAmount) {
                    revert TokensWithFeesNotSupported();
                }
                _depositChecked = true;
            }
        }
        console.log("depositChecked", _depositChecked);
        _bridgeMintData = super._bridgeBurnNativeToken({
            _chainId: _chainId,
            _assetId: _assetId,
            _originalCaller: _originalCaller,
            _depositChecked: _depositChecked,
            _data: _data
        });
    }

```

## PoC

In `era-contracts/l1-contracts/contracts/dev-contracts/TestnetERC20Token.sol` add the contract.

```solidity
contract TestnetERC20TokenWithFee is TestnetERC20Token {
    constructor(string memory name_, string memory symbol_, uint8 decimals_) TestnetERC20Token(name_, symbol_, decimals_) {
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        uint fee = amount / 10;
        _burn(msg.sender, fee);
        return super.transfer(to, amount - fee);
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        uint fee = amount / 10;
        _burn(from, fee);
        return super.transferFrom(from, to, amount - fee);
    }
}

```

In `era-contracts/l1-contracts/test/foundry/l1/unit/concrete/Bridges/L1SharedBridge/L1SharedBridgeBase.t.sol` add the two tests and update imports.

```solidity

    function test_bridgehubDepositBaseToken_ErcWithFee() public {
        // setup token with fee as base token
        TestnetERC20TokenWithFee tokenWithFee = new TestnetERC20TokenWithFee("TestnetERC20TokenWithFee", "TET", 18);
        bytes32 tokenWithFeeAssetId = DataEncoding.encodeNTVAssetId(block.chainid, address(tokenWithFee));
        vm.prank(address(nativeTokenVault));
        nativeTokenVault.registerToken(address(tokenWithFee));
        tokenWithFee.mint(alice, amount);

        // only approve the asset router
        vm.prank(alice);
        tokenWithFee.approve(address(sharedBridge), amount);

        vm.prank(bridgehubAddress);
        // solhint-disable-next-line func-named-parameters
        vm.expectEmit(true, true, true, true, address(sharedBridge));
        emit BridgehubDepositBaseTokenInitiated(chainId, alice, tokenWithFeeAssetId, amount);
        sharedBridge.bridgehubDepositBaseToken(chainId, tokenWithFeeAssetId, alice, amount);

        assertEq(tokenWithFee.balanceOf(alice), 0);
        uint amountMinusFee = amount - (amount / 10);
        assertEq(tokenWithFee.balanceOf(address(nativeTokenVault)), amountMinusFee);
    }

    function test_bridgehubDeposit_ErcWithFee() public {
        // setup token with fee as base token
        TestnetERC20TokenWithFee tokenWithFee = new TestnetERC20TokenWithFee("TestnetERC20TokenWithFee", "TET", 18);
        bytes32 tokenWithFeeAssetId = DataEncoding.encodeNTVAssetId(block.chainid, address(tokenWithFee));
        vm.prank(address(nativeTokenVault));
        nativeTokenVault.registerToken(address(tokenWithFee));
        tokenWithFee.mint(alice, amount);

        // only approve the asset router
        vm.prank(alice);
        tokenWithFee.approve(address(sharedBridge), amount);

        bytes memory transferData = abi.encode(amount, bob);
        bytes memory depositData = bytes.concat(NEW_ENCODING_VERSION, abi.encode(tokenWithFeeAssetId, transferData));
        bytes memory erc20Metadata = nativeTokenVault.getERC20Getters(address(tokenWithFee), block.chainid);
        bytes32 txDataHash = DataEncoding.encodeTxDataHash({
            _nativeTokenVault: address(nativeTokenVault),
            _encodingVersion: NEW_ENCODING_VERSION,
            _originalCaller: alice,
            _assetId: tokenWithFeeAssetId,
            _transferData: transferData
        });
        bytes memory bridgeMintCalldata = DataEncoding.encodeBridgeMintData({
            _originalCaller: alice,
            _remoteReceiver: bob,
            _originToken: address(tokenWithFee),
            _amount: amount,
            _erc20Metadata: erc20Metadata
        });
        vm.prank(bridgehubAddress);
        vm.expectEmit(true, false, true, false, address(sharedBridge));
        emit BridgehubDepositInitiated(chainId, txDataHash, alice, tokenWithFeeAssetId, bridgeMintCalldata);
        sharedBridge.bridgehubDeposit(chainId, alice, 0, depositData);

        assertEq(tokenWithFee.balanceOf(alice), 0);
        uint amountMinusFee = amount - (amount / 10);
        assertEq(tokenWithFee.balanceOf(address(nativeTokenVault)), amountMinusFee);
    }

```

Run tests

```bash
forge test --match-test test_bridgehubDepositBaseToken_ErcWithFee -vvvv
forge test --match-test test_bridgehubDeposit_ErcWithFee -vvvv
```

### `L2AssetRouter._ensureTokenRegisteredWithNTV` `assetId` return value is never assigned, which will cause `withdrawToken` to fail

Submission ID: `cm3yfmizg0005arsccljq0gci`  
Severity: Medium

## Summary

The `_ensureTokenRegisteredWithNTV` function in the [`L2AssetRouter.sol`](https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/era-contracts/l1-contracts/contracts/bridge/asset-router/L2AssetRouter.sol#L164-L164) contract does not assign a value to the `assetId` return variable. This will cause functions that rely on the `assetId` return value to fail, such as `_withdrawSender` during `IAssetHandler.bridgeBurn`, `IAssetRouterBase.finalizeDeposit`, or revert with `AssetIdNotSupported`.

## Vulnerability Details

The `_ensureTokenRegisteredWithNTV` function is defined to return a `bytes32 assetId`. However, within the function body, `assetId` is never assigned a value. As a result, the function will return the default value of `bytes32(0)`, and functions relying on it will revert

### Proof of Concept

Run with `yarn l1 test:foundry --match-test test_withdrawTokenFromGateway -vvvvv`. The test will revert due to the issue above, when it should not.

```diff
diff --git a/era-contracts/l1-contracts/contracts/bridge/asset-router/IL2AssetRouter.sol b/era-contracts/l1-contracts/contracts/bridge/asset-router/IL2AssetRouter.sol
index 32f9307..28e6c16 100644
--- a/era-contracts/l1-contracts/contracts/bridge/asset-router/IL2AssetRouter.sol
+++ b/era-contracts/l1-contracts/contracts/bridge/asset-router/IL2AssetRouter.sol
@@ -16,6 +16,8 @@ interface IL2AssetRouter is IAssetRouterBase {
 
     function withdraw(bytes32 _assetId, bytes calldata _transferData) external returns (bytes32);
 
+    function withdrawToken(address _l2NativeToken, bytes memory _assetData) external returns (bytes32);
+
     function L1_ASSET_ROUTER() external view returns (address);
 
     function withdrawLegacyBridge(address _l1Receiver, address _l2Token, uint256 _amount, address _sender) external;
diff --git a/era-contracts/l1-contracts/test/foundry/l1/integration/l2-tests-in-l1-context/L2GatewayTestAbstract.t.sol b/era-contracts/l1-contracts/test/foundry/l1/integration/l2-tests-in-l1-context/L2GatewayTestAbstract.t.sol
index e97c201..3c6dba2 100644
--- a/era-contracts/l1-contracts/test/foundry/l1/integration/l2-tests-in-l1-context/L2GatewayTestAbstract.t.sol
+++ b/era-contracts/l1-contracts/test/foundry/l1/integration/l2-tests-in-l1-context/L2GatewayTestAbstract.t.sol
@@ -65,6 +65,25 @@ abstract contract L2GatewayTestAbstract is Test, SharedL2ContractDeployer {
         l2AssetRouter.withdraw(ctmAssetId, abi.encode(data));
     }
 
+    function test_withdrawTokenFromGateway() public {
+        finalizeDeposit();
+        address newAdmin = address(0x1);
+        bytes memory newDiamondCut = abi.encode();
+        BridgehubBurnCTMAssetData memory data = BridgehubBurnCTMAssetData({
+            chainId: mintChainId,
+            ctmData: abi.encode(newAdmin, config.contracts.diamondCutData),
+            chainData: abi.encode(chainTypeManager.protocolVersion())
+        });
+        vm.prank(ownerWallet);
+        vm.mockCall(
+            address(L2_MESSENGER),
+            abi.encodeWithSelector(L2_MESSENGER.sendToL1.selector),
+            abi.encode(bytes(""))
+        );
+        address l2NativeToken = address(weth);
+        l2AssetRouter.withdrawToken(l2NativeToken, abi.encode(data));
+    }
+
     function finalizeDeposit() public {
         bytes memory chainData = exampleChainCommitment;
         bytes memory ctmData = abi.encode(
diff --git a/era-contracts/l1-contracts/test/foundry/l1/integration/l2-tests-in-l1-context/_SharedL2ContractDeployer.sol b/era-contracts/l1-contracts/test/foundry/l1/integration/l2-tests-in-l1-context/_SharedL2ContractDeployer.sol
index b0c0ac6..10296c3 100644
--- a/era-contracts/l1-contracts/test/foundry/l1/integration/l2-tests-in-l1-context/_SharedL2ContractDeployer.sol
+++ b/era-contracts/l1-contracts/test/foundry/l1/integration/l2-tests-in-l1-context/_SharedL2ContractDeployer.sol
@@ -95,7 +95,7 @@ abstract contract SharedL2ContractDeployer is Test, DeployUtils {
             beaconProxyBytecodeHash
         );
 
-        L2WrappedBaseToken weth = deployL2Weth();
+        weth = deployL2Weth();
 
         initSystemContracts(
             SystemContractsArgs({

```

## Impact

`L2AssetRouter.withdrawToken` will revert due to an incorrect `bytes32(0)` assetId value.

## Tools Used

Manual code review

## Recommendations

Ensure that the assetId return value is properly assigned within the `_ensureTokenRegisteredWithNTV` function.

```diff
diff --git a/era-contracts/l1-contracts/contracts/bridge/asset-router/L2AssetRouter.sol b/era-contracts/l1-contracts/contracts/bridge/asset-router/L2AssetRouter.sol
index 04d92e3..2bbe9d2 100644
--- a/era-contracts/l1-contracts/contracts/bridge/asset-router/L2AssetRouter.sol
+++ b/era-contracts/l1-contracts/contracts/bridge/asset-router/L2AssetRouter.sol
@@ -164,6 +164,7 @@ contract L2AssetRouter is AssetRouterBase, IL2AssetRouter {
     function _ensureTokenRegisteredWithNTV(address _token) internal override returns (bytes32 assetId) {
         IL2NativeTokenVault nativeTokenVault = IL2NativeTokenVault(L2_NATIVE_TOKEN_VAULT_ADDR);
         nativeTokenVault.ensureTokenIsRegistered(_token);
+        assetId = nativeTokenVault.assetId(_token);
     }
 
     /// @notice Initiates a withdrawal by burning funds on the contract and sending the message to L1

```

### Inverted use of boolean value in `L2NativeTokenVault.constructor` would cause revert or unnecessary deployment of `bridgedTokenBeacon`

Submission ID: `cm46ybjib001j72j7aff9avil`  
Severity: Medium

## Summary

The `L2GatewayUpgradeHelper._getForceDeploymentsData` function in `L2GatewayUpgradeHelper` provides the `ForceDeployment` struct used to deploy the `L2NativeTokenVault`. However, the boolean value passed as `shouldDeployBeacon` is interpreted as `_contractsDeployedAlready` in the L2NativeTokenVault constructor, resulting in an inverted deployment process.

## Vulnerability Details

[`L2NativeTokenVault`](https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/era-contracts/l1-contracts/contracts/bridge/ntv/L2NativeTokenVault.sol#L54) is deployed using `L2GatewayUpgradeHelper.performForceDeployedContractsInit` function and its constructor data is provided by [`_getForceDeploymentsData`](https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/era-contracts/system-contracts/contracts/L2GatewayUpgradeHelper.sol#L151-L170) function as `forceDeployments[3]`:

```solidity
    function _getForceDeploymentsData(
        bytes memory _fixedForceDeploymentsData,
        bytes memory _additionalForceDeploymentsData
    ) internal returns (ForceDeployment[] memory forceDeployments) {
        ...
        address deployedTokenBeacon;
        if (additionalForceDeploymentsData.l2LegacySharedBridge != address(0)) {
            deployedTokenBeacon = address(
                IL2SharedBridgeLegacy(additionalForceDeploymentsData.l2LegacySharedBridge).l2TokenBeacon()
            );
        }

        bool shouldDeployBeacon = deployedTokenBeacon == address(0);

        // Configure the Native Token Vault deployment.
>>      forceDeployments[3] = ForceDeployment({
            bytecodeHash: fixedForceDeploymentsData.l2NtvBytecodeHash,
            newAddress: L2_NATIVE_TOKEN_VAULT_ADDR,
            callConstructor: true,
            value: 0,
            // solhint-disable-next-line func-named-parameters
            input: abi.encode(
                fixedForceDeploymentsData.l1ChainId,
                fixedForceDeploymentsData.aliasedL1Governance,
                fixedForceDeploymentsData.l2TokenProxyBytecodeHash,
                additionalForceDeploymentsData.l2LegacySharedBridge,
                deployedTokenBeacon,
>>              shouldDeployBeacon,
                wrappedBaseTokenAddress,
                additionalForceDeploymentsData.baseTokenAssetId
            )
        });
    }
```

As outlined above, `shouldDeployBeacon` represents whether to deploy tokenBeacon as it reflects the status of `deployedTokenBeacon` being address(0). However, on the receiving end (constructor of [`L2NativeTokenVault`](https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/era-contracts/l1-contracts/contracts/bridge/ntv/L2NativeTokenVault.sol#L54)), `shouldDeployBeacon` is decoded as `_contractsDeployedAlready`:

```solidity
    constructor(
        uint256 _l1ChainId,
        address _aliasedOwner,
        bytes32 _l2TokenProxyBytecodeHash,
        address _legacySharedBridge,
        address _bridgedTokenBeacon,
>>      bool _contractsDeployedAlready,
        address _wethToken,
        bytes32 _baseTokenAssetId
    ) NativeTokenVault(_wethToken, L2_ASSET_ROUTER_ADDR, _baseTokenAssetId, _l1ChainId) {
        L2_LEGACY_SHARED_BRIDGE = IL2SharedBridgeLegacy(_legacySharedBridge);

        if (_l2TokenProxyBytecodeHash == bytes32(0)) {
            revert EmptyBytes32();
        }
        if (_aliasedOwner == address(0)) {
            revert EmptyAddress();
        }

        L2_TOKEN_PROXY_BYTECODE_HASH = _l2TokenProxyBytecodeHash;
        _transferOwnership(_aliasedOwner);

>>      if (_contractsDeployedAlready) {
            if (_bridgedTokenBeacon == address(0)) {
                revert EmptyAddress();
            }
            bridgedTokenBeacon = IBeacon(_bridgedTokenBeacon);
        } else {
            address l2StandardToken = address(new BridgedStandardERC20{salt: bytes32(0)}());

            UpgradeableBeacon tokenBeacon = new UpgradeableBeacon{salt: bytes32(0)}(l2StandardToken);

            tokenBeacon.transferOwnership(owner());
            bridgedTokenBeacon = IBeacon(address(tokenBeacon));
            emit L2TokenBeaconUpdated(address(bridgedTokenBeacon), _l2TokenProxyBytecodeHash);
        }
    }
```

The boolean value is interpreted in the opposite way, which leads to a whole inverted process of deployment. When

* `_contractsDeployedAlready` is true (`shouldDeployBeacon` is true): it will revert as `_bridgedTokenBeacon` is address(0)
* `_contractsDeployedAlready` is false (`shouldDeployBeacon` is false): it will create a new `bridgedTokenBeacon` despite having a valid `_bridgedTokenBeacon` passed in constructor

## Impact

This causes an inverted deployment process, which leads to either a revert when `_contractsDeployedAlready` is true or the unnecessary creation of a new `bridgedTokenBeacon` when it is false. Ultimately it blocks the L2 genesis upgrade in the absence of a legacy shared bridge.

## Tools Used

Manual Review

## Recommendations

Provide the correct boolean value to `ForceDeployment` to properly configure the native token vault deployment, ensuring alignment with the logic defined in the `L2NativeTokenVault` constructor:

```diff
    function _getForceDeploymentsData(
        bytes memory _fixedForceDeploymentsData,
        bytes memory _additionalForceDeploymentsData
    ) internal returns (ForceDeployment[] memory forceDeployments) {
        ...
        address deployedTokenBeacon;
        if (additionalForceDeploymentsData.l2LegacySharedBridge != address(0)) {
            deployedTokenBeacon = address(
                IL2SharedBridgeLegacy(additionalForceDeploymentsData.l2LegacySharedBridge).l2TokenBeacon()
            );
        }

-       bool shouldDeployBeacon = deployedTokenBeacon == address(0);
+       bool contractsDeployedAlready = deployedTokenBeacon != address(0);

        // Configure the Native Token Vault deployment.
        forceDeployments[3] = ForceDeployment({
            bytecodeHash: fixedForceDeploymentsData.l2NtvBytecodeHash,
            newAddress: L2_NATIVE_TOKEN_VAULT_ADDR,
            callConstructor: true,
            value: 0,
            // solhint-disable-next-line func-named-parameters
            input: abi.encode(
                fixedForceDeploymentsData.l1ChainId,
                fixedForceDeploymentsData.aliasedL1Governance,
                fixedForceDeploymentsData.l2TokenProxyBytecodeHash,
                additionalForceDeploymentsData.l2LegacySharedBridge,
                deployedTokenBeacon,
-               shouldDeployBeacon,
+               contractsDeployedAlready,
                wrappedBaseTokenAddress,
                additionalForceDeploymentsData.baseTokenAssetId
            )
        });
    }
```

### Migration blocked due to chain limit in `MessageRoot` contract

Submission ID: `cm443sodn0007wwxdw2t52hws`  
Severity: Medium

## Summary

The protocol's goal of enabling migration to any chain is failed when the maximum number of chains is reached, as this prevents further migrations.

## Vulnerability Details

The protocol intends to permit any chain to be migrated, even when the maximum chain limit has been reached:
[Link to source](https://github.com/Cyfrin/2024-10-zksync/blob/main/era-contracts/l1-contracts/contracts/bridgehub/Bridgehub.sol#L775)

To achieve this, when `bridgeMint` is invoked during migration on the destination chain, it registers the new zk chain with the `_checkMaxNumberOfZKChains` flag set to **false**. This flag bypasses the `MAX_NUMBER_OF_ZK_CHAINS` limit, allowing the registration of new chains regardless of the existing limit:

```solidity
    function _registerNewZKChain(uint256 _chainId, address _zkChain, bool _checkMaxNumberOfZKChains) internal {
        // slither-disable-next-line unused-return
        zkChainMap.set(_chainId, _zkChain);
        if (_checkMaxNumberOfZKChains && zkChainMap.length() > MAX_NUMBER_OF_ZK_CHAINS) {
            revert ZKChainLimitReached();
        }
    }
```

[Link to source](https://github.com/Cyfrin/2024-10-zksync/blob/main/era-contracts/l1-contracts/contracts/bridgehub/Bridgehub.sol#L387)

However, simply setting the flag to `false` is insufficient to bypass the limit when registering a new zk chain, as the new chain also needs to be added to the message root. This addition triggers another check for the `MAX_NUMBER_OF_ZK_CHAINS` limit:
[Link to source](https://github.com/Cyfrin/2024-10-zksync/blob/main/era-contracts/l1-contracts/contracts/bridgehub/Bridgehub.sol#L777)

This function also performs the same check for the chain limit:

```solidity
    function _addNewChain(uint256 _chainId) internal {
        uint256 cachedChainCount = chainCount;
        if (cachedChainCount >= MAX_NUMBER_OF_ZK_CHAINS) {
            revert TooManyChains(cachedChainCount, MAX_NUMBER_OF_ZK_CHAINS);
        }

        ++chainCount;
        chainIndex[_chainId] = cachedChainCount;
        chainIndexToId[cachedChainCount] = _chainId;

        // slither-disable-next-line unused-return
        bytes32 initialHash = chainTree[_chainId].setup(CHAIN_TREE_EMPTY_ENTRY_HASH);

        // slither-disable-next-line unused-return
        sharedTree.pushNewLeaf(MessageHashing.chainIdLeafHash(initialHash, _chainId));

        emit AddedChain(_chainId, cachedChainCount);
    }
```

[Link to source](https://github.com/Cyfrin/2024-10-zksync/blob/main/era-contracts/l1-contracts/contracts/bridgehub/MessageRoot.sol#L154)

Currently, the maximum number of zk chains (`MAX_NUMBER_OF_ZK_CHAINS`) is set to 100:
[Link to source](https://github.com/Cyfrin/2024-10-zksync/blob/main/era-contracts/l1-contracts/contracts/common/Config.sol#L118)

If 100 chains have already been added, the maximum limit is reached. In such a case, migrating any additional chains should still be allowed as per the protocol's objectives. The protocol states:

> We want to allow any chain to be migrated,
> [Link to source](https://github.com/Cyfrin/2024-10-zksync/blob/main/era-contracts/l1-contracts/contracts/bridgehub/Bridgehub.sol#L775)

Additionally, there is a note that:

> Note, that in case of a malicious Bridgehub admin, the total number of chains can be up to 2 times higher. This may be possible, in case the old ChainTypeManager had 100 chains and these were migrated to the Bridgehub only after MAX\_NUMBER\_OF\_ZK\_CHAINS were added to the bridgehub via creation of new chains.
> [Link to source](https://github.com/Cyfrin/2024-10-zksync/blob/main/era-contracts/l1-contracts/contracts/common/Config.sol#L114-L117)

However, the chain count is also limited in the `MessageRoot` contract, and if the limit of 100 chains is reached, the process will fail with a `TooManyChains` error:
[Link to source](https://github.com/Cyfrin/2024-10-zksync/blob/main/era-contracts/l1-contracts/contracts/bridgehub/MessageRoot.sol#L155)

## Impact

The protocol aims to allow migration of any chain, even when the maximum number of chains has been reached, but the current implementation in the `MessageRoot` contract prevents this functionality.

## Tools Used

## Recommendations

The same mechanism for bypassing the `MAX_NUMBER_OF_ZK_CHAINS` limit (i.e., using the `_checkMaxNumberOfZKChains` flag) should be implemented in the `MessageRoot` contract to ensure that migrations can proceed even after the maximum number of chains is reached.

### A newly created chain that has been migrated to the gateway will be lost if tries to migrate back to L1

Submission ID: `cm462qmx1000514d2xlq9fv7w`  
Severity: Medium

## Summary
A newly created chain that has been migrated to the gateway will be lost if tries to migrate back to L1

## Vulnerability Details

When a new chain is created, the `priorityTree` is initialized:

```Solidity
contract DiamondInit is ZKChainBase, IDiamondInit {
    using PriorityQueue for PriorityQueue.Queue;
    using PriorityTree for PriorityTree.Tree;

    /// @dev Initialize the implementation to prevent any possibility of a Parity hack.
    constructor() reentrancyGuardInitializer {}

    /// @notice ZK chain diamond contract initialization
    /// @return Magic 32 bytes, which indicates that the contract logic is expected to be used as a diamond proxy
    /// initializer
    function initialize(InitializeData calldata _initializeData) external reentrancyGuardInitializer returns (bytes32) {
        
        ...

        s.priorityTree.setup(s.priorityQueue.getTotalPriorityTxs());

        ...

        return Diamond.DIAMOND_INIT_SUCCESS_RETURN_VALUE;
    }
}

library PriorityTree {
    using PriorityTree for Tree;
    using DynamicIncrementalMerkle for DynamicIncrementalMerkle.Bytes32PushTree;

    ...

    /// @notice Set up the tree
    function setup(Tree storage _tree, uint256 _startIndex) internal {
        _tree.tree.setup(ZERO_LEAF_HASH);
        _tree.startIndex = _startIndex;
    }

    ...
}

library DynamicIncrementalMerkle {

    function setup(Bytes32PushTree storage self, bytes32 zero) internal returns (bytes32 initialRoot) {
        self._nextLeafIndex = 0;
        self._zeros.push(zero);
        self._sides.push(bytes32(0));
        return bytes32(0);
    }
}
```

The setup simply creates the first leaf as a bytes32(0) and initializes the `startIndex` to the priority queue transactions.
At this point, no hashes are registered in `historicalRoots` mapping.

Now let's follow the flow to migrate the chain from L1 to the GateWay:

* The `forwardedBridgeBurn` function will be called on the Diamond of the newly created chain on L1:

```Solidity
    function forwardedBridgeBurn(
        address _settlementLayer,
        address _originalCaller,
        bytes calldata _data
    ) external payable override onlyBridgehub returns (bytes memory chainBridgeMintData) {
        ...

        s.settlementLayer = _settlementLayer;
        chainBridgeMintData = abi.encode(prepareChainCommitment());
    }

    function prepareChainCommitment() public view returns (ZKChainCommitment memory commitment) {
        ...

        commitment.priorityTree = s.priorityTree.getCommitment();
        
        ...
    }
```

The `chainBridgeMintData` will contain all the data from the priority tree.

```Solidity
    function getCommitment(Tree storage _tree) internal view returns (PriorityTreeCommitment memory commitment) {
        commitment.nextLeafIndex = _tree.tree._nextLeafIndex;
        commitment.startIndex = _tree.startIndex;
        commitment.unprocessedIndex = _tree.unprocessedIndex;
        commitment.sides = _tree.tree._sides;
    }
```

The `sides` will simply contain the bytes32(0) leaf from the previous setup.

* On the gateway it will first deploy the diamond contract for the new chain and the then call the `forwardedBridgeMint` function on it:

```Solidity
    function forwardedBridgeMint(
        bytes calldata _data,
        bool _contractAlreadyDeployed
    ) external payable override onlyBridgehub {
...

        if (block.chainid == L1_CHAIN_ID) {
            // L1 PTree contains all L1->L2 transactions.
            if (
                !s.priorityTree.isHistoricalRoot(
                    _commitment.priorityTree.sides[_commitment.priorityTree.sides.length - 1]
                )
            ) {
                revert NotHistoricalRoot();
            }
            if (!_contractAlreadyDeployed) {
                revert ContractNotDeployed();
            }
            if (s.settlementLayer == address(0)) {
                revert NotMigrated();
            }
            s.priorityTree.l1Reinit(_commitment.priorityTree);
        } else if (_contractAlreadyDeployed) {
            if (s.settlementLayer == address(0)) {
                revert NotMigrated();
            }
            s.priorityTree.checkGWReinit(_commitment.priorityTree);
            s.priorityTree.initFromCommitment(_commitment.priorityTree);
        } else {
            s.priorityTree.initFromCommitment(_commitment.priorityTree);
        }

        ...
    }
```

In this if branch will enter the last one because the contract has been newly deployed. Hence, will call `priorityTree::initFromCommitment`:

```Solidity
    function initFromCommitment(Tree storage _tree, PriorityTreeCommitment memory _commitment) internal {
        uint256 height = _commitment.sides.length; // Height, including the root node.
        if (height == 0) {
            revert InvalidCommitment();
        }
        _tree.startIndex = _commitment.startIndex;
        _tree.unprocessedIndex = _commitment.unprocessedIndex;
        _tree.tree._nextLeafIndex = _commitment.nextLeafIndex;
        _tree.tree._sides = _commitment.sides;
        bytes32 zero = ZERO_LEAF_HASH;
        _tree.tree._zeros = new bytes32[](height);
        for (uint256 i; i < height; ++i) {
            _tree.tree._zeros[i] = zero;
            zero = Merkle.efficientHash(zero, zero);
        }
        _tree.historicalRoots[_tree.tree.root()] = true;
    }
```

This will just set the only side to the `bytes32(0)` leaf.
At this point, if the chain decides to migrate back to L1 it will be lost. Let's see why:

* The `forwardedBridgeBurn` function will be called on the Diamond chain on GW:

```Solidity
    function forwardedBridgeBurn(
        address _settlementLayer,
        address _originalCaller,
        bytes calldata _data
    ) external payable override onlyBridgehub returns (bytes memory chainBridgeMintData) {
        ...

        s.settlementLayer = _settlementLayer;
        chainBridgeMintData = abi.encode(prepareChainCommitment());
    }

    function prepareChainCommitment() public view returns (ZKChainCommitment memory commitment) {
        ...

        commitment.priorityTree = s.priorityTree.getCommitment();
        
        ...
    }
```

The `chainBridgeMintData` will contain all the data from the priority tree.

```Solidity
    function getCommitment(Tree storage _tree) internal view returns (PriorityTreeCommitment memory commitment) {
        commitment.nextLeafIndex = _tree.tree._nextLeafIndex;
        commitment.startIndex = _tree.startIndex;
        commitment.unprocessedIndex = _tree.unprocessedIndex;
        commitment.sides = _tree.tree._sides;
    }
```

The commitment data will be exactly the same as the first migration. However, when this will arrive in L1 this will happen:

* On L1 it will call the `forwardedBridgeMint` function on the diamond contract from the chain:

```Solidity
    function forwardedBridgeMint(
        bytes calldata _data,
        bool _contractAlreadyDeployed
    ) external payable override onlyBridgehub {
...

        if (block.chainid == L1_CHAIN_ID) {
            // L1 PTree contains all L1->L2 transactions.
            if (
                !s.priorityTree.isHistoricalRoot(
                    _commitment.priorityTree.sides[_commitment.priorityTree.sides.length - 1]
                )
            ) {
                revert NotHistoricalRoot();
            }
            if (!_contractAlreadyDeployed) {
                revert ContractNotDeployed();
            }
            if (s.settlementLayer == address(0)) {
                revert NotMigrated();
            }
            s.priorityTree.l1Reinit(_commitment.priorityTree);
        } else if (_contractAlreadyDeployed) {
            if (s.settlementLayer == address(0)) {
                revert NotMigrated();
            }
            s.priorityTree.checkGWReinit(_commitment.priorityTree);
            s.priorityTree.initFromCommitment(_commitment.priorityTree);
        } else {
            s.priorityTree.initFromCommitment(_commitment.priorityTree);
        }

        ...
    }
```

Now, it will enter the first if branch because it will be executed on L1. The first check is if the only `side` from the commitment (bytes32(0)) is an historical root from the priority tree. As we can see, no historical root is registered on the setup, hence this check will fail.

## Impact

High, the chain will be lost as stated in the docs:

> Migrations from GW to L1 do not have any chain recovery mechanism, i.e. if the step (3) from the above fails for some reason (e.g. a new protocol version id is available on the CTM), then the chain is basically lost.


## Tools Used

Manual review

## Recommendations

Register the initial bytes32(0) leaf as historical root upon setup:

```diff
    function setup(Tree storage _tree, uint256 _startIndex) internal {
        _tree.tree.setup(ZERO_LEAF_HASH);
        _tree.startIndex = _startIndex;
++      _tree.historicalRoots[bytes32(0)] = true;
    }
```

## Low Risk Findings

### Incorrect Z-coordinate usage in G2 scalar multiplication causes invalid pairing computations

Submission ID: `cm42cvmd30003ayd3n3tn4jmi`  
Severity: Low

## Summary

In `g2ScalarMul` function in the EcPairing precompile, when performing scalar multiplication by 2, the function incorrectly passes the y-coordinate (`yp1`) instead of the z-coordinate (`zp1`) as the last parameter to `g2JacobianDouble`. This incorrect coordinate usage corrupts the resulting point computation affecting the pairing-based cryptographic operations in the ZKSync Era protocol.

## Proof of Concept

<https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/era-contracts/system-contracts/contracts/precompiles/EcPairing.yul#L683>

```solidity
679:             function g2ScalarMul(xp0, xp1, yp0, yp1, zp0, zp1, scalar) -> xr0, xr1, yr0, yr1, zr0, zr1 {
680:                 let scalarBitIndex := bitLen(scalar)
681:                 switch scalar
682:                 case 0x02 {
683:     @>              xr0, xr1, yr0, yr1, zr0, zr1 := g2JacobianDouble(xp0, xp1, yp0, yp1, zp0, yp1)
684:                 }
685:                 default {
686:                     xr0 := 0
687:                     xr1 := 0
688:                     yr0 := MONTGOMERY_ONE()
689:                     yr1 := 0
690:                     zr0 := 0
691:                     zr1 := 0
692:                     for {} scalarBitIndex {} {
693:                         scalarBitIndex := sub(scalarBitIndex, 1)
694:                         xr0, xr1, yr0, yr1, zr0, zr1 := g2JacobianDouble(xr0, xr1, yr0, yr1, zr0, zr1)
695:                         let bitindex := checkBit(scalarBitIndex, scalar)
696:                         if bitindex {
697:                             xr0, xr1, yr0, yr1, zr0, zr1 := g2JacobianAdd(xp0, xp1, yp0, yp1, zp0, zp1, xr0, xr1, yr0, yr1, zr0, zr1)
698:                         }
699:                         
700:                     }
701:                 }
702:             }
```

The impact of using `yp1` instead of `zp1` in the `g2JacobianDouble` call is a severe because:

In Jacobian coordinates, a point (X:Y:Z) represents the affine point:

$\left(\frac{X}{Z^2}, \frac{Y}{Z^3}\right)$

Using the wrong Z-coordinate (`yp1` instead of `zp1`) will result in completely incorrect affine points.

Consider a point `P` on the `G2` curve in Jacobian coordinates `(X:Y:Z)` where:

```Solidity
P = (X:Y:Z) = (xp0,xp1 : yp0,yp1 : zp0,zp1)
```

When we double this point (multiply by 2), with the bug:

```yul
// BUGGY version
g2JacobianDouble(xp0, xp1, yp0, yp1, zp0, yp1)  // Uses yp1 instead of zp1
```

Let's say we have these values:

```Solidity
xp0 = 1
xp1 = 2
yp0 = 3
yp1 = 4  // This will be incorrectly used as Z coordinate!
zp0 = 5
zp1 = 6  // This should have been used
```

In the [`g2JacobianDouble` function](https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/era-contracts/system-contracts/contracts/precompiles/EcPairing.yul#L572-L573), it performs calculations like:

```yul
function g2JacobianDouble(xp0, xp1, yp0, yp1, zp0, zp1) {
    // Key calculations that will be wrong:
    let t80, t81 := fp2Mul(yp0, yp1, zp0, zp1)  // Computes Y1*Z1
    zr0, zr1 := fp2Add(t80, t81, t80, t81)      // Computes Z3 = 2*t8
    ...
}
```

The bug causes:

1. Wrong Z-coordinate multiplication: `Y1*Z1` uses `(zp0,yp1)` instead of `(zp0,zp1)`
2. This affects the computation of the new Z-coordinate (`Z3`)
3. Since in Jacobian coordinates (X:Y:Z) represents the affine point (X/Z², Y/Z³), the error propagates exponentially

For example:

```Solidity
Correct calculation would use:
Z1 = (5,6)
Y1*Z1 = (yp0,yp1)*(5,6)

Incorrect calculation uses:
Z1 = (5,4)  // Wrong!
Y1*Z1 = (yp0,yp1)*(5,4)
```

This leads to wrong Z-coordinate in the result. When converting back to affine coordinates (X/Z², Y/Z³), the point will be completely wrong. Any subsequent pairing calculations using this point will fail or produce invalid results

The impact is magnified because:

```Solidity
Affine x = X/Z²
Affine y = Y/Z³
```

So the error in Z is amplified quadratically and cubically in the final affine coordinates.
Using the example above,

```Solidity
With correct Z = (5,6):
Z² = (5,6)² = (25-36, 60) = (-11,60)

With incorrect Z = (5,4):
Z² = (5,4)² = (25-16, 40) = (9,40)

This gives us completely different affine coordinates:
Correct: x_affine = X/(-11,60)
Incorrect:   x_affine = X/(9,40)
```

This shows how a single wrong/misplaced coordinate in the Jacobian double operation leads to completely invalid results in the G2 curve arithmetic, which would break any pairing-based cryptographic operations in the protocol.

## Recommendation

```diff
--- a/era-contracts/system-contracts/contracts/precompiles/EcPairing.yul
+++ b/era-contracts/system-contracts/contracts/precompiles/EcPairing.yul
@@ -682,7 +682,7 @@ object "EcPairing" {
     let scalarBitIndex := bitLen(scalar)
     switch scalar
     case 0x02 {
-        xr0, xr1, yr0, yr1, zr0, zr1 := g2JacobianDouble(xp0, xp1, yp0, yp1, zp0, yp1)
+        xr0, xr1, yr0, yr1, zr0, zr1 := g2JacobianDouble(xp0, xp1, yp0, yp1, zp0, zp1)
     }
    ...SNIP
 }
```

### logic to calcute gas for sha256 is different for precompile and L1Messenger

Submission ID: `cm361xewq0005rlpnlinlpnrs`  
Severity: Low

## Summary

Discrepency between logic for calculating sha gas cost lead to either to overchargin or underchaning users.

## Vulnerability Details

Lets compare how two funcitons calculate number of rounds

```solidity

            // Copy calldata to memory for pad it
            let bytesSize := calldatasize()
            calldatacopy(0, 0, bytesSize)

            // The sha256 padding includes additional 8 bytes of the total message's length in bits,
            // so calculate the "full" message length with it.
            let extendBytesLen := add(bytesSize, 8)

            let padLen := sub(BLOCK_SIZE(), mod(extendBytesLen, BLOCK_SIZE())) // @ additional variable compare to l1messager
            let paddedBytesSize := add(extendBytesLen, padLen)

            let numRounds := div(paddedBytesSize, BLOCK_SIZE())
            let precompileParams := unsafePackPrecompileParams(
                0,                        // input offset in words
                // Always divisible by 32, since `BLOCK_SIZE()` is 64 bytes
                div(paddedBytesSize, 32), // input length in words (safe to pass, never exceed `type(uint32).max`)
                0,                        // output offset in words
                1,                        // output length in words
                numRounds                 // number of rounds (safe to pass, never exceed `type(uint64).max`)
            )
            let gasToPay := mul(SHA256_ROUND_GAS_COST(), numRounds)
```

[precompiles/SHA256.yul#L70](https://github.com/Cyfrin/2024-10-zksync/blob/b0c5565b6078a93cc3358a5d5012258caa701385/era-contracts/system-contracts/contracts/precompiles/SHA256.yul#L70)

```solidity
    function sha256GasCost(uint256 _length) internal pure returns (uint256) {
        return SHA256_ROUND_GAS_COST * ((_length + 8) / SHA256_ROUND_NUMBER_OF_BYTES + 1);
    }

```

[/L1Messenger.sol#L65](https://github.com/Cyfrin/2024-10-zksync/blob/b0c5565b6078a93cc3358a5d5012258caa701385/era-contracts/system-contracts/contracts/L1Messenger.sol#L65)

As we can see `padLen := sub(BLOCK_SIZE(), mod(extendBytesLen, BLOCK_SIZE()))` is not in a formula inside l1messagner.

## Impact

Incorrect gas cost would be charged in l1messager

## Tools Used

## Recommendations

Align cost in l1messager with precompile formula

### Lack of proposal expiry mechanisms can lead to governance exploits.

Submission ID: `cm33bnmo10003cjq77m27cw6k`  
Severity: Low

## Summary

Approved proposals could remain in a Ready state indefinitely, and malicious user can take advantage of this and execute the proposal under different conditions than the one under which the proposal was submitted.

## Vulnerability Details

After [security Council](https://github.com/Cyfrin/2024-10-zksync/blob/main/zk-governance/l1-contracts/src/ProtocolUpgradeHandler.sol#L269-L278) or [Guardian](https://github.com/Cyfrin/2024-10-zksync/blob/main/zk-governance/l1-contracts/src/ProtocolUpgradeHandler.sol#L283-L291) approves the proposal a delay will starts example in [security Council](https://github.com/Cyfrin/2024-10-zksync/blob/main/zk-governance/l1-contracts/src/ProtocolUpgradeHandler.sol#L269-L278) case [upgradeStatus\[id\].securityCouncilApprovalTimestamp = uint48(block.timestamp)](https://github.com/Cyfrin/2024-10-zksync/blob/main/zk-governance/l1-contracts/src/ProtocolUpgradeHandler.sol#L275)\
a timestamp will be set to `securityCouncilApprovalTimestamp` and when this delay passes the proposal will be ready to be executed now the proposal creator will be able to execute the proposal.

The problem occurs when the executor does not call `ProtocolUpgradeHandler::execute` in this case the proposal will be in Ready state for ever without a way to make it expire.

1. The [approveUpgradeSecurityCouncil](https://github.com/Cyfrin/2024-10-zksync/blob/main/zk-governance/l1-contracts/src/ProtocolUpgradeHandler.sol#L269) function sets the [securityCouncilApprovalTimestamp](https://github.com/Cyfrin/2024-10-zksync/blob/main/zk-governance/l1-contracts/src/ProtocolUpgradeHandler.sol#L275) for a proposal when it is approved.
2. The [upgradeState](https://github.com/Cyfrin/2024-10-zksync/blob/main/zk-governance/l1-contracts/src/ProtocolUpgradeHandler.sol#L179) function determines the state of the proposal as follows:
   * If the [securityCouncilApprovalTimestamp](https://github.com/Cyfrin/2024-10-zksync/blob/main/zk-governance/l1-contracts/src/ProtocolUpgradeHandler.sol#L199-L204) is not `0`, the proposal transitions to `ExecutionPending` or `Ready` based on whether the [UPGRADE\_DELAY\_PERIOD](https://github.com/Cyfrin/2024-10-zksync/blob/main/zk-governance/l1-contracts/src/ProtocolUpgradeHandler.sol#L46) has elapsed.
   * Once the proposal is ready, it can be executed by calling the [execute](https://github.com/Cyfrin/2024-10-zksync/blob/main/zk-governance/l1-contracts/src/ProtocolUpgradeHandler.sol#L295-L309) function.
3. However, if the [execute](https://github.com/Cyfrin/2024-10-zksync/blob/main/zk-governance/l1-contracts/src/ProtocolUpgradeHandler.sol#L295-L309) function is not called, the proposal remains in a [Ready](https://github.com/Cyfrin/2024-10-zksync/blob/main/zk-governance/l1-contracts/src/ProtocolUpgradeHandler.sol#L202) state forever, as there is no expiry mechanism to transition unexecuted proposals to an [Done](https://github.com/Cyfrin/2024-10-zksync/blob/main/zk-governance/l1-contracts/src/ProtocolUpgradeHandler.sol#L183) state.

# POC:

### Approval Logic

```Solidity
function approveUpgradeSecurityCouncil(bytes32 _id) external onlySecurityCouncil {
      UpgradeState upgState = upgradeState(_id);
      require(upgState == UpgradeState.Waiting, "Upgrade with this id is not waiting for the approval from Security Council");

@>>>  // security council approves the proposal.
@>>>  upgradeStatus[_id].securityCouncilApprovalTimestamp = uint48(block.timestamp);
      emit UpgradeApprovedBySecurityCouncil(_id);
}
```

### State Determination:

After block.timestamp >= upg.securityCouncilApprovalTimestamp + UPGRADE\_DELAY\_PERIOD;

```solidity
function upgradeState(bytes32 _id) public view returns(UpgradeState) {
      //...
@>>>  if (upg.securityCouncilApprovalTimestamp != 0) {
          uint256 readyWithSecurityCouncilTimestamp = upg.securityCouncilApprovalTimestamp + UPGRADE_DELAY_PERIOD;
@>>>      // timestamp is greater than readyWithSecurityCouncilTimestamp so it will  
@>>>      // return Ready state.
          return block.timestamp >= readyWithSecurityCouncilTimestamp
@>>>          ? UpgradeState.Ready
              : UpgradeState.ExecutionPending;
      }
      //...
}
```

### Execution Logic

```Solidity
function execute(UpgradeProposal calldata _proposal) external payable {
      bytes32 id = keccak256(abi.encode(_proposal));
      UpgradeState upgState = upgradeState(id);
      require(upgState == UpgradeState.Ready, "Upgrade is not yet ready");
  
@>>>  // only _proposal.executor can execute the proposal so the proposal 
@>>>  // will be in Ready state and _proposal.executor can execute this when ever he wants.
      require(
          _proposal.executor == address(0) || _proposal.executor == msg.sender,
          "msg.sender is not authorized to perform the upgrade"
      );

      upgradeStatus[id].executed = true;
      _execute(_proposal.calls);
}
```

## Impact

Proposals approved by the Security Council but not executed will remain in an indefinite "Ready" state.

* This could lead to:
  * Stale proposals lingering in the system.
  * Malicious actor could propose an upgrade knowing he won't execute it now but after specific conditions are meet and leaving it in a "Ready" state. When specific conditions align (e.g: changes in the protocol), the actor could execute the proposal to exploit the system.

## Recommendations

Modify the `upgradeState` function to include a new "Expired" state:

File: <https://github.com/Cyfrin/2024-10-zksync/blob/main/zk-governance/l1-contracts/src/ProtocolUpgradeHandler.sol>

```diff
+    uint256 internal constant MAX_PENDING_PERIOD = 60 days;     
     
     function upgradeState(bytes32 _id) public view returns(UpgradeState) {
         if (upg.securityCouncilApprovalTimestamp != 0) {
             uint256 readyWithSecurityCouncilTimestamp = upg.securityCouncilApprovalTimestamp + UPGRADE_DELAY_PERIOD;
+            if (block.timestamp >= readyWithSecurityCouncilTimestamp + MAX_PENDING_PERIOD) {
+                return UpgradeState.Expired;
+            }
             return block.timestamp >= readyWithSecurityCouncilTimestamp
                 ? UpgradeState.Ready
                 : UpgradeState.ExecutionPending;
         }
         
        uint256 waitOrExpiryTimestamp = upg.creationTimestamp + legalVetoTime + UPGRADE_WAIT_OR_EXPIRE_PERIOD;
        if (block.timestamp >= waitOrExpiryTimestamp) {
+           if (!upg.guardiansApproval || block.timestamp >= waitOrExpiryTimestamp + MAX_PENDING_PERIOD) {
                return UpgradeState.Expired;
            }

            uint256 readyWithGuardiansTimestamp = waitOrExpiryTimestamp + UPGRADE_DELAY_PERIOD;
            return block.timestamp >= readyWithGuardiansTimestamp ? UpgradeState.Ready : UpgradeState.ExecutionPending;
        }
     }
```

### Inconsistent Permanent Rollup State Validation in Fee Parameter Updates

Submission ID: `cm46ysuh7000jw8lq9k1pzrsi`  
Severity: Low

### Summary

The `AdminFacet` contract contains an inconsistency in how it enforces permanent rollup state constraints across different fee-related functions. While `setPubdataPricingMode()` and `makePermanentRollup()` properly enforce that permanent rollups must use the `Rollup` pricing mode, the `changeFeeParams()` function lacks this validation. This creates a potential state invariant violation where a permanent rollup chain could have an invalid pricing mode.

While the current implementation of `changeFeeParams()` prevents direct changes to the `pubdataPricingMode`, it doesn't validate that the existing/incoming mode is correct for permanent rollups. This means that if a chain becomes a permanent rollup through state migration (via `forwardedBridgeMint()`), there's no validation ensuring the fee parameters maintain the required `Rollup` pricing mode.

This inconsistency could lead to:

1. State invariant violations where a permanent rollup operates with an invalid pricing mode
2. Potential security issues if other parts of the system assume permanent rollups always use `Rollup` pricing mode
3. Difficulty in upgrading or maintaining the system due to inconsistent state validation

## Proof of Concept

<https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/era-contracts/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L100>

The issue can be demonstrated through the following sequence of operations:

```solidity
// Initial state: Chain is not a permanent rollup, using Validium mode
FeeParams memory initialParams = FeeParams({
    pubdataPricingMode: PubdataPricingMode.Validium,
    ...
});
s.feeParams = initialParams;
s.isPermanentRollup = false;

// 1. Chain becomes permanent rollup through migration
ZKChainCommitment memory commitment = ZKChainCommitment({
    isPermanentRollup: true,
    ...
});
adminFacet.forwardedBridgeMint(abi.encode(commitment), true);
// Now s.isPermanentRollup = true, but fee params still use Validium mode

// 2. Update fee parameters
FeeParams memory newParams = FeeParams({
    pubdataPricingMode: PubdataPricingMode.Validium, // Same as old mode
    ...
});
// This call succeeds despite invalid state
adminFacet.changeFeeParams(newParams);
```

Relevant code references showing the inconsistency:

1. `setPubdataPricingMode()` enforces the constraint:

```solidity
if (s.isPermanentRollup && _pricingMode != PubdataPricingMode.Rollup) {
    revert IncorrectPricingMode();
}
```

1. `changeFeeParams()` lacks the same validation:

```solidity
if (_newFeeParams.pubdataPricingMode != oldFeeParams.pubdataPricingMode) {
    revert InvalidPubdataPricingMode();
}
```

## Recommended mitigation steps

Add permanent rollup state validation to the `changeFeeParams()` function:

```solidity
function changeFeeParams(FeeParams calldata _newFeeParams) external onlyAdminOrChainTypeManager onlyL1 {
    if (_newFeeParams.maxPubdataPerBatch < _newFeeParams.priorityTxMaxPubdata) {
        revert PriorityTxPubdataExceedsMaxPubDataPerBatch();
    }

    FeeParams memory oldFeeParams = s.feeParams;

    // we cannot change pubdata pricing mode
    if (_newFeeParams.pubdataPricingMode != oldFeeParams.pubdataPricingMode) {
        revert InvalidPubdataPricingMode();
    }

    // Add validation for permanent rollup state
    if (s.isPermanentRollup && _newFeeParams.pubdataPricingMode != PubdataPricingMode.Rollup) {
        revert IncorrectPricingMode();
    }

    s.feeParams = _newFeeParams;

    emit NewFeeParams(oldFeeParams, _newFeeParams);
}
```

### CTM Admin can't revert malicious batches due to restricted permission

Submission ID: `cm41yn6lt0005iww16b1dnfo3`  
Severity: Low

## Summary

The [chain type manager documentation](https://github.com/matter-labs/era-contracts/blob/gateway-release-candidate/docs/chain_management/chain_type_manager.md#emergency-upgrade) states that the `ChainTypeManager` (CTM) admin has emergency powers to revert batches without waiting for governance approval. However, in the actual implementation on `Executor.sol`, `revertBatchesSharedBridge` only checks for validator permissions(using the `onlyValidator` modifier), preventing the CTM admin from performing emergency batch reversions.

<https://github.com/matter-labs/era-contracts/blob/9d0ffa4e846519e010329c58fb86e6f99d5e84ca/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L564>

&#x20;

```Solidity
// @audit only the validator can revert batches.
@> function revertBatchesSharedBridge(uint256, uint256 _newLastBatch) external nonReentrant onlyValidator {
    _revertBatches(_newLastBatch);
}

@> modifier onlyValidator() {
    if (!s.validators[msg.sender]) {
        revert Unauthorized(msg.sender);
    }
    _;
}
```

## Vulnerability Details

When the CTM admin attempts to revert batches through `ChainTypeManager.revertBatches()`:

<https://github.com/matter-labs/era-contracts/blob/9d0ffa4e846519e010329c58fb86e6f99d5e84ca/l1-contracts/contracts/state-transition/ChainTypeManager.sol#L282>

```Solidity
function revertBatches(uint256 _chainId, uint256 _newLastBatch) external onlyOwnerOrAdmin {
    IZKChain(getZKChain(_chainId)).revertBatchesSharedBridge(_chainId, _newLastBatch);
}

```

The call fails because as shown above the `revertBatchesSharedBridge` function on `Executor.sol`is protected by the `onlyValidator`modifier. 

Thus, completely breaking the invariant defined in the CTM's documentation: 

*"In case we are aware that some of the committed batches on an ST are dangerous to be executed, **the CTM can call `revertBatches` on that ST. For faster reaction, the admin of the ChainTypeManager has the ability to do so without waiting for governance approval that may take a lot of time.**"*

Also, notice that the devs created the modifier to allow the CTM to also call `revertBatches`but unfortunately, it is not in use. 

```Solidity
modifier onlyValidatorOrChainTypeManager() {
        if (!s.validators[msg.sender] && msg.sender != s.chainTypeManager) {
            revert Unauthorized(msg.sender);
        }
        _;
    }
```

## Impact

* The CTM admin cannot perform emergency reversions if malicious batches are committed. 



## Tools Used

Manual Review

## Recommendations

Replace the `onlyValidator` modifier with `onlyValidatorOrChainTypeManager` on `Executor.sol`: 

```diff
- function revertBatchesSharedBridge(uint256, uint256 _newLastBatch) external nonReentrant onlyValidator {
+ function revertBatchesSharedBridge(uint256, uint256 _newLastBatch) external nonReentrant onlyValidatorOrChainTypeManager {
    _revertBatches(_newLastBatch);
}
```

### L1 Chain doesn't support deposits that revert on 0 approval like BNB

Submission ID: `cm465l6rg00058ucz1qtlt1uq`  
Severity: Low

## Vulnerability Details

Some tokens can revert when `0 approval`is set. The popular BNB is one of them: 

<https://etherscan.io/token/0xB8c77482e45F1F44dE1745F52C74426C631bDD52#code>

```Solidity
           function approve(address _spender, uint256 _value) returns (bool success) {
@>		    if (_value <= 0) throw; 
                    allowance[msg.sender][_spender] = _value;
                    return true;
              }
```

The problem is that `L1ERC20Bridge`calls approve with `0`for all tokens. 

<https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/era-contracts/l1-contracts/contracts/bridge/L1ERC20Bridge.sol#L207>

```Solidity
    function deposit(
        address _l2Receiver,
        address _l1Token,
        uint256 _amount,
        uint256 _l2TxGasLimit,
        uint256 _l2TxGasPerPubdataByte,
        address _refundRecipient
    ) public payable nonReentrant returns (bytes32 l2TxHash) {
        ...
        uint256 amount = _approveFundsToAssetRouter(msg.sender, IERC20(_l1Token), _amount);
        if (amount != _amount) {
            // The token has non-standard transfer logic
            revert TokensWithFeesNotSupported();
        }


        l2TxHash = L1_ASSET_ROUTER.depositLegacyErc20Bridge{value: msg.value}({
            _originalCaller: msg.sender,
            _l2Receiver: _l2Receiver,
            _l1Token: _l1Token,
            _amount: _amount,
            _l2TxGasLimit: _l2TxGasLimit,
            _l2TxGasPerPubdataByte: _l2TxGasPerPubdataByte,
            _refundRecipient: _refundRecipient
        });
        // clearing approval
         //@audit-issue resetting the approval would never work for these tokens
@>        bool success = IERC20(_l1Token).approve(address(L1_ASSET_ROUTER), 0);
        if (!success) {
            revert ApprovalFailed();
        }
        depositAmount[msg.sender][_l1Token][l2TxHash] = _amount;
        ...
    }
```

## Impact

* DoS for tokens that revert on 0 approval. Protocol cannot receive deposits from such tokens. 

## Tools Used

Manual Review

## Recommendations

Call `forceApprove` inside a try-catch block. If the call reverts, check whether the token has `allowance == 0` for the `L1_ASSET_ROUTER`, if so, allow the code to continue, otherwise revert.

### GovernorCountingFractional emitting CastVoteWithReason with ignored support parameter and wrong weight

Submission ID: `cm3a4gunu0003tbw9bj5n4qic`  
Severity: Low

## Summary
When the function `castVoteWithReasonAndParams` is used to split votes, the event `VoteCastWithParams` with the `support` argument is emitted, although this is ignored in this case.

## Vulnerability Details
`GovernorCountingFractional` supports splitting votes between Against/For/Abstain. To do so, `_countVote` checks if `voteData` is non-zero. If so, the split is parsed based on this data and the argument `support` is completely ignored. The function `_castVote` (within `Governor`: https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/zk-governance/l2-contracts/lib/openzeppelin-contracts/contracts/governance/Governor.sol#L581) calls `_countVote` and afterwards emits an event. If `params` has length zero, `VoteCast` is emitted with the `support` and `weight` parameters, which is correct when using `GovernorCountingFractional` (as it also allocates the whole weight to the chosen support value in this case).

However, when the params are non-zero, the event `VoteCastWithParams` is emitted with the same `weight` and `support` parameters. But these parameters are not directly related to the vote in this case. The `weight` is just the total weight (that can be arbitrarily split, even with multiple calls) and `support` is completely ignored. Note that the `support` value could even have invalid values in these events, as it is not verified in `_countVoteFractional`.

## Impact
If an off-chain system (that tracks the voting progress or even makes decision automatically based on it, for instance with a Subgraph) just parses `support` and `weight`, it will lead to completely wrong result and would be easily gameable. For instance, someone with weight 10 could vote to times with vote 1 for "against", but always set the support parameter to "for". The off-chain system would then think that this were 100 votes "for", which is wrong. Setting invalid support parameters could also lead to crashes / errors in off-chain systems, as they might only expect the three possible enum values.

Even if an off-chain system is aware of these intricate details, actually parsing the vote result based on the events is hard: You need to decode the `params` byte array for every `VoteCastWithParams` event to get the correct votes.

## Recommendations
It is recommended to introduce custom events within `GovernorCountingFractional` that emit the actual voting result directly. This will avoid errors in off-chain systems. The `_castVote` function could also be overwritten to prevent that these confusing events are emitted.

### GovernorPreventLateQuorum ineffective in combination with GovernorCountingFractional

Submission ID: `cm3a5fxm20005hwe4t8dsrudl`  
Severity: Low

## Summary

The protection of `GovernorPreventLateQuorum` against whales influencing the result by voting in the last minute.

## Vulnerability Details

According to the docs of `GovernorPreventLateQuorum`, the purpose of the module is:

```Solidity
 * @dev A module that ensures there is a minimum voting period after quorum is reached. This prevents a large voter from
 * swaying a vote and triggering quorum at the last minute, by ensuring there is always time for other voters to react
 * and try to oppose the decision.
```
This works fine with nominal votes, where a large voter would have to cast their whole vote to a particular decision and the other voters would therefore still have time to react. However, the custom `GovernorCountingFractional` module supports partial voting, which makes this protection ineffective. A large voter can vote with a small part of their weight against their intention such that quorum is reached. The vote will then be extended. Just before the extension is over, they can vote with the rest of their weight for their original intention, leaving no time for anyone to react.

## Impact
Let's assume there is a large voter with 30% of the overall weight. The quorum is set to 50% of the overall weight. There is a controversial proposal that has reached 35% NO and 14% YES. The large voter now votes with 1% for NO to trigger the quorum and the vote extension starts. Everyone in support of NO (e.g. the ZKSync foundation) is relieved and does not mobilize more voters, as the quorum was reached and they are in the majority by a large margin. 1 second before the vote extension ends, the large voter casts their remaining 29% for YES, resulting in 43% YES and 36% NO, meaning the vote succeeded (https://github.com/Cyfrin/2024-10-zksync/blob/b0c5565b6078a93cc3358a5d5012258caa701385/zk-governance/l2-contracts/src/lib/GovernorCountingFractional.sol#L104).

Note that such sophisticated governance attacks are very realistic, which is e.g. highlighted by this paper: https://dl.acm.org/doi/10.1145/3605768.3623539

## Recommendations
In combination with `GovernorCountingFractional`, a more sophisticated protection mechanism is needed. One possibility is to not only consider if the quorum was reached, but additionally if the result (i.e. `_voteSucceeded`) changes in the extension period. In such cases, there should be another extension.

### Meet in the middle attack can be used to transfer admin control to user-controlled access

Submission ID: `cm3aehysi0005k8v0ycce1u5c`  
Severity: Low

## Summary

`PermanentRestriction.allowL2Admin` is susceptible to meet in the middle attacks that allow an attacker to transfer admin control to an address that they control.

## Vulnerability Details

`PermanentRestriction._validateMigrationToL2` validates that the migration happens to an expected admin contract, i.e. one that was deployed by the admin factory. To do so, it checks if the address exists in `allowedL2Admins`, which can be populated by any user via `allowL2Admin` by setting the appropriate parameters. The CREATE2 address is then derived based on these parameters:

```Solidity
        address expectedAddress = L2ContractHelper.computeCreate2Address(
            L2_ADMIN_FACTORY,
            deploymentSalt,
            l2BytecodeHash,
            constructorInputHash
        );
```

It is not checked if this contract exists / was actually deployed by the factory. In theory, this is not necessary, as the contract has to be deployed by the factory by the derivation logic and the contracts can always get deployed later on.

However, as an address is only 160-bit long and the user here controls 3 \* 256 bits that influence the derivation (which is more than enough, 80 bits would be sufficient for the attack outlined), a meet-in-the-middle attack can be used to get a collision with an attacker controlled address with high probability in a reasonable time / cost. To do so, the attacker would bruteforce a sufficient number of values (2^80) for one parameter (e.g. `deploymentSalt`) while keeping the other one fixed.  The resulting account addresses would be calculated and efficiently stored, e.g. in a Bloom filter. Then, the attacker would prepare an exploit contract and iterate over the deployment nonces / salts there until a collision is found. Then, the attacker would deploy their exploit contract and whitelist it for the migration by calling `allowL2Admin` with the `deploymentSalt` that results in the same address as their exploit contract. It would now be allowed for the migration and the attacker's exploit contract would be the admin after the migration.

Note that the attack may already feasible economically today if the stakes are high enough (which should be the case here, as millions / billions would be at stake). This will only get worse in the future. In 2021, [Vitalik Buterin wrote](https://ethresear.ch/t/what-would-break-if-we-lose-address-collision-resistance/11356):
> Even without address space extension, collisions today take 2^80 time to compute, and that length of time is already within range of nation-state-level actors willing to spend huge amounts of resources. For reference, the Bitcoin network performs 2^80 SHA256 hashes once every two hours.

In 2023, [Mysten Labs wrote](https://web.archive.org/web/20240815154202/https://mystenlabs.com/blog/ambush-attacks-on-160bit-objectids-addresses):

> The results of these efforts show that the cost of 160-bit hash collision attacks can be accomplished under certain assumptions and access to hardware for as little as just a few million dollars (\$), making it a feasible attack vector even for individuals or less sophisticated actors.

Nowadays, there is even an [EIP](https://eips.ethereum.org/EIPS/eip-3607) because of these concerns.

## Impact
As explained above, an attacker can abuse this to become the admin of the chain after the migration.

## Recommendations
Check that the contract was deployed by the factory, which can be done easily by storing the deployed addresses. Then, the discussed attack no longer works (as the deployment from the factory would fail if the address is already used).

### `L1Nullifier._parseL2WithdrawalMessage` - incorrect length check on `_l2ToL1message`

Submission ID: `cm46yaed8000byugj2gkdih95`  
Severity: Low

## Summary

In the `_parseL2WithdrawalMessage` function of the `L1Nullifier` contract, there is an incorrect length check on the `_l2ToL1message` byte array when the `bytes4(functionSignature)` equals `IAssetRouterBase.finalizeDeposit.selector`. The expected message length should be 68 bytes, but it is incorrectly checked as 36 bytes.

## Vulnerability Details

`_parseL2WithdrawalMessage` function of the [`L1Nullifier`](https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/era-contracts/l1-contracts/contracts/bridge/L1Nullifier.sol) contract is used to parse the withdrawal message and returns withdrawal details.

The function performs an internal length check on `_l2ToL1message` based on the function signature. However, when the `bytes4(functionSignature)` equals `IAssetRouterBase.finalizeDeposit.selector`, the expected length is incorrectly checked as 36 instead of the correct value of 68, as it requires at least two variables:

* originalChainId: Uint256
* assetId: Bytes32

Considering the variables required, the total expected byte length adds up to 4 + 32 + 32 = 68 bytes.

The implementation of the [`_parseL2WithdrawalMessage`](https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/era-contracts/l1-contracts/contracts/bridge/L1Nullifier.sol#L608-L613) function is provided below, highlighting the length check and the process of reading variables:

```solidity
    function _parseL2WithdrawalMessage(
        uint256 _chainId,
        bytes memory _l2ToL1message
    ) internal returns (bytes32 assetId, bytes memory transferData) {
        // Please note that there are three versions of the message:
        // 1. The message that is sent from `L2BaseToken` to withdraw base token.
        // 2. The message that is sent from L2 Legacy Shared Bridge to withdraw ERC20 tokens or base token.
        // 3. The message that is sent from L2 Asset Router to withdraw ERC20 tokens or base token.

        uint256 amount;
        address l1Receiver;

        (uint32 functionSignature, uint256 offset) = UnsafeBytes.readUint32(_l2ToL1message, 0);
        if (bytes4(functionSignature) == IMailbox.finalizeEthWithdrawal.selector) {
            ...
        } else if (bytes4(functionSignature) == IL1ERC20Bridge.finalizeWithdrawal.selector) {
            ...
        } else if (bytes4(functionSignature) == IAssetRouterBase.finalizeDeposit.selector) {
            // The data is expected to be at least 36 bytes long to contain assetId.
>>          if (_l2ToL1message.length < 36) {
                revert WrongMsgLength(36, _l2ToL1message.length);
            }
            // slither-disable-next-line unused-return
>>          (, offset) = UnsafeBytes.readUint256(_l2ToL1message, offset); // originChainId, not used for L2->L1 txs
>>          (assetId, offset) = UnsafeBytes.readBytes32(_l2ToL1message, offset);
            transferData = UnsafeBytes.readRemainingBytes(_l2ToL1message, offset);
        } else {
            revert InvalidSelector(bytes4(functionSignature));
        }
    }
```

As mentioned in [UnsafeBytes.sol](https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/era-contracts/l1-contracts/contracts/common/libraries/UnsafeBytes.sol#L11), the byte length should be correctly validated before utilizing any functions from UnsafeBytes:

```Solidity
* @dev WARNING!
* 1) Functions don't check the length of the bytes array, so it can go out of bounds.
* The user of the library must check for bytes length before using any functions from the library!
```

## Impact

Without a proper length check, the function risks reverting with an `OutOfBounds` error instead of the intended `WrongMsgLength` error, revealing a flaw in error reporting logic and creating debugging challenges.
Furthermore, if the length exceeds 36, attempting to access bytes beyond this point could result in unpredictable runtime behavior, introducing unexpected and potentially harmful system outcomes.

## Tools Used

Manual Review

## Recommendations

Validate `_l2ToL1message.length` against 68 instead of 36.

```diff
        ...
        } else if (bytes4(functionSignature) == IAssetRouterBase.finalizeDeposit.selector) {
            // The data is expected to be at least 36 bytes long to contain assetId.
-           if (_l2ToL1message.length < 36) {
+           if (_l2ToL1message.length < 68) {
                revert WrongMsgLength(36, _l2ToL1message.length);
            }
            // slither-disable-next-line unused-return
            ...
```

### `isPermanentRollup` setter pre-conditions are not validated in `AdminFacet.forwardedBridgeMint`

Submission ID: `cm3yn9r67000510q4hom3unex`  
Severity: Low

## Summary

The `isPermanentRollup` pre-conditions are validated in `AdminFacet.makePermanentRollup` but not in `AdminFacet.forwardedBridgeMint`.

## Vulnerability Details

The function `AdminFacet.makePermanentRollup` includes checks to ensure that the `isPermanentRollup` pre-conditions are met before proceeding. However, these checks are missing in the `AdminFacet.forwardedBridgeMint` function, which can lead to inconsistent state when `AdminFacet.forwardedBridgeMint` is executed with invalid input.

## Impact

Without validating the `isPermanentRollup` pre-conditions in `AdminFacet.forwardedBridgeMint`, the contract may enter an invalid state or exhibit unexpected behavior if executed with invalid input.

## Tools Used

Code review.

## Recommendations

Add the necessary `s.isPermanentRollup` pre-condition checks in the `AdminFacet.forwardedBridgeMint` function to ensure consistency and prevent potential issues.

### Bypass of the fallback role to call any function signature in AccessControlRestriction

Submission ID: `cm4015xm60005wvgx9a05e46y`  
Severity: Low

## Summary

The role to call the fallback functions in the `AccessControlRestriction` contract can be bypassed to also call other functions if:

1. The target contract was compiled with solc `<=0.4.17`
2. The function signature ends a `00` byte\
   without having set any role for any other function.

## Vulnerability Details

Evaluate the following piece of code coming from the `AccessControlRestriction` contract:

```solidity
    /// @inheritdoc Restriction
    function validateCall(Call calldata _call, address _invoker) external view override {
        // Note, that since `DEFAULT_ADMIN_ROLE` is 0 and the default storage value for the
        // `requiredRoles` and `requiredRolesForFallback` is 0, the default admin is by default a required
        // role for all the functions.
        if (_call.data.length < 4) {
            if (!hasRole(requiredRolesForFallback[_call.target], _invoker)) {
                revert AccessToFallbackDenied(_call.target, _invoker);
            }
        } else {
            bytes4 selector = bytes4(_call.data[:4]);
            if (!hasRole(requiredRoles[_call.target][selector], _invoker)) {
                revert AccessToFunctionDenied(_call.target, selector, _invoker);
            }
        }
    }
```

<https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/era-contracts/l1-contracts/contracts/governance/AccessControlRestriction.sol#L62-L77>

Having the calldata set to less than 4 bytes doesn't necessarily means that the fallback function will be called. The function signature in the target contract could be `0x10000000` and be called with the calldata `0x10`.\
This is due to a bug in versions of Solidity versions older than 0.4.18, learn more in the [release announcement of the version 0.4.18](https://soliditylang.org/blog/2017/10/18/solidity-0.4.18-release-announcement/).

```
Code Generator: Do not accept data with less than four bytes (truncated function signature) for regular function calls - fallback function is invoked instead.
```

Because of this, it is possible to call a function whose signature ends with `00` because of this missing 4 bytes check.

### POC

See the following target contract,

```diff
diff --git a/era-contracts/l1-contracts/contracts/PermissionedToken.sol b/era-contracts/l1-contracts/contracts/PermissionedToken.sol
new file mode 100644
index 0000000..aa9d72d
--- /dev/null
+++ b/era-contracts/l1-contracts/contracts/PermissionedToken.sol
@@ -0,0 +1,16 @@
+pragma solidity 0.4.17;
+
+contract PermissionedToken {
+    // 0x58739800
+    bool public wCalled;
+    function withdrawAllFor(address) public { wCalled = true; }
+    // 0x873e9600
+    bool public gCalled;
+    function getOracleState(address,uint32) public { gCalled = true; }
+    // 0xbc000000
+    bool public pCalled;
+    function pwn_8928181() public { pCalled = true; }
+
+    bool public fCalled;
+    function () payable { fCalled = true; }
+}
```

As well as the following test that showcases the vulnerability in the `AccessControlRestriction.t.sol` test file.

```diff
diff --git a/era-contracts/l1-contracts/test/foundry/l1/unit/concrete/Governance/AccessControlRestriction.t.sol b/era-contracts/l1-contracts/test/foundry/l1/unit/concrete/Governance/AccessControlRestriction.t.sol
index 5169979..bddf759 100644
--- a/era-contracts/l1-contracts/test/foundry/l1/unit/concrete/Governance/AccessControlRestriction.t.sol
+++ b/era-contracts/l1-contracts/test/foundry/l1/unit/concrete/Governance/AccessControlRestriction.t.sol
@@ -201,4 +201,62 @@ contract AccessRestrictionTest is Test {
         Call memory call = Call({target: address(chainAdmin), value: 0, data: ""});
         restriction.validateCall(call, randomCaller);
     }
+
+    function test_FallbackRoleValidateTruncated() public {
+        bytes memory code = abi.encodePacked(vm.getCode("contracts/PermissionedToken.sol"));
+        address token;
+        assembly {
+            token := create(0, add(code, 0x20), mload(code))
+        }
+        assert(token != address(0));
+
+        vm.startPrank(owner);
+        restriction.setRequiredRoleForFallback(token, DEFAULT_ADMIN_ROLE);
+
+        Call memory call;
+        Call[] memory calls = new Call[]();
+        bytes4 sig;
+
+        // 1. prove that we can call withdrawAllFor
+        assertFalse(IToken(token).wCalled());
+        sig = bytes4(keccak256("withdrawAllFor(address)"));
+        call = Call({target: token, value: 0, data: abi.encode(bytes3(sig))}); // truncate sig to 3 bytes
+        restriction.validateCall(call, owner);
+        calls[0] = call;
+        chainAdmin.multicall(calls, true);
+        assertTrue(IToken(token).wCalled());
+
+        // 2. prove that we can call getOracleState
+        assertFalse(IToken(token).gCalled());
+        sig = bytes4(keccak256("getOracleState(address,uint32)"));
+        call = Call({target: token, value: 0, data: abi.encode(bytes3(sig))}); // truncate sig to 3 bytes
+        restriction.validateCall(call, owner);
+        calls[0] = call;
+        chainAdmin.multicall(calls, true);
+        assertTrue(IToken(token).gCalled());
+
+        // 3. prove that we can call pwn_8928181
+        assertFalse(IToken(token).pCalled());
+        sig = bytes4(keccak256("pwn_8928181()"));
+        call = Call({target: token, value: 0, data: abi.encode(bytes3(sig))}); // truncate sig to 3 bytes
+        restriction.validateCall(call, owner);
+        calls[0] = call;
+        chainAdmin.multicall(calls, true);
+        assertTrue(IToken(token).pCalled());
+
+        // 4. prove that we can call fallback
+        assertFalse(IToken(token).fCalled());
+        call = Call({target: token, value: 0, data: ""}); // call fallback
+        restriction.validateCall(call, owner);
+        calls[0] = call;
+        chainAdmin.multicall(calls, true);
+        assertTrue(IToken(token).fCalled());
+    }
+}
+
+interface IToken {
+    function wCalled() external view returns (bool);
+    function gCalled() external view returns (bool);
+    function pCalled() external view returns (bool);
+    function fCalled() external view returns (bool);
 }
```

## Impact

This vulnerability makes it possible to bypass the fallback role in the `AccessControlRestriction` contract and still be able to call functions without the `requiredRole` and could lead to catastrophic access control vulnerabilities in target contracts.

## Tools Used

<https://github.com/iFrostizz/sig_cracker>\
vim

## Recommendations

If assuming that fallback functions are triggered when the calldata is empty, require the caller to either supply a calldata lenth of 0 (fallback) or >= 4 (selector). There should be a case testing that calls with a data length included in `]0; 4[` are rejected as they are very exotic anyway.

```diff
diff --git a/era-contracts/l1-contracts/contracts/governance/AccessControlRestriction.sol b/era-contracts/l1-contracts/contracts/governance/AccessControlRestriction.sol
index 6052d1e..8b14e56 100644
--- a/era-contracts/l1-contracts/contracts/governance/AccessControlRestriction.sol
+++ b/era-contracts/l1-contracts/contracts/governance/AccessControlRestriction.sol
@@ -64,15 +64,18 @@ contract AccessControlRestriction is Restriction, IAccessControlRestriction, Acc
         // Note, that since `DEFAULT_ADMIN_ROLE` is 0 and the default storage value for the
         // `requiredRoles` and `requiredRolesForFallback` is 0, the default admin is by default a required
         // role for all the functions.
-        if (_call.data.length < 4) {
+        if (_call.data.length == 0) {
             if (!hasRole(requiredRolesForFallback[_call.target], _invoker)) {
                 revert AccessToFallbackDenied(_call.target, _invoker);
             }
-        } else {
+        } else if (_call.data.length == 4) {
             bytes4 selector = bytes4(_call.data[:4]);
             if (!hasRole(requiredRoles[_call.target][selector], _invoker)) {
                 revert AccessToFunctionDenied(_call.target, selector, _invoker);
             }
+        } else {
+            bytes4 selector = bytes4(_call.data);
+            revert AccessToFunctionDenied(_call.target, selector, _invoker);
         }
     }
 }
```

### State modification during storage reading in `forceSload` function

Submission ID: `cm443fkaz00051atsboh067bd`  
Severity: Low

## Summary

The `forceSload` function alters the `AccountInfo` settings of the target contract, even though its intended purpose is only to read storage from contracts that lack getters, without modifying any state.

## Vulnerability Details

The `SloadContract` contract is used by system contracts to read storage from other contracts that do not provide getters. The process involves first force-deploying the `SloadContract` to the target address, reading the required storage, and then force-deploying the original contract back to the target address.

```solidity
    function forcedSload(address _addr, bytes32 _key) internal returns (bytes32 result) {
        // rest of the code

        forceDeployNoConstructor(_addr, sloadContractBytecodeHash);
        result = SloadContract(_addr).sload(_key);
        forceDeployNoConstructor(_addr, previoushHash);
    }
```

<https://github.com/Cyfrin/2024-10-zksync/blob/main/era-contracts/system-contracts/contracts/libraries/SystemContractHelper.sol#L463-L465>\
<https://github.com/Cyfrin/2024-10-zksync/blob/main/era-contracts/system-contracts/contracts/libraries/SystemContractHelper.sol#L411>\
<https://github.com/Cyfrin/2024-10-zksync/blob/main/era-contracts/system-contracts/contracts/SloadContract.sol#L10>

The goal of this function is to read storage that is not accessible via getters. However, because it involves force deployment, the `AccountInfo` settings (such as `AccountAbstractionVersion` and `AccountNonceOrdering`) are overwritten with default values of `AccountAbstractionVersion.None` and `AccountNonceOrdering.Sequential`.\
<https://github.com/Cyfrin/2024-10-zksync/blob/main/era-contracts/system-contracts/contracts/ContractDeployer.sol#L229>\
<https://github.com/Cyfrin/2024-10-zksync/blob/main/era-contracts/system-contracts/contracts/ContractDeployer.sol#L210-L214>

This behavior means that if a contract originally has `AccountNonceOrdering` set to `Arbitrary`, using `SloadContract` by system contracts to read its storage will unexpectedly change its `AccountNonceOrdering` to `Sequential`. Note that the `AccountNonceOrdering` can only be changed from `Sequential` to `Arbitrary`, not the other way around. This could lead to unintended consequences.\
<https://github.com/Cyfrin/2024-10-zksync/blob/main/era-contracts/system-contracts/contracts/ContractDeployer.sol#L75>

## Impact

Using `SloadContract` by system contracts to read storage from a contract should not alter any state. However, this process unexpectedly changes the `AccountInfo` settings, which could significantly impact the target contract's functionality.

## Tools Used

## Recommendations

To avoid changing the `AccountInfo` settings when using `forcedSload`, the `forceDeployOnAddresses` function should be modified to preserve the original `AccountInfo` configuration of the target contract.

### Calling `requestL2TransactionTwoBridges` with nonzero `_request.l2Value` can cause reverts on the destination chain

Submission ID: `cm443o2ak000b1ats758pnlkd`  
Severity: Low

## Summary  
The `finalizeDeposit` function is not payable, which means calling `requestL2TransactionTwoBridges` with a nonzero `_request.l2Value` will cause a revert on the destination chain.

## Vulnerability Details

The `finalizeDeposit` functions in both the `L2AssetRouter` and `L2SharedBridgeLegacy` contracts are not payable:
- [L2AssetRouter.finalizeDeposit](https://github.com/Cyfrin/2024-10-zksync/blob/main/era-contracts/l1-contracts/contracts/bridge/asset-router/L2AssetRouter.sol#L119)
- [L2SharedBridgeLegacy.finalizeDeposit](https://github.com/Cyfrin/2024-10-zksync/blob/main/era-contracts/l1-contracts/contracts/bridge/L2SharedBridgeLegacy.sol#L116)

This means that when using the function `requestL2TransactionTwoBridges` to bridge a non-base token to a zk chain, and if the `_request.l2Value` is nonzero, it implies that some base token (as `msg.value`) will be forwarded to the `L2AssetRouter::finalizeDeposit` or `L2SharedBridgeLegacy::finalizeDeposit` function. However, since neither of these functions are payable, this will result in a revert.

The flow leading to this issue starts from:
- The `requestL2TransactionTwoBridges` function, which bridges the token with a nonzero `_request.l2Value`:
  [Link to source](https://github.com/Cyfrin/2024-10-zksync/blob/main/era-contracts/l1-contracts/contracts/bridgehub/Bridgehub.sol#L542)

Additionally, the `getDepositCalldata` function determines which deposit function will be called based on whether the token is registered with NTV (Native Token Vault) or not:
- [Link to source](https://github.com/Cyfrin/2024-10-zksync/blob/main/era-contracts/l1-contracts/contracts/bridge/asset-router/L1AssetRouter.sol#L437)

If the token is not registered with NTV, the destination will call `L2AssetRouter::finalizeDeposit`. Otherwise, it will call `L2SharedBridgeLegacy::finalizeDeposit`.

Both of these functions, however, are non-payable, meaning they cannot accept the base token value as part of the transaction, leading to a revert if `_request.l2Value` is nonzero.

## Impact  
If `_request.l2Value` is nonzero when calling `requestL2TransactionTwoBridges`, the transaction will fail and revert on the destination chain.

## Tools Used

## Recommendations  
To avoid this issue, either:
- Enforce that `_request.l2Value` must be zero when calling `requestL2TransactionTwoBridges`, or
- Make the `finalizeDeposit` functions payable (though this might not be the most appropriate solution).

### Signers cannot manually invalidate already issued signatures in various contracts

Submission ID: `cm45bl5ij00039hhl1w5az5ra`  
Severity: Low

## Summary

Once a signature is issued, the signer has no means to manually invalidate it, other than executing a transaction associated with a signature (which will increment the nonce through the `_useNonce` function). This can lead to issues in cases where the signature holder is compromised, the signer has made a mistake, or they simply wish to invalidate an existing signature, as there are no means available for the signer to revoke the signature.

## Vulnerability Details

The [`permit` signatures](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/2d081f24cac1a867f6f73d512f2022e1fa987854/contracts/token/ERC20/extensions/ERC20PermitUpgradeable.sol#L56) in ZkTokenV1.sol and ZkTokenV2.sol offers the signer the option to create a EIP-712 signature which can be used for [vote delegation](https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/zk-governance/l2-contracts/src/ZkTokenV1.sol#L114). This handles the signature nonce through the [`_useNonce`](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/2d081f24cac1a867f6f73d512f2022e1fa987854/contracts/token/ERC20/extensions/ERC20PermitUpgradeable.sol#L97C1-L101C6) function

```solidity
  function initialize(address _admin, address _mintReceiver, uint256 _mintAmount) external initializer {
    __ERC20_init("ZKsync", "ZK");
>   __ERC20Permit_init("ZKsync");
```

The same can be observed in L2WrappedBaseToken which offers a permit functionality, which also relies on openzeppelin's ERC20PermitUpgradeable.sol and subsequently, the [`_useNonce`](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/2d081f24cac1a867f6f73d512f2022e1fa987854/contracts/token/ERC20/extensions/ERC20PermitUpgradeable.sol#L97C1-L101C6)

```solidity
    function initializeV3(
        string calldata name_,
        string calldata symbol_,
        address _l2Bridge,
        address _l1Address,
        bytes32 _baseTokenAssetId
    ) external reinitializer(3) {
        if (_l2Bridge == address(0)) {
            revert ZeroAddress();
        }

        if (_l1Address == address(0)) {
            revert ZeroAddress();
        }
        if (_baseTokenAssetId == bytes32(0)) {
            revert ZeroAddress();
        }
        l2Bridge = _l2Bridge;
        l1Address = _l1Address;
        nativeTokenVault = L2_NATIVE_TOKEN_VAULT_ADDR;
        baseTokenAssetId = _baseTokenAssetId;

        // Set decoded values for name and symbol.
        __ERC20_init_unchained(name_, symbol_);

        // Set the name for EIP-712 signature.
>       __ERC20Permit_init(name_);

        emit Initialize(name_, symbol_, 18);
    }
```

The contracts however offer no method that allows the owner to invalidate its nonce since the `_useNonce` function is internal and cannot be directly accessed.

Similar [finding](https://solodit.xyz/issues/a-signer-cant-cancel-his-signature-before-a-deadline-cyfrin-none-cyfrin-farcaster-markdown) from Cyfrin team.

## Impact

As a result, signatures cannot be cancelled before their expiry, even if its needed to be.

## Tools Used

Manual Review.

## Recommendations

Introduce an external function like `IncreaseNonce` that will query `_useNonce` on behalf of `msg.sender`. A similar mechanism can be found in ZkMerkleDistributor.sol - <https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/zk-governance/l2-contracts/src/ZkMerkleDistributor.sol#L277>

### Messages sent from L2 to L1 does not constrain the receiver chain which can lead to replaying in L1 and GW

Submission ID: `cm46xcmj1000fvzwmcssidh4s`  
Severity: Low

## Summary

Sending messages from an L2 when it is settled to the GW can be proven in the GW and L1 which can lead to message double spending

## Vulnerability Details

When a user on L2 sends a message or a base token withdrawal, the `sendToL1` function is executed on the `L1Messenger`:

```Solidity
    function sendToL1(bytes calldata _message) external override returns (bytes32 hash) {
        uint256 gasBeforeMessageHashing = gasleft();
        hash = EfficientCall.keccak(_message);
        uint256 gasSpentOnMessageHashing = gasBeforeMessageHashing - gasleft();

        /// Store message record
        chainedMessagesHash = keccak256(abi.encode(chainedMessagesHash, hash));

        /// Store log record
        L2ToL1Log memory l2ToL1Log = L2ToL1Log({
            l2ShardId: 0,
            isService: true,
            txNumberInBlock: SYSTEM_CONTEXT_CONTRACT.txNumberInBlock(),
            sender: address(this),
            key: bytes32(uint256(uint160(msg.sender))),
            value: hash
        });
        _processL2ToL1Log(l2ToL1Log);

        ...

        emit L1MessageSent(msg.sender, hash, _message);
    }
```

In this function it chains the total messages during the batch and then it will be sent by the bootloader at the end so it can be proved in other chains.
The problem is that it does not constrain which chain should consume this message. In this case, if the L2 is settled in the GW, a user could prove the inclusion of his message in both GW and L1 chains. This can be really problematic because for base token withdrawals, the user will be able ot receive tokens in both chains.

## Impact

High, users can prove the inclusion of the same message in both chains that can lead to double spending withdrawals

## Tools Used

Manual review

## Recommendations

It does not have a trivial solution, but messages should include a chainId representing which chain should be able to consume the message.

### Zksync's quorum logic in `GovernorCountingFractional` is broken since it wrongly specifies the COUNTING MODE

Submission ID: `cm46hwq4m000df5a54o8dc08v`  
Severity: Low

## Summary

The `GovernorCountingFractional.sol's` quorum logic is broken cause it attempts to only count `for` votes for quorum but wrongly specifies it in the COUNTING MODE

## Vulnerability Details

First note that the L2 contracts attempt to extend the `Governor.sol` in order to now support 3 options faction for vote counting.

This approach is also heavily inspired from Scopelift's scope, see

https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/zk-governance/l2-contracts/src/lib/GovernorCountingFractional.sol#L21-L25

```solidity
 * @dev This code was copied from
 * https://github.com/ScopeLift/flexible-voting/blob/d71c4e02256d4ef6c9067b947d398753402afdd2/src/GovernorCountingFractional.sol.
 * @custom:security-contact security@zksync.io
 */
abstract contract GovernorCountingFractional is Governor {
    ..snip
}
```

Now going to the implementation of `GovernorCountingFractional` we can see that whereas Zksync claim this code has been copied there are some differences which we can see, for e.g in the implemented approach, only `for` votes are counted to quorum, i.e:

https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/zk-governance/l2-contracts/src/lib/GovernorCountingFractional.sol#L89-L98

```solidity
  /**
   * @dev See {Governor-_quorumReached}.
   */
  function _quorumReached(uint256 proposalId) internal view virtual override returns (bool) {
    ProposalVote storage proposalVote = _proposalVotes[proposalId];

    return quorum(proposalSnapshot(proposalId)) <= proposalVote.forVotes;//@audit the amount of for votes needs to strictly have passed quorum
  }

```

This is unlike Scopelift's scope where both `for` and abstain votes are counted towards quorum:

https://github.com/ScopeLift/flexible-voting/blob/d71c4e02256d4ef6c9067b947d398753402afdd2/src/GovernorCountingFractional.sol#L90C1-L98C1

```solidity
    /**
     * @dev See {Governor-_quorumReached}.
     */
    function _quorumReached(uint256 proposalId) internal view virtual override returns (bool) {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];

        return quorum(proposalSnapshot(proposalId)) <= proposalVote.forVotes + proposalVote.abstainVotes;
    }

```

The above reason is why in scope lift's case the `COUNTING_MODE` was specified as such:

https://github.com/ScopeLift/flexible-voting/blob/d71c4e02256d4ef6c9067b947d398753402afdd2/src/GovernorCountingFractional.sol#L49C1-L55C6

```solidity
    /**
     * @dev See {IGovernor-COUNTING_MODE}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function COUNTING_MODE() public pure virtual override returns (string memory) {
        return "support=bravo&quorum=for,abstain&params=fractional";
    }
```

Notice the "support=bravo&quorum=for,abstain&params=fractional"

i.e:

- `support=bravo`
- `quorum=for,abstain`, and
- `params=fractional`

This is correctly implemented, cause when we go to the [official Openzeppelin documentation](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-COUNTING_MODE--) where this all has been inherited from we see the documentation below:

https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-COUNTING_MODE--

> ### COUNTING_MODE() → string - public
>
> A description of the possible support values for castVote and the way these votes are counted, meant to be consumed by UIs to show correct vote options and interpret the results. The string is a URL-encoded sequence of key-value pairs that each describe one aspect, for example support=bravo&quorum=for,abstain.

> There are 2 standard keys: support and quorum.

> support=bravo refers to the vote options 0 = Against, 1 = For, 2 = Abstain, as in GovernorBravo.

> quorum=bravo means that only For votes are counted towards quorum.

> quorum=for,abstain means that both For and Abstain votes are counted towards quorum.

> If a counting module makes use of encoded params, it should include this under a params key with a unique name that describes the behavior. For example:

> params=fractional might refer to a scheme where votes are divided fractionally between for/against/abstain.

> params=erc721 might refer to a scheme where specific NFTs are delegated to vote.

Evidently, we can see that whereas Scopelift correctly implements the options, i.e `support=bravo ` cause they want the three options (for, against and abstain) and also ` quorum=for,abstain` cause they count both for and abstain votes to quorum, see previously [tagged Scopelift's snippet](https://github.com/ScopeLift/flexible-voting/blob/d71c4e02256d4ef6c9067b947d398753402afdd2/src/GovernorCountingFractional.sol#L90C1-L98C1).

**However in the case for Zksync we should have the quorum option to be `bravo` cause only the `for` votes are counted against quorum but this si wrongly implemented cause we have `quorum=for` instead breaking the logic**

See it in code snippets:

https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/zk-governance/l2-contracts/src/lib/GovernorCountingFractional.sol#L56-L59

```solidity
  function COUNTING_MODE() public pure virtual override returns (string memory) {
    return "support=bravo&quorum=for&params=fractional";//@audit
  }

```

## Impact

The counting mode against the quorum is wrong leading to wrong accounting of votes as the mode does not align with what's been used tor each quorum and breaks all external integration since the correct vote options can't be shown neither would the results be correctly shown.

## Tools Used

Manual review

## Recommendations

Apply these changes:

```diff
  function COUNTING_MODE() public pure virtual override returns (string memory) {
-    return "support=bravo&quorum=for&params=fractional";
+    return "support=bravo&quorum=bravo&params=fractional";
  }

```

### During an L1Transaction preparation in `Bootloader.yul` all the gas that's used in `l1TxPreparation` is not accounted for and some of it is not paid at the end of the execution

Submission ID: `cm46wq32u000510qqfl5wllmd`  
Severity: Low

## Vulnerabity Details

The function `Bootloader.yul::l1TxPreparation` returns a value `gasUsedOnPreparation` which is used to calculate the gas used during the entire transaction that is later paid by the sender of the transaction at the end of the execution.

The `gasUsedOnPreparation` value is got from subtracting of the `gasBeforePreparation` and the final remaining gas after all the preparation opereations are done. But the issue is that this gas value `gasBeforePreparation` is captured after some operation which also consumes gas is excuted making the gas used in this operation not to be accounted for in the `gasUsedOnPreparation` value hence won't be paid for.

```Solidity
                setPubdataInfo(gasPerPubdata, basePubdataSpent)
                //@audit gas when sending pubdata not captured
                let gasBeforePreparation := gas()
                debugLog("gasBeforePreparation", gasBeforePreparation)
```

* <https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/era-contracts/system-contracts/bootloader/bootloader.yul#L1099-L1103>

As you can see before capturing `gasBeforePreparation`, the function first calls `setPubdataInfo` fuction which makes an external call to the system context contract of setting pubDataInfo. This consumes some gas though it may be small but this gas is not accounted for.

```Solidity
 let success := call( gas(),SYSTEM_CONTEXT_ADDR(), 0, 0, 68, 0, 0)
```

* <https://github.com/Cyfrin/2024-10-zksync/blob/cfc1251de29379a9548eeff1eea3c78267288356/era-contracts/system-contracts/bootloader/bootloader.yul#L2838>

All other functions that call `setPubdataInfo` like `l2TxValidation` account for all the gas used except for `l1TxPreparation`.

This gas maybe small but as more l1 transactions get executed, it will accumulate to a big value lost in operater fees.

## Imapct

Less gas than one that should be paid is paid at the end of the transaction execution.

## Recommendation

Consider capturing `gasBeforePreparation` before calling `setPubdataInfo`:

```diff
--              setPubdataInfo(gasPerPubdata, basePubdataSpent)
                let gasBeforePreparation := gas()
                debugLog("gasBeforePreparation", gasBeforePreparation)
++              setPubdataInfo(gasPerPubdata, basePubdataSpent)
```
