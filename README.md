# dotfiles

Paul's personal configuration for an [Aurora](https://getaurora.dev) laptop
(Aurora DX, KDE Plasma with Krohnkite tiling), managed with
[GNU Stow](https://www.gnu.org/software/stow/).

Each top-level directory is a **package**: a slice of `$HOME` laid out exactly
as it should appear there. Stow symlinks each file into place, so editing
`~/.config/khal/config` edits the file in this repo, and `git diff` shows what
changed.

Branches: `aurora` (the default) is this setup. `bazzite` keeps the earlier
Bazzite DX + Mango version.

## Why Aurora

[Aurora](https://docs.getaurora.dev) is Universal Blue's KDE Plasma desktop,
built on Fedora Kinoite. What makes it pleasant to live on:

- **The system can't rot.** The OS is a signed, read-only image. Updates are
  downloaded in the background and applied whole at the next boot, and if one
  ever misbehaves, the previous image is one boot-menu entry away.
- **Plasma, done properly.** A current KDE Plasma with sensible defaults, and
  nothing in the way of making it your own.
- **The DX image is a developer's kit out of the box.** Podman, distrobox,
  Homebrew, VS Code and container tooling come preinstalled, so there's no
  need to layer packages onto the base system.
- **A clean split for software.** GUI apps come from Flatpak, CLI tools from
  Homebrew and mise, and anything that wants a normal mutable Fedora gets its
  own distrobox. The base image stays untouched, so updates never fight with
  what you've installed.
- **`ujust`** gathers maintenance chores (toggles, fixes, setup helpers) into
  short commands.

## Quick start

```bash
brew install stow                 # Aurora doesn't ship it; also in the Brewfile
git clone git@github.com:pauljamesharper/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow */                           # or name packages: stow khal khard vdirsyncer
mise install                      # install the CLI tools listed in the mise package
brew bundle --global              # install the Homebrew packages in ~/.Brewfile
```

## Packages

| Package | Links into `~` | What it's for |
|---|---|---|
| `alacritty` | `.config/alacritty/alacritty.toml` | Alacritty terminal. Colours come from `theme.toml`, which is generated, not tracked |
| `autoupdate` | `.config/systemd/user/{mise,distrobox}-upgrade.{service,timer}` | Daily upgrades that Aurora's `uupd` leaves out: mise and its tools, and the packages in every distrobox |
| `bash` | `.bashrc`, `.bash_profile` | Shell startup: mise activation, Universal Blue's bling, and aliases (`e` for `emacsclient -nw`, `fastfetch` using the config below) |
| `atuin` | `.config/atuin/config.toml` | Shell history search |
| `desk` | `.config/desk/themes/`, `.config/rofi/`, `.local/bin/desk-*`, Giants colours, icons and wallpapers | Switchable desktop themes and a wallpaper picker. See [Themes and wallpapers](#themes-and-wallpapers) |
| `emacs` | `.config/emacs/`, `.config/autostart/emacs-daemon.desktop`, `.local/bin/emacs-launch`, `.local/bin/soffice`, `emacsclient.desktop` | Emacs Writing Studio config with personal modules, the daemon autostart, a client launcher, and a LibreOffice shim. See [Emacs](#emacs) |
| `environment` | `.config/environment.d/intel-gtk-fix.conf` | Session environment: `GSK_RENDERER=gl` for GTK 4 on Intel graphics |
| `homebrew` | `.Brewfile` | Homebrew packages (aria2, atuin, bat, eza, ripgrep, starship, stow, zoxide…) for `brew bundle --global` |
| `fastfetch` | `.config/fastfetch/config.jsonc` | Aurora's fastfetch layout plus a line counting mise tools and pipx-style apps, which fastfetch can't detect itself |
| `gh` | `.config/gh/config.yml` | GitHub CLI settings (git over SSH) |
| `glow` | `.config/glow/glow.yml` | Markdown viewer |
| `khal` | `.config/khal/config` | Calendar (Google and EteSync), reading what vdirsyncer syncs |
| `khard` | `.config/khard/khard.conf` | Contacts (Google and EteSync), same arrangement |
| `mise` | `.config/mise/config.toml` | Global tool list: Claude Code, opencode, Ollama, Python, uv, Node, vdirsyncer, khal, khard, todoman, beancount + beangulp, fava, and Emacs's helpers (pyright, ruff, shfmt, shellcheck) |
| `ollama` | `.config/systemd/user/ollama.service` | Runs `ollama serve` as a user service |
| `opencode` | `.config/opencode/opencode.jsonc` | opencode settings |
| `starship` | `.config/starship.toml` | Shell prompt |
| `vdirsyncer` | `.config/vdirsyncer/config` | Syncs calendars and contacts between Google, EteSync and local folders |
| `vscode` | `.config/Code/User/settings.json` | VS Code editor settings |

## Emacs

Emacs lives in a Fedora distrobox named `emacs`, not on the base image. It
gets a native Wayland (pure GTK) build, and anything installed in the box is
there for Emacs alone. Your home folder is shared, so the config, mise tools
and files all work as usual.

One-off setup:

```bash
distrobox create -n emacs -i registry.fedoraproject.org/fedora-toolbox:44
distrobox enter emacs

# inside the box
sudo dnf install emacs-pgtk
# Point `emacs` straight at the Wayland build. Fedora's default is a wrapper
# script that makes Emacs look for its files next to ~/.local/bin/emacs.
sudo alternatives --set emacs /usr/bin/emacs-pgtk
distrobox-export --bin /usr/bin/emacs --export-path ~/.local/bin
distrobox-export --bin /usr/bin/emacsclient --export-path ~/.local/bin
# programs the config checks for at startup
sudo dnf install texlive-scheme-basic texlive-dvipng ImageMagick vorbis-tools poppler-utils mupdf
```

On Fedora 44 the plain `emacs` package accepts any build, and in a container
dnf picks the terminal-only one. That build has no `scroll-bar-mode`, so
`init.el` fails. Install `emacs-pgtk` by name.

How the pieces fit:

- **Daemon:** `emacs-daemon.desktop` in `~/.config/autostart` starts
  `emacs --fg-daemon` in the box at every Plasma login. The daemon's socket is
  in `/run/user/$UID`, which the box shares, so `emacsclient` works on both
  sides.
- **Opening a window:** `emacs-launch` runs `emacsclient -c -a ''`. It opens a
  new frame on the daemon, and starts a daemon first if none is running. The
  "Emacs (Client)" launcher and Meta+E both use it.
- **Language tools:** pyright, ruff, shfmt and shellcheck come from mise. They
  live in your home folder, so Emacs in the box finds them.
- **LibreOffice:** `soffice` runs the LibreOffice Flatpak. Inside a distrobox,
  `flatpak` forwards to the host, so the same shim works in both places. The
  Flatpak can't see the host's `/tmp`, so the config keeps doc-view's cache in
  `~/.config/emacs/doc-view`.
- **Homebrew:** brew lives in `/home/linuxbrew`, outside your home folder, so
  the box can't see it. Install anything Emacs needs with mise or dnf.

The first start downloads every package in the config. Run it once in a
terminal, and press Ctrl+C when the log goes quiet:

```bash
distrobox enter emacs -- emacs --fg-daemon
```

## Desktop: KDE Plasma and Krohnkite

Plasma's own settings files aren't tracked (see below), so this records what's
set up by hand.

- **[Krohnkite](https://github.com/anametologin/krohnkite)** (a KWin script
  installed in `~/.local/share/kwin/scripts`) tiles windows automatically, the
  way a tiling window manager does, while keeping everything else about
  Plasma. Gaps are 8 px around the screen edges and between windows.
- **Ten virtual desktops** in one row.
- **Main panel:** app launcher, desktop numbers, then (centred between two
  spacers) the Fokus pomodoro timer, clock, weather and caffeine, each 12 px
  apart, then a cheat-sheet widget, the system tray and show desktop.
- **Second screen's panel:** desktop numbers only, sized to fit them.

### Themes and wallpapers

The `desk` package, carried over from the earlier Aurora setup on Codeberg,
gives the whole desktop one switchable colour theme. There are 13: Giants
(the default, after Omarchy's Giants), Catppuccin, Doom One, Dracula,
Everforest, GitHub Dark, Gruvbox, Kanagawa, Monokai, Moonfly, Nord, Retro and
Rosé Pine Moon.

- **`desk-theme`** (Meta+Shift+T) shows a picker, or takes a theme id:
  `desk-theme nord`. It sets the KDE colour scheme, icons and GTK theme, and
  recolours Konsole (the `Desk` profile), Alacritty and rofi. A theme with a
  `wallpaper` in its `theme.conf` (a path, a file name under
  `~/.local/share/wallpapers`, or `slideshow`) switches the wallpaper too.
- **`desk-wallpaper`** (Meta+Shift+W) shows thumbnails of everything in
  `~/.local/share/wallpapers`, plus a slideshow of the 19 Giants wallpapers
  (credits in `Giants/CREDITS.md`).
- **`desk-omarchy`** imports [Omarchy](https://github.com/omacom/omarchy)'s
  22 themes as `omarchy-<id>` and their wallpapers into
  `~/.local/share/wallpapers/Omarchy` (minus Omarchy's logo wallpapers and
  duplicates), with each theme's first wallpaper as its default, then runs
  `desk-gen`. Rerun it to pick up Omarchy's changes. It keeps a sparse
  checkout in `~/.cache/desk/omarchy`; nothing it writes is tracked. The
  themes use Omarchy's Yaru accent icons, falling back to Breeze.
- **`desk-gen`** builds the KDE, Konsole, Alacritty and rofi colours from each
  theme's `theme.conf` and `foot-colors.ini`. Run it after adding or editing
  a theme in `desk/.config/desk/themes/<id>/`. Its output in
  `~/.config/desk/generated` isn't tracked.

One-off setup on a new machine:

```bash
desk-gen
# rofi for the pickers, and Yaru icons for the Giants icon theme, from the emacs box
distrobox enter emacs -- sudo dnf install rofi yaru-icon-theme
distrobox enter emacs -- distrobox-export --bin /usr/bin/rofi --export-path ~/.local/bin
# Yaru and its accent colours, which the Omarchy themes use
distrobox enter emacs -- cp -a /usr/share/icons/Yaru* ~/.local/share/icons/
desk-omarchy
# a Konsole profile for the themes to colour, as the default
cp ~/.local/share/konsole/Default.profile ~/.local/share/konsole/Desk.profile   # then set Name=Desk
kwriteconfig6 --file konsolerc --group "Desktop Entry" --key DefaultProfile Desk.profile
```

The other themes use [Colloid](https://github.com/vinceliuice/Colloid-icon-theme)
icons and [Orchis](https://github.com/vinceliuice/Orchis-theme) GTK themes.
Without them those themes still recolour everything, but icons and GTK apps
fall back to Breeze:

```bash
git clone --depth 1 https://github.com/vinceliuice/Colloid-icon-theme /tmp/colloid
cd /tmp/colloid
./install.sh -d ~/.local/share/icons -s default nord dracula gruvbox everforest catppuccin -t default
./install.sh -d ~/.local/share/icons -s default -t orange
./install.sh -d ~/.local/share/icons -s dracula -t grey

# Orchis needs sassc, so build it in a throwaway container
git clone --depth 1 https://github.com/vinceliuice/Orchis-theme /tmp/orchis
mkdir -p /tmp/orchis-out ~/.themes
podman run --rm -v /tmp/orchis:/src:Z -v /tmp/orchis-out:/out:Z registry.fedoraproject.org/fedora:latest bash -c '
  dnf -y -q install sassc which findutils && cd /src &&
  ./install.sh -d /out -c dark -t default purple green grey orange pink &&
  ./install.sh -d /out -c dark -t default --tweaks nord &&
  ./install.sh -d /out -c dark -t purple --tweaks dracula'
cp -a /tmp/orchis-out/. ~/.themes/
```

The pickers' shortcuts go in KDE's shortcut file. Write them while you're
logged out, or from a script in `~/.config/plasma-workspace/env/`, which runs
before KWin starts. Setting shortcuts over KDE's D-Bus shortcut service has
crashed KWin before.

### Keyboard shortcuts

Meta is the Windows/Super key.

| Keys | Action |
|---|---|
| Meta+Return | Konsole |
| Meta+Shift+Return | Konsole running tmux (`tmux-terminal.desktop`) |
| Meta+E | Emacs, a new frame on the daemon |
| Meta+B | Brave |
| Meta+F | Dolphin |
| Meta+Shift+T | Theme picker |
| Meta+Shift+W | Wallpaper picker |
| Meta+Space | KRunner |
| Meta+Q | Close window |
| Meta+W | Overview |
| Meta+G | Grid view of desktops |
| Meta+D | Show desktop |
| Meta+O | Move to the next screen |
| Meta+1 … Meta+0 | Switch to desktop 1–10 |
| Meta+Shift+1 … Meta+Shift+0 | Move window to desktop 1–10 |
| Meta+Ctrl+arrows | Switch desktop left/right/up/down |
| Meta+Esc | Lock screen |

Krohnkite uses Vim-style keys:

| Keys | Action |
|---|---|
| Meta+H / J / K / L | Focus window left / down / up / right |
| Meta+Shift+H / J / K / L | Move window left / down / up / right |
| Meta+Ctrl+H / L | Shrink / grow width |
| Meta+Ctrl+K / J | Shrink / grow height |
| Meta+. / Meta+, | Focus next / previous window |
| Meta+I | More windows in the master area |
| Meta+\\ / Meta+\| | Next / previous layout |
| Meta+M | Monocle layout (one window fills the screen) |
| Meta+R / Meta+Shift+R | Rotate the layout / part of it |
| Meta+Shift+F | Float all windows |

## After stowing

Some packages need a one-off step:

```bash
# Emacs: set up the distrobox (see Emacs above), then log out and in again,
# or start the daemon now
distrobox enter emacs -- emacs --daemon

# Ollama: run it as a service, then pull the model (about 5 GB)
systemctl --user daemon-reload
systemctl --user enable --now ollama.service
mise run ollama-models

# Daily mise and distrobox upgrades
systemctl --user daemon-reload
systemctl --user enable --now mise-upgrade.timer distrobox-upgrade.timer

# Calendars and contacts: authorise Google, then sync
vdirsyncer discover
vdirsyncer sync
```

## Secrets

No secrets live in this repo, and it is public. Anything secret comes from
[pass](https://www.passwordstore.org/) at runtime:

- vdirsyncer runs `pass etesync` for the EteSync password and
  `pass show google/vdirsyncer/client_secret` for the Google OAuth secret.
  Google's access tokens are written to `~/.vdirsyncer/`, outside the repo.
- Emacs reads the Anthropic and DeepSeek API keys through `auth-source`,
  which by default looks in `~/.authinfo.gpg`.
- For `gh`, only `config.yml` is tracked. `hosts.yml` holds the login token and
  stays local.

Restore `~/.gnupg` and `~/.password-store` before running vdirsyncer.

## Stow settings

`.stowrc` makes every `stow` run in this directory use:

- `--target=~`, so packages always land in your home folder, wherever you run
  stow from.
- `--no-folding`, so stow links individual files and never whole directories.
  Without it, `~/.config/emacs` would become a link to this repo, and
  everything Emacs writes there (packages, native-compiled files) would end up
  in git. The same applies to the calendars and contacts vdirsyncer stores
  under `~/.config/vdirsyncer`.

## Adding something new

Move the file into a package with the same path it has under `~`, then stow
the package:

```bash
mkdir -p ~/dotfiles/foo/.config/foo
mv ~/.config/foo/foo.toml ~/dotfiles/foo/.config/foo/
cd ~/dotfiles && stow foo
git add foo && git commit -m "Add foo" && git push
```

To stop managing a package, run `stow -D foo`. That removes the links and
leaves the files in the repo.

If stow reports a conflict, a real file already exists where a link should go.
Usually the app created a default config. Compare the two, keep the one you
want in the repo, delete the other from `~`, and stow again.

## What's deliberately not here

- **KDE's `*rc` files** (panels, shortcuts, Krohnkite, wallpapers), along with
  `mimeapps.list` and GTK settings. Apps save them by replacing the file,
  which turns stow's link back into a regular file, so tracking them doesn't
  work. The [Desktop](#desktop-kde-plasma-and-krohnkite) section records them
  instead.
- **distrobox exports**: `~/.local/bin/emacs` and `~/.local/bin/emacsclient`
  are generated by `distrobox-export`.
- **Generated files**: GTK, xsettingsd and Alacritty colours come from the
  theme scripts.
- **App state and keys**: libvirt VMs, VPN clients, KDE Connect, browser
  profiles.

## Expects

Some packages call programs that aren't in the image or this repo:

- `emacs-launch` and `emacs-daemon.desktop` need the `emacs` distrobox.
- `soffice` needs the LibreOffice Flatpak (`org.libreoffice.LibreOffice`).
- `alacritty.toml` imports `theme.toml`, written by `desk-theme`.
- `desk-theme` and `desk-wallpaper` need rofi (exported from the `emacs`
  box) and ImageMagick's `magick`, which Aurora includes.
- Alacritty itself.

## Keeping in sync

- The `fastfetch` package is a copy of Aurora's config
  (`/usr/share/ublue-os/fastfetch.jsonc`). If Aurora changes its layout,
  copy it again and re-add the mise line.
