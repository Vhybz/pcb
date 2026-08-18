import 'package:camera/camera.dart';
import '../models/defect.dart';
import 'detection_service.dart';

class TfliteDetectionService implements DetectionService {
  @override
  Future<List<Defect>> detect(String imagePath, {Uint8List? bytes}) async {
    throw UnsupportedError('TFLite is not supported on Web. Use HttpDetectionService.');
  }

  @override
  Future<List<Defect>> detectStream(CameraImage image) async {
    return [];
  }
}
