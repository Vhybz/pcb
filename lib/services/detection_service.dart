import 'package:camera/camera.dart';
import '../models/defect.dart';

abstract class DetectionService {
  Future<List<Defect>> detect(String imagePath);
  Future<List<Defect>> detectStream(CameraImage image);
}
