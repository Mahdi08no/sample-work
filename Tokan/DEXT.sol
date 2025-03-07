// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

// اینترفیس استاندارد ERC20
interface IERC20 {

    // مجموع کل توکن‌ها را برمی‌گرداند
    function totalSupply() external view returns (uint256);

    // موجودی یک آدرس مشخص را برمی‌گرداند
    function balanceOf(address account) external view returns (uint256);

    // انتقال توکن به یک آدرس دیگر
    function transfer(address recipient, uint256 amount) external returns (bool);

    // بررسی مقدار مجاز تخصیص داده‌شده برای خرج‌کردن توسط یک آدرس دیگر
    function allowance(address owner, address spender) external view returns (uint256);

    // تعیین مقدار مجاز برای خرج کردن توسط آدرس دیگر
    function approve(address spender, uint256 amount) external returns (bool);

    // رویداد برای تایید تخصیص
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.6.0;

// قرارداد انتزاعی برای فراهم کردن اطلاعات ارسال‌کننده تراکنش
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        return msg.data;
    }
}

pragma solidity ^0.6.0;

// کتابخانه SafeMath برای جلوگیری از سرریز و کم‌ریزی محاسبات عددی
library SafeMath {

    // جمع دو عدد
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    // تفریق دو عدد
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    // ضرب دو عدد
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    // تقسیم دو عدد
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    // باقی‌مانده تقسیم دو عدد
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// قرارداد اصلی توکن DEXT
contract Dextools is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances; // موجودی حساب‌ها
    mapping (address => mapping (address => uint256)) private _allowances; // مجوزها
    uint256 private _totalSupply; // کل عرضه توکن‌ها
    string private _name; // نام توکن
    string private _symbol; // نماد توکن
    uint8 private _decimals; // تعداد اعشار توکن

    constructor () public {
        _name = "DEXTools";
        _symbol = "DEXT";
        _decimals = 18;
        uint256 amount = 150000000000000000000000000; // 150 میلیون
        _totalSupply = amount;
        _balances[_msgSender()] = amount;
        emit Transfer(address(0), _msgSender(), amount); // رویداد انتقال اولیه
    }

    // نام توکن را برمی‌گرداند
    function name() public view returns (string memory) {
        return _name;
    }

    // نماد توکن را برمی‌گرداند
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    // تعداد اعشار توکن را برمی‌گرداند
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    // کل عرضه توکن را برمی‌گرداند
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    // موجودی یک آدرس را برمی‌گرداند
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    // انتقال توکن از طرف فرستنده به گیرنده
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    // مقدار مجاز برای خرج‌کردن توسط آدرس دیگر را برمی‌گرداند
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    // تایید مقدار مجاز خرج‌کردن توسط آدرس دیگر
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    // انتقال توکن از آدرس مشخص به آدرس دیگر
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    // افزایش مقدار مجاز خرج‌کردن
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    // کاهش مقدار مجاز خرج‌کردن
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    // تابع برای توکن‌سوزی توسط فرستنده
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    // توکن‌سوزی از حساب دیگر با استفاده از مقدار مجاز
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");
        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }

    // انتقال داخلی توکن
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    // توکن‌سوزی داخلی
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    // تایید داخلی مقدار مجاز خرج‌کردن
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
