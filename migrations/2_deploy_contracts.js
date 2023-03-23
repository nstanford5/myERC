const myERC = artifacts.require('myERC.sol');

module.exports = function (deployer) {
  deployer.deploy(myERC);
}