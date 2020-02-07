# FLC v2

The Flowchain token (FLC v2) smart contract. This repository hosts the source code for public audits.

# Prerequisites

* [node v10+](https://nodejs.org)\
* [Truffle v5+](https://truffleframework.com)\
* Linux or Mac OS X

# Introduction

The FLC v2 (or the "FLC native token") is the new update of the original FLC v1. Please visit the [Flowchain Token](https://flowchain.co/token.html) official website for more information. For detailed information on FLC v2, we plan to release an official FLC v2 whitepaper in March 2020.

# Off-Chain Issuable Tokens

The FLC v2 token (or the "FLC native token") has many new updates as opposed to the FLC v1 token. The FLC v1 token launched in 2019 is designed to be a mintable token that can be minted by an on-chain smart contract. Moreover, the FLC v2 token is also a mintable token that a number of tokens can also be minted that can be offered to a market.

As described in the academic paper: [Hybrid Blockchain and Pseudonymous Authentication for Secure and Trusted IoT Networksr](https://dl.acm.org/citation.cfm?doid=3292384.3292388), Flowchain has a hybrid architecture comprised of private blockchains (or "off-chain") and a public blockchain (or "on-chain"). Thus, to support Flowchain's hybrid architecture, FLC requires an off-chain issuable token technology to provide minted token redeem and user withdrawal capabilities. 

Such capabilities are lack in the FLC v1 tokens; thus, an upgrade to the original FLC v1 smart contract is required prior to the coming Flowchain main net launch.

## Specification

Flowchain proposes an extension to ERC-20 that adds off-chain issuable and mintable tokens.

A method to set an minimal withdraw amount:

```solidity
function setMinWithdrawAmount(uint256 amount) public returns (bool success);
```

A method to set a minimal withdraw amount:

```solidity
function getMinWithdrawAmount() public returns (uint256 amount);
```

A method to redeem the value of tokens to the address of the block producer (the "user"):

```solidity
function redeem(address to, uint256 amount) external returns (bool success);
```

A method to withdraw user funds:

```solidity
function withdraw(uint256 amount) public returns (bool success);
```

The user can send a signed message to the FLC v2 smart contract to withdraw their funds (the "token rewards") to their ERC-20 compatible wallet.

A method to setup a mintable address that can mint:

```solidity
function setupMintableAddress(address _mintable) public returns (bool success);
```

A method to mint an amount of tokens and transfer to the address:

```solidity
function mintToken(address to, uint256 amount) public returns (bool success);
```

A mintable address is the mining contract that can mint and redeem tokens.

## Implementation

The `redeem` function can only be invoked by the mining contract at the address set by `setupMintableAddress`. 

Also, `redeem` shall call `mintToken` to mint new tokens and send the funds back to the mining contract:

```
contract StandardToken {
    /**
     * @dev Redeem user mintable tokens. Only the mining contract can redeem tokens.
     * @param to The user to be redeemed tokens     
     * @param amount The amount of tokens to be withdrawn
     * @return The result of the withdraw
     */
    function redeem(address to, uint256 amount) external returns (bool success) {
        require(msg.sender == mintableAddress);    

        // Mint new tokens and send the funds to the account `mintableAddress`
        // Users can withdraw funds.
        mintToken(mintableAddress, amount);

        return true;
    }
}
```

# Development

Install the Truffle toolkit:

```
$ npm install -g truffle
```

Install this project:

```
$ git clone https://github.com/flowchain/flc-v2.git
$ cd flc-v2
$ npm install
```

Compile this project:

```
$ truffle compile
```

Run the migrations:

```
$ truffle migrate
```

To test project contracts, open a new terminal and run the following to start a local Ethereum client:

```
$ truffle develop
```

In the previous terminal, run the following to test contracts:

```
$ truffle test
```

# License

The MIT License

Copyright (c) 2020 The Flowchain Foundation. https://flowchain.co

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.