
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

contract MultiSigWallet {
    /* Events */
    event Deposit(address indexed sender, uint amount);
    event Submit(uint indexed txId);
    event Approve(address indexed owner, uint indexed txId);
    event Revoke(address indexed owner, uint indexed txId);
    event Execute(uint indexed txId);


    /* State Variables */
    // Here, struct used for store transation
    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
    }

    address[] public owners;

    // Check msg.sender is owner
    // mapping(msg.sender => is owner or not(true/false)) public isOwner;
    mapping(address => bool) public isOwner;

    // Numbers of owners need to execute the transaction.
    uint public required;

    Transaction[] public transactions;

    // Store the each approval of each transaction by each owner
    // mapping ( tx => mapping (ownerAddress => isApproved)) public approved;
    mapping(uint => mapping(address => bool)) public approved;


    /* Modifiers */
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not Owner");
        _;
    } 

    modifier txExist(uint _txId) {
        require(_txId < transactions.length, "Transaction doesn't exist");
        _;
    }

    modifier notApproved(uint _txId) {
        require(!approved[_txId][msg.sender], "Transaction already approved");
        _;
    }

    modifier notExecuted(uint _txId) {
        require(!(transactions[_txId].executed), "Transaction already executed" );
        _;
    }


    constructor(address[] memory _owners, uint _required) {
        require(_owners.length > 0, "Owners required");
        require(_required <= _owners.length && _required > 0, "Invalid required number of owners");

        for(uint i; i < _owners.length; i++ ) {
            address owner = _owners[i];

            require(owner != address(0), "Invalid Owner");
            require(!isOwner[owner], "Owner is not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        required = _required;
    }


    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submit( 
        address _to,
        uint _value,
        bytes calldata _data
    ) external onlyOwner {
        transactions.push(Transaction({to : _to, value : _value, data : _data, executed: false}));
        emit Submit(transactions.length - 1); // transaction id = transactions.length - 1
    }

    function approve( uint _txId) external txExist(_txId) notApproved(_txId) notExecuted(_txId) {
        approved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    function _getApprovalCount(uint _txId) private view returns (uint count) {
        // get count of total number of approval
        for(uint i; i < owners.length; i++) {
            if (approved[_txId][owners[i]]) {
                count = count + 1;
            }
        }
    }

    function execute(uint _txId) external onlyOwner txExist(_txId) notExecuted(_txId) {
        require(_getApprovalCount(_txId) >= required, "approval count is less then required approval");

        Transaction storage transaction = transactions[_txId];
        transaction.executed = true;

        (bool success, ) = transaction.to.call{value : transaction.value}(transaction.data);
        require(success, "Transaction failed!");

        emit Execute(_txId);
    }

    function revoke(uint _txId) external onlyOwner txExist(_txId) notExecuted(_txId) {
        require(approved[_txId][msg.sender], "Transaction doesn't approved");

        // Now. make transaction from approved state to unapproved;
        approved[_txId][msg.sender] = false;

        emit Revoke(msg.sender, _txId);
    }
} 