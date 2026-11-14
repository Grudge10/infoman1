# INFOMAN1 — Midterm Practical Assessment: Answer Document

**Name:** Jan Liam E. Arias  
**Student ID:** 2510499  
**Repository URL:** https://github.com/Grudge10/infoman1  
**Date Submitted:** 2026-11-14

---

## Task 1: Normalization Audit & 3NF Decomposition

### Approach
I started by loading `eventhub_seed.sql` into MySQL and running `SELECT * FROM event_booking_flat` so I could inspect all 7 rows side by side. Right away, I noticed that `speaker_list` held comma-separated names and that venue and organizer details were repeated on multiple rows. I mapped out the functional dependencies first, then cleaned up the schema step by step: 1NF to make every column atomic, 2NF to pull out attributes that only depended on part of a key, and 3NF to move out attributes that depended on other non-key columns like `venue_code` and `organizer_id`.

### 1. Data Anomalies in `event_booking_flat`
- **Update Anomaly:** `V-METRO` (`Metro Tech Auditorium`, `Quezon City`, capacity `300`) appears in 3 separate rows (`101 / SESS-A1`, `101 / SESS-A2`, and `103 / SESS-A1`). If the auditorium gets renovated and its capacity increases to `350`, we have to update all 3 rows together. Missing even one row leaves two different capacities stored for the same venue. The same issue happens for `V-BAY` (2 rows) and `V-PARK` (2 rows), and for organizers like `Green Earth Initiative` (2 rows).
- **Insertion Anomaly:** Because the primary key is `(booking_id, session_code)` and `booking_date`, `event_title`, and `organizer_id` are all `NOT NULL`, we cannot register a new partner venue like `V-CAMPUS` (`University Amphitheater`) until an event booking exists for it, unless we insert fake placeholder booking details.
- **Deletion Anomaly:** Row `(103, 'SESS-A1')` is the only row containing `organizer_id = 3` (`Innovate Campus Lab`, `lead@innovatecampus.edu`) and the speaker `Ms. Lim`. If that single booking gets cancelled and deleted, we lose the organizer's record and contact email completely from the database.

### 2. Functional Dependencies
- `(booking_id, session_code) -> booking_date, event_title, organizer_id, venue_code, ticket_category, ticket_price, tickets_booked`
- `booking_id -> booking_date, event_title, organizer_id, venue_code` (partial dependency in the flat table)
- `organizer_id -> organizer_name, organizer_email` (transitive dependency via `booking_id`)
- `venue_code -> venue_name, venue_city, venue_capacity` (transitive dependency via `booking_id`)
- `speaker_id -> speaker_name` (after extracting atomic speakers)
- `(booking_id, session_code)` + `speaker_id` is many-to-many (each session booking can have multiple speakers, and a speaker like `Dr. Perez` or `Dr. Aquino` appears across multiple sessions)

### 3. Normalization Progression
- **First Normal Form (1NF):** In `event_booking_flat`, `speaker_list` breaks atomicity by storing values like `'Dr. Perez, Engr. Cruz'` in one cell. To reach 1NF, I removed `speaker_list` from the bookings rows so every cell holds a single value, and gave speakers their own table `speakers(speaker_id, speaker_name)` linked to bookings through a junction table `session_speakers(booking_id, speaker_id)`. I also gave each session booking row its own unique surrogate primary key `booking_id` (since the seed table used `(booking_id, session_code)` where `101` was shared by two sessions of the same event).
- **Second Normal Form (2NF):** In the original flat key `(booking_id, session_code)`, columns like `booking_date`, `event_title`, `organizer_id`, `organizer_name`, `organizer_email`, `venue_code`, `venue_name`, `venue_city`, and `venue_capacity` described the overall event booking rather than a specific session line like `SESS-A1` or `SESS-A2`. Moving event-level attributes into an `events` table keyed by `event_id` (carrying the original event IDs `101` to `106`) ensures that session-specific columns (`session_code`, `booking_date`, `ticket_category`, `ticket_price`, `tickets_booked`) belong in `bookings` and depend on the full primary key `booking_id`.
- **Third Normal Form (3NF):** In `events`, `organizer_name` and `organizer_email` depend on `organizer_id`, while `venue_name`, `venue_city`, and `venue_capacity` depend on `venue_code` instead of directly on `event_id`. I split those out into `organizers` and `venues`, leaving only `organizer_id` and `venue_code` as foreign keys in `events`. Now every non-key attribute depends solely on its own table's primary key.

### 4. Final Relational Schema Notation
```text
venues(<u>venue_code</u>, venue_name, venue_city, venue_capacity)

organizers(<u>organizer_id</u>, organizer_name, organizer_email)

events(<u>event_id</u>, event_title, organizer_id [FK], venue_code [FK])

bookings(<u>booking_id</u>, event_id [FK], session_code, booking_date, ticket_category, ticket_price, tickets_booked, booking_status)

speakers(<u>speaker_id</u>, speaker_name)

session_speakers(<u>booking_id</u> [FK], <u>speaker_id</u> [FK])
```

