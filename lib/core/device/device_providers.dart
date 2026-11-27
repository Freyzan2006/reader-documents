import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'device_profile.dart';

final deviceProfileSourceProvider = Provider<DeviceProfileSource>(
  (ref) => const DeviceProfileSource(),
);

class DeviceProfileNotifier extends AsyncNotifier<DeviceProfile> {
  @override
  Future<DeviceProfile> build() {
    final lifecycle = AppLifecycleListener(onResume: ref.invalidateSelf);
    ref.onDispose(lifecycle.dispose);
    return ref.read(deviceProfileSourceProvider).read();
  }
}

final deviceProfileProvider =
    AsyncNotifierProvider<DeviceProfileNotifier, DeviceProfile>(
      DeviceProfileNotifier.new,
    );
