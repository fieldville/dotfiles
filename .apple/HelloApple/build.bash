#!/usr/bin/env bash
#
# Generate HelloApple.xcodeproj from project.yml and build it for macOS, iOS and iPadOS.
#
#   ./build.bash                build all three
#   ./build.bash macos|ios|ipados   build one
#   ./build.bash open           generate the project and open it in Xcode

set -euo pipefail
cd "$(dirname "$0")"

SCHEME=HelloApple
DERIVED=.build                  # git-ignored

# UDID of the first available simulator whose name starts with $1 (iPhone / iPad).
sim_udid() {
  xcrun simctl list devices available |
    sed -nE "s/^ +$1.*\(([0-9A-F-]{36})\).*/\1/p" | head -1   # names may hold "(M5)"
}

destination() {
  local udid
  case $1 in
    macos)  echo "platform=macOS,arch=$(uname -m)"; return ;;
    ios)    udid=$(sim_udid iPhone) ;;
    ipados) udid=$(sim_udid iPad) ;;
    *)      echo "unknown target: $1 (macos | ios | ipados)" >&2; return 1 ;;
  esac
  [[ -n $udid ]] || { echo "no simulator for $1; run ../setup.bash" >&2; return 1; }
  echo "platform=iOS Simulator,id=$udid"
}

xcodegen generate --quiet

if [[ ${1:-} == open ]]; then
  exec open "$SCHEME.xcodeproj"
fi

targets=("$@")
(( ${#targets[@]} )) || targets=(macos ios ipados)

failed=()
for t in "${targets[@]}"; do
  dest=$(destination "$t") || { failed+=("$t"); continue; }
  echo "--- $t  ($dest)"
  if xcodebuild -project "$SCHEME.xcodeproj" -scheme "$SCHEME" -configuration Debug \
       -destination "$dest" -derivedDataPath "$DERIVED" -quiet build; then
    echo "    BUILD OK: $t"
  else
    echo "    BUILD FAILED: $t"; failed+=("$t")
  fi
done

if (( ${#failed[@]} )); then
  echo "failed: ${failed[*]}" >&2
  exit 1
fi
echo "all builds OK: ${targets[*]}"
