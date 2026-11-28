# INFOMAN1 Week 18 Release-Readiness Audit (Ongoing Assessment 6)

*Note: Administrative readiness audit (Ongoing Assessment 6), separate from the final exam score.*

## 1. File Manifest & Source Cross-References

| Deliverable | INFOMAN1 File / Path | Linked Source / Evidence | Status |
|---|---|---|---|
| Final submission & limitations | [`submission.md`](submission.md) | `webdev2` branch `finals` (`docs/week18/submission.md`) | Ready (`<PENDING_UNLISTED_YOUTUBE_URL>`) |
| Final defense rationale & ERD | [`lecture.md`](lecture.md) | `week14/transactions.sql`, `week16/verification.sql` | Ready (awaiting video timestamps) |
| Consolidated SQL & config release | [`release/`](release/) (`01_schema.sql`–`04_access_control.sql`, `backup.sql`, `application-example.properties`) | Matches `webdev2` `finals` JPA schema (`ddl-auto=validate`) | Complete |
| Setup & safe restore runbook | [`setup.md`](setup.md) | Reproduces clean DB install & separate restore | Complete |
| Test matrix & evidence | [`test_matrix.md`](test_matrix.md), [`evidence/`](evidence/) | SQL constraints, savepoints, grants, restore, `18/18` verify | Complete |

## 2. Requirement-to-Document and Video Timestamp Map

| Requirement | Code / Database Artifact | Document / Evidence | Video Timestamp |
|---|---|---|---|
| Relational schema, 3NF, keys, `CHECK` constraints & ERD | `release/01_schema.sql`, `02_seed.sql` | [`lecture.md`](lecture.md), [`evidence/verification_output.txt`](evidence/verification_output.txt) | `<PENDING_TIMESTAMP>` |
| Live joined report view, cardinality & `ON` vs `WHERE` | `pet_appointment_report` (`release/03_views.sql`) | `week16/verification.sql`, [`evidence/verification_output.txt`](evidence/verification_output.txt) | `<PENDING_TIMESTAMP>` |
| Two-resource persisted CRUD & `409` delete policy | `webdev2` (`PetController`, `OwnerController`, `OwnerService.delete`) | [`submission.md`](submission.md), `../week14/evidence/crud_and_rollback_output.txt` | `<PENDING_TIMESTAMP>` |
| Atomic booking commit, post-write rollback & `SAVEPOINT` | `AppointmentService.bookAppointment`, `week14/transactions.sql` | [`evidence/sql_transactions_output.txt`](evidence/sql_transactions_output.txt), `FIN-05`/`FIN-06` | `<PENDING_TIMESTAMP>` |
| Least-privilege runtime/report accounts & `GRANT`/`REVOKE` | `release/04_access_control.sql` (`vetclinic_app`, `vetclinic_report`) | [`evidence/mysql_privileges_output.txt`](evidence/mysql_privileges_output.txt) | `<PENDING_TIMESTAMP>` |
| `EXPLAIN` plan, `mysqldump` backup & separate restore + restart | `release/backup.sql` -> `vetclinic_f5_restore` | [`setup.md`](setup.md), [`evidence/restore_verification_output.txt`](evidence/restore_verification_output.txt), [`evidence/restore_app_workflow.txt`](evidence/restore_app_workflow.txt) | `<PENDING_TIMESTAMP>` |

## 3. Contributor & Scope Declaration

- **Sole Author:** Jan Liam E. Arias (`2510499`, Git author `Jan Liam Arias <100700937+Grudge10@users.noreply.github.com>`).
- **Known Limitations:** Recorded in [`submission.md`](submission.md) (local HTTP dev cookie flag, env-seeded staff logins, sanitized zero-hash `backup.sql`).

## 4. Repository, Video Playback & Submission Checklist

- [x] SQL release bundle (`01_schema.sql`–`04_access_control.sql`, `application-example.properties`, `backup.sql`) verified complete and free of real passwords or password hashes
- [x] Consolidated `evidence/` outputs match `webdev2` `finals` (`18/18` passing tests) and clean restore checks
- [x] Public/grader repository accessibility & final `week18/` URL checked after pushing Week 18 (https://github.com/Grudge10/infoman1/tree/main/week18)
- [ ] Combined walkthrough video uploaded to YouTube as **Unlisted**, signed-out playback & audio clarity verified, and `<PENDING_UNLISTED_YOUTUBE_URL>` + timestamps filled (`<PENDING_CHECK>`)
