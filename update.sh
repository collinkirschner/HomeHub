#!/bin/sh
# Downloads the newest dashboard into Home Assistant. Run in the Terminal add-on:
#   wget -qO- https://raw.githubusercontent.com/collinkirschner/HomeHub/main/update.sh | sh
# Uses the exact latest commit, so GitHub's 5-minute raw cache never serves an old file.
set -e
SHA=$(wget -qO- https://api.github.com/repos/collinkirschner/HomeHub/commits/main | grep -m1 '"sha"' | cut -d'"' -f4)
[ -n "$SHA" ] || { echo "Konnte die neueste Version nicht ermitteln."; exit 1; }
BASE="https://raw.githubusercontent.com/collinkirschner/HomeHub/$SHA"
D=/config/www/homehub
mkdir -p $D
wget -qO $D/app.html.new "$BASE/app.html"
wget -qO $D/index.html.new "$BASE/index.html"
mv $D/app.html.new $D/app.html
mv $D/index.html.new $D/index.html
echo "Dashboard aktualisiert: Version $(grep -o "var BUILD = '[^']*'" $D/app.html | cut -d"'" -f2)"
