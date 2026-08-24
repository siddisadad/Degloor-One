import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('mr')
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @discoveryArea.
  ///
  /// In en, this message translates to:
  /// **'Discovery Area'**
  String get discoveryArea;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @manageOrders.
  ///
  /// In en, this message translates to:
  /// **'Manage Orders'**
  String get manageOrders;

  /// No description provided for @businessDashboard.
  ///
  /// In en, this message translates to:
  /// **'Business Dashboard'**
  String get businessDashboard;

  /// No description provided for @adminControl.
  ///
  /// In en, this message translates to:
  /// **'Admin Control'**
  String get adminControl;

  /// No description provided for @savedLocations.
  ///
  /// In en, this message translates to:
  /// **'Saved Locations'**
  String get savedLocations;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'Open Now'**
  String get openNow;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @nearbyBusinesses.
  ///
  /// In en, this message translates to:
  /// **'Nearby Businesses'**
  String get nearbyBusinesses;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @locationRequired.
  ///
  /// In en, this message translates to:
  /// **'Location Required'**
  String get locationRequired;

  /// No description provided for @enableLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get enableLocation;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search anything...'**
  String get searchPlaceholder;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @whatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsApp;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write Review'**
  String get writeReview;

  /// No description provided for @reportListing.
  ///
  /// In en, this message translates to:
  /// **'Report Listing'**
  String get reportListing;

  /// No description provided for @enableLocationDescription.
  ///
  /// In en, this message translates to:
  /// **'We need your location to show nearby businesses'**
  String get enableLocationDescription;

  /// No description provided for @noResultsDescription.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or searching for something else'**
  String get noResultsDescription;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change your language'**
  String get languageSubtitle;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @supportAndLegal.
  ///
  /// In en, this message translates to:
  /// **'Support & Legal'**
  String get supportAndLegal;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @helpCenterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'FAQs and Support'**
  String get helpCenterSubtitle;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @termsOfServiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Legal agreements'**
  String get termsOfServiceSubtitle;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @aboutAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get aboutAppSubtitle;

  /// No description provided for @helpIntro.
  ///
  /// In en, this message translates to:
  /// **'DEGLOOR ONE helps you find shops, services, and jobs around Degloor.'**
  String get helpIntro;

  /// No description provided for @helpFindShopsTitle.
  ///
  /// In en, this message translates to:
  /// **'Find shops'**
  String get helpFindShopsTitle;

  /// No description provided for @helpFindShopsBody.
  ///
  /// In en, this message translates to:
  /// **'Use Home and Search to browse nearby listings. Open a shop to call, message on WhatsApp, or get directions.'**
  String get helpFindShopsBody;

  /// No description provided for @helpOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders and reports'**
  String get helpOrdersTitle;

  /// No description provided for @helpOrdersBody.
  ///
  /// In en, this message translates to:
  /// **'Track your orders from Profile. If a listing is wrong or misleading, open the shop page and report it.'**
  String get helpOrdersBody;

  /// No description provided for @helpLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get helpLanguageTitle;

  /// No description provided for @helpLanguageBody.
  ///
  /// In en, this message translates to:
  /// **'Choose English, Marathi, or Hindi from Profile. Your choice is saved on this device.'**
  String get helpLanguageBody;

  /// No description provided for @termsIntro.
  ///
  /// In en, this message translates to:
  /// **'These terms apply when you use DEGLOOR ONE, the Degloor marketplace app.'**
  String get termsIntro;

  /// No description provided for @termsMarketplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'A local marketplace'**
  String get termsMarketplaceTitle;

  /// No description provided for @termsMarketplaceBody.
  ///
  /// In en, this message translates to:
  /// **'DEGLOOR ONE connects customers with shops and service providers in Degloor. Shop hours, catalogues, and prices are provided by those businesses.'**
  String get termsMarketplaceBody;

  /// No description provided for @termsConductTitle.
  ///
  /// In en, this message translates to:
  /// **'Your use of the app'**
  String get termsConductTitle;

  /// No description provided for @termsConductBody.
  ///
  /// In en, this message translates to:
  /// **'Use the app lawfully. Do not post false listings, abuse messaging, or attempt to access another account. We may remove listings or accounts that break these rules.'**
  String get termsConductBody;

  /// No description provided for @termsContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get termsContactTitle;

  /// No description provided for @termsContactBody.
  ///
  /// In en, this message translates to:
  /// **'If you need a copy of these terms or have a question about DEGLOOR ONE, open Help Center from Profile.'**
  String get termsContactBody;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Everything Local. One App.'**
  String get aboutTagline;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'DEGLOOR ONE is the Degloor marketplace for nearby shops, services, jobs, and delivery.'**
  String get aboutBody;

  /// No description provided for @aboutLocation.
  ///
  /// In en, this message translates to:
  /// **'Degloor, Maharashtra'**
  String get aboutLocation;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
