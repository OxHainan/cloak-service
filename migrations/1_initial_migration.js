const State = artifacts.require("StateFactory");
const MyCoinProxy = artifacts.require("ProxyFactory");
const Service = artifacts.require("Service");
const Logic1 = artifacts.require("Logic1");
const Logic2 = artifacts.require("Logic2");


module.exports = async function (deployer) {
    await  deployer.deploy(MyCoinProxy);
    await deployer.deploy(Logic1);
    await deployer.deploy(State);
    await deployer.deploy(Service, State.address)
    await deployer.deploy(Logic2)
};
