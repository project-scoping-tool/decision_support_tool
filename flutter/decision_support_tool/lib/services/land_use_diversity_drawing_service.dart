import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

// ─── EPA class-break model ────────────────────────────────────────────────────

/// One class-break entry fetched live from the EPA SLD renderer.
/// Mirrors the Python script's BREAKS list: { max, label, fillCss }.
class EpaClassBreak {
  final double maxValue;
  final String label;

  /// Color parsed from the EPA renderer's [R, G, B, A] array —
  /// identical to the Python rgbaCss() conversion.
  final Color fillColor;

  const EpaClassBreak({
    required this.maxValue,
    required this.label,
    required this.fillColor,
  });
}

// ─── Result model ─────────────────────────────────────────────────────────────

/// Result returned by [LandUseDiversityDrawingService.calculateFromPolygon].
class LandUseDiversityDrawingResult {
  final int regionCount;
  final String matchedAddress;
  final double lon;
  final double lat;

  /// Simple average of the diversity index, already multiplied by 10.
  final double simpleAverage;

  /// Area-weighted average of the diversity index, already multiplied by 10.
  final double weightedAverage;

  final String answer;
  final List<LandUseDiversityRegionInfo> regions;
  final List<List<double>>? drawnPolygon;

  /// Live EPA class breaks (colors + labels) fetched from the renderer.
  final List<EpaClassBreak> classBreaks;

  LandUseDiversityDrawingResult({
    required this.regionCount,
    required this.matchedAddress,
    required this.lon,
    required this.lat,
    required this.simpleAverage,
    required this.weightedAverage,
    required this.answer,
    required this.regions,
    required this.classBreaks,
    this.drawnPolygon,
  });
}

// ─── Per-region model ─────────────────────────────────────────────────────────

/// Per-region info from the EPA SLD query.
class LandUseDiversityRegionInfo {
  final String objectId;

  /// Raw EPA value already multiplied by 10 for display and bucketing.
  final double? diversityIndex;

  /// Area of the intersection of this region with the drawn polygon (sq miles).
  final double areaSqMiles;
  final String bucket;
  final double points;

  /// Full region polygon ring as [lon, lat] pairs — used for map rendering.
  final List<List<double>> geometry;

  /// Clipped intersection polygon — may be empty if clip failed.
  final List<List<double>> clippedGeometry;

  LandUseDiversityRegionInfo({
    required this.objectId,
    required this.diversityIndex,
    required this.areaSqMiles,
    required this.bucket,
    required this.points,
    required this.geometry,
    required this.clippedGeometry,
  });
}

// ─── Service ──────────────────────────────────────────────────────────────────

/// Service that queries the EPA Smart Location Database (SLD) Layer 7
/// (Land Use Diversity) for a user-drawn polygon and returns an
/// area-weighted average diversity index to autofill the DST answer.
///
/// The EPA field D2B_E8MIXA stores values in the range ~0–1 (e.g. 0.83),
/// but the DST answer ranges are 0-2, 2-3, … 9-10 (i.e. scaled ×10).
/// All raw EPA values are multiplied by 10 before display, bucketing,
/// and averaging — so 0.62 becomes 6.2, which maps to "6-7".
///
/// Colors are fetched live from the EPA renderer endpoint — matching the
/// Python prototype exactly — rather than being hardcoded.
class LandUseDiversityDrawingService {
  static const String _epaRoot =
      'https://geodata.epa.gov/arcgis/rest/services/OA/SmartLocationDatabase/MapServer';
  static const int _layerId = 7; // Land Use Diversity layer

  // ─── Public entry point ──────────────────────────────────────────────────────

  static Future<LandUseDiversityDrawingResult> calculateFromPolygon({
    required String address,
    required List<List<double>> polygonPoints,
  }) async {
    print('=== Land Use Diversity Calculation Starting ===');

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
      final classBreaks = rendererData['classBreaks'] as List<EpaClassBreak>;
      print('✔ Value field: $valueField, ${classBreaks.length} class breaks');

      // Step 3: Query intersecting EPA regions ─────────────────────────────────
      print('Step 3: Querying EPA SLD Layer $_layerId...');
      final epaFeatures = await _fetchIntersectingRegions(
        polygonPoints,
        valueField,
      );
      print('✔ Found ${epaFeatures.length} intersecting regions');

      // Step 4: Compute area-weighted average ──────────────────────────────────
      print('Step 4: Computing area-weighted average...');
      final regionInfoList = <LandUseDiversityRegionInfo>[];
      double sumIndex = 0.0;
      int countWithIndex = 0;
      double weightedSum = 0.0;
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

        // Extract raw EPA value then multiply by 10.
        // EPA stores D2B_E8MIXA as a decimal ~0-1 (e.g. 0.83).
        // The DST answer ranges use the ×10 scale (0-2, 2-3, … 9-10),
        // so 0.83 → 8.3, 0.62 → 6.2, etc.
        final rawVal = attrs[valueField];
        double? diversityIndex; // stored as ×10 value
        if (rawVal != null) {
          final parsed = double.tryParse(rawVal.toString());
          if (parsed != null && parsed >= 0) {
            diversityIndex = parsed * 10.0;
          }
        }

        final bucketInfo = _getDstBucket(diversityIndex ?? 0.0);

        regionInfoList.add(
          LandUseDiversityRegionInfo(
            objectId: objectId,
            diversityIndex: diversityIndex, // already ×10
            areaSqMiles: areaSqMiles,
            bucket: bucketInfo['bucket'] as String,
            points: bucketInfo['points'] as double,
            geometry: rawGeometry,
            clippedGeometry: clipped,
          ),
        );

        if (diversityIndex != null) {
          sumIndex += diversityIndex;
          countWithIndex++;
          weightedSum += diversityIndex * areaSqMiles;
          totalArea += areaSqMiles;
        }

        print(
          '  Region $objectId: raw=${rawVal}, ×10=${diversityIndex?.toStringAsFixed(2) ?? "N/A"} '
          '(${areaSqMiles.toStringAsFixed(4)} sq mi)',
        );
      }

