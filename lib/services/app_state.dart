import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/inspection.dart';
import '../models/defect.dart';
import 'detection_service.dart';
import 'supabase_service.dart';
import 'notification_service.dart';

class AppState extends ChangeNotifier {
  final DetectionService detectionService;
  final SupabaseService supabaseService = SupabaseService();
  final NotificationService notificationService = NotificationService();
  List<CameraDescription> _cameras = [];
  
  List<Inspection> _history = [];
  Inspection? _lastInspection;
  bool _isAnalyzing = false;
  ThemeMode _themeMode = ThemeMode.system;

  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? get userProfile => _userProfile;

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Real-time detection results
  List<Defect> _liveDefects = [];
  List<Defect> get liveDefects => _liveDefects;
  
  AppState({required this.detectionService}) {
    _currentUser = supabaseService.currentUser;
    if (_currentUser != null) {
      fetchProfile();
      fetchHistory();
      notificationService.initialize();
    }
    
    supabaseService.onAuthStateChange((event, session) {
      _currentUser = session?.user;
      if (event == AuthChangeEvent.signedIn) {
        fetchProfile();
        fetchHistory();
        notificationService.initialize();
      } else if (event == AuthChangeEvent.signedOut) {
        _userProfile = null;
        _history = [];
      }
      notifyListeners();
    });
  }
  
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

  Future<void> fetchProfile() async {
    try {
      _userProfile = await supabaseService.getProfile();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  Future<void> updateProfilePicture(dynamic imageFile) async {
    try {
      final avatarUrl = await supabaseService.uploadAvatar(imageFile);
      if (avatarUrl != null) {
        await supabaseService.updateProfile(avatarUrl: avatarUrl);
        await fetchProfile();
      }
    } catch (e) {
      debugPrint('Error updating avatar: $e');
    }
  }

  Future<void> fetchHistory() async {
    try {
      final historyData = await supabaseService.getHistory();
      _history = historyData.map((data) {
        final List defectList = data['defects'] ?? [];
        return Inspection(
          id: data['id'].toString().substring(0, 8).toUpperCase(),
          timestamp: DateTime.parse(data['timestamp']),
          status: data['status'] == 'pass' ? InspectionStatus.pass : InspectionStatus.fail,
          imageUrl: data['image_url'],
          defects: defectList.map((d) {
            final bbox = d['bounding_box'];
            return Defect(
              id: d['id'].toString(),
              className: d['class_name'],
              confidence: (d['confidence'] as num).toDouble(),
              severity: DefectSeverity.values.firstWhere(
                (s) => s.name == d['severity'],
                orElse: () => DefectSeverity.medium,
              ),
              location: d['location_info'] ?? 'Unknown',
              boundingBox: BoundingBox(
                x: (bbox['x'] as num).toDouble(),
                y: (bbox['y'] as num).toDouble(),
                width: (bbox['w'] as num).toDouble(),
                height: (bbox['h'] as num).toDouble(),
              ),
            );
          }).toList(),
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching history: $e');
    }
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

  void updateLiveDefects(List<Defect> defects) {
    _liveDefects = defects;
    notifyListeners();
  }

  Future<Inspection> runDetection(String imagePath) async {
    _isAnalyzing = true;
    notifyListeners();
    
    try {
      // 1. Local AI Inference
      final defects = await detectionService.detect(imagePath);
      
      // 2. Prepare Inspection Model
      final inspection = Inspection(
        id: "TEMP", // Will be replaced by DB ID
        timestamp: DateTime.now(),
        status: defects.isEmpty ? InspectionStatus.pass : InspectionStatus.fail,
        defects: defects,
        imageUrl: imagePath,
      );

      // 3. Upload and Save to Supabase (Persistence)
      await supabaseService.saveInspection(inspection, imagePath);
      
      // 4. Update local state
      await fetchHistory(); // Refresh history from DB
      if (_history.isNotEmpty) {
        _lastInspection = _history.first;
      } else {
        _lastInspection = inspection; // Fallback to local if history fetch failed/empty
      }
      
      return _lastInspection!;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }
}
