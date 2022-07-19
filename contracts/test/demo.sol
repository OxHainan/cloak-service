// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract TransparentProxy is TransparentUpgradeableProxy {
    constructor(
        address _logic,
        address admin_
    ) payable TransparentUpgradeableProxy(_logic, admin_, "") {

    }
}

contract Logic1 {
    uint a;
    function set(uint i) public {
        a += i;
    }

    function get() public view returns(uint) {
        return a;
    }
}

contract Logic2 {
    uint a;
    uint b;
    function set(uint i) public {
        a += i;
        b += a;
    }

    function get() public view returns(uint) {
        return a;
    }
}