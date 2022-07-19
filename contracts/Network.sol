// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract Network is Ownable {
    struct Node {
        bool active;
        uint64 registerTime;
    }

    mapping(address => bool) public isRegistered;
    mapping(address => Node) public nodes;

    modifier whenRegister(address node) {
        require(isRegistered[node], "Network: node no registered");
        _;
    }

    modifier whenNotRegister(address node) {
        require(isRegistered[node]== false, "Network: node has already registered");
        _;
    }

    modifier onlyActive() {
        require(nodes[msg.sender].active, "Network: node is inactive");
        _;
    }

    function registerNode(address node) public onlyOwner whenNotRegister(node) {
        isRegistered[node] = true;
        nodes[node] = Node(true, uint64(block.timestamp));
    }

    function removeNode(address node) public onlyOwner whenRegister(node) {
        delete nodes[node];
        delete isRegistered[node];
    }

    function updateNode(address node, bool active) public onlyOwner whenRegister(node) {
        require(nodes[node].active != active, "Network: cannot update node");
        nodes[node].active = active;
    }
}