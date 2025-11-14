
'use client';

import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { supabaseConfig } from './config';

export * from './provider';
export * from './hooks/use-user';
export * from './hooks/use-collection';
export * from './hooks/use-doc';

let supabase: SupabaseClient;

export function initializeSupabase() {
  if (!supabase) {
    supabase = createClient(supabaseConfig.url, supabaseConfig.anonKey);
  }

  return { supabase };
}
