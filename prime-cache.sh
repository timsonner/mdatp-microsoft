#!/usr/bin/env bash
# Download the PKGBUILD-pinned Microsoft .deb into ./cache and save a Packages excerpt.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p cache
ver=$(awk -F= '/^pkgver=/{print $2; exit}' PKGBUILD)
deb_hash=$(awk '/^sha256sums=/{getline; gsub(/['\'' ]/,""); print; exit}' PKGBUILD)
url="https://packages.microsoft.com/debian/12/prod/pool/main/m/mdatp/mdatp_${ver}_amd64.deb"
dest="cache/mdatp_${ver}_amd64.deb"

echo "Fetching $url"
curl -fsSL -o "${dest}.partial" "$url"
mv "${dest}.partial" "$dest"
got=$(sha256sum "$dest" | awk '{print $1}')
if [[ "$got" != "$deb_hash" ]]; then
  echo "SHA mismatch: got $got want $deb_hash" >&2
  rm -f "$dest"
  exit 1
fi

curl -fsSL "https://packages.microsoft.com/debian/12/prod/dists/bookworm/main/binary-amd64/Packages.gz" \
  | gzip -dc | awk -v v="$ver" '
    /^Package: mdatp$/{p=1; buf=""}
    p { buf=buf $0 "\n" }
    p && /^$/ {
      if (index(buf, "Version: " v "\n")) print buf
      p=0
    }
  ' > "cache/Packages-mdatp-${ver}.txt"

./verify-cache.sh
echo "Primed $dest ($(du -h "$dest" | awk '{print $1}'))"
