// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'dart:math' as math;

// /// Data model for pedestrian crash map
// class PedestrianCrashMapData {
//   final double lon;
//   final double lat;
//   final String matchedAddress;
//   final List<Map<String, dynamic>> crashFeatures;
//   final int crashCount;
//   final double density;
//   final double areaSqMiles;
//   final List<List<double>>? drawnPolyline;

//   PedestrianCrashMapData({
//     required this.lon,
//     required this.lat,
//     required this.matchedAddress,
//     required this.crashFeatures,
//     required this.crashCount,
//     required this.density,
//     required this.areaSqMiles,
//     this.drawnPolyline,
//   });
// }

// /// Widget that displays pedestrian crashes on a map
// class PedestrianCrashMapWidget extends StatelessWidget {
//   final double lat;
//   final double lon;
//   final String matchedAddress;
//   final List<Map<String, dynamic>> crashFeatures;
//   final int crashCount;
//   final double density;
//   final double areaSqMiles;
//   final List<List<double>>? drawnPolyline;

//   const PedestrianCrashMapWidget({
//     Key? key,
//     required this.lat,
//     required this.lon,
//     required this.matchedAddress,
//     required this.crashFeatures,
//     required this.crashCount,
//     required this.density,
//     required this.areaSqMiles,
//     this.drawnPolyline,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     // Group crashes by location to count crashes at same point
//     final crashMarkers = _createCrashMarkers(crashFeatures);

//     // Process drawn polyline for display
//     List<LatLng>? drawnLinePoints;
//     List<LatLng>? bufferedPolygonPoints;

//     if (drawnPolyline != null && drawnPolyline!.isNotEmpty) {
//       // Convert drawn polyline to LatLng
//       drawnLinePoints = drawnPolyline!
//           .map((coords) => LatLng(coords[1], coords[0]))
//           .toList();

//       // Closed polygon ring for hole rendering (last point = first)

// Create buffered area using SAME algorithm as service
//       const bufferMiles = 0.25;
//       final bufferedPolygon = _createBufferedPolygon(
//         drawnPolyline!,
//         bufferMiles,
//       );

//       // Convert buffered polygon to LatLng for display
//       bufferedPolygonPoints = bufferedPolygon
//           .map((coords) => LatLng(coords[1], coords[0]))
//           .toList();
//     }

//     return Dialog(
//       insetPadding: EdgeInsets.all(20.0),
//       child: Container(
//         width: screenWidth * 0.9,
//         height: screenHeight * 0.9,
//         child: Column(
//           children: [
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//               decoration: BoxDecoration(
//                 // color: Colors.orange[700],
//                 color: Colors.blue[700],
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(4.0)),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.directions_walk,
//                           color: Colors.white,
//                           size: 24.0,
//                         ),
//                         SizedBox(width: 10.0),
//                         Expanded(
//                           child: Text(
//                             'Pedestrian Crashes - $matchedAddress',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 18.0,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.close, color: Colors.white),
//                     onPressed: () => Navigator.of(context).pop(),
//                     tooltip: 'Close',
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: FlutterMap(
//                 options: MapOptions(
//                   initialCenter: LatLng(lat, lon),
//                   initialZoom: 15.0,
//                   minZoom: 10.0,
//                   maxZoom: 18.0,
//                 ),
//                 children: [
//                   TileLayer(
//                     urlTemplate:
//                         'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                     userAgentPackageName: 'com.example.app',
//                   ),

//                   // Show buffered area polygon
//                   if (bufferedPolygonPoints != null &&
//                       bufferedPolygonPoints.isNotEmpty)
//                     PolygonLayer(
//                       polygons: [
//                         Polygon(
//                           points: bufferedPolygonPoints,
//                           // color: Colors.orange.withOpacity(0.2),
//                           // borderColor: Colors.orange[700]!,
//                           color: Colors.blue.withOpacity(0.2),
//                           borderColor: Colors.blue[700]!,
//                           borderStrokeWidth: 2.0,
//                           isFilled: true,
//                         ),
//                       ],
//                     ),

//                   // Show original drawn polyline on top
//                   if (drawnLinePoints != null && drawnLinePoints.isNotEmpty)
//                     PolylineLayer(
//                       polylines: [
//                         Polyline(
//                           points: drawnLinePoints,
//                           // color: Colors.orange[900]!,
//                           color: Colors.blue[900]!,
//                           strokeWidth: 3.0,
//                         ),
//                       ],
//                     ),

//                   // Crash markers (with counts for same location)
//                   MarkerLayer(markers: crashMarkers),

//                   // Project address marker
//                   MarkerLayer(
//                     markers: [
//                       Marker(
//                         point: LatLng(lat, lon),
//                         width: 40,
//                         height: 40,
//                         child: Icon(
//                           Icons.location_on,
//                           color: Colors.green,
//                           size: 40,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               padding: EdgeInsets.all(12.0),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 border: Border(top: BorderSide(color: Colors.grey[300]!)),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       _buildStatItem(
//                         'Crashes',
//                         crashCount.toString(),
//                         Colors.red[700]!,
//                       ),
//                       _buildStatItem(
//                         'Area',
//                         '${areaSqMiles.toStringAsFixed(4)} sq mi',
//                         Colors.blue[700]!,
//                         //Colors.orange[700]!,
//                       ),
//                       _buildStatItem(
//                         'Density',
//                         '${density.toStringAsFixed(1)} per sq mi',
//                         //Colors.orange[900]!,
//                         Colors.orange[700]!,
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 8.0),
//                   Divider(height: 1),
//                   SizedBox(height: 8.0),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       _buildLegendItem(
//                         Icons.location_on,
//                         Colors.green,
//                         'Project Address',
//                       ),
//                       _buildLegendItem(
//                         Icons.warning,
//                         Colors.red[700]!,
//                         'Pedestrian crash',
//                       ),
//                       _buildLegendItem(
//                         Icons.circle_outlined,
//                         Colors.blue[700]!,
//                         //Colors.orange[700]!,
//                         '¼ mile buffer',
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Create crash markers with counts for crashes at the same location
//   List<Marker> _createCrashMarkers(List<Map<String, dynamic>> crashFeatures) {
//     // Group crashes by location (rounded to 6 decimal places ~ 0.1 meters)
//     final Map<String, List<Map<String, dynamic>>> crashesByLocation = {};

