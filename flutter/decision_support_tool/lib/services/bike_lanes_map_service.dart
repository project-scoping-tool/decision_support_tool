import 'dart:convert';
import 'package:http/http.dart' as http;

class BikeLanesMapData {
  final double lon;
  final double lat;
  final String matchedAddress;
  final List<Map<String, dynamic>> bikeLaneFeatures;
  final List<Map<String, dynamic>> sharedUsePathFeatures;
  final int bikeLaneLayerId;
  final int sharedUsePathLayerId;

  BikeLanesMapData({
    required this.lon,
    required this.lat,
    required this.matchedAddress,
    required this.bikeLaneFeatures,
    required this.sharedUsePathFeatures,
    required this.bikeLaneLayerId,
    required this.sharedUsePathLayerId,
  });
}

class BikeLanesMapService {
  static const String _arcgisPortal = "https://www.arcgis.com";
  static const String _bikeLaneItemId = "ae77a3326fe64b788618c2f29988ebeb";
  static const String _sharedUsePathItemId = "222b1b87a5984a29ad801c3a55aea778";
  static const double _bufferMiles = 0.25; // 1/4 mile
  static const int _maxFeaturesToDraw = 2000;

  static const String? _arcgisToken = null;

  /// Check if URL already points to a specific layer
  static bool _isLayerUrl(String url) {
    final parts = url.trimRight().split('/');
    if (parts.length < 2) return false;
    return (parts[parts.length - 2] == 'FeatureServer' ||
            parts[parts.length - 2] == 'MapServer') &&
        RegExp(r'^\d+$').hasMatch(parts.last);
  }

  /// Get map data for displaying bike lanes and shared use paths
  static Future<BikeLanesMapData> getMapData({
    required double lon,
    required double lat,
    required String matchedAddress,
    required int bikeLaneLayerId,
    required int sharedUsePathLayerId,
  }) async {
    try {
      print('=== Getting Bike Lanes Map Data ===');

      // Resolve service URLs
      final bikeLaneServiceUrl = await _resolveFeatureServiceUrl(
        _bikeLaneItemId,
      );
      final sharedUsePathServiceUrl = await _resolveFeatureServiceUrl(
        _sharedUsePathItemId,
      );

      // Check if URLs already contain layer IDs
      final bikeLaneLayerUrl = _isLayerUrl(bikeLaneServiceUrl)
          ? bikeLaneServiceUrl
          : '${bikeLaneServiceUrl.trimRight()}/$bikeLaneLayerId';
      final sharedUsePathLayerUrl = _isLayerUrl(sharedUsePathServiceUrl)
          ? sharedUsePathServiceUrl
          : '${sharedUsePathServiceUrl.trimRight()}/$sharedUsePathLayerId';

      print('Querying bike lane features from: $bikeLaneLayerUrl');
      print('Querying shared use path features from: $sharedUsePathLayerUrl');

      // Query features from both layers
      final bikeLaneFeatures = await _queryFeatures(
        bikeLaneLayerUrl,
        lon,
        lat,
        _bufferMiles,
        _maxFeaturesToDraw,
      );

      final sharedUsePathFeatures = await _queryFeatures(
        sharedUsePathLayerUrl,
        lon,
        lat,
        _bufferMiles,
        _maxFeaturesToDraw,
      );

      print('✓ Retrieved ${bikeLaneFeatures.length} bike lane features');
      print(
        '✓ Retrieved ${sharedUsePathFeatures.length} shared use path features',
      );
      print('=== Map Data Retrieved Successfully ===');

      return BikeLanesMapData(
        lon: lon,
        lat: lat,
        matchedAddress: matchedAddress,
        bikeLaneFeatures: bikeLaneFeatures,
        sharedUsePathFeatures: sharedUsePathFeatures,
        bikeLaneLayerId: bikeLaneLayerId,
        sharedUsePathLayerId: sharedUsePathLayerId,
      );
    } catch (e) {
      print('Error in getMapData: $e');
      throw Exception('Error getting bike lanes map data: $e');
    }
  }

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

  static Future<List<Map<String, dynamic>>> _queryFeatures(
    String layerUrl,
    double lon,
    double lat,
    double miles,
    int maxCount,
  ) async {
    final qurl = Uri.parse('${layerUrl.trimRight()}/query');
    final params = {
      'f': 'json',
      'where': '1=1',
      'outFields': '*',
      'returnGeometry': 'true',
      'geometryType': 'esriGeometryPoint',
      'geometry': '$lon,$lat',
      'inSR': '4326',
      'spatialRel': 'esriSpatialRelIntersects',
      'distance': miles.toString(),
      'units': 'esriSRUnit_StatuteMile',
      'resultRecordCount': maxCount.toString(),
      'outSR': '4326',
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

    final features = data['features'] as List?;
    if (features == null) {
      return [];
    }

    return features.map((f) => f as Map<String, dynamic>).toList();
  }

  static void _checkResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  static void _checkError(Map<String, dynamic> data) {
    if (data.containsKey('error')) {
      final error = data['error'];
      throw Exception('ArcGIS error: $error');
    }
  }
}
