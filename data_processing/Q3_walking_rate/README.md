# Q3 — Walking Rate

PST question: *"What is the current rate of walking to work in the
proposed project's Census Tracts?"* (`walking-rate`, `walking-rate-washoe`).

## Original data source

Two live external services, queried on every use:

1. Census TIGERweb (`tigerweb.geo.census.gov/.../Census2020/Tracts_Blocks/MapServer`)
   — tract polygons intersecting the user-drawn area.
2. Census ACS5 subject table, variable `S0801_C01_010E` (% who walk to
   work), fetched per-tract.

## How the data is downloaded

`download_walking_rate_data.py` reuses the shared helper written for the
Biking Rate migration (`../_shared/census_tracts.py`, itself extended in
that same effort to cover Clark + Washoe rather than Clark alone):
`download_tract_geometries()` (2020 tract polygons for FIPS 32-003 and
32-031) and `download_acs_rates('S0801_C01_010E')`.

## How it is processed

`census_tracts.merge()` joins geometry + rate by `(COUNTYFP, TRACTCE)`,
writing `null` for any tract with a suppressed/missing ACS value, under
the `walkRate` property.

## Output dataset

`assets/data/nevada_walking_rate.json` (674 tracts: 535 Clark + 139
Washoe, ~640 KB) — same shape as `nevada_biking_rate.json`, with
`walkRate` instead of `bikeRate`.

## How to rerun/update

```bash
cd data_processing/Q3_walking_rate
python3 download_walking_rate_data.py
cp assets/data/nevada_walking_rate.json \
   ../../flutter/decision_support_tool/assets/data/nevada_walking_rate.json
```

## Which Flutter code uses it

- `lib/services/walking_rate_drawing_service.dart` — rewritten to mirror
  `BikingRateDrawingService`'s local-asset structure: finds tracts
  intersecting the user-drawn polygon (bbox pre-filter + vertex/edge
  intersection test), computes an area-weighted average walk-to-work rate
  (Sutherland-Hodgman clip with a grid-sampling fallback for non-convex
  polygons, both moved into the shared `GeoUtils` helper), and maps it to
  a DST answer bucket using the exact thresholds from `walking-rate.toml`
  (0-1.7% -> 1pt, 1.8-5.5% -> 2pt, 5.6-12.2% -> 3pt, 12.3-29.9% -> 4pt,
  30-54.6% -> 5pt — copied verbatim from the previous live implementation).
- Geocoding (for the map pin) goes through
  `lib/services/geocoding_service.dart` (external API — see
  `/data_processing/README.md`).

## Verification

Spot-checked walk-rate values (including a 100% and several 35-46% tracts)
for sample Clark and Washoe tracts against the live Census ACS API at
migration time — all matched exactly. The area-weighting/clipping/bucket
logic itself is a direct copy of `BikingRateDrawingService`'s
already-shipped local implementation, just against a different ACS
variable and threshold table.
