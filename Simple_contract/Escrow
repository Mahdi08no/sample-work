// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Escrow {
    address public buyer; // خریدار
    address public seller; // فروشنده
    address public arbitrator; // واسطه
    uint256 public escrowBalance; // موجودی قرارداد
    bool public isTransactionComplete; // وضعیت تکمیل معامله

    // رویدادها
    event FundsDeposited(address indexed buyer, uint256 amount);
    event DeliveryConfirmed(address indexed buyer);
    event DisputeResolved(address indexed arbitrator, address recipient, uint256 amount);
    event FundsRefunded(address indexed buyer, uint256 amount);

    // مودیفایرها
    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only the buyer can perform this action");
        _;
    }

    modifier onlyArbitrator() {
        require(msg.sender == arbitrator, "Only the arbitrator can perform this action");
        _;
    }

    modifier transactionIncomplete() {
        require(!isTransactionComplete, "The transaction is already complete");
        _;
    }

    constructor(address _seller, address _arbitrator) {
        buyer = msg.sender;
        seller = _seller;
        arbitrator = _arbitrator;
        escrowBalance = 0;
        isTransactionComplete = false;
    }

    // تابع برای واریز پول توسط خریدار
    function depositFunds() external payable onlyBuyer transactionIncomplete {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        escrowBalance += msg.value;
        emit FundsDeposited(msg.sender, msg.value);
    }

    // تابع برای تأیید دریافت محصول توسط خریدار
    function confirmDelivery() external onlyBuyer transactionIncomplete {
        require(escrowBalance > 0, "No funds available for transfer");

        isTransactionComplete = true;
        uint256 amount = escrowBalance;
        escrowBalance = 0;
        payable(seller).transfer(amount);

        emit DeliveryConfirmed(msg.sender);
    }

    // تابع برای بازپرداخت پول به خریدار
    function refund() external onlyBuyer transactionIncomplete {
        require(escrowBalance > 0, "No funds available for refund");

        uint256 amount = escrowBalance;
        escrowBalance = 0;
        payable(buyer).transfer(amount);

        emit FundsRefunded(buyer, amount);
    }

    // تابع برای حل اختلاف توسط واسطه
    function resolveDispute(address _recipient) external onlyArbitrator transactionIncomplete {
        require(_recipient == buyer || _recipient == seller, "Recipient must be buyer or seller");
        require(escrowBalance > 0, "No funds available for resolution");

        uint256 amount = escrowBalance;
        escrowBalance = 0;
        payable(_recipient).transfer(amount);

        isTransactionComplete = true;
        emit DisputeResolved(msg.sender, _recipient, amount);
    }

    // تابع برای دریافت موجودی قرارداد
    function getBalance() external view returns (uint256) {
        return escrowBalance;
    }
}
