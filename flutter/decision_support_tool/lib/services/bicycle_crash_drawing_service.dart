// import 'dart:convert';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:http/http.dart' as http;
// import 'dart:math' as math;

// class BicycleCrashDrawingResult {
//   final int count;
//   final String matchedAddress;
//   final double lon;
//   final double lat;
//   final double density;
//   final String answer;
//   final double areaSqMiles;
//   final List<Map<String, dynamic>> crashesInArea;
//   final List<List<double>>? drawnPolyline;

//   BicycleCrashDrawingResult({
//     required this.count,
//     required this.matchedAddress,
//     required this.lon,
//     required this.lat,
//     required this.density,
//     required this.answer,
//     required this.areaSqMiles,
//     required this.crashesInArea,
//     this.drawnPolyline,
//   });
// }

// class BicycleCrashDrawingService {
//   static const double _bufferMiles = 0.25;
//   static List<Map<String, dynamic>>? _cachedCrashFeatures;

//   static Future<BicycleCrashDrawingResult> calculateFromPolyline({
//     required String address,
//     required List<List<double>> polylinePoints,
//   }) async {
//     print('=== Bicycle Crash Drawing Calculation Starting ===');

//     try {
//       print('Step 1: Geocoding address...');
//       final geocodeResult = await _geocodeAddress(address);
//       final lon = geocodeResult['lon'] as double;
//       final lat = geocodeResult['lat'] as double;
//       final matched = geocodeResult['matched'] as String;
//       print('✓ Geocoded: $matched at ($lon, $lat)');

//       print('Step 2: Loading crash data...');
//       final crashFeatures = await _loadCrashDataFromAsset();
//       print('✓ Loaded ${crashFeatures.length} crash records');

//       print('Step 3: Creating buffer around polyline...');
//       final bufferedPolygon = _createBufferedPolygon(
//         polylinePoints,
//         _bufferMiles,
//       );
//       print('✓ Created buffered polygon with ${bufferedPolygon.length} points');

//       print('Step 4: Calculating area...');
//       final areaSqMiles = _calculatePolygonArea(bufferedPolygon);
//       // final areaSqMiles = math.pi * _bufferMiles * _bufferMiles;
//       print('✓ Area: ${areaSqMiles.toFixed(6)} sq miles');

//       print('Step 5: Counting crashes within drawn area...');
//       final crashesInArea = _filterCrashesInPolygon(
//         crashFeatures,
//         bufferedPolygon,
//       );
//       final count = crashesInArea.length;
//       print('✓ Found $count crashes within drawn area');

//       final density = areaSqMiles > 0 ? count / areaSqMiles : 0.0;
//       final densityRounded = density.round();
//       print(
//         '✓ Density: ${density.toFixed(2)} crashes/sq mi (rounded: $densityRounded)',
//       );

//       final answer = _getAnswerFromDensity(densityRounded);
//       print('✓ Answer range: $answer');

//       print('=== Bicycle Crash Drawing Calculation Complete ===');

//       return BicycleCrashDrawingResult(
//         count: count,
//         matchedAddress: matched,
//         lon: lon,
//         lat: lat,
//         density: density,
//         answer: answer,
//         areaSqMiles: areaSqMiles,
//         crashesInArea: crashesInArea,
//         drawnPolyline: polylinePoints,
//       );
//     } catch (e) {
//       print('Bicycle Crash Drawing Calculation Failed: $e');
//       rethrow;
//     }
//   }

//   static List<List<double>> _createBufferedPolygon(
//     List<List<double>> polylinePoints,
//     double bufferMiles,
//   ) {
//     if (polylinePoints.isEmpty) return [];
//     if (polylinePoints.length == 1) {
//       return _createCirclePoints(polylinePoints[0], bufferMiles, 64);
//     }

//     final bufferDegrees = bufferMiles / 69.0;
//     final bufferedPoints = <List<double>>[];
//     const arcSteps = 16;

//     for (int i = 0; i < polylinePoints.length; i++) {
//       final current = polylinePoints[i];

//       if (i == 0) {
//         final next = polylinePoints[i + 1];
//         final dx = next[0] - current[0];
//         final dy = next[1] - current[1];
//         final length = math.sqrt(dx * dx + dy * dy);

//         if (length > 0) {
//           final lineAngle = math.atan2(dy, dx);
//           for (int j = 0; j <= arcSteps; j++) {
//             final t = j / arcSteps;
//             final angle = lineAngle + math.pi / 2 + t * math.pi;
//             final x = current[0] + bufferDegrees * math.cos(angle);
//             final y = current[1] + bufferDegrees * math.sin(angle);
//             bufferedPoints.add([x, y]);
//           }
//         }
//       } else if (i == polylinePoints.length - 1) {
//         final prev = polylinePoints[i - 1];
//         final dx = current[0] - prev[0];
//         final dy = current[1] - prev[1];
//         final length = math.sqrt(dx * dx + dy * dy);

//         if (length > 0) {
//           final lineAngle = math.atan2(dy, dx);
//           final perpAngle = lineAngle - math.pi / 2;

//           bufferedPoints.add([
//             current[0] + bufferDegrees * math.cos(perpAngle),
//             current[1] + bufferDegrees * math.sin(perpAngle),
//           ]);

//           for (int j = 1; j <= arcSteps; j++) {
//             final t = j / arcSteps;
//             final angle = lineAngle - math.pi / 2 + t * math.pi;
//             bufferedPoints.add([
//               current[0] + bufferDegrees * math.cos(angle),
//               current[1] + bufferDegrees * math.sin(angle),
//             ]);
//           }
//         }
//       } else {
//         final prev = polylinePoints[i - 1];
//         final next = polylinePoints[i + 1];

