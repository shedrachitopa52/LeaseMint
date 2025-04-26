# LeaseMint - NFT Rental Marketplace Smart Contract

A decentralized NFT rental marketplace built on Stacks blockchain, enabling secure peer-to-peer NFT rentals with deposit protection.

## Features

- 🎨 List NFTs for rent with customizable terms
- 💰 Set rental prices and security deposits
- ⏱️ Define rental duration in blocks
- 🔒 Secure rental validation and return process
- ✅ Automated duration tracking

## Contract Functions

### `list-nft`
List an NFT for rental with specified terms.
```clarity
(list-nft nft-contract token-id rental-price deposit duration)
```

### `rent-nft`
Rent a listed NFT by providing required payment.
```clarity
(rent-nft listing-id)
```

### `return-nft`
Return a rented NFT after rental period completion.
```clarity
(return-nft listing-id)
```

## Data Structures

### Listing
```clarity
{
  owner: principal,
  nft-contract: principal,
  token-id: uint,
  rental-price: uint,
  deposit: uint,
  duration: uint,
  rented: bool,
  renter: (optional principal),
  start-time: (optional uint)
}
```

## Getting Started

1. Clone the repository
2. Install dependencies
```bash
npm install
```
3. Deploy the contract
```bash
clarinet deploy
```


## Security

- Built-in rental duration validation
- Secure deposit handling
- Ownership verification
- Access control checks



