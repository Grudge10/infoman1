# INFOMAN1 Week 18 Final Setup, Smoke Test, and Safe Restore Guide

## 1. Prerequisites
- MySQL `8.4.13` (`mysqld`, `mysql`, and `mysqldump`)
- Java `17+` (verified on OpenJDK `21.0.13`)
- Linked application checkout: `https://github.com/Grudge10/webdev2` on frozen branch `finals` (`target/webdev2-0.0.1-SNAPSHOT.jar` built via `./mvnw clean verify`)
- *Local macOS portable toolchain note:* If MySQL (`port=3307`) and JDK 21 are not on default `PATH`, prefix commands with `$HOME/dev-tools/mysql/bin/` and set `JAVA_HOME=$HOME/dev-tools/jdk-21.0.13+9/Contents/Home`.

## 2. Clean Database Installation (`week18/release/`)
Start MySQL and execute the release bundle inside a fresh empty database (`vetclinic_f5_release`):

```bash
mysql -uroot -h127.0.0.1 -P3307 -e "CREATE DATABASE vetclinic_f5_release;"
mysql -uroot -h127.0.0.1 -P3307 vetclinic_f5_release < week18/release/01_schema.sql
mysql -uroot -h127.0.0.1 -P3307 vetclinic_f5_release < week18/release/02_seed.sql
mysql -uroot -h127.0.0.1 -P3307 vetclinic_f5_release < week18/release/03_views.sql
```

Substitute `<TARGET_DB>` and strong local passwords in an untracked copy of [`release/04_access_control.sql`](release/04_access_control.sql) and run as admin **after** tables and views exist (incorporating the Week 17 grant-order fix).

## 3. Application Startup & Smoke Test (`webdev2` branch `finals`)
Copy [`release/application-example.properties`](release/application-example.properties) or export environment variables pointing to `jdbc:mysql://localhost:3307/vetclinic_f5_release` with `vetclinic_app@localhost` (`ddl-auto=validate`) and initial `APP_SEED_READER_*` / `APP_SEED_MANAGER_*` credentials on first launch (run from the `webdev2` repository root):

```bash
DB_URL="jdbc:mysql://localhost:3307/vetclinic_f5_release" \
DB_USERNAME="vetclinic_app" \
DB_PASSWORD="<LOCAL_APP_PASSWORD>" \
APP_SEED_READER_USERNAME="clinic_viewer" \
APP_SEED_READER_PASSWORD="<LOCAL_READER_PASSWORD>" \
APP_SEED_MANAGER_USERNAME="clinic_manager" \
APP_SEED_MANAGER_PASSWORD="<LOCAL_MANAGER_PASSWORD>" \
java -jar target/webdev2-0.0.1-SNAPSHOT.jar
```

Verify `GET http://localhost:8080/api/health` returns `200 OK` (`{"status":"UP","database":"UP"}`), sign in at `http://localhost:8080/`, create and view a record, then restart without `APP_SEED_*` variables to confirm MySQL persistence.

## 4. Deterministic Backup & Separate-Target Restore Procedure
Export only domain objects and view definitions (no `CREATE DATABASE`, `USE`, or system tables):

```bash
mysqldump -uvetclinic_backup -p -h127.0.0.1 -P3307 \
  --single-transaction --no-tablespaces --set-gtid-purged=OFF vetclinic_f5_release > week18/release/backup.sql
```

Restore into a separate empty database (`vetclinic_f5_restore`) before re-applying privileges:

```bash
mysql -uroot -p -h127.0.0.1 -P3307 -e "CREATE DATABASE vetclinic_f5_restore;"
mysql -uroot -p -h127.0.0.1 -P3307 vetclinic_f5_restore < week18/release/backup.sql
```

Inspect view `DEFINER` clauses if moving across hosts without `root@localhost`, apply substituted grants from [`release/04_access_control.sql`](release/04_access_control.sql) on `vetclinic_f5_restore`, update `DB_URL` to `vetclinic_f5_restore`, and restart `webdev2`.
