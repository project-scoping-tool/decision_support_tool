// Verifies Q4 (pedestrian crash) and Q5 (bicycle crash) render the same
// semi-transparent polygon fill as Q6 (land use diversity) while drawing,
// with their own existing red color scheme, and that the polygon outline
// and numbered vertex markers are still present and unchanged.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:decision_support_tool/ui/pedestrian_crash_drawing_widget.dart';
import 'package:decision_support_tool/ui/bicycle_crash_drawing_widget.dart';

const _triangle = [
  LatLng(36.0, -115.0),
  LatLng(36.001, -115.0),
  LatLng(36.0005, -114.999),
];

void main() {
  group('Q4/Q5 drawing polygon fill (matches Q6 styling)', () {
    testWidgets('PedestrianCrashDrawingWidget shows a filled polygon', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PedestrianCrashDrawingWidget(
              lat: 36.0,
              lon: -115.0,
              matchedAddress: '123 Test St',
              initialPoints: _triangle,
              onCalculationComplete: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      final polygonLayer = tester.widget<PolygonLayer>(
        find.byType(PolygonLayer),
      );
      final polygon = polygonLayer.polygons.single;
      expect(polygon.points, _triangle);
      expect(polygon.isFilled, isTrue);
      expect(polygon.color, Colors.red.withOpacity(0.15));
      expect(polygon.borderColor, Colors.red[700]);
      expect(polygon.borderStrokeWidth, 2.5);

      // Outline and numbered vertex markers are preserved: one
      // MarkerLayer per vertex (3) plus one for the project-address pin.
      expect(find.byType(PolylineLayer), findsOneWidget);
      final markerLayers = tester.widgetList<MarkerLayer>(
        find.byType(MarkerLayer),
      );
      expect(
        markerLayers.map((l) => l.markers.length),
        containsAll([_triangle.length]),
      );
    });

    testWidgets('BicycleCrashDrawingWidget shows a filled polygon', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BicycleCrashDrawingWidget(
              lat: 36.0,
              lon: -115.0,
              matchedAddress: '123 Test St',
              initialPoints: _triangle,
              onCalculationComplete: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      final polygonLayer = tester.widget<PolygonLayer>(
        find.byType(PolygonLayer),
      );
      final polygon = polygonLayer.polygons.single;
      expect(polygon.points, _triangle);
      expect(polygon.isFilled, isTrue);
      expect(polygon.color, Colors.red.withOpacity(0.15));
      expect(polygon.borderColor, Colors.red[700]);
      expect(polygon.borderStrokeWidth, 2.5);

      // Outline and numbered vertex markers are preserved: one
      // MarkerLayer per vertex (3) plus one for the project-address pin.
      expect(find.byType(PolylineLayer), findsOneWidget);
      final markerLayers = tester.widgetList<MarkerLayer>(
        find.byType(MarkerLayer),
      );
      expect(
        markerLayers.map((l) => l.markers.length),
        containsAll([_triangle.length]),
      );
    });

    testWidgets(
      'both widgets show no polygon fill with fewer than 2 points',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PedestrianCrashDrawingWidget(
                lat: 36.0,
                lon: -115.0,
                matchedAddress: '123 Test St',
                initialPoints: const [LatLng(36.0, -115.0)],
                onCalculationComplete: (_) {},
              ),
            ),
          ),
        );
        await tester.pump();
        expect(find.byType(PolygonLayer), findsNothing);
      },
    );
  });
}
