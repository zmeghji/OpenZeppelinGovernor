pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract GovernanceToken is ERC20Votes{
    uint public maxSupply =21000000 * 10**18;
    constructor() 
        ERC20("GovernanceToken", "GT")
        ERC20Permit("GovernanceToken")
    { 
        _mint(msg.sender, maxSupply);
    }
    

}