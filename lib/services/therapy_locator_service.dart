import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/therapy_place.dart';

class TherapyLocatorService {
  TherapyLocatorService({http.Client? client}) : _client = client ?? http.Client();

  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';
  static const String _corsProxy = 'https://corsproxy.io/?';
  final http.Client _client;

  String get _effectiveUrl =>
      kIsWeb ? '$_corsProxy${Uri.encodeComponent(_overpassUrl)}' : _overpassUrl;

  Future<List<TherapyPlace>> fetchNearbyPlaces({
    required double latitude,
    required double longitude,
    int radiusMeters = 10000,
  }) async {
    // Strict mental-health-specific query
    final strictQuery = '''
[out:json][timeout:25];
(
  node(around:$radiusMeters,$latitude,$longitude)["healthcare"="psychotherapist"];
  way(around:$radiusMeters,$latitude,$longitude)["healthcare"="psychotherapist"];
  node(around:$radiusMeters,$latitude,$longitude)["healthcare"="psychiatrist"];
  way(around:$radiusMeters,$latitude,$longitude)["healthcare"="psychiatrist"];
  node(around:$radiusMeters,$latitude,$longitude)["office"="therapist"];
  way(around:$radiusMeters,$latitude,$longitude)["office"="therapist"];
  node(around:$radiusMeters,$latitude,$longitude)["amenity"="clinic"]["healthcare:speciality"~"psychiatry|mental_health",i];
  way(around:$radiusMeters,$latitude,$longitude)["amenity"="clinic"]["healthcare:speciality"~"psychiatry|mental_health",i];
  node(around:$radiusMeters,$latitude,$longitude)["amenity"="social_facility"]["social_facility:for"~"mental_health|disabled|senior",i];
  way(around:$radiusMeters,$latitude,$longitude)["amenity"="social_facility"]["social_facility:for"~"mental_health|disabled|senior",i];
);
out center tags;
''';

    // Broader fallback query — clinics, hospitals, doctors, any healthcare
    final broadQuery = '''
[out:json][timeout:25];
(
  node(around:$radiusMeters,$latitude,$longitude)["amenity"="clinic"];
  way(around:$radiusMeters,$latitude,$longitude)["amenity"="clinic"];
  node(around:$radiusMeters,$latitude,$longitude)["amenity"="hospital"];
  way(around:$radiusMeters,$latitude,$longitude)["amenity"="hospital"];
  node(around:$radiusMeters,$latitude,$longitude)["amenity"="doctors"];
  way(around:$radiusMeters,$latitude,$longitude)["amenity"="doctors"];
  node(around:$radiusMeters,$latitude,$longitude)["healthcare"];
  way(around:$radiusMeters,$latitude,$longitude)["healthcare"];
);
out center tags;
''';

    List<dynamic> elements = const [];

    // Try strict query first
    try {
      elements = await _runQuery(strictQuery);
    } catch (e) {
      print('Strict query failed: $e');
    }

    // Fallback to broad query if strict returns nothing
    if (elements.isEmpty) {
      try {
        elements = await _runQuery(broadQuery);
      } catch (e) {
        print('Broad query also failed: $e');
      }
    }

    if (elements.isEmpty) {
      throw Exception(
        'No nearby support locations found. This may be due to limited data in your area or a network issue.',
      );
    }

    final places = <TherapyPlace>[];

    for (final raw in elements) {
      final item = raw as Map<String, dynamic>;
      final tags = (item['tags'] as Map<String, dynamic>? ?? const {});
      final lat = (item['lat'] as num?)?.toDouble() ?? (item['center']?['lat'] as num?)?.toDouble();
      final lon = (item['lon'] as num?)?.toDouble() ?? (item['center']?['lon'] as num?)?.toDouble();
      if (lat == null || lon == null) continue;

      final name = (tags['name'] ?? tags['operator'] ?? tags['brand'] ?? 'Healthcare Center').toString();
      final phone = (tags['phone'] ?? tags['contact:phone'])?.toString();
      final website = (tags['website'] ?? tags['contact:website'])?.toString();
      final ratingRaw = tags['rating'] ?? tags['stars'];
      final rating = ratingRaw == null ? null : double.tryParse(ratingRaw.toString());
      final address = _buildAddress(tags);
      final distance = Geolocator.distanceBetween(latitude, longitude, lat, lon);
      final id = '${item['type']}-${item['id']}';

      places.add(
        TherapyPlace(
          id: id,
          name: name,
          latitude: lat,
          longitude: lon,
          distanceMeters: distance,
          address: address,
          phone: phone,
          website: website,
          rating: rating,
        ),
      );
    }

    final deduped = <String, TherapyPlace>{};
    for (final p in places) {
      deduped.putIfAbsent('${p.name}-${p.latitude}-${p.longitude}', () => p);
    }

    final result = deduped.values.toList()
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return result;
  }

  Future<List<dynamic>> _runQuery(String query) async {
    final response = await _client
        .post(Uri.parse(_effectiveUrl), body: {'data': query})
        .timeout(const Duration(seconds: 25));

    if (response.statusCode != 200) {
      throw Exception('API returned status ${response.statusCode}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['elements'] as List<dynamic>? ?? const [];
  }

  String? _buildAddress(Map<String, dynamic> tags) {
    final street = tags['addr:street']?.toString();
    final house = tags['addr:housenumber']?.toString();
    final city = tags['addr:city']?.toString();
    final state = tags['addr:state']?.toString();
    final postcode = tags['addr:postcode']?.toString();

    final line1 = [house, street].where((v) => v != null && v.isNotEmpty).join(' ');
    final line2 = [city, state, postcode].where((v) => v != null && v.isNotEmpty).join(', ');
    final combined = [line1, line2].where((v) => v.isNotEmpty).join(' | ');
    if (combined.isEmpty) return null;
    return combined;
  }
}
