import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

// ─── EPA class-break model ────────────────────────────────────────────────────

/// One class-break entry fetched live from the EPA Walkability Index renderer.
/// Mirrors the Python script's BREAKS list: { max, label, fillCss }.
class EpaWalkabilityClassBreak {
  final double maxValue;
  final String label;

  /// Color parsed from the EPA renderer's [R, G, B, A] array —
  /// identical to the Python rgbaCss() conversion.
  final Color fillColor;

  const EpaWalkabilityClassBreak({
    required this.maxValue,
    required this.label,
    required this.fillColor,
  });
}

// ─── Result model ─────────────────────────────────────────────────────────────

/// Result returned by [WalkabilityIndexDrawingService.calculateFromPolygon].
class WalkabilityIndexDrawingResult {
  final int regionCount;
  final String matchedAddress;
  final double lon;
  final double lat;

  /// Simple average of NatWalkInd (1–20 scale).
  final double simpleAverage;

  /// Area-weighted average of NatWalkInd (1–20 scale).
  final double weightedAverage;

  /// Simple average of the DST category (1–4).
  final double simpleCategoryAverage;

  /// Area-weighted average of the DST category (1–4).
  final double weightedCategoryAverage;

  /// Rounded category (area-weighted, .5 rounds up).
  final int roundedCategory;

  /// DST answer range string, e.g. "15.26-20".
  final String answer;

  final List<WalkabilityRegionInfo> regions;
  final List<List<double>>? drawnPolygon;

  /// Live EPA class breaks (colors + labels) fetched from the renderer.
  final List<EpaWalkabilityClassBreak> classBreaks;

  WalkabilityIndexDrawingResult({
    required this.regionCount,
    required this.matchedAddress,
    required this.lon,
    required this.lat,
    required this.simpleAverage,
    required this.weightedAverage,
    required this.simpleCategoryAverage,
    required this.weightedCategoryAverage,
    required this.roundedCategory,
    required this.answer,
    required this.regions,
    required this.classBreaks,
    this.drawnPolygon,
  });
}

// ─── Per-region model ─────────────────────────────────────────────────────────

/// Per-region info from the EPA Walkability Index query.
class WalkabilityRegionInfo {
  final String objectId;

  /// Raw NatWalkInd value (1–20 scale).
  final double? walkIndex;

  /// DST category (1–4) derived from walkIndex.
  final int? category;

  /// Area of the intersection of this region with the drawn polygon (sq miles).
  final double areaSqMiles;

  /// DST answer range, e.g. "15.26-20".
  final String bucket;

  final double points;

  /// Full region polygon ring as [lon, lat] pairs — used for map rendering.
  final List<List<double>> geometry;

  /// Clipped intersection polygon — may be empty if clip failed.
  final List<List<double>> clippedGeometry;

  WalkabilityRegionInfo({
    required this.objectId,
    required this.walkIndex,
    required this.category,
    required this.areaSqMiles,
    required this.bucket,
    required this.points,
    required this.geometry,
    required this.clippedGeometry,
  });
}

// ─── Service ──────────────────────────────────────────────────────────────────

/// Service that queries the EPA National Walkability Index MapServer Layer 0
/// for a user-drawn polygon and returns an area-weighted average walkability
/// score to autofill the DST answer.
///
/// NatWalkInd ranges 1–20. DST category mapping:
///   1–5.75   → Category 1 → "1-5.75"
///   5.76–10.50 → Category 2 → "5.76-10.50"
///   10.51–15.25 → Category 3 → "10.51-15.25"
///   15.26–20 → Category 4 → "15.26-20"
///
/// Rounding rule: area-weighted category average, .5 or more rounds UP.
///
/// Colors are fetched live from the EPA renderer endpoint — matching the
/// Python prototype exactly — rather than being hardcoded.
class WalkabilityIndexDrawingService {
  static const String _epaRoot =
      'https://geodata.epa.gov/arcgis/rest/services/OA/WalkabilityIndex/MapServer';
  static const int _layerId = 0; // NationalWalkabilityIndex block groups

  // ─── Public entry point ──────────────────────────────────────────────────────

