# NonFungibleTokenContract
NFT contracts that support a new ERC token standard for paying commissions to authors
NFTSeries contract do the same but have ability to create several NFT in one transaction. The rest of the interface are the same

# Overview

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
		<td><a href="#initialize">initialize</a></td>
		<td>owner</td>
		<td>initializing after deploy</td>
	</tr>
    <tr>
		<td><a href="#create">create</a></td>
		<td>anyone<span>&#42;</span></td>
		<td>creating NFT token</td>
	</tr>
    <tr>
		<td><a href="#createandsale">createAndSale</a></td>
		<td>anyone<span>&#42;</span></td>
		<td>creating NFT token and immediately adding to sale</td>
	</tr>
    <tr>
		<td><a href="#getcommission">getCommission</a></td>
		<td>anyone</td>
		<td>getting the amount of the commission that will be paid to the author when transferring</td>
	</tr>
	<tr>
		<td><a href="#reducecommission">reduceCommission</a></td>
		<td>NFTAuthor</td>
		<td>reducing Commission for NFT token</td>
	</tr>
	<tr>
		<td><a href="#transferauthorship">transferAuthorship</a></td>
		<td>NFTAuthor</td>
		<td>transfer authorship for NFT token</td>
	</tr>
    <tr>
		<td><a href="#claimlosttoken">claimLostToken</a></td>
		<td>owner</td>
		<td>claiming lost token which can be mistakenly sent to contract</td>
	</tr>
    <tr>
		<td><a href="#listforsale">listForSale</a></td>
		<td>NFTOwner</td>
		<td>adding token to sale</td>
	</tr>
	<tr>
		<td><a href="#listforauction">listForAuction</a></td>
		<td>NFTOwner</td>
		<td>adding token to auction sale. such nft can not be purchase immediately. auction's winner can be claim nft after auction ending</td>
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
		<td><a href="#tokensbyowner">tokensByOwner</a></td>
		<td>anyone</td>
		<td></td>
	</tr>
	<tr>
		<td><a href="#tokensbyauthor">tokensByAuthor</a></td>
		<td>anyone</td>
		<td></td>
	</tr>
	<tr>
		<td><a href="#historyofowners">historyOfOwners</a></td>
		<td>anyone</td>
		<td></td>
	</tr>
	<tr>
		<td><a href="#historyofauthors">historyOfAuthors</a></td>
		<td>anyone</td>
		<td></td>
	</tr>
	<tr>
		<td><a href="#historyofbids">historyOfBids</a></td>
		<td>anyone</td>
		<td></td>
	</tr>
	<tr>
		<td><a href="#getallowners">getAllOwners</a></td>
		<td>anyone</td>
		<td></td>
	</tr>
	<tr>
		<td><a href="#getallauthors">getAllAuthors</a></td>
		<td>anyone</td>
		<td></td>
	</tr>
	<tr>
		<td><a href="#claim">claim</a></td>
		<td>anyone</td>
		<td></td>
	</tr>
	<tr>
		<td><a href="#acceptlastbid">acceptLastBid</a></td>
		<td>NFTOwner</td>
		<td></td>
	</tr>
    <tr>
		<td><a href="#buy">buy</a></td>
		<td>anyone</td>
		<td>buying token by sending coins bnb or eth to contract</td>
	</tr>
	<tr>
		<td><a href="#buywithtoken">buyWithToken</a></td>
		<td>anyone</td>
		<td>buying token by sending tokens to contract</td>
	</tr>
    <tr>
		<td><a href="#offertopaycommission">offerToPayCommission</a></td>
		<td>anyone</td>
		<td>offering to pay commission for token</td>
	</tr>
    <tr>
		<td><a href="#tokensbyauthor">tokensByAuthor</a></td>
		<td>anyone</td>
		<td>viewing tokens list by author</td>
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
Emitted event <a href="#tokencreated">TokenCreated</a>(for NFT)<br>
or <a href="#tokenseriescreated">TokenSeriesCreated</a>(for NFTSeries)<br>
Params:

