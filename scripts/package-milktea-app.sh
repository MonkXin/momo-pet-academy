#!/bin/zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEVELOPER_DIR="${DEVELOPER_DIR:-/Users/monkxin/Downloads/Xcode.app/Contents/Developer}"
BUILD_DIR="$ROOT/.build/arm64-apple-macosx/release"
APP="$ROOT/dist/奶茶的学堂时光.app"
ICONSET="$ROOT/dist/Milktea.iconset"

cd "$ROOT"
DEVELOPER_DIR="$DEVELOPER_DIR" swift build -c release --disable-sandbox

rm -rf "$APP" "$ICONSET"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$ICONSET"

SOURCE="$ROOT/Sources/MomoPetApp/Resources/momo-rabbit-3d.png"
for size in 16 32 128 256 512; do
  sips -z "$size" "$size" "$SOURCE" --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
  doubled=$((size * 2))
  sips -z "$doubled" "$doubled" "$SOURCE" --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/Milktea.icns"

cp "$BUILD_DIR/MomoPetApp" "$APP/Contents/MacOS/MomoPetApp"
cp -R "$BUILD_DIR/MomoPetApp_MomoPetApp.bundle" "$APP/Contents/Resources/"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleDisplayName</key><string>奶茶的学堂时光</string>
  <key>CFBundleExecutable</key><string>MomoPetApp</string>
  <key>CFBundleIconFile</key><string>Milktea</string>
  <key>CFBundleIdentifier</key><string>com.monkxin.milkteapet</string>
  <key>CFBundleName</key><string>奶茶的学堂时光</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>12.0</string>
</dict></plist>
PLIST

chmod +x "$APP/Contents/MacOS/MomoPetApp"
rm -rf "$ICONSET"
echo "已生成：$APP"
