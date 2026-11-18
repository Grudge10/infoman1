# INFOMAN1 Week 14 Lecture Notes (F2)

**Name:** Jan Liam E. Arias  
**Student ID:** 2510499  
**INFOMAN1 Folder:** `week14/`  

## 1. Business Invariant and Transaction Boundary

- **Business invariant:** Veterinarian available slots must be >= 0. Each appointment booked consumes one slot from a Veterinarian. No duplicate appointments for pets on the same date.
- **Transaction boundaries:**
  - In `week14/transactions.sql`, transactions are explicitly started with `START TRANSACTION`. Both parent `veterinarian` updates and child `appointment` inserts are executed on the same InnoDB database connection. The transaction is committed if it is successful, or rolled back if unsuccessful.
  - In `webdev2`, transaction boundaries are defined by the `@Transactional` annotation on `AppointmentService.bookAppointment`. When called from `AppointmentController`, both calls to the repositories run on the same JDBC connection due to passing through the Spring transaction proxy. If an unchecked exception is thrown (`ResourceNotFoundException`, `ConflictException`, `DataIntegrityViolationException`), both changes will be rolled back. Same-bean self-invocation is avoided (since `AppointmentController` calls `AppointmentService` directly), and exceptions are thrown rather than swallowed so rollback still triggers.

## 2. ACID Properties in This Implementation

- **Atomicity:** In `transactions.sql` (Case 2) and rollback testing in `webdev2` (`petId = 999` and duplicate date), if the query fails after decreasing available slots, a `ROLLBACK` will occur and `available_slots` will return to `3`.
- **Consistency:** Constraints in InnoDB (`chk_vet_available_slots`, `chk_appointment_fee`, `uq_appointment_pet_date`, and foreign keys) guarantee that once committed, the database will not have negative values for available slots, negative appointment fees, unparented appointments, or duplicate appointments for a given pet on a specific day.
- **Isolation:** SQL uses `SELECT ... FOR UPDATE`, which locks the appropriate row in the `veterinarian` table until the transaction is committed or rolled back. In Spring Boot, the conditional atomic update statement (`UPDATE veterinarian SET available_slots = available_slots - 1 WHERE id = :id AND available_slots > 0`) means that InnoDB will lock and serialise updates to the given vet's row.
- **Durability:** If a `COMMIT` is successfully executed (such as Case 1 in `transactions.sql` or booking #5 in the browser), we can open a separate client session using `mysql` and verify that the decreased `available_slots` and new appointment row have been persisted in the database.

## 3. Full Rollback vs. Savepoint Rollback

- `ROLLBACK` reverses all actions. In Case 2, Dr. Villanueva's value was decreased to `2`. Adding a negative fee (`-50.00`) caused a violation of the constraint `chk_appointment_fee` (`ERROR 3819`). Therefore, `ROLLBACK` reversed the value of Dr. Villanueva back to `3`.
- `SAVEPOINT` allows us to make a checkpoint within a transaction. In Case 3:
  1. Dr. Ramos (`id: 3`) had their value decreased to `2`. A `SAVEPOINT` called `after_slot_lock` was created.
  2. Another action added a temporary appointment on `2026-11-26` for pet Milo (`pet_id = 4`). Both actions (`available_slots = 2` and the temporary appointment) were visible within the transaction.
  3. `ROLLBACK TO SAVEPOINT after_slot_lock` removed only the temporary appointment. Dr. Ramos still had `2` available slots within the transaction. However, nothing had been committed to the database yet.
  4. Finally, `ROLLBACK` was used to end the transaction, and Dr. Ramos' available slots were changed back to `3`.

## 4. Concurrency Risk and Safe CRUD Decisions

- **Race conditions leading to an underflow in `available_slots`:** Two users trying to book the last appointment at the same time will both read `1` and may overwrite each other or result in a negative value. The race condition can be avoided using `WHERE id = :id AND available_slots > 0` (ensuring `ROW_COUNT() = 1` / `changed == 1`) or `SELECT ... FOR UPDATE`.
- **Safe queries and deletion:** Queries are parameterised (`?`) to avoid SQL concatenation. When attempting to delete an owner with pets, or a pet with appointments, a `409 Conflict` error is raised in the service layer. This is in addition to being blocked by MySQL `FOREIGN KEY` constraints. We do not disable `FOREIGN_KEY_CHECKS` to allow deletion, and we do not silently delete historical data.
