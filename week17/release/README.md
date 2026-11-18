# Vet Clinic Release SQL Bundle Execution Order

Create a new empty database first (do not overwrite existing databases), then run:

1. `01_schema.sql` — tables and constraints (`owner`, `veterinarian`, `pet`, `appointment`, `clinic_account`)
2. `02_seed.sql` — initial fictional clinic data
3. `03_views.sql` — `pet_appointment_report` view
4. `04_access_control.sql` — sanitized template (`<TARGET_DB>` and `<LOCAL_*_PASSWORD>` must be substituted locally before running as admin)
