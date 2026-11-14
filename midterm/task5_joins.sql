USE eventhub_midterm;

-- 1. Lossless Multi-Table INNER JOIN
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

-- 2. Outer Join Missing-Record Diagnostic (unbooked venues)
SELECT v.venue_code,
       v.venue_name,
       v.venue_city,
       v.venue_capacity
FROM venues v
LEFT JOIN events e ON v.venue_code = e.venue_code
LEFT JOIN bookings b ON e.event_id = b.event_id
WHERE b.booking_id IS NULL;

-- 3A. Version A (Flawed WHERE filter - silent inner join trap)
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

-- 3B. Version B (Correct ON condition - preserves all venues)
SELECT v.venue_code,
       v.venue_name,
       b.booking_id,
       b.session_code,
       b.ticket_category,
       b.ticket_price
FROM venues v
LEFT JOIN events e ON v.venue_code = e.venue_code
LEFT JOIN bookings b ON e.event_id = b.event_id AND b.ticket_category = 'VIP';
