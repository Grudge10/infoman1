CREATE DATABASE IF NOT EXISTS webdev2_week8;
USE webdev2_week8;

-- parent tables
CREATE TABLE IF NOT EXISTS owner (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(30) DEFAULT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS veterinarian (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100) DEFAULT NULL
) ENGINE=InnoDB;

-- child tables
CREATE TABLE IF NOT EXISTS pet (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    microchip_number VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    species VARCHAR(50) NOT NULL,
    breed VARCHAR(100) DEFAULT NULL,
    owner_id BIGINT DEFAULT NULL,
    CONSTRAINT fk_pet_owner FOREIGN KEY (owner_id) REFERENCES owner(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS appointment (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    appointment_date DATE NOT NULL,
    reason VARCHAR(255) NOT NULL,
    fee DECIMAL(8,2) NOT NULL DEFAULT 500.00,
    pet_id BIGINT NOT NULL,
    vet_id BIGINT NOT NULL,
    CONSTRAINT fk_appointment_pet FOREIGN KEY (pet_id) REFERENCES pet(id),
    CONSTRAINT fk_appointment_vet FOREIGN KEY (vet_id) REFERENCES veterinarian(id),
    CONSTRAINT chk_appointment_fee CHECK (fee >= 0.00)
) ENGINE=InnoDB;
