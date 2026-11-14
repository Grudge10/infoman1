# INFOMAN1 — Midterm Practical Assessment: Answer Document

**Name:** Jan Liam E. Arias  
**Student ID:** 2510499  
**Repository URL:** https://github.com/Grudge10/infoman1  
**Date Submitted:** 2026-11-14

---

## Task 1: Normalization Audit & 3NF Decomposition

### Approach
I started by loading `eventhub_seed.sql` into MySQL and ran a `SELECT * FROM event_booking_flat` query to view all 7 rows. I immediately saw that the `speaker_list` field was using commas to separate the values and that the venue and organiser details were duplicated. I noted the functional dependencies and normalised to 1NF to ensure all the columns were atomic, 2NF to remove any attributes that depend on a partial key and 3NF to remove any attributes that depend on non-key attributes such as `venue_code` and `organizer_id`.

### 1. Data Anomalies in `event_booking_flat`
- **Update Anomaly:** The venue `'V-METRO'` (capacity 300) is listed in three rows (`101/SESS-A1`, `101/SESS-A2`, `103/SESS-A1`). Therefore, if it is renovated to increase the capacity to 350, all three rows must be updated. If any of the rows are not updated, this will cause a discrepancy as there will be two different capacities for the same venue. This also occurs for the venues `'V-BAY'`, `'V-PARK'` and for partners such as `'Green Earth Initiative'` which both have two rows.
- **Insertion Anomaly:** As the primary key is made up of `(booking_id, session_code)` and `booking_date`, `event_title` and `organizer_id` are all set to `NOT NULL`, we cannot add a new partner venue such as `'V-CAMPUS'` (University Amphitheater) without having an existing event booking, unless dummy data is inserted for the booking.
- **Deletion Anomaly:** The row `(103, 'SESS-A1')` is the only row that contains the data for (`organizer_id` 3) `'Innovate Campus Lab'` (`lead@innovatecampus.edu`) and speaker Ms. Lim. If this one booking is cancelled/deleted then we will lose the record of the organizer and their contact email altogether.

### 2. Functional Dependencies
- `(booking_id, session_code) -> booking_date, event_title, organizer_id, venue_code, ticket_category, ticket_price, tickets_booked`
- `booking_id -> booking_date, event_title, organizer_id, venue_code` (partial dependency in the flat table)
- `organizer_id -> organizer_name, organizer_email` (transitive dependency via `booking_id`)
- `venue_code -> venue_name, venue_city, venue_capacity` (transitive dependency via `booking_id`)
- `speaker_id -> speaker_name` (after extracting atomic speakers)
- `(booking_id, session_code)` + `speaker_id` is many-to-many (each session booking can have multiple speakers, and a speaker like `Dr. Perez` or `Dr. Aquino` appears across multiple sessions)

### 3. Normalization Progression
- **First Normal Form (1NF):** The `speaker_list` attribute within the `event_booking_flat` table violates atomicity as we have multiple values within a single cell (i.e. `Dr. Perez, Engr. Cruz`). To resolve this, I removed the `speaker_list` attribute from the `bookings` table. This means there is only one value in each cell. I created a new table called `speakers` with the format `(speaker_id, speaker_name)` that can be joined to `bookings` using a bridge table called `session_speakers (booking_id, speaker_id)`. Each row within the session bookings table also has a unique surrogate key called `booking_id` (the seed table had multiple bookings with the same `booking_id` 101).
- **Second Normal Form (2NF):** Within the original flat key structure `(booking_id, session_code)` we have columns that describe the event booking as a whole. These are: `booking_date`, `event_title`, `organizer_id`, `organizer_name`, `organizer_email`, `venue_code`, `venue_name`, `venue_city` and `venue_capacity`. By moving these event attributes into a separate table called `events`, keyed by `event_id` (which contain the original event IDs 101-106), this will ensure our session columns (`session_code`, `booking_date`, `ticket_category`, `ticket_price`, `tickets_booked`) are within `bookings` and are dependent on the full primary key `booking_id`.
- **Third Normal Form (3NF):** The `events` table contains transitive dependencies as the `organizer_name` and `organizer_email` are dependent on the `organizer_id`. The `venue_name`, `venue_city` and `venue_capacity` are dependent on the `venue_code`. By creating two new tables (`organizers` and `venues`), only the `organizer_id` and `venue_code` will remain as foreign keys. This means all non-key attributes are functionally dependent solely on their own table's primary key.

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

