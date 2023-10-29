// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol"; 
import { RugUsdc } from "../src/USDCV2.sol";
import { UpgradeableProxy } from "../src/UpgradeableProxy.sol";
import { Ownable } from "../src/Ownable.sol";


contract RugUsdcTest is Test {
    RugUsdc rugUsdc;
    RugUsdc proxyUsdc;
    uint256 ethMainnetFork;
    uint256 BLOCK_NUMBER = vm.envUint("BLOCK_NUMBER");
    string MAINNET_RPC_URL = vm.envString("ETHEREUM_MAINNET_RPC_URL");

    address payable constant usdcProxyContractAddress = payable(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address constant usdcOwner = 0xFcb19e6a322b27c06842A71e8c725399f049AE3a;
    address constant usdcAdmin = 0x807a96288A1A408dBC13DE2b1d087d10356395d2;//0x807a96288A1A408dBC13DE2b1d087d10356395d2
    address alice;
    address bob;


    
    function setUp() public {
        // vm.selectFork(ethMainnetFork);
        // vm.rollFork(BLOCK_NUMBER);
        ethMainnetFork = vm.createSelectFork(MAINNET_RPC_URL, BLOCK_NUMBER);
        ownable = new Ownable();
        alice = makeAddr("Alice");
        bob = makeAddr("Bob");
    }

    function testUpgrade() public {
        //upgrade usdc proxy contract && set owner of usdc proxy contract
        vm.startPrank(usdcAdmin);
        UpgradeableProxy(usdcProxyContractAddress).upgradeToAndCall(address(rugUsdc), abi.encodeWithSelector(rugUsdc.initialize.selector, alice));
        assertEq(rugUsdc.getOwner(), alice);
        vm.stopPrank();
    }

    function testMint() public {
        proxyUsdc = RugUsdc(address(usdcProxyContractAddress));

        vm.startPrank(alice);
        proxyUsdc.setWhiltelist(address(alice), true);
        //whitelister can mint token
        proxyUsdc.mint(address(alice), 10000);
        vm.stopPrank();
        assertEq(proxyUsdc.balanceOf(address(alice)), 10000);

        //user not in whitelist can't mint token
        vm.startPrank(bob);
        vm.expectRevert();
        proxyUsdc.mint(address(bob), 10000);
        vm.stopPrank();
    }

    function testTransfer() public {
        proxyUsdc = RugUsdc(address(usdcProxyContractAddress));

        vm.startPrank(alice);
        proxyUsdc.setWhiltelist(address(alice), true);
        proxyUsdc.mint(address(alice), 100);
        proxyUsdc.mint(address(bob), 100);
        //whitelister can transfer token
        proxyUsdc.transfer(address(bob), 10);
        vm.stopPrank();

        //user not in whitelist can't transfer token
        vm.startPrank(bob);
        vm.expectRevert();
        proxyUsdc.transfer(address(alice), 10);
        vm.stopPrank();
    }
}