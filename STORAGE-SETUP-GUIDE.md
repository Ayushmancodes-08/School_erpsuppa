# Storage Setup Guide

## Error: "Bucket not found"

This error occurs because the Supabase storage buckets haven't been created yet. Follow these steps to fix it:

## Solution

### Step 1: Access Supabase Dashboard
1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor** in the left sidebar

### Step 2: Run the Setup Script
1. Copy the contents of `SETUP-STORAGE-BUCKETS.sql`
2. Paste it into the SQL Editor
3. Click **Run** to execute the script

This will create:
- **avatars** bucket - for student and teacher profile pictures
- **documents** bucket - for resume/CV uploads

### Step 3: Verify Buckets Created
1. Go to **Storage** in the left sidebar
2. You should see two buckets:
   - `avatars`
   - `documents`

### Alternative: Manual Setup via UI

If you prefer to create buckets manually:

#### Create Avatars Bucket:
1. Go to **Storage** → Click **New bucket**
2. Name: `avatars`
3. Check **Public bucket** ✓
4. Click **Create bucket**

#### Create Documents Bucket:
1. Go to **Storage** → Click **New bucket**
2. Name: `documents`
3. Check **Public bucket** ✓
4. Click **Create bucket**

#### Set Policies:
For each bucket, go to **Policies** and add:
- **SELECT**: Allow public access
- **INSERT**: Allow authenticated users
- **UPDATE**: Allow authenticated users
- **DELETE**: Allow authenticated users

## Folder Structure

The application will automatically create these folders:
- `avatars/student-avatars/` - Student profile pictures
- `avatars/teacher-avatars/` - Teacher profile pictures
- `documents/resumes/` - Teacher resume/CV files

## Testing

After setup, try:
1. Login as a student → Go to Settings → Upload profile picture
2. Login as a teacher → Go to Settings → Upload profile picture
3. Go to Careers page → Upload resume as PDF

## Troubleshooting

### Still getting "Bucket not found"?
- Verify bucket names are exactly: `avatars` and `documents` (lowercase)
- Check that buckets are marked as **public**
- Ensure policies are properly set

### Upload fails with permission error?
- Check that storage policies allow INSERT for authenticated users
- Verify your Supabase connection is working

### File size limits?
- Images: Max 5MB
- PDFs: Max 10MB
- These limits are set in the code and can be adjusted if needed