Extra columns like `speaker_1` and `speaker_2` would cause a repeating group thus violating 1NF. This would break if there were more than two speakers invited into a session. To overcome this, a Junction Table has been created called `session_speakers`. This allows multiple speakers to be attached to a session (one `booking_id` and `speaker_id` per row). This also allows speakers (Dr. Perez, Engr. Cruz, Prof. Santos, Dr. Aquino) to be attached to multiple sessions without duplicating their name.

---

## Task 2: DDL Implementation with Constraints

### Approach
When creating the 6 tables in `task2_schema_ddl.sql`, appropriate datatypes were used. `VARCHAR` was used for code, name, email and category. `INT` for id and count. `DATE` for `booking_date`. And `DECIMAL(8,2)` for `ticket_price` so that money is accurately represented. The parent tables were created first (`venues`, `organizers`, `speakers`) followed by the child tables (`events`, `bookings`, `session_speakers`). This means all `FOREIGN KEY`s are properly resolved. Constraints were also added. All required fields had `NOT NULL`. The email field in the `organizers` table had `UNIQUE`. Default values were applied to `booking_status` so it will always be `'CONFIRMED'`. The `venue_capacity` and `ticket_price` fields have `CHECK` constraints to ensure `venue_capacity > 0` and `ticket_price >= 0.00`.

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

The composite primary key of `(booking_id, speaker_id)` is required in `session_speakers` as this is the linking table between `bookings` and `speakers`. Each individual field is not unique within the table as there can be two speakers per session booking, and each speaker can speak during multiple sessions. Therefore using both foreign keys as a composite primary key ensures that each relationship is unique as you cannot have duplicate speaker relationships to the same session.

---

## Task 3: Data Migration & Safe DML Operations

### Approach
To ensure that the data moved cleanly, the first 3 tables were populated via `INSERT INTO ... SELECT DISTINCT` from the `event_booking_flat` table. The 7 sessions were then added to the `bookings` table in order of `booking_id` and `session_code`. The 7 unique speaker names were added to the `speakers` table. Each of the 11 unique pairs for `booking_id` and `speaker_id` were added to the `session_speakers` table. This converted the comma separated values into atomic values. Adding of `'V-CAMPUS'` was performed. The Safe Change Loop was applied to the updating of the ticket price by 10% and deletion of `V-TEMP`. The `chk_ticket_price` constraint was tested with a negative value for price.

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

By using the primary key (`venue_code`) we can be certain we are only deleting the correct record. This is because primary keys are unique. If we were to search on `venue_name` we could accidentally `DELETE` 2 records with similar / same names. A misspelling could also cause us not to `DELETE` the record at all.

---

## Task 4: Filtering, Functions & Aggregate Analytics

### Approach
All four queries are stored within [`task4_analytics.sql`](task4_analytics.sql). To ensure that the `AND` condition does not get evaluated prior to the `OR` condition causing any rows which are outside the April 10 to April 20 timeframe, I put the `OR` statement within parentheses. For query two, I had to inner join multiple tables (`bookings`, `events`, `organizers`) to include the columns of the organizers in the concatenation function. I also added in `DATEDIFF('2025-05-01', b.booking_date)` to give a positive number of days. For query three, I used the `LIKE` statements using `%City` and `M%`. Finally, for query four I grouped by the `ticket_category` and used `HAVING SUM(tickets_booked) >= 5`.

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

The `WHERE` clause is applied to individual rows. This means that aggregate functions such as `SUM(tickets_booked)` do not exist yet and you will get an invalid use of syntax error. The `HAVING` clause is used after the `GROUP BY` clause. We can filter out groups like VIP which only have 3 tickets booked in total.