//         final dx1 = current[0] - prev[0];
//         final dy1 = current[1] - prev[1];
//         final len1 = math.sqrt(dx1 * dx1 + dy1 * dy1);

//         final dx2 = next[0] - current[0];
//         final dy2 = next[1] - current[1];
//         final len2 = math.sqrt(dx2 * dx2 + dy2 * dy2);

//         if (len1 > 0 && len2 > 0) {
//           final angle1 = math.atan2(dy1, dx1);
//           final angle2 = math.atan2(dy2, dx2);
//           final perp1Angle = angle1 - math.pi / 2;
//           final perp2Angle = angle2 - math.pi / 2;

//           var deltaAngle = perp2Angle - perp1Angle;
//           while (deltaAngle > math.pi) deltaAngle -= 2 * math.pi;
//           while (deltaAngle < -math.pi) deltaAngle += 2 * math.pi;

//           if (deltaAngle.abs() > 0.01) {
//             final steps = (arcSteps * deltaAngle.abs() / math.pi).ceil().clamp(
//               4,
//               arcSteps,
//             );
//             for (int j = 0; j <= steps; j++) {
//               final t = j / steps;
//               final angle = perp1Angle + t * deltaAngle;
//               final x = current[0] + bufferDegrees * math.cos(angle);
//               final y = current[1] + bufferDegrees * math.sin(angle);
//               bufferedPoints.add([x, y]);
//             }
//           } else {
//             bufferedPoints.add([
//               current[0] + bufferDegrees * math.cos(perp1Angle),
//               current[1] + bufferDegrees * math.sin(perp1Angle),
//             ]);
//           }
//         }
//       }
//     }

//     for (int i = polylinePoints.length - 1; i >= 0; i--) {
//       if (i == 0 || i == polylinePoints.length - 1) continue;

//       final current = polylinePoints[i];
//       final prev = polylinePoints[i - 1];
//       final next = polylinePoints[i + 1];

//       final dx1 = current[0] - prev[0];
//       final dy1 = current[1] - prev[1];
//       final len1 = math.sqrt(dx1 * dx1 + dy1 * dy1);

//       final dx2 = next[0] - current[0];
//       final dy2 = next[1] - current[1];
//       final len2 = math.sqrt(dx2 * dx2 + dy2 * dy2);

//       if (len1 > 0 && len2 > 0) {
//         final angle1 = math.atan2(dy1, dx1);
//         final angle2 = math.atan2(dy2, dx2);
//         final perp1Angle = angle1 + math.pi / 2;
//         final perp2Angle = angle2 + math.pi / 2;

//         var deltaAngle = perp1Angle - perp2Angle;
//         while (deltaAngle > math.pi) deltaAngle -= 2 * math.pi;
//         while (deltaAngle < -math.pi) deltaAngle += 2 * math.pi;

//         if (deltaAngle.abs() > 0.01) {
//           final steps = (arcSteps * deltaAngle.abs() / math.pi).ceil().clamp(
//             4,
//             arcSteps,
//           );
//           for (int j = 0; j <= steps; j++) {
//             final t = j / steps;
//             final angle = perp2Angle + t * deltaAngle;
//             final x = current[0] + bufferDegrees * math.cos(angle);
//             final y = current[1] + bufferDegrees * math.sin(angle);
//             bufferedPoints.add([x, y]);
//           }
//         } else {
//           bufferedPoints.add([
//             current[0] + bufferDegrees * math.cos(perp1Angle),
//             current[1] + bufferDegrees * math.sin(perp1Angle),
//           ]);
//         }
//       }
//     }

//     if (bufferedPoints.isNotEmpty) {
//       bufferedPoints.add(bufferedPoints[0]);
//     }

//     return bufferedPoints;
//   }

//   static List<List<double>> _createCirclePoints(
//     List<double> center,
//     double radiusMiles,
//     int numPoints,
//   ) {
//     final radiusDegrees = radiusMiles / 69.0;
//     final points = <List<double>>[];
//     for (int i = 0; i <= numPoints; i++) {
//       final angle = (i * 2 * math.pi) / numPoints;
//       final x = center[0] + radiusDegrees * math.cos(angle);
//       final y = center[1] + radiusDegrees * math.sin(angle);
//       points.add([x, y]);
//     }
//     return points;
//   }

//   static double _calculatePolygonArea(List<List<double>> polygonPoints) {
//     if (polygonPoints.length < 3) return 0.0;
//     double area = 0.0;
//     for (int i = 0; i < polygonPoints.length - 1; i++) {
//       final p1 = polygonPoints[i];
//       final p2 = polygonPoints[i + 1];
//       area += p1[0] * p2[1] - p2[0] * p1[1];
//     }
//     area = area.abs() / 2.0;
//     final avgLat =
//         polygonPoints.map((p) => p[1]).reduce((a, b) => a + b) /
//         polygonPoints.length;
//     final latFactor = math.cos(avgLat * math.pi / 180.0);
//     final sqMiles = area * 4761.0 * latFactor;
//     return sqMiles;
//   }

//   static List<Map<String, dynamic>> _filterCrashesInPolygon(
//     List<Map<String, dynamic>> crashFeatures,
//     List<List<double>> polygon,
//   ) {
//     final filtered = <Map<String, dynamic>>[];

//     print(
//       '  Checking ${crashFeatures.length} crashes against polygon with ${polygon.length} points',
//     );

//     for (final feature in crashFeatures) {
//       final geometry = feature['geometry'] as Map<String, dynamic>?;
//       if (geometry == null) continue;
//       final coords = geometry['coordinates'] as List?;
//       if (coords == null || coords.length < 2) continue;
//       final crashLon = (coords[0] as num).toDouble();
//       final crashLat = (coords[1] as num).toDouble();

