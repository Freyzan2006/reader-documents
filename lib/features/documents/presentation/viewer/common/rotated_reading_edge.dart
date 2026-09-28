import 'package:reader_documents/core/ui_kit/ui_kit.dart';

/// The true screen edge that corresponds to the rotated reading frame's own
/// "bottom" — `RotatedBox` rotates clockwise, so each +1 quarter turn walks
/// bottom→left→top→right. Side panels anchored here read as sliding in from
/// the bottom of the rotated content, not an arbitrary screen edge.
AppEdge rotatedReadingBottomEdge(int quarterTurns) => const [
  AppEdge.bottom,
  AppEdge.left,
  AppEdge.top,
  AppEdge.right,
][quarterTurns % 4];
