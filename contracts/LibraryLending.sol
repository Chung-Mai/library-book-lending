// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title LibraryLending - small library: librarian adds books, users borrow/return
contract LibraryLending {
    struct Book {
        uint256 id;
        string title;
        address borrower; // address(0) when available
        bool available;
    }

    address public librarian;
    Book[] private books;

    event BookAdded(uint256 indexed id, string title, address indexed librarian);
    event BookBorrowed(uint256 indexed id, address indexed borrower);
    event BookReturned(uint256 indexed id, address indexed borrower);

    modifier onlyLibrarian() {
        require(msg.sender == librarian, "Only librarian can add books");
        _;
    }

    modifier bookExists(uint256 id) {
        require(id < books.length, "Book does not exist");
        _;
    }

    constructor() {
        librarian = msg.sender;
    }

    function addBook(string memory title) external onlyLibrarian returns (uint256) {
        require(bytes(title).length > 0, "Title is empty");
        uint256 id = books.length;
        books.push(Book(id, title, address(0), true));
        emit BookAdded(id, title, msg.sender);
        return id;
    }

    function borrowBook(uint256 id) external bookExists(id) {
        Book storage b = books[id];
        require(b.available, "Book is already borrowed");
        b.available = false;
        b.borrower = msg.sender;
        emit BookBorrowed(id, msg.sender);
    }

    function returnBook(uint256 id) external bookExists(id) {
        Book storage b = books[id];
        require(!b.available, "Book is not borrowed");
        require(b.borrower == msg.sender, "Only current borrower can return");
        b.available = true;
        b.borrower = address(0);
        emit BookReturned(id, msg.sender);
    }

    function getBook(uint256 id) external view bookExists(id) returns (Book memory) {
        return books[id];
    }

    function getAllBooks() external view returns (Book[] memory) {
        return books;
    }

    function bookCount() external view returns (uint256) {
        return books.length;
    }
}