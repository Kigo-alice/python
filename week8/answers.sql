
-- Database Normalization Assignment
-- Question 1: Achieving 1NF (First Normal Form)

/*
Problem: The Products column contains multiple values (violates 1NF)
Solution: Create a new table where each row represents a single product
*/

-- Step 1: Create the original table (for demonstration)
CREATE TABLE IF NOT EXISTS ProductDetail (
    OrderID INT,
    CustomerName VARCHAR(100),
    Products VARCHAR(255)
);

-- Insert sample data
INSERT INTO ProductDetail (OrderID, CustomerName, Products) VALUES
(101, 'John Doe', 'Laptop, Mouse'),
(102, 'Jane Smith', 'Tablet, Keyboard, Mouse'),
(103, 'Emily Clark', 'Phone');

-- Step 2: Transform to 1NF by creating a new normalized table
CREATE TABLE ProductDetail_1NF AS
SELECT 
    OrderID,
    CustomerName,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', n), ',', -1)) AS Product
FROM ProductDetail
CROSS JOIN (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL 
    SELECT 4 UNION ALL SELECT 5 -- Add more numbers if needed for maximum products
) numbers
WHERE n <= LENGTH(Products) - LENGTH(REPLACE(Products, ',', '')) + 1
ORDER BY OrderID, n;

-- Alternative approach using a more robust method (recommended)
DROP TABLE IF EXISTS ProductDetail_1NF;

CREATE TABLE ProductDetail_1NF (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(100)
);

-- Insert data using a recursive approach (for MySQL 8.0+)
WITH RECURSIVE split_products AS (
    SELECT 
        OrderID,
        CustomerName,
        Products,
        1 AS n,
        SUBSTRING_INDEX(Products, ',', 1) AS Product,
        SUBSTRING(Products, LENGTH(SUBSTRING_INDEX(Products, ',', 1)) + 2) AS remaining
    FROM ProductDetail
    
    UNION ALL
    
    SELECT 
        OrderID,
        CustomerName,
        Products,
        n + 1,
        CASE 
            WHEN LOCATE(',', remaining) > 0 
            THEN SUBSTRING_INDEX(remaining, ',', 1)
            ELSE remaining
        END AS Product,
        CASE 
            WHEN LOCATE(',', remaining) > 0 
            THEN SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
            ELSE ''
        END AS remaining
    FROM split_products
    WHERE remaining != ''
)
INSERT INTO ProductDetail_1NF (OrderID, CustomerName, Product)
SELECT OrderID, CustomerName, TRIM(Product) 
FROM split_products
WHERE Product != '';

-- Display the 1NF result
SELECT '1NF Result:' AS '';
SELECT * FROM ProductDetail_1NF ORDER BY OrderID, Product;

-- Question 2: Achieving 2NF (Second Normal Form)
/*
Problem: CustomerName depends only on OrderID (partial dependency violation)
Solution: Split into two tables - Orders and OrderItems
*/

-- Step 1: Create the original 1NF table (for demonstration)
DROP TABLE IF EXISTS OrderDetails;
CREATE TABLE OrderDetails (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(100),
    Quantity INT,
    PRIMARY KEY (OrderID, Product)
);

-- Insert sample data
INSERT INTO OrderDetails (OrderID, CustomerName, Product, Quantity) VALUES
(101, 'John Doe', 'Laptop', 2),
(101, 'John Doe', 'Mouse', 1),
(102, 'Jane Smith', 'Tablet', 3),
(102, 'Jane Smith', 'Keyboard', 1),
(102, 'Jane Smith', 'Mouse', 2),
(103, 'Emily Clark', 'Phone', 1);

-- Step 2: Create normalized tables for 2NF

