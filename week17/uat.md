# INFOMAN1 Week 17 Release Acceptance Test (UAT) Log (F5)

**Tester:** Jan Liam E. Arias  
**Date:** 2026-11-18  
**Target:** Restored `vetclinic_f5_restore` + packaged `webdev2-0.0.1-SNAPSHOT.jar` running as `vetclinic_app@localhost`  

| # | Scenario | Action | Expected | Actual Observed Result | Status |
|---|---|---|---|---|---|
| 1 | Create & Read (`Pet`) | `POST /api/pets` (`MC-F5REL`, `ReleasePup`, `ownerId=1`), `GET /api/pets?species=Dog` | `201 Created`, persisted in restore target | Created `id=6`; `GET` returned 4 Dog rows (`totalElements=4`); persisted across JAR restart | Pass |
| 2 | Update & Delete Policy | `PUT` update & `409` delete protection verified in regression + `webdev2` build (`16/16`) | Valid updates persist; referenced parents reject `409` | Verified in `clean_verify_output.txt` (`16/16` pass) & restore target UI | Pass |
| 3 | Joined Report (`vetclinic_report`) | Query `pet_appointment_report` on `vetclinic_f5_restore` as `vetclinic_report@localhost` | Returns `3` rows | `report_rows = 3` (`restore_verification_output.txt`) | Pass |
| 4 | Atomic Workflow + Rollback | `POST /api/appointments/book` (`petId=4`, `vetId=1`); then invalid `petId=9999`, `vetId=2` | Commit `3 -> 2` slots; failure `404` leaves `vetId=2` at `3` | Slots `[2, 3, 3]`, persisted appointment #4 (`Release UAT Check`) after restart | Pass |
| 5 | Restricted Runtime & Constraints | `webdev2` connects as `vetclinic_app` (`ddl-auto=validate`); negative `fee = -1.00` tested | No root runtime; `CHECK` active post-restore | App started cleanly as `vetclinic_app`; MySQL raised `ERROR 3819` | Pass |

## Fixes & Remaining Limitations

To resolve `ERROR 1146` on `pet_appointment_report` during rehearsal, the order of operations in `setup.md` was updated so `backup.sql` is restored into the `vetclinic_f5_restore` database first before the `GRANT` statements in `04_access_control.sql` are run.

This rehearsal only demonstrates local backups and restores on a single host, so scheduled automated backups to offsite locations are not implemented. Because `backup.sql` includes `0` entries in `clinic_account`, the initial staff accounts must be seeded using the `APP_SEED_*` environment variables on first launch.
