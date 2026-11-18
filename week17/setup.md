# INFOMAN1 Week 17 Setup, Backup, and Restore Guide (F5)

## 1. Prerequisites
- MySQL `8.4.13` (`mysqldump` and `mysql` client)
- OpenJDK `21.0.13` and `webdev2` branch `week17` (`target/webdev2-0.0.1-SNAPSHOT.jar`)

## 2. Clean Installation Into a Fresh Database
Create a new empty database (do not overwrite an active project database) and run `week17/release/` scripts in order:

```bash
$HOME/dev-tools/mysql/bin/mysql -uroot -h127.0.0.1 -P3307 -e "CREATE DATABASE vetclinic_f5_source;"
$HOME/dev-tools/mysql/bin/mysql -uroot -h127.0.0.1 -P3307 vetclinic_f5_source < week17/release/01_schema.sql
$HOME/dev-tools/mysql/bin/mysql -uroot -h127.0.0.1 -P3307 vetclinic_f5_source < week17/release/02_seed.sql
$HOME/dev-tools/mysql/bin/mysql -uroot -h127.0.0.1 -P3307 vetclinic_f5_source < week17/release/03_views.sql
```

Substitute `<TARGET_DB>` and strong local passwords in a local copy of `week17/release/04_access_control.sql` (outside Git) and apply as admin **after** objects exist.

## 3. Application Startup & Smoke Test (`webdev2`)
Start the packaged release JAR as `vetclinic_app@localhost` (`ddl-auto=validate`) using env vars (`DB_URL`, `DB_USERNAME`, `DB_PASSWORD`, and initial `APP_SEED_*` on first boot), then verify `GET http://localhost:8080/api/health` returns `200 UP`.

## 4. Backup & Separate-Target Restore Procedure
Export only domain tables and views (no `CREATE DATABASE`, `USE`, or system schemas; enter password interactively with `-p`):

```bash
$HOME/dev-tools/mysql/bin/mysqldump -uvetclinic_backup -p -h127.0.0.1 -P3307 \
  --single-transaction --no-tablespaces --set-gtid-purged=OFF vetclinic_f5_source > week17/backup.sql
```

Inspect `week17/backup.sql` (note `DEFINER` clauses on `pet_appointment_report`; restore as an authorized maintainer or strip source-specific definers if restoring on another host without `root@localhost`), create a separate empty target database, import **before** issuing table/view grants:

```bash
$HOME/dev-tools/mysql/bin/mysql -uroot -p -h127.0.0.1 -P3307 -e "CREATE DATABASE vetclinic_f5_restore;"
$HOME/dev-tools/mysql/bin/mysql -uroot -p -h127.0.0.1 -P3307 vetclinic_f5_restore < week17/backup.sql
```

Then run substituted grants from `04_access_control.sql` targeting `vetclinic_f5_restore`, point `DB_URL=jdbc:mysql://localhost:3307/vetclinic_f5_restore`, and restart `webdev2-0.0.1-SNAPSHOT.jar`.
