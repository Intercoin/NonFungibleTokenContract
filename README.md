
<h1> Contracts overview </h1>
<h2> NFTSafeHook </h2>

<p class="lead">

NFTSafeHook is a non fungible token contract of the new standard. It is based on the ERC721 standard, but with significant improvements. The basic idea is to represent the token ID in a special way, in which the ID is the concatenation of the series ID and the token itself in that series. 

The contract allows to create a series of tokens, with certain properties and conditions of sale (custom baseURI, suffix, limit, currency, price and royalties). Thus, it is not only a token contract, but a platform for creating various NFT projects and selling tokens with different logic. 

The list of basic features:
- Creation of a series of tokens with different terms of sale (royalties, price, currency) and token properties (custom baseURI, suffix, limit)
- Conduction of primary purchase (mint) for a specified currency and price
- Possibility for the users to resell tokens on special conditions
- Supporting of additional hooks connection (SafeHooks). SafeHooks mechanism doesn't put the current token owners at risk, since only the hooks that were present at the time of purchase will be applied to the individual token
- The contract owner can call a separate function mintAndDistribute() and mint the specified IDs to the specified addresses 
- The contract supports all functions of the ERC721 standard and ERC721Enumerable, besides there are public transfer() and burn() function
- Name and symbol can be changed by owner

 <h3> Current version addresses: </h3>

