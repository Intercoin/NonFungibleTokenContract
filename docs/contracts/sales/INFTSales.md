# INFTSales

contracts/sales/INFTSales.sol

# Overview

Once installed will be use methods:

| **method name** | **called by** | **description** |
|-|-|-|
|<a href="#claim">claim</a>|everyone||
|<a href="#distributeunlockedtokens">distributeUnlockedTokens</a>|everyone||
|<a href="#initialize">initialize</a>|everyone||
|<a href="#remainingdays">remainingDays</a>|everyone||
|<a href="#specialpurchase">specialPurchase</a>|everyone||
## *Functions*
### claim

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenIds | uint256[] |  |



### distributeUnlockedTokens

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenIds | uint256[] |  |



### initialize

Arguments

| **name** | **type** | **description** |
|-|-|-|
| currency | address |  |
| price | uint256 |  |
| beneficiary | address |  |
| duration | uint64 |  |



### remainingDays

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenId | uint256 |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | uint64 |  |



### specialPurchase

Arguments

| **name** | **type** | **description** |
|-|-|-|
| tokenIds | uint256[] |  |
| addresses | address[] |  |


