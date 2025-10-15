// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title VolumeDynamicToken (No imports, No constructor)
/// @notice ERC20-like token with simple dynamic pricing based on net traded volume.
/// @dev buy() is payable and requires no input fields; contract uses inline initial values (no constructor).
contract VolumeDynamicToken {
    // ERC20 basic storage
    string public name = "VolumeDynamicToken";
    string public symbol = "VDT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Pricing model parameters (set inline, no constructor)
    // basePrice is in wei per token (with decimals 18). Example: 0.001 ETH = 1e15 wei
    uint256 public constant basePrice = 1e15; // 0.001 ETH per token at floor
    // slope controls price increase per token (scaled by SCALE)
    uint256 public constant slope = 1e9; // tuneable: small number
    // SCALE to keep slope small relative to token decimals
    uint256 public constant SCALE = 1e18;

    // Tracks net traded tokens (tokens minted via buys minus tokens burned via sells)
    // This is the "volume" that drives price changes
    uint256 public netTraded; // in token units (with decimals)

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Bought(address indexed buyer, uint256 ethSpent, uint256 tokensMinted, uint256 pricePerToken);
    event Sold(address indexed seller, uint256 tokensBurned, uint256 ethReturned, uint256 pricePerToken);

    // ---------------------------
    // ERC20-like functions
    // ---------------------------
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "transfer to zero");
        require(balanceOf[from] >= value, "insufficient balance");
        unchecked {
            balanceOf[from] -= value;
            balanceOf[to] += value;
        }
        emit Transfer(from, to, value);
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        require(allowed >= value, "allowance exceeded");
        allowance[from][msg.sender] = allowed - value;
        _transfer(from, to, value);
        return true;
    }

    // ---------------------------
    // Pricing logic
    // ---------------------------

    /// @notice Returns current price (wei per token, token has 18 decimals)
    function currentPrice() public view returns (uint256) {
        // price = basePrice + slope * netTraded / SCALE
        // netTraded has token decimals (18), slope is scaled so division by SCALE yields appropriate wei increment
        return basePrice + (slope * netTraded) / SCALE;
    }

    // ---------------------------
    // Buying and Selling
    // ---------------------------

    /// @notice Buy tokens by sending ETH. No input params; tokens minted = floor(msg.value / price)
    /// @dev Any leftover wei (if msg.value not an exact multiple) stays in contract as pool liquidity.
    function buy() external payable returns (uint256 tokensMinted) {
        require(msg.value > 0, "send ETH to buy");
        uint256 price = currentPrice();
        require(price > 0, "invalid price");

        // tokens minted = (msg.value * (10 ** decimals)) / price
        // Since both ETH and price are in wei, multiply numerator by 1 to get token units with 18 decimals.
        tokensMinted = (msg.value * (10 ** uint256(decimals))) / price;
        require(tokensMinted > 0, "insufficient ETH for one token");

        // Mint tokens
        totalSupply += tokensMinted;
        balanceOf[msg.sender] += tokensMinted;

        // Increase netTraded (drives price up)
        netTraded += tokensMinted;

        emit Bought(msg.sender, msg.value, tokensMinted, price);
        emit Transfer(address(0), msg.sender, tokensMinted);
    }

    /// @notice Sell `amount` tokens back to contract for ETH at current price
    /// @param amount Number of tokens to sell (token units with decimals)
    function sell(uint256 amount) external returns (uint256 ethReturned) {
        require(amount > 0, "amount zero");
        require(balanceOf[msg.sender] >= amount, "not enough tokens");

        // Compute ETH to return = amount * price / (10 ** decimals)
        uint256 price = currentPrice();
        // ethReturned = (amount * price) / (10**decimals)
        ethReturned = (amount * price) / (10 ** uint256(decimals));

        // Ensure contract has enough ETH to pay seller
        require(address(this).balance >= ethReturned, "contract has insufficient ETH");

        // Burn tokens
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;

        // Decrease netTraded but avoid underflow
        if (netTraded >= amount) {
            netTraded -= amount;
        } else {
            netTraded = 0;
        }

        // Send ETH
        (bool success, ) = msg.sender.call{value: ethReturned}("");
        require(success, "ETH transfer failed");

        emit Sold(msg.sender, amount, ethReturned, price);
        emit Transfer(msg.sender, address(0), amount);
    }

    // ---------------------------
    // Utility / Admin-like functions
    // ---------------------------

    /// @notice Allows contract to receive ETH (e.g., liquidity top-up)
    receive() external payable {}

    fallback() external payable {}

    /// @notice Emergency withdraw by owner-like address? None implemented because no constructor or owner.
    /// In a production token you would add access control or a vault. This demo intentionally omits that.

    // ---------------------------
    // View helpers
    // ---------------------------

    function decimalsValue() external view returns (uint8) {
        return decimals;
    }
}