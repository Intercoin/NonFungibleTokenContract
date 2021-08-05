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

## Methods
<details>
<summary>methods list</summary>

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
Emitted event `TokenCreated(address author, uint256 tokenId);`<br>
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
    
#### claimLostToken
claiming lost token which can be mistakenly sent to contract<br>
Params:<br>
name  | type | description
--|--|--
erc20address|address| ERC20 contract's address

#### listForSale
adding token to sale<br>
Emitted event `TokenAddedToSale(uint256 tokenId, uint256 amount, address consumeToken)`<br>
Params:<br>
name  | type | description
--|--|--
tokenId|uint256|`tokenId`
amount|uint256|amount in coins(bnb, eth etc.)
consumeToken|address|token address. if address(0) then owner expect coins for sale

#### removeFromSale
removing token from sale list<br>
Emitted event `TokenRemovedFromSale(uint256 tokenId)`<br>
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
</details> 


## Tuples
<details>
<summary>tuples list</summary>

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
multiply|uint256| value that would be pow in interval passed since creation and multiplied to inital amount of commission
accrue|uint256| additional value that would be pow in interval passed since last transfer
intervalSeconds|uint256| interval period in seconds
reduceCommission|uint256| reduced commission in percents from final calculated value

</details> 

## Events
<details>
<summary>events list</summary>
	
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
	
event (uint256 tokenId, uint256 amount);
event (uint256 tokenId);
</details> 

