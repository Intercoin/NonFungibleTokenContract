<h1> Contracts overview </h1>
<h2> NFT </h2>

<p class="lead">

NFT is a non fungible token contract of the new standard. It is based on the ERC721 standard, but with significant improvements. 
The basic idea is to represent the token ID in a special way, in which the ID is the concatenation of the series ID and the token itself in that series. 

The contract allows to create a series of tokens, with certain properties and conditions of sale (custom baseURI, suffix, limit, currency, price and royalties). 
Thus, it is not only a token contract, but a platform for creating various NFT projects and selling tokens with different logic. 

The list of basic features:
- Creation of a series of tokens with different terms of sale (royalties, price, currency) and token properties (custom baseURI, suffix, limit)
- Conduction of primary purchase (mint) for a specified currency and price
- Possibility for the users to resell tokens on special conditions
- Supporting of additional hooks connection (SafeHooks). SafeHooks mechanism doesn't put the current token owners at risk, since only the hooks that were present at the time of purchase will be applied to the individual token
- The contract owner can call a separate function mintAndDistribute() and mint the specified IDs to the specified addresses 
- The contract supports all functions of the ERC721 standard and ERC721Enumerable, besides there are public transfer() and burn() function
- Name and symbol can be changed by owner

<h3> Current version addresses implementation: </h3>

