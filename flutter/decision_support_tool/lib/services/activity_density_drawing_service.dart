import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:decision_support_tool/services/geocoding_service.dart';
import 'package:decision_support_tool/services/geo_utils.dart';

// ─── EPA class-break model ────────────────────────────────────────────────────

class EpaActivityClassBreak {
  final double maxValue;
  final String label;
  final Color fillColor;

  const EpaActivityClassBreak({
    required this.maxValue,
    required this.label,
    required this.fillColor,
  });
}

// ─── Result model ─────────────────────────────────────────────────────────────

class ActivityDensityDrawingResult {
  final int regionCount;
  final String matchedAddress;
  final double lon;
  final double lat;
  final double simpleAverage;
  final double weightedAverage;
  final double weightedScoreAverage;
  final int roundedScore;
  final String answer;
  final List<ActivityDensityRegionInfo> regions;
  final List<List<double>>? drawnPolygon;
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

class ActivityDensityRegionInfo {
  final String objectId;
  final double? density;
  final double areaSqMiles;
  final String bucket;
  final double points;
  final int score;
  final List<List<double>> geometry;
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

/// Service that reads Clark + Washoe County block groups from a local
/// asset (assets/data/nevada_activity_density.json) instead of querying
/// the EPA Smart Location Database (SLD) MapServer Layer 4 live.
///
/// Scoring is unchanged from the previous implementation: per-region
/// scores (0-5) from density buckets, area-weighted average of scores,
/// rounded .5-up, mapped back to a DST answer bucket.
class ActivityDensityDrawingService {
  static const String _assetPath = 'assets/data/nevada_activity_density.json';

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

  static List<Map<String, dynamic>>? _cachedFeatures;
  static List<EpaActivityClassBreak>? _cachedClassBreaks;

  static Future<ActivityDensityDrawingResult> calculateFromPolygon({
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

    final regionInfoList = <ActivityDensityRegionInfo>[];
    double sumDensity = 0.0;
    int countWithDensity = 0;
    double weightedDensitySum = 0.0;
    double weightedScoreSum = 0.0;
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

      double? density;
      if (rawVal != null) {
        final parsed = (rawVal as num).toDouble();
        if (parsed >= 0) density = parsed;
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
    }

    final simpleAvg = countWithDensity > 0
        ? sumDensity / countWithDensity
        : 0.0;
    final weightedAvg = totalArea > 0 ? weightedDensitySum / totalArea : 0.0;
    final scoreAvg = totalArea > 0 ? weightedScoreSum / totalArea : 0.0;

    final frac = scoreAvg - scoreAvg.floor();
    int rounded = (frac >= 0.5) ? scoreAvg.ceil() : scoreAvg.floor();
    rounded = rounded.clamp(0, 5);

    final chosenBucket = _buckets.firstWhere(
      (b) => b.score == rounded,
      orElse: () => _buckets[0],
    );

    return ActivityDensityDrawingResult(
      regionCount: regionInfoList.length,
      matchedAddress: geocode.matchedAddress,
      lon: geocode.lon,
      lat: geocode.lat,
      simpleAverage: simpleAvg,
      weightedAverage: weightedAvg,
      weightedScoreAverage: scoreAvg,
      roundedScore: rounded,
      answer: chosenBucket.text,
      regions: regionInfoList,
      classBreaks: classBreaks,
      drawnPolygon: polygonPoints,
    );
  }

  // ── Local asset loading ───────────────────────────────────────────────────

  static Future<(List<Map<String, dynamic>>, List<EpaActivityClassBreak>)>
  _loadLocalData() async {
    if (_cachedFeatures != null && _cachedClassBreaks != null) {
      return (_cachedFeatures!, _cachedClassBreaks!);
    }

    final jsonString = await rootBundle.loadString(_assetPath);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    final classBreaks = <EpaActivityClassBreak>[];
    for (final cb in (data['classBreaks'] as List)) {
      final m = cb as Map<String, dynamic>;
      final colorArr = m['color'] as List;
      final r = (colorArr[0] as num).toInt();
      final g = (colorArr[1] as num).toInt();
      final b = (colorArr[2] as num).toInt();
      final a = colorArr.length >= 4 ? (colorArr[3] as num).toInt() : 255;
      classBreaks.add(
        EpaActivityClassBreak(
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
        'value': f['density'],
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

  // ── Bucket helper (mirrors Python bucketForDensity(v)) ─────────────────────

  static _DstBucket _getBucketForDensity(double? v) {
    if (v == null || !v.isFinite) return _buckets[0];
    if (v == 0.0) return _buckets[0];
    for (final b in _buckets) {
      if (b.min == null) continue;
      if (v >= b.min! && v <= b.max!) return b;
    }
    return _buckets.last;
  }

  static void clearCache() {
    _cachedFeatures = null;
    _cachedClassBreaks = null;
  }
}
