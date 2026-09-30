#!/usr/bin/env python3
"""
Run this script ONCE on your local machine to build:
    assets/data/nevada_activity_density.json

Requirements:  pip install requests

Usage:
    cd data_processing/Q7_activity_density
    python3 download_activity_density_data.py

Original live source: ActivityDensityDrawingService queried the EPA Smart
Location Database (SLD) MapServer Layer 4 ("Employment and housing
density", field D1D — housing units + jobs per acre, nationwide) live for
whatever block groups intersected the user-drawn polygon, plus fetched the
renderer's live class-break colors/labels on every use.

This script downloads every Clark + Washoe County block group up front
(server-side filtered via STATEFP/COUNTYFP) using the shared helper in
../_shared/epa_sld.py, and captures the renderer's class breaks once as a
static legend.
"""

import json
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "_shared"))
import epa_sld  # noqa: E402

LAYER_URL = (
    "https://geodata.epa.gov/arcgis/rest/services/OA/SmartLocationDatabase/MapServer/4"
)
VALUE_FIELD_FALLBACK = "D1D"
OUT_VALUE_FIELD = "density"

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_PATH = os.path.join(SCRIPT_DIR, "assets", "data", "nevada_activity_density.json")


def main():
    dataset = epa_sld.build_dataset(LAYER_URL, VALUE_FIELD_FALLBACK, OUT_VALUE_FIELD)
    epa_sld.write(dataset, OUT_PATH)
    print()
    print("Make sure pubspec.yaml includes:")
    print("  flutter:")
    print("    assets:")
    print("      - assets/data/nevada_activity_density.json")


if __name__ == "__main__":
    main()
