/**
 * Developed by The Flowchain Foundation
 */
pragma solidity 0.5.16;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
        newOwner = address(0);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyNewOwner() {
        require(msg.sender != address(0));
        require(msg.sender == newOwner);
        _;
    }
    
    function isOwner(address account) public view returns (bool) {
        if( account == owner ){
            return true;
        }
        else {
            return false;
        }
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        newOwner = _newOwner;
    }

    function acceptOwnership() public onlyNewOwner {
        emit OwnershipTransferred(owner, newOwner);        
        owner = newOwner;
        newOwner = address(0);
    }
}

/**
 * @title Pausable
 * @dev The Pausable can pause and unpause the token transfers.
 */
contract Pausable is Ownable {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }    

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

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
 * @title The mintable FLC tokens.
 */
contract Mintable {
    /**
     * @dev Mint a amount of tokens and the funds to the user.
     */
    function mintToken(address to, uint256 amount) public returns (bool success);  

    /**
     * @dev Setup a mintable address that can mint or mine tokens.
     */    
    function setupMintableAddress(address _mintable) public returns (bool success);
}

/**
 * @title The off-chain issuable FLC tokens.
 */
contract OffchainIssuable {
    using SafeMath for uint;

    mapping (address => uint) public _amountMinted;
    mapping (address => uint) public _amountRedeem;

    /**
     * The minimal withdraw ammount.
     */
    uint public _min_withdraw_amount = 100;

    /**
     * @dev Suspend the issuance of new tokens.
     * Once set to false, '_isIssuable' can never be set to 'true' again.
     */
    function setMinWithdrawAmount(uint amount) public returns (bool success);

    /**
     * @dev Resume the issuance of new tokens.
     * Once set to false, '_isIssuable' can never be set to 'true' again.
     */
    function getMinWithdrawAmount() public view returns (uint amount);

    /**
     * @dev Returns the amount of tokens redeemed to `_owner`.
     * @param _owner The address from which the amount will be retrieved
     * @return The amount
     */
    function amountRedeemOf(address _owner) public view returns (uint amount);

    /**
     * @dev Returns the amount of tokens withdrawn by `_owner`.
     * @param _owner The address from which the amount will be retrieved
     * @return The amount
     */
    function amountWithdrawOf(address _owner) public view returns (uint amount);

    /**
     * @dev Redeem the value of tokens to the address 'msg.sender'
     * @param to The user that will receive the redeemed token.
     * @param amount Number of tokens to redeem.
     */
    function redeem(address to, uint amount) external returns (bool success);

    /**
     * @dev The user withdraw API.
     * @param amount Number of tokens to redeem.
     */
    function withdraw(uint amount) public returns (bool success);   
}

/**
 * @title The ERC20 tokens
 */
interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Context {
    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}

/**
 * @dev The ERC20 standard implementation.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint;

    mapping (address => uint) private _balances;
    mapping (address => mapping (address => uint)) private _allowances;

    uint private _totalSupply;

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint) {
        return _balances[account];
    }

    function transfer(address recipient, uint amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

/**
 * @dev Extension of ERC-20 that adds off-chain issuable and mintable tokens.
 * It allows miners to mint (create) new DIO tokens.
 *
 * At construction, the contract `_mintableAddress` is the only token minter.
 */
