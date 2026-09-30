#!/usr/bin/env python3
"""
Rounds coordinates in the raw bike-lane/shared-use-path download to 6
decimal places (~0.11 m at this latitude — far finer than the 0.25-mile
buffer the app tests against) to shrink the bundled asset, since ArcGIS
serializes full float64 precision by default (~15-17 significant digits)
which is pure bundle-size waste for this use case.

Usage:
    python3 process_bike_lanes_data.py
"""

import json
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
IN_PATH = os.path.join(SCRIPT_DIR, "assets", "data", "clark_county_bike_lanes.json")
OUT_PATH = IN_PATH  # round in place


def main():
    with open(IN_PATH) as f:
        data = json.load(f)

    before_kb = os.path.getsize(IN_PATH) / 1024

    for feat in data["features"]:
        feat["paths"] = [
            [[round(x, 6), round(y, 6)] for x, y in path] for path in feat["paths"]
        ]

    with open(OUT_PATH, "w") as f:
        json.dump(data, f, separators=(",", ":"))

    after_kb = os.path.getsize(OUT_PATH) / 1024
    print(f"{len(data['features'])} features, {before_kb:.0f} KB -> {after_kb:.0f} KB")


if __name__ == "__main__":
    main()
