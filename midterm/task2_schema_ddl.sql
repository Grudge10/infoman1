USE eventhub_midterm;

DROP TABLE IF EXISTS session_speakers;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS speakers;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS organizers;
DROP TABLE IF EXISTS venues;

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

SHOW TABLES;
DESCRIBE venues;
DESCRIBE organizers;
DESCRIBE events;
DESCRIBE bookings;
DESCRIBE speakers;
DESCRIBE session_speakers;
