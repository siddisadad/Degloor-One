import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'stat_card_model.dart';
export 'stat_card_model.dart';

class StatCardWidget extends StatefulWidget {
  const StatCardWidget({
    super.key,
    bool? hasTrend,
    this.icon,
    String? label,
    String? trend,
    String? value,
  })  : hasTrend = hasTrend ?? true,
        label = label ?? 'Profile Views',
        trend = trend ?? '+12%',
        value = value ?? '1,284';

  final bool hasTrend;
  final Widget? icon;
  final String label;
  final String trend;
  final String value;

  @override
  State<StatCardWidget> createState() => _StatCardWidgetState();
}

class _StatCardWidgetState extends State<StatCardWidget> {
  late StatCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StatCardModel());
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.icon != null) widget.icon!,
                if (widget.hasTrend)
                  Flexible(
                    child: Text(
                      widget.trend,
                      maxLines: 1,
                      style: DegloorTheme.labelSmall.copyWith(
                        color: DegloorTheme.success,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.value,
              style: DegloorTheme.headingMedium.copyWith(
                color: DegloorTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.label,
              style: DegloorTheme.labelMedium.copyWith(
                color: DegloorTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
