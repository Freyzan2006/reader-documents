import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/navigation/app_shell.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/presentation/actions/shared_document_intake.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class AppBootstrap extends ConsumerStatefulWidget {
  const AppBootstrap({super.key});

  @override
  ConsumerState<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends ConsumerState<AppBootstrap> {
  late final StreamSubscription<List<SharedMediaFile>>
  _sharedDocumentSubscription;
  bool _bootstrapping = true;
  bool _revealed = false;
  Timer? _revealTimer;
  final Stopwatch _uptime = Stopwatch()..start();

  /// A fast open can resolve before the first frame has even presented, which
  /// would show a black screen with no logo on it. Holding the splash for a
  /// beat makes it always land. Measured from widget construction, not from the
  /// moment the work finished, so a quick start still shows it.
  static const _minVisible = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _sharedDocumentSubscription = SharedDocumentIntake.listen(context, ref);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _checkInitialSharedDocument(),
    );
  }

  Future<void> _checkInitialSharedDocument() async {
    try {
      await SharedDocumentIntake.checkInitial(
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
    final remaining = _minVisible - _uptime.elapsed;
    if (remaining <= Duration.zero) {
      _hide();
    } else {
      _revealTimer = Timer(remaining, _hide);
    }
  }

  void _hide() {
    if (!mounted) return;
    setState(() => _bootstrapping = false);
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _sharedDocumentSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _bootstrapping
      ? const ColoredBox(color: Color(0xFF000000), child: _Splash())
      : const AppShell();
}

/// Flutter-side half of the launch screen.
///
/// Black rather than the theme background on purpose: the native splash it
/// hands over from is black, so this keeps the handoff seamless and avoids a
/// white flash on a dark system theme. The glyph and the bar are white for the
/// same reason — the theme's `primary`/`muted` cannot be read on black.
class _Splash extends StatelessWidget {
  const _Splash();

  /// The glyph's own width, not the asset's: launch_logo.png is cropped to the
  /// glyph's bounding box, so one number describes both.
  static const _logoWidth = 128.0;
  static const _barWidth = 160.0;
  static const _white = Color(0xFFFFFFFF);

  // Dimmed rather than white: the moving segment has to stand out against its
  // own track, and two solid whites would cancel each other out.
  static final _track = _white.withValues(alpha: 0.25);

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.lg,
      children: [
        Image.asset(
          'assets/icon/launch_logo.png',
          width: _logoWidth,
          filterQuality: FilterQuality.medium,
        ),
        SizedBox(
          width: _barWidth,
          child: AppProgress(trackColor: _track, fillColor: _white),
        ),
      ],
    ),
  );
}
