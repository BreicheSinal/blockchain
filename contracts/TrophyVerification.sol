// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28; // solidity compiler version

import "hardhat/console.sol";

contract TrophyVerification{
    // VARIABLES && ENUMS

    // public variable of type address
    address public federation;

    // enumeration VerificationStatus: 3 possible values  
    enum VerificationStatus { Pending, Verified, Rejected }

    // TROPHY STRUCT
    struct Trophy {
    uint256 id; // unsigned integer
    string name;
    string description;
    VerificationStatus status;
    address requester; // can be athlete || coach || club
}
}