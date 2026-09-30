#!/usr/bin/env python3
"""
Downloads the 6 park polygon layers the live ParksQueryService tried, and
writes assets/data/clark_county_parks.json, keeping each feature tagged
with its source layer id so the app can reproduce the "best layer by
count" logic locally.

Original live source: ArcGIS Online item 7b483a11c0b3489d8ce7601081872f99
(Clark County GIS "Recreation" MapServer), which has 11 layers total; the
live service only ever queried layers [5, 6, 7, 8, 9, 10]:

    5  Las Vegas Parks
    6  Clark County Parks
    7  Henderson Parks
    8  Mesquite Parks
    9  Boulder City Parks
    10 North Las Vegas Parks

(Layers 0-4 — trails, GPS points, libraries, historic sites, community
centers — were never part of the parks query.)

For a given address, the live service queried all 6 park layers within a
0.5-mile buffer and kept whichever single layer returned the highest
count (ParksQueryService._bestLayerByCount) — not the sum across layers.
This script preserves the per-layer split so that logic can run locally.

Usage:
    python3 download_parks_data.py
"""

import json
import os
import requests

ARCGIS_PORTAL = "https://www.arcgis.com"
ITEM_ID = "7b483a11c0b3489d8ce7601081872f99"
PARK_LAYER_IDS = [5, 6, 7, 8, 9, 10]

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_PATH = os.path.join(SCRIPT_DIR, "assets", "data", "clark_county_parks.json")


def resolve_service_url(item_id):
    print("Step 1: Resolving feature service URL...")
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


def list_layers(service_url):
    r = requests.get(service_url.rstrip("/"), params={"f": "json"}, timeout=60)
    r.raise_for_status()
    return {l["id"]: l.get("name", f"Layer {l['id']}") for l in r.json().get("layers", [])}


def query_all_features(layer_url):
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
        if len(feats) < page_size:
            break
        offset += page_size
    return all_features


def main():
    service_url = resolve_service_url(ITEM_ID)
    print(f"  Service URL: {service_url}")
    layer_names = list_layers(service_url)

    out_features = []
    for layer_id in PARK_LAYER_IDS:
        layer_name = layer_names.get(layer_id, f"Layer {layer_id}")
        layer_url = f"{service_url.rstrip('/')}/{layer_id}"
        print(f"Step 2: Querying layer {layer_id} ({layer_name})...")
        raw = query_all_features(layer_url)
        print(f"  Got {len(raw)} features")

        for f in raw:
            geom = f.get("geometry")
            attrs = f.get("attributes", {})
            if not geom or "rings" not in geom or not geom["rings"]:
                continue
            name = None
            for key in ["NAME", "NAME1", "PARK_NAME", "SITE_NAME"]:
                if attrs.get(key):
                    name = str(attrs[key])
                    break
            out_features.append(
                {
                    "layerId": layer_id,
                    "layerName": layer_name,
                    "name": name or "Park",
                    "rings": geom["rings"],
                }
            )

    print(f"Step 3: Writing {len(out_features)} park polygons...")
    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    with open(OUT_PATH, "w") as fh:
        json.dump({"features": out_features}, fh, separators=(",", ":"))

    size_kb = os.path.getsize(OUT_PATH) / 1024
    print(f"Written -> {OUT_PATH} ({size_kb:.0f} KB)")


if __name__ == "__main__":
    main()
