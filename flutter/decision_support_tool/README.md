# Decision Support Tool — Flutter App

A Flutter-based mobile/desktop decision support tool for evaluating walkability, active transportation infrastructure, and equity indicators for project areas.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Setup Instructions](#setup-instructions)
3. [Project Structure](#project-structure)
4. [APIs Used](#apis-used)
5. [Data Sources](#data-sources)
6. [Adding a New Question Automation](#adding-a-new-question-automation)

---

## Project Overview

The tool presents users with a scored assessment consisting of multiple sections and questions. Each question can be answered manually using provided instructions and external map links, or auto-filled by the app querying external APIs or local datasets. Results are used to generate recommendations for transportation planning projects.

---

## Setup Instructions

### Prerequisites

- Flutter SDK ≥ 3.x ([install guide](https://docs.flutter.dev/get-started/install))
- Dart SDK (bundled with Flutter)
- An IDE: VS Code with the Flutter extension, or Android Studio

### Clone & Install Dependencies

```bash
git clone <your-repo-url>
cd decision_support_tool/flutter/decision_support_tool
flutter pub get
```

### Required Asset Files

The following local data files must be present in `assets/data/` and declared in `pubspec.yaml`:

| File | Purpose |
|---|---|
| `assets/data/nevada_adi_data.json` | Area Deprivation Index polygons for Nevada (GeoJSON/FeatureCollection) |
| `assets/data/crashes_bicyclist.csv` | Nevada bicyclist crash records 2018–2021 |
| `assets/data/crashes_pedestrian.csv` | Nevada pedestrian crash records 2018–2021 |

Ensure `pubspec.yaml` includes:

```yaml
flutter:
  assets:
    - assets/data/nevada_adi_data.json
    - assets/data/crashes_bicyclist.csv
    - assets/data/crashes_pedestrian.csv
    - assets/question_info/
    - assets/assessment_info/
    - assets/recommendations_info/
```

### Run the App

```bash
flutter run -d chrome
```

---

## Project Structure

```
lib/
  services/           # All API query and data processing logic
  ui/                 # All Flutter widgets and pages
  data/               # Data models (static_data_models.dart, form_data_models.dart)
assets/
  question_info/      # TOML config files — one per question
  assessment_info/    # TOML config files — one per assessment
  recommendations_info/
  data/               # Local datasets (CSV, JSON)
```

Question configuration is driven entirely by TOML files. Each file maps to a `QuestionInfo` object and controls the question text, answer options, scoring, instructions, video link, and whether auto-fill is enabled.

---

## APIs Used

### 1. ArcGIS World Geocoding Service

**Used by:** All query services (bus stops, parks, ADI, biking rate, land use diversity, walkability, bicycle crash, pedestrian crash)

**Purpose:** Converts a user-entered street address into longitude/latitude coordinates.

**Endpoint:**
```
GET https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates
```

**Key parameters:**

| Parameter | Value |
|---|---|
| `singleLine` | User-entered address string |
| `outFields` | `Match_addr,Addr_type` |
| `maxLocations` | `1` |
| `f` | `json` |

**How it is used:** Every auto-fill flow starts with geocoding. The service returns a `candidates` array; the app takes the first result's `location.x` (longitude) and `location.y` (latitude). A token can be added via the `token` parameter if you have an ArcGIS API key.

**Where to find documentation:** [ArcGIS REST API — findAddressCandidates](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-find-address-candidates.htm)

---

### 2. ArcGIS Online Item & Feature Service API

**Used by:** `bus_stops_query_service.dart`, `bus_stops_map_service_flutter.dart`, `parks_query_service.dart`

**Purpose:** Resolves a published ArcGIS Online item ID to its backing Feature Service or Map Service URL, lists its layers, and queries features within a buffer radius around a point.

**Endpoints:**

```
# Resolve item to service URL
GET https://www.arcgis.com/sharing/rest/content/items/{itemId}?f=json

# List layers
GET {serviceUrl}?f=json

# Spatial query within radius
GET {serviceUrl}/{layerId}/query?f=json&where=1=1&geometryType=esriGeometryPoint
    &geometry={lon},{lat}&inSR=4326&spatialRel=esriSpatialRelIntersects
    &distance={miles}&units=esriSRUnit_StatuteMile&returnCountOnly=true
```

**How it is used:**

- **Bus Stops:** Item ID `3a1fde0a9b9a49e98574e0c6322a088f` (RTC Southern Nevada bus stop layer). The service iterates all available layers and picks the first one that returns a valid count. A ¼-mile (0.25 mi) buffer is applied. The answer is `"0"` or `"1 or more"`.
- **Parks:** Item ID `7b483a11c0b3489d8ce7601081872f99` (Clark County Recreation layer). Layer IDs 5–10 are tried in sequence; the layer returning the highest feature count wins. A ½-mile (0.5 mi) buffer is applied. The answer is `"0"`, `"1"`, or `">1"`.

**Where to find item IDs:** Open the item on [ArcGIS Online](https://www.arcgis.com) and copy the ID from the URL: `arcgis.com/home/item.html?id=<ITEM_ID>`

**Where to find documentation:** [ArcGIS REST API — Query (Feature Service)](https://developers.arcgis.com/rest/services-reference/enterprise/query-feature-service-layer-.htm)

---

### 3. U.S. Census Bureau — ACS 5-Year Subject Tables API

**Used by:** `biking_rate_drawing_service.dart`

**Purpose:** Fetches the bike-to-work percentage for individual Census Tracts (ACS variable `S0801_C01_011E`) to compute an area-weighted average biking rate for a user-drawn polygon.

**Endpoint:**
```
GET https://api.census.gov/data/2020/acs/acs5/subject
    ?get=NAME,S0801_C01_011E&for=tract:{tract6}&in=state:32 county:003
```

**Key parameters:**

| Parameter | Value |
|---|---|
| `get` | `NAME,S0801_C01_011E` (name + bike-to-work %) |
| `for` | `tract:{6-digit tract FIPS}` |
| `in` | `state:32 county:003` (Nevada / Clark County) |
| `key` | Optional Census API key |

**How it is used:** After the user draws a polygon on the map, the service finds all Census Tract GEOIDs that intersect the polygon (via the TIGER/Web service below), then fetches the ACS biking rate for each tract individually. It computes both a simple average and an area-weighted average, then maps the result to one of the TOML answer buckets.

**Where to find documentation:** [Census Data API User Guide](https://www.census.gov/data/developers/guidance/api-user-guide.html) | [ACS Subject Tables](https://api.census.gov/data/2020/acs/acs5/subject/variables.html)

---

### 4. Census TIGER/Web — Tracts & Blocks Map Service

**Used by:** `biking_rate_drawing_service.dart`

**Purpose:** Queries Census Tract polygon geometries that intersect a user-drawn polygon, returning GEOID identifiers and ring coordinates for spatial clipping.

**Endpoint:**
```
GET https://tigerweb.geo.census.gov/arcgis/rest/services/Census2020/Tracts_Blocks/MapServer/{layerId}/query
    ?f=json&where=1=1&outFields=GEOID&returnGeometry=true
    &geometryType=esriGeometryPolygon&geometry={polygon}&inSR=4326&outSR=4326
```

**How it is used:** The user's drawn polygon (as [lon, lat] rings) is sent as an ArcGIS polygon geometry. The service returns all Census 2020 Tracts that intersect it. GEOIDs with length 11 (tract level, not block level) are retained. Polygon geometries are used for area-intersection calculations via a Sutherland-Hodgman clipping algorithm implemented in Dart.

**Where to find documentation:** [TIGER/Web REST Services](https://tigerweb.geo.census.gov/tigerwebmain/TIGERweb_restmapservice.html)

---



## Data Sources

### Local CSV — Bicycle Crash Data

**File:** `assets/data/crashes_bicyclist.csv`

**Used by:** `bicycle_crash_drawing_service.dart` / `bicycle_crash_drawing_widget.dart` / `bicycle_crash_map_widget.dart`

**Contents:** 2,313 bicycle crash records with columns: `CrashNum`, `Street1`, `Street2`, `CrashDate`, `CrashTime`, `City`, `County`, `X` (longitude), `Y` (latitude).

**How it is used:** Loaded at runtime from Flutter assets via `rootBundle`. When the user draws a polyline on the map, the service buffers that polyline by 0.25 miles (using a point-to-segment distance calculation in Dart) and counts how many crash records fall within the buffer. Crash density = count ÷ buffered area in sq. miles, mapped to TOML answer buckets.

**Original source:** Nevada Department of Transportation (NDOT) crash data 2018–2021, also visualized at [UNLV ArcGIS Online Viewer](https://unlvarcgisonline.maps.arcgis.com/apps/webappviewer/index.html?id=615504612df74a94b2a838cf5f619c20)

---

### Local CSV — Pedestrian Crash Data

**File:** `assets/data/crashes_pedestrian.csv`

**Used by:** `pedestrian_crash_drawing_service.dart` / `pedestrian_crash_drawing_widget.dart` / `pedestrian_crash_map_widget.dart`

**Contents:** 4,972 pedestrian crash records with the same schema as the bicycle crash file.

**How it is used:** Identical approach to bicycle crashes. The user draws a polyline representing the project perimeter; the service counts pedestrian crashes within a 0.25-mile buffer and computes density.

**Original source:** NDOT crash data 2018–2021, also visualized at [UNLV ArcGIS Online Viewer](https://unlvarcgisonline.maps.arcgis.com/apps/webappviewer/index.html?id=d4aff382b1e6440786db5777c29e2022)

---

### Local JSON — Nevada Area Deprivation Index (ADI)

**File:** `assets/data/nevada_adi_data.json`

**Used by:** `adi_query_service.dart`

**Contents:** GeoJSON FeatureCollection of Census Block Group polygons for Nevada. Each feature's `properties` object contains:

| Property | Description |
|---|---|
| `value_state` | ADI state decile (integer 1–10) |
| `id` | Block Group identifier |
| `county` | County name |

**How it is used:** Loaded once per session and cached in memory (`_cachedAdiFeatures`). After geocoding the user's address, the service performs a point-in-polygon test (ray-casting algorithm) across all features to find the matching block group and return its `value_state` as the ADI answer (1–10).

**Original source:** University of Wisconsin Neighborhood Atlas — [Area Deprivation Index](https://www.neighborhoodatlas.medicine.wisc.edu/). The JSON was pre-downloaded for Nevada and bundled as an app asset to avoid requiring users to have network access or an account with the Neighborhood Atlas.

---


