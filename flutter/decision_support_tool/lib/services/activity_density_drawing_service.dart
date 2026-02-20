import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

// ─── EPA class-break model ────────────────────────────────────────────────────

/// One class-break entry fetched live from the EPA SLD renderer.
/// Mirrors the Python script's BREAKS list: { max, label, fillCss }.
class EpaActivityClassBreak {
  final double maxValue;
  final String label;

  /// Color parsed from the EPA renderer's [R, G, B, A] array.
  final Color fillColor;

  const EpaActivityClassBreak({
    required this.maxValue,
    required this.label,
    required this.fillColor,
  });
}

// ─── Result model ─────────────────────────────────────────────────────────────

/// Result returned by [ActivityDensityDrawingService.calculateFromPolygon].
class ActivityDensityDrawingResult {
  final int regionCount;
  final String matchedAddress;
  final double lon;
  final double lat;

  /// Simple average of the activity density (housing units + jobs per acre).
  final double simpleAverage;

  /// Area-weighted average of the activity density.
  final double weightedAverage;

  /// Area-weighted average score (0–5).
  final double weightedScoreAverage;

  /// Rounded score (0–5) using .5+ up, under .5 down rule.
  final int roundedScore;

  /// The selected DST answer text (e.g. "0.28-2.02").
  final String answer;

  final List<ActivityDensityRegionInfo> regions;
  final List<List<double>>? drawnPolygon;

  /// Live EPA class breaks (colors + labels) fetched from the renderer.
  final List<EpaActivityClassBreak> classBreaks;

  ActivityDensityDrawingResult({
    required this.regionCount,
    required this.matchedAddress,
    required this.lon,
    required this.lat,
    required this.simpleAverage,
    required this.weightedAverage,
    required this.weightedScoreAverage,
    required this.roundedScore,
    required this.answer,
    required this.regions,
    required this.classBreaks,
    this.drawnPolygon,
  });
}

// ─── Per-region model ─────────────────────────────────────────────────────────

/// Per-region info from the EPA SLD query.
class ActivityDensityRegionInfo {
  final String objectId;

  /// Raw EPA activity density value (housing units + jobs per acre).
  final double? density;

  /// Area of the intersection of this region with the drawn polygon (sq miles).
  final double areaSqMiles;

  final String bucket;
  final double points;
  final int score;

  /// Full region polygon ring as [lon, lat] pairs — used for map rendering.
  final List<List<double>> geometry;

  /// Clipped intersection polygon — may be empty if clip failed.
  final List<List<double>> clippedGeometry;

  ActivityDensityRegionInfo({
    required this.objectId,
    required this.density,
    required this.areaSqMiles,
    required this.bucket,
    required this.points,
    required this.score,
    required this.geometry,
    required this.clippedGeometry,
  });
}

// ─── DST Bucket model ─────────────────────────────────────────────────────────

class _DstBucket {
  final String text;
  final double? min;
  final double? max;
  final double points;
  final int score;

  const _DstBucket({
    required this.text,
    required this.min,
    required this.max,
    required this.points,
    required this.score,
  });
}

// ─── Service ──────────────────────────────────────────────────────────────────

/// Service that queries the EPA Smart Location Database (SLD) Layer 4
/// (Activity Density — housing units + jobs per acre) for a user-drawn polygon
/// and returns an area-weighted average to autofill the DST answer.
///
/// Scoring mirrors the Python prototype exactly:
///   - Per-region scores (0–5) are computed from density buckets.
///   - Area-weighted average of scores is computed.
///   - Rounded using .5+ up, under .5 down rule.
///   - Rounded score maps back to the DST answer bucket + points.
///
/// Colors are fetched live from the EPA renderer endpoint.
class ActivityDensityDrawingService {
  static const String _epaRoot =
      'https://geodata.epa.gov/arcgis/rest/services/OA/SmartLocationDatabase/MapServer';
  static const int _layerId = 4; // Activity Density layer

