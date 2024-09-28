// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

interface IVionNFT {
    function totalSupply() external view returns (uint256);

    function mint(address to, uint256 quantity) external;
}

/// @title VionNFTPresale contract
/// @notice Implements the presale of vion nft
contract VionNFTPresale is Ownable2Step {
    using SafeERC20 for IERC20;
    using Address for address payable;

    /// @notice The nft price in dollars
    uint256 public constant NFT_PRICE = 375_000_000;

    /// @notice The maximum number of nfts
    uint256 public constant TOTAL_NFTS = 1_000;

    /// @notice The power of ten that is used to met required decimal value
    uint256 public constant NORMALIZATION_FACTOR = 20;

    /// @notice The address of fundsWallet
    address public fundsWallet;

    /// @notice The address of the usdt
    IERC20 public immutable USDT;

    /// @notice The address of the vion nft
    IVionNFT public vioNFT;

    /// @notice The address of the pricefeed contract
    AggregatorV3Interface public priceFeed;

    /// @dev Emitted when nft is purchased with usdt
    event PurchasedNFTWithUSDT(address indexed by, uint256 quantity);

    /// @dev Emitted when nft is purchased with ETH
    event PurchasedNFTWithETH(address indexed by, uint256 quantity);

    /// @dev Emitted when address of funds wallet is updated
    event FundsWalletUpdated(address oldAddress, address newAddress);

    /// @dev Emitted when address of priceFeed contract is updated
    event PriceFeedUpdated(
        AggregatorV3Interface oldAddress,
        AggregatorV3Interface newAddress
    );

    /// @notice Thrown when max nfts max mint limit is reached
    error MaxNftsMinted(uint256 nftsLeft);

    /// @notice Thrown when updating variable with zero value or address
    error ZeroAddress();

    /// @notice Thrown when amount to purchase is less than the nft prices
    error IncorrectInvestmentAmount();

    /// @notice Thrown if the pricefeed contract is zero address while getting live price
    error PriceFeedNotSet();

    /// @notice Thrown when updating with the same value as previously stored
    error IdenticalValue();

    constructor(
        IERC20 usdt,
        IVionNFT vioNFTAddress,
        AggregatorV3Interface priceFeedAddress,
        address fundsWalletAddress,
        address owner
    ) Ownable(owner) {
        if (
            address(usdt) == address(0) ||
            address(priceFeedAddress) == address(0) ||
            address(vioNFTAddress) == address(0) ||
            fundsWalletAddress == address(0)
        ) {
            revert ZeroAddress();
        }

        USDT = usdt;
        vioNFT = vioNFTAddress;
        fundsWallet = fundsWalletAddress;
        priceFeed = priceFeedAddress;
    }

    /// @notice Purchases NFT with ETH
    /// @param quantity The number of the nfts you want to purchase
    function purchaseNFWithETH(uint256 quantity) external payable {
        if (quantity + vioNFT.totalSupply() >= TOTAL_NFTS) {
            revert MaxNftsMinted(TOTAL_NFTS - quantity);
        }

        uint256 priceInEth = (NFT_PRICE * (10 ** NORMALIZATION_FACTOR)) /
            getLatestPrice();

        if (msg.value < quantity * priceInEth) {
            revert IncorrectInvestmentAmount();
        }

        payable(fundsWallet).sendValue(priceInEth);
        vioNFT.mint(msg.sender, quantity);
        emit PurchasedNFTWithETH({by: msg.sender, quantity: quantity});
    }

    /// @notice Purchases NFT with USDT
    /// @param quantity The number of the nfts you want to purchase
    function purchaseNFTWithUSDT(uint256 quantity) external {
        if (quantity + vioNFT.totalSupply() >= TOTAL_NFTS) {
            revert MaxNftsMinted(TOTAL_NFTS - quantity);
        }

        USDT.safeTransferFrom(msg.sender, fundsWallet, (quantity * NFT_PRICE));
        vioNFT.mint(msg.sender, quantity);
        emit PurchasedNFTWithUSDT({by: msg.sender, quantity: quantity});
    }

    /// @notice Changes funds wallet to a new address
    /// @param newFundsWallet The address of the new funds wallet
    function changeFundsWallet(address newFundsWallet) external onlyOwner {
        address oldWallet = fundsWallet;
        if (newFundsWallet == address(0)) {
            revert ZeroAddress();
        }

        if (oldWallet == newFundsWallet) {
            revert IdenticalValue();
        }
        emit FundsWalletUpdated({
            oldAddress: oldWallet,
            newAddress: newFundsWallet
        });
        fundsWallet = newFundsWallet;
    }

    /// @notice Changes pricefeed contract address
    /// @param priceFeedAddress The address of the new priceFeed contract
    function updatePriceFeed(
        AggregatorV3Interface priceFeedAddress
    ) external onlyOwner {
        AggregatorV3Interface oldPriceFeed = priceFeed;

        if (address(priceFeedAddress) == address(0)) {
            revert ZeroAddress();
        }

        if (oldPriceFeed == priceFeedAddress) {
            revert IdenticalValue();
        }

        emit PriceFeedUpdated({
            oldAddress: oldPriceFeed,
            newAddress: priceFeedAddress
        });
        priceFeed = priceFeedAddress;
    }

    /// @notice Function provides live ETH/USD price
    function getLatestPrice() public view returns (uint256) {
        if (address(priceFeed) == address(0)) {
            revert PriceFeedNotSet();
        }
        (
            ,
            /*uint80 roundID*/
            int256 price /*uint256 startedAt*/ /*uint80 answeredInRound*/ /*uint256 timeStamp*/,
            ,
            ,

        ) = priceFeed.latestRoundData();

        return uint256(price);
    }
}
