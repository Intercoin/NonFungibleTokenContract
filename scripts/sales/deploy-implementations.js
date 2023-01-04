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
            }
    
            resolve(data);
        });
    });
}

function write_data(_message) {
    return new Promise(function(resolve, reject) {
        fs.writeFile('./scripts/sales/arguments.json', _message, (err) => {
            if (err) throw err;
            console.log('Data written to file');
            resolve();
        });
    });
}

async function main() {
	var data = await get_data();

    var data_object_root = JSON.parse(data);
	var data_object = {};
	if (typeof data_object_root[hre.network.name] === 'undefined') {
        data_object.time_created = Date.now()
    } else {
        data_object = data_object_root[hre.network.name];
    }
	//----------------

	const [deployer] = await ethers.getSigners();
	
	console.log(
		"Deploying contracts with the account:",
		deployer.address
	);

	// var options = {
	// 	//gasPrice: ethers.utils.parseUnits('50', 'gwei'), 
	// 	gasLimit: 10e6
	// };
    let deployerBalanceAtBegin = await deployer.getBalance();

	console.log("Account balance:", (deployerBalanceAtBegin).toString());

	const NFTSalesFactory = await ethers.getContractFactory("NFTSales");
	
	let nftSales= await NFTSalesFactory.connect(deployer).deploy();

   // await nftSales.wait();
    
	console.log("Implementations:");
	console.log("  nftSales deployed at:       ", nftSales.address);

    let deployerBalanceInTheEnd = await deployer.getBalance();
	console.log("ETH spent: ", ethers.utils.formatEther(deployerBalanceAtBegin.sub(deployerBalanceInTheEnd)));

	data_object.nftSales = nftSales.address;
	
	//---
	const ts_updated = Date.now();
    data_object.time_updated = ts_updated;
    data_object_root[`${hre.network.name}`] = data_object;
    data_object_root.time_updated = ts_updated;
    let data_to_write = JSON.stringify(data_object_root, null, 2);
	console.log(data_to_write);
    await write_data(data_to_write);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
	console.error(error);
	process.exit(1);
  });