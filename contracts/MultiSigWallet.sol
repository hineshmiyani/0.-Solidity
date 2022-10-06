// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

contract MultiSigWallet {
    /* Events */
    event Deposit(address indexed sender, uint256 amount, uint256 balance);
    event Submit(uint256 indexed txId);
    event Approve(address indexed owner, uint256 indexed txId);
    event Revoke(address indexed owner, uint256 indexed txId);
    event Execute(uint256 indexed txId);

    /* State Variables */
    // Here, struct used for store transation
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
    }

    address[] public owners;

    // Check msg.sender is owner
    // mapping(msg.sender => is owner or not(true/false)) public isOwner;
    mapping(address => bool) public isOwner;

    // Numbers of owners need to execute the transaction.
    uint256 public required;

    Transaction[] public transactions;

    // Store the each approval of each transaction by each owner
    // mapping ( tx => mapping (ownerAddress => isApproved)) public approved;
    mapping(uint256 => mapping(address => bool)) public approved;

    /* Modifiers */
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not Owner");
        _;
    }

    modifier txExist(uint256 _txId) {
        require(_txId < transactions.length, "Transaction doesn't exist");
        _;
    }

    modifier notApproved(uint256 _txId) {
        require(!approved[_txId][msg.sender], "Transaction already approved");
        _;
    }

    modifier notExecuted(uint256 _txId) {
        require(
            !(transactions[_txId].executed),
            "Transaction already executed"
        );
        _;
    }

    constructor(address[] memory _owners, uint256 _required) payable {
        require(_owners.length > 0, "Owners required");
        require(
            _required <= _owners.length && _required > 0,
            "Invalid required number of owners"
        );

        for (uint256 i; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "Invalid Owner");
            require(!isOwner[owner], "Owner is not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        required = _required;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function submit(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwner {
        transactions.push(
            Transaction({to: _to, value: _value, data: _data, executed: false})
        );
        emit Submit(transactions.length - 1); // transaction id = transactions.length - 1
    }

    function approve(uint256 _txId)
        external
        txExist(_txId)
        notApproved(_txId)
        notExecuted(_txId)
    {
        approved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    function _getApprovalCount(uint256 _txId)
        private
        view
        returns (uint256 count)
    {
        // get count of total number of approval
        for (uint256 i; i < owners.length; i++) {
            if (approved[_txId][owners[i]]) {
                count = count + 1;
            }
        }
    }

    function execute(uint256 _txId)
        external
        onlyOwner
        txExist(_txId)
        notExecuted(_txId)
    {
        require(
            _getApprovalCount(_txId) >= required,
            "approval count is less then required approval"
        );

        Transaction storage transaction = transactions[_txId];
        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success, "Transaction failed!");

        emit Execute(_txId);
    }

    function revoke(uint256 _txId)
        external
        onlyOwner
        txExist(_txId)
        notExecuted(_txId)
    {
        require(approved[_txId][msg.sender], "Transaction doesn't approved");

        // Now. make transaction from approved state to unapproved;
        approved[_txId][msg.sender] = false;

        emit Revoke(msg.sender, _txId);
    }
}

// Test Contract
contract TestContract {
    uint256 public i;

    function callMe(uint256 j) public {
        i += j;
    }

    function getData() public pure returns (bytes memory) {
        return abi.encodeWithSignature("callMe(uint256)", 112);
    }
}
