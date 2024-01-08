#!/bin/bash
set -euo pipefail
# set -v

DB_NAME='archive.db'

# Use the find command to locate all files in the subdirectories
# The mv command then moves each file to the root directory

for dir in ./ipods/*/; do
  # Get the name of the folder, and escape any single quotes in it
  ipod_name=$(basename "$dir" | sed "s/'/''/g")
  ipod_id=$(sqlite3 -init /dev/null "$DB_NAME" "INSERT INTO ipods(name) VALUES('$ipod_name') RETURNING ipod_id" 2>/dev/null)

  echo "Archiving the tracks on $ipod_name"
  find "$dir" -name '*.mp3' -type f -print0 |
    xargs -0 mediainfo --Inform="General;%Title%~%Album%~%Artist%\n" |
    while IFS= read -r line; do
      IFS="~" read -r title album artist
      title=$(echo "$title" |  sed "s/'/''/g")
      album=$(echo "$album" |  sed "s/'/''/g")
      artist=$(echo "$artist" |  sed "s/'/''/g")
      sqlite3 -init /dev/null "$DB_NAME" 2>/dev/null <<EOF
      INSERT INTO songs(ipod_id, title, album, artist)
      VALUES ($ipod_id, '$title', '$album', '$artist');
EOF
    done

done
