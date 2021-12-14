async function main() {

	const [deployer] = await ethers.getSigners();

	console.log(
	"Deploying contracts with the account:",
	deployer.address
	);

	console.log("Account balance:", (await deployer.getBalance()).toString());

	const FactoryFactory = await ethers.getContractFactory("Factory");
	const NftFactory = await ethers.getContractFactory("NFTSafeHook");

	this.nft = await NftFactory.deploy({gasLimit: 10e6});

	const name = "NFT Edition";
	const symbol = "NFT";
	this.factory = await FactoryFactory.deploy(this.nft.address, name, symbol, {gasLimit: 10e6});


	console.log("NFT deployed at:", this.nft.address);
	console.log("Factory deployed at:", this.factory.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
	console.error(error);
	process.exit(1);
  });