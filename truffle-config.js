module.exports = {
  mocha: {
    reporter: 'eth-gas-reporter',
  },
  contracts_build_directory: './build/contracts',
  networks: {
    ganache: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '*',
      gasPrice: 100000000000,
      gas: 10000000,
      disableConfirmationListener: true,
    },
  },
  compilers: {
    solc: {
      version: '0.7.5',
      settings: {
        optimizer: {
          enabled: true,
          runs: 125,
        },
        evmVersion: 'istanbul',
      },
    },
  },
  plugins: ['solidity-coverage', 'truffle-contract-size'],
}
