# NFTStorage

contracts/v2/NFTStorage.sol

> Details: Storage for any separated parts of NFT: NFTState, NFTView, etc. For all parts storage must be the same.  So need to extend by common contrtacts  like Ownable, Reentrancy, ERC721. that's why we have to leave stubs. we will implement only in certain contracts.  for example "name()", "symbol()" in NFTView.sol and "transfer()", "transferFrom()"  in NFTState.sol Another way are to decompose Ownable, Reentrancy, ERC721 to single flat contract and implement interface methods only for NFTMain.sol Or make like this  NFTStorage->NFTBase->NFTStubs->NFTMain,  NFTStorage->NFTBase->NFTState NFTStorage->NFTBase->NFTView  Here: NFTStorage - only state variables NFTBase - common thing that used in all contracts(for state and for view) like _ownerOf(), or can manageSeries,... NFTStubs - implemented stubs to make NFTMain are fully ERC721, ERC165, etc NFTMain - contract entry point

# Overview

Once installed will be use methods:

| **method name** | **called by** | **description** |
|-|-|-|
|<a href="#approve">approve</a>|everyone||
|<a href="#balanceof">balanceOf</a>|everyone||
|<a href="#baseuri">baseURI</a>|everyone||
|<a href="#commissioninfo">commissionInfo</a>|everyone||
|<a href="#costmanager">costManager</a>|everyone||
|<a href="#factory">factory</a>|everyone||
|<a href="#getapproved">getApproved</a>|everyone||
|<a href="#isapprovedforall">isApprovedForAll</a>|everyone||
|<a href="#mintedcountbyseries">mintedCountBySeries</a>|everyone||
|<a href="#name">name</a>|everyone||
|<a href="#owner">owner</a>|everyone||
|<a href="#ownerof">ownerOf</a>|everyone||
|<a href="#renounceownership">renounceOwnership</a>|everyone||
|<a href="#safetransfer">safeTransfer</a>|everyone||
|<a href="#safetransferfrom">safeTransferFrom</a>|everyone||
|<a href="#safetransferfrom">safeTransferFrom</a>|everyone||
|<a href="#seriesinfo">seriesInfo</a>|everyone||
|<a href="#seriestokenindex">seriesTokenIndex</a>|everyone||
|<a href="#setapprovalforall">setApprovalForAll</a>|everyone||
|<a href="#suffix">suffix</a>|everyone||
|<a href="#supportsinterface">supportsInterface</a>|everyone||
|<a href="#symbol">symbol</a>|everyone||
|<a href="#tokenbyindex">tokenByIndex</a>|everyone||
|<a href="#tokenofownerbyindex">tokenOfOwnerByIndex</a>|everyone||
|<a href="#tokenuri">tokenURI</a>|everyone||
|<a href="#totalsupply">totalSupply</a>|everyone||
|<a href="#transferfrom">transferFrom</a>|everyone||
|<a href="#transferownership">transferOwnership</a>|everyone||
|<a href="#trustedforwarder">trustedForwarder</a>|everyone||
## *Events*
### Approval

Arguments

| **name** | **type** | **description** |
|-|-|-|
| owner | address | indexed |
| approved | address | indexed |
| tokenId | uint256 | indexed |



### ApprovalForAll

Arguments

| **name** | **type** | **description** |
|-|-|-|
| owner | address | indexed |
| operator | address | indexed |
| approved | bool | not indexed |



### NewHook

Arguments

| **name** | **type** | **description** |
|-|-|-|
| seriesId | uint64 | not indexed |
| contractAddress | address | not indexed |



### OwnershipTransferred

Arguments

| **name** | **type** | **description** |
|-|-|-|
| previousOwner | address | indexed |
| newOwner | address | indexed |



### SeriesPutOnSale

Arguments

| **name** | **type** | **description** |
|-|-|-|
| seriesId | uint64 | indexed |
| price | uint256 | not indexed |
| autoincrement | uint256 | not indexed |
| currency | address | not indexed |
| onSaleUntil | uint64 | not indexed |



