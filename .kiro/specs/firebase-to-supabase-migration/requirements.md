# Requirements Document

## Introduction

This document outlines the requirements for migrating the School ERP system from Firebase Firestore to Supabase. The School ERP is a Next.js application that manages students, teachers, fees, hostel management, admissions, attendance, homework, job applications, and notices. The migration must maintain all existing functionality while replacing Firebase Authentication and Firestore with Supabase Auth and PostgreSQL database.

## Glossary

- **School ERP System**: The web application that manages educational institution operations
- **Firebase Firestore**: The current NoSQL cloud database service being replaced
- **Supabase**: The open-source Firebase alternative with PostgreSQL database
- **Supabase Client**: The JavaScript client library for interacting with Supabase services
- **Real-time Subscriptions**: Live data synchronization feature in both Firebase and Supabase
- **Row Level Security (RLS)**: PostgreSQL security feature that controls data access at row level
- **Authentication Provider**: The service managing user identity and access (Firebase Auth → Supabase Auth)
- **Data Context**: React context providing centralized data access across the application
- **Custom Hooks**: React hooks (useCollection, useDoc, useUser) that abstract data operations

## Requirements

### Requirement 1

**User Story:** As a system administrator, I want all Firebase dependencies removed from the project, so that the application no longer relies on Firebase services

#### Acceptance Criteria

1. THE School ERP System SHALL remove all Firebase npm packages from package.json
2. THE School ERP System SHALL delete all Firebase configuration files including .firebaserc, firestore.rules, and apphosting.yaml
3. THE School ERP System SHALL remove the firebase directory and all Firebase-specific code modules
4. THE School ERP System SHALL remove Firebase imports from all application components
5. THE School ERP System SHALL install Supabase client library as the replacement database client


### Requirement 2

**User Story:** As a developer, I want Supabase properly configured and initialized, so that the application can connect to the Supabase backend

#### Acceptance Criteria

1. THE School ERP System SHALL create a Supabase configuration file with project URL and anon key
2. THE School ERP System SHALL initialize the Supabase client on application startup
3. THE School ERP System SHALL provide Supabase client access through React context providers
4. THE School ERP System SHALL replace FirebaseClientProvider with SupabaseClientProvider
5. THE School ERP System SHALL expose useSupabase hook for accessing the Supabase client instance

### Requirement 3

**User Story:** As a developer, I want the PostgreSQL database schema created in Supabase, so that all application data can be stored in relational tables

#### Acceptance Criteria

1. THE School ERP System SHALL create a students table with columns for id, name, class, section, rollNumber, and avatar
2. THE School ERP System SHALL create a teachers table with columns for id, name, and subject
3. THE School ERP System SHALL create a fees table with columns for id, studentId, studentName, class, amount, status, and dueDate
4. THE School ERP System SHALL create a hostelFees table with columns for id, studentId, studentName, roomNumber, amount, status, and dueDate
5. THE School ERP System SHALL create a studentAttendance table with columns for id, studentId, and records (JSONB type)
6. THE School ERP System SHALL create a hostels table with columns for id, name, and type
7. THE School ERP System SHALL create a hostelRooms table with columns for id, hostelId, hostelName, roomNumber, capacity, and occupants (array type)
8. THE School ERP System SHALL create a homeworks table with columns for id, class, section, subject, title, description, dueDate, and assignedBy
9. THE School ERP System SHALL create an admissions table with columns for id, month, admitted, and capacity
10. THE School ERP System SHALL create an admissionApplications table with columns for id, studentName, applyingForGrade, parentName, parentEmail, status, date, and gender
11. THE School ERP System SHALL create a jobApplications table with columns for id, fullName, email, phone, subject, experience, resume, status, and date
12. THE School ERP System SHALL create a users table with columns for id, userId, password, role, and studentId
13. THE School ERP System SHALL create a notices table with columns for id, title, content, author, role, and date
14. THE School ERP System SHALL use UUID as the primary key type for all tables
15. THE School ERP System SHALL add appropriate indexes on foreign key columns for query performance


### Requirement 4

**User Story:** As a developer, I want Row Level Security policies configured, so that data access is properly controlled based on user authentication

#### Acceptance Criteria

1. THE School ERP System SHALL enable Row Level Security on all database tables
2. THE School ERP System SHALL create RLS policies allowing authenticated users to read all records
3. THE School ERP System SHALL create RLS policies allowing authenticated users to insert, update, and delete records
4. THE School ERP System SHALL create RLS policies for the users table restricting access to the user's own record
5. THE School ERP System SHALL configure public read access for unauthenticated users to support the login page data loading

### Requirement 5

**User Story:** As a developer, I want custom React hooks that replicate Firebase functionality, so that data fetching patterns remain consistent

#### Acceptance Criteria

