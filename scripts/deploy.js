async function main() {
	const { BigNumber } = require('ethers');
	//const [deployer] = await ethers.getSigners();
	const [,deployer] = await ethers.getSigners();
	
	const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
	console.log(
		"Deploying contracts with the account:",
		deployer.address
	);

	var options = {
		//gasPrice: ethers.utils.parseUnits('50', 'gwei'), 
		gasLimit: 5e6
	};
	let deployerBalanceAtBegin = await deployer.getBalance();
	console.log("Started account balance:", (deployerBalanceAtBegin).toString());

	const FactoryFactory = await ethers.getContractFactory("Factory");
	const NftFactory = await ethers.getContractFactory("NFT");

	const NFTStateFactory = await ethers.getContractFactory("NFTState");
	const NFTViewFactory = await ethers.getContractFactory("NFTView");
        
	this.nftState = await NFTStateFactory.connect(deployer).deploy();
	this.nftView = await NFTViewFactory.connect(deployer).deploy();

	this.nft = await NftFactory.connect(deployer).deploy(options);

	this.factory = await FactoryFactory.connect(deployer).deploy(this.nft.address, this.nftState.address, this.nftView.address, ZERO_ADDRESS, options);


	console.log("NFT deployed at:", this.nft.address);
	console.log("Factory deployed at:", this.factory.address);
	let deployerBalanceInTheEnd = await deployer.getBalance();
	console.log("ETH spent: ", ethers.utils.formatEther(BigNumber.from(deployerBalanceAtBegin).sub(BigNumber.from(deployerBalanceInTheEnd))));
}

main()
  .then(() => process.exit(0))
  .catch(error => {
	console.error(error);
	process.exit(1);
  });