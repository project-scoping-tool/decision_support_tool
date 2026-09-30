#!/usr/bin/env python3
"""
Run this script ONCE on your local machine to build:
    assets/data/nevada_walking_rate.json

Requirements:  pip install requests

Usage:
    cd data_processing/Q3_walking_rate
    python3 download_walking_rate_data.py

Original live source: WalkingRateDrawingService queried Census TIGERweb
(tract geometry) and the Census ACS5 subject API (S0801_C01_010E,
walk-to-work %) live, for whatever tracts intersected the user's drawn
polygon. This script downloads the same tract geometries + rates for
Clark + Washoe counties up front (see
data_processing/_shared/census_tracts.py) — every jurisdiction that uses
`walking-rate`/`walking-rate-washoe` is in one of those two counties.
"""

import json
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "_shared"))
import census_tracts  # noqa: E402

ACS_YEAR = 2022
ACS_VAR = "S0801_C01_010E"  # % who walk to work

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_PATH = os.path.join(SCRIPT_DIR, "assets", "data", "nevada_walking_rate.json")


def main():
    tracts = census_tracts.download_tract_geometries()
    rates = census_tracts.download_acs_rates(ACS_VAR, ACS_YEAR)
    geojson = census_tracts.merge(tracts, rates, "walkRate")

    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    with open(OUT_PATH, "w") as f:
        json.dump(geojson, f, separators=(",", ":"))
    size_kb = os.path.getsize(OUT_PATH) / 1024
    print(f"Written -> {OUT_PATH} ({size_kb:.0f} KB)")
    print()
    print("Make sure pubspec.yaml includes:")
    print("  flutter:")
    print("    assets:")
    print("      - assets/data/nevada_walking_rate.json")


if __name__ == "__main__":
    main()
