# INFOMAN1 — Week 11 Lab Answers

Name: Jan Liam E. Arias
Student ID: 2510499
GitHub repo: https://github.com/Grudge10/infoman1   
Date submitted: 11/1/2026

## Task 1 — Diagnose the Anomalies

**Approach / explanation:**
I performed a query on the table to count how many D01's there were to show the update anomaly. For the insert anomaly, I tried to add an IT103 course but had to use NULL placeholders for the student columns due to no student being present. Finally for the delete anomaly, I deleted Ana's row of IT102 to show that all course information was lost.

**Code / query used (if applicable):**
```sql
SELECT COUNT(*) AS d01_row_count FROM student_enrollment WHERE dept_id = 'D01';

INSERT INTO student_enrollment (course_id, course_title, dept_id, department_name) VALUES ('IT103', 'Intro to Networks', 'D01', 'Computing Studies');
SELECT * FROM student_enrollment WHERE course_id = 'IT103';

SELECT * FROM student_enrollment WHERE student_id = 101 AND course_id = 'IT102';
DELETE FROM student_enrollment WHERE student_id = 101 AND course_id = 'IT102';
SELECT * FROM student_enrollment WHERE course_id = 'IT102';
```

**Evidence (screenshot filename, output, or file reference in this folder):**
`task1_output.txt`

**Reflection question:**
_[Which of the three anomalies surprised you most in the seed table, and what single structural fact causes all three?]_
The delete anomaly surprised me the most, because deleting just one student's enrollment would completely remove the existence of the 'Web Development' course from the database. All three anomalies are due to the fact that we have merged three separate entities (students, courses and departments) into one large table. This causes the descriptive facts to be dependent on only part of the identity of each row.

## Task 2 — Reach First Normal Form

**Approach / explanation:**
To create enrollments_1nf I removed the multi-valued enrolled_courses column and made sure each row represented one student course pair. I have also added a composite primary key on student_id and course_id. The table is still not fully normalised as the student names and course titles are repeated.

**Code / query used (if applicable):**
```sql
CREATE TABLE enrollments_1nf (
  student_id INT,
  student_name VARCHAR(100),
  course_id VARCHAR(10),
  course_title VARCHAR(100),
  dept_id VARCHAR(10),
  department_name VARCHAR(100),
  grade DECIMAL(4,2),
  PRIMARY KEY (student_id, course_id)
);

INSERT INTO enrollments_1nf VALUES
  (101, 'Ana Cruz', 'IT101', 'Database Systems', 'D01', 'Computing Studies', 1.50),
  (102, 'Ben Lim', 'IT101', 'Database Systems', 'D01', 'Computing Studies', 1.75),
  (101, 'Ana Cruz', 'IT102', 'Web Development', 'D01', 'Computing Studies', 1.25);

SELECT * FROM enrollments_1nf;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
`task2_output.txt`

**Reflection question:**
_[Why does splitting the multi-valued cell still leave student names repeating, and which normal form removes that next?]_
Splitting the multi-valued cell into atomic rows will resolve the violation of 1NF. However, there is still duplication of student names as student name only depends on student_id not the full composite key. This duplication can be resolved by putting the data into 2nd Normal Form (2NF), removing any partial dependencies.

## Task 3 — Reach Second Normal Form

**Approach / explanation:**
I identified the composite key (student_id, course_id) and listed the functional dependencies: student_id determines student_name, course_id determines course facts, and the full key determines grade. I then removed the partial dependencies. Student names were put into the students table, and course information was put into the courses_stage table. The enrollments table had only the composite key and grade, as this is dependent on the whole pair. A join was performed to confirm that the original report could be reconstructed.

**Code / query used (if applicable):**
```sql
CREATE TABLE students (
  student_id INT PRIMARY KEY,
  student_name VARCHAR(100)
);
INSERT INTO students VALUES (101, 'Ana Cruz'), (102, 'Ben Lim');

CREATE TABLE courses_stage (
  course_id VARCHAR(10) PRIMARY KEY,
  course_title VARCHAR(100),
  dept_id VARCHAR(10),
  department_name VARCHAR(100)
);
INSERT INTO courses_stage VALUES 
  ('IT101', 'Database Systems', 'D01', 'Computing Studies'),
  ('IT102', 'Web Development', 'D01', 'Computing Studies');

