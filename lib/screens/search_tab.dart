import 'package:flutter/widgets.dart';

import '../core/ui_kit/ui_kit.dart';

class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context) => const AppCenter(
    child: AppText('Search coming soon', variant: AppTextVariant.caption),
  );
}
