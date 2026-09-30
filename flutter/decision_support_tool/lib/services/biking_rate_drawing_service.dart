// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'dart:math' as math;

// class BikingRateDrawingResult {
//   final int tractCount;
//   final String matchedAddress;
//   final double lon;
//   final double lat;
//   final double simpleAverage;
//   final double weightedAverage;
//   final String answer;
//   final List<TractInfo> tracts;
//   final List<List<double>>? drawnPolygon;

//   BikingRateDrawingResult({
//     required this.tractCount,
//     required this.matchedAddress,
//     required this.lon,
//     required this.lat,
//     required this.simpleAverage,
//     required this.weightedAverage,
//     required this.answer,
//     required this.tracts,
//     this.drawnPolygon,
//   });
// }

// class TractInfo {
//   final String geoid;
//   final String tractLabel;
//   final double? bikeRate;

//   /// Area of the intersection of this tract with the drawn polygon (sq miles).
//   final double areaSqMiles;
//   final String bucket;
//   final double points;

//   /// Full tract polygon ring as [lon, lat] pairs — used for map rendering.
//   final List<List<double>> geometry;

//   /// Clipped intersection polygon — may be empty if clip failed.
//   final List<List<double>> clippedGeometry;

//   TractInfo({
//     required this.geoid,
//     required this.tractLabel,
//     required this.bikeRate,
//     required this.areaSqMiles,
//     required this.bucket,
//     required this.points,
//     required this.geometry,
//     required this.clippedGeometry,
//   });
// }

// class BikingRateDrawingService {
//   static const String _tigerServiceRoot =
//       'https://tigerweb.geo.census.gov/arcgis/rest/services/Census2020/Tracts_Blocks/MapServer';
//   static const int _year = 2020;
//   static const String _stateFips = '32'; // Nevada
//   static const String _countyFips = '003'; // Clark County
//   static const String _acsVar = 'S0801_C01_011E'; // Bike-to-work percentage

//   // Optional Census API key (not required for basic use)
//   static const String? _censusApiKey = null;

//   /// Main entry point: geocode address, find intersecting Census Tracts,
//   /// fetch ACS bike-to-work rates, compute averages, return result.
//   static Future<BikingRateDrawingResult> calculateFromPolygon({
//     required String address,
//     required List<List<double>> polygonPoints,
//   }) async {
//     print('=== Biking Rate Calculation Starting ===');

//     try {
//       print('Step 1: Geocoding address...');
//       final geocodeResult = await _geocodeAddress(address);
//       final lon = geocodeResult['lon'] as double;
//       final lat = geocodeResult['lat'] as double;
//       final matched = geocodeResult['matched'] as String;
//       print('✓ Geocoded: $matched at ($lon, $lat)');

//       print('Step 2: Discovering Census Tract layer...');
//       final tractLayerId = await _discoverTractLayerId();
//       print('✓ Using TIGERweb layer ID: $tractLayerId');

//       print('Step 3: Fetching intersecting Census Tracts from TIGERweb...');
//       final tigerFeatures = await _fetchIntersectingTracts(
//         polygonPoints,
//         tractLayerId,
//       );
//       print('✓ Found ${tigerFeatures.length} intersecting tracts');

//       print('Step 4: Fetching bike-to-work rates from Census API...');
//       final tractInfoList = <TractInfo>[];
//       double sumRate = 0.0;
//       int countWithRate = 0;
//       double weightedSum = 0.0;
//       double totalArea = 0.0;

//       for (final tigerFeat in tigerFeatures) {
//         final geoid = tigerFeat['geoid'] as String;
//         final tractPolygon = tigerFeat['geometry'] as List<List<double>>;

//         // Area of the INTERSECTION of this tract with the drawn polygon.
//         // Use Sutherland-Hodgman as a fast path when it succeeds cleanly,
//         // otherwise fall back to point-sampling over the overlap bbox.
//         final clipped = _clipPolygon(tractPolygon, polygonPoints);
//         final double areaSqMiles;
//         if (clipped.length >= 3) {
//           final shArea = _polygonAreaSqMiles(clipped);
//           // S-H can return spurious large values for non-convex inputs;
//           // cross-check with sampling — if S-H result looks too large, use sampling.
//           final sampledArea = _estimateIntersectionArea(
//             tractPolygon,
//             polygonPoints,
//           );
//           // Use S-H if it's plausible (within 2x of sampled), else sampling
//           areaSqMiles = (sampledArea > 0 && shArea > sampledArea * 2.5)
//               ? sampledArea
//               : shArea;
//         } else {
//           // Clip failed — use point-sampling directly
//           areaSqMiles = _estimateIntersectionArea(tractPolygon, polygonPoints);
//         }

//         // Fetch rate from Census ACS API
//         final bikeRate = await _fetchBikeRateForTract(geoid);

