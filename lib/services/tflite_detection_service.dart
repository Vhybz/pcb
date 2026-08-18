import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/defect.dart';
import 'detection_service.dart';
import 'dart:math';

class TfliteDetectionService implements DetectionService {
  Interpreter? _interpreter;
  List<String>? _labels;

  static const int _inputSize = 416;
  static const double _confidenceThreshold = 0.4;
  static const double _iouThreshold = 0.45;

  Future<void> _loadModel() async {
    _interpreter ??= await Interpreter.fromAsset('assets/model/pcb_defect_model.tflite');
  }

  Future<void> _loadLabels() async {
    if (_labels != null) return;
    final labelsData = await rootBundle.loadString('assets/model/labels.txt');
    _labels = labelsData.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  @override
  Future<List<Defect>> detect(String imagePath) async {
    await _loadModel();
    await _loadLabels();

    Uint8List imageBytes;
    if (imagePath.startsWith('assets/')) {
      final byteData = await rootBundle.load(imagePath);
      imageBytes = byteData.buffer.asUint8List();
    } else {
      final imageFile = File(imagePath);
      imageBytes = await imageFile.readAsBytes();
    }
    
    final originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) return [];

    // Preprocess: Resize to 416x416
    final resizedImage = img.copyResize(originalImage, width: _inputSize, height: _inputSize);

    // Convert to float32 NCHW format: [1, 3, 416, 416]
    final input = Float32List(1 * 3 * _inputSize * _inputSize);
    for (var y = 0; y < _inputSize; y++) {
      for (var x = 0; x < _inputSize; x++) {
        final pixel = resizedImage.getPixel(x, y);
        // NCHW format
        input[0 * _inputSize * _inputSize + y * _inputSize + x] = pixel.r / 255.0;
        input[1 * _inputSize * _inputSize + y * _inputSize + x] = pixel.g / 255.0;
        input[2 * _inputSize * _inputSize + y * _inputSize + x] = pixel.b / 255.0;
      }
    }

    final inputReshaped = input.reshape([1, 3, _inputSize, _inputSize]);

    // Output shape [1, 10, 3549]
    // Each prediction is [x, y, w, h, cls0, ..., cls5]
    final output = List.filled(1 * 10 * 3549, 0.0).reshape([1, 10, 3549]);

    _interpreter!.run(inputReshaped, output);

    final predictions = <_Prediction>[];

    // Post-process
    for (var i = 0; i < 3549; i++) {
      // YOLOv8 output: cx, cy, w, h are at indices 0, 1, 2, 3
      final cx = output[0][0][i];
      final cy = output[0][1][i];
      final w = output[0][2][i];
      final h = output[0][3][i];

      double maxScore = -1.0;
      int classId = -1;

      for (var c = 0; c < 6; c++) {
        final score = output[0][4 + c][i];
        if (score > maxScore) {
          maxScore = score;
          classId = c;
        }
      }

      if (maxScore >= _confidenceThreshold) {
        // Return normalized coordinates (0.0 to 1.0)
        final left = (cx - w / 2) / _inputSize;
        final top = (cy - h / 2) / _inputSize;
        final width = w / _inputSize;
        final height = h / _inputSize;

        predictions.add(_Prediction(
          boundingBox: BoundingBox(
            x: left,
            y: top,
            width: width,
            height: height,
          ),
          confidence: maxScore,
          classId: classId,
          className: classId < _labels!.length ? _labels![classId] : 'Defect $classId',
        ));
      }
    }

    // Non-Max Suppression
    final nmsPredictions = _nms(predictions);

    return nmsPredictions.map((p) {
      return Defect(
        id: '${DateTime.now().millisecondsSinceEpoch}_${p.classId}_${p.confidence.toStringAsFixed(3)}',
        className: p.className,
        confidence: p.confidence,
        severity: _mapSeverity(p.className, p.confidence),
        location: '(${p.boundingBox.x.toInt()}, ${p.boundingBox.y.toInt()})',
        boundingBox: p.boundingBox,
      );
    }).toList();
  }

  List<_Prediction> _nms(List<_Prediction> predictions) {
    if (predictions.isEmpty) return [];
    
    predictions.sort((a, b) => b.confidence.compareTo(a.confidence));
    final selected = <_Prediction>[];
    final isRemoved = List.filled(predictions.length, false);

    for (var i = 0; i < predictions.length; i++) {
      if (isRemoved[i]) continue;
      
      selected.add(predictions[i]);
      
      for (var j = i + 1; j < predictions.length; j++) {
        if (isRemoved[j]) continue;
        
        if (_iou(predictions[i].boundingBox, predictions[j].boundingBox) > _iouThreshold) {
          isRemoved[j] = true;
        }
      }
    }
    return selected;
  }

  double _iou(BoundingBox a, BoundingBox b) {
    final x1 = max(a.x, b.x);
    final y1 = max(a.y, b.y);
    final x2 = min(a.x + a.width, b.x + b.width);
    final y2 = min(a.y + a.height, b.y + b.height);

    final intersectionArea = max(0.0, x2 - x1) * max(0.0, y2 - y1);
    final unionArea = (a.width * a.height) + (b.width * b.height) - intersectionArea;

    if (unionArea <= 0) return 0.0;
    return intersectionArea / unionArea;
  }

  DefectSeverity _mapSeverity(String className, double confidence) {
    // Simple mapping: High confidence or certain classes could be high severity
    if (confidence > 0.85) return DefectSeverity.high;
    if (className.toLowerCase().contains('short') || className.toLowerCase().contains('break')) {
      return DefectSeverity.high;
    }
    if (confidence > 0.6) return DefectSeverity.medium;
    return DefectSeverity.low;
  }
}

class _Prediction {
  final BoundingBox boundingBox;
  final double confidence;
  final int classId;
  final String className;

  _Prediction({
    required this.boundingBox,
    required this.confidence,
    required this.classId,
    required this.className,
  });
}
