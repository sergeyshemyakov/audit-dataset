// SPDX-License-Identifier: Unknown
pragma solidity 0.8.15;

/**
 * @title Singleton - Base for singleton contracts (should always be the first super contract)
 *        This contract is tightly coupled to our proxy contract (see `proxies/SafeProxy.sol`)
 * @author Richard Meissner - @rmeissner
 */
abstract contract Singleton {
    // singleton always has to be the first declared variable to ensure the same location as in the Proxy contract.
    // It should also always be ensured the address is stored alone (uses a full word)
    address private singleton;
}

/**
 * @title NativeCurrencyPaymentFallback - A contract that has a fallback to accept native currency payments.
 * @author Richard Meissner - @rmeissner
 */
abstract contract NativeCurrencyPaymentFallback {
    event SafeReceived(address indexed sender, uint256 value);

    /**
     * @notice Receive function accepts native currency transactions.
     * @dev Emits an event with sender and received value.
     */
    receive() external payable {
        emit SafeReceived(msg.sender, msg.value);
    }
}

/**
 * @title SelfAuthorized - Authorizes current contract to perform actions to itself.
 * @author Richard Meissner - @rmeissner
 */
abstract contract SelfAuthorized {
    function requireSelfCall() private view {
        require(msg.sender == address(this), "GS031");
    }

    modifier authorized() {
        // Modifiers are copied around during compilation. This is a function call as it minimized the bytecode size
        requireSelfCall();
        _;
    }
}

// NOTE(l2beat): This is an interface, generated from the contract source code.
interface Enum {
    enum Operation {
        Call,
        DelegateCall
    }
}

/**
 * @title Executor - A contract that can execute transactions
 * @author Richard Meissner - @rmeissner
 */
abstract contract Executor {
    /**
     * @notice Executes either a delegatecall or a call with provided parameters.
     * @dev This method doesn't perform any sanity check of the transaction, such as:
     *      - if the contract at `to` address has code or not
     *      It is the responsibility of the caller to perform such checks.
     * @param to Destination address.
     * @param value Ether value.
     * @param data Data payload.
     * @param operation Operation type.
     * @return success boolean flag indicating if the call succeeded.
     */
    function execute(address to, uint256 value, bytes memory data, Enum.Operation operation, uint256 txGas)
        internal
        returns (bool success)
    {
        if (operation == Enum.Operation.DelegateCall) {
            // solhint-disable-next-line no-inline-assembly
            assembly {
                success := delegatecall(txGas, to, add(data, 0x20), mload(data), 0, 0)
            }
        } else {
            // solhint-disable-next-line no-inline-assembly
            assembly {
                success := call(txGas, to, value, add(data, 0x20), mload(data), 0, 0)
            }
        }
    }
}

/**
 * @title Module Manager - A contract managing Safe modules
 * @notice Modules are extensions with unlimited access to a Safe that can be added to a Safe by its owners.
 *            ⚠️ WARNING: Modules are a security risk since they can execute arbitrary transactions, 
 *            so only trusted and audited modules should be added to a Safe. A malicious module can
 *            completely takeover a Safe.
 * @author Stefan George - @Georgi87
 * @author Richard Meissner - @rmeissner
 */
abstract contract ModuleManager is SelfAuthorized, Executor {
    event EnabledModule(address indexed module);
    event DisabledModule(address indexed module);
    event ExecutionFromModuleSuccess(address indexed module);
    event ExecutionFromModuleFailure(address indexed module);

    address internal constant SENTINEL_MODULES = address(0x1);

    mapping(address => address) internal modules;

    /**
     * @notice Setup function sets the initial storage of the contract.
     *         Optionally executes a delegate call to another contract to setup the modules.
     * @param to Optional destination address of call to execute.
     * @param data Optional data of call to execute.
     */
    function setupModules(address to, bytes memory data) internal {
        require(modules[SENTINEL_MODULES] == address(0), "GS100");
        modules[SENTINEL_MODULES] = SENTINEL_MODULES;
        if (to != address(0)) {
            require(isContract(to), "GS002");
            // Setup has to complete successfully or transaction fails.
            require(execute(to, 0, data, Enum.Operation.DelegateCall, type(uint256).max), "GS000");
        }
    }

    /**
     * @notice Enables the module `module` for the Safe.
     * @dev This can only be done via a Safe transaction.
     * @param module Module to be whitelisted.
     */
    function enableModule(address module) public authorized {
        // Module address cannot be null or sentinel.
        require(module != address(0) && module != SENTINEL_MODULES, "GS101");
        // Module cannot be added twice.
        require(modules[module] == address(0), "GS102");
        modules[module] = modules[SENTINEL_MODULES];
        modules[SENTINEL_MODULES] = module;
        emit EnabledModule(module);
    }

    /**
     * @notice Disables the module `module` for the Safe.
     * @dev This can only be done via a Safe transaction.
     * @param prevModule Previous module in the modules linked list.
     * @param module Module to be removed.
     */
    function disableModule(address prevModule, address module) public authorized {
        // Validate module address and check that it corresponds to module index.
        require(module != address(0) && module != SENTINEL_MODULES, "GS101");
        require(modules[prevModule] == module, "GS103");
        modules[prevModule] = modules[module];
        modules[module] = address(0);
        emit DisabledModule(module);
    }

    /**
     * @notice Execute `operation` (0: Call, 1: DelegateCall) to `to` with `value` (Native Token)
     * @dev Function is virtual to allow overriding for L2 singleton to emit an event for indexing.
     * @param to Destination address of module transaction.
     * @param value Ether value of module transaction.
     * @param data Data payload of module transaction.
     * @param operation Operation type of module transaction.
     * @return success Boolean flag indicating if the call succeeded.
     */
    function execTransactionFromModule(address to, uint256 value, bytes memory data, Enum.Operation operation)
        public
        virtual
        returns (bool success)
    {
        // Only whitelisted modules are allowed.
        require(msg.sender != SENTINEL_MODULES && modules[msg.sender] != address(0), "GS104");
        // Execute transaction without further confirmations.
        success = execute(to, value, data, operation, type(uint256).max);
        if (success) {
            emit ExecutionFromModuleSuccess(msg.sender);
        } else {
            emit ExecutionFromModuleFailure(msg.sender);
        }
    }

    /**
     * @notice Execute `operation` (0: Call, 1: DelegateCall) to `to` with `value` (Native Token) and return data
     * @param to Destination address of module transaction.
     * @param value Ether value of module transaction.
     * @param data Data payload of module transaction.
     * @param operation Operation type of module transaction.
     * @return success Boolean flag indicating if the call succeeded.
     * @return returnData Data returned by the call.
     */
    function execTransactionFromModuleReturnData(address to, uint256 value, bytes memory data, Enum.Operation operation)
        public
        returns (bool success, bytes memory returnData)
    {
        success = execTransactionFromModule(to, value, data, operation);
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // Load free memory location
            let ptr := mload(0x40)
            // We allocate memory for the return data by setting the free memory location to
            // current free memory location + data size + 32 bytes for data size value
            mstore(0x40, add(ptr, add(returndatasize(), 0x20)))
            // Store the size
            mstore(ptr, returndatasize())
            // Store the data
            returndatacopy(add(ptr, 0x20), 0, returndatasize())
            // Point the return data to the correct memory location
            returnData := ptr
        }
    }

    /**
     * @notice Returns if an module is enabled
     * @return True if the module is enabled
     */
    function isModuleEnabled(address module) public view returns (bool) {
        return SENTINEL_MODULES != module && modules[module] != address(0);
    }

    /**
     * @notice Returns an array of modules.
     *         If all entries fit into a single page, the next pointer will be 0x1.
     *         If another page is present, next will be the last element of the returned array.
     * @param start Start of the page. Has to be a module or start pointer (0x1 address)
     * @param pageSize Maximum number of modules that should be returned. Has to be > 0
     * @return array Array of modules.
     * @return next Start of the next page.
     */
    function getModulesPaginated(address start, uint256 pageSize)
        external
        view
        returns (address[] memory array, address next)
    {
        require(start == SENTINEL_MODULES || isModuleEnabled(start), "GS105");
        require(pageSize > 0, "GS106");
        // Init array with max page size
        array = new address[](pageSize);

        // Populate return array
        uint256 moduleCount = 0;
        next = modules[start];
        while (next != address(0) && next != SENTINEL_MODULES && moduleCount < pageSize) {
            array[moduleCount] = next;
            next = modules[next];
            moduleCount++;
        }

        /**
         * Because of the argument validation, we can assume that the loop will always iterate over the valid module list values
         *       and the `next` variable will either be an enabled module or a sentinel address (signalling the end). 
         *
         *       If we haven't reached the end inside the loop, we need to set the next pointer to the last element of the modules array
         *       because the `next` variable (which is a module by itself) acting as a pointer to the start of the next page is neither 
         *       included to the current page, nor will it be included in the next one if you pass it as a start.
         */
        if (next != SENTINEL_MODULES) {
            next = array[moduleCount - 1];
        }
        // Set correct size of returned array
        // solhint-disable-next-line no-inline-assembly
        assembly {
            mstore(array, moduleCount)
        }
    }

    /**
     * @notice Returns true if `account` is a contract.
     * @dev This function will return false if invoked during the constructor of a contract,
     *      as the code is not actually created until after the constructor finishes.
     * @param account The address being queried
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

/**
 * @title OwnerManager - Manages Safe owners and a threshold to authorize transactions.
 * @dev Uses a linked list to store the owners because the code generate by the solidity compiler
 *      is more efficient than using a dynamic array.
 * @author Stefan George - @Georgi87
 * @author Richard Meissner - @rmeissner
 */
abstract contract OwnerManager is SelfAuthorized {
    event AddedOwner(address indexed owner);
    event RemovedOwner(address indexed owner);
    event ChangedThreshold(uint256 threshold);

    address internal constant SENTINEL_OWNERS = address(0x1);

    mapping(address => address) internal owners;
    uint256 internal ownerCount;
    uint256 internal threshold;

    /**
     * @notice Sets the initial storage of the contract.
     * @param _owners List of Safe owners.
     * @param _threshold Number of required confirmations for a Safe transaction.
     */
    function setupOwners(address[] memory _owners, uint256 _threshold) internal {
        // Threshold can only be 0 at initialization.
        // Check ensures that setup function can only be called once.
        require(threshold == 0, "GS200");
        // Validate that threshold is smaller than number of added owners.
        require(_threshold <= _owners.length, "GS201");
        // There has to be at least one Safe owner.
        require(_threshold >= 1, "GS202");
        // Initializing Safe owners.
        address currentOwner = SENTINEL_OWNERS;
        for (uint256 i = 0; i < _owners.length; i++) {
            // Owner address cannot be null.
            address owner = _owners[i];
            require(
                owner != address(0) && owner != SENTINEL_OWNERS && owner != address(this) && currentOwner != owner,
                "GS203"
            );
            // No duplicate owners allowed.
            require(owners[owner] == address(0), "GS204");
            owners[currentOwner] = owner;
            currentOwner = owner;
        }
        owners[currentOwner] = SENTINEL_OWNERS;
        ownerCount = _owners.length;
        threshold = _threshold;
    }

    /**
     * @notice Adds the owner `owner` to the Safe and updates the threshold to `_threshold`.
     * @dev This can only be done via a Safe transaction.
     * @param owner New owner address.
     * @param _threshold New threshold.
     */
    function addOwnerWithThreshold(address owner, uint256 _threshold) public authorized {
        // Owner address cannot be null, the sentinel or the Safe itself.
        require(owner != address(0) && owner != SENTINEL_OWNERS && owner != address(this), "GS203");
        // No duplicate owners allowed.
        require(owners[owner] == address(0), "GS204");
        owners[owner] = owners[SENTINEL_OWNERS];
        owners[SENTINEL_OWNERS] = owner;
        ownerCount++;
        emit AddedOwner(owner);
        // Change threshold if threshold was changed.
        if (threshold != _threshold) {
            changeThreshold(_threshold);
        }
    }

    /**
     * @notice Removes the owner `owner` from the Safe and updates the threshold to `_threshold`.
     * @dev This can only be done via a Safe transaction.
     * @param prevOwner Owner that pointed to the owner to be removed in the linked list
     * @param owner Owner address to be removed.
     * @param _threshold New threshold.
     */
    function removeOwner(address prevOwner, address owner, uint256 _threshold) public authorized {
        // Only allow to remove an owner, if threshold can still be reached.
        require(ownerCount - 1 >= _threshold, "GS201");
        // Validate owner address and check that it corresponds to owner index.
        require(owner != address(0) && owner != SENTINEL_OWNERS, "GS203");
        require(owners[prevOwner] == owner, "GS205");
        owners[prevOwner] = owners[owner];
        owners[owner] = address(0);
        ownerCount--;
        emit RemovedOwner(owner);
        // Change threshold if threshold was changed.
        if (threshold != _threshold) {
            changeThreshold(_threshold);
        }
    }

    /**
     * @notice Replaces the owner `oldOwner` in the Safe with `newOwner`.
     * @dev This can only be done via a Safe transaction.
     * @param prevOwner Owner that pointed to the owner to be replaced in the linked list
     * @param oldOwner Owner address to be replaced.
     * @param newOwner New owner address.
     */
    function swapOwner(address prevOwner, address oldOwner, address newOwner) public authorized {
        // Owner address cannot be null, the sentinel or the Safe itself.
        require(newOwner != address(0) && newOwner != SENTINEL_OWNERS && newOwner != address(this), "GS203");
        // No duplicate owners allowed.
        require(owners[newOwner] == address(0), "GS204");
        // Validate oldOwner address and check that it corresponds to owner index.
        require(oldOwner != address(0) && oldOwner != SENTINEL_OWNERS, "GS203");
        require(owners[prevOwner] == oldOwner, "GS205");
        owners[newOwner] = owners[oldOwner];
        owners[prevOwner] = newOwner;
        owners[oldOwner] = address(0);
        emit RemovedOwner(oldOwner);
        emit AddedOwner(newOwner);
    }

    /**
     * @notice Changes the threshold of the Safe to `_threshold`.
     * @dev This can only be done via a Safe transaction.
     * @param _threshold New threshold.
     */
    function changeThreshold(uint256 _threshold) public authorized {
        // Validate that threshold is smaller than number of owners.
        require(_threshold <= ownerCount, "GS201");
        // There has to be at least one Safe owner.
        require(_threshold >= 1, "GS202");
        threshold = _threshold;
        emit ChangedThreshold(threshold);
    }

    /**
     * @notice Returns the number of required confirmations for a Safe transaction aka the threshold.
     * @return Threshold number.
     */
    function getThreshold() public view returns (uint256) {
        return threshold;
    }

    /**
     * @notice Returns if `owner` is an owner of the Safe.
     * @return Boolean if owner is an owner of the Safe.
     */
    function isOwner(address owner) public view returns (bool) {
        return owner != SENTINEL_OWNERS && owners[owner] != address(0);
    }

    /**
     * @notice Returns a list of Safe owners.
     * @return Array of Safe owners.
     */
    function getOwners() public view returns (address[] memory) {
        address[] memory array = new address[](ownerCount);

        // populate return array
        uint256 index = 0;
        address currentOwner = owners[SENTINEL_OWNERS];
        while (currentOwner != SENTINEL_OWNERS) {
            array[index] = currentOwner;
            currentOwner = owners[currentOwner];
            index++;
        }
        return array;
    }
}

/**
 * @title SignatureDecoder - Decodes signatures encoded as bytes
 * @author Richard Meissner - @rmeissner
 */
abstract contract SignatureDecoder {
    /**
     * @notice Splits signature bytes into `uint8 v, bytes32 r, bytes32 s`.
     * @dev Make sure to perform a bounds check for @param pos, to avoid out of bounds access on @param signatures
     *      The signature format is a compact form of {bytes32 r}{bytes32 s}{uint8 v}
     *      Compact means uint8 is not padded to 32 bytes.
     * @param pos Which signature to read.
     *            A prior bounds check of this parameter should be performed, to avoid out of bounds access.
     * @param signatures Concatenated {r, s, v} signatures.
     * @return v Recovery ID or Safe signature type.
     * @return r Output value r of the signature.
     * @return s Output value s of the signature.
     */
    function signatureSplit(bytes memory signatures, uint256 pos)
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            let signaturePos := mul(0x41, pos)
            r := mload(add(signatures, add(signaturePos, 0x20)))
            s := mload(add(signatures, add(signaturePos, 0x40)))
            /**
             * Here we are loading the last 32 bytes, including 31 bytes
             * of 's'. There is no 'mload8' to do this.
             * 'byte' is not working due to the Solidity parser, so lets
             * use the second best option, 'and'
             */
            v := and(mload(add(signatures, add(signaturePos, 0x41))), 0xff)
        }
    }
}

/**
 * @title SecuredTokenTransfer - Secure token transfer.
 * @author Richard Meissner - @rmeissner
 */
abstract contract SecuredTokenTransfer {
    /**
     * @notice Transfers a token and returns a boolean if it was a success
     * @dev It checks the return data of the transfer call and returns true if the transfer was successful.
     *      It doesn't check if the `token` address is a contract or not.
     * @param token Token that should be transferred
     * @param receiver Receiver to whom the token should be transferred
     * @param amount The amount of tokens that should be transferred
     * @return transferred Returns true if the transfer was successful
     */
    function transferToken(address token, address receiver, uint256 amount) internal returns (bool transferred) {
        // 0xa9059cbb - keccack("transfer(address,uint256)")
        bytes memory data = abi.encodeWithSelector(0xa9059cbb, receiver, amount);
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // We write the return value to scratch space.
            // See https://docs.soliditylang.org/en/v0.7.6/internals/layout_in_memory.html#layout-in-memory
            let success := call(sub(gas(), 10000), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            switch returndatasize()
            case 0 { transferred := success }
            case 0x20 { transferred := iszero(or(iszero(success), iszero(mload(0)))) }
            default { transferred := 0 }
        }
    }
}

contract ISignatureValidatorConstants {
    // bytes4(keccak256("isValidSignature(bytes,bytes)")
    bytes4 internal constant EIP1271_MAGIC_VALUE = 0x20c13b0b;
}

/**
 * @title Fallback Manager - A contract managing fallback calls made to this contract
 * @author Richard Meissner - @rmeissner
 */
abstract contract FallbackManager is SelfAuthorized {
    event ChangedFallbackHandler(address indexed handler);

    // keccak256("fallback_manager.handler.address")
    bytes32 internal constant FALLBACK_HANDLER_STORAGE_SLOT =
        0x6c9a6c4a39284e37ed1cf53d337577d14212a4870fb976a4366c693b939918d5;

    /**
     *  @notice Internal function to set the fallback handler.
     *  @param handler contract to handle fallback calls.
     */
    function internalSetFallbackHandler(address handler) internal {
        /*
            If a fallback handler is set to self, then the following attack vector is opened:
            Imagine we have a function like this:
            function withdraw() internal authorized {
                withdrawalAddress.call.value(address(this).balance)("");
            }

            If the fallback method is triggered, the fallback handler appends the msg.sender address to the calldata and calls the fallback handler.
            A potential attacker could call a Safe with the 3 bytes signature of a withdraw function. Since 3 bytes do not create a valid signature,
            the call would end in a fallback handler. Since it appends the msg.sender address to the calldata, the attacker could craft an address 
            where the first 3 bytes of the previous calldata + the first byte of the address make up a valid function signature. The subsequent call would result in unsanctioned access to Safe's internal protected methods.
            For some reason, solidity matches the first 4 bytes of the calldata to a function signature, regardless if more data follow these 4 bytes.
        */
        require(handler != address(this), "GS400");

        bytes32 slot = FALLBACK_HANDLER_STORAGE_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, handler)
        }
    }

    /**
     * @notice Set Fallback Handler to `handler` for the Safe.
     * @dev Only fallback calls without value and with data will be forwarded.
     *      This can only be done via a Safe transaction.
     *      Cannot be set to the Safe itself.
     * @param handler contract to handle fallback calls.
     */
    function setFallbackHandler(address handler) public authorized {
        internalSetFallbackHandler(handler);
        emit ChangedFallbackHandler(handler);
    }

    // @notice Forwards all calls to the fallback handler if set. Returns 0 if no handler is set.
    // @dev Appends the non-padded caller address to the calldata to be optionally used in the handler
    //      The handler can make us of `HandlerContext.sol` to extract the address.
    //      This is done because in the next call frame the `msg.sender` will be FallbackManager's address
    //      and having the original caller address may enable additional verification scenarios.
    // solhint-disable-next-line payable-fallback,no-complex-fallback
    fallback() external {
        bytes32 slot = FALLBACK_HANDLER_STORAGE_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            let handler := sload(slot)
            if iszero(handler) { return(0, 0) }
            calldatacopy(0, 0, calldatasize())
            // The msg.sender address is shifted to the left by 12 bytes to remove the padding
            // Then the address without padding is stored right after the calldata
            mstore(calldatasize(), shl(96, caller()))
            // Add 20 bytes for the address appended add the end
            let success := call(gas(), handler, 0, 0, add(calldatasize(), 20), 0, 0)
            returndatacopy(0, 0, returndatasize())
            if iszero(success) { revert(0, returndatasize()) }
            return(0, returndatasize())
        }
    }
}

