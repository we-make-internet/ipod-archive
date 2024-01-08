#!/bin/bash
set -euo pipefail

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
  find "$dir" -type f -print0 |
    xargs -0 mediainfo --Inform="General;%Title%~%Album%~%Artist%\n" |
    sql_escape |
    grep -v '^~~$' |
    awk -F '~' "{printf(\"%s($ipod_id, '%s', '%s', '%s')\n\", NR==1 ? \"\" : \",\", \$1, \$2, \$3)}" |
    { echo "INSERT INTO songs(ipod_id, title, album, artist) VALUES"; cat; echo ';'; } |
    sqlite3 -init /dev/null "$DB_NAME"
done
