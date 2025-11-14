# Implementation Plan

- [x] 1. Setup Supabase project and install dependencies


  - Create new Supabase project at https://app.supabase.com
  - Install @supabase/supabase-js package using: npm install @supabase/supabase-js
  - Uninstall firebase package using: npm uninstall firebase
  - Get Supabase URL and anon key from project Settings → API
  - _Requirements: 1.1, 1.5, 2.2, 9.1, 9.2_

- [ ] 2. Create PostgreSQL database schema in Supabase
  - [ ] 2.1 Create core tables (students, teachers, users)
    - Write SQL to create students table with id, name, class, section, roll_number, avatar columns
    - Write SQL to create teachers table with id, name, subject columns
    - Write SQL to create users table with id, user_id, password, role, student_id columns
    - Add indexes on students.class, users.user_id, users.role
    - _Requirements: 3.1, 3.2, 3.12, 3.14, 3.15_

  - [ ] 2.2 Create fee-related tables
    - Write SQL to create fees table with id, student_id, student_name, class, amount, status, due_date columns
    - Write SQL to create hostel_fees table with id, student_id, student_name, room_number, amount, status, due_date columns
    - Add foreign key constraints referencing students table
    - Add indexes on student_id and status columns
    - _Requirements: 3.3, 3.4, 3.15_

  - [ ] 2.3 Create hostel management tables
    - Write SQL to create hostels table with id, name, type columns
    - Write SQL to create hostel_rooms table with id, hostel_id, hostel_name, room_number, capacity, occupants columns
    - Add foreign key constraint from hostel_rooms to hostels
    - Add index on hostel_rooms.hostel_id
    - _Requirements: 3.6, 3.7, 3.15_


  - [ ] 2.4 Create academic tables
    - Write SQL to create student_attendance table with id, student_id, records (JSONB) columns
    - Write SQL to create homeworks table with id, class, section, subject, title, description, due_date, assigned_by columns
    - Add foreign key constraint from student_attendance to students
    - Add indexes on student_attendance.student_id and homeworks(class, section)
    - _Requirements: 3.5, 3.8, 3.15_

  - [ ] 2.5 Create admission and application tables
    - Write SQL to create admissions table with id, month, admitted, capacity columns
    - Write SQL to create admission_applications table with id, student_name, applying_for_grade, parent_name, parent_email, status, date, gender columns
    - Write SQL to create job_applications table with id, full_name, email, phone, subject, experience, resume, status, date columns
    - Add indexes on admission_applications.status and job_applications.status
    - _Requirements: 3.9, 3.10, 3.11, 3.15_

  - [ ] 2.6 Create notices table and enable realtime
    - Write SQL to create notices table with id, title, content, author, role, date columns
    - Add index on notices.date (descending order)
    - Enable Realtime for all tables using ALTER PUBLICATION supabase_realtime ADD TABLE
    - _Requirements: 3.13, 3.15_

- [ ] 3. Configure Row Level Security policies
  - [ ] 3.1 Enable RLS and create base policies
    - Enable RLS on all 13 tables using ALTER TABLE ... ENABLE ROW LEVEL SECURITY
    - Create public read policies for all tables to support unauthenticated access (login page)
    - Create authenticated full access policies for all tables except users
    - _Requirements: 4.1, 4.2, 4.3, 4.5_

  - [ ] 3.2 Create special policies for users table
    - Create public read policy for users table (login validation)
    - Create restricted update policy for users table (users can only update own record)
    - _Requirements: 4.4_




- [ ] 4. Create Supabase configuration and initialization modules
  - Create src/supabase/config.ts with hardcoded supabaseConfig object (url and anonKey)
  - Add comment in config.ts explaining where to get credentials from Supabase dashboard
  - Create src/supabase/index.ts with initializeSupabase function and client singleton


  - Export all hooks and providers from src/supabase/index.ts
  - _Requirements: 2.1, 2.2, 9.1, 9.2, 9.3, 9.4_

