#!/usr/bin/env python3
"""Reads birthdays from iCloud contacts (CardDAV) and prints them as JSON.

Used by a Home Assistant command_line sensor (sensor.hub_geburtstage). Credentials
come from /config/hub/icloud.json: {"user": "...", "password": "<app-specific password>"}.
Only the standard library is used, so it runs inside the Home Assistant container.
"""
import base64
import json
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET

CONFIG = sys.argv[1] if len(sys.argv) > 1 else "/config/hub/icloud.json"
START = "https://contacts.icloud.com/"
NS = {"d": "DAV:", "c": "urn:ietf:params:xml:ns:carddav"}


def request(method, url, auth, body=None, depth="0", hops=5):
    data = body.encode("utf-8") if body else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Authorization", "Basic " + auth)
    req.add_header("Depth", depth)
    req.add_header("Content-Type", "application/xml; charset=utf-8")
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return resp.geturl(), resp.read().decode("utf-8", "replace")
    except urllib.error.HTTPError as err:
        if err.code in (301, 302, 307, 308) and hops > 0 and err.headers.get("Location"):
            return request(method, urllib.parse.urljoin(url, err.headers["Location"]), auth, body, depth, hops - 1)
        raise


def propfind(url, auth, prop, depth="0"):
    body = '<?xml version="1.0"?><d:propfind xmlns:d="DAV:" xmlns:c="urn:ietf:params:xml:ns:carddav"><d:prop>%s</d:prop></d:propfind>' % prop
    final, text = request("PROPFIND", url, auth, body, depth)
    return final, ET.fromstring(text)


def first_href(tree, path):
    el = tree.find(".//" + path + "/d:href", NS)
    return el.text.strip() if el is not None and el.text else None


def unfold(card):
    return re.sub(r"\r?\n[ \t]", "", card).splitlines()


def parse_bday(line):
    key, _, value = line.partition(":")
    value = value.strip()
    omit = "X-APPLE-OMIT-YEAR" in key.upper()
    m = re.match(r"^(\d{4})-?(\d{2})-?(\d{2})", value)
    if m:
        year, month, day = int(m.group(1)), int(m.group(2)), int(m.group(3))
        if omit or year <= 1604:
            year = None
        return year, month, day
    m = re.match(r"^--(\d{2})-?(\d{2})", value)
    if m:
        return None, int(m.group(1)), int(m.group(2))
    return None


def birthdays_from_cards(cards):
    out = []
    for card in cards:
        name, bday = None, None
        for line in unfold(card):
            upper = line.upper()
            if upper.startswith("FN:") or upper.startswith("FN;"):
                name = line.partition(":")[2].strip().replace("\\,", ",")
            elif upper.startswith("BDAY"):
                bday = parse_bday(line)
        if name and bday:
            year, month, day = bday
            out.append({"name": name, "month": month, "day": day, "year": year})
    out.sort(key=lambda b: (b["month"], b["day"], b["name"]))
    return out


def main():
    with open(CONFIG, encoding="utf-8") as fh:
        cfg = json.load(fh)
    auth = base64.b64encode(("%s:%s" % (cfg["user"], cfg["password"])).encode("utf-8")).decode("ascii")

    base, tree = propfind(START, auth, "<d:current-user-principal/>")
    principal = urllib.parse.urljoin(base, first_href(tree, "d:current-user-principal"))
    base, tree = propfind(principal, auth, "<c:addressbook-home-set/>")
    home = urllib.parse.urljoin(base, first_href(tree, "c:addressbook-home-set"))
    base, tree = propfind(home, auth, "<d:resourcetype/>", depth="1")

    books = []
    for resp in tree.findall("d:response", NS):
        if resp.find(".//d:resourcetype/c:addressbook", NS) is not None:
            books.append(urllib.parse.urljoin(base, resp.find("d:href", NS).text.strip()))

    query = ('<?xml version="1.0"?><c:addressbook-query xmlns:d="DAV:" xmlns:c="urn:ietf:params:xml:ns:carddav">'
             '<d:prop><c:address-data/></d:prop></c:addressbook-query>')
    cards = []
    for book in books:
        _, text = request("REPORT", book, auth, query, depth="1")
        for el in ET.fromstring(text).iter("{urn:ietf:params:xml:ns:carddav}address-data"):
            if el.text:
                cards.append(el.text)

    result = birthdays_from_cards(cards)
    print(json.dumps({"count": len(result), "birthdays": result}, ensure_ascii=False))


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:  # report errors as a readable state instead of crashing the sensor
        print(json.dumps({"count": 0, "birthdays": [], "error": str(exc)[:200]}))
