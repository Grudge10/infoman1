-- task 1 = anomaly demonstrations
SELECT COUNT(*) AS d01_row_count FROM student_enrollment WHERE dept_id = 'D01';

INSERT INTO student_enrollment (course_id, course_title, dept_id, department_name) VALUES ('IT103', 'Intro to Networks', 'D01', 'Computing Studies');
SELECT * FROM student_enrollment WHERE course_id = 'IT103';

SELECT * FROM student_enrollment WHERE student_id = 101 AND course_id = 'IT102';
DELETE FROM student_enrollment WHERE student_id = 101 AND course_id = 'IT102';
SELECT * FROM student_enrollment WHERE course_id = 'IT102';

-- task 2 = first normal form
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

-- task 3 = second normal form
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

-- task 4 = third normal form
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