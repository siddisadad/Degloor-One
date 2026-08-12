import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'category_item_model.dart';
export 'category_item_model.dart';

class CategoryItemWidget extends StatefulWidget {
  const CategoryItemWidget({
    super.key,
    this.icon,
    String? label,
  }) : this.label = label ?? 'Grocery';

  final Widget? icon;
  final String label;

  @override
  State<CategoryItemWidget> createState() => _CategoryItemWidgetState();
}

class _CategoryItemWidgetState extends State<CategoryItemWidget> {
  late CategoryItemModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CategoryItemModel());
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
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: [
          FlutterFlowTheme.of(context).designToken.shadow.xs,
        ],
        borderRadius: BorderRadius.circular(
          FlutterFlowTheme.of(context).designToken.radius.lg,
        ),
        shape: BoxShape.rectangle,
      ),
      child: Padding(
        padding: EdgeInsets.all(
          FlutterFlowTheme.of(context).designToken.spacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56.0,
              height: 56.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primaryBackground,
                borderRadius: BorderRadius.circular(
                  FlutterFlowTheme.of(context).designToken.radius.md,
                ),
                shape: BoxShape.rectangle,
                border: Border.all(
                  color: FlutterFlowTheme.of(context).alternate,
                  width: 1.0,
                ),
              ),
              alignment: const AlignmentDirectional(0.0, 0.0),
              child: widget.icon!,
            ),
            Text(
              valueOrDefault<String>(
                widget.label,
                'Grocery',
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              style: FlutterFlowTheme.of(context).labelSmall.override(
                    fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                    color: FlutterFlowTheme.of(context).primaryText,
                    useGoogleFonts: GoogleFonts.asMap().containsKey(
                        FlutterFlowTheme.of(context).labelSmallFamily),
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ].divide(SizedBox(
              height: FlutterFlowTheme.of(context).designToken.spacing.sm)),
        ),
      ),
    );
  }
}
