/**
 *Submitted for verification at Etherscan.io on 2021-12-30
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
*********************
NFT TEMPLATE CONTRACT
*********************

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


// File: @openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol


// OpenZeppelin Contracts v4.4.0 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSetUpgradeable {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// File: contracts/interfaces/IFactory.sol


pragma solidity ^0.8.0;

interface IFactory {
    function canOverrideCostManager(address operator, address instance) external view returns (bool);
}

// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol


// OpenZeppelin Contracts v4.4.0 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "ALREADY_INITIALIZED");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol


// OpenZeppelin Contracts v4.4.0 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "REENTRANCY");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol


// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

pragma solidity ^0.8.0;


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol


// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

pragma solidity ^0.8.0;



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "OWNER_ONLY");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "ZERO_ADDRESS");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

// File: contracts/lib/StringsW0x.sol


// OpenZeppelin Contracts v4.4.0 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsW0x {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    
    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        int256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, int256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * uint256(length));
        for (int256 i = 2 * length - 1; i > -1; --i) {
            buffer[uint256(i)] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "HEX_LENGTH_TOO_SHORT");
        return string(buffer);
    }
}

// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol


// OpenZeppelin Contracts v4.4.0 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "INSUFFICIENT_BALANCE");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "INSUFFICIENT_BALANCE");
        require(isContract(target), "NON_CONTRACT");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "NON_CONTRACT");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol


// OpenZeppelin Contracts v4.4.0 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: contracts/interfaces/ISafeHook.sol


pragma solidity ^0.8.0;


interface ISafeHook is IERC165Upgradeable {
    function executeHook(address from, address to, uint256 tokenId) external returns(bool success);
}
// File: contracts/interfaces/ICostManager.sol


pragma solidity ^0.8.0;


interface ICostManager is IERC165Upgradeable {
    function accountForOperation(address sender, uint256 info, uint256 param1, uint256 param2) external returns(uint256 spent, uint256 remaining);
}

// File: @openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol


// OpenZeppelin Contracts v4.4.0 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;



/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol


// OpenZeppelin Contracts v4.4.0 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// File: @openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol


// OpenZeppelin Contracts v4.4.0 (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721EnumerableUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// File: @openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721MetadataUpgradeable.sol


// OpenZeppelin Contracts v4.4.0 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// File: @openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol


// OpenZeppelin Contracts v4.4.0 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol


// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/ERC721UpgradeableExt.sol



pragma solidity ^0.8.0;












abstract contract ERC721UpgradeableExt is 
    ERC165Upgradeable, 
    IERC721MetadataUpgradeable,
    IERC721EnumerableUpgradeable, 
    OwnableUpgradeable, 
    ReentrancyGuardUpgradeable
{

    using AddressUpgradeable for address;
    using StringsW0x for uint256;
    
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Contract URI
    string internal _contractURI;    
    
    // Address of factory that produced this instance
    address public factory;
    
    // Utility token, if any, to manage during operations
    address public costManager;

    address public trustedForwarder;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;
    
    // Constants for shifts
    uint8 internal constant SERIES_SHIFT_BITS = 192; // 256 - 64
    uint8 internal constant OPERATION_SHIFT_BITS = 240;  // 256 - 16
    
    // Constants representing operations
    uint8 internal constant OPERATION_INITIALIZE = 0x0;
    uint8 internal constant OPERATION_SETMETADATA = 0x1;
    uint8 internal constant OPERATION_SETSERIESINFO = 0x2;
    uint8 internal constant OPERATION_SETOWNERCOMMISSION = 0x3;
    uint8 internal constant OPERATION_SETCOMMISSION = 0x4;
    uint8 internal constant OPERATION_REMOVECOMMISSION = 0x5;
    uint8 internal constant OPERATION_LISTFORSALE = 0x6;
    uint8 internal constant OPERATION_REMOVEFROMSALE = 0x7;
    uint8 internal constant OPERATION_MINTANDDISTRIBUTE = 0x8;
    uint8 internal constant OPERATION_BURN = 0x9;
    uint8 internal constant OPERATION_BUY = 0xA;
    uint8 internal constant OPERATION_TRANSFER = 0xB;

    address internal constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    uint256 internal constant FRACTION = 100000;
    
    string public baseURI;
    string public suffix;
    
    mapping (uint256 => SaleInfoToken) public salesInfoToken;  // tokenId => SaleInfoToken
    mapping (uint256 => SeriesInfo) public seriesInfo;  // seriesId => SeriesInfo
    CommissionInfo public commissionInfo; // Global commission data 

    mapping(uint256 => uint256) public mintedCountBySeries;
    
    struct SaleInfoToken { 
        SaleInfo saleInfo;
        uint256 ownerCommissionValue;
        uint256 authorCommissionValue;
    }
    struct SaleInfo { 
        uint64 onSaleUntil; 
        address currency;
        uint256 price;
    }

    struct SeriesInfo { 
        address payable author;
        uint32 limit;
        SaleInfo saleInfo;
        CommissionData commission;
        string baseURI;
        string suffix;
    }
    
    struct CommissionInfo {
        uint64 maxValue;
        uint64 minValue;
        CommissionData ownerCommission;
    }

    struct CommissionData {
        uint64 value;
        address recipient;
    }

    event SeriesPutOnSale(
        uint64 indexed seriesId, 
        uint256 price, 
        address currency, 
        uint64 onSaleUntil
    );

    event SeriesRemovedFromSale(
        uint64 indexed seriesId
    );

    event TokenRemovedFromSale(
        uint256 indexed tokenId,
        address account
    );

    event TokenPutOnSale(
        uint256 indexed tokenId, 
        address indexed seller, 
        uint256 price, 
        address currency, 
        uint64 onSaleUntil
    );
    
    event TokenBought(
        uint256 indexed tokenId, 
        address indexed seller, 
        address indexed buyer, 
        address currency, 
        uint256 price
    );
    
    /********************************************************************
    ****** external section *********************************************
    *********************************************************************/
    
    /**
    * @dev sets the default baseURI for the whole contract
    * @param baseURI_ the prefix to prepend to URIs
    */
    function setBaseURI(
        string calldata baseURI_
    ) 
        onlyOwner
        external
    {
        baseURI = baseURI_;
        _accountForOperation(
            OPERATION_SETMETADATA << OPERATION_SHIFT_BITS,
            0x100,
            0
        );
    }
    
    /**
    * @dev sets the default URI suffix for the whole contract
    * @param suffix_ the suffix to append to URIs
    */
    function setSuffix(
        string calldata suffix_
    ) 
        onlyOwner
        external
    {
        suffix = suffix_;
        _accountForOperation(
            OPERATION_SETMETADATA << OPERATION_SHIFT_BITS,
            0x010,
            0
        );
    }

     /**
    * @dev sets URI for contract metadata. 
    * @param newContractURI new URI
    */
    function setContractURI(string memory newContractURI) external onlyOwner {
        _contractURI = newContractURI;
        _accountForOperation(
            OPERATION_SETMETADATA << OPERATION_SHIFT_BITS,
            0x001,
            0
        );
    }

    /**
    * @dev sets information for token series with given ID. 
    * @param seriesId the token series ID
    * @param info new SeriesInfo to set
    */
    function setSeriesInfo(
        uint64 seriesId, 
        SeriesInfo memory info 
    ) 
        external
    {
        _requireCanManageSeries(seriesId);
        if (info.saleInfo.onSaleUntil > seriesInfo[seriesId].saleInfo.onSaleUntil && 
            info.saleInfo.onSaleUntil > block.timestamp
        ) {
            emit SeriesPutOnSale(
                seriesId, 
                info.saleInfo.price, 
                info.saleInfo.currency, 
                info.saleInfo.onSaleUntil
            );
        } else if (info.saleInfo.onSaleUntil <= block.timestamp ) {
            emit SeriesRemovedFromSale(seriesId);
        }
        
        seriesInfo[seriesId] = info;

        _accountForOperation(
            (OPERATION_SETSERIESINFO << OPERATION_SHIFT_BITS) | seriesId,
            uint256(uint160(info.saleInfo.currency)),
            info.saleInfo.price
        );
        
    }
    /**
    * @dev Set commission paid to contract owner from every buy()
    * @param commission new commission info
    */
    function setOwnerCommission(
        CommissionInfo memory commission
    ) 
        external 
        onlyOwner 
    {
        commissionInfo = commission;

        _accountForOperation(
            OPERATION_SETOWNERCOMMISSION << OPERATION_SHIFT_BITS,
            uint256(uint160(commission.ownerCommission.recipient)),
            commission.ownerCommission.value
        );

    }

    /**
    * @dev Set commissions paid for an NFT series
    * @param commissionData new commission data
    */
    function setCommission(
        uint64 seriesId, 
        CommissionData memory commissionData
    ) 
        external 
    {
        _requireCanManageSeries(seriesId);
        require(
            (
                commissionData.value <= commissionInfo.maxValue &&
                commissionData.value >= commissionInfo.minValue &&
                commissionData.value + commissionInfo.ownerCommission.value < FRACTION
            ),
            "COMMISSION_INVALID"
        );
        require(commissionData.recipient != address(0), "RECIPIENT_INVALID");
        seriesInfo[seriesId].commission = commissionData;
        
        _accountForOperation(
            (OPERATION_SETCOMMISSION << OPERATION_SHIFT_BITS) | seriesId,
            commissionData.value,
            uint256(uint160(commissionData.recipient))
        );
        
    }

    /**
    * @dev Remove commissions for series
    * @param seriesId seriesId
    */
    function removeCommission(
        uint64 seriesId
    ) 
        external 
    {
        _requireCanManageSeries(seriesId);
        delete seriesInfo[seriesId].commission;
        
        _accountForOperation(
            (OPERATION_REMOVECOMMISSION << OPERATION_SHIFT_BITS) | seriesId,
            0,
            0
        );
        
    }

    /**
    * @dev list NFT for sale with specified terms
    * @param tokenId the token ID
    * @param price sale price
    * @param currency sale currency
    * @param duration sale duration in seconds
    */
    function listForSale(
        uint256 tokenId,
        uint256 price,
        address currency,
        uint64 duration
    )
        external 
    {
        (bool success, /*bool isExists*/, /*SaleInfo memory data*/, /*address owner*/) = getTokenSaleInfo(tokenId);
        
        _requireCanManageToken(tokenId);
        require(!success, "ALREADY_ON_SALE");
        require(duration > 0, "INVALID_DURATION");

        uint64 seriesId = getSeriesId(tokenId);
        SaleInfo memory newSaleInfo = SaleInfo({
            onSaleUntil: uint64(block.timestamp) + duration,
            currency: currency,
            price: price
        });
        SaleInfoToken memory saleInfoToken = SaleInfoToken({
            saleInfo: newSaleInfo,
            ownerCommissionValue: commissionInfo.ownerCommission.value,
            authorCommissionValue: seriesInfo[seriesId].commission.value
        });
        _setSaleInfo(tokenId, saleInfoToken);

        emit TokenPutOnSale(
            tokenId, 
            _msgSender(), 
            newSaleInfo.price, 
            newSaleInfo.currency, 
            newSaleInfo.onSaleUntil
        );
        
        _accountForOperation(
            (OPERATION_LISTFORSALE << OPERATION_SHIFT_BITS) | seriesId,
            uint256(uint160(currency)),
            price
        );
    }
    
    /**
    * @dev remove NFT from sale
    * @param tokenId the token ID
    */
    function removeFromSale(
        uint256 tokenId
    )
        external 
    {
        (bool success, /*bool isExists*/, SaleInfo memory data, /*address owner*/) = getTokenSaleInfo(tokenId);
        require(success, "NOT_ON_SALE");
        _requireCanManageToken(tokenId);
        clearOnSaleUntil(tokenId);

        emit TokenRemovedFromSale(tokenId, _msgSender());
        
        uint64 seriesId = getSeriesId(tokenId);
        _accountForOperation(
            (OPERATION_REMOVEFROMSALE << OPERATION_SHIFT_BITS) | seriesId,
            uint256(uint160(data.currency)),
            data.price
        );
    }

    /**
    * @dev returns a limited list of all NFTs owned by account
    * @param account address of account
    */
    function tokensByOwner(
        address account,
        uint32 limit
    ) 
        external
        view
        returns (uint256[] memory ret)
    {
        return _tokensByOwner(account, limit);
    }

    /**
    * @dev mints and distributes NFTs with specified IDs
    * to specified addresses
    * @param tokenIds list of NFT IDs to be minted
    * @param addresses list of receiver addresses
    */
    function mintAndDistribute(
        uint256[] memory tokenIds, 
        address[] memory addresses
    )
        external 
    {
        uint256 len = addresses.length;
        require(tokenIds.length == len, "MATCH_LENGTHS");
        for(uint256 i = 0; i < len; i++) {
            _requireCanManageSeries(getSeriesId(tokenIds[i]));
            _mint(addresses[i], tokenIds[i]);
        }
        
        _accountForOperation(
            OPERATION_MINTANDDISTRIBUTE << OPERATION_SHIFT_BITS,
            len,
            0
        );
    }
    
    /** 
    * @dev allows factory owner or operator to override cost manager contract
    * @param costManager_ new address of utility token, or 0
    */
    function overrideCostManager(address costManager_) external {
        // require factory owner or operator, or contract deployer
        require (
            (factory.isContract()) 
                ? IFactory(factory).canOverrideCostManager(_msgSender(), address(this))
                : factory == _msgSender(),
            "cannot override"
        );
        costManager = costManager_;
    }


    /********************************************************************
    ****** public section ***********************************************
    *********************************************************************/
    /**
    * @dev whether caller can set info for a series,
    * manage amount of commissions for the series,
    * mint and distribute tokens from it, etc.
    * @param seriesId the token series ID
    */
    function canManageSeries(uint64 seriesId) public view returns (bool) {
        address ms = _msgSender();
        if (owner() == ms || seriesInfo[seriesId].author == ms) {
            return true;
        }
        uint256 len = hooks[seriesId].length();
        for (uint256 i = 0; i < len; ++i) {
            if (hooks[seriesId].at(i) == ms) {
                return true;
            }
        }
        return false;
    }

    /**
    * @dev whether the caller can transfer an existing token,
    * list it for sale and remove it from sale.
    * Tokens can be managed by their owner
    * or approved accounts via {approve} or {setApprovalForAll}.
    * @param tokenId the tokenID
    */
    function canManageToken(uint256 tokenId) public view returns (bool) {
        return _canManageToken(tokenId);
    }

    /**
     * @dev Returns whether `tokenId` exists.
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function tokenExists(uint256 tokenId) public view virtual returns (bool) {
        return _exists(tokenId);
    }
    
    /**
    * @dev buys NFT in exchange for for native coin. 
    * Mints NFT if it doesn't exist, 
    * otherwise transfers it, if it exists and is on sale
    * @param tokenId token ID to buy
    * @param price amount of native coin to pay
    * @param safe set to true to use safeMint and safeTransfer
    */
    function buy(uint256 tokenId, uint256 price, bool safe) public payable nonReentrant {
        (bool success, bool exists, SaleInfo memory data, address beneficiary) = getTokenSaleInfo(tokenId);
        require(success, "NOT_ON_SALE");
        require(msg.value >= data.price && price >= data.price, "INSUFFICIENT_AMOUNT");
        require(address(0) == data.currency, "WRONG_CURRENCY");

        bool transferSuccess;
        uint256 left = data.price;
        (address[2] memory addresses, uint256[2] memory values, uint256 length) = calculateCommission(tokenId, data.price);
       
        // commissions payment
        for(uint256 i = 0; i < length; i++) {
            (transferSuccess, ) = addresses[i].call{gas: 3000, value: values[i]}(new bytes(0));
            require(transferSuccess, "COMMISSION_PAYMENT_FAILED");
            left -= values[i];
        }
        
        (transferSuccess, ) = beneficiary.call{gas: 3000, value: left}(new bytes(0));
        require(transferSuccess, "BUY_PAYMENT_FAILED");

        uint256 refund = msg.value - data.price;

        if (refund > 0) {
            (transferSuccess, ) = msg.sender.call{gas: 3000, value: refund}(new bytes(0));
            require(transferSuccess, "REFUND_FAILED");
        }

        _buy(tokenId, exists, data, beneficiary, safe);
        
        uint64 seriesId = getSeriesId(tokenId);
        _accountForOperation(
            (OPERATION_BUY << OPERATION_SHIFT_BITS) | seriesId, 
            0,
            price
        );
    }

    /**
    * @dev buys NFT for specified currency.
    * Mints NFT if it doesn't exist,
    * otherwise transfers token if it exists and is on sale.
    * @param tokenId token ID to buy
    * @param currency address of token to pay with
    * @param price amount of currency to pay
    * @param safe pass true to use safeMint and safeTransfer
    */
    function buy(uint256 tokenId, address currency, uint256 price, bool safe) public nonReentrant {
        (bool success, bool exists, SaleInfo memory data, address owner) = getTokenSaleInfo(tokenId);
        require(success, "NOT_ON_SALE");
        require(currency == data.currency, "wrong currency for sale");
        uint256 allowance = IERC20Upgradeable(data.currency).allowance(_msgSender(), address(this));
        require(allowance >= data.price && price >= data.price, "insufficient amount");

        uint256 left = data.price;
        (address[2] memory addresses, uint256[2] memory values, uint256 length) = calculateCommission(tokenId, data.price);
        // commissions payment
        for(uint256 i = 0; i < length; i++) {
            IERC20Upgradeable(data.currency).transferFrom(_msgSender(), addresses[i], values[i]);
            left -= values[i];
        }

        IERC20Upgradeable(data.currency).transferFrom(_msgSender(), owner, left);
        _buy(tokenId, exists, data, owner, safe);
        uint64 seriesId = getSeriesId(tokenId);
        _accountForOperation(
            (OPERATION_BUY << OPERATION_SHIFT_BITS) | seriesId,
            uint256(uint160(currency)),
            price
        );
    }

    /**
    * @dev calculate commission for NFT token sales, for owner and author.
    *  If token was already minted and on sale, use SalesInfo during listForSale.
    *  If the token wasn't minted yet, use SeriesInfo.
    *  Either way, cap the commissions at seriesInfo[seriesId].commission.value
    * @param tokenId token ID to calculate commission
    * @param price amount of specified token to pay 
    */
    function calculateCommission(
        uint256 tokenId,
        uint256 price
    ) 
        internal 
        view 
        returns(
            address[2] memory addresses, 
            uint256[2] memory values,
            uint256 length
        ) 
    {
        uint64 seriesId = getSeriesId(tokenId);
        length = 0;
        uint256 sum;

        // contract owner commission
        if (commissionInfo.ownerCommission.recipient != address(0)) {
            uint256 oc = salesInfoToken[tokenId].ownerCommissionValue;
            if (oc > commissionInfo.ownerCommission.value) {
                oc = commissionInfo.ownerCommission.value;
            }
            if (oc != 0) {
                addresses[length] = commissionInfo.ownerCommission.recipient;
                sum += oc;
                values[length] = oc * price / FRACTION;
                length++;
            }
        }

        // author commission
        if (seriesInfo[seriesId].commission.recipient != address(0)) {
            uint256 ac = salesInfoToken[tokenId].authorCommissionValue;
            if (ac > seriesInfo[seriesId].commission.value) {
                ac = seriesInfo[seriesId].commission.value;
            }
            if (ac != 0) {
                addresses[length] = seriesInfo[seriesId].commission.recipient;
                sum += ac;
                values[length] = ac * price / FRACTION;
                length++;
            }
        }

        require(sum < FRACTION, "INVALID_COMMISSION");

    }

    /**
    * @dev returns contract URI. 
    */
    function contractURI() public view returns(string memory){
        return _contractURI;
    }

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < balanceOf(owner), "INDEX_OUT_OF_BOUNDS");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < totalSupply(), "INDEX_TOO_BIG");
        return _allTokens[index];
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            interfaceId == type(IERC721EnumerableUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "INDEX_TOO_BIG");
        return _balances[owner];
    }

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "NONEXISTENT_TOKEN");
        return owner;
    }

    /**
     * @dev Returns the token collection name.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /** 
    * @dev sets name and symbol for contract
    * @param newName new name 
    * @param newSymbol new symbol 
    */
    function setNameAndSymbol(
        string memory newName, 
        string memory newSymbol
    ) 
        public 
        onlyOwner 
    {
        _setNameAndSymbol(newName, newSymbol);
    }
    
  
    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(
        uint256 tokenId
    ) 
        public 
        view 
        virtual 
        override
        returns (string memory) 
    {
        require(_exists(tokenId), "NONEXISTENT_TOKEN");
        string memory _tokenIdHexString = tokenId.toHexString();
        uint64 seriesId = getSeriesId(tokenId);
        string memory baseURI_ = seriesInfo[seriesId].baseURI;
        string memory suffix_ = seriesInfo[seriesId].suffix;
        if (bytes(baseURI_).length == 0) {
            baseURI_ = baseURI;
        }
        if (bytes(suffix_).length == 0) {
            suffix_ = suffix;
        }
        // If all are set, concatenate
        if (bytes(_tokenIdHexString).length > 0) {
            return string(abi.encodePacked(baseURI_, _tokenIdHexString, suffix_));
        }
        return "";
    }

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "CALLER_THEMSELVES");
        address ms = _msgSender();
        require(
            ms == owner || isApprovedForAll(owner, ms),
            "UNAUTHORIZED"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(ownerOf(tokenId) != address(0), "NONEXISTENT_TOKEN");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "CALLER_THEMSELVES");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        _requireCanManageToken(tokenId);

        _transfer(from, to, tokenId);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        _requireCanManageToken(tokenId);
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Transfers `tokenId` token from sender to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by sender.
     *
     * Emits a {Transfer} event.
     */
    function transfer(
        address to,
        uint256 tokenId
    ) public virtual {
        _requireCanManageToken(tokenId);
        _transfer(_msgSender(), to, tokenId);
    }

    /**
     * @dev Safely transfers `tokenId` token from sender to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by sender.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransfer(
        address to,
        uint256 tokenId
    ) public virtual {
        _requireCanManageToken(tokenId);
        _safeTransfer(_msgSender(), to, tokenId, "");
    }

    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        _requireCanManageToken(tokenId);
        _burn(tokenId);
        
        _accountForOperation(
            OPERATION_BURN << OPERATION_SHIFT_BITS,
            tokenId,
            0
        );
    }

    /**
    * @dev returns if token is on sale or not, 
    * whether it exists or not,
    * as well as data about the sale and its owner
    * @param tokenId token ID 
    */
    function getTokenSaleInfo(uint256 tokenId) 
        public 
        view 
        returns
        (
            bool isOnSale,
            bool exists, 
            SaleInfo memory data,
            address owner
        ) 
    {
        data = salesInfoToken[tokenId].saleInfo;

        exists = _exists(tokenId);
        owner = _owners[tokenId];

        if (owner != address(0)) { 
            if (data.onSaleUntil > block.timestamp) {
                isOnSale = true;
            } 
        } else {   
            uint64 seriesId = getSeriesId(tokenId);
            SeriesInfo memory seriesData = seriesInfo[seriesId];
            if (seriesData.saleInfo.onSaleUntil > block.timestamp) {
                isOnSale = true;
                data = seriesData.saleInfo;
                owner = seriesData.author;
            }
        }   
    }

   /**
    * @dev the owner should be absolutely sure they trust the trustedForwarder
    * @param trustedForwarder_ must be a smart contract that was audited
    */
    function setTrustedForwarder(
        address trustedForwarder_
    )
        onlyOwner 
        public 
    {
        _setTrustedForwarder(trustedForwarder_);
    }

    
      
    /********************************************************************
    ****** internal section *********************************************
    *********************************************************************/

    function _msgSender(
    ) 
        internal 
        view 
        override
        returns (address signer) 
    {
        signer = msg.sender;
        if (msg.data.length >= 20 && trustedForwarder == signer) {
            assembly {
                signer := shr(96,calldataload(sub(calldatasize(),20)))
            }
        }    
    }

    function _setTrustedForwarder(
        address trustedForwarder_
    )
        internal 
    {
        trustedForwarder = trustedForwarder_;
    }

    function _transferOwnership(
        address newOwner
    ) 
        internal 
        virtual 
        override
    {
        super._transferOwnership(newOwner);
        _setTrustedForwarder(address(0));
    }

    function _buy(
        uint256 tokenId, 
        bool exists, 
        SaleInfo memory data, 
        address owner, 
        bool safe
    ) 
        internal 
        virtual 
    {
        address ms = _msgSender();
        if (exists) {
            if (safe) {
                _safeTransfer(owner, ms, tokenId, new bytes(0));
            } else {
                _transfer(owner, ms, tokenId);
            }
            emit TokenBought(
                tokenId, 
                owner, 
                ms, 
                data.currency, 
                data.price
            );
        } else {

            if (safe) {
                _safeMint(ms, tokenId);
            } else {
                _mint(ms, tokenId);
            }
            emit Transfer(owner, ms, tokenId);
            emit TokenBought(
                tokenId, 
                owner, 
                ms, 
                data.currency, 
                data.price
            );
        }
         
    }

    
    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function __ERC721_init(
        string memory name_, 
        string memory symbol_, 
        address costManager_, 
        address producedBy_
    ) 
        internal 
        initializer 
    {
        __Context_init();
        __ERC165_init();
        __Ownable_init();
        __ReentrancyGuard_init();

        _setNameAndSymbol(name_, symbol_);
        costManager = costManager_;
        factory = _msgSender();
        
        _accountForOperation(
            OPERATION_INITIALIZE << OPERATION_SHIFT_BITS,
            uint256(uint160(producedBy_)),
            0
        );
    }
    
    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "IMPLEMENT_ERC721Receiver");
    }

    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "IMPLEMENT_ERC721Receiver"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event. if flag `skipEvent` is false
     */
    function _mint(
        address to, 
        uint256 tokenId
    ) 
        internal 
        virtual 
    {
        require(to != address(0), "ZERO_ADDRESS");
        require(_owners[tokenId] == address(0), "ALREADY_EXISTS");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        uint64 seriesId = getSeriesId(tokenId);
        mintedCountBySeries[seriesId] += 1;

        if (seriesInfo[seriesId].limit != 0) {
            require(
                mintedCountBySeries[seriesId] <= seriesInfo[seriesId].limit, 
                "SERIES_LIMIT_EXCEEDED"
            );
        }
        

        emit Transfer(address(0), to, tokenId);
        
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        
        _balances[DEAD_ADDRESS] += 1;
        _owners[tokenId] = DEAD_ADDRESS;
        clearOnSaleUntil(tokenId);
        emit Transfer(owner, DEAD_ADDRESS, tokenId);

    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ownerOf(tokenId) == from, "token isn't owned by from address");
        require(to != address(0), "ZERO_ADDRESS");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        clearOnSaleUntil(tokenId);

        emit Transfer(from, to, tokenId);
        
        _accountForOperation(
            (OPERATION_TRANSFER << OPERATION_SHIFT_BITS) | getSeriesId(tokenId),
            uint256(uint160(from)),
            uint256(uint160(to))
        );
        
    }
    
    /**
    * @dev sets sale info for the NFT with 'tokenId'
    * @param tokenId token ID
    * @param info information about sale 
    */
    function _setSaleInfo(
        uint256 tokenId, 
        SaleInfoToken memory info 
    ) 
        internal 
    {
        salesInfoToken[tokenId] = info;
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }
    
    /**
    * @param account account
    * @param limit limit
    */
    function _tokensByOwner(
        address account,
        uint32 limit
    ) 
        internal
        view
        returns (uint256[] memory array)
    {
        uint256 len = balanceOf(account);
        if (len > 0) {
            len = (limit != 0 && limit < len) ? limit : len;
            array = new uint256[](len);
            for (uint256 i = 0; i < len; i++) {
                array[i] = _ownedTokens[account][i];
            }
        }
    }

    function getSeriesId(
        uint256 tokenId
    )
        internal
        pure
        returns(uint64)
    {
        return uint64(tokenId >> SERIES_SHIFT_BITS);
    }
    
    /** 
    * @dev sets name and symbol for contract
    * @param newName new name 
    * @param newSymbol new symbol 
    */
    function _setNameAndSymbol(
        string memory newName, 
        string memory newSymbol
    ) 
        internal 
    {
        _name = newName;
        _symbol = newSymbol;
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function clearOnSaleUntil(uint256 tokenId) internal {
        if (salesInfoToken[tokenId].saleInfo.onSaleUntil > 0 ) salesInfoToken[tokenId].saleInfo.onSaleUntil = 0;
    }

    function _requireCanManageSeries(uint64 seriesId) internal view virtual {
        require(canManageSeries(seriesId), "SERIES_NOT_AUTHORIZED");
    }
             
    function _requireCanManageToken(uint256 tokenId) internal view virtual {
        
        require(_exists(tokenId), "NONEXISTENT_TOKEN");
        require(_canManageToken(tokenId), "TOKEN_NOT_AUTHORIZED");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0)
            && _owners[tokenId] != DEAD_ADDRESS;
    }

    function _canManageToken(uint256 tokenId) internal view returns (bool) {
        address ms = _msgSender();
        if (_ownerOf(tokenId) == ms
        || getApproved(tokenId) == ms
        || isApprovedForAll(_ownerOf(tokenId), ms)) {
            return true;
        }
        uint64 seriesId = getSeriesId(tokenId);
        uint256 len = hooksCountByToken[tokenId];
        for (uint256 i = 0; i < len; ++i) {
            if (hooks[seriesId].at(i) == ms) {
                return true;
            }
        }
        return false;
    }
    

    /********************************************************************
    ****** private section **********************************************
    *********************************************************************/

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("IMPLEMENT_ERC721Receiver");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }


   
    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
    
    /**
     * @dev Private function that tells utility token contract to account for an operation
     * @param info uint256 The operation ID (first 8 bits), seriesId is last 8 bits
     * @param param1 uint256 Some more information, if any
     * @param param2 uint256 Some more information, if any
     */
    function _accountForOperation(uint256 info, uint256 param1, uint256 param2) private {
        if (costManager != address(0)) {
            try ICostManager(costManager).accountForOperation(
                _msgSender(), info, param1, param2
            )
            returns (uint256 /*spent*/, uint256 /*remaining*/) {
                // if error is not thrown, we are fine
            } catch Error(string memory reason) {
                // This is executed in case revert() was called with a reason
                revert(reason);
            } catch {
                revert("Insufficient Utility Token: Contact Collection Owner");
            }
        }
    }

    

}

