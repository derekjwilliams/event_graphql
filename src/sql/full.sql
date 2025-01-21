-- DROP SCHEMA public;

CREATE SCHEMA public AUTHORIZATION pg_database_owner;

COMMENT ON SCHEMA public IS 'standard public schema';

-- DROP SEQUENCE public.events_id_seq;

CREATE SEQUENCE public.events_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE public.events_id_seq OWNER TO postgres;
GRANT ALL ON SEQUENCE public.events_id_seq TO postgres;
GRANT ALL ON SEQUENCE public.events_id_seq TO anon;
GRANT ALL ON SEQUENCE public.events_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.events_id_seq TO service_role;

-- DROP SEQUENCE public.tags_id_seq;

CREATE SEQUENCE public.tags_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE public.tags_id_seq OWNER TO postgres;
GRANT ALL ON SEQUENCE public.tags_id_seq TO postgres;
GRANT ALL ON SEQUENCE public.tags_id_seq TO anon;
GRANT ALL ON SEQUENCE public.tags_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.tags_id_seq TO service_role;
-- public.events definition

-- Drop table

-- DROP TABLE public.events;

CREATE TABLE public.events (
	id serial4 NOT NULL,
	title varchar(255) NOT NULL,
	description text NULL,
	"content" text NULL,
	link text NULL,
	author text NULL,
	pub_date timestamptz NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT events_pkey PRIMARY KEY (id)
);

-- Permissions

ALTER TABLE public.events OWNER TO postgres;
GRANT ALL ON TABLE public.events TO postgres;
GRANT ALL ON TABLE public.events TO anon;
GRANT ALL ON TABLE public.events TO authenticated;
GRANT ALL ON TABLE public.events TO service_role;


-- public.tags definition

-- Drop table

-- DROP TABLE public.tags;

CREATE TABLE public.tags (
	id serial4 NOT NULL,
	"name" varchar(255) NOT NULL,
	CONSTRAINT tags_name_key UNIQUE (name),
	CONSTRAINT tags_pkey PRIMARY KEY (id)
);
CREATE INDEX idx_tags_name ON public.tags USING btree (name);

-- Permissions

ALTER TABLE public.tags OWNER TO postgres;
GRANT ALL ON TABLE public.tags TO postgres;
GRANT ALL ON TABLE public.tags TO anon;
GRANT ALL ON TABLE public.tags TO authenticated;
GRANT ALL ON TABLE public.tags TO service_role;


-- public.event_tags definition

-- Drop table

-- DROP TABLE public.event_tags;

CREATE TABLE public.event_tags (
	event_id int4 NOT NULL,
	tag_id int4 NOT NULL,
	CONSTRAINT event_tags_pkey PRIMARY KEY (event_id, tag_id),
	CONSTRAINT event_tags_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE,
	CONSTRAINT event_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE
);

-- Permissions

ALTER TABLE public.event_tags OWNER TO postgres;
GRANT ALL ON TABLE public.event_tags TO postgres;
GRANT ALL ON TABLE public.event_tags TO anon;
GRANT ALL ON TABLE public.event_tags TO authenticated;
GRANT ALL ON TABLE public.event_tags TO service_role;



-- DROP FUNCTION public.get_all_events();

CREATE OR REPLACE FUNCTION public.get_all_events()
 RETURNS SETOF events
 LANGUAGE plpgsql
 STABLE
 SET search_path TO 'public', 'extensions'
AS $function$
BEGIN
  RETURN QUERY SELECT * FROM events;
END;
$function$
;

COMMENT ON FUNCTION public.get_all_events() IS '@graphqlName getAllEvents';

-- Permissions

ALTER FUNCTION public.get_all_events() OWNER TO postgres;
GRANT ALL ON FUNCTION public.get_all_events() TO public;
GRANT ALL ON FUNCTION public.get_all_events() TO postgres;
GRANT ALL ON FUNCTION public.get_all_events() TO anon;
GRANT ALL ON FUNCTION public.get_all_events() TO authenticated;
GRANT ALL ON FUNCTION public.get_all_events() TO service_role;

-- DROP FUNCTION public.get_events_by_date(text);

