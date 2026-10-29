# Fleet replication — Microsoft Defender on Omarchy

Goal: same agent bits on many Omarchy (`ID_LIKE=arch`) systems without the AUR, using Debian 12 **prod** from Microsoft.

## Constraints (read once)

- **Unsupported** by Microsoft on Arch/Omarchy. Agent may run; support expects a listed distro if you open a ticket.
- Custom kernels (e.g. T2) raise breakage risk on kernel bumps — re-verify `mdatp health` after upgrades.
- Requires **x86_64**, **systemd**, **iptables** (or nft iptables compat), network to Defender cloud after onboard.
- Without the portal onboarding script, the product stays unlicensed (`mdatp health` → not healthy / empty org).

## Gold-host prep (done / owned here)

Built artifact (no install yet): `out/mdatp-microsoft-<ver>-x86_64.pkg.tar.zst` from `makepkg --config ./makepkg.local.conf -s`.


1. Clone or copy this `mdatp-microsoft` tree to `~/Projects/mdatp-microsoft` (or a shared path).
2. `./prime-cache.sh` — downloads Microsoft `.deb`, verifies SHA256, stores Packages excerpt.
3. `./verify-cache.sh` — must print OK.
4. Tim places onboarding script under `cache/onboarding/` when licensing is ready.
5. **Do not** install on gold until Tim says go.

## Replicate to another Omarchy host

### Option A — copy the primed tree (airgap-friendly)

From gold host (after verify):

```bash
# example: rsync package repo + cached deb (exclude build junk)
rsync -a --delete \
  --exclude build/ --exclude out/ --exclude logs/ --exclude src/ --exclude pkg/ \
  ~/Projects/mdatp-microsoft/ user@target:~/Projects/mdatp-microsoft/
```

On target:

```bash
cd ~/Projects/mdatp-microsoft
./verify-cache.sh
# STOP if onboarding file missing and this host must join the tenant
makepkg --config ./makepkg.local.conf -si
sudo systemctl enable --now mdatp
sudo python3 cache/onboarding/MicrosoftDefenderATPOnboardingLinuxServer.py
mdatp health --field healthy
mdatp health --field org_id
```

### Option B — pull Microsoft on each host

```bash
cd ~/Projects/mdatp-microsoft   # sync git/docs only; no huge deb
./prime-cache.sh               # needs packages.microsoft.com
./verify-cache.sh
makepkg --config ./makepkg.local.conf -si
# onboard as above
```

Prefer **A** for identical bytes and less reliance on each laptop’s network at install time. Prefer **B** if you only distribute the small git tree and trust Microsoft CDN per host.

### Option C — internal mirror

Host the exact `mdatp_<ver>_amd64.deb` + published SHA256 on an internal HTTPS mirror. Point `PKGBUILD` `source=` at that URL **only if** the file hash still matches Microsoft’s. Document the mirror URL in your ops notes; keep `bump-from-microsoft.sh` as the way to learn new upstream versions.

## Version bumps (fleet-wide)

1. On gold: `./bump-from-microsoft.sh` (or edit `pkgver` + sha intentionally).
2. Review `git diff PKGBUILD`.
3. `./verify-cache.sh`.
4. Roll out new tree / new `.pkg.tar.zst` to hosts; upgrade with `pacman -U` or `makepkg -si`.
5. `systemctl try-restart mdatp` (install hook does this on upgrade).
6. Spot-check `mdatp health` on a canary host before full fleet.

## Install checklist (per host)

- [ ] Omarchy/Arch x86_64, systemd running  
- [ ] `iptables` present (`pacman -Q iptables` or `iptables-nft`)  
- [ ] `./verify-cache.sh` OK  
- [ ] Onboarding `.py` present (Tim)  
- [ ] `makepkg --config ./makepkg.local.conf -si`  
- [ ] `systemctl enable --now mdatp`  
- [ ] Run onboarding script once  
- [ ] `mdatp health --field healthy` → `true` (definitions may lag a few minutes)  
- [ ] Host appears in Defender portal (can take up to ~20 minutes first time)

## Explicit non-goals

- Do not `yay -S mdatp-bin` / AUR.  
- Do not re-sign or re-pack Microsoft’s binaries beyond extracting the official `.deb`.  
- Do not commit the onboarding script or tenant secrets to a public repo.  
- Do not switch channels (insiders-fast/slow) on fleet without a deliberate bump + canary.

## Rollback

```bash
sudo systemctl disable --now mdatp
sudo pacman -Rns mdatp-microsoft
# leftover state if needed:
# sudo rm -rf /var/opt/microsoft/mdatp /var/log/microsoft/mdatp
```

## References

- [Manual deploy](https://learn.microsoft.com/en-us/defender-endpoint/linux-install-manually)  
- [Prerequisites / supported distros](https://learn.microsoft.com/en-us/defender-endpoint/mde-linux-prerequisites)  
- Microsoft prod pool used here: `https://packages.microsoft.com/debian/12/prod/`

## Current gold-host state (MBA91-OMARCY)

As of priming:

- Channel: Debian 12 prod
- Pinned version: `101.26091.0004`
- Cache deb verified against Microsoft Packages SHA256
- Built package: `out/mdatp-microsoft-101.26091.0004-1-x86_64.pkg.tar.zst` (**not** installed)
- Onboarding: waiting on Tim (`cache/onboarding/` empty except `.gitkeep`)
- Service: not enabled
