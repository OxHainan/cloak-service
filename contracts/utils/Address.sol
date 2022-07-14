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

    function functionCall(
        address target, 
        bytes memory data
    ) internal returns(bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target, 
        bytes memory data, 
        string memory errorMessage
    ) internal returns(bytes memory) {
        (bool success, bytes memory returndata) = target.call{value: 0}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success, 
        bytes memory returndata, 
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        }

        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
