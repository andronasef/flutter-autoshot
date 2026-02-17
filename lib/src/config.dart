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
/// `screens.length × locales.length × devices.length`.
class AutoshotConfig {
  /// The list of screens / pages to capture.
  final List<ScreenEntry> screens;

  /// The locales to iterate through for each screen.
  final List<Locale> locales;

  /// The target devices (sourced from [Devices]).
  final List<DeviceInfo> devices;

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
    required this.devices,
    this.theme,
    this.darkTheme,
    this.localizationsDelegates,
    this.supportedLocales,
    this.includeDeviceFrame = false,
    this.settleDelay = const Duration(milliseconds: 500),
  });

  /// Total number of screenshots that will be produced.
  int get totalScreenshots => screens.length * locales.length * devices.length;
}
