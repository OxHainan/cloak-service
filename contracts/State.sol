// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import "./utils/StorageSlot.sol";
import "./utils/Address.sol";
import "./utils/State.sol";

abstract contract BaseState {
    // this is the keccak 256 hash of "cloak.state.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x2a7ee7a990a244bda6b8218d6cc50c824030ffcca1203a6c59bdca9cb30f9e58;
    
    // this is the keccak 256 hash of "cloak.state.codehash" subtracted by 1
    bytes32 private constant _CODEHASH_SLOT = 0x300dd68656ddd8236e9e44b03078545b234db430495d4babec8803a5bbc813e2;
     
    bytes32 internal constant _ACCOUNT_HASH = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

    function _setRollBack(address account) internal {
        require(account != address(0), "BaseState: account is the zero address");
        StorageSlot.getAddressSlot(_ROLLBACK_SLOT).value = account;
    }

    function _getRoolBack() internal view returns(address) {
        return StorageSlot.getAddressSlot(_ROLLBACK_SLOT).value;
    }

    function _clearRollBackAndCodeHash() internal {
        StorageSlot.getBytes32Slot(_CODEHASH_SLOT).value = bytes32(0);
        StorageSlot.getAddressSlot(_ROLLBACK_SLOT).value = address(0);

    }

    function _setCodeHash(address account) internal {
        bytes32 codehash = Address.codehash(account);
        require(codehash != _ACCOUNT_HASH, "BaseState: account is a common address");
        StorageSlot.getBytes32Slot(_CODEHASH_SLOT).value = codehash;
    }

    function _getCodeHash() internal view returns(bytes32){
        return StorageSlot.getBytes32Slot(_CODEHASH_SLOT).value;
    }

    function _updateState(bytes32 proof, bytes32[] memory keys, bytes32[] memory vals) internal {
        bytes32 _proof = keccak256(abi.encodePacked(
            _getCodeHash(), State.compute_hash(keys)
        ));

        require(_proof == proof, "State: verification proof failed");
        State.sstore(keys, vals);
    }
}