# Maintainer: Tim Sonner (local fleet package — Microsoft-only, not from AUR)
#
# Trust chain:
#   1. Binary from packages.microsoft.com (Debian 12 / bookworm prod)
#   2. SHA256 must match Microsoft's Packages index (see cache/ + bump-from-microsoft.sh)
#   3. This PKGBUILD (you own / review it) — no AUR maintainer in the path
#
# Channel choice: Debian 12 prod. Ubuntu 22.04/24.04 ship the same .deb bytes for
# this version; Fedora/RHEL would be RPM and a worse Arch fit.

pkgname=mdatp-microsoft
_debname=mdatp
pkgver=101.26091.0004
pkgrel=1
pkgdesc='Microsoft Defender for Endpoint (official Debian 12 prod package, locally repackaged)'
arch=('x86_64')
url='https://learn.microsoft.com/en-us/defender-endpoint/linux-install-manually'
license=('custom: commercial')
depends=('systemd' 'iptables')
provides=("mdatp=${pkgver}")
conflicts=('mdatp' 'mdatp-bin')
install=mdatp.install
options=('!strip')

_ms_base='https://packages.microsoft.com/debian/12/prod'
source=(
  "${_debname}_${pkgver}_amd64.deb::${_ms_base}/pool/main/m/${_debname}/${_debname}_${pkgver}_amd64.deb"
  'mdatp-sysusers.conf'
)
sha256sums=(
  'e482ac94eafc88ad7e26d99cbec71893f19aaa235cddc28e4b2fa54c0644fc3b'
  '907153bbdeaf8168cfe94b4b9724cb2d34aa0b2bbd77a39be334dbcb03573539'
)

prepare() {
  cd "${srcdir}"
  ar x "${_debname}_${pkgver}_amd64.deb"
  if [[ -f data.tar.gz ]]; then
    tar -xzf data.tar.gz
  elif [[ -f data.tar.xz ]]; then
    tar -xJf data.tar.xz
  elif [[ -f data.tar.zst ]]; then
    tar --zstd -xf data.tar.zst
  else
    echo "No data.tar.* in deb" >&2
    return 1
  fi
}

package() {
  install -d "${pkgdir}/opt/microsoft/${_debname}"
  install -d "${pkgdir}/var/opt/microsoft"
  install -d "${pkgdir}/var/log/microsoft"
  install -d "${pkgdir}/etc/systemd/system"
  install -d "${pkgdir}/usr/bin"

  install -Dm644 "${srcdir}/mdatp-sysusers.conf" \
    "${pkgdir}/usr/lib/sysusers.d/mdatp.conf"

  cp -a "${srcdir}/opt/microsoft/${_debname}/." \
    "${pkgdir}/opt/microsoft/${_debname}/"

  install -Dm644 "${srcdir}/opt/microsoft/${_debname}/conf/mdatp.service" \
    "${pkgdir}/etc/systemd/system/mdatp.service"

  ln -sf /opt/microsoft/mdatp/sbin/wdavdaemonclient "${pkgdir}/usr/bin/mdatp"

  if [[ -f "${srcdir}/opt/microsoft/${_debname}/LICENSE" ]]; then
    install -Dm644 "${srcdir}/opt/microsoft/${_debname}/LICENSE" \
      "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
  fi
}