/**
 * @title StorageAccessible - A generic base contract that allows callers to access all internal storage.
 * @notice See https://github.com/gnosis/util-contracts/blob/bb5fe5fb5df6d8400998094fb1b32a178a47c3a1/contracts/StorageAccessible.sol
 *         It removes a method from the original contract not needed for the Safe contracts.
 * @author Gnosis Developers
 */
abstract contract StorageAccessible {
    /**
     * @notice Reads `length` bytes of storage in the currents contract
     * @param offset - the offset in the current contract's storage in words to start reading from
     * @param length - the number of words (32 bytes) of data to read
     * @return the bytes that were read.
     */
    function getStorageAt(uint256 offset, uint256 length) public view returns (bytes memory) {
        bytes memory result = new bytes(length * 32);
        for (uint256 index = 0; index < length; index++) {
            // solhint-disable-next-line no-inline-assembly
            assembly {
                let word := sload(add(offset, index))
                mstore(add(add(result, 0x20), mul(index, 0x20)), word)
            }
        }
        return result;
    }

    /**
     * @dev Performs a delegatecall on a targetContract in the context of self.
     * Internally reverts execution to avoid side effects (making it static).
     *
     * This method reverts with data equal to `abi.encode(bool(success), bytes(response))`.
     * Specifically, the `returndata` after a call to this method will be:
     * `success:bool || response.length:uint256 || response:bytes`.
     *
     * @param targetContract Address of the contract containing the code to execute.
     * @param calldataPayload Calldata that should be sent to the target contract (encoded method name and arguments).
     */
    function simulateAndRevert(address targetContract, bytes memory calldataPayload) external {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            let success := delegatecall(gas(), targetContract, add(calldataPayload, 0x20), mload(calldataPayload), 0, 0)

            mstore(0x00, success)
            mstore(0x20, returndatasize())
            returndatacopy(0x40, 0, returndatasize())
            revert(0, add(returndatasize(), 0x40))
        }
    }
}

/// @notice More details at https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/IERC165.sol
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by `interfaceId`.
     * See the corresponding EIP section
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface Guard is IERC165 {
    function checkTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures,
        address msgSender
    ) external;

    function checkAfterExecution(bytes32 txHash, bool success) external;
}

/**
 * @title Guard Manager - A contract managing transaction guards which perform pre and post-checks on Safe transactions.
 * @author Richard Meissner - @rmeissner
 */
abstract contract GuardManager is SelfAuthorized {
    event ChangedGuard(address indexed guard);

    // keccak256("guard_manager.guard.address")
    bytes32 internal constant GUARD_STORAGE_SLOT = 0x4a204f620c8c5ccdca3fd54d003badd85ba500436a431f0cbda4f558c93c34c8;

    /**
     * @dev Set a guard that checks transactions before execution
     *      This can only be done via a Safe transaction.
     *      ⚠️ IMPORTANT: Since a guard has full power to block Safe transaction execution,
     *        a broken guard can cause a denial of service for the Safe. Make sure to carefully
     *        audit the guard code and design recovery mechanisms.
     * @notice Set Transaction Guard `guard` for the Safe. Make sure you trust the guard.
     * @param guard The address of the guard to be used or the 0 address to disable the guard
     */
    function setGuard(address guard) external authorized {
        if (guard != address(0)) {
            require(Guard(guard).supportsInterface(type(Guard).interfaceId), "GS300");
        }
        bytes32 slot = GUARD_STORAGE_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, guard)
        }
        emit ChangedGuard(guard);
    }

    /**
     * @dev Internal method to retrieve the current guard
     *      We do not have a public method because we're short on bytecode size limit,
     *      to retrieve the guard address, one can use `getStorageAt` from `StorageAccessible` contract
     *      with the slot `GUARD_STORAGE_SLOT`
     * @return guard The address of the guard
     */
    function getGuard() internal view returns (address guard) {
        bytes32 slot = GUARD_STORAGE_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            guard := sload(slot)
        }
    }
}

/**
 * @title SafeMath
 * @notice Math operations with safety checks that revert on error (overflow/underflow)
 */
library SafeMath {
    /**
     * @notice Multiplies two numbers, reverts on overflow.
     * @param a First number
     * @param b Second number
     * @return Product of a and b
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @notice Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     * @param a First number
     * @param b Second number
     * @return Difference of a and b
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @notice Adds two numbers, reverts on overflow.
     * @param a First number
     * @param b Second number
     * @return Sum of a and b
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @notice Returns the largest of two numbers.
     * @param a First number
     * @param b Second number
     * @return Largest of a and b
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }
}

abstract contract ISignatureValidator is ISignatureValidatorConstants {
    /**
     * @notice Legacy EIP1271 method to validate a signature.
     * @param _data Arbitrary length data signed on the behalf of address(this).
     * @param _signature Signature byte array associated with _data.
     *
     * MUST return the bytes4 magic value 0x20c13b0b when function passes.
     * MUST NOT modify state (using STATICCALL for solc < 0.5, view modifier for solc > 0.5)
     * MUST allow external calls
     */
    function isValidSignature(bytes memory _data, bytes memory _signature) public view virtual returns (bytes4);
}

/**
 * @title Safe - A multisignature wallet with support for confirmations using signed messages based on EIP-712.
 * @dev Most important concepts:
 *      - Threshold: Number of required confirmations for a Safe transaction.
 *      - Owners: List of addresses that control the Safe. They are the only ones that can add/remove owners, change the threshold and
 *        approve transactions. Managed in `OwnerManager`.
 *      - Transaction Hash: Hash of a transaction is calculated using the EIP-712 typed structured data hashing scheme.
 *      - Nonce: Each transaction should have a different nonce to prevent replay attacks.
 *      - Signature: A valid signature of an owner of the Safe for a transaction hash.
 *      - Guard: Guard is a contract that can execute pre- and post- transaction checks. Managed in `GuardManager`.
 *      - Modules: Modules are contracts that can be used to extend the write functionality of a Safe. Managed in `ModuleManager`.
 *      - Fallback: Fallback handler is a contract that can provide additional read-only functional for Safe. Managed in `FallbackManager`.
 *      Note: This version of the implementation contract doesn't emit events for the sake of gas efficiency and therefore requires a tracing node for indexing/
 *      For the events-based implementation see `SafeL2.sol`.
 * @author Stefan George - @Georgi87
 * @author Richard Meissner - @rmeissner
 */
contract Safe is
    Singleton,
    NativeCurrencyPaymentFallback,
    ModuleManager,
    OwnerManager,
    SignatureDecoder,
    SecuredTokenTransfer,
    ISignatureValidatorConstants,
    FallbackManager,
    StorageAccessible,
    GuardManager
{
    using SafeMath for uint256;

    string public constant VERSION = "1.4.1";

    // keccak256(
    //     "EIP712Domain(uint256 chainId,address verifyingContract)"
    // );
    bytes32 private constant DOMAIN_SEPARATOR_TYPEHASH =
        0x47e79534a245952e8b16893a336b85a3d9ea9fa8c573f3d803afb92a79469218;

    // keccak256(
    //     "SafeTx(address to,uint256 value,bytes data,uint8 operation,uint256 safeTxGas,uint256 baseGas,uint256 gasPrice,address gasToken,address refundReceiver,uint256 nonce)"
    // );
    bytes32 private constant SAFE_TX_TYPEHASH = 0xbb8310d486368db6bd6f849402fdd73ad53d316b5a4b2644ad6efe0f941286d8;

    event SafeSetup(
        address indexed initiator, address[] owners, uint256 threshold, address initializer, address fallbackHandler
    );
    event ApproveHash(bytes32 indexed approvedHash, address indexed owner);
    event SignMsg(bytes32 indexed msgHash);
    event ExecutionFailure(bytes32 indexed txHash, uint256 payment);
    event ExecutionSuccess(bytes32 indexed txHash, uint256 payment);

    uint256 public nonce;
    bytes32 private _deprecatedDomainSeparator;
    // Mapping to keep track of all message hashes that have been approved by ALL REQUIRED owners
    mapping(bytes32 => uint256) public signedMessages;
    // Mapping to keep track of all hashes (message or transaction) that have been approved by ANY owners
    mapping(address => mapping(bytes32 => uint256)) public approvedHashes;

    // This constructor ensures that this contract can only be used as a singleton for Proxy contracts
    constructor() {
        /**
         * By setting the threshold it is not possible to call setup anymore,
         * so we create a Safe with 0 owners and threshold 1.
         * This is an unusable Safe, perfect for the singleton
         */
        threshold = 1;
    }

    /**
     * @notice Sets an initial storage of the Safe contract.
     * @dev This method can only be called once.
     *      If a proxy was created without setting up, anyone can call setup and claim the proxy.
     * @param _owners List of Safe owners.
     * @param _threshold Number of required confirmations for a Safe transaction.
     * @param to Contract address for optional delegate call.
     * @param data Data payload for optional delegate call.
     * @param fallbackHandler Handler for fallback calls to this contract
     * @param paymentToken Token that should be used for the payment (0 is ETH)
     * @param payment Value that should be paid
     * @param paymentReceiver Address that should receive the payment (or 0 if tx.origin)
     */
    function setup(
        address[] calldata _owners,
        uint256 _threshold,
        address to,
        bytes calldata data,
        address fallbackHandler,
        address paymentToken,
        uint256 payment,
        address payable paymentReceiver
    ) external {
        // setupOwners checks if the Threshold is already set, therefore preventing that this method is called twice
        setupOwners(_owners, _threshold);
        if (fallbackHandler != address(0)) {
            internalSetFallbackHandler(fallbackHandler);
        }
        // As setupOwners can only be called if the contract has not been initialized we don't need a check for setupModules
        setupModules(to, data);

        if (payment > 0) {
            // To avoid running into issues with EIP-170 we reuse the handlePayment function (to avoid adjusting code of that has been verified we do not adjust the method itself)
            // baseGas = 0, gasPrice = 1 and gas = payment => amount = (payment + 0) * 1 = payment
            handlePayment(payment, 0, 1, paymentToken, paymentReceiver);
        }
        emit SafeSetup(msg.sender, _owners, _threshold, to, fallbackHandler);
    }

    /**
     * @notice Executes a `operation` {0: Call, 1: DelegateCall}} transaction to `to` with `value` (Native Currency)
     *          and pays `gasPrice` * `gasLimit` in `gasToken` token to `refundReceiver`.
     * @dev The fees are always transferred, even if the user transaction fails.
     *      This method doesn't perform any sanity check of the transaction, such as:
     *      - if the contract at `to` address has code or not
     *      - if the `gasToken` is a contract or not
     *      It is the responsibility of the caller to perform such checks.
     * @param to Destination address of Safe transaction.
     * @param value Ether value of Safe transaction.
     * @param data Data payload of Safe transaction.
     * @param operation Operation type of Safe transaction.
     * @param safeTxGas Gas that should be used for the Safe transaction.
     * @param baseGas Gas costs that are independent of the transaction execution(e.g. base transaction fee, signature check, payment of the refund)
     * @param gasPrice Gas price that should be used for the payment calculation.
     * @param gasToken Token address (or 0 if ETH) that is used for the payment.
     * @param refundReceiver Address of receiver of gas payment (or 0 if tx.origin).
     * @param signatures Signature data that should be verified.
     *                   Can be packed ECDSA signature ({bytes32 r}{bytes32 s}{uint8 v}), contract signature (EIP-1271) or approved hash.
     * @return success Boolean indicating transaction's success.
     */
    function execTransaction(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures
    ) public payable virtual returns (bool success) {
        bytes32 txHash;
        // Use scope here to limit variable lifetime and prevent `stack too deep` errors
        {
            bytes memory txHashData = encodeTransactionData(
                // Transaction info
                to,
                value,
                data,
                operation,
                safeTxGas,
                // Payment info
                baseGas,
                gasPrice,
                gasToken,
                refundReceiver,
                // Signature info
                nonce
            );
            // Increase nonce and execute transaction.
            nonce++;
            txHash = keccak256(txHashData);
            checkSignatures(txHash, txHashData, signatures);
        }
        address guard = getGuard();
        {
            if (guard != address(0)) {
                Guard(guard).checkTransaction(
                    // Transaction info
                    to,
                    value,
                    data,
                    operation,
                    safeTxGas,
                    // Payment info
                    baseGas,
                    gasPrice,
                    gasToken,
                    refundReceiver,
                    // Signature info
                    signatures,
                    msg.sender
                );
            }
        }
        // We require some gas to emit the events (at least 2500) after the execution and some to perform code until the execution (500)
        // We also include the 1/64 in the check that is not send along with a call to counteract potential shortings because of EIP-150
        require(gasleft() >= ((safeTxGas * 64) / 63).max(safeTxGas + 2500) + 500, "GS010");
        // Use scope here to limit variable lifetime and prevent `stack too deep` errors
        {
            uint256 gasUsed = gasleft();
            // If the gasPrice is 0 we assume that nearly all available gas can be used (it is always more than safeTxGas)
            // We only substract 2500 (compared to the 3000 before) to ensure that the amount passed is still higher than safeTxGas
            success = execute(to, value, data, operation, gasPrice == 0 ? (gasleft() - 2500) : safeTxGas);
            gasUsed = gasUsed.sub(gasleft());
            // If no safeTxGas and no gasPrice was set (e.g. both are 0), then the internal tx is required to be successful
            // This makes it possible to use `estimateGas` without issues, as it searches for the minimum gas where the tx doesn't revert
            require(success || safeTxGas != 0 || gasPrice != 0, "GS013");
            // We transfer the calculated tx costs to the tx.origin to avoid sending it to intermediate contracts that have made calls
            uint256 payment = 0;
            if (gasPrice > 0) {
                payment = handlePayment(gasUsed, baseGas, gasPrice, gasToken, refundReceiver);
            }
            if (success) {
                emit ExecutionSuccess(txHash, payment);
            } else {
                emit ExecutionFailure(txHash, payment);
            }
        }
        {
            if (guard != address(0)) {
                Guard(guard).checkAfterExecution(txHash, success);
            }
        }
    }

    /**
     * @notice Handles the payment for a Safe transaction.
     * @param gasUsed Gas used by the Safe transaction.
     * @param baseGas Gas costs that are independent of the transaction execution (e.g. base transaction fee, signature check, payment of the refund).
     * @param gasPrice Gas price that should be used for the payment calculation.
     * @param gasToken Token address (or 0 if ETH) that is used for the payment.
     * @return payment The amount of payment made in the specified token.
     */
    function handlePayment(
        uint256 gasUsed,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver
    ) private returns (uint256 payment) {
        // solhint-disable-next-line avoid-tx-origin
        address payable receiver = refundReceiver == address(0) ? payable(tx.origin) : refundReceiver;
        if (gasToken == address(0)) {
            // For ETH we will only adjust the gas price to not be higher than the actual used gas price
            payment = gasUsed.add(baseGas).mul(gasPrice < tx.gasprice ? gasPrice : tx.gasprice);
            require(receiver.send(payment), "GS011");
        } else {
            payment = gasUsed.add(baseGas).mul(gasPrice);
            require(transferToken(gasToken, receiver, payment), "GS012");
        }
    }

    /**
     * @notice Checks whether the signature provided is valid for the provided data and hash. Reverts otherwise.
     * @param dataHash Hash of the data (could be either a message hash or transaction hash)
     * @param data That should be signed (this is passed to an external validator contract)
     * @param signatures Signature data that should be verified.
     *                   Can be packed ECDSA signature ({bytes32 r}{bytes32 s}{uint8 v}), contract signature (EIP-1271) or approved hash.
     */
    function checkSignatures(bytes32 dataHash, bytes memory data, bytes memory signatures) public view {
        // Load threshold to avoid multiple storage loads
        uint256 _threshold = threshold;
        // Check that a threshold is set
        require(_threshold > 0, "GS001");
        checkNSignatures(dataHash, data, signatures, _threshold);
    }

    /**
     * @notice Checks whether the signature provided is valid for the provided data and hash. Reverts otherwise.
     * @dev Since the EIP-1271 does an external call, be mindful of reentrancy attacks.
     * @param dataHash Hash of the data (could be either a message hash or transaction hash)
     * @param data That should be signed (this is passed to an external validator contract)
     * @param signatures Signature data that should be verified.
     *                   Can be packed ECDSA signature ({bytes32 r}{bytes32 s}{uint8 v}), contract signature (EIP-1271) or approved hash.
     * @param requiredSignatures Amount of required valid signatures.
     */
    function checkNSignatures(bytes32 dataHash, bytes memory data, bytes memory signatures, uint256 requiredSignatures)
        public
        view
    {
        // Check that the provided signature data is not too short
        require(signatures.length >= requiredSignatures.mul(65), "GS020");
        // There cannot be an owner with address 0.
        address lastOwner = address(0);
        address currentOwner;
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 i;
        for (i = 0; i < requiredSignatures; i++) {
            (v, r, s) = signatureSplit(signatures, i);
            if (v == 0) {
                require(keccak256(data) == dataHash, "GS027");
                // If v is 0 then it is a contract signature
                // When handling contract signatures the address of the contract is encoded into r
                currentOwner = address(uint160(uint256(r)));

                // Check that signature data pointer (s) is not pointing inside the static part of the signatures bytes
                // This check is not completely accurate, since it is possible that more signatures than the threshold are send.
                // Here we only check that the pointer is not pointing inside the part that is being processed
                require(uint256(s) >= requiredSignatures.mul(65), "GS021");

                // Check that signature data pointer (s) is in bounds (points to the length of data -> 32 bytes)
                require(uint256(s).add(32) <= signatures.length, "GS022");

                // Check if the contract signature is in bounds: start of data is s + 32 and end is start + signature length
                uint256 contractSignatureLen;
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    contractSignatureLen := mload(add(add(signatures, s), 0x20))
                }
                require(uint256(s).add(32).add(contractSignatureLen) <= signatures.length, "GS023");

                // Check signature
                bytes memory contractSignature;
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    // The signature data for contract signatures is appended to the concatenated signatures and the offset is stored in s
                    contractSignature := add(add(signatures, s), 0x20)
                }
                require(
                    ISignatureValidator(currentOwner).isValidSignature(data, contractSignature) == EIP1271_MAGIC_VALUE,
                    "GS024"
                );
            } else if (v == 1) {
                // If v is 1 then it is an approved hash
                // When handling approved hashes the address of the approver is encoded into r
                currentOwner = address(uint160(uint256(r)));
                // Hashes are automatically approved by the sender of the message or when they have been pre-approved via a separate transaction
                require(msg.sender == currentOwner || approvedHashes[currentOwner][dataHash] != 0, "GS025");
            } else if (v > 30) {
                // If v > 30 then default va (27,28) has been adjusted for eth_sign flow
                // To support eth_sign and similar we adjust v and hash the messageHash with the Ethereum message prefix before applying ecrecover
                currentOwner =
                    ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", dataHash)), v - 4, r, s);
            } else {
                // Default is the ecrecover flow with the provided data hash
                // Use ecrecover with the messageHash for EOA signatures
                currentOwner = ecrecover(dataHash, v, r, s);
            }
            require(
                currentOwner > lastOwner && owners[currentOwner] != address(0) && currentOwner != SENTINEL_OWNERS,
                "GS026"
            );
            lastOwner = currentOwner;
        }
    }

    /**
     * @notice Marks hash `hashToApprove` as approved.
     * @dev This can be used with a pre-approved hash transaction signature.
     *      IMPORTANT: The approved hash stays approved forever. There's no revocation mechanism, so it behaves similarly to ECDSA signatures
     * @param hashToApprove The hash to mark as approved for signatures that are verified by this contract.
     */
    function approveHash(bytes32 hashToApprove) external {
        require(owners[msg.sender] != address(0), "GS030");
        approvedHashes[msg.sender][hashToApprove] = 1;
        emit ApproveHash(hashToApprove, msg.sender);
    }

    /**
     * @notice Returns the ID of the chain the contract is currently deployed on.
     * @return The ID of the current chain as a uint256.
     */
    function getChainId() public view returns (uint256) {
        uint256 id;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            id := chainid()
        }
        return id;
    }

    /**
     * @dev Returns the domain separator for this contract, as defined in the EIP-712 standard.
     * @return bytes32 The domain separator hash.
     */
    function domainSeparator() public view returns (bytes32) {
        return keccak256(abi.encode(DOMAIN_SEPARATOR_TYPEHASH, getChainId(), this));
    }

    /**
     * @notice Returns the pre-image of the transaction hash (see getTransactionHash).
     * @param to Destination address.
     * @param value Ether value.
     * @param data Data payload.
     * @param operation Operation type.
     * @param safeTxGas Gas that should be used for the safe transaction.
     * @param baseGas Gas costs for that are independent of the transaction execution(e.g. base transaction fee, signature check, payment of the refund)
     * @param gasPrice Maximum gas price that should be used for this transaction.
     * @param gasToken Token address (or 0 if ETH) that is used for the payment.
     * @param refundReceiver Address of receiver of gas payment (or 0 if tx.origin).
     * @param _nonce Transaction nonce.
     * @return Transaction hash bytes.
     */
    function encodeTransactionData(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address refundReceiver,
        uint256 _nonce
    ) public view returns (bytes memory) {
        bytes32 safeTxHash = keccak256(
            abi.encode(
                SAFE_TX_TYPEHASH,
                to,
                value,
                keccak256(data),
                operation,
                safeTxGas,
                baseGas,
                gasPrice,
                gasToken,
                refundReceiver,
                _nonce
            )
        );
        return abi.encodePacked(bytes1(0x19), bytes1(0x01), domainSeparator(), safeTxHash);
    }

    /**
     * @notice Returns transaction hash to be signed by owners.
     * @param to Destination address.
     * @param value Ether value.
     * @param data Data payload.
     * @param operation Operation type.
     * @param safeTxGas Fas that should be used for the safe transaction.
     * @param baseGas Gas costs for data used to trigger the safe transaction.
     * @param gasPrice Maximum gas price that should be used for this transaction.
     * @param gasToken Token address (or 0 if ETH) that is used for the payment.
     * @param refundReceiver Address of receiver of gas payment (or 0 if tx.origin).
     * @param _nonce Transaction nonce.
     * @return Transaction hash.
     */
    function getTransactionHash(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address refundReceiver,
        uint256 _nonce
    ) public view returns (bytes32) {
        return keccak256(
            encodeTransactionData(
                to, value, data, operation, safeTxGas, baseGas, gasPrice, gasToken, refundReceiver, _nonce
            )
        );
    }
}