### Evidence
From `event_booking_flat` (`eventhub_seed.sql`):
- Rows `(101, 'SESS-A1')`, `(101, 'SESS-A2')`, and `(103, 'SESS-A1')` all repeat `'V-METRO' | 'Metro Tech Auditorium' | 'Quezon City' | 300`, demonstrating the update anomaly.
- Rows `(102, 'SESS-B1')` and `(104, 'SESS-C1')` repeat organizer `2` (`'Green Earth Initiative'`, `'contact@greenearth.org'`) and venue `'V-BAY'`.
- Row `(103, 'SESS-A1')` is the sole record for organizer `3` (`'Innovate Campus Lab'`) and speaker `'Ms. Lim'`, demonstrating the deletion anomaly.
- Rows `(101, 'SESS-A1')`, `(103, 'SESS-A1')`, `(104, 'SESS-C1')`, and `(106, 'SESS-D2')` store comma-separated strings in `speaker_list` (e.g., `'Dr. Perez, Engr. Cruz'`), violating 1NF.

### Reflection
Why does the many-to-many relationship between sessions and speakers require a junction table instead of another column?

Adding extra columns like `speaker_1` and `speaker_2` creates a repeating group that violates 1NF and breaks as soon as a session invites a third speaker. A junction table (`session_speakers`) stores one `(booking_id, speaker_id)` pair per row, so a session can have any number of speakers and the same speaker (`Dr. Perez`, `Engr. Cruz`, `Prof. Santos`, `Dr. Aquino`) can be linked to multiple sessions without duplicating their name.

---

## Task 2: DDL Implementation with Constraints

### Approach
I implemented the 6 tables in `task2_schema_ddl.sql` using `VARCHAR` for codes, names, emails, and categories, `INT` for IDs and counts, `DATE` for `booking_date`, and `DECIMAL(8,2)` for `ticket_price` so currency amounts stay exact. I created parent tables (`venues`, `organizers`, `speakers`) before child tables (`events`, `bookings`, `session_speakers`) so every `FOREIGN KEY` resolves cleanly. I added `NOT NULL` on all required fields, `UNIQUE (organizer_email)` on `organizers`, `DEFAULT 'CONFIRMED'` on `booking_status`, and `CHECK` constraints (`venue_capacity > 0` and `ticket_price >= 0.00`) to stop bad data at the database level.

### Code / Query Used
Full script is in [`task2_schema_ddl.sql`](task2_schema_ddl.sql). Summary of tables and guardrails created:
```sql
CREATE TABLE venues (
    venue_code VARCHAR(20) NOT NULL,
    venue_name VARCHAR(100) NOT NULL,
    venue_city VARCHAR(50) NOT NULL,
    venue_capacity INT NOT NULL,
    PRIMARY KEY (venue_code),
    CONSTRAINT chk_venue_capacity CHECK (venue_capacity > 0)
);

CREATE TABLE organizers (
    organizer_id INT NOT NULL,
    organizer_name VARCHAR(100) NOT NULL,
    organizer_email VARCHAR(100) NOT NULL,
    PRIMARY KEY (organizer_id),
    CONSTRAINT uq_organizer_email UNIQUE (organizer_email)
);

CREATE TABLE events (
    event_id INT NOT NULL,
    event_title VARCHAR(150) NOT NULL,
    organizer_id INT NOT NULL,
    venue_code VARCHAR(20) NOT NULL,
    PRIMARY KEY (event_id),
    CONSTRAINT fk_event_organizer FOREIGN KEY (organizer_id) REFERENCES organizers(organizer_id),
    CONSTRAINT fk_event_venue FOREIGN KEY (venue_code) REFERENCES venues(venue_code)
);

CREATE TABLE bookings (
    booking_id INT NOT NULL AUTO_INCREMENT,
    event_id INT NOT NULL,
    session_code VARCHAR(20) NOT NULL,
    booking_date DATE NOT NULL,
    ticket_category VARCHAR(50) NOT NULL,
    ticket_price DECIMAL(8,2) NOT NULL,
    tickets_booked INT NOT NULL,
    booking_status VARCHAR(20) NOT NULL DEFAULT 'CONFIRMED',
    PRIMARY KEY (booking_id),
    CONSTRAINT fk_booking_event FOREIGN KEY (event_id) REFERENCES events(event_id),
    CONSTRAINT chk_ticket_price CHECK (ticket_price >= 0.00)
);

CREATE TABLE speakers (
    speaker_id INT NOT NULL AUTO_INCREMENT,
    speaker_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (speaker_id)
);

CREATE TABLE session_speakers (
    booking_id INT NOT NULL,
    speaker_id INT NOT NULL,
    PRIMARY KEY (booking_id, speaker_id),
    CONSTRAINT fk_ss_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    CONSTRAINT fk_ss_speaker FOREIGN KEY (speaker_id) REFERENCES speakers(speaker_id)
);
```

