-- =====================================================================
-- INFOMAN1 Midterm Practical Assessment: Unnormalized Seed Data Script
-- Database: eventhub_midterm
-- Scenario: Community Event Booking System (Flawed Flat Table)
-- =====================================================================

CREATE DATABASE IF NOT EXISTS eventhub_midterm;
USE eventhub_midterm;

DROP TABLE IF EXISTS event_booking_flat;

-- Intentionally unnormalized flat table exhibiting:
-- 1. Multi-valued field speaker_list holding comma-separated names (violating 1NF)
-- 2. Partial dependencies on composite key (violating 2NF)
-- 3. Transitive dependencies between venue and city/capacity (violating 3NF)
CREATE TABLE event_booking_flat (
    booking_id INT NOT NULL,
    session_code VARCHAR(20) NOT NULL,
    booking_date DATE NOT NULL,
    organizer_id INT NOT NULL,
    organizer_name VARCHAR(100) NOT NULL,
    organizer_email VARCHAR(100) NOT NULL,
    event_title VARCHAR(150) NOT NULL,
    venue_code VARCHAR(20) NOT NULL,
    venue_name VARCHAR(100) NOT NULL,
    venue_city VARCHAR(50) NOT NULL,
    venue_capacity INT NOT NULL,
    ticket_category VARCHAR(50) NOT NULL,
    ticket_price DECIMAL(8,2) NOT NULL,
    tickets_booked INT NOT NULL,
    speaker_list VARCHAR(255) NULL,
    PRIMARY KEY (booking_id, session_code)
);

INSERT INTO event_booking_flat 
(booking_id, session_code, booking_date, organizer_id, organizer_name, organizer_email, event_title, venue_code, venue_name, venue_city, venue_capacity, ticket_category, ticket_price, tickets_booked, speaker_list)
VALUES
(101, 'SESS-A1', '2025-04-10', 1, 'Tech Forward PH', 'info@techforward.ph', 'Modern Web & DB Summit', 'V-METRO', 'Metro Tech Auditorium', 'Quezon City', 300, 'Standard', 500.00, 4, 'Dr. Perez, Engr. Cruz'),
(101, 'SESS-A2', '2025-04-10', 1, 'Tech Forward PH', 'info@techforward.ph', 'Modern Web & DB Summit', 'V-METRO', 'Metro Tech Auditorium', 'Quezon City', 300, 'VIP', 1200.00, 2, 'Engr. Cruz'),
(102, 'SESS-B1', '2025-04-12', 2, 'Green Earth Initiative', 'contact@greenearth.org', 'Urban Ecology Seminar', 'V-BAY', 'Bayview Convention Hall', 'Manila', 150, 'Standard', 350.00, 5, 'Prof. Santos'),
(103, 'SESS-A1', '2025-04-15', 3, 'Innovate Campus Lab', 'lead@innovatecampus.edu', 'AI & Cloud Infrastructure', 'V-METRO', 'Metro Tech Auditorium', 'Quezon City', 300, 'Student', 250.00, 10, 'Dr. Perez, Ms. Lim'),
(104, 'SESS-C1', '2025-04-18', 2, 'Green Earth Initiative', 'contact@greenearth.org', 'Community Climate Action', 'V-BAY', 'Bayview Convention Hall', 'Manila', 150, 'Standard', 350.00, 3, 'Prof. Santos, Dr. Reyes'),
(105, 'SESS-D1', '2025-04-20', 4, 'Digital Health Alliance', 'care@digitalhealth.ph', 'Health Informatics 2025', 'V-PARK', 'Greenfield Innovation Center', 'Pasig', 80, 'VIP', 1500.00, 1, 'Dr. Aquino'),
(106, 'SESS-D2', '2025-04-22', 4, 'Digital Health Alliance', 'care@digitalhealth.ph', 'Telemedicine Implementation', 'V-PARK', 'Greenfield Innovation Center', 'Pasig', 80, 'Standard', 600.00, 6, 'Dr. Aquino, Engr. Tan');
