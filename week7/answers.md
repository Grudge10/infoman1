# INFOMAN1 — Week 7 Lab Answers

## Task 1 — Complex Student Roster

**Approach / explanation:**
I performed a search of the students table using three criteria combined with the AND operator. The first condition was the IN operator that restricted the major to Computer Science or Information Technology. The second criterion was the LIKE operator with the pattern S%. This condition searched for students with last names starting with the letter S. The third criterion used the NOT operator to exclude students in the Online section.

**Code / query used (if applicable):**
SELECT first_name, last_name, major
FROM students
WHERE major IN ('Computer Science', 'Information Technology')
  AND last_name LIKE 'S%'
  AND NOT (section = 'Online');

**Evidence (screenshot filename, output, or file reference in this folder):**
task1_output.png

**Reflection question:**
Why is it often better to use the `IN` operator rather than chaining multiple `OR` conditions when filtering by a specific list of values?
The IN operator specifies a list of values more concisely, clearly, and with fewer mistakes than OR. With IN, it's easier to make changes to the list of allowed values. Plus, using IN with AND is less error prone than stringing OR conditions together, since the whole list sits inside one obvious group.
---

## Task 2 — Formatting Employee Data

**Approach / explanation:**
I have created the display string using CONCAT function, LEFT function to pull the first initial from the first name field, literal string for the period, space, and parentheses, and ROUND function to round the salary to a whole number. Then, I have added an alias to the resulting field as Instructor Details and limited the displayed records using the LIMIT keyword.

**Code / query used (if applicable):**
SELECT CONCAT(LEFT(first_name, 1), '. ', last_name, ' ($', ROUND(salary), ')') AS `Instructor Details`
FROM instructors
LIMIT 5;

**Evidence (screenshot filename, output, or file reference in this folder):**
task2_output.png

**Reflection question:**
How do string functions like `CONCAT` affect the performance of a query compared to retrieving raw columns and formatting them in the application layer (e.g., in Java or Python)?
Formatting inside SQL spends database CPU cycles constructing strings for every row. The database is almost always the hardest component to scale. Extracting the raw columns and formatting them in the application tier spreads the work to the app tier and keeps the queries simple and indexable. For small reports either is fine, but at scale the application tier is the better place for presentation logic.

---

## Task 3 — Project Deadline Analysis

**Approach / explanation:**
DATEDIFF from due_date minus assigned_date provides the days available, aliased as Days_To_Complete. Since WHERE is evaluated prior to column aliases, the same expression is used again in the WHERE clause to restrict to durations over 14 days, and ORDER BY DESC puts the longest duration first.

**Code / query used (if applicable):**
SELECT assignment_name, DATEDIFF(due_date, assigned_date) AS Days_To_Complete
FROM assignments
WHERE DATEDIFF(due_date, assigned_date) > 14
ORDER BY Days_To_Complete DESC;

**Evidence (screenshot filename, output, or file reference in this folder):**
task3_output.png

**Reflection question:**
Why is column aliasing particularly important when using mathematical or date functions in the `SELECT` clause?
Without the alias the output header is the expression text, which is ugly and not useful for reports or further code. The alias provides a business name to the calculated column, giving your query result a meaningful name that can be used in Excel, dashboards, application code, etc.

---

## Task 4 — Comprehensive Data Audit

**Approach / explanation:**
The audit requires that courses without a description OR those with 4 to 6 credits be selected, but only if their code contains ADV. Since AND binds tighter than OR, the two OR conditions are wrapped in parentheses so they are decided first, then the AND operator applies the LIKE '%ADV%' pattern test, and the rows are sorted by course_name.

**Code / query used (if applicable):**
SELECT course_code, course_name, credits
FROM courses
WHERE (course_description IS NULL OR credits BETWEEN 4 AND 6)
  AND course_code LIKE '%ADV%'
ORDER BY course_name;

**Evidence (screenshot filename, output, or file reference in this folder):**
task4_output.png

**Reflection question:**
Explain how MySQL evaluates the expression `A OR B AND C`. How did you use parentheses (if you did) to ensure your query filtered the exact data requested in the instructions?
MySQL evaluates AND higher than OR, so A OR B AND C is equivalent to A OR (B AND C). This would return all the NULL-description courses regardless of their code. Adding the parentheses around the OR pair, (course_description IS NULL OR credits BETWEEN 4 AND 6) AND course_code LIKE '%ADV%', will force the OR group to be processed first and then combined with the ADV pattern test, which is precisely the audit described by the task.

---

## Self-Check

- [x] All tasks committed with individual, meaningful commit messages
- [x] All files placed inside week7/
- [x] This file completed and renamed answers.md
- [x] Repository link pasted into Moodle (no files uploaded)
