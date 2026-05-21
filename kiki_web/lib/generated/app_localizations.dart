import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'TW')
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'Hi Kiki'**
  String get appName;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Register button text
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Text asking if user doesn't have account
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account yet?'**
  String get noAccountYet;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Username field label
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Home page title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Profile page title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Theme setting label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Dark mode setting
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Light mode setting label
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Error message title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Success message title
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No data message
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Search placeholder text
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Send button text
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Chat page title
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// Message field label
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// Message input placeholder
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// Phone number field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Welcome back title
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Login subtitle
  ///
  /// In en, this message translates to:
  /// **'Please login to your account'**
  String get pleaseLoginToAccount;

  /// Not logged in status
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedIn;

  /// Click to login text
  ///
  /// In en, this message translates to:
  /// **'Click to login'**
  String get clickToLogin;

  /// Learning statistics menu item
  ///
  /// In en, this message translates to:
  /// **'Learning Statistics'**
  String get learningStats;

  /// Learning statistics description
  ///
  /// In en, this message translates to:
  /// **'View learning progress and achievements'**
  String get viewProgressAndAchievements;

  /// Feature tip dialog title
  ///
  /// In en, this message translates to:
  /// **'Feature Tip'**
  String get featureTip;

  /// Learning stats development message
  ///
  /// In en, this message translates to:
  /// **'Learning statistics feature is under development'**
  String get learningStatsInDevelopment;

  /// Favorites menu item
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// Favorites description
  ///
  /// In en, this message translates to:
  /// **'Manage favorite words'**
  String get manageFavoriteWords;

  /// Favorites development message
  ///
  /// In en, this message translates to:
  /// **'Favorites feature is under development'**
  String get favoritesInDevelopment;

  /// Learning history menu item
  ///
  /// In en, this message translates to:
  /// **'Learning History'**
  String get learningHistory;

  /// Learning history description
  ///
  /// In en, this message translates to:
  /// **'View learning records'**
  String get viewLearningRecords;

  /// Learning history development message
  ///
  /// In en, this message translates to:
  /// **'Learning history feature is under development'**
  String get learningHistoryInDevelopment;

  /// Settings description
  ///
  /// In en, this message translates to:
  /// **'Personal preferences'**
  String get personalPreferences;

  /// Help and feedback menu item
  ///
  /// In en, this message translates to:
  /// **'Help & Feedback'**
  String get helpAndFeedback;

  /// Help and feedback description
  ///
  /// In en, this message translates to:
  /// **'Get help or provide feedback'**
  String get getHelpOrProvideFeedback;

  /// Help development message
  ///
  /// In en, this message translates to:
  /// **'Help feature is under development'**
  String get helpInDevelopment;

  /// About menu item
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// About description
  ///
  /// In en, this message translates to:
  /// **'Version information'**
  String get versionInfo;

  /// Log out menu item
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// Log out description
  ///
  /// In en, this message translates to:
  /// **'Safely exit the app'**
  String get safelyExitApp;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// App subtitle
  ///
  /// In en, this message translates to:
  /// **'Grounded Theory'**
  String get groundedTheory;

  /// Version text
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version100;

  /// App description
  ///
  /// In en, this message translates to:
  /// **'A simple and easy-to-use vocabulary learning app that helps you master new vocabulary easily.'**
  String get appDescription;

  /// Exit confirmation title
  ///
  /// In en, this message translates to:
  /// **'Confirm Exit'**
  String get confirmExit;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get confirmLogoutMessage;

  /// Exit button text
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// Push notifications setting
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// Quick switch text
  ///
  /// In en, this message translates to:
  /// **'Quick Switch'**
  String get quickSwitch;

  /// Feature demo text
  ///
  /// In en, this message translates to:
  /// **'Feature Demo'**
  String get featureDemo;

  /// Guest mode button text
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// Create account title
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Registration subtitle
  ///
  /// In en, this message translates to:
  /// **'Fill in information to complete registration'**
  String get fillInfoToRegister;

  /// Nickname field label with hint
  ///
  /// In en, this message translates to:
  /// **'Nickname (optional, 2-20 characters)'**
  String get nicknameOptional;

  /// Password field label with requirements
  ///
  /// In en, this message translates to:
  /// **'Password (6-20 characters, must contain letters and numbers)'**
  String get passwordRequirement;

  /// Text asking if user already has account
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Login now link text
  ///
  /// In en, this message translates to:
  /// **'Login Now'**
  String get loginNow;

  /// Welcome message for guest users
  ///
  /// In en, this message translates to:
  /// **'Hi, please login'**
  String get hiPleaseLogin;

  /// Description of benefits after login
  ///
  /// In en, this message translates to:
  /// **'Login to view learning records and favorites'**
  String get loginToViewRecords;

  /// Phone number label prefix
  ///
  /// In en, this message translates to:
  /// **'Phone: '**
  String get phoneLabel;

  /// Learning records menu item
  ///
  /// In en, this message translates to:
  /// **'Learning Records'**
  String get learningRecords;

  /// My favorites menu item
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get myFavorites;

  /// Nickname field label
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// New badge label for new content
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newBadge;

  /// Item count label
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(int count);

  /// Scene count label
  ///
  /// In en, this message translates to:
  /// **'{count} scenes'**
  String scenesCount(int count);

  /// No description provided for @defaultUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUser;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loggingIn;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed, please try again'**
  String get loginFailed;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccess;

  /// No description provided for @registering.
  ///
  /// In en, this message translates to:
  /// **'Registering...'**
  String get registering;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get registerSuccess;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed, please try again'**
  String get registerFailed;

  /// No description provided for @registerDataEmpty.
  ///
  /// In en, this message translates to:
  /// **'Registration data is empty, please try again later'**
  String get registerDataEmpty;

  /// No description provided for @pleaseTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **', please try again later'**
  String get pleaseTryAgainLater;

  /// No description provided for @loggingOut.
  ///
  /// In en, this message translates to:
  /// **'Logging out...'**
  String get loggingOut;

  /// No description provided for @loggedOut.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get loggedOut;

  /// No description provided for @logoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Logout failed'**
  String get logoutFailed;

  /// No description provided for @guestModeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to enter guest mode'**
  String get guestModeFailed;

  /// No description provided for @pleaseEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get pleaseEnterPhone;

  /// No description provided for @pleaseEnterValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get pleaseEnterValidPhone;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password length should be between 6-20 characters'**
  String get passwordLengthError;

  /// No description provided for @passwordFormatError.
  ///
  /// In en, this message translates to:
  /// **'Password must contain letters and numbers'**
  String get passwordFormatError;

  /// No description provided for @pleaseEnterPasswordAgain.
  ///
  /// In en, this message translates to:
  /// **'Please enter password again'**
  String get pleaseEnterPasswordAgain;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @nicknameLengthError.
  ///
  /// In en, this message translates to:
  /// **'Nickname length should be between 2-20 characters'**
  String get nicknameLengthError;

  /// No description provided for @chooseSceneToStart.
  ///
  /// In en, this message translates to:
  /// **'Choose a scene to start learning!'**
  String get chooseSceneToStart;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Load failed'**
  String get loadFailed;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories'**
  String get noCategories;

  /// No description provided for @noScenes.
  ///
  /// In en, this message translates to:
  /// **'No scenes'**
  String get noScenes;

  /// No description provided for @playPronunciation.
  ///
  /// In en, this message translates to:
  /// **'Play pronunciation'**
  String get playPronunciation;

  /// No description provided for @clickItemHint.
  ///
  /// In en, this message translates to:
  /// **'Please click on items in the scene'**
  String get clickItemHint;

  /// Playing audio message
  ///
  /// In en, this message translates to:
  /// **'Playing audio: {name}'**
  String playingAudio(String name);

  /// No description provided for @learningRecordsInDev.
  ///
  /// In en, this message translates to:
  /// **'Learning records feature is under development'**
  String get learningRecordsInDev;

  /// No description provided for @favoritesInDev.
  ///
  /// In en, this message translates to:
  /// **'Favorites feature is under development'**
  String get favoritesInDev;

  /// No description provided for @settingsInDev.
  ///
  /// In en, this message translates to:
  /// **'Settings feature is under development'**
  String get settingsInDev;

  /// No description provided for @vocabularyInDev.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary feature is under development'**
  String get vocabularyInDev;

  /// No description provided for @simplifiedChinese.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get simplifiedChinese;

  /// No description provided for @traditionalChinese.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get traditionalChinese;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh': {
  switch (locale.countryCode) {
    case 'TW': return AppLocalizationsZhTw();
   }
  break;
   }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
