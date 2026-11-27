import 'package:reader_documents/core/ui_kit/theme/graphics_mode.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';

import 'device_profile.dart';

final class GraphicsModeResolver {
  const GraphicsModeResolver();

  static const lowMemoryThresholdBytes = 2 * 1024 * 1024 * 1024;

  GraphicsMode resolve({
    required AppEffectsMode preference,
    required DeviceProfile device,
    required bool platformReducesMotion,
  }) => switch (preference) {
    AppEffectsMode.quality => GraphicsMode.quality,
    AppEffectsMode.performance => GraphicsMode.performance,
    AppEffectsMode.system =>
      _isConstrained(device, platformReducesMotion)
          ? GraphicsMode.performance
          : GraphicsMode.quality,
  };

  bool _isConstrained(DeviceProfile device, bool platformReducesMotion) =>
      platformReducesMotion ||
      device.lowRamDevice ||
      device.powerSaveMode ||
      (device.totalMemoryBytes ?? lowMemoryThresholdBytes) <
          lowMemoryThresholdBytes;
}
