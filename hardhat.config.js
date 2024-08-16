
require('dotenv').config();
require("@nomicfoundation/hardhat-toolbox");

const kovanURL = `https://eth-kovan.alchemyapi.io/v2/${process.env.ALCHEMY_KOVAN}`
const goerliURL = `https://eth-goerli.alchemyapi.io/v2/${process.env.ALCHEMY_GOERLI}`
const rinkebyURL = /*`https://rinkeby.infura.io/v3/${process.env.INFURA_ID_PROJECT}` */`https://eth-rinkeby.alchemyapi.io/v2/${process.env.ALCHEMY_RINKEBY}`
const bscURL = 'https://bsc-dataseed.binance.org'; //`https://eth-rinkeby.alchemyapi.io/v2/${process.env.ALCHEMY_RINKEBY}` 
const bsctestURL = 'https://data-seed-prebsc-1-s1.binance.org:8545';
const mainnetURL = `https://eth-mainnet.alchemyapi.io/v2/${process.env.ALCHEMY_MAINNET}`
const maticURL = `https://polygon-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_MATIC}`
const mumbaiURL = 'https://matic-mumbai.chainstacklabs.com';

const baseURL = 'https://mainnet.base.org';
const optimismURL = 'https://optimism.llamarpc.com';

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    local: {
      url: "http://localhost:8545", //rinkebyURL,
      chainId: 1337,
      //gasPrice: "auto",
      //accounts: {mnemonic: process.env.MNEMONIC,initialIndex:1},
      accounts: [process.env.private_key],
      saveDeployments: true
    },
    hardhat: {
      allowUnlimitedContractSize: true,
      chainId: 137,  // sync with url or getting uniswap settings will reject transactions
      forking: {
        url: maticURL,
      }
    },
    bsc: {
      url: bscURL,
      chainId: 56,
      //gasPrice: "auto",
      accounts: [
        process.env.private_key,
        process.env.private_key_auxiliary,
        process.env.private_key_nft,
        process.env.private_key_sales
      ],
      saveDeployments: true
    },
    bsctest: {
      url: bsctestURL,
      chainId: 97,
      //gasPrice: "auto",
      accounts: [process.env.private_key],
      saveDeployments: true
    },
    polygonMumbai: {
      url: mumbaiURL,
      chainId: 80001,
      //gasPrice: "auto", 
      accounts: [
        process.env.private_key_auxiliary,
        process.env.private_key_auxiliary,
        process.env.private_key_auxiliary,
        process.env.private_key_auxiliary
      ],
      saveDeployments: true
    },
    polygon: {
      url: maticURL,
      chainId: 137,
      //gasPrice: "auto",
      accounts: [
        process.env.private_key,
        process.env.private_key_auxiliary,
        process.env.private_key_nft,
        process.env.private_key_sales
      ],
      saveDeployments: true
    },
    mainnet: {
      url: mainnetURL,
      chainId: 1,
      gasPrice: 1_500_000_000,
      accounts: [
        process.env.private_key,
        process.env.private_key_auxiliary,
        process.env.private_key_nft,
        process.env.private_key_sales
      ],
      saveDeployments: true
    },
    base: {
      url: baseURL,
      chainId: 8453,
      accounts: [
        process.env.private_key,
        process.env.private_key_auxiliary,
        process.env.private_key_nft,
        process.env.private_key_sales
      ],
      saveDeployments: true
    },
    optimisticEthereum: {
      url: optimismURL,
      chainId: 10,
      accounts: [
        process.env.private_key,
        process.env.private_key_auxiliary,
        process.env.private_key_nft,
        process.env.private_key_sales
      ],
      saveDeployments: true
    }
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD"
  },
  etherscan: {
    //apiKey: process.env.MATIC_API_KEY  
    //apiKey: process.env.ETHERSCAN_API_KEY
    //apiKey: process.env.BSCSCAN_API_KEY
    apiKey: {
      polygon: process.env.MATIC_API_KEY,
      polygonMumbai: process.env.MATIC_API_KEY,
      mainnet: process.env.ETHERSCAN_API_KEY,
      bsctest: process.env.BSCSCAN_API_KEY,
      bsc: process.env.BSCSCAN_API_KEY,
      optimisticEthereum: process.env.OPTIMISM_API_KEY,
      base: process.env.BASE_API_KEY
    }
  },
  solidity: {
    compilers: [
        {
          version: "0.8.15",
          settings: {
            optimizer: {
              enabled: true,
              runs: 50,
            },
            metadata: {
              // do not include the metadata hash, since this is machine dependent
              // and we want all generated code to be deterministic
              // https://docs.soliditylang.org/en/v0.7.6/metadata.html
              bytecodeHash: "none",
            },
          },
        },
        {
          version: "0.8.11",
          settings: {
            optimizer: {
              enabled: true,
              runs: 50,
            },
            metadata: {
              // do not include the metadata hash, since this is machine dependent
              // and we want all generated code to be deterministic
              // https://docs.soliditylang.org/en/v0.7.6/metadata.html
              bytecodeHash: "none",
            },
          },
        },
        {
          version: "0.6.7",
          settings: {},
          settings: {
            optimizer: {
              enabled: false,
              runs: 50,
            },
            metadata: {
              // do not include the metadata hash, since this is machine dependent
              // and we want all generated code to be deterministic
              // https://docs.soliditylang.org/en/v0.7.6/metadata.html
              bytecodeHash: "none",
            },
          },
        },
      ],
  
    
  },

  namedAccounts: {
    deployer: 0,
    },

  paths: {
    sources: "contracts",
  },
  gasReporter: {
    currency: 'USD',
    enabled: (process.env.REPORT_GAS === "true") ? true : false
  },
  mocha: {
    timeout: 200000
  }
 
}