  static Future<WalkabilityIndexDrawingResult> calculateFromPolygon({
    required String address,
    required List<List<double>> polygonPoints,
  }) async {
    print('=== Walkability Index Calculation Starting ===');

    try {
      // Step 1: Geocode ────────────────────────────────────────────────────────
      print('Step 1: Geocoding address...');
      final geocodeResult = await _geocodeAddress(address);
      final lon = geocodeResult['lon'] as double;
      final lat = geocodeResult['lat'] as double;
      final matched = geocodeResult['matched'] as String;
      print('✔ Geocoded: $matched at ($lon, $lat)');

      // Step 2: Fetch EPA renderer (value field + live colors) ─────────────────
      print('Step 2: Fetching EPA renderer...');
      final rendererData = await _fetchRenderer();
      final valueField = rendererData['valueField'] as String;
      final classBreaks =
          rendererData['classBreaks'] as List<EpaWalkabilityClassBreak>;
      print('✔ Value field: $valueField, ${classBreaks.length} class breaks');

      // Step 3: Query intersecting EPA regions ─────────────────────────────────
      print('Step 3: Querying EPA WalkabilityIndex Layer $_layerId...');
      final epaFeatures = await _fetchIntersectingRegions(
        polygonPoints,
        valueField,
      );
      print('✔ Found ${epaFeatures.length} intersecting regions');

      // Step 4: Compute area-weighted averages ─────────────────────────────────
      print('Step 4: Computing area-weighted averages...');
      final regionInfoList = <WalkabilityRegionInfo>[];
      double sumIndex = 0.0;
      int countWithIndex = 0;
      double weightedSum = 0.0;
      double totalArea = 0.0;

      double csum = 0.0;
      int cn = 0;
      double cwsum = 0.0;
      double cwarea = 0.0;

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

        // Extract NatWalkInd value (already 1–20 scale — no scaling needed)
        final rawVal = attrs[valueField];
        double? walkIndex;
        if (rawVal != null) {
          final parsed = double.tryParse(rawVal.toString());
          if (parsed != null && parsed >= 0) {
            walkIndex = parsed;
          }
        }

        final int? category = walkIndex != null
            ? _categoryForValue(walkIndex)
            : null;
        final bucketInfo = _getDstBucket(walkIndex ?? 0.0);

        regionInfoList.add(
          WalkabilityRegionInfo(
            objectId: objectId,
            walkIndex: walkIndex,
            category: category,
            areaSqMiles: areaSqMiles,
            bucket: bucketInfo['bucket'] as String,
            points: bucketInfo['points'] as double,
            geometry: rawGeometry,
            clippedGeometry: clipped,
          ),
        );

        if (walkIndex != null) {
          sumIndex += walkIndex;
          countWithIndex++;
          weightedSum += walkIndex * areaSqMiles;
          totalArea += areaSqMiles;
        }

        if (category != null) {
          csum += category;
          cn++;
          cwsum += category * areaSqMiles;
          cwarea += areaSqMiles;
        }

        print(
          '  Region $objectId: NatWalkInd=${walkIndex?.toStringAsFixed(2) ?? "N/A"} '
          'Cat=$category (${areaSqMiles.toStringAsFixed(4)} sq mi)',
        );
      }

      final simpleAvg = countWithIndex > 0 ? sumIndex / countWithIndex : 0.0;
      final weightedAvg = totalArea > 0 ? weightedSum / totalArea : 0.0;
      final simpleCatAvg = cn > 0 ? csum / cn : 0.0;
      final weightedCatAvg = cwarea > 0 ? cwsum / cwarea : 0.0;

      // Rounding rule: .5 or more rounds UP (mirrors Python roundHalfUp)
      final pickedCat = _roundHalfUp(
        weightedCatAvg > 0 ? weightedCatAvg : simpleCatAvg,
      );

      print('✔ Simple avg (NatWalkInd): ${simpleAvg.toStringAsFixed(2)}');
      print('✔ Weighted avg (NatWalkInd): ${weightedAvg.toStringAsFixed(2)}');
      print('✔ Weighted category avg: ${weightedCatAvg.toStringAsFixed(2)}');
      print('✔ Rounded category: $pickedCat');

      final answer = _rangeForCategory(pickedCat);
      print('✔ DST answer: $answer');
      print('=== Walkability Index Calculation Complete ===');

      return WalkabilityIndexDrawingResult(
        regionCount: regionInfoList.length,
        matchedAddress: matched,
        lon: lon,
        lat: lat,
        simpleAverage: simpleAvg,
        weightedAverage: weightedAvg,
        simpleCategoryAverage: simpleCatAvg,
        weightedCategoryAverage: weightedCatAvg,
        roundedCategory: pickedCat,
        answer: answer,
        regions: regionInfoList,
        classBreaks: classBreaks,
        drawnPolygon: polygonPoints,
      );
    } catch (e) {
      print('Walkability Index Calculation Failed: $e');
      rethrow;
    }
  }

  // ─── Category / answer helpers ────────────────────────────────────────────────
  // Mirrors Python categoryForValue() and rangeForCategory().

  static int _categoryForValue(double v) {
    if (v <= 5.75) return 1;
    if (v <= 10.50) return 2;
    if (v <= 15.25) return 3;
    return 4;
  }

  static String _rangeForCategory(int c) {
    if (c <= 1) return '1-5.75';
    if (c == 2) return '5.76-10.50';
    if (c == 3) return '10.51-15.25';
    return '15.26-20';
  }

  /// Rounds x: .5 or more rounds UP — mirrors Python math.floor(x + 0.5).
  static int _roundHalfUp(double x) => (x + 0.5).floor().clamp(1, 4);

  static Map<String, dynamic> _getDstBucket(double v) {
    if (v <= 5.75) return {'bucket': '1-5.75', 'points': 3.125};
    if (v <= 10.50) return {'bucket': '5.76-10.50', 'points': 6.25};
    if (v <= 15.25) return {'bucket': '10.51-15.25', 'points': 9.375};
    return {'bucket': '15.26-20', 'points': 12.5};
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

    // Value field — known fallback: NatWalkInd
    String valueField = 'NatWalkInd';
    if (renderer != null) {
      final f = renderer['field'] as String? ?? renderer['field1'] as String?;
      if (f != null && f.isNotEmpty) valueField = f;
    }

    // Class breaks → Colors (mirrors Python rgbaCss([R,G,B,A]))
    final breaks = <EpaWalkabilityClassBreak>[];
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
          EpaWalkabilityClassBreak(
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
      throw Exception(
        'No EPA walkability regions returned. Try drawing a larger polygon.',
      );
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

  // ─── Geometry helpers ─────────────────────────────────────────────────────────

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
