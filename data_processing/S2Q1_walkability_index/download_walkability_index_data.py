#!/usr/bin/env python3
"""
Run this script ONCE on your local machine to build:
    assets/data/nevada_walkability_index.json

Requirements:  pip install requests

Usage:
    cd data_processing/S2Q1_walkability_index
    python3 download_walkability_index_data.py

Original live source: WalkabilityIndexDrawingService queried the EPA
National Walkability Index MapServer Layer 0 (field NatWalkInd,
nationwide) live for whatever block groups intersected the user-drawn
polygon, plus fetched the renderer's live class-break colors/labels on
every use.

This script downloads every Clark + Washoe County block group up front
(server-side filtered via STATEFP/COUNTYFP — same schema/approach as the
EPA Smart Location Database used for Q6/Q7) using the shared helper in
../_shared/epa_sld.py, and captures the renderer's class breaks once as a
static legend.

Note: this question's auto-fill button was disabled in the UI before this
migration (see /data_processing/README.md and question_section_page.dart)
— it is re-enabled as part of this migration since there is now a working
local implementation to enable it with.
"""

import json
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "_shared"))
import epa_sld  # noqa: E402

LAYER_URL = (
    "https://geodata.epa.gov/arcgis/rest/services/OA/WalkabilityIndex/MapServer/0"
)
VALUE_FIELD_FALLBACK = "NatWalkInd"
OUT_VALUE_FIELD = "walkIndex"

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_PATH = os.path.join(SCRIPT_DIR, "assets", "data", "nevada_walkability_index.json")


def main():
    dataset = epa_sld.build_dataset(LAYER_URL, VALUE_FIELD_FALLBACK, OUT_VALUE_FIELD)
    epa_sld.write(dataset, OUT_PATH)
    print()
    print("Make sure pubspec.yaml includes:")
    print("  flutter:")
    print("    assets:")
    print("      - assets/data/nevada_walkability_index.json")


if __name__ == "__main__":
    main()