- [x] 5. Implement Supabase provider and context hooks


  - Create src/supabase/provider.tsx with SupabaseProvider component and SupabaseContext
  - Implement useSupabase hook returning Supabase client from context
  - Create src/supabase/client-provider.tsx that initializes Supabase on mount
  - _Requirements: 2.3, 2.4_



- [ ] 6. Implement error handling infrastructure
  - Create src/supabase/errors.ts with SupabasePermissionError class
  - Create src/supabase/error-emitter.ts with ErrorEmitter class
  - Export errorEmitter singleton for use in hooks
  - _Requirements: 5.7, 11.1, 11.2, 11.3, 11.4, 11.5_

- [x] 7. Implement useCollection hook with real-time subscriptions


  - Create src/supabase/hooks/use-collection.tsx
  - Implement initial data fetch using supabase.from(table).select('*')
  - Implement query filtering support using .eq(), .gt(), etc. based on options
  - Implement real-time subscription using supabase.channel().on('postgres_changes')
  - Handle INSERT, UPDATE, DELETE events to update local state
  - Return data array and loading state matching Firebase hook interface
  - Add error handling and emit permission errors
  - _Requirements: 5.1, 5.4, 5.6, 5.7_



- [ ] 8. Implement useDoc hook with update and set methods
  - Create src/supabase/hooks/use-doc.tsx
  - Implement initial data fetch using supabase.from(table).select('*').eq('id', id).single()
  - Implement real-time subscription for single row updates
  - Implement update method using supabase.from(table).update(data).eq('id', id)


  - Implement set method using supabase.from(table).upsert(data)
  - Return data, loading, update, and set matching Firebase hook interface
  - Add error handling and emit permission errors
  - _Requirements: 5.2, 5.5, 5.7_




- [ ] 9. Implement useUser hook for authentication state
  - Create src/supabase/hooks/use-user.tsx
  - Read authenticated state from sessionStorage on mount
  - Return user object and loading state


  - Maintain compatibility with existing login flow
  - _Requirements: 5.3, 8.3, 8.4_

- [ ] 10. Update DataContext to use Supabase
  - Replace useFirestore import with useSupabase in src/lib/data-context.tsx
  - Update all useCollection calls to use Supabase hooks
  - Update seedInitialUsers function to use supabase.from('users').select() and .insert()
  - Remove Firebase imports (collection, addDoc, getDocs, query, where, Firestore)


  - Maintain the same DataContext interface and exports
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 11. Replace Firebase providers in application layout


  - Update src/app/layout.tsx to import SupabaseClientProvider instead of FirebaseClientProvider
  - Replace <FirebaseClientProvider> with <SupabaseClientProvider> in JSX
  - Remove Firebase import statements
  - _Requirements: 1.3, 1.4, 2.4_



- [ ] 12. Update AdmissionRequests component with Supabase operations
  - Replace useFirestore with useSupabase in src/components/erp/AdmissionRequests.tsx
  - Replace addDoc(collection(firestore, "students")) with supabase.from('students').insert()
  - Replace addDoc(collection(firestore, "fees")) with supabase.from('fees').insert()
  - Replace updateDoc(doc(firestore, "admissionApplications", id)) with supabase.from('admission_applications').update().eq('id', id)


  - Remove Firebase imports (addDoc, collection, doc, updateDoc)
  - Handle camelCase to snake_case conversion for table names
  - _Requirements: 7.1, 7.2, 7.6, 1.4_




- [ ] 13. Update NoticeBoard component with Supabase operations
  - Replace useFirestore with useSupabase in src/components/erp/NoticeBoard.tsx
  - Replace addDoc(collection(firestore, "notices")) with supabase.from('notices').insert()
  - Remove Firebase imports (addDoc, collection)
  - _Requirements: 7.1, 7.7, 1.4_

- [ ] 14. Update HostelAllocationDialog component with Supabase operations
  - Locate and update src/components/erp/HostelAllocationDialog.tsx
  - Replace all Firestore operations with Supabase equivalents
  - Update hostel_rooms table operations to use supabase.from('hostel_rooms')
  - Remove Firebase imports
  - _Requirements: 7.8, 1.4_

