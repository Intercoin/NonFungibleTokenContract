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
		<td></td>
	</tr>
  <tr>
		<td><a href="#getcommission">getCommission</a></td>
		<td>anyone</td>
		<td></td>
	</tr>
  <tr>
		<td><a href="#claimlosttoken">claimLostToken</a></td>
		<td>owner</td>
		<td></td>
	</tr>
  <tr>
		<td><a href="#listforsale">listForSale</a></td>
		<td>NFTOwner</td>
		<td></td>
	</tr>
  <tr>
		<td><a href="#removefromsale">removeFromSale</a></td>
		<td>NFTOwner</td>
		<td></td>
	</tr>
  <tr>
		<td><a href="#buy">buy</a></td>
		<td>anyone</td>
		<td></td>
	</tr>
  <tr>
		<td><a href="#offertopaycommission">offerToPayCommission</a></td>
		<td>anyone</td>
		<td></td>
	</tr>
  <tr>
		<td><a href="#initialize">initialize</a></td>
		<td>owner</td>
		<td></td>
	</tr>
</tbody>
</table>

## Methods

#### initialize
initialize contract after deploy or clone. need to be called before using<br>
Params:<br>
name  | type | description
--|--|--
name|string| name of NFT token
symbol|string|symbol of NFT token
communitySettings_|tuple|


```javascript
function test() {
 console.log("look ma’, no spaces");
}
```

    
#### create
creating NFT <br>
Emitted event `NewTokenAppear(address author, uint256 tokenId);`<br>
Params:<br>
name  | type | description
--|--|--
URI|string|The Uniform Resource Identifier (URI)
commissionParams|tuple|


```javascript
function test() {
 console.log("look ma’, no spaces");
}
```


#### getCommission
getting Commission for NFT token<br>
Params:<br>
name  | type | description
--|--|--
tokenId|uint256| `tokenId`

Return Values:<br>
name  | type | description
--|--|--   
token|address|address of ERC20 token
amount|uint256|amount commission

```javascript
function test() {
 console.log("look ma’, no spaces");
}
```
    
#### claimLostToken
claiming lost token which can be mistakenly sent to contract<br>
Params:<br>
name  | type | description
--|--|--
erc20address|address| ERC20 contract's address

```javascript
function test() {
 console.log("look ma’, no spaces");
}
```

#### listForSale
adding token to sale<br>
Emitted event `TokenAddedToSale(uint256 tokenId, uint256 amount)`<br>
Params:<br>
name  | type | description
--|--|--
tokenId|uint256|`tokenId`
amount|uint256|amount in coins(bnb, eth etc.)

```javascript
function test() {
 console.log("look ma’, no spaces");
}
```


#### removeFromSale
removing token from sale list<br>
Emitted event `TokenRemovedFromSale(uint256 tokenId)`<br>
Params:<br>
name  | type | description
--|--|--
tokenId|uint256|`tokenId`

```javascript
function test() {
 console.log("look ma’, no spaces");
}
```


#### buy
can buy token by sending coins bnb or eth to contract<br>
Params:<br>
name  | type | description
--|--|--
tokenId|uint256|`tokenId`

```javascript
function test() {
 console.log("look ma’, no spaces");
}
```


#### offerToPayCommission
offering to pay commission for token<br>
Params:<br>
name  | type | description
--|--|--
tokenId|uint256|`tokenId`
amount|uint256|amount in coins(bnb, eth etc.)

```javascript
function test() {
 console.log("look ma’, no spaces");
}
```

