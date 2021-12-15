
<h1> Contracts overview </h1>
<h2> NFTSafeHook </h2>

<p class="lead">

Non fungible token contract of the new standard. It is based on the ERC721 standard, but with significant changes. The basic idea is to represent the token ID in a special way, in which the ID is the concatenation of the series ID and the token itself in that series. 

The contract allows to create a series of tokens, with certain properties and conditions of sale (custom baseURI, suffix, limit, currency, price and royalties). Thus, it is not only a token contract, but a platform for creating various NFT projects and selling tokens with different logic. 

The list of basic features:
- Creation of a series of tokens with different terms of sale (royalties, price, currency) and token properties (custom baseURI, suffix, limit)
- Conduction of primary purchase (mint) for a specified currency and price
- Possibility for the users to resell tokens on special conditions
- Supporting of additional hooks connection (SafeHooks). SafeHooks mechanism doesn't put the current token owners at risk, since only the hooks that were present at the time of purchase will be applied to the individual token
- The contract owner can call a separate function mintAndDistribute() and mint the specified IDs to the specified addresses 
- The contract supports all functions of the ERC721 standard and ERC721Enumerable, besides there are public transfer() and burn() function

<br>
<h2> Factory </h2>
Factory contract for NFTSafeHooks. Allows gas-efficiently deploating copies of the NFTSafeHooks contract 


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
<h6>getApproved</h6>

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

<p>Mints and distributes NFTs with specified IDs to specified addresses</p>

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

<p>link safeHook contract to certain Series</p>

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
<td>series ID</td>
</tr><tr>
<td>contractAddress</td>
<td>address</td>
<td>address of SafeHook contract</td>
</tr>
</tbody>
</table>

<p>Returns:</p>

<p>No parameters</p>


<hr>
<h6>renounceOwnership</h6>

<p>Leaves the contract without owner. It will not be 
possible to call `onlyOwner` functions anymore. Can only be called by 
the current owner. NOTE: Renouncing ownership will leave the contract 
without an owner, thereby removing any functionality that is only 
available to the owner.</p>

<p>No parameters</p>

<p>Returns:</p>

<p>No parameters</p>


<hr>
<h6>safeTransferFrom</h6>

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
<td></td>
</tr><tr>
<td>to</td>
<td>address</td>
<td></td>
</tr><tr>
<td>tokenId</td>
<td>uint256</td>
<td></td>
</tr>
</tbody>
</table>

<p>Returns:</p>

<p>No parameters</p>


<hr>
<h6>safeTransferFrom</h6>

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
<td></td>
</tr><tr>
<td>to</td>
<td>address</td>
<td></td>
</tr><tr>
<td>tokenId</td>
<td>uint256</td>
<td></td>
</tr><tr>
<td>_data</td>
<td>bytes</td>
<td></td>
</tr>
</tbody>
</table>

<p>Returns:</p>

<p>No parameters</p>


<hr>
<h6>salesInfo</h6>

<p><strong>**Add Documentation for the method here**</strong></p>

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
<td></td>
<td>uint256</td>
<td></td>
</tr>
</tbody>
</table>

<p>Returns:</p>

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
<td>currency</td>
<td>address</td>
<td></td>
</tr><tr>
<td>price</td>
<td>uint256</td>
<td></td>
</tr><tr>
<td>onSaleUntil</td>
<td>uint256</td>
<td></td>
</tr>
</tbody>
</table>


<hr>
<h6>seriesInfo</h6>

<p><strong>**Add Documentation for the method here**</strong></p>

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
<td></td>
<td>uint256</td>
<td></td>
</tr>
</tbody>
</table>

<p>Returns:</p>

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
<td>address</td>
<td></td>
</tr><tr>
<td>saleInfo</td>
<td>tuple</td>
<td></td>
</tr><tr>
<td>limit</td>
<td>uint256</td>
<td></td>
</tr><tr>
<td>baseURI</td>
<td>string</td>
<td></td>
</tr>
</tbody>
</table>


