import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:decision_support_tool/services/pedestrian_crash_drawing_service.dart';
import 'dart:math' as math;

/// Interactive widget for drawing a polygon and calculating pedestrian crash density.
class PedestrianCrashDrawingWidget extends StatefulWidget {
  final double lat;
  final double lon;
  final String matchedAddress;
  final Function(PedestrianCrashDrawingResult) onCalculationComplete;

  /// Optional: pre-populate with a previously drawn polygon.
  final List<LatLng>? initialPoints;

  /// Optional callback invoked with the final polygon before the widget closes.
  final Function(List<LatLng>)? onPolygonSaved;

  const PedestrianCrashDrawingWidget({
    Key? key,
    required this.lat,
    required this.lon,
    required this.matchedAddress,
    required this.onCalculationComplete,
    this.initialPoints,
    this.onPolygonSaved,
  }) : super(key: key);

  @override
  State<PedestrianCrashDrawingWidget> createState() =>
      _PedestrianCrashDrawingWidgetState();
}

class _PedestrianCrashDrawingWidgetState
    extends State<PedestrianCrashDrawingWidget> {
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
      child: Container(
        width: screenWidth * 0.9,
        height: screenHeight * 0.9,
        child: Column(
          children: [
            // Header
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
                            'Draw Project Area - ${widget.matchedAddress}',
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
            // Instructions
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
                          ? 'Click on the map to draw points. Press "Finish Drawing" when done.'
                          : _drawnPoints.isNotEmpty
                          ? 'Project area loaded from a previous question. '
                                'Press "Calculate Density" to reuse it, or '
                                '"Clear & Restart" to draw a new area.'
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
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      if (_drawnPoints.length >= 2)
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
                              color: Colors.red,
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
                                  color: Colors.red,
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
                      color: Colors.black54,
                      child: Center(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
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
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border(top: BorderSide(color: Colors.red[300]!)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[900], size: 20),
                    const SizedBox(width: 8.0),
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
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => setState(() => _errorMessage = null),
                    ),
                  ],
                ),
              ),
            // Controls
            Container(
              padding: const EdgeInsets.all(12.0),
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
                          onPressed: _drawnPoints.length >= 2
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
                          icon: const Icon(Icons.calculate, size: 18),
                          label: const Text('Calculate Density'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 12.0,
                            ),
                          ),
                          onPressed: _calculateDensity,
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

  void _startDrawing() {
    setState(() {
      _isDrawing = true;
      _drawnPoints.clear();
      _errorMessage = null;
    });
  }

  // How close (in miles) a new tap must be to snap to an existing point.
  // ~105 ft / 32 m -- easy to close a polygon without pixel-perfect clicking.
  static const double _snapThresholdMiles = 0.01;

  void _onMapTap(TapPosition tapPosition, LatLng latLng) {
    if (!_isDrawing) return;

    // Snap the tapped location to the nearest existing drawn point if within
    // the snap threshold.  Identical coordinates allow the service to detect
    // a closed polygon (closeDistMi == 0 < 0.031) and use the correct
    // closed-polygon buffer path instead of the open-polyline path.
    LatLng snapped = latLng;
    if (_drawnPoints.isNotEmpty) {
      final lonToMiles = 69.0 * math.cos(latLng.latitude * math.pi / 180.0);
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
    if (_drawnPoints.length < 2) {
      setState(() {
        _errorMessage = 'Please draw at least 2 points.';
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
    if (_drawnPoints.length < 2) {
      setState(() {
        _errorMessage = 'Please draw at least 2 points.';
      });
      return;
    }
    setState(() {
      _isCalculating = true;
      _errorMessage = null;
    });
    try {
      final polylinePoints = _drawnPoints
          .map((p) => [p.longitude, p.latitude])
          .toList();
      final result = await PedestrianCrashDrawingService.calculateFromPolyline(
        address: widget.matchedAddress,
        polylinePoints: polylinePoints,
      );
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
