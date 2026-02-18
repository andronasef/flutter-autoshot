# Autoshot

A **[device_preview](https://pub.dev/packages/device_preview)** wrapper plugin that automates generating App Store / Play Store screenshots across multiple devices, locales, and screens.

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
- **Flexible export**: browser download on Web, file export on mobile/desktop
- **Progress UI**: shows a live progress bar in the device_preview toolbar
- **Naming convention**: `device_name_locale_screen_name.png`

## Installation

```yaml
dependencies:
  autoshot: ^1.3.2
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
      ScreenEntry.widget(name: 'home', builder: (_) => HomeScreenMockup()),
      ScreenEntry.widget(name: 'profile', builder: (_) => ProfileScreen()),
    ],
    locales: [Locale('en', 'US'), Locale('fr', 'FR'), Locale('ar')],
    devices: [
      Devices.ios.iPhone16ProMax,
      Devices.ios.iPad,
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
          ScreenEntry.widget(name: 'home', builder: (_) => HomeScreen()),
          ScreenEntry.widget(name: 'profile', builder: (_) => ProfileScreen()),
        ],
        locales: [Locale('en', 'US'), Locale('fr', 'FR'), Locale('ar')],
        devices: [
          Devices.ios.iPhone16ProMax,
          Devices.ios.iPad,
          Devices.android.samsungGalaxyS20,
        ],
      ),
    ),
  ],
)
```

</details>

## Preferred for real apps: Route-based capture

When screens depend on providers, DI containers, or initialization that lives in your app shell,
use `ScreenEntry.route(...)` so captures run through your real `MaterialApp` and navigator.

```dart
final appNavigatorKey = GlobalKey<NavigatorState>();

Autoshot(
  config: AutoshotConfig(
    screens: [
      ScreenEntry.route(
        name: 'home',
        navigate: (_) async {
          appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );
        },
      ),
      ScreenEntry.route(
        name: 'profile',
        navigate: (_) async {
          appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/profile',
            (route) => false,
          );
        },
      ),
    ],
    locales: [Locale('en', 'US')],
    devices: [Devices.ios.iPhone14Pro],
  ),
  builder: (_) => MyApp(navigatorKey: appNavigatorKey),
)
```

Optional per-screen async preparation is available via `prepare:`.

### Complete route example

```dart
import 'package:autoshot/autoshot.dart';
import 'package:flutter/material.dart';

final appNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    Autoshot(
      config: AutoshotConfig(
        screens: [
          ScreenEntry.route(
            name: 'home',
            navigate: (_) async {
              appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
                '/home',
                (route) => false,
              );
            },
          ),
          ScreenEntry.route(
            name: 'profile',
            navigate: (_) async {
              appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
                '/profile',
                (route) => false,
              );
            },
            prepare: (_) async {
              await Future.delayed(const Duration(milliseconds: 250));
            },
          ),
        ],
        locales: const [Locale('en', 'US')],
        devices: [Devices.ios.iPhone14Pro],
      ),
      builder: (_) => MyApp(navigatorKey: appNavigatorKey),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      useInheritedMediaQuery: true, // required for DevicePreview media query injection
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      routes: {
        '/home': (_) => const HomeScreen(),
        '/profile': (_) => const ProfileScreen(),
      },
      initialRoute: '/home',
    );
  }
}
```

### Click "Generate Screenshots" in the toolbar

The plugin will:

1. Loop through every `device × locale × screen` combination
2. Programmatically switch the device and locale via `DevicePreviewStore`
3. Select the target screen (route navigation or widget mode)
4. Wait for the frame to settle
5. Capture the pixels as PNG
6. Deliver screenshots as browser downloads (Web) or exported files (non-Web)

## Configuration

| Parameter                | Type                             | Default             | Description                                             |
| ------------------------ | -------------------------------- | ------------------- | ------------------------------------------------------- |
| `screens`                | `List<ScreenEntry>`              | required            | Pages to screenshot                                     |
| `locales`                | `List<Locale>`                   | required            | Languages to iterate                                    |
| `devices`                | `List<DeviceInfo>`               | required            | Target devices                                          |
| `theme`                  | `ThemeData?`                     | `ThemeData.light()` | Light theme for captures                                |
| `darkTheme`              | `ThemeData?`                     | `ThemeData.dark()`  | Dark theme for captures                                 |
| `localizationsDelegates` | `List<LocalizationsDelegate>?`   | `null`              | Your app's l10n delegates                               |
| `supportedLocales`       | `List<Locale>?`                  | `locales`           | Supported locales list                                  |
| `onLocaleChanged`        | `AutoshotLocaleChangedCallback?` | `null`              | Hook for external l10n systems (e.g. easy_localization) |
| `includeDeviceFrame`     | `bool`                           | `false`             | Include device chrome in capture                        |
| `settleDelay`            | `Duration`                       | `500ms`             | Wait time after state changes                           |

## Delivery Modes

```dart
AutoshotToolbar(
  delivery: AutoshotDelivery.zip,         // default — single .zip download
  // delivery: AutoshotDelivery.individual, // one download per image
)
```

## Architecture

```
AutoshotController        ← shared state (widget mode screen override)
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
                  ├── either navigates route OR swaps widget screen
                  ├── optional screen.prepare()
                        ├── waits for frame settle
                        ├── captures via DevicePreview.screenshot()
                        └── packages results → download/export destination
```

## Output

The ZIP contains PNGs with the naming convention:

```
autoshot/
  iphone_16_pro_max_en_us_home.png
  iphone_16_pro_max_en_us_profile.png
  iphone_16_pro_max_fr_fr_home.png
  ...
  samsung_galaxy_s20_ar_home.png
  ...
```

## Platform Support

| Platform | Status                                               |
| -------- | ---------------------------------------------------- |
| Web      | ✅ Full support (ZIP + individual browser downloads) |
| Android  | ✅ Saves files to `Download/autoshot` when available |
| iOS      | ✅ Saves files to app Documents/autoshot             |
| Desktop  | ✅ Saves files to Downloads/autoshot when available  |

## License

MIT
