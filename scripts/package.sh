#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
"$PROJECT_DIR/scripts/build.sh"

APP_PATH="$PROJECT_DIR/build/Armenian Phonetic.app"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP_PATH/Contents/Info.plist")"
ARCHITECTURE="$(lipo -archs "$APP_PATH/Contents/MacOS/ArmenianPhonetic")"
PKG_PATH="$PROJECT_DIR/dist/ArmenianPhonetic-$VERSION-$ARCHITECTURE.pkg"
PKG_DIR="$PROJECT_DIR/build/package"
rm -rf "$PKG_DIR"
mkdir -p "$PKG_DIR/payload" "$PROJECT_DIR/dist"
ditto "$APP_PATH" "$PKG_DIR/payload/Armenian Phonetic.app"

printf '%s\n' 'Ստեղծվում է PKG տեղադրիչը։'
pkgbuild --analyze --root "$PKG_DIR/payload" "$PKG_DIR/components.plist"
plutil -replace 0.BundleIsRelocatable -bool false "$PKG_DIR/components.plist"
pkgbuild --root "$PKG_DIR/payload" --component-plist "$PKG_DIR/components.plist" \
  --identifier local.arsen.pkg.ArmenianPhonetic --version "$VERSION" \
  --install-location '/Library/Input Methods' "$PKG_DIR/component.pkg"
productbuild --distribution "$PROJECT_DIR/installer/Distribution.xml" \
  --resources "$PROJECT_DIR/installer/resources" --package-path "$PKG_DIR" \
  "$PKG_PATH"
printf '%s\n' "Տեղադրիչը պատրաստ է՝ $PKG_PATH"
