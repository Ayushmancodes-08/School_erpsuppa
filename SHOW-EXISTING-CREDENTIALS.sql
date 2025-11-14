-- ============================================
-- SHOW ALL EXISTING CREDENTIALS
-- Run this in Supabase SQL Editor
-- ============================================

-- Show all users with their credentials
SELECT 
  user_id,
  password,
  role,
  student_id,
  created_at
FROM users
ORDER BY role, created_at;

-- Show teacher credentials specifically
SELECT 
  user_id as "User ID",
  password as "Password",
  role as "Role",
  created_at as "Created At"
FROM users
WHERE role = 'Teacher'
ORDER BY created_at DESC;

-- Show student credentials specifically
SELECT 
  u.user_id as "User ID",
  u.password as "Password",
  s.name as "Student Name",
  s.class || s.section as "Class",
  u.created_at as "Created At"
FROM users u
LEFT JOIN students s ON u.student_id = s.id
WHERE u.role = 'Student'
ORDER BY u.created_at DESC;

-- ============================================
-- RESULT: You'll see all existing credentials
-- Use these to login!
-- ============================================
