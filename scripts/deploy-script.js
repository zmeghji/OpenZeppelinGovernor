


const hre = require("hardhat");

async function main() {
    const deployer = (await hre.ethers.getSigners())[0];
    //deploy governance token
    let governanceToken = await deploy("GovernanceToken", [])

    //delegate the tokens of deployer account to itself
    await governanceToken.delegate(deployer.address);
    console.log("deployer delegated tokens to self")

    //Deploy the timelock controller
    let myTimelockController = await deploy("MyTimelockController", [1, [], []])
    
    //Deploy the governance contract 
    let myGovernor = await deploy ("MyGovernor", 
        [governanceToken.address, myTimelockController.address])

    //get roles;
    let proposerRole = await myTimelockController.PROPOSER_ROLE();
    let executorRole = await myTimelockController.EXECUTOR_ROLE();
    let adminRole  = await myTimelockController.TIMELOCK_ADMIN_ROLE();
    

    //Grant proposer role on timelock controller to governance contract
    await myTimelockController.grantRole(proposerRole, myGovernor.address);
    await myTimelockController.grantRole(executorRole, myGovernor.address);

    console.log("Granted govenor proposer role on timelock controller")

    //revoke admin role from deployer account
    await myTimelockController.revokeRole(adminRole, myGovernor.address);
    console.log("Revoked govenor's admin role on timelock controller")

    //deploy Greeter
    let greeter = await deploy("Greeter", ["Hello, Hardhat!"])
    
    //Transfer ownership of greeter to Timelock Controller
    greeter.transferOwnership(myTimelockController.address);
    console.log("Transferred ownership greeter to timelock controller");

    // deployer creates proposal through governor contract
    let ABI = [
        "function setGreeting(string memory _greeting) public"
    ];
    let greeterInterface = new hre.ethers.utils.Interface(ABI);
    let encodedFunction = greeterInterface.encodeFunctionData(
        "setGreeting",["New Greeting Yay!"]
    );

    let targets = [greeter.address]
    let values  = [0];
    let calldatas = [encodedFunction];
    let description = "Changing the Greeting";
    await myGovernor.propose(
        targets,
        values,
        calldatas,
        description
    )
    console.log("Created proposal");

    let descriptionHash = ethers.utils.id(description);
    const proposalId = await myGovernor.hashProposal(
        targets,
        values,
        calldatas,
        descriptionHash
    )
    console.log("Proposal id " + proposalId);

    //Wait for two blocks
    await hre.ethers.provider.send("evm_mine");
    await hre.ethers.provider.send("evm_mine");

    // castVoteWithReason to governor contract
    await myGovernor.castVoteWithReason(proposalId,1, "I like the new greeting.")
    console.log("Cast Vote!!!");

    //Wait for five blocks
    await hre.ethers.provider.send("evm_mine");
    await hre.ethers.provider.send("evm_mine");
    await hre.ethers.provider.send("evm_mine");
    await hre.ethers.provider.send("evm_mine");
    await hre.ethers.provider.send("evm_mine");


    //queue proposal for execution using governor contract
    await myGovernor.queue(
        targets,
        values,
        calldatas,
        descriptionHash
    )
    console.log("queued proposal for execution ")

    //execute through governance contract
    await myGovernor.execute(
        targets,
        values,
        calldatas,
        descriptionHash
    )
    console.log("Executed Proposal");

    //Verify Change
    let newGreeting = await greeter.greet();
    console.log(`The new greeting is ${newGreeting}`);
}

async function deploy(contractName, constructorArgs){
    const Contract = await hre.ethers.getContractFactory(contractName);
    const contract = await Contract.deploy(...constructorArgs);
    await contract.deployed();
    console.log(`${contractName} deployed to:`, contract.address);
    return contract;
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
