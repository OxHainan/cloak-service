// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import "./interface/proxy.sol";
import "./Network.sol";
import "./utils/Address.sol";

contract Service is Network {
    using Address for address;
    address public state;
    mapping(address=>address) public escrows;
    constructor(address _state) {
        state = _state;
    }

    modifier onlyEscrow(address addr) {
        require(escrows[addr] == msg.sender, 
            "Service: caller is not the escrow master");
        _;
    }

    modifier onlyNotEscrow(address addr) {
        require(escrows[addr] != msg.sender, 
            "Service: contract has alread escrowed");
        _;
    }

    function escrow(
        IProxy proxy
    ) public onlyNotEscrow(address(proxy)) {
        address logic = proxy.setImplementation(state);
        proxy.escrow(logic);
        escrows[address(proxy)] = msg.sender;
    }

    // (TODO) Wait for all state synchronization to complete
    function upgrade(
        IProxy proxy, 
        address logic
    ) public onlyEscrow(address(proxy)) {
        proxy.upgrade(logic);
    }

    // (TODO) Wait for all state synchronization to complete
    function cancel(
        IProxy proxy
    ) public onlyEscrow(address(proxy)) {
        proxy.cancel(msg.sender);
        delete escrows[address(proxy)];
    }

    function updateState(
        address proxy, 
        bytes memory data
    ) public onlyActive {
        if (escrows[proxy] != address(0)) {
            proxy.functionCall(data);
        }
    }

    function updateState(
        address[] memory proxy, 
        bytes[] memory data
    ) public  {
        require(proxy.length == data.length, 
            "Service: both length not equal");

        for(uint8 i = 0; i < proxy.length; i++) {
            updateState(proxy[i], data[i]);
        }
    }
}