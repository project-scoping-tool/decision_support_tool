// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:decision_support_tool/services/walking_rate_drawing_service.dart';

// /// Interactive widget for drawing a polygon and calculating the walking-to-work
// /// rate from Census Tracts. Mirrors the pattern of BikingRateDrawingWidget.
// class WalkingRateDrawingWidget extends StatefulWidget {
//   final double lat;
//   final double lon;
//   final String matchedAddress;
//   final Function(WalkingRateDrawingResult) onCalculationComplete;

//   const WalkingRateDrawingWidget({
//     Key? key,
//     required this.lat,
//     required this.lon,
//     required this.matchedAddress,
//     required this.onCalculationComplete,
//   }) : super(key: key);

//   @override
//   State<WalkingRateDrawingWidget> createState() =>
//       _WalkingRateDrawingWidgetState();
// }

// class _WalkingRateDrawingWidgetState extends State<WalkingRateDrawingWidget> {
//   final List<LatLng> _drawnPoints = [];
//   bool _isDrawing = false;
//   bool _isCalculating = false;
//   String? _errorMessage;

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Dialog(
//       insetPadding: const EdgeInsets.all(20.0),
//       child: SizedBox(
//         width: screenWidth * 0.9,
//         height: screenHeight * 0.9,
//         child: Column(
//           children: [
//             // ── Header ──────────────────────────────────────────────────────
//             Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 16.0,
//                 vertical: 12.0,
//               ),
//               decoration: BoxDecoration(
//                 // color: Colors.green[700],
//                 color: Colors.blue[700],
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(4.0),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Row(
//                       children: [
//                         const Icon(Icons.draw, color: Colors.white, size: 24.0),
//                         const SizedBox(width: 10.0),
//                         Expanded(
//                           child: Text(
//                             'Draw Project Area – ${widget.matchedAddress}',
//                             style: const TextStyle(
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
//                     icon: const Icon(Icons.close, color: Colors.white),
//                     onPressed: () => Navigator.of(context).pop(),
//                     tooltip: 'Close',
//                   ),
//                 ],
//               ),
//             ),

//             // ── Instruction banner ───────────────────────────────────────────
//             Container(
//               padding: const EdgeInsets.all(12.0),
//               decoration: BoxDecoration(
//                 color: Colors.amber[50],
//                 border: Border(bottom: BorderSide(color: Colors.amber[300]!)),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.info_outline, color: Colors.amber[900], size: 20),
//                   const SizedBox(width: 8.0),
//                   Expanded(
//                     child: Text(
//                       _isDrawing
//                           ? 'Click on the map to add polygon vertices. '
//                                 'Press "Finish Drawing" when the area is enclosed '
//                                 '(minimum 3 points).'
//                           : 'Press "Start Drawing" to outline the project area. '
//                                 'The tool will find intersecting Census Tracts and '
//                                 'calculate the walk-to-work rate automatically.',
//                       style: TextStyle(
//                         fontSize: 13.0,
//                         color: Colors.amber[900],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ── Map ─────────────────────────────────────────────────────────
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
//                       TileLayer(
//                         urlTemplate:
//                             'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                         userAgentPackageName: 'com.example.app',
//                       ),

//                       // Drawn polygon fill + outline
//                       if (_drawnPoints.length >= 3)
//                         PolygonLayer(
//                           polygons: [
//                             Polygon(
//                               points: _drawnPoints,
//                               // color: Colors.green.withOpacity(0.15),
//                               color: Colors.red.withOpacity(0.15),
//                               // borderColor: Colors.green[700]!,
//                               borderColor: Colors.red[700]!,
//                               borderStrokeWidth: 2.5,
//                               isFilled: true,
//                             ),
//                           ],
//                         ),

//                       // Polyline connecting vertices
//                       if (_drawnPoints.isNotEmpty)
//                         PolylineLayer(
//                           polylines: [
//                             Polyline(
//                               points: _drawnPoints,
//                               // color: Colors.green[900]!,
//                               color: Colors.red[900]!,
//                               strokeWidth: 3.0,
//                             ),
//                           ],
//                         ),

//                       // Vertex markers with index numbers
//                       if (_drawnPoints.isNotEmpty)
//                         MarkerLayer(
//                           markers: _drawnPoints.asMap().entries.map((entry) {
//                             return Marker(
//                               point: entry.value,
//                               width: 24,
//                               height: 24,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   // color: Colors.green[700],
//                                   color: Colors.red[700],
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     color: Colors.white,
//                                     width: 2,
//                                   ),
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     '${entry.key + 1}',
//                                     style: const TextStyle(
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
//                             child: const Icon(
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
//                       color: Colors.black.withOpacity(0.5),
//                       child: const Center(
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             CircularProgressIndicator(color: Colors.white),
//                             SizedBox(height: 16),
//                             Text(
//                               'Calculating walk-to-work rate…',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),

//             // ── Bottom control panel ─────────────────────────────────────────
//             Container(
//               padding: const EdgeInsets.all(12.0),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 border: Border(top: BorderSide(color: Colors.grey[300]!)),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Stats row
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       _buildStatItem(
//                         'Points placed',
//                         '${_drawnPoints.length}',
//                         Colors.grey[700]!,
//                       ),
//                       _buildStatItem(
//                         'Status',
//                         _isDrawing
//                             ? 'Drawing…'
//                             : _drawnPoints.isEmpty
//                             ? 'Ready'
//                             : 'Area drawn',
//                         _isDrawing
//                             ? Colors.orange[700]!
//                             : _drawnPoints.isEmpty
//                             ? Colors.grey[700]!
//                             : Colors.green[700]!,
//                       ),
//                     ],
//                   ),

//                   // Error message
//                   if (_errorMessage != null)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 8.0),
//                       child: Text(
//                         _errorMessage!,
//                         style: const TextStyle(color: Colors.red, fontSize: 13),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),

//                   const SizedBox(height: 12.0),
//                   const Divider(height: 1),
//                   const SizedBox(height: 12.0),

//                   // Action buttons – same state machine as biking rate widget
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       if (!_isDrawing && _drawnPoints.isEmpty)
//                         ElevatedButton.icon(
//                           icon: const Icon(Icons.draw, size: 18),
//                           label: const Text('Start Drawing'),
//                           style: ElevatedButton.styleFrom(
//                             // backgroundColor: Colors.green[700],
//                             backgroundColor: Colors.blue[700],
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 24.0,
//                               vertical: 12.0,
//                             ),
//                           ),
//                           onPressed: _startDrawing,
//                         ),

//                       if (_isDrawing) ...[
//                         ElevatedButton.icon(
//                           icon: const Icon(Icons.check, size: 18),
//                           label: const Text('Finish Drawing'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green[700],
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 20.0,
//                               vertical: 12.0,
//                             ),
//                           ),
//                           onPressed: _drawnPoints.length >= 3
//                               ? _finishDrawing
//                               : null,
//                         ),
//                         ElevatedButton.icon(
//                           icon: const Icon(Icons.undo, size: 18),
//                           label: const Text('Undo Last'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.orange[700],
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
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
//                           icon: const Icon(Icons.directions_walk, size: 18),
//                           label: const Text('Calculate Walking Rate'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green[700],
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 20.0,
//                               vertical: 12.0,
//                             ),
//                           ),
//                           onPressed: _calculateWalkingRate,
//                         ),
//                         ElevatedButton.icon(
//                           icon: const Icon(Icons.refresh, size: 18),
//                           label: const Text('Clear & Restart'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.red[700],
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
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

//   // ── Helpers ───────────────────────────────────────────────────────────────

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
//         const SizedBox(height: 4),
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

//   // ── State actions ─────────────────────────────────────────────────────────

//   void _startDrawing() {
//     setState(() {
//       _isDrawing = true;
//       _drawnPoints.clear();
//       _errorMessage = null;
//     });
//   }

//   void _onMapTap(TapPosition tapPosition, LatLng latLng) {
//     if (_isDrawing) {
//       setState(() => _drawnPoints.add(latLng));
//     }
//   }

//   void _undoLastPoint() {
//     if (_drawnPoints.isNotEmpty) {
//       setState(() => _drawnPoints.removeLast());
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

//   Future<void> _calculateWalkingRate() async {
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
//       // Convert LatLng list to [lon, lat] pairs; close the polygon
//       final polygonPoints = _drawnPoints
//           .map((p) => [p.longitude, p.latitude])
//           .toList();
//       polygonPoints.add(polygonPoints.first); // close ring

//       final result = await WalkingRateDrawingService.calculateFromPolygon(
//         address: widget.matchedAddress,
//         polygonPoints: polygonPoints,
//       );

//       if (mounted) {
//         Navigator.of(context).pop();
//         widget.onCalculationComplete(result);
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error calculating walking rate: $e';
//         _isCalculating = false;
//       });
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:decision_support_tool/services/walking_rate_drawing_service.dart';
import 'dart:math' as math;

/// Interactive widget for drawing a polygon and calculating the walking-to-work
/// rate from Census Tracts. Mirrors the pattern of BikingRateDrawingWidget.
class WalkingRateDrawingWidget extends StatefulWidget {
  final double lat;
  final double lon;
  final String matchedAddress;
  final Function(WalkingRateDrawingResult) onCalculationComplete;

  /// Optional: pre-populate with a previously drawn polygon.
  final List<LatLng>? initialPoints;

  /// Optional callback invoked with the final polygon before the widget closes.
  final Function(List<LatLng>)? onPolygonSaved;

  const WalkingRateDrawingWidget({
    Key? key,
    required this.lat,
    required this.lon,
    required this.matchedAddress,
    required this.onCalculationComplete,
    this.initialPoints,
    this.onPolygonSaved,
  }) : super(key: key);
  @override
  State<WalkingRateDrawingWidget> createState() =>
      _WalkingRateDrawingWidgetState();
}

class _WalkingRateDrawingWidgetState extends State<WalkingRateDrawingWidget> {
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
      insetPadding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: screenWidth * 0.9,
        height: screenHeight * 0.9,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.draw, color: Colors.white, size: 24.0),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Text(
                            'Draw Project Area – ${widget.matchedAddress}',
                            style: const TextStyle(
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
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            // ── Instruction banner ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                border: Border(bottom: BorderSide(color: Colors.amber[300]!)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[900], size: 20),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      _isDrawing
                          ? 'Click on the map to add polygon vertices. '
                                'Press "Finish Drawing" when the area is enclosed '
                                '(minimum 3 points).'
                          : _drawnPoints.isNotEmpty
                          ? 'Project area loaded from a previous question. '
                                'Press "Calculate Walking Rate" to reuse it, or '
                                '"Clear & Restart" to draw a new area.'
                          : 'Press "Start Drawing" to outline the project area. '
                                'The tool will find intersecting Census Tracts and '
                                'calculate the walk-to-work rate automatically.',
                      style: TextStyle(
                        fontSize: 13.0,
                        color: Colors.amber[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Map ─────────────────────────────────────────────────────────
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
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      if (_drawnPoints.length >= 3)
                        PolygonLayer(
                          polygons: [
                            Polygon(
                              points: _drawnPoints,
                              color: Colors.red.withOpacity(0.15),
                              borderColor: Colors.red[700]!,
                              borderStrokeWidth: 2.5,
                              isFilled: true,
                            ),
                          ],
                        ),
                      if (_drawnPoints.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _drawnPoints,
                              color: Colors.red[900]!,
                              strokeWidth: 3.0,
                            ),
                          ],
                        ),
                      if (_drawnPoints.isNotEmpty)
                        MarkerLayer(
                          markers: _drawnPoints.asMap().entries.map((entry) {
                            return Marker(
                              point: entry.value,
                              width: 24,
                              height: 24,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red[700],
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: const TextStyle(
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
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(widget.lat, widget.lon),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.green,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (_isCalculating)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Calculating walk-to-work rate…',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // ── Bottom control panel ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        'Points placed',
                        _drawnPoints.length.toString(),
                        Colors.grey[700]!,
                      ),
                      _buildStatItem(
                        'Status',
                        _isDrawing
                            ? 'Drawing…'
                            : _drawnPoints.isEmpty
                            ? 'Ready'
                            : 'Area drawn',
                        _isDrawing
                            ? Colors.orange[700]!
                            : _drawnPoints.isEmpty
                            ? Colors.grey[700]!
                            : Colors.green[700]!,
                      ),
                    ],
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 12.0),
                  const Divider(height: 1),
                  const SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (!_isDrawing && _drawnPoints.isEmpty)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.draw, size: 18),
                          label: const Text('Start Drawing'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 12.0,
                            ),
                          ),
                          onPressed: _startDrawing,
                        ),
                      if (_isDrawing) ...[
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Finish Drawing'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 12.0,
                            ),
                          ),
                          onPressed: _drawnPoints.length >= 3
                              ? _finishDrawing
                              : null,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.undo, size: 18),
                          label: const Text('Undo Last'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
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
                          icon: const Icon(Icons.directions_walk, size: 18),
                          label: const Text('Calculate Walking Rate'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 12.0,
                            ),
                          ),
                          onPressed: _calculateWalkingRate,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Clear & Restart'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
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

  // ── Helpers ───────────────────────────────────────────────────────────────
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
        const SizedBox(height: 4),
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

  // ── State actions ─────────────────────────────────────────────────────────
  void _startDrawing() {
    setState(() {
      _isDrawing = true;
      _drawnPoints.clear();
      _errorMessage = null;
    });
  }

  // How close (in miles) a new tap must be to snap to an existing point.
  // ~105 ft / 32 m — easy to close a polygon without pixel-perfect clicking.
  static const double _snapThresholdMiles = 0.02;

  void _onMapTap(TapPosition tapPosition, LatLng latLng) {
    if (!_isDrawing) return;

    // Snap the tapped location to the nearest existing drawn point if it falls
    // within the snap threshold.  Identical coordinates let the service detect
    // a closed polygon (closeDistMi == 0 < 0.031) and use the correct
    // closed-polygon buffer path instead of the open-polyline path.
    LatLng snapped = latLng;
    if (_drawnPoints.isNotEmpty) {
      final lonToMiles =
          69.0 * math.cos(latLng.latitude * math.pi / 180.0);
      for (final existing in _drawnPoints) {
        final dx = (latLng.longitude - existing.longitude) * lonToMiles;
        final dy = (latLng.latitude - existing.latitude) * 69.0;
        if (math.sqrt(dx * dx + dy * dy) < _snapThresholdMiles) {
          snapped = existing;
          break;
        }
      }
    }

    setState(() => _drawnPoints.add(snapped));
  }

  void _undoLastPoint() {
    if (_drawnPoints.isNotEmpty) {
      setState(() => _drawnPoints.removeLast());
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

  Future<void> _calculateWalkingRate() async {
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
      final polygonPoints = _drawnPoints
          .map((p) => [p.longitude, p.latitude])
          .toList();
      polygonPoints.add(polygonPoints.first); // close ring
      final result = await WalkingRateDrawingService.calculateFromPolygon(
        address: widget.matchedAddress,
        polygonPoints: polygonPoints,
      );
      if (mounted) {
        widget.onPolygonSaved?.call(List<LatLng>.from(_drawnPoints));
        Navigator.of(context).pop();
        widget.onCalculationComplete(result);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error calculating walking rate: \$e';
        _isCalculating = false;
      });
    }
  }
}
