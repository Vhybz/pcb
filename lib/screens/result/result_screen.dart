import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/inspection.dart';
import '../../models/defect.dart';
import '../../services/app_state.dart';
import '../../widgets/defect_list_tile.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final inspection = appState.lastInspection ?? (appState.history.isNotEmpty ? appState.history.first : null);
    
    if (inspection == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('No Data')),
        body: const Center(child: Text('No inspection data found.')),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isPassed = inspection.status == InspectionStatus.pass;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 80,
            pinned: true,
            leading: IconButton.filledTonal(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => context.go('/dashboard'),
            ),
            title: const Text('Analysis Report', style: TextStyle(fontWeight: FontWeight.w900)),
            backgroundColor: colorScheme.surface,
            actions: [
              IconButton.filledTonal(
                icon: const Icon(Icons.share_rounded, size: 20),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // PCB Image Section with Bounding Boxes
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          _buildImageDisplay(inspection.imageUrl),
                          
                          // Actual Bounding Boxes
                          if (inspection.defects.isNotEmpty)
                            ...inspection.defects.map((defect) {
                              // These coordinates need to be scaled if the image is scaled
                              // For simplicity, we assume the detector returns normalized or mapped coords
                              // Let's use a CustomPaint for better scaling or use Positioned with Image scale
                              return _BoundingBoxWidget(
                                defect: defect,
                                colorScheme: colorScheme,
                              );
                            }),
                          
                          // Image Label
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: const Text(
                                'PROCESSED IMAGE',
                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                
                // Status Summary Banner
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isPassed ? AppColors.successContainer : AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: (isPassed ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isPassed ? AppColors.success : AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(isPassed ? Icons.verified_user_rounded : Icons.gpp_bad_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPassed ? 'BOARD CLEARED' : 'ACTION REQUIRED',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: (isPassed ? AppColors.success : AppColors.error).withValues(alpha: 0.6),
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isPassed ? 'Inspection PASSED' : '${inspection.defectCount} DEFECTS FOUND',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: isPassed ? AppColors.success : AppColors.error,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                if (!isPassed) ...[
                  Row(
                    children: [
                      const Text(
                        'Detailed Defect List',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      const Spacer(),
                      Text(
                        'SORT BY SEVERITY',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...inspection.defects.map((defect) => DefectListTile(
                    defect: defect,
                    onTap: () => context.push('/defect-details'),
                  )),
                  const SizedBox(height: 32),
                ],
                
                // Final Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/dashboard'),
                        icon: const Icon(Icons.home_max_rounded),
                        label: const Text('DASHBOARD'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.picture_as_pdf_rounded),
                        label: const Text('GENERATE PDF'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageDisplay(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: double.infinity,
        height: 300,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
    }
    
    if (kIsWeb || imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        height: 300,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
    }

    return Image.file(
      File(imageUrl),
      width: double.infinity,
      height: 300,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: double.infinity,
      height: 300,
      color: Colors.grey[900],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_rounded, color: Colors.white24, size: 48),
          SizedBox(height: 12),
          Text('Failed to load board image', style: TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }
}

class _BoundingBoxWidget extends StatelessWidget {
  final Defect defect;
  final ColorScheme colorScheme;

  const _BoundingBoxWidget({super.key, required this.defect, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    // We need the actual rendered size of the image to scale correctly.
    // BoxFit.contain makes this a bit tricky.
    // For a real-world app, we'd use a CustomPainter or a more precise layout.
    // For now, let's assume the image takes the full 300 height and scales width accordingly.
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Simple scaling assuming BoxFit.contain and 300 height
        const double displayHeight = 300;
        final double displayWidth = constraints.maxWidth;
        
        // This is a simplification. In a real app, you'd calculate the actual image aspect ratio.
        final double left = defect.boundingBox.x * displayWidth;
        final double top = defect.boundingBox.y * displayHeight;
        final double width = defect.boundingBox.width * displayWidth;
        final double height = defect.boundingBox.height * displayHeight;

        return Positioned(
          left: left,
          top: top,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(4),
              color: Colors.red.withValues(alpha: 0.1),
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                color: Colors.red,
                child: Text(
                  defect.className.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}