BSC: 0x7127206a49824D693932f9edCb77C53Fbb8443D7 (https://bscscan.com/address/0x7127206a49824D693932f9edCb77C53Fbb8443D7#code)

Rinkeby: 0xe9cc267028e51EA0176222abFebBD4Bb91D6Ef64 (https://rinkeby.etherscan.io/address/0xe9cc267028e51EA0176222abFebBD4Bb91D6Ef64#code)

Polygon: 0xf220eAd4222dD8a443C9591Fa1969E15Ca43E44c (not verified)

<br>
<h2> Factory </h2>
Factory contract for NFTSafeHooks. Allows gas-efficient deploy of copies of the NFTSafeHooks contract.

<h3> Current version addresses: </h3>

BSC: 0x30aA8512f275AC3a0194F240572F8f9e5095A7D2 (https://bscscan.com/address/0x30aA8512f275AC3a0194F240572F8f9e5095A7D2#code)

Rinkeby: 0x165D223e3756f8E3E54dc3af0545d65E6B9aaBbF (https://rinkeby.etherscan.io/address/0x165D223e3756f8E3E54dc3af0545d65E6B9aaBbF)

Polygon: 0x327033c8097B493072723233e494bA6579Ca2916 (not verified)

 <hr>
<h1> Getting started </h1>
To deploy a new instance of NFTSafeHooks contract user should call produce() method of Factory contract with desired 'name' and 'symbol' of a new token. Since it is done, address of the new instance can be obtained by calling getInstance() method of Factory contract. The caller of the Factory contract is the owner of the new contract. Owner can call all onlyOwner functions. For example, owner can call mintAndDistribute() method and freely mint list of specified IDs to list of specified addresses. To create the new series of tokens, function setSeriesInfo() must be called with appropriate parameters ('onSaleUntil' must be > current timestamp).

 <hr>
<h1> Structs </h1>
<h2> NFTSafeHook </h2>

<h3>SaleInfo</h3>

<p>Stores data about sale</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>onSaleUntil</td>
<td>uint256</td>
<td>block.timestamp of the sale end</td>
</tr><tr>
<td>currency</td>
<td>address</td>
<td>Address of token to pay with</td>
</tr><tr>
<td>price</td>
<td>uint256</td>
<td>Price of the sale</td>
</tr>
</tbody>
</table>


 <hr>


<h3>CommissionData</h3>

<p>Stores data about a commission</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>value</td>
<td>uint64</td>
<td>Amount of fractions (1/100000) to pay to receiver</td>
</tr><tr>
<td>recipient</td>
<td>address</td>
<td>Address of commission recipient </td>
</tr>
</tbody>
</table>


 <hr>


<h3>CommissionInfo</h3>

<p>Stores data about a default commission and global commission parameters</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>maxValue</td>
<td>uint64</td>
<td>Maximum amount of fractions for commissions</td>
</tr><tr>
<td>minValue</td>
<td>uint64</td>
<td>Minimum amount of fractions for commissions </td>
</tr><tr>
<td>defaultValues</td>
<td>CommissionData</td>
<td>Default commission data</td>
</tr>
</tbody>
</table>




 <hr>

<h3>SeriesInfo</h3>

<p>Stores data about a series</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>author</td>
<td>address payable</td>
<td>Author of a series</td>
</tr><tr>
<td>limit</td>
<td>uint32</td>
<td>Maximum amount of NFTs in collection </td>
</tr><tr>
<td>saleInfo</td>
<td>SaleInfo</td>
<td>Information about sale</td>
</tr><tr>
<td>commission</td>
<td>CommissionData</td>
<td>Information about series commission </td>
</tr><tr>
<td>baseURI</td>
<td>string</td>
<td>baseUri for all tokens in a collection </td>
</tr><tr>
<td>suffix</td>
<td>string</td>
<td>Suffix for tokenURI (baseURI|tokenId|suffix) </td>
</tr>
</tbody>
</table>



 <hr>
<h1> Events </h1>

<h2> NFTSafeHook </h2>

<hr>
<h3>NewHook</h3>

<p>Emitted when new hook to the collection added</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>seriesId</td>
<td>uint256</td>
<td>ID of the series which new hook was added to</td>
</tr><tr>
<td>contractAddress</td>
<td>address</td>
<td>address of the new hook address</td>
</tr>
</tbody>
</table>



<hr>
<h3>SeriesPutOnSale</h3>

<p>Emitted when a series is put on sale</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>seriesId</td>
<td>uint256 indexed</td>
<td>ID of the series which was put on sale</td>
</tr><tr>
<td>price</td>
<td>uint256</td>
<td>price of each token in the series</td>
</tr><tr>
<td>currency</td>
<td>address</td>
<td>address of ERC20 token to be payed for NFT (ETH address = 0x0000...00)</td>
</tr><tr>
<td>onSaleUntil</td>
<td>uint256</td>
<td>timestamp of the sale end</td>
</tr>
</tbody>
</table>




<hr>
<h3>SeriesRemovedFromSale</h3>

<p>Emitted when a series is removed from sale</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>seriesId</td>
<td>uint256 indexed</td>
<td>ID of the series which was put on sale</td>
</tr>
</tbody>
</table>





<hr>
<h3>TokenPutOnSale</h3>

<p>Emitted when a token is put on sale</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>tokenId</td>
<td>uint256 indexed</td>
<td>ID of the token which was put on sale</td>
</tr><tr>
<td>seller</td>
<td>address</td>
<td>seller of the token</td>
</tr><tr>
<td>price</td>
<td>uint256</td>
<td>price of the token</td>
</tr><tr>
<td>currency</td>
<td>address</td>
<td>address of ERC20 token to be payed for NFT (ETH address = 0x0000...00)</td>
</tr><tr>
<td>onSaleUntil</td>
<td>uint256</td>
<td>timestamp of the sale end</td>
</tr>
</tbody>
</table>



<hr>
<h3>TokenBought</h3>

<p>Emitted when a token is put on sale</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>tokenId</td>
<td>uint256 indexed</td>
<td>ID of the token which was put on sale</td>
</tr><tr>
<td>seller</td>
<td>address</td>
<td>seller of the token (if token minted seller = series author)</td>
</tr><tr>
<td>buyer</td>
<td>address</td>
<td>buyer of the token </td>
</tr><tr>
<td>price</td>
<td>uint256</td>
<td>price of the sale</td>
</tr><tr>
<td>currency</td>
<td>address</td>
<td>address of ERC20 token payed (ETH address = 0x0000...00)</td>
</tr>
</tbody>
</table>

<All ERC721 standard events>




<br>
<h2>Functions</h2>



<hr>
<h3>approve</h3>

<p>Gives permission to `to` to transfer `tokenId` token to 
another account. The approval is cleared when the token is transferred. 
Only a single account can be approved at a time, so approving the zero 
address clears previous approvals. Requirements: - The caller must own 
the token or be an approved operator. - `tokenId` must exist. Emits an 
{Approval} event.</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>to</td>
<td>address</td>
<td>address to approve token transfer</td>
</tr><tr>
<td>tokenId</td>
<td>uint256</td>
<td>ID of the token</td>
</tr>
</tbody>
</table>


<hr>
<h3>balanceOf</h3>

<p>Returns the number of tokens in `owner`'s account.</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>owner</td>
<td>address</td>
<td>address of account to check balance</td>
</tr>
</tbody>
</table>


<hr>
<h3>burn</h3>

<p>Burns `tokenId`. See {ERC721-_burn}. Requirements: - The caller must own `tokenId` or be an approved operator.</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>tokenId</td>
<td>uint256</td>
<td>token ID to burn</td>
</tr>
</tbody>
</table>




<hr>
<h3>buy</h3>

<p>Buys NFT for specified currency with defined id. Mint token if it doesn't exist and transfer token if it exists and is on sale. Has hook front-running defence</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>tokenId</td>
<td>uint256</td>
<td>token ID to buy</td>
</tr><tr>
<td>currency</td>
<td>address</td>
<td>address of token to pay with</td>
</tr><tr>
<td>price</td>
<td>uint256</td>
<td>amount of specified token to pay</td>
</tr><tr>
<td>safe</td>
<td>bool</td>
<td>use safeMint and safeTransfer or not</td>
</tr><tr>
<td>hookCount</td>
<td>uint256</td>
<td>Number of hooks, used to avoid front-running </td>
</tr>
</tbody>
</table>




<hr>
<h3>buy</h3>

<p>Buys NFT for ETH with defined id. Mint token if it doesn't exist and transfer token if it exists and is on sale</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>tokenId</td>
<td>uint256</td>
<td>token ID to buy</td>
</tr><tr>
<td>safe</td>
<td>bool</td>
<td>use safeMint and safeTransfer or not</td>
</tr>
</tbody>
</table>






<hr>
<h3>buy</h3>

<p>Buys NFT for specified currency with defined id.  mint token if it doesn't exist and transfer token if it exists and is on sale. Has hook front-running defence</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>tokenId</td>
<td>uint256</td>
<td>token ID to buy</td>
</tr><tr>
<td>safe</td>
<td>bool</td>
<td>use safeMint and safeTransfer or not</td>
</tr><tr>
<td>hookCount</td>
<td>uint256</td>
<td>Number of hooks, used to avoid front-running</td>
</tr>
</tbody>
</table>



<hr>
<h3>buy</h3>

<p>Buys NFT for specified currency with defined id. Mint token if it doesn't exist and transfer token if it exists and is on sale</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>tokenId</td>
<td>uint256</td>
<td>token ID to buy</td>
</tr><tr>
<td>currency</td>
<td>address</td>
<td>address of token to pay with</td>
</tr><tr>
<td>price</td>
<td>uint256</td>
<td>amount of specified token to pay</td>
</tr><tr>
<td>safe</td>
<td>bool</td>
<td>use safeMint and safeTransfer or not</td>
</tr>
</tbody>
</table>



<hr>
<h3>getApproved</h3>

<p>Returns the account approved for `tokenId` token. Requirements: - `tokenId` must exist.</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>tokenId</td>
<td>uint256</td>
<td>Token ID </td>
</tr>
</tbody>
</table>




<hr>
<h3>getHookList</h3>

<p>Returns the list of hooks for series with `seriesId`</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>seriesId</td>
<td>uint256</td>
<td>Series ID</td>
</tr>
</tbody>
</table>




<hr>
<h3>getSaleInfo</h3>

<p>Returns the 'SaleInfo' struct for sale of NFT with 'tokenId'. </p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>tokenId</td>
<td>uint256</td>
<td>Token ID</td>
</tr>
</tbody>
</table>



<hr>
<h3>getSeriesInfo</h3>

<p>Returns the SeriesInfo struct for series with 'seriesId'. </p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>seriesId</td>
<td>uint256</td>
<td>Series ID</td>
</tr>
</tbody>
</table>



<hr>
<h3>hooksCountByToken</h3>

<p><strong>Returns number of hooks applied to token with 'tokenId'</strong></p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>tokenId</td>
<td>uint256</td>
<td>Token ID</td>
</tr>
</tbody>
</table>




<hr>
<h3>initialize</h3>

<p><strong>Initializes contract</strong></p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>name</td>
<td>string</td>
<td>Name of NFT</td>
</tr><tr>
<td>symbol</td>
<td>string</td>
<td>Symbol of NFT</td>
</tr>
</tbody>
</table>



<hr>
<h3>isApprovedForAll</h3>

<p>Returns true if the `operator` is allowed to manage all of the assets of `owner`. See {setApprovalForAll}</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>owner</td>
<td>address</td>
<td>Address of tokens' owner</td>
</tr><tr>
<td>operator</td>
<td>address</td>
<td>Address of the operator</td>
</tr>
</tbody>
</table>




<hr>
<h3>listForSale</h3>

<p>Lists NFT with defined token ID on sale with specified terms</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>tokenId</td>
<td>uint256</td>
<td>Token ID</td>
</tr><tr>
<td>price</td>
<td>uint256</td>
<td>Price for the sale </td>
</tr><tr>
<td>currency</td>
<td>address</td>
<td>Currency of sale </td>
</tr><tr>
<td>duration</td>
<td>uint256</td>
<td>Duration of sale in seconds</td>
</tr>
</tbody>
</table>



<hr>
<h3>mintAndDistribute</h3>

<p>Only owner. Mints and distributes NFTs with specified IDs to specified addresses</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>tokenIds</td>
<td>uint256[]</td>
<td>List of NFT IDs to be minted</td>
</tr><tr>
<td>addrs</td>
<td>address[]</td>
<td>List of receiver addresses</td>
</tr>
</tbody>
</table>




<hr>
<h3>mintedCountBySeries</h3>

<p><strong>Returns number of tokens minted in the series</strong></p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>seriesId</td>
<td>uint256</td>
<td>Series ID</td>
</tr>
</tbody>
</table>



<hr>
<h3>name</h3>

<p>Returns the token collection name.</p>




<hr>
<h3>owner</h3>

<p>Returns the address of the current owner.</p>



<hr>
<h3>ownerOf</h3>

<p>Returns the owner of the `tokenId` token. Requirements: - `tokenId` must exist.</p>





<hr>
<h3>pushTokenTransferHook</h3>

<p>Adds safeHook contract to certain Series</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>seriesId</td>
<td>uint256</td>
<td>Series ID</td>
</tr><tr>
<td>contractAddress</td>
<td>address</td>
<td>Address of SafeHook contract</td>
</tr>
</tbody>
</table>



<hr>
<h3>renounceOwnership</h3>

<p>Leaves the contract without owner. It will not be 
possible to call `onlyOwner` functions anymore. Can only be called by 
the current owner. NOTE: Renouncing ownership will leave the contract 
without an owner, thereby removing any functionality that is only 
available to the owner.</p>



<hr>
<h3>transfer</h3>

<p>Tranfers token with 'tokenId' to 'to' address</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>to</td>
<td>address</td>
<td>Receiver address</td>
</tr><tr>
<td>tokenId</td>
<td>uint256</td>
<td>Token ID</td>
</tr>
</tbody>
</table>



<hr>
<h3>safeTransfer</h3>

<p>Safely tranfers token with 'tokenId' to 'to' address</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>to</td>
<td>address</td>
<td>Receiver address</td>
</tr><tr>
<td>tokenId</td>
<td>uint256</td>
<td>Token ID</td>
</tr>
</tbody>
</table>


<hr>
<h3>safeTransferFrom</h3>

<p>Safely transfers `tokenId` token from `from` to `to`, 
checking first that contract recipients are aware of the ERC721 protocol
to prevent tokens from being forever locked. Requirements: - `from` 
cannot be the zero address. - `to` cannot be the zero address. - 
`tokenId` token must exist and be owned by `from`. - If the caller is 
not `from`, it must be have been allowed to move this token by either 
{approve} or {setApprovalForAll}. - If `to` refers to a smart contract, 
it must implement {IERC721Receiver-onERC721Received}, which is called 
upon a safe transfer. Emits a {Transfer} event.</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>from</td>
<td>address</td>
<td>Sender address</td>
</tr><tr>
<td>to</td>
<td>address</td>
<td>Receiver address</td>
</tr><tr>
<td>tokenId</td>
<td>uint256</td>
<td>Token ID</td>
</tr>
</tbody>
</table>



<hr>
<h3>safeTransferFrom</h3>

<p>Safely transfers `tokenId` token from `from` to `to`, 
checking first that contract recipients are aware of the ERC721 protocol
to prevent tokens from being forever locked. Requirements: - `from` 
cannot be the zero address. - `to` cannot be the zero address. - 
`tokenId` token must exist and be owned by `from`. - If the caller is 
not `from`, it must be have been allowed to move this token by either 
{approve} or {setApprovalForAll}. - If `to` refers to a smart contract, 
it must implement {IERC721Receiver-onERC721Received}, which is called 
upon a safe transfer. Emits a {Transfer} event.</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>from</td>
<td>address</td>
<td>Sender address</td>
</tr><tr>
<td>to</td>
<td>address</td>
<td>Receiver address</td>
</tr><tr>
<td>tokenId</td>
<td>uint256</td>
<td>Token ID</td>
</tr><tr>
<td>_data</td>
<td>bytes</td>
<td>Data for the call</td>
</tr>
</tbody>
</table>




<hr>
<h3>salesInfo</h3>

<p><strong>Returns SaleInfo struct of token with 'tokenId'</strong></p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>tokenId</td>
<td>uint256</td>
<td>Token ID</td>
</tr>
</tbody>
</table>


<hr>
<h3>seriesInfo</h3>

<p><strong>Returns SeriesInfo struct of series with 'seriesId'</strong></p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>seriesId</td>
<td>uint256</td>
<td>Series ID</td>
</tr>
</tbody>
</table>




<hr>
<h3>setApprovalForAll</h3>

<p>Approve or remove `operator` as an operator for the 
caller. Operators can call {transferFrom} or {safeTransferFrom} for any 
token owned by the caller. Requirements: - The `operator` cannot be the 
caller. Emits an {ApprovalForAll} event.</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>operator</td>
<td>address</td>
<td>Address of the operator</td>
</tr><tr>
<td>approved</td>
<td>bool</td>
<td>Is approved or not</td>
</tr>
</tbody>
</table>



<hr>
<h3>setNameAndSymbol</h3>

<p>Only owner. Sets name and symbol for contract</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>newName</td>
<td>string</td>
<td>New name </td>
</tr><tr>
<td>newSymbol</td>
<td>string</td>
<td>New symbol </td>
</tr>
</tbody>
</table>





<hr>
<h3>setSaleInfo</h3>

<p>Sets sale info for the NFT with 'tokenId'</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>tokenId</td>
<td>uint256</td>
<td>Token ID</td>
</tr><tr>
<td>info</td>
<td>tuple</td>
<td>Information about sale </td>
</tr>
</tbody>
</table>


<hr>
<h3>setOwnerCommission</h3>

<p> Only owner. Sets information for default commission. </p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>commission</td>
<td>CommissionInfo</td>
<td>Commission information</td>
</tr>
</tbody>
</table>




<hr>
<h3>setCommission</h3>

<p>Only owner. Sets commission for the series. </p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>seriesId</td>
<td>uint64</td>
<td>Series ID</td>
</tr><tr>
<td>commissionData</td>
<td>CommissionData</td>
<td>Commission data</td>
</tr>
</tbody>
</table>





<hr>
<h3>removeCommission</h3>

<p>Only owner. Removes commission for the series</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>seriesId</td>
<td>uint64</td>
<td>Series ID</td>
</tr>
</tbody>
</table>




<hr>
<h3>commissionInfo</h3>

<p> Returns information about commission in the series with 'seriesId' </p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>seriesId</td>
<td>uint64</td>
<td>Series ID</td>
</tr>
</tbody>
</table>



<hr>
<h3>setSeriesInfo</h3>

<p>Only owner. Sets information for series with 'seriesId'. </p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>seriesId</td>
<td>uint256</td>
<td>Series ID</td>
</tr><tr>
<td>info</td>
<td>tuple</td>
<td>New info to set</td>
</tr>
</tbody>
</table>



<hr>
<h3>supportsInterface</h3>

<p>Returns true if the contract supports interface with 'interfaceId' </p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>interfaceId</td>
<td>bytes4</td>
<td>Interface ID</td>
</tr>
</tbody>
</table>




<hr>
<h3>symbol</h3>

<p>Returns the token collection symbol</p>




<hr>
<h3>tokenByIndex</h3>

<p>Returns a token ID at a given `index` of all the tokens 
stored by the contract. Use along with {totalSupply} to enumerate all 
tokens.</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>index</td>
<td>uint256</td>
<td>Token index</td>
</tr>
</tbody>
</table>




<hr>
<h3>tokenOfOwnerByIndex</h3>

<p>Returns a token ID owned by `owner` at a given `index` of
its token list. Use along with {balanceOf} to enumerate all of 
``owner``'s tokens.</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>owner</td>
<td>address</td>
<td>Owner address</td>
</tr><tr>
<td>index</td>
<td>uint256</td>
<td>Token index</td>
</tr>
</tbody>
</table>





<hr>
<h3>tokenURI</h3>

<p>Returns the Uniform Resource Identifier (URI) for `tokenId` token.</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>tokenId</td>
<td>uint256</td>
<td>Token ID</td>
</tr>
</tbody>
</table>



<hr>
<h3>tokensByOwner</h3>

<p>Returns the list of all NFTs owned by 'account'</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>account</td>
<td>address</td>
<td>Address of account</td>
</tr>
</tbody>
</table>



<hr>
<h3>tokensByOwner</h3>

<p>Returns the list of all NFTs owned by 'account'</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>account</td>
<td>address</td>
<td>Address of account</td>
</tr><tr>
<td>limit</td>
<td>uint256</td>
<td>Limit for list</td>
</tr>
</tbody>
</table>



<hr>
<h3>totalSupply</h3>

<p>Returns the total amount of tokens stored by the contract.</p>



<hr>
<h3>transferFrom</h3>

<p>Transfers `tokenId` token from `from` to `to`. WARNING: 
Usage of this method is discouraged, use {safeTransferFrom} whenever 
possible. Requirements: - `from` cannot be the zero address. - `to` 
cannot be the zero address. - `tokenId` token must be owned by `from`. -
If the caller is not `from`, it must be approved to move this token by 
either {approve} or {setApprovalForAll}. Emits a {Transfer} event.</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>from</td>
<td>address</td>
<td>Sender address</td>
</tr><tr>
<td>to</td>
<td>address</td>
<td>Receiver address</td>
</tr><tr>
<td>tokenId</td>
<td>uint256</td>
<td>Token ID</td>
</tr>
</tbody>
</table>



<hr>
<h3>transferOwnership</h3>

<p>Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.</p>

<table class="table table-sm table-bordered table-striped">
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>newOwner</td>
<td>address</td>
<td>New owner address</td>
</tr>
</tbody>
</table>

