import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart' show FBuildContext, FLucideIcons;
import 'package:pdfrx/pdfrx.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/document_file.dart';

class PdfViewerScreen extends StatelessWidget {
  const PdfViewerScreen({required this.file, super.key});

  final DocumentFile file;

  static Widget _buildLoadingBanner(
    BuildContext context,
    int bytesDownloaded,
    int? totalBytes,
  ) => const AppCenter(child: AppSpinner());

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Stack(
      children: [
        Positioned.fill(
          child: PdfViewer.file(
            file.path,
            params: PdfViewerParams(
              backgroundColor: colors.background,
              sizeDelegateProvider: const PdfViewerSizeDelegateProviderLegacy(
                useAlternativeFitScaleAsMinScale: false,
              ),
              behaviorControlParams: const PdfViewerBehaviorControlParams(
                loadPageDimensionsOnDemand: true,
              ),
              loadingBannerBuilder: _buildLoadingBanner,
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: AppHeader.height,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  spacing: AppSpacing.md,
                  children: [
                    AppIconButton(
                      icon: FLucideIcons.arrowLeft,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Center(
                        child: AppCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          child: AppText(
                            file.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    AppBadge(
                      variant: AppBadgeVariant.secondary,
                      child: Text(file.type.label),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
