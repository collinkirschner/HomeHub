#!/bin/sh
# Sets up the birthday sensor (sensor.hub_geburtstage) in Home Assistant.
# Run in the Terminal add-on (see README). Asks once for the Apple ID and the
# app-specific password and stores them only on this Home Assistant (/config/hub).
set -e
D=/config/hub
mkdir -p "$D"
SHA=$(wget -qO- https://api.github.com/repos/collinkirschner/HomeHub/commits/main | grep -m1 '"sha"' | cut -d'"' -f4)
[ -n "$SHA" ] || { echo "Konnte die neueste Version nicht ermitteln."; exit 1; }
wget -qO "$D/birthdays.py" "https://raw.githubusercontent.com/collinkirschner/HomeHub/$SHA/ha/birthdays.py"

if [ ! -f "$D/icloud.json" ]; then
  printf "Apple-ID (E-Mail): "; read -r U
  printf "App-spezifisches Passwort (Eingabe unsichtbar): "; stty -echo; read -r P; stty echo; echo
  printf '{"user": "%s", "password": "%s"}\n' "$U" "$P" > "$D/icloud.json"
  chmod 600 "$D/icloud.json"
fi

CFG=/config/configuration.yaml
if grep -q "hub_geburtstage" "$CFG"; then
  echo "Sensor ist schon eingetragen."
elif grep -q "^command_line:" "$CFG"; then
  echo "Achtung: configuration.yaml enthält schon einen Abschnitt 'command_line:'. Nichts geändert, bitte Claude Bescheid geben."
  exit 1
else
  cat >> "$CFG" <<'YAML'

command_line:
  - sensor:
      name: Hub Geburtstage
      unique_id: hub_geburtstage
      command: "python3 /config/hub/birthdays.py"
      value_template: "{{ value_json.count }}"
      json_attributes:
        - birthdays
        - error
      scan_interval: 43200
      command_timeout: 60
YAML
  echo "Sensor eingetragen."
fi
echo "Prüfe Konfiguration und starte Home Assistant neu ..."
ha core check && ha core restart && echo "Fertig. In 2 Minuten ist sensor.hub_geburtstage da."
