import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:decision_support_tool/services/geocoding_service.dart';
import 'package:decision_support_tool/services/geo_utils.dart';

// ─── EPA class-break model ────────────────────────────────────────────────────

class EpaWalkabilityClassBreak {
  final double maxValue;
  final String label;
  final Color fillColor;

  const EpaWalkabilityClassBreak({
    required this.maxValue,
    required this.label,
    required this.fillColor,
  });
}

// ─── Result model ─────────────────────────────────────────────────────────────

class WalkabilityIndexDrawingResult {
  final int regionCount;
  final String matchedAddress;
  final double lon;
  final double lat;
  final double simpleAverage;
  final double weightedAverage;
  final double simpleCategoryAverage;
  final double weightedCategoryAverage;
  final int roundedCategory;
  final String answer;
  final List<WalkabilityRegionInfo> regions;
  final List<List<double>>? drawnPolygon;
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

class WalkabilityRegionInfo {
  final String objectId;
  final double? walkIndex;
  final int? category;
  final double areaSqMiles;
  final String bucket;
  final double points;
  final List<List<double>> geometry;
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

/// Service that reads Clark + Washoe County block groups from a local
/// asset (assets/data/nevada_walkability_index.json) instead of querying
/// the EPA National Walkability Index MapServer Layer 0 live.
///
/// NatWalkInd ranges 1-20; DST category mapping and rounding rule are
/// unchanged from the previous implementation:
///   1-5.75 -> Cat 1 -> "1-5.75";  5.76-10.50 -> Cat 2 -> "5.76-10.50"
///   10.51-15.25 -> Cat 3 -> "10.51-15.25";  15.26-20 -> Cat 4 -> "15.26-20"
///   area-weighted category average, .5 or more rounds up.
class WalkabilityIndexDrawingService {
  static const String _assetPath =
      'assets/data/nevada_walkability_index.json';

  static List<Map<String, dynamic>>? _cachedFeatures;
  static List<EpaWalkabilityClassBreak>? _cachedClassBreaks;

