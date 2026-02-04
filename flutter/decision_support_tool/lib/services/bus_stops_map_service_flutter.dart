import 'dart:convert';
import 'package:http/http.dart' as http;

class BusStopsMapData {
  final double lon;
  final double lat;
  final String matchedAddress;
  final List<Map<String, dynamic>> busStopFeatures;
  final int layerId;

  BusStopsMapData({
    required this.lon,
    required this.lat,
    required this.matchedAddress,
    required this.busStopFeatures,
    required this.layerId,
  });
}

class BusStopsMapService {
  static const String _arcgisPortal = "https://www.arcgis.com";
  static const String _itemId = "3a1fde0a9b9a49e98574e0c6322a088f";
  static const double _bufferMiles = 0.25; // 1/4 mile
  static const int _maxFeaturesToDraw = 2000;

  // static const String? _arcgisApiKey = null;
  static const String? _arcgisToken = null;

  /// Get map data for displaying bus stops
  static Future<BusStopsMapData> getMapData({
    required double lon,
    required double lat,
    required String matchedAddress,
    required int layerId,
  }) async {
    try {
      final serviceUrl = await _resolveFeatureServiceUrl(_itemId);
      print('Map service URL: $serviceUrl');

      // Get all layers
      final layers = await _listLayers(serviceUrl);

      // Try the provided layerId first, then try all layers
      List<Map<String, dynamic>> features = [];
      int workingLayerId = layerId;

      if (layers.isNotEmpty) {
        print('Trying provided layer ID: $layerId');

        // Try the provided layer first
        final layerUrl = '${serviceUrl.trimRight()}/$layerId';
        try {
          features = await _queryFeatures(
            layerUrl,
            lon,
            lat,
            _bufferMiles,
            _maxFeaturesToDraw,
          );
          print(
            '✓ Success with provided layer $layerId: ${features.length} features',
          );
        } catch (e) {
          print('✗ Provided layer $layerId failed: $e');

          // Try all layers
          for (final layer in layers) {
            final tryLayerId = (layer['id'] as num).toInt();
            final tryLayerUrl = '${serviceUrl.trimRight()}/$tryLayerId';

            print('Trying layer $tryLayerId: ${layer['name']}');

            try {
              features = await _queryFeatures(
                tryLayerUrl,
                lon,
                lat,
                _bufferMiles,
                _maxFeaturesToDraw,
              );
              if (features.isNotEmpty || tryLayerId == layerId) {
                workingLayerId = tryLayerId;
                print(
                  '✓ Success with layer $tryLayerId: ${features.length} features',
                );
                break;
              }
            } catch (e) {
              print('✗ Layer $tryLayerId failed: $e');
              continue;
            }
          }
        }
      } else {
        // No layers, try service URL directly
        print('No layers found, trying service directly');
        features = await _queryFeatures(
          serviceUrl,
          lon,
          lat,
          _bufferMiles,
          _maxFeaturesToDraw,
        );
      }

      return BusStopsMapData(
        lon: lon,
        lat: lat,
        matchedAddress: matchedAddress,
        busStopFeatures: features,
        layerId: workingLayerId,
      );
    } catch (e) {
      print('Error in getMapData: $e');
      throw Exception('Error getting bus stops map data: $e');
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
      final code = error['code'];

      // 404 means wrong layer
      if (code == 404 || error.toString().contains('Feature not found')) {
        throw Exception('Wrong layer (404)');
      }

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
