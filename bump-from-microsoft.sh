#!/usr/bin/env bash
# Bump PKGBUILD to newest mdatp on packages.microsoft.com (Debian 12 prod).
# Then re-prime ./cache. Trust: Microsoft index + download SHA only. No AUR.
set -euo pipefail
cd "$(dirname "$0")"

INDEX_URL='https://packages.microsoft.com/debian/12/prod/dists/bookworm/main/binary-amd64/Packages.gz'
BASE='https://packages.microsoft.com/debian/12/prod'

line=$(
  curl -fsSL "$INDEX_URL" | gzip -dc | awk '
    /^Package: mdatp$/{p=1; ver=""; file=""; sha=""; next}
    p && /^Version:/{ver=$2}
    p && /^Filename:/{file=$2}
    p && /^SHA256:/{sha=$2}
    p && /^$/{
      if (ver != "") printf "%s\t%s\t%s\n", ver, sha, file
      p=0
    }
  ' | sort -V | tail -1
)

IFS=$'\t' read -r ver sha file <<<"$line"
[[ -n "${ver:-}" && -n "${sha:-}" && -n "${file:-}" ]] || {
  echo "Could not parse Microsoft Packages index" >&2
  exit 1
}

echo "Newest on Microsoft index: $ver"
echo "SHA256 (index): $sha"

sys_hash=$(sha256sum mdatp-sysusers.conf | awk '{print $1}')
sed -i "s/^pkgver=.*/pkgver=${ver}/" PKGBUILD
awk -v deb="$sha" -v sys="$sys_hash" '
  BEGIN { insums=0 }
  /^sha256sums=\(/ {
    print "sha256sums=("
    print "  '\''" deb "'\''"
    print "  '\''" sys "'\''"
    print ")"
    insums=1
    next
  }
  insums && /^\)/ { insums=0; next }
  insums { next }
  { print }
' PKGBUILD > PKGBUILD.tmp && mv PKGBUILD.tmp PKGBUILD

./prime-cache.sh
echo "PKGBUILD + cache now at ${ver}. Review diff before fleet rollout."
