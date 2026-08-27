import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_icon_button.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'action_item_model.dart';
export 'action_item_model.dart';

class ActionItemWidget extends StatefulWidget {
  const ActionItemWidget({
    super.key,
    this.icon,
    Color? statusBg,
    String? statusLabel,
    Color? statusText,
    String? subtitle,
    String? title,
    this.onApprove,
    this.onReject,
  })  : statusBg = statusBg ?? const Color(0xFFFFF3E0),
        statusLabel = statusLabel ?? 'PENDING',
        statusText = statusText ?? const Color(0xFFE65100),
        subtitle = subtitle ?? 'Claimed by: Rajesh K.',
        title = title ?? 'Kulkarni Hardware';

  final Widget? icon;
  final Color statusBg;
  final String statusLabel;
  final Color statusText;
  final String subtitle;
  final String title;
  final Future Function()? onApprove;
  final Future Function()? onReject;

  @override
  State<ActionItemWidget> createState() => _ActionItemWidgetState();
}

class _ActionItemWidgetState extends State<ActionItemWidget> {
  late ActionItemModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ActionItemModel());
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
        child: Row(
          children: [
            Container(
              width: 48.0,
              height: 48.0,
              decoration: BoxDecoration(
                color: DegloorTheme.background,
                borderRadius: BorderRadius.circular(8.0),
              ),
              alignment: Alignment.center,
              child: widget.icon,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    maxLines: 1,
                    style: DegloorTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.subtitle,
                    maxLines: 1,
                    style: DegloorTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: widget.statusBg,
                    borderRadius: BorderRadius.circular(9999.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    child: Text(
                      widget.statusLabel,
                      style: DegloorTheme.labelSmall.copyWith(
                        color: widget.statusText,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.onApprove != null)
                      FlutterFlowIconButton(
                        borderRadius: 8.0,
                        buttonSize: 36.0,
                        fillColor: Colors.transparent,
                        icon: const Icon(
                          Icons.check_circle_outline_rounded,
                          color: DegloorTheme.success,
                          size: 20.0,
                        ),
                        onPressed: () async {
                          await widget.onApprove!();
                        },
                      ),
                    if (widget.onReject != null)
                      FlutterFlowIconButton(
                        borderRadius: 8.0,
                        buttonSize: 36.0,
                        fillColor: Colors.transparent,
                        icon: const Icon(
                          Icons.highlight_off_rounded,
                          color: DegloorTheme.error,
                          size: 20.0,
                        ),
                        onPressed: () async {
                          await widget.onReject!();
                        },
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
