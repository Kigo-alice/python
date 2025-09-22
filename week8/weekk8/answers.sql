-- Library Management System Database Design
-- Create database
CREATE DATABASE IF NOT EXISTS library_management_system;
USE library_management_system;

-- Table 1: members - Library members/patrons
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    library_card_number VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE NOT NULL,
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    zip_code VARCHAR(20),
    membership_type ENUM('Student', 'Faculty', 'Staff', 'Public') NOT NULL,
    membership_status ENUM('Active', 'Inactive', 'Suspended') DEFAULT 'Active',
    date_joined DATE NOT NULL,
    expiration_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_email (email),
    INDEX idx_membership_status (membership_status),
    INDEX idx_expiration_date (expiration_date)
);

-- Table 2: authors - Book authors
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_year YEAR,
    death_year YEAR,
    nationality VARCHAR(50),
    biography TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_author_name (last_name, first_name)
);

-- Table 3: publishers - Book publishers
CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(100) UNIQUE NOT NULL,
    address TEXT,
    city VARCHAR(50),
    country VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(200),
    established_year YEAR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_publisher_name (publisher_name)
);

-- Table 4: categories - Book categories/genres
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    parent_category_id INT NULL,
    
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
    ON DELETE SET NULL,
    
    INDEX idx_category_name (category_name)
);


-- Table 5: books - Main book information

CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    edition VARCHAR(20),
    publication_year YEAR,
    publisher_id INT NOT NULL,
    category_id INT NOT NULL,
    language VARCHAR(30) DEFAULT 'English',
    page_count INT,
    description TEXT,
    cover_image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id)
    ON DELETE RESTRICT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
    ON DELETE RESTRICT,
    
    INDEX idx_title (title),
    INDEX idx_isbn (isbn),
    INDEX idx_publication_year (publication_year),
    INDEX idx_category (category_id)
);

-- Table 6: book_authors - Many-to-Many relationship between books and authors

CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    author_order INT NOT NULL DEFAULT 1, -- To handle multiple authors order
    
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
    ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
    ON DELETE CASCADE,
    
    INDEX idx_author_order (author_order)
);

-- Table 7: book_copies - Individual physical copies of books
CREATE TABLE book_copies (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    barcode VARCHAR(50) UNIQUE NOT NULL,
    acquisition_date DATE NOT NULL,
    acquisition_price DECIMAL(10,2),
    current_condition ENUM('Excellent', 'Good', 'Fair', 'Poor', 'Lost') DEFAULT 'Good',
    location VARCHAR(100), -- Shelf location
    status ENUM('Available', 'Checked Out', 'On Hold', 'Under Repair', 'Lost') DEFAULT 'Available',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (book_id) REFERENCES books(book_id)
    ON DELETE RESTRICT,
    
    INDEX idx_barcode (barcode),
    INDEX idx_status (status),
    INDEX idx_location (location)
);


-- Table 8: loans - Book checkout records
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    copy_id INT NOT NULL,
    member_id INT NOT NULL,
    checkout_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE NULL,
    renewal_count INT DEFAULT 0,
    late_fee DECIMAL(8,2) DEFAULT 0.00,
    status ENUM('Active', 'Returned', 'Overdue') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id)
    ON DELETE RESTRICT,
    FOREIGN KEY (member_id) REFERENCES members(member_id)
    ON DELETE RESTRICT,
    
    INDEX idx_member_id (member_id),
    INDEX idx_due_date (due_date),
    INDEX idx_status (status),
    INDEX idx_checkout_date (checkout_date)
);

-- Table 9: holds - Book reservation system
CREATE TABLE holds (
    hold_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    hold_date DATETIME NOT NULL,
    expiration_date DATETIME NOT NULL,
    status ENUM('Active', 'Fulfilled', 'Cancelled', 'Expired') DEFAULT 'Active',
    priority INT DEFAULT 1,
    notification_sent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (book_id) REFERENCES books(book_id)
    ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id)
    ON DELETE CASCADE,
    
    UNIQUE KEY unique_active_hold (book_id, member_id, status),
    INDEX idx_hold_date (hold_date),
    INDEX idx_expiration_date (expiration_date),
    INDEX idx_status (status)
);

