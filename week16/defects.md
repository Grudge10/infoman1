# INFOMAN1 Week 16 Defects and Fixes (F4)

## 1. Validating DB Schema Failed (`webdev2` vs `infoman1`)

When running `webdev2` with `spring.jpa.hibernate.ddl-auto=validate` after creating the `vetclinic_f4_test` database solely from the `infoman1` SQL scripts, schema validation failed due to unrelated leftover JPA entity classes (`Task`, `Department`, `Employee`, `Student`, `Course`, `Enrollment`, and `User`) in `webdev2`. Removing those classes on `webdev2` branch `week16` (`git rm`) resolved the mismatch, and running `./mvnw test` as `vetclinic_app@localhost` returned `15/15` passing tests against `vetclinic_f4_test`.

## 2. Invalid Sorting Parameter Returned HTTP `500` Server Error (`PetService.java`)

When `/api/pets?sort=dropTable` was sent, a `PropertyReferenceException` occurred and returned an HTTP `500` error because `PetService.findAll()` passed arbitrary sort string values from the `GET` request directly to `Sort.by()`. To resolve this issue, the sort value is now checked against an allowed list (`id`, `microchipNumber`, `name`, `species`, `breed`), along with `page >= 0` and `size >= 1`, before creating a `PageRequest` object; unit and security tests passed returning HTTP `400`.

## 3. Displaying Stale Pet Data and Overflowing Tables in Mobile View

When a currently viewed pet was edited or deleted, stale pet information remained in `#pet-detail`, and on a `375px` screen table contents overflowed horizontally because `app.js` did not track `currentDetailPetId` and tables in `index.html` had no overflow wrapper. These issues were fixed by updating `app.js`, `index.html`, and `styles.css` (`.table-wrap` and `:focus-visible`), and all `8/8` browser UAT scenarios passed.
