# INFOMAN1 Week 16 Checkpoint Report (F4)

**Name:** Jan Liam E. Arias  
**Student ID:** 2510499  
**INFOMAN1 Repo:** https://github.com/Grudge10/infoman1 (`week16/`)  
**Linked WEBDEV2 Application:** https://github.com/Grudge10/webdev2 (branch `week16`, application root `/`)  
**MySQL Version:** 8.4.13 (`vetclinic_f4_test` and `webdev2_week8`, runtime identity `vetclinic_app@localhost`)  
**Date Submitted:** 2026-11-20  

## 1. Prerequisites and Feature-Complete Status

Built on `week13/schema.sql`, `week13/seed.sql`, `week13/views.sql`, `week14/migration_week14.sql`, and `week15/migration_week15.sql`:
- [x] Persisted CRUD for `owner` and `pet`, atomic `veterinarian`/`appointment` transaction + rollback, `pet_appointment_report` view, and least-privilege `vetclinic_app`/`vetclinic_report` accounts all verified together.
- [x] `14` named database/integration scenarios executed in [test_matrix.md](test_matrix.md) plus `15/15` automated `webdev2` tests passing on disposable `vetclinic_f4_test`.
- [x] Join cardinality (`COUNT(*)`, `COUNT(DISTINCT p.id)`, `COUNT(a.id)`), `ON` vs `WHERE` outer-join preservation, negative constraints, and `EXPLAIN` captured in [evidence/verification_output.txt](evidence/verification_output.txt).

## 2. Known Limitations

Remaining small improvements (no fee column in `pet_appointment_report`, and `application-test.properties` requires creating the `vetclinic_f4_test` database manually using setup commands) will be covered in reproducible setup and restore documentation in `week17` (`F5`).

## 3. Change Log

1. Added `verification.sql` covering `pet_appointment_report`, join cardinality, `ON` vs `WHERE` comparison, `1062`/`1452`/`3819` constraint checks, and `EXPLAIN`.
2. Executed and recorded `14` integrated test cases (`test_matrix.md`), logged `3` cross-layer fixes (`defects.md`), and captured MySQL `8.4.13` evidence in `evidence/verification_output.txt`.

## 4. Evidence Files

- [verification.sql](verification.sql)
- [test_matrix.md](test_matrix.md)
- [defects.md](defects.md)
- [lecture.md](lecture.md)
- [evidence/verification_output.txt](evidence/verification_output.txt)
