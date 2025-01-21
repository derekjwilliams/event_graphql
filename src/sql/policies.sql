-- Policies

ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_tags ENABLE ROW LEVEL SECURITY;

-- Policy to allow any user (including anon) to SELECT from the events table
CREATE POLICY "Allow public read on events"
  ON events
  FOR SELECT
  USING (true);

-- Policy to allow any user (including anon) to SELECT from the tags table
CREATE POLICY "Allow public read on tags"
  ON tags
  FOR SELECT
  USING (true);

-- Policy to allow any user (including anon) to SELECT from the event_tags table
CREATE POLICY "Allow public read on event_tags"
  ON event_tags
  FOR SELECT
  USING (true);

----------------

-- Policy to allow authenticated users to INSERT into events  

CREATE POLICY "Allow authenticated insert on events"
  ON events
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- Policy to allow authenticated users to UPDATE events
CREATE POLICY "Allow authenticated update on events"
  ON events
  FOR UPDATE
   WITH CHECK (auth.role() = 'authenticated');

-- Policy to allow authenticated users to DELETE events
CREATE POLICY "Allow authenticated delete on events"
  ON events
  FOR DELETE
   USING (auth.role() = 'authenticated');

-- Repeat the above for the 'tags' table
CREATE POLICY "Allow authenticated insert on tags"
  ON tags
  FOR INSERT
   WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated update on tags"
  ON tags
  FOR UPDATE
   USING (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated delete on tags"
  ON tags
  FOR DELETE
   USING (auth.role() = 'authenticated');

-- Repeat the above for the 'event_tags' table
CREATE POLICY "Allow authenticated insert on event_tags"
  ON event_tags
  FOR INSERT
   WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated update on event_tags"
  ON event_tags
  FOR UPDATE
   USING (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated delete on event_tags"
  ON event_tags
  FOR DELETE
   USING (auth.role() = 'authenticated');  