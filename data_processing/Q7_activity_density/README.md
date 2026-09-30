# Q7 — Activity Density

PST question: *"What is the activity density (housing units + jobs per
acre)?"* (`hu-jpa` — used by every jurisdiction, including Washoe).

## Original data source

EPA Smart Location Database (SLD) MapServer, Layer 4 ("Employment and
housing density"), field `D1D`, nationwide:
`https://geodata.epa.gov/arcgis/rest/services/OA/SmartLocationDatabase/MapServer/4`.
Unlike Layer 7 (Q6), the renderer's own field here matched the previous
code's hardcoded fallback (`D1D`) exactly — confirmed by re-fetching the
renderer during this migration.

## How the data is downloaded

`download_activity_density_data.py` uses the shared `../_shared/epa_sld.py`
helper — same approach as Q6: fetch the renderer once (value field +
class-break legend), then query
`where=STATEFP='32' AND COUNTYFP IN ('003','031')` (Clark + Washoe),
paginated.

## How it is processed

Coordinates rounded to 6 decimal places during download. No other
transformation — bucketing (the `0-0.27` / `0.28-2.02` / `2.03-4.30` /
`4.31-8.31` / `>8.32` DST buckets and their 0-5 scores) happens at runtime
in Dart, an exact copy of the previous live `_buckets` table.

## Output dataset

`assets/data/nevada_activity_density.json` (1,604 Clark + Washoe block
groups, ~1.2 MB):

```json
{
  "classBreaks": [{"max": 0.269, "label": "0.00 - 0.27", "color": [255,255,128,255]}, ...],
  "features": [
    {"geoid": "320030005172", "density": 10.4795, "rings": [[[lon,lat], ...]]},
    ...
  ]
}
```

## How to rerun/update

```bash
cd data_processing/Q7_activity_density
python3 download_activity_density_data.py
cp assets/data/nevada_activity_density.json \
   ../../flutter/decision_support_tool/assets/data/nevada_activity_density.json
```

## Which Flutter code uses it

- `lib/services/activity_density_drawing_service.dart` — rewritten to
  mirror `WalkingRateDrawingService`'s local-asset structure: finds block
  groups intersecting the user-drawn polygon, computes an area-weighted
  average density and DST score (unchanged rounding rule: .5+ rounds up),
  and maps it to a DST answer bucket. Class-break colors come from the
  static `classBreaks` array instead of a live renderer fetch.
- Geocoding still goes through `lib/services/geocoding_service.dart`
  (external API — see `/data_processing/README.md`).

## Verification

Cross-checked raw `D1D` values for 4 sample block groups against a live
re-query at migration time — all matched exactly (full float precision).
