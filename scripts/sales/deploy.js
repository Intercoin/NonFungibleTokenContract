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
	//const [deployer] = await ethers.getSigners();

	var signers = await ethers.getSigners();
    var deployer_sales;
    if (signers.length == 1) {
        deployer = signers[0];
    } else {
        [,,,deployer_sales] = signers;
    }

	console.log(
		"Deploying contracts with the account:",
		deployer_sales.address
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

	const deployerBalanceBefore = await deployer_sales.getBalance();
    console.log("Account balance:", (deployerBalanceBefore).toString());

	const NFTSalesFactoryFactory = await ethers.getContractFactory("NFTSalesFactory");
	this.factory = await NFTSalesFactoryFactory.connect(deployer_sales).deploy(...params);

	console.log("Factory deployed at:", this.factory.address);
	console.log("with params:", [..._params]);


	const deployerBalanceAfter = await deployer_sales.getBalance();
    console.log("Spent:", ethers.utils.formatEther(deployerBalanceBefore.sub(deployerBalanceAfter)));
    console.log("gasPrice:", ethers.utils.formatUnits((await network.provider.send("eth_gasPrice")), "gwei")," gwei");
}

main()
  .then(() => process.exit(0))
  .catch(error => {
	console.error(error);
	process.exit(1);
  });