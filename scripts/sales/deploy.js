const fs = require('fs');
//const HDWalletProvider = require('truffle-hdwallet-provider');

function get_data(_message) {
    return new Promise(function(resolve, reject) {
        fs.readFile('./scripts/sales/arguments.json', (err, data) => {
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
		typeof data_object.nftSales === 'undefined' ||
		!data_object.nftSales 
	) {
		throw("Arguments file: wrong addresses");
	}
	///----------
	const { BigNumber } = require('ethers');
	const [deployer] = await ethers.getSigners();
	
	console.log(
		"Deploying contracts with the account:",
		deployer.address
	);

	var options = {
		//gasPrice: ethers.utils.parseUnits('50', 'gwei'), 
		gasLimit: 5e6
	};

	let _params = [
		data_object.nftSales
	]
	let params = [
		..._params,
		options
	]

	let deployerBalanceAtBegin = await deployer.getBalance();
	console.log("Started account balance:", (deployerBalanceAtBegin).toString());

	const NFTSalesFactoryFactory = await ethers.getContractFactory("NFTSalesFactory");
	this.factory = await NFTSalesFactoryFactory.connect(deployer).deploy(...params);

	console.log("Factory deployed at:", this.factory.address);
	console.log("with params:", [..._params]);


	let deployerBalanceInTheEnd = await deployer.getBalance();
	console.log("ETH spent: ", ethers.utils.formatEther(BigNumber.from(deployerBalanceAtBegin).sub(BigNumber.from(deployerBalanceInTheEnd))));
}

main()
  .then(() => process.exit(0))
  .catch(error => {
	console.error(error);
	process.exit(1);
  });