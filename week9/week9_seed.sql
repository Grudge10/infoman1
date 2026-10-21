CREATE DATABASE IF NOT EXISTS infoman1_canteen;
USE infoman1_canteen;

CREATE TABLE students (
  student_id INT PRIMARY KEY,
  student_name VARCHAR(100) NOT NULL,
  program VARCHAR(20) NOT NULL
);
CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  student_id INT NOT NULL,
  order_date DATE NOT NULL,
  FOREIGN KEY (student_id) REFERENCES students(student_id)
);
CREATE TABLE menu_items (
  menu_id INT PRIMARY KEY,
  item_name VARCHAR(100) NOT NULL,
  price DECIMAL(8,2) NOT NULL
);
CREATE TABLE order_items (
  order_id INT NOT NULL,
  menu_id INT NOT NULL,
  quantity INT NOT NULL,
  PRIMARY KEY (order_id, menu_id),
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (menu_id) REFERENCES menu_items(menu_id)
);

INSERT INTO students VALUES
  (1, 'Ana Cruz', 'BSIT'),
  (2, 'Ben Lim', 'BSCS'),
  (3, 'Cara Yu', 'BSIS'),
  (4, 'Dan Reyes', 'BSIT');
INSERT INTO orders VALUES
  (101, 1, '2026-08-10'),
  (102, 1, '2026-08-15'),
  (103, 4, '2026-08-16');
INSERT INTO menu_items VALUES
  (1, 'Siomai Rice', 65.00),
  (2, 'Burger Steak', 89.00),
  (3, 'Iced Tea', 30.00);
INSERT INTO order_items VALUES
  (101, 1, 2),
  (101, 3, 1),
  (102, 2, 1),
  (103, 1, 1);