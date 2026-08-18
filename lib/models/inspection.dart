import 'defect.dart';

enum InspectionStatus { pass, fail }

class Inspection {
  final String id;
  final DateTime timestamp;
  final InspectionStatus status;
  final List<Defect> defects;
  final String imageUrl;

  Inspection({
    required this.id,
    required this.timestamp,
    required this.status,
    required this.defects,
    required this.imageUrl,
  });

  int get defectCount => defects.length;
}
