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

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./FiNTokenCommon.sol";
import "./precompiles/Staking.sol";
import "./precompiles/Distribution.sol";

/// @title 721Fi.xyz Smart Contracts for ERC-721.
/// @author The NFTs2Me Team
/// @notice Read our terms of service
/// @custom:security-contact security@nfts2me.com
/// @custom:terms-of-service https://nfts2me.com/terms-of-service/
/// @custom:website https://721Fi.xyz/
contract FiNERC721 is
    FiNTokenCommon,
    ERC721Upgradeable,
    EIP712Upgradeable,
    ERC721VotesUpgradeable
{
    /// @notice To be called to create the collection. Can only be called once.
    function initialize(
        string memory tokenName,
        string memory tokenSymbol,
        uint256 iMintPrice,
        bytes32 baseURICIDHash,
        bytes32 placeholderImageCIDHash,
        address iErc20PaymentAddress,
        uint32[] calldata integers,

        bool soulboundCollection,
        MintingType iMintingType
    ) public payable override initializer {
        __ERC721_init(tokenName, tokenSymbol);

        if (iErc20PaymentAddress == address(0)) revert InvalidPaymentAddress();
        _erc20PaymentAddress = iErc20PaymentAddress;
        if (integers[4] > 365 days) revert WithdrawPenaltyTimeTooHigh();
        if (uint16(integers[5]) > 10_000) revert WithdrawPenaltyPercentageTooHigh();
        withdrawPenaltyTime = integers[4];
        withdrawPenaltyPercentage = uint16(integers[5]);

        if (integers[0] == 0) revert TotalSupplyMustBeGreaterThanZero();
        _collectionSize = integers[0];

        if (baseURICIDHash != 0 && placeholderImageCIDHash != 0) revert CantSetBaseURIAndPlaceholderAtTheSameTime();
        if (baseURICIDHash == 0) {
            if (placeholderImageCIDHash == 0) {
                revert NoBaseURINorPlaceholderSet();
            } else {
                _placeholderImageCIDHash = placeholderImageCIDHash;
            }
        } else {
            _baseURICIDHash = baseURICIDHash;
        }

        if (uint16(integers[1]) > 10_00) revert RoyaltyFeeTooHigh();
        _royaltyFee = uint16(integers[1]);

        if (uint16(integers[2]) > 10_00) revert RoyaltyFeeTooHigh();
        _mintRoyaltyFee = uint16(integers[2]);

        if (uint16(integers[3]) > 10_00) revert RoyaltyFeeTooHigh();
        _rewardsRoyaltyFee = uint16(integers[3]);

        if (iMintPrice == 0) revert MintPriceMustBeGreaterThanZero();
        _mintPrice = iMintPrice;

        _mintingType = iMintingType;
        _soulboundCollection = soulboundCollection;

    }

    constructor(address libraryAddress, address payable factoryAddress) FiNTokenCommon(libraryAddress, factoryAddress) {}

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    ///  Metadata JSON Schema".
    function tokenURI(uint256 tokenId)
        public
        view
        override(FiNTokenCommon, ERC721Upgradeable)
        returns (string memory)
    {
        _requireMinted(tokenId);
        return IFiNLibrary(address(this)).tokenURIImpl(tokenId);
    }

    function _exists(uint256 tokenId)
        internal
        view
        override(ERC721Upgradeable, FiNTokenCommon)
        returns (bool)
    {
        return super._exists(tokenId);
    }

    function exists(uint256 tokenId) public view override returns (bool)
    {
        return _exists(tokenId);
    }

    function _mint(bool firstMinting, address to, uint256 tokenId, uint256 mintPricePerToken)
        internal
        override(FiNTokenCommon)
    {

        mintingDate[tokenId] = block.timestamp;

        uint ownerFee = (_mintRoyaltyFee *  _mintPrice) / 100_00;
        uint mintPriceMinusFee = mintPricePerToken - ownerFee;

        minimumMintFeeWhenMinting[tokenId] = _mintPrice - ownerFee;

        rawPendingToWithdraw[owner()] += ownerFee;

        uint totalAmountWithRewards = getTotalAmountWithRewards();

        uint currentTokenStakes;

        if (firstMinting || totalStakedRaw == 0 || totalAmountOfStakes == 0 || totalAmountWithRewards == 0) {

            totalAmountOfStakes = 0;
            totalStakedRaw = 0;
            currentTokenStakes = mintPriceMinusFee;
        } else {

            uint newTotalStakes = (totalAmountWithRewards + mintPriceMinusFee) * totalAmountOfStakes / totalAmountWithRewards;
            currentTokenStakes = newTotalStakes - totalAmountOfStakes;

        }

        totalAmountOfStakes += currentTokenStakes;
        totalStakedRaw += mintPriceMinusFee;

        amountOfStakes[tokenId] = currentTokenStakes;
        stakedRaw[tokenId] = mintPriceMinusFee;

        super._mint(to, tokenId);
    }

    function getBurnableAmount(uint256 tokenId) public view override returns (uint256 amountToWithdraw) {
        require(_exists(tokenId), "ERC721: burn of nonexistent token");

        uint totalAmountStaked = getTotalAmountWithRewards();

        uint unburnedTokens = _collectionSize - burnedTokens;

        uint relativeStakes = amountOfStakes[tokenId];

        if (unburnedTokens <= 1) {

            amountToWithdraw = totalAmountStaked;
        } else {

            amountToWithdraw = (relativeStakes * totalAmountStaked) / totalAmountOfStakes;

            uint unburnedPercentagePenalty = (unburnedTokens * 100_00) / _collectionSize;
            assert(unburnedPercentagePenalty <= 100_00);

            uint penaltyPercentage = unburnedPercentagePenalty;

            uint elapsed = block.timestamp - mintingDate[tokenId];

            if (elapsed < withdrawPenaltyTime) {

                uint remainingTime = withdrawPenaltyTime - elapsed;
                uint remainingTimePercentagePenalty = (remainingTime * 100_00) / withdrawPenaltyTime;
                assert(remainingTimePercentagePenalty <= 100_00);

                penaltyPercentage += remainingTimePercentagePenalty;
            }

            assert(penaltyPercentage <= 200_00);

            uint256 penaltiesAmount = (minimumMintFeeWhenMinting[tokenId] * penaltyPercentage * withdrawPenaltyPercentage) / 100_00 / 100_00;
            if (penaltiesAmount > amountToWithdraw) return 0;
            amountToWithdraw -= penaltiesAmount;

        }
    }

    modifier onlyNFTOwner(uint256 tokenId) {
        require(msg.sender == ownerOf(tokenId), "ERC721Fi: Caller must be owner");
        _;
    }

    function burnToWithdraw(uint256 tokenId) public onlyNFTOwner(tokenId) override {

        uint amountToWithdraw = getBurnableAmount(tokenId);

        _burn(tokenId);
        burnedTokens++;

        totalAmountOfStakes -= amountOfStakes[tokenId];
        totalStakedRaw -= stakedRaw[tokenId];
        delete amountOfStakes[tokenId];
        delete stakedRaw[tokenId];

        _send(msg.sender, amountToWithdraw);
    }

    function totalPendingToWithdraw(address owner) public view override returns (uint256 pendingToWithdraw, bool totallyUnbonded) {
        pendingToWithdraw = rawPendingToWithdraw[owner];
        totallyUnbonded = true;

    }

    function withdrawPending() public override {

        uint amountToWithdraw = rawPendingToWithdraw[msg.sender];
        delete(rawPendingToWithdraw[msg.sender]);

        if (amountToWithdraw > 0) {
            _send(msg.sender, amountToWithdraw);
        } else {

            revert("No pending amount to withdraw");
        }

        totalWithdrawn[msg.sender] += amountToWithdraw;
        emit Withdraw(msg.sender, amountToWithdraw);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721Upgradeable)
    {
        super._burn(tokenId);    
    }

    function getTotalAmountWithRewards() public view override returns (uint256 amount) {

        return IERC20Upgradeable(_erc20PaymentAddress).balanceOf(address(this));
    }

    /// @notice Returns the total amount staked by the contract. Not including rewards.
    function getContractStaked() public view override returns (uint256 amount) {
        return IERC20Upgradeable(_erc20PaymentAddress).balanceOf(address(this));

    }

    function unstakeableAmount(uint256 tokenId) public view override returns (uint256 unstakeable) {
        uint256 totalValueBefore = getTotalAmountWithRewards();
        (unstakeable, ) = _unstakeableAmountAux(tokenId, totalValueBefore);
    }

    function _unstakeableAmountAux(uint256 tokenId, uint256 totalValueBefore) private view returns (uint256 unstakeable, uint256 tokenValueBefore) {

        uint256 unburnedTokens = _collectionSize - burnedTokens;

        if (unburnedTokens <= 1) {
            tokenValueBefore = totalValueBefore;
        } else {
            tokenValueBefore = (amountOfStakes[tokenId] * totalValueBefore) / totalAmountOfStakes;
        }

        if (tokenValueBefore > minimumMintFeeWhenMinting[tokenId]) {
            unstakeable = tokenValueBefore - minimumMintFeeWhenMinting[tokenId];
        }
    }

    function decreaseStaking(uint256 tokenId, uint256 amountToDecrease) onlyNFTOwner(tokenId) external override {
        require(amountToDecrease > 0, "Decrease amount must be higher than 0");
        uint256 totalValueBefore = getTotalAmountWithRewards();
        (uint256 unstakeable, uint256 tokenValueBefore) = _unstakeableAmountAux(tokenId, totalValueBefore);

        require(amountToDecrease <= unstakeable, "Decrease amount is higher than unstakeable amount");

        uint256 totalValueAfter = totalValueBefore - amountToDecrease;

        uint256 tokenValueAfter = tokenValueBefore - amountToDecrease;
        assert(tokenValueAfter >= minimumMintFeeWhenMinting[tokenId]);

        if (tokenValueAfter < stakedRaw[tokenId]) {

            uint256 differenceOfStaked = stakedRaw[tokenId] - tokenValueAfter;
            stakedRaw[tokenId] = tokenValueAfter;
            totalStakedRaw -= differenceOfStaked;
        }

        uint256 newAmountOfStakes = (totalAmountOfStakes * totalValueAfter) / totalValueBefore;
        uint256 differenceOfStakes = totalAmountOfStakes - newAmountOfStakes;
        amountOfStakes[tokenId] -= differenceOfStakes;
        totalAmountOfStakes -= differenceOfStakes;

        _send(msg.sender, amountToDecrease);

    }

    function _send(address to, uint256 amount) private {
        SafeERC20Upgradeable.safeTransfer(IERC20Upgradeable(_erc20PaymentAddress), to, amount);

    }

    function increaseStaking(uint256 tokenId, uint256 amountToIncrease) payable external override {
        require(amountToIncrease > 0, "Increase amount must be higher than 0");
        require(_exists(tokenId), "ERC721: increase of nonexistent token");
        uint256 totalValueBefore = getTotalAmountWithRewards();
        _requirePayment(amountToIncrease, 1);

        stakedRaw[tokenId] += amountToIncrease;
        totalStakedRaw += amountToIncrease;

        uint256 totalValueAfter = totalValueBefore + amountToIncrease;
        uint256 newAmountOfStakes = (totalAmountOfStakes * totalValueAfter) / totalValueBefore;
        uint256 differenceOfStakes = newAmountOfStakes - totalAmountOfStakes;
        amountOfStakes[tokenId] += differenceOfStakes;
        totalAmountOfStakes += differenceOfStakes;

    }

    /// @notice A descriptive name for a collection of NFTs in this contract
    function name()
        public
        view
        override(ERC721Upgradeable, FiNTokenCommon)
        returns (string memory)
    {
        return super.name();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal override {
        if (
            from != address(0) &&
            (_soulbound[firstTokenId] || _soulboundCollection)
        ) revert NonTransferrableSoulboundNFT();

        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal override(ERC721Upgradeable, ERC721VotesUpgradeable) {
        super._afterTokenTransfer(from, to, firstTokenId, batchSize);

        if (_maxPerAddress != 0) {

            if (balanceOf(to) > _maxPerAddress) revert MaxPerAddressExceeded();
        }
    }

    /// @notice Query if a contract implements an interface
    /// @param interfaceId The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceId` and `interfaceId` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, IERC165Upgradeable)
        returns (bool)
    {
        return (

        interfaceId == type(IERC2981Upgradeable).interfaceId || super.supportsInterface(interfaceId));
    }

    /// @notice An abbreviated name for NFTs in this contract
    /// @return the collection symbol
    function symbol()
        public
        view
        virtual
        override(IFiN_ERCBase, ERC721Upgradeable)
        returns (string memory)
    {
        return super.symbol();
    }

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param owner An address for whom to query the balance
    /// @return balance The number of NFTs owned by `owner`, possibly zero
    function balanceOf(address owner) public view override(ERC721Upgradeable, FiNTokenCommon) returns (uint256 balance) {
        balance = super.balanceOf(owner);
        if (_mintingType == MintingType.RANDOM) {
            balance += _randomTickets[owner].amount;
        }
    }

    function _EIP712Name() internal virtual override view returns (string memory) {
        return "ERC721Fi";
    }

    function _EIP712Version() internal virtual override view returns (string memory) {
        return "1";
    }

}
