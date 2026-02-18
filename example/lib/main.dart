import 'package:autoshot/autoshot.dart';
import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';

void main() {
  runApp(const AutoshotExample());
}

// ─── Autoshot entry point ─────────────────────────────────────────────────────

class AutoshotExample extends StatelessWidget {
  const AutoshotExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Autoshot(
      config: AutoshotConfig(
        screens: [
          ScreenEntry.widget(name: 'home', builder: (_) => const HomeScreen()),
          ScreenEntry.widget(
            name: 'detail',
            builder: (_) => const DetailScreen(),
          ),
          ScreenEntry.widget(
            name: 'stats',
            builder: (_) => const StatsScreen(),
          ),
        ],
        locales: AppLocalizations.supportedLocales,
        devices: [
          Devices.ios.iPhone16ProMax,
          Devices.ios.iPad,
          Devices.android.samsungGalaxyS20,
        ],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF6750A4),
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: const Color(0xFF6750A4),
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
      ),
      builder: (context) => const MemosApp(),
    );
  }
}

// ─── Root app ─────────────────────────────────────────────────────────────────

class MemosApp extends StatelessWidget {
  const MemosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx)?.appName ?? 'Memos',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6750A4),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF6750A4),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}

// ─── Home screen ──────────────────────────────────────────────────────────────

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final memos = [l10n.memo1, l10n.memo2, l10n.memo3, l10n.memo4];

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(l10n.appName),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 18)),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Greeting card ────────────────────────────────────────
          Card(
            color: cs.primaryContainer,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homeGreeting,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.homeSummary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Today',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          // ── Memo list ────────────────────────────────────────────
          ...memos.asMap().entries.map((e) {
            return _MemoTile(text: e.value, done: e.key == 0);
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: Text(l10n.cta),
      ),
    );
  }
}

class _MemoTile extends StatelessWidget {
  const _MemoTile({required this.text, this.done = false});

  final String text;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 14,
          backgroundColor: done ? cs.primary : cs.surfaceContainerHighest,
          child: Icon(
            done ? Icons.check : Icons.circle_outlined,
            size: 16,
            color: done ? cs.onPrimary : cs.onSurfaceVariant,
          ),
        ),
        title: Text(
          text,
          style: TextStyle(
            decoration: done ? TextDecoration.lineThrough : null,
            color: done ? theme.hintColor : cs.onSurface,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
        dense: true,
      ),
    );
  }
}

// ─── Detail screen ────────────────────────────────────────────────────────────

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.detailTitle)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Illustration placeholder ──────────────────────────
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.sticky_note_2_rounded,
                size: 96,
                color: cs.primary,
              ),
            ),

            const SizedBox(height: 32),

            Text(
              l10n.detailHeadline,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.detailBody,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.6,
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: Text(l10n.cta),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stats screen ─────────────────────────────────────────────────────────────

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statsTitle)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Stats grid ────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: l10n.statTotal,
                    value: '24',
                    icon: Icons.notes_rounded,
                    color: cs.primaryContainer,
                    onColor: cs.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: l10n.statWeek,
                    value: '7',
                    icon: Icons.calendar_today_rounded,
                    color: cs.secondaryContainer,
                    onColor: cs.onSecondaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _StatCard(
              label: l10n.statTags,
              value: '12',
              icon: Icons.label_rounded,
              color: cs.tertiaryContainer,
              onColor: cs.onTertiaryContainer,
            ),

            const SizedBox(height: 28),

            // ── Activity bar chart ────────────────────────────────
            Text(
              'Weekly activity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            _ActivityChart(cs: cs),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: onColor, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: onColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: onColor.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityChart extends StatelessWidget {
  const _ActivityChart({required this.cs});

  final ColorScheme cs;

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _values = [0.4, 0.7, 0.5, 1.0, 0.6, 0.3, 0.8];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_days.length, (i) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                width: 32,
                height: 90 * _values[i],
                decoration: BoxDecoration(
                  color: i == 3 ? cs.primary : cs.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _days[i],
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
