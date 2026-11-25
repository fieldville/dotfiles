#!/usr/bin/env bash
#
# Set up Apple-platform (macOS / iOS / iPadOS) development on this Mac, then build the
# sample app in HelloApple/ for all three as a check. Safe to rerun: every step is skipped
# when already done.
#
#   ./setup.bash            install everything, then build the sample
#   ./setup.bash --no-build install only
#
# Needs: Homebrew, and the App Store signed in (Xcode comes from there via mas).
# sudo is asked for once (mas, xcode-select, licence, first-launch packages).

set -euo pipefail
cd "$(dirname "$0")"

XCODE_APP=/Applications/Xcode.app
XCODE_APP_ID=497799835          # Xcode on the Mac App Store
BREW_TOOLS=(mas xcodegen)       # mas: App Store CLI, xcodegen: project.yml -> .xcodeproj

build=1
[[ ${1:-} == --no-build ]] && build=0

step() { printf '\n==> %s\n' "$*"; }
die()  { echo "error: $*" >&2; exit 1; }

[[ $(uname -s) == Darwin ]] || die "macOS only"
command -v brew >/dev/null || die "Homebrew is required: https://brew.sh"

step "Homebrew tools: ${BREW_TOOLS[*]}"
for f in "${BREW_TOOLS[@]}"; do
  if brew list --formula "$f" >/dev/null 2>&1; then echo "  $f: already installed"
  else brew install "$f"
  fi
done

step "Xcode"
if [[ -d $XCODE_APP ]]; then
  echo "  already installed: $XCODE_APP"
else
  echo "  installing from the App Store (several GB, takes a while)"
  # `get` also works for an Apple Account that has never downloaded Xcode before.
  if ! sudo mas get "$XCODE_APP_ID"; then
    # mas cannot answer the App Store's own sign-in / password prompt (ISErrorDomain 4).
    # Hand over to App Store.app and wait for the install to land.
    echo "  mas failed; opening the App Store page. Click Get / Install there (sign in if asked)."
    open "macappstore://apps.apple.com/app/id$XCODE_APP_ID"
    printf '  waiting for %s ' "$XCODE_APP"
    until [[ -x $XCODE_APP/Contents/Developer/usr/bin/xcodebuild ]]; do
      printf .; sleep 15
    done
    echo " installed"
  fi
  [[ -d $XCODE_APP ]] || die "$XCODE_APP is still missing"
fi

step "Active developer directory"
want=$XCODE_APP/Contents/Developer
if [[ $(xcode-select -p 2>/dev/null) == "$want" ]]; then
  echo "  already $want"
else
  sudo xcode-select -s "$want" && echo "  set to $want"
fi

step "Xcode licence and first-launch packages"
if xcodebuild -checkFirstLaunchStatus >/dev/null 2>&1; then
  echo "  already done"
else
  sudo xcodebuild -license accept
  sudo xcodebuild -runFirstLaunch
fi
xcodebuild -version | sed 's/^/  /'

# The iOS platform (SDK + simulator runtime) is a separate download; iPad simulators use
# the same runtime. macOS needs nothing extra.
step "iOS platform (covers iPadOS)"
if xcrun simctl list runtimes 2>/dev/null | grep -q '^iOS '; then
  xcrun simctl list runtimes | grep '^iOS ' | sed 's/^/  already installed: /'
else
  xcodebuild -downloadPlatform iOS
fi

if (( build )); then
  step "Build check: HelloApple"
  ./HelloApple/build.bash
fi

step "Done"
echo "  open the sample in Xcode:  ./HelloApple/build.bash open"
