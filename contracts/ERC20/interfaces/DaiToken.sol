// Adding only the ERC-20 function we need
interface DaiToken {
    function transfer(address dst, uint256 wad) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);

    function balanceOf(address guy) external view returns (uint256);

    function approve(address guy, uint256 wad) external returns (bool);

    function allowance(address src, address guy)
        external
        view
        returns (uint256);
}
