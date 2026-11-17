#!/bin/bash
#
# find_browser_extensions.sh
#
# Finds the install directories of these browser extensions on macOS:
#   - Metamask
#   - Grammarly
#   - Adblock Plus
#   - Google Translate
#
# Browsers scanned (every profile):
#   - Google Chrome (Stable / Beta / Dev / Canary)
#   - Brave (Stable / Beta / Nightly)
#   - Microsoft Edge (Stable / Beta / Dev / Canary)
#   - Mozilla Firefox (plus LibreWolf / Waterfox if present)
#
# Matches by known extension ID first, then by the extension's real name read
# from its manifest (so store variants / forks are found too).
#
# Usage:
#   chmod +x find_browser_extensions.sh
#   ./find_browser_extensions.sh
#
# Compatible with the stock macOS /bin/bash (3.2).

shopt -s nullglob

APP_SUPPORT="${APP_SUPPORT:-$HOME/Library/Application Support}"
RESULTS="$(mktemp "${TMPDIR:-/tmp}/browser_ext.XXXXXX")"
trap 'rm -f "$RESULTS"' EXIT

# ---------------------------------------------------------------------------
# Known extension IDs  (Label|ID) 
# three IDs are the Chrome Web Store, Edge Add-ons and Firefox versions
# ---------------------------------------------------------------------------
TARGET_IDS="
Metamask|nkbihfbeogaeaoehlefnkodbefgpgknn
Metamask|odfafepnkmbhccpbejgmiehpchacaeak
Metamask|uBlock0@raymondhill.net
Grammarly|kbfnbcaeplbcioakkpcpgfkobkghlhen
Grammarly|cnlefmmeadmemmdciolhbnfeacpdfbkd
Grammarly|87677a2c52b84ad3a151a4a72f5bd3c4@jetpack
Adblock Plus|cfhdojbkjhnklbpkdaibdccddilifddb
Adblock Plus|gmgoamodcdcjnbaobigkjelfplakmdhh
Adblock Plus|{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}
Google Translate|aapbdbdomjkkjkaonfhkkikfgjllcleb
"

label_for_id() {
    printf '%s\n' "$TARGET_IDS" | awk -F'|' -v id="$1" '$2 == id { print $1; exit }'
}

label_for_name() {
    local n
    n="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
    case "$n" in
        *"Metamask"*)    echo "Metamask" ;;
        *grammarly*)          echo "Grammarly" ;;
        *"adblock plus"*)     echo "Adblock Plus" ;;
        *"google translat"*)  echo "Google Translate" ;;
    esac
}

# ---------------------------------------------------------------------------
# Minimal JSON helpers (no python / jq dependency)
# ---------------------------------------------------------------------------

# json_string <json-text> <key>  -> first string value of "key"
json_string() {
    printf '%s' "$1" | tr '\r\n' '  ' | awk -v k="$2" '{
        if (match($0, "\"" k "\"[ \t]*:[ \t]*\"[^\"]*\"")) {
            s = substr($0, RSTART, RLENGTH)
            sub(/^"[^"]*"[ \t]*:[ \t]*"/, "", s); sub(/"$/, "", s)
            print s
        }
    }'
}

# msg_lookup <messages.json-text> <key>  -> "message" value (key is case-insensitive)
msg_lookup() {
    printf '%s' "$1" | tr '\r\n' '  ' | awk -v k="$2" '{
        i = index(tolower($0), "\"" tolower(k) "\"")
        if (i) {
            rest = substr($0, i)
            if (match(rest, /"message"[ \t]*:[ \t]*"[^"]*"/)) {
                s = substr(rest, RSTART, RLENGTH)
                sub(/^"message"[ \t]*:[ \t]*"/, "", s); sub(/"$/, "", s)
                print s
            }
        }
    }'
}

read_dir_file() { cat "$1/$2" 2>/dev/null; }
read_xpi_file() { unzip -p "$1" "$2" 2>/dev/null; }

# resolve_name <manifest-text> <reader-fn> <base>  -> human readable extension name
resolve_name() {
    local manifest="$1" reader="$2" base="$3" name key loc msgs val
    name="$(json_string "$manifest" name)"
    case "$name" in
        __MSG_*__)
            key="${name#__MSG_}"; key="${key%__}"
            for loc in "$(json_string "$manifest" default_locale)" en en_US en_GB; do
                [ -n "$loc" ] || continue
                msgs="$("$reader" "$base" "_locales/$loc/messages.json")"
                [ -n "$msgs" ] || continue
                val="$(msg_lookup "$msgs" "$key")"
                if [ -n "$val" ]; then echo "$val"; return; fi
            done
            ;;
    esac
    echo "$name"
}

# Chromium profile display name from "Local State"
chromium_profile_name() {
    local state="$1/Local State" folder="$2"
    [ -f "$state" ] || return
    tr '\r\n' '  ' < "$state" | awk -v p="$folder" '{
        i = index($0, "\"info_cache\"");  if (!i) exit
        rest = substr($0, i)
        j = index(rest, "\"" p "\":{");   if (!j) exit
        rest = substr(rest, j + length(p) + 3)
        if (match(rest, /"name"[ \t]*:[ \t]*"[^"]*"/)) {
            s = substr(rest, RSTART, RLENGTH)
            sub(/^"name"[ \t]*:[ \t]*"/, "", s); sub(/"$/, "", s)
            print s
        }
    }'
}

# record <browser> <profile> <label> <real-name> <id> <ext-dir> <data-dir>
record() {
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$@" >> "$RESULTS"
}

