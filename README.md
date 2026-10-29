# mdatp-microsoft (Omarchy / Arch fleet)

Local, **Microsoft-only** packaging of Defender for Endpoint for Omarchy hosts.
No AUR in the trust chain. Debian **12 prod** channel (stable).

> Status: **primed, not installed.** Licensing + onboarding package are owned by Tim (portal). Do not `enable --now` until onboarding bits are in place.

## Trust model

| Layer | Who |
| --- | --- |
| Agent binary | Microsoft (`packages.microsoft.com`, Debian 12 prod `.deb`) |
| Integrity | SHA256 from Microsoft `Packages` index; re-checked by `prime-cache.sh` / `verify-cache.sh` |
| Packaging glue | This repo (fleet-owned PKGBUILD) |
| License / org onboarding | Defender portal (Tim) → `cache/onboarding/` |

Do **not** install `mdatp-bin` from the AUR on fleet hosts.

## What’s primed on a gold host

```text
~/Projects/mdatp-microsoft/
  PKGBUILD                 # pinned version + sha256
  mdatp.install            # sysusers + daemon-reload hooks
  mdatp-sysusers.conf
  makepkg.local.conf       # SRCDEST=./cache (offline-friendly)
  prime-cache.sh           # fetch+verify deb into cache/
  verify-cache.sh
  bump-from-microsoft.sh   # optional version bump from MS index
  docs/FLEET.md            # replicate across Omarchy systems
  cache/
    mdatp_<ver>_amd64.deb  # verified Microsoft package (~162M)
    Packages-mdatp-<ver>.txt
    onboarding/            # you drop portal script here later
```

## One-host build (when ready — not yet)

```bash
cd ~/Projects/mdatp-microsoft
./verify-cache.sh
makepkg --config ./makepkg.local.conf -s   # builds package; review before -i
# sudo pacman -U out/mdatp-microsoft-*.pkg.tar.zst
# sudo systemctl enable --now mdatp   # only after onboarding file exists
```

## Your remaining Microsoft steps

1. Defender portal → Settings → Endpoints → Onboarding  
2. OS: **Linux Server**, method: **Local Script**  
3. Download zip → extract `MicrosoftDefenderATPOnboardingLinuxServer.py`  
4. Place it in `cache/onboarding/` on the gold host (and/or your secret store)  
5. Then install + `sudo python3 cache/onboarding/MicrosoftDefenderATPOnboardingLinuxServer.py`  
6. `mdatp health`

See [docs/FLEET.md](docs/FLEET.md) for multi-host replication.
