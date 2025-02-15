DROP FUNCTION IF EXISTS public.get_events_by_date_and_tags(TEXT, TEXT[]);

CREATE OR REPLACE FUNCTION public.get_events_by_date_and_tags(p_pub_date text, p_tag_names text[])
 RETURNS SETOF events
 LANGUAGE plpgsql
 STABLE
 SET search_path TO 'public', 'extensions'
AS $function$
BEGIN
  IF array_length(p_tag_names, 1) IS NULL OR array_length(p_tag_names, 1) = 0 THEN
    -- If p_tag_names is empty or NULL, return all events after p_pub_date
    RETURN QUERY
    SELECT distinct e.*
    FROM events e where  e.event_start_date::date > p_pub_date::date order by e.event_start_date ;
  ELSE
    -- Otherwise, return events with tags matching p_tag_names
    RETURN QUERY
    SELECT DISTINCT  e.*
    FROM events e
    JOIN event_tags et ON e.id = et.event_id
    JOIN tags t ON et.tag_id = t.id
    WHERE e.event_start_date::date > p_pub_date::date and t.name = ANY(p_tag_names) order by e.event_start_date ;
  END IF;
END;
$function$
;

COMMENT ON FUNCTION get_events_by_date_and_tags IS 
  E'@graphqlName getEventsByTagsAndDate \n@param pPubDate: DateTime \n@param pTagNames: [String!]!';

ALTER FUNCTION get_events_by_date_and_tags(TEXT, TEXT[])
SET search_path = public, extensions;

GRANT EXECUTE ON FUNCTION get_events_by_date_and_tags TO anon, authenticated, service_role;

-- With date window for event_start_date
drop function if exists public.get_events_by_date_and_tags(text, text[])

CREATE OR REPLACE FUNCTION public.get_events_by_date_and_tags(
  p_pub_date text,
  p_tag_names text[] DEFAULT NULL,
  p_date_window_start text DEFAULT NULL,
  p_date_window_end text DEFAULT NULL
) RETURNS SETOF events
LANGUAGE plpgsql STABLE
SET search_path TO 'public', 'extensions'
AS $function$
begin
  IF p_pub_date !~ '^\d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2})?$' THEN
    RAISE EXCEPTION 'Invalid date format: %', p_pub_date;
  END IF;
  IF p_date_window_start !~ '^\d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2})?$' THEN
    RAISE EXCEPTION 'Invalid date format: %', p_date_window_start;
  END IF;
  IF p_date_window_end !~ '^\d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2})?$' THEN
    RAISE EXCEPTION 'Invalid date format: %', p_date_window_end;
  END IF;
  IF p_tag_names IS NULL OR cardinality(p_tag_names) = 0 THEN
    RETURN QUERY
    SELECT e.*
    FROM events e
    WHERE 
      e.pub_date >= p_pub_date::date
      AND (
        -- Valid date window
        (p_date_window_start IS NOT NULL AND p_date_window_end IS NOT NULL 
         AND p_date_window_start::date <= p_date_window_end::date
         AND e.event_start_date BETWEEN p_date_window_start::date AND p_date_window_end::DATE)
        OR
        -- Only start date
        (p_date_window_start IS NOT NULL AND p_date_window_end IS NULL 
         AND e.event_start_date >= p_date_window_start::DATE)
        OR
        -- Only end date
        (p_date_window_end IS NOT NULL AND p_date_window_start IS NULL 
         AND e.event_start_date <= p_date_window_end::DATE)
        OR
        -- Invalid/missing window
        ((p_date_window_start IS NULL AND p_date_window_end IS NULL) 
         OR (p_date_window_start::DATE > p_date_window_end::DATE))
      )
    ORDER BY e.event_start_date;
  ELSE
    RETURN QUERY
    SELECT e.*
    FROM events e
    JOIN event_tags et ON e.id = et.event_id
    JOIN tags t ON et.tag_id = t.id
    WHERE 
      e.pub_date >= p_pub_date::DATE
      AND t.name = ANY(p_tag_names)
      AND (
        -- Same date window logic
        (p_date_window_start IS NOT NULL AND p_date_window_end IS NOT NULL 
         AND p_date_window_start::DATE <= p_date_window_end::DATE
         AND e.event_start_date BETWEEN p_date_window_start::DATE AND p_date_window_end::DATE)
        OR
        (p_date_window_start IS NOT NULL AND p_date_window_end IS NULL 
         AND e.event_start_date >= p_date_window_start::DATE)
        OR
        (p_date_window_end IS NOT NULL AND p_date_window_start IS NULL 
         AND e.event_start_date <= p_date_window_end::DATE)
        OR
        ((p_date_window_start IS NULL AND p_date_window_end IS NULL) 
         OR (p_date_window_start::DATE > p_date_window_end::DATE))
      )
    GROUP BY e.id
    ORDER BY e.event_start_date;
  END IF;
END;
$function$;