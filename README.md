# Jatayu Media Player package repositories

This public repository will host **signed APT** and **Flatpak OSTree** update repositories. **Status: not yet deployed or tested remotely.**

Application source and GitHub Releases: https://github.com/jatayuos4u/jatayu-media-player

Public website: https://jatayuos.in (unchanged).

## GitHub Pages setup
In this repository open **Settings → Pages → Build and deployment → Deploy from a branch → main → /(root) → Save**. Verify the URL GitHub provides. The expected project URL is https://jatayuos4u.github.io/jatayu-packages/ but it is not confirmed live.

The project Pages site must serve these files after staging:
- `apt/dists/stable/InRelease` and the complete `apt/pool/` tree
- `apt/jatayu-media-player-archive-key.asc` (public GPG key only)
- `flatpak/summary`, `flatpak/summary.sig`, `flatpak/config`, refs and every OSTree object
- `flatpak-repository-key.asc` (public GPG key only)

## Stage locally — never upload secret keys

After final builds and repository signing on your laptop:

```bash
git clone https://github.com/jatayuos4u/jatayu-packages.git ~/jatayu-packages
bash ~/jatayu-packages/scripts/stage-local-repositories.sh ~/jatayu-media-player/dist ~/jatayu-packages
cd ~/jatayu-packages
git status --short
git diff --stat
```

The script stages public files but does **not** commit, push, configure Pages, or deploy. Review staged files before publishing.

## Required checks before public launch

- Verify the downloaded APT InRelease signature and package hash from a clean client.
- Verify Flatpak remote registration using the published GPG key and a fresh install over HTTPS.
- Publish and test an actual version-to-version upgrade before promising automatic updates.
- Verify GitHub Pages can serve the complete OSTree object tree and stays within its hosting/bandwidth limits.
- Keep the source repository, license notices, checksums and signing key fingerprint available to users.

**Do not store private keys in this repository.** The maintainer-supplied public key fingerprint is `FCAD173B005222F8DCB16C691002D7BA2CD8EB09`. Verify independently before trusting it.

GitHub Pages is subject to hosting limits and is not an unlimited package CDN. For initial manual downloads GitHub Releases can host the independently verified .deb and .flatpak binaries; GitHub Releases alone does not make package-manager auto-updates work.
