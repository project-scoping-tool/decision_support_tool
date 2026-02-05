import 'dart:convert';
import 'package:http/http.dart' as http;

class BikeLanesQueryResult {
  final int count;
  final String matchedAddress;
  final double lon;
  final double lat;
  final String answer;
  final int bikeLaneLayerId;
  final int sharedUsePathLayerId;

  BikeLanesQueryResult({
    required this.count,
    required this.matchedAddress,
    required this.lon,
    required this.lat,
    required this.answer,
    required this.bikeLaneLayerId,
    required this.sharedUsePathLayerId,
  });
}

class BikeLanesQueryService {
  static const String _arcgisPortal = "https://www.arcgis.com";

  // Item IDs from the RTC data
  static const String _bikeLaneItemId = "ae77a3326fe64b788618c2f29988ebeb";
  static const String _sharedUsePathItemId = "222b1b87a5984a29ad801c3a55aea778";

  static const double _bufferMiles = 0.25; // 1/4 mile radius

  static const String? _arcgisApiKey = null;
  static const String? _arcgisToken = null;

  /// Main method to count bike lanes and shared use paths near an address
  static Future<BikeLanesQueryResult> countBikeLanesNearAddress(
    String address,
  ) async {
    try {
      print('=== Bike Lanes Query Starting ===');

      // 1. Geocode the address
      print('Step 1: Geocoding address...');
      final geocodeResult = await _geocodeAddress(address);
      final lon = geocodeResult['lon'] as double;
      final lat = geocodeResult['lat'] as double;
      final matched = geocodeResult['matched'] as String;
      print('✓ Geocoded: $matched at ($lon, $lat)');

      // 2. Resolve both item URLs
      print('Step 2: Resolving feature service URLs...');
      final bikeLaneUrl = await _resolveFeatureServiceUrl(_bikeLaneItemId);
      final sharedUsePathUrl = await _resolveFeatureServiceUrl(
        _sharedUsePathItemId,
      );
      print('✓ Bike Lane URL: $bikeLaneUrl');
      print('✓ Shared Use Path URL: $sharedUsePathUrl');

      // 3. Pick queryable layers
      print('Step 3: Selecting queryable layers...');
      final bikeLaneLayer = await _pickQueryLayer(bikeLaneUrl);
      final sharedUsePathLayer = await _pickQueryLayer(sharedUsePathUrl);
      print('✓ Bike Lane Layer: $bikeLaneLayer');
      print('✓ Shared Use Path Layer: $sharedUsePathLayer');

      // 4. Count features in both layers
      print('Step 4: Counting features...');
      final bikeLaneCount = await _tryCountFeatures(
        bikeLaneLayer,
        lon,
        lat,
        _bufferMiles,
      );
      final sharedUsePathCount = await _tryCountFeatures(
        sharedUsePathLayer,
        lon,
        lat,
        _bufferMiles,
      );

      final totalCount = bikeLaneCount + sharedUsePathCount;

      print('✓ Bike Lanes: $bikeLaneCount');
      print('✓ Shared Use Paths: $sharedUsePathCount');
      print('✓ Total: $totalCount');

      // 5. Extract layer IDs
      final bikeLaneLayerId = _extractLayerId(bikeLaneLayer);
      final sharedUsePathLayerId = _extractLayerId(sharedUsePathLayer);

      print('=== Bike Lanes Query Complete ===');

      return _buildResult(
        totalCount,
        matched,
        lon,
        lat,
        bikeLaneLayerId,
        sharedUsePathLayerId,
      );
    } catch (e) {
      print('Bike Lanes Query Failed: $e');
      throw Exception('Error querying bike lanes and shared use paths: $e');
    }
  }

  /// Extract layer ID from a layer URL
  static int _extractLayerId(String layerUrl) {
    final parts = layerUrl.trimRight().split('/');
    if (parts.isNotEmpty && RegExp(r'^\d+$').hasMatch(parts.last)) {
      return int.parse(parts.last);
    }
    return 0; // default
  }

  /// Check if URL is already a layer URL
  static bool _isLayerUrl(String url) {
    final parts = url.trimRight().split('/');
    if (parts.length < 2) return false;
    return (parts[parts.length - 2] == 'FeatureServer' ||
            parts[parts.length - 2] == 'MapServer') &&
        RegExp(r'^\d+$').hasMatch(parts.last);
  }

  /// Pick a queryable layer from service URL
  static Future<String> _pickQueryLayer(String url) async {
    url = url.trimRight();

    // If already a layer URL, return it
    if (_isLayerUrl(url)) {
      return url;
    }

    // Otherwise, get layers and pick the first one
    final params = {'f': 'json'};
    if (_arcgisToken != null) {
      params['token'] = _arcgisToken!;
    }

    try {
      final response = await http.get(
        Uri.parse(url).replace(queryParameters: params),
      );
      _checkResponse(response);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _checkError(data);

      final layers = data['layers'] as List?;
      if (layers == null || layers.isEmpty) {
        throw Exception('No layers found at service: $url');
      }

      final firstId = (layers[0]['id'] as num).toInt();
      return '$url/$firstId';
    } catch (e) {
      print('Error picking layer: $e');
      rethrow;
    }
  }

  /// Try to count features from a specific layer URL
  static Future<int> _tryCountFeatures(
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

    if (data.containsKey('error')) {
      final error = data['error'];
      throw Exception('ArcGIS error: $error');
    }

    return (data['count'] as num?)?.toInt() ?? 0;
  }

  /// Build the result object
  static BikeLanesQueryResult _buildResult(
    int count,
    String matched,
    double lon,
    double lat,
    int bikeLaneLayerId,
    int sharedUsePathLayerId,
  ) {
    String answer;
    if (count == 0) {
      answer = '0';
    } else {
      answer = '1 or more';
    }

    return BikeLanesQueryResult(
      count: count,
      matchedAddress: matched,
      lon: lon,
      lat: lat,
      answer: answer,
      bikeLaneLayerId: bikeLaneLayerId,
      sharedUsePathLayerId: sharedUsePathLayerId,
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
