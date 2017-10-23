pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/BaseToken.sol";
import "../contracts/RewardToken.sol";
import '../zeppelin-solidity/contracts/math/SafeMath.sol';

contract TestBaseRewardInteraction {
    using SafeMath for uint256;

    function initTokens() returns (BaseToken, RewardToken) {
        BaseToken baseToken = new BaseToken();
        RewardToken rewardToken = new RewardToken();
        baseToken.setRewardTokenOwner(rewardToken);
        baseToken.setRewardStart(123);
        rewardToken.setBaseTokenOwner(baseToken);
        return (baseToken, rewardToken);
    }

    /* Test that Init methods can only be called once */
    function testBaseInitFunctionsCanBeCalledOnce() {
        var (baseToken, rewardToken) = initTokens();
        // TODO fails the second time
    }

    function testRewardForMethod() {
        var (baseToken, rewardToken) = initTokens();

        uint ds = 3 * 30 * 24 * 60 * 60;
        uint16[] storage rewardPerPeriod;
        rewardPerPeriod.push(50000);
        rewardPerPeriod.push(44308);
        rewardPerPeriod.push(39263);
        rewardPerPeriod.push(34793);
        rewardPerPeriod.push(30832);
        rewardPerPeriod.push(27322);
        rewardPerPeriod.push(24211);
        rewardPerPeriod.push(21455);
        rewardPerPeriod.push(19012);
        rewardPerPeriod.push(16847);
        rewardPerPeriod.push(14929);
        rewardPerPeriod.push(13230);
        rewardPerPeriod.push(11723);
        rewardPerPeriod.push(10389);
        rewardPerPeriod.push( 9206);
        rewardPerPeriod.push( 8158);
        rewardPerPeriod.push( 7229);
        rewardPerPeriod.push( 6406);
        rewardPerPeriod.push( 5677);
        rewardPerPeriod.push( 5030);

        // TODO add further reward calculcation tests here
        uint256 rew;
        for (uint8 p = 0; p < 19 /*rewardPerPeriod.length*/ ; p++) {
            rew = rew.add(rewardPerPeriod[p]);
            Assert.equal(
                baseToken.rewardFor(123, 123 + (p + 1) * ds), 
                rew, 
                "Reward for full periods should be correct."
            );
        }
    }

    function testRewardInitFunctionsCanBeCalledOnce() {
        BaseToken baseToken = new BaseToken();
        RewardToken rewardToken = new RewardToken();
        rewardToken.setBaseTokenOwner(baseToken);
        // TODO fails the second time
    }

}
