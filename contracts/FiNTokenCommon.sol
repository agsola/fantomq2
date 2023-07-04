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
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";

/// Utils
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./_interfaces/IFiNCrossFactory.sol";
import "./_interfaces/IFiN_ERCBase.sol";
import "./FiNCommonStorage.sol";

interface IFiNLibrary {
    function tokenURIImpl(uint256 tokenId) external view returns (string memory);
}

/// @title NFTs2Me.com Smart Contracts
/// @author The NFTs2Me Team
/// @notice Read our terms of service
/// @custom:security-contact security@nfts2me.com
/// @custom:terms-of-service https://nfts2me.com/terms-of-service/
/// @custom:website https://nfts2me.com/
abstract contract FiNTokenCommon is FiNCommonStorage, IFiN_ERCBase {
    /// IMMUTABLE
    address internal immutable LIBRARY_ADDRESS;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address libraryAddress, address payable factoryAddress) FiNCommonStorage(factoryAddress) {
        LIBRARY_ADDRESS = libraryAddress;
    }

    function _mint(bool firstMint, address to, uint256 tokenId, uint256 mintPricePerToken) internal virtual;

    function _exists(uint256 tokenId) internal view virtual returns (bool);

    function name() external view virtual override returns (string memory);

    function tokenURI(uint256 tokenId) external view virtual override returns (string memory);

    function balanceOf(address owner) public view virtual returns (uint256 balance);    

    /// @notice Mints one NFT to the caller (msg.sender). Requires `minting type` to be `sequential` and the `mintPrice` to be send (if `Native payment`) or approved (if `ERC-20` payment).
    function mint(uint256 price) external payable override {
        require(price >= _mintPrice, "price lower than mintPrice");
        bool firstMint = _soldTokens <= burnedTokens;
        _checkPhase();
        if (_mintingType != MintingType.SEQUENTIAL) revert InvalidMintingType();
        unchecked {
            if ((++_soldTokens) > _collectionSize) revert CollectionSoldOut();
        }
        _mint(firstMint, msg.sender, _soldTokens, price);
        _requirePayment(price, 1);
    }

    /// @notice Mints `amount` NFTs to the caller (msg.sender). Requires `minting type` to be `sequential` and the `mintPrice` to be send (if `Native payment`) or approved (if `ERC-20` payment).
    /// @param amount The number of NFTs to mint
    function mint(uint256 amount, uint256 price) external payable override {
        require(price >= _mintPrice, "price lower than mintPrice");
        _mintSequentialWithChecks(msg.sender, amount, price);
        _requirePayment(price, amount);
    }

    /// @notice Mints `amount` NFTs to `to` address. Requires `minting type` to be `sequential` and the `mintPrice` to be send (if `Native payment`) or approved (if `ERC-20` payment).
    /// @param to The address of the NFTs receiver
    /// @param amount The number of NFTs to mint    
    function mintTo(address to, uint256 amount, uint256 price) external payable override {
        require(price >= _mintPrice, "price lower than mintPrice");
        _mintSequentialWithChecks(to, amount, price);
        _requirePayment(price, amount);
    }

    function _mintSequentialWithChecks(address to, uint256 amount, uint256 price) private {
        _checkPhase();
        if (_mintingType != MintingType.SEQUENTIAL) revert InvalidMintingType();
        if ((_soldTokens + amount) > _collectionSize) revert CollectionSoldOut();

        _mintSequential(to, amount, price);
    }

    function _mintSequential(address to, uint256 amount, bool soulbound, uint256 price) private {
        for (uint256 i; i < amount; ) {
            bool firstMint = _soldTokens <= burnedTokens;
            unchecked {
                _mint(firstMint, to, ++_soldTokens, price);
            }
            if (soulbound) _soulbound[_soldTokens] = true;
            unchecked {
                ++i;
            }
        }
    }

    function _mintSequential(address to, uint256 amount, uint256 price) internal virtual {
        for (uint256 i; i < amount; ) {
            bool firstMint = _soldTokens <= burnedTokens;
            unchecked {
                _mint(firstMint, to, ++_soldTokens, price);
                ++i;
            }
        }
    }

    /// @notice Two phases on-chain random minting. Mints `amount` NFTs tickets to `to` address. Requires `minting type` to be `random` and the `mintPrice` to be send (if `Native payment`) or approved (if `ERC-20` payment). Once minted, those tickets must be redeemed for an actual token calling `redeemRandom()`.
    /// @param to The address of the NFTs receiver
    /// @param amount The number of NFTs to mint    
    function mintRandomTo(address to, uint256 amount, uint256 price) external payable override {
        require(price >= _mintPrice, "price lower than mintPrice");

        _mintRandomWithChecks(to, amount, price);
        _requirePayment(price, amount);
    }

    function _mintRandomWithChecks(address to, uint256 amount, uint256 price) private {
        _checkPhase();
        if (_mintingType != MintingType.RANDOM) revert InvalidMintingType();
        if (_soldTokens + (amount) > _collectionSize) revert CollectionSoldOut();
        require(_randomTickets[to].amount == 0, "Pending to withdraw > 0");

        unchecked {
            _randomTickets[to].blockNumberToReveal = block.number + 2;
            _randomTickets[to].amount = amount;
            _randomTickets[to].pricePerToken = price;
            _soldTokens += uint32(amount);
        }

        if (_maxPerAddress != 0) {

            if (balanceOf(to) > _maxPerAddress) revert MaxPerAddressExceeded();
        }        
    }

    /// @notice Redeems remaining random tickets generated from `msg.sender` by calling `mintRandomTo` for actual NFTs.
    function redeemRandom() external payable override {
        uint256 blockNumberToReveal = _randomTickets[msg.sender].blockNumberToReveal;
        uint256 amountToRedeem = _randomTickets[msg.sender].amount;
        uint256 price = _randomTickets[msg.sender].pricePerToken;

        if (amountToRedeem == 0) revert NothingToRedeem();
        if (block.number <= _randomTickets[msg.sender].blockNumberToReveal) revert CantRevealYetWaitABitToBeAbleToRedeem();

        bytes32 seedFromBlockNumber = blockhash(blockNumberToReveal);

        if (seedFromBlockNumber == 0) {

            uint256 newBlockNumber = ((block.number & uint256(int256(-0x100))) + (blockNumberToReveal & 0xff));

            if ((newBlockNumber >= block.number)) {
                newBlockNumber -= 256;

            }
            seedFromBlockNumber = blockhash(newBlockNumber);

        }

        delete(_randomTickets[msg.sender].blockNumberToReveal);
        delete(_randomTickets[msg.sender].amount);
        delete(_randomTickets[msg.sender].pricePerToken);

        uint16 maxPerAddressTemp = _maxPerAddress;
        delete(_maxPerAddress);
        _mintRandom(msg.sender, amountToRedeem, seedFromBlockNumber, false, price);
        _maxPerAddress = maxPerAddressTemp;
    }

    function _mintRandom(address to, uint256 amount, bytes32 seed, bool soulbound, uint256 price) private {
        for (; amount > 0; ) {
            uint256 tokenId = _randomTokenId(seed, amount);
            _mint(false, to, tokenId, price);
            if (soulbound) _soulbound[tokenId] = true;
            unchecked {
                --amount;
            }
        }
    }

    function _randomTokenId(bytes32 seed, uint256 extraModifier) private view returns (uint256 tokenId) {

        tokenId = (uint256(keccak256(abi.encodePacked(seed, extraModifier))) % _collectionSize) + 1;

        while (_exists(tokenId)) {
            unchecked {
                tokenId = (tokenId % _collectionSize) + 1;
            }
        }
    }

    /// @notice Mints `amount` NFTs to `to` address. Requires `minting type` to be `specify` and the `mintPrice` to be send (if `Native payment`) or approved (if `ERC-20` payment).
    /// @param to The address of the NFTs receiver
    /// @param tokenIds An array of the specified tokens. They must not be minted, otherwise, it will revert.
    function mintSpecifyTo(address to, uint256[] memory tokenIds, uint256 price)
        external
        payable
        override
    {
        require(price >= _mintPrice, "price lower than mintPrice");
        _mintSpecifyWithChecks(to, tokenIds, price);
        _requirePayment(price, tokenIds.length);
    }

    function _mintSpecifyWithChecks(address to, uint256[] memory tokenIds, uint256 price)
        private
    {
        _checkPhase();
        if (_mintingType != MintingType.SPECIFY) revert InvalidMintingType();

        if (_soldTokens + (tokenIds.length) > _collectionSize) revert CollectionSoldOut();

        _mintSpecify(to, tokenIds, price);
    }

    function _mintSpecify(
        address to,
        uint256[] memory tokenIds,
        bool soulbound,
        uint256 price
    ) private {
        _mintSpecify(to, tokenIds, price);
        uint256 inputLength = tokenIds.length;        
        if (soulbound) {
            for (uint256 i; i < inputLength; ) {
                _soulbound[tokenIds[i]] = true;
                unchecked {
                    ++i;
                }
            }
        }
    }

    function _mintSpecify(address to, uint256[] memory tokenIds, uint256 price)
        internal
        virtual
    {

        uint256 inputLength = tokenIds.length;
        bool firstMint = _soldTokens <= burnedTokens;
        unchecked {
            _soldTokens += uint32(inputLength);
        }
        for (uint256 i; i < inputLength; ) {
            firstMint = firstMint && i==0;
            uint256 tokenId = tokenIds[i];

            if (tokenId == 0 || tokenId > _collectionSize) revert InvalidTokenId();
            _mint(firstMint, to, tokenId, price);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Returns the minting price of one NFT.
    /// @return Mint price for one NFT in native coin or ERC-20.
    function mintPrice() external view returns (uint256) {
        return _mintPrice;
    }

    /// @notice Returns the current total supply.
    /// @return Current total supply.
    function totalSupply() external view returns (uint256) {
        return _soldTokens;
    }

    /// @notice Max amount of NFTs to be hold per address.
    /// @return Max per address allowed.
    function maxPerAddress() external view override returns (uint16) {
        return _maxPerAddress;
    }

    /// @notice Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
    /// @param salePrice The sale price
    /// @return receiver the receiver of the royalties.
    /// @return royaltyAmount the amount of the royalties for the given input.
    function royaltyInfo(
        uint256, 
        uint256 salePrice
    ) external view virtual returns (address receiver, uint256 royaltyAmount) {

        return (address(this), uint256((salePrice * _royaltyFee) / 100_00));
    }

    function _checkPhase() private {

        if (_currentPhase != SalePhase.PUBLIC) {
            if (_currentPhase == SalePhase.DROP_DATE) {
                if (block.timestamp >= _dropDateTimestamp) {
                    _currentPhase = SalePhase.PUBLIC;
                    delete(_dropDateTimestamp);
                } else {
                    revert WaitUntilDropDate();
                }
            } else if (_currentPhase == SalePhase.DROP_AND_END_DATE) {
                if (block.timestamp < _dropDateTimestamp) {
                    revert WaitUntilDropDate();
                }
                if (block.timestamp >= _endDateTimestamp) {
                    revert SaleFinished();
                }
            } else {

                revert PublicSaleNotOpen();
            }
        }
    }

    function _requirePayment(uint256 p_mintPrice, uint256 amount) internal {

            if (p_mintPrice == 0) return;
            uint256 totalAmount = p_mintPrice * amount;

            SafeERC20Upgradeable.safeTransferFrom(
                IERC20Upgradeable(_erc20PaymentAddress),
                msg.sender,
                address(this),
                totalAmount
            );

    }

    fallback() external payable
    {
        address libraryAddress = LIBRARY_ADDRESS;

        assembly {

            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(
                gas(),
                libraryAddress,
                0,
                calldatasize(),
                0,
                0
            )

            returndatacopy(0, 0, returndatasize())

            switch result

            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    receive() external payable {}    
}
