#!/usr/bin/env python3
"""Find the OsmAnd-misc polygons (osm-planet/polygons) containing a point or an OSM object.

Usage:
  find_poly.py 55.7558,37.6173
  find_poly.py 55.7558 37.6173
  find_poly.py "https://www.openstreetmap.org/node/12345"
  find_poly.py "https://www.openstreetmap.org/way/12345"
  find_poly.py "https://www.openstreetmap.org/relation/12345"
  find_poly.py "https://www.openstreetmap.org/#map=15/55.7558/37.6173"
  find_poly.py --osm node/12345
"""

import argparse
import json
import math
import re
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path

POLY_ROOT = Path.home() / "git" / "OsmAnd-misc" / "osm-planet" / "polygons"
OVERPASS = "https://maps.mail.ru/osm/tools/overpass/api/interpreter"

OSM_URL_RE = re.compile(r"openstreetmap\.org/(node|way|relation)/(\d+)", re.I)
MAP_URL_RE = re.compile(r"#map=\d+(?:\.\d+)?/(-?\d+(?:\.\d+)?)/(-?\d+(?:\.\d+)?)")
COORD_RE = re.compile(
    r"^\s*(-?\d+(?:\.\d+)?)[\s,;]+(-?\d+(?:\.\d+)?)\s*$")


# ---------- .poly ----------

def parse_poly(path):
    """-> list of polygons, each a list of rings (ring = list of (lat, lon)).

    Osmosis .poly format: each ring is a block of coordinates terminated by END;
    a bare number starts a new polygon, "!N" marks a hole of polygon N."""
    with open(path, encoding="utf-8", errors="replace") as f:
        lines = f.readlines()
    polys = []   # polys[i] = [outer ring, holes...]
    ring = []
    hole_of = None  # index of the polygon owning the current hole
    for line in lines[1:]:  # first line is the name
        s = line.strip()
        if not s:
            continue
        if s == "END":
            if ring:
                if hole_of is not None and hole_of >= 0:
                    polys[hole_of].append(ring)
                else:
                    polys.append([ring])
                ring = []
            continue
        if line[0] != " " and s.lstrip("!").isdigit():
            hole_of = len(polys) - 1 if s.startswith("!") else None
            continue
        parts = s.split()
        if len(parts) != 2:
            continue
        try:
            # .poly format stores "lon lat" — store as (lat, lon)
            ring.append((float(parts[1]), float(parts[0])))
        except ValueError:
            continue
    return polys


def ring_bbox(ring):
    lats = [p[0] for p in ring]
    lons = [p[1] for p in ring]
    return min(lats), min(lons), max(lats), max(lons)


def bbox_contains(bb, lat, lon):
    return bb[0] <= lat <= bb[2] and bb[1] <= lon <= bb[3]


def point_in_ring(ring, lat, lon):
    """Ray casting. ring: list of (lat, lon)."""
    inside = False
    n = len(ring)
    j = n - 1
    for i in range(n):
        yi, xi = ring[i]
        yj, xj = ring[j]
        if ((xi > lon) != (xj > lon)) and (
                lat < (yj - yi) * (lon - xi) / (xj - xi) + yi):
            inside = not inside
        j = i
    return inside


def point_in_poly(polys, lat, lon):
    for rings in polys:
        if not rings:
            continue
        if bbox_contains(ring_bbox(rings[0]), lat, lon) and \
                point_in_ring(rings[0], lat, lon) and \
                not any(point_in_ring(r, lat, lon) for r in rings[1:]):
            return True
    return False


# ---------- input ----------

def parse_osm_ref(text):
    m = OSM_URL_RE.search(text)
    if m:
        return m.group(1), m.group(2)
    return None


def resolve_osm(osm_type, osm_id):
    q = f"[out:json];{osm_type}({osm_id});out center;"
    data = urllib.parse.urlencode({"data": q}).encode()
    j = None
    for attempt in range(1, 6):
        req = urllib.request.Request(OVERPASS, data=data, method="POST")
        try:
            with urllib.request.urlopen(req, timeout=90) as resp:
                j = json.load(resp)
            break
        except Exception as e:
            print(f"Overpass API unavailable (attempt {attempt}/5): {e}",
                  file=sys.stderr)
            time.sleep(10 * attempt)
    if j is None:
        sys.exit("Overpass API is not responding, try again later")
    els = j.get("elements", [])
    if not els:
        sys.exit(f"Object {osm_type}/{osm_id} not found in Overpass API")
    el = els[0]
    if "lat" in el:
        return el["lat"], el["lon"]
    c = el.get("center")
    if c:
        return c["lat"], c["lon"]
    sys.exit(f"Object {osm_type}/{osm_id} has no coordinates/center")


def parse_coords(text):
    m = MAP_URL_RE.search(text)
    if m:
        return float(m.group(1)), float(m.group(2))
    m = COORD_RE.match(text)
    if m:
        lat, lon = float(m.group(1)), float(m.group(2))
        if abs(lat) > 90 and abs(lon) <= 90:  # lon,lat -> lat,lon
            lat, lon = lon, lat
        return lat, lon
    return None


def resolve_input(arg, osm_arg):
    if osm_arg:
        m = re.match(r"(node|way|relation)/(\d+)", osm_arg, re.I)
        if not m:
            sys.exit(f"Invalid --osm format: {osm_arg} (expected node/123)")
        return resolve_osm(m.group(1).lower(), m.group(2))
    coords = parse_coords(arg)
    if coords:
        # coordinates embedded in the link take precedence over an Overpass lookup
        return coords
    ref = parse_osm_ref(arg)
    if ref:
        return resolve_osm(*ref)
    sys.exit(f"Could not parse input: {arg}")


# ---------- main ----------

def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("input", nargs="*", help="coordinates or an OSM object link")
    ap.add_argument("--osm", help="object as node/123, way/123, relation/123")
    args, extra = ap.parse_known_args()
    if any(not COORD_RE.match(t) for t in extra):
        ap.error(f"unknown arguments: {' '.join(extra)}")
    args.input += extra

    if not args.input and not args.osm:
        ap.error("an argument is required: coordinates or an OSM object link")

    lat, lon = resolve_input(" ".join(args.input), args.osm)
    print(f"Point: {lat:.6f}, {lon:.6f}", file=sys.stderr)

    found = []
    for poly in sorted(POLY_ROOT.rglob("*.poly")):
        polys = parse_poly(poly)
        if not point_in_poly(polys, lat, lon):
            continue
        rel = poly.relative_to(POLY_ROOT).with_suffix("")
        bbox_area = ring_bbox(polys[0][0]) if polys and polys[0] else None
        area = (bbox_area[2] - bbox_area[0]) * (bbox_area[3] - bbox_area[1]) \
            if bbox_area else 0
        found.append((len(rel.parts), -area, str(rel)))

    if not found:
        print("Point is not inside any polygon")
        return
    for _, _, rel in sorted(found):
        print(rel)


if __name__ == "__main__":
    main()
