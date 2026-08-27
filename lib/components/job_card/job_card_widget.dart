import 'package:degloor_one/core/degloor_theme.dart';
import 'package:flutter/material.dart';

class JobCardWidget extends StatelessWidget {
  const JobCardWidget({
    super.key,
    required this.title,
    required this.companyName,
    required this.location,
    required this.salary,
    required this.jobType,
    required this.onActionPressed,
    this.actionText = 'Apply Now',
    this.showAction = true,
    this.isUrgent = false,
  });

  final String title;
  final String companyName;
  final String location;
  final String salary;
  final String jobType;
  final String actionText;
  final bool showAction;
  final bool isUrgent;
  final Future Function() onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
        border: Border.all(color: DegloorTheme.border),
        boxShadow: DegloorTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(DegloorTheme.spacingMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildJobTypeBadge(jobType),
                    if (isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: DegloorTheme.error.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(DegloorTheme.radiusSM),
                        ),
                        child: Text(
                          'URGENT',
                          style: DegloorTheme.labelSmall.copyWith(
                            color: DegloorTheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(title,
                    style: DegloorTheme.headingMedium.copyWith(fontSize: 18)),
                const SizedBox(height: 4),
                Text(companyName, style: DegloorTheme.bodyLarge.copyWith(color: DegloorTheme.primary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: DegloorTheme.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(child: Text(location, style: DegloorTheme.bodySmall)),
                    const Icon(Icons.payments_outlined, size: 16, color: DegloorTheme.success),
                    const SizedBox(width: 4),
                    Text(salary, style: DegloorTheme.bodySmall.copyWith(color: DegloorTheme.success, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          if (showAction)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ElevatedButton(
                onPressed: () async => await onActionPressed(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DegloorTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DegloorTheme.radiusMD)),
                ),
                child: Text(actionText, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildJobTypeBadge(String type) {
    Color color;
    switch (type.toLowerCase()) {
      case 'full-time':
        color = const Color(0xFF1E88E5); // Keep specific blue
        break;
      case 'part-time':
        color = DegloorTheme.success;
        break;
      case 'daily wage':
        color = DegloorTheme.warning;
        break;
      default:
        color = DegloorTheme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DegloorTheme.radiusSM),
      ),
      child: Text(
        type.toUpperCase(),
        style: DegloorTheme.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
