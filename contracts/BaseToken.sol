pragma solidity ^0.4.11;

import '../zeppelin-solidity/contracts/token/StandardToken.sol';
import '../zeppelin-solidity/contracts/ownership/Ownable.sol';
import '../zeppelin-solidity/contracts/math/SafeMath.sol';
//import 'github.com/OpenZeppelin/zeppelin-solidity/contracts/token/StandardToken.sol';
//import 'github.com/OpenZeppelin/zeppelin-solidity/contracts/ownership/Ownable.sol';
//import 'github.com/OpenZeppelin/zeppelin-solidity/contracts/math/SafeMath.sol';


contract BaseToken is StandardToken, Ownable {
    using SafeMath for uint256;

    //struct Reward {
    //    uint value;
    //    uint timestamp;
    //}

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }

    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = 'H1.3';
    //uint32 public multiplier = 0.8861425;

    // address => struct mapping did not work for some reason
    //mapping (address => Reward) reward;
    mapping (address => uint) rewValue;
    mapping (address => uint) rewTimestamp;

    address rewardTokenOwner;    // reward coin owner
    uint rewardStart;   // start of the rewarding peroid

    uint constant ds = 3 * 30 * 24 * 60 * 60;    // period length in seconds (ca. 3 months in seconds)
    uint[] rewardPerPeriod;

    function BaseToken() {
        name = "BaseCoin";
        decimals = 4;   // WARNING! do not change this without modifying reward calculation
        balances[msg.sender] = 25000000 * 10000;
        totalSupply = 25000000 * 10000;
        symbol = "BASE";

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
    }

    /* Approves and then calls the receiving contract */
    // TODO: needed?
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }

    /************************/
    /*    Init functions    */
    /************************/
    function setRewardTokenOwner(address _owner) onlyOwner {
        require(rewardTokenOwner == address(0));
        rewardTokenOwner = _owner;
    }

    function setRewardStart(uint _start) onlyOwner {
        require(rewardStart == 0);
        rewardStart = _start;
    }
    /************************/

    /* Transfer the balance from owner's account to another account */
    function transfer(address _to, uint256 _value) returns (bool success) {
        uint rewFrom = calculateReward(msg.sender);
        uint rewTo = calculateReward(_to);
        if (!super.transfer(_to, _value)) {
            // if no transaction, then no change in reward
            return false;
        }
        if (rewFrom > 0) {
            // increase unclaimed reward
            rewValue[msg.sender] = rewValue[msg.sender].add(rewFrom);
            rewTimestamp[msg.sender] = now;
        }
        if (rewTo > 0) {
            // increase unclaimed reward
            rewValue[_to] = rewValue[_to].add(rewTo);
            rewTimestamp[_to] = now;
        }
    }

    /* Transfer the balance from one account to another account */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint rewFrom = calculateReward(_from);
        uint rewTo = calculateReward(_to);
        if (!super.transferFrom(_from, _to, _value)) {
            // if no transaction, then no change in reward
            return false;
        }
        if (rewFrom > 0) {
            // increase unclaimed reward
            rewValue[_from] = rewValue[_from].add(rewFrom);
            rewTimestamp[_from] = now;
        }
        if (rewTo > 0) {
            // increase unclaimed reward
            rewValue[_to] += rewValue[_to].add(rewTo);
            rewTimestamp[_to] = now;
        }
    }

    /* Disable reward calculation to save GAS */
    function disableMyReward() {
        rewTimestamp[msg.sender] = rewardStart + 100 * ds;
    }

    /* Enable reward calculation starting now */
    function enableMyReward() {
        rewTimestamp[msg.sender] = now;
    }

    /* Internal: calculate the reward for
     * - one base coin
     * - for the period between t1 and t2 */
    // TODO: visible only for testing, make it internal later
    function rewardFor(uint t1, uint t2) constant returns (uint reward) {
        uint p1 = (t1 - rewardStart) / ds;
        uint p2 = (t2 - rewardStart) / ds;
        assert(p2 >= p1);
        if (p1 == p2) {
            // same period
            return (t2 - t1) / ds * rewardPerPeriod[p1];
        } else {
            uint p1start = rewardStart + p1 * ds;
            uint p2start = rewardStart + p2 * ds;
            assert(p2start >= p1start);
            reward = (t1 - p1start) / ds * rewardPerPeriod[p1];
            for (uint p = p1; p < p2; p++) {
                reward += rewardPerPeriod[p];
            }
            reward += (t2 - p2start) / ds * rewardPerPeriod[p2];
            return reward;
        }
    }

    function calculateReward(address _toAddr) constant returns (uint256 reward) {
        if (rewardStart <= 0 || now < rewardStart) {
            return 0;
        }
        // max(previous reward update time, rewardStart)
        uint _from = rewTimestamp[_toAddr];
        if (_from == 0) {
            _from = rewardStart;
        }
        // min(now, end of reward period)
        uint _to = now;
        if (now > rewardStart + 20 * ds) {
            _to = rewardStart + 20 * ds;
        }
        // divide by 10000, because of 4 decimals for base coin
        return balanceOf(_toAddr) * rewardFor(_from, _to) / 10000;
    }

    function claimReward(address _to) returns (uint256 reward) {
        // call by the reward token contract owner
        require(msg.sender == rewardTokenOwner);
        require(rewardStart > 0 && rewardStart < now);
        uint rew = rewValue[_to].add(calculateReward(_to));
        // all reward has been claimed
        rewValue[_to] = 0;
        rewTimestamp[_to] = now;
        return rew;
    }

}

