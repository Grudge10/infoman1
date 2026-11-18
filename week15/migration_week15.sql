-- Maintainer migration for Week 15 (F3): application user accounts table
-- Run as maintainer/admin before starting webdev2 with spring.jpa.hibernate.ddl-auto=validate

USE webdev2_week8;

CREATE TABLE IF NOT EXISTS clinic_account (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(100) NOT NULL,
    role VARCHAR(30) NOT NULL,
    enabled BIT(1) NOT NULL DEFAULT b'1',
    CONSTRAINT chk_clinic_account_role CHECK (role IN ('READER', 'MANAGER'))
) ENGINE=InnoDB;
