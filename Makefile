.DEFAULT_GOAL := help

SHELL := /bin/bash

# Use `make release DEVICE=<serial>` when more than one phone is connected
DEVICE ?=
ADB = adb$(if $(DEVICE), -s $(DEVICE))

.PHONY: help dev dev-android dev-linux devices get analyze test format check check-format check-translations translations hooks-install hooks-run clean doctor build-apk bump-version release-install release

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

check-format: ## Verify formatting of Dart sources
	dart format --set-exit-if-changed lib test tool

check-translations: ## Verify ARB fragments stay in sync and localizations generate
	dart run tool/merge_arb.dart
	flutter gen-l10n

translations: ## Merge lib/l10n/src/*/*.arb fragments and regenerate localizations
	dart run tool/merge_arb.dart
	flutter gen-l10n

hooks-install: ## Point git at the tracked .githooks scripts (no global lefthook needed)
	git config core.hooksPath .githooks
	dart run lefthook_dart validate

hooks-run: ## Run pre-commit checks manually (same as `git commit` would)
	dart run lefthook_dart run pre-commit

clean: ## Remove build artifacts
	flutter clean

doctor: ## Show Flutter/Android/toolchain setup status
	flutter doctor -v

build-apk: ## Build a release APK
	flutter build apk

bump-version: ## Bump patch version in pubspec.yaml and commit it (VERSION=x.y.z to set explicitly)
	@cur=$$(sed -nE 's/^version: *([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+).*/\1+\2/p' pubspec.yaml); \
	if [ -z "$$cur" ]; then echo "Cannot read version: from pubspec.yaml" >&2; exit 1; fi; \
	other=$$(git diff HEAD -U0 -- pubspec.yaml | grep -E '^[+-][^+-]' | grep -vE '^[+-]version: ' | wc -l); \
	if [ "$$other" -gt 0 ]; then echo "pubspec.yaml has other uncommitted changes; commit them before releasing" >&2; exit 1; fi; \
	base=$${cur%%+*}; code=$${cur##*+}; \
	if [ -n "$(VERSION)" ]; then \
		base="$(VERSION)"; \
	else \
		major=$$(echo "$$base" | cut -d. -f1); minor=$$(echo "$$base" | cut -d. -f2); patch=$$(echo "$$base" | cut -d. -f3); \
		base="$$major.$$minor.$$((patch + 1))"; \
	fi; \
	code=$$((code + 1)); \
	sed -i -E "s/^version: .*/version: $$base+$$code/" pubspec.yaml; \
	git add pubspec.yaml && git commit -m "chore(release): $$base [skip ci]"; \
	echo "Version bumped to $$base+$$code"

release-install: ## Build release APK and install it on the phone (keeps app data)
	flutter build apk --release
	@$(ADB) get-state >/dev/null || { echo "No authorized Android device; check 'adb devices'" >&2; exit 1; }
	$(ADB) install -r build/app/outputs/apk/release/app-release.apk

release: bump-version ## Bump version, commit it, build release APK and install it on the phone
	@$(MAKE) --no-print-directory release-install
