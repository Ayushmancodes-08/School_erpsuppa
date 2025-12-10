-- ============================================
-- COMPLETE SUPABASE DATABASE SETUP
-- Run this entire script in Supabase SQL Editor
-- ============================================

-- ============================================
-- STEP 1: CREATE ALL TABLES
-- ============================================

-- Students Table
CREATE TABLE IF NOT EXISTS students (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  class TEXT NOT NULL,
  section TEXT NOT NULL,
  roll_number TEXT NOT NULL,
  avatar TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_students_class ON students(class);

-- Teachers Table
CREATE TABLE IF NOT EXISTS teachers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  subject TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Fees Table
CREATE TABLE IF NOT EXISTS fees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL,
  student_name TEXT NOT NULL,
  class TEXT NOT NULL,
  amount NUMERIC(10, 2) NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('Paid', 'Due', 'Overdue')),
  due_date DATE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_fees_student_id ON fees(student_id);
CREATE INDEX IF NOT EXISTS idx_fees_status ON fees(status);

-- Hostel Fees Table
CREATE TABLE IF NOT EXISTS hostel_fees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL,
  student_name TEXT NOT NULL,
  room_number TEXT NOT NULL,
  amount NUMERIC(10, 2) NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('Paid', 'Due', 'Overdue')),
  due_date DATE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_hostel_fees_student_id ON hostel_fees(student_id);

-- Student Attendance Table
CREATE TABLE IF NOT EXISTS student_attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL,
  records JSONB NOT NULL DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_student_attendance_student_id ON student_attendance(student_id);

-- Hostels Table
CREATE TABLE IF NOT EXISTS hostels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('Boys', 'Girls')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Hostel Rooms Table
CREATE TABLE IF NOT EXISTS hostel_rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  hostel_id UUID NOT NULL,
  hostel_name TEXT NOT NULL,
  room_number TEXT NOT NULL,
  capacity INTEGER NOT NULL,
  occupants TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_hostel_rooms_hostel_id ON hostel_rooms(hostel_id);

-- Homeworks Table
CREATE TABLE IF NOT EXISTS homeworks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class TEXT NOT NULL,
  section TEXT NOT NULL,
  subject TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  due_date DATE NOT NULL,
  assigned_by TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_homeworks_class_section ON homeworks(class, section);

-- Admissions Table
CREATE TABLE IF NOT EXISTS admissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  month TEXT NOT NULL,
  admitted INTEGER NOT NULL,
  capacity INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Admission Applications Table
CREATE TABLE IF NOT EXISTS admission_applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_name TEXT NOT NULL,
  applying_for_grade TEXT NOT NULL,
  parent_name TEXT NOT NULL,
  parent_email TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('Pending', 'Approved', 'Rejected')),
  date DATE NOT NULL,
  gender TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_admission_applications_status ON admission_applications(status);

-- Job Applications Table
CREATE TABLE IF NOT EXISTS job_applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT NOT NULL,
  subject TEXT NOT NULL,
  experience INTEGER NOT NULL,
  resume TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('Pending', 'Accepted', 'Rejected')),
  date DATE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_job_applications_status ON job_applications(status);

-- Users Table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('Admin', 'Teacher', 'Student', 'Finance')),
  student_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_user_id ON users(user_id);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- Notices Table
CREATE TABLE IF NOT EXISTS notices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  author TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('Admin', 'Teacher')),
  date DATE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notices_date ON notices(date DESC);

-- ============================================
-- STEP 2: ENABLE ROW LEVEL SECURITY
-- ============================================

ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE fees ENABLE ROW LEVEL SECURITY;
ALTER TABLE hostel_fees ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE hostels ENABLE ROW LEVEL SECURITY;
ALTER TABLE hostel_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE homeworks ENABLE ROW LEVEL SECURITY;
ALTER TABLE admissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE admission_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE notices ENABLE ROW LEVEL SECURITY;

-- ============================================
-- STEP 3: CREATE RLS POLICIES (PUBLIC ACCESS)
-- ============================================
-- Note: Using public access for simplicity since we have custom auth

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow public access" ON students;
DROP POLICY IF EXISTS "Allow public access" ON teachers;
DROP POLICY IF EXISTS "Allow public access" ON fees;
DROP POLICY IF EXISTS "Allow public access" ON hostel_fees;
DROP POLICY IF EXISTS "Allow public access" ON student_attendance;
DROP POLICY IF EXISTS "Allow public access" ON hostels;
DROP POLICY IF EXISTS "Allow public access" ON hostel_rooms;
DROP POLICY IF EXISTS "Allow public access" ON homeworks;
DROP POLICY IF EXISTS "Allow public access" ON admissions;
DROP POLICY IF EXISTS "Allow public access" ON admission_applications;
DROP POLICY IF EXISTS "Allow public access" ON job_applications;
DROP POLICY IF EXISTS "Allow public access" ON users;
DROP POLICY IF EXISTS "Allow public access" ON notices;

-- Create public access policies for all tables
CREATE POLICY "Allow public access" ON students FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow public access" ON teachers FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow public access" ON fees FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow public access" ON hostel_fees FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow public access" ON student_attendance FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow public access" ON hostels FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow public access" ON hostel_rooms FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow public access" ON homeworks FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow public access" ON admissions FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow public access" ON admission_applications FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow public access" ON job_applications FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow public access" ON users FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow public access" ON notices FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- ============================================
-- STEP 4: ENABLE REALTIME
-- ============================================

-- Add tables to realtime publication
ALTER PUBLICATION supabase_realtime ADD TABLE students;
ALTER PUBLICATION supabase_realtime ADD TABLE teachers;
ALTER PUBLICATION supabase_realtime ADD TABLE fees;
ALTER PUBLICATION supabase_realtime ADD TABLE hostel_fees;
ALTER PUBLICATION supabase_realtime ADD TABLE student_attendance;
ALTER PUBLICATION supabase_realtime ADD TABLE hostels;
ALTER PUBLICATION supabase_realtime ADD TABLE hostel_rooms;
ALTER PUBLICATION supabase_realtime ADD TABLE homeworks;
ALTER PUBLICATION supabase_realtime ADD TABLE admissions;
ALTER PUBLICATION supabase_realtime ADD TABLE admission_applications;
ALTER PUBLICATION supabase_realtime ADD TABLE job_applications;
ALTER PUBLICATION supabase_realtime ADD TABLE users;
ALTER PUBLICATION supabase_realtime ADD TABLE notices;

-- ============================================
-- STEP 5: CREATE DEFAULT USERS
-- ============================================

-- Insert default admin user (if not exists)
INSERT INTO users (user_id, password, role)
SELECT 'admin', 'password', 'Admin'
WHERE NOT EXISTS (
    SELECT 1 FROM users WHERE user_id = 'admin' AND role = 'Admin'
);

-- Insert default finance user (if not exists)
INSERT INTO users (user_id, password, role)
SELECT 'finance', 'password', 'Finance'
WHERE NOT EXISTS (
    SELECT 1 FROM users WHERE user_id = 'finance' AND role = 'Finance'
);

-- ============================================
-- DONE! Your database is ready!
-- ============================================
-- Default Login Credentials:
-- Admin:   admin / password
-- Finance: finance / password
-- 
-- Teacher credentials: Generated by Admin
-- Student credentials: Generated by Teacher
-- Students: Auto-generated when approved (format: STU-FIRSTNAME##)
-- ============================================
