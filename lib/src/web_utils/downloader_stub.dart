import 'dart:typed_data';

import '../runner.dart';

/// Downloads a list of [AutoshotCapture]s as a ZIP archive.
///
/// This is the **stub** implementation used on non-web platforms.
/// On the web, the `downloader_web.dart` implementation is loaded
/// via conditional imports.
Future<void> downloadScreenshotsAsZip(List<AutoshotCapture> screenshots) {
  throw UnsupportedError(
    'ZIP download is only supported on Flutter Web. '
    'Use a file-based export instead.',
  );
}

/// Triggers a browser download for a single file.
///
/// Stub – throws on non-web platforms.
Future<void> downloadFile(String fileName, Uint8List bytes) {
  throw UnsupportedError(
    'Browser downloads are only supported on Flutter Web.',
  );
}