CREATE TABLE enrollments (
  student_id INT,
  course_id VARCHAR(10),
  grade DECIMAL(4,2),
  PRIMARY KEY (student_id, course_id)
);
INSERT INTO enrollments VALUES 
  (101, 'IT101', 1.50),
  (102, 'IT101', 1.75),
  (101, 'IT102', 1.25);

SELECT s.student_name, c.course_title, c.department_name, e.grade
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses_stage c ON e.course_id = c.course_id;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
`task3_output.txt`

**Reflection question:**
_[How do you tell that student name depends on part of the key while grade depends on the whole key?]_
We can see from the attributes that determine the value that knowing a student's name is solely determined by knowing the student_id (half of the key). However we cannot have a grade unless we know both the exact student and course they took (the whole composite key).

## Task 4 — Reach Third Normal Form

**Approach / explanation:**
The transitive dependency was identified. This was where course_id determines dept_id which determines department_name. This was separated into a departments table and an amended courses table. I then added foreign keys to connect the tables together. Running the decision path against each final table: students has no multi-valued, partial, or transitive dependencies (3NF), departments is 3NF, courses is 3NF, and enrollments is 3NF. When joining all four tables together, the report reconstructs perfectly.

**Code / query used (if applicable):**
```sql
CREATE TABLE departments (
  dept_id VARCHAR(10) PRIMARY KEY,
  department_name VARCHAR(100)
);
INSERT INTO departments VALUES ('D01', 'Computing Studies');

CREATE TABLE courses (
  course_id VARCHAR(10) PRIMARY KEY,
  course_title VARCHAR(100),
  dept_id VARCHAR(10),
  FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
INSERT INTO courses VALUES 
  ('IT101', 'Database Systems', 'D01'),
  ('IT102', 'Web Development', 'D01');

ALTER TABLE enrollments ADD FOREIGN KEY (student_id) REFERENCES students(student_id);
ALTER TABLE enrollments ADD FOREIGN KEY (course_id) REFERENCES courses(course_id);

SELECT s.student_name, c.course_title, d.department_name, e.grade
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id
JOIN departments d ON c.dept_id = d.dept_id;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
`task4_output.txt`

**Reflection question:**
_[What makes the department name indirectly dependent, and how does the final four-table join prove nothing was lost?]_
The department name is indirectly dependent on the dept_id, which itself is dependent on the course_id (course_id -> dept_id -> department_name). This final join of four tables demonstrates that nothing has been lost in the process. The exact same student/course/department/grade combinations have been created, they simply don’t have any repeated text.

## Task 5 — Reflection

**Approach / explanation:**
I have compared the effects of normalisation and designing using denormalisation for read heavy reporting. We looked at the department split from task 4. I have also included an example of a mistake I made when splitting into 3NF. This was due to a missing foreign key.

**Code / query used (if applicable):**
```sql
N/A
```

**Evidence (screenshot filename, output, or file reference in this folder):**
N/A

**Reflection question:**
_[When would you keep some denormalized repetition on purpose, and what single symptom tells you a split dropped a key?]_
I would normalise my tables to 3NF. This would allow me to reduce update anomalies in key transaction tables, such as enrollments and student profiles. If a student updated their name or a department was renamed, it would only be updated in one place. However, I may intentionally denormalise some of my data in a read heavy table, such as the department_name in the course_summary table. This avoids expensive multi-table joins when loading dashboards. I traded a little storage and update complexity for faster reads. When completing Task 4, I made an error when trying to make my tables 3NF. I had forgotten to include a foreign key referencing dept_id in my new courses table after splitting the courses_stage table into departments and courses. When I tried to join my 4 tables together I got a syntax error. There was no column to join the two tables. I added the dept_id column back into my courses table and created the foreign key relationship. This reminded me that when normalising you have to keep the relationships between your tables exactly the same so that you can recreate your original data perfectly.

## Self-Check

- [x] All tasks committed with individual, meaningful commit messages
- [x] All files placed inside `week11/`
- [x] This file completed and renamed `answers.md`
- [x] Repository link pasted into Moodle (no files uploaded)
