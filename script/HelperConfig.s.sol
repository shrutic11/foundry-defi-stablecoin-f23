// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "test/mocks/MockV3Aggregator.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address wETHUSDPriceFeed;
        address wBTCUSDPriceFeed;
        address wETH;
        address wBTC;
        uint256 deployerKey;
    }
    uint8 public constant DECIMALS = 8;
    int256 public constant ETH_USD_PRICE = 2000e8;
    int256 public constant BTC_USD_PRICE = 1000e8;
    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111)
            activeNetworkConfig = getSepoliaEthConfig();
        else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig()
        public
        view
        returns (NetworkConfig memory sepoliaNetworkConfig)
    {
        sepoliaNetworkConfig = NetworkConfig({
            wETHUSDPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306, // ETH / USD
            wBTCUSDPriceFeed: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43,
            wETH: 0xdd13E55209Fd76AfE204dBda4007C227904f0a81,
            wBTC: 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063,
            deployerKey: vm.envUint("SEPOLIA_PRIVATE_KEY")
        });
    }

    function getOrCreateAnvilEthConfig()
        public
        returns (NetworkConfig memory anvilNetworkConfig)
    {
        if (activeNetworkConfig.wETHUSDPriceFeed != address(0))
            return activeNetworkConfig;

        vm.startBroadcast();
        MockV3Aggregator ethUSDPriceFeed = new MockV3Aggregator(
            DECIMALS,
            ETH_USD_PRICE
        );

        ERC20Mock wETHMock = new ERC20Mock("WETH", "WETH", msg.sender, 1000e8);

        MockV3Aggregator btcUSDPriceFeed = new MockV3Aggregator(
            DECIMALS,
            BTC_USD_PRICE
        );

        ERC20Mock wBTCMock = new ERC20Mock("WBTC", "WBTC", msg.sender, 1000e8);
        vm.stopBroadcast();

        return
            NetworkConfig({
                wETHUSDPriceFeed: address(ethUSDPriceFeed), // ETH / USD
                wBTCUSDPriceFeed: address(btcUSDPriceFeed),
                wETH: address(wETHMock),
                wBTC: address(wBTCMock),
                deployerKey: vm.envUint("DEFAULT_ANVIL_PRIVATE_KEY")
            });
    }
}