//         final tractLabel = _tractLabelFromGeoid(geoid);
//         final bucketInfo = _getDstBucket(bikeRate ?? 0.0);

//         tractInfoList.add(
//           TractInfo(
//             geoid: geoid,
//             tractLabel: tractLabel,
//             bikeRate: bikeRate,
//             areaSqMiles: areaSqMiles,
//             bucket: bucketInfo['bucket'] as String,
//             points: bucketInfo['points'] as double,
//             geometry: tractPolygon,
//             clippedGeometry: clipped,
//           ),
//         );

//         if (bikeRate != null) {
//           sumRate += bikeRate;
//           countWithRate++;
//           weightedSum += bikeRate * areaSqMiles;
//           totalArea += areaSqMiles;
//         }

//         print(
//           '  Tract $tractLabel: ${bikeRate?.toStringAsFixed(1) ?? "N/A"}% '
//           '(${areaSqMiles.toStringAsFixed(4)} sq mi)',
//         );
//       }

//       final simpleAvg = countWithRate > 0 ? sumRate / countWithRate : 0.0;
//       final weightedAvg = totalArea > 0 ? weightedSum / totalArea : 0.0;

//       print('✓ Simple average: ${simpleAvg.toStringAsFixed(2)}%');
//       print('✓ Area-weighted average: ${weightedAvg.toStringAsFixed(2)}%');

//       final answer = _getAnswerFromRate(simpleAvg);
//       print('✓ DST answer: $answer');
//       print('=== Biking Rate Calculation Complete ===');

//       return BikingRateDrawingResult(
//         tractCount: tractInfoList.length,
//         matchedAddress: matched,
//         lon: lon,
//         lat: lat,
//         simpleAverage: simpleAvg,
//         weightedAverage: weightedAvg,
//         answer: answer,
//         tracts: tractInfoList,
//         drawnPolygon: polygonPoints,
//       );
//     } catch (e) {
//       print('Biking Rate Calculation Failed: $e');
//       rethrow;
//     }
//   }

//   // ─── TIGERweb helpers ─────────────────────────────────────────────────────

//   static Future<int> _discoverTractLayerId() async {
//     try {
//       final response = await http.get(Uri.parse('$_tigerServiceRoot?f=json'));
//       if (response.statusCode != 200) return 0;
//       final meta = jsonDecode(response.body) as Map<String, dynamic>;
//       final layers = meta['layers'] as List? ?? [];
//       for (final layer in layers) {
//         final m = layer as Map<String, dynamic>;
//         if ((m['name'] as String? ?? '').toLowerCase().contains(
//           'census tracts',
//         )) {
//           return (m['id'] as num).toInt();
//         }
//       }
//     } catch (e) {
//       print('  Could not auto-discover tract layer, using 0: $e');
//     }
//     return 0;
//   }

//   static Future<List<Map<String, dynamic>>> _fetchIntersectingTracts(
//     List<List<double>> polygon,
//     int layerId,
//   ) async {
//     final arcGeometry = _toArcgisPolygon(polygon);

//     final params = {
//       'f': 'json',
//       'where': "STATE='$_stateFips' AND COUNTY='$_countyFips'",
//       'outFields': 'GEOID,NAME,STATE,COUNTY,TRACT',
//       'returnGeometry': 'true',
//       'geometryType': 'esriGeometryPolygon',
//       'geometry': jsonEncode(arcGeometry),
//       'inSR': '4326',
//       'outSR': '4326',
//       'spatialRel': 'esriSpatialRelIntersects',
//       'resultRecordCount': '2000',
//     };

//     final url = Uri.parse(
//       '$_tigerServiceRoot/$layerId/query',
//     ).replace(queryParameters: params);
//     final response = await http.get(url);

//     if (response.statusCode != 200) {
//       throw Exception('TIGERweb query failed: HTTP ${response.statusCode}');
//     }
//     final data = jsonDecode(response.body) as Map<String, dynamic>;
//     if (data.containsKey('error')) {
//       throw Exception('TIGERweb error: ${data['error']}');
//     }

//     final features = data['features'] as List? ?? [];
//     if (features.isEmpty) {
//       throw Exception('No Census Tracts found. Try drawing a larger polygon.');
//     }

//     final results = <Map<String, dynamic>>[];
//     for (final feat in features) {
//       final fm = feat as Map<String, dynamic>;
//       final geoid =
//           ((fm['attributes'] as Map?) ?? {})['GEOID']?.toString() ?? '';
//       if (geoid.length != 11) continue; // skip blocks

//       final geom = fm['geometry'] as Map<String, dynamic>?;
//       final rings = geom?['rings'] as List?;
//       if (rings == null || rings.isEmpty) continue;

//       final ring = rings[0] as List;
//       final coords = ring.map((pt) {
//         final p = pt as List;
//         return [(p[0] as num).toDouble(), (p[1] as num).toDouble()];
//       }).toList();

