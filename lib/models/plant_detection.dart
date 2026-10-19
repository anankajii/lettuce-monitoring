class PlantDetection {
  const PlantDetection({
    required this.label,
    required this.confidence,
    required this.createdAt,
    this.imagePath,
  });

  final String label;
  final double confidence;
  final DateTime createdAt;
  final String? imagePath;
}
