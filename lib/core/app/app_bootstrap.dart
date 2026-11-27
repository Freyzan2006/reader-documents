import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/config/app_brand.dart';
import 'package:reader_documents/core/navigation/app_shell.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/presentation/actions/shared_document_intake.dart';
import 'package:reader_documents/features/settings/application/settings_providers.dart';
import 'package:reader_documents/l10n/app_localizations.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

enum AppSplashFailure { storage, timeout }

class AppBootstrap extends ConsumerStatefulWidget {
  const AppBootstrap({super.key});

  static const startupTimeout = Duration(seconds: 10);
  static const sharedCheckTimeout = Duration(seconds: 2);

  @override
  ConsumerState<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends ConsumerState<AppBootstrap>
    with SingleTickerProviderStateMixin {
  late final StreamSubscription<List<SharedMediaFile>>
  _sharedDocumentSubscription;
  late final AnimationController _fade = AnimationController(
    vsync: this,
    value: 1,
  );
  late final Animation<double> _exit = CurvedAnimation(
    parent: _fade,
    curve: AppMotion.curve,
  );
  final _sharedSettled = Completer<void>();
  bool _revealed = false;
  bool _splashGone = false;
  String? _openingName;
  AppSplashFailure? _failure;

  @override
  void initState() {
    super.initState();
    _sharedDocumentSubscription = SharedDocumentIntake.listen(context, ref);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_checkInitialSharedDocument());
      unawaited(_start());
    });
  }

  Future<void> _start() async {
    if (!await _initialize()) return;
    await _sharedSettled.future;
    await _reveal();
  }

  Future<bool> _initialize() async {
    try {
      await Future.wait([
        ref.read(settingsProvider.future),
        ref.read(documentsProvider.future),
      ]).timeout(AppBootstrap.startupTimeout);
      return true;
    } on TimeoutException {
      _fail(AppSplashFailure.timeout);
    } catch (_) {
      _fail(AppSplashFailure.storage);
    }
    return false;
  }

  void _fail(AppSplashFailure failure) {
    if (mounted) setState(() => _failure = failure);
  }

  void _retry() {
    setState(() => _failure = null);
    ref
      ..invalidate(settingsProvider)
      ..invalidate(documentsProvider);
    unawaited(_start());
  }

  void _settleShared() {
    if (!_sharedSettled.isCompleted) _sharedSettled.complete();
  }

  Future<void> _checkInitialSharedDocument() async {
    try {
      await SharedDocumentIntake.checkInitial(
        context,
        ref,
        onBeforeNavigate: _settleShared,
        onOpening: (name) {
          if (mounted) setState(() => _openingName = name);
        },
      ).timeout(AppBootstrap.sharedCheckTimeout);
    } catch (_) {
    } finally {
      _settleShared();
    }
  }

  Future<void> _reveal() async {
    if (_revealed || !mounted) return;
    _revealed = true;
    _fade.duration = context.tokens.motion.route;
    await _fade.reverse();
    if (mounted) setState(() => _splashGone = true);
  }

  @override
  void dispose() {
    _fade.dispose();
    _sharedDocumentSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const AppShell(),
        if (!_splashGone)
          FadeTransition(
            opacity: _exit,
            child: AppSplash(
              openingName: _openingName,
              failure: _failure,
              onRetry: _retry,
              exit: _exit,
            ),
          ),
      ],
    );
  }
}

class AppSplash extends StatefulWidget {
  const AppSplash({
    this.openingName,
    this.failure,
    this.onRetry,
    this.exit,
    super.key,
  });

  static const background = Color(0xFF000000);
  static const ink = Color(0xFFFFFFFF);
  static const slowAfter = Duration(milliseconds: 600);

  final String? openingName;
  final AppSplashFailure? failure;
  final VoidCallback? onRetry;
  final Animation<double>? exit;

  @override
  State<AppSplash> createState() => _AppSplashState();
}

class _AppSplashState extends State<AppSplash> {
  static const _logoWidth = 128.0;
  static const _barWidth = 160.0;
  static const _barSlot = 40.0;
  static final _track = AppSplash.ink.withValues(alpha: 0.25);
  static final _ink2 = AppSplash.ink.withValues(alpha: 0.65);

  Timer? _slowTimer;
  bool _slow = false;

  @override
  void initState() {
    super.initState();
    _slowTimer = Timer(AppSplash.slowAfter, () {
      if (mounted) setState(() => _slow = true);
    });
  }

  @override
  void dispose() {
    _slowTimer?.cancel();
    super.dispose();
  }

  Animation<double> _logoScale(BuildContext context) {
    final exit = widget.exit;
    if (exit == null || !context.tokens.motion.scale) {
      return kAlwaysCompleteAnimation;
    }
    return exit.drive(Tween(begin: AppMotion.scaleFrom, end: 1.0));
  }

  String _reason(AppLocalizations l10n, AppSplashFailure failure) =>
      switch (failure) {
        AppSplashFailure.storage => l10n.splashFailedStorage,
        AppSplashFailure.timeout => l10n.splashFailedTimeout,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = widget.openingName;
    final failure = widget.failure;
    final status = name == null ? null : l10n?.openingFile(name);
    final busy = failure == null && (_slow || status != null);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: AppSplash.background,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.lg,
                children: [
                  ScaleTransition(
                    scale: _logoScale(context),
                    child: Image.asset(
                      'assets/icon/launch_logo.png',
                      width: _logoWidth,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                  SizedBox(
                    height: _barSlot,
                    child: AnimatedOpacity(
                      opacity: busy ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: busy
                          ? Column(
                              spacing: AppSpacing.md,
                              children: [
                                SizedBox(
                                  width: _barWidth,
                                  child: AppProgress(
                                    trackColor: _track,
                                    fillColor: AppSplash.ink,
                                  ),
                                ),
                                if (AppBrand.version.isNotEmpty)
                                  Text(
                                    'v${AppBrand.version}',
                                    style: AppTextStyles.meta.copyWith(
                                      color: _ink2,
                                    ),
                                  ),
                              ],
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            if (failure != null && l10n != null)
              Positioned(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.xl3,
                child: _SplashFailure(
                  title: l10n.splashFailedTitle,
                  reason: _reason(l10n, failure),
                  retryLabel: l10n.retry,
                  onRetry: widget.onRetry,
                ),
              )
            else if (status != null)
              Positioned(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.xl4,
                child: Text(
                  status,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.meta.copyWith(color: _ink2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SplashFailure extends StatelessWidget {
  const _SplashFailure({
    required this.title,
    required this.reason,
    required this.retryLabel,
    this.onRetry,
  });

  static const _buttonHeight = 44.0;

  final String title;
  final String reason;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.sm,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.subtitle.copyWith(color: AppSplash.ink),
        ),
        Text(
          reason,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(
            color: AppSplash.ink.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTappable(
          onPressed: onRetry,
          semanticsLabel: retryLabel,
          child: Container(
            height: _buttonHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            decoration: const BoxDecoration(
              color: AppSplash.ink,
              borderRadius: AppRadii.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.sm,
              children: [
                const Icon(
                  AppIcons.rotateCw,
                  size: 18,
                  color: AppSplash.background,
                ),
                Text(
                  retryLabel,
                  style: AppTextStyles.label.copyWith(
                    color: AppSplash.background,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
