# INFOMAN1 Week 13 Lecture Notes

**Name:** Jan Liam E. Arias  
**Student ID:** 2510499  
**INFOMAN1 Repo:** https://github.com/Grudge10/infoman1 (folder `week13/`)  
**Linked WEBDEV2 App:** https://github.com/Grudge10/webdev2 (branch `week13`, root `/`)  
**Date Submitted:** 2026-11-17

## 1. Requirements and Baseline Audit

### Six Checkable Requirements
- **REQ-1:** The list of registered pets in the clinic can be viewed using `GET /api/pets`.
- **REQ-2:** An individual pet can be searched for using `GET /api/pets/{id}`, returning an error 404 if none found.
- **REQ-3:** The list of owners can be viewed using `GET /api/owners`.
- **REQ-4:** MySQL does not allow inserting duplicate pets with the same `microchip_number`.
- **REQ-5:** MySQL will not allow adding a pet with an `owner_id` that does not exist, or an appointment with a negative `fee`.
- **REQ-6:** The `pet_appointment_report` SQL view links the `appointment`, `pet`, `owner` and `veterinarian` tables and is automatically updated whenever there is a change to any of the base rows.

### Baseline Inventory and Repair Plan
| Item | Status on Baseline (`week11` / `webdev2_week8`) | Location & Repair Done in Week 13 |
|---|---|---|
| Domain entities (`Owner`, `Pet`, `Veterinarian`, `Appointment`) | Working | `src/main/java/com/webdev2/model/` on `webdev2` `week13` |
| `/api/pets` read + pagination | Incomplete (`ownerName` missing, no `@Transactional`) | Repaired in `PetDTO.java` and `PetService.java` |
| `/api/owners` read endpoint | Missing | Added `OwnerDTO`, `OwnerService`, `OwnerController` |
| Pet owner links on seeded rows | Incomplete (`Buddy` to `Milo` had `owner_id = NULL`) | Repaired in `PetDataSeeder.java` and `week13/seed.sql` |
| Formal SQL DDL, `CHECK`, and report view | Missing standalone SQL scripts | Added `week13/schema.sql`, `week13/seed.sql`, and `week13/views.sql` |

## 2. Relational Design and Normalization

```text
owner (id PK, name, phone)
  | 1
  |
  | 0..*
pet (id PK, microchip_number UNIQUE NOT NULL, name NOT NULL, species NOT NULL, breed, owner_id FK NULL)
  | 1
  |
  | 0..*
appointment (id PK, appointment_date NOT NULL, reason NOT NULL, fee DECIMAL(8,2) CHECK >= 0, pet_id FK NOT NULL, vet_id FK NOT NULL)
  | 0..*
  |
  | 1
veterinarian (id PK, name NOT NULL, specialty)
```

- **Data Types & Constraints:** The `owner`, `veterinarian`, `pet` and `appointment` tables are using `InnoDB`. Each has a primary key of `BIGINT AUTO_INCREMENT`. Columns are limited by using `VARCHAR` data types. `appointment_date` uses `DATE`, `fee` uses `DECIMAL(8,2)`. Fields that are required have `NOT NULL`. There is a `UNIQUE` constraint on `microchip_number` in the `pet` table. The `fee` column in the `appointment` table has a constraint to ensure it cannot be less than `0.00`. `owner_id` in the `pet` table is optional as the pet can exist without an owner. The `appointment` table has `NOT NULL` constraints for `pet_id` and `vet_id`.
- **Functional Dependencies & Anomalies Avoided:** There is a functional dependency between `id` and `name`, `phone` in the `owner` table. There is also a functional dependency between `id` and `microchip_number`, `name`, `species`, `breed` and `owner_id` in the `pet` table. If we had stored the owner's phone number in either the `pet` or `appointment` table this would cause duplication as Maria Santos's phone number would appear in every row. This could also cause an update anomaly if her phone number changed. By having a foreign key in the `pet` table we only store her phone number once. Duplicate `owner_id` in the `pet` table is expected as it is a foreign key.
- **Appointment Table Role & FK Constraints:** The `appointment` table represents visits. It contains its own `appointment_date`, `reason` and `fee`. This avoids creating a fake join table. The foreign keys ensure that there are existing `owner`, `pet` and `veterinarian` IDs to reference. Constraints such as `fee` being a positive number require a `CHECK` constraint or validation within the application.

## 3. SQL View Reasoning (`pet_appointment_report`)

`pet_appointment_report` is a stored `SELECT` query, not a copied table snapshot. `INNER JOIN pet` and `INNER JOIN veterinarian` are used to ensure that there is always a pet and a vet (`NOT NULL`) for each appointment. `LEFT JOIN owner` is used to include pets with no owners.

When I had run the query `UPDATE pet SET name = 'Buddy Jr.' WHERE microchip_number = 'MC-1001'` in `evidence/view_before_after.txt`, running this view would immediately show `Buddy Jr.`, without needing to recreate the view, because the view reads the live base tables. Because it is difficult to determine which individual parent and child rows are being updated when a view is using several base tables, `INSERT` and `UPDATE` queries are always done on the base tables (e.g. `pet` and `appointment`). Definer and invoker rights and user privileges affect views, so a view is not a security boundary on its own.

## 4. Application Integration and Credential Safety

- **Path Trace:** In `app.js` (`webdev2` `week13`), `getJson("/api/pets/1")` is called via HTTP. `PetController.getPetById(1)` calls `PetService.findById(1)` which then calls `PetRepository.findById(1)`. This query is called with Hibernate ORM and MySQL JDBC Driver (`mysql-connector-j`) and uses parameter binding to retrieve data from the `webdev2_week8` database. The `PetService.toDTO()` method gets the owner from the database within the transaction and returns the `PetDTO` JSON containing `Buddy` and owner `Maria Santos`.
- **Credentials Not in Git and Browser:** Database host, database name, `DB_USERNAME` and `DB_PASSWORD` should be in your local environment variables and should not be included in your git repo (`.gitignore`) and therefore only the placeholders are in `application-example.properties`. The browser will never receive any database credentials as all frontend code can be seen by the user in DevTools.
- **Connection and Data Issue:** Once I confirmed that MySQL 8.4.13 was running on port 3307 I checked that the `webdev2_week8` database was allowing connections. I then checked the `pet` table and noticed that `owner_id` was `NULL` for rows 1-4. This caused `ownerName` to be empty within `PetDTO` and `pet_appointment_report`. By updating the `PetDataSeeder` and `seed.sql` (`week13`) this issue was resolved.
