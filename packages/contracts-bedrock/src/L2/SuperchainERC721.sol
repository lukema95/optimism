pragma solidity 0.8.25;

// Contracts
import { ERC721 } from "@solady-v0.0.245/tokens/ERC721.sol";

// Libraries
import { Predeploys } from "src/libraries/Predeploys.sol";
import { Unauthorized } from "src/libraries/errors/CommonErrors.sol";

// Interfaces
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { ISemver } from "interfaces/universal/ISemver.sol";
import { IL2ERC721CrossChain, IERC165 } from "interfaces/L2/IL2ERC721CrossChain.sol";

abstract contract SuperchainERC721 is ERC721, IL2ERC721CrossChain {
    /// @notice Mint NFT through a crosschain transfer.
    /// @param _to       Address to mint NFT to.
    /// @param _tokenId  ID of the NFT being minted.
    function crosschainMint(address _to, uint256 _tokenId) external {
        if (msg.sender != Predeploys.SUPERCHAIN_TOKEN_BRIDGE) revert Unauthorized();

        _mint(_to, _tokenId);

        emit CrosschainMint(_to, _tokenId, msg.sender);
    }

    /// @notice Burn NFT through a crosschain transfer.
    /// @param _from     Address to burn NFT from.
    /// @param _tokenId  ID of the NFT being burned.
    function crosschainBurn(address _from, uint256 _tokenId) external {
        if (msg.sender != Predeploys.SUPERCHAIN_TOKEN_BRIDGE) revert Unauthorized();

        _burn(_from, _tokenId);

        emit CrosschainBurn(_from, _tokenId, msg.sender);
    }

    //// @inheritdoc IERC165
    function supportsInterface(bytes4 _interfaceId) public view virtual returns (bool) {
        return _interfaceId == type(IERC165).interfaceId || _interfaceId == type(IERC721).interfaceId
            || _interfaceId == type(IL2ERC721CrossChain).interfaceId;
    }
}