//     for (final feature in crashFeatures) {
//       final geometry = feature['geometry'] as Map<String, dynamic>?;
//       if (geometry == null) continue;

//       final coordinates = geometry['coordinates'] as List?;
//       if (coordinates == null || coordinates.length < 2) continue;

//       final crashLon = (coordinates[0] as num).toDouble();
//       final crashLat = (coordinates[1] as num).toDouble();

//       // Round to 6 decimal places to group nearby crashes
//       final locationKey =
//           '${crashLat.toStringAsFixed(6)},${crashLon.toStringAsFixed(6)}';

//       if (!crashesByLocation.containsKey(locationKey)) {
//         crashesByLocation[locationKey] = [];
//       }
//       crashesByLocation[locationKey]!.add(feature);
//     }

//     // Create markers with counts
//     final markers = <Marker>[];

//     for (final entry in crashesByLocation.entries) {
//       final crashes = entry.value;
//       final count = crashes.length;

//       // Get location from first crash
//       final firstCrash = crashes[0];
//       final geometry = firstCrash['geometry'] as Map<String, dynamic>;
//       final coordinates = geometry['coordinates'] as List;
//       final crashLon = (coordinates[0] as num).toDouble();
//       final crashLat = (coordinates[1] as num).toDouble();

//       // Build tooltip with all crash details
//       final tooltipParts = <String>[];

//       if (count > 1) {
//         tooltipParts.add('$count Crashes at this location:');
//         tooltipParts.add('');
//       }

//       for (int i = 0; i < crashes.length; i++) {
//         final properties =
//             crashes[i]['properties'] as Map<String, dynamic>? ?? {};
//         final crashInfo = <String>[];

//         if (count > 1) {
//           crashInfo.add('Crash ${i + 1}:');
//         }

//         for (final key in ['CrashDate', 'CrashTime', 'Street1', 'City']) {
//           if (properties.containsKey(key) && properties[key] != null) {
//             final value = properties[key].toString();
//             if (value.isNotEmpty) {
//               crashInfo.add('  $key: $value');
//             }
//           }
//         }

//         if (crashInfo.isEmpty && count == 1) {
//           crashInfo.add('Pedestrian Crash');
//         }

//         tooltipParts.addAll(crashInfo);

//         if (count > 1 && i < crashes.length - 1) {
//           tooltipParts.add('');
//         }
//       }

