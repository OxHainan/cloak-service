// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

interface IStateFactory {
    function initialize(address logic) external;
    function changeAdmin() external;
    function upgrade(address logic) external;
    function cancel(address master, address logic) external;
    function updateState(bytes32[] calldata keys, bytes32[] calldata vals) external;
}