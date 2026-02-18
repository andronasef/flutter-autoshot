import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

import '../runner.dart';

/// Downloads a list of [AutoshotCapture]s as a ZIP archive.
///
/// This is the **stub** implementation used on non-web platforms.
/// On the web, the `downloader_web.dart` implementation is loaded
/// via conditional imports.
Future<String> downloadScreenshotsAsZip(
  List<AutoshotCapture> screenshots, {
  String appName = 'app',
}) async {
  final targetDirectory = await _resolveTargetDirectory();
  final outputDirectory =
      Directory('${targetDirectory.path}${Platform.pathSeparator}autoshot');
  if (!outputDirectory.existsSync()) {
    outputDirectory.createSync(recursive: true);
  }

  final archive = Archive();
  for (final shot in screenshots) {
    archive.addFile(
      ArchiveFile(shot.fileName, shot.bytes.length, shot.bytes),
    );
  }

  final zipBytes = ZipEncoder().encode(archive);
  final zipName = _buildZipName(appName);
  final zipPath =
      '${outputDirectory.path}${Platform.pathSeparator}$zipName';
  final zipFile = File(zipPath);
  await zipFile.writeAsBytes(zipBytes, flush: true);

  return zipPath;
}

/// Triggers a browser download for a single file.
///
/// Stub – throws on non-web platforms.
Future<String> downloadFile(String fileName, Uint8List bytes) async {
  final targetDirectory = await _resolveTargetDirectory();
  final outputDirectory =
      Directory('${targetDirectory.path}${Platform.pathSeparator}autoshot');
  if (!outputDirectory.existsSync()) {
    outputDirectory.createSync(recursive: true);
  }

  final filePath = '${outputDirectory.path}${Platform.pathSeparator}$fileName';
  final outputFile = File(filePath);
  await outputFile.writeAsBytes(bytes, flush: true);

  return filePath;
}

String _buildZipName(String appName) {
  final sanitised = appName
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  final now = DateTime.now();
  final timestamp =
      '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}_'
      '${now.hour.toString().padLeft(2, '0')}-'
      '${now.minute.toString().padLeft(2, '0')}-'
      '${now.second.toString().padLeft(2, '0')}';
  return '${sanitised}_autoshot_$timestamp.zip';
}

Future<Directory> _resolveTargetDirectory() async {
  if (Platform.isAndroid) {
    const candidates = <String>[
      '/storage/emulated/0/Download',
      '/sdcard/Download'
    ];
    for (final path in candidates) {
      final dir = Directory(path);
      if (await dir.exists()) {
        return dir;
      }
    }

    final external = await getExternalStorageDirectory();
    if (external != null) {
      return external;
    }
  }

  if (Platform.isIOS) {
    return getApplicationDocumentsDirectory();
  }

  final downloads = await getDownloadsDirectory();
  if (downloads != null) {
    return downloads;
  }

  return getApplicationDocumentsDirectory();
}
