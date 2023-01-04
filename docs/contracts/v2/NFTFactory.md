# NFTFactory

contracts/v2/NFTFactory.sol

# Overview

Once installed will be use methods:

| **method name** | **called by** | **description** |
|-|-|-|
|<a href="#canoverridecostmanager">canOverrideCostManager</a>|everyone||
|<a href="#costmanager">costManager</a>|everyone||
|<a href="#getinstance">getInstance</a>|everyone||
|<a href="#getinstanceinfo">getInstanceInfo</a>|everyone||
|<a href="#implementation">implementation</a>|everyone||
|<a href="#implementationnftstate">implementationNFTState</a>|everyone||
|<a href="#implementationnftview">implementationNFTView</a>|everyone||
|<a href="#instances">instances</a>|everyone||
|<a href="#instancescount">instancesCount</a>|everyone||
|<a href="#owner">owner</a>|everyone||
|<a href="#produce">produce</a>|everyone||
|<a href="#produce">produce</a>|everyone||
|<a href="#renounceoverridecostmanager">renounceOverrideCostManager</a>|everyone||
|<a href="#renounceownership">renounceOwnership</a>|everyone||
|<a href="#setcostmanager">setCostManager</a>|everyone||
|<a href="#transferownership">transferOwnership</a>|everyone||
## *Constructor*


Arguments

| **name** | **type** | **description** |
|-|-|-|
| instance | address |  |
| implState | address |  |
| implView | address |  |
| costManager_ | address |  |



## *Events*
### InstanceCreated

Arguments

| **name** | **type** | **description** |
|-|-|-|
| name | string | not indexed |
| symbol | string | not indexed |
| instance | address | not indexed |
| length | uint256 | not indexed |



### OwnershipTransferred

Arguments

| **name** | **type** | **description** |
|-|-|-|
| previousOwner | address | indexed |
| newOwner | address | indexed |



### RenouncedOverrideCostManagerForInstance

Arguments

| **name** | **type** | **description** |
|-|-|-|
| instance | address | not indexed |



## *Functions*
### canOverrideCostManager

> Details: instance can call this to find out whether a given address can set the cost manager contract

Arguments

| **name** | **type** | **description** |
|-|-|-|
| account | address | the address to test |
| instance | address | the instance to test |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | bool |  |



### costManager

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |



### getInstance

Arguments

| **name** | **type** | **description** |
|-|-|-|
| -/- | bytes32 |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |



### getInstanceInfo

> Details: returns instance info

Arguments

| **name** | **type** | **description** |
|-|-|-|
| instanceId | uint256 | instance ID |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | tuple |  |



### implementation

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |



### implementationNFTState

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |



### implementationNFTView

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |



### instances

Arguments

| **name** | **type** | **description** |
|-|-|-|
| -/- | uint256 |  |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |



### instancesCount

> Details: returns the count of instances

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | uint256 |  |



### owner

> Details: Returns the address of the current owner.

Outputs

| **name** | **type** | **description** |
|-|-|-|
| -/- | address |  |



### produce

> Details: produces new instance with defined name and symbol

Arguments

| **name** | **type** | **description** |
|-|-|-|
| name | string | name of new token |
| symbol | string | symbol of new token |
| contractURI | string | contract URI |
| baseURI | string | base URI |
| suffixURI | string | suffix URI |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| instance | address | address of new contract |



### produce

> Details: produces new instance with defined name and symbol

Arguments

| **name** | **type** | **description** |
|-|-|-|
| name | string | name of new token |
| symbol | string | symbol of new token |
| contractURI | string | contract URI |

Outputs

| **name** | **type** | **description** |
|-|-|-|
| instance | address | address of new contract |



### renounceOverrideCostManager

> Details: renounces ability to override cost manager on instances

Arguments

| **name** | **type** | **description** |
|-|-|-|
| instance | address |  |



### renounceOwnership

> Details: Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner.



### setCostManager

> Details: set the costManager for all future calls to produce()

Arguments

| **name** | **type** | **description** |
|-|-|-|
| costManager_ | address |  |



### transferOwnership

> Details: Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.

Arguments

| **name** | **type** | **description** |
|-|-|-|
| newOwner | address |  |


