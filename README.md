# NonFungibleTokenContract
NFT contracts that support a new ERC token standard for paying commissions to authors
NFTSeries contract do the same but have ability to create several NFT in one transaction. The rest of the interface are the same

# Latest contract instances in test networks

20211202 <br>
Ethereum Rinkeby Testnet<br>
<a href="https://rinkeby.etherscan.io/address/0x555994e9D5C3731Ab3240F3FEC4BcC9a2803484e#code">Created instance NFT</a><br>
<a href="https://ipfs.io/ipfs/QmR9LjNjVsra7pXj2wLddm4tPjT8RPNMxQYtXjpFrbKmgp">https://ipfs.io/ipfs/QmR9LjNjVsra7pXj2wLddm4tPjT8RPNMxQYtXjpFrbKmgp</a>
<br>
Binance SmartChain TestNet<br>
TBD

<details>
<summary>
# Old versions
</summary>
Binance SmartChain TestNet<br>
<p>
20211103 <br>
<a href="https://testnet.bscscan.com/address/0xf5d34ddcf1c89de8d107d8877417d54582b4c33c#contracts">NFTFactory</a><br>
<a href="https://testnet.bscscan.com/address/0x583875e2b1b2a40433d01acf509f0229823c5cd3#code">Created instance NFT</a><br>
<a href="https://ipfs.io/ipfs/QmWomwLZES1BwM4XWnYoei3H42cyH41NaaGNp1eS7fBMEU">https://ipfs.io/ipfs/QmWomwLZES1BwM4XWnYoei3H42cyH41NaaGNp1eS7fBMEU</a>
</p>
<p>
<a href="https://testnet.bscscan.com/address/0xF331051D1Ae614d2554a3121a02fEf3a56882C35#contracts">NFTFactory</a><br>
<a href="https://testnet.bscscan.com/address/0x4a948d22a1d8c9f64c68a5db503aa982f5682f68#code">Created instance NFT</a><br>
<a href="https://ipfs.io/ipfs/QmZnE3Ku2nHqi7TNWUMuyzxZkp87cnn4X4bkPWyWkCR8aM">https://ipfs.io/ipfs/QmZnE3Ku2nHqi7TNWUMuyzxZkp87cnn4X4bkPWyWkCR8aM</a>
</p>
<p>
<a href="https://testnet.bscscan.com/address/0xF4eFc2cB258754AEe772361e034E37716eA324d0#contracts">NFTFactory</a><br>
<a href="https://testnet.bscscan.com/address/0x58DFdE51CD6dDB92EF5DD21A14Fe078a376FE549#code">Created instance NFT</a><br>
</p>
</details>

