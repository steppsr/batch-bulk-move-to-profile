# batch-bulk-move-to-profile

Bash script that will get a list of NFTs to move into a Profile, then split them into batches of 25 and move each batch one at a time.

## Parameters
- Parameter 1 = Collection ID from Mintgarden. This Collection ID will be used as a filter to select which NFTs to move.
- Parameter 2 = Wallet ID. This is the Wallet ID to scan for NFTs in the given collection.
- Parameter 3 = DID Wallet ID. This is the Wallet ID of the DID NFT Wallet to move the NFTs into.
- Parameter 4 = DID. This is the DID that will be set when moving the NFTs.

## Running the command
```
bash batch-bulk-move-to-profile.sh <collection_id> <wallet_id> <did_wallet_id> <did>

Example:
bash batch-bulk-move-to-profile.sh col10en0hus79683c372nux50ev7smv5amrj9tjggkpandhqxd9pnlssmp2uwl 3 5 did:chia:1lwf5wtluvc5flp2ht46xprwvadyykjsctjcgyl3ffktzmd3d4r9slupmsq
```
