CREATE DATABASE IF NOT EXISTS infoman1_normalization;

USE infoman1_normalization;

CREATE TABLE
    student_enrollment (
        student_id INT,
        student_name VARCHAR(100),
        enrolled_courses VARCHAR(200),
        course_id VARCHAR(10),
        course_title VARCHAR(100),
        dept_id VARCHAR(10),
        department_name VARCHAR(100),
        grade DECIMAL(4, 2)
    );

INSERT INTO
    student_enrollment
VALUES
    (
        101,
        'Ana Cruz',
        'IT101, IT102',
        'IT101',
        'Database Systems',
        'D01',
        'Computing Studies',
        1.50
    ),
    (
        102,
        'Ben Lim',
        'IT101',
        'IT101',
        'Database Systems',
        'D01',
        'Computing Studies',
        1.75
    ),
    (
        101,
        'Ana Cruz',
        'IT101, IT102',
        'IT102',
        'Web Development',
        'D01',
        'Computing Studies',
        1.25
    );