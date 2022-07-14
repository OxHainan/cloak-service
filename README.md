<p align="center">
    <h1 align="center">
      Cloak Service
    </h1>
</p>

<div align="center">
    <h4>
        <a href="/CONTRIBUTING.md">
            👥 Contributing
        </a>
        <span>&nbsp;&nbsp;|&nbsp;&nbsp;</span>
        <a href="/CODE_OF_CONDUCT.md">
            🤝 Code of conduct
        </a>
        <span>&nbsp;&nbsp;|&nbsp;&nbsp;</span>
        <a href="https://github.com/OxHainan/cloak-service/contribute">
            🔎 Issues
        </a>
        <!-- <span>&nbsp;&nbsp;|&nbsp;&nbsp;</span>
        <a href="https://t.me/joinchat/B-PQx1U3GtAh--Z4Fwo56A">
            🗣️ Chat &amp; Support
        </a> -->
    </h4>
</div>

| Cloak service is a protocol, designed to be a brige between Ethereum and the Cloak Network. |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |

The core of the Cloak service protocol is to complete the functions of on-chain hosting and synchronization of user contracts in Ethereum. Furthermore, Cloak service also provides [Proxy Contract](/contracts/ProxyFactory.sol) to make the steps for joining our cloak network easier. To learn more about Cloak visit [Cloak docs](https://cloak-docs.readthedocs.io/en/latest/).


---

## 🛠 Install

Clone this repository:

```bash
git clone https://github.com/OxHainan/cloak-service.git
```

and make sure the following dependencies have been installed
```bash
npm install -g truffle ganache-cli
```

## 📜 Usage

### Compile contracts

```bash
truffle compile
```

### Testing

```bash
truffle test
```

### Deploy contracts

```bash
truffle migrate
```

### Contract Escrow

From the user contract, the user can join the cloak using the following operations:

```solidity
contract Demo {
    uint a;
    function set(uint i) public {
        a += i;
    }

    function get() public view returns(uint) {
        return a;
    }
}
```

After deploying the contract, bind the demo contract's address to the proxy contract.

```javascript
proxy.setImplementation(demo.address);
```

by the way, cloak service also provides a quick way to create proxy generic contract, get it:

```javascript
service.createNewProxy()
```
If you want to join the cloak network, you can initiate an escrow transaction in our service contract.

```javascript
service.escrow(proxy.address)
```

Now, the demo contract has completed contract escrow.