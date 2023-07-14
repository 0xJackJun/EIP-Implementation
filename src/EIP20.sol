// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

// implementation for https://eips.ethereum.org/EIPS/eip-20

abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                            STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;
    string public symbol;
    uint8 public immutable decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            ERROR
    //////////////////////////////////////////////////////////////*/

    error InsufficientBalance();
    error InsufficientAllowance();

    /*//////////////////////////////////////////////////////////////
                            EVENT
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        name = name_;
        symbol = symbol_;
        decimals = decimals_;
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 INTERFACE
    //////////////////////////////////////////////////////////////*/

    function transfer(address _to, uint256 _value) public virtual returns (bool success) {
        if (balanceOf[msg.sender] < _value) revert InsufficientBalance();
        unchecked {
            balanceOf[msg.sender] -= _value;
            balanceOf[_to] += _value;
        }
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public virtual returns (bool success) {
        allowance[msg.sender][_spender] += _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool success) {
        if (allowance[_from][_to] < _value) revert InsufficientAllowance();
        if (balanceOf[_from] < _value) revert InsufficientBalance();

        unchecked {
            allowance[_from][_to] -= _value;
            balanceOf[_from] -= _value;
            balanceOf[_to] += _value;
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _mint(address _to, uint256 _value) internal virtual {
        totalSupply += _value;
        unchecked {
            balanceOf[_to] += _value;
        }
        emit Transfer(address(0), _to, _value);
    }

    function _burn(address _from, uint256 _value) internal virtual {
        balanceOf[from] -= amount;
        unchecked {
            totalSupply -= amount;
        }
        emit Transfer(_from, address(0), _value);
    }
}