/// @notice Library for converting numbers into strings and other string operations.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibString.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/LibString.sol)
///
/// Note:
/// For performance and bytecode compactness, most of the string operations are restricted to
/// byte strings (7-bit ASCII), except where otherwise specified.
/// Usage of byte string operations on charsets with runes spanning two or more bytes
/// can lead to undefined behavior.
library LibString {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CUSTOM ERRORS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The length of the output is too small to contain all the hex digits.
    error HexLengthInsufficient();

    /// @dev The length of the string is more than 32 bytes.
    error TooBigForSmallString();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The constant returned when the `search` is not found in the string.
    uint256 internal constant NOT_FOUND = type(uint256).max;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     DECIMAL OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the base 10 decimal representation of `value`.
    function toString(uint256 value) internal pure returns (string memory str) {
        /// @solidity memory-safe-assembly
        assembly {
            // The maximum value of a uint256 contains 78 digits (1 byte per digit), but
            // we allocate 0xa0 bytes to keep the free memory pointer 32-byte word aligned.
            // We will need 1 word for the trailing zeros padding, 1 word for the length,
            // and 3 words for a maximum of 78 digits.
            str := add(mload(0x40), 0x80)
            // Update the free memory pointer to allocate.
            mstore(0x40, add(str, 0x20))
            // Zeroize the slot after the string.
            mstore(str, 0)

            // Cache the end of the memory to calculate the length later.
            let end := str

            let w := not(0) // Tsk.
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for { let temp := value } 1 {} {
                str := add(str, w) // `sub(str, 1)`.
                // Write the character to the pointer.
                // The ASCII index of the '0' character is 48.
                mstore8(str, add(48, mod(temp, 10)))
                // Keep dividing `temp` until zero.
                temp := div(temp, 10)
                if iszero(temp) { break }
            }

            let length := sub(end, str)
            // Move the pointer 32 bytes leftwards to make room for the length.
            str := sub(str, 0x20)
            // Store the length.
            mstore(str, length)
        }
    }

    /// @dev Returns the base 10 decimal representation of `value`.
    function toString(int256 value) internal pure returns (string memory str) {
        if (value >= 0) {
            return toString(uint256(value));
        }
        unchecked {
            str = toString(uint256(-value));
        }
        /// @solidity memory-safe-assembly
        assembly {
            // We still have some spare memory space on the left,
            // as we have allocated 3 words (96 bytes) for up to 78 digits.
            let length := mload(str) // Load the string length.
            mstore(str, 0x2d) // Store the '-' character.
            str := sub(str, 1) // Move back the string pointer by a byte.
            mstore(str, add(length, 1)) // Update the string length.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   HEXADECIMAL OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the hexadecimal representation of `value`,
    /// left-padded to an input length of `length` bytes.
    /// The output is prefixed with "0x" encoded using 2 hexadecimal digits per byte,
    /// giving a total length of `length * 2 + 2` bytes.
    /// Reverts if `length` is too small for the output to contain all the digits.
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory str) {
        str = toHexStringNoPrefix(value, length);
        /// @solidity memory-safe-assembly
        assembly {
            let strLength := add(mload(str), 2) // Compute the length.
            mstore(str, 0x3078) // Write the "0x" prefix.
            str := sub(str, 2) // Move the pointer.
            mstore(str, strLength) // Write the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`,
    /// left-padded to an input length of `length` bytes.
    /// The output is prefixed with "0x" encoded using 2 hexadecimal digits per byte,
    /// giving a total length of `length * 2` bytes.
    /// Reverts if `length` is too small for the output to contain all the digits.
    function toHexStringNoPrefix(uint256 value, uint256 length) internal pure returns (string memory str) {
        /// @solidity memory-safe-assembly
        assembly {
            // We need 0x20 bytes for the trailing zeros padding, `length * 2` bytes
            // for the digits, 0x02 bytes for the prefix, and 0x20 bytes for the length.
            // We add 0x20 to the total and round down to a multiple of 0x20.
            // (0x20 + 0x20 + 0x02 + 0x20) = 0x62.
            str := add(mload(0x40), and(add(shl(1, length), 0x42), not(0x1f)))
            // Allocate the memory.
            mstore(0x40, add(str, 0x20))
            // Zeroize the slot after the string.
            mstore(str, 0)

            // Cache the end to calculate the length later.
            let end := str
            // Store "0123456789abcdef" in scratch space.
            mstore(0x0f, 0x30313233343536373839616263646566)

            let start := sub(str, add(length, length))
            let w := not(1) // Tsk.
            let temp := value
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for {} 1 {} {
                str := add(str, w) // `sub(str, 2)`.
                mstore8(add(str, 1), mload(and(temp, 15)))
                mstore8(str, mload(and(shr(4, temp), 15)))
                temp := shr(8, temp)
                if iszero(xor(str, start)) { break }
            }

            if temp {
                mstore(0x00, 0x2194895a) // `HexLengthInsufficient()`.
                revert(0x1c, 0x04)
            }

            // Compute the string's length.
            let strLength := sub(end, str)
            // Move the pointer and write the length.
            str := sub(str, 0x20)
            mstore(str, strLength)
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x" and encoded using 2 hexadecimal digits per byte.
    /// As address are 20 bytes long, the output will left-padded to have
    /// a length of `20 * 2 + 2` bytes.
    function toHexString(uint256 value) internal pure returns (string memory str) {
        str = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly
        assembly {
            let strLength := add(mload(str), 2) // Compute the length.
            mstore(str, 0x3078) // Write the "0x" prefix.
            str := sub(str, 2) // Move the pointer.
            mstore(str, strLength) // Write the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x".
    /// The output excludes leading "0" from the `toHexString` output.
    /// `0x00: "0x0", 0x01: "0x1", 0x12: "0x12", 0x123: "0x123"`.
    function toMinimalHexString(uint256 value) internal pure returns (string memory str) {
        str = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly
        assembly {
            let o := eq(byte(0, mload(add(str, 0x20))), 0x30) // Whether leading zero is present.
            let strLength := add(mload(str), 2) // Compute the length.
            mstore(add(str, o), 0x3078) // Write the "0x" prefix, accounting for leading zero.
            str := sub(add(str, o), 2) // Move the pointer, accounting for leading zero.
            mstore(str, sub(strLength, o)) // Write the length, accounting for leading zero.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output excludes leading "0" from the `toHexStringNoPrefix` output.
    /// `0x00: "0", 0x01: "1", 0x12: "12", 0x123: "123"`.
    function toMinimalHexStringNoPrefix(uint256 value) internal pure returns (string memory str) {
        str = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly
        assembly {
            let o := eq(byte(0, mload(add(str, 0x20))), 0x30) // Whether leading zero is present.
            let strLength := mload(str) // Get the length.
            str := add(str, o) // Move the pointer, accounting for leading zero.
            mstore(str, sub(strLength, o)) // Write the length, accounting for leading zero.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is encoded using 2 hexadecimal digits per byte.
    /// As address are 20 bytes long, the output will left-padded to have
    /// a length of `20 * 2` bytes.
    function toHexStringNoPrefix(uint256 value) internal pure returns (string memory str) {
        /// @solidity memory-safe-assembly
        assembly {
            // We need 0x20 bytes for the trailing zeros padding, 0x20 bytes for the length,
            // 0x02 bytes for the prefix, and 0x40 bytes for the digits.
            // The next multiple of 0x20 above (0x20 + 0x20 + 0x02 + 0x40) is 0xa0.
            str := add(mload(0x40), 0x80)
            // Allocate the memory.
            mstore(0x40, add(str, 0x20))
            // Zeroize the slot after the string.
            mstore(str, 0)

            // Cache the end to calculate the length later.
            let end := str
            // Store "0123456789abcdef" in scratch space.
            mstore(0x0f, 0x30313233343536373839616263646566)

            let w := not(1) // Tsk.
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for { let temp := value } 1 {} {
                str := add(str, w) // `sub(str, 2)`.
                mstore8(add(str, 1), mload(and(temp, 15)))
                mstore8(str, mload(and(shr(4, temp), 15)))
                temp := shr(8, temp)
                if iszero(temp) { break }
            }

            // Compute the string's length.
            let strLength := sub(end, str)
            // Move the pointer and write the length.
            str := sub(str, 0x20)
            mstore(str, strLength)
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x", encoded using 2 hexadecimal digits per byte,
    /// and the alphabets are capitalized conditionally according to
    /// https://eips.ethereum.org/EIPS/eip-55
    function toHexStringChecksummed(address value) internal pure returns (string memory str) {
        str = toHexString(value);
        /// @solidity memory-safe-assembly
        assembly {
            let mask := shl(6, div(not(0), 255)) // `0b010000000100000000 ...`
            let o := add(str, 0x22)
            let hashed := and(keccak256(o, 40), mul(34, mask)) // `0b10001000 ... `
            let t := shl(240, 136) // `0b10001000 << 240`
            for { let i := 0 } 1 {} {
                mstore(add(i, i), mul(t, byte(i, hashed)))
                i := add(i, 1)
                if eq(i, 20) { break }
            }
            mstore(o, xor(mload(o), shr(1, and(mload(0x00), and(mload(o), mask)))))
            o := add(o, 0x20)
            mstore(o, xor(mload(o), shr(1, and(mload(0x20), and(mload(o), mask)))))
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x" and encoded using 2 hexadecimal digits per byte.
    function toHexString(address value) internal pure returns (string memory str) {
        str = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly
        assembly {
            let strLength := add(mload(str), 2) // Compute the length.
            mstore(str, 0x3078) // Write the "0x" prefix.
            str := sub(str, 2) // Move the pointer.
            mstore(str, strLength) // Write the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is encoded using 2 hexadecimal digits per byte.
    function toHexStringNoPrefix(address value) internal pure returns (string memory str) {
        /// @solidity memory-safe-assembly
        assembly {
            str := mload(0x40)

            // Allocate the memory.
            // We need 0x20 bytes for the trailing zeros padding, 0x20 bytes for the length,
            // 0x02 bytes for the prefix, and 0x28 bytes for the digits.
            // The next multiple of 0x20 above (0x20 + 0x20 + 0x02 + 0x28) is 0x80.
            mstore(0x40, add(str, 0x80))

            // Store "0123456789abcdef" in scratch space.
            mstore(0x0f, 0x30313233343536373839616263646566)

            str := add(str, 2)
            mstore(str, 40)

            let o := add(str, 0x20)
            mstore(add(o, 40), 0)

            value := shl(96, value)

            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for { let i := 0 } 1 {} {
                let p := add(o, add(i, i))
                let temp := byte(i, value)
                mstore8(add(p, 1), mload(and(temp, 15)))
                mstore8(p, mload(shr(4, temp)))
                i := add(i, 1)
                if eq(i, 20) { break }
            }
        }
    }

    /// @dev Returns the hex encoded string from the raw bytes.
    /// The output is encoded using 2 hexadecimal digits per byte.
    function toHexString(bytes memory raw) internal pure returns (string memory str) {
        str = toHexStringNoPrefix(raw);
        /// @solidity memory-safe-assembly
        assembly {
            let strLength := add(mload(str), 2) // Compute the length.
            mstore(str, 0x3078) // Write the "0x" prefix.
            str := sub(str, 2) // Move the pointer.
            mstore(str, strLength) // Write the length.
        }
    }

    /// @dev Returns the hex encoded string from the raw bytes.
    /// The output is encoded using 2 hexadecimal digits per byte.
    function toHexStringNoPrefix(bytes memory raw) internal pure returns (string memory str) {
        /// @solidity memory-safe-assembly
        assembly {
            let length := mload(raw)
            str := add(mload(0x40), 2) // Skip 2 bytes for the optional prefix.
            mstore(str, add(length, length)) // Store the length of the output.

            // Store "0123456789abcdef" in scratch space.
            mstore(0x0f, 0x30313233343536373839616263646566)

            let o := add(str, 0x20)
            let end := add(raw, length)

            for {} iszero(eq(raw, end)) {} {
                raw := add(raw, 1)
                mstore8(add(o, 1), mload(and(mload(raw), 15)))
                mstore8(o, mload(and(shr(4, mload(raw)), 15)))
                o := add(o, 2)
            }
            mstore(o, 0) // Zeroize the slot after the string.
            mstore(0x40, add(o, 0x20)) // Allocate the memory.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   RUNE STRING OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the number of UTF characters in the string.
    function runeCount(string memory s) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            if mload(s) {
                mstore(0x00, div(not(0), 255))
                mstore(0x20, 0x0202020202020202020202020202020202020202020202020303030304040506)
                let o := add(s, 0x20)
                let end := add(o, mload(s))
                for { result := 1 } 1 { result := add(result, 1) } {
                    o := add(o, byte(0, mload(shr(250, mload(o)))))
                    if iszero(lt(o, end)) { break }
                }
            }
        }
    }

    /// @dev Returns if this string is a 7-bit ASCII string.
    /// (i.e. all characters codes are in [0..127])
    function is7BitASCII(string memory s) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            let mask := shl(7, div(not(0), 255))
            result := 1
            let n := mload(s)
            if n {
                let o := add(s, 0x20)
                let end := add(o, n)
                let last := mload(end)
                mstore(end, 0)
                for {} 1 {} {
                    if and(mask, mload(o)) {
                        result := 0
                        break
                    }
                    o := add(o, 0x20)
                    if iszero(lt(o, end)) { break }
                }
                mstore(end, last)
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   BYTE STRING OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // For performance and bytecode compactness, byte string operations are restricted
    // to 7-bit ASCII strings. All offsets are byte offsets, not UTF character offsets.
    // Usage of byte string operations on charsets with runes spanning two or more bytes
    // can lead to undefined behavior.

    /// @dev Returns `subject` all occurrences of `search` replaced with `replacement`.
    function replace(string memory subject, string memory search, string memory replacement)
        internal
        pure
        returns (string memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let subjectLength := mload(subject)
            let searchLength := mload(search)
            let replacementLength := mload(replacement)

            subject := add(subject, 0x20)
            search := add(search, 0x20)
            replacement := add(replacement, 0x20)
            result := add(mload(0x40), 0x20)

            let subjectEnd := add(subject, subjectLength)
            if iszero(gt(searchLength, subjectLength)) {
                let subjectSearchEnd := add(sub(subjectEnd, searchLength), 1)
                let h := 0
                if iszero(lt(searchLength, 0x20)) { h := keccak256(search, searchLength) }
                let m := shl(3, sub(0x20, and(searchLength, 0x1f)))
                let s := mload(search)
                for {} 1 {} {
                    let t := mload(subject)
                    // Whether the first `searchLength % 32` bytes of
                    // `subject` and `search` matches.
                    if iszero(shr(m, xor(t, s))) {
                        if h {
                            if iszero(eq(keccak256(subject, searchLength), h)) {
                                mstore(result, t)
                                result := add(result, 1)
                                subject := add(subject, 1)
                                if iszero(lt(subject, subjectSearchEnd)) { break }
                                continue
                            }
                        }
                        // Copy the `replacement` one word at a time.
                        for { let o := 0 } 1 {} {
                            mstore(add(result, o), mload(add(replacement, o)))
                            o := add(o, 0x20)
                            if iszero(lt(o, replacementLength)) { break }
                        }
                        result := add(result, replacementLength)
                        subject := add(subject, searchLength)
                        if searchLength {
                            if iszero(lt(subject, subjectSearchEnd)) { break }
                            continue
                        }
                    }
                    mstore(result, t)
                    result := add(result, 1)
                    subject := add(subject, 1)
                    if iszero(lt(subject, subjectSearchEnd)) { break }
                }
            }

            let resultRemainder := result
            result := add(mload(0x40), 0x20)
            let k := add(sub(resultRemainder, result), sub(subjectEnd, subject))
            // Copy the rest of the string one word at a time.
            for {} lt(subject, subjectEnd) {} {
                mstore(resultRemainder, mload(subject))
                resultRemainder := add(resultRemainder, 0x20)
                subject := add(subject, 0x20)
            }
            result := sub(result, 0x20)
            let last := add(add(result, 0x20), k) // Zeroize the slot after the string.
            mstore(last, 0)
            mstore(0x40, add(last, 0x20)) // Allocate the memory.
            mstore(result, k) // Store the length.
        }
    }

    /// @dev Returns the byte index of the first location of `search` in `subject`,
    /// searching from left to right, starting from `from`.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `search` is not found.
    function indexOf(string memory subject, string memory search, uint256 from)
        internal
        pure
        returns (uint256 result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            for { let subjectLength := mload(subject) } 1 {} {
                if iszero(mload(search)) {
                    if iszero(gt(from, subjectLength)) {
                        result := from
                        break
                    }
                    result := subjectLength
                    break
                }
                let searchLength := mload(search)
                let subjectStart := add(subject, 0x20)

                result := not(0) // Initialize to `NOT_FOUND`.

                subject := add(subjectStart, from)
                let end := add(sub(add(subjectStart, subjectLength), searchLength), 1)

                let m := shl(3, sub(0x20, and(searchLength, 0x1f)))
                let s := mload(add(search, 0x20))

                if iszero(and(lt(subject, end), lt(from, subjectLength))) { break }

                if iszero(lt(searchLength, 0x20)) {
                    for { let h := keccak256(add(search, 0x20), searchLength) } 1 {} {
                        if iszero(shr(m, xor(mload(subject), s))) {
                            if eq(keccak256(subject, searchLength), h) {
                                result := sub(subject, subjectStart)
                                break
                            }
                        }
                        subject := add(subject, 1)
                        if iszero(lt(subject, end)) { break }
                    }
                    break
                }
                for {} 1 {} {
                    if iszero(shr(m, xor(mload(subject), s))) {
                        result := sub(subject, subjectStart)
                        break
                    }
                    subject := add(subject, 1)
                    if iszero(lt(subject, end)) { break }
                }
                break
            }
        }
    }

    /// @dev Returns the byte index of the first location of `search` in `subject`,
    /// searching from left to right.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `search` is not found.
    function indexOf(string memory subject, string memory search) internal pure returns (uint256 result) {
        result = indexOf(subject, search, 0);
    }

    /// @dev Returns the byte index of the first location of `search` in `subject`,
    /// searching from right to left, starting from `from`.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `search` is not found.
    function lastIndexOf(string memory subject, string memory search, uint256 from)
        internal
        pure
        returns (uint256 result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            for {} 1 {} {
                result := not(0) // Initialize to `NOT_FOUND`.
                let searchLength := mload(search)
                if gt(searchLength, mload(subject)) { break }
                let w := result

                let fromMax := sub(mload(subject), searchLength)
                if iszero(gt(fromMax, from)) { from := fromMax }

                let end := add(add(subject, 0x20), w)
                subject := add(add(subject, 0x20), from)
                if iszero(gt(subject, end)) { break }
                // As this function is not too often used,
                // we shall simply use keccak256 for smaller bytecode size.
                for { let h := keccak256(add(search, 0x20), searchLength) } 1 {} {
                    if eq(keccak256(subject, searchLength), h) {
                        result := sub(subject, add(end, 1))
                        break
                    }
                    subject := add(subject, w) // `sub(subject, 1)`.
                    if iszero(gt(subject, end)) { break }
                }
                break
            }
        }
    }

    /// @dev Returns the byte index of the first location of `search` in `subject`,
    /// searching from right to left.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `search` is not found.
    function lastIndexOf(string memory subject, string memory search) internal pure returns (uint256 result) {
        result = lastIndexOf(subject, search, uint256(int256(-1)));
    }

    /// @dev Returns true if `search` is found in `subject`, false otherwise.
    function contains(string memory subject, string memory search) internal pure returns (bool) {
        return indexOf(subject, search) != NOT_FOUND;
    }

    /// @dev Returns whether `subject` starts with `search`.
    function startsWith(string memory subject, string memory search) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            let searchLength := mload(search)
            // Just using keccak256 directly is actually cheaper.
            // forgefmt: disable-next-item
            result := and(
                iszero(gt(searchLength, mload(subject))),
                eq(
                    keccak256(add(subject, 0x20), searchLength),
                    keccak256(add(search, 0x20), searchLength)
                )
            )
        }
    }

    /// @dev Returns whether `subject` ends with `search`.
    function endsWith(string memory subject, string memory search) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            let searchLength := mload(search)
            let subjectLength := mload(subject)
            // Whether `search` is not longer than `subject`.
            let withinRange := iszero(gt(searchLength, subjectLength))
            // Just using keccak256 directly is actually cheaper.
            // forgefmt: disable-next-item
            result := and(
                withinRange,
                eq(
                    keccak256(
                        // `subject + 0x20 + max(subjectLength - searchLength, 0)`.
                        add(add(subject, 0x20), mul(withinRange, sub(subjectLength, searchLength))),
                        searchLength
                    ),
                    keccak256(add(search, 0x20), searchLength)
                )
            )
        }
    }

    /// @dev Returns `subject` repeated `times`.
    function repeat(string memory subject, uint256 times) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            let subjectLength := mload(subject)
            if iszero(or(iszero(times), iszero(subjectLength))) {
                subject := add(subject, 0x20)
                result := mload(0x40)
                let output := add(result, 0x20)
                for {} 1 {} {
                    // Copy the `subject` one word at a time.
                    for { let o := 0 } 1 {} {
                        mstore(add(output, o), mload(add(subject, o)))
                        o := add(o, 0x20)
                        if iszero(lt(o, subjectLength)) { break }
                    }
                    output := add(output, subjectLength)
                    times := sub(times, 1)
                    if iszero(times) { break }
                }
                mstore(output, 0) // Zeroize the slot after the string.
                let resultLength := sub(output, add(result, 0x20))
                mstore(result, resultLength) // Store the length.
                // Allocate the memory.
                mstore(0x40, add(result, add(resultLength, 0x20)))
            }
        }
    }

    /// @dev Returns a copy of `subject` sliced from `start` to `end` (exclusive).
    /// `start` and `end` are byte offsets.
    function slice(string memory subject, uint256 start, uint256 end) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            let subjectLength := mload(subject)
            if iszero(gt(subjectLength, end)) { end := subjectLength }
            if iszero(gt(subjectLength, start)) { start := subjectLength }
            if lt(start, end) {
                result := mload(0x40)
                let resultLength := sub(end, start)
                mstore(result, resultLength)
                subject := add(subject, start)
                let w := not(0x1f)
                // Copy the `subject` one word at a time, backwards.
                for { let o := and(add(resultLength, 0x1f), w) } 1 {} {
                    mstore(add(result, o), mload(add(subject, o)))
                    o := add(o, w) // `sub(o, 0x20)`.
                    if iszero(o) { break }
                }
                // Zeroize the slot after the string.
                mstore(add(add(result, 0x20), resultLength), 0)
                // Allocate memory for the length and the bytes,
                // rounded up to a multiple of 32.
                mstore(0x40, add(result, and(add(resultLength, 0x3f), w)))
            }
        }
    }

    /// @dev Returns a copy of `subject` sliced from `start` to the end of the string.
    /// `start` is a byte offset.
    function slice(string memory subject, uint256 start) internal pure returns (string memory result) {
        result = slice(subject, start, uint256(int256(-1)));
    }

    /// @dev Returns all the indices of `search` in `subject`.
    /// The indices are byte offsets.
    function indicesOf(string memory subject, string memory search) internal pure returns (uint256[] memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            let subjectLength := mload(subject)
            let searchLength := mload(search)

            if iszero(gt(searchLength, subjectLength)) {
                subject := add(subject, 0x20)
                search := add(search, 0x20)
                result := add(mload(0x40), 0x20)

                let subjectStart := subject
                let subjectSearchEnd := add(sub(add(subject, subjectLength), searchLength), 1)
                let h := 0
                if iszero(lt(searchLength, 0x20)) { h := keccak256(search, searchLength) }
                let m := shl(3, sub(0x20, and(searchLength, 0x1f)))
                let s := mload(search)
                for {} 1 {} {
                    let t := mload(subject)
                    // Whether the first `searchLength % 32` bytes of
                    // `subject` and `search` matches.
                    if iszero(shr(m, xor(t, s))) {
                        if h {
                            if iszero(eq(keccak256(subject, searchLength), h)) {
                                subject := add(subject, 1)
                                if iszero(lt(subject, subjectSearchEnd)) { break }
                                continue
                            }
                        }
                        // Append to `result`.
                        mstore(result, sub(subject, subjectStart))
                        result := add(result, 0x20)
                        // Advance `subject` by `searchLength`.
                        subject := add(subject, searchLength)
                        if searchLength {
                            if iszero(lt(subject, subjectSearchEnd)) { break }
                            continue
                        }
                    }
                    subject := add(subject, 1)
                    if iszero(lt(subject, subjectSearchEnd)) { break }
                }
                let resultEnd := result
                // Assign `result` to the free memory pointer.
                result := mload(0x40)
                // Store the length of `result`.
                mstore(result, shr(5, sub(resultEnd, add(result, 0x20))))
                // Allocate memory for result.
                // We allocate one more word, so this array can be recycled for {split}.
                mstore(0x40, add(resultEnd, 0x20))
            }
        }
    }

    /// @dev Returns a arrays of strings based on the `delimiter` inside of the `subject` string.
    function split(string memory subject, string memory delimiter) internal pure returns (string[] memory result) {
        uint256[] memory indices = indicesOf(subject, delimiter);
        /// @solidity memory-safe-assembly
        assembly {
            let w := not(0x1f)
            let indexPtr := add(indices, 0x20)
            let indicesEnd := add(indexPtr, shl(5, add(mload(indices), 1)))
            mstore(add(indicesEnd, w), mload(subject))
            mstore(indices, add(mload(indices), 1))
            let prevIndex := 0
            for {} 1 {} {
                let index := mload(indexPtr)
                mstore(indexPtr, 0x60)
                if iszero(eq(index, prevIndex)) {
                    let element := mload(0x40)
                    let elementLength := sub(index, prevIndex)
                    mstore(element, elementLength)
                    // Copy the `subject` one word at a time, backwards.
                    for { let o := and(add(elementLength, 0x1f), w) } 1 {} {
                        mstore(add(element, o), mload(add(add(subject, prevIndex), o)))
                        o := add(o, w) // `sub(o, 0x20)`.
                        if iszero(o) { break }
                    }
                    // Zeroize the slot after the string.
                    mstore(add(add(element, 0x20), elementLength), 0)
                    // Allocate memory for the length and the bytes,
                    // rounded up to a multiple of 32.
                    mstore(0x40, add(element, and(add(elementLength, 0x3f), w)))
                    // Store the `element` into the array.
                    mstore(indexPtr, element)
                }
                prevIndex := add(index, mload(delimiter))
                indexPtr := add(indexPtr, 0x20)
                if iszero(lt(indexPtr, indicesEnd)) { break }
            }
            result := indices
            if iszero(mload(delimiter)) {
                result := add(indices, 0x20)
                mstore(result, sub(mload(indices), 2))
            }
        }
    }

    /// @dev Returns a concatenated string of `a` and `b`.
    /// Cheaper than `string.concat()` and does not de-align the free memory pointer.
    function concat(string memory a, string memory b) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            let w := not(0x1f)
            result := mload(0x40)
            let aLength := mload(a)
            // Copy `a` one word at a time, backwards.
            for { let o := and(add(aLength, 0x20), w) } 1 {} {
                mstore(add(result, o), mload(add(a, o)))
                o := add(o, w) // `sub(o, 0x20)`.
                if iszero(o) { break }
            }
            let bLength := mload(b)
            let output := add(result, aLength)
            // Copy `b` one word at a time, backwards.
            for { let o := and(add(bLength, 0x20), w) } 1 {} {
                mstore(add(output, o), mload(add(b, o)))
                o := add(o, w) // `sub(o, 0x20)`.
                if iszero(o) { break }
            }
            let totalLength := add(aLength, bLength)
            let last := add(add(result, 0x20), totalLength)
            // Zeroize the slot after the string.
            mstore(last, 0)
            // Stores the length.
            mstore(result, totalLength)
            // Allocate memory for the length and the bytes,
            // rounded up to a multiple of 32.
            mstore(0x40, and(add(last, 0x1f), w))
        }
    }

    /// @dev Returns a copy of the string in either lowercase or UPPERCASE.
    /// WARNING! This function is only compatible with 7-bit ASCII strings.
    function toCase(string memory subject, bool toUpper) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            let length := mload(subject)
            if length {
                result := add(mload(0x40), 0x20)
                subject := add(subject, 1)
                let flags := shl(add(70, shl(5, toUpper)), 0x3ffffff)
                let w := not(0)
                for { let o := length } 1 {} {
                    o := add(o, w)
                    let b := and(0xff, mload(add(subject, o)))
                    mstore8(add(result, o), xor(b, and(shr(b, flags), 0x20)))
                    if iszero(o) { break }
                }
                result := mload(0x40)
                mstore(result, length) // Store the length.
                let last := add(add(result, 0x20), length)
                mstore(last, 0) // Zeroize the slot after the string.
                mstore(0x40, add(last, 0x20)) // Allocate the memory.
            }
        }
    }

    /// @dev Returns a string from a small bytes32 string.
    /// `s` must be null-terminated, or behavior will be undefined.
    function fromSmallString(bytes32 s) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            let n := 0
            for {} byte(n, s) { n := add(n, 1) } {} // Scan for '\0'.
            mstore(result, n)
            let o := add(result, 0x20)
            mstore(o, s)
            mstore(add(o, n), 0)
            mstore(0x40, add(result, 0x40))
        }
    }

    /// @dev Returns the small string, with all bytes after the first null byte zeroized.
    function normalizeSmallString(bytes32 s) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            for {} byte(result, s) { result := add(result, 1) } {} // Scan for '\0'.
            mstore(0x00, s)
            mstore(result, 0x00)
            result := mload(0x00)
        }
    }

    /// @dev Returns the string as a normalized null-terminated small string.
    function toSmallString(string memory s) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(s)
            if iszero(lt(result, 33)) {
                mstore(0x00, 0xec92f9a3) // `TooBigForSmallString()`.
                revert(0x1c, 0x04)
            }
            result := shl(shl(3, sub(32, result)), mload(add(s, result)))
        }
    }

    /// @dev Returns a lowercased copy of the string.
    /// WARNING! This function is only compatible with 7-bit ASCII strings.
    function lower(string memory subject) internal pure returns (string memory result) {
        result = toCase(subject, false);
    }

    /// @dev Returns an UPPERCASED copy of the string.
    /// WARNING! This function is only compatible with 7-bit ASCII strings.
    function upper(string memory subject) internal pure returns (string memory result) {
        result = toCase(subject, true);
    }

    /// @dev Escapes the string to be used within HTML tags.
    function escapeHTML(string memory s) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            let end := add(s, mload(s))
            result := add(mload(0x40), 0x20)
            // Store the bytes of the packed offsets and strides into the scratch space.
            // `packed = (stride << 5) | offset`. Max offset is 20. Max stride is 6.
            mstore(0x1f, 0x900094)
            mstore(0x08, 0xc0000000a6ab)
            // Store "&quot;&amp;&#39;&lt;&gt;" into the scratch space.
            mstore(0x00, shl(64, 0x2671756f743b26616d703b262333393b266c743b2667743b))
            for {} iszero(eq(s, end)) {} {
                s := add(s, 1)
                let c := and(mload(s), 0xff)
                // Not in `["\"","'","&","<",">"]`.
                if iszero(and(shl(c, 1), 0x500000c400000000)) {
                    mstore8(result, c)
                    result := add(result, 1)
                    continue
                }
                let t := shr(248, mload(c))
                mstore(result, mload(and(t, 0x1f)))
                result := add(result, shr(5, t))
            }
            let last := result
            mstore(last, 0) // Zeroize the slot after the string.
            result := mload(0x40)
            mstore(result, sub(last, add(result, 0x20))) // Store the length.
            mstore(0x40, add(last, 0x20)) // Allocate the memory.
        }
    }

    /// @dev Escapes the string to be used within double-quotes in a JSON.
    /// If `addDoubleQuotes` is true, the result will be enclosed in double-quotes.
    function escapeJSON(string memory s, bool addDoubleQuotes) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            let end := add(s, mload(s))
            result := add(mload(0x40), 0x20)
            if addDoubleQuotes {
                mstore8(result, 34)
                result := add(1, result)
            }
            // Store "\\u0000" in scratch space.
            // Store "0123456789abcdef" in scratch space.
            // Also, store `{0x08:"b", 0x09:"t", 0x0a:"n", 0x0c:"f", 0x0d:"r"}`.
            // into the scratch space.
            mstore(0x15, 0x5c75303030303031323334353637383961626364656662746e006672)
            // Bitmask for detecting `["\"","\\"]`.
            let e := or(shl(0x22, 1), shl(0x5c, 1))
            for {} iszero(eq(s, end)) {} {
                s := add(s, 1)
                let c := and(mload(s), 0xff)
                if iszero(lt(c, 0x20)) {
                    if iszero(and(shl(c, 1), e)) {
                        // Not in `["\"","\\"]`.
                        mstore8(result, c)
                        result := add(result, 1)
                        continue
                    }
                    mstore8(result, 0x5c) // "\\".
                    mstore8(add(result, 1), c)
                    result := add(result, 2)
                    continue
                }
                if iszero(and(shl(c, 1), 0x3700)) {
                    // Not in `["\b","\t","\n","\f","\d"]`.
                    mstore8(0x1d, mload(shr(4, c))) // Hex value.
                    mstore8(0x1e, mload(and(c, 15))) // Hex value.
                    mstore(result, mload(0x19)) // "\\u00XX".
                    result := add(result, 6)
                    continue
                }
                mstore8(result, 0x5c) // "\\".
                mstore8(add(result, 1), mload(add(c, 8)))
                result := add(result, 2)
            }
            if addDoubleQuotes {
                mstore8(result, 34)
                result := add(1, result)
            }
            let last := result
            mstore(last, 0) // Zeroize the slot after the string.
            result := mload(0x40)
            mstore(result, sub(last, add(result, 0x20))) // Store the length.
            mstore(0x40, add(last, 0x20)) // Allocate the memory.
        }
    }

    /// @dev Escapes the string to be used within double-quotes in a JSON.
    function escapeJSON(string memory s) internal pure returns (string memory result) {
        result = escapeJSON(s, false);
    }

    /// @dev Returns whether `a` equals `b`.
    function eq(string memory a, string memory b) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := eq(keccak256(add(a, 0x20), mload(a)), keccak256(add(b, 0x20), mload(b)))
        }
    }

    /// @dev Returns whether `a` equals `b`, where `b` is a null-terminated small string.
    function eqs(string memory a, bytes32 b) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            // These should be evaluated on compile time, as far as possible.
            let m := not(shl(7, div(not(iszero(b)), 255))) // `0x7f7f ...`.
            let x := not(or(m, or(b, add(m, and(b, m)))))
            let r := shl(7, iszero(iszero(shr(128, x))))
            r := or(r, shl(6, iszero(iszero(shr(64, shr(r, x))))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // forgefmt: disable-next-item
            result := gt(eq(mload(a), add(iszero(x), xor(31, shr(3, r)))),
                xor(shr(add(8, r), b), shr(add(8, r), mload(add(a, 0x20)))))
        }
    }

    /// @dev Packs a single string with its length into a single word.
    /// Returns `bytes32(0)` if the length is zero or greater than 31.
    function packOne(string memory a) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            // We don't need to zero right pad the string,
            // since this is our own custom non-standard packing scheme.
            result :=
                mul(
                    // Load the length and the bytes.
                    mload(add(a, 0x1f)),
                    // `length != 0 && length < 32`. Abuses underflow.
                    // Assumes that the length is valid and within the block gas limit.
                    lt(sub(mload(a), 1), 0x1f)
                )
        }
    }

    /// @dev Unpacks a string packed using {packOne}.
    /// Returns the empty string if `packed` is `bytes32(0)`.
    /// If `packed` is not an output of {packOne}, the output behavior is undefined.
    function unpackOne(bytes32 packed) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            // Grab the free memory pointer.
            result := mload(0x40)
            // Allocate 2 words (1 for the length, 1 for the bytes).
            mstore(0x40, add(result, 0x40))
            // Zeroize the length slot.
            mstore(result, 0)
            // Store the length and bytes.
            mstore(add(result, 0x1f), packed)
            // Right pad with zeroes.
            mstore(add(add(result, 0x20), mload(result)), 0)
        }
    }

    /// @dev Packs two strings with their lengths into a single word.
    /// Returns `bytes32(0)` if combined length is zero or greater than 30.
    function packTwo(string memory a, string memory b) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            let aLength := mload(a)
            // We don't need to zero right pad the strings,
            // since this is our own custom non-standard packing scheme.
            result :=
                mul(
                    // Load the length and the bytes of `a` and `b`.
                    or(shl(shl(3, sub(0x1f, aLength)), mload(add(a, aLength))), mload(sub(add(b, 0x1e), aLength))),
                    // `totalLength != 0 && totalLength < 31`. Abuses underflow.
                    // Assumes that the lengths are valid and within the block gas limit.
                    lt(sub(add(aLength, mload(b)), 1), 0x1e)
                )
        }
    }

    /// @dev Unpacks strings packed using {packTwo}.
    /// Returns the empty strings if `packed` is `bytes32(0)`.
    /// If `packed` is not an output of {packTwo}, the output behavior is undefined.
    function unpackTwo(bytes32 packed) internal pure returns (string memory resultA, string memory resultB) {
        /// @solidity memory-safe-assembly
        assembly {
            // Grab the free memory pointer.
            resultA := mload(0x40)
            resultB := add(resultA, 0x40)
            // Allocate 2 words for each string (1 for the length, 1 for the byte). Total 4 words.
            mstore(0x40, add(resultB, 0x40))
            // Zeroize the length slots.
            mstore(resultA, 0)
            mstore(resultB, 0)
            // Store the lengths and bytes.
            mstore(add(resultA, 0x1f), packed)
            mstore(add(resultB, 0x1f), mload(add(add(resultA, 0x20), mload(resultA))))
            // Right pad with zeroes.
            mstore(add(add(resultA, 0x20), mload(resultA)), 0)
            mstore(add(add(resultB, 0x20), mload(resultB)), 0)
        }
    }

    /// @dev Directly returns `a` without copying.
    function directReturn(string memory a) internal pure {
        assembly {
            // Assumes that the string does not start from the scratch space.
            let retStart := sub(a, 0x20)
            let retSize := add(mload(a), 0x40)
            // Right pad with zeroes. Just in case the string is produced
            // by a method that doesn't zero right pad.
            mstore(add(retStart, retSize), 0)
            // Store the return offset.
            mstore(retStart, 0x20)
            // End the transaction, returning the string.
            return(retStart, retSize)
        }
    }
}

