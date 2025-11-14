
'use client';

import { useEffect, useMemo, useState } from 'react';
import { useSupabase } from '../';
import { errorEmitter } from '../error-emitter';
import { SupabasePermissionError, SecurityRuleContext } from '../errors';

type UseCollectionOptions<T> = {
  deps?: any[];
  query?: any[];
};

// Helper function to convert snake_case to camelCase
function toCamelCase(str: string): string {
  return str.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase());
}

// Transform database object keys from snake_case to camelCase
function transformKeys(obj: any): any {
  if (obj === null || obj === undefined) return obj;
  if (Array.isArray(obj)) return obj.map(transformKeys);
  if (typeof obj !== 'object') return obj;

  const transformed: any = {};
  for (const key in obj) {
    if (obj.hasOwnProperty(key)) {
      const camelKey = toCamelCase(key);
      transformed[camelKey] = transformKeys(obj[key]);
    }
  }
  return transformed;
}

export function useCollection<T>(
  table: string,
  options?: UseCollectionOptions<T>
) {
  const supabase = useSupabase();
  const [data, setData] = useState<T[] | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!supabase) {
      return;
    }

    // Initial data fetch
    const fetchData = async () => {
      try {
        let query = supabase.from(table).select('*');

        // Apply query filters if provided
        if (options?.query) {
          options.query.forEach((filter) => {
            if (Array.isArray(filter) && filter.length === 3) {
              const [field, operator, value] = filter;
              if (operator === '==') {
                query = query.eq(field, value);
              } else if (operator === '>') {
                query = query.gt(field, value);
              } else if (operator === '<') {
                query = query.lt(field, value);
              } else if (operator === '>=') {
                query = query.gte(field, value);
              } else if (operator === '<=') {
                query = query.lte(field, value);
              }
            }
          });
        }

        const { data: fetchedData, error } = await query;

        if (error) {
          throw error;
        }

        // Transform snake_case keys to camelCase
        const transformedData = fetchedData ? fetchedData.map(transformKeys) : null;
        setData(transformedData as T[]);
        setLoading(false);
      } catch (error) {
        console.error('Error fetching collection:', error);
        const permissionError = new SupabasePermissionError({
          path: table,
          operation: 'list',
        } satisfies SecurityRuleContext);
        errorEmitter.emit('permission-error', permissionError);
        setLoading(false);
      }
    };

    fetchData();


    // Subscribe to real-time changes
    const channel = supabase
      .channel(`${table}_changes`)
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: table },
        (payload) => {
          if (payload.eventType === 'INSERT') {
            const transformedNew = transformKeys(payload.new);
            setData((prev) => (prev ? [...prev, transformedNew as T] : [transformedNew as T]));
          } else if (payload.eventType === 'UPDATE') {
            const transformedNew = transformKeys(payload.new);
            setData((prev) =>
              prev
                ? prev.map((item: any) =>
                    item.id === (transformedNew as any).id ? (transformedNew as T) : item
                  )
                : [transformedNew as T]
            );
          } else if (payload.eventType === 'DELETE') {
            setData((prev) =>
              prev ? prev.filter((item: any) => item.id !== (payload.old as any).id) : []
            );
          }
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [supabase, table, ...(options?.deps || [])]);

  return { data, loading };
}
