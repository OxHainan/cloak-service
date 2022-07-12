// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

library Address {
   
    function codehash(address account) internal view returns(bytes32 hash) {
        assembly {
            hash := extcodehash(account)
        }
    }

    function isContract(address account) internal view returns(bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}
