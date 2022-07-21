// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import "./utils/StateStorage.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";
import "@openzeppelin/contracts/utils/Address.sol";

abstract contract State {
    using StateStorage for bytes32[];
    // this is the keccak 256 hash of "cloak.state.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x2a7ee7a990a244bda6b8218d6cc50c824030ffcca1203a6c59bdca9cb30f9e58;
    
    // this is the keccak 256 hash of "cloak.state.codehash" subtracted by 1
    bytes32 private constant _CODEHASH_SLOT = 0x300dd68656ddd8236e9e44b03078545b234db430495d4babec8803a5bbc813e2;
    
    // this is the keccak 256 hash of "cloak.state.executor" subtracted by 1
    bytes32 private constant _EXECUTOR_SLOT = 0xb8348531df8271f8aede09ac451eebefaf9b4f564d3006bd336f1747c0d8d659;

    bytes32 private constant _ACCOUNT_HASH = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

    function _setRollBack(address account) internal {
        require(account != address(0), "BaseState: account is the zero address");
        StorageSlot.getAddressSlot(_ROLLBACK_SLOT).value = account;
    }

    function _getRollBack() internal view returns(address) {
        return StorageSlot.getAddressSlot(_ROLLBACK_SLOT).value;
    }

    function _setExecutor(address account) internal {
        require(account != address(0), "BaseState: account is the zero address");
        StorageSlot.getAddressSlot(_EXECUTOR_SLOT).value = account;
    }

    function _getExecutor() internal view returns(address) {
        return StorageSlot.getAddressSlot(_EXECUTOR_SLOT).value;
    }

    modifier onlyExecutor() {
        require(_getExecutor() == msg.sender, "State: caller is not the executor");
        _;
    }

    modifier onlyInitialized() {
        require(_getExecutor() == address(0), "StateFactory: executor has already setting");
        _;
    }

    function _clearRollBackAndCodeHash() internal {
        StorageSlot.getBytes32Slot(_CODEHASH_SLOT).value = bytes32(0);
        StorageSlot.getAddressSlot(_ROLLBACK_SLOT).value = address(0);
        StorageSlot.getAddressSlot(_EXECUTOR_SLOT).value = address(0);
    }

    function _setCodeHash(address account) internal {
        bytes32 codehash;
        assembly {
            codehash := extcodehash(account)
        }
        require(codehash != _ACCOUNT_HASH, 
            "BaseState: account is a common address");
        StorageSlot.getBytes32Slot(_CODEHASH_SLOT).value = codehash;
    }

    function _getCodeHash() internal view returns(bytes32){
        return StorageSlot.getBytes32Slot(_CODEHASH_SLOT).value;
    }

    function _updateState(
        bytes32 proof, 
        bytes32[] memory keys, 
        bytes32[] memory vals
    ) internal {
        bytes32 _proof = keccak256(abi.encodePacked(
            _getCodeHash(), keys.generateStateHash()
        ));

        require(_proof == proof, "State: verification proof failed");
        keys.sstore(vals);
    }
}