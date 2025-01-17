const axios = require('axios')
const querystring = require('querystring')
const fs = require('fs')
const path = require('path')
const promiseRetry = require('promise-retry')
const { EXPLORER_TYPES, REQUEST_STATUS } = require('../constants')

const basePath = path.join(__dirname, '..', '..', '..', 'flats')
const precompiledBasePath = path.join(__dirname, '..', '..', '..', 'precompiled')

const flat = async (contractPath, options) => {
  if (options?.contractName === "PermittableToken") {
    const filePath = path.join(precompiledBasePath, "PermittableToken_flat.sol")
    return fs.readFileSync(filePath).toString()
  }

  const pathArray = contractPath.split('/')
  const name = pathArray[pathArray.length - 1]

  const flatName = name.replace('.sol', '_flat.sol')

  const filePath = path.join(basePath, flatName)

  return fs.readFileSync(filePath).toString()
}

const sendRequest = (url, queries) => axios.post(url, querystring.stringify(queries))

const sendVerifyRequestEtherscan = async (contractPath, options) => {
  const contract = await flat(contractPath, options)
  const postQueries = {
    apikey: options.apiKey,
    module: 'contract',
    action: 'verifysourcecode',
    contractaddress: options.address,
    sourceCode: contract,
    codeformat: 'solidity-single-file',
    contractname: options.contractName,
    compilerversion: options.compiler,
    optimizationUsed: options.optimizationUsed ? 1 : 0,
    runs: options.runs,
    constructorArguements: options.constructorArguments,
    evmversion: options.evmVersion,
  }

  return sendRequest(options.apiUrl, postQueries)
}

const sendVerifyRequestBlockscout = async (contractPath, options) => {
  const contract = await flat(contractPath, options)
  const postQueries = {
    module: 'contract',
    action: 'verify',
    addressHash: options.address,
    contractSourceCode: contract,
    name: options.contractName,
    compilerVersion: options.compiler,
    optimization: options.optimizationUsed,
    optimizationRuns: options.runs,
    constructorArguments: options.constructorArguments,
    evmVersion: options.evmVersion,
  }

  return sendRequest(options.apiUrl, postQueries)
}

const getExplorerType = (apiUrl) =>
  apiUrl && apiUrl.includes('etherscan') ? EXPLORER_TYPES.ETHERSCAN : EXPLORER_TYPES.BLOCKSCOUT

const verifyContract = async (contract, params, type) => {
  try {
    const verify = type === EXPLORER_TYPES.ETHERSCAN ? sendVerifyRequestEtherscan : sendVerifyRequestBlockscout
    const result = await verify(contract, params)
    if (result.data.message === REQUEST_STATUS.OK) {
      console.log(`${params.address} verified in ${type}`)
      return true
    } else {
      if (!result.data.result.includes(`Unable to locate ContractCode`)) {
        console.warn(result)
      }
    }
    return false
  } catch (e) {
    console.error(e)
    return false
  }
}

const verifier = async ({ artifact, address, constructorArguments, apiUrl, apiKey }) => {
  console.log(`verifying contract ${address}`)
  const type = getExplorerType(apiUrl)

  let metadata
  try {
    metadata = JSON.parse(artifact.metadata)
  } catch (e) {
    console.log('Error on decoding values from artifact')
  }

  const contract = artifact.sourcePath
  const params = (artifact.contractName === "PermittableToken" && !metadata) ? {
    address,
    contractName: artifact.contractName,
    constructorArguments,
    compiler: `v${artifact.compiler.version.replace('.Emscripten.clang', '')}`,
    optimizationUsed: true,
    runs: 200,
    evmVersion: "default",
    apiUrl,
    apiKey,
  } : {
    address,
    contractName: artifact.contractName,
    constructorArguments,
    compiler: `v${artifact.compiler.version.replace('.Emscripten.clang', '')}`,
    optimizationUsed: metadata.settings.optimizer.enabled,
    runs: metadata.settings.optimizer.runs,
    evmVersion: metadata.settings.evmVersion,
    apiUrl,
    apiKey,
  }

  try {
    await promiseRetry(async (retry) => {
      const verified = await verifyContract(contract, params, type)
      if (!verified) {
        retry()
      }
    })
  } catch (e) {
    console.log(`It was not possible to verify ${address} in ${type}`)
  }
}

module.exports = verifier
