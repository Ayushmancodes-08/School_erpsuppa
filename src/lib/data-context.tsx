
"use client";

import React, { createContext, useContext, useEffect, ReactNode } from 'react';
import { useCollection } from '@/supabase';
import { useSupabase } from '@/supabase/provider';
import { Student, Fee, StudentAttendance, HostelRoom, Homework, Admission, User, Teacher, AdmissionApplication, HostelFee, JobApplication, Notice, Hostel } from './types';

// Define the shape of our context
interface DataContextProps {
  students: Student[] | null;
  teachers: Teacher[] | null;
  fees: Fee[] | null;
  hostelFees: HostelFee[] | null;
  studentAttendance: StudentAttendance[] | null;
  hostels: Hostel[] | null;
  hostelRooms: HostelRoom[] | null;
  homeworks: Homework[] | null;
  admissions: Admission[] | null;
  admissionApplications: AdmissionApplication[] | null;
  jobApplications: JobApplication[] | null;
  users: User[] | null;
  notices: Notice[] | null;
}

const DataContext = createContext<DataContextProps | undefined>(undefined);

// Function to seed initial users
const seedInitialUsers = async (supabase: any) => {
    if (!supabase) return;
    
    // Seed Admin User
    const { data: adminData } = await supabase
        .from('users')
        .select('*')
        .eq('role', 'Admin')
        .limit(1);
    
    if (!adminData || adminData.length === 0) {
        console.log("No admin user found, creating one...");
        await supabase.from('users').insert({
            user_id: 'admin',
            password: 'password',
            role: 'Admin',
        });
    }

    // Seed Finance User
    const { data: financeData } = await supabase
        .from('users')
        .select('*')
        .eq('role', 'Finance')
        .limit(1);
    
    if (!financeData || financeData.length === 0) {
        console.log("No finance user found, creating one...");
        await supabase.from('users').insert({
            user_id: 'finance',
            password: 'password',
            role: 'Finance',
        });
    }
};

// This provider will now fetch data from Supabase
export const DataProvider = ({ children }: { children: ReactNode }) => {
  const supabase = useSupabase();
  const { data: students } = useCollection<Student>('students');
  const { data: teachers } = useCollection<Teacher>('teachers');
  const { data: fees } = useCollection<Fee>('fees');
  const { data: hostelFees } = useCollection<HostelFee>('hostel_fees');
  const { data: studentAttendance } = useCollection<StudentAttendance>('student_attendance');
  const { data: hostels } = useCollection<Hostel>('hostels');
  const { data: hostelRooms } = useCollection<HostelRoom>('hostel_rooms');
  const { data: homeworks } = useCollection<Homework>('homeworks');
  const { data: admissions } = useCollection<Admission>('admissions');
  const { data: admissionApplications } = useCollection<AdmissionApplication>('admission_applications');
  const { data: jobApplications } = useCollection<JobApplication>('job_applications');
  const { data: users } = useCollection<User>('users');
  const { data: notices } = useCollection<Notice>('notices');

  useEffect(() => {
    if (supabase) {
      seedInitialUsers(supabase);
    }
  }, [supabase]);

  const value = {
    students,
    teachers,
    fees,
    hostelFees,
    studentAttendance,
    hostels,
    hostelRooms,
    homeworks,
    admissions,
    admissionApplications,
    jobApplications,
    users,
    notices,
  };

  return (
    <DataContext.Provider value={value as DataContextProps}>
      {children}
    </DataContext.Provider>
  );
};

export const useData = () => {
  const context = useContext(DataContext);
  if (context === undefined) {
    throw new Error('useData must be used within a DataProvider');
  }
  return context;
};
