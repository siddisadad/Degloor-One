import 'package:degloor_one/core/degloor_theme.dart';
import 'package:flutter/material.dart';

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.buttonText,
    this.onTap,
    this.footer,
  });

  final IconData icon;
  final String title;
  final String? description;
  final String? buttonText;
  final VoidCallback? onTap;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded = constraints.hasBoundedHeight &&
            constraints.maxHeight.isFinite;
        final height = bounded ? constraints.maxHeight : double.infinity;
        final compact = bounded && height < 280;
        final tight = bounded && height < 360;
        final pad = compact ? 12.0 : tight ? 16.0 : 32.0;
        final box = compact ? 48.0 : tight ? 56.0 : 72.0;
        final iconSize = compact ? 24.0 : tight ? 28.0 : 36.0;

        final content = Padding(
          padding: EdgeInsets.all(pad),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: box,
                height: box,
                decoration: BoxDecoration(
                  color: DegloorTheme.accent,
                  borderRadius: BorderRadius.circular(DegloorTheme.radiusLG),
                ),
                child: Icon(icon, size: iconSize, color: DegloorTheme.primary),
              ),
              SizedBox(height: compact ? 8 : 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: DegloorTheme.headingMedium.copyWith(
                  fontSize: compact ? 18 : 20,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  maxLines: compact ? 3 : 8,
                  overflow: TextOverflow.ellipsis,
                  style: DegloorTheme.bodyMedium.copyWith(
                    color: DegloorTheme.textSecondary,
                  ),
                ),
              ],
              if (buttonText != null && onTap != null) ...[
                SizedBox(height: compact ? 12 : 24),
                FilledButton(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: DegloorTheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: Size(0, compact ? 40 : 44),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(DegloorTheme.radiusMD),
                    ),
                  ),
                  child: Text(
                    buttonText!,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
              if (footer != null) ...[
                SizedBox(height: compact ? 12 : 20),
                footer!,
              ],
            ],
          ),
        );

        if (!bounded) {
          return Center(child: content);
        }

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height),
            child: Center(child: content),
          ),
        );
      },
    );
  }
}
