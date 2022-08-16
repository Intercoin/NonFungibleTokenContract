# NFTMain

This it main part of NFT contract.

# Overview

Once installed will be use methods:

| **method name** | **called by** | **description** |
|-|-|-|
|<a href="#approve">approve</a>|token owner |part of ERC721|
|<a href="#balanceof">balanceOf</a>|everyone|owner balance|
|<a href="#baseuri">baseURI</a>|everyone|global baseURI|
|<a href="#burn">burn</a>|token owner |part of ERC721|
|<a href="#buy">buy</a>|everyone||
|<a href="#buyauto">buyAuto</a>|everyone|buys NFT for specified currency|
|<a href="#buyauto">buyAuto</a>|everyone|buys NFT for native coin|
|<a href="#buyauto">buyAuto</a>|everyone|buys NFT for native coin|
|<a href="#buyauto">buyAuto</a>|everyone|buys NFT for specified currency|
|<a href="#canmanageseries">canManageSeries</a>|everyone|tells the caller whether they can manage a series|
|<a href="#canmanagetoken">canManageToken</a>|everyone|tells the caller whether they can transfer an existing token|
|<a href="#commissioninfo">commissionInfo</a>|everyone|global commission data |
|<a href="#contracturi">contractURI</a>|everyone|return contract uri|
|<a href="#costmanager">costManager</a>|everyone|costManager address|
|<a href="#factory">factory</a>|everyone|factory produced that instance|
|<a href="#freeze">freeze</a>|token owner |hold URI and suffix for token|
|<a href="#freeze">freeze</a>|token owner |hold series URI and suffix for token|
|<a href="#getapproved">getApproved</a>|everyone|account approved for `tokenId` token|
|<a href="#gethooklist">getHookList</a>|everyone|returns the list of hooks for series|
|<a href="#getseriesinfo">getSeriesInfo</a>|everyone||
|<a href="#gettokensaleinfo">getTokenSaleInfo</a>|everyone|return token's sale info|
|<a href="#isapprovedforall">isApprovedForAll</a>|everyone|see {setApprovalForAll}|
|<a href="#listforsale">listForSale</a>|token owner|list on sale|
|<a href="#mintanddistribute">mintAndDistribute</a>|owner or series author|mint and distribute new tokens|
|<a href="#mintanddistributeauto">mintAndDistributeAuto</a>|owner or series author|mint and distribute new tokens|
|<a href="#mintedcountbyseries">mintedCountBySeries</a>|everyone|amount of tokens minted in certain series|
|<a href="#name">name</a>|everyone|token's name|
|<a href="#overridecostmanager">overrideCostManager</a>|owner or factory that produced instance|set cost manager address|
|<a href="#owner">owner</a>|everyone|contract owner's address|
|<a href="#ownerof">ownerOf</a>|everyone|owner address by token id|
|<a href="#pushtokentransferhook">pushTokenTransferHook</a>|owner |link safeHook contract to series|
|<a href="#removecommission">removeCommission</a>|owner or series author|remove commission|
|<a href="#removefromsale">removeFromSale</a>|token owner|remove from sale|
|<a href="#renounceownership">renounceOwnership</a>|owner|leaves contract without owner|
|<a href="#safetransfer">safeTransfer</a>|token owner |part of ERC721|
|<a href="#safetransferfrom">safeTransferFrom</a>|token owner |part of ERC721|
|<a href="#safetransferfrom">safeTransferFrom</a>|token owner |part of ERC721|
|<a href="#seriesinfo">seriesInfo</a>|everyone|series info|
|<a href="#seriestokenindex">seriesTokenIndex</a>|everyone||
|<a href="#setapprovalforall">setApprovalForAll</a>|token owner |part of ERC721|
|<a href="#setbaseuri">setBaseURI</a>|owner|set default baseURI|
|<a href="#setcommission">setCommission</a>|owner or series author|set new commission|
|<a href="#setcontracturi">setContractURI</a>|owner|set default contract URI|
|<a href="#setnameandsymbol">setNameAndSymbol</a>|owner|sets name and symbol for contract|
|<a href="#setownercommission">setOwnerCommission</a>|owner|set owner commission|
|<a href="#setseriesinfo">setSeriesInfo</a>|owner or series author|set series Info|
|<a href="#setseriesinfo">setSeriesInfo</a>|owner or series author|set series Info|
|<a href="#setsuffix">setSuffix</a>|owner|set default suffix|
|<a href="#settrustedforwarder">setTrustedForwarder</a>|owner |set trustedForwarder address |
|<a href="#suffix">suffix</a>|everyone|global suffix|
|<a href="#supportsinterface">supportsInterface</a>|everyone|see {IERC165-supportsInterface}|
|<a href="#symbol">symbol</a>|everyone|token's symbol|
|<a href="#tokenbyindex">tokenByIndex</a>|everyone|token by index|
|<a href="#tokenexists">tokenExists</a>|everyone|returns whether `tokenId` exists.|
|<a href="#tokeninfo">tokenInfo</a>|everyone|full info by token id|
|<a href="#tokenofownerbyindex">tokenOfOwnerByIndex</a>|everyone|token of owner by index|
|<a href="#tokenuri">tokenURI</a>|everyone|return token's URI|
|<a href="#tokensbyowner">tokensByOwner</a>|everyone|returns the list of all NFTs owned by 'account' with limit|
|<a href="#totalsupply">totalSupply</a>|everyone|totalsupply|
|<a href="#transfer">transfer</a>|token owner |part of ERC721|
|<a href="#transferfrom">transferFrom</a>|token owner |part of ERC721|
|<a href="#transferownership">transferOwnership</a>|everyone|Transfers ownership of the contract to a new account|
|<a href="#trustedforwarder">trustedForwarder</a>|everyone|trusted forwarder's address|
|<a href="#unfreeze">unfreeze</a>|token owner |unhold URI and suffix for token|
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

> Details: global baseURI

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | string |  |



### burn

> Details: Burns `tokenId`. See {ERC721-burn}.

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenId | uint256 | tokenId Requirements: - The caller must own `tokenId` or be an approved operator. |



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

> Details: global commission data 

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

> Details: costManager address

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |



### factory

> Details: factory produced that instance

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |



### freeze

> Details: hold baseURI and suffix as values baseURI_ and suffix_

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenId | uint256 | token ID to freeze |
| baseURI_ | string | baseURI to hold |
| suffix_ | string | suffixto hold |



### freeze

> Details: hold baseURI and suffix as values as in current series that token belong

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenId | uint256 | token ID to freeze |



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
| tokenIds | uint256[] | list of NFT IDs to be minted |
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

> Details: amount of tokens minted in certain series

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

> Details: Returns the owner of the `tokenId` token. Requirements: - `tokenId` must exist.

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenId | uint256 |  |

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

> Details: series info

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

Arguments

| **name** | **type** | **description** |
|-|-|-|
| baseURI_ | string | baseURI |



### setCommission

> Details: set commission for series

Arguments

| **name** | **type** | **description** |
|-|-|-|
| seriesId | uint64 | seriesId |
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

> Details: global suffix

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
| tokenId | uint256 | token id |

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

> Details: trusted forwarder's address

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |



### unfreeze

> Details: unhold token

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenId | uint256 | token ID to unhold |


