-- ============================================
-- VERIFICATION SCRIPT
-- Run this to check if everything is set up correctly
-- ============================================

-- 1. Check if all tables exist
SELECT 
    'Tables Created' as check_type,
    COUNT(*) as count,
    CASE 
        WHEN COUNT(*) = 13 THEN '✅ All 13 tables exist'
        ELSE '❌ Missing tables! Expected 13, found ' || COUNT(*)
    END as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE';

-- 2. List all tables
SELECT 
    'Table List' as info,
    table_name
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- 3. Check if RLS is enabled
SELECT 
    'RLS Status' as check_type,
    COUNT(*) as tables_with_rls,
    CASE 
        WHEN COUNT(*) = 13 THEN '✅ RLS enabled on all tables'
        ELSE '❌ RLS not enabled on all tables'
    END as status
FROM pg_tables 
WHERE schemaname = 'public' 
  AND rowsecurity = true;

-- 4. Check if policies exist
SELECT 
    'Policies' as check_type,
    COUNT(*) as policy_count,
    CASE 
        WHEN COUNT(*) >= 13 THEN '✅ Policies created'
        ELSE '⚠️ Some policies missing'
    END as status
FROM pg_policies 
WHERE schemaname = 'public';

-- 5. Check users table specifically
SELECT 
    'Users Table' as check_type,
    COUNT(*) as user_count,
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ Users exist: ' || COUNT(*)
        ELSE '⚠️ No users yet (will be auto-created by app)'
    END as status
FROM users;

-- 6. List existing users (if any)
SELECT 
    'Existing Users' as info,
    user_id,
    role
FROM users
ORDER BY role;
