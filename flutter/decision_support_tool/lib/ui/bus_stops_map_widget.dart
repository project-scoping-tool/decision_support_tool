import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// A widget that displays bus stops on a map using flutter_map
class BusStopsMapWidget extends StatelessWidget {
  final double lat;
  final double lon;
  final String matchedAddress;
  final List<Map<String, dynamic>> busStopFeatures;
  final int layerId;

  const BusStopsMapWidget({
    Key? key,
    required this.lat,
    required this.lon,
    required this.matchedAddress,
    required this.busStopFeatures,
    required this.layerId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Create list of markers for bus stops
    final busStopMarkers = <Marker>[];

    for (final feature in busStopFeatures) {
      final geometry = feature['geometry'] as Map<String, dynamic>?;
      if (geometry == null) continue;

      final attributes = feature['attributes'] as Map<String, dynamic>? ?? {};

      // Try to find a label for the bus stop
      String stopLabel = 'Bus Stop';
      for (final key in [
        'STOP_NAME',
        'StopName',
        'NAME',
        'Name',
        'STOPID',
        'STOP_ID',
        'ROUTE',
        'ROUTES',
      ]) {
        if (attributes.containsKey(key) && attributes[key] != null) {
          stopLabel = '$key: ${attributes[key]}';
          break;
        }
      }

      // Handle point geometry (bus stops are typically points)
      if (geometry.containsKey('x') && geometry.containsKey('y')) {
        busStopMarkers.add(
          Marker(
            point: LatLng(geometry['y'], geometry['x']),
            width: 40,
            height: 40,
            child: Tooltip(
              message: stopLabel,
              child: Icon(
                Icons.directions_bus,
                color: Colors.orange[700],
                size: 30,
              ),
            ),
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
                color: Colors.orange[700],
                borderRadius: BorderRadius.vertical(top: Radius.circular(4.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.directions_bus,
                          color: Colors.white,
                          size: 24.0,
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: Text(
                            'Bus Stops Map - $matchedAddress',
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
                        color: Colors.orange.withOpacity(0.1),
                        borderColor: Colors.orange[700]!,
                        borderStrokeWidth: 2.0,
                      ),
                    ],
                  ),
                  // Bus stop markers
                  MarkerLayer(markers: busStopMarkers),
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
                    Colors.orange[700]!,
                    '¼ mile radius',
                  ),
                  _buildLegendItem(
                    Icons.directions_bus,
                    Colors.orange[700]!,
                    '${busStopFeatures.length} bus stop(s)',
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
