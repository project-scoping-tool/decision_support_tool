import 'dart:convert';
import 'package:http/http.dart' as http;

class SchoolsQueryResult {
  final int count;
  final String matchedAddress;
  final double lon;
  final double lat;
  final String answer;
  final int layerId;

  SchoolsQueryResult({
    required this.count,
    required this.matchedAddress,
    required this.lon,
    required this.lat,
    required this.answer,
    required this.layerId,
  });
}

class SchoolsQueryService {
  static const String _arcgisPortal = "https://www.arcgis.com";
  static const String _itemId =
      "ca9eba42cebc4b0c965ffe80a3923978"; // Schools layer item ID
  static const double _bufferMiles = 0.5; // 1/2 mile radius

  // Optional: Add your ArcGIS API key here if you have one
  static const String? _arcgisApiKey = null;
  static const String? _arcgisToken = null;

  /// Main method to count schools near an address
  static Future<SchoolsQueryResult> countSchoolsNearAddress(
    String address,
  ) async {
    try {
      // 1. Geocode the address
      final geocodeResult = await _geocodeAddress(address);
      final lon = geocodeResult['lon'] as double;
      final lat = geocodeResult['lat'] as double;
      final matched = geocodeResult['matched'] as String;

      // 2. Resolve the feature service URL
      final serviceUrl = await _resolveFeatureServiceUrl(_itemId);
      print('Service URL: $serviceUrl');

      // 3. Get layer list
      final layers = await _listLayers(serviceUrl);

      if (layers.isEmpty) {
        print('No layers found, trying service URL directly');
        // Try the service URL directly
        final count = await _tryCountSchools(
          serviceUrl,
          lon,
          lat,
          _bufferMiles,
        );
        if (count >= 0) {
          return _buildResult(count, matched, lon, lat, 0);
        }
        throw Exception('No layers found and direct query failed');
      }

      print('Found ${layers.length} layer(s):');
      for (final layer in layers) {
        print('  - ID: ${layer['id']}, Name: ${layer['name']}');
      }

      // 4. Pick the best school layer (prefer campus/campuses layers)
      final bestLayerId = _pickBestSchoolLayer(layers);
      print('Auto-picked layer: $bestLayerId');

      final layerUrl = '${serviceUrl.trimRight()}/$bestLayerId';

      try {
        final count = await _tryCountSchools(layerUrl, lon, lat, _bufferMiles);
        print('✓ Success with layer $bestLayerId: Found $count schools');
        return _buildResult(count, matched, lon, lat, bestLayerId);
      } catch (e) {
        print('✗ Layer $bestLayerId failed: $e');

        // If the best layer fails, try all layers
        Exception? lastError;

        for (final layer in layers) {
          final layerId = (layer['id'] as num).toInt();
          if (layerId == bestLayerId) continue; // Already tried

          final layerName = layer['name'] as String?;
          final tryLayerUrl = '${serviceUrl.trimRight()}/$layerId';

          print('Trying layer $layerId: $layerName');

          try {
            final count = await _tryCountSchools(
              tryLayerUrl,
              lon,
              lat,
              _bufferMiles,
            );
            if (count >= 0) {
              print('✓ Success with layer $layerId: Found $count schools');
              return _buildResult(count, matched, lon, lat, layerId);
            }
          } catch (e) {
            print('  ✗ Layer $layerId failed: $e');
            lastError = e as Exception;
            continue;
          }
        }

        // If we got here, all layers failed
        throw Exception(
          'Could not find schools in any layer. '
          'Tried ${layers.length} layer(s). '
          'Last error: ${lastError?.toString() ?? "Unknown"}',
        );
      }
    } catch (e) {
      print('Error in countSchoolsNearAddress: $e');
      throw Exception('Error querying schools: $e');
    }
  }

  /// Pick the best school layer based on name heuristics
  static int _pickBestSchoolLayer(List<Map<String, dynamic>> layers) {
    // Preference order for layer names
    final preferredTokens = [
      ['campus'], // "Campus" or "Campuses"
      ['campuses'],
      ['school programs'],
      ['ccsd', 'campus'],
      ['school'],
    ];

    for (final tokens in preferredTokens) {
      for (final layer in layers) {
        final name = (layer['name'] as String?)?.toLowerCase() ?? '';
        if (tokens.every((token) => name.contains(token))) {
          return (layer['id'] as num).toInt();
        }
      }
    }

    // Default to first layer
    return (layers[0]['id'] as num).toInt();
  }

