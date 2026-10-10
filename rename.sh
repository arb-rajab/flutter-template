#!/usr/bin/env bash
# Rename the template to your app. Run once, from the repo root, before the first commit.
#
#   ./rename.sh <dart_package_name> "<Display Name>" <android.application.id>
#   ./rename.sh my_app "My App" com.acme.my_app
#
# dart_package_name: lowercase letters, digits and underscores (becomes the Dart package name).
# The iOS bundle id is derived from the application id by dropping underscores.
# The root widget class name is derived from the display name by dropping spaces.
set -euo pipefail

if [ "$#" -ne 3 ]; then
  echo "usage: $0 <dart_package_name> \"<Display Name>\" <application.id>" >&2
  exit 1
fi
PKG="$1"; NAME="$2"; APP_ID="$3"
IOS_ID="${APP_ID//_/}"
CLASS="${NAME// /}"

[[ "$PKG" =~ ^[a-z][a-z0-9_]*$ ]] || { echo "package name must match ^[a-z][a-z0-9_]*$" >&2; exit 1; }
[[ "$APP_ID" =~ ^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$ ]] || { echo "invalid application id (lowercase, dot separated)" >&2; exit 1; }
[[ "$CLASS" =~ ^[A-Za-z][A-Za-z0-9]*$ ]] || { echo "display name must be letters, digits and spaces" >&2; exit 1; }

# Order matters: ids contain the package token, so replace them first.
FILES=$(grep -rlE 'com\.example\.starter_app|com\.example\.starterApp|Starter App|StarterApp|starter_app' . \
  --exclude-dir=.git --exclude-dir=.dart_tool --exclude-dir=build --exclude=rename.sh \
  --exclude=pubspec.lock --exclude='*.png' || true)
for f in $FILES; do
  sed -i \
    -e "s|com\.example\.starter_app|${APP_ID}|g" \
    -e "s|com\.example\.starterApp|${IOS_ID}|g" \
    -e "s|Starter App|${NAME}|g" \
    -e "s|StarterApp|${CLASS}|g" \
    -e "s|starter_app|${PKG}|g" "$f"
done

# Move the Kotlin source directory to match the package declaration.
OLD_DIR="android/app/src/main/kotlin/com/example/starter_app"
NEW_DIR="android/app/src/main/kotlin/$(echo "$APP_ID" | tr . /)"
if [ -d "$OLD_DIR" ] && [ "$OLD_DIR" != "$NEW_DIR" ]; then
  mkdir -p "$NEW_DIR"
  mv "$OLD_DIR"/* "$NEW_DIR"/
  rmdir "$OLD_DIR" 2>/dev/null || true
  # Remove now-empty leftover template directories.
  rmdir android/app/src/main/kotlin/com/example 2>/dev/null || true
fi

echo "Renamed to ${NAME} (${PKG}, ${APP_ID}, iOS ${IOS_ID}). Then run:"
echo "  flutter pub get && dart format lib test integration_test && flutter analyze && flutter test"
echo "Update the copyright line in LICENSE for your project and delete this script when done."
