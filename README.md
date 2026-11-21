# HomeHub

Wand-Dashboard im Liquid-Glass-Stil für ein altes iPad (getestet auf Safari 12 / iOS 12).
Steuert Licht, Szenen, Sonos, Thermostat, Türschloss und Klingel über Home Assistant
und zeigt im Standby Uhr, Wetter und Termine.

## Dateien

- `src/hub.html` – Quellcode (HTML, CSS und JavaScript in einer Datei)
- `build.sh` – baut daraus `index.html`
- `index.html` – fertige Seite, wird von GitHub Pages ausgeliefert

## Ändern

1. `src/hub.html` bearbeiten
2. `./build.sh` ausführen
3. Beide Dateien committen

## Auf dem iPad

1. Seite in Safari öffnen, dann Teilen › Zum Home-Bildschirm
2. Einstellungen › Anzeige & Helligkeit › Automatische Sperre › Nie
3. Ohne Verbindung läuft die Seite im Demo-Modus mit Beispielgeräten.
   Unter Einstellungen › Verbindung lässt sich Home Assistant (Adresse und
   langlebiger Zugriffstoken) eintragen.

Hinweis: Wird die Seite über GitHub Pages (https) geladen, blockiert der Browser
Verbindungen zu einem Home Assistant mit `http://`-Adresse. Für den Live-Betrieb
`index.html` deshalb in Home Assistant unter `config/www/homehub/` ablegen und auf
dem iPad `http://homeassistant.local:8123/local/homehub/index.html` öffnen.
