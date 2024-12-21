// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28; // solidity compiler version

import "hardhat/console.sol";

contract TrophyVerification{
    /**  VARIABLES && ENUMS */

    // public variable of type address
    address public federation;

    // enumeration VerificationStatus: 3 possible values  
    enum VerificationStatus { Pending, Verified, Rejected }

    /** TROPHY STRUCT */
    struct Trophy {
        uint256 id; // unsigned integer
        string name;
        string description;
        VerificationStatus status;
        address requester; // can be athlete || coach || club
    }

    /** STORAGE */
    uint256 public nextTrophyId; // auto-increment
    mapping(uint256 => Trophy) public trophies; // mapping trophyId to trophy
    mapping(address => uint256[]) public trophiesByOwner; // mapping address to array of their trophyId

    /** EVENTS */

    // emitted when user request a new trophy
    event TrophyRequested(uint256 indexed id, string name, address indexed requester);

    // emitted when federation verifies or rejects a trophy    
    event TrophyVerified(uint256 indexed id, VerificationStatus status);

    /** CONSTRUCTOR */

    // executed when the contract deployed
    constructor() {
        federation = msg.sender; // set federation to address of deployer
    }


    // request trophy function 
    function requestTrophy(string memory name, string memory description) public returns (uint256) {
        uint256 trophyId = nextTrophyId++;

        trophies[trophyId] = Trophy({
            id: trophyId,
            name: name,
            description: description,
            status: VerificationStatus.Pending,
            requester: msg.sender
        });

        trophiesByOwner[msg.sender].push(trophyId);

        emit TrophyRequested(trophyId, name, msg.sender);
        return trophyId;
    }

    // verification trophy function
    function verifyTrophy(uint256 trophyId, bool approved) public {
        require(msg.sender == federation, "Only federation can verify");
        require(trophies[trophyId].status == VerificationStatus.Pending, "Not pending");

        VerificationStatus newStatus = approved ? VerificationStatus.Verified : VerificationStatus.Rejected;
        trophies[trophyId].status = newStatus;

        emit TrophyVerified(trophyId, newStatus);
    }

    // get trophies by owner function
    function getTrophiesByOwner(address owner) public view returns (uint256[] memory) {
        return trophiesByOwner[owner];
    }

    // get all trophies function
    function getTotalTrophies() public view returns (uint256) {
        return nextTrophyId;
    }
}