
/* global ethers task */
require('@nomiclabs/hardhat-waffle')

const fs = require('fs');
const privateKey = fs.readFileSync(".secret").toString().trim();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task('accounts', 'Prints the list of accounts', async () => {
  const accounts = await ethers.getSigners()

  for (const account of accounts) {
    console.log(account.address)
  }
})

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: '0.8.6',
  settings: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  },
  networks: {
    hardhat: {
      accounts: [{
        privateKey: privateKey,
        balance: '2000000000000000000000'
      }]
    },
    rinkeby: {
      url: ``,
      accounts: [privateKey]
    },
    ropsten: {
      url: ``,
      accounts: [privateKey]
    },
    moonbase: {
      url: 'https://rpc.api.moonbase.moonbeam.network',
      accounts: [privateKey]
    },
    milkomeda: {
      url: 'https://rpc-mainnet-cardano-evm.c1.milkomeda.com',
      accounts: [privateKey]
    },
    ethereum: {
      url: '',
      accounts: [privateKey]
    },
    binance: {

      url: '',
      accounts: [privateKey]
    },
    moonbeam: {

      url: '',
      accounts: [privateKey]

    },

    moonriver: {

      url: '',
      accounts: [privateKey]

    },

    polygon: {
      url: 'https://polygon-rpc.com',
      accounts: [privateKey]
    },
    klaytn: {

      url: '',
      accounts: [privateKey]
    }

  }
}
