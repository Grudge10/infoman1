USE infoman1_vetclinic;

-- TASK 1
-- returns every column and every row
SELECT * FROM pet;

-- returns only the name and species columns
SELECT name, species FROM pet;

-- TASK 2
-- returns the name and species of every pet whose species equals 'Dog'
SELECT name, species FROM pet WHERE species = 'Dog';

-- TASK 3
-- numeric threshold: pets aged 3 or older (number unquoted)
SELECT name, age FROM pet WHERE age >= 3;

-- date threshold: appointments after jan 1, 2024 (date quoted)
SELECT appointment_date, reason_for_visit FROM appointment WHERE appointment_date > '2024-01-01';

-- TASK 4
-- Original working query: specific column list + WHERE filter on a string column, correctly quoted.
-- Observed result: returned 1 row (| Whiskers | Cat     |    3 |), exactly as expected.
SELECT name, species, age FROM pet WHERE species = 'Cat';

-- Deliberately broken copy: the single quotes around 'Cat' were removed.
-- Observed behavior: ERROR 1054 (42S22): Unknown column 'Cat' in 'where clause'.
-- Explanation: without quotes, MySQL interprets Cat as a column identifier instead of a string literal, so it looks for a nonexistent column called Cat instead of comparing the species to the text value of 'Cat'.
SELECT name, species, age FROM pet WHERE species = Cat;

