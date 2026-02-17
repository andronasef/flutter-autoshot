import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

import 'config.dart';
import 'controller.dart';
import 'runner.dart';
import 'web_utils/downloader.dart' as downloader;

/// The delivery mode for captured screenshots.
enum AutoshotDelivery {
  /// Bundle all screenshots into a single `.zip` and trigger a download.
  zip,

  /// Trigger a separate browser download for each screenshot individually.
  individual,
}

/// A [DevicePreview] toolbar plugin that automates generating
/// App Store / Play Store screenshots across a matrix of
/// **screens × locales × devices**.
///
/// Add this widget to the [DevicePreview.tools] list alongside the
/// default tools:
///
/// ```dart
/// DevicePreview(
///   builder: (context) => AutoshotApp(
///     controller: controller,
///     child: MyApp(),
///   ),
///   tools: [
///     ...DevicePreview.defaultTools,
///     AutoshotToolbar(
///       controller: controller,
///       config: AutoshotConfig(
///         screens: [
///           ScreenEntry.widget(name: 'home', builder: (_) => HomeScreen()),
///         ],
///         locales: [Locale('en'), Locale('fr')],
///         devices: [Devices.ios.iPhone14Pro, Devices.android.samsungGalaxyS20],
///       ),
///     ),
///   ],
/// )
/// ```
class AutoshotToolbar extends StatefulWidget {
  /// Creates the toolbar plugin widget.
  const AutoshotToolbar({
    super.key,
    required this.controller,
    required this.config,
    this.delivery = AutoshotDelivery.zip,
  });

  /// The controller shared with [AutoshotApp].
  final AutoshotController controller;

  /// The screenshot generation configuration.
  final AutoshotConfig config;

  /// How captured screenshots are delivered to the user.
  final AutoshotDelivery delivery;

  @override
  State<AutoshotToolbar> createState() => _AutoshotToolbarState();
}

class _AutoshotToolbarState extends State<AutoshotToolbar> {
  bool _isRunning = false;
  int _current = 0;
  int _total = 0;
  String _statusText = '';

  @override
  Widget build(BuildContext context) {
    return ToolPanelSection(
      title: 'Autoshot',
      children: [
        // ── Summary ───────────────────────────────────────────────
        ListTile(
          leading: const Icon(Icons.info_outline, size: 20),
          title: Text(
            '${widget.config.screens.length} screens · '
            '${widget.config.locales.length} locales · '
            '${widget.config.devices.length} devices',
          ),
          subtitle: Text('${widget.config.totalScreenshots} screenshots total'),
          dense: true,
        ),

        // ── Generate button / progress ────────────────────────────
        if (_isRunning)
          _ProgressTile(
            current: _current,
            total: _total,
            description: _statusText,
          )
        else
          ListTile(
            leading: const Icon(Icons.play_arrow_rounded),
            title: const Text('Generate Screenshots'),
            subtitle: Text(
              widget.delivery == AutoshotDelivery.zip
                  ? 'Download as ZIP archive'
                  : 'Download individually',
            ),
            onTap: _startCapture,
          ),
      ],
    );
  }

  // ─── Capture loop ───────────────────────────────────────────────

  Future<void> _startCapture() async {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _current = 0;
      _total = widget.config.totalScreenshots;
      _statusText = 'Preparing…';
    });

    final runner = AutoshotRunner(
      config: widget.config,
      controller: widget.controller,
    );

    try {
      final results = await runner.run(
        context,
        onProgress: (current, total, description) {
          if (mounted) {
            setState(() {
              _current = current;
              _total = total;
              _statusText = description;
            });
          }
        },
      );

      if (!mounted) return;

      setState(() => _statusText = 'Packaging downloads…');

      // ── Deliver results ─────────────────────────────────────
      switch (widget.delivery) {
        case AutoshotDelivery.zip:
          await downloader.downloadScreenshotsAsZip(results);
          break;
        case AutoshotDelivery.individual:
          for (final shot in results) {
            await downloader.downloadFile(shot.fileName, shot.bytes);
            // Small delay to avoid browser download throttling.
            await Future.delayed(const Duration(milliseconds: 200));
          }
          break;
      }

      if (mounted) {
        _showSnackBar('✓ ${results.length} screenshots generated!');
      }
    } catch (e, stack) {
      debugPrint('Store screenshot error: $e\n$stack');
      if (mounted) {
        _showSnackBar('Screenshot generation failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRunning = false;
          _current = 0;
          _total = 0;
          _statusText = '';
        });
      }
    }
  }

  void _showSnackBar(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

// ─── Progress indicator tile ──────────────────────────────────────

class _ProgressTile extends StatelessWidget {
  const _ProgressTile({
    required this.current,
    required this.total,
    required this.description,
  });

  final int current;
  final int total;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = total > 0 ? current / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(
                'Capturing $current of $total…',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: progress, minHeight: 6),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
