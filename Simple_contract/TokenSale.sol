// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenSale {

    address public owner; // صاحب قرارداد
    uint public tokenPrice; // قیمت هر توکن (در واحد ETH)
    uint public tokensForSale; // تعداد توکن‌های موجود برای فروش
    uint public tokensSold; // تعداد توکن‌های فروش رفته
    uint public saleStartTime; // زمان شروع فروش
    uint public saleEndTime; // زمان پایان فروش

    IERC20 public token; // ارجاع به قرارداد توکن

    // وضعیت فروش
    enum SaleStatus { NotStarted, Active, Ended, Failed }
    SaleStatus public saleStatus;

    event TokensPurchased(address indexed buyer, uint amount);
    event SaleStarted(uint startTime, uint endTime, uint price, uint totalTokens);
    event SaleEnded(uint totalTokensSold);
    event SaleFailed();

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyWhileSaleActive() {
        require(saleStatus == SaleStatus.Active, "Sale is not active");
        _;
    }

    modifier onlyAfterSaleEnded() {
        require(saleStatus == SaleStatus.Ended || saleStatus == SaleStatus.Failed, "Sale not ended yet");
        _;
    }

    modifier onlyBeforeSaleStart() {
        require(saleStatus == SaleStatus.NotStarted, "Sale already started");
        _;
    }

    constructor(address _tokenAddress) {
        owner = msg.sender;
        token = IERC20(_tokenAddress); // آدرس قرارداد توکن
        saleStatus = SaleStatus.NotStarted;
    }

    // شروع فروش توکن‌ها
    function startSale(uint _tokenPrice, uint _tokensForSale, uint _saleDuration) public onlyOwner onlyBeforeSaleStart {
        tokenPrice = _tokenPrice;
        tokensForSale = _tokensForSale;
        tokensSold = 0;
        saleStartTime = block.timestamp;
        saleEndTime = block.timestamp + _saleDuration;
        saleStatus = SaleStatus.Active;

        emit SaleStarted(saleStartTime, saleEndTime, tokenPrice, tokensForSale);
    }

    // خرید توکن
    function buyTokens(uint _amount) public payable onlyWhileSaleActive {
        require(block.timestamp >= saleStartTime && block.timestamp <= saleEndTime, "Sale period is over");
        require(_amount > 0, "Amount must be greater than zero");
        uint cost = _amount * tokenPrice;
        require(msg.value >= cost, "Not enough ETH sent");

        uint remainingTokens = tokensForSale - tokensSold;
        require(_amount <= remainingTokens, "Not enough tokens available");

        // انتقال توکن به خریدار
        token.transfer(msg.sender, _amount);
        tokensSold += _amount;

        // اگر ETH بیشتر از نیاز باشد، بازپرداخت به خریدار
        if (msg.value > cost) {
            payable(msg.sender).transfer(msg.value - cost);
        }

        emit TokensPurchased(msg.sender, _amount);
    }

    // پایان فروش
    function endSale() public onlyOwner onlyWhileSaleActive {
        require(block.timestamp > saleEndTime, "Sale has not ended yet");

        if (tokensSold >= tokensForSale) {
            saleStatus = SaleStatus.Ended;
            emit SaleEnded(tokensSold);
        } else {
            saleStatus = SaleStatus.Failed;
            emit SaleFailed();
        }
    }

    // بازپرداخت در صورت شکست فروش
    function refund() public onlyAfterSaleEnded {
        require(saleStatus == SaleStatus.Failed, "Sale was successful, no refunds");

        uint purchasedTokens = token.balanceOf(msg.sender);
        require(purchasedTokens > 0, "No tokens to refund");

        // بازگشت توکن‌ها به قرارداد
        token.transferFrom(msg.sender, address(this), purchasedTokens);

        // بازپرداخت ETH به خریدار
        uint refundAmount = purchasedTokens * tokenPrice;
        payable(msg.sender).transfer(refundAmount);
    }

    // برداشت موجودی توسط صاحب قرارداد
    function withdraw() public onlyOwner onlyAfterSaleEnded {
        require(saleStatus == SaleStatus.Ended, "Sale not ended yet");
        payable(owner).transfer(address(this).balance);
    }

    // مشاهده وضعیت فروش
    function getSaleDetails() public view returns (uint, uint, uint, uint, uint, uint) {
        return (tokenPrice, tokensForSale, tokensSold, saleStartTime, saleEndTime, uint(saleStatus));
    }
}

// قرارداد توکن ERC20 (برای استفاده در قرارداد TokenSale)
interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
}