// File: contracts/extensions/ERC721SafeHooksUpgradeable.sol



pragma solidity ^0.8.0;




/**
* holds count of series hooks while token mint and buy
*/
abstract contract ERC721SafeHooksUpgradeable is Initializable, ERC721UpgradeableExt {
    
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    mapping (uint256 => uint256) public hooksCountByToken; // token ID => hooks count

    mapping(uint256 => EnumerableSetUpgradeable.AddressSet) internal hooks;    // series ID => hooks' addresses

    event NewHook(uint256 seriesId, address contractAddress);

    /**
    * @dev buys NFT for ETH with defined id. 
    * mint token if it doesn't exist and transfer token
    * if it exists and is on sale
    * @param tokenId token ID to buy
    * @param price amount of specified ETH to pay
    * @param safe use safeMint and safeTransfer or not
    * @param hookCount number of hooks 
    */
    function buy(
        uint256 tokenId, 
        uint256 price, 
        bool safe, 
        uint256 hookCount
    ) 
        external
        payable
    {
        validateHookCount(tokenId, hookCount);    
        super.buy(tokenId, price, safe);
    }
    /**
    * @dev buys NFT for specified currency with defined id. 
    * mint token if it doesn't exist and transfer token
    * if it exists and is on sale
    * @param tokenId token ID to buy
    * @param currency address of token to pay with
    * @param price amount of specified token to pay
    * @param safe use safeMint and safeTransfer or not
    * @param hookCount number of hooks 
    */
    function buy(
        uint256 tokenId, 
        address currency, 
        uint256 price, 
        bool safe, 
        uint256 hookCount
    ) 
        external
    {
        validateHookCount(tokenId, hookCount);    
        super.buy(tokenId, currency, price, safe);
    }

    /**
    * @dev link safeHook contract to certain series
    * @param seriesId series ID
    * @param contractAddress address of SafeHook contract
    */
    function pushTokenTransferHook(
        uint256 seriesId, 
        address contractAddress
    )
        public 
        onlyOwner
    {

        try ISafeHook(contractAddress).supportsInterface(type(ISafeHook).interfaceId) returns (bool success) {
            if (success) {
                hooks[seriesId].add(contractAddress);
            } else {
                revert("WRONG_INTERFACE");
            }
        } catch {
            revert("WRONG_INTERFACE");
        }

        emit NewHook(seriesId, contractAddress);

    }

    /**
    * @dev returns the list of hooks for NFT series
    * @param seriesId series ID
    */
    function getHookList(
        uint256 seriesId
    ) 
        external 
        view 
        returns(address[] memory) 
    {
        uint256 len = hooks[seriesId].length();
        address[] memory allHooks = new address[](len);
        for (uint256 i = 0; i < len; i++) {
            allHooks[i] = hooks[seriesId].at(i);
        }
        return allHooks;
    }

    /**
    * @dev returns number of hooks for NFT series
    * @param seriesId series ID
    */
    function hooksCount(
        uint256 seriesId
    ) 
        internal 
        view 
        returns(uint256) 
    {
        return hooks[seriesId].length();
    }

    /**
    * @dev validates hook count
    * @param tokenId token ID
    * @param hookCount hook count
    */
    function validateHookCount(
        uint256 tokenId,
        uint256 hookCount
    ) 
        internal 
        view 
    {
        uint256 seriesId = tokenId >> SERIES_SHIFT_BITS;
        require(hookCount == hooksCount(seriesId), "HOOK_COUNT");
    }

    /**
    * @param name_ name 
    * @param symbol_ symbol 
    */
    function __ERC721SafeHook_init(
        string memory name_, 
        string memory symbol_, 
        address costManager_,
        address msgSender_
    ) 
        internal 
        initializer 
    {
        __ERC721_init(name_, symbol_, costManager_, msgSender_);
    }

    /**
     * @dev Overriden function _beforeTokenTransfer with
     * hooks executing 
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) 
        internal 
        virtual 
        override 
    {
        uint256 seriesId = tokenId >> SERIES_SHIFT_BITS;
        uint256 len = hooksCountByToken[tokenId];
        for (uint256 i = 0; i < len; i++) {
            try ISafeHook(hooks[seriesId].at(i)).executeHook(from, to, tokenId)
			returns (bool success) {
                if (!success) {
                    revert("TRANSFER_NOT_AUTHORIZED");
                }
            } catch Error(string memory reason) {
                // This is executed in case revert() was called with a reason
	            revert(reason);
	        } catch {
                revert("TRANSFER_NOT_AUTHORIZED");
            }
        }

        super._beforeTokenTransfer(from, to, tokenId);

    }
    /**
    * @dev overriden _mint function.
    * Here we remember count of series hooks at this moment. 
    * So further hooks will not apply for this token
    */
    function _mint(
        address to, 
        uint256 tokenId
    ) 
        internal 
        virtual 
        override
    {
        _storeHookCount(tokenId);
        super._mint(to, tokenId);
    }

    /**
    * @dev overriden _buy function.
    * Here we remember count of series hooks at this moment. 
    * So further hooks will not apply for this token
    */
    function _buy(
        uint256 tokenId, 
        bool exists, 
        SaleInfo memory data, 
        address owner, 
        bool safe
    ) 
        internal 
        override 
    {
        _storeHookCount(tokenId);
        super._buy(tokenId, exists, data, owner, safe);
        
    }

    /** 
    * @dev used to storage hooksCountByToken at this moment
    */
    function _storeHookCount(
        uint256 tokenId
    )
        internal
    {
        hooksCountByToken[tokenId] = hooks[tokenId >> SERIES_SHIFT_BITS].length();
    }
}

