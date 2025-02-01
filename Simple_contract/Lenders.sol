// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LendingBorrowing {
    struct Loan {
        address borrower;
        uint256 amount;
        uint256 collateral;
        uint256 interestRate;
        uint256 dueDate;
        bool repaid;
    }

    mapping(address => uint256) public lendersBalance;
    mapping(uint256 => Loan) public loans;
    uint256 public loanCounter;
    uint256 public collateralRatio = 150; // 150% collateral

    event LoanRequested(uint256 loanId, address borrower, uint256 amount, uint256 collateral);
    event LoanRepaid(uint256 loanId, address borrower, uint256 amount);

    function depositFunds() external payable {
        require(msg.value > 0, "Must deposit some Ether");
        lendersBalance[msg.sender] += msg.value;
    }

    function requestLoan(uint256 amount, uint256 collateral) external payable {
        require(amount > 0, "Loan amount must be greater than zero");
        require(msg.value >= collateral, "Insufficient collateral provided");
        require(collateral >= (amount * collateralRatio) / 100, "Collateral must meet the ratio requirement");

        loans[loanCounter] = Loan({
            borrower: msg.sender,
            amount: amount,
            collateral: msg.value,
            interestRate: 10, // 10% interest
            dueDate: block.timestamp + 30 days,
            repaid: false
        });

        loanCounter++;
        emit LoanRequested(loanCounter - 1, msg.sender, amount, msg.value);
    }

    function fundLoan(uint256 loanId) external {
        Loan storage loan = loans[loanId];
        require(lendersBalance[msg.sender] >= loan.amount, "Insufficient funds to fund the loan");
        require(!loan.repaid, "Loan already repaid");

        lendersBalance[msg.sender] -= loan.amount;
        payable(loan.borrower).transfer(loan.amount);
    }

    function repayLoan(uint256 loanId) external payable {
        Loan storage loan = loans[loanId];
        require(msg.sender == loan.borrower, "Only borrower can repay");
        require(!loan.repaid, "Loan already repaid");
        require(block.timestamp <= loan.dueDate, "Loan due date has passed");

        uint256 repaymentAmount = loan.amount + (loan.amount * loan.interestRate) / 100;
        require(msg.value >= repaymentAmount, "Insufficient repayment amount");

        loan.repaid = true;
        lendersBalance[address(this)] += msg.value;
        payable(msg.sender).transfer(loan.collateral);

        emit LoanRepaid(loanId, msg.sender, msg.value);
    }

    function liquidateLoan(uint256 loanId) external {
        Loan storage loan = loans[loanId];
        require(block.timestamp > loan.dueDate, "Loan is not overdue");
        require(!loan.repaid, "Loan already repaid");

        payable(address(this)).transfer(loan.collateral);
        delete loans[loanId];
    }
}
