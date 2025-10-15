# VolumeDynamicToken
A **dynamic pricing ERC-20–like token** implemented fully in Solidity **without any imports, constructors, or input fields**.
Token price adjusts automatically based on the **traded volume**, making it a simple demonstration of a **bonding curve mechanism** on Ethereum.

---

## 📘 Overview

The **VolumeDynamicToken (VDT)** is a self-contained token contract written in Solidity `^0.8.0`.
Its unique feature is **dynamic token pricing**, where the price per token changes with the number of tokens bought or sold.

* **No imports or constructor** — fully standalone and self-initializing.
* **Dynamic pricing** — price increases when tokens are bought and decreases when sold.
* **Buy/Sell without parameters** — `buy()` is payable and accepts ETH directly (no arguments).
* **ERC-20–like behavior** — includes `transfer`, `approve`, and `transferFrom`.
* **Transparent & minimalistic** — built for educational and experimental use.

---

## ⚙️ Key Features

| Feature                 | Description                                                            |
| ----------------------- | ---------------------------------------------------------------------- |
| **Dynamic Pricing**     | Linear formula: `price = basePrice + (slope * netTraded / SCALE)`      |
| **Self-Contained**      | No external imports, no constructor, all parameters hardcoded inline   |
| **Buy & Sell**          | Purchase with `buy()` (send ETH); redeem with `sell(amount)`           |
| **Volume-Driven Value** | `netTraded` tracks overall buy/sell activity, directly affecting price |
| **No Owner/Admin**      | 100% decentralized; no privileged address or control functions         |

---

## 📈 Price Mechanism

### Formula

```
price = basePrice + (slope * netTraded / SCALE)
```

* **basePrice:** Minimum price floor (in wei per token)
* **slope:** Controls how much price changes per token bought/sold
* **netTraded:** Net number of tokens traded (buys increase it, sells decrease it)
* **SCALE:** Normalization factor to maintain precision

---

## 💰 Token Economics

| Parameter          | Value                | Description                            |
| ------------------ | -------------------- | -------------------------------------- |
| **Name**           | `VolumeDynamicToken` | Token display name                     |
| **Symbol**         | `VDT`                | Ticker symbol                          |
| **Decimals**       | `18`                 | Standard ERC-20 precision              |
| **Initial Supply** | `0`                  | No tokens exist until bought           |
| **basePrice**      | `1e15 wei`           | Starting price per token (≈ 0.001 ETH) |
| **slope**          | `1e9`                | Determines rate of price increase      |
| **SCALE**          | `1e18`               | Used to scale slope calculations       |

---

## 🧩 Functions

### Core ERC-20 Functions

| Function                                                | Description                               |
| ------------------------------------------------------- | ----------------------------------------- |
| `transfer(address to, uint256 value)`                   | Send tokens to another user               |
| `approve(address spender, uint256 value)`               | Approve spending by another address       |
| `transferFrom(address from, address to, uint256 value)` | Spend tokens on behalf of another address |

### Dynamic Trading Functions

| Function               | Type    | Description                                              |
| ---------------------- | ------- | -------------------------------------------------------- |
| `buy()`                | payable | Buys tokens for `msg.sender` using ETH; mints new tokens |
| `sell(uint256 amount)` | public  | Burns tokens and returns ETH to seller                   |
| `currentPrice()`       | view    | Returns the current token price in wei                   |

### Utility Functions

| Function          | Description                               |
| ----------------- | ----------------------------------------- |
| `receive()`       | Accepts ETH sent directly to the contract |
| `fallback()`      | Handles unexpected calls                  |
| `decimalsValue()` | Returns token decimals (18)               |

---

## 🧮 Example Usage

### 1. Deploy Contract

Deploy directly in **Remix IDE** using Solidity `^0.8.0` — no constructor parameters required.

### 2. Buy Tokens

Send ETH to the contract:

```solidity
VDT.buy{value: 1 ether}();
```

→ Mints tokens for the sender based on the current price.

### 3. Check Balance

```solidity
VDT.balanceOf(msg.sender);
```

### 4. Sell Tokens

```solidity
VDT.sell(1000 * 1e18);
```

→ Burns tokens and sends ETH back at current dynamic price.

### 5. View Current Price

```solidity
VDT.currentPrice();
```
contract address: 0xd9145CCE52D386f254917e481eB44e9943F39138
---

## ⚠️ Disclaimer

> This contract is intended **for educational and experimental purposes only**.
> It is **not audited** and **should not be used in production** or with real funds.
> Linear price curves may cause **imbalances** or **liquidity lockups** without proper bonding-curve integration.

---

## 🧠 Future Enhancements

* Add exponential or logarithmic bonding-curve pricing
* Introduce an **owner/admin** for liquidity control
* Integrate **fee or treasury mechanisms**
* Add **graphical frontend** for on-chain price visualization

---

## 🏷️ License

**MIT License**
Free to use, modify, and distribute with attribution.
