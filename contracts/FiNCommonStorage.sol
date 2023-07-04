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

import "./_interfaces/IFiN_ERCStorage.sol";
import "./_interfaces/IFiNCrossFactory.sol";
import "./_ownable/NFTOwnableUpgradeable.sol";
import "./FiNVersion.sol";

string constant DEFAULT_VALIDATOR_ADDRESS = "evmosvaloper1s95dwnw7vuks688tnzuue0hl6gsczmzjlf759z";

/// @title NFTs2Me.com Smart Contracts
/// @author The NFTs2Me Team
/// @notice Read our terms of service
/// @custom:security-contact security@nfts2me.com
/// @custom:terms-of-service https://nfts2me.com/terms-of-service/
/// @custom:website https://nfts2me.com/
abstract contract FiNCommonStorage is
    NFTOwnableUpgradeable,
    IFiN_ERCStorage,
    FiNVersion
{
    /// IMMUTABLE    
    address payable internal immutable _factory;

    bytes32 internal _baseURICIDHash;
    bytes32 internal _placeholderImageCIDHash;
    bytes32 internal _contractURIMetadataCIDHash;

    uint256 internal _mintPrice;

    uint256 internal _reentrancyEntered;
    uint256 internal _dropDateTimestamp;
    uint256 internal _endDateTimestamp; 

    /// @dev A struct that keeps track of the unbonding delegations.
    struct UnbondingRequest {
        int64 completionTime;
        uint256 amount;
    }

    mapping(uint256 => uint256) public mintingDate;
    uint256 public totalAmountOfStakes;
    uint256 public totalStakedRaw;
    mapping(uint256 => uint256) public amountOfStakes;
    mapping(uint256 => uint256) public minimumMintFeeWhenMinting;
    mapping(uint256 => uint256) public stakedRaw;

    mapping(address => uint256) public rawPendingToWithdraw;
    mapping(address => uint256) public totalWithdrawn;

    address internal _erc20PaymentAddress;

    mapping(address => RandomTicket) internal _randomTickets;
    mapping(bytes => uint256) internal _usedAmountSignature;
    mapping(uint256 => bool) internal _soulbound;
    mapping(uint256 => bytes32) internal _customURICIDHashes;

    string[] internal stakingMethods;
    string[] internal distributionMethods;

    uint32 internal _soldTokens;
    SalePhase internal _currentPhase;

    MintingType internal _mintingType;                                                              
    uint16 internal _royaltyFee;
    uint16 internal _mintRoyaltyFee;
    uint16 internal _rewardsRoyaltyFee;
    uint16 internal _maxPerAddress;                                                                 
    uint32 internal _collectionSize;

    bool internal _soulboundCollection;
    uint32 public burnedTokens;

    uint32 public withdrawPenaltyTime;
    uint16 public withdrawPenaltyPercentage;
    bool internal _doneFirstDelegation;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address payable factoryAddress) {
        _factory = factoryAddress;
        _disableInitializers();
    }

    /// @notice Returns the address of the current collection owner.
    function owner() public view override(NFTOwnableUpgradeable) returns (address collectionOwner) {
        try IFiNCrossFactory(_factory).ownerOf(uint256(uint160(address(this)))) returns (address ownerOf) {
            return ownerOf;
        } catch {}
    }

    function _strictOwner() internal view override(NFTOwnableUpgradeable) returns (address ownerStrictAddress) {
        try IFiNCrossFactory(_factory).strictOwnerOf(uint256(uint160(address(this)))) returns (address strictOwnerOf) {
            return strictOwnerOf;
        } catch {}
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        if (_reentrancyEntered != 0) revert ReentrancyGuard();
        _reentrancyEntered = 1;
    }

    function _nonReentrantAfter() private {
        delete(_reentrancyEntered);
    }

    /// @notice Returns true if the metadata is fixed and immutable. If the metadata hasn't been fixed yet it will return false. Once fixed, it can't be changed by anyone.
    function isMetadataFixed() public view override returns (bool) {
        return (_baseURICIDHash != 0 || (_mintingType == MintingType.CUSTOM_URI));
    }

}
