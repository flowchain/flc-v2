var DexToken = artifacts.require('DexToken');

module.exports = function(deployer) {
	deployer.deploy(DexToken);
};