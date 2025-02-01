// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract JointSavingsAccount {

    address public manager;  // مدیر صندوق
    address[] public members; // اعضای صندوق
    uint public requiredApprovals; // درصد تاییدیه‌های لازم برای برداشت

    mapping(address => bool) public isMember; // بررسی اینکه آیا آدرس عضو صندوق است یا خیر
    mapping(address => bool) public approvals; // تاییدیه‌های اعضا برای برداشت
    uint public balance; // موجودی صندوق

    event Deposited(address indexed member, uint amount);
    event Withdrawn(address indexed member, uint amount);
    event Approval(address indexed member, bool approved);

    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can perform this action");
        _;
    }

    modifier onlyMember() {
        require(isMember[msg.sender], "Only members can perform this action");
        _;
    }

    modifier validApprovals() {
        uint approvalsCount = 0;
        for (uint i = 0; i < members.length; i++) {
            if (approvals[members[i]]) {
                approvalsCount++;
            }
        }
        require(approvalsCount >= requiredApprovals, "Not enough approvals for withdrawal");
        _;
    }

    constructor(address[] memory _members, uint _requiredApprovals) {
        manager = msg.sender;  // مدیر را به عنوان سازنده قرارداد تنظیم می‌کنیم
        members = _members;
        requiredApprovals = _requiredApprovals;

        for (uint i = 0; i < _members.length; i++) {
            isMember[_members[i]] = true;  // اعضا را در سیستم ثبت می‌کنیم
        }
    }

    // واریز پول به صندوق
    function deposit() public payable onlyMember {
        require(msg.value > 0, "Deposit must be greater than 0");
        balance += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    // مشاهده موجودی صندوق
    function getBalance() public view returns (uint) {
        return balance;
    }

    // تایید یا رد برداشت توسط اعضا
    function approveWithdrawal() public onlyMember {
        approvals[msg.sender] = true;
        emit Approval(msg.sender, true);
    }

    // برداشت از صندوق
    function withdraw(uint amount) public onlyManager validApprovals {
        require(amount <= balance, "Insufficient funds");
        balance -= amount;
        payable(manager).transfer(amount);  // ارسال پول به مدیر صندوق
        emit Withdrawn(manager, amount);
    }

    // ریست تاییدیه‌ها پس از برداشت
    function resetApprovals() public onlyManager {
        for (uint i = 0; i < members.length; i++) {
            approvals[members[i]] = false;
        }
    }
}
