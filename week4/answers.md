# INFOMAN1 Week 4 Lab - DDL & Table Creation

## Task 4 - Schema Verification & Comparison

After creating all six tables, I executed a `SHOW TABLES;` command to ensure that they were all created successfully. Then, I performed a `DESCRIBE` command for each table and compared the output with my Week 3 relational schema and physical ERD. The comparison results are summarized below.

| Table | Expected structure (Week 3 schema) | What DESCRIBE actually showed | Match? |
| --- | --- | --- | --- |
| owner | owner_id PK; first_name, last_name, phone_number | owner_id INT (PRI); first_name / last_name VARCHAR(50); phone_number INT | Yes* |
| pet | pet_id PK; name, species, age; owner_id FK | pet_id INT (PRI); name / species VARCHAR(50); age INT (nullable, as designed); owner_id INT (MUL = FK) | Yes |
| veterinarian | vet_id PK; first_name, last_name | vet_id INT (PRI); first_name / last_name VARCHAR(50) | Yes |
| vet_specialization | Composite PK (vet_id, specialization_name); vet_id FK | Composite PRI (vet_id, specialization_name); vet_id (MUL = FK) | Yes |
| appointment | appointment_id PK; appointment_date; reason_for_visit; pet_id FK; vet_id FK | appointment_id INT (PRI); appointment_date DATE; reason_for_visit TEXT; pet_id and vet_id INT (MUL = FK) | Yes |
| vaccination_record | Composite PK (pet_id, vaccine_name, vaccination_date); pet_id FK | Composite PRI (pet_id, vaccine_name, vaccination_date); pet_id (MUL = FK) | Yes |

\*The only discrepancy between the description of the owner table and its actual realization is that the column phone_number has type int. It is a result of the intentional error made for Task 5, which is later corrected with an ALTER TABLE statement.

In general, every primary key, foreign key (denoted by MUL in the DESCRIBE results), data type, and composite key from the Week 3 schema is present in the actual MySQL database. There were no unexpected discrepancies between the design and the implementation except for the purposeful phone_number error in Task 5.
