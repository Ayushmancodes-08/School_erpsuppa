
'use client';

import { useEffect, useMemo, useState } from 'react';
import { useSupabase } from '../';
import { errorEmitter } from '../error-emitter';
import { SupabasePermissionError, SecurityRuleContext } from '../errors';

export function useDoc<T>(path: string, options?: { deps?: any[] }) {
  const supabase = useSupabase();
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);

  // Parse path to get table and id (format: "table/id")
  const { table, id } = useMemo(() => {
    const parts = path.split('/');
    return { table: parts[0], id: parts[1] };
  }, [path]);

  useEffect(() => {
    if (!supabase || !id) {
      return;
    }

    // Initial data fetch
    const fetchData = async () => {
      try {
        const { data: fetchedData, error } = await supabase
          .from(table)
          .select('*')
          .eq('id', id)
          .single();

        if (error) {
          if (error.code === 'PGRST116') {
            // No rows returned
            setData(null);
            setLoading(false);
            return;
          }
          throw error;
        }

        setData(fetchedData as T);
        setLoading(false);
      } catch (error) {
        console.error('Error fetching document:', error);
        const permissionError = new SupabasePermissionError({
          path,
          operation: 'get',
        } satisfies SecurityRuleContext);
        errorEmitter.emit('permission-error', permissionError);
        setLoading(false);
      }
    };

    fetchData();


    // Subscribe to real-time updates for this specific row
    const channel = supabase
      .channel(`${table}_${id}_changes`)
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: table,
          filter: `id=eq.${id}`,
        },
        (payload) => {
          if (payload.eventType === 'UPDATE') {
            setData(payload.new as T);
          } else if (payload.eventType === 'DELETE') {
            setData(null);
          }
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [supabase, table, id, path, ...(options?.deps || [])]);

  const update = async (updateData: Partial<T>) => {
    if (!supabase || !id) {
      return;
    }
    try {
      const { error } = await supabase
        .from(table)
        .update(updateData)
        .eq('id', id);

      if (error) {
        throw error;
      }
    } catch (error) {
      console.error('Error updating document:', error);
      const permissionError = new SupabasePermissionError({
        path,
        operation: 'update',
        requestResourceData: updateData,
      } satisfies SecurityRuleContext);
      errorEmitter.emit('permission-error', permissionError);
    }
  };

  const set = async (setData: T) => {
    if (!supabase || !id) {
      return;
    }
    try {
      const { error } = await supabase
        .from(table)
        .upsert({ ...setData, id } as any);

      if (error) {
        throw error;
      }
    } catch (error) {
      console.error('Error setting document:', error);
      const permissionError = new SupabasePermissionError({
        path,
        operation: 'create',
        requestResourceData: setData,
      } satisfies SecurityRuleContext);
      errorEmitter.emit('permission-error', permissionError);
    }
  };

  return { data, loading, set, update };
}
