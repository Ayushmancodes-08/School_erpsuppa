# Design Document

## Overview

This design document outlines the technical approach for migrating the School ERP system from Firebase Firestore to Supabase. The migration will replace Firebase Authentication and Firestore with Supabase Auth and PostgreSQL while maintaining the existing application architecture and user experience. The design focuses on minimal disruption to the component layer by preserving the same data access patterns through custom hooks.

## Architecture

### Current Architecture (Firebase)

```
Next.js App
├── FirebaseClientProvider (initializes Firebase)
├── DataProvider (loads all collections)
└── Components
    ├── useCollection (real-time Firestore queries)
    ├── useDoc (single document queries)
    └── useUser (Firebase Auth state)
```

### Target Architecture (Supabase)

```
Next.js App
├── SupabaseClientProvider (initializes Supabase)
├── DataProvider (loads all collections from PostgreSQL)
└── Components
    ├── useCollection (real-time Supabase queries)
    ├── useDoc (single row queries)
    └── useUser (custom auth state)
```

### Key Design Decisions

1. **Preserve Hook Interface**: Maintain the same API for useCollection, useDoc, and useUser to avoid component changes
2. **PostgreSQL Schema**: Design normalized relational schema matching the existing Firestore document structure
3. **Real-time Subscriptions**: Use Supabase Realtime channels to replicate Firestore's onSnapshot behavior
4. **Custom Authentication**: Implement simple credential-based auth using the users table instead of Supabase Auth
5. **Provider Pattern**: Replace Firebase providers with Supabase equivalents maintaining the same context structure


## Components and Interfaces

### 1. Supabase Configuration Module

**File**: `src/supabase/config.ts`

```typescript
// Supabase project configuration
// Get these values from: https://app.supabase.com -> Your Project -> Settings -> API
export const supabaseConfig = {
  url: "https://your-project-id.supabase.co",
  anonKey: "your-anon-key-here",
};
```

**Purpose**: Centralize Supabase configuration with direct hardcoded values (matching Firebase config pattern)

### 2. Supabase Client Initialization

**File**: `src/supabase/index.ts`

```typescript
import { createClient, SupabaseClient } from '@supabase/supabase-js';

let supabase: SupabaseClient;

export function initializeSupabase() {
  if (!supabase) {
    supabase = createClient(supabaseConfig.url, supabaseConfig.anonKey);
  }
  return supabase;
}
```

**Purpose**: Initialize and export Supabase client singleton

### 3. Supabase Provider

**File**: `src/supabase/provider.tsx`

```typescript
type SupabaseContextType = {
  supabase: SupabaseClient | null;
};

export function SupabaseProvider({ children, supabase }: Props) {
  return (
    <SupabaseContext.Provider value={{ supabase }}>
      {children}
    </SupabaseContext.Provider>
  );
}

export function useSupabase() {
  return useContext(SupabaseContext);
}
```

**Purpose**: Provide Supabase client through React context

### 4. useCollection Hook

**File**: `src/supabase/hooks/use-collection.tsx`

**Interface**:
```typescript
function useCollection<T>(
  table: string,
  options?: { query?: any[]; deps?: any[] }
): { data: T[] | null; loading: boolean }
```

**Implementation Strategy**:
- Use `supabase.from(table).select('*')` for initial data fetch
- Apply query filters using `.eq()`, `.gt()`, etc. based on options
- Subscribe to real-time changes using `supabase.channel().on('postgres_changes')`
- Update local state when INSERT, UPDATE, or DELETE events occur
- Return data array with loading state


### 5. useDoc Hook

**File**: `src/supabase/hooks/use-doc.tsx`

**Interface**:
```typescript
function useDoc<T>(
  table: string,
  id: string,
  options?: { deps?: any[] }
): {
  data: T | null;
  loading: boolean;
  update: (data: Partial<T>) => Promise<void>;
  set: (data: T) => Promise<void>;
}
```

**Implementation Strategy**:
- Use `supabase.from(table).select('*').eq('id', id).single()` for initial fetch
- Subscribe to real-time updates for the specific row
- Implement `update` using `.update().eq('id', id)`
- Implement `set` using `.upsert()`
- Handle errors and emit error events