# Overview
- ![#f03c15](https://via.placeholder.com/15/f03c15/000000?text=+) `readme is outofdate`

Once installed will be use methods:

<table>
<thead>
	<tr>
		<th>method name</th>
		<th>called by</th>
		<th>description</th>
	</tr>
</thead>
<tbody>
    <tr>
		<td><a href="#buy">buy</a></td>
		<td>anyone</td>
		<td>buying token by sending native coins like BNB or ETH to contract</td>
	</tr>
	<tr>
		<td><a href="#buywithtoken">buyWithToken</a></td>
		<td>anyone</td>
		<td>buying token by sending ERC-20 tokens to contract</td>
	</tr>
    <tr>
		<td><a href="#buywithethandcreate">buyWithETHAndCreate</a></td>
		<td>anyone<span>&#42;</span></td>
		<td>creating NFT token</td>
	</tr>
    <tr>
		<td><a href="#buywithtokenandcreate">buyWithTokenAndCreate</a></td>
		<td>anyone<span>&#42;</span></td>
		<td>creating NFT token</td>
	</tr>
    <tr>
		<td><a href="#addAuthorized">addAuthorized</a></td>
		<td>anyone<span>&#42;</span></td>
		<td>adds an author</td>
	</tr>
    <tr>
		<td><a href="#addAuthorized">removeAuthorized</a></td>
		<td>anyone<span>&#42;</span></td>
		<td>removes an author</td>
	</tr>
	    <tr>
		<td><a href="#addAuthorized">isAuthorized</a></td>
		<td>anyone<span>&#42;</span></td>
		<td>tests whether a wallet is an author</td>
	</tr>
	<tr>
		<td><a href="#getallowners">getAllOwners</a></td>
		<td>anyone</td>
		<td>viewing list total NFT's owners</td>
	</tr>
	<tr>
		<td><a href="#getallauthors">getAllAuthors</a></td>
		<td>anyone</td>
		<td>viewing list total NFT's authors</td>
	</tr>
    <tr>
		<td><a href="#getcommission">getCommission</a></td>
		<td>anyone</td>
		<td>getting the amount of the commission that will be paid to the author when transferring</td>
	</tr>
	<tr>
		<td><a href="#historyofauthors">historyOfAuthors</a></td>
		<td>anyone</td>
		<td>history of all previous authors</td>
	</tr>
	<tr>
		<td><a href="#historyofowners">historyOfOwners</a></td>
		<td>anyone</td>
		<td>history of all previous owners</td>
	</tr>
	<tr>
		<td><a href="#historyofsale">historyOfSale</a></td>
		<td>anyone</td>
		<td>getting sale data that stored when transferring</td>
	</tr>
    <tr>
		<td><a href="#initialize">initialize</a></td>
		<td>owner</td>
		<td>initializing after deploy</td>
	</tr>
    <tr>
		<td><a href="#listforsale">listForSale</a></td>
		<td>NFTOwner</td>
		<td>adding token to sale</td>
	</tr>
	<tr>
		<td><a href="#offertopaycommission">offerToPayCommission</a></td>
		<td>anyone</td>
		<td>offering to pay commission for token</td>
	</tr>
	<tr>
		<td><a href="#reducecommission">reduceCommission</a></td>
		<td>NFTAuthor</td>
		<td>reducing Commission for NFT token</td>
	</tr>
    <tr>
		<td><a href="#removefromsale">removeFromSale</a></td>
		<td>NFTOwner</td>
		<td>removing token from sale</td>
	</tr>
	<tr>
		<td><a href="#saleinfo">saleInfo</a></td>
		<td>anyone</td>
		<td>viewing sale info</td>
	</tr>
	<tr>
		<td><a href="#transferauthorship">transferAuthorship</a></td>
		<td>NFTAuthor</td>
		<td>transfer authorship for NFT token</td>
	</tr>
	<tr>
		<td><a href="#tokensbyowner">tokensByOwner</a></td>
		<td>anyone</td>
		<td>viewing tokens list by owner</td>
	</tr>
	<tr>
		<td><a href="#tokensbyauthor">tokensByAuthor</a></td>
		<td>anyone</td>
		<td>viewing tokens list by author</td>
	</tr>
	<tr>
		<td><a href="#claimlosttoken">claimLostToken</a></td>
		<td>owner</td>
		<td>claiming lost token which can be mistakenly sent to contract</td>
	</tr>
</tbody>
</table>
<sup>*</sup> anyone if while initialize <a href="#communitysettings">communitySettings_.[addr]</a> was set in zero. otherwise method can be called only who belong to community role 'roleMint' in community contract `addr`

## Methods

#### initialize
initialize contract after deploy or clone. need to be called before using<br>
Params:

name  | type | description
--|--|--
name|string| name of NFT token
symbol|string|symbol of NFT token
<a href="#communitysettings">communitySettings_</a>|tuple|
    
#### create
creating NFT <br>
Emits event <a href="#tokencreated">TokenCreated</a>(for NFT)<br>
or <a href="#tokenseriescreated">TokenSeriesCreated</a>(for NFTSeries)<br>
Params:

name  | type | description
--|--|--
URI|string|The Uniform Resource Identifier (URI)
<a href="#commissionparams">commissionParams</a>|tuple|
tokenAmount|uint256|token amount (third parameter acceptible only for NFTSeries contract)
    
#### buyWithETHAndCreate
Buys a token with ETH from `SalesData.seller`, and creates the NFT. The seller becomes the authorOf(tokenId).
Must be pre-authorized by owner's or authorized user's signature.
Emits event <a href="#tokencreated">TokenCreated</a>(for NFT)<br>
or <a href="#tokenseriescreated">TokenSeriesCreated</a>(for NFTSeries)<br>
Params:

name  | type | description
--|--|--
URI|string|The Uniform Resource Identifier (URI)
<a href="#commissionparams">commissionParams</a>|tuple|
saleParams|SaleParams|contains `token=0x0`, `amount`, `seller`
<a href="#commissionparams">commissionParams</a>|tuple|
signature|bytes|the signature, <a href="#signature">generated like this</a>

#### buyWithTokenAndCreate
Transfers amount of a given token from `SalesData.seller`, and creates the NFT. The seller becomes the authorOf(tokenId).
Must be pre-authorized by owner's or authorized user's signature.
The amount must already have been allowed by user signing a call to `token.approve(this contract)`
Emits event <a href="#tokencreated">TokenCreated</a>(for NFT)<br>
or <a href="#tokenseriescreated">TokenSeriesCreated</a>(for NFTSeries)<br>
Params:

name  | type | description
--|--|--
URI|string|The Uniform Resource Identifier (URI)
saleParams|SaleParams|contains `token`, `amount`, `seller`
<a href="#commissionparams">commissionParams</a>|tuple|
signature|bytes|the signature, <a href="#signature">generated like this</a>

#### addAuthorized
Adds to list of wallets of token authors authorized to pre-sign transactions, that can be used for users to buyAndCreate tokens with preset URIs and parameters

name  | type | description
--|--|--
address|address|an NFT author

#### removeAuthorized

Removes from list of wallets of token authors authorized to pre-sign transactions, that can be used for users to buyAndCreate tokens with preset URIs and parameters

name  | type | description
--|--|--
address|address|an NFT author

#### isAuthorized

Returns true if the wallet is authorized to be an author

name  | type | description
--|--|--
address|address|the wallet to ask about

#### getCommission
getting Commission for NFT token<br>
Params:

name  | type | description
--|--|--
tokenId|uint256| `tokenId`

#### reduceCommission
reducing Commission for NFT token<br>
Params:

name  | type | description
--|--|--
tokenId|uint256| `tokenId`
reduceCommissionPercent|uint256| percent in interval [0;10000]  0%-100%

Return Values:

name  | type | description
--|--|--   
token|address|address of ERC20 token
amount|uint256|amount commission

#### transferAuthorship
Transfer authorship for NFT token<br>
Params:

name  | type | description
--|--|--
from|address|old author's address
to|address|new author's address
tokenId|uint256|tokenID of transferred token

#### claimLostToken
claiming lost token which can be mistakenly sent to contract<br>
Params:

name  | type | description
--|--|--
erc20address|address| ERC20 contract's address

#### listForSale
adding token to sale<br>
Emits event <a href="#tokenaddedtosale">TokenAddedToSale</a><br>
Params:

name  | type | description
--|--|--
tokenId|uint256|`tokenId`
amount|uint256|amount in coins(bnb, eth etc.)
consumeToken|address|token address. if address(0) then owner expect coins for sale

#### removeFromSale
removing token from sale list<br>
Emitted event <a href="#tokenremovedfromsale">TokenRemovedFromSale</a><br>
Params:

name  | type | description
--|--|--
tokenId|uint256|`tokenId`

#### saleInfo
viewing current sale info<br>
Params:

name  | type | description
--|--|--
tokenId|uint256|`tokenId`

Return tuple with params:

name  | type | description
--|--|--
amount|uint256|amount in coins(bnb, eth etc.)
consumeToken|address|token address. if address(0) then owner expect coins for sale
isSale|bool|return true if token put into sale list
startTime|uint256|starting auction time
endTime|uint256|ending auction time
minIncrement|uint256| minimum increment from last bid
isAuction|bool|return true if token put into sale list (auction type)


#### tokensByOwner
viewing tokens list by owner<br>
Params:

name  | type | description
--|--|--
owner|address| owner's address

Return array of token ID's

name  | type | description
--|--|--
ret|uint256[]| tokenID's

#### tokensByAuthor
viewing tokens list by author<br>
Params:

name  | type | description
--|--|--
author|address| author's address

Return array of token ID's

name  | type | description
--|--|--
ret|uint256[]| tokenID's

#### historyOfOwners
history of all previous owners<br>
Params:

name  | type | description
--|--|--
tokenId|uint256| `tokenId`

Return

name  | type | description
--|--|--
ret|address[]| addresses's

#### historyOfAuthors
history of all previous authors<br>
Params:

name  | type | description
--|--|--
tokenId|uint256| `tokenId`

Return

name  | type | description
--|--|--
ret|address[]| addresses's

#### historyOfBids
viewing history of bids previous auction<br>
Params:

name  | type | description
--|--|--
tokenId|uint256| `tokenId`

Return

name  | type | description
--|--|--
ret|Bid[]| tuples of Bid's struct

#### getAllOwners
viewing list total NFT's owners<br>

Return

name  | type | description
--|--|--
ret|address[]| addresses's

#### getAllAuthors
viewing list total NFT's authors<br>

Return

name  | type | description
--|--|--
ret|address[]| addresses's

#### claim
claim nft for person who winner auction sale<br>
Params:

name  | type | description
--|--|--
tokenId|uint256| `tokenId`

#### acceptLastBid
nft owner can manually accept last bid<br>
Params:

name  | type | description
--|--|--
tokenId|uint256| `tokenId`
	
#### buy
can buy token by sending coins bnb or eth to contract<br>
Emits event <a href="outbid">OutBid</a>(if token put into auction sale by <a href="listforauction">listForAuction</a>) <br>
Params:

name  | type | description
--|--|--
tokenId|uint256|`tokenId`

#### buyWithToken
can buy token by sending erc20 tokens to contract (need approving before)<br>
Emits event <a href="outbid">OutBid</a>(if token put into auction sale by <a href="listforauction">listForAuction</a>) <br>
Params:

name  | type | description
--|--|--
tokenId|uint256|`tokenId`

#### offerToPayCommission
offering to pay commission for token<br>
Params:

name  | type | description
--|--|--
tokenId|uint256|`tokenId`
amount|uint256|amount in coins(bnb, eth etc.)

#### tokensByAuthor
viewing tokens list by author<br>
Params:

name  | type | description
--|--|--
author|address| author's address

Return Values:

name  | type | description
--|--|--   
ret|uint256[]|list of tokenIds that belongs to author

#### historyOfSale
viewing tokens sale data stored when token trasferring<br>
Params:

name  | type | description
--|--|--
tokenId|uint256|`tokenId`
indexFromEnd|uint256|(optional)timestamp from

Return Values:

name  | type | description
--|--|--   
ret|SaleInfo[]|array of tuples 

## Tuples

#### Ratio
name  | type | description
--|--|--
addr|address|coauthor's address
proportion|uint256|percent (mul by 100) represented how much co-authors will obtain of amount that author can be receive

#### CommunitySettings
name  | type | description
--|--|--
addr|address|address of Community Contract. can be zero. in this case create NFT Token can be available to everyone
roleMint|string|role name from Community

#### CommissionParams

formula calculation a commission that can be payed to author
```
(   
	initialValue * (multiply ^ intervals) + (intervalsSinceLastTransfer * accrue)
) * (10000 - reduceCommission) / 10000
```	
	
name  | type | description
--|--|--
token|address| address of erc20/er777 token. which would be sent to the author as a commission pay
amount|uint256| amount of commission token.
multiply|uint256| value(mul by 1e4) that would be pow in interval passed since creation and multiplied to inital amount of commission
accrue|uint256| additional value that would be pow in interval passed since last transfer
intervalSeconds|uint256| interval period in seconds
reduceCommission|uint256| reduced commission in percents from final calculated value

#### Bid    
name  | type | description
--|--|--
bidder|address|bid address 
bid|uint256| bid amount

#### SaleInfo    
name  | type | description
--|--|--
time|uint256|timesstamp
from|address|from
to|address|to
price|uint256|price payed
token|address|token payed
commission|uint256|price commission
commissionToken|address|token commission

## Events    

#### TokenCreated
emitted only in NFT contract

name  | type | description
--|--|--
author|address|author's address of newly created token
tokenId|uint256|tokenID of newly created token

#### TokenSeriesCreated
emitted only in NFTSeries contract

name  | type | description
--|--|--
author|address|author's address of newly created token
fromTokenId|uint256|first tokenID of newly created series
toTokenId|uint256|last tokenID of newly created series
  
#### TransferAuthorship
name  | type | description
--|--|--
from|address|old author's address
to|address|new author's address
tokenId|uint256|tokenID of transferred token

#### TokenAddedToSale
name  | type | description
--|--|--
tokenId|uint256|tokenID
amount|uint256|amount that need to be paid to owner when some1 buy token
consumeToken|address|erc20 token. if set address(0) then expected coins to pay for NFT

#### TokenAddedToAuctionSale
name  | type | description
--|--|--
tokenId|uint256|tokenID
amount|uint256|amount that need to be paid to owner when some1 buy token
consumeToken|address|erc20 token. if set address(0) then expected coins to pay for NFT
startTime|uint256|starting auction time
endTime|uint256|ending auction time
minIncrement|uint256| minimum increment from last bid
	
#### TokenRemovedFromSale
name  | type | description
--|--|--
tokenId|uint256|tokenID


## How to compute a signature

The below code from Javascript console shows how to do it with [ethers.js](https://docs.ethers.io/v5/) (similar things can be done with web3.js)

<pre>
encoded = ethers.utils.defaultAbiCoder.encode(
  [ "string tokenURI", "tuple(address token, uint256 amount, address seller)", "tuple(address token,uint256 amount,uint256 multiply,uint256 accrue,uint256 intervalSeconds,uint256 reduceCommission)" ],
  [
    "https://yahoo.com",
    { token: "0x35bd01fc9d6d5d81ca9e055db88dc49aa2c699a8", amount: 7, seller: "0x1111158f88410da5f92c7e34c01e7b8649bc0155" },
      { token: "0x35bd01fc9d6d5d81ca9e055db88dc49aa2c699a8", amount: 0, multiply: 0, 
            accrue: 0, intervalSeconds: 60, reduceCommission: 0 }
  ]
);
</pre>
'0x000000000000000000000000000000000000000000000000000000000000014000000000000000000000000035bd01fc9d6d5d81ca9e055db88dc49aa2c699a800000000000000000000000000000000000000000000000000000000000000070000000000000000000000001111158f88410da5f92c7e34c01e7b8649bc015500000000000000000000000035bd01fc9d6d5d81ca9e055db88dc49aa2c699a8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001168747470733a2f2f7961686f6f2e636f6d000000000000000000000000000000'
<pre>
hash = ethers.utils.keccak256(encoded)
</pre>
'0x8ad62b726ab33018d0a9ea7c4298625a176f6d62510cd2d93d67fda3ef2bf041'
<pre>signature = await signer.signMessage(ethers.utils.arrayify(hash));</pre>
'0x7e9e5f3612ce36cea644a47df5a09e0be53123c976df88fd7bca9a3b571ba55f648af4b4b82418c9bd6a8599fdd03a8cab239729fd4744e51d4931cbba1965991c'

## Example to use
NonFungibleTokenContract is a contract represented ERC721 standard with possibility to earn fee to author's NFT token and paying to owner while transfer. <br>
NonFungibleTokenContract can be deploy with 2 ways:<br>
1. directly into network and calling method <a href="">initialize</a> after that<br>
2. calling method produce at NFTFactory with same parameters as in initialize.<br>
in both cases sender will become an owner of NonFungibleTokenContract and can call <a href="#claimlosttoken">claimLostToken</a> in future to claim lost tokens mistekenly send to contract<br>
After deploy and initialize everyone can create NFT token calling method <a href="#create">create</a><br>(if community contract was set in zero while initialize).<br>
After that sender will become an owner and author for newly create NFT token. and as owner will be get fee(commission) for each transfer this NFT token<br>

So scenario #1 <b>"How to transfer token from user1 to user2"</b><br>
<b>a.</b> lets user1 create NFT token. with params `"http://google.com", [0xc778417E063141139Fce010982780140Aa0cD5Ab, 1000000000000000000,10000,0,25200,0]`<br>
Here:<br>
<table>
<thead>
	<tr>
		<th>value</th>
		<th>description</th>
	</tr>
</thead>
<tbody>
	<tr>
		<td>http://google.com</td>
		<td>URI</td>
	</tr>
	<tr>
		<td>0xc778417E063141139Fce010982780140Aa0cD5Ab</td>
		<td>address of WETH token</td>
	</tr>
	<tr>
		<td>1000000000000000000</td>
		<td>amount in 1WETH</td>
	</tr>
	<tr>
		<td>10000</td>
		<td>multiply value. here it equal to 'one' </td>
	</tr>
	<tr>
		<td>0</td>
		<td>accrue value</td>
	</tr>
	<tr>
		<td>25200</td>
		<td>7 hours in seconds that represent one interval</td>
	</tr>
	<tr>
		<td>0</td>
		<td>means that general commission value will not to be reduce</td>
	</tr>
</tbody>
</table>

<b>b.</b> now NFT owner(user1) should call <a href="#listforsale">listForSale<a/> and put own NFT token to sale.<br> 
Otherwise any transfer will reverts with message `NFT: Token does not in sale`. <br>
In params NFT owner(user1) can specify `tokenID`, `amount` and `consumeToken`'s address. <br>
If `consumeToken` are zero than owner expects coins(ETH or BNB) for sale.<br>
for example `213,1000000000000000000,"0x0000000000000000000000000000000000000000"` means that owner expects 1 ETH(or BNB) for TokenID number "213".<br>

<b>b1.</b> aleternative NFT owner(user1) can call <a href="#listforauction">listForAuction<a/> and put own NFT token to auction sale.<br> 
In params NFT owner(user1) can specify `tokenID`, `amount`, `consumeToken`'s address, `startTime`, `endTime` and `minIncrement`. <br>
If `consumeToken` are zero than owner expects coins(ETH or BNB) for sale.<br>
`startTime` can specified as zero. in this case auction will start immediately.<br>
`endTime` can be zero, in this case auctino will never expire and ended only if previous owner will call <a href="acceptlastbid">acceptLastBid</a><br>
for example `213,1000000000000000000,"0x0000000000000000000000000000000000000000"0,0,500000000000000000` means that owner stating unlimited by time auction with started price 1 ETH(or BNB) for TokenID number "213". and expecting minimum 0.5 ETH(or BNB) for every next bid<br>

<b>c.</b> now need offer to pay commission for this tokenID "213". there are several ways:
- anyone can offer to pay commission by: 
    - calling method <a href="offertopaycommission">offerToPayCommission</a> specify tokenID and amount of tokens (describe in point a). in our cases it's WETH.
    - and approve amount to NFTContract address
- NFT owner(user1) may offer to pay a commission. in this case, the commission will be debited primarily from the owner, and if it is not enough - from those who previously offered in order list. <br>Ofcource amount need to be approved before.
- finally NFT Author can reduce commission make transfer for free. he should calls method <a href="#reducecommission">reduceCommission</a> with params `<tokenID>, 0` .

<b>d.</b> finally user2 can buy token by calling method `buy` or `buyWithTokens`. In our cases he should to make payable transaction `buy` with value 1ETH (see point b).
If commissions for author and price for old owner are enough, user2 will become a new owner of this token. Token are automatically removed from sale.
if nft put in to auction sale then calling method `buy` or `buyWithTokens` we just increase bid. and bid from previous user will refund back



