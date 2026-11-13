# mdatp-microsoft

Local packaging of Microsoft Defender for Endpoint for Omarchy and other Arch-like hosts. `PKGBUILD` pins the Debian 12 prod `.deb` from `packages.microsoft.com` (version and SHA256); `prime-cache.sh` and `verify-cache.sh` check that file, and `makepkg` repackages it as `mdatp-microsoft`. `PKGBUILD` conflicts with `mdatp` and AUR `mdatp-bin`; do not install `mdatp-bin` on fleet hosts. Arch and Omarchy are outside Microsoft’s supported Linux list; replication notes are in [docs/FLEET.md](docs/FLEET.md).

## Prerequisites

- x86_64
- Arch or Omarchy with `base-devel` (`makepkg` and `pacman`) to build and install
- `bash`, `curl`, `gzip`, `awk`, and `sha256sum` for the cache scripts
- `systemd` and `iptables` (declared in `PKGBUILD` `depends`)
- HTTPS access to `packages.microsoft.com` for `./prime-cache.sh` and `./bump-from-microsoft.sh`
- `python3` to run the Defender portal onboarding script after install

Git ignores `cache/*.deb`. Add the portal onboarding script under `cache/onboarding/` on the host; that directory is gitignored except for `.gitkeep`.

## Install, build, and check

From the repository root:

```bash
./prime-cache.sh
./verify-cache.sh
makepkg --config ./makepkg.local.conf -s
sudo pacman -U out/mdatp-microsoft-*.pkg.tar.zst
```

`./prime-cache.sh` downloads `cache/mdatp_<pkgver>_amd64.deb`, requires the SHA256 in `PKGBUILD`, and writes `cache/Packages-mdatp-<pkgver>.txt`. `./verify-cache.sh` repeats those checks and exits non-zero on mismatch. `makepkg.local.conf` sets `PKGDEST` to `out/`, so the built archive is `out/mdatp-microsoft-<pkgver>-<pkgrel>-x86_64.pkg.tar.zst`. The pin in `PKGBUILD` is `101.26091.0004` (`pkgrel` 1).

## Usage

Download the Defender portal package for **Linux Server** / **Local Script**, and place `MicrosoftDefenderATPOnboardingLinuxServer.py` in `cache/onboarding/`. Then:

```bash
sudo systemctl enable --now mdatp
sudo python3 cache/onboarding/MicrosoftDefenderATPOnboardingLinuxServer.py
mdatp health
```

The package links `/usr/bin/mdatp` to `/opt/microsoft/mdatp/sbin/wdavdaemonclient`. `mdatp.install` runs `systemd-sysusers` and `systemctl daemon-reload` after install, and `systemctl try-restart mdatp.service` after upgrade.

To move the pin to the newest Debian 12 prod `mdatp` and re-download it:

```bash
./bump-from-microsoft.sh
```

Review the `PKGBUILD` diff before installing that build. Copying a primed tree, health fields, and rollback are in [docs/FLEET.md](docs/FLEET.md).

## Layout

| Path | Role |
| --- | --- |
| `PKGBUILD` | Pinned version, SHA256, and package steps |
| `mdatp.install` | sysusers, daemon-reload, and upgrade restart hooks |
| `mdatp-sysusers.conf` | `mdatp` system user |
| `makepkg.local.conf` | Build dirs: `cache/`, `out/`, `build/`, `logs/` |
| `prime-cache.sh` | Download and hash-check the `.deb` |
| `verify-cache.sh` | Re-check the cached `.deb` and Packages excerpt |
| `bump-from-microsoft.sh` | Update `pkgver` and checksums from the Microsoft index |
| `cache/` | Local `.deb`, index excerpt, and onboarding drop folder |
| `docs/FLEET.md` | Fleet replication notes |

## License

The agent is Microsoft’s commercial package (`license=('custom: commercial')` in `PKGBUILD`). This repo has no `LICENSE` file of its own. Upstream manual install notes: <https://learn.microsoft.com/en-us/defender-endpoint/linux-install-manually>.