  static Future<WalkabilityIndexDrawingResult> calculateFromPolygon({
    required String address,
    required List<List<double>> polygonPoints,
  }) async {
    final geocode = await GeocodingService.geocodeAddress(address);
    final (features, classBreaks) = await _loadLocalData();

    final intersecting = _findIntersectingRegions(features, polygonPoints);
    if (intersecting.isEmpty) {
      throw Exception(
        'No EPA walkability regions found inside your drawn area.\n'
        'Try drawing a larger polygon.',
      );
    }

    final regionInfoList = <WalkabilityRegionInfo>[];
    double sumIndex = 0.0;
    int countWithIndex = 0;
    double weightedSum = 0.0;
    double totalArea = 0.0;

    double csum = 0.0;
    int cn = 0;
    double cwsum = 0.0;
    double cwarea = 0.0;

    for (final feat in intersecting) {
      final objectId = feat['geoid'] as String;
      final rawGeometry = feat['_ring'] as List<List<double>>;
      final rawVal = feat['value'];

      final clipped = GeoUtils.clipPolygon(rawGeometry, polygonPoints);
      double areaSqMiles;
      if (clipped.length >= 3) {
        final shArea = GeoUtils.polygonAreaSqMiles(clipped);
        final sampledArea = GeoUtils.estimateIntersectionAreaSqMiles(
          rawGeometry,
          polygonPoints,
        );
        areaSqMiles = (sampledArea > 0 && shArea > sampledArea * 2.5)
            ? sampledArea
            : shArea;
      } else {
        areaSqMiles = GeoUtils.estimateIntersectionAreaSqMiles(
          rawGeometry,
          polygonPoints,
        );
      }

      double? walkIndex;
      if (rawVal != null) {
        final parsed = (rawVal as num).toDouble();
        if (parsed >= 0) walkIndex = parsed;
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
    }

    final simpleAvg = countWithIndex > 0 ? sumIndex / countWithIndex : 0.0;
    final weightedAvg = totalArea > 0 ? weightedSum / totalArea : 0.0;
    final simpleCatAvg = cn > 0 ? csum / cn : 0.0;
    final weightedCatAvg = cwarea > 0 ? cwsum / cwarea : 0.0;

    final pickedCat = _roundHalfUp(
      weightedCatAvg > 0 ? weightedCatAvg : simpleCatAvg,
    );
    final answer = _rangeForCategory(pickedCat);

    return WalkabilityIndexDrawingResult(
      regionCount: regionInfoList.length,
      matchedAddress: geocode.matchedAddress,
      lon: geocode.lon,
      lat: geocode.lat,
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
  }

  // ── Category / answer helpers (mirrors previous categoryForValue()) ───────

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

  static int _roundHalfUp(double x) => (x + 0.5).floor().clamp(1, 4);

  static Map<String, dynamic> _getDstBucket(double v) {
    if (v <= 5.75) return {'bucket': '1-5.75', 'points': 3.125};
    if (v <= 10.50) return {'bucket': '5.76-10.50', 'points': 6.25};
    if (v <= 15.25) return {'bucket': '10.51-15.25', 'points': 9.375};
    return {'bucket': '15.26-20', 'points': 12.5};
  }

  // ── Local asset loading ───────────────────────────────────────────────────

  static Future<(List<Map<String, dynamic>>, List<EpaWalkabilityClassBreak>)>
  _loadLocalData() async {
    if (_cachedFeatures != null && _cachedClassBreaks != null) {
      return (_cachedFeatures!, _cachedClassBreaks!);
    }

    final jsonString = await rootBundle.loadString(_assetPath);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    final classBreaks = <EpaWalkabilityClassBreak>[];
    for (final cb in (data['classBreaks'] as List)) {
      final m = cb as Map<String, dynamic>;
      final colorArr = m['color'] as List;
      final r = (colorArr[0] as num).toInt();
      final g = (colorArr[1] as num).toInt();
      final b = (colorArr[2] as num).toInt();
      final a = colorArr.length >= 4 ? (colorArr[3] as num).toInt() : 255;
      classBreaks.add(
        EpaWalkabilityClassBreak(
          maxValue: (m['max'] as num).toDouble(),
          label: m['label'] as String,
          fillColor: Color.fromARGB(a, r, g, b),
        ),
      );
    }

    final rawFeatures = data['features'] as List;
    final features = <Map<String, dynamic>>[];
    for (final raw in rawFeatures) {
      final f = raw as Map<String, dynamic>;
      final rawRings = f['rings'] as List?;
      if (rawRings == null || rawRings.isEmpty) continue;
      final ring = (rawRings[0] as List)
          .map<List<double>>(
            (p) => [(p[0] as num).toDouble(), (p[1] as num).toDouble()],
          )
          .toList();
      features.add({
        'geoid': (f['geoid'] ?? '?').toString(),
        'value': f['walkIndex'],
        '_ring': ring,
      });
    }

    _cachedFeatures = features;
    _cachedClassBreaks = classBreaks;
    return (features, classBreaks);
  }

  // ── Intersection detection ────────────────────────────────────────────────

  static List<Map<String, dynamic>> _findIntersectingRegions(
    List<Map<String, dynamic>> features,
    List<List<double>> drawnPolygon,
  ) {
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

      double tMinX = ring[0][0], tMaxX = ring[0][0];
      double tMinY = ring[0][1], tMaxY = ring[0][1];
      for (final p in ring) {
        if (p[0] < tMinX) tMinX = p[0];
        if (p[0] > tMaxX) tMaxX = p[0];
        if (p[1] < tMinY) tMinY = p[1];
        if (p[1] > tMaxY) tMaxY = p[1];
      }

      if (tMaxX < dMinX || tMinX > dMaxX || tMaxY < dMinY || tMinY > dMaxY) {
        continue;
      }

      if (_polygonsIntersect(ring, drawnPolygon)) {
        result.add(feat);
      }
    }
    return result;
  }

  static bool _polygonsIntersect(List<List<double>> a, List<List<double>> b) {
    for (final p in a) {
      if (GeoUtils.pointInPolygon(p[0], p[1], b)) return true;
    }
    for (final p in b) {
      if (GeoUtils.pointInPolygon(p[0], p[1], a)) return true;
    }
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
        ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))) {
      return true;
    }
    return false;
  }

  static double _cross(List<double> o, List<double> a, List<double> b) =>
      (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0]);

  static void clearCache() {
    _cachedFeatures = null;
    _cachedClassBreaks = null;
  }
}
