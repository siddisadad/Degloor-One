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

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'We value your privacy and are committed to protecting your personal data.'**
  String get privacyIntro;

  /// No description provided for @statusFindingShop.
  ///
  /// In en, this message translates to:
  /// **'Finding Shop'**
  String get statusFindingShop;

  /// No description provided for @statusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get statusPreparing;

  /// No description provided for @statusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready for pickup'**
  String get statusReady;

  /// No description provided for @statusShipping.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get statusShipping;

  /// No description provided for @statusRiderNearby.
  ///
  /// In en, this message translates to:
  /// **'Rider is nearby'**
  String get statusRiderNearby;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get statusDeclined;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get statusApplied;

  /// No description provided for @statusShortlisted.
  ///
  /// In en, this message translates to:
  /// **'Shortlisted'**
  String get statusShortlisted;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get selectCity;

  /// No description provided for @retryCities.
  ///
  /// In en, this message translates to:
  /// **'Unable to load cities. Tap to retry.'**
  String get retryCities;

  /// No description provided for @registerBusiness.
  ///
  /// In en, this message translates to:
  /// **'Register Business'**
  String get registerBusiness;

  /// No description provided for @phaseOneDegloorOne.
  ///
  /// In en, this message translates to:
  /// **'Phase 1: DEGLOOR ONE'**
  String get phaseOneDegloorOne;

  /// No description provided for @businessIdentity.
  ///
  /// In en, this message translates to:
  /// **'Business Identity'**
  String get businessIdentity;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get businessName;

  /// No description provided for @ownerName.
  ///
  /// In en, this message translates to:
  /// **'Owner Name'**
  String get ownerName;

  /// No description provided for @businessNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Maharashtra Hardware & Steel'**
  String get businessNameHint;

  /// No description provided for @ownerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Full legal name of proprietor'**
  String get ownerNameHint;

  /// No description provided for @primaryCategory.
  ///
  /// In en, this message translates to:
  /// **'Primary Category'**
  String get primaryCategory;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @typeSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Type / Specialty'**
  String get typeSpecialty;

  /// No description provided for @typeSpecialtyHint.
  ///
  /// In en, this message translates to:
  /// **'What kind of business is this?'**
  String get typeSpecialtyHint;

  /// No description provided for @typeSpecialtyHelper.
  ///
  /// In en, this message translates to:
  /// **'e.g. Kirana, Hardware, Restaurant'**
  String get typeSpecialtyHelper;

  /// No description provided for @businessDescription.
  ///
  /// In en, this message translates to:
  /// **'Business Description'**
  String get businessDescription;

  /// No description provided for @businessDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Briefly describe your products or services...'**
  String get businessDescriptionHint;

  /// No description provided for @contactDetails.
  ///
  /// In en, this message translates to:
  /// **'Contact Details'**
  String get contactDetails;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @whatsAppNumber.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Number'**
  String get whatsAppNumber;

  /// No description provided for @whatsAppNumberHint.
  ///
  /// In en, this message translates to:
  /// **'For customer enquiries'**
  String get whatsAppNumberHint;

  /// No description provided for @whatsAppSameAsMobile.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp same as mobile'**
  String get whatsAppSameAsMobile;

  /// No description provided for @locationAndGps.
  ///
  /// In en, this message translates to:
  /// **'Location & GPS'**
  String get locationAndGps;

  /// No description provided for @streetAddress.
  ///
  /// In en, this message translates to:
  /// **'Street Address'**
  String get streetAddress;

  /// No description provided for @streetAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Shop No., Building Name, Main Road...'**
  String get streetAddressHint;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @areaHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Shivaji Chowk'**
  String get areaHint;

  /// No description provided for @setGpsCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Set GPS Coordinates'**
  String get setGpsCoordinates;

  /// No description provided for @locateMe.
  ///
  /// In en, this message translates to:
  /// **'Locate Me'**
  String get locateMe;

  /// No description provided for @discoveryReach.
  ///
  /// In en, this message translates to:
  /// **'Discovery Reach'**
  String get discoveryReach;

  /// No description provided for @serviceRadius.
  ///
  /// In en, this message translates to:
  /// **'Service Radius'**
  String get serviceRadius;

  /// No description provided for @discoveryRadiusKm.
  ///
  /// In en, this message translates to:
  /// **'Discovery Radius (KM)'**
  String get discoveryRadiusKm;

  /// No description provided for @discoveryDescription.
  ///
  /// In en, this message translates to:
  /// **'How far should customers be able to discover your business?'**
  String get discoveryDescription;

  /// No description provided for @photosAndVerification.
  ///
  /// In en, this message translates to:
  /// **'Photos & Verification'**
  String get photosAndVerification;

  /// No description provided for @photoUploadInstruction.
  ///
  /// In en, this message translates to:
  /// **'Upload clear photos of your storefront and interior.'**
  String get photoUploadInstruction;

  /// No description provided for @storeFront.
  ///
  /// In en, this message translates to:
  /// **'Store Front'**
  String get storeFront;

  /// No description provided for @interior.
  ///
  /// In en, this message translates to:
  /// **'Interior'**
  String get interior;

  /// No description provided for @registrationDoc.
  ///
  /// In en, this message translates to:
  /// **'Reg. Doc'**
  String get registrationDoc;

  /// No description provided for @submitForVerification.
  ///
  /// In en, this message translates to:
  /// **'Submit for Verification'**
  String get submitForVerification;

  /// No description provided for @businessTermsDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'By submitting, you agree to the DEGLOOR ONE Business Terms. Your listing will be reviewed by our local admin team for verification within 24 hours.'**
  String get businessTermsDisclaimer;

  /// No description provided for @pleaseWaitCategories.
  ///
  /// In en, this message translates to:
  /// **'Please wait for categories to load...'**
  String get pleaseWaitCategories;

  /// No description provided for @unableLoadCategories.
  ///
  /// In en, this message translates to:
  /// **'Unable to load categories. Please check your connection.'**
  String get unableLoadCategories;

  /// No description provided for @unableLoadCategoriesRetry.
  ///
  /// In en, this message translates to:
  /// **'Unable to load categories. Tap to retry.'**
  String get unableLoadCategoriesRetry;

  /// No description provided for @businessSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Business submitted for verification!'**
  String get businessSubmitted;

  /// No description provided for @unableSubmitShop.
  ///
  /// In en, this message translates to:
  /// **'Unable to submit the shop. Please try again.'**
  String get unableSubmitShop;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInSubtitleCustomer.
  ///
  /// In en, this message translates to:
  /// **'Sign in to shop local in Degloor.'**
  String get signInSubtitleCustomer;

  /// No description provided for @signInSubtitleBusiness.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your Degloor shop.'**
  String get signInSubtitleBusiness;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or Phone'**
  String get emailOrPhone;

  /// No description provided for @enterCredentials.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials'**
  String get enterCredentials;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @forgotPasswordQuestion.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordQuestion;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @continueWithPhone.
  ///
  /// In en, this message translates to:
  /// **'Continue with Phone'**
  String get continueWithPhone;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @noShopYet.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have a shop yet? '**
  String get noShopYet;

  /// No description provided for @noAccountYet.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccountYet;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @enterCredentialsError.
  ///
  /// In en, this message translates to:
  /// **'Please enter credentials'**
  String get enterCredentialsError;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the email on your account. We will send a link to set a new password.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @checkEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkEmail;

  /// No description provided for @checkEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for {email}, you will receive a reset link shortly. Open it on this device to choose a new password.'**
  String checkEmailSubtitle(Object email);

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @resendLink.
  ///
  /// In en, this message translates to:
  /// **'Resend link'**
  String get resendLink;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get enterValidEmail;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get setNewPassword;

  /// No description provided for @setNewPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a password with at least 6 characters.'**
  String get setNewPasswordSubtitle;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePassword;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @linkExpired.
  ///
  /// In en, this message translates to:
  /// **'Link expired'**
  String get linkExpired;

  /// No description provided for @linkExpiredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This reset link is invalid or has already been used. Request a new one to continue.'**
  String get linkExpiredSubtitle;

  /// No description provided for @requestNewLink.
  ///
  /// In en, this message translates to:
  /// **'Request a new link'**
  String get requestNewLink;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdated;
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