-- Table 10: fines - Financial transactions for late returns/lost books
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    loan_id INT NULL,
    fine_type ENUM('Late Return', 'Lost Book', 'Damage Fee', 'Other') NOT NULL,
    amount DECIMAL(8,2) NOT NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    payment_date DATE NULL,
    status ENUM('Outstanding', 'Paid', 'Waived') DEFAULT 'Outstanding',
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (member_id) REFERENCES members(member_id)
    ON DELETE RESTRICT,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
    ON DELETE SET NULL,
    
    INDEX idx_member_id (member_id),
    INDEX idx_status (status),
    INDEX idx_due_date (due_date)
);


-- Table 11: staff - Library staff members

CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    position VARCHAR(50) NOT NULL,
    department VARCHAR(50),
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2),
    status ENUM('Active', 'Inactive', 'On Leave') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_email (email),
    INDEX idx_position (position)
);
-- Table 12: transactions - Library transactions log
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    staff_id INT NOT NULL,
    transaction_type ENUM('Checkout', 'Return', 'Renewal', 'Hold', 'Fine Payment') NOT NULL,
    transaction_date DATETIME NOT NULL,
    description TEXT,
    related_loan_id INT NULL,
    related_fine_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (member_id) REFERENCES members(member_id)
    ON DELETE RESTRICT,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
    ON DELETE RESTRICT,
    FOREIGN KEY (related_loan_id) REFERENCES loans(loan_id)
    ON DELETE SET NULL,
    FOREIGN KEY (related_fine_id) REFERENCES fines(fine_id)
    ON DELETE SET NULL,
    
    INDEX idx_transaction_date (transaction_date),
    INDEX idx_transaction_type (transaction_type),
    INDEX idx_member_id (member_id)
);

-- Table 13: reviews - Member book reviews and ratings

CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    review_date DATE NOT NULL,
    status ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (book_id) REFERENCES books(book_id)
    ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id)
    ON DELETE CASCADE,
    
    UNIQUE KEY unique_member_book_review (book_id, member_id),
    INDEX idx_rating (rating),
    INDEX idx_review_date (review_date)
);

-- Insert Sample Data

-- Insert sample categories
INSERT INTO categories (category_name, description) VALUES
('Fiction', 'Imaginative literary works'),
('Science Fiction', 'Fiction based on imagined future scientific or technological advances'),
('Mystery', 'Novels focused on solving a crime or puzzle'),
('Biography', 'Accounts of peoples lives'),
('Science', 'Works about the natural and physical world'),
('History', 'Study of past events'),
('Technology', 'Books about computers and technology'),
('Children', 'Books for young readers');

-- Insert sample publishers
INSERT INTO publishers (publisher_name, established_year, country) VALUES
('Penguin Random House', 2013, 'USA'),
('HarperCollins', 1817, 'USA'),
('Simon & Schuster', 1924, 'USA'),
('Macmillan', 1843, 'UK'),
('Hachette Livre', 1826, 'France');

-- Insert sample authors
INSERT INTO authors (first_name, last_name, birth_year, nationality) VALUES
('George', 'Orwell', 1903, 'British'),
('J.K.', 'Rowling', 1965, 'British'),
('Stephen', 'King', 1947, 'American'),
('Isaac', 'Asimov', 1920, 'American'),
('Agatha', 'Christie', 1890, 'British'),
('Michelle', 'Obama', 1964, 'American'),
('Yuval', 'Harari', 1976, 'Israeli');

