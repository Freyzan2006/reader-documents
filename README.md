# reader_documents

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Development checks

Git hooks are managed by [lefthook](https://lefthook.dev/) through the
`lefthook_dart` dev dependency. The `pre-commit` hook formats staged Dart
files (excluding the vendored `packages/` fork), regenerates localizations
when ARB sources change, then runs `flutter analyze` and `flutter test`.

Install the hooks once after cloning:

```sh
flutter pub get
make hooks-install
```

Run the hook manually with `make hooks-run`, or run the CI-style checks with
`make check` (it fails on unformatted code instead of restaging fixes).
Use `LEFTHOOK=0 git commit ...` to bypass the hook when needed.

## License

Source-available under the [PolyForm Noncommercial License 1.0.0](LICENSE) — free to read, fork, modify, and use for any noncommercial purpose. Commercial use requires the copyright holder's permission.
