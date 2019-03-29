const authData = require("./authData.json");
const orderManager = require('./build/contracts/OrderManager.json');
const buzzToken = require('./build/contracts/BuzzToken.json');
const {thorify} = require("thorify");
const Web3 = require("web3");
const web3 = thorify(new Web3(), "http://localhost:8669");


const fs = require("fs");
const path = require("path");

web3.eth.accounts.wallet.add(web3.eth.accounts.privateKeyToAccount(authData['dropchain'].PK));

const deploy = async () => {
    const writeToFile = async (entry) => {
        await fs.writeFileSync(
            path.join(__dirname, "build", "addressRegistry.json"),
            JSON.stringify(entry)
        );
    };

    const erc20 = await new web3.eth.Contract(buzzToken.abi).deploy({
        data: buzzToken.bytecode
    }).send({
        from: authData['dropchain'].address
    });

    const om = await new web3.eth.Contract(orderManager.abi).deploy({
        data: orderManager.bytecode,
        arguments: [erc20.options.address]
    }).send({
        from: authData['dropchain'].address
    });

    await writeToFile({
        orderManager: om.options.address,
        buzzToken: erc20.options.address,
    });
};

deploy();