-- Insert sample books
INSERT INTO books (isbn, title, publication_year, publisher_id, category_id, page_count) VALUES
('978-0451524935', '1984', 1949, 1, 2, 328),
('978-0439554930', 'Harry Potter and the Sorcerer''s Stone', 1997, 2, 1, 320),
('978-1501142970', 'It', 1986, 3, 1, 1138),
('978-0553293357', 'Foundation', 1951, 1, 2, 255),
('978-0062073501', 'Murder on the Orient Express', 1934, 2, 3, 256),
('978-1524763138', 'Becoming', 2018, 1, 4, 448),
('978-0062316097', 'Sapiens: A Brief History of Humankind', 2011, 2, 6, 464);

-- Insert book-author relationships
INSERT INTO book_authors (book_id, author_id, author_order) VALUES
(1, 1, 1),  -- 1984 by George Orwell
(2, 2, 1),  -- Harry Potter by J.K. Rowling
(3, 3, 1),  -- It by Stephen King
(4, 4, 1),  -- Foundation by Isaac Asimov
(5, 5, 1),  -- Murder on the Orient Express by Agatha Christie
(6, 6, 1),  -- Becoming by Michelle Obama
(7, 7, 1);  -- Sapiens by Yuval Harari

-- Insert sample members
INSERT INTO members (library_card_number, first_name, last_name, email, date_of_birth, membership_type, date_joined, expiration_date) VALUES
('LC1001', 'John', 'Smith', 'john.smith@email.com', '1990-05-15', 'Student', '2024-01-15', '2025-01-15'),
('LC1002', 'Sarah', 'Johnson', 'sarah.j@email.com', '1985-08-22', 'Faculty', '2024-01-10', '2026-01-10'),
('LC1003', 'Mike', 'Davis', 'mike.davis@email.com', '1978-12-03', 'Public', '2024-01-20', '2025-01-20');

-- Insert sample staff
INSERT INTO staff (employee_id, first_name, last_name, email, position, hire_date) VALUES
('EMP001', 'Alice', 'Brown', 'alice.brown@library.edu', 'Librarian', '2020-03-15'),
('EMP002', 'Robert', 'Wilson', 'robert.wilson@library.edu', 'Assistant Librarian', '2022-06-01');

-- Insert sample book copies
INSERT INTO book_copies (book_id, barcode, acquisition_date, location) VALUES
(1, 'BC1001', '2023-01-15', 'Fiction A-101'),
(1, 'BC1002', '2023-02-20', 'Fiction A-102'),
(2, 'BC1003', '2023-01-10', 'Fiction B-201'),
(3, 'BC1004', '2023-03-05', 'Fiction C-301'),
(4, 'BC1005', '2023-02-15', 'Sci-Fi D-401'),
(5, 'BC1006', '2023-01-20', 'Mystery E-501'),
(6, 'BC1007', '2023-04-01', 'Biography F-601'),
(7, 'BC1008', '2023-03-20', 'History G-701');

-- Create Views for Common Queries


-- View: Available books with details
CREATE VIEW available_books AS
SELECT 
    b.book_id,
    b.title,
    b.isbn,
    a.first_name AS author_first_name,
    a.last_name AS author_last_name,
    c.category_name,
    p.publisher_name,
    bc.copy_id,
    bc.barcode,
    bc.location
FROM books b
JOIN book_authors ba ON b.book_id = ba.book_id
JOIN authors a ON ba.author_id = a.author_id AND ba.author_order = 1
JOIN categories c ON b.category_id = c.category_id
JOIN publishers p ON b.publisher_id = p.publisher_id
JOIN book_copies bc ON b.book_id = bc.book_id
WHERE bc.status = 'Available';