### Evidence: Table Verification (SHOW TABLES / DESCRIBE)
```text
+----------------------------+
| Tables_in_eventhub_midterm |
+----------------------------+
| bookings                   |
| event_booking_flat         |
| events                     |
| organizers                 |
| session_speakers           |
| speakers                   |
| venues                     |
+----------------------------+

DESCRIBE venues;
+----------------+--------------+------+-----+---------+-------+
| Field          | Type         | Null | Key | Default | Extra |
+----------------+--------------+------+-----+---------+-------+
| venue_code     | varchar(20)  | NO   | PRI | NULL    |       |
| venue_name     | varchar(100) | NO   |     | NULL    |       |
| venue_city     | varchar(50)  | NO   |     | NULL    |       |
| venue_capacity | int          | NO   |     | NULL    |       |
+----------------+--------------+------+-----+---------+-------+

DESCRIBE organizers;
+-----------------+--------------+------+-----+---------+-------+
| Field           | Type         | Null | Key | Default | Extra |
+-----------------+--------------+------+-----+---------+-------+
| organizer_id    | int          | NO   | PRI | NULL    |       |
| organizer_name  | varchar(100) | NO   |     | NULL    |       |
| organizer_email | varchar(100) | NO   | UNI | NULL    |       |
+-----------------+--------------+------+-----+---------+-------+

DESCRIBE events;
+--------------+--------------+------+-----+---------+-------+
| Field        | Type         | Null | Key | Default | Extra |
+--------------+--------------+------+-----+---------+-------+
| event_id     | int          | NO   | PRI | NULL    |       |
| event_title  | varchar(150) | NO   |     | NULL    |       |
| organizer_id | int          | NO   | MUL | NULL    |       |
| venue_code   | varchar(20)  | NO   | MUL | NULL    |       |
+--------------+--------------+------+-----+---------+-------+

DESCRIBE bookings;
+-----------------+--------------+------+-----+-----------+----------------+
| Field           | Type         | Null | Key | Default   | Extra          |
+-----------------+--------------+------+-----+-----------+----------------+
| booking_id      | int          | NO   | PRI | NULL      | auto_increment |
| event_id        | int          | NO   | MUL | NULL      |                |
| session_code    | varchar(20)  | NO   |     | NULL      |                |
| booking_date    | date         | NO   |     | NULL      |                |
| ticket_category | varchar(50)  | NO   |     | NULL      |                |
| ticket_price    | decimal(8,2) | NO   |     | NULL      |                |
| tickets_booked  | int          | NO   |     | NULL      |                |
| booking_status  | varchar(20)  | NO   |     | CONFIRMED |                |
+-----------------+--------------+------+-----+-----------+----------------+

DESCRIBE speakers;
+--------------+--------------+------+-----+---------+----------------+
| Field        | Type         | Null | Key | Default | Extra          |
+--------------+--------------+------+-----+---------+----------------+
| speaker_id   | int          | NO   | PRI | NULL    | auto_increment |
| speaker_name | varchar(100) | NO   |     | NULL    |                |
+--------------+--------------+------+-----+---------+----------------+

DESCRIBE session_speakers;
+------------+------+------+-----+---------+-------+
| Field      | Type | Null | Key | Default | Extra |
+------------+------+------+-----+---------+-------+
| booking_id | int  | NO   | PRI | NULL    |       |
| speaker_id | int  | NO   | PRI | NULL    |       |
+------------+------+------+-----+---------+-------+
```

### Reflection
Which table in your schema needed a composite primary key, and why?

`session_speakers` needed a composite primary key on `(booking_id, speaker_id)` because it is the junction table connecting `bookings` and `speakers`. Neither `booking_id` nor `speaker_id` is unique on its own inside `session_speakers` (one session booking can have two speakers, and one speaker can speak at multiple sessions), so combining both foreign keys uniquely identifies each link and stops duplicate pairings of the same speaker to the same session.

---

## Task 3: Data Migration & Safe DML Operations

### Approach
To migrate the data cleanly without losing anything, I used `INSERT INTO ... SELECT DISTINCT` from `event_booking_flat` to load `venues`, `organizers`, and `events` first, then inserted the 7 session rows into `bookings` ordered by `(booking_id, session_code)`. Next, I inserted the 7 unique speaker names into `speakers` and mapped each of the 11 `(booking_id, speaker_id)` pairs into `session_speakers` so comma-separated entries like `'Dr. Perez, Engr. Cruz'` became two separate atomic rows. After adding `'V-CAMPUS'`, I followed the 4-step Safe Change Loop for both the 10% ticket price update and the `V-TEMP` delete, and tested `chk_ticket_price` with a negative price.

