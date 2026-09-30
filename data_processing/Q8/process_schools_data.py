#!/usr/bin/env python3
"""
Filters the raw multi-layer download (raw_clark_county_schools_all_layers.json,
produced by download_schools_data.py) down to the single layer that the live
SchoolsQueryService actually used at runtime: "CCSD Campuses".

Why only that one layer: SchoolsQueryService._pickBestSchoolLayer() picks the
first layer (in the FeatureServer's own layer order) whose name contains
"campus". Querying the live service's layer list for item
ca9eba42cebc4b0c965ffe80a3923978 gives:

    0 CCSD School Programs
    1 CCSD Campuses      <-- first name containing "campus" -> always picked
    2 Private Schools
    3 NSHE Schools
    4 Elementary_K5
    5 Middle
    6 High

So the live app's schools count has ALWAYS come from "CCSD Campuses" alone
(a polygon layer), never from the other 6 layers. This script reproduces
that exact source-of-truth for the runtime dataset instead of shipping all
1174 features from every layer (which would silently change the answer).

Usage:
    python3 process_schools_data.py
"""

import json
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
RAW_PATH = os.path.join(SCRIPT_DIR, "raw_clark_county_schools_all_layers.json")
OUT_PATH = os.path.join(SCRIPT_DIR, "assets", "data", "clark_county_schools.json")

TARGET_LAYER = "CCSD Campuses"


def main():
    with open(RAW_PATH) as f:
        raw = json.load(f)

    features = [f for f in raw["features"] if f.get("layer") == TARGET_LAYER]
    print(f"Filtered {len(features)} '{TARGET_LAYER}' features out of {len(raw['features'])} total")

    out_features = []
    for f in features:
        out_features.append(
            {
                "name": f.get("name") or "School",
                "lon": f["lon"],
                "lat": f["lat"],
                # Polygon campus footprint used for point-to-polygon distance,
                # matching the live ArcGIS spatial query (point + buffer vs.
                # polygon geometry, esriSpatialRelIntersects).
                "rings": f.get("rings"),
            }
        )

    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    with open(OUT_PATH, "w") as f:
        json.dump({"layer": TARGET_LAYER, "features": out_features}, f, separators=(",", ":"))

    size_kb = os.path.getsize(OUT_PATH) / 1024
    print(f"Written -> {OUT_PATH} ({size_kb:.0f} KB, {len(out_features)} campuses)")


if __name__ == "__main__":
    main()
