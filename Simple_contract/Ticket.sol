// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AirplaneTicketSale {

    struct Flight {
        uint id;
        string destination;
        uint date;
        uint capacity;
        uint ticketsSold;
    }

    address public owner;  // صاحب قرارداد (مدیر سیستم)
    uint public flightIdCounter;  // شمارنده برای شناسه پروازها
    mapping(uint => Flight) public flights;  // پروازهای موجود
    mapping(address => mapping(uint => uint)) public userTickets;  // بلیط‌های خریداری شده توسط هر کاربر (پرواز و تعداد)

    event FlightAdded(uint flightId, string destination, uint date, uint capacity);
    event TicketPurchased(address indexed buyer, uint flightId, uint amount);
    event TicketCancelled(address indexed buyer, uint flightId, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier validFlight(uint flightId) {
        require(flights[flightId].id != 0, "Invalid flight ID");
        _;
    }

    modifier hasAvailableTickets(uint flightId, uint amount) {
        require(flights[flightId].capacity >= flights[flightId].ticketsSold + amount, "Not enough tickets available");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // ثبت پرواز جدید
    function addFlight(string memory _destination, uint _date, uint _capacity) public onlyOwner {
        flightIdCounter++;
        flights[flightIdCounter] = Flight(flightIdCounter, _destination, _date, _capacity, 0);
        emit FlightAdded(flightIdCounter, _destination, _date, _capacity);
    }

    // خرید بلیط
    function purchaseTicket(uint flightId, uint amount) public payable validFlight(flightId) hasAvailableTickets(flightId, amount) {
        uint ticketPrice = 0.1 ether;  // قیمت بلیط (می‌تواند متغیر باشد)
        uint totalCost = ticketPrice * amount;
        require(msg.value >= totalCost, "Insufficient funds");

        flights[flightId].ticketsSold += amount;
        userTickets[msg.sender][flightId] += amount;
        emit TicketPurchased(msg.sender, flightId, amount);

        // بازگشت مابقی وجه
        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }
    }

    // لغو بلیط
    function cancelTicket(uint flightId, uint amount) public validFlight(flightId) {
        require(userTickets[msg.sender][flightId] >= amount, "You don't have enough tickets to cancel");

        uint ticketPrice = 0.1 ether;  // قیمت بلیط (می‌تواند متغیر باشد)
        uint refundAmount = ticketPrice * amount;
        require(refundAmount > 0, "Invalid cancel amount");

        flights[flightId].ticketsSold -= amount;
        userTickets[msg.sender][flightId] -= amount;

        payable(msg.sender).transfer(refundAmount);
        emit TicketCancelled(msg.sender, flightId, amount);
    }

    // مشاهده جزئیات پرواز
    function getFlightDetails(uint flightId) public view validFlight(flightId) returns (string memory, uint, uint, uint, uint) {
        Flight memory flight = flights[flightId];
        return (flight.destination, flight.date, flight.capacity, flight.ticketsSold, flight.capacity - flight.ticketsSold);
    }

    // مشاهده تعداد بلیط‌های خریداری‌شده توسط کاربر
    function getUserTickets(uint flightId) public view validFlight(flightId) returns (uint) {
        return userTickets[msg.sender][flightId];
    }

    // مشاهده موجودی قرارداد
    function contractBalance() public view returns (uint) {
        return address(this).balance;
    }

    // برداشت موجودی توسط صاحب قرارداد
    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
