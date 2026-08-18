import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'services/app_state.dart';
import 'services/detection_service.dart';
import 'services/tflite_detection_service.dart';
import 'services/http_detection_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize cameras
  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('Error fetching cameras: $e');
  }

  // Choose service based on platform
  final DetectionService detectionService = kIsWeb 
    ? HttpDetectionService(apiUrl: 'https://your-pcb-backend.onrender.com') 
    : TfliteDetectionService();

  final appState = AppState(
    detectionService: detectionService,
  );
  appState.setCameras(cameras);

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const PCBDefectScannerApp(),
    ),
  );
}

class PCBDefectScannerApp extends StatelessWidget {
  const PCBDefectScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<AppState>().themeMode;
    return MaterialApp.router(
      title: 'PCB Defect Scanner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