//       if (_isPointInPolygonRobust(crashLon, crashLat, polygon)) {
//         filtered.add(feature);
//       }
//     }

//     return filtered;
//   }

//   /// Robust point-in-polygon test using winding number algorithm
//   /// This is more reliable than ray-casting for complex polygons
//   static bool _isPointInPolygonRobust(
//     double x,
//     double y,
//     List<List<double>> polygon,
//   ) {
//     if (polygon.length < 3) return false;

//     int windingNumber = 0;

//     for (int i = 0; i < polygon.length - 1; i++) {
//       final x1 = polygon[i][0];
//       final y1 = polygon[i][1];
//       final x2 = polygon[i + 1][0];
//       final y2 = polygon[i + 1][1];

//       if (y1 <= y) {
//         if (y2 > y) {
//           // Upward crossing
//           final cross = (x2 - x1) * (y - y1) - (x - x1) * (y2 - y1);
//           if (cross > 0) {
//             windingNumber++;
//           }
//         }
//       } else {
//         if (y2 <= y) {
//           // Downward crossing
//           final cross = (x2 - x1) * (y - y1) - (x - x1) * (y2 - y1);
//           if (cross < 0) {
//             windingNumber--;
//           }
//         }
//       }
//     }

//     return windingNumber != 0;
//   }

//   static Future<List<Map<String, dynamic>>> _loadCrashDataFromAsset() async {
//     if (_cachedCrashFeatures != null) {
//       return _cachedCrashFeatures!;
//     }

//     final possiblePaths = [
//       'assets/data/crashes_bicyclist.csv',
//       'data/crashes_bicyclist.csv',
//       'assets/crashes_bicyclist.csv',
//     ];

//     String? csvString;
//     for (final path in possiblePaths) {
//       try {
//         csvString = await rootBundle.loadString(path);
//         print('  ✓ Loaded from: $path');
//         break;
//       } catch (e) {
//         continue;
//       }
//     }

//     if (csvString == null) {
//       throw Exception('Failed to load bicycle crash CSV');
//     }

//     final lines = csvString.split('\n');
//     final header = lines[0].split(',').map((h) => h.trim()).toList();

//     int? xIndex;
//     int? yIndex;
//     for (int i = 0; i < header.length; i++) {
//       final col = header[i].toLowerCase();
//       if (col == 'x' || col == 'pointx' || col == 'easting') xIndex = i;
//       if (col == 'y' || col == 'pointy' || col == 'northing') yIndex = i;
//     }

//     if (xIndex == null || yIndex == null) {
//       throw Exception('Could not find X and Y columns');
//     }

//     final features = <Map<String, dynamic>>[];
//     for (int i = 1; i < lines.length; i++) {
//       final line = lines[i].trim();
//       if (line.isEmpty) continue;

//       final values = line.split(',');
//       if (values.length <= math.max(xIndex, yIndex)) continue;

//       try {
//         final x = double.parse(values[xIndex].trim());
//         final y = double.parse(values[yIndex].trim());
//         final coords = _utmToLonLat(x, y, 11, true);

//         if (coords[0] < -120 ||
//             coords[0] > -114 ||
//             coords[1] < 35 ||
//             coords[1] > 42) {
//           continue;
//         }

//         final properties = <String, dynamic>{};
//         for (int j = 0; j < header.length && j < values.length; j++) {
//           if (j != xIndex && j != yIndex) {
//             properties[header[j]] = values[j].trim();
//           }
//         }

//         features.add({
//           'geometry': {
//             'type': 'Point',
//             'coordinates': [coords[0], coords[1]],
//           },
//           'properties': properties,
//         });
//       } catch (e) {
//         continue;
//       }
//     }

//     _cachedCrashFeatures = features;
//     return features;
//   }

//   static List<double> _utmToLonLat(
//     double easting,
//     double northing,
//     int zoneNumber,
//     bool northern,
//   ) {
//     const a = 6378137.0;
//     const e = 0.08181919084262149;
//     const e1sq = 0.006739496742276434;
//     const k0 = 0.9996;
//     final x = easting - 500000.0;
//     var y = northing;
//     if (!northern) y -= 10000000.0;
//     final m = y / k0;
//     final mu = m / (a * (1 - e * e / 4 - 3 * e * e * e * e / 64));
//     final e1 = (1 - math.sqrt(1 - e * e)) / (1 + math.sqrt(1 - e * e));
//     final j1 = 3 * e1 / 2 - 27 * math.pow(e1, 3) / 32;
//     final j2 = 21 * e1 * e1 / 16 - 55 * math.pow(e1, 4) / 32;
//     final j3 = 151 * math.pow(e1, 3) / 96;
//     final j4 = 1097 * math.pow(e1, 4) / 512;
//     final fp =
//         mu +
//         j1 * math.sin(2 * mu) +
//         j2 * math.sin(4 * mu) +
//         j3 * math.sin(6 * mu) +
//         j4 * math.sin(8 * mu);
//     final sinfp = math.sin(fp);
//     final cosfp = math.cos(fp);
//     final c1 = e1sq * cosfp * cosfp;
//     final t1 = math.tan(fp) * math.tan(fp);
//     final r1 = a * (1 - e * e) / math.pow(1 - (e * sinfp) * (e * sinfp), 1.5);
//     final n1 = a / math.sqrt(1 - (e * sinfp) * (e * sinfp));
//     final d = x / (n1 * k0);
//     final q1 = n1 * math.tan(fp) / r1;
//     final q2 = d * d / 2;
//     final q3 =
//         (5 + 3 * t1 + 10 * c1 - 4 * c1 * c1 - 9 * e1sq) * math.pow(d, 4) / 24;
//     final q4 =
//         (61 + 90 * t1 + 298 * c1 + 45 * t1 * t1 - 252 * e1sq - 3 * c1 * c1) *
//         math.pow(d, 6) /
//         720;
//     var lat = fp - q1 * (q2 - q3 + q4);
//     final q5 = d;
//     final q6 = (1 + 2 * t1 + c1) * math.pow(d, 3) / 6;
//     final q7 =
//         (5 - 2 * c1 + 28 * t1 - 3 * c1 * c1 + 8 * e1sq + 24 * t1 * t1) *
//         math.pow(d, 5) /
//         120;
//     var lon = (q5 - q6 + q7) / cosfp;
//     final lon0 = (zoneNumber - 1) * 6 - 180 + 3;
//     lon = lon0 + lon * (180.0 / math.pi);
//     lat = lat * (180.0 / math.pi);
//     return [lon, lat];
//   }

