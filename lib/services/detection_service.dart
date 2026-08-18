import '../models/defect.dart';

abstract class DetectionService {
  Future<List<Defect>> detect(String imagePath);
}
