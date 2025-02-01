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