
'use client';

import { ReactNode, useEffect, useState } from 'react';
import { SupabaseClient } from '@supabase/supabase-js';

import { initializeSupabase, SupabaseProvider } from '.';

type SupabaseClientProviderProps = {
  children: ReactNode;
};

export function SupabaseClientProvider({
  children,
}: SupabaseClientProviderProps) {
  const [supabase, setSupabase] = useState<SupabaseClient | null>(null);

  useEffect(() => {
    const { supabase } = initializeSupabase();
    setSupabase(supabase);
  }, []);

  return (
    <SupabaseProvider supabase={supabase}>
      {children}
    </SupabaseProvider>
  );
}
