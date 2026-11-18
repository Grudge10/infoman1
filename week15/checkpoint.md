# INFOMAN1 Week 15 Checkpoint Report (F3)

**Name:** Jan Liam E. Arias  
**Student ID:** 2510499  
**INFOMAN1 Repo:** https://github.com/Grudge10/infoman1 (`week15/`)  
**Linked WEBDEV2 Application:** https://github.com/Grudge10/webdev2 (branch `week15`, application root `/`)  
**MySQL Version:** 8.4.13 (`webdev2_week8`)  
**Date Submitted:** 2026-11-19  

## 1. Prerequisites, Execution Order, and Runtime Config

This must be run after `week13/` and `week14/migration_week14.sql`. As maintainer (`root@localhost`), run `week15/migration_week15.sql` to create `clinic_account`. Copy `week15/access_control.sql`, change `<LOCAL_APP_PASSWORD>` and `<LOCAL_REPORT_PASSWORD>` to strong local passwords not in Git, and run the script as admin.

Start `webdev2` (`week15`) with the following environment variables (without committing any real password values):

```text
DB_USERNAME=vetclinic_app
DB_PASSWORD=<LOCAL_APP_PASSWORD>
JPA_DDL_AUTO=validate
APP_SEED_READER_USERNAME / APP_SEED_READER_PASSWORD (optional, only for initial account creation)
APP_SEED_MANAGER_USERNAME / APP_SEED_MANAGER_PASSWORD (optional, only for initial account creation)
```

## 2. Allowed & Denied Operations Evidence Table

| Identity | Operation Tested | Expected | Actual Observed Result | Status |
|---|---|---|---|---|
| `vetclinic_app@localhost` | `webdev2` startup (`ddl-auto=validate`) + `SELECT COUNT(*) FROM pet` | Allowed (`PROCESSLIST` shows `vetclinic_app`) | All 10 Hikari connections authenticated as `vetclinic_app`; CRUD & `./mvnw test` passed `3/3` | Pass |
| `vetclinic_app@localhost` | `CREATE TABLE unauthorized_test (id INT)` on `webdev2_week8` (safe non-destructive test) | Denied (`CREATE` blocked) | `ERROR 1142 (42000): CREATE command denied to user 'vetclinic_app'@'localhost'` | Pass |
| `vetclinic_report@localhost` | `SELECT ... FROM pet_appointment_report` | Allowed | Returned `3` joined rows cleanly | Pass |
| `vetclinic_report@localhost` | `SELECT * FROM owner` & `INSERT INTO owner` | Denied | `ERROR 1142 (42000)` on both `SELECT` and `INSERT` for table `owner` | Pass |
| `vetclinic_report@localhost` | `REVOKE SELECT` on view, reconnect & query, then restore `GRANT SELECT` | Denied after `REVOKE`; restored to `3` rows | `ERROR 1044 (42000)` after `REVOKE`; restored `3` rows after `GRANT SELECT` | Pass |

## 3. Change Log

1. Added `migration_week15.sql` for maintainer-owned `clinic_account` creation and `access_control.sql` as a sanitized MySQL grant/revoke template.
2. Verified `vetclinic_app@localhost` runtime queries, DDL denial, `vetclinic_report@localhost` view access, base-table denial, and `REVOKE`/`GRANT` restoration.
3. Added `week15/lecture.md`, `week15/checkpoint.md`, and captured outputs in `week15/evidence/`.

## 4. Evidence Files

- [migration_week15.sql](migration_week15.sql)
- [access_control.sql](access_control.sql)
- [evidence/mysql_privileges_output.txt](evidence/mysql_privileges_output.txt)
- [evidence/app_runtime_db_identity.txt](evidence/app_runtime_db_identity.txt)
