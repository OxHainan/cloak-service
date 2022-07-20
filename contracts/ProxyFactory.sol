// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;
import "./interface/proxy.sol";
import "./utils/EIP1967Protocol.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ProxyBridge is EIP1967Protocol {
    address immutable public proxyFactory;

    // this is the keccak 256 hash of "cloak.state.bridge" subtracted by 1
    bytes32 private constant _BRIDGE_SLOT = 0x2a7ee7a990a244bda6b8218d6cc50c824030ffcca1203a6c59bdca9cb30f9e58;

    constructor(address _proxyFactory) {
        proxyFactory = _proxyFactory;
    }

    modifier onlyFactorier() {
        require(proxyFactory == msg.sender, "ProxyBridge: caller is forbidden");
        _;
    }

    function transferAdminShip() external onlyFactorier {
        super._setAdmin(proxyFactory);
        _setBridge(msg.sender);
    }

    function _setBridge(address account) internal {
        require(account != address(0), "ProxyBridge: account is the zero address");
        StorageSlot.getAddressSlot(_BRIDGE_SLOT).value = account;
    }
}

contract ProxyFactory is Ownable {
    function getImplementation(IProxy proxy) public view virtual returns (address){
        // We need to manually run the static call since the getter cannot be flagged as view
        // bytes4(keccak256("implementation()")) == 0x5c60da1b
        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"5c60da1b");
        require(success, "ProxyFactory: caller is not admin");
        return abi.decode(returndata, (address));
    }

    function getAdmin(IProxy proxy) public view virtual returns (address) {
        // We need to manually run the static call since the getter cannot be flagged as view
        // bytes4(keccak256("admin()")) == 0xf851a440
        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"f851a440");
        require(success, "ProxyFactory: caller is not admin");
        return abi.decode(returndata, (address));
    }

    function transferAdminShip(IProxy proxy) external onlyOwner {
        proxy.transferAdminShip();
    }

    function upgrade(IProxy proxy, address implementation) public virtual onlyOwner {
        proxy.upgradeTo(implementation);
    }
}