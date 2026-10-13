// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'NoteNest';

  @override
  String get reflect => 'Reflect';

  @override
  String get searchHint => 'Search journals';

  @override
  String get filterAll => 'All';

  @override
  String get filterFavorite => 'Favorite';

  @override
  String get filterCalm => 'Calm';

  @override
  String get filterGrateful => 'Grateful';

  @override
  String get filterPeaceful => 'Peaceful';

  @override
  String get filterFocused => 'Focused';

  @override
  String get quoteMorning =>
      '\"Every morning brings new potential. Start today with intention.\"';

  @override
  String get quoteAfternoon => '\"Gratitude turns what we have into enough.\"';

  @override
  String get quoteEvening =>
      '\"Small shifts in perspective can open the door to profound inner stillness.\"';

  @override
  String get quoteNight =>
      '\"The quiet of night is where the soul finds its rest.\"';

  @override
  String get todaysEntry => 'Today\'s Entry';

  @override
  String get noJournalsTitle => 'No journals yet';

  @override
  String get noJournalsDesc =>
      'Create a new entry and start writing about your first moment of the day.';

  @override
  String get noResultsTitle => 'No results';

  @override
  String get noResultsDesc => 'Try another keyword or change the mood filter.';

  @override
  String get noFavoritesTitle => 'No favorites yet';

  @override
  String get noFavoritesDesc =>
      'Tap the bookmark icon on a journal\nto mark it as favorite.';

  @override
  String get deleteConfirmTitle => 'Delete Journal?';

  @override
  String get deleteConfirmDesc =>
      'This journal will be permanently deleted and cannot be restored.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteAllTitle => 'Want to Delete All Journals?';

  @override
  String get deleteAllDesc => 'All journals will be permanently deleted.';

  @override
  String get deleteAll => 'Delete All';

  @override
  String get journalDeleted => 'Journal deleted successfully';

  @override
  String get allJournalsDeleted => 'All journals deleted successfully';

  @override
  String get newEntry => 'New Entry';

  @override
  String get editEntry => 'Edit Entry';

  @override
  String get save => 'Save';

  @override
  String get update => 'Update';

  @override
  String get titleHint => 'Title';

  @override
  String get contentHint => 'Start writing your thoughts...';

  @override
  String get selectImage => 'Preset images';

  @override
  String get howFeeling => 'How are you feeling?';

  @override
  String get settings => 'Settings';

  @override
  String get data => 'Data';

  @override
  String get exportJournals => 'Export Journals';

  @override
  String get exportJournalsDesc => 'Save all journals to a text file';

  @override
  String get deleteAllJournals => 'Delete All Journals';

  @override
  String get deleteAllJournalsDesc => 'Permanently delete all journal data';

  @override
  String get about => 'About';

  @override
  String get aboutDesc =>
      'A minimalist journal app to capture daily moments, self-reflection, and track your mood.';

  @override
  String get copyright =>
      'This application is currently under development; please report any bugs immediately.';

  @override
  String get aboutApp => 'About App';

  @override
  String get version => 'v1.1.0';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get feedbackDesc => 'Suggestions or bug reports';

  @override
  String get madeWith => '© 2026 . All rights reserved.';

  @override
  String get stats => 'Statistics';

  @override
  String get streak => 'Streak';

  @override
  String get days => 'Days';

  @override
  String get streakDesc => 'Journaling streak';

  @override
  String get startStreak => 'Start your streak today!';

  @override
  String get totalJournals => 'Total Journals';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get weeklyChart => 'Last 7 Days';

  @override
  String get moodDistribution => 'Mood Distribution';

  @override
  String get topMood => 'Top Mood';

  @override
  String get noDataTitle => 'No data yet';

  @override
  String get noDataDesc => 'Write your first journal to\nsee statistics here.';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get indonesian => 'Bahasa Indonesia';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get onboarding1Title => 'Write Your Reflections';

  @override
  String get onboarding1Desc =>
      'Capture moments, thoughts, and feelings every day. No rules, no pressure.';

  @override
  String get onboarding2Title => 'Track Your Mood';

  @override
  String get onboarding2Desc =>
      'Choose a mood that represents your day. See your emotional patterns over time.';

  @override
  String get onboarding3Title => 'See Your Growth';

  @override
  String get onboarding3Desc =>
      'Simple statistics help you understand yourself better.';

  @override
  String get exportedSuccessfully => 'Journals exported successfully!';

  @override
  String get nothingToExport => 'No journals to export yet';

  @override
  String journalsWithMood(int count) {
    return '$count journals with this mood';
  }

  @override
  String get journalDetail => 'Journal Detail';

  @override
  String get uploadFromGallery => 'Upload from gallery';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get tapToChoose => 'Tap to choose photo from your phone';

  @override
  String get tapToChange => 'Tap to change photo';

  @override
  String get uploadPhoto => 'Upload photo';

  @override
  String get galleryOption => 'Gallery';

  @override
  String get galleryOptionDesc => 'Choose existing photo';

  @override
  String get cameraOption => 'Camera';

  @override
  String get cameraOptionDesc => 'Take photo directly';

  @override
  String get gotIt => 'Got it';

  @override
  String get reminder => 'Notification';

  @override
  String get dailyReminder => 'Daily Reminder';

  @override
  String get dailyReminderDesc => 'Get notified to write your journal';

  @override
  String get reminderTime => 'Reminder Time';

  @override
  String get reminderMessage => 'Reminder Message';

  @override
  String get reminderMessageHint => 'Write your custom reminder message...';

  @override
  String get testNotification => 'Test Notification';

  @override
  String get testNotificationDesc => 'Send a test notification now';

  @override
  String get notificationSent => 'Test notification sent!';

  @override
  String get permissionDenied =>
      'Notification permission denied. Please enable in Settings.';

  @override
  String get reminderSaved => 'Reminder saved successfully!';

  @override
  String get languageDesc =>
      'Choose the most suitable language, it can be changed at any time.';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get aboutFeatures => 'Key Features';

  @override
  String get aboutFeature1 => 'Write, edit, and delete journal entries';

  @override
  String get aboutFeature2 => 'Upload photos from gallery or camera';

  @override
  String get aboutFeature3 => 'Track your mood with 4 options';

  @override
  String get aboutFeature4 => 'Statistics with streak, calendar, and charts';

  @override
  String get aboutFeature5 => 'Multi-language (English & Indonesian)';

  @override
  String get aboutDeveloper => 'Developer';

  @override
  String get aboutFollowMe => 'Follow me on Instagram';

  @override
  String get aboutInstagramHandle => 'imnotferrriii';

  @override
  String get sourceCode => 'View Repository on GitHub';

  @override
  String get sourceCodeDesc =>
      'Check out all these projects in the GitHub repository';

  @override
  String get sendFeedbackOptions => 'Select an option to send feedback.';

  @override
  String get viaEmail => 'Email';

  @override
  String get viaWhatsApp => 'WhatsApp';

  @override
  String get noWhatsApp => 'WhatsApp is not installed';

  @override
  String get feedbackMessage =>
      'Hello Feri, I would like to provide feedback on NoteNest:\n\n';

  @override
  String get aboutGithubHandle => 'FerrCodes';

  @override
  String get aboutDeveloperName => 'Feri';

  @override
  String get socialMedia => 'Social Media';

  @override
  String get socialMediaDesc => 'Connect with the developer';

  @override
  String get appDescription =>
      'A minimalist journal app to capture daily moments, self-reflection, and track your mood. Works fully offline.';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get dangerZoneDesc => 'These actions cannot be undone';

  @override
  String get resetSettings => 'Reset Settings';

  @override
  String get resetSettingsDesc => 'Reset language and notification to default';

  @override
  String get resetSettingsTitle => 'Reset Settings?';

  @override
  String get resetSettingsConfirm =>
      'All settings will be reset to default. Your journals will not be deleted.';

  @override
  String get reset => 'Reset';

  @override
  String get settingsReset => 'Settings reset successfully';

  @override
  String get incompleteTitle => 'Incomplete Journal';

  @override
  String get incompleteDesc => 'Please complete the following before saving:';

  @override
  String get missingTitle => 'Journal title is empty';

  @override
  String get missingContent => 'Journal content is empty';

  @override
  String get missingImage => 'Please select a photo';

  @override
  String get ok => 'OK';

  @override
  String get draftFoundTitle => 'Unsaved Draft Found';

  @override
  String get draftFoundDesc => 'Unfinished journal. Continue?';

  @override
  String get continueDraft => 'Continue';

  @override
  String get discardDraft => 'Discard';

  @override
  String get draftSaved => 'Draft saved automatically';

  @override
  String get feedbackTitle => 'Send Feedback';

  @override
  String get feedbackWhatHappened => 'What happened?';

  @override
  String get feedbackHint => 'Tell us about the issue you encountered';

  @override
  String get feedbackDisclaimer =>
      'Your feedback can be used to improve NoteNest.';

  @override
  String get send => 'Send';

  @override
  String get personalization => 'Personalization';

  @override
  String get manageMoods => 'Manage Moods';

  @override
  String get manageMoodsDesc => 'Create your own custom moods';

  @override
  String get customMoods => 'Custom Moods';

  @override
  String get addMood => 'Add Mood';

  @override
  String get newMood => 'New Mood';

  @override
  String get moodNameHint => 'e.g. Anxious, Excited, Tired...';

  @override
  String get moodLimitReached => 'Maximum 10 custom moods reached';

  @override
  String get moodAlreadyExists => 'This mood name is already used';

  @override
  String get moodAdded => 'Mood added successfully';

  @override
  String get moodDeleted => 'Mood deleted';

  @override
  String get deleteMoodTitle => 'Delete Mood?';

  @override
  String get deleteMoodDesc =>
      'Journals with this mood will still keep the label.';

  @override
  String get noCustomMoods => 'No custom moods yet';

  @override
  String get noCustomMoodsDesc =>
      'Tap \"Add Mood\" to create your first custom mood.';

  @override
  String get archive => 'Archive';

  @override
  String get archiveMoodTitle => 'Archive Mood?';

  @override
  String get archiveMoodDesc =>
      'This mood will be hidden. You can restore it later from the Archive section.';

  @override
  String get moodArchived => 'Mood archived';

  @override
  String get moodRestored => 'Mood restored';

  @override
  String get deletePermanentTitle => 'Delete Permanently?';

  @override
  String get deletePermanentDesc =>
      'This mood will be permanently deleted. This action cannot be undone.';

  @override
  String get moodDeletedPermanent => 'Mood deleted permanently';

  @override
  String get moodColor => 'Mood Color';

  @override
  String get dropdownHint => 'Tap for menu';

  @override
  String get headerSection => 'Customize the header';

  @override
  String get headerScreenDesc =>
      'Customize your home screen header. Turn on or off what you need.';

  @override
  String get displaySection => 'Display';

  @override
  String get userName => 'Your Name';

  @override
  String get userNameHint => 'Enter your name';

  @override
  String get showDate => 'Show Date';

  @override
  String get showDateDesc => 'Display today\'s date';

  @override
  String get showTime => 'Show Time';

  @override
  String get showTimeDesc => 'Display current time';

  @override
  String get showWeather => 'Show Weather';

  @override
  String get showWeatherDesc => 'Display weather (requires internet)';

  @override
  String get greetingMorning => 'Good morning,';

  @override
  String get greetingAfternoon => 'Good afternoon,';

  @override
  String get greetingEvening => 'Good evening,';

  @override
  String get greetingNight => 'Good night';

  @override
  String readingTime(int count) {
    return '$count min read';
  }

  @override
  String wordCount(int count) {
    return '$count words';
  }

  @override
  String editedTime(String time) {
    return 'Edited $time';
  }

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(int count) {
    return '$count minutes ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count hours ago';
  }

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String monthsAgo(int count) {
    return '$count months ago';
  }

  @override
  String yearsAgo(int count) {
    return '$count years ago';
  }

  @override
  String get edit => 'Edit';
}
