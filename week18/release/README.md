# Vet Clinic Final Release Bundle (`week18/release/`)

Create a new empty MySQL `8.4.13` database first (never overwrite an active working database), then run these scripts in order:

1. [`01_schema.sql`](01_schema.sql) — creates `owner`, `veterinarian`, `pet`, `appointment`, and `clinic_account` (`InnoDB`, PKs, FKs, `UNIQUE`, `CHECK` constraints)
2. [`02_seed.sql`](02_seed.sql) — loads fictional initial clinic owners, veterinarians, pets, and appointments
3. [`03_views.sql`](03_views.sql) — creates the dynamic `pet_appointment_report` join view
4. [`04_access_control.sql`](04_access_control.sql) — sanitized privilege template (`<TARGET_DB>` and `<LOCAL_*_PASSWORD>` must be replaced locally outside Git before running as admin)
5. [`application-example.properties`](application-example.properties) — sanitized Spring Boot runtime example (`ddl-auto=validate`, env placeholders, no real passwords)
6. [`backup.sql`](backup.sql) — sanitized domain-only `mysqldump` snapshot (`0` password hashes in `clinic_account`) for separate-target restore rehearsal; see [`../setup.md`](../setup.md) for deterministic regeneration and restore ordering
