import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// A widget that displays parks on a map using flutter_map
class ParksMapWidget extends StatelessWidget {
  final double lat;
  final double lon;
  final String matchedAddress;
  final List<Map<String, dynamic>> parkFeatures;
  final int layerId;

  const ParksMapWidget({
    Key? key,
    required this.lat,
    required this.lon,
    required this.matchedAddress,
    required this.parkFeatures,
    required this.layerId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Create list of polygons for parks
    final parkPolygons = <Polygon>[];
    final parkMarkers = <Marker>[];

    for (final feature in parkFeatures) {
      final geometry = feature['geometry'] as Map<String, dynamic>?;
      if (geometry == null) continue;

      final attributes = feature['attributes'] as Map<String, dynamic>? ?? {};
      String parkName = 'Park';
      for (final key in [
        'NAME',
        'Name',
        'PARK_NAME',
        'PARKNAME',
        'FACILITY_N',
        'FACILITY',
      ]) {
        if (attributes.containsKey(key) && attributes[key] != null) {
          parkName = attributes[key].toString();
          break;
        }
      }

      // Handle polygon geometry
      if (geometry.containsKey('rings')) {
        final rings = geometry['rings'] as List;
        if (rings.isNotEmpty) {
          final ring = rings[0] as List;
          final points = <LatLng>[];
          for (final coord in ring) {
            if (coord is List && coord.length >= 2) {
              points.add(LatLng(coord[1], coord[0]));
            }
          }
          if (points.isNotEmpty) {
            parkPolygons.add(
              Polygon(
                points: points,
                color: Colors.green.withOpacity(0.3),
                borderColor: Colors.green[700]!,
                borderStrokeWidth: 2.0,
                label: parkName,
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 12.0,
                  backgroundColor: Colors.white.withOpacity(0.8),
                ),
              ),
            );
          }
        }
      }
      // Handle point geometry
      else if (geometry.containsKey('x') && geometry.containsKey('y')) {
        parkMarkers.add(
          Marker(
            point: LatLng(geometry['y'], geometry['x']),
            width: 40,
            height: 40,
            child: Icon(Icons.park, color: Colors.green[700], size: 30),
          ),
        );
      }
    }

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
                        Icon(Icons.map, color: Colors.white, size: 24.0),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: Text(
                            'Parks Map - $matchedAddress',
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
                  initialZoom: 14.0,
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
                  // Radius circle
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: LatLng(lat, lon),
                        radius: 804.672, // 0.5 miles in meters
                        useRadiusInMeter: true,
                        color: Colors.blue.withOpacity(0.1),
                        borderColor: Colors.blue[700]!,
                        borderStrokeWidth: 2.0,
                      ),
                    ],
                  ),
                  // Park polygons
                  PolygonLayer(polygons: parkPolygons),
                  // Park markers (for point geometries)
                  MarkerLayer(markers: parkMarkers),
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
                    '½ mile radius',
                  ),
                  _buildLegendItem(
                    Icons.park,
                    Colors.green[700]!,
                    '${parkFeatures.length} park(s)',
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