//   static Future<Map<String, dynamic>> _geocodeAddress(String address) async {
//     final geocodeUrl = Uri.parse(
//       'https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates',
//     );
//     final params = {
//       'f': 'json',
//       'singleLine': address,
//       'outFields': 'Match_addr,Addr_type',
//       'maxLocations': '1',
//     };
//     final response = await http.get(
//       geocodeUrl.replace(queryParameters: params),
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
//     if (location == null) {
//       throw Exception('No location in geocoding result');
//     }
//     final lon = location['x'];
//     final lat = location['y'];
//     final matchedAddress = best['address'] as String? ?? address;
//     return {
//       'lon': (lon as num).toDouble(),
//       'lat': (lat as num).toDouble(),
//       'matched': matchedAddress,
//     };
//   }

//   static String _getAnswerFromDensity(int densityRounded) {
//     if (densityRounded <= 4)
//       return '0-4';
//     else if (densityRounded <= 7)
//       return '5-7';
//     else if (densityRounded <= 10)
//       return '8-10';
//     else if (densityRounded <= 15)
//       return '11-15';
//     else
//       return '15+';
//   }

//   static void clearCache() {
//     _cachedCrashFeatures = null;
//   }
// }

// extension on double {
//   String toFixed(int decimals) => toStringAsFixed(decimals);
// }
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class BicycleCrashDrawingResult {
  final int count;
  final String matchedAddress;
  final double lon;
  final double lat;
  final double density;
  final String answer;
  final double areaSqMiles;
  final List<Map<String, dynamic>> crashesInArea;
  final List<List<double>>? drawnPolyline;

  BicycleCrashDrawingResult({
    required this.count,
    required this.matchedAddress,
    required this.lon,
    required this.lat,
    required this.density,
    required this.answer,
    required this.areaSqMiles,
    required this.crashesInArea,
    this.drawnPolyline,
  });
}

class BicycleCrashDrawingService {
  static const double _bufferMiles = 0.25;
  static List<Map<String, dynamic>>? _cachedCrashFeatures;

  static Future<BicycleCrashDrawingResult> calculateFromPolyline({
    required String address,
    required List<List<double>> polylinePoints,
  }) async {
    print('=== Bicycle Crash Drawing Calculation Starting ===');

    try {
      print('Step 1: Geocoding address...');
      final geocodeResult = await _geocodeAddress(address);
      final lon = geocodeResult['lon'] as double;
      final lat = geocodeResult['lat'] as double;
      final matched = geocodeResult['matched'] as String;
      print('âœ“ Geocoded: $matched at ($lon, $lat)');

      print('Step 2: Loading crash data...');
      final crashFeatures = await _loadCrashDataFromAsset();
      print('âœ“ Loaded ${crashFeatures.length} crash records');

      print('Step 3: Calculating buffer area (grid sampling)...');
      final areaSqMiles = _calculateBufferAreaGrid(polylinePoints, _bufferMiles);
      print('Area: ${areaSqMiles.toStringAsFixed(6)} sq miles');

      print('Step 4: Counting crashes within buffer...');
      final crashesInArea = _filterCrashesByDistance(
        crashFeatures,
        polylinePoints,
        _bufferMiles,
      );
      final count = crashesInArea.length;
      print('Found $count crashes within buffer');

      final density = areaSqMiles > 0 ? count / areaSqMiles : 0.0;
      final densityRounded = density.round();
      print('Density: ${density.toStringAsFixed(2)} crashes/sq mi (rounded: $densityRounded)');

      final answer = _getAnswerFromDensity(densityRounded);
      print('Answer range: $answer');

      print('=== Bicycle Crash Drawing Calculation Complete ===');

      return BicycleCrashDrawingResult(
        count: count,
        matchedAddress: matched,
        lon: lon,
        lat: lat,
        density: density,
        answer: answer,
        areaSqMiles: areaSqMiles,
        crashesInArea: crashesInArea,
        drawnPolyline: polylinePoints,
      );
    } catch (e) {
      print('Bicycle Crash Drawing Calculation Failed: $e');
      rethrow;
    }
  }

  static List<List<double>> _createBufferedPolygon(
    List<List<double>> polylinePoints,
    double bufferMiles,
  ) {
    if (polylinePoints.isEmpty) return [];
    if (polylinePoints.length == 1) {
      return _createCirclePoints(polylinePoints[0], bufferMiles, 64);
    }

    final pts = List<List<double>>.from(polylinePoints);
    final n = pts.length;
    final avgLat = pts.map((p) => p[1]).reduce((a, b) => a + b) / n;
    final lonToMiles = 69.0 * math.cos(avgLat * math.pi / 180.0);
    final latToMiles = 69.0;

    final closeDxMi = (pts.first[0] - pts.last[0]) * lonToMiles;
    final closeDyMi = (pts.first[1] - pts.last[1]) * latToMiles;
    final closeDistMi = math.sqrt(
      closeDxMi * closeDxMi + closeDyMi * closeDyMi,
    );

    if (closeDistMi < 0.031 && n >= 3) {
      return _createClosedPolygonBuffer(pts, bufferMiles, avgLat);
    }
    return _createOpenPolylineBuffer(pts, bufferMiles, avgLat);
  }

