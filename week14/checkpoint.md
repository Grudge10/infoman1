# INFOMAN1 Week 14 Checkpoint Report (F2)

**Name:** Jan Liam E. Arias  
**Student ID:** 2510499  
**INFOMAN1 Repo:** https://github.com/Grudge10/infoman1 (`week14/`)  
**Linked WEBDEV2 Application:** https://github.com/Grudge10/webdev2 (branch `week14`, application root `/`)  
**MySQL Version:** 8.4.13 (InnoDB)  
**Date Submitted:** 2026-11-18  

## 1. Prerequisites and Execution Order

Run against MySQL `8.4.13` in this exact order on a disposable database (`vetclinic_f2_test`) or synced `webdev2_week8`:
1. `week13/schema.sql` (base tables `owner`, `veterinarian`, `pet`, `appointment`)
2. `week13/seed.sql` (initial owners, veterinarians, pets, appointments)
3. `week13/views.sql` (`pet_appointment_report` view)
4. `week14/migration_week14.sql` (adds `veterinarian.available_slots`, `chk_vet_available_slots`, and `uq_appointment_pet_date`)
5. `week14/transactions.sql` (commit, post-first-write rollback, and savepoint scenarios)

```bash
$HOME/dev-tools/mysql/bin/mysqld --basedir=$HOME/dev-tools/mysql --datadir=$HOME/dev-tools/mysql-data --port=3307 --socket=/tmp/mysql.sock
$HOME/dev-tools/mysql/bin/mysql -uroot -h127.0.0.1 -P3307 -e "CREATE DATABASE vetclinic_f2_test;"
sed 's/webdev2_week8/vetclinic_f2_test/g' week13/schema.sql | $HOME/dev-tools/mysql/bin/mysql -uroot -h127.0.0.1 -P3307
sed 's/webdev2_week8/vetclinic_f2_test/g' week13/seed.sql | $HOME/dev-tools/mysql/bin/mysql -uroot -h127.0.0.1 -P3307
sed 's/webdev2_week8/vetclinic_f2_test/g' week13/views.sql | $HOME/dev-tools/mysql/bin/mysql -uroot -h127.0.0.1 -P3307
$HOME/dev-tools/mysql/bin/mysql -uroot -h127.0.0.1 -P3307 vetclinic_f2_test < week14/migration_week14.sql
$HOME/dev-tools/mysql/bin/mysql -uroot -h127.0.0.1 -P3307 --force -v -t vetclinic_f2_test < week14/transactions.sql
```

## 2. Requirements and Evidence Mapping

| Requirement | Database / App Artifact | Evidence File |
|---|---|---|
| REQ-1: Persisted CRUD for `owner` and `pet` | `OwnerController`, `PetController`, `OwnerService`, `PetService` (`webdev2` `week14`) | `evidence/crud_and_rollback_output.txt` |
| REQ-2: Deliberate `409` delete policy without disabling FK checks | `OwnerService.delete`, `PetService.delete`, MySQL FK constraints | `evidence/crud_and_rollback_output.txt` |
| REQ-3: Atomic booking transaction path | `AppointmentController.bookAppointment` -> `AppointmentService.bookAppointment` (`@Transactional`) -> `VeterinarianRepository.decrementSlotIfAvailable` -> `AppointmentRepository.saveAndFlush` | `evidence/app_transaction_mysql_check.txt` |
| REQ-4: Commit & failure rollback after first write (SQL + App) | `week14/transactions.sql` Cases 1–2 & `POST /api/appointments/book` rollback check | `evidence/sql_transactions_output.txt`, `evidence/crud_and_rollback_output.txt` |
| REQ-5: Savepoint partial rollback vs full rollback | `week14/transactions.sql` Case 3 (`SAVEPOINT after_slot_lock`) | `evidence/sql_transactions_output.txt` |

## 3. Actual vs Expected Results

| Check | Expected | Actual Observed Result | Status |
|---|---|---|---|
| `migration_week14.sql` on `vetclinic_f2_test` | Adds `available_slots` (`DEFAULT 3`, `CHECK >= 0`) and `uq_appointment_pet_date` | Clean execution on MySQL `8.4.13` after `week13` scripts | Pass |
| SQL Case 1 (`COMMIT`) | `Dr. Reyes` `3 -> 2` (`ROW_COUNT() = 1`), appointment #4 added and visible in separate connection + view | Separate client connection showed `Dr. Reyes = 2`, 4 appointments, and `Max` in `pet_appointment_report` | Pass |
| SQL Case 2 (Failure + `ROLLBACK`) | `Dr. Villanueva` decremented, negative fee `-50.00` fails `CHECK`, `ROLLBACK` restores `3` | `ERROR 3819 (HY000)` occurred; after `ROLLBACK`, `Dr. Villanueva = 3` and no `2026-11-25` row | Pass |
| SQL Case 3 (`SAVEPOINT after_slot_lock`) | `ROLLBACK TO SAVEPOINT` undoes second write (`Temporary Booking`) keeping slot `2`; final `ROLLBACK` restores `3` | Confirmed step-by-step in `sql_transactions_output.txt` | Pass |
| App CRUD (`owner` & `pet`) | `POST 201`, `PUT 200`, `PATCH 200`, `DELETE 204`, `409` on referenced parent deletes & duplicate microchip | All status codes and database state matched (`crud_and_rollback_output.txt`) | Pass |
| App Atomic Booking Commit (Browser UI) | Booking Milo + Dr. Reyes commits slot `3 -> 2` and inserts row #5 in `webdev2_week8` | `app_transaction_mysql_check.txt` confirmed `Dr. Reyes = 2` and `Ear Check` in `appointment` and `pet_appointment_report` | Pass |
| App Failure Rollback (`409` & `404` after Write #1) | After `decrementSlotIfAvailable`, missing `petId=999` or duplicate pet/date rolls back slot update | `Dr. Villanueva` remained `available_slots = 3` and `appt_count` remained `4` | Pass |

## 4. Known Issues and Notes

- `webdev2_week8` was synced, with `appointment.fee` and Dr. Ramos having schema/seed values adjusted to match `week13/schema.sql` and `week13/seed.sql`. Then constraints were added from `week14`.
- MySQL `GRANT`/`REVOKE` permissions are in `week15` (`F3`).

## 5. Evidence Files

- [evidence/sql_transactions_output.txt](evidence/sql_transactions_output.txt)
- [evidence/app_transaction_mysql_check.txt](evidence/app_transaction_mysql_check.txt)
- [evidence/crud_and_rollback_output.txt](evidence/crud_and_rollback_output.txt)