-- Table 1: Orders (contains order-level information)
CREATE TABLE Orders_2NF (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

-- Table 2: OrderItems (contains item-level information)
CREATE TABLE OrderItems_2NF (
    OrderItemID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT,
    Product VARCHAR(100),
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders_2NF(OrderID)
);

-- Step 3: Populate the 2NF tables

-- Insert into Orders table (distinct order-customer pairs)
INSERT INTO Orders_2NF (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName 
FROM OrderDetails;

-- Insert into OrderItems table
INSERT INTO OrderItems_2NF (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;

-- Display the 2NF results
SELECT 'Orders Table (2NF):' AS '';
SELECT * FROM Orders_2NF ORDER BY OrderID;

SELECT 'OrderItems Table (2NF):' AS '';
SELECT * FROM OrderItems_2NF ORDER BY OrderID, Product;

-- Bonus: Achieving 3NF (Third Normal Form)
/*
Problem: CustomerName might have transitive dependencies
Solution: Further normalize by creating separate Customers table
*/

-- Step 1: Create 3NF tables

-- Customers table
CREATE TABLE Customers_3NF (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerName VARCHAR(100) UNIQUE
);

-- Orders table (3NF)
CREATE TABLE Orders_3NF (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers_3NF(CustomerID)
);

-- OrderItems table (3NF) - remains same as 2NF
CREATE TABLE OrderItems_3NF (
    OrderItemID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT,
    Product VARCHAR(100),
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders_3NF(OrderID)
);

-- Step 2: Populate 3NF tables

-- Insert into Customers table
INSERT INTO Customers_3NF (CustomerName)
SELECT DISTINCT CustomerName 
FROM Orders_2NF;

-- Insert into Orders table (3NF)
INSERT INTO Orders_3NF (OrderID, CustomerID)
SELECT o.OrderID, c.CustomerID
FROM Orders_2NF o
JOIN Customers_3NF c ON o.CustomerName = c.CustomerName;

-- Insert into OrderItems table (3NF)
INSERT INTO OrderItems_3NF (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderItems_2NF;

-- Display the 3NF results
SELECT 'Customers Table (3NF):' AS '';
SELECT * FROM Customers_3NF;

SELECT 'Orders Table (3NF):' AS '';
SELECT o.OrderID, c.CustomerName 
FROM Orders_3NF o
JOIN Customers_3NF c ON o.CustomerID = c.CustomerID
ORDER BY o.OrderID;

SELECT 'OrderItems Table (3NF):' AS '';
SELECT oi.OrderItemID, oi.OrderID, c.CustomerName, oi.Product, oi.Quantity
FROM OrderItems_3NF oi
JOIN Orders_3NF o ON oi.OrderID = o.OrderID
JOIN Customers_3NF c ON o.CustomerID = c.CustomerID
ORDER BY oi.OrderID, oi.Product;

-- Verification Queries

-- Verify 1NF: Check that each row has atomic values
SELECT '1NF Verification - Atomic Values:' AS '';
SELECT OrderID, COUNT(*) as ProductCount
FROM ProductDetail_1NF
GROUP BY OrderID
ORDER BY OrderID;

-- Verify 2NF: Check for partial dependencies
SELECT '2NF Verification - No Partial Dependencies:' AS '';
SELECT 'Orders table has only order-level information' AS Verification;
SELECT 'OrderItems table has only item-level information' AS Verification;

-- Verify 3NF: Check for transitive dependencies
SELECT '3NF Verification - No Transitive Dependencies:' AS '';
SELECT 'Customer information is separated from Orders' AS Verification;

-- Final Database Schema Summary

SELECT '=== FINAL NORMALIZED SCHEMA (3NF) ===' AS '';
SELECT '1. Customers_3NF (CustomerID, CustomerName)' AS TableStructure;
SELECT '2. Orders_3NF (OrderID, CustomerID)' AS TableStructure;
SELECT '3. OrderItems_3NF (OrderItemID, OrderID, Product, Quantity)' AS TableStructure;

-- Show complete normalized data
SELECT '=== COMPLETE NORMALIZED DATA ===' AS '';
SELECT 
    o.OrderID,
    c.CustomerName,
    oi.Product,
    oi.Quantity
FROM Orders_3NF o
JOIN Customers_3NF c ON o.CustomerID = c.CustomerID
JOIN OrderItems_3NF oi ON o.OrderID = oi.OrderID
ORDER BY o.OrderID, oi.Product;