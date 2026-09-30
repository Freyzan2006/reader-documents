import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/config/app_brand.dart';

final appBrandProvider = FutureProvider<void>((ref) async {
  await AppBrand.load();
});
