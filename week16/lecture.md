# INFOMAN1 Week 16 Lecture Notes (F4)

**Name:** Jan Liam E. Arias  
**Student ID:** 2510499  
**INFOMAN1 Folder:** `week16/`  
**Linked WEBDEV2 Branch:** `week16`  

## 1. Three Meaningful Test Choices

In the non-`@Transactional` rollback test (`Week16MysqlTransactionTests`), omitting `@Transactional` from the JUnit test confirms whether `AppointmentService.bookAppointment` commits or rolls back on its own. With no rollback at the test level, it is confirmed that in MySQL write operation 1 (`UPDATE veterinarian`) rolls back for `petId = 999999`.

In the InnoDB constraint violation tests (`verification.sql`), error codes `1062` (`pet.microchip_number`), `1452` (`fk_pet_owner`), and `3819` (`chk_appointment_fee`) cannot be verified using mocked services, so these negative checks are performed directly on MySQL `8.4.13`.

In the privilege and view boundary checks, running `CREATE TABLE` as `vetclinic_app` results in `ERROR 1142`, and running `SELECT` or `INSERT` on the `owner` table as `vetclinic_report` also results in `ERROR 1142`. This confirms that minimum privilege access is enforced throughout integrated processes.

## 2. Expected Report Output, Cardinality, and `ON` vs `WHERE`

In `vetclinic_f4_test`, Maria Santos owns `2` pets (`Buddy`: `1` appointment costing `750.00`; `Bantay`: `1` appointment costing `500.00`), Carlos Mendoza owns `2` pets (`Luna`: `1` appointment costing `1200.00`; `Max`: `0` appointments), and Elena Cruz owns `1` pet (`Milo`: `0` appointments).

The number of rows in the joined output increases as we join tables: for example, `COUNT(*)` returns `2` rows for Maria and `2` rows for Carlos (`5` total rows), despite Carlos only having `1` appointment. `COUNT(DISTINCT p.id)` returns `2` unique pets, and `COUNT(a.id)` ignores non-matching rows so Maria has `2` appointments, Carlos has `1`, and Elena has `0`.

By adding the condition (`a.fee >= 700.00`) in the `LEFT JOIN` clause, we still get Elena Cruz with `0` high-fee appointments. However, by adding the condition (`a.fee >= 700.00`) in the `WHERE` clause, any rows with `NULL` fees are filtered out, turning the `LEFT JOIN` into an `INNER JOIN` so Elena Cruz is quietly dropped from the results.

## 3. Cross-Layer Diagnosis Example

When trying to run `webdev2` with `ddl-auto=validate` on a clean disposable database (`vetclinic_f4_test`) containing only the SQL schema and data from `infoman1`, schema validation errors occurred because preliminary classes (`Task`, `Department`, `Student`, `User`) from `prelim`/`week9` had no corresponding tables.

During debugging, Hibernate SchemaValidator found missing tables (`app_users`, `department`, `task`). In `week16`, there were unused classes carried forward from previous weeks, whereas `week13` `schema.sql` only included the `4` Vet Clinic domain tables (plus `clinic_account` in `week15/migration_week15.sql`).

The Week 7–9 lab files were deleted from `webdev2` `week16`, and running `./mvnw test` again as restricted `vetclinic_app` resulted in all `15` tests passing on `vetclinic_f4_test`.

## 4. `EXPLAIN` Result and Index Tradeoff

Using `EXPLAIN` on the `owner -> pet -> appointment` report query showed: `owner` (`o`) used `type = ALL` across `3` rows with `Extra = Using filesort`; `pet` (`p`) used `type = ref` with `key = fk_pet_owner`, `ref = vetclinic_f4_test.o.id`, and `Extra = Using index` as a covering index scan; and `appointment` (`a`) used `type = ref` with `key = uq_appointment_pet_date`, `ref = vetclinic_f4_test.p.id`, and `Extra = Using where` by matching `pet_id` via the composite index prefix `(pet_id, appointment_date)` and then applying the `fee >= 700.00` filter.

As an index tradeoff, if the number of appointments in the clinic increases to thousands of entries and reports frequently filter by `appointment_date` or `fee`, an index such as `idx_appointment_date_fee (appointment_date, fee)` could speed up date/fee range queries, at the cost of extra disk space and a slight decrease in `INSERT`/`UPDATE`/`DELETE` performance on `appointment`. Given that there are only `3` rows in this table, adding extra indexes is unnecessary.
