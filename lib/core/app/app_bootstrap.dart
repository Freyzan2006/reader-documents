import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/navigation/app_shell.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/presentation/shared_pdf_intake.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class AppBootstrap extends ConsumerStatefulWidget {
  const AppBootstrap({super.key});

  @override
  ConsumerState<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends ConsumerState<AppBootstrap> {
  late final StreamSubscription<List<SharedMediaFile>> _sharedPdfSubscription;
  bool _bootstrapping = true;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _sharedPdfSubscription = SharedPdfIntake.listen(context, ref);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _checkInitialSharedPdf(),
    );
  }

  Future<void> _checkInitialSharedPdf() async {
    try {
      await SharedPdfIntake.checkInitial(
        context,
        ref,
        onBeforeNavigate: _reveal,
      ).timeout(const Duration(seconds: 2));
    } catch (_) {
    } finally {
      _reveal();
    }
  }

  void _reveal() {
    if (_revealed || !mounted) return;
    _revealed = true;
    setState(() => _bootstrapping = false);
  }

  @override
  void dispose() {
    _sharedPdfSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _bootstrapping
      ? ColoredBox(color: AppColors.of(context).background)
      : const AppShell();
}
