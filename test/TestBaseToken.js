import expectThrow from '../zeppelin-solidity/test/helpers/expectThrow';
var BaseToken = artifacts.require("../contracts/BaseToken.sol");
var assert = require("assert");

contract('BaseToken', function(accounts){
  	var basetoken;
	var owner   = accounts[0];
	var sender  = accounts[1];
	var receiver = accounts[2];

	beforeEach(function() {
		return BaseToken.new({from: owner})
		.then(function(instance){
			assert.ok(instance.address);
			basetoken=instance;
		}).then(function(){
			basetoken.setRewardTokenOwner(accounts[9]);
		}).then(function(){
			basetoken.setRewardStart(0);	
		});
	});

        it('should test that the BaseToken contract can be deployed', function(done){
		  BaseToken.new().then(function(instance){
	                    assert.ok(instance.address);
		  }).then(done);
	});
        it('should not allow to call the init functions by other than the owner', function(){
		var contract;
		return BaseToken.new({from: owner}).then(function(instance){
			contract=instance;
			assert.ok(contract.address);
			expectThrow(contract.setRewardTokenOwner(sender, {from: sender}))
		}).then(function(){
			expectThrow(contract.setRewardStart(1, {from: sender}));
		});
	});
        it('should allow to call the setRewardToken transaction only once', function(){
		var contract;
		return BaseToken.new({from: owner}).then(function(instance){
			contract=instance;
			assert.ok(contract.address);
			contract.setRewardTokenOwner(sender, {from: owner});
		}).then(function(){
			expectThrow(contract.setRewardTokenOwner(sender, {from: owner}));
		});
	});
        it('should allow to call the setRewardStart transaction only once', function(){
		var contract;
		return BaseToken.new({from: owner}).then(function(instance){
			contract=instance;
			assert.ok(contract.address);
			contract.setRewardStart(1, {from: owner});
		}).then(function(){
			expectThrow(contract.setRewardStart(1, {from: owner}));
		});
	});
	it('should test that the BaseToken contract is deployed by the correct default address', function(done){
		basetoken.owner.call().then(function(owneraddress) {
                assert.equal(owneraddress, owner, 'BaseToken is not owned by the defauilt address');
                }).then(done);
        });
	it('should test that the BaseToken contract is deployed by the correct address (using from)', function(done){
               BaseToken.new({from: sender}).then(function(instance){
		instance.owner.call().then(function(owneraddress) {
                    assert.equal(owneraddress, sender, 'BaseToken not owned by the set sender address');
                }).then(done);
            });
        });
	it('should test that the owner got allocated with all the BaseToken', function(done){
		var totalsupply, balance;
		basetoken.totalSupply.call().then(function(supply) {
			totalsupply=supply;
			return basetoken.balanceOf.call(owner);
		}).then(function(bal){
			balance=bal;
                    	assert.equal(balance.valueOf(), totalsupply.valueOf(), 'Not all basetokens were allocated to the owner account');
		}).then(done);
        });

	[ 1, 2, 3, 4, 5, 6 ,7, 8, 9 ].forEach(value => {
		  it(`should return 0 for account ${ value } balance`, () => {
                  	basetoken.balanceOf(accounts[value]).then(function(accountbalance){
					assert.equal(accountbalance.valueOf(), 0, 'Account ' + value + '  got allocated with more than 0 basetokens when it should have 0.');
			    });
	});});

	it("should send coin correctly", function() {
    
		var contract;

		// Get initial balances of first and second account.
		var account_one = accounts[0];
		var account_two = accounts[1];
		var account_three = accounts[2];

    		var account_one_starting_balance;
    		var account_two_starting_balance;
    		var account_one_ending_balance;
    		var account_two_ending_balance;

    		var amount = 10000;

     		contract = basetoken;
      		return contract.balanceOf.call(account_one)
    		.then(function(balance) {
			account_one_starting_balance = balance.toNumber();
		}).then(function(){
			// try negative transfer
			expectThrow(contract.transfer(account_one, -50, {from: account_three}));
		}).then(function(){
			// try transfer from 0 balance
			expectThrow(contract.transfer(account_two, 50, {from: account_three}));
		}).then(function(){
			// try transfer to self 
			return contract.transfer(account_one, 5000, {from: account_one});
	 	}).then(function(){
			return contract.balanceOf.call(account_two);
		}).then(function(balance) {
			account_two_starting_balance = balance.toNumber();
			return contract.transfer(account_two, amount, {from: account_one});
		}).then(function() {
			// try to tx more than balance
			expectThrow(contract.transfer(account_three, amount+1, {from: account_two}));
		}).then(function() {
			// transfer all to acc3
			contract.transfer(account_three, amount, {from: account_two});
		}).then(function() {
			// .. then back to acc2
			contract.transfer(account_two, amount, {from: account_three});
		}).then(function() {
			return contract.balanceOf.call(account_one);
		}).then(function(balance) {
			account_one_ending_balance = balance.toNumber();
			return contract.balanceOf.call(account_two);
		}).then(function(balance) {
			account_two_ending_balance = balance.toNumber();

			assert.equal(account_one_ending_balance, account_one_starting_balance - amount, "Amount wasn't correctly taken from the sender");
			assert.equal(account_two_ending_balance, account_two_starting_balance + amount, "Amount wasn't correctly sent to the receiver");
		});
	});

    	it("should handle ERC allowance", function () {
		var amount=10000;
        	return basetoken.approve(sender, amount, {from: owner})
        	.then(function () {
                	return basetoken.allowance.call(owner, sender);
            	}).then(function (allowance) {
                	assert.equal(allowance, amount, "allowance should be "+amount);
                	return expectThrow(basetoken.transferFrom(owner, receiver, amount+1, {from: sender}));
            	}).then(function () {
            		return basetoken.balanceOf.call(receiver);
           	}).then(function (balance) {
                	assert.equal(balance.valueOf(), 0, "balance should be uncanged should not go through");
                	return basetoken.transferFrom(owner, receiver, amount, {from: sender});
            	}).then(function () {
                	return basetoken.balanceOf.call(receiver)
            	}).then(function (balance) {
                	assert.equal(balance, amount, "the balance should be "+amount +"instead of "+balance)
                	return basetoken.allowance.call(owner, sender);
            	}).then(function (allowance) {
                	assert.equal(allowance, 0, "allowance should be 0");
		});
	});
    	
});
