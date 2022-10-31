#!/usr/bin/env bash
## https://stackoverflow.com/questions/69354021/how-do-i-go-about-code-signing-a-macos-application

extract_zip() {
  mkdir -p "$WORK_PATH"
  unzip "$ZIP_PATH" -d "$WORK_PATH"
}

create_zip() {
  ditto -c -k --keepParent "$APP_PATH"  "$ZIP_PATH"
}

create_dmg() {
  OLD_PATH=$(pwd)
  cd "$EXPORT_PATH"
  create-dmg "$1" --dmg-title "$PRODUCT_NAME" --identity="$ID" --overwrite
  cd "$OLD_PATH"
}

get_dmg_path() {
  PATH=$(find "$EXPORT_PATH" -maxdepth 1 -type f -iname "*.dmg" | head -1)
  echo "$PATH"
}

codesign_item() {
  FILE=$1
  codesign -s "$APP_ID" --timestamp "$FILE"
}

notarize_item() {
  FILE=$1
  xcrun notarytool submit "$FILE" --apple-id "$EMAIL" --team-id "$TEAM_ID" --password "$PASSWORD"
  # xcrun altool --notarize-app --primary-bundle-id "$APP_ID" -u "$EMAIL" -p "$PASSWORD" -t osx -f "$FILE"
  read -r -p "Press Y when Apple sends an email indicating that $FILE has been aproved? [y/N] " prompt
  if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
  then
    echo ""
  else
    clean_all
    exit 0
  fi
}

staple_item() {
  FILE=$1
  xcrun stapler staple "$FILE"
}

notarize_history() {
  # xcrun altool --notarization-history 0 -u "$EMAIL" -p "$PASSWORD"
  xcrun notarytool history --apple-id "$EMAIL" --team-id "$TEAM_ID" --password "$PASSWORD"
}

check_dmg() {
  FILE=$1
  spctl -a -vv -t install "$FILE"
}

check_app() {
  FILE=$1
  spctl -a -vv "$FILE"
}

check_staple() {
  FILE=$1
  xcrun stapler validate "$FILE"
}

clean_dist() {
  rm -rf "$WORK_PATH" 2> /dev/null
}

clean_up() {
  rm -rf "$ZIP_PATH" 2> /dev/null
  DMG_PATH=$(get_dmg_path)
  rm -rf "$DMG_PATH" 2> /dev/null
}

clean_all() {
  clean_dist
  clean_up
}

dist_dmg() {
  mv "$DMG_PATH" "$WORK_PATH" 2> /dev/null
}

source .env

EXPORT_PATH="$PWD/build"
WORK_PATH="$EXPORT_PATH/dist"
APP_PATH="$EXPORT_PATH/$PRODUCT_NAME.app"
ZIP_PATH="$EXPORT_PATH/$PRODUCT_NAME.zip"
NOTARIZED_APP_PATH="$WORK_PATH/$PRODUCT_NAME.app"

clean_dist
create_zip
notarize_item "$ZIP_PATH"
extract_zip
staple_item "$NOTARIZED_APP_PATH"
create_dmg "$NOTARIZED_APP_PATH"
DMG_PATH=$(get_dmg_path)
notarize_item "$DMG_PATH"
staple_item "$DMG_PATH"
check_dmg "$DMG_PATH"
check_app "$NOTARIZED_APP_PATH"
check_staple "$DMG_PATH"
check_staple "$NOTARIZED_APP_PATH"
dist_dmg
clean_up