//       results.add({'geoid': geoid, 'geometry': coords});
//     }
//     return results;
//   }

//   static Map<String, dynamic> _toArcgisPolygon(List<List<double>> polygon) {
//     final ring = polygon.map((p) => [p[0], p[1]]).toList();
//     if (ring.isNotEmpty) {
//       final f = ring.first, l = ring.last;
//       if (f[0] != l[0] || f[1] != l[1]) ring.add([f[0], f[1]]);
//     }
//     return {
//       'rings': [ring],
//       'spatialReference': {'wkid': 4326},
//     };
//   }

//   // ─── Census ACS API ───────────────────────────────────────────────────────

//   static Future<double?> _fetchBikeRateForTract(String geoid) async {
//     final tract6 = geoid.substring(5, 11);
//     final params = {
//       'get': 'NAME,$_acsVar',
//       'for': 'tract:$tract6',
//       'in': 'state:$_stateFips county:$_countyFips',
//     };
//     if (_censusApiKey != null) params['key'] = _censusApiKey!;

//     try {
//       final url = Uri.parse(
//         'https://api.census.gov/data/$_year/acs/acs5/subject',
//       ).replace(queryParameters: params);
//       final response = await http.get(url);
//       if (response.statusCode != 200) return null;

//       final data = jsonDecode(response.body) as List;
//       if (data.length < 2) return null;

//       final header = data[0] as List;
//       final row = data[1] as List;
//       final idx = header.indexOf(_acsVar);
//       if (idx < 0) return null;

//       final val = row[idx];
//       if (val == null || val.toString().isEmpty || val.toString() == 'null') {
//         return null;
//       }
//       return double.tryParse(val.toString());
//     } catch (e) {
//       print('  Warning: Census API error for tract $geoid: $e');
//       return null;
//     }
//   }

//   // ─── Geometry ─────────────────────────────────────────────────────────────

//   /// Sutherland-Hodgman clip of subjectPoly by convex clipPoly.
//   static List<List<double>> _clipPolygon(
//     List<List<double>> subject,
//     List<List<double>> clip,
//   ) {
//     if (subject.isEmpty || clip.isEmpty) return subject;
//     List<List<double>> output = List.from(subject);
//     final n = clip.length;
//     for (int i = 0; i < n - 1; i++) {
//       if (output.isEmpty) return [];
//       final A = clip[i], B = clip[i + 1];
//       final input = output;
//       output = [];
//       for (int j = 0; j < input.length; j++) {
//         final cur = input[j];
//         final prev = input[(j + input.length - 1) % input.length];
//         final curIn = _side(cur, A, B);
//         final prevIn = _side(prev, A, B);
//         if (curIn) {
//           if (!prevIn) output.add(_intersect(prev, cur, A, B));
//           output.add(cur);
//         } else if (prevIn) {
//           output.add(_intersect(prev, cur, A, B));
//         }
//       }
//     }
//     return output;
//   }

//   static bool _side(List<double> p, List<double> a, List<double> b) =>
//       (b[0] - a[0]) * (p[1] - a[1]) - (b[1] - a[1]) * (p[0] - a[0]) >= 0;

//   static List<double> _intersect(
//     List<double> a,
//     List<double> b,
//     List<double> c,
//     List<double> d,
//   ) {
//     final a1 = b[1] - a[1], b1 = a[0] - b[0], c1 = a1 * a[0] + b1 * a[1];
//     final a2 = d[1] - c[1], b2 = c[0] - d[0], c2 = a2 * c[0] + b2 * c[1];
//     final det = a1 * b2 - a2 * b1;
//     if (det.abs() < 1e-10) return a;
//     return [(b2 * c1 - b1 * c2) / det, (a1 * c2 - a2 * c1) / det];
//   }

//   /// Shoelace formula, converted to sq miles (approx for Clark County ~36°N).
//   static double _polygonAreaSqMiles(List<List<double>> poly) {
//     if (poly.length < 3) return 0.0;
//     double sum = 0.0;
//     final n = poly.length;
//     for (int i = 0; i < n; i++) {
//       final j = (i + 1) % n;
//       sum += poly[i][0] * poly[j][1] - poly[j][0] * poly[i][1];
//     }
//     return sum.abs() / 2.0 * 69.0 * 55.0;
//   }

//   /// Fallback when Sutherland-Hodgman clip fails (non-convex polygon).
//   /// Estimates intersection area by sampling a grid of points over the tract
//   /// bounding box and counting how many land inside both polygons.
//   static double _estimateIntersectionArea(
//     List<List<double>> tractPoly,
//     List<List<double>> drawnPoly,
//   ) {
//     if (tractPoly.length < 3 || drawnPoly.length < 3) return 0.0;

