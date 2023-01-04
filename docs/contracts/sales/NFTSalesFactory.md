# NFTSalesFactory

contracts/sales/NFTSalesFactory.sol

# Overview

Once installed will be use methods:

| **method name** | **called by** | **description** |
|-|-|-|
|<a href="#addtoblacklist">addToBlackList</a>|owner|adding instance to black list|
|<a href="#getinstancenftcontract">getInstanceNFTcontract</a>|instance|view nft contrac address |
|<a href="#instancescount">instancesCount</a>|everyone|view amount of created instances|
|<a href="#mintanddistribute">mintAndDistribute</a>|instance|mint distribute nfts|
|<a href="#owner">owner</a>|everyone||
|<a href="#produce">produce</a>|owner|creation NFTSales instance|
|<a href="#removefromblacklist">removeFromBlackList</a>|owner|adding instance to black list|
|<a href="#renounceownership">renounceOwnership</a>|everyone||
|<a href="#transferownership">transferOwnership</a>|everyone||
## *Constructor*


Arguments

| **name** | **type** | **description** |
|-|-|-|
| implementation | address |  |



## *Events*
### InstanceCreated

Arguments

| **name** | **type** | **description** |
|-|-|-|
| instance | address | not indexed |
| instancesCount | uint256 | not indexed |



### OwnershipTransferred

Arguments

| **name** | **type** | **description** |
|-|-|-|
| previousOwner | address | indexed |
| newOwner | address | indexed |



## *StateVariables*
### implementationNftSale

> Notice: Community implementation address


| **type** |
|-|
|address|



## *Functions*
### addToBlackList

> Notice: remove ability to mintAndDistibute nft tokens for certain instance

Arguments

| **name** | **type** | **description** |
|-|-|-|
| instance | address | instance's address that would be added to blacklist and prevent call mintAndDistibute |



### getInstanceNFTcontract

> Notice: view nft contrac address. used by instances in external calls

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |



### instancesCount

> Details: view amount of created instances

Outputs

| **name** | **type** | **description** |
|-|-|-|
| amount | uint256 | amount instances |



### mintAndDistribute

> Notice: mint distribute nfts

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenIds | uint256[] | array of tokens that would be a minted |
| addresses | address[] | array of desired owners to newly minted nft tokens |



### owner

> Details: Returns the address of the current owner.

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |



### produce

> Notice: creation NFTSales instance

Arguments

| **name** | **type** | **description** |
|-|-|-|
| NFTcontract | address | nftcontract's address that allows to mintAndDistribute for this factory  |
| owner | address | owner's adddress for newly created NFTSales contract |
| currency | address | currency for every sale nft token  |
| price | uint256 | price amount for every sale nft token  |
| beneficiary | address | address where which receive funds after sale |
| duration | uint64 | locked time when nft will be locked after sale |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| instance | address | address of created instance `NFTSales` |



### removeFromBlackList

> Notice: remove ability to mintAndDistibute nft tokens for certain instance

Arguments

| **name** | **type** | **description** |
|-|-|-|
| instance | address | instance's address that would be added to blacklist and prevent call mintAndDistibute |



### renounceOwnership

> Details: Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner.



### transferOwnership

> Details: Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.

Arguments

| **name** | **type** | **description** |
|-|-|-|
| newOwner | address |  |


