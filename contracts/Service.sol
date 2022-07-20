// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import "./interface/proxy.sol";
import "./Network.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./ProxyFactory.sol";
import "./StateFactory.sol";

contract Service is Network {
    using Address for address;
    address public state;
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
        return address(_proxyFactory);
    }

    function stateFactory() public view returns(address) {
        return address(_stateFactory);
    }

    function proxyBridge() public view returns(address) {
        return address(_proxyBridge);
    }

    function escrow(
        IProxy proxy, address implementation
    ) public onlyNotEscrow(address(proxy)) {
        _proxyFactory.transferAdminShip(proxy);
        address logic = _proxyFactory.getImplementation(proxy);
        require(logic != address(0), "Service: escrow should be after implementated");
        require(logic != stateFactory(), "Service: contract has alread escrowed");

        require (_proxyFactory.getAdmin(proxy) == proxyFactory(), 
            "Service: please complete changeAdmin in proxy first");
        
        _proxyFactory.upgrade(proxy, stateFactory());
        proxy.initialize(implementation);
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

    fallback() external {
        bytes memory _data = msg.data;
        address proxy;
        assembly {
            proxy := mload(add(_data, 0x14))
        }

        address admin = _proxyFactory.getAdmin(IProxy(proxy));
        require(admin == proxyFactory(), "Service: incomplete admin transfer");
    }
}