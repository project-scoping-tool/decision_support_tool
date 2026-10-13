// Verifies the true-polygon-area / point-in-polygon geometry that
// PedestrianCrashDrawingService and BicycleCrashDrawingService now use
// (via GeoUtils) for Q4/Q5, replacing the old 0.25-mile buffer-around-a-
// polyline approach. Both services delegate directly to GeoUtils.
// polygonAreaSqMiles / GeoUtils.pointInPolygon with no extra math of
// their own, so exercising GeoUtils here with a hand-verifiable shape
// is an exact, deterministic stand-in for the services' own
// calculateFromPolygon (which additionally needs network geocoding and
// bundled CSV assets, so isn't practical to exercise end-to-end here).
import 'package:flutter_test/flutter_test.dart';
import 'package:decision_support_tool/services/geo_utils.dart';

void main() {
  group('Crash polygon geometry (GeoUtils, as used by Q4/Q5)', () {
    // A 1-mile x 1-mile square. GeoUtils.polygonAreaSqMiles converts
    // degrees to miles with fixed 69.0 (lat) / 55.0 (lon) factors, so a
    // 1/69deg x 1/55deg box measures out to exactly 1.0 sq mi under that
    // same conversion -- this isolates the shoelace-area logic itself
    // from the (pre-existing, unrelated) geodetic-approximation choice.
    const lon0 = -115.0;
    const lat0 = 36.0;
    const lonDelta = 1.0 / 55.0;
    const latDelta = 1.0 / 69.0;

    final square = [
      [lon0, lat0],
      [lon0 + lonDelta, lat0],
      [lon0 + lonDelta, lat0 + latDelta],
      [lon0, lat0 + latDelta],
    ];

    test('polygonAreaSqMiles computes the true drawn-polygon area', () {
      final area = GeoUtils.polygonAreaSqMiles(square);
      expect(area, closeTo(1.0, 1e-9));
    });

    test('polygonAreaSqMiles is unaffected by an explicit closing point', () {
      // The drawing widgets append the first point again before calling
      // the service ("close ring") -- the area must come out identical
      // whether or not that extra point is present.
      final closed = [...square, square.first];
      expect(
        GeoUtils.polygonAreaSqMiles(closed),
        closeTo(GeoUtils.polygonAreaSqMiles(square), 1e-9),
      );
    });

    test('pointInPolygon correctly classifies points inside vs. outside', () {
      final center = [lon0 + lonDelta / 2, lat0 + latDelta / 2];
      final nearCorner = [lon0 + lonDelta * 0.1, lat0 + latDelta * 0.1];
      final outsideSouthwest = [lon0 - lonDelta, lat0 - latDelta];
      final outsideFar = [lon0 + lonDelta * 10, lat0];

      expect(GeoUtils.pointInPolygon(center[0], center[1], square), isTrue);
      expect(
        GeoUtils.pointInPolygon(nearCorner[0], nearCorner[1], square),
        isTrue,
      );
      expect(
        GeoUtils.pointInPolygon(
          outsideSouthwest[0],
          outsideSouthwest[1],
          square,
        ),
        isFalse,
      );
      expect(
        GeoUtils.pointInPolygon(outsideFar[0], outsideFar[1], square),
        isFalse,
      );
    });

    test(
      'count-inside / area reproduces the density calculation the crash '
      'services now perform (point-in-polygon count / true polygon area)',
      () {
        // 5 "crash" points inside the square, 3 clearly outside -- mirrors
        // PedestrianCrashDrawingService/BicycleCrashDrawingService's
        // _filterCrashesInPolygon + density = count / areaSqMiles.
        final insidePoints = [
          [lon0 + lonDelta * 0.2, lat0 + latDelta * 0.2],
          [lon0 + lonDelta * 0.4, lat0 + latDelta * 0.6],
          [lon0 + lonDelta * 0.5, lat0 + latDelta * 0.5],
          [lon0 + lonDelta * 0.8, lat0 + latDelta * 0.3],
          [lon0 + lonDelta * 0.9, lat0 + latDelta * 0.9],
        ];
        final outsidePoints = [
          [lon0 - lonDelta, lat0 - latDelta],
          [lon0 + lonDelta * 2, lat0 + latDelta * 2],
          [lon0 + lonDelta * 0.5, lat0 - latDelta * 5],
        ];

        final allPoints = [...insidePoints, ...outsidePoints];
        final countInside = allPoints
            .where((p) => GeoUtils.pointInPolygon(p[0], p[1], square))
            .length;

        expect(countInside, equals(insidePoints.length));

        final area = GeoUtils.polygonAreaSqMiles(square);
        final density = area > 0 ? countInside / area : 0.0;
        expect(density, closeTo(5.0, 1e-6));
      },
    );

    test(
      'a larger polygon containing the same points yields a lower density '
      '(true area scales with the drawn shape, unlike a fixed-radius buffer)',
      () {
        // Same square scaled 2x in each direction -> 4x the area. This is
        // the behavior a fixed 0.25-mile buffer could never reproduce,
        // since a buffer's area depended only on the drawn line's length,
        // not the project boundary the user actually drew.
        final biggerSquare = [
          [lon0, lat0],
          [lon0 + lonDelta * 2, lat0],
          [lon0 + lonDelta * 2, lat0 + latDelta * 2],
          [lon0, lat0 + latDelta * 2],
        ];
        final biggerArea = GeoUtils.polygonAreaSqMiles(biggerSquare);
        expect(biggerArea, closeTo(4.0, 1e-6));

        final point = [lon0 + lonDelta * 0.5, lat0 + latDelta * 0.5];
        expect(
          GeoUtils.pointInPolygon(point[0], point[1], square),
          isTrue,
        );
        expect(
          GeoUtils.pointInPolygon(point[0], point[1], biggerSquare),
          isTrue,
        );
      },
    );
  });
}
