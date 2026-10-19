# INFOMAN1 — Week 8 Lab Answers

Name: Jan Liam E. Arias
Student ID: 2510499
GitHub repo: https://github.com/Grudge10/infoman1
Date submitted: 10/19/2026

**Dataset check:** `SELECT COUNT(*) FROM employee;` returned: 500

## Task 1 — Pattern Matching Basics

**Approach / explanation:**
I have made use of the LIKE operator with wildcards to filter the text. For the first two queries, I have used the % sign as a wildcard to indicate any sequence of symbols before or after the specified string of characters. In the third query, I have used the _ wildcard to indicate any single character in the specified position. In this case, the emp_code field has a specific number of characters (5), and I narrow down the search to a particular position (the third character) and specify the exact character that should appear there (0).

**Code / query used (if applicable):**
```sql
-- 1.1
SELECT emp_id, first_name, last_name FROM employee WHERE last_name LIKE '%ez';
-- 1.2
SELECT emp_id, first_name, department FROM employee WHERE first_name LIKE 'Ma%';
-- 1.3a (Proof)
SELECT COUNT(*) FROM employee WHERE emp_code LIKE 'E____';
-- 1.3b (Specific Pattern)
SELECT emp_code, first_name, last_name FROM employee WHERE emp_code LIKE 'E_0__';
```

**Evidence (screenshot filename, output, or file reference in this folder):**
task1_1_output.txt, task1_2_output.txt, task1_3a_output.txt, task1_3b_output.txt
Row counts: 1.1 = 49 rows, 1.2 = 116 rows, 1.3a = 500 rows, 1.3b = 28 rows.

**Reflection question:**
Why do we use the `%` wildcard instead of the `_` wildcard when searching for fields containing a specific keyword?
The % wildcard character can match any number of characters, including zero, so that it will match a keyword in any position in a string of arbitrary length. The _ wildcard character matches only one character, so that it is suitable for use only when the position of the string element is known exactly.

## Task 2 — Basic Aggregation

**Approach / explanation:**
I used aggregate functions to summarize the entire table. The gap between COUNT(*) and COUNT(commission) exists because COUNT(*) counts every row (500), while COUNT(commission) ignores the NULL values (approx. 30% of the data), counting only the rows with valid commission data. For the final query, I used COALESCE(commission, 0) to treat NULL commissions as zero; without this, adding a NULL to a salary would result in NULL, effectively erasing that employee from the total sum.


**Code / query used (if applicable):**
```sql
-- 2.1
SELECT COUNT(*) AS Total_Emps, COUNT(commission) AS Emps_With_Comm FROM employee;
-- 2.2
SELECT SUM(salary) AS Total_Payroll FROM employee;
-- 2.3
SELECT AVG(salary) AS Avg_Sal, MIN(hire_date) AS Earliest, MAX(hire_date) AS Latest FROM employee;
-- 2.4
SELECT SUM(salary + COALESCE(commission, 0)) AS Total_Compensation FROM employee;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
task2_output.png

**Reflection question:**
What is the difference between `COUNT(*)` and `COUNT(column_name)`?
COUNT(*) counts the total number of rows in the result set, regardless of NULL values. COUNT(column_name) counts only the rows where that specific column contains a non-NULL value, effectively ignoring missing data.

## Task 3 — Grouping Data

**Approach / explanation:**
I executed the GROUP BY statement to group the data by department and department and job title. For the first query, I summed up the number of employees, their average salary, and the quantity of different job titles (COUNT DISTINCT) for each department. The second query demonstrated how the information was divided by jobs in each department.

**Code / query used (if applicable):**
```sql
-- 3.1
SELECT department, COUNT(*) AS Headcount, AVG(salary) AS Avg_Sal, COUNT(DISTINCT job_title) AS Unique_Titles
FROM employee GROUP BY department;

-- 3.2
SELECT department, job_title, COUNT(*) AS Headcount
FROM employee GROUP BY department, job_title;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
task3_output.png

**Reflection question:**
Why is it generally invalid to include columns in the `SELECT` list that are not in the `GROUP BY` clause, unless they are inside an aggregate function?
If a column is not grouped or aggregated, the database does not know which of the rows in the group to pick when displaying its value. For instance, if you decide to group your data by Department, you would not be able to select the "Employee Name" column, as you would not know which name to show for the department as a whole since there are multiple names in a department.

## Task 4 — Advanced Filtering with HAVING

**Approach / explanation:**
For the first query, I selected 60,000 as the threshold value for high-paid departments. I used the HAVING clause in the first query because the filtering happened after the average salary calculation for each department. For the second query, I first filtered all Active employees (WHERE clause), distributed them into departments (GROUP BY), and then removed the departments with fewer than 51 workers (HAVING).

**Code / query used (if applicable):**
```sql
-- 4.1
SELECT department, AVG(salary) AS Avg_Sal
FROM employee
GROUP BY department
HAVING AVG(salary) > 60000;

-- 4.2
SELECT department, COUNT(*) AS Active_Count
FROM employee
WHERE status = 'Active'
GROUP BY department
HAVING COUNT(*) > 50;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
task4_output.png

**Reflection question:**
Why must we use the `HAVING` clause here instead of the `WHERE` clause to filter by the average value?
The WHERE condition precedes the selection of rows by grouping and, therefore, cannot contain any references to the results of the aggregation. The HAVING clause is used to select groups of rows that meet specified conditions, which should contain references to the results of the aggregation.

## Self-Check

- [x] All tasks committed with individual, meaningful commit messages
- [x] All files placed inside `week08/`
- [x] This file completed and renamed `answers.md`
- [x] Repository link pasted into Moodle (no files uploaded)