//     // Bounding box of TRACT
//     double tMinX = tractPoly[0][0], tMaxX = tractPoly[0][0];
//     double tMinY = tractPoly[0][1], tMaxY = tractPoly[0][1];
//     for (final p in tractPoly) {
//       if (p[0] < tMinX) tMinX = p[0];
//       if (p[0] > tMaxX) tMaxX = p[0];
//       if (p[1] < tMinY) tMinY = p[1];
//       if (p[1] > tMaxY) tMaxY = p[1];
//     }

//     // Bounding box of DRAWN polygon
//     double dMinX = drawnPoly[0][0], dMaxX = drawnPoly[0][0];
//     double dMinY = drawnPoly[0][1], dMaxY = drawnPoly[0][1];
//     for (final p in drawnPoly) {
//       if (p[0] < dMinX) dMinX = p[0];
//       if (p[0] > dMaxX) dMaxX = p[0];
//       if (p[1] < dMinY) dMinY = p[1];
//       if (p[1] > dMaxY) dMaxY = p[1];
//     }

//     // Sample over the INTERSECTION of both bounding boxes only.
//     // This concentrates all grid points where the overlap actually is,
//     // so even a tiny corner overlap gets proper coverage.
//     final minX = math.max(tMinX, dMinX);
//     final maxX = math.min(tMaxX, dMaxX);
//     final minY = math.max(tMinY, dMinY);
//     final maxY = math.min(tMaxY, dMaxY);

//     // No bbox overlap at all
//     if (minX >= maxX || minY >= maxY) return 0.0;

//     const gridN = 50; // 50x50 = 2500 sample points over the overlap bbox
//     int inside = 0;
//     final dx = (maxX - minX) / gridN;
//     final dy = (maxY - minY) / gridN;

//     for (int ix = 0; ix < gridN; ix++) {
//       for (int iy = 0; iy < gridN; iy++) {
//         final x = minX + (ix + 0.5) * dx;
//         final y = minY + (iy + 0.5) * dy;
//         if (_pointInPolygon(x, y, tractPoly) &&
//             _pointInPolygon(x, y, drawnPoly)) {
//           inside++;
//         }
//       }
//     }

//     // Area of one grid cell in sq miles, sum up all inside cells
//     final cellAreaSqMiles =
//         (dx * 69.0) * (dy * 55.0); // dx deg lon * dy deg lat -> sq mi
//     return inside * cellAreaSqMiles;
//   }

//   /// Ray-casting point-in-polygon test.
//   static bool _pointInPolygon(double x, double y, List<List<double>> poly) {
//     bool inside = false;
//     for (int i = 0, j = poly.length - 1; i < poly.length; j = i++) {
//       final xi = poly[i][0], yi = poly[i][1];
//       final xj = poly[j][0], yj = poly[j][1];
//       if (((yi > y) != (yj > y)) &&
//           (x < (xj - xi) * (y - yi) / (yj - yi) + xi)) {
//         inside = !inside;
//       }
//     }
//     return inside;
//   }

//   // ─── Buckets ──────────────────────────────────────────────────────────────

//   static Map<String, dynamic> _getDstBucket(double rate) {
//     if (rate <= 0.4) return {'bucket': '0-0.4%', 'points': 1.0};
//     if (rate <= 1.5) return {'bucket': '0.5-1.5%', 'points': 2.0};
//     if (rate <= 3.3) return {'bucket': '1.6-3.3%', 'points': 3.0};
//     if (rate <= 6.1) return {'bucket': '3.4-6.1%', 'points': 4.0};
//     return {'bucket': '6.2-11.5%', 'points': 5.0};
//   }

//   static String _getAnswerFromRate(double rate) {
//     if (rate <= 0.4) return '0-0.4%';
//     if (rate <= 1.5) return '0.5-1.5%';
//     if (rate <= 3.3) return '1.6-3.3%';
//     if (rate <= 6.1) return '3.4-6.1%';
//     return '6.2-11.5%';
//   }

//   static String _tractLabelFromGeoid(String geoid) {
//     if (geoid.length < 11) return geoid;
//     final t = geoid.substring(5, 11);
//     final a = t.substring(0, 4).replaceFirst(RegExp(r'^0+'), '');
//     return '${a.isEmpty ? "0" : a}.${t.substring(4)}';
//   }

//   // ─── Geocode ──────────────────────────────────────────────────────────────

