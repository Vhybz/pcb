import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _confidenceThreshold = 0.5;
  bool _flashLight = true;
  bool _autoFocus = true;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 80,
            title: const Text('App Configuration', style: TextStyle(fontWeight: FontWeight.w900)),
            backgroundColor: colorScheme.surface,
            leading: IconButton.filledTonal(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton.filledTonal(
                icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                onPressed: () => appState.toggleTheme(),
              ),
              const SizedBox(width: 16),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader(context, 'AI Model Parameters'),
                const SizedBox(height: 16),
                _buildModelConfigCard(colorScheme),
                const SizedBox(height: 32),
                
                _buildSectionHeader(context, 'Device Interface'),
                const SizedBox(height: 16),
                _buildSettingsGroup(context, [
                  _buildSwitchRow(context, 'Hardware Flash', _flashLight, (val) => setState(() => _flashLight = val), Icons.flashlight_on_rounded),
                  _buildSwitchRow(context, 'Auto-Focus Assist', _autoFocus, (val) => setState(() => _autoFocus = val), Icons.filter_center_focus_rounded),
                ]),
                const SizedBox(height: 32),
                
                _buildSectionHeader(context, 'Support & Legal'),
                const SizedBox(height: 16),
                _buildSettingsGroup(context, [
                  _buildListRow(context, 'User Documentation', Icons.description_rounded, () {}),
                  _buildListRow(context, 'System Diagnostics', Icons.terminal_rounded, () {}),
                  _buildListRow(context, 'Privacy Standards', Icons.security_rounded, () {}),
                  _buildListRow(context, 'Version History', Icons.history_rounded, () {}),
                ]),
                const SizedBox(height: 40),
                
                _buildResetButton(colorScheme),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelConfigCard(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Inference Sensitivity', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '${(_confidenceThreshold * 100).toInt()}%',
                style: TextStyle(fontWeight: FontWeight.w900, color: colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: colorScheme.primary.withValues(alpha: 0.1),
              thumbColor: Colors.white,
              overlayColor: colorScheme.primary.withValues(alpha: 0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: _confidenceThreshold,
              min: 0.1,
              max: 0.9,
              onChanged: (val) => setState(() => _confidenceThreshold = val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w900, 
          fontSize: 11, 
          letterSpacing: 1.5,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, List<Widget> children) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _buildSwitchRow(BuildContext context, String title, bool value, Function(bool) onChanged, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: colorScheme.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildListRow(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: colorScheme.onSurfaceVariant, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildResetButton(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh_rounded, color: AppColors.error, size: 20),
                SizedBox(width: 12),
                Text(
                  'RESET APPLICATION DATA',
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