name  | type | description
--|--|--
URI|string|The Uniform Resource Identifier (URI)
<a href="#commissionparams">commissionParams</a>|tuple|
tokenAmount|uint256|token amount (third parameter acceptible only for NFTSeries contract)
    
#### createAndSale
creating NFT and adding to sale<br>
Emitted event <a href="#tokencreated">TokenCreated</a>(for NFT)<br>
or <a href="#tokenseriescreated">TokenSeriesCreated</a>(for NFTSeries)<br>
Params:

name  | type | description
--|--|--
URI|string|The Uniform Resource Identifier (URI)
<a href="#commissionparams">commissionParams</a>|tuple|
tokenAmount|uint256|token amount (third parameter acceptible only for NFTSeries contract)
consumeAmount|uint256|amount in coins(bnb, eth etc.)
consumeToken|address|token address. if address(0) then owner expect coins for sale

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
Emitted event <a href="#tokenaddedtosale">TokenAddedToSale</a><br>
Params:

name  | type | description
--|--|--
tokenId|uint256|`tokenId`
amount|uint256|amount in coins(bnb, eth etc.)
consumeToken|address|token address. if address(0) then owner expect coins for sale

#### listForAuction
adding token to auction sale. such nft can not be purchase immediately. auction's winner can be claim nft after auction ending <br>
Emitted events:<br> 
<a href="#tokenaddedtosale">TokenAddedToSale</a>, <a href="#tokenaddedtoauctionsale">TokenAddedToAuctionSale</a><br>
Params:

name  | type | description
--|--|--
tokenId|uint256|`tokenId`
amount|uint256|amount in coins(bnb, eth etc.)
consumeToken|address|token address. if address(0) then owner expect coins for sale
startTime|uint256| start auction's time. can be 0, then auction start immediately(in block mined time)
endTime|uint256| end auction's time. can be 0, then auction never end and owner should accept last higher bid to make bidder a new nft owner
minIncrement|uint256| minimal increment from last bid can be acceptable for next bid

#### removeFromSale
removing token from sale list<br>
Emitted event <a href="#tokenremovedfromsale">TokenRemovedFromSale</a><br>
Params:

name  | type | description
--|--|--
tokenId|uint256|`tokenId`

#### saleInfo
viewing sale info<br>
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

#### tokensByAuthor
viewing tokens list by author<br>

#### historyOfOwners
history of all previous owners<br>

#### historyOfAuthors
history of all previous authors<br>

#### historyOfBids
viewing history of bids previous auction<br>

#### getAllOwners
viewing list total NFT's owners<br>

#### getAllAuthors
viewing list total NFT's authors<br>

#### claim
claim nft for person who winner auction sale<br>

#### acceptLastBid
nft owner can manually accept last bid<br>
	
#### buy
can buy token by sending coins bnb or eth to contract<br>
Params:

name  | type | description
--|--|--
tokenId|uint256|`tokenId`

#### buyWithToken
can buy token by sending erc20 tokens to contract (need approving before)<br>
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
	
#### TokenRemovedFromSale
name  | type | description
--|--|--
tokenId|uint256|tokenID


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

<b>c.</b> now need offer to pay commission for this tokenID "213". there are several ways:
- anyone can offer to pay commission by: 
    - calling method <a href="offertopaycommission">offerToPayCommission</a> specify tokenID and amount of tokens (describe in point a). in our cases it's WETH.
    - and approve amount to NFTContract address
- NFT owner(user1) may offer to pay a commission. in this case, the commission will be debited primarily from the owner, and if it is not enough - from those who previously offered in order list. <br>Ofcource amount need to be approved before.
- finally NFT Author can reduce commission make transfer for free. he should calls method <a href="#reducecommission">reduceCommission</a> with params `<tokenID>, 0` .

<b>d.</b> finally user2 can buy token by calling method `buy` or `buyWithTokens`. In our cases he should to make payable transaction `buy` with value 1ETH (see point b).
If commissions for author and price for old owner are enough, user2 will become a new owner of this token. Token are automatically removed from sale.



