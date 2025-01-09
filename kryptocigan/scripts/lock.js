const { ethers } = require("hardhat");
const LockArtifact = require("../artifacts/contracts/Lock.sol/Lock.json");
const UNISWAP_ROUTER_ADDRESS = '0x33128a8fC17869897dcE68Ed026d694621f6FDfD';
const TOKEN_ADDRESS = '0xdAC17F958D2ee523a2206206994597C13D831ec7';

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    const Lock = await ethers.getContractFactory("Lock");
    const lock = await Lock.deploy(UNISWAP_ROUTER_ADDRESS, TOKEN_ADDRESS);
    await lock.waitForDeployment();

    console.log("Lock deployed to:", await lock.getAddress());

    // const MockLock = await ethers.getContractFactory("contracts/MockUniswap.sol:MockUniswap");
    // const mocklock = await MockLock.deploy();
    // await mocklock.waitForDeployment();
    //
    // console.log("MockLock deployed to: ", await mocklock.getAddress());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
// npx hardhat run scripts/lock.js --network localhost