// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Auction {
    address payable public owner;
    bool public isAuctionActive;

    struct Bidder {
        address payable addr;
        uint256 amount;
    }

    struct AuctionData {
        string title;
        uint256 minBid;
        uint256 closeTime;
        Bidder highestBid;
    }

    AuctionData public currentAuction;

    mapping(address => uint256) public pendingReturns;

    event AuctionCreated(string title, uint256 minBid, uint256 closeTime);
    event NewBid(address indexed bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);
    event AuctionCanceled();
    event FundsWithdrawn(address indexed bidder, uint256 amount);

    constructor() {
        owner = payable(msg.sender);
        isAuctionActive = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Permission denied: Only owner");
        _;
    }

    modifier auctionActive() {
        require(isAuctionActive, "Auction is not active");
        _;
    }

    modifier auctionInactive() {
        require(!isAuctionActive, "Auction already active");
        _;
    }

    function createAuction(
        string memory title, 
        uint256 minBid, 
        uint256 durationInSeconds
    ) external onlyOwner auctionInactive {
        require(durationInSeconds > 0, "Duration must be greater than 0");

        uint256 closeTime = block.timestamp + durationInSeconds;

        currentAuction = AuctionData({
            title: title,
            minBid: minBid,
            closeTime: closeTime,
            highestBid: Bidder(payable(address(0)), 0)
        });

        isAuctionActive = true;
        emit AuctionCreated(title, minBid, closeTime);
    }

    function makeBid() external payable auctionActive {
        require(block.timestamp < currentAuction.closeTime, "Auction has already ended");
        
        uint256 currentHighestAmount = currentAuction.highestBid.amount;

        if (currentHighestAmount == 0) {
            require(msg.value >= currentAuction.minBid, "Bid must be at least minimum bid");
        } else {
            require(msg.value > currentHighestAmount, "Bid must be higher than current highest bid");
            pendingReturns[currentAuction.highestBid.addr] += currentHighestAmount;
        }

        currentAuction.highestBid = Bidder(payable(msg.sender), msg.value);
        emit NewBid(msg.sender, msg.value);
    }

    function withdraw() external returns (bool) {
        uint256 amount = pendingReturns[msg.sender];
        require(amount > 0, "No funds to withdraw");

        pendingReturns[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            pendingReturns[msg.sender] = amount;
            return false;
        }

        emit FundsWithdrawn(msg.sender, amount);
        return true;
    }

    function endAuction() external auctionActive {
        require(
            msg.sender == owner || block.timestamp >= currentAuction.closeTime,
            "Cannot end auction yet (only owner can close before time)"
        );

        isAuctionActive = false;
        uint256 winningAmount = currentAuction.highestBid.amount;
        address winner = currentAuction.highestBid.addr;

        emit AuctionEnded(winner, winningAmount);

        if (winningAmount > 0) {
            (bool success, ) = owner.call{value: winningAmount}("");
            require(success, "Transfer to owner failed");
        }
    }

    function cancelAuction() external onlyOwner auctionActive {
        isAuctionActive = false;

        if (currentAuction.highestBid.amount > 0) {
            pendingReturns[currentAuction.highestBid.addr] += currentAuction.highestBid.amount;
        }

        emit AuctionCanceled();
    }
}