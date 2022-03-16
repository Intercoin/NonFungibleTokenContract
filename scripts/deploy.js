async function main() {

	//const [deployer] = await ethers.getSigners();
	const [,deployer] = await ethers.getSigners();
	
	const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
	console.log(
	"Deploying contracts with the account:",
	deployer.address
	);
var options = {
    gasPrice: ethers.utils.parseUnits('50', 'gwei'), 
    gasLimit: 8e6
  };

	console.log("Account balance:", (await deployer.getBalance()).toString());

	const FactoryFactory = await ethers.getContractFactory("Factory");
	const NftFactory = await ethers.getContractFactory("NFTSafeHook");

	this.nft = await NftFactory.connect(deployer).deploy(options);

	const name = "NFT Video Test Rinkeby";
	const symbol = "NFTVTR";
	const contractURI = "https://pastebin.com/raw/XWrnD2Ve";
	this.factory = await FactoryFactory.connect(deployer).deploy(this.nft.address, ZERO_ADDRESS, options);


	console.log("NFT deployed at:", this.nft.address);
	console.log("Factory deployed at:", this.factory.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
	console.error(error);
	process.exit(1);
  });