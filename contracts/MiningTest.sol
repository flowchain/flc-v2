/**
 * Developed by The Flowchain Foundation
 *
 * The Flowchain tokens (FLC v2) smart contract
 */
pragma solidity 0.5.16;

/**
 * @title The mintable and off-chain issuable FLC standard.
 */
interface Token {
    function mintToken(address to, uint256 amount) external returns (bool success);

    /**
     * @dev Redeem the value of tokens to the address 'msg.sender'
     * @param amount Number of tokens to redeem.
     */
    function redeem(address to, uint256 amount) external returns (bool success);    
}

contract MiningTest {
    bool internal _isMinted;

    address private owner;
    Token public tokenReward;

    modifier restricted() {
        if (msg.sender == owner) _;
    }

    constructor(address _tokenAddress) public {
        owner = msg.sender;
        tokenReward = Token(_tokenAddress);
        _isMinted = false;
    }

    function issue(address _to, uint256 amount) public restricted returns (bool success) {
        tokenReward.redeem(_to, amount); 
        return true;
    }
}