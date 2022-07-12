// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import "./interface/proxy.sol";
contract Service {
    address public state;
    mapping(address=>address) public escrows;
    constructor(address _state) {
        state = _state;
    }

    modifier onlyEscrow(address addr) {
        require(escrows[addr] == msg.sender, "Invalid contract master");
        _;
    }

    modifier onlyNotEscrow(address addr) {
        require(escrows[addr] != msg.sender, "contract has alread escrowed");
        _;
    }

    function escrow(address acc) public onlyNotEscrow(acc) {
        IProxy proxy = IProxy(acc);
        address logic = proxy.setImplementation(state);
        proxy.escrow(logic);
        escrows[acc] = msg.sender;
    }

    function upgrade(address acc, address logic) public onlyEscrow(acc) {
        IProxy proxy = IProxy(acc);
        proxy.upgrade(logic);
    }

    function cancel(address acc) public onlyEscrow(acc) {
        IProxy proxy = IProxy(acc);
        proxy.cancel(msg.sender);
        delete escrows[acc];
    }
}