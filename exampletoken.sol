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

pragma solidity ^0.8.0;

interface IWokenFactory {
    function isTradingOpen(address token) external view returns (bool);
}

import "@openzeppelin/contracts@4.9.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.9.0/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts@4.9.0/access/Ownable.sol";

contract ExampleToken is ERC20, ERC20Permit, Ownable {
    address public wokenFactory;
    address public pairAddress;
    bool public timekeeperEnabled = false;

    event TimekeeperEnabled(bool enabled);

    modifier tradingMustBeOpen() {
        if (timekeeperEnabled) {
            require(
                IWokenFactory(wokenFactory).isTradingOpen(pairAddress),
                "WokenExchange : Trading / Transfer is Closed"
            );
        }
        _;
    }

    constructor() ERC20("Example Token", "ST") ERC20Permit("Example Token") {
        _mint(msg.sender, 1000000000 * 10**18);
        wokenFactory = 0x0Dee376e1DCB4DAE68837de8eE5aBE27e629Acd0;
    }

    function setWokenFactory(address _wokenFactory) external onlyOwner { //set or edit the Woken Factory Address
        wokenFactory = _wokenFactory;
    }

    function setPairAddress(address _pairAddress) external onlyOwner { //set or edit your pair Address
        pairAddress = _pairAddress;
    }

    function enableTimekeeper(bool _enabled) external onlyOwner { //Enable or disable the Woken Exchange Timekeeper of your ERC20 token to protect from tranfers while your trading status is closed
        require(
            wokenFactory != address(0) && pairAddress != address(0),
            "Missing wokenFactory or pairAddress"
        );
        require(
            timekeeperEnabled != _enabled,
            _enabled
                ? "Timekeeper already enabled."
                : "Timekeeper already disabled."
        );
        timekeeperEnabled = _enabled;
        emit TimekeeperEnabled(_enabled);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override tradingMustBeOpen {
        super._beforeTokenTransfer(from, to, amount);
    }
}
