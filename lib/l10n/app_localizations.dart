import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

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
    Locale('id'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'NoteNest'**
  String get appName;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'v2.0.1'**
  String get version;

  /// No description provided for @reflect.
  ///
  /// In en, this message translates to:
  /// **'Reflect'**
  String get reflect;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search journals'**
  String get searchHint;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get filterFavorite;

  /// No description provided for @filterCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get filterCalm;

  /// No description provided for @filterGrateful.
  ///
  /// In en, this message translates to:
  /// **'Grateful'**
  String get filterGrateful;

  /// No description provided for @filterPeaceful.
  ///
  /// In en, this message translates to:
  /// **'Peaceful'**
  String get filterPeaceful;

  /// No description provided for @filterFocused.
  ///
  /// In en, this message translates to:
  /// **'Focused'**
  String get filterFocused;

  /// No description provided for @quoteMorning.
  ///
  /// In en, this message translates to:
  /// **'\"Start each day with a positive mind and a grateful heart.\"'**
  String get quoteMorning;

  /// No description provided for @quoteAfternoon.
  ///
  /// In en, this message translates to:
  /// **'\"The small things you are grateful for today can blossom into a great source of happiness.\"'**
  String get quoteAfternoon;

  /// No description provided for @quoteEvening.
  ///
  /// In en, this message translates to:
  /// **'\"Not everything has to be finished today. Give yourself time to rest.\"'**
  String get quoteEvening;

  /// No description provided for @quoteNight.
  ///
  /// In en, this message translates to:
  /// **'\"Bring your day to a peaceful close, and let tomorrow unfold a new story.\"'**
  String get quoteNight;

  /// No description provided for @todaysEntry.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Entry'**
  String get todaysEntry;

  /// No description provided for @noJournalsTitle.
  ///
  /// In en, this message translates to:
  /// **'No journals yet'**
  String get noJournalsTitle;

  /// No description provided for @noJournalsDesc.
  ///
  /// In en, this message translates to:
  /// **'Create a new entry and start writing about your first moment of the day.'**
  String get noJournalsDesc;

  /// No description provided for @noResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResultsTitle;

  /// No description provided for @noResultsDesc.
  ///
  /// In en, this message translates to:
  /// **'Try another keyword or change the mood filter.'**
  String get noResultsDesc;

  /// No description provided for @noFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesTitle;

  /// No description provided for @noFavoritesDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap the bookmark icon on a journal\nto mark it as favorite.'**
  String get noFavoritesDesc;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Journal?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'This journal will be permanently deleted and cannot be restored.'**
  String get deleteConfirmDesc;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Want to Delete All Journals?'**
  String get deleteAllTitle;

  /// No description provided for @deleteAllDesc.
  ///
  /// In en, this message translates to:
  /// **'All journals will be permanently deleted.'**
  String get deleteAllDesc;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @journalDeleted.
  ///
  /// In en, this message translates to:
  /// **'Journal deleted successfully'**
  String get journalDeleted;

  /// No description provided for @allJournalsDeleted.
  ///
  /// In en, this message translates to:
  /// **'All journals deleted successfully'**
  String get allJournalsDeleted;

  /// No description provided for @newEntry.
  ///
  /// In en, this message translates to:
  /// **'New Entry'**
  String get newEntry;

  /// No description provided for @editEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit Entry'**
  String get editEntry;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleHint;

  /// No description provided for @contentHint.
  ///
  /// In en, this message translates to:
  /// **'Start writing down your thoughts and feelings....'**
  String get contentHint;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Preset images'**
  String get selectImage;

  /// No description provided for @howFeeling.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get howFeeling;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @exportJournals.
  ///
  /// In en, this message translates to:
  /// **'Export Journals'**
  String get exportJournals;

  /// No description provided for @exportJournalsDesc.
  ///
  /// In en, this message translates to:
  /// **'Save all journals to a text file'**
  String get exportJournalsDesc;

  /// No description provided for @deleteAllJournals.
  ///
  /// In en, this message translates to:
  /// **'Delete All Journals'**
  String get deleteAllJournals;

  /// No description provided for @deleteAllJournalsDesc.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete all journal data'**
  String get deleteAllJournalsDesc;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutDesc.
  ///
  /// In en, this message translates to:
  /// **'A minimalist journal app to capture daily moments, self-reflection, and track your mood.'**
  String get aboutDesc;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'This application is currently under development; please report any bugs immediately.'**
  String get copyright;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @feedbackDesc.
  ///
  /// In en, this message translates to:
  /// **'Suggestions or bug reports'**
  String get feedbackDesc;

  /// No description provided for @madeWith.
  ///
  /// In en, this message translates to:
  /// **'© 2026 . All rights reserved.'**
  String get madeWith;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get stats;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @streakDesc.
  ///
  /// In en, this message translates to:
  /// **'Journaling streak'**
  String get streakDesc;

  /// No description provided for @startStreak.
  ///
  /// In en, this message translates to:
  /// **'Start your streak today!'**
  String get startStreak;

  /// No description provided for @totalJournals.
  ///
  /// In en, this message translates to:
  /// **'Total Journals'**
  String get totalJournals;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @weeklyChart.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get weeklyChart;

  /// No description provided for @moodDistribution.
  ///
  /// In en, this message translates to:
  /// **'Mood Distribution'**
  String get moodDistribution;

  /// No description provided for @topMood.
  ///
  /// In en, this message translates to:
  /// **'Top Mood'**
  String get topMood;

  /// No description provided for @noDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noDataTitle;

  /// No description provided for @noDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Write your first journal to\nsee statistics here.'**
  String get noDataDesc;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @indonesian.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get indonesian;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Write Your Reflections'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Desc.
  ///
  /// In en, this message translates to:
  /// **'Capture moments, thoughts, and feelings every day. No rules, no pressure.'**
  String get onboarding1Desc;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Track Your Mood'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Desc.
  ///
  /// In en, this message translates to:
  /// **'Choose a mood that represents your day. See your emotional patterns over time.'**
  String get onboarding2Desc;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'See Your Growth'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Desc.
  ///
  /// In en, this message translates to:
  /// **'Simple statistics help you understand yourself better.'**
  String get onboarding3Desc;

  /// No description provided for @exportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Journals exported successfully!'**
  String get exportedSuccessfully;

  /// No description provided for @nothingToExport.
  ///
  /// In en, this message translates to:
  /// **'No journals to export yet'**
  String get nothingToExport;

  /// No description provided for @journalsWithMood.
  ///
  /// In en, this message translates to:
  /// **'{count} journals with this mood'**
  String journalsWithMood(int count);

  /// No description provided for @journalDetail.
  ///
  /// In en, this message translates to:
  /// **'Journal Detail'**
  String get journalDetail;

  /// No description provided for @uploadFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Upload from gallery'**
  String get uploadFromGallery;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @tapToChoose.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose photo from your phone'**
  String get tapToChoose;

  /// No description provided for @tapToChange.
  ///
  /// In en, this message translates to:
  /// **'Tap to change photo'**
  String get tapToChange;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload photo'**
  String get uploadPhoto;

  /// No description provided for @galleryOption.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryOption;

  /// No description provided for @galleryOptionDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose existing photo'**
  String get galleryOptionDesc;

  /// No description provided for @cameraOption.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraOption;

  /// No description provided for @cameraOptionDesc.
  ///
  /// In en, this message translates to:
  /// **'Take photo directly'**
  String get cameraOptionDesc;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get reminder;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get dailyReminder;

  /// No description provided for @dailyReminderDesc.
  ///
  /// In en, this message translates to:
  /// **'A notification will appear if the toggle switch is enabled.'**
  String get dailyReminderDesc;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// No description provided for @reminderMessage.
  ///
  /// In en, this message translates to:
  /// **'Reminder Message'**
  String get reminderMessage;

  /// No description provided for @reminderMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Write your custom reminder message...'**
  String get reminderMessageHint;

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotification;

  /// No description provided for @testNotificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Send a test notification now'**
  String get testNotificationDesc;

  /// No description provided for @notificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent!'**
  String get notificationSent;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission denied. Please enable in Settings.'**
  String get permissionDenied;

  /// No description provided for @reminderSaved.
  ///
  /// In en, this message translates to:
  /// **'Reminder saved successfully!'**
  String get reminderSaved;

  /// No description provided for @languageDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose the language that suits you; change it at any time.'**
  String get languageDesc;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @aboutFeatures.
  ///
  /// In en, this message translates to:
  /// **'Key Features'**
  String get aboutFeatures;

  /// No description provided for @aboutFeature1.
  ///
  /// In en, this message translates to:
  /// **'Write, edit, and delete journal entries'**
  String get aboutFeature1;

  /// No description provided for @aboutFeature2.
  ///
  /// In en, this message translates to:
  /// **'Upload photos from gallery or camera'**
  String get aboutFeature2;

  /// No description provided for @aboutFeature3.
  ///
  /// In en, this message translates to:
  /// **'Track your mood with 4 options'**
  String get aboutFeature3;

  /// No description provided for @aboutFeature4.
  ///
  /// In en, this message translates to:
  /// **'Statistics with streak, calendar, and charts'**
  String get aboutFeature4;

  /// No description provided for @aboutFeature5.
  ///
  /// In en, this message translates to:
  /// **'Multi-language (English & Indonesian)'**
  String get aboutFeature5;

  /// No description provided for @aboutDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get aboutDeveloper;

  /// No description provided for @aboutFollowMe.
  ///
  /// In en, this message translates to:
  /// **'Follow on Instagram'**
  String get aboutFollowMe;

  /// No description provided for @aboutInstagramHandle.
  ///
  /// In en, this message translates to:
  /// **'imnotferrriii'**
  String get aboutInstagramHandle;

  /// No description provided for @sourceCode.
  ///
  /// In en, this message translates to:
  /// **'View Repository on GitHub'**
  String get sourceCode;

  /// No description provided for @sourceCodeDesc.
  ///
  /// In en, this message translates to:
  /// **'Check out all these projects in the GitHub repository'**
  String get sourceCodeDesc;

  /// No description provided for @sendFeedbackOptions.
  ///
  /// In en, this message translates to:
  /// **'Select an option to send feedback.'**
  String get sendFeedbackOptions;

  /// No description provided for @viaEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get viaEmail;

  /// No description provided for @viaWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get viaWhatsApp;

  /// No description provided for @noWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp is not installed'**
  String get noWhatsApp;

  /// No description provided for @feedbackMessage.
  ///
  /// In en, this message translates to:
  /// **'Hello Feri, I would like to provide feedback on NoteNest:\n\n'**
  String get feedbackMessage;

  /// No description provided for @aboutGithubHandle.
  ///
  /// In en, this message translates to:
  /// **'FerrCodes'**
  String get aboutGithubHandle;

  /// No description provided for @aboutDeveloperName.
  ///
  /// In en, this message translates to:
  /// **'Feri'**
  String get aboutDeveloperName;

  /// No description provided for @socialMedia.
  ///
  /// In en, this message translates to:
  /// **'Social Media'**
  String get socialMedia;

  /// No description provided for @socialMediaDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect with the developer'**
  String get socialMediaDesc;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'A minimalist journal app to capture daily moments, self-reflection, and track your mood. Works fully offline.'**
  String get appDescription;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @dangerZoneDesc.
  ///
  /// In en, this message translates to:
  /// **'These actions cannot be undone'**
  String get dangerZoneDesc;

  /// No description provided for @resetSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get resetSettings;

  /// No description provided for @resetSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Reset language and notification to default'**
  String get resetSettingsDesc;

  /// No description provided for @resetSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings?'**
  String get resetSettingsTitle;

  /// No description provided for @resetSettingsConfirm.
  ///
  /// In en, this message translates to:
  /// **'All settings will be reset to default. Your journals will not be deleted.'**
  String get resetSettingsConfirm;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Settings reset successfully'**
  String get settingsReset;

  /// No description provided for @incompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Incomplete Journal'**
  String get incompleteTitle;

  /// No description provided for @incompleteDesc.
  ///
  /// In en, this message translates to:
  /// **'Please complete the following before saving:'**
  String get incompleteDesc;

  /// No description provided for @missingTitle.
  ///
  /// In en, this message translates to:
  /// **'Title is empty'**
  String get missingTitle;

  /// No description provided for @missingContent.
  ///
  /// In en, this message translates to:
  /// **'Content is empty'**
  String get missingContent;

  /// No description provided for @missingImage.
  ///
  /// In en, this message translates to:
  /// **'Please select a photo'**
  String get missingImage;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @draftFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Draft Found'**
  String get draftFoundTitle;

  /// No description provided for @draftFoundDesc.
  ///
  /// In en, this message translates to:
  /// **'There is an unfinished journal entry. Continue?'**
  String get draftFoundDesc;

  /// No description provided for @continueDraft.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueDraft;

  /// No description provided for @discardDraft.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardDraft;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved automatically'**
  String get draftSaved;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get feedbackTitle;

  /// No description provided for @feedbackWhatHappened.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get feedbackWhatHappened;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us about the issue you encountered'**
  String get feedbackHint;

  /// No description provided for @feedbackDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This feedback will provide improvements and enhance the experience for this application.'**
  String get feedbackDisclaimer;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @personalization.
  ///
  /// In en, this message translates to:
  /// **'Personalization'**
  String get personalization;

  /// No description provided for @manageMoods.
  ///
  /// In en, this message translates to:
  /// **'Manage Moods'**
  String get manageMoods;

  /// No description provided for @manageMoodsDesc.
  ///
  /// In en, this message translates to:
  /// **'Create your own custom mood'**
  String get manageMoodsDesc;

  /// No description provided for @customMoods.
  ///
  /// In en, this message translates to:
  /// **'Custom Moods'**
  String get customMoods;

  /// No description provided for @addMood.
  ///
  /// In en, this message translates to:
  /// **'Add Mood'**
  String get addMood;

  /// No description provided for @newMood.
  ///
  /// In en, this message translates to:
  /// **'New Mood'**
  String get newMood;

  /// No description provided for @moodNameHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Anxious, Excited, Tired...'**
  String get moodNameHint;

  /// No description provided for @moodLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum 10 custom moods reached'**
  String get moodLimitReached;

  /// No description provided for @moodAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This mood name is already used'**
  String get moodAlreadyExists;

  /// No description provided for @moodAdded.
  ///
  /// In en, this message translates to:
  /// **'Mood added successfully'**
  String get moodAdded;

  /// No description provided for @moodDeleted.
  ///
  /// In en, this message translates to:
  /// **'Mood deleted'**
  String get moodDeleted;

  /// No description provided for @deleteMoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Mood?'**
  String get deleteMoodTitle;

  /// No description provided for @deleteMoodDesc.
  ///
  /// In en, this message translates to:
  /// **'Journals with this mood will still keep the label.'**
  String get deleteMoodDesc;

  /// No description provided for @noCustomMoods.
  ///
  /// In en, this message translates to:
  /// **'No custom moods yet'**
  String get noCustomMoods;

  /// No description provided for @noCustomMoodsDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add Mood\" to create your first custom mood.'**
  String get noCustomMoodsDesc;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @archiveMoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive Mood?'**
  String get archiveMoodTitle;

  /// No description provided for @archiveMoodDesc.
  ///
  /// In en, this message translates to:
  /// **'This mood will be hidden from the new journal page. It can be restored later.'**
  String get archiveMoodDesc;

  /// No description provided for @moodArchived.
  ///
  /// In en, this message translates to:
  /// **'Mood archived'**
  String get moodArchived;

  /// No description provided for @moodRestored.
  ///
  /// In en, this message translates to:
  /// **'Mood restored'**
  String get moodRestored;

  /// No description provided for @deletePermanentTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently?'**
  String get deletePermanentTitle;

  /// No description provided for @deletePermanentDesc.
  ///
  /// In en, this message translates to:
  /// **'This mood will be permanently deleted.'**
  String get deletePermanentDesc;

  /// No description provided for @moodDeletedPermanent.
  ///
  /// In en, this message translates to:
  /// **'Mood deleted permanently'**
  String get moodDeletedPermanent;

  /// No description provided for @moodColor.
  ///
  /// In en, this message translates to:
  /// **'Mood Color'**
  String get moodColor;

  /// No description provided for @dropdownHint.
  ///
  /// In en, this message translates to:
  /// **'Tap for menu'**
  String get dropdownHint;

  /// No description provided for @headerSection.
  ///
  /// In en, this message translates to:
  /// **'Customize the header'**
  String get headerSection;

  /// No description provided for @headerScreenDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure all header displays on the homepage.'**
  String get headerScreenDesc;

  /// No description provided for @displaySection.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get displaySection;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get userName;

  /// No description provided for @userNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get userNameHint;

  /// No description provided for @showDate.
  ///
  /// In en, this message translates to:
  /// **'Show Date'**
  String get showDate;

  /// No description provided for @showDateDesc.
  ///
  /// In en, this message translates to:
  /// **'Display today\'s date'**
  String get showDateDesc;

  /// No description provided for @showTime.
  ///
  /// In en, this message translates to:
  /// **'Show Time'**
  String get showTime;

  /// No description provided for @showTimeDesc.
  ///
  /// In en, this message translates to:
  /// **'Display current time'**
  String get showTimeDesc;

  /// No description provided for @showWeather.
  ///
  /// In en, this message translates to:
  /// **'Show Weather'**
  String get showWeather;

  /// No description provided for @showWeatherDesc.
  ///
  /// In en, this message translates to:
  /// **'Requires an internet connection'**
  String get showWeatherDesc;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon,'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening,'**
  String get greetingEvening;

  /// No description provided for @greetingNight.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get greetingNight;

  /// No description provided for @filterExcited.
  ///
  /// In en, this message translates to:
  /// **'Excited'**
  String get filterExcited;

  /// No description provided for @betaFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Beta Feature'**
  String get betaFeatureTitle;

  /// No description provided for @betaFeatureDesc.
  ///
  /// In en, this message translates to:
  /// **'Weather feature is currently in beta. It may not always work as expected.'**
  String get betaFeatureDesc;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @permissionsSection.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get permissionsSection;

  /// No description provided for @permissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Devices Permission'**
  String get permissionsTitle;

  /// No description provided for @permissionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage and view all the permissions an app needs to function optimally here.'**
  String get permissionsDesc;

  /// No description provided for @permissionsListSection.
  ///
  /// In en, this message translates to:
  /// **'REQUIRED PERMITS'**
  String get permissionsListSection;

  /// No description provided for @permissionStatusGranted.
  ///
  /// In en, this message translates to:
  /// **'GRANTED'**
  String get permissionStatusGranted;

  /// No description provided for @permissionStatusDenied.
  ///
  /// In en, this message translates to:
  /// **'DENIED'**
  String get permissionStatusDenied;

  /// No description provided for @permissionStatusNotRequested.
  ///
  /// In en, this message translates to:
  /// **'NOT REQUESTED'**
  String get permissionStatusNotRequested;

  /// No description provided for @permissionStatusRestricted.
  ///
  /// In en, this message translates to:
  /// **'RESTRICTED'**
  String get permissionStatusRestricted;

  /// No description provided for @permissionNotification.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get permissionNotification;

  /// No description provided for @permissionNotificationDesc.
  ///
  /// In en, this message translates to:
  /// **'For daily reminders'**
  String get permissionNotificationDesc;

  /// No description provided for @permissionLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get permissionLocation;

  /// No description provided for @permissionLocationDesc.
  ///
  /// In en, this message translates to:
  /// **'For weather feature'**
  String get permissionLocationDesc;

  /// No description provided for @permissionCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get permissionCamera;

  /// No description provided for @permissionCameraDesc.
  ///
  /// In en, this message translates to:
  /// **'For journal photos'**
  String get permissionCameraDesc;

  /// No description provided for @permissionGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get permissionGallery;

  /// No description provided for @permissionGalleryDesc.
  ///
  /// In en, this message translates to:
  /// **'For journal photos'**
  String get permissionGalleryDesc;

  /// No description provided for @permissionTapToOpen.
  ///
  /// In en, this message translates to:
  /// **'Tap to open the phone\'s built-in permission settings.'**
  String get permissionTapToOpen;

  /// No description provided for @permissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Permission granted!'**
  String get permissionGranted;

  /// No description provided for @permissionSamsungHint.
  ///
  /// In en, this message translates to:
  /// **'On Samsung devices, need to tap \"Permissions\" on the next page to manage permissions.'**
  String get permissionSamsungHint;

  /// No description provided for @guideSection.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get guideSection;

  /// No description provided for @guideTitle.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get guideTitle;

  /// No description provided for @guideDesc.
  ///
  /// In en, this message translates to:
  /// **'Some features of this app are somewhat hidden; see them all here.'**
  String get guideDesc;

  /// No description provided for @guideHiddenFeatures.
  ///
  /// In en, this message translates to:
  /// **'HIDDEN FEATURES'**
  String get guideHiddenFeatures;

  /// No description provided for @guideDropdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Hidden Dropdown'**
  String get guideDropdownTitle;

  /// No description provided for @guideDropdownDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap the \"Reflect\" text at the top of the home screen to reveal a hidden menu. Inside, you\'ll find options like Manage Moods and Home Header settings.'**
  String get guideDropdownDesc;

  /// No description provided for @guideCarouselTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo Carousel'**
  String get guideCarouselTitle;

  /// No description provided for @guideCarouselDesc.
  ///
  /// In en, this message translates to:
  /// **'Open a journal with multiple photos and swipe to view each one. Tap a photo to see it full-screen with zoom.'**
  String get guideCarouselDesc;

  /// No description provided for @guideFooter.
  ///
  /// In en, this message translates to:
  /// **'Thank you for trying out all the available features!'**
  String get guideFooter;

  /// No description provided for @generalSection.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSection;

  /// No description provided for @appSection.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get appSection;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System (Default)'**
  String get languageSystem;

  /// No description provided for @permissionBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Permission Blocked'**
  String get permissionBlockedTitle;

  /// No description provided for @permissionBlockedDesc.
  ///
  /// In en, this message translates to:
  /// **'The permission request was denied after being rejected twice. To enable it, open the Permissions page.'**
  String get permissionBlockedDesc;

  /// No description provided for @openPermissionPage.
  ///
  /// In en, this message translates to:
  /// **'See it now'**
  String get openPermissionPage;

  /// No description provided for @hapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// No description provided for @hapticFeedbackDesc.
  ///
  /// In en, this message translates to:
  /// **'Vibrate on interactions'**
  String get hapticFeedbackDesc;

  /// No description provided for @viewOtherOptions.
  ///
  /// In en, this message translates to:
  /// **'View other options'**
  String get viewOtherOptions;

  /// No description provided for @journalDate.
  ///
  /// In en, this message translates to:
  /// **'Journal Date:'**
  String get journalDate;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @pressBackAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get pressBackAgainToExit;

  /// No description provided for @legalSection.
  ///
  /// In en, this message translates to:
  /// **'Legal & Privacy'**
  String get legalSection;

  /// No description provided for @readingTime.
  ///
  /// In en, this message translates to:
  /// **'{count} min read'**
  String readingTime(int count);

  /// No description provided for @wordCount.
  ///
  /// In en, this message translates to:
  /// **'{count} words'**
  String wordCount(int count);

  /// No description provided for @editedTime.
  ///
  /// In en, this message translates to:
  /// **'Edited {time}'**
  String editedTime(String time);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @monthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} months ago'**
  String monthsAgo(int count);

  /// No description provided for @yearsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} years ago'**
  String yearsAgo(int count);

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;
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
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
