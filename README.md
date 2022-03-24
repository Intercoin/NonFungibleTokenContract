![#f03c15](https://via.placeholder.com/15/f03c15/000000?text=+) `readme.md is out of date.`
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
Rinkeby: 0xF0DeBed25eC8ef805280eE8d3e546EE827C6Bc87 (https://rinkeby.etherscan.io/address/0xF0DeBed25eC8ef805280eE8d3e546EE827C6Bc87#code)<br>
<br>
<details>
<summary><b><i>Previous versions implementation</i></b></summary>
------------------------------<br>
Rinkeby: 0x78613Cc32ecA27DEC6f42BC08990CDB06D6b4Df6 (https://rinkeby.etherscan.io/address/0x78613Cc32ecA27DEC6f42BC08990CDB06D6b4Df6#code)<br>
Polygon: 0x159a0e4b698a21B7E50Ec5D06921d73dEFf89510 (not verified)<br>
------------------------------<br>
</details>

<br>
<h2> Factory </h2>
Factory contract for NFTs. Allows gas-efficient deploy of copies of the NFTs contract.

<h3> Current version addresses: </h3>

Rinkeby: 0x4a273f42F320E015Db1F741E17E517F6aF1E4D9B (https://rinkeby.etherscan.io/address/0x4a273f42F320E015Db1F741E17E517F6aF1E4D9B#code)<br>
<br>
<details>
<summary><b><i>Previous versions</i></b></summary>
------------------------------<br>
Rinkeby: 0x4a273f42F320E015Db1F741E17E517F6aF1E4D9B (https://rinkeby.etherscan.io/address/0x4a273f42F320E015Db1F741E17E517F6aF1E4D9B#code)<br>
Polygon: 0xEd99D3bf50e76c257F1b197796c5df8B27F73986 (not verified)<br>
------------------------------<br>
</details>


 <hr>
<h1> Getting started </h1>
To deploy a new instance of NFT contract user should call produce() method of Factory contract with desired 'name' and 'symbol' of a new token. 
Since it is done, address of the new instance can be obtained by calling getInstance() method of Factory contract. 
The caller of the Factory contract is the owner of the new contract. Owner can call all onlyOwner functions. 
For example, owner can call mintAndDistribute() method and freely mint list of specified IDs to list of specified addresses. 
To create the new series of tokens, function setSeriesInfo() must be called with appropriate parameters ('onSaleUntil' must be > current timestamp).

<hr>

## Contracts MD
[NFT.md](docs/contracts/NFTMain.md)<br>
