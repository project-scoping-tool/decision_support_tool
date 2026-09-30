# Q2 — Biking Rate

PST question: *"What is the current rate of biking to work in the proposed
project's Census Tracts?"* (`biking-rate`, `biking-rate-washoe`).

## Original data source

US Census ACS5 subject table, variable `S0801_C01_011E` (% who bike to
work), joined to 2020 Census tract polygons (state 32 = Nevada).

**Note on history:** this question was already migrated to a local dataset
before the wider data-processing migration (this `download_biking_rate_data.py`
script and its previous `assets/data/clark_county_biking_rate.json` output
predate this effort). What this migration changed: the dataset only
covered **Clark County**, but `biking-rate-washoe.toml` has
`autoFillEnabled = true` and routes to the same service — so Washoe County
addresses were silently getting "no tracts found" errors. This run extends
coverage to **Clark + Washoe** (every jurisdiction the app supports) using
the shared tract/ACS downloader in `../_shared/census_tracts.py`, and
renames the output from `clark_county_biking_rate.json` to
`nevada_biking_rate.json` to reflect the wider coverage.

## How the data is downloaded

`download_biking_rate_data.py` calls
`census_tracts.download_tract_geometries()` (2020 tract polygons for FIPS
32-003 and 32-031, from a GitHub GeoJSON mirror of TIGER/Line) and
`census_tracts.download_acs_rates('S0801_C01_011E')` (Census ACS5 subject
API, one call per county), then merges them.

## How it is processed

`census_tracts.merge()` joins geometry + rate by `(COUNTYFP, TRACTCE)`,
writing `null` for any tract with a suppressed/missing ACS value.

## Output dataset

`assets/data/nevada_biking_rate.json` (674 tracts: 535 Clark + 139
Washoe, ~640 KB):

```json
{"type": "FeatureCollection", "features": [{
  "type": "Feature",
  "properties": {"GEOID": "32003510800", "TRACTCE": "510800",
                  "COUNTYFP": "003", "NAME": "51.08", "bikeRate": 0.7},
  "geometry": {"type": "Polygon", "coordinates": [[[lon,lat], ...]]}
}, ...]}
```

## How to rerun/update

```bash
cd data_processing/Q2
python3 download_biking_rate_data.py
cp assets/data/nevada_biking_rate.json \
   ../../flutter/decision_support_tool/assets/data/nevada_biking_rate.json
```

## Which Flutter code uses it

- `lib/services/biking_rate_drawing_service.dart` — finds tracts
  intersecting the user-drawn polygon, computes an area-weighted average
  bike-to-work rate, and maps it to a DST answer bucket. Unchanged except
  the asset path (`_assetPath`).
- Geocoding (for the map pin) still calls the ArcGIS geocoder directly in
  this file — see `/data_processing/README.md`.

## Verification

Spot-checked bike-rate values for sample Clark and Washoe tracts against
the live Census ACS API at migration time (including a 0% and a non-zero
tract) — all matched exactly.
