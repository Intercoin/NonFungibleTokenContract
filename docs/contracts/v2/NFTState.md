# NFTState

contracts/v2/NFTState.sol

# Overview

Once installed will be use methods:

| **method name** | **called by** | **description** |
|-|-|-|
|<a href="#approve">approve</a>|everyone||
|<a href="#balanceof">balanceOf</a>|everyone||
|<a href="#baseuri">baseURI</a>|everyone||
|<a href="#burn">burn</a>|everyone||
|<a href="#buy">buy</a>|everyone||
|<a href="#buyauto">buyAuto</a>|everyone||
|<a href="#buyauto">buyAuto</a>|everyone||
|<a href="#buyauto">buyAuto</a>|everyone||
|<a href="#buyauto">buyAuto</a>|everyone||
|<a href="#commissioninfo">commissionInfo</a>|everyone||
|<a href="#costmanager">costManager</a>|everyone||
|<a href="#factory">factory</a>|everyone||
|<a href="#freeze">freeze</a>|everyone||
|<a href="#freeze">freeze</a>|everyone||
|<a href="#getapproved">getApproved</a>|everyone||
|<a href="#initialize">initialize</a>|everyone||
|<a href="#isapprovedforall">isApprovedForAll</a>|everyone||
|<a href="#listforsale">listForSale</a>|everyone||
|<a href="#mintanddistribute">mintAndDistribute</a>|everyone||
|<a href="#mintanddistributeauto">mintAndDistributeAuto</a>|owner or series author|mint and distribute new tokens|
|<a href="#mintedcountbyseries">mintedCountBySeries</a>|everyone||
|<a href="#name">name</a>|everyone||
|<a href="#overridecostmanager">overrideCostManager</a>|everyone||
|<a href="#owner">owner</a>|everyone||
|<a href="#ownerof">ownerOf</a>|everyone||
|<a href="#pushtokentransferhook">pushTokenTransferHook</a>|everyone||
|<a href="#removecommission">removeCommission</a>|everyone||
|<a href="#removefromsale">removeFromSale</a>|everyone||
|<a href="#renounceownership">renounceOwnership</a>|everyone||
|<a href="#safetransfer">safeTransfer</a>|everyone||
|<a href="#safetransferfrom">safeTransferFrom</a>|everyone||
|<a href="#safetransferfrom">safeTransferFrom</a>|everyone||
|<a href="#seriesinfo">seriesInfo</a>|everyone||
|<a href="#seriestokenindex">seriesTokenIndex</a>|everyone||
|<a href="#setapprovalforall">setApprovalForAll</a>|everyone||
|<a href="#setbaseuri">setBaseURI</a>|everyone||
|<a href="#setcommission">setCommission</a>|everyone||
|<a href="#setcontracturi">setContractURI</a>|everyone||
|<a href="#setnameandsymbol">setNameAndSymbol</a>|everyone||
|<a href="#setownercommission">setOwnerCommission</a>|everyone||
|<a href="#setseriesinfo">setSeriesInfo</a>|everyone||
|<a href="#setseriesinfo">setSeriesInfo</a>|everyone||
|<a href="#setsuffix">setSuffix</a>|everyone||
|<a href="#settrustedforwarder">setTrustedForwarder</a>|everyone||
|<a href="#suffix">suffix</a>|everyone||
|<a href="#supportsinterface">supportsInterface</a>|everyone||
|<a href="#symbol">symbol</a>|everyone||
|<a href="#tokenbyindex">tokenByIndex</a>|everyone||
|<a href="#tokenofownerbyindex">tokenOfOwnerByIndex</a>|everyone||
|<a href="#tokenuri">tokenURI</a>|everyone||
|<a href="#totalsupply">totalSupply</a>|everyone||
|<a href="#transfer">transfer</a>|everyone||
|<a href="#transferfrom">transferFrom</a>|everyone||
|<a href="#transferownership">transferOwnership</a>|everyone||
|<a href="#trustedforwarder">trustedForwarder</a>|everyone||
|<a href="#unfreeze">unfreeze</a>|everyone||
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

> Details: Gives permission to `to` to transfer `tokenId` token to another account. The approval is cleared when the token is transferred. Only a single account can be approved at a time, so approving the zero address clears previous approvals. Requirements: - The caller must own the token or be an approved operator. - `tokenId` must exist. Emits an {Approval} event.

