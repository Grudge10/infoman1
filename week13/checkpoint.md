# INFOMAN1 Week 13 Checkpoint Report (F1)

**Name:** Jan Liam E. Arias  
**Student ID:** 2510499  
**INFOMAN1 Repo:** https://github.com/Grudge10/infoman1 (folder `week13/`)  
**Linked WEBDEV2 Application:** https://github.com/Grudge10/webdev2 (branch `week13`, application root `/`)  
**MySQL Version:** 8.4.13 (InnoDB)  
**Date Submitted:** 2026-11-17

## 1. Execution Order and Setup Commands

Run the SQL scripts in order inside a MySQL `8.0.16+` server:
1. `week13/schema.sql` (creates database `webdev2_week8` if missing and creates parent tables `owner` and `veterinarian` before child tables `pet` and `appointment`)
2. `week13/seed.sql` (inserts fictional owners, veterinarians, linked pets, and appointments)
3. `week13/views.sql` (creates `pet_appointment_report` view and runs the summary query)

```bash
$HOME/dev-tools/mysql/bin/mysqld --basedir=$HOME/dev-tools/mysql --datadir=$HOME/dev-tools/mysql-data --port=3307 --socket=/tmp/mysql.sock --mysqlx=OFF
$HOME/dev-tools/mysql/bin/mysql -uroot -h127.0.0.1 -P3307 < week13/schema.sql
$HOME/dev-tools/mysql/bin/mysql -uroot -h127.0.0.1 -P3307 < week13/seed.sql
$HOME/dev-tools/mysql/bin/mysql -uroot -h127.0.0.1 -P3307 < week13/views.sql
```

- **Schema Ownership:** The `week13/schema.sql` file contains the complete re-creation of the database including `CHECK` constraints and `fee` column. The `webdev2` Spring Boot application uses `spring.jpa.hibernate.ddl-auto=update` so the manual constraints and views are not dropped.
- **Configuration Variables (Placeholders in `webdev2` `application-example.properties`):** `DB_USERNAME`, `DB_PASSWORD`, and `spring.datasource.url`. No real secrets are committed.

## 2. Requirements and Evidence Table

| Requirement | Database / App Artifact | Evidence File |
|---|---|---|
| REQ-1: Read paged pets with owner name | `pet` + `owner` tables, `webdev2` `PetDTO` and `PetController` | `evidence/app_read_match.txt` |
| REQ-2: Single pet detail read by ID | `webdev2` `GET /api/pets/1` matching MySQL `pet.id = 1` | `evidence/app_read_match.txt` |
| REQ-3: Owners read endpoint (`webdev2`) | `owner` table and `OwnerController` (`/api/owners`) | `evidence/schema_inspection.txt` |
| REQ-4: Unique microchip enforcement | `pet.microchip_number` `UNIQUE` constraint in `week13/schema.sql` | `evidence/constraint_rejections.txt` |
| REQ-5: FK owner and non-negative fee rules | `fk_pet_owner`, `chk_appointment_fee` in `week13/schema.sql` | `evidence/constraint_rejections.txt` |
| REQ-6: Live join view report | `pet_appointment_report` in `week13/views.sql` | `evidence/view_before_after.txt` |

## 3. Actual vs Expected Results

| Check | Expected | Actual Observed Result | Status |
|---|---|---|---|
| Clean rebuild in `vetclinic_f1_test` | `schema.sql`, `seed.sql`, and `views.sql` execute cleanly | All 4 tables and `pet_appointment_report` created on MySQL `8.4.13` with 3 appointments returned | Pass |
| Base row update reflected in view | Updating `MC-1001` to `Buddy Jr.` shows in view immediately | `view_before_after.txt` switched from `Buddy` to `Buddy Jr.` without recreating the view | Pass |
| Duplicate `microchip_number` `'MC-1001'` | Insert rejected by `UNIQUE` key | `ERROR 1062 (23000): Duplicate entry 'MC-1001' for key 'pet.microchip_number'` | Pass |
| Invalid `owner_id = 999` insert | Insert rejected by `fk_pet_owner` | `ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails` | Pass |
| Negative `fee = -50.00` insert | Insert rejected by `chk_appointment_fee` | `ERROR 3819 (HY000): Check constraint 'chk_appointment_fee' is violated.` | Pass |
| `webdev2` API vs SQL `SELECT` match | `GET /api/pets` and `/api/pets/1` match `webdev2_week8` rows | Both returned `Buddy`, `MC-1001`, `Golden Retriever`, `Maria Santos` | Pass |

## 4. Known Issues and Scope Notes

- The old `webdev2` Hibernate tables (MySQL `webdev2_week8.appointment`) do not have the `fee` column and therefore, the clean schema, `fee`, and check constraint tests were run on the `vetclinic_f1_test` disposable database. `views.sql` was also run on the `vetclinic_f1_test` and `webdev2_week8` databases.
- The previous `webdev2` lab tables (`app_users`, `department`, `employee`, `student`, `course`, `enrollment`) are still within the `webdev2_week8` database but do not affect the Vet Clinic queries.
- Rollbacks/savepoints are for `week14` (F2). Limited MySQL app permissions are for `week15` (F3).

## 5. Change Log and Evidence

1. `add week 13 schema, seed, and view sql`
2. `add week 13 evidence outputs`
3. `add week 13 lecture.md and checkpoint.md`

- [evidence/schema_inspection.txt](evidence/schema_inspection.txt)
- [evidence/app_read_match.txt](evidence/app_read_match.txt)
- [evidence/view_before_after.txt](evidence/view_before_after.txt)
- [evidence/constraint_rejections.txt](evidence/constraint_rejections.txt)