### Code / Query Used
Full script is in [`task3_dml_operations.sql`](task3_dml_operations.sql). Migration and `'V-CAMPUS'` insert:
```sql
INSERT INTO venues (venue_code, venue_name, venue_city, venue_capacity)
SELECT DISTINCT venue_code, venue_name, venue_city, venue_capacity
FROM event_booking_flat;

INSERT INTO organizers (organizer_id, organizer_name, organizer_email)
SELECT DISTINCT organizer_id, organizer_name, organizer_email
FROM event_booking_flat;

INSERT INTO events (event_id, event_title, organizer_id, venue_code)
SELECT DISTINCT booking_id, event_title, organizer_id, venue_code
FROM event_booking_flat;

INSERT INTO bookings (event_id, session_code, booking_date, ticket_category, ticket_price, tickets_booked)
SELECT booking_id, session_code, booking_date, ticket_category, ticket_price, tickets_booked
FROM event_booking_flat
ORDER BY booking_id, session_code;

INSERT INTO speakers (speaker_name) VALUES
('Dr. Perez'),
('Engr. Cruz'),
('Prof. Santos'),
('Ms. Lim'),
('Dr. Reyes'),
('Dr. Aquino'),
('Engr. Tan');

INSERT INTO session_speakers (booking_id, speaker_id) VALUES
(1, 1), (1, 2), (2, 2), (3, 3), (4, 1), (4, 4), (5, 3), (5, 5), (6, 6), (7, 6), (7, 7);

INSERT INTO venues (venue_code, venue_name, venue_city, venue_capacity)
VALUES ('V-CAMPUS', 'University Amphitheater', 'Quezon City', 500);
```

### Safe Change Loop: 10% Ticket Price Increase
- **Step 1 (Preview Rows):**
  ```sql
  SELECT booking_id, event_id, session_code, ticket_category, ticket_price
  FROM bookings
  WHERE ticket_price > 400.00;
  ```
  ```text
  +------------+----------+--------------+-----------------+--------------+
  | booking_id | event_id | session_code | ticket_category | ticket_price |
  +------------+----------+--------------+-----------------+--------------+
  |          1 |      101 | SESS-A1      | Standard        |       500.00 |
  |          2 |      101 | SESS-A2      | VIP             |      1200.00 |
  |          6 |      105 | SESS-D1      | VIP             |      1500.00 |
  |          7 |      106 | SESS-D2      | Standard        |       600.00 |
  +------------+----------+--------------+-----------------+--------------+
  ```
- **Step 2 (Confirm Target Count):**
  The preview returned 4 rows (`booking_id` 1, 2, 6, and 7), which matches the 4 sessions priced above `400.00`.
- **Step 3 (Execute UPDATE):**
  ```sql
  UPDATE bookings
  SET ticket_price = ROUND(ticket_price * 1.10, 2)
  WHERE ticket_price > 400.00;
  ```
- **Step 4 (Verify Changes):**
  ```sql
  SELECT booking_id, event_id, session_code, ticket_category, ticket_price
  FROM bookings
  WHERE ticket_price > 400.00;
  ```
  ```text
  +------------+----------+--------------+-----------------+--------------+
  | booking_id | event_id | session_code | ticket_category | ticket_price |
  +------------+----------+--------------+-----------------+--------------+
  |          1 |      101 | SESS-A1      | Standard        |       550.00 |
  |          2 |      101 | SESS-A2      | VIP             |      1320.00 |
  |          6 |      105 | SESS-D1      | VIP             |      1650.00 |
  |          7 |      106 | SESS-D2      | Standard        |       660.00 |
  +------------+----------+--------------+-----------------+--------------+
  ```

### Safe Change Loop: DELETE of `V-TEMP`
- **Step 1 (Preview Rows):**
  ```sql
  SELECT * FROM venues WHERE venue_code = 'V-TEMP';
  ```
  ```text
  +------------+----------------------+------------+----------------+
  | venue_code | venue_name           | venue_city | venue_capacity |
  +------------+----------------------+------------+----------------+
  | V-TEMP     | Temporary Annex Hall | Makati     |            100 |
  +------------+----------------------+------------+----------------+
  ```
- **Step 2 (Confirm Target Count):**
  The preview returned 1 row (`venue_code = 'V-TEMP'`), confirming only the temporary venue would be removed.
- **Step 3 (Execute DELETE):**
  ```sql
  DELETE FROM venues WHERE venue_code = 'V-TEMP';
  ```
- **Step 4 (Verify Changes):**
  ```sql
  SELECT * FROM venues WHERE venue_code = 'V-TEMP';
  ```
  Returned `Empty set (0 rows)`, and `SELECT * FROM venues;` still contains all 4 remaining venues (`V-BAY`, `V-CAMPUS`, `V-METRO`, `V-PARK`).

