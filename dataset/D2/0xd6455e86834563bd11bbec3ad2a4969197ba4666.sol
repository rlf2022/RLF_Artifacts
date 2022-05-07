pragma solidity ^0.4.24;

contract Owned {
    address public owner;

    constructor() 
    public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) 
        onlyOwner 
    public {
        owner = newOwner;
    }
}

/**
 * @title ReailtioSafeMath256
 * @dev Math operations with safety checks that throw on error
 */
library RealitioSafeMath256 {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/*
This contract allows you to split ETH between up to 100 receivers.

Each receiver can withdraw their own share of the funds without the cooperation of the others. 
They can also replace their own address with a different one.

The receivers can be added by the `owner` contract, for example a multisig wallet. 
The same receiver can be added multiple times if you want an unequal distribution.
Transfer ownership to 0x0 if you want to lock the receiver list and prevent further changes.

This contract receives ETH normally, without using extra gas that could cause incoming payments to fail.
Anyone can then call allocate() to assign any unassigned balance to the receivers.
The `allocate()` call may leave a small amount of ETH unassigned due to rounding. This can be allocated in a future call.

Once funds are allocated, each party can withdraw their own funds by calling `withdraw()`.
*/

contract SplitterWallet is Owned {

    // We sometimes loop over our recipient list, so set a maximum to avoid gas exhaustion
    uint256 constant MAX_RECIPIENTS = 100;

    using RealitioSafeMath256 for uint256;

    mapping(address => uint256) public balanceOf;
    
    // Sum of all balances in balanceOf
    uint256 public balanceTotal; 

    // List of recipients. May contain duplicates to get paid twice.
    address[] public recipients;

    event LogWithdraw(
        address indexed user,
        uint256 amount
    );

    function _firstRecipientIndex(address addr) 
        internal
    view returns (uint256) 
    {
        uint256 i;
        for(i=0; i 0, "No funds to allocate");

        uint256 num_recipients = recipients.length;

        // NB Rounding may leave some funds unallocated, we can claim them later
        uint256 each = unallocated / num_recipients;
        require(each > 0, "No money left to be allocated after rounding down");

        uint256 i;
        for (i=0; i= balanceTotal);

    }

    /// @notice Withdraw the address balance to the owner account
    function withdraw() 
    external {

        uint256 bal = balanceOf[msg.sender];
        require(bal > 0, "Balance must be positive");

        balanceTotal = balanceTotal.sub(bal);
        balanceOf[msg.sender] = 0;
        msg.sender.transfer(bal);

        emit LogWithdraw(msg.sender, bal);

        assert(address(this).balance >= balanceTotal);

    }

    function()
    external payable {
    }

}