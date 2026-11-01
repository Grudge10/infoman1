CREATE DATABASE IF NOT EXISTS infoman1_bookstore;

USE infoman1_bookstore;

CREATE TABLE
    products (
        product_id INT PRIMARY KEY AUTO_INCREMENT,
        product_name VARCHAR(100),
        sku VARCHAR(30),
        price DECIMAL(10, 2),
        stock_quantity INT,
        status VARCHAR(20)
    );

CREATE TABLE
    sales (
        sale_id INT PRIMARY KEY AUTO_INCREMENT,
        product_id INT,
        sale_date DATE,
        quantity INT,
        FOREIGN KEY (product_id) REFERENCES products (product_id)
    );

CREATE TABLE
    employees (
        employee_id INT PRIMARY KEY,
        employee_name VARCHAR(100) NOT NULL,
        manager_id INT
    );

CREATE TABLE
    colors (color_name VARCHAR(30) PRIMARY KEY);

CREATE TABLE
    sizes (size_name VARCHAR(10) PRIMARY KEY);

INSERT INTO
    products (product_name, sku, price, stock_quantity, status)
VALUES
    ('Notebook', 'NB-001', 45.00, 100, 'Active'),
    ('Ballpen', 'BP-001', 15.00, 250, 'Active'),
    ('USB Drive', 'USB-001', 350.00, 30, 'Active'),
    ('Ruler', 'RL-001', 25.00, 80, 'Active'),
    ('Eraser', 'ER-001', 10.00, 200, 'Active');

INSERT INTO
    sales (product_id, sale_date, quantity)
VALUES
    (1, '2026-08-10', 5),
    (2, '2026-08-11', 10);

INSERT INTO
    employees
VALUES
    (1, 'Lea Ramos', NULL),
    (2, 'Carlo Reyes', 1),
    (3, 'Dana Cruz', 1);

INSERT INTO
    colors
VALUES
    ('Red'),
    ('Blue'),
    ('Green');

INSERT INTO
    sizes
VALUES
    ('S'),
    ('M'),
    ('L');