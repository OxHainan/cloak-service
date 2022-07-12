// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

library State {
    
    function sload(bytes32 key) private view returns(bytes32 v) {
        assembly {
            v := sload(key)
        }
    }

    function compute_hash(bytes32[] memory keys) internal view returns(bytes32 hash) {
        bytes32[] memory v = new bytes32[](keys.length);
        for (uint128 i= 0; i<keys.length; i++) {
            v[i] = sload(keys[i]);
        }

        return keccak256(abi.encodePacked(v));
    }

    function sstore(bytes32 key, bytes32 val) private {
        assembly {
            sstore(key, val)
        }
    }

    function sstore(bytes32[] memory key, bytes32[] memory val) internal {
        for (uint i=0; i<key.length; i++) {
            sstore(key[i], val[i]);
        }
    }
}