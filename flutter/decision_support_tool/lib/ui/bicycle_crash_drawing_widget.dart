// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:decision_support_tool/services/bicycle_crash_drawing_service.dart';

// /// Interactive widget for drawing polyline and calculating crash density
// class BicycleCrashDrawingWidget extends StatefulWidget {
//   final double lat;
//   final double lon;
//   final String matchedAddress;
//   final Function(BicycleCrashDrawingResult) onCalculationComplete;

//   const BicycleCrashDrawingWidget({
//     Key? key,
//     required this.lat,
//     required this.lon,
//     required this.matchedAddress,
//     required this.onCalculationComplete,
//   }) : super(key: key);

//   @override
//   State<BicycleCrashDrawingWidget> createState() =>
//       _BicycleCrashDrawingWidgetState();
// }

// class _BicycleCrashDrawingWidgetState extends State<BicycleCrashDrawingWidget> {
//   final List<LatLng> _drawnPoints = [];
//   bool _isDrawing = false;
//   bool _isCalculating = false;
//   String? _errorMessage;

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Dialog(
//       insetPadding: EdgeInsets.all(20.0),
//       child: Container(
//         width: screenWidth * 0.9,
//         height: screenHeight * 0.9,
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//               decoration: BoxDecoration(
//                 color: Colors.blue[700],
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(4.0)),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Icon(Icons.draw, color: Colors.white, size: 24.0),
//                         SizedBox(width: 10.0),
//                         Expanded(
//                           child: Text(
//                             'Draw Project Area - ${widget.matchedAddress}',
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

//             // Instructions
//             Container(
//               padding: EdgeInsets.all(12.0),
//               decoration: BoxDecoration(
//                 color: Colors.amber[50],
//                 border: Border(bottom: BorderSide(color: Colors.amber[300]!)),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.info_outline, color: Colors.amber[900], size: 20),
//                   SizedBox(width: 8.0),
//                   Expanded(
//                     child: Text(
//                       _isDrawing
//                           ? 'Click on the map to draw points. Double-click or press "Finish Drawing" when done.'
//                           : 'Press "Start Drawing" to draw the project area perimeter on the map.',
//                       style: TextStyle(
//                         fontSize: 13.0,
//                         color: Colors.amber[900],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Map
//             Expanded(
//               child: Stack(
//                 children: [
//                   FlutterMap(
//                     options: MapOptions(
//                       initialCenter: LatLng(widget.lat, widget.lon),
//                       initialZoom: 15.0,
//                       minZoom: 10.0,
//                       maxZoom: 18.0,
//                       onTap: _isDrawing ? _onMapTap : null,
//                     ),
//                     children: [
//                       // OpenStreetMap tiles
//                       TileLayer(
//                         urlTemplate:
//                             'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                         userAgentPackageName: 'com.example.app',
//                       ),

//                       // Drawn polyline
//                       if (_drawnPoints.isNotEmpty)
//                         PolylineLayer(
//                           polylines: [
//                             Polyline(
//                               points: _drawnPoints,
//                               color: Colors.red,
//                               strokeWidth: 3.0,
//                             ),
//                           ],
//                         ),

//                       // Drawn points markers
//                       if (_drawnPoints.isNotEmpty)
//                         MarkerLayer(
//                           markers: _drawnPoints.asMap().entries.map((entry) {
//                             final idx = entry.key;
//                             final point = entry.value;
//                             return Marker(
//                               point: point,
//                               width: 24,
//                               height: 24,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.red,
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     color: Colors.white,
//                                     width: 2,
//                                   ),
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     '${idx + 1}',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                         ),

//                       // Project address marker
//                       MarkerLayer(
//                         markers: [
//                           Marker(
//                             point: LatLng(widget.lat, widget.lon),
//                             width: 40,
//                             height: 40,
//                             child: Icon(
//                               Icons.location_on,
//                               color: Colors.green,
//                               size: 40,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),

//                   // Loading overlay
//                   if (_isCalculating)
//                     Container(
//                       color: Colors.black54,
//                       child: Center(
//                         child: Card(
//                           child: Padding(
//                             padding: EdgeInsets.all(20.0),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 CircularProgressIndicator(),
//                                 SizedBox(height: 16.0),
//                                 Text('Calculating crash density...'),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),

