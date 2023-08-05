// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

/**
 * @title Roots
 * @author Jean Ayala (jeanayala.eth).
 * @custom:coauthor Diegofigs
 * @notice NFT, ERC1155, Pausable
 * @custom:version 1.0.0
 * @custom:address 18
 * @custom:default-precision 0
 * @custom:simple-description An NFT that supports creating multiple collections,
 * with ability for owner to pause NFT transfers.
 * @dev ERC1155 NFT, the basic standard multi-token, with the following features:
 *
 *  - Developers can pause or unpause NFT transfers.
 *  - Developers can adjust metadata.
 *  - Create multiple NFT collections with the same contract.
 *
 */

contract Roots is ERC1155, AccessControl, Pausable, ERC1155Supply {
    /// @dev Role identifier for developers.
    bytes32 public constant DEVELOPER_ROLE = keccak256("DEVELOPER_ROLE");

    /// @dev Mapping from token ID to its URI.
    mapping(uint256 => string) private _tokenURIs;
    
    /**
     * @param _uri NFT metadata URI
     */
    constructor(string memory _uri) ERC1155(_uri) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DEVELOPER_ROLE, msg.sender);
    }

    /**
     * @dev Allows an address with the developer role to set the URIs for multiple tokens.
     * @param ids An array of token IDs.
     * @param uris An array of URIs.
     */
    function setTokenURIs(uint256[] memory ids, string[] memory uris) external onlyRole(DEVELOPER_ROLE) {
        require(ids.length == uris.length, "IDs and URIs length must match");

        for (uint256 i = 0; i < ids.length; i++) {
            _tokenURIs[ids[i]] = uris[i];
        }
    }

    /**
     * @dev Returns the URI for a given token.
     * @param id The token ID.
     * @return The URI of the token.
     */
    function uri(uint256 id) public view override returns (string memory) {
        return _tokenURIs[id];
    }

    /**
     * @dev Updates the base URI that will be used to retrieve metadata.
     * @param newuri The base URI to be used.
     */
    function setURI(string memory newuri) external onlyRole(DEVELOPER_ROLE) {
        _setURI(newuri);
    }

    /**
     * @dev Pauses the contract, preventing any transfers. Only callable by the contract owner.
     */
    function pause() external onlyRole(DEVELOPER_ROLE) {
        _pause();
    }

    /**
     * @dev Unpauses the contract, allowing transfers to occur again. Only callable by the contract owner.
     */
    function unpause() external onlyRole(DEVELOPER_ROLE) {
        _unpause();
    }

    /**
     * @dev A method for the owner to mint a batch of new ERC1155 tokens.
     * @param to The account for new tokens to be sent to.
     * @param ids The ids of the different token types.
     * @param amounts The number of each token type to be minted.
     * @param data additional data that will be used within the receivers' onERC1155Received method
     */
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external payable whenNotPaused {
        _mintBatch(to, ids, amounts, data);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) whenNotPaused {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
