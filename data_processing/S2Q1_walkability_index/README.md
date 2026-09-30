# S2Q1 — National Walkability Index

PST question: *"What is the National Walkability Index Score?"*
(`walkability` — section 2, question 1; used by every jurisdiction,
including Washoe).

## Original data source

EPA National Walkability Index MapServer, Layer 0, field `NatWalkInd`,
nationwide: `https://geodata.epa.gov/arcgis/rest/services/OA/WalkabilityIndex/MapServer/0`.

**Important pre-existing bug found and fixed as part of this migration:**
this question's auto-fill button was **not wired up in the UI at all**.
`walkability.toml` sets `autoFillEnabled = true` and
`WalkabilityIndexDrawingService`/`WalkabilityIndexDrawingWidget` were
fully implemented, but the dispatch case for `buttonText == 'Walkability
Index'` in `question_section_page.dart`'s `_buildWidgetAutoFillButton()`
was commented out — so no auto-fill button ever rendered for this
question, in any jurisdiction, before this migration. It's re-enabled as
part of this work (see "Flutter changes" below), since there's now a
working local implementation for it to call.

## How the data is downloaded

`download_walkability_index_data.py` uses the shared `../_shared/epa_sld.py`
helper (same STATEFP/COUNTYFP-filtered approach as Q6/Q7 — this MapServer
exposes the identical schema): fetches the renderer once (value field +
class-break legend), then queries
`where=STATEFP='32' AND COUNTYFP IN ('003','031')` (Clark + Washoe),
paginated.

## How it is processed

Coordinates rounded to 6 decimal places during download. Category mapping
(1-5.75 / 5.76-10.50 / 10.51-15.25 / 15.26-20) and the area-weighted,
round-half-up category rule happen at runtime in Dart, unchanged from the
previous live code.

## Output dataset

`assets/data/nevada_walkability_index.json` (1,604 Clark + Washoe block
groups, ~1.2 MB):

```json
{
  "classBreaks": [{"max": 5.76, "label": "1 - 5.75 (Least Walkable)", "color": [255,170,0,255]}, ...],
  "features": [
    {"geoid": "320030005172", "walkIndex": 15.667, "rings": [[[lon,lat], ...]]},
    ...
  ]
}
```

## How to rerun/update

```bash
cd data_processing/S2Q1_walkability_index
python3 download_walkability_index_data.py
cp assets/data/nevada_walkability_index.json \
   ../../flutter/decision_support_tool/assets/data/nevada_walkability_index.json
```

## Which Flutter code uses it

- `lib/services/walkability_index_drawing_service.dart` — rewritten to
  mirror `WalkingRateDrawingService`'s local-asset structure: finds block
  groups intersecting the user-drawn polygon, computes area-weighted
  NatWalkInd + category averages, rounds half-up, and maps to a DST answer
  range. Class-break colors come from the static `classBreaks` array
  instead of a live renderer fetch.
- `lib/ui/question_section_page.dart` — the `'Walkability Index'` case in
  `_buildWidgetAutoFillButton()`'s switch statement was **uncommented**
  to actually route to `_openWalkabilityDrawing()`, which already existed
  but was unreachable dead code before this migration.
- Geocoding still goes through `lib/services/geocoding_service.dart`
  (external API — see `/data_processing/README.md`).

## Verification

Cross-checked raw `NatWalkInd` values for 4 sample block groups against a
live re-query at migration time — all matched exactly (full float
precision), and the downloaded class-break labels confirm the same 4
category thresholds the previous live code hardcoded.
