class PlaceSuggestion {
  const PlaceSuggestion({
    required this.name,
    required this.address,
    required this.roadAddress,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String address;
  final String roadAddress;
  final double latitude;
  final double longitude;

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      name: json['place_name'] as String? ?? '',
      address: json['address_name'] as String? ?? '',
      roadAddress: json['road_address_name'] as String? ?? '',
      latitude: double.tryParse(json['y'] as String? ?? '') ?? 0,
      longitude: double.tryParse(json['x'] as String? ?? '') ?? 0,
    );
  }
}
