import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/business_service.dart';
import 'package:degloor_one/components/cached_remote_image.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/components/slider/slider_widget.dart';
import 'package:degloor_one/components/switch_component/switch_component_widget.dart';
import 'package:degloor_one/components/text_field/text_field_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_icon_button.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:degloor_one/shared/discovery_radius.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'edit_business_profile_model.dart';
export 'edit_business_profile_model.dart';

class EditBusinessProfileWidget extends StatefulWidget {
  const EditBusinessProfileWidget({
    super.key,
    required this.business,
  });

  final Shop business;

  static String routeName = 'EditBusinessProfile';
  static String routePath = '/editBusinessProfile';

  @override
  State<EditBusinessProfileWidget> createState() =>
      _EditBusinessProfileWidgetState();
}

class _EditBusinessProfileWidgetState extends State<EditBusinessProfileWidget> {
  late EditBusinessProfileModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSaving = false;
  String? _uploadedImageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditBusinessProfileModel());

    _uploadedImageUrl = widget.business.imageUrl;
    final radius =
        widget.business.discoveryRadius ?? kDefaultDiscoveryRadiusKm;
    _model.sliderModel.sliderValue = sliderPercentFromRadius(radius);

    _model.switchModel.switchValue = widget.business.phoneNumber == widget.business.whatsappNumber;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;

    setState(() => _isUploading = true);
    try {
      final bytes = await image.readAsBytes();
      final url = await BusinessService.instance.uploadPublicImage(
        folder: 'businesses',
        businessId: widget.business.id,
        bytes: bytes,
      );

      setState(() {
        _uploadedImageUrl = url;
        _isUploading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLogger.userFacingMessage(
                e,
                fallback: 'Unable to upload the image. Please try again.',
              ),
            ),
          ),
        );
      }
      setState(() => _isUploading = false);
    }
  }

  Future<void> _updateProfile() async {
    final name = _model.textFieldModel1.inputTextController?.text.trim();
    if (name == null || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business Name is required')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final sliderVal = _model.sliderModel.sliderValue ??
          sliderPercentFromRadius(kDefaultDiscoveryRadiusKm);
      final radiusKm = radiusFromSliderPercent(sliderVal);

      await BusinessService.instance.updateProfile(
        userId: currentUserUid,
        businessId: widget.business.id,
        name: name,
        ownerName: _model.textFieldModel2.inputTextController?.text,
        description: _model.textFieldModel3.inputTextController?.text,
        phoneNumber: _model.textFieldModel4.inputTextController?.text,
        whatsappNumber: _model.switchModel.switchValue == true
            ? _model.textFieldModel4.inputTextController?.text
            : _model.textFieldModel5.inputTextController?.text,
        addressText: _model.textFieldModel6.inputTextController?.text,
        discoveryRadius: radiusKm,
        imageUrl: _uploadedImageUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green),
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
                fallback: 'Unable to update the shop. Please try again.',
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
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
        appBar: degloorAppBar(context, title: 'Edit Business Profile'),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: _isUploading
                                ? const Center(child: CircularProgressIndicator())
                                : (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty)
                                    ? CachedRemoteImage(
                                        url: _uploadedImageUrl!,
                                        width: 120,
                                        height: 120,
                                      )
                                    : Icon(Icons.business_rounded, size: 60, color: FlutterFlowTheme.of(context).secondaryText),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: FlutterFlowIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 20,
                            buttonSize: 40,
                            fillColor: FlutterFlowTheme.of(context).primary,
                            icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                            onPressed: _pickImage,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  wrapWithModel(
                    model: _model.textFieldModel1,
                    updateCallback: () => setState(() {}),
                    child: TextFieldWidget(
                      label: 'Business Name',
                      labelPresent: true,
                      hint: 'Enter business name',
                      value: widget.business.name,
                      variant: 'outlined',
                    ),
                  ),
                  const SizedBox(height: 16),
                  wrapWithModel(
                    model: _model.textFieldModel2,
                    updateCallback: () => setState(() {}),
                    child: TextFieldWidget(
                      label: 'Owner Name',
                      labelPresent: true,
                      hint: 'Full name',
                      value: widget.business.ownerName ?? '',
                      variant: 'outlined',
                    ),
                  ),
                  const SizedBox(height: 16),
                  wrapWithModel(
                    model: _model.textFieldModel3,
                    updateCallback: () => setState(() {}),
                    child: TextFieldWidget(
                      label: 'Description',
                      labelPresent: true,
                      hint: 'What do you sell or provide?',
                      value: widget.business.description ?? '',
                      variant: 'outlined',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Contact Information',
                    style: FlutterFlowTheme.of(context).titleSmall,
                  ),
                  const SizedBox(height: 12),
                  wrapWithModel(
                    model: _model.textFieldModel4,
                    updateCallback: () => setState(() {}),
                    child: TextFieldWidget(
                      label: 'Mobile Number',
                      labelPresent: true,
                      hint: '+91',
                      value: widget.business.phoneNumber ?? '',
                      variant: 'outlined',
                    ),
                  ),
                  const SizedBox(height: 12),
                  wrapWithModel(
                    model: _model.switchModel,
                    updateCallback: () => setState(() {}),
                    child: const SwitchComponentWidget(
                      label: 'WhatsApp same as mobile',
                      labelPresent: true,
                    ),
                  ),
                  if (!(_model.switchModel.switchValue ?? false))
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: wrapWithModel(
                        model: _model.textFieldModel5,
                        updateCallback: () => setState(() {}),
                        child: TextFieldWidget(
                          label: 'WhatsApp Number',
                          labelPresent: true,
                          hint: '+91',
                          value: widget.business.whatsappNumber ?? '',
                          variant: 'outlined',
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    'Location & Reach',
                    style: FlutterFlowTheme.of(context).titleSmall,
                  ),
                  const SizedBox(height: 12),
                  wrapWithModel(
                    model: _model.textFieldModel6,
                    updateCallback: () => setState(() {}),
                    child: TextFieldWidget(
                      label: 'Street Address',
                      labelPresent: true,
                      hint: 'Shop No, Road, etc.',
                      value: widget.business.addressText ?? '',
                      variant: 'outlined',
                    ),
                  ),
                  const SizedBox(height: 16),
                  wrapWithModel(
                    model: _model.sliderModel,
                    updateCallback: () => setState(() {}),
                    child: SliderWidget(
                      label: 'Discovery Radius (KM)',
                      labelPresent: true,
                      valueLabel:
                          '${radiusFromSliderPercent(_model.sliderModel.sliderValue ?? sliderPercentFromRadius(kDefaultDiscoveryRadiusKm)).toInt()} KM',
                      valueLabelPresent: true,
                      divisions: 2,
                      valuePercentage: _model.sliderModel.sliderValue ??
                          sliderPercentFromRadius(kDefaultDiscoveryRadiusKm),
                    ),
                  ),
                  const SizedBox(height: 40),
                  FFButtonWidget(
                    onPressed: _isSaving ? null : _updateProfile,
                    text: 'Save Changes',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 50,
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
    );
  }
}
