// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    address public manager;  // مدیر پروژه
    uint256 public targetAmount;  // هدف جمع‌آوری سرمایه
    uint256 public raisedAmount;  // مبلغ جمع‌آوری شده
    bool public isGoalAchieved;  // بررسی تحقق هدف
    mapping(address => uint256) public donations;  // ذخیره کمک‌های هر کاربر

    // رویدادهایی برای تراکنش‌ها
    event DonationReceived(address donor, uint256 amount);
    event GoalAchieved(uint256 amountRaised);
    event RefundIssued(address donor, uint256 amount);

    modifier onlyManager() {
        require(msg.sender == manager, "Only the manager can perform this action");
        _;
    }

    modifier goalNotAchieved() {
        require(!isGoalAchieved, "The goal has already been achieved");
        _;
    }

    modifier goalAchieved() {
        require(isGoalAchieved, "The goal has not been achieved yet");
        _;
    }

    constructor(uint256 _targetAmount) {
        manager = msg.sender;  // مدیر پروژه در زمان ایجاد قرارداد
        targetAmount = _targetAmount;
        raisedAmount = 0;
        isGoalAchieved = false;
    }

    // تابع برای ارسال کمک مالی به پروژه
    function donate(uint) external payable goalNotAchieved {
        require(msg.value > 0, "Donation must be greater than 0"); // بررسی مقدار ارسال شده
        donations[msg.sender] += msg.value;
        raisedAmount += msg.value;
        emit DonationReceived(msg.sender, msg.value);

        // بررسی اینکه آیا هدف جمع‌آوری سرمایه محقق شده است
        if (raisedAmount >= targetAmount && !isGoalAchieved) {
            isGoalAchieved = true;
            emit GoalAchieved(raisedAmount);
        }
    }

    // تابع برای برداشت وجوه توسط مدیر پروژه
    function withdraw() external onlyManager goalAchieved {
        uint256 amount = raisedAmount;
        raisedAmount = 0;
        payable(manager).transfer(amount);
    }

    // تابع برای بازپرداخت به کاربران در صورت عدم دستیابی به هدف
    function refund() external goalNotAchieved {
        uint256 donationAmount = donations[msg.sender];
        require(donationAmount > 0, "No funds to refund");
        
        donations[msg.sender] = 0;
        payable(msg.sender).transfer(donationAmount);

        emit RefundIssued(msg.sender, donationAmount);
    }
}
