// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Memos';

  @override
  String get homeGreeting => 'Good morning!';

  @override
  String get homeSummary => 'You have 4 memos today.';

  @override
  String get memo1 => 'Buy groceries';

  @override
  String get memo2 => 'Call the doctor';

  @override
  String get memo3 => 'Review pull requests';

  @override
  String get memo4 => 'Read for 30 minutes';

  @override
  String get detailTitle => 'Details';

  @override
  String get detailHeadline => 'Stay Organised';

  @override
  String get detailBody =>
      'Capture ideas, reminders, and to-dos — all in one place.';

  @override
  String get cta => 'Create memo';

  @override
  String get statsTitle => 'Stats';

  @override
  String get statTotal => 'Total memos';

  @override
  String get statWeek => 'Added this week';

  @override
  String get statTags => 'Tags used';
}
