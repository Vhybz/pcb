import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Project Insights',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton.filledTonal(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () => context.read<AppState>().toggleTheme(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroHeader(context, theme, colorScheme),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInstitutionalSection(context, colorScheme),
                  const SizedBox(height: 40),
                  
                  _buildSectionHeader(theme, 'Overview'),
                  const SizedBox(height: 16),
                  _buildOverviewCard(colorScheme, theme),
                  const SizedBox(height: 40),

                  _buildSectionHeader(theme, 'Project Supervisor'),
                  const SizedBox(height: 16),
                  _buildProfileCard(
                    context,
                    name: 'Uwumborinan Nanjo Joseph',
                    role: 'Lead Supervisor',
                    subRole: 'Engineering Department',
                    imagePath: 'assets/authors/Uwumborinan nanjo Joseph.png',
                    colorScheme: colorScheme,
                    isSupervisor: true,
                  ),
                  const SizedBox(height: 40),

                  _buildSectionHeader(theme, 'Development Team'),
                  const SizedBox(height: 16),
                  _buildProfileCard(
                    context,
                    name: 'Attah Godwin',
                    role: 'Hardware Systems & AI',
                    subRole: 'Index: STUBTECH 22793',
                    imagePath: 'assets/authors/STUBTECH 22793 Attah Godwin.png',
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 12),
                  _buildProfileCard(
                    context,
                    name: 'YAHAYA ABDUL-RAHIM',
                    role: 'Lead Mobile Developer',
                    subRole: 'Index: STUBTECH243273',
                    imagePath: 'assets/authors/YAHAYA ABDUL-RAHIM STUBTECH243273.png',
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 12),
                  _buildProfileCard(
                    context,
                    name: 'Munankpa Emmanuel Bachol',
                    role: 'Quality Assurance & UI/UX',
                    subRole: 'Index: Stubtech220432',
                    imagePath: 'assets/authors/Munankpa Emmanuel Bachol  Stubtech220432.png',
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 48),

                  _buildFooter(theme, colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              image: const DecorationImage(
                image: AssetImage('assets/images/img_1.png'),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'PCB Inspector AI',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'FINAL YEAR PROJECT 2026',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSecondaryContainer,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstitutionalSection(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        _buildCompactInfoTile(
          icon: Icons.school_rounded,
          title: 'Sunyani Technical University',
          subtitle: 'Leading Institution in Technology',
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCompactInfoTile(
                icon: Icons.engineering_rounded,
                title: 'Engineering',
                subtitle: 'Faculty',
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCompactInfoTile(
                icon: Icons.electric_bolt_rounded,
                title: 'Electrical',
                subtitle: 'Department',
                colorScheme: colorScheme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_fix_high_rounded, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              const Text('Innovation Mission', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Developing a robust AI framework to bridge the gap between manual PCB inspection and modern industrial automation. This system utilizes customized YOLO architectures for millisecond detection precision.',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context, {
    required String name,
    required String role,
    required String subRole,
    required String imagePath,
    required ColorScheme colorScheme,
    bool isSupervisor = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSupervisor ? colorScheme.primaryContainer.withOpacity(0.1) : colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSupervisor ? colorScheme.primary.withOpacity(0.2) : colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Styled Circular Avatar
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSupervisor ? colorScheme.primary : colorScheme.primary.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isSupervisor ? colorScheme.primary : Colors.black).withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.person_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: 32,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (isSupervisor)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified_rounded, color: Colors.white, size: 12),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subRole,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        children: [
          const Divider(thickness: 0.5),
          const SizedBox(height: 24),
          Text(
            '© 2026 Sunyani Technical University',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.8),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Faculty of Engineering • Electrical Dept.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
