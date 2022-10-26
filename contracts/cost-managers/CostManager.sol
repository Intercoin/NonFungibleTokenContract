// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "./ICostManager.sol";
import "../sales/INFT.sol";

contract CostManager is ICostManager {
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

    uint8 internal constant SERIES_SHIFT_BITS = 192; // 256 - 64
    uint8 internal constant OPERATION_SHIFT_BITS = 240; // 256 - 16

    mapping(address => mapping(uint256 => address)) lockedMap;

    error AlreadyLocked(address nftContract, uint256 tokenId, address custodian);
    error NotLocked(address nftContract, uint256 tokenId);
    error Locked(address nftContract, uint256 tokenId);
    error NotAnOwner(address nftContract, uint256 tokenId);
    error NotACustodian(address nftContract, uint256 tokenId);
    error UnknownTokenId(address nftContract, uint256 tokenId);
    error WrongAddress(address account);

    function accountForOperation(
        address sender,
        uint256 info,
        uint256, /* param1*/
        uint256 /* param2*/
    )
        external
        view
        returns (
            uint256, /* spent*/
            uint256 /* remaining*/
        )
    {
        // _accountForOperation(
        //     (OPERATION_TRANSFER << OPERATION_SHIFT_BITS) | getSeriesId(tokenId),
        //     uint256(uint160(from)),
        //     uint256(uint160(to))
        // );
        // _msgSender(), info, param1, param2

        if ((info >> OPERATION_SHIFT_BITS) == OPERATION_TRANSFER) {
            // address from = address(uint160(param1));
            // address to = address(uint160(param2));
            uint256 tokenId = info - ((info >> OPERATION_SHIFT_BITS) << OPERATION_SHIFT_BITS);
            if (lockedMap[sender][tokenId] != address(0)) {
                revert Locked(sender, tokenId);
            }
        }

        return (0, 0); // to hide warning
    }

    function lock(
        address nftContract,
        uint256 tokenId,
        address custodian
    ) public {
        if (lockedMap[nftContract][tokenId] != address(0)) {
            revert AlreadyLocked(nftContract, tokenId, lockedMap[nftContract][tokenId]);
        }

        bool exists;
        address nftOwner;
        (, exists, , nftOwner) = INFT(nftContract).getTokenSaleInfo(tokenId);
        if (!exists) {
            revert UnknownTokenId(nftContract, tokenId);
        }
        if (nftOwner != msg.sender) {
            revert NotAnOwner(nftContract, tokenId);
        }
        if (custodian == address(0)) {
            revert WrongAddress(custodian);
        }

        lockedMap[nftContract][tokenId] = custodian;
    }

    function unlock(address nftContract, uint256 tokenId) public {
        if (lockedMap[nftContract][tokenId] == address(0)) {
            revert NotLocked(nftContract, tokenId);
        }
        if (lockedMap[nftContract][tokenId] != msg.sender) {
            revert NotACustodian(nftContract, tokenId);
        }

        lockedMap[nftContract][tokenId] = address(0);
    }
}