ABI: [https://ipfs.io/ipfs/QmYQZRcsV6sfVWwVK5FG67g2XcTqkTzcdhk9WRQHwaYQQr](https://ipfs.io/ipfs/QmYQZRcsV6sfVWwVK5FG67g2XcTqkTzcdhk9WRQHwaYQQr)

Rinkeby: [0x04002eCadCe04d1D8A9F3073B83615785dAdA702](https://rinkeby.etherscan.io/address/0x04002eCadCe04d1D8A9F3073B83615785dAdA702#code)<br>
BSC-Testnet: [0x0426e9fE25eF7351946d09136E4b965d53543d08](https://testnet.bscscan.com/address/0x0426e9fE25eF7351946d09136E4b965d53543d08#code)<br>
MATIC: [0x65205E13623761441D3c1792a4d7A6E9076A63F4](https://polygonscan.com/address/0x65205E13623761441D3c1792a4d7A6E9076A63F4#code) (not verified)<br>


<br>
<details>
<summary><b><i>Previous versions implementation</i></b></summary>
------------------------------<br>

ABI: [https://ipfs.io/ipfs/QmdTf3217bra8Jm1egyKkEDBeJfhJfvJ3jhicoDfrhYEGH](https://ipfs.io/ipfs/QmdTf3217bra8Jm1egyKkEDBeJfhJfvJ3jhicoDfrhYEGH)

Rinkeby: [0x5633652F103793fE25465CF04291788B7d8EFAC7](https://rinkeby.etherscan.io/address/0x5633652F103793fE25465CF04291788B7d8EFAC7#code)<br>
BSC-Testnet: [0x814E71E5d6F7F06512bF6db6b00730d75960Dbae](https://testnet.bscscan.com/address/0x814E71E5d6F7F06512bF6db6b00730d75960Dbae#code)<br>
MATIC: [0x7156BE8D65404b6b2F4aEBd70e6a1Bd538358BE6](https://polygonscan.com/address/0x7156BE8D65404b6b2F4aEBd70e6a1Bd538358BE6#code) (not verified)<br>

------------------------------<br>

Rinkeby: [0x0b20A09f61D8d8755BFD8dD084eB3078Bed29514](https://rinkeby.etherscan.io/address/0x0b20A09f61D8d8755BFD8dD084eB3078Bed29514#code)<br>
BSC-Testnet: [0x699e94b92fa331dE1e702332a5fb6b565Eb0D49a](https://testnet.bscscan.com/address/0x699e94b92fa331dE1e702332a5fb6b565Eb0D49a#code)<br>
MATIC: [0x2EA8BF5091B081aFf7C26d0aB6Bbe386cc9666B7](https://polygonscan.com/address/0x2EA8BF5091B081aFf7C26d0aB6Bbe386cc9666B7#code) (not verified)<br>
------------------------------<br>

Rinkeby: [0xF0DeBed25eC8ef805280eE8d3e546EE827C6Bc87](https://rinkeby.etherscan.io/address/0xF0DeBed25eC8ef805280eE8d3e546EE827C6Bc87#code)<br>
BSC-Testnet: [0x59021Cb2448a3af840112eC2de878d8B7d4C1b4E](https://testnet.bscscan.com/address/0x59021Cb2448a3af840112eC2de878d8B7d4C1b4E#code)<br>
MATIC: [0x910F345AC291d22B1188338c9F4e4a91E9EA2A47](https://polygonscan.com/address/0x910F345AC291d22B1188338c9F4e4a91E9EA2A47#code) (not verified)<br>
------------------------------<br>

Rinkeby: [0x78613Cc32ecA27DEC6f42BC08990CDB06D6b4Df6](https://rinkeby.etherscan.io/address/0x78613Cc32ecA27DEC6f42BC08990CDB06D6b4Df6#code)<br>
Polygon: 0x159a0e4b698a21B7E50Ec5D06921d73dEFf89510 (not verified)<br>
------------------------------<br>
</details>

<br>
<h2> Factory </h2>
Factory contract for NFTs. Allows gas-efficient deploy of copies of the NFTs contract.

<h3> Current version addresses: </h3>

ABI: [https://ipfs.io/ipfs/QmdPMNHNdmSeCmcrao5zw8MnULw97pmtb8QpGM5DLXYWuf](https://ipfs.io/ipfs/QmdPMNHNdmSeCmcrao5zw8MnULw97pmtb8QpGM5DLXYWuf)

Rinkeby: [0x900fDA19857e86ae861930B1aeCcB783357D0Be3](https://rinkeby.etherscan.io/address/0x900fDA19857e86ae861930B1aeCcB783357D0Be3#code)<br>
BSC-Testnet: [0x54e4793Dba7d969265ec020a99b35D1447184fCc](https://testnet.bscscan.com/address/0x54e4793Dba7d969265ec020a99b35D1447184fCc#code)<br>
MATIC: [0x7Ac4F98322Da0Ad708D30E59d7856042E8D1758c](https://polygonscan.com/address/0x7Ac4F98322Da0Ad708D30E59d7856042E8D1758c#code) (not verified)<br>

<br>
<details>
<summary><b><i>Previous versions</i></b></summary>

------------------------------<br>

ABI: [https://ipfs.io/ipfs/QmdPMNHNdmSeCmcrao5zw8MnULw97pmtb8QpGM5DLXYWuf](https://ipfs.io/ipfs/QmdPMNHNdmSeCmcrao5zw8MnULw97pmtb8QpGM5DLXYWuf)

Rinkeby: [0xf38F70F637124dEaa836D5bB35ce880FEf4786A8](https://rinkeby.etherscan.io/address/0xf38F70F637124dEaa836D5bB35ce880FEf4786A8#code)<br>
BSC-Testnet: [0x611b4a14e76973d1928B9B0F45022FDf841de50a](https://testnet.bscscan.com/address/0x611b4a14e76973d1928B9B0F45022FDf841de50a#code)<br>
MATIC: [0x80098e58Cb1e593Cf9C046b90057e0890AB7e596](https://polygonscan.com/address/0x80098e58Cb1e593Cf9C046b90057e0890AB7e596#code) (not verified)<br>
------------------------------<br>

Rinkeby: [0x6619495634eA889c73FD51aD60276F104735AbDe](https://rinkeby.etherscan.io/address/0x6619495634eA889c73FD51aD60276F104735AbDe#code)<br>
BSC-Testnet: [0x730d471fC842a6D9822e444e9cce0EB253DCceDc](https://testnet.bscscan.com/address/0x730d471fC842a6D9822e444e9cce0EB253DCceDc#code)<br>
MATIC: [0xd4220E0BaB13520356e0A103C68d1896476dbC7C](https://polygonscan.com/address/0xd4220E0BaB13520356e0A103C68d1896476dbC7C#code) (not verified)<br>
------------------------------<br>

Rinkeby: [0x1411384E65547569657172F6d474Ecf21EE172dD](https://rinkeby.etherscan.io/address/0x1411384E65547569657172F6d474Ecf21EE172dD#code)<br>
BSC-Testnet: [0xe05B713E968246aE8B829df8FD5a088879594d6F](https://testnet.bscscan.com/address/0xe05B713E968246aE8B829df8FD5a088879594d6F#code)<br>
MATIC: [0x427CD51e32DE879B0b4c220396A2ea7172dD7ec2](https://polygonscan.com/address/0x427CD51e32DE879B0b4c220396A2ea7172dD7ec2#code) (not verified)<br>
------------------------------<br>

Rinkeby: [0x4a273f42F320E015Db1F741E17E517F6aF1E4D9B](https://rinkeby.etherscan.io/address/0x4a273f42F320E015Db1F741E17E517F6aF1E4D9B#code)<br>
Polygon: 0xEd99D3bf50e76c257F1b197796c5df8B27F73986 (not verified)<br>
------------------------------<br>
</details>

<h1> Getting started </h1>
To deploy a new instance of NFT contract user should call produce() method of Factory contract with desired 'name' and 'symbol' of a new token. 
Since it is done, address of the new instance can be obtained by calling getInstance() method of Factory contract. 
The caller of the Factory contract is the owner of the new contract. Owner can call all onlyOwner functions. 
For example, owner can call mintAndDistribute() method and freely mint list of specified IDs to list of specified addresses. 
To create the new series of tokens, function setSeriesInfo() must be called with appropriate parameters ('onSaleUntil' must be > current timestamp).

<br>
<h2> NFTSales </h2>
NFTSales contract can be produced by contract NFTSalesFactory and allow to purchase nft by special price that can be setup by NFTSalesFactory's owner . 

The list of basic features:
Token can be claim after duration period that should be passed after purchase
The contract owner can add(or remove) any person into whitelist
Any person from the whitelist can purchase tokens by calling specialPurchase 
Bought tokens will be able after duration time was passed it will not be automaticallY. person have need to call distribute/claim methods

<br>
<h2> NFTSalesFactory </h2>
NFTSalesFactory is a factory contract for NFTSales instance.
Work schema are following: Deployer deploy NFTSalesFactory and make it as Trusted Forwarder for desired NFTContract, where would want to sell nft tokens.
Then for his clients deployer can create NFTSales instance and specify params like currency,price,beneficiary,etc.
Now Client - as owner of NFTSales contract can add to whitelist any persons because calling specialPurchase are able only whitelist's persons.
in any time: 
Owner of NFTSales contract can remove person from whitelist and block method specialPurchase for him using.
Deployer can add to black list certain NFTSales contract, and block it works.
From other side NFTContract's owner can remove NFTSalesFactory from the TrustedForwarder. This will block work for all NFTSales instances produced by the factory.

<hr>
<h1>Contracts MD</h1>

[NFT.md](docs/contracts/v2/NFTMain.md)<br>
[NFTSales.md](docs/contracts/sales/NFTSales.md)<br>
[NFTSalesFactory.md](docs/contracts/sales/NFTSalesFactory.md)<br>
