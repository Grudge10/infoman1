# INFOMAN1 — Week 9 Lab Answers

Name: Jan Liam E. Arias
Student ID: 2510499
GitHub repo: https://github.com/Grudge10/infoman1
Date submitted: 10/21/2026

## Task 1 — INNER JOIN Basics

**Approach / explanation:**
I performed an INNER JOIN of the students and orders tables on the student_id foreign key. INNER JOIN ensures that only students who have placed an order are selected. The students were ordered by the order_id to provide a sequential list of transactions.

**Code / query used (if applicable):**
```sql
SELECT s.student_name, s.program, o.order_id, o.order_date
FROM students s INNER JOIN orders o ON s.student_id = o.student_id
ORDER BY o.order_id;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
`task1_output.txt`

**Reflection question:**
_[Why does an INNER JOIN hide students who never ordered, and when is that exactly the behavior a sales report wants?]_
An INNER JOIN will exclude students who have never made an order because it only shows the records that are common to both tables. This type of join is ideal for a completed sales report because it rules out students that have not submitted any sales orders.

## Task 2 — Finding Missing Relationships

**Approach / explanation:**
I performed a LEFT JOIN based on the students table to keep all students in the output whether they have an order or not. For the second query, I filtered the join using a WHERE condition with o.order_id IS NULL to show those students who did not have any data in the right table. In other words, the LEFT JOIN allows to get all the students and those who have orders will have their related information from the orders table. On the contrary, Ben Lim and Cara Yu are present in the result because they do not have records in the orders table.

**Code / query used (if applicable):**
```sql
-- 2a
SELECT s.student_name, s.program, o.order_id, o.order_date
FROM students s LEFT JOIN orders o ON s.student_id = o.student_id
ORDER BY s.student_id;

-- 2b
SELECT s.student_name, s.program, o.order_id, o.order_date
FROM students s LEFT JOIN orders o ON s.student_id = o.student_id
WHERE o.order_id IS NULL
ORDER BY s.student_id;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
`task2a_output.txt`, `task2b_output.txt`

**Reflection question:**
_[What does NULL mean in the unmatched columns of a LEFT JOIN, and why must you test it with IS NULL instead of equals?]_
In a LEFT JOIN, the appearance of NULL in the columns of the right table indicates that no matching row was found. Note that you should use IS NULL to filter such records because, in SQL, a NULL value is treated as unknown. Therefore, if you use the = operator in the WHERE clause, you will not get the desired result.

## Task 3 — Four-Table Canteen Report

**Approach / explanation:**
I have created a set of four tables in a chain from students, joined on student_id, to orders, to order_items, and, finally, to menu_items. I have made sure that any field that appears in more than one table is renamed using the “table.field” syntax. For instance, I have specified order_id as orders.order_id. I have computed the line_total by multiplying quantity and price and ordered the final receipt by order_id and item_name.

**Code / query used (if applicable):**
```sql
SELECT s.student_name, s.program, o.order_id, m.item_name, oi.quantity, m.price, (oi.quantity * m.price) AS line_total
FROM students s
INNER JOIN orders o ON s.student_id = o.student_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN menu_items m ON oi.menu_id = m.menu_id
ORDER BY o.order_id, m.item_name;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
`task3_output.txt`

**Reflection question:**
_[Why does each JOIN in a multi-table chain need its own ON condition, and what goes wrong when two joins share one?]_
A JOIN statement in a multi-table query always requires an ON condition that defines the exact foreign key to primary key relationship between the two tables being joined. Failure to specify one or more ON conditions for a multi-table join results in a Cartesian product, which is an enormous amount of unneeded data records.

## Task 4 — Aliases, Filters, and the Silent Inner Join

**Approach / explanation:**
For Version A, I performed an INNER JOIN of all the tables and specified the month of August in the WHERE clause. For Version B, I performed a LEFT JOIN of the students table but specified the month of August in the WHERE clause. The two queries produced the same 4 results. To fix this problem, one needs to move the condition with the date to the section of the query containing the ON statement (e.g., ON s.student_id = o.student_id AND o.order_date >= '2026-08-01').

**Code / query used (if applicable):**
```sql
-- Version A
SELECT s.student_name AS buyer, m.item_name AS item, (oi.quantity * m.price) AS line_total
FROM students s
INNER JOIN orders o ON s.student_id = o.student_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN menu_items m ON oi.menu_id = m.menu_id
WHERE o.order_date >= '2026-08-01'
ORDER BY o.order_date DESC, m.item_name;

-- Version B
SELECT s.student_name AS buyer, m.item_name AS item, (oi.quantity * m.price) AS line_total
FROM students s
LEFT JOIN orders o ON s.student_id = o.student_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN menu_items m ON oi.menu_id = m.menu_id
WHERE o.order_date >= '2026-08-01'
ORDER BY o.order_date DESC, m.item_name;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
`task4a_output.txt`, `task4b_output.txt`

**Reflection question:**
_[Why does adding WHERE on the right-side table remove the NULL rows a LEFT JOIN just preserved, and where should that rule live instead?]_
Adding a WHERE condition to the right-side table of a LEFT JOIN will exclude the NULL rows because the WHERE condition is checked after the join is done. Hence, you will lose the unmatched rows that have NULL in the right-side date column because they do not satisfy the >= '2026-08-01' condition. To prevent the rows from being excluded, you should place the date condition in the ON clause, which precedes the LEFT JOIN operation.

## Task 5 — Reflection

**Approach / explanation:**
I wrote a 150-200 word reflection contrasting INNER and LEFT joins based on Task 4, and detailed the "silent inner join" symptom and fix.

**Code / query used (if applicable):**
```sql
-- None required for this reflection task.
```

**Evidence (screenshot filename, output, or file reference in this folder):**
Written reflection below.

**Reflection question:**
_[Which join would you choose for an "all students including non-buyers" roster versus a "completed sales only" report, and what single symptom would tell you that you picked the wrong one?]_
I would choose to use the INNER JOIN in the case of the "completed sales" because it makes sense to pair the buyers with the actual sales, to ensure that the amounts are correct. On the other hand, I would use the LEFT JOIN in the case of the "all students" because it is needed to include everyone, including Ben and Cara, whose order values should appear as NULL.
In task 4, I have noticed the mistake that resulted from what appears to be a silent inner join. I initially used LEFT JOIN to list all the students and then specified the condition of the subsequent orders (WHERE o.order_date >= '2026-08-01'). The result only showed the four lines of matched orders, excluding Ben and Cara. It means that the WHERE condition "ate away" the unmatched rows, where the order date was NULL (because of LEFT JOIN). To fix it, I moved the condition to the ON statement of the orders join.

## Self-Check

- [x] All tasks committed with individual, meaningful commit messages
- [x] All files placed inside `week9/`
- [x] This file completed and renamed `answers.md`
- [x] Repository link pasted into Moodle (no files uploaded)
