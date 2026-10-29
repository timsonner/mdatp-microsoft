# cache/

| Path | Purpose |
| --- | --- |
| `mdatp_<ver>_amd64.deb` | Official Microsoft Debian 12 prod package (verified SHA256) |
| `Packages-mdatp-<ver>.txt` | Excerpt from Microsoft `Packages` index used for that pin |
| `onboarding/` | **You** place Defender portal artifacts here (not committed secrets). Expected: `MicrosoftDefenderATPOnboardingLinuxServer.py` after unzipping the portal package |

Do not put AUR packages here. Deb must come from `packages.microsoft.com` or an internal mirror of that exact file + hash.
