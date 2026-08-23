import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/service_marketplace_service.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:degloor_one/features/services/service_provider_registration_model.dart';
export 'package:degloor_one/features/services/service_provider_registration_model.dart';

class ServiceProviderRegistrationWidget extends StatefulWidget {
  const ServiceProviderRegistrationWidget({super.key});

  static String routeName = 'ServiceProviderRegistration';
  static String routePath = '/serviceProviderRegistration';

  @override
  State<ServiceProviderRegistrationWidget> createState() =>
      _ServiceProviderRegistrationWidgetState();
}

class _ServiceProviderRegistrationWidgetState
    extends State<ServiceProviderRegistrationWidget> {
  late ServiceProviderRegistrationModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<ServiceCategoriesRow>>? _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ServiceProviderRegistrationModel());
    _categoriesFuture = ServiceMarketplaceService.instance.categories();
  }

  Future<void> _submitRegistration() async {
    if (_model.formKey.currentState!.validate()) {
      if (_model.categoryValue == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a service category')),
        );
        return;
      }

      try {
        await ServiceMarketplaceService.instance.register(
          userId: currentUserUid,
          categoryId: _model.categoryValue!,
          experienceYears: _model.experienceTextController!.text,
          hourlyRate: _model.rateTextController!.text,
          bio: _model.bioTextController!.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration submitted! Your profile is now live.'),
              backgroundColor: Colors.green,
            ),
          );
          context.safePop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLogger.userFacingMessage(
                  e,
                  fallback: 'Unable to submit registration. Please try again.',
                ),
              ),
            ),
          );
        }
      }
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
        appBar: degloorAppBar(context, title: 'Join as a Provider'),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _model.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Grow your service business with DEGLOOR ONE. Fill in your details below.',
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    // Category Selection
                    Text(
                      'What service do you provide?',
                      style: FlutterFlowTheme.of(context).labelMedium,
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<List<ServiceCategoriesRow>>(
                      future: _categoriesFuture,
                      builder: (context, snapshot) {
                        final categories = snapshot.data ?? [];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                            borderRadius: BorderRadius.circular(12),
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _model.categoryValue,
                              hint: const Text('Select Category'),
                              isExpanded: true,
                              items: categories.map((cat) {
                                return DropdownMenuItem(
                                  value: cat.id,
                                  child: Text(cat.name),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _model.categoryValue = val),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Experience
                    TextFormField(
                      controller: _model.experienceTextController,
                      focusNode: _model.experienceFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Years of Experience',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) => (val == null || val.isEmpty) ? 'Please enter your experience' : null,
                    ),
                    const SizedBox(height: 20),

                    // Rate
                    TextFormField(
                      controller: _model.rateTextController,
                      focusNode: _model.rateFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Hourly Rate (₹)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) => (val == null || val.isEmpty) ? 'Please enter your rate' : null,
                    ),
                    const SizedBox(height: 20),

                    // Bio
                    TextFormField(
                      controller: _model.bioTextController,
                      focusNode: _model.bioFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Professional Bio',
                        hintText: 'Tell customers about your skills...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                      maxLines: 4,
                      validator: (val) => (val == null || val.isEmpty) ? 'Please write a short bio' : null,
                    ),
                    const SizedBox(height: 32),

                    FFButtonWidget(
                      onPressed: _submitRegistration,
                      text: 'Submit Application',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 56,
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        elevation: 2,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
            ),
          ),
        ),
      ),
    );
  }
}
