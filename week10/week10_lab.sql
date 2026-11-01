-- Task 1: Safe INSERT
INSERT INTO
    products (product_name, sku, price, stock_quantity, status)
VALUES
    (
        'Scientific Calculator',
        'CALC-SCI-001',
        850.00,
        20,
        'Active'
    );

SELECT
    *
FROM
    products
WHERE
    sku = 'CALC-SCI-001';

INSERT INTO
    products (product_name, sku, price, stock_quantity, status)
VALUES
    ('Compass', 'CMP-001', 120.00, 50, 'Active');

SELECT
    *
FROM
    products
WHERE
    sku = 'CMP-001';

-- Rejected insert (wrong data type for price)
INSERT INTO
    products (product_name, sku, price, stock_quantity, status)
VALUES
    ('Binder', 'BND-001', 'expensive', 10, 'Active');

-- Task 2: UPDATE & DELETE safety
-- Preview update
SELECT
    *
FROM
    products
WHERE
    product_id = 6;

-- Execute update
UPDATE products
SET
    price = 875.00
WHERE
    product_id = 6;

-- Verify update
SELECT
    *
FROM
    products
WHERE
    product_id = 6;

-- Preview delete
SELECT
    *
FROM
    products
WHERE
    product_id = 5;

-- Execute delete
DELETE FROM products
WHERE
    product_id = 5;

-- Verify delete
SELECT
    *
FROM
    products
WHERE
    product_id = 5;

-- Task 3: Self join & cross join
SELECT
    e.employee_name AS employee,
    m.employee_name AS manager
FROM
    employees AS e
    LEFT JOIN employees AS m ON e.manager_id = m.employee_id;

SELECT
    c.color_name,
    s.size_name
FROM
    colors AS c
    CROSS JOIN sizes AS s;

-- Task 4: Constraints & table evolution
ALTER TABLE products MODIFY product_name VARCHAR(100) NOT NULL;

ALTER TABLE products ADD UNIQUE (sku);

ALTER TABLE products ADD CONSTRAINT chk_price CHECK (price > 0);

-- Passing write
INSERT INTO
    products (product_name, sku, price, stock_quantity, status)
VALUES
    ('Stapler', 'STP-001', 150.00, 40, 'Active');

-- Rejected writes
INSERT INTO
    products (product_name, sku, price, stock_quantity, status)
VALUES
    (NULL, 'GLU-001', 50.00, 20, 'Active');

INSERT INTO
    products (product_name, sku, price, stock_quantity, status)
VALUES
    ('Glue', 'NB-001', 50.00, 20, 'Active');

INSERT INTO
    products (product_name, sku, price, stock_quantity, status)
VALUES
    ('Tape', 'TPE-001', -10.00, 20, 'Active');