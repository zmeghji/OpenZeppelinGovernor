// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//ERC165 just provides a function which verifies whether this contract supports a particular interface
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";


abstract contract IGovernor is IERC165{

    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }

    //values are ether amounts to send in the call and calldatas are a combination of function signature and data to pass
    event ProposalCreated(
        uint256 proposalId,
        address proposer,
        address[] targets,
        uint256[] values,
        string[] signatures,
        bytes[] calldatas,
        uint256 startBlock,
        uint256 endBlock,
        string description
    );

    event ProposalCanceled(uint256 proposalId);
    event ProposalExecuted(uint256 proposalId);

    //TODO findout what support and weight values mean
    event VoteCast(address indexed voter, uint256 proposalId, uint8 support, uint256 weight, string reason);

    //returns the name of the governor
    function name() public view virtual returns (string memory);
    
    //returns governor version
    function version() public view virtual returns(string memory);

    //used to return information about the voting process using keyvalue pairs for example:
        //`support=bravo&quorum=for,abstain`
    //Mainly for the benefit of front-end dapps 
    function COUNTING_MODE() public pure virtual returns (string memory);

    //Returns proposal id based on proposal details
    function hashProposal(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata calldatas,
        bytes32 descriptionHash
    ) public pure virtual returns (uint256);

    //returns current state of proposal
    function state(uint256 proposalId) public view virtual returns (ProposalState);

    //returns the snapshot block number for the proposal 
    function proposalSnapshot(uint proposalId) public view virtual returns(uint256);

    //last block number at which a vote can be cast for the proposal
    function proposalDeadline(uint proposalId) public view virtual returns (uint256);

    //number of blocks between when the proposal is created and when the voting starts
    function votingDelay() public view virtual returns (uint256);

    //number of blocks between when the voting starts and stops 
    function votingPeriod() public view virtual returns (uint256);

    //minimum number of votes required for proposal to pass
    //block number is the snapshot block for the proposal (matters because quorum number depends on total supply at that block)
    function quorum(uint256 blockNumber) public view virtual returns(uint256);

    //gets voting power of address at a certain block
    function getVotes(address account, uint256 blockNumber) public view virtual returns(uint256);

    //returns whether account has cast vote on proposal id
    function hasVoted(uint256 proposalId, address account) public view virtual returns(bool);

    // Create a new proposal , emits proposalcreated event
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public virtual returns (uint256 proposalId);

    //execute a successful proposal , emits proposalexecuted event
    //This call will actually execute the methods at the specified targets, with ether values and calldatas specified
    function execute(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public payable virtual returns (uint256 proposalId);

    //cast a vote , emits vote cast event 
    // TODO find out what support means and what is returned by this function
    function castVote(uint256 proposalId, uint8 support) public virtual returns(uint256 balance);

    //cast a vote with a reason, emits vote cast event 
    function castVoteWithReason(
        uint256 proposalId, 
        uint8 support,
        string calldata reason
    ) public virtual returns(uint256 balance);


    //casts vote, emits votecast event
    //TODO find out what v, r, and s are 
    function castVoteBySig(
        uint256 proposalId,
        uint8 support,
        uint8 v,
        bytes32 r, 
        bytes32 s
    ) public virtual returns (uint256 balance);

    
}