  /// Try to count schools from a specific layer URL
  static Future<int> _tryCountSchools(
    String layerUrl,
    double lon,
    double lat,
    double miles,
  ) async {
    final qurl = Uri.parse('${layerUrl.trimRight()}/query');
    final params = {
      'f': 'json',
      'where': '1=1',
      'returnCountOnly': 'true',
      'geometryType': 'esriGeometryPoint',
      'geometry': '$lon,$lat',
      'inSR': '4326',
      'spatialRel': 'esriSpatialRelIntersects',
      'distance': miles.toString(),
      'units': 'esriSRUnit_StatuteMile',
    };

    if (_arcgisToken != null) {
      params['token'] = _arcgisToken!;
    }

    final response = await http.get(qurl.replace(queryParameters: params));

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    // Check for errors
    if (data.containsKey('error')) {
      final error = data['error'];
      final code = error['code'];

      // 404 or "Feature not found" means this isn't the right layer
      if (code == 404 || error.toString().contains('Feature not found')) {
        throw Exception('Wrong layer (404)');
      }

      throw Exception('ArcGIS error: $error');
    }

    return (data['count'] as num?)?.toInt() ?? 0;
  }

  /// Build the result object
  static SchoolsQueryResult _buildResult(
    int count,
    String matched,
    double lon,
    double lat,
    int layerId,
  ) {
    String answer;
    if (count == 0) {
      answer = '0';
    } else if (count == 1) {
      answer = '1';
    } else {
      answer = '>1';
    }

    return SchoolsQueryResult(
      count: count,
      matchedAddress: matched,
      lon: lon,
      lat: lat,
      answer: answer,
      layerId: layerId,
    );
  }

  /// Geocode an address using ArcGIS World Geocoding Service
  static Future<Map<String, dynamic>> _geocodeAddress(String address) async {
    final geocodeUrl = Uri.parse(
      'https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates',
    );

    final params = {
      'f': 'json',
      'singleLine': address,
      'outFields': 'Match_addr,Addr_type',
      'maxLocations': '1',
    };

    if (_arcgisApiKey != null) {
      params['token'] = _arcgisApiKey!;
    } else if (_arcgisToken != null) {
      params['token'] = _arcgisToken!;
    }

    final response = await http.get(
      geocodeUrl.replace(queryParameters: params),
    );

    _checkResponse(response);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _checkError(data);

    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('No geocoding candidates returned for address: $address');
    }

    final best = candidates[0] as Map<String, dynamic>;
    final location = best['location'] as Map<String, dynamic>?;

    if (location == null) {
      throw Exception('Geocoding returned no location');
    }

    final lon = location['x'];
    final lat = location['y'];
    final matched =
        best['address'] ??
        (best['attributes'] as Map<String, dynamic>?)?['Match_addr'] ??
        'Matched address';

    if (lon == null || lat == null) {
      throw Exception('Geocoding returned no coordinates');
    }

    return {
      'lon': (lon as num).toDouble(),
      'lat': (lat as num).toDouble(),
      'matched': matched.toString(),
    };
  }

  /// Resolve ArcGIS Online item ID to service URL
  static Future<String> _resolveFeatureServiceUrl(String itemId) async {
    final itemUrl = Uri.parse(
      '$_arcgisPortal/sharing/rest/content/items/$itemId',
    );
    final params = {'f': 'json'};
    if (_arcgisToken != null) {
      params['token'] = _arcgisToken!;
    }

    final response = await http.get(itemUrl.replace(queryParameters: params));
    _checkResponse(response);

    final item = jsonDecode(response.body) as Map<String, dynamic>;
    _checkError(item);

    if (item['url'] != null) {
      return item['url'] as String;
    }

    // Try to get from data
    final dataUrl = Uri.parse(
      '$_arcgisPortal/sharing/rest/content/items/$itemId/data',
    );
    final dataResponse = await http.get(
      dataUrl.replace(queryParameters: params),
    );
    _checkResponse(dataResponse);

    final webmap = jsonDecode(dataResponse.body) as Map<String, dynamic>;
    _checkError(webmap);

    final operationalLayers = webmap['operationalLayers'] as List?;
    if (operationalLayers != null) {
      for (final layer in operationalLayers) {
        final layerMap = layer as Map<String, dynamic>;
        final url = layerMap['url'] as String?;
        if (url != null &&
            (url.contains('MapServer') || url.contains('FeatureServer'))) {
          return url;
        }
      }
    }

    throw Exception('Could not resolve a service URL from this item');
  }

  /// List layers from a MapServer/FeatureServer
  static Future<List<Map<String, dynamic>>> _listLayers(
    String serviceUrl,
  ) async {
    final params = {'f': 'json'};
    if (_arcgisToken != null) {
      params['token'] = _arcgisToken!;
    }

    try {
      final response = await http.get(
        Uri.parse(serviceUrl.trimRight()).replace(queryParameters: params),
      );
      _checkResponse(response);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _checkError(data);

      final layers = data['layers'] as List?;
      if (layers == null) {
        return [];
      }

      return layers.map((l) => l as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error listing layers: $e');
      return [];
    }
  }

  /// Helper to check HTTP response status
  static void _checkResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  /// Helper to check for ArcGIS API errors
  static void _checkError(Map<String, dynamic> data) {
    if (data.containsKey('error')) {
      final error = data['error'];
      throw Exception('ArcGIS error: $error');
    }
  }
}

