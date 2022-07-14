// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import "./utils/StorageSlot.sol";
import "./utils/Address.sol";
abstract contract Proxy {
    // this is the keccak 256 hash of "cloak.proxy.master" subtracted by 1
    bytes32 private constant _MASTER_SLOT = 0x302d5a897102d13e0d906d81acedf7bb60726548606cbf8d04bc3a235dbfaf53;
    // this is the keccak 256 hash of "cloak.proxy.implementation" subtracted by 1
    bytes32 private constant _IMPLEMENTATION_SLOT = 0x5596e004f64113a6e801fc456673223a03c6c2e9c667b1b67d1c5c1a307ea3c3;

    function _getImplementation() internal view returns(address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) internal {
        require(Address.isContract(newImplementation), 
            "proxy: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function _getMaster() internal view returns(address) {
        return StorageSlot.getAddressSlot(_MASTER_SLOT).value;
    }

    function _setMaster(address newMaster) internal {
        require(newMaster != address(0), "proxy: new master is the zero address");
        StorageSlot.getAddressSlot(_MASTER_SLOT).value = newMaster;
    }

    modifier onlyMaster() {
        require(_getMaster() == msg.sender, "proxy: caller is not the master");
        _;
    }

    modifier onlyMaster2() {
        require(_getMaster() == tx.origin, "proxy: caller is not the master");
        _;
    }

    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _fallback() internal {
        _delegate(_getImplementation());
    }

    fallback() external {
        _fallback();
    }
}