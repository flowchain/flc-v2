var FlowchainToken = artifacts.require('FlowchainToken');
var MiningTest = artifacts.require('MiningTest');

var ownerAccount;           // The default owner account. Should be accounts[0]

var token;                  // The constructor promise of token contract
var tokenInstance;          // The token contract instance
var tokenContractAddress;   // The token contract address
var mintableAddress;        // Should be accounts[0]

var miner;                  // The constructor promise of miner contract
var minerInstance;          // The miner contract instance
var minerContractAddress;   // The miner contract address

// The multisig wallet address
var multiSigWallet = '0xc5fdf4076b8f3a5357c5e395ab970b5b54098fef';

// Use me in localhost
var network = 'development';

contract('FlowchainToken', function(accounts,) {
  var BN = require('bn.js');
  var decimals = '000000000000000000';

  mintableAddress = accounts[0];

  it('should instantiate a token contract', function() {
    token = FlowchainToken.new(multiSigWallet);
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

  it('should set an mintable address', function() {
    return tokenInstance.setupMintableAddress(mintableAddress).then(function(tx) {
      assert.equal(tx.receipt.status, true);
    });
  }); 
 
  it('should return the new mintable address', function() {
    return tokenInstance.getMintableAddress().then(function(address) {
      assert.equal(address, mintableAddress);
    });
  });     

  it('should return a balance of 0 in owner account', function() {
    return tokenInstance.balanceOf(ownerAccount).then(function(balance) {
      assert.equal(balance.toString(10), '0');
    });
  });    

  it('should return a balance of 1000000000000000000000000000 in multiSigWallet', function() {
    return tokenInstance.balanceOf(multiSigWallet).then(function(balance) {
      assert.equal(balance.toString(10), '1000000000000000000000000000');
    });
  });  

  it('should mint 5000 tokens and send to ownerAccount', function() {
    return tokenInstance.mintToken(ownerAccount, 5000).then(function(tx) {
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

  it('should freeze the account', function() {
    return tokenInstance.freezeAccount(ownerAccount).then(function(tx) {
      assert.equal(tx.receipt.status, true);
    });
  }); 

  it('should not be able to send funds from a frozen account', async function() {
    try {
      await tokenInstance.transfer(accounts[1], 200);
      await tokenInstance.doRevert();
    } catch (error) {
      return assert.equal(true, true);
    }
    return assert.equal(false, true);
  }); 

  it('should unfreeze the account', function() {
    return tokenInstance.unfreezeAccount(ownerAccount).then(function(tx) {
      assert.equal(tx.receipt.status, true);
    });
  });  

  it('should be able to send 200 tokens from an unfreezed account', function() {
    return tokenInstance.transfer(accounts[2], 200).then(function(tx) {
      assert.equal(tx.receipt.status, true);
    });
  }); 

  it('should return a balance of 200 in the user account', function() {
    return tokenInstance.balanceOf(accounts[2]).then(function(balance) {
      assert.equal(balance.toString(10), '200');
    });
  });    

  it('should freeze the account', function() {
    return tokenInstance.freezeAccount(accounts[2]).then(function(tx) {
      assert.equal(tx.receipt.status, true);
    });
  }); 

  // Mining contract 
  // The mining contract can mine a maximal amount of 20,000 tokens. 
  it('should instantiate a mining contract', function() {
    miner = MiningTest.new(tokenContractAddress);
    return miner.then(function(instance) {
      minerInstance = instance;
      minerContractAddress = instance.address;
      assert.equal(typeof minerContractAddress, 'string');
    });
  }); 

  it('should setup an off-chain mintable address (the miner)', function() {
    return tokenInstance.setupMintableAddress(minerContractAddress).then(function(tx) {
      assert.equal(tx.receipt.status, true);
    });
  }); 
 
  it('should return the new mintable address (the miner)', function() {
    return tokenInstance.getMintableAddress().then(function(address) {
      assert.equal(address, minerContractAddress);
    });
  });  

  it('should return a balance of 0 in the miner contract', function() {
    return tokenInstance.balanceOf(minerContractAddress).then(function(balance) {
      assert.equal(balance.toString(10), '0');
    });
  }); 

  it('should resume the issuance of new tokens', function() {
    return tokenInstance.resumeIssuance().then(function(tx) {
      assert.equal(tx.receipt.status, true);
    });
  });

  it('should issue 50 tokens to the user', function() {
    return minerInstance.issue(ownerAccount, 50).then(function(tx) {
      assert.equal(tx.receipt.status, true);
    });
  });

  it('should return a balance of 50 kept in the miner contract', function() {
    return tokenInstance.balanceOf(minerContractAddress).then(function(balance) {
      assert.equal(balance.toString(10), '50');
    });
  }); 

  it('should set minimal user withdraw amount to 10', function() {
    return tokenInstance.setMinWithdrawAmount(10).then(function(tx) {
      assert.equal(tx.receipt.status, true);
    });
  });   

  it('should return a balance of 0 in the user account before token redeem', function() {
    return tokenInstance.balanceOf(accounts[3]).then(function(balance) {
      assert.equal(balance.toString(10), '0');
    });
  });  

  it('should withdraw 20 tokens to the user account', function() {
    return tokenInstance.withdraw(20).then(function(tx) {
      assert.equal(tx.receipt.status, true);
    });
  });  

  it('should return a balance of 3620 in the user account after token withdraw', function() {
    return tokenInstance.balanceOf(ownerAccount).then(function(balance) {
      assert.equal(balance.toString(10), '3820');
    });
  });          
});