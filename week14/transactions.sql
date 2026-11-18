-- Prerequisites: run week13/schema.sql, week13/seed.sql, week13/views.sql, and week14/migration_week14.sql on disposable DB vetclinic_f2_test
-- Execute with: mysql -uroot -h127.0.0.1 -P3307 --force -v -t vetclinic_f2_test < week14/transactions.sql

-- Before state
SELECT id, name, available_slots FROM veterinarian ORDER BY id;
SELECT id, appointment_date, reason, fee, pet_id, vet_id FROM appointment ORDER BY id;

-- 1. Success path: reserve Dr. Reyes (id = 1) slot and insert appointment for Max (pet_id = 3)
START TRANSACTION;
SELECT id, available_slots FROM veterinarian WHERE id = 1 FOR UPDATE;
UPDATE veterinarian SET available_slots = available_slots - 1 WHERE id = 1 AND available_slots > 0;
SELECT ROW_COUNT() AS changed_rows;
INSERT INTO appointment (appointment_date, reason, fee, pet_id, vet_id)
VALUES ('2026-11-24', 'Skin Allergy Check', 650.00, 3, 1);
COMMIT;

-- After commit
SELECT id, name, available_slots FROM veterinarian WHERE id = 1;
SELECT id, appointment_date, reason, fee, pet_id, vet_id FROM appointment ORDER BY id;

-- 2. Failure path after first write: decrement Dr. Villanueva (id = 2) slot, then hit negative fee CHECK error and roll back
START TRANSACTION;
SELECT id, available_slots FROM veterinarian WHERE id = 2 FOR UPDATE;
UPDATE veterinarian SET available_slots = available_slots - 1 WHERE id = 2 AND available_slots > 0;
SELECT ROW_COUNT() AS changed_rows;
INSERT INTO appointment (appointment_date, reason, fee, pet_id, vet_id)
VALUES ('2026-11-25', 'Invalid Fee Test', -50.00, 4, 2);
ROLLBACK;

-- After full rollback (vet 2 remains at 3 slots, no row added for 2026-11-25)
SELECT id, name, available_slots FROM veterinarian WHERE id = 2;
SELECT id, appointment_date, reason, fee, pet_id, vet_id FROM appointment ORDER BY id;

-- 3. Savepoint partial rollback vs full rollback
START TRANSACTION;
SELECT id, available_slots FROM veterinarian WHERE id = 3 FOR UPDATE;
UPDATE veterinarian SET available_slots = available_slots - 1 WHERE id = 3 AND available_slots > 0;
SELECT ROW_COUNT() AS changed_rows;
SAVEPOINT after_slot_lock;

-- Second mutation after savepoint
INSERT INTO appointment (appointment_date, reason, fee, pet_id, vet_id)
VALUES ('2026-11-26', 'Temporary Booking', 550.00, 4, 3);
SELECT id, name, available_slots FROM veterinarian WHERE id = 3;
SELECT id, appointment_date, reason, pet_id, vet_id FROM appointment WHERE pet_id = 4;

-- Undo only the appointment after the savepoint; slot decrement before savepoint stays active
ROLLBACK TO SAVEPOINT after_slot_lock;
SELECT id, name, available_slots FROM veterinarian WHERE id = 3;
SELECT id, appointment_date, reason, pet_id, vet_id FROM appointment WHERE pet_id = 4;

-- Full rollback restores veterinarian 3 back to 3 slots
ROLLBACK;
SELECT id, name, available_slots FROM veterinarian WHERE id = 3;
SELECT id, appointment_date, reason, fee, pet_id, vet_id FROM appointment ORDER BY id;
