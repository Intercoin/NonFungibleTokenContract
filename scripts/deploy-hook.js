const hre = require("hardhat");

async function main() {

	const [deployer] = await ethers.getSigners();
	
	console.log("Deploying contracts with the account:",deployer.address);
	console.log("Account balance:", (await deployer.getBalance()).toString());

	const LockedHookF = await ethers.getContractFactory("LockedHook");

	let constructorArguments = [];
	
	this.lockedHook = await LockedHookF.connect(deployer).deploy(constructorArguments);

    console.log("waiting 20 blocks to be sure that tx mined");   
    await this.lockedHook.deployTransaction.wait(20);

    let version =  await this.lockedHook.version();
	console.log("lockedHook deployed at:", this.lockedHook.address);
    console.log("   version: ", version.join('.'));

    console.log("try to verify");

    await hre.run("verify:verify", {
        address: this.lockedHook.address,
        contract: "contracts/LockedHook.sol:LockedHook", 
        constructorArguments: constructorArguments,
    });	
}

main()
    .then(() => process.exit(0))
    .catch(error => {
	    console.error(error);
	    process.exit(1);
    });