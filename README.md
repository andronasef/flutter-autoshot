# Autoshot

A **[device_preview](https://pub.dev/packages/device_preview)** wrapper plugin that automates generating App Store / Play Store screenshots across multiple devices, locales, and screens — entirely from the Flutter Web runner.

`autoshot` wraps `device_preview` as a dependency, so you only need to add `autoshot` to your project — no need to depend on `device_preview` separately.

## Problem

Developers currently have to manually switch devices and locales in `device_preview` and take screenshots one-by-one. For an app targeting 3 devices × 5 locales × 4 screens, that's **60 manual screenshots**.

This plugin turns that into a single button click.

## Features

- **Single dependency**: wraps `device_preview` — just add `autoshot` and you're set
- **Matrix automation**: iterates through every combination of `screens × locales × devices`
- **Programmatic control**: updates the `DevicePreview` state (device, locale) without user interaction
- **Render-safe**: waits for frames to settle after each state change before capturing
- **Web-optimised**: captures via `RepaintBoundary` → `toImage()` → PNG bytes
- **ZIP download**: bundles all screenshots into a single `.zip` and triggers a browser download
- **Progress UI**: shows a live progress bar in the device_preview toolbar
- **Naming convention**: `device_name_locale_screen_name.png`

## Installation

```yaml
dependencies:
  autoshot: ^1.0.0
```

> **Note:** You do **not** need to add `device_preview` separately. It is re-exported by `autoshot`.

## Quick Start

```dart
import 'package:autoshot/autoshot.dart';
```

Just wrap your app in `Autoshot` — that's it:

```dart
Autoshot(
  config: AutoshotConfig(
    screens: [
      ScreenEntry(name: 'home', builder: (_) => HomeScreen()),
      ScreenEntry(name: 'profile', builder: (_) => ProfileScreen()),
    ],
    locales: [Locale('en', 'US'), Locale('fr', 'FR'), Locale('ar')],
    devices: [
      Devices.ios.iPhone13ProMax,
      Devices.ios.iPadPro11Inches,
      Devices.android.samsungGalaxyS20,
    ],
    // Optional:
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    localizationsDelegates: [...],
    settleDelay: Duration(milliseconds: 500),
  ),
  builder: (context) => MyApp(),
)
```

`Autoshot` internally creates a `DevicePreview` with the automation controller
and toolbar already wired up. No manual setup needed.

<details>
<summary><strong>Advanced: manual wiring</strong></summary>

If you need full control (custom tool ordering, access to the controller, etc.),
use the lower-level widgets directly:

```dart
final controller = AutoshotController();

DevicePreview(
  builder: (context) => AutoshotApp(
    controller: controller,
    child: MyApp(),
  ),
  tools: [
    ...DevicePreview.defaultTools,
    AutoshotToolbar(
      controller: controller,
      config: AutoshotConfig(
        screens: [
          ScreenEntry(name: 'home', builder: (_) => HomeScreen()),
          ScreenEntry(name: 'profile', builder: (_) => ProfileScreen()),
        ],
        locales: [Locale('en', 'US'), Locale('fr', 'FR'), Locale('ar')],
        devices: [
          Devices.ios.iPhone13ProMax,
          Devices.ios.iPadPro11Inches,
          Devices.android.samsungGalaxyS20,
        ],
      ),
    ),
  ],
)
```

</details>

### Click "Generate Screenshots" in the toolbar

The plugin will:

1. Loop through every `device × locale × screen` combination
2. Programmatically switch the device and locale via `DevicePreviewStore`
3. Swap the displayed screen via the `AutoshotController`
4. Wait for the frame to settle
5. Capture the pixels as PNG
6. Package everything into a `.zip` and trigger a browser download

## Configuration

| Parameter                | Type                           | Default             | Description                      |
| ------------------------ | ------------------------------ | ------------------- | -------------------------------- |
| `screens`                | `List<ScreenEntry>`            | required            | Pages to screenshot              |
| `locales`                | `List<Locale>`                 | required            | Languages to iterate             |
| `devices`                | `List<DeviceInfo>`             | required            | Target devices                   |
| `theme`                  | `ThemeData?`                   | `ThemeData.light()` | Light theme for captures         |
| `darkTheme`              | `ThemeData?`                   | `ThemeData.dark()`  | Dark theme for captures          |
| `localizationsDelegates` | `List<LocalizationsDelegate>?` | `null`              | Your app's l10n delegates        |
| `supportedLocales`       | `List<Locale>?`                | `locales`           | Supported locales list           |
| `includeDeviceFrame`     | `bool`                         | `false`             | Include device chrome in capture |
| `settleDelay`            | `Duration`                     | `500ms`             | Wait time after state changes    |

## Delivery Modes

```dart
AutoshotToolbar(
  delivery: AutoshotDelivery.zip,         // default — single .zip download
  // delivery: AutoshotDelivery.individual, // one download per image
)
```

## Architecture

```
AutoshotController        ← shared state (current screen override)
        │
        ├── AutoshotApp          ← widget wrapper inside DevicePreview.builder
        │       shows controller.currentScreen ?? normalApp
        │
        └── AutoshotToolbar      ← toolbar section widget
                │
                └── AutoshotRunner       ← automation engine
                        │
                        ├── changes device via store.selectDevice()
                        ├── changes locale via store.data.copyWith(locale:)
                        ├── swaps screen via controller.showScreen()
                        ├── waits for frame settle
                        ├── captures via DevicePreview.screenshot()
                        └── packages results → ZIP → browser download
```

## Output

The ZIP contains PNGs with the naming convention:

```
autoshot/
  iphone_13_pro_max_en_us_home.png
  iphone_13_pro_max_en_us_profile.png
  iphone_13_pro_max_fr_fr_home.png
  ...
  samsung_galaxy_s20_ar_home.png
  ...
```

## Platform Support

| Platform       | Status                                                         |
| -------------- | -------------------------------------------------------------- |
| Web            | ✅ Full support (ZIP download)                                 |
| Mobile/Desktop | ⚠️ Capture works, but download requires a file-based processor |

## License

MIT
