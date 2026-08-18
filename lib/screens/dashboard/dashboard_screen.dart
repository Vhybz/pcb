import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/inspection_list_tile.dart';
import '../../services/app_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      appState.fetchProfile();
      appState.fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final stats = appState.stats;
    final recentInspections = appState.history.take(3).toList();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Elegant Header with Profile
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            centerTitle: false,
            scrolledUnderElevation: 2,
            backgroundColor: colorScheme.surface,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<AppState>(
                  builder: (context, appState, _) => Text(
                    'Welcome, ${appState.userProfile?['username'] ?? 'User'}',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  ),
                ),
                Text(
                  'PCB Inspector AI • Live',
                  style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ],
            ),
            actions: [
              _buildNotificationIcon(colorScheme),
              const SizedBox(width: 8),
              _buildAppBarProfile(context, colorScheme),
              const SizedBox(width: 16),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildWelcomeHero(context, theme),
                const SizedBox(height: 32),
                
                _buildSectionTitle(theme, 'Quick Access'),
                const SizedBox(height: 16),
                _buildActionGrid(context, colorScheme),
                const SizedBox(height: 32),

                _buildSectionTitle(theme, 'Performance Analytics'),
                const SizedBox(height: 16),
                _buildStatsGrid(stats),
                const SizedBox(height: 32),

                _buildSectionTitle(theme, 'Productivity Trend'),
                const SizedBox(height: 16),
                _buildTrendCard(context, colorScheme),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle(theme, 'Recent Activity'),
                    TextButton.icon(
                      onPressed: () => context.go('/history'),
                      icon: const Icon(Icons.history_rounded, size: 16),
                      label: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...recentInspections.map((inspection) => InspectionListTile(
                  inspection: inspection,
                  onTap: () => context.push('/result'),
                )),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarProfile(BuildContext context, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () => context.push('/profile'),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2), width: 1.5),
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: colorScheme.primaryContainer,
          child: const Icon(Icons.person_rounded, size: 20),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(ColorScheme colorScheme) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => context.push('/notifications'),
        ),
        Positioned(
          right: 12,
          top: 12,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colorScheme.error,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.surface, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHero(BuildContext context, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/img_1.png',
                width: 140,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'READY TO SCAN',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
                ),
                const SizedBox(height: 12),
                Text(
                  'Improve Yield with\nPrecision AI',
                  style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, height: 1.2),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () => _showInspectionOptions(context),
                  icon: const Icon(Icons.analytics_outlined, size: 18),
                  label: const Text('Start Inspection'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInspectionOptions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Choose Inspection Mode',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Select how you want to analyze the board',
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            _buildModeOption(
              context,
              icon: Icons.now_widgets_rounded,
              title: 'Real-time Scanner',
              subtitle: 'Use live camera feed with AI overlay',
              color: Colors.blue,
              onTap: () {
                context.pop();
                context.push('/scanner');
              },
            ),
            const SizedBox(height: 16),
            _buildModeOption(
              context,
              icon: Icons.cloud_upload_rounded,
              title: 'Upload Image',
              subtitle: 'Select a photo from your gallery',
              color: Colors.purple,
              onTap: () async {
                context.pop();
                final ImagePicker picker = ImagePicker();
                try {
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null && context.mounted) {
                    final bytes = await image.readAsBytes();
                    if (context.mounted) {
                      context.push('/analysis', extra: {
                        'path': image.path,
                        'bytes': bytes,
                      });
                    }
                  }
                } catch (e) {
                  debugPrint('Error picking image: $e');
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildModeOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: colorScheme.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w800,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(
          context,
          Icons.collections_bookmark_rounded,
          'Gallery',
          onTap: () async {
            final ImagePicker picker = ImagePicker();
            try {
              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null && context.mounted) {
                final bytes = await image.readAsBytes();
                if (context.mounted) {
                  context.push('/analysis', extra: {
                    'path': image.path,
                    'bytes': bytes,
                  });
                }
              }
            } catch (e) {
              debugPrint('Error picking image: $e');
            }
          },
        ),
        _buildActionItem(context, Icons.analytics_rounded, 'Stats'),
        _buildActionItem(context, Icons.person_rounded, 'Account', onTap: () => context.push('/profile')),
        _buildActionItem(context, Icons.help_center_rounded, 'Help'),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label, {VoidCallback? onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.05)),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        StatCard(
          title: 'Total Scans',
          value: stats['total'].toString(),
          icon: Icons.qr_code_scanner_rounded,
          iconColor: Colors.blue,
        ),
        StatCard(
          title: 'Defect Rate',
          value: '${stats['defectRate']}%',
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildTrendCard(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Weekly Efficiency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '+12.5%',
                  style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final heights = [40.0, 60.0, 30.0, 80.0, 50.0, 70.0, 95.0];
              return Container(
                width: 20,
                height: heights[index],
                decoration: BoxDecoration(
                  color: index == 6 ? colorScheme.primary : colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
