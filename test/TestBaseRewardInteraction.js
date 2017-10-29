import expectThrow from '../zeppelin-solidity/test/helpers/expectThrow';
var BaseToken = artifacts.require("../contracts/BaseToken.sol");
var RewardToken = artifacts.require("../contracts/RewardToken.sol");
var assert = require("assert");


contract('BaseRewardInteraction', function(accounts){
	const increaseTime = addSeconds => web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [addSeconds], id: 0})
  	var basetoken;
  	var rewardtoken;
	var owner   = accounts[0];
	var sender  = accounts[1];
	var receiver = accounts[2];
	var reward_owner   = accounts[3];

	beforeEach(function() {
		return BaseToken.new({from: owner})
		.then(function(instance){
			assert.ok(instance.address);
			basetoken=instance;
		}).then(function(){
			return RewardToken.new({from:reward_owner});
		}).then(function(rwinstance){
			assert.ok(rwinstance.address);
			rewardtoken=rwinstance;
			return basetoken.setRewardTokenOwner(rewardtoken.address);
		}).then(function(){
			return rewardtoken.setBaseTokenOwner(basetoken.address, {from:reward_owner});
		}).then(function(){
			return basetoken.setRewardStart(1);	
		});
	});

	it('should not allow to call the init functions any more times', function(){
		return expectThrow(basetoken.setRewardTokenOwner(sender, {from: owner}))
		.then(function(){
			return expectThrow(basetoken.setRewardStart(123, {from: owner}))})
		.then(function(){
			return expectThrow(rewardtoken.setBaseTokenOwner(sender, {from: reward_owner}))
		});
	});
	// TODO tests
});
