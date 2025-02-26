pragma solidity ^0.8.0;

import { IERC165 } from "@openzeppelin/contracts/interfaces/IERC165.sol";

interface IL2ERC721CrossChain is IERC165 {
    /// @notice Emitted when a crosschain transfer mints tokens.
    /// @param to       Address of the account tokens are being minted for.
    /// @param tokenId   ID of the token being minted.
    /// @param sender   Address of the account that finilized the crosschain transfer.
    event CrosschainMint(address indexed to, uint256 tokenId, address indexed sender);

    /// @notice Emitted when a crosschain transfer burns tokens.
    /// @param from     Address of the account tokens are being burned from.
    /// @param tokenId   ID of the token being burned.
    /// @param sender   Address of the account that initiated the crosschain transfer.
    event CrosschainBurn(address indexed from, uint256 tokenId, address indexed sender);

    /// @notice Mint tokens through a crosschain transfer.
    /// @param _to       Address to mint tokens to.
    /// @param _tokenId  ID of the token being minted.
    function crosschainMint(address _to, uint256 _tokenId) external;

    /// @notice Burn tokens through a crosschain transfer.
    /// @param _from     Address to burn tokens from.
    /// @param _tokenId  ID of the token being burned.
    function crosschainBurn(address _from, uint256 _tokenId) external;
}
