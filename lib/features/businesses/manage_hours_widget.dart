import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/business_service.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:degloor_one/core/error_handler.dart';
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
    if (currentUser == '') {
      setState(() => _loading = false);
      return;
    }

    try {
      final shop = await BusinessService.instance.requireOwned(currentUser);
      final hours = await BusinessService.instance.hours(currentUser);
      if (mounted) {
        setState(() {
          _business = shop;
          _hours = hours;
          _loading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error fetching business hours', e);
      if (mounted) {
        setState(() {
          _business = null;
          _loading = false;
        });
      }
    }
  }

  Future<void> _saveHours() async {
    if (_business == null) return;
    setState(() => _loading = true);

    try {
      await BusinessService.instance.saveHours(
        userId: currentUserUid,
        hours: _hours,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business hours updated successfully')),
        );
      }
      _fetchData();
    } catch (e) {
      AppLogger.error('Error saving hours', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLogger.userFacingMessage(
                e,
                fallback: 'Unable to update business hours. Please try again.',
              ),
            ),
          ),
        );
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _selectTime(int dayIndex, bool isOpenTime) async {
    final row = _hours[dayIndex];
    final initialPostgresTime = isOpenTime ? row.openTime : row.closeTime;

    TimeOfDay initialTime = const TimeOfDay(hour: 9, minute: 0);
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
        appBar: degloorAppBar(
          context,
          title: 'Business Hours',
          actions: [
            TextButton(
              onPressed: _loading ? null : _saveHours,
              child: const Text('Save'),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _business == null
                ? EmptyStateView(
                    icon: Icons.storefront_outlined,
                    title: 'No shop yet',
                    description:
                        'Register your business to set Degloor opening hours.',
                    buttonText: 'Register business',
                    onTap: () => context.pushNamed('BusinessRegistration'),
                  )
                : Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Set your opening and closing times for each day of the week.',
                            style: FlutterFlowTheme.of(context).labelMedium,
                          ),
                          const SizedBox(height: 16.0),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 7,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12.0),
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
                                  padding: const EdgeInsets.all(16.0),
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
                                                activeThumbColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (!row.isClosed)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () =>
                                                      _selectTime(index, true),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(12.0),
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
                                                          BusinessService.timeLabel(
                                                              row.openTime),
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16.0),
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () =>
                                                      _selectTime(index, false),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(12.0),
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
                                                          BusinessService.timeLabel(
                                                              row.closeTime),
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
                  ),
      ),
    );
  }
}
