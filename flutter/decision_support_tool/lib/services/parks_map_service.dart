import 'dart:convert';
import 'package:http/http.dart' as http;

class ParksMapData {
  final double lon;
  final double lat;
  final String matchedAddress;
  final List<Map<String, dynamic>> parkFeatures;
  final int layerId;

  ParksMapData({
    required this.lon,
    required this.lat,
    required this.matchedAddress,
    required this.parkFeatures,
    required this.layerId,
  });
}

class ParksMapService {
  static const String _arcgisPortal = "https://www.arcgis.com";
  static const String _itemId = "7b483a11c0b3489d8ce7601081872f99";
  static const double _bufferMiles = 0.5;
  static const int _maxFeaturesToDraw = 2000;

  // static const String? _arcgisApiKey = null;
  static const String? _arcgisToken = null;

  /// Get map data for displaying parks
  static Future<ParksMapData> getMapData({
    required double lon,
    required double lat,
    required String matchedAddress,
    required int layerId,
  }) async {
    try {
      final serviceUrl = await _resolveFeatureServiceUrl(_itemId);
      final layerUrl = '${serviceUrl.trimRight()}/$layerId';
      final features = await _queryFeatures(
        layerUrl,
        lon,
        lat,
        _bufferMiles,
        _maxFeaturesToDraw,
      );

      return ParksMapData(
        lon: lon,
        lat: lat,
        matchedAddress: matchedAddress,
        parkFeatures: features,
        layerId: layerId,
      );
    } catch (e) {
      throw Exception('Error getting map data: $e');
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
    _checkResponse(response);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _checkError(data);

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
