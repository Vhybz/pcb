import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';

class AnalysisScreen extends StatefulWidget {
  final String? imagePath;
  const AnalysisScreen({super.key, this.imagePath});

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

    _startAnalysis();
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
    
    // Step 1: Inference & Persistence
    await appState.runDetection(path);

    if (mounted) {
      setState(() {
        _statusText = 'Syncing to Cloud...';
        _subStatusText = 'Uploading report to Supabase';
        _progress = 0.90;
      });
    }
    
    // Brief pause to simulate upload sync if it was too fast
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
    return Opacity(
      opacity: 0.1,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/circuit_pattern.png'), // Fallback to empty if not found
            repeat: ImageRepeat.repeat,
            onError: (e, s) {},
          ),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 20),
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.blue.withValues(alpha: 0.1), width: 0.5)),
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
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1), width: 8),
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
                color: colorScheme.primary.withValues(alpha: 0.05 + (_controller.value * 0.05)),
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 30 * _controller.value,
                    spreadRadius: 5 * _controller.value,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.psychology_rounded,
                  size: 80,
                  color: colorScheme.primary.withValues(alpha: 0.8),
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
            color: Colors.white.withValues(alpha: 0.4),
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
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary.withValues(alpha: 0.5), colorScheme.primary],
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(color: colorScheme.primary.withValues(alpha: 0.5), blurRadius: 10),
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
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
          color: Colors.greenAccent.withValues(alpha: 0.5),
          fontSize: 10,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
