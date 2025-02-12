# Get Started
* forked from https://github.com/Layr-Labs/hello-world-avs/tree/de542237ccf7a48c172ade9dee0e76686f423b28/contracts

## Init
* install foundry
* run `forge build`
* clone `.env.example` as `.env` and fill in the values
    * For AVS optin, `PRIVATE_KEY` is the key controlling the operator

## How to opt in to the Vision AVS 
* Any operator can opt in without any whitelisting process
* There is no infra required
```
export RANDOM=$RANDOM && forge script script/RegisterOperatorToAvs.s.sol --rpc-url https://eth-mainnet.g.alchemy.com/v2/xxx --broadcast
```

## How to opt out from the Vision AVS 
```
forge script script/DeregisterOperator.s.sol --rpc-url https://eth-mainnet.g.alchemy.com/v2/xxx --broadcast
```

## For contract deployment and config update
```
forge script script/VisionAvsDeployer.s.sol --rpc-url https://eth-mainnet.g.alchemy.com/v2/xxx --broadcast --slow --verify
forge script script/UpdateMetadata.s.sol --rpc-url https://eth-mainnet.g.alchemy.com/v2/xxx --broadcast
forge script script/GetData.s.sol --rpc-url https://eth-mainnet.g.alchemy.com/v2/xxx
export IS_MULTISIG=true && forge script script/UpdateQuorum.s.sol --rpc-url https://eth-mainnet.g.alchemy.com/v2/xxx --broadcast
# Print calldata in hex
cast calldata "updateAVSMetadataURI(string)" https://raw.githubusercontent.com/ethgas-developer/ethgas-developer.github.io/main/vision-avs.json
```