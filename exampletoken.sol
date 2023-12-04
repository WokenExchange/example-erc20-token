// ----------------------------------------------------------------------------
// ExampleToken ERC20
//
// example of simple erc20 token with transfers protected
// by the Woken Exchange Timekeeper when the trading status is closed
//
// Custom it with your own functions, supply, name, symbol, etc
//
// https://woken.exchange
//
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------


pragma solidity ^0.8.0;

interface IWokenFactory {
    function isTradingOpen(address token) external view returns (bool);
}

contract ExampleToken {
    string public name = "Example Token";
    string public symbol = "ET";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000000 * (10 ** uint256(decimals));
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public wokenFactory; // Address of the Woken Exchange Factory
    address public pairAddress; // Address of the Token pair on the Woken Factory
    address public owner;
    bool public timekeeperEnabled = false; // Status of your ERC20 Timekeeper

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event TimekeeperEnabled(bool enabled);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function.");
        _;
    }

    modifier tradingMustBeOpen() { //to check the trading status on the Woken Exchange
        if (timekeeperEnabled) {
            require(IWokenFactory(wokenFactory).isTradingOpen(pairAddress), "WokenExchange : Trading / Transfer is Closed");
        }
        _;
    }

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        wokenFactory = 0x0Dee376e1DCB4DAE68837de8eE5aBE27e629Acd0;
        owner = msg.sender;
    }

    function setWokenFactory(address _wokenFactory) external onlyOwner { //set the Woken Factory Address
        wokenFactory = _wokenFactory;
    }

    function setPairAddress(address _pairAddress) external onlyOwner { //set the address of your pair on the Woken Factory
        pairAddress = _pairAddress;
    }

    function enableTimekeeper(bool _enabled) external onlyOwner { //Enable or disable the Woken Exchange Timekeeper of your ERC20 token to protect from tranfers while your trading status is closed 
        timekeeperEnabled = _enabled;
        emit TimekeeperEnabled(_enabled);
    }

    function transfer(address _to, uint256 _value) external tradingMustBeOpen returns (bool) { // trading must be open on the Woken Exchange to allow transfers
        require(_to != address(0), "Invalid recipient address.");
        require(_value <= balanceOf[msg.sender], "Insufficient balance.");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external returns (bool) {
        require(_spender != address(0), "Invalid spender address.");

        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external tradingMustBeOpen returns (bool) { // trading must be open on the Woken Exchange to allow transfers
        require(_from != address(0), "Invalid sender address.");
        require(_to != address(0), "Invalid recipient address.");
        require(_value <= balanceOf[_from], "Insufficient balance.");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded.");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function transferOwnership(address newOwner) external onlyOwner { // Transfer Ownership to a new Owner
        require(newOwner != address(0), "Invalid new owner address.");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() external onlyOwner { // Renounce Ownership
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
}
