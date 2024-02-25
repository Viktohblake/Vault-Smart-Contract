// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

error INSUFFICIENT_FUNDS(string reason);
error AMOUNT_CANT_BE_ZERO(string reason);

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

    //  Function to create a grant
    function createGrant(address beneficiary, uint256 amount, uint256 claimTime) external payable {

        require(msg.sender != address(0), "Address cannot be zero");

        require(amount > 0, "Amount cannot be zero");

        require(msg.value == amount, "Deposit amount must equal the grant amount");

        require(claimTime > block.timestamp, "Claim time must be in the future");

        grants[msg.sender] = Grant(beneficiary, amount, claimTime, false);

        emit GrantCreated(msg.sender, beneficiary, amount, claimTime);
    }

    // Function for beneficiary to claim their grant
    function claimGrant() external {
        Grant storage grant = grants[msg.sender];

        require(!grant.claimed, "Grant has already been claimed");

        require(block.timestamp > grant.claimTime, "Claim time not yet reached");

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

      require(balance > 0, "Contract balance is insufficient");

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