# Q11 — Bike Lanes

PST question: *"How many bike lanes and shared use paths are in the area
or within ¼ mile radius?"* (`bike-lanes-rtc`, `bike-lanes-henderson`).
`bike-lanes-washoe` is manual (`autoFillEnabled = false`) and unaffected.

## Original data source

Two RTC (Regional Transportation Commission) ArcGIS Online items, both
resolving to layers on the same "HUB" FeatureServer used for Bus Stops
(Q10):

```
bike lanes        ae77a3326fe64b788618c2f29988ebeb -> HUB/FeatureServer/9
shared use paths  222b1b87a5984a29ad801c3a55aea778 -> HUB/FeatureServer/10
```

Both are polyline layers. The live `BikeLanesQueryService` queried both
within a 0.25-mile buffer and **summed** the two counts (unlike Parks,
there's no "best layer" selection here — every jurisdiction's toml variant
for this question routes to the same combined bike-lane + shared-use-path
total).

## How the data is downloaded

`download_bike_lanes_data.py` resolves both FeatureServer URLs and pages
through every line feature in each, tagging each with `kind`
(`bike_lane` / `shared_use_path`). Streets are broken into many short
segments by the source data, so this is a much larger download than the
other point/polygon questions: 20,541 bike-lane segments + 1,738
shared-use-path segments = 22,279 lines.

## How it is processed

`process_bike_lanes_data.py` rounds every coordinate to 6 decimal places
(~0.11 m at this latitude — far finer than the ¼-mile buffer the app
tests against). ArcGIS serializes full float64 precision by default
(15-17 significant digits), which is pure bundle-size waste here; rounding
shrank the bundled file from 12.7 MB to 7.8 MB with no change to which
lines fall inside a 0.25-mile buffer.

## Output dataset

`assets/data/clark_county_bike_lanes.json`:

```json
{"features": [
  {"kind": "bike_lane", "paths": [[[lon,lat], [lon,lat], ...]]},
  {"kind": "shared_use_path", "paths": [...]},
  ...
]}
```

## How to rerun/update

```bash
cd data_processing/Q11_bike_lanes
python3 download_bike_lanes_data.py   # network, ~2-3 min (22k+ features, paginated)
python3 process_bike_lanes_data.py    # rounds coordinates in place
cp assets/data/clark_county_bike_lanes.json \
   ../../flutter/decision_support_tool/assets/data/clark_county_bike_lanes.json
```

## Which Flutter code uses it

- `lib/services/bike_lanes_query_service.dart` — counts bike-lane and
  shared-use-path lines within 0.25 mi of the geocoded address using
  `GeoUtils.distanceMilesToPolyline`, and sums the two counts (mirrors the
  live `bikeLaneCount + sharedUsePathCount`).
- `lib/services/bike_lanes_map_service.dart` — builds the "view on map"
  overlay from the same dataset and radius.
- Geocoding still goes through `lib/services/geocoding_service.dart`
  (external API — see `/data_processing/README.md`).

## Verification

Cross-checked 4 real Clark County/Henderson addresses against the live
ArcGIS endpoints at migration time, including a 72-line total — all
matched exactly, split by kind.
