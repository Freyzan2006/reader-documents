.DEFAULT_GOAL := help

.PHONY: help dev dev-android dev-linux devices get analyze test format check check-format check-translations translations hooks-install hooks-run clean doctor build-apk

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

dev: ## Run the app with hot reload (prompts for a device if more than one is connected)
	flutter run

dev-android: ## Run the app on the connected Android device/phone
	flutter run -d android

dev-linux: ## Run the app as a Linux desktop window
	flutter run -d linux

devices: ## List devices Flutter can see (phone, desktop, browser)
	flutter devices

get: ## Fetch/update dependencies from pubspec.yaml
	flutter pub get

analyze: ## Static analysis (flutter analyze)
	flutter analyze

test: ## Run the test suite
	flutter test

format: ## Format all Dart source files
	dart format .

check: check-format check-translations analyze test ## Full CI check (mirrors pre-commit)

check-format: ## Verify formatting of first-party Dart code without touching vendored packages
	dart format --set-exit-if-changed lib test tool

check-translations: ## Verify ARB fragments stay in sync and localizations generate
	dart run tool/merge_arb.dart
	flutter gen-l10n

translations: ## Merge lib/l10n/src/*/*.arb fragments and regenerate localizations
	dart run tool/merge_arb.dart
	flutter gen-l10n

hooks-install: ## Install lefthook git hooks into .git/hooks
	dart run lefthook_dart install

hooks-run: ## Run pre-commit checks manually (same as `git commit` would)
	dart run lefthook_dart run pre-commit

clean: ## Remove build artifacts
	flutter clean

doctor: ## Show Flutter/Android/toolchain setup status
	flutter doctor -v

build-apk: ## Build a release APK
	flutter build apk
