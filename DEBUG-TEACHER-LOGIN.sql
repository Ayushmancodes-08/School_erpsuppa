-- ============================================
-- DEBUG TEACHER LOGIN ISSUE
-- Run these queries in Supabase SQL Editor
-- ============================================

-- Step 1: Check all users in database
SELECT user_id, password, role, created_at 
FROM users 
ORDER BY created_at DESC;

-- Step 2: Check specifically for teacher users
SELECT user_id, password, role, created_at 
FROM users 
WHERE role = 'Teacher';

-- Step 3: Check if any teacher credentials were generated
SELECT 
  user_id,
  length(user_id) as user_id_length,
  password,
  length(password) as password_length,
  role
FROM users 
WHERE user_id LIKE 'TCH-%';

-- Step 4: Check teachers table (to see who can have credentials generated)
SELECT id, name, subject, created_at 
FROM teachers;

-- ============================================
-- WHAT TO LOOK FOR:
-- ============================================
-- 1. Do you see any users with role = 'Teacher'?
-- 2. Do you see any user_id starting with 'TCH-'?
-- 3. Are there teachers in the teachers table?
-- 4. Does the generated user_id match what you're trying to login with?
-- ============================================
