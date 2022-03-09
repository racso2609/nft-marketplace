# Marketplace

this contract let you buy erc1155 tokens indicating USD price

when you create a sale you indicate the price on USD but i multiply that for 10 ** 18, the reason of that id because the chainlink oracle return uint with 8 decimal to avoid underflows when we make the necesary division to determinate the token quantity. to know the price 

``` js
yarn test //run test suite on fork mainnet
yarn compile //compile all our contracts 
yarn deploy-test // depoy the contracts with the tag Marketplace on rinkeby
```
