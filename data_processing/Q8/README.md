# Q8 — Schools

PST question: *"How many schools (CCSD & private) are in the area and within
a ½ mile radius?"* (`schools`, `schools-las-vegas`; `schools-washoe` is
manual/`autoFillEnabled = false` and unaffected by this migration).

## Original data source

Clark County GIS Open Data "Education" FeatureServer
(`https://maps.clarkcountynv.gov/arcgis/rest/services/OpenData/Education/MapServer`,
ArcGIS Online item `ca9eba42cebc4b0c965ffe80a3923978`), which exposes 7
layers: `CCSD School Programs`, `CCSD Campuses`, `Private Schools`,
`NSHE Schools`, `Elementary_K5`, `Middle`, `High`.

**Key finding while tracing the old live code:** the previous
`SchoolsQueryService` never queried all 7 layers. Its
`_pickBestSchoolLayer()` picked the *first* layer (in the FeatureServer's
own order) whose name contains `"campus"`:

```
0 CCSD School Programs
1 CCSD Campuses      <- always matches first, always the one used
2 Private Schools
3 NSHE Schools
4 Elementary_K5
5 Middle
6 High
```

So despite the question text mentioning "CCSD & private", the live answer
has always come from the single `CCSD Campuses` polygon layer alone. This
migration reproduces that exact source of truth rather than "fixing" it —
requirement was to preserve existing behavior, not change scoring.

## How the data is downloaded

`download_schools_data.py` resolves the FeatureServer URL from the ArcGIS
item id, lists all 7 layers, and pages through every feature of every layer
(`resultOffset`/`resultRecordCount`), writing the raw combined dump to
`raw_clark_county_schools_all_layers.json`. Each feature is normalized to
`{type, lon, lat, rings, name, layer, attributes}` (`lon`/`lat` is the
polygon centroid for polygon layers), and anything outside a rough Nevada
bounding box is dropped.

This step still needs network access — it's a one-time developer-machine
script, not something the shipped app runs.

## How it is processed

`process_schools_data.py` filters the raw dump down to just the
`CCSD Campuses` layer (337 of the 1174 raw features) and strips every field
the runtime calculation doesn't need (attributes, layer tag, geometry
type), keeping only `name`, `lon`, `lat`, `rings`. This shrinks the bundled
asset from 6.2 MB to ~1.2 MB with no behavior change.

## Output dataset

`assets/data/clark_county_schools.json`:

```json
{"layer": "CCSD Campuses", "features": [
  {"name": "...", "lon": -115.1, "lat": 36.0, "rings": [[[lon,lat], ...]]},
  ...
]}
```

## How to rerun/update

```bash
cd data_processing/Q8
python3 download_schools_data.py     # -> raw_clark_county_schools_all_layers.json
python3 process_schools_data.py      # -> assets/data/clark_county_schools.json
cp assets/data/clark_county_schools.json \
   ../../flutter/decision_support_tool/assets/data/clark_county_schools.json
```

## Which Flutter code uses it

- `lib/services/schools_query_service.dart` — counts campuses within 0.5 mi
  of the geocoded address using `GeoUtils.distanceMilesToPolygon` (point
  inside polygon = 0 distance, else distance to nearest edge — this
  mirrors ArcGIS's `esriSpatialRelIntersects` + buffer-distance query
  against polygon geometry, not a simple centroid-distance check).
- `lib/services/schools_map_service.dart` — builds the "view on map" overlay
  from the same dataset and radius.
- Geocoding (address → lon/lat) still goes through
  `lib/services/geocoding_service.dart` (external API — see
  `/data_processing/README.md`).

## Verification

Cross-checked 5 real Clark County addresses (mix of 0/1/2-school results)
against the live ArcGIS endpoint at migration time — all matched exactly.
See the migration report for the comparison script/output.
