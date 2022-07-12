const State = artifacts.require("StateFactory");
const Proxy = artifacts.require("ProxyFactory");
const Service = artifacts.require("Service");
const Logic1 = artifacts.require("Logic1");
const Logic2 = artifacts.require("Logic2");

const _ESCROW_SLOT = "0x5596e004f64113a6e801fc456673223a03c6c2e9c667b1b67d1c5c1a307ea3c3";
const _LOGIC_SLOT = "0x2a7ee7a990a244bda6b8218d6cc50c824030ffcca1203a6c59bdca9cb30f9e58";
const _CODEHASH_SLOT = "0x300dd68656ddd8236e9e44b03078545b234db430495d4babec8803a5bbc813e2";
const _MASTER_SLOT = "0x302d5a897102d13e0d906d81acedf7bb60726548606cbf8d04bc3a235dbfaf53";
const nil_address = "0x0000000000000000000000000000000000000000";
contract('CloakService', async (accounts) => {
    // it('Test challenge and response', async () => {
    //     const proxy = await MyCoinProxy.deployed();
    //     const state = await State.at(proxy.address);
    //     const logic = await MyCoinData.at(proxy.address)
    //     await proxy.setLogicContractAddr(State.address);
    //     await state.verify_escrow(MyCoinData.address);
    //     assert.equal(await proxy.getLogicAddress(), State.address)
    //     await state.set_states([3], [2]);
        
    //     await proxy.setLogicContractAddr(MyCoinData.address);
    //     assert.equal(await logic.get(), 2);

    //     await logic.set(127);
    //     // await proxy.setLogicContractAddr(State.address);
    // });
    async function check_address(proxy, obser, target) {
        let res = await web3.eth.getStorageAt(proxy, obser);
        assert.equal(web3.utils.toChecksumAddress(res), target)
    }

    async function check_code(proxy, obser, target) {
        let codehash = await web3.eth.getStorageAt(proxy, obser);
        assert.equal(codehash, web3.utils.keccak256(target));
    }
    
    it('Test service', async () => {
        const proxy = await Proxy.deployed();
        const service = await Service.deployed();
        await proxy.setImplementation(Logic1.address);
        await service.escrow(proxy.address);
        await check_address(proxy.address, _MASTER_SLOT, service.address)
        await check_address(proxy.address, _LOGIC_SLOT, Logic1.address)
        await check_address(proxy.address, _ESCROW_SLOT, State.address)
        assert.equal(await service.escrows(proxy.address), accounts[0])
        await check_code(proxy.address, _CODEHASH_SLOT, await web3.eth.getCode(Logic1.address));
    })

    it('should update contract', async () => {
        const proxy = await Proxy.deployed();
        const service = await Service.deployed();
        await service.upgrade(proxy.address, Logic2.address);
    })

    it("should cancel service", async () => {
        const proxy = await Proxy.deployed();
        const service = await Service.deployed();
        await service.cancel(proxy.address);
        await check_address(proxy.address, _MASTER_SLOT, accounts[0])
        await check_address(proxy.address, _ESCROW_SLOT, Logic2.address)
        assert.equal(await service.escrows(proxy.address), nil_address)

    })
});
