#!/usr/bin/env python3
"""
Downloads RTC (Regional Transportation Commission) bus stop point locations
and writes assets/data/clark_county_bus_stops.json.

Original live source: BusStopsQueryService queried ArcGIS Online item
3a1fde0a9b9a49e98574e0c6322a088f, resolving it to a single point
FeatureServer layer (webgis.rtcsnv.com/.../HUB/FeatureServer/0) and doing a
0.25-mile radius count query against it per address. This script downloads
every point in that same layer once, so the app can do the same radius
count locally.

Usage:
    python3 download_bus_stops_data.py
"""

import json
import os
import requests

ARCGIS_PORTAL = "https://www.arcgis.com"
ITEM_ID = "3a1fde0a9b9a49e98574e0c6322a088f"  # Bus stops item

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_PATH = os.path.join(SCRIPT_DIR, "assets", "data", "clark_county_bus_stops.json")


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

    r = requests.get(
        f"{ARCGIS_PORTAL}/sharing/rest/content/items/{item_id}/data",
        params={"f": "json"},
        timeout=60,
    )
    r.raise_for_status()
    webmap = r.json()
    for layer in webmap.get("operationalLayers", []):
        url = layer.get("url", "")
        if "MapServer" in url or "FeatureServer" in url:
            return url
    raise Exception("Could not resolve service URL")


def query_all_points(layer_url):
    print(f"Step 2: Paging through all features at {layer_url} ...")
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
    service_url = resolve_service_url(ITEM_ID)
    print(f"  Service URL: {service_url}")

    raw_features = query_all_points(service_url)

    out_features = []
    for f in raw_features:
        geom = f.get("geometry")
        if not geom or "x" not in geom or "y" not in geom:
            continue
        attrs = f.get("attributes", {})
        name = None
        for key in ["STOP_NAME", "NAME", "Name", "STOPNAME"]:
            if attrs.get(key):
                name = str(attrs[key])
                break
        out_features.append(
            {"lon": geom["x"], "lat": geom["y"], "name": name or "Bus Stop"}
        )

    print(f"Step 3: Writing {len(out_features)} bus stop points...")
    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    with open(OUT_PATH, "w") as fh:
        json.dump({"features": out_features}, fh, separators=(",", ":"))

    size_kb = os.path.getsize(OUT_PATH) / 1024
    print(f"Written -> {OUT_PATH} ({size_kb:.0f} KB)")


if __name__ == "__main__":
    main()
