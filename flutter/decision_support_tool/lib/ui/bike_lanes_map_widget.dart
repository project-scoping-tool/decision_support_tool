import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// A widget that displays bike lanes and shared use paths on a map using flutter_map
class BikeLanesMapWidget extends StatelessWidget {
  final double lat;
  final double lon;
  final String matchedAddress;
  final List<Map<String, dynamic>> bikeLaneFeatures;
  final List<Map<String, dynamic>> sharedUsePathFeatures;
  final int bikeLaneLayerId;
  final int sharedUsePathLayerId;

  const BikeLanesMapWidget({
    Key? key,
    required this.lat,
    required this.lon,
    required this.matchedAddress,
    required this.bikeLaneFeatures,
    required this.sharedUsePathFeatures,
    required this.bikeLaneLayerId,
    required this.sharedUsePathLayerId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Create polylines for bike lanes (blue)
    final bikeLanePolylines = <Polyline>[];
    for (final feature in bikeLaneFeatures) {
      final geometry = feature['geometry'] as Map<String, dynamic>?;
      if (geometry == null) continue;

      // Handle LineString geometry (paths are typically lines)
      if (geometry.containsKey('paths')) {
        final paths = geometry['paths'] as List;
        for (final path in paths) {
          final points = <LatLng>[];
          for (final coord in (path as List)) {
            if (coord is List && coord.length >= 2) {
              points.add(LatLng(coord[1], coord[0]));
            }
          }
          if (points.isNotEmpty) {
            bikeLanePolylines.add(
              Polyline(
                points: points,
                color: Colors.blue[600]!,
                strokeWidth: 3.0,
              ),
            );
          }
        }
      }
    }

    // Create polylines for shared use paths (green)
    final sharedUsePathPolylines = <Polyline>[];
    for (final feature in sharedUsePathFeatures) {
      final geometry = feature['geometry'] as Map<String, dynamic>?;
      if (geometry == null) continue;

      if (geometry.containsKey('paths')) {
        final paths = geometry['paths'] as List;
        for (final path in paths) {
          final points = <LatLng>[];
          for (final coord in (path as List)) {
            if (coord is List && coord.length >= 2) {
              points.add(LatLng(coord[1], coord[0]));
            }
          }
          if (points.isNotEmpty) {
            sharedUsePathPolylines.add(
              Polyline(
                points: points,
                color: Colors.green[600]!,
                strokeWidth: 3.0,
              ),
            );
          }
        }
      }
    }

    // final totalCount = bikeLaneFeatures.length + sharedUsePathFeatures.length;

    return Dialog(
      insetPadding: EdgeInsets.all(20.0),
      child: Container(
        width: screenWidth * 0.9,
        height: screenHeight * 0.9,
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.vertical(top: Radius.circular(4.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.directions_bike,
                          color: Colors.white,
                          size: 24.0,
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: Text(
                            'Bike Lanes & Shared Use Paths - $matchedAddress',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            // Map
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(lat, lon),
                  initialZoom: 15.0, // Zoom in more for 1/4 mile
                  minZoom: 10.0,
                  maxZoom: 18.0,
                ),
                children: [
                  // OpenStreetMap tiles
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  // Radius circle (1/4 mile = 402.336 meters)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: LatLng(lat, lon),
                        radius: 402.336, // 0.25 miles in meters
                        useRadiusInMeter: true,
                        color: Colors.blue.withOpacity(0.1),
                        borderColor: Colors.blue[700]!,
                        borderStrokeWidth: 2.0,
                      ),
                    ],
                  ),
                  // Bike lane polylines (blue)
                  PolylineLayer(polylines: bikeLanePolylines),
                  // Shared use path polylines (green)
                  PolylineLayer(polylines: sharedUsePathPolylines),
                  // Project address marker
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(lat, lon),
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Legend
            Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem(
                    Icons.location_on,
                    Colors.red,
                    'Project Address',
                  ),
                  _buildLegendItem(
                    Icons.circle_outlined,
                    Colors.blue[700]!,
                    '¼ mile radius',
                  ),
                  _buildLegendItem(
                    Icons.remove,
                    Colors.blue[600]!,
                    '${bikeLaneFeatures.length} bike lane(s)',
                  ),
                  _buildLegendItem(
                    Icons.remove,
                    Colors.green[600]!,
                    '${sharedUsePathFeatures.length} shared use path(s)',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(IconData icon, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
