// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;
import "./interface/proxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ProxyFactory is Ownable {
    function getImplementation(IProxy proxy) public view virtual returns (address){
        // We need to manually run the static call since the getter cannot be flagged as view
        // bytes4(keccak256("implementation()")) == 0x5c60da1b
        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"5c60da1b");
        require(success);
        return abi.decode(returndata, (address));
    }

    function getAdmin(IProxy proxy) public view virtual returns (address) {
        // We need to manually run the static call since the getter cannot be flagged as view
        // bytes4(keccak256("admin()")) == 0xf851a440
        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"f851a440");
        require(success);
        return abi.decode(returndata, (address));
    }

    function changeAdmin(IProxy proxy, address newAdmin) public virtual onlyOwner {
        proxy.changeAdmin(newAdmin);
    }

    function upgrade(IProxy proxy, address implementation) public virtual onlyOwner {
        proxy.upgradeTo(implementation);
    }
}