# Get Started
* forked from https://github.com/Layr-Labs/hello-world-avs/tree/de542237ccf7a48c172ade9dee0e76686f423b28/contracts
```
export PRIVATE_KEY=0x... && export OWNER_ADDRESS=0x... && forge script script/VisionAvsDeployer.s.sol --rpc-url https://1rpc.io/holesky --broadcast

forge script script/UpdateMetadata.s.sol --rpc-url https://1rpc.io/holesky --private-key 0x... --broadcast

export PRIVATE_KEY=0x... && export RANDOM=$RANDOM && forge script script/RegisterOperatorToAvs.s.sol --rpc-url https://1rpc.io/holesky --broadcast
```

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
