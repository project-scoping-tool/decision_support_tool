"""
Shared helper for downloading Census tract geometries + an ACS5 subject-table
variable, used by Q2 (Biking Rate) and Q3 (Walking Rate) — both need the same
Clark + Washoe County tract polygons, just a different ACS commuting-mode
variable merged in. Not a PST question on its own; imported by
data_processing/Q2/download_biking_rate_data.py and
data_processing/Q3_walking_rate/download_walking_rate_data.py.
"""

import requests

STATE_FIPS = "32"  # Nevada
# Every jurisdiction in the PST app is in Clark County except Washoe County.
COUNTY_FIPS_LIST = ["003", "031"]  # Clark, Washoe

# Registered Census API key (same one already used by the existing Q2
# biking-rate script prior to this migration).
CENSUS_API_KEY = "af610e97b805f477a9e54295d3b38d20b57ddb3d"


def download_tract_geometries():
    """Downloads 2020 Census tract polygons for Clark + Washoe counties."""
    print("Downloading Clark + Washoe County tract geometries...")
    url = (
        "https://raw.githubusercontent.com/loganpowell/census-geojson/"
        "master/GeoJSON/500k/2020/32/tract.json"
    )
    r = requests.get(url, timeout=60)
    r.raise_for_status()
    all_tracts = r.json()["features"]
    tracts = [
        f for f in all_tracts if f["properties"].get("COUNTYFP") in COUNTY_FIPS_LIST
    ]
    by_county = {}
    for f in tracts:
        by_county.setdefault(f["properties"]["COUNTYFP"], 0)
        by_county[f["properties"]["COUNTYFP"]] += 1
    print(f"  Got {len(tracts)} tracts: {by_county}")
    return tracts


def download_acs_rates(acs_var, acs_year=2022):
    """Downloads one ACS5 subject-table variable for every tract in both
    counties. Returns {(county_fips, tract_ce): value}."""
    print(f"Downloading ACS {acs_year} {acs_var} for Clark + Washoe...")
    rates = {}
    for county_fips in COUNTY_FIPS_LIST:
        url = (
            f"https://api.census.gov/data/{acs_year}/acs/acs5/subject"
            f"?get=NAME,{acs_var}"
            f"&for=tract:*"
            f"&in=state:{STATE_FIPS}%20county:{county_fips}"
            f"&key={CENSUS_API_KEY}"
        )
        r = requests.get(
            url,
            timeout=60,
            headers={"User-Agent": "Mozilla/5.0", "Accept": "application/json"},
        )
        r.raise_for_status()
        data = r.json()
        if len(data) <= 1:
            raise Exception(f"No tract data returned for county {county_fips}")

        header = data[0]
        var_idx = header.index(acs_var)
        tract_idx = header.index("tract")
        for row in data[1:]:
            tractce = row[tract_idx].zfill(6)
            val = row[var_idx]
            if val in (None, "", "null", "N"):
                continue
            try:
                fval = float(val)
            except ValueError:
                continue
            if fval < 0:  # suppress sentinels (-666666666 etc.)
                continue
            rates[(county_fips, tractce)] = fval
        print(f"  County {county_fips}: {len(data) - 1} tracts, valid rates so far {len(rates)}")
    return rates


def merge(tracts, rates, out_property_name):
    """Merges tract geometries with a rates dict into a GeoJSON
    FeatureCollection, writing the rate under out_property_name (null if
    not found for that tract)."""
    features = []
    for f in tracts:
        props = f["properties"]
        county_fips = props["COUNTYFP"]
        tractce = props["TRACTCE"]
        geo = dict(f["geometry"])
        geo.pop("bbox", None)

        features.append(
            {
                "type": "Feature",
                "properties": {
                    "GEOID": props["GEOID"],
                    "TRACTCE": tractce,
                    "COUNTYFP": county_fips,
                    "NAME": props["NAME"],
                    out_property_name: rates.get((county_fips, tractce)),
                },
                "geometry": geo,
            }
        )

    null_count = sum(1 for f in features if f["properties"][out_property_name] is None)
    print(f"  {len(features)} features, {null_count} have null {out_property_name}")
    return {"type": "FeatureCollection", "features": features}
