// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

/**
********************
NFT FACTORY CONTRACT
********************

Although this code is available for viewing on GitHub and Etherscan, the general public is NOT given a license to freely deploy smart contracts based on this code, on any blockchains.

To prevent confusion and increase trust in the audited code bases of smart contracts we produce, we intend for there to be only ONE official Factory address on the blockchain producing these NFT smart contracts, and we are going to point a blockchain domain name at it.

Copyright (c) Intercoin Inc. All rights reserved.

ALLOWED USAGE.

Provided they agree to all the conditions of this Agreement listed below, anyone is welcome to interact with the official Factory Contract at the address 0x22222e0849704b754be0A372fFcDb9B22e4D7147 to produce smart contract instances, or to interact with instances produced in this manner by others.

Any user of software powered by this code MUST agree to the following, in order to use it. If you do not agree, refrain from using the software:

DISCLAIMERS AND DISCLOSURES.

Customer expressly recognizes that nearly any software may contain unforeseen bugs or other defects, due to the nature of software development. Moreover, because of the immutable nature of smart contracts, any such defects will persist in the software once it is deployed onto the blockchain. Customer therefore expressly acknowledges that any responsibility to obtain outside audits and analysis of any software produced by Developer rests solely with Customer.

Customer understands and acknowledges that the Software is being delivered as-is, and may contain potential defects. While Developer and its staff and partners have exercised care and best efforts in an attempt to produce solid, working software products, Developer EXPRESSLY DISCLAIMS MAKING ANY GUARANTEES, REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED, ABOUT THE FITNESS OF THE SOFTWARE, INCLUDING LACK OF DEFECTS, MERCHANTABILITY OR SUITABILITY FOR A PARTICULAR PURPOSE.

Customer agrees that neither Developer nor any other party has made any representations or warranties, nor has the Customer relied on any representations or warranties, express or implied, including any implied warranty of merchantability or fitness for any particular purpose with respect to the Software. Customer acknowledges that no affirmation of fact or statement (whether written or oral) made by Developer, its representatives, or any other party outside of this Agreement with respect to the Software shall be deemed to create any express or implied warranty on the part of Developer or its representatives.

INDEMNIFICATION.

Customer agrees to indemnify, defend and hold Developer and its officers, directors, employees, agents and contractors harmless from any loss, cost, expense (including attorney’s fees and expenses), associated with or related to any demand, claim, liability, damages or cause of action of any kind or character (collectively referred to as “claim”), in any manner arising out of or relating to any third party demand, dispute, mediation, arbitration, litigation, or any violation or breach of any provision of this Agreement by Customer.

NO WARRANTY.

THE SOFTWARE IS PROVIDED “AS IS” WITHOUT WARRANTY. DEVELOPER SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL, INCIDENTAL, CONSEQUENTIAL, OR EXEMPLARY DAMAGES FOR BREACH OF THE LIMITED WARRANTY. TO THE MAXIMUM EXTENT PERMITTED BY LAW, DEVELOPER EXPRESSLY DISCLAIMS, AND CUSTOMER EXPRESSLY WAIVES, ALL OTHER WARRANTIES, WHETHER EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR USE, OR ANY WARRANTY ARISING OUT OF ANY PROPOSAL, SPECIFICATION, OR SAMPLE, AS WELL AS ANY WARRANTIES THAT THE SOFTWARE (OR ANY ELEMENTS THEREOF) WILL ACHIEVE A PARTICULAR RESULT, OR WILL BE UNINTERRUPTED OR ERROR-FREE. THE TERM OF ANY IMPLIED WARRANTIES THAT CANNOT BE DISCLAIMED UNDER APPLICABLE LAW SHALL BE LIMITED TO THE DURATION OF THE FOREGOING EXPRESS WARRANTY PERIOD. SOME STATES DO NOT ALLOW THE EXCLUSION OF IMPLIED WARRANTIES AND/OR DO NOT ALLOW LIMITATIONS ON THE AMOUNT OF TIME AN IMPLIED WARRANTY LASTS, SO THE ABOVE LIMITATIONS MAY NOT APPLY TO CUSTOMER. THIS LIMITED WARRANTY GIVES CUSTOMER SPECIFIC LEGAL RIGHTS. CUSTOMER MAY HAVE OTHER RIGHTS WHICH VARY FROM STATE TO STATE. 

LIMITATION OF LIABILITY. 

TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL DEVELOPER BE LIABLE UNDER ANY THEORY OF LIABILITY FOR ANY CONSEQUENTIAL, INDIRECT, INCIDENTAL, SPECIAL, PUNITIVE OR EXEMPLARY DAMAGES OF ANY KIND, INCLUDING, WITHOUT LIMITATION, DAMAGES ARISING FROM LOSS OF PROFITS, REVENUE, DATA OR USE, OR FROM INTERRUPTED COMMUNICATIONS OR DAMAGED DATA, OR FROM ANY DEFECT OR ERROR OR IN CONNECTION WITH CUSTOMER'S ACQUISITION OF SUBSTITUTE GOODS OR SERVICES OR MALFUNCTION OF THE SOFTWARE, OR ANY SUCH DAMAGES ARISING FROM BREACH OF CONTRACT OR WARRANTY OR FROM NEGLIGENCE OR STRICT LIABILITY, EVEN IF DEVELOPER OR ANY OTHER PERSON HAS BEEN ADVISED OR SHOULD KNOW OF THE POSSIBILITY OF SUCH DAMAGES, AND NOTWITHSTANDING THE FAILURE OF ANY REMEDY TO ACHIEVE ITS INTENDED PURPOSE. WITHOUT LIMITING THE FOREGOING OR ANY OTHER LIMITATION OF LIABILITY HEREIN, REGARDLESS OF THE FORM OF ACTION, WHETHER FOR BREACH OF CONTRACT, WARRANTY, NEGLIGENCE, STRICT LIABILITY IN TORT OR OTHERWISE, CUSTOMER'S EXCLUSIVE REMEDY AND THE TOTAL LIABILITY OF DEVELOPER OR ANY SUPPLIER OF SERVICES TO DEVELOPER FOR ANY CLAIMS ARISING IN ANY WAY IN CONNECTION WITH OR RELATED TO THIS AGREEMENT, THE SOFTWARE, FOR ANY CAUSE WHATSOEVER, SHALL NOT EXCEED 1,000 USD.

TRADEMARKS.

This Agreement does not grant you any right in any trademark or logo of Developer or its affiliates.

LINK REQUIREMENTS.

Operators of any Websites and Apps which make use of smart contracts based on this code must conspicuously include the following phrase in their website, featuring a clickable link that takes users to nftremix.com:
"Visit https://nftremix.com to release your own NFT collection."

STAKING REQUIREMENTS.

In the future, Developer may begin requiring staking of ITR tokens in order to take further actions (such as producing series and minting tokens). Any staking requirements will first be announced on Developer's website (intercoin.org) four weeks in advance. Staking requirements will not apply to any actions already taken before they are put in place.

CUSTOM ARRANGEMENTS.

Reach out to us at intercoin.org if you are looking to obtain ITR tokens in bulk, remove link requirements forever, remove staking requirements forever, or get custom work done with your NFT projects.

ENTIRE AGREEMENT

This Agreement contains the entire agreement and understanding among the parties hereto with respect to the subject matter hereof, and supersedes all prior and contemporaneous agreements, understandings, inducements and conditions, express or implied, oral or written, of any nature whatsoever with respect to the subject matter hereof. The express terms hereof control and supersede any course of performance and/or usage of the trade inconsistent with any of the terms hereof. Provisions from previous Agreements executed between Customer and Developer., which are not expressly dealt with in this Agreement, will remain in effect.

SUCCESSORS AND ASSIGNS

This Agreement shall continue to apply to any successors or assigns of either party, or any corporation or other entity acquiring all or substantially all the assets and business of either party whether by operation of law or otherwise.

ARBITRATION

All disputes related to this agreement shall be governed by and interpreted in accordance with the laws of New York, without regard to principles of conflict of laws. The parties to this agreement will submit all disputes arising under this agreement to arbitration in New York City, New York before a single arbitrator of the American Arbitration Association (“AAA”). The arbitrator shall be selected by application of the rules of the AAA, or by mutual agreement of the parties, except that such arbitrator shall be an attorney admitted to practice law New York. No party to this agreement will challenge the jurisdiction or venue provisions as provided in this section. No party to this agreement will challenge the jurisdiction or venue provisions as provided in this section.
**/

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "../interfaces/IFactory.sol";
import "../interfaces/IInstanceContract.sol";