//       final tooltipText = tooltipParts.join('\n');

//       // Create marker with badge showing count
//       markers.add(
//         Marker(
//           point: LatLng(crashLat, crashLon),
//           width: 40,
//           height: 40,
//           child: Tooltip(
//             message: tooltipText,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 Icon(Icons.warning, color: Colors.red[700], size: 32),
//                 // Show count badge if multiple crashes at same location
//                 if (count > 1)
//                   Positioned(
//                     top: 0,
//                     right: 0,
//                     child: Container(
//                       padding: EdgeInsets.all(4),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                         border: Border.all(color: Colors.red[700]!, width: 2),
//                       ),
//                       child: Text(
//                         count.toString(),
//                         style: TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.red[900],
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     return markers;
//   }

//   /// SAME buffer algorithm as pedestrian_crash_drawing_service.dart
//   static List<List<double>> _createBufferedPolygon(
//     List<List<double>> polylinePoints,
//     double bufferMiles,
//   ) {
//     if (polylinePoints.isEmpty) return [];
//     if (polylinePoints.length == 1) {
//       return _createCirclePoints(polylinePoints[0], bufferMiles, 64);
//     }

//     final bufferDegrees = bufferMiles / 69.0;
//     final bufferedPoints = <List<double>>[];
//     const arcSteps = 16;

//     for (int i = 0; i < polylinePoints.length; i++) {
//       final current = polylinePoints[i];

//       if (i == 0) {
//         final next = polylinePoints[i + 1];
//         final dx = next[0] - current[0];
//         final dy = next[1] - current[1];
//         final length = math.sqrt(dx * dx + dy * dy);

//         if (length > 0) {
//           final lineAngle = math.atan2(dy, dx);
//           for (int j = 0; j <= arcSteps; j++) {
//             final t = j / arcSteps;
//             final angle = lineAngle + math.pi / 2 + t * math.pi;
//             bufferedPoints.add([
//               current[0] + bufferDegrees * math.cos(angle),
//               current[1] + bufferDegrees * math.sin(angle),
//             ]);
//           }
//         }
//       } else if (i == polylinePoints.length - 1) {
//         final prev = polylinePoints[i - 1];
//         final dx = current[0] - prev[0];
//         final dy = current[1] - prev[1];
//         final length = math.sqrt(dx * dx + dy * dy);

//         if (length > 0) {
//           final lineAngle = math.atan2(dy, dx);
//           final perpAngle = lineAngle - math.pi / 2;

//           bufferedPoints.add([
//             current[0] + bufferDegrees * math.cos(perpAngle),
//             current[1] + bufferDegrees * math.sin(perpAngle),
//           ]);

//           for (int j = 1; j <= arcSteps; j++) {
//             final t = j / arcSteps;
//             final angle = lineAngle - math.pi / 2 + t * math.pi;
//             bufferedPoints.add([
//               current[0] + bufferDegrees * math.cos(angle),
//               current[1] + bufferDegrees * math.sin(angle),
//             ]);
//           }
//         }
//       } else {
//         final prev = polylinePoints[i - 1];
//         final next = polylinePoints[i + 1];

//         final dx1 = current[0] - prev[0];
//         final dy1 = current[1] - prev[1];
//         final len1 = math.sqrt(dx1 * dx1 + dy1 * dy1);

//         final dx2 = next[0] - current[0];
//         final dy2 = next[1] - current[1];
//         final len2 = math.sqrt(dx2 * dx2 + dy2 * dy2);

//         if (len1 > 0 && len2 > 0) {
//           final angle1 = math.atan2(dy1, dx1);
//           final angle2 = math.atan2(dy2, dx2);
//           final perp1Angle = angle1 - math.pi / 2;
//           final perp2Angle = angle2 - math.pi / 2;

//           var deltaAngle = perp2Angle - perp1Angle;
//           while (deltaAngle > math.pi) deltaAngle -= 2 * math.pi;
//           while (deltaAngle < -math.pi) deltaAngle += 2 * math.pi;

//           if (deltaAngle.abs() > 0.01) {
//             final steps = (arcSteps * deltaAngle.abs() / math.pi).ceil().clamp(
//               4,
//               arcSteps,
//             );
//             for (int j = 0; j <= steps; j++) {
//               final t = j / steps;
//               final angle = perp1Angle + t * deltaAngle;
//               bufferedPoints.add([
//                 current[0] + bufferDegrees * math.cos(angle),
//                 current[1] + bufferDegrees * math.sin(angle),
//               ]);
//             }
//           } else {
//             bufferedPoints.add([
//               current[0] + bufferDegrees * math.cos(perp1Angle),
//               current[1] + bufferDegrees * math.sin(perp1Angle),
//             ]);
//           }
//         }
//       }
//     }

