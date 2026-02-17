import 'package:flutter/widgets.dart';

import 'controller.dart';

/// A wrapper widget placed inside the [DevicePreview.builder] that
/// allows the automation runner to swap the displayed content during
/// the screenshot capture loop.
///
/// When the [controller] has no active screen (i.e. automation is idle),
/// the normal [child] is rendered. During capture the controller
/// pushes each target screen widget and this wrapper reflects it
/// immediately.
///
/// ## Usage
///
/// ```dart
/// final controller = AutoshotController();
///
/// DevicePreview(
///   builder: (context) => AutoshotApp(
///     controller: controller,
///     child: MyApp(),
///   ),
///   tools: [
///     ...DevicePreview.defaultTools,
///     AutoshotToolbar(
///       controller: controller,
///       config: AutoshotConfig(/* ... */),
///     ),
///   ],
/// )
/// ```
class AutoshotApp extends StatelessWidget {
  /// Creates an [AutoshotApp].
  const AutoshotApp({super.key, required this.controller, required this.child});

  /// The controller shared with the toolbar plugin widget.
  final AutoshotController controller;

  /// The normal app widget displayed when the automation is idle.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return controller.currentScreen ?? child;
      },
    );
  }
}
