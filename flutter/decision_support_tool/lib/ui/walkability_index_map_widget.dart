import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:decision_support_tool/services/walkability_index_drawing_service.dart';

/// Data container used by AutoFillMapDialog for the walkability index map.
class WalkabilityIndexMapData {
  final double lon;
  final double lat;
  final String matchedAddress;
  final WalkabilityIndexDrawingResult result;

  WalkabilityIndexMapData({
    required this.lon,
    required this.lat,
    required this.matchedAddress,
    required this.result,
  });
}

/// Results map: renders each intersecting EPA Block Group as a coloured
/// polygon using the exact colors fetched live from the EPA Walkability
/// Index renderer — mirroring the Python prototype's colorForValue() and
/// buildLegend() exactly.
///
/// NatWalkInd is already in the 1–20 scale (no ×10 conversion needed).
/// Color lookup uses the raw EPA class-break maxValues (also 1–20 scale).
class WalkabilityIndexMapWidget extends StatelessWidget {
  final double lat;
  final double lon;
  final String matchedAddress;
  final WalkabilityIndexDrawingResult result;

  const WalkabilityIndexMapWidget({
    Key? key,
    required this.lat,
    required this.lon,
    required this.matchedAddress,
    required this.result,
  }) : super(key: key);

  // ── Color lookup ───────────────────────────────────────────────────────────────
  // NatWalkInd and EPA class-break maxValues are both in the 1–20 scale.
  static Color _colorForIndex(
    double? idx,
    List<EpaWalkabilityClassBreak> breaks,
  ) {
    if (idx == null || breaks.isEmpty) return const Color(0xFFDDDDDD);
    for (final b in breaks) {
      if (idx <= b.maxValue) return b.fillColor;
    }
    return breaks.last.fillColor;
  }

  // ── Centroid helper ────────────────────────────────────────────────────────────
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

    // ── Build region polygons & labels ─────────────────────────────────────────
    final regionPolygons = <Polygon>[];
    final regionLabelMarkers = <Marker>[];

    for (final region in result.regions) {
      if (region.geometry.isEmpty) continue;

      final latLngRing = region.geometry
          .map((c) => LatLng(c[1], c[0]))
          .toList();

      regionPolygons.add(
        Polygon(
          points: latLngRing,
          color: _colorForIndex(
            region.walkIndex,
            result.classBreaks,
          ).withOpacity(0.70),
          borderColor: Colors.black,
          borderStrokeWidth: 2.0,
          isFilled: true,
        ),
      );

      final idxStr = region.walkIndex != null
          ? region.walkIndex!.toStringAsFixed(2)
          : 'N/A';
      final center = _centroid(region.geometry);

      regionLabelMarkers.add(
        Marker(
          point: center,
          width: 80,
          height: 36,
          child: IgnorePointer(
            child: Center(
              child: Text(
                idxStr,
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

    // ── Drawn polygon outline ──────────────────────────────────────────────────
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
            // ── Header ───────────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                // color: Colors.teal[700],
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
                            'Walkability Index Map – $matchedAddress',
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

            // ── Map ──────────────────────────────────────────────────────────────
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(lat, lon),
                  initialZoom: 14.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),

                  // 1. Region polygons (EPA colors)
                  if (regionPolygons.isNotEmpty)
                    PolygonLayer(polygons: regionPolygons),

                  // 2. Drawn selection outline
                  if (drawnOutline != null)
                    PolygonLayer(
                      polygons: [
                        Polygon(
                          points: drawnOutline,
                          // color: Colors.teal.withOpacity(0.10),
                          color: Colors.blue.withOpacity(0.10),
                          // borderColor: Colors.teal,
                          borderColor: Colors.blue,
                          borderStrokeWidth: 3.0,
                          isFilled: true,
                        ),
                      ],
                    ),

                  // 3. Region labels (NatWalkInd values)
                  if (regionLabelMarkers.isNotEmpty)
                    MarkerLayer(markers: regionLabelMarkers),

                  // 4. Project address pin
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(lat, lon),
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          // color: Colors.green,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Stats + table panel ───────────────────────────────────────────────
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
                        'Regions',
                        result.regionCount.toString(),
                        Colors.teal[800]!,
                      ),
                      _statItem(
                        'Avg Index',
                        result.simpleAverage.toStringAsFixed(2),
                        Colors.blue[700]!,
                      ),
                      _statItem(
                        'Wtd Avg',
                        result.weightedAverage.toStringAsFixed(2),
                        Colors.orange[700]!,
                      ),
                      // _statItem(
                      //   'Category',
                      //   result.roundedCategory.toString(),
                      //   Colors.purple[700]!,
                      // ),
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

                  // Per-region table
                  if (result.regions.isNotEmpty)
                    SizedBox(
                      height: 110,
                      child: SingleChildScrollView(
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2.5),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(1.5),
                            3: FlexColumnWidth(3),
                            4: FlexColumnWidth(2.5),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                              ),
                              children: const [
                                _TH('Region ID'),
                                _TH('NatWalkInd'),
                                // _TH('Cat'),
                                _TH('Area in selection (sq mi)'),
                                // _TH('DST Range'),
                              ],
                            ),
                            for (final r in result.regions)
                              TableRow(
                                decoration: BoxDecoration(
                                  color: _colorForIndex(
                                    r.walkIndex,
                                    result.classBreaks,
                                  ).withOpacity(0.25),
                                ),
                                children: [
                                  _TD(r.objectId),
                                  _TD(
                                    r.walkIndex != null
                                        ? r.walkIndex!.toStringAsFixed(2)
                                        : 'N/A',
                                  ),
                                  // _TD(
                                  //   r.category != null
                                  //       ? r.category.toString()
                                  //       : '-',
                                  // ),
                                  _TD(r.areaSqMiles.toStringAsFixed(4)),
                                  // _TD(r.bucket),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 6.0),

                  // Legend — built from live EPA class breaks
                  _buildLegend(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Small helpers ──────────────────────────────────────────────────────────────

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
    if (result.classBreaks.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: [
        for (final b in result.classBreaks)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: b.fillColor,
                  border: Border.all(color: Colors.grey),
                ),
              ),
              const SizedBox(width: 4),
              Text(b.label, style: const TextStyle(fontSize: 11)),
            ],
          ),
      ],
    );
  }
}

// ── Tiny table cell widgets ────────────────────────────────────────────────────

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
