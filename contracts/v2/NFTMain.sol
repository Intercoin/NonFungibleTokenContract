// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma abicoder v2;

import "./NFTStorage.sol";

import "./NFTState.sol";
import "./NFTView.sol";

contract NFTMain is NFTStorage {
    
    NFTState implNFTState;
    NFTView implNFTView;

    /**
    * @notice initializes contract
    */
    function initialize(
        address implNFTState_,
        address implNFTView_,
        string memory name_, 
        string memory symbol_, 
        string memory contractURI_, 
        string memory baseURI_, 
        string memory suffixURI_, 
        address costManager_,
        address producedBy_
    ) 
        public 
        //override
        initializer 
    {
        implNFTState = NFTState(implNFTState_);
        implNFTView = NFTView(implNFTView_);

        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                NFTState.initialize.selector,
                name_, symbol_, contractURI_, baseURI_, suffixURI_, costManager_, producedBy_
            )
        );

    }

    function setBaseURI(
        string calldata baseURI_
    ) 
        onlyOwner
        external
    {
    
        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                NFTState.setBaseURI.selector,
                baseURI_
            )
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
        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                NFTState.setSuffix.selector,
                suffix_
            )
        );
    }

    /**
    * @dev sets contract URI. 
    * @param newContractURI new contract URI
    */
    function setContractURI(
        string memory newContractURI
    ) 
        external 
        onlyOwner 
    {
        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                NFTState.setContractURI.selector,
                newContractURI
            )
        );

    }

    /**
    * @dev sets information for series with 'seriesId'. 
    * @param seriesId series ID
    * @param info new info to set
    */
    function setSeriesInfo(
        uint64 seriesId, 
        SeriesInfo memory info 
    ) 
        external
    {

        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                NFTState.setSeriesInfo.selector,
                seriesId, info
            )
        );

    }

    /**
    * set commission paid to contract owner
    * @param commission new commission info
    */
    function setOwnerCommission(
        CommissionInfo memory commission
    ) 
        external 
        onlyOwner 
    {

        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                NFTState.setOwnerCommission.selector,
                commission
            )
        );
    }

    /**
    * set commission for series
    * @param commissionData new commission data
    */
    function setCommission(
        uint64 seriesId, 
        CommissionData memory commissionData
    ) 
        external 
    {
        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                NFTState.setCommission.selector,
                seriesId, commissionData
            )
        );
    }

    /**
    * clear commission for series
    * @param seriesId seriesId
    */
    function removeCommission(
        uint64 seriesId
    ) 
        external 
    {
        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                NFTState.removeCommission.selector,
                seriesId
            )
        );
        
    }

    /**
    * @dev lists on sale NFT with defined token ID with specified terms of sale
    * @param tokenId token ID
    * @param price price for sale 
    * @param currency currency of sale 
    * @param duration duration of sale 
    */
    function listForSale(
        uint256 tokenId,
        uint256 price,
        address currency,
        uint64 duration
    )
        external 
    {
        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                NFTState.listForSale.selector,
                tokenId, price, currency, duration
            )
        );

    }
    
    /**
    * @dev removes from sale NFT with defined token ID
    * @param tokenId token ID
    */
    function removeFromSale(
        uint256 tokenId
    )
        external 
    {
        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                NFTState.removeFromSale.selector,
                tokenId
            )
        );

    }

    
    /**
    * @dev mints and distributes NFTs with specified IDs
    * to specified addresses
    * @param tokenIds list of NFT IDs t obe minted
    * @param addresses list of receiver addresses
    */
    function mintAndDistribute(
        uint256[] memory tokenIds, 
        address[] memory addresses
    )
        external 
    {
        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                NFTState.mintAndDistribute.selector,
                tokenIds, addresses
            )
        );

    }
    
    /** 
    * @dev sets the utility token
    * @param costManager_ new address of utility token, or 0
    */
    function overrideCostManager(address costManager_) external {

        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                NFTState.overrideCostManager.selector,
                costManager_
            )
        );

    }

    ///////////////////////////////////////
    //// external view section ////////////
    ///////////////////////////////////////


    /**
    * @dev returns the list of all NFTs owned by 'account' with limit
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

        return abi.decode(
            _functionDelegateCallView(
                address(implNFTView), 
                abi.encodeWithSelector(
                    NFTView.tokensByOwner.selector, 
                    account, limit
                ), 
                ""
            ), 
            (uint256[])
        );

    }

    /**
    * @dev returns the list of hooks for series with `seriesId`
    * @param seriesId series ID
    */
    function getHookList(
        uint256 seriesId
    ) 
        external 
        view 
        returns(address[] memory) 
    {
        return abi.decode(
            _functionDelegateCallView(
                address(implNFTView), 
                abi.encodeWithSelector(
                    NFTView.getHookList.selector, 
                    seriesId
                ), 
                ""
            ), 
            (address[])
        );

    }

    /********************************************************************
    ****** public section ***********************************************
    *********************************************************************/
    
    /**
    * @dev buys NFT for native coin with defined id. 
    * mint token if it doesn't exist and transfer token
    * if it exists and is on sale
    * @param tokenId token ID to buy
    * @param price amount of specified native coin to pay
    * @param safe use safeMint and safeTransfer or not, 
    * @param hookCount number of hooks 
    */
    function buy(
        uint256 tokenId, 
        uint256 price, 
        bool safe, 
        uint256 hookCount
    ) 
        public 
        payable 
        nonReentrant 
    {
        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                //NFTState.buy.selector,
                bytes4(keccak256(bytes("buy(uint256,uint256,bool,uint256)"))),

                tokenId, price, safe, hookCount
            )
        );

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
        public 
        nonReentrant 
    {

        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                //NFTState.buy.selector,
                bytes4(keccak256(bytes("buy(uint256,address,uint256,bool,uint256)"))),

                tokenId, currency, price, safe, hookCount
            )
        );

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
        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                NFTState.setNameAndSymbol.selector,
                newName, newSymbol
            )
        );

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
        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                NFTState.approve.selector,
                to, tokenId
            )
        );

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
        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                NFTState.setApprovalForAll.selector,
                operator, approved
            )
        );

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
        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                NFTState.transferFrom.selector,
                from, to, tokenId
            )
        );

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
        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                //NFTState.safeTransferFrom.selector,
                bytes4(keccak256(bytes("safeTransferFrom(address,address,uint256,bytes)"))),
                from, to, tokenId, ""
            )
        );

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
        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                //NFTState.safeTransferFrom.selector,
                bytes4(keccak256(bytes("safeTransferFrom(address,address,uint256,bytes)"))),
                from, to, tokenId, _data
            )
        );

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
        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                NFTState.transfer.selector,
                to, tokenId
            )
        );

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
    ) public virtual override {
        
        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                NFTState.safeTransfer.selector,
                to, tokenId
            )
        );
        
    }

    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                NFTState.burn.selector,
                tokenId
            )
        );

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
        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                NFTState.setTrustedForwarder.selector,
                trustedForwarder_
            )
        );

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
        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                NFTState.pushTokenTransferHook.selector,
                seriesId, contractAddress
            )
        );

    }

    function freeze(uint256 tokenId) public {
        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                //NFTState.freeze.selector,
                bytes4(keccak256(bytes("freeze(uint256)"))),
                tokenId
            )
        );

    }

    function freeze(uint256 tokenId, string memory baseURI_, string memory suffix_) public 
    {
        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                //NFTState.freeze.selector,
                bytes4(keccak256(bytes("freeze(uint256,string,string)"))),
                tokenId, baseURI_, suffix_
            )
        );
        
    }
    function unFreeze(uint256 tokenId) public {
        _functionDelegateCall(
            address(implNFTState), 
            abi.encodeWithSelector(
                NFTState.unFreeze.selector,
                tokenId
            )
        );
    }
      

    ///////////////////////////////////////
    //// public view section //////////////
    ///////////////////////////////////////
    /**
    * @dev tells the caller whether they can set info for a series,
    * manage amount of commissions for the series,
    * mint and distribute tokens from it, etc.
    * @param seriesId the id of the series being asked about
    */
    function canManageSeries(uint64 seriesId) public view returns (bool) {
        return abi.decode(
            _functionDelegateCallView(
                address(implNFTView), 
                abi.encodeWithSelector(
                    NFTView.canManageSeries.selector, 
                    seriesId
                ), 
                ""
            ), 
            (bool)
        );

    }

    /**
    * @dev tells the caller whether they can transfer an existing token,
    * list it for sale and remove it from sale.
    * Tokens can be managed by their owner
    * or approved accounts via {approve} or {setApprovalForAll}.
    * @param tokenId the id of the tokens being asked about
    */
    function canManageToken(uint256 tokenId) public view returns (bool) {
        return abi.decode(
            _functionDelegateCallView(
                address(implNFTView), 
                abi.encodeWithSelector(
                    NFTView.canManageToken.selector, 
                    tokenId
                ), 
                ""
            ), 
            (bool)
        );
        
    }

    /**
     * @dev Returns whether `tokenId` exists.
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function tokenExists(uint256 tokenId) public view virtual returns (bool) {
        return abi.decode(
            _functionDelegateCallView(
                address(implNFTView), 
                abi.encodeWithSelector(
                    NFTView.tokenExists.selector, 
                    tokenId
                ), 
                ""
            ), 
            (bool)
        );
    }

    /**
    * @dev returns contract URI. 
    */
    function contractURI() public view returns(string memory){
        return abi.decode(
            _functionDelegateCallView(
                address(implNFTView), 
                abi.encodeWithSelector(
                    NFTView.contractURI.selector
                ), 
                ""
            ), 
            (string)
        );
    }

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        return abi.decode(
            _functionDelegateCallView(
                address(implNFTView), 
                abi.encodeWithSelector(
                    NFTView.tokenOfOwnerByIndex.selector, 
                    owner, index
                ), 
                ""
            ), 
            (uint256)
        );
    }

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return abi.decode(
            _functionDelegateCallView(
                address(implNFTView), 
                abi.encodeWithSelector(
                    NFTView.totalSupply.selector
                ), 
                ""
            ), 
            (uint256)
        );
    }

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        return abi.decode(
            _functionDelegateCallView(
                address(implNFTView), 
                abi.encodeWithSelector(
                    NFTView.tokenByIndex.selector, 
                    index
                ), 
                ""
            ), 
            (uint256)
        );
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override /*override(ERC165Upgradeable, IERC165Upgradeable)*/ returns (bool) {
        return abi.decode(
            _functionDelegateCallView(
                address(implNFTView), 
                abi.encodeWithSelector(
                    NFTView.supportsInterface.selector, 
                    interfaceId
                ), 
                ""
            ), 
            (bool)
        );
      
    }

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        return abi.decode(
            _functionDelegateCallView(
                address(implNFTView), 
                abi.encodeWithSelector(
                    NFTView.balanceOf.selector, 
                    owner
                ), 
                ""
            ), 
            (uint256)
        );
    }

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        return abi.decode(
            _functionDelegateCallView(
                address(implNFTView), 
                abi.encodeWithSelector(
                    NFTView.ownerOf.selector, 
                    tokenId
                ), 
                ""
            ), 
            (address)
        );
    }

    /**
     * @dev Returns the token collection name.
     */
    function name() public view virtual override returns (string memory) {
        return abi.decode(
            _functionDelegateCallView(
                address(implNFTView), 
                abi.encodeWithSelector(
                    NFTView.name.selector
                ), 
                ""
            ), 
            (string)
        );
    }

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() public view virtual override returns (string memory) {
        return abi.decode(
            _functionDelegateCallView(
                address(implNFTView), 
                abi.encodeWithSelector(
                    NFTView.symbol.selector
                ), 
                ""
            ), 
            (string)
        );
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
        return abi.decode(
            _functionDelegateCallView(
                address(implNFTView), 
                abi.encodeWithSelector(
                    NFTView.tokenURI.selector,
                    tokenId
                ), 
                ""
            ), 
            (string)
        );

    }

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        return abi.decode(
            _functionDelegateCallView(
                address(implNFTView), 
                abi.encodeWithSelector(
                    NFTView.getApproved.selector,
                    tokenId
                ), 
                ""
            ), 
            (address)
        );
    }


 

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return abi.decode(
            _functionDelegateCallView(
                address(implNFTView), 
                abi.encodeWithSelector(
                    NFTView.isApprovedForAll.selector,
                    owner, operator
                ), 
                ""
            ), 
            (bool)
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
        return abi.decode(
            _functionDelegateCallView(
                address(implNFTView), 
                abi.encodeWithSelector(
                    NFTView.getTokenSaleInfo.selector,
                    tokenId
                ), 
                ""
            ), 
            (bool, bool, SaleInfo, address)
        );  
    }


    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function _verifyCallResult(
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
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        //require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }
    function _functionDelegateCallView(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        //require(isContract(target), "Address: static call to non-contract");
        data = abi.encodePacked(target,data);    
        (bool success, bytes memory returndata) = address(this).staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    fallback() external {
        
        if (msg.sender == address(this)) {

            address implementationLogic;
            
            bytes memory msgData = msg.data;
            bytes memory msgDataPure;
            uint256 offsetnew;
            uint256 offsetold;
            uint256 i;
            
            // extract address implementation;
            assembly {
                implementationLogic:= mload(add(msgData,0x14))
            }
            
            msgDataPure = new bytes(msgData.length-20);
            uint256 max = msgData.length + 31;
            offsetold=20+32;        
            offsetnew=32;
            // extract keccak256 of methods's hash
            assembly { mstore(add(msgDataPure, offsetnew), mload(add(msgData, offsetold))) }
            
            // extract left data
            for (i=52+32; i<=max; i+=32) {
                offsetnew = i-20;
                offsetold = i;
                assembly { mstore(add(msgDataPure, offsetnew), mload(add(msgData, offsetold))) }
            }
            
            // finally make call
            (bool success, bytes memory data) = address(implementationLogic).delegatecall(msgDataPure);
            assembly {
                switch success
                    // delegatecall returns 0 on error.
                    case 0 { revert(add(data, 32), returndatasize()) }
                    default { return(add(data, 32), returndatasize()) }
            }
            
        }
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}