CREATE OR REPLACE FUNCTION public.get_events_by_date(p_pub_date text)
 RETURNS SETOF events
 LANGUAGE plpgsql
 STABLE
 SET search_path TO 'public', 'extensions'
AS $function$
BEGIN
  RETURN QUERY
  SELECT * FROM events e
  WHERE e.pub_date > p_pub_date::TIMESTAMP WITH TIME ZONE;
END;
$function$
;

COMMENT ON FUNCTION public.get_events_by_date(text) IS '@graphqlName getEventsByDate 
@param pPubDate: String';

-- Permissions

ALTER FUNCTION public.get_events_by_date(text) OWNER TO postgres;
GRANT ALL ON FUNCTION public.get_events_by_date(text) TO public;
GRANT ALL ON FUNCTION public.get_events_by_date(text) TO postgres;
GRANT ALL ON FUNCTION public.get_events_by_date(text) TO anon;
GRANT ALL ON FUNCTION public.get_events_by_date(text) TO authenticated;
GRANT ALL ON FUNCTION public.get_events_by_date(text) TO service_role;

-- DROP FUNCTION public.get_events_by_date_and_tags(text, _text);

CREATE OR REPLACE FUNCTION public.get_events_by_date_and_tags(p_pub_date text, p_tag_names text[])
 RETURNS SETOF events
 LANGUAGE plpgsql
 STABLE
 SET search_path TO 'public', 'extensions'
AS $function$
BEGIN
  RETURN QUERY
  SELECT e.* 
  FROM events e
  JOIN event_tags et ON e.id = et.event_id
  JOIN tags t ON et.tag_id = t.id
  WHERE e.pub_date > p_pub_date::TIMESTAMP WITH TIME ZONE
  AND t.name = ANY(p_tag_names);
END;
$function$
;

COMMENT ON FUNCTION public.get_events_by_date_and_tags(text, _text) IS '@graphqlName getEventsByTagsAndDate 
@param pPubDate: DateTime 
@param pTagNames: [String!]!';

-- Permissions

ALTER FUNCTION public.get_events_by_date_and_tags(text, _text) OWNER TO postgres;
GRANT ALL ON FUNCTION public.get_events_by_date_and_tags(text, _text) TO public;
GRANT ALL ON FUNCTION public.get_events_by_date_and_tags(text, _text) TO postgres;
GRANT ALL ON FUNCTION public.get_events_by_date_and_tags(text, _text) TO anon;
GRANT ALL ON FUNCTION public.get_events_by_date_and_tags(text, _text) TO authenticated;
GRANT ALL ON FUNCTION public.get_events_by_date_and_tags(text, _text) TO service_role;


-- Permissions

GRANT ALL ON SCHEMA public TO pg_database_owner;
GRANT USAGE ON SCHEMA public TO public;
GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT INSERT, TRUNCATE, REFERENCES, SELECT, DELETE, TRIGGER, UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT INSERT, TRUNCATE, REFERENCES, SELECT, DELETE, TRIGGER, UPDATE ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT INSERT, TRUNCATE, REFERENCES, SELECT, DELETE, TRIGGER, UPDATE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT INSERT, TRUNCATE, REFERENCES, SELECT, DELETE, TRIGGER, UPDATE ON TABLES TO service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT EXECUTE ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT EXECUTE ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT EXECUTE ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT EXECUTE ON FUNCTIONS TO service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, USAGE, UPDATE ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, USAGE, UPDATE ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, USAGE, UPDATE ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, USAGE, UPDATE ON SEQUENCES TO service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, USAGE, UPDATE ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, USAGE, UPDATE ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, USAGE, UPDATE ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, USAGE, UPDATE ON SEQUENCES TO service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT INSERT, TRUNCATE, REFERENCES, SELECT, DELETE, TRIGGER, UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT INSERT, TRUNCATE, REFERENCES, SELECT, DELETE, TRIGGER, UPDATE ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT INSERT, TRUNCATE, REFERENCES, SELECT, DELETE, TRIGGER, UPDATE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT INSERT, TRUNCATE, REFERENCES, SELECT, DELETE, TRIGGER, UPDATE ON TABLES TO service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT EXECUTE ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT EXECUTE ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT EXECUTE ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT EXECUTE ON FUNCTIONS TO service_role;