      // Averages are already in the ×10 scale
      final simpleAvg = countWithIndex > 0 ? sumIndex / countWithIndex : 0.0;
      final weightedAvg = totalArea > 0 ? weightedSum / totalArea : 0.0;

      print('✔ Simple average (×10): ${simpleAvg.toStringAsFixed(2)}');
      print('✔ Area-weighted average (×10): ${weightedAvg.toStringAsFixed(2)}');

      final answer = _getAnswerFromIndex(weightedAvg);
      print('✔ DST answer: $answer');
      print('=== Land Use Diversity Calculation Complete ===');

      return LandUseDiversityDrawingResult(
        regionCount: regionInfoList.length,
        matchedAddress: matched,
        lon: lon,
        lat: lat,
        simpleAverage: simpleAvg,
        weightedAverage: weightedAvg,
        answer: answer,
        regions: regionInfoList,
        classBreaks: classBreaks,
        drawnPolygon: polygonPoints,
      );
    } catch (e) {
      print('Land Use Diversity Calculation Failed: $e');
      rethrow;
    }
  }

  // ─── EPA renderer fetch ───────────────────────────────────────────────────────

  /// Fetches the EPA SLD Layer 7 renderer in a single request and returns:
  ///   - 'valueField': the attribute field that holds the diversity index.
  ///   - 'classBreaks': list of [EpaClassBreak] with live colors + labels.
  ///
  /// Mirrors the Python loadRenderer() function exactly:
  ///   - Reads renderer.field for the value field.
  ///   - Maps classBreakInfos[i].symbol.color ([R,G,B,A]) to Flutter Color,
  ///     identical to Python's rgbaCss([R,G,B,A]).
  ///   - Sorts breaks ascending by maxValue.
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

    // Value field
    String valueField = 'D2B_E8MIXA'; // known fallback for Layer 7
    if (renderer != null) {
      final f = renderer['field'] as String? ?? renderer['field1'] as String?;
      if (f != null && f.isNotEmpty) valueField = f;
    }

    // Class breaks → Colors
    // Python: BREAKS = classBreaks.map(cb => ({
    //   max: cb.classMaxValue,
    //   label: cb.label,
    //   fillCss: rgbaCss(cb.symbol.color)   // [R,G,B,A]
    // })).sort((a,b) => a.max - b.max)
    final breaks = <EpaClassBreak>[];
    if (renderer != null) {
      final rawBreaks = renderer['classBreakInfos'] as List? ?? [];
      for (final cb in rawBreaks) {
        final m = cb as Map<String, dynamic>;
        final maxVal = (m['classMaxValue'] as num?)?.toDouble();
        if (maxVal == null) continue;

        final label = m['label'] as String? ?? maxVal.toString();

        // Python rgbaCss([R,G,B,A]): alpha = A/255
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
          fillColor = const Color(0xFFDDDDDD); // same fallback as Python
        }

        breaks.add(
          EpaClassBreak(maxValue: maxVal, label: label, fillColor: fillColor),
        );
      }
      // Sort ascending — mirrors Python .sort((a,b) => a.max - b.max)
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

  // ─── Geometry helpers (mirrors BikingRateDrawingService) ─────────────────────

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

  // ─── Buckets ──────────────────────────────────────────────────────────────────
  // [index] is already multiplied by 10.
  // Boundary rule: if average == boundary, choose the lower interval
  // (e.g. exactly 2.0 -> "0-2", not "2-3").

  static Map<String, dynamic> _getDstBucket(double index) {
    if (index <= 2.0) return {'bucket': '0-2', 'points': 1.0};
    if (index <= 3.0) return {'bucket': '2-3', 'points': 1.5};
    if (index <= 4.0) return {'bucket': '3-4', 'points': 2.0};
    if (index <= 5.0) return {'bucket': '4-5', 'points': 2.5};
    if (index <= 6.0) return {'bucket': '5-6', 'points': 3.0};
    if (index <= 7.0) return {'bucket': '6-7', 'points': 3.5};
    if (index <= 8.0) return {'bucket': '7-8', 'points': 4.0};
    if (index <= 9.0) return {'bucket': '8-9', 'points': 4.5};
    return {'bucket': '9-10', 'points': 5.0};
  }

  static String _getAnswerFromIndex(double index) {
    if (index <= 2.0) return '0-2';
    if (index <= 3.0) return '2-3';
    if (index <= 4.0) return '3-4';
    if (index <= 5.0) return '4-5';
    if (index <= 6.0) return '5-6';
    if (index <= 7.0) return '6-7';
    if (index <= 8.0) return '7-8';
    if (index <= 9.0) return '8-9';
    return '9-10';
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
