-- Fix Users Table - Run this in Supabase SQL Editor

-- First, check what users exist
SELECT * FROM users;

-- Delete all existing users (to start fresh)
DELETE FROM users;

-- Insert default users with correct credentials
INSERT INTO users (user_id, password, role) VALUES
('admin', 'password', 'Admin'),
('finance', 'password', 'Finance'),
('teacher', 'password', 'Teacher');

-- Verify users were created
SELECT user_id, password, role FROM users;

-- Expected output:
-- user_id  | password | role
-- admin    | password | Admin
-- finance  | password | Finance
-- teacher  | password | Teacher
