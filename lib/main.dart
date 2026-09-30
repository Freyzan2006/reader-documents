import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app/application.dart';
import 'core/config/app_brand.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBrand.load();
  runApp(const ProviderScope(child: Application()));
}
