import 'package:flutter_riverpod/legacy.dart';

import 'app_nav_tab.dart';

final currentNavDestinationProvider = StateProvider<AppNavDestination>(
  (ref) => AppNavDestination.home,
);
