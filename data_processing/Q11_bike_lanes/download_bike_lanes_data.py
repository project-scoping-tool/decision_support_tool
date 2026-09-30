#!/usr/bin/env python3
"""
Downloads RTC bike lane and shared-use-path line geometries and writes
assets/data/clark_county_bike_lanes.json.

Original live source: BikeLanesQueryService queried two ArcGIS Online
items, each resolving to a single polyline FeatureServer layer on the same
RTC "HUB" service used for bus stops (Q10):

    bike lanes        ae77a3326fe64b788618c2f29988ebeb -> HUB/FeatureServer/9
    shared use paths   222b1b87a5984a29ad801c3a55aea778 -> HUB/FeatureServer/10

...and summed the 0.25-mile-radius counts from both. This script downloads
every line from both layers, tagged by kind, so the app can reproduce that
locally.

Usage:
    python3 download_bike_lanes_data.py
"""

import json
import os
import requests

ARCGIS_PORTAL = "https://www.arcgis.com"
ITEMS = {
    "bike_lane": "ae77a3326fe64b788618c2f29988ebeb",
    "shared_use_path": "222b1b87a5984a29ad801c3a55aea778",
}

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_PATH = os.path.join(SCRIPT_DIR, "assets", "data", "clark_county_bike_lanes.json")


def resolve_service_url(item_id):
    r = requests.get(
        f"{ARCGIS_PORTAL}/sharing/rest/content/items/{item_id}",
        params={"f": "json"},
        timeout=60,
    )
    r.raise_for_status()
    item = r.json()
    if item.get("url"):
        return item["url"]
    raise Exception("Could not resolve service URL")


def query_all_lines(layer_url):
    all_features = []
    offset = 0
    page_size = 1000
    while True:
        params = {
            "f": "json",
            "where": "1=1",
            "outFields": "*",
            "returnGeometry": "true",
            "outSR": "4326",
            "resultOffset": offset,
            "resultRecordCount": page_size,
        }
        r = requests.get(f"{layer_url.rstrip('/')}/query", params=params, timeout=60)
        r.raise_for_status()
        data = r.json()
        if "error" in data:
            raise Exception(f"ArcGIS error: {data['error']}")
        feats = data.get("features", [])
        all_features.extend(feats)
        print(f"  Got {len(feats)} (total {len(all_features)})")
        if len(feats) < page_size:
            break
        offset += page_size
    return all_features


def main():
    out_features = []
    for kind, item_id in ITEMS.items():
        print(f"Resolving {kind} ({item_id})...")
        service_url = resolve_service_url(item_id)
        print(f"  Service URL: {service_url}")
        raw = query_all_lines(service_url)

        for f in raw:
            geom = f.get("geometry")
            if not geom or "paths" not in geom or not geom["paths"]:
                continue
            out_features.append({"kind": kind, "paths": geom["paths"]})

    print(f"Writing {len(out_features)} line features...")
    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    with open(OUT_PATH, "w") as fh:
        json.dump({"features": out_features}, fh, separators=(",", ":"))

    size_kb = os.path.getsize(OUT_PATH) / 1024
    print(f"Written -> {OUT_PATH} ({size_kb:.0f} KB)")


if __name__ == "__main__":
    main()
