# Vendored fork — local patch notes

Vendored from `docx_file_viewer` **1.0.4** (pub.dev), copied verbatim from
`~/.pub-cache/hosted/pub.dev/docx_file_viewer-1.0.4/` except for `example/`
(removed, not needed here) and the changes below.

## Why this is vendored instead of a plain pub.dev dependency

The app wraps the rendered document in Flutter's own `SelectionArea` to get a
custom, app-styled selection context menu (matching the PDF viewer's) instead
of the platform default. That only works for descendants built from `Text`/
`Text.rich`/`RichText` — Flutter's ambient-`SelectionArea` auto-registration
lives in the `Text` widget itself. The stock package instead used
`SelectableText.rich` (a widget with its *own*, independent selection and
default Material toolbar, with no `contextMenuBuilder` exposed to override
it) whenever `DocxViewConfig.enableSelection` is `true`, which doesn't
register with an ambient `SelectionArea` at all.

## Patch 1 — `SelectableText.rich` → `Text.rich`

Three call sites changed under the `config.enableSelection` branch (`Text.rich`
still renders identically — selection now just comes from the ambient
`SelectionArea` in `DocxDocumentViewer` instead of a per-widget one):

- `lib/src/widget_generator/paragraph_builder.dart` — two occurrences
  (the "no floats" fast path, and the floating-layout text widget).
- `lib/src/widget_generator/list_builder.dart` — one occurrence (list item
  text).

Each site has an inline comment explaining why.

## Patch 2 — horizontal scroll for over-wide floating images/shapes

`RenderFlex overflowed by N pixels` on the `Row` that lays out a paragraph
beside its floating images/shapes. Both of those rows are built as

```dart
Row(children: [
  if (lefts.isNotEmpty) ...[floatColumn(lefts), SizedBox(width: 12)],
  Expanded(child: textWidget),
  if (rights.isNotEmpty) ...[SizedBox(width: 12), floatColumn(rights)],
])
```

The float columns are sized at their intrinsic width straight from the
document (`DocxInlineImage.width`, or
`DocxUnits.pointsToPixels(DocxShape.width)`) and never shrink. Once the floats
wider than the page, `Expanded` collapses to zero and the row still overflows —
on a narrow phone this fires reliably for documents with wide inline images.

Fix, applied to both rows: a `LayoutBuilder` computes the width the floats
demand (widest child per column, since a `Column` sizes its cross axis to its
widest child, plus the spacers, plus a `_minFloatTextWidth` = 64px reserve for
the text). If that total fits the incoming `maxWidth`, the row is returned
unchanged. Otherwise it is wrapped in a `SingleChildScrollView`
(`Axis.horizontal`) around an explicit `SizedBox(width: reservedWidth)` — the
finite width is required, because a horizontal scroll view hands its child
unbounded width and `Expanded` cannot lay out against that.

Content is preserved in full: the user scrolls sideways to reach the rest of
the paragraph, rather than it being clipped or scaled.

- `lib/src/widget_generator/docx_widget_generator.dart` — the block-level
  float row (`buildFloatColumn` neighbours).
- `lib/src/widget_generator/paragraph_builder.dart` — `_buildFloatingLayout`.
  The `IntrinsicHeight` moved inside the `LayoutBuilder` so it still wraps the
  row in both branches.

Note the two rows compute float widths slightly differently, and that is
intentional — it mirrors how each one actually renders its floats. The
`docx_widget_generator.dart` row passes `img.width` to `Image.memory`
**unconverted**, whereas `_buildFloatingLayout` converts with
`DocxUnits.pointsToPixels`. Whichever you keep, the width calculation must stay
in step with the rendering expression in the same function.

## App-side note

No wrapper is needed in `DocxDocumentViewer`. `FittedBox` and `ConstrainedBox`
were both tried there and neither helps: they act on the `DocxView` subtree
before the inner rows lay out, and `FittedBox` in particular passes unbounded
width down, which just moves the failure to a different assertion
(`BoxConstraints forces an infinite width` in `paragraph_builder.dart`).

## Updating to a newer upstream version

1. Fetch the new version's source, e.g. `flutter pub cache add
   docx_file_viewer:<version>` in a scratch project, then copy
   `~/.pub-cache/hosted/pub.dev/docx_file_viewer-<version>/` over this
   directory (keep this `PATCH.md`, drop `example/` again).
2. Reapply Patch 1: search for `SelectableText.rich` (should still be three
   sites — if upstream hasn't restructured that code, that's all of them; if it
   has, adapt the substitution to the new shape).
3. Reapply Patch 2: find the float-layout `Row`s (both contain a float column
   next to `Expanded`) and restore the `LayoutBuilder` + conditional horizontal
   `SingleChildScrollView` around them.
4. Bump the version note at the top of this file.
5. `flutter pub get` in the app, then a full `flutter analyze` / `flutter
   test` / on-device pass before trusting the update.
