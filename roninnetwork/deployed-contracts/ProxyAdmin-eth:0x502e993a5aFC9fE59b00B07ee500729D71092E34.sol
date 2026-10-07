// SPDX-License-Identifier: Unknown
pragma solidity 0.8.15;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @custom:legacy
 * @title AddressManager
 * @notice AddressManager is a legacy contract that was used in the old version of the Optimism
 *         system to manage a registry of string names to addresses. We now use a more standard
 *         proxy system instead, but this contract is still necessary for backwards compatibility
 *         with several older contracts.
 */
contract AddressManager is Ownable {
    /**
     * @notice Mapping of the hashes of string names to addresses.
     */
    mapping(bytes32 => address) private addresses;

    /**
     * @notice Emitted when an address is modified in the registry.
     *
     * @param name       String name being set in the registry.
     * @param newAddress Address set for the given name.
     * @param oldAddress Address that was previously set for the given name.
     */
    event AddressSet(string indexed name, address newAddress, address oldAddress);

    /**
     * @notice Changes the address associated with a particular name.
     *
     * @param _name    String name to associate an address with.
     * @param _address Address to associate with the name.
     */
    function setAddress(string memory _name, address _address) external onlyOwner {
        bytes32 nameHash = _getNameHash(_name);
        address oldAddress = addresses[nameHash];
        addresses[nameHash] = _address;

        emit AddressSet(_name, _address, oldAddress);
    }

    /**
     * @notice Retrieves the address associated with a given name.
     *
     * @param _name Name to retrieve an address for.
     *
     * @return Address associated with the given name.
     */
    function getAddress(string memory _name) external view returns (address) {
        return addresses[_getNameHash(_name)];
    }

    /**
     * @notice Computes the hash of a name.
     *
     * @param _name Name to compute a hash for.
     *
     * @return Hash of the given name.
     */
    function _getNameHash(string memory _name) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_name));
    }
}

/**
 * @title IStaticERC1967Proxy
 * @notice IStaticERC1967Proxy is a static version of the ERC1967 proxy interface.
 */
interface IStaticERC1967Proxy {
    function implementation() external view returns (address);

    function admin() external view returns (address);
}

/**
 * @title IStaticL1ChugSplashProxy
 * @notice IStaticL1ChugSplashProxy is a static version of the ChugSplash proxy interface.
 */
interface IStaticL1ChugSplashProxy {
    function getImplementation() external view returns (address);

    function getOwner() external view returns (address);
}

// NOTE(l2beat): This is an interface, generated from the contract source code.
interface Proxy {
    receive() external payable;
    fallback() external payable;
    function upgradeTo(address _implementation) external;
    function upgradeToAndCall(address _implementation, bytes calldata _data) external payable returns (bytes memory);
    function changeAdmin(address _admin) external;
    function admin() external returns (address);
    function implementation() external returns (address);
}

// NOTE(l2beat): This is an interface, generated from the contract source code.
interface L1ChugSplashProxy {
    receive() external payable;
    fallback() external payable;
    function setStorage(bytes32 _key, bytes32 _value) external;
    function setOwner(address _owner) external;
    function getOwner() external returns (address);
    function getImplementation() external returns (address);
}

/**
 * @title ProxyAdmin
 * @notice This is an auxiliary contract meant to be assigned as the admin of an ERC1967 Proxy,
 *         based on the OpenZeppelin implementation. It has backwards compatibility logic to work
 *         with the various types of proxies that have been deployed by Optimism in the past.
 */