/// @notice Library for parsing JSONs.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/JSONParserLib.sol)
library JSONParserLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The input is invalid.
    error ParsingFailed();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // There are 6 types of variables in JSON (excluding undefined).

    /// @dev For denoting that an item has not been initialized.
    /// A item returned from `parse` will never be of an undefined type.
    /// Parsing a invalid JSON string will simply revert.
    uint8 internal constant TYPE_UNDEFINED = 0;

    /// @dev Type representing an array (e.g. `[1,2,3]`).
    uint8 internal constant TYPE_ARRAY = 1;

    /// @dev Type representing an object (e.g. `{"a":"A","b":"B"}`).
    uint8 internal constant TYPE_OBJECT = 2;

    /// @dev Type representing a number (e.g. `-1.23e+21`).
    uint8 internal constant TYPE_NUMBER = 3;

    /// @dev Type representing a string (e.g. `"hello"`).
    uint8 internal constant TYPE_STRING = 4;

    /// @dev Type representing a boolean (i.e. `true` or `false`).
    uint8 internal constant TYPE_BOOLEAN = 5;

    /// @dev Type representing null (i.e. `null`).
    uint8 internal constant TYPE_NULL = 6;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STRUCTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev A pointer to a parsed JSON node.
    struct Item {
        // Do NOT modify the `_data` directly.
        uint256 _data;
    }

    // Private constants for packing `_data`.

    uint256 private constant _BITPOS_STRING = 32 * 7 - 8;
    uint256 private constant _BITPOS_KEY_LENGTH = 32 * 6 - 8;
    uint256 private constant _BITPOS_KEY = 32 * 5 - 8;
    uint256 private constant _BITPOS_VALUE_LENGTH = 32 * 4 - 8;
    uint256 private constant _BITPOS_VALUE = 32 * 3 - 8;
    uint256 private constant _BITPOS_CHILD = 32 * 2 - 8;
    uint256 private constant _BITPOS_SIBLING_OR_PARENT = 32 * 1 - 8;
    uint256 private constant _BITMASK_POINTER = 0xffffffff;
    uint256 private constant _BITMASK_TYPE = 7;
    uint256 private constant _KEY_INITED = 1 << 3;
    uint256 private constant _VALUE_INITED = 1 << 4;
    uint256 private constant _CHILDREN_INITED = 1 << 5;
    uint256 private constant _PARENT_IS_ARRAY = 1 << 6;
    uint256 private constant _PARENT_IS_OBJECT = 1 << 7;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   JSON PARSING OPERATION                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Parses the JSON string `s`, and returns the root.
    /// Reverts if `s` is not a valid JSON as specified in RFC 8259.
    /// Object items WILL simply contain all their children, inclusive of repeated keys,
    /// in the same order which they appear in the JSON string.
    ///
    /// Note: For efficiency, this function WILL NOT make a copy of `s`.
    /// The parsed tree WILL contain offsets to `s`.
    /// Do NOT pass in a string that WILL be modified later on.
    function parse(string memory s) internal pure returns (Item memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x40, result) // We will use our own allocation instead.
        }
        bytes32 r = _query(_toInput(s), 255);
        /// @solidity memory-safe-assembly
        assembly {
            result := r
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                    JSON ITEM OPERATIONS                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // Note:
    // - An item is a node in the JSON tree.
    // - The value of a string item WILL be double-quoted, JSON encoded.
    // - We make a distinction between `index` and `key`.
    //   - Items in arrays are located by `index` (uint256).
    //   - Items in objects are located by `key` (string).
    // - Keys are always strings, double-quoted, JSON encoded.
    //
    // These design choices are made to balance between efficiency and ease-of-use.

    /// @dev Returns the string value of the item.
    /// This is its exact string representation in the original JSON string.
    /// The returned string WILL have leading and trailing whitespace trimmed.
    /// All inner whitespace WILL be preserved, exactly as it is in the original JSON string.
    /// If the item's type is string, the returned string WILL be double-quoted, JSON encoded.
    ///
    /// Note: This function lazily instantiates and caches the returned string.
    /// Do NOT modify the returned string.
    function value(Item memory item) internal pure returns (string memory result) {
        bytes32 r = _query(_toInput(item), 0);
        /// @solidity memory-safe-assembly
        assembly {
            result := r
        }
    }

    /// @dev Returns the index of the item in the array.
    /// It the item's parent is not an array, returns 0.
    function index(Item memory item) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            if and(mload(item), _PARENT_IS_ARRAY) { result := and(_BITMASK_POINTER, shr(_BITPOS_KEY, mload(item))) }
        }
    }

    /// @dev Returns the key of the item in the object.
    /// It the item's parent is not an object, returns an empty string.
    /// The returned string WILL be double-quoted, JSON encoded.
    ///
    /// Note: This function lazily instantiates and caches the returned string.
    /// Do NOT modify the returned string.
    function key(Item memory item) internal pure returns (string memory result) {
        if (item._data & _PARENT_IS_OBJECT != 0) {
            bytes32 r = _query(_toInput(item), 1);
            /// @solidity memory-safe-assembly
            assembly {
                result := r
            }
        }
    }

    /// @dev Returns the key of the item in the object.
    /// It the item is neither an array nor object, returns an empty array.
    ///
    /// Note: This function lazily instantiates and caches the returned array.
    /// Do NOT modify the returned array.
    function children(Item memory item) internal pure returns (Item[] memory result) {
        bytes32 r = _query(_toInput(item), 3);
        /// @solidity memory-safe-assembly
        assembly {
            result := r
        }
    }

    /// @dev Returns the number of children.
    /// It the item is neither an array nor object, returns zero.
    function size(Item memory item) internal pure returns (uint256 result) {
        bytes32 r = _query(_toInput(item), 3);
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(r)
        }
    }

    /// @dev Returns the item at index `i` for (array).
    /// If `item` is not an array, the result's type WILL be undefined.
    /// If there is no item with the index, the result's type WILL be undefined.
    function at(Item memory item, uint256 i) internal pure returns (Item memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x40, result) // Free the default allocation. We'll allocate manually.
        }
        bytes32 r = _query(_toInput(item), 3);
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(add(add(r, 0x20), shl(5, i)))
            if iszero(and(lt(i, mload(r)), eq(and(mload(item), _BITMASK_TYPE), TYPE_ARRAY))) { result := 0x60 } // Reset to the zero pointer.
        }
    }

    /// @dev Returns the item at key `k` for (object).
    /// If `item` is not an object, the result's type WILL be undefined.
    /// The key MUST be double-quoted, JSON encoded. This is for efficiency reasons.
    /// - Correct : `item.at('"k"')`.
    /// - Wrong   : `item.at("k")`.
    /// For duplicated keys, the last item with the key WILL be returned.
    /// If there is no item with the key, the result's type WILL be undefined.
    function at(Item memory item, string memory k) internal pure returns (Item memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x40, result) // Free the default allocation. We'll allocate manually.
            result := 0x60 // Initialize to the zero pointer.
        }
        if (isObject(item)) {
            bytes32 kHash = keccak256(bytes(k));
            Item[] memory r = children(item);
            // We'll just do a linear search. The alternatives are very bloated.
            for (uint256 i = r.length << 5; i != 0;) {
                /// @solidity memory-safe-assembly
                assembly {
                    item := mload(add(r, i))
                    i := sub(i, 0x20)
                }
                if (keccak256(bytes(key(item))) != kHash) {
                    continue;
                }
                result = item;
                break;
            }
        }
    }

    /// @dev Returns the item's type.
    function getType(Item memory item) internal pure returns (uint8 result) {
        result = uint8(item._data & _BITMASK_TYPE);
    }

    /// Note: All types are mutually exclusive.

    /// @dev Returns whether the item is of type undefined.
    function isUndefined(Item memory item) internal pure returns (bool result) {
        result = item._data & _BITMASK_TYPE == TYPE_UNDEFINED;
    }

    /// @dev Returns whether the item is of type array.
    function isArray(Item memory item) internal pure returns (bool result) {
        result = item._data & _BITMASK_TYPE == TYPE_ARRAY;
    }

    /// @dev Returns whether the item is of type object.
    function isObject(Item memory item) internal pure returns (bool result) {
        result = item._data & _BITMASK_TYPE == TYPE_OBJECT;
    }

    /// @dev Returns whether the item is of type number.
    function isNumber(Item memory item) internal pure returns (bool result) {
        result = item._data & _BITMASK_TYPE == TYPE_NUMBER;
    }

    /// @dev Returns whether the item is of type string.
    function isString(Item memory item) internal pure returns (bool result) {
        result = item._data & _BITMASK_TYPE == TYPE_STRING;
    }

    /// @dev Returns whether the item is of type boolean.
    function isBoolean(Item memory item) internal pure returns (bool result) {
        result = item._data & _BITMASK_TYPE == TYPE_BOOLEAN;
    }

    /// @dev Returns whether the item is of type null.
    function isNull(Item memory item) internal pure returns (bool result) {
        result = item._data & _BITMASK_TYPE == TYPE_NULL;
    }

    /// @dev Returns the item's parent.
    /// If the item does not have a parent, the result's type will be undefined.
    function parent(Item memory item) internal pure returns (Item memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x40, result) // Free the default allocation. We've already allocated.
            result := and(shr(_BITPOS_SIBLING_OR_PARENT, mload(item)), _BITMASK_POINTER)
            if iszero(result) { result := 0x60 } // Reset to the zero pointer.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     UTILITY FUNCTIONS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Parses an unsigned integer from a string (in decimal, i.e. base 10).
    /// Reverts if `s` is not a valid uint256 string matching the RegEx `^[0-9]+$`,
    /// or if the parsed number is too big for a uint256.
    function parseUint(string memory s) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            let n := mload(s)
            let preMulOverflowThres := div(not(0), 10)
            for { let i := 0 } 1 {} {
                i := add(i, 1)
                let digit := sub(and(mload(add(s, i)), 0xff), 48)
                let mulOverflowed := gt(result, preMulOverflowThres)
                let product := mul(10, result)
                result := add(product, digit)
                n := mul(n, iszero(or(or(mulOverflowed, lt(result, product)), gt(digit, 9))))
                if iszero(lt(i, n)) { break }
            }
            if iszero(n) {
                mstore(0x00, 0x10182796) // `ParsingFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Parses a signed integer from a string (in decimal, i.e. base 10).
    /// Reverts if `s` is not a valid int256 string matching the RegEx `^[+-]?[0-9]+$`,
    /// or if the parsed number is too big for a int256.
    function parseInt(string memory s) internal pure returns (int256 result) {
        uint256 n = bytes(s).length;
        uint256 sign;
        uint256 isNegative;
        /// @solidity memory-safe-assembly
        assembly {
            if n {
                let c := and(mload(add(s, 1)), 0xff)
                isNegative := eq(c, 45)
                if or(eq(c, 43), isNegative) {
                    sign := c
                    s := add(s, 1)
                    mstore(s, sub(n, 1))
                }
                if iszero(or(sign, lt(sub(c, 48), 10))) { s := 0x60 }
            }
        }
        uint256 x = parseUint(s);
        /// @solidity memory-safe-assembly
        assembly {
            if shr(255, x) {
                mstore(0x00, 0x10182796) // `ParsingFailed()`.
                revert(0x1c, 0x04)
            }
            if sign {
                mstore(s, sign)
                s := sub(s, 1)
                mstore(s, n)
            }
            result := xor(x, mul(xor(x, add(not(x), 1)), isNegative))
        }
    }

    /// @dev Parses an unsigned integer from a string (in hexadecimal, i.e. base 16).
    /// Reverts if `s` is not a valid uint256 hex string matching the RegEx
    /// `^(0[xX])?[0-9a-fA-F]+$`, or if the parsed number is too big for a uint256.
    function parseUintFromHex(string memory s) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            let n := mload(s)
            // Skip two if starts with '0x' or '0X'.
            let i := shl(1, and(eq(0x3078, or(shr(240, mload(add(s, 0x20))), 0x20)), gt(n, 1)))
            for {} 1 {} {
                i := add(i, 1)
                let c :=
                    byte(
                        and(0x1f, shr(and(mload(add(s, i)), 0xff), 0x3e4088843e41bac000000000000)),
                        0x3010a071000000b0104040208000c05090d060e0f
                    )
                n := mul(n, iszero(or(iszero(c), shr(252, result))))
                result := add(shl(4, result), sub(c, 1))
                if iszero(lt(i, n)) { break }
            }
            if iszero(n) {
                mstore(0x00, 0x10182796) // `ParsingFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Decodes a JSON encoded string.
    /// The string MUST be double-quoted, JSON encoded.
    /// Reverts if the string is invalid.
    /// As you can see, it's pretty complex for a deceptively simple looking task.
    function decodeString(string memory s) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            function fail() {
                mstore(0x00, 0x10182796) // `ParsingFailed()`.
                revert(0x1c, 0x04)
            }

            function decodeUnicodeEscapeSequence(pIn_, end_) -> _unicode, _pOut {
                _pOut := add(pIn_, 4)
                let b_ := iszero(gt(_pOut, end_))
                let t_ := mload(pIn_) // Load the whole word.
                for { let i_ := 0 } iszero(eq(i_, 4)) { i_ := add(i_, 1) } {
                    let c_ := sub(byte(i_, t_), 48)
                    if iszero(and(shr(c_, 0x7e0000007e03ff), b_)) { fail() } // Not hexadecimal.
                    c_ := sub(c_, add(mul(gt(c_, 16), 7), shl(5, gt(c_, 48))))
                    _unicode := add(shl(4, _unicode), c_)
                }
            }

            function decodeUnicodeCodePoint(pIn_, end_) -> _unicode, _pOut {
                _unicode, _pOut := decodeUnicodeEscapeSequence(pIn_, end_)
                if iszero(or(lt(_unicode, 0xd800), gt(_unicode, 0xdbff))) {
                    let t_ := mload(_pOut) // Load the whole word.
                    end_ := mul(end_, eq(shr(240, t_), 0x5c75)) // Fail if not starting with '\\u'.
                    t_, _pOut := decodeUnicodeEscapeSequence(add(_pOut, 2), end_)
                    _unicode := add(0x10000, add(shl(10, and(0x3ff, _unicode)), and(0x3ff, t_)))
                }
            }

            function appendCodePointAsUTF8(pIn_, c_) -> _pOut {
                if iszero(gt(c_, 0x7f)) {
                    mstore8(pIn_, c_)
                    _pOut := add(pIn_, 1)
                    leave
                }
                mstore8(0x1f, c_)
                mstore8(0x1e, shr(6, c_))
                if iszero(gt(c_, 0x7ff)) {
                    mstore(pIn_, shl(240, or(0xc080, and(0x1f3f, mload(0x00)))))
                    _pOut := add(pIn_, 2)
                    leave
                }
                mstore8(0x1d, shr(12, c_))
                if iszero(gt(c_, 0xffff)) {
                    mstore(pIn_, shl(232, or(0xe08080, and(0x0f3f3f, mload(0x00)))))
                    _pOut := add(pIn_, 3)
                    leave
                }
                mstore8(0x1c, shr(18, c_))
                mstore(pIn_, shl(224, or(0xf0808080, and(0x073f3f3f, mload(0x00)))))
                _pOut := add(pIn_, shl(2, lt(c_, 0x110000)))
            }

            function chr(p_) -> _c {
                _c := byte(0, mload(p_))
            }

            let n := mload(s)
            let end := add(add(s, n), 0x1f)
            if iszero(and(gt(n, 1), eq(0x2222, or(and(0xff00, mload(add(s, 2))), chr(end))))) { fail() } // Fail if not double-quoted.

            let out := add(mload(0x40), 0x20)
            for { let curr := add(s, 0x21) } iszero(eq(curr, end)) {} {
                let c := chr(curr)
                curr := add(curr, 1)
                // Not '\\'.
                if iszero(eq(c, 92)) {
                    // Not '"'.
                    if iszero(eq(c, 34)) {
                        mstore8(out, c)
                        out := add(out, 1)
                        continue
                    }
                    curr := end
                }
                if iszero(eq(curr, end)) {
                    let escape := chr(curr)
                    curr := add(curr, 1)
                    // '"', '/', '\\'.
                    if and(shr(escape, 0x100000000000800400000000), 1) {
                        mstore8(out, escape)
                        out := add(out, 1)
                        continue
                    }
                    // 'u'.
                    if eq(escape, 117) {
                        escape, curr := decodeUnicodeCodePoint(curr, end)
                        out := appendCodePointAsUTF8(out, escape)
                        continue
                    }
                    // `{'b':'\b', 'f':'\f', 'n':'\n', 'r':'\r', 't':'\t'}`.
                    escape := byte(sub(escape, 85), 0x080000000c000000000000000a0000000d0009)
                    if escape {
                        mstore8(out, escape)
                        out := add(out, 1)
                        continue
                    }
                }
                fail()
                break
            }
            mstore(out, 0) // Zeroize the last slot.
            result := mload(0x40)
            mstore(result, sub(out, add(result, 0x20))) // Store the length.
            mstore(0x40, add(out, 0x20)) // Allocate the memory.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      PRIVATE HELPERS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Performs a query on the input with the given mode.
    function _query(bytes32 input, uint256 mode) private pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            function fail() {
                mstore(0x00, 0x10182796) // `ParsingFailed()`.
                revert(0x1c, 0x04)
            }

            function chr(p_) -> _c {
                _c := byte(0, mload(p_))
            }

            function skipWhitespace(pIn_, end_) -> _pOut {
                for { _pOut := pIn_ } 1 { _pOut := add(_pOut, 1) } {
                    if iszero(and(shr(chr(_pOut), 0x100002600), 1)) { leave } // Not in ' \n\r\t'.
                }
            }

            function setP(packed_, bitpos_, p_) -> _packed {
                // Perform an out-of-gas revert if `p_` exceeds `_BITMASK_POINTER`.
                returndatacopy(returndatasize(), returndatasize(), gt(p_, _BITMASK_POINTER))
                _packed := or(and(not(shl(bitpos_, _BITMASK_POINTER)), packed_), shl(bitpos_, p_))
            }

            function getP(packed_, bitpos_) -> _p {
                _p := and(_BITMASK_POINTER, shr(bitpos_, packed_))
            }

            function mallocItem(s_, packed_, pStart_, pCurr_, type_) -> _item {
                _item := mload(0x40)
                // forgefmt: disable-next-item
                packed_ := setP(setP(packed_, _BITPOS_VALUE, sub(pStart_, add(s_, 0x20))),
                    _BITPOS_VALUE_LENGTH, sub(pCurr_, pStart_))
                mstore(_item, or(packed_, type_))
                mstore(0x40, add(_item, 0x20)) // Allocate memory.
            }

            function parseValue(s_, sibling_, pIn_, end_) -> _item, _pOut {
                let packed_ := setP(mload(0x00), _BITPOS_SIBLING_OR_PARENT, sibling_)
                _pOut := skipWhitespace(pIn_, end_)
                if iszero(lt(_pOut, end_)) { leave }
                for { let c_ := chr(_pOut) } 1 {} {
                    // If starts with '"'.
                    if eq(c_, 34) {
                        let pStart_ := _pOut
                        _pOut := parseStringSub(s_, packed_, _pOut, end_)
                        _item := mallocItem(s_, packed_, pStart_, _pOut, TYPE_STRING)
                        break
                    }
                    // If starts with '['.
                    if eq(c_, 91) {
                        _item, _pOut := parseArray(s_, packed_, _pOut, end_)
                        break
                    }
                    // If starts with '{'.
                    if eq(c_, 123) {
                        _item, _pOut := parseObject(s_, packed_, _pOut, end_)
                        break
                    }
                    // If starts with any in '0123456789-'.
                    if and(shr(c_, shl(45, 0x1ff9)), 1) {
                        _item, _pOut := parseNumber(s_, packed_, _pOut, end_)
                        break
                    }
                    if iszero(gt(add(_pOut, 4), end_)) {
                        let pStart_ := _pOut
                        let w_ := shr(224, mload(_pOut))
                        // 'true' in hex format.
                        if eq(w_, 0x74727565) {
                            _pOut := add(_pOut, 4)
                            _item := mallocItem(s_, packed_, pStart_, _pOut, TYPE_BOOLEAN)
                            break
                        }
                        // 'null' in hex format.
                        if eq(w_, 0x6e756c6c) {
                            _pOut := add(_pOut, 4)
                            _item := mallocItem(s_, packed_, pStart_, _pOut, TYPE_NULL)
                            break
                        }
                    }
                    if iszero(gt(add(_pOut, 5), end_)) {
                        let pStart_ := _pOut
                        let w_ := shr(216, mload(_pOut))
                        // 'false' in hex format.
                        if eq(w_, 0x66616c7365) {
                            _pOut := add(_pOut, 5)
                            _item := mallocItem(s_, packed_, pStart_, _pOut, TYPE_BOOLEAN)
                            break
                        }
                    }
                    fail()
                    break
                }
                _pOut := skipWhitespace(_pOut, end_)
            }

            function parseArray(s_, packed_, pIn_, end_) -> _item, _pOut {
                let j_ := 0
                for { _pOut := add(pIn_, 1) } 1 { _pOut := add(_pOut, 1) } {
                    if iszero(lt(_pOut, end_)) { fail() }
                    if iszero(_item) {
                        _pOut := skipWhitespace(_pOut, end_)
                        if eq(chr(_pOut), 93) { break } // ']'.
                    }
                    _item, _pOut := parseValue(s_, _item, _pOut, end_)
                    if _item {
                        // forgefmt: disable-next-item
                        mstore(_item, setP(or(_PARENT_IS_ARRAY, mload(_item)),
                            _BITPOS_KEY, j_))
                        j_ := add(j_, 1)
                        let c_ := chr(_pOut)
                        if eq(c_, 93) { break } // ']'.
                        if eq(c_, 44) { continue } // ','.
                    }
                    _pOut := end_
                }
                _pOut := add(_pOut, 1)
                packed_ := setP(packed_, _BITPOS_CHILD, _item)
                _item := mallocItem(s_, packed_, pIn_, _pOut, TYPE_ARRAY)
            }

            function parseObject(s_, packed_, pIn_, end_) -> _item, _pOut {
                for { _pOut := add(pIn_, 1) } 1 { _pOut := add(_pOut, 1) } {
                    if iszero(lt(_pOut, end_)) { fail() }
                    if iszero(_item) {
                        _pOut := skipWhitespace(_pOut, end_)
                        if eq(chr(_pOut), 125) { break } // '}'.
                    }
                    _pOut := skipWhitespace(_pOut, end_)
                    let pKeyStart_ := _pOut
                    let pKeyEnd_ := parseStringSub(s_, _item, _pOut, end_)
                    _pOut := skipWhitespace(pKeyEnd_, end_)
                    // If ':'.
                    if eq(chr(_pOut), 58) {
                        _item, _pOut := parseValue(s_, _item, add(_pOut, 1), end_)
                        if _item {
                            // forgefmt: disable-next-item
                            mstore(_item, setP(setP(or(_PARENT_IS_OBJECT, mload(_item)),
                                _BITPOS_KEY_LENGTH, sub(pKeyEnd_, pKeyStart_)),
                                    _BITPOS_KEY, sub(pKeyStart_, add(s_, 0x20))))
                            let c_ := chr(_pOut)
                            if eq(c_, 125) { break } // '}'.
                            if eq(c_, 44) { continue } // ','.
                        }
                    }
                    _pOut := end_
                }
                _pOut := add(_pOut, 1)
                packed_ := setP(packed_, _BITPOS_CHILD, _item)
                _item := mallocItem(s_, packed_, pIn_, _pOut, TYPE_OBJECT)
            }

            function checkStringU(p_, o_) {
                // If not in '0123456789abcdefABCDEF', revert.
                if iszero(and(shr(sub(chr(add(p_, o_)), 48), 0x7e0000007e03ff), 1)) { fail() }
                if iszero(eq(o_, 5)) { checkStringU(p_, add(o_, 1)) }
            }

            function parseStringSub(s_, packed_, pIn_, end_) -> _pOut {
                if iszero(lt(pIn_, end_)) { fail() }
                for { _pOut := add(pIn_, 1) } 1 {} {
                    let c_ := chr(_pOut)
                    if eq(c_, 34) { break } // '"'.
                    // Not '\'.
                    if iszero(eq(c_, 92)) {
                        _pOut := add(_pOut, 1)
                        continue
                    }
                    c_ := chr(add(_pOut, 1))
                    // '"', '\', '//', 'b', 'f', 'n', 'r', 't'.
                    if and(shr(sub(c_, 34), 0x510110400000000002001), 1) {
                        _pOut := add(_pOut, 2)
                        continue
                    }
                    // 'u'.
                    if eq(c_, 117) {
                        checkStringU(_pOut, 2)
                        _pOut := add(_pOut, 6)
                        continue
                    }
                    _pOut := end_
                    break
                }
                if iszero(lt(_pOut, end_)) { fail() }
                _pOut := add(_pOut, 1)
            }

            function skip0To9s(pIn_, end_, atLeastOne_) -> _pOut {
                for { _pOut := pIn_ } 1 { _pOut := add(_pOut, 1) } { if iszero(lt(sub(chr(_pOut), 48), 10)) { break } } // Not '0'..'9'.

                if and(atLeastOne_, eq(pIn_, _pOut)) { fail() }
            }

            function parseNumber(s_, packed_, pIn_, end_) -> _item, _pOut {
                _pOut := pIn_
                if eq(chr(_pOut), 45) { _pOut := add(_pOut, 1) } // '-'.
                if iszero(lt(sub(chr(_pOut), 48), 10)) { fail() } // Not '0'..'9'.
                let c_ := chr(_pOut)
                _pOut := add(_pOut, 1)
                if iszero(eq(c_, 48)) { _pOut := skip0To9s(_pOut, end_, 0) } // Not '0'.
                if eq(chr(_pOut), 46) { _pOut := skip0To9s(add(_pOut, 1), end_, 1) } // '.'.
                let t_ := mload(_pOut)
                // 'E', 'e'.
                if eq(or(0x20, byte(0, t_)), 101) {
                    // forgefmt: disable-next-item
                    _pOut := skip0To9s(add(byte(sub(byte(1, t_), 14), 0x010001), // '+', '-'.
                        add(_pOut, 1)), end_, 1)
                }
                _item := mallocItem(s_, packed_, pIn_, _pOut, TYPE_NUMBER)
            }

            function copyStr(s_, offset_, len_) -> _sCopy {
                _sCopy := mload(0x40)
                s_ := add(s_, offset_)
                let w_ := not(0x1f)
                for { let i_ := and(add(len_, 0x1f), w_) } 1 {} {
                    mstore(add(_sCopy, i_), mload(add(s_, i_)))
                    i_ := add(i_, w_) // `sub(i_, 0x20)`.
                    if iszero(i_) { break }
                }
                mstore(_sCopy, len_) // Copy the length.
                mstore(add(add(_sCopy, 0x20), len_), 0) // Zeroize the last slot.
                mstore(0x40, add(add(_sCopy, 0x40), len_)) // Allocate memory.
            }

            function value(item_) -> _value {
                let packed_ := mload(item_)
                _value := getP(packed_, _BITPOS_VALUE) // The offset in the string.
                if iszero(and(_VALUE_INITED, packed_)) {
                    let s_ := getP(packed_, _BITPOS_STRING)
                    _value := copyStr(s_, _value, getP(packed_, _BITPOS_VALUE_LENGTH))
                    packed_ := setP(packed_, _BITPOS_VALUE, _value)
                    mstore(s_, or(_VALUE_INITED, packed_))
                }
            }

            function children(item_) -> _arr {
                _arr := 0x60 // Initialize to the zero pointer.
                let packed_ := mload(item_)
                for {} iszero(gt(and(_BITMASK_TYPE, packed_), TYPE_OBJECT)) {} {
                    if or(iszero(packed_), iszero(item_)) { break }
                    if and(packed_, _CHILDREN_INITED) {
                        _arr := getP(packed_, _BITPOS_CHILD)
                        break
                    }
                    _arr := mload(0x40)
                    let o_ := add(_arr, 0x20)
                    for { let h_ := getP(packed_, _BITPOS_CHILD) } h_ {} {
                        mstore(o_, h_)
                        let q_ := mload(h_)
                        let y_ := getP(q_, _BITPOS_SIBLING_OR_PARENT)
                        mstore(h_, setP(q_, _BITPOS_SIBLING_OR_PARENT, item_))
                        h_ := y_
                        o_ := add(o_, 0x20)
                    }
                    let w_ := not(0x1f)
                    let n_ := add(w_, sub(o_, _arr))
                    mstore(_arr, shr(5, n_))
                    mstore(0x40, o_) // Allocate memory.
                    packed_ := setP(packed_, _BITPOS_CHILD, _arr)
                    mstore(item_, or(_CHILDREN_INITED, packed_))
                    // Reverse the array.
                    if iszero(lt(n_, 0x40)) {
                        let lo_ := add(_arr, 0x20)
                        let hi_ := add(_arr, n_)
                        for {} 1 {} {
                            let temp_ := mload(lo_)
                            mstore(lo_, mload(hi_))
                            mstore(hi_, temp_)
                            hi_ := add(hi_, w_)
                            lo_ := add(lo_, 0x20)
                            if iszero(lt(lo_, hi_)) { break }
                        }
                    }
                    break
                }
            }

            function getStr(item_, bitpos_, bitposLength_, bitmaskInited_) -> _result {
                _result := 0x60 // Initialize to the zero pointer.
                let packed_ := mload(item_)
                if or(iszero(item_), iszero(packed_)) { leave }
                _result := getP(packed_, bitpos_)
                if iszero(and(bitmaskInited_, packed_)) {
                    let s_ := getP(packed_, _BITPOS_STRING)
                    _result := copyStr(s_, _result, getP(packed_, bitposLength_))
                    mstore(item_, or(bitmaskInited_, setP(packed_, bitpos_, _result)))
                }
            }

            switch mode
            // Get value.
            case 0 { result := getStr(input, _BITPOS_VALUE, _BITPOS_VALUE_LENGTH, _VALUE_INITED) }
            // Get key.
            case 1 { result := getStr(input, _BITPOS_KEY, _BITPOS_KEY_LENGTH, _KEY_INITED) }
            // Get children.
            case 3 { result := children(input) }
            // Parse.
            default {
                let p := add(input, 0x20)
                let e := add(p, mload(input))
                if iszero(eq(p, e)) {
                    let c := chr(e)
                    mstore8(e, 34) // Place a '"' at the end to speed up parsing.
                    // The `34 << 248` makes `mallocItem` preserve '"' at the end.
                    mstore(0x00, setP(shl(248, 34), _BITPOS_STRING, input))
                    result, p := parseValue(input, 0, p, e)
                    mstore8(e, c) // Restore the original char at the end.
                }
                if or(lt(p, e), iszero(result)) { fail() }
            }
        }
    }

    /// @dev Casts the input to a bytes32.
    function _toInput(string memory input) private pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := input
        }
    }

    /// @dev Casts the input to a bytes32.
    function _toInput(Item memory input) private pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := input
        }
    }
}

