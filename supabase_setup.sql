CREATE TABLE IF NOT EXISTS words (
  id SERIAL PRIMARY KEY,
  word TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO words (word) VALUES 
  ('darkrippers'),
  ('kirito'),
  ('eromechi'),
  ('pablini'),
  ('secuaz'),
  ('nino'),
  ('celismor'),
  ('wesuangelito')
ON CONFLICT (word) DO NOTHING;

ALTER TABLE words ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access" ON words;

CREATE POLICY "Allow public read access"
  ON words
  FOR SELECT
  USING (true);

CREATE TABLE IF NOT EXISTS game_users (
  id SERIAL PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  best_score INTEGER DEFAULT 0,
  games_completed INTEGER DEFAULT 0,
  last_played TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS game_sessions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES game_users(id),
  words_found INTEGER DEFAULT 0,
  score INTEGER NOT NULL,
  completed_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS discovered_words_log (
  id SERIAL PRIMARY KEY,
  session_id INTEGER REFERENCES game_sessions(id),
  word TEXT NOT NULL,
  discovered_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE game_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE discovered_words_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read/write users" ON game_users;
DROP POLICY IF EXISTS "Allow public read/write sessions" ON game_sessions;
DROP POLICY IF EXISTS "Allow public read/write words log" ON discovered_words_log;

CREATE POLICY "Allow public read/write users"
  ON game_users
  FOR ALL
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow public read/write sessions"
  ON game_sessions
  FOR ALL
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow public read/write words log"
  ON discovered_words_log
  FOR ALL
  USING (true)
  WITH CHECK (true);

SELECT * FROM words ORDER BY word;
