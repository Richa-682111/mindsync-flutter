import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/therapy_place.dart';
import '../services/therapy_locator_service.dart';
import '../utils/app_theme.dart';

class TherapyLocatorMapScreen extends StatefulWidget {
  const TherapyLocatorMapScreen({super.key});

  @override
  State<TherapyLocatorMapScreen> createState() => _TherapyLocatorMapScreenState();
}

class _TherapyLocatorMapScreenState extends State<TherapyLocatorMapScreen> {
  final MapController _mapController = MapController();
  final TherapyLocatorService _service = TherapyLocatorService();

  StreamSubscription<Position>? _positionSubscription;
  Position? _currentPosition;
  List<TherapyPlace> _places = const [];
  bool _isLoading = true;
  bool _hasPermission = false;
  String? _error;
  double? _lastFetchLat;
  double? _lastFetchLon;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
        _error = 'Location services are disabled. Please enable GPS and try again.';
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
        _hasPermission = false;
        _error = 'Location permission is required to find nearby support.';
      });
      return;
    }

    _hasPermission = true;

    try {
      final current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _onNewPosition(current, forceFetch: true);
      _listenToLocationUpdates();
    } catch (_) {
      setState(() {
        _isLoading = false;
        _error = 'Could not get your current location.';
      });
    }
  }

  void _listenToLocationUpdates() {
    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50,
      ),
    ).listen(
      (position) => _onNewPosition(position),
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _error = 'Live location updates are unavailable.';
        });
      },
    );
  }

  Future<void> _onNewPosition(Position position, {bool forceFetch = false}) async {
    if (!mounted) return;
    setState(() {
      _currentPosition = position;
      _error = null;
    });

    final shouldFetch = forceFetch || _shouldRefreshPlaces(position.latitude, position.longitude);
    if (!shouldFetch) return;

    _lastFetchLat = position.latitude;
    _lastFetchLon = position.longitude;

    setState(() => _isLoading = true);
    try {
      print('[MAP] Fetching places at ${position.latitude}, ${position.longitude}');
      final places = await _service.fetchNearbyPlaces(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      print('[MAP] Got ${places.length} places');
      if (!mounted) return;
      setState(() {
        _places = places;
        _isLoading = false;
      });
      _mapController.move(LatLng(position.latitude, position.longitude), 13);
    } catch (e) {
      print('[MAP] ERROR: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  bool _shouldRefreshPlaces(double lat, double lon) {
    if (_lastFetchLat == null || _lastFetchLon == null) return true;
    final moved = Geolocator.distanceBetween(_lastFetchLat!, _lastFetchLon!, lat, lon);
    return moved > 300;
  }

  void _openDetails(TherapyPlace place) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(place.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              _detailLine('Address', place.address ?? 'Not available'),
              _detailLine('Distance', '${(place.distanceMeters / 1000).toStringAsFixed(2)} km'),
              _detailLine('Contact', place.phone ?? 'Not available'),
              _detailLine('Website', place.website ?? 'Not available'),
              _detailLine('Rating/Reviews', place.rating?.toStringAsFixed(1) ?? 'Not available from OSM data'),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (place.phone != null && place.phone!.isNotEmpty)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _launchUri('tel:${place.phone}'),
                        child: const Text('Call'),
                      ),
                    ),
                  if (place.phone != null && place.phone!.isNotEmpty && place.website != null)
                    const SizedBox(width: 8),
                  if (place.website != null && place.website!.isNotEmpty)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _launchUri(place.website!),
                        child: const Text('Open Website'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, height: 1.35),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUri(String value) async {
    final uri = Uri.tryParse(value.startsWith('http') || value.startsWith('tel:') ? value : 'https://$value');
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final initial = _currentPosition == null
        ? const LatLng(28.6139, 77.2090) // New Delhi fallback
        : LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Therapy & Support'),
        backgroundColor: AppTheme.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initial,
              initialZoom: 12,

            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mindsync',
              ),
              MarkerLayer(
                markers: [
                  if (_currentPosition != null)
                    Marker(
                      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      width: 44,
                      height: 44,
                      child: const Icon(Icons.my_location, color: Colors.blue, size: 28),
                    ),
                  ..._places.map(
                    (place) => Marker(
                      point: LatLng(place.latitude, place.longitude),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => _openDetails(place),
                        child: const Icon(Icons.location_on, color: Colors.red, size: 34),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_isLoading)
            const Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: _StatusCard(
                icon: Icons.sync,
                text: 'Fetching live nearby therapist and support locations...',
              ),
            ),
          if (_error != null)
            Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: _StatusCard(
                icon: Icons.error_outline,
                text: _error!,
              ),
            ),
          if (!_isLoading && _error == null && _hasPermission && _places.isEmpty)
            const Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: _StatusCard(
                icon: Icons.info_outline,
                text: 'No nearby therapist/support centers found in this area.',
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _initialize,
        label: const Text('Refresh'),
        icon: const Icon(Icons.refresh),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.textPrimary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