- [ ] 15. Search and update any remaining components with Firestore operations
  - Search codebase for remaining Firebase/Firestore imports
  - Update any components in src/components/erp/ with direct database operations
  - Replace all collection(), addDoc(), updateDoc(), deleteDoc() calls with Supabase equivalents
  - Ensure all table names use snake_case (e.g., admission_applications, hostel_fees)
  - _Requirements: 7.9, 1.4_

- [ ] 16. Remove Firebase directory and configuration files
  - Delete src/firebase directory and all its contents
  - Delete .firebaserc file
  - Delete firestore.rules file
  - Delete apphosting.yaml file
  - _Requirements: 1.2, 1.3_

- [ ] 17. Create SupabaseErrorListener component
  - Create src/components/SupabaseErrorListener.tsx to replace FirebaseErrorListener
  - Subscribe to error-emitter events and display toast notifications
  - Update imports in SupabaseProvider to use new error listener
  - Delete src/components/FirebaseErrorListener.tsx
  - _Requirements: 11.2, 11.3_


- [ ] 18. Verify and test core functionality
  - [ ] 18.1 Test data loading and authentication
    - Start the development server and navigate to login page
    - Verify users collection loads without errors
    - Test login with Admin credentials (userId: 'admin', password: 'password')
    - Verify successful login redirects to dashboard
    - Check browser console for any Firebase-related errors
    - _Requirements: 10.1, 10.2_

  - [ ] 18.2 Test admission request workflow
    - Navigate to Admin dashboard
    - Verify pending admission applications display
    - Approve an admission application
    - Verify new student record is created in students table
    - Verify new fee record is created in fees table
    - Verify application status updates to 'Approved'
    - _Requirements: 10.3_

  - [ ] 18.3 Test notice board functionality
    - Post a new notice as Admin or Teacher
    - Verify notice appears in the notice board
    - Check that notice persists after page refresh
    - Verify real-time update if viewing in multiple tabs
    - _Requirements: 10.4_

  - [ ] 18.4 Test hostel allocation
    - Navigate to hostel management section
    - Allocate a student to a hostel room
    - Verify hostel_rooms table updates with new occupant
    - Verify occupancy count updates correctly
    - _Requirements: 10.5_

  - [ ] 18.5 Test real-time subscriptions
    - Open application in two browser tabs
    - Make a data change in one tab (e.g., post a notice)
    - Verify the change appears in the second tab without refresh
    - Test with multiple data types (students, fees, notices)
    - _Requirements: 10.6_





  - [ ] 18.6 Test all dashboard views
    - Login as Admin and verify all KPIs and charts display
    - Login as Teacher and verify teacher dashboard loads
    - Login as Student and verify student dashboard with fees and attendance
    - Login as Finance and verify finance dashboard with fee management
    - _Requirements: 10.7_

  - [ ] 18.7 Test fee payment flow
    - Navigate to student fee payment page
    - Verify fee details display correctly
    - Click "Pay Now" and complete payment form
    - Verify fee status updates in database
    - _Requirements: 10.8_

  - [ ] 18.8 Test attendance logging
    - Navigate to attendance management
    - Log attendance for students
    - Verify attendance records persist to student_attendance table
    - Verify attendance displays correctly in student view
    - _Requirements: 10.9_

  - [ ] 18.9 Final codebase verification
    - Search entire codebase for 'firebase' string
    - Search for 'firestore' string
    - Verify no Firebase imports remain
    - Verify firebase package is removed from package.json
    - Check that all Firebase config files are deleted
    - _Requirements: 10.10_

- [ ] 19. Create migration documentation
  - Create MIGRATION.md file documenting the migration process
  - Document Supabase project setup steps
  - Document database schema with table relationships
  - Document environment variable configuration
  - Document any breaking changes or API differences
  - Include troubleshooting section for common issues
  - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_

