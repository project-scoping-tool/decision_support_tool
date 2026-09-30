# Q6 — Land Use Diversity

PST question: *"What is the land use diversity index? (jobs to housing)"*
(`land-use-diversity` — used by every jurisdiction, including Washoe).

## Original data source

EPA Smart Location Database (SLD) MapServer, Layer 7 ("Land use
diversity"), nationwide: `https://geodata.epa.gov/arcgis/rest/services/OA/SmartLocationDatabase/MapServer/7`.

**Key finding while tracing the old live code:** its comments describe
`D2B_E8MIXA` as the "known fallback" value field, but the live code always
fetched the layer's renderer first and used `renderer.field` when present
— and that field has actually been **`D2A_EPHHM`**, not `D2B_E8MIXA`, for
as long as this renderer has looked the way it does today. So the app's
real historical answers came from `D2A_EPHHM`. This migration preserves
that actual behavior (verified: raw `D2A_EPHHM` values downloaded here
matched a live re-query exactly for several sample block groups), not the
stale fallback name in the comment.

The renderer's own class-break labels (`0.1` -> `"0-1"`, `1.0` -> `"9-10"`,
etc.) also confirm the existing ×10 scaling logic (raw ~0-1 value ×10 for
display/bucketing) is correct regardless of which field name is used.

## How the data is downloaded

`download_land_use_diversity_data.py` uses the shared
`../_shared/epa_sld.py` helper:
1. Fetches the layer's renderer once (`?f=json` on the layer URL) to
   resolve the real value field and capture the class-break legend
   (color + label + max value per bucket) as a static list — the live
   code fetched this same renderer on every question view.
2. Queries the layer with `where=STATEFP='32' AND COUNTYFP IN ('003','031')`
   (Clark + Washoe), paginated — the EPA MapServer exposes `STATEFP`/
   `COUNTYFP` fields directly, so this is a precise server-side filter,
   not a nationwide download.

## How it is processed

Coordinates are rounded to 6 decimal places during download (negligible
precision loss, smaller file). No other transformation — the ×10 scaling
and bucketing happen at runtime in Dart, unchanged from the live code.

## Output dataset

`assets/data/nevada_land_use_diversity.json` (1,604 Clark + Washoe block
groups, ~1.2 MB):

```json
{
  "classBreaks": [{"max": 0.1, "label": "0 -1", "color": [255,255,128,255]}, ...],
  "features": [
    {"geoid": "320030005172", "diversityIndex": 0.7988, "rings": [[[lon,lat], ...]]},
    ...
  ]
}
```

## How to rerun/update

```bash
cd data_processing/Q6_land_use_diversity
python3 download_land_use_diversity_data.py
cp assets/data/nevada_land_use_diversity.json \
   ../../flutter/decision_support_tool/assets/data/nevada_land_use_diversity.json
```

## Which Flutter code uses it

- `lib/services/land_use_diversity_drawing_service.dart` — rewritten to
  mirror `WalkingRateDrawingService`'s local-asset structure: finds block
  groups intersecting the user-drawn polygon, computes an area-weighted
  average diversity index (×10), and maps it to a DST answer bucket.
  Class-break colors now come from the static `classBreaks` array in the
  asset instead of a live renderer fetch.
- Geocoding still goes through `lib/services/geocoding_service.dart`
  (external API — see `/data_processing/README.md`).

## Verification

Cross-checked raw `D2A_EPHHM` values for 4 sample block groups against a
live re-query at migration time — all matched exactly (full float
precision). The clip/area-weighting logic itself is the same pattern
already shipped and verified in `BikingRateDrawingService`/
`WalkingRateDrawingService`.
