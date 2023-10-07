// SPDX-License-Identifier: MIT

// This is considered an Exogenous, Decentralized, Anchored (pegged), Crypto Collateralized low volitility coin

// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.19;

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title DSCEngine
 * @author Shruti Chaurasia
 * The system is designed to be as minimal as possible, and have the toekns maintain a 1 token == $1 peg.
 * This stablecoin has properties:
 * -Exogenous collateral
 * -Dollar pegged
 * -Algorithmically stable
 *
 * It is similar to DAI if DAI had no governance, no fees, and was nly backed by wETH and wBTC.
 *
 * Our DSC system should always be overcollateralized. At no point should the value of all collateral be less than or equal to all the value of DSC.
 *
 * @notice This contract is the core of the DSC System. It handles all the logic for minting and redeeming DSC, as well as depositing and withdrawing collateral.
 *
 * @notice This contract is very loosely based on the MakerDAO DSS (DAI) system.
 */

contract DSCEngine is ReentrancyGuard {
    ////////////////
    // Errors     //
    ///////////////
    error DSCEngine__AmountLessThanZero();
    error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    error DSCEngine__TokenNotAllowed();
    error DSCEngine__DepositCollateralFailed();

    /////////////////////////
    // State Variables     //
    ////////////////////////

    mapping(address token => address priceFeed) private s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amount))
        private s_collatetralDeposited;
    DecentralizedStableCoin private immutable i_dsc;

    /////////////////
    // Events     //
    ////////////////

    event DSCEngine__CollateralDeposited(
        address indexed user,
        address indexed token,
        uint256 indexed amount
    );

    ////////////////
    // Modifiers  //
    ///////////////

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) revert DSCEngine__AmountLessThanZero();
        _;
    }

    modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert DSCEngine__TokenNotAllowed();
        }
        _;
    }

    constructor(
        address[] memory tokenAddresses,
        address[] memory priceFeedAddresses,
        address dscAddress
    ) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
        }

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
        }

        i_dsc = DecentralizedStableCoin(dscAddress);
    }

    ////////////////////////
    // External Functions  //
    ////////////////////////

    function depositCollateralAndMintDSC() external {}

    /**
     *
     * @param tokenCollateralAddress The address of the token to deposit the collateral.
     * @param amountCollateral The amount of token to be collateralized.
     */
    function depositCollateral(
        address tokenCollateralAddress,
        uint256 amountCollateral
    )
        external
        moreThanZero(amountCollateral)
        isAllowedToken(tokenCollateralAddress)
        nonReentrant
    {
        s_collatetralDeposited[msg.sender][
            tokenCollateralAddress
        ] += amountCollateral;
        emit DSCEngine__CollateralDeposited(
            msg.sender,
            tokenCollateralAddress,
            amountCollateral
        );

        bool success = IERC20(tokenCollateralAddress).transferFrom(
            msg.sender,
            address(this),
            amountCollateral
        );

        if (!success) {
            revert DSCEngine__DepositCollateralFailed();
        }
    }

    function redeemCollateralForDSC() external {}

    function redeemCollateral() external {}

    function mintDSC() external {}

    function burnDSC() external {}

    function liquidate() external {}

    function getHealthFactore() external view {}
}
