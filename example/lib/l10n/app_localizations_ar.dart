// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'ملاحظات';

  @override
  String get homeGreeting => 'صباح الخير!';

  @override
  String get homeSummary => 'لديك 4 ملاحظات اليوم.';

  @override
  String get memo1 => 'شراء البقالة';

  @override
  String get memo2 => 'الاتصال بالطبيب';

  @override
  String get memo3 => 'مراجعة طلبات السحب';

  @override
  String get memo4 => 'قراءة لمدة 30 دقيقة';

  @override
  String get detailTitle => 'التفاصيل';

  @override
  String get detailHeadline => 'ابقَ منظمًا';

  @override
  String get detailBody =>
      'سجّل أفكارك وتذكيراتك ومهامك — كل ذلك في مكان واحد.';

  @override
  String get cta => 'إنشاء ملاحظة';

  @override
  String get statsTitle => 'الإحصائيات';

  @override
  String get statTotal => 'إجمالي الملاحظات';

  @override
  String get statWeek => 'مضاف هذا الأسبوع';

  @override
  String get statTags => 'الوسوم المستخدمة';
}
