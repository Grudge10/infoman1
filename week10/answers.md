# INFOMAN1 — Week 10 Lab Answers

Name: Jan Liam E. Arias
Student ID: 2510499
GitHub repo: https://github.com/Grudge10/infoman1
Date submitted: 11/1/2026

## Task 1 — Safe INSERT

**Approach / explanation:**
I inserted the Scientific Calculator and Compass by specifying the target columns to prevent mapping errors. A SELECT statement was then executed to ensure the rows were inserted by using the WHERE clause to filter by the new SKU. An insert was also attempted with a string in the price column to demonstrate how MySQL will reject incorrect data types.

**Code / query used (if applicable):**
```sql
INSERT INTO products (product_name, sku, price, stock_quantity, status) VALUES ('Scientific Calculator', 'CALC-SCI-001', 850.00, 20, 'Active');
SELECT * FROM products WHERE sku = 'CALC-SCI-001';

INSERT INTO products (product_name, sku, price, stock_quantity, status) VALUES ('Compass', 'CMP-001', 120.00, 50, 'Active');
SELECT * FROM products WHERE sku = 'CMP-001';

-- Rejected insert (wrong data type for price)
INSERT INTO products (product_name, sku, price, stock_quantity, status) VALUES ('Binder', 'BND-001', 'expensive', 10, 'Active');
```

**Evidence (screenshot filename, output, or file reference in this folder):**
`task1_output.txt`

**Reflection question:**
_[Why does listing target columns explicitly make an INSERT safer, and what fills in for columns you omit?]_
By specifying the columns you want to use, you avoid the possibility of mapping your data to incorrect columns if the table structure changes or you forget the default ordering. Any columns not specified will be set to their DEFAULT values or NULL.

## Task 2 — UPDATE & DELETE Without Collateral Damage

**Approach / explanation:**
I used the primary key product_id to target the Calculator and Eraser to ensure there were no naming conflicts. I performed a SELECT command before performing an UPDATE or DELETE to ensure that only one row was affected. Then I applied the changes and performed a final SELECT to confirm.

**Code / query used (if applicable):**
```sql
-- Preview Update
SELECT * FROM products WHERE product_id = 6;
-- Execute Update
UPDATE products SET price = 875.00 WHERE product_id = 6;
-- Verify Update
SELECT * FROM products WHERE product_id = 6;

-- Preview Delete
SELECT * FROM products WHERE product_id = 5;
-- Execute Delete
DELETE FROM products WHERE product_id = 5;
-- Verify Delete
SELECT * FROM products WHERE product_id = 5;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
`task2_output.txt`

**Reflection question:**
_[What would your UPDATE and DELETE have done without their WHERE clauses, and why is a stable identifier safer than a name?]_
Without the WHERE clauses, the UPDATE would have changed all product prices in the table to 875.00, and the DELETE would have wiped out the entire products table. It is better to use a primary key as a stable identifier rather than a name, because names can be duplicated, whereas IDs are always unique.

## Task 3 — Self Join & Cross Join

**Approach / explanation:**
For the self join, I used two aliases on the employees table (e and m) to differentiate between the employee and manager roles. I also used a LEFT JOIN so that the top manager wasn’t excluded. For the cross join, I simply selected from the colors and sizes tables without an ON clause to return all possible combinations.

**Code / query used (if applicable):**
```sql
-- Self Join
SELECT e.employee_name AS employee, m.employee_name AS manager
FROM employees AS e
LEFT JOIN employees AS m ON e.manager_id = m.employee_id;

-- Cross Join
SELECT c.color_name, s.size_name
FROM colors AS c
CROSS JOIN sizes AS s;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
`task3_output.txt`

**Reflection question:**
_[Why does the self join need two aliases and a LEFT JOIN, and when is a CROSS JOIN the deliberate choice rather than a missing ON?]_
We use two aliases for the self join because MySQL needs to treat the single table as two separate entities. The LEFT JOIN ensures that Lea stays in the results with a NULL manager, since she doesn't have a manager_id. A CROSS JOIN is used intentionally when we actually want a Cartesian product, like generating all variations of a product. But if we just forget the ON clause in a normal join, it causes that same explosion by accident.

## Task 4 — Constraints & Table Evolution

**Approach / explanation:**
I used ALTER TABLE to add the constraints. MODIFY was used to set the product_name column to NOT NULL, and ADD was used for the UNIQUE and CHECK constraints. I tested the syntax in the CLI first to make sure MySQL accepts the MODIFY and CHECK commands without throwing errors. I then ran valid inserts to confirm they work, and invalid inserts to capture the exact error messages.

**Code / query used (if applicable):**
```sql
-- Evolve schema
ALTER TABLE products MODIFY product_name VARCHAR(100) NOT NULL;
ALTER TABLE products ADD UNIQUE (sku);
ALTER TABLE products ADD CONSTRAINT chk_price CHECK (price > 0);

-- Passing write
INSERT INTO products (product_name, sku, price, stock_quantity, status) VALUES ('Stapler', 'STP-001', 150.00, 40, 'Active');

-- Rejected writes
INSERT INTO products (product_name, sku, price, stock_quantity, status) VALUES (NULL, 'GLU-001', 50.00, 20, 'Active');
INSERT INTO products (product_name, sku, price, stock_quantity, status) VALUES ('Glue', 'NB-001', 50.00, 20, 'Active');
INSERT INTO products (product_name, sku, price, stock_quantity, status) VALUES ('Tape', 'TPE-001', -10.00, 20, 'Active');
```

**Evidence (screenshot filename, output, or file reference in this folder):**
`task4_output.txt`

**Reflection question:**
_[Why do constraints block future bad writes without repairing old bad rows, and what must you do before adding NOT NULL?]_
Constraints do not fix past incorrect entries because they are only triggered when a new INSERT or UPDATE is attempted. When adding a NOT NULL constraint to an existing column, you must first clean up any NULL values already in that column, otherwise MySQL will reject the ALTER TABLE statement entirely.

## Task 5 — Reflection

**Approach / explanation:**
I compared UI checks at the application level against constraints at the database level, focusing on the rules from Task 4. I also included an example of a syntax mistake I made during the lab.

**Code / query used (if applicable):**
```sql
N/A
```

**Evidence (screenshot filename, output, or file reference in this folder):**
N/A

**Reflection question:**
I would use application-level validations to ensure the UI is filled out correctly, like highlighting a field in red if it contains invalid data to catch simple typos. But I would rely on database constraints to enforce the actual business rules, like the CHECK (price > 0) and UNIQUE sku constraints we added in Task 4. If there is a bug in the app, the database still acts as a final check. Without database constraints, bad data would be corrupted silently, leading to negative prices or duplicate SKUs in the tables. While completing this lab, I made a mistake with my self join in Task 3 by forgetting to add a second alias to the employees table. MySQL threw an 'Unknown column' error because it didn't know which instance of the table I was trying to get the manager's name from. I fixed it by adding employees AS e and employees AS m. It was a simple typo, but it completely broke the query until I separated the two roles.

## Self-Check

- [x] All tasks committed with individual, meaningful commit messages
- [x] All files placed inside `week10/`
- [x] This file completed and renamed `answers.md`
- [x] Repository link pasted into Moodle (no files uploaded)
