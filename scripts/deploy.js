const fs = require('fs');
//const HDWalletProvider = require('truffle-hdwallet-provider');

function get_data(_message) {
    return new Promise(function(resolve, reject) {
        fs.readFile('./scripts/arguments.json', (err, data) => {
            if (err) {
                if (err.code == 'ENOENT' && err.syscall == 'open' && err.errno == -4058) {
					let obj = {};
					data = JSON.stringify(obj, null, "");
                    fs.writeFile('./scripts/arguments.json', data, (err) => {
                        if (err) throw err;
                        resolve(data);
                    });
                } else {
                    throw err;
                }
            } else {
            	resolve(data);
			}
        });
    });
}

async function main() {
	var data = await get_data();
    var data_object_root = JSON.parse(data);
	if (typeof data_object_root[hre.network.name] === 'undefined') {
		throw("Arguments file: missed data");
    } else if (typeof data_object_root[hre.network.name] === 'undefined') {
		throw("Arguments file: missed network data");
    }
	data_object = data_object_root[hre.network.name];
	if (
		typeof data_object.nft === 'undefined' ||
		typeof data_object.nftState === 'undefined' ||
		typeof data_object.nftView === 'undefined' ||
		typeof data_object.releaseManager === 'undefined' ||
		!data_object.nft ||
		!data_object.nftState ||
		!data_object.nftView ||
		!data_object.releaseManager
	) {
		throw("Arguments file: wrong addresses");
	}
	///----------
	const { BigNumber } = require('ethers');
	//const [deployer] = await ethers.getSigners();
	var signers = await ethers.getSigners();
    var deployer_nft;
    if (signers.length == 1) {
        deployer = signers[0];
    } else {
        [,,deployer_nft,] = signers;
    }

	const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
	console.log(
		"Deploying contracts with the account:",
		deployer_nft.address
	);

	var options = {
		//gasPrice: ethers.utils.parseUnits('50', 'gwei'), 
		gasLimit: 5e6
	};

	let _params = [
		data_object.nft,
		data_object.nftState,
		data_object.nftView,
		ZERO_ADDRESS, // costmanager
		data_object.releaseManager
	]
	let params = [
		..._params,
		options
	]
	
	const deployerBalanceBefore = await ethers.provider.getBalance(deployer_nft.address);
    console.log("Account balance:", (deployerBalanceBefore).toString());
	
	const FactoryFactory = await ethers.getContractFactory("NFTFactory");
	this.factory = await FactoryFactory.connect(deployer_nft).deploy(...params);
	
	console.log("Factory deployed at:", this.factory.target);
	console.log("with params:", [..._params]);
	console.log("registered with release manager:", data_object.releaseManager);

    const deployerBalanceAfter = await ethers.provider.getBalance(deployer_nft.address);
    console.log("Spent:", ethers.formatEther(deployerBalanceBefore - deployerBalanceAfter));
    console.log("gasPrice:", ethers.formatUnits((await network.provider.send("eth_gasPrice")), "gwei")," gwei");
    
}

main()
  .then(() => process.exit(0))
  .catch(error => {
	console.error(error);
	process.exit(1);
  });