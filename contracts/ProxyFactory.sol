// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import "./Proxy.sol";

contract ProxyFactory is Proxy {
    constructor() {
        super._setMaster(msg.sender);
    }

    function setImplementation(address newImplementation) external onlyMaster2 returns (address oldImplementation) {
        oldImplementation = super._getImplementation();
        super._setImplementation(newImplementation);
    }
}