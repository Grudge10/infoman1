# INFOMAN1 Week 17 Checkpoint Report (F5)

**Name:** Jan Liam E. Arias  
**Student ID:** 2510499  
**INFOMAN1 Repo:** https://github.com/Grudge10/infoman1 (`week17/`)  
**Linked WEBDEV2 Application:** https://github.com/Grudge10/webdev2 (branch `week17`, application root `/`, artifact `target/webdev2-0.0.1-SNAPSHOT.jar`)  
**MySQL Version:** 8.4.13 (InnoDB)  
**Date Submitted:** 2026-11-21  

## 1. Release Bundle & Verification Summary

- [x] Reproducible release scripts in `week17/release/` (`01_schema.sql`, `02_seed.sql`, `03_views.sql`, `04_access_control.sql`, `README.md`)
- [x] Clean source install -> `mysqldump` (`week17/backup.sql`) -> restore into empty `vetclinic_f5_restore` -> verified counts, constraints, view, and packaged `webdev2` JAR restart persistence (`restore_report.md`, `uat.md`)
- [x] Runtime stays least-privilege (`vetclinic_app@localhost`, `ddl-auto=validate`), no committed secrets

## 2. Requirement-to-Artifact Matrix

| Requirement | Database / Release Artifact | Evidence |
|---|---|---|
| Reproducible clean release scripts | `release/01_schema.sql`–`04_access_control.sql`, `release/README.md` | [setup.md](setup.md) |
| Clean target installation & portability | `setup.md`, `lecture.md` (`DEFINER` & grant ordering) | [restore_report.md](restore_report.md) |
| Backup & separate-target restore proof | `backup.sql`, `vetclinic_f5_source` -> `vetclinic_f5_restore` | [evidence/restore_verification_output.txt](evidence/restore_verification_output.txt) |
| End-to-end UAT & restart persistence | `webdev2-0.0.1-SNAPSHOT.jar` against `vetclinic_f5_restore` | [uat.md](uat.md), [evidence/restore_app_workflow.txt](evidence/restore_app_workflow.txt) |
| Least-privilege runtime & no secrets | `04_access_control.sql`, `backup.sql` (`0` account rows) | [evidence/restore_verification_output.txt](evidence/restore_verification_output.txt) |

## 3. Draft Week 18 Walkthrough Outline

1. Identity, `week18` / `finals` repo paths, and Vet Clinic problem (`0:00–1:30`)
2. ERD, 3NF functional dependencies, constraints, and `pet_appointment_report` view (`1:30–3:30`)
3. Spring Boot + Vanilla JS CRUD, `409` delete policy, and atomic booking commit + rollback (`3:30–6:00`)
4. MySQL `SAVEPOINT` vs full rollback, `GRANT`/`REVOKE`, and `READER`/`MANAGER` CSRF tests (`6:00–8:30`)
5. `EXPLAIN`, automated `./mvnw test` (`16/16`), backup/restore verification, and defect fixes (`8:30–10:30`)

## 4. Change Log

1. Added `week17/release/` SQL bundle (`01_schema.sql`–`04_access_control.sql`, `README.md`), sanitized `backup.sql`, and `setup.md`.
2. Executed clean install, `mysqldump`, separate-target restore into `vetclinic_f5_restore`, and packaged `webdev2` UAT (`restore_report.md`, `uat.md`, `lecture.md`, `evidence/`).

## 5. Deliverables & Evidence

- [release/](release/)
- [backup.sql](backup.sql)
- [setup.md](setup.md)
- [restore_report.md](restore_report.md)
- [uat.md](uat.md)
- [lecture.md](lecture.md)
- [evidence/restore_verification_output.txt](evidence/restore_verification_output.txt)
- [evidence/restore_app_workflow.txt](evidence/restore_app_workflow.txt)