//   static Future<Map<String, dynamic>> _geocodeAddress(String address) async {
//     final url = Uri.parse(
//       'https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates',
//     );
//     final params = {
//       'f': 'json',
//       'singleLine': address,
//       'outFields': 'Match_addr,Addr_type',
//       'maxLocations': '1',
//     };
//     final response = await http.get(
//       url.replace(queryParameters: params),
//       headers: {'Accept': 'application/json'},
//     );
//     if (response.statusCode != 200) {
//       throw Exception('Geocoding failed: HTTP ${response.statusCode}');
//     }
//     final data = jsonDecode(response.body) as Map<String, dynamic>;
//     final candidates = data['candidates'] as List?;
//     if (candidates == null || candidates.isEmpty) {
//       throw Exception('No geocoding results for: $address');
//     }
//     final best = candidates[0] as Map<String, dynamic>;
//     final location = best['location'] as Map<String, dynamic>?;
//     if (location == null) throw Exception('No location in geocoding result');
//     return {
//       'lon': (location['x'] as num).toDouble(),
//       'lat': (location['y'] as num).toDouble(),
//       'matched': (best['address'] as String?) ?? address,
//     };
//   }
// }

import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

// ─── Result models (unchanged public API) ─────────────────────────────────────

class BikingRateDrawingResult {
  final int tractCount;
  final String matchedAddress;
  final double lon;
  final double lat;
  final double simpleAverage;
  final double weightedAverage;
  final String answer;
  final List<TractInfo> tracts;
  final List<List<double>>? drawnPolygon;

  BikingRateDrawingResult({
    required this.tractCount,
    required this.matchedAddress,
    required this.lon,
    required this.lat,
    required this.simpleAverage,
    required this.weightedAverage,
    required this.answer,
    required this.tracts,
    this.drawnPolygon,
  });
}

class TractInfo {
  final String geoid;
  final String tractLabel;
  final double? bikeRate;
  final double areaSqMiles;
  final String bucket;
  final double points;
  final List<List<double>> geometry;
  final List<List<double>> clippedGeometry;

  TractInfo({
    required this.geoid,
    required this.tractLabel,
    required this.bikeRate,
    required this.areaSqMiles,
    required this.bucket,
    required this.points,
    required this.geometry,
    required this.clippedGeometry,
  });
}

// ─── Service ──────────────────────────────────────────────────────────────────

/// Biking-rate service that reads tract geometry + ACS rates from a local
/// asset file (assets/data/nevada_biking_rate.json) instead of calling
/// the Census API at runtime.
///
/// The asset file covers Clark + Washoe counties (every jurisdiction the
/// PST app supports) and is built once by running:
///   python3 data_processing/Q2/download_biking_rate_data.py
///
/// File format (GeoJSON FeatureCollection):
/// {
///   "type": "FeatureCollection",
///   "features": [{
///     "type": "Feature",
///     "properties": {
///       "GEOID":    "32003510800",
///       "TRACTCE":  "510800",
///       "COUNTYFP": "003",
///       "NAME":     "51.08",
///       "bikeRate": 0.7          // % who bike to work; null if suppressed
///     },
///     "geometry": { "type": "Polygon", "coordinates": [[[lon,lat],...]] }
///   }, ...]
/// }
class BikingRateDrawingService {
  static const String _assetPath = 'assets/data/nevada_biking_rate.json';

  /// Cache – loaded once per app session.
  static List<Map<String, dynamic>>? _cachedFeatures;

  // ── Public entry point ────────────────────────────────────────────────────