  /// DST answer buckets — mirrors BUCKETS in Python prototype.
  static const List<_DstBucket> _buckets = [
    _DstBucket(text: 'No Density', min: null, max: null, points: 0.0, score: 0),
    _DstBucket(text: '0-0.27', min: 0.0, max: 0.27, points: 1.0, score: 1),
    _DstBucket(text: '0.28-2.02', min: 0.28, max: 2.02, points: 2.0, score: 2),
    _DstBucket(text: '2.03-4.30', min: 2.03, max: 4.30, points: 3.0, score: 3),
    _DstBucket(text: '4.31-8.31', min: 4.31, max: 8.31, points: 4.0, score: 4),
    _DstBucket(
      text: '>8.32',
      min: 8.32,
      max: double.infinity,
      points: 5.0,
      score: 5,
    ),
  ];

  // ─── Public entry point ──────────────────────────────────────────────────────

  static Future<ActivityDensityDrawingResult> calculateFromPolygon({
    required String address,
    required List<List<double>> polygonPoints,
  }) async {
    print('=== Activity Density Calculation Starting ===');

    try {
      // Step 1: Geocode ────────────────────────────────────────────────────────
      print('Step 1: Geocoding address...');
      final geocodeResult = await _geocodeAddress(address);
      final lon = geocodeResult['lon'] as double;
      final lat = geocodeResult['lat'] as double;
      final matched = geocodeResult['matched'] as String;
      print('✔ Geocoded: $matched at ($lon, $lat)');

      // Step 2: Fetch EPA renderer (value field + live colors) ─────────────────
      print(
        'Step 2: Fetching EPA renderer (value field + class-break colors)...',
      );
      final rendererData = await _fetchRenderer();
      final valueField = rendererData['valueField'] as String;
      final classBreaks =
          rendererData['classBreaks'] as List<EpaActivityClassBreak>;
      print('✔ Value field: $valueField, ${classBreaks.length} class breaks');

      // Step 3: Query intersecting EPA regions ─────────────────────────────────
      print('Step 3: Querying EPA SLD Layer $_layerId...');
      final epaFeatures = await _fetchIntersectingRegions(
        polygonPoints,
        valueField,
      );
      print('✔ Found ${epaFeatures.length} intersecting regions');

      // Step 4: Compute averages and DST score ─────────────────────────────────
      print('Step 4: Computing area-weighted average and scores...');
      final regionInfoList = <ActivityDensityRegionInfo>[];
      double sumDensity = 0.0;
      int countWithDensity = 0;
      double weightedDensitySum = 0.0;
      double weightedScoreSum = 0.0;
      double totalArea = 0.0;

      for (final feat in epaFeatures) {
        final objectId = feat['objectId'] as String;
        final rawGeometry = feat['geometry'] as List<List<double>>;
        final attrs = feat['attributes'] as Map<String, dynamic>;

        // Intersection area
        final clipped = _clipPolygon(rawGeometry, polygonPoints);
        final double areaSqMiles;
        if (clipped.length >= 3) {
          final shArea = _polygonAreaSqMiles(clipped);
          final sampledArea = _estimateIntersectionArea(
            rawGeometry,
            polygonPoints,
          );
          areaSqMiles = (sampledArea > 0 && shArea > sampledArea * 2.5)
              ? sampledArea
              : shArea;
        } else {
          areaSqMiles = _estimateIntersectionArea(rawGeometry, polygonPoints);
        }

        // Extract raw EPA value
        final rawVal = attrs[valueField];
        double? density;
        if (rawVal != null) {
          final parsed = double.tryParse(rawVal.toString());
          if (parsed != null && parsed >= 0) {
            density = parsed;
          }
        }

        final bucketInfo = _getBucketForDensity(density);

        regionInfoList.add(
          ActivityDensityRegionInfo(
            objectId: objectId,
            density: density,
            areaSqMiles: areaSqMiles,
            bucket: bucketInfo.text,
            points: bucketInfo.points,
            score: bucketInfo.score,
            geometry: rawGeometry,
            clippedGeometry: clipped,
          ),
        );

        if (density != null) {
          sumDensity += density;
          countWithDensity++;
          weightedDensitySum += density * areaSqMiles;
          totalArea += areaSqMiles;
        }

        if (areaSqMiles > 0) {
          weightedScoreSum += bucketInfo.score * areaSqMiles;
        }

        print(
          '  Region $objectId: density=${density?.toStringAsFixed(2) ?? "N/A"} '
          'bucket=${bucketInfo.text} score=${bucketInfo.score} '
          '(${areaSqMiles.toStringAsFixed(4)} sq mi)',
        );
      }

      final simpleAvg = countWithDensity > 0
          ? sumDensity / countWithDensity
          : 0.0;
      final weightedAvg = totalArea > 0 ? weightedDensitySum / totalArea : 0.0;
      final scoreAvg = totalArea > 0 ? weightedScoreSum / totalArea : 0.0;

      // Rounding rule: .5+ up, under .5 down — mirrors Python prototype
      final frac = scoreAvg - scoreAvg.floor();
      int rounded = (frac >= 0.5) ? scoreAvg.ceil() : scoreAvg.floor();
      rounded = rounded.clamp(0, 5);

      final chosenBucket = _buckets.firstWhere(
        (b) => b.score == rounded,
        orElse: () => _buckets[0],
      );

      final answer = chosenBucket.text;

      print('✔ Simple average density: ${simpleAvg.toStringAsFixed(2)}');
      print('✔ Area-weighted avg density: ${weightedAvg.toStringAsFixed(2)}');
      print('✔ Area-weighted score avg: ${scoreAvg.toStringAsFixed(2)}');
      print('✔ Rounded score: $rounded → DST answer: $answer');
      print('=== Activity Density Calculation Complete ===');

      return ActivityDensityDrawingResult(
        regionCount: regionInfoList.length,
        matchedAddress: matched,
        lon: lon,
        lat: lat,
        simpleAverage: simpleAvg,
        weightedAverage: weightedAvg,
        weightedScoreAverage: scoreAvg,
        roundedScore: rounded,
        answer: answer,
        regions: regionInfoList,
        classBreaks: classBreaks,
        drawnPolygon: polygonPoints,
      );
    } catch (e) {
      print('Activity Density Calculation Failed: $e');
      rethrow;
    }
  }

