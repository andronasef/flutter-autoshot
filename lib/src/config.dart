import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

/// Callback used to navigate to a target screen inside the real app shell.
///
/// This is executed by [AutoshotRunner] before each capture when using
/// [ScreenEntry.route].
typedef ScreenNavigationCallback = Future<void> Function(BuildContext context);

/// Optional hook that runs after screen selection/navigation and before capture.
///
/// Use this to wait for async initialization specific to a screen.
typedef ScreenPrepareCallback = Future<void> Function(BuildContext context);

/// Callback invoked when the autoshot runner switches to a new locale.
///
/// Use this to synchronise external localisation systems (e.g.
/// easy_localization) that are not driven by DevicePreview's locale.
typedef AutoshotLocaleChangedCallback = Future<void> Function(
    BuildContext context, Locale locale);

/// A single screen entry to be captured during the automation loop.
///
/// Each [ScreenEntry] represents one "page" of the app that will be
/// screenshot for every combination of device and locale.
class ScreenEntry {
  /// A human-readable name used in the output file name.
  ///
  /// Example: `'home'`, `'profile'`, `'settings'`.
  /// Will be sanitised to a file-system-safe string automatically.
  final String name;

  /// A builder that returns the widget tree for this screen.
  ///
  /// The widget is rendered inside a [MaterialApp] shell configured
  /// with the current device preview locale and theme, so it should
  /// typically return a [Scaffold] or equivalent page-level widget.
  ///
  /// Used by [ScreenEntry.widget].
  final WidgetBuilder? builder;

  /// A callback that navigates to this screen inside the real app shell.
  ///
  /// Used by [ScreenEntry.route].
  final ScreenNavigationCallback? navigate;

  /// Optional hook invoked before capture for this screen.
  final ScreenPrepareCallback? prepare;

  /// Creates a widget-based screen entry.
  ///
  /// Deprecated in favor of [ScreenEntry.widget].
  const ScreenEntry({
    required this.name,
    required WidgetBuilder this.builder,
    this.prepare,
  }) : navigate = null;

  /// Creates a widget-based screen entry.
  ///
  /// This mode renders the screen in an isolated shell.
  const ScreenEntry.widget({
    required this.name,
    required this.builder,
    this.prepare,
  }) : navigate = null;

  /// Creates a route-based screen entry.
  ///
  /// This mode captures through your app's own navigation tree,
  /// preserving providers and initialized dependencies from your
  /// real app shell.
  const ScreenEntry.route({
    required this.name,
    required this.navigate,
    this.prepare,
  }) : builder = null;

  /// Whether this entry uses route-based navigation.
  bool get isRouteBased => navigate != null;
}

/// Configuration for the automated screenshot generation.
///
/// Defines which [screens], [locales], and [devices] to iterate through.
/// The total number of screenshots produced is
/// `screens.length × locales.length × effectiveDevices.length`.
class AutoshotConfig {
  /// The list of screens / pages to capture.
  final List<ScreenEntry> screens;

  /// The locales to iterate through for each screen.
  final List<Locale> locales;

  /// The target devices (sourced from [Devices]).
  ///
  /// When `null`, defaults to a phone and a tablet:
  /// ```
  /// [
  ///   Devices.android.bigPhone.copyWith(name: 'phone'),
  ///   Devices.android.smallTablet.copyWith(name: 'tablet'),
  /// ]
  /// ```
  final List<DeviceInfo>? devices;

  /// The application name used when naming the exported ZIP archive.
  ///
  /// The archive will be named `{appName}_autoshot_{timestamp}.zip`.
  /// Defaults to `'app'` when omitted.
  final String? appName;

  /// Light theme applied to the [MaterialApp] wrapper when capturing.
  ///
  /// Falls back to [ThemeData.light()] if omitted.
  final ThemeData? theme;

  /// Dark theme applied to the [MaterialApp] wrapper when capturing.
  ///
  /// Falls back to [ThemeData.dark()] if omitted.
  final ThemeData? darkTheme;

  /// Optional localizations delegates forwarded to the [MaterialApp] wrapper.
  final List<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  /// Optional supported locales forwarded to the [MaterialApp] wrapper.
  ///
  /// Defaults to [locales] when omitted.
  final List<Locale>? supportedLocales;

  /// Optional callback invoked when the runner switches locale.
  ///
  /// Use this to update external localisation systems (e.g.
  /// `context.setLocale(locale)` for easy_localization) that are not
  /// driven by DevicePreview's internal locale state.
  final AutoshotLocaleChangedCallback? onLocaleChanged;

  /// Whether the device frame chrome should be included in the captured
  /// image. When `false` (default), captures only the app viewport.
  final bool includeDeviceFrame;

  /// Delay after each state change (device / locale / screen) to let
  /// the framework settle before capturing. Increase this if you see
  /// partially rendered frames.
  final Duration settleDelay;

  /// Creates an autoshot configuration.
  const AutoshotConfig({
    required this.screens,
    required this.locales,
    this.devices,
    this.appName,
    this.theme,
    this.darkTheme,
    this.localizationsDelegates,
    this.supportedLocales,
    this.onLocaleChanged,
    this.includeDeviceFrame = false,
    this.settleDelay = const Duration(milliseconds: 500),
  });

  /// The resolved list of devices to capture.
  ///
  /// Returns [devices] if provided, otherwise returns the two built-in
  /// defaults: a phone and a small tablet.
  List<DeviceInfo> get effectiveDevices =>
      devices ??
      [
        Devices.android.bigPhone.copyWith(name: 'phone'),
        Devices.android.smallTablet.copyWith(name: 'tablet'),
      ];

  /// The resolved application name used for ZIP archive naming.
  String get effectiveAppName => appName ?? 'app';

  /// Total number of screenshots that will be produced.
  int get totalScreenshots =>
      screens.length * locales.length * effectiveDevices.length;
}
