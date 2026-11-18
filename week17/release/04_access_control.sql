-- Sanitized privilege template for release databases.
-- Replace <TARGET_DB> and <LOCAL_*_PASSWORD> locally before running as admin.

CREATE USER IF NOT EXISTS 'vetclinic_app'@'localhost' IDENTIFIED BY '<LOCAL_APP_PASSWORD>';
GRANT SELECT, INSERT, UPDATE, DELETE ON <TARGET_DB>.* TO 'vetclinic_app'@'localhost';

CREATE USER IF NOT EXISTS 'vetclinic_report'@'localhost' IDENTIFIED BY '<LOCAL_REPORT_PASSWORD>';
GRANT SELECT ON <TARGET_DB>.pet_appointment_report TO 'vetclinic_report'@'localhost';

CREATE USER IF NOT EXISTS 'vetclinic_backup'@'localhost' IDENTIFIED BY '<LOCAL_BACKUP_PASSWORD>';
GRANT SELECT, SHOW VIEW, LOCK TABLES ON <TARGET_DB>.* TO 'vetclinic_backup'@'localhost';

SHOW GRANTS FOR 'vetclinic_app'@'localhost';
SHOW GRANTS FOR 'vetclinic_report'@'localhost';
SHOW GRANTS FOR 'vetclinic_backup'@'localhost';
