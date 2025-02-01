// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Whitelist {
    address public owner; // مالک قرارداد
    mapping(address => bool) private whitelistedAddresses; // ذخیره وضعیت لیست سفید

    // رویدادها
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event AddressAdded(address indexed user);
    event AddressRemoved(address indexed user);

    // مودیفایر برای محدود کردن دسترسی به مالک
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // سازنده برای تعیین مالک اولیه
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    // انتقال مالکیت به آدرس جدید
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner cannot be the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // اضافه کردن یک آدرس به لیست سفید
    function addToWhitelist(address user) external onlyOwner {
        require(!whitelistedAddresses[user], "Address is already whitelisted");
        whitelistedAddresses[user] = true;
        emit AddressAdded(user);
    }

    // حذف یک آدرس از لیست سفید
    function removeFromWhitelist(address user) external onlyOwner {
        require(whitelistedAddresses[user], "Address is not whitelisted");
        whitelistedAddresses[user] = false;
        emit AddressRemoved(user);
    }

    // بررسی اینکه آیا یک آدرس در لیست سفید قرار دارد یا خیر
    function isWhitelisted(address user) external view returns (bool) {
        return whitelistedAddresses[user];
    }
}
