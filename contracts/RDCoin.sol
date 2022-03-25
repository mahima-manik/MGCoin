// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Stakeable {

    struct Stake {
        uint amount;            // total amount staked initially (>0)
        uint depositTime;       // initial stake time
        uint withdrawnAmount;   // withdrawn stake amount
        uint lastWithdrawTime;  // last withdraw time
        uint lastRewardTime;    // last reward time
    }

    event Staked(address account, uint amount);
    event Reward(address account, uint amount);
    event Withdraw(address account, uint amount);

    mapping (address => Stake) private stakes;
    uint constant ONE_WEEK = 604800000;
    uint constant ONE_MONTH = 2629800000;

    modifier sanityCheck (address account, uint amount) {
        require(amount > 0, "stake amount <= 0");
        require(account != address(0), "cannot be zero address");
        _;
    }

    function stake (address account, uint256 amount) internal sanityCheck(account, amount) { 
        uint currentTime = block.timestamp;
        Stake storage _stake = stakes[account];
        if (_stake.amount == 0) {
            _stake.depositTime = currentTime;
            _stake.lastWithdrawTime = currentTime;
            _stake.lastRewardTime = currentTime;
        }
        _stake.amount += amount;
    }
    
    function withdraw(address account, uint amount) internal sanityCheck(account, amount) {
        
        uint currentTime = block.timestamp;
        Stake storage _stake = stakes[account];
        
        // Check withdraw conditions
        require (_stake.amount > 0, "stake amount <= 0");
        uint withdrawLimit = (_stake.amount * 25) / 100;
        
        if (withdrawLimit <= amount) {
            revert ("withdraw limit exceeded");
        }
        
        if (_stake.amount - _stake.withdrawnAmount <= 0)   {
            revert ("amount not available to withdraw");
        }
        
        if (!timeDifference(_stake.lastWithdrawTime, currentTime, ONE_WEEK))   {
            revert ("cannot withdraw before one week");
        }

        _stake.withdrawnAmount += amount;
        _stake.lastWithdrawTime = currentTime;
        
        // TODO: Reset the _stake.amount to 0 when everything is withdrawn
        uint stakedAmount = _stake.amount - _stake.withdrawnAmount;

        // All staked token is withdrawn
        if (stakedAmount == 0)  {
            _stake.amount = 0;
            _stake.depositTime = 0;
            _stake.lastRewardTime = 0;
            _stake.lastWithdrawTime = 0;
            _stake.withdrawnAmount = 0;
            revert("no token staked");
        }
    }
    
    function reward(address account) internal returns (uint) {
        uint currentTime = block.timestamp;
        Stake storage _stake = stakes[account];
        
        // Check reward condition
        bool isEligible = timeDifference(_stake.lastWithdrawTime, currentTime, ONE_MONTH);
        require(isEligible, "cannot reward before one month");

        uint stakedAmount = _stake.amount - _stake.withdrawnAmount;

        // All staked token is withdrawn
        if (stakedAmount == 0)  {
            _stake.amount = 0;
            _stake.depositTime = 0;
            _stake.lastRewardTime = 0;
            _stake.lastWithdrawTime = 0;
            _stake.withdrawnAmount = 0;
            revert("no token staked");
        }

        uint rewardAmount = (stakedAmount * 10) / 100;
        
        _stake.lastRewardTime = currentTime;
        return rewardAmount;
    }

    function getStakes(address account) internal view returns (uint) {
        Stake storage _stake = stakes[account];
        if (_stake.amount == 0) return 0;
        return _stake.amount - _stake.withdrawnAmount;
    }

    function timeDifference(uint from, uint to, uint difference) private pure returns (bool) {
        return true;
    }

}


contract RDCoin is Context, IERC20, IERC20Metadata, Stakeable {
    string private _name= "RDCoin";
    string private _symbol="RDC";
    uint private total_token_supply = 1500000000;
    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor() {
        _mint(msg.sender, total_token_supply*10**18);
    }

   
    function name() public view virtual override returns (string memory) {
        return _name;
    }

   
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

   
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

   
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

   
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

   
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

   
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

  
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "transfer from the zero address");
        require(to != address(0), "transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

  
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

   
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

   
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

  
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

  
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function stake (uint amount) external {
        require(balanceOf(msg.sender) >= amount, "insufficient balance");
        stake(msg.sender, amount);
        _burn(msg.sender, amount);
        emit Staked(msg.sender, amount);
    }

    function withraw(uint amount) external {
        withdraw(msg.sender, amount);
        _mint(msg.sender, amount);
        emit Withdraw(msg.sender, amount);
    }

    function reward() external {
        uint256 rewardAmount = reward(msg.sender);
        _mint(msg.sender, rewardAmount);
        emit Reward(msg.sender, rewardAmount);
    }

    function getStakes() external view returns (uint _stake) {
        _stake = getStakes(msg.sender);
        return _stake;
    }
}