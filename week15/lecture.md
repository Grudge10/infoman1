# INFOMAN1 Week 15 Lecture Notes (F3)

**Name:** Jan Liam E. Arias  
**Student ID:** 2510499  
**INFOMAN1 Folder:** `week15/`  
**Linked WEBDEV2 Branch:** `week15`  

## 1. Permission Matrix and Role Separation

| Identity | Scope / Objects | Granted Operations | Purpose |
|---|---|---|---|
| Schema Maintainer (`root@localhost`, admin only) | `webdev2_week8.*` | Full DDL + user provisioning | Runs `schema.sql`, `migration_week14.sql`, `migration_week15.sql`, and `GRANT`/`REVOKE`; never used by Spring Boot |
| Runtime App (`vetclinic_app@localhost`) | `webdev2_week8.*` | `SELECT, INSERT, UPDATE, DELETE` | Used by `webdev2` at runtime with `ddl-auto=validate`; cannot `CREATE`/`ALTER`/`DROP` tables |
| Reporting (`vetclinic_report@localhost`) | `webdev2_week8.pet_appointment_report` | `SELECT` only | Reads joined clinic report view; denied all base tables and all writes |
| App End Users (`clinic_viewer`, `clinic_manager`) | HTTP API via `clinic_account` | `READER` reads vs `MANAGER` writes | Authenticated via `BCrypt` session; share `vetclinic_app` DB pool rather than owning MySQL logins |

## 2. Database Identities vs. Application Users & Host Scope

Privileges on the MySQL database mean that only certain SQL commands may be executed by the backend application (`vetclinic_app`) or reports (`vetclinic_report`). Authorisation within the application in `webdev2` means only certain users (`READER`/`MANAGER`) can trigger endpoints.

Both users have restricted host access to `'localhost'`, meaning they cannot be accessed from a remote host. This matches the connection string in `jdbc:mysql://localhost:3307/webdev2_week8` (`USER()` and `CURRENT_USER()` in MySQL were found to be `vetclinic_app@localhost` in `mysql_privileges_output.txt`).

Since the schema ownership is separated from its execution, we can use `spring.jpa.hibernate.ddl-auto=validate`. This means that `migration_week15.sql` will have been run by the maintainer in advance, and Spring Boot never performs any `ALTER`/`DROP` commands.

## 3. View Security (`DEFINER` vs `INVOKER`) and `GRANT`/`REVOKE` Results

From `SHOW CREATE VIEW pet_appointment_report`, we can see that its `SQL SECURITY` is set to `DEFINER` (default), and its `DEFINER` is `'root'@'localhost'`. As the base tables are accessed using the definer's privileges, and not the invoker's (invoker = `SQL SECURITY INVOKER`), `vetclinic_report@localhost` is able to `SELECT` data from `pet_appointment_report`. However, attempts to directly `SELECT` from or `INSERT INTO owner` failed with `ERROR 1142 (42000)`.

When the admin executed `REVOKE SELECT ON webdev2_week8.pet_appointment_report FROM 'vetclinic_report'@'localhost'`, `SHOW GRANTS` returned only `GRANT USAGE ON *.*`. When trying to connect to `webdev2_week8`, an error occurred: `ERROR 1044 (42000)` (`Access denied`). However, when executing `GRANT SELECT` again, access to all 3 rows of the report was granted.

## 4. Diagnosed Configuration / Privilege Issue

In Weeks 13 and 14, Spring Boot was configured using `spring.jpa.hibernate.ddl-auto=update`. As such, it required `CREATE` and `ALTER` privileges if any of the entities changed. Now, by configuring `clinic_account` DDL in maintainer-run `week15/migration_week15.sql` and setting Spring Boot to use `ddl-auto=${JPA_DDL_AUTO:validate}`, we can ensure that during runtime the credentials are least-privileged. The `vetclinic_app` credentials are provided strictly using environment variables `DB_USERNAME` and `DB_PASSWORD`, and as a result no passwords are committed.
