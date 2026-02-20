import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:decision_support_tool/services/walking_rate_drawing_service.dart';

/// Data container used by AutoFillMapDialog for the walking rate map.
class WalkingRateMapData {
  final double lon;
  final double lat;
  final String matchedAddress;
  final WalkingRateDrawingResult result;

  WalkingRateMapData({
    required this.lon,
    required this.lat,
    required this.matchedAddress,
    required this.result,
  });
}

/// Results map: renders each intersecting Census Tract as a coloured polygon
/// labelled "51.07:\n2.1%" – matching the Python prototype output.
/// Uses a Greens colour palette to align with data.census.gov's walk-to-work map.
class WalkingRateMapWidget extends StatelessWidget {
  final double lat;
  final double lon;
  final String matchedAddress;
  final WalkingRateDrawingResult result;

  const WalkingRateMapWidget({
    Key? key,
    required this.lat,
    required this.lon,
    required this.matchedAddress,
    required this.result,
  }) : super(key: key);

  // ── Greens colour scale – matches walking-rate.toml buckets ───────────────
  // Bins: 0–1.7%, 1.8–5.5%, 5.6–12.2%, 12.3–29.9%, 30–54.6%
  static const _binColors = [
    Color(0xFFedf8e9), // 0–1.7%  (lightest green)
    Color(0xFFc7e9c0), // 1.8–5.5%
    Color(0xFFa1d99b), // 5.6–12.2%
    Color(0xFF74c476), // 12.3–29.9%
    Color(0xFF31a354), // 30–54.6% (darkest green)
  ];

  static Color _colorForRate(double? rate) {
    if (rate == null) return const Color(0xFFdddddd);
    if (rate <= 1.7) return _binColors[0];
    if (rate <= 5.5) return _binColors[1];
    if (rate <= 12.2) return _binColors[2];
    if (rate <= 29.9) return _binColors[3];
    return _binColors[4];
  }

