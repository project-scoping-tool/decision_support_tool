import 'dart:math' as math;

/// Shared planar-geometry helpers for the local (asset-backed) auto-fill
/// services. Every calculation here works in [lon, lat] degree pairs and
/// converts to miles locally using a simple equirectangular approximation
/// (good enough at Nevada's latitude / county-scale distances — the same
/// approximation the app's existing drawing services already used against
/// live ArcGIS/EPA data).
class GeoUtils {
  /// Miles per degree of longitude at [latDeg], and miles per degree of
  /// latitude (constant).
  static (double lonToMiles, double latToMiles) milesPerDegree(double latDeg) {
    return (69.0 * math.cos(latDeg * math.pi / 180.0), 69.0);
  }

  /// Great-circle (haversine) distance in miles between two lon/lat points.
  /// Used for point-to-point radius checks (bus stops, parks, bike lanes'
  /// endpoints) — matches the geodesic buffer ArcGIS used server-side more
  /// closely than the planar approximation above at short (<1 mi) ranges.
  static double distanceMilesHaversine(
    double lon1,
    double lat1,
    double lon2,
    double lat2,
  ) {
    const earthRadiusMiles = 3958.8;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMiles * c;
  }

  static double _deg2rad(double deg) => deg * (math.pi / 180.0);

  /// Ray-casting point-in-polygon test. [ring] is a list of [lon, lat]
  /// pairs; does not need to be explicitly closed.
  static bool pointInPolygon(double x, double y, List<List<double>> ring) {
    bool inside = false;
    for (int i = 0, j = ring.length - 1; i < ring.length; j = i++) {
      final xi = ring[i][0], yi = ring[i][1];
      final xj = ring[j][0], yj = ring[j][1];
      if (((yi > y) != (yj > y)) &&
          (x < (xj - xi) * (y - yi) / (yj - yi) + xi)) {
        inside = !inside;
      }
    }
    return inside;
  }

  /// Distance in miles from point (px, py) to the segment (ax,ay)-(bx,by).
  static double distanceMilesToSegment(
    double px,
    double py,
    double ax,
    double ay,
    double bx,
    double by,
    double lonToMiles,
    double latToMiles,
  ) {
    final pxM = px * lonToMiles, pyM = py * latToMiles;
    final axM = ax * lonToMiles, ayM = ay * latToMiles;
    final bxM = bx * lonToMiles, byM = by * latToMiles;
    final dx = bxM - axM, dy = byM - ayM;
    final lenSq = dx * dx + dy * dy;
    if (lenSq == 0) {
      final ex = pxM - axM, ey = pyM - ayM;
      return math.sqrt(ex * ex + ey * ey);
    }
    final t = ((pxM - axM) * dx + (pyM - ayM) * dy) / lenSq;
    final tc = t.clamp(0.0, 1.0);
    final cx = axM + tc * dx, cy = ayM + tc * dy;
    final ex = pxM - cx, ey = pyM - cy;
    return math.sqrt(ex * ex + ey * ey);
  }

  /// Distance in miles from a point to the nearest segment of an (open)
  /// polyline.
  static double distanceMilesToPolyline(
    double lon,
    double lat,
    List<List<double>> pts,
  ) {
    if (pts.length < 2) return double.infinity;
    final avgLat = pts.map((p) => p[1]).reduce((a, b) => a + b) / pts.length;
    final (lonToMiles, latToMiles) = milesPerDegree(avgLat);
    double minDist = double.infinity;
    for (int i = 0; i < pts.length - 1; i++) {
      final d = distanceMilesToSegment(
        lon,
        lat,
        pts[i][0],
        pts[i][1],
        pts[i + 1][0],
        pts[i + 1][1],
        lonToMiles,
        latToMiles,
      );
      if (d < minDist) minDist = d;
    }
    return minDist;
  }

