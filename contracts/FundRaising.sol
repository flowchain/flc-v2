/**
 * Developed by The Flowchain Foundation
 *
 * The Flowchain tokens (FLC v2) smart contract
 */
pragma solidity 0.5.16;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}

/**
 * @title The mintable and offchain issuable token.
 */
interface Dextoken {
    function mint(address to, uint amount) external returns (bool success);    
    function redeem(address to, uint amount) external returns (bool success); 
}

contract FundRaising {
    using SafeMath for uint;

    address public owner;
    address public pool;

    /*
     * According to the whitepaper, we issue 1,000,000 DEXG tokens for
     * fund raising.
     */
    uint public max_mintable_amount = 1000000;

    Dextoken public DEXG;

    mapping (address => uint) private _balances;

    modifier onlyOwner() {
        if (msg.sender == owner) _;
    }

    constructor(address tokenAddress) public {
        owner = msg.sender;
        pool = address(this);

        DEXG = Dextoken(tokenAddress);

        _balances[owner] = max_mintable_amount;
    }

    function issue(address team, uint amount) external onlyOwner returns (bool success) {
        require(team != address(0), "ERC20: zero address");

        _balances[owner] = _balances[owner].sub(amount, "ERC20: amount exceeds balance");

        DEXG.mint(team, amount);

        return true;
    }

    function redeem(uint amount) external onlyOwner returns (bool success) {
        DEXG.redeem(pool, amount);

        return true;
    } 

    function getMintableBalance() external view returns (uint) {
        return _balances[owner];
    }       
}