//     for (int i = polylinePoints.length - 1; i >= 0; i--) {
//       if (i == 0 || i == polylinePoints.length - 1) continue;

//       final current = polylinePoints[i];
//       final prev = polylinePoints[i - 1];
//       final next = polylinePoints[i + 1];

//       final dx1 = current[0] - prev[0];
//       final dy1 = current[1] - prev[1];
//       final len1 = math.sqrt(dx1 * dx1 + dy1 * dy1);

//       final dx2 = next[0] - current[0];
//       final dy2 = next[1] - current[1];
//       final len2 = math.sqrt(dx2 * dx2 + dy2 * dy2);

//       if (len1 > 0 && len2 > 0) {
//         final angle1 = math.atan2(dy1, dx1);
//         final angle2 = math.atan2(dy2, dx2);
//         final perp1Angle = angle1 + math.pi / 2;
//         final perp2Angle = angle2 + math.pi / 2;

//         var deltaAngle = perp1Angle - perp2Angle;
//         while (deltaAngle > math.pi) deltaAngle -= 2 * math.pi;
//         while (deltaAngle < -math.pi) deltaAngle += 2 * math.pi;

//         if (deltaAngle.abs() > 0.01) {
//           final steps = (arcSteps * deltaAngle.abs() / math.pi).ceil().clamp(
//             4,
//             arcSteps,
//           );
//           for (int j = 0; j <= steps; j++) {
//             final t = j / steps;
//             final angle = perp2Angle + t * deltaAngle;
//             bufferedPoints.add([
//               current[0] + bufferDegrees * math.cos(angle),
//               current[1] + bufferDegrees * math.sin(angle),
//             ]);
//           }
//         } else {
//           bufferedPoints.add([
//             current[0] + bufferDegrees * math.cos(perp1Angle),
//             current[1] + bufferDegrees * math.sin(perp1Angle),
//           ]);
//         }
//       }
//     }

//     if (bufferedPoints.isNotEmpty) {
//       bufferedPoints.add(bufferedPoints[0]);
//     }

//     return bufferedPoints;
//   }

//   static List<List<double>> _createCirclePoints(
//     List<double> center,
//     double radiusMiles,
//     int numPoints,
//   ) {
//     final radiusDegrees = radiusMiles / 69.0;
//     final points = <List<double>>[];

//     for (int i = 0; i <= numPoints; i++) {
//       final angle = (i * 2 * math.pi) / numPoints;
//       points.add([
//         center[0] + radiusDegrees * math.cos(angle),
//         center[1] + radiusDegrees * math.sin(angle),
//       ]);
//     }

//     return points;
//   }

//   Widget _buildStatItem(String label, String value, Color color) {
//     return Column(
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 11,
//             color: Colors.grey[600],
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         SizedBox(height: 4),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 16,
//             color: color,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildLegendItem(IconData icon, Color color, String label) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, color: color, size: 20),
//         SizedBox(width: 4),
//         Text(label, style: TextStyle(fontSize: 12)),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

/// Data model for bicycle crash map
class PedestrianCrashMapData {
  final double lon;
  final double lat;
  final String matchedAddress;
  final List<Map<String, dynamic>> crashFeatures;
  final int crashCount;
  final double density;
  final double areaSqMiles;
  final List<List<double>>? drawnPolyline;

  PedestrianCrashMapData({
    required this.lon,
    required this.lat,
    required this.matchedAddress,
    required this.crashFeatures,
    required this.crashCount,
    required this.density,
    required this.areaSqMiles,
    this.drawnPolyline,
  });
}

/// Widget that displays bicycle crashes on a map
class PedestrianCrashMapWidget extends StatelessWidget {
  final double lat;
  final double lon;
  final String matchedAddress;
  final List<Map<String, dynamic>> crashFeatures;
  final int crashCount;
  final double density;
  final double areaSqMiles;
  final List<List<double>>? drawnPolyline;

