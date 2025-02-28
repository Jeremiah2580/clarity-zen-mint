# ZenMint
A calm-themed NFT creation and auction platform built on Stacks blockchain using Clarity.

## Features
- Create unique NFTs with customizable metadata 
- List NFTs for auction
- Place bids on NFTs
- Claim won auctions
- Transfer NFT ownership

## Setup and Installation
1. Clone the repository
2. Install Clarinet for local development
3. Run `clarinet check` to verify contracts
4. Run `clarinet test` to execute test suite

## Usage Examples
```clarity
;; Create a new NFT 
(contract-call? .zen-mint create-nft "Peaceful Garden" "A tranquil zen garden scene" u100000)

;; List NFT for auction
(contract-call? .zen-mint start-auction u1 u1000000 u100)

;; Place bid on NFT
(contract-call? .zen-mint place-bid u1 u1500000)

;; Claim won auction
(contract-call? .zen-mint claim-auction u1)
```

## Dependencies
- Clarity language
- Clarinet for testing and deployment
