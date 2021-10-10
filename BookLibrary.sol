// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// ABI coder v2 is activated by default since solc 0.8.0

import "./Ownable.sol";

contract BookLibrary is Ownable{

    event BookAdded(uint id, string title, uint copiesCount);
    event BookBorrowed(uint bookId, address borrower);
    event BookReturned(uint bookId, address borrower);

    struct Book {
        string title;
        uint copies;
    }

    // The array is public, so solidity automatically creates a getter function for the array's elements (element's index has to be provided)
    Book[] public books;
    // Shows is a title is being added in the library
    mapping(string => bool) isAdded;

    address[] borrowers;
    mapping(address => bool) isBorrower;
    // Shows which books a user is borrowed (user => (bookId => bool)
    mapping(address => mapping(uint => bool)) userBorrowed;

    function addBorrower(address _borrower) private {
        if(!isBorrower[_borrower]) {
            borrowers.push(_borrower);
            isBorrower[_borrower] = true;
        }

    }

    /**
     * @dev Add new book with ('_title') and ('copiesCount') in the books array.
     * Can only be called by the current owner.
     * Can only be invoked outside the contract.
     */
    function addBook(string memory _title, uint _copiesCount) external onlyOwner {
        require(!isAdded[_title], "This book is already added!");

        books.push(Book(_title, _copiesCount));
        isAdded[_title] = true;
        uint id = books.length - 1;

        emit BookAdded(id, _title, _copiesCount);
    }

    /**
     * @dev Returns all added books and their copies number.
     */
    function viewAllBooks() public view returns ( Book[] memory) {
        return books;
    }

    /**
     * @dev Borrow a book by ('_bookId').
     * Can only be invoked outside the contract.
     */
    function borrowBook(uint _bookId) external {
        require(books[_bookId].copies > 0, "There are no copies left! Try again later.");
        require(!userBorrowed[msg.sender][_bookId], "You already own a copy of this book.");

        userBorrowed[msg.sender][_bookId] = true;
        books[_bookId].copies--;
        
        addBorrower(msg.sender);
        
        emit BookBorrowed(_bookId, msg.sender);
    }

    /**
     * @dev Return a book by ('_bookId').
     * Can only be invoked outside the contract.
     */
    function returnBook(uint _bookId) external {
        require(userBorrowed[msg.sender][_bookId] == true, "You don't own a copy of this book.");

        userBorrowed[msg.sender][_bookId] = false;
        books[_bookId].copies++;

        emit BookReturned(_bookId, msg.sender);
    }

    function viewAllBorrowers() public view returns ( address[] memory) {
        return borrowers;
    }

}
