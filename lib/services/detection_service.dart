import 'dart:typed_data';
import 'package:camera/camera.dart';
import '../models/defect.dart';

abstract class DetectionService {
  Future<List<Defect>> detect(String imagePath, {Uint8List? bytes});
  Future<List<Defect>> detectStream(CameraImage image);
}
