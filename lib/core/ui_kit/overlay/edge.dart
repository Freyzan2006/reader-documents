import 'package:flutter/widgets.dart';

enum AppEdge {
  top,
  bottom,
  left,
  right;

  bool get vertical => this == top || this == bottom;

  Offset get hiddenOffset => switch (this) {
    top => const Offset(0, -1),
    bottom => const Offset(0, 1),
    left => const Offset(-1, 0),
    right => const Offset(1, 0),
  };

  Offset get freeEdgeDirection => -hiddenOffset;

  Alignment get alignment => switch (this) {
    top => Alignment.topCenter,
    bottom => Alignment.bottomCenter,
    left => Alignment.centerLeft,
    right => Alignment.centerRight,
  };
}
