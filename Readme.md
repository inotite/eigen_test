# Eigen Tasks (C, D)

## How to set up the project

This project is built with `foundry` and `forge` so you should have `foundry` installed on your local in order to test it.

```
forge install
```

## How to run the test cases

As we are using the mainnet addresses for `Uniswap`, `USDC`, `USDT`, and `Chainlink` oracles, the test should run on `mainnet` fork.

```
forge test -f <MAINNET_RPC_URL> -vvv
```

You should replace `<MAINNET_RPC_URL>` with your own RPC URL to test and that could be anything like `Infura`, `Alchemy`, or any mainnet RPC URL.

## Where the flattened files live?

- `src/SwapCoinsFlattened.sol` is the flattened version of Task C.
- `src/OracleUsageFlattened.sol` is the flattened version of Task D.
