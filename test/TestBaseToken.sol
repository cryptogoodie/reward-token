pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/BaseToken.sol";

contract TestBaseToken {

//    function testInitialBalanceUsingDeployedContract() {
//      BaseToken baseToken = BaseToken(DeployedAddresses.BaseToken());
//
//      uint expected = baseToken.totalSupply();
//
//      Assert.equal(baseToken.balanceOf(tx.origin), expected, "Owner should have all base tokens initially");
//    }

    function testInitialBalanceWithNewBasicToken() {
        BaseToken baseToken = new BaseToken();

        uint expected = baseToken.totalSupply();

        // not expected to work: it is not called by the owner
        Assert.equal(baseToken.balanceOf(address(this)), expected, "Owner should have all base tokens initially");
    }

}
