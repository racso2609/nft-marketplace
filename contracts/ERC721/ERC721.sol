pragma solidity ^0.8.7;

/* import "@openzeppelin/contracts/access/Ownable.sol"; */
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ERC721 is ERC721Upgradeable, Initializable {
    using Counters for Counters.Counter;
    Counters.Counter private nftQuantity;
    struct Nft {
        string tokenURI;
    }

    mapping(uint256 => Nft) public nfts;
    event Mint(uint256 tokenId, address user);

    function initialize(string calldata _name, string calldata _symbol)
        external
        onlyInitializing
    {
        __ERC721_init(_name, _symbol);
    }

    function mint(string calldata _tokenURI) {
        nftQuantity.increment();
        _safeMint(msg.sender, nftQuantity);
        Nft newNft;
        newNft.tokenURI = _tokenURI;
        nfts[nftQuantity.current()] = newNft;

        emit Mint(nftQuantity.current(), msg.sender);
    }
}
