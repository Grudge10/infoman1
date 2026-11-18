-- Sanitized Week 15 (F3) MySQL privilege template for Vet Clinic
-- Replace <LOCAL_APP_PASSWORD> and <LOCAL_REPORT_PASSWORD> locally before running as root/admin.
-- Do NOT commit real passwords into Git or run literal placeholder strings.

CREATE USER IF NOT EXISTS 'vetclinic_app'@'localhost' IDENTIFIED BY '<LOCAL_APP_PASSWORD>';
GRANT SELECT, INSERT, UPDATE, DELETE ON webdev2_week8.* TO 'vetclinic_app'@'localhost';

CREATE USER IF NOT EXISTS 'vetclinic_report'@'localhost' IDENTIFIED BY '<LOCAL_REPORT_PASSWORD>';
GRANT SELECT ON webdev2_week8.pet_appointment_report TO 'vetclinic_report'@'localhost';

SHOW GRANTS FOR 'vetclinic_app'@'localhost';
SHOW GRANTS FOR 'vetclinic_report'@'localhost';

-- Revoke test for report identity (run as admin, test denied read as vetclinic_report, then restore)
REVOKE SELECT ON webdev2_week8.pet_appointment_report FROM 'vetclinic_report'@'localhost';
SHOW GRANTS FOR 'vetclinic_report'@'localhost';

-- Restore intended report read privilege
GRANT SELECT ON webdev2_week8.pet_appointment_report TO 'vetclinic_report'@'localhost';
SHOW GRANTS FOR 'vetclinic_report'@'localhost';
