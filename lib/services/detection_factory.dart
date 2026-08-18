import 'package:flutter/foundation.dart';
import 'detection_service.dart';
import 'http_detection_service.dart';
import 'tflite_detection_service_web.dart' if (dart.library.io) 'tflite_detection_service.dart';

class DetectionFactory {
  static DetectionService create() {
    if (kIsWeb) {
      return HttpDetectionService(apiUrl: 'https://pcb-wb29.onrender.com');
    } else {
      // On non-web platforms where dart:io is available, 
      // the conditional import will provide the real TfliteDetectionService.
      return TfliteDetectionService();
    }
  }
}