### Evidence: Constraint Protection Verification
- **Invalid SQL Statement:**
  ```sql
  INSERT INTO bookings (event_id, session_code, booking_date, ticket_category, ticket_price, tickets_booked)
  VALUES (101, 'SESS-BAD', '2025-04-25', 'Standard', -100.00, 1);
  ```
- **MySQL Error Message Received:**
  ```text
  ERROR 3819 (HY000) at line 1: Check constraint 'chk_ticket_price' is violated.
  ```

### Reflection
Why is the `DELETE` targeted by primary key rather than by venue name?

Targeting by primary key (`venue_code = 'V-TEMP'`) guarantees only that exact record is matched because primary keys are unique. If you filter by `venue_name` instead, two venues with similar or identical names could accidentally get deleted at once, or a small spelling mismatch could make the `DELETE` miss the row completely.

---

## Task 4: Filtering, Functions & Aggregate Analytics

### Approach
All 4 queries are saved in [`task4_analytics.sql`](task4_analytics.sql). For Query 1, I wrapped the `OR` condition in parentheses so SQL would not evaluate `AND` before `OR` and leak rows outside the April 10 to April 20 date range. For Query 2, I joined `bookings`, `events`, and `organizers` so I could pull `organizer_name` and `organizer_email` into `CONCAT()` and compute `DATEDIFF('2025-05-01', b.booking_date)` with a positive day count. For Query 3, I used `LIKE '%City'` and `LIKE 'M%'` on `venue_city`. For Query 4, I grouped by `ticket_category` and used `HAVING SUM(tickets_booked) >= 5` after aggregation.

### Query 1: Compound Logical Filtering with Precedence
**SQL Query:**
```sql
SELECT booking_id, event_id, session_code, booking_date, ticket_category, ticket_price, tickets_booked
FROM bookings
WHERE booking_date BETWEEN '2025-04-10' AND '2025-04-20'
  AND (ticket_category = 'VIP' OR ticket_price > 500.00);
```
**Output:**
```text
+------------+----------+--------------+--------------+-----------------+--------------+----------------+
| booking_id | event_id | session_code | booking_date | ticket_category | ticket_price | tickets_booked |
+------------+----------+--------------+--------------+-----------------+--------------+----------------+
|          1 |      101 | SESS-A1      | 2025-04-10   | Standard        |       550.00 |              4 |
|          2 |      101 | SESS-A2      | 2025-04-10   | VIP             |      1320.00 |              2 |
|          6 |      105 | SESS-D1      | 2025-04-20   | VIP             |      1650.00 |              1 |
+------------+----------+--------------+--------------+-----------------+--------------+----------------+
```

### Query 2: Scalar String & Date Functions
**SQL Query:**
```sql
SELECT b.booking_id,
       e.event_title,
       CONCAT(o.organizer_name, ' <', o.organizer_email, '>') AS contact_card,
       b.booking_date,
       DATEDIFF('2025-05-01', b.booking_date) AS days_elapsed
FROM bookings b
INNER JOIN events e ON b.event_id = e.event_id
INNER JOIN organizers o ON e.organizer_id = o.organizer_id;
```
**Output:**
```text
+------------+-----------------------------+-------------------------------------------------+--------------+--------------+
| booking_id | event_title                 | contact_card                                    | booking_date | days_elapsed |
+------------+-----------------------------+-------------------------------------------------+--------------+--------------+
|          1 | Modern Web & DB Summit      | Tech Forward PH <info@techforward.ph>           | 2025-04-10   |           21 |
|          2 | Modern Web & DB Summit      | Tech Forward PH <info@techforward.ph>           | 2025-04-10   |           21 |
|          3 | Urban Ecology Seminar       | Green Earth Initiative <contact@greenearth.org> | 2025-04-12   |           19 |
|          5 | Community Climate Action    | Green Earth Initiative <contact@greenearth.org> | 2025-04-18   |           13 |
|          4 | AI & Cloud Infrastructure   | Innovate Campus Lab <lead@innovatecampus.edu>   | 2025-04-15   |           16 |
|          6 | Health Informatics 2025     | Digital Health Alliance <care@digitalhealth.ph> | 2025-04-20   |           11 |
|          7 | Telemedicine Implementation | Digital Health Alliance <care@digitalhealth.ph> | 2025-04-22   |            9 |
+------------+-----------------------------+-------------------------------------------------+--------------+--------------+
```

### Query 3: Pattern Matching with LIKE Wildcards
**SQL Query:**
```sql
SELECT venue_code, venue_name, venue_city, venue_capacity
FROM venues
WHERE venue_city LIKE '%City'
   OR venue_city LIKE 'M%';
```
**Output:**
```text
+------------+-------------------------+-------------+----------------+
| venue_code | venue_name              | venue_city  | venue_capacity |
+------------+-------------------------+-------------+----------------+
| V-BAY      | Bayview Convention Hall | Manila      |            150 |
| V-CAMPUS   | University Amphitheater | Quezon City |            500 |
| V-METRO    | Metro Tech Auditorium   | Quezon City |            300 |
+------------+-------------------------+-------------+----------------+
```

