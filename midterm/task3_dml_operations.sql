USE eventhub_midterm;

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
(1, 1),
(1, 2),
(2, 2),
(3, 3),
(4, 1),
(4, 4),
(5, 3),
(5, 5),
(6, 6),
(7, 6),
(7, 7);

INSERT INTO venues (venue_code, venue_name, venue_city, venue_capacity)
VALUES ('V-CAMPUS', 'University Amphitheater', 'Quezon City', 500);

-- Preview update
SELECT booking_id, event_id, session_code, ticket_category, ticket_price
FROM bookings
WHERE ticket_price > 400.00;

-- Execute update
UPDATE bookings
SET ticket_price = ROUND(ticket_price * 1.10, 2)
WHERE ticket_price > 400.00;

-- Verify update
SELECT booking_id, event_id, session_code, ticket_category, ticket_price
FROM bookings
WHERE ticket_price > 400.00;

INSERT INTO venues (venue_code, venue_name, venue_city, venue_capacity)
VALUES ('V-TEMP', 'Temporary Annex Hall', 'Makati', 100);

-- Preview delete
SELECT * FROM venues WHERE venue_code = 'V-TEMP';

-- Execute delete
DELETE FROM venues WHERE venue_code = 'V-TEMP';

-- Verify delete
SELECT * FROM venues WHERE venue_code = 'V-TEMP';

-- Rejected insert (negative ticket price)
INSERT INTO bookings (event_id, session_code, booking_date, ticket_category, ticket_price, tickets_booked)
VALUES (101, 'SESS-BAD', '2025-04-25', 'Standard', -100.00, 1);