### SeriesRemovedFromSale

Arguments

| **name** | **type** | **description** |
|-|-|-|
| seriesId | uint64 | indexed |



### TokenBought

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenId | uint256 | indexed |
| seller | address | indexed |
| buyer | address | indexed |
| currency | address | not indexed |
| price | uint256 | not indexed |



### TokenPutOnSale

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenId | uint256 | indexed |
| seller | address | indexed |
| price | uint256 | not indexed |
| currency | address | not indexed |
| onSaleUntil | uint64 | not indexed |



### TokenRemovedFromSale

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenId | uint256 | indexed |
| account | address | not indexed |



### Transfer

Arguments

| **name** | **type** | **description** |
|-|-|-|
| from | address | indexed |
| to | address | indexed |
| tokenId | uint256 | indexed |



## *Functions*
### approve

Arguments

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |
| -/- | uint256 |  |



### balanceOf

Arguments

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | uint256 |  |



### baseURI

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | string |  |



### commissionInfo

Outputs

| **name** | **type** | **description** |
|-|-|-|
| maxValue | uint64 |  |
| minValue | uint64 |  |
| ownerCommission | tuple |  |



### costManager

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |



### factory

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |



### getApproved

Arguments

| **name** | **type** | **description** |
|-|-|-|
| -/- | uint256 |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |



### isApprovedForAll

Arguments

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |
| -/- | address |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | bool |  |



### mintedCountBySeries

Arguments

| **name** | **type** | **description** |
|-|-|-|
| -/- | uint64 |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | uint256 |  |



### name

> Details: Returns the token collection name.

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | string |  |



### owner

> Details: Returns the address of the current owner.

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |



### ownerOf

Arguments

| **name** | **type** | **description** |
|-|-|-|
| -/- | uint256 |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |



### renounceOwnership

> Details: Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner.



### safeTransfer

Arguments

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |
| -/- | uint256 |  |



### safeTransferFrom

Arguments

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |
| -/- | address |  |
| -/- | uint256 |  |



### safeTransferFrom

Arguments

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |
| -/- | address |  |
| -/- | uint256 |  |
| -/- | bytes |  |



### seriesInfo

Arguments

| **name** | **type** | **description** |
|-|-|-|
| -/- | uint64 |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| author | address |  |
| limit | uint32 |  |
| saleInfo | tuple |  |
| commission | tuple |  |
| baseURI | string |  |
| suffix | string |  |



### seriesTokenIndex

Arguments

| **name** | **type** | **description** |
|-|-|-|
| -/- | uint64 |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | uint192 |  |



### setApprovalForAll

Arguments

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |
| -/- | bool |  |



### suffix

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | string |  |



### supportsInterface

> Details: Returns true if this contract implements the interface defined by `interfaceId`. See the corresponding https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section] to learn more about how these ids are created. This function call must use less than 30 000 gas.

Arguments

| **name** | **type** | **description** |
|-|-|-|
| interfaceId | bytes4 |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | bool |  |



### symbol

> Details: Returns the token collection symbol.

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | string |  |



### tokenByIndex

Arguments

| **name** | **type** | **description** |
|-|-|-|
| -/- | uint256 |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | uint256 |  |



### tokenOfOwnerByIndex

Arguments

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |
| -/- | uint256 |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | uint256 |  |



### tokenURI

Arguments

| **name** | **type** | **description** |
|-|-|-|
| -/- | uint256 |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | string |  |



### totalSupply

> Details: Returns the total amount of tokens stored by the contract.

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | uint256 |  |



### transferFrom

Arguments

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |
| -/- | address |  |
| -/- | uint256 |  |



### transferOwnership

> Details: Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.

Arguments

| **name** | **type** | **description** |
|-|-|-|
| newOwner | address |  |



### trustedForwarder

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |


