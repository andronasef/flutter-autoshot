import 'dart:typed_data';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config.dart';
import 'controller.dart';

/// Progress callback signature for the automation loop.
///
/// [current] is 1-based, [total] is the overall count.
/// [description] provides a human-readable label like
/// `"iPhone 14 Pro / en / home"`.
typedef AutoshotProgressCallback = void Function(
    int current, int total, String description);

/// A single captured screenshot with its metadata and pixel data.
class AutoshotCapture {
  /// The suggested file name (e.g. `iphone_14_pro_en_home.png`).
  final String fileName;

  /// Raw PNG bytes.
  final Uint8List bytes;

  /// The device this was captured on.
  final DeviceInfo device;

  /// The locale active during capture.
  final Locale locale;

  /// The screen name from [ScreenEntry.name].
  final String screenName;

  const AutoshotCapture({
    required this.fileName,
    required this.bytes,
    required this.device,
    required this.locale,
    required this.screenName,
  });
}

/// The automation engine that iterates through the
/// **screens × locales × devices** matrix, programmatically
/// updating the [DevicePreview] state for each combination, waiting
/// for the frame to settle, and capturing the rendered pixels.
class AutoshotRunner {
  /// Creates a runner with the given [config] and [controller].
  AutoshotRunner({required this.config, required this.controller});

  /// The screenshot configuration.
  final AutoshotConfig config;

  /// The controller used to swap the preview content.
  final AutoshotController controller;

  /// A [GlobalKey] attached to a [RepaintBoundary] that wraps
  /// only the app viewport (excluding the device frame and toolbar).
  /// This is installed by the [section] widget when
  /// [AutoshotConfig.includeDeviceFrame] is `false`.
  GlobalKey? appRepaintBoundaryKey;

  /// Runs the full capture loop and returns all captured screenshots.
  ///
  /// [context] must be a descendant of both [DevicePreview] and
  /// [ChangeNotifierProvider<DevicePreviewStore>].
  ///
  /// Reports progress via [onProgress] if provided.
  Future<List<AutoshotCapture>> run(
    BuildContext context, {
    AutoshotProgressCallback? onProgress,
  }) async {
    final store = context.read<DevicePreviewStore>();
    final results = <AutoshotCapture>[];

    // ── Save initial state ──────────────────────────────────────────
    final initialDeviceId = store.deviceInfo.identifier;
    final initialLocale = store.data.locale;
    final initialFrameVisible = store.data.isFrameVisible;

    int current = 0;
    final total = config.totalScreenshots;

    try {
      for (final device in config.devices) {
        // ── Set device ────────────────────────────────────────────
        store.selectDevice(device.identifier);

        // Ensure frame visibility matches config
        if (store.data.isFrameVisible != config.includeDeviceFrame) {
          store.toggleFrame();
        }

        for (final locale in config.locales) {
          // ── Set locale ──────────────────────────────────────────
          // Use locale.toString() which produces underscore-separated format
          // (e.g. 'en_US') that DevicePreview expects. toLanguageTag() produces
          // hyphen-separated BCP 47 format ('en-US') which DevicePreview's
          // split('_') parser cannot handle, resulting in a malformed locale.
          store.data = store.data.copyWith(locale: locale.toString());
          // Notify external localisation systems (e.g. easy_localization).
          if (config.onLocaleChanged != null) {
            // ignore: use_build_context_synchronously
            await config.onLocaleChanged!(context, locale);
            await _settle();
          }
          for (final screen in config.screens) {
            current++;
            final description =
                '${device.name} / ${locale.toLanguageTag()} / ${screen.name}';
            onProgress?.call(current, total, description);

            // ── Set screen content ────────────────────────────────
            if (screen.isRouteBased) {
              controller.reset();
              // ignore: use_build_context_synchronously
              await screen.navigate!(context);
            } else {
              controller.showScreen(
                // ignore: use_build_context_synchronously
                _wrapScreen(context, screen, locale),
              );
            }

            // ── Optional screen preparation ───────────────────────
            if (screen.prepare != null) {
              // ignore: use_build_context_synchronously
              await screen.prepare!(context);
            }

            // ── Wait for frame to settle ──────────────────────────
            await _settle();

            // ── Capture ───────────────────────────────────────────
            // ignore: use_build_context_synchronously
            final bytes = await _capture(context, store);

            final fileName = _buildFileName(device, locale, screen);
            results.add(
              AutoshotCapture(
                fileName: fileName,
                bytes: bytes,
                device: device,
                locale: locale,
                screenName: screen.name,
              ),
            );
          }
        }
      }
    } finally {
      // ── Restore initial state ───────────────────────────────────
      store.selectDevice(initialDeviceId);
      store.data = store.data.copyWith(locale: initialLocale);
      if (store.data.isFrameVisible != initialFrameVisible) {
        store.toggleFrame();
      }
      controller.reset();
    }

    return results;
  }

  // ─── Private helpers ──────────────────────────────────────────────

  /// Wraps a [ScreenEntry] in a configured [MaterialApp] that respects
  /// the DevicePreview simulation (locale, theme, media query).
  Widget _wrapScreen(BuildContext context, ScreenEntry screen, Locale locale) {
    return MaterialApp(
      // ignore: deprecated_member_use
      useInheritedMediaQuery: true,
      locale: locale,
      builder: DevicePreview.appBuilder,
      theme: config.theme ?? ThemeData.light(),
      darkTheme: config.darkTheme ?? ThemeData.dark(),
      // ThemeMode.system lets MaterialApp read the platformBrightness that
      // DevicePreview.appBuilder injects, so dark-mode is respected correctly.
      themeMode: ThemeMode.system,
      localizationsDelegates: config.localizationsDelegates,
      supportedLocales: config.supportedLocales ?? config.locales,
      debugShowCheckedModeBanner: false,
      home: Builder(builder: screen.builder!),
    );
  }

  /// Waits for the rendering pipeline to flush and then an extra
  /// [AutoshotConfig.settleDelay] buffer.
  Future<void> _settle() async {
    // Let the framework process the pending state changes.
    await WidgetsBinding.instance.endOfFrame;
    await Future.delayed(config.settleDelay);
    // One more pump to be safe.
    await WidgetsBinding.instance.endOfFrame;
  }

  /// Captures the current preview content as PNG bytes.
  ///
  /// Uses [DevicePreview.screenshot] which captures the full device
  /// frame via its own [RepaintBoundary]. The result includes the
  /// device chrome when `includeDeviceFrame` is true.
  Future<Uint8List> _capture(
    BuildContext context,
    DevicePreviewStore store,
  ) async {
    // Use the built-in screenshot mechanism which captures
    // the RepaintBoundary around the DeviceFrame widget.
    final screenshot = await DevicePreview.screenshot(context);
    return screenshot.bytes;
  }

  /// Produces a filesystem-safe file name from the combination of
  /// device, locale, and screen.
  ///
  /// Example: `iphone_14_pro_en_us_home.png`
  static String _buildFileName(
    DeviceInfo device,
    Locale locale,
    ScreenEntry screen,
  ) {
    final deviceName = _sanitise(device.name);
    final localeName = locale.toString().toLowerCase();
    final screenName = _sanitise(screen.name);
    return '${deviceName}_${localeName}_$screenName.png';
  }

  static String _sanitise(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}
