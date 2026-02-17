# Changelog

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
