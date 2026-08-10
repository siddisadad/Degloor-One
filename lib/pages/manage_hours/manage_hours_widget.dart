import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'manage_hours_model.dart';
export 'manage_hours_model.dart';

class ManageHoursWidget extends StatefulWidget {
  const ManageHoursWidget({super.key});

  static String routeName = 'ManageHours';
  static String routePath = '/manageHours';

  @override
  State<ManageHoursWidget> createState() => _ManageHoursWidgetState();
}

class _ManageHoursWidgetState extends State<ManageHoursWidget> {
  late ManageHoursModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loading = true;
  BusinessesRow? _business;
  List<BusinessHoursRow> _hours = [];
  final List<String> _weekDays = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ManageHoursModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  Future<void> _fetchData() async {
    final currentUser = currentUserUid;
    if (currentUser == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final businesses = await BusinessesTable().queryRows(
        queryFn: (q) => q.eq('owner_id', currentUser),
      );

      if (businesses.isNotEmpty) {
        _business = businesses.first;
        final hours = await BusinessHoursTable().queryRows(
          queryFn: (q) => q.eq('business_id', _business!.id).order('day_of_week'),
        );

        // Initialize missing days
        final existingDays = hours.map((h) => h.dayOfWeek).toSet();
        for (int i = 0; i < 7; i++) {
          if (!existingDays.contains(i)) {
            hours.add(BusinessHoursRow({
              'business_id': _business!.id,
              'day_of_week': i,
              'open_time': '09:00:00',
              'close_time': '18:00:00',
              'is_closed': false,
            }));
          }
        }
        hours.sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));

        setState(() {
          _hours = hours;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      print('Error fetching business hours: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _saveHours() async {
    if (_business == null) return;
    setState(() => _loading = true);

    try {
      for (final row in _hours) {
        if (row.id == null || row.id.isEmpty || row.id == 'null') {
          // It's a new row (we initialized it locally)
          // We need to insert it
          await BusinessHoursTable().insert({
            'business_id': row.businessId,
            'day_of_week': row.dayOfWeek,
            'open_time': row.openTime?.toIso8601String(),
            'close_time': row.closeTime?.toIso8601String(),
            'is_closed': row.isClosed,
          });
        } else {
          // Update existing
          await BusinessHoursTable().update(
            data: {
              'open_time': row.openTime?.toIso8601String(),
              'close_time': row.closeTime?.toIso8601String(),
              'is_closed': row.isClosed,
            },
            matchingRows: (q) => q.eq('id', row.id),
          );
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Business hours updated successfully')),
      );
      _fetchData(); // Refresh to get IDs for new rows
    } catch (e) {
      print('Error saving hours: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update business hours')),
      );
      setState(() => _loading = false);
    }
  }

  Future<void> _selectTime(int dayIndex, bool isOpenTime) async {
    final row = _hours[dayIndex];
    final initialPostgresTime = isOpenTime ? row.openTime : row.closeTime;

    TimeOfDay initialTime = TimeOfDay(hour: 9, minute: 0);
    if (initialPostgresTime?.time != null) {
      initialTime = TimeOfDay.fromDateTime(initialPostgresTime!.time!);
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      setState(() {
        if (isOpenTime) {
          row.openTime = PostgresTime(dt);
        } else {
          row.closeTime = PostgresTime(dt);
        }
      });
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 30.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Business Hours',
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  font: GoogleFonts.inter(),
                  letterSpacing: 0.0,
                ),
          ),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 16.0, 8.0),
              child: FFButtonWidget(
                onPressed: _loading ? null : _saveHours,
                text: 'Save',
                options: FFButtonOptions(
                  width: 80.0,
                  height: 40.0,
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: FlutterFlowTheme.of(context).primary,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        font: GoogleFonts.inter(),
                        color: Colors.white,
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                      ),
                  elevation: 2.0,
                  borderSide: BorderSide(
                    color: Colors.transparent,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: _loading
            ? Center(child: CircularProgressIndicator())
            : _business == null
                ? Center(child: Text('No business found for this account.'))
                : SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Set your opening and closing times for each day of the week.',
                            style: FlutterFlowTheme.of(context).labelMedium,
                          ),
                          SizedBox(height: 16.0),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: 7,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 12.0),
                            itemBuilder: (context, index) {
                              final row = _hours[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).alternate,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _weekDays[index],
                                            style: FlutterFlowTheme.of(context)
                                                .titleMedium
                                                .override(
                                                  font: GoogleFonts.inter(),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'Closed',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall,
                                              ),
                                              Switch(
                                                value: row.isClosed,
                                                onChanged: (val) {
                                                  setState(() {
                                                    row.isClosed = val;
                                                  });
                                                },
                                                activeColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (!row.isClosed)
                                        Padding(
                                          padding: EdgeInsets.only(top: 8.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () =>
                                                      _selectTime(index, true),
                                                  child: Container(
                                                    padding: EdgeInsets.all(12.0),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .alternate),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text('Open',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .labelSmall),
                                                        Text(
                                                          row.openTime?.toString() ??
                                                              'Select',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 16.0),
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () =>
                                                      _selectTime(index, false),
                                                  child: Container(
                                                    padding: EdgeInsets.all(12.0),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .alternate),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text('Close',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .labelSmall),
                                                        Text(
                                                          row.closeTime?.toString() ??
                                                              'Select',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
