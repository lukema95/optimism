pragma solidity 0.8.25;

// Libraries
import { Predeploys } from "src/libraries/Predeploys.sol";
import { ZeroAddress, Unauthorized } from "src/libraries/errors/CommonErrors.sol";

// Interfaces
import { ISuperchainERC721 } from "interfaces/L2/ISuperchainERC721.sol";
import { IL2ERC721CrossChain, IERC165 } from "interfaces/L2/IL2ERC721CrossChain.sol";
import { IL2ToL2CrossDomainMessenger } from "interfaces/L2/IL2ToL2CrossDomainMessenger.sol";

contract SuperchainERC721Bridge {

    error InvalidCrossDomainSender();
    error InvalidERC721();

    /// @notice Emitted when an ERC721 is sent from one chain to another.
    /// @param token       Address of the token being sent.
    /// @param from        Address of the sender.
    /// @param to          Address of the recipient.
    /// @param tokenId     ID of the token being sent.
    /// @param destination Chain ID of the destination chain.
    event SendERC721(address indexed token, address indexed from, address indexed to, uint256 tokenId, uint256 destination);

    /// @notice Emitted when an ERC721 is successfully relayed on this chain.
    /// @param token       Address of the token being relayed.
    /// @param from        Address of the msg.sender of sendERC721 on the source chain.
    /// @param to          Address of the recipient.
    /// @param tokenId     ID of the token being relayed.
    /// @param source      Chain ID of the source chain.
    event RelayERC721(address indexed token, address indexed from, address indexed to, uint256 tokenId, uint256 source);

    /// @notice Address of the L2ToL2CrossDomainMessenger Predeploy.
    address internal constant MESSENGER = Predeploys.L2_TO_L2_CROSS_DOMAIN_MESSENGER;

    /// @notice Sends an ERC721 to a destination chain.
    /// @param _token       Address of the token being sent.
    /// @param _to          Address of the recipient.
    /// @param _tokenId     ID of the token being sent.
    /// @param _chainId     Chain ID of the destination chain.
    /// @return msgHash_    Hash of the sent message.
    function sendERC721(address _token, address _to, uint256 _tokenId, uint256 _chainId) external returns (bytes32 msgHash_) {
        if (_to == address(0)) revert ZeroAddress();

        if (!IERC165(_token).supportsInterface(type(IL2ERC721CrossChain).interfaceId)) revert InvalidERC721();

        ISuperchainERC721(_token).crosschainBurn(msg.sender, _tokenId);

        bytes memory message = abi.encodeCall(this.relayERC721, (_token, msg.sender, _to, _tokenId));
        msgHash_ = IL2ToL2CrossDomainMessenger(MESSENGER).sendMessage(_chainId, address(this), message);

        emit SendERC721(_token, msg.sender, _to, _tokenId, _chainId);
    }

    /// @notice Relays an ERC721 received from another chain.
    /// @param _token       Address of the token being relayed.
    /// @param _from        Address of the msg.sender of sendERC721 on the source chain.
    /// @param _to          Address of the recipient.
    /// @param _tokenId     ID of the token being relayed.
    function relayERC721(address _token, address _from, address _to, uint256 _tokenId) external {
        if (msg.sender != MESSENGER) revert Unauthorized();

        (address crossDomainMessageSender, uint256 source) =
            _decodeSentMessagePayload(_sentMessage);

        if (crossDomainMessageSender != address(this)) revert InvalidCrossDomainSender();

        ISuperchainERC721(_token).crosschainMint(_to, _tokenId);

        emit RelayERC721(_token, _from, _to, _tokenId, source);
    }

}
