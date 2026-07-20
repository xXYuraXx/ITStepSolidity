// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract VoteOnline {
    address private owner;
    mapping(string => Candidate) private candidates;
    string[] private candidates_names;
    mapping(address => Voter) private voters;
    address[] private voters_addresses;

    struct Voter {
        bool voted;
    }

    struct Candidate {
        bool isExist;
        uint voteCount;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Sender is not owner");
        _;
    }

    constructor () {
        owner = msg.sender;
    }

    function addCandidate(string memory name) public payable {
        require(msg.value == 1 ether, "For adding candidate you must pay 1 ether");
        require(!candidates[name].isExist, "Candidate already exist");

        payable(owner).transfer(1 ether);
        candidates[name].isExist = true;
        candidates_names.push(name);
    }

    function vote(string memory candidate) public {
        address _voter = msg.sender;
        require(!voters[_voter].voted, "You already voted");
        require(candidates[candidate].isExist, "Candidate doesn't exist");

        voters[_voter].voted = true;
        candidates[candidate].voteCount += 1;
        voters_addresses.push(msg.sender);
    }

    function getWinner() public isOwner view returns(string memory) {
        require(candidates_names.length > 0, "No candidates");
        require(voters_addresses.length > 0, "No votes");

        uint maxVotes = 0;
        string memory winnerName = "-";
        for (uint i = 0; i < candidates_names.length; i++) 
        {
            if (candidates[candidates_names[i]].voteCount > maxVotes) {
                winnerName = candidates_names[i];
                maxVotes = candidates[candidates_names[i]].voteCount;
            }
        }
        return winnerName;
    }

    function resetAll() public {
        for (uint i = 0; i < candidates_names.length; i++) 
        {
            candidates[candidates_names[i]].voteCount = 0;
            candidates[candidates_names[i]].isExist = false;
        }
        delete candidates_names;
        
        for (uint i = 0; i < voters_addresses.length; i++)
        {
            delete voters[voters_addresses[i]];
        }
        delete voters_addresses;

    }
}