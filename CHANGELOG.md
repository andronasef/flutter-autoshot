# Changelog

## 1.3.2

- Fixed `_wrapScreen` dark-mode handling: replaced `DevicePreview.isDarkMode()` (non-existent API) with `ThemeMode.system`, which correctly reads the `platformBrightness` that `DevicePreview.appBuilder` injects.
- Simplified example: replaced the complex grid/chart UI with clean, minimal screens (Home: greeting card + 4 memo tiles; Detail: centred icon + headline + CTA; Stats: 3 stat cards).
- Migrated example to native Flutter localisation (ARB files) — removed the intermediate `_S` helper class entirely.
- Reduced ARB keys from 40+ to 17, covering all 5 locales (English, Arabic, French, Japanese, German).

## 1.3.1

- Fixed widget-based screen captures (`ScreenEntry.widget`) not respecting DevicePreview's dark-mode toggle — added `themeMode: DevicePreview.isDarkMode(context) ? ThemeMode.dark : ThemeMode.light` to `_wrapScreen`.
- Updated example: 5 locales (English, Arabic, French, Japanese, German), 3 screens (Home, Detail, Stats), proper `localizationsDelegates` + `supportedLocales`, and `themeMode` wired to `DevicePreview.isDarkMode` so the locale/dark-mode toggles in DevicePreview are reflected live in the app.

## 1.3.0

- Added `AutoshotLocaleChangedCallback` typedef for hooking into locale switches.
- Added `onLocaleChanged` callback to `AutoshotConfig` to synchronise external localisation systems (e.g. `easy_localization`) that are not driven by DevicePreview's locale state.
- Fixed locale switching format: use `locale.toString()` (e.g. `en_US`) instead of `toLanguageTag()` (e.g. `en-US`) so DevicePreview parses the locale correctly.

## 1.2.0

- Saved captures to a real file location on non-web platforms instead of throwing unsupported download errors.
- On Android phones, screenshots are exported to the Downloads folder when available.
- Fixed locale switching during capture by using a DevicePreview-compatible locale tag format.
- Moved the Autoshot section to the top of DevicePreview tools when using the `Autoshot` wrapper.
- Updated example locales/content so locale-based screenshot differences are visible.

## 1.1.2

- Updated SDK constraints for better compatibility.

## 1.1.1

- Updated SDK constraints for better compatibility.

## 1.1.0

- Fixed `DevicePreview` compatibility issues with `backgroundColor` and `padding`.
- Updated homepage URL.
- Optimized package description for pub.dev.
- Improved dependency constraints.

## 1.0.0

- Initial release of **autoshot**.
- Wraps `device_preview` as a dependency — single import, single dependency.
- Automated screenshot generation across devices × locales × screens.
- ZIP download for Flutter Web.
- Progress UI in the device_preview toolbar.