// File: contracts/presets/NFTSafeHook.sol



/**
Although this code is available for viewing on GitHub and Etherscan, it is NOT licensed to the general public.

To prevent confusion and increase trust in the audited code bases of smart contracts we produce, we intend for there to be only ONE official Factory address on the blockchain producing these NFT smart contracts, and we are going to point a blockchain domain name at it.

Copyright (c) Intercoin Inc. All rights reserved.

However, the general public is welcome to use this official Factory to produce instances for their use. We may begin requiring staking of ITR tokens in order to take actions (such as producing series and minting tokens). If you are looking to obtain ITR tokens or custom work done with your NFT projects, visit intercoin.org

Any user of software powered by this code must agree to the following, in order to use it. If you do not agree, refrain from using the software:

DISCLAIMERS AND DISCLOSURES.

Customer expressly recognizes that nearly any software may contain unforeseen bugs or other defects, due to the nature of software development. Moreover, because of the immutable nature of smart contracts, any such defects will persist in the software once it is deployed onto the blockchain. Customer therefore expressly acknowledges that no outside audits of the software have been conducted, and any responsibility to obtain such audits and analysis of any software produced by Developer rests solely with Customer.

Customer understands and acknowledges that the Software is being delivered as-is, and may contain potential defects. While Developer and its staff and partners have exercised care and best efforts in an attempt to produce solid, working software products, Developer EXPRESSLY DISCLAIMS MAKING ANY GUARANTEES, REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED, ABOUT THE FITNESS OF THE SOFTWARE, INCLUDING LACK OF DEFECTS, MERCHANTABILITY OR SUITABILITY FOR A PARTICULAR PURPOSE.

Customer agrees that neither Developer nor any other party has made any representations or warranties, nor has the Customer relied on any representations or warranties, express or implied, including any implied warranty of merchantability or fitness for any particular purpose with respect to the Software. Customer acknowledges that no affirmation of fact or statement (whether written or oral) made by Developer, its representatives, or any other party outside of this Agreement with respect to the Software shall be deemed to create any express or implied warranty on the part of Developer or its representatives.

INDEMNIFICATION.

Customer agrees to indemnify, defend and hold Developer and its officers, directors, employees, agents and contractors harmless from any loss, cost, expense (including attorney’s fees and expenses), associated with or related to any demand, claim, liability, damages or cause of action of any kind or character (collectively referred to as “claim”), in any manner arising out of or relating to any third party demand, dispute, mediation, arbitration, litigation, or any violation or breach of any provision of this Agreement by Customer.

NO WARRANTY.

THE SOFTWARE IS PROVIDED “AS IS” WITHOUT WARRANTY. DEVELOPER SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL, INCIDENTAL, CONSEQUENTIAL, OR EXEMPLARY DAMAGES FOR BREACH OF THE LIMITED WARRANTY. TO THE MAXIMUM EXTENT PERMITTED BY LAW, DEVELOPER EXPRESSLY DISCLAIMS, AND CUSTOMER EXPRESSLY WAIVES, ALL OTHER WARRANTIES, WHETHER EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR USE, OR ANY WARRANTY ARISING OUT OF ANY PROPOSAL, SPECIFICATION, OR SAMPLE, AS WELL AS ANY WARRANTIES THAT THE SOFTWARE (OR ANY ELEMENTS THEREOF) WILL ACHIEVE A PARTICULAR RESULT, OR WILL BE UNINTERRUPTED OR ERROR-FREE. THE TERM OF ANY IMPLIED WARRANTIES THAT CANNOT BE DISCLAIMED UNDER APPLICABLE LAW SHALL BE LIMITED TO THE DURATION OF THE FOREGOING EXPRESS WARRANTY PERIOD. SOME STATES DO NOT ALLOW THE EXCLUSION OF IMPLIED WARRANTIES AND/OR DO NOT ALLOW LIMITATIONS ON THE AMOUNT OF TIME AN IMPLIED WARRANTY LASTS, SO THE ABOVE LIMITATIONS MAY NOT APPLY TO CUSTOMER. THIS LIMITED WARRANTY GIVES CUSTOMER SPECIFIC LEGAL RIGHTS. CUSTOMER MAY HAVE OTHER RIGHTS WHICH VARY FROM STATE TO STATE. 

LIMITATION OF LIABILITY. 

TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL DEVELOPER BE LIABLE UNDER ANY THEORY OF LIABILITY FOR ANY CONSEQUENTIAL, INDIRECT, INCIDENTAL, SPECIAL, PUNITIVE OR EXEMPLARY DAMAGES OF ANY KIND, INCLUDING, WITHOUT LIMITATION, DAMAGES ARISING FROM LOSS OF PROFITS, REVENUE, DATA OR USE, OR FROM INTERRUPTED COMMUNICATIONS OR DAMAGED DATA, OR FROM ANY DEFECT OR ERROR OR IN CONNECTION WITH CUSTOMER'S ACQUISITION OF SUBSTITUTE GOODS OR SERVICES OR MALFUNCTION OF THE SOFTWARE, OR ANY SUCH DAMAGES ARISING FROM BREACH OF CONTRACT OR WARRANTY OR FROM NEGLIGENCE OR STRICT LIABILITY, EVEN IF DEVELOPER OR ANY OTHER PERSON HAS BEEN ADVISED OR SHOULD KNOW OF THE POSSIBILITY OF SUCH DAMAGES, AND NOTWITHSTANDING THE FAILURE OF ANY REMEDY TO ACHIEVE ITS INTENDED PURPOSE. WITHOUT LIMITING THE FOREGOING OR ANY OTHER LIMITATION OF LIABILITY HEREIN, REGARDLESS OF THE FORM OF ACTION, WHETHER FOR BREACH OF CONTRACT, WARRANTY, NEGLIGENCE, STRICT LIABILITY IN TORT OR OTHERWISE, CUSTOMER'S EXCLUSIVE REMEDY AND THE TOTAL LIABILITY OF DEVELOPER OR ANY SUPPLIER OF SERVICES TO DEVELOPER FOR ANY CLAIMS ARISING IN ANY WAY IN CONNECTION WITH OR RELATED TO THIS AGREEMENT, THE SOFTWARE, FOR ANY CAUSE WHATSOEVER, SHALL NOT EXCEED 1,000 USD.

ENTIRE AGREEMENT

This Agreement contains the entire agreement and understanding among the parties hereto with respect to the subject matter hereof, and supersedes all prior and contemporaneous agreements, understandings, inducements and conditions, express or implied, oral or written, of any nature whatsoever with respect to the subject matter hereof. The express terms hereof control and supersede any course of performance and/or usage of the trade inconsistent with any of the terms hereof. Provisions from previous Agreements executed between Customer and Developer., which are not expressly dealt with in this Agreement, will remain in effect.

SUCCESSORS AND ASSIGNS

This Agreement shall continue to apply to any successors or assigns of either party, or any corporation or other entity acquiring all or substantially all the assets and business of either party whether by operation of law or otherwise.

ARBITRATION

All disputes related to this agreement shall be governed by and interpreted in accordance with the laws of New York, without regard to principles of conflict of laws. The parties to this agreement will submit all disputes arising under this agreement to arbitration in New York City, New York before a single arbitrator of the American Arbitration Association (“AAA”). The arbitrator shall be selected by application of the rules of the AAA, or by mutual agreement of the parties, except that such arbitrator shall be an attorney admitted to practice law New York. No party to this agreement will challenge the jurisdiction or venue provisions as provided in this section. No party to this agreement will challenge the jurisdiction or venue provisions as provided in this section.
**/

pragma solidity ^0.8.0;
pragma abicoder v2;

/**
* NFT with safe hooks support
*/
contract NFT is ERC721SafeHooksUpgradeable {

    /**
    * @notice initializes contract
    */
    function initialize(
        string memory name_, 
        string memory symbol_, 
        string memory contractURI_,
        address costManager_,
        address producedBy_
    ) 
        public 
        initializer 
    {
        __Ownable_init();
        __ReentrancyGuard_init();
        __ERC721SafeHook_init(name_, symbol_, costManager_, producedBy_);
        _contractURI = contractURI_;

    }
}