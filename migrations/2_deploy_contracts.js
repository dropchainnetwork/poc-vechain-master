//const OrderManager = artifacts.require("OrderManager");
const util = require("util");
const fs = require("fs");
const path = require("path");
const writeFile = util.promisify(fs.writeFile);

const {thorify} = require("thorify");
const Web3 = require("web3");
const abi = require('./build/contracts/OrderManager');
const web3 = thorify(new Web3(), "http://localhost:8669");

module.exports = async function(deployer) {
    const orderManager = await deployer.deploy(OrderManager);

    const addresses = {
        orderManager: OrderManager.address
    };

    await writeFile(
        path.join(__dirname, "..", "build", "addresses.json"),
        JSON.stringify(addresses)
    );
};