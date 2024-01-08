#!/bin/bash
set -euo pipefail
# set -v

DB_NAME='archive.db'

function sql_escape {
  sed "s/'/''/g"
}

for dir in ./ipods/*/; do
  # Get the name of the folder, and escape any single quotes in it
  ipod_name=$(basename "$dir" | sql_escape)
  ipod_insert_query="INSERT INTO ipods(name) VALUES('$ipod_name') RETURNING ipod_id;"
  ipod_id=$(sqlite3 -init /dev/null "$DB_NAME" "$ipod_insert_query" 2>/dev/null)

  echo "Archiving the tracks on $ipod_name"
  find "$dir" -name '*.mp3' -type f -print0 |
    xargs -0 mediainfo --Inform="General;%Title%~%Album%~%Artist%\n" |
    while IFS= read -r line; do
      IFS="~" read -r title album artist
      title=$(echo "$title" | sql_escape)
      album=$(echo "$album" | sql_escape)
      artist=$(echo "$artist" | sql_escape)
      sqlite3 -init /dev/null "$DB_NAME" 2>/dev/null <<EOF
      INSERT INTO songs(ipod_id, title, album, artist)
      VALUES ($ipod_id, '$title', '$album', '$artist');
EOF
    done

done