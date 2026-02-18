// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../runner.dart';

/// Downloads all [screenshots] bundled into a single ZIP archive
/// via a browser-triggered download.
///
/// The archive is named `{appName}_autoshot_{timestamp}.zip`.
///
/// File structure inside the ZIP:
/// ```
/// autoshot/
///   iphone_14_pro_en_us_home.png
///   iphone_14_pro_fr_fr_home.png
///   ...
/// ```
Future<String> downloadScreenshotsAsZip(
  List<AutoshotCapture> screenshots, {
  String appName = 'app',
}) async {
  final archive = Archive();

  for (final shot in screenshots) {
    archive.addFile(
      ArchiveFile('autoshot/${shot.fileName}', shot.bytes.length, shot.bytes),
    );
  }

  final zipBytes = ZipEncoder().encode(archive);
  final zipName = _buildZipName(appName);

  final blob = html.Blob([Uint8List.fromList(zipBytes)], 'application/zip');
  final url = html.Url.createObjectUrlFromBlob(blob);

  html.AnchorElement(href: url)
    ..setAttribute('download', zipName)
    ..click();

  html.Url.revokeObjectUrl(url);

  return 'browser-download';
}

String _buildZipName(String appName) {
  final sanitised = appName
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  final now = DateTime.now();
  final timestamp = '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}_'
      '${now.hour.toString().padLeft(2, '0')}-'
      '${now.minute.toString().padLeft(2, '0')}-'
      '${now.second.toString().padLeft(2, '0')}';
  return '${sanitised}_autoshot_$timestamp.zip';
}

/// Triggers a browser download for a single file with the given
/// [fileName] and raw [bytes].
Future<String> downloadFile(String fileName, Uint8List bytes) async {
  final blob = html.Blob([bytes], 'image/png');
  final url = html.Url.createObjectUrlFromBlob(blob);

  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();

  html.Url.revokeObjectUrl(url);

  return 'browser-download';
}
