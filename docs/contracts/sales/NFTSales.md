# NFTSales

contracts/sales/NFTSales.sol

# Overview

Once installed will be use methods:

| **method name** | **called by** | **description** |
|-|-|-|
|<a href="#claim">claim</a>|owner of tokenIds|claim locked tokens|
|<a href="#distributeunlockedtokens">distributeUnlockedTokens</a>|anyone|claim locked tokens|
|<a href="#getblocktimestamp">getBlockTimestamp</a>|everyone||
|<a href="#initialize">initialize</a>|factory on initialization|initialization instance|
|<a href="#iswhitelisted">isWhitelisted</a>|everyone||
|<a href="#onerc721received">onERC721Received</a>|everyone||
|<a href="#owner">owner</a>|everyone||
|<a href="#remainingdays">remainingDays</a>|person in the whitelist|locked days|
|<a href="#renounceownership">renounceOwnership</a>|everyone||
|<a href="#specialpurchase">specialPurchase</a>|person in the whitelist|sale nft tokens|
|<a href="#transferownership">transferOwnership</a>|everyone||
|<a href="#whitelistadd">whitelistAdd</a>|everyone||
|<a href="#whitelistremove">whitelistRemove</a>|everyone||
## *Events*
### OwnershipTransferred

Arguments

| **name** | **type** | **description** |
|-|-|-|
| previousOwner | address | indexed |
| newOwner | address | indexed |



## *Functions*
### claim

> Notice: claim unlocked tokens

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenIds | uint256[] | array of tokens that need to be unlocked |



### distributeUnlockedTokens

> Notice: distribute unlocked tokens

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenIds | uint256[] | array of tokens that need to be unlocked |



### getBlockTimestamp

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | uint256 |  |



### initialize

> Notice: initialization 

Arguments

| **name** | **type** | **description** |
|-|-|-|
| _currency | address | currency for every sale nft token  |
| _price | uint256 | price amount for every sale nft token  |
| _beneficiary | address | address where which receive funds after sale |
| _duration | uint64 | locked time when nft will be locked after sale |



### isWhitelisted

> Notice: Checks if a address already exists in a whitelist 

Arguments

| **name** | **type** | **description** |
|-|-|-|
| addr | address | address |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| result | bool | return true if exist  |



### onERC721Received

Arguments

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |
| -/- | address |  |
| -/- | uint256 |  |
| -/- | bytes |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | bytes4 |  |



### owner

> Details: Returns the address of the current owner.

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |



### remainingDays

> Notice: amount of days that left to unlocked

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenId | uint256 |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | uint64 | amount of days that left to unlocked |



### renounceOwnership

> Details: Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner.



### specialPurchase

> Notice: sale nft tokens

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenIds | uint256[] | array of tokens that would be a sold |
| addresses | address[] | array of desired owners to newly sold nft tokens |



### transferOwnership

> Details: Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.

Arguments

| **name** | **type** | **description** |
|-|-|-|
| newOwner | address |  |



### whitelistAdd

> Notice: Adding addresses list to whitelist   Requirements: - `_addresses` cannot contains the zero address. 

Arguments

| **name** | **type** | **description** |
|-|-|-|
| _addresses | address[] | list of addresses which will be added to whitelist |



### whitelistRemove

> Notice: Removing addresses list from whitelist  Requirements: - `_addresses` cannot contains the zero address. 

Arguments

| **name** | **type** | **description** |
|-|-|-|
| _addresses | address[] | list of addresses which will be removed from whitelist |


