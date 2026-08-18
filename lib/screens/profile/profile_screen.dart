import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final appState = context.watch<AppState>();

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 80,
            title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.w900)),
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
                _buildHeroProfile(context, colorScheme),
                const SizedBox(height: 32),
                
                _buildSectionHeader(context, 'Professional Identity'),
                const SizedBox(height: 16),
                _buildInfoGroup(colorScheme, [
                  _buildInfoRow(colorScheme, 'Employee ID', 'STU-EEE-2026-08', Icons.badge_outlined),
                  _buildInfoRow(colorScheme, 'Designation', 'Senior Industrial Inspector', Icons.work_outline_rounded),
                  _buildInfoRow(colorScheme, 'Department', 'Electrical & Electronics', Icons.electrical_services_rounded),
                ]),
                
                const SizedBox(height: 32),
                _buildSectionHeader(context, 'Activity Summary'),
                const SizedBox(height: 16),
                _buildStatsRow(appState, colorScheme),
                
                const SizedBox(height: 32),
                _buildSectionHeader(context, 'Account Actions'),
                const SizedBox(height: 16),
                _buildActionCard(colorScheme, 'Security Settings', 'Update password and biometrics', Icons.security_rounded),
                const SizedBox(height: 12),
                _buildActionCard(colorScheme, 'Notification Preferences', 'Manage alert levels', Icons.notifications_active_outlined),
                
                const SizedBox(height: 40),
                _buildLogoutButton(colorScheme),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroProfile(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primary, width: 3),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: colorScheme.primary,
              child: const Text('JD', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'John Doe',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'ADMINISTRATOR',
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
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
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5, color: Colors.grey),
      ),
    );
  }

  Widget _buildInfoGroup(ColorScheme colorScheme, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(ColorScheme colorScheme, String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: colorScheme.primary, size: 20),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildStatsRow(AppState appState, ColorScheme colorScheme) {
    final stats = appState.stats;
    return Row(
      children: [
        _buildStatItem(colorScheme, 'TOTAL SCANS', stats['total'].toString()),
        const SizedBox(width: 12),
        _buildStatItem(colorScheme, 'ACCURACY', '98.2%'),
      ],
    );
  }

  Widget _buildStatItem(ColorScheme colorScheme, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(ColorScheme colorScheme, String title, String subtitle, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: colorScheme.primary, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      ),
    );
  }

  Widget _buildLogoutButton(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.error.withOpacity(0.1)),
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
                Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                SizedBox(width: 12),
                Text(
                  'LOGOUT ACCOUNT',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
