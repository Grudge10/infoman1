USE eventhub_midterm;

ALTER TABLE venues
ADD COLUMN venue_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
ADD CONSTRAINT chk_venue_status CHECK (venue_status IN ('ACTIVE', 'RENOVATION', 'INACTIVE'));

SELECT venue_code, venue_name, venue_status
FROM venues
WHERE venue_code = 'V-PARK';

UPDATE venues
SET venue_status = 'RENOVATION'
WHERE venue_code = 'V-PARK';

SELECT venue_code, venue_name, venue_status
FROM venues
WHERE venue_code = 'V-PARK';

-- Rejected update (invalid status)
UPDATE venues SET venue_status = 'CLOSED' WHERE venue_code = 'V-PARK';
-- ERROR 3819 (HY000): Check constraint 'chk_venue_status' is violated.

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
