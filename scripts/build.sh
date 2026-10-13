#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
PROJECT_ROOT="$PWD"
# Xcode and SwiftPM embed a resource fallback location. Build from an anonymous
# copy so this generated literal cannot expose the builder's account or clone path.
BUILD_ROOT="$(mktemp -d /tmp/lgwebos-menubar-build.XXXXXX)"
trap 'rm -rf "$BUILD_ROOT"' EXIT
tar -C "$PROJECT_ROOT" \
  --exclude .git --exclude dist --exclude .build --exclude .swiftpm \
  --exclude .local --exclude research --exclude DerivedData \
  -cf - . | tar -C "$BUILD_ROOT" -xf -
xcodebuild \
  -project "$BUILD_ROOT/Apps/macOS/LGwebOS-menubar.xcodeproj" \
  -scheme "LGwebOS-menubar" \
  -configuration Release \
  -destination "platform=macOS" \
  -derivedDataPath "$BUILD_ROOT/DerivedData" \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGN_STYLE=Manual \
  "OTHER_SWIFT_FLAGS=-file-prefix-map $BUILD_ROOT=. -debug-prefix-map $BUILD_ROOT=." \
  "OTHER_CFLAGS=-ffile-prefix-map=$BUILD_ROOT=." \
  build
APP="$PROJECT_ROOT/dist/LGwebOS-menubar.app"
rm -rf "$APP"
mkdir -p "$PROJECT_ROOT/dist"
cp -R "$BUILD_ROOT/DerivedData/Build/Products/Release/LGwebOS-menubar.app" "$APP"
strip -S "$APP/Contents/MacOS/LGwebOSMenubar"
codesign --force --deep --sign - --identifier br.local.LGRemote "$APP"
printf 'App created at %s\n' "$APP"
