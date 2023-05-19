// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;
import "./interface/IStateFactory.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract ProxyFactory is Ownable {

    string public name;
    constructor() {
        name = "Cloak Proxy Factory";
    }

    function upgradeAndChangeAdmin(
        address proxy
    ) public onlyOwner {
        IStateFactory(proxy).changeAdmin();
    }
}