### Query 4: GROUP BY and HAVING Summary
**SQL Query:**
```sql
SELECT ticket_category,
       SUM(tickets_booked) AS total_tickets_booked,
       SUM(tickets_booked * ticket_price) AS gross_revenue
FROM bookings
GROUP BY ticket_category
HAVING SUM(tickets_booked) >= 5;
```
**Output:**
```text
+-----------------+----------------------+---------------+
| ticket_category | total_tickets_booked | gross_revenue |
+-----------------+----------------------+---------------+
| Standard        |                   18 |       8960.00 |
| Student         |                   10 |       2500.00 |
+-----------------+----------------------+---------------+
```

### Reflection
Why does Query 4 filter with `HAVING` instead of `WHERE`?

Because `WHERE` runs on individual rows before `GROUP BY` groups them together, so aggregate totals like `SUM(tickets_booked)` do not exist yet when `WHERE` executes. Putting `SUM(tickets_booked) >= 5` inside `WHERE` throws a syntax/invalid-use error, whereas `HAVING` runs after `GROUP BY` and filters out groups like `VIP` (which only has 3 total tickets booked).

---

## Task 5: Multi-Table Joins & Outer Join Diagnostics

### Approach
All queries for this task are in [`task5_joins.sql`](task5_joins.sql). For the lossless report, I started from `bookings` and joined `events` on `event_id`, then joined `venues` on `venue_code` and `organizers` on `organizer_id` using table aliases `b`, `e`, `v`, and `o`. For the unbooked venue check and the VIP diagnostic, I started from `venues` on the left so venues with no events or bookings would be preserved before applying `IS NULL` or the `ON` condition.

### 1. Multi-Table INNER JOIN
**SQL Query:**
```sql
SELECT e.event_title,
       o.organizer_name,
       v.venue_name,
       b.ticket_category,
       b.tickets_booked,
       (b.tickets_booked * b.ticket_price) AS total_price
FROM bookings b
INNER JOIN events e ON b.event_id = e.event_id
INNER JOIN venues v ON e.venue_code = v.venue_code
INNER JOIN organizers o ON e.organizer_id = o.organizer_id
ORDER BY b.booking_id;
```
**Output:**
```text
+-----------------------------+-------------------------+------------------------------+-----------------+----------------+-------------+
| event_title                 | organizer_name          | venue_name                   | ticket_category | tickets_booked | total_price |
+-----------------------------+-------------------------+------------------------------+-----------------+----------------+-------------+
| Modern Web & DB Summit      | Tech Forward PH         | Metro Tech Auditorium        | Standard        |              4 |     2200.00 |
| Modern Web & DB Summit      | Tech Forward PH         | Metro Tech Auditorium        | VIP             |              2 |     2640.00 |
| Urban Ecology Seminar       | Green Earth Initiative  | Bayview Convention Hall      | Standard        |              5 |     1750.00 |
| AI & Cloud Infrastructure   | Innovate Campus Lab     | Metro Tech Auditorium        | Student         |             10 |     2500.00 |
| Community Climate Action    | Green Earth Initiative  | Bayview Convention Hall      | Standard        |              3 |     1050.00 |
| Health Informatics 2025     | Digital Health Alliance | Greenfield Innovation Center | VIP             |              1 |     1650.00 |
| Telemedicine Implementation | Digital Health Alliance | Greenfield Innovation Center | Standard        |              6 |     3960.00 |
+-----------------------------+-------------------------+------------------------------+-----------------+----------------+-------------+
```

### 2. Finding Unbooked Venues (LEFT JOIN ... IS NULL)
**SQL Query:**
```sql
SELECT v.venue_code,
       v.venue_name,
       v.venue_city,
       v.venue_capacity
FROM venues v
LEFT JOIN events e ON v.venue_code = e.venue_code
LEFT JOIN bookings b ON e.event_id = b.event_id
WHERE b.booking_id IS NULL;
```
**Output:**
```text
+------------+-------------------------+-------------+----------------+
| venue_code | venue_name              | venue_city  | venue_capacity |
+------------+-------------------------+-------------+----------------+
| V-CAMPUS   | University Amphitheater | Quezon City |            500 |
+------------+-------------------------+-------------+----------------+
```

