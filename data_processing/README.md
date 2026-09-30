# data_processing

Scripts that build the local datasets the PST (Project Scoping Tool) Flutter
app bundles under `assets/data/`, so the app can answer auto-fill questions
without depending on a live external API at runtime. One folder per
PST question that has an auto-fill data source; each folder has its own
README with that question's specific source/download/processing/output
details.

## Geographic scope

Every jurisdiction the app supports (Boulder City, Clark County, City of
Henderson, City of Las Vegas, City of Mesquite, City of North Las Vegas,
Washoe County) is in **Clark County** or **Washoe County**. All datasets
built here are scoped to those two counties rather than statewide Nevada
— matching the existing crash-data precedent (`Crashes_Procress_24`'s
`CLARK_*`/`WASHOE_*` files) — to keep the app's bundle size down without
losing coverage anywhere the app is actually used. (`nevada_adi_data.json`,
used by the Underserved/ADI question, is the one exception: it already
shipped statewide before this migration and was left as-is.)

## Geocoding stays external — why

Every one of these questions starts from a user-typed project address and
needs (lon, lat) before it can look anything up. That step —
`lib/services/geocoding_service.dart` — still calls the ArcGIS World
Geocoding Service and is the **one runtime API dependency that remains**
after this migration.

This was evaluated and rejected for localization: a fully offline
geocoder needs a bundled address-point/range dataset (Census TIGER
address ranges, or OpenAddresses/OSM data — tens of MB even limited to
Nevada) plus fuzzy text-matching/interpolation logic to handle typos,
abbreviations, and partial addresses the way a composite locator does.
That's a separate, materially larger effort than localizing the
per-question data lookups here, with a real risk of degrading match
accuracy compared to ArcGIS's locator (which blends address points,
parcels, and street-range interpolation) — which would violate "preserve
existing behavior." Every question's actual data lookup (counts, rates,
indices, buckets) is now local; only turning free text into coordinates
is not.

## Folder structure

```
data_processing/
  _shared/                    # helpers imported by multiple question scripts
    census_tracts.py          #   TIGER tract geometry + ACS5 subject-table download (Q2, Q3)
    epa_sld.py                #   EPA MapServer layer download w/ STATEFP/COUNTYFP filter (Q6, Q7, S2Q1)

  Q2/                          # Biking Rate            (already local; extended to Washoe here)
  Q3_walking_rate/             # Walking Rate            -> nevada_walking_rate.json
  Q6_land_use_diversity/       # Land Use Diversity      -> nevada_land_use_diversity.json
  Q7_activity_density/         # Activity Density        -> nevada_activity_density.json
  Q8/                          # Schools                 -> clark_county_schools.json (finished; was half-done)
  Q9_public_parks/             # Public Parks            -> clark_county_parks.json
  Q10_bus_stops/                # Bus Stops                -> clark_county_bus_stops.json
  Q11_bike_lanes/               # Bike Lanes               -> clark_county_bike_lanes.json
  S2Q1_walkability_index/      # National Walkability Index -> nevada_walkability_index.json

  Crashes_Procress_23/         # Pedestrian/Bicycle Crash - already local, predates this migration
  Crashes_Procress_24/         # Pedestrian/Bicycle Crash - already local, predates this migration
```

`Q2`, `Q8`, `Crashes_Procress_23`, `Crashes_Procress_24` already existed
before this effort (Biking Rate and the crash datasets were already local;
Schools' data had been downloaded but never wired into the live Flutter
code). Everything else was created by this migration. ADI (Underserved)
has no `data_processing/` folder — it predates this repo's data-processing
scripts entirely and its dataset was already in place.

## Rerunning everything

Each subfolder's README has the exact commands. In general:

```bash
cd data_processing/<folder>
python3 download_<question>_data.py     # some also have a process_*.py step
cp assets/data/<file>.json ../../flutter/decision_support_tool/assets/data/<file>.json
```

Then confirm `flutter/decision_support_tool/pubspec.yaml`'s `flutter:
assets:` list still references the file (it doesn't change on a rerun,
only when a *new* dataset is added).

## Requirements

```
pip install requests
```

No other Python dependencies are needed — every script here is a plain
`requests`-based downloader/JSON transformer, deliberately kept simple
since these run once on a developer machine, not in CI or at app runtime.