contract ProxyAdmin is Ownable {
    /**
     * @notice The proxy types that the ProxyAdmin can manage.
     *
     * @custom:value ERC1967    Represents an ERC1967 compliant transparent proxy interface.
     * @custom:value CHUGSPLASH Represents the Chugsplash proxy interface (legacy).
     * @custom:value RESOLVED   Represents the ResolvedDelegate proxy (legacy).
     */
    enum ProxyType {
        ERC1967,
        CHUGSPLASH,
        RESOLVED
    }

    /**
     * @notice A mapping of proxy types, used for backwards compatibility.
     */
    mapping(address => ProxyType) public proxyType;

    /**
     * @notice A reverse mapping of addresses to names held in the AddressManager. This must be
     *         manually kept up to date with changes in the AddressManager for this contract
     *         to be able to work as an admin for the ResolvedDelegateProxy type.
     */
    mapping(address => string) public implementationName;

    /**
     * @notice The address of the address manager, this is required to manage the
     *         ResolvedDelegateProxy type.
     */
    AddressManager public addressManager;

    /**
     * @notice A legacy upgrading indicator used by the old Chugsplash Proxy.
     */
    bool internal upgrading;

    /**
     * @param _owner Address of the initial owner of this contract.
     */
    constructor(address _owner) Ownable() {
        _transferOwnership(_owner);
    }

    /**
     * @notice Sets the proxy type for a given address. Only required for non-standard (legacy)
     *         proxy types.
     *
     * @param _address Address of the proxy.
     * @param _type    Type of the proxy.
     */
    function setProxyType(address _address, ProxyType _type) external onlyOwner {
        proxyType[_address] = _type;
    }

    /**
     * @notice Sets the implementation name for a given address. Only required for
     *         ResolvedDelegateProxy type proxies that have an implementation name.
     *
     * @param _address Address of the ResolvedDelegateProxy.
     * @param _name    Name of the implementation for the proxy.
     */
    function setImplementationName(address _address, string memory _name) external onlyOwner {
        implementationName[_address] = _name;
    }

    /**
     * @notice Set the address of the AddressManager. This is required to manage legacy
     *         ResolvedDelegateProxy type proxy contracts.
     *
     * @param _address Address of the AddressManager.
     */
    function setAddressManager(AddressManager _address) external onlyOwner {
        addressManager = _address;
    }

    /**
     * @custom:legacy
     * @notice Set an address in the address manager. Since only the owner of the AddressManager
     *         can directly modify addresses and the ProxyAdmin will own the AddressManager, this
     *         gives the owner of the ProxyAdmin the ability to modify addresses directly.
     *
     * @param _name    Name to set within the AddressManager.
     * @param _address Address to attach to the given name.
     */
    function setAddress(string memory _name, address _address) external onlyOwner {
        addressManager.setAddress(_name, _address);
    }

    /**
     * @custom:legacy
     * @notice Set the upgrading status for the Chugsplash proxy type.
     *
     * @param _upgrading Whether or not the system is upgrading.
     */
    function setUpgrading(bool _upgrading) external onlyOwner {
        upgrading = _upgrading;
    }

    /**
     * @custom:legacy
     * @notice Legacy function used to tell ChugSplashProxy contracts if an upgrade is happening.
     *
     * @return Whether or not there is an upgrade going on. May not actually tell you whether an
     *         upgrade is going on, since we don't currently plan to use this variable for anything
     *         other than a legacy indicator to fix a UX bug in the ChugSplash proxy.
     */
    function isUpgrading() external view returns (bool) {
        return upgrading;
    }

    /**
     * @notice Returns the implementation of the given proxy address.
     *
     * @param _proxy Address of the proxy to get the implementation of.
     *
     * @return Address of the implementation of the proxy.
     */
    function getProxyImplementation(address _proxy) external view returns (address) {
        ProxyType ptype = proxyType[_proxy];
        if (ptype == ProxyType.ERC1967) {
            return IStaticERC1967Proxy(_proxy).implementation();
        } else if (ptype == ProxyType.CHUGSPLASH) {
            return IStaticL1ChugSplashProxy(_proxy).getImplementation();
        } else if (ptype == ProxyType.RESOLVED) {
            return addressManager.getAddress(implementationName[_proxy]);
        } else {
            revert("ProxyAdmin: unknown proxy type");
        }
    }

    /**
     * @notice Returns the admin of the given proxy address.
     *
     * @param _proxy Address of the proxy to get the admin of.
     *
     * @return Address of the admin of the proxy.
     */
    function getProxyAdmin(address payable _proxy) external view returns (address) {
        ProxyType ptype = proxyType[_proxy];
        if (ptype == ProxyType.ERC1967) {
            return IStaticERC1967Proxy(_proxy).admin();
        } else if (ptype == ProxyType.CHUGSPLASH) {
            return IStaticL1ChugSplashProxy(_proxy).getOwner();
        } else if (ptype == ProxyType.RESOLVED) {
            return addressManager.owner();
        } else {
            revert("ProxyAdmin: unknown proxy type");
        }
    }

    /**
     * @notice Updates the admin of the given proxy address.
     *
     * @param _proxy    Address of the proxy to update.
     * @param _newAdmin Address of the new proxy admin.
     */
    function changeProxyAdmin(address payable _proxy, address _newAdmin) external onlyOwner {
        ProxyType ptype = proxyType[_proxy];
        if (ptype == ProxyType.ERC1967) {
            Proxy(_proxy).changeAdmin(_newAdmin);
        } else if (ptype == ProxyType.CHUGSPLASH) {
            L1ChugSplashProxy(_proxy).setOwner(_newAdmin);
        } else if (ptype == ProxyType.RESOLVED) {
            addressManager.transferOwnership(_newAdmin);
        } else {
            revert("ProxyAdmin: unknown proxy type");
        }
    }

    /**
     * @notice Changes a proxy's implementation contract.
     *
     * @param _proxy          Address of the proxy to upgrade.
     * @param _implementation Address of the new implementation address.
     */
    function upgrade(address payable _proxy, address _implementation) public onlyOwner {
        ProxyType ptype = proxyType[_proxy];
        if (ptype == ProxyType.ERC1967) {
            Proxy(_proxy).upgradeTo(_implementation);
        } else if (ptype == ProxyType.CHUGSPLASH) {
            L1ChugSplashProxy(_proxy).setStorage(
                // bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)
                0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc,
                bytes32(uint256(uint160(_implementation)))
            );
        } else if (ptype == ProxyType.RESOLVED) {
            string memory name = implementationName[_proxy];
            addressManager.setAddress(name, _implementation);
        } else {
            // It should not be possible to retrieve a ProxyType value which is not matched by
            // one of the previous conditions.
            assert(false);
        }
    }

    /**
     * @notice Changes a proxy's implementation contract and delegatecalls the new implementation
     *         with some given data. Useful for atomic upgrade-and-initialize calls.
     *
     * @param _proxy          Address of the proxy to upgrade.
     * @param _implementation Address of the new implementation address.
     * @param _data           Data to trigger the new implementation with.
     */
    function upgradeAndCall(address payable _proxy, address _implementation, bytes memory _data)
        external
        payable
        onlyOwner
    {
        ProxyType ptype = proxyType[_proxy];
        if (ptype == ProxyType.ERC1967) {
            Proxy(_proxy).upgradeToAndCall{value: msg.value}(_implementation, _data);
        } else {
            // reverts if proxy type is unknown
            upgrade(_proxy, _implementation);
            (bool success,) = _proxy.call{value: msg.value}(_data);
            require(success, "ProxyAdmin: call to proxy after upgrade failed");
        }
    }
}
