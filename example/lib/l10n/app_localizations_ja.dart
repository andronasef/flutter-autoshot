// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'メモ';

  @override
  String get homeGreeting => 'おはようございます！';

  @override
  String get homeSummary => '今日は4件のメモがあります。';

  @override
  String get memo1 => '食料品を買う';

  @override
  String get memo2 => '医者に電話する';

  @override
  String get memo3 => 'プルリクエストをレビューする';

  @override
  String get memo4 => '30分読書する';

  @override
  String get detailTitle => '詳細';

  @override
  String get detailHeadline => '整理整頓を保とう';

  @override
  String get detailBody => 'アイデア、リマインダー、やることリスト — すべてひとつの場所に。';

  @override
  String get cta => 'メモを作成';

  @override
  String get statsTitle => '統計';

  @override
  String get statTotal => 'メモ合計';

  @override
  String get statWeek => '今週追加';

  @override
  String get statTags => '使用タグ';
}
