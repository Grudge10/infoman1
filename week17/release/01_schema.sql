-- Clean consolidated Vet Clinic schema (F1 + F2 + F3)
-- Target database must already exist and be selected (e.g. mysql ... <target_db> < release/01_schema.sql)

CREATE TABLE IF NOT EXISTS owner (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(30) DEFAULT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS veterinarian (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100) DEFAULT NULL,
    available_slots INT NOT NULL DEFAULT 3,
    CONSTRAINT chk_vet_available_slots CHECK (available_slots >= 0)
) ENGINE=InnoDB;

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
    CONSTRAINT chk_appointment_fee CHECK (fee >= 0.00),
    CONSTRAINT uq_appointment_pet_date UNIQUE (pet_id, appointment_date)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS clinic_account (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(100) NOT NULL,
    role VARCHAR(30) NOT NULL,
    enabled BIT(1) NOT NULL DEFAULT b'1',
    CONSTRAINT chk_clinic_account_role CHECK (role IN ('READER', 'MANAGER'))
) ENGINE=InnoDB;
