import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Nft is ERC1155 {
    using Counters for Counters.Counter;
    Counters.Counter private nftQuantity;
    struct NftObject {
        string tokenURI;
        address owner;
    }

    mapping(uint256 => NftObject) public nfts;

    constructor() ERC1155("") {}

    function uri(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return string(abi.encodePacked(nfts[_tokenId].tokenURI));
    }

    /// @param _tokenURI is the ipfs link to the corresponding file
    /// @param amount is the quantity of avaliables tokens
    /// @dev make a mint and store the ipfs link on nfts
    function mint(string calldata _tokenURI, uint256 amount)
        external
        returns (uint256)
    {
        _mint(msg.sender, nftQuantity.current(), amount, "");
        NftObject memory newNft;
        newNft.tokenURI = _tokenURI;
        newNft.owner = msg.sender;
        nfts[nftQuantity.current()] = newNft;
        nftQuantity.increment();
        return nftQuantity.current() - 1;
    }
}
