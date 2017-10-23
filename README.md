# README #

This is the code of BaseToken and RewardToken contracts. It uses the [OpenZeppelin](https://github.com/OpenZeppelin/zeppelin-solidity). It contains unit tests based on [Truffle Framework](http://truffleframework.com/).

### How do I get set up? ###

* Install NodeJS 5.0+
* Install [EthereumJS TestRPC](https://github.com/ethereumjs/testrpc)
* Install Truffle

~~~~
npm install -g truffle
~~~~

### How to run the tests ###

~~~~
truffle test
~~~~

### How does the project structure look like? ###

* *contracts* - contract code
* *migrations* - Truffle migrations code (currently empty)
* *test* - unit tests for the contracts
* *truffletemplates* - template code that comes with adding the Truffle nature to the project
* *zeppelin-solidity* - copy of the OpenZepplin project, not needed if contract imports are changed to the direct github URL, but it is good to have for local testing
