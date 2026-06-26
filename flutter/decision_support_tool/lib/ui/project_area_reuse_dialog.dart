import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Result returned from [showProjectAreaReuseDialog].
///
/// [reuse] is true when the user chose to reuse the saved polygon.
/// [points] holds the polygon points when [reuse] is true; null otherwise.
class ProjectAreaReuseChoice {
  final bool reuse;
  final List<LatLng>? points;
  const ProjectAreaReuseChoice.reuse(this.points) : reuse = true;
  const ProjectAreaReuseChoice.drawNew() : reuse = false, points = null;
}

/// Shows a dialog asking whether to reuse the previously drawn project area
/// or draw a new one.
///
/// Returns a [ProjectAreaReuseChoice] – never null (the dialog is not
/// dismissible).
///
/// Usage:
/// ```dart
/// final choice = await showProjectAreaReuseDialog(
///   context: context,
///   savedPoints: _savedProjectPolygon!,
///   lat: lat,
///   lon: lon,
/// );
/// if (choice.reuse) {
///   // open widget with initialPoints: choice.points
/// } else {
///   // open widget with no initialPoints
/// }
/// ```
Future<ProjectAreaReuseChoice> showProjectAreaReuseDialog({
  required BuildContext context,
  required List<LatLng> savedPoints,
  required double lat,
  required double lon,
}) async {
  final result = await showDialog<ProjectAreaReuseChoice>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) =>
        _ProjectAreaReuseDialog(savedPoints: savedPoints, lat: lat, lon: lon),
  );
  // Should never be null because the dialog always pops with a value.
  return result ?? const ProjectAreaReuseChoice.drawNew();
}

// ─── Private dialog widget ────────────────────────────────────────────────────

class _ProjectAreaReuseDialog extends StatelessWidget {
  final List<LatLng> savedPoints;
  final double lat;
  final double lon;

  const _ProjectAreaReuseDialog({
    required this.savedPoints,
    required this.lat,
    required this.lon,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      insetPadding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: screenWidth * 0.75,
        height: screenHeight * 0.75,
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4.0),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.map, color: Colors.white, size: 24.0),
                  const SizedBox(width: 10.0),
                  const Expanded(
                    child: Text(
                      'Reuse Project Area?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Info banner ───────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border(bottom: BorderSide(color: Colors.blue[200]!)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[800], size: 20),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'You already drew a project area for a previous question. '
                      'Reusing the same area ensures all questions describe '
                      'the same project boundary.',
                      style: TextStyle(fontSize: 13.0, color: Colors.blue[900]),
                    ),
                  ),
                ],
              ),
            ),

            // ── Mini-map preview ──────────────────────────────────────────────
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(lat, lon),
                  initialZoom: 15.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  if (savedPoints.length >= 2)
                    PolygonLayer(
                      polygons: [
                        Polygon(
                          points: savedPoints,
                          color: Colors.blue.withOpacity(0.20),
                          borderColor: Colors.blue[700]!,
                          borderStrokeWidth: 2.5,
                          isFilled: true,
                        ),
                      ],
                    ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: savedPoints,
                        color: Colors.blue[900]!,
                        strokeWidth: 2.0,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(lat, lon),
                        width: 36,
                        height: 36,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Action buttons ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(4.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Reuse This Area'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                    ),
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(ProjectAreaReuseChoice.reuse(savedPoints)),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.draw, size: 18),
                    label: const Text('Draw New Area'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                    ),
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(const ProjectAreaReuseChoice.drawNew()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
