// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;
import "./utils/EIP1967Protocol.sol";
contract ProxyBridge is EIP1967Protocol {
    address immutable public proxyFactory;
    // string immutable public name;

    constructor(address _proxyFactory) {
        proxyFactory = _proxyFactory;
        // name = "Cloak Proxy Bridge";
    }

    modifier onlyFactorier() {
        require(proxyFactory == msg.sender, "ProxyBridge: caller is forbidden");
        _;
    }

    function upgradeAndChangeAdmin(address newImplementation) external onlyFactorier {
        require(super._getAdmin() == tx.origin, "ProxyBridge: caller is not origin admin");
        super._changeAdmin(proxyFactory);
        super._setImplementation(newImplementation);
    }
}
