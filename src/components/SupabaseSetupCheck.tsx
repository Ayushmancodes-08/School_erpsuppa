'use client';

import { useEffect, useState } from 'react';
import { useSupabase } from '@/supabase/provider';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { AlertCircle, CheckCircle2 } from 'lucide-react';

export function SupabaseSetupCheck() {
  const supabase = useSupabase();
  const [isConfigured, setIsConfigured] = useState(false);
  const [isChecking, setIsChecking] = useState(true);

  useEffect(() => {
    const checkSetup = async () => {
      if (!supabase) {
        setIsConfigured(false);
        setIsChecking(false);
        return;
      }

      try {
        // Try to query the users table
        const { data, error } = await supabase.from('users').select('count').limit(1);
        
        if (error) {
          console.error('Supabase setup check failed:', error);
          setIsConfigured(false);
        } else {
          setIsConfigured(true);
        }
      } catch (error) {
        console.error('Supabase setup check error:', error);
        setIsConfigured(false);
      } finally {
        setIsChecking(false);
      }
    };

    checkSetup();
  }, [supabase]);

  if (isChecking) {
    return null; // Don't show anything while checking
  }

  if (!isConfigured) {
    return (
      <div className="fixed top-4 left-1/2 transform -translate-x-1/2 z-50 w-full max-w-2xl px-4">
        <Alert variant="destructive">
          <AlertCircle className="h-4 w-4" />
          <AlertTitle>Supabase Not Configured</AlertTitle>
          <AlertDescription>
            Please configure your Supabase credentials in <code className="bg-destructive/20 px-1 py-0.5 rounded">src/supabase/config.ts</code>.
            <br />
            See <strong>SETUP-INSTRUCTIONS.md</strong> for the 3-step setup guide.
          </AlertDescription>
        </Alert>
      </div>
    );
  }

  return null;
}
