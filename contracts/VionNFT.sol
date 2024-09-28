// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC721A} from "erc721a/contracts/ERC721A.sol";
import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/// @title VionNFT contract
/// @notice Implements the minting of vion nft
contract VionNFT is ERC721A, Ownable2Step {
    /// @notice The address of presale contract
    address public presale;

    /// @dev Emitted when presale contract is updated
    event PresaleContractUpdated(address oldAddress, address newAddress);

    /// @notice Thrown when updating variable with zero value or address
    error ZeroAddress();

    /// @notice Thrown when updating with the same value as previously stored
    error IdenticalValue();

    constructor(
        string memory name,
        string memory symbol,
        address owner
    ) ERC721A(name, symbol) Ownable(owner) {}

    /// @notice Mints nft of quantity `quantity` to the user only callable by presale contract
    /// @param to The wallet address to which nfts will be mitned to
    /// @param quantity The number of nfts that will be minted to `to`
    function mint(address to, uint256 quantity) external {
        if (msg.sender != address(presale)) {
            revert ZeroAddress();
        }

        _mint(to, quantity);
    }

    /// @notice Sets presale contract address
    /// @param presaleAddress The address of the presaleAddress contract
    function updatePresaleContract(address presaleAddress) external onlyOwner {
        address oldPresale = presale;

        if (oldPresale == presaleAddress) {
            revert IdenticalValue();
        }

        emit PresaleContractUpdated({
            oldAddress: oldPresale,
            newAddress: presaleAddress
        });
        presale = presaleAddress;
    }
}