/// @notice Library for comparing semver strings. Ignores prereleases and build metadata.
library SemverComp {
    /// @notice Struct representing a semver string.
    /// @custom:field major The major version number.
    /// @custom:field minor The minor version number.
    /// @custom:field patch The patch version number.
    struct Semver {
        uint256 major;
        uint256 minor;
        uint256 patch;
    }

    /// @notice Error thrown when a semver string has less than 3 parts.
    error SemverComp_InvalidSemverParts();

    /// @notice Parses a semver string into a Semver struct. Only handles the major, minor, and
    ///         patch numerical components, ignores prereleases and build metadata.
    /// @param _semver The semver string to parse.
    /// @return The parsed Semver struct.
    function parse(string memory _semver) internal pure returns (Semver memory) {
        string[] memory parts = LibString.split(_semver, ".");

        // We need at least 3 parts to be a valid semver, but we might have more parts if the
        // semver looks like "1.2.3-beta.4+build.5".
        if (parts.length < 3) {
            revert SemverComp_InvalidSemverParts();
        }

        // Split the patch component by hyphen, if it exists. We only want the first part of the
        // patch. We're ignoring prereleases and build versions in this library. We're handling
        // cases like 1.2.3-beta.4+build.5 as well as 1.2.3+build.5.
        string[] memory patchParts = LibString.split(parts[2], "-");
        string[] memory patchParts2 = LibString.split(patchParts[0], "+");

        // Parse the major, minor, and patch components. JSONParserLib will revert if the
        // components are not valid decimal numbers.
        return Semver({
            major: JSONParserLib.parseUint(parts[0]),
            minor: JSONParserLib.parseUint(parts[1]),
            patch: JSONParserLib.parseUint(patchParts2[0])
        });
    }

    /// @notice Compares two semver strings (=). Ignores prereleases and build metadata.
    /// @param _a The first semver string.
    /// @param _b The second semver string.
    /// @return True if the semver strings are equal, false otherwise.
    function eq(string memory _a, string memory _b) internal pure returns (bool) {
        Semver memory a = parse(_a);
        Semver memory b = parse(_b);
        return a.major == b.major && a.minor == b.minor && a.patch == b.patch;
    }

    /// @notice Compares two semver strings (<). Ignores prereleases and build metadata.
    /// @param _a The first semver string.
    /// @param _b The second semver string.
    /// @return True if the first semver string is less than the second, false otherwise.
    function lt(string memory _a, string memory _b) internal pure returns (bool) {
        Semver memory a = parse(_a);
        Semver memory b = parse(_b);
        return a.major < b.major || (a.major == b.major && a.minor < b.minor)
            || (a.major == b.major && a.minor == b.minor && a.patch < b.patch);
    }

    /// @notice Compares two semver strings (<=). Ignores prereleases and build metadata.
    /// @param _a The first semver string.
    /// @param _b The second semver string.
    /// @return True if the first semver string is less than or equal to the second, false otherwise.
    function lte(string memory _a, string memory _b) internal pure returns (bool) {
        return eq(_a, _b) || lt(_a, _b);
    }

    /// @notice Compares two semver strings (>). Ignores prereleases and build metadata.
    /// @param _a The first semver string.
    /// @param _b The second semver string.
    /// @return True if the first semver string is greater than the second, false otherwise.
    function gt(string memory _a, string memory _b) internal pure returns (bool) {
        return !eq(_a, _b) && !lt(_a, _b);
    }

    /// @notice Compares two semver strings (>=). Ignores prereleases and build metadata.
    /// @param _a The first semver string.
    /// @param _b The second semver string.
    /// @return True if the first semver string is greater than or equal to the second, false otherwise.
    function gte(string memory _a, string memory _b) internal pure returns (bool) {
        return eq(_a, _b) || gt(_a, _b);
    }
}

