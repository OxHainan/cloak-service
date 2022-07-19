const State = artifacts.require("StateFactory");
const Service = artifacts.require("Service");
const Logic1 = artifacts.require("Logic1");
const Logic2 = artifacts.require("Logic2");
const TransparentProxy = artifacts.require("TransparentProxy");

const _IMPLEMENTATION_SLOT = "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc";
const _ROLLBACK_SLOT = "0x2a7ee7a990a244bda6b8218d6cc50c824030ffcca1203a6c59bdca9cb30f9e58";
const _CODEHASH_SLOT = "0x300dd68656ddd8236e9e44b03078545b234db430495d4babec8803a5bbc813e2";
const _ADMIN_SLOT = "0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103";
const _EXECUTOR_SLOT = "0xb8348531df8271f8aede09ac451eebefaf9b4f564d3006bd336f1747c0d8d659";
const nil_address = "0x0000000000000000000000000000000000000000";
contract('CloakService', async (accounts) => {
    async function check_address(proxy, obser, target) {
        let res = await web3.eth.getStorageAt(proxy, obser);
        assert.equal(web3.utils.toChecksumAddress(res), target)
    }

    async function check_code(proxy, obser, target) {
        let codehash = await web3.eth.getStorageAt(proxy, obser);
        assert.equal(codehash, web3.utils.keccak256(target));
    }
    
    it('Test service', async () => {
        const proxy = await TransparentProxy.deployed();
        const service = await Service.deployed();
        await proxy.changeAdmin(await service.proxyFactory());
        await service.escrow(proxy.address);
        await check_address(proxy.address, _ADMIN_SLOT, await service.proxyFactory())
        await check_address(proxy.address, _EXECUTOR_SLOT, Service.address)
        await check_address(proxy.address, _ROLLBACK_SLOT, Logic1.address)
        await check_address(proxy.address, _IMPLEMENTATION_SLOT, State.address)
        assert.equal((await service.escrows(proxy.address)).master, accounts[0])
        await check_code(proxy.address, _CODEHASH_SLOT, await web3.eth.getCode(Logic1.address));
    })

    it('should update contract', async () => {
        const proxy = await TransparentProxy.deployed();
        const service = await Service.deployed();
        await service.upgrade(proxy.address, Logic2.address);
    })

    it("should cancel service", async () => {
        const proxy = await TransparentProxy.deployed();
        const service = await Service.deployed();
        await service.cancel(proxy.address);
        await check_address(proxy.address, _ADMIN_SLOT, accounts[0])
        await check_address(proxy.address, _IMPLEMENTATION_SLOT, Logic2.address)
        assert.equal((await service.escrows(proxy.address)).master, nil_address)
    });

    it("should escrow contract again", async () => {
        const logic = await Logic2.at(TransparentProxy.address);
        const proxy = await TransparentProxy.deployed();
        const service = await Service.deployed(); 
        await proxy.changeAdmin(await service.proxyFactory());
        await service.escrow(logic.address);
        await check_address(proxy.address, _ADMIN_SLOT, await service.proxyFactory())
        await check_address(proxy.address, _EXECUTOR_SLOT, Service.address)
        await check_address(proxy.address, _ROLLBACK_SLOT, Logic2.address)
        await check_address(proxy.address, _IMPLEMENTATION_SLOT, State.address)
        assert.equal((await service.escrows(logic.address)).master, accounts[0])
        await check_code(logic.address, _CODEHASH_SLOT, await web3.eth.getCode(Logic2.address));
    });

    it('should transfer owner ship', async () => {
        const service = await Service.deployed();
        assert(await service.owner() == accounts[0]);
        await service.transferOwnership(accounts[1]);
        assert(await service.owner() == accounts[1]);
        await service.transferOwnership(accounts[0], {from: accounts[1]});
    })

    it('should contract enchaned', async () => {
        const service = await Service.deployed();
        await service.privacyEnhancement(TransparentProxy.address);
        // await service.cancel(Proxy.address)
    })

    it("should update state to proxy", async () => {
        const state = await State.at(TransparentProxy.address);
        const service = await Service.deployed();
        let keys = new Array(3);
        let vals = new Array(keys.length);
        for (let i = 0; i < keys.length; i++)
        {
            vals[i] = await web3.eth.getStorageAt(state.address, i);
            vals[i] = web3.utils.leftPad(vals[i], 64);
            keys[i] = web3.utils.leftPad(i, 64);
        }

        let packed = web3.utils.encodePacked(vals[0], vals[1], vals[2]);
        let proof = web3.utils.keccak256(
            web3.utils.encodePacked(
                await web3.eth.getStorageAt(state.address, _CODEHASH_SLOT),
                web3.utils.keccak256(packed)
            ))
        
        for (let i = 0; i < vals.length; i++)
        {
            vals[i] = web3.utils.leftPad(i + 122, 64);
        }

        let request = await state.updateState.request(
            proof,
            keys, 
            vals
        )

        await service.registerNode(accounts[0])
        await service.updateState(request.to, request.data)

        for (let i = 0; i < vals.length; i++) {
            assert.equal(
                web3.utils.leftPad(await web3.eth.getStorageAt(state.address, keys[i]), 64),
                vals[i]
            )
        }
    })
});
