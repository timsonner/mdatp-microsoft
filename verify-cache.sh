#!/usr/bin/env bash
# Verify primed Microsoft .deb against pinned PKGBUILD sha256 (+ optional index excerpt).
set -euo pipefail
cd "$(dirname "$0")"
ver=$(awk -F= '/^pkgver=/{print $2; exit}' PKGBUILD)
deb_hash=$(awk '/^sha256sums=/{getline; gsub(/['\'' ]/,""); print; exit}' PKGBUILD)
file="cache/mdatp_${ver}_amd64.deb"
[[ -f "$file" ]] || { echo "Missing $file — run ./prime-cache.sh"; exit 1; }
got=$(sha256sum "$file" | awk '{print $1}')
echo "pkgver=$ver"
echo "expected=$deb_hash"
echo "got     =$got"
[[ "$got" == "$deb_hash" ]] || { echo "FAIL"; exit 1; }
echo "OK cache matches PKGBUILD pin"
if [[ -f "cache/Packages-mdatp-${ver}.txt" ]]; then
  idx=$(awk '/^SHA256:/{print $2; exit}' "cache/Packages-mdatp-${ver}.txt")
  echo "index   =$idx"
  [[ "$idx" == "$deb_hash" ]] || { echo "WARN: Packages excerpt SHA differs from PKGBUILD"; exit 1; }
  echo "OK Packages excerpt matches"
fi