1. THE School ERP System SHALL create a useCollection hook that fetches data from Supabase tables with real-time subscriptions
2. THE School ERP System SHALL create a useDoc hook that fetches a single document from Supabase with real-time updates
3. THE School ERP System SHALL create a useUser hook that manages authentication state
4. THE School ERP System SHALL ensure useCollection returns data in the same format as the Firebase version
5. THE School ERP System SHALL ensure useDoc returns data, loading state, and update/set methods
6. THE School ERP System SHALL implement real-time subscriptions using Supabase channels for live data updates
7. THE School ERP System SHALL handle errors gracefully and emit error events when operations fail

### Requirement 6

**User Story:** As a developer, I want the DataContext updated to use Supabase, so that all components receive data from the new backend

#### Acceptance Criteria

1. THE School ERP System SHALL update DataContext to use Supabase client instead of Firestore
2. THE School ERP System SHALL update the seedInitialUsers function to use Supabase insert operations
3. THE School ERP System SHALL maintain the same data structure and interface for all collections
4. THE School ERP System SHALL ensure all useCollection hooks in DataContext point to Supabase tables
5. THE School ERP System SHALL preserve the existing context API so components require no changes


### Requirement 7

**User Story:** As a developer, I want all Firestore CRUD operations replaced with Supabase equivalents, so that data manipulation works with the PostgreSQL database

#### Acceptance Criteria

1. WHEN a component calls addDoc, THE School ERP System SHALL execute a Supabase insert operation
2. WHEN a component calls updateDoc, THE School ERP System SHALL execute a Supabase update operation
3. WHEN a component calls deleteDoc, THE School ERP System SHALL execute a Supabase delete operation
4. WHEN a component calls getDocs, THE School ERP System SHALL execute a Supabase select query
5. WHEN a component calls getDoc, THE School ERP System SHALL execute a Supabase single row select
6. THE School ERP System SHALL update AdmissionRequests component to use Supabase operations
7. THE School ERP System SHALL update NoticeBoard component to use Supabase operations
8. THE School ERP System SHALL update HostelAllocationDialog component to use Supabase operations
9. THE School ERP System SHALL update all other components performing direct database operations

### Requirement 8

**User Story:** As a developer, I want authentication migrated to Supabase Auth, so that users can log in without Firebase

#### Acceptance Criteria

1. THE School ERP System SHALL implement custom authentication using Supabase database queries
2. THE School ERP System SHALL validate user credentials against the users table in Supabase
3. THE School ERP System SHALL maintain session storage for authenticated user state
4. THE School ERP System SHALL preserve the existing login flow and user experience
5. THE School ERP System SHALL support role-based authentication for Admin, Teacher, Student, and Finance roles

### Requirement 9

**User Story:** As a developer, I want Supabase credentials directly configured in the codebase, so that setup is simplified without environment variables

#### Acceptance Criteria

1. THE School ERP System SHALL create a configuration file with hardcoded Supabase URL and anon key
2. THE School ERP System SHALL use the same pattern as Firebase config (direct export of configuration object)
3. THE School ERP System SHALL document the Supabase credentials in the config file comments
4. THE School ERP System SHALL maintain the same simple setup approach as the current Firebase implementation


### Requirement 10

**User Story:** As a developer, I want comprehensive testing of the migration, so that all features work correctly with Supabase

#### Acceptance Criteria

1. THE School ERP System SHALL verify that all data collections load correctly on application startup
2. THE School ERP System SHALL verify that user login functionality works with Supabase authentication
3. THE School ERP System SHALL verify that admission request approval creates student and fee records
4. THE School ERP System SHALL verify that notice posting adds records to the Supabase notices table
5. THE School ERP System SHALL verify that hostel allocation updates the hostelRooms table
6. THE School ERP System SHALL verify that real-time updates propagate to all connected clients
7. THE School ERP System SHALL verify that all dashboard views display data correctly
8. THE School ERP System SHALL verify that fee payment flows work end-to-end
9. THE School ERP System SHALL verify that attendance logging persists to the database
10. THE School ERP System SHALL verify that no Firebase references remain in the codebase

### Requirement 11

**User Story:** As a developer, I want proper error handling and logging, so that issues can be diagnosed and resolved

#### Acceptance Criteria

1. THE School ERP System SHALL log connection errors when Supabase client initialization fails
2. THE School ERP System SHALL display user-friendly error messages when database operations fail
3. THE School ERP System SHALL emit error events for permission-related failures
4. THE School ERP System SHALL handle network errors gracefully with retry logic
5. THE School ERP System SHALL provide meaningful error context for debugging

### Requirement 12

**User Story:** As a developer, I want migration documentation, so that the setup process and changes are clearly understood

#### Acceptance Criteria

1. THE School ERP System SHALL provide a migration guide documenting the changes made
2. THE School ERP System SHALL document the Supabase project setup steps
3. THE School ERP System SHALL document the database schema and table structures
4. THE School ERP System SHALL document environment variable configuration
5. THE School ERP System SHALL document any breaking changes or API differences
