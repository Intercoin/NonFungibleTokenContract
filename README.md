# NonFungibleTokenContract
NFT contracts that support a new ERC token standard for paying commissions to authors

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
		<td><a href="#addauthors">addAuthors</a></td>
		<td>NFTAuthor</td>
		<td>adding co-authors for NFT token</td>
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
		<td><a href="#removefromsale">removeFromSale</a></td>
		<td>NFTOwner</td>
		<td>removing token from sale</td>
	</tr>
	<tr>
		<td><a href="#saleinfo">saleInfo</a></td>
		<td>anyone</td>
		<td>viewing sale info (consume tokens address and amount)</td>
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
Params:<br>
name  | type | description
--|--|--
name|string| name of NFT token
symbol|string|symbol of NFT token
<a href="#communitysettings">communitySettings_</a>|tuple|
    
#### create
creating NFT <br>
Emitted event <a href="#tokencreated">TokenCreated</a><br>
Params:<br>
name  | type | description
--|--|--
URI|string|The Uniform Resource Identifier (URI)
commissionParams|tuple|

#### getCommission
getting Commission for NFT token<br>
Params:<br>
name  | type | description
--|--|--
tokenId|uint256| `tokenId`

#### reduceCommission
reducing Commission for NFT token<br>
Params:<br>
name  | type | description
--|--|--
tokenId|uint256| `tokenId`
reduceCommissionPercent|uint256| percent in interval [0;10000]  0%-100%

Return Values:<br>
name  | type | description
--|--|--   
token|address|address of ERC20 token
amount|uint256|amount commission

#### transferAuthorship
Transfer authorship for NFT token<br>
Params:<br>
name  | type | description
--|--|--
from|address|old author's address
to|address|new author's address
tokenId|uint256|tokenID of transferred token

#### addAuthors
Adding co-authors for NFT token<br>
Params:<br>
name  | type | description
--|--|--
tokenId|uint256|tokenID of transferred token
addresses|address[]|co-authors's addresses
proportions|uint256[]|proportions (mul by 100)

#### claimLostToken
claiming lost token which can be mistakenly sent to contract<br>
Params:<br>
name  | type | description
--|--|--
erc20address|address| ERC20 contract's address

#### listForSale
adding token to sale<br>
Emitted event <a href="#tokenaddedtosale">TokenAddedToSale</a><br>
Params:<br>
name  | type | description
--|--|--
tokenId|uint256|`tokenId`
amount|uint256|amount in coins(bnb, eth etc.)
consumeToken|address|token address. if address(0) then owner expect coins for sale

#### removeFromSale
removing token from sale list<br>
Emitted event <a href="#tokenremovedfromsale">TokenRemovedFromSale</a><br>
Params:<br>
name  | type | description
--|--|--
tokenId|uint256|`tokenId`

#### saleInfo
viewing sale info<br>
Params:<br>
name  | type | description
--|--|--
tokenId|uint256|`tokenId`

#### buy
can buy token by sending coins bnb or eth to contract<br>
Params:<br>
name  | type | description
--|--|--
tokenId|uint256|`tokenId`

#### buyWithToken
can buy token by sending erc20 tokens to contract (need approving before)<br>
Params:<br>
name  | type | description
--|--|--
tokenId|uint256|`tokenId`

#### offerToPayCommission
offering to pay commission for token<br>
Params:<br>
name  | type | description
--|--|--
tokenId|uint256|`tokenId`
amount|uint256|amount in coins(bnb, eth etc.)

#### tokensByAuthor
viewing tokens list by author<br>
Params:<br>
name  | type | description
--|--|--
author|address| author's address

Return Values:<br>
name  | type | description
--|--|--   
ret|uint256[]|list of tokenIds that belongs to author


## Tuples

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
name  | type | description
--|--|--
author|address|author's address of newly created token
tokenId|uint256|tokenID of newly created token

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



