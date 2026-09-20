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

