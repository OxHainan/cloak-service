// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import "./State.sol";
import "./Proxy.sol";

contract StateFactory is BaseState, Proxy {
    function updateState(
        bytes32 proof, 
        bytes32[] memory keys, 
        bytes32[] memory vals
    ) external onlyMaster {
        super._updateState(proof, keys, vals);
    }

    function escrow(address logic) external onlyMaster2 {
        require(super._getRollBack() != logic, 
            "StateFactory: the same as contract or not implementated");
        
        super._setRollBack(logic);
        super._setCodeHash(logic);
        super._setMaster(msg.sender);
    }

    function upgrade(address logic) external onlyMaster {
        require(super._getRollBack() != logic, 
            "StateFactory: new contract should be different");

        super._setRollBack(logic);
        super._setCodeHash(logic);
    }

    function cancel(address master) external onlyMaster {
        address logic = super._getRollBack();
        require(logic != address(0), 
            "StateFactory: logic is the zero address");

        super._setImplementation(logic);
        super._setMaster(master);
        super._clearRollBackAndCodeHash();
    }
}