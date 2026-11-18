# INFOMAN1 Week 17 Backup and Restore Verification Report (F5)

**Name:** Jan Liam E. Arias  
**Source Database:** `vetclinic_f5_source` (cleanly built from `release/01_schema.sql`–`03_views.sql`)  
**Restore Target Database:** `vetclinic_f5_restore` (fresh empty database; working `webdev2_week8` untouched)  
**Tool Versions:** MySQL Server `8.4.13`, `mysqldump` (`8.4.13`)  
**Sanitized Backup File:** [backup.sql](backup.sql) (contains fictional seed rows + view only; `0` `clinic_account` credentials or hashes)  

## 1. Commands & Portability Findings

Backup command (with password supplied outside Git): `mysqldump -uvetclinic_backup -p -h127.0.0.1 -P3307 --single-transaction --no-tablespaces --set-gtid-purged=OFF vetclinic_f5_source > week17/backup.sql`.

The `backup.sql` file does not contain `CREATE DATABASE` or `USE` statements, and line `195` shows `/*!50013 DEFINER='root'@'localhost' SQL SECURITY DEFINER */` for view `pet_appointment_report`. Therefore, it was restored by the local maintenance user (`root@localhost`), who created the `vetclinic_f5_restore` objects and subsequent grants. When running `GRANT SELECT ON vetclinic_f5_restore.pet_appointment_report` before importing `backup.sql`, `ERROR 1146` occurred, whereas importing `backup.sql` first followed by `GRANT` worked cleanly.

## 2. Post-Restore Verification (`vetclinic_f5_restore`)

The row counts matched the source database across `owner` (`3`), `veterinarian` (`3`), `pet` (`5`), `appointment` (`3`), and `clinic_account` (`0`), and all business data matched: `Buddy` (`MC-1001`), `Bantay` (`MC-1005`), the three veterinarians (with `available_slots = 3`), and three rows in `pet_appointment_report` (`3` rows read by `vetclinic_report@localhost`). Inserting data into the `appointment` table with `fee = -1.00` raised `ERROR 3819 (HY000)` (`chk_appointment_fee`). Finally, running `java -jar webdev2-0.0.1-SNAPSHOT.jar` against `vetclinic_f5_restore` as `vetclinic_app@localhost` (`ddl-auto=validate`) passed `POST /api/pets` (`ReleasePup`, `201`), atomic `POST /api/appointments/book` (`Dr. Reyes` `3 -> 2`, `201`), and failure rollback (`petId=9999` -> `404`, `Dr. Villanueva` remained at `3`), with data persisting after restarting the server ([evidence/restore_verification_output.txt](evidence/restore_verification_output.txt), [evidence/restore_app_workflow.txt](evidence/restore_app_workflow.txt)).