/// @title LivenessModule2
/// @notice This module allows challenge-based ownership transfer to a fallback owner
///         when the Safe becomes unresponsive. The fallback owner can initiate a challenge,
///         and if the Safe doesn't respond within the challenge period, ownership transfers
///         to the fallback owner.
/// @dev This is a singleton contract. To use it:
///      1. The Safe must first enable this module using ModuleManager.enableModule()
///      2. The Safe must then configure the module by calling configure() with params
///
///     This guard is compatible only with Safe version 1.4.1.
///
///      Follows a state machine diagram for the lifecycle of this contract:
///      +----------------------+
///      | Start (no challenge) |<---------------------------+
///      +----------------------+                            |
///       |                                                  | respond() by Safe
///       |  challenge() by fallbackOwner                    | OR
///       |                                                  | configureLivenessModule() by Safe
///       v                                                  | OR
///      +--------------------------------------+            | clearLivenessModule() by Safe
///      | Challenge Started                    |            |
///      | challengeStartTime = block.timestamp |------------+
///      +--------------------------------------+            |
///       |                                                  |
///       |  block.timestamp >= challengeStartTime +         |
///       |                     livenessResponsePeriod       |
///       v                                                  |
///      +-----+-----------------------------------------+   |
///      | Ready to transfer ownership to fallback owner |---+
///      +-----+-----------------------------------------+
///       |
///       |  changeOwnershipToFallback() by fallbackOwner
///       |
///       v
///      +------------------------------+
///      | Ownership Transferred        |
///      | - fallback owner sole owner  |
///      | - guard cleared              |
///      | - challenge cleared          |
///      +------------------------------+
///
abstract contract LivenessModule2 {
    /// @notice Configuration for a Safe's liveness module.
    /// @custom:field livenessResponsePeriod The duration in seconds that Safe owners have to
    ///                                      respond to a challenge.
    /// @custom:field fallbackOwner The address that can initiate challenges and claim
    ///                             ownership if the Safe is unresponsive.
    struct ModuleConfig {
        uint256 livenessResponsePeriod;
        address fallbackOwner;
    }

    /// @notice Mapping from Safe address to its configuration.
    mapping(Safe => ModuleConfig) internal _livenessSafeConfiguration;

    /// @notice Mapping from Safe address to active challenge start time (0 if none).
    mapping(Safe => uint256) public challengeStartTime;

    /// @notice Reserved address used as previous owner to the first owner in a Safe.
    address internal constant SENTINEL_OWNER = address(0x1);

    /// @notice Error for when module is not enabled for the Safe.
    error LivenessModule2_ModuleNotEnabled();

    /// @notice Error for when Safe is not configured for this module.
    error LivenessModule2_ModuleNotConfigured();

    /// @notice Error for when the contract is not 1.4.1.
    error LivenessModule2_InvalidVersion();

    /// @notice Error for when a challenge already exists.
    error LivenessModule2_ChallengeAlreadyExists();

    /// @notice Error for when no challenge exists.
    error LivenessModule2_ChallengeDoesNotExist();

    /// @notice Error for when trying to cancel a challenge after response period has ended.
    error LivenessModule2_ResponsePeriodEnded();

    /// @notice Error for when trying to execute ownership transfer while response period is
    ///         active.
    error LivenessModule2_ResponsePeriodActive();

    /// @notice Error for when caller is not authorized.
    error LivenessModule2_UnauthorizedCaller();

    /// @notice Error for invalid response period.
    error LivenessModule2_InvalidResponsePeriod();

    /// @notice Error for invalid fallback owner.
    error LivenessModule2_InvalidFallbackOwner();

    /// @notice Error for when trying to clear configuration while module is enabled.
    error LivenessModule2_ModuleStillEnabled();

    /// @notice Error for when ownership transfer verification fails.
    error LivenessModule2_OwnershipTransferFailed();

    /// @notice Emitted when a Safe configures the module.
    /// @param safe The Safe address that configured the module.
    /// @param livenessResponsePeriod The duration in seconds that Safe owners have to
    ///                               respond to a challenge.
    /// @param fallbackOwner The address that can initiate challenges and claim ownership if
    ///                      the Safe is unresponsive.
    event ModuleConfigured(address indexed safe, uint256 livenessResponsePeriod, address fallbackOwner);

    /// @notice Emitted when a Safe clears the module configuration.
    /// @param safe The Safe address that cleared the module configuration.
    event ModuleCleared(address indexed safe);

    /// @notice Emitted when a challenge is started.
    /// @param safe The Safe address that started the challenge.
    /// @param challengeStartTime The timestamp when the challenge started.
    event ChallengeStarted(address indexed safe, uint256 challengeStartTime);

    /// @notice Emitted when a challenge is cancelled.
    /// @param safe The Safe address that cancelled the challenge.
    event ChallengeCancelled(address indexed safe);

    /// @notice Emitted when ownership is transferred to the fallback owner.
    /// @param safe The Safe address that succeeded the challenge.
    /// @param fallbackOwner The address that claimed ownership if the Safe is unresponsive.
    event ChallengeSucceeded(address indexed safe, address fallbackOwner);

    ////////////////////////////////////////////////////////////////
    //                   External View Functions                  //
    ////////////////////////////////////////////////////////////////

    /// @notice Returns challenge_start_time + liveness_response_period if challenge exists, or
    ///         0 if not.
    /// @param _safe The Safe address to query.
    /// @return The challenge end timestamp, or 0 if no challenge.
    function getChallengePeriodEnd(Safe _safe) public view returns (uint256) {
        uint256 startTime = challengeStartTime[_safe];
        if (startTime == 0) {
            return 0;
        }
        ModuleConfig storage config = _livenessSafeConfiguration[_safe];
        return startTime + config.livenessResponsePeriod;
    }

    /// @notice Returns the configuration for a given Safe.
    /// @param _safe The Safe address to query.
    /// @return The ModuleConfig for the Safe.
    function livenessSafeConfiguration(Safe _safe) public view returns (ModuleConfig memory) {
        return _livenessSafeConfiguration[_safe];
    }

    ////////////////////////////////////////////////////////////////
    //              External State-Changing Functions             //
    ////////////////////////////////////////////////////////////////

    /// @notice Configures the module for a Safe that has already enabled it.
    /// @param _config The configuration parameters for the module containing the response
    ///                period and fallback owner.
    /// @dev It is strongly recommended that the fallback owner is also a Safe or at least a
    ///      contract that is capable of building and executing transaction batches.
    function configureLivenessModule(ModuleConfig memory _config) external {
        Safe callingSafe = Safe(payable(msg.sender));

        // Validate configuration parameters to ensure module can function properly.
        // livenessResponsePeriod must be > 0 to allow time for Safe owners to respond.
        if (_config.livenessResponsePeriod == 0) {
            revert LivenessModule2_InvalidResponsePeriod();
        }
        // fallbackOwner must not be zero address or the safe itself to be able to become an owner.
        if (_config.fallbackOwner == address(0) || _config.fallbackOwner == address(callingSafe)) {
            revert LivenessModule2_InvalidFallbackOwner();
        }

        // Check that the safe contract version is 1.4.1. There have been breaking changes at every
        // minor version, and we can only support one version.
        if (!SemverComp.eq(callingSafe.VERSION(), "1.4.1")) {
            revert LivenessModule2_InvalidVersion();
        }

        // Check that this module is enabled on the calling Safe.
        _assertModuleEnabled(callingSafe);

        // Store the configuration for this safe
        _livenessSafeConfiguration[callingSafe] = _config;

        // Clear any existing challenge when configuring/re-configuring.
        // This is necessary because changing the configuration (especially
        // livenessResponsePeriod)
        // would invalidate any ongoing challenge timing, creating inconsistent state.
        // For example, if a challenge was started with a 7-day period and we reconfigure to
        // 1 day, the challenge timing becomes ambiguous. Canceling ensures clean state.
        // Additionally, a Safe that is able to successfully trigger the configuration function
        // is necessarily live, so cancelling the challenge also makes sense from a
        // theoretical standpoint.
        _cancelChallenge(callingSafe);

        emit ModuleConfigured(msg.sender, _config.livenessResponsePeriod, _config.fallbackOwner);

        // Verify that any other extensions which are enabled on the Safe are configured correctly.
        _checkCombinedConfig(callingSafe);
    }

    /// @notice Clears the module configuration for a Safe.
    /// @dev Note: Clearing the configuration also cancels any ongoing challenges.
    ///      This function is intended for use when a Safe wants to permanently remove
    ///      the LivenessModule2 configuration. Typical usage pattern:
    ///      1. Safe disables the module via ModuleManager.disableModule().
    ///      2. Safe calls this clearLivenessModule() function to remove stored configuration.
    ///      3. If Safe later re-enables the module, it must call configureLivenessModule() again.
    ///      Never calling clearLivenessModule() after disabling keeps configuration data
    ///      persistent for potential future re-enabling.
    function clearLivenessModule() external {
        Safe callingSafe = Safe(payable(msg.sender));

        // Check if the calling safe has configuration set
        _assertModuleConfigured(callingSafe);

        // Check that this module is NOT enabled on the calling Safe
        // This prevents clearing configuration while module is still enabled
        _assertModuleNotEnabled(callingSafe);

        // Erase the configuration data for this safe
        delete _livenessSafeConfiguration[callingSafe];

        // Also clear any active challenge
        _cancelChallenge(callingSafe);
        emit ModuleCleared(address(callingSafe));
    }

    /// @notice Challenges an enabled safe.
    /// @param _safe The Safe address to challenge.
    function challenge(Safe _safe) external {
        // Check if the calling safe has configuration set
        _assertModuleConfigured(_safe);

        // Check that the module is still enabled on the target Safe.
        _assertModuleEnabled(_safe);

        // Check that the caller is the fallback owner
        if (msg.sender != _livenessSafeConfiguration[_safe].fallbackOwner) {
            revert LivenessModule2_UnauthorizedCaller();
        }

        // Check that no challenge already exists
        if (challengeStartTime[_safe] != 0) {
            revert LivenessModule2_ChallengeAlreadyExists();
        }

        // Set the challenge start time and emit the event
        challengeStartTime[_safe] = block.timestamp;
        emit ChallengeStarted(address(_safe), block.timestamp);
    }

    /// @notice Responds to a challenge for an enabled safe, canceling it.
    function respond() external {
        Safe callingSafe = Safe(payable(msg.sender));

        // Check if the calling safe has configuration set.
        _assertModuleConfigured(callingSafe);

        // Check that this module is enabled on the calling Safe.
        _assertModuleEnabled(callingSafe);

        // Check that a challenge exists
        uint256 startTime = challengeStartTime[callingSafe];
        if (startTime == 0) {
            revert LivenessModule2_ChallengeDoesNotExist();
        }

        // Cancel the challenge without checking if response period has expired
        // This allows the Safe to respond at any time, providing more flexibility
        _cancelChallenge(callingSafe);
    }

    /// @notice With successful challenge, removes all current owners from enabled safe, appoints
    ///         fallback as sole owner, and sets its quorum to 1.
    /// @dev After ownership transfer, the fallback owner becomes the sole owner and is also still
    ///      configured as the fallback owner. If the fallback owner would become unable to sign,
    ///      it would not be able challenge the safe again. For this reason, it is important that
    ///      the fallback owner has a way to preserve its own liveness.
    ///
    ///      It is of critical importance that this function never reverts. If it were to do so,
    ///      the Safe would be permanently bricked. For this reason, the external calls from this
    ///      function are allowed to fail silently instead of reverting.
    /// @param _safe The Safe address to transfer ownership of.
    function changeOwnershipToFallback(Safe _safe) external {
        // Ensure Safe is configured with this module to prevent unauthorized execution.
        _assertModuleConfigured(_safe);

        // Verify module is still enabled to ensure Safe hasn't disabled it mid-challenge.
        _assertModuleEnabled(_safe);

        // Only fallback owner can execute ownership transfer (per specs update)
        if (msg.sender != _livenessSafeConfiguration[_safe].fallbackOwner) {
            revert LivenessModule2_UnauthorizedCaller();
        }

        // Verify active challenge exists - without challenge, ownership transfer not allowed
        uint256 startTime = challengeStartTime[_safe];
        if (startTime == 0) {
            revert LivenessModule2_ChallengeDoesNotExist();
        }

        // Ensure response period has fully expired before allowing ownership transfer.
        // This gives Safe owners full configured time to demonstrate liveness.
        if (block.timestamp < getChallengePeriodEnd(_safe)) {
            revert LivenessModule2_ResponsePeriodActive();
        }

        // Reset the challenge state to allow a new challenge
        delete challengeStartTime[_safe];

        // Get current owners
        address[] memory owners = _safe.getOwners();

        // Remove all owners after the first one
        // Note: This loop is safe as real-world Safes have limited owners (typically < 10)
        // Gas limits would only be a concern with hundreds/thousands of owners
        while (owners.length > 1) {
            _safe.execTransactionFromModule({
                to: address(_safe),
                value: 0,
                operation: Enum.Operation.Call,
                data: abi.encodeCall(OwnerManager.removeOwner, (SENTINEL_OWNER, owners[0], 1))
            });
            owners = _safe.getOwners();
        }

        // Now swap the remaining single owner with the fallback owner
        // Note: If the fallback owner would be the only or the last owner in the owners list,
        // swapOwner would internally revert in OwnerManager, but we ignore it because the final
        // owners list would still be what we want.
        _safe.execTransactionFromModule({
            to: address(_safe),
            value: 0,
            operation: Enum.Operation.Call,
            data: abi.encodeCall(
                OwnerManager.swapOwner, (SENTINEL_OWNER, owners[0], _livenessSafeConfiguration[_safe].fallbackOwner)
            )
        });

        // Sanity check: verify the fallback owner is now the only owner
        address[] memory finalOwners = _safe.getOwners();
        if (finalOwners.length != 1 || finalOwners[0] != _livenessSafeConfiguration[_safe].fallbackOwner) {
            revert LivenessModule2_OwnershipTransferFailed();
        }

        // Disable the guard
        // Note that this will remove whichever guard is currently set on the Safe,
        // even if it is not the SaferSafes guard. This is intentional, as it is possible that the
        // guard was the cause of the liveness failure which resulted in the transfer of ownership to
        // the fallback owner.
        // WARNING: Removing the TimelockGuard from a Safe will make all Scheduled and Cancelled
        // transactions at or below the Safe nonce immediately executable by anyone. To avoid this,
        // particularly in an adversarial environment, it is recommended that the fallback owner is
        // also a Safe, and that the call to `changeOwnershipToFallback` is the first transaction
        // in a batch that also includes as many nonce-bumping no-op transactions through the Safe
        // with the TimelockGuard as needed to increase its nonce above that of all Scheduled and
        // Cancelled transactions.
        _safe.execTransactionFromModule({
            to: address(_safe),
            value: 0,
            operation: Enum.Operation.Call,
            data: abi.encodeCall(GuardManager.setGuard, (address(0)))
        });

        emit ChallengeSucceeded(address(_safe), _livenessSafeConfiguration[_safe].fallbackOwner);
    }

    ////////////////////////////////////////////////////////////////
    //                   Internal View Functions                  //
    ////////////////////////////////////////////////////////////////

    /// @notice Internal helper function which can be overriden in a child contract to check if the
    ///         guard's configuration is valid in the context of other extensions that are enabled
    ///         on the Safe.
    function _checkCombinedConfig(Safe _safe) internal view virtual;

    /// @notice Asserts that the module is configured for the given Safe.
    /// @param _safe The Safe address to check.
    function _assertModuleConfigured(Safe _safe) internal view {
        ModuleConfig storage config = _livenessSafeConfiguration[_safe];
        if (config.fallbackOwner == address(0)) {
            revert LivenessModule2_ModuleNotConfigured();
        }
    }

    /// @notice Asserts that the module is enabled for the given Safe.
    /// @param _safe The Safe address to check.
    function _assertModuleEnabled(Safe _safe) internal view {
        if (!_safe.isModuleEnabled(address(this))) {
            revert LivenessModule2_ModuleNotEnabled();
        }
    }

    /// @notice Asserts that the module is not enabled for the given Safe.
    /// @param _safe The Safe address to check.
    function _assertModuleNotEnabled(Safe _safe) internal view {
        if (_safe.isModuleEnabled(address(this))) {
            revert LivenessModule2_ModuleStillEnabled();
        }
    }

    ////////////////////////////////////////////////////////////////
    //             Internal State-Changing Functions              //
    ////////////////////////////////////////////////////////////////

    /// @notice Internal function to cancel a challenge and emit the appropriate event.
    /// @param _safe The Safe address for which to cancel the challenge.
    function _cancelChallenge(Safe _safe) internal {
        // Early return if no challenge exists
        if (challengeStartTime[_safe] == 0) {
            return;
        }

        delete challengeStartTime[_safe];
        emit ChallengeCancelled(address(_safe));
    }
}

