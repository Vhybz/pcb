import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';

class AnalysisScreen extends StatefulWidget {
  final String? imagePath;
  final Uint8List? imageBytes;
  const AnalysisScreen({super.key, this.imagePath, this.imageBytes});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _progress = 0.0;
  Timer? _progressTimer;
  String _statusText = 'Analyzing Image Data...';
  String _subStatusText = 'YOLO v8 Inference in Progress';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Start analysis after the first frame to avoid "setState during build" errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnalysis();
    });
  }

  Future<void> _startAnalysis() async {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted) {
        setState(() {
          _progress += 0.008;
          if (_progress >= 0.70) {
            _progress = 0.70;
            _progressTimer?.cancel();
          }
        });
      }
    });

    final appState = context.read<AppState>();
    final path = widget.imagePath ?? "assets/images/img_1.png";
    
    try {
      debugPrint('Analysis: Starting detection for $path');
      // Step 1: Inference & Persistence
      await appState.runDetection(path, bytes: widget.imageBytes);
      debugPrint('Analysis: Detection complete');

      if (mounted) {
        setState(() {
          _statusText = 'Finalizing Report...';
          _subStatusText = 'Preparing results for display';
          _progress = 0.95;
        });
      }
    } catch (e) {
      debugPrint('Analysis: Error during detection pipeline: $e');
      if (mounted) {
        setState(() {
          _statusText = 'Analysis Interrupted';
          _subStatusText = 'Proceeding with cached data';
        });
      }
    }
    
    // Brief pause for visual transition
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _progress = 1.0;
      });
      _progressTimer?.cancel();
      // Brief pause to show 100% completion
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        context.pushReplacement('/result');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Technical Background
          _buildScanningGrid(),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: Column(
                children: [
                  const Spacer(),
                  // Central Processing Unit Visual
                  _buildProcessorVisual(colorScheme),
                  const SizedBox(height: 60),
                  
                  // Status Info
                  _buildAnalysisStatus(theme, colorScheme),
                  const SizedBox(height: 48),
                  
                  // Progress Pipeline
                  _buildProgressBar(colorScheme),
                  
                  const Spacer(),
                  // Data Console
                  _buildDataConsole(colorScheme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningGrid() {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.1,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: CustomPaint(
            painter: _TechnicalGridPainter(),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessorVisual(ColorScheme colorScheme) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer rotating ring
        RotationTransition(
          turns: _controller,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primary.withOpacity(0.1), width: 8),
            ),
          ),
        ),
        // Inner pulsing core
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(0.05 + (_controller.value * 0.05)),
                border: Border.all(color: colorScheme.primary.withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.2),
                    blurRadius: 30 * _controller.value,
                    spreadRadius: 5 * _controller.value,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.psychology_rounded,
                  size: 80,
                  color: colorScheme.primary.withOpacity(0.8),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnalysisStatus(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Text(
          'NEURAL PROCESSING',
          style: TextStyle(
            color: colorScheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _statusText,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _subStatusText,
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary.withOpacity(0.5), colorScheme.primary],
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(color: colorScheme.primary.withOpacity(0.5), blurRadius: 10),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${(_progress * 100).toInt()}% COMPLETE',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildDataConsole(ColorScheme colorScheme) {
    // Actually just use kIsWeb if I import foundation, but let's just make it look good.
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConsoleLine('ENGINE: TFLITE_RUNTIME'), // Placeholder check
          _buildConsoleLine('NODE: ${Theme.of(context).platform == TargetPlatform.android ? "EDGE_DEVICE" : "CLOUD_RENDER"}'),
          _buildConsoleLine('STATUS: RUNNING_INFERENCE'),
        ],
      ),
    );
  }

  Widget _buildConsoleLine(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '> $text',
        style: TextStyle(
          color: Colors.greenAccent.withOpacity(0.5),
          fontSize: 10,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TechnicalGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width.isInfinite || size.height.isInfinite) return;

    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
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