-- View: Current active loans with member and book details
CREATE VIEW current_loans AS
SELECT 
    l.loan_id,
    m.first_name AS member_first_name,
    m.last_name AS member_last_name,
    m.email AS member_email,
    b.title,
    a.first_name AS author_first_name,
    a.last_name AS author_last_name,
    bc.barcode,
    l.checkout_date,
    l.due_date,
    l.status
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN book_copies bc ON l.copy_id = bc.copy_id
JOIN books b ON bc.book_id = b.book_id
JOIN book_authors ba ON b.book_id = ba.book_id
JOIN authors a ON ba.author_id = a.author_id AND ba.author_order = 1
WHERE l.status = 'Active';

-- View: Overdue books
CREATE VIEW overdue_books AS
SELECT 
    l.loan_id,
    m.first_name,
    m.last_name,
    m.email,
    b.title,
    l.due_date,
    DATEDIFF(CURRENT_DATE, l.due_date) AS days_overdue,
    l.late_fee
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN book_copies bc ON l.copy_id = bc.copy_id
JOIN books b ON bc.book_id = b.book_id
WHERE l.status = 'Active' 
AND l.due_date < CURRENT_DATE;

-- Create Stored Procedures

DELIMITER //

-- Procedure: Check out a book
CREATE PROCEDURE CheckoutBook(
    IN p_member_id INT,
    IN p_copy_id INT,
    IN p_staff_id INT,
    OUT p_loan_id INT
)
BEGIN
    DECLARE v_due_date DATE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Calculate due date (14 days from today)
    SET v_due_date = DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY);
    
    -- Insert loan record
    INSERT INTO loans (copy_id, member_id, checkout_date, due_date)
    VALUES (p_copy_id, p_member_id, CURRENT_DATE, v_due_date);
    
    SET p_loan_id = LAST_INSERT_ID();
    
    -- Update book copy status
    UPDATE book_copies 
    SET status = 'Checked Out' 
    WHERE copy_id = p_copy_id;
    
    -- Log transaction
    INSERT INTO transactions (member_id, staff_id, transaction_type, transaction_date, related_loan_id, description)
    VALUES (p_member_id, p_staff_id, 'Checkout', NOW(), p_loan_id, 
            CONCAT('Book checked out - Loan ID: ', p_loan_id));
    
    COMMIT;
END //

