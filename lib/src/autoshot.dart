import 'package:device_preview/device_preview.dart';
import 'package:flutter/widgets.dart';

import 'config.dart';
import 'controller.dart';
import 'screenshot_app.dart';
import 'section.dart';

/// A convenience widget that sets up [DevicePreview] with the autoshot
/// screenshot automation already wired in.
///
/// This is the easiest way to use autoshot — just wrap your app and
/// provide a config:
///
/// ```dart
/// Autoshot(
///   config: AutoshotConfig(
///     screens: [
///       ScreenEntry(name: 'home', builder: (_) => HomeScreen()),
///       ScreenEntry(name: 'profile', builder: (_) => ProfileScreen()),
///     ],
///     locales: [Locale('en', 'US'), Locale('fr', 'FR')],
///     devices: [Devices.ios.iPhone13ProMax],
///   ),
///   builder: (context) => MyApp(),
/// )
/// ```
///
/// Under the hood this creates an [AutoshotController], wraps your app
/// in [AutoshotApp], and adds [AutoshotToolbar] to the device_preview
/// toolbar — all automatically.
///
/// For advanced usage (e.g. accessing the controller directly or
/// customising tool ordering), use the lower-level widgets
/// [AutoshotApp], [AutoshotToolbar], and [AutoshotController] instead.
class Autoshot extends StatefulWidget {
  /// Creates an [Autoshot] wrapper.
  const Autoshot({
    super.key,
    required this.config,
    required this.builder,
    this.delivery = AutoshotDelivery.zip,
    this.enabled = true,
    this.isToolbarVisible = true,
    this.availableLocales,
    this.defaultDevice,
    this.tools,
    this.storage,
    this.backgroundColor,
    this.data,
    this.padding,
  });

  /// The autoshot configuration defining screens, locales, and devices.
  final AutoshotConfig config;

  /// The previewed widget builder — typically your root app widget.
  final WidgetBuilder builder;

  /// How captured screenshots are delivered to the user.
  final AutoshotDelivery delivery;

  /// If `false`, device preview is disabled and [builder] is rendered
  /// directly without any wrapping.
  final bool enabled;

  /// Whether the device_preview toolbar is visible.
  final bool isToolbarVisible;

  /// The available locales for the device preview locale picker.
  final List<Locale>? availableLocales;

  /// The default selected device when opening device preview.
  final DeviceInfo? defaultDevice;

  /// Additional toolbar tools to include **before** the autoshot section.
  ///
  /// When `null`, [DevicePreview.defaultTools] are used.
  /// The autoshot toolbar is always appended automatically.
  final List<Widget>? tools;

  /// The storage used to persist device preview preferences.
  final DevicePreviewStorage? storage;

  /// The background color of the device preview canvas.
  final Color? backgroundColor;

  /// Initial device preview data / configuration.
  final DevicePreviewData? data;

  /// Padding around the the device frame.
  final EdgeInsets? padding;

  @override
  State<Autoshot> createState() => _AutoshotState();
}

class _AutoshotState extends State<Autoshot> {
  late final AutoshotController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AutoshotController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseTools = widget.tools ?? DevicePreview.defaultTools;

    return DevicePreview(
      enabled: widget.enabled,
      isToolbarVisible: widget.isToolbarVisible,
      availableLocales: widget.availableLocales,
      defaultDevice: widget.defaultDevice,
      storage: widget.storage,
      backgroundColor: widget.backgroundColor,
      data: widget.data,
      devices: widget.config.devices,
      padding: widget.padding,
      builder: (context) =>
          AutoshotApp(controller: _controller, child: widget.builder(context)),
      tools: [
        ...baseTools,
        AutoshotToolbar(
          controller: _controller,
          config: widget.config,
          delivery: widget.delivery,
        ),
      ],
    );
  }
}
