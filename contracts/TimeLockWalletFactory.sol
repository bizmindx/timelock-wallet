// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./TimeLockWallet.sol";
import "./CloneFactory.sol";


contract TimeLockWalletFactory is CloneFactory, Ownable {
    // TimeLockWallet public newWallet;
    address public relayer;
    mapping(address => address[]) wallets;
    address payable masterContract;

    event Created(
        address indexed wallet,
        address indexed beneficiary,
        address creator,
        uint256 endsAt,
        uint256 createdAt,
        uint256 amount
    );


    constructor(address payable _masterContract, address _relayer) {
        masterContract = _masterContract;
        relayer = _relayer;
    }

     function setRelayer(address _relayer) public onlyOwner {
                relayer = _relayer;
    }

    function createNewWallet(
        IERC20 token,
        address beneficiary,
        uint256 endsAt
    ) public payable returns (bool) {
       
        TimeLockWallet timeLockWallet = TimeLockWallet(createClone(masterContract));

         timeLockWallet.init(
           token,
            beneficiary,
            endsAt,
            _msgSender(),
            relayer
        );

        wallets[beneficiary].push(address(timeLockWallet));

        emit Created(
            address(timeLockWallet),
            beneficiary,
            _msgSender(),
            endsAt,
            block.timestamp,
            msg.value
        );
        return true;
    }

    function getWallets(address owner)
        public
        view
        returns (address[] memory)
    {
        return wallets[owner];
    }
    
    receive() external payable {
        revert();
    }
}
