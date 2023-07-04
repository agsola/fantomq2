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

import "../_important/README.sol";

interface IFiN_ERCStorage is Readme {
    event Withdraw(address indexed to, uint256 value);

    /// @notice This event is emitted when a token is minted using an affiliate
    /// @param affiliate The affiliate address
    event AffiliateSell(address indexed affiliate);

    /// @notice Error thrown when trying to mint a token with a given id which is already minted
    error TokenAlreadyMinted();

    /// @notice Error thrown when input variable differ in length
    error InvalidInputSizesDontMatch();

    /// @notice Error thrown when input variable differ in length
    error InputSizeMismatch();

    /// @notice Error thrown when trying to mint a token with a given invalid id
    error InvalidTokenId();

    /// @notice Error thrown when trying to redeem random tickets with no amount to redeem
    error NothingToRedeem();

    /// @notice Error thrown when trying to redeem random tickets too soon
    error CantRevealYetWaitABitToBeAbleToRedeem();

    /// @notice Error thrown when the input amount is not valid
    error InvalidAmount();

    /// @notice Error thrown when trying to mint a sold out collection or the amount to mint exceeds the remaining supply
    error CollectionSoldOut();

    /// @notice Error thrown when trying to presale/whitelist mint and the collection current phase is `closed`
    error PresaleNotOpen();

    /// @notice Error thrown when trying to mint and the collection current phase is not `open`
    error PublicSaleNotOpen();

    /// @notice Error thrown when trying to mint but the sale has already finished
    error SaleFinished();

    /// @notice Error thrown when trying to mint more than the allowance to mint
    error NotEnoughAmountToMint();

    /// @notice Error thrown when sending funds to a free minting
    error InvalidMintFeeForFreeMinting();

    /// @notice Error thrown when the sent amount is not valid
    error InvalidMintFee();

    /// @notice Royalty fee can't be higher than 10%
    error RoyaltyFeeTooHigh();

    /// @notice Invalid input. Total supply must be greater than zero
    error TotalSupplyMustBeGreaterThanZero();

    /// @notice Withdraw penalty time can't be higher than 365 days
    error WithdrawPenaltyTimeTooHigh();

    /// @notice ERC20 Payment Token can't be the zero address
    error InvalidPaymentAddress();

    /// @notice Withdraw penalty percentage can't be higher than 10%
    error WithdrawPenaltyPercentageTooHigh();

    /// @notice Mint price can't be zero
    error MintPriceMustBeGreaterThanZero();

    /// @notice Can't set BaseURI and Placeholder at the same time
    error CantSetBaseURIAndPlaceholderAtTheSameTime();

    /// @notice No BaseURI nor Placeholder set
    error NoBaseURINorPlaceholderSet();

    /// @notice Can't transfer a Soulbound Token (SBT)
    error NonTransferrableSoulboundNFT();

    /// @notice The input revenue percentages are not valid
    error InvalidRevenuePercentage();

    /// @notice Can't mint until specified drop date
    error WaitUntilDropDate();

    /// @notice Trying to use mintPresale method in a collection with a minting type that doesn't support whitelist
    error PresaleInvalidMintingType();

    /// @notice Metadata is already fixed. Can't change metadata once fixed
    error MetadataAlreadyFixed();

    /// @notice Invalid collection minting type for the current minting function
    error InvalidMintingType();

    /// @notice The address exceeded the max per address amount
    error MaxPerAddressExceeded();

    /// @notice The given signature doesn't match the input values
    error SignatureMismatch();

    /// @notice Reentrancy Guard protection
    error ReentrancyGuard();

    /// @notice New Placeholder can't be empty
    error NewPlaceholderCantBeEmpty();

    /// @notice New BaseURI can't be empty
    error NewBaseURICantBeEmpty();    

    /// @notice Invalid percentage or discount values
    error InvalidPercentageOrDiscountValues();

    /// @notice Can't lower current percentages
    error CantLowerCurrentPercentages();

    /// @notice Contract MetadataURI already fixed
    error ContractMetadataURIAlreadyFixed();

    /// @notice Only the given affiliate or FiN can call this function
    error OnlyAffiliateOrFiN();

    /// @notice The signature has expired
    error SignatureExpired();

    /// @notice Invalid phase can't be set without giving a date, use the proper functions
    error InvalidPhaseWithoutDate();

    /// @notice Invalid drop date
    error InvalidDropDate();

    /// @notice Operator address is filtered
    error AddressFiltered(address filtered);

    struct RandomTicket {
        uint256 amount;
        uint256 blockNumberToReveal;
        uint256 pricePerToken;
    }

    struct RevenueAddress {
        address to;
        uint16 percentage;
    }

    struct AffiliateInformation {
        bool enabled;
        uint16 affiliatePercentage;
        uint16 userDiscount;
    }

    enum SalePhase { 
        CLOSED,
        PRESALE,
        PUBLIC,
        DROP_DATE,
        DROP_AND_END_DATE
    }

    enum MintingType { 
        SEQUENTIAL, 
        RANDOM, 
        SPECIFY, 
        CUSTOM_URI 
    }

    /// @notice Returns true if the metadata is fixed and immutable. If the metadata hasn't been fixed yet it will return false. Once fixed, it can't be changed by anyone.
    function isMetadataFixed() external view returns (bool);

    /// @notice Returns the amount of time in seconds that the withdraw penalty will be applied. It will linearly decrease as the time passes.
    function withdrawPenaltyTime() external view returns (uint32);

    /// @notice Returns the percentage of the withdraw penalty. It will linearly decrease as the time passes until it passes withdrawPenaltyTime
    function withdrawPenaltyPercentage() external view returns (uint16);

    /// @notice Returns the amount of tokens burned so far
    function burnedTokens() external view returns (uint32);

    /// @notice Returns the amount of EVMOS originally staked
    function totalStakedRaw() external view returns (uint);

    /// @notice Returns the amount of EVMOS that was used to mint the tokenId
    function stakedRaw(uint256 tokenId) external view returns (uint256 amountPaidForToken);

    /// @notice Returns the total amount of stakes. When a user enters into the collection, it gets assigned a number of stakes which are relative to their participation.
    function totalAmountOfStakes() external view returns (uint);

    /// @notice Returns the amount of stakes from a given tokenId
    function amountOfStakes(uint256 tokenId) external view returns (uint256 amountOfStakes);

    // /// @notice Returns the current validaor address.

    /// @notice Returns the minting date of a given tokenId
    function mintingDate(uint256 tokenId) external view returns (uint256 mintingDate);

    /// @notice Returns the amount to withdraw from a given account not taking into account the amount coming from bounding contracts
    function rawPendingToWithdraw(address account) external view returns (uint256 pendingToWithdraw);

}

