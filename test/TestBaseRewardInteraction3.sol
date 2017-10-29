pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/BaseToken.sol";
import "../contracts/RewardToken.sol";
import '../zeppelin-solidity/contracts/math/SafeMath.sol';

contract TestBaseRewardInteraction3 {
    using SafeMath for uint256;

    function initTokens() returns (BaseToken, RewardToken) {
        BaseToken baseToken = new BaseToken();
        RewardToken rewardToken = new RewardToken();
        baseToken.setRewardTokenOwner(rewardToken);
        baseToken.setRewardStart(123);
        rewardToken.setBaseTokenOwner(baseToken);
        return (baseToken, rewardToken);
    }

    function testRewardForMethod() {
        var (baseToken, rewardToken) = initTokens();

        uint256 rew;

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
        // test fractions of periods
        Assert.equal(baseToken.rewardFor(123, 123 + ds / 5), 50000 / 5, "Reward for 1/5 period (start).");
        Assert.equal(baseToken.rewardFor(123 + 12345, 123 + 12345 + ds / 5), 50000 / 5, "Reward for 1/5 period (start).");
        Assert.equal(baseToken.rewardFor(123 + (ds * 4) / 5, 123 + ds ), 50000 / 5, "Reward for 1/5 period (end).");
        Assert.equal(baseToken.rewardFor(123 + ds, 123 + ds * 5 / 4 ), 44308 / 4, "Reward for 1/4  2nd period (end).");
        
        // test timespan that covers multiple - fractional - periods
        Assert.equal(baseToken.rewardFor(123 + (ds * 4) / 5, 123 + ds * 5 / 4 ), 50000 / 5 + 44308 / 4, "Reward for 1/5 1st and 1/4 2nd period (end).");
	
    }

}
