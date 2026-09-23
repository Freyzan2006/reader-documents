import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../data_display/card.dart';
import '../data_display/text.dart';
import '../primitives/gap.dart';
import '../tokens/app_borders.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import 'button.dart';

class AppUploadFile {
  const AppUploadFile({
    required this.name,
    this.extension,
    this.sizeBytes,
    this.path,
  });

  final String name;
  final String? extension;
  final int? sizeBytes;
  final String? path;
}

class AppUpload extends StatefulWidget {
  const AppUpload({
    required this.allowedExtensions,
    required this.onChanged,
    this.allowMultiple = false,
    super.key,
  });

  final List<String> allowedExtensions;
  final bool allowMultiple;
  final ValueChanged<List<AppUploadFile>> onChanged;

  @override
  State<AppUpload> createState() => _AppUploadState();
}

class _AppUploadState extends State<AppUpload> {
  List<AppUploadFile> _files = [];

  Future<void> _pick() async {
    final List<PlatformFile> picked;
    if (widget.allowMultiple) {
      picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
      );
    } else {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
      );
      picked = file == null ? const [] : [file];
    }

    if (picked.isEmpty) return;

    final files = [
      for (final file in picked)
        AppUploadFile(
          name: file.name,
          extension: file.extension,
          sizeBytes: file.lengthSync(),
          path: file.path,
        ),
    ];

    setState(
      () => _files = widget.allowMultiple ? [..._files, ...files] : files,
    );
    widget.onChanged(_files);
  }

  void _remove(AppUploadFile file) {
    setState(() => _files.remove(file));
    widget.onChanged(_files);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _DropZone(onTap: _pick, allowedExtensions: widget.allowedExtensions),
      if (_files.isNotEmpty) ...[
        const AppGap.sm(),
        Column(
          spacing: AppSpacing.sm,
          children: [
            for (final file in _files)
              _FileRow(file: file, onRemove: () => _remove(file)),
          ],
        ),
      ],
    ],
  );
}

class _DropZone extends StatelessWidget {
  const _DropZone({required this.onTap, required this.allowedExtensions});

  final VoidCallback onTap;
  final List<String> allowedExtensions;

  @override
  Widget build(BuildContext context) => FTappable(
    onPress: onTap,
    child: _DashedBorder(
      radius: AppRadius.of(context).md,
      color: AppBorders.color(context),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Icon(
              FLucideIcons.upload,
              color: context.theme.colors.mutedForeground,
            ),
            const AppGap.sm(),
            const AppText('Tap to upload'),
            const AppGap.xs(),
            AppText(
              allowedExtensions.map((ext) => '.$ext').join(', '),
              variant: AppTextVariant.caption,
            ),
          ],
        ),
      ),
    ),
  );
}

class _FileRow extends StatelessWidget {
  const _FileRow({required this.file, required this.onRemove});

  final AppUploadFile file;
  final VoidCallback onRemove;

  static IconData _iconFor(String? extension) =>
      switch (extension?.toLowerCase()) {
        'png' || 'jpg' || 'jpeg' => FLucideIcons.image,
        _ => FLucideIcons.fileText,
      };

  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    child: Row(
      spacing: AppSpacing.sm,
      children: [
        Icon(
          _iconFor(file.extension),
          size: 20,
          color: context.theme.colors.mutedForeground,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(file.name),
              if (file.sizeBytes != null)
                AppText(
                  _formatSize(file.sizeBytes!),
                  variant: AppTextVariant.caption,
                ),
            ],
          ),
        ),
        AppButton(
          variant: AppButtonVariant.ghost,
          onPressed: onRemove,
          child: const Icon(FLucideIcons.x),
        ),
      ],
    ),
  );
}

class _DashedBorder extends StatelessWidget {
  const _DashedBorder({
    required this.child,
    required this.radius,
    required this.color,
  });

  final Widget child;
  final BorderRadius radius;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DashedBorderPainter(radius: radius, color: color),
    child: child,
  );
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.radius, required this.color});

  final BorderRadius radius;
  final Color color;

  static const double _dashWidth = 6;
  static const double _dashSpace = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..addRRect(radius.toRRect(Offset.zero & size));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + _dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + _dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
