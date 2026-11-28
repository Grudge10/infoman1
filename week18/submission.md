# INFOMAN1 Week 18 Final Submission (Finals)

**Student Name:** Jan Liam E. Arias (`2510499`) — Sole individual contributor (no group collaborators)  
**INFOMAN1 Repository:** https://github.com/Grudge10/infoman1  
**INFOMAN1 Final Folder:** [`week18/`](https://github.com/Grudge10/infoman1/tree/main/week18) (`release/` bundle inside [`week18/release/`](release/))  
**Linked WEBDEV2 Application:** https://github.com/Grudge10/webdev2 (branch `finals`, application root `/`)  
**Date Submitted:** 2026-11-22  

## Walkthrough Recording (To Be Filled After Screen Recording)

- **Unlisted YouTube Video URL:** `<PENDING_UNLISTED_YOUTUBE_URL>`
- **Signed-Out Playback Verified:** `<PENDING_PRIVATE_WINDOW_CHECK>`

| Timestamp | Database & Integration Section Covered | Evidence / Scripts Shown |
|---|---|---|
| `<00:00>` | Identity, Vet Clinic problem, [`week18/release/`](release/), `webdev2` branch `finals` | [setup.md](setup.md), [submission.md](submission.md) |
| `<01:30>` | ERD, 3NF functional dependencies (`owner`, `veterinarian`, `pet`, `appointment`), PK/FK/`CHECK` & `409` delete policy | [lecture.md](lecture.md), [release/01_schema.sql](release/01_schema.sql) |
| `<03:00>` | Persisted CRUD (`owner`, `pet`), invalid/duplicate rejections (`1062`/`1452`/`3819`), `pet_appointment_report` view + `ON` vs `WHERE` | [../week16/verification.sql](../week16/verification.sql), [evidence/verification_output.txt](evidence/verification_output.txt) |
| `<05:00>` | Atomic booking (`veterinarian.available_slots` + `appointment`) commit, post-write failure rollback & `SAVEPOINT after_slot_lock` | [../week14/transactions.sql](../week14/transactions.sql), [evidence/sql_transactions_output.txt](evidence/sql_transactions_output.txt) |
| `<07:00>` | Restricted `vetclinic_app@localhost` (`ddl-auto=validate`), `vetclinic_report@localhost` `GRANT`/`REVOKE`/`RESTORE` | [release/04_access_control.sql](release/04_access_control.sql), [evidence/mysql_privileges_output.txt](evidence/mysql_privileges_output.txt) |
| `<09:00>` | `EXPLAIN` plan, `mysqldump` backup & separate-target `vetclinic_f5_restore` verification + restart persistence | [setup.md](setup.md), [evidence/restore_verification_output.txt](evidence/restore_verification_output.txt) |

## Known Limitations

Only one host is supported at this stage (http://localhost:8080). If deployed publicly, SSL must be terminated (`COOKIE_SECURE` must be set to `true`). Staff accounts (`READER`/`MANAGER`) are created using `APP_SEED_*` environment variables during setup. The [release/backup.sql](release/backup.sql) file contains zero rows within the `clinic_account` table to prevent accidental exposure of password hashes in Git. Within `pet_appointment_report`, clinical information and reasons can be seen without revealing the cost of appointments to `vetclinic_report`.

## Key Documentation References

- [Final Database Defense Notes](lecture.md)
- [Setup, Smoke Test & Safe Restore Guide](setup.md)
- [Final Test Matrix](test_matrix.md) & [Evidence Folder](evidence/)
- [Consolidated SQL Release Bundle](release/)
- [Release-Readiness Audit (Ongoing Assessment 6)](readiness.md)
- [Milestone Index & Checkpoint](checkpoint.md)
