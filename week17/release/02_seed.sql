-- Fictional domain seed data for clean database installation

INSERT INTO owner (id, name, phone) VALUES
(1, 'Maria Santos', '09181112222'),
(2, 'Carlos Mendoza', '09172223333'),
(3, 'Elena Cruz', '09193334444');

INSERT INTO veterinarian (id, name, specialty, available_slots) VALUES
(1, 'Dr. Reyes', 'Surgery', 3),
(2, 'Dr. Villanueva', 'General Practice', 3),
(3, 'Dr. Ramos', 'Dermatology', 3);

INSERT INTO pet (id, microchip_number, name, species, breed, owner_id) VALUES
(1, 'MC-1001', 'Buddy', 'Dog', 'Golden Retriever', 1),
(2, 'MC-1002', 'Luna', 'Cat', 'Siamese', 2),
(3, 'MC-1003', 'Max', 'Dog', 'German Shepherd', 2),
(4, 'MC-1004', 'Milo', 'Cat', 'Persian', 3),
(5, 'MC-1005', 'Bantay', 'Dog', 'Aspin', 1);

INSERT INTO appointment (id, appointment_date, reason, fee, pet_id, vet_id) VALUES
(1, '2026-11-12', 'Annual Checkup', 500.00, 5, 1),
(2, '2026-11-18', 'Vaccination Booster', 750.00, 1, 2),
(3, '2026-11-20', 'Dental Cleaning', 1200.00, 2, 1);
