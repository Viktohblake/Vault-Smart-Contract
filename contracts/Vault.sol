// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

error INSUFFICIENT_FUNDS();
error AMOUNT_CANT_BE_ZERO();
error GRANT_AMOUNT_MUST_EQUAL_DEPOSIT();
error CLAIM_TIME_NOT_REACHED();
error CLAIM_TIME_MUST_BE_IN_FUTURE();
error GRANT_CLAIMED();
error ADDRESS_CANT_BE_ZERO();

contract Vault {

  address owner;

    struct Grant {
        address beneficiary;
        uint256 amount;
        uint256 claimTime;
        bool claimed;
    }

    mapping(address => Grant) grants;

    event GrantCreated(address indexed donor, address indexed beneficiary, uint256 amount, uint256 claimTime);

    event GrantClaimed(address indexed beneficiary, uint256 amount);

    // Function to create a grant
    function createGrant(address beneficiary, uint256 amount, uint256 claimTime) external payable {

        if(msg.sender == address(0))
          revert ADDRESS_CANT_BE_ZERO();

        if (amount<= 0 )
          revert AMOUNT_CANT_BE_ZERO();
        
        if (msg.value != amount) 
          revert GRANT_AMOUNT_MUST_EQUAL_DEPOSIT();

        if (claimTime < block.timestamp) 
            revert CLAIM_TIME_MUST_BE_IN_FUTURE();
          
        grants[msg.sender] = Grant(beneficiary, amount, claimTime, false);

        emit GrantCreated(msg.sender, beneficiary, amount, claimTime);
    }

    // Function for beneficiary to claim their grant
    function claimGrant() external {
        Grant storage grant = grants[msg.sender];

        if (grant.claimed)
            revert GRANT_CLAIMED();

        if(block.timestamp <= grant.claimTime)
          revert CLAIM_TIME_NOT_REACHED();

        payable(msg.sender).transfer(grant.amount);
        grant.claimed = true;

        emit GrantClaimed(msg.sender, grant.amount);
    }

    function getBeneficiaryGrant(address _beneficiary) external view returns (address beneficiary, uint256 amount, uint256 claimTime, bool claimed){
        Grant storage grant = grants[_beneficiary];

        return (grant.beneficiary, grant.amount, grant.claimTime, grant.claimed);
    }

    function ownerWithdraw() external onlyOwner payable {
      
      uint balance = address(this).balance;

      if (balance <= 0) 
        revert INSUFFICIENT_FUNDS();

      payable(address(this)).transfer(balance);
    }

    function checkContractBal() external view returns (uint256) {
      return address(this).balance;
    }


    modifier onlyOwner() {
      require(msg.sender == owner);
      _;
    }
}