-- Procedure: Return a book
CREATE PROCEDURE ReturnBook(
    IN p_loan_id INT,
    IN p_staff_id INT
)
BEGIN
    DECLARE v_member_id INT;
    DECLARE v_copy_id INT;
    DECLARE v_due_date DATE;
    DECLARE v_days_late INT;
    DECLARE v_late_fee DECIMAL(8,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Get loan details
    SELECT member_id, copy_id, due_date 
    INTO v_member_id, v_copy_id, v_due_date
    FROM loans 
    WHERE loan_id = p_loan_id AND status = 'Active';
    
    IF v_member_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loan not found or already returned';
    END IF;
    
    -- Calculate late fee if applicable
    SET v_days_late = GREATEST(0, DATEDIFF(CURRENT_DATE, v_due_date));
    SET v_late_fee = v_days_late * 0.25; -- $0.25 per day
    
    -- Update loan record
    UPDATE loans 
    SET return_date = CURRENT_DATE,
        status = 'Returned',
        late_fee = v_late_fee
    WHERE loan_id = p_loan_id;
    
    -- Update book copy status
    UPDATE book_copies 
    SET status = 'Available' 
    WHERE copy_id = v_copy_id;
    
    -- Create fine record if applicable
    IF v_late_fee > 0 THEN
        INSERT INTO fines (member_id, loan_id, fine_type, amount, issue_date, due_date, description)
        VALUES (v_member_id, p_loan_id, 'Late Return', v_late_fee, CURRENT_DATE, 
                DATE_ADD(CURRENT_DATE, INTERVAL 30 DAY),
                CONCAT('Late return fee for ', v_days_late, ' days overdue'));
    END IF;
    
    -- Log transaction
    INSERT INTO transactions (member_id, staff_id, transaction_type, transaction_date, related_loan_id, description)
    VALUES (v_member_id, p_staff_id, 'Return', NOW(), p_loan_id, 
            CONCAT('Book returned', IF(v_late_fee > 0, CONCAT(' - Late fee: $', v_late_fee), '')));
    
    COMMIT;
END //

DELIMITER ;

-- Create Triggers

-- Trigger: Update book copy status when loan is created
DELIMITER //
CREATE TRIGGER after_loan_insert
AFTER INSERT ON loans
FOR EACH ROW
BEGIN
    UPDATE book_copies 
    SET status = 'Checked Out' 
    WHERE copy_id = NEW.copy_id;
END //

-- Trigger: Update book copy status when loan is returned
CREATE TRIGGER after_loan_update
AFTER UPDATE ON loans
FOR EACH ROW
BEGIN
    IF NEW.status = 'Returned' AND OLD.status != 'Returned' THEN
        UPDATE book_copies 
        SET status = 'Available' 
        WHERE copy_id = NEW.copy_id;
    END IF;
END //

DELIMITER ;

-- Database Relationships Summary

/*
RELATIONSHIPS IN THE DATABASE:

1. One-to-Many:
   - Publisher → Books
   - Category → Books
   - Member → Loans
   - Member → Holds
   - Member → Fines
   - Member → Reviews
   - Staff → Transactions
   - Book → Book Copies
   - Book → Reviews

2. Many-to-Many:
   - Books ↔ Authors (via book_authors junction table)
   
3. One-to-One (implied):
   - Loan → Fine (one loan can have one fine)
   - Transaction → Loan/Fine (one transaction relates to one loan/fine)
*/

-- Query Examples

-- Example 1: Find all available science fiction books
SELECT 
    b.title,
    a.first_name,
    a.last_name,
    bc.location
FROM available_books avb
JOIN books b ON avb.book_id = b.book_id
JOIN authors a ON avb.author_first_name = a.first_name AND avb.author_last_name = a.last_name
WHERE avb.category_name = 'Science Fiction';

-- Example 2: Get member borrowing history
SELECT 
    m.first_name,
    m.last_name,
    b.title,
    l.checkout_date,
    l.return_date,
    l.status
FROM members m
JOIN loans l ON m.member_id = l.member_id
JOIN book_copies bc ON l.copy_id = bc.copy_id
JOIN books b ON bc.book_id = b.book_id
WHERE m.member_id = 1
ORDER BY l.checkout_date DESC;

-- Example 3: Calculate total fines by member
SELECT 
    m.first_name,
    m.last_name,
    SUM(f.amount) as total_fines,
    COUNT(*) as fine_count
FROM members m
LEFT JOIN fines f ON m.member_id = f.member_id
WHERE f.status = 'Outstanding'
GROUP BY m.member_id, m.first_name, m.last_name;

-- Database Documentation
/*
LIBRARY MANAGEMENT SYSTEM DATABASE DESIGN

TABLES:
1. members - Library patrons with membership details
2. authors - Book authors information
3. publishers - Publishing companies
4. categories - Book genres/categories (self-referencing for hierarchy)
5. books - Main book information
6. book_authors - Junction table for many-to-many book-author relationship
7. book_copies - Individual physical copies of books
8. loans - Book checkout records
9. holds - Book reservation system
10. fines - Financial transactions for violations
11. staff - Library employees
12. transactions - Audit log of all library transactions
13. reviews - Member book reviews and ratings

KEY FEATURES:
- Comprehensive member management
- Inventory tracking with multiple copies
- Reservation system with priority queuing
- Financial management for fines and fees
- Staff management and transaction logging
- Book reviews and rating system
- Hierarchical category system
- Advanced search and reporting capabilities

BUSINESS RULES:
- Members can have multiple active loans (with limits)
- Books can have multiple physical copies
- Each copy has its own status and condition
- Fines are automatically calculated for late returns
- Reservations expire after a set period
- Staff members log all transactions for audit purposes
*/

SHOW TABLES;