#!/bin/sh
# Builds the dashboard from src/hub.html:
#   app.html   - the full dashboard page
#   index.html - a tiny loader that always fetches app.html fresh, so home-screen
#                web apps on old iPads never get stuck on a cached copy.
set -e
cd "$(dirname "$0")"
STAMP=$(date -u +%Y-%m-%d\ %H:%M)
HEAD='<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, viewport-fit=cover">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<meta name="apple-mobile-web-app-title" content="Zuhause">
<meta name="theme-color" content="#0b1020">'
{
  printf '%s\n' '<!doctype html>' '<html lang="de">' '<head>' "$HEAD" '</head>' '<body>'
  sed "s/__BUILD__/$STAMP/" src/hub.html
  printf '%s\n' '</body>' '</html>'
} > app.html
cat > index.html <<HTML
<!doctype html>
<html lang="de">
<head>
$HEAD
<title>Zuhause Hub</title>
<style>html,body{margin:0;height:100%;background:#0b1020;color:#fff;font-family:-apple-system,BlinkMacSystemFont,sans-serif}#m{position:fixed;top:50%;left:0;right:0;text-align:center;opacity:.6}</style>
</head>
<body>
<div id="m">Lädt …</div>
<script>
(function () {
  function load(tries) {
    var x = new XMLHttpRequest();
    x.open('GET', 'app.html?t=' + Date.now(), true);
    x.onload = function () {
      if (x.status === 200) { document.open(); document.write(x.responseText); document.close(); }
      else retry(tries);
    };
    x.onerror = function () { retry(tries); };
    x.send();
  }
  function retry(tries) {
    document.getElementById('m').textContent = 'Home Assistant nicht erreichbar – neuer Versuch …';
    setTimeout(function () { load(tries + 1); }, Math.min(30000, 2000 * (tries + 1)));
  }
  load(0);
})();
</script>
</body>
</html>
HTML
echo "app.html ($(wc -c < app.html) bytes) and index.html (loader) written, version $STAMP"