contract FactoryV1 is Ownable, IFactory {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    
    address public costManager;
    address public implementation;
    mapping(bytes32 => address) public getInstance; // keccak256("name", "symbol") => instance address
    mapping(address => InstanceInfo) private _instanceInfos;
    address[] public instances;
    EnumerableSetUpgradeable.AddressSet private _renouncedOverrideCostManager;
       
    struct InstanceInfo {
        string name;
        string symbol;
        address creator;
    }
    
    event InstanceCreated(string name, string symbol, address instance, uint256 length);
    event RenouncedOverrideCostManagerForInstance(address instance);

    constructor (
        address instance, 
        address costManager_
    ) {
        implementation = instance;
        costManager = costManager_;

        
    }

    /**
    * @dev returns the count of instances
    */
    function instancesCount() external view returns (uint256) {
        return instances.length;
    }
    
    /**
    * @dev set the costManager for all future calls to produce()
    */
    function setCostManager(address costManager_) public onlyOwner {
        costManager = costManager_;
    }
    
    /**
    * @dev renounces ability to override cost manager on instances
    */
    function renounceOverrideCostManager(address instance) public onlyOwner {
        _renouncedOverrideCostManager.add(instance);
        emit RenouncedOverrideCostManagerForInstance(instance);
    }
    
    /** 
    * @dev instance can call this to find out whether a given address can set the cost manager contract
    * @param account the address to test
    * @param instance the instance to test
    */
    function canOverrideCostManager(
        address account, 
        address instance
    ) 
        external 
        override 
        view
        returns (bool) 
    {
        return (account == owner() && !_renouncedOverrideCostManager.contains(instance));
    }

    /**
    * @dev produces new instance with defined name and symbol
    * @param name name of new token
    * @param symbol symbol of new token
    * @param contractURI contract URI
    * @return instance address of new contract
    */
    function produce(
        string memory name,
        string memory symbol,
        string memory contractURI
    ) 
        public 
        returns (address instance) 
    {
        return _produce(
            name,
            symbol,
            contractURI,
            "",
            ""
        );
    }

    /**
    * @dev produces new instance with defined name and symbol
    * @param name name of new token
    * @param symbol symbol of new token
    * @param contractURI contract URI
    * @param baseURI base URI
    * @param suffixURI suffix URI
    * @return instance address of new contract
    */
    function produce(
        string memory name,
        string memory symbol,
        string memory contractURI,
        string memory baseURI,
        string memory suffixURI
    ) 
        public 
        returns (address instance) 
    {
        return _produce(
            name,
            symbol,
            contractURI,
            baseURI,
            suffixURI
        );
    }

    function _produce(
        string memory name,
        string memory symbol,
        string memory contractURI,
        string memory baseURI,
        string memory suffixURI

    ) 
        internal 
        returns (address instance) 
    {
        _createInstanceValidate(name, symbol);
        address instanceCreated = _createInstance(name, symbol);
        require(instanceCreated != address(0), "StakingFactory: INSTANCE_CREATION_FAILED");
        address ms = _msgSender();
        IInstanceContract(instanceCreated).initialize(
            name, 
            symbol, 
            contractURI, 
            baseURI,
            suffixURI,
            costManager, 
            ms
        );
        Ownable(instanceCreated).transferOwnership(ms);
        instance = instanceCreated;
    }

    
     /**
    * @dev returns instance info
    * @param instanceId instance ID
    */
    function getInstanceInfo(
        uint256 instanceId
    ) public view returns(InstanceInfo memory) {
        
        address instance = instances[instanceId];
        return _instanceInfos[instance];
    }
    
    
    function _createInstanceValidate(
        string memory name,
        string memory symbol
    ) internal view {
        require((bytes(name)).length != 0, "Factory: EMPTY NAME");
        require((bytes(symbol)).length != 0, "Factory: EMPTY SYMBOL");
        address instance = getInstance[keccak256(abi.encodePacked(name, symbol))];
        require(instance == address(0), "Factory: ALREADY_EXISTS");
    }

    function _createInstance(
        string memory name,
        string memory symbol
    ) internal returns (address instance) {
        
        instance = _createClone(implementation);
        
        getInstance[keccak256(abi.encodePacked(name, symbol))] = instance;
        instances.push(instance);
        _instanceInfos[instance] = InstanceInfo(
            name,
            symbol,
            _msgSender()
        );
        emit InstanceCreated(name, symbol, instance, instances.length);
    }

    function _createClone(address target) internal returns (address result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
        let clone := mload(0x40)
        mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
        mstore(add(clone, 0x14), targetBytes)
        mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
        result := create(0, clone, 0x37)
        }
    }
        
}
