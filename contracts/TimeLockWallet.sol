// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./BaseRelayRecipient.sol";

contract TimeLockWallet is BaseRelayRecipient {
using SafeERC20 for IERC20;

    IERC20 token;
    address beneficiary;
    uint256 endsAt;
    address creator;
    uint256 createdAt;
    modifier onlyOwner {
        require(_msgSender() == beneficiary, "Unauthorized");
        _;
    }

    function init(
        IERC20 _token,
        address _beneficiary,
        uint256 _endsAt,
        address _creator,
        address forwarder
    ) external{
        require(
            _endsAt > block.timestamp,
            "TokenTimelock: release time is before current time"
        );
        token = _token;
        beneficiary = _beneficiary;
        creator =  _creator;
        createdAt = block.timestamp;
        endsAt = _endsAt;
        _trustedForwarder = forwarder;
    }

    receive () external payable {}

    function getEtherBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getToken() public view virtual returns (IERC20) {
        return token;
    }
    
    function getBeneficiary() public view virtual returns (address) {
        return beneficiary;
    }

    function getCreator() public view virtual returns (address) {
        return creator;
    }

    function getCreatedTime() public view virtual returns (uint256) {
        return createdAt;
    }
    
    function getEndsAt() public view virtual returns (uint256) {
        return endsAt;
    }

     function setTrustedForwarder(address forwarder) public onlyOwner{
        _trustedForwarder = forwarder;
    }

    function releaseToken() public virtual onlyOwner {
        // solhint-disable-next-line not-rely-on-time
        require(
            block.timestamp >= endsAt,
            "TimeLock:Can't withdraw before releasing time"
        );
        uint256 amount = getToken().balanceOf(address(this));
        require(amount > 0, "TokenTimelock: no tokens to release");
        getToken().transfer(getBeneficiary(), amount);
    }

    function releaseEther() public onlyOwner {
        // solhint-disable-next-line not-rely-on-time
        require(
            block.timestamp >= getEndsAt(),
            "TimeLock:Can't withdraw before releasing time"
        );
        uint256 amount = address(this).balance;
        require(amount > 0, "No Ether to release");
        payable(_msgSender()).transfer(amount);
    }
     function getWalletInfo()
        public
        view
        returns (
            address,
            address,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            beneficiary,
            creator,
            endsAt,
            address(this).balance,
            getToken().balanceOf(address(this))
        );
    }

    function versionRecipient() external pure override returns (string memory) {
        return "1";
    }
}