  // ─── EPA renderer fetch ───────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> _fetchRenderer() async {
    final url = Uri.parse('$_epaRoot/$_layerId?f=json');
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('EPA layer info failed: HTTP ${response.statusCode}');
    }

    final info = jsonDecode(response.body) as Map<String, dynamic>;
    final renderer =
        (info['drawingInfo'] as Map<String, dynamic>?)?['renderer']
            as Map<String, dynamic>?;

    // Known fallback field for Layer 4 — Activity Density
    String valueField = 'D1D';
    if (renderer != null) {
      final f = renderer['field'] as String? ?? renderer['field1'] as String?;
      if (f != null && f.isNotEmpty) valueField = f;
    }

    final breaks = <EpaActivityClassBreak>[];
    if (renderer != null) {
      final rawBreaks = renderer['classBreakInfos'] as List? ?? [];
      for (final cb in rawBreaks) {
        final m = cb as Map<String, dynamic>;
        final maxVal = (m['classMaxValue'] as num?)?.toDouble();
        if (maxVal == null) continue;

        final label = m['label'] as String? ?? maxVal.toString();

        final colorArr =
            (m['symbol'] as Map<String, dynamic>?)?['color'] as List?;
        final Color fillColor;
        if (colorArr != null && colorArr.length >= 3) {
          final r = (colorArr[0] as num).toInt();
          final g = (colorArr[1] as num).toInt();
          final b = (colorArr[2] as num).toInt();
          final a = colorArr.length >= 4 ? (colorArr[3] as num).toInt() : 255;
          fillColor = Color.fromARGB(a, r, g, b);
        } else {
          fillColor = const Color(0xFFDDDDDD);
        }

        breaks.add(
          EpaActivityClassBreak(
            maxValue: maxVal,
            label: label,
            fillColor: fillColor,
          ),
        );
      }
      breaks.sort((a, b) => a.maxValue.compareTo(b.maxValue));
    }

    if (breaks.isEmpty) {
      print('  Warning: no class breaks in EPA renderer, colors will be grey.');
    }

    return {'valueField': valueField, 'classBreaks': breaks};
  }

  // ─── EPA query ────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> _fetchIntersectingRegions(
    List<List<double>> polygon,
    String valueField,
  ) async {
    final arcGeometry = _toArcgisPolygon(polygon);

    final params = {
      'f': 'json',
      'where': '1=1',
      'outFields': '*',
      'returnGeometry': 'true',
      'geometryType': 'esriGeometryPolygon',
      'geometry': jsonEncode(arcGeometry),
      'inSR': '4326',
      'outSR': '4326',
      'spatialRel': 'esriSpatialRelIntersects',
      'resultRecordCount': '5000',
    };

    final url = Uri.parse(
      '$_epaRoot/$_layerId/query',
    ).replace(queryParameters: params);

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('EPA query failed: HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data.containsKey('error')) {
      throw Exception('EPA query error: ${data['error']}');
    }

    final features = data['features'] as List? ?? [];
    if (features.isEmpty) {
      throw Exception('No EPA regions returned. Try drawing a larger polygon.');
    }

    final result = <Map<String, dynamic>>[];
    for (final feat in features) {
      final f = feat as Map<String, dynamic>;
      final geomRaw = f['geometry'] as Map<String, dynamic>?;
      final attrs = f['attributes'] as Map<String, dynamic>? ?? {};

      if (geomRaw == null) continue;
      final rings = geomRaw['rings'] as List?;
      if (rings == null || rings.isEmpty) continue;

      final ring = rings[0] as List;
      final coords = ring
          .map<List<double>>(
            (pt) => [(pt as List)[0].toDouble(), pt[1].toDouble()],
          )
          .toList();

      final objectId =
          attrs['OBJECTID']?.toString() ??
          attrs['GEOID20']?.toString() ??
          attrs['GEOID']?.toString() ??
          '?';

      result.add({
        'objectId': objectId,
        'geometry': coords,
        'attributes': attrs,
      });
    }
    return result;
  }

  // ─── Bucket helpers ───────────────────────────────────────────────────────────

  /// Returns the DST bucket for a given density value.
  /// Mirrors Python bucketForDensity(v):
  ///   - null or NaN → No Density
  ///   - exactly 0.0 → No Density
  ///   - otherwise match min..max ranges
  static _DstBucket _getBucketForDensity(double? v) {
    if (v == null || !v.isFinite) return _buckets[0]; // No Density
    if (v == 0.0) return _buckets[0]; // No Density
    for (final b in _buckets) {
      if (b.min == null) continue; // skip No Density sentinel
      if (v >= b.min! && v <= b.max!) return b;
    }
    return _buckets.last; // >8.32
  }

  // ─── Geometry helpers (mirrors LandUseDiversityDrawingService) ────────────────

  static Map<String, dynamic> _toArcgisPolygon(List<List<double>> polygon) {
    final ring = polygon.map((pt) => [pt[0], pt[1]]).toList();
    if (ring.isNotEmpty) {
      final first = ring.first, last = ring.last;
      if (first[0] != last[0] || first[1] != last[1]) {
        ring.add([first[0], first[1]]);
      }
    }
    return {
      'rings': [ring],
      'spatialReference': {'wkid': 4326},
    };
  }

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

  /// Shoelace formula, converted to sq miles (approx for Clark County ~36N).
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

  /// Fallback area estimate via grid sampling when Sutherland-Hodgman fails.
  static double _estimateIntersectionArea(
    List<List<double>> regionPoly,
    List<List<double>> drawnPoly,
  ) {
    if (regionPoly.length < 3 || drawnPoly.length < 3) return 0.0;

    double tMinX = regionPoly[0][0], tMaxX = regionPoly[0][0];
    double tMinY = regionPoly[0][1], tMaxY = regionPoly[0][1];
    for (final p in regionPoly) {
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
        if (_pointInPolygon(x, y, regionPoly) &&
            _pointInPolygon(x, y, drawnPoly)) {
          inside++;
        }
      }
    }
    final cellAreaSqMiles = (dx * 69.0) * (dy * 55.0);
    return inside * cellAreaSqMiles;
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

  // ─── Geocode ──────────────────────────────────────────────────────────────────

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
}
