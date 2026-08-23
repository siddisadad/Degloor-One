import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/shop_service.dart';
import 'package:degloor_one/backend/user_service.dart';
import 'package:degloor_one/shared/listing_complaint.dart';
import 'package:degloor_one/shared/user_profile.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/app_state.dart';
import 'package:degloor_one/components/button/button_widget.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'user_profile_reports_model.dart';
export 'user_profile_reports_model.dart';

class UserProfileReportsWidget extends StatefulWidget {
  const UserProfileReportsWidget({super.key});

  static String routeName = 'UserProfileReports';
  static String routePath = '/userProfileReports';

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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: DegloorTheme.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('My Profile', style: DegloorTheme.headingMedium),
          elevation: 0,
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
                            () => context.pushNamed('Cart'),
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
                            () => context.goNamed('Services'),
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
                      'Language',
                      'Change your language',
                      () => _showLanguageSelector(context),
                    ),
                    const SizedBox(height: 12),
                    _sectionHeader('Support & Legal'),
                    _settingsTile(
                      Icons.help_outline_rounded,
                      'Help Center',
                      'FAQs and Support',
                      () {},
                    ),
                    _settingsTile(
                      Icons.description_outlined,
                      'Terms of Service',
                      'Legal agreements',
                      () {},
                    ),
                    _settingsTile(
                      Icons.info_outline_rounded,
                      'About App',
                      'Version 1.0.0',
                      () {},
                    ),
                    const SizedBox(height: 12),
                    _sectionHeader('My Reports'),
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
                                  () {},
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

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Language / भाषा निवडा',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildLangItem(context, 'English', 'en'),
            _buildLangItem(context, 'मराठी (Marathi)', 'mr'),
            _buildLangItem(context, 'हिन्दी (Hindi)', 'hi'),
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
        fullName: _nameController.text,
        phoneNumber: _phoneController.text,
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
