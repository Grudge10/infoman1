# INFOMAN1 Week 17 Lecture Notes (F5)

**Name:** Jan Liam E. Arias  
**Student ID:** 2510499  
**INFOMAN1 Folder:** `week17/`  
**Linked WEBDEV2 Branch:** `week17`  

## 1. Release Architecture and Schema Ownership

Within the release (`week17/release/`), the database objects (`01_schema.sql`, `02_seed.sql`, `03_views.sql`) and access control (`04_access_control.sql`) belong to the maintainer setup section, while the Vet Clinic application is run by `webdev2` as `vetclinic_app@localhost` with `spring.jpa.hibernate.ddl-auto=validate`. Since DDL and DML are separated, Spring Boot can check that columns and tables match without running any `ALTER` or `CREATE` commands.

## 2. Backup Consistency and Source/Target Safety

`mysqldump --single-transaction --no-tablespaces --set-gtid-purged=OFF` creates a consistent backup of `vetclinic_f5_source` (`InnoDB`), where global read locks are not taken on non-DDL operations within the database. However, schema modifications (`ALTER` / `DROP`) may conflict with the consistency assumptions of the backup if performed concurrently, and for this reason schema modifications were frozen during rehearsal.

`--databases` is not used so that `CREATE DATABASE` and `USE vetclinic_f5_source` statements are omitted from the dump. This allows importing into `vetclinic_f5_restore` without accidentally overwriting data in `vetclinic_f5_source`.

Privileges are stored within system tables inside `mysql`, meaning `04_access_control.sql` must be applied to the new target database rather than relying on privileges being included in `backup.sql`.

## 3. View `DEFINER`, Account Portability, and Secret Safety

The view `pet_appointment_report` was exported with `/*!50013 DEFINER='root'@'localhost' SQL SECURITY DEFINER */`. When this view is restored by a non-privileged user on a machine where there is no `'root'@'localhost'`, it will raise an error unless the definer statement is updated or removed by the maintainer. When restored by the local maintainer and documenting the definer line in `restore_report.md`, `vetclinic_report` performs correctly without exposing root credentials in source files.

No default credentials exist in `clinic_account` within `backup.sql` (`0` rows). Local `BCrypt` credentials are seeded in the database when the JAR is run for the first time using environment variables (`APP_SEED_*`) without committing any secrets.

## 4. UAT Finding Analysis

During target setup, running `GRANT SELECT ON vetclinic_f5_restore.pet_appointment_report` threw `ERROR 1146` because the `pet_appointment_report` view did not exist yet. Importing `backup.sql` before issuing object-specific `GRANT` statements in `setup.md` resolves the error so the restore guide can be followed cleanly from start to finish.