---

## Task 5: Multi-Table Joins & Outer Join Diagnostics

### Approach
All queries are in the file [`task5_joins.sql`](task5_joins.sql). For the lossless join report I joined on `event_id` (from `bookings`), `venue_code` (from `venues`) and `organizer_id` (from `organizers`). I used table aliases of `b`, `e`, `v`, `o`. For the unbooked venue and VIP diagnosis, I started my query with `venues` on the left so that any venues without events/bookings would remain. This way the `IS NULL` or `ON` condition could be applied.

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
  `LEFT JOIN` creates joined rows but will result in `NULL` values for any columns in the right table that are not matched (`b.ticket_category` in this case for `V-CAMPUS`). The `WHERE` is then applied to the final joined rows. As there are no instances where `NULL` will equal `'VIP'` it will remove all unmatched rows and rows where `ticket_category` is not `'VIP'`. This will effectively turn your `LEFT JOIN` into an `INNER JOIN`. By including `AND b.ticket_category = 'VIP'` in your `ON` statement you can filter the right table rows to only those where `ticket_category` is `'VIP'` whilst keeping all the left table (`venues`) rows.

### Reflection
Why is `= NULL` the wrong way to find unbooked venues, and what is the correct test?

`NULL` means unknown in SQL so when you do `b.booking_id = NULL` you will always get an `UNKNOWN` result. This means that no records would be found. We need to use the `IS NULL` operator instead. So we should use: `WHERE b.booking_id IS NULL`.

---

## Task 6: Schema Evolution & Cross-Week Synthesis

### Approach
I modified the `venues` table within [`task6_synthesis.sql`](task6_synthesis.sql) using the `ALTER TABLE` statement with an additional column added (`venue_status`). This had a default value of `'ACTIVE'` and only allowed `'ACTIVE'`, `'RENOVATION'` or `'INACTIVE'` statuses. I updated the `V-PARK` record to `'RENOVATION'` using its primary key and checked that it would not allow `'CLOSED'`. I then created my synthesis query, joining the 3 tables: `venues`, `events` and `bookings`, using `WHERE`, `GROUP BY`, `HAVING` and `ORDER BY` clauses.

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

MySQL will automatically assign a `DEFAULT` value of (in this case `'ACTIVE'`) to all existing records. This means each record will have a value of `'ACTIVE'` assigned immediately, therefore there will be no `NULL` values and the `NOT NULL` constraint will also be satisfied without any errors.

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
   
   The most difficult aspect of this task was determining the grain of the flat table in Tasks 1 and 2NF. This meant that the table `event_booking_flat` had a composite key of `booking_id` and `session_code`. For event 101 there were two sessions (`SESS-A1` and `SESS-A2`). The column `speaker_list` also had a list of names stored as a comma separated string. By separating the `events` and `bookings` tables, and separating the speakers into `speakers` and `session_speakers`, this ensured all data was in its simplest form. With the separation of `venues` and `organizers` we could easily update the venues table to include `V-CAMPUS`, or note that `V-PARK` was under renovation by simply changing one row of data. The `UNIQUE` constraint was applied to `organizer_email` and the constraint `chk_ticket_price` ensured invalid data couldn't be entered.

2. What are the practical performance tradeoffs between keeping a single flat table versus querying multiple normalized tables using `JOIN`s in a high-traffic production environment?
   
   Using a flat table like `event_booking_flat` means that all data can be read quickly using a simple `SELECT` statement. However, when trying to update data it can become very slow and risk prone. When trying to update a venue capacity or status, you have to lock the table and update many duplicate rows. There is also wasted space due to duplicate strings. When working with 3NF tables such as our 6 table design, data can be quickly and consistently updated. However, when trying to read data you have to perform `JOIN`s between tables (Tasks 5 and 6). Generally, in a real scenario the main transactional database would be kept in 3NF format with appropriate indexes on foreign keys (`event_id`, `organizer_id`, `venue_code`). If heavy queries are causing issues then summary views or denormalized caches would be used.
