//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DecentralizedStableCoin} from "../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../src/DSCEngine.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployDSC is Script {
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function run() external returns (DecentralizedStableCoin, DSCEngine) {
        HelperConfig config = new HelperConfig();
        (
            address wETHUSDPriceFeed,
            address wBTCUSDPriceFeed,
            address wETH,
            address wBTC,
            uint256 deployerKey
        ) = config.activeNetworkConfig();

        tokenAddresses = [wETH, wBTC];
        priceFeedAddresses = [wETHUSDPriceFeed, wBTCUSDPriceFeed];

        vm.startBroadcast(deployerKey);
        DecentralizedStableCoin dsc = new DecentralizedStableCoin();
        DSCEngine engine = new DSCEngine(
            tokenAddresses,
            priceFeedAddresses,
            address(dsc)
        );
        dsc.transferOwnership(address(engine));
        vm.stopBroadcast();

        return (dsc, engine);
    }
}
