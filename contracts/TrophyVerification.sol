// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28; // solidity compiler version

import "hardhat/console.sol";

contract TrophyVerification {
    // custom errors (gas optimization)
    error OnlyFederation();
    error TrophyNotPending();
    error InvalidTrophyId();

    /**  VARIABLES && ENUMS */

    // public variable of type address
    address public immutable federation;

    // enumeration VerificationStatus: 3 possible values  
    enum VerificationStatus { 
        Pending,
        Verified, 
        Rejected 
    }

    /** TROPHY STRUCT */
    struct Trophy {
        uint256 id; // unsigned integer
        string name;
        string description;
        VerificationStatus status;
        address requester; // can be athlete || coach || club
        uint256 timestamp;
    }

    /** STORAGE */
    uint256 private nextTrophyId;
    
    mapping(uint256 => Trophy) public trophies; // mapping trophyId to trophy
    mapping(address => uint256[]) public trophiesByOwner; // mapping address to array of their trophyId

    /** EVENTS */

    // emitted when user request a new trophy
    event TrophyRequested(
        uint256 indexed id,
        string name,
        address indexed requester,
        uint256 timestamp
    );

    // emitted when federation verifies or rejects a trophy    
    event TrophyVerified(
        uint256 indexed id,
        VerificationStatus status,
        uint256 timestamp
    );

    modifier onlyFederation() {
        if (msg.sender != federation) {
            revert OnlyFederation();
        }
        _;
    }

    /** CONSTRUCTOR */

    // executed when the contract deployed
    constructor() {
        federation = msg.sender;
    }

    // request trophy function 
    function requestTrophy(
        string calldata name,
        string calldata description
    ) external returns (uint256 trophyId) {
        trophyId = nextTrophyId++;

        Trophy memory newTrophy = Trophy({
            id: trophyId,
            name: name,
            description: description,
            status: VerificationStatus.Pending,
            requester: msg.sender,
            timestamp: block.timestamp
        });

        trophies[trophyId] = newTrophy;
        trophiesByOwner[msg.sender].push(trophyId);

        emit TrophyRequested(
            trophyId,
            name,
            msg.sender,
            block.timestamp
        );
    }

    // verification trophy function
    function verifyTrophy(
        uint256 trophyId,
        bool approved
    ) external onlyFederation {
        Trophy storage trophy = trophies[trophyId];
        
        if (trophy.requester == address(0)) {
            revert InvalidTrophyId();
        }
        
        if (trophy.status != VerificationStatus.Pending) {
            revert TrophyNotPending();
        }

        trophy.status = approved ? VerificationStatus.Verified : VerificationStatus.Rejected;

        emit TrophyVerified(
            trophyId,
            trophy.status,
            block.timestamp
        );
    }

    // get trophies by owner function
    function getTrophiesByOwner(
        address owner
    ) external view returns (uint256[] memory) {
        return trophiesByOwner[owner];
    }
    
    // get all trophies function
    function getTotalTrophies() external view returns (uint256) {
        return nextTrophyId;
    }
}