abstract contract BaseGuard is Guard {
    function supportsInterface(bytes4 interfaceId) external view virtual override returns (bool) {
        return interfaceId == type(Guard).interfaceId // 0xe6d7a83a
            || interfaceId == type(IERC165).interfaceId; // 0x01ffc9a7
    }
}

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

interface IResourceMetering {
    struct ResourceParams {
        uint128 prevBaseFee;
        uint64 prevBoughtGas;
        uint64 prevBlockNum;
    }

    struct ResourceConfig {
        uint32 maxResourceLimit;
        uint8 elasticityMultiplier;
        uint8 baseFeeMaxChangeDenominator;
        uint32 minimumBaseFee;
        uint32 systemTxMaxGas;
        uint128 maximumBaseFee;
    }

    error OutOfGas();

    event Initialized(uint8 version);

    function params() external view returns (uint128 prevBaseFee, uint64 prevBoughtGas, uint64 prevBlockNum); // nosemgrep

    function __constructor__() external;
}

/// @title Constants
/// @notice Constants is a library for storing constants. Simple! Don't put everything in here, just
///         the stuff used in multiple contracts. Constants that only apply to a single contract
///         should be defined in that contract instead.
library Constants {
    /// @notice Special address to be used as the tx origin for gas estimation calls in the
    ///         OptimismPortal and CrossDomainMessenger calls. You only need to use this address if
    ///         the minimum gas limit specified by the user is not actually enough to execute the
    ///         given message and you're attempting to estimate the actual necessary gas limit. We
    ///         use address(1) because it's the ecrecover precompile and therefore guaranteed to
    ///         never have any code on any EVM chain.
    address internal constant ESTIMATION_ADDRESS = address(1);

    /// @notice Value used for the L2 sender storage slot in both the OptimismPortal and the
    ///         CrossDomainMessenger contracts before an actual sender is set. This value is
    ///         non-zero to reduce the gas cost of message passing transactions.
    address internal constant DEFAULT_L2_SENDER = 0x000000000000000000000000000000000000dEaD;

    /// @notice The storage slot that holds the address of a proxy implementation.
    /// @dev `bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)`
    bytes32 internal constant PROXY_IMPLEMENTATION_ADDRESS =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /// @notice The storage slot that holds the address of the owner.
    /// @dev `bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1)`
    bytes32 internal constant PROXY_OWNER_ADDRESS = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /// @notice The storage slot that holds the guard address in Safe contracts.
    /// @dev `keccak256("guard_manager.guard.address")`
    bytes32 internal constant GUARD_STORAGE_SLOT = 0x4a204f620c8c5ccdca3fd54d003badd85ba500436a431f0cbda4f558c93c34c8;

    /// @notice The address that represents ether when dealing with ERC20 token addresses.
    address internal constant ETHER = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /// @notice The address that represents the system caller responsible for L1 attributes
    ///         transactions.
    address internal constant DEPOSITOR_ACCOUNT = 0xDeaDDEaDDeAdDeAdDEAdDEaddeAddEAdDEAd0001;

    /// @notice The address used by OPCM to check if the contract is running in a testing
    ///         environment. This address doesn't have any code on production networks but can be
    ///         made to have code in tests with cheatcodes.
    address internal constant TESTING_ENVIRONMENT_ADDRESS = address(0xbeefcafe);

    /// @notice Returns the default values for the ResourceConfig. These are the recommended values
    ///         for a production network.
    function DEFAULT_RESOURCE_CONFIG() internal pure returns (IResourceMetering.ResourceConfig memory) {
        IResourceMetering.ResourceConfig memory config = IResourceMetering.ResourceConfig({
            maxResourceLimit: 20_000_000,
            elasticityMultiplier: 10,
            baseFeeMaxChangeDenominator: 8,
            minimumBaseFee: 1 gwei,
            systemTxMaxGas: 1_000_000,
            maximumBaseFee: type(uint128).max
        });
        return config;
    }
}

