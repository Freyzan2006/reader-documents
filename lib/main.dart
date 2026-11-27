import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app/application.dart';
import 'core/config/app_brand.dart';
import 'core/ui_kit/ui_kit.dart';

void main() async {
  AppIcons.prepareTreeShaking();
  WidgetsFlutterBinding.ensureInitialized();
  await AppBrand.load();
  runApp(const ProviderScope(child: Application()));
}
