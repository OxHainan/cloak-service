// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import "./State.sol";
import "./utils/EIP1967.sol";

contract StateFactory is State, EIP1967 {
    address immutable public proxyFactory;
    address immutable public executor;
    string constant public name = "Cloak Proxy Bridge";

    constructor(address _proxyFactory, address _executor) {
        proxyFactory = _proxyFactory;
        executor = _executor;
    }

    modifier onlyFactorier() {
        require(proxyFactory == msg.sender, "ProxyBridge: caller is forbidden");
        _;
    }

    function changeAdmin() external onlyFactorier{
        require(super._getAdmin() == tx.origin, "ProxyBridge: caller is not origin admin");
        super._changeAdmin(proxyFactory);
    }

    function updateState(
        bytes32[] memory keys, 
        bytes32[] memory vals
    ) external onlyExecutor {
        super._updateState(keys, vals);
    }

    modifier onlyExecutor() {
        require(executor== msg.sender, "State: caller is not the executor");
        _;
    }

    function cancel(address master, address logic) external onlyExecutor {
        require(logic != address(0), 
            "StateFactory: logic is the zero address");

        super._setImplementation(logic);
        super._changeAdmin(master);
    }
}