// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Mémos';

  @override
  String get homeGreeting => 'Bonjour !';

  @override
  String get homeSummary => 'Vous avez 4 mémos aujourd\'hui.';

  @override
  String get memo1 => 'Faire les courses';

  @override
  String get memo2 => 'Appeler le médecin';

  @override
  String get memo3 => 'Revoir les pull requests';

  @override
  String get memo4 => 'Lire 30 minutes';

  @override
  String get detailTitle => 'Détails';

  @override
  String get detailHeadline => 'Restez Organisé';

  @override
  String get detailBody =>
      'Capturez idées, rappels et tâches — le tout en un seul endroit.';

  @override
  String get cta => 'Créer un mémo';

  @override
  String get statsTitle => 'Statistiques';

  @override
  String get statTotal => 'Mémos au total';

  @override
  String get statWeek => 'Ajoutés cette semaine';

  @override
  String get statTags => 'Tags utilisés';
}
