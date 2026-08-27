import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'stat_card2_model.dart';
export 'stat_card2_model.dart';

class StatCard2Widget extends StatefulWidget {
  const StatCard2Widget({
    super.key,
    String? label,
    String? trend,
    String? value,
    bool? isPositive,
  })  : label = label ?? 'Pending Claims',
        trend = trend ?? '+3',
        value = value ?? '12',
        isPositive = isPositive ?? false;

  final String label;
  final String trend;
  final String value;
  final bool isPositive;

  @override
  State<StatCard2Widget> createState() => _StatCard2WidgetState();
}

class _StatCard2WidgetState extends State<StatCard2Widget> {
  late StatCard2Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StatCard2Model());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DegloorTheme.cardBackground,
        borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
        border: Border.all(color: DegloorTheme.border),
        boxShadow: DegloorTheme.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: DegloorTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  widget.value,
                  style: DegloorTheme.headingMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.trend.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: widget.isPositive
                          ? DegloorTheme.success.withValues(alpha: 0.1)
                          : DegloorTheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        widget.trend,
                        style: DegloorTheme.labelSmall.copyWith(
                          color: widget.isPositive
                              ? DegloorTheme.success
                              : DegloorTheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
