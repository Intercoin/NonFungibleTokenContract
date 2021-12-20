async function main() {

	const [deployer] = await ethers.getSigners();
	const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
	console.log(
	"Deploying contracts with the account:",
	deployer.address
	);

	console.log("Account balance:", (await deployer.getBalance()).toString());

	const FactoryFactory = await ethers.getContractFactory("Factory");
	const NftFactory = await ethers.getContractFactory("NFTSafeHook");

	this.nft = await NftFactory.deploy({gasLimit: 5e6});

	const name = "NFT ContractURI BSC";
	const symbol = "NFTCUB";
	const contractURI = "https://pastebin.com/raw/armzdJZr";
	this.factory = await FactoryFactory.deploy(this.nft.address, name, symbol, contractURI, ZERO_ADDRESS, {gasLimit: 3e6});


	console.log("NFT deployed at:", this.nft.address);
	console.log("Factory deployed at:", this.factory.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
	console.error(error);
	process.exit(1);
  });