// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

interface IProxy
{
    function setImplementation(address newImplementation) external returns(address);
    function escrow(address logic) external;
    function upgrade(address logic) external;
    function cancel(address master) external;
}