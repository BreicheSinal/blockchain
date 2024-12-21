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
    uint256 public trophyId; // auto-increment
    mapping(uint256 => Trophy) public trophies; // mapping trophyId to trophy
    mapping(address => uint256[]) public trophiesByOwner; // mapping address to array of their trophyId

    /** EVENTS */

    // emitted when user request a new trophy
    event TrophyRequested(uint256 indexed id, string name, address indexed requester);

    // emitted when federation verifies or rejects a trophy    
    event TrophyVerified(uint256 indexed id, VerificationStatus status);

}