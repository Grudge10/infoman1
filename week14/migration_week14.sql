-- Run after week13/schema.sql and week13/seed.sql on the target Vet Clinic database

ALTER TABLE veterinarian
    ADD COLUMN available_slots INT NOT NULL DEFAULT 3,
    ADD CONSTRAINT chk_vet_available_slots CHECK (available_slots >= 0);

ALTER TABLE appointment
    ADD CONSTRAINT uq_appointment_pet_date UNIQUE (pet_id, appointment_date);