### 3. The "Silent Inner Join" Trap Comparison
- **Version A (Flawed WHERE filter):**
  ```sql
  SELECT v.venue_code,
         v.venue_name,
         b.booking_id,
         b.session_code,
         b.ticket_category,
         b.ticket_price
  FROM venues v
  LEFT JOIN events e ON v.venue_code = e.venue_code
  LEFT JOIN bookings b ON e.event_id = b.event_id
  WHERE b.ticket_category = 'VIP';
  ```
  *Result / Behavior:*
  ```text
  +------------+------------------------------+------------+--------------+-----------------+--------------+
  | venue_code | venue_name                   | booking_id | session_code | ticket_category | ticket_price |
  +------------+------------------------------+------------+--------------+-----------------+--------------+
  | V-METRO    | Metro Tech Auditorium        |          2 | SESS-A2      | VIP             |      1320.00 |
  | V-PARK     | Greenfield Innovation Center |          6 | SESS-D1      | VIP             |      1650.00 |
  +------------+------------------------------+------------+--------------+-----------------+--------------+
  ```
  Only 2 rows return. `V-BAY` and `V-CAMPUS` disappear completely from the output even though `LEFT JOIN` was used.

- **Version B (Correct ON condition):**
  ```sql
  SELECT v.venue_code,
         v.venue_name,
         b.booking_id,
         b.session_code,
         b.ticket_category,
         b.ticket_price
  FROM venues v
  LEFT JOIN events e ON v.venue_code = e.venue_code
  LEFT JOIN bookings b ON e.event_id = b.event_id AND b.ticket_category = 'VIP';
  ```
  *Result / Behavior:*
  ```text
  +------------+------------------------------+------------+--------------+-----------------+--------------+
  | venue_code | venue_name                   | booking_id | session_code | ticket_category | ticket_price |
  +------------+------------------------------+------------+--------------+-----------------+--------------+
  | V-BAY      | Bayview Convention Hall      |       NULL | NULL         | NULL            |         NULL |
  | V-BAY      | Bayview Convention Hall      |       NULL | NULL         | NULL            |         NULL |
  | V-CAMPUS   | University Amphitheater      |       NULL | NULL         | NULL            |         NULL |
  | V-METRO    | Metro Tech Auditorium        |          2 | SESS-A2      | VIP             |      1320.00 |
  | V-METRO    | Metro Tech Auditorium        |       NULL | NULL         | NULL            |         NULL |
  | V-PARK     | Greenfield Innovation Center |          6 | SESS-D1      | VIP             |      1650.00 |
  | V-PARK     | Greenfield Innovation Center |       NULL | NULL         | NULL            |         NULL |
  +------------+------------------------------+------------+--------------+-----------------+--------------+
  ```
  All 4 venues (`V-BAY`, `V-CAMPUS`, `V-METRO`, `V-PARK`) stay in the result set, with `NULL` values shown where an event or venue has no VIP booking.

- **Technical Explanation:**
  `LEFT JOIN` builds the joined rows first and fills unmatched right-side columns (like `b.ticket_category` for `V-CAMPUS`) with `NULL`. When `WHERE b.ticket_category = 'VIP'` runs afterwards, it checks the final paired rows, and since `NULL = 'VIP'` never evaluates to true (it evaluates to `UNKNOWN`), `WHERE` drops all unmatched and non-VIP rows. That silently turns the `LEFT JOIN` into an `INNER JOIN`. Placing `AND b.ticket_category = 'VIP'` inside the `ON` clause restricts which right-side rows match during the join step while still preserving every left-side venue row.

### Reflection
Why is `= NULL` the wrong way to find unbooked venues, and what is the correct test?

In SQL, `NULL` represents an unknown value, so comparing `b.booking_id = NULL` always evaluates to `UNKNOWN` (never true) and returns zero rows. The correct operator is `IS NULL` (written as `WHERE b.booking_id IS NULL`), which specifically checks whether the column has no value.

---

## Task 6: Schema Evolution & Cross-Week Synthesis

### Approach
In [`task6_synthesis.sql`](task6_synthesis.sql), I evolved the `venues` table using `ALTER TABLE` to add `venue_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'` along with a `CHECK` constraint restricting values to `'ACTIVE'`, `'RENOVATION'`, or `'INACTIVE'`. After updating `V-PARK` to `'RENOVATION'` using its primary key and confirming that `'CLOSED'` gets rejected, I wrote the synthesis query joining `venues`, `events`, and `bookings` with `WHERE`, `GROUP BY`, `HAVING`, and `ORDER BY` together.

### 1. ALTER TABLE Statement & Status Constraint
```sql
ALTER TABLE venues
ADD COLUMN venue_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
ADD CONSTRAINT chk_venue_status CHECK (venue_status IN ('ACTIVE', 'RENOVATION', 'INACTIVE'));
```

### 2. Targeted Primary-Key UPDATE
```sql
SELECT venue_code, venue_name, venue_status
FROM venues
WHERE venue_code = 'V-PARK';

UPDATE venues
SET venue_status = 'RENOVATION'
WHERE venue_code = 'V-PARK';

SELECT venue_code, venue_name, venue_status
FROM venues
WHERE venue_code = 'V-PARK';
```
Output after update:
```text
+------------+------------------------------+--------------+
| venue_code | venue_name                   | venue_status |
+------------+------------------------------+--------------+
| V-PARK     | Greenfield Innovation Center | RENOVATION   |
+------------+------------------------------+--------------+
```

