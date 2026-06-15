#!/usr/bin/env python3
"""
Downloads CCSD + private school point locations (Clark County Education layer)
and writes assets/data/clark_county_schools.json

Usage:
    cd /path/to/flutter/project
    python3 download_schools_data.py
"""

import json, os, requests

ARCGIS_PORTAL = "https://www.arcgis.com"
ITEM_ID = "ca9eba42cebc4b0c965ffe80a3923978"  # Schools item

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_PATH = os.path.join(SCRIPT_DIR, 'assets', 'data', 'clark_county_schools.json')

NEVADA_BBOX = {
    'xmin': -120.0, 'ymin': 34.99,
    'xmax': -114.04, 'ymax': 42.0,
}


def resolve_service_url(item_id):
    print('Step 1: Resolving feature service URL...')
    r = requests.get(f'{ARCGIS_PORTAL}/sharing/rest/content/items/{item_id}',
                      params={'f': 'json'}, timeout=60)
    r.raise_for_status()
    item = r.json()
    if item.get('url'):
        return item['url']

    r = requests.get(f'{ARCGIS_PORTAL}/sharing/rest/content/items/{item_id}/data',
                      params={'f': 'json'}, timeout=60)
    r.raise_for_status()
    webmap = r.json()
    for layer in webmap.get('operationalLayers', []):
        url = layer.get('url', '')
        if 'MapServer' in url or 'FeatureServer' in url:
            return url
    raise Exception('Could not resolve service URL')


def list_layers(service_url):
    r = requests.get(service_url.rstrip('/'), params={'f': 'json'}, timeout=60)
    r.raise_for_status()
    return r.json().get('layers', [])


def query_all_features(layer_url):
    print(f'  Querying: {layer_url}')
    all_features = []
    offset = 0
    page_size = 1000
    while True:
        params = {
            'f': 'json',
            'where': '1=1',
            'outFields': '*',
            'returnGeometry': 'true',
            'outSR': '4326',
            'resultOffset': offset,
            'resultRecordCount': page_size,
        }
        r = requests.get(f'{layer_url.rstrip("/")}/query', params=params, timeout=60)
        if r.status_code != 200:
            print(f'    HTTP {r.status_code}, stopping')
            break
        data = r.json()
        if 'error' in data:
            print(f'    Error: {data["error"]}, stopping')
            break
        feats = data.get('features', [])
        all_features.extend(feats)
        print(f'    Got {len(feats)} (total {len(all_features)})')
        if len(feats) < page_size:
            break
        offset += page_size
    return all_features


def normalize_feature(f, layer_name):
    geom = f.get('geometry')
    attrs = f.get('attributes', {})
    if not geom:
        return None

    name = None
    for key in ['NAME', 'Name', 'SCHOOL_NAME', 'SCHOOLNAME', 'FACILITY_N', 'School_Name']:
        if attrs.get(key):
            name = str(attrs[key])
            break

    if 'rings' in geom:
        ring = geom['rings'][0]
        # bbox check using first vertex
        x0, y0 = ring[0][0], ring[0][1]
        if not (NEVADA_BBOX['xmin'] <= x0 <= NEVADA_BBOX['xmax'] and
                NEVADA_BBOX['ymin'] <= y0 <= NEVADA_BBOX['ymax']):
            return None

        # centroid for icon placement
        xs = [p[0] for p in ring]
        ys = [p[1] for p in ring]
        clon = sum(xs) / len(xs)
        clat = sum(ys) / len(ys)

        return {
            'type': 'Polygon',
            'lon': clon,
            'lat': clat,
            'rings': geom['rings'],
            'name': name or 'School',
            'layer': layer_name,
            'attributes': {k: v for k, v in attrs.items() if v is not None},
        }

    elif 'x' in geom and 'y' in geom:
        x, y = geom['x'], geom['y']
        if not (NEVADA_BBOX['xmin'] <= x <= NEVADA_BBOX['xmax'] and
                NEVADA_BBOX['ymin'] <= y <= NEVADA_BBOX['ymax']):
            return None

        return {
            'type': 'Point',
            'lon': x,
            'lat': y,
            'rings': None,
            'name': name or 'School',
            'layer': layer_name,
            'attributes': {k: v for k, v in attrs.items() if v is not None},
        }

    return None


def main():
    service_url = resolve_service_url(ITEM_ID)
    print(f'  Service URL: {service_url}')

    layers = list_layers(service_url)
    print(f'Step 2: Found {len(layers)} layer(s)')
    for l in layers:
        print(f'  - {l["id"]}: {l.get("name")}')

    features = []
    for layer in layers:
        layer_id = layer['id']
        layer_name = layer.get('name', f'Layer {layer_id}')
        layer_url = f'{service_url.rstrip("/")}/{layer_id}'
        raw = query_all_features(layer_url)
        for f in raw:
            norm = normalize_feature(f, layer_name)
            if norm:
                features.append(norm)

    print(f'Step 3: Writing {len(features)} school points...')
    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    with open(OUT_PATH, 'w') as fh:
        json.dump({'features': features}, fh, separators=(',', ':'))

    size_kb = os.path.getsize(OUT_PATH) / 1024
    print(f'✔ Written → {OUT_PATH} ({size_kb:.0f} KB)')
    print()
    print('Add to pubspec.yaml:')
    print('  flutter:')
    print('    assets:')
    print('      - assets/data/clark_county_schools.json')


if __name__ == '__main__':
    main()