// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import "./StateFactory.sol";
import "./ProxyFactory.sol";
import "./ProxyBridge.sol";
import "./Network.sol";
import "./interface/IStateFactory.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Service is Network {
    using Address for address;
    ProxyFactory _proxyFactory;
    StateFactory _stateFactory;
    ProxyBridge _proxyBridge;

    struct Escrow {
        address master;
        bool enhanced;
    }
    
    mapping(address=> Escrow) public escrows;

    constructor() {
        _stateFactory = new StateFactory();
        _proxyFactory = new ProxyFactory();
        _proxyBridge = new ProxyBridge(address(_proxyFactory));
    }

    modifier onlyEscrow(address addr) {
        require(escrows[addr].master == msg.sender, 
            "Service: caller is not the escrow master");
        _;
    }

    modifier onlyNotEscrow(address proxy) {
        require(escrows[proxy].master != msg.sender, 
            "Service: contract has alread escrowed");
        _;
    }

    modifier onlyNotEnhanced(address addr) {
        require(escrows[addr].enhanced == false, 
            "Service: escrow enchaned become effective");
        _;
    }

    function proxyFactory() public view returns(address) {
        return address(_proxyFactory);
    }

    function stateFactory() public view returns(address) {
        return address(_stateFactory);
    }

    function proxyBridge() public view returns(address) {
        return address(_proxyBridge);
    }

    function escrow(
        address proxy, address implementation
    ) public onlyNotEscrow(proxy) {
        _proxyFactory.upgradeAndChangeAdmin(proxy, stateFactory());
        IStateFactory(proxy).initialize(implementation);
        escrows[proxy] = Escrow(msg.sender, false);
    }

    function privacyEnhancement(
        address proxy
    ) public onlyEscrow(proxy) onlyNotEnhanced(proxy) {
        escrows[proxy].enhanced = true;
    }

    // (TODO) Wait for all state synchronization to complete
    function upgrade(
        address proxy, 
        address logic
    ) public onlyEscrow(proxy) {
        IStateFactory(proxy).upgrade(logic);
    }

    // (TODO) Wait for all state synchronization to complete
    function cancel(
        address proxy
    ) public onlyEscrow(proxy) onlyNotEnhanced(proxy) {
        IStateFactory(proxy).cancel(msg.sender);
        delete escrows[proxy];
    }

    function updateState(
        address proxy, 
        bytes memory data
    ) public onlyActive onlyEscrow(proxy) {
        proxy.functionCall(data);
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