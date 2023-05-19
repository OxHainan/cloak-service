// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import "./StateFactory.sol";
import "./ProxyFactory.sol";
import "./Network.sol";
import "./interface/IStateFactory.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Service is Network {
    using Address for address;
    ProxyFactory _proxyFactory;
    StateFactory _stateFactory;

    struct Escrow {
        address master;
        bool enhanced;
        address logic;
    }
    
    mapping(address=> Escrow) public escrows;

    constructor() {
        _proxyFactory = new ProxyFactory();
        _stateFactory = new StateFactory(address(_proxyFactory), address(this));
    }

    modifier onlyEscrow(address proxy) {
        require(escrows[proxy].master == msg.sender, 
            "Service: caller is not the escrow master");
        _;
    }

    modifier onlyNotEscrow(address proxy) {
        require(escrows[proxy].master != msg.sender, 
            "Service: contract has alread escrowed");
        _;
    }

    modifier onlyNotEnhanced(address proxy) {
        require(escrows[proxy].enhanced == false, 
            "Service: escrow enchaned become effective");
        _;
    }

    function proxyFactory() public view returns(address) {
        return address(_proxyFactory);
    }

    function stateFactory() public view returns(address) {
        return address(_stateFactory);
    }

    function escrow(
        address proxy, address implementation
    ) public onlyNotEscrow(proxy) {
        require(proxy != implementation, "Service: implementation cannot be proxy");
        _proxyFactory.upgradeAndChangeAdmin(proxy);
        escrows[proxy] = Escrow(msg.sender, false, implementation);
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
        escrows[proxy].logic = logic;
    }

    // (TODO) Wait for all state synchronization to complete
    function cancel(
        address proxy
    ) public onlyEscrow(proxy) onlyNotEnhanced(proxy) {
        IStateFactory(proxy).cancel(msg.sender, escrows[proxy].logic);
        delete escrows[proxy];
    }

    function updateState(
        address proxy, 
        bytes memory data,
        bool isCancel
    ) public onlyActive {
        require(escrows[proxy].master != address(0), "Service: contract is not escrows");
        proxy.functionCall(data);
        if (isCancel) {
            cancel(proxy);
        }
    }

    function updateState(
        address proxy, 
        bytes memory data
    ) public onlyActive {
        require(escrows[proxy].master != address(0), "Service: contract is not escrows");
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