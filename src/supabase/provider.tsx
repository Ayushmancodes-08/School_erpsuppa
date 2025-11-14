
'use client';

import { SupabaseClient } from '@supabase/supabase-js';
import {
  createContext,
  ReactNode,
  useContext,
} from 'react';

type SupabaseContextType = {
  supabase: SupabaseClient | null;
};

const SupabaseContext = createContext<SupabaseContextType>({
  supabase: null,
});

type SupabaseProviderProps = {
  children: ReactNode;
} & SupabaseContextType;

import { SupabaseErrorListener } from '@/components/SupabaseErrorListener';

export function SupabaseProvider({
  children,
  supabase,
}: SupabaseProviderProps) {
  return (
    <SupabaseContext.Provider value={{ supabase }}>
      <SupabaseErrorListener />
      {children}
    </SupabaseContext.Provider>
  );
}

export function useSupabase() {
  const { supabase } = useContext(SupabaseContext);
  return supabase;
}
