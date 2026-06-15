#!/usr/bin/env python3
"""
Run this script ONCE on your local machine to build:
    assets/data/clark_county_biking_rate.json

Requirements:  pip install requests

Usage:
    cd /path/to/your/flutter/project   (where pubspec.yaml lives)
    python3 download_biking_rate_data.py

If the Census API is blocked, the script prints a manual fallback URL.
"""

import json, os, sys, requests

STATE_FIPS  = '32'
COUNTY_FIPS = '003'
ACS_YEAR    = 2022
ACS_VAR     = 'S0801_C01_011E'   # % who bike to work

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_PATH   = os.path.join(SCRIPT_DIR, 'assets', 'data', 'clark_county_biking_rate.json')

# ── Step 1 – tract geometries (GitHub mirror, always works) ───────────────────
def download_geometries():
    print('Step 1: Downloading Clark County tract geometries...')
    url = ('https://raw.githubusercontent.com/loganpowell/census-geojson/'
           'master/GeoJSON/500k/2020/32/tract.json')
    r = requests.get(url, timeout=60)
    r.raise_for_status()
    all_tracts = r.json()['features']
    clark = [f for f in all_tracts if f['properties'].get('COUNTYFP') == COUNTY_FIPS]
    print(f'  ✔ {len(clark)} Clark County tracts')
    return clark

# ── Step 2 – ACS rates (Census API) ──────────────────────────────────────────
def download_acs_rates():
    print(f'Step 2: Downloading ACS {ACS_YEAR} bike-to-work rates from Census API...')

    API_KEY = "af610e97b805f477a9e54295d3b38d20b57ddb3d"

    url = (
        f'https://api.census.gov/data/{ACS_YEAR}/acs/acs5/subject'
        f'?get=NAME,{ACS_VAR}'
        f'&for=tract:*'
        f'&in=state:{STATE_FIPS}%20county:{COUNTY_FIPS}'
        f'&key={API_KEY}'
    )

    print(f"Request URL:\n{url}\n")

    try:
        r = requests.get(
            url,
            timeout=60,
            headers={
                "User-Agent": "Mozilla/5.0",
                "Accept": "application/json"
            }
        )

        print(f"HTTP Status: {r.status_code}")

        if r.status_code != 200:
            print("API Response:")
            print(r.text)
            r.raise_for_status()

        data = r.json()

        if len(data) <= 1:
            raise Exception("No tract data returned from Census API")

        print(f"✔ Retrieved {len(data)-1} tract records")
        return data

    except Exception as e:
        print(f"❌ Census API error: {e}")
        raise

    print()
    print('  ══════════════════════════════════════════════════════════')
    print('  MANUAL FALLBACK STEPS:')
    print()
    print('  1. Open this URL in your browser (copy/paste exactly):')
    print()
    print(f'     https://api.census.gov/data/{ACS_YEAR}/acs/acs5/subject'
          f'?get=NAME,{ACS_VAR}'
          f'&for=tract:*'
          f'&in=state:{STATE_FIPS}%20county:{COUNTY_FIPS}')
    print()
    print('  2. The browser shows a JSON array. Save the page as:')
    print(f'       {manual}')
    print()
    print('  3. Re-run this script.')
    print('  ══════════════════════════════════════════════════════════')
    sys.exit(1)

# ── Step 3 – merge ────────────────────────────────────────────────────────────
def merge(clark_tracts, acs_data):
    print('Step 3: Merging geometry + rates...')
    header    = acs_data[0]
    var_idx   = header.index(ACS_VAR)
    tract_idx = header.index('tract')

    rate_by_tract = {}
    for row in acs_data[1:]:
        tractce = row[tract_idx].zfill(6)
        val = row[var_idx]
        if val in (None, '', 'null', 'N'): continue
        try:
            fval = float(val)
        except ValueError:
            continue
        if fval < 0: continue          # suppress sentinels (-666666666 etc.)
        rate_by_tract[tractce] = fval

    print(f'  Valid rates: {len(rate_by_tract)}, '
          f'suppressed/missing: {len(acs_data)-1 - len(rate_by_tract)}')

    features = []
    for f in clark_tracts:
        props   = f['properties']
        tractce = props['TRACTCE']
        geo     = f['geometry']
        # Remove bbox if present (saves ~30 KB)
        geo.pop('bbox', None)

        features.append({
            'type': 'Feature',
            'properties': {
                'GEOID':    props['GEOID'],
                'TRACTCE':  tractce,
                'NAME':     props['NAME'],
                'bikeRate': rate_by_tract.get(tractce),  # null if not found
            },
            'geometry': geo,
        })

    null_count = sum(1 for f in features if f['properties']['bikeRate'] is None)
    print(f'  {len(features)} features, {null_count} have null bikeRate')
    return {'type': 'FeatureCollection', 'features': features}

# ── Step 4 – write ────────────────────────────────────────────────────────────
def write(geojson):
    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    with open(OUT_PATH, 'w') as f:
        json.dump(geojson, f, separators=(',', ':'))
    size_kb = os.path.getsize(OUT_PATH) / 1024
    print(f'Step 4: Written → {OUT_PATH}  ({size_kb:.0f} KB)')

# ── Main ──────────────────────────────────────────────────────────────────────
if __name__ == '__main__':
    clark_tracts = download_geometries()
    acs_data     = download_acs_rates()
    geojson      = merge(clark_tracts, acs_data)
    write(geojson)
    print()
    print('✔ Done!')
    print()
    print('Make sure pubspec.yaml includes:')
    print('  flutter:')
    print('    assets:')
    print('      - assets/data/clark_county_biking_rate.json')