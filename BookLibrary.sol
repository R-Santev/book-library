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
    mapping(string => bool) isBookAdded;

    address[] borrowers;
    // Shows is a sender is already a borrower
    mapping(address => bool) isBorrower;
    // Shows which books a user is borrowed (user => (bookId => bool)
    mapping(address => mapping(uint => bool)) userBorrowed;

    /**
     * @notice Add new book with ('_title') and ('_copiesCount') in the books array.
     * Can only be called by the current owner.
     * Can only be invoked outside the contract.
     * @param _title - the title of the book
     * @param _copiesCount -  the number of copies of this book
     */
    function addBook(string memory _title, uint _copiesCount) external onlyOwner {
        require(!isBookAdded[_title], "This book is already added!");

        books.push(Book(_title, _copiesCount));
        isBookAdded[_title] = true;
        uint id = books.length - 1;

        emit BookAdded(id, _title, _copiesCount);
    }
    
    /**
     * @notice Borrow a book by ('_bookId').
     * Can only be invoked outside the contract.
     * @param _bookId - the ID of the book
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
     * @notice The borrower returns a book by ('_bookId').
     * Can only be invoked outside the contract.
     * @param _bookId - the ID of the book
     */
    function returnBook(uint _bookId) external {
        require(userBorrowed[msg.sender][_bookId] == true, "You don't own a copy of this book.");

        userBorrowed[msg.sender][_bookId] = false;
        books[_bookId].copies++;

        emit BookReturned(_bookId, msg.sender);
    }

    /**
     * @notice Returns all added books and their copies number.
     * return Book[]
     */
    function viewAllBooks() public view returns ( Book[] memory) {
        return books;
    }

    /**
     * @notice Returns all people that have ever borrowed a given book.
     * return address[]
     */
    function viewAllBorrowers() public view returns ( address[] memory) {
        return borrowers;
    }

    /**
     * @notice Add the person as a borrower, if it is not already added.
     * Can only be invoked inside the contract.
     */
    function addBorrower(address _borrower) private {
        if (!isBorrower[_borrower]) {
            borrowers.push(_borrower);
            isBorrower[_borrower] = true;
        }

    }

}