  static Future<BikingRateDrawingResult> calculateFromPolygon({
    required String address,
    required List<List<double>> polygonPoints,
  }) async {
    print('=== Biking Rate Calculation (local data) Starting ===');

    try {
      // Step 1 – geocode the typed address for the map pin
      print('Step 1: Geocoding address...');
      final geocodeResult = await _geocodeAddress(address);
      final lon = geocodeResult['lon'] as double;
      final lat = geocodeResult['lat'] as double;
      final matched = geocodeResult['matched'] as String;
      print('✔ Geocoded: $matched at ($lon, $lat)');

      // Step 2 – load local tract data
      print('Step 2: Loading local tract data...');
      final features = await _loadLocalTractData();
      print('✔ Loaded ${features.length} tracts from asset');

      // Step 3 – find tracts whose geometry intersects the drawn polygon
      print('Step 3: Finding intersecting tracts...');
      final intersecting = _findIntersectingTracts(features, polygonPoints);
      print('✔ Found ${intersecting.length} intersecting tracts');

      if (intersecting.isEmpty) {
        throw Exception(
          'No Census Tracts found inside your drawn area.\n'
          'Try drawing a larger polygon.',
        );
      }

      // Step 4 – compute area-weighted average biking rate
      print('Step 4: Computing area-weighted biking rate...');
      final tractInfoList = <TractInfo>[];
      double sumRate = 0.0;
      int countWithRate = 0;
      double weightedSum = 0.0;
      double totalArea = 0.0;

      for (final feat in intersecting) {
        final props = feat['properties'] as Map<String, dynamic>;
        final geoid = props['GEOID'] as String;
        final tractLabel = props['NAME'] as String;
        final bikeRateRaw = props['bikeRate'];
        final double? bikeRate = bikeRateRaw != null
            ? (bikeRateRaw as num).toDouble()
            : null;

        final geometry = feat['_ring'] as List<List<double>>;

        // Intersection area
        final clipped = _clipPolygon(geometry, polygonPoints);
        double areaSqMiles;
        if (clipped.length >= 3) {
          final shArea = _polygonAreaSqMiles(clipped);
          final sampledArea = _estimateIntersectionArea(
            geometry,
            polygonPoints,
          );
          areaSqMiles = (sampledArea > 0 && shArea > sampledArea * 2.5)
              ? sampledArea
              : shArea;
        } else {
          areaSqMiles = _estimateIntersectionArea(geometry, polygonPoints);
        }

        final bucketInfo = _getDstBucket(bikeRate ?? 0.0);

        tractInfoList.add(
          TractInfo(
            geoid: geoid,
            tractLabel: tractLabel,
            bikeRate: bikeRate,
            areaSqMiles: areaSqMiles,
            bucket: bucketInfo['bucket'] as String,
            points: bucketInfo['points'] as double,
            geometry: geometry,
            clippedGeometry: clipped,
          ),
        );

        if (bikeRate != null) {
          sumRate += bikeRate;
          countWithRate++;
          weightedSum += bikeRate * areaSqMiles;
          totalArea += areaSqMiles;
        }

        print(
          '  Tract $tractLabel: ${bikeRate?.toStringAsFixed(1) ?? "N/A"}% '
          '(${areaSqMiles.toStringAsFixed(4)} sq mi)',
        );
      }

      if (countWithRate == 0) {
        throw Exception(
          'Biking-rate data is not yet available for these tracts.\n\n'
          'Please run the download script to populate the data:\n'
          '  python3 download_biking_rate_data.py\n\n'
          'Then restart the app.',
        );
      }

      final simpleAvg = sumRate / countWithRate;
      final weightedAvg = totalArea > 0 ? weightedSum / totalArea : simpleAvg;

      print('✔ Simple average: ${simpleAvg.toStringAsFixed(2)}%');
      print('✔ Area-weighted average: ${weightedAvg.toStringAsFixed(2)}%');

      final answer = _getAnswerFromRate(simpleAvg);
      print('✔ DST answer: $answer');
      print('=== Biking Rate Calculation Complete ===');

      return BikingRateDrawingResult(
        tractCount: tractInfoList.length,
        matchedAddress: matched,
        lon: lon,
        lat: lat,
        simpleAverage: simpleAvg,
        weightedAverage: weightedAvg,
        answer: answer,
        tracts: tractInfoList,
        drawnPolygon: polygonPoints,
      );
    } catch (e) {
      print('Biking Rate Calculation Failed: $e');
      rethrow;
    }
  }

  // ── Local asset loading ───────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> _loadLocalTractData() async {
    if (_cachedFeatures != null) {
      print('  Using cached tract data (${_cachedFeatures!.length} tracts)');
      return _cachedFeatures!;
    }

    print('  Loading from $_assetPath ...');
    final jsonString = await rootBundle.loadString(_assetPath);
    final geojson = jsonDecode(jsonString) as Map<String, dynamic>;
    final rawFeatures = geojson['features'] as List;

    final features = <Map<String, dynamic>>[];
    for (final raw in rawFeatures) {
      final f = raw as Map<String, dynamic>;
      final geom = f['geometry'] as Map<String, dynamic>?;
      if (geom == null) continue;

      final type = geom['type'] as String;
      final coords = geom['coordinates'] as List;

      // Extract the outer ring (first ring of first polygon)
      List<dynamic> outerRing;
      if (type == 'Polygon') {
        outerRing = coords[0] as List;
      } else if (type == 'MultiPolygon') {
        // Use the largest ring
        outerRing = (coords[0] as List)[0] as List;
        for (final poly in coords) {
          final ring = (poly as List)[0] as List;
          if (ring.length > outerRing.length) outerRing = ring;
        }
      } else {
        continue;
      }

      final ring = outerRing.map<List<double>>((pt) {
        final p = pt as List;
        return [(p[0] as num).toDouble(), (p[1] as num).toDouble()];
      }).toList();

      // Stash the parsed ring directly on the feature map for fast access
      features.add({'properties': f['properties'], '_ring': ring});
    }

