# HomeHub

Wand-Dashboard im Liquid-Glass-Stil für ein altes iPad (getestet auf Safari 12 / iOS 12).
Steuert Licht, Szenen, Sonos, Thermostat, Türschloss und Klingel über Home Assistant
und zeigt im Standby Uhr, Wetter und Termine.

## Dateien

- `src/hub.html` – Quellcode (HTML, CSS und JavaScript in einer Datei)
- `build.sh` – baut daraus `app.html` (das Dashboard) und `index.html` (Startseite, die `app.html` immer frisch lädt)
- `update.sh` – spielt die neueste Version in Home Assistant ein

## Ändern

1. `src/hub.html` bearbeiten
2. `./build.sh` ausführen
3. `src/hub.html`, `app.html` und `index.html` committen

## In Home Assistant aktualisieren

Im Terminal-Add-on:

```
wget -qO- https://raw.githubusercontent.com/collinkirschner/HomeHub/main/update.sh | sh
```

Das Dashboard auf dem iPad prüft stündlich, ob eine neue Version installiert ist, und lädt sich dann selbst neu.

## Auf dem iPad

1. Seite in Safari öffnen, dann Teilen › Zum Home-Bildschirm
2. Einstellungen › Anzeige & Helligkeit › Automatische Sperre › Nie
3. Ohne Verbindung läuft die Seite im Demo-Modus mit Beispielgeräten.
   Unter Einstellungen › Verbindung lässt sich Home Assistant (Adresse und
   langlebiger Zugriffstoken) eintragen.

Hinweis: Wird die Seite über GitHub Pages (https) geladen, blockiert der Browser
Verbindungen zu einem Home Assistant mit `http://`-Adresse. Für den Live-Betrieb
das Dashboard deshalb mit `update.sh` in Home Assistant installieren und auf dem
iPad `http://homeassistant.local/local/homehub/index.html` öffnen.

## Geburtstage aus iCloud-Kontakten

`ha/birthdays.py` liest die Geburtstage aus den iCloud-Kontakten (CardDAV) und stellt
sie als `sensor.hub_geburtstage` bereit. Einmalig im Terminal-Add-on einrichten:

```
SHA=$(wget -qO- https://api.github.com/repos/collinkirschner/HomeHub/commits/main | grep -m1 '"sha"' | cut -d'"' -f4); wget -qO /tmp/hub-bday.sh "https://raw.githubusercontent.com/collinkirschner/HomeHub/$SHA/ha/install-birthdays.sh" && sh /tmp/hub-bday.sh
```

Das Skript fragt einmal nach Apple-ID und app-spezifischem Passwort und speichert sie nur
auf dem Home Assistant (`/config/hub/icloud.json`).
