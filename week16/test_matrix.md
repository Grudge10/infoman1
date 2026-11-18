# INFOMAN1 Week 16 Test Matrix (F4)

| ID | Requirement / Case | Preconditions & Input | Expected Result | Actual Observed Result | Status | Evidence / Source |
|---|---|---|---|---|---|---|
| T-01 | Valid Create (`owner`, `pet`) | Authenticated `MANAGER`; new `MC-F4UI` (`Mocha`, `Maria Santos`) | `201 Created`, row persisted in MySQL | Persisted ID 29 with `owner_id=1`, survived reload | Pass | `webdev2/docs/week16/test_matrix.md` |
| T-02 | List & Detail Read | Authenticated `READER`/`MANAGER`; `GET /api/pets`, `GET /api/pets/29` | Paged JSON with `ownerName`; detail matches row | Rendered matching breed & owner | Pass | `webdev2/docs/week16/test_matrix.md` |
| T-03 | Empty Filter Result | `GET /api/pets?species=Bird` | `200 OK` empty `content: []`, UI `"No pets found."` | Clean empty state shown (not an error) | Pass | `webdev2/docs/week16/test_matrix.md` |
| T-04 | Missing Record (`404`) | `GET /api/pets/999999` | `404 Not Found` `ErrorResponse` | `{"status":404,"message":"Pet not found..."}` | Pass | `Week16ApiSecurityTests.java` |
| T-05 | Valid Update (`PUT`) | `PUT /api/pets/29` changing `breed` to `Siamese Mix` | `200 OK`, MySQL row updated | MySQL & `#pet-detail` updated to `Siamese Mix` | Pass | `Week16ApiSecurityTests.java` |
| T-06 | Valid Delete (`204`) | `DELETE /api/pets/29` (no appointments) | `204 No Content`, row removed from `pet` | Deleted cleanly; UI cleared `#pet-detail` | Pass | `webdev2/docs/week16/test_matrix.md` |
| T-07 | Invalid Required / Range (`400`, `CHECK`) | App: `name="A"` (`400`); MySQL: `fee = -10.00` | App returns `400`; MySQL `ERROR 3819` | `400` field error; `ERROR 3819 (chk_appointment_fee)` | Pass | `evidence/verification_output.txt` |
| T-08 | Duplicate Unique (`409`, `ERROR 1062`) | Insert pet with existing `'MC-1001'` | App returns `409`; MySQL `ERROR 1062` | `409` JSON; `ERROR 1062` in `vetclinic_f4_test` | Pass | `evidence/verification_output.txt` |
| T-09 | Invalid FK (`ERROR 1452`) | Insert pet with nonexistent `owner_id = 999` | Rejected by `fk_pet_owner` | `ERROR 1452 (23000): foreign key constraint fails` | Pass | `evidence/verification_output.txt` |
| T-10 | Joined View & `ON` Filter Totals | Run `pet_appointment_report` & `LEFT JOIN ... ON a.fee >= 700.00` | `3` view rows; `Maria=1, Carlos=1, Elena=0` | Exact match; `WHERE` comparison showed Elena dropped | Pass | `evidence/verification_output.txt` |
| T-11 | Atomic Workflow Commit | `Week16MysqlTransactionTests`: `vetId=1`, `petId=4`, `700.00` | `Dr. Reyes` `3 -> 2`, appt count `3 -> 4` | Verified via independent reads on `vetclinic_f4_test` | Pass | `Week16MysqlTransactionTests.java` |
| T-12 | Post-Write Rollback | `Week16MysqlTransactionTests`: `vetId=2`, missing `petId=999999` | Throws `404`, `Dr. Villanueva` stays `3` slots | `available_slots = 3`, appts = `3` | Pass | `Week16MysqlTransactionTests.java` |
| T-13 | Runtime Privilege Denial | `vetclinic_app@localhost` attempts `CREATE TABLE` | `ERROR 1142` (`CREATE` denied) | `ERROR 1142` recorded in Week 15 evidence | Pass | `../week15/evidence/mysql_privileges_output.txt` |
| T-14 | Report Privilege & `REVOKE` Denial | `vetclinic_report@localhost` tries `SELECT`/`INSERT` on `owner` & post-`REVOKE` view read | `ERROR 1142` on `owner`, `ERROR 1044` after `REVOKE` | Verified then restored `GRANT SELECT` | Pass | `../week15/evidence/mysql_privileges_output.txt` |
