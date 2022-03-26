// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Airdrop {
    uint immutable dropStartTime;
    uint immutable dropEndTime;
    uint lastDropTime;
    
    uint constant MAX_LIMIT = 150;
    uint constant TWELVE_MONTHS = 31557600000;
    uint constant ONE_DAY = 86400000;

    mapping (address => uint) public airdrops;

    constructor()    {
        dropStartTime = block.timestamp;
        dropEndTime = dropStartTime + TWELVE_MONTHS;
    }

    function drop (address account) internal {
        require (isDropAvailable(block.timestamp), "invalid drop");
        require (airdrops[account] + 1 > MAX_LIMIT, "max drops reached");
        airdrops[account] += 1;
    }

    function isDropAvailable(uint timestamp) private view returns (bool diff) {
        if (timestamp - lastDropTime > ONE_DAY) return false;
        if (timestamp > dropEndTime) return false;
        return true;
    }

}