CREATE TABLE ipods (
  ipod_id INTEGER PRIMARY KEY,
  name TEXT
);

CREATE TABLE songs (
  ipod_id TEXT REFERENCES ipods,
  title TEXT,
  artist TEXT,
  album TEXT
);
