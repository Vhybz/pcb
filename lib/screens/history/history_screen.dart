import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/app_state.dart';
import '../../widgets/inspection_list_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final history = appState.history;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('Inspection Logs', style: TextStyle(fontWeight: FontWeight.w900)),
            backgroundColor: colorScheme.surface,
            scrolledUnderElevation: 2,
            actions: [
              IconButton.filledTonal(
                icon: const Icon(Icons.search_rounded, size: 20),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
            ],
          ),
          SliverToBoxAdapter(
            child: _buildFilterSection(colorScheme),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: history.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState(colorScheme, theme))
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => InspectionListTile(
                        inspection: history[index],
                        onTap: () => context.push('/result'),
                      ),
                      childCount: history.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(ColorScheme colorScheme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _buildFilterChip('All'),
          const SizedBox(width: 10),
          _buildFilterChip('Passed'),
          const SizedBox(width: 10),
          _buildFilterChip('Failed'),
          const SizedBox(width: 10),
          _buildFilterChip('Latest'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    final colorScheme = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => setState(() => selectedFilter = label),
      showCheckmark: false,
      selectedColor: colorScheme.primary,
      backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide.none,
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inventory_2_outlined, size: 64, color: colorScheme.primary.withOpacity(0.2)),
        const SizedBox(height: 24),
        Text(
          'No Inspections Yet',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Complete a scan to see records here',
          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
