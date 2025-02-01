pragma solidity 0.5.16;

// رابط استاندارد BEP-20 برای تعریف توکن
interface IBEP20 {

  function totalSupply() external view returns (uint256); // تعداد کل توکن‌ها
  function decimals() external view returns (uint8); // تعداد اعشار توکن
  function symbol() external view returns (string memory); // نماد توکن
  function name() external view returns (string memory); // نام توکن
  function getOwner() external view returns (address); // آدرس مالک قرارداد
  function balanceOf(address account) external view returns (uint256); // موجودی یک آدرس
  function transfer(address recipient, uint256 amount) external returns (bool); // انتقال توکن
  function allowance(address _owner, address spender) external view returns (uint256); // مقدار مجاز برای خرج
  function approve(address spender, uint256 amount) external returns (bool); // تایید خرج توکن
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool); // انتقال توسط مجوز

  event Transfer(address indexed from, address indexed to, uint256 value); // رویداد انتقال
  event Approval(address indexed owner, address indexed spender, uint256 value); // رویداد تایید
}

// قرارداد برای دسترسی به اطلاعات فرستنده و داده‌های تراکنش
contract Context {
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender; // آدرس فرستنده تراکنش
  }

  function _msgData() internal view returns (bytes memory) {
    this; 
    return msg.data; // داده‌های تراکنش
  }
}

// کتابخانه برای محاسبات امن
library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow"); // جلوگیری از سرریز در جمع
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow"); // جلوگیری از کم‌ریزی در تفریق
    return a - b;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) return 0; // اگر یکی از مقادیر صفر باشد
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow"); // جلوگیری از سرریز در ضرب
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: division by zero"); // جلوگیری از تقسیم بر صفر
    return a / b;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "SafeMath: modulo by zero"); // جلوگیری از باقیمانده صفر
    return a % b;
  }
}

// مدیریت مالکیت قرارداد
contract Ownable is Context {
  address private _owner; // آدرس مالک

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner); // رویداد تغییر مالکیت

  constructor () internal {
    _owner = _msgSender(); // تعیین مالک اولیه
    emit OwnershipTransferred(address(0), _owner);
  }

  function owner() public view returns (address) {
    return _owner; // بازگرداندن آدرس مالک
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner"); // بررسی مالکیت
    _;
  }

  function renounceOwnership() public onlyOwner {
    _owner = address(0); // صرف نظر از مالکیت
    emit OwnershipTransferred(_owner, address(0));
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address"); // آدرس جدید نباید صفر باشد
    _owner = newOwner; // تغییر مالک
    emit OwnershipTransferred(_owner, newOwner);
  }
}

// قرارداد اصلی توکن
contract BEP20XRP is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances; // موجودی حساب‌ها
  mapping (address => mapping (address => uint256)) private _allowances; // مجوز خرج

  uint256 private _totalSupply; // تعداد کل توکن‌ها
  uint8 public _decimals; // تعداد اعشار
  string public _symbol; // نماد توکن
  string public _name; // نام توکن

  constructor() public {
    _name = "XRP Token"; // تعریف نام توکن
    _symbol = "XRP"; // تعریف نماد توکن
    _decimals = 18; // تعریف تعداد اعشار
    _totalSupply = 42000000 * 10**18; // تعداد کل توکن‌ها
    _balances[msg.sender] = _totalSupply; // تخصیص تمام توکن‌ها به سازنده قرارداد

    emit Transfer(address(0), msg.sender, _totalSupply); // رویداد انتقال اولیه
  }

  // توابع اصلی BEP-20
  function decimals() external view returns (uint8) { return _decimals; } // تعداد اعشار
  function symbol() external view returns (string memory) { return _symbol; } // نماد
  function name() external view returns (string memory) { return _name; } // نام
  function totalSupply() external view returns (uint256) { return _totalSupply; } // کل عرضه
  function balanceOf(address account) external view returns (uint256) { return _balances[account]; } // موجودی آدرس

  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), recipient, amount); // انتقال توکن
    return true;
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount); // تایید خرج
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount); // انتقال با مجوز
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount)); // کاهش مجوز
    return true;
  }

  // توابع کمکی داخلی
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from zero address"); // بررسی آدرس فرستنده
    require(recipient != address(0), "BEP20: transfer to zero address"); // بررسی آدرس گیرنده
    _balances[sender] = _balances[sender].sub(amount); // کاهش موجودی فرستنده
    _balances[recipient] = _balances[recipient].add(amount); // افزایش موجودی گیرنده
    emit Transfer(sender, recipient, amount); // ثبت رویداد
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from zero address"); // بررسی آدرس مالک
    require(spender != address(0), "BEP20: approve to zero address"); // بررسی آدرس گیرنده مجوز
    _allowances[owner][spender] = amount; // تنظیم مقدار مجاز
    emit Approval(owner, spender, amount); // ثبت رویداد
  }
}
