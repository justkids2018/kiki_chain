import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Hi Kiki';

  @override
  String get welcome => 'Welcome';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get noAccountYet => 'Don\'t have an account yet?';

  @override
  String get loading => 'Loading...';

  @override
  String get confirm => 'Confirm';

  @override
  String get username => 'Username';

  @override
  String get home => 'Home';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get noData => 'No data available';

  @override
  String get retry => 'Retry';

  @override
  String get search => 'Search';

  @override
  String get send => 'Send';

  @override
  String get chat => 'Chat';

  @override
  String get message => 'Message';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get pleaseLoginToAccount => 'Please login to your account';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get clickToLogin => 'Click to login';

  @override
  String get learningStats => 'Learning Statistics';

  @override
  String get viewProgressAndAchievements =>
      'View learning progress and achievements';

  @override
  String get featureTip => 'Feature Tip';

  @override
  String get learningStatsInDevelopment =>
      'Learning statistics feature is under development';

  @override
  String get favorites => 'Favorites';

  @override
  String get manageFavoriteWords => 'Manage favorite words';

  @override
  String get favoritesInDevelopment => 'Favorites feature is under development';

  @override
  String get learningHistory => 'Learning History';

  @override
  String get viewLearningRecords => 'View learning records';

  @override
  String get learningHistoryInDevelopment =>
      'Learning history feature is under development';

  @override
  String get personalPreferences => 'Personal preferences';

  @override
  String get helpAndFeedback => 'Help & Feedback';

  @override
  String get getHelpOrProvideFeedback => 'Get help or provide feedback';

  @override
  String get helpInDevelopment => 'Help feature is under development';

  @override
  String get about => 'About';

  @override
  String get versionInfo => 'Version information';

  @override
  String get logOut => 'Log Out';

  @override
  String get safelyExitApp => 'Safely exit the app';

  @override
  String get close => 'Close';

  @override
  String get groundedTheory => 'Grounded Theory';

  @override
  String get version100 => 'Version 1.0.0';

  @override
  String get appDescription =>
      'A simple and easy-to-use vocabulary learning app that helps you master new vocabulary easily.';

  @override
  String get confirmExit => 'Confirm Exit';

  @override
  String get confirmLogoutMessage => 'Are you sure you want to log out?';

  @override
  String get exit => 'Exit';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get quickSwitch => 'Quick Switch';

  @override
  String get featureDemo => 'Feature Demo';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get createAccount => 'Create Account';

  @override
  String get fillInfoToRegister =>
      'Fill in information to complete registration';

  @override
  String get nicknameOptional => 'Nickname (optional, 2-20 characters)';

  @override
  String get passwordRequirement =>
      'Password (6-20 characters, must contain letters and numbers)';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get loginNow => 'Login Now';

  @override
  String get hiPleaseLogin => 'Hi, please login';

  @override
  String get loginToViewRecords =>
      'Login to view learning records and favorites';

  @override
  String get phoneLabel => 'Phone: ';

  @override
  String get learningRecords => 'Learning Records';

  @override
  String get myFavorites => 'My Favorites';

  @override
  String get nickname => 'Nickname';

  @override
  String get newBadge => 'NEW';

  @override
  String itemsCount(int count) {
    return '$count items';
  }

  @override
  String scenesCount(int count) {
    return '$count scenes';
  }

  @override
  String get defaultUser => 'User';

  @override
  String get hint => 'Hint';

  @override
  String get loggingIn => 'Logging in...';

  @override
  String get loginFailed => 'Login failed, please try again';

  @override
  String get loginSuccess => 'Login successful';

  @override
  String get registering => 'Registering...';

  @override
  String get registerSuccess => 'Registration successful';

  @override
  String get registerFailed => 'Registration failed, please try again';

  @override
  String get registerDataEmpty =>
      'Registration data is empty, please try again later';

  @override
  String get pleaseTryAgainLater => ', please try again later';

  @override
  String get loggingOut => 'Logging out...';

  @override
  String get loggedOut => 'Logged out successfully';

  @override
  String get logoutFailed => 'Logout failed';

  @override
  String get guestModeFailed => 'Failed to enter guest mode';

  @override
  String get pleaseEnterPhone => 'Please enter phone number';

  @override
  String get pleaseEnterValidPhone => 'Please enter a valid phone number';

  @override
  String get pleaseEnterPassword => 'Please enter password';

  @override
  String get passwordLengthError =>
      'Password length should be between 6-20 characters';

  @override
  String get passwordFormatError => 'Password must contain letters and numbers';

  @override
  String get pleaseEnterPasswordAgain => 'Please enter password again';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get nicknameLengthError =>
      'Nickname length should be between 2-20 characters';

  @override
  String get chooseSceneToStart => 'Choose a scene to start learning!';

  @override
  String get loadFailed => 'Load failed';

  @override
  String get noCategories => 'No categories';

  @override
  String get noScenes => 'No scenes';

  @override
  String get playPronunciation => 'Play pronunciation';

  @override
  String get clickItemHint => 'Please click on items in the scene';

  @override
  String playingAudio(String name) {
    return 'Playing audio: $name';
  }

  @override
  String get learningRecordsInDev =>
      'Learning records feature is under development';

  @override
  String get favoritesInDev => 'Favorites feature is under development';

  @override
  String get settingsInDev => 'Settings feature is under development';

  @override
  String get vocabularyInDev => 'Vocabulary feature is under development';

  @override
  String get temporaryName => 'Temporary';

  @override
  String get noneValue => 'None';

  @override
  String get userId => 'User ID';

  @override
  String get myInfo => 'My Info';

  @override
  String get accountAndSecurity => 'Account & Security';

  @override
  String get messageNotifications => 'Message Notifications';

  @override
  String get languageSwitch => 'Language Switch';

  @override
  String get personalInfo => 'Personal Info';

  @override
  String get registeredAt => 'Registered At';

  @override
  String get lastLogin => 'Last Login';

  @override
  String get profileReadonlyHint =>
      'Note: This version supports viewing information only. Editing will be available later.';

  @override
  String get profileCenter => 'Profile Center';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get forgotPasswordNotAvailable =>
      'Password recovery is not available yet. Please clear and re-enter your account and password.';

  @override
  String get clearAndRetry => 'Clear and Retry';

  @override
  String get termsAgreementText =>
      'I have read and agree to the User Agreement and Privacy Policy';

  @override
  String get aboutUs => 'About Us';

  @override
  String get versionPrefix => 'Version';

  @override
  String get aboutDescription =>
      'Hi Kiki helps children build vocabulary understanding and writing skills together through scene-based learning, stroke order practice, and writing exercises.';

  @override
  String contactEmailHint(String email) {
    return 'If you have suggestions, contact us: $email';
  }

  @override
  String get noMailClientDetected => 'No available mail client detected';

  @override
  String get openMailFailed =>
      'Failed to open mail app. Please try again later';

  @override
  String emailCopied(String email) {
    return 'Email copied: $email';
  }

  @override
  String get feedbackSubmitSuccess =>
      'Feedback submitted successfully. Thanks for your suggestion';

  @override
  String get feedbackSubmitFailed => 'Submit failed. Please try again later';

  @override
  String get feedbackHeadline => 'We value every suggestion you share';

  @override
  String get feedbackDescription =>
      'Please choose a type and describe your issue. After submission, admins will review it in the backend.';

  @override
  String get feedbackTypeLabel => 'Feedback type';

  @override
  String get feedbackTypeGeneral => 'Product suggestion';

  @override
  String get feedbackTypeBug => 'Bug report';

  @override
  String get feedbackTypeContent => 'Content correction';

  @override
  String get feedbackTypeAccount => 'Account issue';

  @override
  String get feedbackContentHint =>
      'Please describe your issue or suggestion in detail';

  @override
  String get feedbackContentRequired => 'Please enter feedback content';

  @override
  String get feedbackContentTooShort =>
      'Feedback content must be at least 2 characters';

  @override
  String get feedbackContactHint => 'Contact info (optional, e.g. phone/email)';

  @override
  String get submittingFeedback => 'Submitting...';

  @override
  String get submitFeedback => 'Submit Feedback';

  @override
  String get interactiveLearning => 'Interactive Learning';

  @override
  String get startLearning => 'Start Learning';

  @override
  String get strokePractice => 'Stroke Practice';

  @override
  String get simplifiedChinese => 'Simplified Chinese';

  @override
  String get traditionalChinese => 'Traditional Chinese';
}
