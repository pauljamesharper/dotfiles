#!/usr/bin/env bash
# Copy the widgets into Plasma's plasmoid folder. They can't be stowed: Plasma
# refuses package files that are symlinks pointing outside the package.
# Rerun after editing one, then restart Plasma to load it:
#   systemctl --user restart plasma-plasmashell
set -eu
cd "$(dirname "$0")"
dest=~/.local/share/plasma/plasmoids
mkdir -p "$dest"
for d in local.*/; do
    rm -rf "${dest:?}/${d%/}"
    cp -r "$d" "$dest/"
    echo "installed ${d%/}"
done
