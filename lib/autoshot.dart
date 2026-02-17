/// Automated App Store / Play Store screenshot generation for
/// [device_preview](https://pub.dev/packages/device_preview).
///
/// This plugin iterates through a configurable matrix of
/// **screens × locales × devices**, programmatically controlling
/// DevicePreview to render each combination and capturing the output
/// as PNG images. On Flutter Web the results are bundled into a ZIP
/// archive and triggered as a browser download.
///
/// ## Quick start
///
/// ```dart
/// import 'package:autoshot/autoshot.dart';
///
/// Autoshot(
///   config: AutoshotConfig(
///     screens: [
///       ScreenEntry.widget(name: 'home', builder: (_) => HomeScreen()),
///       ScreenEntry.widget(name: 'profile', builder: (_) => ProfileScreen()),
///     ],
///     locales: [Locale('en', 'US'), Locale('fr', 'FR')],
///     devices: [Devices.ios.iPhone14Pro, Devices.android.samsungGalaxyS20],
///   ),
///   builder: (context) => MyApp(),
/// )
/// ```
library autoshot;

// Re-export device_preview so consumers only need a single import.
export 'package:device_preview/device_preview.dart';

export 'src/autoshot.dart';
export 'src/config.dart';
export 'src/controller.dart';
export 'src/runner.dart' show AutoshotCapture, AutoshotRunner;
export 'src/screenshot_app.dart';
export 'src/section.dart';