  const PedestrianCrashMapWidget({
    Key? key,
    required this.lat,
    required this.lon,
    required this.matchedAddress,
    required this.crashFeatures,
    required this.crashCount,
    required this.density,
    required this.areaSqMiles,
    this.drawnPolyline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Group crashes by location to count crashes at same point
    final crashMarkers = _createCrashMarkers(crashFeatures);

    // Process drawn polyline for display
    List<LatLng>? drawnLinePoints;
    List<LatLng>? bufferedPolygonPoints;

    if (drawnPolyline != null && drawnPolyline!.isNotEmpty) {
      // Points for the drawn polyline display (open)
      drawnLinePoints = drawnPolyline!
          .map((coords) => LatLng(coords[1], coords[0]))
          .toList();

      const bufferMiles = 0.25;
      final bufferedPolygon = _createBufferedPolygon(
        drawnPolyline!,
        bufferMiles,
      );
      bufferedPolygonPoints = bufferedPolygon
          .map((coords) => LatLng(coords[1], coords[0]))
          .toList();
    }

    return Dialog(
      insetPadding: EdgeInsets.all(20.0),
      child: Container(
        width: screenWidth * 0.9,
        height: screenHeight * 0.9,
        child: Column(
          children: [
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
                          Icons.directions_walk,
                          color: Colors.white,
                          size: 24.0,
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: Text(
                            'Pedestrian Crashes - $matchedAddress',
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
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(lat, lon),
                  initialZoom: 15.0,
                  minZoom: 10.0,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),

                  // Show full buffer area
                  if (bufferedPolygonPoints != null &&
                      bufferedPolygonPoints.isNotEmpty)
                    PolygonLayer(
                      polygons: [
                        Polygon(
                          points: List<LatLng>.from(bufferedPolygonPoints),
                          color: Colors.blue.withValues(alpha: 0.2),
                          borderColor: Colors.blue[700]!,
                          borderStrokeWidth: 2.0,
                          isFilled: true,
                        ),
                      ],
                    ),

                  // Show original drawn polyline on top
                  if (drawnLinePoints != null && drawnLinePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: drawnLinePoints,
                          color: Colors.blue[900]!,
                          strokeWidth: 3.0,
                        ),
                      ],
                    ),

                  // Crash markers (with counts for same location)
                  MarkerLayer(markers: crashMarkers),

                  // Project address marker
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(lat, lon),
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        'Crashes',
                        crashCount.toString(),
                        Colors.red[700]!,
                      ),
                      _buildStatItem(
                        'Area',
                        '${areaSqMiles.toStringAsFixed(4)} sq mi',
                        Colors.blue[700]!,
                      ),
                      _buildStatItem(
                        'Density',
                        '${density.toStringAsFixed(1)} per sq mi',
                        Colors.orange[700]!,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Divider(height: 1),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem(
                        Icons.location_on,
                        Colors.green,
                        'Project Address',
                      ),
                      _buildLegendItem(
                        Icons.warning,
                        Colors.red[700]!,
                        'Pedestrian crash',
                      ),
                      _buildLegendItem(
                        Icons.circle_outlined,
                        Colors.blue[700]!,
                        'Â¼ mile buffer',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Create crash markers with counts for crashes at the same location
  List<Marker> _createCrashMarkers(List<Map<String, dynamic>> crashFeatures) {
    // Group crashes by location (rounded to 6 decimal places ~ 0.1 meters)
    final Map<String, List<Map<String, dynamic>>> crashesByLocation = {};

    for (final feature in crashFeatures) {
      final geometry = feature['geometry'] as Map<String, dynamic>?;
      if (geometry == null) continue;

      final coordinates = geometry['coordinates'] as List?;
      if (coordinates == null || coordinates.length < 2) continue;

      final crashLon = (coordinates[0] as num).toDouble();
      final crashLat = (coordinates[1] as num).toDouble();

      // Round to 6 decimal places to group nearby crashes
      final locationKey =
          '${crashLat.toStringAsFixed(6)},${crashLon.toStringAsFixed(6)}';

      if (!crashesByLocation.containsKey(locationKey)) {
        crashesByLocation[locationKey] = [];
      }
      crashesByLocation[locationKey]!.add(feature);
    }

    // Create markers with counts
    final markers = <Marker>[];

    for (final entry in crashesByLocation.entries) {
      final crashes = entry.value;
      final count = crashes.length;

      // Get location from first crash
      final firstCrash = crashes[0];
      final geometry = firstCrash['geometry'] as Map<String, dynamic>;
      final coordinates = geometry['coordinates'] as List;
      final crashLon = (coordinates[0] as num).toDouble();
      final crashLat = (coordinates[1] as num).toDouble();

      // Build tooltip with all crash details
      final tooltipParts = <String>[];

      if (count > 1) {
        tooltipParts.add('$count Crashes at this location:');
        tooltipParts.add('');
      }

      for (int i = 0; i < crashes.length; i++) {
        final properties =
            crashes[i]['properties'] as Map<String, dynamic>? ?? {};
        final crashInfo = <String>[];

        if (count > 1) {
          crashInfo.add('Crash ${i + 1}:');
        }

        for (final key in ['CrashDate', 'CrashTime', 'Street1', 'City']) {
          if (properties.containsKey(key) && properties[key] != null) {
            final value = properties[key].toString();
            if (value.isNotEmpty) {
              crashInfo.add('  $key: $value');
            }
          }
        }

        if (crashInfo.isEmpty && count == 1) {
          crashInfo.add('Bicycle Crash');
        }

        tooltipParts.addAll(crashInfo);

        if (count > 1 && i < crashes.length - 1) {
          tooltipParts.add('');
        }
      }

      final tooltipText = tooltipParts.join('\n');

      // Create marker with badge showing count
      markers.add(
        Marker(
          point: LatLng(crashLat, crashLon),
          width: 40,
          height: 40,
          child: Tooltip(
            message: tooltipText,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.warning, color: Colors.red[700], size: 32),
                // Show count badge if multiple crashes at same location
                if (count > 1)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red[700]!, width: 2),
                      ),
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[900],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return markers;
  }

  static List<List<double>> _createBufferedPolygon(
    List<List<double>> polylinePoints,
    double bufferMiles,
  ) {
    if (polylinePoints.isEmpty) return [];
    if (polylinePoints.length == 1) {
      return _createCirclePoints(polylinePoints[0], bufferMiles, 64);
    }

    final pts = List<List<double>>.from(polylinePoints);
    final n = pts.length;
    final avgLat = pts.map((p) => p[1]).reduce((a, b) => a + b) / n;
    final lonToMiles = 69.0 * math.cos(avgLat * math.pi / 180.0);
    final latToMiles = 69.0;

    final closeDxMi = (pts.first[0] - pts.last[0]) * lonToMiles;
    final closeDyMi = (pts.first[1] - pts.last[1]) * latToMiles;
    final closeDistMi =
        math.sqrt(closeDxMi * closeDxMi + closeDyMi * closeDyMi);

    if (closeDistMi < 0.031 && n >= 3) {
      return _createClosedPolygonBuffer(pts, bufferMiles, avgLat);
    }
    return _createOpenPolylineBuffer(pts, bufferMiles, avgLat);
  }

  static List<List<double>> _createClosedPolygonBuffer(
    List<List<double>> pts,
    double bufferMiles,
    double avgLat,
  ) {
    var ring = List<List<double>>.from(pts);
    final dx = ring.first[0] - ring.last[0];
    final dy = ring.first[1] - ring.last[1];
    if (math.sqrt(dx * dx + dy * dy) > 1e-10) {
      ring = [...ring, ring.first];
    }
    final closedRing = ring.sublist(0, ring.length - 1);
    final nn = closedRing.length;

    final bufferLatDeg = bufferMiles / 69.0;
    final bufferLonDeg =
        bufferMiles / (69.0 * math.cos(avgLat * math.pi / 180.0));
    final lonToMiles = 69.0 * math.cos(avgLat * math.pi / 180.0);
    final latToMiles = 69.0;

    double signedArea = 0.0;
    for (int i = 0; i < nn; i++) {
      final j = (i + 1) % nn;
      signedArea += closedRing[i][0] * closedRing[j][1] -
          closedRing[j][0] * closedRing[i][1];
    }
    signedArea /= 2.0;
    final perpSign = signedArea > 0 ? -1.0 : 1.0;

    const arcSteps = 16;
    final bufferedPoints = <List<double>>[];

    for (int i = 0; i < nn; i++) {
      final current = closedRing[i];
      final prev = closedRing[(i - 1 + nn) % nn];
      final next = closedRing[(i + 1) % nn];

      final dx1 = (current[0] - prev[0]) * lonToMiles;
      final dy1 = (current[1] - prev[1]) * latToMiles;
      final dx2 = (next[0] - current[0]) * lonToMiles;
      final dy2 = (next[1] - current[1]) * latToMiles;

      final cross = dx1 * dy2 - dy1 * dx2;
      final isConvex = (cross * perpSign) < 0;

      final inAngle = math.atan2(dy1, dx1);
      final outAngle = math.atan2(dy2, dx2);
      final perpIn = inAngle + perpSign * math.pi / 2.0;
      final perpOut = outAngle + perpSign * math.pi / 2.0;

      var delta = perpOut - perpIn;
      while (delta > math.pi) delta -= 2 * math.pi;
      while (delta < -math.pi) delta += 2 * math.pi;

      if (isConvex && delta.abs() > 0.01) {
        final steps =
            (arcSteps * delta.abs() / math.pi).ceil().clamp(4, arcSteps);
        for (int j = 0; j <= steps; j++) {
          final t = j / steps;
          final angle = perpIn + t * delta;
          bufferedPoints.add([
            current[0] + bufferLonDeg * math.cos(angle),
            current[1] + bufferLatDeg * math.sin(angle),
          ]);
        }
      } else {
        final bisector = perpIn + delta / 2.0;
        final cosHalf = math.cos(delta / 2.0);
        final miter = cosHalf.abs() > 0.1
            ? (1.0 / cosHalf).clamp(-4.0, 4.0)
            : 1.0;
        bufferedPoints.add([
          current[0] + bufferLonDeg * math.cos(bisector) * miter,
          current[1] + bufferLatDeg * math.sin(bisector) * miter,
        ]);
      }
    }

    if (bufferedPoints.isNotEmpty) {
      bufferedPoints.add(bufferedPoints[0]);
    }
    return bufferedPoints;
  }

  static List<List<double>> _createOpenPolylineBuffer(
    List<List<double>> pts,
    double bufferMiles,
    double avgLat,
  ) {
    final n = pts.length;
    final bufferLatDeg = bufferMiles / 69.0;
    final bufferLonDeg =
        bufferMiles / (69.0 * math.cos(avgLat * math.pi / 180.0));
    final lonToMiles = 69.0 * math.cos(avgLat * math.pi / 180.0);
    final latToMiles = 69.0;
    const arcSteps = 16;

    final segAngles = <double>[];
    for (int i = 0; i < n - 1; i++) {
      final ddx = (pts[i + 1][0] - pts[i][0]) * lonToMiles;
      final ddy = (pts[i + 1][1] - pts[i][1]) * latToMiles;
      segAngles.add(math.atan2(ddy, ddx));
    }

    final rightSide = <List<double>>[];
    final leftSide = <List<double>>[];

    for (int i = 0; i < n; i++) {
      if (i == 0) {
        final pa = segAngles[0] - math.pi / 2;
        rightSide.add([
          pts[0][0] + bufferLonDeg * math.cos(pa),
          pts[0][1] + bufferLatDeg * math.sin(pa),
        ]);
      } else if (i == n - 1) {
        final pa = segAngles[n - 2] - math.pi / 2;
        rightSide.add([
          pts[n - 1][0] + bufferLonDeg * math.cos(pa),
          pts[n - 1][1] + bufferLatDeg * math.sin(pa),
        ]);
      } else {
        final perpIn = segAngles[i - 1] - math.pi / 2;
        final perpOut = segAngles[i] - math.pi / 2;
        final dxIn = (pts[i][0] - pts[i - 1][0]) * lonToMiles;
        final dyIn = (pts[i][1] - pts[i - 1][1]) * latToMiles;
        final dxOut = (pts[i + 1][0] - pts[i][0]) * lonToMiles;
        final dyOut = (pts[i + 1][1] - pts[i][1]) * latToMiles;
        final cross = dxIn * dyOut - dyIn * dxOut;
        var delta = perpOut - perpIn;
        while (delta > math.pi) delta -= 2 * math.pi;
        while (delta < -math.pi) delta += 2 * math.pi;

        if (cross > 1e-10 && delta.abs() > 0.01) {
          final steps =
              (arcSteps * delta.abs() / math.pi).ceil().clamp(4, arcSteps);
          for (int j = 0; j <= steps; j++) {
            final t = j / steps;
            final angle = perpIn + t * delta;
            rightSide.add([
              pts[i][0] + bufferLonDeg * math.cos(angle),
              pts[i][1] + bufferLatDeg * math.sin(angle),
            ]);
          }
        } else {
          final bisector = perpIn + delta / 2.0;
          final cosHalf = math.cos(delta / 2.0);
          final miter = cosHalf.abs() > 0.1
              ? (1.0 / cosHalf).clamp(-4.0, 4.0)
              : 1.0;
          rightSide.add([
            pts[i][0] + bufferLonDeg * math.cos(bisector) * miter,
            pts[i][1] + bufferLatDeg * math.sin(bisector) * miter,
          ]);
        }
      }
    }

    for (int i = 0; i < n; i++) {
      if (i == 0) {
        final pa = segAngles[0] + math.pi / 2;
        leftSide.add([
          pts[0][0] + bufferLonDeg * math.cos(pa),
          pts[0][1] + bufferLatDeg * math.sin(pa),
        ]);
      } else if (i == n - 1) {
        final pa = segAngles[n - 2] + math.pi / 2;
        leftSide.add([
          pts[n - 1][0] + bufferLonDeg * math.cos(pa),
          pts[n - 1][1] + bufferLatDeg * math.sin(pa),
        ]);
      } else {
        final perpIn = segAngles[i - 1] + math.pi / 2;
        final perpOut = segAngles[i] + math.pi / 2;
        final dxIn = (pts[i][0] - pts[i - 1][0]) * lonToMiles;
        final dyIn = (pts[i][1] - pts[i - 1][1]) * latToMiles;
        final dxOut = (pts[i + 1][0] - pts[i][0]) * lonToMiles;
        final dyOut = (pts[i + 1][1] - pts[i][1]) * latToMiles;
        final cross = dxIn * dyOut - dyIn * dxOut;
        var delta = perpOut - perpIn;
        while (delta > math.pi) delta -= 2 * math.pi;
        while (delta < -math.pi) delta += 2 * math.pi;

        if (cross < -1e-10 && delta.abs() > 0.01) {
          final steps =
              (arcSteps * delta.abs() / math.pi).ceil().clamp(4, arcSteps);
          for (int j = 0; j <= steps; j++) {
            final t = j / steps;
            final angle = perpIn + t * delta;
            leftSide.add([
              pts[i][0] + bufferLonDeg * math.cos(angle),
              pts[i][1] + bufferLatDeg * math.sin(angle),
            ]);
          }
        } else {
          final bisector = perpIn + delta / 2.0;
          final cosHalf = math.cos(delta / 2.0);
          final miter = cosHalf.abs() > 0.1
              ? (1.0 / cosHalf).clamp(-4.0, 4.0)
              : 1.0;
          leftSide.add([
            pts[i][0] + bufferLonDeg * math.cos(bisector) * miter,
            pts[i][1] + bufferLatDeg * math.sin(bisector) * miter,
          ]);
        }
      }
    }

    final result = <List<double>>[];

    final startAngle = segAngles[0] + math.pi / 2;
    for (int j = 0; j <= arcSteps; j++) {
      final t = j / arcSteps;
      final angle = startAngle + t * math.pi;
      result.add([
        pts[0][0] + bufferLonDeg * math.cos(angle),
        pts[0][1] + bufferLatDeg * math.sin(angle),
      ]);
    }

    result.addAll(rightSide);

    final endAngle = segAngles[n - 2] - math.pi / 2;
    for (int j = 0; j <= arcSteps; j++) {
      final t = j / arcSteps;
      final angle = endAngle + t * math.pi;
      result.add([
        pts[n - 1][0] + bufferLonDeg * math.cos(angle),
        pts[n - 1][1] + bufferLatDeg * math.sin(angle),
      ]);
    }

    result.addAll(leftSide.reversed);

    if (result.isNotEmpty) {
      result.add(result[0]);
    }
    return result;
  }

  static List<List<double>> _createCirclePoints(
    List<double> center,
    double radiusMiles,
    int numPoints,
  ) {
    final radiusLatDeg = radiusMiles / 69.0;
    final radiusLonDeg =
        radiusMiles / (69.0 * math.cos(center[1] * math.pi / 180.0));
    final points = <List<double>>[];
    for (int i = 0; i <= numPoints; i++) {
      final angle = (i * 2 * math.pi) / numPoints;
      points.add([
        center[0] + radiusLonDeg * math.cos(angle),
        center[1] + radiusLatDeg * math.sin(angle),
      ]);
    }
    return points;
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