contract DexToken is ERC20, ERC20Detailed, Mintable, OffchainIssuable, Ownable, Pausable {
    using SafeMath for uint;

    bool internal _isIssuable;

    event Freeze(address indexed account);
    event Unfreeze(address indexed account);

    mapping (address => bool) public minters;
    mapping (address => bool) public frozenAccount;

    modifier notFrozen(address _account) {
        require(!frozenAccount[_account]);
        _;
    }

    constructor () public ERC20Detailed("Dextoken.io", "DIO", 18) {
        _isIssuable = true;
    }

    function transfer(address to, uint value) public notFrozen(msg.sender) whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }   

    function transferFrom(address from, address to, uint value) public notFrozen(from) whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    /**
     * @dev Suspend the issuance of new tokens.
     * Once set to false, '_isIssuable' can never be set to 'true' again.
     */
    function suspendIssuance() external onlyOwner {
        _isIssuable = false;
    }

    /**
     * @dev Resume the issuance of new tokens.
     * Once set to false, '_isIssuable' can never be set to 'true' again.
     */
    function resumeIssuance() external onlyOwner {
        _isIssuable = true;
    }

    /**
     * @return bool return 'true' if tokens can still be issued by the issuer, 
     * 'false' if they can't anymore.
     */
    function isIssuable() public view returns (bool success) {
        return _isIssuable;
    }

    /**
     * @dev Freeze an user
     * @param account The address of the user who will be frozen
     * @return The result of freezing an user
     */
    function freezeAccount(address account) public onlyOwner returns (bool) {
        require(!frozenAccount[account], "ERC20: account frozen");
        frozenAccount[account] = true;
        emit Freeze(account);
        return true;
    }

    /**
     * @dev Unfreeze an user
     * @param account The address of the user who will be unfrozen
     * @return The result of unfreezing an user
     */
    function unfreezeAccount(address account) public onlyOwner returns (bool) {
        require(frozenAccount[account], "ERC20: account not frozen");
        frozenAccount[account] = false;
        emit Unfreeze(account);
        return true;
    }

    /**
     * @dev Setup the contract address that can mint tokens
     * @param minter The address of the smart contract
     * @return The result of the setup
     */
    function addMinter(address minter) public onlyOwner returns (bool success) {
        minters[minter] = true;
        return true;
    }

    function removeMinter(address minter) public onlyOwner returns (bool success) {
        minters[minter] = false;
        return true;
    }

    /**
     * @dev Suspend the issuance of new tokens.
     * Once set to false, '_isIssuable' can never be set to 'true' again.
     */
    function setMinWithdrawAmount(uint amount) public onlyOwner returns (bool success) {
        require(amount > 0, "ERC20: amount invalid");
        _min_withdraw_amount = amount;
        return true;
    }

    /**
     * @dev Resume the issuance of new tokens.
     * Once set to false, '_isIssuable' can never be set to 'true' again.
     */
    function getMinWithdrawAmount() public view returns (uint amount) {
        return _min_withdraw_amount;
    }

    /**
     * @dev Returns the amount of tokens redeemed to `_owner`.
     * @param _owner The address from which the amount will be retrieved
     * @return The amount
     */
    function amountRedeemOf(address _owner) public view returns (uint amount) {
        return _amountRedeem[_owner];
    }

    /**
     * @dev Returns the amount of tokens withdrawn by `_owner`.
     * @param _owner The address from which the amount will be retrieved
     * @return The amount
     */
    function amountWithdrawOf(address _owner) public view returns (uint amount) {
        return _amountMinted[_owner];
    }

    /**
     * @dev Redeem user mintable tokens. Only the mining contract can redeem tokens.
     * @param to The user that will receive the redeemed token.     
     * @param amount The amount of tokens to be withdrawn
     * @return The result of the redeem
     */
    function redeem(address to, uint amount) external returns (bool success) {
        require(_isIssuable == true, "ERC20: token not issuable");
        require(amount > 0, "ERC20: amount invalid");

        // The total amount of redeem tokens to the user.
        _amountRedeem[to].sub(amount, "ERC20: transfer amount exceeds redeem");

        // Mint new tokens and send the funds to the account `mintableAddress`
        // Users can withdraw funds.
        _amountMinted[to].add(amount);
        _mint(to, amount);
        return true;
    }

    /**
     * @dev Mint an amount of tokens and transfer to the user
     * @param to The address of the user who will receive the tokens
     * @param amount The amount of tokens
     * @return The result of token minting
     */
    function mint(address to, uint256 amount) public returns (bool success) {
        require(minters[msg.sender], "!minter");    
        _amountRedeem[to].add(amount);
        return true;
    }

    /**
     * @dev Burn an amount of tokens and transfer to the user
     * @param account The address of the user
     * @param amount The amount of tokens to burn
     * @return The result of token burning
     */
    function burn(address account, uint256 amount) public onlyOwner returns (bool success) {
        _burn(account, amount);
        return true;
    }    
}