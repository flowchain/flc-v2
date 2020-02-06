var FlowchainToken = artifacts.require('FlowchainToken');
var MiningTest = artifacts.require('MiningTest');

module.exports = function(deployer) {
	deployer.deploy(FlowchainToken, '0xc5fdf4076b8f3a5357c5e395ab970b5b54098fef').then(() => {
		return deployer.deploy(MiningTest, FlowchainToken.address);
	})
};


