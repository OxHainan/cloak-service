// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

interface IProxy
{
    function upgradeTo(address newImplementation) external;
    function transferAdminShip() external;
    function initialize(address logic) external;
    function upgrade(address logic) external;
    function cancel(address master) external;
}