USE infoman1_vetclinic;

-- TASK 1
-- returns every column and every row
SELECT * FROM pet;

-- returns only the name and species columns
SELECT name, species FROM pet;

-- TASK 2
-- returns the name and species of every pet whose species equals 'Dog'
SELECT name, species FROM pet WHERE species = 'Dog';

