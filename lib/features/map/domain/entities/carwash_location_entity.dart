class CarwashLocationEntity {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final int estimatedMinutes;
  final String? imageUrl;
  final bool isSubscribed;
  final bool isOpen;

  const CarwashLocationEntity({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.estimatedMinutes,
    this.imageUrl,
    this.isSubscribed = false,
    this.isOpen = true,
  });
}