-- ============================================
-- ADD FOREIGN KEY CONSTRAINTS
-- Run this AFTER creating all tables
-- This ensures data integrity across tables
-- ============================================

-- Add foreign key from fees to students
ALTER TABLE fees 
ADD CONSTRAINT fk_fees_student 
FOREIGN KEY (student_id) 
REFERENCES students(id) 
ON DELETE CASCADE;

-- Add foreign key from hostel_fees to students
ALTER TABLE hostel_fees 
ADD CONSTRAINT fk_hostel_fees_student 
FOREIGN KEY (student_id) 
REFERENCES students(id) 
ON DELETE CASCADE;

-- Add foreign key from student_attendance to students
ALTER TABLE student_attendance 
ADD CONSTRAINT fk_attendance_student 
FOREIGN KEY (student_id) 
REFERENCES students(id) 
ON DELETE CASCADE;

-- Add foreign key from hostel_rooms to hostels
ALTER TABLE hostel_rooms 
ADD CONSTRAINT fk_hostel_rooms_hostel 
FOREIGN KEY (hostel_id) 
REFERENCES hostels(id) 
ON DELETE CASCADE;

-- Add foreign key from users to students (for student users)
ALTER TABLE users 
ADD CONSTRAINT fk_users_student 
FOREIGN KEY (student_id) 
REFERENCES students(id) 
ON DELETE SET NULL;

-- ============================================
-- VERIFICATION: Check all foreign keys
-- ============================================

SELECT
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
  AND tc.table_schema='public'
ORDER BY tc.table_name;
