class TherapyPlace {
  const TherapyPlace({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    this.address,
    this.phone,
    this.website,
    this.rating,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final String? address;
  final String? phone;
  final String? website;
  final double? rating;
}
