# Lottery
## About
This is a Lottery Contract inspired from chinese lottery version by implementing VRF for getting random number for choosing the winner.

## Guide
1. see [documentation](https://docs.chain.link/docs/get-a-random-number/) from VRF if you want to deploy this contract as you need to fund it some `LINK` to make it work. if you want to test this on Rinkeby Network you can get some test coin from Chain link too, see [documentation](https://docs.chain.link/docs/chainlink-vrf/) for details.

## How To Usage
1. You can send `0.001` ETH to contract below (any other amount will be rejected) and when the bet is still open
2. The manager can then start for requesting `randomWords` from VRF for choosing the winner
3. then the maanger can do `chooseWinner` to pick the winner.
4. when the manager want to start next bid round, he can use `startNewBid` function to reset the settings.

Note: 
if any problem occurs, please check if the VRF subscription has enough `LINK` to fund

## Sample Contract
`Rinkeby` : `0xe308533960200bbef632c9f7184d7ffc931bb591`

## Tech Stack
(VRF Chainlink)[https://docs.chain.link/docs/chainlink-vrf/]