//             // Error message
//             if (_errorMessage != null)
//               Container(
//                 padding: EdgeInsets.all(12.0),
//                 decoration: BoxDecoration(
//                   color: Colors.red[50],
//                   border: Border(top: BorderSide(color: Colors.red[300]!)),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.error_outline, color: Colors.red[900], size: 20),
//                     SizedBox(width: 8.0),
//                     Expanded(
//                       child: Text(
//                         _errorMessage!,
//                         style: TextStyle(
//                           fontSize: 13.0,
//                           color: Colors.red[900],
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.close, size: 20),
//                       onPressed: () => setState(() => _errorMessage = null),
//                     ),
//                   ],
//                 ),
//               ),

//             // Controls
//             Container(
//               padding: EdgeInsets.all(12.0),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 border: Border(top: BorderSide(color: Colors.grey[300]!)),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Stats
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       _buildStatItem(
//                         'Points Drawn',
//                         _drawnPoints.length.toString(),
//                         Colors.blue[700]!,
//                       ),
//                       _buildStatItem(
//                         'Status',
//                         _isDrawing
//                             ? 'Drawing...'
//                             : _drawnPoints.isEmpty
//                             ? 'Not Started'
//                             : 'Ready',
//                         _isDrawing
//                             ? Colors.orange[700]!
//                             : _drawnPoints.isEmpty
//                             ? Colors.grey[700]!
//                             : Colors.green[700]!,
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 12.0),
//                   Divider(height: 1),
//                   SizedBox(height: 12.0),

//                   // Action buttons
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       if (!_isDrawing && _drawnPoints.isEmpty)
//                         ElevatedButton.icon(
//                           icon: Icon(Icons.draw, size: 18),
//                           label: Text('Start Drawing'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue[700],
//                             foregroundColor: Colors.white,
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 24.0,
//                               vertical: 12.0,
//                             ),
//                           ),
//                           onPressed: _startDrawing,
//                         ),

//                       if (_isDrawing) ...[
//                         ElevatedButton.icon(
//                           icon: Icon(Icons.check, size: 18),
//                           label: Text('Finish Drawing'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green[700],
//                             foregroundColor: Colors.white,
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 20.0,
//                               vertical: 12.0,
//                             ),
//                           ),
//                           onPressed: _drawnPoints.length >= 3
//                               ? _finishDrawing
//                               : null,
//                         ),
//                         ElevatedButton.icon(
//                           icon: Icon(Icons.undo, size: 18),
//                           label: Text('Undo Last'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.orange[700],
//                             foregroundColor: Colors.white,
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 20.0,
//                               vertical: 12.0,
//                             ),
//                           ),
//                           onPressed: _drawnPoints.isNotEmpty
//                               ? _undoLastPoint
//                               : null,
//                         ),
//                       ],

//                       if (!_isDrawing && _drawnPoints.isNotEmpty) ...[
//                         ElevatedButton.icon(
//                           icon: Icon(Icons.calculate, size: 18),
//                           label: Text('Calculate Density'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green[700],
//                             foregroundColor: Colors.white,
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 20.0,
//                               vertical: 12.0,
//                             ),
//                           ),
//                           onPressed: _calculateDensity,
//                         ),
//                         ElevatedButton.icon(
//                           icon: Icon(Icons.refresh, size: 18),
//                           label: Text('Clear & Restart'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.red[700],
//                             foregroundColor: Colors.white,
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 20.0,
//                               vertical: 12.0,
//                             ),
//                           ),
//                           onPressed: _clearDrawing,
//                         ),
//                       ],
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

//   void _startDrawing() {
//     setState(() {
//       _isDrawing = true;
//       _drawnPoints.clear();
//       _errorMessage = null;
//     });
//   }

//   void _onMapTap(TapPosition tapPosition, LatLng latLng) {
//     if (_isDrawing) {
//       setState(() {
//         _drawnPoints.add(latLng);
//       });
//     }
//   }

//   void _undoLastPoint() {
//     if (_drawnPoints.isNotEmpty) {
//       setState(() {
//         _drawnPoints.removeLast();
//       });
//     }
//   }

