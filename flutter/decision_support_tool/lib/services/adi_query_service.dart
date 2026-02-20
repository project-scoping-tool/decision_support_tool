import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class AdiQueryResult {
  final int adiValue;
  final String matchedAddress;
  final double lon;
  final double lat;
  final String blockGroup;
  final String county;

  AdiQueryResult({
    required this.adiValue,
    required this.matchedAddress,
    required this.lon,
    required this.lat,
    required this.blockGroup,
    required this.county,
  });
}

class AdiQueryService {
  // Nevada bounding box for geocoding
  static const String _nevadaSearchExtent =
      '-120.000808868339,34.9911168284889,-114.040269700533,42.001108550977';

  // Cache for ADI data (loaded once per session)
  static List<Map<String, dynamic>>? _cachedAdiFeatures;

  /// Lookup ADI value for an address string (geocodes internally).
  static Future<AdiQueryResult> getAdiForAddress(String address) async {
    final geocodeResult = await _geocodeAddress(address);
    final lon = geocodeResult['lon'] as double;
    final lat = geocodeResult['lat'] as double;
    final matched = geocodeResult['matched'] as String;
    return getAdiForCoordinates(lon, lat, matched);
  }

  /// Lookup ADI value using pre-resolved coordinates (skips geocoding).
  /// [matchedAddress] is the address string to include in the result.
  static Future<AdiQueryResult> getAdiForCoordinates(
    double lon,
    double lat,
    String matchedAddress,
  ) async {
    print('=== ADI Query (coordinates) ===');
    try {
      // 2. Load Nevada ADI data from local asset
      print('Step 2: Loading ADI data from local asset...');
      final geoJsonFeatures = await _loadAdiDataFromAsset();
      print('âœ“ Loaded ${geoJsonFeatures.length} ADI features');

      // 3 & 4. Iterate polygons, find the one containing our point, skip
      //         suppressed/non-numeric ADI codes (e.g. "GQ-PH").
      print('Step 3: Finding containing polygon with valid ADI...');
      AdiQueryResult? result;
      for (final feature in geoJsonFeatures) {
        final geometry = feature['geometry'] as Map<String, dynamic>?;
        if (geometry == null) continue;

        final type = geometry['type'] as String?;
        final coordinates = geometry['coordinates'];

        bool isInside = false;
        if (type == 'Polygon') {
          isInside = _isPointInPolygon(lon, lat, coordinates as List);
        } else if (type == 'MultiPolygon') {
          for (final polygon in (coordinates as List)) {
            if (_isPointInPolygon(lon, lat, polygon as List)) {
              isInside = true;
              break;
            }
          }
        }
        if (!isInside) continue;

        final properties = feature['properties'] as Map<String, dynamic>;
        final adiValueStr = properties['value_state'] as String?;
        final blockGroupId = properties['id'] as String?;
        final countyName = properties['county'] as String?;

        if (adiValueStr == null || adiValueStr.isEmpty) {
          print('  Skipping ${blockGroupId ?? "?"}: empty value_state');
          continue;
        }

        // int.tryParse returns null for suppressed codes like "GQ-PH", "PH", etc.
        final adiValue = int.tryParse(adiValueStr);
        if (adiValue == null) {
          print(
            '  Skipping ${blockGroupId ?? "?"}: suppressed code "$adiValueStr"',
          );
          continue;
        }

        if (adiValue < 1 || adiValue > 10) {
          print(
            '  Skipping ${blockGroupId ?? "?"}: ADI out of range ($adiValue)',
          );
          continue;
        }

        print('Matched ADI: $adiValue for block group: $blockGroupId');
        result = AdiQueryResult(
          adiValue: adiValue,
          matchedAddress: matchedAddress,
          lon: lon,
          lat: lat,
          blockGroup: blockGroupId ?? 'Unknown',
          county: countyName ?? 'Nevada',
        );
        break;
      }

      if (result == null) {
        throw Exception(
          'This address falls in a block group with a suppressed ADI score.\n\n'
          'This typically occurs in group-quarters areas such as:\n'
          '  • University housing / dormitories\n'
          '  • Military bases\n'
          '  • Correctional facilities\n\n'
          'Please verify the ADI manually at:\n'
          'https://www.neighborhoodatlas.medicine.wisc.edu/mapping',
        );
      }

      print('=== ADI Query Complete ===');
      return result;
    } catch (e) {
      print('ADI Query Failed: $e');
      rethrow;
    }
  }

