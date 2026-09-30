import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:decision_support_tool/services/geocoding_service.dart';
import 'package:decision_support_tool/services/geo_utils.dart';

// ─── EPA class-break model ────────────────────────────────────────────────────

/// One class-break entry from the local static legend captured at
/// data_processing/Q6_land_use_diversity/download_land_use_diversity_data.py
/// time (originally fetched live from the EPA SLD renderer on every use).
class EpaClassBreak {
  final double maxValue;
  final String label;
  final Color fillColor;

  const EpaClassBreak({
    required this.maxValue,
    required this.label,
    required this.fillColor,
  });
}

// ─── Result model ─────────────────────────────────────────────────────────────

class LandUseDiversityDrawingResult {
  final int regionCount;
  final String matchedAddress;
  final double lon;
  final double lat;
  final double simpleAverage;
  final double weightedAverage;
  final String answer;
  final List<LandUseDiversityRegionInfo> regions;
  final List<List<double>>? drawnPolygon;
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

class LandUseDiversityRegionInfo {
  final String objectId;
  final double? diversityIndex;
  final double areaSqMiles;
  final String bucket;
  final double points;
  final List<List<double>> geometry;
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

/// Service that reads Clark + Washoe County block groups from a local
/// asset (assets/data/nevada_land_use_diversity.json) instead of querying
/// the EPA Smart Location Database (SLD) MapServer Layer 7 live.
///
/// The local dataset's value field is whatever the EPA renderer resolved
/// to at download time (see README — it was actually `D2A_EPHHM`, not the
/// `D2B_E8MIXA` name the previous code's comments described as the
/// "known fallback"; the live code always trusted the renderer's `field`
/// over that fallback, so this preserves the actual live behavior, not
/// the stale comment). Values are ~0-1 and are multiplied by ×10 for
/// display/bucketing/averaging, unchanged from the previous
/// implementation — 0.62 -> 6.2 -> "6-7".
class LandUseDiversityDrawingService {
  static const String _assetPath =
      'assets/data/nevada_land_use_diversity.json';

  static List<Map<String, dynamic>>? _cachedFeatures;
  static List<EpaClassBreak>? _cachedClassBreaks;

  static Future<LandUseDiversityDrawingResult> calculateFromPolygon({
    required String address,
    required List<List<double>> polygonPoints,
  }) async {
    final geocode = await GeocodingService.geocodeAddress(address);
    final (features, classBreaks) = await _loadLocalData();

    final intersecting = _findIntersectingRegions(features, polygonPoints);
    if (intersecting.isEmpty) {
      throw Exception(
        'No EPA regions found inside your drawn area.\n'
        'Try drawing a larger polygon.',
      );
    }

    final regionInfoList = <LandUseDiversityRegionInfo>[];
    double sumIndex = 0.0;
    int countWithIndex = 0;
    double weightedSum = 0.0;
    double totalArea = 0.0;

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

      double? diversityIndex;
      if (rawVal != null) {
        final parsed = (rawVal as num).toDouble();
        if (parsed >= 0) diversityIndex = parsed * 10.0;
      }

      final bucketInfo = _getDstBucket(diversityIndex ?? 0.0);

      regionInfoList.add(
        LandUseDiversityRegionInfo(
          objectId: objectId,
          diversityIndex: diversityIndex,
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
    }

    final simpleAvg = countWithIndex > 0 ? sumIndex / countWithIndex : 0.0;
    final weightedAvg = totalArea > 0 ? weightedSum / totalArea : 0.0;
    final answer = _getAnswerFromIndex(weightedAvg);

    return LandUseDiversityDrawingResult(
      regionCount: regionInfoList.length,
      matchedAddress: geocode.matchedAddress,
      lon: geocode.lon,
      lat: geocode.lat,
      simpleAverage: simpleAvg,
      weightedAverage: weightedAvg,
      answer: answer,
      regions: regionInfoList,
      classBreaks: classBreaks,
      drawnPolygon: polygonPoints,
    );
  }

  // ── Local asset loading ───────────────────────────────────────────────────

  static Future<(List<Map<String, dynamic>>, List<EpaClassBreak>)>
  _loadLocalData() async {
    if (_cachedFeatures != null && _cachedClassBreaks != null) {
      return (_cachedFeatures!, _cachedClassBreaks!);
    }

    final jsonString = await rootBundle.loadString(_assetPath);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    final classBreaks = <EpaClassBreak>[];
    for (final cb in (data['classBreaks'] as List)) {
      final m = cb as Map<String, dynamic>;
      final colorArr = m['color'] as List;
      final r = (colorArr[0] as num).toInt();
      final g = (colorArr[1] as num).toInt();
      final b = (colorArr[2] as num).toInt();
      final a = colorArr.length >= 4 ? (colorArr[3] as num).toInt() : 255;
      classBreaks.add(
        EpaClassBreak(
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
        'value': f['diversityIndex'],
        '_ring': ring,
      });
    }

    _cachedFeatures = features;
    _cachedClassBreaks = classBreaks;
    return (features, classBreaks);
  }

  // ── Intersection detection (mirrors WalkingRateDrawingService) ────────────

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

  // ── Buckets ──────────────────────────────────────────────────────────────────
  // [index] is already multiplied by 10. Boundary rule: exactly on a
  // boundary chooses the lower interval (e.g. 2.0 -> "0-2", not "2-3").

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

  static void clearCache() {
    _cachedFeatures = null;
    _cachedClassBreaks = null;
  }
}
