var DexToken = artifacts.require('DexToken');

var ownerAccount;           // The default owner account. Should be accounts[0]

var token;                  // The constructor promise of token contract
var tokenInstance;          // The token contract instance
var tokenContractAddress;   // The token contract address
var mintableAddress;        // Should be accounts[0]

// Use me in localhost
var network = 'development';

contract('DexToken', function(accounts,) {
  var BN = require('bn.js');
  var decimals = '000000000000000000';

  mintableAddress = accounts[0];

  it('should instantiate a token contract', function() {
    token = DexToken.new();
    // Wait for the token contract.
    // The amount of total supply gives to the creator. The contract calls transfer
    // from the address 0x0, therefore, we have to wait until the instantiatation finish.
    return token.then(function(instance) {
      tokenInstance = instance;
      tokenContractAddress = instance.address;
      assert.equal(typeof tokenContractAddress, 'string');
    });
  });

  it('should return a balance of 0 after instantiatation', function() {
    return tokenInstance.balanceOf(tokenContractAddress).then(function(balance) {
      assert.equal(balance, 0);
    });
  }); 

  it('should return the address of token creator', function() {
    return tokenInstance.getCreator().then(function(address) {
      ownerAccount = address;
      assert.equal(address, accounts[0]);
    });
  });      

  it('should return a balance of 0 in owner account', function() {
    return tokenInstance.balanceOf(ownerAccount).then(function(balance) {
      assert.equal(balance.toString(10), '0');
    });
  });    

  it('should mint 5000 tokens and send to ownerAccount', function() {
    return tokenInstance.mint(ownerAccount, 5000).then(function(tx) {
      assert.equal(tx.receipt.status, true);
    });
  }); 

  it('should return a balance of 5000 in ownerAccount', function() {
    return tokenInstance.balanceOf(ownerAccount).then(function(balance) {
      assert.equal(balance.toString(10), '5000');
    });
  }); 

  it('should send 1000 from ownerAccount to the user', function() {
    return tokenInstance.transfer(accounts[1], 1000).then(function(tx) {
      assert.equal(tx.receipt.status, true);
    });
  }); 

  it('should return a balance of 4000 in ownerAccount', function() {
    return tokenInstance.balanceOf(ownerAccount).then(function(balance) {
      assert.equal(balance.toString(10), '4000');
    });
  }); 

  it('should return a balance of 1000 in the user account', function() {
    return tokenInstance.balanceOf(accounts[1]).then(function(balance) {
      assert.equal(balance.toString(10), '1000');
    });
  });         
});