// import 'dart:convert';
// import 'dart:math' as math;
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:http/http.dart' as http;

// class SchoolsQueryResult {
//   final int count;
//   final String matchedAddress;
//   final double lon;
//   final double lat;
//   final String answer;
//   final int layerId; // kept for API compatibility; unused locally

//   SchoolsQueryResult({
//     required this.count,
//     required this.matchedAddress,
//     required this.lon,
//     required this.lat,
//     required this.answer,
//     required this.layerId,
//   });
// }

// class SchoolsQueryService {
//   static const String _assetPath = 'assets/data/clark_county_schools.json';
//   static const double _bufferMiles = 0.5;

//   static List<Map<String, dynamic>>? _cachedFeatures;

//   static Future<SchoolsQueryResult> countSchoolsNearAddress(
//     String address,
//   ) async {
//     final geocodeResult = await _geocodeAddress(address);
//     final lon = geocodeResult['lon'] as double;
//     final lat = geocodeResult['lat'] as double;
//     final matched = geocodeResult['matched'] as String;

//     final features = await _loadLocalData();

//     int count = 0;
//     for (final f in features) {
//       final flon = (f['lon'] as num).toDouble();
//       final flat = (f['lat'] as num).toDouble();
//       if (_distanceMiles(lat, lon, flat, flon) <= _bufferMiles) {
//         count++;
//       }
//     }

//     String answer;
//     if (count == 0) {
//       answer = '0';
//     } else if (count == 1) {
//       answer = '1';
//     } else {
//       answer = '>1';
//     }

//     return SchoolsQueryResult(
//       count: count,
//       matchedAddress: matched,
//       lon: lon,
//       lat: lat,
//       answer: answer,
//       layerId: 0,
//     );
//   }

//   static Future<List<Map<String, dynamic>>> _loadLocalData() async {
//     if (_cachedFeatures != null) return _cachedFeatures!;
//     final jsonString = await rootBundle.loadString(_assetPath);
//     final data = jsonDecode(jsonString) as Map<String, dynamic>;
//     _cachedFeatures = (data['features'] as List).cast<Map<String, dynamic>>();
//     return _cachedFeatures!;
//   }

//   /// Haversine distance in miles.
//   static double _distanceMiles(
//     double lat1,
//     double lon1,
//     double lat2,
//     double lon2,
//   ) {
//     const earthRadiusMiles = 3958.8;
//     final dLat = _deg2rad(lat2 - lat1);
//     final dLon = _deg2rad(lon2 - lon1);
//     final a =
//         math.sin(dLat / 2) * math.sin(dLat / 2) +
//         math.cos(_deg2rad(lat1)) *
//             math.cos(_deg2rad(lat2)) *
//             math.sin(dLon / 2) *
//             math.sin(dLon / 2);
//     final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
//     return earthRadiusMiles * c;
//   }

//   static double _deg2rad(double deg) => deg * (math.pi / 180.0);

//   static Future<Map<String, dynamic>> _geocodeAddress(String address) async {
//     final url = Uri.parse(
//       'https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates',
//     );
//     final params = {
//       'f': 'json',
//       'singleLine': address,
//       'outFields': 'Match_addr,Addr_type',
//       'maxLocations': '1',
//     };
//     final response = await http.get(
//       url.replace(queryParameters: params),
//       headers: {'Accept': 'application/json'},
//     );
//     if (response.statusCode != 200) {
//       throw Exception('Geocoding failed: HTTP ${response.statusCode}');
//     }
//     final data = jsonDecode(response.body) as Map<String, dynamic>;
//     final candidates = data['candidates'] as List?;
//     if (candidates == null || candidates.isEmpty) {
//       throw Exception('No geocoding results for: $address');
//     }
//     final best = candidates[0] as Map<String, dynamic>;
//     final location = best['location'] as Map<String, dynamic>?;
//     if (location == null) throw Exception('No location in geocoding result');
//     return {
//       'lon': (location['x'] as num).toDouble(),
//       'lat': (location['y'] as num).toDouble(),
//       'matched': (best['address'] as String?) ?? address,
//     };
//   }

//   static void clearCache() {
//     _cachedFeatures = null;
//   }
// }
