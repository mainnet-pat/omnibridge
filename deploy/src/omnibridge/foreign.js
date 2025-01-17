const { web3Foreign, deploymentAddress } = require('../web3')
const { deployContract, upgradeProxy } = require('../deploymentUtils')
const {
  EternalStorageProxy,
  ForeignOmnibridge,
  PermittableToken,
  TokenFactory,
  SelectorTokenGasLimitManager,
  WETHOmnibridgeRouter,
} = require('../loadContracts')

const {
  FOREIGN_TOKEN_FACTORY,
  FOREIGN_ERC677_TOKEN_IMAGE,
  FOREIGN_BRIDGE_OWNER,
  FOREIGN_TOKEN_NAME_SUFFIX,
  FOREIGN_AMB_BRIDGE,
  FOREIGN_MEDIATOR_REQUEST_GAS_LIMIT,
  FOREIGN_WETH_ADDRESS,
} = require('../loadEnv')

async function deployForeign() {
  let nonce = await web3Foreign.eth.getTransactionCount(deploymentAddress)

  console.log('\n[Foreign] Deploying Bridge Mediator storage\n')
  const foreignBridgeStorage = await deployContract(EternalStorageProxy, [], {
    network: 'foreign',
    nonce: nonce++,
  })
  console.log('[Foreign] Bridge Mediator Storage: ', foreignBridgeStorage.options.address)

  let tokenFactory = FOREIGN_TOKEN_FACTORY
  if (!tokenFactory) {
    let foreignTokenImage = FOREIGN_ERC677_TOKEN_IMAGE
    if (!foreignTokenImage) {
      console.log('\n[Foreign] Deploying new ERC677 token image')
      const chainId = await web3Foreign.eth.getChainId()
      const erc677token = await deployContract(PermittableToken, ['', '', 0, chainId], {
        network: 'foreign',
        nonce: nonce++,
      })
      foreignTokenImage = erc677token.options.address
      console.log('\n[Foreign] New ERC677 token image has been deployed: ', foreignTokenImage)
    } else {
      console.log('\n[Foreign] Using existing ERC677 token image: ', foreignTokenImage)
    }
    console.log('\n[Foreign] Deploying new token factory')
    const factory = await deployContract(TokenFactory, [FOREIGN_BRIDGE_OWNER, foreignTokenImage], {
      network: 'foreign',
      nonce: nonce++,
    })
    tokenFactory = factory.options.address
    console.log('\n[Foreign] New token factory has been deployed: ', tokenFactory)
  } else {
    console.log('\n[Foreign] Using existing token factory: ', tokenFactory)
  }

  console.log(`\n[Foreign] Deploying gas limit manager contract with the following parameters:
    FOREIGN_AMB_BRIDGE: ${FOREIGN_AMB_BRIDGE}
    OWNER: ${FOREIGN_BRIDGE_OWNER}
  `)
  const gasLimitManager = await deployContract(
    SelectorTokenGasLimitManager,
    [FOREIGN_AMB_BRIDGE, FOREIGN_BRIDGE_OWNER, FOREIGN_MEDIATOR_REQUEST_GAS_LIMIT], {
      network: 'foreign',
      nonce: nonce++
    }
  )
  console.log('\n[Foreign] New Gas Limit Manager has been deployed: ', gasLimitManager.options.address)
  console.log('[Foreign] Manual setup of request gas limits in the manager is recommended.')
  console.log('[Foreign] Please, call setCommonRequestGasLimits on the Gas Limit Manager contract.')

  console.log('\n[Foreign] Deploying Bridge Mediator implementation with the following parameters:')
  console.log(`    TOKEN_NAME_SUFFIX: ${FOREIGN_TOKEN_NAME_SUFFIX}\n`)
  const foreignBridgeImplementation = await deployContract(ForeignOmnibridge, [FOREIGN_TOKEN_NAME_SUFFIX], {
    network: 'foreign',
    nonce: nonce++,
  })
  console.log('[Foreign] Bridge Mediator Implementation: ', foreignBridgeImplementation.options.address)

  console.log('\n[Foreign] Hooking up Mediator storage to Mediator implementation')
  await upgradeProxy({
    network: 'foreign',
    proxy: foreignBridgeStorage,
    implementationAddress: foreignBridgeImplementation.options.address,
    version: '1',
    nonce: nonce++,
  })

  if (FOREIGN_WETH_ADDRESS) {
    console.log('\n[Foreign] FOREIGN_WETH_ADDRESS was set. Deploying WETHOmnibridgeRouter helper\n')
    const foreignWETHOmnibridgeRouter = await deployContract(WETHOmnibridgeRouter, [foreignBridgeStorage.options.address, FOREIGN_WETH_ADDRESS, FOREIGN_BRIDGE_OWNER], {
      network: 'foreign',
      nonce: nonce++,
    })
    console.log('[Foreign] WETHOmnibridgeRouter deployed at: ', foreignWETHOmnibridgeRouter.options.address)
  }

  console.log('\nForeign part of OMNIBRIDGE has been deployed\n')
  return {
    foreignBridgeMediator: { address: foreignBridgeStorage.options.address },
    tokenFactory: { address: tokenFactory },
    gasLimitManager: { address: gasLimitManager.options.address }
  }
}

module.exports = deployForeign
