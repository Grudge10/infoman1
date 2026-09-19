-- TASK1
CREATE DATABASE infoman1_vetclinic;
USE infoman1_vetclinic;
SHOW DATABASES;

-- TASK2
CREATE TABLE owner (
    owner_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number INT NOT NULL
);

CREATE TABLE pet (
    pet_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    species VARCHAR(50) NOT NULL,
    age INT,
    owner_id INT NOT NULL,
    FOREIGN KEY (owner_id) REFERENCES owner(owner_id)
);

CREATE TABLE veterinarian (
    vet_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL
);

CREATE TABLE vet_specialization (
    vet_id INT NOT NULL,
    specialization_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (vet_id, specialization_name),
    FOREIGN KEY (vet_id) REFERENCES veterinarian(vet_id)
);