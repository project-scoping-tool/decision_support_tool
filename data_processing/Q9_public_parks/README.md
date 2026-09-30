# Q9 — Public Parks

PST question: *"How many public parks are in the project area or within ½
mile radius?"* (`public-parks`, `public-parks-las-vegas`).
`public-parks-washoe` is manual (`autoFillEnabled = false`) and unaffected.

## Original data source

Clark County GIS Open Data "Recreation" MapServer (ArcGIS Online item
`7b483a11c0b3489d8ce7601081872f99`). The MapServer has 11 layers total
(trails, GPS points, libraries, historic sites, community centers, plus 6
per-jurisdiction park polygon layers); the live `ParksQueryService` only
ever queried layers `[5, 6, 7, 8, 9, 10]`:

```
5  Las Vegas Parks
6  Clark County Parks
7  Henderson Parks
8  Mesquite Parks
9  Boulder City Parks
10 North Las Vegas Parks
```

For a given address, the live service queried **all 6** of those layers
within a 0.5-mile buffer and kept whichever **single layer** returned the
highest count (`_bestLayerByCount`) — not the sum across layers. That's
the exact behavior this migration reproduces.

## How the data is downloaded

`download_parks_data.py` resolves the MapServer URL from the item id and
pages through all 6 park layers, keeping each polygon tagged with its
source `layerId`/`layerName` and a best-effort `name` (checked across
several possible name fields since each layer's schema differs slightly).

## How it is processed

No separate processing step — the downloader writes the runtime file
directly; there's no oversized attribute payload to strip (parks layers
don't carry the volume of extra fields the raw schools dump did).

## Output dataset

`assets/data/clark_county_parks.json`:

```json
{"features": [
  {"layerId": 5, "layerName": "Las Vegas Parks", "name": "...", "rings": [[[lon,lat], ...]]},
  ...
]}
```

388 polygons total across the 6 layers, ~1.4 MB.

## How to rerun/update

```bash
cd data_processing/Q9_public_parks
python3 download_parks_data.py
cp assets/data/clark_county_parks.json \
   ../../flutter/decision_support_tool/assets/data/clark_county_parks.json
```

## Which Flutter code uses it

- `lib/services/parks_query_service.dart` — for each of the 6 layers,
  counts polygons within 0.5 mi of the geocoded address using
  `GeoUtils.distanceMilesToPolygon`, then keeps the layer with the highest
  count (mirrors `_bestLayerByCount` exactly, including tie-breaking by
  layer order).
- `lib/services/parks_map_service.dart` — builds the "view on map" overlay
  from the same dataset, filtered to the winning layer.
- Geocoding still goes through `lib/services/geocoding_service.dart`
  (external API — see `/data_processing/README.md`).

## Verification

Cross-checked 5 addresses spanning different jurisdictions (Las Vegas,
Henderson, Boulder City, Mesquite) against the live ArcGIS endpoint at
migration time, including a 7-park match in Boulder City — winning layer
and count matched exactly in every case.
