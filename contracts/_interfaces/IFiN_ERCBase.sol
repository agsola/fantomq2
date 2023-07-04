/** ---------------------------------------------------------------------------- //
 *                                                                               //
 *                                       .:::.                                   //
 *                                    .:::::::.                                  //
 *                                    ::::::::.                                  //
 *                                 .:::::::::.                                   //
 *                             ..:::.              ..                            //
 *                          .::::.                 ::::..                        //
 *                      ..:::..                    ::::::::.                     //
 *                   .::::.                        :::.  ..:::.                  //
 *               ..:::..                           :::.      .:::.               //
 *            .::::.                               :::.         .:::..           //
 *         .:::..               ..                 :::.            .::::.        //
 *     .::::.               ..:::=-                ::::               ..:::.     //
 *    :::.               .:::::::===:              ::::::.               .::::   //
 *   .::.            .:::::::::::=====.            ::::::::::.             .::.  //
 *   .::         .:::::::::::::::=======.          :::::::::::::..          ::.  //
 *   .::        .::::::::::::::::========-         :::::::::::::::::        ::.  //
 *   .::        .::::::::::::::::==========:       :::::::::::::::::        ::.  //
 *   .::        .::::::::::::::::============:     :::::::::::::::::        ::.  //
 *   .::        .::::::::::::::::==============.   :::::::::::::::::        ::.  //
 *   .::        .::::::::::::::::===============-. :::::::::::::::::        ::.  //
 *   .::        .::::::::::::::::=================::::::::::::::::::        ::.  //
 *   .::        .::::::::::::::::==================-::::::::::::::::        ::.  //
 *   .::        .::::::::::::::::==================-::::::::::::::::        ::.  //
 *   .::        .::::::::::::::::==================-::::::::::::::::        ::.  //
 *   .::        .:::::::::::::::::=================-::::::::::::::::        ::.  //
 *   .::        .:::::::::::::::: .-===============-::::::::::::::::        ::.  //
 *   .::        .::::::::::::::::   .==============-::::::::::::::::        ::.  //
 *   .::        .::::::::::::::::     :============-::::::::::::::::        ::.  //
 *   .::        .::::::::::::::::       :==========-::::::::::::::::        ::.  //
 *   .::        .::::::::::::::::        .-========-::::::::::::::::        ::.  //
 *   .::          .::::::::::::::          .=======-::::::::::::::.         ::.  //
 *   .::.             .::::::::::            .=====-::::::::::..            ::.  //
 *    :::..              ..::::::              :===-::::::..              .:::.  //
 *      .:::..               .:::                -=-:::.               .::::.    //
 *         .::::.            .:::                 ..                .::::.       //
 *            .::::.         .:::                               ..:::.           //
 *                .:::.      .:::                            .::::.              //
 *                   .:::..  .:::                        ..:::..                 //
 *                      .::::.:::                     .::::.                     //
 *                         ..::::                 ..:::..                        //
 *                             .:              .::::.                            //
 *                                     :::::.::::.                               //
 *                                    ::::::::.                                  //
 *                                    :::::::.                                   //
 *                                     .::::.                                    //
 *                                                                               //
 *                                                                               //
 *   Smart contract generated at https://721fi.xyz (by https://nfts2me.com)      //
 *                                                                               //
 *   NFTs2Me. Make an NFT Collection.                                            //
 *   With ZERO Coding Skills.                                                    //
 *                                                                               //
 *   NFTs2Me is not associated or affiliated with this project.                  //
 *   NFTs2Me is not liable for any bugs or issues associated with this contract. //
 *   NFTs2Me Terms of Service: https://nfts2me.com/terms-of-service/             //
 * ----------------------------------------------------------------------------- */

/// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import "./IFiN_ERCStorage.sol";

interface IFiN_ERCBase is IERC2981Upgradeable, IFiN_ERCStorage {
    /// @notice To be called to create the collection. Can only be called once.
    function initialize
    (
        string memory tokenName,
        string memory tokenSymbol,
        uint256 iMintPrice,
        bytes32 baseURICIDHash,
        bytes32 placeholderImageCIDHash,

        address iErc20PaymentAddress,
        uint32[] calldata integers,

        bool soulboundCollection,
        MintingType iMintingType
    ) external payable;

    /// @notice A descriptive name for a collection of NFTs in this contract
    function name() external view returns (string memory);

