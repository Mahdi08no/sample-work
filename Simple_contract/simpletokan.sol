// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleERC20 {
    string public name = "SimpleToken";  // نام توکن
    string public symbol = "STK";        // نماد توکن
    uint8 public decimals = 18;          // تعداد اعشار توکن‌ها
    uint256 public totalSupply;          // کل عرضه توکن‌ها

    // ذخیره موجودی هر کاربر
    mapping(address => uint256) public balanceOf;

    // رویداد انتقال توکن
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        balanceOf[msg.sender] = totalSupply; // ارسال تمام توکن‌ها به سازنده
    }

    // تابع انتقال توکن
    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(balanceOf[msg.sender] >= amount, "ERC20: transfer amount exceeds balance");

        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // تابع برای چک کردن موجودی یک آدرس خاص
    function getBalance(address account) public view returns (uint256) {
        return balanceOf[account];
    }
}
