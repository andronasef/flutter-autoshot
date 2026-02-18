// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Notizen';

  @override
  String get homeGreeting => 'Guten Morgen!';

  @override
  String get homeSummary => 'Du hast heute 4 Notizen.';

  @override
  String get memo1 => 'Einkaufen gehen';

  @override
  String get memo2 => 'Arzt anrufen';

  @override
  String get memo3 => 'Pull Requests prüfen';

  @override
  String get memo4 => '30 Minuten lesen';

  @override
  String get detailTitle => 'Details';

  @override
  String get detailHeadline => 'Bleibe Organisiert';

  @override
  String get detailBody =>
      'Erfasse Ideen, Erinnerungen und Aufgaben — alles an einem Ort.';

  @override
  String get cta => 'Notiz erstellen';

  @override
  String get statsTitle => 'Statistiken';

  @override
  String get statTotal => 'Notizen gesamt';

  @override
  String get statWeek => 'Diese Woche hinzugefügt';

  @override
  String get statTags => 'Tags verwendet';
}
