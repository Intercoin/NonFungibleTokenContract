# NFTView

contracts/v2/NFTView.sol

# Overview

Once installed will be use methods:

| **method name** | **called by** | **description** |
|-|-|-|
|<a href="#approve">approve</a>|everyone||
|<a href="#balanceof">balanceOf</a>|everyone||
|<a href="#baseuri">baseURI</a>|everyone||
|<a href="#canmanageseries">canManageSeries</a>|everyone||
|<a href="#canmanagetoken">canManageToken</a>|everyone||
|<a href="#commissioninfo">commissionInfo</a>|everyone||
|<a href="#contracturi">contractURI</a>|everyone||
|<a href="#costmanager">costManager</a>|everyone||
|<a href="#factory">factory</a>|everyone||
|<a href="#getapproved">getApproved</a>|everyone||
|<a href="#gethooklist">getHookList</a>|everyone||
|<a href="#getseriesinfo">getSeriesInfo</a>|everyone||
|<a href="#gettokensaleinfo">getTokenSaleInfo</a>|everyone||
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
|<a href="#tokenexists">tokenExists</a>|everyone||
|<a href="#tokeninfo">tokenInfo</a>|everyone||
|<a href="#tokenofownerbyindex">tokenOfOwnerByIndex</a>|everyone||
|<a href="#tokenuri">tokenURI</a>|everyone||
|<a href="#tokensbyowner">tokensByOwner</a>|everyone||
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

> Details: Returns the number of tokens in ``owner``'s account.

Arguments

| **name** | **type** | **description** |
|-|-|-|
| owner | address |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | uint256 |  |



### baseURI

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | string |  |



### canManageSeries

> Details: tells the caller whether they can set info for a series, manage amount of commissions for the series, mint and distribute tokens from it, etc.

Arguments

| **name** | **type** | **description** |
|-|-|-|
| account | address | address to check |
| seriesId | uint64 | the id of the series being asked about |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | bool |  |



### canManageToken

> Details: tells the caller whether they can transfer an existing token, list it for sale and remove it from sale. Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.

Arguments

| **name** | **type** | **description** |
|-|-|-|
| account | address | address to check |
| tokenId | uint256 | the id of the tokens being asked about |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | bool |  |



### commissionInfo

Outputs

| **name** | **type** | **description** |
|-|-|-|
| maxValue | uint64 |  |
| minValue | uint64 |  |
| ownerCommission | tuple |  |



### contractURI

> Details: returns contract URI. 

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | string |  |



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

> Details: Returns the account approved for `tokenId` token. Requirements: - `tokenId` must exist.

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenId | uint256 |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |



### getHookList

> Details: returns the list of hooks for series with `seriesId`

Arguments

| **name** | **type** | **description** |
|-|-|-|
| seriesId | uint64 | series ID |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | address[] |  |



### getSeriesInfo

Arguments

| **name** | **type** | **description** |
|-|-|-|
| seriesId | uint64 |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| author | address |  |
| limit | uint32 |  |
| onSaleUntil | uint64 |  |
| currency | address |  |
| price | uint256 |  |
| value | uint64 |  |
| recipient | address |  |
| baseURI | string |  |
| suffix | string |  |



### getTokenSaleInfo

> Details: returns if token is on sale or not,  whether it exists or not, as well as data about the sale and its owner

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenId | uint256 | token ID  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| isOnSale | bool |  |
| exists | bool |  |
| data | tuple |  |
| owner | address |  |



### isApprovedForAll

> Details: Returns if the `operator` is allowed to manage all of the assets of `owner`. See {setApprovalForAll}

Arguments

| **name** | **type** | **description** |
|-|-|-|
| owner | address |  |
| operator | address |  |

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

> Details: Returns the owner of the `tokenId` token. Requirements: - `tokenId` must exist.

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenId | uint256 |  |

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

> Details: See {IERC165-supportsInterface}.

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

> Details: Returns a token ID at a given `index` of all the tokens stored by the contract. Use along with {totalSupply} to enumerate all tokens.

Arguments

| **name** | **type** | **description** |
|-|-|-|
| index | uint256 |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | uint256 |  |



### tokenExists

> Details: Returns whether `tokenId` exists. Tokens start existing when they are minted (`_mint`), and stop existing when they are burned (`_burn`).

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenId | uint256 |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | bool |  |



### tokenInfo

> Details: returns info for token and series that belong to

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenId | uint256 | token ID  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | tuple |  |



### tokenOfOwnerByIndex

> Details: Returns a token ID owned by `owner` at a given `index` of its token list. Use along with {balanceOf} to enumerate all of ``owner``'s tokens.

Arguments

| **name** | **type** | **description** |
|-|-|-|
| owner | address |  |
| index | uint256 |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | uint256 |  |



### tokenURI

> Details: Returns the Uniform Resource Identifier (URI) for `tokenId` token.

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenId | uint256 |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | string |  |



### tokensByOwner

> Details: returns the list of all NFTs owned by 'account' with limit

Arguments

| **name** | **type** | **description** |
|-|-|-|
| account | address | address of account |
| limit | uint32 |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| ret | uint256[] |  |



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


