import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/inspection.dart';

class InspectionListTile extends StatelessWidget {
  final Inspection inspection;
  final VoidCallback onTap;

  const InspectionListTile({
    super.key,
    required this.inspection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isPass = inspection.status == InspectionStatus.pass;
    
    final statusColor = isPass ? colorScheme.primary : colorScheme.error;
    final statusBgColor = isPass ? colorScheme.primaryContainer : colorScheme.errorContainer;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.08)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Status Icon with background
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: statusBgColor.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isPass ? Icons.check_circle_rounded : Icons.report_problem_rounded,
                      color: statusColor,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Inspection Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inspection.id,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 12, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd • HH:mm').format(inspection.timestamp),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isPass ? 'PASSED' : 'FAILED',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: isPass ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    if (!isPass) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${inspection.defectCount} DEFECTS',
                        style: TextStyle(
                          color: colorScheme.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, color: colorScheme.outline.withValues(alpha: 0.5), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