  // ── Centroid of a polygon (for label placement) ────────────────────────────
  static LatLng _centroid(List<List<double>> coords) {
    double sumX = 0, sumY = 0;
    for (final c in coords) {
      sumX += c[0];
      sumY += c[1];
    }
    return LatLng(sumY / coords.length, sumX / coords.length);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // ── Build tract polygons ──────────────────────────────────────────────────
    final tractPolygons = <Polygon>[];
    final tractLabelMarkers = <Marker>[];

    for (final tract in result.tracts) {
      if (tract.geometry.isEmpty) continue;

      final latLngRing = tract.geometry.map((c) => LatLng(c[1], c[0])).toList();

      tractPolygons.add(
        Polygon(
          points: latLngRing,
          color: _colorForRate(tract.walkRate).withOpacity(0.65),
          borderColor: Colors.black,
          borderStrokeWidth: 2.0,
          isFilled: true,
        ),
      );

      // Label like "51.07:\n2.1%"
      final rateStr = tract.walkRate != null
          ? '${tract.walkRate!.toStringAsFixed(1)}%'
          : 'N/A';
      final labelText = '${tract.tractLabel}:\n$rateStr';
      final center = _centroid(tract.geometry);

      tractLabelMarkers.add(
        Marker(
          point: center,
          width: 90,
          height: 44,
          child: IgnorePointer(
            child: Center(
              child: Text(
                labelText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  shadows: [
                    Shadow(
                      color: Colors.white,
                      blurRadius: 3,
                      offset: Offset(1, 1),
                    ),
                    Shadow(
                      color: Colors.white,
                      blurRadius: 3,
                      offset: Offset(-1, -1),
                    ),
                    Shadow(
                      color: Colors.white,
                      blurRadius: 3,
                      offset: Offset(1, -1),
                    ),
                    Shadow(
                      color: Colors.white,
                      blurRadius: 3,
                      offset: Offset(-1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // ── Drawn polygon outline ─────────────────────────────────────────────────
    List<LatLng>? drawnOutline;
    if (result.drawnPolygon != null && result.drawnPolygon!.length >= 3) {
      drawnOutline = result.drawnPolygon!
          .map((c) => LatLng(c[1], c[0]))
          .toList();
    }

    return Dialog(
      insetPadding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: screenWidth * 0.9,
        height: screenHeight * 0.9,
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                // color: Colors.green[700],
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
                        const Icon(
                          Icons.directions_walk,
                          color: Colors.white,
                          size: 24.0,
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Text(
                            'Walking Rate Map – $matchedAddress',
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

            // ── Map ────────────────────────────────────────────────────────
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(lat, lon),
                  initialZoom: 13.0,
                  minZoom: 10.0,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),

                  // 1. Tract fill polygons (behind everything)
                  if (tractPolygons.isNotEmpty)
                    PolygonLayer(polygons: tractPolygons),

                  // 2. Drawn polygon outline (on top of tract fills)
                  if (drawnOutline != null && drawnOutline.length >= 3)
                    PolygonLayer(
                      polygons: [
                        Polygon(
                          points: drawnOutline,
                          // color: Colors.green.withOpacity(0.10),
                          color: Colors.blue.withOpacity(0.10),
                          // borderColor: Colors.green[800]!,
                          borderColor: Colors.blue,
                          borderStrokeWidth: 3.0,
                          isFilled: true,
                        ),
                      ],
                    ),

                  // 3. Tract labels (markers centred on each tract)
                  if (tractLabelMarkers.isNotEmpty)
                    MarkerLayer(markers: tractLabelMarkers),

                  // 4. Project address pin
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(lat, lon),
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
            ),

            // ── Stats + table panel ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statItem(
                        'Tracts',
                        result.tractCount.toString(),
                        Colors.green[700]!,
                      ),
                      _statItem(
                        'Avg Rate',
                        '${result.simpleAverage.toStringAsFixed(1)}%',
                        Colors.blue[700]!,
                      ),
                      _statItem(
                        'Wtd Avg',
                        '${result.weightedAverage.toStringAsFixed(1)}%',
                        Colors.orange[700]!,
                      ),
                      _statItem(
                        'DST Answer',
                        result.answer,
                        Colors.green[700]!,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  const Divider(height: 1),
                  const SizedBox(height: 6.0),

                  // Per-tract table
                  if (result.tracts.isNotEmpty)
                    SizedBox(
                      height: 110,
                      child: SingleChildScrollView(
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(3.5),
                            3: FlexColumnWidth(3),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                              ),
                              children: const [
                                _TH('Tract'),
                                _TH('Rate'),
                                _TH('Area in selection (sq mi)'),
                                _TH('Bucket'),
                              ],
                            ),
                            for (final t in result.tracts)
                              TableRow(
                                decoration: BoxDecoration(
                                  color: _colorForRate(
                                    t.walkRate,
                                  ).withOpacity(0.3),
                                ),
                                children: [
                                  _TD(t.tractLabel),
                                  _TD(
                                    t.walkRate != null
                                        ? '${t.walkRate!.toStringAsFixed(1)}%'
                                        : 'N/A',
                                  ),
                                  _TD(t.areaSqMiles.toStringAsFixed(4)),
                                  _TD(t.bucket),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 6.0),
                  _buildLegend(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Small helpers ─────────────────────────────────────────────────────────

  Widget _statItem(String label, String value, Color color) => Column(
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        style: TextStyle(
          fontSize: 15,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );

  Widget _buildLegend() {
    const labels = [
      '0–1.7%',
      '1.8–5.5%',
      '5.6–12.2%',
      '12.3–29.9%',
      '30–54.6%',
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        for (int i = 0; i < labels.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: _binColors[i],
                  border: Border.all(color: Colors.grey),
                ),
              ),
              const SizedBox(width: 4),
              Text(labels[i], style: const TextStyle(fontSize: 11)),
            ],
          ),
      ],
    );
  }
}

// ── Tiny table cell widgets ───────────────────────────────────────────────────

class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
    ),
  );
}

class _TD extends StatelessWidget {
  final String text;
  const _TD(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    child: Text(text, style: const TextStyle(fontSize: 11)),
  );
}