    _cachedFeatures = features;
    print('  Loaded and parsed ${features.length} tracts');
    return features;
  }

  // ── Intersection detection ────────────────────────────────────────────────

  /// Returns features whose bounding box + centroid or edge overlaps the drawn
  /// polygon.  Uses a fast bbox pre-filter then a proper polygon-intersection
  /// check.
  static List<Map<String, dynamic>> _findIntersectingTracts(
    List<Map<String, dynamic>> features,
    List<List<double>> drawnPolygon,
  ) {
    // Bounding box of the drawn polygon
    double dMinX = drawnPolygon[0][0], dMaxX = drawnPolygon[0][0];
    double dMinY = drawnPolygon[0][1], dMaxY = drawnPolygon[0][1];
    for (final p in drawnPolygon) {
      if (p[0] < dMinX) dMinX = p[0];
      if (p[0] > dMaxX) dMaxX = p[0];
      if (p[1] < dMinY) dMinY = p[1];
      if (p[1] > dMaxY) dMaxY = p[1];
    }

    final result = <Map<String, dynamic>>[];

    for (final feat in features) {
      final ring = feat['_ring'] as List<List<double>>;
      if (ring.isEmpty) continue;

      // Fast bbox pre-filter
      double tMinX = ring[0][0], tMaxX = ring[0][0];
      double tMinY = ring[0][1], tMaxY = ring[0][1];
      for (final p in ring) {
        if (p[0] < tMinX) tMinX = p[0];
        if (p[0] > tMaxX) tMaxX = p[0];
        if (p[1] < tMinY) tMinY = p[1];
        if (p[1] > tMaxY) tMaxY = p[1];
      }

      // No bbox overlap → skip
      if (tMaxX < dMinX || tMinX > dMaxX || tMaxY < dMinY || tMinY > dMaxY) {
        continue;
      }

      // Proper intersection: any tract vertex inside drawn polygon,
      // OR any drawn vertex inside tract polygon,
      // OR polygon edges cross.
      if (_polygonsIntersect(ring, drawnPolygon)) {
        result.add(feat);
      }
    }

    return result;
  }

  /// True when two polygons have any overlap (vertex-in-polygon or edge-cross).
  static bool _polygonsIntersect(List<List<double>> a, List<List<double>> b) {
    // 1. Any vertex of A inside B?
    for (final p in a) {
      if (_pointInPolygon(p[0], p[1], b)) return true;
    }
    // 2. Any vertex of B inside A?
    for (final p in b) {
      if (_pointInPolygon(p[0], p[1], a)) return true;
    }
    // 3. Edge intersection (handles the case where one polygon is entirely
    //    inside the other but no vertices were caught above, e.g. a tiny
    //    drawn polygon inside a large tract)
    for (int i = 0; i < a.length - 1; i++) {
      for (int j = 0; j < b.length - 1; j++) {
        if (_segmentsIntersect(a[i], a[i + 1], b[j], b[j + 1])) return true;
      }
    }
    return false;
  }

  static bool _segmentsIntersect(
    List<double> p1,
    List<double> p2,
    List<double> p3,
    List<double> p4,
  ) {
    final d1 = _cross(p3, p4, p1);
    final d2 = _cross(p3, p4, p2);
    final d3 = _cross(p1, p2, p3);
    final d4 = _cross(p1, p2, p4);
    if (((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
        ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0)))
      return true;
    return false;
  }

  static double _cross(List<double> o, List<double> a, List<double> b) =>
      (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0]);

  // ── Geometry helpers ──────────────────────────────────────────────────────

  /// Sutherland-Hodgman clip of subject by clip polygon.
  static List<List<double>> _clipPolygon(
    List<List<double>> subject,
    List<List<double>> clip,
  ) {
    if (subject.isEmpty || clip.isEmpty) return subject;
    List<List<double>> output = List.from(subject);
    final n = clip.length;
    for (int i = 0; i < n - 1; i++) {
      if (output.isEmpty) return [];
      final A = clip[i], B = clip[i + 1];
      final input = output;
      output = [];
      for (int j = 0; j < input.length; j++) {
        final cur = input[j];
        final prev = input[(j + input.length - 1) % input.length];
        final curIn = _side(cur, A, B);
        final prevIn = _side(prev, A, B);
        if (curIn) {
          if (!prevIn) output.add(_intersect(prev, cur, A, B));
          output.add(cur);
        } else if (prevIn) {
          output.add(_intersect(prev, cur, A, B));
        }
      }
    }
    return output;
  }

  static bool _side(List<double> p, List<double> a, List<double> b) =>
      (b[0] - a[0]) * (p[1] - a[1]) - (b[1] - a[1]) * (p[0] - a[0]) >= 0;

  static List<double> _intersect(
    List<double> a,
    List<double> b,
    List<double> c,
    List<double> d,
  ) {
    final a1 = b[1] - a[1], b1 = a[0] - b[0], c1 = a1 * a[0] + b1 * a[1];
    final a2 = d[1] - c[1], b2 = c[0] - d[0], c2 = a2 * c[0] + b2 * c[1];
    final det = a1 * b2 - a2 * b1;
    if (det.abs() < 1e-10) return a;
    return [(b2 * c1 - b1 * c2) / det, (a1 * c2 - a2 * c1) / det];
  }

  /// Shoelace → sq miles (approx for Clark County ~36 °N).
  static double _polygonAreaSqMiles(List<List<double>> poly) {
    if (poly.length < 3) return 0.0;
    double sum = 0.0;
    final n = poly.length;
    for (int i = 0; i < n; i++) {
      final j = (i + 1) % n;
      sum += poly[i][0] * poly[j][1] - poly[j][0] * poly[i][1];
    }
    return sum.abs() / 2.0 * 69.0 * 55.0;
  }

  /// Grid-sampling fallback for non-convex polygons.
  static double _estimateIntersectionArea(
    List<List<double>> tractPoly,
    List<List<double>> drawnPoly,
  ) {
    if (tractPoly.length < 3 || drawnPoly.length < 3) return 0.0;

    double tMinX = tractPoly[0][0], tMaxX = tractPoly[0][0];
    double tMinY = tractPoly[0][1], tMaxY = tractPoly[0][1];
    for (final p in tractPoly) {
      if (p[0] < tMinX) tMinX = p[0];
      if (p[0] > tMaxX) tMaxX = p[0];
      if (p[1] < tMinY) tMinY = p[1];
      if (p[1] > tMaxY) tMaxY = p[1];
    }

    double dMinX = drawnPoly[0][0], dMaxX = drawnPoly[0][0];
    double dMinY = drawnPoly[0][1], dMaxY = drawnPoly[0][1];
    for (final p in drawnPoly) {
      if (p[0] < dMinX) dMinX = p[0];
      if (p[0] > dMaxX) dMaxX = p[0];
      if (p[1] < dMinY) dMinY = p[1];
      if (p[1] > dMaxY) dMaxY = p[1];
    }

    final minX = math.max(tMinX, dMinX);
    final maxX = math.min(tMaxX, dMaxX);
    final minY = math.max(tMinY, dMinY);
    final maxY = math.min(tMaxY, dMaxY);
    if (minX >= maxX || minY >= maxY) return 0.0;

    const gridN = 50;
    int inside = 0;
    final dx = (maxX - minX) / gridN;
    final dy = (maxY - minY) / gridN;
    for (int ix = 0; ix < gridN; ix++) {
      for (int iy = 0; iy < gridN; iy++) {
        final x = minX + (ix + 0.5) * dx;
        final y = minY + (iy + 0.5) * dy;
        if (_pointInPolygon(x, y, tractPoly) &&
            _pointInPolygon(x, y, drawnPoly)) {
          inside++;
        }
      }
    }
    return inside * (dx * 69.0) * (dy * 55.0);
  }

  static bool _pointInPolygon(double x, double y, List<List<double>> poly) {
    bool inside = false;
    for (int i = 0, j = poly.length - 1; i < poly.length; j = i++) {
      final xi = poly[i][0], yi = poly[i][1];
      final xj = poly[j][0], yj = poly[j][1];
      if (((yi > y) != (yj > y)) &&
          (x < (xj - xi) * (y - yi) / (yj - yi) + xi)) {
        inside = !inside;
      }
    }
    return inside;
  }

  // ── DST buckets ───────────────────────────────────────────────────────────

  static Map<String, dynamic> _getDstBucket(double rate) {
    final r = double.parse(rate.toStringAsFixed(1));
    if (r <= 0.4) return {'bucket': '0-0.4%', 'points': 1.0};
    if (r <= 1.5) return {'bucket': '0.5-1.5%', 'points': 2.0};
    if (r <= 3.3) return {'bucket': '1.6-3.3%', 'points': 3.0};
    if (r <= 6.1) return {'bucket': '3.4-6.1%', 'points': 4.0};
    return {'bucket': '6.2-11.5%', 'points': 5.0};
  }

  static String _getAnswerFromRate(double rate) {
    final r = double.parse(rate.toStringAsFixed(1));
    if (r <= 0.4) return '0-0.4%';
    if (r <= 1.5) return '0.5-1.5%';
    if (r <= 3.3) return '1.6-3.3%';
    if (r <= 6.1) return '3.4-6.1%';
    return '6.2-11.5%';
  }

  // ── Geocode ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> _geocodeAddress(String address) async {
    final url = Uri.parse(
      'https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates',
    );
    final params = {
      'f': 'json',
      'singleLine': address,
      'outFields': 'Match_addr,Addr_type',
      'maxLocations': '1',
    };
    final response = await http.get(
      url.replace(queryParameters: params),
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Geocoding failed: HTTP ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('No geocoding results for: $address');
    }
    final best = candidates[0] as Map<String, dynamic>;
    final location = best['location'] as Map<String, dynamic>?;
    if (location == null) throw Exception('No location in geocoding result');
    return {
      'lon': (location['x'] as num).toDouble(),
      'lat': (location['y'] as num).toDouble(),
      'matched': (best['address'] as String?) ?? address,
    };
  }

  /// Clear the in-memory cache (call if the asset file has been updated).
  static void clearCache() {
    _cachedFeatures = null;
    print('Biking rate cache cleared');
  }
}
