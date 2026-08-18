import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../models/defect.dart';
import 'detection_service.dart';

class HttpDetectionService implements DetectionService {
  final String apiUrl;

  HttpDetectionService({required this.apiUrl});

  @override
  Future<List<Defect>> detect(String imagePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$apiUrl/detect'));
      
      if (imagePath.startsWith('assets/')) {
        final byteData = await rootBundle.load(imagePath);
        final bytes = byteData.buffer.asUint8List();
        request.files.add(http.MultipartFile.fromBytes(
          'file', 
          bytes,
          filename: 'image.jpg',
        ));
      } else if (kIsWeb) {
        final response = await http.get(Uri.parse(imagePath));
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          response.bodyBytes,
          filename: 'upload.jpg',
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath('file', imagePath));
      }
      
      final streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        final response = await http.Response.fromStream(streamedResponse);
        final data = json.decode(response.body);
        final List detections = data['detections'];
        
        return detections.map((d) {
          final bbox = d['bbox'];
          return Defect(
            id: 'net_${DateTime.now().millisecondsSinceEpoch}',
            className: d['class_name'],
            confidence: d['confidence'],
            severity: _mapSeverity(d['class_name'], d['confidence']),
            location: 'Remote',
            boundingBox: BoundingBox(
              x: bbox[0],
              y: bbox[1],
              width: bbox[2],
              height: bbox[3],
            ),
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('HTTP Detection Error: $e');
    }
    return [];
  }

  @override
  Future<List<Defect>> detectStream(CameraImage image) async {
    // For now, HTTP real-time is too heavy for every frame.
    return [];
  }

  DefectSeverity _mapSeverity(String className, double confidence) {
    if (confidence > 0.85) return DefectSeverity.high;
    if (className.toLowerCase().contains('short') || className.toLowerCase().contains('break')) {
      return DefectSeverity.high;
    }
    return DefectSeverity.medium;
  }
}
