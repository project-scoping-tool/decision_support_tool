"""
Shared helper for downloading a layer of the EPA Smart Location Database
(SLD) or EPA National Walkability Index MapServer, clipped to Clark +
Washoe counties via a server-side WHERE clause (both services expose
STATEFP/COUNTYFP fields, so no client-side spatial clipping is needed).

Used by:
  - Q6 (Land Use Diversity)   - SLD layer 7, field D2B_E8MIXA
  - Q7 (Activity Density)     - SLD layer 4, field D1D
  - S2Q1 (Walkability Index)  - WalkabilityIndex layer 0, field NatWalkInd

Not a PST question on its own.
"""

import json
import requests

STATE_FIPS = "32"  # Nevada
COUNTY_FIPS_LIST = ["003", "031"]  # Clark, Washoe
WHERE_CLAUSE = (
    f"STATEFP='{STATE_FIPS}' AND COUNTYFP IN "
    f"({','.join(repr(c) for c in COUNTY_FIPS_LIST)})"
)


def fetch_renderer(layer_url, fallback_field):
    """Fetches the layer's renderer (value field + class-break legend:
    color/label/max value per bucket) once, so the app can ship a static
    legend instead of calling this live on every question view."""
    r = requests.get(layer_url, params={"f": "json"}, timeout=60)
    r.raise_for_status()
    info = r.json()
    renderer = (info.get("drawingInfo") or {}).get("renderer") or {}

    value_field = renderer.get("field") or renderer.get("field1") or fallback_field

    breaks = []
    for cb in renderer.get("classBreakInfos", []):
        max_val = cb.get("classMaxValue")
        if max_val is None:
            continue
        color = ((cb.get("symbol") or {}).get("color")) or [221, 221, 221, 255]
        breaks.append(
            {
                "max": max_val,
                "label": cb.get("label") or str(max_val),
                "color": color,
            }
        )
    breaks.sort(key=lambda b: b["max"])
    return value_field, breaks


def query_all_features(layer_url, value_field):
    """Pages through every block group in Clark + Washoe counties for one
    layer, keeping only GEOID, the value field, and outer-ring geometry."""
    all_features = []
    offset = 0
    page_size = 1000
    while True:
        params = {
            "f": "json",
            "where": WHERE_CLAUSE,
            "outFields": f"GEOID20,GEOID10,{value_field}",
            "returnGeometry": "true",
            "outSR": "4326",
            "resultOffset": offset,
            "resultRecordCount": page_size,
        }
        r = requests.get(f"{layer_url.rstrip('/')}/query", params=params, timeout=90)
        r.raise_for_status()
        data = r.json()
        if "error" in data:
            raise Exception(f"EPA query error: {data['error']}")
        feats = data.get("features", [])
        all_features.extend(feats)
        print(f"  Got {len(feats)} (total {len(all_features)})")
        if len(feats) < page_size:
            break
        offset += page_size
    return all_features


def build_dataset(layer_url, value_field_fallback, out_value_field):
    """Full pipeline: fetch renderer + all features, normalize to a compact
    GeoJSON-ish structure with rounded coordinates."""
    print(f"Fetching renderer from {layer_url} ...")
    value_field, class_breaks = fetch_renderer(layer_url, value_field_fallback)
    print(f"  Value field: {value_field}, {len(class_breaks)} class breaks")

    print(f"Querying block groups (Clark + Washoe) ...")
    raw = query_all_features(layer_url, value_field)

    out_features = []
    for f in raw:
        geom = f.get("geometry")
        attrs = f.get("attributes", {})
        if not geom or "rings" not in geom or not geom["rings"]:
            continue
        geoid = attrs.get("GEOID20") or attrs.get("GEOID10")
        raw_val = attrs.get(value_field)
        rings = [
            [[round(p[0], 6), round(p[1], 6)] for p in ring]
            for ring in geom["rings"]
        ]
        out_features.append(
            {
                "geoid": str(geoid) if geoid is not None else None,
                out_value_field: raw_val,
                "rings": rings,
            }
        )

    print(f"  {len(out_features)} block groups")
    return {"classBreaks": class_breaks, "features": out_features}


def write(dataset, out_path):
    import os

    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "w") as f:
        json.dump(dataset, f, separators=(",", ":"))
    size_kb = os.path.getsize(out_path) / 1024
    print(f"Written -> {out_path} ({size_kb:.0f} KB)")