  /// Load ADI data from local asset file
  static Future<List<Map<String, dynamic>>> _loadAdiDataFromAsset() async {
    // Return cached data if available
    if (_cachedAdiFeatures != null) {
      print('  Using cached ADI data (${_cachedAdiFeatures!.length} features)');
      return _cachedAdiFeatures!;
    }

    print('  Loading from assets/data/nevada_adi_data.json...');

    try {
      // Load from assets
      final jsonString = await rootBundle.loadString(
        'assets/data/nevada_adi_data.json',
      );

      print('  Loaded ${jsonString.length} characters');

      // Parse JSON
      var data = jsonDecode(jsonString);

      print('  JSON type: ${data.runtimeType}');

      List<Map<String, dynamic>> features;

      // Handle different JSON structures
      if (data is Map<String, dynamic>) {
        // Check if data is wrapped in a "data" key
        if (data.containsKey('data') && data['data'] is Map) {
          print('  Found data wrapper, unwrapping...');
          data = data['data'] as Map<String, dynamic>;
        }

        // Now check for FeatureCollection or features array
        if (data['type'] == 'FeatureCollection' &&
            data.containsKey('features')) {
          print('  Found FeatureCollection with features array');
          features = (data['features'] as List).cast<Map<String, dynamic>>();
        } else if (data.containsKey('features')) {
          print('  Found features array');
          features = (data['features'] as List).cast<Map<String, dynamic>>();
        } else {
          print('  Available keys: ${data.keys.toList()}');
          throw Exception('No features array found in JSON after unwrapping');
        }
      } else if (data is List) {
        print('  JSON is a direct array of features');
        features = data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Unexpected JSON structure: ${data.runtimeType}');
      }

      if (features.isEmpty) {
        throw Exception('Features array is empty');
      }

      print('  Parsed ${features.length} features');

      // Validate first feature
      if (features.isNotEmpty) {
        final first = features[0];
        if (first.containsKey('geometry') && first.containsKey('properties')) {
          final props = first['properties'] as Map<String, dynamic>?;
          print('  âœ“ Valid GeoJSON features with geometry and properties');
          if (props != null && props.containsKey('value_state')) {
            print('  âœ“ Features have ADI data (value_state)');
          }
        } else {
          print('  Warning: Features may not have proper GeoJSON structure');
        }
      }

      // Cache for future use
      _cachedAdiFeatures = features;
      return features;
    } catch (e, stackTrace) {
      print('  Error loading asset: $e');
      print(
        '  Stack trace: ${stackTrace.toString().split('\n').take(3).join('\n')}',
      );
      throw Exception(
        'Failed to load ADI data from asset.\n\n'
        'Error: $e',
      );
    }
  }

  /// Geocode an address using ArcGIS
  static Future<Map<String, dynamic>> _geocodeAddress(String address) async {
    final geocodeUrl = Uri.parse(
      'https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates',
    );

    final params = {
      'f': 'json',
      'category': 'Address,Postal',
      'sourceCountry': 'USA',
      'outFields': 'Status,Region',
      'maxLocations': '1',
      'searchExtent': _nevadaSearchExtent,
      'singleLine': address,
    };

    final response = await http.get(
      geocodeUrl.replace(queryParameters: params),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Geocoding failed: HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List?;

    if (candidates == null || candidates.isEmpty) {
      throw Exception('No geocoding results for: $address');
    }

    final best = candidates[0] as Map<String, dynamic>;
    final location = best['location'] as Map<String, dynamic>?;

    if (location == null) {
      throw Exception('No location in geocoding result');
    }

    final lon = location['x'];
    final lat = location['y'];
    final matchedAddress = best['address'] as String? ?? address;
    final score = best['score'] as num?;

    if (score != null && score < 75) {
      throw Exception('Low geocoding confidence (score: $score)');
    }

    return {
      'lon': (lon as num).toDouble(),
      'lat': (lat as num).toDouble(),
      'matched': matchedAddress,
    };
  }

  /// Ray casting algorithm for point-in-polygon test
  static bool _isPointInPolygon(double x, double y, List rings) {
    if (rings.isEmpty) return false;

    final ring = rings[0] as List;
    if (ring.length < 3) return false;

    bool inside = false;

    for (int i = 0, j = ring.length - 1; i < ring.length; j = i++) {
      final point = ring[i] as List;
      final prevPoint = ring[j] as List;

      final xi = (point[0] as num).toDouble();
      final yi = (point[1] as num).toDouble();
      final xj = (prevPoint[0] as num).toDouble();
      final yj = (prevPoint[1] as num).toDouble();

      final intersect =
          ((yi > y) != (yj > y)) && (x < (xj - xi) * (y - yi) / (yj - yi) + xi);

      if (intersect) inside = !inside;
    }

    return inside;
  }

  /// Clear cached data
  static void clearCache() {
    _cachedAdiFeatures = null;
    print('ADI cache cleared');
  }
}
