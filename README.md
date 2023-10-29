# Test

## step 1.

```
git clone https://github.com/HaoHaoLifeHack/RugPull.git
```

## step 2.

```
forge install
```

## step 3.

```
forge test --mc TradingCenterTest -vvv
```

## step 4.
請先在 project level 建立一個 .env  檔案，檔案內容需包含底下資訊，並請將 ETHEREUM_MAINNET_RPC_URL 的地址換成你的 alchemy 地址
Please find ref below:
```
ETHEREUM_MAINNET_RPC_URL = 'https://eth-mainnet.g.alchemy.com/v2/<your_api_key>'
BLOCK_NUMBER = 18454357
```
```
forge test --mc RugUsdcTest -vvv
```