  static List<List<double>> _createClosedPolygonBuffer(
    List<List<double>> pts,
    double bufferMiles,
    double avgLat,
  ) {
    var ring = List<List<double>>.from(pts);
    final dx = ring.first[0] - ring.last[0];
    final dy = ring.first[1] - ring.last[1];
    if (math.sqrt(dx * dx + dy * dy) > 1e-10) {
      ring = [...ring, ring.first];
    }
    final closedRing = ring.sublist(0, ring.length - 1);
    final nn = closedRing.length;

    final bufferLatDeg = bufferMiles / 69.0;
    final bufferLonDeg =
        bufferMiles / (69.0 * math.cos(avgLat * math.pi / 180.0));
    final lonToMiles = 69.0 * math.cos(avgLat * math.pi / 180.0);
    final latToMiles = 69.0;

    double signedArea = 0.0;
    for (int i = 0; i < nn; i++) {
      final j = (i + 1) % nn;
      signedArea +=
          closedRing[i][0] * closedRing[j][1] -
          closedRing[j][0] * closedRing[i][1];
    }
    signedArea /= 2.0;
    final perpSign = signedArea > 0 ? -1.0 : 1.0;

    const arcSteps = 16;
    final bufferedPoints = <List<double>>[];

    for (int i = 0; i < nn; i++) {
      final current = closedRing[i];
      final prev = closedRing[(i - 1 + nn) % nn];
      final next = closedRing[(i + 1) % nn];

      final dx1 = (current[0] - prev[0]) * lonToMiles;
      final dy1 = (current[1] - prev[1]) * latToMiles;
      final dx2 = (next[0] - current[0]) * lonToMiles;
      final dy2 = (next[1] - current[1]) * latToMiles;

      final cross = dx1 * dy2 - dy1 * dx2;
      final isConvex = (cross * perpSign) < 0;

      final inAngle = math.atan2(dy1, dx1);
      final outAngle = math.atan2(dy2, dx2);
      final perpIn = inAngle + perpSign * math.pi / 2.0;
      final perpOut = outAngle + perpSign * math.pi / 2.0;

      var delta = perpOut - perpIn;
      while (delta > math.pi) delta -= 2 * math.pi;
      while (delta < -math.pi) delta += 2 * math.pi;

      if (isConvex && delta.abs() > 0.01) {
        final steps = (arcSteps * delta.abs() / math.pi).ceil().clamp(
          4,
          arcSteps,
        );
        for (int j = 0; j <= steps; j++) {
          final t = j / steps;
          final angle = perpIn + t * delta;
          bufferedPoints.add([
            current[0] + bufferLonDeg * math.cos(angle),
            current[1] + bufferLatDeg * math.sin(angle),
          ]);
        }
      } else {
        final bisector = perpIn + delta / 2.0;
        final cosHalf = math.cos(delta / 2.0);
        final miter = cosHalf.abs() > 0.1
            ? (1.0 / cosHalf).clamp(-4.0, 4.0)
            : 1.0;
        bufferedPoints.add([
          current[0] + bufferLonDeg * math.cos(bisector) * miter,
          current[1] + bufferLatDeg * math.sin(bisector) * miter,
        ]);
      }
    }

    if (bufferedPoints.isNotEmpty) {
      bufferedPoints.add(bufferedPoints[0]);
    }
    return bufferedPoints;
  }

