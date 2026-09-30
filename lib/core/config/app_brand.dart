import 'package:package_info_plus/package_info_plus.dart';

abstract final class AppBrand {
  static const name = 'MDocumentsManager';
  static const shortName = 'MDM';

  /// Runtime-populated version from pubspec.yaml (e.g. "1.0.0").
  static String version = '';

  /// Runtime-populated build number from pubspec.yaml (e.g. "1").
  static String buildNumber = '';

  /// Loads version and build number from the platform's package info.
  /// Call once at app startup.
  static Future<void> load() async {
    final info = await PackageInfo.fromPlatform();
    version = info.version;
    buildNumber = info.buildNumber;
  }
}
