#!/bin/sh
# Downloads the newest dashboard into Home Assistant. Run in the Terminal add-on:
#   wget -qO- https://raw.githubusercontent.com/collinkirschner/HomeHub/main/update.sh | sh
# Uses the exact latest commit, so GitHub's 5-minute raw cache never serves an old file.
set -e
SHA=$(wget -qO- https://api.github.com/repos/collinkirschner/HomeHub/commits/main | grep -m1 '"sha"' | cut -d'"' -f4)
[ -n "$SHA" ] || { echo "Konnte die neueste Version nicht ermitteln."; exit 1; }
mkdir -p /config/www/homehub
wget -qO /config/www/homehub/index.html.new "https://raw.githubusercontent.com/collinkirschner/HomeHub/$SHA/index.html"
mv /config/www/homehub/index.html.new /config/www/homehub/index.html
echo "Dashboard aktualisiert: $(grep -o 'Version 20[0-9-]* [0-9:]*' /config/www/homehub/index.html)"
