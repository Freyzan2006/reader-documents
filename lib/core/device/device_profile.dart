import 'package:flutter/services.dart';

final class DeviceProfile {
  const DeviceProfile({
    required this.totalMemoryBytes,
    required this.lowRamDevice,
    required this.powerSaveMode,
  });

  static const unknown = DeviceProfile(
    totalMemoryBytes: null,
    lowRamDevice: false,
    powerSaveMode: false,
  );

  factory DeviceProfile.fromMap(Map<Object?, Object?> map) => DeviceProfile(
    totalMemoryBytes: (map['totalMemoryBytes'] as num?)?.toInt(),
    lowRamDevice: map['lowRamDevice'] == true,
    powerSaveMode: map['powerSaveMode'] == true,
  );

  final int? totalMemoryBytes;
  final bool lowRamDevice;
  final bool powerSaveMode;
}

final class DeviceProfileSource {
  const DeviceProfileSource();

  static const _channel = MethodChannel(
    'uz.freyzan.mdocumentsmanager/device_profile',
  );

  Future<DeviceProfile> read() async {
    try {
      final map = await _channel.invokeMapMethod<Object?, Object?>('read');
      return map == null ? DeviceProfile.unknown : DeviceProfile.fromMap(map);
    } on PlatformException {
      return DeviceProfile.unknown;
    } on MissingPluginException {
      return DeviceProfile.unknown;
    }
  }
}
