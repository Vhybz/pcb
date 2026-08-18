import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'services/app_state.dart';
import 'services/detection_service.dart';
import 'services/detection_factory.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://gafuutafwztshomzrkws.supabase.co',
    publishableKey: 'sb_publishable_gZXnUk2d6jfzQagR67t5FQ_Qs5ckXuG',
  );

  // Choose service based on platform via factory
  final DetectionService detectionService = DetectionFactory.create();

  final appState = AppState(
    detectionService: detectionService,
  );

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const PCBDefectScannerApp(),
    ),
  );
}

class PCBDefectScannerApp extends StatefulWidget {
  const PCBDefectScannerApp({super.key});

  @override
  State<PCBDefectScannerApp> createState() => _PCBDefectScannerAppState();
}

class _PCBDefectScannerAppState extends State<PCBDefectScannerApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.createRouter(context.read<AppState>());
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<AppState>().themeMode;
    return MaterialApp.router(
      title: 'PCB Defect Scanner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
