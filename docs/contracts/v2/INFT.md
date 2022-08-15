# INFT

contracts/v2/NFTBulkSaleV2.sol

# Overview

Once installed will be use methods:

| **method name** | **called by** | **description** |
|-|-|-|
|<a href="#gettokensaleinfo">getTokenSaleInfo</a>|everyone||
|<a href="#mintanddistribute">mintAndDistribute</a>|everyone||
|<a href="#seriesinfo">seriesInfo</a>|everyone||
## *Functions*
### getTokenSaleInfo

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenId | uint256 |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| isOnSale | bool |  |
| exists | bool |  |
| data | tuple |  |
| owner | address |  |



### mintAndDistribute

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenIds | uint256[] |  |
| addresses | address[] |  |



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


