//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./GovernorVotes.sol";

abstract contract GovernorVotesQuorumFraction is GovernorVotes{
    uint256 private _quorumNumerator;
    
    event QuorumNumeratorUpdated(uint256 oldQuorumNumberator, uint256 newQuorumNumerator);

    constructor(uint256 quorumNumerator){
        _updateQuorumNumerator(quorumNumerator);
    }
    function quorumNumerator() public view virtual returns(uint256){
        return _quorumNumerator;
    }
    function quorumDenominator() public view virtual returns(uint256){
        return 100;
    }
    function quorum(uint256 blockNumber) public view virtual override returns (uint256) {
        return (token.getPastTotalSupply(blockNumber) * quorumNumerator()) / quorumDenominator();
    }

    function updateQuorumNumerator(uint256 newQuorumNumerator) external virtual onlyGovernance {
        _updateQuorumNumerator(newQuorumNumerator);
    }

    function _updateQuorumNumerator(uint256 newQuorumNumerator) internal virtual {
        require(
            newQuorumNumerator <= quorumDenominator(),
            "GovernorVotesQuorumFraction: quorumNumerator over quorumDenominator"
        );

        uint256 oldQuorumNumerator = _quorumNumerator;
        _quorumNumerator = newQuorumNumerator;

        emit QuorumNumeratorUpdated(oldQuorumNumerator, newQuorumNumerator);
    }


}