import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:decision_support_tool/services/geocoding_service.dart';
import 'package:decision_support_tool/services/geo_utils.dart';

class WalkingRateDrawingResult {
  final int tractCount;
  final String matchedAddress;
  final double lon;
  final double lat;
  final double simpleAverage;
  final double weightedAverage;
  final String answer;
  final List<TractInfo> tracts;
  final List<List<double>>? drawnPolygon;

  WalkingRateDrawingResult({
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
  final double? walkRate;
  final double areaSqMiles;
  final String bucket;
  final double points;
  final List<List<double>> geometry;
  final List<List<double>> clippedGeometry;

  TractInfo({
    required this.geoid,
    required this.tractLabel,
    required this.walkRate,
    required this.areaSqMiles,
    required this.bucket,
    required this.points,
    required this.geometry,
    required this.clippedGeometry,
  });
}

/// Walking-rate service that reads tract geometry + ACS rates from a local
/// asset file (assets/data/nevada_walking_rate.json) instead of calling
/// Census TIGERweb + the ACS API at runtime.
///
/// The asset file covers Clark + Washoe counties (every jurisdiction the
/// PST app supports) and is built once by running:
///   python3 data_processing/Q3_walking_rate/download_walking_rate_data.py
///
/// Mirrors BikingRateDrawingService's structure and bucket logic exactly;
/// see data_processing/Q3_walking_rate/README.md.
class WalkingRateDrawingService {
  static const String _assetPath = 'assets/data/nevada_walking_rate.json';

  static List<Map<String, dynamic>>? _cachedFeatures;

  static Future<WalkingRateDrawingResult> calculateFromPolygon({
    required String address,
    required List<List<double>> polygonPoints,
  }) async {
    final geocode = await GeocodingService.geocodeAddress(address);
    final features = await _loadLocalTractData();

    final intersecting = _findIntersectingTracts(features, polygonPoints);
    if (intersecting.isEmpty) {
      throw Exception(
        'No Census Tracts found inside your drawn area.\n'
        'Try drawing a larger polygon.',
      );
    }

    final tractInfoList = <TractInfo>[];
    double sumRate = 0.0;
    int countWithRate = 0;
    double weightedSum = 0.0;
    double totalArea = 0.0;

    for (final feat in intersecting) {
      final props = feat['properties'] as Map<String, dynamic>;
      final geoid = props['GEOID'] as String;
      final tractLabel = props['NAME'] as String;
      final walkRateRaw = props['walkRate'];
      final double? walkRate = walkRateRaw != null
          ? (walkRateRaw as num).toDouble()
          : null;

      final geometry = feat['_ring'] as List<List<double>>;
      final clipped = GeoUtils.clipPolygon(geometry, polygonPoints);
      double areaSqMiles;
      if (clipped.length >= 3) {
        final shArea = GeoUtils.polygonAreaSqMiles(clipped);
        final sampledArea = GeoUtils.estimateIntersectionAreaSqMiles(
          geometry,
          polygonPoints,
        );
        areaSqMiles = (sampledArea > 0 && shArea > sampledArea * 2.5)
            ? sampledArea
            : shArea;
      } else {
        areaSqMiles = GeoUtils.estimateIntersectionAreaSqMiles(
          geometry,
          polygonPoints,
        );
      }

      final bucketInfo = _getDstBucket(walkRate ?? 0.0);

      tractInfoList.add(
        TractInfo(
          geoid: geoid,
          tractLabel: tractLabel,
          walkRate: walkRate,
          areaSqMiles: areaSqMiles,
          bucket: bucketInfo['bucket'] as String,
          points: bucketInfo['points'] as double,
          geometry: geometry,
          clippedGeometry: clipped,
        ),
      );

      if (walkRate != null) {
        sumRate += walkRate;
        countWithRate++;
        weightedSum += walkRate * areaSqMiles;
        totalArea += areaSqMiles;
      }
    }

    if (countWithRate == 0) {
      throw Exception(
        'Walking-rate data is not available for these tracts.',
      );
    }

    final simpleAvg = sumRate / countWithRate;
    final weightedAvg = totalArea > 0 ? weightedSum / totalArea : simpleAvg;
    final answer = _getAnswerFromRate(simpleAvg);

    return WalkingRateDrawingResult(
      tractCount: tractInfoList.length,
      matchedAddress: geocode.matchedAddress,
      lon: geocode.lon,
      lat: geocode.lat,
      simpleAverage: simpleAvg,
      weightedAverage: weightedAvg,
      answer: answer,
      tracts: tractInfoList,
      drawnPolygon: polygonPoints,
    );
  }

  // ── Local asset loading ───────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> _loadLocalTractData() async {
    if (_cachedFeatures != null) return _cachedFeatures!;

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

      List<dynamic> outerRing;
      if (type == 'Polygon') {
        outerRing = coords[0] as List;
      } else if (type == 'MultiPolygon') {
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

      features.add({'properties': f['properties'], '_ring': ring});
    }

    _cachedFeatures = features;
    return features;
  }

  // ── Intersection detection ────────────────────────────────────────────────

  static List<Map<String, dynamic>> _findIntersectingTracts(
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

  // ── DST buckets ───────────────────────────────────────────────────────────
  // Walk-to-work thresholds from walking-rate.toml:
  //   0-1.7%    -> 1 pt
  //   1.8-5.5%  -> 2 pts
  //   5.6-12.2% -> 3 pts
  //   12.3-29.9%-> 4 pts
  //   30-54.6%  -> 5 pts

  static Map<String, dynamic> _getDstBucket(double rate) {
    if (rate <= 1.7) return {'bucket': '0-1.7%', 'points': 1.0};
    if (rate <= 5.5) return {'bucket': '1.8-5.5%', 'points': 2.0};
    if (rate <= 12.2) return {'bucket': '5.6-12.2%', 'points': 3.0};
    if (rate <= 29.9) return {'bucket': '12.3-29.9%', 'points': 4.0};
    return {'bucket': '30-54.6%', 'points': 5.0};
  }

  static String _getAnswerFromRate(double rate) {
    if (rate <= 1.7) return '0-1.7%';
    if (rate <= 5.5) return '1.8-5.5%';
    if (rate <= 12.2) return '5.6-12.2%';
    if (rate <= 29.9) return '12.3-29.9%';
    return '30-54.6%';
  }

  static void clearCache() {
    _cachedFeatures = null;
  }
}