Arguments

| **name** | **type** | **description** |
|-|-|-|
| to | address |  |
| tokenId | uint256 |  |



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



### burn

> Details: Burns `tokenId`. See {ERC721-_burn}. Requirements: - The caller must own `tokenId` or be an approved operator.

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenId | uint256 |  |



### buy

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenIds | uint256[] |  |
| currency | address |  |
| totalPrice | uint256 |  |
| safe | bool |  |
| hookCount | uint256 |  |
| buyFor | address |  |



### buyAuto

> Details: buys NFT for native coin with undefined id.  Id will be generate as usually by auto inrement but belong to seriesId and transfer token if it is on sale

Arguments

| **name** | **type** | **description** |
|-|-|-|
| seriesId | uint64 | series ID whene we can find free token to buy |
| currency | address | address of token to pay with |
| price | uint256 | amount of specified token to pay |
| safe | bool | use safeMint and safeTransfer or not |
| hookCount | uint256 | number of hooks  |
| buyFor | address | address of new nft owner |



### buyAuto

> Details: buys NFT for native coin with undefined id.  Id will be generate as usually by auto inrement but belong to seriesId and transfer token if it is on sale

Arguments

| **name** | **type** | **description** |
|-|-|-|
| seriesId | uint64 | series ID whene we can find free token to buy |
| price | uint256 | amount of specified native coin to pay |
| safe | bool | use safeMint and safeTransfer or not,  |
| hookCount | uint256 | number of hooks  |



### buyAuto

> Details: buys NFT for native coin with undefined id.  Id will be generate as usually by auto inrement but belong to seriesId and transfer token if it is on sale

Arguments

| **name** | **type** | **description** |
|-|-|-|
| seriesId | uint64 | series ID whene we can find free token to buy |
| price | uint256 | amount of specified native coin to pay |
| safe | bool | use safeMint and safeTransfer or not,  |
| hookCount | uint256 | number of hooks  |
| buyFor | address | address of new nft owner |



### buyAuto

> Details: buys NFT for native coin with undefined id.  Id will be generate as usually by auto inrement but belong to seriesId and transfer token if it is on sale

Arguments

| **name** | **type** | **description** |
|-|-|-|
| seriesId | uint64 | series ID whene we can find free token to buy |
| currency | address | address of token to pay with |
| price | uint256 | amount of specified token to pay |
| safe | bool | use safeMint and safeTransfer or not |
| hookCount | uint256 | number of hooks  |



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



### freeze

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenId | uint256 |  |
| baseURI | string |  |
| suffix | string |  |



### freeze

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenId | uint256 |  |



### getApproved

Arguments

| **name** | **type** | **description** |
|-|-|-|
| -/- | uint256 |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |



### initialize

Arguments

| **name** | **type** | **description** |
|-|-|-|
| name_ | string |  |
| symbol_ | string |  |
| contractURI_ | string |  |
| baseURI_ | string |  |
| suffixURI_ | string |  |
| costManager_ | address |  |
| producedBy_ | address |  |



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



### listForSale

> Details: lists on sale NFT with defined token ID with specified terms of sale

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenId | uint256 | token ID |
| price | uint256 | price for sale  |
| currency | address | currency of sale  |
| duration | uint64 | duration of sale  |



### mintAndDistribute

> Details: mints and distributes NFTs with specified IDs to specified addresses

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenIds | uint256[] | list of NFT IDs t obe minted |
| addresses | address[] | list of receiver addresses |



### mintAndDistributeAuto

> Details: mints and distributes `amount` NFTs by `seriesId` to `account`

Arguments

| **name** | **type** | **description** |
|-|-|-|
| seriesId | uint64 | seriesId |
| account | address | receiver addresses |
| amount | uint256 | amount of tokens |



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



### overrideCostManager

> Details: sets the utility token

Arguments

| **name** | **type** | **description** |
|-|-|-|
| costManager_ | address | new address of utility token, or 0 |



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



### pushTokenTransferHook

> Details: link safeHook contract to certain series

Arguments

| **name** | **type** | **description** |
|-|-|-|
| seriesId | uint64 | series ID |
| contractAddress | address | address of SafeHook contract |



### removeCommission

> Notice: clear commission for series

Arguments

| **name** | **type** | **description** |
|-|-|-|
| seriesId | uint64 | seriesId |



