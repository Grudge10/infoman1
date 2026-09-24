# Task 2: Relational Schema

member(<u>member_id</u>, member_name, phone, join_date)

storage_location(<u>location_code</u>, description)

tool(<u>tool_id</u>, tool_name, category, purchase_date, location_code* [FK -> storage_location])

certification(<u>cert_id</u>, cert_name)

tool_requirement(<u>tool_id*</u> [FK -> tool], <u>cert_id*</u> [FK -> certification])

member_certification(<u>member_id*</u> [FK -> member], <u>cert_id*</u> [FK -> certification], completion_date)

borrowing(<u>borrow_id</u>, member_id* [FK -> member], tool_id* [FK -> tool], borrow_date, return_date)