### 3. Constraint Test (invalid status)
- **Invalid SQL Statement:**
  ```sql
  UPDATE venues SET venue_status = 'CLOSED' WHERE venue_code = 'V-PARK';
  ```
- **MySQL Error Message Received:**
  ```text
  ERROR 3819 (HY000) at line 1: Check constraint 'chk_venue_status' is violated.
  ```

### 4. Integrated Synthesis Report Query
**SQL Query:**
```sql
SELECT v.venue_name,
       v.venue_city,
       COUNT(b.booking_id) AS total_bookings,
       SUM(b.tickets_booked) AS total_attendees,
       ROUND(AVG(b.ticket_price), 2) AS avg_ticket_price,
       SUM(b.tickets_booked * b.ticket_price) AS total_revenue
FROM venues v
INNER JOIN events e ON v.venue_code = e.venue_code
INNER JOIN bookings b ON e.event_id = b.event_id
WHERE v.venue_status = 'ACTIVE'
GROUP BY v.venue_name, v.venue_city
HAVING AVG(b.ticket_price) > 300.00
ORDER BY total_revenue DESC;
```
**Output:**
```text
+-------------------------+-------------+----------------+-----------------+------------------+---------------+
| venue_name              | venue_city  | total_bookings | total_attendees | avg_ticket_price | total_revenue |
+-------------------------+-------------+----------------+-----------------+------------------+---------------+
| Metro Tech Auditorium   | Quezon City |              3 |              16 |           706.67 |       7340.00 |
| Bayview Convention Hall | Manila      |              2 |               8 |           350.00 |       2800.00 |
+-------------------------+-------------+----------------+-----------------+------------------+---------------+
```

### Reflection
Why does adding `NOT NULL DEFAULT 'ACTIVE'` succeed on a table that already holds rows?

Because MySQL automatically fills in the `DEFAULT` value (`'ACTIVE'`) for all existing rows when adding the new column. Since every row gets `'ACTIVE'` right away, none of them contain `NULL`, so the `NOT NULL` constraint is satisfied immediately without throwing an error.

---

## Task 7: Self-Review & Reflection

### Self-Audit Checklist
- [x] All three anomalies (update, insert, delete) clearly explained with examples
- [x] Schema systematically normalized from flat table $\rightarrow$ 1NF $\rightarrow$ 2NF $\rightarrow$ 3NF
- [x] Speakers modeled with a junction table
- [x] All primary keys underlined and foreign keys marked in schema notation
- [x] DDL created with `NOT NULL`, `UNIQUE`, `DEFAULT`, and `CHECK` constraints
- [x] 4-step Safe Change Loop followed for the `UPDATE` and the `DELETE`
- [x] Invalid insert correctly triggered and documented MySQL constraint error
- [x] Query 1 properly uses parentheses for `AND` / `OR` operator precedence
- [x] Query 4 properly uses `HAVING` instead of `WHERE` for aggregate filter
- [x] Outer join missing-record query uses `IS NULL` check
- [x] Silent inner join trap clearly explained with both query variations
- [x] `ALTER TABLE` successfully executed and invalid status rejected
- [x] Integrated synthesis report combines joins, aggregation, grouping, and ordering

### Concluding Reflection
1. What was the most significant challenge when decomposing the unnormalized flat table into 3NF, and how did separating entities improve data integrity?
   
   The trickiest part was figuring out the grain of the flat table in Task 1 and 2NF: `event_booking_flat` used `(booking_id, session_code)` where event `101` had two sessions (`SESS-A1` and `SESS-A2`), while `speaker_list` held comma-separated names inside each session row. Splitting `events` from `bookings` and putting speakers into `speakers` plus `session_speakers` made every row clean and atomic. After separating `venues` and `organizers`, adding `V-CAMPUS` in Task 3 or marking `V-PARK` as `'RENOVATION'` in Task 6 only touched one row instead of needing multiple edits across repeated booking records, and constraints like `UNIQUE (organizer_email)` and `chk_ticket_price` kept invalid values out completely.

2. What are the practical performance tradeoffs between keeping a single flat table versus querying multiple normalized tables using `JOIN`s in a high-traffic production environment?
   
   A single flat table like `event_booking_flat` lets you read everything with a quick `SELECT` without joining tables, which can feel faster for read-heavy dashboards. However, writes become slow and risky because updating one venue's capacity or status requires locking and updating dozens or thousands of repeated rows, and duplicated strings waste storage and cache memory. Normalized 3NF tables like our 6-table schema keep writes fast and consistent on single rows, at the cost of having to run multi-table `JOIN`s (like in Task 5 and Task 6) on read queries. In production, you usually keep the main transactional database normalized to 3NF with proper indexes on the foreign keys (`event_id`, `organizer_id`, `venue_code`) so joins stay fast, and only use summary views or denormalized caches if heavy reporting queries actually start slowing down.
