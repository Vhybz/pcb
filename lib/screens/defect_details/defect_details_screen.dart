import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/defect.dart';

class DefectDetailsScreen extends StatelessWidget {
  const DefectDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mocking the "Missing Component" defect for detail view
    final defect = Defect(
      id: "d1",
      className: "Missing Component",
      confidence: 0.964,
      severity: DefectSeverity.high,
      location: "Top-Left Quadrant (R12)",
      boundingBox: BoundingBox(x: 50, y: 50, width: 100, height: 100),
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            leading: IconButton.filledTonal(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.black,
                    child: Center(
                      child: Icon(
                        Icons.memory_rounded, 
                        size: 180, 
                        color: colorScheme.error.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  // Close-up "Scanner" zoom effect
                  Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.error, width: 3),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: colorScheme.error.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 5)
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Text(
                        'MACRO_ZOOM: 12.5x',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'CRITICAL DEFECT',
                              style: TextStyle(color: colorScheme.error, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            defect.className,
                            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 32),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'A critical hardware failure detected where a required SMD component is absent from the specified coordinates. This results in an open circuit condition.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 40),
                
                _buildSectionHeader('Analytical Data'),
                const SizedBox(height: 16),
                _buildMetricGrid(colorScheme, defect),
                
                const SizedBox(height: 40),
                
                _buildSectionHeader('Engineering Recommendation'),
                const SizedBox(height: 16),
                _buildRecommendationCard(colorScheme, theme),
                
                const SizedBox(height: 48),
                
                FilledButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.assignment_turned_in_rounded),
                  label: const Text('CONFIRM REVIEW'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 64),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    backgroundColor: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontWeight: FontWeight.w900, 
        fontSize: 11, 
        letterSpacing: 2,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildMetricGrid(ColorScheme colorScheme, Defect defect) {
    return Row(
      children: [
        _buildMetricItem(colorScheme, 'CONFIDENCE', '${(defect.confidence * 100).toStringAsFixed(1)}%', Icons.verified_user_rounded),
        const SizedBox(width: 12),
        _buildMetricItem(colorScheme, 'SEVERITY', 'HIGH_PRIO', Icons.priority_high_rounded),
      ],
    );
  }

  Widget _buildMetricItem(ColorScheme colorScheme, String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary, size: 20),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            Text(
              label,
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(ColorScheme colorScheme, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Corrective Action',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '1. Halt assembly line section #4\n2. Re-verify feeder unit calibration\n3. Manual resolder required for board unit R12\n4. Perform post-repair 3D inspection',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
