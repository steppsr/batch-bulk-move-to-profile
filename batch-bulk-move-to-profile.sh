#!/bin/bash

# Parameter 1 = Collection ID from Mintgarden. This Collection ID will be used as a filter to select which NFTs to move.
# Parameter 2 = Wallet ID. This is the Wallet ID to scan for NFTs in the given collection.
# Parameter 3 = DID Wallet ID. This is the Wallet ID of the DID NFT Wallet to move the NFTs into.
# Parameter 4 = DID. This is the DID that will be set when moving the NFTs.

sleep_countdown()
{
        secs=$(($1))
        while [ $secs -gt 0 ]; do
           echo -ne " $secs\033[0K\r"
           sleep 1
           : $((secs--))
        done
}

appdir=`pwd`
mkdir -p $appdir/files
cd $appdir/files

# move the nft from the given collection into the given did wallet
col=$1
wid=$2
nft_wallet_id=$4
did_id=$4

fee_xch=0.000000000001

if [ "$col" == "" ] || [ "$wid" == "" ] || [ "$nft_wallet_id" == "" ] || [ "$did_id" == "" ]; then
        echo "Missing parameters."
        echo "USAGE: bash nft_move.sh <collection_id> <wallet_id> <did_wallet_id> <did>"
        exit
else
        c=`chia rpc wallet nft_count_nfts '{"wallet_id":'$wid'}' | jq -r '.count'`
        nft_ids=`chia rpc wallet nft_get_nfts '{"wallet_id":'$wid', "start_index":0, "num":'$c', "ignore_size_limit": false}' | grep "nft_id" | cut -c 24-85`

        for id in $nft_ids; do

                nft_json=`curl -s https://api.mintgarden.io/nfts/$id`
                nft_col_id=`echo "$nft_json" | jq '.collection.id' | cut --fields 2 --delimiter=\"`
                if [ "$nft_col_id" == "$col" ]; then
                        echo "$id" >> moves.csv
                fi
        done
fi

# lets make sure no left over files are around
rm -f batch_*

# now lets split the move.csv into batchs of 25
split -l 25 moves.csv batch_

# clear moves.csv file
truncate -s 0 moves.csv

batchs=`ls -1 batch_*`

json=""
for batch in $batchs; do

        # build json for RPC command
        json=`jq -n --argjson nft_coin_list "[]" --arg did_id "$did_id" --arg fee "FEE_VALUE" '$ARGS.named' `

        file_contents=`cat $batch`
        for nft_id in $file_contents; do
                json=`echo $json | jq '.nft_coin_list += [{"nft_coin_id":"'"$nft_id"'","wallet_id":'"$nft_wallet_id"'}]'`
        done

        # call RPC for bulk move on batch
        json=`echo $json | jq -c .`
        json="${json//\"FEE_VALUE\"/$fee_xch}"
        cmd="chia rpc wallet nft_set_did_bulk '$json'"
        eval "$cmd"
        sleep_countdown 120
done
rm -f batch_*

cd $appdir