    /// @notice An abbreviated name for NFTs in this contract
    /// @return the collection symbol
    function symbol() external view returns (string memory);

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    ///  Metadata JSON Schema".
    function tokenURI(uint256 tokenId) external view returns (string memory);

    /// @notice Mints one NFT to the caller (msg.sender). Requires `minting type` to be `sequential` and the `mintPrice` to be send (if `Native payment`) or approved (if `ERC-20` payment).
    function mint(uint256 price) external payable;

    /// @notice Mints `amount` NFTs to the caller (msg.sender). Requires `minting type` to be `sequential` and the `mintPrice` to be send (if `Native payment`) or approved (if `ERC-20` payment).
    /// @param amount The number of NFTs to mint
    function mint(uint256 amount, uint256 price) external payable;

    /// @notice Mints `amount` NFTs to `to` address. Requires `minting type` to be `sequential` and the `mintPrice` to be send (if `Native payment`) or approved (if `ERC-20` payment).
    /// @param to The address of the NFTs receiver
    /// @param amount The number of NFTs to mint    
    function mintTo(address to, uint256 amount, uint256 price) external payable;

    /// @notice Two phases on-chain random minting. Mints `amount` NFTs tickets to `to` address. Requires `minting type` to be `random` and the `mintPrice` to be send (if `Native payment`) or approved (if `ERC-20` payment). Once minted, those tickets must be redeemed for an actual token calling `redeemRandom()`.
    /// @param to The address of the NFTs receiver
    /// @param amount The number of NFTs to mint    
    function mintRandomTo(address to, uint256 amount, uint256 price) external payable;    

    /// @notice Redeems remaining random tickets generated from `msg.sender` by calling `mintRandomTo` for actual NFTs.
    function redeemRandom() external payable;

    /// @notice Mints `amount` NFTs to `to` address. Requires `minting type` to be `specify` and the `mintPrice` to be send (if `Native payment`) or approved (if `ERC-20` payment).
    /// @param to The address of the NFTs receiver
    /// @param tokenIds An array of the specified tokens. They must not be minted, otherwise, it will revert.
    function mintSpecifyTo(address to, uint256[] memory tokenIds, uint256 price) external payable; 

    /// @notice Returns the minting price of one NFT.
    /// @return Mint price for one NFT in native coin or ERC-20.
    function mintPrice() external view returns (uint256);

    /// @notice Returns the current total supply.
    /// @return Current total supply.
    function totalSupply() external view returns (uint256);

    /// @notice Max amount of NFTs to be hold per address.
    /// @return Max per address allowed.
    function maxPerAddress() external view returns (uint16);

    /// @notice The amount of staked EVMOS that can be withdrawn when burning the NFT.
    function getBurnableAmount(uint256 tokenId) external view returns (uint256 amountToWithdraw);

    /// @notice Returns the total amount staked plus the rewards all together.
    function getTotalAmountWithRewards() external view returns (uint256 amount);

    /// @notice Returns the total amount staked by the contract. Not including rewards.
    function getContractStaked() external view returns (uint256 amount);

    /// @notice The amount of EVMOS that can be withdrawn by a given address, and if it is totally unbonded.
    function totalPendingToWithdraw(address owner) external view returns (uint256 pendingToWithdraw, bool totallyUnbonded);    

    /// @notice Burns the NFT and receives the staked EVMOS in return. To get the EVMOS, the rewards must be withdrawn after the unbonding period.
    function burnToWithdraw(uint256 tokenId) external;

    /// @notice Returns true if the NFT exists.
    function exists(uint256 tokenId) external returns (bool);

    // /// @notice Changes the current validator address to a new one.

    // /// @notice Reinvest the current pending rewards, withdrawing them from the validator and staking them again.

    /// @notice Withdraws the current pending rewards for msg.sender.
    function withdrawPending() external;

    /// @notice The maximum amount of EVMOS that can be unstaked for a given tokenId.
    function unstakeableAmount(uint256 tokenId) external view returns (uint256 amount);

    /// @notice Increases the staked amount for a given tokenId.
    function increaseStaking(uint256 tokenId, uint256 amountToIncrease) payable external;

    /// @notice Decreases the staked amount for a given tokenId. 'amountToDecrease' must be less than or equal to 'unstakeableAmount'.
    function decreaseStaking(uint256 tokenId, uint256 amountToDecrease) external;

}

