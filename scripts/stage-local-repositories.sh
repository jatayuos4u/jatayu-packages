#!/usr/bin/env bash
set -euo pipefail
if (( $# != 2 )); then
  echo "Usage: bash scripts/stage-local-repositories.sh <player-dist-dir> <jatayu-packages-clone-dir>" >&2
  exit 2
fi
SRC=$(realpath "$1")
DST=$(realpath "$2")
[[ -d "$DST/.git" ]] || { echo "Target must be a Git clone" >&2; exit 1; }
[[ "$(git -C "$DST" remote get-url origin)" == *"jatayuos4u/jatayu-packages"* ]] || {
  echo "Target is not jatayuos4u/jatayu-packages" >&2; exit 1;
}
for p in "$SRC/apt-repo/dists/stable/InRelease" "$SRC/apt-repo/jatayu-media-player-archive-key.asc" "$SRC/flatpak-repo/summary" "$SRC/flatpak-repo/summary.sig" "$SRC/flatpak-repo/config" "$SRC/flatpak-repository-key.asc"; do
  [[ -s "$p" ]] || { echo "Missing required signed public repository file: $p" >&2; exit 1; }
done
command -v gpg >/dev/null || { echo "gpg required" >&2; exit 1; }
command -v rsync >/dev/null || { echo "rsync required" >&2; exit 1; }
gpg --batch --verify "$SRC/apt-repo/dists/stable/InRelease" || {
  echo "APT InRelease signature verification failed" >&2; exit 1;
}
[[ -d "$SRC/flatpak-repo/objects" ]] || { echo "Flatpak objects absent" >&2; exit 1; }
[[ -d "$SRC/apt-repo/pool" ]] || { echo "APT package pool absent" >&2; exit 1; }
# Never copy repository configuration or host-private files from outside the two output trees.
mkdir -p "$DST/apt" "$DST/flatpak"
rsync -a --delete --exclude=conf/ --exclude=db/ --exclude=lists/ "$SRC/apt-repo/" "$DST/apt/"
rsync -a --delete "$SRC/flatpak-repo/" "$DST/flatpak/"
cp "$SRC/flatpak-repository-key.asc" "$DST/flatpak-repository-key.asc"
printf '%s\n' "Staged signed public repository content; NO commit/push or deployment performed."
du -sh "$DST/apt" "$DST/flatpak"
git -C "$DST" status --short | head -n 35
echo "Check public keys and content before any Git push; do not copy secret keys."
