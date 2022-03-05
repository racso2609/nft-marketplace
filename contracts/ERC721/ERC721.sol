pragma solidity ^0.8.7;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

contract ERC721 is ERC721Upgradeable {
    using Counters for Counters.Counter;
    Counters.Counter private nftQuantity;
    struct Nft {
        string tokenURI;
    }

    mapping(uint256 => Nft) public nfts;

    function initialize(string calldata _name, string calldata _symbol)
        external
        initializer
    {
        __ERC721_init(_name, _symbol);
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        string memory baseURI = _baseURI();

        return string(abi.encodePacked(baseURI, nfts[_tokenId].tokenURI));
    }

    /// @param _tokenURI is the ipfs link to the corresponding file
    /// @dev make a mint and store the ipfs link on nfts
    function mint(string calldata _tokenURI) external returns (uint256) {
        _safeMint(msg.sender, nftQuantity.current());
        Nft memory newNft;
        newNft.tokenURI = _tokenURI;
        nfts[nftQuantity.current()] = newNft;
        nftQuantity.increment();
        return nftQuantity.current() - 1;
    }
}