/// @title TimelockGuard
/// @notice This guard provides timelock functionality for Safe transactions
/// @dev This is a singleton contract, any Safe on the network can use this guard to enforce a
///      timelock delay, and allow a subset of signers to cancel a transaction if they do not agree
///      with the execution. This provides significant security improvements over the Safe's
///      default execution mechanism, which will allow any transaction to be executed as long as it
///      is fully signed, and with no mechanism for revealing the existence of said signatures.
/// Usage:
///     In order to use this guard, the Safe must first enable it using Safe.setGuard(), and then
///     configure it by calling TimelockGuard.configureTimelockGuard().
/// Scheduling and executing transactions:
///     Once enabled and configured, all transactions executed by the Safe's execTransaction()
///     function will revert, unless the transaction has first been scheduled by calling
///     scheduleTransaction() on this contract. Because scheduleTransaction() uses the Safe's own
///     signature verification logic, the same signatures used to execute a transaction can be
///     used to schedule it.
///     Note: this guard does not apply a delay to transactions executed by modules which are
///     installed on the Safe.
/// Cancelling transactions:
///     Once a transaction has been scheduled, so long as it has not already been executed, it can
///     be cancelled by calling cancelTransaction() on this contract.
///     This mechanism allows for a subset of signers to cancel a transaction if they do not agree
///     with the execution.
///     As an 'anti-griefing' mechanism, the cancellation threshold (the number of signatures
///     required to cancel a transaction) starts at 1, and is automatically increased by 1 after
///     each cancellation.
///     The cancellation threshold is reset to 1 after any transaction is executed successfully.
/// Failed transactions:
///     The execTransaction call by the Safe doesn't revert if the called transaction fails and it
///     returns a false success value instead, bumping the nonce as with successful transactions.
///     The TimelockGuard matches this behaviour by marking failed transactions as Executed,
///     removing them from the pending transactions queue, and resetting the cancellation
///     threshold.
/// Safe Version Compatibility:
///     This guard is compatible only with Safe version 1.4.1.
/// Threats Mitigated and Integration With LivenessModule:
///     This Guard is designed to protect against a number of well-defined scenarios, defined on
///     the two axes of amount of keys compromised, and type of compromise.
///     For scenarios where the keys compromised don't amount to a blocking threshold (the number
///     of signers who must refuse to sign a transaction in order to block it from being executed),
///     regular transactions from the multisig for removal or rotation is the preferred solution.
///     For scenarios where the keys compromised are at least a blocking threshold, but not as much
///     as quorum, the LivenessModule would be used. If there is a quorum of absent keys, but no
///     significant malicious control, the LivenessModule would also be used.
///     The TimelockGuard acts when there is malicious control of a quorum of keys. If the control
///     is temporary, for example by phishing a single set of signatures, then the TimelockGuard's
///     cancellation is enough to stop the attack entirely. If the malicious control would be
///     permanent, then the TimelockGuard will buy some time to execute remediations external to
///     the compromised safe.
///     The following table summarizes the various scenarios and the course of action to take in
///     each case.
///                       +-------------------------------------------------------------------+
///                       |                        Course of action when X Number of keys...  |
/// +-----------------------------------------------------------------------------------------+
/// |                     | ... are Absent                 |  ... are Maliciously Controlled  |
/// | X Number of keys    | (Honest signers cannot sign)   |  (Malicious signers can sign)    |
/// +-----------------------------------------------------------------------------------------+
/// | 1+                  | swapOwner                      | swapOwner                        |
/// +-----------------------------------------------------------------------------------------+
/// | Blocking Threshold+ | challenge +                    | challenge +                      |
/// |                     | changeOwnershipToFallback      | changeOwnershipToFallback        |
/// +-----------------------------------------------------------------------------------------+
/// | Quorum+             | challenge +                    | cancelTransaction                |
/// |                     | changeOwnershipToFallback      |                                  |
/// +-----------------------------------------------------------------------------------------+
abstract contract TimelockGuard is BaseGuard {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    /// @notice Allowed states of a transaction
    enum TransactionState {
        NotScheduled,
        Pending,
        Cancelled,
        Executed
    }

    /// @notice Scheduled transaction
    /// @custom:field txHash The hash of the transaction.
    /// @custom:field executionTime The timestamp when execution becomes valid.
    /// @custom:field state The state of the transaction.
    /// @custom:field params The parameters of the transaction.
    /// @custom:field nonce The nonce of the transaction.
    struct ScheduledTransaction {
        bytes32 txHash;
        uint256 executionTime;
        TransactionState state;
        ExecTransactionParams params;
        uint256 nonce;
    }

    /// @notice Parameters for the Safe's execTransaction function
    /// @custom:field to The address of the contract to call.
    /// @custom:field value The value to send with the transaction.
    /// @custom:field data The data to send with the transaction.
    /// @custom:field operation The operation to perform with the transaction.
    /// @custom:field safeTxGas The gas to use for the transaction.
    /// @custom:field baseGas The base gas to use for the transaction.
    /// @custom:field gasPrice The gas price to use for the transaction.
    /// @custom:field gasToken The token to use for the transaction.
    /// @custom:field refundReceiver The address to receive the refund for the transaction.
    struct ExecTransactionParams {
        address to;
        uint256 value;
        bytes data;
        Enum.Operation operation;
        uint256 safeTxGas;
        uint256 baseGas;
        uint256 gasPrice;
        address gasToken;
        address payable refundReceiver;
    }

    /// @notice Aggregated state for each Safe using this guard.
    /// @dev We have chosen for operational reasons to keep a list of pending transactions that can
    ///      be easily retrieved via a function call. This is done by maintaining a separate
    ///      EnumerableSet with the hashes of pending transactions. Transactions in the enumerable
    ///      set need to be updated along with updates to the ScheduledTransactions mapping.
    struct SafeState {
        uint256 timelockDelay;
        uint256 cancellationThreshold;
        mapping(bytes32 => ScheduledTransaction) scheduledTransactions;
        EnumerableSet.Bytes32Set pendingTxHashes;
    }

    /// @notice Mapping from Safe address to a mapping of configuration nonce to its state.
    mapping(Safe => mapping(uint256 => SafeState)) internal _safeStates;

    /// @notice Mapping from Safe address to the current configuration nonce.
    mapping(Safe => uint256) internal _safeConfigNonces;

    /// @notice Error for when guard is not enabled for the Safe
    error TimelockGuard_GuardNotEnabled();

    /// @notice Error for when Safe is not configured for this guard
    error TimelockGuard_GuardNotConfigured();

    /// @notice Error for invalid timelock delay
    error TimelockGuard_InvalidTimelockDelay();

    /// @notice Error for when a transaction is already scheduled
    error TimelockGuard_TransactionAlreadyScheduled();

    /// @notice Error for when a transaction is already cancelled
    error TimelockGuard_TransactionAlreadyCancelled();

    /// @notice Error for when a transaction is not scheduled
    error TimelockGuard_TransactionNotScheduled();

    /// @notice Error for when a transaction is not ready to execute (timelock delay not passed)
    error TimelockGuard_TransactionNotReady();

    /// @notice Error for when a transaction has already been executed
    error TimelockGuard_TransactionAlreadyExecuted();

    /// @notice Error for when the contract is not 1.4.1
    error TimelockGuard_InvalidVersion();

    /// @notice Error for when trying to clear guard while it is still enabled
    error TimelockGuard_GuardStillEnabled();

    /// @notice Error for when the caller is not an owner of the Safe
    error TimelockGuard_NotOwner();

    /// @notice Emitted when a Safe configures the guard
    /// @param safe The Safe whose guard is configured.
    /// @param timelockDelay The timelock delay in seconds.
    event GuardConfigured(Safe indexed safe, uint256 timelockDelay);

    /// @notice Emitted when a transaction is scheduled for a Safe.
    /// @param safe The Safe whose transaction is scheduled.
    /// @param txHash The identifier of the scheduled transaction.
    /// @param executionTime The timestamp when execution becomes valid.
    event TransactionScheduled(Safe indexed safe, bytes32 indexed txHash, uint256 executionTime);

    /// @notice Emitted when a transaction is cancelled for a Safe.
    /// @param safe The Safe whose transaction is cancelled.
    /// @param txHash The identifier of the cancelled transaction.
    event TransactionCancelled(Safe indexed safe, bytes32 indexed txHash);

    /// @notice Emitted when a transaction is executed for a Safe.
    /// @param safe The Safe whose transaction is executed.
    /// @param txHash The identifier of the executed transaction.
    event TransactionExecuted(Safe indexed safe, bytes32 indexed txHash);

    /// @notice Emitted when the cancellation threshold is updated
    /// @param safe The Safe whose cancellation threshold is updated.
    /// @param oldThreshold The old cancellation threshold.
    /// @param newThreshold The new cancellation threshold.
    event CancellationThresholdUpdated(Safe indexed safe, uint256 oldThreshold, uint256 newThreshold);

    /// @notice Used to emit a message, primarily to ensure that the cancelTransaction function is
    ///         is not labelled as view so that it is treated as a state-changing function.
    event Message(string message);

    ////////////////////////////////////////////////////////////////
    //                  Internal View Functions                   //
    ////////////////////////////////////////////////////////////////

    /// @notice Returns the blocking threshold, which is defined as the minimum number of owners
    ///         that must coordinate to block a transaction from being executed by refusing to
    ///         sign.
    /// @dev Because `_safe.getOwners()` loops through the owners list, it could run out of gas if
    ///      there are a lot of owners.
    /// @param _safe The Safe address to query
    /// @return The current blocking threshold
    function _blockingThreshold(Safe _safe) internal view returns (uint256) {
        return _safe.getOwners().length - _safe.getThreshold() + 1;
    }

    /// @notice Internal helper to check if TimelockGuard is enabled for a Safe
    /// @param _safe The Safe address
    /// @return The current guard address
    function _isGuardEnabled(Safe _safe) internal view returns (bool) {
        address guard = abi.decode(_safe.getStorageAt(uint256(Constants.GUARD_STORAGE_SLOT), 1), (address));
        return guard == address(this);
    }

    /// @notice Returns a storage reference to the current SafeState for a given Safe.
    /// @param _safe The Safe address to query.
    /// @return The current SafeState storage reference.
    function _currentSafeState(Safe _safe) internal view returns (SafeState storage) {
        return _safeStates[_safe][_safeConfigNonces[_safe]];
    }

    /// @notice Internal helper function which can be overridden in a child contract to check if the
    ///         guard's configuration is valid in the context of other extensions that are enabled
    ///         on the Safe.
    function _checkCombinedConfig(Safe _safe) internal view virtual;

    ////////////////////////////////////////////////////////////////
    //                  External View Functions                   //
    ////////////////////////////////////////////////////////////////

    /// @notice Returns the cancellation threshold for a given safe
    /// @param _safe The Safe address to query
    /// @return The current cancellation threshold
    function cancellationThreshold(Safe _safe) public view returns (uint256) {
        return _currentSafeState(_safe).cancellationThreshold;
    }

    /// @notice Returns the maximum cancellation threshold for a given safe
    /// @dev The cancellation threshold must be capped in order to preserve the ability of honest
    ///      users to cancel malicious transactions. The rationale for the calculation of the
    ///      maximum cancellation threshold is as follows:
    ///      If the quorum is lower, then it is used as the maximum cancellation threshold, so that
    ///      even if an attacker has _joint control_ of a quorum of keys, the honest users can
    ///      still indefinitely cancel a malicious transaction.
    ///      If the blocking threshold is lower, then it is used as the maximum cancellation
    ///      threshold, so that if an attacker has less than a quorum of keys, honest users can
    ///      still remove an attacker from the Safe by refusing to respond to a malicious
    ///      transaction.
    /// @param _safe The Safe address to query
    /// @return The maximum cancellation threshold
    function maxCancellationThreshold(Safe _safe) public view returns (uint256) {
        uint256 blockingThreshold = _blockingThreshold(_safe);
        uint256 quorum = _safe.getThreshold();
        // Return the minimum of the blocking threshold and the quorum
        return (blockingThreshold < quorum ? blockingThreshold : quorum);
    }

    /// @notice Returns the timelock delay for a given Safe
    /// @param _safe The Safe address to query
    /// @return The timelock delay in seconds
    function timelockDelay(Safe _safe) public view returns (uint256) {
        return _currentSafeState(_safe).timelockDelay;
    }

    /// @notice Returns the scheduled transaction for a given Safe and tx hash
    /// @dev This function is necessary to properly expose the scheduledTransactions mapping, as
    ///      simply making the mapping public will return a tuple instead of a struct.
    function scheduledTransaction(Safe _safe, bytes32 _txHash) public view returns (ScheduledTransaction memory) {
        return _currentSafeState(_safe).scheduledTransactions[_txHash];
    }

    /// @notice Returns the list of all scheduled but not cancelled or executed transactions for
    ///         for a given safe
    /// @dev WARNING: This operation will copy the entire set of pending transactions to memory,
    ///      which can be quite expensive. This is designed only to be used by view accessors that
    ///      are queried without any gas fees. Developers should keep in mind that this function
    ///      has an unbounded cost, and using it as part of a state-changing function may render
    ///      the function uncallable if the set grows to a point where copying to memory consumes
    ///      too much gas to fit in a block.
    /// @return List of pending transaction hashes
    function pendingTransactions(Safe _safe) external view returns (ScheduledTransaction[] memory) {
        SafeState storage safeState = _currentSafeState(_safe);

        // Get the list of pending transaction hashes
        bytes32[] memory hashes = safeState.pendingTxHashes.values();

        // We want to provide the caller with the full parameters of each pending transaction, but
        // mappings are not iterable, so we use the enumerable set of pending transaction hashes to
        // retrieve the ScheduledTransaction struct for each hash, and then return an array of the
        // ScheduledTransaction structs.
        ScheduledTransaction[] memory scheduled = new ScheduledTransaction[](hashes.length);
        for (uint256 i = 0; i < hashes.length; i++) {
            scheduled[i] = safeState.scheduledTransactions[hashes[i]];
        }
        return scheduled;
    }

    ////////////////////////////////////////////////////////////////
    //                 Guard Interface Functions                  //
    ////////////////////////////////////////////////////////////////

    /// @notice Implementation of Guard interface.Called by the Safe before executing a transaction
    /// @dev This function is used to check that the transaction has been scheduled and is ready to
    /// execute. It only reads the state of the contract, and potentially reverts in order to
    /// protect against execution of unscheduled, early or cancelled transactions.
    function checkTransaction(
        address _to,
        uint256 _value,
        bytes memory _data,
        Enum.Operation _operation,
        uint256 _safeTxGas,
        uint256 _baseGas,
        uint256 _gasPrice,
        address _gasToken,
        address payable _refundReceiver,
        bytes memory, /* signatures */
        address _msgSender
    ) external override {
        Safe callingSafe = Safe(payable(msg.sender));

        if (_currentSafeState(callingSafe).timelockDelay == 0) {
            // We return immediately. This is important in order to allow a Safe which has the
            // guard set, but not configured, to complete the setup process.

            // It is also just a reasonable thing to do, since an unconfigured Safe must have a
            // delay of zero.
            return;
        }

        // Limit execution of transactions to owners of the Safe only.
        // This ensures that an attacker cannot simply collect valid signatures, but must also
        // control a private key. It is accepted as a trade-off that paymasters, relayers or UX
        // wrappers cannot execute transactions with the TimelockGuard enabled.
        if (!callingSafe.isOwner(_msgSender)) {
            revert TimelockGuard_NotOwner();
        }

        // Get the nonce of the Safe for the transaction being executed,
        // since the Safe's nonce is incremented before the transaction is executed,
        // we must subtract 1.
        uint256 nonce = callingSafe.nonce() - 1;

        // Get the transaction hash from the Safe's getTransactionHash function
        bytes32 txHash = callingSafe.getTransactionHash(
            _to, _value, _data, _operation, _safeTxGas, _baseGas, _gasPrice, _gasToken, _refundReceiver, nonce
        );

        // Get the scheduled transaction
        ScheduledTransaction storage scheduledTx = _currentSafeState(callingSafe).scheduledTransactions[txHash];

        // Check if the transaction was cancelled
        if (scheduledTx.state == TransactionState.Cancelled) {
            revert TimelockGuard_TransactionAlreadyCancelled();
        }

        // Check if the transaction has already been executed
        // Note: this is of course enforced by the Safe itself, but we check it here for
        // completeness
        if (scheduledTx.state == TransactionState.Executed) {
            revert TimelockGuard_TransactionAlreadyExecuted();
        }

        // Check if the transaction has been scheduled
        if (scheduledTx.state == TransactionState.NotScheduled) {
            revert TimelockGuard_TransactionNotScheduled();
        }

        // Check if the timelock delay has passed
        if (scheduledTx.executionTime > block.timestamp) {
            revert TimelockGuard_TransactionNotReady();
        }

        // Reset the cancellation threshold
        _resetCancellationThreshold(callingSafe);

        // Set the transaction as executed.
        // Reverts in transaction as called from the Safe will be caught and ignored, with the Safe
        // bumping the nonce regardless. We accordingly set the transaction as executed and remove
        // it from the pending transactions anyway, as it can't be retried.
        scheduledTx.state = TransactionState.Executed;
        _currentSafeState(callingSafe).pendingTxHashes.remove(txHash);

        emit TransactionExecuted(callingSafe, txHash);
    }

    /// @notice Implementation of Guard interface. Called by the Safe after executing a transaction
    function checkAfterExecution(bytes32 _txHash, bool _success) external override {}

    ////////////////////////////////////////////////////////////////
    //              Internal State-Changing Functions             //
    ////////////////////////////////////////////////////////////////

    /// @notice Increase the cancellation threshold for a safe
    /// @dev This function must be called only once and only when calling cancel
    /// @param _safe The Safe address to increase the cancellation threshold for.
    function _increaseCancellationThreshold(Safe _safe) internal {
        SafeState storage safeState = _currentSafeState(_safe);

        if (safeState.cancellationThreshold < maxCancellationThreshold(_safe)) {
            uint256 oldThreshold = safeState.cancellationThreshold;
            safeState.cancellationThreshold++;
            emit CancellationThresholdUpdated(_safe, oldThreshold, safeState.cancellationThreshold);
        }
    }

    /// @notice Reset the cancellation threshold for a safe
    /// @dev This function must be called only once and only when calling checkAfterExecution
    /// @param _safe The Safe address to reset the cancellation threshold for.
    function _resetCancellationThreshold(Safe _safe) internal {
        SafeState storage safeState = _currentSafeState(_safe);
        uint256 oldThreshold = safeState.cancellationThreshold;
        safeState.cancellationThreshold = 1;
        emit CancellationThresholdUpdated(_safe, oldThreshold, 1);
    }

    ////////////////////////////////////////////////////////////////
    //              External State-Changing Functions             //
    ////////////////////////////////////////////////////////////////

    /// @notice Configure the contract as a timelock guard by setting the timelock delay
    /// @dev This function is only callable by the Safe itself. Requiring a call from the Safe
    ///      itself (rather than accepting signatures directly as in cancelTransaction()) is
    ///      important to ensure that maliciously gathered signatures will not be able to instantly
    ///      reconfigure the delay to zero. This function does not check that the guard is enabled
    ///      on the Safe, the recommended approach is to atomically enable the guard and configure
    ///      the delay in a single batched transaction.
    /// @param _timelockDelay The timelock delay in seconds (0 to clear configuration)
    function configureTimelockGuard(uint256 _timelockDelay) external {
        // Record the calling Safe
        Safe callingSafe = Safe(payable(msg.sender));

        // Check that the safe contract is version 1.4.1
        // There have been breaking changes at every minor version, and we can only support one
        // version.
        if (!SemverComp.eq(callingSafe.VERSION(), "1.4.1")) {
            revert TimelockGuard_InvalidVersion();
        }

        // Check that this guard is enabled on the calling Safe
        if (!_isGuardEnabled(callingSafe)) {
            revert TimelockGuard_GuardNotEnabled();
        }

        // Validate timelock delay - must not be zero or longer than 1 year
        if (_timelockDelay == 0 || _timelockDelay > 365 days) {
            revert TimelockGuard_InvalidTimelockDelay();
        }

        // Store the timelock delay for this safe
        _currentSafeState(callingSafe).timelockDelay = _timelockDelay;

        // Initialize (or reset) the cancellation threshold to 1.
        _resetCancellationThreshold(callingSafe);
        emit GuardConfigured(callingSafe, _timelockDelay);

        // Verify that any other extensions which are enabled on the Safe are configured correctly.
        _checkCombinedConfig(callingSafe);
    }

    /// @notice Clears the timelock guard configuration for a Safe.
    /// @dev Note: Clearing the configuration also cancels all pending transactions.
    ///      This function is intended for use when a Safe wants to permanently remove
    ///      the TimelockGuard configuration. Typical usage pattern:
    ///      1. Safe disables the guard via GuardManager.setGuard(address(0)).
    ///      2. Safe calls this clearTimelockGuard() function to remove stored configuration.
    ///      3. If Safe later re-enables the guard, it must call configureTimelockGuard() again.
    ///      Warning: Clearing the configuration allows all transactions previously scheduled to be
    ///      scheduled again, including cancelled transactions. It is strongly recommended to
    ///      manually increment the Safe's nonce when a scheduled transaction is cancelled.
    function clearTimelockGuard() external {
        Safe callingSafe = Safe(payable(msg.sender));

        // Check that this guard is NOT enabled on the calling Safe
        // This prevents clearing configuration while guard is still enabled
        if (_isGuardEnabled(callingSafe)) {
            revert TimelockGuard_GuardStillEnabled();
        }

        // Clear the configuration by bumping the nonce, all config and pending transactions will
        // be effectively wiped.
        _safeConfigNonces[callingSafe]++;
    }

    /// @notice Schedule a transaction for execution after the timelock delay.
    /// @dev This function validates signatures in the exact same way as the Safe's own
    ///      execTransaction function, meaning that the same signatures used to schedule a
    ///      transaction can be used to execute it later. This maintains compatibility with
    ///      existing signature generation tools. Owners can use any method to sign the a
    ///      transaction, including signing with a private key, calling the Safe's approveHash
    ///      function, or EIP1271 contract signatures.
    ///      The Safe doesn't increase its nonce when a transaction is cancelled in the Timelock.
    ///      This means that it is possible to add the very same transaction a second time to the
    ///      safe queue, but it won't be possible to schedule it again in the Timelock. It is
    ///      recommended that the safe nonce is manually incremented when a scheduled transaction
    ///      is cancelled.
    /// @param _safe The Safe address to schedule the transaction for.
    /// @param _nonce The nonce of the Safe for the transaction being scheduled.
    /// @param _params The parameters of the transaction being scheduled.
    /// @param _signatures The signatures of the owners who are scheduling the transaction.
    function scheduleTransaction(
        Safe _safe,
        uint256 _nonce,
        ExecTransactionParams memory _params,
        bytes memory _signatures
    ) external {
        // Check that this guard is enabled on the calling Safe
        if (!_isGuardEnabled(_safe)) {
            revert TimelockGuard_GuardNotEnabled();
        }

        // Check that the guard has been configured for the Safe
        if (_currentSafeState(_safe).timelockDelay == 0) {
            revert TimelockGuard_GuardNotConfigured();
        }

        // Get the encoded transaction data as defined in the Safe
        // The format of the string returned is: "0x1901{domainSeparator}{safeTxHash}"
        bytes memory txHashData = _safe.encodeTransactionData(
            _params.to,
            _params.value,
            _params.data,
            _params.operation,
            _params.safeTxGas,
            _params.baseGas,
            _params.gasPrice,
            _params.gasToken,
            _params.refundReceiver,
            _nonce
        );

        // Get the transaction hash and data as defined in the Safe
        // This value is identical to keccak256(txHashData), but we prefer to use the Safe's own
        // internal logic as it is more future-proof in case future versions of the Safe change
        // the transaction hash derivation.
        bytes32 txHash = _safe.getTransactionHash(
            _params.to,
            _params.value,
            _params.data,
            _params.operation,
            _params.safeTxGas,
            _params.baseGas,
            _params.gasPrice,
            _params.gasToken,
            _params.refundReceiver,
            _nonce
        );

        // Check if the transaction exists
        // A transaction can only be scheduled once, regardless of whether it has been cancelled or
        // not, as otherwise an observer could reuse the same signatures to either:
        // 1. Reschedule a transaction after it has been cancelled
        // 2. Reschedule a pending transaction, which would update the execution time thus
        //    extending the delay for the original transaction.
        if (_currentSafeState(_safe).scheduledTransactions[txHash].executionTime != 0) {
            revert TimelockGuard_TransactionAlreadyScheduled();
        }

        // Verify signatures using the Safe's signature checking logic
        // This function call reverts if the signatures are invalid.
        _safe.checkSignatures(txHash, txHashData, _signatures);

        // Calculate the execution time
        uint256 executionTime = block.timestamp + _currentSafeState(_safe).timelockDelay;

        // Schedule the transaction and add it to the pending transactions set
        _currentSafeState(_safe).scheduledTransactions[txHash] = ScheduledTransaction({
            txHash: txHash,
            executionTime: executionTime,
            state: TransactionState.Pending,
            params: _params,
            nonce: _nonce
        });
        _currentSafeState(_safe).pendingTxHashes.add(txHash);

        emit TransactionScheduled(_safe, txHash, executionTime);
    }

    /// @notice Cancel a scheduled transaction if cancellation threshold is met
    /// @dev This function aims to mimic the approach which would be used by a quorum of signers to
    ///      cancel a partially signed transaction, by signing and executing an empty transaction
    ///      at the same nonce.
    ///      This enables us to define a standard "cancellation transaction" format using the Safe
    ///      address, nonce, and hash of the transaction being cancelled. This is necessary to
    ///      ensure that the cancellation transaction is unique and cannot be used to cancel
    ///      another transaction at the same nonce.
    ///
    ///      Signature verification uses the Safe's checkNSignatures function, so that the number
    ///      of signatures can be set by the Safe's current cancellation threshold. Another benefit
    ///      of checkNSignatures is that owners can use any method to sign the cancellation
    ///      transaction inputs, including signing with a private key, calling the Safe's
    ///      approveHash function, or EIP1271 contract signatures.
    ///
    ///      It is allowed to cancel transactions from a disabled TimelockGuard, as a way of
    ///      clearing the queue that wouldn't be as blunt as calling `clearTimelockConfiguration`.
    /// @param _safe The Safe address to cancel the transaction for.
    /// @param _txHash The hash of the transaction being cancelled.
    /// @param _nonce The nonce of the Safe for the transaction being cancelled.
    /// @param _signatures The signatures of the owners who are cancelling the transaction.
    function cancelTransaction(Safe _safe, bytes32 _txHash, uint256 _nonce, bytes memory _signatures) external {
        // The following checks ensure that the transaction has:
        // 1. Been scheduled
        // 2. Not already been cancelled
        // 3. Not already been executed
        // There is nothing inherently wrong with cancelling a transaction a transaction that
        // doesn't meet these criteria, but we revert in order to inform the user, and avoid
        // emitting a misleading TransactionCancelled event.
        if (_currentSafeState(_safe).scheduledTransactions[_txHash].state == TransactionState.Cancelled) {
            revert TimelockGuard_TransactionAlreadyCancelled();
        }
        if (_currentSafeState(_safe).scheduledTransactions[_txHash].state == TransactionState.Executed) {
            revert TimelockGuard_TransactionAlreadyExecuted();
        }
        if (_currentSafeState(_safe).scheduledTransactions[_txHash].state == TransactionState.NotScheduled) {
            revert TimelockGuard_TransactionNotScheduled();
        }

        // Generate the cancellation transaction data
        bytes memory txData = abi.encodeCall(this.signCancellation, (_txHash));
        // Any nonce can be used here, as long as all of the signatures are for the same
        // nonce. In practice we expect the nonce to be the same as the nonce of the transaction
        // being cancelled, as this most closely mimics the behaviour of the Safe UI's transaction
        // replacement feature. However we do not enforce that here, to allow for flexibility,
        // and to avoid the need for logic to retrieve the nonce from the transaction being
        // cancelled.
        bytes memory cancellationTxData = _safe.encodeTransactionData(
            address(this), 0, txData, Enum.Operation.Call, 0, 0, 0, address(0), address(0), _nonce
        );
        bytes32 cancellationTxHash = _safe.getTransactionHash(
            address(this), 0, txData, Enum.Operation.Call, 0, 0, 0, address(0), address(0), _nonce
        );

        // Verify signatures using the Safe's signature checking logic, with the cancellation
        // threshold as the number of signatures required.
        _safe.checkNSignatures(
            cancellationTxHash, cancellationTxData, _signatures, _currentSafeState(_safe).cancellationThreshold
        );

        // Set the transaction as cancelled, and remove it from the pending transactions set
        _currentSafeState(_safe).scheduledTransactions[_txHash].state = TransactionState.Cancelled;
        _currentSafeState(_safe).pendingTxHashes.remove(_txHash);

        // Increase the cancellation threshold
        _increaseCancellationThreshold(_safe);

        emit TransactionCancelled(_safe, _txHash);
    }

    ////////////////////////////////////////////////////////////////
    //                      Dummy Functions                       //
    ////////////////////////////////////////////////////////////////

    /// @notice Dummy function provided as a utility to facilitate signing cancelTransaction data
    ///         in the Safe UI.
    function signCancellation(bytes32) public {
        emit Message("This function is not meant to be called, did you mean to call cancelTransaction?");
    }
}

/// @title ISemver
/// @notice ISemver is a simple contract for ensuring that contracts are
///         versioned using semantic versioning.
interface ISemver {
    /// @notice Getter for the semantic version of the contract. This is not
    ///         meant to be used onchain but instead meant to be used by offchain
    ///         tooling.
    /// @return Semver contract version as a string.
    function version() external view returns (string memory);
}

/// @title SaferSafes
/// @notice Combined Safe extensions providing both liveness module and timelock guard
///         functionality.
/// @dev This contract can be enabled simultaneously as both a module and a guard on a Safe:
///      - As a module: provides liveness challenge functionality to prevent multisig deadlock
///      - As a guard: provides timelock functionality for transaction delays and cancellation
///      The two components in this contract are almost entirely independent of each other, and can
///      be treated as separate extensions to the Safe. The only shared logic is the
///      _checkCombinedConfig which runs at the end of the configuration functions for both
///      components and ensures that the resulting configuration is valid. Either component can be
///      enabled or disabled independently of the other. When installing either component, it
///      should first be enabled, and then configured. If a component's functionality is not
///      desired, then there is no need to enable or configure it.
///      This contract is compatible only with the Safe contract version 1.4.1 due to the
///      compatibility restrictions in the LivenessModule2 and TimelockGuard contracts.
contract SaferSafes is LivenessModule2, TimelockGuard, ISemver {
    /// @notice Semantic version.
    /// @custom:semver 1.10.1
    string public constant version = "1.10.1";

    /// @notice Error for when the liveness response period is insufficient.
    error SaferSafes_InsufficientLivenessResponsePeriod();

    /// @notice Internal helper function which can be overriden in a child contract to check if the
    ///         guard's configuration is valid in the context of other extensions that are enabled
    ///         on the Safe. This function acts as a FREI-PI invariant check to ensure the
    ///         resulting config is valid, it MUST be called at the end of any configuration
    ///         functions in the parent contract.
    function _checkCombinedConfig(Safe _safe) internal view override(LivenessModule2, TimelockGuard) {
        // We only need to perform this check if both the guard and the module are enabled on the
        // Safe
        if (!(_isGuardEnabled(_safe) && _safe.isModuleEnabled(address(this)))) {
            return;
        }

        uint256 timelockDelay = _currentSafeState(_safe).timelockDelay;
        uint256 livenessResponsePeriod = _livenessSafeConfiguration[_safe].livenessResponsePeriod;

        // If the timelock delay is 0, then the timelock guard is enabled but not configured.
        // No delay is applied to transactions, so we don't need to perform any further checks.
        if (timelockDelay == 0) {
            return;
        }

        // If the liveness response period is 0, then the liveness module is enabled but not
        // configured.
        // Challenging is not possible, so we don't need to perform any further checks.
        if (livenessResponsePeriod == 0) {
            return;
        }

        // The liveness response period must be at least twice the timelock delay, this is
        // necessary to prevent a situation in which a Safe is not able to respond because there is
        // insufficient time to respond to a challenge after the timelock delay has expired.
        if (livenessResponsePeriod < 2 * timelockDelay) {
            revert SaferSafes_InsufficientLivenessResponsePeriod();
        }
    }
}
