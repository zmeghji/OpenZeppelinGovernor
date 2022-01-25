//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Governor.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

abstract contract GovernorVotes is Governor{
    ERC20Votes public immutable token;
    constructor(ERC20Votes tokenAddress){
        token =tokenAddress;
    }
    
    function getVotes(address account, uint blockNumber)
        public view virtual override returns(uint256){
            //TODO investigate how the ERC20Votes works
            //Presumably this gets the number of tokens the account had at the provided block number
            return token.getPastVotes(account, blockNumber);
        }
}