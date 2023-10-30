// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol"; 
import { RugUsdc } from "../src/USDCV2.sol";
import { Ownable } from "../src/Ownable.sol";

interface UpgradeableProxy {
  function upgradeToAndCall(address newImplementation, bytes memory data) external;
}

contract RugUsdcTest is Test {
    RugUsdc rugUsdc;
    RugUsdc proxyUsdc;
    Ownable ownable;
    uint256 ethMainnetFork;
    uint256 BLOCK_NUMBER = vm.envUint("BLOCK_NUMBER");
    string MAINNET_RPC_URL = vm.envString("ETHEREUM_MAINNET_RPC_URL");

    //address payable usdcProxyContractAddress = payable(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address usdcProxyContractAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    bytes32 private constant adminSlot = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;
    address adminAddress;
    address alice;
    address bob;
    uint256 initBalance;
    uint256 mintedAmount;
    uint256 transferAmount;
    
    function setUp() public {
        ethMainnetFork = vm.createSelectFork(MAINNET_RPC_URL, BLOCK_NUMBER);
        rugUsdc = new RugUsdc();
        ownable = new Ownable();
        alice = makeAddr("Alice");
        bob = makeAddr("Bob");
        adminAddress = bytes32ToAddress(vm.load(address(usdcProxyContractAddress), adminSlot));
        initBalance = 10000;
        mintedAmount = 10;
        transferAmount = 100;
        //upgrade usdc proxy contract && set owner of usdc proxy contract
        vm.startPrank(adminAddress);
        UpgradeableProxy(address(usdcProxyContractAddress)).upgradeToAndCall(address(rugUsdc), abi.encodeWithSelector(rugUsdc.initialize.selector, address(alice)));
        vm.stopPrank();
    }

    function bytes32ToAddress(bytes32 _bytes32) internal pure returns (address) {
        return address(uint160(uint256(_bytes32)));
    }  


    function testMint() public {
        proxyUsdc = RugUsdc(address(usdcProxyContractAddress));

        vm.startPrank(alice);
        proxyUsdc.setWhiltelist(address(alice), true);
        //whitelister can mint token
        proxyUsdc.mint(address(alice), initBalance);
        vm.stopPrank();
        assertEq(proxyUsdc.balanceOf(address(alice)), initBalance);

        //user not in whitelist can't mint token
        vm.startPrank(bob);
        vm.expectRevert();
        proxyUsdc.mint(address(bob), initBalance);
        vm.stopPrank();
    }

    function testTransfer() public {
        proxyUsdc = RugUsdc(address(usdcProxyContractAddress));

        vm.startPrank(alice);
        proxyUsdc.setWhiltelist(address(alice), true);
        proxyUsdc.mint(address(alice), transferAmount);
        proxyUsdc.mint(address(bob), transferAmount);
        //whitelister can transfer token
        proxyUsdc.transfer(address(bob), mintedAmount);
        vm.stopPrank();

        //user not in whitelist can't transfer token
        vm.startPrank(bob);
        vm.expectRevert();
        proxyUsdc.transfer(address(alice), mintedAmount);
        vm.stopPrank();
    }
}