-- Join report view using SQL SECURITY INVOKER? Kept SQL SECURITY DEFINER (default)
-- when installed by schema maintainer so read-only report accounts need only view SELECT.

CREATE OR REPLACE VIEW pet_appointment_report AS
SELECT a.id AS appointment_id,
       a.appointment_date,
       a.reason,
       p.id AS pet_id,
       p.microchip_number,
       p.name AS pet_name,
       p.species,
       o.name AS owner_name,
       v.name AS vet_name,
       v.specialty
FROM appointment a
JOIN pet p ON p.id = a.pet_id
LEFT JOIN owner o ON o.id = p.owner_id
JOIN veterinarian v ON v.id = a.vet_id;
