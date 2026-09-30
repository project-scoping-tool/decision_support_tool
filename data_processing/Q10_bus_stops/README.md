# Q10 — Bus Stops

PST question: *"What is the level of bus service within a quarter mile of
the project area..."* (`bus-stops-rtc`, `bus-stops-las-vegas`,
`bus-stops-google-earth`). `bus-stops-washoe` is manual
(`autoFillEnabled = false`) and unaffected.

## Original data source

RTC (Regional Transportation Commission of Southern Nevada) "HUB"
FeatureServer, ArcGIS Online item `3a1fde0a9b9a49e98574e0c6322a088f`, which
resolves to a single point layer:
`https://webgis.rtcsnv.com/arcgis/rest/services/Web/HUB/FeatureServer/0`
(3,763 stops). Unlike Schools, this item has no sub-layers to choose
between — the old live `BusStopsQueryService`'s multi-layer fallback logic
never actually had more than one layer to try here.

## How the data is downloaded

`download_bus_stops_data.py` resolves the FeatureServer URL from the item
id and pages through every point (`resultOffset`/`resultRecordCount`),
writing `{lon, lat, name}` for each stop.

## How it is processed

No separate processing step — the downloader writes the runtime file
directly, since the source is already a small, flat point layer.

## Output dataset

`assets/data/clark_county_bus_stops.json`:

```json
{"features": [{"lon": -115.1, "lat": 36.1, "name": "..."}, ...]}
```

## How to rerun/update

```bash
cd data_processing/Q10_bus_stops
python3 download_bus_stops_data.py
cp assets/data/clark_county_bus_stops.json \
   ../../flutter/decision_support_tool/assets/data/clark_county_bus_stops.json
```

## Which Flutter code uses it

- `lib/services/bus_stops_query_service.dart` — counts stops within 0.25 mi
  of the geocoded address using `GeoUtils.distanceMilesHaversine`.
- `lib/services/bus_stops_map_service_flutter.dart` — builds the "view on
  map" overlay from the same dataset and radius.
- Geocoding still goes through `lib/services/geocoding_service.dart`
  (external API — see `/data_processing/README.md`).

## Verification

Cross-checked 5 real Clark County addresses against the live ArcGIS
endpoint at migration time (counts ranged 2–6) — all matched exactly.
