-- ==========================================
-- INFOMAN1 Prelim Lab Exam - Task 4: Queries
-- Database: toolshare_prelim with sample data loaded
-- ==========================================

USE toolshare_prelim;

-- Q1: names and categories of all tools in the Power Tools category
SELECT tool_name, category FROM tool WHERE category = 'Power Tools';
-- Results (3 rows):
-- Cordless Drill | Power Tools
-- Circular Saw   | Power Tools
-- Angle Grinder  | Power Tools

-- Q2: members who joined after January 1, 2025
SELECT member_id, member_name, join_date FROM member WHERE join_date > '2025-01-01';
-- Results (4 rows):
-- 2 | Jose Rizal  | 2025-02-10
-- 3 | Ana Reyes   | 2025-06-01
-- 5 | Liza Gomez  | 2025-01-15
-- 6 | Kevin Lim   | 2025-08-05

-- Q3: borrowing records currently on loan
SELECT borrow_id, member_id, tool_id, borrow_date, return_date FROM borrowing WHERE return_date IS NULL;
-- Results (2 rows):
-- 2 | 1 | 2 | 2025-09-12 | NULL
-- 3 | 2 | 7 | 2025-09-05 | NULL

-- Q4: all borrowing records for member 1, Maria Santos
SELECT borrow_id, tool_id, borrow_date, return_date FROM borrowing WHERE member_id = 1;
-- Results (2 rows):
-- 1 | 1 | 2025-09-01 | 2025-09-10
-- 2 | 2 | 2025-09-12 | NULL

-- Q5: tools purchased before January 1, 2024
SELECT tool_name, category, purchase_date FROM tool WHERE purchase_date < '2024-01-01';
-- Results (3 rows):
-- Cordless Drill | Power Tools | 2023-05-10
-- Circular Saw   | Power Tools | 2023-08-22
-- Garden Shovel  | Garden      | 2023-12-01