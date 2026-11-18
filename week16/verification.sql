-- Week 16 (F4): Report verification, outer-join vs WHERE check, constraints, and EXPLAIN
-- Prerequisites: vetclinic_f4_test created from week13/schema.sql, seed.sql, views.sql, week14/migration_week14.sql, week15/migration_week15.sql
-- Execute with: mysql -uroot -h127.0.0.1 -P3307 --force -v -t vetclinic_f4_test < week16/verification.sql

-- 1. View report output vs expected base rows
SELECT appointment_id, appointment_date, reason, pet_name, species, owner_name, vet_name, specialty
FROM pet_appointment_report
ORDER BY appointment_date, appointment_id;

-- 2. One-to-many join cardinality: Maria Santos owns Buddy (1 appt) and Bantay (1 appt), Carlos owns Luna (1 appt) and Max (0 appts), Elena owns Milo (0 appts)
SELECT o.id,
       o.name AS owner_name,
       COUNT(*) AS raw_joined_rows,
       COUNT(DISTINCT p.id) AS distinct_pets,
       COUNT(a.id) AS total_appointments
FROM owner o
LEFT JOIN pet p ON p.owner_id = o.id
LEFT JOIN appointment a ON a.pet_id = p.id
GROUP BY o.id, o.name
ORDER BY o.id;

-- 3. Filter in ON preserves owners with 0 matching appointments >= 700.00 (Elena = 0 instead of vanishing)
SELECT o.id,
       o.name AS owner_name,
       COUNT(a.id) AS high_fee_appointments
FROM owner o
LEFT JOIN pet p ON p.owner_id = o.id
LEFT JOIN appointment a ON a.pet_id = p.id AND a.fee >= 700.00
GROUP BY o.id, o.name
ORDER BY o.id;

-- Contrast: putting child filter in WHERE turns LEFT JOIN into an inner filter and drops Elena
SELECT o.id,
       o.name AS owner_name,
       COUNT(a.id) AS high_fee_appointments
FROM owner o
LEFT JOIN pet p ON p.owner_id = o.id
LEFT JOIN appointment a ON a.pet_id = p.id
WHERE a.fee >= 700.00
GROUP BY o.id, o.name
ORDER BY o.id;

-- 4. Real MySQL constraint rejections (negative checks)
INSERT INTO pet (microchip_number, name, species, breed, owner_id)
VALUES ('MC-1001', 'DuplicateChip', 'Dog', 'Aspin', 1);

INSERT INTO pet (microchip_number, name, species, breed, owner_id)
VALUES ('MC-8888', 'BadOwner', 'Cat', 'Siamese', 999);

INSERT INTO appointment (appointment_date, reason, fee, pet_id, vet_id)
VALUES ('2026-12-20', 'Negative Fee', -10.00, 1, 1);

-- 5. EXPLAIN plan on owner/pet/appointment report join
EXPLAIN
SELECT o.id, o.name, COUNT(DISTINCT p.id) AS pets, COUNT(a.id) AS appointments
FROM owner o
LEFT JOIN pet p ON p.owner_id = o.id
LEFT JOIN appointment a ON a.pet_id = p.id AND a.fee >= 700.00
GROUP BY o.id, o.name
ORDER BY o.id;
