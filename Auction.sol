// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.13;

// contract Auction {
//     address private owner;
//     AuctionData currentAuction;
//     bool _isAuctionExist = false;


    

//     struct MaxBet {
//         address payable binder;
//         uint256 ammount;
//     }

//     struct AuctionData {
//         string title;
//         uint256 minBet;
//         uint256 closeTime;
//         MaxBet maxBet;
//     }

//     constructor() {
//         owner = msg.sender;
//         _isAuctionExist = false;
//     }

//     modifier isOwner() {
//         require(msg.sender == owner, "Permission denied");
//         _;
//     }

//     modifier isAuctionExist() {
//         require(msg.sender == owner, "Permission denied");
//         _;
//     }



//     function createAuction(string memory title, uint256 minBet, uint256 closeTime) public isOwner {
//         require(closeTime > block.timestamp, "Wrong 'closeTime' must be later then now.");
//         currentAuction = AuctionData(title, minBet, closeTime, MaxBet(payable(0), 0));
//         _isAuctionExist = true;
//     }

//     function makeBind() isAuctionExist payable public {
//         require(msg.value > currentAuction.maxBet.ammount, "Your bind smaller then current max bind");


//     }

//     function endAuction() isOwner payable public {
//         (bool isSuccess, ) = payable(currentAuction.maxBet.binder).call({ value: currentAuction.maxBet.binder.ammount })("");

//     } 




// }