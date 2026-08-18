import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/app_state.dart';
import '../../models/defect.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with TickerProviderStateMixin {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  int _selectedCameraIndex = 0;
  bool isFlashOn = false;
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 4.0;
  
  late AnimationController _scannerController;
  late AnimationController _pulseController;

  bool _isDetecting = false;
  bool isLiveDetectionEnabled = true;
  DateTime _lastDetectionTime = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
    
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  Future<void> _initializeCamera() async {
    final appState = context.read<AppState>();
    
    // 1. Ensure camera list is fetched (no prompt yet on most platforms)
    await appState.ensureCamerasInitialized();
    
    // 2. Request explicit permission (This shows the OS prompt)
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (status != PermissionStatus.granted) return;

    final cameras = appState.cameras;
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras[_selectedCameraIndex],
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: kIsWeb ? ImageFormatGroup.jpeg : ImageFormatGroup.yuv420,
    );

    try {
      await _controller!.initialize();
      _minZoom = await _controller!.getMinZoomLevel();
      _maxZoom = await _controller!.getMaxZoomLevel();
      
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });

      if (!kIsWeb) {
        _controller!.startImageStream(_processCameraImage);
      }
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  Future<void> _switchCamera() async {
    final cameras = context.read<AppState>().cameras;
    if (cameras.length < 2) return;

    _selectedCameraIndex = (_selectedCameraIndex + 1) % cameras.length;
    
    if (_controller != null) {
      await _controller!.dispose();
      setState(() {
        _isCameraInitialized = false;
        isFlashOn = false; // Reset flash state when switching cameras
      });
    }
    
    await _initializeCamera();
    HapticFeedback.mediumImpact();
  }

  void _processCameraImage(CameraImage image) async {
    if (!isLiveDetectionEnabled || _isDetecting) return;
    if (DateTime.now().difference(_lastDetectionTime).inMilliseconds < 300) return;

    _isDetecting = true;
    _lastDetectionTime = DateTime.now();

    try {
      final appState = context.read<AppState>();
      final defects = await appState.detectionService.detectStream(image);
      if (mounted) {
        appState.updateLiveDefects(defects);
      }
    } catch (e) {
      debugPrint('Detection stream error: $e');
    } finally {
      _isDetecting = false;
    }
  }

  @override
  void dispose() {
    if (_controller?.value.isStreamingImages ?? false) {
      _controller?.stopImageStream();
    }
    _controller?.dispose();
    _scannerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_isCameraInitialized) return;
    try {
      final newFlashMode = isFlashOn ? FlashMode.off : FlashMode.torch;
      await _controller!.setFlashMode(newFlashMode);
      setState(() => isFlashOn = !isFlashOn);
      HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Flash error: $e');
    }
  }

  Future<void> _takePicture() async {
    HapticFeedback.heavyImpact();
    
    if (_controller?.value.isStreamingImages ?? false) {
      await _controller?.stopImageStream();
    }

    if (!mounted) return;

    if (_controller == null || !_isCameraInitialized) {
      context.push('/analysis');
      return;
    }

    try {
      setState(() => _isCameraInitialized = false);
      await Future.delayed(const Duration(milliseconds: 100));
      
      final XFile picture = await _controller!.takePicture();
      if (!mounted) return;
      context.push('/analysis', extra: picture.path); 
    } catch (e) {
      if (!mounted) return;
      context.push('/analysis');
    }
  }

  Future<void> _pickFromGallery() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        if (!mounted) return;
        context.push('/analysis', extra: {
          'path': image.path,
          'bytes': bytes,
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double frameWidth = size.width > size.height ? size.height * 0.5 : size.width * 0.85;
    final double frameHeight = size.width > size.height ? size.height * 0.35 : size.width * 0.65;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildCameraView(),
          _buildLiveDetections(),
          _buildGridOverlay(),
          _buildScanLine(frameHeight, frameWidth),
          _buildHUDOverlay(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildViewfinder(frameWidth, frameHeight),
                const SizedBox(height: 24),
                _buildAuraIndicator(),
              ],
            ),
          ),
          _buildZoomSlider(),
          _buildTopBar(),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildLiveDetections() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (appState.liveDefects.isEmpty) return const SizedBox.shrink();
        
        return CustomPaint(
          size: Size.infinite,
          painter: LiveBoundingBoxPainter(
            defects: appState.liveDefects,
            colorScheme: Theme.of(context).colorScheme,
          ),
        );
      },
    );
  }

  Widget _buildCameraView() {
    if (!_isCameraInitialized || _controller == null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF05070A),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 60,
                child: LinearProgressIndicator(backgroundColor: Colors.white10, color: Colors.blueAccent),
              ),
              const SizedBox(height: 20),
              Text('BOOTING SENSORS...', style: TextStyle(color: Colors.blue.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ],
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller!.value.previewSize!.height,
          height: _controller!.value.previewSize!.width,
          child: CameraPreview(_controller!),
        ),
      ),
    );
  }

  Widget _buildGridOverlay() {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.15,
        child: CustomPaint(
          size: Size.infinite,
          painter: TechnicalGridPainter(),
        ),
      ),
    );
  }

  Widget _buildHUDOverlay() {
    final cameras = context.read<AppState>().cameras;
    String camValue = "UNKNOWN";
    if (cameras.isNotEmpty && _selectedCameraIndex < cameras.length) {
      camValue = cameras[_selectedCameraIndex].lensDirection.name.toUpperCase();
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HUDLine(label: "STATUS", value: isLiveDetectionEnabled ? "REALTIME_ACTIVE" : "STANDBY", color: isLiveDetectionEnabled ? Colors.greenAccent : Colors.orangeAccent),
            const _HUDLine(label: "AI_VER", value: "YOLO_V8_PCB", color: Colors.blueAccent),
            _HUDLine(label: "CAMERA", value: camValue, color: Colors.blueAccent),
            Consumer<AppState>(
              builder: (context, appState, _) => _HUDLine(
                label: "LIVE_FIND", 
                value: appState.liveDefects.length.toString(), 
                color: appState.liveDefects.isNotEmpty ? Colors.redAccent : Colors.blueAccent
              ),
            ),
            const Spacer(),
            const _HUDLine(label: "BUFFER", value: "STREAMING", color: Colors.blueAccent),
            const _HUDLine(label: "ISO", value: "AUTO", color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildScanLine(double fh, double fw) {
    return Center(
      child: AnimatedBuilder(
        animation: _scannerController,
        builder: (context, child) {
          return SizedBox(
            width: fw,
            height: fh,
            child: Stack(
              children: [
                Positioned(
                  top: _scannerController.value * fh,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1.5,
                    decoration: BoxDecoration(
                      boxShadow: [BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 1)],
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildViewfinder(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
      ),
      child: Stack(
        children: [
          _buildCorner(Alignment.topLeft),
          _buildCorner(Alignment.topRight),
          _buildCorner(Alignment.bottomLeft),
          _buildCorner(Alignment.bottomRight),
          Center(
            child: FadeTransition(
              opacity: _pulseController,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.4), width: 1),
                ),
                child: const Icon(Icons.add, color: Colors.blueAccent, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment) {
    final bool isLeft = alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;
    final bool isTop = alignment == Alignment.topLeft || alignment == Alignment.topRight;
    return Align(
      alignment: alignment,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: Colors.blueAccent, width: 3) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: Colors.blueAccent, width: 3) : BorderSide.none,
            left: isLeft ? const BorderSide(color: Colors.blueAccent, width: 3) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: Colors.blueAccent, width: 3) : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: alignment == Alignment.topLeft ? const Radius.circular(12) : Radius.zero,
            topRight: alignment == Alignment.topRight ? const Radius.circular(12) : Radius.zero,
            bottomLeft: alignment == Alignment.bottomLeft ? const Radius.circular(12) : Radius.zero,
            bottomRight: alignment == Alignment.bottomRight ? const Radius.circular(12) : Radius.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildAuraIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: const Text('AUTO_DETECT: ENABLED', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
    );
  }

  Widget _buildZoomSlider() {
    return Positioned(
      right: 20,
      top: 0,
      bottom: 0,
      child: Center(
        child: RotatedBox(
          quarterTurns: 3,
          child: SizedBox(
            width: 150,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                activeTrackColor: Colors.blueAccent,
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.white,
                overlayColor: Colors.blueAccent.withValues(alpha: 0.2),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: _currentZoom,
                min: _minZoom,
                max: _maxZoom,
                onChanged: (val) async {
                  setState(() => _currentZoom = val);
                  await _controller?.setZoomLevel(val);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCircularButton(Icons.arrow_back_ios_new_rounded, () => context.pop()),
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('SYSTEM_SCAN', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 3)),
                Text('REALTIME_ENGINE_ACTIVE', style: TextStyle(color: Colors.greenAccent, fontSize: 8, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCircularButton(Icons.flip_camera_ios_rounded, _switchCamera),
                const SizedBox(width: 8),
                _buildCircularButton(isFlashOn ? Icons.bolt_rounded : Icons.bolt_outlined, _toggleFlash, active: isFlashOn),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSecondaryAction(Icons.photo_library_rounded, 'GALLERY', onTap: _pickFromGallery),
            _buildShutterButton(),
            _buildSecondaryAction(
              isLiveDetectionEnabled ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              'AI_LIVE',
              onTap: () {
                setState(() => isLiveDetectionEnabled = !isLiveDetectionEnabled);
                HapticFeedback.lightImpact();
              },
              active: isLiveDetectionEnabled,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton(IconData icon, VoidCallback onTap, {bool active = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? Colors.blueAccent.withValues(alpha: 0.4) : Colors.black38,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildSecondaryAction(IconData icon, String label, {required VoidCallback onTap, bool active = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCircularButton(icon, onTap, active: active),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildShutterButton() {
    return GestureDetector(
      onTap: _takePicture,
      child: Container(
        width: 84,
        height: 84,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 2),
        ),
        child: Container(
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: const Center(child: Icon(Icons.camera_rounded, color: Colors.black, size: 36)),
        ),
      ),
    );
  }
}

class _HUDLine extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HUDLine({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("$label:", style: TextStyle(color: color.withValues(alpha: 0.5), fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          const SizedBox(width: 8),
          Text(value, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

class TechnicalGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width.isInfinite || size.height.isInfinite) return;

    final paint = Paint()
      ..color = Colors.blueAccent.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    // Safety limit to prevent browser hang
    final int horizontalLines = (size.width / spacing).floor().clamp(0, 100);
    final int verticalLines = (size.height / spacing).floor().clamp(0, 100);

    for (int i = 0; i <= horizontalLines; i++) {
      double x = i * spacing;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (int i = 0; i <= verticalLines; i++) {
      double y = i * spacing;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class LiveBoundingBoxPainter extends CustomPainter {
  final List<Defect> defects;
  final ColorScheme colorScheme;

  LiveBoundingBoxPainter({required this.defects, required this.colorScheme});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var defect in defects) {
      final rect = Rect.fromLTWH(
        defect.boundingBox.x * size.width,
        defect.boundingBox.y * size.height,
        defect.boundingBox.width * size.width,
        defect.boundingBox.height * size.height,
      );

      canvas.drawRect(rect, paint);

      final labelPaint = Paint()..color = Colors.red;
      canvas.drawRect(
        Rect.fromLTWH(rect.left, rect.top - 15, defect.className.length * 7.0, 15),
        labelPaint,
      );

      textPainter.text = TextSpan(
        text: defect.className.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(rect.left + 2, rect.top - 14));
    }
  }

  @override
  bool shouldRepaint(LiveBoundingBoxPainter oldDelegate) => true;
}
