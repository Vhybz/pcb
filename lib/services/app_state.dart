import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/inspection.dart';
import 'detection_service.dart';

class AppState extends ChangeNotifier {
  final DetectionService detectionService;
  List<CameraDescription> _cameras = [];
  
  List<Inspection> _history = [];
  Inspection? _lastInspection;
  bool _isAnalyzing = false;
  ThemeMode _themeMode = ThemeMode.system;
  
  AppState({required this.detectionService});
  
  List<CameraDescription> get cameras => _cameras;
  List<Inspection> get history => _history;
  Inspection? get lastInspection => _lastInspection;
  bool get isAnalyzing => _isAnalyzing;
  ThemeMode get themeMode => _themeMode;

  void setCameras(List<CameraDescription> cameras) {
    _cameras = cameras;
    notifyListeners();
  }

  Map<String, dynamic> get stats {
    final total = _history.length;
    final passed = _history.where((i) => i.status == InspectionStatus.pass).length;
    final failed = total - passed;
    final defectRate = total > 0 ? (failed / total * 100).toInt() : 0;
    
    return {
      "total": total,
      "passed": passed,
      "failed": failed,
      "defectRate": defectRate,
    };
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void addInspection(Inspection inspection) {
    _history.insert(0, inspection);
    _lastInspection = inspection;
    notifyListeners();
  }

  Future<Inspection> runDetection(String imagePath) async {
    _isAnalyzing = true;
    notifyListeners();
    
    try {
      final defects = await detectionService.detect(imagePath);
      
      final inspection = Inspection(
        id: "PCB-${129 + _history.length}",
        timestamp: DateTime.now(),
        status: defects.isEmpty ? InspectionStatus.pass : InspectionStatus.fail,
        defects: defects,
        imageUrl: imagePath,
      );
      
      addInspection(inspection);
      return inspection;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }
}
