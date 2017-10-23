pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/RewardToken.sol";

contract TestRewardToken {

//  function testInitialBalanceUsingDeployedContract() {
//    RewardToken rewardToken = RewardToken(DeployedAddresses.RewardToken());
//
//    uint expected = 0;
//
//    Assert.equal(rewardToken.balanceOf(tx.origin), expected, "Owner should have 0 reward coin initially");
//  }

    function testInitialBalanceWithNewRewardToken() {
        RewardToken rewardToken = new RewardToken();

        uint expected = 0;

        Assert.equal(rewardToken.balanceOf(address(this)), expected, "Owner should have 0 reward coin initially");
    }

}
