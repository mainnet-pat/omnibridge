module.exports = {
  contracts_directory: "./precompiled/*.sol",
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
      version: '0.4.24',
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        },
      },
    },
  },
  plugins: ['solidity-coverage', 'truffle-contract-size'],
}
