module.exports = function dataExtend() {
    
    return {
        'contracts/v2/NFTMain.sol': {
            'description': [
                'This it main part of NFT contract.',
            ].join("<br>"),
            //'constructor':{'custom:shortd': 'part of ERC20'},
            'exclude': [
                'initialize',

                // 'ADMIN_ROLE', 'DEFAULT_ADMIN_ROLE', 'REDEEM_ROLE', 'CIRCULATION_ROLE', 'CIRCULATION_DEFAULT', 
                // 'authorizeOperator',
                // 'decimals',
                // 'defaultOperators',
                // 'tokensReceived',
                // 'supportsInterface',
            ],
            'fix': {
                'baseURI': {'custom:shortd': 'global baseURI'},
                'suffix': {'custom:shortd': 'global suffix'},
                'commissionInfo': {'custom:shortd': 'global commission data '},
                'costManager': {'custom:shortd': 'costManager address'},
                'factory': {'custom:shortd': 'factory produced that instance'},
                'mintedCountBySeries': {'custom:shortd': 'amount of tokens minted in certain series'},
                'owner': {'custom:shortd': 'contract owner\'s address'},
                'renounceOwnership': {'custom:calledby': 'owner', 'custom:shortd': 'leaves contract without owner'},
                'seriesInfo': {'custom:shortd': 'series info'},
                'transferOwnership': {'custom:shortd': 'Transfers ownership of the contract to a new account'},
                'trustedForwarder': {'custom:shortd': 'trusted forwarder\'s address'},
                
            },
        },
        
    };
}