### 6. useUser Hook

**File**: `src/supabase/hooks/use-user.tsx`

**Interface**:
```typescript
function useUser(): {
  user: User | null;
  loading: boolean;
}
```

**Implementation Strategy**:
- Check sessionStorage for authenticated state on mount
- Return user object based on stored session data
- No actual Supabase Auth integration (using custom auth)
- Maintain compatibility with existing login flow

### 7. Client Provider

**File**: `src/supabase/client-provider.tsx`

**Purpose**: Initialize Supabase client on mount and provide to children

**Implementation**:
- Call `initializeSupabase()` in useEffect
- Pass client to SupabaseProvider
- Replace FirebaseClientProvider in layout.tsx


## Data Models

### PostgreSQL Schema Design

All tables will use UUID primary keys and include appropriate indexes. The schema mirrors the existing TypeScript interfaces.

#### Students Table
```sql
CREATE TABLE students (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  class TEXT NOT NULL,
  section TEXT NOT NULL,
  roll_number TEXT NOT NULL,
  avatar TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_students_class ON students(class);
```

#### Teachers Table
```sql
CREATE TABLE teachers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  subject TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### Fees Table
```sql
CREATE TABLE fees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  student_name TEXT NOT NULL,
  class TEXT NOT NULL,
  amount NUMERIC(10, 2) NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('Paid', 'Due', 'Overdue')),
  due_date DATE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_fees_student_id ON fees(student_id);
CREATE INDEX idx_fees_status ON fees(status);
```

#### Hostel Fees Table
```sql
CREATE TABLE hostel_fees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  student_name TEXT NOT NULL,
  room_number TEXT NOT NULL,
  amount NUMERIC(10, 2) NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('Paid', 'Due', 'Overdue')),
  due_date DATE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_hostel_fees_student_id ON hostel_fees(student_id);
```


#### Student Attendance Table
```sql
CREATE TABLE student_attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  records JSONB NOT NULL DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_student_attendance_student_id ON student_attendance(student_id);
```

#### Hostels Table
```sql
CREATE TABLE hostels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('Boys', 'Girls')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### Hostel Rooms Table
```sql
CREATE TABLE hostel_rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  hostel_id UUID NOT NULL REFERENCES hostels(id) ON DELETE CASCADE,
  hostel_name TEXT NOT NULL,
  room_number TEXT NOT NULL,
  capacity INTEGER NOT NULL,
  occupants TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_hostel_rooms_hostel_id ON hostel_rooms(hostel_id);
```

#### Homeworks Table
```sql
CREATE TABLE homeworks (
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

CREATE INDEX idx_homeworks_class_section ON homeworks(class, section);
```


