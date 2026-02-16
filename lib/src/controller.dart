import 'package:flutter/widgets.dart';

/// Controls which widget is displayed inside [AutoshotApp] during
/// the automated capture loop.
///
/// When [currentScreen] is `null` the normal child is shown.
/// During automation the [AutoshotRunner] pushes each screen widget
/// into the controller so the preview renders the correct content.
class AutoshotController extends ChangeNotifier {
  Widget? _currentScreen;

  /// The widget currently being captured, or `null` when idle.
  Widget? get currentScreen => _currentScreen;

  /// Whether the automation loop is currently running.
  bool get isCapturing => _currentScreen != null;

  /// Replace the preview content with [screen].
  ///
  /// Called by [AutoshotRunner] for each iteration.
  void showScreen(Widget screen) {
    _currentScreen = screen;
    notifyListeners();
  }

  /// Restore the normal app content.
  void reset() {
    _currentScreen = null;
    notifyListeners();
  }
}