//   void _finishDrawing() {
//     if (_drawnPoints.length < 3) {
//       setState(() {
//         _errorMessage = 'Please draw at least 3 points to form an area.';
//       });
//       return;
//     }

//     setState(() {
//       _isDrawing = false;
//       _errorMessage = null;
//     });
//   }

//   void _clearDrawing() {
//     setState(() {
//       _drawnPoints.clear();
//       _isDrawing = false;
//       _errorMessage = null;
//     });
//   }

//   Future<void> _calculateDensity() async {
//     if (_drawnPoints.length < 3) {
//       setState(() {
//         _errorMessage = 'Please draw at least 3 points to form an area.';
//       });
//       return;
//     }

//     setState(() {
//       _isCalculating = true;
//       _errorMessage = null;
//     });

//     try {
//       // Convert LatLng to [lon, lat] format
//       final polylinePoints = _drawnPoints
//           .map((p) => [p.longitude, p.latitude])
//           .toList();

//       // Calculate crashes within drawn area
//       final result = await BicycleCrashDrawingService.calculateFromPolyline(
//         address: widget.matchedAddress,
//         polylinePoints: polylinePoints,
//       );

//       // Close this dialog
//       if (mounted) {
//         Navigator.of(context).pop();

//         // Call callback with result
//         widget.onCalculationComplete(result);
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error calculating density: $e';
//         _isCalculating = false;
//       });
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:decision_support_tool/services/bicycle_crash_drawing_service.dart';

/// Interactive widget for drawing polyline and calculating crash density
class BicycleCrashDrawingWidget extends StatefulWidget {
  final double lat;
  final double lon;
  final String matchedAddress;
  final Function(BicycleCrashDrawingResult) onCalculationComplete;

  /// Optional: pre-populate with a previously drawn polygon.
  final List<LatLng>? initialPoints;

  /// Optional callback invoked with the final polygon before the widget closes.
  final Function(List<LatLng>)? onPolygonSaved;
  const BicycleCrashDrawingWidget({
    Key? key,
    required this.lat,
    required this.lon,
    required this.matchedAddress,
    required this.onCalculationComplete,
    this.initialPoints,
    this.onPolygonSaved,
  }) : super(key: key);
  @override
  State<BicycleCrashDrawingWidget> createState() =>
      _BicycleCrashDrawingWidgetState();
}