### removeFromSale

> Details: removes from sale NFT with defined token ID

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenId | uint256 | token ID |



### renounceOwnership

> Details: Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner.



### safeTransfer

> Details: Safely transfers `tokenId` token from sender to `to`. Requirements: - `to` cannot be the zero address. - `tokenId` token must exist and be owned by sender. - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer. Emits a {Transfer} event.

Arguments

| **name** | **type** | **description** |
|-|-|-|
| to | address |  |
| tokenId | uint256 |  |



### safeTransferFrom

> Details: Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients are aware of the ERC721 protocol to prevent tokens from being forever locked. Requirements: - `from` cannot be the zero address. - `to` cannot be the zero address. - `tokenId` token must exist and be owned by `from`. - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}. - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer. Emits a {Transfer} event.

Arguments

| **name** | **type** | **description** |
|-|-|-|
| from | address |  |
| to | address |  |
| tokenId | uint256 |  |



### safeTransferFrom

> Details: Safely transfers `tokenId` token from `from` to `to`. Requirements: - `from` cannot be the zero address. - `to` cannot be the zero address. - `tokenId` token must exist and be owned by `from`. - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}. - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer. Emits a {Transfer} event.

Arguments

| **name** | **type** | **description** |
|-|-|-|
| from | address |  |
| to | address |  |
| tokenId | uint256 |  |
| _data | bytes |  |



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

> Details: Approve or remove `operator` as an operator for the caller. Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller. Requirements: - The `operator` cannot be the caller. Emits an {ApprovalForAll} event.

Arguments

| **name** | **type** | **description** |
|-|-|-|
| operator | address |  |
| approved | bool |  |



### setBaseURI

> Details: sets the default baseURI for the whole contract

Arguments

| **name** | **type** | **description** |
|-|-|-|
| baseURI_ | string | the prefix to prepend to URIs |



### setCommission

> Notice: set commission for series

Arguments

| **name** | **type** | **description** |
|-|-|-|
| seriesId | uint64 |  |
| commissionData | tuple | new commission data |



### setContractURI

> Details: sets contract URI. 

Arguments

| **name** | **type** | **description** |
|-|-|-|
| newContractURI | string | new contract URI |



### setNameAndSymbol

> Details: sets name and symbol for contract

Arguments

| **name** | **type** | **description** |
|-|-|-|
| newName | string | new name  |
| newSymbol | string | new symbol  |



### setOwnerCommission

> Notice: set commission paid to contract owner

Arguments

| **name** | **type** | **description** |
|-|-|-|
| commission | tuple | new commission info |



### setSeriesInfo

> Details: sets information for series with 'seriesId'. 

Arguments

| **name** | **type** | **description** |
|-|-|-|
| seriesId | uint64 | series ID |
| info | tuple | new info to set |
| transferWhitelistSettings | tuple |  |
| buyWhitelistSettings | tuple |  |



### setSeriesInfo

> Details: sets information for series with 'seriesId'. 

Arguments

| **name** | **type** | **description** |
|-|-|-|
| seriesId | uint64 | series ID |
| info | tuple | new info to set |



### setSuffix

> Details: sets the default URI suffix for the whole contract

Arguments

| **name** | **type** | **description** |
|-|-|-|
| suffix_ | string | the suffix to append to URIs |



### setTrustedForwarder

> Details: the owner should be absolutely sure they trust the trustedForwarder

Arguments

| **name** | **type** | **description** |
|-|-|-|
| trustedForwarder_ | address | must be a smart contract that was audited |



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



### transfer

> Details: Transfers `tokenId` token from sender to `to`. WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible. Requirements: - `to` cannot be the zero address. - `tokenId` token must be owned by sender. Emits a {Transfer} event.

Arguments

| **name** | **type** | **description** |
|-|-|-|
| to | address |  |
| tokenId | uint256 |  |



### transferFrom

> Details: Transfers `tokenId` token from `from` to `to`. WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible. Requirements: - `from` cannot be the zero address. - `to` cannot be the zero address. - `tokenId` token must be owned by `from`. - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}. Emits a {Transfer} event.

Arguments

| **name** | **type** | **description** |
|-|-|-|
| from | address |  |
| to | address |  |
| tokenId | uint256 |  |



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



### unfreeze

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenId | uint256 |  |


