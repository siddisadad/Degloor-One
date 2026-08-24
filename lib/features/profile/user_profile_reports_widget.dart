import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/shop_service.dart';
import 'package:degloor_one/backend/user_service.dart';
import 'package:degloor_one/shared/listing_complaint.dart';
import 'package:degloor_one/shared/user_profile.dart';
import 'package:degloor_one/shared/user_profile_draft.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/app_state.dart';
import 'package:degloor_one/components/button/button_widget.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/features/profile/profile_info_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'user_profile_reports_model.dart';
export 'user_profile_reports_model.dart';

class UserProfileReportsWidget extends StatefulWidget {
  const UserProfileReportsWidget({
    super.key,
    this.showBack = true,
  });

  /// Pushed profile (Home, order help) shows back. The Profile tab does not.
  final bool showBack;

  static String routeName = 'UserProfileReports';
  static String routePath = '/userProfileReports';
  static String stackedRouteName = 'MyProfile';
  static String stackedRoutePath = '/myProfile';

  @override
  State<UserProfileReportsWidget> createState() =>
      _UserProfileReportsWidgetState();
}

class _UserProfileReportsWidgetState extends State<UserProfileReportsWidget> {
  late UserProfileReportsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserProfileReportsModel());
    if (loggedIn && currentUserUid.length > 10) {
      _reloadProfile();
      _model.complaintsFuture =
          ShopService.instance.complaintsForUser(currentUserUid);
    }
  }

  void _reloadProfile() {
    _model.userProfileFuture = UserService.instance.profile(currentUserUid);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: DegloorTheme.background,
        appBar: degloorAppBar(
          context,
          title: 'My Profile',
          showBack: widget.showBack,
        ),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(DegloorTheme.spacingLG),
                      child: FutureBuilder<List<UserProfile>>(
                        future: _model.userProfileFuture,
                        builder: (context, snapshot) {
                          final user = snapshot.data?.firstOrNull;
                          final name = user?.fullName ?? 'Guest User';
                          final initials =
                              name.isNotEmpty ? name[0].toUpperCase() : 'U';

                          return Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  color: DegloorTheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: DegloorTheme.headingMedium),
                                    Text(
                                      user?.email ?? 'guest@local',
                                      style: DegloorTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: DegloorTheme.primary,
                                ),
                                onPressed: () => _editPersonalInfo(user),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: DegloorTheme.spacingSM),
                    Padding(
                      padding: const EdgeInsets.all(DegloorTheme.spacingMD),
                      child: Row(
                        children: [
                          _activityCard(
                            Icons.shopping_bag_rounded,
                            'Orders',
                            () => context.pushNamed('CustomerOrders'),
                          ),
                          const SizedBox(width: 12),
                          _activityCard(
                            Icons.shopping_cart_rounded,
                            'Cart',
                            () => context.pushNamed('ShoppingCart'),
                          ),
                          const SizedBox(width: 12),
                          _activityCard(
                            Icons.notifications_rounded,
                            'Inbox',
                            () => context.pushNamed('Notifications'),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        DegloorTheme.spacingMD,
                        0,
                        DegloorTheme.spacingMD,
                        DegloorTheme.spacingMD,
                      ),
                      child: Row(
                        children: [
                          _activityCard(
                            Icons.handyman_rounded,
                            'Services',
                            () => context.pushNamed('LocalServices'),
                          ),
                          const SizedBox(width: 12),
                          _activityCard(
                            Icons.work_rounded,
                            'Jobs',
                            () => context.pushNamed('JobsMarketplace'),
                          ),
                        ],
                      ),
                    ),
                    _sectionHeader('Account Settings'),
                    _settingsTile(
                      Icons.person_outline_rounded,
                      'Personal Information',
                      'Name, Email, Phone',
                      () async {
                        final rows = await _model.userProfileFuture;
                        if (!mounted) return;
                        await _editPersonalInfo(rows?.firstOrNull);
                      },
                    ),
                    _settingsTile(
                      Icons.location_on_outlined,
                      'Saved Addresses',
                      'Home, Work, Other',
                      () => context.pushNamed('AddressList'),
                    ),
                    _settingsTile(
                      Icons.language_rounded,
                      l10n?.language ?? 'Language',
                      l10n?.languageSubtitle ?? 'Change your language',
                      () => _showLanguageSelector(context),
                    ),
                    const SizedBox(height: 12),
                    _sectionHeader(l10n?.supportAndLegal ?? 'Support & Legal'),
                    _settingsTile(
                      Icons.help_outline_rounded,
                      l10n?.helpCenter ?? 'Help Center',
                      l10n?.helpCenterSubtitle ?? 'FAQs and Support',
                      () => context.pushNamed(ProfileInfoWidget.helpRouteName),
                    ),
                    _settingsTile(
                      Icons.description_outlined,
                      l10n?.termsOfService ?? 'Terms of Service',
                      l10n?.termsOfServiceSubtitle ?? 'Legal agreements',
                      () => context.pushNamed(ProfileInfoWidget.termsRouteName),
                    ),
                    _settingsTile(
                      Icons.info_outline_rounded,
                      l10n?.aboutApp ?? 'About App',
                      l10n?.aboutAppSubtitle ?? 'Version 1.0.0',
                      () => context.pushNamed(ProfileInfoWidget.aboutRouteName),
                    ),
                    const SizedBox(height: 12),
                    _sectionHeader('My Reports'),
                    if (_model.complaintsFuture == null)
                      const EmptyStateView(
                        icon: Icons.flag_outlined,
                        title: 'No reports yet',
                        description:
                            'If something is wrong with a Degloor listing, report it from the shop page.',
                      )
                    else
                      FutureBuilder<List<ListingComplaint>>(
                        future: _model.complaintsFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final complaints = snapshot.data!;
                          if (complaints.isEmpty) {
                            return const EmptyStateView(
                              icon: Icons.flag_outlined,
                              title: 'No reports yet',
                              description:
                                  'If something is wrong with a Degloor listing, report it from the shop page.',
                            );
                          }
                          return Column(
                            children: complaints
                                .map(
                                  (complaint) => _settingsTile(
                                    Icons.flag_outlined,
                                    complaint.subject,
                                    '${complaint.status} · ${dateTimeFormat('MMM d, yyyy', complaint.createdAt)}',
                                    () => _openReport(complaint),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: DegloorTheme.spacingMD),
                      child: ButtonWidget(
                        onTap: () async {
                          await authManager.signOut();
                          if (context.mounted) {
                            context.goNamed('Authentication');
                          }
                        },
                        content: 'Sign Out',
                        variant: 'outline',
                        size: 'large',
                        fullWidth: true,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _activityCard(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
            border: Border.all(color: DegloorTheme.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: DegloorTheme.primary, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: DegloorTheme.labelSmall
                    .copyWith(color: DegloorTheme.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title,
          style: DegloorTheme.labelSmall.copyWith(letterSpacing: 1)),
    );
  }

  Widget _settingsTile(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: DegloorTheme.accent,
            borderRadius: BorderRadius.circular(DegloorTheme.radiusSM),
          ),
          child: Icon(icon, color: DegloorTheme.primary, size: 20),
        ),
        title: Text(title, style: DegloorTheme.titleMedium.copyWith(fontSize: 15)),
        subtitle: Text(subtitle, style: DegloorTheme.bodySmall),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: DegloorTheme.textSecondary, size: 20),
        onTap: onTap,
      ),
    );
  }

  Future<void> _editPersonalInfo(UserProfile? user) async {
    if (currentUserUid.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to update your profile')),
      );
      return;
    }
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _PersonalInfoSheet(
        user: user,
        email: user?.email ?? currentUserEmail,
        userId: currentUserUid,
      ),
    );
    if (saved == true && mounted) {
      _reloadProfile();
      setState(() {});
    }
  }

  Future<void> _openReport(ListingComplaint complaint) {
    final businessId = complaint.businessId;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(complaint.subject, style: DegloorTheme.headingMedium),
                  const SizedBox(height: 8),
                  Text(
                    '${complaint.status} · ${dateTimeFormat('MMM d, yyyy', complaint.createdAt)}',
                    style: DegloorTheme.bodySmall,
                  ),
                  if (complaint.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(complaint.description, style: DegloorTheme.bodyMedium),
                  ],
                  if (businessId != null && businessId.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    ButtonWidget(
                      content: 'View shop',
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        if (!context.mounted) return;
                        await context.pushNamed(
                          'BusinessProfile',
                          queryParameters: {'businessId': businessId},
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n?.selectLanguage ?? 'Select Language',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildLangItem(sheetContext, 'English', 'en'),
            _buildLangItem(sheetContext, 'मराठी (Marathi)', 'mr'),
            _buildLangItem(sheetContext, 'हिन्दी (Hindi)', 'hi'),
          ],
        ),
      ),
    );
  }

  Widget _buildLangItem(BuildContext context, String label, String code) {
    final isSelected = FFAppState.instance.locale == code;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        title: Text(label),
        onTap: () {
          FFAppState.instance.locale = code;
          Navigator.pop(context);
          setState(() {});
        },
        trailing: isSelected
            ? const Icon(Icons.check, color: DegloorTheme.primary)
            : null,
      ),
    );
  }
}

class _PersonalInfoSheet extends StatefulWidget {
  const _PersonalInfoSheet({
    required this.user,
    required this.email,
    required this.userId,
  });

  final UserProfile? user;
  final String email;
  final String userId;

  @override
  State<_PersonalInfoSheet> createState() => _PersonalInfoSheetState();
}

class _PersonalInfoSheetState extends State<_PersonalInfoSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.fullName ?? '');
    _phoneController =
        TextEditingController(text: widget.user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await UserService.instance.updateProfile(
        userId: widget.userId,
        draft: UserProfileDraft.fromProfile(
          fullName: _nameController.text,
          phoneNumber: _phoneController.text,
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLogger.userFacingMessage(
              error,
              fallback: 'Unable to update your profile. Please try again.',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Personal information', style: DegloorTheme.headingMedium),
          const SizedBox(height: 8),
          Text(widget.email, style: DegloorTheme.bodySmall),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full name'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: DegloorTheme.primary,
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(_saving ? 'Saving...' : 'Save'),
          ),
        ],
      ),
    );
  }
}
