pragma solidity ^0.4.11;

import './BaseToken.sol';
import '../zeppelin-solidity/contracts/ownership/Ownable.sol';
import '../zeppelin-solidity/contracts/token/StandardToken.sol';
import '../zeppelin-solidity/contracts/math/SafeMath.sol';
//import 'github.com/OpenZeppelin/zeppelin-solidity/contracts/token/StandardToken.sol';
//import 'github.com/OpenZeppelin/zeppelin-solidity/contracts/ownership/Ownable.sol';
//import 'github.com/OpenZeppelin/zeppelin-solidity/contracts/math/SafeMath.sol';


contract RewardToken is StandardToken, Ownable {
    using SafeMath for uint256;

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }

    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = 'H1.2';

    address baseTokenOwner;

    uint256 claimedSupply; // reward size claimed so far

    function RewardToken() {
        name = "RewardCoin";
        decimals = 5;   // WARNING! do not change this without modifying reward calculation
        totalSupply = 25000000 * 4 * 100000;
        symbol = "REW";
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
    function setBaseTokenOwner(address _owner) onlyOwner {
        require(baseTokenOwner == address(0));
        baseTokenOwner = _owner;
    }
    /************************/

    /* Transfer the reward to the caller address */
    function claimMy() returns (bool success) {
        return claim(msg.sender);
    }

    /* Transfer the reward to the specified address */
    function claim(address _to) internal returns (bool success) {
        require(claimedSupply < totalSupply);
        BaseToken baseToken = BaseToken(baseTokenOwner);
        uint256 reward = baseToken.claimReward(_to);
        // cannot reward more than remaining supply (some reward may be lost this way)
        if (totalSupply.sub(claimedSupply) < reward) {
            reward = totalSupply.sub(claimedSupply);
        }
        claimedSupply = claimedSupply.add(reward);
        balances[_to] = balances[_to].add(reward);
        Transfer(0x0, _to, reward);
        return true;
    }

}