#### Admissions Table
```sql
CREATE TABLE admissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  month TEXT NOT NULL,
  admitted INTEGER NOT NULL,
  capacity INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### Admission Applications Table
```sql
CREATE TABLE admission_applications (
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

CREATE INDEX idx_admission_applications_status ON admission_applications(status);
```

#### Job Applications Table
```sql
CREATE TABLE job_applications (
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

CREATE INDEX idx_job_applications_status ON job_applications(status);
```

#### Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('Admin', 'Teacher', 'Student', 'Finance')),
  student_id UUID REFERENCES students(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_users_user_id ON users(user_id);
CREATE INDEX idx_users_role ON users(role);
```


#### Notices Table
```sql
CREATE TABLE notices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  author TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('Admin', 'Teacher')),
  date DATE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notices_date ON notices(date DESC);
```

### Column Naming Convention

PostgreSQL uses snake_case for column names (e.g., `student_id`, `due_date`), while the TypeScript interfaces use camelCase (e.g., `studentId`, `dueDate`). The Supabase client will automatically handle this conversion when configured properly, or we'll manually map between conventions in the hooks.

## Error Handling

### Error Types

1. **Connection Errors**: Supabase client initialization failures
2. **Query Errors**: Failed SELECT, INSERT, UPDATE, DELETE operations
3. **Permission Errors**: RLS policy violations
4. **Network Errors**: Timeout or connectivity issues
5. **Validation Errors**: Invalid data format or constraint violations

### Error Handling Strategy

1. **Hook Level**: Catch errors in useCollection and useDoc, set loading to false
2. **Component Level**: Display toast notifications for user-facing errors
3. **Error Emitter**: Maintain error emitter pattern for permission errors
4. **Logging**: Console.error for debugging in development
5. **Graceful Degradation**: Show empty states when data fails to load

### Error Emitter

**File**: `src/supabase/error-emitter.ts`

```typescript
class ErrorEmitter extends EventEmitter {
  emit(event: 'permission-error', error: SupabasePermissionError): boolean;
}

export const errorEmitter = new ErrorEmitter();
```


## Row Level Security (RLS) Policies

### Design Rationale

The current Firestore rules allow public read access and authenticated write access. We'll replicate this behavior with RLS policies while adding more granular control.

### Policy Structure

For each table, we'll create four policies:

1. **Public Read Policy**: Allow unauthenticated SELECT (for login page)
2. **Authenticated Read Policy**: Allow authenticated users to SELECT all rows
3. **Authenticated Insert Policy**: Allow authenticated users to INSERT
4. **Authenticated Update/Delete Policy**: Allow authenticated users to UPDATE and DELETE

### Example RLS Policies

```sql
-- Enable RLS
ALTER TABLE students ENABLE ROW LEVEL SECURITY;

-- Public read access (for login page data loading)
CREATE POLICY "Allow public read access"
  ON students FOR SELECT
  TO anon
  USING (true);

-- Authenticated users can do everything
CREATE POLICY "Allow authenticated users full access"
  ON students FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);
```

### Users Table Special Policy

The users table requires stricter policies:

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Public read for login validation
CREATE POLICY "Allow public read for login"
  ON users FOR SELECT
  TO anon
  USING (true);

-- Authenticated users can only update their own record
CREATE POLICY "Users can update own record"
  ON users FOR UPDATE
  TO authenticated
  USING (auth.uid()::text = id::text)
  WITH CHECK (auth.uid()::text = id::text);
```

**Note**: Since we're using custom authentication (not Supabase Auth), we may need to adjust these policies or use service role key for operations.


## Real-time Subscriptions

### Design Approach

Supabase provides real-time functionality through PostgreSQL's replication features. We'll use Supabase Realtime channels to subscribe to table changes.

### Implementation in useCollection

```typescript
useEffect(() => {
  // Initial data fetch
  const fetchData = async () => {
    const { data, error } = await supabase.from(table).select('*');
    if (data) setData(data);
    setLoading(false);
  };
  
  fetchData();
  
  // Subscribe to changes
  const channel = supabase
    .channel(`${table}_changes`)
    .on('postgres_changes', 
      { event: '*', schema: 'public', table: table },
      (payload) => {
        if (payload.eventType === 'INSERT') {
          setData(prev => [...prev, payload.new]);
        } else if (payload.eventType === 'UPDATE') {
          setData(prev => prev.map(item => 
            item.id === payload.new.id ? payload.new : item
          ));
        } else if (payload.eventType === 'DELETE') {
          setData(prev => prev.filter(item => item.id !== payload.old.id));
        }
      }
    )
    .subscribe();
    
  return () => {
    supabase.removeChannel(channel);
  };
}, [table]);
```

### Realtime Configuration

Realtime must be enabled for each table in the Supabase dashboard or via SQL:

```sql
ALTER PUBLICATION supabase_realtime ADD TABLE students;
ALTER PUBLICATION supabase_realtime ADD TABLE teachers;
-- ... repeat for all tables
```


## CRUD Operations Migration

### Mapping Firebase to Supabase

| Firebase Operation | Supabase Equivalent |
|-------------------|---------------------|
| `addDoc(collection(db, 'table'), data)` | `supabase.from('table').insert(data)` |
| `updateDoc(doc(db, 'table', id), data)` | `supabase.from('table').update(data).eq('id', id)` |
| `deleteDoc(doc(db, 'table', id))` | `supabase.from('table').delete().eq('id', id)` |
| `getDocs(collection(db, 'table'))` | `supabase.from('table').select('*')` |
| `getDoc(doc(db, 'table', id))` | `supabase.from('table').select('*').eq('id', id).single()` |
| `query(collection, where('field', '==', value))` | `supabase.from('table').select('*').eq('field', value)` |
| `onSnapshot(query, callback)` | `supabase.channel().on('postgres_changes', callback)` |

### Component Updates Required

#### AdmissionRequests.tsx
- Replace `addDoc(collection(firestore, "students"), ...)` with `supabase.from('students').insert(...)`
- Replace `addDoc(collection(firestore, "fees"), ...)` with `supabase.from('fees').insert(...)`
- Replace `updateDoc(doc(firestore, "admissionApplications", id), ...)` with `supabase.from('admission_applications').update(...).eq('id', id)`

#### NoticeBoard.tsx
- Replace `addDoc(collection(firestore, "notices"), ...)` with `supabase.from('notices').insert(...)`

#### HostelAllocationDialog.tsx
- Replace Firestore operations with Supabase equivalents
- Update hostel_rooms table with new occupants

#### DataContext.tsx
- Replace `getDocs(query(...))` with `supabase.from('users').select('*').eq('role', 'Admin')`
- Replace `addDoc` with `supabase.from('users').insert(...)`


## Testing Strategy

### Unit Testing

1. **Hook Testing**: Test useCollection, useDoc, and useUser in isolation
   - Mock Supabase client responses
   - Verify data transformations
   - Test error handling paths

2. **Provider Testing**: Test SupabaseProvider initialization
   - Verify client is created correctly
   - Test context value propagation

### Integration Testing

1. **Data Flow Testing**: Verify end-to-end data operations
   - Test DataContext loads all collections
   - Verify real-time updates propagate
   - Test CRUD operations in components

2. **Authentication Testing**: Verify login flow
   - Test credential validation
   - Verify session storage
   - Test role-based access

### Manual Testing Checklist

- [ ] Login with Admin, Teacher, Student, Finance roles
- [ ] Verify all dashboard views load data
- [ ] Test admission request approval flow
- [ ] Test notice posting and display
- [ ] Test hostel allocation
- [ ] Test fee payment flow
- [ ] Test attendance logging
- [ ] Verify real-time updates across multiple browser tabs
- [ ] Test error scenarios (network failure, invalid data)
- [ ] Verify no Firebase references remain in code

### Performance Testing

1. **Load Time**: Measure initial data load performance
2. **Real-time Latency**: Measure time from database change to UI update
3. **Query Performance**: Verify indexes improve query speed
4. **Concurrent Users**: Test multiple simultaneous connections


## Migration Sequence

### Phase 1: Setup and Configuration
1. Create Supabase project
2. Install @supabase/supabase-js package
3. Remove Firebase packages
4. Create environment variables
5. Delete Firebase configuration files

### Phase 2: Database Schema
1. Create all 13 tables with proper schema
2. Add indexes for performance
3. Enable Row Level Security
4. Create RLS policies
5. Enable Realtime for all tables

### Phase 3: Core Infrastructure
1. Create Supabase configuration module
2. Implement Supabase client initialization
3. Create SupabaseProvider and context hooks
4. Implement useCollection hook
5. Implement useDoc hook
6. Implement useUser hook
7. Create error emitter

### Phase 4: Data Layer Migration
1. Update DataContext to use Supabase
2. Update seedInitialUsers function
3. Replace FirebaseClientProvider with SupabaseClientProvider in layout.tsx
4. Update all useCollection calls to use new hooks

### Phase 5: Component Updates
1. Update AdmissionRequests component
2. Update NoticeBoard component
3. Update HostelAllocationDialog component
4. Update any other components with direct Firestore operations
5. Remove Firebase imports from all files

### Phase 6: Testing and Validation
1. Test all user flows
2. Verify real-time functionality
3. Test error handling
4. Performance testing
5. Code cleanup and documentation


## Configuration Setup

### Supabase Config File (No .env needed!)

Create `src/supabase/config.ts` with hardcoded values (same pattern as Firebase):

```typescript
// Supabase project configuration
// Get these values from: https://app.supabase.com -> Your Project -> Settings -> API
export const supabaseConfig = {
  url: "https://your-project-id.supabase.co",
  anonKey: "your-anon-key-here",
};
```

### How to Get Your Supabase Credentials

1. Go to https://app.supabase.com
2. Select your project (or create a new one)
3. Go to **Settings** → **API**
4. Copy the **Project URL** (e.g., `https://abcdefgh.supabase.co`)
5. Copy the **anon/public key** (starts with `eyJ...`)
6. Paste both values directly into `src/supabase/config.ts`

**No .env file needed!** Just like your Firebase config, the values are directly in the code.

## Dependencies

### Packages to Install

```json
{
  "dependencies": {
    "@supabase/supabase-js": "^2.39.0"
  }
}
```

### Packages to Remove

```json
{
  "dependencies": {
    "firebase": "^11.9.1"  // REMOVE
  }
}
```

### Installation Commands

```bash
npm install @supabase/supabase-js
npm uninstall firebase
```


## Key Differences and Considerations

### 1. Data Structure

**Firebase**: Document-based NoSQL with nested objects
**Supabase**: Relational PostgreSQL with normalized tables

**Impact**: The JSONB type handles nested data (like attendance records), but most data is flattened into columns.

### 2. Real-time Behavior

**Firebase**: Automatic real-time updates via onSnapshot
**Supabase**: Requires explicit channel subscription and event handling

**Impact**: More boilerplate code in hooks, but similar end result.

### 3. Authentication

**Firebase**: Full-featured auth with email/password, OAuth, etc.
**Supabase**: Full-featured auth, but we're using custom auth with database queries

**Impact**: Simpler implementation for this use case, but less secure than proper auth.

### 4. Auto-generated IDs

**Firebase**: Auto-generates document IDs
**Supabase**: Uses UUID with DEFAULT gen_random_uuid()

**Impact**: No code changes needed, both generate unique IDs automatically.

### 5. Query Syntax

**Firebase**: `where('field', '==', value)`
**Supabase**: `.eq('field', value)`

**Impact**: Different syntax but similar capabilities. Supabase is more SQL-like.

### 6. Offline Support

**Firebase**: Built-in offline persistence
**Supabase**: No built-in offline support

**Impact**: Application requires internet connection. Could add service worker for offline support later.

### 7. Security Rules

**Firebase**: Custom rules language in firestore.rules
**Supabase**: PostgreSQL Row Level Security policies

**Impact**: More powerful and flexible with RLS, but requires SQL knowledge.


## Rollback Strategy

In case the migration encounters critical issues:

### 1. Version Control
- Create a git branch for the migration
- Commit frequently with clear messages
- Tag the pre-migration state

### 2. Database Backup
- Export existing Firestore data before migration
- Keep Firebase project active during testing
- Document data export/import procedures

### 3. Rollback Steps
1. Revert git branch to pre-migration state
2. Restore Firebase configuration
3. Reinstall Firebase packages
4. Redeploy previous version

### 4. Parallel Running (Optional)
- Keep both Firebase and Supabase running temporarily
- Use feature flag to switch between backends
- Gradually migrate users to Supabase

## Documentation Deliverables

1. **Migration Guide**: Step-by-step instructions for setting up Supabase
2. **Schema Documentation**: Complete database schema with relationships
3. **API Changes**: List of changed imports and function calls
4. **Setup Instructions**: How to configure environment variables
5. **Troubleshooting Guide**: Common issues and solutions

## Success Criteria

The migration is considered successful when:

1. All Firebase dependencies are removed
2. All 13 data collections load correctly from Supabase
3. User authentication works with all roles
4. All CRUD operations function properly
5. Real-time updates work across all features
6. No console errors related to Firebase
7. Application performance is equal or better
8. All manual test cases pass
