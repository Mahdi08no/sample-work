// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BinaryTree {
    struct Node {
        uint value;        // مقدار ذخیره‌شده در گره
        uint left;         // اشاره‌گر به گره چپ (آی‌دی)
        uint right;        // اشاره‌گر به گره راست (آی‌دی)
        bool exists;       // بررسی وجود گره
    }

    mapping(uint => Node) public nodes; // نگهداری گره‌ها
    uint public root;                   // ریشه درخت
    uint public nodeCount;              // شمارش تعداد گره‌ها

    constructor() {
        root = 0; // ابتدا ریشه وجود ندارد
        nodeCount = 0;
    }

    // افزودن یک گره به درخت
    function addNode(uint _value) public {
        nodeCount++;
        Node memory newNode = Node({
            value: _value,
            left: 0,
            right: 0,
            exists: true
        });

        if (root == 0) {
            root = nodeCount; // اولین گره، ریشه می‌شود
        } else {
            _insert(root, nodeCount, _value);
        }

        nodes[nodeCount] = newNode;
    }

    // تابع کمکی برای افزودن گره‌ها به مکان درست
    function _insert(uint _currentId, uint _newId, uint _value) internal {
        if (_value < nodes[_currentId].value) {
            // به سمت چپ برو
            if (nodes[_currentId].left == 0) {
                nodes[_currentId].left = _newId;
            } else {
                _insert(nodes[_currentId].left, _newId, _value);
            }
        } else {
            // به سمت راست برو
            if (nodes[_currentId].right == 0) {
                nodes[_currentId].right = _newId;
            } else {
                _insert(nodes[_currentId].right, _newId, _value);
            }
        }
    }

    // خواندن یک گره بر اساس آی‌دی
    function getNode(uint _id) public view returns (uint, uint, uint, bool) {
        Node memory node = nodes[_id];
        return (node.value, node.left, node.right, node.exists);
    }

    // جستجوی مقدار در درخت
    function search(uint _value) public view returns (bool) {
        return _search(root, _value);
    }

    function _search(uint _currentId, uint _value) internal view returns (bool) {
        if (_currentId == 0) return false;

        if (nodes[_currentId].value == _value) {
            return true;
        } else if (_value < nodes[_currentId].value) {
            return _search(nodes[_currentId].left, _value);
        } else {
            return _search(nodes[_currentId].right, _value);
        }
    }
}
