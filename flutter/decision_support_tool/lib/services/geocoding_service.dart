import 'dart:convert';
import 'package:http/http.dart' as http;

/// Result of resolving a free-text address to coordinates.
class GeocodeResult {
  final double lon;
  final double lat;
  final String matchedAddress;

  GeocodeResult({
    required this.lon,
    required this.lat,
    required this.matchedAddress,
  });
}

/// Turns a user-typed project address into coordinates.
///
/// This is the **one runtime dependency on an external API** that remains
/// across the PST auto-fill questions after the local-data migration
/// (see /data_processing/README.md for why): every other question — ADI,
/// biking/walking rate, crash density, land use diversity, activity
/// density, schools, parks, bus stops, bike lanes, walkability index —
/// answers entirely from a bundled local dataset once it has a (lon, lat).
///
/// Geocoding itself was evaluated for localization and rejected: a fully
/// offline geocoder needs a bundled address-point/range dataset (tens of
/// MB even limited to Nevada) plus fuzzy text-matching/interpolation logic
/// to handle typos and abbreviations, and would likely be less accurate
/// than ArcGIS's composite locator (street ranges + address points +
/// parcels blended together). That's a materially different, much larger
/// effort than localizing the per-question data lookups, and risked
/// changing user-facing behavior. So geocoding stays external; every
/// service below calls this class once per address, then does the rest of
/// its calculation against a local asset.
class GeocodingService {
  static Future<GeocodeResult> geocodeAddress(String address) async {
    final url = Uri.parse(
      'https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates',
    );
    final params = {
      'f': 'json',
      'singleLine': address,
      'outFields': 'Match_addr,Addr_type',
      'maxLocations': '1',
    };

    final response = await http.get(
      url.replace(queryParameters: params),
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Geocoding failed: HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data.containsKey('error')) {
      throw Exception('Geocoding error: ${data['error']}');
    }

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
    final matchedAddress =
        (best['address'] as String?) ??
        (best['attributes'] as Map<String, dynamic>?)?['Match_addr']
            ?.toString() ??
        address;

    if (lon == null || lat == null) {
      throw Exception('Geocoding returned no coordinates');
    }

    return GeocodeResult(
      lon: (lon as num).toDouble(),
      lat: (lat as num).toDouble(),
      matchedAddress: matchedAddress,
    );
  }
}
