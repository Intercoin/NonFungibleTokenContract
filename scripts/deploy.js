async function main() {

	const [deployer] = await ethers.getSigners();

	console.log(
	"Deploying contracts with the account:",
	deployer.address
	);

	console.log("Account balance:", (await deployer.getBalance()).toString());

	const NFT = await ethers.getContractFactory("NFT");
	const contract = await NFT.deploy();

	console.log("Contract deployed at:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
	console.error(error);
	process.exit(1);
  });