async function main() {

	const [deployer] = await ethers.getSigners();
	
	const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
  	// const discountSensitivity = 0;

	var options = {
		//gasPrice: ethers.utils.parseUnits('150', 'gwei'), 
		gasLimit: 5e6
	};
	

	console.log("Deploying contracts with the account:",deployer.address);
	console.log("Account balance:", (await deployer.getBalance()).toString());

	const NFTSalesF = await ethers.getContractFactory("NFTSales");
  	const NFTSalesFactoryF = await ethers.getContractFactory("NFTSalesFactory");

	this.implementation = await NFTSalesF.connect(deployer).deploy(options);

	let _params = [this.implementation.address];
	
	let params = [
		..._params,
		options
	]
	
	this.factory = await NFTSalesFactoryF.connect(deployer).deploy(...params);

	console.log("Implementation deployed at:", this.implementation.address);
	console.log("--------------------");
	console.log("Factory deployed at:", this.factory.address);
	console.log("with params:", [..._params]);

}

main()
  .then(() => process.exit(0))
  .catch(error => {
	console.error(error);
	process.exit(1);
  });