#!/bin/bash
set -euo pipefail

# Use the find command to locate all files in the subdirectories
# The mv command then moves each file to the root directory

find . -name '*.mp3' -type f -print0 |
  xargs -0 mediainfo --Inform="General;%Title%---%Album%---%Artist%\n" |
  while IFS= read -r line; do
    echo $line
  done