  static List<List<double>> _createOpenPolylineBuffer(
    List<List<double>> pts,
    double bufferMiles,
    double avgLat,
  ) {
    final n = pts.length;
    final bufferLatDeg = bufferMiles / 69.0;
    final bufferLonDeg =
        bufferMiles / (69.0 * math.cos(avgLat * math.pi / 180.0));
    final lonToMiles = 69.0 * math.cos(avgLat * math.pi / 180.0);
    final latToMiles = 69.0;
    const arcSteps = 16;

    final segAngles = <double>[];
    for (int i = 0; i < n - 1; i++) {
      final ddx = (pts[i + 1][0] - pts[i][0]) * lonToMiles;
      final ddy = (pts[i + 1][1] - pts[i][1]) * latToMiles;
      segAngles.add(math.atan2(ddy, ddx));
    }

    final rightSide = <List<double>>[];
    final leftSide = <List<double>>[];

    for (int i = 0; i < n; i++) {
      if (i == 0) {
        final pa = segAngles[0] - math.pi / 2;
        rightSide.add([
          pts[0][0] + bufferLonDeg * math.cos(pa),
          pts[0][1] + bufferLatDeg * math.sin(pa),
        ]);
      } else if (i == n - 1) {
        final pa = segAngles[n - 2] - math.pi / 2;
        rightSide.add([
          pts[n - 1][0] + bufferLonDeg * math.cos(pa),
          pts[n - 1][1] + bufferLatDeg * math.sin(pa),
        ]);
      } else {
        final perpIn = segAngles[i - 1] - math.pi / 2;
        final perpOut = segAngles[i] - math.pi / 2;
        final dxIn = (pts[i][0] - pts[i - 1][0]) * lonToMiles;
        final dyIn = (pts[i][1] - pts[i - 1][1]) * latToMiles;
        final dxOut = (pts[i + 1][0] - pts[i][0]) * lonToMiles;
        final dyOut = (pts[i + 1][1] - pts[i][1]) * latToMiles;
        final cross = dxIn * dyOut - dyIn * dxOut;
        var delta = perpOut - perpIn;
        while (delta > math.pi) delta -= 2 * math.pi;
        while (delta < -math.pi) delta += 2 * math.pi;

        if (cross > 1e-10 && delta.abs() > 0.01) {
          final steps = (arcSteps * delta.abs() / math.pi).ceil().clamp(
            4,
            arcSteps,
          );
          for (int j = 0; j <= steps; j++) {
            final t = j / steps;
            final angle = perpIn + t * delta;
            rightSide.add([
              pts[i][0] + bufferLonDeg * math.cos(angle),
              pts[i][1] + bufferLatDeg * math.sin(angle),
            ]);
          }
        } else {
          final bisector = perpIn + delta / 2.0;
          final cosHalf = math.cos(delta / 2.0);
          final miter = cosHalf.abs() > 0.1
              ? (1.0 / cosHalf).clamp(-4.0, 4.0)
              : 1.0;
          rightSide.add([
            pts[i][0] + bufferLonDeg * math.cos(bisector) * miter,
            pts[i][1] + bufferLatDeg * math.sin(bisector) * miter,
          ]);
        }
      }
    }

    for (int i = 0; i < n; i++) {
      if (i == 0) {
        final pa = segAngles[0] + math.pi / 2;
        leftSide.add([
          pts[0][0] + bufferLonDeg * math.cos(pa),
          pts[0][1] + bufferLatDeg * math.sin(pa),
        ]);
      } else if (i == n - 1) {
        final pa = segAngles[n - 2] + math.pi / 2;
        leftSide.add([
          pts[n - 1][0] + bufferLonDeg * math.cos(pa),
          pts[n - 1][1] + bufferLatDeg * math.sin(pa),
        ]);
      } else {
        final perpIn = segAngles[i - 1] + math.pi / 2;
        final perpOut = segAngles[i] + math.pi / 2;
        final dxIn = (pts[i][0] - pts[i - 1][0]) * lonToMiles;
        final dyIn = (pts[i][1] - pts[i - 1][1]) * latToMiles;
        final dxOut = (pts[i + 1][0] - pts[i][0]) * lonToMiles;
        final dyOut = (pts[i + 1][1] - pts[i][1]) * latToMiles;
        final cross = dxIn * dyOut - dyIn * dxOut;
        var delta = perpOut - perpIn;
        while (delta > math.pi) delta -= 2 * math.pi;
        while (delta < -math.pi) delta += 2 * math.pi;

        if (cross < -1e-10 && delta.abs() > 0.01) {
          final steps = (arcSteps * delta.abs() / math.pi).ceil().clamp(
            4,
            arcSteps,
          );
          for (int j = 0; j <= steps; j++) {
            final t = j / steps;
            final angle = perpIn + t * delta;
            leftSide.add([
              pts[i][0] + bufferLonDeg * math.cos(angle),
              pts[i][1] + bufferLatDeg * math.sin(angle),
            ]);
          }
        } else {
          final bisector = perpIn + delta / 2.0;
          final cosHalf = math.cos(delta / 2.0);
          final miter = cosHalf.abs() > 0.1
              ? (1.0 / cosHalf).clamp(-4.0, 4.0)
              : 1.0;
          leftSide.add([
            pts[i][0] + bufferLonDeg * math.cos(bisector) * miter,
            pts[i][1] + bufferLatDeg * math.sin(bisector) * miter,
          ]);
        }
      }
    }

    final result = <List<double>>[];

    final startAngle = segAngles[0] + math.pi / 2;
    for (int j = 0; j <= arcSteps; j++) {
      final t = j / arcSteps;
      final angle = startAngle + t * math.pi;
      result.add([
        pts[0][0] + bufferLonDeg * math.cos(angle),
        pts[0][1] + bufferLatDeg * math.sin(angle),
      ]);
    }

    result.addAll(rightSide);

    final endAngle = segAngles[n - 2] - math.pi / 2;
    for (int j = 0; j <= arcSteps; j++) {
      final t = j / arcSteps;
      final angle = endAngle + t * math.pi;
      result.add([
        pts[n - 1][0] + bufferLonDeg * math.cos(angle),
        pts[n - 1][1] + bufferLatDeg * math.sin(angle),
      ]);
    }

    result.addAll(leftSide.reversed);

    if (result.isNotEmpty) {
      result.add(result[0]);
    }
    return result;
  }

  static List<List<double>> _createCirclePoints(
    List<double> center,
    double radiusMiles,
    int numPoints,
  ) {
    final radiusLatDeg = radiusMiles / 69.0;
    final radiusLonDeg =
        radiusMiles / (69.0 * math.cos(center[1] * math.pi / 180.0));
    final points = <List<double>>[];
    for (int i = 0; i <= numPoints; i++) {
      final angle = (i * 2 * math.pi) / numPoints;
      points.add([
        center[0] + radiusLonDeg * math.cos(angle),
        center[1] + radiusLatDeg * math.sin(angle),
      ]);
    }
    return points;
  }

