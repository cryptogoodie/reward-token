pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/BaseToken.sol";
import "../contracts/RewardToken.sol";
import '../zeppelin-solidity/contracts/math/SafeMath.sol';

contract TestBaseRewardInteraction2 {
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

        // test rewards before start
	Assert.equal(baseToken.rewardFor(0, 123), 0, "Reward before start is not 0 (case 1).");
	Assert.equal(baseToken.rewardFor(100, 123), 0, "Reward before start is not 0 (case 3).");
        
        // test rewards after reward payment is over
        Assert.equal(baseToken.rewardFor(123 + rewardPerPeriod.length * ds, 123 + (rewardPerPeriod.length + 10) * ds ), 0, "Reward after end should be 0.");
        rew=baseToken.rewardFor(55555, 123 + rewardPerPeriod.length * ds); // get full reward from givent time as reference
        Assert.equal(baseToken.rewardFor(55555, 123 + rewardPerPeriod.length * ds + 1), rew, "Reward after end should not increase (case 1).");
        Assert.equal(baseToken.rewardFor(55555, 123 + rewardPerPeriod.length * ds + 10000000000), rew, "Reward after end should not increase (case 1).");

        // test 0 timediff rewards 
        Assert.equal(baseToken.rewardFor(122, 122), 0, "Reward for 0 time should be always 0 (beforestart).");
        Assert.equal(baseToken.rewardFor(123, 123), 0, "Reward for 0 time should be always 0 (atstart).");
        Assert.equal(baseToken.rewardFor(123 + ds + 1, 123 + ds + 1), 0, "Reward for 0 time should be always 0 (in the middle).");
        Assert.equal(baseToken.rewardFor(123 + rewardPerPeriod.length * ds, 123 + rewardPerPeriod.length * ds), 0, "Reward for 0 time should be always 0 (at the end).");
        Assert.equal(baseToken.rewardFor(123 + rewardPerPeriod.length * ds + 100, 123 + rewardPerPeriod.length * ds + 100 ), 0, "Reward for 0 time should be always 0 (atfter the end).");
    }   
}