  /// Distance in miles from a point to a polygon: 0 if the point is inside
  /// the ring, otherwise the distance to the nearest edge. Mirrors ArcGIS's
  /// `esriSpatialRelIntersects` + buffer-distance query against polygon
  /// geometry.
  static double distanceMilesToPolygon(
    double lon,
    double lat,
    List<List<double>> ring,
  ) {
    if (ring.length < 3) return double.infinity;
    if (pointInPolygon(lon, lat, ring)) return 0.0;
    // Distance to the boundary — treat the (possibly open) ring as a closed
    // polyline by appending the first point.
    final closed = [...ring, ring.first];
    return distanceMilesToPolyline(lon, lat, closed);
  }

  /// Sutherland-Hodgman clip of [subject] by convex polygon [clip].
  static List<List<double>> clipPolygon(
    List<List<double>> subject,
    List<List<double>> clip,
  ) {
    if (subject.isEmpty || clip.isEmpty) return subject;
    List<List<double>> output = List.from(subject);
    final n = clip.length;
    for (int i = 0; i < n - 1; i++) {
      if (output.isEmpty) return [];
      final a = clip[i], b = clip[i + 1];
      final input = output;
      output = [];
      for (int j = 0; j < input.length; j++) {
        final cur = input[j];
        final prev = input[(j + input.length - 1) % input.length];
        final curIn = _side(cur, a, b);
        final prevIn = _side(prev, a, b);
        if (curIn) {
          if (!prevIn) output.add(_intersect(prev, cur, a, b));
          output.add(cur);
        } else if (prevIn) {
          output.add(_intersect(prev, cur, a, b));
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

  /// Shoelace formula, converted to sq miles (equirectangular approximation
  /// valid at ~36N, matches the constant already used across the app's
  /// existing drawing services).
  static double polygonAreaSqMiles(List<List<double>> poly) {
    if (poly.length < 3) return 0.0;
    double sum = 0.0;
    final n = poly.length;
    for (int i = 0; i < n; i++) {
      final j = (i + 1) % n;
      sum += poly[i][0] * poly[j][1] - poly[j][0] * poly[i][1];
    }
    return sum.abs() / 2.0 * 69.0 * 55.0;
  }

  /// Grid-sampling fallback for estimating the intersection area of two
  /// polygons when Sutherland-Hodgman clipping fails (non-convex input).
  static double estimateIntersectionAreaSqMiles(
    List<List<double>> polyA,
    List<List<double>> polyB,
  ) {
    if (polyA.length < 3 || polyB.length < 3) return 0.0;

    double aMinX = polyA[0][0], aMaxX = polyA[0][0];
    double aMinY = polyA[0][1], aMaxY = polyA[0][1];
    for (final p in polyA) {
      if (p[0] < aMinX) aMinX = p[0];
      if (p[0] > aMaxX) aMaxX = p[0];
      if (p[1] < aMinY) aMinY = p[1];
      if (p[1] > aMaxY) aMaxY = p[1];
    }
    double bMinX = polyB[0][0], bMaxX = polyB[0][0];
    double bMinY = polyB[0][1], bMaxY = polyB[0][1];
    for (final p in polyB) {
      if (p[0] < bMinX) bMinX = p[0];
      if (p[0] > bMaxX) bMaxX = p[0];
      if (p[1] < bMinY) bMinY = p[1];
      if (p[1] > bMaxY) bMaxY = p[1];
    }

    final minX = math.max(aMinX, bMinX);
    final maxX = math.min(aMaxX, bMaxX);
    final minY = math.max(aMinY, bMinY);
    final maxY = math.min(aMaxY, bMaxY);
    if (minX >= maxX || minY >= maxY) return 0.0;

    const gridN = 50;
    int inside = 0;
    final dx = (maxX - minX) / gridN;
    final dy = (maxY - minY) / gridN;
    for (int ix = 0; ix < gridN; ix++) {
      for (int iy = 0; iy < gridN; iy++) {
        final x = minX + (ix + 0.5) * dx;
        final y = minY + (iy + 0.5) * dy;
        if (pointInPolygon(x, y, polyA) && pointInPolygon(x, y, polyB)) {
          inside++;
        }
      }
    }
    return inside * (dx * 69.0) * (dy * 55.0);
  }
}