class _BicycleCrashDrawingWidgetState extends State<BicycleCrashDrawingWidget> {
  late final List<LatLng> _drawnPoints;
  bool _isDrawing = false;
  bool _isCalculating = false;
  String? _errorMessage;
  @override
  void initState() {
    super.initState();
    _drawnPoints = widget.initialPoints != null
        ? List<LatLng>.from(widget.initialPoints!)
        : [];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
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
                        Icon(Icons.draw, color: Colors.white, size: 24.0),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: Text(
                            'Draw Project Area - ${widget.matchedAddress}',
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
            // Instructions
            Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                border: Border(bottom: BorderSide(color: Colors.amber[300]!)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[900], size: 20),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      _isDrawing
                          ? 'Click on the map to draw points. Double-click or press "Finish Drawing" when done.'
                          : 'Press "Start Drawing" to draw the project area perimeter on the map.',
                      style: TextStyle(
                        fontSize: 13.0,
                        color: Colors.amber[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Map
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(widget.lat, widget.lon),
                      initialZoom: 15.0,
                      minZoom: 10.0,
                      maxZoom: 18.0,
                      onTap: _isDrawing ? _onMapTap : null,
                    ),
                    children: [
                      // OpenStreetMap tiles
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      // Drawn polyline
                      if (_drawnPoints.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _drawnPoints,
                              color: Colors.red,
                              strokeWidth: 3.0,
                            ),
                          ],
                        ),
                      // Drawn points markers
                      if (_drawnPoints.isNotEmpty)
                        MarkerLayer(
                          markers: _drawnPoints.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final point = entry.value;
                            return Marker(
                              point: point,
                              width: 24,
                              height: 24,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${idx + 1}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      // Project address marker
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(widget.lat, widget.lon),
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
                  // Loading overlay
                  if (_isCalculating)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16.0),
                                Text('Calculating crash density...'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Error message
            if (_errorMessage != null)
              Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border(top: BorderSide(color: Colors.red[300]!)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[900], size: 20),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontSize: 13.0,
                          color: Colors.red[900],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 20),
                      onPressed: () => setState(() => _errorMessage = null),
                    ),
                  ],
                ),
              ),
            // Controls
            Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        'Points Drawn',
                        _drawnPoints.length.toString(),
                        Colors.blue[700]!,
                      ),
                      _buildStatItem(
                        'Status',
                        _isDrawing
                            ? 'Drawing...'
                            : _drawnPoints.isEmpty
                            ? 'Not Started'
                            : 'Ready',
                        _isDrawing
                            ? Colors.orange[700]!
                            : _drawnPoints.isEmpty
                            ? Colors.grey[700]!
                            : Colors.green[700]!,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.0),
                  Divider(height: 1),
                  SizedBox(height: 12.0),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (!_isDrawing && _drawnPoints.isEmpty)
                        ElevatedButton.icon(
                          icon: Icon(Icons.draw, size: 18),
                          label: Text('Start Drawing'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 12.0,
                            ),
                          ),
                          onPressed: _startDrawing,
                        ),
                      if (_isDrawing) ...[
                        ElevatedButton.icon(
                          icon: Icon(Icons.check, size: 18),
                          label: Text('Finish Drawing'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 12.0,
                            ),
                          ),
                          onPressed: _drawnPoints.length >= 3
                              ? _finishDrawing
                              : null,
                        ),
                        ElevatedButton.icon(
                          icon: Icon(Icons.undo, size: 18),
                          label: Text('Undo Last'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[700],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 12.0,
                            ),
                          ),
                          onPressed: _drawnPoints.isNotEmpty
                              ? _undoLastPoint
                              : null,
                        ),
                      ],
                      if (!_isDrawing && _drawnPoints.isNotEmpty) ...[
                        ElevatedButton.icon(
                          icon: Icon(Icons.calculate, size: 18),
                          label: Text('Calculate Density'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 12.0,
                            ),
                          ),
                          onPressed: _calculateDensity,
                        ),
                        ElevatedButton.icon(
                          icon: Icon(Icons.refresh, size: 18),
                          label: Text('Clear & Restart'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 12.0,
                            ),
                          ),
                          onPressed: _clearDrawing,
                        ),
                      ],
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

  void _startDrawing() {
    setState(() {
      _isDrawing = true;
      _drawnPoints.clear();
      _errorMessage = null;
    });
  }

  void _onMapTap(TapPosition tapPosition, LatLng latLng) {
    if (_isDrawing) {
      setState(() {
        _drawnPoints.add(latLng);
      });
    }
  }

  void _undoLastPoint() {
    if (_drawnPoints.isNotEmpty) {
      setState(() {
        _drawnPoints.removeLast();
      });
    }
  }

  void _finishDrawing() {
    if (_drawnPoints.length < 3) {
      setState(() {
        _errorMessage = 'Please draw at least 3 points to form an area.';
      });
      return;
    }
    setState(() {
      _isDrawing = false;
      _errorMessage = null;
    });
  }

  void _clearDrawing() {
    setState(() {
      _drawnPoints.clear();
      _isDrawing = false;
      _errorMessage = null;
    });
  }

  Future<void> _calculateDensity() async {
    if (_drawnPoints.length < 3) {
      setState(() {
        _errorMessage = 'Please draw at least 3 points to form an area.';
      });
      return;
    }
    setState(() {
      _isCalculating = true;
      _errorMessage = null;
    });
    try {
      // Convert LatLng to [lon, lat] format
      final polylinePoints = _drawnPoints
          .map((p) => [p.longitude, p.latitude])
          .toList();
      // Calculate crashes within drawn area
      final result = await BicycleCrashDrawingService.calculateFromPolyline(
        address: widget.matchedAddress,
        polylinePoints: polylinePoints,
      );
      // Close this dialog
      if (mounted) {
        widget.onPolygonSaved?.call(List<LatLng>.from(_drawnPoints));
        Navigator.of(context).pop();
        widget.onCalculationComplete(result);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error calculating density: $e';
        _isCalculating = false;
      });
    }
  }
}
