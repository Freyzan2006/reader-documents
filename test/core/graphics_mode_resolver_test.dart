import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/core/device/device_profile.dart';
import 'package:reader_documents/core/device/graphics_mode_resolver.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';

const _gb = 1024 * 1024 * 1024;

DeviceProfile _device({
  int? memory = 6 * _gb,
  bool lowRam = false,
  bool powerSave = false,
}) => DeviceProfile(
  totalMemoryBytes: memory,
  lowRamDevice: lowRam,
  powerSaveMode: powerSave,
);

GraphicsMode _auto(DeviceProfile device, {bool reducesMotion = false}) =>
    const GraphicsModeResolver().resolve(
      preference: AppEffectsMode.system,
      device: device,
      platformReducesMotion: reducesMotion,
    );

void main() {
  test('auto picks quality on a capable device', () {
    expect(_auto(_device()), GraphicsMode.quality);
  });

  test('auto picks performance below 2 GB of memory', () {
    expect(_auto(_device(memory: 2 * _gb - 1)), GraphicsMode.performance);
    expect(_auto(_device(memory: 2 * _gb)), GraphicsMode.quality);
  });

  test('auto picks performance on low-ram devices and in power saving', () {
    expect(_auto(_device(lowRam: true)), GraphicsMode.performance);
    expect(_auto(_device(powerSave: true)), GraphicsMode.performance);
  });

  test('auto picks performance when the system reduces motion', () {
    expect(_auto(_device(), reducesMotion: true), GraphicsMode.performance);
  });

  test('auto falls back to quality when the device cannot be read', () {
    expect(_auto(DeviceProfile.unknown), GraphicsMode.quality);
  });

  test('an explicit choice wins over the device', () {
    const resolver = GraphicsModeResolver();
    expect(
      resolver.resolve(
        preference: AppEffectsMode.quality,
        device: _device(lowRam: true),
        platformReducesMotion: true,
      ),
      GraphicsMode.quality,
    );
    expect(
      resolver.resolve(
        preference: AppEffectsMode.performance,
        device: _device(),
        platformReducesMotion: false,
      ),
      GraphicsMode.performance,
    );
  });

  test('device profile reads the platform map', () {
    final profile = DeviceProfile.fromMap({
      'totalMemoryBytes': 3 * _gb,
      'lowRamDevice': true,
      'powerSaveMode': false,
    });
    expect(profile.totalMemoryBytes, 3 * _gb);
    expect(profile.lowRamDevice, isTrue);
    expect(profile.powerSaveMode, isFalse);
  });

  test('performance keeps only cheap motion, reduce motion keeps none', () {
    const performance = AppMotion.performance;
    expect(performance.expressive, isFalse);
    expect(performance.layoutChange, Duration.zero);
    expect(performance.paletteChange, Duration.zero);
    expect(performance.sheet, greaterThan(Duration.zero));
    expect(performance.reveal, Duration.zero);
    expect(performance.staggerDelay(0), isNull);
    expect(AppMotion.quality.staggerDelay(AppMotion.staggerLimit), isNull);

    final reduced = AppMotion.resolve(GraphicsMode.quality, reduceMotion: true);
    expect(reduced.route, Duration.zero);
    expect(reduced.sheet, Duration.zero);
  });
}
