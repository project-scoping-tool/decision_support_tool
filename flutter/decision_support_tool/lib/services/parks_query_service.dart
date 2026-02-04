import 'dart:convert';
import 'package:http/http.dart' as http;

class ParksQueryResult {
  final int count;
  final String matchedAddress;
  final double lon;
  final double lat;
  final String answer;
  final int layerId;

  ParksQueryResult({
    required this.count,
    required this.matchedAddress,
    required this.lon,
    required this.lat,
    required this.answer,
    required this.layerId,
  });
}

class ParksQueryService {
  static const String _arcgisPortal = "https://www.arcgis.com";
  static const String _itemId = "7b483a11c0b3489d8ce7601081872f99";
  static const double _bufferMiles = 0.5;
  static const List<int> _parkLayerIds = [5, 6, 7, 8, 9, 10];

  // Optional: Add your ArcGIS API key here if you have one
  static const String? _arcgisApiKey = null;
  static const String? _arcgisToken = null;

  /// Main method to count parks near an address
  static Future<ParksQueryResult> countParksNearAddress(String address) async {
    try {
      // 1. Geocode the address
      final geocodeResult = await _geocodeAddress(address);
      final lon = geocodeResult['lon'] as double;
      final lat = geocodeResult['lat'] as double;
      final matched = geocodeResult['matched'] as String;

      // 2. Resolve the feature service URL
      final serviceUrl = await _resolveFeatureServiceUrl(_itemId);

      // 3. Find the best park layer by count
      final bestLayerResult = await _bestLayerByCount(
        serviceUrl,
        lon,
        lat,
        _bufferMiles,
      );
      final bestId = bestLayerResult['id'] as int;
      final bestCount = bestLayerResult['count'] as int;

      if (bestId < 0) {
        throw Exception('Could not query any park layers successfully');
      }

      // 4. Determine answer based on count
      String answer;
      if (bestCount == 0) {
        answer = '0';
      } else if (bestCount == 1) {
        answer = '1';
      } else {
        answer = '>1';
      }

      return ParksQueryResult(
        count: bestCount,
        matchedAddress: matched,
        lon: lon,
        lat: lat,
        answer: answer,
        layerId: bestId,
      );
    } catch (e) {
      throw Exception('Error querying parks: $e');
    }
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

  /// Count features within a radius of a point
  static Future<int> _countOnly(
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
    _checkResponse(response);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _checkError(data);

    return (data['count'] as num?)?.toInt() ?? 0;
  }

  /// Try all park layers and choose the one with the largest count
  static Future<Map<String, int>> _bestLayerByCount(
    String serviceUrl,
    double lon,
    double lat,
    double miles,
  ) async {
    int bestId = -1;
    int bestCount = -1;

    for (final lid in _parkLayerIds) {
      final layerUrl = '${serviceUrl.trimRight()}/$lid';
      try {
        final count = await _countOnly(layerUrl, lon, lat, miles);
        if (count > bestCount) {
          bestCount = count;
          bestId = lid;
        }
      } catch (e) {
        // Skip layers that fail
        continue;
      }
    }

    return {'id': bestId, 'count': bestCount};
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