# ---------------------------------------------------------------------------
# Chromium based browsers (Chrome / Brave / Edge)
# ---------------------------------------------------------------------------
scan_chromium() {
    local browser="$1" root="$2"
    [ -d "$root" ] || return
    echo "Scanning $browser ..." >&2

    local extroot profile_dir folder pname extdir id label verdir v realname data
    for extroot in "$root"/*/Extensions; do
        [ -d "$extroot" ] || continue
        profile_dir="$(dirname "$extroot")"
        folder="$(basename "$profile_dir")"
        pname="$(chromium_profile_name "$root" "$folder")"
        [ -n "$pname" ] && folder="$folder ($pname)"

        for extdir in "$extroot"/*; do
            [ -d "$extdir" ] || continue
            id="$(basename "$extdir")"
            [ "$id" = "Temp" ] && continue

            verdir=""
            for v in "$extdir"/*/; do verdir="${v%/}"; done   # newest version dir

            realname=""
            if [ -n "$verdir" ] && [ -f "$verdir/manifest.json" ]; then
                realname="$(resolve_name "$(cat "$verdir/manifest.json")" read_dir_file "$verdir")"
            fi

            label="$(label_for_id "$id")"
            [ -z "$label" ] && label="$(label_for_name "$realname")"
            [ -z "$label" ] && continue

            data=""
            [ -d "$profile_dir/Local Extension Settings/$id" ] && data="$profile_dir/Local Extension Settings/$id"

            record "$browser" "$folder" "$label" "${realname:-?}" "$id" "$extdir" "$data"
        done
    done
}

# ---------------------------------------------------------------------------
# Mozilla based browsers (Firefox / LibreWolf / Waterfox)
# ---------------------------------------------------------------------------
firefox_uuid() {
    local prefs="$1/prefs.js" id="$2"
    [ -f "$prefs" ] || return
    grep 'extensions.webextensions.uuids' "$prefs" | sed 's/\\"/"/g' | awk -v id="$id" '{
        key = "\"" id "\":\""
        i = index($0, key)
        if (i) { s = substr($0, i + length(key)); sub(/".*/, "", s); print s }
    }'
}

scan_firefox() {
    local browser="$1" root="$2"
    [ -d "$root" ] || return
    echo "Scanning $browser ..." >&2

    local prof folder item base id label realname manifest uuid data d
    for prof in "$root"/*/; do
        prof="${prof%/}"
        [ -d "$prof/extensions" ] || continue
        folder="$(basename "$prof")"

        for item in "$prof/extensions"/*; do
            base="$(basename "$item")"
            id="${base%.xpi}"
            realname=""

            if [ -f "$item" ] && [ "${base##*.}" = "xpi" ]; then
                manifest="$(unzip -p "$item" manifest.json 2>/dev/null)"
                [ -n "$manifest" ] && realname="$(resolve_name "$manifest" read_xpi_file "$item")"
            elif [ -d "$item" ] && [ -f "$item/manifest.json" ]; then
                realname="$(resolve_name "$(cat "$item/manifest.json")" read_dir_file "$item")"
            else
                continue
            fi

            label="$(label_for_id "$id")"
            [ -z "$label" ] && label="$(label_for_name "$realname")"
            [ -z "$label" ] && continue

            data=""
            uuid="$(firefox_uuid "$prof" "$id")"
            if [ -n "$uuid" ]; then
                for d in "$prof/storage/default/moz-extension+++$uuid"*; do data="$d"; break; done
            fi

            record "$browser" "$folder" "$label" "${realname:-?}" "$id" "$item" "$data"
        done
    done
}

# ---------------------------------------------------------------------------
# Run scans
# ---------------------------------------------------------------------------
scan_chromium "Google Chrome"          "$APP_SUPPORT/Google/Chrome"
scan_chromium "Google Chrome Beta"     "$APP_SUPPORT/Google/Chrome Beta"
scan_chromium "Google Chrome Dev"      "$APP_SUPPORT/Google/Chrome Dev"
scan_chromium "Google Chrome Canary"   "$APP_SUPPORT/Google/Chrome Canary"
scan_chromium "Brave"                  "$APP_SUPPORT/BraveSoftware/Brave-Browser"
scan_chromium "Brave Beta"             "$APP_SUPPORT/BraveSoftware/Brave-Browser-Beta"
scan_chromium "Brave Nightly"          "$APP_SUPPORT/BraveSoftware/Brave-Browser-Nightly"
scan_chromium "Microsoft Edge"         "$APP_SUPPORT/Microsoft Edge"
scan_chromium "Microsoft Edge Beta"    "$APP_SUPPORT/Microsoft Edge Beta"
scan_chromium "Microsoft Edge Dev"     "$APP_SUPPORT/Microsoft Edge Dev"
scan_chromium "Microsoft Edge Canary"  "$APP_SUPPORT/Microsoft Edge Canary"
scan_firefox  "Mozilla Firefox"        "$APP_SUPPORT/Firefox/Profiles"
scan_firefox  "LibreWolf"              "$APP_SUPPORT/librewolf/Profiles"
scan_firefox  "Waterfox"               "$APP_SUPPORT/Waterfox/Profiles"

# ---------------------------------------------------------------------------
# Print results (after all scanning is finished)
# ---------------------------------------------------------------------------
echo
echo "=================================================================="
echo " Browser extension directories"
echo "=================================================================="

total=0
last_group=""
while IFS=$'\t' read -r browser profile label realname id extdir data; do
    group="$browser | Profile: $profile"
    if [ "$group" != "$last_group" ]; then
        echo
        echo "[$browser]  Profile: $profile"
        last_group="$group"
    fi
    echo "  - $label   (name: $realname, id: $id)"
    echo "      Extension: $extdir"
    [ -n "$data" ] && echo "      Data:      $data"
    total=$((total + 1))
done < "$RESULTS"

echo
if [ "$total" -eq 0 ]; then
    echo "No matching extensions found."
else
    echo "Total found: $total"
fi
