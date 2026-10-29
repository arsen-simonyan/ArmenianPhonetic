#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
APP_PATH="$PROJECT_DIR/build/Armenian Phonetic.app"

printf '%s\n' 'Կառուցվում է Armenian Phonetic հավելվածը։'
rm -rf "$APP_PATH"
mkdir -p "$APP_PATH/Contents/MacOS"
ditto "$PROJECT_DIR/Resources" "$APP_PATH/Contents/Resources"
mv "$APP_PATH/Contents/Resources/Info.plist" "$APP_PATH/Contents/Info.plist"

xcrun swift "$PROJECT_DIR/Source/make-icon.swift" "$APP_PATH/Contents/Resources/HY.pdf"
xcrun clang -target arm64-apple-macos27.0 -fobjc-arc -O2 -Wall -Wextra \
  -Wno-unused-parameter -framework Cocoa -framework Carbon -framework InputMethodKit \
  "$PROJECT_DIR/Source/main.m" -o "$APP_PATH/Contents/MacOS/ArmenianPhonetic"
codesign --force --sign - "$APP_PATH"
codesign --verify --deep --strict "$APP_PATH"
printf '%s\n' "Հավելվածը պատրաստ է՝ $APP_PATH"
