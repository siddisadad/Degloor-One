import 'package:degloor_one/backend/whatsapp_service.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

enum ProfileInfoKind { helpCenter, termsOfService, aboutApp, privacyPolicy }

/// Help Center, Terms of Service, and About App share one scrollable page.
class ProfileInfoWidget extends StatelessWidget {
  const ProfileInfoWidget({
    super.key,
    required this.kind,
  });

  final ProfileInfoKind kind;

  static const helpRouteName = 'HelpCenter';
  static const helpRoutePath = '/helpCenter';
  static const termsRouteName = 'TermsOfService';
  static const termsRoutePath = '/termsOfService';
  static const aboutRouteName = 'AboutApp';
  static const aboutRoutePath = '/aboutApp';
  static const privacyRouteName = 'PrivacyPolicy';
  static const privacyRoutePath = '/privacyPolicy';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final copy = _copyFor(l10n);

    return Scaffold(
      backgroundColor: DegloorTheme.background,
      appBar: degloorAppBar(context, title: copy.title),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        children: [
          if (kind == ProfileInfoKind.aboutApp) ...[
            Text(
              'DEGLOOR ONE',
              style: DegloorTheme.headingLarge.copyWith(
                color: DegloorTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(copy.intro, style: DegloorTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(copy.locationOrVersion, style: DegloorTheme.bodySmall),
          const SizedBox(height: 24),
          if (kind == ProfileInfoKind.helpCenter) _buildContactSupport(context),
          for (final section in copy.sections) ...[
            Text(section.heading, style: DegloorTheme.titleMedium),
            const SizedBox(height: 8),
            Text(section.body, style: DegloorTheme.bodyMedium),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildContactSupport(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DegloorTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
        border: Border.all(
          color: DegloorTheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Need direct help?',
            style: DegloorTheme.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Message our support team on WhatsApp for any issues or queries.',
            style: DegloorTheme.bodySmall.copyWith(
              color: DegloorTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => WhatsAppService.launchWhatsApp(
              phoneNumber: WhatsAppService.adminSupportNumber,
              message: 'Hello Degloor One Support, I need help with...',
            ),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            label: const Text('Contact Support'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DegloorTheme.success,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DegloorTheme.radiusSM),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _InfoCopy _copyFor(AppLocalizations? l10n) {
    switch (kind) {
      case ProfileInfoKind.helpCenter:
        return _InfoCopy(
          title: l10n?.helpCenter ?? 'Help Center',
          intro: l10n?.helpIntro ??
              'DEGLOOR ONE helps you find shops, services, and jobs around Degloor.',
          locationOrVersion: l10n?.aboutLocation ?? 'Degloor, Maharashtra',
          sections: [
            _InfoSection(
              l10n?.helpFindShopsTitle ?? 'Find shops',
              l10n?.helpFindShopsBody ??
                  'Use Home and Search to browse nearby listings. Open a shop to call, message on WhatsApp, or get directions.',
            ),
            _InfoSection(
              l10n?.helpOrdersTitle ?? 'Orders and reports',
              l10n?.helpOrdersBody ??
                  'Track your orders from Profile. If a listing is wrong or misleading, open the shop page and report it.',
            ),
            _InfoSection(
              l10n?.helpLanguageTitle ?? 'Language',
              l10n?.helpLanguageBody ??
                  'Choose English, Marathi, or Hindi from Profile. Your choice is saved on this device.',
            ),
          ],
        );
      case ProfileInfoKind.termsOfService:
        return _InfoCopy(
          title: l10n?.termsOfService ?? 'Terms of Service',
          intro: l10n?.termsIntro ??
              'These terms apply when you use DEGLOOR ONE, the Degloor marketplace app.',
          locationOrVersion: l10n?.aboutLocation ?? 'Degloor, Maharashtra',
          sections: [
            _InfoSection(
              l10n?.termsMarketplaceTitle ?? 'A local marketplace',
              l10n?.termsMarketplaceBody ??
                  'DEGLOOR ONE connects customers with shops and service providers in Degloor. Shop hours, catalogues, and prices are provided by those businesses.',
            ),
            _InfoSection(
              l10n?.termsConductTitle ?? 'Your use of the app',
              l10n?.termsConductBody ??
                  'Use the app lawfully. Do not post false listings, abuse messaging, or attempt to access another account. We may remove listings or accounts that break these rules.',
            ),
            _InfoSection(
              l10n?.termsContactTitle ?? 'Questions',
              l10n?.termsContactBody ??
                  'If you need a copy of these terms or have a question about DEGLOOR ONE, open Help Center from Profile.',
            ),
          ],
        );
      case ProfileInfoKind.privacyPolicy:
        return _InfoCopy(
          title: l10n?.privacyPolicy ?? 'Privacy Policy',
          intro: l10n?.privacyIntro ??
              'We value your privacy and are committed to protecting your personal data.',
          locationOrVersion: l10n?.aboutLocation ?? 'Degloor, Maharashtra',
          sections: [
            const _InfoSection(
              'Data Collection',
              'We collect information you provide (name, phone, location) to facilitate marketplace services and deliveries.',
            ),
            const _InfoSection(
              'Third-Party Services',
              'We may use trusted services like Google Maps and WhatsApp to provide features. Your data is handled securely and not sold to third parties.',
            ),
            const _InfoSection(
              'Your Choices',
              'You can manage your profile and delete your account data at any time from the app settings.',
            ),
          ],
        );
      case ProfileInfoKind.aboutApp:
        return _InfoCopy(
          title: l10n?.aboutApp ?? 'About App',
          intro: l10n?.aboutTagline ?? 'Everything Local. One App.',
          locationOrVersion: l10n?.aboutAppSubtitle ?? 'Version 1.0.0',
          sections: [
            _InfoSection(
              l10n?.aboutLocation ?? 'Degloor, Maharashtra',
              l10n?.aboutBody ??
                  'DEGLOOR ONE is the Degloor marketplace for nearby shops, services, jobs, and delivery.',
            ),
          ],
        );
    }
  }
}

class _InfoCopy {
  const _InfoCopy({
    required this.title,
    required this.intro,
    required this.locationOrVersion,
    required this.sections,
  });

  final String title;
  final String intro;
  final String locationOrVersion;
  final List<_InfoSection> sections;
}

class _InfoSection {
  const _InfoSection(this.heading, this.body);

  final String heading;
  final String body;
}
