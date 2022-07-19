// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import "./State.sol";
import "./utils/EIP1967Protocol.sol";

contract StateFactory is BaseState, EIP1967Protocol {
    function updateState(
        bytes32 proof, 
        bytes32[] memory keys, 
        bytes32[] memory vals
    ) external onlyExecutor {
        super._updateState(proof, keys, vals);
    }

    function escrow(address logic) external onlyInitialized {
        require(super._getRollBack() != logic, 
            "StateFactory: the same as contract or not implementated");
        
        super._setRollBack(logic);
        super._setCodeHash(logic);
        super._setExecutor(msg.sender);
    }

    function setExecutor(address executor) external{
        require(_getExecutor() == address(0), "StateFactory: executor has already setting");
        _setExecutor(executor);
    }

    function upgrade(address logic) external onlyExecutor {
        require(super._getRollBack() != logic, 
            "StateFactory: new contract should be different");

        super._setRollBack(logic);
        super._setCodeHash(logic);
    }

    function cancel(address master) external onlyExecutor {
        address logic = super._getRollBack();
        require(logic != address(0), 
            "StateFactory: logic is the zero address");

        super._setImplementation(logic);
        super._setAdmin(master);
        super._clearRollBackAndCodeHash();
    }
}