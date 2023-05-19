// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import "./utils/StateStorage.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";
import "@openzeppelin/contracts/utils/Address.sol";

abstract contract State {
    using StateStorage for bytes32[];

    function _updateState(
        bytes32[] memory keys, 
        bytes32[] memory vals
    ) internal {
        keys.sstore(vals);
    }
}