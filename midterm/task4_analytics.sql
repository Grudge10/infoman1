USE eventhub_midterm;

-- Query 1: Logical Filtering & Precedence
SELECT booking_id, event_id, session_code, booking_date, ticket_category, ticket_price, tickets_booked
FROM bookings
WHERE booking_date BETWEEN '2025-04-10' AND '2025-04-20'
  AND (ticket_category = 'VIP' OR ticket_price > 500.00);

/*
Output:
+------------+----------+--------------+--------------+-----------------+--------------+----------------+
| booking_id | event_id | session_code | booking_date | ticket_category | ticket_price | tickets_booked |
+------------+----------+--------------+--------------+-----------------+--------------+----------------+
|          1 |      101 | SESS-A1      | 2025-04-10   | Standard        |       550.00 |              4 |
|          2 |      101 | SESS-A2      | 2025-04-10   | VIP             |      1320.00 |              2 |
|          6 |      105 | SESS-D1      | 2025-04-20   | VIP             |      1650.00 |              1 |
+------------+----------+--------------+--------------+-----------------+--------------+----------------+
*/

-- Query 2: Text & Date Functions
SELECT b.booking_id,
       e.event_title,
       CONCAT(o.organizer_name, ' <', o.organizer_email, '>') AS contact_card,
       b.booking_date,
       DATEDIFF('2025-05-01', b.booking_date) AS days_elapsed
FROM bookings b
INNER JOIN events e ON b.event_id = e.event_id
INNER JOIN organizers o ON e.organizer_id = o.organizer_id;

/*
Output:
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
*/

-- Query 3: Pattern Matching with Wildcards
SELECT venue_code, venue_name, venue_city, venue_capacity
FROM venues
WHERE venue_city LIKE '%City'
   OR venue_city LIKE 'M%';

/*
Output:
+------------+-------------------------+-------------+----------------+
| venue_code | venue_name              | venue_city  | venue_capacity |
+------------+-------------------------+-------------+----------------+
| V-BAY      | Bayview Convention Hall | Manila      |            150 |
| V-CAMPUS   | University Amphitheater | Quezon City |            500 |
| V-METRO    | Metro Tech Auditorium   | Quezon City |            300 |
+------------+-------------------------+-------------+----------------+
*/

-- Query 4: Grouping & HAVING
SELECT ticket_category,
       SUM(tickets_booked) AS total_tickets_booked,
       SUM(tickets_booked * ticket_price) AS gross_revenue
FROM bookings
GROUP BY ticket_category
HAVING SUM(tickets_booked) >= 5;

/*
Output:
+-----------------+----------------------+---------------+
| ticket_category | total_tickets_booked | gross_revenue |
+-----------------+----------------------+---------------+
| Standard        |                   18 |       8960.00 |
| Student         |                   10 |       2500.00 |
+-----------------+----------------------+---------------+
*/
