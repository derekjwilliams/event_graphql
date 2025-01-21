DROP FUNCTION IF EXISTS public.get_events_by_date_and_tags(TEXT, TEXT[]);

CREATE FUNCTION public.get_events_by_date_and_tags(
  p_pub_date TEXT,
  p_tag_names TEXT[]
)
RETURNS SETOF events
AS $$
BEGIN
  IF array_length(p_tag_names, 1) IS NULL OR array_length(p_tag_names, 1) = 0 THEN
    -- If p_tag_names is empty or NULL, return all events after p_pub_date
    RETURN QUERY
    SELECT e.*
    FROM events e
    WHERE e.pub_date > p_pub_date::TIMESTAMP WITH TIME ZONE;
  ELSE
    -- Otherwise, return events with tags matching p_tag_names
    RETURN QUERY
    SELECT e.*
    FROM events e
    JOIN event_tags et ON e.id = et.event_id
    JOIN tags t ON et.tag_id = t.id
    WHERE e.pub_date > p_pub_date::TIMESTAMP WITH TIME ZONE
    AND t.name = ANY(p_tag_names);
  END IF;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION get_events_by_date_and_tags IS 
  E'@graphqlName getEventsByTagsAndDate \n@param pPubDate: DateTime \n@param pTagNames: [String!]!';

ALTER FUNCTION get_events_by_date_and_tags(TEXT, TEXT[])
SET search_path = public, extensions;

GRANT EXECUTE ON FUNCTION get_events_by_date_and_tags TO anon, authenticated, service_role;