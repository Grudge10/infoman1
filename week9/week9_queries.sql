-- Task 1
SELECT s.student_name, s.program, o.order_id, o.order_date
FROM students s INNER JOIN orders o ON s.student_id = o.student_id
ORDER BY o.order_id;

-- Task 2a
SELECT s.student_name, s.program, o.order_id, o.order_date
FROM students s LEFT JOIN orders o ON s.student_id = o.student_id
ORDER BY s.student_id;

-- Task 2b
SELECT s.student_name, s.program, o.order_id, o.order_date
FROM students s LEFT JOIN orders o ON s.student_id = o.student_id
WHERE o.order_id IS NULL
ORDER BY s.student_id;

-- Task 3
SELECT s.student_name, s.program, o.order_id, m.item_name, oi.quantity, m.price, (oi.quantity * m.price) AS line_total
FROM students s
INNER JOIN orders o ON s.student_id = o.student_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN menu_items m ON oi.menu_id = m.menu_id
ORDER BY o.order_id, m.item_name;

-- Task 4 Version A (INNER JOIN)
SELECT s.student_name AS buyer, m.item_name AS item, (oi.quantity * m.price) AS line_total
FROM students s
INNER JOIN orders o ON s.student_id = o.student_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN menu_items m ON oi.menu_id = m.menu_id
WHERE o.order_date >= '2026-08-01'
ORDER BY o.order_date DESC, m.item_name;

-- Task 4 Version B (LEFT JOIN with WHERE - the broken one)
SELECT s.student_name AS buyer, m.item_name AS item, (oi.quantity * m.price) AS line_total
FROM students s
LEFT JOIN orders o ON s.student_id = o.student_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN menu_items m ON oi.menu_id = m.menu_id
WHERE o.order_date >= '2026-08-01'
ORDER BY o.order_date DESC, m.item_name;