  static double _distToSegmentMiles(
    double px,
    double py,
    double ax,
    double ay,
    double bx,
    double by,
    double lonToMiles,
    double latToMiles,
  ) {
    final pxM = px * lonToMiles;
    final pyM = py * latToMiles;
    final axM = ax * lonToMiles;
    final ayM = ay * latToMiles;
    final bxM = bx * lonToMiles;
    final byM = by * latToMiles;
    final dx = bxM - axM;
    final dy = byM - ayM;
    final lenSq = dx * dx + dy * dy;
    if (lenSq == 0) {
      final ex = pxM - axM;
      final ey = pyM - ayM;
      return math.sqrt(ex * ex + ey * ey);
    }
    final t = ((pxM - axM) * dx + (pyM - ayM) * dy) / lenSq;
    final tc = t.clamp(0.0, 1.0);
    final cx = axM + tc * dx;
    final cy = ayM + tc * dy;
    final ex = pxM - cx;
    final ey = pyM - cy;
    return math.sqrt(ex * ex + ey * ey);
  }

  static double _distToPolylineMiles(
    double lon,
    double lat,
    List<List<double>> pts,
    double lonToMiles,
    double latToMiles,
  ) {
    double minDist = double.infinity;
    for (int i = 0; i < pts.length - 1; i++) {
      final d = _distToSegmentMiles(
        lon, lat,
        pts[i][0], pts[i][1],
        pts[i + 1][0], pts[i + 1][1],
        lonToMiles, latToMiles,
      );
      if (d < minDist) minDist = d;
    }
    return minDist;
  }

  // Returns true if (lon, lat) is within bufferMiles of the polyline.
  // For closed polygons this naturally produces an ArcGIS-style donut: when
  // the polygon is large enough that its centre is farther than bufferMiles
  // from every edge, the centre hole is excluded automatically.
  static bool _isPointInBuffer(
    double lon,
    double lat,
    List<List<double>> pts,
    double bufferMiles,
  ) {
    if (pts.isEmpty) return false;
    final avgLat = pts.map((p) => p[1]).reduce((a, b) => a + b) / pts.length;
    final lonToMiles = 69.0 * math.cos(avgLat * math.pi / 180.0);
    const latToMiles = 69.0;
    return _distToPolylineMiles(lon, lat, pts, lonToMiles, latToMiles) <= bufferMiles;
  }

  // Grid-based area: count cells inside buffer, multiply by cell area.
  // Step 0.0005 deg (~55 m) avoids double-counting overlapping buffer parts.
  static double _calculateBufferAreaGrid(
    List<List<double>> pts,
    double bufferMiles,
  ) {
    if (pts.isEmpty) return 0.0;
    final avgLat = pts.map((p) => p[1]).reduce((a, b) => a + b) / pts.length;
    final lonToMiles = 69.0 * math.cos(avgLat * math.pi / 180.0);
    const latToMiles = 69.0;
    const step = 0.0005;
    final cellArea = (step * lonToMiles) * (step * latToMiles);
    double minLon = pts.map((p) => p[0]).reduce((a, b) => a < b ? a : b);
    double maxLon = pts.map((p) => p[0]).reduce((a, b) => a > b ? a : b);
    double minLat = pts.map((p) => p[1]).reduce((a, b) => a < b ? a : b);
    double maxLat = pts.map((p) => p[1]).reduce((a, b) => a > b ? a : b);
    final bufLonDeg = bufferMiles / lonToMiles;
    final bufLatDeg = bufferMiles / latToMiles;
    minLon -= bufLonDeg + step;
    maxLon += bufLonDeg + step;
    minLat -= bufLatDeg + step;
    maxLat += bufLatDeg + step;
    int count = 0;
    for (double sLat = minLat; sLat <= maxLat; sLat += step) {
      for (double sLon = minLon; sLon <= maxLon; sLon += step) {
        if (_isPointInBuffer(sLon, sLat, pts, bufferMiles)) count++;
      }
    }
    return count * cellArea;
  }

  static List<Map<String, dynamic>> _filterCrashesByDistance(
    List<Map<String, dynamic>> crashFeatures,
    List<List<double>> pts,
    double bufferMiles,
  ) {
    final result = <Map<String, dynamic>>[];
    for (final feature in crashFeatures) {
      final geometry = feature['geometry'] as Map<String, dynamic>?;
      if (geometry == null) continue;
      final coords = geometry['coordinates'] as List?;
      if (coords == null || coords.length < 2) continue;
      final crashLon = (coords[0] as num).toDouble();
      final crashLat = (coords[1] as num).toDouble();
      if (_isPointInBuffer(crashLon, crashLat, pts, bufferMiles)) {
        result.add(feature);
      }
    }
    return result;
  }


  /// Robust point-in-polygon test using winding number algorithm
  /// This is more reliable than ray-casting for complex polygons
  static bool _isPointInPolygonRobust(
    double x,
    double y,
    List<List<double>> polygon,
  ) {
    if (polygon.length < 3) return false;

    int windingNumber = 0;

    for (int i = 0; i < polygon.length - 1; i++) {
      final x1 = polygon[i][0];
      final y1 = polygon[i][1];
      final x2 = polygon[i + 1][0];
      final y2 = polygon[i + 1][1];

      if (y1 <= y) {
        if (y2 > y) {
          // Upward crossing
          final cross = (x2 - x1) * (y - y1) - (x - x1) * (y2 - y1);
          if (cross > 0) {
            windingNumber++;
          }
        }
      } else {
        if (y2 <= y) {
          // Downward crossing
          final cross = (x2 - x1) * (y - y1) - (x - x1) * (y2 - y1);
          if (cross < 0) {
            windingNumber--;
          }
        }
      }
    }

    return windingNumber != 0;
  }

