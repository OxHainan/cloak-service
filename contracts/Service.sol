// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import "./interface/proxy.sol";
import "./Network.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./ProxyFactory.sol";

contract Service is Network {
    using Address for address;
    address public state;
    ProxyFactory factory;

    struct Escrow {
        address master;
        bool enhanced;
    }
    
    mapping(address=> Escrow) public escrows;
    constructor(address _state) {
        state = _state;
        factory = new ProxyFactory();
    }

    modifier onlyEscrow(address addr) {
        require(escrows[addr].master == msg.sender, 
            "Service: caller is not the escrow master");
        _;
    }

    modifier onlyNotEscrow(address addr) {
        require(escrows[addr].master != msg.sender, 
            "Service: contract has alread escrowed");
        _;
    }

    modifier onlyNotEnhanced(address addr) {
        require(escrows[addr].enhanced == false, "Service: escrow enchaned become effective");
        _;
    }

    function proxyFactory() public view returns(address) {
        return address(factory);
    }

    function escrow(
        IProxy proxy
    ) public onlyNotEscrow(address(proxy)) {
        address logic = factory.getImplementation(proxy);
        require(logic != state, "Service: contract escrow should be after implementated");
        require (factory.getAdmin(proxy) == address(factory), 
            "Service: please complete changeAdmin in proxy first");
            
        factory.upgrade(proxy, state);
        proxy.escrow(logic);
        escrows[address(proxy)] = Escrow(msg.sender, false);
    }

    function privacyEnhancement(address proxy) public onlyEscrow(proxy) onlyNotEnhanced(proxy) {
        escrows[proxy].enhanced = true;
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
    ) public onlyEscrow(address(proxy)) onlyNotEnhanced(address(proxy)) {
        proxy.cancel(msg.sender);
        delete escrows[address(proxy)];
    }

    function updateState(
        address proxy, 
        bytes memory data
    ) public onlyActive {
        if (escrows[proxy].master != address(0)) {
            proxy.functionCall(data);
        }
    }

    function updateState(
        address[] memory proxy, 
        bytes[] memory data
    ) public {
        require(proxy.length == data.length, 
            "Service: both length not equal");

        for(uint8 i = 0; i < proxy.length; i++) {
            updateState(proxy[i], data[i]);
        }
    }
}