<hr>
<h6>setApprovalForAll</h6>

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
<td></td>
</tr><tr>
<td>approved</td>
<td>bool</td>
<td></td>
</tr>
</tbody>
</table>

<p>Returns:</p>

<p>No parameters</p>


<hr>
<h6>setNameAndSymbol</h6>

<p>sets name and symbol for contract</p>

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
<td>new name </td>
</tr><tr>
<td>newSymbol</td>
<td>string</td>
<td>new symbol </td>
</tr>
</tbody>
</table>

<p>Returns:</p>

<p>No parameters</p>


<hr>
<h6>setSaleInfo</h6>

<p>sets sale info for the NFT with 'tokenId'</p>

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
<td>token ID</td>
</tr><tr>
<td>info</td>
<td>tuple</td>
<td>information about sale </td>
</tr>
</tbody>
</table>

<p>Returns:</p>

<p>No parameters</p>


<hr>
<h6>setSeriesInfo</h6>

<p>sets information for series with 'seriesId'. </p>

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
<td>series ID</td>
</tr><tr>
<td>info</td>
<td>tuple</td>
<td>new info to set</td>
</tr>
</tbody>
</table>

<p>Returns:</p>

<p>No parameters</p>


<hr>
<h6>supportsInterface</h6>

<p>See {IERC165-supportsInterface}.</p>

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
<td></td>
</tr>
</tbody>
</table>

<p>Returns:</p>

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
<td></td>
<td>bool</td>
<td></td>
</tr>
</tbody>
</table>


<hr>
<h6>symbol</h6>

<p>Returns the token collection symbol.</p>

<p>No parameters</p>

<p>Returns:</p>

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
<td></td>
<td>string</td>
<td></td>
</tr>
</tbody>
</table>


<hr>
<h6>tokenByIndex</h6>

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
<td></td>
</tr>
</tbody>
</table>

<p>Returns:</p>

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
<td></td>
<td>uint256</td>
<td></td>
</tr>
</tbody>
</table>


<hr>
<h6>tokenOfOwnerByIndex</h6>

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
<td></td>
</tr><tr>
<td>index</td>
<td>uint256</td>
<td></td>
</tr>
</tbody>
</table>

<p>Returns:</p>

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
<td></td>
<td>uint256</td>
<td></td>
</tr>
</tbody>
</table>


<hr>
<h6>tokenURI</h6>

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
<td></td>
</tr>
</tbody>
</table>

<p>Returns:</p>

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
<td></td>
<td>string</td>
<td></td>
</tr>
</tbody>
</table>


<hr>
<h6>tokensByOwner</h6>

<p>gives the list of all NFTs owned by 'account'</p>

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
<td>address of account</td>
</tr>
</tbody>
</table>

<p>Returns:</p>

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
<td>ret</td>
<td>uint256[]</td>
<td></td>
</tr>
</tbody>
</table>


<hr>
<h6>tokensByOwner</h6>

<p>gives the list of all NFTs owned by 'account'</p>

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
<td>address of account</td>
</tr><tr>
<td>limit</td>
<td>uint256</td>
<td></td>
</tr>
</tbody>
</table>

<p>Returns:</p>

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
<td>ret</td>
<td>uint256[]</td>
<td></td>
</tr>
</tbody>
</table>


<hr>
<h6>totalSupply</h6>

<p>Returns the total amount of tokens stored by the contract.</p>

<p>No parameters</p>

<p>Returns:</p>

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
<td></td>
<td>uint256</td>
<td></td>
</tr>
</tbody>
</table>


<hr>
<h6>transferFrom</h6>

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
<td></td>
</tr><tr>
<td>to</td>
<td>address</td>
<td></td>
</tr><tr>
<td>tokenId</td>
<td>uint256</td>
<td></td>
</tr>
</tbody>
</table>

<p>Returns:</p>

<p>No parameters</p>


<hr>
<h6>transferOwnership</h6>

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
<td></td>
</tr>
</tbody>
</table>

<p>Returns:</p>

<p>No parameters</p>