  static Future<List<Map<String, dynamic>>> _loadCrashDataFromAsset() async {
    if (_cachedCrashFeatures != null) {
      return _cachedCrashFeatures!;
    }

    final possiblePaths = [
      'assets/data/crashes_bicyclist.csv',
      'data/crashes_bicyclist.csv',
      'assets/crashes_bicyclist.csv',
    ];

    String? csvString;
    for (final path in possiblePaths) {
      try {
        csvString = await rootBundle.loadString(path);
        print('  âœ“ Loaded from: $path');
        break;
      } catch (e) {
        continue;
      }
    }

    if (csvString == null) {
      throw Exception('Failed to load bicycle crash CSV');
    }

    final lines = csvString.split('\n');
    final header = lines[0].split(',').map((h) => h.trim()).toList();

    int? xIndex;
    int? yIndex;
    for (int i = 0; i < header.length; i++) {
      final col = header[i].toLowerCase();
      if (col == 'x' || col == 'pointx' || col == 'easting') xIndex = i;
      if (col == 'y' || col == 'pointy' || col == 'northing') yIndex = i;
    }

    if (xIndex == null || yIndex == null) {
      throw Exception('Could not find X and Y columns');
    }

    final features = <Map<String, dynamic>>[];
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final values = line.split(',');
      if (values.length <= math.max(xIndex, yIndex)) continue;

      try {
        final x = double.parse(values[xIndex].trim());
        final y = double.parse(values[yIndex].trim());
        final coords = _utmToLonLat(x, y, 11, true);

        if (coords[0] < -120 ||
            coords[0] > -114 ||
            coords[1] < 35 ||
            coords[1] > 42) {
          continue;
        }

        final properties = <String, dynamic>{};
        for (int j = 0; j < header.length && j < values.length; j++) {
          if (j != xIndex && j != yIndex) {
            properties[header[j]] = values[j].trim();
          }
        }

        features.add({
          'geometry': {
            'type': 'Point',
            'coordinates': [coords[0], coords[1]],
          },
          'properties': properties,
        });
      } catch (e) {
        continue;
      }
    }

    _cachedCrashFeatures = features;
    return features;
  }

  static List<double> _utmToLonLat(
    double easting,
    double northing,
    int zoneNumber,
    bool northern,
  ) {
    const a = 6378137.0;
    const e = 0.08181919084262149;
    const e1sq = 0.006739496742276434;
    const k0 = 0.9996;
    final x = easting - 500000.0;
    var y = northing;
    if (!northern) y -= 10000000.0;
    final m = y / k0;
    final mu = m / (a * (1 - e * e / 4 - 3 * e * e * e * e / 64));
    final e1 = (1 - math.sqrt(1 - e * e)) / (1 + math.sqrt(1 - e * e));
    final j1 = 3 * e1 / 2 - 27 * math.pow(e1, 3) / 32;
    final j2 = 21 * e1 * e1 / 16 - 55 * math.pow(e1, 4) / 32;
    final j3 = 151 * math.pow(e1, 3) / 96;
    final j4 = 1097 * math.pow(e1, 4) / 512;
    final fp =
        mu +
        j1 * math.sin(2 * mu) +
        j2 * math.sin(4 * mu) +
        j3 * math.sin(6 * mu) +
        j4 * math.sin(8 * mu);
    final sinfp = math.sin(fp);
    final cosfp = math.cos(fp);
    final c1 = e1sq * cosfp * cosfp;
    final t1 = math.tan(fp) * math.tan(fp);
    final r1 = a * (1 - e * e) / math.pow(1 - (e * sinfp) * (e * sinfp), 1.5);
    final n1 = a / math.sqrt(1 - (e * sinfp) * (e * sinfp));
    final d = x / (n1 * k0);
    final q1 = n1 * math.tan(fp) / r1;
    final q2 = d * d / 2;
    final q3 =
        (5 + 3 * t1 + 10 * c1 - 4 * c1 * c1 - 9 * e1sq) * math.pow(d, 4) / 24;
    final q4 =
        (61 + 90 * t1 + 298 * c1 + 45 * t1 * t1 - 252 * e1sq - 3 * c1 * c1) *
        math.pow(d, 6) /
        720;
    var lat = fp - q1 * (q2 - q3 + q4);
    final q5 = d;
    final q6 = (1 + 2 * t1 + c1) * math.pow(d, 3) / 6;
    final q7 =
        (5 - 2 * c1 + 28 * t1 - 3 * c1 * c1 + 8 * e1sq + 24 * t1 * t1) *
        math.pow(d, 5) /
        120;
    var lon = (q5 - q6 + q7) / cosfp;
    final lon0 = (zoneNumber - 1) * 6 - 180 + 3;
    lon = lon0 + lon * (180.0 / math.pi);
    lat = lat * (180.0 / math.pi);
    return [lon, lat];
  }

  static Future<Map<String, dynamic>> _geocodeAddress(String address) async {
    final geocodeUrl = Uri.parse(
      'https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates',
    );
    final params = {
      'f': 'json',
      'singleLine': address,
      'outFields': 'Match_addr,Addr_type',
      'maxLocations': '1',
    };
    final response = await http.get(
      geocodeUrl.replace(queryParameters: params),
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
    if (location == null) {
      throw Exception('No location in geocoding result');
    }
    final lon = location['x'];
    final lat = location['y'];
    final matchedAddress = best['address'] as String? ?? address;
    return {
      'lon': (lon as num).toDouble(),
      'lat': (lat as num).toDouble(),
      'matched': matchedAddress,
    };
  }

  static String _getAnswerFromDensity(int densityRounded) {
    if (densityRounded <= 4)
      return '0-4';
    else if (densityRounded <= 7)
      return '5-7';
    else if (densityRounded <= 10)
      return '8-10';
    else if (densityRounded <= 15)
      return '11-15';
    else
      return '15+';
  }

  static void clearCache() {
    _cachedCrashFeatures = null;
  }
}

extension on double {
  String toFixed(int decimals) => toStringAsFixed(decimals);
}
