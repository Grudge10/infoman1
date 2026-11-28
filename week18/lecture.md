# INFOMAN1 Week 18 Final Database Defense Notes

**Name:** Jan Liam E. Arias (`2510499`)  
**INFOMAN1 Folder:** `week18/`  
**Linked WEBDEV2 Branch:** `finals`  

## 1. Relational Schema, Functional Dependencies, and Normalization (`<01:30>`)

```text
owner (id PK, name NOT NULL, phone)
  | 1
  | 0..* (fk_pet_owner, ON DELETE RESTRICT, owner_id nullable)
pet (id PK, microchip_number UNIQUE NOT NULL, name NOT NULL, species NOT NULL, breed, owner_id FK NULL)
  | 1
  | 0..* (fk_appointment_pet, uq_appointment_pet_date (pet_id, appointment_date))
appointment (id PK, appointment_date NOT NULL, reason NOT NULL, fee DECIMAL(8,2) CHECK >= 0.00, pet_id FK NOT NULL, vet_id FK NOT NULL)
  | 0..*
  | 1 (fk_appointment_vet)
veterinarian (id PK, name NOT NULL, specialty, available_slots INT DEFAULT 3 CHECK >= 0)

clinic_account (id PK, username UNIQUE NOT NULL, password_hash NOT NULL, role CHECK IN ('READER','MANAGER'), enabled BIT(1))
```

The Vet Clinic database has 4 normalized InnoDB tables (`owner`, `veterinarian`, `pet`, and `appointment`), plus a `clinic_account` table to allow users to log in using Spring Security (`week18/release/01_schema.sql`).

Functional Dependencies & 3NF: `owner.id -> name, phone` and `pet.id -> microchip_number, name, species, breed, owner_id`. Including `owner.phone` in `pet` or `appointment` tables would cause repetition and update errors when it was changed. By having `owner` as a separate table and a foreign key (`fk_pet_owner` with `ON DELETE RESTRICT` constraints) in `pet` (with `409 Conflict` validation in `OwnerService.delete`), owner data is consolidated. However, in order to allow pets with no owner (stray pets), `owner_id` in `pet` can be `NULL`.

Constraints: `pet` has a `UNIQUE` constraint on `microchip_number`. `appointment` has a `CHECK` constraint to enforce `fee >= 0.00` (`chk_appointment_fee`). `veterinarian` has a `CHECK` constraint to enforce `available_slots >= 0` (`chk_vet_available_slots`). An appointment cannot be made twice on the same day for the same pet; this is enforced by a `UNIQUE` constraint on `pet_id` and `appointment_date` in MySQL and Java (`uq_appointment_pet_date`) (`week18/evidence/verification_output.txt`).

## 2. Live SQL View, Join Cardinality, and `EXPLAIN` (`<03:00>`)

The view `pet_appointment_report` (`week18/release/03_views.sql`) performs an `INNER JOIN` of `appointment`, `pet`, and `veterinarian`, and a `LEFT JOIN` of `owner` (`SQL SECURITY DEFINER`). If we update records in the underlying tables (`pet`/`owner`), we can see these changes instantly in this view. In `week16/verification.sql`, we determined the join cardinality (one-to-many). We also showed that including the condition `a.fee >= 700.00` in a `LEFT JOIN` ensures owners with zero matching results are shown (Elena Cruz with `0` appointments), whereas putting the condition `a.fee >= 700.00` in the `WHERE` clause makes it an `INNER JOIN`, meaning that Elena will be excluded (`week18/evidence/verification_output.txt`).

`EXPLAIN` shows that we are using indexes with `fk_pet_owner` (`ref`, covering index) and `uq_appointment_pet_date` (`ref`). However, due to the small size of seed data (`3` rows), `owner` is scanned with `ALL`.

## 3. Atomic Workflow, Rollback, Savepoints, and Concurrency (`<05:00>`)

In `week14/transactions.sql` and `AppointmentService.bookAppointment` (`@Transactional`), we check and decrement `available_slots` of the vet based on `id` (`:id`) and `available_slots` (`available_slots > 0`). However, if any error occurs after this change (i.e., `chk_appointment_fee` with `ERROR 3819`, or invalid `petId` `999999`, or duplicate `(pet_id, appointment_date)` in `Week16MysqlTransactionTests`), `available_slots` will be rolled back so that there are no partial commits.

In `week14/transactions.sql`, we can verify savepoints were used in Case 3 (`week18/evidence/sql_transactions_output.txt`). Rolling back to the savepoint `after_slot_lock` only rolled back the `Temporary Booking`, but did not revert Dr. Ramos's available slots to `3` (it was still `2` within the transaction). However, the final rollback reverted Dr. Ramos's available slots to `3`. By checking `available_slots > 0` and only allowing an update if it affects one row (`ROW_COUNT() = 1` / `changed == 1`), we avoid concurrent requests exceeding the last available slot.

## 4. Least-Privilege Access Control, Backup/Restore, and Individual Diagnosis (`<07:00>–<09:00>`)

`vetclinic_app@localhost` has `SELECT`, `INSERT`, `UPDATE`, and `DELETE` permissions (`ddl-auto` set to `validate`). A `CREATE TABLE` command produces `ERROR 1142`. `vetclinic_report@localhost` has `SELECT` access to `pet_appointment_report` only. Trying to `SELECT` on the `owner` table produces `ERROR 1142`. After removing `SELECT` grants (`REVOKE`), `ERROR 1044` occurs. Re-granting `SELECT` (`GRANT`) remedies the issue (`week18/evidence/mysql_privileges_output.txt`).

Separate-target backup and restore (using `mysqldump` with `--single-transaction --no-tablespaces --set-gtid-purged=OFF` into `week18/release/backup.sql`, restored into `vetclinic_f5_restore`) confirmed the same number of entries as pre-backup. The view output was verified, the rejection of `chk_appointment_fee` was observed, and the packaged JAR file was restarted and found to retain data (`ReleasePup` in `week18/evidence/restore_app_workflow.txt`).

Personal Contributions and Troubleshooting: Authored the schema migrations, SQL transaction/privilege scripts, REST/security implementation, simple UI, and JUnit and MySQL tests. Problems faced: Hibernate `ddl-auto=validate` failed due to residual entities from `prelim` and `week9`. This was solved by removing outdated classes within `week16`, so that `webdev2` matches `week18/release/01_schema.sql`. It was also discovered that `GRANT` statements on tables and views must be executed after restore (see [setup.md](setup.md)).
