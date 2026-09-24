CREATE DATABASE IF NOT EXISTS toolshare_prelim;
USE toolshare_prelim;

SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS storage_location (
    location_code VARCHAR(10) PRIMARY KEY,
    description VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS member (
    member_id INT PRIMARY KEY,
    member_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    join_date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS tool (
    tool_id INT PRIMARY KEY,
    tool_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    purchase_date DATE NOT NULL,
    location_code VARCHAR(10) NOT NULL,
    FOREIGN KEY (location_code) REFERENCES storage_location (location_code)
);

CREATE TABLE IF NOT EXISTS certification (
    cert_id INT PRIMARY KEY,
    cert_name VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS tool_requirement (
    tool_id INT NOT NULL,
    cert_id INT NOT NULL,
    PRIMARY KEY (tool_id, cert_id),
    FOREIGN KEY (tool_id) REFERENCES tool (tool_id),
    FOREIGN KEY (cert_id) REFERENCES certification (cert_id)
);

CREATE TABLE IF NOT EXISTS member_certification (
    member_id INT NOT NULL,
    cert_id INT NOT NULL,
    completion_date DATE NOT NULL,
    PRIMARY KEY (member_id, cert_id),
    FOREIGN KEY (member_id) REFERENCES member (member_id),
    FOREIGN KEY (cert_id) REFERENCES certification (cert_id)
);

CREATE TABLE IF NOT EXISTS borrowing (
    borrow_id INT PRIMARY KEY,
    member_id INT NOT NULL,
    tool_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    return_date DATE NULL,
    FOREIGN KEY (member_id) REFERENCES member (member_id),
    FOREIGN KEY (tool_id) REFERENCES tool (tool_id)
);

SET FOREIGN_KEY_CHECKS = 1;

-- Clear previous runs in child-first order (re-runnable script)
DELETE FROM borrowing;
DELETE FROM member_certification;
DELETE FROM tool_requirement;
DELETE FROM tool;
DELETE FROM certification;
DELETE FROM member;
DELETE FROM storage_location;

-- 3 storage locations
INSERT INTO storage_location (location_code, description) VALUES
('A3', 'Shelf A3 - Power Tools'),
('B1', 'Pegboard B1 - Garden Tools'),
('C2', 'Cabinet C2 - General');

-- 6 members (4 joined after 2025-01-01; member 1 is Maria Santos)
INSERT INTO member (member_id, member_name, phone, join_date) VALUES
(1, 'Maria Santos', '09171234567', '2024-03-15'),
(2, 'Jose Rizal',   '09179876543', '2025-02-10'),
(3, 'Ana Reyes',    '09172223333', '2025-06-01'),
(4, 'Mark Cruz',    '09174445555', '2023-11-20'),
(5, 'Liza Gomez',   '09175556666', '2025-01-15'),
(6, 'Kevin Lim',    '09176667777', '2025-08-05');

-- 8 tools (3 x 'Power Tools'; 3 purchased before 2024-01-01)
INSERT INTO tool (tool_id, tool_name, category, purchase_date, location_code) VALUES
(1, 'Cordless Drill',   'Power Tools', '2023-05-10', 'A3'),
(2, 'Circular Saw',     'Power Tools', '2023-08-22', 'A3'),
(3, 'Angle Grinder',    'Power Tools', '2024-06-15', 'A3'),
(4, 'Garden Shovel',    'Garden',      '2023-12-01', 'B1'),
(5, 'Hedge Trimmer',    'Garden',      '2024-03-20', 'B1'),
(6, 'Hammer Set',       'Hand Tools',  '2024-09-10', 'C2'),
(7, 'Welding Machine',  'Metalwork',   '2024-02-11', 'C2'),
(8, 'Lawn Mower',       'Garden',      '2024-11-05', 'B1');

-- 4 certifications
INSERT INTO certification (cert_id, cert_name) VALUES
(1, 'Chainsaw Safety'),
(2, 'Welding Basics'),
(3, 'Power Tool Handling'),
(4, 'Garden Equipment Use');

-- Tool -> certification requirements (M:N)
INSERT INTO tool_requirement (tool_id, cert_id) VALUES
(2, 3),
(3, 3),
(7, 2),
(8, 4);

-- Member -> certification completions with dates (M:N + attribute)
INSERT INTO member_certification (member_id, cert_id, completion_date) VALUES
(1, 3, '2024-04-01'),
(2, 2, '2025-03-01'),
(3, 4, '2025-06-15'),
(5, 3, '2025-02-01');

-- 6 borrowing records (2 currently on loan: borrow_id 2, 3)
INSERT INTO borrowing (borrow_id, member_id, tool_id, borrow_date, return_date) VALUES
(1, 1, 1, '2025-09-01', '2025-09-10'),
(2, 1, 2, '2025-09-12', NULL),
(3, 2, 7, '2025-09-05', NULL),
(4, 3, 4, '2025-08-20', '2025-08-28'),
(5, 4, 6, '2025-07-10', '2025-07-15'),
(6, 5, 3, '2025-09-08', '2025-09-14');