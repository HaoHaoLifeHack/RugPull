// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import {Ownable} from "./Ownable.sol";

// Copy all storageVariables from usdc logic contract, and keep the variables' sequence
contract UsdcStorageVariable {
    string public name;
    string public symbol;
    uint8 public decimals;
    string public currency;
    address public masterMinter;
    bool internal initialized;

    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;
    uint256 internal totalSupply_ = 0;
    mapping(address => bool) internal minters;
    mapping(address => uint256) internal minterAllowed;
}

contract RugUsdc is UsdcStorageVariable, Ownable {
    bool internal initializeRugUsdc;
    
    mapping(address => bool) public whitelist;

    modifier inWhitelist(address _address) {
        require(whitelist[_address], "You are not allowed to do the action!");
        _;
    }

    function initialize(address _ownerAddress) external {
        if (initializeRugUsdc) return;

        initializeOwnable(_ownerAddress);
        initializeRugUsdc = true;
    }
        
    function setWhiltelist(address _address, bool _bool) onlyOwner external{
        whitelist[_address] = _bool;
    }

    function transfer(address _to, uint256 _amount) public inWhitelist(msg.sender) returns (bool){
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        return true;
    }

    function mint(address _to, uint256 _amount) external inWhitelist(msg.sender) returns (bool){
        require(_to != address(0), "Mint to invalid recipient address");
        require(_amount > 0, "Mint amount is lower than 0");

        totalSupply_ = totalSupply_ + _amount;
        balances[_to] = balances[_to] + _amount;

        return true;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return balances[account];
    }
}

