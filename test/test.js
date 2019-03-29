const testData = require("./testData.json");
const authData = require("../authData.json");
const orderManager = require('../build/contracts/OrderManager.json');
const buzzToken = require('../build/contracts/BuzzToken.json');
const {thorify} = require("thorify");
const Web3 = require("web3");
const web3 = thorify(new Web3(), "http://localhost:8669");
const addressRegistry = require("../build/addressRegistry");
const Promise = require("bluebird");

const fs = require("fs");
const path = require("path");

const TEST_PARTICIPANTS = [
    'brand-1',
    'brand-2',
    'brand-3',
    'brand-4',
    'brand-5',
    'brand-6',
    'brand-7',
    'brand-8',
    'brand-9',
    'brand-10'
];

const CONTRACT = new web3.eth.Contract(orderManager.abi, addressRegistry.orderManager);
const WALLET = new web3.eth.Contract(buzzToken.abi, addressRegistry.buzzToken);

const prepKeys = () => {
    web3.eth.accounts.wallet.add(authData.dropchain.PK);

    TEST_PARTICIPANTS.forEach(p => {
        web3.eth.accounts.wallet.add(testData[p].PK)
    });
};

const registerBrands = async () => {

    const createBrand = () => TEST_PARTICIPANTS.map(p => CONTRACT.methods.createBrand(testData[p].address, p).send({from: authData.dropchain.address}));

    const approveBuzz = () => TEST_PARTICIPANTS.map(p => WALLET.methods.approve(addressRegistry.orderManager, 999000000000000000000).send({from: testData[p].address}));

    console.log("Registering brands...");

    return Promise.all(createBrand())
        .then(() => Promise.all(approveBuzz())
            .then(() => console.log('Ok.')));

};

const writeToFile = async (entry, fileName) => {
    await fs.appendFileSync(
        path.join(__dirname, "out", `${fileName}.csv`),
        entry + '\r\n'
    );
};

const prepareTransactions = txCount => {
    const transactions = [];

    TEST_PARTICIPANTS.forEach(p => {
        for (let i = 1; i <= txCount; i++) {
            const before = Date.now();
            transactions.push(CONTRACT.methods.createUnit(`Test unit #${i}`)
                .send({from: testData[p].address})
                .then(resp => Date.now() - before)
                .catch(e => console.warn('Error', e.message, i)));
        }
    });

    return transactions;
};

const execute = (txCount, scenarioName) => {
    const before = Date.now();
    return Promise.all(prepareTransactions(txCount)).then(ms => {
        return writeToFile(`${ms}, ${Date.now() - before}`, scenarioName);
    });
};

const log = (transactions) => {
    console.timeEnd("intervalTest");
    console.log(transactions.length * TEST_PARTICIPANTS.length, "transactions");
};

const intervalTest = (caption = 'intervalTest') => {
    const transactions = [];
    return new Promise((resolve, reject) => {
        console.time(caption);

        transactions.push(execute(1,));
        const job = setInterval(() => transactions.push(execute(2, caption)), 1000);

        setTimeout(() => {
            clearInterval(job);
            Promise.all(transactions).then(() => {
                log(transactions);
                return resolve;
            }).catch(() => reject);
        }, 30000);
    });
};

const sequenceTest = async (caption = "sequenceTest") => {
    const sequence = [11, 9, 11, 9, 11, 11];
    console.time(caption);
    for (let i = 0; i <= sequence.length - 1; i++) {
        await execute(sequence[i], 'sequenceTest');
    }
    console.timeEnd(caption);
};

const test = async () => {
    prepKeys();

    await registerBrands();
    //await intervalTest();
    await sequenceTest();
};

test().then(() => console.log("Finished."));
