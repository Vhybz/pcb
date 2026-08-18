enum DefectSeverity { low, medium, high }

class Defect {
  final String id;
  final String className;
  final double confidence;
  final DefectSeverity severity;
  final String location;
  final BoundingBox boundingBox;

  Defect({
    required this.id,
    required this.className,
    required this.confidence,
    required this.severity,
    required this.location,
    required this.boundingBox,
  });
}

class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}
